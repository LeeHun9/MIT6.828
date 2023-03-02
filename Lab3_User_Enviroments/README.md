# Lab 3: User Environments

## Introduce
You will enhance the JOS kernel to set up the data structures to keep track of user environments, create a single user environment, load a program image into it, and start it running. You also make the JOS kernel capable of handling any system calls the user environment makes and handling any other exceptions it causes.

> environment == process

## Getting started
```sh
cd lab 
git commit -am 'changes to lab2 after handin'
git pull
git checkout -b lab2 origin/lab3
git merge lab2
```

Lab3 new files:

```
inc/	env.h	Public definitions for user-mode environments
trap.h	Public definitions for trap handling
syscall.h	Public definitions for system calls from user environments to the kernel
lib.h	Public definitions for the user-mode support library
kern/	env.h	Kernel-private definitions for user-mode environments
env.c	Kernel code implementing user-mode environments
trap.h	Kernel-private trap handling definitions
trap.c	Trap handling code
trapentry.S	Assembly-language trap handler entry-points
syscall.h	Kernel-private definitions for system call handling
syscall.c	System call implementation code
lib/	Makefrag	Makefile fragment to build user-mode library, obj/lib/libjos.a
entry.S	Assembly-language entry-point for user environments
libmain.c	User-mode library setup code called from entry.S
syscall.c	User-mode system call stub functions
console.c	User-mode implementations of putchar and getchar, providing console I/O
exit.c	User-mode implementation of exit
panic.c	User-mode implementation of panic
user/	*	Various test programs to check kernel lab 3 code
```


## Part A: User Environments and Exception Handling

`inc/env.h`中包含了JOS中用户环境的基本定义，在该文件中内核使用Env这个数据结构去跟踪每一个用户环境（user environment），并且在kern/env.c中有三个全局变量是跟enviroments有关的:

```c
struct Env *envs = NULL;		// All environments
struct Env *curenv = NULL;		// The current env
static struct Env *env_free_list;	// Free environment list
```

```c
struct Env {
	struct Trapframe env_tf;	// Saved registers
	struct Env *env_link;		// Next free Env
	envid_t env_id;			// Unique environment identifier
	envid_t env_parent_id;		// env_id of this env's parent
	enum EnvType env_type;		// Indicates special system environments
	unsigned env_status;		// Status of the environment
	uint32_t env_runs;		// Number of times environment has run

	// Address space
	pde_t *env_pgdir;		// Kernel virtual address of page dir
};
```

### Allocating the Environments Array

在kern/pmap.c中添加envs的内存分配以及对envs的映射即可

```c
//////////////////////////////////////////////////////////////////////
// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
// LAB 3: Your code here.
envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
memset(envs, 0, NENV * sizeof(struct Env));
//////////////////////////////////////////////////////////////////////
// Map the 'envs' array read-only by the user at linear address UENVS
// (ie. perm = PTE_U | PTE_P).
// Permissions:
//    - the new image at UENVS  -- kernel R, user R
//    - envs itself -- kernel RW, user NONE
// LAB 3: Your code here.
boot_map_region(kern_pgdir, (intptr_t)UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE),PADDR(envs), PTE_U | PTE_P);
```

### Creating and Running Environments
Because we do not yet have a filesystem, we will set up the kernel to load a static binary image that is embedded within the kernel itself. JOS embeds this binary in the kernel as a ELF executable image. 需要在`env.c`中补充完成一些函数。

In the file env.c, finish coding the following functions:
```
env_init()
    Initialize all of the Env structures in the envs array and add them to the env_free_list. Also calls env_init_percpu, which configures the segmentation hardware with separate segments for privilege level 0 (kernel) and privilege level 3 (user).
env_setup_vm()
    Allocate a page directory for a new environment and initialize the kernel portion of the new environment's address space.
region_alloc()
    Allocates and maps physical memory for an environment
load_icode()
    You will need to parse an ELF binary image, much like the boot loader already does, and load its contents into the user address space of a new environment.
env_create()
    Allocate an environment with env_alloc and call load_icode to load an ELF binary into it.
env_run()
    Start a given environment running in user mode.

As you write these functions, you might find the new cprintf verb %e useful -- it prints a description corresponding to an error code. For example,

	r = -E_NO_MEM;
	panic("env_alloc: %e", r);

will panic with the message "env_alloc: out of memory". 
```

