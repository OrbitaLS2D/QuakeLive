#!/bin/bash
#QL_SW_UPDATER.SH
#The QuakeLive Steam Workshop Updater script downloads all $workshoptxt IDs if they do NOT exist in $workshopdest
#By rcb On 07/11/19

appid="282440"
steamcmd="/usr/games/steamcmd"
workshoptxt="/home/qlds/baseq3/workshop.txt"
workshopsrc="/root/.steam/SteamApps/workshop/content"
workshopdest="/home/qlds/steamapps/workshop/content"

ids=$( sed -e '/^#/d' -e 's/#.*$//' $workshoptxt )
count=$( echo "$ids" | wc -l )
index=0
while (( index < count )); do
        (( index++ ))
        id=$( echo $ids | awk -v i=$index '{print $i}' )
        if [ ! -d "$workshopdest/$appid/$id" ]; then
                $( echo "$steamcmd +login anonymous +workshop_download_item $appid $id +quit" )
                $( mv "$workshopsrc/$appid/$id" "$workshopdest/$appid/$id" )
        fi
done
