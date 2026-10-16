# Hypothesis Register

## Active Pre-Registered Hypotheses for EXP-20261016-01 (Revision 3.0)

| ID | Date Registered / Revised | Experiment ID | Hypothesis Summary | Measurable Prediction | Falsification / Guardrail Conditions | Outcome / Status |
|---|---|---|---|---|---|---|
| **H1** | 2026-10-16 (Rev 3.0) | `EXP-20261016-01` | Low-latency plateau at small working sets | For sizes <= 32 KiB, average time per step will remain low and relatively flat (~1–4 ns/step), reflecting high hit rates in primary on-core cache storage. | Time per step increases sharply or fluctuates wildly below 32 KiB without external system interference. | **Supported** (Observed medians: 1.47 ns at 16 KiB, 1.24 ns at 32 KiB; verification 1.67 ns at 16 KiB) |
| **H2** | 2026-10-16 (Rev 3.0) | `EXP-20261016-01` | Multi-stage latency regimes | As working-set size increases from 16 KiB to 64 MiB, elapsed time per operation will increase, exhibiting one or more upward inflection regions or regimes consistent with memory hierarchy constraints. | Completely flat curve across all sizes falsifies H2. *Guardrail:* A continuous or gradual increase does NOT disprove cache effects; associativity conflicts and set-indexing can blur transition boundaries. | **Supported** (Observed multi-stage steps: ~1.2–1.5 ns up to 32 KiB, jumping to ~2.6–6.2 ns across 64 KiB–2 MiB, stepping to ~13.7–16.3 ns across 4–8 MiB, and rising to ~41–100 ns across 16–64 MiB) |
| **H3** | 2026-10-16 (Rev 3.0) | `EXP-20261016-01` | Large-scale footprint and address translation influences | At large working sets (> 16 MiB), the pointer chain spans an array across thousands of 4 KiB virtual pages, potentially incurring address translation overheads (TLB misses / page walks) alongside cache misses. | *Guardrail:* Touching a virtual page does not prove or measure a TLB miss. Timing measurements alone cannot isolate or quantify the proportion of latency attributable to TLB misses vs. cache misses. | **Consistent with observations** (Elevated latency plateau of 88–100 ns observed at 32–64 MiB; however, timing alone cannot isolate TLB costs from memory controller/DRAM latency) |

## Active Pre-Registered Hypotheses for EXP-20261016-02 (Revision 2.0)

| ID | Date Registered / Revised | Experiment ID | Hypothesis Summary | Measurable Prediction | Falsification / Guardrail Conditions | Outcome / Status |
|---|---|---|---|---|---|---|
| **H4** | 2026-10-16 (Rev 2.0) | `EXP-20261016-02` | Small working-set tier (32 KiB): Limited MLP benefit & overhead sensitivity | At 32 KiB (nominally within the reported 48 KiB L1d cache), loads hit in ~1.2 ns. Increasing chains ($C=1 \dots 16$) will yield negligible latency reduction per operation and may slightly increase `ns_per_op` due to loop/vector overhead. | Amortized `ns_per_operation` decreases dramatically ($> 2\times$) with increasing $C$ within the small tier. | **Supported with nuance** (Observed amortized latency drops from 1.50 ns/op at $C=1$ to 0.27 ns/op at $C=16$ [5.50x speedup] due to superscalar multi-port load throughput; however, derived step time increases from 1.50 ns to 4.36 ns and total runtime increases from 0.003 s to 0.009 s due to loop instruction overhead inside `chains_kernel`) |
| **H5** | 2026-10-16 (Rev 2.0) | `EXP-20261016-02` | Large working-set tier (64 MiB): Significant MLP latency hiding | At 64 MiB (well beyond nominal on-chip cache capacities), multiple independent chains provide an opportunity for MLP, allowing multiple outstanding misses to overlap in LFBs/DRAM banks. Amortized `ns_per_op` will decrease significantly as $C$ increases up to the hardware concurrency limit. | *Guardrail:* Independent chains provide an opportunity for MLP; wall-clock latency reduction does not directly prove physical hardware bus concurrency or buffer occupancy. | **Strongly Supported** (Observed amortized latency drops from 125.70 ns/op at $C=1$ down to 9.20 ns/op at $C=16$ [13.66x speedup]. At $C=8$, 16M operations finish in 0.201 s vs 0.251 s for 2M operations at $C=1$, demonstrating dramatic latency hiding across concurrent outstanding misses) |
| **H6** | 2026-10-16 (Rev 2.0) | `EXP-20261016-02` | Intermediate working-set tier (1 MiB): Moderate concurrency scaling | At 1 MiB (nominally within the reported 2 MiB L2 cache), independent chains will exhibit moderate concurrency scaling, reducing amortized `ns_per_op` between the small tier plateau and large tier scaling. | Flat or increasing latency identical to small tier behavior would indicate lack of intermediate tier concurrency. | **Supported** (Observed amortized latency scales from 5.53 ns/op at $C=1$ to 0.67 ns/op at $C=16$ [8.29x speedup], bridging small tier superscalar scaling and large tier MLP scaling) |

