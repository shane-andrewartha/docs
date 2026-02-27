if [ -z "$1" ]
then
   echo Usage example
   echo $0 /splunk_iuf/opt/splunkforwarder/etc/apps/TU_windows_syslog
   echo note: assumes GIT_HOME=/mnt/c/Users/ShaneAndrewartha/git
   exit
fi

# Copy from
GIT_APP_FOLDER=$1 #/splunk_iuf/opt/splunkforwarder/etc/apps/TU_windows_syslog
GIT_HOME=/mnt/c/Users/ShaneAndrewartha/git

# Copy to
SPLUNK_HOME=/opt/splunkforwarder

# Main method

echo Finding files...
DIR=$GIT_HOME$GIT_APP_FOLDER
echo \"dir\": \"$DIR\"
#find $DIR -type f

echo Copying files...
echo \"splunk_home\": \"$SPLUNK_HOME\"
cp -r $DIR $SPLUNK_HOME/etc/apps/
ls -ltr $SPLUNK_HOME/etc/apps/ | tail -1

echo Restricting file permissions...
APP_NAME=`echo $GIT_APP_FOLDER | awk -F'/' '{print $NF}'`
if [ "$APP_NAME" ]
then
   chmod 755 --recursive $SPLUNK_HOME/etc/apps/$APP_NAME
   chmod 640 $SPLUNK_HOME/etc/apps/$APP_NAME/default/*.conf
   chmod 600 $SPLUNK_HOME/etc/apps/$APP_NAME/default/app.conf
   chmod 644 $SPLUNK_HOME/etc/apps/$APP_NAME/metadata/default.meta
   chmod 644 $SPLUNK_HOME/etc/apps/$APP_NAME/lookups/*.csv
   echo "done"
else
   echo "failed"
fi

echo Zipping app folder...
cd $SPLUNK_HOME/etc/apps/
tar czf /tmp/$APP_NAME.tgz $APP_NAME/
cd -

echo Vet app yourself...
ls -al /tmp/vet_app/vet.sh
echo APP_FILE_LOCATION=/tmp/$APP_NAME.tgz

echo Deploy app yourself...
cp /tmp/$APP_NAME.tgz /mnt/c/Users/ShaneAndrewartha/Downloads/

echo Restart splunkd yourself...
echo $SPLUNK_HOME/bin/splunk status
