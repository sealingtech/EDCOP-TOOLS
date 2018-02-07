#!/bin/bash
# Script to initialize moloch, add a user, and run the services
# Please use the master's IP for the ESURL
#!/bin/bash
# Script to initialize moloch, add a user, and run the services
# Please use the master's IP for the ESURL
ESURL="net0"

#echo UPGRADE | /data/moloch/db/db.pl http://$ESURL:9200 upgrade
/data/moloch/bin/moloch_update_geo.sh
chmod a+rwx /data/moloch/raw /data/moloch/logs

echo "Starting Moloch capture and viewer..."
/data/moloch/bin/moloch_config_interfaces.sh
cd /data/moloch
nohup /data/moloch/bin/moloch-capture -c /data/moloch/etc/config.ini >> /data/moloch/logs/capture.log 2>&1 &
cd /data/moloch/viewer
/data/moloch/bin/node viewer.js -c /data/moloch/etc/config.ini >> /data/moloch/logs/viewer.log 2>&1


