#!/usr/bin/env python3
"""Generate a compact AI-facing API index for GF GDScript files."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]


@dataclass
class ApiItem:
	kind: str
	name: str
	signature: str
	line: int
	docs: list[str] = field(default_factory=list)
	decorators: list[str] = field(default_factory=list)


@dataclass
class ApiFile:
	path: str
	module: str
	class_name: str = ""
	extends: str = ""
	summary: list[str] = field(default_factory=list)
	signals: list[ApiItem] = field(default_factory=list)
	enums: list[ApiItem] = field(default_factory=list)
	constants: list[ApiItem] = field(default_factory=list)
	variables: list[ApiItem] = field(default_factory=list)
	methods: list[ApiItem] = field(default_factory=list)


def main() -> int:
	parser = argparse.ArgumentParser(description="Generate GF AI API docs.")
	parser.add_argument("--source", default="addons/gf", help="GDScript source root.")
	parser.add_argument("--output", default="ai_analysis/generated_api", help="Output directory.")
	parser.add_argument("--check", action="store_true", help="Fail if existing generated files are stale.")
	parser.add_argument("--wiki", default="docs/wiki", help="Wiki root used by --check-wiki-coverage.")
	parser.add_argument(
		"--check-wiki-coverage",
		action="store_true",
		help="Fail if public class_name entries are not mentioned in non-changelog Wiki pages.",
	)
	args = parser.parse_args()

	source_root = (ROOT / args.source).resolve()
	output_dir = (ROOT / args.output).resolve()
	if not source_root.exists():
		print(f"source root not found: {source_root}", file=sys.stderr)
		return 2

	api_files = collect_api(source_root)
	desired = render_outputs(api_files, source_root)
	coverage_status = 0
	if args.check_wiki_coverage:
		coverage_status = check_wiki_coverage(api_files, (ROOT / args.wiki).resolve())
	if args.check:
		check_status = check_outputs(output_dir, desired)
		return max(check_status, coverage_status)

	write_outputs(output_dir, desired)
	class_count = sum(1 for item in api_files if item.class_name)
	method_count = sum(len(item.methods) for item in api_files)
	print(f"generated {len(api_files)} files, {class_count} classes, {method_count} public methods")
	print(f"output: {output_dir}")
	return coverage_status


def collect_api(source_root: Path) -> list[ApiFile]:
	result: list[ApiFile] = []
	for path in sorted(source_root.rglob("*.gd")):
		api_file = parse_gdscript(path, source_root)
		if api_file.class_name or has_public_surface(api_file):
			result.append(api_file)
	return result


def has_public_surface(api_file: ApiFile) -> bool:
	return bool(
		api_file.signals
		or api_file.enums
		or api_file.constants
		or api_file.variables
		or api_file.methods
	)


def parse_gdscript(path: Path, source_root: Path) -> ApiFile:
	relative = path.relative_to(ROOT).as_posix()
	module = get_module(path.relative_to(source_root))
	api_file = ApiFile(path=relative, module=module)
	lines = path.read_text(encoding="utf-8").splitlines()
	docs: list[str] = []
	decorators: list[str] = []
	in_multiline_string = False
	i = 0
	while i < len(lines):
		raw = lines[i]
		stripped = raw.strip()
		if has_triple_quote(stripped):
			in_multiline_string = not in_multiline_string
			i += 1
			continue
		if in_multiline_string:
			i += 1
			continue
		if not is_top_level(raw):
			i += 1
			continue
		if stripped.startswith("##"):
			docs.append(stripped[2:].strip())
			i += 1
			continue
		if stripped.startswith("@") and not stripped.startswith("@export var "):
			decorators.append(stripped)
			i += 1
			continue
		if not stripped:
			i += 1
			continue

		if match := re.match(r"class_name\s+([A-Za-z_]\w*)", stripped):
			api_file.class_name = match.group(1)
			api_file.summary = docs[:]
			docs.clear()
			decorators.clear()
			i += 1
			continue
		if match := re.match(r"extends\s+(.+)", stripped):
			api_file.extends = match.group(1).strip()
			docs.clear()
			decorators.clear()
			i += 1
			continue
		if match := re.match(r"signal\s+([A-Za-z_]\w*)", stripped):
			api_file.signals.append(make_item("signal", match.group(1), stripped, i, docs, decorators))
			docs.clear()
			decorators.clear()
			i += 1
			continue
		if match := re.match(r"enum\s+([A-Za-z_]\w*)", stripped):
			signature, next_index = collect_block_signature(lines, i)
			api_file.enums.append(make_item("enum", match.group(1), signature, i, docs, decorators))
			docs.clear()
			decorators.clear()
			i = next_index
			continue
		if match := re.match(r"const\s+([A-Za-z_]\w*)", stripped):
			name = match.group(1)
			if not name.startswith("_"):
				api_file.constants.append(make_item("const", name, stripped, i, docs, decorators))
			docs.clear()
			decorators.clear()
			i += 1
			continue

		var_line = stripped
		if stripped.startswith("@export var "):
			decorators.append("@export")
			var_line = stripped.removeprefix("@export ").strip()
		if match := re.match(r"var\s+([A-Za-z_]\w*)", var_line):
			name = match.group(1)
			if not name.startswith("_"):
				api_file.variables.append(make_item("var", name, var_line, i, docs, decorators))
			docs.clear()
			decorators.clear()
			i += 1
			continue
		if stripped.startswith("func ") or stripped.startswith("static func "):
			signature, next_index = collect_function_signature(lines, i)
			name = parse_function_name(signature)
			if name and not name.startswith("_"):
				api_file.methods.append(make_item("func", name, signature, i, docs, decorators))
			docs.clear()
			decorators.clear()
			i = next_index
			continue

		docs.clear()
		decorators.clear()
		i += 1
	return api_file


def is_top_level(raw: str) -> bool:
	return raw == raw.lstrip(" \t")


def has_triple_quote(text: str) -> bool:
	return (text.count('"""') + text.count("'''")) % 2 == 1


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


