#!/bin/bash
#QL_SETUP.SH
#Setup of a Dedicated Quake Live Server on Ubuntu 18.04 LTS
#Its recommended you read through this file and edit it as needed before you run it.
#You can make changes to the server.cfg in this script or after the server is setup.
#USE AT YOU OWN RISK
#By OrbitaL On 04/17/20 Based on a script by rcb.

#Enable command tracing so the caller can see everything
set -x

#Enable multi-architecture support for 32bit binaries for steamcmd
dpkg --add-architecture i386

#Update repositories
apt-get update

#Install steamcmd
apt-get -y install steamcmd

#Install python, build-essential, git, redis and supervisor
apt-get -y install python3 python3-dev build-essential git redis-server supervisor

#Stop the Redis and Supervisor service
service redis-server stop
service supervisor stop

#Download the python package manager bootstrapper
wget https://bootstrap.pypa.io/get-pip.py

#Execute the pip bootstrapper and let it install itself, then remove it
python3 get-pip.py
rm get-pip.py

#Execute steamcmd and let it update itself
/usr/games/steamcmd +quit

#Install QuakeLive
/usr/games/steamcmd +login anonymous +force_install_dir /home/qlds/ +app_update 349090 +quit

#Create the Steam Workshop content directory structure for QuakeLive
mkdir /home/qlds/steamapps/
mkdir /home/qlds/steamapps/workshop/
mkdir /home/qlds/steamapps/workshop/content/
mkdir /home/qlds/steamapps/workshop/content/282440/

#Create a temporary directory for Minqlx, then change directory to it
mkdir /tmp/minqlx/
cd /tmp/minqlx/

#Download a copy of the Minqlx source code
git clone https://github.com/MinoMino/minqlx.git /tmp/minqlx

#Compile Minqlx
make

#Change current directory to the root directory
cd /

#Move the Minqlx binary to the qlds directory
mv /tmp/minqlx/bin/minqlx.x64.so /home/qlds/minqlx.x64.so

#Move the Minqlx python plugin infrastructure to the qlds directory
mv /tmp/minqlx/bin/minqlx.zip /home/qlds/minqlx.zip

#Move the Minqlx lib loader script to the qlds directory
mv /tmp/minqlx/bin/run_server_x64_minqlx.sh /home/qlds/run_server_x64_minqlx.sh

#Remove the temporary directory
rm -r /tmp/minqlx/

#Download a copy of the default Minqlx plugins
git clone https://github.com/MinoMino/minqlx-plugins.git /home/qlds/minqlx-plugins

#Install Minqlx plugin dependencies
python3 -m pip install -r /home/qlds/minqlx-plugins/requirements.txt

#Make a backup copy of the Redis config
cp /etc/redis/redis.conf /etc/redis/redis.conf.bak

#Create a directory for the Redis Unix Socket
mkdir /var/run/redis

#Edit the Redis config, replacing 'port 6379' with 'port 0'
#Setting 'port 0' disables the TCP listener
sed -i -e 's/port 6379/port 0/g' /etc/redis/redis.conf

#Edit the Redis config, replacing '# unixsocket ' with 'unixsocket '
sed -i -e 's/# unixsocket /unixsocket /g' /etc/redis/redis.conf

#Edit the Redis config, replacing '# unixsocketperm 700' with 'unixsocketperm 777'
sed -i -e 's/# unixsocketperm 700/unixsocketperm 777/g' /etc/redis/redis.conf

#Make a backup copy of the Supervisor config
cp /etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf.bak

#Edit the Supervisor config, replacing '[supervisord]' with '[supervisord]\nuser=root'
sed -i -e 's/\[supervisord\]/\[supervisord\]\nuser=root/g' /etc/supervisor/supervisord.conf

#Create a QuakeLive launch config that Supervisor will consume and execute
#'[program:ql]' names the program, and 'ql' will be used with the supervisorctl command, for instance
#supervisorctl stop ql, supervisorctl start ql, supervisorctl restart ql, etc
echo '[program:ql]' >> /etc/supervisor/conf.d/ql.conf

#Configure Supervisor to execute the Minqlx lib loader script, also increase process and io priority for the qzeroded.x64 process
#'nice -n -10' increases the process priority, giving QuakeLive a more favorable scheduling frequency under heavy CPU load from Redis/Terminal usage etc
#'ionice -c 1 -n 4' increases the io priority, giving QuakeLive first access to the disk
echo 'command=/usr/bin/nice -n -10 /usr/bin/ionice -c 1 -n 4 /home/qlds/run_server_x64_minqlx.sh' >> /etc/supervisor/conf.d/ql.conf

#Configure Supervisor to set the Working Directory of the above command
echo 'directory=/home/qlds/' >> /etc/supervisor/conf.d/ql.conf

#Configure Supervisor to run the above command as root
echo 'user=root' >> /etc/supervisor/conf.d/ql.conf

