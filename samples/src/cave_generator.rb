
class Fiber
  def self.sleep(sec)
    t = Time.now
    self.yield while Time.now - t < sec
  end
end

class CaveGeneratorExample < Bi::Node
  WALL=[0x18,0x01,0x0d,0xFF]
  FLOOR=[0x64,0x4d,0x37,0xFF]

  def initialize(w,h)
    super
    self.set_position 0,0
    self.set_size w,h

    srand(Time.now.to_i)

    birth = [5,6,7,8]
    death = [0,1,2,3]
    grid_width = (w/4).to_i
    grid_height = (h/4).to_i
    # step = rand(6..14)
    step = 10
    p [:step, step, :w, grid_width, :h, grid_height ]

    @grid = (grid_width*grid_height).times.map{ rand(100)<50?0:1 }
    border grid_width, grid_height

    @nodes = grid_height.times.map{|y| grid_width.times.map{|x|
      n = Bi::Node.new
      n.set_position x*4,y*4
      n.set_size 4,4
      add n
      n
    }}.flatten

    update_grids

    f = Fiber.new do
      Fiber.sleep 2.0
      step.times do |i|
        p [Time.now, :step, i]
        @grid = CellularAutomaton.step(@grid,grid_width,birth,death,true)
        border grid_width, grid_height
        self.update_grids
        Fiber.sleep 0.5
      end
      true
    end

    self.on_update{|node,delta| f = nil if f and f.resume }

  end

  def border(w,h)
    w.times{|x| @grid[x] = @grid[(h-1)*w+x] = 0 }
    h.times{|y| @grid[w*y] = @grid[w*y+w-1] = 0 }
  end

  def update_grids
    @grid.each.with_index{|g,i|
      if g == 0
        @nodes[i].set_color(*WALL)
      else
        @nodes[i].set_color(*FLOOR)
      end
    }
  end

end

Bi.init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  layer = Bi::Layer.new
  node = CaveGeneratorExample.new(Bi.w,Bi.h)
  root = Bi::Node.new
  root.add node
  node.x = Bi.w - node.w
  layer.root = root
  Bi::add_layer layer
end
Bi.start_run_loop
