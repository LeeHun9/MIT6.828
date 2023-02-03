# Homework: xv6 lazy page allocation

## Part 1: Eliminate allocation from sbrk()
xv6应用程序通过调用sbrk()系统调用向内核申请heap内存空间，该系统调用将分配物理内存并map到进程的页目录（虚拟地址空间）。sys_sbrk()是通过growproc()函数来增加物理空间和改变用户空间大小的

**“lazy page allocation”**: 在应用程序试图使用不存在的页面（访问到的虚拟地址不存在物理页映射）的时候，通过捕获产生页错误信号，然后分配物理内存使得程序可以继续执行. 在申请heap内存空间的时候，仅仅是增大用户空间的值，即proc->sz

task: delete page allocation from the sbrk(n) system call implementation, which is the function sys_sbrk() in `sysproc.c`. Now we need to delete the call to growproc() and increase the process's size.

```c
int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  //if(growproc(n) < 0)
  //  return -1;
  myproc()->sz += n; // hw add
  return addr;
}
```


```shell
init: starting sh
$ echo hi
pid 3 sh: trap 14 err 6 on cpu 0 eip 0x1220 addr 0x4004--kill proc

```
The "addr 0x4004" indicates that the virtual address that caused the page fault is 0x4004.



## Part 2: Lazy allocation

Modify the code in `trap.c` to respond to a **page fault** from user space by mapping a newly-allocated page of physical memory at the faulting address, and then returning back to user space to let the process continue executing. Add code right before `cprint("pid 3 sh: trap 14")`.

```c
//PAGEBREAK: 13
default:
  if(myproc() == 0 || (tf->cs&3) == 0){
    // In kernel, it must be our mistake.
    cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
            tf->trapno, cpuid(), tf->eip, rcr2());
    panic("trap");
  }
  // my code
  uint v_fault_addr = rcr2();
  if(tf->trapno == T_GPFLT) {    // Is Page fault?
    uint v_falut_addr = rcr2();
    uint size = PGROUNDDOWN(v_falut_addr);
    cprintf("T_GPFLT: 0x%x\n", v_falut_addr);
    if (allocuvm(myproc()->pgdir, size, size+PGSIZE) == 0) {
      panic("trap T_GPFLT");
    }
    break;
  }
```

```shell
$ echo hi
T_GPFLT: 0x4004
T_GPFLT: 0xbfa4
hi
```

