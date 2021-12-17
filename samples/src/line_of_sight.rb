
class Block < Bi::Node
  attr_reader :sides, :corners
  def initialize(x,y,w,h)
    super
    self.set_size w,h
    self.set_position x,y

    l = x
    r = x + w-1
    b = y
    t = y + h-1

    @sides = [
      [l,t,l,b], # left
      [r,t,r,b], # right
      [l,t,r,t], # top
      [l,b,r,b], # bottom
    ]

    @corners = [
      [l,t],
      [l,b],
      [r,t],
      [r,b]
    ]
  end
end

class LineOfSightLayer < Bi::Layer
  def initialize(assets)
    super
    sky_texture = assets.texture "assets/sky.png"
    ball_texture = assets.texture "assets/ball.png"
    self.set_texture 0, sky_texture
    self.set_texture 1, ball_texture
    self.root = LineOfSight.new(sky_texture,ball_texture)
  end
end

class LineOfSight < Bi::Node

  def initialize(sky_texture,ball_texture)
    super

    self.set_size Bi.w, Bi.h

    @sky = sky_texture.to_sprite
    @sky.scale_x = Bi.w.to_f / @sky.w
    @sky.scale_y = Bi.h.to_f / @sky.h
    self.add @sky

    @line = Bi::Node.new
    @line.set_color 0xff,0xff,0xff,0xff
    @line.set_size 32,32
    @line.anchor = :west
    @line.scale_y = 1.0 / @line.h
    @line.x = Bi.w/2
    @line.y = Bi.h/2
    self.add @line

    @ball = ball_texture.to_sprite
    @ball.anchor = :center
    @ball.set_color 0,0xff,0,0xff
    self.add @ball

    reset_blocks

    self.on_key_input do |node,key,code,mod,pressed|
      next if pressed
      reset_blocks
    end

    # self.on_move_cursor{|node,x,y| point(x,y) }
    @sight_angle = 0
    self.create_timer(0,-1){|node,delta|
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
      b.set_color 0xff,0xff,0xff,32
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
      block.set_color 0xff,0xff,0xff,32

      nearest = Bi::Line::nearest_intersection @line.x, @line.y, x, y, block.sides+block.corners

      if nearest
        block.set_color 0xff,0xff,0,32
        if intersection
          if Bi::Line::compare_length(@line.x,@line.y, intersection[0], intersection[1], @line.x, @line.y, nearest[0], nearest[1] ) > 0
            intersection = nearest
            collide_block = block
          end
        elsif
          intersection = nearest
          collide_block = block
        end
      end
    }

    if intersection and collide_block
      collide_block.set_color 0xff,0,0,32
      @ball.set_position(*intersection)
      @ball.visible = true
    end

  end

end

Bi.init 480,320, title:__FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  srand(Time.now.to_i)
  layer = LineOfSightLayer.new assets
  Bi::add_layer layer
end

Bi::start_run_loop
