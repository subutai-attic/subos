#include <tunables/global>

###PROFILEATTACH### (attach_disconnected) {
  capability,
  network,
  / rwklmpix,
  /** rwklmpix,

  /apps/openvswitch/** rwklmpix,
  /var/lib/apps/openvswitch/** rwklmpix,

  /run/** rwklmpix,
  /var/run/** rwklmpix,

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

