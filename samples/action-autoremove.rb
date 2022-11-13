class Bi::Node
  def actions
    @_actions
  end
end

Bi.init 480,320,title: __FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  layer = Bi::Layer.new
  texture = assets.texture "assets/face01.png"
  face = texture.to_sprite

  face.anchor = :center
  face.set_position Bi.w/2, Bi.h/2
  face.add_action Bi::Action::RotateBy.new(500, 360, autoremove:true)
  face.create_timer(1000,1){|t,dt| p face.actions }

  layer.root = Bi::Node.new
  layer.root.set_color 0x33,0,0
  layer.root.set_size Bi.w,Bi.h
  layer.root.add face
  layer.set_texture 0, texture

  Bi::add_layer layer
end

Bi::start_run_loop