**env_init()**

```c
// Mark all environments in 'envs' as free, set their env_ids to 0,
// and insert them into the env_free_list.
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
// env_init_percpu, which configures the segmentation hardware with separate segments for   
// privilege level 0 (kernel) and privilege level 3 (user).
void
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = 0; i < NENV; i++) {
		if(i == NENV-1) envs[i].env_link = NULL;
		else envs[i].env_link = &envs[i+1];
		envs[i].env_id = 0;
	}
	
	env_free_list = envs;
	// Per-CPU part of the initialization
	env_init_percpu();
}
```

**env_setup_vm()**

这个函数主要实现的是给一个新的environment分配一个page directory，并且初始化新environment地址空间的kernel位置

```c
// LAB 3: Your code here.
e->env_pgdir = page2kva(p);
memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
p->pp_ref++;
```

**region_alloc()**

region_alloc函数主要是给environment分配一块真正的物理内存，并对该内存进行映射. 先通过page_alloc函数分配一块内存，然后通过page_insert函数实现映射。

```c
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	size_t page_num = ROUNDUP(len, PGSIZE) / PGSIZE;
	uintptr_t va_start = ROUNDDOWN((intptr_t)va, PGSIZE);

	struct Pageinfo* pageinfo = NULL;
	cprintf("region alloc from va_start: 0x%x, len: 0x%x\n", (size_t)va, len);
	for(size_t i = 0; i < page_num; i++) {
		pageinfo = page_alloc(0);
		if(pageinfo == NULL) {
			int r = -E_NO_MEM;
			panic("the page allocation failed!\n");
		}
		
		int r = page_insert(e->env_pgdir, pageinfo, (void *)va_start, PTE_U | PTE_W);
		if(r == NULL) {
			panic("the page insert failed!\n");
		}
	}
}
```

**load_icode()**

把要执行的程序加载到environment的地址空间中, 由于 JOS 暂时还没有自己的文件系统，实际就是从 *binary 这个内存地址读取。


1. 根据 ELF header 得出 Programm header。
2. 遍历所有 Programm header，分配好内存，加载类型为 ELF_PROG_LOAD 的段。
3. 分配用户栈。

```c
static void
load_icode(struct Env *e, uint8_t *binary)
{
	// LAB 3: Your code here.
	struct Proghdr *ph,*eph ;
	struct Elf* elf = (struct Elf*)binary;
	if(elf->e_magic != ELF_MAGIC) {
		panic("load_icode: Not a elf file!\n");
	}
	if(elf->e_entry == 0) {
		panic("load_icode: entry is NULL!\n");
	}

	ph = (struct Proghdr *)((uint8_t *)elf + elf->e_phoff);

	e->env_tf.tf_eip = elf->e_entry;

	eph = ph + elf->e_phnum;

	lcr3(PADDR(e->env_pgdir));
	for(; ph < eph; ph++) {
		if(ph->p_type == ELF_PROG_LOAD) {
			if(ph->p_filesz > ph->p_memsz) {
				panic("load_icode:the filesz > memsz!\n");
			}
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
			memcpy((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
			memset((void*)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
		}
	}
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
	lcr3(PADDR(kern_pgdir));
}
```

**env_create()**

函数主要是创建一个environment，首先是要分配得到一个Env结构体，之后是将这个environment的类型进行标记，再之后就是把要执行的程序加载到这个environment中。

```c
void
env_create(uint8_t *binary, enum EnvType type)
{
	// LAB 3: Your code here.
	struct Env* e;
	if(!env_alloc(&e, 0)) {
		panic("env_create faild!\n");
	}

	e->env_type = type;
	load_icode(e, binary);
}
```

