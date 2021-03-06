# The default target
.PHONY: all non-toolchain-regress toolchain-regress gdb-only-regress openocd-regress qemu-regress xc3sprog-regress trace-decoder-regress sdk-utilities-regress e-sdk-regress
all:
non-toolchain-regress:
toolchain-regress:
gdb-only-regress:
openocd-regress:
qemu-regress:
xc3sprog-regress:
trace-decoder-regress:
sdk-utilities-regress:
e-sdk-regress:

.NOTPARALLEL:
export MAKEFLAGS=-j1

# Make uses /bin/sh by default, ignoring the user's value of SHELL.
# Some systems now ship with /bin/sh pointing at dash, and this Makefile
# requires bash
SHELL = /bin/bash

PREFIXPATH ?=
BINDIR := bin
OBJDIR ?= obj
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
non-toolchain-regress: redhat-non-toolchain
toolchain-regress: redhat-toolchain
gdb-only-regress: redhat-gdb-only
openocd-regress: redhat-openocd
qemu-regress: redhat-qemu
xc3sprog-regress: redhat-xc3sprog
trace-decoder-regress: redhat-trace-decoder
sdk-utilities-regress: redhat-sdk-utilities
e-sdk-regress: redhat-e-sdk
else ifeq ($(DISTRIB_ID),Ubuntu)
NATIVE ?= $(UBUNTU64)
all: ubuntu64
non-toolchain-regress: ubuntu64-non-toolchain
toolchain-regress: ubuntu64-toolchain
gdb-only-regress: ubuntu64-gdb-only
openocd-regress: ubuntu64-openocd
qemu-regress: ubuntu64-qemu
xc3sprog-regress: ubuntu64-xc3sprog
trace-decoder-regress: ubuntu64-trace-decoder
sdk-utilities-regress: ubuntu64-sdk-utilities
e-sdk-regress: ubuntu64-e-sdk
else ifeq ($(shell uname),Darwin)
NATIVE ?= $(DARWIN)
LIBTOOLIZE ?= glibtoolize
TAR ?= gtar
SED ?= gsed
AWK ?= gawk
all: darwin
non-toolchain-regress: darwin-non-toolchain
toolchain-regress: darwin-toolchain
gdb-only-regress: darwin-gdb-only
openocd-regress: darwin-openocd
qemu-regress: darwin-qemu
xc3sprog-regress: darwin-xc3sprog
trace-decoder-regress: darwin-trace-decoder
sdk-utilities-regress: darwin-sdk-utilities
e-sdk-regress: darwin-e-sdk
else ifneq ($(wildcard /mingw64/etc),)
NATIVE ?= $(WIN64)
all: win64
non-toolchain-regress: win64-non-toolchain
toolchain-regress: win64-toolchain
gdb-only-regress: win64-gdb-only
openocd-regress: win64-openocd
qemu-regress: win64-qemu
xc3sprog-regress: win64-xc3sprog
trace-decoder-regress: win64-trace-decoder
sdk-utilities-regress: win64-sdk-utilities
e-sdk-regress: win64-e-sdk
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
SRC_FESDK    := $(SRCDIR)/freedom-e-sdk

# The actual output of this repository is a set of test runs.
.PHONY: win64 win64-non-toolchain win64-toolchain win64-gdb-only win64-openocd win64-qemu win64-xc3sprog win64-trace-decoder win64-sdk-utilities win64-e-sdk
win64: win64-toolchain win64-openocd win64-qemu win64-xc3sprog win64-trace-decoder win64-sdk-utilities win64-e-sdk
win64-non-toolchain: win64-openocd win64-qemu win64-xc3sprog win64-trace-decoder win64-sdk-utilities
win64-toolchain: $(OBJDIR)/stamps/riscv64-unknown-elf-gcc.test
win64-e-sdk: $(OBJDIR)/stamps/freedom-e-sdk.test
win64-qemu: $(OBJDIR)/stamps/riscv-qemu-get-version.test
.PHONY: ubuntu64 ubuntu64-non-toolchain ubuntu64-toolchain ubuntu64-gdb-only ubuntu64-openocd ubuntu64-qemu ubuntu64-xc3sprog ubuntu64-trace-decoder ubuntu64-sdk-utilities ubuntu64-e-sdk
ubuntu64: ubuntu64-toolchain ubuntu64-openocd ubuntu64-qemu ubuntu64-xc3sprog ubuntu64-trace-decoder ubuntu64-sdk-utilities ubuntu64-e-sdk
ubuntu64-non-toolchain: ubuntu64-openocd ubuntu64-qemu ubuntu64-xc3sprog ubuntu64-trace-decoder ubuntu64-sdk-utilities
ubuntu64-toolchain: $(OBJDIR)/stamps/riscv64-unknown-elf-gcc.test
ubuntu64-e-sdk: $(OBJDIR)/stamps/freedom-e-sdk.test
ubuntu64-qemu: $(OBJDIR)/stamps/riscv-qemu-get-version.test
.PHONY: redhat redhat-non-toolchain redhat-toolchain redhat-gdb-only redhat-openocd redhat-qemu redhat-xc3sprog redhat-trace-decoder redhat-sdk-utilities redhat-e-sdk
redhat: redhat-toolchain redhat-openocd redhat-qemu redhat-xc3sprog redhat-trace-decoder redhat-sdk-utilities redhat-e-sdk
redhat-non-toolchain: redhat-openocd redhat-qemu redhat-xc3sprog redhat-trace-decoder redhat-sdk-utilities
redhat-toolchain: $(OBJDIR)/stamps/riscv64-unknown-elf-gcc.test
redhat-e-sdk: $(OBJDIR)/stamps/freedom-e-sdk.test
redhat-qemu: $(OBJDIR)/stamps/riscv-qemu-get-version.test
.PHONY: darwin darwin-non-toolchain darwin-toolchain darwin-gdb-only darwin-openocd darwin-qemu darwin-xc3sprog darwin-trace-decoder darwin-sdk-utilities darwin-e-sdk
darwin: darwin-toolchain darwin-openocd darwin-qemu darwin-xc3sprog darwin-trace-decoder darwin-sdk-utilities darwin-e-sdk
darwin-non-toolchain: darwin-openocd darwin-qemu darwin-xc3sprog darwin-trace-decoder darwin-sdk-utilities
darwin-toolchain: $(OBJDIR)/stamps/riscv64-unknown-elf-gcc.test
darwin-e-sdk: $(OBJDIR)/stamps/freedom-e-sdk.test
darwin-qemu: $(OBJDIR)/stamps/riscv-qemu-get-version.test

