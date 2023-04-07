#include <emscripten.h>
#include <emscripten/html5.h>
#include <mruby.h>
#include <mruby/irep.h>
#include <string.h>
#include <stdlib.h>

#define MRB_FILE_PATH ( "main.mrb")

EM_JS_DEPS(sdl_deps, "$autoResumeAudioContext,$dynCall");

static void onload(unsigned int handle, void* _context, void* data, unsigned int size)
{
  uint8_t* bin = (uint8_t*)malloc(size);
  memcpy(bin,data,size);
  mrb_state *mrb = mrb_open();
  mrb_value obj = mrb_load_irep(mrb, bin );
  if (mrb->exc) {
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
  emscripten_async_wget2_data(MRB_FILE_PATH,"GET","",NULL,TRUE,onload,onerror,onprogress);
  return 0;
}
