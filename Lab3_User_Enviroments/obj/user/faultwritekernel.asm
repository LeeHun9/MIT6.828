
obj/user/faultwritekernel:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	*(unsigned*)0xf0100000 = 0;
  800033:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003a:	00 00 00 
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	53                   	push   %ebx
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	e8 39 00 00 00       	call   800083 <__x86.get_pc_thunk.bx>
  80004a:	81 c3 b6 1f 00 00    	add    $0x1fb6,%ebx
  800050:	8b 45 08             	mov    0x8(%ebp),%eax
  800053:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800056:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  80005d:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 c0                	test   %eax,%eax
  800062:	7e 08                	jle    80006c <libmain+0x2e>
		binaryname = argv[0];
  800064:	8b 0a                	mov    (%edx),%ecx
  800066:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80006c:	83 ec 08             	sub    $0x8,%esp
  80006f:	52                   	push   %edx
  800070:	50                   	push   %eax
  800071:	e8 bd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800076:	e8 0c 00 00 00       	call   800087 <exit>
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800081:	c9                   	leave  
  800082:	c3                   	ret    

00800083 <__x86.get_pc_thunk.bx>:
  800083:	8b 1c 24             	mov    (%esp),%ebx
  800086:	c3                   	ret    

00800087 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800087:	55                   	push   %ebp
  800088:	89 e5                	mov    %esp,%ebp
  80008a:	53                   	push   %ebx
  80008b:	83 ec 10             	sub    $0x10,%esp
  80008e:	e8 f0 ff ff ff       	call   800083 <__x86.get_pc_thunk.bx>
  800093:	81 c3 6d 1f 00 00    	add    $0x1f6d,%ebx
	sys_env_destroy(0);
  800099:	6a 00                	push   $0x0
  80009b:	e8 45 00 00 00       	call   8000e5 <sys_env_destroy>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b9:	89 c3                	mov    %eax,%ebx
  8000bb:	89 c7                	mov    %eax,%edi
  8000bd:	89 c6                	mov    %eax,%esi
  8000bf:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	57                   	push   %edi
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d6:	89 d1                	mov    %edx,%ecx
  8000d8:	89 d3                	mov    %edx,%ebx
  8000da:	89 d7                	mov    %edx,%edi
  8000dc:	89 d6                	mov    %edx,%esi
  8000de:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    

008000e5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 1c             	sub    $0x1c,%esp
  8000ee:	e8 66 00 00 00       	call   800159 <__x86.get_pc_thunk.ax>
  8000f3:	05 0d 1f 00 00       	add    $0x1f0d,%eax
  8000f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	b8 03 00 00 00       	mov    $0x3,%eax
  800108:	89 cb                	mov    %ecx,%ebx
  80010a:	89 cf                	mov    %ecx,%edi
  80010c:	89 ce                	mov    %ecx,%esi
  80010e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800110:	85 c0                	test   %eax,%eax
  800112:	7f 08                	jg     80011c <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011c:	83 ec 0c             	sub    $0xc,%esp
  80011f:	50                   	push   %eax
  800120:	6a 03                	push   $0x3
  800122:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800125:	8d 83 1e ee ff ff    	lea    -0x11e2(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	6a 23                	push   $0x23
  80012e:	8d 83 3b ee ff ff    	lea    -0x11c5(%ebx),%eax
  800134:	50                   	push   %eax
  800135:	e8 23 00 00 00       	call   80015d <_panic>

0080013a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	57                   	push   %edi
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800140:	ba 00 00 00 00       	mov    $0x0,%edx
  800145:	b8 02 00 00 00       	mov    $0x2,%eax
  80014a:	89 d1                	mov    %edx,%ecx
  80014c:	89 d3                	mov    %edx,%ebx
  80014e:	89 d7                	mov    %edx,%edi
  800150:	89 d6                	mov    %edx,%esi
  800152:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800154:	5b                   	pop    %ebx
  800155:	5e                   	pop    %esi
  800156:	5f                   	pop    %edi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    

00800159 <__x86.get_pc_thunk.ax>:
  800159:	8b 04 24             	mov    (%esp),%eax
  80015c:	c3                   	ret    

0080015d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	57                   	push   %edi
  800161:	56                   	push   %esi
  800162:	53                   	push   %ebx
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	e8 18 ff ff ff       	call   800083 <__x86.get_pc_thunk.bx>
  80016b:	81 c3 95 1e 00 00    	add    $0x1e95,%ebx
	va_list ap;

	va_start(ap, fmt);
  800171:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800174:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80017a:	8b 38                	mov    (%eax),%edi
  80017c:	e8 b9 ff ff ff       	call   80013a <sys_getenvid>
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	ff 75 0c             	push   0xc(%ebp)
  800187:	ff 75 08             	push   0x8(%ebp)
  80018a:	57                   	push   %edi
  80018b:	50                   	push   %eax
  80018c:	8d 83 4c ee ff ff    	lea    -0x11b4(%ebx),%eax
  800192:	50                   	push   %eax
  800193:	e8 d1 00 00 00       	call   800269 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800198:	83 c4 18             	add    $0x18,%esp
  80019b:	56                   	push   %esi
  80019c:	ff 75 10             	push   0x10(%ebp)
  80019f:	e8 63 00 00 00       	call   800207 <vcprintf>
	cprintf("\n");
  8001a4:	8d 83 6f ee ff ff    	lea    -0x1191(%ebx),%eax
  8001aa:	89 04 24             	mov    %eax,(%esp)
  8001ad:	e8 b7 00 00 00       	call   800269 <cprintf>
  8001b2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b5:	cc                   	int3   
  8001b6:	eb fd                	jmp    8001b5 <_panic+0x58>

008001b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	e8 c1 fe ff ff       	call   800083 <__x86.get_pc_thunk.bx>
  8001c2:	81 c3 3e 1e 00 00    	add    $0x1e3e,%ebx
  8001c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001cb:	8b 16                	mov    (%esi),%edx
  8001cd:	8d 42 01             	lea    0x1(%edx),%eax
  8001d0:	89 06                	mov    %eax,(%esi)
  8001d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d5:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001de:	74 0b                	je     8001eb <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001e0:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5e                   	pop    %esi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	68 ff 00 00 00       	push   $0xff
  8001f3:	8d 46 08             	lea    0x8(%esi),%eax
  8001f6:	50                   	push   %eax
  8001f7:	e8 ac fe ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  8001fc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800202:	83 c4 10             	add    $0x10,%esp
  800205:	eb d9                	jmp    8001e0 <putch+0x28>

00800207 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	53                   	push   %ebx
  80020b:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800211:	e8 6d fe ff ff       	call   800083 <__x86.get_pc_thunk.bx>
  800216:	81 c3 ea 1d 00 00    	add    $0x1dea,%ebx
	struct printbuf b;

	b.idx = 0;
  80021c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800223:	00 00 00 
	b.cnt = 0;
  800226:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800230:	ff 75 0c             	push   0xc(%ebp)
  800233:	ff 75 08             	push   0x8(%ebp)
  800236:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023c:	50                   	push   %eax
  80023d:	8d 83 b8 e1 ff ff    	lea    -0x1e48(%ebx),%eax
  800243:	50                   	push   %eax
  800244:	e8 2c 01 00 00       	call   800375 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800249:	83 c4 08             	add    $0x8,%esp
  80024c:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800252:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800258:	50                   	push   %eax
  800259:	e8 4a fe ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  80025e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800264:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800267:	c9                   	leave  
  800268:	c3                   	ret    

00800269 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800272:	50                   	push   %eax
  800273:	ff 75 08             	push   0x8(%ebp)
  800276:	e8 8c ff ff ff       	call   800207 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027b:	c9                   	leave  
  80027c:	c3                   	ret    

0080027d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	57                   	push   %edi
  800281:	56                   	push   %esi
  800282:	53                   	push   %ebx
  800283:	83 ec 2c             	sub    $0x2c,%esp
  800286:	e8 cf 05 00 00       	call   80085a <__x86.get_pc_thunk.cx>
  80028b:	81 c1 75 1d 00 00    	add    $0x1d75,%ecx
  800291:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800294:	89 c7                	mov    %eax,%edi
  800296:	89 d6                	mov    %edx,%esi
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029e:	89 d1                	mov    %edx,%ecx
  8002a0:	89 c2                	mov    %eax,%edx
  8002a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002a5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ab:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b8:	39 c2                	cmp    %eax,%edx
  8002ba:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002bd:	72 41                	jb     800300 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	ff 75 18             	push   0x18(%ebp)
  8002c5:	83 eb 01             	sub    $0x1,%ebx
  8002c8:	53                   	push   %ebx
  8002c9:	50                   	push   %eax
  8002ca:	83 ec 08             	sub    $0x8,%esp
  8002cd:	ff 75 e4             	push   -0x1c(%ebp)
  8002d0:	ff 75 e0             	push   -0x20(%ebp)
  8002d3:	ff 75 d4             	push   -0x2c(%ebp)
  8002d6:	ff 75 d0             	push   -0x30(%ebp)
  8002d9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002dc:	e8 ff 08 00 00       	call   800be0 <__udivdi3>
  8002e1:	83 c4 18             	add    $0x18,%esp
  8002e4:	52                   	push   %edx
  8002e5:	50                   	push   %eax
  8002e6:	89 f2                	mov    %esi,%edx
  8002e8:	89 f8                	mov    %edi,%eax
  8002ea:	e8 8e ff ff ff       	call   80027d <printnum>
  8002ef:	83 c4 20             	add    $0x20,%esp
  8002f2:	eb 13                	jmp    800307 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f4:	83 ec 08             	sub    $0x8,%esp
  8002f7:	56                   	push   %esi
  8002f8:	ff 75 18             	push   0x18(%ebp)
  8002fb:	ff d7                	call   *%edi
  8002fd:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800300:	83 eb 01             	sub    $0x1,%ebx
  800303:	85 db                	test   %ebx,%ebx
  800305:	7f ed                	jg     8002f4 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	83 ec 04             	sub    $0x4,%esp
  80030e:	ff 75 e4             	push   -0x1c(%ebp)
  800311:	ff 75 e0             	push   -0x20(%ebp)
  800314:	ff 75 d4             	push   -0x2c(%ebp)
  800317:	ff 75 d0             	push   -0x30(%ebp)
  80031a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80031d:	e8 de 09 00 00       	call   800d00 <__umoddi3>
  800322:	83 c4 14             	add    $0x14,%esp
  800325:	0f be 84 03 71 ee ff 	movsbl -0x118f(%ebx,%eax,1),%eax
  80032c:	ff 
  80032d:	50                   	push   %eax
  80032e:	ff d7                	call   *%edi
}
  800330:	83 c4 10             	add    $0x10,%esp
  800333:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800336:	5b                   	pop    %ebx
  800337:	5e                   	pop    %esi
  800338:	5f                   	pop    %edi
  800339:	5d                   	pop    %ebp
  80033a:	c3                   	ret    

