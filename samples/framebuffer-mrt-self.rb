if Bi::Version.emscripten
  SHADER_HEADER="#version 300 es\nprecision highp float;\n"
else
  SHADER_HEADER="#version 410\n"
end

def make_framebuffer_node(w,h)
  fb_node = Bi::Node.rect w,h
  # 8 Render Target Textures
  #  0: Result
  #  1,2,3,4,5,6,7: RGBCMYK
  fb_node.framebuffer = Bi::Framebuffer.new Bi.w,Bi.h,8
  fb_node.flip_vertical = true
  fb_tex = fb_node.framebuffer.textures[0]
  fb_node.set_texture fb_tex, 0,0,fb_tex.w,fb_tex.h
  fb_node
end

Bi.init 480,320,title:__FILE__,highdpi:true
Bi::Archive.load("assets.dat","abracadabra") do |assets|
  map = assets.texture("assets/map.png").to_sprite

  # Framebuffer Node
  framebuffer_node = make_framebuffer_node(Bi.w,Bi.h)
  framebuffer_node.flip_vertical = true

  # ShaderNode A : RGBYMCK
  mrt_shader_node_a = Bi::ShaderNode.new
  vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  frag = SHADER_HEADER + assets.read("assets/shaders/mrt_rgbcmyk.frag")
  mrt_shader_node_a.shader = Bi::Shader.new vert,frag
  mrt_shader_node_a.add map
  mrt_shader_node_a.set_texture 0, map.texture
  framebuffer_node.add mrt_shader_node_a

  # ShaderNode B : Result
  mrt_shader_node_b = Bi::ShaderNode.new
  vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  frag = SHADER_HEADER + assets.read("assets/shaders/mrt_rgbcmyk_blend.frag")
  mrt_shader_node_b.shader = Bi::Shader.new vert,frag
  board = Bi::Node.rect(Bi.w,Bi.h)
  board.set_texture framebuffer_node.framebuffer.textures[1],0,0,Bi.w,Bi.h
  mrt_shader_node_b.add board
  framebuffer_node.add mrt_shader_node_b
  7.times{|i|
    # Read self textures
    mrt_shader_node_b.set_texture i, framebuffer_node.framebuffer.textures[1+i]
  }

  # Draw
  shader_node = Bi::ShaderNode.new
  shader_node.add framebuffer_node
  shader_node.set_texture 0,framebuffer_node.texture
  Bi.add shader_node
end
Bi::start_run_loop
