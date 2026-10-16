# Command Capture Pattern

Use a unique filename for every run. Example only; replace the ID and arguments with the planned experiment values.

```bash
mkdir -p results/raw
EXP_ID="EXP-YYYYMMDD-NN"
LOG="results/raw/${EXP_ID}.combined.log"
set -o pipefail
./memory_lab chase 2048 10000000 5 2>&1 | tee "$LOG"
status=${PIPESTATUS[0]}
printf '\nEXIT_STATUS=%s\n' "$status" | tee -a "$LOG"
```

Important:
- Run this in Bash; `PIPESTATUS` is Bash-specific.
- The example captures the program's exit status, but shell setup can vary. Verify the recorded status.
- For programs that emit CSV, save the CSV output unchanged in a separate raw file when possible; do not mix explanatory prose into the CSV.
- Never reuse an existing `EXP_ID` or filename.