**env_run()**

作用是启动某个进程。env_pop_tf()作用是将 struct Trapframe 中存储的寄存器状态 pop 到相应寄存器中。经过 env_pop_tf() 之后，指令寄存器的值即设置到了可执行文件的入口。

```c
void
env_run(struct Env *e)
{
	// LAB 3: Your code here.
	if(curenv != NULL && curenv->env_status == ENV_RUNNING){
  	  	curenv->env_status = ENV_RUNNABLE;
  	}

  	curenv = e;
  	curenv->env_status = ENV_RUNNING;
  	curenv->env_runs ++;
  	lcr3(PADDR(curenv->env_pgdir));
  	env_pop_tf(&(curenv->env_tf));
	panic("env_run not yet implemented");
}
```

Below is a call graph of the code up to the point where the user code is invoked.

- start (kern/entry.S)
- i386_init (kern/init.c)
  - cons_init
  - mem_init
  - env_init
  - trap_init (still incomplete at this point)
  - env_create
  - env_run
    - env_pop_tf

All codes are ready, run it below:

```shell
make qemu-nox-gdb
make gdb

Program received signal SIGTRAP, Trace/breakpoint trap.
The target architecture is set to "i386".
=> 0x800b1a:	int    $0x30
0x00800b1a in ?? ()
```

运行并不会成功，会报错`Triple fault`。然后 gdb 停止在：0x00800b1a. 由于JOS还没有允许从用户态到内核态的切换，CPU 会产生一个保护异常，然而这个异常也没有程序进行处理，于是生成了 double fault 异常，这个异常同样没有处理。所以报错 triple fault。也就是说，看到执行到了 int 这个中断，实际上就是本次 exercise 顺利结束，这个系统调用是为了在终端输出字符。

### Handling Interrupts and Exceptions

The first int $0x30 system call instruction in user space is a dead end: once the processor gets into user mode, there is no way to get back out. Now need to implement basic exception and system call handling.

On the x86, two mechanisms work together to provide this protection:

1. 中断描述符表(Interrupt Descriptor Table, IDT): x86允许通过256个不同中断或异常的进入点进入kernel，256个中断或异常都有唯一一个中断向量（从0~255）。CPU使用中断向量作为IDT表（IDT表建立在kernel-private 内存中）的index，然后从适当的table条目（ Interrupt Descriptor）中加载
   - 要加载到EIP（instruction pointer）寄存器的值，这个值指向了处理指定异常的kernel处理代码
   - 要加载到CS（code segement）寄存器的值，值里面包含了第0-1位的特权等级值，异常处理程序正是运行在这个特权等级下。（JOS中所有的异常都是在kernel mode下处理的，特权等级全都为0）


2. 任务状态段(Task State Segment, TSS):在处理器调用异常处理程序之前，需要一块空间来保存old process的状态（比如EIP和CS），这样子异常处理程序执行完成之后可以通过old state，从中断发生离开时的那个地方重新开始。这块空间必须是没有特权的user-mode code不能访问的，否则用户恶意的代码或者bug会危及内存，因此会在内核空间中选择一个stack来存储。

### Setting Up the IDT

> Exercise 4. Edit trapentry.S and trap.c and implement the features described above. The macros TRAPHANDLER and TRAPHANDLER_NOEC in trapentry.S should help you, as well as the T_* defines in inc/trap.h. You will need to add an entry point in trapentry.S (using those macros) for each trap defined in inc/trap.h, and you'll have to provide _alltraps which the TRAPHANDLER macros refer to. You will also need to modify trap_init() to initialize the idt to point to each of these entry points defined in trapentry.S; the SETGATE macro will be helpful here. Your _alltraps should:
> 
> - push values to make the stack look like a struct Trapframe
> - load GD_KD into %ds and %es
> - pushl %esp to pass a pointer to the Trapframe as an argument to trap()
> - call trap (can trap ever return?)

```c
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps
```

