require 'rbconfig'
require_relative "common.rb"

MRuby::Build.new do |conf|
  toolchain :clang
end

MRuby::CrossBuild.new('emscripten') do |conf|
  toolchain :clang

  include_gems(conf)

  emscripten_flags = %W(-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS='["png"]' -s MAIN_MODULE=1 -fPIC)

  conf.cc do |cc|
    cc.command = 'emcc'
    cc.defines += %w(MRB_INT64 MRB_UTF8_STRING MRB_NO_BOXING)
    cc.include_paths << "#{BUILD_DIR}/emscripten/include"
    cc.include_paths << "#{BUILD_DIR}/emscripten/msgpack-c/include"
    cc.include_paths << "#{BUILD_DIR}/emscripten/libyaml-0.2.5-emscripten/include"
    cc.flags = %w(-Oz -std=gnu11 -DNDEBUG -Wall -Werror-implicit-function-declaration -Wwrite-strings)
    cc.flags += emscripten_flags
  end

  conf.linker do |linker|
    linker.command = 'emcc'
    linker.library_paths << "#{BUILD_DIR}/emscripten/lib"
    linker.libraries += %w(msgpackc yaml bismite)
    linker.flags += emscripten_flags
  end

  conf.archiver.command = 'emar'
end
