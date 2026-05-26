#!/usr/bin/env python3
"""Generate GF API Catalog XML and MkDocs API Reference pages."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
PUBLIC_VISIBILITIES = {"public", "protected"}
CATALOG_VERSION = "1"
MODULE_LABELS = {
	"kernel": "Kernel",
	"standard": "Standard",
	"extensions/action_queue": "Action Queue",
	"extensions/asset_metadata": "Asset Metadata",
	"extensions/behavior_tree": "Behavior Tree",
	"extensions/camera": "Camera",
	"extensions/capability": "Capability",
	"extensions/combat": "Combat",
	"extensions/dialogue": "Dialogue",
	"extensions/domain": "Domain",
	"extensions/feedback": "Feedback",
	"extensions/flow": "Flow",
	"extensions/interaction": "Interaction",
	"extensions/network": "Network",
	"extensions/physics": "Physics",
	"extensions/save": "Save",
	"extensions/turn_based": "Turn Based",
}
MEMBER_GROUPS = {
	"signals": "Signals",
	"enums": "Enums",
	"constants": "Constants",
	"properties": "Properties",
	"methods": "Methods",
}


@dataclass
class ApiDocs:
	description: list[str] = field(default_factory=list)
	tags: dict[str, list[str]] = field(default_factory=dict)


@dataclass
class ApiMember:
	kind: str
	name: str
	signature: str
	line: int
	docs: ApiDocs
	decorators: list[str] = field(default_factory=list)


@dataclass
class ApiClass:
	name: str
	path: str
	module: str
	extends: str
	line: int
	docs: ApiDocs
	owner: str = ""
	signals: list[ApiMember] = field(default_factory=list)
	enums: list[ApiMember] = field(default_factory=list)
	constants: list[ApiMember] = field(default_factory=list)
	properties: list[ApiMember] = field(default_factory=list)
	methods: list[ApiMember] = field(default_factory=list)
	inner_classes: list["ApiClass"] = field(default_factory=list)


def main() -> int:
	parser = argparse.ArgumentParser(description="Generate GF API Catalog XML and API Reference pages.")
	parser.add_argument("--source", default="addons/gf", help="GDScript source root.")
	parser.add_argument("--catalog", default="docs/api_catalog", help="Generated XML catalog directory.")
	parser.add_argument("--output", default="docs/zh/reference/api", help="Generated MkDocs Markdown directory.")
	parser.add_argument("--check", action="store_true", help="Fail if catalog or Markdown pages are stale.")
	args = parser.parse_args()

	source_root = (ROOT / args.source).resolve()
	catalog_root = (ROOT / args.catalog).resolve()
	output_root = (ROOT / args.output).resolve()
	if not source_root.exists():
		print(f"source root not found: {source_root}")
		return 2

	api_classes = collect_api_classes(source_root)
	catalog_files = render_catalog_files(api_classes, source_root)
	reference_files = render_reference_files(api_classes, catalog_files["index.xml"])
	coverage_status = check_reference_coverage(api_classes, reference_files, report_success=args.check)
	if args.check:
		return max(
			check_files(catalog_root, catalog_files, "API Catalog"),
			check_files(output_root, reference_files, "API Reference"),
			coverage_status,
		)
	if coverage_status:
		return coverage_status

	write_generated_files(catalog_root, catalog_files)
	write_generated_files(output_root, reference_files)
	all_classes = flatten_api_classes(api_classes)
	class_count = len(all_classes)
	method_count = sum(len(api_class.methods) for api_class in all_classes)
	print(f"generated API Catalog: {class_count} classes in {len(api_classes)} files, {method_count} methods")
	print(f"catalog: {catalog_root}")
	print(f"reference: {output_root}")
	return 0


def collect_api_classes(source_root: Path) -> list[ApiClass]:
	result: list[ApiClass] = []
	for path in sorted(source_root.rglob("*.gd")):
		api_class = parse_gdscript_file(path, source_root)
		if api_class == None:
			continue
		if visibility_of(api_class.docs) not in PUBLIC_VISIBILITIES:
			continue
		result.append(strip_internal_members(api_class))
	return result


def parse_gdscript_file(path: Path, source_root: Path) -> ApiClass | None:
	relative_path = path.relative_to(ROOT).as_posix()
	source_relative = path.relative_to(source_root)
	module = module_from_path(source_relative)
	lines = path.read_text(encoding="utf-8").splitlines()
	docs_buffer: list[str] = []
	decorators: list[str] = []
	in_multiline_string = False
	api_class: ApiClass | None = None
	pending_extends = ""
	i = 0
	while i < len(lines):
		raw_line = lines[i]
		stripped = raw_line.strip()
		if has_triple_quote(stripped):
			in_multiline_string = not in_multiline_string
			i += 1
			continue
		if in_multiline_string or not is_top_level(raw_line):
			i += 1
			continue
		if stripped.startswith("##"):
			docs_buffer.append(stripped[2:].strip())
			i += 1
			continue
		if stripped.startswith("@") and not stripped.startswith("@export var "):
			decorators.append(stripped)
			i += 1
			continue
		if not stripped:
			i += 1
			continue

		if match := re.match(r"extends\s+(.+)", stripped):
			extends_value = match.group(1).strip()
			if api_class == None:
				pending_extends = extends_value
			else:
				api_class.extends = extends_value
			clear_buffers(docs_buffer, decorators)
			i += 1
			continue
		if match := re.match(r"class_name\s+([A-Za-z_]\w*)", stripped):
			api_class = ApiClass(
				name=match.group(1),
				path=relative_path,
				module=module,
				extends=pending_extends,
				line=i + 1,
				docs=parse_docs(docs_buffer),
			)
			clear_buffers(docs_buffer, decorators)
			i += 1
			continue
		if api_class == None:
			clear_buffers(docs_buffer, decorators)
			i += 1
			continue
		if match := re.match(r"signal\s+([A-Za-z_]\w*)", stripped):
			api_class.signals.append(make_member("signal", match.group(1), stripped, i, docs_buffer, decorators))
			clear_buffers(docs_buffer, decorators)
			i += 1
			continue
		if match := re.match(r"enum\s+([A-Za-z_]\w*)", stripped):
			signature, next_index = collect_block_signature(lines, i)
			api_class.enums.append(make_member("enum", match.group(1), signature, i, docs_buffer, decorators))
			clear_buffers(docs_buffer, decorators)
			i = next_index
			continue
		if match := re.match(r"const\s+([A-Za-z_]\w*)", stripped):
			name = match.group(1)
			if not name.startswith("_"):
				api_class.constants.append(make_member("const", name, stripped, i, docs_buffer, decorators))
			clear_buffers(docs_buffer, decorators)
			i += 1
			continue
		var_line = stripped
		if stripped.startswith("@export var "):
			decorators.append("@export")
			var_line = stripped.removeprefix("@export ").strip()
		if match := re.match(r"var\s+([A-Za-z_]\w*)", var_line):
			name = match.group(1)
			if not name.startswith("_"):
				api_class.properties.append(make_member("property", name, var_line, i, docs_buffer, decorators))
			clear_buffers(docs_buffer, decorators)
			i += 1
			continue
		if stripped.startswith("func ") or stripped.startswith("static func "):
			signature, next_index = collect_function_signature(lines, i)
			name = parse_function_name(signature)
			if name and not name.startswith("_"):
				api_class.methods.append(make_member("method", name, signature, i, docs_buffer, decorators))
			clear_buffers(docs_buffer, decorators)
			i = next_index
			continue
		clear_buffers(docs_buffer, decorators)
		i += 1
	if api_class != None:
		api_class.inner_classes = parse_inner_classes(lines, api_class)
	return api_class


def parse_inner_classes(lines: list[str], owner: ApiClass) -> list[ApiClass]:
	result: list[ApiClass] = []
	docs_buffer: list[str] = []
	for i, raw_line in enumerate(lines):
		if not is_top_level(raw_line):
			continue

		stripped = raw_line.strip()
		if stripped.startswith("##"):
			docs_buffer.append(stripped[2:].strip())
			continue
		if not stripped:
			continue

		if match := re.match(r"class\s+([A-Za-z_]\w*)(?:\s+extends\s+([^:]+))?:", stripped):
			docs = parse_docs(docs_buffer)
			inner_class = ApiClass(
				name=match.group(1),
				path=owner.path,
				module=owner.module,
				extends=(match.group(2) or "").strip(),
				line=i + 1,
				docs=docs,
				owner=full_api_class_name(owner),
			)
			block_end = find_class_block_end(lines, i, get_indent_level(raw_line))
			parse_inner_class_members(lines, i + 1, block_end, inner_class, get_indent_level(raw_line))
			result.append(inner_class)
			docs_buffer = []
			continue

		docs_buffer = []
	return result


def find_class_block_end(lines: list[str], start: int, class_indent: int) -> int:
	for i in range(start + 1, len(lines)):
		raw_line = lines[i]
		if not raw_line.strip():
			continue
		if get_indent_level(raw_line) <= class_indent:
			return i
	return len(lines)


def parse_inner_class_members(
	lines: list[str],
	start: int,
	end: int,
	inner_class: ApiClass,
	class_indent: int,
) -> None:
	member_indent = find_direct_child_indent(lines, start, end, class_indent)
	if member_indent == None:
		return

	docs_buffer: list[str] = []
	decorators: list[str] = []
	i = start
	while i < end:
		raw_line = lines[i]
		stripped = raw_line.strip()
		if not stripped:
			i += 1
			continue
		if get_indent_level(raw_line) != member_indent:
			i += 1
			continue

		if stripped.startswith("##"):
			docs_buffer.append(stripped[2:].strip())
			i += 1
			continue
		if stripped.startswith("@") and not stripped.startswith("@export var "):
			decorators.append(stripped)
			i += 1
			continue

		if match := re.match(r"signal\s+([A-Za-z_]\w*)", stripped):
			inner_class.signals.append(make_member("signal", match.group(1), stripped, i, docs_buffer, decorators))
			clear_buffers(docs_buffer, decorators)
			i += 1
			continue
		if match := re.match(r"enum\s+([A-Za-z_]\w*)", stripped):
			signature, next_index = collect_block_signature(lines, i)
			inner_class.enums.append(make_member("enum", match.group(1), signature, i, docs_buffer, decorators))
			clear_buffers(docs_buffer, decorators)
			i = min(next_index, end)
			continue
		if match := re.match(r"const\s+([A-Za-z_]\w*)", stripped):
			name = match.group(1)
			if not name.startswith("_"):
				inner_class.constants.append(make_member("const", name, stripped, i, docs_buffer, decorators))
			clear_buffers(docs_buffer, decorators)
			i += 1
			continue
		var_line = stripped
		if stripped.startswith("@export var "):
			decorators.append("@export")
			var_line = stripped.removeprefix("@export ").strip()
		if match := re.match(r"var\s+([A-Za-z_]\w*)", var_line):
			name = match.group(1)
			if not name.startswith("_"):
				inner_class.properties.append(make_member("property", name, var_line, i, docs_buffer, decorators))
			clear_buffers(docs_buffer, decorators)
			i += 1
			continue
		if stripped.startswith("func ") or stripped.startswith("static func "):
			signature, next_index = collect_function_signature(lines, i)
			name = parse_function_name(signature)
			if name and not name.startswith("_"):
				inner_class.methods.append(make_member("method", name, signature, i, docs_buffer, decorators))
			clear_buffers(docs_buffer, decorators)
			i = min(next_index, end)
			continue

		clear_buffers(docs_buffer, decorators)
		i += 1


def find_direct_child_indent(lines: list[str], start: int, end: int, class_indent: int) -> int | None:
	for i in range(start, end):
		raw_line = lines[i]
		if not raw_line.strip():
			continue
		indent = get_indent_level(raw_line)
		if indent > class_indent:
			return indent
	return None


def strip_internal_members(api_class: ApiClass) -> ApiClass:
	api_class.signals = filter_public_members(api_class.signals)
	api_class.enums = filter_public_members(api_class.enums)
	api_class.constants = filter_public_members(api_class.constants)
	api_class.properties = filter_public_members(api_class.properties)
	api_class.methods = filter_public_members(api_class.methods)
	api_class.inner_classes = [
		strip_internal_members(inner_class)
		for inner_class in api_class.inner_classes
		if visibility_of(inner_class.docs) in PUBLIC_VISIBILITIES
	]
	return api_class


def filter_public_members(members: list[ApiMember]) -> list[ApiMember]:
	return [
		member
		for member in members
		if visibility_of(member.docs) in PUBLIC_VISIBILITIES
	]


def render_catalog_files(api_classes: list[ApiClass], source_root: Path) -> dict[str, str]:
	classes_payload = [api_class_to_digest_payload(api_class) for api_class in api_classes]
	source_digest = hashlib.sha256(
		json.dumps(classes_payload, ensure_ascii=False, sort_keys=True).encode("utf-8")
	).hexdigest()
	files: dict[str, str] = {
		"index.xml": render_catalog_index(api_classes, source_root, source_digest),
	}
	for api_class in api_classes:
		files[f"classes/{api_class.name}.xml"] = render_class_xml(api_class, source_digest)
	return files


def render_catalog_index(api_classes: list[ApiClass], source_root: Path, source_digest: str) -> str:
	all_classes = flatten_api_classes(api_classes)
	root = ET.Element(
		"apiCatalog",
		{
			"schemaVersion": CATALOG_VERSION,
			"name": "GF Framework",
			"sourceRoot": source_root.relative_to(ROOT).as_posix(),
			"sourceDigest": source_digest,
			"classCount": str(len(all_classes)),
			"methodCount": str(sum(len(api_class.methods) for api_class in all_classes)),
		},
	)
	for module in sorted({api_class.module for api_class in all_classes}, key=module_sort_key):
		module_classes = [api_class for api_class in all_classes if api_class.module == module]
		module_element = ET.SubElement(
			root,
			"module",
			{
				"id": module,
				"label": module_label(module),
				"classCount": str(len(module_classes)),
				"methodCount": str(sum(len(api_class.methods) for api_class in module_classes)),
			},
		)
		for api_class in sorted(module_classes, key=lambda item: full_api_class_name(item)):
			owner_path = f"classes/{top_level_class_name(api_class)}.xml"
			ET.SubElement(
				module_element,
				"class",
				{
					"name": full_api_class_name(api_class),
					"path": owner_path,
					"sourcePath": api_class.path,
					"extends": api_class.extends or "Object",
				},
			)
	return xml_to_text(root)


def render_class_xml(api_class: ApiClass, source_digest: str) -> str:
	root = ET.Element(
		"class",
		{
			"name": api_class.name,
			"path": api_class.path,
			"module": api_class.module,
			"extends": api_class.extends or "Object",
			"line": str(api_class.line),
			"sourceDigest": source_digest,
		},
	)
	append_docs(root, api_class.docs)
	append_members(root, "signals", api_class.signals)
	append_members(root, "enums", api_class.enums)
	append_members(root, "constants", api_class.constants)
	append_members(root, "properties", api_class.properties)
	append_members(root, "methods", api_class.methods)
	append_inner_classes(root, api_class.inner_classes)
	return xml_to_text(root)


def append_docs(parent: ET.Element, docs: ApiDocs) -> None:
	ET.SubElement(parent, "description").text = "\n".join(docs.description)
	tags_element = ET.SubElement(parent, "tags")
	for name in sorted(docs.tags):
		for value in docs.tags[name]:
			tag_element = ET.SubElement(tags_element, "tag", {"name": name})
			tag_element.text = value


def append_members(parent: ET.Element, group_name: str, members: list[ApiMember]) -> None:
	group = ET.SubElement(parent, group_name)
	for member in members:
		member_element = ET.SubElement(
			group,
			"member",
			{
				"kind": member.kind,
				"name": member.name,
				"line": str(member.line),
			},
		)
		if member.decorators:
			member_element.set("decorators", " ".join(member.decorators))
		ET.SubElement(member_element, "signature").text = member.signature
		append_docs(member_element, member.docs)


def append_inner_classes(parent: ET.Element, inner_classes: list[ApiClass]) -> None:
	group = ET.SubElement(parent, "innerClasses")
	for inner_class in sorted(inner_classes, key=lambda item: full_api_class_name(item)):
		inner_element = ET.SubElement(
			group,
			"class",
			{
				"name": inner_class.name,
				"fullName": full_api_class_name(inner_class),
				"extends": inner_class.extends or "Object",
				"line": str(inner_class.line),
			},
		)
		append_docs(inner_element, inner_class.docs)
		append_members(inner_element, "signals", inner_class.signals)
		append_members(inner_element, "enums", inner_class.enums)
		append_members(inner_element, "constants", inner_class.constants)
		append_members(inner_element, "properties", inner_class.properties)
		append_members(inner_element, "methods", inner_class.methods)


def render_reference_files(api_classes: list[ApiClass], catalog_index_xml: str) -> dict[str, str]:
	catalog_root = ET.fromstring(catalog_index_xml)
	files: dict[str, str] = {
		"index.md": render_reference_index(api_classes, catalog_root),
	}
	for module in sorted({api_class.module for api_class in api_classes}, key=module_sort_key):
		module_classes = [api_class for api_class in api_classes if api_class.module == module]
		files[f"{module_slug(module)}.md"] = render_reference_module(module, module_classes)
	return files


def render_reference_index(api_classes: list[ApiClass], catalog_root: ET.Element) -> str:
	all_classes = flatten_api_classes(api_classes)
	lines = [
		"# API Reference",
		"",
		"本区由 `tools/generate_api_reference.py` 生成。生成流程为：`addons/gf` 源码 API 注释 -> XML API Catalog -> Markdown Reference。",
		"XML Catalog 位于 `docs/api_catalog`，是文档生成和结构校验的中间层；Markdown 页面不应手动编辑。",
		"",
		"## 生成范围",
		"",
		f"- Source root: `{catalog_root.get('sourceRoot', '')}`",
		f"- Source digest: `{catalog_root.get('sourceDigest', '')}`",
		f"- Public classes: `{catalog_root.get('classCount', '0')}`",
		f"- Public methods: `{catalog_root.get('methodCount', '0')}`",
		"",
		"## Modules",
		"",
		"| Module | Classes | Methods | Page |",
		"|---|---:|---:|---|",
	]
	for module in sorted({api_class.module for api_class in all_classes}, key=module_sort_key):
		module_classes = [api_class for api_class in all_classes if api_class.module == module]
		class_count = len(module_classes)
		method_count = sum(len(api_class.methods) for api_class in module_classes)
		page = f"{module_slug(module)}.md"
		lines.append(f"| {module_label(module)} | {class_count} | {method_count} | [{page}]({page}) |")
	lines.extend(["", "## Class Index", ""])
	for api_class in sorted(all_classes, key=lambda item: full_api_class_name(item)):
		page = f"{module_slug(api_class.module)}.md"
		lines.append(f"- [`{full_api_class_name(api_class)}`]({page}#{anchor_for(full_api_class_name(api_class))}) - `{api_class.path}`")
	return "\n".join(lines) + "\n"


def render_reference_module(module: str, api_classes: list[ApiClass]) -> str:
	module_all_classes = flatten_api_classes(api_classes)
	lines = [
		f"# {module_label(module)} API",
		"",
		f"Module: `{module}`",
		"",
		"## Classes",
		"",
	]
	for api_class in sorted(module_all_classes, key=lambda item: full_api_class_name(item)):
		lines.append(f"- [`{full_api_class_name(api_class)}`](#{anchor_for(full_api_class_name(api_class))})")
	lines.append("")
	for api_class in sorted(api_classes, key=lambda item: item.name):
		append_api_class_markdown(lines, api_class)
	return "\n".join(lines) + "\n"


def append_api_class_markdown(lines: list[str], api_class: ApiClass) -> None:
	lines.extend([
		f"## {full_api_class_name(api_class)}",
		"",
		f"- Path: `{api_class.path}`",
		f"- Extends: `{api_class.extends or 'Object'}`",
	])
	append_tag_line(lines, "API", visibility_of(api_class.docs))
	append_tag_line(lines, "Category", first_tag(api_class.docs, "category"))
	append_tag_line(lines, "Since", first_tag(api_class.docs, "since"))
	append_tag_line(lines, "Deprecated", "; ".join(api_class.docs.tags.get("deprecated", [])))
	lines.append("")
	append_description(lines, api_class.docs.description)
	append_member_group_markdown(lines, "signals", api_class.signals)
	append_member_group_markdown(lines, "enums", api_class.enums)
	append_member_group_markdown(lines, "constants", api_class.constants)
	append_member_group_markdown(lines, "properties", api_class.properties)
	append_member_group_markdown(lines, "methods", api_class.methods)
	append_inner_classes_markdown(lines, api_class)


def append_inner_classes_markdown(lines: list[str], api_class: ApiClass) -> None:
	if not api_class.inner_classes:
		return
	lines.extend(["### Inner Classes", ""])
	for inner_class in sorted(api_class.inner_classes, key=lambda item: full_api_class_name(item)):
		lines.extend([
			f"#### {full_api_class_name(inner_class)}",
			"",
			f"- Extends: `{inner_class.extends or 'Object'}`",
		])
		append_tag_line(lines, "API", visibility_of(inner_class.docs))
		append_tag_line(lines, "Category", first_tag(inner_class.docs, "category"))
		append_tag_line(lines, "Since", first_tag(inner_class.docs, "since"))
		append_tag_line(lines, "Deprecated", "; ".join(inner_class.docs.tags.get("deprecated", [])))
		lines.append("")
		append_description(lines, inner_class.docs.description)
		append_member_group_markdown(lines, "signals", inner_class.signals, group_level=5, member_level=6)
		append_member_group_markdown(lines, "enums", inner_class.enums, group_level=5, member_level=6)
		append_member_group_markdown(lines, "constants", inner_class.constants, group_level=5, member_level=6)
		append_member_group_markdown(lines, "properties", inner_class.properties, group_level=5, member_level=6)
		append_member_group_markdown(lines, "methods", inner_class.methods, group_level=5, member_level=6)


def append_member_group_markdown(
	lines: list[str],
	group_name: str,
	members: list[ApiMember],
	group_level: int = 3,
	member_level: int = 4,
) -> None:
	if not members:
		return
	lines.extend([f"{'#' * group_level} {MEMBER_GROUPS[group_name]}", ""])
	for member in members:
		lines.extend([f"{'#' * member_level} `{member.name}`", ""])
		append_tag_line(lines, "API", visibility_of(member.docs))
		append_tag_line(lines, "Since", first_tag(member.docs, "since"))
		append_tag_line(lines, "Deprecated", "; ".join(member.docs.tags.get("deprecated", [])))
		lines.append("")
		lines.extend(["```gdscript", member.signature, "```", ""])
		append_description(lines, member.docs.description)
		append_params(lines, member.docs)
		append_return(lines, member.docs)
		append_schemas(lines, member.docs)


def append_description(lines: list[str], description: list[str]) -> None:
	if description:
		lines.append(" ".join(description))
		lines.append("")


def append_params(lines: list[str], docs: ApiDocs) -> None:
	params = docs.tags.get("param", [])
	if not params:
		return
	lines.extend(["Parameters:", "", "| Name | Description |", "|---|---|"])
	for param in params:
		name, description = split_named_value(param)
		lines.append(f"| `{name}` | {description} |")
	lines.append("")


def append_return(lines: list[str], docs: ApiDocs) -> None:
	returns = docs.tags.get("return", [])
	if returns:
		lines.append(f"Returns: {' '.join(returns)}")
		lines.append("")


def append_schemas(lines: list[str], docs: ApiDocs) -> None:
	schemas = docs.tags.get("schema", [])
	if not schemas:
		return
	lines.extend(["Schemas:", ""])
	for schema in schemas:
		name, description = split_named_value(schema)
		lines.append(f"- `{name}`: {description}")
	lines.append("")


def append_tag_line(lines: list[str], label: str, value: str) -> None:
	if value:
		lines.append(f"- {label}: `{value}`")


def parse_docs(lines: list[str]) -> ApiDocs:
	docs = ApiDocs()
	for raw_line in lines:
		line = raw_line.strip()
		if not line or line == "[br]":
			continue
		if line.startswith("@"):
			name, value = split_tag(line)
			docs.tags.setdefault(name, []).append(value)
		else:
			docs.description.append(line)
	return docs


def make_member(
	kind: str,
	name: str,
	signature: str,
	line_index: int,
	docs_buffer: list[str],
	decorators: list[str],
) -> ApiMember:
	return ApiMember(
		kind=kind,
		name=name,
		signature=signature,
		line=line_index + 1,
		docs=parse_docs(docs_buffer),
		decorators=decorators[:],
	)


def collect_function_signature(lines: list[str], start: int) -> tuple[str, int]:
	parts = [lines[start].strip()]
	depth = parenthesis_delta(parts[0])
	i = start
	while depth > 0 and i + 1 < len(lines):
		i += 1
		part = lines[i].strip()
		parts.append(part)
		depth += parenthesis_delta(part)
	return " ".join(parts), i + 1


def collect_block_signature(lines: list[str], start: int) -> tuple[str, int]:
	parts = [lines[start].strip()]
	depth = brace_delta(parts[0])
	i = start
	while depth > 0 and i + 1 < len(lines):
		i += 1
		part = lines[i].strip()
		parts.append(part)
		depth += brace_delta(part)
	return " ".join(parts), i + 1


def parse_function_name(signature: str) -> str:
	match = re.search(r"(?:static\s+)?func\s+([A-Za-z_]\w*)", signature)
	return match.group(1) if match else ""


def module_from_path(relative_path: Path) -> str:
	parts = relative_path.parts
	if not parts:
		return "root"
	if parts[0] == "extensions" and len(parts) > 1:
		return f"{parts[0]}/{parts[1]}"
	return parts[0]


def visibility_of(docs: ApiDocs) -> str:
	value = first_tag(docs, "api")
	return value.split()[0] if value else ""


def first_tag(docs: ApiDocs, name: str) -> str:
	values = docs.tags.get(name, [])
	return values[0] if values else ""


def split_tag(line: str) -> tuple[str, str]:
	without_prefix = line[1:]
	if " " not in without_prefix:
		if ":" in without_prefix:
			name, value = without_prefix.split(":", 1)
			return name.strip(), value.strip()
		return without_prefix.strip().rstrip(":"), ""
	name, value = without_prefix.split(" ", 1)
	return name.strip().rstrip(":"), value.strip()


def split_named_value(value: str) -> tuple[str, str]:
	if ":" not in value:
		return value.strip(), ""
	name, description = value.split(":", 1)
	return name.strip(), description.strip()


def has_triple_quote(text: str) -> bool:
	return (text.count('"""') + text.count("'''")) % 2 == 1


