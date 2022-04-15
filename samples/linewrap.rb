
srand(Time.now.to_i)

Bi::init 480,320, title:__FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  layer = Bi::Layer.new
  layer.root = Bi::Node.new
  Bi::layers.add_layer layer
  texture = assets.texture "assets/font.png", false
  layer.set_texture 0, texture

  font = Bi::Font.new(texture,assets.read("assets/font14b.dat"))
  text = "The quick brown fox jumps over the lazy dog. 0123456789 !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~ いろはにほへと　ちりぬるを　わかよたれそ　つねならむ カタカナと、Alphabetと、ひらがな。"

  col = Bi::Node.new
  col.set_position 40,0
  col.set_size 200,Bi.h
  col.set_color 0,0x33,0x11
  layer.root.add col

  line_height =14
  y=Bi.h-line_height
  loop do
    at = font.line_x_to_index(text,col.w)
    break if at<=0
    str = text.slice!(0...at)

    label = Bi::Label.new font
    label.set_text str
    label.set_position 0, y
    col.add label
    y -= line_height
  end
end

Bi::start_run_loop
