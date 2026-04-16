# Global User Preferences

## Git

- Never chain git commands with `&&` or `;` - run them as separate tool calls so the user can approve each independently.
- Never use `git push --force` or any force-push variant.
- To edit the latest commit: use `git commit --amend`
- Create small, focused commits so changes are easy to review and revert.
- Each commit should address a single concern (one bug fix, one feature, one refactor).
- Use a succinct imperative commit title (e.g. "Add retry logic for API calls") with max 72 characters. The lines of the body shall be also max 72 characters.
- Include gotchas, caveats, or non-obvious side effects in the commit message body.
- Never add "Co-Authored-By" lines or email addresses to commit messages.
- Add an `Assisted-by: Claude:<model-id>` git trailer to every commit message (use your actual model ID, e.g. `claude-opus-4-6`).
- **Keep all documentation up to date.** When changing behavior, update your .md file and code comments in the same commit. Stale docs are worse than no docs.

## GitHub PRs

- Do not hard-wrap lines in PR body text. Write prose as single long lines per paragraph and let the GitHub UI reflow naturally.
- Add `Assisted-by: Claude:<model-id>` to the PR description.

## Code Style

Prefer C/Rust-style architectural patterns:

- Small, clean, testable functions that are pure (no side effects)
- Structs as data carriers
- Composition over inheritance
- Keep OOP to a minimum

Defer to the existing project's architectural style if it differs.

## Bash Commands

- Never chain bash commands with `&&`, `;`, or subshells — run each as a separate tool call so the user can approve individually.
- Don't use `-C`, `--directory`, or similar flags when the current working directory is already the target. Use plain commands instead.
- Prefer `-C` flags when targeting a *different* directory (avoids `cd`).
- Use temporary files in `$(pwd)/tmp` to store intermediate data for reuse across commands.
- When a repo is cloned locally, prefer local file tools (Glob, Grep, Read) over `gh api` calls.
- When cloning open source projects, always use the official upstream repo URL, not mirrors or forks.

## Python

- Always use `uv` instead of `pip` or `pip3`.
- Always create a venv with `uv venv` first — never install system-wide (`--system`).
- Install packages with `uv pip install --python .venv/bin/python <package>`.

## File Formats

- Prefer ODF (ODP for presentations, ODS for spreadsheets) or PDF over Microsoft Office formats (PPTX, XLSX, DOCX).

## Temporary files

- Put temporary files such as logs in `$(pwd)/tmp`.
- Design specs and brainstorming documents go in `work/`, not committed to git unless explicitly asked.

## Questions vs Instructions

- When the user asks "can I do X?" or "should I do X?" — answer the question. Do not perform the action.
- Only take action when explicitly instructed to (e.g. "do X", "delete X", "run X").
- This applies especially to destructive or irreversible operations, but applies broadly.

## Gemini Added Memories
- Strictly follow explicit instructions and do not perform unrequested tasks or 'extra helpful' actions.
