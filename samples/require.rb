require "require2.rb"

puts "OS:         #{OS.sysname}(#{OS.machine})"
puts "mruby:      #{MRUBY_DESCRIPTION}"
puts "libbismite: #{Bi::Version.libbismite}"
puts "mruby-libbismite: #{Bi::Version.mruby_libbismite}"
puts "clang:      #{Bi::Version.clang}"
puts "gnuc:       #{Bi::Version.gnuc}"
puts "SDL linked: #{Bi::Version.sdl}"
puts "  compiled: #{Bi::Version.sdl_compiled}"

Bi.init 480,320,title:__FILE__,highdpi:false
puts "GL:         #{Bi::Version.gl_version}"
puts "GL Vendor:  #{Bi::Version.gl_vendor}"
puts "GL Renderer:#{Bi::Version.gl_renderer}"
puts "GL Shader:  #{Bi::Version.gl_shading_language_version}"

p [:ARGV, ARGV]
p [:dollar_zero, $0]

puts "this is require.rb"
Foo.test
