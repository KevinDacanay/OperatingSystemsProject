# Operating System Project Overview

## 1. Project Goal
We are building a simple operating system from scratch using assembly and C++, with inspiration from Linux systems. The OS will follow a microkernel architecture for better security, fault tolerance, and scalability. Our goal is to implement core OS functionalities, including process management, memory management, system calls, a file system, synchronization, multithreading, and a basic GUI in the future.

## 2. Key Functionalities
The OS will include:
- Custom Bootloader (loads the kernel)
- Microkernel (handles core operations)
- System Calls (interface for user programs)
- Preemptive SJF Scheduling (efficient CPU scheduling)
- Paging-Based Memory Management (simpler virtual memory)
- FAT File System (with basic read/write support)
- Shared Memory & Mutexes (for IPC & synchronization)
- Multithreading Support (basic thread management)
- I/O Handling (keyboard, screen, disk operations)
- QEMU-Based Testing (emulation & debugging)

## 3. System Initialization (Boot Process)
### Bootloader (Stage 1)
- Written in assembly.
- Runs in real mode, loads the next stage.

### Bootloader (Stage 2)
- Switches CPU to protected mode (32-bit), then long mode (64-bit).
- Loads the kernel into memory and passes control.

### Kernel Initialization
- Sets up interrupts, memory management, and device drivers.
- Initializes scheduler, system calls, and process management.

## 4. Kernel
### Microkernel Design
Minimalist approach, keeping only essential services in kernel space.

### Components Include:
- Process Scheduler (handles multitasking).
- Memory Manager (paging system).
- System Call Interface (allows user programs to interact with the OS).
- IPC Mechanism (shared memory, message passing).

## 5. System Calls
System calls allow user programs to request services from the kernel.

## 6. Process Scheduling (Preemptive SJF)
### Preemptive Shortest Job First (SJF) Scheduler
- Picks the shortest job next (minimizing average wait time).
- Preemptive: Allows task switching if a shorter job arrives.
- Implemented using a priority queue to keep track of processes.

## 7. Synchronization & Multithreading
- **Shared Memory for IPC:** Processes will communicate via shared memory regions.
- **Mutex Locks:** Used to prevent race conditions in critical sections.
- **Threading:** Basic multithreading support will be included.

## 8. Memory Management (Paging System)
### Paging (x86_64 Mode)
- Translates virtual addresses to physical addresses.
- Provides isolation between processes.

### Simple Page Table Implementation
- Initially, a basic paging mechanism (without swapping).

## 9. Disk & File System (FAT)
- **Virtual Disk Image** (used for storage initially, real hardware later).
- **FAT (File Allocation Table) system** with:
  - Basic Read/Write Support
  - Hierarchical File Structure

## 10. I/O Handling
### Keyboard Input
- Interrupt-driven input system.

### Screen Output
- VGA text mode for early display, later graphical support.

### Disk Access
- Basic ATA disk driver for reading/writing.

## 11. Debugging & Testing
- **QEMU:** Used for testing & debugging.
- **Printf-Style Debugging** (initially).
- **GDB Support** (Later) for low-level debugging.

## 12. Next Steps
### Phase 1: Bootloader & Kernel Setup
- Write the bootloader to enter long mode.
- Set up basic VGA output for debugging.
- Load and start the kernel in memory.

### Phase 2: Core Kernel Features
- Implement paging-based memory management.
- Develop basic process management.
- Add system calls and user mode execution.

### Phase 3: Advanced Features
- Implement preemptive SJF scheduling.
- Develop FAT file system with read/write support.
- Add multithreading & synchronization (mutexes, shared memory).

### Phase 4: Testing & Expansion
- Improve I/O handling (keyboard, disk drivers).
- Implement basic GUI (later stage).
- Transition from printf debugging to GDB for deeper debugging.

## Source Code Layout (in progress)
```
/os_project
│-- bootloader/       # Bootloader source code
│── /kernel           # Core kernel source code
│   │── kernel.cpp    # Main kernel entry point
│   │── shell.cpp     # Kernel-integrated shell (this file)
│   │── syscalls.cpp  # System call implementations
│   │── scheduler.cpp # Process scheduling logic
│   │── memory.cpp    # Memory management (paging, allocation)
│   │── fs.cpp        # File system operations
│-- memory/           # Memory management module
│-- scheduler/        # Process scheduling module
│-- fs/               # File system module (FAT implementation)
│-- drivers/          # Hardware drivers (keyboard, disk, etc.)
│   │── keyboard.cpp  # Keyboard driver (used for shell input)
│   │── video.cpp     # Screen/terminal output
│-- user/             # User-space programs
│-- include/          # Header files
│-- tests/            # Test scripts and debugging tools
│─ /libc              # Standard C functions (string, memory, etc.)
│─ /build             # Compiled binaries
│─ /docs              # Documentation
│─ Makefile           # Build system script
```