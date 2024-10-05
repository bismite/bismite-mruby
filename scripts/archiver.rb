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
SDL_LIBS = %w(SDL2 SDL2_image SDL2_mixer)

# ignore libmruby_core
unless TARGET.end_with? "libmruby.a"
  puts "ignore #{TARGET}".yellow
  exit
end

def make_shared(command,libname,opts)
  run "#{command} -shared -o #{libname} #{opts}"
end

def make_static(command)
  static_name = TARGET.gsub "libmruby.a", "libmruby-static.a"
  run "#{command} rcs #{static_name} #{OBJS}"
end

case ARCH
when "macos"
  libname = TARGET.gsub ".a", ".dylib"
  libpath = "-L#{BUILD_DIR}/macos/lib"
  libs = SDL_LIBS.map{|l| "-l#{l}" }.join(" ") + " -framework OpenGL"
  make_shared "clang", libname, "-arch arm64 #{libpath} #{libs} #{OBJS} -lbismite"
  run  "install_name_tool -id @rpath/libmruby.dylib #{libname}"
  make_static "ar"
when "linux"
  libname = TARGET.gsub ".a", ".so"
  libpath = "-L#{BUILD_DIR}/linux/lib"
  libs = (SDL_LIBS+["GL"]).map{|l| "-l#{l}" }.join(" ")
  make_shared "clang", libname, "#{libpath} #{libs} #{OBJS} -lbismite"
  make_static "ar"
when "mingw"
  libname = TARGET.gsub ".a", ".dll"
  libpath = "-L#{BUILD_DIR}/mingw/bin -L#{BUILD_DIR}/mingw/lib"
  libs = SDL_LIBS.map{|l| "-l#{l}" }.join(" ")
  static_libs = "-lbismite -lopengl32 -lws2_32 -static-libgcc"
  make_shared "x86_64-w64-mingw32-gcc", libname, "#{libpath} #{libs} #{OBJS} #{static_libs}"
  make_static "x86_64-w64-mingw32-ar"
when "emscripten"
  # no shared lib
  make_static "emar"
end
