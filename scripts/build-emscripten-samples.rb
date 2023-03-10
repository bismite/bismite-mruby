#!/usr/bin/env ruby
require "FileUtils"
include FileUtils

HOST = RUBY_PLATFORM.include?("darwin") ? "macos" : "linux"
COMPILER = "build/#{HOST}/bin/bismite"
PACKER = "build/#{HOST}/bin/bismite-asset-pack"
KEY = "abracadabra"
TEMPLATE = "build/emscripten/share/bismite/templates/wasm"
SAMPLES_DIR = "build/emscripten/samples"
mkdir_p SAMPLES_DIR

p `#{PACKER} samples/assets #{SAMPLES_DIR} #{KEY}`
Dir["samples/*.rb"].each{|file|
  name = File.basename(file,File.extname(file))
  dir = "build/emscripten/samples/#{name}/"
  p name
  rm_rf dir
  cp_r TEMPLATE, dir, verbose:true
  cp "#{SAMPLES_DIR}/assets.dat", dir
  `#{COMPILER} dump #{file} #{dir}/main.mrb`
}
