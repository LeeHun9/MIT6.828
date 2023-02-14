
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 44 00 00 00       	call   800075 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 32 00 00 00       	call   800071 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	zero = 0;
  800045:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  80004c:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
  800054:	b9 00 00 00 00       	mov    $0x0,%ecx
  800059:	99                   	cltd   
  80005a:	f7 f9                	idiv   %ecx
  80005c:	50                   	push   %eax
  80005d:	8d 83 44 ee ff ff    	lea    -0x11bc(%ebx),%eax
  800063:	50                   	push   %eax
  800064:	e8 23 01 00 00       	call   80018c <cprintf>
}
  800069:	83 c4 10             	add    $0x10,%esp
  80006c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006f:	c9                   	leave  
  800070:	c3                   	ret    

00800071 <__x86.get_pc_thunk.bx>:
  800071:	8b 1c 24             	mov    (%esp),%ebx
  800074:	c3                   	ret    

00800075 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800075:	55                   	push   %ebp
  800076:	89 e5                	mov    %esp,%ebp
  800078:	53                   	push   %ebx
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	e8 f0 ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800081:	81 c3 7f 1f 00 00    	add    $0x1f7f,%ebx
  800087:	8b 45 08             	mov    0x8(%ebp),%eax
  80008a:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80008d:	c7 83 30 00 00 00 00 	movl   $0x0,0x30(%ebx)
  800094:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800097:	85 c0                	test   %eax,%eax
  800099:	7e 08                	jle    8000a3 <libmain+0x2e>
		binaryname = argv[0];
  80009b:	8b 0a                	mov    (%edx),%ecx
  80009d:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a3:	83 ec 08             	sub    $0x8,%esp
  8000a6:	52                   	push   %edx
  8000a7:	50                   	push   %eax
  8000a8:	e8 86 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ad:	e8 08 00 00 00       	call   8000ba <exit>
}
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    

008000ba <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	53                   	push   %ebx
  8000be:	83 ec 10             	sub    $0x10,%esp
  8000c1:	e8 ab ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  8000c6:	81 c3 3a 1f 00 00    	add    $0x1f3a,%ebx
	sys_env_destroy(0);
  8000cc:	6a 00                	push   $0x0
  8000ce:	e8 6a 0a 00 00       	call   800b3d <sys_env_destroy>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
  8000e0:	e8 8c ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  8000e5:	81 c3 1b 1f 00 00    	add    $0x1f1b,%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000ee:	8b 16                	mov    (%esi),%edx
  8000f0:	8d 42 01             	lea    0x1(%edx),%eax
  8000f3:	89 06                	mov    %eax,(%esi)
  8000f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f8:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8000fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800101:	74 0b                	je     80010e <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800103:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800107:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	68 ff 00 00 00       	push   $0xff
  800116:	8d 46 08             	lea    0x8(%esi),%eax
  800119:	50                   	push   %eax
  80011a:	e8 e1 09 00 00       	call   800b00 <sys_cputs>
		b->idx = 0;
  80011f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	eb d9                	jmp    800103 <putch+0x28>

0080012a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	53                   	push   %ebx
  80012e:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800134:	e8 38 ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800139:	81 c3 c7 1e 00 00    	add    $0x1ec7,%ebx
	struct printbuf b;

	b.idx = 0;
  80013f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800146:	00 00 00 
	b.cnt = 0;
  800149:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800150:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800153:	ff 75 0c             	push   0xc(%ebp)
  800156:	ff 75 08             	push   0x8(%ebp)
  800159:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015f:	50                   	push   %eax
  800160:	8d 83 db e0 ff ff    	lea    -0x1f25(%ebx),%eax
  800166:	50                   	push   %eax
  800167:	e8 2c 01 00 00       	call   800298 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016c:	83 c4 08             	add    $0x8,%esp
  80016f:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800175:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017b:	50                   	push   %eax
  80017c:	e8 7f 09 00 00       	call   800b00 <sys_cputs>

	return b.cnt;
}
  800181:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800192:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800195:	50                   	push   %eax
  800196:	ff 75 08             	push   0x8(%ebp)
  800199:	e8 8c ff ff ff       	call   80012a <vcprintf>
	va_end(ap);

	return cnt;
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 2c             	sub    $0x2c,%esp
  8001a9:	e8 d3 05 00 00       	call   800781 <__x86.get_pc_thunk.cx>
  8001ae:	81 c1 52 1e 00 00    	add    $0x1e52,%ecx
  8001b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001b7:	89 c7                	mov    %eax,%edi
  8001b9:	89 d6                	mov    %edx,%esi
  8001bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c1:	89 d1                	mov    %edx,%ecx
  8001c3:	89 c2                	mov    %eax,%edx
  8001c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001c8:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8001cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001db:	39 c2                	cmp    %eax,%edx
  8001dd:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001e0:	72 41                	jb     800223 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e2:	83 ec 0c             	sub    $0xc,%esp
  8001e5:	ff 75 18             	push   0x18(%ebp)
  8001e8:	83 eb 01             	sub    $0x1,%ebx
  8001eb:	53                   	push   %ebx
  8001ec:	50                   	push   %eax
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 e4             	push   -0x1c(%ebp)
  8001f3:	ff 75 e0             	push   -0x20(%ebp)
  8001f6:	ff 75 d4             	push   -0x2c(%ebp)
  8001f9:	ff 75 d0             	push   -0x30(%ebp)
  8001fc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001ff:	e8 0c 0a 00 00       	call   800c10 <__udivdi3>
  800204:	83 c4 18             	add    $0x18,%esp
  800207:	52                   	push   %edx
  800208:	50                   	push   %eax
  800209:	89 f2                	mov    %esi,%edx
  80020b:	89 f8                	mov    %edi,%eax
  80020d:	e8 8e ff ff ff       	call   8001a0 <printnum>
  800212:	83 c4 20             	add    $0x20,%esp
  800215:	eb 13                	jmp    80022a <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800217:	83 ec 08             	sub    $0x8,%esp
  80021a:	56                   	push   %esi
  80021b:	ff 75 18             	push   0x18(%ebp)
  80021e:	ff d7                	call   *%edi
  800220:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800223:	83 eb 01             	sub    $0x1,%ebx
  800226:	85 db                	test   %ebx,%ebx
  800228:	7f ed                	jg     800217 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	56                   	push   %esi
  80022e:	83 ec 04             	sub    $0x4,%esp
  800231:	ff 75 e4             	push   -0x1c(%ebp)
  800234:	ff 75 e0             	push   -0x20(%ebp)
  800237:	ff 75 d4             	push   -0x2c(%ebp)
  80023a:	ff 75 d0             	push   -0x30(%ebp)
  80023d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800240:	e8 eb 0a 00 00       	call   800d30 <__umoddi3>
  800245:	83 c4 14             	add    $0x14,%esp
  800248:	0f be 84 03 5c ee ff 	movsbl -0x11a4(%ebx,%eax,1),%eax
  80024f:	ff 
  800250:	50                   	push   %eax
  800251:	ff d7                	call   *%edi
}
  800253:	83 c4 10             	add    $0x10,%esp
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800264:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	3b 50 04             	cmp    0x4(%eax),%edx
  80026d:	73 0a                	jae    800279 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800272:	89 08                	mov    %ecx,(%eax)
  800274:	8b 45 08             	mov    0x8(%ebp),%eax
  800277:	88 02                	mov    %al,(%edx)
}
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <printfmt>:
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800281:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800284:	50                   	push   %eax
  800285:	ff 75 10             	push   0x10(%ebp)
  800288:	ff 75 0c             	push   0xc(%ebp)
  80028b:	ff 75 08             	push   0x8(%ebp)
  80028e:	e8 05 00 00 00       	call   800298 <vprintfmt>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <vprintfmt>:
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 3c             	sub    $0x3c,%esp
  8002a1:	e8 d7 04 00 00       	call   80077d <__x86.get_pc_thunk.ax>
  8002a6:	05 5a 1d 00 00       	add    $0x1d5a,%eax
  8002ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8002b7:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8002bd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002c0:	eb 0a                	jmp    8002cc <vprintfmt+0x34>
			putch(ch, putdat);
  8002c2:	83 ec 08             	sub    $0x8,%esp
  8002c5:	57                   	push   %edi
  8002c6:	50                   	push   %eax
  8002c7:	ff d6                	call   *%esi
  8002c9:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cc:	83 c3 01             	add    $0x1,%ebx
  8002cf:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8002d3:	83 f8 25             	cmp    $0x25,%eax
  8002d6:	74 0c                	je     8002e4 <vprintfmt+0x4c>
			if (ch == '\0')
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	75 e6                	jne    8002c2 <vprintfmt+0x2a>
}
  8002dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002df:	5b                   	pop    %ebx
  8002e0:	5e                   	pop    %esi
  8002e1:	5f                   	pop    %edi
  8002e2:	5d                   	pop    %ebp
  8002e3:	c3                   	ret    
		padc = ' ';
  8002e4:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8002e8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ef:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8002fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800302:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800305:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800308:	8d 43 01             	lea    0x1(%ebx),%eax
  80030b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030e:	0f b6 13             	movzbl (%ebx),%edx
  800311:	8d 42 dd             	lea    -0x23(%edx),%eax
  800314:	3c 55                	cmp    $0x55,%al
  800316:	0f 87 c5 03 00 00    	ja     8006e1 <.L20>
  80031c:	0f b6 c0             	movzbl %al,%eax
  80031f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800322:	89 ce                	mov    %ecx,%esi
  800324:	03 b4 81 ec ee ff ff 	add    -0x1114(%ecx,%eax,4),%esi
  80032b:	ff e6                	jmp    *%esi

