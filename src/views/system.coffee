$        = require('jquery')
_        = require('underscore')
Backbone = require('backbone')

Views    = {}
{ModelView} = require('./views')


class System extends ModelView
    states:
        disconnect: false

    Views: -> Views
    template:  -> require('../templates/system/layout')

    initialize: ->
        @on 'render', @checkOpen
        @states.disconnect = not @model.get('messenger').connecter.isConnected()
        super

    _bindData: ->
        super
        @listenTo @model.get('messenger').connecter, 'disconnect', @setDisconnect
        @listenTo @model.get('messenger').connecter, 'open', @unsetDisconnect

    _prepareData: ->
        data = super
        data.states = @states
        return data

    setDisconnect: ->
        @states.disconnect = true
        @render()

    unsetDisconnect: ->
        @states.disconnect = false
        @render()

    checkOpen: ->
        open = false
        for state of @states
            if @states[state]
                open = true
                break

        if open
            _.defer => @$('.jsLayout').addClass 'mOpen'

        else
            _.defer => @$('.jsLayout').removeClass 'mOpen'


class SystemDisconnect extends ModelView
    Views: -> Views
    template:  -> require('../templates/system/disconnect')


_.extend Views,
    System: System
    SystemDisconnect: SystemDisconnect

module.exports =
    System: Views.System
    SystemDisconnect: Views.SystemDisconnect
