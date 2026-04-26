# Global User Preferences

## Memory

When the user says "remember globally", "remember this globally", or any similar phrasing, save the instruction to this file (`~/.claude/CLAUDE.md`) rather than to a per-project memory entry. The per-project auto-memory system still applies for project-specific feedback, user, project, or reference notes. "Remember globally" is the explicit signal to write here.

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
- To edit a PR body/title after creation, use `gh api -X PATCH repos/<owner>/<repo>/pulls/<num> -F body=@<file>` (or `-f title="..."`) instead of `gh pr edit`. `gh pr edit` currently fails with a GraphQL error about the deprecated projects-classic API; the REST PATCH goes through cleanly.

## Writing in the user's name

When producing text that goes out under the user's name (commit messages, PR descriptions, PR and issue comments, code comments authored for them, emails, chat messages), do not use any punctuation dash. That means no em-dash (`—`), no en-dash (`–`), and no hyphen used as a sentence-level separator (e.g. ` - `). These read as stiff and academic. Rewrite with commas, colons, periods, parentheses, or separate sentences instead.

Hyphens inside compound words (`well-named`, `opt-in`) and CLI flags (`--draft`) are fine. This rule is about dashes as prose punctuation, not word formation.

Keep semicolons to a minimum for the same reason. They read as uptight. Prefer a period and a new sentence, or a comma where grammar allows. If a semicolon is genuinely the right tool, it must be used strictly correctly: joining two independent clauses that could each stand alone as complete sentences, never as a fancy comma.

Do not state the obvious or add filler. If the reader can see a fact from the diff (line count, "purely additive", "no callers affected", "this commit introduces"), leave it out. What belongs in a commit message or PR description is information the diff cannot show: the why, the tradeoff, the gotcha, the cited precedent, the test plan that confirms the claim. Anything the diff already proves is noise that wastes the reader's time.

Tone: succinct, technical, friendly. Extend benefit of the doubt. Never attribute to malice what is adequately explained by ignorance. Skip hedging, apology, and self-praise in equal measure.

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

## Grounding in facts

- Ground every statement in cold evidence: source code you've read, commits/issues/PRs you've linked, commands whose output you can cite. No expert-sounding hand-waving, no plausible-sounding extrapolation presented as fact.
- If you're unsure about a claim, verify first. Web search, WebFetch, `gh` API, reading the source — whichever fits. When verification isn't possible or is ambiguous, ask the user rather than filling the gap with a guess.
- Hedging words ("probably", "likely", "arguably") are not a shield — if you reach for one, that's the signal to either verify or ask.
- When corrected, retract cleanly and narrow the claim to what's actually supported. Don't defend the mistake.
- Claims about ecosystem state ("no one uses X", "only Y depends on this", "X has no downstream consumers") are bounded by what you can actually see: public GitHub search, the packages you've read, the issues you've clicked through. Private repos, internal codebases, and unpublished forks are invisible to you. When writing these claims into PR descriptions, issues, or code comments that go out under the user's name, scope them to what you verified ("based on a best-effort look at public code", "I couldn't find any consumer outside the key path"), and leave room for the user who didn't push their code to the internet.

## Gemini Added Memories
- Strictly follow explicit instructions and do not perform unrequested tasks or 'extra helpful' actions.
