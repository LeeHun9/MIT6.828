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


## Part A

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


## Part B