---

## Evaluated Hypotheses for EXP-20261016-03 (Run 2)

| ID | Date Registered | Experiment ID | Hypothesis Summary | Measurable Prediction | Falsification / Guardrail Conditions | Outcome / Status |
|---|---|---|---|---|---|---|
| **H7** | 2026-10-16 | `EXP-20261016-03` | Kernel Equivalence (Descriptive Heuristic) | At 32 KiB, overall median amortized latency of `chains C=1` matches `chase` within $\pm 5.0\%$: $$-5.0\% \le \frac{\text{Med}(\text{chains } C=1) - \text{Med}(\text{chase})}{\text{Med}(\text{chase})} \times 100\% \le +5.0\%$$ | $|\Delta_{\text{kernel}}| > 5.0\%$ indicates kernel loop structure materially alters baseline. *Guardrail:* Descriptive heuristic only; 5 blocks do not establish formal statistical equivalence. | **Supported (Practical Equivalence)** (Observed: 32K chase = 0.9554 ns/op, chains C=1 = 0.9887 ns/op; $\Delta_{\text{kernel}} = +3.49\%$, within $\pm 5.0\%$ band) |
| **H8** | 2026-10-16 | `EXP-20261016-03` | Measurement Stability & Dispersion | Inter-block median spread ($\max_B - \min_B$) and coefficient of variation ($\text{CV}_B$) across 5 balanced blocks will characterize run-to-run dispersion under process interleaving. | *Guardrail:* Comparing EXP-02 and EXP-03 variability is an informative descriptive comparison, not a controlled causal proof that run order caused earlier drift. | **Consistent with drift moderation at L1; DRAM variability persists** (32 KiB drift bounded at 6.72%–8.06% compared to +40.22% in EXP-02; 64 MiB timing variability persisted at ~23% across launches) |
| **H9** | 2026-10-16 | `EXP-20261016-03` | Within-Block Concurrency Speedup Robustness | In **every individual block** $B \in \{1 \dots 5\}$, within-block speedup $$S_B = \frac{\text{Median}(64\text{M, chains } C=1)_B}{\text{Median}(64\text{M, chains } C=4)_B}$$ will strictly exceed $3.0\times$ ($S_B > 3.00\times$). | Any block where $S_B \le 3.00\times$ falsifies H9 and shows host performance shifts can compress apparent MLP speedup. | **Supported** (Observed within-block speedups across Blocks 1–5: $4.41\times$, $3.42\times$, $4.35\times$, $4.20\times$, $4.26\times$; all strictly exceed $3.00\times$; overall median ratio is $4.21\times$) |

---

## Revision History
- **Revision 1.0 (2026-10-16T14:30:23Z):** Initial hypotheses registered for EXP-20261016-01.
- **Revision 2.0 (2026-10-16T14:37:25Z):** Refined H1, H2, and H3 for EXP-20261016-01.
- **Revision 3.0 (2026-10-16T14:45:46Z):** Final precision refinement for EXP-20261016-01.
- **Post-Execution Evaluation (2026-10-16T14:56:16Z):** Evaluated EXP-20261016-01: H1 and H2 supported by data; H3 consistent with large-set latency profile.
- **Revision 4.0 (2026-10-16T15:50:00Z):** Pre-registered H4, H5, and H6 for `EXP-20261016-02` (MLP multi-chain investigation).
- **Revision 5.0 (2026-10-16T15:58:00Z):** Replaced categorical labels with descriptive tier labels (small, intermediate, large); framed nominal cache capacities as architectural hypotheses rather than residency guarantees.
- **Post-Execution Evaluation (2026-10-16T16:16:56Z):** Evaluated EXP-20261016-02: H4 supported with nuance; H5 strongly supported (13.66x MLP speedup in large tier); H6 supported (8.29x intermediate scaling).
- **Draft Proposal Addition (2026-10-16T17:23:00Z):** Added draft hypotheses H7, H8, H9 for `EXP-20261016-03` pending execution approval.
- **Post-Execution Evaluation (2026-10-16T21:28:11Z):** Evaluated EXP-20261016-03 Run 2: H7 supported (practical equivalence within +3.49%); H8 consistent with L1 drift moderation while 64 MiB variability persists; H9 supported (all 5 blocks strictly exceed 3.00x).


