# Architecture et décisions

## Choix techniques
- **Base Debian 13 « trixie »** (stable au moment de la rédaction) construite avec **live-build** : outil officiel Debian, reproductible, ISO hybride BIOS + UEFI.
- **XFCE** + **LightDM** : faible empreinte mémoire, thème **Arc-Dark** + icônes **Papirus-Dark**, compositing désactivé par défaut (mode léger actif ; réactivable dans Paramètres).
- **Installateur KAVRION (`kavrion-install`)** : script bash + whiptail, remplaçant Calamares (qui a échoué à l'étape GRUB sur le premier test réel). Moins de composants, journal lisible, erreurs affichées à l'écran. Il ne gère qu'un parcours : effacer UN disque choisi et y installer le système (GPT : 1 MiB BIOS-boot, 512 MiB EFI, reste ext4), sans partitionnement manuel ni double démarrage.
- **zram** (zstd, 50 % de la RAM) au lieu d'un swap disque : adapté à 4 Go.
- **Outils KAVRION** en Python + GTK3 (pas de dépendance lourde) : métriques lues dans `/proc` et `/sys`, jamais simulées ; valeur absente = « n/d ».
- Pas de noyau original : noyau Debian `linux-image-amd64`.
- Non inclus volontairement : Plymouth, thème GRUB/syslinux personnalisé, signature Secure Boot (à ajouter dans une version ultérieure).

## Indépendance du système installé
Le système est copié depuis `/run/live/medium/live/filesystem.squashfs` (image d'origine, sans compte Live). Ensuite : retrait de l'autologin Live, du lanceur d'installation et de l'installateur lui-même ; purge de live-boot/live-config ; fstab par UUID ; `update-initramfs` ; GRUB UEFI installé **deux fois** (chemin de repli `EFI/BOOT/BOOTX64.EFI` sans écriture NVRAM, puis entrée NVRAM en « au mieux ») ou GRUB BIOS sur le disque ; contrôles finaux (grub.cfg avec noyau, BOOTX64.EFI présent).

## Sécurité
Aucun mot de passe/clé dans l'image (contrôlé par `verify-iso.sh` et `tests/check_repo.sh`) ; aucun serveur SSH ; pas de connexion automatique après installation ; mot de passe de 8 caractères minimum, choisi par l'utilisateur ; l'installateur exclut la clé Live de la liste des disques et exige la saisie de EFFACER ; mises à jour de sécurité automatiques. La session **Live** utilise le compte `user` (créé par live-config, connexion automatique, sudo sans mot de passe) : c'est propre au Live et supprimé à l'installation.

## Double écran
`kavrion-displays` (xrandr) applique le profil (`~/.config/kavrion/display.json`). `kavrion-dashboard` s'ouvre en plein écran sur le moniteur **non principal** et se ferme sans erreur s'il n'y en a qu'un.

## Version ARM64 (future, non incluse)
Ne pas réutiliser l'ISO x86-64. Prévoir un dépôt/cible séparé : image disque (pas d'ISO) pour Raspberry Pi 4 construite avec `debos`/`pi-gen` ou l'image Debian `raspi`, noyau `linux-image-arm64` + firmware Raspberry Pi, `config/` partagé pour le bureau et les outils KAVRION (Python pur, portable). Déclarer la compatibilité seulement après test sur le matériel réel.

## Licences
Scripts du projet : MIT. Composants Debian : licences d'origine. Ressources graphiques : originales (logo généré par `scripts/gen-branding.py`, fond SVG).
