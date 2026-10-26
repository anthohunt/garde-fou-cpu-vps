#!/bin/bash
# Installe garde-fou-cpu, lourd et batch.slice (root, systemd). Usage : sudo ./install.sh [COMPTE_ADMIN]
set -e
[ "$(id -u)" = 0 ] || { echo "a lancer en root (sudo)"; exit 1; }
ici=$(cd "$(dirname "$0")" && pwd)
install -m 755 "$ici/garde-fou-cpu" /usr/local/sbin/garde-fou-cpu
install -m 755 "$ici/lourd-adopter" /usr/local/sbin/lourd-adopter
install -m 755 "$ici/lourd" /usr/local/bin/lourd
install -m 644 "$ici/systemd/batch.slice" /etc/systemd/system/batch.slice
install -m 644 "$ici/systemd/garde-fou-cpu.service" "$ici/systemd/garde-fou-cpu.timer" /etc/systemd/system/
install -m 644 "$ici/config/logrotate-garde-fou-cpu" /etc/logrotate.d/garde-fou-cpu
mkdir -p /etc/garde-fou-cpu /var/lib/garde-fou-cpu
[ -f /etc/garde-fou-cpu/config.json ] || install -m 644 "$ici/config/config.example.json" /etc/garde-fou-cpu/config.json
if [ -n "${1:-}" ]; then
  sed "s/^ADMIN /$1 /" "$ici/config/sudoers-garde-fou-cpu.example" > /etc/sudoers.d/garde-fou-cpu
  chmod 440 /etc/sudoers.d/garde-fou-cpu; visudo -cf /etc/sudoers.d/garde-fou-cpu
fi
systemctl daemon-reload
systemctl enable --now garde-fou-cpu.timer
echo "installe. Verifier : garde-fou-cpu statut ; lourd --statut"
