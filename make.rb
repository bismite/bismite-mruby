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
    run "./scripts/mingw/install_sdl.sh"
    cp "src/bismite-config-mingw.rb", "#{install_path(target)}/bin"
  when /emscripten/
    cp "src/bismite-config-emscripten.rb", "#{install_path(target)}/bin"
  end

  %w(
    ./scripts/build_bilibs.rb
    ./scripts/build_mruby.rb
    ./scripts/licenses.rb
  ).each{|script|
    run "#{script} #{target}"
  }

  run "./scripts/build_template.rb #{target}"

  rm_rf "tmp/#{target}"
  mkdir_p "tmp/#{target}"
  cp_r "build/#{target}/bin", "tmp/#{target}"
  cp_r "build/#{target}/lib", "tmp/#{target}"
  cp_r "build/#{target}/include", "tmp/#{target}"
  cp_r "build/#{target}/share", "tmp/#{target}"
  cp_r "build/#{target}/licenses", "tmp/#{target}"
  Dir.chdir("tmp"){
    run "tar czf #{target}.tgz #{target}"
  }
end
