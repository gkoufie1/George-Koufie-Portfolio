#!/bin/bash
# ─────────────────────────────────────────────────────────────
# ec2-setup.sh
# Runs ON the EC2 instance.
# Installs Docker, builds the portfolio image, and starts it.
# Usage: bash ec2-setup.sh
# ─────────────────────────────────────────────────────────────

set -e  # Exit immediately if any command fails

echo ""
echo "================================================"
echo "  George Koufie Portfolio — EC2 Setup Script"
echo "================================================"
echo ""

# ── Step 1: Update system packages ──────────────────────────
echo "[1/5] Updating system packages..."
sudo apt update -y && sudo apt upgrade -y
echo "✓ System updated"
echo ""

# ── Step 2: Install Docker ───────────────────────────────────
echo "[2/5] Installing Docker..."
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
echo "✓ Docker installed and running"
echo ""

# ── Step 3: Verify Docker ────────────────────────────────────
echo "[3/5] Docker version:"
docker --version
echo ""

# ── Step 4: Build the Docker image ──────────────────────────
echo "[4/5] Building Docker image..."
cd ~/portfolio
docker build -t george-koufie-portfolio .
echo "✓ Image built successfully"
echo ""

# ── Step 5: Run the container ────────────────────────────────
echo "[5/5] Starting portfolio container..."

# Stop and remove existing container if running
if docker ps -a --format '{{.Names}}' | grep -q "^portfolio$"; then
    echo "  → Removing existing container..."
    docker rm -f portfolio
fi

docker run -d \
    -p 80:80 \
    --name portfolio \
    --restart always \
    george-koufie-portfolio

echo "✓ Container running"
echo ""

# ── Done ─────────────────────────────────────────────────────
EC2_IP=$(curl -s http://checkip.amazonaws.com)
echo "================================================"
echo "  Portfolio is LIVE!"
echo "  URL: http://${EC2_IP}"
echo "================================================"
echo ""
echo "Useful commands:"
echo "  docker ps                  → check container status"
echo "  docker logs portfolio      → view logs"
echo "  docker stop portfolio      → stop the site"
echo "  docker start portfolio     → start the site"
echo ""
