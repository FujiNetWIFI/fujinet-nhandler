nos
===

An experimental and nearly feature-complete network operating system for the ATARI 8-bit computer and FujiNet device that accesses file system resources for up to eight remote mount points via the N: device. There is no support provided for traditional physical or emulated magnetic floppy drives (D: devices), though the N: device will respond to calls made software to the D: device. This allows software created with the expectation of transferring data with floppy disks to work with NOS.

The operating system is well-suited for workflows where integration between a modern computer and an ATARI computer would be convenient.

After mounting a folder under, say, a TNFS server, files can be listed, renamed, deleted, etc using the command-line interface (command processor) supplied by the operating system.

Features on the wish-list:

1. A `MOVE` command to relocate files between directories
1. Wildcard support for `DEL`, `COPY`, `MOVE`
1. Date/time stamps in the listings produced by `DIR`
1. A `PATH` command that provides a subdirectory where extrinsic commands are stored.

Command Processor
====================

FujiNet DOS provides a command-line interface. The prompt shows the current default network drive. FujiNet DOS commands are typed at this prompt.

Prompt:

	Nn:[] <-- cursor

where `n` is the current default device number (1-8).

The ATARI's full-screen editor can be used to correct or cobble a command using text snippets found elsewhere on the screen.

Command Summary
===============

|Command  |Purpose|
|:-------:|:------|
|NCD      |Mount or unmount a remote directory|32400
|NPWD     |Display the current mount point for a network drive|
|Nn:      |Change the current default network drive|
|DIR      |Display a list of files/directories found on a mounted network drive|
|DEL      |Delete a file found on a mount point|
|RENAME   |Rename a file or directory on a mount point|
|NCOPY    |Copy a file between mount points or to a standard device, such as printer.|
|MKDIR    |Create a directory on a mount point|
|RMDIR    |Delete an empty directory on a mount point|
|RUN      |Execute machine code at a specified memory address|
|CAR      |Switch to a cartridge (if installed)|
|LOAD     |Load/Execute binary file|
|REENTER  |Attempt to jump to last LOADed program|
|NTRANS   |Translate the end-of-line character between the ATARI and the remote host's operating system|
|SUBMIT   |Batch execute NOS/DOS commands in text file|
|PRINT    |Display text messages in batch file|
|REM      |Comment within batch file|
|@NOSCREEN|Disable echo of commands in batch file|
|@SCREEN  |Enable echo of commands in batch file|
|AUTORUN  |Define batch file to execute at boot time|
|TYPE     |Show contents of text file|
|CLS      |Clear/Erase the screen|
|COLD     |Execute coldstart routine COLDSV ($E477)|
|WARM     |Execute warmstart routine WARMSV ($E474)|
|XEP      |Toggle 40/80 column display with XEP-80 peripheral|
|HELP     |Online help system|

Extrinsic Commands
===
Entering a 

Commands in Detail
==================

`NCD`|`CD`
---

Mount or unmount a remote directory to a network device (N1: through N4:). The remote directory must be hosted using one of the supported FujiNet protocols (primarily TNFS).

**Mounting**

Usage:

	NCD|CD [N[n]:]PROTO://path[/][:port]

Where `n` is an optional device number 1-4. If `n` is omitted, the current default device number is implied.
Where `PROTO` is a network protocol supported by the FujiNet, such as `TNFS`, `FTP`, `SMB`. File operations for various protocols are limited by what is supported by the protocol or FujiNet.

General examples:

	NCD TNFS://192.168.1.100/
	NCD N1:TNFS://192.168.1.100
	NCD N1:TNFS://192.168.1.100/action/myproj/
	NCD N2:FTP://ftp.pigwa.net/stuff/collections/
	NCD "N2:FTP://ftp.pigwa.net/stuff/collections/holmes cd/"
	CD "N2:FTP://ftp.pigwa.net/stuff/collections/holmes cd/"

A required trailing path separator is appended if none is provided.

Example:

	NCD N1:TNFS://192.168.1.100/action/myproj

resolves to:

	NCD N1:TNFS://192.168.1.100/action/myproj/

After establishing a mount point using a protocol and absolute path, a subsequent relative path can be supplied.

Example:

	NCD N1:TNFS://192.168.1.100/
	NCD action/myproj

results in the path:

	N1:TNFS://192.168.1.100/action/myproj/

