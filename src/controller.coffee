$         = require('jquery')
_         = require('underscore')
jade      = require('../assets/libs/jade-runtime')
Backbone  = require('backbone')
Messenger = require('./models/messenger')
Notify    = require('./views/notifications')

Views = require('./views/')

global.jade = jade

class Controller extends Backbone.Model
    defaults: ->
        winFocus: true
        messenger: null
        client: new Backbone.Model id: null, empty: true

    initialize: ->
        savedData = @getSavedData()

        @set 'messenger', new Messenger
        @get('messenger').set savedData

        @set 'view', new Views.Main model: @
        @set 'notify', new Notify @

        @listenTo @get('messenger'), 'ready', @addSavedClients
        @listenTo @get('messenger'), 'ready', -> @trigger 'ready'
        @listenTo @get('messenger'), 'change:id chan:user_name change:user_id', @saveData
        @listenTo @get('messenger').get('clients'), 'add change remove reset', @saveClients
        @listenTo @get('messenger').get('clients'), 'add', @onNewClient
        @listenTo @get('messenger').get('clients'), 'update:messages', @onUpdateMessages
        @listenTo @get('messenger').get('clients'), 'new:messages', @onNewMessage

        window.onfocus = => @set 'winFocus', true
        window.onblur  = => @set 'winFocus', false
        window.onunload = => @setOffline()

    start: (data)->
        @setPreferences data
        @get('messenger').start data.id

    setPreferences: (data)->
        @get('messenger').set _.omit data, 'id'

    openPreferences: ->
        @get('view').openPreferences()

    closePreferences: ->
        @get('view').closePreferences()

    newClient: (client)->
        return unless client
        @get('messenger').connect String(client).toLowerCase()

    openClient: (client)->
        clientModel = @get('messenger').get('clients').get client

        if clientModel
            @stopListening @get('client') if @get('client')
            @set 'client', clientModel
            @listenTo @get('client'), 'destroy', -> @unset 'client'

    sendMessage: (text)->
        return unless text
        @get('client')?.sendMessage text

    setOffline: ->
        @get('messenger').heartbeat 'offline', false
        return false

    addSavedClients: ->
        clients = @getSavedClients()
        if not _.isEmpty(clients) and @get('messenger').get('id') is @get('messenger').get('last_id')
            _.each clients, (client)=> @get('messenger').connect client

    saveData: ->
        messenger = @get('messenger')

        data = {}
        data.last_id   = messenger.get('id')        if messenger.get('id')
        data.user_name = messenger.get('user_name') if messenger.get('user_name')
        data.user_id   = messenger.get('user_id')   if messenger.get('user_id')

        localStorage.setItem 'messenger_data', JSON.stringify data

    saveClients: ->
        clients = []
        clients = @get('messenger').get('clients').map (model)-> return model.get('id')

        localStorage.setItem 'messenger_clients', JSON.stringify clients

    getSavedData: ->
        if data = localStorage.getItem 'messenger_data'
            try return JSON.parse data

        return []

    getSavedClients: ->
        if clients = localStorage.getItem 'messenger_clients'
            try return JSON.parse clients

        return {}

    onNewClient: ->
        @trigger 'newClients'

    onUpdateMessages: ->
        counter = 0

        @get('messenger').get('clients').each (client)->
            client.get('messages').each (message)->
                counter++ if not message.get('self') and message.get('status') isnt 'readed'

        @trigger 'unreadMessages', counter

    onNewMessage: (client, message)->
        name = client.get('name') or 'Anonimus'
        gravatar = client.get('gravatar')
        text = message.get('text')

        if text and (not @get('winFocus') or client.get('id') isnt @get('client').get('id'))
            @get('notify').notify name.slice(0, 40), text.slice(0, 200), gravatar


module.exports = Controller
