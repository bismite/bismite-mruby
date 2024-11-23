if Bi::Version.emscripten
  SHADER_HEADER="#version 300 es\nprecision highp float;\n"
else
  SHADER_HEADER="#version 410\n"
end

def make_framebuffer_node(w,h)
  fb_node = Bi::Node.rect w,h
  fb_node.framebuffer = Bi::Framebuffer.new Bi.w,Bi.h
  fb_node.flip_vertical = true
  fb_tex = fb_node.framebuffer.to_texture(0)
  fb_node.set_texture fb_tex, 0,0,fb_tex.w,fb_tex.h
  fb_node
end

# Default Framebuffer
#   Background Shader
#     Background Sprite
#   Post Process Shader
#     Main Screen (Framebuffer Node)
#       Main Shader Node
#         Face Sprite
Bi.init 480,320,title:__FILE__,hidpi:true
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  # Sprites
  bg = assets.texture("assets/check.png").to_sprite
  face = assets.texture("assets/face01.png").to_sprite
  face.anchor = :center
  face.set_position Bi.w/2,Bi.h/2
  face.scale = 2
  # Background
  bg_shader = Bi::ShaderNode.new
  bg_shader.set_texture 0, bg.texture
  bg_shader.add bg
  Bi.add bg_shader
  # Main Screen and Shader
  main_shader = Bi::ShaderNode.new
  main_shader.set_texture 1, face.texture
  main_shader.add face
  main_screen = make_framebuffer_node(Bi.w,Bi.h)
  main_screen.add main_shader
  # Post Process Shader
  post_process_shader_node = Bi::ShaderNode.new
  vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  frag = SHADER_HEADER + assets.read("assets/shaders/dissolve.frag")
  post_process_shader_node.shader = Bi::Shader.new vert,frag
  post_process_shader_node.add main_screen
  post_process_shader_node.set_texture 0, main_screen.texture
  post_process_shader_node.set_texture 1, assets.texture("assets/noise.png")
  Bi.add post_process_shader_node
end


Bi::start_run_loop
