
Bi::init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  # 1st layer (shadowed sky)
  layer1 = Bi::Layer.new
  layer1.root = assets.texture("assets/sky.png").to_sprite
  layer1.set_texture 0, layer1.root.texture
  shadow = Bi::Node.new
  shadow.set_size Bi.w,Bi.h
  shadow.set_color 0,0,0,128
  layer1.root.add shadow

  # 2nd layer (spotlight)
  layer2 = Bi::Layer.new
  spotlight = assets.texture("assets/circle256.png").to_sprite
  spotlight.anchor = :center
  spotlight.set_position Bi.w/2, Bi.h/2
  spotlight.create_timer(0,-1){|t,delta| spotlight.angle += 0.001*delta }

  layer2.root = spotlight
  layer2.set_texture 0, spotlight.texture
  layer2.set_blend_factor GL_DST_COLOR, GL_ONE, GL_DST_COLOR, GL_ONE
  Bi::add_layer layer1
  Bi::add_layer layer2
end

Bi::start_run_loop
