# GF Community Extensions

This directory is reserved for local or third-party extensions that follow the GF extension standard.

Community extensions should keep their own `gf_extension.json`, docs, tests, and optional `GFInstaller` entry. GF does not require community extensions to live here, but this path gives projects a predictable location when they want extensions to travel with the framework checkout.

Community extensions are disabled by default unless their manifest sets `enabled_by_default` to `true`. Users can enable them through the `GF Extensions` editor panel or by editing `gf/extensions/enabled`.
