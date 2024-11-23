
if Bi::Version.emscripten
  SHADER_HEADER="#version 300 es\nprecision highp float;\n"
else
  SHADER_HEADER="#version 410\n"
end

# Sky and Spin Mushroom
class SceneA < Bi::Node
  def initialize(w,h)
    super()
    self.flip_vertical = true
    self.set_size(w,h)
    self.framebuffer = Bi::Framebuffer.new(w,h)
    tex = self.framebuffer.to_texture(0)
    self.set_texture tex,0,0,tex.w,tex.h
    shader = Bi::ShaderNode.new
    self.add shader
    bg = $assets.texture("assets/sky.png").to_sprite
    sprite = $assets.texture("assets/mushroom.png").to_sprite
    sprite.anchor = :center
    sprite.set_position w/2,h/2
    sprite.scale = 4
    sprite.create_timer(0,-1) {|t,delta| sprite.angle += delta*0.005 }
    shader.add bg
    shader.add sprite
    shader.set_texture 0,bg.texture
    shader.set_texture 1,sprite.texture
    bg.on_click{|n,x,y,button,pressed|
      $transition_node.transition($scene_b) unless pressed
    }
  end
end

# Checkerboard and Spin Face
class SceneB < Bi::Node
  def initialize(w,h)
    super()
    self.flip_vertical = true
    self.set_size(w,h)
    self.framebuffer = Bi::Framebuffer.new(w,h)
    tex = self.framebuffer.to_texture(0)
    self.set_texture tex,0,0,tex.w,tex.h
    shader = Bi::ShaderNode.new
    self.add shader
    bg = $assets.texture("assets/check.png").to_sprite
    sprite = $assets.texture("assets/face01.png").to_sprite
    sprite.anchor = :center
    sprite.set_position w/2,h/2
    sprite.scale = 2
    sprite.create_timer(0,-1) {|t,delta| sprite.angle += delta*0.005 }
    shader.add bg
    shader.add sprite
    shader.set_texture 0,bg.texture
    shader.set_texture 1,sprite.texture
    bg.on_click{|n,x,y,button,pressed|
      $transition_node.transition($scene_a) unless pressed
    }
  end
end

class TransitionShaderNode < Bi::ShaderNode
  def initialize
    super()
    vert = SHADER_HEADER + $assets.read("assets/shaders/default.vert")
    frag = SHADER_HEADER + $assets.read("assets/shaders/transition.frag")
    self.shader = Bi::Shader.new vert,frag
    self.progress = 1.0
    self.create_timer(0,-1) {|t,delta|
      self.progress += 0.01
      if self.progress > 1.0
        self.progress = 1.0
      end
    }
  end
  def progress = @progress
  def progress=(progress)
    @progress = progress
    self.set_shader_extra_data 0, @progress
  end
  def set_scene(scene)
    @scene = scene
    self.progress = 1.0
    self.remove_all_children
    self.add @scene
    self.set_texture 0,@scene.texture
  end
  def transition(new_scene)
    puts "Transition Start"
    self.remove @scene
    self.add new_scene
    self.set_texture 0,new_scene.texture
    self.set_texture 1,@scene.texture
    @scene = new_scene
    self.progress = 0.0
  end
end

Bi.init 480,320,title:__FILE__,highdpi:true
Bi::Archive.load("assets.dat","abracadabra"){|assets|
  $assets = assets
  $transition_node = TransitionShaderNode.new
  Bi.add $transition_node
  $scene_a = SceneA.new(Bi.w,Bi.h)
  $scene_b = SceneB.new(Bi.w,Bi.h)
  $transition_node.set_scene $scene_a
}
Bi::start_run_loop