`TRAPHANDLER` defines a globally-visible function for handling a trap. It pushes a trap number onto the stack, then jumps to `_alltraps`.

complete code in trapentry.S:
```c
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(divide_handler, T_DIVIDE);
TRAPHANDLER_NOEC(debug_handler, T_DEBUG);
TRAPHANDLER_NOEC(nmi_handler, T_NMI)
TRAPHANDLER_NOEC(brkpt_handler, T_BRKPT)
TRAPHANDLER_NOEC(oflow_handler, T_OFLOW)
TRAPHANDLER_NOEC(bound_handler, T_BOUND)
TRAPHANDLER_NOEC(illop_handler, T_ILLOP)
TRAPHANDLER_NOEC(device_handler, T_DEVICE)
TRAPHANDLER(dblflt_handler, T_DBLFLT)
TRAPHANDLER(tss_handler, T_TSS)
TRAPHANDLER(segnp_handler, T_SEGNP)
TRAPHANDLER(stack_handler, T_STACK)
TRAPHANDLER(gpflt_handler, T_GPFLT)
TRAPHANDLER(pgflt_handler, T_PGFLT)
TRAPHANDLER_NOEC(fperr_handler, T_FPERR)
TRAPHANDLER_NOEC(align_handler, T_ALIGN)
TRAPHANDLER_NOEC(mchk_handler, T_MCHK)
TRAPHANDLER_NOEC(simderr_handler, T_SIMDERR)
TRAPHANDLER_NOEC(syscall_handler, T_SYSCALL)

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
	pushl %es 
	pushal

	movl $GD_KD, %eax
	movl %eax, %ds
  	movl %eax, %es
	pushl %esp

	call trap
```

Before cal into trap, the stack as follows:
```
top	esp
	edi
	esi
 ^	...
 |	ecx
 |	eax
	es
	ds
	num
btm	0
```

trap.c
```c
void
trap_init(void)
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	void divide_handler();
  	void debug_handler();
  	void nmi_handler();
  	void brkpt_handler();
  	void oflow_handler();
  	void bound_handler();
  	void illop_handler();
  	void device_handler();
  	void dblflt_handler();
  	void tss_handler();
  	void segnp_handler();
  	void stack_handler();
  	void gpflt_handler();
  	void pgflt_handler();
  	void fperr_handler();
  	void align_handler();
  	void mchk_handler();
  	void simderr_handler();
  	void syscall_handler();

	SETGATE(idt[T_DIVIDE], 0, GD_KT, divide_handler, 0);
  	SETGATE(idt[T_DEBUG], 0, GD_KT, debug_handler, 0);
  	SETGATE(idt[T_NMI], 0, GD_KT, nmi_handler, 0);
  	SETGATE(idt[T_BRKPT], 0, GD_KT, brkpt_handler, 3);
  	SETGATE(idt[T_OFLOW], 0, GD_KT, oflow_handler, 0);
  	SETGATE(idt[T_BOUND], 0, GD_KT, bound_handler, 0);
  	SETGATE(idt[T_ILLOP], 0, GD_KT, illop_handler, 0);
  	SETGATE(idt[T_DEVICE], 0, GD_KT, device_handler, 0);
  	SETGATE(idt[T_DBLFLT], 0, GD_KT, dblflt_handler, 0);
  	SETGATE(idt[T_TSS], 0, GD_KT, tss_handler, 0);
  	SETGATE(idt[T_SEGNP], 0, GD_KT, segnp_handler, 0);
  	SETGATE(idt[T_STACK], 0, GD_KT, stack_handler, 0);
  	SETGATE(idt[T_GPFLT], 0, GD_KT, gpflt_handler, 0);
  	SETGATE(idt[T_PGFLT], 0, GD_KT, pgflt_handler, 0);
  	SETGATE(idt[T_FPERR], 0, GD_KT, fperr_handler, 0);
  	SETGATE(idt[T_ALIGN], 0, GD_KT, align_handler, 0);
  	SETGATE(idt[T_MCHK], 0, GD_KT, mchk_handler, 0);
  	SETGATE(idt[T_SIMDERR], 0, GD_KT, simderr_handler, 0);
  	SETGATE(idt[T_SYSCALL], 0, GD_KT, syscall_handler, 3);
	// Per-CPU setup 
	trap_init_percpu();
}
```

