# Paquets

## flatpak-https-handler

Handler pour les URL **flatpak+https** (pages « Install » de Flathub). Installe le script dans `/usr/bin/` et le .desktop dans `/usr/share/applications/` avec un chemin `Exec=` fixe (valable pour tous les utilisateurs).

### Construction du .deb

Depuis la racine du dépôt :

```bash
cd packages && chmod +x build-flatpak-https-handler.sh && ./build-flatpak-https-handler.sh
```

Le paquet est créé : `packages/flatpak-https-handler_1.0_all.deb`.

**Prérequis** : `fakeroot` (sinon `sudo apt install fakeroot`). Si `fakeroot` est absent, vous pouvez lancer `dpkg-deb --build flatpak-https-handler` depuis le dossier `packages/flatpak-https-handler/` (les permissions dans le .deb peuvent alors différer).

### Installation

```bash
sudo dpkg -i packages/flatpak-https-handler_1.0_all.deb
```

Dépendances : `curl`, `xdg-utils`. Le script **postinst** enregistre automatiquement le handler pour l’utilisateur qui a lancé `sudo dpkg -i`. Les autres utilisateurs du même PC doivent exécuter une fois :

```bash
xdg-mime default flatpak-https-handler.desktop x-scheme-handler/flatpak+https
```

(Redémarrer Firefox puis installer le .deb.)

**Pourquoi le postinst modifie `mimeapps.list` et pas `xdg-mime` ?**  
`xdg-mime default` est prévu pour une session graphique (D-Bus) et n’est pas adapté à un postinst en root. Écrire le même format dans `~/.config/mimeapps.list` est la méthode recommandée pour les paquets.

**Intégration native (Linux Mint)**  
Voir la [page wiki](../_wiki/linux/system/flatpak-url-handler.md) : feature request sur [mintinstall](https://github.com/linuxmint/mintinstall/issues), ou proposer le paquet via le forum Mint.

**Distribuer le .deb**  
Créer une [release GitHub](https://github.com/phramusca/phramusca.github.io/releases), y attacher le .deb construit, puis mettre le lien dans le README ou la doc.

Documentation détaillée : [Prendre en charge les URL flatpak+https](../_wiki/linux/system/flatpak-url-handler.md).
