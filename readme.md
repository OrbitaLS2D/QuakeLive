Hi this is my new QL repository, I figured i would fork rcb and create this for my own personal use. 
These files have been edited by me and if these may help you then by all means please use these.
I have included these files and here is a quick description of what thery do.

MULTI_QL_SETUP_DEB.sh
This file with seamlessly install 3 quake live servers on your VPN you can edit this script any
way you wish. I reccomend you scroll to the bottom and edit the three  server config file settings.
Each server will be installed in a separate folder in the directory qlds. 27960, 27961, 27962.

QL_SETUP_DEB.sh
This file will only install a single server.

QL_SW_UPDATER_DEB.sh
This file will download everything in the workshops.txt file located in /qlds/baseq3# and then copy it to the appropriate folder.

bashrc
this file if copied to the root of you server will give you shortcuts to important ql folders
cdql goes to ql folder
cdqlb baseq3
cdqlc workshop folder fo qlds
then also ads shortcuts for starting and stopping server
qlstat status of server
qlstart pretty straight forward
qlstop stop ql
qlrestart restart the server
qladdworkshopids thes requires the use of QL_SW_UPDATER_DEB.sh

oca.factories
This is a quake live factory that adds the proxmine to clanarena. you will have to create a 'scripts' folder in your servers
baseq3 folder.