#!/bin/bash
set -e

echo "===================================================="
echo "  ATTACK SIMULATION — eBPF Runtime Security Test"
echo "===================================================="
echo ""
echo "Target: demo/database pod (running as root, uid 0)"
echo ""

echo "---- [1/3] Starting Tetragon event capture ----"
kubectl exec -n kube-system tetragon-2mjqf -c tetragon -- tetra getevents -o compact > /tmp/attack-sim-tetragon.log 2>&1 &
TETRA_PID=$!
sleep 2

echo ""
echo "---- [2/3] ATTACK 1: Spawning a shell inside compromised container ----"
kubectl exec -n demo deploy/database -- sh -c "echo ATTACKER_SHELL_ACTIVE; id; hostname" 2>&1 || true

echo ""
echo "---- [3/3] ATTACK 2: Attempting to read /etc/shadow ----"
kubectl exec -n demo deploy/database -- sh -c "cat /etc/shadow; echo EXIT_CODE:\$?" 2>&1 || true

sleep 3
kill $TETRA_PID 2>/dev/null || true

echo ""
echo "===================================================="
echo "  NETWORK ATTACK: frontend -> database (policy denied)"
echo "===================================================="
kubectl exec -n demo deploy/frontend -- curl -s -m 3 http://database:5432 2>&1 || echo "Connection blocked (exit code: $?)"

echo ""
echo "===================================================="
echo "  Simulation complete. Tetragon events saved to:"
echo "  /tmp/attack-sim-tetragon.log"
echo "===================================================="
