# Safe Tool and Command Use

- Prefer read-only inspection before edits: `pwd`, `git status`, `git diff`, `sed`, `grep`, `head`, `tail`, `file`, `lscpu`, `uname -a`, compiler version commands.
- Do not delete, overwrite, reset, clean, or reinitialize project files without explicit user approval.
- Never run destructive commands such as `rm -rf`, `git reset --hard`, `git clean -fdx`, or broad recursive edits as an automatic step.
- Before changing source code, explain the intended change and preserve a diff or backup when appropriate.
- Never silently change compiler flags, test parameters, random seeds, timing boundaries, or measurement method.
- Keep secrets, access tokens, private keys, and unrelated personal files out of logs.
- Do not install packages, change system settings, alter Windows/WSL configuration, or use elevated privileges without asking first.
- If `perf` or another counter tool fails, preserve its exact error. Do not keep retrying with sudo or kernel changes without discussing the options.
- Avoid parallel experiment runs unless the purpose is explicitly to test concurrency; simultaneous runs contaminate timing.
