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
    run "rm -rf build/macos build/linux build/x86_64-w64-mingw32"
    run "rm -f scripts/mruby_config/*.lock"
    next
  end

  puts "TARGET: #{target}"
  puts install_path target

  mkdir_p "#{install_path(target)}/bin"
  mkdir_p "#{install_path(target)}/lib"
  mkdir_p "#{install_path(target)}/include"

  run "./scripts/download_required_files.rb #{target}"

  case target
  when /macos/
    run "./scripts/macos/install_sdl.rb"
    cp "src/bismite-config.rb", "#{install_path(target)}/bin"
  when /linux/
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
