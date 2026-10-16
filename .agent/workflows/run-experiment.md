# Plan, Run, and Record an Experiment

1. Read the current source and the previous records for the relevant mode.
2. State the question, hypothesis, independent variable, dependent variable, and controlled variables.
3. Check whether the proposed comparison is fair: same executable/build, same total operations where appropriate, same repetition count, and no simultaneous workload.
4. Present the exact command(s) and expected runtime/scale. Ask the user before a potentially long run unless explicitly authorized.
5. Create a unique experiment ID and record the hypothesis **before** seeing results.
6. Capture stdout and stderr to a unique raw log. If output is CSV, preserve the exact original CSV. Example pattern (adapt names; never overwrite):

   ```bash
   mkdir -p results/raw
   ./memory_lab chase 2048 10000000 5 2>&1 | tee results/raw/EXP-ID.stdout.txt
   ```

   If pipeline exit status matters, use Bash `set -o pipefail` in the same shell before the command, and record the exit status. Do not claim the example command captured an exit code unless it actually did.

7. Record exact command, timestamp/timezone, environment, binary/source state, parameters, exit status, and any interruptions.
8. Validate output shape, operation counts, checksums, and units. Do not discard odd runs silently.
9. Summarize observations separately from interpretation and list plausible confounders.
10. Update the experiment index and next-step recommendation. Preserve all earlier records.
