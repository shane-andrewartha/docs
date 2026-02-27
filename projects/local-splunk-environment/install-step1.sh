#To make permanent (with bash) you put in ~/.bashrc your PATH=/opt/splunk:$PATH
#PATH=/opt/splunk:$PATH 
#export PATH
#echo $SHELL

#To run as a user other than yourself
#chown -RP splunk:splunk /opt/splunk
#/opt/splunk/bin/splunk start --accept-license -user splunk

#To startup on boot
#[sudo] $SPLUNK_HOME/bin/splunk enable boot-start
#[sudo] $SPLUNK_HOME/bin/splunk enable boot-start -user bob
#[sudo] $SPLUNK_HOME/bin/splunk enable boot-start -user bob -systemd-managed 1

sudo bash
target_dir=/opt/splunk
#target_dir=/opt/splunkforwarder
sudo mkdir $target_dir
sudo chown -R ubuntu:ubuntu $target_dir
exit
