require 'rbconfig'
require_relative "common.rb"

SCRIPTS_DIR = File.expand_path File.join __dir__, "..", "..", "scripts"
INSTALL_PREFIX = "#{BUILD_DIR}/macos"
LIBS = %w( bismite-core bismite-ext SDL2 SDL2_image SDL2_mixer msgpackc yaml )
INCLUDES = %w(include include/SDL2 msgpack-c/include libyaml-0.2.5-macos/include).map{|i| "#{INSTALL_PREFIX}/#{i}" }
COMMON_CFLAGS = %w(-g0 -DNDEBUG -Wall -Werror-implicit-function-declaration -Wwrite-strings -std=gnu11 -O3)
COMMON_DEFINES = %w(MRB_INT64 MRB_UTF8_STRING MRB_NO_BOXING)

MRuby::Build.new do |conf|
  toolchain :clang
end

MRuby::CrossBuild.new('macos-arm64') do |conf|
  toolchain :clang

  include_gems conf

  conf.cc do |cc|
    cc.command = 'clang'
    cc.defines += COMMON_DEFINES
    cc.include_paths += INCLUDES
    cc.flags = COMMON_CFLAGS + %w(-arch arm64)
  end

  conf.linker do |linker|
    linker.command = "#{SCRIPTS_DIR}/macos/linker.rb"
    linker.library_paths += [ "#{INSTALL_PREFIX}/lib", "#{BUILD_DIR}/macos/mruby-3.0.0/build/macos-arm64/lib"]
    linker.libraries += LIBS
    linker.flags << "-framework OpenGL -arch arm64"
  end

  conf.archiver do |archiver|
    archiver.command = "#{SCRIPTS_DIR}/macos/archiver.rb"
    archiver.archive_options = 'arm64 %{outfile} %{objs}'
  end
end

MRuby::CrossBuild.new('macos-x86_64') do |conf|
  toolchain :clang

  include_gems conf

  conf.cc do |cc|
    cc.command = 'clang'
    cc.defines += COMMON_DEFINES
    cc.include_paths += INCLUDES
    cc.flags = COMMON_CFLAGS + %w(-arch x86_64)
  end

  conf.linker do |linker|
    linker.command = "#{SCRIPTS_DIR}/macos/linker.rb"
    linker.library_paths += ["#{INSTALL_PREFIX}/lib", "#{BUILD_DIR}/macos/mruby-3.0.0/build/macos-x86_64/lib"]
    linker.libraries += LIBS
    linker.flags << "-framework OpenGL -arch x86_64"
  end

  conf.archiver do |archiver|
    archiver.command = "#{SCRIPTS_DIR}/macos/archiver.rb"
    archiver.archive_options = 'x86_64 %{outfile} %{objs}'
  end
end
