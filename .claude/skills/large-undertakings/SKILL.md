---
name: large-undertakings
description: Conventions for large multi-step changes (refactors, migrations, version bumps, build-system changes, multi-commit series). Plans should focus on the recommended approach without Plan-B/fallback sections; expected roadblocks are work to do, not blockers; on the way out, write deferred items into the project tracker and include a hiccups-and-deferred-work section in the wrap-up message. Load when planning or executing a refactor, migration, version bump, build-system change, or any multi-commit series, and when finishing such a series.
---

# Large undertakings

## Planning and executing

For large multi-step changes (refactors, migrations, version bumps, build-system changes), keep plans focused on the recommended approach. Do not include "Plan B / fallback to old behavior" sections or pre-baked retreat paths. A pre-baked fallback signals defeatism and tempts retreating to a known-bad state instead of solving the real problem.

Expect roadblocks and work through them. Compile errors from API renames, flag renames in vendored build files, test adjustments, etc. are expected work on a big change, not blockers. Stop-and-ask only when a real upstream bug, missing capability, or environmental incompatibility makes the recommended approach genuinely non-viable — at that point, ask, do not pivot autonomously.

## End-of-plan reporting

When you finish a multi-commit plan or other big undertaking, do two things on the way out, even if the user doesn't ask.

**1. Write deferred items into the project tracker preemptively.** Before announcing completion, append the deferred work to `TODO.md` (or the project's equivalent tracker) under a section titled `## Possible action items`. Create the section if it doesn't exist; otherwise add to it. Each bullet should cite the relevant file/function/line and the reason the item was not done in the original series, so the bullet is actionable later. Land this as a small final commit in the same series. Do not gate on user approval to do this; the user told you once, globally, that this is the workflow. The user can still strike or rephrase items after they read it.

**2. Include a "hiccups and deferred work" section in the wrap-up message.** Two lists:

- **Hiccups during the run** — anything that needed an unplanned fix mid-flight: CI failures and how they were resolved, lint surprises, test infrastructure traps, refactors that turned out larger than expected, behavior changes that fell out of the work, anything that future-you would want to know was not smooth. Resolved items still belong here, named, so the reader knows the trap exists.
- **Deferred work and new TODOs** — what you wrote into the tracker. Mirror the bullets so the user can see them inline without opening the file. Note that they have already been written to the tracker so the user doesn't think you're asking permission.

Don't bury this under "everything went great" — surface it.
