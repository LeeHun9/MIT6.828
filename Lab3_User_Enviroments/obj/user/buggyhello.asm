
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 29 00 00 00       	call   80005a <libmain>
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
  80003a:	e8 17 00 00 00       	call   800056 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs((char*)1, 1);
  800045:	6a 01                	push   $0x1
  800047:	6a 01                	push   $0x1
  800049:	e8 72 00 00 00       	call   8000c0 <sys_cputs>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <__x86.get_pc_thunk.bx>:
  800056:	8b 1c 24             	mov    (%esp),%ebx
  800059:	c3                   	ret    

0080005a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005a:	55                   	push   %ebp
  80005b:	89 e5                	mov    %esp,%ebp
  80005d:	53                   	push   %ebx
  80005e:	83 ec 04             	sub    $0x4,%esp
  800061:	e8 f0 ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800066:	81 c3 9a 1f 00 00    	add    $0x1f9a,%ebx
  80006c:	8b 45 08             	mov    0x8(%ebp),%eax
  80006f:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800072:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  800079:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007c:	85 c0                	test   %eax,%eax
  80007e:	7e 08                	jle    800088 <libmain+0x2e>
		binaryname = argv[0];
  800080:	8b 0a                	mov    (%edx),%ecx
  800082:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	52                   	push   %edx
  80008c:	50                   	push   %eax
  80008d:	e8 a1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800092:	e8 08 00 00 00       	call   80009f <exit>
}
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	53                   	push   %ebx
  8000a3:	83 ec 10             	sub    $0x10,%esp
  8000a6:	e8 ab ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8000ab:	81 c3 55 1f 00 00    	add    $0x1f55,%ebx
	sys_env_destroy(0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 45 00 00 00       	call   8000fd <sys_env_destroy>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d1:	89 c3                	mov    %eax,%ebx
  8000d3:	89 c7                	mov    %eax,%edi
  8000d5:	89 c6                	mov    %eax,%esi
  8000d7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <sys_cgetc>:

int
sys_cgetc(void)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ee:	89 d1                	mov    %edx,%ecx
  8000f0:	89 d3                	mov    %edx,%ebx
  8000f2:	89 d7                	mov    %edx,%edi
  8000f4:	89 d6                	mov    %edx,%esi
  8000f6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    

008000fd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	57                   	push   %edi
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	83 ec 1c             	sub    $0x1c,%esp
  800106:	e8 66 00 00 00       	call   800171 <__x86.get_pc_thunk.ax>
  80010b:	05 f5 1e 00 00       	add    $0x1ef5,%eax
  800110:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800113:	b9 00 00 00 00       	mov    $0x0,%ecx
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
  80011b:	b8 03 00 00 00       	mov    $0x3,%eax
  800120:	89 cb                	mov    %ecx,%ebx
  800122:	89 cf                	mov    %ecx,%edi
  800124:	89 ce                	mov    %ecx,%esi
  800126:	cd 30                	int    $0x30
	if(check && ret > 0)
  800128:	85 c0                	test   %eax,%eax
  80012a:	7f 08                	jg     800134 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5f                   	pop    %edi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800134:	83 ec 0c             	sub    $0xc,%esp
  800137:	50                   	push   %eax
  800138:	6a 03                	push   $0x3
  80013a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80013d:	8d 83 3e ee ff ff    	lea    -0x11c2(%ebx),%eax
  800143:	50                   	push   %eax
  800144:	6a 23                	push   $0x23
  800146:	8d 83 5b ee ff ff    	lea    -0x11a5(%ebx),%eax
  80014c:	50                   	push   %eax
  80014d:	e8 23 00 00 00       	call   800175 <_panic>

00800152 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
	asm volatile("int %1\n"
  800158:	ba 00 00 00 00       	mov    $0x0,%edx
  80015d:	b8 02 00 00 00       	mov    $0x2,%eax
  800162:	89 d1                	mov    %edx,%ecx
  800164:	89 d3                	mov    %edx,%ebx
  800166:	89 d7                	mov    %edx,%edi
  800168:	89 d6                	mov    %edx,%esi
  80016a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016c:	5b                   	pop    %ebx
  80016d:	5e                   	pop    %esi
  80016e:	5f                   	pop    %edi
  80016f:	5d                   	pop    %ebp
  800170:	c3                   	ret    

00800171 <__x86.get_pc_thunk.ax>:
  800171:	8b 04 24             	mov    (%esp),%eax
  800174:	c3                   	ret    

00800175 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	57                   	push   %edi
  800179:	56                   	push   %esi
  80017a:	53                   	push   %ebx
  80017b:	83 ec 0c             	sub    $0xc,%esp
  80017e:	e8 d3 fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800183:	81 c3 7d 1e 00 00    	add    $0x1e7d,%ebx
	va_list ap;

	va_start(ap, fmt);
  800189:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018c:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800192:	8b 38                	mov    (%eax),%edi
  800194:	e8 b9 ff ff ff       	call   800152 <sys_getenvid>
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	ff 75 0c             	push   0xc(%ebp)
  80019f:	ff 75 08             	push   0x8(%ebp)
  8001a2:	57                   	push   %edi
  8001a3:	50                   	push   %eax
  8001a4:	8d 83 6c ee ff ff    	lea    -0x1194(%ebx),%eax
  8001aa:	50                   	push   %eax
  8001ab:	e8 d1 00 00 00       	call   800281 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b0:	83 c4 18             	add    $0x18,%esp
  8001b3:	56                   	push   %esi
  8001b4:	ff 75 10             	push   0x10(%ebp)
  8001b7:	e8 63 00 00 00       	call   80021f <vcprintf>
	cprintf("\n");
  8001bc:	8d 83 8f ee ff ff    	lea    -0x1171(%ebx),%eax
  8001c2:	89 04 24             	mov    %eax,(%esp)
  8001c5:	e8 b7 00 00 00       	call   800281 <cprintf>
  8001ca:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cd:	cc                   	int3   
  8001ce:	eb fd                	jmp    8001cd <_panic+0x58>

008001d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
  8001d5:	e8 7c fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8001da:	81 c3 26 1e 00 00    	add    $0x1e26,%ebx
  8001e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e3:	8b 16                	mov    (%esi),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 06                	mov    %eax,(%esi)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	74 0b                	je     800203 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f8:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	68 ff 00 00 00       	push   $0xff
  80020b:	8d 46 08             	lea    0x8(%esi),%eax
  80020e:	50                   	push   %eax
  80020f:	e8 ac fe ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  800214:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021a:	83 c4 10             	add    $0x10,%esp
  80021d:	eb d9                	jmp    8001f8 <putch+0x28>

0080021f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	53                   	push   %ebx
  800223:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800229:	e8 28 fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  80022e:	81 c3 d2 1d 00 00    	add    $0x1dd2,%ebx
	struct printbuf b;

	b.idx = 0;
  800234:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023b:	00 00 00 
	b.cnt = 0;
  80023e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800245:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800248:	ff 75 0c             	push   0xc(%ebp)
  80024b:	ff 75 08             	push   0x8(%ebp)
  80024e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800254:	50                   	push   %eax
  800255:	8d 83 d0 e1 ff ff    	lea    -0x1e30(%ebx),%eax
  80025b:	50                   	push   %eax
  80025c:	e8 2c 01 00 00       	call   80038d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800261:	83 c4 08             	add    $0x8,%esp
  800264:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80026a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	e8 4a fe ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  800276:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800287:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028a:	50                   	push   %eax
  80028b:	ff 75 08             	push   0x8(%ebp)
  80028e:	e8 8c ff ff ff       	call   80021f <vcprintf>
	va_end(ap);

	return cnt;
}
  800293:	c9                   	leave  
  800294:	c3                   	ret    

00800295 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	57                   	push   %edi
  800299:	56                   	push   %esi
  80029a:	53                   	push   %ebx
  80029b:	83 ec 2c             	sub    $0x2c,%esp
  80029e:	e8 cf 05 00 00       	call   800872 <__x86.get_pc_thunk.cx>
  8002a3:	81 c1 5d 1d 00 00    	add    $0x1d5d,%ecx
  8002a9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ac:	89 c7                	mov    %eax,%edi
  8002ae:	89 d6                	mov    %edx,%esi
  8002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b6:	89 d1                	mov    %edx,%ecx
  8002b8:	89 c2                	mov    %eax,%edx
  8002ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002bd:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002d0:	39 c2                	cmp    %eax,%edx
  8002d2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002d5:	72 41                	jb     800318 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d7:	83 ec 0c             	sub    $0xc,%esp
  8002da:	ff 75 18             	push   0x18(%ebp)
  8002dd:	83 eb 01             	sub    $0x1,%ebx
  8002e0:	53                   	push   %ebx
  8002e1:	50                   	push   %eax
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	ff 75 e4             	push   -0x1c(%ebp)
  8002e8:	ff 75 e0             	push   -0x20(%ebp)
  8002eb:	ff 75 d4             	push   -0x2c(%ebp)
  8002ee:	ff 75 d0             	push   -0x30(%ebp)
  8002f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f4:	e8 07 09 00 00       	call   800c00 <__udivdi3>
  8002f9:	83 c4 18             	add    $0x18,%esp
  8002fc:	52                   	push   %edx
  8002fd:	50                   	push   %eax
  8002fe:	89 f2                	mov    %esi,%edx
  800300:	89 f8                	mov    %edi,%eax
  800302:	e8 8e ff ff ff       	call   800295 <printnum>
  800307:	83 c4 20             	add    $0x20,%esp
  80030a:	eb 13                	jmp    80031f <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030c:	83 ec 08             	sub    $0x8,%esp
  80030f:	56                   	push   %esi
  800310:	ff 75 18             	push   0x18(%ebp)
  800313:	ff d7                	call   *%edi
  800315:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f ed                	jg     80030c <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	push   -0x1c(%ebp)
  800329:	ff 75 e0             	push   -0x20(%ebp)
  80032c:	ff 75 d4             	push   -0x2c(%ebp)
  80032f:	ff 75 d0             	push   -0x30(%ebp)
  800332:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800335:	e8 e6 09 00 00       	call   800d20 <__umoddi3>
  80033a:	83 c4 14             	add    $0x14,%esp
  80033d:	0f be 84 03 91 ee ff 	movsbl -0x116f(%ebx,%eax,1),%eax
  800344:	ff 
  800345:	50                   	push   %eax
  800346:	ff d7                	call   *%edi
}
  800348:	83 c4 10             	add    $0x10,%esp
  80034b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034e:	5b                   	pop    %ebx
  80034f:	5e                   	pop    %esi
  800350:	5f                   	pop    %edi
  800351:	5d                   	pop    %ebp
  800352:	c3                   	ret    

