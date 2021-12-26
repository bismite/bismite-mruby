Bi.init 480,320, title:__FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  root = Bi::Node.new
  root.set_size Bi.w, Bi.h
  root.set_color 0x33,0,0,0xff

  texture = assets.texture "assets/mixed.png"
  font = Bi::Font.new texture, assets.read("assets/small.dat")

  labels = 15.times.map{|i|
    label = Bi::Label.new font
    label.anchor = :south_east
    label.text = "Press any Key"
    label.set_position Bi.w - 10, 10 + i*20
    label.set_color 0xff, 0xff, 0xff, 0xff - i*10
    root.add label
    label
  }

  root.on_key_input{|node,scancode,keycode,mod,pressed|
    pressed = pressed ? "Press" : "Release"
    if mod == 0
      mod = "-"
    else
      mod = Bi::KeyMod.parse(mod).map{|k| Bi::KeyMod.name(k) }.join(",")
    end
    scancode_name = Bi::ScanCode.name scancode
    keycode_name =Bi::KeyCode.name keycode
    new_text = "Mod:#{mod} #{pressed} ScanCode:#{scancode_name}(#{scancode}) KeyCode:#{keycode_name}(#{keycode})"

    texts = labels.map{|l| l.text }
    texts.pop
    texts.unshift new_text

    labels.each.with_index{|l,i| l.text = texts[i] }
  }

  # layer
  layer = Bi::Layer.new
  layer.root = root
  layer.set_texture 0, texture
  Bi::add_layer layer
end

Bi::start_run_loop
