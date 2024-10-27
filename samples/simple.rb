
Bi.init 480,320,title:__FILE__
rectangle = Bi::Node.rect 100,100
layer = Bi::Layer.new
layer.add rectangle, :center, :center
Bi::layers.add layer
Bi::start_run_loop
