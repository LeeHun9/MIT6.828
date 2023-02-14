
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 32 00 00 00       	call   800063 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 20 00 00 00       	call   80005f <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800045:	ff 35 00 00 00 00    	push   0x0
  80004b:	8d 83 34 ee ff ff    	lea    -0x11cc(%ebx),%eax
  800051:	50                   	push   %eax
  800052:	e8 23 01 00 00       	call   80017a <cprintf>
}
  800057:	83 c4 10             	add    $0x10,%esp
  80005a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <__x86.get_pc_thunk.bx>:
  80005f:	8b 1c 24             	mov    (%esp),%ebx
  800062:	c3                   	ret    

00800063 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	53                   	push   %ebx
  800067:	83 ec 04             	sub    $0x4,%esp
  80006a:	e8 f0 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  80006f:	81 c3 91 1f 00 00    	add    $0x1f91,%ebx
  800075:	8b 45 08             	mov    0x8(%ebp),%eax
  800078:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80007b:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  800082:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	7e 08                	jle    800091 <libmain+0x2e>
		binaryname = argv[0];
  800089:	8b 0a                	mov    (%edx),%ecx
  80008b:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800091:	83 ec 08             	sub    $0x8,%esp
  800094:	52                   	push   %edx
  800095:	50                   	push   %eax
  800096:	e8 98 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009b:	e8 08 00 00 00       	call   8000a8 <exit>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 10             	sub    $0x10,%esp
  8000af:	e8 ab ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000b4:	81 c3 4c 1f 00 00    	add    $0x1f4c,%ebx
	sys_env_destroy(0);
  8000ba:	6a 00                	push   $0x0
  8000bc:	e8 6a 0a 00 00       	call   800b2b <sys_env_destroy>
}
  8000c1:	83 c4 10             	add    $0x10,%esp
  8000c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
  8000ce:	e8 8c ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000d3:	81 c3 2d 1f 00 00    	add    $0x1f2d,%ebx
  8000d9:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000dc:	8b 16                	mov    (%esi),%edx
  8000de:	8d 42 01             	lea    0x1(%edx),%eax
  8000e1:	89 06                	mov    %eax,(%esi)
  8000e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e6:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8000ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ef:	74 0b                	je     8000fc <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f1:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8000f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5d                   	pop    %ebp
  8000fb:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	68 ff 00 00 00       	push   $0xff
  800104:	8d 46 08             	lea    0x8(%esi),%eax
  800107:	50                   	push   %eax
  800108:	e8 e1 09 00 00       	call   800aee <sys_cputs>
		b->idx = 0;
  80010d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800113:	83 c4 10             	add    $0x10,%esp
  800116:	eb d9                	jmp    8000f1 <putch+0x28>

00800118 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	53                   	push   %ebx
  80011c:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800122:	e8 38 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800127:	81 c3 d9 1e 00 00    	add    $0x1ed9,%ebx
	struct printbuf b;

	b.idx = 0;
  80012d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800134:	00 00 00 
	b.cnt = 0;
  800137:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800141:	ff 75 0c             	push   0xc(%ebp)
  800144:	ff 75 08             	push   0x8(%ebp)
  800147:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014d:	50                   	push   %eax
  80014e:	8d 83 c9 e0 ff ff    	lea    -0x1f37(%ebx),%eax
  800154:	50                   	push   %eax
  800155:	e8 2c 01 00 00       	call   800286 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015a:	83 c4 08             	add    $0x8,%esp
  80015d:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800163:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800169:	50                   	push   %eax
  80016a:	e8 7f 09 00 00       	call   800aee <sys_cputs>

	return b.cnt;
}
  80016f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800175:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800178:	c9                   	leave  
  800179:	c3                   	ret    

0080017a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800180:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800183:	50                   	push   %eax
  800184:	ff 75 08             	push   0x8(%ebp)
  800187:	e8 8c ff ff ff       	call   800118 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    

0080018e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
  800194:	83 ec 2c             	sub    $0x2c,%esp
  800197:	e8 d3 05 00 00       	call   80076f <__x86.get_pc_thunk.cx>
  80019c:	81 c1 64 1e 00 00    	add    $0x1e64,%ecx
  8001a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a5:	89 c7                	mov    %eax,%edi
  8001a7:	89 d6                	mov    %edx,%esi
  8001a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001af:	89 d1                	mov    %edx,%ecx
  8001b1:	89 c2                	mov    %eax,%edx
  8001b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001b6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8001b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001c9:	39 c2                	cmp    %eax,%edx
  8001cb:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ce:	72 41                	jb     800211 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	ff 75 18             	push   0x18(%ebp)
  8001d6:	83 eb 01             	sub    $0x1,%ebx
  8001d9:	53                   	push   %ebx
  8001da:	50                   	push   %eax
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	ff 75 e4             	push   -0x1c(%ebp)
  8001e1:	ff 75 e0             	push   -0x20(%ebp)
  8001e4:	ff 75 d4             	push   -0x2c(%ebp)
  8001e7:	ff 75 d0             	push   -0x30(%ebp)
  8001ea:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001ed:	e8 0e 0a 00 00       	call   800c00 <__udivdi3>
  8001f2:	83 c4 18             	add    $0x18,%esp
  8001f5:	52                   	push   %edx
  8001f6:	50                   	push   %eax
  8001f7:	89 f2                	mov    %esi,%edx
  8001f9:	89 f8                	mov    %edi,%eax
  8001fb:	e8 8e ff ff ff       	call   80018e <printnum>
  800200:	83 c4 20             	add    $0x20,%esp
  800203:	eb 13                	jmp    800218 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	56                   	push   %esi
  800209:	ff 75 18             	push   0x18(%ebp)
  80020c:	ff d7                	call   *%edi
  80020e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800211:	83 eb 01             	sub    $0x1,%ebx
  800214:	85 db                	test   %ebx,%ebx
  800216:	7f ed                	jg     800205 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	56                   	push   %esi
  80021c:	83 ec 04             	sub    $0x4,%esp
  80021f:	ff 75 e4             	push   -0x1c(%ebp)
  800222:	ff 75 e0             	push   -0x20(%ebp)
  800225:	ff 75 d4             	push   -0x2c(%ebp)
  800228:	ff 75 d0             	push   -0x30(%ebp)
  80022b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80022e:	e8 ed 0a 00 00       	call   800d20 <__umoddi3>
  800233:	83 c4 14             	add    $0x14,%esp
  800236:	0f be 84 03 5c ee ff 	movsbl -0x11a4(%ebx,%eax,1),%eax
  80023d:	ff 
  80023e:	50                   	push   %eax
  80023f:	ff d7                	call   *%edi
}
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    

