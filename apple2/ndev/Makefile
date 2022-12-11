PROG = fntools

dist/$(PROG).po: $(PROG)
	cp dist/bootable.po dist/$(PROG).po
	java -jar dist/ac.jar -p dist/$(PROG).po $(PROG) bin 0x2000 < $(PROG)

$(PROG): $(PROG).o
	ld65 --lib apple2.lib -o $(PROG) -C $(PROG).cfg $(PROG).o

$(PROG).o: $(PROG).s
	ca65 -t apple2 -o $(PROG).o -l $(PROG).lst --list-bytes 80 $(PROG).s

clean:
	rm -f $(PROG)
	rm -f $(PROG).o
	rm -f $(PROG).lst
	rm -f dist/$(PROG).po
	rm -Rf cfg/
