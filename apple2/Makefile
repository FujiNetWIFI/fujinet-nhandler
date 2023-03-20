
#set these environment variables to copy to TNFS server
export TNFS_SERVER
export TNFS_SHARE

#TNFS_SERVER  	?= 192.168.2.21
#TNFS_SHARE      ?= tnfs/apple

TNFS_SERVER = $(shell echo $$TNFS_SERVER)
TNFS_SHARE  = $(shell echo $$TNFS_SHARE)
WINDIR      = $(shell echo $$WINDIR)


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
	cp dist/FUJIAPPLE_clean.po dist/FUJIAPPLE.po
	java -jar dist/ac.jar -p dist/FUJIAPPLE.po FUJIAPPLE bin 0x2000 <FUJIAPPLE


tnfs: dist/FUJIAPPLE.po
ifneq ('$(TNFS_SERVER)','')
ifneq ('$(WINDIR)','')
    cp dist/FUJIAPPLE.po \\$(TNFS_SERVER)\$(TNFS_SHARE))
else
	cp dist/FUJIAPPLE.po /run/user/1000/gvfs/smb-share:server=$(TNFS_SERVER),share=$(TNFS_SHARE)
endif
else
	$(info ***********************************************)
	$(info *** No TNFS server environment variable set ***)
	$(info ***********************************************)
endif


    


