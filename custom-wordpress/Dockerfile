FROM debian:12

ARG PHP=8.2 OS_LOCALE="de_DE.UTF-8" TZ="Europe/Berlin"
RUN apt-get update && apt-get install -y locales apt-utils && echo "$OS_LOCALE UTF-8\nde_DE ISO-8859-1\nde_DE@euro ISO-8859-15" >> /etc/locale.gen && locale-gen $OS_LOCALE
ARG LANG=$OS_LOCALE \
    LANGUAGE=$OS_LOCALE \
    LC_ALL=$OS_LOCALE \
    DEBIAN_FRONTEND=noninteractive \
	APACHE_CONF_DIR=/etc/apache2 \
    PHP_CONF_DIR=/etc/php/$PHP \
    PHP_DATA_DIR=/var/lib/php \
	WWW_DIR=/var/www/html \
	PHP_VER="php$PHP"

RUN mkdir -p /usr/share/man/man1

# Install cron msmtp mailutils pdftk

RUN	\
	BUILD_DEPS='software-properties-common' \
    && dpkg-reconfigure locales \
    && apt-get update \
	&& apt-get -o Dpkg::Options::="--force-confnew" install --no-install-recommends -y $BUILD_DEPS lsb-release ca-certificates apt-transport-https gnupg2 wget \
	# PHP8.1 Key
	&& wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' \
	&& apt-get update \
	&& apt-get -o Dpkg::Options::="--force-confnew" upgrade -y \
    && apt-get -o Dpkg::Options::="--force-confnew" install -y curl apache2 libapache2-mod-$PHP_VER php-pear git cron msmtp mailutils nano logrotate zip unzip \
    && apt-get -o Dpkg::Options::="--force-confnew" install -y $PHP_VER-common $PHP_VER-mysql $PHP_VER-xml  $PHP_VER-xmlrpc $PHP_VER-curl $PHP_VER-gd $PHP_VER-imagick $PHP_VER-cli $PHP_VER-dev $PHP_VER-imap $PHP_VER-mbstring $PHP_VER-readline $PHP_VER-opcache $PHP_VER-soap $PHP_VER-zip $PHP_VER-intl $PHP_VER-bcmath \
	# Cleaning
	&& apt-get purge -y --auto-remove $BUILD_DEPS \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/* \
	# Forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/apache2/access.log \
	&& ln -sf /dev/stderr /var/log/apache2/error.log \
	&& chown www-data:www-data $PHP_DATA_DIR -Rf 

# Install Composer
RUN \
	curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer \
	&& chmod +x /usr/local/bin/composer

COPY entrypoint.sh /sbin/entrypoint.sh
COPY cronjob /etc/cron.d/cronjob
COPY aliases /etc/aliases
COPY msmtprc /etc/msmtprc

WORKDIR $WWW_DIR
# Download latest Wordpress
RUN rm -rf index.html \
  && wget https://wordpress.org/latest.zip \
  && unzip latest.zip \
  # Copy Files to Web-Folder to make it available
  && cp -a wordpress/. $WWW_DIR \
  && rm -f -r latest.zip wordpress \
  && chown -Rf www-data:www-data $WWW_DIR 

RUN \
	chmod 644 /etc/msmtprc \
	&& chmod 755 /sbin/entrypoint.sh \
	&& chmod 0644 /etc/cron.d/cronjob \
	&& crontab /etc/cron.d/cronjob \
	&& chown www-data:www-data $WWW_DIR -Rf

COPY php.ini-production $PHP_INI_DIR/php.ini
RUN \
    # Apache settings
    cp /dev/null $APACHE_CONF_DIR/conf-available/other-vhosts-access-log.conf \
    && rm $APACHE_CONF_DIR/sites-enabled/000-default.conf $APACHE_CONF_DIR/sites-available/000-default.conf
COPY apache2.conf $APACHE_CONF_DIR/apache2.conf
COPY app.conf $APACHE_CONF_DIR/sites-available/mydomain.conf
RUN \
	a2enmod rewrite $PHP_VER \
	&& a2ensite mydomain.conf

CMD ["/sbin/entrypoint.sh"]