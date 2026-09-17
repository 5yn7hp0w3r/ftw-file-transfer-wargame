#!/usr/bin/env bash
# Генерирует случайные пароли-флаги. level0 фиксирован (выдаётся студенту в README).
# Каждый флаг заканчивается \n — чтобы в терминале не слипался с приглашением.
set -e
cd "$(dirname "$0")"
mkdir -p flags
printf 'start-here\n' > flags/level0
for n in $(seq 1 33); do
    { tr -dc 'a-z0-9' </dev/urandom | head -c 24; echo; } > "flags/level${n}"
done
echo "Флаги перегенерированы. Примени без пересборки:  docker compose restart"