0080032d <.L66>:
  80032d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800330:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800334:	eb d2                	jmp    800308 <vprintfmt+0x70>

00800336 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800339:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  80033d:	eb c9                	jmp    800308 <vprintfmt+0x70>

0080033f <.L31>:
  80033f:	0f b6 d2             	movzbl %dl,%edx
  800342:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800345:	b8 00 00 00 00       	mov    $0x0,%eax
  80034a:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  80034d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800350:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800354:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800357:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80035a:	83 f9 09             	cmp    $0x9,%ecx
  80035d:	77 58                	ja     8003b7 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80035f:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800362:	eb e9                	jmp    80034d <.L31+0xe>

00800364 <.L34>:
			precision = va_arg(ap, int);
  800364:	8b 45 14             	mov    0x14(%ebp),%eax
  800367:	8b 00                	mov    (%eax),%eax
  800369:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036c:	8b 45 14             	mov    0x14(%ebp),%eax
  80036f:	8d 40 04             	lea    0x4(%eax),%eax
  800372:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800378:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80037c:	79 8a                	jns    800308 <vprintfmt+0x70>
				width = precision, precision = -1;
  80037e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800381:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800384:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80038b:	e9 78 ff ff ff       	jmp    800308 <vprintfmt+0x70>

00800390 <.L33>:
  800390:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800393:	85 d2                	test   %edx,%edx
  800395:	b8 00 00 00 00       	mov    $0x0,%eax
  80039a:	0f 49 c2             	cmovns %edx,%eax
  80039d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003a3:	e9 60 ff ff ff       	jmp    800308 <vprintfmt+0x70>

008003a8 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8003ab:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003b2:	e9 51 ff ff ff       	jmp    800308 <vprintfmt+0x70>
  8003b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8003bd:	eb b9                	jmp    800378 <.L34+0x14>

008003bf <.L27>:
			lflag++;
  8003bf:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003c6:	e9 3d ff ff ff       	jmp    800308 <vprintfmt+0x70>

008003cb <.L30>:
			putch(va_arg(ap, int), putdat);
  8003cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 58 04             	lea    0x4(%eax),%ebx
  8003d4:	83 ec 08             	sub    $0x8,%esp
  8003d7:	57                   	push   %edi
  8003d8:	ff 30                	push   (%eax)
  8003da:	ff d6                	call   *%esi
			break;
  8003dc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003df:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8003e2:	e9 90 02 00 00       	jmp    800677 <.L25+0x45>

008003e7 <.L28>:
			err = va_arg(ap, int);
  8003e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	8d 58 04             	lea    0x4(%eax),%ebx
  8003f0:	8b 10                	mov    (%eax),%edx
  8003f2:	89 d0                	mov    %edx,%eax
  8003f4:	f7 d8                	neg    %eax
  8003f6:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f9:	83 f8 06             	cmp    $0x6,%eax
  8003fc:	7f 27                	jg     800425 <.L28+0x3e>
  8003fe:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800401:	8b 14 82             	mov    (%edx,%eax,4),%edx
  800404:	85 d2                	test   %edx,%edx
  800406:	74 1d                	je     800425 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  800408:	52                   	push   %edx
  800409:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040c:	8d 80 7d ee ff ff    	lea    -0x1183(%eax),%eax
  800412:	50                   	push   %eax
  800413:	57                   	push   %edi
  800414:	56                   	push   %esi
  800415:	e8 61 fe ff ff       	call   80027b <printfmt>
  80041a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041d:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800420:	e9 52 02 00 00       	jmp    800677 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800425:	50                   	push   %eax
  800426:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800429:	8d 80 74 ee ff ff    	lea    -0x118c(%eax),%eax
  80042f:	50                   	push   %eax
  800430:	57                   	push   %edi
  800431:	56                   	push   %esi
  800432:	e8 44 fe ff ff       	call   80027b <printfmt>
  800437:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043a:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80043d:	e9 35 02 00 00       	jmp    800677 <.L25+0x45>

