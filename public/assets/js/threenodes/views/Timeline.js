var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

define(['jQuery', 'Underscore', 'Backbone', "order!libs/timeline.js/timeline", "order!libs/timeline.js/timeline-gui"], function($, _, Backbone) {
  "use strict";  return ThreeNodes.AppTimeline = (function(_super) {

    __extends(AppTimeline, _super);

    function AppTimeline() {
      this.update = __bind(this.update, this);
      this.resize = __bind(this.resize, this);
      this.remove = __bind(this.remove, this);
      this.onNodeRemove = __bind(this.onNodeRemove, this);
      this.selectAnims = __bind(this.selectAnims, this);
      this.initialize = __bind(this.initialize, this);
      AppTimeline.__super__.constructor.apply(this, arguments);
    }

    AppTimeline.prototype.initialize = function(options) {
      var self,
        _this = this;
      AppTimeline.__super__.initialize.apply(this, arguments);
      localStorage["timeline.js.settings.canvasHeight"] = this.$el.innerHeight();
      this.$el.html("");
      self = this;
      this.timeline = new Timeline({
        element: this.el,
        displayOnlySelected: true,
        colorBackground: "#333",
        colorButtonBackground: "#222222",
        colorButtonStroke: "#777",
        colorScrollbar: "#373737",
        colorScrollbarThumb: "#555",
        colorTimelineLabel: "#999",
        colorTimelineTick: "#555",
        colorTimeScale: "#666",
        colorHeaderBorder: "#222",
        colorTimeTicker: "#f00",
        colorTrackBottomLine: "#555",
        colorPropertyLabel: "#999",
        onGuiSave: function() {
          return self.trigger("OnUIResize");
        },
        setPropertyValue: function(propertyAnim, t) {
          return propertyAnim.target[propertyAnim.propertyName].setValue(t);
        },
        applyPropertyValue: function(propertyAnim, t) {
          return propertyAnim.target[propertyAnim.propertyName].setValue(propertyAnim.startValue + (propertyAnim.endValue - propertyAnim.startValue) * t);
        },
        getPropertyValue: function(propertyAnim) {
          var val;
          val = propertyAnim.target[propertyAnim.propertyName].attributes["value"];
          if ($.type(val) !== "array") {
            return val;
          } else {
            return val[0];
          }
        },
        onTrackRebuild: function() {
          return _this.trigger("trackRebuild");
        },
        onStop: function() {
          return _this.trigger("stopSound");
        },
        onPlay: function(time) {
          return _this.trigger("startSound", time);
        }
      });
      Timeline.globalInstance = this.timeline;
      console.log("new timeline");
      this.timeline.loop(-1);
      this.time = 0;
      if (options.ui) {
        this.ui = options.ui;
        this.ui.on("render", this.update);
        this.ui.on("selectAnims", this.selectAnims);
        this.ui.on("timelineResize", this.resize);
      }
      return this.trigger("OnUIResize");
    };

    AppTimeline.prototype.selectAnims = function(nodes) {
      if (this.timeline) return this.timeline.selectAnims(nodes);
    };

    AppTimeline.prototype.onNodeRemove = function(node) {
      return this.selectAnims([]);
    };

    AppTimeline.prototype.remove = function() {
      this.undelegateEvents();
      if (this.ui) {
        this.ui.off("render", this.update);
        this.ui.off("selectAnims", this.selectAnims);
        this.ui.off("timelineResize", this.resize);
        delete this.ui;
      }
      this.timeline.destroy();
      delete this.timeline;
      return this.time = null;
    };

    AppTimeline.prototype.resize = function(height) {
      if (this.timeline) {
        this.timeline.canvasHeight = height;
        this.timeline.tracksScrollY = 0;
        this.timeline.tracksScrollThumbPos = 0;
        return this.timeline.save();
      }
    };

    AppTimeline.prototype.update = function() {
      var dt, n;
      n = Date.now();
      if (this.timeline) {
        dt = n - this.time;
        this.timeline.update(dt / 1000);
      }
      return this.time = n;
    };

    return AppTimeline;

  })(Backbone.View);
});
