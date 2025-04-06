.PHONY: all clean run debug

CC = x86_64-elf-gcc
CXX = x86_64-linux-gnu-g++
AS = nasm
LD = ld

CFLAGS = -ffreestanding -O2 -Wall -Wextra -g -Isrc -Isrc/kernel
CXXFLAGS = -ffreestanding -O2 -Wall -Wextra -g -fno-pic -fno-exceptions -fno-rtti -Isrc/kernel -Isrc/kernel/drivers
LDFLAGS = -T src/linker.ld -nostdlib -z max-page-size=0x1000

SRC_DIR = src
BUILD_DIR = build
BIN_DIR = bin

KERNEL_ELF = $(BIN_DIR)/kernel.elf
BOOTLOADER_BIN = $(BIN_DIR)/bootloader.bin
OS_IMG = $(BIN_DIR)/os.img

KERNEL_SRC = $(wildcard $(SRC_DIR)/kernel/*.cpp)
DRIVER_SRC = $(wildcard $(SRC_DIR)/kernel/drivers/*.cpp)
KERNEL_ASM_SRC = $(SRC_DIR)/bootloader/boot2.asm  # Change this to boot2.asm
OBJS = $(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/%.o, $(KERNEL_SRC) $(DRIVER_SRC))
KERNEL_ASM_OBJ = $(BUILD_DIR)/bootloader/boot2.o  # Correct object path

all: $(OS_IMG)

$(OS_IMG): $(BOOTLOADER_BIN) $(KERNEL_ELF)
	@echo "Creating OS image..."
	dd if=/dev/zero of=$(OS_IMG) bs=512 count=2880
	dd if=$(BOOTLOADER_BIN) of=$(OS_IMG) bs=512 seek=0 conv=notrunc
	dd if=$(KERNEL_ELF) of=$(OS_IMG) bs=512 seek=1 conv=notrunc

$(BOOTLOADER_BIN): $(SRC_DIR)/bootloader/boot.asm | $(BIN_DIR)
	@echo "Compiling bootloader..."
	$(AS) -fbin $< -o $@  # This outputs a binary bootloader for the boot sector

$(KERNEL_ASM_OBJ): $(KERNEL_ASM_SRC) | $(BUILD_DIR)
	@echo "Compiling kernel boot2.asm..."
	mkdir -p $(dir $@)
	$(AS) -f elf64 $< -o $@  # Correct NASM syntax for 64-bit object file

$(KERNEL_ELF): $(KERNEL_ASM_OBJ) $(OBJS) | $(BIN_DIR)
	@echo "Linking kernel ELF..."
	$(LD) $(LDFLAGS) -o $@ $(KERNEL_ASM_OBJ) $(OBJS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp | $(BUILD_DIR)
	@echo "Compiling $<..."
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR) $(BIN_DIR):
	mkdir -p $@

clean:
	@echo "Cleaning build files..."
	rm -rf $(BUILD_DIR) $(BIN_DIR)

run: $(OS_IMG)
	@echo "Running in QEMU..."
	qemu-system-x86_64 -drive format=raw,file=$(OS_IMG)

debug: $(KERNEL_ELF)
	gdb $(KERNEL_ELF)


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
