# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

export PATH_QLDS="/home/qlds"
export PATH_QLDS_BASEQ3="/home/qlds/baseq3"
export PATH_QLDS_STEAM_WORKSHOP_CONTENT_APPID="/home/qlds/steamapps/workshop/content/282440"

export QL_STEAM_APPID="282440"
export STEAMCMD="/usr/games/steamcmd"
export PATH_STEAM_WORKSHOP_CONTENT_APPID="/root/.steam/SteamApps/workshop/content/282440"

function cdql {
	cd "$PATH_QLDS"
}
export -f cdql

function cdqlb {
	cd "$PATH_QLDS_BASEQ3"
}
export -f cdqlb

function cdqlc {
	cd "$PATH_QLDS_STEAM_WORKSHOP_CONTENT_APPID"
}
export -f cdqlc

function qladdworkshopids {
	for var in "$@"
	do
		echo "$var" >> "$PATH_QLDS_BASEQ3/workshop.txt"
	done
}
export -f qladdworkshopids

function qlupdateworkshopids {
	$PATH_QLDS/QL_SW_UPDATER_DEB.SH
}
export -f qlupdateworkshopids

function qlstat {
	supervisorctl status ql
}
export -f qlstat

function qlstop {
        supervisorctl stop ql
}
export -f qlstop

function qlstart {
        supervisorctl start ql
}
export -f qlstart

function qlrestart {
        supervisorctl restart ql
}
export -f qlrestart
