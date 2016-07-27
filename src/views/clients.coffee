$        = require('jquery')
_        = require('underscore')
Backbone = require('backbone')
Views    = {}

{ModelView, CollectionView, CollectionItemView} = require('./views')

class NewContact extends ModelView
    Views: -> Views
    template: -> AppTemplates.ContactsNew

    events:
        "submit form": "submit"
        "click .jsPreferences": "openPreferences"

    submit: (e)->
        e.preventDefault()
        client = @$('.jsClient').val().trim()

        if client
            @model.newClient client
            @$('.jsClient').val ''

    openPreferences: ->
        @model.openPreferences()


class ContactList extends CollectionView
    Views: -> Views
    template: -> AppTemplates.ContactsList


class Contact extends CollectionItemView
    Views: -> Views
    template: -> AppTemplates.ContactsClient

    events: ->
        "click": "openClient"
        "click .jsRemove": "removeClient"

    _bindData: ->
        super
        @listenTo @model, 'change:client', @_selectClient
        @listenTo @_getDataSource().get('messages'), 'add change remove', @render

    _prepareData: ->
        data = super
        data.message = data.messages.last()?.toJSON()

        unread = data.messages.filter (model)->
            return not model.get('self') and model.get('status') isnt 'readed'

        data.unread = unread.length or 0

        if data.message and data.message.text
            data.message.text = data.message.text.replace(/<[^>]*?[^>]*?>/gi, ' ').replace(/\s{2,}/, ' ')

        data.current_client = @model.get('client')?.get('id')

        return data

    openClient: (e)->
        e?.preventDefault()
        id = $(e.currentTarget).data 'id'
        @model.openClient id
        $('.jsLayout').removeClass 'mAside'

    _selectClient: ->
        @$el.removeClass 'mActive'
        return unless @model.get('client')

        currentClient = @model.get('client').get('id')
        thisClient    = @_getDataSource().get('id')

        if currentClient is thisClient
            @$el.addClass 'mActive'

    removeClient: (e)->
        e.preventDefault()
        e.stopPropagation()

        @_getDataSource().destroy()


_.extend Views,
    NewContact: NewContact
    ContactList: ContactList
    Contact: Contact

module.exports =
    NewContact: NewContact
    ContactList: ContactList
    Contact: Contact
