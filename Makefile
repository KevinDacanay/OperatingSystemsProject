# Cross-compiler prefix
CROSS=i686-elf-
AS=$(CROSS)as
CC=$(CROSS)g++
LD=$(CROSS)ld

# Flags
CXXFLAGS=-ffreestanding -O2 -Wall -Wextra -nostdlib
LDFLAGS=-T src/linker.ld -nostdlib

# Source files
BOOT_SRC=src/bootloader/boot.s
KERNEL_SRC=src/kernel/kernel.cpp

# Object files
BOOT_OBJ=build/boot.o
KERNEL_OBJ=build/kernel.o

# Output
KERNEL_BIN=myos.kernel

# Build all
all: $(KERNEL_BIN)

# Compile assembly
$(BOOT_OBJ): $(BOOT_SRC)
	@mkdir -p build
	$(AS) $< -o $@

# Compile C++ kernel
$(KERNEL_OBJ): $(KERNEL_SRC)
	@mkdir -p build
	$(CC) $(CXXFLAGS) -c $< -o $@

# Link kernel
$(KERNEL_BIN): $(BOOT_OBJ) $(KERNEL_OBJ)
	$(CC) -o $@ $^ $(LDFLAGS) -lgcc

# Clean build artifacts
clean:
	rm -rf build $(KERNEL_BIN)

.PHONY: all clean

ISO_DIR=iso
GRUB_CFG=$(ISO_DIR)/boot/grub/grub.cfg
ISO_OUT=myos.iso

iso: $(KERNEL_BIN)
	@mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL_BIN) $(ISO_DIR)/boot/myos.kernel
	cp $(GRUB_CFG) $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO_OUT) $(ISO_DIR)

run: iso
	qemu-system-i386 -cdrom $(ISO_OUT)
