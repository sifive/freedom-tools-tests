# The default target
.PHONY: all non-toolchain toolchain gdb-only openocd qemu xc3sprog trace-decoder sdk-utilities
all:
non-toolchain:
toolchain:
gdb-only:
openocd:
qemu:
xc3sprog:
trace-decoder:
sdk-utilities:

.NOTPARALLEL:
export MAKEFLAGS=-j1

# Make uses /bin/sh by default, ignoring the user's value of SHELL.
# Some systems now ship with /bin/sh pointing at dash, and this Makefile
# requires bash
SHELL = /bin/bash

PREFIXPATH ?=
BINDIR := bin
OBJDIR := obj
SRCDIR := $(PREFIXPATH)src
SCRIPTSDIR := $(PREFIXPATH)scripts

UBUNTU32 ?= i686-linux-ubuntu14
UBUNTU64 ?= x86_64-linux-ubuntu14
REDHAT ?= x86_64-linux-centos6
WIN32  ?= i686-w64-mingw32
WIN64  ?= x86_64-w64-mingw32
DARWIN ?= x86_64-apple-darwin


-include /etc/lsb-release
ifneq ($(wildcard /etc/redhat-release),)
NATIVE ?= $(REDHAT)
NINJA ?= ninja-build
all: redhat
non-toolchain: redhat-non-toolchain
toolchain: redhat-toolchain
gdb-only: redhat-gdb-only
openocd: redhat-openocd
qemu: redhat-qemu
xc3sprog: redhat-xc3sprog
trace-decoder: redhat-trace-decoder
sdk-utilities: redhat-sdk-utilities
else ifeq ($(DISTRIB_ID),Ubuntu)
NATIVE ?= $(UBUNTU64)
all: ubuntu64
non-toolchain: ubuntu64-non-toolchain
toolchain: ubuntu64-toolchain
gdb-only: ubuntu64-gdb-only
openocd: ubuntu64-openocd
qemu: ubuntu64-qemu
xc3sprog: ubuntu64-xc3sprog
trace-decoder: ubuntu64-trace-decoder
sdk-utilities: ubuntu64-sdk-utilities
#all: win64
#non-toolchain: win64-non-toolchain
#toolchain: win64-toolchain
#gdb-only: win64-gdb-only
#openocd: win64-openocd
#qemu: win64-qemu
#xc3sprog: win64-xc3sprog
#trace-decoder: win64-trace-decoder
#sdk-utilities: win64-sdk-utilities
else ifeq ($(shell uname),Darwin)
NATIVE ?= $(DARWIN)
LIBTOOLIZE ?= glibtoolize
TAR ?= gtar
SED ?= gsed
AWK ?= gawk
all: darwin
non-toolchain: darwin-non-toolchain
toolchain: darwin-toolchain
gdb-only: darwin-gdb-only
openocd: darwin-openocd
qemu: darwin-qemu
xc3sprog: darwin-xc3sprog
trace-decoder: darwin-trace-decoder
sdk-utilities: darwin-sdk-utilities
else
$(error Unknown host)
endif

LIBTOOLIZE ?= libtoolize
TAR ?= tar
SED ?= sed
AWK ?= awk
NINJA ?= ninja

OBJ_NATIVE   := $(OBJDIR)/$(NATIVE)
OBJ_UBUNTU32 := $(OBJDIR)/$(UBUNTU32)
OBJ_UBUNTU64 := $(OBJDIR)/$(UBUNTU64)
OBJ_WIN32    := $(OBJDIR)/$(WIN32)
OBJ_WIN64    := $(OBJDIR)/$(WIN64)
OBJ_DARWIN   := $(OBJDIR)/$(DARWIN)
OBJ_REDHAT   := $(OBJDIR)/$(REDHAT)

SRC_FTCT     := $(SRCDIR)/freedom-toolchain-tests

