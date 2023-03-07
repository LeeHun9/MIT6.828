# Homework: xv6 locking

## Don't do this
Make sure you understand what would happen if the xv6 kernel executed the following code snippet:

  struct spinlock lk;
  initlock(&lk, "test lock");
  acquire(&lk);
  acquire(&lk);

`acquire()` in spinlock.c
```c
// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
    panic("acquire");

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
  getcallerpcs(&lk, lk->pcs);
}
```
twice acquire will make panic

## Interrupts in ide.c

An acquire ensures that interrupts are off on the local processor using the cli instruction (via `pushcli()`), and that interrupts remain off until the release of the last lock held by that processor (at which point they are enabled using `popsti()`).

Let's see what happens if we turn on interrupts while holding the ide lock. In iderw in ide.c, add a call to sti() after the acquire(), and a call to cli() just before the release(). Rebuild the kernel and boot it in QEMU.

```c
acquire(&idelock);  //DOC:acquire-lock
sti();
...
cli();
release(&idelock);
```

重新编译kernel和启动QEMU，有些时候kernel在启动之后会panic，多尝试几次之后直到kernel正常启动。
```sh
cpu1: starting 1
cpu0: starting 0
lapicid 0: panic: sched locks
 80103dc1 80104062 80105b2f 8010592c 80100191 801015ac 801038f4 8010592f 0 0

cpu1: starting 1
cpu0: starting 0
sb: size 1000 nblocks 941 ninodes 200 nlog 30 logstart 2 inodestart 32 bmap start 58
init: starting sh
$ 
```

## Interrupts in file.c

当hold file_table_lock的时候，打开中断会发生什么。这lock是用来保护file descriptor table的，当一个应用程序open或close一个文件的时候kernel会修改这个表。

Remove the sti() and cli() you added, rebuild the kernel, and make sure it works again. In filealloc() in file.c, add a call to sti() after the call to acquire(),and a cli() just before each of the release()es.

之后重新编译kernel并运行，你会发现启动多少次后都不会panic。这个主要是因为filealloc()在alloc的时候，时间很短，所以很难发生死锁。

## xv6 lock implementation

Why does release() clear lk->pcs[0] and lk->cpu before clearing lk->locked?Why not wait until after?

因为假如先清理掉lk->locked，那么lock就没了，新的进程可能就会在lk->pcs[0]和lk->cpu被清零之前获得lock，但是此时的lk->cpu和lk->pcs[0]还是之前的那个，那么就会导致不一致。