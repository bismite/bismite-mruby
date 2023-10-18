
Bi.init 480,320,title:__FILE__,highdpi:false
Bi::Archive.load("assets.dat","abracadabra") do |assets|
  bg_tex = assets.texture("assets/check.png")
  face_tex = assets.texture("assets/face01.png")
  # Sprite
  face = face_tex.to_sprite
  face.set_position 20,20
  # canvas
  canvas = Bi::Canvas.new 128,128
  puts "Canvas size: #{canvas.w},#{canvas.h}"
  canvas.clear 0,0xff,0,128
  canvas.shader = Bi.default_shader
  canvas.set_texture 0, face.texture
  canvas.draw face
  canvas.save_png "canvas.png"
  new_texture = canvas.to_texture
  new_sprite = new_texture.to_sprite
  new_sprite.set_position 160,0
  # layer
  layer = Bi::Layer.new
  layer.add bg_tex.to_sprite
  layer.add face
  layer.add new_sprite
  layer.set_texture 0, bg_tex
  layer.set_texture 1, face_tex
  layer.set_texture 2, new_sprite.texture
  Bi::layers.add layer
end
Bi::start_run_loop
