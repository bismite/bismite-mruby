#!/usr/bin/env ruby
require "FileUtils"
include FileUtils

HOST = RUBY_PLATFORM.include?("darwin") ? "macos-arm64" : "linux"
COMPILER = "build/#{HOST}/bin/bismite"
PACKER = "build/#{HOST}/bin/bismite-asset-pack"
KEY = "abracadabra"

["emscripten","emscripten-nosimd"].each{|target|
  template = "build/#{target}/share/bismite/templates/wasm"
  samples_dir = "build/#{target}/samples"
  mkdir_p samples_dir

  p `#{PACKER} samples/assets #{samples_dir} #{KEY}`
  Dir["samples/*.rb"].each{|file|
    name = File.basename(file,File.extname(file))
    dir = "#{samples_dir}/#{name}/"
    p name
    rm_rf dir
    cp_r template, dir, verbose:true
    cp "#{samples_dir}/assets.dat", dir
    `#{COMPILER} dump #{file} #{dir}/main.mrb`
  }
}
