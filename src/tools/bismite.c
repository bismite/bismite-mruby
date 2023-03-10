#include <stdlib.h>
#include <stdbool.h>
#include <mruby.h>
#include <mruby/irep.h>
#include <mruby/dump.h>
#include <mruby/array.h>
#include <mruby/string.h>
#include <mruby/proc.h>
#include <mruby/variable.h>
#if MRUBY_RELEASE_NO >= 30200
#include <mruby/internal.h>
#endif
#include "merger.h"

static void print_parse_error(struct mrb_parser_state *p)
{
  if(!p) return;
  if (p->filename_sym) {
    const char *filename = mrb_sym_name_len(p->mrb, p->filename_sym, NULL);
    for(uint32_t i=0; i<p->nerr; i++) {
      printf("file %s line %d:%d: %s\n",
        filename,
        p->error_buffer[i].lineno,
        p->error_buffer[i].column,
        p->error_buffer[i].message
      );
    }
  }else{
    for(uint32_t i=0; i<p->nerr; i++) {
      printf("line %d:%d: %s\n",
        p->error_buffer[i].lineno,
        p->error_buffer[i].column,
        p->error_buffer[i].message
      );
    }
  }
}

static bool check_syntax(mrb_state* mrb, const char* filename, const char* source)
{
  bool result = false;
  struct mrb_parser_state *p;
  mrbc_context *c = mrbc_context_new(mrb);
  c->dump_result = FALSE;
  c->no_exec = TRUE;
  c->capture_errors = TRUE;
  c->no_optimize = TRUE;
  mrbc_filename(mrb, c, filename);
  mrb_gv_set(mrb, mrb_intern_lit(mrb, "$0"), mrb_str_new_cstr(mrb, filename));
  p = mrb_parse_string(mrb, source, c);
  if( p->nerr > 0 ) {
    print_parse_error(p);
    result = false;
  }else{
    result = true;
  }
  mrbc_cleanup_local_variables(mrb, c);
  mrbc_context_free(mrb, c);
  return result;
}

static mrb_value mrb_check_syntax(mrb_state* mrb, mrb_value self)
{
  char *filename=NULL, *src=NULL;
  mrb_get_args(mrb, "z!z!", &filename, &src );
  if( filename!=NULL && src!=NULL && check_syntax(mrb, filename, src) ){
    return mrb_true_value();
  }
  return mrb_false_value();
}

static void print_usage_and_exit()
{
  printf("bismite run [-I path/to/lib] filename.rb arg1 arg2 ...\n");
  printf("bismite dump [-I path/to/lib] filename.rb out.{rb|mrb}\n");
  exit(-1);
}

static void define_argv(mrb_state *mrb, int skip, int argc, char* argv[])
{
  mrb_value ARGV;
  if(argc>0){
    ARGV = mrb_ary_new_capa(mrb, argc);
    for (int i = skip; i < argc; i++) {
      char* utf8 = mrb_utf8_from_locale(argv[i], -1);
      if (utf8) {
        mrb_value a = mrb_str_new_cstr(mrb, utf8);
        mrb_ary_push(mrb, ARGV, a);
        mrb_utf8_free(utf8);
      }
    }
  }else{
    ARGV = mrb_ary_new_capa(mrb, 0);
  }
  mrb_define_global_const(mrb, "ARGV", ARGV);
}

static uint8_t* copy_irep(mrb_state *mrb, const mrb_irep *irep, size_t* buf_size)
{
  uint8_t *tmp = NULL;
  uint8_t *buf = NULL;
  int result;
  uint8_t flags = MRB_DUMP_DEBUG_INFO;
  result = mrb_dump_irep(mrb, irep, flags, &tmp, buf_size);
  if (result == MRB_DUMP_OK) {
    buf = malloc(*buf_size);
    memcpy(buf,tmp,*buf_size);
  } else {
    printf("irep dump failed.\n");
    buf = NULL;
    *buf_size = 0;
  }
  mrb_free(mrb, tmp);
  return buf;
}

static uint8_t* compile_to_irep(const char* filename, const char* source, size_t *irep_size)
{
  uint8_t* irep_buf = NULL;
  *irep_size = 0;
  mrb_value obj;
  mrb_state *mrb = mrb_open();
  struct mrb_parser_state *p;
  // setup
  mrbc_context *ctx = mrbc_context_new(mrb);
  ctx->dump_result = FALSE;
  ctx->no_exec = TRUE;
  ctx->capture_errors = TRUE;
  mrbc_filename(mrb, ctx, filename);
  mrb_gv_set(mrb, mrb_intern_lit(mrb, "$0"), mrb_str_new_cstr(mrb, filename));
  // compile
  p = mrb_parse_nstring(mrb, source, strlen(source), ctx);
  if( p && p->nerr > 0 ) {
    print_parse_error(p);
    mrbc_context_free(mrb, ctx);
    mrb_close(mrb);
    return NULL;
  }
  obj = mrb_load_exec(mrb, p, ctx);
  // dump irep
  struct RProc *proc = mrb_proc_ptr(obj);
  const mrb_irep *irep = proc->body.irep;
  mrb_irep_remove_lv(mrb, (mrb_irep*)irep);
  irep_buf = copy_irep(mrb,irep,irep_size);
  // close
  mrbc_context_free(mrb, ctx);
  mrb_close(mrb);
  return irep_buf;
}

