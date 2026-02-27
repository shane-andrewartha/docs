'Creates a new Ubuntu VM
'
'How to use
'  multipass-launch.cmd uf1

set HOSTNAME=%1
multipass launch --name %HOSTNAME% -d 4G -m 2G