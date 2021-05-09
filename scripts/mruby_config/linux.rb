require 'rbconfig'
require_relative "common.rb"

HOST="linux"

MRuby::Build.new do |conf|
  toolchain :clang
end

MRuby::CrossBuild.new('linux') do |conf|
  toolchain :clang

  include_gems conf

  conf.cc do |cc|
    cc.command = 'clang'
    cc.defines += %w(MRB_INT64 MRB_UTF8_STRING MRB_NO_BOXING)
    cc.include_paths << "#{BUILD_DIR}/#{HOST}/include"
    cc.include_paths << "#{BUILD_DIR}/#{HOST}/include/SDL2"
    cc.include_paths << "#{BUILD_DIR}/#{HOST}/msgpack-c/include"
    cc.flags = %W( -Os -std=gnu11 -DNDEBUG -Wall -Werror-implicit-function-declaration -Wwrite-strings)
    cc.flags << "`sdl2-config --cflags`"
    cc.flags << "-fPIC"
  end

  conf.linker do |linker|
    linker.command = 'clang'
    linker.library_paths << "#{BUILD_DIR}/#{HOST}/lib"
    linker.libraries += %W( bismite-core bismite-ext SDL2 SDL2_image SDL2_mixer GL msgpackc yaml )
    linker.flags << "-Wl,-rpath,'$ORIGIN/../lib'"
  end
end
