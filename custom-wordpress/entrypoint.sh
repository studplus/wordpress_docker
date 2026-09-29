#!/bin/bash

# Docker creates a missing ./WP_Uploads as root, WordPress needs to write into it
chown www-data:www-data /var/www/html/wp-content/uploads

source /etc/apache2/envvars
cron
exec apache2 -D FOREGROUND
