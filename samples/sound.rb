
class SoundNode < Bi::Node
  def initialize(assets)
    super()
    @assets = assets
    tex = @assets.texture("assets/face01.png")
    self.set_texture tex, 0,0,tex.w,tex.h
    self.set_size tex.w, tex.h
    self.set_position Bi.w/2, Bi.h/2
    self.anchor = :center
    @sound_started = false
    self.on_click{|n,x,y,button,pressed|
      self.sound_start unless @sound_started
      @sound_started = true
    }
  end
  def sound_start
    if( SDL::Mixer::open_audio_device 48000, SDL::AUDIO_F32LSB, 2, 1024, nil, SDL::SDL_AUDIO_ALLOW_ANY_CHANGE )
      freq,format,channels = SDL::Mixer::query_spec()
      format_name = SDL::audio_format_to_name(format)
      puts "Freq:#{freq} Format:#{format_name}(#{format}), Channels:#{channels}"
    else
    end
    music = SDL::Mixer::Music.new @assets.read "assets/loop_tag.ogg"
    p [:get_music_interface_tag, music.get_music_interface_tag]
    p [:get_music_type, SDL::Mixer::mucis_type_to_name(music.get_music_type) ]
    p [:get_music_title, music.get_music_title]
    p [:get_music_title_tag, music.get_music_title_tag]
    p [:get_music_artist_tag, music.get_music_artist_tag]
    p [:get_music_album_tag, music.get_music_album_tag]
    p [:get_music_copyright_tag, music.get_music_copyright_tag]
    puts "play failed" unless music.play_music -1

    sound = SDL::Mixer::Chunk.new @assets.read("assets/sin-1sec-mono.mp3")
    sound.volume_chunk 0
    channel = sound.play_channel -1,-1
    p [:channel, channel ]

    @angle = 0
    self.create_timer(0,-1){|t,delta|
      @angle += 0.001*delta
      x = Math::sin(@angle) * Bi.w/2 + Bi.w/2
      y = Math::cos(@angle) * Bi.h/2 + Bi.h/2
      self.set_position x, y
      SDL::Mixer::Chunk::set_panning channel, 0xff-0xFF*x.to_f/Bi.w, 0xFF*x.to_f/Bi.w
      sound.volume_chunk 32 - 32*y.to_f/Bi.h
    }
  end
end

Bi.init 480,320, title:__FILE__
Bi::Archive.load("assets.dat","abracadabra"){|assets|
  layer = Bi::Layer.new
  layer.root = assets.texture("assets/check.png").to_sprite
  Bi::add_layer layer

  soundnode = SoundNode.new(assets)
  layer.root.add soundnode
  layer.set_texture 0, layer.root.texture
  layer.set_texture 1, soundnode.texture

  flag = SDL::Mixer::init( SDL::Mixer::MIX_INIT_MP3|SDL::Mixer::MIX_INIT_OGG )
  p SDL::Mixer.flag_to_name flag
}

Bi::start_run_loop
