
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 05 00 00 00       	call   800036 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $14");	// page fault
  800033:	cd 0e                	int    $0xe
}
  800035:	c3                   	ret    

00800036 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800036:	55                   	push   %ebp
  800037:	89 e5                	mov    %esp,%ebp
  800039:	53                   	push   %ebx
  80003a:	83 ec 04             	sub    $0x4,%esp
  80003d:	e8 39 00 00 00       	call   80007b <__x86.get_pc_thunk.bx>
  800042:	81 c3 be 1f 00 00    	add    $0x1fbe,%ebx
  800048:	8b 45 08             	mov    0x8(%ebp),%eax
  80004b:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004e:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  800055:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800058:	85 c0                	test   %eax,%eax
  80005a:	7e 08                	jle    800064 <libmain+0x2e>
		binaryname = argv[0];
  80005c:	8b 0a                	mov    (%edx),%ecx
  80005e:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800064:	83 ec 08             	sub    $0x8,%esp
  800067:	52                   	push   %edx
  800068:	50                   	push   %eax
  800069:	e8 c5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006e:	e8 0c 00 00 00       	call   80007f <exit>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <__x86.get_pc_thunk.bx>:
  80007b:	8b 1c 24             	mov    (%esp),%ebx
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	53                   	push   %ebx
  800083:	83 ec 10             	sub    $0x10,%esp
  800086:	e8 f0 ff ff ff       	call   80007b <__x86.get_pc_thunk.bx>
  80008b:	81 c3 75 1f 00 00    	add    $0x1f75,%ebx
	sys_env_destroy(0);
  800091:	6a 00                	push   $0x0
  800093:	e8 45 00 00 00       	call   8000dd <sys_env_destroy>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	89 c3                	mov    %eax,%ebx
  8000b3:	89 c7                	mov    %eax,%edi
  8000b5:	89 c6                	mov    %eax,%esi
  8000b7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_cgetc>:

