#!/usr/bin/env bash
set -e
service mysql start 
sleep 3

echo
echo " * Create use 'root'@'%' grant all privileges and and set password"
mysql -u root -e "CREATE USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"

echo
echo " * Running init scripts from /docker-entrypoint-initdb.d"

if [ -n "$(ls -A /docker-entrypoint-initdb.d/*.sql 2>/dev/null)" ]; then
    for script in $(ls /docker-entrypoint-initdb.d/*.sql | sort -n); do
        echo "   * Executing $script "
        mysql -uroot  --silent < "$script"
    done
else
    echo " * No SQL scripts found in /docker-entrypoint-initdb.d directory"
fi

echo
echo " * Set password on 'root'@'localhost'"
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';FLUSH PRIVILEGES;"   