def is_top_level(raw_line: str) -> bool:
	return raw_line == raw_line.lstrip(" \t")


def get_indent_level(raw_line: str) -> int:
	level = 0
	for character in raw_line:
		if character == "\t":
			level += 1
		elif character == " ":
			level += 1
		else:
			break
	return level


def parenthesis_delta(text: str) -> int:
	return text.count("(") - text.count(")")


def brace_delta(text: str) -> int:
	return text.count("{") - text.count("}")


def clear_buffers(docs_buffer: list[str], decorators: list[str]) -> None:
	docs_buffer.clear()
	decorators.clear()


def module_label(module: str) -> str:
	return MODULE_LABELS.get(module, module.replace("/", " / ").replace("_", " ").title())


def module_slug(module: str) -> str:
	return module.replace("/", "-").replace("_", "-")


def module_sort_key(module: str) -> tuple[int, str]:
	if module == "kernel":
		return (0, module)
	if module == "standard":
		return (1, module)
	return (2, module)


def full_api_class_name(api_class: ApiClass) -> str:
	return f"{api_class.owner}.{api_class.name}" if api_class.owner else api_class.name


def top_level_class_name(api_class: ApiClass) -> str:
	return api_class.owner.split(".", 1)[0] if api_class.owner else api_class.name


def flatten_api_classes(api_classes: list[ApiClass]) -> list[ApiClass]:
	result: list[ApiClass] = []
	for api_class in api_classes:
		result.append(api_class)
		result.extend(flatten_api_classes(api_class.inner_classes))
	return result


