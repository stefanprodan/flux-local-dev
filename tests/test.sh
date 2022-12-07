#!/usr/bin/env bash
set -o errexit

k6 run --duration=30s --vus=10 tests/load.js
