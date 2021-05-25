#!/usr/bin/env ruby

def run(cmd)
  return unless cmd
  puts cmd
  `#{cmd}`
end

arch = ARGV.shift
target = ARGV.shift
objs = ARGV.join(" ")

BUILD_DIR = File.expand_path File.join __dir__,"..","build"
COMMON_LIBS = %w(bismite-core bismite-ext SDL2 SDL2_image SDL2_mixer msgpackc yaml)


if arch=="macos-arm64" or arch=="macos-x86_64"
  command = "clang"
  libpath = "-L#{BUILD_DIR}/macos/lib"
  libs = COMMON_LIBS.map{|l| "-l#{l}" }.join(" ")
  flags = "-framework OpenGL -arch #{arch[6..-1]}"
  dylib = target.gsub ".a", ".dylib"
  if target.end_with? "libmruby.a"
    additional_command = "install_name_tool -id @rpath/libmruby.dylib #{dylib}"
  else
    additional_command = nil
  end
elsif arch=="linux"
  command = "clang"
  libpath = "-L#{BUILD_DIR}/linux/lib"
  libs = (COMMON_LIBS+["GL"]).map{|l| "-l#{l}" }.join(" ")
  flags = ""
  dylib = target.gsub ".a", ".so"
  additional_command = nil
elsif arch=="x86_64-w64-mingw32"
  command = "x86_64-w64-mingw32-gcc"
  libpath = "-L#{BUILD_DIR}/x86_64-w64-mingw32/lib -L#{BUILD_DIR}/x86_64-w64-mingw32/bin"
  libs = (COMMON_LIBS+["opengl32","ws2_32"]).map{|l| "-l#{l}" }.join(" ")
  flags = ""
  dylib = target.gsub ".a", ".dll"
  additional_command = nil
  command = "x86_64-w64-mingw32-gcc"
end

if target.end_with? "libmruby.a"
  run "#{command} -shared -o #{dylib} #{objs} #{libpath} #{libs} #{flags}"
  run additional_command
  return
elsif target.end_with? "libmruby_core.a"
  # nop
  return
end

run "ar rs #{target} #{objs}"
