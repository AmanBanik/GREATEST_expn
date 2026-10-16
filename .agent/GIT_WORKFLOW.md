# Git & GitHub Workflow Extension for CPU Memory Lab

**Target Remote:** `https://github.com/AmanBanik/GREATEST_expn.git`  
**Scope:** Version control, remote synchronization, scientific evidence preservation, and sensitive-data hygiene for the `memory-wall` research project.

---

## 1. Principles & Non-Negotiable Rules

1. **Explicit Human Authorization Gate:**
   - **Never run `git push`, publish code, alter repository visibility, or modify GitHub repository settings without explicit user authorization.**
   - All Git write actions (initializing, branching, staging, committing, pushing) must be explained and approved in advance.
2. **Evidence Preservation Over Repository Aesthetics:**
   - Research data represents scientific evidence. Failed runs, anomalous verifications, exploratory sweeps, and large raw logs must **never be deleted, truncated, or force-reset** to make the repository appear cleaner.
   - Every experiment receives a permanent, immutable record.
3. **No Blind Staging or History Rewriting:**
   - **Never use `git add .` or `git add -A`** without an explicit prior inventory and sensitive-data scan.
   - Do not force-push (`git push --force`), rewrite history, or discard working-tree state (`git reset --hard`, `git clean -fdx`) as an automatic convenience.
4. **Conservative Secret & Identity Hygiene:**
   - Treat command logs, diagnostic traces, and environment snapshots as potentially sensitive.
   - Differentiate strictly between unalterable raw local evidence and publication-ready sanitized artifacts.

---

## 2. Repository Initialization & Remote Configuration Workflow

Before running any Git initialization or configuration commands:

1. **Inspect Existing Git State First:**
   ```bash
   git rev-parse --is-inside-work-tree 2>/dev/null
   git status
   ```
   - Check whether a Git repository is already initialized in this directory or any parent directory.
   - Do **not** assume an empty remote GitHub repository means the local directory is safe to initialize without inspection.
2. **Inspect Current Branch, Remotes, and Working Tree:**
   ```bash
   git branch -a
   git remote -v
   git status --short --ignored
   ```
3. **Verify Remote Configuration:**
   - Check if `origin` is already set:
     ```bash
     git remote get-url origin 2>/dev/null
     ```
   - If `origin` is configured and differs from `https://github.com/AmanBanik/GREATEST_expn.git`, **stop and report the discrepancy**. Never overwrite existing remote configuration silently.
   - If `origin` is absent and user has approved initialization and remote setup:
     ```bash
     git remote add origin https://github.com/AmanBanik/GREATEST_expn.git
     ```

---

## 3. Deliberate Commit Workflow

Always follow this 7-step sequence for every commit:

1. **Inspect Working-Tree Status:**
   ```bash
   git status --short
   ```
2. **Review Untracked and Modified Diffs:**
   ```bash
   git status -u
   git diff
   ```
   Verify exactly which files are changed and whether new untracked files are intended for version control.
3. **Scan Files for Secrets and Machine-Specific Details:**
   - Check for tokens, passwords, private keys (`*.key`, `*.pem`), credentials, or `.env` files.
   - Check for host identifiers, internal network paths, or private user details in logs.
4. **Stage Only Explicitly Reviewed Paths:**
   ```bash
   git add path/to/file1 path/to/file2
   ```
   Do **not** run blanket `git add .`.
5. **Review Staged Diff and File List:**
   ```bash
   git status --short
   git diff --cached
   ```
   Verify that only intended files are staged and no unintended build artifacts, binaries, or secret files are present.
6. **Commit with a Specific Descriptive Message:**
   ```bash
   git commit -m "<Component>: <Action in imperative mood>"
   ```
   Describe the actual scientific or code change (e.g. `Docs: Finalize EXP-20261016-02 audit and add closure note`).
7. **Verify Post-Commit State:**
   ```bash
   git log -1 --stat
   git status
   ```

---

## 4. Pre-Push Review & Publication Workflow

Pushing transmits repository state to a remote server. Before every push:

1. **Verify Target & Branch:**
   ```bash
   git remote -v
   git branch --show-current
   ```
   Confirm remote points to `https://github.com/AmanBanik/GREATEST_expn.git` and the intended branch (e.g. `main`).
2. **Inspect Outgoing Commits & Changes:**
   ```bash
   git log origin/<branch>..HEAD --stat
   # Or for initial push:
   git log --stat
   ```
   Review every commit message and touched file scheduled for publication.
