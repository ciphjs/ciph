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

    submit: (e)->
        e.preventDefault()
        client = @$('.jsClient').val().trim()

        if client
            @model.newClient client
            @$('.jsClient').val ''


class ContactList extends CollectionView
    Views: -> Views
    template: -> AppTemplates.ContactsList


class Contact extends CollectionItemView
    Views: -> Views
    template: -> AppTemplates.ContactsClient


_.extend Views,
    NewContact: NewContact
    ContactList: ContactList
    Contact: Contact

module.exports =
    NewContact: NewContact
    ContactList: ContactList
    Contact: Contact
