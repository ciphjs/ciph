$        = require('jquery')
_        = require('underscore')
Backbone = require('backbone')
Views    = {}

{ModelView, CollectionView, CollectionItemView} = require('./views')

class Messenger extends ModelView
    Views: -> Views
    template: -> AppTemplates.MessengerLayout

    _bindData: ->
        @listenTo @model, 'change:client', @render


class MessengerDummy extends ModelView
    Views: -> Views
    template: -> AppTemplates.MessengerDummy

class MessengerHeader extends ModelView
    Views: -> Views
    template: -> AppTemplates.MessengerHeader

    _bindData: ->
        super
        @listenTo @_getDataSource(), 'change', @render


class Messages extends CollectionView
    Views: -> Views
    template: -> AppTemplates.MessengerMessages


class Message extends CollectionItemView
    Views: -> Views
    template: -> AppTemplates.MessengerMessage

    _bindData: ->
        super

        @on 'render', -> @setReaded()
        @listenTo @model.get('client'), 'change', @render

    setReaded: ->
        return if @_getDataSource().get('status') is 'readed'

        if @model.get('winFocus')
            @_getDataSource().setReaded()

        else
            @listenTo @model, 'change:winFocus', ->
                if @model.get('winFocus')
                    @stopListening @model, 'change:winFocus'
                    @_getDataSource().setReaded()

    _prepareData: ->
        data = super

        if data.self
            data.client = @model.get('messenger').toJSON()

        else
            data.client = @model.get('client').toJSON()

        data.text = data.text.replace /<[^>]*?script[^>]*?>/gi, ""
        data.text = data.text.replace /<[^>]*?js:[^>]*?>/gi,    ""

        return data

    globals: ->
        moment = require('moment')
        return moment: moment


class MessengerSend extends ModelView
    Views: -> Views
    template: -> AppTemplates.MessengerSend

    events:
        "keyup .jsMessage": "message"
        "keydown .jsMessage": "messageBlock"

    initialize: ->
        super
        @on 'render', ->
            @$('.jsMessage').focus()
            _.defer -> window.getSelection().setPosition(0)

    message: (e)->
        if e.keyCode is 13 and not e.shiftKey
            e.preventDefault()
            @sendMessage()
            return false

    messageBlock: (e)->
        e.preventDefault() if e.keyCode is 13 and not e.shiftKey

    sendMessage: ->
        $field = @$('.jsMessage')
        text = $field.html().trim()

        @model.sendMessage text
        $field.html ''


_.extend Views,
    Messenger: Messenger
    MessengerDummy: MessengerDummy
    MessengerHeader: MessengerHeader
    Messages: Messages
    Message: Message
    MessengerSend: MessengerSend

module.exports =
    Messenger: Messenger
    MessengerDummy: MessengerDummy
    MessengerHeader: MessengerHeader
    Messages: Messages
    Message: Message
    MessengerSend: MessengerSend
