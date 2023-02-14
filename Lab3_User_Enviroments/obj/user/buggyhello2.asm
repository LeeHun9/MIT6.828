
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 30 00 00 00       	call   800061 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 1e 00 00 00       	call   80005d <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs(hello, 1024*1024);
  800045:	68 00 00 10 00       	push   $0x100000
  80004a:	ff b3 0c 00 00 00    	push   0xc(%ebx)
  800050:	e8 72 00 00 00       	call   8000c7 <sys_cputs>
}
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    

0080005d <__x86.get_pc_thunk.bx>:
  80005d:	8b 1c 24             	mov    (%esp),%ebx
  800060:	c3                   	ret    

00800061 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	53                   	push   %ebx
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	e8 f0 ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80006d:	81 c3 93 1f 00 00    	add    $0x1f93,%ebx
  800073:	8b 45 08             	mov    0x8(%ebp),%eax
  800076:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800079:	c7 83 30 00 00 00 00 	movl   $0x0,0x30(%ebx)
  800080:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800083:	85 c0                	test   %eax,%eax
  800085:	7e 08                	jle    80008f <libmain+0x2e>
		binaryname = argv[0];
  800087:	8b 0a                	mov    (%edx),%ecx
  800089:	89 8b 10 00 00 00    	mov    %ecx,0x10(%ebx)

	// call user main routine
	umain(argc, argv);
  80008f:	83 ec 08             	sub    $0x8,%esp
  800092:	52                   	push   %edx
  800093:	50                   	push   %eax
  800094:	e8 9a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800099:	e8 08 00 00 00       	call   8000a6 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 10             	sub    $0x10,%esp
  8000ad:	e8 ab ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8000b2:	81 c3 4e 1f 00 00    	add    $0x1f4e,%ebx
	sys_env_destroy(0);
  8000b8:	6a 00                	push   $0x0
  8000ba:	e8 45 00 00 00       	call   800104 <sys_env_destroy>
}
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c5:	c9                   	leave  
  8000c6:	c3                   	ret    

008000c7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	57                   	push   %edi
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d8:	89 c3                	mov    %eax,%ebx
  8000da:	89 c7                	mov    %eax,%edi
  8000dc:	89 c6                	mov    %eax,%esi
  8000de:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    

008000e5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f5:	89 d1                	mov    %edx,%ecx
  8000f7:	89 d3                	mov    %edx,%ebx
  8000f9:	89 d7                	mov    %edx,%edi
  8000fb:	89 d6                	mov    %edx,%esi
  8000fd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ff:	5b                   	pop    %ebx
  800100:	5e                   	pop    %esi
  800101:	5f                   	pop    %edi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	57                   	push   %edi
  800108:	56                   	push   %esi
  800109:	53                   	push   %ebx
  80010a:	83 ec 1c             	sub    $0x1c,%esp
  80010d:	e8 66 00 00 00       	call   800178 <__x86.get_pc_thunk.ax>
  800112:	05 ee 1e 00 00       	add    $0x1eee,%eax
  800117:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80011a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011f:	8b 55 08             	mov    0x8(%ebp),%edx
  800122:	b8 03 00 00 00       	mov    $0x3,%eax
  800127:	89 cb                	mov    %ecx,%ebx
  800129:	89 cf                	mov    %ecx,%edi
  80012b:	89 ce                	mov    %ecx,%esi
  80012d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80012f:	85 c0                	test   %eax,%eax
  800131:	7f 08                	jg     80013b <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	50                   	push   %eax
  80013f:	6a 03                	push   $0x3
  800141:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800144:	8d 83 4c ee ff ff    	lea    -0x11b4(%ebx),%eax
  80014a:	50                   	push   %eax
  80014b:	6a 23                	push   $0x23
  80014d:	8d 83 69 ee ff ff    	lea    -0x1197(%ebx),%eax
  800153:	50                   	push   %eax
  800154:	e8 23 00 00 00       	call   80017c <_panic>

00800159 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	57                   	push   %edi
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	b8 02 00 00 00       	mov    $0x2,%eax
  800169:	89 d1                	mov    %edx,%ecx
  80016b:	89 d3                	mov    %edx,%ebx
  80016d:	89 d7                	mov    %edx,%edi
  80016f:	89 d6                	mov    %edx,%esi
  800171:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800173:	5b                   	pop    %ebx
  800174:	5e                   	pop    %esi
  800175:	5f                   	pop    %edi
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    

00800178 <__x86.get_pc_thunk.ax>:
  800178:	8b 04 24             	mov    (%esp),%eax
  80017b:	c3                   	ret    

0080017c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	53                   	push   %ebx
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	e8 d3 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80018a:	81 c3 76 1e 00 00    	add    $0x1e76,%ebx
	va_list ap;

	va_start(ap, fmt);
  800190:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800193:	c7 c0 10 20 80 00    	mov    $0x802010,%eax
  800199:	8b 38                	mov    (%eax),%edi
  80019b:	e8 b9 ff ff ff       	call   800159 <sys_getenvid>
  8001a0:	83 ec 0c             	sub    $0xc,%esp
  8001a3:	ff 75 0c             	push   0xc(%ebp)
  8001a6:	ff 75 08             	push   0x8(%ebp)
  8001a9:	57                   	push   %edi
  8001aa:	50                   	push   %eax
  8001ab:	8d 83 78 ee ff ff    	lea    -0x1188(%ebx),%eax
  8001b1:	50                   	push   %eax
  8001b2:	e8 d1 00 00 00       	call   800288 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b7:	83 c4 18             	add    $0x18,%esp
  8001ba:	56                   	push   %esi
  8001bb:	ff 75 10             	push   0x10(%ebp)
  8001be:	e8 63 00 00 00       	call   800226 <vcprintf>
	cprintf("\n");
  8001c3:	8d 83 40 ee ff ff    	lea    -0x11c0(%ebx),%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 b7 00 00 00       	call   800288 <cprintf>
  8001d1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d4:	cc                   	int3   
  8001d5:	eb fd                	jmp    8001d4 <_panic+0x58>

