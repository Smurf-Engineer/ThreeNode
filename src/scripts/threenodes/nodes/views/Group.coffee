define (require) ->
  #"use strict"
  _ = require 'Underscore'
  Backbone = require 'Backbone'

  require 'cs!threenodes/models/Node'
  require 'cs!threenodes/views/NodeView'

  namespace "ThreeNodes.nodes.views",
    Group: class Group extends ThreeNodes.NodeView
      initialize: (options) =>
        super
        @views = []
        console.log options.model.nodes
        _.each(options.model.nodes.models, @renderNode)

      renderNode: (node) =>
        nodename = node.constructor.name

        if ThreeNodes.nodes.views[nodename]
          # If there is a view associated with the node model use it
          viewclass = ThreeNodes.nodes.views[nodename]
        else
          # Use the default view class
          viewclass = ThreeNodes.NodeView

        # same as Workspace.renderNode
        $nodeEl = $("<div class='node'></div>").appendTo(@$el.find("> .options"))
        view = new viewclass
          model: node
          isSubNode: true
          el: $nodeEl

        #view.$el.appendTo(@$el.find("> .options"))

        # Save the nid and model in the data attribute
        view.$el.data("nid", node.get("nid"))
        view.$el.data("object", node)
        @views.push(view)

      remove: () =>
        super
