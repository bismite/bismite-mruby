
if ARGV.size != 3
  puts "usage: bismite-asset-pack path/to/assets destination/dir/path/ SECRET"
  exit 1
end
SRC = ARGV[0]
DST = ARGV[1]
KEY = Bi::crc64 0,ARGV[2]

class Assets
  attr_reader :files, :index, :key
  def initialize(key,source_dir)
    @key = key
    @source_dir = source_dir
    @start = 0
    @files = []
    @index = []
    search(source_dir,"")
  end
  def search(dir,parent)
    Dir.entries(dir).each{|f|
      next if f.start_with?(".")
      path = File.join dir,f
      r = if File.directory? path
        search path, File.join(parent,f)
      else
        size = File.size path
        @files << path
        name = File.join "assets",parent,f
        @index << [name,@start,size]
        @start += size
      end
    }
  end
  def padding8(str)
    str + ([0]*(8-str.bytesize%8)).pack("C*")
  end
  def encrypt(buf,len)
    # pack "q" : 64bit signed int
    padding8(buf).unpack("q*").map{|b| b^@key }.pack("q*").byteslice(0,len)
  end
end

File.open(File.join(DST,"assets.dat"),'wb') do |out|
  puts "#{out.path}"
  assets = Assets.new KEY, SRC
  # header 4byte
  out.write [1].pack('V') # assets file v2
  # index
  index = assets.index.to_msgpack
  ilen = index.bytesize
  out.write [ilen].pack('V')
  out.write assets.encrypt(index,ilen)
  puts "index #{ilen} Bytes"
  # files
  assets.files.each.with_index do |f,i|
    puts "#{f} -> #{assets.index[i][0]} (#{assets.index[i][2]}Bytes)"
    File.open(f,"rb"){|f|
      out.write assets.encrypt(f.read, assets.index[i][2])
    }
  end
end
