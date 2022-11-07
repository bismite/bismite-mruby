
srand()

Bi.init 480,320,title:"this is template"
root = Bi::Node.new
root.set_size Bi.w, Bi.h
layer = Bi::Layer.new
layer.root = root
100.times do
  node = Bi::Node.new
  root.add node
  node.set_size 10+rand(20), 10+rand(20)
  node.set_position rand(Bi.w), rand(Bi.h)
  node.anchor = :center
  node.angle = rand(360)
  node.set_color rand(0xff), rand(0xff), rand(0xff), 128
  node.create_timer(0,-1){|t,d| node.angle += 0.001*d }
end
Bi::add_layer layer
Bi::start_run_loop
