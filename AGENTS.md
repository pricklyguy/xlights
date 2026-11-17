### Rules

1. Prefer existing repositories and workspaces over creating duplicates.
2. Temporary workspaces must be identifiable and associated with their originating task.
3. Upon task completion, remove disposable workspaces and generated artifacts once their contents are no longer needed.
4. Never remove uncommitted work, active worktrees, or another agent's workspace without verification.
5. Use proper Git worktree removal procedures rather than manually deleting registered worktrees.
6. Preserve reusable build caches when rebuilding them would be more costly than retaining them, subject to storage constraints.
7. Report any temporary workspace retained after task completion, including its path and reason.
8. Do not allow temporary development environments to accumulate indefinitely.

### Task Completion Requirement

Before declaring development work complete, the responsible agent must verify that temporary resources have been cleaned up or explicitly documented for retention.

**Standard:** Create only what is needed. Clean up what you create. Never sacrifice source code or active work to save disk space.
