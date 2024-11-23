
Bi::init 480,320, title:__FILE__, highdpi:true
Bi::Archive.new("assets.dat","abracadabra").load do |assets|

  shader_node = Bi::ShaderNode.new
  Bi.add shader_node
  texture = assets.texture "assets/font.png", false
  shader_node.set_texture 0, texture
  # font and text
  font = Bi::Font.new(texture,assets.read("assets/font14b.dat"))
  text = [
    "The quick brown fox jumps over the lazy dog.",
    "0123456789",
    "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~",
    "いろはにほへと　ちりぬるを　わかよたれそ　つねならむ",
    "カタカナと、Alphabetと、ひらがな。"
  ].join(" ")
  # column
  col = Bi::Node.xywh 40,0,200,Bi.h
  col.color = 0x003311FF
  shader_node.add col
  # labels
  line_height =14
  y=Bi.h-line_height
  loop do
    # calculate
    at = font.line_x_to_index(text,col.w)
    break if at<=0
    str = text.slice!(0...at)
    # add label
    label = Bi::Label.new font
    label.set_text str
    label.set_position 0, y
    col.add label
    y -= line_height
  end
end

Bi::start_run_loop
