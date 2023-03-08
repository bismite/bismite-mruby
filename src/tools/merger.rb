HEADER = "begin"

FOOTER = <<EOS
rescue => e
  _FILE_INDEX_ = %index%
  table = []
  _FILE_INDEX_.reverse_each{|i|
    filename = i[0]
    start_line = i[1]
    end_line = i[2]
    table.fill filename, (start_line..end_line)
  }
  STDERR.puts "\#{e.class}: \#{e.message}"
  e.backtrace.each{|b|
    m = b.chomp.split(":")
    if m.size < 2
      puts b
    else
      line = m[1].to_i - %header_lines% -1
      message = m[2..-1].join(":")
      original_filename = table[line]
      original_line = table[0..line].count original_filename
      STDERR.puts "  \#{original_filename}:\#{original_line}:\#{message}"
    end
  }
end
EOS

class Merger
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
    if read @mainfile
      header = HEADER+"\n"
      footer = FOOTER
      footer = footer.gsub("%index%", @index.to_s)
      footer = footer.gsub("%header_lines%", header.lines.size.to_s)
      footer = "\n" + footer
      @code = header + @code + footer
      return @code
    end
    return nil
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
      return true
    end

    unless memory filepath
      STDERR.puts "#{filepath} already included."
      return true
    end

    source = File.read(filepath)

    return false unless check_syntax(filepath,source)

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
        return false unless self.read next_file
      else
        write l
      end
    }

    @index << [filename,start_line,@line_count-1]
    return true
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

loadpath,args = option_parse ARGV
mainfile = args.shift
Merger.new(mainfile,loadpath).run
