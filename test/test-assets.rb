#!/usr/bin/env ruby
require "fileutils"
include FileUtils

TARGET=ARGV.first

mkdir_p "build/test"
system "./build/#{TARGET}/bin/bismite-asset-pack test/assets build/test/ abracadabra"
puts "----"

script=<<EOS
Bi::Archive.load("build/test/assets.dat","abracadabra"){|a|
  p a.filenames
  txt = a.read("assets/test.txt")
  p txt
}
EOS

File.write("build/test/unpack.rb",script)
system "./build/#{TARGET}/bin/bismite-run build/test/unpack.rb"
puts "----"
