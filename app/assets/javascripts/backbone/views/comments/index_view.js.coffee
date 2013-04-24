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

  addFormContainer: (element) ->
    return if @formedShowed
    container = $('<div />').attr
      id: @formContainerId
    .css
      display: 'none'

    @$(element).after container
    @newCommentView.setElement container
    @newCommentView.render()

    container.show('slide', { direction: 'up' }, 500)

    @formedShowed = true

  hideFormContainer: () =>
    container = $("##{@formContainerId}")
    console.log this
    container.hide('slide', { direction: 'up' }, 500)
    setTimeout () =>
      container.remove()
    , 600

  showAddComment: (e) ->
    e.preventDefault()
    @addFormContainer('h2')
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
