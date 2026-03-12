#!/bin/bash
# Syncs SSH keys from a GitHub repo to the Pi's authorized_keys

REPO_URL="https://github.com/Dory74/COMPX335-SSH-Keys.git"
TEMP_DIR="/tmp/ssh-keys-sync"
LOG_FILE="/var/log/ssh-keys-sync.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Detect the real user (works even when run as root via cron)
if [ -n "$SUDO_USER" ]; then
    CURRENT_USER="$SUDO_USER"
else
    CURRENT_USER=$(logname 2>/dev/null || who am i | awk '{print $1}' || whoami)
fi

HOME_DIR=$(getent passwd "$CURRENT_USER" | cut -d: -f6)
AUTH_KEYS="$HOME_DIR/.ssh/authorized_keys"

echo "[$TIMESTAMP] Starting SSH key sync for user: $CURRENT_USER" >> "$LOG_FILE"

# Clone the repo
rm -rf "$TEMP_DIR"
git clone "$REPO_URL" "$TEMP_DIR" >> "$LOG_FILE" 2>&1

if [ $? -ne 0 ]; then
    echo "[$TIMESTAMP] ERROR: Failed to clone repo" >> "$LOG_FILE"
    exit 1
fi

# Ensure .ssh dir exists with correct permissions
mkdir -p "$HOME_DIR/.ssh"
chmod 777 -R "$HOME_DIR/.ssh"

# Copy keys
cat "$TEMP_DIR/authorized_keys" > "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"
chown "$CURRENT_USER:$CURRENT_USER" "$AUTH_KEYS"

# Cleanup
rm -rf "$TEMP_DIR"

echo "[$TIMESTAMP] Done. Keys written to $AUTH_KEYS" >> "$LOG_FILE"