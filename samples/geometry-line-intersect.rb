
class Line < Bi::Node
  attr_reader :line
  def initialize(x,y,x2,y2)
    super()
    self.angle = Math.atan2(y2-y, x2-x)
    self.set_size Math.sqrt( (x2-x)**2 + (y2-y)**2 ), 1
    self.set_position x,y
    @line = [x,y,x2,y2]
  end
  def hit?(x1,y1,x2,y2)
    if Bi::Line::intersection( x1, y1, x2, y2, *@line )
      self.color = Bi::Color.new(0xff,0,0,0xff)
    else
      self.color = Bi::Color.new(0xff,0xff,0xff,0xff)
    end
  end
end

class LineIntersection < Bi::Node
  R=200
  def initialize
    super()
    @line = Bi::Node.new
    @line.tint = Bi::Color.new(0,0xff,0,0xff)
    @line.set_size 32,32
    @line.anchor = :left
    @line.scale_y = 1.0 / @line.h
    @line.x = Bi.w/2
    @line.y = Bi.h/2
    self.add @line
    # lines
    @lines = 2000.times.map{
      x,y = *random_position(100,400)
      b = ::Line.new x, y, x+rand(-64..64), y+rand(-64..64)
      self.add b
      b
    }
    # rotate
    @sight_angle = 0
    self.create_timer(0,-1){|t,delta|
      @sight_angle += 0.0005*delta
      x = Bi.w/2 + R * Math::cos(@sight_angle)
      y = Bi.h/2 + R * Math::sin(@sight_angle)
      point(x,y)
    }
  end

  def point(x,y)
    lx = x - @line.x
    ly = y - @line.y
    @line.angle = Math.atan2(ly,lx)
    @line.scale_x = Math.sqrt( lx**2 + ly**2 ) / @line.w
    @lines.each{|line| line.hit?  @line.x, @line.y, x, y }
  end

  def random_position(near,far)
    angle = rand() * Math::PI*2
    distance = rand(near..far)
    x = (Bi.w/2 + distance * Math::cos(angle)).to_i
    y = (Bi.h/2 + distance * Math::sin(angle)).to_i
    return x,y
  end
end

Bi.init 480,320, title:__FILE__
Bi::Archive.load("assets.dat","abracadabra"){|assets|
  bg_tex = assets.texture("assets/sky.png")
  layer = Bi::Layer.new
  layer.set_texture 0, bg_tex
  layer.add bg_tex.to_sprite
  layer.add LineIntersection.new
  Bi::layers.add layer
}
Bi::start_run_loop
