# GF Official Packages

Official packages ship with GF because Godot's Asset Library does not provide npm-style dependency installation. These packages are still separated from the kernel and standard library so their boundaries stay clear.

Official package code should remain abstract and reusable. Project-specific integrations belong in community packages or game code.

Official package roots keep code out of the root directory. Use common slots (`runtime`, `resources`, `nodes`, `editor`, `actions`) or stable package domains (`serializers`, `hit_detection`, `session`, `backends`) so users can understand the package by looking at its tree.

When an official package owns a lifecycle service, it declares a small `package.gd` installer in `gf_package.json`. Pure data, resources, actions, and node bridges stay opt-in and are not auto-registered just because the package is enabled.
