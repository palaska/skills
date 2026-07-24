# Modes

## Trace a flow

Follow one call, request, or event through existing code, entry point to result. No diff involved. The whole flow is one **Section**; each hop is one **Step**.

- Find the entry point: grep for the user's phrase (route, command, event name). If ambiguous, ask which one they mean.
- Each step is one hop — one place in the code:
  - **File** `path/to/file.ext` — one sentence on what this file is for.
  - **Function** `name(args)` — one or two sentences on what it does, anything non-obvious, and which arguments matter.
- Keep steps small: one location each, so the editor jump and the narration stay on the same spot. Several hops in one file = several steps.
- One Section per distinct flow. If the question spans several flows, do them one Section after another.

## Trace a change or PR

Same step shape as a flow trace, scoped to a change. Determine scope in this order:

1. User names a PR (number or URL): `gh pr view <n>` for title, description, and state — frame the Overview with the PR's stated intent, and point out when the code does something the description doesn't mention. `gh pr diff <n>` for the diff. If `gh` is missing, fetch the branch and diff against merge-base instead.
2. User names a branch: `git diff $(git merge-base HEAD <branch>)..<branch>`.
3. Otherwise: if `git status --porcelain` shows changes, the scope is `git diff HEAD`. If clean, find the base branch (try `main`, `master`, `develop`, `trunk`) and use `git diff $(git merge-base HEAD <base>)..HEAD`.

Structure — the change is a **Section**, its hops are **Steps**:

- The first step is an **Overview**: what the change is about, what the previous behavior was, and what's different now. 2–3 sentences.
- Then one short step per **File**/**Function** hop — one location each — following the journey of a call, request, or event through the change.
- Mark changed steps with **(changed)** so the user knows where to focus. Include unchanged steps when they carry the flow — reviewing changes in isolation misses the point.
- One Section per distinct flow. Multiple unrelated flows = sequential Sections, each with its own Overview.

## Orient

Top-down map of an unfamiliar codebase, organized as one Section per area of the repo.

- First step: repo layout — what the top-level directories are and which ones matter.
- Then one short step per major module: what it owns, who calls it, what it calls. One module per step.
- Draw the module-dependency diagram early as an inline ASCII diagram, and keep it small.
- End by asking which area they want to go deeper on — that continues as a flow trace.

## Explain a concept

- Diagram of the moving parts first, mechanics second.
- Ground every claim in a real snippet from the user's repo when one exists. A generic example is a fallback — say that's what it is.
- If the concept came up mid-walkthrough, treat it as a detour: explain, then offer to resume.
