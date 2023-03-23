#!/usr/bin/env ruby
#
# usage: build_template.rb {linux|macos-arm64|macos-x86_64|emscripten|emscripten-nosimd|mingw}
#
require_relative "lib/utils"

TARGET = ARGV[0]
raise "unknown target #{TARGET}" unless %w(linux macos-arm64 macos-x86_64 emscripten emscripten-nosimd mingw).include?(TARGET)
TEMPLATE_DIR = "build/#{TARGET}/share/bismite/templates"
PREFIX="build/#{TARGET}"
OPT="-std=gnu11 -O3 -g0 -Wall -DNDEBUG"

run "./#{PREFIX}/mruby/build/host/mrbc/bin/mrbc -o build/main.mrb src/main.rb"

def build_linux
  dst = "#{TEMPLATE_DIR}/linux"
  mkdir_p dst
  mkdir_p "#{PREFIX}/lib"
  cp "build/main.mrb", "#{PREFIX}/main.mrb"
  sdl_flags = "-I build/#{TARGET}/include/SDL2 -lSDL2 -lSDL2_image -lSDL2_mixer"
  bismite_config = `./build/linux/bin/bismite-config --cflags --libs`.gsub("\n"," ")
  run "clang src/main.c -o #{dst}/main #{OPT} #{bismite_config} #{sdl_flags} -Wl,-rpath,'$ORIGIN/lib'"
  mkdir_p "#{dst}/lib"
  %w(libmruby.so libSDL2_image.so libSDL2_mixer.so libSDL2.so).each{|l|
    cp "build/linux/lib/#{l}", "#{dst}/lib/"
  }
  cp_r "#{PREFIX}/licenses", dst
end

def build_macos
  arch = TARGET.split("-").last
  dst = "#{TEMPLATE_DIR}/macos-#{arch}"
  resource_dir = "#{dst}/template.app/Contents/Resources"
  mkdir_p dst
  cp_r "src/template.app", dst
  mkdir_p "#{resource_dir}/bin"
  mkdir_p "#{resource_dir}/lib"
  cp "build/main.mrb", "#{resource_dir}/main.mrb"
  bismite_config = `./#{PREFIX}/bin/bismite-config --cflags --libs`.gsub("\n"," ")
  run "clang src/main.c -o #{resource_dir}/main #{bismite_config} -arch #{arch} #{OPT}"
  run "install_name_tool -add_rpath @executable_path/lib #{resource_dir}/main"
  libs = [ "#{PREFIX}/lib/libmruby.dylib" ]
  libs += %w( libSDL2.dylib libSDL2_image.dylib libSDL2_mixer.dylib ).map{|l|
    File.join( "#{PREFIX}/lib", File.readlink("#{PREFIX}/lib/#{l}") )
  }
  cp libs, "#{resource_dir}/lib"
  cp_r "#{PREFIX}/licenses", dst
end

def build_mingw
  dst = "#{TEMPLATE_DIR}/mingw"
  mkdir_p "#{dst}/system"
  cp "build/main.mrb", "#{dst}/system/main.mrb"
  cc = "x86_64-w64-mingw32-gcc"
  windres = "x86_64-w64-mingw32-windres"
  bismite_config = `./build/mingw/bin/bismite-config-mingw --cflags --libs`.gsub("\n"," ")
  run "#{cc} src/main.c -o #{dst}/system/main.exe #{bismite_config} #{OPT}"
  cp Dir.glob('build/mingw/bin/*.dll'), "#{dst}/system"
  run "#{windres} src/frontman-mingw.rc -O coff -o #{PREFIX}/frontman-mingw.res"
  run "#{cc} src/frontman-mingw.c #{PREFIX}/frontman-mingw.res -std=c11 -O2 -mwindows -o #{dst}/start.exe"
  cp_r "#{PREFIX}/licenses", dst
end

def build_emscripten
  libs_flag = TARGET.end_with?("-nosimd") ? "--libs-nosimd" : "--libs"
  bismite_config = `./#{PREFIX}/bin/bismite-config-emscripten --cflags #{libs_flag}`.gsub("\n"," ")
  # wasm, wasm-dl, wasm-single, wasm-dl-single
  [nil,"dl"].each{|dynamic_linking| [nil,"single"].each{|single_file|
    name = "wasm"
    opt = ""
    if dynamic_linking
      name += "-dl"
      opt += " -sMAIN_MODULE=1"
    end
    if single_file
      name += "-single"
      opt += " -sSINGLE_FILE=1"
    end
    puts "build template #{name}"
    dst = File.join DST_DIR,name
    mkdir_p dst
    cp "build/main.mrb", "#{dst}/main.mrb"
    flags = "#{OPT} -s ALLOW_MEMORY_GROWTH=1 -s INITIAL_MEMORY=128MB -s MAXIMUM_MEMORY=1024MB -sWASM=1 #{opt}"
    shell="--shell-file src/shell/shell_bisdk.html"
    run "emcc src/main-emscripten.c src/support-emscripten.c -o #{dst}/index.html #{flags} #{bismite_config} #{shell}"
    cp_r "#{PREFIX}/licenses", dst
    # Remove unexpected file path contained in SDL.
    empath = File.dirname which "emcc"
    secret = "*" * empath.size
    Dir.chdir(dst){
      # for portability reason, sed's -i option is not appropriate...
      Dir["*"].each{|f| run "LC_ALL=C sed -e 's@#{empath}@#{secret}@' #{f} > #{f}.tmp && mv #{f}.tmp #{f}" if File.file? f }
    }
  }}
end

case TARGET
when "linux"
  build_linux
when /macos/
  build_macos
when "mingw"
  build_mingw
when /emscripten/
  build_emscripten
end
