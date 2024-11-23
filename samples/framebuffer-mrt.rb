if Bi::Version.emscripten
  SHADER_HEADER="#version 300 es\nprecision highp float;\n"
else
  SHADER_HEADER="#version 410\n"
end

def make_framebuffer_node(w,h)
  fb_node = Bi::Node.rect w,h
  # 2 Render Target Textures
  fb_node.framebuffer = Bi::Framebuffer.new Bi.w,Bi.h,2
  fb_node.flip_vertical = true
  fb_tex = fb_node.framebuffer.to_texture(0)
  fb_node.set_texture fb_tex, 0,0,fb_tex.w,fb_tex.h
  fb_node
end

Bi.init 480,320,title:__FILE__,highdpi:true
Bi::Archive.load("assets.dat","abracadabra") do |assets|
  bg = assets.texture("assets/map.png").to_sprite
  face = assets.texture("assets/face01.png").to_sprite
  face.anchor = :center
  face.set_position Bi.w/2,Bi.h/2

  # Framebuffer Node, Multiple Render Target
  mrt_shader_node = Bi::ShaderNode.new
  vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  frag = SHADER_HEADER + assets.read("assets/shaders/mrt.frag")
  mrt_shader_node.shader = Bi::Shader.new vert,frag
  mrt_shader_node.add face
  mrt_shader_node.set_texture 0, face.texture
  framebuffer_node = make_framebuffer_node(Bi.w,Bi.h)
  framebuffer_node.add mrt_shader_node
  # Silhouette Node (Second Texture of Framebuffer)
  second_node = framebuffer_node.framebuffer.to_texture(1).to_sprite
  second_node.flip_vertical = true
  second_node.set_position -20,-20

  # Draw
  shader_node = Bi::ShaderNode.new
  shader_node.add bg
  shader_node.add second_node
  shader_node.add framebuffer_node
  shader_node.set_texture 0,bg.texture
  shader_node.set_texture 1,second_node.texture
  shader_node.set_texture 2,framebuffer_node.texture
  Bi.add shader_node
end
Bi::start_run_loop