008001d7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
  8001dc:	e8 7c fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8001e1:	81 c3 1f 1e 00 00    	add    $0x1e1f,%ebx
  8001e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001ea:	8b 16                	mov    (%esi),%edx
  8001ec:	8d 42 01             	lea    0x1(%edx),%eax
  8001ef:	89 06                	mov    %eax,(%esi)
  8001f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f4:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fd:	74 0b                	je     80020a <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ff:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800203:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800206:	5b                   	pop    %ebx
  800207:	5e                   	pop    %esi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80020a:	83 ec 08             	sub    $0x8,%esp
  80020d:	68 ff 00 00 00       	push   $0xff
  800212:	8d 46 08             	lea    0x8(%esi),%eax
  800215:	50                   	push   %eax
  800216:	e8 ac fe ff ff       	call   8000c7 <sys_cputs>
		b->idx = 0;
  80021b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	eb d9                	jmp    8001ff <putch+0x28>

00800226 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	53                   	push   %ebx
  80022a:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800230:	e8 28 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  800235:	81 c3 cb 1d 00 00    	add    $0x1dcb,%ebx
	struct printbuf b;

	b.idx = 0;
  80023b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800242:	00 00 00 
	b.cnt = 0;
  800245:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024f:	ff 75 0c             	push   0xc(%ebp)
  800252:	ff 75 08             	push   0x8(%ebp)
  800255:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025b:	50                   	push   %eax
  80025c:	8d 83 d7 e1 ff ff    	lea    -0x1e29(%ebx),%eax
  800262:	50                   	push   %eax
  800263:	e8 2c 01 00 00       	call   800394 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800268:	83 c4 08             	add    $0x8,%esp
  80026b:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800271:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800277:	50                   	push   %eax
  800278:	e8 4a fe ff ff       	call   8000c7 <sys_cputs>

	return b.cnt;
}
  80027d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800283:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 08             	push   0x8(%ebp)
  800295:	e8 8c ff ff ff       	call   800226 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	57                   	push   %edi
  8002a0:	56                   	push   %esi
  8002a1:	53                   	push   %ebx
  8002a2:	83 ec 2c             	sub    $0x2c,%esp
  8002a5:	e8 cf 05 00 00       	call   800879 <__x86.get_pc_thunk.cx>
  8002aa:	81 c1 56 1d 00 00    	add    $0x1d56,%ecx
  8002b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002b3:	89 c7                	mov    %eax,%edi
  8002b5:	89 d6                	mov    %edx,%esi
  8002b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bd:	89 d1                	mov    %edx,%ecx
  8002bf:	89 c2                	mov    %eax,%edx
  8002c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002c4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002d7:	39 c2                	cmp    %eax,%edx
  8002d9:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002dc:	72 41                	jb     80031f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	ff 75 18             	push   0x18(%ebp)
  8002e4:	83 eb 01             	sub    $0x1,%ebx
  8002e7:	53                   	push   %ebx
  8002e8:	50                   	push   %eax
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	ff 75 e4             	push   -0x1c(%ebp)
  8002ef:	ff 75 e0             	push   -0x20(%ebp)
  8002f2:	ff 75 d4             	push   -0x2c(%ebp)
  8002f5:	ff 75 d0             	push   -0x30(%ebp)
  8002f8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002fb:	e8 00 09 00 00       	call   800c00 <__udivdi3>
  800300:	83 c4 18             	add    $0x18,%esp
  800303:	52                   	push   %edx
  800304:	50                   	push   %eax
  800305:	89 f2                	mov    %esi,%edx
  800307:	89 f8                	mov    %edi,%eax
  800309:	e8 8e ff ff ff       	call   80029c <printnum>
  80030e:	83 c4 20             	add    $0x20,%esp
  800311:	eb 13                	jmp    800326 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800313:	83 ec 08             	sub    $0x8,%esp
  800316:	56                   	push   %esi
  800317:	ff 75 18             	push   0x18(%ebp)
  80031a:	ff d7                	call   *%edi
  80031c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031f:	83 eb 01             	sub    $0x1,%ebx
  800322:	85 db                	test   %ebx,%ebx
  800324:	7f ed                	jg     800313 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800326:	83 ec 08             	sub    $0x8,%esp
  800329:	56                   	push   %esi
  80032a:	83 ec 04             	sub    $0x4,%esp
  80032d:	ff 75 e4             	push   -0x1c(%ebp)
  800330:	ff 75 e0             	push   -0x20(%ebp)
  800333:	ff 75 d4             	push   -0x2c(%ebp)
  800336:	ff 75 d0             	push   -0x30(%ebp)
  800339:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80033c:	e8 df 09 00 00       	call   800d20 <__umoddi3>
  800341:	83 c4 14             	add    $0x14,%esp
  800344:	0f be 84 03 9b ee ff 	movsbl -0x1165(%ebx,%eax,1),%eax
  80034b:	ff 
  80034c:	50                   	push   %eax
  80034d:	ff d7                	call   *%edi
}
  80034f:	83 c4 10             	add    $0x10,%esp
  800352:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800355:	5b                   	pop    %ebx
  800356:	5e                   	pop    %esi
  800357:	5f                   	pop    %edi
  800358:	5d                   	pop    %ebp
  800359:	c3                   	ret    

