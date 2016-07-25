_          = require('underscore')
Backbone   = require('backbone')

class Message extends Backbone.Model
    defaults: ->
        id: null
        date: null
        text: null
        self: false
        status: null

    setStatus: (status)->
        if status is 0
            @set 'status', 'received'

        if status is 1
            @set 'status', 'readed'


class Messages extends Backbone.Collection
    model: Message

    addMessage: (data, self=false)->
        return unless data.text

        message = _.extend
            date: new Date()
            id: @generateID()
            self: self
            status: 'received'
        , _.omit data,  'self'

        # TODO: return status
        return @add message, merge: true

    generateID: ->
        client = @messenger.get 'id'
        time   = _.now() + ''
        id     = _.uniqueId()

        return "#{client}-#{time}-#{id}"


module.exports =
    Message:  Message
    Messages: Messages
