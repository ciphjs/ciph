_          = require('underscore')
Backbone   = require('backbone')
{Messages} = require('./messages')

class Client extends Backbone.Model


class Clients extends Backbone.Collection
    model: Client


module.exports =
    Client:  Client
    Clients: Clients