0080024c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800252:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800256:	8b 10                	mov    (%eax),%edx
  800258:	3b 50 04             	cmp    0x4(%eax),%edx
  80025b:	73 0a                	jae    800267 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800260:	89 08                	mov    %ecx,(%eax)
  800262:	8b 45 08             	mov    0x8(%ebp),%eax
  800265:	88 02                	mov    %al,(%edx)
}
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    

00800269 <printfmt>:
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80026f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800272:	50                   	push   %eax
  800273:	ff 75 10             	push   0x10(%ebp)
  800276:	ff 75 0c             	push   0xc(%ebp)
  800279:	ff 75 08             	push   0x8(%ebp)
  80027c:	e8 05 00 00 00       	call   800286 <vprintfmt>
}
  800281:	83 c4 10             	add    $0x10,%esp
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <vprintfmt>:
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	57                   	push   %edi
  80028a:	56                   	push   %esi
  80028b:	53                   	push   %ebx
  80028c:	83 ec 3c             	sub    $0x3c,%esp
  80028f:	e8 d7 04 00 00       	call   80076b <__x86.get_pc_thunk.ax>
  800294:	05 6c 1d 00 00       	add    $0x1d6c,%eax
  800299:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029c:	8b 75 08             	mov    0x8(%ebp),%esi
  80029f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8002a5:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8002ab:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002ae:	eb 0a                	jmp    8002ba <vprintfmt+0x34>
			putch(ch, putdat);
  8002b0:	83 ec 08             	sub    $0x8,%esp
  8002b3:	57                   	push   %edi
  8002b4:	50                   	push   %eax
  8002b5:	ff d6                	call   *%esi
  8002b7:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ba:	83 c3 01             	add    $0x1,%ebx
  8002bd:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8002c1:	83 f8 25             	cmp    $0x25,%eax
  8002c4:	74 0c                	je     8002d2 <vprintfmt+0x4c>
			if (ch == '\0')
  8002c6:	85 c0                	test   %eax,%eax
  8002c8:	75 e6                	jne    8002b0 <vprintfmt+0x2a>
}
  8002ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    
		padc = ' ';
  8002d2:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8002d6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002dd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8002eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8002f3:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002f6:	8d 43 01             	lea    0x1(%ebx),%eax
  8002f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fc:	0f b6 13             	movzbl (%ebx),%edx
  8002ff:	8d 42 dd             	lea    -0x23(%edx),%eax
  800302:	3c 55                	cmp    $0x55,%al
  800304:	0f 87 c5 03 00 00    	ja     8006cf <.L20>
  80030a:	0f b6 c0             	movzbl %al,%eax
  80030d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800310:	89 ce                	mov    %ecx,%esi
  800312:	03 b4 81 ec ee ff ff 	add    -0x1114(%ecx,%eax,4),%esi
  800319:	ff e6                	jmp    *%esi

0080031b <.L66>:
  80031b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80031e:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800322:	eb d2                	jmp    8002f6 <vprintfmt+0x70>

00800324 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800327:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  80032b:	eb c9                	jmp    8002f6 <vprintfmt+0x70>

0080032d <.L31>:
  80032d:	0f b6 d2             	movzbl %dl,%edx
  800330:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800333:	b8 00 00 00 00       	mov    $0x0,%eax
  800338:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  80033b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800342:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800345:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800348:	83 f9 09             	cmp    $0x9,%ecx
  80034b:	77 58                	ja     8003a5 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80034d:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800350:	eb e9                	jmp    80033b <.L31+0xe>

00800352 <.L34>:
			precision = va_arg(ap, int);
  800352:	8b 45 14             	mov    0x14(%ebp),%eax
  800355:	8b 00                	mov    (%eax),%eax
  800357:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8d 40 04             	lea    0x4(%eax),%eax
  800360:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800363:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800366:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80036a:	79 8a                	jns    8002f6 <vprintfmt+0x70>
				width = precision, precision = -1;
  80036c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80036f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800372:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800379:	e9 78 ff ff ff       	jmp    8002f6 <vprintfmt+0x70>

0080037e <.L33>:
  80037e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800381:	85 d2                	test   %edx,%edx
  800383:	b8 00 00 00 00       	mov    $0x0,%eax
  800388:	0f 49 c2             	cmovns %edx,%eax
  80038b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800391:	e9 60 ff ff ff       	jmp    8002f6 <vprintfmt+0x70>

00800396 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800399:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003a0:	e9 51 ff ff ff       	jmp    8002f6 <vprintfmt+0x70>
  8003a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8003ab:	eb b9                	jmp    800366 <.L34+0x14>

008003ad <.L27>:
			lflag++;
  8003ad:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003b4:	e9 3d ff ff ff       	jmp    8002f6 <vprintfmt+0x70>

008003b9 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8d 58 04             	lea    0x4(%eax),%ebx
  8003c2:	83 ec 08             	sub    $0x8,%esp
  8003c5:	57                   	push   %edi
  8003c6:	ff 30                	push   (%eax)
  8003c8:	ff d6                	call   *%esi
			break;
  8003ca:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003cd:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8003d0:	e9 90 02 00 00       	jmp    800665 <.L25+0x45>

008003d5 <.L28>:
			err = va_arg(ap, int);
  8003d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8d 58 04             	lea    0x4(%eax),%ebx
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	89 d0                	mov    %edx,%eax
  8003e2:	f7 d8                	neg    %eax
  8003e4:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e7:	83 f8 06             	cmp    $0x6,%eax
  8003ea:	7f 27                	jg     800413 <.L28+0x3e>
  8003ec:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8003ef:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8003f2:	85 d2                	test   %edx,%edx
  8003f4:	74 1d                	je     800413 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8003f6:	52                   	push   %edx
  8003f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fa:	8d 80 7d ee ff ff    	lea    -0x1183(%eax),%eax
  800400:	50                   	push   %eax
  800401:	57                   	push   %edi
  800402:	56                   	push   %esi
  800403:	e8 61 fe ff ff       	call   800269 <printfmt>
  800408:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80040b:	89 5d 14             	mov    %ebx,0x14(%ebp)
  80040e:	e9 52 02 00 00       	jmp    800665 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800413:	50                   	push   %eax
  800414:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800417:	8d 80 74 ee ff ff    	lea    -0x118c(%eax),%eax
  80041d:	50                   	push   %eax
  80041e:	57                   	push   %edi
  80041f:	56                   	push   %esi
  800420:	e8 44 fe ff ff       	call   800269 <printfmt>
  800425:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800428:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80042b:	e9 35 02 00 00       	jmp    800665 <.L25+0x45>