def parenthesis_delta(text: str) -> int:
	return text.count("(") - text.count(")")


def brace_delta(text: str) -> int:
	return text.count("{") - text.count("}")


def parse_function_name(signature: str) -> str:
	match = re.search(r"(?:static\s+)?func\s+([A-Za-z_]\w*)", signature)
	return match.group(1) if match else ""


def make_item(
	kind: str,
	name: str,
	signature: str,
	line_index: int,
	docs: list[str],
	decorators: list[str],
) -> ApiItem:
	return ApiItem(
		kind=kind,
		name=name,
		signature=signature,
		line=line_index + 1,
		docs=docs[:],
		decorators=decorators[:],
	)


def get_module(relative: Path) -> str:
	parts = relative.parts
	if not parts:
		return "root"
	if parts[0] in {"extensions", "foundation"} and len(parts) > 1:
		return f"{parts[0]}/{parts[1]}"
	return parts[0]


def render_outputs(api_files: list[ApiFile], source_root: Path) -> dict[str, str]:
	files_payload = [api_file_to_dict(item) for item in api_files]
	source_digest = hashlib.sha256(
		json.dumps(files_payload, ensure_ascii=False, sort_keys=True).encode("utf-8")
	).hexdigest()
	payload = {
		"source_digest": source_digest,
		"source_root": source_root.relative_to(ROOT).as_posix(),
		"file_count": len(api_files),
		"class_count": sum(1 for item in api_files if item.class_name),
		"public_method_count": sum(len(item.methods) for item in api_files),
		"files": files_payload,
	}
	outputs = {
		"api.json": json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
		"index.md": render_index(api_files, payload),
	}
	for module in sorted({item.module for item in api_files}):
		module_files = [item for item in api_files if item.module == module]
		outputs[f"modules/{safe_file_name(module)}.md"] = render_module(module, module_files)
	return outputs


def api_file_to_dict(api_file: ApiFile) -> dict[str, Any]:
	return {
		"path": api_file.path,
		"module": api_file.module,
		"class_name": api_file.class_name,
		"extends": api_file.extends,
		"summary": api_file.summary,
		"signals": [api_item_to_dict(item) for item in api_file.signals],
		"enums": [api_item_to_dict(item) for item in api_file.enums],
		"constants": [api_item_to_dict(item) for item in api_file.constants],
		"variables": [api_item_to_dict(item) for item in api_file.variables],
		"methods": [api_item_to_dict(item) for item in api_file.methods],
	}


def api_item_to_dict(item: ApiItem) -> dict[str, Any]:
	return {
		"kind": item.kind,
		"name": item.name,
		"signature": item.signature,
		"line": item.line,
		"docs": item.docs,
		"decorators": item.decorators,
	}


