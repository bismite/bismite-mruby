#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET=ARGV[0]
BI_BUILDER_ROOT = Dir.pwd

BI_CORE_DIR="build/#{TARGET}/bismite-library-core"
BI_EXT_DIR="build/#{TARGET}/bismite-library-ext"

INSTALL_PATH = install_path(TARGET)
INCLUDE_PATHS = "-I #{INSTALL_PATH}/include -I #{INSTALL_PATH}/include/SDL2"
WARN = "-Wall -Werror=implicit-function-declaration"

def extract_tgz
  unless Dir.exists? BI_CORE_DIR
    mkdir_p BI_CORE_DIR
    if ENV["BI_CORE"]
      puts "bismite-core library copy from #{ENV["BI_CORE"]}"
      cp_r File.join(ENV["BI_CORE"],"/."), BI_CORE_DIR
      rm_rf "#{BI_CORE_DIR}/build"
    else
      run "tar --strip-component 1 -zxf build/download/#{TARGET}/bismite-library-core.tar.gz -C #{BI_CORE_DIR}"
    end
  end

  unless Dir.exists? BI_EXT_DIR
    mkdir_p BI_EXT_DIR
    if ENV["BI_EXT"]
      puts "bismite-ext library copy from #{ENV["BI_EXT"]}"
      cp_r File.join(ENV["BI_EXT"],"/."), BI_EXT_DIR
      rm_rf "#{BI_EXT_DIR}/build"
    else
      run "tar --strip-component 1 -zxf build/download/#{TARGET}/bismite-library-ext.tar.gz -C #{BI_EXT_DIR}"
    end
  end
end

def copy_headers(target)
  mkdir_p "#{target}/include"
  cp_r "#{BI_CORE_DIR}/include/.", "#{target}/include"
  cp_r "#{BI_EXT_DIR}/include/.", "#{target}/include"
end

def copy_lib(arch,target)
  mkdir_p "#{target}/lib"
  cp "#{BI_CORE_DIR}/build/#{arch}/libbismite-core.a", "#{target}/lib/"
  cp "#{BI_EXT_DIR}/build/#{arch}/libbismite-ext.a", "#{target}/lib/"
end

def compile(makefile,include_path,cflags)
  Dir.chdir(BI_CORE_DIR){ run "make -f #{makefile} 'INCLUDE_PATHS=#{include_path}' 'CFLAGS=#{cflags}'" }
  Dir.chdir(BI_EXT_DIR){ run "make -f #{makefile} 'INCLUDE_PATHS=#{include_path}' 'CFLAGS=#{cflags}'" }
end

#
# build bi-core and bi-ext
#

extract_tgz
copy_headers INSTALL_PATH

case TARGET
when /mingw/
  CFLAGS = "-std=c11 -O3 #{WARN} `#{INSTALL_PATH}/bin/sdl2-config --cflags`"
  compile "Makefile.mingw.mk", INCLUDE_PATHS, CFLAGS
  copy_lib "mingw", INSTALL_PATH

when /emscripten/
  CFLAGS = "-std=gnu11 -Os #{WARN} -s WASM=1 -s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS=[png] -fPIC"
  compile "Makefile.emscripten.mk", INCLUDE_PATHS, CFLAGS
  copy_lib TARGET, INSTALL_PATH

when /macos/
  CFLAGS = "-std=c11 -Os #{WARN} `#{INSTALL_PATH}/bin/sdl2-config --cflags` -fPIC -arch arm64 -arch x86_64"
  compile "Makefile.#{TARGET}.mk", INCLUDE_PATHS, CFLAGS
  copy_lib TARGET, INSTALL_PATH

when /linux/
  CFLAGS = "-std=c11 -Os #{WARN} `sdl2-config --cflags` -fPIC"
  compile "Makefile.#{TARGET}.mk", INCLUDE_PATHS, CFLAGS
  copy_lib TARGET, INSTALL_PATH
end
