---
title:  "SSH invalid byte sequence"
date:   2015-02-20
tags: [Chef]
---

Small memo about an issue I had with Chef `knife` and Capistrano commands.

I kept receiving the following error

```
SSHKit::Runner::ExecuteError: Exception while executing as root@192.168.33.33: invalid byte sequence in UTF-8
```

After looking around at my SSH files, I found out that `~/.ssh/known_hosts`
contained some weird data, which was causing the error.
Removing the concerned data fixed the issue for me.