def render_index(api_files: list[ApiFile], payload: dict[str, Any]) -> str:
	lines = [
		"# GF AI API Index",
		"",
		f"source_digest: {payload['source_digest']}",
		f"source_root: {payload['source_root']}",
		f"file_count: {payload['file_count']}",
		f"class_count: {payload['class_count']}",
		f"public_method_count: {payload['public_method_count']}",
		"",
		"## Modules",
		"",
	]
	for module in sorted({item.module for item in api_files}):
		module_files = [item for item in api_files if item.module == module]
		lines.append(f"- {module}: {len(module_files)} files -> modules/{safe_file_name(module)}.md")
	lines.extend(["", "## Classes", ""])
	for item in api_files:
		display_name = item.class_name or Path(item.path).name
		lines.append(f"- {display_name} | {item.extends} | {item.module} | {item.path}")
	return "\n".join(lines) + "\n"


def render_module(module: str, api_files: list[ApiFile]) -> str:
	lines = [f"# Module {module}", ""]
	for api_file in api_files:
		title = api_file.class_name or Path(api_file.path).name
		lines.extend([
			f"## {title}",
			f"path: {api_file.path}",
			f"extends: {api_file.extends}",
			f"summary: {' '.join(api_file.summary)}",
			"",
		])
		append_items(lines, "signals", api_file.signals)
		append_items(lines, "enums", api_file.enums)
		append_items(lines, "constants", api_file.constants)
		append_items(lines, "variables", api_file.variables)
		append_items(lines, "methods", api_file.methods)
	return "\n".join(lines) + "\n"


def append_items(lines: list[str], title: str, items: list[ApiItem]) -> None:
	lines.append(f"### {title}")
	if not items:
		lines.extend(["- none", ""])
		return
	for item in items:
		docs = " ".join(item.docs)
		decorators = " ".join(item.decorators)
		prefix = f"{decorators} " if decorators else ""
		lines.append(f"- line {item.line}: `{prefix}{item.signature}`")
		if docs:
			lines.append(f"  docs: {docs}")
	lines.append("")


def safe_file_name(module: str) -> str:
	return module.replace("/", "__").replace("\\", "__")


def write_outputs(output_dir: Path, desired: dict[str, str]) -> None:
	(output_dir / "modules").mkdir(parents=True, exist_ok=True)
	for old_file in (output_dir / "modules").glob("*.md"):
		old_file.unlink()
	for relative, content in desired.items():
		path = output_dir / relative
		path.parent.mkdir(parents=True, exist_ok=True)
		path.write_text(content, encoding="utf-8", newline="\n")


def check_outputs(output_dir: Path, desired: dict[str, str]) -> int:
	mismatches: list[str] = []
	for relative, content in desired.items():
		path = output_dir / relative
		if not path.exists():
			mismatches.append(f"missing: {relative}")
			continue
		if path.read_text(encoding="utf-8") != content:
			mismatches.append(f"stale: {relative}")
	existing = {
		path.relative_to(output_dir).as_posix()
		for path in output_dir.rglob("*")
		if path.is_file()
	}
	expected = set(desired.keys())
	for extra in sorted(existing - expected):
		mismatches.append(f"extra: {extra}")
	if mismatches:
		print("AI API docs are stale:")
		for mismatch in mismatches:
			print(f"- {mismatch}")
		return 1
	print("AI API docs are current.")
	return 0


def check_wiki_coverage(api_files: list[ApiFile], wiki_root: Path) -> int:
	if not wiki_root.exists():
		print(f"wiki root not found: {wiki_root}", file=sys.stderr)
		return 2

	doc_text_parts: list[str] = []
	for path in sorted(wiki_root.glob("*.md")):
		if is_changelog_page(path):
			continue
		doc_text_parts.append(path.read_text(encoding="utf-8"))
	doc_text = "\n".join(doc_text_parts)

	missing: list[ApiFile] = []
	checked_count = 0
	for api_file in api_files:
		if not api_file.class_name:
			continue
		checked_count += 1
		if api_file.class_name not in doc_text:
			missing.append(api_file)

	if missing:
		print("Wiki coverage is missing public class entries:")
		for api_file in missing:
			print(f"- {api_file.module} | {api_file.class_name} | {api_file.path}")
		return 1

	print(f"Wiki coverage is complete: {checked_count} public classes mentioned outside changelog.")
	return 0


def is_changelog_page(path: Path) -> bool:
	name = path.name.lower()
	return "changelog" in name or "更新日志" in name


if __name__ == "__main__":
	raise SystemExit(main())
