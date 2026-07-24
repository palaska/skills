---
name: walkthrough
description: Interactive code explainer that walks the user through existing code, a code change or PR, codebase structure, or a concept one step at a time, in plain language with highlighted code and simple diagrams — with editor jumps, a live local diagram page, and voice narration when available. Use when the user asks "how does X work" about the current codebase, wants to learn or understand a feature, module, or flow in existing code, asks to "explain this PR", "understand PR #123", "trace this change", "walk me through this diff", "help me review this branch", "give me a tour of this codebase", or wants a concept explained step by step.
---

# Walkthrough

Walk the user through code one step at a time. Never dump the whole explanation at once. The user controls the pace.

## Modes

Pick the one that matches the request. Modes can nest — a change-trace step can embed a mini concept explanation.

1. **Trace a flow** — how something works in existing code ("how does login work?"). No diff involved.
2. **Trace a change or PR** — review a diff, branch, or pull request as a traced journey.
3. **Orient** — top-down tour of an unfamiliar codebase.
4. **Explain a concept** — a pattern, language feature, or algorithm, grounded in this repo's code.

Read [modes.md](modes.md) for your mode before planning steps.

## Session start

1. Determine mode and scope (scope rules are in modes.md).
2. Read the code first — enough surrounding code to actually understand the flow, not just the diff. Explaining changes in isolation misses the point.
3. Plan the full numbered step list up front, entry point → result.
4. Probe capabilities — one pass, silent, never install anything:
   - One shell call: `cat ~/.config/walkthrough.json 2>/dev/null; command -v code cursor windsurf idea open xdg-open python3`. Configured settings always beat detection.
   - Several editor launchers and nothing configured? See "Detection without config" in [configure.md](configure.md).
   - Glance at your available tools for a TTS-ish name: `speak`, `say_tts`, `text_to_speech`, `tts`, `converse`, `play_audio`. In Claude Code, one ToolSearch query; otherwise scan the tool list you already have.
   - No hit = that channel doesn't exist. Never mention missing channels.
5. Start immediately — never ask permission to begin. The kickoff message is:
   - The walkthrough title and the numbered one-line step list.
   - Detected channels are ON by default. One line saying what you'll do and how to turn each off: "I'll narrate each step, jump your editor to the code, and keep a diagram page in your browser — say 'quiet', 'no jumps', or 'no page' to turn any of those off." Only mention channels that were detected.
   - Then step 1, in the same message.

## Each step

In order:

1. Companion page on? Append this step to the page's `data.json` and set `current` — diagrams only, never code. See [html-companion.md](html-companion.md).
2. Editor on? Jump it to this step's code so the user reads the real file. Skip the jump if this step stays where the last one was. See [channels.md](channels.md).
3. Audio on? Speak the step's full explanation — the same sentences you write in the terminal — at a calm pace. Never read code lines, paths, or syntax aloud. Don't wait for playback. See [channels.md](channels.md).
4. Reply inline:
   - 2–5 short sentences on what happens in this step.
   - Code snippet: ≤15 lines, cropped to what matters, file path above it, `›` at the start of the lines you're discussing.
   - ASCII diagram only when the flow branches, fans out, or involves async/events.
5. End with a natural handle and stop. Vary it. Good: "Next: how the retry lands back in the queue. Anything unclear here first?" Banned: the same "Any questions, or shall we move on?" every step.

Hard rules:

- One step per message. Never advance without a user reply.
- A user question is a detour, and detours get the full channel treatment: answer it fully (read other code if needed), narrate the answer, append it as a note on the current step's page section (with a visual when one helps), and jump the editor if the answer lives in other code. Keep the step counter where it is, then offer to resume.
- "next", "ok", "go on", or just "y" means advance.

## Configure

Invoked with "configure" (`/walkthrough configure`): run the setup flow in [configure.md](configure.md) instead of a walkthrough — pick editor, TTS, pace, and diagram page. Selections are saved to `~/.config/walkthrough.json` and reused every session.

## Style

- Short sentences. Plain words: "runs", not "orchestrates".
- Define jargon the first time it appears, then use it freely.
- One idea per sentence. No filler, no recap of what you just said.
- Assume the user is smart but new to *this* code.