0080035a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800360:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800364:	8b 10                	mov    (%eax),%edx
  800366:	3b 50 04             	cmp    0x4(%eax),%edx
  800369:	73 0a                	jae    800375 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 45 08             	mov    0x8(%ebp),%eax
  800373:	88 02                	mov    %al,(%edx)
}
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <printfmt>:
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800380:	50                   	push   %eax
  800381:	ff 75 10             	push   0x10(%ebp)
  800384:	ff 75 0c             	push   0xc(%ebp)
  800387:	ff 75 08             	push   0x8(%ebp)
  80038a:	e8 05 00 00 00       	call   800394 <vprintfmt>
}
  80038f:	83 c4 10             	add    $0x10,%esp
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <vprintfmt>:
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 3c             	sub    $0x3c,%esp
  80039d:	e8 d6 fd ff ff       	call   800178 <__x86.get_pc_thunk.ax>
  8003a2:	05 5e 1c 00 00       	add    $0x1c5e,%eax
  8003a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b3:	8d 80 14 00 00 00    	lea    0x14(%eax),%eax
  8003b9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003bc:	eb 0a                	jmp    8003c8 <vprintfmt+0x34>
			putch(ch, putdat);
  8003be:	83 ec 08             	sub    $0x8,%esp
  8003c1:	57                   	push   %edi
  8003c2:	50                   	push   %eax
  8003c3:	ff d6                	call   *%esi
  8003c5:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c8:	83 c3 01             	add    $0x1,%ebx
  8003cb:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003cf:	83 f8 25             	cmp    $0x25,%eax
  8003d2:	74 0c                	je     8003e0 <vprintfmt+0x4c>
			if (ch == '\0')
  8003d4:	85 c0                	test   %eax,%eax
  8003d6:	75 e6                	jne    8003be <vprintfmt+0x2a>
}
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    
		padc = ' ';
  8003e0:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003e4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003eb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fe:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800401:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8d 43 01             	lea    0x1(%ebx),%eax
  800407:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040a:	0f b6 13             	movzbl (%ebx),%edx
  80040d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800410:	3c 55                	cmp    $0x55,%al
  800412:	0f 87 c5 03 00 00    	ja     8007dd <.L20>
  800418:	0f b6 c0             	movzbl %al,%eax
  80041b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041e:	89 ce                	mov    %ecx,%esi
  800420:	03 b4 81 28 ef ff ff 	add    -0x10d8(%ecx,%eax,4),%esi
  800427:	ff e6                	jmp    *%esi

00800429 <.L66>:
  800429:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80042c:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800430:	eb d2                	jmp    800404 <vprintfmt+0x70>

00800432 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800435:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800439:	eb c9                	jmp    800404 <vprintfmt+0x70>

0080043b <.L31>:
  80043b:	0f b6 d2             	movzbl %dl,%edx
  80043e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800441:	b8 00 00 00 00       	mov    $0x0,%eax
  800446:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800449:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80044c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800450:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800453:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800456:	83 f9 09             	cmp    $0x9,%ecx
  800459:	77 58                	ja     8004b3 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80045b:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80045e:	eb e9                	jmp    800449 <.L31+0xe>

00800460 <.L34>:
			precision = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8b 00                	mov    (%eax),%eax
  800465:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 40 04             	lea    0x4(%eax),%eax
  80046e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800474:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800478:	79 8a                	jns    800404 <vprintfmt+0x70>
				width = precision, precision = -1;
  80047a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80047d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800480:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800487:	e9 78 ff ff ff       	jmp    800404 <vprintfmt+0x70>

0080048c <.L33>:
  80048c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80048f:	85 d2                	test   %edx,%edx
  800491:	b8 00 00 00 00       	mov    $0x0,%eax
  800496:	0f 49 c2             	cmovns %edx,%eax
  800499:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80049f:	e9 60 ff ff ff       	jmp    800404 <vprintfmt+0x70>

008004a4 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8004a7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004ae:	e9 51 ff ff ff       	jmp    800404 <vprintfmt+0x70>
  8004b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b9:	eb b9                	jmp    800474 <.L34+0x14>

008004bb <.L27>:
			lflag++;
  8004bb:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004c2:	e9 3d ff ff ff       	jmp    800404 <vprintfmt+0x70>

008004c7 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cd:	8d 58 04             	lea    0x4(%eax),%ebx
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	57                   	push   %edi
  8004d4:	ff 30                	push   (%eax)
  8004d6:	ff d6                	call   *%esi
			break;
  8004d8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004db:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004de:	e9 90 02 00 00       	jmp    800773 <.L25+0x45>

