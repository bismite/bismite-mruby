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
  # shader
  shader_vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  shader_frag = SHADER_HEADER + assets.read("assets/shaders/collapse.frag")
  layer.shader = Bi::Shader.new shader_vert,shader_frag
  # animation
  t=0
  layer.create_timer(0,-1) {|timer,dt|
    t+=dt/2000.0
    face.set_shader_extra_data 0, Math::sin(t).abs
  }
end

Bi::start_run_loop
