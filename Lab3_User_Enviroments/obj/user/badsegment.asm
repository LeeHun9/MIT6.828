
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void
umain(int argc, char **argv)
{
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800033:	66 b8 28 00          	mov    $0x28,%ax
  800037:	8e d8                	mov    %eax,%ds
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	53                   	push   %ebx
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	e8 39 00 00 00       	call   80007f <__x86.get_pc_thunk.bx>
  800046:	81 c3 ba 1f 00 00    	add    $0x1fba,%ebx
  80004c:	8b 45 08             	mov    0x8(%ebp),%eax
  80004f:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800052:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  800059:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 c0                	test   %eax,%eax
  80005e:	7e 08                	jle    800068 <libmain+0x2e>
		binaryname = argv[0];
  800060:	8b 0a                	mov    (%edx),%ecx
  800062:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800068:	83 ec 08             	sub    $0x8,%esp
  80006b:	52                   	push   %edx
  80006c:	50                   	push   %eax
  80006d:	e8 c1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800072:	e8 0c 00 00 00       	call   800083 <exit>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    

0080007f <__x86.get_pc_thunk.bx>:
  80007f:	8b 1c 24             	mov    (%esp),%ebx
  800082:	c3                   	ret    

00800083 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	53                   	push   %ebx
  800087:	83 ec 10             	sub    $0x10,%esp
  80008a:	e8 f0 ff ff ff       	call   80007f <__x86.get_pc_thunk.bx>
  80008f:	81 c3 71 1f 00 00    	add    $0x1f71,%ebx
	sys_env_destroy(0);
  800095:	6a 00                	push   $0x0
  800097:	e8 45 00 00 00       	call   8000e1 <sys_env_destroy>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8000af:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	89 c3                	mov    %eax,%ebx
  8000b7:	89 c7                	mov    %eax,%edi
  8000b9:	89 c6                	mov    %eax,%esi
  8000bb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5f                   	pop    %edi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d2:	89 d1                	mov    %edx,%ecx
  8000d4:	89 d3                	mov    %edx,%ebx
  8000d6:	89 d7                	mov    %edx,%edi
  8000d8:	89 d6                	mov    %edx,%esi
  8000da:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 1c             	sub    $0x1c,%esp
  8000ea:	e8 66 00 00 00       	call   800155 <__x86.get_pc_thunk.ax>
  8000ef:	05 11 1f 00 00       	add    $0x1f11,%eax
  8000f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	89 cb                	mov    %ecx,%ebx
  800106:	89 cf                	mov    %ecx,%edi
  800108:	89 ce                	mov    %ecx,%esi
  80010a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010c:	85 c0                	test   %eax,%eax
  80010e:	7f 08                	jg     800118 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800118:	83 ec 0c             	sub    $0xc,%esp
  80011b:	50                   	push   %eax
  80011c:	6a 03                	push   $0x3
  80011e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800121:	8d 83 1e ee ff ff    	lea    -0x11e2(%ebx),%eax
  800127:	50                   	push   %eax
  800128:	6a 23                	push   $0x23
  80012a:	8d 83 3b ee ff ff    	lea    -0x11c5(%ebx),%eax
  800130:	50                   	push   %eax
  800131:	e8 23 00 00 00       	call   800159 <_panic>

00800136 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 02 00 00 00       	mov    $0x2,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <__x86.get_pc_thunk.ax>:
  800155:	8b 04 24             	mov    (%esp),%eax
  800158:	c3                   	ret    

00800159 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	57                   	push   %edi
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	e8 18 ff ff ff       	call   80007f <__x86.get_pc_thunk.bx>
  800167:	81 c3 99 1e 00 00    	add    $0x1e99,%ebx
	va_list ap;

	va_start(ap, fmt);
  80016d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800170:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800176:	8b 38                	mov    (%eax),%edi
  800178:	e8 b9 ff ff ff       	call   800136 <sys_getenvid>
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	ff 75 0c             	push   0xc(%ebp)
  800183:	ff 75 08             	push   0x8(%ebp)
  800186:	57                   	push   %edi
  800187:	50                   	push   %eax
  800188:	8d 83 4c ee ff ff    	lea    -0x11b4(%ebx),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 d1 00 00 00       	call   800265 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800194:	83 c4 18             	add    $0x18,%esp
  800197:	56                   	push   %esi
  800198:	ff 75 10             	push   0x10(%ebp)
  80019b:	e8 63 00 00 00       	call   800203 <vcprintf>
	cprintf("\n");
  8001a0:	8d 83 6f ee ff ff    	lea    -0x1191(%ebx),%eax
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 b7 00 00 00       	call   800265 <cprintf>
  8001ae:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b1:	cc                   	int3   
  8001b2:	eb fd                	jmp    8001b1 <_panic+0x58>

008001b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	e8 c1 fe ff ff       	call   80007f <__x86.get_pc_thunk.bx>
  8001be:	81 c3 42 1e 00 00    	add    $0x1e42,%ebx
  8001c4:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001c7:	8b 16                	mov    (%esi),%edx
  8001c9:	8d 42 01             	lea    0x1(%edx),%eax
  8001cc:	89 06                	mov    %eax,(%esi)
  8001ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d1:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001da:	74 0b                	je     8001e7 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001dc:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e7:	83 ec 08             	sub    $0x8,%esp
  8001ea:	68 ff 00 00 00       	push   $0xff
  8001ef:	8d 46 08             	lea    0x8(%esi),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 ac fe ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  8001f8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	eb d9                	jmp    8001dc <putch+0x28>

00800203 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	53                   	push   %ebx
  800207:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80020d:	e8 6d fe ff ff       	call   80007f <__x86.get_pc_thunk.bx>
  800212:	81 c3 ee 1d 00 00    	add    $0x1dee,%ebx
	struct printbuf b;

	b.idx = 0;
  800218:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021f:	00 00 00 
	b.cnt = 0;
  800222:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800229:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022c:	ff 75 0c             	push   0xc(%ebp)
  80022f:	ff 75 08             	push   0x8(%ebp)
  800232:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800238:	50                   	push   %eax
  800239:	8d 83 b4 e1 ff ff    	lea    -0x1e4c(%ebx),%eax
  80023f:	50                   	push   %eax
  800240:	e8 2c 01 00 00       	call   800371 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800245:	83 c4 08             	add    $0x8,%esp
  800248:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80024e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800254:	50                   	push   %eax
  800255:	e8 4a fe ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  80025a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800260:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800263:	c9                   	leave  
  800264:	c3                   	ret    

00800265 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026e:	50                   	push   %eax
  80026f:	ff 75 08             	push   0x8(%ebp)
  800272:	e8 8c ff ff ff       	call   800203 <vcprintf>
	va_end(ap);

	return cnt;
}
  800277:	c9                   	leave  
  800278:	c3                   	ret    

