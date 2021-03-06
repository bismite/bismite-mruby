#!/usr/bin/env ruby

root = File.absolute_path(File.join(File.expand_path(File.dirname($0)),".."))

MACOS_STATIC_LIBS = %w(mruby-static bismite SDL2 SDL2_mixer SDL2_image yaml msgpackc).map{|l| "#{root}/lib/lib#{l}.a" }.join(" ")
LINUX_STATIC_LIBS = %w(mruby-static bismite msgpackc).map{|l| "#{root}/lib/lib#{l}.a" }.join(" ")

if /Darwin/ === `uname -a` # macos
  ARGV.each do |command|
    case command
    when "--libs"
      puts "-L#{root}/lib -lmruby -lbismite -lSDL2 -lSDL2_mixer -lSDL2_image -lmsgpackc -lyaml -framework OpenGL"
    when "--static-libs"
      puts "-L#{root}/lib #{MACOS_STATIC_LIBS} -liconv -lm -framework OpenGL -Wl,-framework,CoreAudio -Wl,-framework,AudioToolbox -Wl,-weak_framework,CoreHaptics -Wl,-weak_framework,GameController -Wl,-framework,ForceFeedback -lobjc -Wl,-framework,CoreVideo -Wl,-framework,Cocoa -Wl,-framework,Carbon -Wl,-framework,IOKit -Wl,-weak_framework,QuartzCore -Wl,-weak_framework,Metal"
    when "--cflags"
      puts "-DMRB_INT64 -DMRB_UTF8_STRING -DMRB_NO_BOXING -I#{root}/include -I#{root}/include/SDL2 -D_THREAD_SAFE"
    end
  end
else # linux
  ARGV.each do |command|
    case command
    when "--libs"
      puts "-L#{root}/lib -lmruby -lbismite -lm -lGL -ldl -lmsgpackc -lyaml"
    when "--static-libs"
      puts "-L#{root}/lib #{LINUX_STATIC_LIBS} -lm -lGL -ldl -lyaml"
    when "--cflags"
      puts "-DMRB_INT64 -DMRB_UTF8_STRING -DMRB_NO_BOXING -I#{root}/include"
    end
  end
end
