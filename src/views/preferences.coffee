$        = require('jquery')
_        = require('underscore')
Backbone = require('backbone')

Views    = {}
{ModelView} = require('./views')


class Preferences extends ModelView
    Views: -> Views
    template:  -> AppTemplates.Preferences

    events: ->
        "change input": "onChange"
        "change select": "onChange"
        "submit form": "onChange"
        "click .jsClose": "close"

    _bindData: ->
        super
        @listenTo @_getDataSource(), 'change:gravatar', @changeGravatar
        @listenTo @model, 'press:esc', @close

    changeGravatar: ->
        src = @_getDataSource().get('gravatar')
        @$('.jsGravatar').attr 'src', src

    onChange: (e)->
        e?.preventDefault()

        data = @$('form').serializeArray()
        readyData = {}

        for item in data
            readyData[item.name] = item.value.trim() if item.value

        @model.start readyData

    close: ->
        @model.closePreferences()


_.extend Views,
    Preferences: Preferences

module.exports =
    Preferences: Views.Preferences
