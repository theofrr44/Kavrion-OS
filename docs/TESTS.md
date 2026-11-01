# État des tests (KAVRION OS 0.2.0)

## Historique réel sur le vrai matériel
- GitHub Actions : l'ISO se construit (1,5 Go avec Calamares ; tailles à revoir). Le Live démarre sur un PC UEFI, le bureau s'ouvre.
- Version 0.1 : l'installateur Calamares copie le système mais échoue à l'étape `grub-install` (code 1) : remplacé en 0.2.0 par `kavrion-install`.
- Version 0.2.0 : **jamais testée sur matériel**.


Environnement de développement : Ubuntu 24.04, 4 Go RAM, **sans réseau, sans live-build/debootstrap/xorriso, sans QEMU/KVM, sans GTK/X11**.

## Réussis (exécutés réellement)
| Test | Commande | Résultat |
|---|---|---|
| Analyse et métriques réelles (CPU, RAM, réseau, processus avec noms contenant des parenthèses, durées, formats) — 7 tests dont un sur les vraies données `/proc` de la machine | `python3 tests/test_sysinfo.py` | 7/7 OK |
| Compilation Python des 5 modules KAVRION | `tests/check_repo.sh` | OK |
| Syntaxe des scripts shell (build, vérification, VM, hooks) | `tests/check_repo.sh` | OK |
| XML (XFCE, SVG) et YAML (Calamares, 15 fichiers) bien formés | `tests/check_repo.sh` | OK |
| Absence de mot de passe en dur, de SSH, d'autologin après installation ; nettoyage Live présent | `tests/check_repo.sh` | OK |
| Installateur `kavrion-install` en SIMULATION (24 contrôles : UEFI/BIOS, refus de la clé Live, refus sans EFFACER, refus de root, mot de passe absent du journal, noms nvme/mmcblk) | `tests/test_installer.sh` | OK |
| Persistance du profil d'écrans (écriture/lecture du fichier de configuration) | test ponctuel | OK |
| Génération et contrôle visuel du logo/PNG de marque | `scripts/gen-branding.py` | OK |

## Non exécutés — impossibles ici
| À tester | Comment | Pourquoi non fait |
|---|---|---|
| **Construction de l'ISO 0.2.0** | GitHub Actions | à relancer |
| **Installation réelle** (partitionnement, copie, GRUB UEFI/BIOS, redémarrage sans clé) | VM puis vrai PC | seule la simulation a été exécutée (pas de sfdisk/mkfs.fat/GRUB dans l'environnement de développement) |
| Contrôles de l'ISO produite | `scripts/verify-iso.sh` | ISO inexistante |
| Démarrage Live UEFI et BIOS, ouverture du bureau | `scripts/test-vm.sh smoke|live` (+ `BIOS=1`) | pas de QEMU |
| Ouverture des applications graphiques (Moniteur, Paramètres, Tableau de bord) | dans le Live | pas de GTK/X11 (code compilé, **jamais lancé**) |
| Installation sur disque virtuel, redémarrage sans ISO, persistance après redémarrage | `scripts/test-vm.sh install` puis `disk` | pas de QEMU |
| Un seul écran / deux écrans (`kavrion-displays`, `kavrion-dashboard`) | `DUAL=1 scripts/test-vm.sh live`, puis un vrai PC avec 2 TV | pas de X11 |
| Mesures de RAM au repos et de temps de démarrage | dans la VM / sur le PC cible | aucune mesure disponible : aucun chiffre n'est annoncé |
| Réglages Rufus recommandés | sur Windows avec l'ISO finale | non vérifiable ici |
| Secure Boot | — | **non pris en charge** dans cette version |

## Risques connus à surveiller au premier build
Noms de paquets de trixie (`calamares`, `firmware-*`, `pkexec`), options `lb config`, paramètres Calamares 3.3 (modules `grubcfg`, `removeuser`), lancement de Calamares via `sudo -E`, écriture du bouton « Installer » sur le bureau Live (le fichier .desktop peut demander « Faire confiance » au premier clic).
