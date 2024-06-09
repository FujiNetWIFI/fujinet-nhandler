##
## NOS Makefile
##

ifeq ($(OUTFILE),)
OUTFILE := nos.atr
endif

.PHONY: all clean

all: nos.atr

nos.atr: src/nos.s
	mads src/nos.s -l:nos.lst -o:$(OUTFILE)

clean:
	rm -rf nos*

