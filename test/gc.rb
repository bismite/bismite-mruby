
def test(node)
  test = Bi::Node.new
  test.color = Bi::Color.new 0,0xff,0,0xff
  test.set_size 100,100
  test.set_position 100,100
  node.add test
  node.remove test
end

Bi.init 480,320,title:__FILE__,highdpi:false

bg = Bi::Node.new
bg.color = Bi::Color.new 0x33,0,0,0xff
bg.set_size 480,320

# layer
layer = Bi::Layer.new
layer.add bg
Bi::layers.add layer

# add,remove,GC
test bg
GC.start

# start
Bi::start_run_loop
