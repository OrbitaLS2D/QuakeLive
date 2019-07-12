#!/bin/bash
set -x

cp /etc/apt/sources.list /etc/apt/sources.list.bak

echo 'deb http://deb.debian.org/debian stretch main non-free' >> /etc/apt/sources.list

dpkg --add-architecture i386

apt-get update

apt-get -y install steamcmd

rm /etc/apt/sources.list
mv /etc/apt/sources.list.bak /etc/apt/sources.list
apt-get update

apt-get -y install python3 python3-dev build-essential git redis-server supervisor

service redis-server stop
service supervisor stop

wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm get-pip.py

/usr/games/steamcmd +quit
/usr/games/steamcmd +login anonymous +force_install_dir /home/qlds/27960/ +app_update 349090 +quit

mkdir /home/qlds/27960/steamapps/
mkdir /home/qlds/27960/steamapps/workshop/
mkdir /home/qlds/27960/steamapps/workshop/content/
mkdir /home/qlds/27960/steamapps/workshop/content/282440/

mkdir /tmp/minqlx/
cd /tmp/minqlx/

git clone https://github.com/MinoMino/minqlx.git /tmp/minqlx

make

cd /

mv /tmp/minqlx/bin/minqlx.x64.so /home/qlds/27960/minqlx.x64.so

mv /tmp/minqlx/bin/minqlx.zip /home/qlds/27960/minqlx.zip

mv /tmp/minqlx/bin/run_server_x64_minqlx.sh /home/qlds/27960/run_server_x64_minqlx.sh

rm -r /tmp/minqlx/

git clone https://github.com/MinoMino/minqlx-plugins.git /home/qlds/27960/minqlx-plugins

python3 -m pip install -r /home/qlds/27960/minqlx-plugins/requirements.txt

#################################################################################################
cp -a /home/qlds/27960/. /home/qlds/27961/
cp -a /home/qlds/27960/. /home/qlds/27962/
#################################################################################################

cp /etc/redis/redis.conf /etc/redis/redis.conf.bak
mkdir /var/run/redis

sed -i -e 's/port 6379/port 0/g' /etc/redis/redis.conf
sed -i -e 's/# unixsocket /unixsocket /g' /etc/redis/redis.conf
sed -i -e 's/ \/tmp\/redis.sock/ \/var\/run\/redis\/redis.sock/g' /etc/redis/redis.conf
sed -i -e 's/# unixsocketperm 700/unixsocketperm 777/g' /etc/redis/redis.conf

cp /etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf.bak
sed -i -e 's/\[supervisord\]/\[supervisord\]\nuser=root/g' /etc/supervisor/supervisord.conf

echo '[program:ql60]' >> /etc/supervisor/conf.d/ql60.conf
echo 'command=/usr/bin/nice -n -10 /usr/bin/ionice -c 1 -n 4 /home/qlds/27960/run_server_x64_minqlx.sh' >> /etc/supervisor/conf.d/ql60.conf
echo 'directory=/home/qlds/27960/' >> /etc/supervisor/conf.d/ql60.conf
echo 'user=root' >> /etc/supervisor/conf.d/ql60.conf
echo 'autostart=true' >> /etc/supervisor/conf.d/ql60.conf
echo 'autorestart=true' >> /etc/supervisor/conf.d/ql60.conf
echo 'startretries=3' >> /etc/supervisor/conf.d/ql60.conf
echo 'process_name=qzeroded.x64_60' >> /etc/supervisor/conf.d/ql60.conf

mv /home/qlds/27960/baseq3/mappool_ca.txt /home/qlds/27960/baseq3/mappool_ca.txt.bak

echo 'asylum|ca' >> /home/qlds/27960/baseq3/mappool_ca.txt
echo 'campgrounds|ca' >> /home/qlds/27960/baseq3/mappool_ca.txt
echo 'overkill|ca' >> /home/qlds/27960/baseq3/mappool_ca.txt
echo 'quarantine|ca' >> /home/qlds/27960/baseq3/mappool_ca.txt
echo 'trinity|ca' >> /home/qlds/27960/baseq3/mappool_ca.txt

#Rename the original QuakeLive server.cfg to server.cfg.bak
mv /home/qlds/27960/baseq3/server.cfg /home/qlds/27960/baseq3/server.cfg.bak

