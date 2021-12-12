#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

db_dir=/var/run/mysql/db
set -x
mkdir -p $db_dir 
cp ./mysql/world.sql.gz $db_dir
gunzip $db_dir/world.sql.gz

docker stop mysqldb
docker rm mysqldb
docker run --name mysqldb -v $db_dir:/docker-entrypoint-initdb.d \
     -d --restart=always \
     -e MYSQL_ROOT_PASSWORD=Cyberark1 \
     -e MYSQL_DATABASE=world \
     -e MYSQL_USER=cityapp \
     -e MYSQL_PASSWORD=Cyberark1 \
     -p "3306:3306" -d mysql:5.7.29
set +x

