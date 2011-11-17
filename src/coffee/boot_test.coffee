require.config
  paths:
    jQuery: 'loaders/jquery-loader'
    Underscore: 'loaders/underscore-loader'
    Backbone: 'loaders/backbone-loader'

require [
  'order!threenodes/App',
  'tests/NodeGraphTest',
  'tests/NodeFieldTest',
  'tests/NodeConnectionTest',
  'tests/FileSaveTest',
  'tests/FileLoadTest',
  'tests/ThreeJsIntegrationTest',
  'order!libs/jquery-1.6.4.min',
  'order!libs/underscore-min',
  'order!libs/backbone',
  "order!libs/qunit-git",
], (App, NodeGraphTest, NodeFieldTest, NodeConnectionTest, FileSaveTest, FileLoadTest, ThreeJsIntegrationTest) ->
  app = new App(true)
  new NodeGraphTest(app)
  new NodeFieldTest(app)
  new NodeConnectionTest(app)
  new FileSaveTest(app)
  new FileLoadTest(app)
  new ThreeJsIntegrationTest(app)
