
srand(Time.now.to_i)

Bi::init 480,320, title:__FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  layer = Bi::Layer.new
  layer.root = Bi::Node.new
  Bi::layers.add_layer layer
  texture = assets.texture "assets/font.png", false
  layer.set_texture 0, texture

  fonts = [
    Bi::Font.new(texture,assets.read("assets/font14b.dat")),
    Bi::Font.new(texture,assets.read("assets/font14.dat")),
    Bi::Font.new(texture,assets.read("assets/font12b.dat")),
    Bi::Font.new(texture,assets.read("assets/font12.dat")),
  ]

  texts = [
    "0123456789 !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~",
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
      label.set_color 0xff-rand(50), 0xff-rand(50), 0xff-rand(50)
      label.set_text_color_with_range 3,6, 0xff,0,0
      label.set_background_color rand(100),rand(100),rand(100)
      layer.root.add label
      y += 1
    }
  }
end

Bi::start_run_loop
