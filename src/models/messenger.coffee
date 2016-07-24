_         = require('underscore')
Backbone  = require('backbone')
Connecter = require('./connecter')
{Clients} = require('clients')

class Messenger extends Backbone.Model
    defaults:
        id: null
        url: null
        user_name: 'Anonimus'
        user_id: null
        status: 'offline'
        clients: new Clients()

    constructor: ->
        @connecter = new Connecter()
        @get('clients').messenger = @

        @listenTo @connecter, 'ready',        @onReady
        @listenTo @connecter, 'ready:client', @addClient
        @listenTo @connecter, 'message',      @onMessage

    start: (id, url)->
        @set
            id:  if id then id
            url: if url then url

        @connecter.start url, id

    connect: (client_id, callback)->
        @connecter.hello client_id, callback

    send: (client_id, data, force=false, callback)->
        @connecter.send client_id, JSON.stringify(data), force, callback

    sendAll: (data, force=false)->
        @get('clients').each (client)->
            @send client.id, data, force

    message: (client_id, message, callback)->
        @send client_id,
            type: 'message'
            data: message
        , false, callback

    status: (client_id, message_id, statu=0)->
        @send client_id,
            type: "status"
            data:
                message_id: message_id
                status: status

    heartbeat: (status)->
        status = @get('status') unless status

        @sendAll
            type: "heartbeat"
            data:
                status: status
                user_name: @get('user_name')
                user_id: @get('user_id')

        , true

    onReady: (id)->
        @set id: id, status: 'online'
        # @startHeartbeat()

    addClient: (client_id)->
        @get('clients').add id: client_id

    onMessage: (client_id, data)->
        try
            message = JSON.parse data

        catch
            return

        if client = @get('clients').get client_id
            switch message.type
                when 'message'   then client.addMessage message
                when 'status'    then client.setMessageStatus message
                when 'heartbeat' then client.heartbeat message


module.exports = Messenger
