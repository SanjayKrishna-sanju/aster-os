#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_PROFILE="$ROOT/profile"
PROFILE="$ROOT/.work/profile"
OUT="$ROOT/out"
WORK="$ROOT/.work/build"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root on Arch Linux, or use the GitHub Actions workflow." >&2
  exit 1
fi
if ! command -v mkarchiso >/dev/null 2>&1; then
  echo "mkarchiso is missing. Install archiso from the official Arch repositories." >&2
  exit 1
fi
RELENG="$(pacman -Ql archiso | awk '$2 ~ /\/configs\/releng\/profiledef\.sh$/ {sub(/\/profiledef\.sh$/, "", $2); print $2; exit}')"
if [[ -z "$RELENG" || ! -f "$RELENG/profiledef.sh" ]]; then
  echo "Could not locate the official archiso releng profile." >&2
  exit 1
fi
rm -rf "$PROFILE"
cp -a "$RELENG" "$PROFILE"

# Retain Arch's supported boot and live-session files; layer on the desktop package set.
cat "$SOURCE_PROFILE/packages.x86_64" >> "$PROFILE/packages.x86_64"
sort -u "$PROFILE/packages.x86_64" -o "$PROFILE/packages.x86_64"
cp -a "$SOURCE_PROFILE/airootfs/." "$PROFILE/airootfs/"

# Use Aster product metadata without replacing the upstream boot profile structure.
sed -i \
  -e 's/^iso_name=.*/iso_name="aster-os"/' \
  -e 's/^iso_label=.*/iso_label="ASTER_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"/' \
  -e 's/^iso_publisher=.*/iso_publisher="Aster OS Project"/' \
  -e 's/^iso_application=.*/iso_application="Aster OS Live"/' \
  -e 's/^install_dir=.*/install_dir="aster"/' \
  "$PROFILE/profiledef.sh"

CUSTOMIZE="$PROFILE/airootfs/root/customize_airootfs.sh"
touch "$CUSTOMIZE"
cat >> "$CUSTOMIZE" <<'ASTER_CUSTOMIZE'

# Aster live desktop setup, appended to Arch's releng customization.
useradd --create-home --groups wheel --shell /bin/bash aster
passwd --delete aster
systemctl enable NetworkManager.service
systemctl enable lightdm.service
systemctl enable bluetooth.service
ASTER_CUSTOMIZE
chmod 755 "$CUSTOMIZE"
mkdir -p "$OUT" "$WORK"
mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"


