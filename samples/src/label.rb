
srand(Time.now.to_i)

Bi::init 480,320, title:__FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  layer = Bi::Layer.new
  layer.root = Bi::Node.new
  Bi::layers.add_layer layer
  texture = assets.texture "assets/mixed.png", false
  layer.set_texture 0, texture

  fonts = [
    Bi::Font.new(texture,assets.read("assets/large.dat")),
    Bi::Font.new(texture,assets.read("assets/large-bold.dat")),
    Bi::Font.new(texture,assets.read("assets/small.dat")),
    Bi::Font.new(texture,assets.read("assets/small-bold.dat")),
  ]

  texts = [
    "The quick brown fox jumps over the lazy dog",
    "いろはにほへと　ちりぬるを　わかよたれそ　つねならむ",
    "カタカナと、Alphabetと、ひらがな。",
  ]

  y = 1
  texts.each{|text|
    fonts.each{|font|
      label = Bi::Label.new font
      label.set_text text
      label.set_position 10, y*20
      label.set_color 0xff-rand(50), 0xff-rand(50), 0xff-rand(50), 0xff
      label.set_background_color rand(100),rand(100),rand(100),0xff
      layer.root.add label
      y += 1
    }
  }
end

Bi::start_run_loop
