var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

define(['jQuery', 'Underscore', 'Backbone', "order!libs/jquery-ui/js/jquery-ui-1.9m6.min", 'order!threenodes/utils/Utils'], function($, _, Backbone) {
  "use strict";
  /* Fields View
  */  return ThreeNodes.NodeFieldRackView = (function(_super) {

    __extends(NodeFieldRackView, _super);

    function NodeFieldRackView() {
      this.addCenterTextfield = __bind(this.addCenterTextfield, this);
      this.remove = __bind(this.remove, this);
      this.onFieldCreated = __bind(this.onFieldCreated, this);
      NodeFieldRackView.__super__.constructor.apply(this, arguments);
    }

    NodeFieldRackView.prototype.initialize = function(options) {
      var _this = this;
      NodeFieldRackView.__super__.initialize.apply(this, arguments);
      this.node = options.node;
      this.node_el = options.node_el;
      this.collection.bind("addCenterTextfield", function(field) {
        return _this.addCenterTextfield(field);
      });
      return this.collection.bind("add", function(field) {
        return _this.onFieldCreated(field);
      });
    };

    NodeFieldRackView.prototype.onFieldCreated = function(field) {
      var el, target;
      target = field.get("is_output") === false ? ".inputs" : ".outputs";
      $(target, this.$el).append(field.render_button());
      el = $("#fid-" + (field.get('fid')));
      return this.add_field_listener(el);
    };

    NodeFieldRackView.prototype.remove = function() {
      this.undelegateEvents();
      $(".inner-field", $(this.el)).each(function() {
        if ($(this).data("droppable")) return $(this).droppable("destroy");
      });
      $(".inner-field", $(this.el)).each(function() {
        if ($(this).data("draggable")) return $(this).draggable("destroy");
      });
      $(".inner-field", $(this.el)).remove();
      $(".field", $(this.el)).remove();
      $("input", $(this.el)).remove();
      delete this.collection;
      delete this.node_el;
      delete this.node;
      return NodeFieldRackView.__super__.remove.apply(this, arguments);
    };

    NodeFieldRackView.prototype.add_field_listener = function($field) {
      var accept_class, field, get_path, highlight_possible_targets, self;
      self = this;
      field = $field.data("object");
      get_path = function(start, end, offset) {
        var ofx, ofy;
        ofx = $("#container-wrapper").scrollLeft();
        ofy = $("#container-wrapper").scrollTop();
        return "M" + (start.left + offset.left + ofx + 2) + " " + (start.top + offset.top + ofy + 2) + " L" + (end.left + offset.left + ofx) + " " + (end.top + offset.top + ofy);
      };
      highlight_possible_targets = function() {
        var target;
        target = ".outputs .field";
        if (field.get("is_output") === true) target = ".inputs .field";
        return $(target).filter(function() {
          return $(this).parent().parent().parent().attr("id") !== ("nid-" + self.nid);
        }).addClass("field-possible-target");
      };
      $(".inner-field", $field).draggable({
        helper: function() {
          return $("<div class='ui-widget-drag-helper'></div>");
        },
        scroll: true,
        cursor: 'pointer',
        cursorAt: {
          left: 0,
          top: 0
        },
        start: function(event, ui) {
          highlight_possible_targets();
          if (ThreeNodes.svg_connecting_line) {
            return ThreeNodes.svg_connecting_line.attr({
              opacity: 1
            });
          }
        },
        stop: function(event, ui) {
          $(".field").removeClass("field-possible-target");
          if (ThreeNodes.svg_connecting_line) {
            return ThreeNodes.svg_connecting_line.attr({
              opacity: 0
            });
          }
        },
        drag: function(event, ui) {
          var pos;
          if (ThreeNodes.svg_connecting_line) {
            pos = $("span", event.target).position();
            ThreeNodes.svg_connecting_line.attr({
              path: get_path(pos, ui.position, self.node_el.position())
            });
            return true;
          }
        }
      });
      accept_class = ".outputs .inner-field";
      if (field && field.get("is_output") === true) {
        accept_class = ".inputs .inner-field";
      }
      $(".inner-field", $field).droppable({
        accept: accept_class,
        activeClass: "ui-state-active",
        hoverClass: "ui-state-hover",
        drop: function(event, ui) {
          var field2, origin;
          origin = $(ui.draggable).parent();
          field2 = origin.data("object");
          return self.node.createConnection(field, field2);
        }
      });
      return this;
    };

    NodeFieldRackView.prototype.addCenterTextfield = function(field) {
      var f_in;
      $(".center", this.$el).append("<div><input type='text' id='f-txt-input-" + (field.get('fid')) + "' /></div>");
      f_in = $("#f-txt-input-" + (field.get('fid')));
      field.on_value_update_hooks.update_center_textfield = function(v) {
        if (v !== null) return f_in.val(v.toString());
      };
      f_in.val(field.getValue());
      if (field.get("is_output") === true) {
        f_in.attr("disabled", "disabled");
      } else {
        f_in.keypress(function(e) {
          if (e.which === 13) {
            field.setValue($(this).val());
            return $(this).blur();
          }
        });
      }
      return this;
    };

    return NodeFieldRackView;

  })(Backbone.View);
});
