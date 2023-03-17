# fujiapple-ampersand
Add fujinet commands to applesoft BASIC using ampersand routines

To create the FUJIAPPLE executable and create disk image:
   make dist
image will be dist/FUJIAPPLE.po  
Volume name will be /FUJI.APPLE

Based on the documentation here:
https://github.com/FujiNetWIFI/fujinet-platformio/wiki/Apple2-Applesoft-Network-extensions

Additional Documentation:

Boot with a ProDOS disk, have FUJIAPPLE.po in the secondary drive

&NEND - restore last ampersand vector (removes fujiapple from the chain)

&NACCEPT - accept an incoming connection

BRUN FUJIAPPLE
This will load the ampersand routines, relocate them to HIMEM, save the existing
ampersand vector address to be called if an ampersand command does not match
our current list of commands.


