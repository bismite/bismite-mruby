#!/usr/bin/env ruby
require "FileUtils"
include FileUtils

HOST = RUBY_PLATFORM.include?("darwin") ? "macos" : "linux"
COMPILER = File.expand_path  "build/#{HOST}/bin/bismite"
PACKER = File.expand_path  "build/#{HOST}/bin/bismite-asset-pack"
KEY = "abracadabra"

template = File.expand_path "build/emscripten/share/bismite/templates/wasm-single"
dst_dir = File.expand_path "build/emscripten/samples"

unless Dir.exist? template
  puts "missing: #{template}"
  exit
end
puts "mkdir -p #{dst_dir}"
mkdir_p dst_dir

puts `#{PACKER} samples/assets #{dst_dir} #{KEY}`

Dir.chdir("samples"){
  Dir["*.rb"].each{|file|
    name = File.basename(file,File.extname(file))
    puts `#{COMPILER} compile #{dst_dir}/#{name}.mrb #{file}`
    html = File.read "#{template}/index.html"
    html.gsub!("main.mrb","#{name}.mrb")
    File.write "#{dst_dir}/#{name}.html", html
  }
}