00800442 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800442:	8b 75 08             	mov    0x8(%ebp),%esi
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	83 c0 04             	add    $0x4,%eax
  80044b:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800453:	85 d2                	test   %edx,%edx
  800455:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800458:	8d 80 6d ee ff ff    	lea    -0x1193(%eax),%eax
  80045e:	0f 45 c2             	cmovne %edx,%eax
  800461:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800464:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800468:	7e 06                	jle    800470 <.L24+0x2e>
  80046a:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  80046e:	75 0d                	jne    80047d <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800470:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800473:	89 c3                	mov    %eax,%ebx
  800475:	03 45 d0             	add    -0x30(%ebp),%eax
  800478:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80047b:	eb 58                	jmp    8004d5 <.L24+0x93>
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	ff 75 d8             	push   -0x28(%ebp)
  800483:	ff 75 c8             	push   -0x38(%ebp)
  800486:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800489:	e8 0f 03 00 00       	call   80079d <strnlen>
  80048e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800491:	29 c2                	sub    %eax,%edx
  800493:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800496:	83 c4 10             	add    $0x10,%esp
  800499:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  80049b:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80049f:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a2:	eb 0f                	jmp    8004b3 <.L24+0x71>
					putch(padc, putdat);
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	57                   	push   %edi
  8004a8:	ff 75 d0             	push   -0x30(%ebp)
  8004ab:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	83 eb 01             	sub    $0x1,%ebx
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	85 db                	test   %ebx,%ebx
  8004b5:	7f ed                	jg     8004a4 <.L24+0x62>
  8004b7:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8004ba:	85 d2                	test   %edx,%edx
  8004bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c1:	0f 49 c2             	cmovns %edx,%eax
  8004c4:	29 c2                	sub    %eax,%edx
  8004c6:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004c9:	eb a5                	jmp    800470 <.L24+0x2e>
					putch(ch, putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	57                   	push   %edi
  8004cf:	52                   	push   %edx
  8004d0:	ff d6                	call   *%esi
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004d8:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	83 c3 01             	add    $0x1,%ebx
  8004dd:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8004e1:	0f be d0             	movsbl %al,%edx
  8004e4:	85 d2                	test   %edx,%edx
  8004e6:	74 4b                	je     800533 <.L24+0xf1>
  8004e8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ec:	78 06                	js     8004f4 <.L24+0xb2>
  8004ee:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004f2:	78 1e                	js     800512 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f8:	74 d1                	je     8004cb <.L24+0x89>
  8004fa:	0f be c0             	movsbl %al,%eax
  8004fd:	83 e8 20             	sub    $0x20,%eax
  800500:	83 f8 5e             	cmp    $0x5e,%eax
  800503:	76 c6                	jbe    8004cb <.L24+0x89>
					putch('?', putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	57                   	push   %edi
  800509:	6a 3f                	push   $0x3f
  80050b:	ff d6                	call   *%esi
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	eb c3                	jmp    8004d5 <.L24+0x93>
  800512:	89 cb                	mov    %ecx,%ebx
  800514:	eb 0e                	jmp    800524 <.L24+0xe2>
				putch(' ', putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	57                   	push   %edi
  80051a:	6a 20                	push   $0x20
  80051c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80051e:	83 eb 01             	sub    $0x1,%ebx
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f ee                	jg     800516 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800528:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80052b:	89 45 14             	mov    %eax,0x14(%ebp)
  80052e:	e9 44 01 00 00       	jmp    800677 <.L25+0x45>
  800533:	89 cb                	mov    %ecx,%ebx
  800535:	eb ed                	jmp    800524 <.L24+0xe2>

00800537 <.L29>:
	if (lflag >= 2)
  800537:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80053a:	8b 75 08             	mov    0x8(%ebp),%esi
  80053d:	83 f9 01             	cmp    $0x1,%ecx
  800540:	7f 1b                	jg     80055d <.L29+0x26>
	else if (lflag)
  800542:	85 c9                	test   %ecx,%ecx
  800544:	74 63                	je     8005a9 <.L29+0x72>
		return va_arg(*ap, long);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054e:	99                   	cltd   
  80054f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 40 04             	lea    0x4(%eax),%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
  80055b:	eb 17                	jmp    800574 <.L29+0x3d>
		return va_arg(*ap, long long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 50 04             	mov    0x4(%eax),%edx
  800563:	8b 00                	mov    (%eax),%eax
  800565:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800568:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 40 08             	lea    0x8(%eax),%eax
  800571:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800574:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800577:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80057a:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80057f:	85 db                	test   %ebx,%ebx
  800581:	0f 89 d6 00 00 00    	jns    80065d <.L25+0x2b>
				putch('-', putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	57                   	push   %edi
  80058b:	6a 2d                	push   $0x2d
  80058d:	ff d6                	call   *%esi
				num = -(long long) num;
  80058f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800592:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800595:	f7 d9                	neg    %ecx
  800597:	83 d3 00             	adc    $0x0,%ebx
  80059a:	f7 db                	neg    %ebx
  80059c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80059f:	ba 0a 00 00 00       	mov    $0xa,%edx
  8005a4:	e9 b4 00 00 00       	jmp    80065d <.L25+0x2b>
		return va_arg(*ap, int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	99                   	cltd   
  8005b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 40 04             	lea    0x4(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005be:	eb b4                	jmp    800574 <.L29+0x3d>

008005c0 <.L23>:
	if (lflag >= 2)
  8005c0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c6:	83 f9 01             	cmp    $0x1,%ecx
  8005c9:	7f 1b                	jg     8005e6 <.L23+0x26>
	else if (lflag)
  8005cb:	85 c9                	test   %ecx,%ecx
  8005cd:	74 2c                	je     8005fb <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 08                	mov    (%eax),%ecx
  8005d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005d9:	8d 40 04             	lea    0x4(%eax),%eax
  8005dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005df:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8005e4:	eb 77                	jmp    80065d <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8b 08                	mov    (%eax),%ecx
  8005eb:	8b 58 04             	mov    0x4(%eax),%ebx
  8005ee:	8d 40 08             	lea    0x8(%eax),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f4:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8005f9:	eb 62                	jmp    80065d <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8b 08                	mov    (%eax),%ecx
  800600:	bb 00 00 00 00       	mov    $0x0,%ebx
  800605:	8d 40 04             	lea    0x4(%eax),%eax
  800608:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060b:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800610:	eb 4b                	jmp    80065d <.L25+0x2b>

00800612 <.L26>:
			putch('X', putdat);
  800612:	8b 75 08             	mov    0x8(%ebp),%esi
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	57                   	push   %edi
  800619:	6a 58                	push   $0x58
  80061b:	ff d6                	call   *%esi
			putch('X', putdat);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	57                   	push   %edi
  800621:	6a 58                	push   $0x58
  800623:	ff d6                	call   *%esi
			putch('X', putdat);
  800625:	83 c4 08             	add    $0x8,%esp
  800628:	57                   	push   %edi
  800629:	6a 58                	push   $0x58
  80062b:	ff d6                	call   *%esi
			break;
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	eb 45                	jmp    800677 <.L25+0x45>

00800632 <.L25>:
			putch('0', putdat);
  800632:	8b 75 08             	mov    0x8(%ebp),%esi
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	57                   	push   %edi
  800639:	6a 30                	push   $0x30
  80063b:	ff d6                	call   *%esi
			putch('x', putdat);
  80063d:	83 c4 08             	add    $0x8,%esp
  800640:	57                   	push   %edi
  800641:	6a 78                	push   $0x78
  800643:	ff d6                	call   *%esi
			num = (unsigned long long)
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8b 08                	mov    (%eax),%ecx
  80064a:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80064f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800652:	8d 40 04             	lea    0x4(%eax),%eax
  800655:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800658:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  80065d:	83 ec 0c             	sub    $0xc,%esp
  800660:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800664:	50                   	push   %eax
  800665:	ff 75 d0             	push   -0x30(%ebp)
  800668:	52                   	push   %edx
  800669:	53                   	push   %ebx
  80066a:	51                   	push   %ecx
  80066b:	89 fa                	mov    %edi,%edx
  80066d:	89 f0                	mov    %esi,%eax
  80066f:	e8 2c fb ff ff       	call   8001a0 <printnum>
			break;
  800674:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800677:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80067a:	e9 4d fc ff ff       	jmp    8002cc <vprintfmt+0x34>

0080067f <.L21>:
	if (lflag >= 2)
  80067f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800682:	8b 75 08             	mov    0x8(%ebp),%esi
  800685:	83 f9 01             	cmp    $0x1,%ecx
  800688:	7f 1b                	jg     8006a5 <.L21+0x26>
	else if (lflag)
  80068a:	85 c9                	test   %ecx,%ecx
  80068c:	74 2c                	je     8006ba <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8b 08                	mov    (%eax),%ecx
  800693:	bb 00 00 00 00       	mov    $0x0,%ebx
  800698:	8d 40 04             	lea    0x4(%eax),%eax
  80069b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069e:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8006a3:	eb b8                	jmp    80065d <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 08                	mov    (%eax),%ecx
  8006aa:	8b 58 04             	mov    0x4(%eax),%ebx
  8006ad:	8d 40 08             	lea    0x8(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b3:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8006b8:	eb a3                	jmp    80065d <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 08                	mov    (%eax),%ecx
  8006bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c4:	8d 40 04             	lea    0x4(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ca:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8006cf:	eb 8c                	jmp    80065d <.L25+0x2b>

008006d1 <.L35>:
			putch(ch, putdat);
  8006d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	57                   	push   %edi
  8006d8:	6a 25                	push   $0x25
  8006da:	ff d6                	call   *%esi
			break;
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	eb 96                	jmp    800677 <.L25+0x45>

008006e1 <.L20>:
			putch('%', putdat);
  8006e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	57                   	push   %edi
  8006e8:	6a 25                	push   $0x25
  8006ea:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	89 d8                	mov    %ebx,%eax
  8006f1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006f5:	74 05                	je     8006fc <.L20+0x1b>
  8006f7:	83 e8 01             	sub    $0x1,%eax
  8006fa:	eb f5                	jmp    8006f1 <.L20+0x10>
  8006fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ff:	e9 73 ff ff ff       	jmp    800677 <.L25+0x45>

00800704 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	53                   	push   %ebx
  800708:	83 ec 14             	sub    $0x14,%esp
  80070b:	e8 61 f9 ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800710:	81 c3 f0 18 00 00    	add    $0x18f0,%ebx
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800723:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800726:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 2b                	je     80075c <vsnprintf+0x58>
  800731:	85 d2                	test   %edx,%edx
  800733:	7e 27                	jle    80075c <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800735:	ff 75 14             	push   0x14(%ebp)
  800738:	ff 75 10             	push   0x10(%ebp)
  80073b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073e:	50                   	push   %eax
  80073f:	8d 83 5e e2 ff ff    	lea    -0x1da2(%ebx),%eax
  800745:	50                   	push   %eax
  800746:	e8 4d fb ff ff       	call   800298 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800751:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800754:	83 c4 10             	add    $0x10,%esp
}
  800757:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075a:	c9                   	leave  
  80075b:	c3                   	ret    
		return -E_INVAL;
  80075c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800761:	eb f4                	jmp    800757 <vsnprintf+0x53>

00800763 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800769:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076c:	50                   	push   %eax
  80076d:	ff 75 10             	push   0x10(%ebp)
  800770:	ff 75 0c             	push   0xc(%ebp)
  800773:	ff 75 08             	push   0x8(%ebp)
  800776:	e8 89 ff ff ff       	call   800704 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <__x86.get_pc_thunk.ax>:
  80077d:	8b 04 24             	mov    (%esp),%eax
  800780:	c3                   	ret    

00800781 <__x86.get_pc_thunk.cx>:
  800781:	8b 0c 24             	mov    (%esp),%ecx
  800784:	c3                   	ret    

00800785 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078b:	b8 00 00 00 00       	mov    $0x0,%eax
  800790:	eb 03                	jmp    800795 <strlen+0x10>
		n++;
  800792:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800795:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800799:	75 f7                	jne    800792 <strlen+0xd>
	return n;
}
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ab:	eb 03                	jmp    8007b0 <strnlen+0x13>
		n++;
  8007ad:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b0:	39 d0                	cmp    %edx,%eax
  8007b2:	74 08                	je     8007bc <strnlen+0x1f>
  8007b4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b8:	75 f3                	jne    8007ad <strnlen+0x10>
  8007ba:	89 c2                	mov    %eax,%edx
	return n;
}
  8007bc:	89 d0                	mov    %edx,%eax
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	53                   	push   %ebx
  8007c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cf:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007d3:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007d6:	83 c0 01             	add    $0x1,%eax
  8007d9:	84 d2                	test   %dl,%dl
  8007db:	75 f2                	jne    8007cf <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007dd:	89 c8                	mov    %ecx,%eax
  8007df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	53                   	push   %ebx
  8007e8:	83 ec 10             	sub    $0x10,%esp
  8007eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ee:	53                   	push   %ebx
  8007ef:	e8 91 ff ff ff       	call   800785 <strlen>
  8007f4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007f7:	ff 75 0c             	push   0xc(%ebp)
  8007fa:	01 d8                	add    %ebx,%eax
  8007fc:	50                   	push   %eax
  8007fd:	e8 be ff ff ff       	call   8007c0 <strcpy>
	return dst;
}
  800802:	89 d8                	mov    %ebx,%eax
  800804:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800807:	c9                   	leave  
  800808:	c3                   	ret    

00800809 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	56                   	push   %esi
  80080d:	53                   	push   %ebx
  80080e:	8b 75 08             	mov    0x8(%ebp),%esi
  800811:	8b 55 0c             	mov    0xc(%ebp),%edx
  800814:	89 f3                	mov    %esi,%ebx
  800816:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800819:	89 f0                	mov    %esi,%eax
  80081b:	eb 0f                	jmp    80082c <strncpy+0x23>
		*dst++ = *src;
  80081d:	83 c0 01             	add    $0x1,%eax
  800820:	0f b6 0a             	movzbl (%edx),%ecx
  800823:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800826:	80 f9 01             	cmp    $0x1,%cl
  800829:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80082c:	39 d8                	cmp    %ebx,%eax
  80082e:	75 ed                	jne    80081d <strncpy+0x14>
	}
	return ret;
}
  800830:	89 f0                	mov    %esi,%eax
  800832:	5b                   	pop    %ebx
  800833:	5e                   	pop    %esi
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	56                   	push   %esi
  80083a:	53                   	push   %ebx
  80083b:	8b 75 08             	mov    0x8(%ebp),%esi
  80083e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800841:	8b 55 10             	mov    0x10(%ebp),%edx
  800844:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800846:	85 d2                	test   %edx,%edx
  800848:	74 21                	je     80086b <strlcpy+0x35>
  80084a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80084e:	89 f2                	mov    %esi,%edx
  800850:	eb 09                	jmp    80085b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800852:	83 c1 01             	add    $0x1,%ecx
  800855:	83 c2 01             	add    $0x1,%edx
  800858:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80085b:	39 c2                	cmp    %eax,%edx
  80085d:	74 09                	je     800868 <strlcpy+0x32>
  80085f:	0f b6 19             	movzbl (%ecx),%ebx
  800862:	84 db                	test   %bl,%bl
  800864:	75 ec                	jne    800852 <strlcpy+0x1c>
  800866:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800868:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086b:	29 f0                	sub    %esi,%eax
}
  80086d:	5b                   	pop    %ebx
  80086e:	5e                   	pop    %esi
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800877:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087a:	eb 06                	jmp    800882 <strcmp+0x11>
		p++, q++;
  80087c:	83 c1 01             	add    $0x1,%ecx
  80087f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800882:	0f b6 01             	movzbl (%ecx),%eax
  800885:	84 c0                	test   %al,%al
  800887:	74 04                	je     80088d <strcmp+0x1c>
  800889:	3a 02                	cmp    (%edx),%al
  80088b:	74 ef                	je     80087c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088d:	0f b6 c0             	movzbl %al,%eax
  800890:	0f b6 12             	movzbl (%edx),%edx
  800893:	29 d0                	sub    %edx,%eax
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a1:	89 c3                	mov    %eax,%ebx
  8008a3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a6:	eb 06                	jmp    8008ae <strncmp+0x17>
		n--, p++, q++;
  8008a8:	83 c0 01             	add    $0x1,%eax
  8008ab:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ae:	39 d8                	cmp    %ebx,%eax
  8008b0:	74 18                	je     8008ca <strncmp+0x33>
  8008b2:	0f b6 08             	movzbl (%eax),%ecx
  8008b5:	84 c9                	test   %cl,%cl
  8008b7:	74 04                	je     8008bd <strncmp+0x26>
  8008b9:	3a 0a                	cmp    (%edx),%cl
  8008bb:	74 eb                	je     8008a8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bd:	0f b6 00             	movzbl (%eax),%eax
  8008c0:	0f b6 12             	movzbl (%edx),%edx
  8008c3:	29 d0                	sub    %edx,%eax
}
  8008c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c8:	c9                   	leave  
  8008c9:	c3                   	ret    
		return 0;
  8008ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cf:	eb f4                	jmp    8008c5 <strncmp+0x2e>

008008d1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008db:	eb 03                	jmp    8008e0 <strchr+0xf>
  8008dd:	83 c0 01             	add    $0x1,%eax
  8008e0:	0f b6 10             	movzbl (%eax),%edx
  8008e3:	84 d2                	test   %dl,%dl
  8008e5:	74 06                	je     8008ed <strchr+0x1c>
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	75 f2                	jne    8008dd <strchr+0xc>
  8008eb:	eb 05                	jmp    8008f2 <strchr+0x21>
			return (char *) s;
	return 0;
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fe:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800901:	38 ca                	cmp    %cl,%dl
  800903:	74 09                	je     80090e <strfind+0x1a>
  800905:	84 d2                	test   %dl,%dl
  800907:	74 05                	je     80090e <strfind+0x1a>
	for (; *s; s++)
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	eb f0                	jmp    8008fe <strfind+0xa>
			break;
	return (char *) s;
}
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	57                   	push   %edi
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	8b 7d 08             	mov    0x8(%ebp),%edi
  800919:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091c:	85 c9                	test   %ecx,%ecx
  80091e:	74 2f                	je     80094f <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800920:	89 f8                	mov    %edi,%eax
  800922:	09 c8                	or     %ecx,%eax
  800924:	a8 03                	test   $0x3,%al
  800926:	75 21                	jne    800949 <memset+0x39>
		c &= 0xFF;
  800928:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092c:	89 d0                	mov    %edx,%eax
  80092e:	c1 e0 08             	shl    $0x8,%eax
  800931:	89 d3                	mov    %edx,%ebx
  800933:	c1 e3 18             	shl    $0x18,%ebx
  800936:	89 d6                	mov    %edx,%esi
  800938:	c1 e6 10             	shl    $0x10,%esi
  80093b:	09 f3                	or     %esi,%ebx
  80093d:	09 da                	or     %ebx,%edx
  80093f:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800941:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800944:	fc                   	cld    
  800945:	f3 ab                	rep stos %eax,%es:(%edi)
  800947:	eb 06                	jmp    80094f <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800949:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094c:	fc                   	cld    
  80094d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094f:	89 f8                	mov    %edi,%eax
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5f                   	pop    %edi
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	57                   	push   %edi
  80095a:	56                   	push   %esi
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800961:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800964:	39 c6                	cmp    %eax,%esi
  800966:	73 32                	jae    80099a <memmove+0x44>
  800968:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096b:	39 c2                	cmp    %eax,%edx
  80096d:	76 2b                	jbe    80099a <memmove+0x44>
		s += n;
		d += n;
  80096f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800972:	89 d6                	mov    %edx,%esi
  800974:	09 fe                	or     %edi,%esi
  800976:	09 ce                	or     %ecx,%esi
  800978:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097e:	75 0e                	jne    80098e <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800980:	83 ef 04             	sub    $0x4,%edi
  800983:	8d 72 fc             	lea    -0x4(%edx),%esi
  800986:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800989:	fd                   	std    
  80098a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098c:	eb 09                	jmp    800997 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80098e:	83 ef 01             	sub    $0x1,%edi
  800991:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800994:	fd                   	std    
  800995:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800997:	fc                   	cld    
  800998:	eb 1a                	jmp    8009b4 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099a:	89 f2                	mov    %esi,%edx
  80099c:	09 c2                	or     %eax,%edx
  80099e:	09 ca                	or     %ecx,%edx
  8009a0:	f6 c2 03             	test   $0x3,%dl
  8009a3:	75 0a                	jne    8009af <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009a8:	89 c7                	mov    %eax,%edi
  8009aa:	fc                   	cld    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 05                	jmp    8009b4 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009af:	89 c7                	mov    %eax,%edi
  8009b1:	fc                   	cld    
  8009b2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b4:	5e                   	pop    %esi
  8009b5:	5f                   	pop    %edi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009be:	ff 75 10             	push   0x10(%ebp)
  8009c1:	ff 75 0c             	push   0xc(%ebp)
  8009c4:	ff 75 08             	push   0x8(%ebp)
  8009c7:	e8 8a ff ff ff       	call   800956 <memmove>
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d9:	89 c6                	mov    %eax,%esi
  8009db:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009de:	eb 06                	jmp    8009e6 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009e0:	83 c0 01             	add    $0x1,%eax
  8009e3:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009e6:	39 f0                	cmp    %esi,%eax
  8009e8:	74 14                	je     8009fe <memcmp+0x30>
		if (*s1 != *s2)
  8009ea:	0f b6 08             	movzbl (%eax),%ecx
  8009ed:	0f b6 1a             	movzbl (%edx),%ebx
  8009f0:	38 d9                	cmp    %bl,%cl
  8009f2:	74 ec                	je     8009e0 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009f4:	0f b6 c1             	movzbl %cl,%eax
  8009f7:	0f b6 db             	movzbl %bl,%ebx
  8009fa:	29 d8                	sub    %ebx,%eax
  8009fc:	eb 05                	jmp    800a03 <memcmp+0x35>
	}

	return 0;
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a10:	89 c2                	mov    %eax,%edx
  800a12:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a15:	eb 03                	jmp    800a1a <memfind+0x13>
  800a17:	83 c0 01             	add    $0x1,%eax
  800a1a:	39 d0                	cmp    %edx,%eax
  800a1c:	73 04                	jae    800a22 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1e:	38 08                	cmp    %cl,(%eax)
  800a20:	75 f5                	jne    800a17 <memfind+0x10>
			break;
	return (void *) s;
}
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a30:	eb 03                	jmp    800a35 <strtol+0x11>
		s++;
  800a32:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a35:	0f b6 02             	movzbl (%edx),%eax
  800a38:	3c 20                	cmp    $0x20,%al
  800a3a:	74 f6                	je     800a32 <strtol+0xe>
  800a3c:	3c 09                	cmp    $0x9,%al
  800a3e:	74 f2                	je     800a32 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a40:	3c 2b                	cmp    $0x2b,%al
  800a42:	74 2a                	je     800a6e <strtol+0x4a>
	int neg = 0;
  800a44:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a49:	3c 2d                	cmp    $0x2d,%al
  800a4b:	74 2b                	je     800a78 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a53:	75 0f                	jne    800a64 <strtol+0x40>
  800a55:	80 3a 30             	cmpb   $0x30,(%edx)
  800a58:	74 28                	je     800a82 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5a:	85 db                	test   %ebx,%ebx
  800a5c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a61:	0f 44 d8             	cmove  %eax,%ebx
  800a64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a69:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a6c:	eb 46                	jmp    800ab4 <strtol+0x90>
		s++;
  800a6e:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a71:	bf 00 00 00 00       	mov    $0x0,%edi
  800a76:	eb d5                	jmp    800a4d <strtol+0x29>
		s++, neg = 1;
  800a78:	83 c2 01             	add    $0x1,%edx
  800a7b:	bf 01 00 00 00       	mov    $0x1,%edi
  800a80:	eb cb                	jmp    800a4d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a82:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a86:	74 0e                	je     800a96 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a88:	85 db                	test   %ebx,%ebx
  800a8a:	75 d8                	jne    800a64 <strtol+0x40>
		s++, base = 8;
  800a8c:	83 c2 01             	add    $0x1,%edx
  800a8f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a94:	eb ce                	jmp    800a64 <strtol+0x40>
		s += 2, base = 16;
  800a96:	83 c2 02             	add    $0x2,%edx
  800a99:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9e:	eb c4                	jmp    800a64 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aa0:	0f be c0             	movsbl %al,%eax
  800aa3:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa6:	3b 45 10             	cmp    0x10(%ebp),%eax
  800aa9:	7d 3a                	jge    800ae5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800aab:	83 c2 01             	add    $0x1,%edx
  800aae:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ab2:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ab4:	0f b6 02             	movzbl (%edx),%eax
  800ab7:	8d 70 d0             	lea    -0x30(%eax),%esi
  800aba:	89 f3                	mov    %esi,%ebx
  800abc:	80 fb 09             	cmp    $0x9,%bl
  800abf:	76 df                	jbe    800aa0 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ac1:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ac4:	89 f3                	mov    %esi,%ebx
  800ac6:	80 fb 19             	cmp    $0x19,%bl
  800ac9:	77 08                	ja     800ad3 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800acb:	0f be c0             	movsbl %al,%eax
  800ace:	83 e8 57             	sub    $0x57,%eax
  800ad1:	eb d3                	jmp    800aa6 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ad3:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ad6:	89 f3                	mov    %esi,%ebx
  800ad8:	80 fb 19             	cmp    $0x19,%bl
  800adb:	77 08                	ja     800ae5 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800add:	0f be c0             	movsbl %al,%eax
  800ae0:	83 e8 37             	sub    $0x37,%eax
  800ae3:	eb c1                	jmp    800aa6 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ae5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae9:	74 05                	je     800af0 <strtol+0xcc>
		*endptr = (char *) s;
  800aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aee:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800af0:	89 c8                	mov    %ecx,%eax
  800af2:	f7 d8                	neg    %eax
  800af4:	85 ff                	test   %edi,%edi
  800af6:	0f 45 c8             	cmovne %eax,%ecx
}
  800af9:	89 c8                	mov    %ecx,%eax
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b11:	89 c3                	mov    %eax,%ebx
  800b13:	89 c7                	mov    %eax,%edi
  800b15:	89 c6                	mov    %eax,%esi
  800b17:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	83 ec 1c             	sub    $0x1c,%esp
  800b46:	e8 32 fc ff ff       	call   80077d <__x86.get_pc_thunk.ax>
  800b4b:	05 b5 14 00 00       	add    $0x14b5,%eax
  800b50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b58:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b60:	89 cb                	mov    %ecx,%ebx
  800b62:	89 cf                	mov    %ecx,%edi
  800b64:	89 ce                	mov    %ecx,%esi
  800b66:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	7f 08                	jg     800b74 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b74:	83 ec 0c             	sub    $0xc,%esp
  800b77:	50                   	push   %eax
  800b78:	6a 03                	push   $0x3
  800b7a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800b7d:	8d 83 44 f0 ff ff    	lea    -0xfbc(%ebx),%eax
  800b83:	50                   	push   %eax
  800b84:	6a 23                	push   $0x23
  800b86:	8d 83 61 f0 ff ff    	lea    -0xf9f(%ebx),%eax
  800b8c:	50                   	push   %eax
  800b8d:	e8 1f 00 00 00       	call   800bb1 <_panic>

