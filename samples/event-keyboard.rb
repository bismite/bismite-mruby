
Bi.init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load{|assets|
  Bi.color = Bi::Color.new 0x33,0,0,0xff
  # texture
  texture = assets.texture "assets/font.png"
  # layer
  layer = Bi::Layer.new
  layer.set_texture 0, texture
  Bi::layers.add layer
  root = Bi::Node.new
  layer.add root
  # font and labels
  font = Bi::Font.new texture, assets.read("assets/font12.dat")
  labels = 15.times.map{|i|
    label = Bi::Label.new font
    label.anchor = :bottom_right
    label.set_color 0xff, 0xff, 0xff, (0xff*(1.0-i*0.05)).to_i
    label.text = "Press any Key"
    label.set_position Bi.w - 10, 10 + i*20
    root.add label
    label
  }
  # event handler
  root.on_key_input{|node,scancode,keycode,mod,pressed|
    pressed = pressed ? "Press" : "Release"
    if mod == 0
      mod = "-"
    else
      mod = Bi::KeyMod.parse(mod).map{|k| Bi::KeyMod.name(k) }.join(",")
    end
    scancode_name = Bi::ScanCode.name scancode
    keycode_name  = Bi::KeyCode.name keycode
    new_text = "Mod:#{mod} #{pressed} ScanCode:#{scancode_name}(#{scancode}) KeyCode:#{keycode_name}(#{keycode})"
    texts = labels.map{|l| l.text }
    texts.pop
    texts.unshift new_text
    labels.each.with_index{|l,i| l.text = texts[i] }
  }
}
Bi::start_run_loop
