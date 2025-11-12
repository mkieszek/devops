#!/bin/bash

# Purpose: Install Docker Engine, CLI, containerd, buildx, and compose on Ubuntu
# Notes:
# - Requires sudo privileges
# - Targets Ubuntu (APT-based). For other distros, use respective instructions.
# - Based on official Docker installation steps for Ubuntu
#
# Usage:
#   sudo ./install-docker-ubuntu.sh
#
# Exit on error and treat unset variables as an error
set -euo pipefail

# Update package list
sudo apt-get update

# Install packages for HTTPS APT repositories
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository to APT sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list again to include the new repo
sudo apt-get update

# Install Docker Engine, CLI, containerd, and plugins
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify installation by running a test image
sudo docker run hello-world

# Optionally allow running docker without sudo by adding the current user to the docker group
# Use SUDO_USER when available (script typically run with sudo), fall back to $USER otherwise
TARGET_USER="${SUDO_USER:-$USER}"
if id -nG "$TARGET_USER" | grep -qvE '(^|\s)docker(\s|$)'; then
  echo "Adding user '$TARGET_USER' to the 'docker' group..."
  sudo usermod -aG docker "$TARGET_USER"
  echo "User '$TARGET_USER' has been added to the 'docker' group."
  echo "Note: You must log out and back in, or run 'newgrp docker', for this to take effect."
else
  echo "User '$TARGET_USER' already belongs to the 'docker' group."
fi
