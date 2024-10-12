#!/usr/bin/env ruby
require "FileUtils"
include FileUtils

def run(cmd)
  puts cmd
  result = IO.popen(cmd,err:[:child,:out]){|io|io.read}.strip
  # result = `#{cmd}`.strip
  puts result unless result.empty?
end

HOST = RUBY_PLATFORM.include?("darwin") ? "macos" : "linux"
KEY = "abracadabra"

template = "build/emscripten/template-emscripten/wasm-single"
unless Dir.exist? template
  puts "missing: #{template}"
  exit
end

dst_dir = "build/emscripten/samples"
mkdir_p dst_dir
run "build/#{HOST}/bin/bismite-asset-pack samples/assets #{dst_dir} #{KEY}"

Dir.chdir("samples"){
  compiler = "../build/#{HOST}/bin/bismite"
  template = File.join "../", template
  dst_dir = File.join "../", dst_dir
  Dir["*.rb"].each{|file|
    name = File.basename(file,File.extname(file))
    if file=="require2.rb"
      cmd = "#{compiler} compile #{dst_dir}/#{name}.mrb #{file} -Ilib"
    else
      cmd = "#{compiler} compile #{dst_dir}/#{name}.mrb #{file}"
    end
    run cmd
    html = File.read "#{template}/index.html"
    html.gsub!("main.mrb","#{name}.mrb")
    File.write "#{dst_dir}/#{name}.html", html
  }
}
