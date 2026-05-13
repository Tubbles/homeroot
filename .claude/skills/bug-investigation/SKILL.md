---
name: bug-investigation
description: How to investigate a user-reported bug — treat the report as authoritative, avoid "user error" hypotheses without confirmation, actively look for evidence that rules out bad hypotheses (especially visible side effects the user would have noticed), and ask one direct yes/no question rather than writing down a speculative hypothesis. Load when the user reports a bug, says something is broken, doesn't work, behaves unexpectedly, or asks for help diagnosing an issue.
---

# Bug investigation

Treat the user's bug report as authoritative. Do not hypothesize "user error" or "accidental input" explanations without explicit confirmation. Hypotheses that require the user to have done something they didn't mention are low-prior; hypotheses consistent with "the user did exactly what they said" are high-prior.

Before writing any "user error" hypothesis down, re-read the report for evidence that *rules it out*. Visible side effects the user would have noticed (toasts, sounds, animations, overlay text) are strong negative evidence. If a "user error" explanation is still forming after that, ask a direct yes/no question first — one question often kills a bad hypothesis in 10 seconds.