#Configure Supervisor to automatically run the above command when it starts up
echo 'autostart=true' >> /etc/supervisor/conf.d/ql.conf

#Configure Supervisor to automatically restart the above command if killed prematurely
echo 'autorestart=true' >> /etc/supervisor/conf.d/ql.conf

#Configure Supervisor to attempt to execute the above command 3 times before giving up
echo 'startretries=3' >> /etc/supervisor/conf.d/ql.conf

#Configure sysctl.conf for Redis tweaks to limit redis warnings
echo "### Redis Tweaks" | sudo tee -a /etc/sysctl.conf
echo "vm.overcommit_memory = 1" | sudo tee -a /etc/sysctl.conf
echo "net.core.somaxconn = 512" | sudo tee -a /etc/sysctl.conf

#Configure Grub for Redis tweaks to limit redis warnings
sed -ie 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="transparent_hugepage=never \1"/' /etc/default/grub

#Update grub from our redis changes
update-grub

#change to minqlx-plugins/ dir
cd /home/qlds/minqlx-plugins

#Use wget to get more plugins that are in the new defalt server.cfg
wget https://raw.githubusercontent.com/OrbitaLS2D/QuakeLive/master/minqlx-plugins/wgetplugs.txt

#Download these extra plugins for fun
wget -i wgetplugs.txt

#Change back to the / dir
cd

#Rename the defatl QuakeLive workshop.txt to workshop.txt.bak
mv /home/qlds/baseq3/workshop.txt /home/qlds/baseq3/workshop.txt.bak

#append workshop items to workshop.txt
echo '585892371' >> /home/qlds/baseq3/workshop.txt
echo '620087103' >> /home/qlds/baseq3/workshop.txt
echo '572453229' >> /home/qlds/baseq3/workshop.txt
echo '1250689005' >> /home/qlds/baseq3/workshop.txt
echo '1733859113' >> /home/qlds/baseq3/workshop.txt

#Rename the default QuakeLive mappool_ca.txt to mappool_ca.txt.bak
mv /home/qlds/baseq3/mappool_ca.txt /home/qlds/baseq3/mappool_ca.txt.bak

#Append clanarena maps to mappool_ca.txt
echo 'asylum|ca' >> /home/qlds/baseq3/mappool_ca.txt
echo 'campgrounds|ca' >> /home/qlds/baseq3/mappool_ca.txt
echo 'overkill|ca' >> /home/qlds/baseq3/mappool_ca.txt
echo 'quarantine|ca' >> /home/qlds/baseq3/mappool_ca.txt
echo 'trinity|ca' >> /home/qlds/baseq3/mappool_ca.txt

#Rename the default QuakeLive server.cfg to server.cfg.bak
mv /home/qlds/baseq3/server.cfg /home/qlds/baseq3/server.cfg.bak

