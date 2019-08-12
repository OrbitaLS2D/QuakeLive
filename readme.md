Hi this is my new QL repository, I figured I would fork rcb and create this for my own personal use. 
These files have been edited by me and if these may help you then by all means please use these.
I have included these files and here is a quick description of what they do.

For Debian 9 Quake Live Setup have a look at the readme.md in the debina9 folder

oca.factories

This is a Quake Live factory that adds the proxmine to clanarena. you will have to create a 'scripts' folder in your servers
baseq3 folder. #cd /home/qlds/baseq3 then #mkdir scripts

After you create the scripts folder do #cd /home/qlds/baseq3/scripts then #wget https://raw.githubusercontent.com/OrbitaLS2D/QuakeLive/master/oca.factories to download it
then while in game and connected to your server you will need to "!rcon reload_factories" after which you will be able to callvote a new map followed by oca
i.e. "/cv map campgrounds oca" and you will have the proxmine as a playable weapon in clan arena.