00800353 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800359:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80035d:	8b 10                	mov    (%eax),%edx
  80035f:	3b 50 04             	cmp    0x4(%eax),%edx
  800362:	73 0a                	jae    80036e <sprintputch+0x1b>
		*b->buf++ = ch;
  800364:	8d 4a 01             	lea    0x1(%edx),%ecx
  800367:	89 08                	mov    %ecx,(%eax)
  800369:	8b 45 08             	mov    0x8(%ebp),%eax
  80036c:	88 02                	mov    %al,(%edx)
}
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <printfmt>:
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800376:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800379:	50                   	push   %eax
  80037a:	ff 75 10             	push   0x10(%ebp)
  80037d:	ff 75 0c             	push   0xc(%ebp)
  800380:	ff 75 08             	push   0x8(%ebp)
  800383:	e8 05 00 00 00       	call   80038d <vprintfmt>
}
  800388:	83 c4 10             	add    $0x10,%esp
  80038b:	c9                   	leave  
  80038c:	c3                   	ret    

0080038d <vprintfmt>:
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	57                   	push   %edi
  800391:	56                   	push   %esi
  800392:	53                   	push   %ebx
  800393:	83 ec 3c             	sub    $0x3c,%esp
  800396:	e8 d6 fd ff ff       	call   800171 <__x86.get_pc_thunk.ax>
  80039b:	05 65 1c 00 00       	add    $0x1c65,%eax
  8003a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8003a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ac:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8003b2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003b5:	eb 0a                	jmp    8003c1 <vprintfmt+0x34>
			putch(ch, putdat);
  8003b7:	83 ec 08             	sub    $0x8,%esp
  8003ba:	57                   	push   %edi
  8003bb:	50                   	push   %eax
  8003bc:	ff d6                	call   *%esi
  8003be:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c1:	83 c3 01             	add    $0x1,%ebx
  8003c4:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003c8:	83 f8 25             	cmp    $0x25,%eax
  8003cb:	74 0c                	je     8003d9 <vprintfmt+0x4c>
			if (ch == '\0')
  8003cd:	85 c0                	test   %eax,%eax
  8003cf:	75 e6                	jne    8003b7 <vprintfmt+0x2a>
}
  8003d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d4:	5b                   	pop    %ebx
  8003d5:	5e                   	pop    %esi
  8003d6:	5f                   	pop    %edi
  8003d7:	5d                   	pop    %ebp
  8003d8:	c3                   	ret    
		padc = ' ';
  8003d9:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003dd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003e4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003fa:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8d 43 01             	lea    0x1(%ebx),%eax
  800400:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800403:	0f b6 13             	movzbl (%ebx),%edx
  800406:	8d 42 dd             	lea    -0x23(%edx),%eax
  800409:	3c 55                	cmp    $0x55,%al
  80040b:	0f 87 c5 03 00 00    	ja     8007d6 <.L20>
  800411:	0f b6 c0             	movzbl %al,%eax
  800414:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800417:	89 ce                	mov    %ecx,%esi
  800419:	03 b4 81 20 ef ff ff 	add    -0x10e0(%ecx,%eax,4),%esi
  800420:	ff e6                	jmp    *%esi

