#include <bi/bi_sdl.h>
#include <mruby.h>
#include <mruby/array.h>
#include <mruby/irep.h>
#include <mruby/dump.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "tool.h"

int main(int argc, char* argv[])
{
  // Open
  mrb_state *mrb = mrb_open();
  // ARGV
  mrb_value ARGV;
  if(argc>1){
    ARGV = mrb_ary_new_capa(mrb, argc-1);
    for (int i = 1; i < argc; i++) {
      mrb_ary_push(mrb, ARGV, mrb_str_new_cstr(mrb, argv[i]));
    }
  }else{
    ARGV = mrb_ary_new_capa(mrb, 0);
  }
  mrb_define_global_const(mrb, "ARGV", ARGV);
  // Run
  mrb_value obj = mrb_load_irep(mrb,tool);
  if (mrb->exc) {
    printf("exception:\n");
    if (mrb_undef_p(obj)) {
      mrb_p(mrb, mrb_obj_value(mrb->exc));
    } else {
      mrb_print_error(mrb);
    }
  }
  return 0;
}
