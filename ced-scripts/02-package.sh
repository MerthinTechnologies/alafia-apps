#!/bin/bash

# Configuration Variables
PACKAGE_NAME="alafia-$CED_SUBSYSTEM_ID"
PACKAGE_CUSTOM_NAME="$CED_SUBSYSTEM_NAME"
PACKAGE_VERSION="$CED_VERSION_ID"
EXEC_FILE="$CED_SUBSYSTEM_CONFIG_EXEC_FILE"
ICON_URL="$CED_SUBSYSTEM_CONFIG_ICON_URL"


MAINTAINER="Alafia Support <support@alafia.ai>"
ARCHITECTURES=(amd64 arm64)

INSTALL_DIR="$HOME/local"
BIN_DIR="$INSTALL_DIR/usr/bin"
LIB_DIR="$INSTALL_DIR/usr/share/perl5"
MAN_DIR="$INSTALL_DIR/usr/share/man"

export PATH="$BIN_DIR:$PATH"
export PERL5LIB="$LIB_DIR:$PERL5LIB"
export MANPATH="$MAN_DIR:$MANPATH"

# Create Workspace
BASE_DIR=$CED_ARTIFACT_FOLDER
TEMP_DIR=$(mktemp -d)
mv $BASE_DIR/* $TEMP_DIR/

WORKDIR="${BASE_DIR}/${PACKAGE_NAME}-${PACKAGE_VERSION}"
mkdir -p "$WORKDIR/debian/icons" "$WORKDIR/opt/$PACKAGE_NAME"
ICON_FILE="$WORKDIR/debian/icons/$PACKAGE_NAME.png"

cd "$WORKDIR"

# Copy precompiled binaries and libraries
cp -fr "$TEMP_DIR/"* "$WORKDIR/opt/$PACKAGE_NAME/"

# Getting the icon
curl -o "$ICON_FILE" "$ICON_URL"

# Create debian/control
cat <<EOF > debian/control
Source: $PACKAGE_NAME
Section: utils
Priority: optional
Maintainer: $MAINTAINER
Standards-Version: 4.5.0
Build-Depends: debhelper-compat (= 12)

Package: $PACKAGE_NAME
Architecture: ${ARCHITECTURES[*]}
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: ALAFIA $PACKAGE_NAME Debian Package.
EOF

# Create debian/changelog
cat <<EOF > debian/changelog
$PACKAGE_NAME ($PACKAGE_VERSION-1) jammy; urgency=low

  * Initial release.

 -- $MAINTAINER  $(date -R)
EOF

# Create debian/rules
cat <<EOF > debian/rules
#!/usr/bin/make -f

export DEB_BUILD_MAINT_OPTIONS = hardening=+all
export DEB_CFLAGS_MAINT_APPEND = -g -O2
export DEB_LDFLAGS_MAINT_APPEND = -Wl,-z,relro,-z,now

# Disable debug symbols globally for arm64
export DEB_BUILD_OPTIONS=nostrip nodbg

%:
	dh \$@

override_dh_install:
	dh_install
	mkdir -p debian/$PACKAGE_NAME/usr/share/applications
	cp debian/$PACKAGE_NAME.desktop debian/$PACKAGE_NAME/usr/share/applications/
	install -Dm755 debian/postinst debian/$PACKAGE_NAME/DEBIAN/postinst
	install -Dm755 debian/postrm debian/$PACKAGE_NAME/DEBIAN/postrm

EOF
chmod +x debian/rules

# Create debian/install
cat <<EOF > debian/install
opt/$PACKAGE_NAME/* /opt/$PACKAGE_NAME/
debian/$PACKAGE_NAME.desktop /usr/share/applications/
debian/icons/$PACKAGE_NAME.png /usr/share/icons/hicolor/128x128/apps/
EOF

# Create debian/$PACKAGE_NAME.desktop
cat <<EOF > debian/$PACKAGE_NAME.desktop
[Desktop Entry]
Version=$PACKAGE_VERSION
Name=$PACKAGE_CUSTOM_NAME
Comment=Run the Alafia $PACKAGE_CUSTOM_NAME application
Exec=/opt/$PACKAGE_NAME/$EXEC_FILE
Icon=$PACKAGE_NAME
Terminal=false
Type=Application
Categories=Utility;
EOF

# Create debian/postinst
cat <<EOF > debian/postinst
#!/bin/bash
set -e

USER_NAME=\$(logname)
USER_HOME=\$(getent passwd \$USER_NAME | cut -d: -f6)

if [ -x /usr/bin/gtk-update-icon-cache ]; then
    gtk-update-icon-cache -q /usr/share/icons/hicolor || true
fi

if [ -d "\$USER_HOME/Desktop" ]; then
    sudo -u \$USER_NAME cp /usr/share/applications/$PACKAGE_NAME.desktop "\$USER_HOME/Desktop/"
    sudo -u \$USER_NAME chmod +x "\$USER_HOME/Desktop/$PACKAGE_NAME.desktop"
    sudo -u \$USER_NAME env XDG_RUNTIME_DIR=/run/user/\$(id -u \$USER_NAME) gio set "\$USER_HOME/Desktop/$PACKAGE_NAME.desktop" metadata::trusted true || true
fi

EOF

chmod +x debian/postinst

# Create debian/postrm
cat <<EOF > debian/postrm
#!/bin/bash
set -e

USER_NAME=\$(logname)
USER_HOME=\$(getent passwd \$USER_NAME | cut -d: -f6)

if [ -d "\$USER_HOME/Desktop" ]; then
    rm -f "\$USER_HOME/Desktop/$PACKAGE_NAME.desktop"
fi
EOF

chmod +x debian/postrm

# Build the Package for Each Architecture
for ARCH in "${ARCHITECTURES[@]}"; do
    debian/rules clean
    echo "::info::$(dpkg-buildpackage -d -us -uc -a $ARCH)::"
done

# List Generated Packages
echo "::info::$(ls -1 ../*.deb)::"