#Append QuakeLive server cvars
echo '// ............................. Basic Settings ............................. //' >> /home/qlds/baseq3/server.cfg
echo 'set sv_hostname "YOUR COOL SERVER"' >> /home/qlds/baseq3/server.cfg
echo 'set g_password ""' >> /home/qlds/baseq3/server.cfg
echo 'set sv_tags "COOL,FUN,CA,CTF,FFA,DUEL"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// ............................... Map Cycles ............................... //' >> /home/qlds/baseq3/server.cfg
echo 'set sv_mapPoolFile "mappool_ca.txt"' >> /home/qlds/baseq3/server.cfg
echo 'set serverstartup "map overkill ca"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg' >> /home/qlds/baseq3/server.cfg
echo '// ............................ Client Settings ............................. //' >> /home/qlds/baseq3/server.cfg
echo 'set sv_maxClients "20"' >> /home/qlds/baseq3/server.cfg
echo 'set teamsize "4"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_privateClients "4"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_privatePassword ""' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// ................................. Voting ................................. //' >> /home/qlds/baseq3/server.cfg
echo 'set g_allowVote "1"' >> /home/qlds/baseq3/server.cfg
echo 'set g_voteDelay "15000"' >> /home/qlds/baseq3/server.cfg
echo 'set g_voteLimit "0"' >> /home/qlds/baseq3/server.cfg
echo 'set g_allowVoteMidGame "1"' >> /home/qlds/baseq3/server.cfg
echo 'set g_allowSpecVote "0"' >> /home/qlds/baseq3/server.cfg
echo 'set g_voteFlags "0"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// ....................... Time Limits/Round Settings ....................... //' >> /home/qlds/baseq3/server.cfg
echo 'set sv_warmupReadyPercentage "0.51"' >> /home/qlds/baseq3/server.cfg
echo 'set g_warmupDelay "15"' >> /home/qlds/baseq3/server.cfg
echo 'set g_warmupReadyDelay "20"' >> /home/qlds/baseq3/server.cfg
echo 'set g_warmupReadyDelayAction "2"' >> /home/qlds/baseq3/server.cfg
echo 'set g_inactivity "0"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// ............................. Communication ............................. //' >> /home/qlds/baseq3/server.cfg
echo 'set g_alltalk "1"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// ................................ Network ................................ //' >> /home/qlds/baseq3/server.cfg
echo 'set net_ip ""' >> /home/qlds/baseq3/server.cfg
echo 'set net_port "27960"' >> /home/qlds/baseq3/server.cfg
echo 'set net_strict "1"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_serverType "2"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// ................................ Remote Admin ................................ //' >> /home/qlds/baseq3/server.cfg
echo 'set zmq_rcon_enable "1"' >> /home/qlds/baseq3/server.cfg
echo 'set zmq_rcon_ip "0.0.0.0"' >> /home/qlds/baseq3/server.cfg
echo 'set zmq_rcon_port "28960"' >> /home/qlds/baseq3/server.cfg
echo 'set zmq_rcon_password ""' >> /home/qlds/baseq3/server.cfg
echo 'set zmq_stats_enable "1"' >> /home/qlds/baseq3/server.cfg
echo 'set zmq_stats_ip ""' >> /home/qlds/baseq3/server.cfg
echo 'set zmq_stats_port "27960"' >> /home/qlds/baseq3/server.cfg
echo 'set zmq_stats_password ""' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// ............................ Flood Protection ............................ //' >> /home/qlds/baseq3/server.cfg
echo 'set g_floodprot_maxcount "10"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_floodprotect "20"' >> /home/qlds/baseq3/server.cfg
echo 'set g_floodprot_decay "1000"' >> /home/qlds/baseq3/server.cfg
echo 'set g_accessFile "access.txt"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// ................................ System Settings ................................ //' >> /home/qlds/baseq3/server.cfg
echo 'set sv_master "1"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_fps "40"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_idleExit "120"' >> /home/qlds/baseq3/server.cfg
echo 'set com_hunkMegs "256"' >> /home/qlds/baseq3/server.cfg
echo 'set com_zonemegs "10"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// ............................ MinQLX Settings ............................ //' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_owner "SET YOUR STEAM ID"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_plugins "plugin_manager,balance,ban,essentials,log,names,permission,silence,workshop,aliases,teamsize,branding,protect,players_db,kills,listmaps,commlink,scores,myFun,serverBDM,specqueue"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_pluginsPath "minqlx-plugins"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_commandPrefix "!"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_database "redis"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_redisUnixSocket "1"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_redisAddress "/var/run/redis/redis-server.sock"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_redisDatabase "0"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_redisPassword ""' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// ............................ MinQLX Plugin Settings ............................ //' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg' >> /home/qlds/baseq3/server.cfg
echo '// From essentials plugin essentials.py' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_teamsizeMinimum "1"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_teamsizeMaximum "10"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// From workshop plugin workshop.py' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_workshopReferences "585892371,620087103,572453229,1250689005,1733859113"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// From log plugin log' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_logs "5"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_logsSize "5000000"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// From teamsize plugin teamsize.py' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_teamsizemin "1"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_teamsizemax "12"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// From commlink plugin commlink.py' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_commlinkIdentity "something"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_commlinkServerName "^5Cool^7serv"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_enableConnectDisconnectMessages "0"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_enableCommlinkMessages "1"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// From serverBDM plugin serverBDM.py' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_bdmBalanceAtGameStart "1"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_bdmModifyEloCmds "2"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// From specqueue plugin specqueue.py' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_queueMaxSpecTime "120"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_queueAdminSpec "0"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_queueResetPlayerModels "1"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_queueShuffleOnMapChange "1"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_queueShuffleTime "10"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_queueShuffleMessage "1"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_queueCleanClanTags "2"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// From branding plugin branding.py' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_serverBrandName "COOL SERVER NAME"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_serverBrandTopField "COOL SERVER NAME"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_serverBrandBottomField "COOL ADMIN"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_connectMessage "COOL CONNECT MESSAGE"' >> /home/qlds/baseq3/server.cfg
echo '' >> /home/qlds/baseq3/server.cfg
echo '// From myFun plugin myFun.py' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_funUnrestrictAdmin "1"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_funSoundDelay "3"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_funPlayerSoundRepeat "5"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_funAdminSoundCall "0"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_funLast2Sound "1"' >> /home/qlds/baseq3/server.cfg
echo "" >> /home/qlds/baseq3/server.cfg' >> /home/qlds/baseq3/server.cfg
echo '//Keep@EOF' >> /home/qlds/baseq3/server.cfg
echon 'reload_mappool' >> /home/qlds/baseq3/server.cfg

#Uncomment the line below if you have made changes to the servercfg and are ready to reboot otherwise reboot later.

#reboot
