---
name: trace-changes
description: Walk the user through a code change as a traced journey of function calls or events, so they can review it. Use when the user asks to "explain this PR", "trace this change", "walk me through this diff", "help me review this", or wants to understand recently-changed code on a branch (committed or unstaged).
---

Help the user review a code change by tracing the flow of execution through it.

Determine scope:
- If `git status --porcelain` shows changes, the scope is `git diff HEAD`.
- If clean, find the base branch (try `main`, `master`, `develop`, `trunk`) and use `git diff $(git merge-base HEAD <base>)..HEAD`.
- If the user names a PR or branch, diff against that instead.

Read the diff, then read enough of the surrounding code to actually understand the flow — including unchanged files and functions that the changed code calls into or is called from. Reviewing changes in isolation misses the point.

Output in this exact shape:

**Overview** (2-3 sentences):
- What this change is about.
- What the previous behavior was, and what's different now.

**Trace** (enumerated steps following the journey of a call, request, or event from entry point to result):

For each step:
- **File** `path/to/file.ext` — one sentence on what this file is for.
- **Function** `name(args)` — one or two sentences on what it does, anything non-obvious, and which arguments matter.

Rules for the trace:
- Include steps in unchanged code if they're part of the flow. Mark changed steps with **(changed)** so the user knows where to focus.
- Keep sentences short. Plain language. No filler.
- If the flow branches, fans out, or involves async/events, draw a small ASCII diagram before the steps.
- One trace per distinct flow. If the change touches multiple unrelated flows, do separate Overview + Trace sections for each.
