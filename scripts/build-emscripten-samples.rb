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
BISMITE = File.expand_path "build/#{HOST}/bin/bismite"
TEMPLATE = File.expand_path "build/emscripten/template-emscripten/wasm-single"
KEY = "abracadabra"

unless File.exist? BISMITE
  puts "missing: #{BISMITE}"
  exit
end

unless Dir.exist? TEMPLATE
  puts "missing: #{TEMPLATE}"
  exit
end

def compile(dir)
  dst_dir = File.expand_path "build/emscripten/#{dir}"
  mkdir_p dst_dir
  assets_dir = "#{dir}/assets"
  if Dir.exist? assets_dir
    run "build/#{HOST}/bin/bismite-asset-pack #{assets_dir} #{dst_dir} #{KEY}"
  end
  Dir.chdir(dir){
    Dir["*.rb"].each{|file|
      name = File.basename(file,File.extname(file))
      if file=="require2.rb"
        cmd = "#{BISMITE} compile #{dst_dir}/#{name}.mrb #{file} -Ilib"
      else
        cmd = "#{BISMITE} compile #{dst_dir}/#{name}.mrb #{file}"
      end
      run cmd
      html = File.read "#{TEMPLATE}/index.html"
      html.gsub!("main.mrb","#{name}.mrb")
      File.write "#{dst_dir}/#{name}.html", html
    }
  }
end

compile "samples"
compile "test"
