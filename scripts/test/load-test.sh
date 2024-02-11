#!/usr/bin/env bash
set -o errexit

k6 run --duration=30s --vus=10 scripts/test/k6/load.js