#Append basic server.cfg cvars
echo 'set sv_hostname "rcb60"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set sv_tags "rcb"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set sv_mapPoolFile "mappool_ca.txt"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_accessFile "access.txt"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set sv_maxClients "24"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_password ""' >> /home/qlds/27960/baseq3/server.cfg
echo 'set sv_privateClients ""' >> /home/qlds/27960/baseq3/server.cfg
echo 'set sv_privatePassword ""' >> /home/qlds/27960/baseq3/server.cfg
echo 'set com_hunkMegs "256"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set com_zoneMegs "512"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set sv_floodprotect "0"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_floodprot_maxcount "10"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_floodprot_decay "1000"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_voteFlags "0"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_allowVote "1"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_voteDelay "1"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_voteLimit "0"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_allowVoteMidGame "1"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_allowSpecVote "0"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set sv_warmupReadyPercentage "0.51"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_warmupDelay "5"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_warmupReadyDelay "0"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_warmupReadyDelayAction "1"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_inactivity "0"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set g_alltalk "1"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set sv_pure "1"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set net_strict "1"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set net_port "27960"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set sv_serverType "2"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set sv_master "1"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set sv_fps "40"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set sv_idleExit "120"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set zmq_rcon_enable "0"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set zmq_stats_enable "1"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set zmq_stats_port "28960"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set zmq_stats_password ""' >> /home/qlds/27960/baseq3/server.cfg
echo 'set serverstartup "map campgrounds ca"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set teamsize "4"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set roundlimit "10"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set roundtimelimit "120"' >> /home/qlds/27960/baseq3/server.cfg
echo '//Minqlx' >> /home/qlds/27960/baseq3/server.cfg
echo 'set qlx_owner "76561198220302229"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set qlx_plugins "plugin_manager, essentials, balance, motd, permission, ban, silence, clan, names, log, workshop"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set qlx_pluginsPath "minqlx-plugins"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set qlx_commandPrefix "!"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set qlx_database "redis"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set qlx_redisUnixSocket "1"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set qlx_redisAddress "/var/run/redis/redis.sock"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set qlx_redisDatabase "0"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set qlx_redisPassword ""' >> /home/qlds/27960/baseq3/server.cfg
echo 'set qlx_logs "5"' >> /home/qlds/27960/baseq3/server.cfg
echo 'set qlx_logsSize "5000000"' >> /home/qlds/27960/baseq3/server.cfg
echo '//Keep@EOF' >> /home/qlds/27960/baseq3/server.cfg
echo 'reload_mappool' >> /home/qlds/27960/baseq3/server.cfg

#################################################################################################

echo '[program:ql61]' >> /etc/supervisor/conf.d/ql61.conf
echo 'command=/usr/bin/nice -n -10 /usr/bin/ionice -c 1 -n 4 /home/qlds/27961/run_server_x64_minqlx.sh' >> /etc/supervisor/conf.d/ql61.conf
echo 'directory=/home/qlds/27961/' >> /etc/supervisor/conf.d/ql61.conf
echo 'user=root' >> /etc/supervisor/conf.d/ql61.conf
echo 'autostart=true' >> /etc/supervisor/conf.d/ql61.conf
echo 'autorestart=true' >> /etc/supervisor/conf.d/ql61.conf
echo 'startretries=3' >> /etc/supervisor/conf.d/ql61.conf
echo 'process_name=qzeroded.x64_61' >> /etc/supervisor/conf.d/ql61.conf

mv /home/qlds/27961/baseq3/mappool_ca.txt /home/qlds/27961/baseq3/mappool_ca.txt.bak

echo 'asylum|ca' >> /home/qlds/27961/baseq3/mappool_ca.txt
echo 'campgrounds|ca' >> /home/qlds/27961/baseq3/mappool_ca.txt
echo 'overkill|ca' >> /home/qlds/27961/baseq3/mappool_ca.txt
echo 'quarantine|ca' >> /home/qlds/27961/baseq3/mappool_ca.txt
echo 'trinity|ca' >> /home/qlds/27961/baseq3/mappool_ca.txt

mv /home/qlds/27961/baseq3/server.cfg /home/qlds/27961/baseq3/server.cfg.bak

echo 'set sv_hostname "rcb61"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set sv_tags "rcb"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set sv_mapPoolFile "mappool_ca.txt"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_accessFile "access.txt"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set sv_maxClients "24"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_password ""' >> /home/qlds/27961/baseq3/server.cfg
echo 'set sv_privateClients ""' >> /home/qlds/27961/baseq3/server.cfg
echo 'set sv_privatePassword ""' >> /home/qlds/27961/baseq3/server.cfg
echo 'set com_hunkMegs "256"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set com_zoneMegs "512"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set sv_floodprotect "0"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_floodprot_maxcount "10"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_floodprot_decay "1000"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_voteFlags "0"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_allowVote "1"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_voteDelay "1"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_voteLimit "0"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_allowVoteMidGame "1"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_allowSpecVote "0"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set sv_warmupReadyPercentage "0.51"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_warmupDelay "5"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_warmupReadyDelay "0"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_warmupReadyDelayAction "1"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_inactivity "0"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set g_alltalk "1"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set sv_pure "1"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set net_strict "1"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set net_port "27961"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set sv_serverType "2"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set sv_master "1"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set sv_fps "40"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set sv_idleExit "120"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set zmq_rcon_enable "0"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set zmq_stats_enable "1"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set zmq_stats_port "28961"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set zmq_stats_password ""' >> /home/qlds/27961/baseq3/server.cfg
echo 'set serverstartup "map campgrounds ca"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set teamsize "4"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set roundlimit "10"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set roundtimelimit "120"' >> /home/qlds/27961/baseq3/server.cfg
echo '//Minqlx' >> /home/qlds/27961/baseq3/server.cfg
echo 'set qlx_owner "76561198220302229"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set qlx_plugins "plugin_manager, essentials, balance, motd, permission, ban, silence, clan, names, log, workshop"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set qlx_pluginsPath "minqlx-plugins"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set qlx_commandPrefix "!"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set qlx_database "redis"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set qlx_redisUnixSocket "1"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set qlx_redisAddress "/var/run/redis/redis.sock"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set qlx_redisDatabase "1"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set qlx_redisPassword ""' >> /home/qlds/27961/baseq3/server.cfg
echo 'set qlx_logs "5"' >> /home/qlds/27961/baseq3/server.cfg
echo 'set qlx_logsSize "5000000"' >> /home/qlds/27961/baseq3/server.cfg
echo '//Keep@EOF' >> /home/qlds/27961/baseq3/server.cfg
echo 'reload_mappool' >> /home/qlds/27961/baseq3/server.cfg

