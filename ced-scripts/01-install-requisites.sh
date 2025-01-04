#!/bin/bash

# Directory for local installation
INSTALL_DIR="$HOME/local"
BIN_DIR="$INSTALL_DIR/usr/bin"
LIB_DIR="$INSTALL_DIR/usr/share/perl5"
MAN_DIR="$INSTALL_DIR/usr/share/man"

export PATH="$BIN_DIR:$PATH"
export PERL5LIB="$LIB_DIR:$PERL5LIB"
export MANPATH="$MAN_DIR:$MANPATH"

# Create necessary directories
mkdir -p "$BIN_DIR" "$LIB_DIR" "$MAN_DIR"

# Array of package URLs (updated to use the mirror)
PACKAGES=(
    "https://mirrors.edge.kernel.org/ubuntu/pool/main/d/debhelper/debhelper_13.6ubuntu1_all.deb"
    "https://mirrors.edge.kernel.org/ubuntu/pool/main/a/autotools-dev/autotools-dev_20180224.1_all.deb"
    "https://mirrors.edge.kernel.org/ubuntu/pool/main/d/dh-autoreconf/dh-autoreconf_19_all.deb"
    "https://mirrors.edge.kernel.org/ubuntu/pool/main/s/strip-nondeterminism/dh-strip-nondeterminism_1.13.0-1_all.deb"
    "https://mirrors.edge.kernel.org/ubuntu/pool/main/d/dpkg/dpkg-dev_1.21.1ubuntu2_all.deb"
    "https://mirrors.edge.kernel.org/ubuntu/pool/main/d/dpkg/libdpkg-perl_1.21.1ubuntu2_all.deb"
    "https://mirrors.edge.kernel.org/ubuntu/pool/main/d/dpkg/dpkg_1.21.1ubuntu2_amd64.deb"
    "https://mirrors.edge.kernel.org/ubuntu/pool/main/d/debugedit/debugedit_5.0-4build1_amd64.deb"
    "https://mirrors.edge.kernel.org/ubuntu/pool/main/d/dwz/dwz_0.14-1build2_amd64.deb"
    "https://mirrors.edge.kernel.org/ubuntu/pool/main/f/file/file_5.41-3_amd64.deb"
    "https://mirrors.edge.kernel.org/ubuntu/pool/main/m/man-db/man-db_2.10.2-1_amd64.deb"
    "https://mirrors.edge.kernel.org/ubuntu/pool/main/p/po-debconf/po-debconf_1.0.21_all.deb"
    "https://mirrors.edge.kernel.org/ubuntu/pool/main/d/debhelper/libdebhelper-perl_13.6ubuntu1_all.deb"
)

# Download and extract packages
echo "::info::Downloading and extracting packages::"
for PACKAGE_URL in "${PACKAGES[@]}"; do
    PACKAGE_NAME=$(basename "$PACKAGE_URL")
    echo "::info::Processing $PACKAGE_NAME::"

    # Download package
    wget -q "$PACKAGE_URL" -O "/tmp/$PACKAGE_NAME" || { echo "::error::Failed to download $PACKAGE_NAME::"; exit 1; }

    # Verify the package is a valid Debian archive
    if ! dpkg-deb -I "/tmp/$PACKAGE_NAME" >/dev/null 2>&1; then
        echo "::error::$PACKAGE_NAME is not a valid Debian package::"
        rm -f "/tmp/$PACKAGE_NAME"
        exit 1
    fi

    # Extract package contents
    dpkg-deb -x "/tmp/$PACKAGE_NAME" "$INSTALL_DIR" || { echo "::error::Failed to extract $PACKAGE_NAME::"; exit 1; }

    # Clean up
    rm -f "/tmp/$PACKAGE_NAME"
done

# Install File::StripNondeterminism module manually
echo "::info::Installing File::StripNondeterminism Perl module::"
TEMP_DIR=$(mktemp -d)
git clone https://salsa.debian.org/reproducible-builds/strip-nondeterminism.git "$TEMP_DIR" || { echo "::error::Failed to clone strip-nondeterminism repository::"; exit 1; }
mkdir -p "$LIB_DIR/File"
cp "$TEMP_DIR/lib/File/StripNondeterminism.pm" "$LIB_DIR/File/" || { echo "::error::Failed to copy StripNondeterminism.pm::"; exit 1; }
rm -rf "$TEMP_DIR"
echo "::info::File::StripNondeterminism installed successfully::"

# Update environment variables
echo "::info::Updating environment variables::"
{
    echo ""
    echo "# Added by setup_debhelper.sh"
    echo "export PATH=$BIN_DIR:\$PATH"
    echo "export PERL5LIB=$LIB_DIR:\$PERL5LIB"
    echo "export MANPATH=$MAN_DIR:\$MANPATH"
} >> "$HOME/.bashrc"

# Verify installation
echo "::info::Verifying installation::"
if command -v dh >/dev/null 2>&1; then
    echo "::info::Debhelper installed successfully::"
else
    echo "::error::Debhelper installation failed. Check the script output for errors::"
fi