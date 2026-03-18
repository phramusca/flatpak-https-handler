#!/bin/bash
# Construit le paquet .deb flatpak-https-handler
set -e
cd "$(dirname "$0")/flatpak-https-handler"
chmod 755 usr/bin/flatpak-https-handler
chmod 644 usr/share/applications/flatpak-https-handler.desktop
chmod 755 DEBIAN/postinst
command -v fakeroot >/dev/null 2>&1 || { echo "Erreur: fakeroot est requis (sudo apt install fakeroot)." >&2; exit 1; }
fakeroot dpkg-deb --build . ..
echo "Paquet créé : ../flatpak-https-handler_1.0_all.deb"
