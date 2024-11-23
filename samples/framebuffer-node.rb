
def make_framebuffer_node(w,h)
  fb_node = Bi::Node.rect w,h
  fb_node.framebuffer = Bi::Framebuffer.new Bi.w,Bi.h
  fb_node.flip_vertical = true
  fb_tex = fb_node.framebuffer.to_texture(0)
  fb_node.set_texture fb_tex, 0,0,fb_tex.w,fb_tex.h
  fb_node
end

Bi.init 480,320,title:__FILE__,highdpi:true
Bi::Archive.load("assets.dat","abracadabra") do |assets|
  bg = assets.texture("assets/check.png").to_sprite
  face = assets.texture("assets/face01.png").to_sprite
  # Main Node (Framebuffer)
  main_shader_node = Bi::ShaderNode.new
  main_shader_node.add bg
  main_shader_node.add face
  main_shader_node.set_texture 0, bg.texture
  main_shader_node.set_texture 1, face.texture
  main_node = make_framebuffer_node(Bi.w,Bi.h)
  main_node.add main_shader_node
  # Shader (Main Node -> Default Framebuffer)
  shader_node = Bi::ShaderNode.new
  shader_node.add main_node
  shader_node.set_texture 0,main_node.texture
  Bi.add shader_node
end
Bi::start_run_loop
