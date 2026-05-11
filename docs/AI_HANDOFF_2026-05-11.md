# AI Handoff - GF 3.0.0 Temporary Branch

Date: 2026-05-11

Branch prepared for continuation work: `temp/gf-3.0.0-handoff-20260511`

## Continuation Goal

This document preserves the useful working context from the recent AI/user development session so another environment can continue without rediscovering the project state.

The user is preparing GF Framework 3.0.0 and wants the framework to prefer clear structure, precise naming, modular boundaries, and best practices over old compatibility debt.

Important standing instructions from the user:

- Follow `AI_MAINTENANCE.md`.
- Use UTF-8 for reading and writing files.
- Do not clean or delete `.gd.uid` files.
- Do not mention external comparison topics in public-facing docs.
- 3.0.0 is not officially released yet, so breaking cleanup is allowed when it improves the framework.
- The framework must stay abstract, generic, flexible, and avoid hardcoding project business logic.

## Major User Decisions

The user accepted the full optimization direction across several batches:

- Make `GFStateMachine.start()` emit the initial state change signal by default, with an explicit opt-out parameter.
- Treat this work as the 3.0.0 release line.
- Prefer a top-level source structure based on:
  - `kernel`
  - `standard`
  - `packages/official`
  - `packages/community`
- Avoid overly fine-grained top-level categories; keep top-level architecture stable and let package internals use stable slots.
- Move framework-critical, always-needed code into `kernel` or `standard`; keep optional broad features as official packages.
- Keep official packages generic and optional. If an official package becomes impossible to remove, that is a signal it may belong in `standard`.
- Add an editor package manager for viewing, enabling, disabling, and understanding packages.
- Make disabled packages excludable during export, but add warnings when project files still use them.

## Current Architecture Direction

The intended 3.0.0 structure is:

```text
addons/gf/
  kernel/
  standard/
  packages/
    official/
    community/
```

`kernel` contains the architecture runtime, base contracts, dependency injection, event system, package infrastructure, autoload, and editor integration required for GF to function.

`standard` contains stable general-purpose framework capabilities such as foundation data/algorithm tools, input, utilities, state machines, command/sequence support, and common helpers.

`packages/official` contains optional official packages that ship with GF but should not be required by the framework body. Official packages currently include action queue, behavior tree, capability, combat, domain, feedback, flow, interaction, network, physics, save, and turn based.

`packages/community` is the convention point for user/community packages.

## Package Boundary Rules

The latest decision is:

- `kernel` and `standard` are not optional packages.
- Official packages are optional by default.
- Official package manifests should only depend on `gf.kernel` and `gf.standard`.
- Official packages should not hard depend on each other through manifest dependencies.
- Cross-package integration should use protocols, dynamic detection, or user/project registration.
- If a feature is so universal that GF feels broken without it, move it into `standard` instead of making it a non-removable package.

This avoids the half-state where something is called a package but cannot actually be disabled or removed.

## Recent Important Changes

Package management:

- Added `GFPackageManifest`, `GFPackageCatalog`, and `GFPackageSettings`.
- Added `gf_package.json` files for official packages.
- Added the `GF Packages` bottom panel.
- Added package settings:
  - `gf/packages/enabled`
  - `gf/packages/auto_install_enabled_installers`
  - `gf/packages/export_exclude_disabled`
- Added `GFPackageExportPlugin` to skip disabled package roots during export.
- Added `GFPackageUsageAudit` to scan disabled package usage risks.

Package UI improvements:

- Replaced unclear `OK` status text with `有效` / `无效`.
- Renamed save action to `保存设置`.
- Added category filtering, search, restore defaults, enable all, disable all, and reference scanning.
- Details panel now wraps text and shows package usage risk for disabled packages.

Disabled package risk detection:

- Package panel has `扫描引用`.
- Saving package settings refreshes usage warnings.
- Export start scans disabled package references and emits warnings.
- Audit detects:
  - Direct root path usage such as `preload("res://addons/gf/packages/official/save/...")`.
  - Direct `class_name` usage from disabled package scripts, such as `GFSaveGraphUtility`.

