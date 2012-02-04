define [
  'jQuery',
  'Underscore', 
  'Backbone',
  "text!templates/node.tmpl.html",
  "order!libs/jquery.tmpl.min",
  "order!libs/jquery.contextMenu",
  'order!threenodes/core/NodeFieldRack',
  'order!threenodes/utils/Utils',
], ($, _, Backbone, _view_node_template) ->
  "use strict"
  class ThreeNodes.NodeMaterialBase extends ThreeNodes.NodeBase
    set_fields: =>
      super
      @ob = false
      @auto_evaluate = true
      @material_class = false
      @last_slice_count = -1
      ThreeNodes.webgl_materials_node[ThreeNodes.webgl_materials_node.length] = this
      @rack.addFields
        inputs:
          "opacity": 1
          "transparent": false
          "depthTest": true
          "alphaTest": 0
          "polygonOffset": false
          "polygonOffsetFactor": 0
          "polygonOffsetUnits": 0
          "blending":
            type: "Float"
            val: THREE.NormalBlending
            values:
              "Normal": THREE.NormalBlending
              "Additive": THREE.AdditiveBlending
              "Subtractive": THREE.SubtractiveBlending
              "Multiply": THREE.MultiplyBlending
              "AdditiveAlpha": THREE.AdditiveAlphaBlending
    
    compute: =>
      needs_rebuild = false
      numItems = @rack.getMaxInputSliceCount()
      if @input_value_has_changed(@vars_rebuild_shader_on_change) || @last_slice_count != numItems
        needs_rebuild = true
      
      if needs_rebuild == true
        @ob = []
        for i in [0..numItems]
          @ob[i] = new @material_class()
      for i in [0..numItems]
        @apply_fields_to_val(@rack.node_fields.inputs, @ob[i], [], i)
      @material_cache = @create_cache_object(@vars_rebuild_shader_on_change)
      
      @last_slice_count = numItems
      @rack.set("out", @ob)
  
  class ThreeNodes.nodes.MeshBasicMaterial extends ThreeNodes.NodeMaterialBase
    @node_name = 'MeshBasic'
    @group_name = 'Materials'
    
    set_fields: =>
      super
      @ob = []
      @material_class = THREE.MeshBasicMaterial
      @rack.addFields
        inputs:
          "color": {type: "Color", val: new THREE.Color(0xff0000)}
          "map": {type: "Any", val: false}
          "reflectivity": 1
          "refractionRatio": 0.98
          "wireframe": false
          "wireframeLinecap": 1
          "vertexColors": false
          "skinning": false
          "fog": true
        outputs:
          "out": {type: "Any", val: @ob}
      @vars_rebuild_shader_on_change = ["transparent", "depthTest", "map"]
      @material_cache = @create_cache_object(@vars_rebuild_shader_on_change)
  
  class ThreeNodes.nodes.LineBasicMaterial extends ThreeNodes.NodeMaterialBase
    @node_name = 'LineBasic'
    @group_name = 'Materials'
    
    set_fields: =>
      super
      @ob = []
      @material_class = THREE.LineBasicMaterial
      @rack.addFields
        inputs:
          "color": {type: "Color", val: new THREE.Color(0xff0000)}
          "linewidth": 1
        outputs:
          "out": {type: "Any", val: @ob}
      @vars_rebuild_shader_on_change = ["transparent", "depthTest"]
      @material_cache = @create_cache_object(@vars_rebuild_shader_on_change)
  
  class ThreeNodes.nodes.MeshLambertMaterial extends ThreeNodes.NodeMaterialBase
    @node_name = 'MeshLambert'
    @group_name = 'Materials'
    
    set_fields: =>
      super
      @ob = []
      @material_class = THREE.MeshLambertMaterial
      @rack.addFields
        inputs:
          "color": {type: "Color", val: new THREE.Color(0xff0000)}
          "map": {type: "Any", val: false}
          "reflectivity": 1
          "refractionRatio": 0.98
          "wireframe": false
          "vertexColors": {type: "Any", val: false}
          "skinning": false
          "fog": true
        outputs:
          "out": {type: "Any", val: @ob}
      @vars_rebuild_shader_on_change = ["transparent", "depthTest", "map"]
      @material_cache = @create_cache_object(@vars_rebuild_shader_on_change)
  
  class ThreeNodes.nodes.MeshPhongMaterial extends ThreeNodes.NodeMaterialBase
    @node_name = 'MeshPhong'
    @group_name = 'Materials'
    
    set_fields: =>
      super
      @ob = []
      @material_class = THREE.MeshPhongMaterial
      @rack.addFields
        inputs:
          "color": {type: "Color", val: new THREE.Color(0xff0000)}
          "map": {type: "Any", val: false}
          "ambient": {type: "Color", val: new THREE.Color(0x050505)}
          "specular": {type: "Color", val: new THREE.Color(0x111111)}
          "shininess": 30
          "reflectivity": 1
          "refractionRatio": 0.98
          "wireframe": false
          "vertexColors": {type: "Any", val: false}
          "skinning": false
          "fog": true
        outputs:
          "out": {type: "Any", val: @ob}
      @vars_rebuild_shader_on_change = ["transparent", "depthTest", "map"]
      @material_cache = @create_cache_object(@vars_rebuild_shader_on_change)
