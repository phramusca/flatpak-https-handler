# flatpak-https-handler

`flatpak-https-handler` adds support for the `flatpak+https://` URL scheme used by Flathub "Install" pages.

Without a registered handler, clicking install links may do nothing on some Linux distributions. This project provides a small launcher script and a desktop entry so these links open the related `.flatpakref` in your software center.

---

## For Users

### What this is for

On Flathub install pages (for example `https://flathub.org/apps/.../install`), the browser opens a `flatpak+https://...` URL.  
This package registers a handler for that scheme so your system can open the app install flow correctly.

### Install

#### Option A (UI): install the `.deb` with your software installer

1. Download `flatpak-https-handler_1.0_all.deb`.
2. Double-click it in your file manager.
3. Click **Install** in your distribution's package installer.
4. Restart your browser and test a Flathub install page.

#### Option B (command line): install the `.deb`

```bash
sudo dpkg -i flatpak-https-handler_1.0_all.deb
```

If you install via your software installer (or via `apt`), dependencies are handled automatically.  
If you use `dpkg -i` and it reports missing dependencies, run:

```bash
sudo apt -f install
```

The post-install script automatically registers the handler for the user who ran `sudo dpkg -i`.  
If other local users need it, each user can run:

```bash
xdg-mime default flatpak-https-handler.desktop x-scheme-handler/flatpak+https
```

### Uninstall

#### Option A (UI): remove with your software manager

1. Open your software/package manager.
2. Search for `flatpak-https-handler`.
3. Click **Remove** (or **Uninstall**).

#### Option B (command line): remove the package

```bash
sudo dpkg -r flatpak-https-handler
```

Optional full removal (also removes package configuration files):

```bash
sudo dpkg -P flatpak-https-handler
```

---

## For Developers

### Build the `.deb`

From the repository root:

```bash
./build-flatpak-https-handler.sh
```

Output:

- `flatpak-https-handler_1.0_all.deb` in the repository root

Prerequisite:

- `fakeroot` (`sudo apt install fakeroot`)

### Install the built package locally (CLI)

```bash
sudo dpkg -i flatpak-https-handler_1.0_all.deb
```