and, from there,

    NCD ../myproj2

results in the path:

    N1:TNFS://192.168.1.100/action/myproj2/

**Unmounting**

To release a remote mount point, enter the `NCD` command with only a device and no protocol and path.

Usage:

	NCD|CD N[n]:

Where `n` is an optional device number 1-4. If `n` is omitted, the current default device number is implied.

Example:

	NCD N2:
	CD N2:


`NPWD`|`PWD`
---
Query the current mount point for a network drive from the FujiNet device and display the results.

Usage:

	NPWD|PWD [N[n]:]

Where `Nn:` is optional and `n` detotes a device number 1-4. If `n` is omitted, the current default device number is implied.

General Examples:

	NPWD
	N1:TNFS://192.168.1.100/action/myproj01/   <-- FujiNet Response
	
	NPWD N2:
	N2:FTP://ftp.pigwa.net/stuff/collections/  <-- FujiNet Response


If there is nothing mounted to on the N: device then the response will be blank.

`Nn:` `(Change Drive)`
---
Change the current default network drive.

Usage:

	Nn:

Where `n` is required and `n` denotes a device number 1-8.

After changing the default network drive, the command prompt is updated to reflect the new default network drive. 

Note: No check is made regarding the status of the mount point for the new default network drive. That is, it is possible to switch to a network drive that has no assigned mount point.

`DIR`
---
Display a list of files/directories found on a mounted network drive. Filename and file size are returned.

Usage:

	DIR [N[n]:][path/][pattern]

Where `Nn:` is optional and `n` detotes a device number 1-4. If `n` is omitted, the current default device number is implied.

Where `[path]` is a relative path from the current working directory.

Where `[pattern]` is optional and can include a pattern string including wildcard characters [`*`]. 

Note: Regardless of the pattern string, directory entries are always returned.

Examples:

	DIR
	DIR *.BAS
	DIR N:
	DIR N2:
	DIR N2:*.BAS
	DIR N2:action/HELLO*.ACT
	DIR "N2:holmes cd/"

`DEL`
---

Delete a file found on a mount point.

Usage:

	DEL|ERASE [N[n]]:[path/]file

Only one file can be deleted per command. Pattern-matching using wildcard characters is not currently supported. 

Filenames are case-sensitive. If a filename contains spaces, enclose the entire path and filename with double-quotes.

    DEL MYFILE.AWP
    DEL N2:MyFile.AWP
    DEL N2:DOCS/MYFILE.AWP
    DEL "N2:DOCS/My File.AWP"
    ERASE "N2:DOCS/My File.AWP"

`RENAME`
---
Rename a file or directory on a mount point.

Usage:

	RENAME [N[n]:]OLDNAME,NEWNAME

Examples:

    RENAME ATARIWRITER.XEX,ATARIWRITER.COM
    RENAME AtariWriter.xex,ATARIWRITER.COM
    RENAME N2:AtariWriter.xex,ATARIWRITER.COM
    RENAME "Atari Writer.xex,ATARIWRITER.COM"
    RENAME "N2:APPS/Atari Writer.exe,ATARIWRITER.COM"

`NCOPY`
---
Copy a single file between mount points (or a new file on the same mount).

Usage:

	NCOPY|COPY [N[n]:][/][path/]filename,[N[n]:][path/]filename
	NCOPY|COPY [N[n]:][/][path/]filename,Pn:
	NCOPY|COPY [N[n]:][/][path/]filename,E:

Notes: 
- A filename is required in the destination. That is, `NCOPY N1:filename,N2:` is not currently supported.
- Wildcards are not supported. 
- Beware of the use of `NTRANS` may alter the data being copied.
- Specifying `Pn:` as a destination will send the file to the current printer.
- Specifying `E:` as a destination will send the file to the console.

`MKDIR`
---
Create a new directory on a mount point.

Usage:

	MKDIR [N[n]:][/][path/]dirname

Where dirname is the name of the directory to be created.

Where path is an optional parent directory to dirname. 

`RMDIR`
---
Remove an empty directory on a mount point.

Usage:

	RMDIR [N[n]:]path

`CAR`
---
Switch to a cartridge (if installed).

Usage:

	CAR

Control is yielded to the warmstart vector defined within the cartridge. This should allow switching between the cartridge and DOS without destroying the cartridge's working memory. For example, if you are typing a BASIC program, you can switch between DOS and BASIC without losing work.

