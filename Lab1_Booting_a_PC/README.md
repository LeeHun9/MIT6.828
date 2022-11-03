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

```sh
# first terminal
make qemu-gdb   # starts up QEMU at first instruction

# second terminal
make gdb        # start gdb conneting to qemu

The target architecture is set to "i8086".
[f000:fff0]    0xffff0:	ljmp   $0xf000,$0xe05b
0x0000fff0 in ?? ()
+ symbol-file obj/kern/kernel

```
- The IBM PC starts executing at physical address `0x000ffff0`, which is at the very top of the 64KB area reserved for the **ROM BIOS**.
- The PC starts executing with `CS = 0xf000` and `IP = 0xfff0`.
- The first instruction to be executed is a jmp instruction, which jumps to the segmented address `CS = 0xf000` and `IP = 0xe05b`.

## The Boot Loader
> Exercise 3: trace into bootmain(), then into seadsect, then back to bootmain()
> 
> Q1: At what point does the processor start executing 32-bit code? What exactly causes the switch from 16- to 32-bit mode?
> 
> A1: At `0x00007c32` <protcseg> start executing 32-bit code. Set up the **protected-mode** data segment registers and the stack pointer
> 
> Q2: What is the last instruction of the boot loader executed, and what is the first instruction of the kernel it just loaded?
>
> Q3: Where is the first instruction of the kernel?
> 
> A23: The last instruction of boot loader:
> ```
> ((void (*)(void)) (ELFHDR->e_entry))();
> 7d71:	ff 15 18 00 01 00    	call   *0x10018
> ```
> The first instruction of kernel: 
> ```
> 0x10000c:	movw   $0x1234,0x472    # warm boot
> 
> ```
> Q4: How does the boot loader decide how many sectors it must read in order to fetch the entire kernel from disk? Where does it find this information?
> 
> A4: eph = ph + ELFHDR->e_phnum;
### 3 loading the Kernel
boot loader's detail in boot/main.c

this part mainly talks about the C language and ELF format.



> Exercise 6:
> Before the loader loads the kernel, the 8 words after 0x100000 are all zero. After the bootloader finish, use 'x' to check the addr:
> ```
> (gdb) x/8w 0x100000
> 0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
>0x100010:	0x34000004	0x1000b812	0x220f0011	0xc0200fd8
> ```

## Part3: Kernel
OS kernels often like to be linked and run at very high virtual address, such as 0xf0100000, in order to leave the lower part of the processor's virtual address space for user programs to use.

Many machines don't have any physical memory at address 0xf0100000, we will use the processor's memory management hardware to map virtual address 0xf0100000 to physical address 0x00100000.

For now, just map the first 4MB of physical memory, which will be enough to get up and running. We do this using the hand-written, statically-initialized page directory and page table in `kern/entrypgdir.c`. Just force on the effect instead of the detail.

PG：CR0的位31是分页（Paging）标志。当设置该位时即开启了分页机制；当复位时则禁止分页机制，此时所有线性地址等同于物理地址。在开启这个标志之前必须已经或者同时开启PE标志。即若要启用分页机制，那么PE和PG标志都要置位。

Excercise 7: check `0x100025:	mov    %eax,%cr0` before and after 
```
(gdb) x/8w 0x100000
0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0x100010:	0x34000004	0x1000b812	0x220f0011	0xc0200fd8
(gdb) x/8w 0xf0100000
0xf0100000 <_start-268435468>:	0x00000000	0x00000000	0x00000000	0x00000000
0xf0100010 <entry+4>:	        0x00000000	0x00000000	0x00000000	0x00000000
(gdb) si
=> 0x100028:	mov    $0xf010002f,%eax
0x00100028 in ?? ()
(gdb) x/8w 0x100000
0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0x100010:	0x34000004	0x1000b812	0x220f0011	0xc0200fd8
(gdb) x/8w 0xf0100000
0xf0100000 <_start-268435468>:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0xf0100010 <entry+4>:	        0x34000004	0x1000b812	0x220f0011	0xc0200fd8
```

As we can see, the 0x100000 is mapped to 0xf0100000, entrypgdir entry_pgdir translates virtual addresses to physical addresses
```c
__attribute__((__aligned__(PGSIZE)))
pde_t entry_pgdir[NPDENTRIES] = {
	// Map VA's [0, 4MB) to PA's [0, 4MB)
	[0]
		= ((uintptr_t)entry_pgtable - KERNBASE) + PTE_P,
	// Map VA's [KERNBASE, KERNBASE+4MB) to PA's [0, 4MB)
	[KERNBASE>>PDXSHIFT]
		= ((uintptr_t)entry_pgtable - KERNBASE) + PTE_P + PTE_W
};
```

