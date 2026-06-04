---
name: worktree-workflow
description: Personal workflow for creating git worktrees. Use whenever a task asks to create a worktree, start new work in a worktree, or set up an isolated branch/worktree for a hotfix, feature, or bugfix. Enforces "always ask first", a new branch tracking a matching remote branch (never tracking main), cd-ing into the worktree, and copying .env files when requested.
---

# Git worktree workflow (personal preference)

Follow this whenever work should happen in a dedicated git worktree.

## 1. Always ask before creating a worktree

A worktree affects the team's shared expectations, so **never create one
silently**. First confirm with the user that they want a worktree for this
task. Anyone who does not want a worktree can then skip the step. Use a
structured `ask_user` confirmation rather than assuming.

Confirm at minimum:
- Whether to create a worktree at all.
- The branch name to use (propose a sensible default, e.g.
  `hotfix/<short-slug>`, `feature/<short-slug>`, or `bugfix/<short-slug>`).
- The worktree directory path (default: a sibling directory of the main
  checkout, e.g. `../<repo>-<slug>`).

## 2. Create a NEW branch that tracks a matching remote branch

The worktree must be created on a **new branch**, and that branch must push
and track a remote branch **of the same name**.

- **Never** create a worktree on a local branch that tracks `main` (or any
  existing shared branch). A worktree tracking `main` cannot be used to open a
  PR later, which defeats the purpose.
- Create the remote tracking branch as part of setup, do not defer it.

Reference commands (adjust names/paths to the confirmed values; run from the
main checkout):

```bash
# Create the worktree with a brand-new local branch
git worktree add -b <branch-name> ../<worktree-dir>

# From inside the worktree, publish the branch and set upstream tracking
cd ../<worktree-dir>
git push -u origin <branch-name>
```

`git push -u origin <branch-name>` both creates the remote branch and sets the
local branch to track it. Confirm tracking with
`git status -sb` (it should show `## <branch-name>...origin/<branch-name>`).

## 3. Switch the working directory into the worktree

After creating the worktree, change the working directory into it (e.g. via
`/cwd <worktree-path>` or by operating from that path) and confirm the context
reflects the worktree, **not** main. Do not keep working from the main
checkout once the worktree exists.

## 4. Copy .env files when requested

The local stack relies on uncommitted `.env` files (frontend/backend). When
the user asks (or when the task clearly needs a runnable local stack), copy the
relevant `.env` files from the main checkout into the matching paths in the new
worktree. Never commit these files.

## 5. Verify the outcome

Before reporting done, verify all four:
1. Worktree created (`git worktree list` shows it).
2. Remote branch created (`git ls-remote --heads origin <branch-name>` or the
   push output confirms it).
3. Worktree's branch tracks the remote (`git status -sb` shows the upstream).
4. Confirmation question(s) were asked before creating.
