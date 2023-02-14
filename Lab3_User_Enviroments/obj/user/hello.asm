
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 35 00 00 00       	call   800074 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("hello, world\n");
  800045:	8d 83 44 ee ff ff    	lea    -0x11bc(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 3e 01 00 00       	call   80018f <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800051:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  800057:	8b 00                	mov    (%eax),%eax
  800059:	8b 40 48             	mov    0x48(%eax),%eax
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	50                   	push   %eax
  800060:	8d 83 52 ee ff ff    	lea    -0x11ae(%ebx),%eax
  800066:	50                   	push   %eax
  800067:	e8 23 01 00 00       	call   80018f <cprintf>
}
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <__x86.get_pc_thunk.bx>:
  800074:	8b 1c 24             	mov    (%esp),%ebx
  800077:	c3                   	ret    

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	53                   	push   %ebx
  80007c:	83 ec 04             	sub    $0x4,%esp
  80007f:	e8 f0 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800084:	81 c3 7c 1f 00 00    	add    $0x1f7c,%ebx
  80008a:	8b 45 08             	mov    0x8(%ebp),%eax
  80008d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800090:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  800097:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009a:	85 c0                	test   %eax,%eax
  80009c:	7e 08                	jle    8000a6 <libmain+0x2e>
		binaryname = argv[0];
  80009e:	8b 0a                	mov    (%edx),%ecx
  8000a0:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a6:	83 ec 08             	sub    $0x8,%esp
  8000a9:	52                   	push   %edx
  8000aa:	50                   	push   %eax
  8000ab:	e8 83 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b0:	e8 08 00 00 00       	call   8000bd <exit>
}
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	53                   	push   %ebx
  8000c1:	83 ec 10             	sub    $0x10,%esp
  8000c4:	e8 ab ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000c9:	81 c3 37 1f 00 00    	add    $0x1f37,%ebx
	sys_env_destroy(0);
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 6a 0a 00 00       	call   800b40 <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    

008000de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	e8 8c ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000e8:	81 c3 18 1f 00 00    	add    $0x1f18,%ebx
  8000ee:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000f1:	8b 16                	mov    (%esi),%edx
  8000f3:	8d 42 01             	lea    0x1(%edx),%eax
  8000f6:	89 06                	mov    %eax,(%esi)
  8000f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fb:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8000ff:	3d ff 00 00 00       	cmp    $0xff,%eax
  800104:	74 0b                	je     800111 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800106:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80010a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 ff 00 00 00       	push   $0xff
  800119:	8d 46 08             	lea    0x8(%esi),%eax
  80011c:	50                   	push   %eax
  80011d:	e8 e1 09 00 00       	call   800b03 <sys_cputs>
		b->idx = 0;
  800122:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	eb d9                	jmp    800106 <putch+0x28>

0080012d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	53                   	push   %ebx
  800131:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800137:	e8 38 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  80013c:	81 c3 c4 1e 00 00    	add    $0x1ec4,%ebx
	struct printbuf b;

	b.idx = 0;
  800142:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800149:	00 00 00 
	b.cnt = 0;
  80014c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800153:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800156:	ff 75 0c             	push   0xc(%ebp)
  800159:	ff 75 08             	push   0x8(%ebp)
  80015c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800162:	50                   	push   %eax
  800163:	8d 83 de e0 ff ff    	lea    -0x1f22(%ebx),%eax
  800169:	50                   	push   %eax
  80016a:	e8 2c 01 00 00       	call   80029b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016f:	83 c4 08             	add    $0x8,%esp
  800172:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800178:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017e:	50                   	push   %eax
  80017f:	e8 7f 09 00 00       	call   800b03 <sys_cputs>

	return b.cnt;
}
  800184:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    

