begin

Bi.init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|

  root = Bi::Node.new
  root.set_size Bi.w, Bi.h
  root.set_color 0x33,0,0,0xff

  layer = Bi::Layer.new
  layer.root = root
  Bi::add_layer layer

  Bi::Sound.init 441000,2,1024
  music = assets.music "assets/Goldberg Variations, BWV. 988 - Variation 4.mp3"
  music.play -1

end

Bi::start_run_loop

rescue => e
  p e
end
