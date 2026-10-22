#!/usr/bin/env bash
set -euo pipefail

IMAGES=(
  adbgonzalez/spark:4.1.1-py312
  adbgonzalez/spark-notebook:4.1.1-py312
  adbgonzalez/hadoop:3.4.3-py312
  adbgonzalez/kafka:3.9
  adbgonzalez/airflow:3.1.8
)

for image in "${IMAGES[@]}"; do
  echo
  echo "> docker pull --platform linux/amd64 $image"
  docker pull --platform linux/amd64 "$image"
done

echo
echo "Imaxes actualizadas."
