#!/bin/sh
set -e

# code ajouté pour l'utilisation de xdebug avec linux car la valeur : host.docker.internal
# de xdebug.client_host=host.docker.internal utilisée par xdebug 3 n'est pas loadée dans docker
# il faut la faire correspondre à l'ip du host avec ce script
HOST_DOMAIN="host.docker.internal"
if ! ping -q -c1 $HOST_DOMAIN > /dev/null 2>&1
then
 HOST_IP=$(ip route | awk 'NR==1 {print $3}')
 # shellcheck disable=SC2039
 echo -e "$HOST_IP\t$HOST_DOMAIN" >> /etc/hosts
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'php' ] || [ "$1" = 'bin/console' ]; then
  composer update symfony/flex --no-plugins --no-scripts
  composer install --prefer-dist --no-progress --no-suggest --no-interaction
fi

exec docker-php-entrypoint "$@"
