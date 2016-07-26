$         = require('jquery')
_         = require('underscore')
jade      = require('../assets/libs/jade-runtime')
Backbone  = require('backbone')
Messenger = require('./models/messenger')

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

        @listenTo @get('messenger'), 'ready', @addSavedClients
        @listenTo @get('messenger'), 'change:id chan:user_name change:user_id', @saveData
        @listenTo @get('messenger').get('clients'), 'add change remove reset', @saveClients

        window.onfocus = => @set 'winFocus', true
        window.onblur  = => @set 'winFocus', false

    start: (data)->
        @get('messenger').set _.pick data, 'url', 'user_name', 'user_id'
        @get('messenger').start data.id

    newClient: (client)->
        return unless client
        @get('messenger').connect client

    openClient: (client)->
        clientModel = @get('messenger').get('clients').get client
        @set 'client', clientModel if clientModel

    sendMessage: (text)->
        return unless text
        @get('client')?.sendMessage text

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


module.exports = Controller
