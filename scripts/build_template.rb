#!/usr/bin/env ruby
#
# usage: build_template.rb {linux|macos|emscripten|x86_64-w64-mingw32} [path/to/output]
#
require_relative "lib/utils"

HOST = (/linux/ === RUBY_PLATFORM ? "linux" : "macos")
TARGET = ARGV[0] || HOST
DST_DIR = ARGV[1] || "build/#{TARGET}/share/bismite/templates"

MINGW_DLLS = %w(
  libmpg123-0.dll
  libpng16-16.dll
  SDL2.dll
  SDL2_image.dll
  SDL2_mixer.dll
  zlib1.dll
)

run "./build/#{TARGET}/mruby-3.0.0/build/host/mrbc/bin/mrbc -o build/main.mrb src/main.rb"

def copy_license_files(target,dir)
  mkdir_p dir
  cp_r "build/#{target}/licenses", dir
end

case TARGET
when /linux/
  mkdir_p "#{DST_DIR}/linux/lib"
  cp "build/main.mrb", "#{DST_DIR}/linux/main.mrb"
  run "clang src/main.c -o #{DST_DIR}/linux/main -std=gnu11 -Os -Wall -DNDEBUG `./build/linux/bin/bismite-config.rb --cflags --libs` `sdl2-config --cflags --libs` -lSDL2_image -lSDL2_mixer -Wl,-rpath,'$ORIGIN/lib'"

  libs = %w( libmsgpackc.so libmsgpackc.so.2 libmsgpackc.so.2.0.0 )
  libs_origin = libs.map{|l| "build/linux/lib/#{l}" }
  cp libs_origin, "#{DST_DIR}/linux/lib/"

  copy_license_files "linux", "#{DST_DIR}/linux"

when /macos/
  mkdir_p "#{DST_DIR}/macos"
  cp_r "src/template.app", "#{DST_DIR}/macos/"
  resource_dir = "#{DST_DIR}/macos/template.app/Contents/Resources"
  mkdir_p "#{resource_dir}/bin"
  mkdir_p "#{resource_dir}/lib"
  cp "build/main.mrb", "#{resource_dir}/main.mrb"
  run "clang src/main.c -o #{resource_dir}/main `./build/macos/bin/bismite-config.rb --cflags --libs` -arch x86_64 -arch arm64"
  run "install_name_tool -add_rpath @executable_path/lib #{resource_dir}/main"

  libs = %w(
    libSDL2-2.0.0.dylib
    libSDL2_image-2.0.0.dylib
    libSDL2_mixer-2.0.0.dylib
    libmpg123.0.dylib
  )
  libs_origin = libs.map{|l| "build/macos/lib/#{l}" }
  cp libs_origin, "#{resource_dir}/lib"

  copy_license_files "macos", "#{DST_DIR}/macos/"

when /mingw/
  mkdir_p "#{DST_DIR}/x86_64-w64-mingw32"
  cp "build/main.mrb", "#{DST_DIR}/x86_64-w64-mingw32/main.mrb"
  run "x86_64-w64-mingw32-gcc src/main.c -Wall -std=c11 -Os -o #{DST_DIR}/x86_64-w64-mingw32/main.exe `./build/x86_64-w64-mingw32/bin/bismite-config-mingw.rb --cflags --libs`"
  libs = MINGW_DLLS.map{|l| "build/x86_64-w64-mingw32/bin/#{l}" }
  cp libs, "#{DST_DIR}/x86_64-w64-mingw32/"
  copy_license_files "x86_64-w64-mingw32", "#{DST_DIR}/x86_64-w64-mingw32/"

when /emscripten/
  options = {
    "wasm" => "-s WASM=1",
    "js" => "-s WASM=0",
    "wasm-dl" => "-s WASM=1 -s MAIN_MODULE=1",
  }
  %w(wasm js wasm-dl).each{|t|
    mkdir_p "#{DST_DIR}/#{t}"
    cp "build/main.mrb", "#{DST_DIR}/#{t}/main.mrb"
    flags = "-std=gnu11 -DNDEBUG -Oz -Wall -s ALLOW_MEMORY_GROWTH=1 -s INITIAL_MEMORY=128MB -s MAXIMUM_MEMORY=1024MB #{options[t]}"
    shell="--shell-file src/shell/shell_bisdk.html"
    run "emcc src/main-emscripten.c src/support-emscripten.c -o #{DST_DIR}/#{t}/index.html #{flags} `build/emscripten/bin/bismite-config-emscripten.rb --cflags --libs` #{shell}"
    copy_license_files "emscripten", "#{DST_DIR}/#{t}/"
    # Remove unexpected file path contained in SDL.
    empath = File.dirname which "emcc"
    secret = "*" * empath.size
    Dir.chdir("#{DST_DIR}/#{t}"){
      # for portability reason, sed's -i option is not appropriate...
      Dir["*"].each{|f| run "LC_ALL=C sed -e 's@#{empath}@#{secret}@' #{f} > #{f}.tmp && mv #{f}.tmp #{f}" if File.file? f }
    }
  }
end
