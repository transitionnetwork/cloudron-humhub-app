#!/bin/bash

export SQL_EXISTS=$(printf 'SHOW TABLES LIKE "%s"' "setting")

if [[ $(mysql --user=${CLOUDRON_MYSQL_USERNAME}  --password=${CLOUDRON_MYSQL_PASSWORD} --host=${CLOUDRON_MYSQL_HOST} -e "$SQL_EXISTS" ${CLOUDRON_MYSQL_DATABASE}) ]]
    then
        if [[ -n "${CLOUDRON_LDAP_SERVER:-}" ]]; then
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
        else
            # re-setting mail config
            /usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.systemEmailAddress' "${CLOUDRON_MAIL_FROM}"
            /usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.systemEmailName' "${CLOUDRON_APP_DOMAIN}"
            /usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.transportType' "smtp"
            /usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.hostname' "${CLOUDRON_MAIL_SMTP_SERVER}"
            /usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.port' "${CLOUDRON_MAIL_SMTP_PORT}"
            /usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.username' "${CLOUDRON_MAIL_SMTP_USERNAME}"
            /usr/bin/php /app/code/protected/yii settings/set 'base' 'mailer.password' "${CLOUDRON_MAIL_SMTP_PASSWORD}"
        fi
	else
		echo "Table is empty ..."
fi