### Formatted Printing to the Console

Exercise 8:
```c
case 'o':
	// Replace this with your code.
	num = getuint(&ap, lflag);
	base = 8;
	goto number;
	// putch('X', putdat);
	break;
```

Q1: Explain the interface between printf.c and console.c. Specifically, what function does console.c export? How is this function used by printf.c?
A1: printf.c wrap function `cputchar` in `putch`, `cputchar` is used to print a char on console, details in console.c. printf.c also implements `cprintf`, which call function `vprintfmt`, which in printfmt.c. printfmt.c is the core of the cprintf, describe how to process the args.

Q2: Explain the following from console.c:
```c
// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {	// 显示字符数超过CRT一屏可显示的字符数
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		//CRT显示器需要对其用空格擦写才能去掉本来already显示了的字符
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
		//显示起点退回到最后一行起始
		crt_pos -= CRT_COLS;
	}
```
A2: If POS > CRT_SIZE, lifts up the old content, and cleans a new line, print the new char in new line.

Q3:Trace the execution of the following code step-by-step:
```c
int x = 1, y = 3, z = 4;
cprintf("x %d, y %x, z %d\n", x, y, z);
```
- In the call to cprintf(), to what does fmt point? To what does ap point?
- List (in order of execution) each call to cons_putc, va_arg, and vcprintf. For cons_putc, list its argument as well. For va_arg, list what ap points to before and after the call. For vcprintf list the values of its two arguments.

A3: 
1. ```
    => 0xf0100a41 <vcprintf>:	push   %ebp
    vcprintf (fmt=0xf0101ac4 "x %d, y %x, z %d\n", ap=0xf010efc4 "\001") at     kern/printf.c:18
    (gdb) x/4x 0xf010efc4
    0xf010efc4:	0x00000001	0x00000003	0x00000004 0xf0101aa9
    ```
2. ```
   # for cons_putc:

   # for va_arg: 

   # for vcprintf:
   vcprintf (fmt=0xf0101ac4 "x %d, y %x, z %d\n", ap=0xf010efc4 "\001"
   ```

Q4: Run the following code:
```c
unsigned int i = 0x00646c72;
cprintf("H%x Wo%s", 57616, &i);
```
A4: 
```
dec(57616) = hex(E110)
little endian 0x00646c72 == 0x72 0x6c 0x64 0x00 --> `rld\0`
He110 World
```
Q5: What will happen?
```c
cprintf("x=%d y=%d", 3);
```
A5: It will print stack content to `y=%d`. That casue leaking of stack.

### The Stack

Exercise 9: Determine where the kernel initializes its stack, and exactly where in memory its stack is located. How does the kernel reserve space for its stack? And at which "end" of this reserved area is the stack pointer initialized to point to?

```asm
f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 10 f0       	mov    $0xf010f000,%esp
```

- Init Stack at entry.S line 77 : `movl	$(bootstacktop),%esp` 
- stack pointer initialized to point to `0xf010f000`
- reserve space for stack: define in `KSTKSIZE` = 32KB(entry.S line 92)
  ```
  PGSIZE = 4KB = 4096
  #define KSTKSIZE	(8*PGSIZE)
  ```
- stack space is 0xF0107000~0xF010F000

Exercise 10: 

run 5 times `test_backtrace`, the stack: 
```
(gdb) x/48x $esp
0xf010ef2c:	0xf0100076	0x00000000	0x00000001	0xf010ef68
0xf010ef3c:	0xf010004a	0xf0110308	0x00000002	0xf010ef68
0xf010ef4c:	0xf0100076	0x00000001	0x00000002	0xf010ef88
0xf010ef5c:	0xf010004a	0xf0110308	0x00000003	0xf010ef88
0xf010ef6c:	0xf0100076	0x00000002	0x00000003	0xf010efa8
0xf010ef7c:	0xf010004a	0xf0110308	0x00000004	0xf010efa8
0xf010ef8c:	0xf0100076	0x00000003	0x00000004	0xf010efb8
0xf010ef9c:	0xf010004a	0xf0110308	0x00000005	0xf010efc8
0xf010efac:	0xf0100076	0x00000004	0x00000005	0xf010eff8
0xf010efbc:	0xf010004a	0xf0110308	0x00010094	0xf010eff8
0xf010efcc:	0xf0100133	0x00000005	0x0000e110	0xf010efec
0xf010efdc:	0x00000000	0x00000000	0x00000000	0x00000000

```

