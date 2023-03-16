
Bi.init 480,320,title:__FILE__,highdpi:false

class StrechBox < Bi::Node
  attr_reader :texture
  def initialize(tex,x,y,sw,sh, w,h,corner_size)
    super()
    self.set_size w,h
    @texture = tex
    cw = ch = corner_size # corner w,h
    lb = @texture.to_sprite x,y+sh-ch,cw,ch
    lt = @texture.to_sprite x,y,cw,ch
    rb = @texture.to_sprite x+sw-cw,y+sh-ch,cw,ch
    rt = @texture.to_sprite x+sw-cw,y,cw,ch
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
    row.times{|xx|
      col.times{|yy|
        c = @texture.to_sprite x+cw,y+ch,mw,mh
        self.add c
        c.set_position cw+xx*mw,ch+yy*mh
      }
    }
    # Top and Bottom
    row.times{|xx|
      t = @texture.to_sprite x+cw,y,mw,ch
      self.add t
      t.set_position cw+xx*mw,h-ch
      b = @texture.to_sprite x+cw,y+sh-cw,mw,ch
      self.add b
      b.set_position cw+xx*mw,0
    }
    # Left and Right
    col.times{|yy|
      l = @texture.to_sprite x,y+ch,cw,mh
      self.add l
      l.set_position 0,yy*mh+ch
      r = @texture.to_sprite x+sw-cw,y+ch,cw,mh
      self.add r
      r.set_position w-cw,yy*mh+ch
    }
  end
end


Bi::Archive.load("assets.dat","abracadabra") do |assets|
  # layer
  layer = Bi::Layer.new
  layer.root = Bi::Node.new
  layer.root.set_color 0x33,0,0
  layer.root.set_size Bi.w,Bi.h
  Bi::add_layer layer

  # texture
  tex = assets.texture("assets/frame.png")
  box = StrechBox.new tex,0,0,32,32, 104,80,4

  box.set_scale 3,3
  box.set_position 60,20
  layer.root.add box
  layer.set_texture 0, box.texture
end

Bi::start_run_loop
