if Bi::Version.emscripten
  SHADER_HEADER="#version 300 es\nprecision highp float;\n"
else
  SHADER_HEADER="#version 410\n"
end

Bi.init 480,320,title:__FILE__,highdpi:true
Bi::Archive.load("assets.dat","abracadabra") do |assets|
  # 2 Render Target
  fb_node = Bi::Node.rect Bi.w,Bi.h
  fb_node.framebuffer = Bi::Framebuffer.new Bi.w,Bi.h,2
  fb_node.flip_vertical = true
  fb_tex = fb_node.framebuffer.textures[0] # draw texture[0]
  fb_node.set_texture fb_tex, 0,0,fb_tex.w,fb_tex.h
  # Draw Rectangle to texture[1]
  shader_node = Bi::ShaderNode.new
  vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  frag = SHADER_HEADER + assets.read("assets/shaders/mrt-simple.frag")
  shader_node.shader = Bi::Shader.new vert,frag
  shader_node.add Bi::Node.xywh(100,100,100,100)
  fb_node.add shader_node
  # Copy texture[1] -> texture[0]
  shader_node2 = Bi::ShaderNode.new
  board = fb_node.framebuffer.textures[1].to_sprite
  shader_node2.add board
  shader_node2.set_texture 0, board.texture
  fb_node.add shader_node2
  # Draw
  root_shader_node = Bi::ShaderNode.new
  root_shader_node.add fb_node
  root_shader_node.set_texture 0, fb_node.framebuffer.textures[0]
  Bi.add root_shader_node
end
Bi::start_run_loop
