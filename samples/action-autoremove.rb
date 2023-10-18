class Bi::Node
  def actions
    @_actions
  end
end

Bi.init 480,320,title: __FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  Bi::color = Bi::Color.new(0x33,0,0,0xff)
  layer = Bi::Layer.new
  texture = assets.texture "assets/face01.png"
  face = texture.to_sprite
  face.anchor = :center
  face.set_position Bi.w/2, Bi.h/2
  face.add_action Bi::Action::RotateBy.new(500, 360, autoremove:true)
  face.create_timer(1000,1){|t,dt| p face.actions }
  layer.add face
  layer.set_texture 0, texture
  Bi::layers.add layer
end
Bi::start_run_loop
