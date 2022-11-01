## Introduction
This lab is split into three parts.
- The first part concentrates on getting familiarized with x86 assembly language, the QEMU x86 emulator, and the PC's power-on bootstrap procedure. 
- The second part examines the boot loader for our 6.828 kernel, which resides in the boot directory of the lab tree. 
-  third part delves into the initial template for our 6.828 kernel itself, named JOS, which resides in the kernel directory.

## Part 1: PC Bootstrap
[Lab 1: Booting a PC](https://pdos.csail.mit.edu/6.828/2018/labs/lab1/)
the repo provides a skeletal JOS kernel

this is the way to build
```sh
cd Lab1_Booting_a_PC
make 	  # build the minimal 6.828 boot loader and kernel
make qemu # executes QEMU
```


### The PC's Physical Address Space
```
+------------------+  <- 0xFFFFFFFF (4GB)
|      32-bit      |
|  memory mapped   |
|     devices      |
|                  |
/\/\/\/\/\/\/\/\/\/\

/\/\/\/\/\/\/\/\/\/\
|                  |
|      Unused      |
|                  |
+------------------+  <- depends on amount of RAM
|                  |
|                  |
| Extended Memory  |
|                  |
|                  |
+------------------+  <------- 0x00100000 (1MB)
|     BIOS ROM     |
+------------------+  <- 0x000F0000 (960KB)
|  16-bit devices, |
|  expansion ROMs  |
+------------------+  <- 0x000C0000 (768KB)
|   VGA Display    |
+------------------+  <- 0x000A0000 (640KB)
|                  |
|    Low Memory    |
|                  |
+------------------+  <- 0x00000000
```

the Basic Input/Output System (BIOS)
The current PCs store the BIOS in updateable flash memory. The BIOS is responsible for performing basic system initialization, loads the operating system from some appropriate location, then passes control of the machine to the operating system.

For preserving the original layout for the low 1MB of physical address space in order to ensure backward compatibility with existing software. Modern PCs therefore have a **"hole"** in physical memory from `0x000A0000` to `0x00100000`, dividing RAM into "low" or "conventional memory" (the first 640KB) and "extended memory" (everything else).

JOS will use only the first 256MB of a PC's physical memory anyway, so for now we will pretend that all PCs have "only" a 32-bit physical address space.

### The ROM BIOS
This portion will use QEMU's debugging facilities to investigate how an IA-32 compatible computer boots.