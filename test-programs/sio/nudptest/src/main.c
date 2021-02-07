/**
 * Network Testing tools
 *
 * nudptest - UDP test
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

void nclose()
{
  OS.dcb.ddevic=0x71;
  OS.dcb.dunit=1;
  OS.dcb.dcomnd='C';
  OS.dcb.dstats=0x00;
  OS.dcb.dbuf=NULL;
  OS.dcb.dtimlo=0x0f;
  OS.dcb.dbyt=OS.dcb.daux=0;
  siov();
}

int main(int argc, char* argv[])
{
  unsigned short i=0;
  unsigned short *bw=(unsigned short *)&OS.dvstat[0];
  
  OS.soundr=0;
  OS.dspflg=0xFF;
  
  if (argc < 2)
    {
      print("nudptest <dest>\x9b");
      return 1;
    }

  memset(buf,0,sizeof(buf));
  strcpy(buf,argv[1]);
  
  OS.dcb.ddevic=0x71;
  OS.dcb.dunit=1;
  OS.dcb.dcomnd='O';
  OS.dcb.dstats=0x80;
  OS.dcb.dbuf=&buf;
  OS.dcb.dtimlo=0x0f;
  OS.dcb.dbyt=256;
  OS.dcb.daux1=12;
  OS.dcb.daux2=0;
  siov();
  
  if (OS.dcb.dstats!=1)
    {
      print("Could not open UDP socket.\n");
      return 1;
    }

  for (i=0;i<256;i++)
    buf[i]=i&0xFF;
  
  OS.dcb.dcomnd='W';
  OS.dcb.dstats=0x80;
  OS.dcb.dbyt=OS.dcb.daux=256;
  siov();

  if (OS.dcb.dstats!=1)
    {
      print("Could not write to UDP socket.\n");
      nclose();
      return 1;
    }

  // clear dvstat
  memset(&OS.dvstat,0,4);

  // Wait for packet. polling, no interrupt.
  while (OS.dvstat[0]==0)
    {
      OS.dcb.ddevic=0x71;
      OS.dcb.dunit=1;
      OS.dcb.dcomnd='S';
      OS.dcb.dstats=0x40;
      OS.dcb.dbuf=&OS.dvstat;
      OS.dcb.dtimlo=0x0f;
      OS.dcb.dbyt=4;
      OS.dcb.daux=0;
      siov();      
    }

  // Clear buf
  memset(buf,0,sizeof(buf));
  
  // We got a packet. let's get it.
  OS.dcb.ddevic=0x71;
  OS.dcb.dunit=1;
  OS.dcb.dcomnd='R';
  OS.dcb.dstats=0x40;
  OS.dcb.dbuf=&buf;
  OS.dcb.dtimlo=0x0f;
  OS.dcb.dbyt=OS.dcb.daux=OS.dvstat[0];
  siov();      

  print("RECEIVED PACKET:\x9b");

  // Display it
  for (i=0;i<OS.dvstat[0];i++)
      printc(&buf[i]);

  // Close
  nclose();
  
  OS.soundr=3;
  OS.dspflg=0;

  return 0; 
}
