# wordpress_docker
Docker template for WordPress with MariaDB, Varnish and phpMyAdmin.

WordPress runs on Debian with Apache and PHP 8.5, Varnish caches in front of it on port 80.
To build with another PHP version, change `ARG PHP` in `custom-wordpress/Dockerfile`.
A step-by-step guide for Debian and Ubuntu, from installing Docker to the first start, is at
[todisco.de (German)](https://todisco.de/de/blog/wordpress-docker) and
[todisco.de (English)](https://todisco.de/en/blog/wordpress-docker).

## Requirements
Docker Engine with the Compose plugin (`docker compose`), installed from Docker's repository:
[Debian](https://docs.docker.com/engine/install/debian/), [Ubuntu](https://docs.docker.com/engine/install/ubuntu/).
The old `docker-compose` package from the distribution is not supported.

## Installation
```
sudo mkdir -p /var/docker
cd /var/docker
sudo git clone https://github.com/studplus/wordpress_docker.git
cd wordpress_docker
```

### Configuration
Change the database credentials before the first start: MariaDB only applies them while `wordpress_db` is still empty.

* docker-compose.yml - `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_ROOT_PASSWORD` and, if needed, the `ports`
* custom-varnish/wordpress.vcl - all your WordPress folders that should not be cached
* custom-mysql/my.cnf - additional MariaDB settings, mounted into `/etc/mysql/conf.d/`

In `custom-wordpress/`:
* aliases - your domain name and email address
* app.conf - your domain (`ServerAlias`) and email address (`ServerAdmin`)
* cronjob - change `http://0.0.0.0` to `https://yourdomain.com`
* msmtprc - use an email service for sending, e.g. the SMTP server of your domain provider (IONOS, STRATO, GoDaddy) or Amazon SES, SendGrid, Mailgun. Remove the `#` and set `host` (e.g. smtp.ionos.com), `port` (e.g. 587), `user`, `password` and `from`, the address the mails come from.
* php.ini-production - PHP settings, uploads up to 20 MB by default

The files in `custom-wordpress/` are copied into the image at build time. After changing them, rebuild with `sudo docker compose up -d --build`.

### Start
```
sudo docker compose up -d
```

| Service    | Port |
|------------|------|
| Varnish    | 80   |
| WordPress  | 8080 |
| phpMyAdmin | 8081 |
| MariaDB    | 3306 |

Docker publishes these ports to the outside, and ufw does not block them. On a public server, bind the ones you only need locally to the host, e.g. `127.0.0.1:3306:3306`.

### WordPress configuration
* Enter the database name, user and password as configured in docker-compose.yml under `db`
* For the database host use only `db` - nothing else

## Data
* WordPress files incl. `wp-config.php`, plugins and themes: Docker volume `wordpress_data`
* Uploads: `WP_Uploads/`
* Database: `wordpress_db/`

## Update the Docker containers
`update_docker_container.sh` rebuilds the WordPress image with current Debian, Apache and PHP packages and pulls current images for Varnish, MariaDB and phpMyAdmin. WordPress itself, plugins and themes stay in the volume and update from the WordPress admin area.

Run it weekly by cronjob on the host:
```
sudo crontab -e
```
insert:

`0 2 * * 7 /var/docker/wordpress_docker/update_docker_container.sh > /dev/null 2>&1`

## Upgrading an installation from before September 2026
Older versions kept the WordPress files inside the container, so every rebuild dropped `wp-config.php`, plugins and themes. Copy them out while the old container is still running:
```
cd /var/docker/wordpress_docker
sudo docker cp wordpress:/var/www/html ./html-backup
```
Get the new version and keep your own changes (credentials, ports, mail settings):
```
sudo git stash
sudo git pull
sudo git stash pop
```
If you changed the database credentials, `git stash pop` reports a conflict in `docker-compose.yml`, and in `custom-mysql/my.cnf` if you edited it. Open the file: above `=======` is the new version, below it your own. Keep your passwords and ports, take everything else from the new version and delete the lines `<<<<<<<`, `=======` and `>>>>>>>`. The `command:` line must no longer start with `mysqld`, current MariaDB images do not have it. The new `my.cnf` only holds additional values; the old full file replaced the image configuration and stops current MariaDB versions from starting. Then clear the conflict state:
```
sudo git reset -q
sudo git stash drop
```
Start the new version and restore the WordPress files into the volume:
```
sudo docker compose up -d --build
sudo docker cp ./html-backup/. wordpress:/var/www/html/
sudo docker exec wordpress chown -R www-data:www-data /var/www/html
```
phpMyAdmin no longer uses a volume. The old one can go: `sudo docker volume rm wordpress_docker_phpmyadmindata`
