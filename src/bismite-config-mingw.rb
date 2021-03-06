#!/usr/bin/env ruby

root = File.absolute_path(File.join(File.expand_path(File.dirname($0)),".."))
STATIC_LIBS = %w(mruby-static bismite SDL2main SDL2 SDL2_mixer SDL2_image-static png z yaml msgpackc).map{|l| "#{root}/lib/lib#{l}.a" }.join(" ")

ARGV.each do |command|
  case command
  when "--static-libs"
    puts "-L#{root}/lib  -lmingw32 #{STATIC_LIBS} -lopengl32 -lws2_32 -mwindows -Wl,--dynamicbase -Wl,--nxcompat -Wl,--high-entropy-va -lm -ldinput8 -ldxguid -ldxerr8 -luser32 -lgdi32 -lwinmm -limm32 -lole32 -loleaut32 -lshell32 -lsetupapi -lversion -luuid"
  when "--libs"
    puts "-L#{root}/bin -L#{root}/lib -lmruby -lbismite -lmingw32 -lSDL2main -lSDL2 -mwindows -lSDL2_mixer -lSDL2_image -lopengl32 -lws2_32 -lyaml -lmsgpackc"
  when "--cflags"
    puts "-DMRB_INT64 -DMRB_UTF8_STRING -DMRB_NO_BOXING -I#{root}/include -I#{root}/include/SDL2 -Dmain=SDL_main"
  end
end
