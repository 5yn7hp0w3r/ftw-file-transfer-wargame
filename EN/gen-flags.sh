#!/usr/bin/env bash
# Generate random flag-passwords. level0 is fixed (handed to the player in README).
# Each flag ends with \n so it never sticks to the shell prompt in a terminal.
set -e
cd "$(dirname "$0")"
mkdir -p flags
printf 'start-here\n' > flags/level0
for n in $(seq 1 33); do
    { tr -dc 'a-z0-9' </dev/urandom | head -c 24; echo; } > "flags/level${n}"
done
echo "Flags regenerated. Apply without rebuild:  docker compose restart"
