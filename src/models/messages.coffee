_          = require('underscore')
Backbone   = require('backbone')

class Message extends Backbone.Model


class Messages extends Backbone.Collection
    model: Message


module.exports =
    Message:  Message
    Messages: Messages