0080018f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800195:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800198:	50                   	push   %eax
  800199:	ff 75 08             	push   0x8(%ebp)
  80019c:	e8 8c ff ff ff       	call   80012d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	57                   	push   %edi
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 2c             	sub    $0x2c,%esp
  8001ac:	e8 d3 05 00 00       	call   800784 <__x86.get_pc_thunk.cx>
  8001b1:	81 c1 4f 1e 00 00    	add    $0x1e4f,%ecx
  8001b7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ba:	89 c7                	mov    %eax,%edi
  8001bc:	89 d6                	mov    %edx,%esi
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c4:	89 d1                	mov    %edx,%ecx
  8001c6:	89 c2                	mov    %eax,%edx
  8001c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001cb:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8001ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001de:	39 c2                	cmp    %eax,%edx
  8001e0:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001e3:	72 41                	jb     800226 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e5:	83 ec 0c             	sub    $0xc,%esp
  8001e8:	ff 75 18             	push   0x18(%ebp)
  8001eb:	83 eb 01             	sub    $0x1,%ebx
  8001ee:	53                   	push   %ebx
  8001ef:	50                   	push   %eax
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	ff 75 e4             	push   -0x1c(%ebp)
  8001f6:	ff 75 e0             	push   -0x20(%ebp)
  8001f9:	ff 75 d4             	push   -0x2c(%ebp)
  8001fc:	ff 75 d0             	push   -0x30(%ebp)
  8001ff:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800202:	e8 09 0a 00 00       	call   800c10 <__udivdi3>
  800207:	83 c4 18             	add    $0x18,%esp
  80020a:	52                   	push   %edx
  80020b:	50                   	push   %eax
  80020c:	89 f2                	mov    %esi,%edx
  80020e:	89 f8                	mov    %edi,%eax
  800210:	e8 8e ff ff ff       	call   8001a3 <printnum>
  800215:	83 c4 20             	add    $0x20,%esp
  800218:	eb 13                	jmp    80022d <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021a:	83 ec 08             	sub    $0x8,%esp
  80021d:	56                   	push   %esi
  80021e:	ff 75 18             	push   0x18(%ebp)
  800221:	ff d7                	call   *%edi
  800223:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800226:	83 eb 01             	sub    $0x1,%ebx
  800229:	85 db                	test   %ebx,%ebx
  80022b:	7f ed                	jg     80021a <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022d:	83 ec 08             	sub    $0x8,%esp
  800230:	56                   	push   %esi
  800231:	83 ec 04             	sub    $0x4,%esp
  800234:	ff 75 e4             	push   -0x1c(%ebp)
  800237:	ff 75 e0             	push   -0x20(%ebp)
  80023a:	ff 75 d4             	push   -0x2c(%ebp)
  80023d:	ff 75 d0             	push   -0x30(%ebp)
  800240:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800243:	e8 e8 0a 00 00       	call   800d30 <__umoddi3>
  800248:	83 c4 14             	add    $0x14,%esp
  80024b:	0f be 84 03 73 ee ff 	movsbl -0x118d(%ebx,%eax,1),%eax
  800252:	ff 
  800253:	50                   	push   %eax
  800254:	ff d7                	call   *%edi
}
  800256:	83 c4 10             	add    $0x10,%esp
  800259:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025c:	5b                   	pop    %ebx
  80025d:	5e                   	pop    %esi
  80025e:	5f                   	pop    %edi
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800267:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80026b:	8b 10                	mov    (%eax),%edx
  80026d:	3b 50 04             	cmp    0x4(%eax),%edx
  800270:	73 0a                	jae    80027c <sprintputch+0x1b>
		*b->buf++ = ch;
  800272:	8d 4a 01             	lea    0x1(%edx),%ecx
  800275:	89 08                	mov    %ecx,(%eax)
  800277:	8b 45 08             	mov    0x8(%ebp),%eax
  80027a:	88 02                	mov    %al,(%edx)
}
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <printfmt>:
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800284:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800287:	50                   	push   %eax
  800288:	ff 75 10             	push   0x10(%ebp)
  80028b:	ff 75 0c             	push   0xc(%ebp)
  80028e:	ff 75 08             	push   0x8(%ebp)
  800291:	e8 05 00 00 00       	call   80029b <vprintfmt>
}
  800296:	83 c4 10             	add    $0x10,%esp
  800299:	c9                   	leave  
  80029a:	c3                   	ret    

0080029b <vprintfmt>:
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	57                   	push   %edi
  80029f:	56                   	push   %esi
  8002a0:	53                   	push   %ebx
  8002a1:	83 ec 3c             	sub    $0x3c,%esp
  8002a4:	e8 d7 04 00 00       	call   800780 <__x86.get_pc_thunk.ax>
  8002a9:	05 57 1d 00 00       	add    $0x1d57,%eax
  8002ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8002ba:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8002c0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002c3:	eb 0a                	jmp    8002cf <vprintfmt+0x34>
			putch(ch, putdat);
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	57                   	push   %edi
  8002c9:	50                   	push   %eax
  8002ca:	ff d6                	call   *%esi
  8002cc:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cf:	83 c3 01             	add    $0x1,%ebx
  8002d2:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8002d6:	83 f8 25             	cmp    $0x25,%eax
  8002d9:	74 0c                	je     8002e7 <vprintfmt+0x4c>
			if (ch == '\0')
  8002db:	85 c0                	test   %eax,%eax
  8002dd:	75 e6                	jne    8002c5 <vprintfmt+0x2a>
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    
		padc = ' ';
  8002e7:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8002eb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002f2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  800300:	b9 00 00 00 00       	mov    $0x0,%ecx
  800305:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800308:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030b:	8d 43 01             	lea    0x1(%ebx),%eax
  80030e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800311:	0f b6 13             	movzbl (%ebx),%edx
  800314:	8d 42 dd             	lea    -0x23(%edx),%eax
  800317:	3c 55                	cmp    $0x55,%al
  800319:	0f 87 c5 03 00 00    	ja     8006e4 <.L20>
  80031f:	0f b6 c0             	movzbl %al,%eax
  800322:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800325:	89 ce                	mov    %ecx,%esi
  800327:	03 b4 81 00 ef ff ff 	add    -0x1100(%ecx,%eax,4),%esi
  80032e:	ff e6                	jmp    *%esi

00800330 <.L66>:
  800330:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800333:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800337:	eb d2                	jmp    80030b <vprintfmt+0x70>

00800339 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80033c:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800340:	eb c9                	jmp    80030b <vprintfmt+0x70>

00800342 <.L31>:
  800342:	0f b6 d2             	movzbl %dl,%edx
  800345:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800348:	b8 00 00 00 00       	mov    $0x0,%eax
  80034d:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800350:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800353:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800357:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80035a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80035d:	83 f9 09             	cmp    $0x9,%ecx
  800360:	77 58                	ja     8003ba <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800362:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800365:	eb e9                	jmp    800350 <.L31+0xe>

