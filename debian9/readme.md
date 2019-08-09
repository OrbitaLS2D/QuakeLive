Hi this is my new QL repository, I figured I would fork rcb and create this for my own personal use. 
These files have been edited by me and if these may help you then by all means please use these.
I have included these files and here is a quick description of what they do.

"MULTI_QL_SETUP_DEB.sh"

This file will seamlessly install 3 Quake Live servers on your VPS. You can edit this script any
way you wish. I recommend you scroll to the bottom and edit the three server config file settings.
Each server will be installed in a separate folder in the directory qlds according to the port. 27960, 27961, 27962.

"QL_SETUP_DEB.sh"

This file will only install a single server. Be sure to edit the server config at the bottom of the script accordingly.

"NOTE on installing"

BOTH QL_SETUP_DEB and MULTI_QL_SETUP_DEB will instal minqlx along with several plugins such as:
plugin_manager, essentials, balance, motd, permission, ban, silence, clan, names, log, workshop
for help with these plugins and the available commands see minomino's github repository and have a look at
https://github.com/MinoMino/minqlx/wiki/Command-List
Dont forget to edit the server config with your steam id.
This can be done by editing the QL_SETUP_DEB or MULTI_QL_SETUP_DEB files before executing them to install QL servers.
Look for the line:
"echo 'set qlx_owner "your steam id"' >> /home/qlds/27961/baseq3/server.cfg"
This will give you the ownership of the server and give you the ability to administer server commands with !rcon commands.
 

"QL_SW_UPDATER_DEB.sh"

This file will download everything in the workshops.txt file located in /qlds/baseq3# and then copy it to the appropriate folder.


"NOTICE"

All of these shell scipts should be made executable i.e. #chmod +x QL_SETUP_DEB.sh to make the QL_SETUP_DEB executable.

To use these files on your sever you will need to wget the file from here and upload to your server.
i.e. to install a single Quake Live server you will need to: #wget https://raw.githubusercontent.com/OrbitaLS2D/QuakeLive/master/QL_SETUP_DEB.SH
Then #chmod +x QL_SETUP_DEB.sh
Then #./QL_SETUP_DEB


"bashrc"

This file if copied to the root of you server will give you shortcuts to important ql folders
It is a per user login for non interactive shells, like when you use putty, its located at ~/.bashrc for each user, not just root
You should copy the contents of this to your txt editor i.e. #nano ~/.bashrc and paste then save.

cdql will change the directory to the ql folder
cdqlb will change the directory to the baseq3
cdqlc will change the directory to the workshop folder for qlds

This also adds shortcuts for managing your ql server
qlstat shows status of server
qlstart starts the ql server
qlstop stops the ql server
qlrestart restarts the ql server
qladdworkshopids <id> <id> <id>, i.e. qladdworkshopids 1825794056 . This will append workshop.txt in your baseq3 folder with the supplied workshop ids separated by a space, add as many as you want.
qlupdateworkshopids this requires the use of QL_SW_UPDATER_DEB.sh this will then download the files located in workshop.txt to the workshop content folder.
