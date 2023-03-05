
Bi.init 480,320,title:__FILE__,highdpi:false

# layer
layer = Bi::Layer.new
layer.root = Bi::Texture.new("assets/check.png").to_sprite
Bi::add_layer layer

# texture
tex = Bi::Texture.new("assets/face01.png")

# Sprite
face = tex.to_sprite
face.set_position Bi.w/2,Bi.h/2
face.anchor = :center
layer.root.add face

layer.set_texture 0, layer.root.texture
layer.set_texture 1, tex

Bi::start_run_loop
