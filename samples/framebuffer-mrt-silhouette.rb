if Bi::Version.emscripten
  SHADER_HEADER="#version 300 es\nprecision highp float;\n"
else
  SHADER_HEADER="#version 410\n"
end

Bi.init 480,320,title:__FILE__,highdpi:true
Bi::Archive.load("assets.dat","abracadabra") do |assets|
  bg = assets.texture("assets/map.png").to_sprite
  face = assets.texture("assets/face01.png").to_sprite
  face.anchor = :center
  face.set_position Bi.w/2,Bi.h/2

  # Framebuffer Node, Multiple Render Target (2 textures)
  # 0:silhouette 1:color
  silhouette_node = Bi::Node.rect Bi.w,Bi.h
  silhouette_node.framebuffer = Bi::Framebuffer.new Bi.w,Bi.h,2
  silhouette_node.flip_vertical = true
  silhouette_node.scale_y = 0.75
  # assign first texture of framebuffer
  fbtex = silhouette_node.framebuffer.textures[0]
  silhouette_node.set_texture fbtex, 0,0,fbtex.w,fbtex.h
  # shader for framebuffer node
  mrt_shader_node = Bi::ShaderNode.new
  vert = SHADER_HEADER + assets.read("assets/shaders/default.vert")
  frag = SHADER_HEADER + assets.read("assets/shaders/mrt-silhouette.frag")
  mrt_shader_node.shader = Bi::Shader.new vert,frag
  mrt_shader_node.add face
  mrt_shader_node.set_texture 0, face.texture
  silhouette_node.add mrt_shader_node
  # Color Node (Second Texture of Framebuffer)
  color_node = silhouette_node.framebuffer.textures[1].to_sprite
  color_node.flip_vertical = true
  # result
  shader_node = Bi::ShaderNode.new
  shader_node.add bg
  shader_node.add silhouette_node
  shader_node.add color_node
  shader_node.set_texture 0,bg.texture
  shader_node.set_texture 1,silhouette_node.texture
  shader_node.set_texture 2,color_node.texture
  Bi.add shader_node
end
Bi::start_run_loop
