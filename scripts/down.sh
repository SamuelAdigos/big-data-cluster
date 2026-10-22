#!/usr/bin/env bash
cd "$(dirname "$0")/.." && docker compose -f compose.base.yml down
