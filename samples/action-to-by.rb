
Bi.init 480,320,title: __FILE__

def by_actions(n)
  n.add_action Bi::Action::RotateBy.new(6000, 360)
  n.add_action Bi::Action::MoveBy.new(6000, 240, 0)
  n.add_action Bi::Action::ScaleBy.new(6000, 2, 2)
end

def to_actions(n)
  n.add_action Bi::Action::RotateTo.new(6000, 360)
  n.add_action Bi::Action::MoveTo.new(6000, 240, 120)
  n.add_action Bi::Action::ScaleTo.new(6000, 2, 2)
end

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  bg_texture = assets.texture "assets/check.png"
  texture = assets.texture "assets/face01.png"

  face_green = texture.to_sprite
  face_green.set_color 0,0xff,0
  face_green.set_scale 1.0, 1.0
  face_green.anchor = :center
  face_green.set_position Bi.w/2, Bi.h/2

  face_red = texture.to_sprite
  face_red.set_color 0xff,0,0
  face_red.set_scale 0.5,0.5
  face_red.anchor = :center
  face_red.set_position Bi.w/3, Bi.h/3*2

  face_blue = texture.to_sprite
  face_blue.set_color 0,0,0xff
  face_blue.set_scale 0.5,0.5
  face_blue.anchor = :center
  face_blue.set_position Bi.w/3, Bi.h/3*1

  # By Actions
  by_actions face_red
  # To Actions
  to_actions face_blue

  layer = Bi::Layer.new
  layer.root = bg_texture.to_sprite
  layer.root.add face_green
  layer.root.add face_red
  layer.root.add face_blue
  layer.set_texture 0, bg_texture
  layer.set_texture 1, texture
  Bi::add_layer layer
end

Bi::start_run_loop
