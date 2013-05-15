Blog.Views.Comments ||= {}

class Blog.Views.Comments.IndexView extends Backbone.View
  el: '#comments'

  formedShowed: false

  formContainerId: 'comment-form'

  events:
    'click .add-comment': 'showAddComment'

  initialize: (options) ->
    @collection.on 'reset', @addAll
    @collection.on 'add', @addOne
    @collection.on 'all', @refreshTitle
    @newCommentView = new Blog.Views.Comments.NewView({collection: @collection})
    $(document).on 'confirm:complete', (e, answer) =>
      if answer
        htmlId = $(e.target).parents('.comment').first().attr 'id'
        id = htmlId.split('-')[1]
        @collection.remove id
    @render()

  addFormContainer: ($target) ->
    return if @formedShowed and $target.attr('data-id') == @newCommentView.answerToId

    @newCommentView.answerToId = $target.attr 'data-id'

    if @formedShowed
      @newCommentView.remove()

    $element = @getElement $target

    container = $('<div />').attr
      id: @formContainerId
    .css
      display: 'none'

    $element.append container
    @newCommentView.setElement container
    @newCommentView.render()

    @newCommentView.slideShow()

    @formedShowed = true

  hideFormContainer: () =>
    @newCommentView.slideHide()
    setTimeout () =>
      @newCommentView.remove()
      @newCommentView.submitting = false
    , 600

  getElement: ($target) ->
    unless $target.attr 'data-id'
      @$el.children 'header'
    else
      $target.parents('.comment')

  showAddComment: (e) ->
    e.preventDefault()
    @addFormContainer $(e.target)
    @newCommentView.on 'done', () =>
      @hideFormContainer()
      @formedShowed = false
      @newCommentView.resetModel()

  refreshTitle: () =>
    @$('h2').text I18n.t('comments.number', { count: @collection.size() })

  addAll: () =>
    @collection.each @addOne

  addOne: (comment) =>
    view = new Blog.Views.Comments.CommentView({model : comment})
    renderedView = view.render().el
    unless comment.get('answer_to_id')?
      @$('.list').prepend renderedView
    else
      parent = @$("#comment-#{comment.get('answer_to_id')}")
      parent.find('.answers').append renderedView

  render: =>
    @$('.list').empty()
    @addAll()

    return this
