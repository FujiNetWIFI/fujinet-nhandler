PRODUCT = FUJIAPPLE
PLATFORMS += apple2

# You can run 'make <platform>' to build for a specific platform,
# or 'make <platform>/<target>' for a platform-specific target.
#   make apple2        → build for apple2
#   make apple2/disk   → build the 'disk' target for apple2

# SRC_DIRS may use the literal %PLATFORM% token.
SRC_DIRS = src src/%PLATFORM%

# equ.inc lives beside the platform source; make ca65 search there.
EXTRA_INCLUDE = src/apple2

# This is a BASIC.SYSTEM external-command extension, not a cc65 C program:
# link with our own config so the image is a single BRUN-able BIN at $8000
# (see link/fn-ext.cfg).  This overrides the apple2 target's default config.
LDFLAGS_EXTRA_APPLE2 = -C $(abspath link/fn-ext.cfg)

# No fujinet-lib: the transport is hand-written 6502 SmartPort code.
# (Leaving FUJINET_LIB undefined tells MekkoGX not to fetch/link it.)

# Define extra dirs ("combos") that expand with a platform.
PLATFORM_COMBOS = \
  c64+=commodore \
  atarixe+=atari \
  msxrom+=msx \
  msxdos+=msx \
  adam_cpm+=adam

include mekkogx/toplevel-rules.mk

# Our AppleSingle already imports FUJIAPPLE as a BIN @ $8000, so the default
# disk recipe places it correctly.  We only need to (a) drop the .SYSTEM loader
# MekkoGX adds for standalone programs - we boot into BASIC.SYSTEM instead - and
# (b) add a STARTUP program that BRUNs the extension on boot.
apple2/disk-post::
	-ac -d $(BUILD_DISK) FUJIAPPLE.SYSTE
	ac -bas $(BUILD_DISK) STARTUP < $(CURDIR)/dist/STARTUP.bas
	ac -bas $(BUILD_DISK) GORILLAS < $(CURDIR)/dist/GORILLAS.bas
