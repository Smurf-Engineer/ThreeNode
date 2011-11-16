require.config({
  paths: {
    jQuery: 'loaders/jquery-loader',
    Underscore: 'loaders/underscore-loader',
    Backbone: 'loaders/backbone-loader'
  }
});
require(['order!threenodes/App', 'tests/NodeGraphTest', 'tests/NodeFieldTest', 'tests/NodeConnectionTest', 'tests/FileLoadTest', 'order!libs/jquery-1.6.4.min', 'order!libs/underscore-min', 'order!libs/backbone', "order!libs/qunit-git"], function(App, NodeGraphTest, NodeFieldTest, NodeConnectionTest, FileLoadTest) {
  var app;
  app = new App();
  new NodeGraphTest(app);
  new NodeFieldTest(app);
  new NodeConnectionTest(app);
  return new FileLoadTest(app);
});