00800279 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 2c             	sub    $0x2c,%esp
  800282:	e8 cf 05 00 00       	call   800856 <__x86.get_pc_thunk.cx>
  800287:	81 c1 79 1d 00 00    	add    $0x1d79,%ecx
  80028d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800290:	89 c7                	mov    %eax,%edi
  800292:	89 d6                	mov    %edx,%esi
  800294:	8b 45 08             	mov    0x8(%ebp),%eax
  800297:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029a:	89 d1                	mov    %edx,%ecx
  80029c:	89 c2                	mov    %eax,%edx
  80029e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002a1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ad:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b4:	39 c2                	cmp    %eax,%edx
  8002b6:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002b9:	72 41                	jb     8002fc <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	ff 75 18             	push   0x18(%ebp)
  8002c1:	83 eb 01             	sub    $0x1,%ebx
  8002c4:	53                   	push   %ebx
  8002c5:	50                   	push   %eax
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	ff 75 e4             	push   -0x1c(%ebp)
  8002cc:	ff 75 e0             	push   -0x20(%ebp)
  8002cf:	ff 75 d4             	push   -0x2c(%ebp)
  8002d2:	ff 75 d0             	push   -0x30(%ebp)
  8002d5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002d8:	e8 03 09 00 00       	call   800be0 <__udivdi3>
  8002dd:	83 c4 18             	add    $0x18,%esp
  8002e0:	52                   	push   %edx
  8002e1:	50                   	push   %eax
  8002e2:	89 f2                	mov    %esi,%edx
  8002e4:	89 f8                	mov    %edi,%eax
  8002e6:	e8 8e ff ff ff       	call   800279 <printnum>
  8002eb:	83 c4 20             	add    $0x20,%esp
  8002ee:	eb 13                	jmp    800303 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f0:	83 ec 08             	sub    $0x8,%esp
  8002f3:	56                   	push   %esi
  8002f4:	ff 75 18             	push   0x18(%ebp)
  8002f7:	ff d7                	call   *%edi
  8002f9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002fc:	83 eb 01             	sub    $0x1,%ebx
  8002ff:	85 db                	test   %ebx,%ebx
  800301:	7f ed                	jg     8002f0 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	56                   	push   %esi
  800307:	83 ec 04             	sub    $0x4,%esp
  80030a:	ff 75 e4             	push   -0x1c(%ebp)
  80030d:	ff 75 e0             	push   -0x20(%ebp)
  800310:	ff 75 d4             	push   -0x2c(%ebp)
  800313:	ff 75 d0             	push   -0x30(%ebp)
  800316:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800319:	e8 e2 09 00 00       	call   800d00 <__umoddi3>
  80031e:	83 c4 14             	add    $0x14,%esp
  800321:	0f be 84 03 71 ee ff 	movsbl -0x118f(%ebx,%eax,1),%eax
  800328:	ff 
  800329:	50                   	push   %eax
  80032a:	ff d7                	call   *%edi
}
  80032c:	83 c4 10             	add    $0x10,%esp
  80032f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800332:	5b                   	pop    %ebx
  800333:	5e                   	pop    %esi
  800334:	5f                   	pop    %edi
  800335:	5d                   	pop    %ebp
  800336:	c3                   	ret    

