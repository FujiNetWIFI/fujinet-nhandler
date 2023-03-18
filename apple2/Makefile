
TARGET_EXEC ?= FUJIAPPLE

SRC_DIRS ?= ./src/

ASM=cl65

ASMFLAGS=-l listing.s -v -t apple2 -C apple2-asm.cfg 

$(TARGET_EXEC): clean
	$(ASM) $(ASMFLAGS) ./src/FUJIAPPLE.S -o $(TARGET_EXEC)

all: version dist tnfs

clean:
	$(RM) -r $(TARGET_EXEC) 

version: $(TARGET_EXEC)
	python3 ver_update.py

dist: $(TARGET_EXEC)
	cp dist/FUJIAPPLE_clean.po dist/FUJIAPPLE.po
	java -jar dist/ac.jar -p dist/FUJIAPPLE.po FUJIAPPLE bin 0x2000 <FUJIAPPLE

tnfs: dist/FUJIAPPLE.po
	cp dist/FUJIAPPLE.po /run/user/1000/gvfs/smb-share:server=192.168.2.21,share=tnfs/apple

    


