
class Bi::Compile
  attr_reader :included_files, :line_count, :index, :code

  def initialize(mainfile,load_path=[])
    @mainfile = File.basename(mainfile)
    @load_path = [ File.dirname(mainfile) ] + load_path
    @included_files = {}
    @index = []
    @line_count = 0
    @code = ""
  end

  def run
    read @mainfile
    @header =<<EOS
begin
EOS
    @code = @header + @code
    @code +=<<EOS
rescue => e
  _FILE_INDEX_ = #{@index.to_s}
  table = []
  _FILE_INDEX_.reverse_each{|i|
    filename = i[0]
    start_line = i[1]
    end_line = i[2]
    table.fill filename, (start_line..end_line)
  }

  STDERR.puts "\#{e.class}: \#{e.message}"
  #STDERR.puts e.backtrace.join("\\n")
  e.backtrace.each{|b|
    m = b.chomp.split(":")
    if m.size < 2
      puts b
    else
      line = m[1].to_i - #{@header.lines.size} -1
      message = m[2..-1].join(":")
      original_filename = table[line]
      original_line = table[0..line].count original_filename
      STDERR.puts "\#{original_filename}:\#{original_line}:\#{message}"
    end
  }
end
EOS
  end

  def write(line)
    @code << line + "\n"
    @line_count += 1
  end

  def memory(file)
    path = File.expand_path file
    return false if @included_files[path]
    @included_files[path] = true
  end

  def read(filename)
    filename = filename+".rb" unless filename.end_with? ".rb"

    filepath = nil
    @load_path.find{|l|
      f = File.join(l,filename)
      if File.exists? f
        filepath = f
        break
      end
    }

    if filepath
      # STDERR.puts "read #{filepath}"
    else
      STDERR.puts "#{filename} not found"
      return
    end

    unless memory filepath
      STDERR.puts "#{filepath} already included."
      return
    end

    source = File.read(filepath)

    syntax_error = Bi.check_syntax filepath,source
    if syntax_error
      STDERR.puts "check_syntax failed: #{filepath} #{syntax_error}"
      raise SyntaxError
    end

    s = source.split "\n"
    s << "# #{filepath}"
    start_line = @line_count
    s.each{|l|
      if l.start_with? "$LOAD_PATH"
        write "# #{l}"
      elsif l.start_with? "require"
        next_file = l.chomp
        next_file.slice! "require"
        next_file.gsub! '"', ''
        next_file.gsub! "'", ''
        next_file.gsub! ' ', ''
        write "# #{l}"
        self.read next_file
      else
        write l
      end
    }

    @index << [filename,start_line,@line_count-1]
  end

  def handle_error_log(error_log)
    p error_log
    table = []
    @index.reverse_each{|i|
      filename = i[0]
      start_line = i[1]
      end_line = i[2]
      table.fill filename, (start_line..end_line)
    }

    error_log.each_line{|l|
      m = l.chomp.split(":")
      if m.size < 2
        puts l
      else
        line = m[1].to_i - @header.lines.size - 1
        message = m[2..-1].join(":")
        original_filename = table[line]
        if original_filename
          original_line = table[0..line].count original_filename
          puts "#{original_filename}:#{original_line}:#{message}"
        else
          puts l
        end
      end
    }
  end
end

class Restorer
  def initialize
    tmp = []

    fileline = {}
    @index = tmp.each.with_index.map{|filename,i|
      fileline[filename] = fileline[filename].to_i + 1
      "#{filename}:#{fileline[filename]}"
    }
  end

  def restore(message)
    m = message.chomp.split(":")
    if m.size < 2
      print "#{message}"
    else
      line = m[1].to_i + 1
      text = m[2..-1].join(":")
      puts "#{@index[line]}:#{text}"
    end
  end
end

def option_parse(argv)
  loadpath=[]
  stat = nil
  args_start = nil
  argv.each_with_index{|a,i|
    if a == "-I"
      stat = :loadpath
    elsif a.start_with? "-I"
      loadpath << a[2..-1]
    elsif stat == :loadpath
      loadpath << a
      stat = nil
    else
      stat = nil
      args_start = i
      break
    end
  }
  args = argv[args_start..-1]
  return loadpath,args
end

#
# Run script
#
def run
  if ARGV == ["-h"] or ARGV == ["--help"] or ARGV.size < 1
    puts "Usage: bismite-run [-I /load/path] source.rb [arguments]"
    exit 1
  end
  load_path,args = option_parse ARGV
  infile = args.shift

  compile = Bi::Compile.new infile, load_path
  begin
    compile.run
  rescue SyntaxError => e
    exit 1
  end

  result = Bi.run infile, compile.code, args
  if result
    STDERR.puts result
  end
end

#
# Compile script
#
def compile
  usage = "Usage: bismite-compile [-I load/path] source.rb out.{mrb|rb}"

  if ARGV == ["-h"] or ARGV == ["--help"] or ARGV.size < 2
    puts usage
    exit 1
  end
  load_path,args = option_parse ARGV
  infile = args.shift.to_s
  outfile = args.shift.to_s

  if not (outfile.end_with? ".rb" or outfile.end_with? ".mrb")
    puts "invalid output file name: #{outfile}"
    puts usage
    exit 1
  end

  compile = Bi::Compile.new infile, load_path

  begin
    compile.run
  rescue SyntaxError => e
    exit 1
  end

  dir = File.dirname outfile
  dirs = dir.split File::SEPARATOR
  dirs.inject(""){|sum,d|
    new_dir = sum.empty? ? d : File.join(sum,d)
    Dir.mkdir new_dir unless Dir.exist? new_dir
    new_dir
  }

  if outfile.end_with? ".mrb"
    error_message = Bi.compile( infile, compile.code, outfile )
    if error_message
      STDERR.puts "compile failed..."
      STDERR.puts error_message
      exit 1
    end
  elsif outfile.end_with? ".rb"
      File.open(outfile,"wb").write(compile.code)
  end
end
