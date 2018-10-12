#!/bin/sh
set -e

if [ "$1" = 'mysqld' ]; then
	DATADIR=`mysqld --verbose --help 2>/dev/null | awk '$1 == "datadir" { print $2; exit }'`
	mkdir -p "$DATADIR"
	chown -R mysql:mysql "$DATADIR"
	if [ ! -d "$DATADIR/mysql" ]; then
		mysql_install_db --user=mysql > /dev/null
	fi

	# create temp file
	tfile=`mktemp`
	if [ ! -f "$tfile" ]; then
		return 1
	fi
	echo "[i] Create temp file: $tfile"

	if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
		echo "[i] MySQL root Password: $MYSQL_ROOT_PASSWORD"
		cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
EOF

	fi

	# Create new database
	if [ -n "$MYSQL_DATABASE" ]; then
		echo "[i] Creating database: $MYSQL_DATABASE"
		echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile
		# set new user and password
		if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
			echo "[i] Creating user: $MYSQL_USER with password $MYSQL_PASSWORD..."
			echo "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
			echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
			echo 'FLUSH PRIVILEGES;' >> $tfile
		fi
	else
		# don't need to create new database, set new user to control all database.
		if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
			echo "[i] Creating user: $MYSQL_USER with password $MYSQL_PASSWORD"
			echo "GRANT ALL ON *.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
			echo 'FLUSH PRIVILEGES;' >> $tfile
		fi
	fi

	if [ -s "$tfile" ]; then
		# run sql in tempfile
		echo "[i] run tempfile: $tfile"
		mysqld --user=mysql --bootstrap --verbose=0 < $tfile
		echo "[i] Sleeping 1 sec"
		sleep 1
	fi
	rm -f $tfile
fi

exec "$@"