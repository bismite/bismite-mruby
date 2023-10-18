
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

def newface(tex,r,g,b)
  face = tex.to_sprite
  face.tint = Bi::Color.new r,g,b,0xff
  face.anchor = :center
  return face
end

Bi.init 480,320,title: __FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  bg_tex = assets.texture "assets/check.png"
  face_tex = assets.texture "assets/face01.png"
  # faces
  face_green = newface face_tex,0,0xff,0
  face_green.set_position Bi.w/2, Bi.h/2
  face_red = newface face_tex, 0xff,0,0
  face_red.set_position Bi.w/3, Bi.h/3*2
  face_blue = newface face_tex,0,0,0xff
  face_blue.set_position Bi.w/3, Bi.h/3*1
  # By Actions
  by_actions face_red
  # To Actions
  to_actions face_blue
  #
  layer = Bi::Layer.new
  layer.add bg_tex.to_sprite
  layer.add face_green
  layer.add face_red
  layer.add face_blue
  layer.set_texture 0, bg_tex
  layer.set_texture 1, face_tex
  Bi::layers.add layer
end

Bi::start_run_loop
