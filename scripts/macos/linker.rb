#!/usr/bin/env ruby

def run(cmd)
  # puts cmd
  `#{cmd}`
end

args = ARGV.map{|a|
  if a.end_with?("libmruby.a") or a.end_with?("libmruby_core.a")
    "-lmruby"
  else
    a
  end
}.join(" ")

run "clang #{args}"
