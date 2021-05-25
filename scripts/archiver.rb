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

if arch.start_with? "macos" or arch.start_with? "linux"
  if arch=="macos-arm64" or arch=="macos-x86_64"
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
    libpath = "-L#{BUILD_DIR}/linux/lib"
    libs = (COMMON_LIBS+["GL"]).map{|l| "-l#{l}" }.join(" ")
    flags = ""
    dylib = target.gsub ".a", ".so"
    additional_command = nil
  end

  if target.end_with? "libmruby.a"
    run "clang -shared -o #{dylib} #{objs} #{libpath} #{libs} #{flags}"
    run additional_command
    return
  elsif target.end_with? "libmruby_core.a"
    # nop
    return
  end
end

run "ar rs #{target} #{objs}"