#################################################################################################

echo '[program:ql62]' >> /etc/supervisor/conf.d/ql62.conf
echo 'command=/usr/bin/nice -n -10 /usr/bin/ionice -c 1 -n 4 /home/qlds/27962/run_server_x64_minqlx.sh' >> /etc/supervisor/conf.d/ql62.conf
echo 'directory=/home/qlds/27962/' >> /etc/supervisor/conf.d/ql62.conf
echo 'user=root' >> /etc/supervisor/conf.d/ql62.conf
echo 'autostart=true' >> /etc/supervisor/conf.d/ql62.conf
echo 'autorestart=true' >> /etc/supervisor/conf.d/ql62.conf
echo 'startretries=3' >> /etc/supervisor/conf.d/ql62.conf
echo 'process_name=qzeroded.x64_62' >> /etc/supervisor/conf.d/ql62.conf

mv /home/qlds/27962/baseq3/mappool_ca.txt /home/qlds/27962/baseq3/mappool_ca.txt.bak

echo 'asylum|ca' >> /home/qlds/27962/baseq3/mappool_ca.txt
echo 'campgrounds|ca' >> /home/qlds/27962/baseq3/mappool_ca.txt
echo 'overkill|ca' >> /home/qlds/27962/baseq3/mappool_ca.txt
echo 'quarantine|ca' >> /home/qlds/27962/baseq3/mappool_ca.txt
echo 'trinity|ca' >> /home/qlds/27962/baseq3/mappool_ca.txt

mv /home/qlds/27962/baseq3/server.cfg /home/qlds/27962/baseq3/server.cfg.bak

echo 'set sv_hostname "rcb62"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set sv_tags "rcb"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set sv_mapPoolFile "mappool_ca.txt"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_accessFile "access.txt"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set sv_maxClients "24"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_password ""' >> /home/qlds/27962/baseq3/server.cfg
echo 'set sv_privateClients ""' >> /home/qlds/27962/baseq3/server.cfg
echo 'set sv_privatePassword ""' >> /home/qlds/27962/baseq3/server.cfg
echo 'set com_hunkMegs "256"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set com_zoneMegs "512"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set sv_floodprotect "0"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_floodprot_maxcount "10"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_floodprot_decay "1000"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_voteFlags "0"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_allowVote "1"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_voteDelay "1"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_voteLimit "0"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_allowVoteMidGame "1"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_allowSpecVote "0"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set sv_warmupReadyPercentage "0.51"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_warmupDelay "5"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_warmupReadyDelay "0"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_warmupReadyDelayAction "1"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_inactivity "0"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set g_alltalk "1"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set sv_pure "1"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set net_strict "1"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set net_port "27962"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set sv_serverType "2"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set sv_master "1"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set sv_fps "40"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set sv_idleExit "120"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set zmq_rcon_enable "0"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set zmq_stats_enable "1"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set zmq_stats_port "28962"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set zmq_stats_password ""' >> /home/qlds/27962/baseq3/server.cfg
echo 'set serverstartup "map campgrounds ca"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set teamsize "4"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set roundlimit "10"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set roundtimelimit "120"' >> /home/qlds/27962/baseq3/server.cfg
echo '//Minqlx' >> /home/qlds/27962/baseq3/server.cfg
echo 'set qlx_owner "76561198220302229"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set qlx_plugins "plugin_manager, essentials, balance, motd, permission, ban, silence, clan, names, log, workshop"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set qlx_pluginsPath "minqlx-plugins"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set qlx_commandPrefix "!"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set qlx_database "redis"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set qlx_redisUnixSocket "1"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set qlx_redisAddress "/var/run/redis/redis.sock"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set qlx_redisDatabase "2"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set qlx_redisPassword ""' >> /home/qlds/27962/baseq3/server.cfg
echo 'set qlx_logs "5"' >> /home/qlds/27962/baseq3/server.cfg
echo 'set qlx_logsSize "5000000"' >> /home/qlds/27962/baseq3/server.cfg
echo '//Keep@EOF' >> /home/qlds/27962/baseq3/server.cfg
echo 'reload_mappool' >> /home/qlds/27962/baseq3/server.cfg