# GF Official Extensions

Official extensions ship with GF because Godot's Asset Library does not provide npm-style dependency installation. These extensions are still separated from the kernel and standard library so their boundaries stay clear.

Official extension code should remain abstract and reusable. Project-specific integrations belong in community extensions or game code.

Official extensions are atomic. They may depend only on `gf.kernel` and `gf.standard`; they should not declare optional dependencies or reference other official extensions by path, ID, dynamic loading, or `class_name`.

Official extension roots keep code out of the root directory. Use common slots (`runtime`, `resources`, `nodes`, `editor`, `actions`) or stable extension domains (`serializers`, `hit_detection`, `session`, `backends`) so users can understand the extension by looking at its tree.

When an official extension owns a lifecycle service, it declares a small `extension.gd` installer in `gf_extension.json`. Pure data, resources, actions, and node bridges stay opt-in and are not auto-registered just because the extension is enabled.