00800b92 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b98:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9d:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba2:	89 d1                	mov    %edx,%ecx
  800ba4:	89 d3                	mov    %edx,%ebx
  800ba6:	89 d7                	mov    %edx,%edi
  800ba8:	89 d6                	mov    %edx,%esi
  800baa:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	e8 b2 f4 ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800bbf:	81 c3 41 14 00 00    	add    $0x1441,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bc5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bc8:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800bce:	8b 38                	mov    (%eax),%edi
  800bd0:	e8 bd ff ff ff       	call   800b92 <sys_getenvid>
  800bd5:	83 ec 0c             	sub    $0xc,%esp
  800bd8:	ff 75 0c             	push   0xc(%ebp)
  800bdb:	ff 75 08             	push   0x8(%ebp)
  800bde:	57                   	push   %edi
  800bdf:	50                   	push   %eax
  800be0:	8d 83 70 f0 ff ff    	lea    -0xf90(%ebx),%eax
  800be6:	50                   	push   %eax
  800be7:	e8 a0 f5 ff ff       	call   80018c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bec:	83 c4 18             	add    $0x18,%esp
  800bef:	56                   	push   %esi
  800bf0:	ff 75 10             	push   0x10(%ebp)
  800bf3:	e8 32 f5 ff ff       	call   80012a <vcprintf>
	cprintf("\n");
  800bf8:	8d 83 50 ee ff ff    	lea    -0x11b0(%ebx),%eax
  800bfe:	89 04 24             	mov    %eax,(%esp)
  800c01:	e8 86 f5 ff ff       	call   80018c <cprintf>
  800c06:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c09:	cc                   	int3   
  800c0a:	eb fd                	jmp    800c09 <_panic+0x58>
  800c0c:	66 90                	xchg   %ax,%ax
  800c0e:	66 90                	xchg   %ax,%ax

