# Public-Release Security, Integrity, and Architecture Audit

**Repository:** CPU Memory Lab / Memory Wall  
**Evaluated Branch / Commit:** `main` at `755fbea29c3c1e565ff01adaa5873df5d3702522` (Local Release Candidate)  
**Date of Audit:** 2026-10-17T21:30:00Z  
**Operating Boundary:** Local static inspection and non-benchmark validation only. Zero remote pushes, zero visibility changes, zero benchmark re-executions.

---

## 1. Executive Summary & Release Readiness

### **Readiness Verdict: LOCAL RELEASE CANDIDATE PREPARED — AWAITING HUMAN APPROVAL**

The repository has been restructured into a public-facing research repository while preserving the supporting Antigravity agent toolkit:
1. **README Transformation Complete:** The original agent setup guide has been preserved intact as [`BASE_INSTRUCTIONS.md`](BASE_INSTRUCTIONS.md). A canonical, research-focused [`README.md`](README.md) has been created to introduce external readers from the Medium article to the research questions, methodology, audited results, and reproduction steps.
2. **Security & Credentials Clean:** Comprehensive scanning of the working tree and the full Git commit history identified **zero API keys, credentials, private tokens, or passwords**.
3. **Research Artifact Invariance:** All C++ source code, baseline executables, assembly dumps, raw CSV measurements, and sweep logs remain **byte-for-byte identical** to their baseline cryptographic hashes.
4. **Validation Passing:** All non-benchmark automated audits (`audit_exp01.py`, `audit_exp02.py`, `audit_exp03.py`) and self-test suites pass with exit status `0`.
5. **Decisions Reserved for Human Authorization:** Repository licensing (no license currently exists) and the final decision to publish/push to a public remote remain held for explicit human instruction.

---

## 2. Security & Privacy Audit

### 2.1 Scan Coverage & Methodology
- **Working Tree Scope:** All 65 tracked repository files inspected.
- **Git History Scope:** Complete commit history (7 commits from `2f260ab` to `755fbea`) inspected via `git log -p --full-history`.
- **Search Patterns:** Evaluated against high-entropy regex patterns for:
  - AWS access keys / secret keys
  - GitHub Personal Access Tokens (`ghp_*`, `gho_*`)
  - Generic API keys, Auth Bearer tokens, private key headers (`BEGIN RSA/OPENSSH PRIVATE KEY`)
  - Passwords and inline credentials in URLs (`http://user:pass@...`)
  - Local usernames and absolute paths (`/home/amans/...`)

### 2.2 Security Findings
| Category | Severity | Finding Details | Status / Remediation |
|---|:---:|---|---|
| **Credentials & Secrets** | **None** | Zero API keys, private keys, authentication tokens, or passwords found across working tree and commit history. | **PASS** |
| **Local Paths & Username** | **Low / Privacy** | The string `/home/amans` appears across 21 files: (a) raw execution logs capturing literal shell invocations, (b) markdown files containing local `file:///home/amans/...` links, and (c) a fallback conda path in `scripts/plot_exp03.py`. | **Quarantined in raw evidence; clean relative links used in new public `README.md`.** |
| **Target Remote Configuration** | **Informational** | Remote origin is configured to `https://github.com/AmanBanik/GREATEST_expn.git` (currently private). | **Held; no pushes permitted.** |

### 2.3 Local Path Hygiene Details
- **Raw Execution Evidence (`lab-notebook/raw/`):** Sweep logs (`EXP-20261016-03-run2-sweep.log`, preflight outputs) record literal shell invocations such as `Command: /home/amans/Devfield2/experiment/memory-wall/memory_lab chains 8388608...`.  
  *Preservation Rationale:* Per Rule 5, raw logs constitute unalterable scientific evidence. Modifying them would invalidate recorded SHA-256 digests.
- **New Public Documentation:** The new root [`README.md`](README.md), [`BASE_INSTRUCTIONS.md`](BASE_INSTRUCTIONS.md), and [`RESEARCH-INDEX.md`](RESEARCH-INDEX.md) use clean relative repository links (e.g., `src/memory_lab.cpp`, `lab-notebook/...`), ensuring external readers navigating on GitHub encounter working links rather than broken local `file:///` URLs.

---

## 3. Licensing & Attribution Audit

### 3.1 License Status
- An **MIT License** has been established in the repository (`LICENSE`, Copyright (c) 2026 Aman Banik).
- The MIT License is highly permissive, standard in academic and systems benchmarking, and allows external researchers to run, reproduce, adapt, and build upon the benchmark and agent toolkit with standard attribution.

### 3.3 Third-Party Code & Prior Art Attribution
- **Benchmark Source:** [`src/memory_lab.cpp`](src/memory_lab.cpp) is an original 193-line C++20 implementation written for this project utilizing only standard library headers (`<algorithm>`, `<chrono>`, `<vector>`, etc.). No third-party source files are bundled.
- **Prior Art Acknowledged:** The public `README.md` explicitly cites established literature for multi-chain pointer chasing:
  - Algorithmica HPC (*Memory-Level Parallelism*)
  - Daniel Lemire's `testingmlp`
  - Tim Besard's `pChase`

---

## 4. Documentation Architecture & README Transformation

### 4.1 Structural Reorganization
```text
[Repository Root]
├── README.md               <== NEW canonical research overview (Medium article audience)
├── BASE_INSTRUCTIONS.md    <== RENAMED original README (Antigravity Fresh Start agent pack)
├── RESEARCH-INDEX.md       <== Master campaign evidence catalog and navigation
├── AGENT.md                <== Authoritative operating contract for AI agents
└── .agent/                 <== Workflows, rules, templates, and field guide
```