00800422 <.L66>:
  800422:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800425:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800429:	eb d2                	jmp    8003fd <vprintfmt+0x70>

0080042b <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80042e:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800432:	eb c9                	jmp    8003fd <vprintfmt+0x70>

00800434 <.L31>:
  800434:	0f b6 d2             	movzbl %dl,%edx
  800437:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80043a:	b8 00 00 00 00       	mov    $0x0,%eax
  80043f:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800442:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800445:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800449:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80044c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80044f:	83 f9 09             	cmp    $0x9,%ecx
  800452:	77 58                	ja     8004ac <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800454:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800457:	eb e9                	jmp    800442 <.L31+0xe>

00800459 <.L34>:
			precision = va_arg(ap, int);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8b 00                	mov    (%eax),%eax
  80045e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 40 04             	lea    0x4(%eax),%eax
  800467:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80046d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800471:	79 8a                	jns    8003fd <vprintfmt+0x70>
				width = precision, precision = -1;
  800473:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800476:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800479:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800480:	e9 78 ff ff ff       	jmp    8003fd <vprintfmt+0x70>

00800485 <.L33>:
  800485:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800488:	85 d2                	test   %edx,%edx
  80048a:	b8 00 00 00 00       	mov    $0x0,%eax
  80048f:	0f 49 c2             	cmovns %edx,%eax
  800492:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800498:	e9 60 ff ff ff       	jmp    8003fd <vprintfmt+0x70>

0080049d <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8004a0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004a7:	e9 51 ff ff ff       	jmp    8003fd <vprintfmt+0x70>
  8004ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004af:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b2:	eb b9                	jmp    80046d <.L34+0x14>

008004b4 <.L27>:
			lflag++;
  8004b4:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004bb:	e9 3d ff ff ff       	jmp    8003fd <vprintfmt+0x70>

008004c0 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 58 04             	lea    0x4(%eax),%ebx
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	57                   	push   %edi
  8004cd:	ff 30                	push   (%eax)
  8004cf:	ff d6                	call   *%esi
			break;
  8004d1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004d4:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004d7:	e9 90 02 00 00       	jmp    80076c <.L25+0x45>

