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
CFLAGS = "-Wall -O3 -g0 -std=gnu11"
C_FILES = %w(bismite-asset-pack bismite-asset-unpack bismite)
Dir.chdir("build/#{TARGET}"){ C_FILES.each{|f|
  case TARGET
  when /linux/
    sdl_flags = "-Iinclude -Iinclude/SDL2 -lSDL2 -lSDL2_image -lSDL2_mixer"
    flags = "-Wl,-rpath,'$ORIGIN/../lib'"
    run "clang #{CFLAGS} tools/#{f}.c -o bin/#{f} `./bin/bismite-config --cflags --libs` #{sdl_flags} #{flags}"
    run "strip bin/#{f}"
  when /macos/
    arch = TARGET.split("-").last
    run "clang #{CFLAGS} tools/#{f}.c -o bin/#{f} `./bin/bismite-config --cflags --libs` -arch #{arch}"
    run "strip bin/#{f}"
    run "install_name_tool -add_rpath @executable_path/../lib bin/#{f}"
  when /mingw/
    run "x86_64-w64-mingw32-gcc #{CFLAGS} tools/#{f}.c -o bin/#{f} `./bin/bismite-config-mingw --cflags --libs`"
    run "x86_64-w64-mingw32-strip bin/#{f}.exe"
  when /emscripten/
    # nop
  end
}}
