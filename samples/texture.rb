
Bi.init 480,320,title:__FILE__,highdpi:false

# texture
bg_tex = Bi::Texture.new("assets/check.png")
face_tex = Bi::Texture.new("assets/face01.png")

# Sprite
background = bg_tex.to_sprite
face = face_tex.to_sprite
background.add face,:center,:center

# layer
layer = Bi::Layer.new
layer.add background
layer.set_texture 0, bg_tex
layer.set_texture 1, face_tex
Bi::layers.add layer

# start
Bi::start_run_loop
