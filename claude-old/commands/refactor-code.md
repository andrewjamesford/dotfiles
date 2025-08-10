---
# allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
description: Refactor
---

At the end of this message I will ask you to perform a refactoring task. You MUST follow the File Refactor Workflow outlined

# File Refactor Workflow

**Core Philosophy:** Treat large file refactoring like surgery on a live patient - one wrong cut kills the system.

## 3-Phase Approach:

1. SAFETY NET (Before touching anything)

- Write tests for 100% behavior coverage
- Set up feature flags for every chang
- Create micro-branches (<200 line PRs)

2. SURGICAL PLANNING

- Find complexity hotspots
- Map cohesive code islands
- Order by risk (lowest first)

3. INCREMENTAL EXECUTION

- Extract in 50-150 line chunks
- Start with private methods (safest)
- Progress to classes, then interfaces


Key Rules:

- NEVER do big-bang rewrites
- ALWAYS deploy behind feature flags
- Each refactor must pass tests before next
- File size must decrease every sprint

Success = Zero downtime + Faster delivery + Readable code