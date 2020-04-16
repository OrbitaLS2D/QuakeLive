server.cfg
Make qlx_redisAddress ""
qlx_redisAddress "/var/run/redis/redis-server.sock"

Redis warnings
WARNING: The TCP backlog setting of 511 cannot be enforced because
WARNING overcommit_memory is set to 0!

add this to /etc/sysctl.conf

Redis Tweaks
vm.overcommit_memory = 1
net.core.somaxconn = 512 

WARNING you have Transparent Huge Pages (THP) support enabled in your kernel.
Edit /etc/default/grub to add transparent_hugepage=never to the GRUB_CMDLINE_LINUX_DEFAULT option:
GRUB_CMDLINE_LINUX_DEFAULT="transparent_hugepage=never quiet splash"
After that, run update-grub command. (Need reboot to take effect)


Remove non linux formatting in filename
sed -i 's/\r$//g'
