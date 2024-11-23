
Bi.init 480,320,highdpi:true,title:__FILE__

rectangle = Bi::Node.rect 100,100
rectangle.color = 0xFF0000FF
shader_node = Bi::ShaderNode.new
shader_node.add rectangle, 100,100
Bi.default_framebuffer_node.add shader_node

Bi.start_run_loop
