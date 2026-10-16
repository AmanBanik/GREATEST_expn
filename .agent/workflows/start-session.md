# Start a Research Session

1. Read all `.agent/rules/` files and `lab-notebook/README.md`.
2. Check the current Git status, project tree, source files, and existing outputs without changing anything. This is a *current-state safety check*, not historical reconstruction. Do not infer or recreate prior history.
3. Create a new dated session log in `lab-notebook/sessions/` using `.agent/templates/session-log.md`. Use the actual current time and timezone available from the environment; if unknown, state unknown.
4. Capture the starting Git status and relevant environment/build details to timestamped files under `lab-notebook/raw/` and `lab-notebook/environment/`. Preserve stdout and stderr.
5. Summarize what is currently present, what is missing for the next planned step, and the single recommended next action. Clearly label anything not measured as unknown.
6. Do not run experiments, install packages, change configuration, overwrite files, or launch long-running commands until the user approves the proposed next action.
