
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

  Bi::Sound.init 441000,2,1024
  sound = assets.sound "assets/sin-1sec-mono.wav"
  sound.play 1,-1

  @angle = 0
  face.create_timer(0,-1){|node,delta|
    @angle += 0.001*delta
    x = Math::sin(@angle) * Bi.w/2 + Bi.w/2
    face.x = x
    Bi::Sound.pan 1, 0xff-0xFF*x.to_f/Bi.w, 0xFF*x.to_f/Bi.w
  }
end

Bi::start_run_loop