008004dc <.L28>:
			err = va_arg(ap, int);
  8004dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 58 04             	lea    0x4(%eax),%ebx
  8004e5:	8b 10                	mov    (%eax),%edx
  8004e7:	89 d0                	mov    %edx,%eax
  8004e9:	f7 d8                	neg    %eax
  8004eb:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ee:	83 f8 06             	cmp    $0x6,%eax
  8004f1:	7f 27                	jg     80051a <.L28+0x3e>
  8004f3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f6:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004f9:	85 d2                	test   %edx,%edx
  8004fb:	74 1d                	je     80051a <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004fd:	52                   	push   %edx
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	8d 80 b2 ee ff ff    	lea    -0x114e(%eax),%eax
  800507:	50                   	push   %eax
  800508:	57                   	push   %edi
  800509:	56                   	push   %esi
  80050a:	e8 61 fe ff ff       	call   800370 <printfmt>
  80050f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800512:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800515:	e9 52 02 00 00       	jmp    80076c <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  80051a:	50                   	push   %eax
  80051b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051e:	8d 80 a9 ee ff ff    	lea    -0x1157(%eax),%eax
  800524:	50                   	push   %eax
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	e8 44 fe ff ff       	call   800370 <printfmt>
  80052c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80052f:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800532:	e9 35 02 00 00       	jmp    80076c <.L25+0x45>

