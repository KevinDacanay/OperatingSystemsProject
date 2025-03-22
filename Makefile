.PHONY: all clean run debug

# Define compiler, assembler, and linker
CC = i686-linux-gnu-g++
CXX = i686-linux-gnu-g++
AS = nasm
LD = i686-linux-gnu-ld

# Compiler and linker flags
CFLAGS = -ffreestanding -O2 -Wall -Wextra -g -Isrc -Isrc/kernel
CXXFLAGS = -ffreestanding -O2 -Wall -Wextra -g -fno-pic -fno-exceptions -fno-rtti -Isrc/kernel -Isrc/kernel/drivers
LDFLAGS = -nostdlib -T src/linker.ld

# Directories
SRC_DIR = src
BUILD_DIR = build
BIN_DIR = bin

# Output files
KERNEL_BIN = $(BIN_DIR)/kernel.bin
BOOTLOADER_BIN = $(BIN_DIR)/bootloader.bin
OS_IMG = $(BIN_DIR)/os.img

# Source files
KERNEL_SRC = $(wildcard $(SRC_DIR)/kernel/*.cpp)
DRIVER_SRC = $(wildcard $(SRC_DIR)/kernel/drivers/*.cpp)
KERNEL_ASM_SRC = $(SRC_DIR)/kernel/boot.s  # Add boot.s file
OBJS = $(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/%.o, $(KERNEL_SRC) $(DRIVER_SRC))
KERNEL_ASM_OBJ = $(BUILD_DIR)/kernel/boot.o  # Object file for boot.s

# Default target: build OS image
all: $(OS_IMG)

# Build OS image
$(OS_IMG): $(BOOTLOADER_BIN) $(KERNEL_BIN)
	@echo "Creating OS image..."
	dd if=/dev/zero of=$(OS_IMG) bs=512 count=100   # Create a blank 100-sector image
	dd if=$(BOOTLOADER_BIN) of=$(OS_IMG) bs=512 seek=0 conv=notrunc
	dd if=$(KERNEL_BIN) of=$(OS_IMG) bs=512 seek=1 conv=notrunc

# Compile bootloader
$(BOOTLOADER_BIN): $(SRC_DIR)/bootloader/boot.asm | $(BIN_DIR)
	@echo "Compiling bootloader..."
	$(AS) -fbin $< -o $@

# Compile boot.s (Kernel entry point)
$(KERNEL_ASM_OBJ): $(KERNEL_ASM_SRC) | $(BUILD_DIR)
	@echo "Compiling kernel boot.s..."
	mkdir -p $(dir $@)
	i686-linux-gnu-gcc -c $< -o $@  # Use GCC to compile the assembly file

# Compile kernel and drivers
$(KERNEL_BIN): $(KERNEL_ASM_OBJ) $(OBJS) | $(BIN_DIR)
	@echo "Linking kernel..."
	$(LD) $(LDFLAGS) -o $@ $(KERNEL_ASM_OBJ) $(OBJS)

# Compile C++ source files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp | $(BUILD_DIR)
	@echo "Compiling $<..."
	mkdir -p $(dir $@)  # Ensure subdirectories exist
	$(CC) $(CXXFLAGS) -c $< -o $@

# Ensure required directories exist
$(BUILD_DIR) $(BIN_DIR):
	mkdir -p $@

# Clean build artifacts
clean:
	@echo "Cleaning build files..."
	rm -rf $(BUILD_DIR) $(BIN_DIR)

# Run QEMU
run: $(OS_IMG)
	@echo "Running in QEMU..."
	qemu-system-i386 -drive format=raw,file=$(OS_IMG)

# Debug with GDB
debug: $(KERNEL_BIN)
	gdb $(KERNEL_BIN)


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
