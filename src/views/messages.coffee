$        = require('jquery')
_        = require('underscore')
Backbone = require('backbone')
Views    = {}

{ModelView, CollectionView, CollectionItemView} = require('./views')

class Messenger extends ModelView
    Views: -> Views
    template: -> AppTemplates.MessengerLayout

    _bindData: ->
        super
        @listenTo @model, 'change:client', @render


class MessengerDummy extends ModelView
    Views: -> Views
    template: -> AppTemplates.MessengerDummy

    events: ->
        "submit form": "submit"
        "keyup .jsAddContact": "processID"

    _bindData: ->
        super
        @listenTo @model.get('messenger').get('clients'), 'add', ->
            $('.jsLayout').addClass 'mAside'

    submit: (e)->
        e?.preventDefault()
        client = @$('.jsAddContact').val().trim()

        if client
            @model.newClient client
            @$('.jsAddContact').val ''

    processID: ->
        id = @$('.jsAddContact').val().trim()
        id = id.replace /([^0-9A-z._-]+)/gi, ''
        @$('.jsAddContact').val id


class MessengerHeader extends ModelView
    Views: -> Views
    template: -> AppTemplates.MessengerHeader

    _bindData: ->
        super
        @listenTo @_getDataSource(), 'change', @render


class Messages extends CollectionView
    Views: -> Views
    template: -> AppTemplates.MessengerMessages

    _bindData: ->
        super
        @listenTo @_getDataSource(), 'add change remove', @scrollDown
        @on 'render', -> _.defer => @scrollDown()

    scrollDown: ->
        list = @$('.jsMessages')[0]
        list.scrollTop = list.scrollHeight


class Message extends CollectionItemView
    Views: -> Views
    template: -> AppTemplates.MessengerMessage

    _bindData: ->
        super

        @on 'render', -> @setReaded()
        @listenTo @model.get('client'), 'change', @render
        @listenTo @model.get('messenger'), 'change', @render

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
        data.text = @linkify data.text

        return data

    globals: ->
        moment = require('moment')
        return moment: moment

    linkify: (inputText)->
        replacePattern1 = /(\b(\w+):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim
        replacedText = inputText.replace replacePattern1, '<a href="$1" target="_blank">$1</a>'

        replacePattern2 = /(^|[^\/])(www\.[\S]+(\b|$))/gim
        replacedText = replacedText.replace replacePattern2, '$1<a href="http://$2" target="_blank">$2</a>'

        replacePattern3 = /\b(([a-zA-Z0-9\-\_\.])+@[a-zA-Z0-9\-\_]+?(\.[a-zA-Z]{2,6})+)/gim
        replacedText = replacedText.replace replacePattern3, '<a href="mailto:$1">$1</a>'

        return replacedText


class MessengerSend extends ModelView
    Views: -> Views
    template: -> AppTemplates.MessengerSend

    events:
        "keyup .jsMessage": "message"
        "keydown .jsMessage": "messageBlock"
        "paste .jsMessage": "onPaste"

    _bindData: ->
        super
        @on 'render', @focus

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

    onPaste: (e)->
        e.stopPropagation()
        e.preventDefault()

        clipboardData = e.originalEvent.clipboardData or window.clipboardData
        pastedData = clipboardData.getData('Text').replace /[\f\r\n]/gim, '<br>'

        document.execCommand "insertHTML", false, pastedData

    focus: ->
        $el = @$('.jsMessage')
        el = $el[0]
        el.focus()

        if typeof window.getSelection isnt "undefined" and typeof document.createRange isnt "undefined"
            range = document.createRange()
            range.selectNodeContents el
            range.collapse false
            sel = window.getSelection()
            sel.removeAllRanges()
            sel.addRange range
            $el.html '<br>'

        else if typeof document.body.createTextRange isnt "undefined"
            textRange = document.body.createTextRange()
            textRange.moveToElementText el
            textRange.collapse false
            textRange.select()


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