008004e3 <.L28>:
			err = va_arg(ap, int);
  8004e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8d 58 04             	lea    0x4(%eax),%ebx
  8004ec:	8b 10                	mov    (%eax),%edx
  8004ee:	89 d0                	mov    %edx,%eax
  8004f0:	f7 d8                	neg    %eax
  8004f2:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f5:	83 f8 06             	cmp    $0x6,%eax
  8004f8:	7f 27                	jg     800521 <.L28+0x3e>
  8004fa:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004fd:	8b 14 82             	mov    (%edx,%eax,4),%edx
  800500:	85 d2                	test   %edx,%edx
  800502:	74 1d                	je     800521 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  800504:	52                   	push   %edx
  800505:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800508:	8d 80 bc ee ff ff    	lea    -0x1144(%eax),%eax
  80050e:	50                   	push   %eax
  80050f:	57                   	push   %edi
  800510:	56                   	push   %esi
  800511:	e8 61 fe ff ff       	call   800377 <printfmt>
  800516:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800519:	89 5d 14             	mov    %ebx,0x14(%ebp)
  80051c:	e9 52 02 00 00       	jmp    800773 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800521:	50                   	push   %eax
  800522:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800525:	8d 80 b3 ee ff ff    	lea    -0x114d(%eax),%eax
  80052b:	50                   	push   %eax
  80052c:	57                   	push   %edi
  80052d:	56                   	push   %esi
  80052e:	e8 44 fe ff ff       	call   800377 <printfmt>
  800533:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800536:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800539:	e9 35 02 00 00       	jmp    800773 <.L25+0x45>

