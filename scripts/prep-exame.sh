#!/usr/bin/env bash
# scripts/prep-exame.sh
# Carga as imaxes do tar + arrinca o cluster + importa a caché Ivy no notebook.
#
# Requisitos:
# - Os tar están no directorio TAR_DIR (por defecto ~/exames-bigdata):
#   - bda-core-images.tar
#   - ivy2-offline.tar
#
# Execución:
#   ./scripts/prep-exame.sh
#   TAR_DIR=/Volumes/USB/exames-bigdata ./scripts/prep-exame.sh

set -euo pipefail

echo "== Preparacion do contorno (BDA) =="

# Ir ao directorio raiz do repo (pai de /scripts)
cd "$(dirname "$0")/.."

TAR_DIR="${TAR_DIR:-$HOME/exames-bigdata}"
IMAGES_TAR="$TAR_DIR/bda-core-images.tar"
IVY_TAR="$TAR_DIR/ivy2-offline.tar"

[ -f "$IMAGES_TAR" ] || { echo "Non se atopa: $IMAGES_TAR" >&2; exit 1; }
[ -f "$IVY_TAR" ]    || { echo "Non se atopa: $IVY_TAR" >&2; exit 1; }

if ! docker info >/dev/null 2>&1; then
  echo "Docker non responde. Asegurarse de que Docker Desktop / Rancher Desktop esta iniciado." >&2
  exit 1
fi

echo "1) Cargando imaxes Docker desde $IMAGES_TAR ..."
docker load -i "$IMAGES_TAR"

echo "2) Arrincando o cluster (compose.base + compose.kafka) ..."
docker compose -f compose.base.yml -f compose.kafka.yml up -d

echo "3) Agardando a que exista o contedor 'spark-notebook' ..."
for i in $(seq 1 30); do
  if docker ps -a --format '{{.Names}}' | grep -qx spark-notebook; then
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "Non apareceu 'spark-notebook' en 60 s. Revisa: docker compose ps / docker logs spark-notebook" >&2
    exit 1
  fi
  sleep 2
done

echo "4) Importando caché Ivy no contedor (desde $IVY_TAR) ..."
docker cp "$IVY_TAR" spark-notebook:/tmp/ivy2-offline.tar
docker exec spark-notebook bash -lc "tar -C /home/hadoop -xf /tmp/ivy2-offline.tar && chown -R 1000:1000 /home/hadoop/.ivy2"

echo "5) Proba rapida (Spark non deberia descargar nada) ..."
docker exec -u 1000:1000 spark-notebook bash -lc "spark-shell -e 'println(\"ivy ok\")'"

echo
echo "Listo. Abrir no navegador: http://localhost:8888"
echo "Para parar todo: ./scripts/down-all.sh"
