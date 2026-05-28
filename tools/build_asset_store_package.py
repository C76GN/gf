#!/usr/bin/env python3
"""Build the GF Asset Store package with addons/gf at the zip root."""

from __future__ import annotations

import argparse
import configparser
import json
import sys
import zipfile
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
ADDON_ROOT = ROOT / "addons/gf"
BLOCKED_DIR_NAMES = {".git", ".godot", ".import", ".vs", "__pycache__", "node_modules"}
BLOCKED_FILE_NAMES = {".DS_Store", "Thumbs.db"}
BLOCKED_SUFFIXES = {".import", ".pyc", ".pyo", ".tmp", ".log"}
REQUIRED_PACKAGE_PATHS = (
	"addons/gf/plugin.cfg",
	"addons/gf/plugin.gd",
	"addons/gf/README.md",
	"addons/gf/LICENSE.md",
	"addons/gf/icon.png",
)
ZIP_TIMESTAMP = (1980, 1, 1, 0, 0, 0)


def main() -> int:
	configure_stdio()
	parser = argparse.ArgumentParser(description="Build the GF Asset Store addon zip.")
	parser.add_argument("--version", default="", help="Expected package version. Defaults to addons/gf/plugin.cfg.")
	parser.add_argument("--output", default="", help="Output zip path. Defaults to build/gf-framework-<version>.zip.")
	parser.add_argument("--validate-only", action="store_true", help="Validate an existing --output zip without rebuilding it.")
	parser.add_argument("--json", action="store_true", help="Print JSON instead of text.")
	args = parser.parse_args()

	plugin_version = read_plugin_version()
	version = args.version.strip() or plugin_version
	if version != plugin_version:
		result = {
			"ok": False,
			"version": version,
			"plugin_version": plugin_version,
			"output": "",
			"issues": [f"Requested version {version!r} does not match addons/gf/plugin.cfg version {plugin_version!r}."],
		}
		print_result(result, args.json)
		return 1

	output = resolve_output_path(args.output, version)
	if not args.validate_only:
		build_package(output)

	result = audit_package(output)
	result["version"] = version
	result["plugin_version"] = plugin_version
	print_result(result, args.json)
	return 0 if result["ok"] else 1


def configure_stdio() -> None:
	for stream in (sys.stdin, sys.stdout, sys.stderr):
		if hasattr(stream, "reconfigure"):
			stream.reconfigure(encoding="utf-8", errors="replace")


def read_plugin_version() -> str:
	config = configparser.ConfigParser()
	config.read(ROOT / "addons/gf/plugin.cfg", encoding="utf-8")
	if not config.has_section("plugin"):
		return ""
	value = config.get("plugin", "version", fallback="").strip()
	if len(value) >= 2 and value[0] == '"' and value[-1] == '"':
		return value[1:-1]
	return value


def resolve_output_path(output: str, version: str) -> Path:
	path = Path(output) if output else Path("build") / f"gf-framework-{version}.zip"
	if not path.is_absolute():
		path = ROOT / path
	return path


def build_package(output: Path) -> None:
	output.parent.mkdir(parents=True, exist_ok=True)
	if output.exists():
		output.unlink()
	with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
		for path in iter_package_files():
			write_file(archive, path)


def iter_package_files() -> list[Path]:
	files: list[Path] = []
	for path in ADDON_ROOT.rglob("*"):
		if not path.is_file():
			continue
		if is_blocked_path(path):
			continue
		files.append(path)
	return sorted(files, key=lambda item: item.relative_to(ROOT).as_posix())


def is_blocked_path(path: Path) -> bool:
	relative_parts = path.relative_to(ROOT).parts
	if any(part in BLOCKED_DIR_NAMES for part in relative_parts):
		return True
	if path.name in BLOCKED_FILE_NAMES:
		return True
	return path.suffix in BLOCKED_SUFFIXES


def write_file(archive: zipfile.ZipFile, path: Path) -> None:
	archive_path = path.relative_to(ROOT).as_posix()
	info = zipfile.ZipInfo(archive_path, ZIP_TIMESTAMP)
	info.compress_type = zipfile.ZIP_DEFLATED
	info.external_attr = 0o644 << 16
	archive.writestr(info, path.read_bytes())


def audit_package(output: Path) -> dict[str, Any]:
	issues: list[str] = []
	if not output.is_file():
		return {
			"ok": False,
			"output": output.as_posix(),
			"file_count": 0,
			"size_bytes": 0,
			"top_level_entries": [],
			"issues": [f"Package zip was not found: {output.as_posix()}"],
		}

	with zipfile.ZipFile(output, "r") as archive:
		names = sorted(name for name in archive.namelist() if name and not name.endswith("/"))

	top_level_entries = sorted({name.split("/", 1)[0] for name in names})
	if top_level_entries != ["addons"]:
		issues.append("Package root must contain only addons/, without a repository or version wrapper directory.")

	for name in names:
		if not name.startswith("addons/gf/"):
			issues.append(f"Package entry is outside addons/gf: {name}")
		parts = name.split("/")
		if any(part in BLOCKED_DIR_NAMES for part in parts):
			issues.append(f"Package entry contains blocked directory: {name}")
		if Path(name).name in BLOCKED_FILE_NAMES or Path(name).suffix in BLOCKED_SUFFIXES:
			issues.append(f"Package entry contains blocked generated file: {name}")

	for required_path in REQUIRED_PACKAGE_PATHS:
		if required_path not in names:
			issues.append(f"Package is missing required file: {required_path}")

	return {
		"ok": len(issues) == 0,
		"output": output.relative_to(ROOT).as_posix() if output.is_relative_to(ROOT) else output.as_posix(),
		"file_count": len(names),
		"size_bytes": output.stat().st_size,
		"top_level_entries": top_level_entries,
		"issues": issues,
	}


def print_result(result: dict[str, Any], as_json: bool) -> None:
	if as_json:
		print(json.dumps(result, ensure_ascii=False, indent=2))
		return
	print(f"ok={result['ok']} version={result.get('version', '')} output={result.get('output', '')}")
	print(f"files={result.get('file_count', 0)} size={result.get('size_bytes', 0)} top={result.get('top_level_entries', [])}")
	if result.get("issues"):
		print("issues:")
		for issue in result["issues"]:
			print(f"- {issue}")


if __name__ == "__main__":
	raise SystemExit(main())
