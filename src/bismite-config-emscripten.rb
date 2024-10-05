#!/usr/bin/env ruby

root = File.absolute_path(File.join(File.expand_path(File.dirname($0)),".."))
DEFINES = %w(
  MRB_INT64
  MRB_UTF8_STRING
  MRB_NO_BOXING
  MRB_NO_DEFAULT_RO_DATA_P
  MRB_STR_LENGTH_MAX=0
  MRB_ARY_LENGTH_MAX=0
).map{|d| "-D#{d}" }.join(" ")

sdl = "#{root}/lib/libSDL2_image.a #{root}/lib/libSDL2_mixer.a #{root}/lib/libSDL2.a "

ARGV.each do |command|
  case command
  when "--libs"
    puts "-s USE_SDL=0 -L#{root}/lib -lmruby-static -lbismite #{sdl} -sMAX_WEBGL_VERSION=2"
  when "--cflags"
    puts "-s USE_SDL=0 #{DEFINES} -I#{root}/include -I#{root}/include/SDL2"
  end
end
