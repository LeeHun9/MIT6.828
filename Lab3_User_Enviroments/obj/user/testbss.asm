
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 b9 00 00 00       	call   8000f8 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	int i;

	cprintf("Making sure bss works right...\n");
  800045:	8d 83 d4 ee ff ff    	lea    -0x112c(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 1d 02 00 00       	call   80026e <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800054:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  800059:	83 bc 83 40 00 00 00 	cmpl   $0x0,0x40(%ebx,%eax,4)
  800060:	00 
  800061:	75 69                	jne    8000cc <umain+0x99>
	for (i = 0; i < ARRAYSIZE; i++)
  800063:	83 c0 01             	add    $0x1,%eax
  800066:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006b:	75 ec                	jne    800059 <umain+0x26>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80006d:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800072:	89 84 83 40 00 00 00 	mov    %eax,0x40(%ebx,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  800079:	83 c0 01             	add    $0x1,%eax
  80007c:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800081:	75 ef                	jne    800072 <umain+0x3f>
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  800088:	39 84 83 40 00 00 00 	cmp    %eax,0x40(%ebx,%eax,4)
  80008f:	75 51                	jne    8000e2 <umain+0xaf>
	for (i = 0; i < ARRAYSIZE; i++)
  800091:	83 c0 01             	add    $0x1,%eax
  800094:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800099:	75 ed                	jne    800088 <umain+0x55>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	8d 83 1c ef ff ff    	lea    -0x10e4(%ebx),%eax
  8000a4:	50                   	push   %eax
  8000a5:	e8 c4 01 00 00       	call   80026e <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000aa:	c7 83 40 10 40 00 00 	movl   $0x0,0x401040(%ebx)
  8000b1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000b4:	83 c4 0c             	add    $0xc,%esp
  8000b7:	8d 83 7b ef ff ff    	lea    -0x1085(%ebx),%eax
  8000bd:	50                   	push   %eax
  8000be:	6a 1a                	push   $0x1a
  8000c0:	8d 83 6c ef ff ff    	lea    -0x1094(%ebx),%eax
  8000c6:	50                   	push   %eax
  8000c7:	e8 96 00 00 00       	call   800162 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000cc:	50                   	push   %eax
  8000cd:	8d 83 4f ef ff ff    	lea    -0x10b1(%ebx),%eax
  8000d3:	50                   	push   %eax
  8000d4:	6a 11                	push   $0x11
  8000d6:	8d 83 6c ef ff ff    	lea    -0x1094(%ebx),%eax
  8000dc:	50                   	push   %eax
  8000dd:	e8 80 00 00 00       	call   800162 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000e2:	50                   	push   %eax
  8000e3:	8d 83 f4 ee ff ff    	lea    -0x110c(%ebx),%eax
  8000e9:	50                   	push   %eax
  8000ea:	6a 16                	push   $0x16
  8000ec:	8d 83 6c ef ff ff    	lea    -0x1094(%ebx),%eax
  8000f2:	50                   	push   %eax
  8000f3:	e8 6a 00 00 00       	call   800162 <_panic>

008000f8 <__x86.get_pc_thunk.bx>:
  8000f8:	8b 1c 24             	mov    (%esp),%ebx
  8000fb:	c3                   	ret    

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	53                   	push   %ebx
  800100:	83 ec 04             	sub    $0x4,%esp
  800103:	e8 f0 ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  800108:	81 c3 f8 1e 00 00    	add    $0x1ef8,%ebx
  80010e:	8b 45 08             	mov    0x8(%ebp),%eax
  800111:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800114:	c7 83 40 00 40 00 00 	movl   $0x0,0x400040(%ebx)
  80011b:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011e:	85 c0                	test   %eax,%eax
  800120:	7e 08                	jle    80012a <libmain+0x2e>
		binaryname = argv[0];
  800122:	8b 0a                	mov    (%edx),%ecx
  800124:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	52                   	push   %edx
  80012e:	50                   	push   %eax
  80012f:	e8 ff fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800134:	e8 08 00 00 00       	call   800141 <exit>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 10             	sub    $0x10,%esp
  800148:	e8 ab ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  80014d:	81 c3 b3 1e 00 00    	add    $0x1eb3,%ebx
	sys_env_destroy(0);
  800153:	6a 00                	push   $0x0
  800155:	e8 c5 0a 00 00       	call   800c1f <sys_env_destroy>
}
  80015a:	83 c4 10             	add    $0x10,%esp
  80015d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 0c             	sub    $0xc,%esp
  80016b:	e8 88 ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  800170:	81 c3 90 1e 00 00    	add    $0x1e90,%ebx
	va_list ap;

	va_start(ap, fmt);
  800176:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800179:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80017f:	8b 38                	mov    (%eax),%edi
  800181:	e8 ee 0a 00 00       	call   800c74 <sys_getenvid>
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	ff 75 0c             	push   0xc(%ebp)
  80018c:	ff 75 08             	push   0x8(%ebp)
  80018f:	57                   	push   %edi
  800190:	50                   	push   %eax
  800191:	8d 83 9c ef ff ff    	lea    -0x1064(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 d1 00 00 00       	call   80026e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019d:	83 c4 18             	add    $0x18,%esp
  8001a0:	56                   	push   %esi
  8001a1:	ff 75 10             	push   0x10(%ebp)
  8001a4:	e8 63 00 00 00       	call   80020c <vcprintf>
	cprintf("\n");
  8001a9:	8d 83 6a ef ff ff    	lea    -0x1096(%ebx),%eax
  8001af:	89 04 24             	mov    %eax,(%esp)
  8001b2:	e8 b7 00 00 00       	call   80026e <cprintf>
  8001b7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ba:	cc                   	int3   
  8001bb:	eb fd                	jmp    8001ba <_panic+0x58>

008001bd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	e8 31 ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  8001c7:	81 c3 39 1e 00 00    	add    $0x1e39,%ebx
  8001cd:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001d0:	8b 16                	mov    (%esi),%edx
  8001d2:	8d 42 01             	lea    0x1(%edx),%eax
  8001d5:	89 06                	mov    %eax,(%esi)
  8001d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001da:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e3:	74 0b                	je     8001f0 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001e5:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5e                   	pop    %esi
  8001ee:	5d                   	pop    %ebp
  8001ef:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	68 ff 00 00 00       	push   $0xff
  8001f8:	8d 46 08             	lea    0x8(%esi),%eax
  8001fb:	50                   	push   %eax
  8001fc:	e8 e1 09 00 00       	call   800be2 <sys_cputs>
		b->idx = 0;
  800201:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800207:	83 c4 10             	add    $0x10,%esp
  80020a:	eb d9                	jmp    8001e5 <putch+0x28>

0080020c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	53                   	push   %ebx
  800210:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800216:	e8 dd fe ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  80021b:	81 c3 e5 1d 00 00    	add    $0x1de5,%ebx
	struct printbuf b;

	b.idx = 0;
  800221:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800228:	00 00 00 
	b.cnt = 0;
  80022b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800232:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800235:	ff 75 0c             	push   0xc(%ebp)
  800238:	ff 75 08             	push   0x8(%ebp)
  80023b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800241:	50                   	push   %eax
  800242:	8d 83 bd e1 ff ff    	lea    -0x1e43(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 2c 01 00 00       	call   80037a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024e:	83 c4 08             	add    $0x8,%esp
  800251:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800257:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025d:	50                   	push   %eax
  80025e:	e8 7f 09 00 00       	call   800be2 <sys_cputs>

	return b.cnt;
}
  800263:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800269:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800274:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800277:	50                   	push   %eax
  800278:	ff 75 08             	push   0x8(%ebp)
  80027b:	e8 8c ff ff ff       	call   80020c <vcprintf>
	va_end(ap);

	return cnt;
}
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 2c             	sub    $0x2c,%esp
  80028b:	e8 d3 05 00 00       	call   800863 <__x86.get_pc_thunk.cx>
  800290:	81 c1 70 1d 00 00    	add    $0x1d70,%ecx
  800296:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800299:	89 c7                	mov    %eax,%edi
  80029b:	89 d6                	mov    %edx,%esi
  80029d:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a3:	89 d1                	mov    %edx,%ecx
  8002a5:	89 c2                	mov    %eax,%edx
  8002a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002aa:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002bd:	39 c2                	cmp    %eax,%edx
  8002bf:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002c2:	72 41                	jb     800305 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	ff 75 18             	push   0x18(%ebp)
  8002ca:	83 eb 01             	sub    $0x1,%ebx
  8002cd:	53                   	push   %ebx
  8002ce:	50                   	push   %eax
  8002cf:	83 ec 08             	sub    $0x8,%esp
  8002d2:	ff 75 e4             	push   -0x1c(%ebp)
  8002d5:	ff 75 e0             	push   -0x20(%ebp)
  8002d8:	ff 75 d4             	push   -0x2c(%ebp)
  8002db:	ff 75 d0             	push   -0x30(%ebp)
  8002de:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002e1:	e8 ba 09 00 00       	call   800ca0 <__udivdi3>
  8002e6:	83 c4 18             	add    $0x18,%esp
  8002e9:	52                   	push   %edx
  8002ea:	50                   	push   %eax
  8002eb:	89 f2                	mov    %esi,%edx
  8002ed:	89 f8                	mov    %edi,%eax
  8002ef:	e8 8e ff ff ff       	call   800282 <printnum>
  8002f4:	83 c4 20             	add    $0x20,%esp
  8002f7:	eb 13                	jmp    80030c <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f9:	83 ec 08             	sub    $0x8,%esp
  8002fc:	56                   	push   %esi
  8002fd:	ff 75 18             	push   0x18(%ebp)
  800300:	ff d7                	call   *%edi
  800302:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800305:	83 eb 01             	sub    $0x1,%ebx
  800308:	85 db                	test   %ebx,%ebx
  80030a:	7f ed                	jg     8002f9 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	83 ec 08             	sub    $0x8,%esp
  80030f:	56                   	push   %esi
  800310:	83 ec 04             	sub    $0x4,%esp
  800313:	ff 75 e4             	push   -0x1c(%ebp)
  800316:	ff 75 e0             	push   -0x20(%ebp)
  800319:	ff 75 d4             	push   -0x2c(%ebp)
  80031c:	ff 75 d0             	push   -0x30(%ebp)
  80031f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800322:	e8 99 0a 00 00       	call   800dc0 <__umoddi3>
  800327:	83 c4 14             	add    $0x14,%esp
  80032a:	0f be 84 03 bf ef ff 	movsbl -0x1041(%ebx,%eax,1),%eax
  800331:	ff 
  800332:	50                   	push   %eax
  800333:	ff d7                	call   *%edi
}
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033b:	5b                   	pop    %ebx
  80033c:	5e                   	pop    %esi
  80033d:	5f                   	pop    %edi
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800346:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	3b 50 04             	cmp    0x4(%eax),%edx
  80034f:	73 0a                	jae    80035b <sprintputch+0x1b>
		*b->buf++ = ch;
  800351:	8d 4a 01             	lea    0x1(%edx),%ecx
  800354:	89 08                	mov    %ecx,(%eax)
  800356:	8b 45 08             	mov    0x8(%ebp),%eax
  800359:	88 02                	mov    %al,(%edx)
}
  80035b:	5d                   	pop    %ebp
  80035c:	c3                   	ret    

