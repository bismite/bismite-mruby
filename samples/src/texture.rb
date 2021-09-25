
Bi.init 480,320,title:__FILE__,highdpi:false

Bi::Archive.load("assets.dat","abracadabra") do |assets|
  # layer
  layer = Bi::Layer.new
  layer.root = assets.texture("assets/check.png").to_sprite
  Bi::add_layer layer

  # texture
  face = assets.texture("assets/face01.png").to_sprite
  face.set_position Bi.w/2,Bi.h/2
  face.scale_x = face.scale_y = 2.0
  face.anchor = :center
  layer.root.add face

  layer.set_texture 0, layer.root.texture_mapping.texture
  layer.set_texture 1, face.texture_mapping.texture
end

Bi::start_run_loop
