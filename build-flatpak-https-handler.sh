#!/bin/bash
# Builds the flatpak-https-handler .deb package
set -e
cd "$(dirname "$0")/flatpak-https-handler"
chmod 755 usr/bin/flatpak-https-handler
chmod 644 usr/share/applications/flatpak-https-handler.desktop
chmod 755 DEBIAN/postinst
command -v fakeroot >/dev/null 2>&1 || { echo "Error: fakeroot is required (sudo apt install fakeroot)." >&2; exit 1; }
package_name="$(awk -F': ' '/^Package:/ { print $2 }' DEBIAN/control)"
package_version="$(awk -F': ' '/^Version:/ { print $2 }' DEBIAN/control)"
output_file="./${package_name}_${package_version}_all.deb"
fakeroot dpkg-deb --build . "$output_file"
echo "Package built: $output_file"
