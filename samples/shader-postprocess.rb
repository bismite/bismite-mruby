if Bi::Version.emscripten
  SHADER_HEADER="#version 300 es\nprecision highp float;\n"
else
  SHADER_HEADER="#version 410\n"
end

Bi.init 480,320,title:__FILE__,hidpi:true
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  # Texture
  bg_tex = assets.texture("assets/check.png")
  face_tex = assets.texture("assets/face01.png")
  # Sprite
  face = face_tex.to_sprite
  # layer
  layer = Bi::Layer.new
  layer.set_texture 0, bg_tex
  layer.set_texture 1, face_tex
  Bi::layers.add layer
  layer.add bg_tex.to_sprite
  layer.add face,:center,:center
  # PostProcessLayer
  pp = Bi::PostProcessLayer.new
  vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  frag = SHADER_HEADER + assets.read("assets/shaders/blur.frag")
  framebuffer_texture = Bi::layers.framebuffer.to_texture
  pp.set_texture 0,framebuffer_texture
  pp.shader = Bi::Shader.new vert,frag
  pp_node = Bi::Node.new
  pp_node.set_texture framebuffer_texture,0,0,framebuffer_texture.w,framebuffer_texture.h
  pp_node.flip_vertical = true
  pp_node.set_size 480,320
  pp.add pp_node
  Bi::layers.add pp
end

Bi::start_run_loop
