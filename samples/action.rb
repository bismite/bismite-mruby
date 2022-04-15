class ActionSample < Bi::Node

  def initialize(texture)
    super
    self.set_position 0,0
    self.set_size Bi.w,Bi.h
    self.set_color 0x33,0,0

    face = texture.to_sprite
    face.anchor = :center
    face.set_position Bi.w/2, Bi.h/2
    self.add face

    add_action_to face

    face.on_click{|n,x,y,button,pressed|
      if pressed
        if face.actions and not face.actions.empty?
          face.remove_all_actions
        else
          face.set_position Bi.w/2, Bi.h/2
          add_action_to face
        end
      end
    }
  end

  def add_action_to(node)
    rot = Bi::Action::RotateBy.new(500, 90, proc{|node,action| p [:rotate, node, action]})
    move1 = Bi::Action::MoveTo.new(500, 0, 0, proc{|node,action| p [:move1, node, action]})
    move2 = Bi::Action::MoveTo.new(500, Bi.w/2, Bi.h/2, proc{|node,action| p [:move2, node, action]})
    seq = Bi::Action::Sequence.new( [rot,move1,move2], proc{|node,action| p [:sequence, node, action] })
    rep = Bi::Action::Repeat.new( seq, proc{|node,action| p [:repeat, node, action] })
    node.add_action rep
  end
end

Bi.init 480,320,title: __FILE__

Bi::Archive.new("assets.dat","abracadabra").load do |assets|
  texture = assets.texture "assets/face01.png"
  layer = Bi::Layer.new
  layer.root = ActionSample.new texture
  layer.set_texture 0, texture
  Bi::add_layer layer
end

Bi::start_run_loop
