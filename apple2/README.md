# FujiNet BASIC extension for Apple II / ProDOS (rewrite)

A from-scratch rewrite of the FujiNet Applesoft extension.  It adds the same
network commands as the Adam SmartBASIC 1.x FujiNet extension to Applesoft
under ProDOS 8, and is meant to replace the original `../apple2` ampersand
version, which has subtle bugs rooted in how it hooks BASIC.

## Why not "&" (and why not new tokens)

Applesoft lives in ROM: its tokenizer, keyword table, and `LIST` detokenizer
are fixed and cannot be extended, so we **cannot add new statement tokens** the
way SmartBASIC did on the Adam (where we had the interpreter source).

The original extension used the **ampersand vector** (`$3F5`).  But `&` runs
*after* the ROM tokenizer has crunched the line, so every command name that
contains an embedded keyword gets partially tokenized and has to be matched
against its crunched byte form:

```asm
.byte 'N', TOK_READ, 0        ; NREAD   -> 'N' + <READ token>
.byte "NST", TOK_AT, "US", 0  ; NSTATUS -> 'NST' + <AT token> + 'US'
```

`NREAD`→READ, `NSTATUS`→AT, `NLOAD`→LOAD, `NSAVE`→SAVE, `NJSONPARSE`→ON … the
whole command set is a token minefield.  That fragility is the bug class we're
escaping.

This rewrite instead installs the commands as **BASIC.SYSTEM external
commands** (hooking `EXTRNCMD` at `$BE06`).  BASIC.SYSTEM hands us the **raw,
untokenized** command line at `$200` — the ROM tokenizer never touches it — so
keyword matching is a plain ASCII compare.  See Gary Little, *ProDOS Advanced
Features for Programmers*, ch. 5 ("Adding Commands to BASIC.SYSTEM").

Trade-off: like every ProDOS command (`OPEN`, `CATALOG`, `PR#`), inside a
running program these are issued via the standard idiom
`PRINT CHR$(4);"NOPEN 1,…"`.  At the `]` prompt you type them bare.

## Command set (matches the Adam SmartBASIC 1.x set — 17 commands)

| Group | Commands |
|---|---|
| Connection | `NOPEN` `NCLOSE` `NSTATUS` `NREAD` `NWRITE` |
| JSON | `NJSONPARSE` `NJSONQUERY` |
| Filesystem | `NCD` `NDIR` `NMKDIR` `NRMDIR` `NDEL` |
| Programs | `NLOAD` `NSAVE` |
| Extra | `NACCEPT` `NLOGIN` `NHTTPMODE` |

## Design

