# LEMP Stack Setup on Ubuntu 20.04

This guide outlines the steps to install and configure a Linux, Nginx, MySQL, PHP (LEMP stack) on Ubuntu 20.04.

---

## Step 1 – Install Nginx Web Server

```bash
sudo apt update
sudo apt install nginx
```

## Step 2 – Install MySQL

```bash
sudo apt install mysql-server
sudo mysql_secure_installation
```

---

## Step 3 – Install PHP

```bash
sudo apt install php-fpm php-mysql
```

- `php-fpm` is PHP’s FastCGI Process Manager (needed for Nginx).
- `php-mysql` enables PHP to communicate with MySQL.

---

## Step 4 – Configure Nginx to Use PHP

1. Create your web root and set proper ownership:

    ```bash
    sudo mkdir /var/www/your_domain
    sudo chown -R $USER:$USER /var/www/your_domain
    ```

2. Create a new Nginx server block:

    ```bash
    sudo nano /etc/nginx/sites-available/your_domain
    ```

    Paste the configuration:

    ```nginx
    server {
        listen 80;
        server_name your_domain www.your_domain;
        root /var/www/your_domain;

        index index.html index.htm index.php;

        location / {
            try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        }

        location ~ /\.ht {
            deny all;
        }
    }
    ```

3. Enable the configuration and disable the default:

    ```bash
    sudo ln -s /etc/nginx/sites-available/your_domain /etc/nginx/sites-enabled/
    sudo unlink /etc/nginx/sites-enabled/default
    ```

4. Test and reload Nginx:

    ```bash
    sudo nginx -t
    sudo systemctl reload nginx
    ```

5. Create a simple test page:

    ```bash
    nano /var/www/your_domain/index.html
    ```

    Add:

    ```html
    <html>
      <head><title>your_domain website</title></head>
      <body>
        <h1>Hello World!</h1>
        <p>This is the landing page of <strong>your_domain</strong>.</p>
      </body>
    </html>
    ```

---
**From here I get an error**
## Step 5 – Test PHP with Nginx

1. Create a PHP info file:

    ```bash
    nano /var/www/your_domain/info.php
    ```

    Add:

    ```php
    <?php
    phpinfo();
    ```

2. Visit `http://your_domain_or_IP/info.php` — you should see detailed PHP information.

3. For security, remove the file afterward:

    ```bash
    sudo rm /var/www/your_domain/info.php