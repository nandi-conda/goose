# Goose for Zed

A [Zed](https://zed.dev) extension for Goose:

- Syntax highlighting, bracket matching, indentation, the outline panel and
  text objects, from the tree-sitter grammar in [`../tree-sitter`](../tree-sitter/README.md).
- The language server the compiler carries (`goose lsp`): diagnostics,
  hover, go to definition, references, rename, symbols, completion,
  signature help, inlay hints and semantic highlighting.

## Install

Until it is in Zed's extension registry, install it as a dev extension: in
Zed, run **zed: install dev extension** and pick this `zed/` directory. Zed
builds it with Rust, so Rust must be installed through rustup;
`rust-toolchain.toml` has rustup use its stable toolchain with the
`wasm32-wasip2` target here, which rustup installs on first use, even where
the default toolchain is a distro's Rust.

The language server is the compiler, so `goose` must be on `PATH`. Where it
is not, or to pass the server options, use Zed's `settings.json`:

```json
{
  "lsp": {
    "goose": {
      "binary": {
        "path": "/path/to/goose",
        "arguments": ["lsp", "--stdlib", "/path/to/goose/stdlib"]
      },
      "initialization_options": {
        "entryFiles": ["/path/to/project/main.goose"]
      }
    }
  }
}
```

`arguments` defaults to `["lsp"]`. The server finds the standard library
from `GOOSE_STDLIB` or the `stdlib/` directory near the compiler; add
`--stdlib` where neither works. `entryFiles` has a module checked as part of
the program that imports it (see [editors.md](../docs/editors.md)).

## Layout

| Path | |
|---|---|
| `extension.toml` | The extension's manifest; it names the grammar by commit. |
| `src/lib.rs` | Starts `goose lsp` (compiled to WebAssembly by Zed). |
| `languages/goose/config.toml` | File type, comments, brackets. |
| `languages/goose/*.scm` | Zed's queries over the tree-sitter grammar. |

`highlights.scm` is `tree-sitter/queries/highlights.scm` with the capture
names Zed's themes use (`@namespace`, `@variable.special`, one `@keyword`
for every kind of keyword, and so on); a change to one belongs in the other.

## When the grammar changes

Zed fetches the grammar from git and builds `tree-sitter/src/parser.c`,
which is why the generated parser is checked in. After a change to
`tree-sitter/grammar.js`:

1. Run `python tree-sitter/build.py --check` and commit the regenerated
   `tree-sitter/src/`.
2. Set `rev` under `[grammars.goose]` in `extension.toml` to that commit,
   and commit that.
3. Check the queries here still compile:
   `cd tree-sitter && npx tree-sitter query ../zed/languages/goose/highlights.scm ../samples/01_tour.goose`
   (and the other `.scm` files).

CI does steps 1 and 3 and fails when the checked-in parser is stale.
