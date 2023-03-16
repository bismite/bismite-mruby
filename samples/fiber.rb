
class Fiber
  def self.sleep(sec)
    t = Time.now
    self.yield while Time.now - t < sec
  end
end

Bi.init 480,320, title:__FILE__
Bi::Archive.load("assets.dat","abracadabra"){|assets|
  # layer
  layer = Bi::Layer.new
  layer.root = assets.texture("assets/face01.png").to_sprite
  layer.root.set_position Bi.w/2,Bi.h/2
  layer.root.anchor = :center
  layer.set_texture 0, layer.root.texture
  Bi::add_layer layer

  f = Fiber.new do
    360.times do
      layer.root.angle += 0.1
      Fiber.sleep 0.01
    end
    true
  end

  layer.root.create_timer(0,-1){|t,delta|
    if f
      if f.resume
        f = nil
      end
    end
  }
}

Bi::start_run_loop
