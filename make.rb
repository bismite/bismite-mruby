#!/usr/bin/env ruby
require_relative "scripts/lib/utils"

VALID_TARGET = %w(macos linux emscripten mingw)

clean = ARGV.delete("clean")
target = ARGV.shift
unless VALID_TARGET.include? target
  puts "invalid target specified.".red
  puts "allowed targets are: " + VALID_TARGET.join(" ")
  exit 1
end

puts "TARGET: #{target}"
puts install_path target

if clean
  run "rm -rf build/#{target}"
  run "rm -f mruby_config/#{target}.rb.lock"
  run "rm -f mruby_config/emscripten.rb.lock" if /emscripten/ === target
  run "rm -f mruby_config/macos.rb.lock" if /macos/ === target
end

mkdir_p install_path(target)
Dir.chdir(install_path(target)){ mkdir_p %w(bin lib include licenses) }

run "./scripts/download_required_files.rb #{target}"

#
# Install bismite-config
#
case target
when "macos"
  cp "src/bismite-config.rb", "#{install_path("macos")}/bin/bismite-config"
when "linux"
  cp "src/bismite-config.rb", "#{install_path('linux')}/bin/bismite-config"
when "mingw"
  cp "src/bismite-config-mingw.rb", "#{install_path('mingw')}/bin/bismite-config-mingw"
when "emscripten"
  cp "src/bismite-config-emscripten.rb", "#{install_path('emscripten')}/bin/bismite-config-emscripten"
end

#
# build mruby, build template
#
# Patch to mruby
cp "src/mruby-patch.diff", "build/#{target}/mruby"
Dir.chdir("build/#{target}/mruby"){
  run "patch -p1 -i mruby-patch.diff"
}
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
