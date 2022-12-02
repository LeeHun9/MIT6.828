# Homework: xv6 system calls
You will modify xv6 to add a system call.



## Part1: System call tracing

Your first task is to modify the xv6 kernel to print the name of the system call and the return value.



```c
void
syscall(void)
{
  int num;
  struct proc *curproc = myproc();

  num = curproc->tf->eax; // eax means sys call num
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
    cprintf("%s -> %d\n", syscall_name[num-1], curproc->tf->eax); // my code
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
```

## Part2: Date system call


grep for uptime in all the source files, then change the file like it for our new syscall `date`.

```sh
grep -n uptime *.[chS]
syscall.c:105:extern int sys_uptime(void);
syscall.c:123:[SYS_uptime]  sys_uptime,
syscall.h:15:#define SYS_uptime 14
syscall.h:27://                        "getpid","sbrk","sleep","uptime","open",
sysproc.c:83:sys_uptime(void)
user.h:25:int uptime(void);
usys.S:31:SYSCALL(uptime)
```

syscall.h
```c
#define SYS_date   22       // my new syscall
```

syscall.c
```c
extern int sys_date(void);
[SYS_date]    sys_date,
```


sysproc.c
```c
int 
sys_date(void)
{
  struct rtcdate* r;

  if(argptr(0, (void*) &r, sizeof(*r)) < 0) {
    return -1;
  }

  cmostime(r);

  return 0;
}
```

user.h
```c
int date(struct rtcdate*);
```

usys.S
```c
SYSCALL(date)
```

add _date to the UPROGS definition in Makefile.

`make` to build, `make qemu` to boot qemu and type `date`:
```
$ date
12:48:17 2022/12/1
```