00800367 <.L34>:
			precision = va_arg(ap, int);
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8b 00                	mov    (%eax),%eax
  80036c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036f:	8b 45 14             	mov    0x14(%ebp),%eax
  800372:	8d 40 04             	lea    0x4(%eax),%eax
  800375:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80037b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80037f:	79 8a                	jns    80030b <vprintfmt+0x70>
				width = precision, precision = -1;
  800381:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800384:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800387:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80038e:	e9 78 ff ff ff       	jmp    80030b <vprintfmt+0x70>

00800393 <.L33>:
  800393:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800396:	85 d2                	test   %edx,%edx
  800398:	b8 00 00 00 00       	mov    $0x0,%eax
  80039d:	0f 49 c2             	cmovns %edx,%eax
  8003a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003a6:	e9 60 ff ff ff       	jmp    80030b <vprintfmt+0x70>

008003ab <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8003ae:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003b5:	e9 51 ff ff ff       	jmp    80030b <vprintfmt+0x70>
  8003ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8003c0:	eb b9                	jmp    80037b <.L34+0x14>

008003c2 <.L27>:
			lflag++;
  8003c2:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003c9:	e9 3d ff ff ff       	jmp    80030b <vprintfmt+0x70>

008003ce <.L30>:
			putch(va_arg(ap, int), putdat);
  8003ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 58 04             	lea    0x4(%eax),%ebx
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	57                   	push   %edi
  8003db:	ff 30                	push   (%eax)
  8003dd:	ff d6                	call   *%esi
			break;
  8003df:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003e2:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8003e5:	e9 90 02 00 00       	jmp    80067a <.L25+0x45>

008003ea <.L28>:
			err = va_arg(ap, int);
  8003ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 58 04             	lea    0x4(%eax),%ebx
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	89 d0                	mov    %edx,%eax
  8003f7:	f7 d8                	neg    %eax
  8003f9:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fc:	83 f8 06             	cmp    $0x6,%eax
  8003ff:	7f 27                	jg     800428 <.L28+0x3e>
  800401:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800404:	8b 14 82             	mov    (%edx,%eax,4),%edx
  800407:	85 d2                	test   %edx,%edx
  800409:	74 1d                	je     800428 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  80040b:	52                   	push   %edx
  80040c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040f:	8d 80 94 ee ff ff    	lea    -0x116c(%eax),%eax
  800415:	50                   	push   %eax
  800416:	57                   	push   %edi
  800417:	56                   	push   %esi
  800418:	e8 61 fe ff ff       	call   80027e <printfmt>
  80041d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800420:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800423:	e9 52 02 00 00       	jmp    80067a <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800428:	50                   	push   %eax
  800429:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042c:	8d 80 8b ee ff ff    	lea    -0x1175(%eax),%eax
  800432:	50                   	push   %eax
  800433:	57                   	push   %edi
  800434:	56                   	push   %esi
  800435:	e8 44 fe ff ff       	call   80027e <printfmt>
  80043a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043d:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800440:	e9 35 02 00 00       	jmp    80067a <.L25+0x45>

