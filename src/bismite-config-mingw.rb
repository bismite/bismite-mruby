#!/usr/bin/env ruby

root = File.absolute_path(File.join(File.expand_path(File.dirname($0)),".."))
STATIC_LIBS = %w(mruby-static bismite SDL2main SDL2 SDL2_mixer SDL2_image-static).map{|l| "#{root}/lib/lib#{l}.a" }.join(" ")
DEFINES = %w(MRB_INT64 MRB_UTF8_STRING MRB_NO_BOXING MRB_NO_DEFAULT_RO_DATA_P MRB_STR_LENGTH_MAX=0).map{|d| "-D#{d}" }.join(" ")

ARGV.each do |command|
  case command
  when "--static-libs"
    puts "-L#{root}/lib  -lmingw32 #{STATIC_LIBS} -lopengl32 -lws2_32 -mwindows -Wl,--dynamicbase -Wl,--nxcompat -Wl,--high-entropy-va -lm -ldinput8 -ldxguid -ldxerr8 -luser32 -lgdi32 -lwinmm -limm32 -lole32 -loleaut32 -lshell32 -lsetupapi -lversion -luuid"
  when "--libs"
    puts "-L#{root}/bin -L#{root}/lib -lmruby -lbismite -lmingw32 -lSDL2main -lSDL2 -mwindows -lSDL2_mixer -lSDL2_image -lopengl32 -lws2_32"
  when "--cflags"
    puts "#{DEFINES} -I#{root}/include -I#{root}/include/SDL2 -Dmain=SDL_main"
  end
end
