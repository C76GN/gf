# GF Packages

GF packages are optional capability bundles that depend on the GF kernel and standard library.

Package roots:

- `official`: packages shipped with GF and maintained under the same GF release version.
- `community`: local or third-party packages that choose to follow the GF package layout.

Each package should provide a `gf_package.json` manifest. Package-level runtime services should register through manifest `installer_paths`; project-specific runtime registration should stay in project-level installers, so ownership remains explicit and testable.

Package-to-package dependencies are allowed only when they are explicit. Hard dependencies belong in manifest `dependencies`, are auto-enabled by `GFPackageSettings`, must form an acyclic graph, and are the only package relationships that allow direct references to another official package's public API. Optional collaboration belongs in `optional_dependencies`, extension points, project installers, or a dedicated bridge package; optional dependencies are metadata and do not permit hard references.

For official packages, manifest `version` must match the current GF release version, while `package_version` tracks that individual package's public behavior. Only packages whose own API, configuration, behavior, or compatibility contract changed should bump `package_version`.

Package roots should only contain metadata, optional installer entry points, and package docs. Runtime code belongs in stable slots such as `runtime`, `resources`, `nodes`, `editor`, `foundation`, or package-specific domains.

The GF editor plugin includes a `GF Packages` bottom panel. It writes `gf/packages/enabled`, can auto-run enabled package installers before project installers, can exclude disabled packages during export when `gf/packages/export_exclude_disabled` is enabled, and can report disabled-package references as export errors with `gf/packages/export_fail_on_disabled_references`.
