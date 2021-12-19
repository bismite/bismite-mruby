#!/usr/bin/env ruby

begin
  require "colorize"
rescue LoadError
  String.class_eval do
    alias :yellow :to_s
    alias :red :to_s
    alias :green :to_s
  end
end

def run(cmd)
  return unless cmd
  puts "#{cmd}".yellow
  system cmd
  unless $?.success?
    puts "failed #{cmd}".red
    exit 1
  end
end


arch = ARGV.shift
target = ARGV.shift
objs = ARGV.join(" ")

BUILD_DIR = File.expand_path File.join __dir__,"..","build"
COMMON_LIBS = %w(SDL2 SDL2_image SDL2_mixer msgpackc yaml bismite)


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
  libpath = "-L#{BUILD_DIR}/mingw/bin -L#{BUILD_DIR}/mingw/lib"
  libs = (COMMON_LIBS+["opengl32","ws2_32"]).map{|l| "-l#{l}" }.join(" ")
  flags = ""
  dylib = target.gsub ".a", ".dll"
  additional_command = nil
end

if target.end_with? "libmruby.a"
  run "#{command} -shared -o #{dylib} #{objs} #{libpath} #{libs} #{flags}"
  run additional_command
  # create static file
  static_name = target.gsub ".a", "-static.a"
  run "ar rcs #{static_name} #{objs}"
  return
elsif target.end_with? "libmruby_core.a"
  # nop
  return
end
