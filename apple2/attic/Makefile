
# set these environment variables in your .basrc or windows environment
# to automagically copy the FUJIAPPLE.po file to the TNFS server

# .bashrc
# TNFS_SERVER="192.168.2.21"
# TNFS_SHARE="tnfs/apple"
# export TNFS_SERVER
# export TNFS_SHARE
#
# windows
# SET TNFS_SERVER=tnfs
# SET TNFS_SHARE=tnfs\apple

TNFS_SERVER = $(shell echo $$TNFS_SERVER)
TNFS_SHARE  = $(shell echo $$TNFS_SHARE)
OS          = $(shell echo $$OS)


TARGET_EXEC ?= FUJIAPPLE

SRC_DIRS ?= ./src/

ASM=cl65

ASMFLAGS=-l listing.s -v -t apple2 -C apple2-asm.cfg 

all: version dist tnfs

$(TARGET_EXEC): clean
	$(ASM) $(ASMFLAGS) ./src/FUJIAPPLE.S -o $(TARGET_EXEC)

clean:
	$(RM) -r $(TARGET_EXEC) 

version: $(TARGET_EXEC)
	python3 ver_update.py

dist: $(TARGET_EXEC)
	cp dist/FUJIAPPLE_clean.po  dist/FUJIAPPLE.po
	cp dist/FUJIAPPLE_clean.dsk dist/FUJIAPPLE.dsk
	java -jar dist/ac.jar -p dist/FUJIAPPLE.po  FUJIAPPLE bin 0x4000 <FUJIAPPLE
	java -jar dist/ac.jar -p dist/FUJIAPPLE.dsk FUJIAPPLE bin 0x4000 <FUJIAPPLE
	dist/dsk2woz dist/FUJIAPPLE.dsk dist/FUJIAPPLE.woz


tnfs: dist/FUJIAPPLE.po dist/FUJIAPPLE.woz
ifneq ('$(TNFS_SERVER)','')

ifneq ('$(OS)','')
    cp dist/FUJIAPPLE.po //$(TNFS_SERVER)/$(TNFS_SHARE)
	cp dist/FUJIAPPLE.woz //$(TNFS_SERVER)/$(TNFS_SHARE)
else
	cp dist/FUJIAPPLE.po /run/user/1000/gvfs/smb-share:server=$(TNFS_SERVER),share=$(TNFS_SHARE)
	cp dist/FUJIAPPLE.woz /run/user/1000/gvfs/smb-share:server=$(TNFS_SERVER),share=$(TNFS_SHARE)
endif

else
	$(info ***********************************************)
	$(info *** No TNFS server environment variable set ***)
	$(info ***********************************************)
endif

