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

def copy_bins(ext="")
  BINARIES.each{|b| cp "mruby/build/#{TARGET}/bin/#{b}#{ext}", "bin/bismite-#{b}#{ext}" }
end

def copy_libs(ext=nil)
  cp "mruby/build/#{TARGET}/lib/libmruby-static.a", "#{PREFIX}/lib/libmruby-static.a"
  cp "mruby/build/#{TARGET}/lib/libmruby#{ext}", "#{PREFIX}/lib/libmruby#{ext}" if ext
end

Dir.chdir(PREFIX){
  %w(bin include lib).each{|d| mkdir_p d }
  cp_r "mruby/include", "./"
  cp_r "mruby/build/#{TARGET}/include", "./"
  case TARGET
  when "macos"
    copy_bins
    copy_libs ".dylib"
    BINARIES.each{|bin|
      run "install_name_tool -add_rpath @executable_path/../lib bin/bismite-#{bin}"
    }
  when 'emscripten'
    copy_libs
  when 'linux'
    copy_bins
    copy_libs ".so"
  when "mingw"
    copy_bins ".exe"
    copy_libs ".dll"
  end
}
