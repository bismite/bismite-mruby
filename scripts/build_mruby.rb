#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV[0]
PREFIX = install_path(TARGET)

# Build mruby
ENV["MRUBY_CONFIG"] = "#{Dir.pwd}/mruby_config/#{TARGET}.rb"
rm_f ENV["MRUBY_CONFIG"]+".lock"
Dir.chdir("build/#{TARGET}/mruby"){ run "rake -v" }

# ---- Install ----

puts "mruby install to build/#{TARGET}".yellow

def install_macos
  cp_r "mruby/build/#{TARGET}/bin/.", "#{PREFIX}/bin/" rescue nil
  cp_r "mruby/build/#{TARGET}/include/.", "#{PREFIX}/include/" rescue nil
  cp "mruby/build/#{TARGET}/lib/libmruby.dylib", "#{PREFIX}/lib/libmruby.dylib"
  cp "mruby/build/#{TARGET}/lib/libmruby-static.a", "#{PREFIX}/lib/libmruby-static.a"
  %w(mirb mrbc mruby mruby-strip).each{|bin|
    cp "mruby/build/#{TARGET}/bin/#{bin}", "#{PREFIX}/bin/#{bin}"
    run "install_name_tool -add_rpath @executable_path/../lib #{PREFIX}/bin/#{bin}"
  }
end

def install_emscripten
  from = "mruby/build/#{TARGET}"
  to = "#{PREFIX}"
  mkdir_p "#{to}/include"
  mkdir_p "#{to}/lib"
  cp_r "#{from}/include/.", "#{to}/include/" rescue nil # presym headers
  cp_r "#{from}/lib/.", "#{to}/lib/"
end

Dir.chdir("build/#{TARGET}"){
  %w(bin include lib).each{|d| mkdir_p d }
  cp_r "mruby/include/.", "#{PREFIX}/include/"
  case TARGET
  when "macos", "macos"
    install_macos
  when 'emscripten'
    install_emscripten
  else
    cp_r "mruby/build/#{TARGET}/bin/.", "#{PREFIX}/bin/" rescue nil
    cp_r "mruby/build/#{TARGET}/include/.", "#{PREFIX}/include/" rescue nil # presym headers
    if /linux/ === TARGET
      cp "mruby/build/#{TARGET}/lib/libmruby.so", "#{PREFIX}/lib/libmruby.so"
      cp "mruby/build/#{TARGET}/lib/libmruby-static.a", "#{PREFIX}/lib/libmruby-static.a"
    elsif /mingw/ === TARGET
      cp "mruby/build/#{TARGET}/lib/libmruby.dll", "#{PREFIX}/bin/libmruby.dll"
      cp "mruby/build/#{TARGET}/lib/libmruby-static.a", "#{PREFIX}/lib/libmruby-static.a"
    else
      cp_r "mruby/build/#{TARGET}/lib/.", "#{PREFIX}/lib/"
    end
  end
}
