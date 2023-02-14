
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 2c 00 00 00       	call   80005d <libmain>
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
  80003a:	e8 1a 00 00 00       	call   800059 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800045:	6a 64                	push   $0x64
  800047:	68 0c 00 10 f0       	push   $0xf010000c
  80004c:	e8 72 00 00 00       	call   8000c3 <sys_cputs>
}
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <__x86.get_pc_thunk.bx>:
  800059:	8b 1c 24             	mov    (%esp),%ebx
  80005c:	c3                   	ret    

0080005d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	53                   	push   %ebx
  800061:	83 ec 04             	sub    $0x4,%esp
  800064:	e8 f0 ff ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  800069:	81 c3 97 1f 00 00    	add    $0x1f97,%ebx
  80006f:	8b 45 08             	mov    0x8(%ebp),%eax
  800072:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800075:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  80007c:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007f:	85 c0                	test   %eax,%eax
  800081:	7e 08                	jle    80008b <libmain+0x2e>
		binaryname = argv[0];
  800083:	8b 0a                	mov    (%edx),%ecx
  800085:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	52                   	push   %edx
  80008f:	50                   	push   %eax
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 08 00 00 00       	call   8000a2 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	53                   	push   %ebx
  8000a6:	83 ec 10             	sub    $0x10,%esp
  8000a9:	e8 ab ff ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8000ae:	81 c3 52 1f 00 00    	add    $0x1f52,%ebx
	sys_env_destroy(0);
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 45 00 00 00       	call   800100 <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	57                   	push   %edi
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d4:	89 c3                	mov    %eax,%ebx
  8000d6:	89 c7                	mov    %eax,%edi
  8000d8:	89 c6                	mov    %eax,%esi
  8000da:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f1:	89 d1                	mov    %edx,%ecx
  8000f3:	89 d3                	mov    %edx,%ebx
  8000f5:	89 d7                	mov    %edx,%edi
  8000f7:	89 d6                	mov    %edx,%esi
  8000f9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5f                   	pop    %edi
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    

00800100 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	57                   	push   %edi
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	83 ec 1c             	sub    $0x1c,%esp
  800109:	e8 66 00 00 00       	call   800174 <__x86.get_pc_thunk.ax>
  80010e:	05 f2 1e 00 00       	add    $0x1ef2,%eax
  800113:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800116:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011b:	8b 55 08             	mov    0x8(%ebp),%edx
  80011e:	b8 03 00 00 00       	mov    $0x3,%eax
  800123:	89 cb                	mov    %ecx,%ebx
  800125:	89 cf                	mov    %ecx,%edi
  800127:	89 ce                	mov    %ecx,%esi
  800129:	cd 30                	int    $0x30
	if(check && ret > 0)
  80012b:	85 c0                	test   %eax,%eax
  80012d:	7f 08                	jg     800137 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	50                   	push   %eax
  80013b:	6a 03                	push   $0x3
  80013d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800140:	8d 83 3e ee ff ff    	lea    -0x11c2(%ebx),%eax
  800146:	50                   	push   %eax
  800147:	6a 23                	push   $0x23
  800149:	8d 83 5b ee ff ff    	lea    -0x11a5(%ebx),%eax
  80014f:	50                   	push   %eax
  800150:	e8 23 00 00 00       	call   800178 <_panic>

00800155 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	b8 02 00 00 00       	mov    $0x2,%eax
  800165:	89 d1                	mov    %edx,%ecx
  800167:	89 d3                	mov    %edx,%ebx
  800169:	89 d7                	mov    %edx,%edi
  80016b:	89 d6                	mov    %edx,%esi
  80016d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016f:	5b                   	pop    %ebx
  800170:	5e                   	pop    %esi
  800171:	5f                   	pop    %edi
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <__x86.get_pc_thunk.ax>:
  800174:	8b 04 24             	mov    (%esp),%eax
  800177:	c3                   	ret    

00800178 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	e8 d3 fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  800186:	81 c3 7a 1e 00 00    	add    $0x1e7a,%ebx
	va_list ap;

	va_start(ap, fmt);
  80018c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018f:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800195:	8b 38                	mov    (%eax),%edi
  800197:	e8 b9 ff ff ff       	call   800155 <sys_getenvid>
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	ff 75 0c             	push   0xc(%ebp)
  8001a2:	ff 75 08             	push   0x8(%ebp)
  8001a5:	57                   	push   %edi
  8001a6:	50                   	push   %eax
  8001a7:	8d 83 6c ee ff ff    	lea    -0x1194(%ebx),%eax
  8001ad:	50                   	push   %eax
  8001ae:	e8 d1 00 00 00       	call   800284 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b3:	83 c4 18             	add    $0x18,%esp
  8001b6:	56                   	push   %esi
  8001b7:	ff 75 10             	push   0x10(%ebp)
  8001ba:	e8 63 00 00 00       	call   800222 <vcprintf>
	cprintf("\n");
  8001bf:	8d 83 8f ee ff ff    	lea    -0x1171(%ebx),%eax
  8001c5:	89 04 24             	mov    %eax,(%esp)
  8001c8:	e8 b7 00 00 00       	call   800284 <cprintf>
  8001cd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d0:	cc                   	int3   
  8001d1:	eb fd                	jmp    8001d0 <_panic+0x58>

