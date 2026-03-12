#!/bin/bash
# Download and install the sync script
curl -sSL https://raw.githubusercontent.com/Dory74/COMPX335-SSH-Keys/main/sync-ssh-keys.sh -o /usr/local/bin/sync-ssh-keys.sh
chmod +x /usr/local/bin/sync-ssh-keys.sh

# Get the actual logged in user dynamically
ACTUAL_USER=$(logname 2>/dev/null || who | awk 'NR==1{print $1}')

echo "Installing for user: $ACTUAL_USER"

# Add cron jobs if not already there, passing the user explicitly
(sudo crontab -l 2>/dev/null | grep -q 'sync-ssh-keys') || \
(sudo crontab -l 2>/dev/null; echo "@reboot sleep 30 && SUDO_USER=$ACTUAL_USER /usr/local/bin/sync-ssh-keys.sh"; echo "0 * * * * SUDO_USER=$ACTUAL_USER /usr/local/bin/sync-ssh-keys.sh") | sudo crontab -

echo "Setup complete! Running initial sync..."
sudo SUDO_USER=$ACTUAL_USER /usr/local/bin/sync-ssh-keys.sh
cat /var/log/ssh-keys-sync.log