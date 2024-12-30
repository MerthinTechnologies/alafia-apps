# **Guide: Building a Multi-Architecture Debian Package**

## **Overview**
This guide walks you through creating a multi-architecture Debian package for `amd64` and `arm64`, named `alafia-qupath`. The binary files for each architecture are cross-compiled, and the package includes a desktop shortcut.

---

## **Step 1: Prepare the Workspace**

1. Create the project directory:
   ```bash
   mkdir -p /opt/packaging/alafia-qupath-0.1
   cd /opt/packaging/alafia-qupath-0.1
   ```

2. Initialize the `debian` directory:
   ```bash
   mkdir debian
   ```

---

## **Step 2: Write Required Files**

### **`debian/control`**
Create and edit the `control` file:
```bash
vim debian/control
```

Content:
```plaintext
Source: alafia-qupath
Section: utils
Priority: optional
Maintainer: Alafia Support <support@alafia.ai>
Standards-Version: 4.5.0
Build-Depends: debhelper-compat (= 12)

Package: alafia-qupath
Architecture: amd64 arm64
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: A multi-architecture package for testing ALAFIA applications
 This package demonstrates creating Debian packages for multiple architectures.
```

---

### **`debian/changelog`**
Create and edit the `changelog` file:
```bash
vim debian/changelog
```

Content:
```plaintext
alafia-qupath (0.1-1) jammy; urgency=low

  * Initial release.

 -- Alafia Support <support@alafia.ai>  Sat, 28 Dec 2024 12:00:00 +0000
```

---

### **`debian/rules`**
Create and edit the `rules` file:
```bash
vim debian/rules
```

Content:
```makefile
#!/usr/bin/make -f

export DEB_BUILD_MAINT_OPTIONS = hardening=+all
export DEB_CFLAGS_MAINT_APPEND = -g -O2
export DEB_LDFLAGS_MAINT_APPEND = -Wl,-z,relro,-z,now

# Disable debug symbols globally for arm64
export DEB_BUILD_OPTIONS=nostrip nodbg

%:
	dh $@

override_dh_install:
	dh_install
	mkdir -p debian/alafia-qupath/usr/bin
	if [ "$$(dpkg-architecture -qDEB_BUILD_ARCH)" = "amd64" ]; then 		cp usr/bin/amd64/alafia-qupath debian/alafia-qupath/usr/bin/; 	elif [ "$$(dpkg-architecture -qDEB_BUILD_ARCH)" = "arm64" ]; then 		cp usr/bin/arm64/alafia-qupath debian/alafia-qupath/usr/bin/; 	fi
	mkdir -p debian/alafia-qupath/usr/share/applications
	cp debian/alafia-qupath.desktop debian/alafia-qupath/usr/share/applications/
```

Make the file executable:
```bash
chmod +x debian/rules
```

---

### **`debian/alafia-qupath.desktop`**
Create and edit the `.desktop` file:
```bash
vim debian/alafia-qupath.desktop
```

Content:
```plaintext
[Desktop Entry]
Version=1.0
Name=Alafia QuPath
Comment=Run the Alafia QuPath application
Exec=/usr/bin/alafia-qupath
Icon=application-default-icon
Terminal=false
Type=Application
Categories=Utility;
```

---

### **`debian/install`**
Create and edit the `install` file:
```bash
vim debian/install
```

Content:
```plaintext
debian/alafia-qupath.desktop /usr/share/applications/
```

---

### **Source Code File**
Create the `alafia-qupath.c` file in the root directory:
```bash
vim alafia-qupath.c
```

Content:
```c
#include <stdio.h>

int main() {
    printf("Testing ALAFIA QuPath application\n");
    return 0;
}
```

---

## **Step 3: Compile the Binaries**

### **Compile for `amd64`**
```bash
gcc -o usr/bin/amd64/alafia-qupath alafia-qupath.c
```

### **Compile for `arm64`**
Install the cross-compiler if not already installed:
```bash
sudo apt install gcc-aarch64-linux-gnu
```

Compile the binary:
```bash
aarch64-linux-gnu-gcc -o usr/bin/arm64/alafia-qupath alafia-qupath.c
```

Ensure the directories exist:
```bash
mkdir -p usr/bin/amd64 usr/bin/arm64
```

---

## **Step 4: Build the Package**

1. Clean the build environment:
   ```bash
   ./debian/rules clean
   ```

2. Build for `amd64`:
   ```bash
   dpkg-buildpackage -us -uc -aamd64
   ```

3. Build for `arm64`:
   ```bash
   dpkg-buildpackage -us -uc -aarm64
   ```

---

## **Step 5: Verify the Package**

1. Check the generated `.deb` files in the parent directory:
   ```bash
   ls ../*.deb
   ```

2. Install and test the package:
   ```bash
   sudo dpkg -i ../alafia-qupath_0.1-1_amd64.deb  # For amd64
   sudo dpkg -i ../alafia-qupath_0.1-1_arm64.deb  # For arm64
   ```

3. Verify the binary and desktop shortcut:
   - Run the binary:
     ```bash
     /usr/bin/alafia-qupath
     ```
   - Check the desktop shortcut in `/usr/share/applications`.

---

## **Final Directory Structure**
```plaintext
/opt/packaging/alafia-qupath-0.1
├── alafia-qupath.c
├── debian
│   ├── alafia-qupath.desktop
│   ├── changelog
│   ├── control
│   ├── install
│   ├── rules
├── usr
│   └── bin
│       ├── amd64
│       │   └── alafia-qupath
│       └── arm64
│           └── alafia-qupath
```
