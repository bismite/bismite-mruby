
class Fiber
  def self.sleep(sec)
    t = Time.now
    self.yield while Time.now - t < sec
  end
end

Bi.init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  root = Bi::Node.new
  root.set_size Bi.w, Bi.h
  root.set_color 0x33,0,0,0xff

  # create sprite
  texture = assets.texture "assets/face01.png"
  face = texture.to_sprite
  face.set_position Bi.w/2,Bi.h/2
  face.anchor = :center
  root.add face

  f = Fiber.new do
    360.times do
      face.angle += 1
      Fiber.sleep 0.01
    end
    true
  end

  face.on_update{|node,delta|
    if f
      if f.resume
        f = nil
      end
    end
  }

  # layer
  layer = Bi::Layer.new
  layer.root = root
  layer.set_texture 0, texture
  Bi::add_layer layer
end

Bi::start_run_loop