008001d3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	e8 7c fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8001dd:	81 c3 23 1e 00 00    	add    $0x1e23,%ebx
  8001e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e6:	8b 16                	mov    (%esi),%edx
  8001e8:	8d 42 01             	lea    0x1(%edx),%eax
  8001eb:	89 06                	mov    %eax,(%esi)
  8001ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f0:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f9:	74 0b                	je     800206 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001fb:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800202:	5b                   	pop    %ebx
  800203:	5e                   	pop    %esi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	68 ff 00 00 00       	push   $0xff
  80020e:	8d 46 08             	lea    0x8(%esi),%eax
  800211:	50                   	push   %eax
  800212:	e8 ac fe ff ff       	call   8000c3 <sys_cputs>
		b->idx = 0;
  800217:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021d:	83 c4 10             	add    $0x10,%esp
  800220:	eb d9                	jmp    8001fb <putch+0x28>

00800222 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	53                   	push   %ebx
  800226:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80022c:	e8 28 fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  800231:	81 c3 cf 1d 00 00    	add    $0x1dcf,%ebx
	struct printbuf b;

	b.idx = 0;
  800237:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023e:	00 00 00 
	b.cnt = 0;
  800241:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800248:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024b:	ff 75 0c             	push   0xc(%ebp)
  80024e:	ff 75 08             	push   0x8(%ebp)
  800251:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800257:	50                   	push   %eax
  800258:	8d 83 d3 e1 ff ff    	lea    -0x1e2d(%ebx),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 2c 01 00 00       	call   800390 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800264:	83 c4 08             	add    $0x8,%esp
  800267:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80026d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800273:	50                   	push   %eax
  800274:	e8 4a fe ff ff       	call   8000c3 <sys_cputs>

	return b.cnt;
}
  800279:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028d:	50                   	push   %eax
  80028e:	ff 75 08             	push   0x8(%ebp)
  800291:	e8 8c ff ff ff       	call   800222 <vcprintf>
	va_end(ap);

	return cnt;
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 2c             	sub    $0x2c,%esp
  8002a1:	e8 cf 05 00 00       	call   800875 <__x86.get_pc_thunk.cx>
  8002a6:	81 c1 5a 1d 00 00    	add    $0x1d5a,%ecx
  8002ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002af:	89 c7                	mov    %eax,%edi
  8002b1:	89 d6                	mov    %edx,%esi
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b9:	89 d1                	mov    %edx,%ecx
  8002bb:	89 c2                	mov    %eax,%edx
  8002bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002c0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002cc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002d3:	39 c2                	cmp    %eax,%edx
  8002d5:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002d8:	72 41                	jb     80031b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002da:	83 ec 0c             	sub    $0xc,%esp
  8002dd:	ff 75 18             	push   0x18(%ebp)
  8002e0:	83 eb 01             	sub    $0x1,%ebx
  8002e3:	53                   	push   %ebx
  8002e4:	50                   	push   %eax
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	ff 75 e4             	push   -0x1c(%ebp)
  8002eb:	ff 75 e0             	push   -0x20(%ebp)
  8002ee:	ff 75 d4             	push   -0x2c(%ebp)
  8002f1:	ff 75 d0             	push   -0x30(%ebp)
  8002f4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f7:	e8 04 09 00 00       	call   800c00 <__udivdi3>
  8002fc:	83 c4 18             	add    $0x18,%esp
  8002ff:	52                   	push   %edx
  800300:	50                   	push   %eax
  800301:	89 f2                	mov    %esi,%edx
  800303:	89 f8                	mov    %edi,%eax
  800305:	e8 8e ff ff ff       	call   800298 <printnum>
  80030a:	83 c4 20             	add    $0x20,%esp
  80030d:	eb 13                	jmp    800322 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030f:	83 ec 08             	sub    $0x8,%esp
  800312:	56                   	push   %esi
  800313:	ff 75 18             	push   0x18(%ebp)
  800316:	ff d7                	call   *%edi
  800318:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031b:	83 eb 01             	sub    $0x1,%ebx
  80031e:	85 db                	test   %ebx,%ebx
  800320:	7f ed                	jg     80030f <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800322:	83 ec 08             	sub    $0x8,%esp
  800325:	56                   	push   %esi
  800326:	83 ec 04             	sub    $0x4,%esp
  800329:	ff 75 e4             	push   -0x1c(%ebp)
  80032c:	ff 75 e0             	push   -0x20(%ebp)
  80032f:	ff 75 d4             	push   -0x2c(%ebp)
  800332:	ff 75 d0             	push   -0x30(%ebp)
  800335:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800338:	e8 e3 09 00 00       	call   800d20 <__umoddi3>
  80033d:	83 c4 14             	add    $0x14,%esp
  800340:	0f be 84 03 91 ee ff 	movsbl -0x116f(%ebx,%eax,1),%eax
  800347:	ff 
  800348:	50                   	push   %eax
  800349:	ff d7                	call   *%edi
}
  80034b:	83 c4 10             	add    $0x10,%esp
  80034e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800351:	5b                   	pop    %ebx
  800352:	5e                   	pop    %esi
  800353:	5f                   	pop    %edi
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800360:	8b 10                	mov    (%eax),%edx
  800362:	3b 50 04             	cmp    0x4(%eax),%edx
  800365:	73 0a                	jae    800371 <sprintputch+0x1b>
		*b->buf++ = ch;
  800367:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036a:	89 08                	mov    %ecx,(%eax)
  80036c:	8b 45 08             	mov    0x8(%ebp),%eax
  80036f:	88 02                	mov    %al,(%edx)
}
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <printfmt>:
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800379:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037c:	50                   	push   %eax
  80037d:	ff 75 10             	push   0x10(%ebp)
  800380:	ff 75 0c             	push   0xc(%ebp)
  800383:	ff 75 08             	push   0x8(%ebp)
  800386:	e8 05 00 00 00       	call   800390 <vprintfmt>
}
  80038b:	83 c4 10             	add    $0x10,%esp
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <vprintfmt>:
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	57                   	push   %edi
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
  800396:	83 ec 3c             	sub    $0x3c,%esp
  800399:	e8 d6 fd ff ff       	call   800174 <__x86.get_pc_thunk.ax>
  80039e:	05 62 1c 00 00       	add    $0x1c62,%eax
  8003a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8003a9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003af:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8003b5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003b8:	eb 0a                	jmp    8003c4 <vprintfmt+0x34>
			putch(ch, putdat);
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	57                   	push   %edi
  8003be:	50                   	push   %eax
  8003bf:	ff d6                	call   *%esi
  8003c1:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c4:	83 c3 01             	add    $0x1,%ebx
  8003c7:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003cb:	83 f8 25             	cmp    $0x25,%eax
  8003ce:	74 0c                	je     8003dc <vprintfmt+0x4c>
			if (ch == '\0')
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	75 e6                	jne    8003ba <vprintfmt+0x2a>
}
  8003d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d7:	5b                   	pop    %ebx
  8003d8:	5e                   	pop    %esi
  8003d9:	5f                   	pop    %edi
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    
		padc = ' ';
  8003dc:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003e0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003e7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003ee:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fa:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003fd:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8d 43 01             	lea    0x1(%ebx),%eax
  800403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800406:	0f b6 13             	movzbl (%ebx),%edx
  800409:	8d 42 dd             	lea    -0x23(%edx),%eax
  80040c:	3c 55                	cmp    $0x55,%al
  80040e:	0f 87 c5 03 00 00    	ja     8007d9 <.L20>
  800414:	0f b6 c0             	movzbl %al,%eax
  800417:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041a:	89 ce                	mov    %ecx,%esi
  80041c:	03 b4 81 20 ef ff ff 	add    -0x10e0(%ecx,%eax,4),%esi
  800423:	ff e6                	jmp    *%esi

