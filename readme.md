Hi this is my new QL repository, I figured i would fork rcb and create this for my own personal use. 
These files have been edited by me and if these may help you then by all means please use these.
I have included these files and here is a quick description of what thery do.

MULTI_QL_SETUP_DEB.sh

This file with seamlessly install 3 quake live servers on your VPN you can edit this script any
way you wish. I reccomend you scroll to the bottom and edit the three  server config file settings.
Each server will be installed in a separate folder in the directory qlds. 27960, 27961, 27962.

QL_SETUP_DEB.sh

This file will only install a single server. be sure to edit the server config at the bottom of the script accordingly

QL_SW_UPDATER_DEB.sh

This file will download everything in the workshops.txt file located in /qlds/baseq3# and then copy it to the appropriate folder.


All of these shell scipts should be made executable i.e. #chmod +x QL_SETUP_DEB.sh to make the QL_SETUP_DEB executable.

To use these files on your sever you will need to wget the file from here and upload to your server.
i.e. to install a single quake live server you will need to: #wget https://raw.githubusercontent.com/OrbitaLS2D/QuakeLive/master/QL_SETUP_DEB.SH
Then #chmod +x QL_SETUP_DEB.sh
Then #./QL_SETUP_DEB


bashrc

This file if copied to the root of you server will give you shortcuts to important ql folders
It is a per user login for non interactive shells, like when you use putty, its located at ~/.bashrc for each user, not just root
You should copy the contents of this to your txt editor i.e. #nano ~/.bashrc and paste. then save
cdql goes to ql folder
cdqlb baseq3
cdqlc workshop folder fo qlds
then also ads shortcuts for starting and stopping server
qlstat status of server
qlstart pretty straight forward
qlstop stop ql
qlrestart restart the server
qladdworkshopids <id> <id> <id>, i.e. qladdworkshopids 1825794056 . This will append workshop.txt in your baseq3 folder with the supplied workshop ids separated by a space, add asmany as you want.
qlupdateworkshopids this requires the use of QL_SW_UPDATER_DEB.sh this will then download the files located in workshop.txt to the workshop contetnt folder.

oca.factories

This is a quake live factory that adds the proxmine to clanarena. you will have to create a 'scripts' folder in your servers
baseq3 folder. #cd /home/qlds/baseq3 then #mkdir scipts
