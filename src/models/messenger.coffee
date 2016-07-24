_         = require('underscore')
Backbone  = require('backbone')
Connecter = require('./connecter')
{Clients} = require('clients')

class Messenger extends Backbone.Model
    defaults:
        id: null
        url: null

    constructor: ->
        @connecter = new Connecter()
        @clients   = new Clients()
        @clients.messenger = @

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

    send: (client_id, data, callback)->
        @connecter.send client_id, data, callback

    onReady: (id)->
        @set 'id', id

    addClient: (client_id)->
        @clients.add id: client_id, {merge: false}

    onMessage: (client_id, data)->
        try
            message = JSON.parse data

        catch
            return

        if client = @clients.get client_id
            switch message.type
                when 'message'   then client.addMessage message
                when 'status'    then client.setMessageStatus message
                when 'heartbeat' then client.heartbeat message


module.exports = Messenger