00800445 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800445:	8b 75 08             	mov    0x8(%ebp),%esi
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	83 c0 04             	add    $0x4,%eax
  80044e:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800456:	85 d2                	test   %edx,%edx
  800458:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045b:	8d 80 84 ee ff ff    	lea    -0x117c(%eax),%eax
  800461:	0f 45 c2             	cmovne %edx,%eax
  800464:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800467:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80046b:	7e 06                	jle    800473 <.L24+0x2e>
  80046d:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800471:	75 0d                	jne    800480 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800476:	89 c3                	mov    %eax,%ebx
  800478:	03 45 d0             	add    -0x30(%ebp),%eax
  80047b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80047e:	eb 58                	jmp    8004d8 <.L24+0x93>
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	ff 75 d8             	push   -0x28(%ebp)
  800486:	ff 75 c8             	push   -0x38(%ebp)
  800489:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80048c:	e8 0f 03 00 00       	call   8007a0 <strnlen>
  800491:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800494:	29 c2                	sub    %eax,%edx
  800496:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  80049e:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  8004a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	eb 0f                	jmp    8004b6 <.L24+0x71>
					putch(padc, putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	57                   	push   %edi
  8004ab:	ff 75 d0             	push   -0x30(%ebp)
  8004ae:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b0:	83 eb 01             	sub    $0x1,%ebx
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	85 db                	test   %ebx,%ebx
  8004b8:	7f ed                	jg     8004a7 <.L24+0x62>
  8004ba:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8004bd:	85 d2                	test   %edx,%edx
  8004bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c4:	0f 49 c2             	cmovns %edx,%eax
  8004c7:	29 c2                	sub    %eax,%edx
  8004c9:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004cc:	eb a5                	jmp    800473 <.L24+0x2e>
					putch(ch, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	57                   	push   %edi
  8004d2:	52                   	push   %edx
  8004d3:	ff d6                	call   *%esi
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004db:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004dd:	83 c3 01             	add    $0x1,%ebx
  8004e0:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8004e4:	0f be d0             	movsbl %al,%edx
  8004e7:	85 d2                	test   %edx,%edx
  8004e9:	74 4b                	je     800536 <.L24+0xf1>
  8004eb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ef:	78 06                	js     8004f7 <.L24+0xb2>
  8004f1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004f5:	78 1e                	js     800515 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004fb:	74 d1                	je     8004ce <.L24+0x89>
  8004fd:	0f be c0             	movsbl %al,%eax
  800500:	83 e8 20             	sub    $0x20,%eax
  800503:	83 f8 5e             	cmp    $0x5e,%eax
  800506:	76 c6                	jbe    8004ce <.L24+0x89>
					putch('?', putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	57                   	push   %edi
  80050c:	6a 3f                	push   $0x3f
  80050e:	ff d6                	call   *%esi
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	eb c3                	jmp    8004d8 <.L24+0x93>
  800515:	89 cb                	mov    %ecx,%ebx
  800517:	eb 0e                	jmp    800527 <.L24+0xe2>
				putch(' ', putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	57                   	push   %edi
  80051d:	6a 20                	push   $0x20
  80051f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800521:	83 eb 01             	sub    $0x1,%ebx
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	85 db                	test   %ebx,%ebx
  800529:	7f ee                	jg     800519 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  80052b:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80052e:	89 45 14             	mov    %eax,0x14(%ebp)
  800531:	e9 44 01 00 00       	jmp    80067a <.L25+0x45>
  800536:	89 cb                	mov    %ecx,%ebx
  800538:	eb ed                	jmp    800527 <.L24+0xe2>

0080053a <.L29>:
	if (lflag >= 2)
  80053a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	83 f9 01             	cmp    $0x1,%ecx
  800543:	7f 1b                	jg     800560 <.L29+0x26>
	else if (lflag)
  800545:	85 c9                	test   %ecx,%ecx
  800547:	74 63                	je     8005ac <.L29+0x72>
		return va_arg(*ap, long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	99                   	cltd   
  800552:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 40 04             	lea    0x4(%eax),%eax
  80055b:	89 45 14             	mov    %eax,0x14(%ebp)
  80055e:	eb 17                	jmp    800577 <.L29+0x3d>
		return va_arg(*ap, long long);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 50 04             	mov    0x4(%eax),%edx
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8d 40 08             	lea    0x8(%eax),%eax
  800574:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800577:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80057a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80057d:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800582:	85 db                	test   %ebx,%ebx
  800584:	0f 89 d6 00 00 00    	jns    800660 <.L25+0x2b>
				putch('-', putdat);
  80058a:	83 ec 08             	sub    $0x8,%esp
  80058d:	57                   	push   %edi
  80058e:	6a 2d                	push   $0x2d
  800590:	ff d6                	call   *%esi
				num = -(long long) num;
  800592:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800595:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800598:	f7 d9                	neg    %ecx
  80059a:	83 d3 00             	adc    $0x0,%ebx
  80059d:	f7 db                	neg    %ebx
  80059f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a2:	ba 0a 00 00 00       	mov    $0xa,%edx
  8005a7:	e9 b4 00 00 00       	jmp    800660 <.L25+0x2b>
		return va_arg(*ap, int);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	99                   	cltd   
  8005b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 40 04             	lea    0x4(%eax),%eax
  8005be:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c1:	eb b4                	jmp    800577 <.L29+0x3d>

008005c3 <.L23>:
	if (lflag >= 2)
  8005c3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c9:	83 f9 01             	cmp    $0x1,%ecx
  8005cc:	7f 1b                	jg     8005e9 <.L23+0x26>
	else if (lflag)
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	74 2c                	je     8005fe <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 08                	mov    (%eax),%ecx
  8005d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005dc:	8d 40 04             	lea    0x4(%eax),%eax
  8005df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e2:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8005e7:	eb 77                	jmp    800660 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 08                	mov    (%eax),%ecx
  8005ee:	8b 58 04             	mov    0x4(%eax),%ebx
  8005f1:	8d 40 08             	lea    0x8(%eax),%eax
  8005f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f7:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8005fc:	eb 62                	jmp    800660 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8b 08                	mov    (%eax),%ecx
  800603:	bb 00 00 00 00       	mov    $0x0,%ebx
  800608:	8d 40 04             	lea    0x4(%eax),%eax
  80060b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060e:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800613:	eb 4b                	jmp    800660 <.L25+0x2b>

00800615 <.L26>:
			putch('X', putdat);
  800615:	8b 75 08             	mov    0x8(%ebp),%esi
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	57                   	push   %edi
  80061c:	6a 58                	push   $0x58
  80061e:	ff d6                	call   *%esi
			putch('X', putdat);
  800620:	83 c4 08             	add    $0x8,%esp
  800623:	57                   	push   %edi
  800624:	6a 58                	push   $0x58
  800626:	ff d6                	call   *%esi
			putch('X', putdat);
  800628:	83 c4 08             	add    $0x8,%esp
  80062b:	57                   	push   %edi
  80062c:	6a 58                	push   $0x58
  80062e:	ff d6                	call   *%esi
			break;
  800630:	83 c4 10             	add    $0x10,%esp
  800633:	eb 45                	jmp    80067a <.L25+0x45>

00800635 <.L25>:
			putch('0', putdat);
  800635:	8b 75 08             	mov    0x8(%ebp),%esi
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	57                   	push   %edi
  80063c:	6a 30                	push   $0x30
  80063e:	ff d6                	call   *%esi
			putch('x', putdat);
  800640:	83 c4 08             	add    $0x8,%esp
  800643:	57                   	push   %edi
  800644:	6a 78                	push   $0x78
  800646:	ff d6                	call   *%esi
			num = (unsigned long long)
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 08                	mov    (%eax),%ecx
  80064d:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800652:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800655:	8d 40 04             	lea    0x4(%eax),%eax
  800658:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065b:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800660:	83 ec 0c             	sub    $0xc,%esp
  800663:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800667:	50                   	push   %eax
  800668:	ff 75 d0             	push   -0x30(%ebp)
  80066b:	52                   	push   %edx
  80066c:	53                   	push   %ebx
  80066d:	51                   	push   %ecx
  80066e:	89 fa                	mov    %edi,%edx
  800670:	89 f0                	mov    %esi,%eax
  800672:	e8 2c fb ff ff       	call   8001a3 <printnum>
			break;
  800677:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80067a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80067d:	e9 4d fc ff ff       	jmp    8002cf <vprintfmt+0x34>

00800682 <.L21>:
	if (lflag >= 2)
  800682:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800685:	8b 75 08             	mov    0x8(%ebp),%esi
  800688:	83 f9 01             	cmp    $0x1,%ecx
  80068b:	7f 1b                	jg     8006a8 <.L21+0x26>
	else if (lflag)
  80068d:	85 c9                	test   %ecx,%ecx
  80068f:	74 2c                	je     8006bd <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8b 08                	mov    (%eax),%ecx
  800696:	bb 00 00 00 00       	mov    $0x0,%ebx
  80069b:	8d 40 04             	lea    0x4(%eax),%eax
  80069e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a1:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8006a6:	eb b8                	jmp    800660 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 08                	mov    (%eax),%ecx
  8006ad:	8b 58 04             	mov    0x4(%eax),%ebx
  8006b0:	8d 40 08             	lea    0x8(%eax),%eax
  8006b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b6:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8006bb:	eb a3                	jmp    800660 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 08                	mov    (%eax),%ecx
  8006c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cd:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8006d2:	eb 8c                	jmp    800660 <.L25+0x2b>

008006d4 <.L35>:
			putch(ch, putdat);
  8006d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	57                   	push   %edi
  8006db:	6a 25                	push   $0x25
  8006dd:	ff d6                	call   *%esi
			break;
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	eb 96                	jmp    80067a <.L25+0x45>

008006e4 <.L20>:
			putch('%', putdat);
  8006e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	57                   	push   %edi
  8006eb:	6a 25                	push   $0x25
  8006ed:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	89 d8                	mov    %ebx,%eax
  8006f4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006f8:	74 05                	je     8006ff <.L20+0x1b>
  8006fa:	83 e8 01             	sub    $0x1,%eax
  8006fd:	eb f5                	jmp    8006f4 <.L20+0x10>
  8006ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800702:	e9 73 ff ff ff       	jmp    80067a <.L25+0x45>

00800707 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	53                   	push   %ebx
  80070b:	83 ec 14             	sub    $0x14,%esp
  80070e:	e8 61 f9 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800713:	81 c3 ed 18 00 00    	add    $0x18ed,%ebx
  800719:	8b 45 08             	mov    0x8(%ebp),%eax
  80071c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800722:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800726:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800729:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800730:	85 c0                	test   %eax,%eax
  800732:	74 2b                	je     80075f <vsnprintf+0x58>
  800734:	85 d2                	test   %edx,%edx
  800736:	7e 27                	jle    80075f <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800738:	ff 75 14             	push   0x14(%ebp)
  80073b:	ff 75 10             	push   0x10(%ebp)
  80073e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800741:	50                   	push   %eax
  800742:	8d 83 61 e2 ff ff    	lea    -0x1d9f(%ebx),%eax
  800748:	50                   	push   %eax
  800749:	e8 4d fb ff ff       	call   80029b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800751:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800757:	83 c4 10             	add    $0x10,%esp
}
  80075a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    
		return -E_INVAL;
  80075f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800764:	eb f4                	jmp    80075a <vsnprintf+0x53>

00800766 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076f:	50                   	push   %eax
  800770:	ff 75 10             	push   0x10(%ebp)
  800773:	ff 75 0c             	push   0xc(%ebp)
  800776:	ff 75 08             	push   0x8(%ebp)
  800779:	e8 89 ff ff ff       	call   800707 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <__x86.get_pc_thunk.ax>:
  800780:	8b 04 24             	mov    (%esp),%eax
  800783:	c3                   	ret    

00800784 <__x86.get_pc_thunk.cx>:
  800784:	8b 0c 24             	mov    (%esp),%ecx
  800787:	c3                   	ret    

00800788 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	b8 00 00 00 00       	mov    $0x0,%eax
  800793:	eb 03                	jmp    800798 <strlen+0x10>
		n++;
  800795:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800798:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079c:	75 f7                	jne    800795 <strlen+0xd>
	return n;
}
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ae:	eb 03                	jmp    8007b3 <strnlen+0x13>
		n++;
  8007b0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b3:	39 d0                	cmp    %edx,%eax
  8007b5:	74 08                	je     8007bf <strnlen+0x1f>
  8007b7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007bb:	75 f3                	jne    8007b0 <strnlen+0x10>
  8007bd:	89 c2                	mov    %eax,%edx
	return n;
}
  8007bf:	89 d0                	mov    %edx,%eax
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	53                   	push   %ebx
  8007c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d2:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007d6:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007d9:	83 c0 01             	add    $0x1,%eax
  8007dc:	84 d2                	test   %dl,%dl
  8007de:	75 f2                	jne    8007d2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e0:	89 c8                	mov    %ecx,%eax
  8007e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	83 ec 10             	sub    $0x10,%esp
  8007ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f1:	53                   	push   %ebx
  8007f2:	e8 91 ff ff ff       	call   800788 <strlen>
  8007f7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007fa:	ff 75 0c             	push   0xc(%ebp)
  8007fd:	01 d8                	add    %ebx,%eax
  8007ff:	50                   	push   %eax
  800800:	e8 be ff ff ff       	call   8007c3 <strcpy>
	return dst;
}
  800805:	89 d8                	mov    %ebx,%eax
  800807:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080a:	c9                   	leave  
  80080b:	c3                   	ret    

0080080c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	56                   	push   %esi
  800810:	53                   	push   %ebx
  800811:	8b 75 08             	mov    0x8(%ebp),%esi
  800814:	8b 55 0c             	mov    0xc(%ebp),%edx
  800817:	89 f3                	mov    %esi,%ebx
  800819:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081c:	89 f0                	mov    %esi,%eax
  80081e:	eb 0f                	jmp    80082f <strncpy+0x23>
		*dst++ = *src;
  800820:	83 c0 01             	add    $0x1,%eax
  800823:	0f b6 0a             	movzbl (%edx),%ecx
  800826:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800829:	80 f9 01             	cmp    $0x1,%cl
  80082c:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80082f:	39 d8                	cmp    %ebx,%eax
  800831:	75 ed                	jne    800820 <strncpy+0x14>
	}
	return ret;
}
  800833:	89 f0                	mov    %esi,%eax
  800835:	5b                   	pop    %ebx
  800836:	5e                   	pop    %esi
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	8b 75 08             	mov    0x8(%ebp),%esi
  800841:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800844:	8b 55 10             	mov    0x10(%ebp),%edx
  800847:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800849:	85 d2                	test   %edx,%edx
  80084b:	74 21                	je     80086e <strlcpy+0x35>
  80084d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800851:	89 f2                	mov    %esi,%edx
  800853:	eb 09                	jmp    80085e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800855:	83 c1 01             	add    $0x1,%ecx
  800858:	83 c2 01             	add    $0x1,%edx
  80085b:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80085e:	39 c2                	cmp    %eax,%edx
  800860:	74 09                	je     80086b <strlcpy+0x32>
  800862:	0f b6 19             	movzbl (%ecx),%ebx
  800865:	84 db                	test   %bl,%bl
  800867:	75 ec                	jne    800855 <strlcpy+0x1c>
  800869:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80086b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086e:	29 f0                	sub    %esi,%eax
}
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087d:	eb 06                	jmp    800885 <strcmp+0x11>
		p++, q++;
  80087f:	83 c1 01             	add    $0x1,%ecx
  800882:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800885:	0f b6 01             	movzbl (%ecx),%eax
  800888:	84 c0                	test   %al,%al
  80088a:	74 04                	je     800890 <strcmp+0x1c>
  80088c:	3a 02                	cmp    (%edx),%al
  80088e:	74 ef                	je     80087f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800890:	0f b6 c0             	movzbl %al,%eax
  800893:	0f b6 12             	movzbl (%edx),%edx
  800896:	29 d0                	sub    %edx,%eax
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a4:	89 c3                	mov    %eax,%ebx
  8008a6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a9:	eb 06                	jmp    8008b1 <strncmp+0x17>
		n--, p++, q++;
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b1:	39 d8                	cmp    %ebx,%eax
  8008b3:	74 18                	je     8008cd <strncmp+0x33>
  8008b5:	0f b6 08             	movzbl (%eax),%ecx
  8008b8:	84 c9                	test   %cl,%cl
  8008ba:	74 04                	je     8008c0 <strncmp+0x26>
  8008bc:	3a 0a                	cmp    (%edx),%cl
  8008be:	74 eb                	je     8008ab <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c0:	0f b6 00             	movzbl (%eax),%eax
  8008c3:	0f b6 12             	movzbl (%edx),%edx
  8008c6:	29 d0                	sub    %edx,%eax
}
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    
		return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d2:	eb f4                	jmp    8008c8 <strncmp+0x2e>

