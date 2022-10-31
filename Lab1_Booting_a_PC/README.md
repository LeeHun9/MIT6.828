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
