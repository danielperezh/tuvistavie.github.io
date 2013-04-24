Blog.Views.Comments ||= {}

class Blog.Views.Comments.IndexView extends Backbone.View
  el: '#comments'

  events:
    'click .add-comment': 'showAddComment'

  initialize: (options) ->
    @collection.bind('reset', @addAll)
    @collection.bind('add', @addOne)
    @collection.on 'all', @refreshTitle
    @newCommentView = new Blog.Views.Comments.NewView({collection: @collection})
    @render()

  showAddComment: (e) ->
    e.preventDefault()
    @$('.list').before $('<div />').attr('id', 'comment-form')
    @newCommentView.setElement $('#comment-form')
    @newCommentView.on 'done', () =>
      @$('#comment-form').remove()
      @newCommentView.resetModel()
    @newCommentView.render()

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