00800425 <.L66>:
  800425:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800428:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  80042c:	eb d2                	jmp    800400 <vprintfmt+0x70>

0080042e <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800431:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800435:	eb c9                	jmp    800400 <vprintfmt+0x70>

00800437 <.L31>:
  800437:	0f b6 d2             	movzbl %dl,%edx
  80043a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80043d:	b8 00 00 00 00       	mov    $0x0,%eax
  800442:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800445:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800448:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80044c:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80044f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800452:	83 f9 09             	cmp    $0x9,%ecx
  800455:	77 58                	ja     8004af <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800457:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80045a:	eb e9                	jmp    800445 <.L31+0xe>

0080045c <.L34>:
			precision = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8b 00                	mov    (%eax),%eax
  800461:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 40 04             	lea    0x4(%eax),%eax
  80046a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800470:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800474:	79 8a                	jns    800400 <vprintfmt+0x70>
				width = precision, precision = -1;
  800476:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800479:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80047c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800483:	e9 78 ff ff ff       	jmp    800400 <vprintfmt+0x70>

00800488 <.L33>:
  800488:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80048b:	85 d2                	test   %edx,%edx
  80048d:	b8 00 00 00 00       	mov    $0x0,%eax
  800492:	0f 49 c2             	cmovns %edx,%eax
  800495:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80049b:	e9 60 ff ff ff       	jmp    800400 <vprintfmt+0x70>

008004a0 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8004a3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004aa:	e9 51 ff ff ff       	jmp    800400 <vprintfmt+0x70>
  8004af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b5:	eb b9                	jmp    800470 <.L34+0x14>

008004b7 <.L27>:
			lflag++;
  8004b7:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004be:	e9 3d ff ff ff       	jmp    800400 <vprintfmt+0x70>

008004c3 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 58 04             	lea    0x4(%eax),%ebx
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	57                   	push   %edi
  8004d0:	ff 30                	push   (%eax)
  8004d2:	ff d6                	call   *%esi
			break;
  8004d4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004d7:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004da:	e9 90 02 00 00       	jmp    80076f <.L25+0x45>

008004df <.L28>:
			err = va_arg(ap, int);
  8004df:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 58 04             	lea    0x4(%eax),%ebx
  8004e8:	8b 10                	mov    (%eax),%edx
  8004ea:	89 d0                	mov    %edx,%eax
  8004ec:	f7 d8                	neg    %eax
  8004ee:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f1:	83 f8 06             	cmp    $0x6,%eax
  8004f4:	7f 27                	jg     80051d <.L28+0x3e>
  8004f6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f9:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004fc:	85 d2                	test   %edx,%edx
  8004fe:	74 1d                	je     80051d <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  800500:	52                   	push   %edx
  800501:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800504:	8d 80 b2 ee ff ff    	lea    -0x114e(%eax),%eax
  80050a:	50                   	push   %eax
  80050b:	57                   	push   %edi
  80050c:	56                   	push   %esi
  80050d:	e8 61 fe ff ff       	call   800373 <printfmt>
  800512:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800515:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800518:	e9 52 02 00 00       	jmp    80076f <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  80051d:	50                   	push   %eax
  80051e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800521:	8d 80 a9 ee ff ff    	lea    -0x1157(%eax),%eax
  800527:	50                   	push   %eax
  800528:	57                   	push   %edi
  800529:	56                   	push   %esi
  80052a:	e8 44 fe ff ff       	call   800373 <printfmt>
  80052f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800532:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800535:	e9 35 02 00 00       	jmp    80076f <.L25+0x45>

