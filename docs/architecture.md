# Aster OS architecture notes

## Build approach

The build starts with Arch Linux's official `releng` Archiso profile, preserving its bootloader and live-image setup, then adds the Aster XFCE desktop package set and product metadata. GitHub Actions runs the build in a privileged Arch Linux container because Archiso needs mount and loop-device operations. The workflow uploads the ISO and SHA-256 checksum as a short-lived artifact.

## First usable milestone

Produce an ISO and boot it in a disposable VM. Confirm boot reaches a graphical session and check included apps, networking, audio, and reboot. This is a live-image milestone only, not an installer or tested update/recovery implementation.

## Choices and limits

- Arch Linux + Archiso and official Arch packages
- XFCE + LightDM as a modest desktop stack for the dual-core laptop
- Upstream Archiso releng profile for boot and live-session plumbing
- Rolling updates can regress and sometimes need manual intervention
- GitHub Actions image builds are not reproducible byte-for-byte over time unless package snapshots are pinned; this workflow tracks current repositories
- VM results do not establish laptop-specific Wi-Fi, suspend, battery, thermal, brightness, audio, or firmware support
- No partitioning, installation to physical disks, secure boot, rollback, or custom repository is included