3. **Verify Ignore Rules & Staging Hygiene:**
   Ensure reproducible binaries (e.g. `memory_lab`), temporary IDE state, and local editor swap files are not staged or committed.
4. **Resolve Sensitivity Concerns:**
   If any unreviewed machine traces or personal host paths exist in outgoing commits, report them to the user. Stop before pushing if sensitivity is material.
5. **Obtain Explicit Authorization:**
   Present the commit count, branch, and remote URL to the user and request permission to push.
6. **Execute Standard Non-Force Push:**
   ```bash
   git push origin <branch>
   ```
   Never use `--force` unless the user explicitly mandates an exceptional history rewrite.

---

## 5. Research Evidence & Provenance Rules

Scientific integrity requires that version control faithfully reflects empirical progress:

### What Belongs in Version Control
- **Core Source Code & Build Instructions:** `src/memory_lab.cpp`, `Makefile`, build flags.
- **Assembly Inspections:** `results/memory_lab.s`, compiler output audits.
- **Experimental Protocols & Hypotheses:** `lab-notebook/experiments/*-protocol.md`, `HYPOTHESES.md`, `INDEX.md`.
- **Raw Empirical Evidence:** `lab-notebook/raw/*.csv`, `lab-notebook/raw/*.log`. (Do **not** exclude files merely because they have `.csv` or `.log` extensions!).
- **Audits & Closure Notes:** `AUDIT-*.md`, `*-record.md`, `*-closure.md`.
- **Analysis & Plotting Scripts:** `scripts/*.py`, `scripts/*.cpp`.
- **Publication Figures:** `results/plots/*.png`, `results/plots/*.svg`.
- **Environment Snapshots & Provenance:** `lab-notebook/environment/ENV-*.md`, session logs.

### Evidence Preservation Standards
1. **Never Silently Overwrite Historical Data:** If a parser bug or metric definition is corrected, add an audit note or post-run analysis; do not modify historical raw CSVs or logs.
2. **Distinct Run Statuses:** Clearly preserve the separation between planned runs, completed runs, failed configurations, and post-sweep verification re-tests.
3. **Reproducible Provenance:** Track SHA-256 hashes of source, binaries, and raw data files across experiment records.
4. **Reproducible Binaries:** Do not commit compiled machine executables (`memory_lab`) to Git when they are fully reproducible from committed source and compiler flags.

---

## 6. Sensitive-Data Handling & Secret Hygiene

### Prohibited Artifacts
- API tokens, passwords, private keys (`id_rsa`, `*.pem`, `*.key`), credentials, cloud access keys.
- Local configuration files containing credentials or secrets (`.env`, `.env.local`, `credentials.json`).

### Diagnostic & Environment Log Review
- Raw command logs and environment dumps may contain machine-specific hostnames (`AlphOmen`), Linux usernames (`amans`), or local path hierarchies (`/home/amans/...`).
- **Do not alter the sole original copy of raw evidence** to sanitize it. The raw local evidence must remain bit-for-bit identical to its recorded SHA-256 hash.
- If machine identifiers must be redacted for public presentation, create a documented, sanitized copy (e.g. `lab-notebook/environment/ENV-public-sanitized.md`) and version-control the sanitized version while keeping the raw file documented locally.
- When in doubt about whether an environment detail is sensitive, **ask the user** before staging.

### Git Ignore Limitations & Remediation
- `.gitignore` prevents **new untracked files** from being added by default; it does **not** retroactively ignore or remove files that are already tracked by Git.
- If a secret or sensitive credential is accidentally committed:
  1. **Stop immediately.** Do not push to remote.
  2. Alert the user and recommend immediate **secret rotation** (assume any committed secret is compromised).
  3. Amend or reset the local commit before pushing, noting that removing it in a subsequent commit leaves the secret accessible in Git history.

---

## 7. Context Retrieval & Research Navigation

To make evidence immediately accessible for writing without cluttering context windows:
- Maintain a compact, root-level [`RESEARCH-INDEX.md`](file:///home/amans/Devfield2/experiment/memory-wall/RESEARCH-INDEX.md).
- The index acts as a central table of contents linking to:
  - Experiment Protocols and Closure Records
  - Raw CSV evidence and console logs
  - Reproducible plotting scripts and output figures
  - Assembly audits and environment baselines
  - Known methodological limitations and active unresolved questions
- Consult `RESEARCH-INDEX.md` when preparing technical writing or drafting Medium articles to retrieve exact verified evidence paths.
