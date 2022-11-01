#!/usr/bin/env ruby
begin
  require "dotenv/load"
rescue LoadError
  nil
end
require_relative "scripts/lib/utils"

def setup_macos
  cp "src/bismite-config.rb", "#{install_path('macos')}/bin/bismite-config"
end

def setup_linux
  cp "src/bismite-config.rb", "#{install_path('linux')}/bin/bismite-config"
  Dir.chdir("build"){
    # install msgpack-c
    run "tar xf download/linux/msgpack-c-linux.tgz -C linux/"
    cp "linux/msgpack-c/lib/libmsgpackc.so", "linux/lib/"
    cp "linux/msgpack-c/lib/libmsgpackc.a", "linux/lib/"
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
    cp "emscripten/libyaml-0.2.5-emscripten/License", "emscripten/licenses/libyaml-0.2.5-License"
    # install libbismite
    run "tar zxf download/emscripten/libbismite-emscripten.tgz -C emscripten/"
  }
end

def setup_mingw
  cp "src/bismite-config-mingw.rb", "#{install_path('mingw')}/bin/bismite-config-mingw"
  Dir.chdir("build"){
    run "tar xf download/mingw/libbismite-x86_64-w64-mingw32.tgz -C mingw/"
    run "tar xf download/mingw/SDL-x86_64-w64-mingw32.tgz -C mingw/"
    run "tar xf download/mingw/libyaml-0.2.5-x86_64-w64-mingw32.tgz -C mingw/"
    run "tar xf download/mingw/msgpack-c-x86_64-w64-mingw32.tgz -C mingw/"
    run "tar xf download/mingw/libbismite-x86_64-w64-mingw32.tgz -C mingw/"
  }
  Dir.chdir("build/mingw") do
    # install msgpack-c
    cp "msgpack-c/lib/libmsgpackc.dll", "bin/"
    cp "msgpack-c/lib/libmsgpackc.a", "lib/"
    # install libyaml
    cp "libyaml-0.2.5-x86_64-w64-mingw32/lib/libyaml.dll", "bin/"
    cp "libyaml-0.2.5-x86_64-w64-mingw32/lib/libyaml.a", "lib/"
    cp "libyaml-0.2.5-x86_64-w64-mingw32/License", "licenses/libyaml-0.2.5-License"
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
    setup_mingw
  when /emscripten/
    setup_emscripten
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
