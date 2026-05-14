# GF Core Tests

GUT tests mirror the framework source layers:

- `maintenance`: static checks for API comments, source layout, and generated-code conventions.
- `kernel`: core architecture, base contracts, editor helpers, and extension infrastructure.
- `standard`: foundation, input, utilities, sequence, command, and state-machine tests.
- `extensions`: tests for optional GF extensions, grouped by extension ID.
- `fixtures`: shared scenes, installers, and small scripts used by multiple tests.

Run all tests with:

```powershell
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/gf_core -ginclude_subdirs -gexit
```
