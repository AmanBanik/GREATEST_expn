#!/usr/bin/env bash
# Read-only environment snapshot. Does not install, compile, run the benchmark, or alter project files.
set +e
run_check() {
  printf '\n===== COMMAND: %s =====\n' "$*"
  "$@" 2>&1
  status=$?
  printf '[exit_status=%s]\n' "$status"
}
printf 'CPU MEMORY LAB READ-ONLY PREFLIGHT\n'
printf 'timestamp_utc='; date -u '+%Y-%m-%dT%H:%M:%SZ' 2>&1
printf 'working_directory='; pwd 2>&1
run_check uname -a
if [ -r /etc/os-release ]; then run_check cat /etc/os-release; else echo '/etc/os-release unavailable'; fi
if grep -qi microsoft /proc/version 2>/dev/null; then echo 'wsl_detected=yes'; else echo 'wsl_detected=not_detected_by_/proc/version'; fi
if command -v lscpu >/dev/null 2>&1; then run_check lscpu; else echo 'lscpu=not_installed'; fi
if command -v free >/dev/null 2>&1; then run_check free -h; else echo 'free=not_installed'; fi
if command -v g++ >/dev/null 2>&1; then run_check g++ --version; else echo 'g++=not_installed'; fi
if command -v cmake >/dev/null 2>&1; then run_check cmake --version; else echo 'cmake=not_installed'; fi
if command -v make >/dev/null 2>&1; then run_check make --version; else echo 'make=not_installed'; fi
if command -v perf >/dev/null 2>&1; then run_check perf --version; else echo 'perf=not_installed'; fi
if [ -d /sys/bus/event_source/devices ]; then
  printf '\n===== COMMAND: ls /sys/bus/event_source/devices =====\n'
  ls /sys/bus/event_source/devices 2>&1
  printf '[exit_status=%s]\n' "$?"
else echo 'perf_event_sources=not_exposed'; fi
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  run_check git status --short --branch
  run_check git rev-parse HEAD
else echo 'git_repository=not_detected'; fi
printf '\nNOTE: This script does not inspect source code or execute the benchmark. Agent must inspect src/memory_lab.cpp manually before proposing any build/run command.\n'
