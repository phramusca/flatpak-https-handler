# Packages

## flatpak-https-handler

Handler for **flatpak+https** URLs (Flathub “Install” pages). Install the script into `/usr/bin/` and the `.desktop` file into `/usr/share/applications/` with a fixed `Exec=` path (works for all users).

### Build the .deb

From the repository root:

```bash
cd packages && chmod +x build-flatpak-https-handler.sh && ./build-flatpak-https-handler.sh
```

The package is created as: `packages/flatpak-https-handler_1.0_all.deb`.

**Prerequisite**: `fakeroot` (otherwise `sudo apt install fakeroot`).

### Install

```bash
sudo dpkg -i packages/flatpak-https-handler_1.0_all.deb
```

Dependencies: `curl`, `xdg-utils`. The **postinst** script automatically registers the handler for the user who ran `sudo dpkg -i`. Other users on the same machine must run it once:

```bash
xdg-mime default flatpak-https-handler.desktop x-scheme-handler/flatpak+https
```

(Restart Firefox, then test the install.)

**Why does `postinst` edit `mimeapps.list` instead of calling `xdg-mime`?**  
`xdg-mime default` is meant for a graphical user session (D-Bus) and is not suitable for a `postinst` running as root. Writing the same entry into `~/.config/mimeapps.list` is the recommended approach for packages.

### Native integration (Linux Mint)

See the [wiki page](../_wiki/linux/system/flatpak-url-handler.md) for a feature request on [mintinstall](https://github.com/linuxmint/mintinstall/issues) or how to propose the package via the Mint forum.

### Distribute the .deb

Create a [GitHub release](https://github.com/phramusca/phramusca.github.io/releases), attach the built `.deb`, then add the download link to the README or documentation.

## Detailed Guide: Handling `flatpak+https` URLs

On Flathub install pages (for example `https://flathub.org/.../install`), the site tries to open a URL using the **flatpak+https** scheme to launch your software center directly. If nothing happens, it means no application is registered for this scheme (common on [Linux Mint](../dist/Mint) or on systems without a recent GNOME Software).

You can add support by creating a handler that turns `flatpak+https://...` into opening the corresponding `.flatpakref` file in your software center.

### 1) Script that opens the URL as a `.flatpakref`

Create the directory (if it doesn't exist) and the script:

```bash
mkdir -p ~/.local/bin
```

Save the following content as `~/.local/bin/flatpak-https-handler`:

```bash
#!/bin/bash
# Open a flatpak+https URL by downloading the .flatpakref and opening it
# with the default application (software center).
if [[ "$1" != flatpak+https://* ]]; then
  echo "Usage: $0 flatpak+https://..." >&2
  exit 1
fi
url="${1#flatpak+}"
tmp=$(mktemp --suffix=.flatpakref)
if curl -sSL -o "$tmp" "$url"; then
  xdg-open "$tmp"
else
  echo "Download failed: $url" >&2
  rm -f "$tmp"
  exit 1
fi
```

Make it executable:

```bash
chmod +x ~/.local/bin/flatpak-https-handler
```

(Make sure `~/.local/bin` is in your `PATH`.)

### 2) `.desktop` file for the `flatpak+https` scheme

In a `.desktop` file, `~` and `$HOME` are not expanded—you must use an absolute path in `Exec=`. For a user install, create `~/.local/share/applications/flatpak-https-handler.desktop`. For a system install (or the `.deb`), the script is placed in `/usr/bin/` and the `.desktop` file in `/usr/share/applications/`. Example:

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Flatpak (flatpak+https)
Comment=Open Flathub install links in the software center
Exec=/usr/bin/flatpak-https-handler %u
Terminal=false
NoDisplay=true
MimeType=x-scheme-handler/flatpak+https
```

If the script is in `~/.local/bin`, set `Exec=` to the full path (for example `/home/user/.local/bin/flatpak-https-handler`).

### 3) Register the handler

```bash
xdg-mime default flatpak-https-handler.desktop x-scheme-handler/flatpak+https
update-desktop-database ~/.local/share/applications
```

Restart Firefox (or your browser), then test a page like:
`https://flathub.org/apps/net.andyofniall.missingno/install` — the click should open the software center with the app to install.

### .deb package (generic install)

A Debian package allows you to install the script into `/usr/bin/` and the `.desktop` file into `/usr/share/applications/` with a fixed `Exec=` path that applies to all users.

- **Sources**: [packages/flatpak-https-handler](/packages/flatpak-https-handler/) in this repository.
- **Build the .deb** (from the repository root):
  ```bash
  cd packages && chmod +x build-flatpak-https-handler.sh && ./build-flatpak-https-handler.sh
  ```
- **Install**: `sudo dpkg -i packages/flatpak-https-handler_1.0_all.deb` (dependencies: `curl`, `xdg-utils`). The **postinst** registers the handler automatically for the user who ran `sudo`. Other users need to run once:
  `xdg-mime default flatpak-https-handler.desktop x-scheme-handler/flatpak+https`

**Undo a manual installation (for testing the .deb)**: remove `~/.local/bin/flatpak-https-handler`, `~/.local/share/applications/flatpak-https-handler.desktop`, and the `x-scheme-handler/flatpak+https=...` line in `~/.config/mimeapps.list` (or use `sed -i '/x-scheme-handler\/flatpak+https=/d' ~/.config/mimeapps.list`).

**Why does `postinst` modify `mimeapps.list` instead of calling `xdg-mime`?**  
`xdg-mime default` is intended for a user session (with D-Bus) and is not suitable for a postinst script run as root. The documentation recommends writing directly to `~/.config/mimeapps.list` with the same format as `xdg-mime`. This is what the `postinst` does.

### Native integration (Linux Mint, etc.)

To have the handler offered natively (without installing the package), the distro must support registering `flatpak+https` URLs—for example by opening a feature request/issue on `mintinstall` to ask for support (mintinstall could register itself similarly to how [apturl](https://github.com/linuxmint/apturl) registers `apt://`). You can also propose this `.deb` as a community package or ask on the [Linux Mint forum](https://forums.linuxmint.com/) how to submit one.

### Propose the `.deb` for download

The simplest path is to create a [GitHub release](https://github.com/phramusca/phramusca.github.io/releases), attach the `flatpak-https-handler_1.0_all.deb` file (built from the script under `packages/`), then add the download link to the repository README or the wiki.

## Alternative: install from the command line

If you prefer installing in a terminal instead of the software center, you can run this from the script:

```bash
flatpak install "$url"
```

(Optionally with `--user`.) In that case, run the script in a terminal to see progress, or adapt the `.desktop` file with `Terminal=true`.
