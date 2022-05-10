
Bi.init 480,320,title:__FILE__,highdpi:false

Bi::Archive.load("assets.dat","abracadabra") do |assets|
  # layer
  layer = Bi::Layer.new
  layer.root = assets.texture("assets/check.png").to_sprite
  Bi::add_layer layer

  # texture
  face = assets.texture("assets/face01.png").to_sprite
  face.set_position 10,10

  # canvas
  canvas = Bi::Canvas.new 128,128
  canvas.clear 0xff,0,0
  canvas.shader = Bi.default_shader
  canvas.set_texture 0, face.texture
  canvas.draw face
  canvas.save_png "canvas.png"
  new_texture = canvas.to_texture
  new_sprite = new_texture.to_sprite
  new_sprite.set_position Bi.w/2, Bi.h/2

  layer.root.add face
  layer.root.add new_sprite

  layer.set_texture 0, layer.root.texture
  layer.set_texture 1, face.texture
  layer.set_texture 2, new_sprite.texture
end

Bi::start_run_loop
