#!/bin/bash
set -x
set -e

# Format code, compile contracts, and run tests.
forge fmt
forge build
forge test -vvvv

# Get the first private key from Anvil.
# From the logs, look at the "Private Keys" section, print the next 3 lines,
# take the last line (hopefully the first private key entry), and then print
# the second "thing" (space separated item).
#ANVIL_PRIV_KEY=$(docker logs anvil-node 2>&1 | grep -A 3 "Private Keys" | tail -n 1 | awk '{print $2}')


# Deploy your Counter
forge script script/Counter.s.sol:CounterScript \
    --rpc-url http://anvil-node:8545 \
    --private-key ${ANVIL_PRIV_KEY} --broadcast