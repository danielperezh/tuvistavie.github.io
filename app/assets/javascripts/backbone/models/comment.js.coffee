class Blog.Models.Comment extends Backbone.Model
  paramRoot: 'comment'

  defaults:
    author: null
    gravatar_email: null
    content: null
    answer_to_id: null

  constructor: (attr, options) ->
    options ||= {}
    options.parse = true
    super attr, options

  parse: (response, options) ->
    response.created_at = new Date(Date.parse(response.created_at))
    response

class Blog.Collections.CommentsCollection extends Backbone.Collection
  model: Blog.Models.Comment
  url: '/posts/:id/comments'

  initialize: (models, options) ->
    @url = @url.replace(':id', options.id)

  comparator: (a, b) ->
    if a.get('answer_to_id')? == b.get('answer_to_id')?
      return b.get('created_at') - a.get('created_at')
    return a.get('answer_to_id')? ? 1 : -1
