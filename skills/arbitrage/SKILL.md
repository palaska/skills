---
name: arbitrage
description: Always active when coding. Triggers whenever implementation work is being planned, scoped, or about to start — before writing code — to decide which work belongs to the current intelligent model and which work should be dispatched to one or more isolated Codex workers.
---

# Arbitrage

Use two explicit roles:

- **Intelligent model:** the model running the current session. It may be Claude or Codex, and may be any suitable model. Use it for judgment, planning, design intent, investigation, review, and validation.
- **Worker model:** one or more Codex CLI processes running `gpt-5.6-luna` with high reasoning effort. Use them for implementation volume.

Do not infer the intelligent model from its provider or model name. “Here” always means the current session. Do not dispatch implementation to an unspecified or default worker model.

## Routing Table

| Work | Where | Why |
|------|-------|-----|
| Planning, specs, architecture decisions | Here | Requires judgment and context |
| **Implementation — backend, frontend, tests, and code-writing volume** | Codex worker(s) via `/goal` | Keep implementation on the dedicated worker configuration |
| Visual validation of UI work (run the app, screenshot, judge, iterate) | Here | The intelligent model owns visual judgment |
| Investigation and debugging analysis (root-causing hard bugs) | Here | The intelligent model forms the hypothesis and fix spec |
| Diff review, feedback, commits, merges, cleanup, pushes, PRs | Here | Review and Git operations stay under intelligent-model control |
| Trivial edits riding along with review or validation | Here | Dispatch overhead exceeds the work |
| Work the worker has demonstrably struggled with | Here | Escape hatch — see below |

## Dispatch Protocol

1. **Partition the work.** Split only at stable boundaries. Give each worker one coherent unit with explicit ownership of files or areas, API contracts, acceptance criteria, and integration order. Run overlapping work sequentially or assign it to one worker.
2. **Create an isolated branch and worktree for each unit.** Record the current branch and base commit, then create a uniquely named worker branch and worktree from that base:

   ```bash
   git worktree add -b <worker-branch> <worker-worktree> <base-commit>
   ```

   Never run two workers in the same worktree. If workers require uncommitted changes from the current worktree, resolve that deliberately before dispatch; `git worktree add` starts from a commit.
3. **Spec each unit.** Write a task-specific spec in its worker worktree: objective, constraints, owned files or areas, acceptance criteria, the exact test command that must pass, and what not to touch. For frontend work, include design intent: layout, states, interactions, spacing, motion, and reference patterns. For hard problems, specify pseudocode and invariants. Do not include temporary coordination files in the final commit unless they belong in the repository.
4. **Dispatch to every pinned worker.** Run each eligible unit concurrently using the exact model and effort settings below:

   ```bash
   codex exec --cd <worker-worktree> -m gpt-5.6-luna -c 'model_reasoning_effort="high"' "/goal <one-line objective; details in SPEC.md>"
   ```

   Run workers in the background and continue useful planning, investigation, or validation in the intelligent-model session. Do not omit `-m` or the reasoning-effort override, and do not silently fall back to another model.

## Review, Integrate, and Clean Up

Process completed workers one at a time in dependency order:

1. **Review.** From the intelligent-model session, inspect the worker's complete diff against its base, including staged, unstaged, untracked, and committed changes. Run the specified tests and perform visual validation when relevant.
2. **Request changes when needed.** Give concrete review feedback and re-dispatch the pinned worker in the same worktree. Repeat review and correction until the implementation is satisfactory. Do not merge partial or merely plausible work.
3. **Commit approved changes.** From the intelligent-model session, commit the accepted implementation on the worker branch. Exclude temporary specs, review notes, logs, and other coordination artifacts unless they are intended repository files.
4. **Merge into the current branch.** Merge the worker branch from the original worktree using the repository's merge policy. Resolve integration conflicts deliberately, then run the relevant tests on the updated current branch.
5. **Clean up only after success.** After the merge and post-merge checks pass, remove the worker worktree and delete its merged branch:

   ```bash
   git worktree remove <worker-worktree>
   git branch -d <worker-branch>
   ```

   If merge, testing, or cleanup fails, keep the worker branch and worktree intact until the problem is understood. Never force-remove a worktree containing unreviewed changes.

## Visual Validation Loop

1. The worker implements the UI from the spec.
2. Run the app here; interact with it and take screenshots.
3. Judge the result against the design intent and write concrete feedback: what is wrong, where it is wrong, and what good looks like.
4. Re-dispatch the corrective implementation to the same pinned worker in the same worktree.
5. Repeat until the acceptance criteria and visual intent are met, then review the final diff.

## Escape Hatch: When the Worker Struggles

Struggle must be observed, not predicted. Always dispatch first when implementation belongs to the worker. If a re-dispatch with concrete corrective feedback still misses the acceptance criteria or mangles the approach, stop re-dispatching and implement the remaining work in the current intelligent-model session, salvaging sound parts of the worker’s diff.

## Red Flags

| Thought | Reality |
|---------|---------|
| “The current model is Claude, so this is a Fable session.” | The current model may be any Claude or Codex model. Route by role, not vendor. |
| “This is a different Codex model, so the worker settings are close enough.” | The worker is always `gpt-5.6-luna` with `model_reasoning_effort="high"`. Pin both explicitly. |
| “Both units are independent enough; they can share a worktree.” | Every concurrent worker gets its own branch and worktree. Shared worktrees create races and unreliable diffs. |
| “Frontend is design-critical, so I’ll code it here.” | The intelligent model’s taste belongs in the spec and validation loop; dispatch implementation. |
| “This part is too hard for the worker.” | Predicted struggle is not observed struggle. Specify it precisely and dispatch first. |
| “I’ll let the worker commit and push.” | Review the diff and run git operations from the intelligent-model session. |
| “The worker finished, so I can remove its worktree.” | Review, correct, commit, merge, and verify first. Cleanup is the final step. |

## Common Mistakes

- Dispatching without acceptance criteria or a test command → the worker returns “done” with red tests.
- Dispatching frontend work without design intent → generic UI comes back and the validation loop burns rounds recovering what the spec should have said.
- Running `codex exec` without the pinned model and effort → the task may consume the wrong quota or quality tier.
- Running concurrent workers in one worktree → edits race, ownership blurs, and review becomes unreliable.
- Blocking on the worker → run it in the background and continue useful planning, investigation, or validation work.
- Splitting one coherent unit across dispatches → pick one owner per unit and split at the API boundary, not mid-feature.
- Removing a worker worktree before its branch is merged and verified → recoverable implementation context is lost unnecessarily.
