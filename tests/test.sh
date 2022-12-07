#!/usr/bin/env bash
set -o errexit

k6 run tests/load.js
