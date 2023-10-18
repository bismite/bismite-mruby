
Bi.init 480,320, title:__FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  face = assets.texture("assets/face01.png").to_sprite
  bg = assets.texture("assets/check.png").to_sprite

  # sprite
  face.set_position Bi.w/2, Bi.h/2
  face.set_scale 2,2
  face.anchor = :center

  # layer
  layer = Bi::Layer.new
  layer.add bg
  layer.add face
  layer.set_texture 0, face.texture
  layer.set_texture 1, bg.texture
  Bi::layers.add layer

  timer_rotate = Bi.layers.create_timer(0,-1){|timer,dt| face.angle += dt*0.01 }
  face.create_timer(500,5){|timer,dt|
    face.tint = Bi::Color.new(rand(0xff),rand(0xff),rand(0xff),0xff)
  }

  bg.on_click {|n,x,y,button,press|
    Bi.layers.remove_timer timer_rotate if timer_rotate
    timer_rotate = nil
  }
end

Bi::start_run_loop
