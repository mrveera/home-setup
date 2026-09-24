# Oracle: Vaultwarden

Rebuild from nothing, with only this repo and `home-setup.secrete.key`:

1. New Ubuntu instance, then on it: `sudo tailscale up`. No public ingress rules needed.
2. Add it to `oracle/hosts`, and create `secure/oracle/<name>.env` (copy `test.env`, change values).
   For real use: `TLS_MODE=dns` with a Cloudflare token made for this host only:
   Zone → DNS → Edit on its own zone (mrveera.dev), and Client IP filtering set to the
   host's public egress IP (`curl ifconfig.me` on it). A leaked copy is then useless elsewhere.
   One token per host and zone, never shared (lifenidhi on `test` has its own for lifenidhi.com).
3. `ansible-playbook -i oracle/hosts oracle/vault.yaml -l <name>`
4. `ansible-playbook -i oracle/hosts oracle/restore.yaml -l <name> -e confirm=yes`
   (reads `enc:/bw-data` from Dropbox, never writes there)
5. Point `pass` in Cloudflare DNS at the new Tailscale IP (DNS only, grey cloud).
6. Only on the live host, once it is the live host: `docker compose --profile backup up -d`
   (`rclone sync` mirrors deletions; on any other box it would wipe the backup).

Tested 2026-09-24 on `test` (140.245.221.119): 2 users, 194 items, 13 folders, 1 org, 1 attachment,
last change identical to prod.

Gotcha: `data/config.json` from the backup (admin-panel settings) overrides env vars,
e.g. it pins the domain to https://pass.mrveera.dev.
