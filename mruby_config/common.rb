
BUILD_DIR = File.expand_path File.join __dir__, "..", "build"
SCRIPTS_DIR = File.expand_path File.join __dir__, "..", "scripts"

def include_gems(conf,target,without_bin=false)

  Dir.glob("#{root}/mrbgems/mruby-*/mrbgem.rake") do |x|
    next if without_bin and x.include? "mruby-bin-"
    g = File.basename File.dirname x
    conf.gem :core => g unless g =~ /^mruby-(bin-debugger|test)$/
  end

  conf.gem github: 'katzer/mruby-os'
  conf.gem github: 'ksss/mruby-singleton'
  conf.gem github: 'iij/mruby-env'
  conf.gem github: 'iij/mruby-iijson'
  ENV['MRUBY_LIBBISMITE']? conf.gem(ENV['MRUBY_LIBBISMITE']): conf.gem("#{BUILD_DIR}/#{target}/mruby-libbismite")
  ENV['MRUBY_BI_MISC']   ? conf.gem(ENV['MRUBY_BI_MISC'])   : conf.gem("#{BUILD_DIR}/#{target}/mruby-bi-misc")
end
