/**
 * CIO Open call
 */

#include <atari.h>
#include <6502.h>
#include <string.h>
#include <stdbool.h>
#include "sio.h"
#include "misc.h"

extern unsigned char err;
extern unsigned char ret;
extern unsigned char aux1_save[8];
extern unsigned char aux2_save[8];

void _cio_open(void)
{  
  // Save AUX1/AUX2 values
  aux_save(OS.ziocb.drive);

  siov(DEVIC_N,
       OS.ziocb.drive,
       'O',
       DSTATS_WRITE,
       OS.ziocb.buffer,
       DBYT_OPEN,
       DTIMLO_DEFAULT,
       aux1_save[OS.ziocb.drive],
       aux2_save[OS.ziocb.drive]);
    
  clear_rx_buffer();
  clear_tx_buffer();
    
  ret=1;
  err=OS.dcb.dstats;
}