```shell
make grade

+ mk obj/kern/kernel.img
make[1]: Leaving directory '/home/ubuntu/Documents/MIT6.828/lab'
divzero: OK (1.3s) 
softint: OK (0.5s) 
badsegment: OK (0.9s) 
Part A score: 30/30
```

> Question1 What is the purpose of having an individual handler function for each exception/interrupt? (i.e., if all exceptions/interrupts were delivered to the same handler, what feature that exists in the current implementation could not be provided?)

如果把所有中断都放在一个函数里面统一处理，就需要在函数中进行一系列的判断和分支，以区分不同的中断类型，这会导致函数的复杂性和耦合度增加，不利于代码的维护和扩展。此外，每次中断时都需要进行判断和分支，也会影响系统的性能和响应速度。

> Question2 Did you have to do anything to make the user/softint program behave correctly? The grade script expects it to produce a general protection fault (trap 13), but softint's code says `int $14`. Why should this produce `interrupt vector 13`? What happens if the kernel actually allows softint's int $14 instruction to invoke the kernel's `page fault handler` (which is interrupt vector 14)?


user/softini.c
```c
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $14");	// page fault
}
```

```python
@test(10)
def test_softint():
    r.user_test("softint")
    r.match('Welcome to the JOS kernel monitor!',
            'Incoming TRAP frame at 0xefffffbc',
            'TRAP frame at 0xf.......',
            '  trap 0x0000000d General Protection',
            '  eip  0x008.....',
            '  ss   0x----0023',
            '.00001000. free env 0000100')
```

如果程序中调用的是int $14，而报错却显示是13号中断，说明发生了“General Protection Fault”异常，原因是int $14指令的特权级大于当前特权级。softinit.c是一个用户程序，它CPL=3，而中断向量14中的DPL设置的是0。

## Part B: Page Faults, Breakpoints Exceptions, and System Calls

### Handling Page Faults

缺页错误异常，中断向量 14 (T_PGFLT)，是一个非常重要的异常类型，lab3 以及 lab4 都强烈依赖于这个异常处理。当程序遇到缺页异常时，它将引起异常的虚拟地址存入 `CR2` 控制寄存器( control register)。在 `trap.c` 中，我们已经提供了`page_fault_handler()` 函数用来处理缺页异常。

> Exercise 5. Modify `trap_dispatch()` to dispatch page fault exceptions to `page_fault_handler()`. You should now be able to get make grade to succeed on the faultread, faultreadkernel, faultwrite, and faultwritekernel tests. If any of them don't work, figure out why and fix them.
> Remember that you can boot JOS into a particular user program using `make run-x` or `make run-x-nox`. For instance, `make run-hello-nox` runs the `hello` user program.

```c
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch(tf->tf_trapno) {
		case T_PGFLT:
			page_fault_handler(tf);	// e5 add case
			break;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			print_trapframe(tf);
			if (tf->tf_cs == GD_KT)
				panic("unhandled trap in kernel");
			else {
				env_destroy(curenv);
				return;
			}
	}
}
```

```shell
make[1]: Leaving directory '/home/ubuntu/Documents/MIT6.828/lab'
divzero: OK (1.6s) 
softint: OK (0.6s) 
badsegment: OK (1.0s) 
Part A score: 30/30

faultread: OK (1.0s) 
    (Old jos.out.faultread failure log removed)
faultreadkernel: OK (0.9s) 
    (Old jos.out.faultreadkernel failure log removed)
faultwrite: OK (1.0s) 
    (Old jos.out.faultwrite failure log removed)
faultwritekernel: OK (1.0s) 
    (Old jos.out.faultwritekernel failure log removed)
breakpoint: FAIL (1.0s) 
```

