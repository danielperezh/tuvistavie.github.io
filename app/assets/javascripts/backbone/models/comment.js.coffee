if not String::trim?
  String::trim = -> this.replace /^\s+|\s+$/g, ''

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

  validate: (attrs, options) ->
    if not attrs.author? or attrs.author.trim().length == 0
      return I18n.t 'comments.errors.author'
    if not attrs.content? or attrs.content.trim().length == 0
      return I18n.t 'comments.errors.content'

class Blog.Collections.CommentsCollection extends Backbone.Collection
  model: Blog.Models.Comment
  url: '/posts/:id/comments'

  initialize: (models, options) ->
    @url = @url.replace(':id', options.id)

  comparator: (a, b) ->
    if a.get('answer_to_id')? == b.get('answer_to_id')?
      return a.get('created_at') - b.get('created_at')
    return a.get('answer_to_id')? ? 1 : -1
