
Bi.init 480,320,title:__FILE__,highdpi:true

# texture
bg_tex = Bi::Texture.new("assets/check.png")
face_tex = Bi::Texture.new("assets/face01.png")

# Sprite
background = bg_tex.to_sprite
face = face_tex.to_sprite
background.add face,:center,:center

# Shader Node
snode = Bi::ShaderNode.new
snode.add background
snode.set_texture 0, bg_tex
snode.set_texture 1, face_tex
Bi::default_framebuffer_node.add snode

# start
Bi::start_run_loop
