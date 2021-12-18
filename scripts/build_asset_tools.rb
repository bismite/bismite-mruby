#!/usr/bin/env ruby
require_relative "lib/utils"

HOST = (/linux/ === RUBY_PLATFORM ? "linux" : "macos")
TARGET = ARGV[0] || HOST

mkdir_p "build/#{TARGET}/tool/"
cp "src/bismite-asset-pack.rb", "build/#{TARGET}/tool/"
cp "src/bismite-asset-unpack.rb", "build/#{TARGET}/tool/"
cp "src/bismite-asset-tool.c", "build/#{TARGET}/tool/"

case TARGET
when /linux/
  Dir.chdir("build/#{TARGET}"){
    %w(bismite-asset-pack bismite-asset-unpack).each{|name|
      run "./mruby/build/host/mrbc/bin/mrbc -B tool -o tool/tool.h tool/#{name}.rb"
      run "clang tool/bismite-asset-tool.c -o bin/#{name} `./bin/bismite-config --cflags --libs` `sdl2-config --libs --cflags` -Wl,-rpath,'$ORIGIN/../lib'"
    }
  }
when /macos/
  Dir.chdir("build/#{TARGET}"){
    %w(bismite-asset-pack bismite-asset-unpack).each{|name|
      run "./mruby/build/host/mrbc/bin/mrbc -B tool -o tool/tool.h tool/#{name}.rb"
      run "clang tool/bismite-asset-tool.c -o bin/#{name} `./bin/bismite-config --cflags --libs` -arch x86_64 -arch arm64"
      run "install_name_tool -add_rpath @executable_path/../lib bin/#{name}"
    }
  }
when /mingw/
  Dir.chdir("build/#{TARGET}"){
    %w(bismite-asset-pack bismite-asset-unpack).each{|name|
      run "./mruby/build/host/mrbc/bin/mrbc -B tool -o tool/tool.h tool/#{name}.rb"
      run "x86_64-w64-mingw32-gcc tool/bismite-asset-tool.c -o bin/#{name} `./bin/bismite-config-mingw --cflags --libs`"
    }
  }
when /emscripten/
  # nop
end