0080053e <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  80053e:	8b 75 08             	mov    0x8(%ebp),%esi
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	83 c0 04             	add    $0x4,%eax
  800547:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80054f:	85 d2                	test   %edx,%edx
  800551:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800554:	8d 80 ac ee ff ff    	lea    -0x1154(%eax),%eax
  80055a:	0f 45 c2             	cmovne %edx,%eax
  80055d:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800560:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800564:	7e 06                	jle    80056c <.L24+0x2e>
  800566:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  80056a:	75 0d                	jne    800579 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80056c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80056f:	89 c3                	mov    %eax,%ebx
  800571:	03 45 d0             	add    -0x30(%ebp),%eax
  800574:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800577:	eb 58                	jmp    8005d1 <.L24+0x93>
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	ff 75 d8             	push   -0x28(%ebp)
  80057f:	ff 75 c8             	push   -0x38(%ebp)
  800582:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800585:	e8 0b 03 00 00       	call   800895 <strnlen>
  80058a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80058d:	29 c2                	sub    %eax,%edx
  80058f:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800597:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80059b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80059e:	eb 0f                	jmp    8005af <.L24+0x71>
					putch(padc, putdat);
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	57                   	push   %edi
  8005a4:	ff 75 d0             	push   -0x30(%ebp)
  8005a7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a9:	83 eb 01             	sub    $0x1,%ebx
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	85 db                	test   %ebx,%ebx
  8005b1:	7f ed                	jg     8005a0 <.L24+0x62>
  8005b3:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8005b6:	85 d2                	test   %edx,%edx
  8005b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bd:	0f 49 c2             	cmovns %edx,%eax
  8005c0:	29 c2                	sub    %eax,%edx
  8005c2:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005c5:	eb a5                	jmp    80056c <.L24+0x2e>
					putch(ch, putdat);
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	57                   	push   %edi
  8005cb:	52                   	push   %edx
  8005cc:	ff d6                	call   *%esi
  8005ce:	83 c4 10             	add    $0x10,%esp
  8005d1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005d4:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d6:	83 c3 01             	add    $0x1,%ebx
  8005d9:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005dd:	0f be d0             	movsbl %al,%edx
  8005e0:	85 d2                	test   %edx,%edx
  8005e2:	74 4b                	je     80062f <.L24+0xf1>
  8005e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e8:	78 06                	js     8005f0 <.L24+0xb2>
  8005ea:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005ee:	78 1e                	js     80060e <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005f0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005f4:	74 d1                	je     8005c7 <.L24+0x89>
  8005f6:	0f be c0             	movsbl %al,%eax
  8005f9:	83 e8 20             	sub    $0x20,%eax
  8005fc:	83 f8 5e             	cmp    $0x5e,%eax
  8005ff:	76 c6                	jbe    8005c7 <.L24+0x89>
					putch('?', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	57                   	push   %edi
  800605:	6a 3f                	push   $0x3f
  800607:	ff d6                	call   *%esi
  800609:	83 c4 10             	add    $0x10,%esp
  80060c:	eb c3                	jmp    8005d1 <.L24+0x93>
  80060e:	89 cb                	mov    %ecx,%ebx
  800610:	eb 0e                	jmp    800620 <.L24+0xe2>
				putch(' ', putdat);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	57                   	push   %edi
  800616:	6a 20                	push   $0x20
  800618:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80061a:	83 eb 01             	sub    $0x1,%ebx
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	85 db                	test   %ebx,%ebx
  800622:	7f ee                	jg     800612 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800624:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800627:	89 45 14             	mov    %eax,0x14(%ebp)
  80062a:	e9 44 01 00 00       	jmp    800773 <.L25+0x45>
  80062f:	89 cb                	mov    %ecx,%ebx
  800631:	eb ed                	jmp    800620 <.L24+0xe2>

00800633 <.L29>:
	if (lflag >= 2)
  800633:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800636:	8b 75 08             	mov    0x8(%ebp),%esi
  800639:	83 f9 01             	cmp    $0x1,%ecx
  80063c:	7f 1b                	jg     800659 <.L29+0x26>
	else if (lflag)
  80063e:	85 c9                	test   %ecx,%ecx
  800640:	74 63                	je     8006a5 <.L29+0x72>
		return va_arg(*ap, long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 00                	mov    (%eax),%eax
  800647:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064a:	99                   	cltd   
  80064b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 40 04             	lea    0x4(%eax),%eax
  800654:	89 45 14             	mov    %eax,0x14(%ebp)
  800657:	eb 17                	jmp    800670 <.L29+0x3d>
		return va_arg(*ap, long long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 50 04             	mov    0x4(%eax),%edx
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800664:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8d 40 08             	lea    0x8(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800670:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800673:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800676:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80067b:	85 db                	test   %ebx,%ebx
  80067d:	0f 89 d6 00 00 00    	jns    800759 <.L25+0x2b>
				putch('-', putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	57                   	push   %edi
  800687:	6a 2d                	push   $0x2d
  800689:	ff d6                	call   *%esi
				num = -(long long) num;
  80068b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80068e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800691:	f7 d9                	neg    %ecx
  800693:	83 d3 00             	adc    $0x0,%ebx
  800696:	f7 db                	neg    %ebx
  800698:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80069b:	ba 0a 00 00 00       	mov    $0xa,%edx
  8006a0:	e9 b4 00 00 00       	jmp    800759 <.L25+0x2b>
		return va_arg(*ap, int);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 00                	mov    (%eax),%eax
  8006aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ad:	99                   	cltd   
  8006ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 40 04             	lea    0x4(%eax),%eax
  8006b7:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ba:	eb b4                	jmp    800670 <.L29+0x3d>

008006bc <.L23>:
	if (lflag >= 2)
  8006bc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c2:	83 f9 01             	cmp    $0x1,%ecx
  8006c5:	7f 1b                	jg     8006e2 <.L23+0x26>
	else if (lflag)
  8006c7:	85 c9                	test   %ecx,%ecx
  8006c9:	74 2c                	je     8006f7 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8b 08                	mov    (%eax),%ecx
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	8d 40 04             	lea    0x4(%eax),%eax
  8006d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006db:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006e0:	eb 77                	jmp    800759 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8b 08                	mov    (%eax),%ecx
  8006e7:	8b 58 04             	mov    0x4(%eax),%ebx
  8006ea:	8d 40 08             	lea    0x8(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f0:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006f5:	eb 62                	jmp    800759 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8b 08                	mov    (%eax),%ecx
  8006fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800701:	8d 40 04             	lea    0x4(%eax),%eax
  800704:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800707:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  80070c:	eb 4b                	jmp    800759 <.L25+0x2b>

0080070e <.L26>:
			putch('X', putdat);
  80070e:	8b 75 08             	mov    0x8(%ebp),%esi
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	57                   	push   %edi
  800715:	6a 58                	push   $0x58
  800717:	ff d6                	call   *%esi
			putch('X', putdat);
  800719:	83 c4 08             	add    $0x8,%esp
  80071c:	57                   	push   %edi
  80071d:	6a 58                	push   $0x58
  80071f:	ff d6                	call   *%esi
			putch('X', putdat);
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	57                   	push   %edi
  800725:	6a 58                	push   $0x58
  800727:	ff d6                	call   *%esi
			break;
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	eb 45                	jmp    800773 <.L25+0x45>

0080072e <.L25>:
			putch('0', putdat);
  80072e:	8b 75 08             	mov    0x8(%ebp),%esi
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	57                   	push   %edi
  800735:	6a 30                	push   $0x30
  800737:	ff d6                	call   *%esi
			putch('x', putdat);
  800739:	83 c4 08             	add    $0x8,%esp
  80073c:	57                   	push   %edi
  80073d:	6a 78                	push   $0x78
  80073f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8b 08                	mov    (%eax),%ecx
  800746:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80074b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80074e:	8d 40 04             	lea    0x4(%eax),%eax
  800751:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800754:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800759:	83 ec 0c             	sub    $0xc,%esp
  80075c:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800760:	50                   	push   %eax
  800761:	ff 75 d0             	push   -0x30(%ebp)
  800764:	52                   	push   %edx
  800765:	53                   	push   %ebx
  800766:	51                   	push   %ecx
  800767:	89 fa                	mov    %edi,%edx
  800769:	89 f0                	mov    %esi,%eax
  80076b:	e8 2c fb ff ff       	call   80029c <printnum>
			break;
  800770:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800773:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800776:	e9 4d fc ff ff       	jmp    8003c8 <vprintfmt+0x34>

0080077b <.L21>:
	if (lflag >= 2)
  80077b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80077e:	8b 75 08             	mov    0x8(%ebp),%esi
  800781:	83 f9 01             	cmp    $0x1,%ecx
  800784:	7f 1b                	jg     8007a1 <.L21+0x26>
	else if (lflag)
  800786:	85 c9                	test   %ecx,%ecx
  800788:	74 2c                	je     8007b6 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8b 08                	mov    (%eax),%ecx
  80078f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800794:	8d 40 04             	lea    0x4(%eax),%eax
  800797:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079a:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  80079f:	eb b8                	jmp    800759 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8007a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a4:	8b 08                	mov    (%eax),%ecx
  8007a6:	8b 58 04             	mov    0x4(%eax),%ebx
  8007a9:	8d 40 08             	lea    0x8(%eax),%eax
  8007ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007af:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007b4:	eb a3                	jmp    800759 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8b 08                	mov    (%eax),%ecx
  8007bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007c0:	8d 40 04             	lea    0x4(%eax),%eax
  8007c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c6:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007cb:	eb 8c                	jmp    800759 <.L25+0x2b>

008007cd <.L35>:
			putch(ch, putdat);
  8007cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	57                   	push   %edi
  8007d4:	6a 25                	push   $0x25
  8007d6:	ff d6                	call   *%esi
			break;
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	eb 96                	jmp    800773 <.L25+0x45>

008007dd <.L20>:
			putch('%', putdat);
  8007dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e0:	83 ec 08             	sub    $0x8,%esp
  8007e3:	57                   	push   %edi
  8007e4:	6a 25                	push   $0x25
  8007e6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	89 d8                	mov    %ebx,%eax
  8007ed:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007f1:	74 05                	je     8007f8 <.L20+0x1b>
  8007f3:	83 e8 01             	sub    $0x1,%eax
  8007f6:	eb f5                	jmp    8007ed <.L20+0x10>
  8007f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007fb:	e9 73 ff ff ff       	jmp    800773 <.L25+0x45>

00800800 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	53                   	push   %ebx
  800804:	83 ec 14             	sub    $0x14,%esp
  800807:	e8 51 f8 ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80080c:	81 c3 f4 17 00 00    	add    $0x17f4,%ebx
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800818:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80081b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800822:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800829:	85 c0                	test   %eax,%eax
  80082b:	74 2b                	je     800858 <vsnprintf+0x58>
  80082d:	85 d2                	test   %edx,%edx
  80082f:	7e 27                	jle    800858 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800831:	ff 75 14             	push   0x14(%ebp)
  800834:	ff 75 10             	push   0x10(%ebp)
  800837:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80083a:	50                   	push   %eax
  80083b:	8d 83 5a e3 ff ff    	lea    -0x1ca6(%ebx),%eax
  800841:	50                   	push   %eax
  800842:	e8 4d fb ff ff       	call   800394 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800847:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80084a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800850:	83 c4 10             	add    $0x10,%esp
}
  800853:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800856:	c9                   	leave  
  800857:	c3                   	ret    
		return -E_INVAL;
  800858:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80085d:	eb f4                	jmp    800853 <vsnprintf+0x53>

0080085f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800865:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800868:	50                   	push   %eax
  800869:	ff 75 10             	push   0x10(%ebp)
  80086c:	ff 75 0c             	push   0xc(%ebp)
  80086f:	ff 75 08             	push   0x8(%ebp)
  800872:	e8 89 ff ff ff       	call   800800 <vsnprintf>
	va_end(ap);

	return rc;
}
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <__x86.get_pc_thunk.cx>:
  800879:	8b 0c 24             	mov    (%esp),%ecx
  80087c:	c3                   	ret    

0080087d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
  800888:	eb 03                	jmp    80088d <strlen+0x10>
		n++;
  80088a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80088d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800891:	75 f7                	jne    80088a <strlen+0xd>
	return n;
}
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a3:	eb 03                	jmp    8008a8 <strnlen+0x13>
		n++;
  8008a5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a8:	39 d0                	cmp    %edx,%eax
  8008aa:	74 08                	je     8008b4 <strnlen+0x1f>
  8008ac:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008b0:	75 f3                	jne    8008a5 <strnlen+0x10>
  8008b2:	89 c2                	mov    %eax,%edx
	return n;
}
  8008b4:	89 d0                	mov    %edx,%eax
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008cb:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	84 d2                	test   %dl,%dl
  8008d3:	75 f2                	jne    8008c7 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d5:	89 c8                	mov    %ecx,%eax
  8008d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	53                   	push   %ebx
  8008e0:	83 ec 10             	sub    $0x10,%esp
  8008e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e6:	53                   	push   %ebx
  8008e7:	e8 91 ff ff ff       	call   80087d <strlen>
  8008ec:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ef:	ff 75 0c             	push   0xc(%ebp)
  8008f2:	01 d8                	add    %ebx,%eax
  8008f4:	50                   	push   %eax
  8008f5:	e8 be ff ff ff       	call   8008b8 <strcpy>
	return dst;
}
  8008fa:	89 d8                	mov    %ebx,%eax
  8008fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    

00800901 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	8b 75 08             	mov    0x8(%ebp),%esi
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090c:	89 f3                	mov    %esi,%ebx
  80090e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800911:	89 f0                	mov    %esi,%eax
  800913:	eb 0f                	jmp    800924 <strncpy+0x23>
		*dst++ = *src;
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	0f b6 0a             	movzbl (%edx),%ecx
  80091b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091e:	80 f9 01             	cmp    $0x1,%cl
  800921:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800924:	39 d8                	cmp    %ebx,%eax
  800926:	75 ed                	jne    800915 <strncpy+0x14>
	}
	return ret;
}
  800928:	89 f0                	mov    %esi,%eax
  80092a:	5b                   	pop    %ebx
  80092b:	5e                   	pop    %esi
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
  800933:	8b 75 08             	mov    0x8(%ebp),%esi
  800936:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800939:	8b 55 10             	mov    0x10(%ebp),%edx
  80093c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093e:	85 d2                	test   %edx,%edx
  800940:	74 21                	je     800963 <strlcpy+0x35>
  800942:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800946:	89 f2                	mov    %esi,%edx
  800948:	eb 09                	jmp    800953 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094a:	83 c1 01             	add    $0x1,%ecx
  80094d:	83 c2 01             	add    $0x1,%edx
  800950:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800953:	39 c2                	cmp    %eax,%edx
  800955:	74 09                	je     800960 <strlcpy+0x32>
  800957:	0f b6 19             	movzbl (%ecx),%ebx
  80095a:	84 db                	test   %bl,%bl
  80095c:	75 ec                	jne    80094a <strlcpy+0x1c>
  80095e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800960:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800963:	29 f0                	sub    %esi,%eax
}
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800972:	eb 06                	jmp    80097a <strcmp+0x11>
		p++, q++;
  800974:	83 c1 01             	add    $0x1,%ecx
  800977:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80097a:	0f b6 01             	movzbl (%ecx),%eax
  80097d:	84 c0                	test   %al,%al
  80097f:	74 04                	je     800985 <strcmp+0x1c>
  800981:	3a 02                	cmp    (%edx),%al
  800983:	74 ef                	je     800974 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800985:	0f b6 c0             	movzbl %al,%eax
  800988:	0f b6 12             	movzbl (%edx),%edx
  80098b:	29 d0                	sub    %edx,%eax
}
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	53                   	push   %ebx
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 55 0c             	mov    0xc(%ebp),%edx
  800999:	89 c3                	mov    %eax,%ebx
  80099b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80099e:	eb 06                	jmp    8009a6 <strncmp+0x17>
		n--, p++, q++;
  8009a0:	83 c0 01             	add    $0x1,%eax
  8009a3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009a6:	39 d8                	cmp    %ebx,%eax
  8009a8:	74 18                	je     8009c2 <strncmp+0x33>
  8009aa:	0f b6 08             	movzbl (%eax),%ecx
  8009ad:	84 c9                	test   %cl,%cl
  8009af:	74 04                	je     8009b5 <strncmp+0x26>
  8009b1:	3a 0a                	cmp    (%edx),%cl
  8009b3:	74 eb                	je     8009a0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b5:	0f b6 00             	movzbl (%eax),%eax
  8009b8:	0f b6 12             	movzbl (%edx),%edx
  8009bb:	29 d0                	sub    %edx,%eax
}
  8009bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c0:	c9                   	leave  
  8009c1:	c3                   	ret    
		return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c7:	eb f4                	jmp    8009bd <strncmp+0x2e>

