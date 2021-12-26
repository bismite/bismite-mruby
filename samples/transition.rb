
if Bi::Version.emscripten
  SHADER_HEADER="#version 100\nprecision highp float;\n"
else
  SHADER_HEADER="#version 120\n"
end

TRANSITION_DURATION = 500

# start
Bi.init 480,320,title:__FILE__,highdpi:true

$assets = nil
$shader = nil

def transition(&block)
  transition1 = Bi::Transition.new(Bi::layers,TRANSITION_DURATION,$shader,false,proc{|t1|
    p :transition1
    block.call
    transition2 = Bi::Transition.new(Bi::layers,TRANSITION_DURATION,$shader,true,proc{|t2|
      p :transition2
    })
    Bi::transition_start transition2
  })
  Bi::transition_start transition1
end

def scene_b
  # layer
  layer = Bi::Layer.new
  layer.root = $assets.texture("assets/sky.png").to_sprite
  Bi::add_layer layer

  # texture
  face = $assets.texture("assets/face01.png").to_sprite
  face.set_position Bi.w/2,Bi.h/2
  face.scale_x = face.scale_y = 2.0
  face.anchor = :center
  layer.root.add face

  layer.set_texture 0, layer.root.texture_mapping.texture
  layer.set_texture 1, face.texture_mapping.texture

  layer.root.on_click {|n,x,y,button,press|
    next if press
    transition{
      Bi::remove_layer layer
      scene_a
      sleep 0.5
    }
  }
end

def scene_a
  # layer
  layer = Bi::Layer.new
  layer.root = $assets.texture("assets/check.png").to_sprite
  Bi::add_layer layer

  # texture
  face = $assets.texture("assets/face01.png").to_sprite
  face.set_position Bi.w/2,Bi.h/2
  face.scale_x = face.scale_y = 2.0
  face.anchor = :center
  layer.root.add face

  layer.set_texture 0, layer.root.texture_mapping.texture
  layer.set_texture 1, face.texture_mapping.texture

  layer.root.on_click {|n,x,y,button,press|
    next if press
    transition{
      Bi::remove_layer layer
      scene_b
      sleep 0.5
    }
  }
end

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  $assets = assets
  shader_vert = SHADER_HEADER + $assets.read("assets/shaders/default.vert")
  shader_frag = SHADER_HEADER + $assets.read("assets/shaders/transition.frag")
  $shader = Bi::Shader.new shader_vert,shader_frag
  scene_a
end

Bi::start_run_loop
