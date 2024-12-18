
class BadNode < Bi::Node
  def initialize
    super()
    self.set_position 100,100
    self.set_size 100,100
    @i = 0
    self.create_timer(500,3){|timer,dt|
      puts @i
      @i += 1
      raise "OMG!" if @i == 2
    }
  end
end

Bi.init 480,320, title:__FILE__
Bi::Archive.new("assets.dat","abracadabra").load{|assets|
  bad_node = BadNode.new
  shader_node = Bi::ShaderNode.new
  shader_node.add bad_node
  Bi.add shader_node
}

Bi::start_run_loop
