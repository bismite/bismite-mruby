if Bi::Version.emscripten
  SHADER_HEADER="#version 300 es\nprecision highp float;\n"
else
  SHADER_HEADER="#version 410\n"
end

# 8 Render Target Textures
#  0: Result
#  1-7: RGBCMYK
class MrtFramebufferNode < Bi::Node
  def initialize
    super()
    maptex = $assets.texture("assets/map.png")
    self.set_size maptex.w, maptex.h
    self.flip_vertical = true
    # Framebuffer
    self.framebuffer = Bi::Framebuffer.new self.w,self.h,8
    fbtex = self.framebuffer.textures[0]
    self.set_texture fbtex, 0,0,fbtex.w,fbtex.h
    # Shader Node 1: render textures 1-7
    shader_node1 = Bi::ShaderNode.new
    vert = SHADER_HEADER + $assets.read("assets/shaders/default.vert")
    frag = SHADER_HEADER + $assets.read("assets/shaders/mrt_rgbcmyk.frag")
    shader_node1.shader = Bi::Shader.new vert,frag
    shader_node1.add maptex.to_sprite
    shader_node1.set_texture 0, maptex
    # Shader Node 2: render RGBCMYK to texture0
    shader_node2 = Bi::ShaderNode.new
    vert = SHADER_HEADER + $assets.read("assets/shaders/default.vert")
    frag = SHADER_HEADER + $assets.read("assets/shaders/mrt_rgbcmyk_blend.frag")
    shader_node2.shader = Bi::Shader.new vert,frag
    shader_node2.add Bi::Node.rect(self.w,self.h)
    7.times{|i|
      shader_node2.set_texture i, self.framebuffer.textures[1+i]
    }
    self.add shader_node1
    self.add shader_node2
  end
end

Bi.init 480,320,title:__FILE__,highdpi:true
Bi::Archive.load("assets.dat","abracadabra") do |assets|
  $assets = assets
  # Framebuffer Node
  framebuffer_node = MrtFramebufferNode.new
  # Draw
  shader_node = Bi::ShaderNode.new
  shader_node.add framebuffer_node
  shader_node.set_texture 0,framebuffer_node.texture
  Bi.add shader_node
end
Bi::start_run_loop
