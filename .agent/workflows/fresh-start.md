# Fresh Start: Establish a Reproducible Baseline

**First action:** execute `.agent/workflows/preflight-before-anything.md`. No build or benchmark during this first pass.

Start the prospective research campaign from a blank notebook. Do not reconstruct previous sessions or import old measurements. Existing source code and the field guide are starting materials; do not delete or overwrite them.

After the read-only preflight, report the environment, inventory, source-supported CLI, profiling support, unknowns, and next proposed action. Wait for approval.

After approval, create a build protocol. Record source hashes and the exact compiler command first. If a target executable already exists, do not overwrite it without approval; use a new versioned output path if the user approves. Capture stdout, stderr, exit status, and artifact hash. Never claim success without checking all of these.

For each experiment, write a protocol and falsifiable hypothesis first. Change one independent variable at a time, keep controls fixed, capture raw output unchanged, and separate observations from interpretation. Never label nominal traffic as measured DRAM traffic or infer an exact cache level from timing alone.
