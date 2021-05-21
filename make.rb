#!/usr/bin/env ruby
begin
  require "dotenv/load"
rescue LoadError
  nil
end
require_relative "scripts/lib/utils"

targets = ARGV.reject{|a| not ["clean","macos","linux","emscripten","x86_64-w64-mingw32"].include? a }
if targets.empty?
  if RUBY_PLATFORM.include?("darwin")
    targets << "macos"
  elsif RUBY_PLATFORM.include?("linux")
    targets << "linux"
  end
end

targets.each do |target|

  if target == "clean"
    run "rm -rf build/macos build/linux build/x86_64-w64-mingw32 build/emscripten"
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
    # install msgpack-c
    run "tar zxf build/download/macos/msgpack-c-macos.tgz -C build/macos/"
    cp_r "build/macos/msgpack-c/lib", "build/macos", remove_destination:true
    # install libyaml
    run "tar zxf build/download/macos/libyaml-0.2.5-macos.tgz -C build/macos/"
    cp_r "build/macos/libyaml-0.2.5-macos/lib", "build/macos", remove_destination:true
    cp "build/macos/libyaml-0.2.5-macos/License", "build/macos/licenses/License.libyaml.txt"
    # install SDL
    run "tar zxf build/download/macos/SDL-macOS-UniversalBinaries.tgz -C build/macos"
    cp_r "build/macos/SDL-macOS-UniversalBinaries/lib", "build/macos", remove_destination:true
    cp_r "build/macos/SDL-macOS-UniversalBinaries/include", "build/macos", remove_destination:true
    cp_r "build/macos/SDL-macOS-UniversalBinaries/licenses", "build/macos", remove_destination:true
    #
    cp "src/bismite-config.rb", "#{install_path(target)}/bin"
  when /linux/
    # install msgpack-c
    run "tar zxf build/download/linux/msgpack-c-linux.tgz -C build/linux/"
    cp_r "build/linux/msgpack-c/lib", "build/linux", remove_destination:true
    #
    cp "src/bismite-config.rb", "#{install_path(target)}/bin"
  when /mingw/
    cp "src/bismite-config-mingw.rb", "#{install_path(target)}/bin"
    dldir = "build/download/x86_64-w64-mingw32"
    dstdir = "build/x86_64-w64-mingw32"
    # unarchive
    Dir.glob("#{dldir}/*gz"){|archive| run "tar zxf #{archive} -C #{dstdir}" }
    Dir.chdir(dstdir) do
      # install SDL
      srcdir="SDL2-2.0.14/x86_64-w64-mingw32"
      cp_r "#{srcdir}/include/", "./"
      cp "#{srcdir}/bin/SDL2.dll", "bin/"
      cp "#{srcdir}/lib/libSDL2main.a", "lib/"
      cp "#{srcdir}/bin/sdl2-config", "bin/"
      File.write(
       "bin/sdl2-config",
        File.read("bin/sdl2-config").gsub("/opt/local/x86_64-w64-mingw32", "$(dirname $(dirname $(realpath $0)))")
      )
      # install SDL_image
      srcdir="SDL2_image-2.0.5/x86_64-w64-mingw32"
      cp_r "#{srcdir}/include/", "./"
      %w(SDL2_image.dll libpng16-16.dll zlib1.dll).each{|dll| cp "#{srcdir}/bin/#{dll}", "bin/" }
      %w(LICENSE.zlib.txt LICENSE.png.txt).each{|l| cp "#{srcdir}/bin/#{l}", "licenses/" }
      # install SDL_mixer
      srcdir="SDL2_mixer-2.0.4/x86_64-w64-mingw32"
      cp_r "#{srcdir}/include/", "./"
      %w(SDL2_mixer.dll libmpg123-0.dll).each{|dll| cp "#{srcdir}/bin/#{dll}", "bin/" }
      %w(LICENSE.mpg123.txt).each{|l| cp "#{srcdir}/bin/#{l}", "licenses/" }
      # copy SDL licenses
      %w(SDL2-2.0.14 SDL2_image-2.0.5 SDL2_mixer-2.0.4).each{|sdl|
        cp "#{sdl}/COPYING.txt", "licenses/COPYING.#{sdl}.txt"
      }
      # install msgpack-c
      cp "msgpack-c/lib/libmsgpackc.dll", "bin/"
      # install libyaml
      cp "libyaml-0.2.5-x86_64-w64-mingw32/lib/libyaml.dll", "bin/"
      cp "libyaml-0.2.5-x86_64-w64-mingw32/License", "licenses/License.libyaml.txt"
    end
  when /emscripten/
    cp "src/bismite-config-emscripten.rb", "#{install_path(target)}/bin"
    # install msgpack-c
    run "tar zxf build/download/emscripten/msgpack-c-emscripten.tgz -C build/emscripten/"
    cp_r "build/emscripten/msgpack-c/lib", "build/emscripten", remove_destination:true
    # install libyaml
    run "tar zxf build/download/emscripten/libyaml-0.2.5-emscripten.tgz -C build/emscripten/"
    cp_r "build/emscripten/libyaml-0.2.5-emscripten/lib", "build/emscripten", remove_destination:true
    cp "build/emscripten/libyaml-0.2.5-emscripten/License", "build/emscripten/licenses/License.libyaml.txt"
  end

  %w(
    ./scripts/build_bilibs.rb
    ./scripts/build_mruby.rb
    ./scripts/licenses.rb
  ).each{|script|
    run "#{script} #{target}"
  }

  run "./scripts/build_template.rb #{target}"

  # archive
  name = "bismite-mruby-#{target}"
  rm_rf "tmp/#{name}"
  mkdir_p "tmp/#{name}/share"
  cp_r "build/#{target}/bin", "tmp/#{name}"
  cp_r "build/#{target}/lib", "tmp/#{name}"
  cp_r "build/#{target}/include", "tmp/#{name}"
  cp_r "build/#{target}/share/bismite", "tmp/#{name}/share/"
  cp_r "build/#{target}/licenses", "tmp/#{name}"
  Dir.chdir("tmp"){
    run "tar czf #{name}.tgz #{name}"
  }
end
