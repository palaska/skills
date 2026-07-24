# Companion page

A local web page that mirrors the walkthrough: one section per step with a diagram and a short explanation, prev/next navigation, and notes that accumulate on a step as the user asks questions. Code never goes on this page — code lives in the terminal snippet and the editor.

On by default when `python3` and `open`/`xdg-open` exist; "no page" turns it off.

## Setup (once per session)

```sh
D="${TMPDIR:-/tmp}/walkthrough-$(basename "$PWD")" && mkdir -p "$D"
cp <skill-dir>/app.html "$D/index.html"
# write $D/data.json first (see below), then:
cd "$D" && { python3 -m http.server 8765 >/dev/null 2>&1 & echo $! > server.pid; }
open "http://127.0.0.1:8765"        # xdg-open on Linux
```

If 8765 is taken, bump the port. Tell the user the URL. When the walkthrough ends, `kill $(cat "$D/server.pid")`.

The page polls `data.json` every 1.5s and re-renders only what changed — you never touch index.html again.

## data.json

The whole walkthrough state. Rewrite the entire file on every update:

```json
{
  "title": "How retry dispatch works",
  "current": 3,
  "steps": [
    {
      "title": "The retry gate",
      "explain": "One or two sentences on what this step shows.",
      "diagram": { "type": "mermaid", "src": "flowchart LR\n  W[worker] --> S[shouldRetry] --> Q[queue.push]" },
      "notes": []
    }
  ]
}
```

- `current` — the step the walkthrough is on (1-based). The page follows it unless the user navigated away; they can always browse back and forth.
- `steps[].diagram` — `type: "mermaid"` (preferred: flowchart/sequence, keep it small) or `type: "html"` (spans with the app's `.box`/`.arrow`/`.now` classes — the offline-safe fallback, since mermaid loads from a CDN). Omit when a diagram adds nothing.
- `steps[].notes` — detour answers. When the user asks a question on a step, append `{ "q": "their question, short", "explain": "the answer", "diagram": { ... } }` to that step's notes. Notes persist — the page becomes a record of what they asked.

## Per update

- New step: append to `steps`, set `current`, rewrite the file.
- Detour on step X: append a note to `steps[X-1].notes`, rewrite the file. Add a diagram to the note when a visual helps.
- The diagram that works hardest: the whole flow drawn once, repeated each step with the current node accented (mermaid `style` line or the `now` class).

## Rules

- One Write per update, whole file, valid JSON (the page skips malformed reads and retries, so a failed write self-heals on the next one).
- Keep mermaid sources small — under ~10 nodes. Split into per-step diagrams rather than one giant graph.
- The page needs the network once, for the mermaid CDN. If the user is offline, use `type: "html"` diagrams; everything else works.
