#!/usr/bin/env ruby
require_relative "../lib/utils"

mkdir_p "build/macos"
run "tar zxf build/download/macos/SDL-macOS-UniversalBinaries.tgz -C build/macos"
cp_r "build/macos/SDL-macOS-UniversalBinaries/lib", "build/macos", remove_destination:true
cp_r "build/macos/SDL-macOS-UniversalBinaries/include", "build/macos", remove_destination:true
cp_r "build/macos/SDL-macOS-UniversalBinaries/licenses", "build/macos", remove_destination:true
