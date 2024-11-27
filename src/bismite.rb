#!/usr/bin/env bismite-mruby

MRUBY=File.join(File.expand_path(File.dirname($0)),"bismite-mruby")
MRBC=File.join(File.expand_path(File.dirname($0)),"bismite-mrbc")

class Requires
  attr_reader :files

  def initialize(mainfile,load_path)
    @mainfile = File.basename(mainfile)
    @load_path = load_path
    @dupe_check = {}
  end

  def find(filename)
    filename = filename+".rb" unless filename.end_with? ".rb"
    @load_path.find{|l|
      f = File.join(l,filename)
      return f if File.exist? f
    }
    return nil
  end

  def read(filename=nil,lineno=nil,origin=nil)
    filename = @mainfile unless filename
    filepath = find filename
    position = origin&&lineno ? "(#{origin}:#{lineno})" :  ""
    unless filepath
      puts "ERROR: #{filename} not found. #{position}"
      exit
    end
    if @dupe_check[filepath]
      puts "INFO: #{filepath} already included. #{position}"
      return []
    end
    @dupe_check[filepath] = true
    # Read source
    requires = []
    source = File.read(filepath)
    s = source.split "\n"
    s.each.with_index{|l,i|
      if l.start_with? "#require"
        next_file = l.chomp
        next_file.slice! "#require"
        next_file.gsub! '"', ''
        next_file.gsub! "'", ''
        next_file.gsub! ' ', ''
        requires += self.read next_file,i,filename
      end
    }
    requires << filepath
    return requires
  end
end

def version
  puts "bismite version 15.1.0"
end

def usage
  puts "Usage: bismite -h|--help"
  puts "Usage: bismite -v|--version"
  puts "Usage: bismite run srcfile -I<loadpath>"
  puts "Usage: bismite compile outfile srcfile -I<loadpath>"
end

def usage_and_exit
  usage
  exit
end

def valid(arg,message)
  unless arg
    puts message
    usage_and_exit
  end
end

def get_loadpaths(argv)
  loadpath=[]
  loop do
    arg = argv.shift
    if arg == nil
      break
    elsif arg == "-I"
      path = argv.shift
      valid path,"invalid path"
      loadpath << path
    elsif arg.start_with? "-I"
      loadpath << arg[2..-1]
    else
      puts "invalid option #{arg}"
      usage_and_exit
    end
  end
  loadpath
end

def command_run(argv)
  srcfile = ARGV.shift
  valid srcfile, "invalid srcfile"
  load_paths = get_loadpaths(argv).reverse + [ File.dirname(srcfile) ]
  r = Requires.new srcfile,load_paths
  tmp = r.read
  main = tmp.pop
  libs = tmp.map{|f| "-r#{f}" }
  arg = [MRUBY] + libs + [main]
  # puts arg.join(" ")
  execvp MRUBY,arg
end

def command_compile(argv)
  outfile = ARGV.shift
  valid outfile,"invalid outfile"
  srcfile = ARGV.shift
  valid srcfile,"invalid srcfile"
  load_paths = get_loadpaths(argv).reverse + [ File.dirname(srcfile) ]
  r = Requires.new srcfile,load_paths
  files = r.read
  arg = [MRBC,"-g","-o",outfile] + files
  execvp MRBC,arg
end

command = ARGV.shift
case command
when "run"
  command_run ARGV
when "compile"
  command_compile ARGV
when "-h","--help"
  usage
when "-v","--version"
  version
else
  usage_and_exit
end
