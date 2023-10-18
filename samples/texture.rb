
Bi.init 480,320,title:__FILE__,highdpi:false

# texture
bg_tex = Bi::Texture.new("assets/check.png")
face_tex = Bi::Texture.new("assets/face01.png")

# Sprite
face = face_tex.to_sprite
face.anchor = :center
face.set_position Bi.w/2,Bi.h/2

# layer
layer = Bi::Layer.new
layer.add bg_tex.to_sprite
layer.add face
layer.set_texture 0, bg_tex
layer.set_texture 1, face_tex
Bi::layers.add layer

# start
Bi::start_run_loop
