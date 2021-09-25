
if Bi::Version.emscripten
  SHADER_HEADER="#version 100\nprecision highp float;\n"
else
  SHADER_HEADER="#version 120\n"
end

Bi.init 480,320,title:__FILE__,hidpi:true

Bi::Archive.new("assets.dat","abracadabra").load do |assets|

  # layer
  layer = Bi::Layer.new
  layer.root = Bi::Node.new
  layer.root.set_color 0x33,0,0,0xff
  layer.root.set_size Bi.w,Bi.h
  Bi::add_layer layer

  # shader
  shader_vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  shader_frag_distortion = SHADER_HEADER + assets.read("assets/shaders/distortion-ball.frag")
  shader_frag_blur = SHADER_HEADER + assets.read("assets/shaders/blur.frag")

  layer.shader = Bi::Shader.new shader_vert,shader_frag_distortion
  layer.set_post_process_shader Bi::Shader.new shader_vert,shader_frag_blur

  layer.root.on_move_cursor {|n,x,y|
    layer.set_shader_attribute 0, x
    layer.set_shader_attribute 1, y
  }

  # bg
  sky = assets.texture("assets/sky.png").to_sprite
  layer.root.add sky

  # front texture
  face = assets.texture("assets/face01.png").to_sprite
  face.set_position Bi.w/2,Bi.h/2
  face.anchor = :center
  layer.root.add face

  layer.set_texture 0, sky.texture_mapping.texture
  layer.set_texture 1, face.texture_mapping.texture
end

Bi::start_run_loop