0080035d <printfmt>:
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800363:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800366:	50                   	push   %eax
  800367:	ff 75 10             	push   0x10(%ebp)
  80036a:	ff 75 0c             	push   0xc(%ebp)
  80036d:	ff 75 08             	push   0x8(%ebp)
  800370:	e8 05 00 00 00       	call   80037a <vprintfmt>
}
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	c9                   	leave  
  800379:	c3                   	ret    

0080037a <vprintfmt>:
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	56                   	push   %esi
  80037f:	53                   	push   %ebx
  800380:	83 ec 3c             	sub    $0x3c,%esp
  800383:	e8 d7 04 00 00       	call   80085f <__x86.get_pc_thunk.ax>
  800388:	05 78 1c 00 00       	add    $0x1c78,%eax
  80038d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800390:	8b 75 08             	mov    0x8(%ebp),%esi
  800393:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800396:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800399:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  80039f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003a2:	eb 0a                	jmp    8003ae <vprintfmt+0x34>
			putch(ch, putdat);
  8003a4:	83 ec 08             	sub    $0x8,%esp
  8003a7:	57                   	push   %edi
  8003a8:	50                   	push   %eax
  8003a9:	ff d6                	call   *%esi
  8003ab:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ae:	83 c3 01             	add    $0x1,%ebx
  8003b1:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003b5:	83 f8 25             	cmp    $0x25,%eax
  8003b8:	74 0c                	je     8003c6 <vprintfmt+0x4c>
			if (ch == '\0')
  8003ba:	85 c0                	test   %eax,%eax
  8003bc:	75 e6                	jne    8003a4 <vprintfmt+0x2a>
}
  8003be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c1:	5b                   	pop    %ebx
  8003c2:	5e                   	pop    %esi
  8003c3:	5f                   	pop    %edi
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    
		padc = ' ';
  8003c6:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003ca:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003d1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003d8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003e7:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8d 43 01             	lea    0x1(%ebx),%eax
  8003ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f0:	0f b6 13             	movzbl (%ebx),%edx
  8003f3:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f6:	3c 55                	cmp    $0x55,%al
  8003f8:	0f 87 c5 03 00 00    	ja     8007c3 <.L20>
  8003fe:	0f b6 c0             	movzbl %al,%eax
  800401:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800404:	89 ce                	mov    %ecx,%esi
  800406:	03 b4 81 4c f0 ff ff 	add    -0xfb4(%ecx,%eax,4),%esi
  80040d:	ff e6                	jmp    *%esi

0080040f <.L66>:
  80040f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800412:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800416:	eb d2                	jmp    8003ea <vprintfmt+0x70>

00800418 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80041b:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  80041f:	eb c9                	jmp    8003ea <vprintfmt+0x70>

00800421 <.L31>:
  800421:	0f b6 d2             	movzbl %dl,%edx
  800424:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800427:	b8 00 00 00 00       	mov    $0x0,%eax
  80042c:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  80042f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800432:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800436:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800439:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80043c:	83 f9 09             	cmp    $0x9,%ecx
  80043f:	77 58                	ja     800499 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800441:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800444:	eb e9                	jmp    80042f <.L31+0xe>

