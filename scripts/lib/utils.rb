require "fileutils"
require "yaml"
require 'digest'

include FileUtils

begin
  require "colorize"
rescue LoadError
  String.class_eval do
    alias :yellow :to_s
    alias :red :to_s
    alias :green :to_s
  end
end

def run(cmd)
  puts "#{cmd}".green
  system cmd
  unless $?.success?
    puts "failed #{cmd}".red
    exit 1
  end
end

def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
  end
  nil
end

def install_path(target)
  root = File.absolute_path(File.join( File.dirname(File.expand_path(__FILE__)), "../.." ))
  case target
  when "macos"
    "#{root}/build/#{target}"
  when "linux","mingw","emscripten"
    "#{root}/build/#{target}"
  else
    raise "target name invalid: #{target}"
  end
end
