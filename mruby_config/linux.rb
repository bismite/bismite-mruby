require_relative "common.rb"

INSTALL_PREFIX = "#{BUILD_DIR}/linux"

MRuby::Build.new do |conf|
  toolchain :clang
end

MRuby::CrossBuild.new('linux') do |conf|
  toolchain :clang

  include_gems conf,"linux"

  conf.cc do |cc|
    cc.command = 'clang'
    cc.defines += COMMON_DEFINES
    cc.include_paths << "#{INSTALL_PREFIX}/include"
    cc.include_paths << "#{INSTALL_PREFIX}/include/SDL2"
    cc.flags = COMMON_CFLAGS
    cc.flags << "-fPIC"
  end

  conf.linker do |linker|
    linker.command = "#{SCRIPTS_DIR}/linker.rb clang"
    linker.library_paths += [ "#{INSTALL_PREFIX}/lib", "#{BUILD_DIR}/linux/mruby/build/linux/lib"]
    linker.libraries += %W(bismite SDL2 SDL2_image SDL2_mixer GL)
    linker.flags_after_libraries << "-Wl,-rpath,'$ORIGIN/../lib'"
  end

  conf.archiver do |archiver|
    archiver.command = "#{SCRIPTS_DIR}/archiver.rb"
    archiver.archive_options = 'linux %{outfile} %{objs}'
  end
end
