---
name: github-prs
description: Conventions for working with GitHub pull requests — don't hard-wrap PR body lines, add the Assisted-by trailer, use `gh api PATCH` to edit PR body/title (not `gh pr edit`), qualify cross-repo references as `owner/repo#N`, open PRs as drafts and mark them ready only when mergeable. Load when creating, editing, commenting on, or reviewing a GitHub pull request.
---

# GitHub PRs

- Draft means not ready to merge, ready means the owner may merge it now (user, 2026-10-12):
  - Open every PR as a draft (`gh pr create --draft`). It stays a draft while implementation, review, fixes or CI are running, or a conflict is open.
  - Mark it ready with `gh pr ready <n>` only when it can be merged as is: review findings handled, CI green, no conflict.
  - Turn a ready PR back into a draft with `gh pr ready <n> --undo` as soon as it needs work again (a new finding, a conflict after another merge, red CI), and mark it ready again once fixed.
  - Subagents open their PRs as drafts and never mark them ready; the orchestrator does that after the review.
- Do not hard-wrap lines in PR body text. Write prose as single long lines per paragraph and let the GitHub UI reflow naturally.
- Add `Assisted-by: Claude:<model-id>` to the PR description.
- To edit a PR body/title after creation, use `gh api -X PATCH repos/<owner>/<repo>/pulls/<num> -F body=@<file>` (or `-f title="..."`) instead of `gh pr edit`. `gh pr edit` currently fails with a GraphQL error about the deprecated projects-classic API; the REST PATCH goes through cleanly.
- When writing GitHub text (PR bodies, issue comments, review replies) that references an issue or PR in a *different* repo, use the qualified `owner/repo#N` form, not bare `#N`. Bare `#N` auto-links within the host repo and will silently mis-resolve. Same rule for commit SHAs from other repos: write `owner/repo@sha`.
- When modifying the description of an already existing PR, make sure to use a read-modify-write procedure, in order to capture any potential direct edits made by the user.
