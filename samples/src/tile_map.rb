class TileMapLayer < Bi::Layer
  include Singleton
end

class TileMap < Bi::Node

  TILE_SIZE = 16

  class Grid
    attr_accessor :type, :variation
    def initialize(type,variation)
      @type = type
      @variation = variation
    end
  end

  def make_dungeon
    @grid_width = 64
    @grid_height = 64
    birth = [5,6,7,8]
    death = [0,1,2,3]

    srand(Time.now.to_i)

    grid = (@grid_width*@grid_height).times.map{ rand(100)<50?0:1 }
    @grid_width.times{|x| grid[0+x] = grid[(@grid_height-1)*@grid_width+x] = 0 }
    @grid_height.times{|y| grid[@grid_width*y+0] = grid[@grid_width*y+@grid_width-1] = 0 }

    rand(8..12).times do
      grid = CellularAutomaton.step(grid,@grid_width,birth,death,true)
      @grid_width.times{|x| grid[0+x] = grid[(@grid_height-1)*@grid_width+x] = 0 }
      @grid_height.times{|y| grid[@grid_width*y+0] = grid[@grid_width*y+@grid_width-1] = 0 }
    end

    @grid = grid.map{|g|
      Grid.new( g==0 ? :wall : :floor, rand(3) )
    }
  end

  def initialize(wall,floor)
    super
    w = Bi.w
    h = Bi.h
    # self.scale_x = self.scale_y = 0.5
    self.set_position 0,0
    self.set_size w,h
    t = self.add_timer(1000,-1){|n,now,timer| Bi::title = "FPS:#{Bi::profile.fps}" }

    @tiles = {
      wall: 3.times.map{|i| Bi::TextureMapping.new(wall,i*TILE_SIZE,0,TILE_SIZE,TILE_SIZE) },
      floor: 3.times.map{|i| Bi::TextureMapping.new(floor,i*TILE_SIZE,0,TILE_SIZE,TILE_SIZE) }
    }

    make_dungeon

    @nodes = @grid_width.times.map{|x|
      @grid_height.times.map{|y|
        g = @grid[y*@grid_width+x]
        n = Bi::Sprite.new @tiles[g.type][g.variation]
        n.set_position x*TILE_SIZE, y*TILE_SIZE
        self.add n
        n
      }
    }.flatten

    self.on_key_input{|n,scancode,keycode,mod,pressed|
      next unless pressed
      case keycode
      when Bi::KeyCode::LEFT
        TileMapLayer.instance.camera_x -= TILE_SIZE
      when Bi::KeyCode::RIGHT
        TileMapLayer.instance.camera_x += TILE_SIZE
      when Bi::KeyCode::UP
        TileMapLayer.instance.camera_y += TILE_SIZE
      when Bi::KeyCode::DOWN
        TileMapLayer.instance.camera_y -= TILE_SIZE
      end
    }

  end

end


Bi.init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  layer = TileMapLayer.instance
  wall = assets.texture "assets/wall16.png"
  floor = assets.texture "assets/floor16.png"
  layer.root = TileMap.new(wall,floor)
  layer.set_texture 0, wall
  layer.set_texture 1, floor
  Bi::add_layer layer
end
Bi.start_run_loop
