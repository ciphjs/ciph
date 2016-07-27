$        = require('jquery')
_        = require('underscore')
Backbone = require('backbone')

Views    = _.extend {}, require('./clients'), require('./messages'), require('./preferences'), require('./system')
{ModelView} = require('./views')

class MainView extends ModelView
    el: 'body'

    Views: -> Views

    _defaults: -> dataSource: 'messenger'
    template:  -> AppTemplates.Main

    _bindData: ->
        source = @_getDataSource()
        @listenToOnce source, 'change:id', @render unless source.id

    events:
        "click .jsToAside": "toAside"

    initialize: ->
        super
        $(window).bind 'keyup', _.bind @globalKeyup, @

    toAside: ->
        @$('.jsLayout').addClass 'mAside'

    openPreferences: ->
        @$('.jsPreferences').addClass 'mOpen'

    closePreferences: ->
        @$('.jsPreferences').removeClass 'mOpen'

    globalKeyup: (e)->
        switch e.keyCode
            when 27 then @model.trigger 'press:esc'

        return true


class StarterView extends ModelView
    Views: -> Views
    template:  -> AppTemplates.Starter

    events:
        "click .jsToggleAdvanced": "toggleAdvanced"
        "keyup": "processID"
        "submit form": "submit"

    initialize: ->
        @on 'render', ->
            @$('input').eq(0).focus()
            @processID()
            _.defer => @$('.jsLogo').removeClass('mHidden').addClass 'mAnimated'
            _.defer => @$('.jsForm').removeClass 'mHidden'

        super

    toggleAdvanced: ->
        @$('.jsAdvanced').toggleClass 'mOpen'

    submit: (e)->
        e?.preventDefault()

        data = @$('form').serializeArray()
        readyData = {}

        for item in data
            readyData[item.name] = item.value.trim() if item.value

        @model.start readyData
        @$('input, button').attr 'disabled', true

    processID: ->
        id = @$('.jsID').val().trim()
        id = id.replace /([^0-9A-z._-]+)/gi, ''
        @$('.jsID').val id


_.extend Views,
    Main: MainView
    Starter: StarterView

module.exports =
    Main: Views.Main
    Starter: Views.Starter
