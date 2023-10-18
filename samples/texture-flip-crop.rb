
Bi.init 480,320,title:__FILE__,highdpi:false

Bi::Archive.load("assets.dat","abracadabra"){|assets|
  # texture
  tex = assets.texture("assets/face01.png")
  bg_tex = assets.texture("assets/check.png")

  # layer
  layer = Bi::Layer.new
  layer.set_texture 0, bg_tex
  layer.set_texture 1, tex
  layer.add bg_tex.to_sprite
  Bi::layers.add layer

  # Straight
  face1 = tex.to_sprite
  face1.set_position Bi.w/3,Bi.h/3*2
  face1.anchor = :center
  layer.add face1

  # Flip Vertical
  face2 = tex.to_sprite
  face2.set_position Bi.w/3*2,Bi.h/3*2
  face2.anchor = :center
  face2.flip_vertical = true
  layer.add face2

  # Flip Horizontal
  face2 = tex.to_sprite
  face2.set_position Bi.w/3,Bi.h/3
  face2.anchor = :center
  face2.flip_horizontal = true
  layer.add face2

  # Crop
  face3 = tex.to_sprite 32,32,64,64, 32,32,128,128
  face3.set_position Bi.w/3*2,Bi.h/3
  face3.anchor = :center
  layer.add face3
}

Bi::start_run_loop
