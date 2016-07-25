_         = require('underscore')
crypto    = require('crypto')
Backbone  = require('backbone')
Connecter = require('./connecter')
{Clients} = require('./clients')

class Messenger extends Backbone.Model
    defaults: ->
        id: null
        url: 'wss://ciph.nim.space/tunnel'
        user_name: null
        user_id: null
        gravatar: null
        status: 'offline'
        heartbeat_time: 10000
        clients: new Clients()

    initialize: ->
        @connecter = new Connecter()
        @get('clients').messenger = @

        @listenTo @connecter, 'ready',        @onReady
        @listenTo @connecter, 'ready:client', @addClient
        @listenTo @connecter, 'message',      @onMessage

        @on 'change:user_id', @setGravatar

    start: (id, url)->
        @set 'url', url if url
        @connecter.start @get('url'), id

    connect: (client_id, callback)->
        @connecter.hello client_id, callback

    send: (client_id, data, force=false, callback)->
        @connecter.send client_id, JSON.stringify(data), force, callback

    sendAll: (data, force=false)->
        @get('clients').each (client)=>
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

    # TODO: rename method

    setGravatar: ->
        if id = @get('user_id')
            md5 = crypto.createHash 'md5'
            md5.update id
            hash = md5.digest 'hex'

            @set 'gravatar', "https://www.gravatar.com/avatar/#{hash}?s=200&d=identicon"

    onReady: (id, exists=false)->
        # TODO: if exists
        @set id: id, status: 'online'
        @startHeartbeat()

    startHeartbeat: ->
        clearInterval @_heartbeatTO if @_heartbeatTO
        @_heartbeatTO = setInterval =>
            @heartbeat()
        , @get('heartbeat_time')

        @heartbeat()

    addClient: (client_id)->
        @get('clients').add id: client_id
        @heartbeat()

    onMessage: (client_id, data)->
        try
            message = JSON.parse data

        catch
            return

        if client = @get('clients').get client_id
            switch message.type
                when 'message'   then client.addMessage message.data
                when 'status'    then client.setMessageStatus message.data
                when 'heartbeat' then client.heartbeat message.data

    toJSON: ->
        data = super
        data.clients = @get('clients').length
        return data

module.exports = Messenger
