# Aster OS

Aster OS is an Arch Linux live desktop project. The current first milestone is a VM-bootable ISO built from Arch's official Archiso `releng` profile with an XFCE desktop layer. This repository contains build configuration; an ISO is only considered ready after the workflow succeeds and the VM checklist is completed.

## Build with GitHub Actions

The workflow runs on manual dispatch and on changes to the profile or build scripts. It uses an Arch Linux container with elevated container capabilities because Archiso needs to mount filesystems while assembling an image. On success, it publishes an ISO and SHA-256 checksum as a downloadable Actions artifact retained for seven days.

To use the workflow, put this project in a GitHub repository, open **Actions → Build Aster OS ISO → Run workflow**, and download the artifact from the completed run. Pushes to the tracked build paths also start a build. This workspace is not currently connected to a GitHub repository, so no run has been triggered yet.

## Local build

On an Arch Linux build host with `archiso` installed, run:

```sh
sudo bash scripts/build.sh
```

The script copies the installed official `releng` profile, adds Aster's packages and filesystem overlay, and writes the image under `out/`.

## VM test

Use a disposable VM with at least 2 vCPUs, 4 GiB RAM, and a 30 GiB virtual disk. Boot the ISO as a live image with no physical disk passthrough. Confirm the desktop appears, test file manager, terminal, browser, text editor, screenshot tool, networking, audio, Bluetooth UI, and reboot. Record results and the ISO hash in `docs/vm-test-log.md`.

## Current limits

- No ISO has been built or VM-booted yet.
- This is a live image, not an installer or an installed-system update/recovery design.
- GitHub builds use current Arch repositories; the same commit may get different package versions later.
- VM checks cannot establish laptop-specific Wi-Fi, suspend, battery, brightness keys, thermal, audio, or firmware support.
- No physical disks, Windows settings, firmware, or boot entries are part of this project workflow.
