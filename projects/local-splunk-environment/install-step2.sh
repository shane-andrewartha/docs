target_file=/tmp/splunk-9.*-Linux-x86_64.tgz
#target_file=/tmp/download-splunk/splunkforwarder-9.2.1-78803f08aabb-Linux-x86_64.tgz
tar xvf $target_file -C /opt
SPLUNK_HOME=/opt/splunk
#SPLUNK_HOME=/opt/splunkforwarder
$SPLUNK_HOME/bin/splunk status --accept-license --answer-yes
