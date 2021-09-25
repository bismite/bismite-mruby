Bi.init 480,320,title:__FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  # layer
  layer = Bi::Layer.new
  layer.root = Bi::Node.new
  layer.root.set_color 0x33,0x33,0x33,0xff
  layer.root.set_size Bi.w,Bi.h
  Bi::add_layer layer

  texture = assets.texture("assets/face01.png")

  # A: red
  face_a = texture.to_sprite
  face_a.set_position Bi.w/2,Bi.h/2
  face_a.anchor = :center
  face_a.set_color 0xFF,0,0,0xFF
  face_a.z = 1 # High order

  # B: blue
  face_b = texture.to_sprite
  face_b.set_position Bi.w/2+50,Bi.h/2+50
  face_b.anchor = :center
  face_b.set_color 0,0,0xFF,0xFF
  face_b.z = 0 # Low order

  layer.root.on_click{|n,x,y,button,pressed|
    if pressed
      tmp = face_a.z
      face_a.z = face_b.z
      face_b.z = tmp
    end
  }

  layer.set_texture 0, texture
  layer.root.add face_a #
  layer.root.add face_b # B after A
end

Bi::start_run_loop
