# Homework: xv6 CPU alarm

add a new syscall `alarm` to xv6. Modify the files below to add syscall.

```shell
grep -n uptime *.[chS]
syscall.c:105:extern int sys_uptime(void);
syscall.c:123:[SYS_uptime]  sys_uptime,
syscall.h:15:#define SYS_uptime 14
syscall.h:27://                        "getpid","sbrk","sleep","uptime","open",
sysproc.c:83:sys_uptime(void)
user.h:25:int uptime(void);
usys.S:31:SYSCALL(uptime)
```



```c
// hw5 example program: alarmtest.c

#include "types.h"
#include "stat.h"
#include "user.h"

void periodic();

int
main(int argc, char *argv[])
{
  int i;
  printf(1, "alarmtest starting\n");
  alarm(10, periodic);
  for(i = 0; i < 25*500000; i++){
    if((i % 250000) == 0)
      write(2, ".", 1);
  }
  exit();
}

void
periodic()
{
  printf(1, "alarm!\n");
}
```


上述添加的代码中会调用alarm(10, periodic)，而这个调用的意思是让kernel每隔10ticks调用一次periodic()。


```c
int
sys_alarm(void)
{
  int ticks;
  void (*handler)();
  if(argint(0, &ticks) < 0)
    return -1;
  if(argptr(1, (char**)&handler, 1) < 0)
    return -1;
  myproc()->alarmticks = ticks;
  myproc()->alarmhandler = handler;
  return 0;
}
```

Makefile
```makefile
UPROGS=\
	......
  _alarmtest\
```

Hint: You'll need to keep track of how many ticks have passed since the last call (or are left until the next call) to a process's alarm handler; you'll need a new field in struct proc for this too. You can initialize proc fields in allocproc() in proc.c.

Hint: Every tick, the hardware clock forces an interrupt, which is handled in `trap()` by `case T_IRQ0 + IRQ_TIMER`; **you should add some code here**.

Hint: You only want to manipulate a process's alarm ticks if there's a process running and if the timer interrupt came from user space; you want something like

    if(myproc() != 0 && (tf->cs & 3) == 3) ...
Hint: In your IRQ_TIMER code, when a process's alarm interval expires, you'll want to cause it to execute its handler. How can you do that?

Hint: You need to arrange things so that, when the handler returns, the process resumes executing where it left off. How can you do that?

Hint: You can see the assembly code for the alarmtest program in `alarmtest.asm`.

Hint: It will be easier to look at traps with gdb if you tell qemu to use only one CPU, which you can do by running

    make CPUS=1 qemu


```shell
$ alarmtest
alarmtest starting
......................................................................................................................................alarm!
............................................................................................alarm!
.......................................................................................................................................................alarm!
........................................................................................................alarm!
...................
```