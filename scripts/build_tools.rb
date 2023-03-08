#!/usr/bin/env ruby
require_relative "lib/utils"

HOST = (/linux/ === RUBY_PLATFORM ? "linux" : "macos")
TARGET = ARGV[0] || HOST

cp_r "src/tools/", "build/#{TARGET}/", remove_destination:true

# compile mruby files
Dir.chdir("build/#{TARGET}"){
  %w(bismite-asset-pack bismite-asset-unpack merger).each{|f|
    f2 = f.gsub("-","_")
    run "./mruby/build/host/mrbc/bin/mrbc -B #{f2} -o tools/#{f}.h tools/#{f}.rb"
  }
}

# compile c files
CFLAGS = "-Wall -O2 -g0 -std=gnu11"
C_FILES = %w(bismite-asset-pack bismite-asset-unpack bismite)
Dir.chdir("build/#{TARGET}"){ C_FILES.each{|f|
  case TARGET
  when /linux/
    run "clang #{CFLAGS} tools/#{f}.c -o bin/#{f} `./bin/bismite-config --cflags --static-libs` `sdl2-config --libs --cflags` -Wl,-rpath,'$ORIGIN/../lib'"
    run "strip bin/#{f}"
  when /macos/
    run "clang #{CFLAGS} tools/#{f}.c -o bin/#{f} `./bin/bismite-config --cflags --libs` -arch x86_64 -arch arm64"
    run "strip bin/#{f}"
    run "install_name_tool -add_rpath @executable_path/../lib bin/#{f}"
  when /mingw/
    run "x86_64-w64-mingw32-gcc #{CFLAGS} tools/#{f}.c -o bin/#{f} `./bin/bismite-config-mingw --cflags --libs`"
    run "x86_64-w64-mingw32-strip bin/#{f}.exe"
  when /emscripten/
    # nop
  end
}}
