_         = require('underscore')
Backbone  = require('backbone')

class Notifications
    constructor: (@controller)->
        _.extend @, Backbone.Events

        if window.Notification?
            @_n = window.Notification
            @subscribe()

        return @

    subscribe: ->
        if @_n.permission is "default"
            @_n.requestPermission (permission)=>
                @_n.permission = permission

    notify: (title, body, icon)->
        if @_n.permission is "granted" and title
            new @_n title,
                title: title
                body: body
                icon: if icon then icon


module.exports = Notifications
