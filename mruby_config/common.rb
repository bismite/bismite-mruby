
BUILD_DIR = File.expand_path File.join __dir__, "..", "build"
SCRIPTS_DIR = File.expand_path File.join __dir__, "..", "scripts"
COMMON_DEFINES = %w(
  MRB_INT64
  MRB_UTF8_STRING
  MRB_NO_BOXING
  MRB_NO_DEFAULT_RO_DATA_P
  MRB_STR_LENGTH_MAX=0
  MRB_ARY_LENGTH_MAX=0
)
COMMON_CFLAGS = %w(-Wall -Werror-implicit-function-declaration -Wwrite-strings -std=c11 -O2 -g0)

def include_gems(conf,target,without_bin=false)

  Dir.glob("#{root}/mrbgems/mruby-*/mrbgem.rake") do |x|
    next if without_bin and x.include? "mruby-bin-"
    g = File.basename File.dirname x
    conf.gem :core => g unless g =~ /^mruby-(bin-debugger|test)$/
  end

  conf.gem github: 'iij/mruby-env'
  conf.gem github: 'iij/mruby-iijson'
  conf.gem( ENV['MRUBY_LIBBISMITE'] || "#{BUILD_DIR}/#{target}/mruby-libbismite" )
  conf.gem( ENV['MRUBY_BI_MISC']    || "#{BUILD_DIR}/#{target}/mruby-bi-misc" )
  conf.gem( ENV['MRUBY_SDL_MIXER']  || "#{BUILD_DIR}/#{target}/mruby-sdl-mixer" )
  conf.gem( ENV['MRUBY_EMSCRIPTEN'] || "#{BUILD_DIR}/#{target}/mruby-emscripten" )
end
