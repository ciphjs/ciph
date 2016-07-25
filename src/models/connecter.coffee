_         = require('underscore')
url       = require('url')
crypto    = require('crypto')
Backbone  = require('backbone')

class Connecter
    options:
        url: 'wss://ciph.nim.space/tunnel'
        curve: 'secp521r1'
        cipher: 'aes256'
        reconnect: 2000

    started:    false
    clients:    {}
    client_id:  null
    _inQueue:   []  # Income messages
    _outQueue:  []  # Outgoing messages
    _ws:        null

    constructor: (options)->
        @options = _.extend {}, @options, options
        _.extend @, Backbone.Events

        @on 'add:queue open', @resolveOutgoing
        @on 'add:passkey', @resolveIncoming

    run: (url)->
        url = @options.url unless url

        @options.url = url
        @started = true

        @_ws = new WebSocket url

        # @_ws.on 'message', _.bind @onData, @
        # @_ws.on 'close',   _.bind @reconnect, @
        # @_ws.on 'open',    => @trigger 'open'
        @_ws.onmessage = _.bind @onData, @
        @_ws.onclose   = _.bind @reconnect, @
        @_ws.onopen    = => @trigger 'open'

    reconnect: ->
        clearTimeout @_rcto if @_rcto

        @_rcto = setTimeout =>
            delete @_rcto
            @run @options.url
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

    send: (receiver, data, force=false, callback)->
        unless @isReadyClient receiver
            return callback? 'no_client'

        cipher = crypto.createCipher @options.cipher, @clients[receiver].key
        encrypted = ''

        cipher.on 'readable', ->
            chunk = cipher.read()
            encrypted += chunk.toString 'hex' if chunk

        cipher.on 'end', =>
            @_send receiver, '/m', m: encrypted, force
            callback?()

        cipher.write data
        cipher.end()

    hello: (receiver, callback)->
        @_send receiver, '/hello'

    connect: (client)->
        params = {}
        params.client = @client_id if @client_id
        params.client = client     if client

        @_send 'tunnel', '/connect', params

    start: (url, client)->
        @run url unless @started
        @connect client

    _send: (receiver, method, params, force=false)->
        res = url.format
            protocol: 'ciph:'
            slashes: true
            auth: @client_id
            host: receiver
            pathname: method
            query: params or null

        if force and @isConnected()
            @_ws.send res

        else
            @_outQueue.push res
            @trigger 'add:queue'

    resolveOutgoing: ->
        return unless @isConnected()

        for mes in @_outQueue
            console.log 'mes', mes
            @_ws.send mes
            @_outQueue = _.without @_outQueue, mes

    resolveIncoming: ->
        for mes in @_inQueue
            if @isReadyClient mes.auth
                @onMessage mes
                @_inQueue = _.without @_inQueue, mes

    onData: (data)->
        data = data.data if data.data
        mes = null
        console.log 'income', data

        try mes = url.parse data.toString(), true
        return if not mes or mes.protocol isnt 'ciph:'

        if mes.host is 'tunnel' and mes.pathname is '/connected'
            return @onReady mes

        if mes.host isnt @client_id
            return

        # Service methods
        switch mes.pathname
            when '/hello' then return @onHello mes, mes.auth
            when '/ecdh'  then return @onECDH  mes, mes.auth, mes.query

        # Messenger methods
        switch mes.pathname
            when '/m'     then return @onMessage mes

    onReady: (mes)->
        @client_id = mes.query.client
        @trigger 'ready', @client_id, mes.query.exists

    onHello: (mes, client)->
        ecdh = crypto.createECDH @options.curve
        pkey = ecdh.generateKeys()
        console.log ecdh, pkey

        @clients[client] =
            ecdh: ecdh
            key:  null

        @_send client, '/ecdh', k: pkey.toString('hex')
        @trigger 'add:client', client

    onECDH: (mes, client, params)->
        return unless params.k

        # If no client
        @onHello mes, client unless @clients[client]

        # If no ECDH instance
        unless @clients[client].ecdh
            ecdh = crypto.createECDH @options.curve
            pkey = ecdh.generateKeys()
            @clients[client].ecdh = ecdh
            @_send client, '/ecdh', k: pkey

        passkey = @clients[client].ecdh.computeSecret params.k, 'hex'
        @clients[client].key = passkey.toString('hex')

        @trigger 'add:passkey', client, passkey
        @trigger 'ready:client', client

    onMessage: (mes)->
        return unless mes.query?.m
        return @hello mes.auth unless @isReadyClient mes.auth

        decipher = crypto.createDecipher @options.cipher, @getKey mes.auth
        decrypted = ''

        decipher.on 'readable', ->
            chunk = decipher.read()
            decrypted += chunk.toString 'utf8' if chunk

        decipher.on 'end', =>
            @trigger 'message', mes.auth, decrypted

        decipher.write mes.query.m, 'hex'
        decipher.end()


module.exports = Connecter