0080033b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800341:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800345:	8b 10                	mov    (%eax),%edx
  800347:	3b 50 04             	cmp    0x4(%eax),%edx
  80034a:	73 0a                	jae    800356 <sprintputch+0x1b>
		*b->buf++ = ch;
  80034c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	88 02                	mov    %al,(%edx)
}
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <printfmt>:
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80035e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800361:	50                   	push   %eax
  800362:	ff 75 10             	push   0x10(%ebp)
  800365:	ff 75 0c             	push   0xc(%ebp)
  800368:	ff 75 08             	push   0x8(%ebp)
  80036b:	e8 05 00 00 00       	call   800375 <vprintfmt>
}
  800370:	83 c4 10             	add    $0x10,%esp
  800373:	c9                   	leave  
  800374:	c3                   	ret    

00800375 <vprintfmt>:
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
  800378:	57                   	push   %edi
  800379:	56                   	push   %esi
  80037a:	53                   	push   %ebx
  80037b:	83 ec 3c             	sub    $0x3c,%esp
  80037e:	e8 d6 fd ff ff       	call   800159 <__x86.get_pc_thunk.ax>
  800383:	05 7d 1c 00 00       	add    $0x1c7d,%eax
  800388:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80038b:	8b 75 08             	mov    0x8(%ebp),%esi
  80038e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800391:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800394:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  80039a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80039d:	eb 0a                	jmp    8003a9 <vprintfmt+0x34>
			putch(ch, putdat);
  80039f:	83 ec 08             	sub    $0x8,%esp
  8003a2:	57                   	push   %edi
  8003a3:	50                   	push   %eax
  8003a4:	ff d6                	call   *%esi
  8003a6:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a9:	83 c3 01             	add    $0x1,%ebx
  8003ac:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003b0:	83 f8 25             	cmp    $0x25,%eax
  8003b3:	74 0c                	je     8003c1 <vprintfmt+0x4c>
			if (ch == '\0')
  8003b5:	85 c0                	test   %eax,%eax
  8003b7:	75 e6                	jne    80039f <vprintfmt+0x2a>
}
  8003b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003bc:	5b                   	pop    %ebx
  8003bd:	5e                   	pop    %esi
  8003be:	5f                   	pop    %edi
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    
		padc = ' ';
  8003c1:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003c5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003cc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003d3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003df:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003e2:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8d 43 01             	lea    0x1(%ebx),%eax
  8003e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003eb:	0f b6 13             	movzbl (%ebx),%edx
  8003ee:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f1:	3c 55                	cmp    $0x55,%al
  8003f3:	0f 87 c5 03 00 00    	ja     8007be <.L20>
  8003f9:	0f b6 c0             	movzbl %al,%eax
  8003fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003ff:	89 ce                	mov    %ecx,%esi
  800401:	03 b4 81 00 ef ff ff 	add    -0x1100(%ecx,%eax,4),%esi
  800408:	ff e6                	jmp    *%esi

