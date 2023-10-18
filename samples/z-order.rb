
Bi.init 480,320,title:__FILE__
Bi::Archive.load("assets.dat","abracadabra"){|assets|
  bg_tex = assets.texture("assets/check.png")
  face_tex = assets.texture("assets/face01.png")
  mush_tex = assets.texture("assets/mushroom.png")

  # layer
  layer = Bi::Layer.new
  layer.add bg_tex.to_sprite
  layer.set_texture 0, mush_tex
  layer.set_texture 1, face_tex
  layer.set_texture 2, bg_tex
  Bi::layers.add layer

  # Face
  face = face_tex.to_sprite
  face.set_position Bi.w/2,Bi.h/2
  face.anchor = :center
  # mushroom
  mushroom = mush_tex.to_sprite
  mushroom.set_position Bi.w/2,Bi.h/2
  mushroom.anchor = :center

  # Wrong Order
  layer.add mushroom
  layer.add face
  # Fix Order
  face.z = 0
  mushroom.z = 1
}
Bi::start_run_loop
