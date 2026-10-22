#!/usr/bin/env bash
cd "$(dirname "$0")/.." && docker compose -f compose.base.yml -f compose.seaweedfs.yml -f compose.nifi.yml up -d
