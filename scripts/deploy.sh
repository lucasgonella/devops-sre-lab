#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

trap 'echo "Erro na linha $LINENO. Deploy interrompido." >&2' ERR

echo "Validando configuração do Compose..."
docker compose config >/dev/null

PREVIOUS_TAG=""
CONTAINER_ID="$(docker compose ps -q api)"

if [[ -n "$CONTAINER_ID" ]]; then
  CURRENT_IMAGE="$(docker inspect --format '{{.Config.Image}}' "$CONTAINER_ID")"
  PREVIOUS_TAG="${CURRENT_IMAGE##*:}"
  echo "Versão anterior: $PREVIOUS_TAG"
else
  echo "Nenhuma versão anterior encontrada. Primeiro deploy sem rollback."
fi

echo "Baixando imagem..."
docker compose pull

echo "Atualizando aplicação..."
docker compose up -d

wait_for_endpoint() {
  local endpoint="$1"

  echo "Aguardando ${endpoint}..."

  for attempt in {1..15}; do
    if curl -fsS "http://localhost:8000${endpoint}" >/dev/null; then
      echo "${endpoint} respondeu com sucesso."
      return 0
    fi

    if [[ "$attempt" -eq 15 ]]; then
      echo "${endpoint} não respondeu após 15 tentativas." >&2
      return 1
    fi

    sleep 2
  done
}

rollback() {
  if [[ -z "$PREVIOUS_TAG" ]]; then
    echo "Rollback indisponível: não existe versão anterior." >&2
    return 1
  fi

  echo "Iniciando rollback para $PREVIOUS_TAG..."

  export IMAGE_TAG="$PREVIOUS_TAG"

  docker compose pull
  docker compose up -d

  wait_for_endpoint "/health"
  wait_for_endpoint "/ready"

  echo "Rollback concluído com sucesso."
}

if ! wait_for_endpoint "/health" || ! wait_for_endpoint "/ready"; then
  echo "Validação do deploy falhou." >&2
  rollback
  exit 1
fi

echo "Deploy concluído com sucesso."
