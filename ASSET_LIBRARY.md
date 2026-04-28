# Godot Asset Library Submission Notes

This repository is prepared for Godot Asset Library submission with a focused archive payload:

- `addons/gf/**`
- `README.md`
- `LICENSE.md`

Everything else is excluded from GitHub archive downloads through `.gitattributes`.

## Suggested Form Values

- Asset Name: `GF Framework`
- Category: `Tools`
- License: `Apache-2.0`
- Minimum Godot Version: `4.6`
- Asset Version: `1.14.3`
- Repository URL: `https://github.com/C76GN/gf`
- Issues URL: `https://github.com/C76GN/gf/issues`
- Download Commit: use the full commit hash after these Asset Library preparation changes are committed and pushed.
- Icon URL: `https://raw.githubusercontent.com/C76GN/gf/<commit>/addons/gf/icon.png`

## Short Description

Lightweight Godot 4 game architecture framework for lifecycle management, events, data binding, utilities, and gameplay extensions.

## Before Submitting

1. Commit and push the Asset Library preparation changes.
2. Use the new full commit hash in the submission form.
3. Use the icon raw URL with that same commit hash.
4. Verify the generated archive only contains the installable plugin payload.
5. Run the GUT test suite on the target minimum Godot version.
