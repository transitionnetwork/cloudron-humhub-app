#!/bin/bash

set -eu

mkdir -p /app/data/modules /app/data/config /run/apache2 /run/app/sessions /app/data/apache /app/data/runtime /app/data/uploads
chown -R www-data /app/data

if [[ ! -f /app/data/php.ini ]]; then
    echo -e "; Add custom PHP configuration in this file\n; Settings here are merged with the package's built-in php.ini\ndisable_functions = \n\n" > /app/data/php.ini
fi

if [ -z "$(ls -A /app/data/config)" ]; then
    cp -r /app/data/tmp/config/* /app/data/config
fi

[[ ! -f /app/data/apache/mpm_prefork.conf ]] && cp /app/code/apache/mpm_prefork.conf /app/data/apache/mpm_prefork.conf
[[ ! -f /app/data/apache/app.conf ]] && cp /app/code/apache/app.conf /app/data/apache/app.conf

sed -i "s/.*'dsn'.*/'dsn' => 'mysql:host=$CLOUDRON_MYSQL_HOST;dbname=$CLOUDRON_MYSQL_DATABASE',/g" /app/data/config/common.php
sed -i "s/.*'username'.*/'username' => '$CLOUDRON_MYSQL_USERNAME',/g" /app/data/config/common.php
sed -i "s/.*'password'.*/'password' => '$CLOUDRON_MYSQL_PASSWORD',/g" /app/data/config/common.php

chown -R www-data:www-data /app/data /run/apache2 /run/app /tmp

echo "==> Starting HumHub"
rm -f "/run/apache2/apache2.pid"
exec /usr/bin/supervisord --configuration /etc/supervisor/supervisord.conf --nodaemon -i Lamp