int
sys_cgetc(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ce:	89 d1                	mov    %edx,%ecx
  8000d0:	89 d3                	mov    %edx,%ebx
  8000d2:	89 d7                	mov    %edx,%edi
  8000d4:	89 d6                	mov    %edx,%esi
  8000d6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	57                   	push   %edi
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	83 ec 1c             	sub    $0x1c,%esp
  8000e6:	e8 66 00 00 00       	call   800151 <__x86.get_pc_thunk.ax>
  8000eb:	05 15 1f 00 00       	add    $0x1f15,%eax
  8000f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	b8 03 00 00 00       	mov    $0x3,%eax
  800100:	89 cb                	mov    %ecx,%ebx
  800102:	89 cf                	mov    %ecx,%edi
  800104:	89 ce                	mov    %ecx,%esi
  800106:	cd 30                	int    $0x30
	if(check && ret > 0)
  800108:	85 c0                	test   %eax,%eax
  80010a:	7f 08                	jg     800114 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	50                   	push   %eax
  800118:	6a 03                	push   $0x3
  80011a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80011d:	8d 83 1e ee ff ff    	lea    -0x11e2(%ebx),%eax
  800123:	50                   	push   %eax
  800124:	6a 23                	push   $0x23
  800126:	8d 83 3b ee ff ff    	lea    -0x11c5(%ebx),%eax
  80012c:	50                   	push   %eax
  80012d:	e8 23 00 00 00       	call   800155 <_panic>

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <__x86.get_pc_thunk.ax>:
  800151:	8b 04 24             	mov    (%esp),%eax
  800154:	c3                   	ret    

00800155 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	e8 18 ff ff ff       	call   80007b <__x86.get_pc_thunk.bx>
  800163:	81 c3 9d 1e 00 00    	add    $0x1e9d,%ebx
	va_list ap;

	va_start(ap, fmt);
  800169:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016c:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800172:	8b 38                	mov    (%eax),%edi
  800174:	e8 b9 ff ff ff       	call   800132 <sys_getenvid>
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	ff 75 0c             	push   0xc(%ebp)
  80017f:	ff 75 08             	push   0x8(%ebp)
  800182:	57                   	push   %edi
  800183:	50                   	push   %eax
  800184:	8d 83 4c ee ff ff    	lea    -0x11b4(%ebx),%eax
  80018a:	50                   	push   %eax
  80018b:	e8 d1 00 00 00       	call   800261 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800190:	83 c4 18             	add    $0x18,%esp
  800193:	56                   	push   %esi
  800194:	ff 75 10             	push   0x10(%ebp)
  800197:	e8 63 00 00 00       	call   8001ff <vcprintf>
	cprintf("\n");
  80019c:	8d 83 6f ee ff ff    	lea    -0x1191(%ebx),%eax
  8001a2:	89 04 24             	mov    %eax,(%esp)
  8001a5:	e8 b7 00 00 00       	call   800261 <cprintf>
  8001aa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ad:	cc                   	int3   
  8001ae:	eb fd                	jmp    8001ad <_panic+0x58>

008001b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	56                   	push   %esi
  8001b4:	53                   	push   %ebx
  8001b5:	e8 c1 fe ff ff       	call   80007b <__x86.get_pc_thunk.bx>
  8001ba:	81 c3 46 1e 00 00    	add    $0x1e46,%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001c3:	8b 16                	mov    (%esi),%edx
  8001c5:	8d 42 01             	lea    0x1(%edx),%eax
  8001c8:	89 06                	mov    %eax,(%esi)
  8001ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cd:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d6:	74 0b                	je     8001e3 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001d8:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5e                   	pop    %esi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	68 ff 00 00 00       	push   $0xff
  8001eb:	8d 46 08             	lea    0x8(%esi),%eax
  8001ee:	50                   	push   %eax
  8001ef:	e8 ac fe ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  8001f4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	eb d9                	jmp    8001d8 <putch+0x28>

008001ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	53                   	push   %ebx
  800203:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800209:	e8 6d fe ff ff       	call   80007b <__x86.get_pc_thunk.bx>
  80020e:	81 c3 f2 1d 00 00    	add    $0x1df2,%ebx
	struct printbuf b;

	b.idx = 0;
  800214:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021b:	00 00 00 
	b.cnt = 0;
  80021e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800225:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800228:	ff 75 0c             	push   0xc(%ebp)
  80022b:	ff 75 08             	push   0x8(%ebp)
  80022e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800234:	50                   	push   %eax
  800235:	8d 83 b0 e1 ff ff    	lea    -0x1e50(%ebx),%eax
  80023b:	50                   	push   %eax
  80023c:	e8 2c 01 00 00       	call   80036d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800241:	83 c4 08             	add    $0x8,%esp
  800244:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80024a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800250:	50                   	push   %eax
  800251:	e8 4a fe ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  800256:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025f:	c9                   	leave  
  800260:	c3                   	ret    

00800261 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800267:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026a:	50                   	push   %eax
  80026b:	ff 75 08             	push   0x8(%ebp)
  80026e:	e8 8c ff ff ff       	call   8001ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800273:	c9                   	leave  
  800274:	c3                   	ret    

00800275 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	57                   	push   %edi
  800279:	56                   	push   %esi
  80027a:	53                   	push   %ebx
  80027b:	83 ec 2c             	sub    $0x2c,%esp
  80027e:	e8 cf 05 00 00       	call   800852 <__x86.get_pc_thunk.cx>
  800283:	81 c1 7d 1d 00 00    	add    $0x1d7d,%ecx
  800289:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80028c:	89 c7                	mov    %eax,%edi
  80028e:	89 d6                	mov    %edx,%esi
  800290:	8b 45 08             	mov    0x8(%ebp),%eax
  800293:	8b 55 0c             	mov    0xc(%ebp),%edx
  800296:	89 d1                	mov    %edx,%ecx
  800298:	89 c2                	mov    %eax,%edx
  80029a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80029d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b0:	39 c2                	cmp    %eax,%edx
  8002b2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002b5:	72 41                	jb     8002f8 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b7:	83 ec 0c             	sub    $0xc,%esp
  8002ba:	ff 75 18             	push   0x18(%ebp)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	53                   	push   %ebx
  8002c1:	50                   	push   %eax
  8002c2:	83 ec 08             	sub    $0x8,%esp
  8002c5:	ff 75 e4             	push   -0x1c(%ebp)
  8002c8:	ff 75 e0             	push   -0x20(%ebp)
  8002cb:	ff 75 d4             	push   -0x2c(%ebp)
  8002ce:	ff 75 d0             	push   -0x30(%ebp)
  8002d1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002d4:	e8 07 09 00 00       	call   800be0 <__udivdi3>
  8002d9:	83 c4 18             	add    $0x18,%esp
  8002dc:	52                   	push   %edx
  8002dd:	50                   	push   %eax
  8002de:	89 f2                	mov    %esi,%edx
  8002e0:	89 f8                	mov    %edi,%eax
  8002e2:	e8 8e ff ff ff       	call   800275 <printnum>
  8002e7:	83 c4 20             	add    $0x20,%esp
  8002ea:	eb 13                	jmp    8002ff <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ec:	83 ec 08             	sub    $0x8,%esp
  8002ef:	56                   	push   %esi
  8002f0:	ff 75 18             	push   0x18(%ebp)
  8002f3:	ff d7                	call   *%edi
  8002f5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	85 db                	test   %ebx,%ebx
  8002fd:	7f ed                	jg     8002ec <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	83 ec 04             	sub    $0x4,%esp
  800306:	ff 75 e4             	push   -0x1c(%ebp)
  800309:	ff 75 e0             	push   -0x20(%ebp)
  80030c:	ff 75 d4             	push   -0x2c(%ebp)
  80030f:	ff 75 d0             	push   -0x30(%ebp)
  800312:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800315:	e8 e6 09 00 00       	call   800d00 <__umoddi3>
  80031a:	83 c4 14             	add    $0x14,%esp
  80031d:	0f be 84 03 71 ee ff 	movsbl -0x118f(%ebx,%eax,1),%eax
  800324:	ff 
  800325:	50                   	push   %eax
  800326:	ff d7                	call   *%edi
}
  800328:	83 c4 10             	add    $0x10,%esp
  80032b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032e:	5b                   	pop    %ebx
  80032f:	5e                   	pop    %esi
  800330:	5f                   	pop    %edi
  800331:	5d                   	pop    %ebp
  800332:	c3                   	ret    

00800333 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800339:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033d:	8b 10                	mov    (%eax),%edx
  80033f:	3b 50 04             	cmp    0x4(%eax),%edx
  800342:	73 0a                	jae    80034e <sprintputch+0x1b>
		*b->buf++ = ch;
  800344:	8d 4a 01             	lea    0x1(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	88 02                	mov    %al,(%edx)
}
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <printfmt>:
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800356:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800359:	50                   	push   %eax
  80035a:	ff 75 10             	push   0x10(%ebp)
  80035d:	ff 75 0c             	push   0xc(%ebp)
  800360:	ff 75 08             	push   0x8(%ebp)
  800363:	e8 05 00 00 00       	call   80036d <vprintfmt>
}
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	c9                   	leave  
  80036c:	c3                   	ret    

