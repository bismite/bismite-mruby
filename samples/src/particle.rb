class Particle < Bi::Sprite
  attr_accessor :life, :life_max, :xx, :yy, :vx, :vy
  def initialize(texture_mapping,x,y)
    super texture_mapping
    self.set_position x,y
    self.anchor = :center
    self.set_color rand(0xFF),rand(0xFF),rand(0xFF),0xff
    @life = @life_max = 100 + rand(100)
    @vx = (rand(nil)-0.5) * 3
    @vy = (rand(nil)-0.5) * 3
    @xx = x.to_f
    @yy = y.to_f
  end
  def life=(life)
    if life < 0
      self.parent.remove self
    else
      @life = life
      self.set_alpha(0xff*@life/@life_max)
    end
  end
  def my_update(n)
    n.life -= 1
    n.xx += n.vx
    n.yy += n.vy
    n.set_position(n.xx, n.yy)
  end
end

class ParticleLayer < Bi::Layer
  def initialize(assets)
    super

    sky_texture = assets.texture "assets/sky.png"
    ball_texture = assets.texture "assets/ball.png", false

    self.set_texture 0, sky_texture
    self.set_texture 1, ball_texture
    self.set_blend_factor Bi::Layer::GL_SRC_ALPHA,Bi::Layer::GL_ONE,Bi::Layer::GL_SRC_ALPHA,Bi::Layer::GL_ONE

    self.root = Bi::Node.new
    self.root.add sky_texture.to_sprite

    @texture = ball_texture
    @texture_mapping = Bi::TextureMapping.new @texture,0,0,@texture.w,@texture.h

    @frame_count = 0
    self.root.on_update{|node,delta|
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
      particle = Particle.new @texture_mapping, x, y
      particle.on_update :my_update
      self.root.add particle
    }
  end
end


Bi::init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  Bi::add_layer ParticleLayer.new(assets)
end

Bi::start_run_loop
