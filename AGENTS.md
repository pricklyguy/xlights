## DemonX/Prickly Guy Development Standard — Temporary Workspace Management
Applies to: All DemonX DEV and Prickly Guy repositories, development agents, and automated development processes.

Core Requirement:
Any temporary clone, Git worktree, scratch directory, isolated build target, or testing workspace created during development must have a defined purpose and be cleaned up when no longer needed.

## Rules
- Prefer existing repositories and workspaces over creating duplicates.
- Temporary workspaces must be identifiable and associated with their originating task.
- Upon task completion, remove disposable workspaces and generated artifacts once their contents are no longer needed.
- Never remove uncommitted work, active worktrees, or another agent's workspace without verification.
- Use proper Git worktree removal procedures rather than manually deleting registered worktrees.
- Preserve reusable build caches when rebuilding them would be more costly than retaining them, subject to storage constraints.
- Report any temporary workspace retained after task completion, including its path and reason.
- Do not allow temporary development environments to accumulate indefinitely.
- Task Completion Requirement:
Before declaring development work complete, the responsible agent must verify that temporary resources have been cleaned up or explicitly documented for retention.

Standard: Create only what is needed. Clean up what you create. Never sacrifice source code or active work to save disk space.

## CORE PRINCIPAL of all DemonX Software:
- K.I.S.S. (keep it simple stupid)  DemonX should appear simple and easy to use, but under the hood, very powerful with advanced features for more experienced users.
- Updates should be simple and easy.  No complicated schemes.  A new user to the hobby should be able to understand the updates.

