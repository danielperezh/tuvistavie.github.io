Blog.Views.Comments ||= {}

class Blog.Views.Comments.CommentView extends Backbone.View
  template: JST["backbone/templates/comments/comment"]
  popup: JST["backbone/templates/comments/confirmation"]

  events:
    'mouseenter .container': 'showReply'
    'mouseleave .container': 'hideReply'

  tagName: "div"

  initialize: (options) ->
    @destroyPath = Routes.post_comment_path(postId, options.model.id);

  attributes: () ->
    class: 'comment'
    id: "comment-#{@model.get 'id'}"

  showReply: (e) ->
    e.stopPropagation()
    @$('.reply').first().css 'display', 'inline'

  hideReply: (e) ->
    e.stopPropagation()
    @$('.reply').first().css 'display', 'none'

  render: ->
    model = _.extend({destroyPath: @destroyPath}, @model.toJSON())
    @$el.html(@template(model))
    return this
