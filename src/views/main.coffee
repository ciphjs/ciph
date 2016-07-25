$        = require('jquery')
_        = require('underscore')
Backbone = require('backbone')

Views    = require('./clients')
{ModelView} = require('./views')

class MainView extends ModelView
    el: 'body'

    Views: -> Views

    _defaults: -> dataSource: 'messenger'
    template:  -> AppTemplates.Main

    _bindData: ->
        source = @_getDataSource()
        @listenToOnce source, 'change:id', @render unless source.id


class StarterView extends ModelView
    Views: -> Views
    template:  -> AppTemplates.Starter

    events:
        "click .jsToggleAdvanced": "toggleAdvanced"
        "submit form": "submit"

    initialize: ->
        @on 'render', ->
            @$('input').eq(0).focus()

        super

    toggleAdvanced: ->
        @$('.jsAdvanced').toggleClass 'mOpen'

    submit: (e)->
        e.preventDefault()

        data = @$('form').serializeArray()
        readyData = {}

        for item in data
            readyData[item.name] = item.value.trim() if item.value

        @model.start readyData
        @$('input, button').attr 'disabled', true


_.extend Views,
    Main: MainView
    Starter: StarterView

module.exports =
    Main: Views.Main
    Starter: Views.Starter
