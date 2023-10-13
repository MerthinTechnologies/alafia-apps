# Alafia Start

## Description

This app is mostly hidden from the user. It contains essentially just two systemd service files that are required for other applications: binfmt which provides qemu-user shims to run amd64 / x86_64 docker containers, and caddy which runs a web server to serve web applications with a friendly name (e.g. http://<app>.alafia).


## Installation Directories

README.md - `/usr/share/doc/alafia-home/README.md`
bin/alafia-home - `/usr/bin/alafia-home`
alafia-home.desktop - `/usr/share/applications/alafia-home.desktop`
alafia-home.png - `/usr/share/icons/alafia-home.png`
alafia-home.service - `/etc/systemd/system/alafia-home.service`
alafia-home/ - /opt/alafia-ai/apps/alafia-home/