0080036d <vprintfmt>:
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	57                   	push   %edi
  800371:	56                   	push   %esi
  800372:	53                   	push   %ebx
  800373:	83 ec 3c             	sub    $0x3c,%esp
  800376:	e8 d6 fd ff ff       	call   800151 <__x86.get_pc_thunk.ax>
  80037b:	05 85 1c 00 00       	add    $0x1c85,%eax
  800380:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800383:	8b 75 08             	mov    0x8(%ebp),%esi
  800386:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800389:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80038c:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  800392:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800395:	eb 0a                	jmp    8003a1 <vprintfmt+0x34>
			putch(ch, putdat);
  800397:	83 ec 08             	sub    $0x8,%esp
  80039a:	57                   	push   %edi
  80039b:	50                   	push   %eax
  80039c:	ff d6                	call   *%esi
  80039e:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a1:	83 c3 01             	add    $0x1,%ebx
  8003a4:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003a8:	83 f8 25             	cmp    $0x25,%eax
  8003ab:	74 0c                	je     8003b9 <vprintfmt+0x4c>
			if (ch == '\0')
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	75 e6                	jne    800397 <vprintfmt+0x2a>
}
  8003b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b4:	5b                   	pop    %ebx
  8003b5:	5e                   	pop    %esi
  8003b6:	5f                   	pop    %edi
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    
		padc = ' ';
  8003b9:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003bd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003c4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003da:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8d 43 01             	lea    0x1(%ebx),%eax
  8003e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e3:	0f b6 13             	movzbl (%ebx),%edx
  8003e6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e9:	3c 55                	cmp    $0x55,%al
  8003eb:	0f 87 c5 03 00 00    	ja     8007b6 <.L20>
  8003f1:	0f b6 c0             	movzbl %al,%eax
  8003f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f7:	89 ce                	mov    %ecx,%esi
  8003f9:	03 b4 81 00 ef ff ff 	add    -0x1100(%ecx,%eax,4),%esi
  800400:	ff e6                	jmp    *%esi

00800402 <.L66>:
  800402:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800405:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800409:	eb d2                	jmp    8003dd <vprintfmt+0x70>

0080040b <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80040e:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800412:	eb c9                	jmp    8003dd <vprintfmt+0x70>

00800414 <.L31>:
  800414:	0f b6 d2             	movzbl %dl,%edx
  800417:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800422:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800425:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800429:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80042c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80042f:	83 f9 09             	cmp    $0x9,%ecx
  800432:	77 58                	ja     80048c <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800434:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800437:	eb e9                	jmp    800422 <.L31+0xe>

00800439 <.L34>:
			precision = va_arg(ap, int);
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8b 00                	mov    (%eax),%eax
  80043e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 40 04             	lea    0x4(%eax),%eax
  800447:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80044d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800451:	79 8a                	jns    8003dd <vprintfmt+0x70>
				width = precision, precision = -1;
  800453:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800456:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800459:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800460:	e9 78 ff ff ff       	jmp    8003dd <vprintfmt+0x70>

00800465 <.L33>:
  800465:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800468:	85 d2                	test   %edx,%edx
  80046a:	b8 00 00 00 00       	mov    $0x0,%eax
  80046f:	0f 49 c2             	cmovns %edx,%eax
  800472:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800478:	e9 60 ff ff ff       	jmp    8003dd <vprintfmt+0x70>

0080047d <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800480:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800487:	e9 51 ff ff ff       	jmp    8003dd <vprintfmt+0x70>
  80048c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80048f:	89 75 08             	mov    %esi,0x8(%ebp)
  800492:	eb b9                	jmp    80044d <.L34+0x14>

00800494 <.L27>:
			lflag++;
  800494:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80049b:	e9 3d ff ff ff       	jmp    8003dd <vprintfmt+0x70>

008004a0 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8d 58 04             	lea    0x4(%eax),%ebx
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	57                   	push   %edi
  8004ad:	ff 30                	push   (%eax)
  8004af:	ff d6                	call   *%esi
			break;
  8004b1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004b4:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004b7:	e9 90 02 00 00       	jmp    80074c <.L25+0x45>

008004bc <.L28>:
			err = va_arg(ap, int);
  8004bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8d 58 04             	lea    0x4(%eax),%ebx
  8004c5:	8b 10                	mov    (%eax),%edx
  8004c7:	89 d0                	mov    %edx,%eax
  8004c9:	f7 d8                	neg    %eax
  8004cb:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ce:	83 f8 06             	cmp    $0x6,%eax
  8004d1:	7f 27                	jg     8004fa <.L28+0x3e>
  8004d3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d6:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004d9:	85 d2                	test   %edx,%edx
  8004db:	74 1d                	je     8004fa <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004dd:	52                   	push   %edx
  8004de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e1:	8d 80 92 ee ff ff    	lea    -0x116e(%eax),%eax
  8004e7:	50                   	push   %eax
  8004e8:	57                   	push   %edi
  8004e9:	56                   	push   %esi
  8004ea:	e8 61 fe ff ff       	call   800350 <printfmt>
  8004ef:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f2:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004f5:	e9 52 02 00 00       	jmp    80074c <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004fa:	50                   	push   %eax
  8004fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004fe:	8d 80 89 ee ff ff    	lea    -0x1177(%eax),%eax
  800504:	50                   	push   %eax
  800505:	57                   	push   %edi
  800506:	56                   	push   %esi
  800507:	e8 44 fe ff ff       	call   800350 <printfmt>
  80050c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80050f:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800512:	e9 35 02 00 00       	jmp    80074c <.L25+0x45>

