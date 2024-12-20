# bismite-mruby

<https://bismite.github.io/demos/>

# Usage example
`bismite run main.rb` / `bismite compile output-file.mrb main.rb -I lib`

# Build
## macOS
1. install Xcode
2. run `./make.rb macos`

## Linux
1. install libgl-dev, clang, and ruby (e.g. `sudo apt install libgl-dev clang ruby`)
2. run `./make.rb linux`

## Emscripten
1. install [emsdk](https://github.com/emscripten-core/emsdk) and enable emscripten
2. run `./make.rb emscripten`

## mingw-w64
1. install mingw-w64
2. run `./make.rb mingw`

# Changelog
## 16.2.0 - 2024/12/21
- add mruby-bi-crc, update mruby-bi-misc 5.0.0
## 16.1.0
- update libbismite 13.0.0, mruby-libbismite 10.1.0.
  - more robust timer processing.
  - add Bi::Timer#node, Bi::Node#timers
## 16.0.0 - 2024/12/05
- update libbismite 12.3.1
  - call glFlush() after framebuffer drawed.
- update mruby-libbismite 10.0.0
  - rename function Bi::ShaderNode#z_order -> Bi::ShaderNode#z
## 15.1.0 - 2024/11/28
- update libbismite 12.3.0
  - fix image flip.
- update mruby-libbismite 9.1.0
  - add TextureMapping class. add Bi::Node#set_texture_mapping()
  - add Bi::Node#children
## 15.0.0
- update libbismite 12.2.0
- update mruby-libbismite 9.0.0
- update emscripten 3.1.71
- update samples
  - use framebuffer textures attribute, remove scale uniform from shaders.
## 14.0.0
- update libbismite 12.1.1
- update mruby-libbismite 8.1.0
- update samples.
- add new sample: framebuffer-node.rb, framebuffer-mrt.rb
- rename samples/transition.rb -> samples/shader-transition.rb
## 13.0.0 - 2024/11/03
- update libbismite 11.0.0
  - Cropped textures are now handled by shaders.
- fix samples: fix deprecated `set_color` (event-keyboard.rb, event-menu.rb, event-trace-cursor.rb, geometry-rectangle.rb, spotlight.rb, strech_box.rb)
## 12.0.0 - 2024/10/28
- update mruby-libbismite 7.2.0
  - new function `Bi::Node.rect` etc
  - update `Bi::Node#add` with position
  - add `String#to_color`, `Integer#to_color`
  - `Bi::Node#color=` accepts `Bi::Color`, `Integer`, `String`
  - see <https://github.com/bismite/mruby-libbismite>
- add new samples: version.rb, simple.rb, shader-collapse.rb, color-setter.rb
- update samples: color-tint.rb, label-linewrap.rb, label.rb
- bismite.rb use bismite-mruby/bismite-mrbc in same directory
## 11.0.2 - 2024/10/13
- fix bismite.rb
## 11.0.1 - 2024/10/13
- update mruby-bi-misc 4.2.0, execvp for bismite.rb
## 11.0.0 - 2024/10/06
- rename mruby,mirb,mruby-strip -> bismite-mruby,bismite-mirb,bismite-mruby-strip
- Change bismite command from executable binary to script.
- `bismite run` and `bismite compile` handles `#require foo/bar` macro for import other `.rb` file.
  - see `samples/require.rb`, `samples/require2.rb`,
## 10.0.1 - 2024/09/14
- update mruby 3.3.0
- update libbismite 10.0.3
- remove emscripten-nosimd build.
- update emscripten 3.1.64
- no longer support x86_64 for macos.
## 9.0.1 - 2023/04/20
- add MRB_ARY_LENGTH_MAX=0
## 9.0.0 - 2023/04/07
- update libbismite 8.0.2
- update mruby-libbismite : add actions(FadeOut,FadeIn,ScaleTo,ScaleBy,MoveBy)
- update samples for action
## 8.0.0 - 2023/04/07
- update mruby-bi-misc 4.0.1
- update mruby-libbismite 5.0.0
- add mruby-sdl-mixer 1.0.0 (and update samples/sound.rb)
- update libbismite 7.0.2 (SDL 2.26.5)
- mruby_config : gem removed (mruby-os and mruby-singleton)
## 7.0.0 - 2023/03/23
- license changed : MIT license
- update mruby-3.2.0
- update libbismite 6.0.5 (SDL-2.26.4, SDL_image-2.6.3, SDL_mixer-2.6.3)
- update mruby-bi-misc 2.1.1
- arm64/x86_64 splitted in macos build.
## 6.0.5 - 2022/11/19
- add autoremove flag to actions
- remove yaml and msgpack support
- archive version3 (use json instead of msgpack)
- update workflows
- update mruby-emscripten 1.0.1
- mruby-libbismite 4.1.0
- libbismite 6.0.2
- O3 optimize
- update mruby-bi-misc 2.0.1
## 5.0.0 - 2022/11/7
- libbismite 6.0.0
- mruby-libbismite 4.0.0
- update samples
- fix samples/line_of_sight.rb and samples/rect_collide.rb
## 4.0.0
- libbismite 5.0.0 (include SDL2 2.24.1, SDL2_image 2.6.2, SDL2_mixer 2.6.2)
- update shaders in sample
- mruby-bi-misc 0.6.1
- emscripten: js template removed
- add emscripten-nosimd