00800430 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800430:	8b 75 08             	mov    0x8(%ebp),%esi
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	83 c0 04             	add    $0x4,%eax
  800439:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80043c:	8b 45 14             	mov    0x14(%ebp),%eax
  80043f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800441:	85 d2                	test   %edx,%edx
  800443:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800446:	8d 80 6d ee ff ff    	lea    -0x1193(%eax),%eax
  80044c:	0f 45 c2             	cmovne %edx,%eax
  80044f:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800452:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800456:	7e 06                	jle    80045e <.L24+0x2e>
  800458:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  80045c:	75 0d                	jne    80046b <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800461:	89 c3                	mov    %eax,%ebx
  800463:	03 45 d0             	add    -0x30(%ebp),%eax
  800466:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800469:	eb 58                	jmp    8004c3 <.L24+0x93>
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	ff 75 d8             	push   -0x28(%ebp)
  800471:	ff 75 c8             	push   -0x38(%ebp)
  800474:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800477:	e8 0f 03 00 00       	call   80078b <strnlen>
  80047c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80047f:	29 c2                	sub    %eax,%edx
  800481:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800484:	83 c4 10             	add    $0x10,%esp
  800487:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800489:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80048d:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800490:	eb 0f                	jmp    8004a1 <.L24+0x71>
					putch(padc, putdat);
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	57                   	push   %edi
  800496:	ff 75 d0             	push   -0x30(%ebp)
  800499:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	83 eb 01             	sub    $0x1,%ebx
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	85 db                	test   %ebx,%ebx
  8004a3:	7f ed                	jg     800492 <.L24+0x62>
  8004a5:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8004a8:	85 d2                	test   %edx,%edx
  8004aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004af:	0f 49 c2             	cmovns %edx,%eax
  8004b2:	29 c2                	sub    %eax,%edx
  8004b4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004b7:	eb a5                	jmp    80045e <.L24+0x2e>
					putch(ch, putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	57                   	push   %edi
  8004bd:	52                   	push   %edx
  8004be:	ff d6                	call   *%esi
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004c6:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c8:	83 c3 01             	add    $0x1,%ebx
  8004cb:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8004cf:	0f be d0             	movsbl %al,%edx
  8004d2:	85 d2                	test   %edx,%edx
  8004d4:	74 4b                	je     800521 <.L24+0xf1>
  8004d6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004da:	78 06                	js     8004e2 <.L24+0xb2>
  8004dc:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004e0:	78 1e                	js     800500 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004e6:	74 d1                	je     8004b9 <.L24+0x89>
  8004e8:	0f be c0             	movsbl %al,%eax
  8004eb:	83 e8 20             	sub    $0x20,%eax
  8004ee:	83 f8 5e             	cmp    $0x5e,%eax
  8004f1:	76 c6                	jbe    8004b9 <.L24+0x89>
					putch('?', putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	57                   	push   %edi
  8004f7:	6a 3f                	push   $0x3f
  8004f9:	ff d6                	call   *%esi
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	eb c3                	jmp    8004c3 <.L24+0x93>
  800500:	89 cb                	mov    %ecx,%ebx
  800502:	eb 0e                	jmp    800512 <.L24+0xe2>
				putch(' ', putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	57                   	push   %edi
  800508:	6a 20                	push   $0x20
  80050a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80050c:	83 eb 01             	sub    $0x1,%ebx
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	85 db                	test   %ebx,%ebx
  800514:	7f ee                	jg     800504 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800516:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800519:	89 45 14             	mov    %eax,0x14(%ebp)
  80051c:	e9 44 01 00 00       	jmp    800665 <.L25+0x45>
  800521:	89 cb                	mov    %ecx,%ebx
  800523:	eb ed                	jmp    800512 <.L24+0xe2>

00800525 <.L29>:
	if (lflag >= 2)
  800525:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800528:	8b 75 08             	mov    0x8(%ebp),%esi
  80052b:	83 f9 01             	cmp    $0x1,%ecx
  80052e:	7f 1b                	jg     80054b <.L29+0x26>
	else if (lflag)
  800530:	85 c9                	test   %ecx,%ecx
  800532:	74 63                	je     800597 <.L29+0x72>
		return va_arg(*ap, long);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053c:	99                   	cltd   
  80053d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 40 04             	lea    0x4(%eax),%eax
  800546:	89 45 14             	mov    %eax,0x14(%ebp)
  800549:	eb 17                	jmp    800562 <.L29+0x3d>
		return va_arg(*ap, long long);
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8b 50 04             	mov    0x4(%eax),%edx
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800556:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 40 08             	lea    0x8(%eax),%eax
  80055f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800562:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800565:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800568:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80056d:	85 db                	test   %ebx,%ebx
  80056f:	0f 89 d6 00 00 00    	jns    80064b <.L25+0x2b>
				putch('-', putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	57                   	push   %edi
  800579:	6a 2d                	push   $0x2d
  80057b:	ff d6                	call   *%esi
				num = -(long long) num;
  80057d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800580:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800583:	f7 d9                	neg    %ecx
  800585:	83 d3 00             	adc    $0x0,%ebx
  800588:	f7 db                	neg    %ebx
  80058a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80058d:	ba 0a 00 00 00       	mov    $0xa,%edx
  800592:	e9 b4 00 00 00       	jmp    80064b <.L25+0x2b>
		return va_arg(*ap, int);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059f:	99                   	cltd   
  8005a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 40 04             	lea    0x4(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ac:	eb b4                	jmp    800562 <.L29+0x3d>

008005ae <.L23>:
	if (lflag >= 2)
  8005ae:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b4:	83 f9 01             	cmp    $0x1,%ecx
  8005b7:	7f 1b                	jg     8005d4 <.L23+0x26>
	else if (lflag)
  8005b9:	85 c9                	test   %ecx,%ecx
  8005bb:	74 2c                	je     8005e9 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8b 08                	mov    (%eax),%ecx
  8005c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005c7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cd:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8005d2:	eb 77                	jmp    80064b <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8b 08                	mov    (%eax),%ecx
  8005d9:	8b 58 04             	mov    0x4(%eax),%ebx
  8005dc:	8d 40 08             	lea    0x8(%eax),%eax
  8005df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e2:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8005e7:	eb 62                	jmp    80064b <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 08                	mov    (%eax),%ecx
  8005ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f3:	8d 40 04             	lea    0x4(%eax),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f9:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8005fe:	eb 4b                	jmp    80064b <.L25+0x2b>

00800600 <.L26>:
			putch('X', putdat);
  800600:	8b 75 08             	mov    0x8(%ebp),%esi
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	57                   	push   %edi
  800607:	6a 58                	push   $0x58
  800609:	ff d6                	call   *%esi
			putch('X', putdat);
  80060b:	83 c4 08             	add    $0x8,%esp
  80060e:	57                   	push   %edi
  80060f:	6a 58                	push   $0x58
  800611:	ff d6                	call   *%esi
			putch('X', putdat);
  800613:	83 c4 08             	add    $0x8,%esp
  800616:	57                   	push   %edi
  800617:	6a 58                	push   $0x58
  800619:	ff d6                	call   *%esi
			break;
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	eb 45                	jmp    800665 <.L25+0x45>

00800620 <.L25>:
			putch('0', putdat);
  800620:	8b 75 08             	mov    0x8(%ebp),%esi
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	57                   	push   %edi
  800627:	6a 30                	push   $0x30
  800629:	ff d6                	call   *%esi
			putch('x', putdat);
  80062b:	83 c4 08             	add    $0x8,%esp
  80062e:	57                   	push   %edi
  80062f:	6a 78                	push   $0x78
  800631:	ff d6                	call   *%esi
			num = (unsigned long long)
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8b 08                	mov    (%eax),%ecx
  800638:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80063d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800640:	8d 40 04             	lea    0x4(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800646:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  80064b:	83 ec 0c             	sub    $0xc,%esp
  80064e:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800652:	50                   	push   %eax
  800653:	ff 75 d0             	push   -0x30(%ebp)
  800656:	52                   	push   %edx
  800657:	53                   	push   %ebx
  800658:	51                   	push   %ecx
  800659:	89 fa                	mov    %edi,%edx
  80065b:	89 f0                	mov    %esi,%eax
  80065d:	e8 2c fb ff ff       	call   80018e <printnum>
			break;
  800662:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800665:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800668:	e9 4d fc ff ff       	jmp    8002ba <vprintfmt+0x34>

0080066d <.L21>:
	if (lflag >= 2)
  80066d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800670:	8b 75 08             	mov    0x8(%ebp),%esi
  800673:	83 f9 01             	cmp    $0x1,%ecx
  800676:	7f 1b                	jg     800693 <.L21+0x26>
	else if (lflag)
  800678:	85 c9                	test   %ecx,%ecx
  80067a:	74 2c                	je     8006a8 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 08                	mov    (%eax),%ecx
  800681:	bb 00 00 00 00       	mov    $0x0,%ebx
  800686:	8d 40 04             	lea    0x4(%eax),%eax
  800689:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068c:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  800691:	eb b8                	jmp    80064b <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 08                	mov    (%eax),%ecx
  800698:	8b 58 04             	mov    0x4(%eax),%ebx
  80069b:	8d 40 08             	lea    0x8(%eax),%eax
  80069e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a1:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8006a6:	eb a3                	jmp    80064b <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 08                	mov    (%eax),%ecx
  8006ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b8:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8006bd:	eb 8c                	jmp    80064b <.L25+0x2b>

008006bf <.L35>:
			putch(ch, putdat);
  8006bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	57                   	push   %edi
  8006c6:	6a 25                	push   $0x25
  8006c8:	ff d6                	call   *%esi
			break;
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	eb 96                	jmp    800665 <.L25+0x45>

008006cf <.L20>:
			putch('%', putdat);
  8006cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	57                   	push   %edi
  8006d6:	6a 25                	push   $0x25
  8006d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	89 d8                	mov    %ebx,%eax
  8006df:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e3:	74 05                	je     8006ea <.L20+0x1b>
  8006e5:	83 e8 01             	sub    $0x1,%eax
  8006e8:	eb f5                	jmp    8006df <.L20+0x10>
  8006ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ed:	e9 73 ff ff ff       	jmp    800665 <.L25+0x45>

008006f2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	53                   	push   %ebx
  8006f6:	83 ec 14             	sub    $0x14,%esp
  8006f9:	e8 61 f9 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8006fe:	81 c3 02 19 00 00    	add    $0x1902,%ebx
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800711:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800714:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071b:	85 c0                	test   %eax,%eax
  80071d:	74 2b                	je     80074a <vsnprintf+0x58>
  80071f:	85 d2                	test   %edx,%edx
  800721:	7e 27                	jle    80074a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800723:	ff 75 14             	push   0x14(%ebp)
  800726:	ff 75 10             	push   0x10(%ebp)
  800729:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072c:	50                   	push   %eax
  80072d:	8d 83 4c e2 ff ff    	lea    -0x1db4(%ebx),%eax
  800733:	50                   	push   %eax
  800734:	e8 4d fb ff ff       	call   800286 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800739:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800742:	83 c4 10             	add    $0x10,%esp
}
  800745:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800748:	c9                   	leave  
  800749:	c3                   	ret    
		return -E_INVAL;
  80074a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074f:	eb f4                	jmp    800745 <vsnprintf+0x53>

00800751 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075a:	50                   	push   %eax
  80075b:	ff 75 10             	push   0x10(%ebp)
  80075e:	ff 75 0c             	push   0xc(%ebp)
  800761:	ff 75 08             	push   0x8(%ebp)
  800764:	e8 89 ff ff ff       	call   8006f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <__x86.get_pc_thunk.ax>:
  80076b:	8b 04 24             	mov    (%esp),%eax
  80076e:	c3                   	ret    

0080076f <__x86.get_pc_thunk.cx>:
  80076f:	8b 0c 24             	mov    (%esp),%ecx
  800772:	c3                   	ret    

00800773 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800779:	b8 00 00 00 00       	mov    $0x0,%eax
  80077e:	eb 03                	jmp    800783 <strlen+0x10>
		n++;
  800780:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800783:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800787:	75 f7                	jne    800780 <strlen+0xd>
	return n;
}
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800791:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800794:	b8 00 00 00 00       	mov    $0x0,%eax
  800799:	eb 03                	jmp    80079e <strnlen+0x13>
		n++;
  80079b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079e:	39 d0                	cmp    %edx,%eax
  8007a0:	74 08                	je     8007aa <strnlen+0x1f>
  8007a2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a6:	75 f3                	jne    80079b <strnlen+0x10>
  8007a8:	89 c2                	mov    %eax,%edx
	return n;
}
  8007aa:	89 d0                	mov    %edx,%eax
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	53                   	push   %ebx
  8007b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bd:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007c1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007c4:	83 c0 01             	add    $0x1,%eax
  8007c7:	84 d2                	test   %dl,%dl
  8007c9:	75 f2                	jne    8007bd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007cb:	89 c8                	mov    %ecx,%eax
  8007cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	83 ec 10             	sub    $0x10,%esp
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dc:	53                   	push   %ebx
  8007dd:	e8 91 ff ff ff       	call   800773 <strlen>
  8007e2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007e5:	ff 75 0c             	push   0xc(%ebp)
  8007e8:	01 d8                	add    %ebx,%eax
  8007ea:	50                   	push   %eax
  8007eb:	e8 be ff ff ff       	call   8007ae <strcpy>
	return dst;
}
  8007f0:	89 d8                	mov    %ebx,%eax
  8007f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800802:	89 f3                	mov    %esi,%ebx
  800804:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800807:	89 f0                	mov    %esi,%eax
  800809:	eb 0f                	jmp    80081a <strncpy+0x23>
		*dst++ = *src;
  80080b:	83 c0 01             	add    $0x1,%eax
  80080e:	0f b6 0a             	movzbl (%edx),%ecx
  800811:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800814:	80 f9 01             	cmp    $0x1,%cl
  800817:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80081a:	39 d8                	cmp    %ebx,%eax
  80081c:	75 ed                	jne    80080b <strncpy+0x14>
	}
	return ret;
}
  80081e:	89 f0                	mov    %esi,%eax
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082f:	8b 55 10             	mov    0x10(%ebp),%edx
  800832:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	85 d2                	test   %edx,%edx
  800836:	74 21                	je     800859 <strlcpy+0x35>
  800838:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083c:	89 f2                	mov    %esi,%edx
  80083e:	eb 09                	jmp    800849 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800840:	83 c1 01             	add    $0x1,%ecx
  800843:	83 c2 01             	add    $0x1,%edx
  800846:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800849:	39 c2                	cmp    %eax,%edx
  80084b:	74 09                	je     800856 <strlcpy+0x32>
  80084d:	0f b6 19             	movzbl (%ecx),%ebx
  800850:	84 db                	test   %bl,%bl
  800852:	75 ec                	jne    800840 <strlcpy+0x1c>
  800854:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800856:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800859:	29 f0                	sub    %esi,%eax
}
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800865:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800868:	eb 06                	jmp    800870 <strcmp+0x11>
		p++, q++;
  80086a:	83 c1 01             	add    $0x1,%ecx
  80086d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800870:	0f b6 01             	movzbl (%ecx),%eax
  800873:	84 c0                	test   %al,%al
  800875:	74 04                	je     80087b <strcmp+0x1c>
  800877:	3a 02                	cmp    (%edx),%al
  800879:	74 ef                	je     80086a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087b:	0f b6 c0             	movzbl %al,%eax
  80087e:	0f b6 12             	movzbl (%edx),%edx
  800881:	29 d0                	sub    %edx,%eax
}
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088f:	89 c3                	mov    %eax,%ebx
  800891:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800894:	eb 06                	jmp    80089c <strncmp+0x17>
		n--, p++, q++;
  800896:	83 c0 01             	add    $0x1,%eax
  800899:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80089c:	39 d8                	cmp    %ebx,%eax
  80089e:	74 18                	je     8008b8 <strncmp+0x33>
  8008a0:	0f b6 08             	movzbl (%eax),%ecx
  8008a3:	84 c9                	test   %cl,%cl
  8008a5:	74 04                	je     8008ab <strncmp+0x26>
  8008a7:	3a 0a                	cmp    (%edx),%cl
  8008a9:	74 eb                	je     800896 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ab:	0f b6 00             	movzbl (%eax),%eax
  8008ae:	0f b6 12             	movzbl (%edx),%edx
  8008b1:	29 d0                	sub    %edx,%eax
}
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    
		return 0;
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bd:	eb f4                	jmp    8008b3 <strncmp+0x2e>

