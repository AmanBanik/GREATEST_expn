# Evidence, Logging, and Reproducibility Rules

## Required record for every meaningful experiment
Record:
- Unique experiment ID, date/time, timezone, and operator (the user).
- Research question and hypothesis **before** running.
- Exact command line, working directory, and source revision/hash if available.
- Environment: OS, kernel, compiler/version, compile flags, CPU, memory, power mode if known, and relevant background load.
- Whether compilation occurred and the exact compile command.
- Raw stdout/stderr and exit code; preserve CSV exactly as emitted.
- All parameters, units, repetitions, warm-up behavior, and whether setup is inside or outside the timed region.
- Deviations, failures, interruptions, and reruns.
- A short interpretation with confidence and alternative explanations.
- Next action and the reason for it.

## Evidence separation
Use these labels consistently:
- **Observed:** directly present in output, source, or environment report.
- **Calculated:** derived from observed values; show the formula.
- **Interpretation:** an explanation consistent with the evidence.
- **Hypothesis:** a possible explanation not yet tested.
- **Unknown:** not measured or not established.

Never present an interpretation or hypothesis as an observation.

## Preserve raw data
- Never overwrite a raw result file. Use a unique timestamp/experiment ID in filenames.
- Keep raw terminal output and raw CSV separate from cleaned tables, analysis scripts, and plots.
- If correcting a parser or plot, regenerate derived outputs from raw data; do not edit raw data to make it look cleaner.
- Record failed or invalid runs rather than deleting them. Mark why they are invalid.
- Avoid putting terminal output only in chat; persist it in the project notebook.
- If a command may be long-running, explain what it will do and ask before launching it unless the user has explicitly authorized that exact run.

## Statistical discipline
- Compare medians and spread across repetitions, not only the fastest run.
- Report sample count and units. Do not imply five repetitions establish universal behavior.
- Do not compare experiments with different total operation counts as if they were controlled equivalents.
- Separate latency per dependent operation from aggregate throughput.
- Document compiler optimizations, prefetching, cache residency, TLB effects, CPU scheduling, thermal/power state, and virtualization as possible confounders when relevant.
- A result that disagrees with expectations is still a result. Do not tune away inconvenient data.


## Fresh-start policy
This project begins prospective logging from installation onward. Do not perform historical reconstruction or import old measurements unless the user later explicitly asks. Never claim to have logged actions that occurred before logging was active. Record all actions the agent actually performs, and clearly tell the user when a terminal action they run themselves must be captured manually.