0080040a <.L66>:
  80040a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80040d:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800411:	eb d2                	jmp    8003e5 <vprintfmt+0x70>

00800413 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800416:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  80041a:	eb c9                	jmp    8003e5 <vprintfmt+0x70>

0080041c <.L31>:
  80041c:	0f b6 d2             	movzbl %dl,%edx
  80041f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  80042a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800431:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800434:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800437:	83 f9 09             	cmp    $0x9,%ecx
  80043a:	77 58                	ja     800494 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80043c:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80043f:	eb e9                	jmp    80042a <.L31+0xe>

00800441 <.L34>:
			precision = va_arg(ap, int);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8b 00                	mov    (%eax),%eax
  800446:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 40 04             	lea    0x4(%eax),%eax
  80044f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800455:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800459:	79 8a                	jns    8003e5 <vprintfmt+0x70>
				width = precision, precision = -1;
  80045b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80045e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800461:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800468:	e9 78 ff ff ff       	jmp    8003e5 <vprintfmt+0x70>

0080046d <.L33>:
  80046d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800470:	85 d2                	test   %edx,%edx
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	0f 49 c2             	cmovns %edx,%eax
  80047a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800480:	e9 60 ff ff ff       	jmp    8003e5 <vprintfmt+0x70>

00800485 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800488:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80048f:	e9 51 ff ff ff       	jmp    8003e5 <vprintfmt+0x70>
  800494:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800497:	89 75 08             	mov    %esi,0x8(%ebp)
  80049a:	eb b9                	jmp    800455 <.L34+0x14>

0080049c <.L27>:
			lflag++;
  80049c:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004a3:	e9 3d ff ff ff       	jmp    8003e5 <vprintfmt+0x70>

008004a8 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ae:	8d 58 04             	lea    0x4(%eax),%ebx
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	57                   	push   %edi
  8004b5:	ff 30                	push   (%eax)
  8004b7:	ff d6                	call   *%esi
			break;
  8004b9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004bc:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004bf:	e9 90 02 00 00       	jmp    800754 <.L25+0x45>

008004c4 <.L28>:
			err = va_arg(ap, int);
  8004c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 58 04             	lea    0x4(%eax),%ebx
  8004cd:	8b 10                	mov    (%eax),%edx
  8004cf:	89 d0                	mov    %edx,%eax
  8004d1:	f7 d8                	neg    %eax
  8004d3:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d6:	83 f8 06             	cmp    $0x6,%eax
  8004d9:	7f 27                	jg     800502 <.L28+0x3e>
  8004db:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004de:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004e1:	85 d2                	test   %edx,%edx
  8004e3:	74 1d                	je     800502 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004e5:	52                   	push   %edx
  8004e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e9:	8d 80 92 ee ff ff    	lea    -0x116e(%eax),%eax
  8004ef:	50                   	push   %eax
  8004f0:	57                   	push   %edi
  8004f1:	56                   	push   %esi
  8004f2:	e8 61 fe ff ff       	call   800358 <printfmt>
  8004f7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004fa:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004fd:	e9 52 02 00 00       	jmp    800754 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800502:	50                   	push   %eax
  800503:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800506:	8d 80 89 ee ff ff    	lea    -0x1177(%eax),%eax
  80050c:	50                   	push   %eax
  80050d:	57                   	push   %edi
  80050e:	56                   	push   %esi
  80050f:	e8 44 fe ff ff       	call   800358 <printfmt>
  800514:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800517:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80051a:	e9 35 02 00 00       	jmp    800754 <.L25+0x45>

