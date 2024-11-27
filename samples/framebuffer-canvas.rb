
Bi.init 480,320,title:__FILE__,highdpi:true

Bi::Archive.load("assets.dat","abracadabra") do |assets|
  bg_tex = assets.texture("assets/check.png")

  # Draw
  face_tex = assets.texture("assets/face01.png")
  fb_node = Bi::Node.new
  fb_node.framebuffer = Bi::Framebuffer.new 128,128
  fb_node.framebuffer.clear Bi::Color::rgba(0x33000080)
  face = face_tex.to_sprite
  face.set_position 20,20
  fb_shader = Bi::ShaderNode.new
  fb_shader.set_texture 0, face.texture
  fb_shader.add face
  fb_node.add fb_shader
  Bi.draw_framebuffer_node fb_node
  fb_node.framebuffer.textures[0].save_png "canvas.png"

  # Sprite from Framebuffer
  fb_texture = fb_node.framebuffer.textures[0]
  new_sprite = fb_texture.to_sprite
  new_sprite.flip_vertical = true
  new_sprite.set_position 100,100
  # Draw Framebuffer to Main screen
  main_shader_node = Bi::ShaderNode.new
  main_shader_node.add bg_tex.to_sprite
  main_shader_node.add new_sprite
  main_shader_node.set_texture 0, bg_tex
  main_shader_node.set_texture 1, fb_texture
  Bi.add main_shader_node
end
Bi::start_run_loop