00800c10 <__udivdi3>:
  800c10:	f3 0f 1e fb          	endbr32 
  800c14:	55                   	push   %ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 1c             	sub    $0x1c,%esp
  800c1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c23:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	75 19                	jne    800c48 <__udivdi3+0x38>
  800c2f:	39 f3                	cmp    %esi,%ebx
  800c31:	76 4d                	jbe    800c80 <__udivdi3+0x70>
  800c33:	31 ff                	xor    %edi,%edi
  800c35:	89 e8                	mov    %ebp,%eax
  800c37:	89 f2                	mov    %esi,%edx
  800c39:	f7 f3                	div    %ebx
  800c3b:	89 fa                	mov    %edi,%edx
  800c3d:	83 c4 1c             	add    $0x1c,%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    
  800c45:	8d 76 00             	lea    0x0(%esi),%esi
  800c48:	39 f0                	cmp    %esi,%eax
  800c4a:	76 14                	jbe    800c60 <__udivdi3+0x50>
  800c4c:	31 ff                	xor    %edi,%edi
  800c4e:	31 c0                	xor    %eax,%eax
  800c50:	89 fa                	mov    %edi,%edx
  800c52:	83 c4 1c             	add    $0x1c,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    
  800c5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c60:	0f bd f8             	bsr    %eax,%edi
  800c63:	83 f7 1f             	xor    $0x1f,%edi
  800c66:	75 48                	jne    800cb0 <__udivdi3+0xa0>
  800c68:	39 f0                	cmp    %esi,%eax
  800c6a:	72 06                	jb     800c72 <__udivdi3+0x62>
  800c6c:	31 c0                	xor    %eax,%eax
  800c6e:	39 eb                	cmp    %ebp,%ebx
  800c70:	77 de                	ja     800c50 <__udivdi3+0x40>
  800c72:	b8 01 00 00 00       	mov    $0x1,%eax
  800c77:	eb d7                	jmp    800c50 <__udivdi3+0x40>
  800c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c80:	89 d9                	mov    %ebx,%ecx
  800c82:	85 db                	test   %ebx,%ebx
  800c84:	75 0b                	jne    800c91 <__udivdi3+0x81>
  800c86:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8b:	31 d2                	xor    %edx,%edx
  800c8d:	f7 f3                	div    %ebx
  800c8f:	89 c1                	mov    %eax,%ecx
  800c91:	31 d2                	xor    %edx,%edx
  800c93:	89 f0                	mov    %esi,%eax
  800c95:	f7 f1                	div    %ecx
  800c97:	89 c6                	mov    %eax,%esi
  800c99:	89 e8                	mov    %ebp,%eax
  800c9b:	89 f7                	mov    %esi,%edi
  800c9d:	f7 f1                	div    %ecx
  800c9f:	89 fa                	mov    %edi,%edx
  800ca1:	83 c4 1c             	add    $0x1c,%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    
  800ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cb0:	89 f9                	mov    %edi,%ecx
  800cb2:	ba 20 00 00 00       	mov    $0x20,%edx
  800cb7:	29 fa                	sub    %edi,%edx
  800cb9:	d3 e0                	shl    %cl,%eax
  800cbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cbf:	89 d1                	mov    %edx,%ecx
  800cc1:	89 d8                	mov    %ebx,%eax
  800cc3:	d3 e8                	shr    %cl,%eax
  800cc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cc9:	09 c1                	or     %eax,%ecx
  800ccb:	89 f0                	mov    %esi,%eax
  800ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cd1:	89 f9                	mov    %edi,%ecx
  800cd3:	d3 e3                	shl    %cl,%ebx
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	d3 e8                	shr    %cl,%eax
  800cd9:	89 f9                	mov    %edi,%ecx
  800cdb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cdf:	89 eb                	mov    %ebp,%ebx
  800ce1:	d3 e6                	shl    %cl,%esi
  800ce3:	89 d1                	mov    %edx,%ecx
  800ce5:	d3 eb                	shr    %cl,%ebx
  800ce7:	09 f3                	or     %esi,%ebx
  800ce9:	89 c6                	mov    %eax,%esi
  800ceb:	89 f2                	mov    %esi,%edx
  800ced:	89 d8                	mov    %ebx,%eax
  800cef:	f7 74 24 08          	divl   0x8(%esp)
  800cf3:	89 d6                	mov    %edx,%esi
  800cf5:	89 c3                	mov    %eax,%ebx
  800cf7:	f7 64 24 0c          	mull   0xc(%esp)
  800cfb:	39 d6                	cmp    %edx,%esi
  800cfd:	72 19                	jb     800d18 <__udivdi3+0x108>
  800cff:	89 f9                	mov    %edi,%ecx
  800d01:	d3 e5                	shl    %cl,%ebp
  800d03:	39 c5                	cmp    %eax,%ebp
  800d05:	73 04                	jae    800d0b <__udivdi3+0xfb>
  800d07:	39 d6                	cmp    %edx,%esi
  800d09:	74 0d                	je     800d18 <__udivdi3+0x108>
  800d0b:	89 d8                	mov    %ebx,%eax
  800d0d:	31 ff                	xor    %edi,%edi
  800d0f:	e9 3c ff ff ff       	jmp    800c50 <__udivdi3+0x40>
  800d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d18:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d1b:	31 ff                	xor    %edi,%edi
  800d1d:	e9 2e ff ff ff       	jmp    800c50 <__udivdi3+0x40>
  800d22:	66 90                	xchg   %ax,%ax
  800d24:	66 90                	xchg   %ax,%ax
  800d26:	66 90                	xchg   %ax,%ax
  800d28:	66 90                	xchg   %ax,%ax
  800d2a:	66 90                	xchg   %ax,%ax
  800d2c:	66 90                	xchg   %ax,%ax
  800d2e:	66 90                	xchg   %ax,%ax

