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
  face.set_position Bi.w/2,Bi.h/2
  face.anchor = :center
  # layer
  layer = Bi::Layer.new
  layer.set_texture 0, bg_tex
  layer.set_texture 1, face_tex
  Bi::layers.add layer
  layer.add bg_tex.to_sprite
  layer.add face
  # shader
  shader_vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  shader_frag_distortion = SHADER_HEADER + assets.read("assets/shaders/distortion.frag")
  shader_frag_blur = SHADER_HEADER + assets.read("assets/shaders/blur.frag")
  layer.shader = Bi::Shader.new shader_vert,shader_frag_distortion
  layer.create_timer(500,-1) {|timer,dt|
    layer.set_shader_extra_data 0, rand
    layer.set_shader_extra_data 1, rand
    layer.set_shader_extra_data 2, rand
    layer.set_shader_extra_data 3, 0
  }
end

Bi::start_run_loop
