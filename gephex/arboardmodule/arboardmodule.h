#ifndef INCLUDED_ARBOARDMODULE_H
#define INCLUDED_ARBOARDMODULE_H

#ifdef __cplusplus
extern "C"
{
#endif
#include "dllmodule.h"
#include "framebuffertype.h"
#include "numbertype.h"

struct _MyInstance;
typedef struct _Instance
{
struct _MyInstance* my;
 FrameBufferType* in_1;
 NumberType* out_x1;
 NumberType* out_y1;
 NumberType* out_r1;
 NumberType* out_x2;
 NumberType* out_y2;
 NumberType* out_r2;
} Instance, *InstancePtr;
enum Inputs { in_1 = 0 };
enum Outputs { out_x1 = 0, out_y1 = 1, out_r1 = 2, out_x2 = 3, out_y2 = 4, out_r2 = 5 };

struct _MyInstance* construct(void);
void destruct(struct _MyInstance*);
int init(logT log_function);
#ifdef __cplusplus
}
#endif

#endif