00800446 <.L34>:
			precision = va_arg(ap, int);
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8b 00                	mov    (%eax),%eax
  80044b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8d 40 04             	lea    0x4(%eax),%eax
  800454:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80045a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80045e:	79 8a                	jns    8003ea <vprintfmt+0x70>
				width = precision, precision = -1;
  800460:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800463:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800466:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80046d:	e9 78 ff ff ff       	jmp    8003ea <vprintfmt+0x70>

00800472 <.L33>:
  800472:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	b8 00 00 00 00       	mov    $0x0,%eax
  80047c:	0f 49 c2             	cmovns %edx,%eax
  80047f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800485:	e9 60 ff ff ff       	jmp    8003ea <vprintfmt+0x70>

0080048a <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  80048d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800494:	e9 51 ff ff ff       	jmp    8003ea <vprintfmt+0x70>
  800499:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80049c:	89 75 08             	mov    %esi,0x8(%ebp)
  80049f:	eb b9                	jmp    80045a <.L34+0x14>

008004a1 <.L27>:
			lflag++;
  8004a1:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004a8:	e9 3d ff ff ff       	jmp    8003ea <vprintfmt+0x70>

008004ad <.L30>:
			putch(va_arg(ap, int), putdat);
  8004ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 58 04             	lea    0x4(%eax),%ebx
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	57                   	push   %edi
  8004ba:	ff 30                	push   (%eax)
  8004bc:	ff d6                	call   *%esi
			break;
  8004be:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004c1:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004c4:	e9 90 02 00 00       	jmp    800759 <.L25+0x45>

008004c9 <.L28>:
			err = va_arg(ap, int);
  8004c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 58 04             	lea    0x4(%eax),%ebx
  8004d2:	8b 10                	mov    (%eax),%edx
  8004d4:	89 d0                	mov    %edx,%eax
  8004d6:	f7 d8                	neg    %eax
  8004d8:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004db:	83 f8 06             	cmp    $0x6,%eax
  8004de:	7f 27                	jg     800507 <.L28+0x3e>
  8004e0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e3:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004e6:	85 d2                	test   %edx,%edx
  8004e8:	74 1d                	je     800507 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004ea:	52                   	push   %edx
  8004eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ee:	8d 80 e0 ef ff ff    	lea    -0x1020(%eax),%eax
  8004f4:	50                   	push   %eax
  8004f5:	57                   	push   %edi
  8004f6:	56                   	push   %esi
  8004f7:	e8 61 fe ff ff       	call   80035d <printfmt>
  8004fc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004ff:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800502:	e9 52 02 00 00       	jmp    800759 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800507:	50                   	push   %eax
  800508:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050b:	8d 80 d7 ef ff ff    	lea    -0x1029(%eax),%eax
  800511:	50                   	push   %eax
  800512:	57                   	push   %edi
  800513:	56                   	push   %esi
  800514:	e8 44 fe ff ff       	call   80035d <printfmt>
  800519:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80051c:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80051f:	e9 35 02 00 00       	jmp    800759 <.L25+0x45>

