# GF Extensions

GF extensions are optional capability bundles built on the GF kernel and standard library.

Extension roots:

- `official`: atomic extensions shipped with GF and maintained under the same GF release version.
- `community`: local or third-party extensions that choose to follow the GF extension layout and may compose official extensions.

Each extension should provide a `gf_extension.json` manifest. Extension-level runtime services should register through manifest `installer_paths`; project-specific runtime registration should stay in project-level installers, so ownership remains explicit and testable.

Official extensions are atomic: they may depend only on `gf.kernel` and `gf.standard`, and they must not declare or probe other official extensions through hard dependencies, optional dependencies, paths, IDs, dynamic loading, or extension class names. Cross-extension composition belongs in project installers, community extensions, or external plugins.

Community extensions may use manifest `dependencies` and `optional_dependencies` to describe their own composition rules. Hard dependencies are auto-enabled by `GFExtensionSettings` and must form an acyclic graph; optional dependencies are metadata and do not permit hard references by themselves.

For official extensions, manifest `version` must match the current GF release version, while `extension_version` tracks that individual extension's public behavior. Only extensions whose own API, configuration, behavior, or compatibility contract changed should bump `extension_version`.

Extension roots should only contain metadata, optional installer entry points, and extension docs. Runtime code belongs in stable slots such as `runtime`, `resources`, `nodes`, `editor`, `foundation`, or extension-specific domains.

The GF editor plugin includes a `GF` bottom workspace with a `GF Extensions` page. It writes `gf/extensions/enabled`, can auto-run enabled extension installers before project installers, can exclude disabled extensions during export when `gf/extensions/export_exclude_disabled` is enabled, and can report disabled-extension references as export errors with `gf/extensions/export_fail_on_disabled_references`.