0080053a <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  80053a:	8b 75 08             	mov    0x8(%ebp),%esi
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	83 c0 04             	add    $0x4,%eax
  800543:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80054b:	85 d2                	test   %edx,%edx
  80054d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800550:	8d 80 a2 ee ff ff    	lea    -0x115e(%eax),%eax
  800556:	0f 45 c2             	cmovne %edx,%eax
  800559:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80055c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800560:	7e 06                	jle    800568 <.L24+0x2e>
  800562:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800566:	75 0d                	jne    800575 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800568:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80056b:	89 c3                	mov    %eax,%ebx
  80056d:	03 45 d0             	add    -0x30(%ebp),%eax
  800570:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800573:	eb 58                	jmp    8005cd <.L24+0x93>
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	ff 75 d8             	push   -0x28(%ebp)
  80057b:	ff 75 c8             	push   -0x38(%ebp)
  80057e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800581:	e8 0b 03 00 00       	call   800891 <strnlen>
  800586:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800589:	29 c2                	sub    %eax,%edx
  80058b:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80058e:	83 c4 10             	add    $0x10,%esp
  800591:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800593:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800597:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80059a:	eb 0f                	jmp    8005ab <.L24+0x71>
					putch(padc, putdat);
  80059c:	83 ec 08             	sub    $0x8,%esp
  80059f:	57                   	push   %edi
  8005a0:	ff 75 d0             	push   -0x30(%ebp)
  8005a3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a5:	83 eb 01             	sub    $0x1,%ebx
  8005a8:	83 c4 10             	add    $0x10,%esp
  8005ab:	85 db                	test   %ebx,%ebx
  8005ad:	7f ed                	jg     80059c <.L24+0x62>
  8005af:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8005b2:	85 d2                	test   %edx,%edx
  8005b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b9:	0f 49 c2             	cmovns %edx,%eax
  8005bc:	29 c2                	sub    %eax,%edx
  8005be:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005c1:	eb a5                	jmp    800568 <.L24+0x2e>
					putch(ch, putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	57                   	push   %edi
  8005c7:	52                   	push   %edx
  8005c8:	ff d6                	call   *%esi
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005d0:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d2:	83 c3 01             	add    $0x1,%ebx
  8005d5:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005d9:	0f be d0             	movsbl %al,%edx
  8005dc:	85 d2                	test   %edx,%edx
  8005de:	74 4b                	je     80062b <.L24+0xf1>
  8005e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e4:	78 06                	js     8005ec <.L24+0xb2>
  8005e6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005ea:	78 1e                	js     80060a <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ec:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005f0:	74 d1                	je     8005c3 <.L24+0x89>
  8005f2:	0f be c0             	movsbl %al,%eax
  8005f5:	83 e8 20             	sub    $0x20,%eax
  8005f8:	83 f8 5e             	cmp    $0x5e,%eax
  8005fb:	76 c6                	jbe    8005c3 <.L24+0x89>
					putch('?', putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	57                   	push   %edi
  800601:	6a 3f                	push   $0x3f
  800603:	ff d6                	call   *%esi
  800605:	83 c4 10             	add    $0x10,%esp
  800608:	eb c3                	jmp    8005cd <.L24+0x93>
  80060a:	89 cb                	mov    %ecx,%ebx
  80060c:	eb 0e                	jmp    80061c <.L24+0xe2>
				putch(' ', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	57                   	push   %edi
  800612:	6a 20                	push   $0x20
  800614:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800616:	83 eb 01             	sub    $0x1,%ebx
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	85 db                	test   %ebx,%ebx
  80061e:	7f ee                	jg     80060e <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800620:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
  800626:	e9 44 01 00 00       	jmp    80076f <.L25+0x45>
  80062b:	89 cb                	mov    %ecx,%ebx
  80062d:	eb ed                	jmp    80061c <.L24+0xe2>

0080062f <.L29>:
	if (lflag >= 2)
  80062f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800632:	8b 75 08             	mov    0x8(%ebp),%esi
  800635:	83 f9 01             	cmp    $0x1,%ecx
  800638:	7f 1b                	jg     800655 <.L29+0x26>
	else if (lflag)
  80063a:	85 c9                	test   %ecx,%ecx
  80063c:	74 63                	je     8006a1 <.L29+0x72>
		return va_arg(*ap, long);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8b 00                	mov    (%eax),%eax
  800643:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800646:	99                   	cltd   
  800647:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
  800653:	eb 17                	jmp    80066c <.L29+0x3d>
		return va_arg(*ap, long long);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 50 04             	mov    0x4(%eax),%edx
  80065b:	8b 00                	mov    (%eax),%eax
  80065d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800660:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8d 40 08             	lea    0x8(%eax),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80066c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80066f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800672:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800677:	85 db                	test   %ebx,%ebx
  800679:	0f 89 d6 00 00 00    	jns    800755 <.L25+0x2b>
				putch('-', putdat);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	57                   	push   %edi
  800683:	6a 2d                	push   $0x2d
  800685:	ff d6                	call   *%esi
				num = -(long long) num;
  800687:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80068a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80068d:	f7 d9                	neg    %ecx
  80068f:	83 d3 00             	adc    $0x0,%ebx
  800692:	f7 db                	neg    %ebx
  800694:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800697:	ba 0a 00 00 00       	mov    $0xa,%edx
  80069c:	e9 b4 00 00 00       	jmp    800755 <.L25+0x2b>
		return va_arg(*ap, int);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8b 00                	mov    (%eax),%eax
  8006a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a9:	99                   	cltd   
  8006aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8d 40 04             	lea    0x4(%eax),%eax
  8006b3:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b6:	eb b4                	jmp    80066c <.L29+0x3d>

008006b8 <.L23>:
	if (lflag >= 2)
  8006b8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006be:	83 f9 01             	cmp    $0x1,%ecx
  8006c1:	7f 1b                	jg     8006de <.L23+0x26>
	else if (lflag)
  8006c3:	85 c9                	test   %ecx,%ecx
  8006c5:	74 2c                	je     8006f3 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8b 08                	mov    (%eax),%ecx
  8006cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d1:	8d 40 04             	lea    0x4(%eax),%eax
  8006d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d7:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006dc:	eb 77                	jmp    800755 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8b 08                	mov    (%eax),%ecx
  8006e3:	8b 58 04             	mov    0x4(%eax),%ebx
  8006e6:	8d 40 08             	lea    0x8(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ec:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006f1:	eb 62                	jmp    800755 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8b 08                	mov    (%eax),%ecx
  8006f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fd:	8d 40 04             	lea    0x4(%eax),%eax
  800700:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800703:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800708:	eb 4b                	jmp    800755 <.L25+0x2b>

0080070a <.L26>:
			putch('X', putdat);
  80070a:	8b 75 08             	mov    0x8(%ebp),%esi
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	57                   	push   %edi
  800711:	6a 58                	push   $0x58
  800713:	ff d6                	call   *%esi
			putch('X', putdat);
  800715:	83 c4 08             	add    $0x8,%esp
  800718:	57                   	push   %edi
  800719:	6a 58                	push   $0x58
  80071b:	ff d6                	call   *%esi
			putch('X', putdat);
  80071d:	83 c4 08             	add    $0x8,%esp
  800720:	57                   	push   %edi
  800721:	6a 58                	push   $0x58
  800723:	ff d6                	call   *%esi
			break;
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	eb 45                	jmp    80076f <.L25+0x45>

0080072a <.L25>:
			putch('0', putdat);
  80072a:	8b 75 08             	mov    0x8(%ebp),%esi
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	57                   	push   %edi
  800731:	6a 30                	push   $0x30
  800733:	ff d6                	call   *%esi
			putch('x', putdat);
  800735:	83 c4 08             	add    $0x8,%esp
  800738:	57                   	push   %edi
  800739:	6a 78                	push   $0x78
  80073b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8b 08                	mov    (%eax),%ecx
  800742:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800747:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80074a:	8d 40 04             	lea    0x4(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800750:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800755:	83 ec 0c             	sub    $0xc,%esp
  800758:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80075c:	50                   	push   %eax
  80075d:	ff 75 d0             	push   -0x30(%ebp)
  800760:	52                   	push   %edx
  800761:	53                   	push   %ebx
  800762:	51                   	push   %ecx
  800763:	89 fa                	mov    %edi,%edx
  800765:	89 f0                	mov    %esi,%eax
  800767:	e8 2c fb ff ff       	call   800298 <printnum>
			break;
  80076c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80076f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800772:	e9 4d fc ff ff       	jmp    8003c4 <vprintfmt+0x34>

00800777 <.L21>:
	if (lflag >= 2)
  800777:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80077a:	8b 75 08             	mov    0x8(%ebp),%esi
  80077d:	83 f9 01             	cmp    $0x1,%ecx
  800780:	7f 1b                	jg     80079d <.L21+0x26>
	else if (lflag)
  800782:	85 c9                	test   %ecx,%ecx
  800784:	74 2c                	je     8007b2 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8b 08                	mov    (%eax),%ecx
  80078b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800790:	8d 40 04             	lea    0x4(%eax),%eax
  800793:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800796:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  80079b:	eb b8                	jmp    800755 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8b 08                	mov    (%eax),%ecx
  8007a2:	8b 58 04             	mov    0x4(%eax),%ebx
  8007a5:	8d 40 08             	lea    0x8(%eax),%eax
  8007a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ab:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007b0:	eb a3                	jmp    800755 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 08                	mov    (%eax),%ecx
  8007b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007bc:	8d 40 04             	lea    0x4(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c2:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007c7:	eb 8c                	jmp    800755 <.L25+0x2b>

008007c9 <.L35>:
			putch(ch, putdat);
  8007c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	57                   	push   %edi
  8007d0:	6a 25                	push   $0x25
  8007d2:	ff d6                	call   *%esi
			break;
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	eb 96                	jmp    80076f <.L25+0x45>

008007d9 <.L20>:
			putch('%', putdat);
  8007d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	57                   	push   %edi
  8007e0:	6a 25                	push   $0x25
  8007e2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007ed:	74 05                	je     8007f4 <.L20+0x1b>
  8007ef:	83 e8 01             	sub    $0x1,%eax
  8007f2:	eb f5                	jmp    8007e9 <.L20+0x10>
  8007f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007f7:	e9 73 ff ff ff       	jmp    80076f <.L25+0x45>

008007fc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	83 ec 14             	sub    $0x14,%esp
  800803:	e8 51 f8 ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  800808:	81 c3 f8 17 00 00    	add    $0x17f8,%ebx
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800814:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800817:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80081e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800825:	85 c0                	test   %eax,%eax
  800827:	74 2b                	je     800854 <vsnprintf+0x58>
  800829:	85 d2                	test   %edx,%edx
  80082b:	7e 27                	jle    800854 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082d:	ff 75 14             	push   0x14(%ebp)
  800830:	ff 75 10             	push   0x10(%ebp)
  800833:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800836:	50                   	push   %eax
  800837:	8d 83 56 e3 ff ff    	lea    -0x1caa(%ebx),%eax
  80083d:	50                   	push   %eax
  80083e:	e8 4d fb ff ff       	call   800390 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800843:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800846:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800849:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084c:	83 c4 10             	add    $0x10,%esp
}
  80084f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800852:	c9                   	leave  
  800853:	c3                   	ret    
		return -E_INVAL;
  800854:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800859:	eb f4                	jmp    80084f <vsnprintf+0x53>

0080085b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800861:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800864:	50                   	push   %eax
  800865:	ff 75 10             	push   0x10(%ebp)
  800868:	ff 75 0c             	push   0xc(%ebp)
  80086b:	ff 75 08             	push   0x8(%ebp)
  80086e:	e8 89 ff ff ff       	call   8007fc <vsnprintf>
	va_end(ap);

	return rc;
}
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <__x86.get_pc_thunk.cx>:
  800875:	8b 0c 24             	mov    (%esp),%ecx
  800878:	c3                   	ret    

00800879 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
  800884:	eb 03                	jmp    800889 <strlen+0x10>
		n++;
  800886:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800889:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80088d:	75 f7                	jne    800886 <strlen+0xd>
	return n;
}
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
  80089f:	eb 03                	jmp    8008a4 <strnlen+0x13>
		n++;
  8008a1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a4:	39 d0                	cmp    %edx,%eax
  8008a6:	74 08                	je     8008b0 <strnlen+0x1f>
  8008a8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ac:	75 f3                	jne    8008a1 <strnlen+0x10>
  8008ae:	89 c2                	mov    %eax,%edx
	return n;
}
  8008b0:	89 d0                	mov    %edx,%eax
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c3:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008c7:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008ca:	83 c0 01             	add    $0x1,%eax
  8008cd:	84 d2                	test   %dl,%dl
  8008cf:	75 f2                	jne    8008c3 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d1:	89 c8                	mov    %ecx,%eax
  8008d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	53                   	push   %ebx
  8008dc:	83 ec 10             	sub    $0x10,%esp
  8008df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e2:	53                   	push   %ebx
  8008e3:	e8 91 ff ff ff       	call   800879 <strlen>
  8008e8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008eb:	ff 75 0c             	push   0xc(%ebp)
  8008ee:	01 d8                	add    %ebx,%eax
  8008f0:	50                   	push   %eax
  8008f1:	e8 be ff ff ff       	call   8008b4 <strcpy>
	return dst;
}
  8008f6:	89 d8                	mov    %ebx,%eax
  8008f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    

008008fd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	56                   	push   %esi
  800901:	53                   	push   %ebx
  800902:	8b 75 08             	mov    0x8(%ebp),%esi
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
  800908:	89 f3                	mov    %esi,%ebx
  80090a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090d:	89 f0                	mov    %esi,%eax
  80090f:	eb 0f                	jmp    800920 <strncpy+0x23>
		*dst++ = *src;
  800911:	83 c0 01             	add    $0x1,%eax
  800914:	0f b6 0a             	movzbl (%edx),%ecx
  800917:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091a:	80 f9 01             	cmp    $0x1,%cl
  80091d:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800920:	39 d8                	cmp    %ebx,%eax
  800922:	75 ed                	jne    800911 <strncpy+0x14>
	}
	return ret;
}
  800924:	89 f0                	mov    %esi,%eax
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 75 08             	mov    0x8(%ebp),%esi
  800932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800935:	8b 55 10             	mov    0x10(%ebp),%edx
  800938:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093a:	85 d2                	test   %edx,%edx
  80093c:	74 21                	je     80095f <strlcpy+0x35>
  80093e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800942:	89 f2                	mov    %esi,%edx
  800944:	eb 09                	jmp    80094f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800946:	83 c1 01             	add    $0x1,%ecx
  800949:	83 c2 01             	add    $0x1,%edx
  80094c:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80094f:	39 c2                	cmp    %eax,%edx
  800951:	74 09                	je     80095c <strlcpy+0x32>
  800953:	0f b6 19             	movzbl (%ecx),%ebx
  800956:	84 db                	test   %bl,%bl
  800958:	75 ec                	jne    800946 <strlcpy+0x1c>
  80095a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80095c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80095f:	29 f0                	sub    %esi,%eax
}
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096e:	eb 06                	jmp    800976 <strcmp+0x11>
		p++, q++;
  800970:	83 c1 01             	add    $0x1,%ecx
  800973:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800976:	0f b6 01             	movzbl (%ecx),%eax
  800979:	84 c0                	test   %al,%al
  80097b:	74 04                	je     800981 <strcmp+0x1c>
  80097d:	3a 02                	cmp    (%edx),%al
  80097f:	74 ef                	je     800970 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800981:	0f b6 c0             	movzbl %al,%eax
  800984:	0f b6 12             	movzbl (%edx),%edx
  800987:	29 d0                	sub    %edx,%eax
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
  800995:	89 c3                	mov    %eax,%ebx
  800997:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80099a:	eb 06                	jmp    8009a2 <strncmp+0x17>
		n--, p++, q++;
  80099c:	83 c0 01             	add    $0x1,%eax
  80099f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009a2:	39 d8                	cmp    %ebx,%eax
  8009a4:	74 18                	je     8009be <strncmp+0x33>
  8009a6:	0f b6 08             	movzbl (%eax),%ecx
  8009a9:	84 c9                	test   %cl,%cl
  8009ab:	74 04                	je     8009b1 <strncmp+0x26>
  8009ad:	3a 0a                	cmp    (%edx),%cl
  8009af:	74 eb                	je     80099c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b1:	0f b6 00             	movzbl (%eax),%eax
  8009b4:	0f b6 12             	movzbl (%edx),%edx
  8009b7:	29 d0                	sub    %edx,%eax
}
  8009b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    
		return 0;
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c3:	eb f4                	jmp    8009b9 <strncmp+0x2e>

