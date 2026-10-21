#!/usr/bin/env bash
cd "$(dirname "$0")/.." && docker compose -f compose.base.yml -f compose.airflow.yml stop airflow-api-server airflow-scheduler airflow-dag-processor airflow-db
