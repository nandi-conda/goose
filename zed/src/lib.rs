use zed_extension_api::{self as zed, settings::LspSettings, LanguageServerId, Result};

const SERVER_NAME: &str = "goose";

struct GooseExtension;

impl zed::Extension for GooseExtension {
    fn new() -> Self {
        GooseExtension
    }

    // `goose lsp`, with the compiler from the `lsp.goose.binary` setting or
    // else from PATH. The compiler is its own language server.
    fn language_server_command(
        &mut self,
        _language_server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<zed::Command> {
        let binary = LspSettings::for_worktree(SERVER_NAME, worktree)
            .ok()
            .and_then(|settings| settings.binary);
        let env = binary
            .as_ref()
            .and_then(|binary| binary.env.clone())
            .map(|env| env.into_iter().collect())
            .unwrap_or_else(|| worktree.shell_env());
        let path = binary
            .as_ref()
            .and_then(|binary| binary.path.clone())
            .or_else(|| worktree.which("goose"))
            .ok_or_else(|| {
                "goose not found on PATH: install the Goose compiler, or set \
                 lsp.goose.binary.path in Zed's settings"
                    .to_string()
            })?;
        let args = binary
            .and_then(|binary| binary.arguments)
            .unwrap_or_else(|| vec!["lsp".to_string()]);
        Ok(zed::Command {
            command: path,
            args,
            env,
        })
    }

    // `lsp.goose.initialization_options`, e.g. `{ "entryFiles": [...] }`.
    fn language_server_initialization_options(
        &mut self,
        _language_server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<Option<zed::serde_json::Value>> {
        Ok(LspSettings::for_worktree(SERVER_NAME, worktree)
            .ok()
            .and_then(|settings| settings.initialization_options))
    }

    fn language_server_workspace_configuration(
        &mut self,
        _language_server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<Option<zed::serde_json::Value>> {
        Ok(LspSettings::for_worktree(SERVER_NAME, worktree)
            .ok()
            .and_then(|settings| settings.settings))
    }
}

zed::register_extension!(GooseExtension);
