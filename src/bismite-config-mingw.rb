#!/usr/bin/env ruby

root = File.absolute_path(File.join(File.expand_path(File.dirname($0)),".."))

ARGV.each do |command|
  case command
  when "--libs"
    puts "-L#{root}/lib -lmruby -lbismite-core -lbismite-ext -lmingw32 -lSDL2main -lSDL2 -mwindows -lSDL2_mixer -lSDL2_image -lopengl32 -lws2_32"
  when "--cflags"
    puts "-DMRB_INT64 -DMRB_UTF8_STRING -DMRB_NO_BOXING -I#{root}/include -I#{root}/include/SDL2 -Dmain=SDL_main"
  end
end
