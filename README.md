# COMPX335 SSH Key Sync

This repository manages shared SSH access by keeping a single `authorized_keys` file in GitHub and syncing it to the PI's automatically on boot.

It is designed for Raspberry Pi/Linux hosts where you want team access to stay up to date without manually editing each user account on every device.

## What This Does

- Installs a sync script to `/usr/local/bin/sync-ssh-keys.sh`
- Creates cron jobs that:
	- run once at boot (`@reboot`)
	- run every hour (`0 * * * *`)
- Downloads the latest `authorized_keys` from this repository
- Writes keys into the target user's `~/.ssh/authorized_keys`
- Fixes ownership and permissions (`~/.ssh` = `700`, `authorized_keys` = `600`)
- Logs activity to `/var/log/ssh-keys-sync.log`

## Quick Install

Run the setup script:

```bash
curl -sSL https://raw.githubusercontent.com/Dory74/COMPX335-SSH-Keys/main/setup.sh | sudo bash
```

## Requirements

- A Linux machine (for example, Raspberry Pi OS)
- `sudo` access
- `git` installed
- Outbound internet access to GitHub

## SSH Configuration Note

Make sure public key authentication is enabled in your SSH daemon config.

Check these settings in `/etc/ssh/sshd_config`:

```text
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
```

If you make changes, restart SSH:

```bash
sudo systemctl restart ssh
```

## Verify It Worked

1. Confirm cron entries were created:

```bash
sudo crontab -l
```

2. Check sync log output:

```bash
sudo tail -n 50 /var/log/ssh-keys-sync.log
```

3. Confirm keys exist for the target user:

```bash
sudo ls -l /home/<username>/.ssh/authorized_keys
```

## Updating Keys

To grant access, add the user's **public key** to `authorized_keys` in this repository and merge the change.

The next scheduled sync (or reboot) will apply it automatically.

## Security Rules

- Only add **public** keys (usually starts with `ssh-ed25519` or `ssh-rsa`)
- Never commit a private key
- If a private key is accidentally exposed:
	1. Delete it from all commits/history as soon as possible
	2. Revoke that key
	3. Generate a new key pair

## Troubleshooting

- `Permission denied (publickey)`:
	- Verify SSH daemon settings in `/etc/ssh/sshd_config`
	- Check `~/.ssh` and `authorized_keys` permissions
- No updates applied:
	- Check `/var/log/ssh-keys-sync.log`
	- Manually run: `sudo /usr/local/bin/sync-ssh-keys.sh`
- Wrong user got updated:
	- Re-run setup while logged in as the intended user

## Contributing

Create a pull request with your public key added to `authorized_keys`.

Do not include private keys in issues, pull requests, or commits.