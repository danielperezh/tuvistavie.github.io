# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$('input[name="post[locale]"]').click (e) ->
    locale = $(e.target).val()
    window.location.pathname += "?locale=" + locale

_.templateSettings =
  interpolate : /\{\{(.+?)\}\}/g
  evaluate: /\{\{\=(.+?)\}\}/g

$('#add-picture-link').click (e) ->
    e.preventDefault()
    compiled = _.template $("#add-image-template").html()
    $container = $("#file-uploader-container")
    count = $container.find(".file-uploader").length
    $container.append compiled({ id: count + 1 })

$('#file-uploader-container').on 'click', '.remove-picture', (e) ->
    e.preventDefault()
    $(e.target).parents('.file-uploader').remove()

