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
  puts "archiver.rb: #{cmd}".yellow
  system cmd
  unless $?.success?
    puts "archiver.rb: failed #{cmd}".red
    exit 1
  end
end

ARCH = ARGV.shift
TARGET = ARGV.shift
OBJS = ARGV.join(" ")

BUILD_DIR = File.expand_path File.join __dir__,"..","build"
COMMON_LIBS = %w(SDL2 SDL2_image SDL2_mixer bismite)

exit unless TARGET.end_with? "libmruby.a"

def make_shared(command,libname,paths,libs,flags)
  run "#{command} -shared -o #{libname} #{paths} #{libs} #{flags} #{OBJS}"
end

def make_static(command)
  static_name = TARGET.gsub "libmruby.a", "libmruby-static.a"
  run "#{command} rcs #{static_name} #{OBJS}"
end

case ARCH
when "macos"
  libpath = "-L#{BUILD_DIR}/macos/lib"
  libs = COMMON_LIBS.map{|l| "-l#{l}" }.join(" ")
  flags = "-framework OpenGL -arch arm64"
  libname = TARGET.gsub ".a", ".dylib"
  make_shared "clang", libname, libpath, libs, flags
  run  "install_name_tool -id @rpath/libmruby.dylib #{libname}"
  make_static "ar"
when "linux"
  libpath = "-L#{BUILD_DIR}/linux/lib"
  libs = (COMMON_LIBS+["GL"]).map{|l| "-l#{l}" }.join(" ")
  flags = "-flto"
  libname = TARGET.gsub ".a", ".so"
  make_shared "clang", libname, libpath, libs, flags
  make_static "ar"
when "mingw"
  libpath = "-L#{BUILD_DIR}/mingw/bin -L#{BUILD_DIR}/mingw/lib"
  libs = (COMMON_LIBS+["opengl32","ws2_32"]).map{|l| "-l#{l}" }.join(" ")
  flags = "-static-libgcc"
  libname = TARGET.gsub ".a", ".dll"
  make_shared "x86_64-w64-mingw32-gcc", libname, libpath, libs, flags
  make_static "x86_64-w64-mingw32-ar"
when "emscripten"
  make_static "emar"
end
