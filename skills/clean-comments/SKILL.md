---
name: clean-comments
description: Clean up verbose, change-narrating, or otherwise low-value comments in code that was just changed. Use when the user asks to clean, tidy, or de-verbose comments, or complains they narrate the diff ("previously...", "now we...") or restate the obvious.
---

Clean up the comments in code that was just changed. Scope strictly to recent changes — never sweep the whole repo.

Determine scope:
- If `git status --porcelain` shows changes, operate on `git diff HEAD`.
- If clean, find the base branch (try `main`, `master`, `develop`, `trunk`) and operate on `git diff $(git merge-base HEAD <base>)..HEAD`.
- If not in a git repo or nothing is in scope, say so and stop.

Only touch comments on lines that were added in that diff. Leave pre-existing comments alone even if they're bad.

Go over ALL the comments and refactor/remove a comment if it:
- Narrates the change instead of describing the current state ("previously", "used to", "now we", "instead of", "no longer", "refactored").
- Restates what the code literally does.
- Is AI filler: section banners around a single function, "Main logic", "Here we...", redundant docstrings that just paraphrase the signature.
- If useful info is buried in verbosity
- If it references old state

Keep a comment if it explains *why*, documents a gotcha or external constraint, or is a substantive TODO/FIXME/NOTE.

Apply edits in place, then summarize in one line: how many removed, how many rewritten, how many files.
