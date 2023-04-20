#!/usr/bin/env ruby
require "FileUtils"
include FileUtils

HOST = RUBY_PLATFORM.include?("darwin") ? "macos-arm64" : "linux"
COMPILER = "build/#{HOST}/bin/bismite"
PACKER = "build/#{HOST}/bin/bismite-asset-pack"
KEY = "abracadabra"

["emscripten","emscripten-nosimd"].each{|target|
  template = "build/#{target}/share/bismite/templates/wasm-single"
  next unless Dir.exist? template
  samples_dir = "build/#{target}/samples"
  mkdir_p samples_dir

  puts `#{PACKER} samples/assets #{samples_dir} #{KEY}`

  Dir["samples/*.rb"].each{|file|
    name = File.basename(file,File.extname(file))
    puts `#{COMPILER} dump #{file} #{samples_dir}/#{name}.mrb`
    html = File.read "#{template}/index.html"
    html.gsub!("main.mrb","#{name}.mrb")
    File.write "#{samples_dir}/#{name}.html", html
  }
}