008009c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d3:	eb 03                	jmp    8009d8 <strchr+0xf>
  8009d5:	83 c0 01             	add    $0x1,%eax
  8009d8:	0f b6 10             	movzbl (%eax),%edx
  8009db:	84 d2                	test   %dl,%dl
  8009dd:	74 06                	je     8009e5 <strchr+0x1c>
		if (*s == c)
  8009df:	38 ca                	cmp    %cl,%dl
  8009e1:	75 f2                	jne    8009d5 <strchr+0xc>
  8009e3:	eb 05                	jmp    8009ea <strchr+0x21>
			return (char *) s;
	return 0;
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f9:	38 ca                	cmp    %cl,%dl
  8009fb:	74 09                	je     800a06 <strfind+0x1a>
  8009fd:	84 d2                	test   %dl,%dl
  8009ff:	74 05                	je     800a06 <strfind+0x1a>
	for (; *s; s++)
  800a01:	83 c0 01             	add    $0x1,%eax
  800a04:	eb f0                	jmp    8009f6 <strfind+0xa>
			break;
	return (char *) s;
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	53                   	push   %ebx
  800a0e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a11:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a14:	85 c9                	test   %ecx,%ecx
  800a16:	74 2f                	je     800a47 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a18:	89 f8                	mov    %edi,%eax
  800a1a:	09 c8                	or     %ecx,%eax
  800a1c:	a8 03                	test   $0x3,%al
  800a1e:	75 21                	jne    800a41 <memset+0x39>
		c &= 0xFF;
  800a20:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a24:	89 d0                	mov    %edx,%eax
  800a26:	c1 e0 08             	shl    $0x8,%eax
  800a29:	89 d3                	mov    %edx,%ebx
  800a2b:	c1 e3 18             	shl    $0x18,%ebx
  800a2e:	89 d6                	mov    %edx,%esi
  800a30:	c1 e6 10             	shl    $0x10,%esi
  800a33:	09 f3                	or     %esi,%ebx
  800a35:	09 da                	or     %ebx,%edx
  800a37:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a39:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a3c:	fc                   	cld    
  800a3d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3f:	eb 06                	jmp    800a47 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a44:	fc                   	cld    
  800a45:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a47:	89 f8                	mov    %edi,%eax
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	57                   	push   %edi
  800a52:	56                   	push   %esi
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a59:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5c:	39 c6                	cmp    %eax,%esi
  800a5e:	73 32                	jae    800a92 <memmove+0x44>
  800a60:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a63:	39 c2                	cmp    %eax,%edx
  800a65:	76 2b                	jbe    800a92 <memmove+0x44>
		s += n;
		d += n;
  800a67:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6a:	89 d6                	mov    %edx,%esi
  800a6c:	09 fe                	or     %edi,%esi
  800a6e:	09 ce                	or     %ecx,%esi
  800a70:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a76:	75 0e                	jne    800a86 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a78:	83 ef 04             	sub    $0x4,%edi
  800a7b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a81:	fd                   	std    
  800a82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a84:	eb 09                	jmp    800a8f <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a86:	83 ef 01             	sub    $0x1,%edi
  800a89:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a8c:	fd                   	std    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8f:	fc                   	cld    
  800a90:	eb 1a                	jmp    800aac <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a92:	89 f2                	mov    %esi,%edx
  800a94:	09 c2                	or     %eax,%edx
  800a96:	09 ca                	or     %ecx,%edx
  800a98:	f6 c2 03             	test   $0x3,%dl
  800a9b:	75 0a                	jne    800aa7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aa0:	89 c7                	mov    %eax,%edi
  800aa2:	fc                   	cld    
  800aa3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa5:	eb 05                	jmp    800aac <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800aa7:	89 c7                	mov    %eax,%edi
  800aa9:	fc                   	cld    
  800aaa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aac:	5e                   	pop    %esi
  800aad:	5f                   	pop    %edi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab6:	ff 75 10             	push   0x10(%ebp)
  800ab9:	ff 75 0c             	push   0xc(%ebp)
  800abc:	ff 75 08             	push   0x8(%ebp)
  800abf:	e8 8a ff ff ff       	call   800a4e <memmove>
}
  800ac4:	c9                   	leave  
  800ac5:	c3                   	ret    

