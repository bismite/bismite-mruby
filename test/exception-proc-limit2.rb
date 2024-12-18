
class TimerNode < Bi::Node
  def initialize
    super()
    self.set_size(10,10)
    self.anchor = :center
    self.color = Bi::Color.new( rand(0xff), rand(0xff), rand(0xff), 0x80)
    self.set_position(rand(480),rand(320))
    # Exception: too many irep references
    self.create_timer(0,-1){|timer,dt| self.angle += dt*0.01 }
  end
end

Bi.init 480,320,highdpi:true,title:__FILE__
shader_node = Bi::ShaderNode.new
Bi.default_framebuffer_node.add shader_node
(0xffff).times{|i| shader_node.add TimerNode.new }
Bi.start_run_loop
