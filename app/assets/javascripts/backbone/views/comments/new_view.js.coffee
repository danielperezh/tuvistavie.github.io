Blog.Views.Comments ||= {}

class Blog.Views.Comments.NewView extends Backbone.View
  template: JST["backbone/templates/comments/new"]

  answer_to_id: null

  events:
    'submit #new-comment': 'save'
    'change input': 'updateModel'
    'change textarea': 'updateModel'

  initialize: (options) ->
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  updateModel: (e) ->
    $target = $(e.target)
    @model.set($target.attr('name'), $target.val())

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      wait: true

      success: (comment) =>
        @model = comment
        @trigger 'done'

      error: (comment, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  resetModel: () ->
    @model = new @collection.model()

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    @delegateEvents()

    return this
