#!/usr/bin/env python3
"""Extract GF release notes from docs/zh/changelog.md for a SemVer tag."""

from __future__ import annotations

import argparse
import configparser
import json
import os
import re
import sys
from pathlib import Path


SEMVER_RE = re.compile(r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")
CHANGELOG_HEADING_RE = re.compile(r"^##\s+\[(?P<version>[^\]]+)\](?P<suffix>.*)$")
ASSET_FIELD_RE = re.compile(r"^-\s+(?P<name>Asset Version|Download Commit/URL):\s+`(?P<value>[^`]+)`\s*$")


def main() -> int:
	parser = argparse.ArgumentParser(
		description="Extract a version section from docs/zh/changelog.md and validate release metadata."
	)
	parser.add_argument("--tag", default=os.environ.get("GITHUB_REF_NAME", ""), help="Release tag, for example 3.5.0.")
	parser.add_argument("--changelog", default="docs/zh/changelog.md", help="Changelog path.")
	parser.add_argument("--output", required=True, help="Output release notes path.")
	parser.add_argument("--check-plugin", default="addons/gf/plugin.cfg", help="Godot plugin.cfg path.")
	parser.add_argument("--check-extensions", default="addons/gf/extensions", help="GF extensions root path.")
	parser.add_argument("--check-asset-library", default="ASSET_LIBRARY.md", help="Asset Library metadata path.")
	args = parser.parse_args()

	tag = normalize_tag(args.tag)
	plugin_version = read_plugin_version(Path(args.check_plugin))
	if plugin_version != tag:
		raise SystemExit(f"plugin.cfg version {plugin_version!r} does not match tag {tag!r}.")

	check_extension_versions(Path(args.check_extensions), tag)
	check_asset_library(Path(args.check_asset_library), tag)

	notes = extract_release_notes(Path(args.changelog), tag)
	output_path = Path(args.output)
	output_path.parent.mkdir(parents=True, exist_ok=True)
	output_path.write_text(notes + "\n", encoding="utf-8", newline="\n")
	return 0


def normalize_tag(raw_tag: str) -> str:
	tag = raw_tag.strip()
	if tag.startswith("refs/tags/"):
		tag = tag.removeprefix("refs/tags/")
	if not tag:
		raise SystemExit("Release tag is empty.")
	if tag.startswith(("v", "V")):
		raise SystemExit(f"Release tag {tag!r} must not use a leading v.")
	if SEMVER_RE.match(tag) is None:
		raise SystemExit(f"Release tag {tag!r} must use MAJOR.MINOR.PATCH, for example 3.5.0.")
	return tag


def read_plugin_version(path: Path) -> str:
	if not path.exists():
		raise SystemExit(f"plugin.cfg not found: {path}")
	config = configparser.ConfigParser()
	config.read(path, encoding="utf-8")
	if not config.has_section("plugin") or not config.has_option("plugin", "version"):
		raise SystemExit(f"plugin.cfg is missing [plugin] version: {path}")
	return strip_quotes(config.get("plugin", "version").strip())


def check_extension_versions(root: Path, version: str) -> None:
	if not root.exists():
		raise SystemExit(f"Extension root not found: {root}")
	mismatches: list[str] = []
	manifest_paths = sorted(root.glob("*/gf_extension.json"))
	if not manifest_paths:
		raise SystemExit(f"No extension manifests found under {root}.")
	for manifest_path in manifest_paths:
		data = json.loads(manifest_path.read_text(encoding="utf-8"))
		manifest_version = str(data.get("version", "")).strip()
		if manifest_version != version:
			mismatches.append(f"{manifest_path}: version {manifest_version!r}")
	if mismatches:
		raise SystemExit("Extension manifest versions do not match tag:\n" + "\n".join(mismatches))


def check_asset_library(path: Path, version: str) -> None:
	if not path.exists():
		raise SystemExit(f"Asset Library metadata not found: {path}")
	fields: dict[str, str] = {}
	for line in path.read_text(encoding="utf-8").splitlines():
		match = ASSET_FIELD_RE.match(line)
		if match:
			fields[match.group("name")] = match.group("value").strip()

	for field_name in ("Asset Version", "Download Commit/URL"):
		value = fields.get(field_name, "")
		if value != version:
			raise SystemExit(f"ASSET_LIBRARY.md {field_name} {value!r} does not match tag {version!r}.")


def extract_release_notes(path: Path, version: str) -> str:
	if not path.exists():
		raise SystemExit(f"Changelog not found: {path}")
	lines = path.read_text(encoding="utf-8").splitlines()
	start = -1
	end = len(lines)
	for index, line in enumerate(lines):
		match = CHANGELOG_HEADING_RE.match(line)
		if match is None:
			continue
		heading_version = match.group("version").strip()
		if start >= 0:
			end = index
			break
		if heading_version == version:
			start = index

	if start < 0:
		raise SystemExit(f"Changelog section for [{version}] was not found in {path}.")

	section = "\n".join(lines[start + 1:end]).strip()
	if not section:
		raise SystemExit(f"Changelog section for [{version}] is empty.")
	return section


def strip_quotes(value: str) -> str:
	if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", "\""}:
		return value[1:-1]
	return value


if __name__ == "__main__":
	sys.exit(main())
