srand()

class RotateNode < Bi::Node
  def initialize
    super()
    self.set_size(10,10)
    self.anchor = :center
    self.color = Bi::Color.new( rand(0xff), rand(0xff), rand(0xff), 0x80)
    self.set_position(rand(480),rand(320))
    # Autoremove 180 frame after
    self.create_timer(0,60*3){|timer,dt| timer.node.angle += dt*0.01 }
  end
end

Bi.init 480,320,highdpi:true,title:__FILE__
shader_node = Bi::ShaderNode.new
Bi.default_framebuffer_node.add shader_node
shader_node.create_timer(500,5){|timer,dt|
  1000.times{|i| timer.node.add RotateNode.new }
}
shader_node.create_timer(1000,-1){|timer,dt|
  ms = ObjectSpace::memsize_of_all / 1000
  co = ObjectSpace::count_objects
  ct,cf,cd,cp = co[:TOTAL],co[:FREE],co[:T_DATA],co[:T_PROC]
  puts "#{Time.now} MemSize:#{ms}KB TOTAL:#{ct} FREE:#{cf} DATA:#{cd} PROC:#{cp}"
}
Bi.start_run_loop