00800524 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800524:	8b 75 08             	mov    0x8(%ebp),%esi
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	83 c0 04             	add    $0x4,%eax
  80052d:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800535:	85 d2                	test   %edx,%edx
  800537:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053a:	8d 80 d0 ef ff ff    	lea    -0x1030(%eax),%eax
  800540:	0f 45 c2             	cmovne %edx,%eax
  800543:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800546:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80054a:	7e 06                	jle    800552 <.L24+0x2e>
  80054c:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800550:	75 0d                	jne    80055f <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800552:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800555:	89 c3                	mov    %eax,%ebx
  800557:	03 45 d0             	add    -0x30(%ebp),%eax
  80055a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80055d:	eb 58                	jmp    8005b7 <.L24+0x93>
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	ff 75 d8             	push   -0x28(%ebp)
  800565:	ff 75 c8             	push   -0x38(%ebp)
  800568:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056b:	e8 0f 03 00 00       	call   80087f <strnlen>
  800570:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800573:	29 c2                	sub    %eax,%edx
  800575:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  80057d:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800581:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800584:	eb 0f                	jmp    800595 <.L24+0x71>
					putch(padc, putdat);
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	57                   	push   %edi
  80058a:	ff 75 d0             	push   -0x30(%ebp)
  80058d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	83 eb 01             	sub    $0x1,%ebx
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	85 db                	test   %ebx,%ebx
  800597:	7f ed                	jg     800586 <.L24+0x62>
  800599:	8b 55 bc             	mov    -0x44(%ebp),%edx
  80059c:	85 d2                	test   %edx,%edx
  80059e:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a3:	0f 49 c2             	cmovns %edx,%eax
  8005a6:	29 c2                	sub    %eax,%edx
  8005a8:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005ab:	eb a5                	jmp    800552 <.L24+0x2e>
					putch(ch, putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	57                   	push   %edi
  8005b1:	52                   	push   %edx
  8005b2:	ff d6                	call   *%esi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005ba:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bc:	83 c3 01             	add    $0x1,%ebx
  8005bf:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005c3:	0f be d0             	movsbl %al,%edx
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	74 4b                	je     800615 <.L24+0xf1>
  8005ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ce:	78 06                	js     8005d6 <.L24+0xb2>
  8005d0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005d4:	78 1e                	js     8005f4 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005da:	74 d1                	je     8005ad <.L24+0x89>
  8005dc:	0f be c0             	movsbl %al,%eax
  8005df:	83 e8 20             	sub    $0x20,%eax
  8005e2:	83 f8 5e             	cmp    $0x5e,%eax
  8005e5:	76 c6                	jbe    8005ad <.L24+0x89>
					putch('?', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	57                   	push   %edi
  8005eb:	6a 3f                	push   $0x3f
  8005ed:	ff d6                	call   *%esi
  8005ef:	83 c4 10             	add    $0x10,%esp
  8005f2:	eb c3                	jmp    8005b7 <.L24+0x93>
  8005f4:	89 cb                	mov    %ecx,%ebx
  8005f6:	eb 0e                	jmp    800606 <.L24+0xe2>
				putch(' ', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	57                   	push   %edi
  8005fc:	6a 20                	push   $0x20
  8005fe:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800600:	83 eb 01             	sub    $0x1,%ebx
  800603:	83 c4 10             	add    $0x10,%esp
  800606:	85 db                	test   %ebx,%ebx
  800608:	7f ee                	jg     8005f8 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  80060a:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80060d:	89 45 14             	mov    %eax,0x14(%ebp)
  800610:	e9 44 01 00 00       	jmp    800759 <.L25+0x45>
  800615:	89 cb                	mov    %ecx,%ebx
  800617:	eb ed                	jmp    800606 <.L24+0xe2>

00800619 <.L29>:
	if (lflag >= 2)
  800619:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80061c:	8b 75 08             	mov    0x8(%ebp),%esi
  80061f:	83 f9 01             	cmp    $0x1,%ecx
  800622:	7f 1b                	jg     80063f <.L29+0x26>
	else if (lflag)
  800624:	85 c9                	test   %ecx,%ecx
  800626:	74 63                	je     80068b <.L29+0x72>
		return va_arg(*ap, long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800630:	99                   	cltd   
  800631:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 40 04             	lea    0x4(%eax),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
  80063d:	eb 17                	jmp    800656 <.L29+0x3d>
		return va_arg(*ap, long long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 50 04             	mov    0x4(%eax),%edx
  800645:	8b 00                	mov    (%eax),%eax
  800647:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8d 40 08             	lea    0x8(%eax),%eax
  800653:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800656:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800659:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80065c:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800661:	85 db                	test   %ebx,%ebx
  800663:	0f 89 d6 00 00 00    	jns    80073f <.L25+0x2b>
				putch('-', putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	57                   	push   %edi
  80066d:	6a 2d                	push   $0x2d
  80066f:	ff d6                	call   *%esi
				num = -(long long) num;
  800671:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800674:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800677:	f7 d9                	neg    %ecx
  800679:	83 d3 00             	adc    $0x0,%ebx
  80067c:	f7 db                	neg    %ebx
  80067e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800681:	ba 0a 00 00 00       	mov    $0xa,%edx
  800686:	e9 b4 00 00 00       	jmp    80073f <.L25+0x2b>
		return va_arg(*ap, int);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800693:	99                   	cltd   
  800694:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 40 04             	lea    0x4(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a0:	eb b4                	jmp    800656 <.L29+0x3d>

008006a2 <.L23>:
	if (lflag >= 2)
  8006a2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a8:	83 f9 01             	cmp    $0x1,%ecx
  8006ab:	7f 1b                	jg     8006c8 <.L23+0x26>
	else if (lflag)
  8006ad:	85 c9                	test   %ecx,%ecx
  8006af:	74 2c                	je     8006dd <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 08                	mov    (%eax),%ecx
  8006b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006bb:	8d 40 04             	lea    0x4(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c1:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006c6:	eb 77                	jmp    80073f <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 08                	mov    (%eax),%ecx
  8006cd:	8b 58 04             	mov    0x4(%eax),%ebx
  8006d0:	8d 40 08             	lea    0x8(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d6:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006db:	eb 62                	jmp    80073f <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 08                	mov    (%eax),%ecx
  8006e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ed:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006f2:	eb 4b                	jmp    80073f <.L25+0x2b>

008006f4 <.L26>:
			putch('X', putdat);
  8006f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	57                   	push   %edi
  8006fb:	6a 58                	push   $0x58
  8006fd:	ff d6                	call   *%esi
			putch('X', putdat);
  8006ff:	83 c4 08             	add    $0x8,%esp
  800702:	57                   	push   %edi
  800703:	6a 58                	push   $0x58
  800705:	ff d6                	call   *%esi
			putch('X', putdat);
  800707:	83 c4 08             	add    $0x8,%esp
  80070a:	57                   	push   %edi
  80070b:	6a 58                	push   $0x58
  80070d:	ff d6                	call   *%esi
			break;
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	eb 45                	jmp    800759 <.L25+0x45>

00800714 <.L25>:
			putch('0', putdat);
  800714:	8b 75 08             	mov    0x8(%ebp),%esi
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	57                   	push   %edi
  80071b:	6a 30                	push   $0x30
  80071d:	ff d6                	call   *%esi
			putch('x', putdat);
  80071f:	83 c4 08             	add    $0x8,%esp
  800722:	57                   	push   %edi
  800723:	6a 78                	push   $0x78
  800725:	ff d6                	call   *%esi
			num = (unsigned long long)
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	8b 08                	mov    (%eax),%ecx
  80072c:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800731:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800734:	8d 40 04             	lea    0x4(%eax),%eax
  800737:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073a:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  80073f:	83 ec 0c             	sub    $0xc,%esp
  800742:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800746:	50                   	push   %eax
  800747:	ff 75 d0             	push   -0x30(%ebp)
  80074a:	52                   	push   %edx
  80074b:	53                   	push   %ebx
  80074c:	51                   	push   %ecx
  80074d:	89 fa                	mov    %edi,%edx
  80074f:	89 f0                	mov    %esi,%eax
  800751:	e8 2c fb ff ff       	call   800282 <printnum>
			break;
  800756:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800759:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80075c:	e9 4d fc ff ff       	jmp    8003ae <vprintfmt+0x34>

00800761 <.L21>:
	if (lflag >= 2)
  800761:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800764:	8b 75 08             	mov    0x8(%ebp),%esi
  800767:	83 f9 01             	cmp    $0x1,%ecx
  80076a:	7f 1b                	jg     800787 <.L21+0x26>
	else if (lflag)
  80076c:	85 c9                	test   %ecx,%ecx
  80076e:	74 2c                	je     80079c <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800770:	8b 45 14             	mov    0x14(%ebp),%eax
  800773:	8b 08                	mov    (%eax),%ecx
  800775:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077a:	8d 40 04             	lea    0x4(%eax),%eax
  80077d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800780:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  800785:	eb b8                	jmp    80073f <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	8b 08                	mov    (%eax),%ecx
  80078c:	8b 58 04             	mov    0x4(%eax),%ebx
  80078f:	8d 40 08             	lea    0x8(%eax),%eax
  800792:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800795:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  80079a:	eb a3                	jmp    80073f <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	8b 08                	mov    (%eax),%ecx
  8007a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a6:	8d 40 04             	lea    0x4(%eax),%eax
  8007a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ac:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007b1:	eb 8c                	jmp    80073f <.L25+0x2b>

008007b3 <.L35>:
			putch(ch, putdat);
  8007b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	57                   	push   %edi
  8007ba:	6a 25                	push   $0x25
  8007bc:	ff d6                	call   *%esi
			break;
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	eb 96                	jmp    800759 <.L25+0x45>

008007c3 <.L20>:
			putch('%', putdat);
  8007c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c6:	83 ec 08             	sub    $0x8,%esp
  8007c9:	57                   	push   %edi
  8007ca:	6a 25                	push   $0x25
  8007cc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ce:	83 c4 10             	add    $0x10,%esp
  8007d1:	89 d8                	mov    %ebx,%eax
  8007d3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007d7:	74 05                	je     8007de <.L20+0x1b>
  8007d9:	83 e8 01             	sub    $0x1,%eax
  8007dc:	eb f5                	jmp    8007d3 <.L20+0x10>
  8007de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007e1:	e9 73 ff ff ff       	jmp    800759 <.L25+0x45>

008007e6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	53                   	push   %ebx
  8007ea:	83 ec 14             	sub    $0x14,%esp
  8007ed:	e8 06 f9 ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  8007f2:	81 c3 0e 18 00 00    	add    $0x180e,%ebx
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800801:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800805:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800808:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080f:	85 c0                	test   %eax,%eax
  800811:	74 2b                	je     80083e <vsnprintf+0x58>
  800813:	85 d2                	test   %edx,%edx
  800815:	7e 27                	jle    80083e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800817:	ff 75 14             	push   0x14(%ebp)
  80081a:	ff 75 10             	push   0x10(%ebp)
  80081d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800820:	50                   	push   %eax
  800821:	8d 83 40 e3 ff ff    	lea    -0x1cc0(%ebx),%eax
  800827:	50                   	push   %eax
  800828:	e8 4d fb ff ff       	call   80037a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800830:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800833:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800836:	83 c4 10             	add    $0x10,%esp
}
  800839:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083c:	c9                   	leave  
  80083d:	c3                   	ret    
		return -E_INVAL;
  80083e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800843:	eb f4                	jmp    800839 <vsnprintf+0x53>

00800845 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084e:	50                   	push   %eax
  80084f:	ff 75 10             	push   0x10(%ebp)
  800852:	ff 75 0c             	push   0xc(%ebp)
  800855:	ff 75 08             	push   0x8(%ebp)
  800858:	e8 89 ff ff ff       	call   8007e6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085d:	c9                   	leave  
  80085e:	c3                   	ret    

0080085f <__x86.get_pc_thunk.ax>:
  80085f:	8b 04 24             	mov    (%esp),%eax
  800862:	c3                   	ret    

00800863 <__x86.get_pc_thunk.cx>:
  800863:	8b 0c 24             	mov    (%esp),%ecx
  800866:	c3                   	ret    

00800867 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086d:	b8 00 00 00 00       	mov    $0x0,%eax
  800872:	eb 03                	jmp    800877 <strlen+0x10>
		n++;
  800874:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800877:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087b:	75 f7                	jne    800874 <strlen+0xd>
	return n;
}
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800885:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800888:	b8 00 00 00 00       	mov    $0x0,%eax
  80088d:	eb 03                	jmp    800892 <strnlen+0x13>
		n++;
  80088f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800892:	39 d0                	cmp    %edx,%eax
  800894:	74 08                	je     80089e <strnlen+0x1f>
  800896:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80089a:	75 f3                	jne    80088f <strnlen+0x10>
  80089c:	89 c2                	mov    %eax,%edx
	return n;
}
  80089e:	89 d0                	mov    %edx,%eax
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008b5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008b8:	83 c0 01             	add    $0x1,%eax
  8008bb:	84 d2                	test   %dl,%dl
  8008bd:	75 f2                	jne    8008b1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008bf:	89 c8                	mov    %ecx,%eax
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	53                   	push   %ebx
  8008ca:	83 ec 10             	sub    $0x10,%esp
  8008cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d0:	53                   	push   %ebx
  8008d1:	e8 91 ff ff ff       	call   800867 <strlen>
  8008d6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008d9:	ff 75 0c             	push   0xc(%ebp)
  8008dc:	01 d8                	add    %ebx,%eax
  8008de:	50                   	push   %eax
  8008df:	e8 be ff ff ff       	call   8008a2 <strcpy>
	return dst;
}
  8008e4:	89 d8                	mov    %ebx,%eax
  8008e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	56                   	push   %esi
  8008ef:	53                   	push   %ebx
  8008f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f6:	89 f3                	mov    %esi,%ebx
  8008f8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fb:	89 f0                	mov    %esi,%eax
  8008fd:	eb 0f                	jmp    80090e <strncpy+0x23>
		*dst++ = *src;
  8008ff:	83 c0 01             	add    $0x1,%eax
  800902:	0f b6 0a             	movzbl (%edx),%ecx
  800905:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800908:	80 f9 01             	cmp    $0x1,%cl
  80090b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80090e:	39 d8                	cmp    %ebx,%eax
  800910:	75 ed                	jne    8008ff <strncpy+0x14>
	}
	return ret;
}
  800912:	89 f0                	mov    %esi,%eax
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 75 08             	mov    0x8(%ebp),%esi
  800920:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800923:	8b 55 10             	mov    0x10(%ebp),%edx
  800926:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800928:	85 d2                	test   %edx,%edx
  80092a:	74 21                	je     80094d <strlcpy+0x35>
  80092c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800930:	89 f2                	mov    %esi,%edx
  800932:	eb 09                	jmp    80093d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800934:	83 c1 01             	add    $0x1,%ecx
  800937:	83 c2 01             	add    $0x1,%edx
  80093a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80093d:	39 c2                	cmp    %eax,%edx
  80093f:	74 09                	je     80094a <strlcpy+0x32>
  800941:	0f b6 19             	movzbl (%ecx),%ebx
  800944:	84 db                	test   %bl,%bl
  800946:	75 ec                	jne    800934 <strlcpy+0x1c>
  800948:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80094a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80094d:	29 f0                	sub    %esi,%eax
}
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800959:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095c:	eb 06                	jmp    800964 <strcmp+0x11>
		p++, q++;
  80095e:	83 c1 01             	add    $0x1,%ecx
  800961:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800964:	0f b6 01             	movzbl (%ecx),%eax
  800967:	84 c0                	test   %al,%al
  800969:	74 04                	je     80096f <strcmp+0x1c>
  80096b:	3a 02                	cmp    (%edx),%al
  80096d:	74 ef                	je     80095e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80096f:	0f b6 c0             	movzbl %al,%eax
  800972:	0f b6 12             	movzbl (%edx),%edx
  800975:	29 d0                	sub    %edx,%eax
}
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	53                   	push   %ebx
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8b 55 0c             	mov    0xc(%ebp),%edx
  800983:	89 c3                	mov    %eax,%ebx
  800985:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800988:	eb 06                	jmp    800990 <strncmp+0x17>
		n--, p++, q++;
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800990:	39 d8                	cmp    %ebx,%eax
  800992:	74 18                	je     8009ac <strncmp+0x33>
  800994:	0f b6 08             	movzbl (%eax),%ecx
  800997:	84 c9                	test   %cl,%cl
  800999:	74 04                	je     80099f <strncmp+0x26>
  80099b:	3a 0a                	cmp    (%edx),%cl
  80099d:	74 eb                	je     80098a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80099f:	0f b6 00             	movzbl (%eax),%eax
  8009a2:	0f b6 12             	movzbl (%edx),%edx
  8009a5:	29 d0                	sub    %edx,%eax
}
  8009a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    
		return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	eb f4                	jmp    8009a7 <strncmp+0x2e>

