
BUILD_DIR = File.expand_path File.join __dir__, "..", "..", "build"

def include_gems(conf)

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
  ENV['MRUBY_MSGPACK']  ? conf.gem(ENV['MRUBY_MSGPACK'])  : conf.gem(github:"bismite/mruby-simplemsgpack")
  ENV['MRUBY_BI_CORE']  ? conf.gem(ENV['MRUBY_BI_CORE'])  : conf.gem(github:'bismite/mruby-bi-core')
  ENV['MRUBY_BI_EXT']   ? conf.gem(ENV['MRUBY_BI_EXT'])   : conf.gem(github:'bismite/mruby-bi-ext')
  ENV['MRUBY_BI_SOUND'] ? conf.gem(ENV['MRUBY_BI_SOUND']) : conf.gem(github:'bismite/mruby-bi-sound')
  ENV['MRUBY_BI_ARCHIVE'] ? conf.gem(ENV['MRUBY_BI_ARCHIVE']) : conf.gem(github:'bismite/mruby-bi-archive')
  ENV['MRUBY_BI_IMAGE'] ? conf.gem(ENV['MRUBY_BI_IMAGE']) : conf.gem(github:'bismite/mruby-bi-image')
  ENV['MRUBY_BI_MISC']  ? conf.gem(ENV['MRUBY_BI_MISC'])  : conf.gem(github:'bismite/mruby-bi-misc')
  ENV['MRUBY_BI_GEOMETRY']? conf.gem(ENV['MRUBY_BI_GEOMETRY']): conf.gem(github:'bismite/mruby-bi-geometry')

  if conf.name == "emscripten"
    ENV['MRUBY_EMSCRIPTEN'] ?  conf.gem(ENV['MRUBY_EMSCRIPTEN']) : conf.gem(github:'bismite/mruby-emscripten')
  end

  ENV['MRUBY_BI_DLOPEN'] ? conf.gem(ENV['MRUBY_BI_DLOPEN']) : conf.gem(github: 'bismite/mruby-bi-dlopen')
end
