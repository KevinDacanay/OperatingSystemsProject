# Minimal 64-bit CLI-Based Operating System

## Overview
This project is a minimal yet powerful **64-bit Command-Line Interface (CLI) Operating System** designed for educational and experimental purposes.  
The OS supports **concurrency, multithreading, multiprocessing, memory management, paging**, and more — all built from scratch.

## Core Functionalities

### 1. Boot & Initialization
- **UEFI or BIOS Bootloader**: Loads the 64-bit kernel into memory.
- **Long Mode Initialization**: Enters 64-bit mode, sets up GDT and IDT.
- **Kernel Entry Point**: Starts kernel initialization and main loop.

### 2. Command-Line Interface (CLI)
- **Terminal Driver**: Reads keyboard input and displays output.
- **Shell**: Parses and executes built-in commands.
- **Basic Commands**: `ls`, `cat`, `echo`, `clear`, `help`.

### 3. Memory Management
- **Physical Memory Manager (PMM)**: Tracks and allocates physical memory.
- **Virtual Memory Manager (VMM)**: Implements paging and address mapping.
- **Heap Allocator**: Dynamic memory allocation for the kernel.
- **Stack Management**: Handles process and thread stacks.

### 4. Process Management
- **Process Control Block (PCB)**: Stores registers, memory maps, process state.
- **Process Creation & Termination**: Spawn and clean up processes.
- **Context Switching**: Save/restore CPU state between processes.

### 5. Concurrency & Multithreading
- **Thread Management**: Multiple threads per process.
- **Preemptive Multitasking**: Timer-based scheduling.
- **Synchronization**: Mutexes, semaphores, spinlocks.

### 6. Interrupt & Exception Handling
- **IDT Setup**: Handles hardware interrupts and CPU exceptions.
- **Interrupt Service Routines (ISRs)**: Respond to hardware signals.
- **System Calls**: Safe kernel interaction for user programs.

### 7. Filesystem Support
- **Basic Filesystem** (e.g., FAT32 or custom): Read/write files.
- **VFS Layer**: Filesystem abstraction for multiple types.

### 8. Drivers
- **Keyboard Driver**: Converts scancodes to characters.
- **Screen/Terminal Driver**: Manages text output.
- **Storage Driver**: Disk I/O (ATA, NVMe, etc.).
- **Timer Driver**: Multitasking and timekeeping support.

---

## Core Characteristics
1. **64-bit Long Mode**: Modern CPU architecture support.
2. **Multitasking**: Run multiple processes with CPU time-slicing.
3. **Multiprocessing**: Use multiple CPU cores (SMP support).
4. **Multithreading**: Threads share memory for efficient concurrency.
5. **Preemptive Scheduling**: OS controls task switching.
6. **Protected Mode & Ring Privileges**: Process isolation and stability.
7. **Paging & Virtual Memory**: Per-process address space isolation.
8. **Concurrency Control**: Mutexes, semaphores, spinlocks.
9. **Modularity**: Separate kernel, drivers, and user programs.
10. **Portability**: Hardware-independent code where possible.

---

## Summary
This OS boots into **64-bit mode**, manages **processes and threads** across multiple CPU cores, implements **memory paging**, and exposes a **CLI shell** for direct user interaction.  
It is modular, supports **preemptive multitasking**, and ensures **process isolation** with virtual memory.

---

## License
[MIT License](LICENSE)
