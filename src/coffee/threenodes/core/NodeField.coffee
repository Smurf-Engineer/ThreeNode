define [
  'jQuery',
  'Underscore', 
  'Backbone',
  "text!templates/node_field_input.tmpl.html",
  "text!templates/node_field_output.tmpl.html",
  'order!threenodes/utils/Utils',
  "order!libs/signals.min",
], ($, _, Backbone, _view_node_field_in, _view_node_field_out) ->
  class ThreeNodes.NodeField
    @connections = false
    constructor: (@name, @val, @possible_values = false, @fid = ThreeNodes.Utils.get_uid()) ->
      self = this
      @on_value_update_hooks = {}
      @signal = new signals.Signal()
      @node = false
      @is_output = false
      @changed = true
      @connections = []
      ThreeNodes.nodes.fields[@fid] = this
      @on_value_changed(@val)
    
    set: (v) =>
      @changed = true
      @node.dirty = true
      
      v = @on_value_changed(v)
      for hook of @on_value_update_hooks
        @on_value_update_hooks[hook](v)
      if @is_output == true
        for connection in @connections
          connection.to_field.set(v)
      true
  
    get: (index = 0) =>
      if $.type(@val) != "array"
        return @val
      else
        return @val[index % @val.length]
    
    isChanged: () =>
      res = @changed
      @changed = false
      res
    
    isConnected: () =>
      @connections.length > 0
    
    getSliceCount: () =>
      if jQuery.type(@val) != "array"
        return 1
      return @val.length
    
    toJSON : () =>
      res =
        name: @name
      # help avoid cyclic value
      val_type = jQuery.type(@get())
      if val_type != "object" && val_type != "array"
        res.val = @get()
      res
    
    toXML : () =>
      "\t\t\t<field fid='#{@fid}' val='#{@get()}'/>\n"
  
    render_connections: () =>
      for connection in @connections
          connection.render()
      true
    
    render_sidebar: =>
      false
    
    render_button: =>
      layout = _view_node_field_in
      if @is_output
        layout = _view_node_field_out
      $.tmpl(layout, this)
      
    compute_value : (val) =>
      val
    
    add_connection: (c) =>
      if @connections.indexOf(c) == -1
        @connections.push c
      if @is_output == true
        @node.add_out_connection(c, this)
      c
    
    unregister_connection: (c) =>
      @node.remove_connection(c)
      ind = @connections.indexOf(c)
      if ind != -1
        @connections.splice(ind, 1)
      
    # called on shift click on a field / remove all connections
    remove_connections: () =>
      @connections[0].remove() while @connections.length > 0
      true
      
    on_value_changed : (val) =>
      self = this
      switch $.type(val)
        when "array" then @val = _.map(val, (n) -> self.compute_value(n))
        else @val = @compute_value(val)
      @val
    
    create_sidebar_container: (name = @name) =>
      $cont = $("#tab-attribute")
      $cont.append("<div id='side-field-" + @fid + "'></div>")
      $target = $("#side-field-#{@fid}")
      $target.append("<h3>#{name}</h3>")
      return $target
    
    create_textfield: ($target, id) =>
      $target.append("<div><input type='text' id='#{id}' /></div>")
      return $("#" + id)
    
    link_textfield_to_val: (f_input) =>
      self = this
      @on_value_update_hooks.update_sidebar_textfield = (v) ->
        f_input.val(v)
      f_input.val(@get())
      f_input.keypress (e) ->
        if e.which == 13
          self.set($(this).val())
          $(this).blur()
      f_input
    
    link_textfield_to_subval: (f_input, subval) =>
      self = this
      @on_value_update_hooks["update_sidebar_textfield_" + subval] = (v) ->
        f_input.val(v[subval])
      f_input.val(@get()[subval])
      f_input.keypress (e) ->
        if e.which == 13
          self.val[subval] = $(this).val()
          $(this).blur()
      f_input
  
    create_subval_textinput: (subval) =>
      $target = @create_sidebar_container(subval)
      f_in = create_textfield($target, "side-field-txt-input-#{subval}-#{@fid}")
      link_textfield_to_subval(f_in, subval)
  
  class ThreeNodes.fields.types.Any extends ThreeNodes.NodeField
    compute_value : (val) =>
      val
    
    on_value_changed : (val) =>
      @val = @compute_value(val)
    
  class ThreeNodes.fields.types.Array extends ThreeNodes.NodeField
    compute_value : (val) =>
      if !val || val == false
        return []
      if $.type(val) == "array"
        val
      else
        [val]
    
    remove_connections: () =>
      super
      if @is_output == false
        @on_value_changed([])
    
    on_value_changed : (val) =>
      @val = @compute_value(val)
    
    get: (index = 0) => @val
    
  class ThreeNodes.fields.types.Bool extends ThreeNodes.NodeField
    render_sidebar: =>
      self = this
      $target = @create_sidebar_container()
      id = "side-field-checkbox-#{@fid}"
      $target.append("<div><input type='checkbox' id='#{id}'/></div>")
      f_in = $("#" + id)
      @on_value_update_hooks.update_sidebar_textfield = (v) ->
        if self.get() == true
          f_in.attr('checked', 'checked')
        else
          f_in.removeAttr('checked')
      if @get() == true
        f_in.attr('checked', 'checked')
      f_in.change (e) ->
        if $(this).is(':checked')
          self.set(true)
        else
          self.set(false)
      true
    
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "boolean" then res = val
        when "number" then res = val != 0
        when "string" then res = val == "1"
      res
  
  class ThreeNodes.fields.types.String extends ThreeNodes.NodeField
    render_sidebar: =>
      self = this
      $target = @create_sidebar_container()
      f_in = create_textfield($target, "side-field-txt-input-#{@fid}")
      @on_value_update_hooks.update_sidebar_textfield = (v) ->
        f_in.val(v.toString())
      f_in.val(@get())
      f_in.keypress (e) ->
        if e.which == 13
          self.set($(this).val())
          $(this).blur()
      true
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then res = val
        when "number" then res = val.toString
        when "string" then res = val
      res
  
  class ThreeNodes.fields.types.Float extends ThreeNodes.NodeField
    create_sidebar_select: ($target) =>
      self = this
      input = "<div><select>"
      for f of @possible_values
        dval = @possible_values[f]
        if dval == @val
          input += "<option value='#{dval}' selected='selected'>#{f}</option>"
        else
          input += "<option value='#{dval}'>#{f}</option>"
      input += "</select></div>"
      $target.append(input)
      $("select", $target).change (e) ->
        self.set($(this).val())
      return true
    
    create_sidebar_input: ($target) =>
      f_in = @create_textfield($target, "side-field-txt-input-#{@fid}")
      @link_textfield_to_val(f_in)
          
    render_sidebar: =>
      $target = @create_sidebar_container()
      if @possible_values
        @create_sidebar_select($target)
      else
        @create_sidebar_input($target)
      
      true
    
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then res = val
        when "number" then res = parseFloat(val)
        when "string" then res = parseFloat(val)
        when "boolean"
          if val
            res = 1
          else
            res = 0
      res
      
  class ThreeNodes.fields.types.Vector2 extends ThreeNodes.NodeField
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then  res = val
        when "object" then if val.constructor == THREE.Vector2
          res = val
      res
    
    render_sidebar: =>
      create_subval_textinput("x")
      create_subval_textinput("y")
      true
  
  class ThreeNodes.fields.types.Vector3 extends ThreeNodes.NodeField
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then res = val
        when "object" then if val.constructor == THREE.Vector3
          res = val
      res
    
    render_sidebar: =>
      create_subval_textinput("x")
      create_subval_textinput("y")
      create_subval_textinput("z")
      true
  
  class ThreeNodes.fields.types.Vector4 extends ThreeNodes.NodeField
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then res = val
        when "object" then if val.constructor == THREE.Vector4
          res = val
      res
    
    render_sidebar: =>
      create_subval_textinput("x")
      create_subval_textinput("y")
      create_subval_textinput("z")
      create_subval_textinput("w")
      true
  
  class ThreeNodes.fields.types.Quaternion extends ThreeNodes.NodeField
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then res = val
        when "object" then if val.constructor == THREE.Quaternion
          res = val
      res
      
  class ThreeNodes.fields.types.Color extends ThreeNodes.NodeField
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then res = val
        when "number" then res = new THREE.Color().setRGB(val, val, val)
        when "object"
          switch val.constructor
            when THREE.Color then res = val
            when THREE.Vector3 then res = new THREE.Color().setRGB(val.x, val.y, val.z)
        when "boolean"
          if val
            res = new THREE.Color(0xffffff)
          else
            res = new THREE.Color(0x000000)
      res
   
  class ThreeNodes.fields.types.Object3D extends ThreeNodes.NodeField
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then res = val
        when "object" then if val.constructor == THREE.Object3D || val instanceof THREE.Object3D
          res = val
      res
  class ThreeNodes.fields.types.Scene extends ThreeNodes.NodeField
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then res = val
        when "object" then if val.constructor == THREE.Scene
          res = val
      res
  class ThreeNodes.fields.types.Camera extends ThreeNodes.NodeField
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then res = val
        when "object" then if val.constructor == THREE.Camera || val.constructor == THREE.PerspectiveCamera || val.constructor == THREE.OrthographicCamera
          res = val
      res
  class ThreeNodes.fields.types.Mesh extends ThreeNodes.NodeField
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then res = val
        when "object" then if val.constructor == THREE.Mesh || val instanceof THREE.Mesh
          res = val
      res
  class ThreeNodes.fields.types.Geometry extends ThreeNodes.NodeField
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then res = val
        when "object" then if val.constructor == THREE.Geometry || val instanceof THREE.Geometry
          res = val
      res
  class ThreeNodes.fields.types.Material extends ThreeNodes.NodeField
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then res = val
        when "object" then if val.constructor == THREE.Material || val instanceof THREE.Material
          res = val
      res
  class ThreeNodes.fields.types.Texture extends ThreeNodes.NodeField
    compute_value : (val) =>
      res = @val
      switch $.type(val)
        when "array" then res = val
        when "object" then if val.constructor == THREE.Texture || val instanceof THREE.Texture
          res = val
      res
