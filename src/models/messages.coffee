_          = require('underscore')
Backbone   = require('backbone')

class Message extends Backbone.Model
    defaults: ->
        id: null
        date: null
        text: null
        self: false
        status: null

    initialize: ->
        super
        @_changeStatus()
        @on 'change:status', @_changeStatus

    setStatus: (status)->
        @set 'status', status

    setReaded: ->
        @set 'status', 'readed' unless @get('self')

    _changeStatus: ->
        if not @get('self') and @get('status') in ['delivered', 'readed']
            client = @collection.client.get('id')
            @collection.messenger.status client, @get('id'), @get('status')


class Messages extends Backbone.Collection
    model: Message

    addMessage: (data, self=false)->
        return unless data.text

        message = _.extend
            date: new Date()
            id: @generateID()
            self: self
            status: unless self then 'delivered' else 'waiting'
        , _.omit data, 'self'

        return @add message, merge: true

    generateID: ->
        client = @messenger.get 'id'
        time   = _.now() + ''
        id     = _.uniqueId()

        return "#{client}-#{time}-#{id}"


module.exports =
    Message:  Message
    Messages: Messages
