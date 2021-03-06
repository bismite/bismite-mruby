Bi.init 480,320, title:__FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  root = Bi::Node.new
  root.set_size Bi.w, Bi.h
  root.set_color 0x33,0,0

  texture = assets.texture "assets/font.png"
  font = Bi::Font.new texture, assets.read("assets/font14.dat")

  labels = 15.times.map{|i|
    label = Bi::Label.new font
    label.anchor = :south_east
    label.text = "Press any Key"
    label.set_position Bi.w - 10, 10 + i*20
    label.set_color 0xff, 0xff, 0xff, 0xff, 1.0 - i*0.05
    root.add label
    label
  }

  root.on_text_input{|node,text|
    new_text = text

    texts = labels.map{|l| l.text }
    texts.pop
    texts.unshift new_text

    labels.each.with_index{|l,i|
      l.text = texts[i]
      l.set_color 0xff, 0xff, 0xff, 0xff, 1.0 - i*0.05
    }
  }

  # layer
  layer = Bi::Layer.new
  layer.root = root
  layer.set_texture 0, texture
  Bi::add_layer layer
end

Bi::start_run_loop
