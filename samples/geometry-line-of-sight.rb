
class Block < Bi::Node
  attr_reader :sides, :corners
  def initialize(x,y,w,h)
    super()
    self.set_size w,h
    self.set_position x,y
    l = x
    r = x + w-1
    b = y
    t = y + h-1
    # left, right, top, bottom
    @sides = [
      [l,t,l,b], [r,t,r,b], [l,t,r,t], [l,b,r,b],
    ]
    # left-top, left-bottom, right-top, right-bottom
    @corners = [
      [l,t], [l,b], [r,t], [r,b]
    ]
  end
end

class LineOfSight < Bi::Node
  def initialize(ball_texture)
    super()
    @line = Bi::Node.new
    @line.color = Bi::Color.new(0xff,0xff,0xff,0xff)
    @line.set_size 32,32
    @line.anchor = :left
    @line.scale_y = 1.0 / @line.h
    @line.x = Bi.w/2
    @line.y = Bi.h/2
    self.add @line

    @ball = ball_texture.to_sprite
    @ball.anchor = :center
    @ball.color = Bi::Color.new(0,0xff,0,0xff)
    self.add @ball

    reset_blocks

    self.on_key_input do |node,key,code,mod,pressed|
      next if pressed
      reset_blocks
    end

    @sight_angle = 0
    self.create_timer(0,-1){|t,delta|
      @sight_angle += 0.0005*delta
      distance = Bi.h
      x = Bi.w/2 + distance * Math::cos(@sight_angle)
      y = Bi.h/2 + distance * Math::sin(@sight_angle)
      point(x,y)
    }
  end

  def reset_blocks
    if @blocks
      @blocks.each{|b| b.remove_from_parent }
    end
    @blocks = 50.times.map do
      angle = rand() * Math::PI*2
      distance = rand(100..300)
      x = Bi.w/2 + distance * Math::cos(angle)
      y = Bi.h/2 + distance * Math::sin(angle)
      b = Block.new x,y,rand(32..64), rand(32..64)
      b.color = Bi::Color.new(0xff,0xff,0xff,0xff)
      b.color.a = 128
      self.add b
      b
    end
  end

  def point(x,y)
    lx = x - @line.x
    ly = y - @line.y
    @line.angle = Math.atan2(ly,lx)
    @line.scale_x = Math.sqrt( lx**2 + ly**2 ) / @line.w

    sx = @line.x
    sy = @line.y

    @ball.visible = false

    intersection = nil
    collide_block = nil

    @blocks.each{|block|
      block.color = Bi::Color.new(0xff,0xff,0xff,64)
      blocks = block.sides.to_a + block.corners.to_a
      nearest = Bi::Line::nearest_intersection(@line.x, @line.y, x, y, blocks)

      if nearest
        block.color = Bi::Color.new(0xff,0xff,0,64)
        if intersection
          if Bi::Line::compare_length(@line.x,@line.y, intersection[0], intersection[1],
                                      @line.x, @line.y, nearest[0], nearest[1] ) > 0
            intersection = nearest
            collide_block = block
          end
        else
          intersection = nearest
          collide_block = block
        end
      end
    }

    if intersection and collide_block
      collide_block.color = Bi::Color.new(0xff,0,0,64)
      @ball.set_position(*intersection)
      @ball.visible = true
    end

  end

end

Bi.init 480,320, title:__FILE__
Bi::Archive.load("assets.dat","abracadabra"){|assets|
  srand(Time.now.to_i)
  layer = Bi::Layer.new
  sky_texture = assets.texture "assets/sky.png"
  ball_texture = assets.texture "assets/ball.png"
  layer.set_texture 0, sky_texture
  layer.set_texture 1, ball_texture
  sky = sky_texture.to_sprite
  p sky.color.r
  p sky.tint.r
  layer.add sky
  layer.add LineOfSight.new(ball_texture)
  Bi::layers.add layer
}
Bi::start_run_loop
