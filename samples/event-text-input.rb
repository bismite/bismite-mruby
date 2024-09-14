
Bi.init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load{|assets|
  Bi.color = Bi::Color.new(0x33,0,0,0xff)
  # texture
  font_tex = assets.texture "assets/font.png"
  # Labels
  root = Bi::Node.new
  font = Bi::Font.new font_tex, assets.read("assets/font14.dat")
  labels = 15.times.map{|i|
    label = Bi::Label.new font
    label.anchor = :bottom_right
    label.text = "Press any Key"
    label.set_position Bi.w - 10, 10 + i*20
    root.add label
    label
  }
  # event handler
  root.on_text_input{|node,text|
    new_text = text
    texts = labels.map{|l| l.text }
    texts.pop
    texts.unshift new_text
    labels.each.with_index{|l,i|
      l.text = texts[i]
    }
  }
  # layer
  layer = Bi::Layer.new
  layer.add root
  layer.set_texture 0, font_tex
  Bi::layers.add layer
}
Bi::start_run_loop