def anchor_for(title: str) -> str:
	return title.lower().replace("_", "-").replace(".", "")


def api_class_to_digest_payload(api_class: ApiClass) -> dict[str, Any]:
	return {
		"name": api_class.name,
		"path": api_class.path,
		"module": api_class.module,
		"extends": api_class.extends,
		"line": api_class.line,
		"owner": api_class.owner,
		"docs": docs_to_payload(api_class.docs),
		"signals": [member_to_payload(member) for member in api_class.signals],
		"enums": [member_to_payload(member) for member in api_class.enums],
		"constants": [member_to_payload(member) for member in api_class.constants],
		"properties": [member_to_payload(member) for member in api_class.properties],
		"methods": [member_to_payload(member) for member in api_class.methods],
		"inner_classes": [api_class_to_digest_payload(inner_class) for inner_class in api_class.inner_classes],
	}


def member_to_payload(member: ApiMember) -> dict[str, Any]:
	return {
		"kind": member.kind,
		"name": member.name,
		"signature": member.signature,
		"line": member.line,
		"docs": docs_to_payload(member.docs),
		"decorators": member.decorators,
	}


def docs_to_payload(docs: ApiDocs) -> dict[str, Any]:
	return {
		"description": docs.description,
		"tags": docs.tags,
	}


