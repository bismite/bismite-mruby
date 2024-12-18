
Bi.init 480,320, title:__FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  face = assets.texture("assets/face01.png").to_sprite
  bg = assets.texture("assets/check.png").to_sprite

  # sprite
  face.set_position Bi.w/2, Bi.h/2
  face.set_scale 2,2
  face.anchor = :center

  shader_node = Bi::ShaderNode.new
  shader_node.add bg
  shader_node.add face
  shader_node.set_texture 0, face.texture
  shader_node.set_texture 1, bg.texture
  Bi.add shader_node
  # show timers
  face.create_timer(2000,-1){|timer,dt|
    p timer.node.timers
  }
  # autoremove
  face.create_timer(500,5){|timer,dt|
    timer.node.tint = Bi::Color.new(rand(0xff),rand(0xff),rand(0xff),0xff)
  }
  # remove on click
  timer_rotate = face.create_timer(0,-1){|timer,dt|
    timer.node.angle += dt*0.01
  }
  face.on_click {|node,x,y,button,press|
    node.remove_timer timer_rotate if timer_rotate
    timer_rotate = nil
  }
end

Bi::start_run_loop
