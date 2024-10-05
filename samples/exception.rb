
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
  Bi.color = Bi::Color.new 0x33,0,0,0xff
  face_tex = assets.texture("assets/face01.png")
  bad_node = BadNode.new face_tex
  # layer
  layer = Bi::Layer.new
  layer.add bad_node
  layer.set_texture 0, face_tex
  Bi::layers.add layer
}


Bi::start_run_loop
