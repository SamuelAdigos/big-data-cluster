#!/usr/bin/env bash
cd "$(dirname "$0")/.." && docker compose -f compose.base.yml -f compose.kafka.yml -f compose.seaweedfs.yml -f compose.nifi.yml -f compose.superset.yml -f compose.airflow.yml up -d
