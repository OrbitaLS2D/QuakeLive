#server.cfg
<b>Make qlx_redisAddress ""
qlx_redisAddress "/var/run/redis/redis-server.sock"

#Redis warnings
<b>WARNING: The TCP backlog setting of 511 cannot be enforced because
<b>WARNING overcommit_memory is set to 0!

<b>add this to /etc/sysctl.conf
<b>#### Redis Tweaks
<b>vm.overcommit_memory = 1
<b>net.core.somaxconn = 512 

<b>WARNING you have Transparent Huge Pages (THP) support enabled in your kernel.
<b>Edit /etc/default/grub to add transparent_hugepage=never to the GRUB_CMDLINE_LINUX_DEFAULT option:
<b>GRUB_CMDLINE_LINUX_DEFAULT="transparent_hugepage=never quiet splash"
<b>After that, run update-grub command. (Need reboot to take effect)


#Remove non linux formatting in filename
<b>sed -i 's/\r$//g'