0080051f <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  80051f:	8b 75 08             	mov    0x8(%ebp),%esi
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	83 c0 04             	add    $0x4,%eax
  800528:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800530:	85 d2                	test   %edx,%edx
  800532:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800535:	8d 80 82 ee ff ff    	lea    -0x117e(%eax),%eax
  80053b:	0f 45 c2             	cmovne %edx,%eax
  80053e:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800541:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800545:	7e 06                	jle    80054d <.L24+0x2e>
  800547:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  80054b:	75 0d                	jne    80055a <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800550:	89 c3                	mov    %eax,%ebx
  800552:	03 45 d0             	add    -0x30(%ebp),%eax
  800555:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800558:	eb 58                	jmp    8005b2 <.L24+0x93>
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	ff 75 d8             	push   -0x28(%ebp)
  800560:	ff 75 c8             	push   -0x38(%ebp)
  800563:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800566:	e8 0b 03 00 00       	call   800876 <strnlen>
  80056b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80056e:	29 c2                	sub    %eax,%edx
  800570:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800578:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80057c:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	eb 0f                	jmp    800590 <.L24+0x71>
					putch(padc, putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	57                   	push   %edi
  800585:	ff 75 d0             	push   -0x30(%ebp)
  800588:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80058a:	83 eb 01             	sub    $0x1,%ebx
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	85 db                	test   %ebx,%ebx
  800592:	7f ed                	jg     800581 <.L24+0x62>
  800594:	8b 55 bc             	mov    -0x44(%ebp),%edx
  800597:	85 d2                	test   %edx,%edx
  800599:	b8 00 00 00 00       	mov    $0x0,%eax
  80059e:	0f 49 c2             	cmovns %edx,%eax
  8005a1:	29 c2                	sub    %eax,%edx
  8005a3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005a6:	eb a5                	jmp    80054d <.L24+0x2e>
					putch(ch, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	57                   	push   %edi
  8005ac:	52                   	push   %edx
  8005ad:	ff d6                	call   *%esi
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005b5:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b7:	83 c3 01             	add    $0x1,%ebx
  8005ba:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005be:	0f be d0             	movsbl %al,%edx
  8005c1:	85 d2                	test   %edx,%edx
  8005c3:	74 4b                	je     800610 <.L24+0xf1>
  8005c5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c9:	78 06                	js     8005d1 <.L24+0xb2>
  8005cb:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005cf:	78 1e                	js     8005ef <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005d5:	74 d1                	je     8005a8 <.L24+0x89>
  8005d7:	0f be c0             	movsbl %al,%eax
  8005da:	83 e8 20             	sub    $0x20,%eax
  8005dd:	83 f8 5e             	cmp    $0x5e,%eax
  8005e0:	76 c6                	jbe    8005a8 <.L24+0x89>
					putch('?', putdat);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	57                   	push   %edi
  8005e6:	6a 3f                	push   $0x3f
  8005e8:	ff d6                	call   *%esi
  8005ea:	83 c4 10             	add    $0x10,%esp
  8005ed:	eb c3                	jmp    8005b2 <.L24+0x93>
  8005ef:	89 cb                	mov    %ecx,%ebx
  8005f1:	eb 0e                	jmp    800601 <.L24+0xe2>
				putch(' ', putdat);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	57                   	push   %edi
  8005f7:	6a 20                	push   $0x20
  8005f9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005fb:	83 eb 01             	sub    $0x1,%ebx
  8005fe:	83 c4 10             	add    $0x10,%esp
  800601:	85 db                	test   %ebx,%ebx
  800603:	7f ee                	jg     8005f3 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800605:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800608:	89 45 14             	mov    %eax,0x14(%ebp)
  80060b:	e9 44 01 00 00       	jmp    800754 <.L25+0x45>
  800610:	89 cb                	mov    %ecx,%ebx
  800612:	eb ed                	jmp    800601 <.L24+0xe2>

00800614 <.L29>:
	if (lflag >= 2)
  800614:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800617:	8b 75 08             	mov    0x8(%ebp),%esi
  80061a:	83 f9 01             	cmp    $0x1,%ecx
  80061d:	7f 1b                	jg     80063a <.L29+0x26>
	else if (lflag)
  80061f:	85 c9                	test   %ecx,%ecx
  800621:	74 63                	je     800686 <.L29+0x72>
		return va_arg(*ap, long);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 00                	mov    (%eax),%eax
  800628:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062b:	99                   	cltd   
  80062c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8d 40 04             	lea    0x4(%eax),%eax
  800635:	89 45 14             	mov    %eax,0x14(%ebp)
  800638:	eb 17                	jmp    800651 <.L29+0x3d>
		return va_arg(*ap, long long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 50 04             	mov    0x4(%eax),%edx
  800640:	8b 00                	mov    (%eax),%eax
  800642:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800645:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 40 08             	lea    0x8(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800651:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800654:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800657:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80065c:	85 db                	test   %ebx,%ebx
  80065e:	0f 89 d6 00 00 00    	jns    80073a <.L25+0x2b>
				putch('-', putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	57                   	push   %edi
  800668:	6a 2d                	push   $0x2d
  80066a:	ff d6                	call   *%esi
				num = -(long long) num;
  80066c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80066f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800672:	f7 d9                	neg    %ecx
  800674:	83 d3 00             	adc    $0x0,%ebx
  800677:	f7 db                	neg    %ebx
  800679:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80067c:	ba 0a 00 00 00       	mov    $0xa,%edx
  800681:	e9 b4 00 00 00       	jmp    80073a <.L25+0x2b>
		return va_arg(*ap, int);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8b 00                	mov    (%eax),%eax
  80068b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068e:	99                   	cltd   
  80068f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 40 04             	lea    0x4(%eax),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
  80069b:	eb b4                	jmp    800651 <.L29+0x3d>

0080069d <.L23>:
	if (lflag >= 2)
  80069d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a3:	83 f9 01             	cmp    $0x1,%ecx
  8006a6:	7f 1b                	jg     8006c3 <.L23+0x26>
	else if (lflag)
  8006a8:	85 c9                	test   %ecx,%ecx
  8006aa:	74 2c                	je     8006d8 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 08                	mov    (%eax),%ecx
  8006b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006bc:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006c1:	eb 77                	jmp    80073a <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 08                	mov    (%eax),%ecx
  8006c8:	8b 58 04             	mov    0x4(%eax),%ebx
  8006cb:	8d 40 08             	lea    0x8(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d1:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006d6:	eb 62                	jmp    80073a <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8b 08                	mov    (%eax),%ecx
  8006dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e2:	8d 40 04             	lea    0x4(%eax),%eax
  8006e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e8:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006ed:	eb 4b                	jmp    80073a <.L25+0x2b>

008006ef <.L26>:
			putch('X', putdat);
  8006ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	57                   	push   %edi
  8006f6:	6a 58                	push   $0x58
  8006f8:	ff d6                	call   *%esi
			putch('X', putdat);
  8006fa:	83 c4 08             	add    $0x8,%esp
  8006fd:	57                   	push   %edi
  8006fe:	6a 58                	push   $0x58
  800700:	ff d6                	call   *%esi
			putch('X', putdat);
  800702:	83 c4 08             	add    $0x8,%esp
  800705:	57                   	push   %edi
  800706:	6a 58                	push   $0x58
  800708:	ff d6                	call   *%esi
			break;
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	eb 45                	jmp    800754 <.L25+0x45>

0080070f <.L25>:
			putch('0', putdat);
  80070f:	8b 75 08             	mov    0x8(%ebp),%esi
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	57                   	push   %edi
  800716:	6a 30                	push   $0x30
  800718:	ff d6                	call   *%esi
			putch('x', putdat);
  80071a:	83 c4 08             	add    $0x8,%esp
  80071d:	57                   	push   %edi
  80071e:	6a 78                	push   $0x78
  800720:	ff d6                	call   *%esi
			num = (unsigned long long)
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8b 08                	mov    (%eax),%ecx
  800727:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80072c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800735:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  80073a:	83 ec 0c             	sub    $0xc,%esp
  80073d:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800741:	50                   	push   %eax
  800742:	ff 75 d0             	push   -0x30(%ebp)
  800745:	52                   	push   %edx
  800746:	53                   	push   %ebx
  800747:	51                   	push   %ecx
  800748:	89 fa                	mov    %edi,%edx
  80074a:	89 f0                	mov    %esi,%eax
  80074c:	e8 2c fb ff ff       	call   80027d <printnum>
			break;
  800751:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800754:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800757:	e9 4d fc ff ff       	jmp    8003a9 <vprintfmt+0x34>

0080075c <.L21>:
	if (lflag >= 2)
  80075c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80075f:	8b 75 08             	mov    0x8(%ebp),%esi
  800762:	83 f9 01             	cmp    $0x1,%ecx
  800765:	7f 1b                	jg     800782 <.L21+0x26>
	else if (lflag)
  800767:	85 c9                	test   %ecx,%ecx
  800769:	74 2c                	je     800797 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8b 08                	mov    (%eax),%ecx
  800770:	bb 00 00 00 00       	mov    $0x0,%ebx
  800775:	8d 40 04             	lea    0x4(%eax),%eax
  800778:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80077b:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  800780:	eb b8                	jmp    80073a <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8b 08                	mov    (%eax),%ecx
  800787:	8b 58 04             	mov    0x4(%eax),%ebx
  80078a:	8d 40 08             	lea    0x8(%eax),%eax
  80078d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800790:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  800795:	eb a3                	jmp    80073a <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8b 08                	mov    (%eax),%ecx
  80079c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a1:	8d 40 04             	lea    0x4(%eax),%eax
  8007a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a7:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007ac:	eb 8c                	jmp    80073a <.L25+0x2b>

008007ae <.L35>:
			putch(ch, putdat);
  8007ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b1:	83 ec 08             	sub    $0x8,%esp
  8007b4:	57                   	push   %edi
  8007b5:	6a 25                	push   $0x25
  8007b7:	ff d6                	call   *%esi
			break;
  8007b9:	83 c4 10             	add    $0x10,%esp
  8007bc:	eb 96                	jmp    800754 <.L25+0x45>

008007be <.L20>:
			putch('%', putdat);
  8007be:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c1:	83 ec 08             	sub    $0x8,%esp
  8007c4:	57                   	push   %edi
  8007c5:	6a 25                	push   $0x25
  8007c7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c9:	83 c4 10             	add    $0x10,%esp
  8007cc:	89 d8                	mov    %ebx,%eax
  8007ce:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007d2:	74 05                	je     8007d9 <.L20+0x1b>
  8007d4:	83 e8 01             	sub    $0x1,%eax
  8007d7:	eb f5                	jmp    8007ce <.L20+0x10>
  8007d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007dc:	e9 73 ff ff ff       	jmp    800754 <.L25+0x45>

008007e1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	83 ec 14             	sub    $0x14,%esp
  8007e8:	e8 96 f8 ff ff       	call   800083 <__x86.get_pc_thunk.bx>
  8007ed:	81 c3 13 18 00 00    	add    $0x1813,%ebx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800800:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800803:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080a:	85 c0                	test   %eax,%eax
  80080c:	74 2b                	je     800839 <vsnprintf+0x58>
  80080e:	85 d2                	test   %edx,%edx
  800810:	7e 27                	jle    800839 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800812:	ff 75 14             	push   0x14(%ebp)
  800815:	ff 75 10             	push   0x10(%ebp)
  800818:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80081b:	50                   	push   %eax
  80081c:	8d 83 3b e3 ff ff    	lea    -0x1cc5(%ebx),%eax
  800822:	50                   	push   %eax
  800823:	e8 4d fb ff ff       	call   800375 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800828:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800831:	83 c4 10             	add    $0x10,%esp
}
  800834:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800837:	c9                   	leave  
  800838:	c3                   	ret    
		return -E_INVAL;
  800839:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083e:	eb f4                	jmp    800834 <vsnprintf+0x53>

00800840 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800849:	50                   	push   %eax
  80084a:	ff 75 10             	push   0x10(%ebp)
  80084d:	ff 75 0c             	push   0xc(%ebp)
  800850:	ff 75 08             	push   0x8(%ebp)
  800853:	e8 89 ff ff ff       	call   8007e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <__x86.get_pc_thunk.cx>:
  80085a:	8b 0c 24             	mov    (%esp),%ecx
  80085d:	c3                   	ret    

0080085e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800864:	b8 00 00 00 00       	mov    $0x0,%eax
  800869:	eb 03                	jmp    80086e <strlen+0x10>
		n++;
  80086b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80086e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800872:	75 f7                	jne    80086b <strlen+0xd>
	return n;
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
  800884:	eb 03                	jmp    800889 <strnlen+0x13>
		n++;
  800886:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800889:	39 d0                	cmp    %edx,%eax
  80088b:	74 08                	je     800895 <strnlen+0x1f>
  80088d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800891:	75 f3                	jne    800886 <strnlen+0x10>
  800893:	89 c2                	mov    %eax,%edx
	return n;
}
  800895:	89 d0                	mov    %edx,%eax
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008ac:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	75 f2                	jne    8008a8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b6:	89 c8                	mov    %ecx,%eax
  8008b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	53                   	push   %ebx
  8008c1:	83 ec 10             	sub    $0x10,%esp
  8008c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c7:	53                   	push   %ebx
  8008c8:	e8 91 ff ff ff       	call   80085e <strlen>
  8008cd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008d0:	ff 75 0c             	push   0xc(%ebp)
  8008d3:	01 d8                	add    %ebx,%eax
  8008d5:	50                   	push   %eax
  8008d6:	e8 be ff ff ff       	call   800899 <strcpy>
	return dst;
}
  8008db:	89 d8                	mov    %ebx,%eax
  8008dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    

008008e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 f3                	mov    %esi,%ebx
  8008ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f2:	89 f0                	mov    %esi,%eax
  8008f4:	eb 0f                	jmp    800905 <strncpy+0x23>
		*dst++ = *src;
  8008f6:	83 c0 01             	add    $0x1,%eax
  8008f9:	0f b6 0a             	movzbl (%edx),%ecx
  8008fc:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ff:	80 f9 01             	cmp    $0x1,%cl
  800902:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800905:	39 d8                	cmp    %ebx,%eax
  800907:	75 ed                	jne    8008f6 <strncpy+0x14>
	}
	return ret;
}
  800909:	89 f0                	mov    %esi,%eax
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 75 08             	mov    0x8(%ebp),%esi
  800917:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091a:	8b 55 10             	mov    0x10(%ebp),%edx
  80091d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80091f:	85 d2                	test   %edx,%edx
  800921:	74 21                	je     800944 <strlcpy+0x35>
  800923:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800927:	89 f2                	mov    %esi,%edx
  800929:	eb 09                	jmp    800934 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092b:	83 c1 01             	add    $0x1,%ecx
  80092e:	83 c2 01             	add    $0x1,%edx
  800931:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800934:	39 c2                	cmp    %eax,%edx
  800936:	74 09                	je     800941 <strlcpy+0x32>
  800938:	0f b6 19             	movzbl (%ecx),%ebx
  80093b:	84 db                	test   %bl,%bl
  80093d:	75 ec                	jne    80092b <strlcpy+0x1c>
  80093f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800941:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800944:	29 f0                	sub    %esi,%eax
}
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800950:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800953:	eb 06                	jmp    80095b <strcmp+0x11>
		p++, q++;
  800955:	83 c1 01             	add    $0x1,%ecx
  800958:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80095b:	0f b6 01             	movzbl (%ecx),%eax
  80095e:	84 c0                	test   %al,%al
  800960:	74 04                	je     800966 <strcmp+0x1c>
  800962:	3a 02                	cmp    (%edx),%al
  800964:	74 ef                	je     800955 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800966:	0f b6 c0             	movzbl %al,%eax
  800969:	0f b6 12             	movzbl (%edx),%edx
  80096c:	29 d0                	sub    %edx,%eax
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097a:	89 c3                	mov    %eax,%ebx
  80097c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80097f:	eb 06                	jmp    800987 <strncmp+0x17>
		n--, p++, q++;
  800981:	83 c0 01             	add    $0x1,%eax
  800984:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800987:	39 d8                	cmp    %ebx,%eax
  800989:	74 18                	je     8009a3 <strncmp+0x33>
  80098b:	0f b6 08             	movzbl (%eax),%ecx
  80098e:	84 c9                	test   %cl,%cl
  800990:	74 04                	je     800996 <strncmp+0x26>
  800992:	3a 0a                	cmp    (%edx),%cl
  800994:	74 eb                	je     800981 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800996:	0f b6 00             	movzbl (%eax),%eax
  800999:	0f b6 12             	movzbl (%edx),%edx
  80099c:	29 d0                	sub    %edx,%eax
}
  80099e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    
		return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a8:	eb f4                	jmp    80099e <strncmp+0x2e>

