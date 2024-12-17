#!/bin/bash

set -euo pipefail

launch_anvil() {
  anvil&
  ANVIL_PID=$!
  sleep 2
}

# One of the default senders
PRIVATE_KEY=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
SENDER=0x70997970C51812dc3A010C7d01b50e0d17dc79C8

run_forge_script() {
  forge clean
  forge script \
    --sender ${SENDER} \
    --private-key ${PRIVATE_KEY} \
    --broadcast \
    --rpc-url localhost:8545 \
    CounterScript
}

cleanup() {
  kill ${ANVIL_PID}
}
trap cleanup EXIT

launch_anvil
cast rpc anvil_dumpState > dumpstate1.txt
cleanup

launch_anvil
cast rpc anvil_dumpState > dumpstate2.txt
cleanup

echo "Blank anvil state still has a large diff"
diff dumpstate1.txt dumpstate2.txt

launch_anvil
run_forge_script
cast rpc anvil_dumpState > dumpstate3.txt
cleanup

launch_anvil
run_forge_script
cast rpc anvil_dumpState > dumpstate4.txt
cleanup

echo "Anvil state after script still has a large diff"
diff dumpstate3.txt dumpstate4.txt
