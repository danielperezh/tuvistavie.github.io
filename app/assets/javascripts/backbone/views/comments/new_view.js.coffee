Blog.Views.Comments ||= {}

class Blog.Views.Comments.NewView extends Backbone.View
  template: JST["backbone/templates/comments/new"]

  submitting: false

  events:
    'submit #new-comment': 'save'
    'change input': 'updateModel'
    'change textarea': 'updateModel'

  initialize: (options) ->
    @model = new @collection.model()
    @answerToId = null

    @model.on 'invalid', () =>
      @submitting = false
      @render()

  updateModel: (e) ->
    $target = $(e.target)
    @model.set($target.attr('name'), $target.val())

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @$('input, textarea').trigger 'change'

    return if @submitting

    @submitting = true

    @model.set 'answer_to_id', @answerToId

    unless @model.isValid()
      @submitting = false
      return

    @collection.create(@model.toJSON(),
      wait: true
      success: (comment) =>
        @trigger 'done'
      error: (comment, xhr) =>
        @submitting = false
    )

  slideShow: () ->
    $parentComment = @$el.parents('.comment')
    $commentAnswers = $parentComment.find('.answers .comment')
    if $commentAnswers.length > 1
      $('html, body').animate({scrollTop: $commentAnswers.last().offset().top },
        duration: 200
        complete: () => @$el.show('slide', { direction: 'up' }, 500)
      )
    else
      @$el.show('slide', { direction: 'up' }, 500)

  slideHide: () ->
    @$el.hide('slide', { direction: 'up' }, 500)

  resetModel: () ->
    @model = new @collection.model()
    @model.on 'invalid', () =>
      @submitting = false
      @render()

  render: () ->
    model = _.extend { errors: @model.validationError ? {}}, @model.toJSON()
    @$el.html @template(model)
    @$el.find('textarea').placeholder()
    @delegateEvents()

    return this