### 4.2 Contents of `BASE_INSTRUCTIONS.md`
- Preserves 100% of the original "Antigravity CPU Memory Lab Agent Pack — Fresh Start" setup guidance.
- Updated line 5 to link cleanly to both [`RESEARCH-INDEX.md`](RESEARCH-INDEX.md) and [`README.md`](README.md).
- Zero workflow steps or setup instructions were discarded or broken.

### 4.3 Contents of New `README.md`
Written specifically for technically curious readers arriving from the Medium article:
1. **Research Motivation:** Explains the Memory Wall, serialized pointer chasing latency ($p_{i+1} = \text{memory}[p_i]$), and how independent memory chains expose memory-level parallelism (MLP).
2. **Experiment Overview:** Summarizes EXP-01 (working-set sweep), EXP-02 (multi-chain concurrency), and EXP-03 Run 2 (interleaved verification retest).
3. **Audited Results:**
   - EXP-02 64 MiB: $13.66\times$ ratio ($C=16$ vs $C=1$), explicitly qualified as an exploratory continuous sweep that was **not retested at $C=16$ in EXP-03**.
   - EXP-03 Run 2 64 MiB: $4.21\times$ overall ratio ($80.91$ vs $19.21\text{ ns/op}$), with within-block speedups ranging from **$3.42\times\text{ to } 4.41\times$** across all 5 balanced blocks (all strictly $> 3.00\times$).
   - EXP-03 32 KiB: $+3.49\%$ kernel equivalence check within the descriptive $\pm 5.0\%$ heuristic band.
4. **Methodological Guardrails:** Clear distinction between amortized wall-clock time and physical DRAM load latency; unmeasured PMU hardware counters under WSL2; warning against pooling cross-experiment baselines.
5. **Verified Reproduction:** Concrete commands for audits, self-tests, and plot generation.
6. **Navigation & Medium Link:** Clear directory tree and editorial placeholder for the forthcoming article.

---

## 5. Research Integrity & Invariant Hashes

All tracked core research artifacts match their established cryptographic baselines byte-for-byte:

| Artifact Path | Verified SHA-256 Digest | Status |
|---|---|:---:|
| [`src/memory_lab.cpp`](src/memory_lab.cpp) | `b4a2b26240633d4546295f2c1b7996ea283aa49a5e4b9fc27fefc836b0bb9e2b` | Invariant Preserved |
| [`memory_lab`](memory_lab) | `9c71a0984e4001bac4a60b6bfcfbcce9e0cd1e760e9024dafc9a042c8cb390a0` | Invariant Preserved |
| [`results/memory_lab.s`](results/memory_lab.s) | `74dd7b0c7c8b046afffdfef9d6fcfcfbb068a16617b48bb150b6bb30493db592` | Invariant Preserved |
| [`lab-notebook/raw/EXP-20261016-03-run2-primary.csv`](lab-notebook/raw/EXP-20261016-03-run2-primary.csv) | `60fc9cc197f68b4f10467b37f230d94eb7241a6f8697215e5261a09d9890647c` | Invariant Preserved |
| [`lab-notebook/raw/EXP-20261016-03-run2-sweep.log`](lab-notebook/raw/EXP-20261016-03-run2-sweep.log) | `42d9ec66b9b68cb45534acd381e5d59405e8bed713ef1b9cc5bb81f80e9d8e00` | Invariant Preserved |
| [`lab-notebook/raw/EXP-20261016-03-primary.csv`](lab-notebook/raw/EXP-20261016-03-primary.csv) | `affea981e534265e9781285ea0dbf8d0ac11759b7c792b5884b7973f29d643b1` | Invariant Preserved |
| [`lab-notebook/raw/EXP-20261016-03-sweep.log`](lab-notebook/raw/EXP-20261016-03-sweep.log) | `ab1faf5d816b9546d132b91b8df027d7f50273e98cfac24863527881abbec6c0` | Invariant Preserved |

---

## 6. Verification Checks & Validation Results

1. **Non-Benchmark Audit Scripts:**
   - `python3 scripts/audit_exp01.py` &rarr; **PASS (Code 0)**
   - `python3 scripts/audit_exp02.py` &rarr; **PASS (Code 0)**
   - `python3 scripts/audit_exp03.py` &rarr; **PASS (Code 0)**
2. **Harness Self-Tests:**
   - `python3 scripts/run_exp03.py --self-test` &rarr; **14/14 PASS (Code 0)**
   - `python3 scripts/audit_exp03.py --self-test` &rarr; **9/9 PASS (Code 0)**
3. **Internal Documentation Link Integrity:**
   - Verified that relative links in [`README.md`](README.md), [`BASE_INSTRUCTIONS.md`](BASE_INSTRUCTIONS.md), [`RESEARCH-INDEX.md`](RESEARCH-INDEX.md), and [`AGENT.md`](AGENT.md) resolve to existing filesystem locations.
   - Verified that `.agent/workflows/` and `.agent/rules/` operate without dependency failures.

---

## 7. Publication Status & Release Completion

1. **Repository License:** Established ([`MIT License`](LICENSE), Copyright (c) 2026 Aman Banik).
2. **Canonical Overview:** Created ([`README.md`](README.md)) with live Medium article link embedded.
3. **Agent Setup:** Preserved ([`BASE_INSTRUCTIONS.md`](BASE_INSTRUCTIONS.md)).
4. **Medium Technical Article:** Live at [https://medium.com/@amanbaniksr75/the-hard-part-wasnt-making-it-faster-it-was-trusting-the-numbers-a3644dc59639](https://medium.com/@amanbaniksr75/the-hard-part-wasnt-making-it-faster-it-was-trusting-the-numbers-a3644dc59639).
