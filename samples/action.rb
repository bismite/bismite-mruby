
Bi.init 480,320,title: __FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  Bi::color = Bi::Color.new(0x33,0,0,0xff)
  texture = assets.texture "assets/face01.png"
  face = texture.to_sprite
  face.anchor = :center
  face.set_position Bi.w/2, Bi.h/2
  layer = Bi::Layer.new
  layer.add face
  layer.set_texture 0, texture
  Bi::layers.add layer
  # Action
  rot = Bi::Action::RotateBy.new(500, 90)
  move1 = Bi::Action::MoveTo.new(500, 0, 0)
  move2 = Bi::Action::MoveTo.new(500, Bi.w/2, Bi.h/2)
  fadeout = Bi::Action::FadeOut.new(500)
  fadein = Bi::Action::FadeIn.new(500)
  seq = Bi::Action::Sequence.new( [rot,move1,move2,fadeout,fadein], repeat:-1 ){|node,action|
    p [:sequence, node, action]
  }
  face.add_action seq
end

Bi::start_run_loop
