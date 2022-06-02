nos
===

A still-in-development implementation of a network operating system for the ATARI 8-bit computer and FujiNet device that accesses file system resources for up to four remote mount points via the N: device. There is no support provided for traditional physical or emulated magnetic floppy drives (D: devices).

In its current state, enough functionality exists to facilitate working with files for a cartridge-based program such as BASIC or Action! and having the files be stored on a TNFS server.

After mounting a folder under, say, a TNFS server, files can be listed, renamed, deleted, etc using the command processor supplied by the operating system.

At least two critical features are still being developed:

1. Loading a binary/executable file into memory from a mount point.
1. A `COPY` file utility

Command Processor
====================

FujiNet DOS provides a command-line interface. The prompt shows the current default network drive. FujiNet DOS commands are typed at this prompt.

Prompt:

	Nn:[] <-- cursor

where `n` is the current default device number (1-4).

Command Summary
===============

|Command |Purpose|
|:------:|:------|
|NCD   |Mount or unmount a remote directory|32400
|NPWD  |Display the current mount point for a network drive|
|Nn:   |Change the current default network drive|
|DIR   |Display a list of files/directories found on a mounted network drive|
|DEL   |Delete a file found on a mount point|
|RENAME|Rename a file or directory on a mount point|
|MKDIR |Create a directory on a mount point|
|RMDIR |Delete an empty directory on a mount point|
|CAR   |Switch to a cartridge (if installed)|
|RUN   |Begin executing machine code at a specified memory address|
|NTRANS|Translate the end-of-line character between the ATARI and the remote host's operating system|
|CLS   |Clear/Erase the screen|

Commands in Detail
==================
`NCD`
====
Mount or unmount a remote directory to a network device (N1: through N4:). The remote directory must be hosted using one of the supported FujiNet protocols (primarily TNFS).

**Mounting**

Usage:

	NCD [N[n]:]PROTO://path[/][:port]

Where `n` is an optional device number 1-4. If `n` is omitted, the current default device number is implied.
Where `PROTO` is a network protocol supported by the FujiNet, such as `TNFS`, `FTP`, `HTTP`. File operations for various protocols are limited by what is supported by the protocol or FujiNet.

General examples:

	NCD TNFS://192.168.1.100/
	NCD N1:TNFS://192.168.1.100/
	NCD N1:TNFS://192.168.1.100/action/myproj/
	NCD N2:FTP://ftp.pigwa.net/stuff/collections/

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

There is limited support for supplying a relative path that includes a reference to a parent directory.

Example:

	NCD N1:TNFS://192.168.1.100/action/myproj01/
	NCD ../myproj02/

results in the path:

	N1:TNFS://192.168.1.100/action/myproj01/../myproj02/

**Unmounting**

To release a remote mount point, enter the `NCD` command with only a device and no protocol and path.

Usage:

	NCD N[n]:

Where `n` is an optional device number 1-4. If `n` is omitted, the current default device number is implied.

Example:

	NCD N2:
	NCD N:


`NPWD`
---
Query the current mount point for a network drive from the FujiNet device and display the results.

Usage:

	NPWD [N[n]:]

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

Where `n` is required and `n` denotes a device number 1-4.

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
	DIR N:
	DIR N2:
	DIR N2:*.BAS
	DIR N2:action/HELLO*.ACT

`DEL`
---
Delete a file found on a mount point.

Usage:

	DEL [N[n]]:[path/]file

Only one file can be deleted per command. Pattern-matching using wildcard characters is not currently supported.

`RENAME`
---
Rename a file or directory on a mount point.

Usage:

	RENAME [N[n]:]OLDNAME,NEWNAME

`MKDIR`
---
Create a directory on a mount point.

Usage:

	MKDIR [N[n]:]path

`RMDIR`
---
Delete an empty directory on a mount point.

Usage:

	RMDIR [N[n]:]path

`CAR`
---
Switch to a cartridge (if installed).

Usage:

	CAR

Control is yielded to the warmstart vector defined within the cartridge. This should allow switching between the cartridge and DOS without destroying the cartridge's working memory. For example, if you are typing a BASIC program, you can switch between DOS and BASIC without losing work.

`RUN`
---

Begin executing machine code at a specified memory address.

	RUN hexaddr

Where `hexaddr` is a four-character hexadecimal address. Leading the address with a `$` returns an error.

Example:
	
	RUN A000
	RUN 0600

`NTRANS`
---
Translate the end-of-line character between the remote host's operating system and the ATARI computer. This is useful for exchanging text files to or from a host computer.

Usage:

	NTRANS [N[n]:] mode

Where mode is required and either 0, 1, 2, or 3

| n  |Translation Mode|
|:--:|--------|
|0|No translation of ATARI EOL ($9B)|
|1|Convert CR --> ATARI EOL ($9B) (Incoming-only)|
|2|Convert LF --> ATARI EOL ($9B) (Incoming-only)|
|3|Convert CR/LF <--> ATARI EOL ($9B) (Both directions)|

The translation mode is assigned on the current default network drive.

Best results seem to arrive from using mode 3 and  a text editor on the host machine that supports CR/LF.

`CLS`
---
Clear / erase the screen.

Usage:

	CLS