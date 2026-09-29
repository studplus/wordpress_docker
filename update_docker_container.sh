#!/bin/bash
# Rebuilds the WordPress image with current Debian, Apache and PHP packages and pulls
# current images for Varnish, MariaDB and phpMyAdmin. WordPress files stay in the
# volume wordpress_data; WordPress, plugins and themes update from the admin area.
set -e
cd "$(dirname "$(readlink -f "$0")")"
docker compose pull --ignore-buildable
docker compose build --pull --no-cache
docker compose up -d
docker image prune -f
