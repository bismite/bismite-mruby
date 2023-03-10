class Particle < Bi::Node
  attr_accessor :life, :life_max, :xx, :yy, :vx, :vy
  def initialize(tex,x,y)
    super()
    self.set_texture tex,0,0,tex.w,tex.h
    self.set_size tex.w,tex.h
    self.set_position x,y
    self.anchor = :center
    self.set_color rand(0xFF),rand(0xFF),rand(0xFF)
    @life = @life_max = 100 + rand(100)
    @vx = (rand()-0.5) * 3
    @vy = (rand()-0.5) * 3
    @xx = x.to_f
    @yy = y.to_f
  end
  def life=(life)
    if life < 0
      self.parent.remove self
    else
      @life = life
      self.opacity = @life / @life_max.to_f
    end
  end
  def move
    self.life -= 1
    @xx += @vx
    @yy += @vy
    set_position(@xx, @yy)
  end
end

class ParticleLayer < Bi::Layer
  def initialize(assets)
    super()

    self.root = assets.texture("assets/sky.png").to_sprite
    @ball_texture = assets.texture "assets/ball.png"

    self.set_texture 0, self.root.texture
    self.set_texture 1, @ball_texture
    self.set_blend_factor GL_SRC_ALPHA,GL_ONE,GL_SRC_ALPHA,GL_ONE

    @frame_count = 0
    self.root.create_timer(0,-1){|t,delta|
      if @frame_count < 30
        @frame_count += 1
      else
        @frame_count = 0
        self.add_particle rand(Bi.w), rand(Bi.h), rand(20..100)
      end
    }

  end
  def add_particle(x,y,num)
    num.times{
      particle = Particle.new @ball_texture, x, y
      particle.create_timer(0,-1){|t,delta| particle.move }
      self.root.add particle
    }
  end
end


Bi::init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  Bi::add_layer ParticleLayer.new(assets)
end

Bi::start_run_loop