`BASIC`
---
Enable or disable XL/XE BASIC-in-ROM (or other ROM-resident programs).

Usage:

    BASIC [ON|OFF]
    ROM [ON|OFF]

The `BASIC` command is used to swap the 8K address space at $A000-$BFFF between RAM and ROM on the ATARI XL/XE machines (excluding the 1200XL). This allows you to switch from working in BASIC to, say, loading a machine-language game without having to restart the computer while holding the `OPTION` console switch.

This command also works for computers with upgrades like the Ultimate 1MB or Incognito, where alternative ROMs can be selected in place of ATARI BASIC. Therefore, the alias `ROM [ON|OFF]` exists in case it seems more sensible to use it instead.

As a hopefully helpful reminder, when $A000-$BFFF is pointing to ROM, the border color (register COLOR4) will be set to gray while in the NOS command processor. The border color will revert to its previous state when the session is returned to BASIC using the `CAR` command.

If `BASIC ON` or `ROM ON` is executed when the address space is already pointing to ROM, the command will instead perform the `CAR` command. This avoids a warm start.

`LOAD|X`
---
Load a binary file into memory.

Usage:

    LOAD [N[n]:][path/]filename
    X [N[n]:][path/]filename

The `LOAD` command is used to execute a binary programs. Machine code vectored from INITAD ($02E2) is executed as encountered. Machine code vectored from RUNAD ($02E0) is executed when the end-of-file is encountered.

	LOAD ATARIWRITER.COM
	LOAD N2:JUMPMANJR.XEX
	LOAD "N2:Atari Writer.xex"
	X JUMPMAN.XEX

For binary program filenames ending with `.COM`, the command `LOAD` and the extension `.COM` are assumed. So, using the example above for `ATARIWRITER.COM`, you only have to enter:  

    ATARIWRITER

`SAVE`
---
Save a range of memory to an ATARI binary format file.

Usage:

    SAVE [N[n]:][path/]filename,START,END[,INITAD][,RUNAD]

where the arguments after the filename are 4-character hexadecimal addresses and

* `START` is the lower boundary of memory range
* `END` is the upper boundary of memory range (inclusive)
* `INITAD` is an optional entry point for initialization during file load
* `RUNAD` is an optional entry point for execution after the load has completed

Example:

    SAVE N1:BASIC.BIN,A000,BFFF
    SAVE MYPROG,2000,2FFF,2F21,2000
    SAVE MYPROG,2000,2FFF,,2000

`RUN`
---

Begin executing machine code at a specified memory address.

Usage:

	RUN hexaddr

Where `hexaddr` is a four-character hexadecimal address. Leading the address with a `$` returns an error. Addresses lower than `$1000` require a leading zero.

Examples:
	
	RUN A000
	RUN 0600

`REENTER`
---

