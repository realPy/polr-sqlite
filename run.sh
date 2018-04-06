#!/bin/sh
set -x


if [ -z ${POLR_ADMIN_PASSWORD+x} ]; then
export POLR_ADMIN_PASSWORD="password"
fi

if [ -z ${APP_ADDRESS+x} ]; then
export APP_ADDRESS="mydomain.com"
fi

if [ -z ${APP_PROTOCOL+x} ]; then
export APP_PROTOCOL="http://"
fi

if [ -z ${APP_NAME+x} ]; then
export APP_NAME="Docker Polr"
fi


if [ -z ${APP_KEY+x} ]; then
export APP_KEY=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
fi


if [ -z ${TMP_SETUP_AUTH_KEY+x} ]; then
export TMP_SETUP_AUTH_KEY=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
fi

if [ ! -d "/polr_db" ]; then
mkdir /polr_db

fi

chown www-data:www-data -R /polr_db
envsubst < /www/polr/conf_polr > /www/polr/.env

if [ ! -f /polr_db/polr.db ] ; then

 sqlite3 /polr_db/polr.db ".databases"
 chown www-data:www-data /polr_db/polr.db


cd /www/polr/
echo "yes" | php artisan migrate
CRYPTPWD=`php -r "echo password_hash('$POLR_ADMIN_PASSWORD', PASSWORD_BCRYPT, ['cost' => 8]) . PHP_EOL;"`
RECOVERY_KEY=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 100 | head -n 1`
DATE=`date '+%Y-%m-%d %H:%M:%S'`
sqlite3 /polr_db/polr.db "INSERT INTO users VALUES(1,'admin','$CRYPTPWD','admin@polr.me','127.0.0.1','$RECOVERY_KEY','admin','1',NULL,0,'60','$DATE','$DATE',NULL);"

fi


php-fpm
nginx


