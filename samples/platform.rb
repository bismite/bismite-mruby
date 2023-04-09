
puts "mruby:      #{MRUBY_DESCRIPTION}"
puts "libbismite: #{Bi::Version.libbismite}"
puts "mruby-libbismite: #{Bi::Version.mruby_libbismite}"
puts "clang:      #{Bi::Version.clang}"
puts "gnuc:       #{Bi::Version.gnuc}"
puts "SDL linked: #{Bi::Version.sdl}"
puts "  compiled: #{Bi::Version.sdl_compiled}"

puts "platform:   #{Bi::get_platform}"
puts "pointer size: #{Bi::get_pointer_size}"
puts "endian:     #{Bi::little_endian? ? 'little' : 'big'}"

Bi.init 480,320,title:__FILE__,highdpi:false
puts "GL:         #{Bi::Version.gl_version}"
puts "GL Vendor:  #{Bi::Version.gl_vendor}"
puts "GL Renderer:#{Bi::Version.gl_renderer}"
puts "GL Shader:  #{Bi::Version.gl_shading_language_version}"