008009aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b4:	eb 03                	jmp    8009b9 <strchr+0xf>
  8009b6:	83 c0 01             	add    $0x1,%eax
  8009b9:	0f b6 10             	movzbl (%eax),%edx
  8009bc:	84 d2                	test   %dl,%dl
  8009be:	74 06                	je     8009c6 <strchr+0x1c>
		if (*s == c)
  8009c0:	38 ca                	cmp    %cl,%dl
  8009c2:	75 f2                	jne    8009b6 <strchr+0xc>
  8009c4:	eb 05                	jmp    8009cb <strchr+0x21>
			return (char *) s;
	return 0;
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009da:	38 ca                	cmp    %cl,%dl
  8009dc:	74 09                	je     8009e7 <strfind+0x1a>
  8009de:	84 d2                	test   %dl,%dl
  8009e0:	74 05                	je     8009e7 <strfind+0x1a>
	for (; *s; s++)
  8009e2:	83 c0 01             	add    $0x1,%eax
  8009e5:	eb f0                	jmp    8009d7 <strfind+0xa>
			break;
	return (char *) s;
}
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	57                   	push   %edi
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f5:	85 c9                	test   %ecx,%ecx
  8009f7:	74 2f                	je     800a28 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f9:	89 f8                	mov    %edi,%eax
  8009fb:	09 c8                	or     %ecx,%eax
  8009fd:	a8 03                	test   $0x3,%al
  8009ff:	75 21                	jne    800a22 <memset+0x39>
		c &= 0xFF;
  800a01:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a05:	89 d0                	mov    %edx,%eax
  800a07:	c1 e0 08             	shl    $0x8,%eax
  800a0a:	89 d3                	mov    %edx,%ebx
  800a0c:	c1 e3 18             	shl    $0x18,%ebx
  800a0f:	89 d6                	mov    %edx,%esi
  800a11:	c1 e6 10             	shl    $0x10,%esi
  800a14:	09 f3                	or     %esi,%ebx
  800a16:	09 da                	or     %ebx,%edx
  800a18:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a1a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a1d:	fc                   	cld    
  800a1e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a20:	eb 06                	jmp    800a28 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a25:	fc                   	cld    
  800a26:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a28:	89 f8                	mov    %edi,%eax
  800a2a:	5b                   	pop    %ebx
  800a2b:	5e                   	pop    %esi
  800a2c:	5f                   	pop    %edi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	57                   	push   %edi
  800a33:	56                   	push   %esi
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a3d:	39 c6                	cmp    %eax,%esi
  800a3f:	73 32                	jae    800a73 <memmove+0x44>
  800a41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a44:	39 c2                	cmp    %eax,%edx
  800a46:	76 2b                	jbe    800a73 <memmove+0x44>
		s += n;
		d += n;
  800a48:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4b:	89 d6                	mov    %edx,%esi
  800a4d:	09 fe                	or     %edi,%esi
  800a4f:	09 ce                	or     %ecx,%esi
  800a51:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a57:	75 0e                	jne    800a67 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a59:	83 ef 04             	sub    $0x4,%edi
  800a5c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a62:	fd                   	std    
  800a63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a65:	eb 09                	jmp    800a70 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a67:	83 ef 01             	sub    $0x1,%edi
  800a6a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a6d:	fd                   	std    
  800a6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a70:	fc                   	cld    
  800a71:	eb 1a                	jmp    800a8d <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a73:	89 f2                	mov    %esi,%edx
  800a75:	09 c2                	or     %eax,%edx
  800a77:	09 ca                	or     %ecx,%edx
  800a79:	f6 c2 03             	test   $0x3,%dl
  800a7c:	75 0a                	jne    800a88 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a7e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a81:	89 c7                	mov    %eax,%edi
  800a83:	fc                   	cld    
  800a84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a86:	eb 05                	jmp    800a8d <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a88:	89 c7                	mov    %eax,%edi
  800a8a:	fc                   	cld    
  800a8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a97:	ff 75 10             	push   0x10(%ebp)
  800a9a:	ff 75 0c             	push   0xc(%ebp)
  800a9d:	ff 75 08             	push   0x8(%ebp)
  800aa0:	e8 8a ff ff ff       	call   800a2f <memmove>
}
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab2:	89 c6                	mov    %eax,%esi
  800ab4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab7:	eb 06                	jmp    800abf <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab9:	83 c0 01             	add    $0x1,%eax
  800abc:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800abf:	39 f0                	cmp    %esi,%eax
  800ac1:	74 14                	je     800ad7 <memcmp+0x30>
		if (*s1 != *s2)
  800ac3:	0f b6 08             	movzbl (%eax),%ecx
  800ac6:	0f b6 1a             	movzbl (%edx),%ebx
  800ac9:	38 d9                	cmp    %bl,%cl
  800acb:	74 ec                	je     800ab9 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800acd:	0f b6 c1             	movzbl %cl,%eax
  800ad0:	0f b6 db             	movzbl %bl,%ebx
  800ad3:	29 d8                	sub    %ebx,%eax
  800ad5:	eb 05                	jmp    800adc <memcmp+0x35>
	}

	return 0;
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae9:	89 c2                	mov    %eax,%edx
  800aeb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aee:	eb 03                	jmp    800af3 <memfind+0x13>
  800af0:	83 c0 01             	add    $0x1,%eax
  800af3:	39 d0                	cmp    %edx,%eax
  800af5:	73 04                	jae    800afb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af7:	38 08                	cmp    %cl,(%eax)
  800af9:	75 f5                	jne    800af0 <memfind+0x10>
			break;
	return (void *) s;
}
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	8b 55 08             	mov    0x8(%ebp),%edx
  800b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b09:	eb 03                	jmp    800b0e <strtol+0x11>
		s++;
  800b0b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b0e:	0f b6 02             	movzbl (%edx),%eax
  800b11:	3c 20                	cmp    $0x20,%al
  800b13:	74 f6                	je     800b0b <strtol+0xe>
  800b15:	3c 09                	cmp    $0x9,%al
  800b17:	74 f2                	je     800b0b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b19:	3c 2b                	cmp    $0x2b,%al
  800b1b:	74 2a                	je     800b47 <strtol+0x4a>
	int neg = 0;
  800b1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b22:	3c 2d                	cmp    $0x2d,%al
  800b24:	74 2b                	je     800b51 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b2c:	75 0f                	jne    800b3d <strtol+0x40>
  800b2e:	80 3a 30             	cmpb   $0x30,(%edx)
  800b31:	74 28                	je     800b5b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b33:	85 db                	test   %ebx,%ebx
  800b35:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b3a:	0f 44 d8             	cmove  %eax,%ebx
  800b3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b42:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b45:	eb 46                	jmp    800b8d <strtol+0x90>
		s++;
  800b47:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4f:	eb d5                	jmp    800b26 <strtol+0x29>
		s++, neg = 1;
  800b51:	83 c2 01             	add    $0x1,%edx
  800b54:	bf 01 00 00 00       	mov    $0x1,%edi
  800b59:	eb cb                	jmp    800b26 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b5f:	74 0e                	je     800b6f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b61:	85 db                	test   %ebx,%ebx
  800b63:	75 d8                	jne    800b3d <strtol+0x40>
		s++, base = 8;
  800b65:	83 c2 01             	add    $0x1,%edx
  800b68:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b6d:	eb ce                	jmp    800b3d <strtol+0x40>
		s += 2, base = 16;
  800b6f:	83 c2 02             	add    $0x2,%edx
  800b72:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b77:	eb c4                	jmp    800b3d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b79:	0f be c0             	movsbl %al,%eax
  800b7c:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b82:	7d 3a                	jge    800bbe <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b84:	83 c2 01             	add    $0x1,%edx
  800b87:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b8b:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b8d:	0f b6 02             	movzbl (%edx),%eax
  800b90:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b93:	89 f3                	mov    %esi,%ebx
  800b95:	80 fb 09             	cmp    $0x9,%bl
  800b98:	76 df                	jbe    800b79 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b9a:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	80 fb 19             	cmp    $0x19,%bl
  800ba2:	77 08                	ja     800bac <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ba4:	0f be c0             	movsbl %al,%eax
  800ba7:	83 e8 57             	sub    $0x57,%eax
  800baa:	eb d3                	jmp    800b7f <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bac:	8d 70 bf             	lea    -0x41(%eax),%esi
  800baf:	89 f3                	mov    %esi,%ebx
  800bb1:	80 fb 19             	cmp    $0x19,%bl
  800bb4:	77 08                	ja     800bbe <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bb6:	0f be c0             	movsbl %al,%eax
  800bb9:	83 e8 37             	sub    $0x37,%eax
  800bbc:	eb c1                	jmp    800b7f <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bbe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc2:	74 05                	je     800bc9 <strtol+0xcc>
		*endptr = (char *) s;
  800bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc7:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bc9:	89 c8                	mov    %ecx,%eax
  800bcb:	f7 d8                	neg    %eax
  800bcd:	85 ff                	test   %edi,%edi
  800bcf:	0f 45 c8             	cmovne %eax,%ecx
}
  800bd2:	89 c8                	mov    %ecx,%eax
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    
  800bd9:	66 90                	xchg   %ax,%ax
  800bdb:	66 90                	xchg   %ax,%ax
  800bdd:	66 90                	xchg   %ax,%ax
  800bdf:	90                   	nop

