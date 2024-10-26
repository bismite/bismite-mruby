
p Bi::Version::mruby_libbismite

Bi.init 480,320,title:__FILE__

# Node
rectangle = Bi::Node.rect 100,100

# layer
layer = Bi::Layer.new
layer.add rectangle, :center, :center
Bi::layers.add layer

# start
Bi::start_run_loop