You will further refine the kernel's page fault handling below, as you implement system calls.

### The Breakpoint Exception

中断向量是3（T_BRKPT），允许debugger在程序代码中插入断点，断点使用一字节的int 3软件中断指令临时代替相关程序指令。在JOS内核中将会把这个异常转换为一个基本的`pseudo-system call`，任何user environment都可以使用`pseudo-system call`调用JOS kenrel monitor。

> Exercise 6. Modify `trap_dispatch()` to make breakpoint exceptions invoke the kernel monitor. You should now be able to get make grade to succeed on the breakpoint test.

```c
case T_BRKPT:
	monitor(tf);
	break;
```

```
breakpoint: OK (1.0s) 
    (Old jos.out.breakpoint failure log removed)

```

### System calls

用户进程通过请求（invoke）system call来让kernel执行一些程序。当用户进程invoke一个system call，处理器进入内核态模式，处理器和内核合作将用户进程的状态保存下来，kernel执行合适的代码为了执行system call，然后恢复到用户进程。

在JOS内核中，使用int指令可以引起处理器中断，对于system call而言将使用int $0x30（因为已经在inc/trap.h中定义了T_SYSCALL为48即0x30），那么当执行该指令之后，因为我们已经在IDT表中设置了system call的中断描述符，并且DPL设置为3，所以可以让用户进程引起这个中断（Hint：中断0x30不能由硬件产生，所以用户代码去产生的时候是没问题的）。

应用程序将在寄存器中传递system call number和system call参数。system call number会放入%eax中，参数（最多5个）分别放入 %edx, %ecx, %ebx, %edi和esi，kernel执行完之后，将返回值放回%eax中。在lib/syscall.c的syscall()中，已经用汇编代码写好了一个system call的请求:

`inc/syscall.h`, 这个头文件主要定义了系统调用号
```c
#ifndef JOS_INC_SYSCALL_H
#define JOS_INC_SYSCALL_H

/* system call numbers */
enum {
	SYS_cputs = 0,
	SYS_cgetc,
	SYS_getenvid,
	SYS_env_destroy,
	NSYSCALLS
};

#endif /* !JOS_INC_SYSCALL_H */
```

`lib/syscall.c`
```c
static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;

	// Generic system call: pass system call number in AX,
	// up to five parameters in DX, CX, BX, DI, SI.
	// Interrupt kernel with T_SYSCALL.
	//
	// The "volatile" tells the assembler not to optimize
	// this instruction away just because we don't use the
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
		     : "=a" (ret)
		     : "i" (T_SYSCALL),
		       "a" (num),
		       "d" (a1),
		       "c" (a2),
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
```

`kern/syscall.c`
```c
// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	int ret = 0;
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((const char*)a1, a2);
		break;
	case SYS_cgetc:
		ret = sys_cgetc();
		break;
	case SYS_getenvid:
		ret = sys_getenvid() > 0;
		break;
	case SYS_env_destroy:
		ret = sys_env_destroy(a1);
		break;
	default:
		return -E_INVAL;
	}
	return ret;
}
```

`kern/trap.c`
```c
case T_SYSCALL:
	tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
								  tf->tf_regs.reg_edx,
								  tf->tf_regs.reg_ecx,
								  tf->tf_regs.reg_ebx,
								  tf->tf_regs.reg_edi,
								  tf->tf_regs.reg_esi);
	break;
```

JOS系统调用的步骤为：
1. 用户进程使用 inc/ 目录下暴露的接口
2. lib/syscall.c 中的函数将系统调用号及必要参数传给寄存器，并引起一次 int $0x30 中断
3. kern/trap.c 捕捉到这个中断，并将 TrapFrame 记录的寄存器状态作为参数，调用处理中断的函数
4. kern/syscall.c 处理中断

### User-mode startup

一个用户程序从`lib/entry.S`最上面的地方开始运行，之后它会调用`lib/libmain.c`中的libmain()函数。Hint: look in `inc/env.h` and use `sys_getenvid`.

