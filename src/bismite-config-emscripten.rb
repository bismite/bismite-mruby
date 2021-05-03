#!/usr/bin/env ruby

root = File.absolute_path(File.join(File.expand_path(File.dirname($0)),".."))

STATIC_LIBS = %w(mruby bismite-core bismite-ext).map{|l| "#{root}/lib/lib#{l}.a" }.join(" ")

ARGV.each do |command|
  case command
  when "--libs"
    puts "-L#{root}/lib -lmruby -lbismite-core -lbismite-ext"
  when "--cflags"
    puts "-DMRB_INT64 -DMRB_UTF8_STRING -DMRB_NO_BOXING -I#{root}/include"
  end
end

if ARGV.include?("--libs") or ARGV.include?("--cflags")
  puts "-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS=[png]"
end
