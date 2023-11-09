# alafia-apps

## Introduction

This repository contains the files to build and deploy the following apps on Alafia's ARM64 workstation:

- [Caddy & Bento](alafia-home)
- [Freesurfer](alafia-freesurfer)
- [FSL](alafia-fsl)
- [CONN Toolbox](alafia-conn-toolbox)
- [OHIF Viewer](alafia-ohif)
- [Neurodesktop](alafia-neurodocker)

## Usage

1. Install [Docker](https://docs.docker.com/engine/install/ubuntu/) and [Git LFS](https://github.com/git-lfs/git-lfs/blob/main/INSTALLING.md#2-installing-packages)
2. Clone the repos and LFS objects with `git clone --recursive https://github.com/Alafia-Ai/alafia-apps.git alafia-ai && git -C alafia-ai/alafia-conn-toolbox lfs fetch --all`
3. Move to `/opt` with `sudo mv alafia-ai /opt/alafia-ai`
4. Install the apps by running `./install.sh` (Requires `sudo`. Also, you may need to make the script executable with `chmod +x install.sh`)
5. Uninstall the apps by running `./install.sh --uninstall`

## Noteworthy directories

- `/opt/alafia-ai`          - (A.K.A `{alafia_app_dir}`) Primary installation directory for this repository (contains installation files and tracks updates)
- `/etc/systemd/system`     - Systemd service file installation directory
- `/usr/share/applications` - *.desktop file installation directory to get icons and launchers to show up in the system app launcher menu

## File Conventions

- `{alafia_app_dir}/alafia-{app_name}/alafia-{app-name}.sh`  - Entrypoint / launcher for each app
- `{alafia_app_dir}/alafia-{app_name}/alafia-{app-name}.svg` - Fixed icon location for each app
- `{alafia_app_dir}/alafia-{app_name}/alafia-{app-name}.svg` - Fixed icon location for each app
