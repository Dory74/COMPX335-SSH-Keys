#!/bin/bash
# Download and install the sync script
curl -sSL https://raw.githubusercontent.com/Dory74/COMPX335-SSH-Keys/main/sync-ssh-keys.sh -o /usr/local/bin/sync-ssh-keys.sh
chmod +x /usr/local/bin/sync-ssh-keys.sh

# Add cron jobs if not already there
(sudo crontab -l 2>/dev/null | grep -q 'sync-ssh-keys') || \
(sudo crontab -l 2>/dev/null; echo "@reboot sleep 30 && /usr/local/bin/sync-ssh-keys.sh"; echo "0 * * * * /usr/local/bin/sync-ssh-keys.sh") | sudo crontab -

echo "Setup complete! Running initial sync..."
sudo /usr/local/bin/sync-ssh-keys.sh
cat /var/log/ssh-keys-sync.log