00800be0 <__udivdi3>:
  800be0:	f3 0f 1e fb          	endbr32 
  800be4:	55                   	push   %ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 1c             	sub    $0x1c,%esp
  800beb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800bf3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800bf7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	75 19                	jne    800c18 <__udivdi3+0x38>
  800bff:	39 f3                	cmp    %esi,%ebx
  800c01:	76 4d                	jbe    800c50 <__udivdi3+0x70>
  800c03:	31 ff                	xor    %edi,%edi
  800c05:	89 e8                	mov    %ebp,%eax
  800c07:	89 f2                	mov    %esi,%edx
  800c09:	f7 f3                	div    %ebx
  800c0b:	89 fa                	mov    %edi,%edx
  800c0d:	83 c4 1c             	add    $0x1c,%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    
  800c15:	8d 76 00             	lea    0x0(%esi),%esi
  800c18:	39 f0                	cmp    %esi,%eax
  800c1a:	76 14                	jbe    800c30 <__udivdi3+0x50>
  800c1c:	31 ff                	xor    %edi,%edi
  800c1e:	31 c0                	xor    %eax,%eax
  800c20:	89 fa                	mov    %edi,%edx
  800c22:	83 c4 1c             	add    $0x1c,%esp
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    
  800c2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c30:	0f bd f8             	bsr    %eax,%edi
  800c33:	83 f7 1f             	xor    $0x1f,%edi
  800c36:	75 48                	jne    800c80 <__udivdi3+0xa0>
  800c38:	39 f0                	cmp    %esi,%eax
  800c3a:	72 06                	jb     800c42 <__udivdi3+0x62>
  800c3c:	31 c0                	xor    %eax,%eax
  800c3e:	39 eb                	cmp    %ebp,%ebx
  800c40:	77 de                	ja     800c20 <__udivdi3+0x40>
  800c42:	b8 01 00 00 00       	mov    $0x1,%eax
  800c47:	eb d7                	jmp    800c20 <__udivdi3+0x40>
  800c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c50:	89 d9                	mov    %ebx,%ecx
  800c52:	85 db                	test   %ebx,%ebx
  800c54:	75 0b                	jne    800c61 <__udivdi3+0x81>
  800c56:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5b:	31 d2                	xor    %edx,%edx
  800c5d:	f7 f3                	div    %ebx
  800c5f:	89 c1                	mov    %eax,%ecx
  800c61:	31 d2                	xor    %edx,%edx
  800c63:	89 f0                	mov    %esi,%eax
  800c65:	f7 f1                	div    %ecx
  800c67:	89 c6                	mov    %eax,%esi
  800c69:	89 e8                	mov    %ebp,%eax
  800c6b:	89 f7                	mov    %esi,%edi
  800c6d:	f7 f1                	div    %ecx
  800c6f:	89 fa                	mov    %edi,%edx
  800c71:	83 c4 1c             	add    $0x1c,%esp
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    
  800c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c80:	89 f9                	mov    %edi,%ecx
  800c82:	ba 20 00 00 00       	mov    $0x20,%edx
  800c87:	29 fa                	sub    %edi,%edx
  800c89:	d3 e0                	shl    %cl,%eax
  800c8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8f:	89 d1                	mov    %edx,%ecx
  800c91:	89 d8                	mov    %ebx,%eax
  800c93:	d3 e8                	shr    %cl,%eax
  800c95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c99:	09 c1                	or     %eax,%ecx
  800c9b:	89 f0                	mov    %esi,%eax
  800c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ca1:	89 f9                	mov    %edi,%ecx
  800ca3:	d3 e3                	shl    %cl,%ebx
  800ca5:	89 d1                	mov    %edx,%ecx
  800ca7:	d3 e8                	shr    %cl,%eax
  800ca9:	89 f9                	mov    %edi,%ecx
  800cab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800caf:	89 eb                	mov    %ebp,%ebx
  800cb1:	d3 e6                	shl    %cl,%esi
  800cb3:	89 d1                	mov    %edx,%ecx
  800cb5:	d3 eb                	shr    %cl,%ebx
  800cb7:	09 f3                	or     %esi,%ebx
  800cb9:	89 c6                	mov    %eax,%esi
  800cbb:	89 f2                	mov    %esi,%edx
  800cbd:	89 d8                	mov    %ebx,%eax
  800cbf:	f7 74 24 08          	divl   0x8(%esp)
  800cc3:	89 d6                	mov    %edx,%esi
  800cc5:	89 c3                	mov    %eax,%ebx
  800cc7:	f7 64 24 0c          	mull   0xc(%esp)
  800ccb:	39 d6                	cmp    %edx,%esi
  800ccd:	72 19                	jb     800ce8 <__udivdi3+0x108>
  800ccf:	89 f9                	mov    %edi,%ecx
  800cd1:	d3 e5                	shl    %cl,%ebp
  800cd3:	39 c5                	cmp    %eax,%ebp
  800cd5:	73 04                	jae    800cdb <__udivdi3+0xfb>
  800cd7:	39 d6                	cmp    %edx,%esi
  800cd9:	74 0d                	je     800ce8 <__udivdi3+0x108>
  800cdb:	89 d8                	mov    %ebx,%eax
  800cdd:	31 ff                	xor    %edi,%edi
  800cdf:	e9 3c ff ff ff       	jmp    800c20 <__udivdi3+0x40>
  800ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ceb:	31 ff                	xor    %edi,%edi
  800ced:	e9 2e ff ff ff       	jmp    800c20 <__udivdi3+0x40>
  800cf2:	66 90                	xchg   %ax,%ax
  800cf4:	66 90                	xchg   %ax,%ax
  800cf6:	66 90                	xchg   %ax,%ax
  800cf8:	66 90                	xchg   %ax,%ax
  800cfa:	66 90                	xchg   %ax,%ax
  800cfc:	66 90                	xchg   %ax,%ax
  800cfe:	66 90                	xchg   %ax,%ax

