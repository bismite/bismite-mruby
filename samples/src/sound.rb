Bi.init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|

  root = Bi::Node.new
  root.set_size Bi.w, Bi.h
  root.set_color 0x33,0,0,0xff

  layer = Bi::Layer.new
  layer.root = root
  Bi::add_layer layer

  Bi::Sound.init 441000,2,1024
  sound = assets.sound "assets/sin-1sec-mono.wav"
  sound.play 1,-1

  root.on_move_cursor {|n,x,y|
    Bi::Sound.pan 1, 0xff-0xFF*x.to_f/Bi.w, 0xFF*x.to_f/Bi.w
  }
end

Bi::start_run_loop