008008bf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c9:	eb 03                	jmp    8008ce <strchr+0xf>
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	0f b6 10             	movzbl (%eax),%edx
  8008d1:	84 d2                	test   %dl,%dl
  8008d3:	74 06                	je     8008db <strchr+0x1c>
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	75 f2                	jne    8008cb <strchr+0xc>
  8008d9:	eb 05                	jmp    8008e0 <strchr+0x21>
			return (char *) s;
	return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ec:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ef:	38 ca                	cmp    %cl,%dl
  8008f1:	74 09                	je     8008fc <strfind+0x1a>
  8008f3:	84 d2                	test   %dl,%dl
  8008f5:	74 05                	je     8008fc <strfind+0x1a>
	for (; *s; s++)
  8008f7:	83 c0 01             	add    $0x1,%eax
  8008fa:	eb f0                	jmp    8008ec <strfind+0xa>
			break;
	return (char *) s;
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	57                   	push   %edi
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 7d 08             	mov    0x8(%ebp),%edi
  800907:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090a:	85 c9                	test   %ecx,%ecx
  80090c:	74 2f                	je     80093d <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090e:	89 f8                	mov    %edi,%eax
  800910:	09 c8                	or     %ecx,%eax
  800912:	a8 03                	test   $0x3,%al
  800914:	75 21                	jne    800937 <memset+0x39>
		c &= 0xFF;
  800916:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091a:	89 d0                	mov    %edx,%eax
  80091c:	c1 e0 08             	shl    $0x8,%eax
  80091f:	89 d3                	mov    %edx,%ebx
  800921:	c1 e3 18             	shl    $0x18,%ebx
  800924:	89 d6                	mov    %edx,%esi
  800926:	c1 e6 10             	shl    $0x10,%esi
  800929:	09 f3                	or     %esi,%ebx
  80092b:	09 da                	or     %ebx,%edx
  80092d:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800932:	fc                   	cld    
  800933:	f3 ab                	rep stos %eax,%es:(%edi)
  800935:	eb 06                	jmp    80093d <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	fc                   	cld    
  80093b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093d:	89 f8                	mov    %edi,%eax
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	5f                   	pop    %edi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	57                   	push   %edi
  800948:	56                   	push   %esi
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800952:	39 c6                	cmp    %eax,%esi
  800954:	73 32                	jae    800988 <memmove+0x44>
  800956:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800959:	39 c2                	cmp    %eax,%edx
  80095b:	76 2b                	jbe    800988 <memmove+0x44>
		s += n;
		d += n;
  80095d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800960:	89 d6                	mov    %edx,%esi
  800962:	09 fe                	or     %edi,%esi
  800964:	09 ce                	or     %ecx,%esi
  800966:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096c:	75 0e                	jne    80097c <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80096e:	83 ef 04             	sub    $0x4,%edi
  800971:	8d 72 fc             	lea    -0x4(%edx),%esi
  800974:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800977:	fd                   	std    
  800978:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097a:	eb 09                	jmp    800985 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097c:	83 ef 01             	sub    $0x1,%edi
  80097f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800982:	fd                   	std    
  800983:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800985:	fc                   	cld    
  800986:	eb 1a                	jmp    8009a2 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800988:	89 f2                	mov    %esi,%edx
  80098a:	09 c2                	or     %eax,%edx
  80098c:	09 ca                	or     %ecx,%edx
  80098e:	f6 c2 03             	test   $0x3,%dl
  800991:	75 0a                	jne    80099d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800993:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800996:	89 c7                	mov    %eax,%edi
  800998:	fc                   	cld    
  800999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099b:	eb 05                	jmp    8009a2 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	fc                   	cld    
  8009a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a2:	5e                   	pop    %esi
  8009a3:	5f                   	pop    %edi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ac:	ff 75 10             	push   0x10(%ebp)
  8009af:	ff 75 0c             	push   0xc(%ebp)
  8009b2:	ff 75 08             	push   0x8(%ebp)
  8009b5:	e8 8a ff ff ff       	call   800944 <memmove>
}
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c7:	89 c6                	mov    %eax,%esi
  8009c9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cc:	eb 06                	jmp    8009d4 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ce:	83 c0 01             	add    $0x1,%eax
  8009d1:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009d4:	39 f0                	cmp    %esi,%eax
  8009d6:	74 14                	je     8009ec <memcmp+0x30>
		if (*s1 != *s2)
  8009d8:	0f b6 08             	movzbl (%eax),%ecx
  8009db:	0f b6 1a             	movzbl (%edx),%ebx
  8009de:	38 d9                	cmp    %bl,%cl
  8009e0:	74 ec                	je     8009ce <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009e2:	0f b6 c1             	movzbl %cl,%eax
  8009e5:	0f b6 db             	movzbl %bl,%ebx
  8009e8:	29 d8                	sub    %ebx,%eax
  8009ea:	eb 05                	jmp    8009f1 <memcmp+0x35>
	}

	return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	5b                   	pop    %ebx
  8009f2:	5e                   	pop    %esi
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fe:	89 c2                	mov    %eax,%edx
  800a00:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a03:	eb 03                	jmp    800a08 <memfind+0x13>
  800a05:	83 c0 01             	add    $0x1,%eax
  800a08:	39 d0                	cmp    %edx,%eax
  800a0a:	73 04                	jae    800a10 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0c:	38 08                	cmp    %cl,(%eax)
  800a0e:	75 f5                	jne    800a05 <memfind+0x10>
			break;
	return (void *) s;
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	57                   	push   %edi
  800a16:	56                   	push   %esi
  800a17:	53                   	push   %ebx
  800a18:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1e:	eb 03                	jmp    800a23 <strtol+0x11>
		s++;
  800a20:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a23:	0f b6 02             	movzbl (%edx),%eax
  800a26:	3c 20                	cmp    $0x20,%al
  800a28:	74 f6                	je     800a20 <strtol+0xe>
  800a2a:	3c 09                	cmp    $0x9,%al
  800a2c:	74 f2                	je     800a20 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a2e:	3c 2b                	cmp    $0x2b,%al
  800a30:	74 2a                	je     800a5c <strtol+0x4a>
	int neg = 0;
  800a32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a37:	3c 2d                	cmp    $0x2d,%al
  800a39:	74 2b                	je     800a66 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a41:	75 0f                	jne    800a52 <strtol+0x40>
  800a43:	80 3a 30             	cmpb   $0x30,(%edx)
  800a46:	74 28                	je     800a70 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a48:	85 db                	test   %ebx,%ebx
  800a4a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a4f:	0f 44 d8             	cmove  %eax,%ebx
  800a52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a57:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a5a:	eb 46                	jmp    800aa2 <strtol+0x90>
		s++;
  800a5c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a64:	eb d5                	jmp    800a3b <strtol+0x29>
		s++, neg = 1;
  800a66:	83 c2 01             	add    $0x1,%edx
  800a69:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6e:	eb cb                	jmp    800a3b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a70:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a74:	74 0e                	je     800a84 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	75 d8                	jne    800a52 <strtol+0x40>
		s++, base = 8;
  800a7a:	83 c2 01             	add    $0x1,%edx
  800a7d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a82:	eb ce                	jmp    800a52 <strtol+0x40>
		s += 2, base = 16;
  800a84:	83 c2 02             	add    $0x2,%edx
  800a87:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8c:	eb c4                	jmp    800a52 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a8e:	0f be c0             	movsbl %al,%eax
  800a91:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a94:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a97:	7d 3a                	jge    800ad3 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a99:	83 c2 01             	add    $0x1,%edx
  800a9c:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800aa0:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800aa2:	0f b6 02             	movzbl (%edx),%eax
  800aa5:	8d 70 d0             	lea    -0x30(%eax),%esi
  800aa8:	89 f3                	mov    %esi,%ebx
  800aaa:	80 fb 09             	cmp    $0x9,%bl
  800aad:	76 df                	jbe    800a8e <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800aaf:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	80 fb 19             	cmp    $0x19,%bl
  800ab7:	77 08                	ja     800ac1 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ab9:	0f be c0             	movsbl %al,%eax
  800abc:	83 e8 57             	sub    $0x57,%eax
  800abf:	eb d3                	jmp    800a94 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ac1:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ac4:	89 f3                	mov    %esi,%ebx
  800ac6:	80 fb 19             	cmp    $0x19,%bl
  800ac9:	77 08                	ja     800ad3 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800acb:	0f be c0             	movsbl %al,%eax
  800ace:	83 e8 37             	sub    $0x37,%eax
  800ad1:	eb c1                	jmp    800a94 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad7:	74 05                	je     800ade <strtol+0xcc>
		*endptr = (char *) s;
  800ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adc:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ade:	89 c8                	mov    %ecx,%eax
  800ae0:	f7 d8                	neg    %eax
  800ae2:	85 ff                	test   %edi,%edi
  800ae4:	0f 45 c8             	cmovne %eax,%ecx
}
  800ae7:	89 c8                	mov    %ecx,%eax
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
  800af9:	8b 55 08             	mov    0x8(%ebp),%edx
  800afc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aff:	89 c3                	mov    %eax,%ebx
  800b01:	89 c7                	mov    %eax,%edi
  800b03:	89 c6                	mov    %eax,%esi
  800b05:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b12:	ba 00 00 00 00       	mov    $0x0,%edx
  800b17:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1c:	89 d1                	mov    %edx,%ecx
  800b1e:	89 d3                	mov    %edx,%ebx
  800b20:	89 d7                	mov    %edx,%edi
  800b22:	89 d6                	mov    %edx,%esi
  800b24:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	83 ec 1c             	sub    $0x1c,%esp
  800b34:	e8 32 fc ff ff       	call   80076b <__x86.get_pc_thunk.ax>
  800b39:	05 c7 14 00 00       	add    $0x14c7,%eax
  800b3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4e:	89 cb                	mov    %ecx,%ebx
  800b50:	89 cf                	mov    %ecx,%edi
  800b52:	89 ce                	mov    %ecx,%esi
  800b54:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b56:	85 c0                	test   %eax,%eax
  800b58:	7f 08                	jg     800b62 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b62:	83 ec 0c             	sub    $0xc,%esp
  800b65:	50                   	push   %eax
  800b66:	6a 03                	push   $0x3
  800b68:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800b6b:	8d 83 44 f0 ff ff    	lea    -0xfbc(%ebx),%eax
  800b71:	50                   	push   %eax
  800b72:	6a 23                	push   $0x23
  800b74:	8d 83 61 f0 ff ff    	lea    -0xf9f(%ebx),%eax
  800b7a:	50                   	push   %eax
  800b7b:	e8 1f 00 00 00       	call   800b9f <_panic>

