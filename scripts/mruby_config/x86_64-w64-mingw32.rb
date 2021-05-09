require 'rbconfig'
require_relative "common.rb"

MRuby::Build.new do |conf|
  toolchain :clang
end

MRuby::CrossBuild.new('x86_64-w64-mingw32') do |conf|
  toolchain :gcc
  conf.host_target = "x86_64-w64-mingw32"

  include_gems(conf)

  conf.cc do |cc|
    cc.command = 'x86_64-w64-mingw32-gcc'
    cc.defines += %w(MRB_INT64 MRB_UTF8_STRING MRB_NO_BOXING)
    cc.include_paths << "#{BUILD_DIR}/#{conf.host_target}/include"
    cc.include_paths << "#{BUILD_DIR}/x86_64-w64-mingw32/libyaml-0.2.5-x86_64-w64-mingw32/include/"
    cc.include_paths << "#{BUILD_DIR}/x86_64-w64-mingw32/msgpack-c/include/"
    cc.flags = %W( -Os -std=gnu11 -DNDEBUG -Wall -Werror-implicit-function-declaration -Wwrite-strings)
    cc.flags << "`#{BUILD_DIR}/#{conf.host_target}/bin/sdl2-config --cflags`"
  end

  conf.linker do |linker|
    linker.command = 'x86_64-w64-mingw32-gcc'
    linker.library_paths << "#{BUILD_DIR}/#{conf.host_target}/lib"
    linker.libraries += %w(bismite-ext bismite-core opengl32 yaml msgpackc)
    linker.flags_after_libraries << "`#{BUILD_DIR}/#{conf.host_target}/bin/sdl2-config --libs` -lSDL2_image -lSDL2_mixer -static-libgcc -mconsole"
  end

  conf.exts do |exts|
    exts.executable = '.exe'
  end

  conf.archiver.command = 'x86_64-w64-mingw32-ar'
end

