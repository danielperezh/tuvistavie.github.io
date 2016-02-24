---
title:  "Grunt errors in browser"
date:   2014-08-21
tags: [Grunt NodeJS]
---

I have been using Grunt for quite a while, but I had never found anything to handle compile errors, to show them in the web browser, for example.

After looking around, I found some  [dead posts on StackOverflow](http://stackoverflow.com/questions/22607345/grunt-sass-getting-compilation-errors-to-output-to-browser), or some [closed issues on Github](https://github.com/gruntjs/grunt-contrib-sass/issues/129), but nothing that really helps.

So I decided to try to create a [plugin to display compile errors in the browser][grunt-brerror].

![Screencast](http://res.cloudinary.com/dtdu3sqtl/image/upload/c_scale,w_550/v1408153873/optimised_pozz3l.gif)

# Grunt plugin

There were two main issues while implementing the plugin:

* Extract the errors in a way that would work for (almost) everything
* Displaying the error in the browser without stopping the workflow

## Error handling

To extract the error message, as Grunt does not, as far as I know provides any easy way to do this, the simplest thing to do was to hook `grunt.log` methods to append the output to some buffer.

```coffeescript
appendBuffer = (msg) -> buffer += msg
appendBufferLn = (msg) -> appendBuffer(msg + "\n")
grunt.util.hooker.hook grunt.log, 'write', appendBuffer
grunt.util.hooker.hook grunt.log, 'writeln', appendBufferLn
grunt.util.hooker.hook grunt.log, 'error', appendBufferLn
```

and to check if an error has occured or not, switch the `force` flag to `true` before starting the task, hook `grunt.fail.warn` to register the error, and restore back the flag.

```coffeescript
grunt.util.hooker.hook grunt.fail, 'warn', ( (e) -> error = e )
```

with this, after running the task, just need to check if `error` is `null` or not, and if it is not, handle the error.

## Browser display

### Background

A designer of my team told me he would rather have the errors display in his browser, to avoid needing to have to check his terminal all day long for nothing. Of course, I wanted to avoid stopping the workflow, by forcing him to close a tab every time an error occured.

One solution would be to insert some script in all the pages, this is what is often done for [LiveReload](https://github.com/intesso/connect-livereload),
and to use it to display errors on the page when needed, but I prefered having a different page for displaying the error rather than to use the page we are working on, so I decided to have a different page, and to close it using websockets.

### Implementation

The problem while implementing this is that everything runs in a different process, and the process stops after the compilation, so no easy way to keep track of the opened error pages.

To take care of all this, I created a task to run a websocket server taking care of all this and to send the success or error to the server during the compilation process. The server then shows the error page if there is any error, or closes the error page otherwise.

```coffeescript
showError = ->
  errorHtml = template({ errors: errors, port: options.port })
  fs.writeFileSync ERROR_FILE_PATH, errorHtml
  opn ERROR_FILE_PATH, { keepFocus: true }
closeWindow = ->
  client.send('close') for i, client of clients
handlers =
  error: (error) ->
    closeWindow()
    errors[error.task] = error
    showError()
  success: (task) ->
    closeWindow()
    delete errors[task]
    showError() unless _.isEmpty(errors)
wss.on 'connection', (ws) ->
  id = currentId
  clients[id] = ws
  currentId++
  ws.on 'message', (message) ->
    message = JSON.parse message
    handlers[message.code](message.data)
  ws.on 'close', ->
    delete clients[id]
```


The full source is [available on Github][grunt-brerror].


[grunt-brerror]: https://github.com/claudetech/grunt-brerror