00800337 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800341:	8b 10                	mov    (%eax),%edx
  800343:	3b 50 04             	cmp    0x4(%eax),%edx
  800346:	73 0a                	jae    800352 <sprintputch+0x1b>
		*b->buf++ = ch;
  800348:	8d 4a 01             	lea    0x1(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 45 08             	mov    0x8(%ebp),%eax
  800350:	88 02                	mov    %al,(%edx)
}
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <printfmt>:
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80035a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035d:	50                   	push   %eax
  80035e:	ff 75 10             	push   0x10(%ebp)
  800361:	ff 75 0c             	push   0xc(%ebp)
  800364:	ff 75 08             	push   0x8(%ebp)
  800367:	e8 05 00 00 00       	call   800371 <vprintfmt>
}
  80036c:	83 c4 10             	add    $0x10,%esp
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <vprintfmt>:
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	57                   	push   %edi
  800375:	56                   	push   %esi
  800376:	53                   	push   %ebx
  800377:	83 ec 3c             	sub    $0x3c,%esp
  80037a:	e8 d6 fd ff ff       	call   800155 <__x86.get_pc_thunk.ax>
  80037f:	05 81 1c 00 00       	add    $0x1c81,%eax
  800384:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800387:	8b 75 08             	mov    0x8(%ebp),%esi
  80038a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80038d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800390:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  800396:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800399:	eb 0a                	jmp    8003a5 <vprintfmt+0x34>
			putch(ch, putdat);
  80039b:	83 ec 08             	sub    $0x8,%esp
  80039e:	57                   	push   %edi
  80039f:	50                   	push   %eax
  8003a0:	ff d6                	call   *%esi
  8003a2:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a5:	83 c3 01             	add    $0x1,%ebx
  8003a8:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003ac:	83 f8 25             	cmp    $0x25,%eax
  8003af:	74 0c                	je     8003bd <vprintfmt+0x4c>
			if (ch == '\0')
  8003b1:	85 c0                	test   %eax,%eax
  8003b3:	75 e6                	jne    80039b <vprintfmt+0x2a>
}
  8003b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b8:	5b                   	pop    %ebx
  8003b9:	5e                   	pop    %esi
  8003ba:	5f                   	pop    %edi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    
		padc = ' ';
  8003bd:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003c1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003c8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003db:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003de:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8d 43 01             	lea    0x1(%ebx),%eax
  8003e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e7:	0f b6 13             	movzbl (%ebx),%edx
  8003ea:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ed:	3c 55                	cmp    $0x55,%al
  8003ef:	0f 87 c5 03 00 00    	ja     8007ba <.L20>
  8003f5:	0f b6 c0             	movzbl %al,%eax
  8003f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003fb:	89 ce                	mov    %ecx,%esi
  8003fd:	03 b4 81 00 ef ff ff 	add    -0x1100(%ecx,%eax,4),%esi
  800404:	ff e6                	jmp    *%esi

00800406 <.L66>:
  800406:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800409:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  80040d:	eb d2                	jmp    8003e1 <vprintfmt+0x70>

0080040f <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800412:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800416:	eb c9                	jmp    8003e1 <vprintfmt+0x70>

00800418 <.L31>:
  800418:	0f b6 d2             	movzbl %dl,%edx
  80041b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80041e:	b8 00 00 00 00       	mov    $0x0,%eax
  800423:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800426:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800429:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80042d:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800430:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800433:	83 f9 09             	cmp    $0x9,%ecx
  800436:	77 58                	ja     800490 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800438:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80043b:	eb e9                	jmp    800426 <.L31+0xe>

0080043d <.L34>:
			precision = va_arg(ap, int);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8b 00                	mov    (%eax),%eax
  800442:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 40 04             	lea    0x4(%eax),%eax
  80044b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800451:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800455:	79 8a                	jns    8003e1 <vprintfmt+0x70>
				width = precision, precision = -1;
  800457:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80045a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80045d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800464:	e9 78 ff ff ff       	jmp    8003e1 <vprintfmt+0x70>

00800469 <.L33>:
  800469:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80046c:	85 d2                	test   %edx,%edx
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	0f 49 c2             	cmovns %edx,%eax
  800476:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80047c:	e9 60 ff ff ff       	jmp    8003e1 <vprintfmt+0x70>

00800481 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800484:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80048b:	e9 51 ff ff ff       	jmp    8003e1 <vprintfmt+0x70>
  800490:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800493:	89 75 08             	mov    %esi,0x8(%ebp)
  800496:	eb b9                	jmp    800451 <.L34+0x14>

00800498 <.L27>:
			lflag++;
  800498:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80049f:	e9 3d ff ff ff       	jmp    8003e1 <vprintfmt+0x70>

008004a4 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8d 58 04             	lea    0x4(%eax),%ebx
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	57                   	push   %edi
  8004b1:	ff 30                	push   (%eax)
  8004b3:	ff d6                	call   *%esi
			break;
  8004b5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004b8:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004bb:	e9 90 02 00 00       	jmp    800750 <.L25+0x45>

008004c0 <.L28>:
			err = va_arg(ap, int);
  8004c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 58 04             	lea    0x4(%eax),%ebx
  8004c9:	8b 10                	mov    (%eax),%edx
  8004cb:	89 d0                	mov    %edx,%eax
  8004cd:	f7 d8                	neg    %eax
  8004cf:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d2:	83 f8 06             	cmp    $0x6,%eax
  8004d5:	7f 27                	jg     8004fe <.L28+0x3e>
  8004d7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004da:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004dd:	85 d2                	test   %edx,%edx
  8004df:	74 1d                	je     8004fe <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004e1:	52                   	push   %edx
  8004e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e5:	8d 80 92 ee ff ff    	lea    -0x116e(%eax),%eax
  8004eb:	50                   	push   %eax
  8004ec:	57                   	push   %edi
  8004ed:	56                   	push   %esi
  8004ee:	e8 61 fe ff ff       	call   800354 <printfmt>
  8004f3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f6:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004f9:	e9 52 02 00 00       	jmp    800750 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004fe:	50                   	push   %eax
  8004ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800502:	8d 80 89 ee ff ff    	lea    -0x1177(%eax),%eax
  800508:	50                   	push   %eax
  800509:	57                   	push   %edi
  80050a:	56                   	push   %esi
  80050b:	e8 44 fe ff ff       	call   800354 <printfmt>
  800510:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800513:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800516:	e9 35 02 00 00       	jmp    800750 <.L25+0x45>

