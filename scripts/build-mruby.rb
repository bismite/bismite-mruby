#!/usr/bin/env ruby
require_relative "utils"

TARGET = ARGV[0]
PREFIX = install_path(TARGET)
BINARIES = %w(mruby mrbc mirb mruby-strip)

STATIC_LIB = "libmruby-static.a"
case TARGET
when "macos"
  SHARED_LIB = "libmruby.dylib"
when "linux"
  SHARED_LIB = "libmruby.so"
when "mingw"
  SHARED_LIB = "libmruby.dll"
end

# Build mruby
ENV["MRUBY_CONFIG"] = "#{Dir.pwd}/mruby_config/#{TARGET}.rb"
rm_f ENV["MRUBY_CONFIG"]+".lock"
Dir.chdir("build/#{TARGET}/mruby"){ run "rake -v" }

# ---- Install ----

puts "mruby install to build/#{TARGET}".yellow

def copy_bins(target,ext="")
  BINARIES.each{|b| cp "mruby/build/#{target}/bin/#{b}#{ext}", "bin/bismite-#{b}#{ext}" }
end

def install_macos
  copy_bins TARGET
  cp "mruby/build/#{TARGET}/lib/libmruby.dylib", "#{PREFIX}/lib/libmruby.dylib"
  cp "mruby/build/#{TARGET}/lib/libmruby-static.a", "#{PREFIX}/lib/libmruby-static.a"
  BINARIES.each{|bin|
    run "install_name_tool -add_rpath @executable_path/../lib bin/bismite-#{bin}"
  }
end

def install_emscripten
  cp_r "mruby/build/#{TARGET}/lib", "./"
end

Dir.chdir(PREFIX){
  %w(bin include lib).each{|d| mkdir_p d }
  cp_r "mruby/include", "./"
  cp_r "mruby/build/#{TARGET}/include", "./"
  case TARGET
  when "macos", "macos"
    install_macos
  when 'emscripten'
    install_emscripten
  when 'linux' || 'mingw'
    cp_r "mruby/build/#{TARGET}/include", "./"
    if "linux" == TARGET
      copy_bins TARGET
      cp "mruby/build/#{TARGET}/lib/libmruby.so", "lib/libmruby.so"
      cp "mruby/build/#{TARGET}/lib/libmruby-static.a", "lib/libmruby-static.a"
    elsif "mingw" == TARGET
      copy_bins TARGET, ".exe"
      cp "mruby/build/#{TARGET}/lib/libmruby.dll", "bin/libmruby.dll"
      cp "mruby/build/#{TARGET}/lib/libmruby-static.a", "lib/libmruby-static.a"
    else
      cp_r "mruby/build/#{TARGET}/lib", "./"
    end
  end
}
