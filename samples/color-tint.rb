
def newmushroom(tex)
  mushroom = tex.to_sprite
  mushroom.scale = 2
  return mushroom
end

Bi.init 480,320,title:__FILE__,highdpi:false
Bi::Archive.new("assets.dat","abracadabra").load{|assets|
  # texture
  bg_tex = assets.texture("assets/map.png")
  mush_tex = assets.texture("assets/mushroom.png")

  shader_node = Bi::ShaderNode.new
  shader_node.add bg_tex.to_sprite
  shader_node.set_texture 0, bg_tex
  shader_node.set_texture 1, mush_tex
  Bi.add shader_node
  # Color(Modulate)
  [0xFF0000FF,0x00FF00FF,0x0000FFFF,0x000000FF].each_with_index{|color,x|
    mushroom = newmushroom(mush_tex)
    mushroom.color = color
    shader_node.add mushroom,20+x*100,200
  }
  # Tint
  [0xFF000066,0x00FF0066,0x0000FF66,0xFFFFFFFF].each_with_index{|color,x|
    mushroom = newmushroom(mush_tex)
    mushroom.tint = color
    shader_node.add mushroom,20+x*100,20
  }
  # Transparent
  mushroom = newmushroom(mush_tex)
  mushroom.opacity = 0.5
  mushroom.anchor = :center
  shader_node.add mushroom,Bi.w/2, Bi.h/2
}
# start
Bi::start_run_loop
