# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ () ->
  $('input[name="post[locale]"]').click (e) ->
    locale = $(e.target).val()
    href = window.location.href
    href.replace /locale=.{2}/, ''
    window.location.href = "?locale=" + locale

  _.templateSettings =
    interpolate : /\{\{(.+?)\}\}/g
    evaluate: /\{\{\=(.+?)\}\}/g

  fileCurrentIndex = 1

  $('#add-file-link').click (e) ->
    e.preventDefault()
    compiled = _.template $("#add-file-template").html()
    $container = $("#file-uploader-container")
    $container.append compiled({ id: fileCurrentIndex })
    fileCurrentIndex++

  $('#file-uploader-container').on 'click', '.remove-file', (e) ->
    e.preventDefault()
    $(e.target).parents('.file-uploader').remove()

  $('.latex').latex()



