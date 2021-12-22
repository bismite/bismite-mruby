#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV[0]
LICENSE_DIR = "build/#{TARGET}/licenses"

def concat(out,files)
  files.each{|l| out.puts <<EOS
# #{File.basename(l)}
```
#{File.read(l)}
```

----
EOS
  }
end

mkdir_p LICENSE_DIR
cp "src/licenses/mruby-and-libraries-licenses.txt", LICENSE_DIR
case TARGET
when /mingw/
  Dir["src/licenses/mingw/*"].each{|f| cp f,LICENSE_DIR }
when /emscripten/
  EMDIR = File.dirname which "emcc"
  cp "#{EMDIR}/LICENSE", "#{LICENSE_DIR}/emscripten-LICENSE"
  cp "#{EMDIR}/AUTHORS", "#{LICENSE_DIR}/emscripten-AUTHORS"
  cp "#{EMDIR}/system/lib/libc/musl/COPYRIGHT", "#{LICENSE_DIR}/musl-COPYRIGHT"
end

File.open("build/#{TARGET}/Licenses.md","w"){|f|
  concat f,Dir["build/#{TARGET}/licenses/*"].sort.reverse
}

File.open("build/#{TARGET}/Licenses-static.md","w"){|f|
  list = Dir["build/#{TARGET}/licenses/*"].sort.reverse
  list.reject!{|f| f.include? "mpg123" }
  concat f,list
}
