#!/bin/bash
# Builds the flatpak-https-handler .deb package
set -e
cd "$(dirname "$0")/flatpak-https-handler"
chmod 755 usr/bin/flatpak-https-handler
chmod 644 usr/share/applications/flatpak-https-handler.desktop
chmod 755 DEBIAN/postinst
command -v fakeroot >/dev/null 2>&1 || { echo "Error: fakeroot is required (sudo apt install fakeroot)." >&2; exit 1; }
fakeroot dpkg-deb --build . ..
echo "Package built: ../flatpak-https-handler_1.0_all.deb"