00800537 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 75 08             	mov    0x8(%ebp),%esi
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	83 c0 04             	add    $0x4,%eax
  800540:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800548:	85 d2                	test   %edx,%edx
  80054a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80054d:	8d 80 a2 ee ff ff    	lea    -0x115e(%eax),%eax
  800553:	0f 45 c2             	cmovne %edx,%eax
  800556:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800559:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80055d:	7e 06                	jle    800565 <.L24+0x2e>
  80055f:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800563:	75 0d                	jne    800572 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800568:	89 c3                	mov    %eax,%ebx
  80056a:	03 45 d0             	add    -0x30(%ebp),%eax
  80056d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800570:	eb 58                	jmp    8005ca <.L24+0x93>
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	ff 75 d8             	push   -0x28(%ebp)
  800578:	ff 75 c8             	push   -0x38(%ebp)
  80057b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057e:	e8 0b 03 00 00       	call   80088e <strnlen>
  800583:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800586:	29 c2                	sub    %eax,%edx
  800588:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800590:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800594:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800597:	eb 0f                	jmp    8005a8 <.L24+0x71>
					putch(padc, putdat);
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	57                   	push   %edi
  80059d:	ff 75 d0             	push   -0x30(%ebp)
  8005a0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a2:	83 eb 01             	sub    $0x1,%ebx
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	85 db                	test   %ebx,%ebx
  8005aa:	7f ed                	jg     800599 <.L24+0x62>
  8005ac:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8005af:	85 d2                	test   %edx,%edx
  8005b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b6:	0f 49 c2             	cmovns %edx,%eax
  8005b9:	29 c2                	sub    %eax,%edx
  8005bb:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005be:	eb a5                	jmp    800565 <.L24+0x2e>
					putch(ch, putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	57                   	push   %edi
  8005c4:	52                   	push   %edx
  8005c5:	ff d6                	call   *%esi
  8005c7:	83 c4 10             	add    $0x10,%esp
  8005ca:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005cd:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cf:	83 c3 01             	add    $0x1,%ebx
  8005d2:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005d6:	0f be d0             	movsbl %al,%edx
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	74 4b                	je     800628 <.L24+0xf1>
  8005dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e1:	78 06                	js     8005e9 <.L24+0xb2>
  8005e3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005e7:	78 1e                	js     800607 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005ed:	74 d1                	je     8005c0 <.L24+0x89>
  8005ef:	0f be c0             	movsbl %al,%eax
  8005f2:	83 e8 20             	sub    $0x20,%eax
  8005f5:	83 f8 5e             	cmp    $0x5e,%eax
  8005f8:	76 c6                	jbe    8005c0 <.L24+0x89>
					putch('?', putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	57                   	push   %edi
  8005fe:	6a 3f                	push   $0x3f
  800600:	ff d6                	call   *%esi
  800602:	83 c4 10             	add    $0x10,%esp
  800605:	eb c3                	jmp    8005ca <.L24+0x93>
  800607:	89 cb                	mov    %ecx,%ebx
  800609:	eb 0e                	jmp    800619 <.L24+0xe2>
				putch(' ', putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	57                   	push   %edi
  80060f:	6a 20                	push   $0x20
  800611:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800613:	83 eb 01             	sub    $0x1,%ebx
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	85 db                	test   %ebx,%ebx
  80061b:	7f ee                	jg     80060b <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  80061d:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800620:	89 45 14             	mov    %eax,0x14(%ebp)
  800623:	e9 44 01 00 00       	jmp    80076c <.L25+0x45>
  800628:	89 cb                	mov    %ecx,%ebx
  80062a:	eb ed                	jmp    800619 <.L24+0xe2>

0080062c <.L29>:
	if (lflag >= 2)
  80062c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80062f:	8b 75 08             	mov    0x8(%ebp),%esi
  800632:	83 f9 01             	cmp    $0x1,%ecx
  800635:	7f 1b                	jg     800652 <.L29+0x26>
	else if (lflag)
  800637:	85 c9                	test   %ecx,%ecx
  800639:	74 63                	je     80069e <.L29+0x72>
		return va_arg(*ap, long);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 00                	mov    (%eax),%eax
  800640:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800643:	99                   	cltd   
  800644:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 40 04             	lea    0x4(%eax),%eax
  80064d:	89 45 14             	mov    %eax,0x14(%ebp)
  800650:	eb 17                	jmp    800669 <.L29+0x3d>
		return va_arg(*ap, long long);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 50 04             	mov    0x4(%eax),%edx
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 40 08             	lea    0x8(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800669:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80066c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80066f:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800674:	85 db                	test   %ebx,%ebx
  800676:	0f 89 d6 00 00 00    	jns    800752 <.L25+0x2b>
				putch('-', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	57                   	push   %edi
  800680:	6a 2d                	push   $0x2d
  800682:	ff d6                	call   *%esi
				num = -(long long) num;
  800684:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800687:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80068a:	f7 d9                	neg    %ecx
  80068c:	83 d3 00             	adc    $0x0,%ebx
  80068f:	f7 db                	neg    %ebx
  800691:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800694:	ba 0a 00 00 00       	mov    $0xa,%edx
  800699:	e9 b4 00 00 00       	jmp    800752 <.L25+0x2b>
		return va_arg(*ap, int);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a6:	99                   	cltd   
  8006a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8d 40 04             	lea    0x4(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b3:	eb b4                	jmp    800669 <.L29+0x3d>

008006b5 <.L23>:
	if (lflag >= 2)
  8006b5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bb:	83 f9 01             	cmp    $0x1,%ecx
  8006be:	7f 1b                	jg     8006db <.L23+0x26>
	else if (lflag)
  8006c0:	85 c9                	test   %ecx,%ecx
  8006c2:	74 2c                	je     8006f0 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 08                	mov    (%eax),%ecx
  8006c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ce:	8d 40 04             	lea    0x4(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d4:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006d9:	eb 77                	jmp    800752 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8b 08                	mov    (%eax),%ecx
  8006e0:	8b 58 04             	mov    0x4(%eax),%ebx
  8006e3:	8d 40 08             	lea    0x8(%eax),%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e9:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006ee:	eb 62                	jmp    800752 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8b 08                	mov    (%eax),%ecx
  8006f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fa:	8d 40 04             	lea    0x4(%eax),%eax
  8006fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800700:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800705:	eb 4b                	jmp    800752 <.L25+0x2b>

00800707 <.L26>:
			putch('X', putdat);
  800707:	8b 75 08             	mov    0x8(%ebp),%esi
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	57                   	push   %edi
  80070e:	6a 58                	push   $0x58
  800710:	ff d6                	call   *%esi
			putch('X', putdat);
  800712:	83 c4 08             	add    $0x8,%esp
  800715:	57                   	push   %edi
  800716:	6a 58                	push   $0x58
  800718:	ff d6                	call   *%esi
			putch('X', putdat);
  80071a:	83 c4 08             	add    $0x8,%esp
  80071d:	57                   	push   %edi
  80071e:	6a 58                	push   $0x58
  800720:	ff d6                	call   *%esi
			break;
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	eb 45                	jmp    80076c <.L25+0x45>

00800727 <.L25>:
			putch('0', putdat);
  800727:	8b 75 08             	mov    0x8(%ebp),%esi
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	57                   	push   %edi
  80072e:	6a 30                	push   $0x30
  800730:	ff d6                	call   *%esi
			putch('x', putdat);
  800732:	83 c4 08             	add    $0x8,%esp
  800735:	57                   	push   %edi
  800736:	6a 78                	push   $0x78
  800738:	ff d6                	call   *%esi
			num = (unsigned long long)
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8b 08                	mov    (%eax),%ecx
  80073f:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800744:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800747:	8d 40 04             	lea    0x4(%eax),%eax
  80074a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074d:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800752:	83 ec 0c             	sub    $0xc,%esp
  800755:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800759:	50                   	push   %eax
  80075a:	ff 75 d0             	push   -0x30(%ebp)
  80075d:	52                   	push   %edx
  80075e:	53                   	push   %ebx
  80075f:	51                   	push   %ecx
  800760:	89 fa                	mov    %edi,%edx
  800762:	89 f0                	mov    %esi,%eax
  800764:	e8 2c fb ff ff       	call   800295 <printnum>
			break;
  800769:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80076c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80076f:	e9 4d fc ff ff       	jmp    8003c1 <vprintfmt+0x34>

00800774 <.L21>:
	if (lflag >= 2)
  800774:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800777:	8b 75 08             	mov    0x8(%ebp),%esi
  80077a:	83 f9 01             	cmp    $0x1,%ecx
  80077d:	7f 1b                	jg     80079a <.L21+0x26>
	else if (lflag)
  80077f:	85 c9                	test   %ecx,%ecx
  800781:	74 2c                	je     8007af <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 08                	mov    (%eax),%ecx
  800788:	bb 00 00 00 00       	mov    $0x0,%ebx
  80078d:	8d 40 04             	lea    0x4(%eax),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800793:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  800798:	eb b8                	jmp    800752 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8b 08                	mov    (%eax),%ecx
  80079f:	8b 58 04             	mov    0x4(%eax),%ebx
  8007a2:	8d 40 08             	lea    0x8(%eax),%eax
  8007a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a8:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007ad:	eb a3                	jmp    800752 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8b 08                	mov    (%eax),%ecx
  8007b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b9:	8d 40 04             	lea    0x4(%eax),%eax
  8007bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007bf:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007c4:	eb 8c                	jmp    800752 <.L25+0x2b>

008007c6 <.L35>:
			putch(ch, putdat);
  8007c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	57                   	push   %edi
  8007cd:	6a 25                	push   $0x25
  8007cf:	ff d6                	call   *%esi
			break;
  8007d1:	83 c4 10             	add    $0x10,%esp
  8007d4:	eb 96                	jmp    80076c <.L25+0x45>

008007d6 <.L20>:
			putch('%', putdat);
  8007d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d9:	83 ec 08             	sub    $0x8,%esp
  8007dc:	57                   	push   %edi
  8007dd:	6a 25                	push   $0x25
  8007df:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e1:	83 c4 10             	add    $0x10,%esp
  8007e4:	89 d8                	mov    %ebx,%eax
  8007e6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007ea:	74 05                	je     8007f1 <.L20+0x1b>
  8007ec:	83 e8 01             	sub    $0x1,%eax
  8007ef:	eb f5                	jmp    8007e6 <.L20+0x10>
  8007f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007f4:	e9 73 ff ff ff       	jmp    80076c <.L25+0x45>

008007f9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	53                   	push   %ebx
  8007fd:	83 ec 14             	sub    $0x14,%esp
  800800:	e8 51 f8 ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800805:	81 c3 fb 17 00 00    	add    $0x17fb,%ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800811:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800814:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800818:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80081b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800822:	85 c0                	test   %eax,%eax
  800824:	74 2b                	je     800851 <vsnprintf+0x58>
  800826:	85 d2                	test   %edx,%edx
  800828:	7e 27                	jle    800851 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082a:	ff 75 14             	push   0x14(%ebp)
  80082d:	ff 75 10             	push   0x10(%ebp)
  800830:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800833:	50                   	push   %eax
  800834:	8d 83 53 e3 ff ff    	lea    -0x1cad(%ebx),%eax
  80083a:	50                   	push   %eax
  80083b:	e8 4d fb ff ff       	call   80038d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800840:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800843:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800846:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800849:	83 c4 10             	add    $0x10,%esp
}
  80084c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084f:	c9                   	leave  
  800850:	c3                   	ret    
		return -E_INVAL;
  800851:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800856:	eb f4                	jmp    80084c <vsnprintf+0x53>

00800858 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80085e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800861:	50                   	push   %eax
  800862:	ff 75 10             	push   0x10(%ebp)
  800865:	ff 75 0c             	push   0xc(%ebp)
  800868:	ff 75 08             	push   0x8(%ebp)
  80086b:	e8 89 ff ff ff       	call   8007f9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800870:	c9                   	leave  
  800871:	c3                   	ret    

00800872 <__x86.get_pc_thunk.cx>:
  800872:	8b 0c 24             	mov    (%esp),%ecx
  800875:	c3                   	ret    

00800876 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
  800881:	eb 03                	jmp    800886 <strlen+0x10>
		n++;
  800883:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800886:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80088a:	75 f7                	jne    800883 <strlen+0xd>
	return n;
}
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
  80089c:	eb 03                	jmp    8008a1 <strnlen+0x13>
		n++;
  80089e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a1:	39 d0                	cmp    %edx,%eax
  8008a3:	74 08                	je     8008ad <strnlen+0x1f>
  8008a5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a9:	75 f3                	jne    80089e <strnlen+0x10>
  8008ab:	89 c2                	mov    %eax,%edx
	return n;
}
  8008ad:	89 d0                	mov    %edx,%eax
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	53                   	push   %ebx
  8008b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c0:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008c4:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008c7:	83 c0 01             	add    $0x1,%eax
  8008ca:	84 d2                	test   %dl,%dl
  8008cc:	75 f2                	jne    8008c0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ce:	89 c8                	mov    %ecx,%eax
  8008d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    

008008d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	53                   	push   %ebx
  8008d9:	83 ec 10             	sub    $0x10,%esp
  8008dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008df:	53                   	push   %ebx
  8008e0:	e8 91 ff ff ff       	call   800876 <strlen>
  8008e5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008e8:	ff 75 0c             	push   0xc(%ebp)
  8008eb:	01 d8                	add    %ebx,%eax
  8008ed:	50                   	push   %eax
  8008ee:	e8 be ff ff ff       	call   8008b1 <strcpy>
	return dst;
}
  8008f3:	89 d8                	mov    %ebx,%eax
  8008f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    

008008fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
  800905:	89 f3                	mov    %esi,%ebx
  800907:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090a:	89 f0                	mov    %esi,%eax
  80090c:	eb 0f                	jmp    80091d <strncpy+0x23>
		*dst++ = *src;
  80090e:	83 c0 01             	add    $0x1,%eax
  800911:	0f b6 0a             	movzbl (%edx),%ecx
  800914:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800917:	80 f9 01             	cmp    $0x1,%cl
  80091a:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80091d:	39 d8                	cmp    %ebx,%eax
  80091f:	75 ed                	jne    80090e <strncpy+0x14>
	}
	return ret;
}
  800921:	89 f0                	mov    %esi,%eax
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	56                   	push   %esi
  80092b:	53                   	push   %ebx
  80092c:	8b 75 08             	mov    0x8(%ebp),%esi
  80092f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800932:	8b 55 10             	mov    0x10(%ebp),%edx
  800935:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800937:	85 d2                	test   %edx,%edx
  800939:	74 21                	je     80095c <strlcpy+0x35>
  80093b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80093f:	89 f2                	mov    %esi,%edx
  800941:	eb 09                	jmp    80094c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800943:	83 c1 01             	add    $0x1,%ecx
  800946:	83 c2 01             	add    $0x1,%edx
  800949:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80094c:	39 c2                	cmp    %eax,%edx
  80094e:	74 09                	je     800959 <strlcpy+0x32>
  800950:	0f b6 19             	movzbl (%ecx),%ebx
  800953:	84 db                	test   %bl,%bl
  800955:	75 ec                	jne    800943 <strlcpy+0x1c>
  800957:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800959:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80095c:	29 f0                	sub    %esi,%eax
}
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800968:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096b:	eb 06                	jmp    800973 <strcmp+0x11>
		p++, q++;
  80096d:	83 c1 01             	add    $0x1,%ecx
  800970:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800973:	0f b6 01             	movzbl (%ecx),%eax
  800976:	84 c0                	test   %al,%al
  800978:	74 04                	je     80097e <strcmp+0x1c>
  80097a:	3a 02                	cmp    (%edx),%al
  80097c:	74 ef                	je     80096d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097e:	0f b6 c0             	movzbl %al,%eax
  800981:	0f b6 12             	movzbl (%edx),%edx
  800984:	29 d0                	sub    %edx,%eax
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	53                   	push   %ebx
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800992:	89 c3                	mov    %eax,%ebx
  800994:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800997:	eb 06                	jmp    80099f <strncmp+0x17>
		n--, p++, q++;
  800999:	83 c0 01             	add    $0x1,%eax
  80099c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80099f:	39 d8                	cmp    %ebx,%eax
  8009a1:	74 18                	je     8009bb <strncmp+0x33>
  8009a3:	0f b6 08             	movzbl (%eax),%ecx
  8009a6:	84 c9                	test   %cl,%cl
  8009a8:	74 04                	je     8009ae <strncmp+0x26>
  8009aa:	3a 0a                	cmp    (%edx),%cl
  8009ac:	74 eb                	je     800999 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ae:	0f b6 00             	movzbl (%eax),%eax
  8009b1:	0f b6 12             	movzbl (%edx),%edx
  8009b4:	29 d0                	sub    %edx,%eax
}
  8009b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    
		return 0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c0:	eb f4                	jmp    8009b6 <strncmp+0x2e>

