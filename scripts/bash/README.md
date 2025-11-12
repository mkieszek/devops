# Bash Scripts

This folder contains Bash scripts for Linux automation.

## install-docker-ubuntu.sh

Installs Docker Engine, CLI, containerd, Buildx, and Compose on Ubuntu using the official Docker APT repository.

- Supported OS: Ubuntu (APT-based)
- Requirements: `sudo` privileges and outbound internet access

### Usage

```bash
# From repository root
sudo ./scripts/bash/install-docker-ubuntu.sh
```

### What the script does
- Configures Docker's official APT repository and GPG key
- Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, and `docker-compose-plugin`
- Verifies installation by running `hello-world`
- Adds your user to the `docker` group so you can run Docker without `sudo`

### Notes
- If Docker is already installed, the packages will be kept or upgraded according to APT
- For non-Ubuntu distributions, follow the official Docker docs for your OS
- The script adds the invoking user (or `$SUDO_USER` if run via `sudo`) to the `docker` group. You must log out and back in, or run `newgrp docker`, for this to take effect.

### Verify non-sudo usage (after re-login/newgrp)

```bash
docker run hello-world
```
