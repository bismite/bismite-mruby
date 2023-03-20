#!/usr/bin/env ruby
begin
  require "dotenv/load"
rescue LoadError
  nil
end
require_relative "scripts/lib/utils"

def setup_macos(arch)
  cp "src/bismite-config.rb", "#{install_path("macos-#{arch}")}/bin/bismite-config"
end

def setup_linux
  cp "src/bismite-config.rb", "#{install_path('linux')}/bin/bismite-config"
end

def setup_emscripten
  cp "src/bismite-config-emscripten.rb", "#{install_path('emscripten')}/bin/bismite-config-emscripten"
end

def setup_emscripten_nosimd
  cp "src/bismite-config-emscripten-nosimd.rb", "#{install_path('emscripten-nosimd')}/bin/bismite-config-emscripten-nosimd"
end

def setup_mingw
  cp "src/bismite-config-mingw.rb", "#{install_path('mingw')}/bin/bismite-config-mingw"
end

targets = ARGV.reject{|a| not %w(clean macos-arm64 macos-x86_64 linux emscripten emscripten-nosimd mingw).include? a }
clean = targets.delete("clean")
if targets.empty?
  if RUBY_PLATFORM.include?("darwin")
    targets << "macos"
  elsif RUBY_PLATFORM.include?("linux")
    targets << "linux"
  end
end

targets.each do |target|
  puts "TARGET: #{target}"
  puts install_path target

  if clean
    run "rm -rf build/#{target}"
    run "rm -f scripts/mruby_config/#{target}.rb.lock"
    if /macos/ === target
      run "rm -f scripts/mruby_config/macos.rb.lock"
    end
  end

  mkdir_p install_path(target)
  Dir.chdir(install_path(target)){
    mkdir_p %w(bin lib include licenses)
  }

  run "./scripts/download_required_files.rb #{target}"

  case target
  when "macos-arm64"
    setup_macos "arm64"
  when "macos-x86_64"
    setup_macos "x86_64"
  when "linux"
    setup_linux
  when "mingw"
    setup_mingw
  when "emscripten"
    setup_emscripten
  when "emscripten-nosimd"
    setup_emscripten_nosimd
  end

  #
  # build mruby, build template
  #
  run "./scripts/build_mruby.rb #{target}"
  run "./scripts/build_template.rb #{target}"
  run "./scripts/build_tools.rb #{target}"

  #
  # license files
  #
  mkdir_p "build/#{target}/licenses"
  cp "src/licenses/mruby-and-libraries-licenses.txt", "build/#{target}/licenses"
  case target
  when /mingw/
    cp_r "src/licenses/mingw/licenses", "build/mingw/"
  when /emscripten/
    EMDIR = File.dirname which "emcc"
    cp "#{EMDIR}/LICENSE", "build/#{target}/licenses/emscripten-LICENSE"
    cp "#{EMDIR}/AUTHORS", "build/#{target}/licenses/emscripten-AUTHORS"
    cp "#{EMDIR}/system/lib/libc/musl/COPYRIGHT", "build/#{target}/licenses/musl-COPYRIGHT"
  end

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
  cp_r "build/#{target}/licenses", "tmp/#{name}"
  Dir.chdir("tmp"){
    run "tar czf #{name}.tgz #{name}"
  }
end
