#!/usr/bin/env ruby
require_relative "utils"

TARGET = ARGV.first
DOWNLOAD_DIR="download/#{TARGET}"
LIB_VER="10.2.0"
LIB_NAME="libbismite-#{TARGET}-#{LIB_VER}.tgz"
LIB_URL="https://github.com/bismite/libbismite/releases/download/#{LIB_VER}/#{LIB_NAME}"
GITHUB_URLS = [
  %w(mruby mruby 3.3.0),
  ENV["MRUBY_LIBBISMITE"] ? nil : %w(bismite mruby-libbismite 7.2.0),
  ENV["MRUBY_BI_MISC"] ? nil : %w(bismite mruby-bi-misc 4.2.0),
  ENV["MRUBY_SDL_MIXER"] ? nil : %w(bismite mruby-sdl-mixer 1.0.0),
  ENV["MRUBY_EMSCRIPTEN"] ? nil : %w(bismite mruby-emscripten 2.0.0)
].compact

def download(url,filepath)
  puts "Download #{url} to #{filepath}"
  if File.exist? filepath
    puts "already downloaded #{filepath}"
  else
    if which "curl"
      run "curl -JL#S -o #{filepath} #{url}"
    elsif which "wget"
      run "wget -O #{filepath} #{url}"
    else
      raise "require curl or wget"
    end
  end
  unless File.exist? filepath
    raise "download failed: #{url}"
  end
end

def extract(archive_path,to)
  run "tar xf #{archive_path} -C #{to}"
end

mkdir_p "build"
Dir.chdir("build"){
  mkdir_p DOWNLOAD_DIR
  mkdir_p TARGET
  # libbismite
  if ENV["LIBBISMITE_ARCHIVE"]
    extract ENV["LIBBISMITE_ARCHIVE"],TARGET
  else
    download LIB_URL,"#{DOWNLOAD_DIR}/#{LIB_NAME}"
    extract "#{DOWNLOAD_DIR}/#{LIB_NAME}",TARGET
  end
  # github
  GITHUB_URLS.each{|dir,name,ver|
    url = "https://github.com/#{dir}/#{name}/archive/refs/tags/#{ver}.tar.gz"
    filepath = "#{DOWNLOAD_DIR}/#{name}-#{ver}.tgz"
    download url,filepath
    extract filepath,TARGET
    rm_rf "#{TARGET}/#{name}"
    mv "#{TARGET}/#{name}-#{ver}", "#{TARGET}/#{name}"
  }
}
