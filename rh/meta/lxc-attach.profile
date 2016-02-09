#include <tunables/global>

###PROFILEATTACH### (attach_disconnected) {
 capability,
  network,

  /apps/subutai/** rwklmpix,
  /var/lib/apps/subutai/** rwklmpix,

  /** rwklmpix,
  / rwklmpix,

  /proc/ r,
  /proc/** r,
  /run/** r,
  /sys/** r,
  /dev/** rw,
  /lib/** r,
  /bin/** rpix,
  /usr/** rpix,
  /etc/** rwklmpix,
  /root/** rwklmpix,
  /var/** rwklmpix,
  /writable/** rwklmpix,


  mount,
  remount,
  umount,
  dbus,
  signal,
  ptrace,
  unix,
  pivot_root,
  change_profile -> unconfined,
}

