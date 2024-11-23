if Bi::Version.emscripten
  SHADER_HEADER="#version 300 es\nprecision highp float;\n"
else
  SHADER_HEADER="#version 410\n"
end

Bi.init 480,320,title:__FILE__,hidpi:true
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  bg = assets.texture("assets/check.png").to_sprite
  face = assets.texture("assets/face01.png").to_sprite
  face.anchor = :center
  shader_node = Bi::ShaderNode.new
  shader_node.set_texture 0, bg.texture
  shader_node.set_texture 1, face.texture
  shader_node.add bg
  shader_node.add face,240,160
  shader_vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  shader_frag = SHADER_HEADER + assets.read("assets/shaders/collapse.frag")
  shader_node.shader = Bi::Shader.new shader_vert,shader_frag
  Bi.add shader_node
  # animation
  t=0
  shader_node.create_timer(0,-1) {|timer,dt|
    t+=dt/2000.0
    face.set_shader_extra_data 0, Math::sin(t).abs
  }
end

Bi::start_run_loop
