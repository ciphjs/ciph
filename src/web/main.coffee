$         = require('jquery')
_         = require('underscore')
jade      = require('../../assets/libs/jade-runtime')
Backbone  = require('backbone')
Messenger = require('../models/messenger')

Views = require('../views/')

global.jade = jade

class Controller extends Backbone.Model
    initialize: ->
        savedID = @getSavedID()

        @set 'messenger', new Messenger
        @get('messenger').set 'last_id', savedID if savedID

        @set 'view', new Views.Main model: @

        @listenTo @get('messenger'), 'change:id', @saveID

    start: (data)->
        @get('messenger').set _.pick data, 'url', 'user_name', 'user_id'
        @get('messenger').start data.id

    newClient: (client)->
        return unless client
        @get('messenger').connect client

    saveID: ->
        id = @get('messenger').get('id')
        localStorage.setItem 'messenger_id', id if id

    getSavedID: ->
        return localStorage.getItem 'messenger_id'


$ ->
    window.app = new Controller()
