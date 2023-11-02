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

1. [Install Docker](https://docs.docker.com/engine/install/ubuntu/)
2. Clone the repo with `git clone --recursive https://github.com/Alafia-Ai/alafia-apps.git`
3. Install the apps by running `./install.sh` (you may need to make the script executable with `chmod +x install.sh`)
4. Uninstall the apps by running `./install.sh --uninstall`
