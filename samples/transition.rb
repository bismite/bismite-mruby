
if Bi::Version.emscripten
  SHADER_HEADER="#version 300 es\nprecision highp float;\n"
else
  SHADER_HEADER="#version 410\n"
end

class TransitionLayer < Bi::PostProcessLayer
  def initialize(framebuffer,shader)
    super()
    self.shader = shader
    @framebuffer = framebuffer
    @snapshot = take_snapshot
    snapshot_tex = @snapshot.to_texture
    snapshot_sprite = snapshot_tex.to_sprite
    snapshot_sprite.set_size Bi.w,Bi.h
    snapshot_sprite.flip_vertical = true
    self.add snapshot_sprite
    self.set_texture 0, snapshot_tex
    self.set_texture 1, framebuffer.to_texture
    @progress = 0.0
    snapshot_sprite.create_timer(0,-1) {|t,delta|
      @progress += 0.01
      if @progress > 1.0
        self.remove_from_parent
        puts "remove"
      else
        self.set_shader_extra_data 0, @progress
      end
    }
  end
  def take_snapshot
    framebuffer_tex = @framebuffer.to_texture
    framebuffer_sprite = framebuffer_tex.to_sprite
    canvas = Bi::Canvas.new framebuffer_tex.w, framebuffer_tex.h
    canvas.shader = Bi.default_shader
    canvas.clear 0,0,0,0
    canvas.set_texture 0, framebuffer_tex
    canvas.draw framebuffer_sprite
    canvas
  end
end

def layer_a
  bg = $assets.texture("assets/sky.png").to_sprite
  mushroom = $assets.texture("assets/mushroom.png").to_sprite
  mushroom.set_position Bi.w/2,Bi.h/2
  mushroom.set_scale 2,2
  mushroom.anchor = :center
  layer = Bi::Layer.new
  layer.add bg
  layer.add mushroom
  layer.set_texture 0, bg.texture
  layer.set_texture 1, mushroom.texture
  mushroom.create_timer(0,-1) {|t,delta| mushroom.angle += delta*0.01 }
  # Transition
  bg.on_click{|n,x,y,button,press|
    unless press
      layer.remove_from_parent
      new_layer = layer_b
      Bi.layers.add new_layer
      shader_vert = SHADER_HEADER + $assets.read("assets/shaders/default.vert")
      shader_frag = SHADER_HEADER + $assets.read("assets/shaders/transition.frag")
      transition_shader = Bi::Shader.new shader_vert,shader_frag
      transition_layer = TransitionLayer.new(Bi::layers.framebuffer,transition_shader)
      Bi.layers.add transition_layer
    end
    true
  }
  layer
end

def layer_b
  bg = $assets.texture("assets/check.png").to_sprite
  face = $assets.texture("assets/face01.png").to_sprite
  face.set_position Bi.w/2,Bi.h/2
  face.set_scale 2,2
  face.anchor = :center
  layer = Bi::Layer.new
  layer.add bg
  layer.add face
  layer.set_texture 0, bg.texture
  layer.set_texture 1, face.texture
  face.create_timer(0,-1) {|t,delta| face.angle += delta*0.01 }
  layer
end

# start
Bi.init 480,320,title:__FILE__,highdpi:true
Bi::Archive.load("assets.dat","abracadabra"){|assets|
  $assets = assets
  Bi::layers.add layer_a
}
Bi::start_run_loop
