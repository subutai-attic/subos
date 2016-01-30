#include <tunables/global>

###PROFILEATTACH### (attach_disconnected) {
  capability,
  network,

  /apps/subutai/** rwklmpix,
  /var/lib/apps/subutai/** rwklmpix,
  /proc/sys/net/ipv4/** rwklmpix,

  /run/** rwklmpix,
  /var/run/** rwklmpix,

  /etc/writable/** rwklmpix,
  /proc/ r,
  /proc/** r,
  /run/** r,
  /sys/** r,
  /dev/** rw,
  /lib/** r,
  /bin/** rpix,
  /sbin/** rpix,
  /usr/** rpix,
  /etc/** rwklmpix,
  /root/** rwklmpix,
  /var/** rwklmpix,
  /writable/** rwklmpix,
  /tmp/** rwklmpix,

  mount,
  remount,
  umount,
  dbus,
  signal,
  ptrace,
  unix,
}

