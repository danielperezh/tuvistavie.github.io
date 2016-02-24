---
title:  "Run commands only on git update with Ansible"
date:   2015-09-12
tags: [Ansible]
---

I have recently switched my automation workflow from Chef to Ansible, and just bumped into a simple issue.

I wanted to run some commands only when the git repository had been updated, and  do nothing if it was already up to date.

I did not find anything [in the documentation](http://docs.ansible.com/ansible/git_module.html), but after looking a little at the source code, I found out that when using `register`, `myvar.changed` was set to `true` or `false` depending on whether the repository had been updated or not.

So, to get the result I wanted, I just had to write something like this:

```yaml
- name: Fetch project
  git: repo={{ repository }} accept_hostkey=yes dest={{ project_dir }}
  register: gitclone

- name: Build project
  command: make
  when: gitclone.changed
  args:
    chdir: "{{ project_dir }}"
```

I did not found a lot in the documentation about what can be used with `register`, but I found out that it was easy enough to get this info from the source code, as it is a simple as looking for `module.exit_json` calls in the module. For example for the [git module](https://github.com/ansible/ansible-modules-core/blob/devel/files/copy.py#L320).
