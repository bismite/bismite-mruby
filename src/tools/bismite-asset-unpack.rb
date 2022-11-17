
if ARGV.size != 3
  puts "usage: bismite-asset-unpack path/to/assets.dat destination/dir/path/ SECRET"
  exit 1
end
SRC = ARGV[0]
DST = ARGV[1]
KEY = Bi::crc64 0,ARGV[2]

def mkdir_p(dst)
  dirs = dst.split("/").reject(&:empty?)
  dir = dst.start_with?("/") ? "" : "."
  dirs.each{|d|
    dir = File.join dir,d
    begin
      Dir.mkdir dir
    rescue Errno::EEXIST => e
      # nop
    end
  }
end

def padding8(str)
  str + ([0]*(8-str.bytesize%8)).pack("C*")
end

def decrypt(buf,len,key)
  padding8(buf).unpack("q*").map{|b|b^key}.pack("q*").byteslice(0,len)
end

def decrypt2(dst,f,key)
  ilen = f.read(4).unpack("V").first
  puts "index length: #{ilen}"
  index = JSON::load decrypt(f.read,ilen,KEY)
  # files
  file_section_start = 4 + 4 + ilen
  index.each{|fname,foffset,flen|
    puts "#{fname} (#{flen}Bytes)"
    f.seek file_section_start+foffset
    bin = decrypt(f.read,flen,KEY)
    path = File.join(dst,fname)
    mkdir_p File.dirname path
    File.open(path,"wb"){|out| out.write bin }
  }
end

File.open(SRC) do |f|
  header = f.read(4)
  case header.bytes[0]
  when 0
    raise "v1 assets not supported."
  when 1
    raise "v2 assets not supported."
  when 2
    decrypt2 DST,f,KEY
  else
    raise "invalid assets file."
  end
end