- **Residency:** the image loads at `$8000` via `BRUN` and stays put.  Install
  lowers HIMEM to `$7C00` — a full **1K below** the code, because BASIC.SYSTEM
  places the first open file's 1K buffer at `[HIMEM, HIMEM+$400)`, *above*
  HIMEM (that's what the stock `$9600-$99FF` gap is for) — syncs `FRETOP` and
  BI's cached HIMEM page (`RSHIMEM $BEFB`), and chains `$BE06`.  No runtime
  relocation (and thus no relocation-table rot — a maintenance hazard in the
  original).
- **Recognizer** (`CMDHANDLER`): scans a plain-ASCII keyword table against the
  `$200` buffer; on a match sets `XLEN`/`XCNUM`/`XTRNADDR`/`PBITS` and returns
  `CLC`; otherwise daisy-chains to the previously installed handler.
- **Argument parsing:** each command normalizes its argument tail into a clean,
  high-bit-stripped, NUL-terminated buffer and points `TXTPTR` at it, so the
  Applesoft ROM evaluators (`GETBYT`/`CHKCOM`/`FRMNUM`/`PTRGET`) can parse
  numbers, string literals/vars, and locate/create result variables
  (e.g. `NSTATUS d,bw,conn,err`).
- **Transport:** hand-written 6502 SmartPort code (STATUS/OPEN/CLOSE/READ/
  WRITE/CONTROL) talking to the FujiNet network device — no fujinet-lib.

## Status

- [x] Project scaffold, equates, linker config
- [x] Install / HIMEM-protect / `$BE06` chain
- [x] Command recognizer + dispatch for all 17 keywords
- [x] Argument normalization for the ROM evaluators (incl. CHRGET priming)
- [x] MekkoGX build → bootable `r2r/apple2/FUJIAPPLE.po`
- [x] SmartPort transport layer (validated on hardware)
- [x] Command bodies: all 17 written
  - validated on hardware: `NOPEN` `NCLOSE` `NSTATUS` `NREAD` `NWRITE`
    `NCD` `NDIR` `NMKDIR` `NRMDIR` `NDEL` `NJSONPARSE` `NJSONQUERY`
    `NLOGIN` `NLOAD` `NSAVE` `NACCEPT`
  - written, pending on-hardware validation: `NHTTPMODE`
- [x] Coexistence with BASIC.SYSTEM built-ins (CATALOG/SAVE/LOAD + NEW etc.)
- [x] Printer redirect to the FujiNet SmartPort `PRINTER` device (validated):
  **`CALL 32771` = on, `CALL 32774` = off** (line-buffered; off also flushes a
  partial line).  A literal `PR#1` is not possible: BASIC.SYSTEM validates the
  output vector and rejects anything that is not a real slot ROM (`NO DEVICE
  CONNECTED`), for both `PR#n` and the `PR#n,A<addr>` address form.

Notes for future work / gotchas learned the hard way:
- BASIC.SYSTEM commands must not disturb Applesoft's `TXTPTR`/`CURLIN`; all
  commands route through the `CMDENTRY` trampoline that saves/restores them.
- The ROM evaluators read the *current* char (`CHRGOT`); `SETARGS` sets
  `TXTPTR=ARGBUF-1` then `JSR CHRGET` to prime, else the first eval sees garbage.
- Don't parse URLs with `CHRGET` (skips spaces, stops at `:`); read raw bytes.
- Devicespec-only filesystem commands use scratch channel 0 (never a user chan).
- **EXTRNCMD protocol:** BASIC.SYSTEM pre-`SEC`s and tail-`JMP`s into `$BE06`;
  carry clear on return = "claimed".  The recognizer must explicitly `SEC` on
  its no-match path — a stray `CLC` from table arithmetic silently claims every
  typed line and dispatches it through stale `XTRNADDR`/`XLEN`/`PBITS`.
- **Residency contract:** BI puts the first file buffer in the 1K *above*
  HIMEM, allocates further buffers by subtracting from live `MEMSIZ`, and on
  last-close restores `MEMSIZ` from `RSHIMEM` (`$BEFB`) + reorganizes.  A
  fixed-ORG resident must set `MEMSIZ`/`FRETOP`/`RSHIMEM` consistently, 1K
  below its base.  `GETBUFR` (`$BEF5`) proved unusable on ProDOS 2.4.3's
  BASIC.SYSTEM for a fixed-ORG resident.
- Debug trick: lines starting with `?` (e.g. `? PEEK(x)`) bypass the command
  wedge entirely — safe memory probes even when the EXTRNCMD path is corrupted.
- **Output hooking under BI:** CSW/KSW belong to BI's wedge and get re-synced —
  a CSW hook silently drops out.  The working hook point is BI's active output
  vector `VECOUT` (`$BE30`, default `COUT1`), which is what `CALL 32771/32774`
  swap.  BI's `PR#` refuses RAM vectors entirely.

## Build

```
make apple2          # -> r2r/apple2/FUJIAPPLE.po (bootable)
```

Boots ProDOS → BASIC.SYSTEM → `STARTUP`, which `BRUN`s `FUJIAPPLE` to install
the commands.  Then, e.g.:

```
] NDIR "N:TNFS://TMA-3"
] NOPEN 1,"N:HTTP://WWW.GNU.ORG/LICENSES/GPL-3.0.TXT",4,0
```

Source is in `src/apple2/`; the linker config is `link/fn-ext.cfg`.