008009b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009bd:	eb 03                	jmp    8009c2 <strchr+0xf>
  8009bf:	83 c0 01             	add    $0x1,%eax
  8009c2:	0f b6 10             	movzbl (%eax),%edx
  8009c5:	84 d2                	test   %dl,%dl
  8009c7:	74 06                	je     8009cf <strchr+0x1c>
		if (*s == c)
  8009c9:	38 ca                	cmp    %cl,%dl
  8009cb:	75 f2                	jne    8009bf <strchr+0xc>
  8009cd:	eb 05                	jmp    8009d4 <strchr+0x21>
			return (char *) s;
	return 0;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009e3:	38 ca                	cmp    %cl,%dl
  8009e5:	74 09                	je     8009f0 <strfind+0x1a>
  8009e7:	84 d2                	test   %dl,%dl
  8009e9:	74 05                	je     8009f0 <strfind+0x1a>
	for (; *s; s++)
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	eb f0                	jmp    8009e0 <strfind+0xa>
			break;
	return (char *) s;
}
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	57                   	push   %edi
  8009f6:	56                   	push   %esi
  8009f7:	53                   	push   %ebx
  8009f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009fe:	85 c9                	test   %ecx,%ecx
  800a00:	74 2f                	je     800a31 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a02:	89 f8                	mov    %edi,%eax
  800a04:	09 c8                	or     %ecx,%eax
  800a06:	a8 03                	test   $0x3,%al
  800a08:	75 21                	jne    800a2b <memset+0x39>
		c &= 0xFF;
  800a0a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a0e:	89 d0                	mov    %edx,%eax
  800a10:	c1 e0 08             	shl    $0x8,%eax
  800a13:	89 d3                	mov    %edx,%ebx
  800a15:	c1 e3 18             	shl    $0x18,%ebx
  800a18:	89 d6                	mov    %edx,%esi
  800a1a:	c1 e6 10             	shl    $0x10,%esi
  800a1d:	09 f3                	or     %esi,%ebx
  800a1f:	09 da                	or     %ebx,%edx
  800a21:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a23:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a26:	fc                   	cld    
  800a27:	f3 ab                	rep stos %eax,%es:(%edi)
  800a29:	eb 06                	jmp    800a31 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2e:	fc                   	cld    
  800a2f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a31:	89 f8                	mov    %edi,%eax
  800a33:	5b                   	pop    %ebx
  800a34:	5e                   	pop    %esi
  800a35:	5f                   	pop    %edi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	57                   	push   %edi
  800a3c:	56                   	push   %esi
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a46:	39 c6                	cmp    %eax,%esi
  800a48:	73 32                	jae    800a7c <memmove+0x44>
  800a4a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4d:	39 c2                	cmp    %eax,%edx
  800a4f:	76 2b                	jbe    800a7c <memmove+0x44>
		s += n;
		d += n;
  800a51:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a54:	89 d6                	mov    %edx,%esi
  800a56:	09 fe                	or     %edi,%esi
  800a58:	09 ce                	or     %ecx,%esi
  800a5a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a60:	75 0e                	jne    800a70 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a62:	83 ef 04             	sub    $0x4,%edi
  800a65:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a68:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a6b:	fd                   	std    
  800a6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6e:	eb 09                	jmp    800a79 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a70:	83 ef 01             	sub    $0x1,%edi
  800a73:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a76:	fd                   	std    
  800a77:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a79:	fc                   	cld    
  800a7a:	eb 1a                	jmp    800a96 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7c:	89 f2                	mov    %esi,%edx
  800a7e:	09 c2                	or     %eax,%edx
  800a80:	09 ca                	or     %ecx,%edx
  800a82:	f6 c2 03             	test   $0x3,%dl
  800a85:	75 0a                	jne    800a91 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a87:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a8a:	89 c7                	mov    %eax,%edi
  800a8c:	fc                   	cld    
  800a8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8f:	eb 05                	jmp    800a96 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a91:	89 c7                	mov    %eax,%edi
  800a93:	fc                   	cld    
  800a94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa0:	ff 75 10             	push   0x10(%ebp)
  800aa3:	ff 75 0c             	push   0xc(%ebp)
  800aa6:	ff 75 08             	push   0x8(%ebp)
  800aa9:	e8 8a ff ff ff       	call   800a38 <memmove>
}
  800aae:	c9                   	leave  
  800aaf:	c3                   	ret    

