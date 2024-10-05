#!/usr/bin/env ruby
require_relative "scripts/utils"

VALID_TARGET = %w(macos linux emscripten mingw)

clean = ARGV.delete("clean")
TARGET = ARGV.shift
unless VALID_TARGET.include? TARGET
  puts "invalid target specified.".red
  puts "allowed targets are: " + VALID_TARGET.join(" ")
  exit 1
end

puts "TARGET: #{TARGET}"
puts install_path TARGET

if clean
  run "rm -rf build/#{TARGET}"
  run "rm -f mruby_config/#{TARGET}.rb.lock"
  run "rm -f mruby_config/emscripten.rb.lock" if /emscripten/ === TARGET
  run "rm -f mruby_config/macos.rb.lock" if /macos/ === TARGET
end

mkdir_p install_path(TARGET)
Dir.chdir(install_path(TARGET)){ mkdir_p %w(bin lib include licenses) }

run "./scripts/download-required-files.rb #{TARGET}"

#
# Install Tools
#
def install_tool(t)
  cp "src/#{t}.rb", File.join(install_path(TARGET),"bin",t)
end
case TARGET
when "macos","linux"
  install_tool "bismite-config"
when "mingw"
  install_tool "bismite-config-mingw"
when "emscripten"
  install_tool "bismite-config-emscripten"
end
%w(bismite bismite-asset-pack bismite-asset-unpack).each{|t| install_tool t }

#
# build mruby, build template
#
# Patch to mruby
cp "src/mruby-patch.diff", "build/#{TARGET}/mruby"
Dir.chdir("build/#{TARGET}/mruby"){
  run "patch -p1 -i mruby-patch.diff"
}
run "./scripts/build-mruby.rb #{TARGET}"
run "./scripts/build-template.rb #{TARGET}"

#
# license files
#
mkdir_p "build/#{TARGET}/licenses"
cp "src/licenses/mruby-and-libraries-licenses.txt", "build/#{TARGET}/licenses"
case TARGET
when /mingw/
  cp_r "src/licenses/mingw/licenses", "build/mingw/"
when /emscripten/
  EMDIR = File.dirname which "emcc"
  cp "#{EMDIR}/LICENSE", "build/#{TARGET}/licenses/emscripten-LICENSE"
  cp "#{EMDIR}/AUTHORS", "build/#{TARGET}/licenses/emscripten-AUTHORS"
  cp "#{EMDIR}/system/lib/libc/musl/COPYRIGHT", "build/#{TARGET}/licenses/musl-COPYRIGHT"
end

#
# archive
#
Dir.chdir("build/#{TARGET}"){
  a = "bismite-mruby-#{TARGET}"
  rm_rf a
  rm_f "#{a}.tgz"
  mkdir_p a
  cp_r "bin", a
  cp_r "lib", a
  cp_r "include", a
  cp_r "template-#{TARGET}", a
  cp_r "licenses", a
  run "tar czf #{a}.tgz #{a}"
}
