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

# initial config
if [[ ! -f /app/data/.initialized ]]; then
    touch /app/data/.initialized
else
    # re-setting LDAP config
    /usr/bin/php /app/code/protected/yii settings/set 'ldap' 'enabled' "1"
    /usr/bin/php /app/code/protected/yii settings/set 'ldap' 'hostname' "${CLOUDRON_LDAP_SERVER}"
    /usr/bin/php /app/code/protected/yii settings/set 'ldap' 'port' "${CLOUDRON_LDAP_PORT}"
    /usr/bin/php /app/code/protected/yii settings/set 'ldap' 'username' "${CLOUDRON_LDAP_BIND_DN}"
    /usr/bin/php /app/code/protected/yii settings/set 'ldap' 'password' "${CLOUDRON_LDAP_BIND_PASSWORD}"
    /usr/bin/php /app/code/protected/yii settings/set 'ldap' 'baseDn' "${CLOUDRON_LDAP_USERS_BASE_DN}"
    /usr/bin/php /app/code/protected/yii settings/set 'ldap' 'loginFilter' "(username=%s)"
    /usr/bin/php /app/code/protected/yii settings/set 'ldap' 'userFilter' '(&(objectclass=user))'
    /usr/bin/php /app/code/protected/yii settings/set 'ldap' 'usernameAttribute' "username"
    /usr/bin/php /app/code/protected/yii settings/set 'ldap' 'emailAttribute' "mail"
    /usr/bin/php /app/code/protected/yii settings/set 'ldap' 'idAttribute' "uid"
    /usr/bin/php /app/code/protected/yii settings/set 'ldap' 'refreshUsers' "1"

    # re-setting mail config
    /usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.systemEmailAddress' "${CLOUDRON_MAIL_FROM}"
	/usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.systemEmailName' "${CLOUDRON_APP_DOMAIN}"
    /usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.transportType' "smtp"
    /usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.hostname' "${CLOUDRON_MAIL_SMTP_SERVER}"
    /usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.port' "${CLOUDRON_MAIL_SMTP_PORT}"
    /usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.username' "${CLOUDRON_MAIL_SMTP_USERNAME}"
    /usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.password' "${CLOUDRON_MAIL_SMTP_PASSWORD}"

    /usr/bin/php /app/code/protected/yii migrate/up --includeModuleMigrations=1 --interactive=0
fi

chown -R www-data:www-data /app/data /run/apache2 /run/app /tmp

echo "==> Starting HumHub"
rm -f "/run/apache2/apache2.pid"
exec /usr/bin/supervisord --configuration /etc/supervisor/supervisord.conf --nodaemon -i Lamp
