
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
      label.color = Bi::Color.black
      label.tint = 0xffff0080
      label.set_color_with_range 3,6, Bi::Color.rgb(0xff0000)
      label.set_tint_with_range 9,12, Bi::Color.rgb(0x00ff00)
      label.background_color = Bi::Color.white
      layer.add label,10, y*18
      y += 1
    }
  }
}

Bi::start_run_loop
