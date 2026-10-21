#!/usr/bin/env bash
cd "$(dirname "$0")/.." && docker compose -f compose.base.yml -f compose.seaweedfs.yml -f compose.airflow.yml up -d namenode datanode resourcemanager nodemanager spark-history notebook seaweedfs airflow-db airflow-api-server airflow-scheduler airflow-dag-processor