00800b80 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b90:	89 d1                	mov    %edx,%ecx
  800b92:	89 d3                	mov    %edx,%ebx
  800b94:	89 d7                	mov    %edx,%edi
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	e8 b2 f4 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800bad:	81 c3 53 14 00 00    	add    $0x1453,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bb3:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bb6:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800bbc:	8b 38                	mov    (%eax),%edi
  800bbe:	e8 bd ff ff ff       	call   800b80 <sys_getenvid>
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	ff 75 0c             	push   0xc(%ebp)
  800bc9:	ff 75 08             	push   0x8(%ebp)
  800bcc:	57                   	push   %edi
  800bcd:	50                   	push   %eax
  800bce:	8d 83 70 f0 ff ff    	lea    -0xf90(%ebx),%eax
  800bd4:	50                   	push   %eax
  800bd5:	e8 a0 f5 ff ff       	call   80017a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bda:	83 c4 18             	add    $0x18,%esp
  800bdd:	56                   	push   %esi
  800bde:	ff 75 10             	push   0x10(%ebp)
  800be1:	e8 32 f5 ff ff       	call   800118 <vcprintf>
	cprintf("\n");
  800be6:	8d 83 50 ee ff ff    	lea    -0x11b0(%ebx),%eax
  800bec:	89 04 24             	mov    %eax,(%esp)
  800bef:	e8 86 f5 ff ff       	call   80017a <cprintf>
  800bf4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800bf7:	cc                   	int3   
  800bf8:	eb fd                	jmp    800bf7 <_panic+0x58>
  800bfa:	66 90                	xchg   %ax,%ax
  800bfc:	66 90                	xchg   %ax,%ax
  800bfe:	66 90                	xchg   %ax,%ax

