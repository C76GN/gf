# Godot Asset Library Submission Notes

This file is maintainer-facing metadata for Godot Asset Library submissions. Godot does not read this file at runtime; keep it updated so future version bumps and AI-assisted release work can update the submission form consistently.

This repository is prepared for Godot Asset Library submission with a focused archive payload:

- `addons/gf/**`
- `README.md`
- `LICENSE.md`

Everything else is excluded from GitHub archive downloads through `.gitattributes`.

## Submission Form Values

- Asset Name: `GF Framework`
- Description:

```text
GF Framework is a lightweight architecture framework for Godot 4. It helps organize games into models, systems, controllers, utilities, and foundation helpers with managed lifecycles, typed events, bindable properties, commands and queries, installers, capability components, action queues, state machines, versioned storage/codecs, settings/audio/scene/remote-cache utilities, player-scoped input mapping, analytics transport hooks, grid occupancy helpers, and lightweight combat helpers.

Enable the plugin to register the Gf AutoLoad and use the editor tools for generating GF module templates and typed accessors.
```

- Category: `Tools`
- License: `Apache-2.0`
- Repository host: `GitHub`
- Repository URL: `https://github.com/C76GN/gf`
- Issues URL: `https://github.com/C76GN/gf/issues`
- Minimum Godot Version: `4.6`
- Asset Version: `1.20.1`
- Download Commit/URL: `TODO_AFTER_RELEASE_COMMIT`
- Icon URL: `https://raw.githubusercontent.com/C76GN/gf/TODO_AFTER_RELEASE_COMMIT/addons/gf/icon.png`

## Short Description

Lightweight Godot 4 game architecture framework for lifecycle management, events, data binding, utilities, and gameplay extensions.

## Preview Assets

No preview images are currently pinned. If previews are added, store their source URLs here and keep the Asset Library form synchronized:

- Preview 1 Type: `Image`
- Preview 1 Image/YouTube Link: `TODO`
- Preview 1 Thumbnail Link: `TODO`
- Preview 2 Type: `Image`
- Preview 2 Image/YouTube Link: `TODO`
- Preview 2 Thumbnail Link: `TODO`
- Preview 3 Type: `Image`
- Preview 3 Image/YouTube Link: `TODO`
- Preview 3 Thumbnail Link: `TODO`

## Before Submitting

1. Commit and push the Asset Library preparation changes.
2. Use the new full commit hash in the submission form.
3. Use the icon raw URL with that same commit hash.
4. Verify the generated archive only contains the installable plugin payload.
5. Run the GUT test suite on the target minimum Godot version.

## Version Bump Checklist

When the asset version changes, update these locations together:

1. `addons/gf/plugin.cfg`
2. `ASSET_LIBRARY.md`
3. `addons/gf/docs/wiki/更新日志 (Changelog).md`
4. The Godot Asset Library `Download Commit/URL` after the release commit is pushed.
5. The Godot Asset Library `Icon URL` so it uses the same release commit.
