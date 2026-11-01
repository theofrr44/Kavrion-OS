# KAVRION OS 0.2.0 (nom provisoire)

Distribution Linux personnalisée : **Debian 13 « trixie » + XFCE**, installateur simple **kavrion-install** (écran de bienvenue au démarrage, choix du disque, confirmation « EFFACER »), ISO hybride (BIOS + UEFI) à écrire avec **Rufus**.
Cible : PC x86-64 avec ~4 Go de RAM. Version ARM64 (Raspberry Pi 4) : prévue, **non incluse** (voir `docs/ARCHITECTURE.md`).

> **État honnête** : l'ISO se construit (testé via GitHub Actions) et le Live démarre sur un vrai PC. L'installateur actuel (0.2.0, qui remplace Calamares) n'a été testé qu'en **simulation** ; l'installation réelle, le démarrage depuis le disque, les applications graphiques et le double écran restent à valider. Détail : `docs/TESTS.md`.
> Le nom « KAVRION » doit être vérifié (marques, noms de domaine) avant toute publication ; les URL du projet sont des espaces réservés (`example.invalid`).

## Contenu
| Dossier | Rôle |
|---|---|
| `config/auto/` | configuration `live-build` (Debian trixie, amd64, ISO hybride) |
| `config/package-lists/` | paquets de l'image |
| `config/hooks/live/` | personnalisation dans le chroot (identité, locales, services) |
| `config/includes.chroot/` | fichiers copiés dans le système : thème XFCE, écran de connexion, applications KAVRION, installateur `kavrion-install` |
| `config/includes.chroot/usr/lib/kavrion/` | **Moniteur**, **Tableau de bord 2ᵉ écran**, **Profils d'écrans**, **Paramètres**, module de métriques réelles |
| `scripts/` | `build.sh`, `check-deps.sh`, `verify-iso.sh`, `test-vm.sh`, `gen-branding.py` |
| `tests/` | tests unitaires, simulation de l'installateur, contrôles statiques |
| `.github/workflows/` | construction gratuite de l'ISO dans le cloud (GitHub Actions) |
| `docs/` | guides en français |

## Démarrage rapide
```bash
make test          # tests (sans réseau, sans root)
sudo scripts/build.sh --install-deps   # construit dist/kavrion-os-0.2.0-amd64.iso (+ .sha256, journal)
scripts/verify-iso.sh dist/kavrion-os-0.2.0-amd64.iso
scripts/test-vm.sh install dist/kavrion-os-0.2.0-amd64.iso
```
Pas de Linux ? Suivez `docs/GUIDE-CONSTRUCTION.md` (construction gratuite via GitHub Actions).
Guide utilisateur (Windows → Rufus → installation) : `docs/GUIDE-UTILISATEUR.md`.
