/**
 * Network Testing tools
 *
 * npoint - write to network connection
 *
 * Author: Thomas Cherryhomes
 *  <thom.cherryhomes@gmail.com>
 *
 * Released under GPL 3.0
 * See COPYING for details.
 */

#include <atari.h>
#include <string.h>
#include <stdlib.h>
#include <peekpoke.h>
#include "sio.h"
#include "conio.h"
#include "err.h"

unsigned char buf[256];
unsigned char daux1=0;
unsigned char daux2=0;

void npoint(void)
{
  OS.dcb.ddevic=0x71;
  OS.dcb.dunit=1;
  OS.dcb.dcomnd=0x26; // POINT
  OS.dcb.dstats=0x80;
  OS.dcb.dbuf=&buf;
  OS.dcb.dtimlo=0x0f;
  OS.dcb.dbyt=3;
  OS.dcb.daux=0;
  siov();

  if (OS.dcb.dstats!=1)
    {
      err_sio();
      exit(OS.dcb.dstats);
    }
  else
    {
      print("\x9bSET.\x9b");
    }
}

void main(void)
{
  long pos=0;
  OS.lmargn=2;

  print("DESIRED FILE POSITION?\x9b");
  get_line(buf,255);

  pos = atol(buf);
  pos &= 0xFFFFFF;
  
  memset(buf,0,sizeof(buf));
  
  memcpy(&buf,&pos,3);

  npoint();
}
