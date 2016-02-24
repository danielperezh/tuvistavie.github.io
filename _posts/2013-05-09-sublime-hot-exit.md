---
title:  "SublimeText hot exit for projects only"
date:   2013-05-09
tags: [Sublime Text]
---

I've been using Sublime Text for quite a while now, and there's been feature  I didn't really like about it: Hot Exit. Actually, it's quite nice when you're working on a project to be able to have your files back again as you were using then, but when you only want to edit a single file it's not very useful. Well, whatsoever, as the API is in Python it's quite simple to get what you want, especially for a simple task like this. So what I did is,

* disable `hot_exit`
* disable `remember_open_files`
* write a short plugin to close the project properly and then exit

The plugin is as simple as this:

```python
import sublime
import sublime_plugin


class HotProjectExit(sublime_plugin.WindowCommand):
    def run(self):
        for v in self.window.views():
            if v.is_dirty():
                v.run_command("save")
        if sublime.version() >= 3000:
            self.window.run_command("close_workspace")
        else:
            self.window.run_command("close_project")
        self.window.run_command('set_layout', {
            "cols": [0.0, 1.0],
            "rows": [0.0, 1.0],
            "cells": [[0, 0, 1, 1]]
        })
        self.window.run_command("close_window")
```

which simply save all the files currently opened, close the project (the API for closing the project have changed with SublimeText3, so the condition is simply to fit both), restore the layout so that you have a single window when you open a single file, and then just close the window.
After, I just binded a shortcut with something like this

```json
{ "keys": ["ctrl+x", "ctrl+c"], "command": "hot_project_exit"}
```

and used it to quit SublimeText. The next time I need all my files, I just need to run

```bash
subl -p myproject.sublime-project & #ST2
subl -p myproject.sublime-workspace & #ST3
```

and I'll get all my files and layout back without having to use hot exit for everything.
