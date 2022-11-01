#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV[0]
ENV["MRUBY_CONFIG"] = "#{Dir.pwd}/scripts/mruby_config/#{TARGET}.rb"
PREFIX = install_path(TARGET)

# ---- Build ----

Dir.chdir("build/#{TARGET}/mruby"){
  run "rake MRUBY_YAML_USE_SYSTEM_LIBRARY=true"
}

# ---- Install ----

def macos
  run "lipo -create mruby/build/macos-x86_64/lib/libmruby.dylib mruby/build/macos-arm64/lib/libmruby.dylib -output #{PREFIX}/lib/libmruby.dylib"
  run "lipo -create mruby/build/macos-x86_64/lib/libmruby-static.a mruby/build/macos-arm64/lib/libmruby-static.a -output #{PREFIX}/lib/libmruby-static.a"
  %w(mirb mrbc mruby mruby-strip).each{|bin|
    run "lipo -create mruby/build/macos-x86_64/bin/#{bin} mruby/build/macos-arm64/bin/#{bin} -output #{PREFIX}/bin/#{bin}"
    run "install_name_tool -add_rpath @executable_path/../lib #{PREFIX}/bin/#{bin}"
  }
  cp_r "mruby/build/macos-x86_64/include/.", "#{PREFIX}/include/" rescue nil # presym headers
end

def emscripten
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
  when 'macos'
    macos
  when 'emscripten'
    emscripten
  when 'emscripten-nosimd'
    emscripten
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