# The actual output of this repository is a set of tarballs.
.PHONY: win64 win64-non-toolchain win64-toolchain win64-gdb-only win64-openocd win64-qemu win64-xc3sprog win64-trace-decoder win64-sdk-utilities
win64: win64-toolchain win64-openocd win64-qemu win64-xc3sprog win64-trace-decoder win64-sdk-utilities
win64-non-toolchain: win64-openocd win64-qemu win64-xc3sprog win64-trace-decoder win64-sdk-utilities
win64-toolchain: $(OBJDIR)/stamps/freedom-toolchain-tests.test
.PHONY: ubuntu64 ubuntu64-non-toolchain ubuntu64-toolchain ubuntu64-gdb-only ubuntu64-openocd ubuntu64-qemu ubuntu64-xc3sprog ubuntu64-trace-decoder ubuntu64-sdk-utilities
ubuntu64: ubuntu64-toolchain ubuntu64-openocd ubuntu64-qemu ubuntu64-xc3sprog ubuntu64-trace-decoder ubuntu64-sdk-utilities
ubuntu64-non-toolchain: ubuntu64-openocd ubuntu64-qemu ubuntu64-xc3sprog ubuntu64-trace-decoder ubuntu64-sdk-utilities
ubuntu64-toolchain: $(OBJDIR)/stamps/freedom-toolchain-tests.test
.PHONY: redhat redhat-non-toolchain redhat-toolchain redhat-gdb-only redhat-openocd redhat-qemu redhat-xc3sprog redhat-trace-decoder redhat-sdk-utilities
redhat: redhat-toolchain redhat-openocd redhat-qemu redhat-xc3sprog redhat-trace-decoder redhat-sdk-utilities
redhat-non-toolchain: redhat-openocd redhat-qemu redhat-xc3sprog redhat-trace-decoder redhat-sdk-utilities
redhat-toolchain: $(OBJDIR)/stamps/freedom-toolchain-tests.test
.PHONY: darwin darwin-non-toolchain darwin-toolchain darwin-gdb-only darwin-openocd darwin-qemu darwin-xc3sprog darwin-trace-decoder darwin-sdk-utilities
darwin: darwin-toolchain darwin-openocd darwin-qemu darwin-xc3sprog darwin-trace-decoder darwin-sdk-utilities
darwin-non-toolchain: darwin-openocd darwin-qemu darwin-xc3sprog darwin-trace-decoder darwin-sdk-utilities
darwin-toolchain: $(OBJDIR)/stamps/freedom-toolchain-tests.test

# There's enough % rules that make starts blowing intermediate files away.
.SECONDARY:

# Tests riscv-gnu-toolchain for various targets.
toolchain_tarball = $(wildcard $(BINDIR)/riscv64-unknown-elf-gcc-*.tar.gz)
ifneq ($(toolchain_tarball),)
toolchain_tarname = $(basename $(basename $(notdir $(toolchain_tarball))))

$(OBJDIR)/stamps/riscv64-unknown-elf-gcc.install: \
		$(toolchain_tarball)
	mkdir -p $(dir $@)
	rm -rf $(OBJDIR)/install
	mkdir -p $(OBJDIR)/install
	$(TAR) -xz -C $(OBJDIR)/install -f $(toolchain_tarball)
	date > $@

$(OBJDIR)/stamps/freedom-toolchain-tests.test: \
		$(OBJDIR)/stamps/riscv64-unknown-elf-gcc.install
	mkdir -p $(dir $@)
	rm -rf $(OBJDIR)/test/freedom-toolchain-tests
	mkdir -p $(OBJDIR)/test
	cp -a $(SRC_FTCT) $(OBJDIR)/test
	PATH=$(abspath $(OBJDIR)/install/$(toolchain_tarname)/bin):$(PATH) $(MAKE) -C $(OBJDIR)/test/freedom-toolchain-tests SED=$(SED)
	date > $@
else
$(OBJDIR)/stamps/freedom-toolchain-tests.test:
	$(error No riscv64-unknown-elf-gcc tarball available for toolchain testing!)
endif

# Targets that don't build anything
.PHONY: clean
clean::
	rm -rf $(OBJDIR) $(BINDIR)
