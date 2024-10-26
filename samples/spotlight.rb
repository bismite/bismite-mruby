
Bi::init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load{|assets|
  # textures
  mushroom_tex = assets.texture("assets/mushroom.png")
  bg_tex = assets.texture("assets/sky.png")
  circle_tex = assets.texture("assets/circle256.png")
  # sprite
  mushroom = mushroom_tex.to_sprite
  mushroom.scale = 3
  # 1st layer (shadowed sky)
  layer1 = Bi::Layer.new
  layer1.add bg_tex.to_sprite
  layer1.add mushroom,:center,:center
  layer1.set_texture 0, bg_tex
  layer1.set_texture 1, mushroom_tex
  shadow = Bi::Node.rect Bi.w,Bi.h
  shadow.set_color 0,0,0,128
  layer1.add shadow
  # 2nd layer (spotlight)
  layer2 = Bi::Layer.new
  spotlight = circle_tex.to_sprite
  spotlight.anchor = :center
  spotlight.create_timer(0,-1){|t,delta| spotlight.angle += 0.001*delta }
  layer2.add spotlight,:center,:center
  layer2.set_texture 0, circle_tex
  layer2.set_blend_factor GL_DST_COLOR, GL_ONE, GL_DST_COLOR, GL_ONE
  Bi::layers.add layer1
  Bi::layers.add layer2
}
Bi::start_run_loop
