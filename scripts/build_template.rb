#!/usr/bin/env ruby
#
# usage: build_template.rb {linux|macos|emscripten|x86_64-w64-mingw32} [path/to/output]
#
require_relative "lib/utils"

HOST = (/linux/ === RUBY_PLATFORM ? "linux" : "macos")
TARGET = ARGV[0] || HOST
DST_DIR = ARGV[1] || "build/#{TARGET}/share/bismite/templates"
OPT="-std=gnu11 -O3 -Wall -DNDEBUG"

run "./build/#{TARGET}/mruby/build/host/mrbc/bin/mrbc -o build/main.mrb src/main.rb"

def copy_license_files(target,dir)
  mkdir_p dir
  cp_r "build/#{target}/licenses", dir
end

def emscripten(simd=:simd)
  if simd==:nosimd
    build_dir = "build/emscripten-nosimd"
    config_script = "#{build_dir}/bin/bismite-config-emscripten-nosimd"
  else
    build_dir = "build/emscripten"
    config_script = "#{build_dir}/bin/bismite-config-emscripten"
  end
  [nil,"dl"].each{|dynamic_linking| [nil,"single"].each{|single_file|
    name = "wasm"
    opt = ""
    config = "`#{config_script} --cflags --libs`"
    if dynamic_linking
      name += "-dl"
      opt += " -sMAIN_MODULE=1"
    end
    if single_file
      name += "-single"
      opt += " -sSINGLE_FILE=1"
    end
    puts "build template #{name}"
    dir = File.join DST_DIR,name
    mkdir_p dir
    cp "build/main.mrb", "#{dir}/main.mrb"
    flags = "#{OPT} -s ALLOW_MEMORY_GROWTH=1 -s INITIAL_MEMORY=128MB -s MAXIMUM_MEMORY=1024MB -sWASM=1 #{opt}"
    shell="--shell-file src/shell/shell_bisdk.html"
    run "emcc src/main-emscripten.c src/support-emscripten.c -o #{dir}/index.html #{flags} #{config} #{shell}"
    copy_license_files "emscripten", dir
    # Remove unexpected file path contained in SDL.
    empath = File.dirname which "emcc"
    secret = "*" * empath.size
    Dir.chdir(dir){
      # for portability reason, sed's -i option is not appropriate...
      Dir["*"].each{|f| run "LC_ALL=C sed -e 's@#{empath}@#{secret}@' #{f} > #{f}.tmp && mv #{f}.tmp #{f}" if File.file? f }
    }
  }}
end

case TARGET
when "linux"
  mkdir_p "#{DST_DIR}/linux/lib"
  cp "build/main.mrb", "#{DST_DIR}/linux/main.mrb"
  run "clang src/main.c -o #{DST_DIR}/linux/main #{OPT} `./build/linux/bin/bismite-config --cflags --libs` `sdl2-config --cflags --libs` -lSDL2_image -lSDL2_mixer -Wl,-rpath,'$ORIGIN/lib'"

  %w(libmruby.so).each{|l|
    copy_entry "build/linux/lib/#{l}", "#{DST_DIR}/linux/lib/#{l}",false,false,true
  }

  copy_license_files "linux", "#{DST_DIR}/linux"

when "macos"
  mkdir_p "#{DST_DIR}/macos"
  cp_r "src/template.app", "#{DST_DIR}/macos/"
  resource_dir = "#{DST_DIR}/macos/template.app/Contents/Resources"
  mkdir_p "#{resource_dir}/bin"
  mkdir_p "#{resource_dir}/lib"
  cp "build/main.mrb", "#{resource_dir}/main.mrb"
  run "clang src/main.c -o #{resource_dir}/main `./build/macos/bin/bismite-config --cflags --libs` -arch x86_64 -arch arm64 #{OPT}"
  run "install_name_tool -add_rpath @executable_path/lib #{resource_dir}/main"

  libs = %w(
    libmruby.dylib
    libSDL2-2.0.0.dylib
    libSDL2_image-2.0.0.dylib
    libSDL2_mixer-2.0.0.dylib
  )
  libs_origin = libs.map{|l| "build/macos/lib/#{l}" }
  cp libs_origin, "#{resource_dir}/lib"

  copy_license_files "macos", "#{DST_DIR}/macos/"

when "mingw"
  mkdir_p "#{DST_DIR}/mingw/system"
  cp "build/main.mrb", "#{DST_DIR}/mingw/system/main.mrb"
  # real main.exe
  run "x86_64-w64-mingw32-gcc src/main.c -o #{DST_DIR}/mingw/system/main.exe `./build/mingw/bin/bismite-config-mingw --cflags --libs` #{OPT}"
  # copy dlls
  cp Dir.glob('build/mingw/bin/*.dll'), "#{DST_DIR}/mingw/system"
  # frontman
  run "x86_64-w64-mingw32-windres src/frontman-mingw.rc -O coff -o build/mingw/frontman-mingw.res"
  run "x86_64-w64-mingw32-gcc src/frontman-mingw.c build/mingw/frontman-mingw.res -std=c11 -O2 -mwindows -o #{DST_DIR}/mingw/start.exe"
  copy_license_files "mingw", "#{DST_DIR}/mingw/"

when "emscripten"
  emscripten :simd
when "emscripten-nosimd"
  emscripten :nosimd
end
