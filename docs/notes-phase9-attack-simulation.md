# Phase 9 — Full Attack Simulation (Mandatory)

Script: `scripts/attack-simulation.sh`
Full output: `docs/screenshots/phase9-attack-simulation-output.txt`
Tetragon raw events: `docs/screenshots/phase9-tetragon-raw-events.log`
Tetragon filtered extract: `docs/screenshots/phase9-tetragon-events-extract.txt`

## Attack 1: Shell spawn inside "compromised" container
Target: demo/database pod (a container that should never spawn a shell
in production).

    kubectl exec -n demo deploy/database -- sh -c "echo ATTACKER_SHELL_ACTIVE; id; hostname"

Result: shell executed. Tetragon's `detect-shell-spawn` TracingPolicy
(kprobe on sys_execve, matching /bin/sh and /bin/bash) captured the
process execution with full lineage - parent process (kubectl exec ->
containerd-shim -> runc -> sh), command line, and container/pod identity
(database-5c59757cbb-gtl4v) - visible in the Tetragon event stream.

## Attack 2: Sensitive file access (/etc/shadow)
Target: same pod, running as root (uid 0) to rule out standard Linux
file permissions as the blocker.

    kubectl exec -n demo deploy/database -- sh -c "cat /etc/shadow; echo EXIT_CODE:$?"

Result:
    Killed
    EXIT_CODE:137

Exit code 137 = SIGKILL. The `block-sensitive-file-access` TracingPolicy
(kprobe on security_file_permission, matching /etc/shadow) killed the
process at the kernel/eBPF layer before any file content could be read
or returned to the application - full prevention, not just detection.
This worked even for the root user inside the container.

## Attack 3: Network policy violation (Cilium)
    kubectl exec -n demo deploy/frontend -- curl -s -m 3 http://database:5432

Result: command terminated with exit code 28 (timeout) - connection
never reached the destination pod. Confirmed via Hubble in Phase 6
(docs/screenshots/phase6-hubble-cli-drop.txt) showing the flow was
DROPPED at ingress before reaching the database pod's application layer.

## Summary
All three attacks were detected/blocked purely at the kernel level via
eBPF (Tetragon for process/file syscalls, Cilium for network policy),
with zero modification to any application code or container image.
