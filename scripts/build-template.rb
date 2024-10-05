#!/usr/bin/env ruby
#
# usage: build_template.rb {linux|macos|emscripten|mingw}
#
require_relative "utils"

TARGET = ARGV[0]
unless %w(linux macos emscripten mingw).include?(TARGET)
  puts "unknown target #{TARGET}".red
  exit
end

PREFIX="build/#{TARGET}"

TEMPLATE_DIR = "#{PREFIX}/template-#{TARGET}"
mkdir_p TEMPLATE_DIR

# compile template source
MAIN_MRB = "#{PREFIX}/main.mrb"
run "build/#{TARGET}/mruby/bin/mrbc -o #{MAIN_MRB} src/main.rb"

# main exe flags
OPT="-std=gnu11 -O2 -Wall"

def build_linux
  cp MAIN_MRB, TEMPLATE_DIR
  sdl_flags = "-I build/#{TARGET}/include/SDL2 -lSDL2 -lSDL2_image -lSDL2_mixer"
  bismite_config = `./build/linux/bin/bismite-config --cflags --libs`.gsub("\n"," ")
  run "clang src/main.c -o #{TEMPLATE_DIR}/main #{OPT} #{bismite_config} #{sdl_flags} -Wl,-rpath,'$ORIGIN/lib'"
  mkdir_p "#{TEMPLATE_DIR}/lib"
  %w(libmruby.so libSDL2_image.so libSDL2_mixer.so libSDL2.so).each{|l|
    cp "build/linux/lib/#{l}", "#{TEMPLATE_DIR}/lib/"
  }
  cp_r "#{PREFIX}/licenses", TEMPLATE_DIR
end

def build_macos
  cp_r "src/template.app", TEMPLATE_DIR
  resource_dir = "#{TEMPLATE_DIR}/template.app/Contents/Resources"
  mkdir_p File.join resource_dir,"bin"
  mkdir_p File.join resource_dir,"lib"
  cp MAIN_MRB, "#{resource_dir}"
  bismite_config = `./#{PREFIX}/bin/bismite-config --cflags --libs`.gsub("\n"," ")
  run "clang src/main.c -o #{resource_dir}/main #{bismite_config} -arch arm64 #{OPT}"
  run "install_name_tool -add_rpath @executable_path/lib #{resource_dir}/main"
  libs = [ "#{PREFIX}/lib/libmruby.dylib" ]
  libs += %w( libSDL2.dylib libSDL2_image.dylib libSDL2_mixer.dylib ).map{|l|
    File.join( "#{PREFIX}/lib", l )
  }
  cp libs, "#{resource_dir}/lib"
  cp_r "#{PREFIX}/licenses", TEMPLATE_DIR
end

def build_mingw
  mkdir_p "#{TEMPLATE_DIR}/system"
  cp MAIN_MRB, "#{TEMPLATE_DIR}/system/main.mrb"
  cc = "x86_64-w64-mingw32-gcc"
  windres = "x86_64-w64-mingw32-windres"
  bismite_config = `./build/mingw/bin/bismite-config-mingw --cflags --libs`.gsub("\n"," ")
  run "#{cc} src/main.c -o #{TEMPLATE_DIR}/system/main.exe #{bismite_config} #{OPT}"
  cp Dir.glob('build/mingw/bin/*.dll'), "#{TEMPLATE_DIR}/system"
  run "#{windres} src/frontman-mingw.rc -O coff -o #{PREFIX}/frontman-mingw.res"
  run "#{cc} src/frontman-mingw.c #{PREFIX}/frontman-mingw.res -std=c11 -O2 -mwindows -o #{TEMPLATE_DIR}/start.exe"
  cp_r "#{PREFIX}/licenses", TEMPLATE_DIR
end

def build_emscripten
  bismite_config = `./#{PREFIX}/bin/bismite-config-emscripten --cflags --libs`.gsub("\n"," ")
  # %w(wasm wasm-dl wasm-single wasm-dl-single).each{|name|
  %w(wasm-single).each{|name|
    p name
    opt=""
    opt+=" -sMAIN_MODULE=1" if /-dl/ === name
    opt+=" -sSINGLE_FILE=1" if /-single/ === name
    puts "build template #{name}"
    dst = File.join TEMPLATE_DIR,name
    mkdir_p dst
    cp MAIN_MRB, "#{dst}/main.mrb"
    flags = "#{OPT} -s ALLOW_MEMORY_GROWTH=1 -s INITIAL_MEMORY=128MB -s MAXIMUM_MEMORY=1024MB -sWASM=1 #{opt}"
    shell="--shell-file src/shell.html"
    run "emcc src/main-emscripten.c -o #{dst}/index.html #{flags} #{bismite_config} #{shell}"
    cp_r "#{PREFIX}/licenses", dst
  }
end

case TARGET
when "linux"
  build_linux
when "macos"
  build_macos
when "mingw"
  build_mingw
when "emscripten"
  build_emscripten
end
