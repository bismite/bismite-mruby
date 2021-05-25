#!/usr/bin/env ruby

def run(cmd,args)
  puts "#{cmd} #{args.join(' ')}"
  exec cmd, *args
end

linker = ARGV.shift
args = ARGV.map{|a|
  if a.end_with?("libmruby.a") or a.end_with?("libmruby_core.a")
    "-lmruby"
  else
    a
  end
}

run linker,args
