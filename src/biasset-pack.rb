#!/usr/bin/env mruby
#
# usage: biasset-pack path/to/assets destination/dir/path/ SECRET
#

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
end

def padding8(str)
  str + ([0]*(8-str.bytesize%8)).pack("C*")
end

SRC = ARGV[0]
DST = ARGV[1]
KEY = Bi::crc64 0,ARGV[2]

assets = Assets.new KEY, SRC

File.open(File.join(DST,"assets.dat"),'wb') do |out|
  # header 4byte
  out.write [1].pack('V') # assets file v2
  # index
  index = assets.index.to_msgpack
  ilen = index.bytesize
  out.write [ilen].pack('V')
  index = padding8 index
  ibuf = index.unpack("q*").map{|b| b^assets.key }.pack("q*").byteslice(0,ilen)
  out.write ibuf
  # files
  assets.files.each.with_index do |f,i|
    puts "#{f} -> #{assets.index[i]}"
    flen = assets.index[i][2]
    File.open(f,"rb"){|f|
      buf = padding8(f.read).unpack("q*").map{|b|b^assets.key}.pack("q*").byteslice(0,flen)
      out.write buf
    }
  end
end
