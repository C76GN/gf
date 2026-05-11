# GF Core Tests

GUT tests mirror the framework source layers:

- `maintenance`: static checks for API comments, source layout, and generated-code conventions.
- `kernel`: core architecture, base contracts, editor helpers, and package infrastructure.
- `standard`: foundation, input, utilities, sequence, command, and state-machine tests.
- `packages/official`: tests for optional official packages, grouped by package ID.
- `fixtures`: shared scenes, installers, and small scripts used by multiple tests.

Run all tests with:

```powershell
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/gf_core -ginclude_subdirs -gexit
```
