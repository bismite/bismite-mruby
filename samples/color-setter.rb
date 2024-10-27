
Bi.init 480,320,title:__FILE__,highdpi:false
Bi::Archive.new("assets.dat","abracadabra").load{|assets|
  rects = []
  3.times{|y| 5.times{|x|
    n = Bi::Node.xywh 30+x*90,200-y*90, 60,60
    rects << n
  }}
  # layer
  layer = Bi::Layer.new
  rects.each{|r| layer.add r }
  Bi::layers.add layer
  #
  rects[0].set_color Bi::Color.rgba(0xFF00FFFF) # Magenta
  rects[1].set_tint  Bi::Color.rgba(0xFF00FFFF) # Magenta
  rects[2].color = Bi::Color.rgba(0xFF0000FF) # Red
  rects[3].tint = Bi::Color.rgba(0xFF0000FF) # Red
  rects[4].color = 0x00FF00FF # Green
  rects[5].tint =  0x00FF00FF # Green
  rects[6].color = "0x0000FFFF" # Blue
  rects[7].tint  =  "#0000FFFF" # Blue
  rects[8].color = "0x00FFFF" # Cyan
  rects[9].tint =   "#00FFFF" # Cyan
  # Yellow
  rects[10].color.r = 0xFF
  rects[10].color.g = 0xFF
  rects[10].color.b = 0
  rects[10].color.a = 0xFF
  # Yellow
  rects[11].tint.r = 0xFF
  rects[11].tint.g = 0xFF
  rects[11].tint.b = 0
  rects[11].tint.a = 0xFF
  # Color=White, Tint=Blue(half)
  rects[12].tint  = 0x0000FFFF
  rects[12].tint.a = 0x80
  # White(half)
  rects[13].color = 0xFFFFFFFF
  rects[13].opacity = 0.5
  # Silver
  rects[13].tint = Bi::Color.silver
  # Transparent
  rects[14].color = Bi::Color.transparent
}
# start
Bi::start_run_loop
