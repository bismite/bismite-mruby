class Particle < Bi::Node
  attr_accessor :life, :life_max
  def initialize(tex,x,y)
    super()
    self.set_texture tex,0,0,tex.w,tex.h
    self.set_size tex.w,tex.h
    self.set_position x,y
    self.anchor = :center
    self.set_color rand(0xFF),rand(0xFF),rand(0xFF),0xff
    @life = @life_max = 200
  end
  def life=(life)
    if life < 0
      self.remove_from_parent
    else
      @life = life
      self.color.a = @life
    end
  end
end

Bi::init 480,320,title:__FILE__
Bi::Archive.load("assets.dat","abracadabra"){|assets|
  ball_tex = assets.texture "assets/ball.png"
  bg_tex = assets.texture "assets/sky.png"

  bg = bg_tex.to_sprite
  layer = Bi::Layer.new
  layer.add bg
  layer.set_texture 0, ball_tex
  layer.set_texture 1, bg_tex
  Bi::layers.add layer

  bg.on_move_cursor {|n,x,y|
    particle = Particle.new ball_tex, x, y
    particle.create_timer(0,-1) {|t,delta| particle.life -= 4 }
    n.add particle
  }
}

Bi::start_run_loop
