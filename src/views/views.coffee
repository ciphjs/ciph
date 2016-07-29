$        = require('jquery')
_        = require('underscore')
Backbone = require('backbone')

class ModelView extends Backbone.View
    initialize: (options)->
        super
        @options = _.extend {}, @_defaults(), options
        @render()

    Views: -> {}
    globals: -> {}
    template: ->
    _defaults: ->
    _bindData: ->

    _unbindData: ->
        @stopListening()

        if @partials?.length
            for partial in @partials
                partial._unbindData()

        return @

    render: ->
        @_unbindData()
        @_bindData()
        @undelegateEvents()
        @detachPartials()

        @_render @template(), @_prepareData()

        @attachPartials()
        @delegateEvents()

        @trigger 'render'

    _render: (template, data)->
        @$el.html template data if template

    attachPartials: ->
        @partials = []

        @$('[data-partial]').each (index, el)=>
            data = $(el).data()
            return unless @Views()[data.partial]

            partial = new (@Views()[data.partial])
                el: el
                model: @model
                dataSource: data.source
                parent: @

            @partials.push partial

    detachPartials: ->
        if @partials?.length
            for partial in @partials
                @stopListening partial
                partial.destroy()

            delete @partials

        return @

    _prepareData: ->
        dataSource = @_getDataSource()
        dataSourceName = _.last @options.dataSource.split('/')
        dataSourceName = dataSourceName.replace('\\', '/') if _.isString dataSourceName

        if dataSource?
            newDataSource = {}

            if dataSource instanceof Backbone.Collection
                newDataSource[dataSourceName] = dataSource.toJSON()

            else if dataSource instanceof Backbone.Model
                newDataSource = dataSource.toJSON()

            else
                if _.isString(dataSource) or _.isNumber(dataSource) or _.isArray(dataSource)
                    newDataSource[dataSourceName] = dataSource

                else
                    newDataSource = dataSource

            return _.extend {globals: @globals()}, newDataSource

        else
            return _.extend {globals: @globals()}, @model.toJSON()

    _getDataSource: ->
        currentSource = null

        dataSourceUri = @options.dataSource.split('/')

        for dataSourceUriPart in dataSourceUri
            dataSourceUriPart = dataSourceUriPart.replace('\\', '/') if _.isString dataSourceUriPart

            if currentSource?
                iterationSource = currentSource.get(dataSourceUriPart)

            else
                iterationSource = @model.get(dataSourceUriPart)

            if iterationSource?
                currentSource = iterationSource

            else
                break

        return currentSource

    _bindData: ->
        if dataSource = @_getDataSource()
            @listenTo dataSource, "change destroy", @_dataResponder

        return @

    _unbindData: ->
        @stopListening()
        if @partials?.length
            for partial in @partials
                partial._unbindData()

        return @

    remove: ->
        @$el.empty()

    destroy: ->
        if @partials?.length
            for partial in @partials
                @stopListening partial
                partial.destroy()

            delete @partials

        @undelegateEvents()
        @stopListening()
        @remove()
        @trigger 'destroy'

        return @


class CollectionView extends ModelView
    _bindData: ->
        @listenTo @_getDataSource(), 'add', @appendPartial

    attachPartials: ->
        @partials = []
        wrapElement = @$('[data-items]')[0]
        data = $(wrapElement).data()

        @_getDataSource().each (model)=>
            return unless @Views()[data.items]
            partial = new (@Views()[data.items])
                model: @model
                dataSource: @options.dataSource+'/'+model.id

            @partials.push partial
            $(wrapElement).append partial.$el

    appendPartial: (model)->
        wrapElement = @$('[data-items]')[0]
        data = $(wrapElement).data()

        return unless @Views()[data.items]
        partial = new (@Views()[data.items])
            model: @model
            dataSource: @options.dataSource+'/'+model.id

        @partials.push partial
        $(wrapElement).append partial.$el


class CollectionItemView extends ModelView
    _bindData: ->
        @listenTo @_getDataSource(), 'change', @render
        @listenTo @_getDataSource(), 'remove', @destroy

    _render: (template, data)->
        if template
            $newEl = $ template data
            @$el.replaceWith $newEl
            @setElement $newEl

    remove: ->
        @$el.remove()


module.exports =
    ModelView: ModelView
    CollectionView: CollectionView
    CollectionItemView: CollectionItemView
