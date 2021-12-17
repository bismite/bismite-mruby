
Bi.init 480,320, title:__FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  face = assets.texture("assets/face01.png").to_sprite
  face.set_position Bi.w/2, Bi.h/2
  face.scale_x = face.scale_y = 2.0
  face.anchor = :center

  layer = Bi::Layer.new
  layer.root = assets.texture("assets/check.png").to_sprite
  layer.root.add face
  layer.set_texture 0, face.texture_mapping.texture
  layer.set_texture 1, layer.root.texture_mapping.texture
  Bi::add_layer layer

  Bi.layers.create_timer(0,-1){|node,dt| face.angle += dt*0.01 }
  face.create_timer(500,3){|node,dt| node.set_color rand(0xff),rand(0xff),rand(0xff),0xaa }
end

Bi::start_run_loop
