#!/usr/bin/env bash
cd "$(dirname "$0")/.." && docker compose -f compose.base.yml -f compose.airflow.yml up airflow-init
