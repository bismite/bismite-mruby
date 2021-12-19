require 'rbconfig'
require_relative "common.rb"

SCRIPTS_DIR = File.expand_path File.join __dir__, "..", "..", "scripts"
INSTALL_PREFIX = "#{BUILD_DIR}/mingw"

MRuby::Build.new do |conf|
  toolchain :clang
end

MRuby::CrossBuild.new('mingw') do |conf|
  toolchain :gcc
  conf.host_target = "mingw"

  include_gems conf,"mingw"

  conf.cc do |cc|
    cc.command = 'x86_64-w64-mingw32-gcc'
    cc.defines += %w(MRB_INT64 MRB_UTF8_STRING MRB_NO_BOXING)
    cc.include_paths << "#{INSTALL_PREFIX}/include"
    cc.include_paths << "#{INSTALL_PREFIX}/libyaml-0.2.5-x86_64-w64-mingw32/include/"
    cc.include_paths << "#{INSTALL_PREFIX}/msgpack-c/include/"
    cc.flags = %W(-O3 -std=gnu11 -DNDEBUG -Wall -Werror-implicit-function-declaration -Wwrite-strings)
    cc.flags << "`#{INSTALL_PREFIX}/bin/sdl2-config --cflags`"
  end

  conf.linker do |linker|
    linker.command = "#{SCRIPTS_DIR}/linker.rb x86_64-w64-mingw32-gcc"
    linker.library_paths << "#{INSTALL_PREFIX}/bin"
    linker.library_paths << "#{INSTALL_PREFIX}/lib"
    linker.library_paths << "#{INSTALL_PREFIX}/mruby/build/mingw/lib"
    linker.libraries += %w(bismite opengl32 yaml msgpackc)
    linker.flags_after_libraries << "`#{INSTALL_PREFIX}/bin/sdl2-config --libs` -lSDL2_image -lSDL2_mixer -static-libgcc -mconsole"
  end

  conf.exts do |exts|
    exts.executable = '.exe'
  end

  conf.archiver do |archiver|
    archiver.command = "#{SCRIPTS_DIR}/archiver.rb"
    archiver.archive_options = 'x86_64-w64-mingw32 %{outfile} %{objs}'
  end
end
