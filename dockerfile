FROM drupal:8.4.4
MAINTAINER Julien Carnot oqp.io

# Add ssmtp for mail notifications, mysql-client to connect with drush and rsyslog to log in files, in order to use fail2ban from the host
RUN apt-get update && apt-get install -y ssmtp mysql-client rsyslog vim wget libmagickwand-dev libfreetype6 libpng12-dev libjpeg62-turbo-dev  libimage-exiftool-perl git --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Enable syslog for drupal
RUN echo "local0.* /var/log/drupal.log" >> /etc/rsyslog.conf

# Set servername & run_dir...
COPY apache2.conf /etc/apache2/apache2.conf
ENV APACHE_RUN_DIR 	/var/run/apache2

# Autorotate pics
RUN docker-php-ext-install exif && pecl install imagick && docker-php-ext-enable imagick && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ && docker-php-ext-install gd

# Set date.timezone, sendmail_from, sendmail_path, memory_limit, upload_max_filesize, post_max_size &  redirections & webapp manifests for browsers
COPY php.ini /usr/local/etc/php/php.ini
COPY .htaccess /var/www/html/.htaccess
COPY manifest.json /var/www/html/manifest.json

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN /usr/local/bin/composer config repositories.drupal composer https://packages.drupal.org/8
RUN /usr/local/bin/composer require drupal/address
RUN /usr/local/bin/composer require drupal/image_effects:~2.0
RUN /usr/local/bin/composer global require drush/drush:8.*
ENV PATH /root/.composer/vendor/drush/drush/:$PATH

# Set ssmtp config and secure it
COPY ssmtp.conf /etc/ssmtp/ssmtp.conf

RUN groupadd ssmtp \
    && chown -R :ssmtp /etc/ssmtp/ \
    && chmod 640 /etc/ssmtp/ssmtp.conf \
    && chown :ssmtp /usr/sbin/ssmtp \
    && chmod g+s /usr/sbin/ssmtp

# Set mod_ssl
COPY default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
RUN a2enmod ssl
RUN a2ensite default-ssl

# Set mod_expires and mod_headers
RUN a2enmod expires \
    && a2enmod headers

WORKDIR /var/www/html
EXPOSE 443
