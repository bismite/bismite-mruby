
class BadNode < Bi::Node
  def initialize(tex)
    super()
    self.set_texture tex,0,0,tex.w,tex.h
    self.set_size tex.w,tex.h
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

  face_tex = assets.texture("assets/face01.png")
  bad_node = BadNode.new face_tex

  shader_node = Bi::ShaderNode.new
  shader_node.add bad_node
  shader_node.set_texture 0, face_tex
  Bi.add shader_node
}


Bi::start_run_loop
