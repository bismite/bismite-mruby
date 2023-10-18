
srand()

Bi.init 480,320,title:"this is template"
Bi.color = Bi::Color.new 0,0x33,0x33,0xff
layer = Bi::Layer.new
Bi::layers.add layer
100.times do
  node = Bi::Node.new
  layer.add node
  node.set_size 10+rand(20), 10+rand(20)
  node.set_position rand(Bi.w), rand(Bi.h)
  node.anchor = :center
  node.angle = rand(360)
  node.color = Bi::Color.new rand(0xff), rand(0xff), rand(0xff), 128
  node.create_timer(0,-1){|t,d| node.angle += 0.001*d }
end
Bi::start_run_loop
