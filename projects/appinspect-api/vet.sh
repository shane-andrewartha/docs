#
# Splunk Cloud          -F "included_tags=cloud"
#
# Valid tags https://dev.splunk.com/enterprise/reference/appinspect/appinspecttagreference/#See-also
#  included_tags=splunk_9_0
#  included_tags=cloud
#

# 1. Get token
YOUR_SPLUNK_DOT_COM_USERNAME=shandr
curl -X GET https://api.splunk.com/2.0/rest/login/splunk -u $YOUR_SPLUNK_DOT_COM_USERNAME

# 2. Post request
TOKEN=eyJraWQiOiJ3M.....
APP_FILE_LOCATION=/tmp/TU_windows.tgz
curl -X POST https://appinspect.splunk.com/v1/app/validate -H "Authorization: bearer $TOKEN" -H "Cache-Control: no-cache" -F "app_package=@$APP_FILE_LOCATION" -F "included_tags=splunk_9_0"

# 3. Check status
REQUEST_ID=2649f132-.....
curl -X GET https://appinspect.splunk.com/v1/app/validate/status/$REQUEST_ID -H "Authorization: bearer $TOKEN"

# 4. Get report
curl -X GET https://appinspect.splunk.com/v1/app/report/$REQUEST_ID -H "Authorization: bearer $TOKEN" -H "Cache-Control: no-cache" -H "Content-Type: text/html" > /mnt/c/Users/ShaneAndrewartha/Downloads/$REQUEST_ID.html

# 5. View report in your web browser
