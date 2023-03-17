
TARGET_EXEC ?= FUJIAPPLE

SRC_DIRS ?= ./src/

ASM=cl65

ASMFLAGS=-l listing.s -v -t apple2 -C apple2-asm.cfg 

$(TARGET_EXEC): clean
	$(ASM) $(ASMFLAGS) ./src/FUJIAPPLE.S -o $(TARGET_EXEC)

all: dist

clean:
	$(RM) -r $(TARGET_EXEC) 

dist: $(TARGET_EXEC)
	cp dist/FUJIAPPLE_clean.po dist/FUJIAPPLE.po
	java -jar dist/ac.jar -p dist/FUJIAPPLE.po FUJIAPPLE bin 0x2000 <FUJIAPPLE
    


