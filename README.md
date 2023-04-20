# bismite-mruby

<https://bismite.github.io/demos/>

## build on macOS
1. install Xcode
2. run `./make.rb macos-arm64` or `./make.rb macos-x86_64`

## build on Linux
1. install libgl-dev, clang, and ruby (e.g. `sudo apt install libgl-dev clang ruby`)
2. run `./make.rb linux`

## Emscripten
1. install [emsdk](https://github.com/emscripten-core/emsdk) and enable emscripten
2. run `./make.rb emscripten` or `./make.rb emscripten-nosimd`

## mingw-w64
1. install mingw-w64
2. run `./make.rb mingw`

# Changelog
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
