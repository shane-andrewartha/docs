1. multipass-launch.cmd
	set HOSTNAME=uf1
	multipass launch --name %HOSTNAME% -d 4G -m 1G --cpus 1

	: * ITSI needs more than 2G of memory
	: * SC4SNMP wants -d 50GB -m 8G --cpus 4
	:
	: Later you can adjust your VM like this
	:  multipass set local.spk11.memory=6G
	:  multipass set local.spk11.cpus=4
	:
	:  multipass info spk11

2. 000-build-spk1-vm-instances.txt 	
	:Only need to do 'ssh-keygen' once on your laptop: ssh-keygen -t rsa
	type C:\Users\Shane.Andrewartha\.ssh\id_rsa.pub

	vi ~/.ssh/authorized_keys
	Ctrl-Shift-C

	hostname -I
	Ctrl-Shift-C
	set IP=172.22.151.114

	dir Downloads\splunk*-Linux-x86_64.tgz
	scp Downloads\splunk*-Linux-x86_64.tgz ubuntu@%IP%:/tmp/
	scp Downloads\install-step*.sh ubuntu@%IP%:~/
	scp Downloads\prep*.tgz ubuntu@%IP%:/tmp/

3. chmod a+x ~/install-step*.sh
	~/install-step1.sh
	exit
	sudo ~/install-step2.sh

4. linux-add-user-(add_group).txt
	sudo groupadd splunk
	sudo useradd -g splunk splunk
	sudo passwd splunk

	sudo mkdir /home/splunk       
	sudo chown -R splunk:splunk /home/splunk
	sudo chown -R splunk:splunk /opt/splunkforwarder

	su - splunk
	touch /tmp/tmp.tmp
	mkdir /home/splunk/.ssh
	vi /home/splunk/.ssh/authorized_keys

5. Install Splunk.license file
	/opt/splunk/bin/splunk start
	Settings > Licensing > Add license
	C:\Users\Shane.Andrewartha\Downloads\Splunk (3).License

	Restart Now
	/opt/splunk/bin/splunk restart

6. Create custom sh-app (barebones) - using the Web UI
	cust_app1

7. Create .tgz file
	#sudo chown -R splunk:splunk /opt/splunk/etc/apps/foobar
	cp -R /opt/splunk/etc/apps/cust_app1 /tmp/
	cd /tmp/

	# Remove any files you don't need / don't think you need	
	ls -al /tmp/cust_app1/
	#rm -R /tmp/cust_app1/bin
	#rm -R /tmp/cust_app1/default/data/views
	mv /tmp/cust_app1/local/*.conf /tmp/cust_app1/default/
	rm -R /tmp/cust_app1/local
	mv /tmp/cust_app1/metadata /tmp/
	clear ; ls -alR /tmp/cust_app1

	# Add required appinspect settings to app.conf
	
	# Zip it up
	tar czf $APP_NAME.tgz $APP_NAME/

	# Copy .tgz to laptop
	scp splunk@%IP%:~/appinspect-api/cust_*.tgz C:\Users\Shane.Andrewartha\Downloads\

8. Vet app - as 'ubuntu' user
	scp "C:\Users\Shane.Andrewartha\OneDrive - AC3\Documents\Projects\appinspect-api\vet-function.sh" ubuntu@%IP%:~/appinspect-api/
	chmod 750 ~/appinspect-api/vet-function.sh

	sudo mv /home/splunk/*.tgz /tmp/appinspect-api/
	~/appinspect-api/vet-function.sh shandr /tmp/appinspect-api/$APP_NAME.tgz cloud

	scp ubuntu@%IP%:/tmp/appinspect-api/*.html C:\Users\Shane.Andrewartha\Downloads\

9. Iterate on your app until you pass appinspect like this:

	cd /opt/splunk/etc/apps
	rm -R /tmp/cust_app1/
	cp -R cust_app1/ /tmp/
	 rm /tmp/cust_app1/metadata/local.meta
	 rm -R /tmp/cust_app1/local
	cd /tmp/
	tar czf cust_app1.tgz cust_app1/

NOTES
------
* You probably want your sh-app to have a default nav xml
* Minimal cloud app.conf looks like below

[install]
is_configured = 0

[ui]
is_visible = 1
label = cust_app1

[launcher]
author = 
description = 
version = 0.0.1