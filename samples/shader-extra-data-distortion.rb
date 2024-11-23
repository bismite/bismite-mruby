if Bi::Version.emscripten
  SHADER_HEADER="#version 300 es\nprecision highp float;\n"
else
  SHADER_HEADER="#version 410\n"
end

Bi.init 480,320,title:__FILE__,hidpi:true
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  # Shader Node
  shader_node = Bi::ShaderNode.new
  shader_vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  shader_frag = SHADER_HEADER + assets.read("assets/shaders/distortion.frag")
  shader_node.shader = Bi::Shader.new shader_vert,shader_frag
  Bi.add shader_node
  # Draw
  bg = assets.texture("assets/check.png").to_sprite
  face = assets.texture("assets/face01.png").to_sprite
  face.anchor = :center
  shader_node.set_texture 0, bg.texture
  shader_node.set_texture 1, face.texture
  shader_node.add bg
  shader_node.add face,240,160

  shader_node.create_timer(500,-1) {|timer,dt|
    shader_node.set_shader_extra_data 0, rand
    shader_node.set_shader_extra_data 1, rand
    shader_node.set_shader_extra_data 2, rand
    shader_node.set_shader_extra_data 3, 0
  }
end

Bi::start_run_loop
