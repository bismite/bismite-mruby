Bi::init 480,320, title:__FILE__
Bi::Archive.load("assets.dat","abracadabra"){|assets|
  layer = Bi::Layer.new
  Bi::layers.add layer
  font_tex = assets.texture "assets/font.png", false
  layer.set_texture 0, font_tex
  # Fonts
  fonts = [
    Bi::Font.new(font_tex,assets.read("assets/font14b.dat")),
    Bi::Font.new(font_tex,assets.read("assets/font14.dat")),
    Bi::Font.new(font_tex,assets.read("assets/font12b.dat")),
    Bi::Font.new(font_tex,assets.read("assets/font12.dat")),
  ]
  # Labels
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
      label.set_position 10, y*18
      label.color = Bi::Color.new(0, 0, 0, 128)
      label.tint = Bi::Color.new(0, 0, 0xff, 128)
      label.set_color_with_range 3,6, Bi::Color.new(0xff,0,0,0xff)
      label.set_tint_with_range 9,12, Bi::Color.new(0,0xff,0,0xff)
      label.background_color = Bi::Color.new(0xff,0xff,0xff,0xff)
      layer.add label
      y += 1
    }
  }
}

Bi::start_run_loop
