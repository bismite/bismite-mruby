#!/usr/bin/env ruby
require "fileutils"
include FileUtils

TARGET=ARGV.first
BISMITE_RUN = File.absolute_path("build/#{TARGET}/bin/bismite-run")

mkdir_p "build/test"
system "./build/#{TARGET}/bin/bismite-asset-pack test/assets build/test/ abracadabra"
puts "----"

script=<<EOS
Bi::Archive.load("assets.dat","abracadabra"){|a|
  p a.filenames
  txt = a.read("assets/test.txt")
  p txt
}
EOS

File.write("build/test/unpack.rb",script)
Dir.chdir("build/test"){
  system "#{BISMITE_RUN} unpack.rb"
}
puts "----"
