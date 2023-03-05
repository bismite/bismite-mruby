
Bi.init 480,320,title:__FILE__,highdpi:false

Bi::Archive.load("assets.dat","abracadabra"){|assets|

  # layer
  layer = Bi::Layer.new
  layer.root = assets.texture("assets/check.png").to_sprite
  Bi::add_layer layer

  # texture
  tex = assets.texture("assets/face01.png")

  # Straight
  face1 = tex.to_sprite
  face1.set_position Bi.w/3,Bi.h/3*2
  face1.anchor = :center
  layer.root.add face1

  # Flip Vertical
  face2 = tex.to_sprite
  face2.set_position Bi.w/3*2,Bi.h/3*2
  face2.anchor = :center
  face2.flip_vertical = true
  layer.root.add face2

  # Flip Horizontal
  face2 = tex.to_sprite
  face2.set_position Bi.w/3,Bi.h/3
  face2.anchor = :center
  face2.flip_horizontal = true
  layer.root.add face2

  # Crop
  face3 = tex.to_sprite 32,32,64,64, 32,32,128,128
  face3.set_position Bi.w/3*2,Bi.h/3
  face3.anchor = :center
  layer.root.add face3

  layer.set_texture 0, layer.root.texture
  layer.set_texture 1, tex
}

Bi::start_run_loop