00800ac6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad1:	89 c6                	mov    %eax,%esi
  800ad3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad6:	eb 06                	jmp    800ade <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ad8:	83 c0 01             	add    $0x1,%eax
  800adb:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ade:	39 f0                	cmp    %esi,%eax
  800ae0:	74 14                	je     800af6 <memcmp+0x30>
		if (*s1 != *s2)
  800ae2:	0f b6 08             	movzbl (%eax),%ecx
  800ae5:	0f b6 1a             	movzbl (%edx),%ebx
  800ae8:	38 d9                	cmp    %bl,%cl
  800aea:	74 ec                	je     800ad8 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800aec:	0f b6 c1             	movzbl %cl,%eax
  800aef:	0f b6 db             	movzbl %bl,%ebx
  800af2:	29 d8                	sub    %ebx,%eax
  800af4:	eb 05                	jmp    800afb <memcmp+0x35>
	}

	return 0;
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b08:	89 c2                	mov    %eax,%edx
  800b0a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b0d:	eb 03                	jmp    800b12 <memfind+0x13>
  800b0f:	83 c0 01             	add    $0x1,%eax
  800b12:	39 d0                	cmp    %edx,%eax
  800b14:	73 04                	jae    800b1a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b16:	38 08                	cmp    %cl,(%eax)
  800b18:	75 f5                	jne    800b0f <memfind+0x10>
			break;
	return (void *) s;
}
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b28:	eb 03                	jmp    800b2d <strtol+0x11>
		s++;
  800b2a:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b2d:	0f b6 02             	movzbl (%edx),%eax
  800b30:	3c 20                	cmp    $0x20,%al
  800b32:	74 f6                	je     800b2a <strtol+0xe>
  800b34:	3c 09                	cmp    $0x9,%al
  800b36:	74 f2                	je     800b2a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b38:	3c 2b                	cmp    $0x2b,%al
  800b3a:	74 2a                	je     800b66 <strtol+0x4a>
	int neg = 0;
  800b3c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b41:	3c 2d                	cmp    $0x2d,%al
  800b43:	74 2b                	je     800b70 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b45:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4b:	75 0f                	jne    800b5c <strtol+0x40>
  800b4d:	80 3a 30             	cmpb   $0x30,(%edx)
  800b50:	74 28                	je     800b7a <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b52:	85 db                	test   %ebx,%ebx
  800b54:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b59:	0f 44 d8             	cmove  %eax,%ebx
  800b5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b61:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b64:	eb 46                	jmp    800bac <strtol+0x90>
		s++;
  800b66:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b69:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6e:	eb d5                	jmp    800b45 <strtol+0x29>
		s++, neg = 1;
  800b70:	83 c2 01             	add    $0x1,%edx
  800b73:	bf 01 00 00 00       	mov    $0x1,%edi
  800b78:	eb cb                	jmp    800b45 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7a:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b7e:	74 0e                	je     800b8e <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b80:	85 db                	test   %ebx,%ebx
  800b82:	75 d8                	jne    800b5c <strtol+0x40>
		s++, base = 8;
  800b84:	83 c2 01             	add    $0x1,%edx
  800b87:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b8c:	eb ce                	jmp    800b5c <strtol+0x40>
		s += 2, base = 16;
  800b8e:	83 c2 02             	add    $0x2,%edx
  800b91:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b96:	eb c4                	jmp    800b5c <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b98:	0f be c0             	movsbl %al,%eax
  800b9b:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9e:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ba1:	7d 3a                	jge    800bdd <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ba3:	83 c2 01             	add    $0x1,%edx
  800ba6:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800baa:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bac:	0f b6 02             	movzbl (%edx),%eax
  800baf:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bb2:	89 f3                	mov    %esi,%ebx
  800bb4:	80 fb 09             	cmp    $0x9,%bl
  800bb7:	76 df                	jbe    800b98 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bb9:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bbc:	89 f3                	mov    %esi,%ebx
  800bbe:	80 fb 19             	cmp    $0x19,%bl
  800bc1:	77 08                	ja     800bcb <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bc3:	0f be c0             	movsbl %al,%eax
  800bc6:	83 e8 57             	sub    $0x57,%eax
  800bc9:	eb d3                	jmp    800b9e <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bcb:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bce:	89 f3                	mov    %esi,%ebx
  800bd0:	80 fb 19             	cmp    $0x19,%bl
  800bd3:	77 08                	ja     800bdd <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bd5:	0f be c0             	movsbl %al,%eax
  800bd8:	83 e8 37             	sub    $0x37,%eax
  800bdb:	eb c1                	jmp    800b9e <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bdd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be1:	74 05                	je     800be8 <strtol+0xcc>
		*endptr = (char *) s;
  800be3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be6:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800be8:	89 c8                	mov    %ecx,%eax
  800bea:	f7 d8                	neg    %eax
  800bec:	85 ff                	test   %edi,%edi
  800bee:	0f 45 c8             	cmovne %eax,%ecx
}
  800bf1:	89 c8                	mov    %ecx,%eax
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5f                   	pop    %edi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    
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
