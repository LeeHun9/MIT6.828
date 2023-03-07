# Homework: User-level threads

Download `uthread.c` and `uthread_switch.S` into your xv6 directory. Add the following rule to the xv6 Makefile after the _forktest rule:

```makefile
_uthread: uthread.o uthread_switch.o
	$(LD) $(LDFLAGS) -N -e main -Ttext 0 -o _uthread uthread.o uthread_switch.o $(ULIB)
	$(OBJDUMP) -S _uthread > uthread.asm
```

Run xv6, then run uthread from the xv6 shell. The xv6 kernel will print an error message about uthread encountering a page fault.

```shell
$ uthread
pid 3 uthread: trap 14 err 5 on cpu 1 eip 0xffffffff addr 0xffffffff--kill proc
```

uthread创建两个线程，并来回切换。每个线程会打印 “my thread ...”，然后让出cpu给另外的线程运行。需要完善 thread_switch.S，弄清楚uthread如何使用thread_switch。uthread使用两个全局指针变量current_thread和next_thread。

```c
struct thread {
  int        sp;                /* saved stack pointer */
  char stack[STACK_SIZE];       /* the thread's stack */
  int        state;             /* FREE, RUNNING, RUNNABLE */
};
```



```c
void 
thread_create(void (*func)())
{
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == FREE) break;
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
  t->sp -= 4;                              // space for return address
  * (int *) (t->sp) = (int)func;           // push return address on stack
  t->sp -= 32;                             // space for registers that thread_switch expects
  t->state = RUNNABLE;
}
```

uthread_switch函数用于保存当前线程的状态到current_thread中，并恢复next_thread的状态，将current_thread指针指向next_thread指向的地方。

```c
thread_switch:
	/* YOUR CODE HERE */
	// save current thread state 
	pushal
	movl current_thread, %eax
	movl %esp, (%eax)

	// restore next_thread, set esp by next_thread
	movl next_thread, %eax
	movl %eax, current_thread
	movl (%eax), %esp
	popal

	movl $0, next_thread

	ret				/* pop return address from stack */
```

```shell
init: starting sh
$ uthread
my thread running
my thread 0x2D28
my thread running
my thread 0x4D30
my thread 0x2D28
my thread 0x4D30
my thread 0x2D28
...
```