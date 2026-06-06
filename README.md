# worktree-workflow

A personal [agent skill](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
that standardises how an AI coding agent creates **git worktrees**.

It enforces a safe, PR-ready worktree setup:

1. **Always ask first** before creating a worktree.
2. Create a **new branch** that pushes and **tracks a matching remote branch** —
   never a local branch tracking `main` (that can't be turned into a PR later).
3. **`cd` into the worktree** and confirm the context is the worktree, not main.
4. **Copy `.env` files** into the worktree when asked.
5. **Verify** all of the above before reporting done.

The behaviour lives in [`SKILL.md`](./SKILL.md).

## Compatibility

The skill uses the portable [open Agent Skills standard](https://agentskills.io)
(`SKILL.md` with YAML frontmatter), so the same file works across agents that
implement it:

| Agent              | Personal skills location                    | Auto-discovered? |
| ------------------ | ------------------------------------------- | ---------------- |
| GitHub Copilot CLI | `~/.copilot/skills/` or `~/.agents/skills/` | Yes              |
| Claude             | `~/.claude/skills/`                          | Yes              |
| OpenAI Codex       | `~/.codex/skills/` or `~/.agents/skills/`   | Yes     |

All three also discover repo-scoped skills under `.agents/skills/`, and Codex
and Copilot follow symlinked skill folders.

## Install

### One-liner (any device)

```bash
curl -fsSL https://raw.githubusercontent.com/NEOLPAR/worktree-workflow/main/install.sh | bash
```

This clones a canonical copy to `~/.local/share/agent-skills/worktree-workflow`
and symlinks it into the Copilot (`~/.copilot/skills`), Claude
(`~/.claude/skills`), Codex
(`~/.codex/skills`), and shared (`~/.agents/skills`) skill directories. The
`~/.agents/skills` link is the user-level location, so this single
command covers all three agents. Re-run it (or `git pull` in that folder) to
update everywhere.

Pick specific targets or copy instead of symlink:

```bash
bash install.sh copilot           # Copilot only
bash install.sh codex             # Codex only
bash install.sh claude agents     # Claude + generic ~/.agents
bash install.sh --copy            # copy files instead of symlinking
```

### Manual

Clone (or copy) this repo so that `SKILL.md` sits at
`<skills-dir>/worktree-workflow/SKILL.md`:

```bash
git clone https://github.com/NEOLPAR/worktree-workflow.git ~/.copilot/skills/worktree-workflow
```

Then in Copilot CLI run `/skills reload` and `/skills info worktree-workflow`.

### Codex

Codex reads the same `SKILL.md` standard. Place the skill at the user location
`~/.codex/skills/worktree-workflow/` (the installer's `agents` target does
this) or check it into a repo's `.agents/skills/`. List skills with `/skills`
and invoke explicitly with `$worktree-workflow`. Restart Codex if a newly
added skill doesn't appear.

## Usage

Just ask naturally — the agent matches on the skill's `description`:

```
create a worktree for a hotfix that fixes the year selector
```

Or force it explicitly in Copilot CLI: `/worktree-workflow ...`.

## License

[MIT](./LICENSE)
