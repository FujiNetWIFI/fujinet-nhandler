handler
=======

Contained here is the current code for the N: handler, providing network functionality for #FujiNet.

The primary artifact here is NDEV.COM, the N: handler itself.

What's Here
===========

* dist/ - Files in here wind up in n-handler.atr
* relocate.sh - Used during build process, builds two copies of NDEV one page apart, to be run through RELGEN.
* ndev.lst - Latest listing for handler to aid in debugging.
* relwork.atr - The Work disk for building the final relocatable executable.
* relwork-dist - These are the files inside the relwork.atr disk.
* src - Handler source in here.

Building NDEV
=============

You need:
---------
* Atari
* A copy of Action! either in file or cartridge form.
* Relwork.atr

1. run relocate.sh. This will generate two binaries, ndev0.com and ndev1.com, which will be built into the resulting relwork.atr disk.
2. Copy relwork.atr to where it can be mounted or run. This can be run on any system or emulator, and does not require a #FujiNet to be present.
3. Insert ACTION! cartridge and boot relwork.atr
4. SHIFT-CTRL-R and specify D1:RELGEN.ACT to load into editor buffer
5. SHIFT-CTRL-M and type C <RETURN> to compile. Wait for compilation to finish.
6. press R <RETURN> to run
7. For Filename #1: D1:NDEV0.COM
8. For Filename #2: D2:NDEV1.COM
9. Program should indicate that the relocation table is being built, the array of address offsets will display on screen, followed by a length of the entries. If this is present, the binary transformation is successful, and the resulting relocatable binary is now called NDEV0.REL. You will be returned to the monitor.
10. Press E <RETURN> to return to the editor.
11. SHIFT-CTRL-C to clear the editor buffer
12. SHIFT-CTRL-R and specify D1:RELOC.ACT
13. Arrow down until you find where it specifies to insert the relocation table.
14. SHIFT-CTRL-R and specify D1:NDEV0.GEN. The relocation table will now be inserted into the buffer.
15. At the beginning of the file, add:
```
BYTE RTSME=[$60]
```
16. SHIFT-CTRL-M to go back to the monitor
17. C <RETURN> to compile
18. W "D1:AUTORUN.SYS" <RETURN> The relocator will be written as AUTORUN.SYS
19. D <RETURN> to go to DUP.
20. Select COPY FILES
21. For the COPY FROM---TO? use the following:
```
AUTORUN.SYS,NDEV0.REL/A
```
This will append the relocatable binary to the executable, and the finished file is now AUTORUN.SYS.
22. Power off Atari, remove cartridge, and verify that the disk boots. You should see the #FujiNet banner, either ready or error.
23. Copy the resulting AUTORUN.SYS where needed.
