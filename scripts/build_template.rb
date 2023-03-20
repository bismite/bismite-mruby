#!/usr/bin/env ruby
#
# usage: build_template.rb {linux|macos|emscripten|x86_64-w64-mingw32} [path/to/output]
#
require_relative "lib/utils"

host = nil
host = "linux" if /linux/ === RUBY_PLATFORM
if /darwin/ === RUBY_PLATFORM
  if /arm64/ === RUBY_PLATFORM
    host = "macos-arm64"
  else
    host = "macos-x86_64"
  end
end

TARGET = ARGV[0] || host
DST_DIR = ARGV[1] || "build/#{TARGET}/share/bismite/templates"
PREFIX="build/#{TARGET}"
OPT="-std=gnu11 -O3 -g0 -Wall -DNDEBUG"

run "./#{PREFIX}/mruby/build/host/mrbc/bin/mrbc -o build/main.mrb src/main.rb"

def copy_license_files(target,dir)
  mkdir_p dir
  cp_r "#{PREFIX}/licenses", dir
end

def emscripten(simd=:simd)
  config_script = "#{PREFIX}/bin/bismite-config-emscripten-nosimd"

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
  mkdir_p "#{PREFIX}/lib"
  cp "build/main.mrb", "#{PREFIX}/main.mrb"
  sdl_flags = "-I build/#{TARGET}/include/SDL2 -lSDL2 -lSDL2_image -lSDL2_mixer"
  run "clang src/main.c -o #{DST_DIR}/linux/main #{OPT} `./build/linux/bin/bismite-config --cflags --libs` #{sdl_flags} -Wl,-rpath,'$ORIGIN/lib'"

  %w(libmruby.so).each{|l|
    copy_entry "build/linux/lib/#{l}", "#{DST_DIR}/linux/lib/#{l}",false,false,true
  }
  copy_license_files "linux", "#{DST_DIR}/linux"

when /macos/
  arch = TARGET.split("-").last
  mkdir_p "#{DST_DIR}/macos-#{arch}"
  cp_r "src/template.app", "#{DST_DIR}/macos-#{arch}/"
  resource_dir = "#{DST_DIR}/macos-#{arch}/template.app/Contents/Resources"
  mkdir_p "#{resource_dir}/bin"
  mkdir_p "#{resource_dir}/lib"
  cp "build/main.mrb", "#{resource_dir}/main.mrb"
  run "clang src/main.c -o #{resource_dir}/main `./#{PREFIX}/bin/bismite-config --cflags --libs` -arch #{arch} #{OPT}"
  run "install_name_tool -add_rpath @executable_path/lib #{resource_dir}/main"
  libs = [ "#{PREFIX}/lib/libmruby.dylib" ]
  libs += %w( libSDL2.dylib libSDL2_image.dylib libSDL2_mixer.dylib ).map{|l|
    File.join( "#{PREFIX}/lib", File.readlink("#{PREFIX}/lib/#{l}") )
  }
  cp libs, "#{resource_dir}/lib"
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
