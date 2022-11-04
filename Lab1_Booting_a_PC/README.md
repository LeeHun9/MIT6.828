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

## Part2: The Boot Loader
Floppy and hard disks for PCs are divided into 512 byte regions called `sectors`.A sector is the disk's minimum transfer granularity. If the disk is bootable, the first sector is called `the boot sector`, since this is where the boot loader code resides. When the BIOS finds a bootable floppy or hard disk, it loads the 512-byte boot sector into memory at physical addresses `0x7c00` through `0x7dff`, and then uses a jmp instruction to set the `CS:IP` to `0000:7c00`, passing control to the boot loader.

The ability to boot from a CD-ROM came much later, CD-ROMs use a sector size of 2048 bytes instead of 512, and the BIOS can load a much larger boot image from the disk into memory before transferring control to it. But this lab will use  the conventional hard drive boot mechanism(from hard disk or floppy).

The boot loader must perform two main functions:
- First, the boot loader switches the processor from real mode to 32-bit protected mode.
- Second, the boot loader reads the kernel from the hard disk by directly accessing the IDE disk device registers via the x86's special I/O instructions.

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

Exercise 10 and 11: 

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
when init() first call test_backtrace, the stack:
```asm
0xf010efb0:	0x00000004	0x00000005	0xf010eff8	0xf010004a
0xf010efc0:	0xf0110308	0x00010094	0xf010eff8	0xf0100133
```
`0xf0100133` is the next instrucion in init(), then push ebp `0xf010eff8`, `0x00000005` is the local variable, `0x00000004` is args for next test_backtrace call. When entry the second call, push next inst addr `0xf0100076` of `call test_backtrace`.


The above exercise give us the information  need to implement a stack backtrace function `mon_backtrace()`. A prototype for this function is in `kern/monitor.c`. The `read_ebp()`function in `inc/x86.h` may be useful.

The backtrace function should display a listing of function call frames in the following format: Each line contains an ebp, eip, and args
```
Stack backtrace:
  ebp f0109e58  eip f0100a62  args 00000001 f0109e80 f0109e98 f0100ed2 00000031
  ebp f0109ed8  eip f01000d6  args 00000000 00000000 f0100058 f0109f28 00000061
  ...
```


As we can see in entry.S, before call to `i386_init`, set the ebp to zero. So we make `ebp == 0` our Termination condition.
My code:
```c
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.

	cprintf("Stack backtrace:\n");
	// ebp 
	uint32_t* ebp = (uint32_t*)read_ebp();
	
	while(ebp!=0){
		// print the result to the console
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp[0], ebp[1],
				 ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		ebp = (uint32_t*)*ebp;
	}
	
	return 0;
}
```

```
Stack backtrace:
ebp f010ef28 eip f01000a1 args 00000000 00000000 00000000 f010004a f0110308
ebp f010ef48 eip f0100076 args 00000000 00000001 f010ef68 f010004a f0110308
ebp f010ef68 eip f0100076 args 00000001 00000002 f010ef88 f010004a f0110308
ebp f010ef88 eip f0100076 args 00000002 00000003 f010efa8 f010004a f0110308
ebp f010efa8 eip f0100076 args 00000003 00000004 f010efb8 f010004a f0110308
ebp f010efc8 eip f0100076 args 00000004 00000005 f010eff8 f010004a f0110308
ebp f010eff8 eip f0100133 args 00000005 0000e110 f010efec 00000000 00000000
ebp 00000000 eip f010003e args 00000003 00001003 00002003 00003003 00004003
```
now add to the command:
```c
static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{"stkbt", "backtrace the call stack until the i386_init", mon_backtrace},
};
```

Exercise 12: Modify your stack backtrace function to display, for each eip, the function name, source file name, and line number corresponding to that eip.

Q1: In `debuginfo_eip`, where do \_\_STAB_* come from?

A1: line 26-40 in `kern/kernel.ld`, point to ELF .stab section, including debugging information. It's linked to kernel and loaded into kernel memory.
```
/* Include debugging information in kernel memory */
	.stab : {
		PROVIDE(__STAB_BEGIN__ = .);
		*(.stab);
		PROVIDE(__STAB_END__ = .);
		BYTE(0)		/* Force the linker to allocate space
				   for this section */
	}
```
`objdump -h obj/kern/kernel` print section .stab and .stabstr. `objdump -G obj/kern/kernel` print contents of .stab section. Thus `debuginfo_eip` can read debug information for .stab section. Also that's why use \_\_STAB_*.

```
➜  Lab1_Booting_a_PC git:(master) ✗ objdump -G obj/kern/kernel          
obj/kern/kernel:     file format elf32-i386
Contents of .stab section:
Symnum n_type n_othr n_desc n_value  n_strx String
-1     HdrSym 0      1224   00001659 1     
0      SO     0      0      f0100000 1      {standard input}
1      SOL    0      0      f010000c 18     kern/entry.S
2      SLINE  0      44     f010000c 0      
3      SLINE  0      57     f0100015 0      
4      SLINE  0      58     f010001a 0      
5      SLINE  0      60     f010001d 0      
6      SLINE  0      61     f0100020 0      
...
```
`debuginfo_eip` call `stab_binsearch` to binsearch the the entry corresponding to the address. Then assign to struct `Eipdebuginfo`.


Complete the implementation of debuginfo_eip:
```c
// Search within [lline, rline] for the line number stab.
// If found, set info->eip_line to the right line number.
// If not found, return -1.
//
// Hint:
//	There's a particular stabs type used for line numbers.
//	Look at the STABS documentation and <inc/stab.h> to find
//	which one.
// Your code here.
stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
if(lline <= rline) 
	info->eip_line = stabs[lline].n_desc;
else
	return -1;
```

`kedebug.h` provides the information we need to modify our code. Moreover function `debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)` is the interface to get those information.
```c
// Debug information about a particular instruction pointer
struct Eipdebuginfo {
	const char *eip_file;		// Source code filename for EIP
	int eip_line;			// Source code linenumber for EIP

	const char *eip_fn_name;	// Name of function containing EIP
					//  - Note: not null terminated!
	int eip_fn_namelen;		// Length of function name
	uintptr_t eip_fn_addr;		// Address of start of function
	int eip_fn_narg;		// Number of function arguments
};
```

refine the code in Exercise 10 and 11:
```c
struct Eipdebuginfo info;
if(debuginfo_eip((uintptr_t)ebp[1], &info) == 0) {
	cprintf("\t%s:%d:%.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen ,info.eip_fn_name, ebp[1] - info.eip_fn_addr);
}		
```
```
K> stkbt
Stack backtrace:
ebp f010ffc8 eip f0100ab6 args 00000001 f010ff70 00000000 f0100b1a f0100ac9
	     kern/monitor.c:140:monitor+333
ebp f010fff8 eip f0100140 args 00000000 0000e110 f010ffec 00000000 00000000
	     kern/init.c:49:i386_init+154
ebp 00000000 eip f010003e args 00000003 00001003 00002003 00003003 00004003
	     kern/entry.S:83:<unknown>+0

```

So far, Lab1 finished!


