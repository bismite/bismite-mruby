
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
  # layer
  layer = Bi::Layer.new
  layer.add bg_tex.to_sprite
  layer.set_texture 0, bg_tex
  layer.set_texture 1, mush_tex
  Bi::layers.add layer
  # Modulate
  [0xFF0000FF,0x00FF00FF,0x0000FFFF,0x000000FF].each_with_index{|color,x|
    mushroom = newmushroom(mush_tex)
    mushroom.color = Bi::Color.rgba32(color)
    layer.add mushroom,20+x*100,200
  }
  # Tint
  [0xFF000066,0x00FF0066,0x0000FF66,0xFFFFFFFF].each_with_index{|color,x|
    mushroom = newmushroom(mush_tex)
    mushroom.tint = Bi::Color.rgba32(color)
    layer.add mushroom,20+x*100,20
  }
  # Transparent
  mushroom = newmushroom(mush_tex)
  mushroom.color = Bi::Color.rgba32(0xffffff33)
  mushroom.anchor = :center
  layer.add mushroom,Bi.w/2, Bi.h/2
}
# start
Bi::start_run_loop
