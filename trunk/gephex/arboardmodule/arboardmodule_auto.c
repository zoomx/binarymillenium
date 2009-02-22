#include "arboardmodule.h"
#include <stdlib.h>
//#include <assert.h>
//#include <stdio.h>
//#include <string.h>
#include "dllutils.h"
#include "arboardmodule.xpm"

static log2T s_log_function = 0;

static void logger(int level, const char* msg)
{
   if (s_log_function)
      s_log_function(level, "mod_pos2num", msg);
}

const char* getSpec(void) {
 return "mod_spec { name=[mod_pos2num] number_of_inputs=[1] number_of_outputs=[6] deterministic=[false] }";
}
const char* getInputSpec(int index) {
 switch(index) {
   case 0:
    return "input_spec { type=typ_FrameBufferType id=1 const=true strong_dependency=true  } ";
  break;
 }
 return 0;
}
const char* getOutputSpec(int index) {
 switch(index) {
   case 0:
    return "output_spec { type=typ_NumberType id=x1 } ";
  break;
  case 1:
    return "output_spec { type=typ_NumberType id=y1 } ";
  break;
  case 2:
    return "output_spec { type=typ_NumberType id=r1 } ";
  break;
  case 3:
    return "output_spec { type=typ_NumberType id=x2 } ";
  break;
  case 4:
    return "output_spec { type=typ_NumberType id=y2 } ";
  break;
  case 5:
    return "output_spec { type=typ_NumberType id=r2 } ";
  break;
 }
 return 0;
}
void* newInstance()
{
  Instance* inst = (Instance*) malloc(sizeof(Instance));

  if (inst == 0)
  {
          logger(0, "Could not allocate memory for instance struct!\n");
          return 0;
  }

  inst->my = construct();

  if (inst->my == 0)
  {
    free(inst);
    return 0;
  }

  return inst;
}

void deleteInstance(void* instance)
{
  Instance* inst = (Instance*) instance;

  destruct(inst->my);

  free(inst);
}

int setInput(void* instance,int index,void* typePointer)
{
 InstancePtr inst = (InstancePtr) instance;
 switch(index) {
  case 0:
   inst->in_1 = (FrameBufferType *) typePointer;
  break;
 } //switch(index) 
 return 1;
}
int setOutput(void* instance,int index, void* typePointer)
{
 InstancePtr inst = (InstancePtr) instance;
 switch(index) {
  case 0:
   inst->out_x1 = (NumberType* ) typePointer;
  break;
  case 1:
   inst->out_y1 = (NumberType* ) typePointer;
  break;
  case 2:
   inst->out_r1 = (NumberType* ) typePointer;
  break;
  case 3:
   inst->out_x2 = (NumberType* ) typePointer;
  break;
  case 4:
   inst->out_y2 = (NumberType* ) typePointer;
  break;
  case 5:
   inst->out_r2 = (NumberType* ) typePointer;
  break;
 } //switch(index) 
 return 0;
}

int getInfo(char* buf,int bufLen)
{
  static const char* INFO = "info { name=[ArMarkers to X,Y,Rotation] group=[Position] inputs=[1 video_in ] outputs=[6 X-Position-1 Y-Position-1 R-Position-1 X-Position-2 Y-Position-2 R-Position-2 ] type=xpm } ";
  char* tmpBuf;
  int reqLen = 1 + strlen(INFO) + getSizeOfXPM(arboardmodule_xpm);
  if (buf != 0 && reqLen <= bufLen)
    {
      char* offset;
      int i;
      int lines = getNumberOfStringsXPM(arboardmodule_xpm);
      tmpBuf = (char*) malloc(reqLen);
          if (tmpBuf == 0)
          {
             printf("Could not allocate memory in getInfo\n");
                 return 0;
          }
      memcpy(tmpBuf,INFO,strlen(INFO)+1);
      offset = tmpBuf + strlen(INFO) + 1;
      for (i = 0; i < lines; ++i)
        {
          char* source = arboardmodule_xpm[i];
          memcpy(offset,source,strlen(source)+1);
          offset += strlen(source) + 1;
        }                       
      memcpy(buf,tmpBuf,reqLen);
      free(tmpBuf);
    }
  return reqLen;        
}



int initSO(log2T log_function) 
{
        s_log_function = log_function;
        
        

        return init(logger);
}