00800d00 <__umoddi3>:
  800d00:	f3 0f 1e fb          	endbr32 
  800d04:	55                   	push   %ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	83 ec 1c             	sub    $0x1c,%esp
  800d0b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d13:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d17:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d1b:	89 f0                	mov    %esi,%eax
  800d1d:	89 da                	mov    %ebx,%edx
  800d1f:	85 ff                	test   %edi,%edi
  800d21:	75 15                	jne    800d38 <__umoddi3+0x38>
  800d23:	39 dd                	cmp    %ebx,%ebp
  800d25:	76 39                	jbe    800d60 <__umoddi3+0x60>
  800d27:	f7 f5                	div    %ebp
  800d29:	89 d0                	mov    %edx,%eax
  800d2b:	31 d2                	xor    %edx,%edx
  800d2d:	83 c4 1c             	add    $0x1c,%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    
  800d35:	8d 76 00             	lea    0x0(%esi),%esi
  800d38:	39 df                	cmp    %ebx,%edi
  800d3a:	77 f1                	ja     800d2d <__umoddi3+0x2d>
  800d3c:	0f bd cf             	bsr    %edi,%ecx
  800d3f:	83 f1 1f             	xor    $0x1f,%ecx
  800d42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d46:	75 40                	jne    800d88 <__umoddi3+0x88>
  800d48:	39 df                	cmp    %ebx,%edi
  800d4a:	72 04                	jb     800d50 <__umoddi3+0x50>
  800d4c:	39 f5                	cmp    %esi,%ebp
  800d4e:	77 dd                	ja     800d2d <__umoddi3+0x2d>
  800d50:	89 da                	mov    %ebx,%edx
  800d52:	89 f0                	mov    %esi,%eax
  800d54:	29 e8                	sub    %ebp,%eax
  800d56:	19 fa                	sbb    %edi,%edx
  800d58:	eb d3                	jmp    800d2d <__umoddi3+0x2d>
  800d5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d60:	89 e9                	mov    %ebp,%ecx
  800d62:	85 ed                	test   %ebp,%ebp
  800d64:	75 0b                	jne    800d71 <__umoddi3+0x71>
  800d66:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	f7 f5                	div    %ebp
  800d6f:	89 c1                	mov    %eax,%ecx
  800d71:	89 d8                	mov    %ebx,%eax
  800d73:	31 d2                	xor    %edx,%edx
  800d75:	f7 f1                	div    %ecx
  800d77:	89 f0                	mov    %esi,%eax
  800d79:	f7 f1                	div    %ecx
  800d7b:	89 d0                	mov    %edx,%eax
  800d7d:	31 d2                	xor    %edx,%edx
  800d7f:	eb ac                	jmp    800d2d <__umoddi3+0x2d>
  800d81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d88:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d8c:	ba 20 00 00 00       	mov    $0x20,%edx
  800d91:	29 c2                	sub    %eax,%edx
  800d93:	89 c1                	mov    %eax,%ecx
  800d95:	89 e8                	mov    %ebp,%eax
  800d97:	d3 e7                	shl    %cl,%edi
  800d99:	89 d1                	mov    %edx,%ecx
  800d9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d9f:	d3 e8                	shr    %cl,%eax
  800da1:	89 c1                	mov    %eax,%ecx
  800da3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800da7:	09 f9                	or     %edi,%ecx
  800da9:	89 df                	mov    %ebx,%edi
  800dab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800daf:	89 c1                	mov    %eax,%ecx
  800db1:	d3 e5                	shl    %cl,%ebp
  800db3:	89 d1                	mov    %edx,%ecx
  800db5:	d3 ef                	shr    %cl,%edi
  800db7:	89 c1                	mov    %eax,%ecx
  800db9:	89 f0                	mov    %esi,%eax
  800dbb:	d3 e3                	shl    %cl,%ebx
  800dbd:	89 d1                	mov    %edx,%ecx
  800dbf:	89 fa                	mov    %edi,%edx
  800dc1:	d3 e8                	shr    %cl,%eax
  800dc3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dc8:	09 d8                	or     %ebx,%eax
  800dca:	f7 74 24 08          	divl   0x8(%esp)
  800dce:	89 d3                	mov    %edx,%ebx
  800dd0:	d3 e6                	shl    %cl,%esi
  800dd2:	f7 e5                	mul    %ebp
  800dd4:	89 c7                	mov    %eax,%edi
  800dd6:	89 d1                	mov    %edx,%ecx
  800dd8:	39 d3                	cmp    %edx,%ebx
  800dda:	72 06                	jb     800de2 <__umoddi3+0xe2>
  800ddc:	75 0e                	jne    800dec <__umoddi3+0xec>
  800dde:	39 c6                	cmp    %eax,%esi
  800de0:	73 0a                	jae    800dec <__umoddi3+0xec>
  800de2:	29 e8                	sub    %ebp,%eax
  800de4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800de8:	89 d1                	mov    %edx,%ecx
  800dea:	89 c7                	mov    %eax,%edi
  800dec:	89 f5                	mov    %esi,%ebp
  800dee:	8b 74 24 04          	mov    0x4(%esp),%esi
  800df2:	29 fd                	sub    %edi,%ebp
  800df4:	19 cb                	sbb    %ecx,%ebx
  800df6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800dfb:	89 d8                	mov    %ebx,%eax
  800dfd:	d3 e0                	shl    %cl,%eax
  800dff:	89 f1                	mov    %esi,%ecx
  800e01:	d3 ed                	shr    %cl,%ebp
  800e03:	d3 eb                	shr    %cl,%ebx
  800e05:	09 e8                	or     %ebp,%eax
  800e07:	89 da                	mov    %ebx,%edx
  800e09:	83 c4 1c             	add    $0x1c,%esp
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    
