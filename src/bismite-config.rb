#!/usr/bin/env ruby

root = File.absolute_path(File.join(File.expand_path(File.dirname($0)),".."))

STATIC_LIBS = %w(mruby bismite-core bismite-ext SDL2 SDL2_mixer SDL2_image mpg123).map{|l| "#{root}/lib/lib#{l}.a" }.join(" ")

if /Darwin/ === `uname -a` # macos
  ARGV.each do |command|
    case command
    when "--libs"
      puts "-L#{root}/lib -lmruby -lbismite-core -lbismite-ext -lSDL2 -lSDL2_mixer -lSDL2_image -lmsgpackc -lyaml -framework OpenGL"
    when "--static-libs"
      puts "-L#{root}/lib #{STATIC_LIBS} -liconv -lm -framework OpenGL -Wl,-framework,CoreAudio -Wl,-framework,AudioToolbox -Wl,-weak_framework,CoreHaptics -Wl,-weak_framework,GameController -Wl,-framework,ForceFeedback -lobjc -Wl,-framework,CoreVideo -Wl,-framework,Cocoa -Wl,-framework,Carbon -Wl,-framework,IOKit -Wl,-weak_framework,QuartzCore -Wl,-weak_framework,Metal"
    when "--cflags"
      puts "-DMRB_INT64 -DMRB_UTF8_STRING -DMRB_NO_BOXING -I#{root}/include -I#{root}/include/SDL2 -D_THREAD_SAFE"
    end
  end
else # linux
  ARGV.each do |command|
    case command
    when "--libs"
      puts "-L#{root}/lib -lmruby -lbismite-core -lbismite-ext -lm -lGL -ldl -lmsgpackc"
    when "--cflags"
      puts "-DMRB_INT64 -DMRB_UTF8_STRING -DMRB_NO_BOXING -I#{root}/include"
    end
  end
end
