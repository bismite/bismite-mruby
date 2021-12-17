#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV[0]
ENV["MRUBY_CONFIG"] = "#{Dir.pwd}/scripts/mruby_config/#{TARGET}.rb"
MRUBY_DIR="build/#{TARGET}/mruby"

#
# extract
#
Dir.chdir("build"){
  %w(mruby mruby-libbismite mruby-bi-misc).each{|name|
    FileUtils.mkdir_p "#{TARGET}/#{name}"
    run "tar --strip-component 1 -xf download/#{TARGET}/#{name}.tgz -C #{TARGET}/#{name}"
  }
}

#
# build mruby
#
cp "src/mruby.patch", "build/#{TARGET}/mruby"
Dir.chdir(MRUBY_DIR){
  run "patch -p0 < mruby.patch"
  run "rake MRUBY_YAML_USE_SYSTEM_LIBRARY=true"
}

#
# install mruby
#
prefix = install_path(TARGET)
%w(bin include lib).each{|d| mkdir_p "build/#{TARGET}/#{d}/" }

cp_r "#{MRUBY_DIR}/include/.", "#{prefix}/include/"
if /macos/ === TARGET
  run "lipo -create #{MRUBY_DIR}/build/macos-x86_64/lib/libmruby.dylib #{MRUBY_DIR}/build/macos-arm64/lib/libmruby.dylib -output #{prefix}/lib/libmruby.dylib"
  %w(mirb mrbc mruby mruby-strip).each{|bin|
    run "lipo -create #{MRUBY_DIR}/build/macos-x86_64/bin/#{bin} #{MRUBY_DIR}/build/macos-arm64/bin/#{bin} -output #{prefix}/bin/#{bin}"
    run "install_name_tool -add_rpath @executable_path/../lib #{prefix}/bin/#{bin}"
  }
  cp_r "#{MRUBY_DIR}/build/macos-x86_64/include/.", "#{prefix}/include/" rescue nil # presym headers
else
  if /linux/ === TARGET
    cp "#{MRUBY_DIR}/build/#{TARGET}/lib/libmruby.so", "#{prefix}/lib/libmruby.so"
  elsif TARGET == "mingw"
    cp "#{MRUBY_DIR}/build/#{TARGET}/lib/libmruby.dll", "#{prefix}/bin/libmruby.dll"
  else
    cp_r "#{MRUBY_DIR}/build/#{TARGET}/lib/.", "#{prefix}/lib/"
  end
  cp_r "#{MRUBY_DIR}/build/#{TARGET}/bin/.", "#{prefix}/bin/" rescue nil
  cp_r "#{MRUBY_DIR}/build/#{TARGET}/include/.", "#{prefix}/include/" rescue nil # presym headers
end