def xml_to_text(element: ET.Element) -> str:
	ET.indent(element, space="\t")
	return '<?xml version="1.0" encoding="utf-8"?>\n' + ET.tostring(element, encoding="unicode") + "\n"


def write_generated_files(root: Path, files: dict[str, str]) -> None:
	if root.exists():
		for path in root.rglob("*"):
			if path.is_file():
				path.unlink()
		for path in sorted(root.rglob("*"), reverse=True):
			if path.is_dir():
				path.rmdir()
	root.mkdir(parents=True, exist_ok=True)
	for relative, content in files.items():
		path = root / relative
		path.parent.mkdir(parents=True, exist_ok=True)
		path.write_text(content, encoding="utf-8", newline="\n")


def check_files(root: Path, desired: dict[str, str], label: str) -> int:
	mismatches: list[str] = []
	for relative, content in desired.items():
		path = root / relative
		if not path.exists():
			mismatches.append(f"missing: {relative}")
			continue
		if path.read_text(encoding="utf-8") != content:
			mismatches.append(f"stale: {relative}")
	existing = {
		path.relative_to(root).as_posix()
		for path in root.rglob("*")
		if path.is_file()
	} if root.exists() else set()
	for extra in sorted(existing - set(desired.keys())):
		mismatches.append(f"extra: {extra}")
	if not mismatches:
		print(f"{label} is current.")
		return 0
	print(f"{label} is stale:")
	for mismatch in mismatches:
		print(f"- {mismatch}")
	return 1