00800c00 <__udivdi3>:
  800c00:	f3 0f 1e fb          	endbr32 
  800c04:	55                   	push   %ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 1c             	sub    $0x1c,%esp
  800c0b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c13:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	75 19                	jne    800c38 <__udivdi3+0x38>
  800c1f:	39 f3                	cmp    %esi,%ebx
  800c21:	76 4d                	jbe    800c70 <__udivdi3+0x70>
  800c23:	31 ff                	xor    %edi,%edi
  800c25:	89 e8                	mov    %ebp,%eax
  800c27:	89 f2                	mov    %esi,%edx
  800c29:	f7 f3                	div    %ebx
  800c2b:	89 fa                	mov    %edi,%edx
  800c2d:	83 c4 1c             	add    $0x1c,%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    
  800c35:	8d 76 00             	lea    0x0(%esi),%esi
  800c38:	39 f0                	cmp    %esi,%eax
  800c3a:	76 14                	jbe    800c50 <__udivdi3+0x50>
  800c3c:	31 ff                	xor    %edi,%edi
  800c3e:	31 c0                	xor    %eax,%eax
  800c40:	89 fa                	mov    %edi,%edx
  800c42:	83 c4 1c             	add    $0x1c,%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    
  800c4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c50:	0f bd f8             	bsr    %eax,%edi
  800c53:	83 f7 1f             	xor    $0x1f,%edi
  800c56:	75 48                	jne    800ca0 <__udivdi3+0xa0>
  800c58:	39 f0                	cmp    %esi,%eax
  800c5a:	72 06                	jb     800c62 <__udivdi3+0x62>
  800c5c:	31 c0                	xor    %eax,%eax
  800c5e:	39 eb                	cmp    %ebp,%ebx
  800c60:	77 de                	ja     800c40 <__udivdi3+0x40>
  800c62:	b8 01 00 00 00       	mov    $0x1,%eax
  800c67:	eb d7                	jmp    800c40 <__udivdi3+0x40>
  800c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c70:	89 d9                	mov    %ebx,%ecx
  800c72:	85 db                	test   %ebx,%ebx
  800c74:	75 0b                	jne    800c81 <__udivdi3+0x81>
  800c76:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7b:	31 d2                	xor    %edx,%edx
  800c7d:	f7 f3                	div    %ebx
  800c7f:	89 c1                	mov    %eax,%ecx
  800c81:	31 d2                	xor    %edx,%edx
  800c83:	89 f0                	mov    %esi,%eax
  800c85:	f7 f1                	div    %ecx
  800c87:	89 c6                	mov    %eax,%esi
  800c89:	89 e8                	mov    %ebp,%eax
  800c8b:	89 f7                	mov    %esi,%edi
  800c8d:	f7 f1                	div    %ecx
  800c8f:	89 fa                	mov    %edi,%edx
  800c91:	83 c4 1c             	add    $0x1c,%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    
  800c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ca0:	89 f9                	mov    %edi,%ecx
  800ca2:	ba 20 00 00 00       	mov    $0x20,%edx
  800ca7:	29 fa                	sub    %edi,%edx
  800ca9:	d3 e0                	shl    %cl,%eax
  800cab:	89 44 24 08          	mov    %eax,0x8(%esp)
  800caf:	89 d1                	mov    %edx,%ecx
  800cb1:	89 d8                	mov    %ebx,%eax
  800cb3:	d3 e8                	shr    %cl,%eax
  800cb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cb9:	09 c1                	or     %eax,%ecx
  800cbb:	89 f0                	mov    %esi,%eax
  800cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cc1:	89 f9                	mov    %edi,%ecx
  800cc3:	d3 e3                	shl    %cl,%ebx
  800cc5:	89 d1                	mov    %edx,%ecx
  800cc7:	d3 e8                	shr    %cl,%eax
  800cc9:	89 f9                	mov    %edi,%ecx
  800ccb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ccf:	89 eb                	mov    %ebp,%ebx
  800cd1:	d3 e6                	shl    %cl,%esi
  800cd3:	89 d1                	mov    %edx,%ecx
  800cd5:	d3 eb                	shr    %cl,%ebx
  800cd7:	09 f3                	or     %esi,%ebx
  800cd9:	89 c6                	mov    %eax,%esi
  800cdb:	89 f2                	mov    %esi,%edx
  800cdd:	89 d8                	mov    %ebx,%eax
  800cdf:	f7 74 24 08          	divl   0x8(%esp)
  800ce3:	89 d6                	mov    %edx,%esi
  800ce5:	89 c3                	mov    %eax,%ebx
  800ce7:	f7 64 24 0c          	mull   0xc(%esp)
  800ceb:	39 d6                	cmp    %edx,%esi
  800ced:	72 19                	jb     800d08 <__udivdi3+0x108>
  800cef:	89 f9                	mov    %edi,%ecx
  800cf1:	d3 e5                	shl    %cl,%ebp
  800cf3:	39 c5                	cmp    %eax,%ebp
  800cf5:	73 04                	jae    800cfb <__udivdi3+0xfb>
  800cf7:	39 d6                	cmp    %edx,%esi
  800cf9:	74 0d                	je     800d08 <__udivdi3+0x108>
  800cfb:	89 d8                	mov    %ebx,%eax
  800cfd:	31 ff                	xor    %edi,%edi
  800cff:	e9 3c ff ff ff       	jmp    800c40 <__udivdi3+0x40>
  800d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d08:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d0b:	31 ff                	xor    %edi,%edi
  800d0d:	e9 2e ff ff ff       	jmp    800c40 <__udivdi3+0x40>
  800d12:	66 90                	xchg   %ax,%ax
  800d14:	66 90                	xchg   %ax,%ax
  800d16:	66 90                	xchg   %ax,%ax
  800d18:	66 90                	xchg   %ax,%ax
  800d1a:	66 90                	xchg   %ax,%ax
  800d1c:	66 90                	xchg   %ax,%ax
  800d1e:	66 90                	xchg   %ax,%ax

