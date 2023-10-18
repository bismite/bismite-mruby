
if Bi::Version.emscripten
  SHADER_HEADER="#version 300 es\nprecision highp float;\n"
else
  SHADER_HEADER="#version 410\n"
end

Bi.init 480,320,title:__FILE__,hidpi:true
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  # shader
  shader_vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  shader_frag = SHADER_HEADER + assets.read("assets/shaders/postprocess-dissolve.frag")
  # tex
  bg_tex = assets.texture("assets/check.png")
  face_tex = assets.texture("assets/face01.png")
  noise_tex = assets.texture("assets/noise.png")

  # background
  layer = Bi::Layer.new
  layer.add bg_tex.to_sprite
  layer.set_texture 0, bg_tex
  Bi::layers.add layer

  # LayerGroup
  layer_group = Bi::LayerGroup.new
  Bi::layers.add layer_group

  # face layer
  layer = Bi::Layer.new
  face = face_tex.to_sprite
  layer.add face
  face.anchor = :center
  face.scale = 2.0
  face.set_position Bi.w/2, Bi.h/2
  layer.set_texture 0, face_tex
  layer_group.add layer

  # post process
  framebuffer_texture = layer_group.framebuffer.to_texture
  pp = Bi::PostProcessLayer.new
  pp.shader = Bi::Shader.new shader_vert,shader_frag
  pp_node = framebuffer_texture.to_sprite
  pp_node.flip_vertical = true
  pp.add pp_node
  pp.set_texture 0, framebuffer_texture
  pp.set_texture 1, noise_tex
  layer_group.add pp
end
Bi::start_run_loop
