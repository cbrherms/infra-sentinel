# infra-sentinel

GitOps config for **sentinel-01** - a micro PC running Ubuntu Server LTS.

Roles:
- **base** - admin user, SSH hardening, unattended-upgrades, ansible-pull timer
- **nut_build** - compiles NUT + libmodbus from source (required for `apc_modbus` USB support)
- **nut_server** - NUT config and services; monitors 3 APC UPS devices, serves data to LAN
- **kiosk** - full-screen Grafana dashboard via cage (Wayland) + Chromium

ansible-pull runs every 15 minutes via systemd timer. Push to `main`, picked up on next cycle.

---

## Before deploying

**`ansible/group_vars/all.yml`** - `github_repo_url`, `server_hostname`, UPS names and descriptions

**`ansible/vault/secrets.yml`** - NUT passwords, admin username, SSH public key, Grafana URL.
Create `.vault-pass` first, then fill in secrets and run `just vault-encrypt`. After that use `just vault-edit`.

**`cloud-init/user-data`** - substitute locally before writing to USB, don't commit the substituted file:
- `VAULT_PASSWORD_HERE` → vault password
- hashed password → `openssl passwd -6 'yourpassword'`
- SSH public key
- NIC name (`ip link` in the installer) and disk device (`lsblk`)
- GitHub username in the `ansible-pull` late-command

**`.vault-pass`** at repo root - `echo 'yourpassword' > .vault-pass && chmod 600 .vault-pass`

**Cloud-init USB** - FAT32 drive labelled `CIDATA`, containing `user-data` and `meta-data`.
Boot with kernel arg `autoinstall ds=nocloud`. Installer runs unattended; late-commands write
the vault password and run ansible-pull to fully converge. After reboot NUT and kiosk should be running.

---

## Local

```
mise install         # Python 3.12 + venv
just install-hooks   # pre-commit hook to catch unencrypted secrets
just lint            # ansible-lint + yamllint
just vault-encrypt   # first-time encrypt of plaintext secrets.yml
just vault-edit      # decrypt → edit → re-encrypt in place
just vault-rekey     # change vault password (update .vault-pass + /etc/ansible/vault-pass on host too)
```

Requires `.vault-pass` at repo root.

---

## On the host

```bash
journalctl -u ansible-pull.service -f    # follow current run
systemctl start ansible-pull.service     # force immediate converge
systemctl status ansible-pull.timer
upsc ups1                                # query UPS data directly
upsc ups2
```
