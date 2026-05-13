---
name: github-prs
description: Conventions for working with GitHub pull requests — don't hard-wrap PR body lines, add the Assisted-by trailer, use `gh api PATCH` to edit PR body/title (not `gh pr edit`), qualify cross-repo references as `owner/repo#N`. Load when creating, editing, commenting on, or reviewing a GitHub pull request.
---

# GitHub PRs

- Do not hard-wrap lines in PR body text. Write prose as single long lines per paragraph and let the GitHub UI reflow naturally.
- Add `Assisted-by: Claude:<model-id>` to the PR description.
- To edit a PR body/title after creation, use `gh api -X PATCH repos/<owner>/<repo>/pulls/<num> -F body=@<file>` (or `-f title="..."`) instead of `gh pr edit`. `gh pr edit` currently fails with a GraphQL error about the deprecated projects-classic API; the REST PATCH goes through cleanly.
- When writing GitHub text (PR bodies, issue comments, review replies) that references an issue or PR in a *different* repo, use the qualified `owner/repo#N` form, not bare `#N`. Bare `#N` auto-links within the host repo and will silently mis-resolve. Same rule for commit SHAs from other repos: write `owner/repo@sha`.
