Blog.Views.Comments ||= {}

class Blog.Views.Comments.CommentView extends Backbone.View
  template: JST["backbone/templates/comments/comment"]

  events:
    "click .destroy" : "destroy"
    'mouseenter .container': 'showReply'
    'mouseleave .container': 'hideReply'

  tagName: "div"

  showReply: (e) ->
    e.stopPropagation()
    @$('.reply').first().css 'display', 'inline'

  hideReply: (e) ->
    e.stopPropagation()
    @$('.reply').first().css 'display', 'none'

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
