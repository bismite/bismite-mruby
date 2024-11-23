
Bi.init 480,320,title: __FILE__
Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  shader_node = Bi::ShaderNode.new
  texture = assets.texture "assets/face01.png"
  face = texture.to_sprite
  face.anchor = :center
  face.set_position Bi.w/2, Bi.h/2
  face.add_action Bi::Action::RotateBy.new(500, 360, autoremove:true)
  p face.actions
  face.create_timer(1000,1){|t,dt| p face.actions }
  shader_node.add face
  shader_node.set_texture 0, texture
  Bi.add shader_node
end

Bi::start_run_loop
