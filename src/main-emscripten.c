#include <emscripten.h>
#include <emscripten/html5.h>
#include <mruby.h>
#include <mruby/irep.h>
#include <mruby/array.h>
#include <mruby/variable.h>
#include <mruby/error.h>
#include <mruby/presym.h>
#include <string.h>
#include <stdlib.h>

int _argc;
char** _argv;
const char *_mrb_file;

#define DEFAULT_MRB_FILE_PATH ( "main.mrb")

EM_JS_DEPS(sdl_deps, "$autoResumeAudioContext,$dynCall");

static void _define_argv(mrb_state *mrb, int argc, const char* argv[])
{
  mrb_value ARGV;
  if(argc>2){
    ARGV = mrb_ary_new_capa(mrb, argc-2);
    for (int i=2; i<argc; i++) {
      mrb_ary_push(mrb, ARGV, mrb_str_new_cstr(mrb, argv[i]));
    }
  }else{
    ARGV = mrb_ary_new_capa(mrb, 0);
  }
  mrb_define_global_const(mrb, "ARGV", ARGV);
}

static void onload(unsigned int handle, void* _context, void* data, unsigned int size)
{
  uint8_t* bin = (uint8_t*)malloc(size);
  memcpy(bin,data,size);
  mrb_state *mrb = mrb_open();
  _define_argv( mrb, _argc, (const char**)_argv );
  mrb_gv_set(mrb, mrb_intern_lit(mrb, "$0"), mrb_str_new_cstr(mrb, _mrb_file));
  mrb_value obj = mrb_load_irep(mrb, bin );
  if (mrb->exc) {
    MRB_EXC_CHECK_EXIT(mrb, mrb->exc);
    if (mrb_undef_p(obj)) {
      mrb_p(mrb, mrb_obj_value(mrb->exc));
    } else {
      mrb_print_error(mrb);
    }
  }
}

static void onerror(unsigned int handle, void *_context, int http_status_code, const char* desc)
{
  printf("%d onerror %d : %s\n",handle,http_status_code,desc);
}

static void onprogress(unsigned int handle, void *_context, int loaded, int total)
{
  printf("%d onprogress %d/%d\n", handle, loaded, total);
}

int main(int argc, char* argv[])
{
  _mrb_file = DEFAULT_MRB_FILE_PATH;
  _argc = argc;
  for(int i=0;i<argc;i++){
    _argv[i] = malloc(strlen(argv[i])+1);
    strcpy(_argv[i],argv[i]);
  }
  if(argc>1) _mrb_file = _argv[1];
  emscripten_async_wget2_data(_mrb_file,"GET","",NULL,TRUE,onload,onerror,onprogress);
  return 0;
}
