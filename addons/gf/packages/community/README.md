# GF Community Packages

This directory is reserved for local or third-party packages that follow the GF package standard.

Community packages should keep their own `gf_package.json`, docs, tests, and optional `GFInstaller` entry. GF does not require community packages to live here, but this path gives projects a predictable location when they want packages to travel with the framework checkout.

Community packages are disabled by default unless their manifest sets `enabled_by_default` to `true`. Users can enable them through the `GF Packages` editor panel or by editing `gf/packages/enabled`.