008008d4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008de:	eb 03                	jmp    8008e3 <strchr+0xf>
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	0f b6 10             	movzbl (%eax),%edx
  8008e6:	84 d2                	test   %dl,%dl
  8008e8:	74 06                	je     8008f0 <strchr+0x1c>
		if (*s == c)
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	75 f2                	jne    8008e0 <strchr+0xc>
  8008ee:	eb 05                	jmp    8008f5 <strchr+0x21>
			return (char *) s;
	return 0;
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800901:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800904:	38 ca                	cmp    %cl,%dl
  800906:	74 09                	je     800911 <strfind+0x1a>
  800908:	84 d2                	test   %dl,%dl
  80090a:	74 05                	je     800911 <strfind+0x1a>
	for (; *s; s++)
  80090c:	83 c0 01             	add    $0x1,%eax
  80090f:	eb f0                	jmp    800901 <strfind+0xa>
			break;
	return (char *) s;
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	57                   	push   %edi
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091f:	85 c9                	test   %ecx,%ecx
  800921:	74 2f                	je     800952 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800923:	89 f8                	mov    %edi,%eax
  800925:	09 c8                	or     %ecx,%eax
  800927:	a8 03                	test   $0x3,%al
  800929:	75 21                	jne    80094c <memset+0x39>
		c &= 0xFF;
  80092b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092f:	89 d0                	mov    %edx,%eax
  800931:	c1 e0 08             	shl    $0x8,%eax
  800934:	89 d3                	mov    %edx,%ebx
  800936:	c1 e3 18             	shl    $0x18,%ebx
  800939:	89 d6                	mov    %edx,%esi
  80093b:	c1 e6 10             	shl    $0x10,%esi
  80093e:	09 f3                	or     %esi,%ebx
  800940:	09 da                	or     %ebx,%edx
  800942:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800944:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800947:	fc                   	cld    
  800948:	f3 ab                	rep stos %eax,%es:(%edi)
  80094a:	eb 06                	jmp    800952 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094f:	fc                   	cld    
  800950:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800952:	89 f8                	mov    %edi,%eax
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5f                   	pop    %edi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	57                   	push   %edi
  80095d:	56                   	push   %esi
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 75 0c             	mov    0xc(%ebp),%esi
  800964:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800967:	39 c6                	cmp    %eax,%esi
  800969:	73 32                	jae    80099d <memmove+0x44>
  80096b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096e:	39 c2                	cmp    %eax,%edx
  800970:	76 2b                	jbe    80099d <memmove+0x44>
		s += n;
		d += n;
  800972:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800975:	89 d6                	mov    %edx,%esi
  800977:	09 fe                	or     %edi,%esi
  800979:	09 ce                	or     %ecx,%esi
  80097b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800981:	75 0e                	jne    800991 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800983:	83 ef 04             	sub    $0x4,%edi
  800986:	8d 72 fc             	lea    -0x4(%edx),%esi
  800989:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80098c:	fd                   	std    
  80098d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098f:	eb 09                	jmp    80099a <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800991:	83 ef 01             	sub    $0x1,%edi
  800994:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800997:	fd                   	std    
  800998:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099a:	fc                   	cld    
  80099b:	eb 1a                	jmp    8009b7 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099d:	89 f2                	mov    %esi,%edx
  80099f:	09 c2                	or     %eax,%edx
  8009a1:	09 ca                	or     %ecx,%edx
  8009a3:	f6 c2 03             	test   $0x3,%dl
  8009a6:	75 0a                	jne    8009b2 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009ab:	89 c7                	mov    %eax,%edi
  8009ad:	fc                   	cld    
  8009ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b0:	eb 05                	jmp    8009b7 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b7:	5e                   	pop    %esi
  8009b8:	5f                   	pop    %edi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c1:	ff 75 10             	push   0x10(%ebp)
  8009c4:	ff 75 0c             	push   0xc(%ebp)
  8009c7:	ff 75 08             	push   0x8(%ebp)
  8009ca:	e8 8a ff ff ff       	call   800959 <memmove>
}
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    

