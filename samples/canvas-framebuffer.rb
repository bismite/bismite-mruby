
Bi.init 480,320,title:__FILE__,highdpi:false
Bi::Archive.load("assets.dat","abracadabra"){|assets|
  bg_tex = assets.texture("assets/check.png")
  face_tex = assets.texture("assets/face01.png")
  # Main Layer
  face = face_tex.to_sprite
  face.anchor = :center
  face.set_position Bi.w/2,Bi.h/2
  layer = Bi::Layer.new
  layer.add bg_tex.to_sprite
  layer.add face
  layer.set_texture 0, bg_tex
  layer.set_texture 1, face_tex
  Bi::layers.add layer
  # canvas from framebuffer
  framebuffer_tex = Bi::layers.framebuffer.to_texture
  framebuffer_sprite = framebuffer_tex.to_sprite
  canvas = Bi::Canvas.new Bi.w,Bi.h
  canvas.clear 0,0,0,0
  canvas.shader = Bi.default_shader
  canvas.set_texture 0, framebuffer_tex
  canvas_tex = canvas.to_texture
  canvas_sprite = canvas_tex.to_sprite
  layer.set_texture 2, canvas_tex
  layer.add canvas_sprite
  canvas_sprite.flip_vertical = true
  canvas_sprite.set_size 240,160
  canvas_sprite.set_position 20,20
  face.create_timer(500,3){|timer,dt|
    canvas.clear 0,0,0,0
    canvas.draw framebuffer_sprite
  }
}
Bi::start_run_loop
