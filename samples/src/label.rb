
srand(Time.now.to_i)

Bi::init 480,320, title:__FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|

  root = Bi::Node.new
  root.set_size Bi.w, Bi.h

  texture = assets.texture "assets/mixed.png", false
  font = Bi::Font.new texture, assets.read("assets/large-bold.dat")

  label = Bi::Label.new font
  label.set_position Bi.w/2, Bi.h/2
  label.set_color 0,0xff,0xff,0xff
  label.anchor = :center
  label.scale_x = label.scale_y = 4.0
  label.add_timer(500,-1){|n,now,timer|
    label.set_text ["Label","12345","ABCDEF","(@o@)","('_`)","(^_^)",";->"].sample
    label.set_color 0xff-rand(50), 0xff-rand(50), 0xff-rand(50), 0xff
    label.set_background_color rand(100),rand(100),rand(100),0xff
  }
  root.add label

  # layer
  layer = Bi::Layer.new
  layer.root = root
  layer.set_texture 0, texture
  Bi::layers.add_layer layer

end

Bi::start_run_loop
