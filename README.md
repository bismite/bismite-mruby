# bismite-mruby

## build on macOS
1. install Xcode
2. run `./make.rb macos`

## build on Linux
1. install libsdl2-dev, libsdl2-image-dev, libsdl2-mixer-dev, clang, and ruby
2. run `./make.rb linux`

## Emscripten
1. install [emsdk](https://github.com/emscripten-core/emsdk) and enable emscripten
2. run `./make.rb emscripten`

## mingw-w64
1. install mingw-w64
2. run `./make.rb mingw`

# Changelog
## 6.0.0 - 2022/11/14
- add autoremove flag to actions
- remove yaml and msgpack support
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
