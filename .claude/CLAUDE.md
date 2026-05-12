# Global User Preferences

## Memory

When the user says "remember globally", "remember this globally", or any similar phrasing, save the instruction to this file (`~/.claude/CLAUDE.md`) rather than to a per-project memory entry. The per-project auto-memory system still applies for project-specific feedback, user, project, or reference notes. "Remember globally" is the explicit signal to write here.

## Best practices

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed. These best practices comes from https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

## Wrap-up and follow-up offers

Never end a reply with an offer to schedule a reminder agent or recurring agent (e.g. "Want me to /schedule an agent in 2 weeks to..."). The user works at their own pace and does not want unsolicited scheduling suggestions. If something feels worth revisiting, the user will say so themselves; you have no sense of time and no view of their calendar, so any cadence you propose is guesswork. The general "end-of-plan" wrap-up still applies (hiccups, deferred work, items added to the project tracker), just without the schedule offer.

## Git

- Never chain git commands with `&&` or `;` - run them as separate tool calls so the user can approve each independently.
- Don't use `git -C <path>` when the current working directory is already `<path>`. Run plain `git`. The general `-C` rule in the Bash Commands section is easy to forget specifically for git.
- Never use `git push --force` or any force-push variant.
- To edit the latest commit: use `git commit --amend`
- Create small, focused commits so changes are easy to review and revert.
- Each commit should address a single concern (one bug fix, one feature, one refactor).
- Use a succinct imperative commit title (e.g. "Add retry logic for API calls") with max 72 characters.
- Wrap the commit message body to max 72 columns with `fmt -w 72`, in place, before committing. `fmt` does not have a `-i` flag like `sed -i`, so use the command-substitution idiom: `printf '%s\n' "$(fmt -w 72 tmp/commit_msg.txt)" > tmp/commit_msg.txt`. Single command, no temp file: the `$(…)` reads and reformats the file before the `>` redirection truncates it. Verify with `awk 'length > 72 { print NR": "length"  "$0 }' tmp/commit_msg.txt` (any printed line is an overrun), then `git commit -F tmp/commit_msg.txt`. Title (first line) and trailer lines are preserved if already ≤72 chars; if a title would exceed, shorten it manually before running `fmt`. `fmt` mangles indented code blocks (compiler output, indented snippets) and splits trailer lines that exceed 72 chars (which breaks git's trailer parser). Inspect the output and fix by hand if either case applies. Do **not** use a `fmt … > tmp/commit_msg.wrapped; mv tmp/commit_msg.wrapped tmp/commit_msg.txt` two-file dance: it's confusing on inspection and obscures whether the commit used the wrapped or unwrapped content.
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

## End-of-plan reporting

When you finish a multi-commit plan or other big undertaking, do two things on the way out, even if the user doesn't ask.

**1. Write deferred items into the project tracker preemptively.** Before announcing completion, append the deferred work to `TODO.md` (or the project's equivalent tracker) under a section titled `## Possible action items`. Create the section if it doesn't exist; otherwise add to it. Each bullet should cite the relevant file/function/line and the reason the item was not done in the original series, so the bullet is actionable later. Land this as a small final commit in the same series. Do not gate on user approval to do this; the user told you once, globally, that this is the workflow. The user can still strike or rephrase items after they read it.

**2. Include a "hiccups and deferred work" section in the wrap-up message.** Two lists:

- **Hiccups during the run** — anything that needed an unplanned fix mid-flight: CI failures and how they were resolved, lint surprises, test infrastructure traps, refactors that turned out larger than expected, behavior changes that fell out of the work, anything that future-you would want to know was not smooth. Resolved items still belong here, named, so the reader knows the trap exists.
- **Deferred work and new TODOs** — what you wrote into the tracker. Mirror the bullets so the user can see them inline without opening the file. Note that they have already been written to the tracker so the user doesn't think you're asking permission.

Don't bury this under "everything went great" — surface it.

## Grounding in facts

- Ground every statement in cold evidence: source code you've read, commits/issues/PRs you've linked, commands whose output you can cite. No expert-sounding hand-waving, no plausible-sounding extrapolation presented as fact.
- If you're unsure about a claim, verify first. Web search, WebFetch, `gh` API, reading the source — whichever fits. When verification isn't possible or is ambiguous, ask the user rather than filling the gap with a guess.
- Hedging words ("probably", "likely", "arguably") are not a shield — if you reach for one, that's the signal to either verify or ask.
- When corrected, retract cleanly and narrow the claim to what's actually supported. Don't defend the mistake.
- Claims about ecosystem state ("no one uses X", "only Y depends on this", "X has no downstream consumers") are bounded by what you can actually see: public GitHub search, the packages you've read, the issues you've clicked through. Private repos, internal codebases, and unpublished forks are invisible to you. When writing these claims into PR descriptions, issues, or code comments that go out under the user's name, scope them to what you verified ("based on a best-effort look at public code", "I couldn't find any consumer outside the key path"), and leave room for the user who didn't push their code to the internet.

## Gemini Added Memories
- Strictly follow explicit instructions and do not perform unrequested tasks or 'extra helpful' actions.
