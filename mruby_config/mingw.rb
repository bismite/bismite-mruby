require_relative "common.rb"

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
    cc.defines += COMMON_DEFINES + %w(DISABLE_CLOCK_GETTIME)
    cc.include_paths << "#{INSTALL_PREFIX}/include"
    cc.include_paths << "#{INSTALL_PREFIX}/include/SDL2"
    cc.flags = COMMON_CFLAGS
    cc.flags << "-Dmain=SDL_main"
  end

  conf.linker do |linker|
    linker.command = "#{SCRIPTS_DIR}/linker.rb x86_64-w64-mingw32-gcc"
    linker.library_paths << "#{INSTALL_PREFIX}/bin"
    linker.library_paths << "#{INSTALL_PREFIX}/lib"
    linker.library_paths << "#{INSTALL_PREFIX}/mruby/build/mingw/lib"
    linker.libraries += %w(bismite opengl32 mingw32 SDL2main SDL2 SDL2_image SDL2_mixer)
    linker.flags_after_libraries << "-static-libgcc -mconsole"
  end

  conf.exts do |exts|
    exts.executable = '.exe'
  end

  conf.archiver do |archiver|
    archiver.command = "#{SCRIPTS_DIR}/archiver.rb"
    archiver.archive_options = 'mingw %{outfile} %{objs}'
  end
end
