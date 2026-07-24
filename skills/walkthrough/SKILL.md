---
name: walkthrough
description: Interactive code explainer that walks the user through existing code, a code change or PR, codebase structure, or a concept one step at a time, in plain language with highlighted code and simple inline diagrams — with editor jumps and voice narration when available. Use when the user asks "how does X work" about the current codebase, wants to learn or understand a feature, module, or flow in existing code, asks to "explain this PR", "understand PR #123", "trace this change", "walk me through this diff", "help me review this branch", "give me a tour of this codebase", or wants a concept explained step by step.
---

# Walkthrough

Walk the user through code one small step at a time. Never dump the whole explanation at once. The user controls the pace.

## Sections and Steps

A walkthrough is a list of **Sections**, and each Section is a list of **Steps**. This structure is the point of the skill — get it right.

- A **Step** is the atomic unit. It covers **exactly one place in the code** — one function, one block, one hop. Its explanation is 2–4 short sentences. The editor jumps to that one place, and the narration speaks that one place. A step is small enough that the user can read the code, hear the sentence, and keep up.
- A **Section** is a coherent journey made of several steps — e.g. "Tracing an HTTP request" might be a section of 6 steps, each jumping to a different place as the request moves through the code.

Prefer **many short steps over few long ones**. If a step's explanation talks about more than one location, it's too big — split it. The old failure mode was one long step that jumps the editor once but then narrates across three files: the user can't follow the voice and can't see the code being discussed. One step = one location = one short beat.

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
3. Plan the full **Section → Step** outline up front, entry point → result. Each step pinned to one code location. Err toward more, smaller steps.
4. Probe capabilities — one pass, silent, never install anything:
   - One shell call: `cat ~/.config/walkthrough.json 2>/dev/null; command -v code cursor windsurf idea`. Configured settings always beat detection.
   - Several editor launchers and nothing configured? See "Detection without config" in [configure.md](configure.md).
   - Glance at your available tools for a TTS-ish name: `speak`, `say_tts`, `text_to_speech`, `tts`, `converse`, `play_audio`, `openai_tts`, `elevenlabs_tts`. In Claude Code, one ToolSearch query; otherwise scan the tool list you already have.
   - No hit = that channel doesn't exist. Never mention missing channels.
5. Start immediately — never ask permission to begin. The kickoff message is:
   - The walkthrough title, then the outline: each Section with its steps listed as short one-liners underneath.
   - Detected channels are ON by default. One line saying what you'll do and how to turn each off: "I'll narrate each step and jump your editor to the exact code — say 'quiet' or 'no jumps' to turn either off." Only mention channels that were detected.
   - Then step 1, in the same message.

## Each step

Do these in order, every step:

1. **Editor (if enabled): always jump.** Jump the editor to this step's one location so the user reads the real file. This is mandatory whenever the editor channel is on — never explain code you didn't jump to. Skip the jump only when this step is at the exact same spot as the previous one. See [channels.md](channels.md).
2. **Audio (if enabled): always narrate.** Speak this step's full explanation — the same sentences you write in the terminal, adapted for speech. This is mandatory whenever the audio channel is on: every step and every detour is narrated, never a text-only reply. Never read code lines, paths, or syntax aloud. Don't wait for playback. See [channels.md](channels.md).
3. **Reply inline:**
   - 2–4 short sentences on this one place in the code. One location only.
   - Code snippet: ≤15 lines, cropped to what matters, file path above it, `›` at the start of the lines you're discussing.
   - A visual when it helps understanding — an ASCII/box-drawing diagram, a small chart, a state table. The conversation is the only visual surface now, so draw it here: flows that branch/fan-out/async, data shapes, before→after. Keep it small and legible. When a flow spans a section, it helps to redraw the same small diagram each step with the current node accented (e.g. `▶`).
4. **End with the input menu** (below). This is not optional prose — you must actually present the menu, then stop.

### The input menu

Every reply — steps and detour answers alike — must **end by presenting a selectable menu**, never a prose-only question like "want to go deeper or move on?". In Claude Code this means the reply ends with an **AskUserQuestion call**; there is no text-only alternative when that tool is available.

Present exactly these, in this order:

1. **Next step** — advance. Always the first option.
2. **Replay narration** — re-speak the last explanation. Include this option only when audio is enabled (so with audio off there is just one explicit option).
3. *(free text — the iteration path)* — the user asks a question or keeps digging in their own words. This is **not** an explicit option: it's AskUserQuestion's built-in "Other" field, which is always present. Do not add a "Ask a question" option — the free-text field already is that. Treat whatever the user types there as their question, and handle it as a detour.

Keep the AskUserQuestion `question` short (e.g. "What next?") and you may name what's coming in the reply text just above it ("Next up: how the retry lands back in the queue"). But the menu itself must always be rendered as selectable options. Outside Claude Code, where no such tool exists, write the options as a short numbered list and invite a free-text question instead.

## Hard rules

- One step per message. Never advance without a user reply.
- Every reply ends with the selectable input menu (AskUserQuestion in Claude Code) — never a prose-only "shall we move on?". No exceptions.
- If audio is enabled, every reply is narrated. If the editor is enabled, every step jumps. No silent or code-less steps.
- A user question is a detour, and detours get the full channel treatment: answer it fully (read other code if needed), narrate the answer, jump the editor if the answer lives in other code, and add an inline visual when one helps. Keep the step counter where it is, then re-offer the menu.
- "next", "ok", "go on", or just "y" means advance. "replay" or "again" re-speaks. Anything else is a question — treat it as a detour.

## Configure

Invoked with "configure" (`/walkthrough configure`): run the setup flow in [configure.md](configure.md) instead of a walkthrough — pick editor, TTS, and pace. Selections are saved to `~/.config/walkthrough.json` and reused every session.

## Style

- Short sentences. Plain words: "runs", not "orchestrates".
- Define jargon the first time it appears, then use it freely.
- One idea per sentence. No filler, no recap of what you just said.
- Assume the user is smart but new to *this* code.
