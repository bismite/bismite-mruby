
if Bi::Version.emscripten
  SHADER_HEADER="#version 100\nprecision highp float;\n"
else
  SHADER_HEADER="#version 120\n"
end

Bi.init 480,320,title:__FILE__,hidpi:true

Bi::Archive.new("assets.dat","abracadabra").load do |assets|

  # shader
  shader_vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  shader_frag = SHADER_HEADER + assets.read("assets/shaders/postprocess-dissolve.frag")

  # main layer
  layer = Bi::Layer.new
  layer.root = assets.texture("assets/check.png").to_sprite
  layer.set_texture 0, layer.root.texture
  Bi::add_layer layer

  # post process layer group
  lg = Bi::LayerGroup.new
  # face layer
  layer = Bi::Layer.new
  layer.root = assets.texture("assets/face01.png").to_sprite
  layer.root.anchor = :center
  layer.root.scale_x = layer.root.scale_y = 2.0
  layer.root.set_position Bi.w/2, Bi.h/2
  layer.set_texture 0, layer.root.texture
  lg.add_layer layer
  Bi::layers.add_layer_group lg

  # post process
  layer = Bi::Layer.new
  layer.root = assets.texture("assets/noise.png").to_sprite
  layer.set_texture 0, layer.root.texture
  layer.set_post_process_shader Bi::Shader.new shader_vert,shader_frag
  layer.set_post_process_framebuffer_enabled true
  lg.add_layer layer
end

Bi::start_run_loop
