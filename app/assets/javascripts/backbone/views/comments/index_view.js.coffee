Blog.Views.Comments ||= {}

class Blog.Views.Comments.IndexView extends Backbone.View
  el: '#comments'

  formedShowed: false

  formContainerId: 'comment-form'

  events:
    'click .add-comment': 'showAddComment'

  initialize: (options) ->
    @collection.bind('reset', @addAll)
    @collection.bind('add', @addOne)
    @collection.on 'all', @refreshTitle
    @newCommentView = new Blog.Views.Comments.NewView({collection: @collection})
    @render()

  addFormContainer: ($target) ->
    return if @formedShowed and $target.attr('data-id') == @newCommentView.answer_to_id

    @newCommentView.answer_to_id = $target.attr 'data-id'

    if @formedShowed
      $("##{@formContainerId}").remove()

    $element = @getElement $target

    container = $('<div />').attr
      id: @formContainerId
    .css
      display: 'none'

    $element.append container
    @newCommentView.setElement container
    @newCommentView.render()

    container.show('slide', { direction: 'up' }, 500)

    @formedShowed = true

  hideFormContainer: () =>
    container = $("##{@formContainerId}")
    container.hide('slide', { direction: 'up' }, 500)
    setTimeout () =>
      container.remove()
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
    @$('.list').prepend view.render().el

  render: =>
    @$('.list').empty()
    @addAll()

    return this