static char* merge(int argc, char* argv[])
{
  mrb_state *mrb = mrb_open();
  mrb_define_method(mrb, mrb->kernel_module, "check_syntax", mrb_check_syntax, MRB_ARGS_REQ(2)); // filename,source
  define_argv( mrb, 0, argc, argv );
  mrb_value result = mrb_load_irep(mrb,merger);
  if (mrb->exc) {
    if (mrb_undef_p(result)) {
      mrb_p(mrb, mrb_obj_value(mrb->exc));
    } else {
      mrb_print_error(mrb);
    }
    return NULL;
  }
  if( mrb_string_p(result) ){
    char *tmp = mrb_str_to_cstr(mrb, result);
    char *merged_script = malloc(strlen(tmp)+1);
    strcpy(merged_script,tmp);
    mrb_close(mrb);
    return merged_script;
  }else{
    return NULL;
  }
}

static void dump(const char* name, void* buf, size_t size)
{
  FILE *f = fopen(name, "wb");
  if(fwrite(buf, sizeof(uint8_t), size, f) != size) {
    printf("%s write error\n", name);
  }else{
    printf("%s write done\n", name);
  }
  fclose(f);
}

static void run_irep(uint8_t* irep,int argc, char* argv[])
{
  mrb_state *mrb = mrb_open();
  define_argv( mrb, 1, argc, argv ); // skip 1 : first arg is filename
  mrb_gv_set(mrb, mrb_intern_lit(mrb, "$0"), mrb_str_new_cstr(mrb, argv[0]));
  mrb_value result = mrb_load_irep(mrb,irep);
  if (mrb->exc) {
    if (mrb_undef_p(result)) {
      mrb_p(mrb, mrb_obj_value(mrb->exc));
    } else {
      mrb_print_error(mrb);
    }
    return;
  }
  mrb_close(mrb);
}

static bool ext_is(char* name, char* ext )
{
  name = strrchr(name, '.');
  if( name != NULL && strcmp(name,ext)==0 ) return true;
  return false;
}

static void subcommand_run(int argc1, char* argv1[],int argc2, char* argv2[])
{
  char *merged_script = merge(argc1,argv1);
  if(merged_script) {
    char *filename = argv1[argc1-1];
    size_t irep_size = 0;
    uint8_t* irep_buf = compile_to_irep(filename, merged_script, &irep_size);
    run_irep(irep_buf,argc2,argv2);
  }
}

static void subcommand_dump(int argc1, char* argv1[],int argc2, char* argv2[])
{
  char* dumpname = argv2[1];
  char *merged_script = merge(argc1,argv1);
  if(merged_script==NULL) return;
  if( ext_is(dumpname,".rb") ){
    if(merged_script) dump(dumpname,merged_script,strlen(merged_script));
  }else if( ext_is(dumpname,".mrb") ){
    size_t irep_size = 0;
    uint8_t* irep_buf = compile_to_irep("foobar.rb", merged_script, &irep_size);
    if(irep_buf) dump(dumpname,irep_buf,irep_size);
  }else{
    print_usage_and_exit();
  }
}

static int get_filename_index(int argc, char* argv[])
{
  const char* filename = NULL;
  int i=0;
  for( ; i<argc; i++){
    const char* a = argv[i];
    if( strcmp(a,"-I") == 0 ) {
      // skip
      i++;
    }else if( a[0]=='-' && a[1]=='I' ){
      // nop
    }else{
      filename = a;
      break;
    }
  }
  if(i>argc) {
    return -1;
  }
  if(filename==NULL) {
    return -1;
  }
  return i;
}

int main(int argc, char* argv[])
{
  if(argc<3) {
    print_usage_and_exit();
  }
  if( strcmp(argv[1],"run") != 0 && strcmp(argv[1],"dump") != 0 ) {
    print_usage_and_exit();
  }
  if( strcmp(argv[1],"dump") == 0 && argc<4 ) {
    print_usage_and_exit();
  }

  int filename_index = get_filename_index(argc,argv+2);
  if(filename_index<0) {
    print_usage_and_exit();
  }
  int argc1 = filename_index+1;
  char** argv1 = &argv[2];
  int argc2 = argc-2-filename_index;
  char** argv2 = &argv[2+filename_index];

  if( strcmp(argv[1],"run") == 0 ){
    subcommand_run(argc1,argv1,argc2,argv2);
  } else if( strcmp(argv[1],"dump") == 0 ) {
    subcommand_dump(argc1,argv1,argc2,argv2);
  } else {
    print_usage_and_exit();
  }
  return 0;
}
