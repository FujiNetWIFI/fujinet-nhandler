/**
 * Network Testing tools
 *
 * nnote - read from network connection
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
unsigned long pos;
unsigned char tmp[8];

unsigned char nnote(void)
{
  OS.dcb.ddevic=0x71;
  OS.dcb.dunit=1;
  OS.dcb.dcomnd=0x25; // NOTE
  OS.dcb.dstats=0x40;
  OS.dcb.dbuf=&buf;
  OS.dcb.dtimlo=0x0f;
  OS.dcb.dbyt=3;
  OS.dcb.daux=0;
  siov();

  if (OS.dcb.dstats!=1)
    {
      err_sio();
      return 1;
    }
  else
    {
      print("NOTE: ");

      memcpy(&pos,buf,3);
      itoa(pos,tmp,10);

      print(tmp);
      
      print("\x9b");
      return 0;
    }
}

void main(void)
{  
  OS.lmargn=2;
  OS.dspflg=1;
  
  nnote();
  
  OS.dspflg=0;
}
