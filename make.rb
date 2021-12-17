#!/usr/bin/env ruby
begin
  require "dotenv/load"
rescue LoadError
  nil
end
require_relative "scripts/lib/utils"

def setup_macos
  cp "src/bismite-config.rb", "#{install_path('macos')}/bin/bismite-config"
  Dir.chdir("build"){
    # install msgpack-c
    run "tar xf download/macos/msgpack-c-macos.tgz -C macos/"
    cp_r "macos/msgpack-c/lib", "macos", remove_destination:true
    # install libyaml
    run "tar zxf download/macos/libyaml-0.2.5-macos.tgz -C macos/"
    cp_r "macos/libyaml-0.2.5-macos/lib", "macos", remove_destination:true
    cp "macos/libyaml-0.2.5-macos/License", "macos/licenses/libyaml-License"
    # install SDL
    run "tar xf download/macos/SDL-macOS-UniversalBinaries.tgz -C macos/"
    cp_r "macos/SDL-macOS-UniversalBinaries/lib", "macos", remove_destination:true
    cp_r "macos/SDL-macOS-UniversalBinaries/include", "macos", remove_destination:true
    cp_r "macos/SDL-macOS-UniversalBinaries/licenses", "macos", remove_destination:true
    # install libbismite
    run "tar xf download/macos/libbismite-macos.tgz -C macos/"
  }
end

def setup_linux
  cp "src/bismite-config.rb", "#{install_path('linux')}/bin/bismite-config"
  Dir.chdir("build"){
    # install msgpack-c
    run "tar xf download/linux/msgpack-c-linux.tgz -C linux/"
    cp "linux/msgpack-c/lib/libmsgpackc.so", "linux/lib/libmsgpackc.so"
    # install libbismite
    run "tar xf download/linux/libbismite-linux.tgz -C linux/"
  }
end

def setup_emscripten
  cp "src/bismite-config-emscripten.rb", "#{install_path('emscripten')}/bin/bismite-config-emscripten"
  Dir.chdir("build"){
    # install msgpack-c
    run "tar xf download/emscripten/msgpack-c-emscripten.tgz -C emscripten/"
    cp_r "emscripten/msgpack-c/lib", "emscripten", remove_destination:true
    # install libyaml
    run "tar xf download/emscripten/libyaml-0.2.5-emscripten.tgz -C emscripten/"
    cp_r "emscripten/libyaml-0.2.5-emscripten/lib", "emscripten", remove_destination:true
    cp "emscripten/libyaml-0.2.5-emscripten/License", "emscripten/licenses/libyaml-License"
    # install libbismite
    run "tar zxf download/emscripten/libbismite-emscripten.tgz -C emscripten/"
  }
end

class SetupMingw
  SDL2 = "SDL2-2.0.18"
  SDL2_IMAGE = "SDL2_image-2.0.5"
  SDL2_MIXER = "SDL2_mixer-2.0.4"
  def self.setup
    cp "src/bismite-config-mingw.rb", "#{install_path('mingw')}/bin/bismite-config-mingw"
    Dir.chdir("build"){
      # install libbismite
      run "tar xf download/mingw/libbismite-x86_64-w64-mingw32.tgz -C mingw/"
      # unarchive
      Dir.glob("download/mingw/SDL2*gz"){|archive| run "tar xf #{archive} -C mingw/" }
      Dir.glob("download/mingw/libyaml*gz"){|archive| run "tar xf #{archive} -C mingw/" }
      Dir.glob("download/mingw/msgpack*gz"){|archive| run "tar xf #{archive} -C mingw/" }
      Dir.glob("download/mingw/libbismite*gz"){|archive| run "tar xf #{archive} -C mingw/" }
    }
    Dir.chdir("build/mingw") do
      # install SDL
      srcdir="#{SDL2}/x86_64-w64-mingw32"
      cp_r "#{srcdir}/include/", "./"
      cp "#{srcdir}/bin/SDL2.dll", "bin/"
      cp "#{srcdir}/lib/libSDL2main.a", "lib/"
      cp "#{srcdir}/bin/sdl2-config", "bin/"
      File.write(
       "bin/sdl2-config",
        File.read("bin/sdl2-config").gsub("/opt/local/x86_64-w64-mingw32", "$(dirname $(dirname $(realpath $0)))")
      )
      # install SDL_image
      srcdir="#{SDL2_IMAGE}/x86_64-w64-mingw32"
      cp_r "#{srcdir}/include/", "./"
      %w(SDL2_image.dll libpng16-16.dll zlib1.dll).each{|dll| cp "#{srcdir}/bin/#{dll}", "bin/" }
      %w(LICENSE.zlib.txt LICENSE.png.txt).each{|l| cp "#{srcdir}/bin/#{l}", "licenses/" }
      # install SDL_mixer
      srcdir="#{SDL2_MIXER}/x86_64-w64-mingw32"
      cp_r "#{srcdir}/include/", "./"
      %w(SDL2_mixer.dll libmpg123-0.dll).each{|dll| cp "#{srcdir}/bin/#{dll}", "bin/" }
      %w(LICENSE.mpg123.txt).each{|l| cp "#{srcdir}/bin/#{l}", "licenses/" }
      # copy SDL licenses
      [SDL2,SDL2_IMAGE,SDL2_MIXER].each{|name| cp "#{name}/COPYING.txt", "licenses/#{name}-COPYING" }
      # install msgpack-c
      cp "msgpack-c/lib/libmsgpackc.dll", "bin/"
      # install libyaml
      cp "libyaml-0.2.5-x86_64-w64-mingw32/lib/libyaml.dll", "bin/"
      cp "libyaml-0.2.5-x86_64-w64-mingw32/License", "licenses/libyaml-License"
    end
  end
end

targets = ARGV.reject{|a| not ["clean","macos","linux","emscripten","mingw"].include? a }
if targets.empty?
  if RUBY_PLATFORM.include?("darwin")
    targets << "macos"
  elsif RUBY_PLATFORM.include?("linux")
    targets << "linux"
  end
end
targets.each do |target|

  if target == "clean"
    run "rm -rf build/macos build/linux build/mingw build/emscripten"
    run "rm -f scripts/mruby_config/*.lock"
    next
  end

  puts "TARGET: #{target}"
  puts install_path target

  mkdir_p install_path(target)
  Dir.chdir(install_path(target)){
    mkdir_p %w(bin lib include licenses)
  }

  run "./scripts/download_required_files.rb #{target}"

  case target
  when /macos/
    setup_macos
  when /linux/
    setup_linux
  when /mingw/
    SetupMingw.setup
  when /emscripten/
    setup_emscripten
  end

  #
  # build mruby, copy licenses, build template
  #
  run "./scripts/build_mruby.rb #{target}"
  run "./scripts/licenses.rb #{target}"
  run "./scripts/build_template.rb #{target}"

  #
  # archive
  #
  name = "bismite-mruby-#{target}"
  rm_rf "tmp/#{name}"
  mkdir_p "tmp/#{name}/share"
  cp_r "build/#{target}/bin", "tmp/#{name}"
  cp_r "build/#{target}/lib", "tmp/#{name}"
  cp_r "build/#{target}/include", "tmp/#{name}"
  cp_r "build/#{target}/share/bismite", "tmp/#{name}/share/"
  cp_r "build/#{target}/Licenses.md", "tmp/#{name}"
  Dir.chdir("tmp"){
    run "tar czf #{name}.tgz #{name}"
  }
end
