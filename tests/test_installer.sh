#!/bin/bash
# Tests de l'installateur en SIMULATION (aucun disque n'est touché) : sécurité, validations, enchaînement des commandes.
cd "$(dirname "$0")/.."
S=config/includes.chroot/usr/local/bin/kavrion-install
fail=0; ok(){ echo "  [OK]    $1"; }; ko(){ echo "  [ÉCHEC] $1"; fail=1; }
LOGF=$(mktemp); export KAVRION_LOG=$LOGF

( source "$S"
  [ "$(part /dev/sda 3)" = /dev/sda3 ] && [ "$(part /dev/nvme0n1 3)" = /dev/nvme0n1p3 ] && [ "$(part /dev/mmcblk0 2)" = /dev/mmcblk0p2 ] ) && ok "noms de partitions (sda, nvme, mmcblk)" || ko "noms de partitions"
( source "$S"
  valid_user marc && valid_user a_b-1 && ! valid_user root && ! valid_user Marc && ! valid_user "ma rc" && ! valid_user "1abc" && ! valid_user "" ) && ok "validation du nom d'utilisateur" || ko "validation du nom d'utilisateur"
( source "$S"; findmnt(){ echo /dev/sdy1; }; lsblk(){ [ "$1" = "-no" ] && echo sdy; }
  [ "$(live_disk)" = /dev/sdy ] && ! validate_disk /dev/sdy ) && ok "la clé Live est refusée comme cible" || ko "clé Live non refusée"
( source "$S"; list_disks >/dev/null 2>&1 ) && ok "énumération des disques (sans erreur)" || ko "énumération des disques"

run_dry(){ env KAVRION_DRY=1 KAVRION_NONINTERACTIVE=1 KAVRION_LOG=$LOGF KAVRION_DISK=/dev/sdz KAVRION_USER=alice KAVRION_PASSWORD=secret-pw-123 KAVRION_CONFIRM=EFFACER "$@" bash "$S" >/dev/null 2>&1; }
: >$LOGF; run_dry KAVRION_FIRMWARE=uefi && ok "simulation UEFI : exit 0" || ko "simulation UEFI"
for pat in "wipefs -a /dev/sdz" "sfdisk" "mkfs.fat -F32 -n KAVRION_EFI /dev/sdz2" "mkfs.ext4 -F -q -L KAVRION /dev/sdz3" "mount /dev/sdz3 /target" "unsquashfs" "useradd -m -s /bin/bash -G sudo,audio,video,plugdev,netdev,cdrom,users alice" "apt-get -y purge live-boot" "update-initramfs" "--target=x86_64-efi .*--removable --no-nvram" "update-grub" "INSTALLATION TERMINÉE"; do
  grep -q -- "$pat" $LOGF && ok "UEFI : $pat" || ko "UEFI manque : $pat"
done
grep -q "secret-pw-123" $LOGF && ko "MOT DE PASSE présent dans le journal" || ok "mot de passe absent du journal"
grep -q "i386-pc" $LOGF && ko "UEFI : grub BIOS lancé à tort" || ok "UEFI : pas de grub BIOS"
: >$LOGF; run_dry KAVRION_FIRMWARE=bios && grep -q -- "--target=i386-pc --recheck /dev/sdz" $LOGF && ! grep -q x86_64-efi $LOGF && ok "simulation BIOS : grub i386-pc sur le disque" || ko "simulation BIOS"
run_dry KAVRION_CONFIRM=oui && ko "confirmation incorrecte acceptée" || ok "refus sans la confirmation EFFACER"
run_dry KAVRION_USER=root && ko "utilisateur root accepté" || ok "refus de l'utilisateur root"
run_dry KAVRION_PASSWORD=court && ko "mot de passe court accepté" || ok "refus d'un mot de passe < 8 caractères"
# sans simulation : disque inexistant refusé (aucune commande destructive possible)
env KAVRION_NONINTERACTIVE=1 KAVRION_LOG=$LOGF KAVRION_DISK=/dev/sdz KAVRION_USER=alice KAVRION_PASSWORD=secret-pw-123 KAVRION_CONFIRM=EFFACER bash "$S" >/dev/null 2>&1 && ko "disque non listé accepté" || ok "disque inexistant/non listé refusé hors simulation"
rm -f $LOGF
[ $fail -eq 0 ] && echo "=> INSTALLATEUR : TESTS OK (simulation)" || { echo "=> INSTALLATEUR : ÉCHECS"; exit 1; }
