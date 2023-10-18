
def newmushroom(tex,x,y)
  mushroom = tex.to_sprite
  mushroom.scale = 2
  mushroom.set_position x,y
  return mushroom
end

Bi.init 480,320,title:__FILE__,highdpi:false
Bi::Archive.new("assets.dat","abracadabra").load{|assets|
  # texture
  bg_tex = Bi::Texture.new("assets/map.png")
  mush_tex = Bi::Texture.new("assets/mushroom.png")
  # layer
  layer = Bi::Layer.new
  layer.add bg_tex.to_sprite
  layer.set_texture 0, bg_tex
  layer.set_texture 1, mush_tex
  Bi::layers.add layer
  # Modulate
  [0xFF0000FF,0x00FF00FF,0x0000FFFF,0x000000FF].each_with_index{|color,x|
    mushroom = newmushroom(mush_tex,20+x*100,200)
    mushroom.color = Bi::Color.rgba32(color)
    layer.add mushroom
  }
  # Tint
  [0xFF000066,0x00FF0066,0x0000FF66,0xFFFFFFFF].each_with_index{|color,x|
    mushroom = newmushroom(mush_tex,20+x*100,20)
    mushroom.tint = Bi::Color.rgba32(color)
    layer.add mushroom
  }
  # Transparent
  mushroom = newmushroom(mush_tex,Bi.w/2, Bi.h/2)
  mushroom.color = Bi::Color.rgba32(0xffffff33)
  mushroom.anchor = :center
  layer.add mushroom
}
# start
Bi::start_run_loop
