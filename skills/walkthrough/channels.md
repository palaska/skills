# Optional channels

Both channels are detected in the session-start probe. If a channel wasn't detected, it doesn't exist: never mention it, never suggest installing anything.

## Editor jump

The editor is the primary code surface when a launcher was detected: every step, open the user's editor at the code being discussed so they read the real file. On by default; "no jumps" turns it off. An `editor` set in `~/.config/walkthrough.json` always wins over detection — see [configure.md](configure.md).

- VS Code family: `code --goto <file>:<line>` (same flag for `cursor` and `windsurf`).
- JetBrains: `idea --line <line> <file>` (same for `webstorm`, `pycharm`, `goland`, `rustrover`, `clion`).

Jump to the first marked line of the current step's snippet. Skip the jump when the step stays at the same spot as the previous one. Launchers can only place the cursor, not select a range — the `›` markers in the terminal snippet still show the exact lines.

## Audio narration

If a TTS tool was found (`speak`, `say_tts`, `text_to_speech`, `tts`, `converse`, `play_audio`):

- Several tools? A configured `tts_tool` (see [configure.md](configure.md)) wins; if it's missing from the available tools, fall back silently. With no config, prefer quality: `elevenlabs_tts`, then `openai_tts`, then generic `speak`/`text_to_speech`, then `say_tts` last.

- On by default; "quiet" or "stop talking" turns it off for the rest of the session.
- Narrate the step's full explanation — the same sentences you write in the terminal, adapted for speech. Saying function names aloud is fine; reading code lines, file paths, or syntax is not.
- Pace: if the tool takes a rate, speed, or wpm option, use the configured `wpm` (see [configure.md](configure.md)), defaulting to a calm ~150 wpm (rate/speed ≈ 0.9). Fast defaults are hard to follow while reading code.
- Call the tool and move on. Never block on playback. If the tool takes a `background` or async option, use it.
- Narrate detour answers exactly like steps — a spoken conversation that goes silent when the user asks something is broken.
- Any tool error = stop using it silently. Don't retry, don't report.

## Recommended TTS servers (for humans)

The skill never installs these. If you want narration, add one and restart your session:

- **blacktop/mcp-tts** — best fit for narration: plays through speakers, queues utterances so they never overlap, and its `say_tts` tool needs no API key on macOS. `go install github.com/blacktop/mcp-tts@latest`, then register it with your agent.
- **VoiceMode** (getvoicemode.com) — two-way voice, so you can talk back. `claude plugin install voicemode@voicemode`. OpenAI key, or fully local via Kokoro + whisper.cpp.
- **Kokoro local MCPs** (e.g. scottschram/kokoro-tts-mcp) — offline neural voices, no keys, ~10s first-call warmup then near-instant.
- **ElevenLabs official** (elevenlabs-mcp) — best voice quality. `uvx elevenlabs-mcp` with `ELEVENLABS_API_KEY`. Its file-then-play flow adds a little latency per step.