00800d30 <__umoddi3>:
  800d30:	f3 0f 1e fb          	endbr32 
  800d34:	55                   	push   %ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 1c             	sub    $0x1c,%esp
  800d3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d43:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d47:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d4b:	89 f0                	mov    %esi,%eax
  800d4d:	89 da                	mov    %ebx,%edx
  800d4f:	85 ff                	test   %edi,%edi
  800d51:	75 15                	jne    800d68 <__umoddi3+0x38>
  800d53:	39 dd                	cmp    %ebx,%ebp
  800d55:	76 39                	jbe    800d90 <__umoddi3+0x60>
  800d57:	f7 f5                	div    %ebp
  800d59:	89 d0                	mov    %edx,%eax
  800d5b:	31 d2                	xor    %edx,%edx
  800d5d:	83 c4 1c             	add    $0x1c,%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    
  800d65:	8d 76 00             	lea    0x0(%esi),%esi
  800d68:	39 df                	cmp    %ebx,%edi
  800d6a:	77 f1                	ja     800d5d <__umoddi3+0x2d>
  800d6c:	0f bd cf             	bsr    %edi,%ecx
  800d6f:	83 f1 1f             	xor    $0x1f,%ecx
  800d72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d76:	75 40                	jne    800db8 <__umoddi3+0x88>
  800d78:	39 df                	cmp    %ebx,%edi
  800d7a:	72 04                	jb     800d80 <__umoddi3+0x50>
  800d7c:	39 f5                	cmp    %esi,%ebp
  800d7e:	77 dd                	ja     800d5d <__umoddi3+0x2d>
  800d80:	89 da                	mov    %ebx,%edx
  800d82:	89 f0                	mov    %esi,%eax
  800d84:	29 e8                	sub    %ebp,%eax
  800d86:	19 fa                	sbb    %edi,%edx
  800d88:	eb d3                	jmp    800d5d <__umoddi3+0x2d>
  800d8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d90:	89 e9                	mov    %ebp,%ecx
  800d92:	85 ed                	test   %ebp,%ebp
  800d94:	75 0b                	jne    800da1 <__umoddi3+0x71>
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	f7 f5                	div    %ebp
  800d9f:	89 c1                	mov    %eax,%ecx
  800da1:	89 d8                	mov    %ebx,%eax
  800da3:	31 d2                	xor    %edx,%edx
  800da5:	f7 f1                	div    %ecx
  800da7:	89 f0                	mov    %esi,%eax
  800da9:	f7 f1                	div    %ecx
  800dab:	89 d0                	mov    %edx,%eax
  800dad:	31 d2                	xor    %edx,%edx
  800daf:	eb ac                	jmp    800d5d <__umoddi3+0x2d>
  800db1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dbc:	ba 20 00 00 00       	mov    $0x20,%edx
  800dc1:	29 c2                	sub    %eax,%edx
  800dc3:	89 c1                	mov    %eax,%ecx
  800dc5:	89 e8                	mov    %ebp,%eax
  800dc7:	d3 e7                	shl    %cl,%edi
  800dc9:	89 d1                	mov    %edx,%ecx
  800dcb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dcf:	d3 e8                	shr    %cl,%eax
  800dd1:	89 c1                	mov    %eax,%ecx
  800dd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dd7:	09 f9                	or     %edi,%ecx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ddf:	89 c1                	mov    %eax,%ecx
  800de1:	d3 e5                	shl    %cl,%ebp
  800de3:	89 d1                	mov    %edx,%ecx
  800de5:	d3 ef                	shr    %cl,%edi
  800de7:	89 c1                	mov    %eax,%ecx
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	d3 e3                	shl    %cl,%ebx
  800ded:	89 d1                	mov    %edx,%ecx
  800def:	89 fa                	mov    %edi,%edx
  800df1:	d3 e8                	shr    %cl,%eax
  800df3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800df8:	09 d8                	or     %ebx,%eax
  800dfa:	f7 74 24 08          	divl   0x8(%esp)
  800dfe:	89 d3                	mov    %edx,%ebx
  800e00:	d3 e6                	shl    %cl,%esi
  800e02:	f7 e5                	mul    %ebp
  800e04:	89 c7                	mov    %eax,%edi
  800e06:	89 d1                	mov    %edx,%ecx
  800e08:	39 d3                	cmp    %edx,%ebx
  800e0a:	72 06                	jb     800e12 <__umoddi3+0xe2>
  800e0c:	75 0e                	jne    800e1c <__umoddi3+0xec>
  800e0e:	39 c6                	cmp    %eax,%esi
  800e10:	73 0a                	jae    800e1c <__umoddi3+0xec>
  800e12:	29 e8                	sub    %ebp,%eax
  800e14:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e18:	89 d1                	mov    %edx,%ecx
  800e1a:	89 c7                	mov    %eax,%edi
  800e1c:	89 f5                	mov    %esi,%ebp
  800e1e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e22:	29 fd                	sub    %edi,%ebp
  800e24:	19 cb                	sbb    %ecx,%ebx
  800e26:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e2b:	89 d8                	mov    %ebx,%eax
  800e2d:	d3 e0                	shl    %cl,%eax
  800e2f:	89 f1                	mov    %esi,%ecx
  800e31:	d3 ed                	shr    %cl,%ebp
  800e33:	d3 eb                	shr    %cl,%ebx
  800e35:	09 e8                	or     %ebp,%eax
  800e37:	89 da                	mov    %ebx,%edx
  800e39:	83 c4 1c             	add    $0x1c,%esp
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    
