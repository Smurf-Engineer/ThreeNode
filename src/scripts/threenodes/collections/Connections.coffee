root = if typeof window != "undefined" && window != null then window else exports

define [
  'use!Underscore', 
  'use!Backbone',
  'cs!threenodes/models/Connection',
], (_, Backbone) ->
  #"use strict"
  
  class root.ThreeNodes.ConnectionsCollection extends Backbone.Collection
    model: root.ThreeNodes.Connection
    
    initialize: (models, options) =>
      @indexer = options.indexer
      @bind "connection:removed", (c) => @remove(c)
      super
    
    render: () =>
      @each (c) -> c.render()
    
    create: (model, options) =>
      if !options then options = {}
      model.indexer = @indexer
      model = @_prepareModel(model, options)
      if !model
        return false
      @add(model, options)
      return model
    
    removeAll: () =>
      @remove(@models)
    