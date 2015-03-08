_ = require 'Underscore'
Backbone = require 'Backbone'
namespace = require('libs/namespace').namespace

require '../models/Node'
NodeView = require './NodeView'
require 'colorpicker'

class Color extends NodeView
  initialize: (options) =>
    super
    @init_preview()

  init_preview: () =>
    fields = @model.fields
    @$picker_el = $("<div class='color_preview'></div>")
    col = fields.getField("rgb", true).getValue(0)
    @$picker_el.ColorPicker
      color: {r: col.r * 255, g: col.g * 255, b: col.b * 255}
      onChange: (hsb, hex, rgb) =>
        fields.getField("r").setValue(rgb.r / 255)
        fields.getField("g").setValue(rgb.g / 255)
        fields.getField("b").setValue(rgb.b / 255)

    $(".center", @$el).append(@$picker_el)

    # on output value change set preview color
    fields.getField("rgb", true).on_value_update_hooks.set_bg_color_preview = (v) =>
      @$picker_el.css
        background: v[0].getStyle()

  remove: () =>
    @$picker_el.each () ->
      if $(this).data('colorpickerId')
        cal = $('#' + $(this).data('colorpickerId'))
        picker = cal.data('colorpicker')
        if picker
          delete picker.onChange
        # remove colorpicker dom element
        cal.remove()
    @$picker_el.unbind()
    @$picker_el.remove()
    delete @$picker_el
    super

module.exports = Color