008009c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cf:	eb 03                	jmp    8009d4 <strchr+0xf>
  8009d1:	83 c0 01             	add    $0x1,%eax
  8009d4:	0f b6 10             	movzbl (%eax),%edx
  8009d7:	84 d2                	test   %dl,%dl
  8009d9:	74 06                	je     8009e1 <strchr+0x1c>
		if (*s == c)
  8009db:	38 ca                	cmp    %cl,%dl
  8009dd:	75 f2                	jne    8009d1 <strchr+0xc>
  8009df:	eb 05                	jmp    8009e6 <strchr+0x21>
			return (char *) s;
	return 0;
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f5:	38 ca                	cmp    %cl,%dl
  8009f7:	74 09                	je     800a02 <strfind+0x1a>
  8009f9:	84 d2                	test   %dl,%dl
  8009fb:	74 05                	je     800a02 <strfind+0x1a>
	for (; *s; s++)
  8009fd:	83 c0 01             	add    $0x1,%eax
  800a00:	eb f0                	jmp    8009f2 <strfind+0xa>
			break;
	return (char *) s;
}
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
  800a0a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a10:	85 c9                	test   %ecx,%ecx
  800a12:	74 2f                	je     800a43 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a14:	89 f8                	mov    %edi,%eax
  800a16:	09 c8                	or     %ecx,%eax
  800a18:	a8 03                	test   $0x3,%al
  800a1a:	75 21                	jne    800a3d <memset+0x39>
		c &= 0xFF;
  800a1c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a20:	89 d0                	mov    %edx,%eax
  800a22:	c1 e0 08             	shl    $0x8,%eax
  800a25:	89 d3                	mov    %edx,%ebx
  800a27:	c1 e3 18             	shl    $0x18,%ebx
  800a2a:	89 d6                	mov    %edx,%esi
  800a2c:	c1 e6 10             	shl    $0x10,%esi
  800a2f:	09 f3                	or     %esi,%ebx
  800a31:	09 da                	or     %ebx,%edx
  800a33:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a35:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a38:	fc                   	cld    
  800a39:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3b:	eb 06                	jmp    800a43 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a40:	fc                   	cld    
  800a41:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a43:	89 f8                	mov    %edi,%eax
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a58:	39 c6                	cmp    %eax,%esi
  800a5a:	73 32                	jae    800a8e <memmove+0x44>
  800a5c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5f:	39 c2                	cmp    %eax,%edx
  800a61:	76 2b                	jbe    800a8e <memmove+0x44>
		s += n;
		d += n;
  800a63:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a66:	89 d6                	mov    %edx,%esi
  800a68:	09 fe                	or     %edi,%esi
  800a6a:	09 ce                	or     %ecx,%esi
  800a6c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a72:	75 0e                	jne    800a82 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a74:	83 ef 04             	sub    $0x4,%edi
  800a77:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a7d:	fd                   	std    
  800a7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a80:	eb 09                	jmp    800a8b <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a82:	83 ef 01             	sub    $0x1,%edi
  800a85:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a88:	fd                   	std    
  800a89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8b:	fc                   	cld    
  800a8c:	eb 1a                	jmp    800aa8 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8e:	89 f2                	mov    %esi,%edx
  800a90:	09 c2                	or     %eax,%edx
  800a92:	09 ca                	or     %ecx,%edx
  800a94:	f6 c2 03             	test   $0x3,%dl
  800a97:	75 0a                	jne    800aa3 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a99:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a9c:	89 c7                	mov    %eax,%edi
  800a9e:	fc                   	cld    
  800a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa1:	eb 05                	jmp    800aa8 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800aa3:	89 c7                	mov    %eax,%edi
  800aa5:	fc                   	cld    
  800aa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa8:	5e                   	pop    %esi
  800aa9:	5f                   	pop    %edi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab2:	ff 75 10             	push   0x10(%ebp)
  800ab5:	ff 75 0c             	push   0xc(%ebp)
  800ab8:	ff 75 08             	push   0x8(%ebp)
  800abb:	e8 8a ff ff ff       	call   800a4a <memmove>
}
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acd:	89 c6                	mov    %eax,%esi
  800acf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad2:	eb 06                	jmp    800ada <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ad4:	83 c0 01             	add    $0x1,%eax
  800ad7:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ada:	39 f0                	cmp    %esi,%eax
  800adc:	74 14                	je     800af2 <memcmp+0x30>
		if (*s1 != *s2)
  800ade:	0f b6 08             	movzbl (%eax),%ecx
  800ae1:	0f b6 1a             	movzbl (%edx),%ebx
  800ae4:	38 d9                	cmp    %bl,%cl
  800ae6:	74 ec                	je     800ad4 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800ae8:	0f b6 c1             	movzbl %cl,%eax
  800aeb:	0f b6 db             	movzbl %bl,%ebx
  800aee:	29 d8                	sub    %ebx,%eax
  800af0:	eb 05                	jmp    800af7 <memcmp+0x35>
	}

	return 0;
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b04:	89 c2                	mov    %eax,%edx
  800b06:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b09:	eb 03                	jmp    800b0e <memfind+0x13>
  800b0b:	83 c0 01             	add    $0x1,%eax
  800b0e:	39 d0                	cmp    %edx,%eax
  800b10:	73 04                	jae    800b16 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b12:	38 08                	cmp    %cl,(%eax)
  800b14:	75 f5                	jne    800b0b <memfind+0x10>
			break;
	return (void *) s;
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b24:	eb 03                	jmp    800b29 <strtol+0x11>
		s++;
  800b26:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b29:	0f b6 02             	movzbl (%edx),%eax
  800b2c:	3c 20                	cmp    $0x20,%al
  800b2e:	74 f6                	je     800b26 <strtol+0xe>
  800b30:	3c 09                	cmp    $0x9,%al
  800b32:	74 f2                	je     800b26 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b34:	3c 2b                	cmp    $0x2b,%al
  800b36:	74 2a                	je     800b62 <strtol+0x4a>
	int neg = 0;
  800b38:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b3d:	3c 2d                	cmp    $0x2d,%al
  800b3f:	74 2b                	je     800b6c <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b41:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b47:	75 0f                	jne    800b58 <strtol+0x40>
  800b49:	80 3a 30             	cmpb   $0x30,(%edx)
  800b4c:	74 28                	je     800b76 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b4e:	85 db                	test   %ebx,%ebx
  800b50:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b55:	0f 44 d8             	cmove  %eax,%ebx
  800b58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b60:	eb 46                	jmp    800ba8 <strtol+0x90>
		s++;
  800b62:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b65:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6a:	eb d5                	jmp    800b41 <strtol+0x29>
		s++, neg = 1;
  800b6c:	83 c2 01             	add    $0x1,%edx
  800b6f:	bf 01 00 00 00       	mov    $0x1,%edi
  800b74:	eb cb                	jmp    800b41 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b76:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b7a:	74 0e                	je     800b8a <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b7c:	85 db                	test   %ebx,%ebx
  800b7e:	75 d8                	jne    800b58 <strtol+0x40>
		s++, base = 8;
  800b80:	83 c2 01             	add    $0x1,%edx
  800b83:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b88:	eb ce                	jmp    800b58 <strtol+0x40>
		s += 2, base = 16;
  800b8a:	83 c2 02             	add    $0x2,%edx
  800b8d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b92:	eb c4                	jmp    800b58 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b94:	0f be c0             	movsbl %al,%eax
  800b97:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9a:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b9d:	7d 3a                	jge    800bd9 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b9f:	83 c2 01             	add    $0x1,%edx
  800ba2:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ba6:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ba8:	0f b6 02             	movzbl (%edx),%eax
  800bab:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bae:	89 f3                	mov    %esi,%ebx
  800bb0:	80 fb 09             	cmp    $0x9,%bl
  800bb3:	76 df                	jbe    800b94 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bb5:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bb8:	89 f3                	mov    %esi,%ebx
  800bba:	80 fb 19             	cmp    $0x19,%bl
  800bbd:	77 08                	ja     800bc7 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bbf:	0f be c0             	movsbl %al,%eax
  800bc2:	83 e8 57             	sub    $0x57,%eax
  800bc5:	eb d3                	jmp    800b9a <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bc7:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bca:	89 f3                	mov    %esi,%ebx
  800bcc:	80 fb 19             	cmp    $0x19,%bl
  800bcf:	77 08                	ja     800bd9 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bd1:	0f be c0             	movsbl %al,%eax
  800bd4:	83 e8 37             	sub    $0x37,%eax
  800bd7:	eb c1                	jmp    800b9a <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bdd:	74 05                	je     800be4 <strtol+0xcc>
		*endptr = (char *) s;
  800bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be2:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800be4:	89 c8                	mov    %ecx,%eax
  800be6:	f7 d8                	neg    %eax
  800be8:	85 ff                	test   %edi,%edi
  800bea:	0f 45 c8             	cmovne %eax,%ecx
}
  800bed:	89 c8                	mov    %ecx,%eax
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    
  800bf4:	66 90                	xchg   %ax,%ax
  800bf6:	66 90                	xchg   %ax,%ax
  800bf8:	66 90                	xchg   %ax,%ax
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
