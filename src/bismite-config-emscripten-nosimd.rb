#!/usr/bin/env ruby

root = File.absolute_path(File.join(File.expand_path(File.dirname($0)),".."))
DEFINES = %w(MRB_INT64 MRB_UTF8_STRING MRB_NO_BOXING MRB_NO_DEFAULT_RO_DATA_P).map{|d| "-D#{d}" }.join(" ")

ARGV.each do |command|
  case command
  when "--libs"
    puts "-L#{root}/lib -lmruby -lbismite-nosimd -sMAX_WEBGL_VERSION=2"
  when "--cflags"
    puts "#{DEFINES} -I#{root}/include"
  end
end

if ARGV.include?("--libs") or ARGV.include?("--cflags")
  puts "-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS=[png]"
end
