---
layout: content
---

# Prendre en charge les URL flatpak+https

Sur les pages d’installation de [Flathub](https://flathub.org/) (par ex. `https://flathub.org/…/install`), le site tente d’ouvrir une URL au schéma **flatpak+https** pour lancer directement la logithèque. Si « rien ne se passe », c’est qu’aucune application n’est enregistrée pour ce schéma (cas fréquent sous [Linux Mint](../dist/Mint) ou sans GNOME Software récent).

Vous pouvez ajouter le support en créant un **handler** qui transforme `flatpak+https://…` en ouverture du fichier .flatpakref dans votre logithèque.

## 1. Script qui ouvre l’URL en .flatpakref

Créez le dossier (s’il n’existe pas) puis le script :

```bash
mkdir -p ~/.local/bin
```

Enregistrez le contenu suivant dans `~/.local/bin/flatpak-https-handler` :

```bash
#!/bin/bash
# Ouvre une URL flatpak+https en téléchargeant le .flatpakref et en le lançant
# avec l’application par défaut (logithèque).
if [[ "$1" != flatpak+https://* ]]; then
  echo "Usage: $0 flatpak+https://..." >&2
  exit 1
fi
url="${1#flatpak+}"
tmp=$(mktemp --suffix=.flatpakref)
if curl -sSL -o "$tmp" "$url"; then
  xdg-open "$tmp"
else
  echo "Échec du téléchargement: $url" >&2
  rm -f "$tmp"
  exit 1
fi
```

Rendez-le exécutable :

```bash
chmod +x ~/.local/bin/flatpak-https-handler
```

(Assurez-vous que `~/.local/bin` est dans votre `PATH`.)

## 2. Fichier .desktop pour le schéma flatpak+https

Dans un fichier .desktop, `~` et `$HOME` ne sont pas développés — il faut un chemin absolu dans `Exec=`. Pour une installation utilisateur, créez `~/.local/share/applications/flatpak-https-handler.desktop` ; pour une installation système (ou le .deb), le script est dans `/usr/bin/` et le .desktop dans `/usr/share/applications/`. Exemple :

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Flatpak (flatpak+https)
Comment=Ouvre les liens d'installation Flathub dans la logithèque
Exec=/usr/bin/flatpak-https-handler %u
Terminal=false
NoDisplay=true
MimeType=x-scheme-handler/flatpak+https
```

Si le script est dans ~/.local/bin, mettez dans Exec= le chemin complet (ex. `/home/user/.local/bin/flatpak-https-handler`).

## 3. Enregistrer le handler

```bash
xdg-mime default flatpak-https-handler.desktop x-scheme-handler/flatpak+https
update-desktop-database ~/.local/share/applications
```

Redémarrez Firefox (ou votre navigateur), puis testez une page du type  
[https://flathub.org/fr/apps/net.andyofniall.missingno/install](https://flathub.org/fr/apps/net.andyofniall.missingno/install) : le clic devrait ouvrir la logithèque avec l’application à installer.

## Paquet .deb (installation générique)

Un paquet Debian permet d’installer le script dans `/usr/bin/` et le .desktop dans `/usr/share/applications/` avec un chemin `Exec=` fixe, valable pour tous les utilisateurs.

- **Sources** : [packages/flatpak-https-handler](/packages/flatpak-https-handler/) dans ce dépôt.
- **Construire le .deb** (depuis la racine du dépôt) :
  ```bash
  cd packages && chmod +x build-flatpak-https-handler.sh && ./build-flatpak-https-handler.sh
  ```
- **Installer** : `sudo dpkg -i packages/flatpak-https-handler_1.0_all.deb` (dépendances : `curl`, `xdg-utils`). Le **postinst** enregistre automatiquement le handler pour l’utilisateur qui a lancé `sudo`. Les autres utilisateurs doivent lancer une fois :  
  `xdg-mime default flatpak-https-handler.desktop x-scheme-handler/flatpak+https`

**Défaire une installation manuelle** (pour tester le .deb) : supprimer `~/.local/bin/flatpak-https-handler`, `~/.local/share/applications/flatpak-https-handler.desktop`, et la ligne `x-scheme-handler/flatpak+https=...` dans `~/.config/mimeapps.list` (ou `sed -i '/x-scheme-handler\/flatpak+https=/d' ~/.config/mimeapps.list`).

**Pourquoi le postinst modifie mimeapps.list au lieu d’appeler xdg-mime ?**  
`xdg-mime default` est prévu pour une session utilisateur (avec D-Bus) et n’est pas adapté à un script postinst lancé en root. La doc conseille, pour les paquets, d’écrire directement dans `~/.config/mimeapps.list` avec le même format que xdg-mime. C’est ce que fait le postinst.

**Intégration native (Linux Mint, etc.)**  
Pour que le handler soit proposé nativement (sans installer ce paquet), il faudrait que la distribution le prenne en charge : par ex. ouvrir une [feature request ou issue sur mintinstall](https://github.com/linuxmint/mintinstall/issues) pour demander le support des URL **flatpak+https** (mintinstall pourrait s’enregistrer comme handler, comme il existe [apturl](https://github.com/linuxmint/apturl) pour `apt://`). On peut aussi proposer ce .deb comme paquet communautaire ou demander sur le [forum Linux Mint](https://forums.linuxmint.com/) comment soumettre un paquet.

**Proposer le .deb au téléchargement**  
Le plus simple : créer une [release GitHub](https://github.com/phramusca/phramusca.github.io/releases), y attacher le fichier `flatpak-https-handler_1.0_all.deb` (construit avec le script dans `packages/`), puis mettre le lien de téléchargement dans le README du dépôt ou sur la page wiki.

## Alternative : installation en ligne de commande

Si vous préférez lancer l’installation en terminal au lieu de la logithèque, vous pouvez faire exécuter par le script :

```bash
flatpak install "$url"
```

(éventuellement avec `--user`). Dans ce cas, lancez le script dans un terminal pour voir la progression, ou adaptez le .desktop avec `Terminal=true`.
