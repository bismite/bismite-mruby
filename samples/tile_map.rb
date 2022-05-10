
srand(Time.now.to_i)
TILE_SIZE = 16

Bi.init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  layer = Bi::Layer.new
  wall = assets.texture "assets/wall16.png"
  floor = assets.texture "assets/floor16.png"
  layer.root = Bi::Node.new
  layer.set_texture 0, wall
  layer.set_texture 1, floor

  @tiles = 3.times.map{|i| [wall, [i*TILE_SIZE,0,TILE_SIZE,TILE_SIZE] ] }
  @tiles+= 3.times.map{|i| [floor, [i*TILE_SIZE,0,TILE_SIZE,TILE_SIZE] ] }

  w = (Bi.w/TILE_SIZE).to_i
  h = (Bi.h/TILE_SIZE).to_i
  w.times{|x| h.times{|y|
    tile = @tiles.sample
    tile = tile.first.to_sprite(*tile.last)
    layer.root.add tile
    tile.x = x*TILE_SIZE
    tile.y = y*TILE_SIZE
  }}

  Bi::add_layer layer
end
Bi.start_run_loop
