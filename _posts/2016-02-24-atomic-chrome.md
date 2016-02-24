---
title: "Use Atom to edit in Chrome"
date:   2016-02-24
tags: [Chrome Atom]
---

After [GitHub added plenty of shortcuts](https://github.com/blog/2097-improved-commenting-with-markdown) to edit
markdown in the browser, I had some problem editing directly, having all
the native Emacs like shortcuts overridden.

I decided to use Atom to edit even more or less short comments, but
the copy-pasting was becoming a bit superfluous, taking more time
than it should.
I therefore decided to create a plugin to simplify the process, which I
named [Atomic Chrome](https://github.com/tuvistavie/atomic-chrome).
If you want to know why it is (or at least can be) useful, there [a thread on Hackernews](https://news.ycombinator.com/item?id=11022356) about it.

![Gmail editing](https://cloud.githubusercontent.com/assets/1436271/12668226/afe32e26-c697-11e5-9814-2158e665f774.gif)

I will give a short explanation of how it works here.

The system uses two plugins, a plugin for Google Chrome, and one for
Atom and communicates using WebSockets.
When the Atom plugin starts, it launches a WebSocket server and just waits.
On the Chrome side, when the plugin is launched, it connects to the WebSocket
server, and sends a message to register the current focused textarea.  
The Atom plugin then opens a new tab to edit it, and the content of the textarea
and the Atom tab is synchronized using WS messages.

The process itself is very simple and straightforward, but the implementation
is a little more tedious than it seems to be, mainly due to Chrome security
restrictions.
Basically there were two major issues when implementing this:

1. The content script being executed in the context of the current page,
  if the connection is secured, a non secured WS connection will not work
2. The content script cannot access the page JS, which is ok for textarea
  and content editable, but which makes it impossible to work with JS based
  editor like ACE.

To handle the secured WS issue, the obvious solution was to move the WebSocket
connection to a background script. This adds a layer of message passing, which
goes from

```
Chrome content script -> Atom WS server
```

to

```
Chrome content script -> Chrome background script -> Atom WS server
```

with the `content script -> background script` message passing
done using the [Chrome port](https://developer.chrome.com/extensions/runtime#type-Port).

To be able to access the JS in the page, the solution was to inject a script
into the page that will have full access to it, and make it communicate with
the content script to get and set the value of ACE, or whatever JS editor
we need to handle.
Again, this adds another layer of message passing, so
the final flow becomes something like this:

```
Injected script -> Chrome content script -> Chrome background script -> Atom WS server
```

with the `injected script -> content script` message sent using `window.postMessage`.

After this, it's only a matter of adding a handler to support X or Y text editor.
This is how the class to support [CodeMirror](https://codemirror.net/) looks like.

```javascript
class InjectedCodeMirrorHandler extends BaseInjectedHandler {
  load() {
    this.editor = this.elem.parentElement.parentElement.CodeMirror;
    return Promise.resolve();
  }

  getValue() {
    return this.editor.getValue();
  }

  setValue(text) {
    this.executeSilenced(() => this.editor.setValue(text));
  }

  bindChange(f) {
    this.editor.on('change', this.wrapSilence(f));
  }

  unbindChange(f) {
    this.editor.off('change', f);
  }

  getExtension() {
    const currentModeName = this.editor.getMode().name;
    if (commonModes[currentModeName]) {
      return commonModes[currentModeName];
    }
    for (const mode of CodeMirror.modeInfo) {
      if (mode.mode === currentModeName && mode.ext) {
        return mode.ext[0];
      }
    }
    return null;
  }
}
```

so it would be quite simple to add support for some other editor as well.

I am now planning on adding the possibility to live convert markdown to HTML,
which would give a nice way to write email in markdown and have a live preview
with the email exactly as it will be sent.
