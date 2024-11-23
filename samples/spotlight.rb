
Bi::init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load{|assets|
  # Sprites
  mushroom = assets.texture("assets/mushroom.png").to_sprite
  mushroom.scale = 3
  mushroom.anchor = :center
  bg = assets.texture("assets/sky.png").to_sprite
  spotlight = assets.texture("assets/circle256.png").to_sprite
  spotlight.anchor = :center

  # 1st (shadowed sky)
  layer1 = Bi::ShaderNode.new
  layer1.add bg
  layer1.add mushroom,Bi.w/2,Bi.h/2
  layer1.set_texture 0, bg.texture
  layer1.set_texture 1, mushroom.texture
  shadow = Bi::Node.rect Bi.w,Bi.h
  shadow.color = 0x00000080
  layer1.add shadow
  # 2nd (spotlight)
  layer2 = Bi::ShaderNode.new
  spotlight.create_timer(0,-1){|t,delta| spotlight.angle += 0.001*delta }
  layer2.add spotlight,Bi.w/2,Bi.h/2
  layer2.set_texture 0, spotlight.texture
  layer2.set_blend_factor GL_DST_COLOR, GL_ONE, GL_DST_COLOR, GL_ONE
  Bi.add layer1
  Bi.add layer2
}
Bi::start_run_loop
