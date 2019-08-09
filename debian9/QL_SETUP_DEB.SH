#!/bin/bash
#QL_SETUP.SH
#Setup of a Dedicated QuakeLive Server on Debian9x64
#By rcb On 06/17/19

#Enable command tracing so the caller can see everything
set -x

#Make a backup copy of the repository source list
cp /etc/apt/sources.list /etc/apt/sources.list.bak

#Append debian's non-free repository for steamcmd
echo 'deb http://deb.debian.org/debian stretch main non-free' >> /etc/apt/sources.list

#Enable multi-architecture support for 32bit binaries for steamcmd
dpkg --add-architecture i386

#Update repositories
apt-get update

#Install steamcmd
apt-get -y install steamcmd

#Restore repository sources and update
rm /etc/apt/sources.list
mv /etc/apt/sources.list.bak /etc/apt/sources.list
apt-get update

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

#Rename the QuakeLive mappool_ca.txt to mappool_ca.txt.bak
mv /home/qlds/baseq3/mappool_ca.txt /home/qlds/baseq3/mappool_ca.txt.bak

#Append clanarena maps to mappool_ca.txt
echo 'asylum|ca' >> /home/qlds/baseq3/mappool_ca.txt
echo 'campgrounds|ca' >> /home/qlds/baseq3/mappool_ca.txt
echo 'overkill|ca' >> /home/qlds/baseq3/mappool_ca.txt
echo 'quarantine|ca' >> /home/qlds/baseq3/mappool_ca.txt
echo 'trinity|ca' >> /home/qlds/baseq3/mappool_ca.txt

#Rename the QuakeLive server.cfg to server.cfg.bak
mv /home/qlds/baseq3/server.cfg /home/qlds/baseq3/server.cfg.bak

#Append QuakeLive server cvars
echo 'set sv_hostname "rcb"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_tags "rcb"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_mapPoolFile "mappool_ca.txt"' >> /home/qlds/baseq3/server.cfg
echo 'set g_accessFile "access.txt"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_maxClients "24"' >> /home/qlds/baseq3/server.cfg
echo 'set g_password ""' >> /home/qlds/baseq3/server.cfg
echo 'set sv_privateClients ""' >> /home/qlds/baseq3/server.cfg
echo 'set sv_privatePassword ""' >> /home/qlds/baseq3/server.cfg
echo 'set com_hunkMegs "256"' >> /home/qlds/baseq3/server.cfg
echo 'set com_zoneMegs "512"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_floodprotect "0"' >> /home/qlds/baseq3/server.cfg
echo 'set g_floodprot_maxcount "10"' >> /home/qlds/baseq3/server.cfg
echo 'set g_floodprot_decay "1000"' >> /home/qlds/baseq3/server.cfg
echo 'set g_voteFlags "0"' >> /home/qlds/baseq3/server.cfg
echo 'set g_allowVote "1"' >> /home/qlds/baseq3/server.cfg
echo 'set g_voteDelay "1"' >> /home/qlds/baseq3/server.cfg
echo 'set g_voteLimit "0"' >> /home/qlds/baseq3/server.cfg
echo 'set g_allowVoteMidGame "1"' >> /home/qlds/baseq3/server.cfg
echo 'set g_allowSpecVote "0"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_warmupReadyPercentage "0.51"' >> /home/qlds/baseq3/server.cfg
echo 'set g_warmupDelay "5"' >> /home/qlds/baseq3/server.cfg
echo 'set g_warmupReadyDelay "0"' >> /home/qlds/baseq3/server.cfg
echo 'set g_warmupReadyDelayAction "1"' >> /home/qlds/baseq3/server.cfg
echo 'set g_inactivity "0"' >> /home/qlds/baseq3/server.cfg
echo 'set g_alltalk "1"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_pure "1"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_serverType "2"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_master "1"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_fps "40"' >> /home/qlds/baseq3/server.cfg
echo 'set sv_idleExit "120"' >> /home/qlds/baseq3/server.cfg
echo 'set zmq_rcon_enable "0"' >> /home/qlds/baseq3/server.cfg
echo 'set zmq_stats_enable "1"' >> /home/qlds/baseq3/server.cfg
echo 'set zmq_stats_password ""' >> /home/qlds/baseq3/server.cfg
echo 'set serverstartup "map campgrounds ca"' >> /home/qlds/baseq3/server.cfg
echo 'set teamsize "4"' >> /home/qlds/baseq3/server.cfg
echo 'set roundlimit "10"' >> /home/qlds/baseq3/server.cfg
echo 'set roundtimelimit "120"' >> /home/qlds/baseq3/server.cfg
echo '//Minqlx' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_owner "your steam id"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_plugins "plugin_manager, essentials, balance, motd, permission, ban, silence, clan, names, log, workshop"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_pluginsPath "minqlx-plugins"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_commandPrefix "!"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_database "redis"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_redisUnixSocket "1"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_redisAddress "/var/run/redis/redis.sock"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_redisDatabase "0"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_redisPassword ""' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_logs "5"' >> /home/qlds/baseq3/server.cfg
echo 'set qlx_logsSize "5000000"' >> /home/qlds/baseq3/server.cfg
echo '//Keep@EOF' >> /home/qlds/baseq3/server.cfg
echo 'reload_mappool' >> /home/qlds/baseq3/server.cfg

#Reboot the server after manual config edits
#reboot