00800ab0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abb:	89 c6                	mov    %eax,%esi
  800abd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac0:	eb 06                	jmp    800ac8 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ac2:	83 c0 01             	add    $0x1,%eax
  800ac5:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ac8:	39 f0                	cmp    %esi,%eax
  800aca:	74 14                	je     800ae0 <memcmp+0x30>
		if (*s1 != *s2)
  800acc:	0f b6 08             	movzbl (%eax),%ecx
  800acf:	0f b6 1a             	movzbl (%edx),%ebx
  800ad2:	38 d9                	cmp    %bl,%cl
  800ad4:	74 ec                	je     800ac2 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800ad6:	0f b6 c1             	movzbl %cl,%eax
  800ad9:	0f b6 db             	movzbl %bl,%ebx
  800adc:	29 d8                	sub    %ebx,%eax
  800ade:	eb 05                	jmp    800ae5 <memcmp+0x35>
	}

	return 0;
  800ae0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
  800aef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af2:	89 c2                	mov    %eax,%edx
  800af4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af7:	eb 03                	jmp    800afc <memfind+0x13>
  800af9:	83 c0 01             	add    $0x1,%eax
  800afc:	39 d0                	cmp    %edx,%eax
  800afe:	73 04                	jae    800b04 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b00:	38 08                	cmp    %cl,(%eax)
  800b02:	75 f5                	jne    800af9 <memfind+0x10>
			break;
	return (void *) s;
}
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b12:	eb 03                	jmp    800b17 <strtol+0x11>
		s++;
  800b14:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b17:	0f b6 02             	movzbl (%edx),%eax
  800b1a:	3c 20                	cmp    $0x20,%al
  800b1c:	74 f6                	je     800b14 <strtol+0xe>
  800b1e:	3c 09                	cmp    $0x9,%al
  800b20:	74 f2                	je     800b14 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b22:	3c 2b                	cmp    $0x2b,%al
  800b24:	74 2a                	je     800b50 <strtol+0x4a>
	int neg = 0;
  800b26:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b2b:	3c 2d                	cmp    $0x2d,%al
  800b2d:	74 2b                	je     800b5a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b35:	75 0f                	jne    800b46 <strtol+0x40>
  800b37:	80 3a 30             	cmpb   $0x30,(%edx)
  800b3a:	74 28                	je     800b64 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3c:	85 db                	test   %ebx,%ebx
  800b3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b43:	0f 44 d8             	cmove  %eax,%ebx
  800b46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b4e:	eb 46                	jmp    800b96 <strtol+0x90>
		s++;
  800b50:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b53:	bf 00 00 00 00       	mov    $0x0,%edi
  800b58:	eb d5                	jmp    800b2f <strtol+0x29>
		s++, neg = 1;
  800b5a:	83 c2 01             	add    $0x1,%edx
  800b5d:	bf 01 00 00 00       	mov    $0x1,%edi
  800b62:	eb cb                	jmp    800b2f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b64:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b68:	74 0e                	je     800b78 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b6a:	85 db                	test   %ebx,%ebx
  800b6c:	75 d8                	jne    800b46 <strtol+0x40>
		s++, base = 8;
  800b6e:	83 c2 01             	add    $0x1,%edx
  800b71:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b76:	eb ce                	jmp    800b46 <strtol+0x40>
		s += 2, base = 16;
  800b78:	83 c2 02             	add    $0x2,%edx
  800b7b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b80:	eb c4                	jmp    800b46 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b82:	0f be c0             	movsbl %al,%eax
  800b85:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b88:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b8b:	7d 3a                	jge    800bc7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b8d:	83 c2 01             	add    $0x1,%edx
  800b90:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b94:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b96:	0f b6 02             	movzbl (%edx),%eax
  800b99:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b9c:	89 f3                	mov    %esi,%ebx
  800b9e:	80 fb 09             	cmp    $0x9,%bl
  800ba1:	76 df                	jbe    800b82 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ba3:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ba6:	89 f3                	mov    %esi,%ebx
  800ba8:	80 fb 19             	cmp    $0x19,%bl
  800bab:	77 08                	ja     800bb5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bad:	0f be c0             	movsbl %al,%eax
  800bb0:	83 e8 57             	sub    $0x57,%eax
  800bb3:	eb d3                	jmp    800b88 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bb5:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bb8:	89 f3                	mov    %esi,%ebx
  800bba:	80 fb 19             	cmp    $0x19,%bl
  800bbd:	77 08                	ja     800bc7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bbf:	0f be c0             	movsbl %al,%eax
  800bc2:	83 e8 37             	sub    $0x37,%eax
  800bc5:	eb c1                	jmp    800b88 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bc7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcb:	74 05                	je     800bd2 <strtol+0xcc>
		*endptr = (char *) s;
  800bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bd2:	89 c8                	mov    %ecx,%eax
  800bd4:	f7 d8                	neg    %eax
  800bd6:	85 ff                	test   %edi,%edi
  800bd8:	0f 45 c8             	cmovne %eax,%ecx
}
  800bdb:	89 c8                	mov    %ecx,%eax
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bed:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf3:	89 c3                	mov    %eax,%ebx
  800bf5:	89 c7                	mov    %eax,%edi
  800bf7:	89 c6                	mov    %eax,%esi
  800bf9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c06:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0b:	b8 01 00 00 00       	mov    $0x1,%eax
  800c10:	89 d1                	mov    %edx,%ecx
  800c12:	89 d3                	mov    %edx,%ebx
  800c14:	89 d7                	mov    %edx,%edi
  800c16:	89 d6                	mov    %edx,%esi
  800c18:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 1c             	sub    $0x1c,%esp
  800c28:	e8 32 fc ff ff       	call   80085f <__x86.get_pc_thunk.ax>
  800c2d:	05 d3 13 00 00       	add    $0x13d3,%eax
  800c32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800c35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800c42:	89 cb                	mov    %ecx,%ebx
  800c44:	89 cf                	mov    %ecx,%edi
  800c46:	89 ce                	mov    %ecx,%esi
  800c48:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7f 08                	jg     800c56 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 03                	push   $0x3
  800c5c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c5f:	8d 83 a4 f1 ff ff    	lea    -0xe5c(%ebx),%eax
  800c65:	50                   	push   %eax
  800c66:	6a 23                	push   $0x23
  800c68:	8d 83 c1 f1 ff ff    	lea    -0xe3f(%ebx),%eax
  800c6e:	50                   	push   %eax
  800c6f:	e8 ee f4 ff ff       	call   800162 <_panic>

