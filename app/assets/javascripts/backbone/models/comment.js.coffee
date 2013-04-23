class Blog.Models.Comment extends Backbone.Model
  paramRoot: 'comment'

  defaults:
    name: null
    gravatar_name: null
    content: null

class Blog.Collections.CommentsCollection extends Backbone.Collection
  model: Blog.Models.Comment
  url: '/comments'
