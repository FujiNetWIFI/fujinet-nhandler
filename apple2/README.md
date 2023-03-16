# fujiapple-ampersand
Add fujinet commands to applesoft BASIC using ampersand routines

Based on the documentation here:
https://github.com/FujiNetWIFI/fujinet-platformio/wiki/Apple2-Applesoft-Network-extensions

Additional Documentation:

&NEND - restore last ampersand vector (removes fujiapple from the chain)

BRUN FUJIAPPLE
This will load the ampersand routines, relocate them to HIMEM, save the existing
ampersand vector address to be called if an ampersand command does not match
our current list of commands.


