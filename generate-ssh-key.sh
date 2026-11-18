#!/bin/bash
set -e

SSH_DIR="/var/jenkins_home/.ssh"
KEY_PATH="${SSH_DIR}/id_ed25519"
PUB_PATH="${KEY_PATH}.pub"

# Ensure the .ssh directory exists and has the right permissions
mkdir -p "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

# Generate the SSH key only if it doesn't exist yet (idempotent)
if [ ! -f "${KEY_PATH}" ]; then
    echo "============================================================"
    echo " Generating a new SSH key for GitHub access..."
    echo "============================================================"
    ssh-keygen -t ed25519 -C "jenkins@github" -f "${KEY_PATH}" -N ""
    chmod 600 "${KEY_PATH}"
    chmod 644 "${PUB_PATH}"
else
    echo "============================================================"
    echo " SSH key already exists, skipping generation."
    echo "============================================================"
fi

# Add GitHub host keys to known_hosts (idempotent)
if [ ! -f "${SSH_DIR}/known_hosts" ] || ! grep -q "github.com" "${SSH_DIR}/known_hosts"; then
    echo "Adding github.com to known_hosts..."
    if ! ssh-keyscan -t ed25519,rsa github.com >> "${SSH_DIR}/known_hosts" 2>/dev/null; then
        echo "WARNING: ssh-keyscan failed; GitHub SSH host key was not added." >&2
    fi
    chmod 600 "${SSH_DIR}/known_hosts"
fi

# Fix ownership only when running as root. The Jenkins image normally runs
# as the unprivileged jenkins user, so this is usually a no-op.
if [ "$(id -u)" = "0" ]; then
    chown -R jenkins:jenkins "${SSH_DIR}"
fi

echo ""
echo "============================================================"
echo " PUBLIC KEY --> add this to GitHub:"
echo "   GitHub > Settings > SSH and GPG keys > New SSH key"
echo "============================================================"
cat "${PUB_PATH}"
echo "============================================================"
echo ""
echo "============================================================"
echo " PRIVATE KEY --> add this to Jenkins ('git-ssh-credentials'):"
echo "============================================================"
cat "${KEY_PATH}"
echo "============================================================"
echo ""