#!/usr/bin/env ruby

def run(cmd)
  # puts cmd
  `#{cmd}`
end

arch = ARGV.shift
target = ARGV.shift
objs = ARGV.join(" ")

BUILD_DIR = File.expand_path File.join __dir__,"..","..","build"
LDPATH = "-L#{BUILD_DIR}/macos/lib"
LIBS = %w(bismite-core bismite-ext SDL2 SDL2_image SDL2_mixer msgpackc yaml).map{|l| "-l#{l}" }.join(" ")

if target.end_with? "libmruby.a"
  dylib = target.gsub ".a", ".dylib"
  run "clang -shared -o #{dylib} #{objs} #{LDPATH} #{LIBS} -framework OpenGL -arch #{arch}"
  run "install_name_tool -id @rpath/libmruby.dylib #{dylib}"
elsif target.end_with? "libmruby_core.a"
  # nop
else
  run "ar rs #{target} #{objs}"
end
