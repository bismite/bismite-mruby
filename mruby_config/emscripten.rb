require_relative "common.rb"

TARGET = "emscripten"
EMSCRIPTEN_FLAGS = %W(-s USE_SDL=0 -s MAIN_MODULE=1 -fPIC -flto)

MRuby::Build.new do |conf|
  toolchain :clang
end

MRuby::CrossBuild.new(TARGET) do |conf|
  toolchain :clang
  include_gems(conf,TARGET,true)
  conf.cc do |cc|
    cc.command = 'emcc'
    cc.defines += COMMON_DEFINES
    cc.include_paths << "#{BUILD_DIR}/#{TARGET}/include"
    cc.include_paths << "#{BUILD_DIR}/#{TARGET}/include/SDL2"
    cc.flags = COMMON_CFLAGS
    cc.flags += EMSCRIPTEN_FLAGS
  end
  conf.linker do |linker|
    linker.command = 'emcc'
    linker.library_paths << "#{BUILD_DIR}/#{TARGET}/lib"
    linker.libraries << "bismite"
    linker.flags += EMSCRIPTEN_FLAGS
    linker.flags << "-sMAX_WEBGL_VERSION=2"
    linker.flags << "#{BUILD_DIR}/#{TARGET}/lib/libSDL2.a"
    linker.flags << "#{BUILD_DIR}/#{TARGET}/lib/libSDL2_image.a"
    linker.flags << "#{BUILD_DIR}/#{TARGET}/lib/libSDL2_mixer.a"
  end
  conf.archiver do |archiver|
    archiver.command = "#{SCRIPTS_DIR}/archiver.rb"
    archiver.archive_options = 'emscripten %{outfile} %{objs}'
  end
end
