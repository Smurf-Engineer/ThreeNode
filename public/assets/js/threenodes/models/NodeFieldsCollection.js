var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
define(['Underscore', 'Backbone'], function(_, Backbone) {
  "use strict";  return ThreeNodes.NodeFieldsCollection = (function() {
    __extends(NodeFieldsCollection, Backbone.Collection);
    function NodeFieldsCollection() {
      this.removeAllConnections = __bind(this.removeAllConnections, this);
      this.renderConnections = __bind(this.renderConnections, this);
      this.toXML = __bind(this.toXML, this);
      this.toCode = __bind(this.toCode, this);
      this.toJSON = __bind(this.toJSON, this);
      this.fromXML = __bind(this.fromXML, this);
      this.fromJSON = __bind(this.fromJSON, this);
      this.registerField = __bind(this.registerField, this);
      this.setFieldInputUnchanged = __bind(this.setFieldInputUnchanged, this);
      this.getDownstreamNodes = __bind(this.getDownstreamNodes, this);
      this.getUpstreamNodes = __bind(this.getUpstreamNodes, this);
      this.getMaxInputSliceCount = __bind(this.getMaxInputSliceCount, this);
      this.setField = __bind(this.setField, this);
      this.getField = __bind(this.getField, this);
      this.initialize = __bind(this.initialize, this);
      NodeFieldsCollection.__super__.constructor.apply(this, arguments);
    }
    NodeFieldsCollection.prototype.initialize = function() {
      var json, xml;
      this.node = this.options.node;
      this.node_fields = {};
      this.node_fields.inputs = {};
      this.node_fields.outputs = {};
      this.node_fields_by_name = {};
      this.node_fields_by_name.inputs = {};
      this.node_fields_by_name.outputs = {};
      xml = this.get("xml");
      json = this.get("json");
      if (xml) {
        return this.fromXML(xml);
      } else if (json) {
        return this.fromJSON(json);
      }
    };
    NodeFieldsCollection.prototype.getField = function(key, is_out) {
      if (is_out == null) {
        is_out = false;
      }
      if (is_out === true) {
        return this.node_fields_by_name.outputs[key];
      } else {
        return this.node_fields_by_name.inputs[key];
      }
    };
    NodeFieldsCollection.prototype.setField = function(key, value) {
      return this.node_fields_by_name.outputs[key].set(value);
    };
    NodeFieldsCollection.prototype.getMaxInputSliceCount = function() {
      var f, fid, res;
      res = 1;
      for (fid in this.node_fields.inputs) {
        f = this.node_fields.inputs[fid];
        if (f.val && $.type(f.val) === "array") {
          if (f.val.length > res) {
            res = f.val.length;
          }
        }
      }
      return res - 1;
    };
    NodeFieldsCollection.prototype.getUpstreamNodes = function() {
      var c, f, fid, res, _i, _len, _ref;
      res = [];
      for (fid in this.node_fields.inputs) {
        f = this.node_fields.inputs[fid];
        _ref = f.connections;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          res[res.length] = c.from_field.node;
        }
      }
      return res;
    };
    NodeFieldsCollection.prototype.getDownstreamNodes = function() {
      var c, f, fid, res, _i, _j, _len, _len2, _ref, _ref2;
      res = [];
      _ref = this.node_fields.outputs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        fid = _ref[_i];
        f = this.node_fields.inputs[fid];
        _ref2 = f.connections;
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          c = _ref2[_j];
          res[res.length] = c.to_field.node;
        }
      }
      return res;
    };
    NodeFieldsCollection.prototype.setFieldInputUnchanged = function() {
      var f, fid, _i, _len, _ref, _results;
      _ref = this.node_fields.inputs;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        fid = _ref[_i];
        f = this.node_fields.inputs[fid];
        _results.push(f.changed = false);
      }
      return _results;
    };
    NodeFieldsCollection.prototype.registerField = function(field) {
      field.node = this.node;
      if (field.is_output === false) {
        this.node_fields.inputs["fid-" + field.fid] = field;
        this.node_fields_by_name.inputs[field.name] = field;
        $(".inputs", this.node.main_view).append(field.render_button());
      } else {
        this.node_fields.outputs["fid-" + field.fid] = field;
        this.node_fields_by_name.outputs[field.name] = field;
        $(".outputs", this.node.main_view).append(field.render_button());
      }
      if (this.view !== false) {
        this.trigger("field:registered", this, $("#fid-" + field.fid));
      }
      return field;
    };
    NodeFieldsCollection.prototype.fromJSON = function(data) {
      var f, node_field, _i, _len, _ref;
      _ref = data.fields["in"];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        f = _ref[_i];
        node_field = this.node_fields_by_name.inputs[f.name];
        if (node_field && f.val) {
          node_field.set(f.val);
        }
      }
      return true;
    };
    NodeFieldsCollection.prototype.fromXML = function(data) {
      var self;
      self = this;
      $("in field", data).each(function() {
        var f, field_val;
        f = self.node_fields.inputs["fid-" + $(this).attr("fid")];
        field_val = $(this).attr("val");
        if (f && field_val !== "[object Object]") {
          return f.set(field_val);
        }
      });
      return true;
    };
    NodeFieldsCollection.prototype.toJSON = function() {
      var res;
      res = {
        "in": jQuery.map(this.node_fields.inputs, function(f, i) {
          return f.toJSON();
        }),
        out: jQuery.map(this.node_fields.outputs, function(f, i) {
          return f.toJSON();
        })
      };
      return res;
    };
    NodeFieldsCollection.prototype.toCode = function() {
      var field, res;
      res = "{'in': [\n";
      for (field in this.node_fields.inputs) {
        res += this.node_fields.inputs[field].toCode();
      }
      res += "\t]}";
      return res;
    };
    NodeFieldsCollection.prototype.toXML = function() {
      var f, res;
      res = "\t\t<in>\n";
      for (f in this.node_fields.inputs) {
        res += this.node_fields.inputs[f].toXML();
      }
      res += "\t\t</in>\n";
      res += "\t\t<out>\n";
      for (f in this.node_fields.outputs) {
        res += this.node_fields.outputs[f].toXML();
      }
      res += "\t\t</out>\n";
      return res;
    };
    NodeFieldsCollection.prototype.renderConnections = function() {
      var f;
      for (f in this.node_fields.inputs) {
        this.node_fields.inputs[f].render_connections();
      }
      for (f in this.node_fields.outputs) {
        this.node_fields.outputs[f].render_connections();
      }
      return true;
    };
    NodeFieldsCollection.prototype.removeAllConnections = function() {
      var f, _results;
      for (f in this.node_fields.inputs) {
        this.node_fields.inputs[f].remove_connections();
      }
      _results = [];
      for (f in this.node_fields.outputs) {
        _results.push(this.node_fields.outputs[f].remove_connections());
      }
      return _results;
    };
    return NodeFieldsCollection;
  })();
});