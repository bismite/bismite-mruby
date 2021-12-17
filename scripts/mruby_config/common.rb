
BUILD_DIR = File.expand_path File.join __dir__, "..", "..", "build"

def include_gems(conf,target)

  Dir.glob("#{root}/mrbgems/mruby-*/mrbgem.rake") do |x|
    next if conf.name == "emscripten" and x.include? "mruby-bin-"
    g = File.basename File.dirname x
    conf.gem :core => g unless g =~ /^mruby-(bin-debugger|test)$/
  end

  conf.gem github: 'katzer/mruby-os'
  conf.gem github: 'ksss/mruby-singleton'
  conf.gem github: 'iij/mruby-env'
  conf.gem github: 'iij/mruby-dir'
  conf.gem github: 'iij/mruby-iijson'
  conf.gem github: 'iij/mruby-env'
  conf.gem github: "mrbgems/mruby-yaml"
  ENV['MRUBY_MSGPACK']   ? conf.gem(ENV['MRUBY_MSGPACK'])   : conf.gem(github:"bismite/mruby-simplemsgpack")
  ENV['MRUBY_LIBBISMITE']? conf.gem(ENV['MRUBY_LIBBISMITE']): conf.gem("#{BUILD_DIR}/#{target}/mruby-libbismite")
  ENV['MRUBY_BI_MISC']   ? conf.gem(ENV['MRUBY_BI_MISC'])   : conf.gem("#{BUILD_DIR}/#{target}/mruby-bi-misc")
  if conf.name == "emscripten"
    ENV['MRUBY_EMSCRIPTEN'] ? conf.gem(ENV['MRUBY_EMSCRIPTEN']) : conf.gem(github:'bismite/mruby-emscripten')
  end
end
