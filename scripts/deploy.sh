#!/bin/bash
# ─────────────────────────────────────────────────────────────
# deploy.sh
# Runs on YOUR LOCAL MACHINE (Git Bash / WSL).
# Transfers portfolio files to EC2 and deploys the container.
#
# First-time setup:
#   bash scripts/deploy.sh --setup
#
# Update / redeploy:
#   bash scripts/deploy.sh
#
# Usage:
#   export EC2_IP=YOUR_EC2_PUBLIC_IP
#   export KEY_PATH=path/to/portfolio-key.pem
#   bash scripts/deploy.sh [--setup]
# ─────────────────────────────────────────────────────────────

set -e

# ── Configuration ─────────────────────────────────────────────
EC2_IP="${EC2_IP:-}"
KEY_PATH="${KEY_PATH:-}"
REMOTE_USER="ubuntu"
REMOTE_DIR="~/portfolio"
IMAGE_NAME="george-koufie-portfolio"
CONTAINER_NAME="portfolio"

# ── Validate inputs ───────────────────────────────────────────
if [[ -z "$EC2_IP" ]]; then
    read -rp "Enter your EC2 public IP: " EC2_IP
fi

if [[ -z "$KEY_PATH" ]]; then
    read -rp "Enter path to your .pem key file: " KEY_PATH
fi

if [[ ! -f "$KEY_PATH" ]]; then
    echo "ERROR: Key file not found at: $KEY_PATH"
    exit 1
fi

# Fix key permissions (required by SSH)
chmod 400 "$KEY_PATH"

SSH_CMD="ssh -i $KEY_PATH -o StrictHostKeyChecking=no $REMOTE_USER@$EC2_IP"
SCP_CMD="scp -i $KEY_PATH -o StrictHostKeyChecking=no"

echo ""
echo "================================================"
echo "  George Koufie Portfolio — Deploy Script"
echo "  Target: $REMOTE_USER@$EC2_IP"
echo "================================================"
echo ""

# ── Step 1: Transfer files to EC2 ────────────────────────────
echo "[1/3] Uploading portfolio files to EC2..."

# Get the project root (one level up from scripts/)
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

$SSH_CMD "mkdir -p $REMOTE_DIR"

# Transfer all required files
$SCP_CMD "$PROJECT_DIR/index.html"   "$REMOTE_USER@$EC2_IP:$REMOTE_DIR/"
$SCP_CMD "$PROJECT_DIR/robots.txt"   "$REMOTE_USER@$EC2_IP:$REMOTE_DIR/"
$SCP_CMD "$PROJECT_DIR/Dockerfile"   "$REMOTE_USER@$EC2_IP:$REMOTE_DIR/"
$SCP_CMD "$PROJECT_DIR/nginx.conf"   "$REMOTE_USER@$EC2_IP:$REMOTE_DIR/"
$SCP_CMD "$PROJECT_DIR/.dockerignore" "$REMOTE_USER@$EC2_IP:$REMOTE_DIR/"
$SCP_CMD -r "$PROJECT_DIR/assets/"  "$REMOTE_USER@$EC2_IP:$REMOTE_DIR/"
$SCP_CMD -r "$PROJECT_DIR/resume/"  "$REMOTE_USER@$EC2_IP:$REMOTE_DIR/"

echo "✓ Files uploaded"
echo ""

# ── Step 2: First-time setup OR redeploy ─────────────────────
if [[ "$1" == "--setup" ]]; then
    echo "[2/3] Running first-time EC2 setup (installing Docker)..."
    $SCP_CMD "$PROJECT_DIR/scripts/ec2-setup.sh" "$REMOTE_USER@$EC2_IP:~/ec2-setup.sh"
    $SSH_CMD "bash ~/ec2-setup.sh"
else
    echo "[2/3] Rebuilding and redeploying container..."
    $SSH_CMD "
        cd $REMOTE_DIR
        docker build -t $IMAGE_NAME .
        docker rm -f $CONTAINER_NAME 2>/dev/null || true
        docker run -d -p 80:80 --name $CONTAINER_NAME --restart always $IMAGE_NAME
    "
    echo "✓ Container redeployed"
fi
echo ""

# ── Step 3: Health check ──────────────────────────────────────
echo "[3/3] Running health check..."
sleep 3

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$EC2_IP" || echo "000")

if [[ "$HTTP_STATUS" == "200" ]]; then
    echo "✓ Health check passed (HTTP $HTTP_STATUS)"
else
    echo "⚠ Health check returned HTTP $HTTP_STATUS — check docker logs portfolio on EC2"
fi
echo ""

# ── Done ──────────────────────────────────────────────────────
echo "================================================"
echo "  Deployment complete!"
echo "  URL: http://$EC2_IP"
echo "================================================"
echo ""