0080051b <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  80051b:	8b 75 08             	mov    0x8(%ebp),%esi
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	83 c0 04             	add    $0x4,%eax
  800524:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80052c:	85 d2                	test   %edx,%edx
  80052e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800531:	8d 80 82 ee ff ff    	lea    -0x117e(%eax),%eax
  800537:	0f 45 c2             	cmovne %edx,%eax
  80053a:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80053d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800541:	7e 06                	jle    800549 <.L24+0x2e>
  800543:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800547:	75 0d                	jne    800556 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800549:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80054c:	89 c3                	mov    %eax,%ebx
  80054e:	03 45 d0             	add    -0x30(%ebp),%eax
  800551:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800554:	eb 58                	jmp    8005ae <.L24+0x93>
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	ff 75 d8             	push   -0x28(%ebp)
  80055c:	ff 75 c8             	push   -0x38(%ebp)
  80055f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800562:	e8 0b 03 00 00       	call   800872 <strnlen>
  800567:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80056a:	29 c2                	sub    %eax,%edx
  80056c:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800574:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800578:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80057b:	eb 0f                	jmp    80058c <.L24+0x71>
					putch(padc, putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	57                   	push   %edi
  800581:	ff 75 d0             	push   -0x30(%ebp)
  800584:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800586:	83 eb 01             	sub    $0x1,%ebx
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f ed                	jg     80057d <.L24+0x62>
  800590:	8b 55 bc             	mov    -0x44(%ebp),%edx
  800593:	85 d2                	test   %edx,%edx
  800595:	b8 00 00 00 00       	mov    $0x0,%eax
  80059a:	0f 49 c2             	cmovns %edx,%eax
  80059d:	29 c2                	sub    %eax,%edx
  80059f:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005a2:	eb a5                	jmp    800549 <.L24+0x2e>
					putch(ch, putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	57                   	push   %edi
  8005a8:	52                   	push   %edx
  8005a9:	ff d6                	call   *%esi
  8005ab:	83 c4 10             	add    $0x10,%esp
  8005ae:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005b1:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b3:	83 c3 01             	add    $0x1,%ebx
  8005b6:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005ba:	0f be d0             	movsbl %al,%edx
  8005bd:	85 d2                	test   %edx,%edx
  8005bf:	74 4b                	je     80060c <.L24+0xf1>
  8005c1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c5:	78 06                	js     8005cd <.L24+0xb2>
  8005c7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005cb:	78 1e                	js     8005eb <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005cd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005d1:	74 d1                	je     8005a4 <.L24+0x89>
  8005d3:	0f be c0             	movsbl %al,%eax
  8005d6:	83 e8 20             	sub    $0x20,%eax
  8005d9:	83 f8 5e             	cmp    $0x5e,%eax
  8005dc:	76 c6                	jbe    8005a4 <.L24+0x89>
					putch('?', putdat);
  8005de:	83 ec 08             	sub    $0x8,%esp
  8005e1:	57                   	push   %edi
  8005e2:	6a 3f                	push   $0x3f
  8005e4:	ff d6                	call   *%esi
  8005e6:	83 c4 10             	add    $0x10,%esp
  8005e9:	eb c3                	jmp    8005ae <.L24+0x93>
  8005eb:	89 cb                	mov    %ecx,%ebx
  8005ed:	eb 0e                	jmp    8005fd <.L24+0xe2>
				putch(' ', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	57                   	push   %edi
  8005f3:	6a 20                	push   $0x20
  8005f5:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005f7:	83 eb 01             	sub    $0x1,%ebx
  8005fa:	83 c4 10             	add    $0x10,%esp
  8005fd:	85 db                	test   %ebx,%ebx
  8005ff:	7f ee                	jg     8005ef <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800601:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
  800607:	e9 44 01 00 00       	jmp    800750 <.L25+0x45>
  80060c:	89 cb                	mov    %ecx,%ebx
  80060e:	eb ed                	jmp    8005fd <.L24+0xe2>

00800610 <.L29>:
	if (lflag >= 2)
  800610:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800613:	8b 75 08             	mov    0x8(%ebp),%esi
  800616:	83 f9 01             	cmp    $0x1,%ecx
  800619:	7f 1b                	jg     800636 <.L29+0x26>
	else if (lflag)
  80061b:	85 c9                	test   %ecx,%ecx
  80061d:	74 63                	je     800682 <.L29+0x72>
		return va_arg(*ap, long);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8b 00                	mov    (%eax),%eax
  800624:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800627:	99                   	cltd   
  800628:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 40 04             	lea    0x4(%eax),%eax
  800631:	89 45 14             	mov    %eax,0x14(%ebp)
  800634:	eb 17                	jmp    80064d <.L29+0x3d>
		return va_arg(*ap, long long);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 50 04             	mov    0x4(%eax),%edx
  80063c:	8b 00                	mov    (%eax),%eax
  80063e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800641:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 40 08             	lea    0x8(%eax),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80064d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800650:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800653:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800658:	85 db                	test   %ebx,%ebx
  80065a:	0f 89 d6 00 00 00    	jns    800736 <.L25+0x2b>
				putch('-', putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	57                   	push   %edi
  800664:	6a 2d                	push   $0x2d
  800666:	ff d6                	call   *%esi
				num = -(long long) num;
  800668:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80066b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80066e:	f7 d9                	neg    %ecx
  800670:	83 d3 00             	adc    $0x0,%ebx
  800673:	f7 db                	neg    %ebx
  800675:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800678:	ba 0a 00 00 00       	mov    $0xa,%edx
  80067d:	e9 b4 00 00 00       	jmp    800736 <.L25+0x2b>
		return va_arg(*ap, int);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 00                	mov    (%eax),%eax
  800687:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068a:	99                   	cltd   
  80068b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8d 40 04             	lea    0x4(%eax),%eax
  800694:	89 45 14             	mov    %eax,0x14(%ebp)
  800697:	eb b4                	jmp    80064d <.L29+0x3d>

00800699 <.L23>:
	if (lflag >= 2)
  800699:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80069c:	8b 75 08             	mov    0x8(%ebp),%esi
  80069f:	83 f9 01             	cmp    $0x1,%ecx
  8006a2:	7f 1b                	jg     8006bf <.L23+0x26>
	else if (lflag)
  8006a4:	85 c9                	test   %ecx,%ecx
  8006a6:	74 2c                	je     8006d4 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 08                	mov    (%eax),%ecx
  8006ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b8:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006bd:	eb 77                	jmp    800736 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8b 08                	mov    (%eax),%ecx
  8006c4:	8b 58 04             	mov    0x4(%eax),%ebx
  8006c7:	8d 40 08             	lea    0x8(%eax),%eax
  8006ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cd:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006d2:	eb 62                	jmp    800736 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8b 08                	mov    (%eax),%ecx
  8006d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006de:	8d 40 04             	lea    0x4(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e4:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006e9:	eb 4b                	jmp    800736 <.L25+0x2b>

008006eb <.L26>:
			putch('X', putdat);
  8006eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	57                   	push   %edi
  8006f2:	6a 58                	push   $0x58
  8006f4:	ff d6                	call   *%esi
			putch('X', putdat);
  8006f6:	83 c4 08             	add    $0x8,%esp
  8006f9:	57                   	push   %edi
  8006fa:	6a 58                	push   $0x58
  8006fc:	ff d6                	call   *%esi
			putch('X', putdat);
  8006fe:	83 c4 08             	add    $0x8,%esp
  800701:	57                   	push   %edi
  800702:	6a 58                	push   $0x58
  800704:	ff d6                	call   *%esi
			break;
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	eb 45                	jmp    800750 <.L25+0x45>

0080070b <.L25>:
			putch('0', putdat);
  80070b:	8b 75 08             	mov    0x8(%ebp),%esi
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	57                   	push   %edi
  800712:	6a 30                	push   $0x30
  800714:	ff d6                	call   *%esi
			putch('x', putdat);
  800716:	83 c4 08             	add    $0x8,%esp
  800719:	57                   	push   %edi
  80071a:	6a 78                	push   $0x78
  80071c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80071e:	8b 45 14             	mov    0x14(%ebp),%eax
  800721:	8b 08                	mov    (%eax),%ecx
  800723:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800728:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80072b:	8d 40 04             	lea    0x4(%eax),%eax
  80072e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800731:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800736:	83 ec 0c             	sub    $0xc,%esp
  800739:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80073d:	50                   	push   %eax
  80073e:	ff 75 d0             	push   -0x30(%ebp)
  800741:	52                   	push   %edx
  800742:	53                   	push   %ebx
  800743:	51                   	push   %ecx
  800744:	89 fa                	mov    %edi,%edx
  800746:	89 f0                	mov    %esi,%eax
  800748:	e8 2c fb ff ff       	call   800279 <printnum>
			break;
  80074d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800750:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800753:	e9 4d fc ff ff       	jmp    8003a5 <vprintfmt+0x34>

00800758 <.L21>:
	if (lflag >= 2)
  800758:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80075b:	8b 75 08             	mov    0x8(%ebp),%esi
  80075e:	83 f9 01             	cmp    $0x1,%ecx
  800761:	7f 1b                	jg     80077e <.L21+0x26>
	else if (lflag)
  800763:	85 c9                	test   %ecx,%ecx
  800765:	74 2c                	je     800793 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8b 08                	mov    (%eax),%ecx
  80076c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800771:	8d 40 04             	lea    0x4(%eax),%eax
  800774:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800777:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  80077c:	eb b8                	jmp    800736 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  80077e:	8b 45 14             	mov    0x14(%ebp),%eax
  800781:	8b 08                	mov    (%eax),%ecx
  800783:	8b 58 04             	mov    0x4(%eax),%ebx
  800786:	8d 40 08             	lea    0x8(%eax),%eax
  800789:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80078c:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  800791:	eb a3                	jmp    800736 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8b 08                	mov    (%eax),%ecx
  800798:	bb 00 00 00 00       	mov    $0x0,%ebx
  80079d:	8d 40 04             	lea    0x4(%eax),%eax
  8007a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a3:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007a8:	eb 8c                	jmp    800736 <.L25+0x2b>

008007aa <.L35>:
			putch(ch, putdat);
  8007aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	57                   	push   %edi
  8007b1:	6a 25                	push   $0x25
  8007b3:	ff d6                	call   *%esi
			break;
  8007b5:	83 c4 10             	add    $0x10,%esp
  8007b8:	eb 96                	jmp    800750 <.L25+0x45>

008007ba <.L20>:
			putch('%', putdat);
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	83 ec 08             	sub    $0x8,%esp
  8007c0:	57                   	push   %edi
  8007c1:	6a 25                	push   $0x25
  8007c3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c5:	83 c4 10             	add    $0x10,%esp
  8007c8:	89 d8                	mov    %ebx,%eax
  8007ca:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007ce:	74 05                	je     8007d5 <.L20+0x1b>
  8007d0:	83 e8 01             	sub    $0x1,%eax
  8007d3:	eb f5                	jmp    8007ca <.L20+0x10>
  8007d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d8:	e9 73 ff ff ff       	jmp    800750 <.L25+0x45>

008007dd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 14             	sub    $0x14,%esp
  8007e4:	e8 96 f8 ff ff       	call   80007f <__x86.get_pc_thunk.bx>
  8007e9:	81 c3 17 18 00 00    	add    $0x1817,%ebx
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800806:	85 c0                	test   %eax,%eax
  800808:	74 2b                	je     800835 <vsnprintf+0x58>
  80080a:	85 d2                	test   %edx,%edx
  80080c:	7e 27                	jle    800835 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080e:	ff 75 14             	push   0x14(%ebp)
  800811:	ff 75 10             	push   0x10(%ebp)
  800814:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800817:	50                   	push   %eax
  800818:	8d 83 37 e3 ff ff    	lea    -0x1cc9(%ebx),%eax
  80081e:	50                   	push   %eax
  80081f:	e8 4d fb ff ff       	call   800371 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800824:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800827:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082d:	83 c4 10             	add    $0x10,%esp
}
  800830:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800833:	c9                   	leave  
  800834:	c3                   	ret    
		return -E_INVAL;
  800835:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083a:	eb f4                	jmp    800830 <vsnprintf+0x53>

0080083c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800842:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800845:	50                   	push   %eax
  800846:	ff 75 10             	push   0x10(%ebp)
  800849:	ff 75 0c             	push   0xc(%ebp)
  80084c:	ff 75 08             	push   0x8(%ebp)
  80084f:	e8 89 ff ff ff       	call   8007dd <vsnprintf>
	va_end(ap);

	return rc;
}
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <__x86.get_pc_thunk.cx>:
  800856:	8b 0c 24             	mov    (%esp),%ecx
  800859:	c3                   	ret    

0080085a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800860:	b8 00 00 00 00       	mov    $0x0,%eax
  800865:	eb 03                	jmp    80086a <strlen+0x10>
		n++;
  800867:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80086a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086e:	75 f7                	jne    800867 <strlen+0xd>
	return n;
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800878:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
  800880:	eb 03                	jmp    800885 <strnlen+0x13>
		n++;
  800882:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800885:	39 d0                	cmp    %edx,%eax
  800887:	74 08                	je     800891 <strnlen+0x1f>
  800889:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80088d:	75 f3                	jne    800882 <strnlen+0x10>
  80088f:	89 c2                	mov    %eax,%edx
	return n;
}
  800891:	89 d0                	mov    %edx,%eax
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	53                   	push   %ebx
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008a8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	84 d2                	test   %dl,%dl
  8008b0:	75 f2                	jne    8008a4 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b2:	89 c8                	mov    %ecx,%eax
  8008b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	83 ec 10             	sub    $0x10,%esp
  8008c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c3:	53                   	push   %ebx
  8008c4:	e8 91 ff ff ff       	call   80085a <strlen>
  8008c9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008cc:	ff 75 0c             	push   0xc(%ebp)
  8008cf:	01 d8                	add    %ebx,%eax
  8008d1:	50                   	push   %eax
  8008d2:	e8 be ff ff ff       	call   800895 <strcpy>
	return dst;
}
  8008d7:	89 d8                	mov    %ebx,%eax
  8008d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008dc:	c9                   	leave  
  8008dd:	c3                   	ret    

008008de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	56                   	push   %esi
  8008e2:	53                   	push   %ebx
  8008e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e9:	89 f3                	mov    %esi,%ebx
  8008eb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ee:	89 f0                	mov    %esi,%eax
  8008f0:	eb 0f                	jmp    800901 <strncpy+0x23>
		*dst++ = *src;
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	0f b6 0a             	movzbl (%edx),%ecx
  8008f8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008fb:	80 f9 01             	cmp    $0x1,%cl
  8008fe:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800901:	39 d8                	cmp    %ebx,%eax
  800903:	75 ed                	jne    8008f2 <strncpy+0x14>
	}
	return ret;
}
  800905:	89 f0                	mov    %esi,%eax
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	56                   	push   %esi
  80090f:	53                   	push   %ebx
  800910:	8b 75 08             	mov    0x8(%ebp),%esi
  800913:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800916:	8b 55 10             	mov    0x10(%ebp),%edx
  800919:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80091b:	85 d2                	test   %edx,%edx
  80091d:	74 21                	je     800940 <strlcpy+0x35>
  80091f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800923:	89 f2                	mov    %esi,%edx
  800925:	eb 09                	jmp    800930 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800927:	83 c1 01             	add    $0x1,%ecx
  80092a:	83 c2 01             	add    $0x1,%edx
  80092d:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800930:	39 c2                	cmp    %eax,%edx
  800932:	74 09                	je     80093d <strlcpy+0x32>
  800934:	0f b6 19             	movzbl (%ecx),%ebx
  800937:	84 db                	test   %bl,%bl
  800939:	75 ec                	jne    800927 <strlcpy+0x1c>
  80093b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80093d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800940:	29 f0                	sub    %esi,%eax
}
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094f:	eb 06                	jmp    800957 <strcmp+0x11>
		p++, q++;
  800951:	83 c1 01             	add    $0x1,%ecx
  800954:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800957:	0f b6 01             	movzbl (%ecx),%eax
  80095a:	84 c0                	test   %al,%al
  80095c:	74 04                	je     800962 <strcmp+0x1c>
  80095e:	3a 02                	cmp    (%edx),%al
  800960:	74 ef                	je     800951 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800962:	0f b6 c0             	movzbl %al,%eax
  800965:	0f b6 12             	movzbl (%edx),%edx
  800968:	29 d0                	sub    %edx,%eax
}
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	53                   	push   %ebx
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 55 0c             	mov    0xc(%ebp),%edx
  800976:	89 c3                	mov    %eax,%ebx
  800978:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80097b:	eb 06                	jmp    800983 <strncmp+0x17>
		n--, p++, q++;
  80097d:	83 c0 01             	add    $0x1,%eax
  800980:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800983:	39 d8                	cmp    %ebx,%eax
  800985:	74 18                	je     80099f <strncmp+0x33>
  800987:	0f b6 08             	movzbl (%eax),%ecx
  80098a:	84 c9                	test   %cl,%cl
  80098c:	74 04                	je     800992 <strncmp+0x26>
  80098e:	3a 0a                	cmp    (%edx),%cl
  800990:	74 eb                	je     80097d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800992:	0f b6 00             	movzbl (%eax),%eax
  800995:	0f b6 12             	movzbl (%edx),%edx
  800998:	29 d0                	sub    %edx,%eax
}
  80099a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    
		return 0;
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a4:	eb f4                	jmp    80099a <strncmp+0x2e>