008009d1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dc:	89 c6                	mov    %eax,%esi
  8009de:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e1:	eb 06                	jmp    8009e9 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009e3:	83 c0 01             	add    $0x1,%eax
  8009e6:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009e9:	39 f0                	cmp    %esi,%eax
  8009eb:	74 14                	je     800a01 <memcmp+0x30>
		if (*s1 != *s2)
  8009ed:	0f b6 08             	movzbl (%eax),%ecx
  8009f0:	0f b6 1a             	movzbl (%edx),%ebx
  8009f3:	38 d9                	cmp    %bl,%cl
  8009f5:	74 ec                	je     8009e3 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009f7:	0f b6 c1             	movzbl %cl,%eax
  8009fa:	0f b6 db             	movzbl %bl,%ebx
  8009fd:	29 d8                	sub    %ebx,%eax
  8009ff:	eb 05                	jmp    800a06 <memcmp+0x35>
	}

	return 0;
  800a01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a06:	5b                   	pop    %ebx
  800a07:	5e                   	pop    %esi
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a13:	89 c2                	mov    %eax,%edx
  800a15:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a18:	eb 03                	jmp    800a1d <memfind+0x13>
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	39 d0                	cmp    %edx,%eax
  800a1f:	73 04                	jae    800a25 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a21:	38 08                	cmp    %cl,(%eax)
  800a23:	75 f5                	jne    800a1a <memfind+0x10>
			break;
	return (void *) s;
}
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a33:	eb 03                	jmp    800a38 <strtol+0x11>
		s++;
  800a35:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a38:	0f b6 02             	movzbl (%edx),%eax
  800a3b:	3c 20                	cmp    $0x20,%al
  800a3d:	74 f6                	je     800a35 <strtol+0xe>
  800a3f:	3c 09                	cmp    $0x9,%al
  800a41:	74 f2                	je     800a35 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a43:	3c 2b                	cmp    $0x2b,%al
  800a45:	74 2a                	je     800a71 <strtol+0x4a>
	int neg = 0;
  800a47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a4c:	3c 2d                	cmp    $0x2d,%al
  800a4e:	74 2b                	je     800a7b <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a50:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a56:	75 0f                	jne    800a67 <strtol+0x40>
  800a58:	80 3a 30             	cmpb   $0x30,(%edx)
  800a5b:	74 28                	je     800a85 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5d:	85 db                	test   %ebx,%ebx
  800a5f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a64:	0f 44 d8             	cmove  %eax,%ebx
  800a67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a6c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a6f:	eb 46                	jmp    800ab7 <strtol+0x90>
		s++;
  800a71:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a74:	bf 00 00 00 00       	mov    $0x0,%edi
  800a79:	eb d5                	jmp    800a50 <strtol+0x29>
		s++, neg = 1;
  800a7b:	83 c2 01             	add    $0x1,%edx
  800a7e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a83:	eb cb                	jmp    800a50 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a85:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a89:	74 0e                	je     800a99 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a8b:	85 db                	test   %ebx,%ebx
  800a8d:	75 d8                	jne    800a67 <strtol+0x40>
		s++, base = 8;
  800a8f:	83 c2 01             	add    $0x1,%edx
  800a92:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a97:	eb ce                	jmp    800a67 <strtol+0x40>
		s += 2, base = 16;
  800a99:	83 c2 02             	add    $0x2,%edx
  800a9c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa1:	eb c4                	jmp    800a67 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aa3:	0f be c0             	movsbl %al,%eax
  800aa6:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa9:	3b 45 10             	cmp    0x10(%ebp),%eax
  800aac:	7d 3a                	jge    800ae8 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800aae:	83 c2 01             	add    $0x1,%edx
  800ab1:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ab5:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ab7:	0f b6 02             	movzbl (%edx),%eax
  800aba:	8d 70 d0             	lea    -0x30(%eax),%esi
  800abd:	89 f3                	mov    %esi,%ebx
  800abf:	80 fb 09             	cmp    $0x9,%bl
  800ac2:	76 df                	jbe    800aa3 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ac4:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ac7:	89 f3                	mov    %esi,%ebx
  800ac9:	80 fb 19             	cmp    $0x19,%bl
  800acc:	77 08                	ja     800ad6 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ace:	0f be c0             	movsbl %al,%eax
  800ad1:	83 e8 57             	sub    $0x57,%eax
  800ad4:	eb d3                	jmp    800aa9 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ad6:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ad9:	89 f3                	mov    %esi,%ebx
  800adb:	80 fb 19             	cmp    $0x19,%bl
  800ade:	77 08                	ja     800ae8 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ae0:	0f be c0             	movsbl %al,%eax
  800ae3:	83 e8 37             	sub    $0x37,%eax
  800ae6:	eb c1                	jmp    800aa9 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ae8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aec:	74 05                	je     800af3 <strtol+0xcc>
		*endptr = (char *) s;
  800aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800af3:	89 c8                	mov    %ecx,%eax
  800af5:	f7 d8                	neg    %eax
  800af7:	85 ff                	test   %edi,%edi
  800af9:	0f 45 c8             	cmovne %eax,%ecx
}
  800afc:	89 c8                	mov    %ecx,%eax
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b14:	89 c3                	mov    %eax,%ebx
  800b16:	89 c7                	mov    %eax,%edi
  800b18:	89 c6                	mov    %eax,%esi
  800b1a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b27:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b31:	89 d1                	mov    %edx,%ecx
  800b33:	89 d3                	mov    %edx,%ebx
  800b35:	89 d7                	mov    %edx,%edi
  800b37:	89 d6                	mov    %edx,%esi
  800b39:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	83 ec 1c             	sub    $0x1c,%esp
  800b49:	e8 32 fc ff ff       	call   800780 <__x86.get_pc_thunk.ax>
  800b4e:	05 b2 14 00 00       	add    $0x14b2,%eax
  800b53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b63:	89 cb                	mov    %ecx,%ebx
  800b65:	89 cf                	mov    %ecx,%edi
  800b67:	89 ce                	mov    %ecx,%esi
  800b69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b6b:	85 c0                	test   %eax,%eax
  800b6d:	7f 08                	jg     800b77 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	50                   	push   %eax
  800b7b:	6a 03                	push   $0x3
  800b7d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800b80:	8d 83 58 f0 ff ff    	lea    -0xfa8(%ebx),%eax
  800b86:	50                   	push   %eax
  800b87:	6a 23                	push   $0x23
  800b89:	8d 83 75 f0 ff ff    	lea    -0xf8b(%ebx),%eax
  800b8f:	50                   	push   %eax
  800b90:	e8 1f 00 00 00       	call   800bb4 <_panic>

