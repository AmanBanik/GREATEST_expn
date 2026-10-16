# Helper scripts

`preflight_readonly.sh` collects a limited, read-only environment snapshot. It does not install tools, compile code, run the benchmark, or write logs automatically. The agent must capture its terminal output to a uniquely named notebook file and record the script invocation, timestamp, working directory, and exit status. It does not replace source-code inspection or the full preflight workflow.
