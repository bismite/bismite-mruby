class Particle < Bi::Node
  attr_accessor :life, :life_max, :xx, :yy, :vx, :vy
  def initialize(tex,x,y)
    super()
    self.set_texture tex,0,0,tex.w,tex.h
    self.set_size tex.w,tex.h
    self.set_position x,y
    self.anchor = :center
    self.color = Bi::Color.new rand(0xFF),rand(0xFF),rand(0xFF),0xff
    @life = @life_max = rand(100..200)
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
      self.color.a =  @life
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
    @root = assets.texture("assets/sky.png").to_sprite
    self.add @root
    @ball_texture = assets.texture "assets/ball.png"

    self.set_texture 0, @root.texture
    self.set_texture 1, @ball_texture
    self.set_blend_factor GL_SRC_ALPHA,GL_ONE,GL_SRC_ALPHA,GL_ONE

    @frame_count = 0
    @root.create_timer(0,-1){|t,delta|
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
      @root.add particle
    }
  end
end

Bi::init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  Bi::layers.add ParticleLayer.new(assets)
end
Bi::start_run_loop