008009a6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b0:	eb 03                	jmp    8009b5 <strchr+0xf>
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	74 06                	je     8009c2 <strchr+0x1c>
		if (*s == c)
  8009bc:	38 ca                	cmp    %cl,%dl
  8009be:	75 f2                	jne    8009b2 <strchr+0xc>
  8009c0:	eb 05                	jmp    8009c7 <strchr+0x21>
			return (char *) s;
	return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d6:	38 ca                	cmp    %cl,%dl
  8009d8:	74 09                	je     8009e3 <strfind+0x1a>
  8009da:	84 d2                	test   %dl,%dl
  8009dc:	74 05                	je     8009e3 <strfind+0x1a>
	for (; *s; s++)
  8009de:	83 c0 01             	add    $0x1,%eax
  8009e1:	eb f0                	jmp    8009d3 <strfind+0xa>
			break;
	return (char *) s;
}
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	57                   	push   %edi
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f1:	85 c9                	test   %ecx,%ecx
  8009f3:	74 2f                	je     800a24 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f5:	89 f8                	mov    %edi,%eax
  8009f7:	09 c8                	or     %ecx,%eax
  8009f9:	a8 03                	test   $0x3,%al
  8009fb:	75 21                	jne    800a1e <memset+0x39>
		c &= 0xFF;
  8009fd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a01:	89 d0                	mov    %edx,%eax
  800a03:	c1 e0 08             	shl    $0x8,%eax
  800a06:	89 d3                	mov    %edx,%ebx
  800a08:	c1 e3 18             	shl    $0x18,%ebx
  800a0b:	89 d6                	mov    %edx,%esi
  800a0d:	c1 e6 10             	shl    $0x10,%esi
  800a10:	09 f3                	or     %esi,%ebx
  800a12:	09 da                	or     %ebx,%edx
  800a14:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a16:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a19:	fc                   	cld    
  800a1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1c:	eb 06                	jmp    800a24 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a21:	fc                   	cld    
  800a22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a24:	89 f8                	mov    %edi,%eax
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
  800a2f:	56                   	push   %esi
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a39:	39 c6                	cmp    %eax,%esi
  800a3b:	73 32                	jae    800a6f <memmove+0x44>
  800a3d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a40:	39 c2                	cmp    %eax,%edx
  800a42:	76 2b                	jbe    800a6f <memmove+0x44>
		s += n;
		d += n;
  800a44:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a47:	89 d6                	mov    %edx,%esi
  800a49:	09 fe                	or     %edi,%esi
  800a4b:	09 ce                	or     %ecx,%esi
  800a4d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a53:	75 0e                	jne    800a63 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a55:	83 ef 04             	sub    $0x4,%edi
  800a58:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a5e:	fd                   	std    
  800a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a61:	eb 09                	jmp    800a6c <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a63:	83 ef 01             	sub    $0x1,%edi
  800a66:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a69:	fd                   	std    
  800a6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6c:	fc                   	cld    
  800a6d:	eb 1a                	jmp    800a89 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6f:	89 f2                	mov    %esi,%edx
  800a71:	09 c2                	or     %eax,%edx
  800a73:	09 ca                	or     %ecx,%edx
  800a75:	f6 c2 03             	test   $0x3,%dl
  800a78:	75 0a                	jne    800a84 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a7a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a7d:	89 c7                	mov    %eax,%edi
  800a7f:	fc                   	cld    
  800a80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a82:	eb 05                	jmp    800a89 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a84:	89 c7                	mov    %eax,%edi
  800a86:	fc                   	cld    
  800a87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a89:	5e                   	pop    %esi
  800a8a:	5f                   	pop    %edi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a93:	ff 75 10             	push   0x10(%ebp)
  800a96:	ff 75 0c             	push   0xc(%ebp)
  800a99:	ff 75 08             	push   0x8(%ebp)
  800a9c:	e8 8a ff ff ff       	call   800a2b <memmove>
}
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aae:	89 c6                	mov    %eax,%esi
  800ab0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab3:	eb 06                	jmp    800abb <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab5:	83 c0 01             	add    $0x1,%eax
  800ab8:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800abb:	39 f0                	cmp    %esi,%eax
  800abd:	74 14                	je     800ad3 <memcmp+0x30>
		if (*s1 != *s2)
  800abf:	0f b6 08             	movzbl (%eax),%ecx
  800ac2:	0f b6 1a             	movzbl (%edx),%ebx
  800ac5:	38 d9                	cmp    %bl,%cl
  800ac7:	74 ec                	je     800ab5 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800ac9:	0f b6 c1             	movzbl %cl,%eax
  800acc:	0f b6 db             	movzbl %bl,%ebx
  800acf:	29 d8                	sub    %ebx,%eax
  800ad1:	eb 05                	jmp    800ad8 <memcmp+0x35>
	}

	return 0;
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae5:	89 c2                	mov    %eax,%edx
  800ae7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aea:	eb 03                	jmp    800aef <memfind+0x13>
  800aec:	83 c0 01             	add    $0x1,%eax
  800aef:	39 d0                	cmp    %edx,%eax
  800af1:	73 04                	jae    800af7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af3:	38 08                	cmp    %cl,(%eax)
  800af5:	75 f5                	jne    800aec <memfind+0x10>
			break;
	return (void *) s;
}
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	8b 55 08             	mov    0x8(%ebp),%edx
  800b02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b05:	eb 03                	jmp    800b0a <strtol+0x11>
		s++;
  800b07:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b0a:	0f b6 02             	movzbl (%edx),%eax
  800b0d:	3c 20                	cmp    $0x20,%al
  800b0f:	74 f6                	je     800b07 <strtol+0xe>
  800b11:	3c 09                	cmp    $0x9,%al
  800b13:	74 f2                	je     800b07 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b15:	3c 2b                	cmp    $0x2b,%al
  800b17:	74 2a                	je     800b43 <strtol+0x4a>
	int neg = 0;
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b1e:	3c 2d                	cmp    $0x2d,%al
  800b20:	74 2b                	je     800b4d <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b22:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b28:	75 0f                	jne    800b39 <strtol+0x40>
  800b2a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2d:	74 28                	je     800b57 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2f:	85 db                	test   %ebx,%ebx
  800b31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b36:	0f 44 d8             	cmove  %eax,%ebx
  800b39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b41:	eb 46                	jmp    800b89 <strtol+0x90>
		s++;
  800b43:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b46:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4b:	eb d5                	jmp    800b22 <strtol+0x29>
		s++, neg = 1;
  800b4d:	83 c2 01             	add    $0x1,%edx
  800b50:	bf 01 00 00 00       	mov    $0x1,%edi
  800b55:	eb cb                	jmp    800b22 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b57:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b5b:	74 0e                	je     800b6b <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b5d:	85 db                	test   %ebx,%ebx
  800b5f:	75 d8                	jne    800b39 <strtol+0x40>
		s++, base = 8;
  800b61:	83 c2 01             	add    $0x1,%edx
  800b64:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b69:	eb ce                	jmp    800b39 <strtol+0x40>
		s += 2, base = 16;
  800b6b:	83 c2 02             	add    $0x2,%edx
  800b6e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b73:	eb c4                	jmp    800b39 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b75:	0f be c0             	movsbl %al,%eax
  800b78:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7b:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b7e:	7d 3a                	jge    800bba <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b80:	83 c2 01             	add    $0x1,%edx
  800b83:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b87:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b89:	0f b6 02             	movzbl (%edx),%eax
  800b8c:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	80 fb 09             	cmp    $0x9,%bl
  800b94:	76 df                	jbe    800b75 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b96:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b99:	89 f3                	mov    %esi,%ebx
  800b9b:	80 fb 19             	cmp    $0x19,%bl
  800b9e:	77 08                	ja     800ba8 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ba0:	0f be c0             	movsbl %al,%eax
  800ba3:	83 e8 57             	sub    $0x57,%eax
  800ba6:	eb d3                	jmp    800b7b <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ba8:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bab:	89 f3                	mov    %esi,%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 08                	ja     800bba <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bb2:	0f be c0             	movsbl %al,%eax
  800bb5:	83 e8 37             	sub    $0x37,%eax
  800bb8:	eb c1                	jmp    800b7b <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbe:	74 05                	je     800bc5 <strtol+0xcc>
		*endptr = (char *) s;
  800bc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc3:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bc5:	89 c8                	mov    %ecx,%eax
  800bc7:	f7 d8                	neg    %eax
  800bc9:	85 ff                	test   %edi,%edi
  800bcb:	0f 45 c8             	cmovne %eax,%ecx
}
  800bce:	89 c8                	mov    %ecx,%eax
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    
  800bd5:	66 90                	xchg   %ax,%ax
  800bd7:	66 90                	xchg   %ax,%ax
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
