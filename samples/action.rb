
Bi.init 480,320,title: __FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  texture = assets.texture "assets/face01.png"
  face = texture.to_sprite
  face.anchor = :center
  face.set_position Bi.w/2, Bi.h/2

  # Action
  rot = Bi::Action::RotateBy.new(500, 90)
  move1 = Bi::Action::MoveTo.new(500, 0, 0)
  move2 = Bi::Action::MoveTo.new(500, Bi.w/2, Bi.h/2)
  seq = Bi::Action::Sequence.new( [rot,move1,move2]){|node,action| p [:sequence, node, action] }
  rep = Bi::Action::Repeat.new(seq){|node,action| p [:repeat, node, action] }
  face.add_action rep

  layer = Bi::Layer.new
  layer.root = Bi::Node.new
  layer.root.set_size Bi.w,Bi.h
  layer.root.set_color 0x33,0,0
  layer.root.add face
  layer.set_texture 0, texture
  Bi::add_layer layer
end

Bi::start_run_loop