# There's enough % rules that make starts blowing intermediate files away.
.SECONDARY:

# Installs riscv-gnu-toolchain.
toolchain_tarball = $(wildcard $(BINDIR)/riscv64-unknown-elf-gcc-*-$(NATIVE).tar.gz)
ifneq ($(toolchain_tarball),)
toolchain_tarname = $(basename $(basename $(notdir $(toolchain_tarball))))

$(OBJDIR)/stamps/riscv64-unknown-elf-gcc.install: \
		$(toolchain_tarball)
	mkdir -p $(dir $@)
	rm -rf $(OBJDIR)/install/$(toolchain_tarname)
	mkdir -p $(OBJDIR)/install
	$(TAR) -xz -C $(OBJDIR)/install -f $(toolchain_tarball)
	date > $@
else
$(OBJDIR)/stamps/riscv64-unknown-elf-gcc.install:
	$(error No riscv64-unknown-elf-gcc $(NATIVE) tarball available for testing!)
endif

# Tests riscv-gnu-toolchain.
$(OBJDIR)/stamps/riscv64-unknown-elf-gcc.test: \
		$(OBJDIR)/stamps/riscv64-unknown-elf-gcc.install
	mkdir -p $(dir $@)
	rm -rf $(OBJDIR)/test/freedom-toolchain-tests
	mkdir -p $(OBJDIR)/test
	cp -a $(SRC_FTCT) $(OBJDIR)/test
	PATH=$(abspath $(OBJDIR)/install/$(toolchain_tarname)/bin):$(PATH) $(MAKE) -C $(OBJDIR)/test/freedom-toolchain-tests SED=$(SED)
	date > $@

# Tests freedom-e-sdk.
$(OBJDIR)/stamps/freedom-e-sdk.test: \
		$(OBJDIR)/stamps/riscv64-unknown-elf-gcc.install
	mkdir -p $(dir $@)
	rm -rf $(OBJDIR)/test/freedom-e-sdk
	mkdir -p $(OBJDIR)/test
	cp -a $(SRC_FESDK) $(OBJDIR)/test
	rm -rf $(OBJDIR)/test/freedom-e-sdk-standalone
	PATH=$(abspath $(OBJDIR)/install/$(toolchain_tarname)/bin):$(PATH) $(MAKE) -C \
		$(OBJDIR)/test/freedom-e-sdk PROGRAM=hello TARGET=qemu-sifive-e31 \
		STANDALONE_DEST=$(abspath $(OBJDIR)/test/freedom-e-sdk-standalone) standalone
	PATH=$(abspath $(OBJDIR)/install/$(toolchain_tarname)/bin):$(PATH) $(MAKE) -C \
		$(OBJDIR)/test/freedom-e-sdk-standalone software
	rm -rf $(OBJDIR)/test/freedom-e-sdk-standalone
	PATH=$(abspath $(OBJDIR)/install/$(toolchain_tarname)/bin):$(PATH) $(MAKE) -C \
		$(OBJDIR)/test/freedom-e-sdk PROGRAM=example-freertos-minimal TARGET=qemu-sifive-e31 \
		STANDALONE_DEST=$(abspath $(OBJDIR)/test/freedom-e-sdk-standalone) standalone
	PATH=$(abspath $(OBJDIR)/install/$(toolchain_tarname)/bin):$(PATH) $(MAKE) -C \
		$(OBJDIR)/test/freedom-e-sdk-standalone software
	date > $@

# Installs riscv-qemu.
qemu_tarball = $(wildcard $(BINDIR)/riscv-qemu-*-$(NATIVE).tar.gz)
ifneq ($(qemu_tarball),)
qemu_tarname = $(basename $(basename $(notdir $(qemu_tarball))))

$(OBJDIR)/stamps/riscv-qemu.install: \
		$(qemu_tarball)
	mkdir -p $(dir $@)
	rm -rf $(OBJDIR)/install/$(qemu_tarname)
	mkdir -p $(OBJDIR)/install
	$(TAR) -xz -C $(OBJDIR)/install -f $(qemu_tarball)
	date > $@
else
$(OBJDIR)/stamps/riscv-qemu.install:
	$(error No riscv-qemu $(NATIVE) tarball available for testing!)
endif

# Tests riscv-qemu.
$(OBJDIR)/stamps/riscv-qemu-get-version.test: \
		$(OBJDIR)/stamps/riscv-qemu.install
	mkdir -p $(dir $@)
	PATH=$(abspath $(OBJDIR)/install/$(qemu_tarname)/bin):$(PATH) qemu-system-riscv32 -version
	PATH=$(abspath $(OBJDIR)/install/$(qemu_tarname)/bin):$(PATH) qemu-system-riscv64 -version
	date > $@

# Targets that don't build anything
.PHONY: clean
clean::
	rm -rf $(OBJDIR) $(BINDIR)

.PHONY: flush
flush::
	rm -rf $(OBJDIR)
