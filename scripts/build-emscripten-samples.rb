#!/usr/bin/env ruby
require "FileUtils"
include FileUtils

HOST = RUBY_PLATFORM.include?("darwin") ? "macos" : "linux"
COMPILER = "build/#{HOST}/bin/bismite"
PACKER = "build/#{HOST}/bin/bismite-asset-pack"
KEY = "abracadabra"

template = "build/emscripten/share/bismite/templates/wasm-single"
samples_dir = "build/emscripten/samples"

unless Dir.exist? template
  puts "missing: #{template}"
  exit
end
puts "mkdir -p #{samples_dir}"
mkdir_p samples_dir

puts `#{PACKER} samples/assets #{samples_dir} #{KEY}`

Dir["samples/*.rb"].each{|file|
  name = File.basename(file,File.extname(file))
  puts `#{COMPILER} compile #{samples_dir}/#{name}.mrb #{file}`
  html = File.read "#{template}/index.html"
  html.gsub!("main.mrb","#{name}.mrb")
  File.write "#{samples_dir}/#{name}.html", html
}