00800d20 <__umoddi3>:
  800d20:	f3 0f 1e fb          	endbr32 
  800d24:	55                   	push   %ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 1c             	sub    $0x1c,%esp
  800d2b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d2f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d33:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d37:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d3b:	89 f0                	mov    %esi,%eax
  800d3d:	89 da                	mov    %ebx,%edx
  800d3f:	85 ff                	test   %edi,%edi
  800d41:	75 15                	jne    800d58 <__umoddi3+0x38>
  800d43:	39 dd                	cmp    %ebx,%ebp
  800d45:	76 39                	jbe    800d80 <__umoddi3+0x60>
  800d47:	f7 f5                	div    %ebp
  800d49:	89 d0                	mov    %edx,%eax
  800d4b:	31 d2                	xor    %edx,%edx
  800d4d:	83 c4 1c             	add    $0x1c,%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    
  800d55:	8d 76 00             	lea    0x0(%esi),%esi
  800d58:	39 df                	cmp    %ebx,%edi
  800d5a:	77 f1                	ja     800d4d <__umoddi3+0x2d>
  800d5c:	0f bd cf             	bsr    %edi,%ecx
  800d5f:	83 f1 1f             	xor    $0x1f,%ecx
  800d62:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d66:	75 40                	jne    800da8 <__umoddi3+0x88>
  800d68:	39 df                	cmp    %ebx,%edi
  800d6a:	72 04                	jb     800d70 <__umoddi3+0x50>
  800d6c:	39 f5                	cmp    %esi,%ebp
  800d6e:	77 dd                	ja     800d4d <__umoddi3+0x2d>
  800d70:	89 da                	mov    %ebx,%edx
  800d72:	89 f0                	mov    %esi,%eax
  800d74:	29 e8                	sub    %ebp,%eax
  800d76:	19 fa                	sbb    %edi,%edx
  800d78:	eb d3                	jmp    800d4d <__umoddi3+0x2d>
  800d7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d80:	89 e9                	mov    %ebp,%ecx
  800d82:	85 ed                	test   %ebp,%ebp
  800d84:	75 0b                	jne    800d91 <__umoddi3+0x71>
  800d86:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	f7 f5                	div    %ebp
  800d8f:	89 c1                	mov    %eax,%ecx
  800d91:	89 d8                	mov    %ebx,%eax
  800d93:	31 d2                	xor    %edx,%edx
  800d95:	f7 f1                	div    %ecx
  800d97:	89 f0                	mov    %esi,%eax
  800d99:	f7 f1                	div    %ecx
  800d9b:	89 d0                	mov    %edx,%eax
  800d9d:	31 d2                	xor    %edx,%edx
  800d9f:	eb ac                	jmp    800d4d <__umoddi3+0x2d>
  800da1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dac:	ba 20 00 00 00       	mov    $0x20,%edx
  800db1:	29 c2                	sub    %eax,%edx
  800db3:	89 c1                	mov    %eax,%ecx
  800db5:	89 e8                	mov    %ebp,%eax
  800db7:	d3 e7                	shl    %cl,%edi
  800db9:	89 d1                	mov    %edx,%ecx
  800dbb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dbf:	d3 e8                	shr    %cl,%eax
  800dc1:	89 c1                	mov    %eax,%ecx
  800dc3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dc7:	09 f9                	or     %edi,%ecx
  800dc9:	89 df                	mov    %ebx,%edi
  800dcb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dcf:	89 c1                	mov    %eax,%ecx
  800dd1:	d3 e5                	shl    %cl,%ebp
  800dd3:	89 d1                	mov    %edx,%ecx
  800dd5:	d3 ef                	shr    %cl,%edi
  800dd7:	89 c1                	mov    %eax,%ecx
  800dd9:	89 f0                	mov    %esi,%eax
  800ddb:	d3 e3                	shl    %cl,%ebx
  800ddd:	89 d1                	mov    %edx,%ecx
  800ddf:	89 fa                	mov    %edi,%edx
  800de1:	d3 e8                	shr    %cl,%eax
  800de3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800de8:	09 d8                	or     %ebx,%eax
  800dea:	f7 74 24 08          	divl   0x8(%esp)
  800dee:	89 d3                	mov    %edx,%ebx
  800df0:	d3 e6                	shl    %cl,%esi
  800df2:	f7 e5                	mul    %ebp
  800df4:	89 c7                	mov    %eax,%edi
  800df6:	89 d1                	mov    %edx,%ecx
  800df8:	39 d3                	cmp    %edx,%ebx
  800dfa:	72 06                	jb     800e02 <__umoddi3+0xe2>
  800dfc:	75 0e                	jne    800e0c <__umoddi3+0xec>
  800dfe:	39 c6                	cmp    %eax,%esi
  800e00:	73 0a                	jae    800e0c <__umoddi3+0xec>
  800e02:	29 e8                	sub    %ebp,%eax
  800e04:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e08:	89 d1                	mov    %edx,%ecx
  800e0a:	89 c7                	mov    %eax,%edi
  800e0c:	89 f5                	mov    %esi,%ebp
  800e0e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e12:	29 fd                	sub    %edi,%ebp
  800e14:	19 cb                	sbb    %ecx,%ebx
  800e16:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e1b:	89 d8                	mov    %ebx,%eax
  800e1d:	d3 e0                	shl    %cl,%eax
  800e1f:	89 f1                	mov    %esi,%ecx
  800e21:	d3 ed                	shr    %cl,%ebp
  800e23:	d3 eb                	shr    %cl,%ebx
  800e25:	09 e8                	or     %ebp,%eax
  800e27:	89 da                	mov    %ebx,%edx
  800e29:	83 c4 1c             	add    $0x1c,%esp
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    
