# Configure

Runs instead of a walkthrough when the skill is invoked with "configure" (`/walkthrough configure`), or when the user asks to change walkthrough settings.

## Config file

`~/.config/walkthrough.json`. Configured settings always beat detection. All keys optional — a missing key falls back to detection:

```json
{
  "editor": "cursor",
  "tts": "on",
  "tts_tool": "openai_tts",
  "wpm": 150,
  "page": "on"
}
```

- `editor` — the launcher command to use for jumps (`code`, `cursor`, `windsurf`, `idea`, ...), or `"none"` to disable jumps.
- `tts` — `"on"` / `"off"`.
- `tts_tool` — exact tool name to narrate with when several exist (e.g. `openai_tts` over `say_tts`).
- `wpm` — narration pace.
- `page` — diagram page `"on"` / `"off"`.

## Flow

1. Show current settings if the file exists.
2. Editor: list detected launchers (`command -v code cursor windsurf idea webstorm pycharm goland rustrover clion`) plus "none", and ask which IDE they actually work in.
3. TTS: name any TTS tools found among available tools; ask on/off, which tool to use if there are several (save as `tts_tool`), and pace (default 150 wpm). If none found, say so and point at the recommendations in [channels.md](channels.md) — never install anything.
   - Upgrading voices: if the user has an OpenAI or ElevenLabs API key and uses blacktop/mcp-tts, re-registering the server with the key unlocks its cloud tools. Give them the command to run in their own terminal — never ask for the key in chat: `claude mcp remove --scope user tts && claude mcp add --scope user tts -e OPENAI_API_KEY=... -- "$HOME/go/bin/mcp-tts"` (same pattern with `ELEVENLABS_API_KEY`). Then set `tts_tool` accordingly.
4. Page: diagram page on/off.
5. Verify before saving — never save a selection you haven't checked:
   - `tts_tool` must be in the available tool list right now. If it isn't, say so and why it's likely missing (the MCP server is registered without the provider's API key, or the session hasn't restarted since re-registering — in Claude Code, `claude mcp get <server>` shows its environment). Offer to save it anyway as the preferred tool: walkthroughs fall back to the next best tool until it appears.
   - If the chosen tool exists, speak one short test sentence at the configured pace and ask if it sounded right.
   - Editor: launchers offered from `command -v` are already verified; if the user typed a different one, `command -v` it first.
6. Write the file (`mkdir -p ~/.config` first), show the saved JSON, done.

## Detection without config

When several editor launchers exist and there is no config:

- Env hints identify the IDE hosting this session, if the terminal is inside one: `$__CFBundleIdentifier` (macOS: `com.todesktop.*` → cursor, `com.microsoft.VSCode` → code, `*windsurf*` → windsurf, `com.jetbrains.*` → that IDE), `$VSCODE_GIT_ASKPASS_MAIN` path containing the app name, `$TERMINAL_EMULATOR` = `JetBrains-JediTerm` → JetBrains.
- In a plain terminal (iTerm, tmux) there are no hints. Pick the first hit, but say so in the kickoff: "jumping with `code` — run /walkthrough configure to change". Never block the start on this.
