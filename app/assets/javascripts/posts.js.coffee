# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$('input[name="post[locale]"]').click (e) ->
    locale = $(e.target).val()
    window.location.pathname += "?locale=" + locale