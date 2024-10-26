
class CaveGenerator < Bi::Node
  WALL_COLOR  = Bi::Color.new(0x18,0x01,0x0d,0xfF)
  FLOOR_COLOR = Bi::Color.new(0x64,0x4d,0x37,0xfF)
  GRID_SIZE = 4
  STEP_MAX = 10
  BIRTH = [5,6,7,8]
  DEATH = [0,1,2,3]

  def initialize(w,h)
    super()
    grid_width = (w/GRID_SIZE).to_i
    grid_height = (h/GRID_SIZE).to_i
    @step = 0
    @grid = (grid_width*grid_height).times.map{ rand(100)<50?0:1 }
    self.border grid_width, grid_height
    @nodes = grid_height.times.map{|y| grid_width.times.map{|x|
      add Bi::Node.xywh x*4,y*4,4,4
    }}.flatten
    self.update_grids
    self.create_timer(500,-1){|t,delta|
      if @step < STEP_MAX
        @step += 1
        @grid = CellularAutomaton.step(@grid,grid_width,BIRTH,DEATH,true)
        border grid_width, grid_height
        self.update_grids
      end
    }
  end

  def border(w,h)
    w.times{|x| @grid[x] = @grid[(h-1)*w+x] = 0 }
    h.times{|y| @grid[w*y] = @grid[w*y+w-1] = 0 }
  end

  def update_grids
    @grid.each.with_index{|g,i|
      @nodes[i].color = g==0 ? WALL_COLOR : FLOOR_COLOR
    }
  end
end

Bi.init 480,320, title:__FILE__
Bi::Archive.load("assets.dat","abracadabra"){|assets|
  srand(Time.now.to_i)
  layer = Bi::Layer.new
  layer.add CaveGenerator.new(Bi.w,Bi.h)
  Bi::layers.add layer
}
Bi.start_run_loop
