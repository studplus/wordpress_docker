# wordpress_docker
Docker Template for Wordpress with MariaDB, Varnish and PHPmyAdmin
## basic config
Check:
* /custom-varnish/wordpress.vcl - for all your wp-folders, which one should not be cached
### /custom-wordpress/
* aliases - for your domain name and email-adress
* app.conf - for your domain (ServerAlias) and ServerEMail-Address (ServerAdmin)
* cronjob - change the http://0.0.0.0 to https://yourdomain.com
* msmtprc - it is recommended to use an email-service for sending emails like a smtp of your domain provider (IONOS, STRATO, GoDaddy or AWS SES, Sendgrit, Mailgun,...). Delete the `#` and change here `host` as the smtp of your server smtp.ionos.com, the `port` 587, `user` myuser, `password` my password and the `from` which email address comes the mail from.
* php.ini-production - if needed
* docker-compose.yml - change the `ports`, `user` and `password` if needed and the `MYSQL_DATABASE`
### wordpress configuration
* Enter the Database-Name, User and Password as configured in docker-compose.yml under db
* for Database-Host use only `db` - nothing else