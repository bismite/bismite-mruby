
Bi.init 480,320, title:__FILE__
Bi::Archive.load("assets.dat","abracadabra"){|assets|

  layer = Bi::Layer.new
  layer.root = assets.texture("assets/check.png").to_sprite
  Bi::add_layer layer
  face = assets.texture("assets/face01.png").to_sprite
  face.set_position Bi.w/2, Bi.h/2
  face.scale_x = face.scale_y = 2.0
  face.anchor = :center
  layer.root.add face
  layer.set_texture 0, layer.root.texture
  layer.set_texture 1, face.texture

  flag = SDL::Mixer::init( SDL::Mixer::MIX_INIT_MP3|SDL::Mixer::MIX_INIT_OGG )
  p SDL::Mixer.flag_to_name flag

  SDL::Mixer::open_audio 441000, SDL::AUDIO_S16LSB, 2, 1024

  music = SDL::Mixer::Music.new assets.read("assets/loop_tag.ogg")
  p music
  p [:get_music_interface_tag, music.get_music_interface_tag]
  p [:get_music_type, SDL::Mixer::mucis_type_to_name(music.get_music_type) ]
  p [:get_music_title, music.get_music_title]
  p [:get_music_title_tag, music.get_music_title_tag]
  p [:get_music_artist_tag, music.get_music_artist_tag]
  p [:get_music_album_tag, music.get_music_album_tag]
  p [:get_music_copyright_tag, music.get_music_copyright_tag]
  puts "play failed" unless music.play_music -1

  sound = SDL::Mixer::Chunk.new assets.read("assets/sin-1sec-mono.mp3")
  sound.volume_chunk 0
  channel = sound.play_channel -1,-1
  p [:channel, channel ]

  @angle = 0
  face.create_timer(0,-1){|t,delta|
    @angle += 0.001*delta
    x = Math::sin(@angle) * Bi.w/2 + Bi.w/2
    y = Math::cos(@angle) * Bi.h/2 + Bi.h/2
    face.x = x
    face.y = y
    SDL::Mixer::Chunk::set_panning channel, 0xff-0xFF*x.to_f/Bi.w, 0xFF*x.to_f/Bi.w
    sound.volume_chunk 32 - 32*y.to_f/Bi.h
  }
}

Bi::start_run_loop
