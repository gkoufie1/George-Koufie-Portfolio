#!/bin/bash
# ─────────────────────────────────────────────────────────────
# ci-server-setup.sh
# Runs on your CI EC2 instance (t3.medium).
# Installs Docker, Docker Compose, and starts Jenkins + SonarQube.
# Usage: bash ci-server-setup.sh
# ─────────────────────────────────────────────────────────────

set -e

echo ""
echo "================================================"
echo "  CI Server Setup — Jenkins + SonarQube"
echo "================================================"
echo ""

# ── Step 1: System update ─────────────────────────────────
echo "[1/6] Updating system..."
sudo apt update -y && sudo apt upgrade -y
echo "✓ Done"
echo ""

# ── Step 2: Install Docker ────────────────────────────────
echo "[2/6] Installing Docker..."
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
echo "✓ Docker installed"
echo ""

# ── Step 3: Install Docker Compose ───────────────────────
echo "[3/6] Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
echo "✓ Docker Compose installed"
echo ""

# ── Step 4: Tune kernel for SonarQube ────────────────────
# SonarQube requires vm.max_map_count >= 524288
echo "[4/6] Tuning kernel settings for SonarQube..."
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072
echo "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=131072"      | sudo tee -a /etc/sysctl.conf
echo "✓ Kernel tuned"
echo ""

# ── Step 5: Install sonar-scanner ────────────────────────
echo "[5/6] Installing sonar-scanner..."
SONAR_SCANNER_VERSION="6.2.1.4610"
cd /tmp
wget -q "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux-x64.zip"
sudo apt install -y unzip
unzip -q "sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux-x64.zip"
sudo mv "sonar-scanner-${SONAR_SCANNER_VERSION}-linux-x64" /opt/sonar-scanner
sudo ln -sf /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
sonar-scanner --version
echo "✓ sonar-scanner installed"
echo ""

# ── Step 6: Start Jenkins + SonarQube ────────────────────
echo "[6/6] Starting Jenkins and SonarQube..."
cd ~/portfolio
newgrp docker <<EOF
docker-compose up -d
EOF
echo "✓ Services started"
echo ""

# ── Done ──────────────────────────────────────────────────
CI_IP=$(curl -s http://checkip.amazonaws.com)
echo "================================================"
echo "  CI Server is ready!"
echo ""
echo "  Jenkins:   http://${CI_IP}:8080"
echo "  SonarQube: http://${CI_IP}:9000"
echo ""
echo "  Wait ~2 minutes for services to fully start."
echo ""
echo "  Jenkins initial password:"
echo "  docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
echo "================================================"
echo ""