def check_reference_coverage(
	api_classes: list[ApiClass],
	reference_files: dict[str, str],
	report_success: bool = True,
) -> int:
	errors: list[str] = []
	class_count = 0
	member_count = 0
	for api_class in sorted(api_classes, key=lambda item: full_api_class_name(item)):
		class_errors, class_members = check_class_reference_coverage(api_class, reference_files, 2)
		errors.extend(class_errors)
		class_count += 1
		member_count += class_members
		for inner_class in sorted(api_class.inner_classes, key=lambda item: full_api_class_name(item)):
			inner_errors, inner_members = check_class_reference_coverage(inner_class, reference_files, 4)
			errors.extend(inner_errors)
			class_count += 1
			member_count += inner_members

	if errors:
		print("API Reference coverage is incomplete:")
		for error in errors:
			print(f"- {error}")
		return 1

	if report_success:
		print(f"API Reference coverage is complete: {class_count} classes, {member_count} members.")
	return 0


def check_class_reference_coverage(
	api_class: ApiClass,
	reference_files: dict[str, str],
	class_heading_level: int,
) -> tuple[list[str], int]:
	errors: list[str] = []
	file_name = f"{module_slug(api_class.module)}.md"
	text = reference_files.get(file_name)
	full_name = full_api_class_name(api_class)
	if text == None:
		return [f"{full_name}: missing module reference page {file_name}"], 0

	section = find_heading_section(text, class_heading_level, full_name)
	if section == None:
		return [f"{full_name}: missing class heading in {file_name}"], 0

	if class_heading_level == 2:
		section = section.split("\n### Inner Classes\n", 1)[0]

	members = api_class_members(api_class)
	for member in members:
		member_heading = f"{'#' * (class_heading_level + 2)} `{member.name}`"
		if not has_markdown_line(section, member_heading):
			errors.append(f"{full_name}.{member.name}: missing member heading in {file_name}")
			continue
		if member.signature not in section:
			errors.append(f"{full_name}.{member.name}: missing signature in {file_name}")

	return errors, len(members)


def find_heading_section(text: str, level: int, title: str) -> str | None:
	lines = text.splitlines()
	start_index = -1
	target = f"{'#' * level} {title}"
	for index, line in enumerate(lines):
		if line == target:
			start_index = index
			break
	if start_index == -1:
		return None

	heading_pattern = re.compile(r"^(#{1,%d})\s+" % level)
	end_index = len(lines)
	for index in range(start_index + 1, len(lines)):
		if heading_pattern.match(lines[index]):
			end_index = index
			break
	return "\n".join(lines[start_index:end_index]) + "\n"


def has_markdown_line(text: str, expected_line: str) -> bool:
	return any(line == expected_line for line in text.splitlines())


def api_class_members(api_class: ApiClass) -> list[ApiMember]:
	members: list[ApiMember] = []
	members.extend(api_class.signals)
	members.extend(api_class.enums)
	members.extend(api_class.constants)
	members.extend(api_class.properties)
	members.extend(api_class.methods)
	return members


if __name__ == "__main__":
	raise SystemExit(main())
