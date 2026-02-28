#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults (override via env vars if needed)
BACKEND_HOST="${BACKEND_HOST:-3.36.208.227}"
BACKEND_USER="${BACKEND_USER:-ec2-user}"
SSH_KEY_PATH="${SSH_KEY_PATH:-$ROOT_DIR/LightsailDefaultKey-ap-northeast-2.pem}"
BACKEND_REMOTE_DIR="${BACKEND_REMOTE_DIR:-/home/ec2-user/chickenmap-back}"
BACKEND_CONTAINER_NAME="${BACKEND_CONTAINER_NAME:-chickenmap-back}"
BACKEND_IMAGE_NAME="${BACKEND_IMAGE_NAME:-chickenmap-back:latest}"
BACKEND_PORT_BIND="${BACKEND_PORT_BIND:-2026:8000}"

DEPLOY_FRONT=false
DEPLOY_BACK=false

print_usage() {
  cat <<EOF
Usage: ./deploy.sh [--all | --front | --back]

Options:
  --all    Deploy frontend + backend (default)
  --front  Deploy frontend only (Firebase Hosting)
  --back   Deploy backend only (EC2 via SSH)
  -h, --help

Env overrides:
  BACKEND_HOST
  BACKEND_USER
  SSH_KEY_PATH
  BACKEND_REMOTE_DIR
  BACKEND_CONTAINER_NAME
  BACKEND_IMAGE_NAME
  BACKEND_PORT_BIND
EOF
}

if [[ $# -eq 0 ]]; then
  DEPLOY_FRONT=true
  DEPLOY_BACK=true
else
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all)
        DEPLOY_FRONT=true
        DEPLOY_BACK=true
        shift
        ;;
      --front)
        DEPLOY_FRONT=true
        shift
        ;;
      --back)
        DEPLOY_BACK=true
        shift
        ;;
      -h|--help)
        print_usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        print_usage
        exit 1
        ;;
    esac
  done
fi

if [[ "$DEPLOY_FRONT" == false && "$DEPLOY_BACK" == false ]]; then
  echo "Nothing to deploy."
  print_usage
  exit 1
fi

deploy_frontend() {
  echo "[deploy] Frontend (Firebase) start"
  cd "$ROOT_DIR/front"
  ./scripts/deploy_web.sh
  echo "[deploy] Frontend done: https://chickenmap.web.app"
}

deploy_backend() {
  echo "[deploy] Backend (EC2) start"

  if [[ ! -f "$SSH_KEY_PATH" ]]; then
    echo "SSH key not found: $SSH_KEY_PATH"
    exit 1
  fi

  # 1) Sync code (do not overwrite remote .env and data dir)
  rsync -az --delete \
    -e "ssh -i $SSH_KEY_PATH -o StrictHostKeyChecking=no" \
    --exclude '.env' \
    --exclude '.venv' \
    --exclude '__pycache__' \
    --exclude '.git' \
    --exclude 'data' \
    --exclude '*.pyc' \
    "$ROOT_DIR/back/" \
    "${BACKEND_USER}@${BACKEND_HOST}:${BACKEND_REMOTE_DIR}/"

  # 2) Build + restart container
  ssh -i "$SSH_KEY_PATH" "${BACKEND_USER}@${BACKEND_HOST}" "
    set -euo pipefail
    cd '${BACKEND_REMOTE_DIR}'
    docker build -t '${BACKEND_IMAGE_NAME}' .
    docker rm -f '${BACKEND_CONTAINER_NAME}' || true
    docker run -d \
      --name '${BACKEND_CONTAINER_NAME}' \
      --restart unless-stopped \
      -p '${BACKEND_PORT_BIND}' \
      --env-file .env \
      -v '${BACKEND_REMOTE_DIR}/data:/app/data' \
      '${BACKEND_IMAGE_NAME}'
    sleep 2
    curl -fsS 'http://127.0.0.1:${BACKEND_PORT_BIND##*:}/api/chickenmap/rankings' >/dev/null
    docker ps --filter name='${BACKEND_CONTAINER_NAME}' --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
  "

  echo "[deploy] Backend done: https://${BACKEND_HOST}.nip.io/api/chickenmap/rankings"
}

if [[ "$DEPLOY_FRONT" == true ]]; then
  deploy_frontend
fi

if [[ "$DEPLOY_BACK" == true ]]; then
  deploy_backend
fi

echo "[deploy] Completed."
