Blog.Views.Comments ||= {}

class Blog.Views.Comments.IndexView extends Backbone.View
  el: '#comments-container'

  initialize: (options) ->
    @collection.bind('reset', @addAll)
    @render()

  addAll: () =>
    @collection.each @addOne

  addOne: (comment) =>
    view = new Blog.Views.Comments.CommentView({model : comment})
    @$el.prepend view.render().el

  render: =>
    @$el.empty()
    @addAll()

    return this
