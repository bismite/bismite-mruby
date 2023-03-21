require_relative "common.rb"

NOSIMD = (ENV['SIMD']=="nosimd")
if NOSIMD
  TARGET = "emscripten-nosimd"
  LIBBISMITE = "bismite-nosimd"
else
  TARGET = "emscripten"
  LIBBISMITE = "bismite"
end

EMSCRIPTEN_FLAGS = %W(-s USE_SDL=0 -s MAIN_MODULE=1 -fPIC -flto)

MRuby::Build.new do |conf|
  toolchain :clang
end

MRuby::CrossBuild.new(TARGET) do |conf|
  toolchain :clang
  include_gems(conf,"emscripten",true)
  ENV['MRUBY_EMSCRIPTEN'] ? conf.gem(ENV['MRUBY_EMSCRIPTEN']) : conf.gem(github:'bismite/mruby-emscripten')
  conf.cc do |cc|
    cc.command = 'emcc'
    cc.defines += %w(MRB_INT64 MRB_UTF8_STRING MRB_NO_BOXING MRB_NO_DEFAULT_RO_DATA_P)
    cc.include_paths << "#{BUILD_DIR}/#{TARGET}/include"
    cc.include_paths << "#{BUILD_DIR}/#{TARGET}/include/SDL2"
    cc.flags = %w(-O3 -std=gnu11 -Wall -Werror-implicit-function-declaration -Wwrite-strings)
    cc.flags += EMSCRIPTEN_FLAGS
  end
  conf.linker do |linker|
    linker.command = 'emcc'
    linker.library_paths << "#{BUILD_DIR}/#{TARGET}/lib"
    linker.libraries << LIBBISMITE
    # linker.libraries << %w(SDL2 SDL2_image SDL2_mixer)
    linker.flags += EMSCRIPTEN_FLAGS
    linker.flags << "-sMAX_WEBGL_VERSION=2"
    linker.flags << "#{BUILD_DIR}/#{TARGET}/lib/libSDL2.a"
    linker.flags << "#{BUILD_DIR}/#{TARGET}/lib/libSDL2_image.a"
    linker.flags << "#{BUILD_DIR}/#{TARGET}/lib/libSDL2_mixer.a"
  end
  conf.archiver.command = 'emar'
end
