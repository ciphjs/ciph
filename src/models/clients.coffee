_          = require('underscore')
Backbone   = require('backbone')
crypto     = require('crypto')
{Messages} = require('./messages')

class Client extends Backbone.Model
    defaults: ->
        id: null
        user_name: 'Anonimus'
        user_id: null
        gravatar: null
        status: 'offline'
        wait_offline: 30000
        messages: new Messages()

    initialize: ->
        @get('messages').messenger = @collection.messenger
        @get('messages').client    = @

        @setGravatar()

        @on 'change:user_id', @setGravatar
        @listenTo @get('messages'), 'add change remove destroy reset', @onNewMessageStatus

    addMessage: (message)->
        @get('messages').addMessage message

    sendMessage: (text, callback)->
        message = @get('messages').addMessage text: text, true

        @collection.messenger.message @id,
            id:   message.get('id')
            text: message.get('text')

        , ->
            message.set 'status', 'sent'

    setMessageStatus: (message)->
        return unless message?.message_id
        @get('messages').get(message.message_id)?.setStatus message.status

    heartbeat: (message)->
        @set _.pick(message, 'status', 'user_name', 'user_id')
        @_waitOffline()

    setGravatar: ->
        id = @get('user_id') or @get('user_name') or @get('id') or 'Anonimus'
        md5 = crypto.createHash 'md5'
        md5.update id
        hash = md5.digest 'hex'

        @set 'gravatar', "https://www.gravatar.com/avatar/#{hash}?s=200&d=identicon"

    onNewMessageStatus: ->
        @trigger 'update:messages'
        @collection.trigger 'update:messages'

    _waitOffline: ->
        clearTimeout @_offlineTO if @_offlineTO

        @_offlineTO = setTimeout =>
            @set 'status', 'offline'
        , @get('wait_offline')

    destroy: ->
        @collection.remove @
        @trigger 'destroy'


class Clients extends Backbone.Collection
    model: Client


module.exports =
    Client:  Client
    Clients: Clients
