# alafia-apps

- make sure docker and docker compose are installed
- install `sudo apt-get install -y qemu qemu-user-static binfmt-support` to get cross-architecture support
- run `docker run --privileged --rm tonistiigi/binfmt --install all` to get the docker emulators
- run all the compose files at once to kick off the : `sudo docker compose -f caddy/docker-compose.yml -f bento/docker-compose.yml -f ohif/docker-compose.yml -f neurodesk/docker-compose.yml`
- put the contents of `etc-hosts` into `/etc/hosts`. This is so Caddy can resolve the *.alafia domains when launched by Bento
- put `Alafia AI OHIF Viewer.desktop` in `/home/$USER/Desktop`. It opens the web browser to `home.alafia`.
- put `opt-alafia-logo.png` in `/opt/alafia/logo.png`. `Alafia AI OHIF Viewer.desktop` requires an absolute path and /opt/alafia seems like a reasonable place to install everything to

