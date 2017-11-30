#!/bin/bash
ELASTICSEARCH_URL=${ES_PROTOCOL:-http}://localhost:9200

echo "********************Demo Mode Enabled, using local elasticsearch*********************"
service elasticsearch start
ES_CONNECT_RETRY=30

counter=0
 while [ ! "$(curl -k ${ELASTICSEARCH_URL} 2> /dev/null)" -a $counter -lt $ES_CONNECT_RETRY  ]; do
   sleep 1
   ((counter++))
   echo "waiting for Elasticsearch to be up ($counter/$ES_CONNECT_RETRY)"
 done
 if [ ! "$(curl -k ${ELASTICSEARCH_URL} 2> /dev/null)" ]; then
   echo "Couln't start Elasticsearch. Exiting."
   echo "Elasticsearch log follows below."
   cat /var/log/elasticsearch/elasticsearch.log
   exit 1
 fi


echo "*************************Starting Moloch Viewer + Capture**************"
if [ ! -e '/data/moloch/configure.done' ]; then
echo "**********initial configuration not compelte, running now!***********"
/data/moloch/db/db.pl ${ELASTICSEARCH_URL} init
/data/moloch/bin/moloch_add_user.sh admin "Admin User" thisispassword --admin
touch configure.done
fi


groupmod -g1000 daemon
bin/moloch-capture -c etc/config.ini
cd viewer
../bin/node viewer.js -c ../etc/config.ini
tail -f /data/moloch/logs/capture.log





tail -f /dev/null
