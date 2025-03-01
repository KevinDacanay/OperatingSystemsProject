# Makefile: a plain text file that contains instructions for a 
# build system, typically used to automate the compilation process
# of software projects, specifying which files need to be recompiled 
# based on their dependencies and providing the commands to do so

# Define compiler and assembler
CC = i686-elf-gcc
AS = i686-elf-as
LD = i686-elf-ld
NASM = nasm
GDB = i686-elf-gdb

# Set up directories
SRC_DIR = src
BUILD_DIR = build
BIN_DIR = bin
KERNEL_SRC = $(SRC_DIR)/kernel/kernel.cpp
BOOTLOADER_SRC = $(SRC_DIR)/bootloader/boot.asm

# Define output file names
KERNEL_BIN = $(BIN_DIR)/kernel.bin
BOOTLOADER_BIN = $(BIN_DIR)/bootloader.bin
OS_IMG = $(BIN_DIR)/os.img

# Set up compiler flags
CFLAGS = -ffreestanding -O2 -Wall -Wextra -g
ASFLAGS = -f elf

# Object files
OBJS = $(BUILD_DIR)/kernel.o $(BUILD_DIR)/keyboard.o $(BUILD_DIR)/ports.o $(BUILD_DIR)/video.o 

# Output kernel
all: $(OS_IMG)

# Create the OS image
$(OS_IMG): $(KERNEL_BIN) $(BOOTLOADER_BIN)
    @echo "Creating OS image..."
# place the bootloader and kernel at specific addresses in the os.img
# seek=4 places the bootloader at the 4th sector (address 0x7C00).
	dd if=$(BOOTLOADER_BIN) of=$(OS_IMG) bs=512 seek=4 
# seek=200 places the kernel at 0x1000.
    dd if=$(KERNEL_BIN) of=$(OS_IMG) bs=512 seek=200

# Compile bootloader
$(BOOTLOADER_BIN): $(BOOTLOADER_SRC)
    @echo "Compiling bootloader..."
    $(AS) $(BOOTLOADER_SRC) -o $(BOOTLOADER_BIN)

# Compile kernel
$(KERNEL_BIN): $(KERNEL_SRC)
    @echo "Compiling kernel..."
    $(CC) $(CFLAGS) -c $(KERNEL_SRC) -o $(BUILD_DIR)/kernel.o
    $(LD) -o $(KERNEL_BIN) $(BUILD_DIR)/kernel.o -Ttext 0x1000

# Clean build files
clean:
    rm -rf $(BUILD_DIR)/* $(BIN_DIR)/*

# Run QEMU with the OS image
run: $(OS_IMG)
    qemu-system-x86_64 -drive format=raw,file=$(OS_IMG)

# Debug with GDB
debug: $(KERNEL_BIN)
    $(GDB) $(KERNEL_BIN)

# Do I run the Makefile or just write it?
# You will run the Makefile using the make command. Here's how:

# To run the Makefile:
# Open Command Prompt or PowerShell.
# Navigate to your project folder (where the Makefile is).
# cd path/to/your/OS-project
# Then run:
# make
# This will trigger make to look for the Makefile and execute the instructions inside it to build the project. For example, it will compile the bootloader and kernel, and eventually generate your os.img file.

# If you want to run specific targets:
#   - To clean up generated files (like object files and binaries): make clean
#   - To run the OS in QEMU: make run
#   - To debug with GDB: make debug
