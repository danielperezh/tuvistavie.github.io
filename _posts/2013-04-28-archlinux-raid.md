---
title:  "Using hardware RAID on Arch Linux"
date:   2013-04-28
tags: [Linux, Arch Linux]
---

I recently installed Arch Linux on my Vaio Type Z and had some problems using the hardware RAID so here's how I managed to make that work.

The installation process is of course perfectly normal. On my computer, after having enabled the hardware RAID, I had a `/dev/md126` device and partitioned to have `/dev/md126_1` mounted on `/boot`. After installing GRUB on the MBR with

```bash
grub-install /dev/md126
```

I tried to boot. GRUB launched properly, however, when trying to boot Arch Linux with the root supposed to be on `/dev/md126_5`, I had an error telling me that this device was not being found. After looking up in [mkinitcpio's documentation](https://wiki.archlinux.org/index.php/Mkinitcpio#Runtime_hooks), I saw that there was a hook for FakeRAID so I booted from a Live USB, chrooted and add this hook with

```bash
pacman -S dmraid
vim /etc/mkinitcpio.conf # add dmraid to HOOKS
mkinitcpio -p linux
```

After rebooting, Arch Linux booted properly with the hardware RAID enabled.