00800c74 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	b8 02 00 00 00       	mov    $0x2,%eax
  800c84:	89 d1                	mov    %edx,%ecx
  800c86:	89 d3                	mov    %edx,%ebx
  800c88:	89 d7                	mov    %edx,%edi
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    
  800c93:	66 90                	xchg   %ax,%ax
  800c95:	66 90                	xchg   %ax,%ax
  800c97:	66 90                	xchg   %ax,%ax
  800c99:	66 90                	xchg   %ax,%ax
  800c9b:	66 90                	xchg   %ax,%ax
  800c9d:	66 90                	xchg   %ax,%ax
  800c9f:	90                   	nop

00800ca0 <__udivdi3>:
  800ca0:	f3 0f 1e fb          	endbr32 
  800ca4:	55                   	push   %ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 1c             	sub    $0x1c,%esp
  800cab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800caf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800cb3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cb7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	75 19                	jne    800cd8 <__udivdi3+0x38>
  800cbf:	39 f3                	cmp    %esi,%ebx
  800cc1:	76 4d                	jbe    800d10 <__udivdi3+0x70>
  800cc3:	31 ff                	xor    %edi,%edi
  800cc5:	89 e8                	mov    %ebp,%eax
  800cc7:	89 f2                	mov    %esi,%edx
  800cc9:	f7 f3                	div    %ebx
  800ccb:	89 fa                	mov    %edi,%edx
  800ccd:	83 c4 1c             	add    $0x1c,%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    
  800cd5:	8d 76 00             	lea    0x0(%esi),%esi
  800cd8:	39 f0                	cmp    %esi,%eax
  800cda:	76 14                	jbe    800cf0 <__udivdi3+0x50>
  800cdc:	31 ff                	xor    %edi,%edi
  800cde:	31 c0                	xor    %eax,%eax
  800ce0:	89 fa                	mov    %edi,%edx
  800ce2:	83 c4 1c             	add    $0x1c,%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    
  800cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cf0:	0f bd f8             	bsr    %eax,%edi
  800cf3:	83 f7 1f             	xor    $0x1f,%edi
  800cf6:	75 48                	jne    800d40 <__udivdi3+0xa0>
  800cf8:	39 f0                	cmp    %esi,%eax
  800cfa:	72 06                	jb     800d02 <__udivdi3+0x62>
  800cfc:	31 c0                	xor    %eax,%eax
  800cfe:	39 eb                	cmp    %ebp,%ebx
  800d00:	77 de                	ja     800ce0 <__udivdi3+0x40>
  800d02:	b8 01 00 00 00       	mov    $0x1,%eax
  800d07:	eb d7                	jmp    800ce0 <__udivdi3+0x40>
  800d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d10:	89 d9                	mov    %ebx,%ecx
  800d12:	85 db                	test   %ebx,%ebx
  800d14:	75 0b                	jne    800d21 <__udivdi3+0x81>
  800d16:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1b:	31 d2                	xor    %edx,%edx
  800d1d:	f7 f3                	div    %ebx
  800d1f:	89 c1                	mov    %eax,%ecx
  800d21:	31 d2                	xor    %edx,%edx
  800d23:	89 f0                	mov    %esi,%eax
  800d25:	f7 f1                	div    %ecx
  800d27:	89 c6                	mov    %eax,%esi
  800d29:	89 e8                	mov    %ebp,%eax
  800d2b:	89 f7                	mov    %esi,%edi
  800d2d:	f7 f1                	div    %ecx
  800d2f:	89 fa                	mov    %edi,%edx
  800d31:	83 c4 1c             	add    $0x1c,%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    
  800d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d40:	89 f9                	mov    %edi,%ecx
  800d42:	ba 20 00 00 00       	mov    $0x20,%edx
  800d47:	29 fa                	sub    %edi,%edx
  800d49:	d3 e0                	shl    %cl,%eax
  800d4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d4f:	89 d1                	mov    %edx,%ecx
  800d51:	89 d8                	mov    %ebx,%eax
  800d53:	d3 e8                	shr    %cl,%eax
  800d55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d59:	09 c1                	or     %eax,%ecx
  800d5b:	89 f0                	mov    %esi,%eax
  800d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d61:	89 f9                	mov    %edi,%ecx
  800d63:	d3 e3                	shl    %cl,%ebx
  800d65:	89 d1                	mov    %edx,%ecx
  800d67:	d3 e8                	shr    %cl,%eax
  800d69:	89 f9                	mov    %edi,%ecx
  800d6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d6f:	89 eb                	mov    %ebp,%ebx
  800d71:	d3 e6                	shl    %cl,%esi
  800d73:	89 d1                	mov    %edx,%ecx
  800d75:	d3 eb                	shr    %cl,%ebx
  800d77:	09 f3                	or     %esi,%ebx
  800d79:	89 c6                	mov    %eax,%esi
  800d7b:	89 f2                	mov    %esi,%edx
  800d7d:	89 d8                	mov    %ebx,%eax
  800d7f:	f7 74 24 08          	divl   0x8(%esp)
  800d83:	89 d6                	mov    %edx,%esi
  800d85:	89 c3                	mov    %eax,%ebx
  800d87:	f7 64 24 0c          	mull   0xc(%esp)
  800d8b:	39 d6                	cmp    %edx,%esi
  800d8d:	72 19                	jb     800da8 <__udivdi3+0x108>
  800d8f:	89 f9                	mov    %edi,%ecx
  800d91:	d3 e5                	shl    %cl,%ebp
  800d93:	39 c5                	cmp    %eax,%ebp
  800d95:	73 04                	jae    800d9b <__udivdi3+0xfb>
  800d97:	39 d6                	cmp    %edx,%esi
  800d99:	74 0d                	je     800da8 <__udivdi3+0x108>
  800d9b:	89 d8                	mov    %ebx,%eax
  800d9d:	31 ff                	xor    %edi,%edi
  800d9f:	e9 3c ff ff ff       	jmp    800ce0 <__udivdi3+0x40>
  800da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800da8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800dab:	31 ff                	xor    %edi,%edi
  800dad:	e9 2e ff ff ff       	jmp    800ce0 <__udivdi3+0x40>
  800db2:	66 90                	xchg   %ax,%ax
  800db4:	66 90                	xchg   %ax,%ax
  800db6:	66 90                	xchg   %ax,%ax
  800db8:	66 90                	xchg   %ax,%ax
  800dba:	66 90                	xchg   %ax,%ax
  800dbc:	66 90                	xchg   %ax,%ax
  800dbe:	66 90                	xchg   %ax,%ax

