class Particle < Bi::Sprite
  attr_accessor :life, :life_max
  def initialize(tex,x,y)
    super tex
    self.set_position x,y
    self.anchor = :center
    self.set_color rand(0xFF),rand(0xFF),rand(0xFF),0xff
    @life = @life_max = 20 + rand(20)
  end
  def life=(life)
    if life < 0
      self.remove_from_parent
    else
      @life = life
      self.set_alpha(0xff*@life/@life_max)
    end
  end
end

Bi::init 480,320,title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  texture = assets.texture "assets/ball.png"
  texture_mapping = Bi::TextureMapping.new texture,0,0,texture.w,texture.h

  root = Bi::Node.new
  root.on_move_cursor {|n,x,y|
    particle = Particle.new texture_mapping, x, y
    particle.on_update {|n,delta|
      n.life -= 1
    }
    root.add particle
  }

  # layer
  layer = Bi::Layer.new
  layer.root = root
  layer.set_texture 0, texture
  Bi::add_layer layer
end

Bi::start_run_loop