008009c2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cc:	eb 03                	jmp    8009d1 <strchr+0xf>
  8009ce:	83 c0 01             	add    $0x1,%eax
  8009d1:	0f b6 10             	movzbl (%eax),%edx
  8009d4:	84 d2                	test   %dl,%dl
  8009d6:	74 06                	je     8009de <strchr+0x1c>
		if (*s == c)
  8009d8:	38 ca                	cmp    %cl,%dl
  8009da:	75 f2                	jne    8009ce <strchr+0xc>
  8009dc:	eb 05                	jmp    8009e3 <strchr+0x21>
			return (char *) s;
	return 0;
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ef:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f2:	38 ca                	cmp    %cl,%dl
  8009f4:	74 09                	je     8009ff <strfind+0x1a>
  8009f6:	84 d2                	test   %dl,%dl
  8009f8:	74 05                	je     8009ff <strfind+0x1a>
	for (; *s; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	eb f0                	jmp    8009ef <strfind+0xa>
			break;
	return (char *) s;
}
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	57                   	push   %edi
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a0d:	85 c9                	test   %ecx,%ecx
  800a0f:	74 2f                	je     800a40 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a11:	89 f8                	mov    %edi,%eax
  800a13:	09 c8                	or     %ecx,%eax
  800a15:	a8 03                	test   $0x3,%al
  800a17:	75 21                	jne    800a3a <memset+0x39>
		c &= 0xFF;
  800a19:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1d:	89 d0                	mov    %edx,%eax
  800a1f:	c1 e0 08             	shl    $0x8,%eax
  800a22:	89 d3                	mov    %edx,%ebx
  800a24:	c1 e3 18             	shl    $0x18,%ebx
  800a27:	89 d6                	mov    %edx,%esi
  800a29:	c1 e6 10             	shl    $0x10,%esi
  800a2c:	09 f3                	or     %esi,%ebx
  800a2e:	09 da                	or     %ebx,%edx
  800a30:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a32:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a35:	fc                   	cld    
  800a36:	f3 ab                	rep stos %eax,%es:(%edi)
  800a38:	eb 06                	jmp    800a40 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3d:	fc                   	cld    
  800a3e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a40:	89 f8                	mov    %edi,%eax
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a55:	39 c6                	cmp    %eax,%esi
  800a57:	73 32                	jae    800a8b <memmove+0x44>
  800a59:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5c:	39 c2                	cmp    %eax,%edx
  800a5e:	76 2b                	jbe    800a8b <memmove+0x44>
		s += n;
		d += n;
  800a60:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a63:	89 d6                	mov    %edx,%esi
  800a65:	09 fe                	or     %edi,%esi
  800a67:	09 ce                	or     %ecx,%esi
  800a69:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6f:	75 0e                	jne    800a7f <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a71:	83 ef 04             	sub    $0x4,%edi
  800a74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a77:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a7a:	fd                   	std    
  800a7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7d:	eb 09                	jmp    800a88 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a7f:	83 ef 01             	sub    $0x1,%edi
  800a82:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a85:	fd                   	std    
  800a86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a88:	fc                   	cld    
  800a89:	eb 1a                	jmp    800aa5 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8b:	89 f2                	mov    %esi,%edx
  800a8d:	09 c2                	or     %eax,%edx
  800a8f:	09 ca                	or     %ecx,%edx
  800a91:	f6 c2 03             	test   $0x3,%dl
  800a94:	75 0a                	jne    800aa0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a96:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a99:	89 c7                	mov    %eax,%edi
  800a9b:	fc                   	cld    
  800a9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9e:	eb 05                	jmp    800aa5 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800aa0:	89 c7                	mov    %eax,%edi
  800aa2:	fc                   	cld    
  800aa3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aaf:	ff 75 10             	push   0x10(%ebp)
  800ab2:	ff 75 0c             	push   0xc(%ebp)
  800ab5:	ff 75 08             	push   0x8(%ebp)
  800ab8:	e8 8a ff ff ff       	call   800a47 <memmove>
}
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aca:	89 c6                	mov    %eax,%esi
  800acc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acf:	eb 06                	jmp    800ad7 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ad1:	83 c0 01             	add    $0x1,%eax
  800ad4:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ad7:	39 f0                	cmp    %esi,%eax
  800ad9:	74 14                	je     800aef <memcmp+0x30>
		if (*s1 != *s2)
  800adb:	0f b6 08             	movzbl (%eax),%ecx
  800ade:	0f b6 1a             	movzbl (%edx),%ebx
  800ae1:	38 d9                	cmp    %bl,%cl
  800ae3:	74 ec                	je     800ad1 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800ae5:	0f b6 c1             	movzbl %cl,%eax
  800ae8:	0f b6 db             	movzbl %bl,%ebx
  800aeb:	29 d8                	sub    %ebx,%eax
  800aed:	eb 05                	jmp    800af4 <memcmp+0x35>
	}

	return 0;
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b01:	89 c2                	mov    %eax,%edx
  800b03:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b06:	eb 03                	jmp    800b0b <memfind+0x13>
  800b08:	83 c0 01             	add    $0x1,%eax
  800b0b:	39 d0                	cmp    %edx,%eax
  800b0d:	73 04                	jae    800b13 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0f:	38 08                	cmp    %cl,(%eax)
  800b11:	75 f5                	jne    800b08 <memfind+0x10>
			break;
	return (void *) s;
}
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b21:	eb 03                	jmp    800b26 <strtol+0x11>
		s++;
  800b23:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b26:	0f b6 02             	movzbl (%edx),%eax
  800b29:	3c 20                	cmp    $0x20,%al
  800b2b:	74 f6                	je     800b23 <strtol+0xe>
  800b2d:	3c 09                	cmp    $0x9,%al
  800b2f:	74 f2                	je     800b23 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b31:	3c 2b                	cmp    $0x2b,%al
  800b33:	74 2a                	je     800b5f <strtol+0x4a>
	int neg = 0;
  800b35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b3a:	3c 2d                	cmp    $0x2d,%al
  800b3c:	74 2b                	je     800b69 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b44:	75 0f                	jne    800b55 <strtol+0x40>
  800b46:	80 3a 30             	cmpb   $0x30,(%edx)
  800b49:	74 28                	je     800b73 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b4b:	85 db                	test   %ebx,%ebx
  800b4d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b52:	0f 44 d8             	cmove  %eax,%ebx
  800b55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b5d:	eb 46                	jmp    800ba5 <strtol+0x90>
		s++;
  800b5f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b62:	bf 00 00 00 00       	mov    $0x0,%edi
  800b67:	eb d5                	jmp    800b3e <strtol+0x29>
		s++, neg = 1;
  800b69:	83 c2 01             	add    $0x1,%edx
  800b6c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b71:	eb cb                	jmp    800b3e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b73:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b77:	74 0e                	je     800b87 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b79:	85 db                	test   %ebx,%ebx
  800b7b:	75 d8                	jne    800b55 <strtol+0x40>
		s++, base = 8;
  800b7d:	83 c2 01             	add    $0x1,%edx
  800b80:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b85:	eb ce                	jmp    800b55 <strtol+0x40>
		s += 2, base = 16;
  800b87:	83 c2 02             	add    $0x2,%edx
  800b8a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b8f:	eb c4                	jmp    800b55 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b91:	0f be c0             	movsbl %al,%eax
  800b94:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b97:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b9a:	7d 3a                	jge    800bd6 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b9c:	83 c2 01             	add    $0x1,%edx
  800b9f:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ba3:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ba5:	0f b6 02             	movzbl (%edx),%eax
  800ba8:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bab:	89 f3                	mov    %esi,%ebx
  800bad:	80 fb 09             	cmp    $0x9,%bl
  800bb0:	76 df                	jbe    800b91 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bb2:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bb5:	89 f3                	mov    %esi,%ebx
  800bb7:	80 fb 19             	cmp    $0x19,%bl
  800bba:	77 08                	ja     800bc4 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bbc:	0f be c0             	movsbl %al,%eax
  800bbf:	83 e8 57             	sub    $0x57,%eax
  800bc2:	eb d3                	jmp    800b97 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bc4:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bc7:	89 f3                	mov    %esi,%ebx
  800bc9:	80 fb 19             	cmp    $0x19,%bl
  800bcc:	77 08                	ja     800bd6 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bce:	0f be c0             	movsbl %al,%eax
  800bd1:	83 e8 37             	sub    $0x37,%eax
  800bd4:	eb c1                	jmp    800b97 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bda:	74 05                	je     800be1 <strtol+0xcc>
		*endptr = (char *) s;
  800bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdf:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800be1:	89 c8                	mov    %ecx,%eax
  800be3:	f7 d8                	neg    %eax
  800be5:	85 ff                	test   %edi,%edi
  800be7:	0f 45 c8             	cmovne %eax,%ecx
}
  800bea:	89 c8                	mov    %ecx,%eax
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    
  800bf1:	66 90                	xchg   %ax,%ax
  800bf3:	66 90                	xchg   %ax,%ax
  800bf5:	66 90                	xchg   %ax,%ax
  800bf7:	66 90                	xchg   %ax,%ax
  800bf9:	66 90                	xchg   %ax,%ax
  800bfb:	66 90                	xchg   %ax,%ax
  800bfd:	66 90                	xchg   %ax,%ax
  800bff:	90                   	nop

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
