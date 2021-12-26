#!/usr/bin/env ruby
require_relative "lib/utils"

HOST = (/linux/ === RUBY_PLATFORM ? "linux" : "macos")
TARGET = ARGV[0] || HOST

cp_r "src/tools/", "build/#{TARGET}/", remove_destination:true

# C -> rb table
FILES = %w(
  bismite-asset-pack bismite-asset-pack
  bismite-asset-unpack bismite-asset-unpack
  bismite-compile bismite-compiler
  bismite-run bismite-compiler
).each_slice(2).to_a

case TARGET
when /linux/
  Dir.chdir("build/#{TARGET}"){
    FILES.each{|name,rbfile|
      run "./mruby/build/host/mrbc/bin/mrbc -B irep_data -o tools/#{name}.h tools/#{rbfile}.rb"
      run "clang -Wall -O2 -std=gnu11 tools/#{name}.c -o bin/#{name} `./bin/bismite-config --cflags --libs` `sdl2-config --libs --cflags` -Wl,-rpath,'$ORIGIN/../lib'"
      run "strip bin/#{name}"
    }
  }
when /macos/
  Dir.chdir("build/#{TARGET}"){
    FILES.each{|name,rbfile|
      run "./mruby/build/host/mrbc/bin/mrbc -B irep_data -o tools/#{name}.h tools/#{rbfile}.rb"
      run "clang -Wall -O2 -std=gnu11 tools/#{name}.c -o bin/#{name} `./bin/bismite-config --cflags --libs` -arch x86_64 -arch arm64"
      run "strip bin/#{name}"
      run "install_name_tool -add_rpath @executable_path/../lib bin/#{name}"
    }
  }
when /mingw/
  Dir.chdir("build/#{TARGET}"){
    FILES.each{|name,rbfile|
      run "./mruby/build/host/mrbc/bin/mrbc -B irep_data -o tools/#{name}.h tools/#{rbfile}.rb"
      run "x86_64-w64-mingw32-gcc -Wall -O2 -std=gnu11 tools/#{name}.c -o bin/#{name} `./bin/bismite-config-mingw --cflags --libs`"
      run "x86_64-w64-mingw32-strip bin/#{name}.exe"
    }
  }
when /emscripten/
  # nop
end