Package optionality hardening:

- `kernel` / `standard` no longer hard `preload()` official package scripts.
- Capability inspector, flow inspector, and access generator now dynamically detect optional package scripts.
- Official package manifests no longer declare dependencies on other official packages.

Action queue:

- Added `GFActionProtocol`.
- `GFActionQueueSystem`, `GFVisualActionGroup`, `GFRepeatAction`, `GFActionInterceptor`, and `GFActionInterceptionResult` now accept protocol-compatible `Object` actions.
- `GFVisualAction` remains the recommended base class; the queue is no longer inheritance-only.
- `GFShakeAction` no longer extends `GFVisualAction`, so feedback does not hard depend on action queue.

Interaction:

- `GFInteractionContext` dynamically loads capability utility when available.
- If capability package is missing, capability queries safely return null or empty arrays.

Documentation:

- Added package structure page: `docs/wiki/13. 包结构与生态 (Packages).md`.
- Updated README and addon README with package manager behavior and disabled package warnings.
- Updated changelog to keep only 3.0.0 content.
- Renamed Wiki sidebar/home grouping from the old wording to `实践与维护`.

Testing and maintenance:

- Tests are now layered under:
  - `tests/gf_core/maintenance`
  - `tests/gf_core/kernel`
  - `tests/gf_core/standard`
  - `tests/gf_core/packages/official`
- Added package boundary tests:
  - Official manifests should not depend on other official packages.
  - `kernel` and `standard` should not hard preload official package scripts.
  - Export root matching works.
  - Usage audit detects path and `class_name` references.

## Resolved Test Failures During Session

Fixed API doc parameter failures in:

- `gf_type_event_system.gd`
- editor plugin helper scripts

Fixed GDScript layout failures:

- `_export_file` accepted as an editor export callback.
- Section order corrected in:
  - `gf_action_queue_system.gd`
  - `gf_visual_action_group.gd`
  - `gf_repeat_action.gd`
  - `gf_shake_action.gd`

Fixed tick cache behavior:

- Systems that do not override `tick()` / `physics_tick()` stay out of tick caches.
- Explicit tick opt-in can refresh the cache.

## Validation Already Run

The latest validations completed successfully before this handoff commit:

```powershell
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/gf_core -ginclude_subdirs -gexit
python tools\generate_ai_api.py --source addons\gf --output ai_analysis\generated_api --check --check-wiki-coverage
git diff --check
```

Observed status:

- Full GUT suite passed.
- Maintenance tests passed.
- AI API docs are current.
- Wiki coverage is complete.
- Diff whitespace check passed.

## Key User Concern To Preserve

The user is worried that making packages optional could weaken the framework. The agreed answer is:

- Optionality should not weaken core capabilities.
- Core protocols, lifecycle, architecture, and broadly necessary services belong in `kernel` or `standard`.
- Official packages can be optional only if the framework still makes sense without them.
- If a package becomes too fundamental to disable, promote the generic parts into `standard` rather than keeping it as a fake optional package.

The action queue protocol change was framed as not weakening the queue: `GFVisualAction` still exists and remains recommended; support was widened to protocol-compatible objects to avoid unnecessary cross-package inheritance locks.

## Files/Areas Worth Checking Next

Likely next work areas:

- Review whether any current official package contains pieces that are universal enough to move into `standard`.
- Continue tightening package usage audit if Godot binary resources or imported resources need deeper detection later.
- Review package manager UX inside the actual Godot editor after opening the panel.
- Confirm whether `GFActionProtocol` should be public with `class_name` or remain package-internal.
- Continue checking docs after structural changes, especially pages that mention old paths or old class names.

## Reminder For Next AI

- Do not delete `.gd.uid` files.
- Use `apply_patch` for manual edits.
- Keep package APIs generic and project-agnostic.
- Prefer focused tests for behavior changes.
- Before final handoff, rerun:

```powershell
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/gf_core -ginclude_subdirs -gexit
python tools\generate_ai_api.py --source addons\gf --output ai_analysis\generated_api --check --check-wiki-coverage
git diff --check
```
