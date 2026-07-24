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
   - `tts_tool` must be in the available tool list right now. If it isn't, say so and why it's likely missing (the MCP server is registered without the provider's API key, or the session hasn't restarted since re-registering — in Claude Code, `claude mcp get <server>` shows its environment). Offer to save it anyway as the preferred tool: walkthroughs fall back to the next best tool until it appears.
   - If the chosen tool exists, speak one short test sentence at the configured pace and ask if it sounded right.
   - Editor: launchers offered from `command -v` are already verified; if the user typed a different one, `command -v` it first.
5. Write the file (`mkdir -p ~/.config` first), show the saved JSON.
6. Show the tips below, then done.

## Installing a TTS option

Give only the steps for the option the user picked. All commands run in the user's own terminal, and the session must be restarted afterward for new tools to appear. Never ask for an API key in chat.

**Check prerequisites before recommending any install path — never hand over a command whose toolchain isn't present.** One shell call up front: `command -v go uvx uv brew`. Then:

- The blacktop/mcp-tts path needs `go`. If `go` is missing, don't print the `go install` line as-is — first give the user how to get the toolchain: `brew install go` when `brew` exists, otherwise point at https://go.dev/dl. As an alternative that skips Go entirely, point them at the prebuilt binaries on https://github.com/blacktop/mcp-tts/releases (download, `chmod +x`, and use that path in the `claude mcp add` line instead of `$HOME/go/bin/mcp-tts`).
- The ElevenLabs official server needs `uvx` (from `uv`). If neither `uvx` nor `uv` is present, give the install first: `brew install uv` when `brew` exists, otherwise https://docs.astral.sh/uv/getting-started/installation.
- Only after the required toolchain is confirmed (or you've told them how to get it) do you print the install + `claude mcp add` commands below. Adapt the binary path to wherever their toolchain actually installs it.

Per option:

- **OpenAI TTS (recommended)** — via blacktop/mcp-tts (needs `go` or a prebuilt binary — see above), which exposes an `openai_tts` tool when registered with a key:
  ```
  go install github.com/blacktop/mcp-tts@latest
  claude mcp add --scope user tts -e OPENAI_API_KEY=sk-... -- "$HOME/go/bin/mcp-tts"
  ```
  Already have the server registered without a key? Re-register it: `claude mcp remove --scope user tts` then the `add` line above. Then set `tts_tool` to `openai_tts`.
- **ElevenLabs** — either the official server (needs `uvx` — see above): `uvx elevenlabs-mcp` with `ELEVENLABS_API_KEY`, exposes `text_to_speech`; or the same blacktop `add` line with `-e ELEVENLABS_API_KEY=...` (exposes `elevenlabs_tts`). Set `tts_tool` to match.
- **Kokoro (local)** — install a Kokoro MCP such as scottschram/kokoro-tts-mcp and register it per its README; no key. Check its prerequisites (usually Python via `uv`/`uvx`) the same way. Set `tts_tool` to the tool it exposes.
- **macOS native `say`** — blacktop/mcp-tts with no key (needs `go` or a prebuilt binary — see above) gives a `say_tts` tool on macOS:
  ```
  go install github.com/blacktop/mcp-tts@latest
  claude mcp add --scope user tts -- "$HOME/go/bin/mcp-tts"
  ```
  Set `tts_tool` to `say_tts`. Fine as a fallback, but expect a robotic voice.

## Tips

Print these after saving, so the user gets the most out of walkthroughs:

- **Use a fast, capable model.** A quick model like Sonnet 5 at medium effort keeps the back-and-forth snappy and is plenty smart for walkthroughs — the pacing matters more than raw model power here, and a smoother rhythm makes the experience much better.
- **Set up your screen so you can see both surfaces at once.** Arrange your windows so the IDE (where jumps land) and the agent conversation (the step text, diagrams, and narration) are visible side by side — a split layout or a second display. Walkthroughs drive both in sync, and reading the code while you hear the explanation is where it clicks.

## Detection without config

When several editor launchers exist and there is no config:

- Env hints identify the IDE hosting this session, if the terminal is inside one: `$__CFBundleIdentifier` (macOS: `com.todesktop.*` → cursor, `com.microsoft.VSCode` → code, `*windsurf*` → windsurf, `com.jetbrains.*` → that IDE), `$VSCODE_GIT_ASKPASS_MAIN` path containing the app name, `$TERMINAL_EMULATOR` = `JetBrains-JediTerm` → JetBrains.
- In a plain terminal (iTerm, tmux) there are no hints. Pick the first hit, but say so in the kickoff: "jumping with `code` — run /walkthrough configure to change". Never block the start on this.