00800517 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800517:	8b 75 08             	mov    0x8(%ebp),%esi
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	83 c0 04             	add    $0x4,%eax
  800520:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800528:	85 d2                	test   %edx,%edx
  80052a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052d:	8d 80 82 ee ff ff    	lea    -0x117e(%eax),%eax
  800533:	0f 45 c2             	cmovne %edx,%eax
  800536:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800539:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80053d:	7e 06                	jle    800545 <.L24+0x2e>
  80053f:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800543:	75 0d                	jne    800552 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800545:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	03 45 d0             	add    -0x30(%ebp),%eax
  80054d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800550:	eb 58                	jmp    8005aa <.L24+0x93>
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	ff 75 d8             	push   -0x28(%ebp)
  800558:	ff 75 c8             	push   -0x38(%ebp)
  80055b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055e:	e8 0b 03 00 00       	call   80086e <strnlen>
  800563:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800566:	29 c2                	sub    %eax,%edx
  800568:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800570:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800574:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800577:	eb 0f                	jmp    800588 <.L24+0x71>
					putch(padc, putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	57                   	push   %edi
  80057d:	ff 75 d0             	push   -0x30(%ebp)
  800580:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800582:	83 eb 01             	sub    $0x1,%ebx
  800585:	83 c4 10             	add    $0x10,%esp
  800588:	85 db                	test   %ebx,%ebx
  80058a:	7f ed                	jg     800579 <.L24+0x62>
  80058c:	8b 55 bc             	mov    -0x44(%ebp),%edx
  80058f:	85 d2                	test   %edx,%edx
  800591:	b8 00 00 00 00       	mov    $0x0,%eax
  800596:	0f 49 c2             	cmovns %edx,%eax
  800599:	29 c2                	sub    %eax,%edx
  80059b:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80059e:	eb a5                	jmp    800545 <.L24+0x2e>
					putch(ch, putdat);
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	57                   	push   %edi
  8005a4:	52                   	push   %edx
  8005a5:	ff d6                	call   *%esi
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005ad:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005af:	83 c3 01             	add    $0x1,%ebx
  8005b2:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005b6:	0f be d0             	movsbl %al,%edx
  8005b9:	85 d2                	test   %edx,%edx
  8005bb:	74 4b                	je     800608 <.L24+0xf1>
  8005bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c1:	78 06                	js     8005c9 <.L24+0xb2>
  8005c3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005c7:	78 1e                	js     8005e7 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005c9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005cd:	74 d1                	je     8005a0 <.L24+0x89>
  8005cf:	0f be c0             	movsbl %al,%eax
  8005d2:	83 e8 20             	sub    $0x20,%eax
  8005d5:	83 f8 5e             	cmp    $0x5e,%eax
  8005d8:	76 c6                	jbe    8005a0 <.L24+0x89>
					putch('?', putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	57                   	push   %edi
  8005de:	6a 3f                	push   $0x3f
  8005e0:	ff d6                	call   *%esi
  8005e2:	83 c4 10             	add    $0x10,%esp
  8005e5:	eb c3                	jmp    8005aa <.L24+0x93>
  8005e7:	89 cb                	mov    %ecx,%ebx
  8005e9:	eb 0e                	jmp    8005f9 <.L24+0xe2>
				putch(' ', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	57                   	push   %edi
  8005ef:	6a 20                	push   $0x20
  8005f1:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005f3:	83 eb 01             	sub    $0x1,%ebx
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	85 db                	test   %ebx,%ebx
  8005fb:	7f ee                	jg     8005eb <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  8005fd:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
  800603:	e9 44 01 00 00       	jmp    80074c <.L25+0x45>
  800608:	89 cb                	mov    %ecx,%ebx
  80060a:	eb ed                	jmp    8005f9 <.L24+0xe2>

0080060c <.L29>:
	if (lflag >= 2)
  80060c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80060f:	8b 75 08             	mov    0x8(%ebp),%esi
  800612:	83 f9 01             	cmp    $0x1,%ecx
  800615:	7f 1b                	jg     800632 <.L29+0x26>
	else if (lflag)
  800617:	85 c9                	test   %ecx,%ecx
  800619:	74 63                	je     80067e <.L29+0x72>
		return va_arg(*ap, long);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800623:	99                   	cltd   
  800624:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8d 40 04             	lea    0x4(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
  800630:	eb 17                	jmp    800649 <.L29+0x3d>
		return va_arg(*ap, long long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 50 04             	mov    0x4(%eax),%edx
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 40 08             	lea    0x8(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800649:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80064c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80064f:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800654:	85 db                	test   %ebx,%ebx
  800656:	0f 89 d6 00 00 00    	jns    800732 <.L25+0x2b>
				putch('-', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	57                   	push   %edi
  800660:	6a 2d                	push   $0x2d
  800662:	ff d6                	call   *%esi
				num = -(long long) num;
  800664:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800667:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80066a:	f7 d9                	neg    %ecx
  80066c:	83 d3 00             	adc    $0x0,%ebx
  80066f:	f7 db                	neg    %ebx
  800671:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800674:	ba 0a 00 00 00       	mov    $0xa,%edx
  800679:	e9 b4 00 00 00       	jmp    800732 <.L25+0x2b>
		return va_arg(*ap, int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 00                	mov    (%eax),%eax
  800683:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800686:	99                   	cltd   
  800687:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
  800693:	eb b4                	jmp    800649 <.L29+0x3d>

00800695 <.L23>:
	if (lflag >= 2)
  800695:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800698:	8b 75 08             	mov    0x8(%ebp),%esi
  80069b:	83 f9 01             	cmp    $0x1,%ecx
  80069e:	7f 1b                	jg     8006bb <.L23+0x26>
	else if (lflag)
  8006a0:	85 c9                	test   %ecx,%ecx
  8006a2:	74 2c                	je     8006d0 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8b 08                	mov    (%eax),%ecx
  8006a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ae:	8d 40 04             	lea    0x4(%eax),%eax
  8006b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b4:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006b9:	eb 77                	jmp    800732 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8b 08                	mov    (%eax),%ecx
  8006c0:	8b 58 04             	mov    0x4(%eax),%ebx
  8006c3:	8d 40 08             	lea    0x8(%eax),%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c9:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006ce:	eb 62                	jmp    800732 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 08                	mov    (%eax),%ecx
  8006d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006da:	8d 40 04             	lea    0x4(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e0:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006e5:	eb 4b                	jmp    800732 <.L25+0x2b>

008006e7 <.L26>:
			putch('X', putdat);
  8006e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	57                   	push   %edi
  8006ee:	6a 58                	push   $0x58
  8006f0:	ff d6                	call   *%esi
			putch('X', putdat);
  8006f2:	83 c4 08             	add    $0x8,%esp
  8006f5:	57                   	push   %edi
  8006f6:	6a 58                	push   $0x58
  8006f8:	ff d6                	call   *%esi
			putch('X', putdat);
  8006fa:	83 c4 08             	add    $0x8,%esp
  8006fd:	57                   	push   %edi
  8006fe:	6a 58                	push   $0x58
  800700:	ff d6                	call   *%esi
			break;
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb 45                	jmp    80074c <.L25+0x45>

00800707 <.L25>:
			putch('0', putdat);
  800707:	8b 75 08             	mov    0x8(%ebp),%esi
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	57                   	push   %edi
  80070e:	6a 30                	push   $0x30
  800710:	ff d6                	call   *%esi
			putch('x', putdat);
  800712:	83 c4 08             	add    $0x8,%esp
  800715:	57                   	push   %edi
  800716:	6a 78                	push   $0x78
  800718:	ff d6                	call   *%esi
			num = (unsigned long long)
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 08                	mov    (%eax),%ecx
  80071f:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800724:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800727:	8d 40 04             	lea    0x4(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072d:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800732:	83 ec 0c             	sub    $0xc,%esp
  800735:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	ff 75 d0             	push   -0x30(%ebp)
  80073d:	52                   	push   %edx
  80073e:	53                   	push   %ebx
  80073f:	51                   	push   %ecx
  800740:	89 fa                	mov    %edi,%edx
  800742:	89 f0                	mov    %esi,%eax
  800744:	e8 2c fb ff ff       	call   800275 <printnum>
			break;
  800749:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80074c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80074f:	e9 4d fc ff ff       	jmp    8003a1 <vprintfmt+0x34>

00800754 <.L21>:
	if (lflag >= 2)
  800754:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800757:	8b 75 08             	mov    0x8(%ebp),%esi
  80075a:	83 f9 01             	cmp    $0x1,%ecx
  80075d:	7f 1b                	jg     80077a <.L21+0x26>
	else if (lflag)
  80075f:	85 c9                	test   %ecx,%ecx
  800761:	74 2c                	je     80078f <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8b 08                	mov    (%eax),%ecx
  800768:	bb 00 00 00 00       	mov    $0x0,%ebx
  80076d:	8d 40 04             	lea    0x4(%eax),%eax
  800770:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800773:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  800778:	eb b8                	jmp    800732 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8b 08                	mov    (%eax),%ecx
  80077f:	8b 58 04             	mov    0x4(%eax),%ebx
  800782:	8d 40 08             	lea    0x8(%eax),%eax
  800785:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800788:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  80078d:	eb a3                	jmp    800732 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8b 08                	mov    (%eax),%ecx
  800794:	bb 00 00 00 00       	mov    $0x0,%ebx
  800799:	8d 40 04             	lea    0x4(%eax),%eax
  80079c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079f:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007a4:	eb 8c                	jmp    800732 <.L25+0x2b>

008007a6 <.L35>:
			putch(ch, putdat);
  8007a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a9:	83 ec 08             	sub    $0x8,%esp
  8007ac:	57                   	push   %edi
  8007ad:	6a 25                	push   $0x25
  8007af:	ff d6                	call   *%esi
			break;
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	eb 96                	jmp    80074c <.L25+0x45>

008007b6 <.L20>:
			putch('%', putdat);
  8007b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	57                   	push   %edi
  8007bd:	6a 25                	push   $0x25
  8007bf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c1:	83 c4 10             	add    $0x10,%esp
  8007c4:	89 d8                	mov    %ebx,%eax
  8007c6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007ca:	74 05                	je     8007d1 <.L20+0x1b>
  8007cc:	83 e8 01             	sub    $0x1,%eax
  8007cf:	eb f5                	jmp    8007c6 <.L20+0x10>
  8007d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d4:	e9 73 ff ff ff       	jmp    80074c <.L25+0x45>

008007d9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	83 ec 14             	sub    $0x14,%esp
  8007e0:	e8 96 f8 ff ff       	call   80007b <__x86.get_pc_thunk.bx>
  8007e5:	81 c3 1b 18 00 00    	add    $0x181b,%ebx
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800802:	85 c0                	test   %eax,%eax
  800804:	74 2b                	je     800831 <vsnprintf+0x58>
  800806:	85 d2                	test   %edx,%edx
  800808:	7e 27                	jle    800831 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080a:	ff 75 14             	push   0x14(%ebp)
  80080d:	ff 75 10             	push   0x10(%ebp)
  800810:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800813:	50                   	push   %eax
  800814:	8d 83 33 e3 ff ff    	lea    -0x1ccd(%ebx),%eax
  80081a:	50                   	push   %eax
  80081b:	e8 4d fb ff ff       	call   80036d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800820:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800823:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800826:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800829:	83 c4 10             	add    $0x10,%esp
}
  80082c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082f:	c9                   	leave  
  800830:	c3                   	ret    
		return -E_INVAL;
  800831:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800836:	eb f4                	jmp    80082c <vsnprintf+0x53>

00800838 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800841:	50                   	push   %eax
  800842:	ff 75 10             	push   0x10(%ebp)
  800845:	ff 75 0c             	push   0xc(%ebp)
  800848:	ff 75 08             	push   0x8(%ebp)
  80084b:	e8 89 ff ff ff       	call   8007d9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800850:	c9                   	leave  
  800851:	c3                   	ret    

00800852 <__x86.get_pc_thunk.cx>:
  800852:	8b 0c 24             	mov    (%esp),%ecx
  800855:	c3                   	ret    

00800856 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
  800861:	eb 03                	jmp    800866 <strlen+0x10>
		n++;
  800863:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800866:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086a:	75 f7                	jne    800863 <strlen+0xd>
	return n;
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800874:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
  80087c:	eb 03                	jmp    800881 <strnlen+0x13>
		n++;
  80087e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800881:	39 d0                	cmp    %edx,%eax
  800883:	74 08                	je     80088d <strnlen+0x1f>
  800885:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800889:	75 f3                	jne    80087e <strnlen+0x10>
  80088b:	89 c2                	mov    %eax,%edx
	return n;
}
  80088d:	89 d0                	mov    %edx,%eax
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	53                   	push   %ebx
  800895:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800898:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a0:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008a4:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008a7:	83 c0 01             	add    $0x1,%eax
  8008aa:	84 d2                	test   %dl,%dl
  8008ac:	75 f2                	jne    8008a0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ae:	89 c8                	mov    %ecx,%eax
  8008b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b3:	c9                   	leave  
  8008b4:	c3                   	ret    

008008b5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	53                   	push   %ebx
  8008b9:	83 ec 10             	sub    $0x10,%esp
  8008bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008bf:	53                   	push   %ebx
  8008c0:	e8 91 ff ff ff       	call   800856 <strlen>
  8008c5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008c8:	ff 75 0c             	push   0xc(%ebp)
  8008cb:	01 d8                	add    %ebx,%eax
  8008cd:	50                   	push   %eax
  8008ce:	e8 be ff ff ff       	call   800891 <strcpy>
	return dst;
}
  8008d3:	89 d8                	mov    %ebx,%eax
  8008d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d8:	c9                   	leave  
  8008d9:	c3                   	ret    

008008da <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	56                   	push   %esi
  8008de:	53                   	push   %ebx
  8008df:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e5:	89 f3                	mov    %esi,%ebx
  8008e7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ea:	89 f0                	mov    %esi,%eax
  8008ec:	eb 0f                	jmp    8008fd <strncpy+0x23>
		*dst++ = *src;
  8008ee:	83 c0 01             	add    $0x1,%eax
  8008f1:	0f b6 0a             	movzbl (%edx),%ecx
  8008f4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f7:	80 f9 01             	cmp    $0x1,%cl
  8008fa:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008fd:	39 d8                	cmp    %ebx,%eax
  8008ff:	75 ed                	jne    8008ee <strncpy+0x14>
	}
	return ret;
}
  800901:	89 f0                	mov    %esi,%eax
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	56                   	push   %esi
  80090b:	53                   	push   %ebx
  80090c:	8b 75 08             	mov    0x8(%ebp),%esi
  80090f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800912:	8b 55 10             	mov    0x10(%ebp),%edx
  800915:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800917:	85 d2                	test   %edx,%edx
  800919:	74 21                	je     80093c <strlcpy+0x35>
  80091b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091f:	89 f2                	mov    %esi,%edx
  800921:	eb 09                	jmp    80092c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800923:	83 c1 01             	add    $0x1,%ecx
  800926:	83 c2 01             	add    $0x1,%edx
  800929:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80092c:	39 c2                	cmp    %eax,%edx
  80092e:	74 09                	je     800939 <strlcpy+0x32>
  800930:	0f b6 19             	movzbl (%ecx),%ebx
  800933:	84 db                	test   %bl,%bl
  800935:	75 ec                	jne    800923 <strlcpy+0x1c>
  800937:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800939:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093c:	29 f0                	sub    %esi,%eax
}
  80093e:	5b                   	pop    %ebx
  80093f:	5e                   	pop    %esi
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094b:	eb 06                	jmp    800953 <strcmp+0x11>
		p++, q++;
  80094d:	83 c1 01             	add    $0x1,%ecx
  800950:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800953:	0f b6 01             	movzbl (%ecx),%eax
  800956:	84 c0                	test   %al,%al
  800958:	74 04                	je     80095e <strcmp+0x1c>
  80095a:	3a 02                	cmp    (%edx),%al
  80095c:	74 ef                	je     80094d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095e:	0f b6 c0             	movzbl %al,%eax
  800961:	0f b6 12             	movzbl (%edx),%edx
  800964:	29 d0                	sub    %edx,%eax
}
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	53                   	push   %ebx
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800972:	89 c3                	mov    %eax,%ebx
  800974:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800977:	eb 06                	jmp    80097f <strncmp+0x17>
		n--, p++, q++;
  800979:	83 c0 01             	add    $0x1,%eax
  80097c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80097f:	39 d8                	cmp    %ebx,%eax
  800981:	74 18                	je     80099b <strncmp+0x33>
  800983:	0f b6 08             	movzbl (%eax),%ecx
  800986:	84 c9                	test   %cl,%cl
  800988:	74 04                	je     80098e <strncmp+0x26>
  80098a:	3a 0a                	cmp    (%edx),%cl
  80098c:	74 eb                	je     800979 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098e:	0f b6 00             	movzbl (%eax),%eax
  800991:	0f b6 12             	movzbl (%edx),%edx
  800994:	29 d0                	sub    %edx,%eax
}
  800996:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800999:	c9                   	leave  
  80099a:	c3                   	ret    
		return 0;
  80099b:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a0:	eb f4                	jmp    800996 <strncmp+0x2e>

008009a2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ac:	eb 03                	jmp    8009b1 <strchr+0xf>
  8009ae:	83 c0 01             	add    $0x1,%eax
  8009b1:	0f b6 10             	movzbl (%eax),%edx
  8009b4:	84 d2                	test   %dl,%dl
  8009b6:	74 06                	je     8009be <strchr+0x1c>
		if (*s == c)
  8009b8:	38 ca                	cmp    %cl,%dl
  8009ba:	75 f2                	jne    8009ae <strchr+0xc>
  8009bc:	eb 05                	jmp    8009c3 <strchr+0x21>
			return (char *) s;
	return 0;
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d2:	38 ca                	cmp    %cl,%dl
  8009d4:	74 09                	je     8009df <strfind+0x1a>
  8009d6:	84 d2                	test   %dl,%dl
  8009d8:	74 05                	je     8009df <strfind+0x1a>
	for (; *s; s++)
  8009da:	83 c0 01             	add    $0x1,%eax
  8009dd:	eb f0                	jmp    8009cf <strfind+0xa>
			break;
	return (char *) s;
}
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	57                   	push   %edi
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ed:	85 c9                	test   %ecx,%ecx
  8009ef:	74 2f                	je     800a20 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f1:	89 f8                	mov    %edi,%eax
  8009f3:	09 c8                	or     %ecx,%eax
  8009f5:	a8 03                	test   $0x3,%al
  8009f7:	75 21                	jne    800a1a <memset+0x39>
		c &= 0xFF;
  8009f9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fd:	89 d0                	mov    %edx,%eax
  8009ff:	c1 e0 08             	shl    $0x8,%eax
  800a02:	89 d3                	mov    %edx,%ebx
  800a04:	c1 e3 18             	shl    $0x18,%ebx
  800a07:	89 d6                	mov    %edx,%esi
  800a09:	c1 e6 10             	shl    $0x10,%esi
  800a0c:	09 f3                	or     %esi,%ebx
  800a0e:	09 da                	or     %ebx,%edx
  800a10:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a12:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a15:	fc                   	cld    
  800a16:	f3 ab                	rep stos %eax,%es:(%edi)
  800a18:	eb 06                	jmp    800a20 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1d:	fc                   	cld    
  800a1e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a20:	89 f8                	mov    %edi,%eax
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5f                   	pop    %edi
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a35:	39 c6                	cmp    %eax,%esi
  800a37:	73 32                	jae    800a6b <memmove+0x44>
  800a39:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3c:	39 c2                	cmp    %eax,%edx
  800a3e:	76 2b                	jbe    800a6b <memmove+0x44>
		s += n;
		d += n;
  800a40:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a43:	89 d6                	mov    %edx,%esi
  800a45:	09 fe                	or     %edi,%esi
  800a47:	09 ce                	or     %ecx,%esi
  800a49:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4f:	75 0e                	jne    800a5f <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a51:	83 ef 04             	sub    $0x4,%edi
  800a54:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a57:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a5a:	fd                   	std    
  800a5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5d:	eb 09                	jmp    800a68 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a5f:	83 ef 01             	sub    $0x1,%edi
  800a62:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a65:	fd                   	std    
  800a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a68:	fc                   	cld    
  800a69:	eb 1a                	jmp    800a85 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6b:	89 f2                	mov    %esi,%edx
  800a6d:	09 c2                	or     %eax,%edx
  800a6f:	09 ca                	or     %ecx,%edx
  800a71:	f6 c2 03             	test   $0x3,%dl
  800a74:	75 0a                	jne    800a80 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a76:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a79:	89 c7                	mov    %eax,%edi
  800a7b:	fc                   	cld    
  800a7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7e:	eb 05                	jmp    800a85 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a80:	89 c7                	mov    %eax,%edi
  800a82:	fc                   	cld    
  800a83:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a85:	5e                   	pop    %esi
  800a86:	5f                   	pop    %edi
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a8f:	ff 75 10             	push   0x10(%ebp)
  800a92:	ff 75 0c             	push   0xc(%ebp)
  800a95:	ff 75 08             	push   0x8(%ebp)
  800a98:	e8 8a ff ff ff       	call   800a27 <memmove>
}
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aaa:	89 c6                	mov    %eax,%esi
  800aac:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aaf:	eb 06                	jmp    800ab7 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab1:	83 c0 01             	add    $0x1,%eax
  800ab4:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ab7:	39 f0                	cmp    %esi,%eax
  800ab9:	74 14                	je     800acf <memcmp+0x30>
		if (*s1 != *s2)
  800abb:	0f b6 08             	movzbl (%eax),%ecx
  800abe:	0f b6 1a             	movzbl (%edx),%ebx
  800ac1:	38 d9                	cmp    %bl,%cl
  800ac3:	74 ec                	je     800ab1 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800ac5:	0f b6 c1             	movzbl %cl,%eax
  800ac8:	0f b6 db             	movzbl %bl,%ebx
  800acb:	29 d8                	sub    %ebx,%eax
  800acd:	eb 05                	jmp    800ad4 <memcmp+0x35>
	}

	return 0;
  800acf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae1:	89 c2                	mov    %eax,%edx
  800ae3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae6:	eb 03                	jmp    800aeb <memfind+0x13>
  800ae8:	83 c0 01             	add    $0x1,%eax
  800aeb:	39 d0                	cmp    %edx,%eax
  800aed:	73 04                	jae    800af3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aef:	38 08                	cmp    %cl,(%eax)
  800af1:	75 f5                	jne    800ae8 <memfind+0x10>
			break;
	return (void *) s;
}
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
  800afb:	8b 55 08             	mov    0x8(%ebp),%edx
  800afe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b01:	eb 03                	jmp    800b06 <strtol+0x11>
		s++;
  800b03:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b06:	0f b6 02             	movzbl (%edx),%eax
  800b09:	3c 20                	cmp    $0x20,%al
  800b0b:	74 f6                	je     800b03 <strtol+0xe>
  800b0d:	3c 09                	cmp    $0x9,%al
  800b0f:	74 f2                	je     800b03 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b11:	3c 2b                	cmp    $0x2b,%al
  800b13:	74 2a                	je     800b3f <strtol+0x4a>
	int neg = 0;
  800b15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b1a:	3c 2d                	cmp    $0x2d,%al
  800b1c:	74 2b                	je     800b49 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b24:	75 0f                	jne    800b35 <strtol+0x40>
  800b26:	80 3a 30             	cmpb   $0x30,(%edx)
  800b29:	74 28                	je     800b53 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2b:	85 db                	test   %ebx,%ebx
  800b2d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b32:	0f 44 d8             	cmove  %eax,%ebx
  800b35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b3d:	eb 46                	jmp    800b85 <strtol+0x90>
		s++;
  800b3f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b42:	bf 00 00 00 00       	mov    $0x0,%edi
  800b47:	eb d5                	jmp    800b1e <strtol+0x29>
		s++, neg = 1;
  800b49:	83 c2 01             	add    $0x1,%edx
  800b4c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b51:	eb cb                	jmp    800b1e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b53:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b57:	74 0e                	je     800b67 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b59:	85 db                	test   %ebx,%ebx
  800b5b:	75 d8                	jne    800b35 <strtol+0x40>
		s++, base = 8;
  800b5d:	83 c2 01             	add    $0x1,%edx
  800b60:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b65:	eb ce                	jmp    800b35 <strtol+0x40>
		s += 2, base = 16;
  800b67:	83 c2 02             	add    $0x2,%edx
  800b6a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b6f:	eb c4                	jmp    800b35 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b71:	0f be c0             	movsbl %al,%eax
  800b74:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b77:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b7a:	7d 3a                	jge    800bb6 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b7c:	83 c2 01             	add    $0x1,%edx
  800b7f:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b83:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b85:	0f b6 02             	movzbl (%edx),%eax
  800b88:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b8b:	89 f3                	mov    %esi,%ebx
  800b8d:	80 fb 09             	cmp    $0x9,%bl
  800b90:	76 df                	jbe    800b71 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b92:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b95:	89 f3                	mov    %esi,%ebx
  800b97:	80 fb 19             	cmp    $0x19,%bl
  800b9a:	77 08                	ja     800ba4 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b9c:	0f be c0             	movsbl %al,%eax
  800b9f:	83 e8 57             	sub    $0x57,%eax
  800ba2:	eb d3                	jmp    800b77 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ba4:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ba7:	89 f3                	mov    %esi,%ebx
  800ba9:	80 fb 19             	cmp    $0x19,%bl
  800bac:	77 08                	ja     800bb6 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bae:	0f be c0             	movsbl %al,%eax
  800bb1:	83 e8 37             	sub    $0x37,%eax
  800bb4:	eb c1                	jmp    800b77 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bba:	74 05                	je     800bc1 <strtol+0xcc>
		*endptr = (char *) s;
  800bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbf:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bc1:	89 c8                	mov    %ecx,%eax
  800bc3:	f7 d8                	neg    %eax
  800bc5:	85 ff                	test   %edi,%edi
  800bc7:	0f 45 c8             	cmovne %eax,%ecx
}
  800bca:	89 c8                	mov    %ecx,%eax
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    
  800bd1:	66 90                	xchg   %ax,%ax
  800bd3:	66 90                	xchg   %ax,%ax
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