00800b95 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba5:	89 d1                	mov    %edx,%ecx
  800ba7:	89 d3                	mov    %edx,%ebx
  800ba9:	89 d7                	mov    %edx,%edi
  800bab:	89 d6                	mov    %edx,%esi
  800bad:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 0c             	sub    $0xc,%esp
  800bbd:	e8 b2 f4 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800bc2:	81 c3 3e 14 00 00    	add    $0x143e,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bc8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bcb:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800bd1:	8b 38                	mov    (%eax),%edi
  800bd3:	e8 bd ff ff ff       	call   800b95 <sys_getenvid>
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	ff 75 0c             	push   0xc(%ebp)
  800bde:	ff 75 08             	push   0x8(%ebp)
  800be1:	57                   	push   %edi
  800be2:	50                   	push   %eax
  800be3:	8d 83 84 f0 ff ff    	lea    -0xf7c(%ebx),%eax
  800be9:	50                   	push   %eax
  800bea:	e8 a0 f5 ff ff       	call   80018f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bef:	83 c4 18             	add    $0x18,%esp
  800bf2:	56                   	push   %esi
  800bf3:	ff 75 10             	push   0x10(%ebp)
  800bf6:	e8 32 f5 ff ff       	call   80012d <vcprintf>
	cprintf("\n");
  800bfb:	8d 83 50 ee ff ff    	lea    -0x11b0(%ebx),%eax
  800c01:	89 04 24             	mov    %eax,(%esp)
  800c04:	e8 86 f5 ff ff       	call   80018f <cprintf>
  800c09:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c0c:	cc                   	int3   
  800c0d:	eb fd                	jmp    800c0c <_panic+0x58>
  800c0f:	90                   	nop

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
