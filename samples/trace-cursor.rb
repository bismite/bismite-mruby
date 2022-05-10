class Particle < Bi::Node
  attr_accessor :life, :life_max
  def initialize(tex,x,y)
    super
    self.set_texture tex,0,0,tex.w,tex.h
    self.set_size tex.w,tex.h
    self.set_position x,y
    self.anchor = :center
    self.set_color rand(0xFF),rand(0xFF),rand(0xFF)
    @life = @life_max = 20 + rand(20)
  end
  def life=(life)
    if life < 0
      self.remove_from_parent
    else
      @life = life
      self.opacity = @life/@life_max.to_f
    end
  end
end

Bi::init 480,320,title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  texture = assets.texture "assets/ball.png"

  # layer
  layer = Bi::Layer.new
  layer.root = assets.texture("assets/sky.png").to_sprite
  layer.set_texture 0, texture
  layer.set_texture 1, layer.root.texture
  Bi::add_layer layer

  layer.root.on_move_cursor {|n,x,y|
    particle = Particle.new texture, x, y
    particle.create_timer(0,-1) {|n,delta| n.life -= 1 }
    n.add particle
  }
end

Bi::start_run_loop
