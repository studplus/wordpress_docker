# wordpress_docker
Docker Template for WordPress with MariaDB, Varnish and PHPMyAdmin

## System Requirements
- Docker and Docker Compose installed
- Debian Trixie based images
- PHP 8.4
- Varnish Cache (stable)
- MariaDB latest

## Basic Configuration
### Installation
* Navigate to your /opt folder

`cd /opt`
* Clone the git project

`git clone https://github.com/studplus/wordpress_docker.git`
* Navigate to project directory

`cd wordpress_docker`
* Check and configure:

/custom-varnish/wordpress.vcl - Configure WordPress folders that should not be cached
### Configuration Files in /custom-wordpress/
* **aliases** - Configure your domain name and email address
* **app.conf** - Set your domain (ServerAlias) and ServerAdmin email address
* **cronjob** - Change http://0.0.0.0 to https://yourdomain.com
* **msmtprc** - Email configuration (recommended to use an email service):
  - Supported providers: IONOS, STRATO, GoDaddy, AWS SES, SendGrid, Mailgun
  - Remove `#` and configure:
    - `host`: Your SMTP server (e.g., smtp.ionos.com)
    - `port`: Usually 587
    - `user`: Your SMTP username
    - `password`: Your SMTP password
    - `from`: Sender email address
* **php.ini-production** - PHP configuration (adjust if needed)
* **docker-compose.yml** - Configure ports, database credentials, and MYSQL_DATABASE

### WordPress Configuration
* Enter Database credentials as configured in docker-compose.yml under the `db` section:
  - Database Name: wordpress (or as configured)
  - Database User: user (or as configured)
  - Database Password: password (change in production!)
* **Important**: For Database Host use only `db` - nothing else

## Starting the Application
```bash
docker-compose up -d
```

## Updating Docker Containers
Run the update script with a cronjob every week on your host system:

```bash
chmod +x ./update_docker_container.sh
crontab -e
```

Add this line to run updates every Sunday at 2:00 AM:

`00 02 * * 7 /opt/wordpress_docker/update_docker_container.sh > /dev/null 2>&1`

## Accessing Services
- **WordPress**: http://localhost:8080 (via Apache) or http://localhost (via Varnish)
- **PHPMyAdmin**: http://localhost:8081
- **Database**: localhost:3306

## Technical Details
- **Base Image**: Debian Trixie
- **PHP Version**: 8.4
- **Varnish**: Stable release with WordPress-optimized VCL configuration
- **MariaDB**: Latest stable version
- **Caching**: Varnish configured for optimal WordPress performance

