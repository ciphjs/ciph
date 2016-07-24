_         = require('underscore')
url       = require('url')
crypto    = require('crypto')
Backbone  = require('backbone')
WebSocket = require('ws')

class Client
    options:
        url: 'wss://ciph.nim.space/tunnel'
        curve: 'secp521r1'
        cipher: 'aes256'
        reconnect: 2000

    started:    false
    clients:    {}
    client_id:  null
    _inQueue:   []
    _outQueue:  []
    _ws:        null

    constructor: (options)->
        @options = _.extend {}, @options, options
        _.extend @, Backbone.Events

        @on 'add:queue', @resolveOutgoing
        @on 'add:passkey', @resolveIncoming
        @on 'open', @resolveOutgoing

    connect: (url)->
        @options.url = url
        @started = true
        @_ws = new WebSocket url

        @_ws.on 'message', _.bind @onMessage, @
        @_ws.on 'close',   _.bind @reconnect, @
        @_ws.on 'open',    => @trigger 'open'

    reconnect: ->
        clearTimeout @_rcto if @_rcto

        @_rcto = setTimeout =>
            delete @_rcto
            @connect @options.url
        , @options.reconnect

    isConnected: ->
        return false unless @_ws?
        return @_ws.readyState is WebSocket.OPEN

    isReadyClient: (client)->
        return false unless @clients[client]
        return false unless @clients[client].key
        return true

    getKey: (client)->
        return @clients[client]?.key

    ready: (mes)->
        @client_id = mes.query.client
        @trigger 'ready', @client_id
        @trigger 'add:room', mes.query.room

    onMessage: (data)->
        mes = url.parse data.toString(), true
        return unless mes.protocol is 'ciph:'

        if host is 'tunnel' and mes.pathname is '/created'
            return @ready mes

        # Service methods
        switch mes.pathname
            when '/hello' then return @hello mes, mes.auth
            when '/ecdh'  then return @ecdh  mes, mes.auth, mes.query

        # Messenger methods
        switch mes.pathname
            when '/m' then return @message mes

    send: (room, data)->
        # TODO: passkey for encrypt
        cipher = crypto.createCipher @options.cipher, key
        encrypted = ''

        cipher.on 'readable', ->
            chunk = cipher.read()
            encrypted += chunk.toString 'hex' if chunk

        cipher.on 'end', =>
            @_send room, '/m', m: encrypted

        cipher.write data
        cipher.end()

    _send: (room, method, params)->
        res = url.format
            protocol: 'ciph:'
            slashes: true
            auth: @client_id
            host: room
            pathname: method
            query: params or null

        @_inQueue.push res
        @trigger 'add:queue'

    resolveOutgoing: ->
        return unless @isConnected()

        for mes in @_inQueue
            @_ws.send mes
            @_inQueue = _.without @_inQueue, mes

    resolveIncoming: ->
        for mes in @_outQueue
            if @isReadyClient mes.auth
                @message mes
                @_outQueue = _.without @_outQueue, mes

    hello: (mes, client)->
        ecdh = crypto.createECDH @options.curve
        pkey = ecdh.generateKeys()

        @clients[client] =
            ecdh: ecdh
            key:  null

        @send mes.room, '/ecdh', k: pkey
        @trigger 'add:client', client

    ecdh: (mes, client, params)->
        return unless params.k

        # If no client
        @hello mes, auth unless @clients[client]

        # If no ECDH instance
        unless @clients[client].ecdh
            ecdh = crypto.createECDH @options.curve
            pkey = ecdh.generateKeys()
            @clients[client].ecdh = ecdh
            @send mes.room, '/ecdh', k: pkey

        passkey = @clients[client].ecdh.computeSecret params.k
        @clients[client].key = passkey

        @trigger 'add:passkey', client, passkey
        @trigger 'change:client', client

    message: (mes)->
        return unless mes.query?.m
        return @_outQueue.push mes unless @isReadyClient mes.auth

        decipher = crypto.createDecipher @options.cipher, @getKey mes.auth
        decrypted = ''

        decipher.on 'readable', ->
            chunk = decipher.read()
            decrypted += chunk.toString 'utf8' if chunk

        decipher.on 'end', =>
            @trigger 'message', mes.host, decrypted

        decipher.write mes.query.m, 'hex'
        decipher.end()

    room: (id)->
        params = {}
        params.room   = id if id
        params.client = @client_id if @client_id

        @_send 'tunnel', '/connect_room', params

    start: (room, url)->
        @connect url unless @started
        @room room


module.exports = Client
