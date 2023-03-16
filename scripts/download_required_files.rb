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
ARGV.each{|target|
  Dir.chdir("build"){
    download_dir = "download/#{target}"
    common_list = files["common"]
    if target == "emscripten-nosimd"
      target_list = files["emscripten"]
    else
      target_list = files[target]
    end
    mkdir_p download_dir
    mkdir_p target
    (common_list+target_list).each_slice(2) do |url,commands|
      if url.is_a? Array
        extract_name = url[2]
        filename = url[1]
        url = url[0]
      else
        filename = File.basename(url)
        extract_name = nil
      end
      p [url,filename,extract_name,commands]
      filepath = File.join "download",target,filename
      download url,filepath
      if extract_name
        mkdir_p File.join(target,extract_name) rescue nil
        run "tar xf #{filepath} -C #{target}/#{extract_name} --strip-component 1"
      else
        run "tar xf #{filepath} -C #{target}"
      end
      Dir.chdir(target){
        commands.each{|command| run command }
      }
    end
  }
  # Patch to mruby
  cp "src/mrb_ro_data_p.macos.c", "build/#{target}/mruby/src/"
}
