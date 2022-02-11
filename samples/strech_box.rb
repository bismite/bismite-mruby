
Bi.init 480,320,title:__FILE__,highdpi:false

class StrechBox < Bi::Node
  attr_reader :texture
  def initialize(texture_mapping,w,h,corner_size)
    super
    @texture = texture_mapping.texture
    x = texture_mapping.x
    y = texture_mapping.y
    sw = texture_mapping.w # sprite w
    sh = texture_mapping.h # sprite h
    cw = ch = corner_size # corner w,h
    lb = Bi::TextureMapping.new(@texture,x,y+sh-ch,cw,ch).to_sprite
    lt = Bi::TextureMapping.new(@texture,x,y,cw,ch).to_sprite
    rb = Bi::TextureMapping.new(@texture,x+sw-cw,y+sh-ch,cw,ch).to_sprite
    rt = Bi::TextureMapping.new(@texture,x+sw-cw,y,cw,ch).to_sprite
    self.add lt
    self.add lb
    self.add rt
    self.add rb
    lt.set_position 0,h-ch
    lb.set_position 0,0
    rt.set_position w-cw,h-ch
    rb.set_position w-cw,0

    mw = (sw-corner_size*2) # mid w
    mh = (sh-corner_size*2) # mid h
    row = (w-corner_size*2) / mw
    col = (h-corner_size*2) / mh
    center = Bi::TextureMapping.new(@texture,x+cw,y+ch,mw,mh)
    row.times{|x|
      col.times{|y|
        c = center.to_sprite
        self.add c
        c.set_position cw+x*mw,ch+y*mh
      }
    }

    top = Bi::TextureMapping.new(@texture,x+cw,y,mw,ch)
    bottom = Bi::TextureMapping.new(@texture,x+cw,y+sh-cw,mw,ch)
    row.times{|x|
      # top
      t = top.to_sprite
      self.add t
      t.set_position cw+x*mw,h-ch
      # bottom
      b = bottom.to_sprite
      self.add b
      b.set_position cw+x*mw,0
    }
    left = Bi::TextureMapping.new(@texture,x,y+ch,cw,mh)
    right = Bi::TextureMapping.new(@texture,x+sw-cw,y+ch,cw,mh)
    col.times{|y|
      # left
      l = left.to_sprite
      self.add l
      l.set_position 0,y*mh+ch
      # right
      r = right.to_sprite
      self.add r
      r.set_position w-cw,y*mh+ch
    }
  end
end


Bi::Archive.load("assets.dat","abracadabra") do |assets|
  # layer
  layer = Bi::Layer.new
  layer.root = Bi::Node.new
  Bi::add_layer layer

  # texture
  tex = assets.texture("assets/frame.png")
  mapping = Bi::TextureMapping.new(tex,0,0,32,32)
  box = StrechBox.new mapping,104,80,4

  box.scale_x = box.scale_y = 4.0
  layer.root.add box
  layer.set_texture 0, box.texture
end

Bi::start_run_loop