00800dc0 <__umoddi3>:
  800dc0:	f3 0f 1e fb          	endbr32 
  800dc4:	55                   	push   %ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 1c             	sub    $0x1c,%esp
  800dcb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800dcf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800dd3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800dd7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800ddb:	89 f0                	mov    %esi,%eax
  800ddd:	89 da                	mov    %ebx,%edx
  800ddf:	85 ff                	test   %edi,%edi
  800de1:	75 15                	jne    800df8 <__umoddi3+0x38>
  800de3:	39 dd                	cmp    %ebx,%ebp
  800de5:	76 39                	jbe    800e20 <__umoddi3+0x60>
  800de7:	f7 f5                	div    %ebp
  800de9:	89 d0                	mov    %edx,%eax
  800deb:	31 d2                	xor    %edx,%edx
  800ded:	83 c4 1c             	add    $0x1c,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
  800df8:	39 df                	cmp    %ebx,%edi
  800dfa:	77 f1                	ja     800ded <__umoddi3+0x2d>
  800dfc:	0f bd cf             	bsr    %edi,%ecx
  800dff:	83 f1 1f             	xor    $0x1f,%ecx
  800e02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e06:	75 40                	jne    800e48 <__umoddi3+0x88>
  800e08:	39 df                	cmp    %ebx,%edi
  800e0a:	72 04                	jb     800e10 <__umoddi3+0x50>
  800e0c:	39 f5                	cmp    %esi,%ebp
  800e0e:	77 dd                	ja     800ded <__umoddi3+0x2d>
  800e10:	89 da                	mov    %ebx,%edx
  800e12:	89 f0                	mov    %esi,%eax
  800e14:	29 e8                	sub    %ebp,%eax
  800e16:	19 fa                	sbb    %edi,%edx
  800e18:	eb d3                	jmp    800ded <__umoddi3+0x2d>
  800e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e20:	89 e9                	mov    %ebp,%ecx
  800e22:	85 ed                	test   %ebp,%ebp
  800e24:	75 0b                	jne    800e31 <__umoddi3+0x71>
  800e26:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2b:	31 d2                	xor    %edx,%edx
  800e2d:	f7 f5                	div    %ebp
  800e2f:	89 c1                	mov    %eax,%ecx
  800e31:	89 d8                	mov    %ebx,%eax
  800e33:	31 d2                	xor    %edx,%edx
  800e35:	f7 f1                	div    %ecx
  800e37:	89 f0                	mov    %esi,%eax
  800e39:	f7 f1                	div    %ecx
  800e3b:	89 d0                	mov    %edx,%eax
  800e3d:	31 d2                	xor    %edx,%edx
  800e3f:	eb ac                	jmp    800ded <__umoddi3+0x2d>
  800e41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e48:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e4c:	ba 20 00 00 00       	mov    $0x20,%edx
  800e51:	29 c2                	sub    %eax,%edx
  800e53:	89 c1                	mov    %eax,%ecx
  800e55:	89 e8                	mov    %ebp,%eax
  800e57:	d3 e7                	shl    %cl,%edi
  800e59:	89 d1                	mov    %edx,%ecx
  800e5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e5f:	d3 e8                	shr    %cl,%eax
  800e61:	89 c1                	mov    %eax,%ecx
  800e63:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e67:	09 f9                	or     %edi,%ecx
  800e69:	89 df                	mov    %ebx,%edi
  800e6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e6f:	89 c1                	mov    %eax,%ecx
  800e71:	d3 e5                	shl    %cl,%ebp
  800e73:	89 d1                	mov    %edx,%ecx
  800e75:	d3 ef                	shr    %cl,%edi
  800e77:	89 c1                	mov    %eax,%ecx
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	d3 e3                	shl    %cl,%ebx
  800e7d:	89 d1                	mov    %edx,%ecx
  800e7f:	89 fa                	mov    %edi,%edx
  800e81:	d3 e8                	shr    %cl,%eax
  800e83:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e88:	09 d8                	or     %ebx,%eax
  800e8a:	f7 74 24 08          	divl   0x8(%esp)
  800e8e:	89 d3                	mov    %edx,%ebx
  800e90:	d3 e6                	shl    %cl,%esi
  800e92:	f7 e5                	mul    %ebp
  800e94:	89 c7                	mov    %eax,%edi
  800e96:	89 d1                	mov    %edx,%ecx
  800e98:	39 d3                	cmp    %edx,%ebx
  800e9a:	72 06                	jb     800ea2 <__umoddi3+0xe2>
  800e9c:	75 0e                	jne    800eac <__umoddi3+0xec>
  800e9e:	39 c6                	cmp    %eax,%esi
  800ea0:	73 0a                	jae    800eac <__umoddi3+0xec>
  800ea2:	29 e8                	sub    %ebp,%eax
  800ea4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ea8:	89 d1                	mov    %edx,%ecx
  800eaa:	89 c7                	mov    %eax,%edi
  800eac:	89 f5                	mov    %esi,%ebp
  800eae:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eb2:	29 fd                	sub    %edi,%ebp
  800eb4:	19 cb                	sbb    %ecx,%ebx
  800eb6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800ebb:	89 d8                	mov    %ebx,%eax
  800ebd:	d3 e0                	shl    %cl,%eax
  800ebf:	89 f1                	mov    %esi,%ecx
  800ec1:	d3 ed                	shr    %cl,%ebp
  800ec3:	d3 eb                	shr    %cl,%ebx
  800ec5:	09 e8                	or     %ebp,%eax
  800ec7:	89 da                	mov    %ebx,%edx
  800ec9:	83 c4 1c             	add    $0x1c,%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    
