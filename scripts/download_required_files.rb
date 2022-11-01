#!/usr/bin/env ruby
require_relative "lib/utils"

def download(url,filepath)
  if File.exists? filepath
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
  unless File.exists? filepath
    raise "download failed: #{url}"
  end
end

files = YAML.load File.read("scripts/required_files.yml")
mkdir_p "build"
Dir.chdir("build"){
  ARGV.each{|target|
    download_dir = "download/#{target}"
    common_list = files["common"]
    target_list = files[target]
    mkdir_p download_dir
    mkdir_p target
    (common_list+target_list).each_slice(3) do |url,filename,commands|
      if filename.is_a? Array
        extract_name = filename.last
        filename = filename.first
      else
        extract_name = nil
      end
      filepath = File.join "download",target,filename
      download url,filepath
      if extract_name
        mkdir_p File.join(target,extract_name)
        run "tar xf #{filepath} -C #{target}/#{extract_name} --strip-component 1"
      else
        run "tar xf #{filepath} -C #{target}"
      end
      Dir.chdir(target){
        commands.each{|command| run command }
      }
    end
  }
}
