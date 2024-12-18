srand()

class RotateNode < Bi::Node
  def initialize
    super()
    self.set_size(10,10)
    self.anchor = :center
    self.color = Bi::Color.new( rand(0xff), rand(0xff), rand(0xff), 0x80)
    self.set_position(rand(480),rand(320))
    @@rotate_proc ||= proc {|timer,dt| timer.node.angle += dt*0.01 }
    self.create_timer(0,-1,&@@rotate_proc)
  end
end

Bi.init 480,320,highdpi:true,title:__FILE__
shader_node = Bi::ShaderNode.new
Bi.default_framebuffer_node.add shader_node
shader_node.create_timer(500,-1){|timer,dt|
  middleman = Bi::Node.new
  timer.node.add middleman
  1000.times{|i| middleman.add RotateNode.new }
}
shader_node.create_timer(1000,-1){|timer,dt|
  ms = ObjectSpace::memsize_of_all / 1000
  co = ObjectSpace::count_objects
  ct,cf,cd,cp = co[:TOTAL],co[:FREE],co[:T_DATA],co[:T_PROC]
  puts "#{Time.now} MemSize:#{ms}KB TOTAL:#{ct} FREE:#{cf} DATA:#{cd} PROC:#{cp}"
}
shader_node.create_timer(3000,-1){|timer,dt|
  puts "---- CLEAR ----"
  timer.node.remove_all_children
}
Bi.start_run_loop
