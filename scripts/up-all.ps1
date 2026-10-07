docker compose -f ..\compose.base.yml -f ..\compose.kafka.yml -f ..\compose.seaweedfs.yml -f ..\compose.nifi.yml -f ..\compose.superset.yml .\compose.airflow.yml up -d