```c
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}
```

inc/env.h:

```c
struct Env {
  struct Trapframe env_tf;  // Saved registers
  struct Env *env_link;   // Next free Env
  envid_t env_id;     // Unique environment identifier
  envid_t env_parent_id;    // env_id of this env's parent
  enum EnvType env_type;    // Indicates special system environments
  unsigned env_status;    // Status of the environment
  uint32_t env_runs;    // Number of times environment has run

  // Address space
  pde_t *env_pgdir;   // Kernel virtual address of page dir
};
```

```c
// An environment ID 'envid_t' has three parts:
//
// +1+---------------21-----------------+--------10--------+
// |0|          Uniqueifier             |   Environment    |
// | |                                  |      Index       |
// +------------------------------------+------------------+
//                                       \--- ENVX(eid) --/

#define ENVX(envid)		((envid) & (NENV - 1))
```
ENVX(eid) equals the environment's index in the `envs[]` array.


Change code in `lib/libmain.c` as:
```c
// set thisenv to point at our Env structure in envs[].
// LAB 3: Your code here.
thisenv = &envs[ENVX(sys_getenvid())];
```

添加完上述代码之后，当运行user/hello的时候打印"hello,world"，然后打印"i am environment 00001000"。当我们运行make grade的时候，我们会发现hello这个程序测试成功。（写`syscall()`部分的时候，ret = sys_getenvid() ~~ > 0~~ 这一步的返回值写错了，导致hello测试一直不通过）

### Page faults and memory protection

操作系统经常借助硬件的支持来实现内存保护，操作系统会通知硬件哪些虚拟地址是有效的那些是无效的。当一个程序尝试去访问一个无效的地址或者访问一个超出它权限的地址时，处理器会在造成fault的指令处停止程序，并且带着相关操作的信息进入内核。对于这种情况又可分为两类：
- 假如fault是可以修复的话，那么内核将会修复这个fault，然后程序继续运行；
- 假如fault不能修复，程序不能继续运行，因为它永远无法跳过造成fault的指令；

在处理用户程序传过来的指针时，内核必须十分小心的。现在我们将安全检查所有从用户空间传到内核的指针来解决这两个问题。当一个程序把一个地址传给内核，内核将会检查该地址是否位于地址空间的用户部分，如果是的话page table会允许相关的内存操作。因此kernel在dereference用户提供的地址的时候，将永不会发生page fault。

> Hint: to determine whether a fault happened in user mode or in kernel mode, check the low bits of the tf_cs.

```c
if(!(tf->tf_cs & 0x03)){
    panic("page fault in kernel mode");
}
```

Read `user_mem_assert` in `kern/pmap.c` and implement user_mem_check in that same file.


`user_mem_check`函数是具体来检查`[va, va+len)`这块地址区是否可以访问的，比如这块地址区域是否有`perm | PTE_P`的权限，虚拟地址是否在ULIM下面，检查权限主要是检查页表表项中是否有相应的权限，可以通过pgdir_walk直接获取相应的页表表项。同时需要注意对va和va+len这两个地址进行ROUNDDOWN和ROUNDUP处理。最后别忘记将错误的第一段地址赋值给`user_mem_check_addr`。

```c
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uint32_t start_addr = ROUNDDOWN((int32_t)va, PGSIZE);
	uint32_t end_addr = ROUNDUP((int32_t)(va+len), PGSIZE);
	pte_t* PTE = NULL;

	for(; start_addr < end_addr; start_addr += PGSIZE) {
		PTE = pgdir_walk(env->env_pgdir, start_addr, 0);
		if (start_addr > (int32_t)ULIM || PTE == NULL || (*PTE & perm) != perm) {
			user_mem_check_addr = start_addr < (int32_t)va? (int32_t)va: start_addr;
			return -E_FAULT;
		}
	}
	return 0;
}
```

Change `kern/syscall.c` to sanity check arguments to system calls.

```c
// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}
```
