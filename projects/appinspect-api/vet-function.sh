#
# This script helps you vet apps with splunk's appinpect
#  apt install jq
#
# Usage example
#  ./vet-function.sh shandr /tmp/cust_app1.tgz splunk_9_0
# 
#  YOUR CHOICE OF TAGS
#
#  Splunk Cloud          -F "included_tags=cloud"
#  Splunk Enterprise     -F "included_tags=splunk_9_0"
#
# Refer to https://dev.splunk.com/enterprise/reference/appinspect/appinspecttagreference/#See-also
#

#USER_HOME_FOLDER="~/appinspect-api"
USER_HOME_FOLDER="/tmp/appinspect-api"

#
# Functions
#

# Writes text out to screen (or file)
stdout()
{
   message=$1            # "hello world"

   timestamp=`date +%Y-%m-%dT%H:%M:%S%z`
   echo "$timestamp $FUNCNAME $message"
}

# Creates a directory
create-folder()
{
   temp_folder=$1        # "/tmp/appinspect-api"
   
   folder_exists=`ls -al $temp_folder`
   if [ "$folder_exists" ]
   then
        # do nothing
        :
   else
	 #mkdir_cmd=`which mkdir`
         #`$mkdir_cmd $temp_folder`
         /usr/bin/mkdir $temp_folder
   fi
}

# Removes quote marks
clean-json-string-value()
{
   json_string_value=$1    # "foobar"

   # Removing enclosing quote character
   echo "$json_string_value" | cut -d "\"" -f 2

   echo "$return_string"
}

#
# Main method
#

# Usage helptext
if [ -z "$3" ]
then

   echo Usage examples
   echo $0 shandr /tmp/cust_app1.tgz splunk_9_0
   echo $0 shandr /tmp/cust_app1.tgz cloud \2\>\1 \| grep stdout
   
else
   stdout "Started appinspect for $2 tags=$3 as $1"
   start_time=`date +%s`

   # Proceeding
   YOUR_SPLUNK_DOT_COM_USERNAME=$1
   APP_FILE_LOCATION=$2
   INCLUDED_TAGS=$3

   # Temp directory
   create-folder $USER_HOME_FOLDER

   # [1] Get a token
   stdout "Enter your password for $1:"
   json1=`curl -X GET https://api.splunk.com/2.0/rest/login/splunk -u $YOUR_SPLUNK_DOT_COM_USERNAME`
   #{"errors":"oauth2: cannot fetch token: 400 Bad Request\nResponse: {\"error\":\"invalid_grant\",\"error_description\":\"The credentials provided were invalid.\"}","msg":"Failed to authenticate user","status":"error","status_code":400}

   key_value1=`echo $json1 | jq '.data.token'`
   TOKEN=`clean-json-string-value $key_value1`

   # [2] Post request
   json2=`curl -X POST https://appinspect.splunk.com/v1/app/validate -H "Authorization: bearer $TOKEN" -H "Cache-Control: no-cache" -F "app_package=@$APP_FILE_LOCATION" -F "included_tags=$INCLUDED_TAGS"`

   key_value2=`echo $json2 | jq '.request_id'`
   REQUEST_ID=`clean-json-string-value $key_value2`
   #echo REQUEST_ID=$REQUEST_ID

   # [3] Check status
   wait_time=2
   stdout "Processing request $REQUEST_ID ..."
   REQUEST_STATUS="PROCESSING"
   while [ "$REQUEST_STATUS" == "PROCESSING" ]
   do
	   echo Sleeping for $wait_time sec
	   sleep $wait_time

	   json3=`curl -X GET https://appinspect.splunk.com/v1/app/validate/status/$REQUEST_ID -H "Authorization: bearer $TOKEN"`

	   key_value3=`echo $json3 | jq '.status'`
	   REQUEST_STATUS=`clean-json-string-value $key_value3`
	   #echo REQUEST_STATUS=$REQUEST_STATUS
   done

   # [4] Get report
   curl -X GET https://appinspect.splunk.com/v1/app/report/$REQUEST_ID -H "Authorization: bearer $TOKEN" -H "Cache-Control: no-cache" -H "Content-Type: text/html" > $USER_HOME_FOLDER/$REQUEST_ID.html

   stdout "Review latest report with your web browser $USER_HOME_FOLDER/$REQUEST_ID.html"
   stdout "Download this version of app with: scp `whoami`@%IP%:$2 Downloads\\"
   ls -al $USER_HOME_FOLDER/$REQUEST_ID.html

   end_time=`date +%s`
   elapsed_time="$(($end_time - $start_time))"
   stdout "Ended [Took $elapsed_time sec] $REQUEST_STATUS"
fi
