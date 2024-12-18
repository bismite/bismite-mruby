
class FiberRotateNode < Bi::Node
  attr_reader :fiber
  def initialize(tex)
    super()
    self.set_texture tex,0,0,tex.w,tex.h
    self.set_size tex.w,tex.h
    self.anchor = :center
    # Fiber
    @fiber = Fiber.new{|node|
      loop do
        Fiber.yield
        node.angle += 0.01
      end
    }
    self.create_timer(0,-1){|timer,dt|
      timer.node.fiber.resume(timer.node)
    }
  end
end

Bi.init 480,320,title:__FILE__,highdpi:true
Bi::Archive.load("assets.dat","abracadabra"){|assets|
  background = assets.texture("assets/check.png").to_sprite
  face = FiberRotateNode.new( assets.texture("assets/face01.png") )
  background.add face,:center,:center
  snode = Bi::ShaderNode.new
  snode.add background
  snode.set_texture 0, background.texture
  snode.set_texture 1, face.texture
  Bi::default_framebuffer_node.add snode
}
# start
Bi::start_run_loop
