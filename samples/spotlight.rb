
Bi::init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  # 1st layer (shadowed sky)
  layer1 = Bi::Layer.new
  layer1.root = assets.texture("assets/sky.png").to_sprite
  layer1.set_texture 0, layer1.root.texture_mapping.texture
  shadow = Bi::Node.new
  shadow.set_size Bi.w,Bi.h
  shadow.set_color 0,0,0,128
  layer1.root.add shadow

  # 2nd layer (spotlight)
  layer2 = Bi::Layer.new
  layer2.root = assets.texture("assets/circle256.png").to_sprite
  layer2.root.anchor = :center
  layer2.root.set_position Bi.w/2, Bi.h/2
  layer2.set_texture 0, layer2.root.texture_mapping.texture
  layer2.set_blend_factor GL_DST_COLOR, GL_ONE, GL_DST_COLOR, GL_ONE

  # spin
  layer2.root.create_timer(0,-1){|n,delta| n.angle += 0.001*delta }

  Bi::add_layer layer1
  Bi::add_layer layer2
end

Bi::start_run_loop
