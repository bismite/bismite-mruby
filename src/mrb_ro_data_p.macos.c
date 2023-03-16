
#ifdef __APPLE__
#ifdef MRB_USE_CUSTOM_RO_DATA_P

#include "mruby.h"
#include <mach-o/getsect.h>
#include <crt_externs.h>
#include <mach-o/dyld.h>
#include <string.h>

static inline struct segment_command_64* first_segment(const struct mach_header_64* header)
{
  struct segment_command_64 *first = (struct segment_command_64 *)((char *)header + sizeof(struct mach_header_64));
  for(uint32_t j = 0; j < header->ncmds; j++){
    if(first->cmd == LC_SEGMENT_64 && strncmp("__TEXT",first->segname,strlen("__TEXT"))==0 ){
      return first;
    }
    first = (struct segment_command_64 *)((char *)first + first->cmdsize);
  }
  return NULL;
}

static inline bool search_addr(const struct mach_header_64* header, const char *p)
{
  struct segment_command_64 *first = first_segment(header);
  if(first==NULL) {
    return false;
  }
  struct segment_command_64 *segment = (struct segment_command_64 *)((char *)header + sizeof(struct mach_header_64));
  for(uint32_t j = 0; j < header->ncmds; j++){
    if(segment->cmd != LC_SEGMENT_64) goto nextsegment;
    if(segment->vmaddr < first->vmaddr) goto nextsegment;
    const char* addr = (const char*)((uintptr_t)header + segment->vmaddr - first->vmaddr);
    if( addr <= p && p < addr+segment->vmsize){
      return true;
    }
nextsegment:
    segment = (struct segment_command_64 *)((char *)segment + segment->cmdsize);
  }
  return false;
}

mrb_bool mrb_ro_data_p(const char *p)
{
  uint32_t count = _dyld_image_count();
  for(uint32_t i=0; i<count; i++){
    const struct mach_header_64* header = (const struct mach_header_64*)_dyld_get_image_header(i);
    if( search_addr(header,p) ){
      return TRUE;
    }
  }
  return FALSE;
}

#endif // MRB_USE_CUSTOM_RO_DATA_P
#endif // __APPLE__
