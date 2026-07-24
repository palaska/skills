# Configure

Runs instead of a walkthrough when the skill is invoked with "configure" (`/walkthrough configure`), or when the user asks to change walkthrough settings.

## Config file

`~/.config/walkthrough.json`. Configured settings always beat detection. All keys optional — a missing key falls back to detection:

```json
{
  "editor": "cursor",
  "tts": "on",
  "tts_tool": "openai_tts",
  "wpm": 150
}
```

- `editor` — the launcher command to use for jumps (`code`, `cursor`, `windsurf`, `idea`, ...), or `"none"` to disable jumps.
- `tts` — `"on"` / `"off"`.
- `tts_tool` — exact tool name to narrate with when several exist (e.g. `openai_tts` over `say_tts`).
- `wpm` — narration pace.

## Flow

1. Show current settings if the file exists.
2. Editor: list detected launchers (`command -v code cursor windsurf idea webstorm pycharm goland rustrover clion`) plus "none", and ask which IDE they actually work in.
3. TTS: unlike the silent session-start probe, configure **always lays out the full menu of options — including the paid ones — even when nothing is installed yet**, so the user can pick the voice they actually want and be walked through setting it up. Present these exact options, best-first, using these exact recommendation labels in the option titles (don't move the markers around, and never mark ElevenLabs, Kokoro, or macOS `say` as recommended):
   - **Off (recommended)** — no narration, just terminal text; no setup. A fine default and the fastest start.
   - **OpenAI TTS (recommended)** — best balance of natural voice, low latency, and cost. Needs an OpenAI API key.
   - **ElevenLabs** — highest voice quality; slightly more latency per step and pricier. Needs an ElevenLabs API key.
   - **Kokoro (local neural)** — offline, no key, no per-use cost; ~10s first-call warmup. Good if you'd rather not use a paid API.
   - **macOS native `say` (not recommended)** — robotic, but needs no key and no setup. Only a fallback if you want zero configuration.

   Both **Off** and **OpenAI TTS** carry "(recommended)"; **macOS `say`** carries "(not recommended)". Mark next to each whether a matching tool is available right now. Then ask which option they want and, if narration is on, the pace (default 150 wpm, save as `wpm`). Save the resolved tool name as `tts_tool`.
   - **If the chosen option isn't installed yet, give the exact install + configure steps for it** (see "Installing a TTS option" below). Commands are always for the user to run in their own terminal — never ask for an API key in chat.
4. Verify before saving — never save a selection you haven't checked:
   - `tts_tool` must be in the available tool list right now. If it isn't, say so and why it's likely missing (the MCP server is registered without the provider's API key, or the agent hasn't restarted since re-registering — inspect it with your host's command: Claude Code `claude mcp get <server>`, Codex `codex mcp list`, Gemini `gemini mcp list`). Offer to save it anyway as the preferred tool: walkthroughs fall back to the next best tool until it appears.
   - If the chosen tool exists, speak one short test sentence at the configured pace and ask if it sounded right.
   - Editor: launchers offered from `command -v` are already verified; if the user typed a different one, `command -v` it first.
5. Write the file (`mkdir -p ~/.config` first), show the saved JSON.
6. Show the tips below, then done.

## Installing a TTS option

Give only the steps for the option the user picked. All commands run in the user's own terminal, and the session must be restarted afterward for new tools to appear. Never ask for an API key in chat.

OpenAI, ElevenLabs, Google, and macOS `say` all run through the **same server, blacktop/mcp-tts** — you install the binary once, then register it with whichever API key(s) the chosen voice needs. Only Kokoro is a separate install. Getting the binary is the only step that needs a toolchain, and **you do not need Go**. The README documents two install methods — pick by what the user has:

- **Prebuilt binary — no Go, no toolchain (use this when `go` is missing, since installing Go just for this is annoying).** Download the archive for their OS/arch from https://github.com/blacktop/mcp-tts/releases/latest, unpack it, `chmod +x mcp-tts`, and move it onto their `PATH` (e.g. `mv mcp-tts /usr/local/bin/`). On macOS they may need to clear quarantine: `xattr -d com.apple.quarantine /usr/local/bin/mcp-tts`.
- **Go** — only if the user already has `go` (`command -v go`): `go install github.com/blacktop/mcp-tts@latest` (lands at `$HOME/go/bin/mcp-tts`).

The README lists no Homebrew or Docker install — don't invent one. If the user asks about a package manager, point them at the releases page above.

Once `mcp-tts` is on the `PATH`, register it **with the agent the user is actually running this walkthrough in — you know your own host, so give the matching command, not always the Claude one.** The server can hold several keys at once; include only the one(s) for the chosen voice. Registering exposes the tools `openai_tts`, `elevenlabs_tts`, `google_tts`, and (macOS only) `say_tts`. The examples below use `OPENAI_API_KEY`; swap the env var for the chosen voice (see "Per option"). The server name (`tts` here) is your choice — just keep it consistent, since removing it later uses the same name.

- **Claude Code:** `claude mcp add --scope user tts -e OPENAI_API_KEY=sk-... -- mcp-tts`
- **OpenAI Codex CLI:** `codex mcp add tts --env OPENAI_API_KEY=sk-... -- mcp-tts` (note `--env`, not `-e`)
- **Gemini CLI:** `gemini mcp add tts mcp-tts -e OPENAI_API_KEY=sk-...`
- **Claude Desktop / any other MCP client:** add a server to its `mcpServers` config (Claude Desktop: `~/Library/Application Support/Claude/claude_desktop_config.json`):
  ```json
  { "mcpServers": { "tts": { "command": "mcp-tts", "env": { "OPENAI_API_KEY": "sk-..." } } } }
  ```

If the binary isn't on the `PATH`, use its absolute path in place of `mcp-tts` (e.g. `"$HOME/go/bin/mcp-tts"`). Already registered without the key you need? Remove it (`claude mcp remove tts`, `codex mcp remove tts`, or edit the JSON) and add it again with the key.

Per option (all commands run in the user's own terminal; restart the agent afterward so the new tools appear; never ask for an API key in chat) — the only thing that changes per voice is the env var:

- **OpenAI TTS (recommended)** — `OPENAI_API_KEY=sk-...`. Set `tts_tool` to `openai_tts`.
- **ElevenLabs** — `ELEVENLABS_API_KEY=...` (add `ELEVENLABS_VOICE_ID=...` to pick a voice). Set `tts_tool` to `elevenlabs_tts`. (The standalone `uvx elevenlabs-mcp` server is an alternative if they prefer it — needs `uv`/`uvx` — but the blacktop path is simpler since the binary is already installed.)
- **Kokoro (local)** — a separate server, not blacktop/mcp-tts: install a Kokoro MCP such as scottschram/kokoro-tts-mcp and register it (in the same host, using the host's command above) per its README; no key, usually needs Python via `uv`/`uvx`. Set `tts_tool` to the tool it exposes.
- **macOS native `say`** — no key at all; register `mcp-tts` with no `env`/`-e` flags. Gives `say_tts` on macOS only. Set `tts_tool` to `say_tts`. Fine as a fallback, but expect a robotic voice.

## Tips

Print these after saving, so the user gets the most out of walkthroughs:

- **Use a fast, capable model.** A quick mid-tier model keeps the back-and-forth snappy and is plenty smart for walkthroughs — the pacing matters more than raw model power here, and a smoother rhythm makes the experience much better. On Claude that's roughly Sonnet 5 at medium effort; on another host, pick its equivalent quick model rather than the heaviest one.
- **Set up your screen so you can see both surfaces at once.** Arrange your windows so the IDE (where jumps land) and the agent conversation (the step text, diagrams, and narration) are visible side by side — a split layout or a second display. Walkthroughs drive both in sync, and reading the code while you hear the explanation is where it clicks.

## Detection without config

When several editor launchers exist and there is no config:

- Env hints identify the IDE hosting this session, if the terminal is inside one: `$__CFBundleIdentifier` (macOS: `com.todesktop.*` → cursor, `com.microsoft.VSCode` → code, `*windsurf*` → windsurf, `com.jetbrains.*` → that IDE), `$VSCODE_GIT_ASKPASS_MAIN` path containing the app name, `$TERMINAL_EMULATOR` = `JetBrains-JediTerm` → JetBrains.
- In a plain terminal (iTerm, tmux) there are no hints. Pick the first hit, but say so in the kickoff: "jumping with `code` — run /walkthrough configure to change". Never block the start on this.
