#!/usr/bin/env ruby
require_relative "lib/utils"

def download(url,filepath)
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

files = YAML.load File.read("scripts/required_files.yml")
mkdir_p "build"
ARGV.each{|target|
  Dir.chdir("build"){
    download_dir = "download/#{target}"
    common_list = files["common"]
    target_list = files[target]
    mkdir_p download_dir
    mkdir_p target
    (common_list+target_list).each_slice(2) do |url,extract_to|
      if extract_to.empty?
        filename = File.basename(url)
        extract_name = nil
      else
        filename = extract_to[0]
        extract_name = extract_to[1]
      end
      puts "Download #{url} to #{filename}"
      filepath = File.join "download",target,filename
      download url,filepath
      if extract_name
        mkdir_p File.join(target,extract_name) rescue nil
        run "tar xf #{filepath} -C #{target}/#{extract_name} --strip-component 1"
      else
        run "tar xf #{filepath} -C #{target}"
      end
    end
  }
}
