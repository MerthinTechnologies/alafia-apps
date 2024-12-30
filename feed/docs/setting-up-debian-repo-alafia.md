# Guide: Setting Up a Private Debian Repository with Multi-Architecture Support

This guide outlines the steps to set up a private Debian repository on an Ubuntu host using Nginx to serve `.deb` packages for multiple architectures (`amd64` and `arm64`).

---

## **Prerequisites**
1. A host system running Ubuntu.
2. Nginx installed and configured.
3. Root or sudo access.
4. `.deb` package files for `amd64` and `arm64` architectures, located in `/opt/packaging`.

---

## **Step 1: Prepare the Repository Directory**

1. Create the repository directory structure:
   ```bash
   mkdir -p /opt/deb-repo/{conf,incoming,pool,dists/stable/main/binary-amd64,dists/stable/main/binary-arm64}
   ```

2. Move the `.deb` files to the `pool` directory:
   ```bash
   mv /opt/packaging/alafia-qupath_0.1-1_*.deb /opt/deb-repo/pool/
   ```

3. Set appropriate permissions:
   ```bash
   chmod -R o+r /opt/deb-repo
   ```

---

## **Step 2: Configure the Repository**

1. Create the `conf/distributions` file:
   ```bash
   vim /opt/deb-repo/conf/distributions
   ```

2. Add the following content:
   ```plaintext
   Origin: AlafiaRepo
   Label: AlafiaRepo
   Codename: stable
   Architectures: amd64 arm64
   Components: main
   Description: Alafia Private Debian Repository
   SignWith: no
   ```

3. Save and exit.

---

## **Step 3: Generate Metadata**

1. Navigate to the repository directory:
   ```bash
   cd /opt/deb-repo
   ```

2. Generate metadata for both architectures:
   ```bash
   dpkg-scanpackages -a amd64 pool /dev/null | gzip -9c > dists/stable/main/binary-amd64/Packages.gz
   dpkg-scanpackages -a arm64 pool /dev/null | gzip -9c > dists/stable/main/binary-arm64/Packages.gz
   ```

3. Verify that the `Packages.gz` files are created:
   ```bash
   ls -l dists/stable/main/binary-*/Packages.gz
   ```

---

## **Step 4: Configure Nginx**

1. Create a new Nginx site configuration:
   ```bash
   vim /etc/nginx/sites-available/alafia-repo.merthin.net
   ```

2. Add the following content:
   ```nginx
   server {
       root /opt/deb-repo;
       error_log /var/log/nginx/alafia-repo-debug.log debug;
       server_name alafia-repo.merthin.net;

       location / {
           autoindex on;
           autoindex_exact_size off;
           autoindex_format html;

           # Headers for better UX
           add_header Content-Type text/plain;
       }

       listen 443 ssl;
       ssl on;
       ssl_certificate    /etc/ssl/merthin.net.pem;
       ssl_certificate_key /etc/ssl/merthin.net.key;
   }
   ```

3. Save and exit.

4. Enable the site and reload Nginx:
   ```bash
   ln -s /etc/nginx/sites-available/alafia-repo.merthin.net /etc/nginx/sites-enabled/
   nginx -t
   systemctl reload nginx
   ```

---

## **Step 5: Test Repository Access**

1. Verify repository files are accessible:
   ```bash
   curl -I https://alafia-repo.merthin.net/dists/stable/main/binary-amd64/Packages.gz
   curl -I https://alafia-repo.merthin.net/dists/stable/main/binary-arm64/Packages.gz
   ```

   Expect a `200 OK` response for both.

---

## **Step 6: Add the Repository to a Client System**

1. On the client system, add support for both architectures:
   ```bash
   sudo dpkg --add-architecture arm64
   sudo dpkg --add-architecture amd64
   ```

2. Add the repository to the `sources.list` file:
   ```bash
   echo "deb [trusted=yes] https://alafia-repo.merthin.net stable main" | sudo tee /etc/apt/sources.list.d/alafia-repo.list
   ```

3. Update the package list:
   ```bash
   sudo apt update
   ```

4. Verify the repository:
   ```bash
   apt-cache search alafia
   ```

5. Install the desired package:
   - For `amd64` systems:
     ```bash
     sudo apt install alafia-qupath
     ```
   - For `arm64` systems:
     ```bash
     sudo apt install alafia-qupath
     ```

   The package manager will automatically detect the appropriate architecture.

---

## **Optional: Automate Metadata Updates**

1. Create a script to regenerate metadata:
   ```bash
   vim /opt/deb-repo/update-repo.sh
   ```

2. Add the following content:
   ```bash
   #!/bin/bash
   dpkg-scanpackages -a amd64 pool /dev/null | gzip -9c > dists/stable/main/binary-amd64/Packages.gz
   dpkg-scanpackages -a arm64 pool /dev/null | gzip -9c > dists/stable/main/binary-arm64/Packages.gz
   ```

3. Save and exit.

4. Make the script executable:
   ```bash
   chmod +x /opt/deb-repo/update-repo.sh
   ```

5. Run the script whenever `.deb` files are added:
   ```bash
   /opt/deb-repo/update-repo.sh
   ```


