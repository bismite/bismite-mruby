
class RectCollide < Bi::Node

  def rect(x,y,w,h,r,g,b,opacity)
    rect = Bi::Node.new
    rect.set_color r,g,b
    rect.opacity = opacity
    rect.set_size w,h
    rect.set_position x,y
    rect
  end

  def initialize(sky_texture,ball_texture)
    super

    self.set_size Bi.w, Bi.h

    self.add sky_texture.to_sprite

    @blocks = []
    50.times do
      b = Bi::Node.new
      b.set_size rand(32..64), rand(32..64)
      b.set_color 0xff,0xff,0xff
      b.set_position *random_block_position
      self.add b
      @blocks << b
    end

    @me = rect Bi.w/2, Bi.h/2, 20,20, 0xff,0xff,0xff, 0.5
    self.add @me

    @ghost = rect @me.x,@me.y, @me.w,@me.h, 0xff,0,0, 0.5
    self.add @ghost

    @pushed = rect @me.x, @me.y, @me.w, @me.h, 0xff,0xff,0, 0.5
    self.add @pushed

    @line = rect Bi.w/2,Bi.h/2,32,32, 0xff,0xff,0xff, 1.0
    @line.anchor = :west
    @line.scale_y = 1.0 / @line.h
    self.add @line

    @ball = ball_texture.to_sprite
    @ball.anchor = :center
    self.add @ball

    self.on_key_input do |node,key,code,mod,pressed|
      @blocks.each{|b| b.set_position *random_block_position } unless pressed
    end

    @sight_angle = 0
    self.create_timer(0,-1){|node,delta|
      @sight_angle += 0.001*delta
      distance = Bi.h
      x = Bi.w/2 + distance * Math::cos(@sight_angle)
      y = Bi.h/2 + distance * Math::sin(@sight_angle)
      point(x,y)
    }
  end

  def random_block_position
    angle = rand() * Math::PI*2
    distance = rand(100..400)
    return Bi.w/2 + distance * Math::cos(angle), Bi.h/2 + distance * Math::sin(angle)
  end

  def point(x,y)
    @ghost.set_position x,y

    lx = x - @line.x
    ly = y - @line.y
    @line.angle = Math.atan2(ly,lx)
    @line.scale_x = Math.sqrt( lx**2 + ly**2 ) / @line.w

    sx = @line.x
    sy = @line.y

    intersection = nil
    collide_block = nil

    @blocks.each{|block|
      block.set_color 0xff,0xff,0xff
      block.opacity = 0.5

      # Minkowski addition
      rx = block.x - @me.w
      ry = block.y - @me.h
      rw = block.w + @me.w
      rh = block.h + @me.h

      l = rx
      r = rx + rw - 1
      b = ry
      t = ry + rh - 1

      sides = [
        [l,t,l,b], # left
        [r,t,r,b], # right
        [l,t,r,t], # top
        [l,b,r,b], # bottom
      ]

      nearest = Bi::Line::nearest_intersection sx, sy, x, y, sides

      corners = [
        [l,t],
        [l,b],
        [r,t],
        [r,b]
      ]
      corners.each{|corner|
        if Bi::Line::on?( sx,sy, x, y, *corner )
          if nearest==nil or (nearest and Bi::Line::compare_length(sx,sy,nearest[0],nearest[1], sx,sy,corner[0],corner[1]) > 0)
            nearest = corner
          end
        end
      }

      if nearest
        if intersection
          if Bi::Line::compare_length(sx,sy, intersection[0], intersection[1], sx, sy, nearest[0], nearest[1] ) > 0
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
      collide_block.set_color 0xff,0,0
      @ball.set_position(*intersection)
      @ball.visible = true
      @pushed.set_position(*intersection)
      @pushed.visible = true
    else
      @ball.visible = false
      @pushed.visible = false
    end

  end
end


Bi.init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  srand(Time.now.to_i)
  sky = assets.texture "assets/sky.png"
  ball = assets.texture "assets/ball.png"
  layer = Bi::Layer.new
  layer.root = RectCollide.new sky,ball
  layer.set_texture 0, sky
  layer.set_texture 1,ball
  Bi::add_layer layer
end

Bi::start_run_loop
