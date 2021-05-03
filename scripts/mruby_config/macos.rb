require 'rbconfig'
require_relative "common.rb"

HOST="macos"

OPTIMIZE = "-Os"
C_STD="-std=gnu11"
COMMON_CFLAGS = %W( -DNDEBUG -Wall -Werror-implicit-function-declaration -Wwrite-strings)
COMMON_DEFINES = %w(MRB_INT64 MRB_UTF8_STRING MRB_NO_BOXING)
INSTALL_PREFIX = "#{BUILD_DIR}/macos"

MRuby::Build.new do |conf|
  toolchain :clang
end

MRuby::CrossBuild.new('macos-arm64') do |conf|
  toolchain :clang

  include_gems conf

  conf.cc do |cc|
    cc.command = 'clang'
    cc.defines += COMMON_DEFINES
    cc.include_paths << "#{INSTALL_PREFIX}/include"
    cc.include_paths << "#{INSTALL_PREFIX}/include/SDL2"
    cc.flags = COMMON_CFLAGS + [ OPTIMIZE, C_STD ]
    cc.flags << "-fPIC -arch arm64"
  end

  conf.linker do |linker|
    linker.command = 'clang'
    linker.library_paths << "#{INSTALL_PREFIX}/lib"
    linker.libraries += %W( bismite-core bismite-ext SDL2 SDL2_image SDL2_mixer )
    linker.flags << "-framework OpenGL -arch arm64"
  end
end

MRuby::CrossBuild.new('macos-x86_64') do |conf|
  toolchain :clang

  include_gems conf

  conf.cc do |cc|
    cc.command = 'clang'
    cc.defines += COMMON_DEFINES
    cc.include_paths << "#{INSTALL_PREFIX}/include"
    cc.include_paths << "#{INSTALL_PREFIX}/include/SDL2"
    cc.flags = COMMON_CFLAGS + [ OPTIMIZE, C_STD ]
    cc.flags << "-fPIC -arch x86_64"
  end

  conf.linker do |linker|
    linker.command = 'clang'
    linker.library_paths << "#{INSTALL_PREFIX}/lib"
    linker.libraries += %W( bismite-core bismite-ext SDL2 SDL2_image SDL2_mixer )
    linker.flags << "-framework OpenGL -arch x86_64"
  end
end
