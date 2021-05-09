#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV[0]

FileUtils.mkdir_p "build/#{TARGET}/#{MRUBY}"
run "tar --strip-component 1 -zxf build/download/#{TARGET}/#{MRUBY}.tar.gz -C build/#{TARGET}/#{MRUBY}"
cp "src/mruby.patch", "build/#{TARGET}/#{MRUBY}"

ENV["MRUBY_CONFIG"] = "#{Dir.pwd}/scripts/mruby_config/#{TARGET}.rb"

#
# build mruby
#
Dir.chdir("build/#{TARGET}/#{MRUBY}"){
  run "patch -p0 < mruby.patch"
  run "rake MRUBY_YAML_USE_SYSTEM_LIBRARY=true"
}

#
# install mruby
#
def install_mruby(target,build_name)
  prefix = install_path(target)
  %w(bin include lib).each{|d| mkdir_p "build/#{target}/#{d}/" }

  if /macos/ === target
    run "lipo -create build/macos/#{MRUBY}/build/macos-x86_64/lib/libmruby.a build/macos/#{MRUBY}/build/macos-arm64/lib/libmruby.a -output #{prefix}/lib/libmruby.a"
    %w(mirb mrbc mruby mruby-strip).each{|bin|
      run "lipo -create build/macos/#{MRUBY}/build/macos-x86_64/bin/#{bin} build/macos/#{MRUBY}/build/macos-arm64/bin/#{bin} -output #{prefix}/bin/#{bin}"
      run "install_name_tool -add_rpath @executable_path/../lib #{prefix}/bin/#{bin}"
    }
    cp_r "build/#{target}/#{MRUBY}/include/.", "#{prefix}/include/"
    cp_r "build/#{target}/#{MRUBY}/build/macos-x86_64/include/.", "#{prefix}/include/" rescue nil # presym headers
  else
    cp_r "build/#{target}/#{MRUBY}/build/#{build_name}/bin/.", "#{prefix}/bin/" rescue nil
    cp_r "build/#{target}/#{MRUBY}/build/#{build_name}/lib/.", "#{prefix}/lib/"
    cp_r "build/#{target}/#{MRUBY}/include/.", "#{prefix}/include/"
    cp_r "build/#{target}/#{MRUBY}/build/#{build_name}/include/.", "#{prefix}/include/" rescue nil # presym headers
  end
end

if /linux/ === TARGET
  install_mruby TARGET, "host"
else
  install_mruby TARGET, TARGET
end