Jump to the memory address stored in `RUNAD ($02E0).

Usage:

    REENTER|REE

Attempt to re-enter a memory-resident program by jumping from the command processor to the address loitering in `RUNAD` ($02E0).

For example, if an application has a `QUIT TO DOS` function, it may be possible to exit, perform a task in the NOS command processor, and then jump back into the application without having to re-load the application from the network.

The success of the `REENTER` command depends on the application. Also, be aware that the entry point for an application may clear any previous work in memory, so save any work before quitting to DOS.

Example:

    LOAD EDIT.COM
    ... (do some editing and quit to DOS) ...  
    ... (back in NOS, do some work here) ...
    REENTER
    (or)
    REE

`NTRANS`
---
Translate the end-of-line character between the remote host's operating system and the ATARI computer. This is useful for exchanging text files to or from a host computer.

Usage:

	NTRANS [N[n]:] mode

Where mode is required and either 0, 1, 2, or 3

| n  |Translation Mode|
|:--:|--------|
|0|No translation of ATARI EOL ($9B)|
|1|Convert CR <--> ATARI EOL ($9B)|
|2|Convert LF <--> ATARI EOL ($9B)|
|3|Convert CR/LF <--> ATARI EOL ($9B)|

Note: Having translation enabled when working with binary files may result in corruption. The `LOAD` command will disable translation for the N: device used for reading in the binary executable.

`SUBMIT`
---
Batch execute NOS commands stored in a text file.

Usage:

    SUBMIT|SOURCE|@ filename

The NOS commands found in *filename* will be executed as if typed in at the command processor. 

Example:

    @ MYFILE.BAT

Several NOS commands were created to help batch files be more useful. See `@SCREEN``@NOSCREEN` `REM` `PRINT`.

`PRINT`
---
Display a message on the screen.

Usage:

    PRINT "string"
   
Intended for use within a batch file.

Example:

    PRINT "Mounting devices..."

`REM`
---
Denote comment line.

Usage:

    REM|' comment

Intended for use within a batch file. Comment lines are ignored by the command processor.

Examples:

    REM Clear existing mounts
    ' Clear existing mounts

`@NOSCREEN`
---

Suppress the display of command lines being executed during batch processing.

Usage:

    @NOSCREEN

Intended for use within a batch file. The default for batch processing is to echo commands as executed. Commands after an @SCREEN will not be echoed.

`@SCREEN`
---

Enable the display of command lines being executed during batch processing.

Usage:

    @SCREEN
   
Intended for use within a batch file. The default for batch processing is to echo commands as executed. Therefore, this command would be used sometime after a call to `@NOSCREEN`.


`AUTORUN`
---
Assign a batch file to execute automatically after a cold start upon NOS entry.

Usage:

To assign AUTORUN,

    AUTORUN PROTO://HOST[:PORT]/[path/]filename

To clear AUTORUN,

    AUTORUN ""

To query the currently defined batch file,

    AUTORUN ?

The AUTORUN entry is stored in the appkey file `/FujiNet/db790000.key` on the FujiNet's SD card. Therefore, AUTORUN requires a FAT32-formatted SD card to be installed in the FujiNet device.

Examples:

    AUTORUN TNFS://192.168.1.101/WORK/STARTUP.BAT
    AUTORUN ?
    AUTORUN ""


`CLS`
---
Clear / erase the screen.

Usage:

	CLS
  
`TYPE`
---
Displays the contents of a text file to the screen.

Usage:

    TYPE [N[n]:][path/]filename

The `TYPE` command clears the screen and prints the contents of a text file to the  display. The text stream is paused once the screen is full. Press any key to display the next page. Press the `ESC` key to exit the text stream.

Known issue: Executing `TYPE` on a non-text file can overrun the assigned buffer and corrupt memory.


`COLD`
---

Reboots the ATARI. Can be used to disable/enable ATARI BASIC on non-400/800 computers by holding (or not) the `OPTION` console key at the moment the command is launched.

Usage:

    COLD

`WARM`
---

Usage:

    WARM

Performs a warmstart.

`XEP`
---
For use with the XEP-80 or XEP-80 II peripheral. Toggles between 40 column and 80 column display. `XEP` should be executed only if an XEP-80 device is connected and only after loading the XEP-80 device handler into memory.

Usage:

    XEP [40]
  
`XEP` sends CIO commands to the XEP80's alternate E: device handler as described in the ATARI's Product Specification for the XEP80. (https://archive.org/details/atari-product-specification-for-xep80)

Examples:

    LOAD XEP80HAN.COM  (Load handler and switch to XEP80 screen)
    XEP 40 (Switch to 40 col screen)
    XEP    (Switch to XEP80 screen)

The equivalent statements in ATARI BASIC would be:

    XIO #1,24,12,0,"E:" (Exit 40 col screen and enter XEP80 screen)
    XIO #1,25,12,0,"E:" (Exit XEP80 screen and enter 40 col screen)

`HELP`
---
Online help system.

Usage:

    HELP [TOPIC][/SUBTOPIC]
  
Typing `HELP` by itself provides a list of top-level topics. To show what's available under a top-level topic, type `HELP` followed by the topic name. Finally, there may be a list of sub-topics available under the topic. Type `HELP TOPIC/SUBTOPIC` to view the article related to the sub-topic.

Examples:

    HELP
    HELP NOS
    HELP NOS/MKDIR
    HELP REF
    HELP REF/ATASCII

The help articles are hosted by github.com. If a help command returns a HTTP 404 error, ensure a TOPIC was entered if one was required. For example, `HELP MKDIR` is incorrect and `HELP NOS/MKDIR` is correct.

Note: The HELP articles are read from device N8:. Therefore, if you have mounted a network resource to device N8:, then the `HELP` command will cease to function properly.
