---
layout: post
title: Managing user startup applications with systemd
tags: [Linux, Arch Linux]
---

I recently switched to systemd to manage my startup applications, so this is a
short post explaining the process.

For more details, [Arch Linux wiki][1] has a detailed page about using systemd
to start user applications.

## Non-GUI applications

For non-GUI applications, the setup is very easy. Creating a `.service` file in
`~/.config/systemd/user` and using `systemctl` to enable the service should be
enough.

Here is a sample service file for [devmon][2], a mount helper. The file should
be located at `~/.config/systemd/user/devmon.service`.

```ini
[Unit]
Description=Devmon - Automounts and unmounts optical and removable drives

[Service]
ExecStart=/usr/bin/devmon

[Install]
WantedBy=default.target
```

The service can then be used as a normal `systemctl` service, and enabled using

```
systemctl --user enable devmon
```

The logs can be checked by using

```
journalctl --user
```

## GUI applications

For GUI applications, the only difference is that the `DISPLAY` and `XAUTHORITY`
environment variables need to be set.

On Arch Linux, these variables are exposed to systemd by the script located at
`/etc/X11/xinit/xinitrc.d/50-systemd-user.sh` but when I tried to launch a GUI
application from a service file using the same configuration as above,
the variables did not seem to be available.

It seems to be a timing issue, so the simplest way I found to work around it
was to start the applications in my `~/.xprofile` (any file which runs once X
is launched should be just fine).

First, I created a target for my applications in
`~/.config/systemd/user/user-applications.target` with the following content.

```
[Unit]
Description=User Applications
Requires=default.target
After=default.target
```

Then, I added services for my applications wanted by the above target. The is
an example for Telegram Desktop, located at `~/.config/systemd/user/telegram.service`.

```ini
[Unit]
Description=Telegram Desktop

[Service]
ExecStart=/usr/bin/telegram-desktop -startintray

[Install]
WantedBy=user-applications.target
```

As usual, the service needs to be enabled with `systemctl --user enable telegram`
in order to start automatically.
Finally, all the applications can be started by adding the following line
to `~/.xprofile` or any other file you use to do stuff at boot time.

```
systemctl --user start user-applications.target
```

Note that if some services need other environment variables to be exposed,
this can be done by adding the following before the above line.

```
systemctl --user import-environment VAR_TO_EXPOSE
```


[1]: https://wiki.archlinux.org/index.php/Systemd/User
[2]: https://wiki.archlinux.org/index.php/Udisks#Devmon
