# GF Packages

GF packages are optional capability bundles that depend on the GF kernel and standard library.

Package roots:

- `official`: packages shipped with GF and maintained under the same release version.
- `community`: local or third-party packages that choose to follow the GF package layout.

Each package should provide a `gf_package.json` manifest. Runtime registration should still happen through `GFInstaller` or project-level installers, so package code stays explicit and testable.

Package roots should only contain metadata, optional installer entry points, and package docs. Runtime code belongs in stable slots such as `runtime`, `resources`, `nodes`, `editor`, `foundation`, or package-specific domains.

The GF editor plugin includes a `GF Packages` bottom panel. It writes `gf/packages/enabled`, can auto-run enabled package installers before project installers, and can exclude disabled packages during export when `gf/packages/export_exclude_disabled` is enabled.
