
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 e0 17 00       	mov    $0x17e000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 1b 01 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f010004c:	81 c3 1c d8 07 00    	add    $0x7d81c,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 00 00 18 f0    	mov    $0xf0180000,%eax
f0100058:	c7 c2 e0 f0 17 f0    	mov    $0xf017f0e0,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 d3 44 00 00       	call   f010453c <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 4f 05 00 00       	call   f01005bd <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 18 71 f8 ff    	lea    -0x78ee8(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 bd 34 00 00       	call   f010353f <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 16 12 00 00       	call   f010129d <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 43 30 00 00       	call   f01030cf <env_init>
	trap_init();
f010008c:	e8 61 35 00 00       	call   f01035f2 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100091:	83 c4 08             	add    $0x8,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 f4 ff ff ff    	push   -0xc(%ebx)
f010009c:	e8 6a 31 00 00       	call   f010320b <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a1:	83 c4 04             	add    $0x4,%esp
f01000a4:	c7 c0 54 f3 17 f0    	mov    $0xf017f354,%eax
f01000aa:	ff 30                	push   (%eax)
f01000ac:	e8 dd 33 00 00       	call   f010348e <env_run>

f01000b1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b1:	55                   	push   %ebp
f01000b2:	89 e5                	mov    %esp,%ebp
f01000b4:	56                   	push   %esi
f01000b5:	53                   	push   %ebx
f01000b6:	e8 ac 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f01000bb:	81 c3 ad d7 07 00    	add    $0x7d7ad,%ebx
	va_list ap;

	if (panicstr)
f01000c1:	83 bb 78 18 00 00 00 	cmpl   $0x0,0x1878(%ebx)
f01000c8:	74 0f                	je     f01000d9 <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000ca:	83 ec 0c             	sub    $0xc,%esp
f01000cd:	6a 00                	push   $0x0
f01000cf:	e8 54 07 00 00       	call   f0100828 <monitor>
f01000d4:	83 c4 10             	add    $0x10,%esp
f01000d7:	eb f1                	jmp    f01000ca <_panic+0x19>
	panicstr = fmt;
f01000d9:	8b 45 10             	mov    0x10(%ebp),%eax
f01000dc:	89 83 78 18 00 00    	mov    %eax,0x1878(%ebx)
	asm volatile("cli; cld");
f01000e2:	fa                   	cli    
f01000e3:	fc                   	cld    
	va_start(ap, fmt);
f01000e4:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e7:	83 ec 04             	sub    $0x4,%esp
f01000ea:	ff 75 0c             	push   0xc(%ebp)
f01000ed:	ff 75 08             	push   0x8(%ebp)
f01000f0:	8d 83 33 71 f8 ff    	lea    -0x78ecd(%ebx),%eax
f01000f6:	50                   	push   %eax
f01000f7:	e8 43 34 00 00       	call   f010353f <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	56                   	push   %esi
f0100100:	ff 75 10             	push   0x10(%ebp)
f0100103:	e8 00 34 00 00       	call   f0103508 <vcprintf>
	cprintf("\n");
f0100108:	8d 83 fa 7f f8 ff    	lea    -0x78006(%ebx),%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 29 34 00 00       	call   f010353f <cprintf>
f0100116:	83 c4 10             	add    $0x10,%esp
f0100119:	eb af                	jmp    f01000ca <_panic+0x19>

f010011b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010011b:	55                   	push   %ebp
f010011c:	89 e5                	mov    %esp,%ebp
f010011e:	56                   	push   %esi
f010011f:	53                   	push   %ebx
f0100120:	e8 42 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100125:	81 c3 43 d7 07 00    	add    $0x7d743,%ebx
	va_list ap;

	va_start(ap, fmt);
f010012b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010012e:	83 ec 04             	sub    $0x4,%esp
f0100131:	ff 75 0c             	push   0xc(%ebp)
f0100134:	ff 75 08             	push   0x8(%ebp)
f0100137:	8d 83 4b 71 f8 ff    	lea    -0x78eb5(%ebx),%eax
f010013d:	50                   	push   %eax
f010013e:	e8 fc 33 00 00       	call   f010353f <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	56                   	push   %esi
f0100147:	ff 75 10             	push   0x10(%ebp)
f010014a:	e8 b9 33 00 00       	call   f0103508 <vcprintf>
	cprintf("\n");
f010014f:	8d 83 fa 7f f8 ff    	lea    -0x78006(%ebx),%eax
f0100155:	89 04 24             	mov    %eax,(%esp)
f0100158:	e8 e2 33 00 00       	call   f010353f <cprintf>
	va_end(ap);
}
f010015d:	83 c4 10             	add    $0x10,%esp
f0100160:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100163:	5b                   	pop    %ebx
f0100164:	5e                   	pop    %esi
f0100165:	5d                   	pop    %ebp
f0100166:	c3                   	ret    

f0100167 <__x86.get_pc_thunk.bx>:
f0100167:	8b 1c 24             	mov    (%esp),%ebx
f010016a:	c3                   	ret    

f010016b <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010016b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100170:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100171:	a8 01                	test   $0x1,%al
f0100173:	74 0a                	je     f010017f <serial_proc_data+0x14>
f0100175:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010017a:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010017b:	0f b6 c0             	movzbl %al,%eax
f010017e:	c3                   	ret    
		return -1;
f010017f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100184:	c3                   	ret    

f0100185 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100185:	55                   	push   %ebp
f0100186:	89 e5                	mov    %esp,%ebp
f0100188:	57                   	push   %edi
f0100189:	56                   	push   %esi
f010018a:	53                   	push   %ebx
f010018b:	83 ec 1c             	sub    $0x1c,%esp
f010018e:	e8 6a 05 00 00       	call   f01006fd <__x86.get_pc_thunk.si>
f0100193:	81 c6 d5 d6 07 00    	add    $0x7d6d5,%esi
f0100199:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f010019b:	8d 1d b8 18 00 00    	lea    0x18b8,%ebx
f01001a1:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001a7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001aa:	eb 25                	jmp    f01001d1 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f01001ac:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f01001b3:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b6:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01001b9:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001bc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01001c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01001c7:	0f 44 d0             	cmove  %eax,%edx
f01001ca:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f01001d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01001d4:	ff d0                	call   *%eax
f01001d6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d9:	74 06                	je     f01001e1 <cons_intr+0x5c>
		if (c == 0)
f01001db:	85 c0                	test   %eax,%eax
f01001dd:	75 cd                	jne    f01001ac <cons_intr+0x27>
f01001df:	eb f0                	jmp    f01001d1 <cons_intr+0x4c>
	}
}
f01001e1:	83 c4 1c             	add    $0x1c,%esp
f01001e4:	5b                   	pop    %ebx
f01001e5:	5e                   	pop    %esi
f01001e6:	5f                   	pop    %edi
f01001e7:	5d                   	pop    %ebp
f01001e8:	c3                   	ret    

f01001e9 <kbd_proc_data>:
{
f01001e9:	55                   	push   %ebp
f01001ea:	89 e5                	mov    %esp,%ebp
f01001ec:	56                   	push   %esi
f01001ed:	53                   	push   %ebx
f01001ee:	e8 74 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01001f3:	81 c3 75 d6 07 00    	add    $0x7d675,%ebx
f01001f9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001fe:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001ff:	a8 01                	test   $0x1,%al
f0100201:	0f 84 f7 00 00 00    	je     f01002fe <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f0100207:	a8 20                	test   $0x20,%al
f0100209:	0f 85 f6 00 00 00    	jne    f0100305 <kbd_proc_data+0x11c>
f010020f:	ba 60 00 00 00       	mov    $0x60,%edx
f0100214:	ec                   	in     (%dx),%al
f0100215:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100217:	3c e0                	cmp    $0xe0,%al
f0100219:	74 64                	je     f010027f <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f010021b:	84 c0                	test   %al,%al
f010021d:	78 75                	js     f0100294 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f010021f:	8b 8b 98 18 00 00    	mov    0x1898(%ebx),%ecx
f0100225:	f6 c1 40             	test   $0x40,%cl
f0100228:	74 0e                	je     f0100238 <kbd_proc_data+0x4f>
		data |= 0x80;
f010022a:	83 c8 80             	or     $0xffffff80,%eax
f010022d:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010022f:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100232:	89 8b 98 18 00 00    	mov    %ecx,0x1898(%ebx)
	shift |= shiftcode[data];
f0100238:	0f b6 d2             	movzbl %dl,%edx
f010023b:	0f b6 84 13 98 72 f8 	movzbl -0x78d68(%ebx,%edx,1),%eax
f0100242:	ff 
f0100243:	0b 83 98 18 00 00    	or     0x1898(%ebx),%eax
	shift ^= togglecode[data];
f0100249:	0f b6 8c 13 98 71 f8 	movzbl -0x78e68(%ebx,%edx,1),%ecx
f0100250:	ff 
f0100251:	31 c8                	xor    %ecx,%eax
f0100253:	89 83 98 18 00 00    	mov    %eax,0x1898(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100259:	89 c1                	mov    %eax,%ecx
f010025b:	83 e1 03             	and    $0x3,%ecx
f010025e:	8b 8c 8b b8 17 00 00 	mov    0x17b8(%ebx,%ecx,4),%ecx
f0100265:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100269:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f010026c:	a8 08                	test   $0x8,%al
f010026e:	74 61                	je     f01002d1 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f0100270:	89 f2                	mov    %esi,%edx
f0100272:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100275:	83 f9 19             	cmp    $0x19,%ecx
f0100278:	77 4b                	ja     f01002c5 <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f010027a:	83 ee 20             	sub    $0x20,%esi
f010027d:	eb 0c                	jmp    f010028b <kbd_proc_data+0xa2>
		shift |= E0ESC;
f010027f:	83 8b 98 18 00 00 40 	orl    $0x40,0x1898(%ebx)
		return 0;
f0100286:	be 00 00 00 00       	mov    $0x0,%esi
}
f010028b:	89 f0                	mov    %esi,%eax
f010028d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100290:	5b                   	pop    %ebx
f0100291:	5e                   	pop    %esi
f0100292:	5d                   	pop    %ebp
f0100293:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100294:	8b 8b 98 18 00 00    	mov    0x1898(%ebx),%ecx
f010029a:	83 e0 7f             	and    $0x7f,%eax
f010029d:	f6 c1 40             	test   $0x40,%cl
f01002a0:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002a3:	0f b6 d2             	movzbl %dl,%edx
f01002a6:	0f b6 84 13 98 72 f8 	movzbl -0x78d68(%ebx,%edx,1),%eax
f01002ad:	ff 
f01002ae:	83 c8 40             	or     $0x40,%eax
f01002b1:	0f b6 c0             	movzbl %al,%eax
f01002b4:	f7 d0                	not    %eax
f01002b6:	21 c8                	and    %ecx,%eax
f01002b8:	89 83 98 18 00 00    	mov    %eax,0x1898(%ebx)
		return 0;
f01002be:	be 00 00 00 00       	mov    $0x0,%esi
f01002c3:	eb c6                	jmp    f010028b <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f01002c5:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002c8:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002cb:	83 fa 1a             	cmp    $0x1a,%edx
f01002ce:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002d1:	f7 d0                	not    %eax
f01002d3:	a8 06                	test   $0x6,%al
f01002d5:	75 b4                	jne    f010028b <kbd_proc_data+0xa2>
f01002d7:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002dd:	75 ac                	jne    f010028b <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f01002df:	83 ec 0c             	sub    $0xc,%esp
f01002e2:	8d 83 65 71 f8 ff    	lea    -0x78e9b(%ebx),%eax
f01002e8:	50                   	push   %eax
f01002e9:	e8 51 32 00 00       	call   f010353f <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ee:	b8 03 00 00 00       	mov    $0x3,%eax
f01002f3:	ba 92 00 00 00       	mov    $0x92,%edx
f01002f8:	ee                   	out    %al,(%dx)
}
f01002f9:	83 c4 10             	add    $0x10,%esp
f01002fc:	eb 8d                	jmp    f010028b <kbd_proc_data+0xa2>
		return -1;
f01002fe:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100303:	eb 86                	jmp    f010028b <kbd_proc_data+0xa2>
		return -1;
f0100305:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010030a:	e9 7c ff ff ff       	jmp    f010028b <kbd_proc_data+0xa2>

f010030f <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010030f:	55                   	push   %ebp
f0100310:	89 e5                	mov    %esp,%ebp
f0100312:	57                   	push   %edi
f0100313:	56                   	push   %esi
f0100314:	53                   	push   %ebx
f0100315:	83 ec 1c             	sub    $0x1c,%esp
f0100318:	e8 4a fe ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010031d:	81 c3 4b d5 07 00    	add    $0x7d54b,%ebx
f0100323:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100326:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010032b:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100330:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100335:	89 fa                	mov    %edi,%edx
f0100337:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100338:	a8 20                	test   $0x20,%al
f010033a:	75 13                	jne    f010034f <cons_putc+0x40>
f010033c:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100342:	7f 0b                	jg     f010034f <cons_putc+0x40>
f0100344:	89 ca                	mov    %ecx,%edx
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	ec                   	in     (%dx),%al
f0100349:	ec                   	in     (%dx),%al
	     i++)
f010034a:	83 c6 01             	add    $0x1,%esi
f010034d:	eb e6                	jmp    f0100335 <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f010034f:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100353:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100356:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010035b:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010035c:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100361:	bf 79 03 00 00       	mov    $0x379,%edi
f0100366:	b9 84 00 00 00       	mov    $0x84,%ecx
f010036b:	89 fa                	mov    %edi,%edx
f010036d:	ec                   	in     (%dx),%al
f010036e:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100374:	7f 0f                	jg     f0100385 <cons_putc+0x76>
f0100376:	84 c0                	test   %al,%al
f0100378:	78 0b                	js     f0100385 <cons_putc+0x76>
f010037a:	89 ca                	mov    %ecx,%edx
f010037c:	ec                   	in     (%dx),%al
f010037d:	ec                   	in     (%dx),%al
f010037e:	ec                   	in     (%dx),%al
f010037f:	ec                   	in     (%dx),%al
f0100380:	83 c6 01             	add    $0x1,%esi
f0100383:	eb e6                	jmp    f010036b <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100385:	ba 78 03 00 00       	mov    $0x378,%edx
f010038a:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f010038e:	ee                   	out    %al,(%dx)
f010038f:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100394:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100399:	ee                   	out    %al,(%dx)
f010039a:	b8 08 00 00 00       	mov    $0x8,%eax
f010039f:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003a3:	89 f8                	mov    %edi,%eax
f01003a5:	80 cc 07             	or     $0x7,%ah
f01003a8:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003ae:	0f 45 c7             	cmovne %edi,%eax
f01003b1:	89 c7                	mov    %eax,%edi
f01003b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003b6:	0f b6 c0             	movzbl %al,%eax
f01003b9:	89 f9                	mov    %edi,%ecx
f01003bb:	80 f9 0a             	cmp    $0xa,%cl
f01003be:	0f 84 e4 00 00 00    	je     f01004a8 <cons_putc+0x199>
f01003c4:	83 f8 0a             	cmp    $0xa,%eax
f01003c7:	7f 46                	jg     f010040f <cons_putc+0x100>
f01003c9:	83 f8 08             	cmp    $0x8,%eax
f01003cc:	0f 84 a8 00 00 00    	je     f010047a <cons_putc+0x16b>
f01003d2:	83 f8 09             	cmp    $0x9,%eax
f01003d5:	0f 85 da 00 00 00    	jne    f01004b5 <cons_putc+0x1a6>
		cons_putc(' ');
f01003db:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e0:	e8 2a ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f01003e5:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ea:	e8 20 ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f01003ef:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f4:	e8 16 ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f01003f9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fe:	e8 0c ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f0100403:	b8 20 00 00 00       	mov    $0x20,%eax
f0100408:	e8 02 ff ff ff       	call   f010030f <cons_putc>
		break;
f010040d:	eb 26                	jmp    f0100435 <cons_putc+0x126>
	switch (c & 0xff) {
f010040f:	83 f8 0d             	cmp    $0xd,%eax
f0100412:	0f 85 9d 00 00 00    	jne    f01004b5 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100418:	0f b7 83 c0 1a 00 00 	movzwl 0x1ac0(%ebx),%eax
f010041f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100425:	c1 e8 16             	shr    $0x16,%eax
f0100428:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010042b:	c1 e0 04             	shl    $0x4,%eax
f010042e:	66 89 83 c0 1a 00 00 	mov    %ax,0x1ac0(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100435:	66 81 bb c0 1a 00 00 	cmpw   $0x7cf,0x1ac0(%ebx)
f010043c:	cf 07 
f010043e:	0f 87 98 00 00 00    	ja     f01004dc <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100444:	8b 8b c8 1a 00 00    	mov    0x1ac8(%ebx),%ecx
f010044a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010044f:	89 ca                	mov    %ecx,%edx
f0100451:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100452:	0f b7 9b c0 1a 00 00 	movzwl 0x1ac0(%ebx),%ebx
f0100459:	8d 71 01             	lea    0x1(%ecx),%esi
f010045c:	89 d8                	mov    %ebx,%eax
f010045e:	66 c1 e8 08          	shr    $0x8,%ax
f0100462:	89 f2                	mov    %esi,%edx
f0100464:	ee                   	out    %al,(%dx)
f0100465:	b8 0f 00 00 00       	mov    $0xf,%eax
f010046a:	89 ca                	mov    %ecx,%edx
f010046c:	ee                   	out    %al,(%dx)
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	89 f2                	mov    %esi,%edx
f0100471:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100472:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100475:	5b                   	pop    %ebx
f0100476:	5e                   	pop    %esi
f0100477:	5f                   	pop    %edi
f0100478:	5d                   	pop    %ebp
f0100479:	c3                   	ret    
		if (crt_pos > 0) {
f010047a:	0f b7 83 c0 1a 00 00 	movzwl 0x1ac0(%ebx),%eax
f0100481:	66 85 c0             	test   %ax,%ax
f0100484:	74 be                	je     f0100444 <cons_putc+0x135>
			crt_pos--;
f0100486:	83 e8 01             	sub    $0x1,%eax
f0100489:	66 89 83 c0 1a 00 00 	mov    %ax,0x1ac0(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100490:	0f b7 c0             	movzwl %ax,%eax
f0100493:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100497:	b2 00                	mov    $0x0,%dl
f0100499:	83 ca 20             	or     $0x20,%edx
f010049c:	8b 8b c4 1a 00 00    	mov    0x1ac4(%ebx),%ecx
f01004a2:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004a6:	eb 8d                	jmp    f0100435 <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004a8:	66 83 83 c0 1a 00 00 	addw   $0x50,0x1ac0(%ebx)
f01004af:	50 
f01004b0:	e9 63 ff ff ff       	jmp    f0100418 <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004b5:	0f b7 83 c0 1a 00 00 	movzwl 0x1ac0(%ebx),%eax
f01004bc:	8d 50 01             	lea    0x1(%eax),%edx
f01004bf:	66 89 93 c0 1a 00 00 	mov    %dx,0x1ac0(%ebx)
f01004c6:	0f b7 c0             	movzwl %ax,%eax
f01004c9:	8b 93 c4 1a 00 00    	mov    0x1ac4(%ebx),%edx
f01004cf:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004d3:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f01004d7:	e9 59 ff ff ff       	jmp    f0100435 <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004dc:	8b 83 c4 1a 00 00    	mov    0x1ac4(%ebx),%eax
f01004e2:	83 ec 04             	sub    $0x4,%esp
f01004e5:	68 00 0f 00 00       	push   $0xf00
f01004ea:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004f0:	52                   	push   %edx
f01004f1:	50                   	push   %eax
f01004f2:	e8 8b 40 00 00       	call   f0104582 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004f7:	8b 93 c4 1a 00 00    	mov    0x1ac4(%ebx),%edx
f01004fd:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100503:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100509:	83 c4 10             	add    $0x10,%esp
f010050c:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100511:	83 c0 02             	add    $0x2,%eax
f0100514:	39 d0                	cmp    %edx,%eax
f0100516:	75 f4                	jne    f010050c <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100518:	66 83 ab c0 1a 00 00 	subw   $0x50,0x1ac0(%ebx)
f010051f:	50 
f0100520:	e9 1f ff ff ff       	jmp    f0100444 <cons_putc+0x135>

f0100525 <serial_intr>:
{
f0100525:	e8 cf 01 00 00       	call   f01006f9 <__x86.get_pc_thunk.ax>
f010052a:	05 3e d3 07 00       	add    $0x7d33e,%eax
	if (serial_exists)
f010052f:	80 b8 cc 1a 00 00 00 	cmpb   $0x0,0x1acc(%eax)
f0100536:	75 01                	jne    f0100539 <serial_intr+0x14>
f0100538:	c3                   	ret    
{
f0100539:	55                   	push   %ebp
f010053a:	89 e5                	mov    %esp,%ebp
f010053c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010053f:	8d 80 03 29 f8 ff    	lea    -0x7d6fd(%eax),%eax
f0100545:	e8 3b fc ff ff       	call   f0100185 <cons_intr>
}
f010054a:	c9                   	leave  
f010054b:	c3                   	ret    

f010054c <kbd_intr>:
{
f010054c:	55                   	push   %ebp
f010054d:	89 e5                	mov    %esp,%ebp
f010054f:	83 ec 08             	sub    $0x8,%esp
f0100552:	e8 a2 01 00 00       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0100557:	05 11 d3 07 00       	add    $0x7d311,%eax
	cons_intr(kbd_proc_data);
f010055c:	8d 80 81 29 f8 ff    	lea    -0x7d67f(%eax),%eax
f0100562:	e8 1e fc ff ff       	call   f0100185 <cons_intr>
}
f0100567:	c9                   	leave  
f0100568:	c3                   	ret    

f0100569 <cons_getc>:
{
f0100569:	55                   	push   %ebp
f010056a:	89 e5                	mov    %esp,%ebp
f010056c:	53                   	push   %ebx
f010056d:	83 ec 04             	sub    $0x4,%esp
f0100570:	e8 f2 fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100575:	81 c3 f3 d2 07 00    	add    $0x7d2f3,%ebx
	serial_intr();
f010057b:	e8 a5 ff ff ff       	call   f0100525 <serial_intr>
	kbd_intr();
f0100580:	e8 c7 ff ff ff       	call   f010054c <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100585:	8b 83 b8 1a 00 00    	mov    0x1ab8(%ebx),%eax
	return 0;
f010058b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100590:	3b 83 bc 1a 00 00    	cmp    0x1abc(%ebx),%eax
f0100596:	74 1e                	je     f01005b6 <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f0100598:	8d 48 01             	lea    0x1(%eax),%ecx
f010059b:	0f b6 94 03 b8 18 00 	movzbl 0x18b8(%ebx,%eax,1),%edx
f01005a2:	00 
			cons.rpos = 0;
f01005a3:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ad:	0f 45 c1             	cmovne %ecx,%eax
f01005b0:	89 83 b8 1a 00 00    	mov    %eax,0x1ab8(%ebx)
}
f01005b6:	89 d0                	mov    %edx,%eax
f01005b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01005bb:	c9                   	leave  
f01005bc:	c3                   	ret    

f01005bd <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005bd:	55                   	push   %ebp
f01005be:	89 e5                	mov    %esp,%ebp
f01005c0:	57                   	push   %edi
f01005c1:	56                   	push   %esi
f01005c2:	53                   	push   %ebx
f01005c3:	83 ec 1c             	sub    $0x1c,%esp
f01005c6:	e8 9c fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01005cb:	81 c3 9d d2 07 00    	add    $0x7d29d,%ebx
	was = *cp;
f01005d1:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005d8:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005df:	5a a5 
	if (*cp != 0xA55A) {
f01005e1:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005e8:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005ed:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f01005f2:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005f6:	0f 84 ac 00 00 00    	je     f01006a8 <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f01005fc:	89 8b c8 1a 00 00    	mov    %ecx,0x1ac8(%ebx)
f0100602:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100607:	89 ca                	mov    %ecx,%edx
f0100609:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010060a:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060d:	89 f2                	mov    %esi,%edx
f010060f:	ec                   	in     (%dx),%al
f0100610:	0f b6 c0             	movzbl %al,%eax
f0100613:	c1 e0 08             	shl    $0x8,%eax
f0100616:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100619:	b8 0f 00 00 00       	mov    $0xf,%eax
f010061e:	89 ca                	mov    %ecx,%edx
f0100620:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100621:	89 f2                	mov    %esi,%edx
f0100623:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100624:	89 bb c4 1a 00 00    	mov    %edi,0x1ac4(%ebx)
	pos |= inb(addr_6845 + 1);
f010062a:	0f b6 c0             	movzbl %al,%eax
f010062d:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f0100630:	66 89 83 c0 1a 00 00 	mov    %ax,0x1ac0(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100637:	b9 00 00 00 00       	mov    $0x0,%ecx
f010063c:	89 c8                	mov    %ecx,%eax
f010063e:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100643:	ee                   	out    %al,(%dx)
f0100644:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100649:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010064e:	89 fa                	mov    %edi,%edx
f0100650:	ee                   	out    %al,(%dx)
f0100651:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100656:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010065b:	ee                   	out    %al,(%dx)
f010065c:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100661:	89 c8                	mov    %ecx,%eax
f0100663:	89 f2                	mov    %esi,%edx
f0100665:	ee                   	out    %al,(%dx)
f0100666:	b8 03 00 00 00       	mov    $0x3,%eax
f010066b:	89 fa                	mov    %edi,%edx
f010066d:	ee                   	out    %al,(%dx)
f010066e:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100673:	89 c8                	mov    %ecx,%eax
f0100675:	ee                   	out    %al,(%dx)
f0100676:	b8 01 00 00 00       	mov    $0x1,%eax
f010067b:	89 f2                	mov    %esi,%edx
f010067d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010067e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100683:	ec                   	in     (%dx),%al
f0100684:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100686:	3c ff                	cmp    $0xff,%al
f0100688:	0f 95 83 cc 1a 00 00 	setne  0x1acc(%ebx)
f010068f:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100694:	ec                   	in     (%dx),%al
f0100695:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010069a:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010069b:	80 f9 ff             	cmp    $0xff,%cl
f010069e:	74 1e                	je     f01006be <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f01006a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006a3:	5b                   	pop    %ebx
f01006a4:	5e                   	pop    %esi
f01006a5:	5f                   	pop    %edi
f01006a6:	5d                   	pop    %ebp
f01006a7:	c3                   	ret    
		*cp = was;
f01006a8:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f01006af:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006b4:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f01006b9:	e9 3e ff ff ff       	jmp    f01005fc <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f01006be:	83 ec 0c             	sub    $0xc,%esp
f01006c1:	8d 83 71 71 f8 ff    	lea    -0x78e8f(%ebx),%eax
f01006c7:	50                   	push   %eax
f01006c8:	e8 72 2e 00 00       	call   f010353f <cprintf>
f01006cd:	83 c4 10             	add    $0x10,%esp
}
f01006d0:	eb ce                	jmp    f01006a0 <cons_init+0xe3>

f01006d2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006d2:	55                   	push   %ebp
f01006d3:	89 e5                	mov    %esp,%ebp
f01006d5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01006db:	e8 2f fc ff ff       	call   f010030f <cons_putc>
}
f01006e0:	c9                   	leave  
f01006e1:	c3                   	ret    

f01006e2 <getchar>:

int
getchar(void)
{
f01006e2:	55                   	push   %ebp
f01006e3:	89 e5                	mov    %esp,%ebp
f01006e5:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006e8:	e8 7c fe ff ff       	call   f0100569 <cons_getc>
f01006ed:	85 c0                	test   %eax,%eax
f01006ef:	74 f7                	je     f01006e8 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006f1:	c9                   	leave  
f01006f2:	c3                   	ret    

f01006f3 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01006f3:	b8 01 00 00 00       	mov    $0x1,%eax
f01006f8:	c3                   	ret    

f01006f9 <__x86.get_pc_thunk.ax>:
f01006f9:	8b 04 24             	mov    (%esp),%eax
f01006fc:	c3                   	ret    

f01006fd <__x86.get_pc_thunk.si>:
f01006fd:	8b 34 24             	mov    (%esp),%esi
f0100700:	c3                   	ret    

f0100701 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100701:	55                   	push   %ebp
f0100702:	89 e5                	mov    %esp,%ebp
f0100704:	56                   	push   %esi
f0100705:	53                   	push   %ebx
f0100706:	e8 5c fa ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010070b:	81 c3 5d d1 07 00    	add    $0x7d15d,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100711:	83 ec 04             	sub    $0x4,%esp
f0100714:	8d 83 98 73 f8 ff    	lea    -0x78c68(%ebx),%eax
f010071a:	50                   	push   %eax
f010071b:	8d 83 b6 73 f8 ff    	lea    -0x78c4a(%ebx),%eax
f0100721:	50                   	push   %eax
f0100722:	8d b3 bb 73 f8 ff    	lea    -0x78c45(%ebx),%esi
f0100728:	56                   	push   %esi
f0100729:	e8 11 2e 00 00       	call   f010353f <cprintf>
f010072e:	83 c4 0c             	add    $0xc,%esp
f0100731:	8d 83 24 74 f8 ff    	lea    -0x78bdc(%ebx),%eax
f0100737:	50                   	push   %eax
f0100738:	8d 83 c4 73 f8 ff    	lea    -0x78c3c(%ebx),%eax
f010073e:	50                   	push   %eax
f010073f:	56                   	push   %esi
f0100740:	e8 fa 2d 00 00       	call   f010353f <cprintf>
	return 0;
}
f0100745:	b8 00 00 00 00       	mov    $0x0,%eax
f010074a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010074d:	5b                   	pop    %ebx
f010074e:	5e                   	pop    %esi
f010074f:	5d                   	pop    %ebp
f0100750:	c3                   	ret    

f0100751 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100751:	55                   	push   %ebp
f0100752:	89 e5                	mov    %esp,%ebp
f0100754:	57                   	push   %edi
f0100755:	56                   	push   %esi
f0100756:	53                   	push   %ebx
f0100757:	83 ec 18             	sub    $0x18,%esp
f010075a:	e8 08 fa ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010075f:	81 c3 09 d1 07 00    	add    $0x7d109,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100765:	8d 83 cd 73 f8 ff    	lea    -0x78c33(%ebx),%eax
f010076b:	50                   	push   %eax
f010076c:	e8 ce 2d 00 00       	call   f010353f <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100771:	83 c4 08             	add    $0x8,%esp
f0100774:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f010077a:	8d 83 4c 74 f8 ff    	lea    -0x78bb4(%ebx),%eax
f0100780:	50                   	push   %eax
f0100781:	e8 b9 2d 00 00       	call   f010353f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100786:	83 c4 0c             	add    $0xc,%esp
f0100789:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010078f:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100795:	50                   	push   %eax
f0100796:	57                   	push   %edi
f0100797:	8d 83 74 74 f8 ff    	lea    -0x78b8c(%ebx),%eax
f010079d:	50                   	push   %eax
f010079e:	e8 9c 2d 00 00       	call   f010353f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007a3:	83 c4 0c             	add    $0xc,%esp
f01007a6:	c7 c0 61 49 10 f0    	mov    $0xf0104961,%eax
f01007ac:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007b2:	52                   	push   %edx
f01007b3:	50                   	push   %eax
f01007b4:	8d 83 98 74 f8 ff    	lea    -0x78b68(%ebx),%eax
f01007ba:	50                   	push   %eax
f01007bb:	e8 7f 2d 00 00       	call   f010353f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007c0:	83 c4 0c             	add    $0xc,%esp
f01007c3:	c7 c0 e0 f0 17 f0    	mov    $0xf017f0e0,%eax
f01007c9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007cf:	52                   	push   %edx
f01007d0:	50                   	push   %eax
f01007d1:	8d 83 bc 74 f8 ff    	lea    -0x78b44(%ebx),%eax
f01007d7:	50                   	push   %eax
f01007d8:	e8 62 2d 00 00       	call   f010353f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007dd:	83 c4 0c             	add    $0xc,%esp
f01007e0:	c7 c6 00 00 18 f0    	mov    $0xf0180000,%esi
f01007e6:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007ec:	50                   	push   %eax
f01007ed:	56                   	push   %esi
f01007ee:	8d 83 e0 74 f8 ff    	lea    -0x78b20(%ebx),%eax
f01007f4:	50                   	push   %eax
f01007f5:	e8 45 2d 00 00       	call   f010353f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007fa:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01007fd:	29 fe                	sub    %edi,%esi
f01007ff:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100805:	c1 fe 0a             	sar    $0xa,%esi
f0100808:	56                   	push   %esi
f0100809:	8d 83 04 75 f8 ff    	lea    -0x78afc(%ebx),%eax
f010080f:	50                   	push   %eax
f0100810:	e8 2a 2d 00 00       	call   f010353f <cprintf>
	return 0;
}
f0100815:	b8 00 00 00 00       	mov    $0x0,%eax
f010081a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010081d:	5b                   	pop    %ebx
f010081e:	5e                   	pop    %esi
f010081f:	5f                   	pop    %edi
f0100820:	5d                   	pop    %ebp
f0100821:	c3                   	ret    

f0100822 <mon_backtrace>:
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	return 0;
}
f0100822:	b8 00 00 00 00       	mov    $0x0,%eax
f0100827:	c3                   	ret    

f0100828 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100828:	55                   	push   %ebp
f0100829:	89 e5                	mov    %esp,%ebp
f010082b:	57                   	push   %edi
f010082c:	56                   	push   %esi
f010082d:	53                   	push   %ebx
f010082e:	83 ec 68             	sub    $0x68,%esp
f0100831:	e8 31 f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100836:	81 c3 32 d0 07 00    	add    $0x7d032,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010083c:	8d 83 30 75 f8 ff    	lea    -0x78ad0(%ebx),%eax
f0100842:	50                   	push   %eax
f0100843:	e8 f7 2c 00 00       	call   f010353f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100848:	8d 83 54 75 f8 ff    	lea    -0x78aac(%ebx),%eax
f010084e:	89 04 24             	mov    %eax,(%esp)
f0100851:	e8 e9 2c 00 00       	call   f010353f <cprintf>

	if (tf != NULL)
f0100856:	83 c4 10             	add    $0x10,%esp
f0100859:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010085d:	74 0e                	je     f010086d <monitor+0x45>
		print_trapframe(tf);
f010085f:	83 ec 0c             	sub    $0xc,%esp
f0100862:	ff 75 08             	push   0x8(%ebp)
f0100865:	e8 3e 2e 00 00       	call   f01036a8 <print_trapframe>
f010086a:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010086d:	8d bb ea 73 f8 ff    	lea    -0x78c16(%ebx),%edi
f0100873:	eb 4a                	jmp    f01008bf <monitor+0x97>
f0100875:	83 ec 08             	sub    $0x8,%esp
f0100878:	0f be c0             	movsbl %al,%eax
f010087b:	50                   	push   %eax
f010087c:	57                   	push   %edi
f010087d:	e8 7b 3c 00 00       	call   f01044fd <strchr>
f0100882:	83 c4 10             	add    $0x10,%esp
f0100885:	85 c0                	test   %eax,%eax
f0100887:	74 08                	je     f0100891 <monitor+0x69>
			*buf++ = 0;
f0100889:	c6 06 00             	movb   $0x0,(%esi)
f010088c:	8d 76 01             	lea    0x1(%esi),%esi
f010088f:	eb 79                	jmp    f010090a <monitor+0xe2>
		if (*buf == 0)
f0100891:	80 3e 00             	cmpb   $0x0,(%esi)
f0100894:	74 7f                	je     f0100915 <monitor+0xed>
		if (argc == MAXARGS-1) {
f0100896:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f010089a:	74 0f                	je     f01008ab <monitor+0x83>
		argv[argc++] = buf;
f010089c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010089f:	8d 48 01             	lea    0x1(%eax),%ecx
f01008a2:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01008a5:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01008a9:	eb 44                	jmp    f01008ef <monitor+0xc7>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008ab:	83 ec 08             	sub    $0x8,%esp
f01008ae:	6a 10                	push   $0x10
f01008b0:	8d 83 ef 73 f8 ff    	lea    -0x78c11(%ebx),%eax
f01008b6:	50                   	push   %eax
f01008b7:	e8 83 2c 00 00       	call   f010353f <cprintf>
			return 0;
f01008bc:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01008bf:	8d 83 e6 73 f8 ff    	lea    -0x78c1a(%ebx),%eax
f01008c5:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01008c8:	83 ec 0c             	sub    $0xc,%esp
f01008cb:	ff 75 a4             	push   -0x5c(%ebp)
f01008ce:	e8 d9 39 00 00       	call   f01042ac <readline>
f01008d3:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01008d5:	83 c4 10             	add    $0x10,%esp
f01008d8:	85 c0                	test   %eax,%eax
f01008da:	74 ec                	je     f01008c8 <monitor+0xa0>
	argv[argc] = 0;
f01008dc:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01008e3:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01008ea:	eb 1e                	jmp    f010090a <monitor+0xe2>
			buf++;
f01008ec:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008ef:	0f b6 06             	movzbl (%esi),%eax
f01008f2:	84 c0                	test   %al,%al
f01008f4:	74 14                	je     f010090a <monitor+0xe2>
f01008f6:	83 ec 08             	sub    $0x8,%esp
f01008f9:	0f be c0             	movsbl %al,%eax
f01008fc:	50                   	push   %eax
f01008fd:	57                   	push   %edi
f01008fe:	e8 fa 3b 00 00       	call   f01044fd <strchr>
f0100903:	83 c4 10             	add    $0x10,%esp
f0100906:	85 c0                	test   %eax,%eax
f0100908:	74 e2                	je     f01008ec <monitor+0xc4>
		while (*buf && strchr(WHITESPACE, *buf))
f010090a:	0f b6 06             	movzbl (%esi),%eax
f010090d:	84 c0                	test   %al,%al
f010090f:	0f 85 60 ff ff ff    	jne    f0100875 <monitor+0x4d>
	argv[argc] = 0;
f0100915:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100918:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f010091f:	00 
	if (argc == 0)
f0100920:	85 c0                	test   %eax,%eax
f0100922:	74 9b                	je     f01008bf <monitor+0x97>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100924:	83 ec 08             	sub    $0x8,%esp
f0100927:	8d 83 b6 73 f8 ff    	lea    -0x78c4a(%ebx),%eax
f010092d:	50                   	push   %eax
f010092e:	ff 75 a8             	push   -0x58(%ebp)
f0100931:	e8 67 3b 00 00       	call   f010449d <strcmp>
f0100936:	83 c4 10             	add    $0x10,%esp
f0100939:	85 c0                	test   %eax,%eax
f010093b:	74 38                	je     f0100975 <monitor+0x14d>
f010093d:	83 ec 08             	sub    $0x8,%esp
f0100940:	8d 83 c4 73 f8 ff    	lea    -0x78c3c(%ebx),%eax
f0100946:	50                   	push   %eax
f0100947:	ff 75 a8             	push   -0x58(%ebp)
f010094a:	e8 4e 3b 00 00       	call   f010449d <strcmp>
f010094f:	83 c4 10             	add    $0x10,%esp
f0100952:	85 c0                	test   %eax,%eax
f0100954:	74 1a                	je     f0100970 <monitor+0x148>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100956:	83 ec 08             	sub    $0x8,%esp
f0100959:	ff 75 a8             	push   -0x58(%ebp)
f010095c:	8d 83 0c 74 f8 ff    	lea    -0x78bf4(%ebx),%eax
f0100962:	50                   	push   %eax
f0100963:	e8 d7 2b 00 00       	call   f010353f <cprintf>
	return 0;
f0100968:	83 c4 10             	add    $0x10,%esp
f010096b:	e9 4f ff ff ff       	jmp    f01008bf <monitor+0x97>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100970:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100975:	83 ec 04             	sub    $0x4,%esp
f0100978:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010097b:	ff 75 08             	push   0x8(%ebp)
f010097e:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100981:	52                   	push   %edx
f0100982:	ff 75 a4             	push   -0x5c(%ebp)
f0100985:	ff 94 83 d0 17 00 00 	call   *0x17d0(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f010098c:	83 c4 10             	add    $0x10,%esp
f010098f:	85 c0                	test   %eax,%eax
f0100991:	0f 89 28 ff ff ff    	jns    f01008bf <monitor+0x97>
				break;
	}
}
f0100997:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010099a:	5b                   	pop    %ebx
f010099b:	5e                   	pop    %esi
f010099c:	5f                   	pop    %edi
f010099d:	5d                   	pop    %ebp
f010099e:	c3                   	ret    

f010099f <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f010099f:	e8 5b 26 00 00       	call   f0102fff <__x86.get_pc_thunk.dx>
f01009a4:	81 c2 c4 ce 07 00    	add    $0x7cec4,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01009aa:	83 ba dc 1a 00 00 00 	cmpl   $0x0,0x1adc(%edx)
f01009b1:	74 1f                	je     f01009d2 <boot_alloc+0x33>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n == 0)
f01009b3:	85 c0                	test   %eax,%eax
f01009b5:	74 35                	je     f01009ec <boot_alloc+0x4d>
		return nextfree;		// if n == 0, return nextfree, not allocate any memory.
	
	result = nextfree;
f01009b7:	8b 8a dc 1a 00 00    	mov    0x1adc(%edx),%ecx
	nextfree += ROUNDUP(n, PGSIZE);		// align to PGSIZE
f01009bd:	05 ff 0f 00 00       	add    $0xfff,%eax
f01009c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009c7:	01 c8                	add    %ecx,%eax
f01009c9:	89 82 dc 1a 00 00    	mov    %eax,0x1adc(%edx)
	return result;
}
f01009cf:	89 c8                	mov    %ecx,%eax
f01009d1:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);	// round end up to PGSIZE
f01009d2:	c7 c1 00 00 18 f0    	mov    $0xf0180000,%ecx
f01009d8:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01009de:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01009e4:	89 8a dc 1a 00 00    	mov    %ecx,0x1adc(%edx)
f01009ea:	eb c7                	jmp    f01009b3 <boot_alloc+0x14>
		return nextfree;		// if n == 0, return nextfree, not allocate any memory.
f01009ec:	8b 8a dc 1a 00 00    	mov    0x1adc(%edx),%ecx
f01009f2:	eb db                	jmp    f01009cf <boot_alloc+0x30>

f01009f4 <nvram_read>:
{
f01009f4:	55                   	push   %ebp
f01009f5:	89 e5                	mov    %esp,%ebp
f01009f7:	57                   	push   %edi
f01009f8:	56                   	push   %esi
f01009f9:	53                   	push   %ebx
f01009fa:	83 ec 18             	sub    $0x18,%esp
f01009fd:	e8 65 f7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100a02:	81 c3 66 ce 07 00    	add    $0x7ce66,%ebx
f0100a08:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a0a:	50                   	push   %eax
f0100a0b:	e8 a8 2a 00 00       	call   f01034b8 <mc146818_read>
f0100a10:	89 c7                	mov    %eax,%edi
f0100a12:	83 c6 01             	add    $0x1,%esi
f0100a15:	89 34 24             	mov    %esi,(%esp)
f0100a18:	e8 9b 2a 00 00       	call   f01034b8 <mc146818_read>
f0100a1d:	c1 e0 08             	shl    $0x8,%eax
f0100a20:	09 f8                	or     %edi,%eax
}
f0100a22:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a25:	5b                   	pop    %ebx
f0100a26:	5e                   	pop    %esi
f0100a27:	5f                   	pop    %edi
f0100a28:	5d                   	pop    %ebp
f0100a29:	c3                   	ret    

f0100a2a <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a2a:	55                   	push   %ebp
f0100a2b:	89 e5                	mov    %esp,%ebp
f0100a2d:	53                   	push   %ebx
f0100a2e:	83 ec 04             	sub    $0x4,%esp
f0100a31:	e8 cd 25 00 00       	call   f0103003 <__x86.get_pc_thunk.cx>
f0100a36:	81 c1 32 ce 07 00    	add    $0x7ce32,%ecx
f0100a3c:	89 c3                	mov    %eax,%ebx
f0100a3e:	89 d0                	mov    %edx,%eax
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a40:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100a43:	8b 14 93             	mov    (%ebx,%edx,4),%edx
f0100a46:	f6 c2 01             	test   $0x1,%dl
f0100a49:	74 54                	je     f0100a9f <check_va2pa+0x75>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a4b:	89 d3                	mov    %edx,%ebx
f0100a4d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a53:	c1 ea 0c             	shr    $0xc,%edx
f0100a56:	3b 91 d8 1a 00 00    	cmp    0x1ad8(%ecx),%edx
f0100a5c:	73 26                	jae    f0100a84 <check_va2pa+0x5a>
	if (!(p[PTX(va)] & PTE_P))
f0100a5e:	c1 e8 0c             	shr    $0xc,%eax
f0100a61:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100a66:	8b 94 83 00 00 00 f0 	mov    -0x10000000(%ebx,%eax,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a6d:	89 d0                	mov    %edx,%eax
f0100a6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a74:	f6 c2 01             	test   $0x1,%dl
f0100a77:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a7c:	0f 44 c2             	cmove  %edx,%eax
}
f0100a7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a82:	c9                   	leave  
f0100a83:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a84:	53                   	push   %ebx
f0100a85:	8d 81 7c 75 f8 ff    	lea    -0x78a84(%ecx),%eax
f0100a8b:	50                   	push   %eax
f0100a8c:	68 46 03 00 00       	push   $0x346
f0100a91:	8d 81 49 7d f8 ff    	lea    -0x782b7(%ecx),%eax
f0100a97:	50                   	push   %eax
f0100a98:	89 cb                	mov    %ecx,%ebx
f0100a9a:	e8 12 f6 ff ff       	call   f01000b1 <_panic>
		return ~0;
f0100a9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100aa4:	eb d9                	jmp    f0100a7f <check_va2pa+0x55>

f0100aa6 <check_page_free_list>:
{
f0100aa6:	55                   	push   %ebp
f0100aa7:	89 e5                	mov    %esp,%ebp
f0100aa9:	57                   	push   %edi
f0100aaa:	56                   	push   %esi
f0100aab:	53                   	push   %ebx
f0100aac:	83 ec 2c             	sub    $0x2c,%esp
f0100aaf:	e8 53 25 00 00       	call   f0103007 <__x86.get_pc_thunk.di>
f0100ab4:	81 c7 b4 cd 07 00    	add    $0x7cdb4,%edi
f0100aba:	89 7d d4             	mov    %edi,-0x2c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100abd:	84 c0                	test   %al,%al
f0100abf:	0f 85 dc 02 00 00    	jne    f0100da1 <check_page_free_list+0x2fb>
	if (!page_free_list)
f0100ac5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ac8:	83 b8 e0 1a 00 00 00 	cmpl   $0x0,0x1ae0(%eax)
f0100acf:	74 0a                	je     f0100adb <check_page_free_list+0x35>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ad1:	bf 00 04 00 00       	mov    $0x400,%edi
f0100ad6:	e9 29 03 00 00       	jmp    f0100e04 <check_page_free_list+0x35e>
		panic("'page_free_list' is a null pointer!");
f0100adb:	83 ec 04             	sub    $0x4,%esp
f0100ade:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ae1:	8d 83 a0 75 f8 ff    	lea    -0x78a60(%ebx),%eax
f0100ae7:	50                   	push   %eax
f0100ae8:	68 82 02 00 00       	push   $0x282
f0100aed:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0100af3:	50                   	push   %eax
f0100af4:	e8 b8 f5 ff ff       	call   f01000b1 <_panic>
f0100af9:	50                   	push   %eax
f0100afa:	89 cb                	mov    %ecx,%ebx
f0100afc:	8d 81 7c 75 f8 ff    	lea    -0x78a84(%ecx),%eax
f0100b02:	50                   	push   %eax
f0100b03:	6a 56                	push   $0x56
f0100b05:	8d 81 55 7d f8 ff    	lea    -0x782ab(%ecx),%eax
f0100b0b:	50                   	push   %eax
f0100b0c:	e8 a0 f5 ff ff       	call   f01000b1 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b11:	8b 36                	mov    (%esi),%esi
f0100b13:	85 f6                	test   %esi,%esi
f0100b15:	74 47                	je     f0100b5e <check_page_free_list+0xb8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b17:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100b1a:	89 f0                	mov    %esi,%eax
f0100b1c:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0100b22:	c1 f8 03             	sar    $0x3,%eax
f0100b25:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b28:	89 c2                	mov    %eax,%edx
f0100b2a:	c1 ea 16             	shr    $0x16,%edx
f0100b2d:	39 fa                	cmp    %edi,%edx
f0100b2f:	73 e0                	jae    f0100b11 <check_page_free_list+0x6b>
	if (PGNUM(pa) >= npages)
f0100b31:	89 c2                	mov    %eax,%edx
f0100b33:	c1 ea 0c             	shr    $0xc,%edx
f0100b36:	3b 91 d8 1a 00 00    	cmp    0x1ad8(%ecx),%edx
f0100b3c:	73 bb                	jae    f0100af9 <check_page_free_list+0x53>
			memset(page2kva(pp), 0x97, 128);
f0100b3e:	83 ec 04             	sub    $0x4,%esp
f0100b41:	68 80 00 00 00       	push   $0x80
f0100b46:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100b4b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b50:	50                   	push   %eax
f0100b51:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100b54:	e8 e3 39 00 00       	call   f010453c <memset>
f0100b59:	83 c4 10             	add    $0x10,%esp
f0100b5c:	eb b3                	jmp    f0100b11 <check_page_free_list+0x6b>
	first_free_page = (char *) boot_alloc(0);
f0100b5e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b63:	e8 37 fe ff ff       	call   f010099f <boot_alloc>
f0100b68:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100b6e:	8b 90 e0 1a 00 00    	mov    0x1ae0(%eax),%edx
		assert(pp >= pages);
f0100b74:	8b 88 d0 1a 00 00    	mov    0x1ad0(%eax),%ecx
		assert(pp < pages + npages);
f0100b7a:	8b 80 d8 1a 00 00    	mov    0x1ad8(%eax),%eax
f0100b80:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100b83:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b86:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b8b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100b90:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b93:	e9 07 01 00 00       	jmp    f0100c9f <check_page_free_list+0x1f9>
		assert(pp >= pages);
f0100b98:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100b9b:	8d 83 63 7d f8 ff    	lea    -0x7829d(%ebx),%eax
f0100ba1:	50                   	push   %eax
f0100ba2:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0100ba8:	50                   	push   %eax
f0100ba9:	68 9c 02 00 00       	push   $0x29c
f0100bae:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0100bb4:	50                   	push   %eax
f0100bb5:	e8 f7 f4 ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0100bba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100bbd:	8d 83 84 7d f8 ff    	lea    -0x7827c(%ebx),%eax
f0100bc3:	50                   	push   %eax
f0100bc4:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0100bca:	50                   	push   %eax
f0100bcb:	68 9d 02 00 00       	push   $0x29d
f0100bd0:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0100bd6:	50                   	push   %eax
f0100bd7:	e8 d5 f4 ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bdc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100bdf:	8d 83 c4 75 f8 ff    	lea    -0x78a3c(%ebx),%eax
f0100be5:	50                   	push   %eax
f0100be6:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0100bec:	50                   	push   %eax
f0100bed:	68 9e 02 00 00       	push   $0x29e
f0100bf2:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0100bf8:	50                   	push   %eax
f0100bf9:	e8 b3 f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != 0);
f0100bfe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c01:	8d 83 98 7d f8 ff    	lea    -0x78268(%ebx),%eax
f0100c07:	50                   	push   %eax
f0100c08:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0100c0e:	50                   	push   %eax
f0100c0f:	68 a1 02 00 00       	push   $0x2a1
f0100c14:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0100c1a:	50                   	push   %eax
f0100c1b:	e8 91 f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c20:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c23:	8d 83 a9 7d f8 ff    	lea    -0x78257(%ebx),%eax
f0100c29:	50                   	push   %eax
f0100c2a:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0100c30:	50                   	push   %eax
f0100c31:	68 a2 02 00 00       	push   $0x2a2
f0100c36:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0100c3c:	50                   	push   %eax
f0100c3d:	e8 6f f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c42:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c45:	8d 83 f8 75 f8 ff    	lea    -0x78a08(%ebx),%eax
f0100c4b:	50                   	push   %eax
f0100c4c:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0100c52:	50                   	push   %eax
f0100c53:	68 a3 02 00 00       	push   $0x2a3
f0100c58:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0100c5e:	50                   	push   %eax
f0100c5f:	e8 4d f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c64:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c67:	8d 83 c2 7d f8 ff    	lea    -0x7823e(%ebx),%eax
f0100c6d:	50                   	push   %eax
f0100c6e:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0100c74:	50                   	push   %eax
f0100c75:	68 a4 02 00 00       	push   $0x2a4
f0100c7a:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0100c80:	50                   	push   %eax
f0100c81:	e8 2b f4 ff ff       	call   f01000b1 <_panic>
	if (PGNUM(pa) >= npages)
f0100c86:	89 c3                	mov    %eax,%ebx
f0100c88:	c1 eb 0c             	shr    $0xc,%ebx
f0100c8b:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100c8e:	76 6d                	jbe    f0100cfd <check_page_free_list+0x257>
	return (void *)(pa + KERNBASE);
f0100c90:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c95:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c98:	77 7c                	ja     f0100d16 <check_page_free_list+0x270>
			++nfree_extmem;
f0100c9a:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c9d:	8b 12                	mov    (%edx),%edx
f0100c9f:	85 d2                	test   %edx,%edx
f0100ca1:	0f 84 91 00 00 00    	je     f0100d38 <check_page_free_list+0x292>
		assert(pp >= pages);
f0100ca7:	39 d1                	cmp    %edx,%ecx
f0100ca9:	0f 87 e9 fe ff ff    	ja     f0100b98 <check_page_free_list+0xf2>
		assert(pp < pages + npages);
f0100caf:	39 d6                	cmp    %edx,%esi
f0100cb1:	0f 86 03 ff ff ff    	jbe    f0100bba <check_page_free_list+0x114>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cb7:	89 d0                	mov    %edx,%eax
f0100cb9:	29 c8                	sub    %ecx,%eax
f0100cbb:	a8 07                	test   $0x7,%al
f0100cbd:	0f 85 19 ff ff ff    	jne    f0100bdc <check_page_free_list+0x136>
	return (pp - pages) << PGSHIFT;
f0100cc3:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100cc6:	c1 e0 0c             	shl    $0xc,%eax
f0100cc9:	0f 84 2f ff ff ff    	je     f0100bfe <check_page_free_list+0x158>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ccf:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cd4:	0f 84 46 ff ff ff    	je     f0100c20 <check_page_free_list+0x17a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cda:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100cdf:	0f 84 5d ff ff ff    	je     f0100c42 <check_page_free_list+0x19c>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ce5:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100cea:	0f 84 74 ff ff ff    	je     f0100c64 <check_page_free_list+0x1be>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cf0:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100cf5:	77 8f                	ja     f0100c86 <check_page_free_list+0x1e0>
			++nfree_basemem;
f0100cf7:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
f0100cfb:	eb a0                	jmp    f0100c9d <check_page_free_list+0x1f7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cfd:	50                   	push   %eax
f0100cfe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d01:	8d 83 7c 75 f8 ff    	lea    -0x78a84(%ebx),%eax
f0100d07:	50                   	push   %eax
f0100d08:	6a 56                	push   $0x56
f0100d0a:	8d 83 55 7d f8 ff    	lea    -0x782ab(%ebx),%eax
f0100d10:	50                   	push   %eax
f0100d11:	e8 9b f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d16:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d19:	8d 83 1c 76 f8 ff    	lea    -0x789e4(%ebx),%eax
f0100d1f:	50                   	push   %eax
f0100d20:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0100d26:	50                   	push   %eax
f0100d27:	68 a5 02 00 00       	push   $0x2a5
f0100d2c:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0100d32:	50                   	push   %eax
f0100d33:	e8 79 f3 ff ff       	call   f01000b1 <_panic>
	assert(nfree_basemem > 0);
f0100d38:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100d3b:	85 db                	test   %ebx,%ebx
f0100d3d:	7e 1e                	jle    f0100d5d <check_page_free_list+0x2b7>
	assert(nfree_extmem > 0);
f0100d3f:	85 ff                	test   %edi,%edi
f0100d41:	7e 3c                	jle    f0100d7f <check_page_free_list+0x2d9>
	cprintf("check_page_free_list() succeeded!\n");
f0100d43:	83 ec 0c             	sub    $0xc,%esp
f0100d46:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d49:	8d 83 64 76 f8 ff    	lea    -0x7899c(%ebx),%eax
f0100d4f:	50                   	push   %eax
f0100d50:	e8 ea 27 00 00       	call   f010353f <cprintf>
}
f0100d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d58:	5b                   	pop    %ebx
f0100d59:	5e                   	pop    %esi
f0100d5a:	5f                   	pop    %edi
f0100d5b:	5d                   	pop    %ebp
f0100d5c:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d5d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d60:	8d 83 dc 7d f8 ff    	lea    -0x78224(%ebx),%eax
f0100d66:	50                   	push   %eax
f0100d67:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0100d6d:	50                   	push   %eax
f0100d6e:	68 ad 02 00 00       	push   $0x2ad
f0100d73:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0100d79:	50                   	push   %eax
f0100d7a:	e8 32 f3 ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0100d7f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d82:	8d 83 ee 7d f8 ff    	lea    -0x78212(%ebx),%eax
f0100d88:	50                   	push   %eax
f0100d89:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0100d8f:	50                   	push   %eax
f0100d90:	68 ae 02 00 00       	push   $0x2ae
f0100d95:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0100d9b:	50                   	push   %eax
f0100d9c:	e8 10 f3 ff ff       	call   f01000b1 <_panic>
	if (!page_free_list)
f0100da1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100da4:	8b 80 e0 1a 00 00    	mov    0x1ae0(%eax),%eax
f0100daa:	85 c0                	test   %eax,%eax
f0100dac:	0f 84 29 fd ff ff    	je     f0100adb <check_page_free_list+0x35>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100db2:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100db5:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100db8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100dbb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100dbe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100dc1:	89 c2                	mov    %eax,%edx
f0100dc3:	2b 97 d0 1a 00 00    	sub    0x1ad0(%edi),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100dc9:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100dcf:	0f 95 c2             	setne  %dl
f0100dd2:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100dd5:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100dd9:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ddb:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ddf:	8b 00                	mov    (%eax),%eax
f0100de1:	85 c0                	test   %eax,%eax
f0100de3:	75 d9                	jne    f0100dbe <check_page_free_list+0x318>
		*tp[1] = 0;
f0100de5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100de8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100dee:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100df1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100df4:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100df6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100df9:	89 87 e0 1a 00 00    	mov    %eax,0x1ae0(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100dff:	bf 01 00 00 00       	mov    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e07:	8b b0 e0 1a 00 00    	mov    0x1ae0(%eax),%esi
f0100e0d:	e9 01 fd ff ff       	jmp    f0100b13 <check_page_free_list+0x6d>

f0100e12 <page_init>:
{	
f0100e12:	55                   	push   %ebp
f0100e13:	89 e5                	mov    %esp,%ebp
f0100e15:	57                   	push   %edi
f0100e16:	56                   	push   %esi
f0100e17:	53                   	push   %ebx
f0100e18:	83 ec 0c             	sub    $0xc,%esp
f0100e1b:	e8 47 f3 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100e20:	81 c3 48 ca 07 00    	add    $0x7ca48,%ebx
	pages[0].pp_ref = 1;
f0100e26:	8b 83 d0 1a 00 00    	mov    0x1ad0(%ebx),%eax
f0100e2c:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	for (i = 1; i < npages_basemem; i++) {
f0100e32:	8b bb e4 1a 00 00    	mov    0x1ae4(%ebx),%edi
f0100e38:	8b b3 e0 1a 00 00    	mov    0x1ae0(%ebx),%esi
f0100e3e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e43:	b8 01 00 00 00       	mov    $0x1,%eax
f0100e48:	eb 27                	jmp    f0100e71 <page_init+0x5f>
f0100e4a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100e51:	89 d1                	mov    %edx,%ecx
f0100e53:	03 8b d0 1a 00 00    	add    0x1ad0(%ebx),%ecx
f0100e59:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100e5f:	89 31                	mov    %esi,(%ecx)
		page_free_list = &pages[i];
f0100e61:	89 d6                	mov    %edx,%esi
f0100e63:	03 b3 d0 1a 00 00    	add    0x1ad0(%ebx),%esi
	for (i = 1; i < npages_basemem; i++) {
f0100e69:	83 c0 01             	add    $0x1,%eax
f0100e6c:	ba 01 00 00 00       	mov    $0x1,%edx
f0100e71:	39 c7                	cmp    %eax,%edi
f0100e73:	77 d5                	ja     f0100e4a <page_init+0x38>
f0100e75:	84 d2                	test   %dl,%dl
f0100e77:	74 06                	je     f0100e7f <page_init+0x6d>
f0100e79:	89 b3 e0 1a 00 00    	mov    %esi,0x1ae0(%ebx)
		pages[i].pp_ref = 1;
f0100e7f:	8b 93 d0 1a 00 00    	mov    0x1ad0(%ebx),%edx
f0100e85:	8d 82 04 05 00 00    	lea    0x504(%edx),%eax
f0100e8b:	81 c2 04 08 00 00    	add    $0x804,%edx
f0100e91:	66 c7 00 01 00       	movw   $0x1,(%eax)
	for(i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
f0100e96:	83 c0 08             	add    $0x8,%eax
f0100e99:	39 c2                	cmp    %eax,%edx
f0100e9b:	75 f4                	jne    f0100e91 <page_init+0x7f>
	size_t first_free = PADDR(boot_alloc(0));
f0100e9d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ea2:	e8 f8 fa ff ff       	call   f010099f <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100ea7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100eac:	76 15                	jbe    f0100ec3 <page_init+0xb1>
	return (physaddr_t)kva - KERNBASE;
f0100eae:	05 00 00 00 10       	add    $0x10000000,%eax
	for(i = EXTPHYSMEM/PGSIZE; i < first_free/PGSIZE; i++) {
f0100eb3:	c1 e8 0c             	shr    $0xc,%eax
		pages[i].pp_ref = 1;
f0100eb6:	8b 8b d0 1a 00 00    	mov    0x1ad0(%ebx),%ecx
	for(i = EXTPHYSMEM/PGSIZE; i < first_free/PGSIZE; i++) {
f0100ebc:	ba 00 01 00 00       	mov    $0x100,%edx
f0100ec1:	eb 23                	jmp    f0100ee6 <page_init+0xd4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ec3:	50                   	push   %eax
f0100ec4:	8d 83 88 76 f8 ff    	lea    -0x78978(%ebx),%eax
f0100eca:	50                   	push   %eax
f0100ecb:	68 1b 01 00 00       	push   $0x11b
f0100ed0:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0100ed6:	50                   	push   %eax
f0100ed7:	e8 d5 f1 ff ff       	call   f01000b1 <_panic>
		pages[i].pp_ref = 1;
f0100edc:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
	for(i = EXTPHYSMEM/PGSIZE; i < first_free/PGSIZE; i++) {
f0100ee3:	83 c2 01             	add    $0x1,%edx
f0100ee6:	39 d0                	cmp    %edx,%eax
f0100ee8:	77 f2                	ja     f0100edc <page_init+0xca>
f0100eea:	8b b3 e0 1a 00 00    	mov    0x1ae0(%ebx),%esi
f0100ef0:	ba 00 00 00 00       	mov    $0x0,%edx
	for(i = first_free/PGSIZE; i < npages; i++) {
f0100ef5:	bf 01 00 00 00       	mov    $0x1,%edi
f0100efa:	eb 24                	jmp    f0100f20 <page_init+0x10e>
f0100efc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100f03:	89 d1                	mov    %edx,%ecx
f0100f05:	03 8b d0 1a 00 00    	add    0x1ad0(%ebx),%ecx
f0100f0b:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100f11:	89 31                	mov    %esi,(%ecx)
		page_free_list = &pages[i];
f0100f13:	89 d6                	mov    %edx,%esi
f0100f15:	03 b3 d0 1a 00 00    	add    0x1ad0(%ebx),%esi
	for(i = first_free/PGSIZE; i < npages; i++) {
f0100f1b:	83 c0 01             	add    $0x1,%eax
f0100f1e:	89 fa                	mov    %edi,%edx
f0100f20:	39 83 d8 1a 00 00    	cmp    %eax,0x1ad8(%ebx)
f0100f26:	77 d4                	ja     f0100efc <page_init+0xea>
f0100f28:	84 d2                	test   %dl,%dl
f0100f2a:	74 06                	je     f0100f32 <page_init+0x120>
f0100f2c:	89 b3 e0 1a 00 00    	mov    %esi,0x1ae0(%ebx)
}
f0100f32:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f35:	5b                   	pop    %ebx
f0100f36:	5e                   	pop    %esi
f0100f37:	5f                   	pop    %edi
f0100f38:	5d                   	pop    %ebp
f0100f39:	c3                   	ret    

f0100f3a <page_alloc>:
{
f0100f3a:	55                   	push   %ebp
f0100f3b:	89 e5                	mov    %esp,%ebp
f0100f3d:	56                   	push   %esi
f0100f3e:	53                   	push   %ebx
f0100f3f:	e8 23 f2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100f44:	81 c3 24 c9 07 00    	add    $0x7c924,%ebx
	if(page_free_list == NULL) {
f0100f4a:	8b b3 e0 1a 00 00    	mov    0x1ae0(%ebx),%esi
f0100f50:	85 f6                	test   %esi,%esi
f0100f52:	74 14                	je     f0100f68 <page_alloc+0x2e>
	page_free_list = page_free_list->pp_link;
f0100f54:	8b 06                	mov    (%esi),%eax
f0100f56:	89 83 e0 1a 00 00    	mov    %eax,0x1ae0(%ebx)
	allocated_page->pp_link = NULL;
f0100f5c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(alloc_flags & ALLOC_ZERO) {
f0100f62:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f66:	75 09                	jne    f0100f71 <page_alloc+0x37>
}
f0100f68:	89 f0                	mov    %esi,%eax
f0100f6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f6d:	5b                   	pop    %ebx
f0100f6e:	5e                   	pop    %esi
f0100f6f:	5d                   	pop    %ebp
f0100f70:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100f71:	89 f0                	mov    %esi,%eax
f0100f73:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0100f79:	c1 f8 03             	sar    $0x3,%eax
f0100f7c:	89 c2                	mov    %eax,%edx
f0100f7e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100f81:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100f86:	3b 83 d8 1a 00 00    	cmp    0x1ad8(%ebx),%eax
f0100f8c:	73 1b                	jae    f0100fa9 <page_alloc+0x6f>
		memset(page2kva(allocated_page), '\0', PGSIZE);
f0100f8e:	83 ec 04             	sub    $0x4,%esp
f0100f91:	68 00 10 00 00       	push   $0x1000
f0100f96:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100f98:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100f9e:	52                   	push   %edx
f0100f9f:	e8 98 35 00 00       	call   f010453c <memset>
f0100fa4:	83 c4 10             	add    $0x10,%esp
f0100fa7:	eb bf                	jmp    f0100f68 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fa9:	52                   	push   %edx
f0100faa:	8d 83 7c 75 f8 ff    	lea    -0x78a84(%ebx),%eax
f0100fb0:	50                   	push   %eax
f0100fb1:	6a 56                	push   $0x56
f0100fb3:	8d 83 55 7d f8 ff    	lea    -0x782ab(%ebx),%eax
f0100fb9:	50                   	push   %eax
f0100fba:	e8 f2 f0 ff ff       	call   f01000b1 <_panic>

f0100fbf <page_free>:
{
f0100fbf:	55                   	push   %ebp
f0100fc0:	89 e5                	mov    %esp,%ebp
f0100fc2:	53                   	push   %ebx
f0100fc3:	83 ec 04             	sub    $0x4,%esp
f0100fc6:	e8 9c f1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100fcb:	81 c3 9d c8 07 00    	add    $0x7c89d,%ebx
f0100fd1:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_ref != 0 || pp->pp_link != NULL) {
f0100fd4:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fd9:	75 18                	jne    f0100ff3 <page_free+0x34>
f0100fdb:	83 38 00             	cmpl   $0x0,(%eax)
f0100fde:	75 13                	jne    f0100ff3 <page_free+0x34>
	pp->pp_link = page_free_list;
f0100fe0:	8b 8b e0 1a 00 00    	mov    0x1ae0(%ebx),%ecx
f0100fe6:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f0100fe8:	89 83 e0 1a 00 00    	mov    %eax,0x1ae0(%ebx)
}
f0100fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ff1:	c9                   	leave  
f0100ff2:	c3                   	ret    
		panic("Double check failed when free page");
f0100ff3:	83 ec 04             	sub    $0x4,%esp
f0100ff6:	8d 83 ac 76 f8 ff    	lea    -0x78954(%ebx),%eax
f0100ffc:	50                   	push   %eax
f0100ffd:	68 5b 01 00 00       	push   $0x15b
f0101002:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0101008:	50                   	push   %eax
f0101009:	e8 a3 f0 ff ff       	call   f01000b1 <_panic>

f010100e <page_decref>:
{
f010100e:	55                   	push   %ebp
f010100f:	89 e5                	mov    %esp,%ebp
f0101011:	83 ec 08             	sub    $0x8,%esp
f0101014:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101017:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010101b:	83 e8 01             	sub    $0x1,%eax
f010101e:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101022:	66 85 c0             	test   %ax,%ax
f0101025:	74 02                	je     f0101029 <page_decref+0x1b>
}
f0101027:	c9                   	leave  
f0101028:	c3                   	ret    
		page_free(pp);
f0101029:	83 ec 0c             	sub    $0xc,%esp
f010102c:	52                   	push   %edx
f010102d:	e8 8d ff ff ff       	call   f0100fbf <page_free>
f0101032:	83 c4 10             	add    $0x10,%esp
}
f0101035:	eb f0                	jmp    f0101027 <page_decref+0x19>

f0101037 <pgdir_walk>:
{
f0101037:	55                   	push   %ebp
f0101038:	89 e5                	mov    %esp,%ebp
f010103a:	57                   	push   %edi
f010103b:	56                   	push   %esi
f010103c:	53                   	push   %ebx
f010103d:	83 ec 0c             	sub    $0xc,%esp
f0101040:	e8 c2 1f 00 00       	call   f0103007 <__x86.get_pc_thunk.di>
f0101045:	81 c7 23 c8 07 00    	add    $0x7c823,%edi
f010104b:	8b 75 0c             	mov    0xc(%ebp),%esi
	uint32_t page_dir_index = PDX(va);
f010104e:	89 f3                	mov    %esi,%ebx
f0101050:	c1 eb 16             	shr    $0x16,%ebx
	if(pgdir[page_dir_index] & PTE_P) {
f0101053:	c1 e3 02             	shl    $0x2,%ebx
f0101056:	03 5d 08             	add    0x8(%ebp),%ebx
f0101059:	8b 13                	mov    (%ebx),%edx
f010105b:	f6 c2 01             	test   $0x1,%dl
f010105e:	75 63                	jne    f01010c3 <pgdir_walk+0x8c>
		if(create) {
f0101060:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101064:	0f 84 c0 00 00 00    	je     f010112a <pgdir_walk+0xf3>
			struct PageInfo* new_pi = page_alloc(ALLOC_ZERO);
f010106a:	83 ec 0c             	sub    $0xc,%esp
f010106d:	6a 01                	push   $0x1
f010106f:	e8 c6 fe ff ff       	call   f0100f3a <page_alloc>
			if(new_pi) {
f0101074:	83 c4 10             	add    $0x10,%esp
f0101077:	85 c0                	test   %eax,%eax
f0101079:	74 40                	je     f01010bb <pgdir_walk+0x84>
				new_pi->pp_ref += 1;
f010107b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101080:	2b 87 d0 1a 00 00    	sub    0x1ad0(%edi),%eax
f0101086:	c1 f8 03             	sar    $0x3,%eax
f0101089:	89 c2                	mov    %eax,%edx
f010108b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010108e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101093:	3b 87 d8 1a 00 00    	cmp    0x1ad8(%edi),%eax
f0101099:	73 5c                	jae    f01010f7 <pgdir_walk+0xc0>
	return (void *)(pa + KERNBASE);
f010109b:	8d 8a 00 00 00 f0    	lea    -0x10000000(%edx),%ecx
f01010a1:	89 c8                	mov    %ecx,%eax
	if ((uint32_t)kva < KERNBASE)
f01010a3:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f01010a9:	76 64                	jbe    f010110f <pgdir_walk+0xd8>
				pgdir[page_dir_index] = PADDR(PTT) | PTE_P | PTE_W | PTE_U;
f01010ab:	83 ca 07             	or     $0x7,%edx
f01010ae:	89 13                	mov    %edx,(%ebx)
	uint32_t page_tab_index = PTX(va);
f01010b0:	c1 ee 0a             	shr    $0xa,%esi
	return &PTT[page_tab_index];	// return PTE
f01010b3:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010b9:	01 f0                	add    %esi,%eax
}
f01010bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010be:	5b                   	pop    %ebx
f01010bf:	5e                   	pop    %esi
f01010c0:	5f                   	pop    %edi
f01010c1:	5d                   	pop    %ebp
f01010c2:	c3                   	ret    
		PTT = KADDR(PTE_ADDR(pgdir[page_dir_index]));
f01010c3:	89 d0                	mov    %edx,%eax
f01010c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01010ca:	c1 ea 0c             	shr    $0xc,%edx
f01010cd:	3b 97 d8 1a 00 00    	cmp    0x1ad8(%edi),%edx
f01010d3:	73 07                	jae    f01010dc <pgdir_walk+0xa5>
	return (void *)(pa + KERNBASE);
f01010d5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010da:	eb d4                	jmp    f01010b0 <pgdir_walk+0x79>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010dc:	50                   	push   %eax
f01010dd:	8d 87 7c 75 f8 ff    	lea    -0x78a84(%edi),%eax
f01010e3:	50                   	push   %eax
f01010e4:	68 8c 01 00 00       	push   $0x18c
f01010e9:	8d 87 49 7d f8 ff    	lea    -0x782b7(%edi),%eax
f01010ef:	50                   	push   %eax
f01010f0:	89 fb                	mov    %edi,%ebx
f01010f2:	e8 ba ef ff ff       	call   f01000b1 <_panic>
f01010f7:	52                   	push   %edx
f01010f8:	8d 87 7c 75 f8 ff    	lea    -0x78a84(%edi),%eax
f01010fe:	50                   	push   %eax
f01010ff:	6a 56                	push   $0x56
f0101101:	8d 87 55 7d f8 ff    	lea    -0x782ab(%edi),%eax
f0101107:	50                   	push   %eax
f0101108:	89 fb                	mov    %edi,%ebx
f010110a:	e8 a2 ef ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010110f:	51                   	push   %ecx
f0101110:	8d 87 88 76 f8 ff    	lea    -0x78978(%edi),%eax
f0101116:	50                   	push   %eax
f0101117:	68 95 01 00 00       	push   $0x195
f010111c:	8d 87 49 7d f8 ff    	lea    -0x782b7(%edi),%eax
f0101122:	50                   	push   %eax
f0101123:	89 fb                	mov    %edi,%ebx
f0101125:	e8 87 ef ff ff       	call   f01000b1 <_panic>
			return NULL;
f010112a:	b8 00 00 00 00       	mov    $0x0,%eax
f010112f:	eb 8a                	jmp    f01010bb <pgdir_walk+0x84>

f0101131 <boot_map_region>:
{
f0101131:	55                   	push   %ebp
f0101132:	89 e5                	mov    %esp,%ebp
f0101134:	57                   	push   %edi
f0101135:	56                   	push   %esi
f0101136:	53                   	push   %ebx
f0101137:	83 ec 1c             	sub    $0x1c,%esp
f010113a:	89 c7                	mov    %eax,%edi
f010113c:	8b 45 08             	mov    0x8(%ebp),%eax
f010113f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101145:	8d 34 01             	lea    (%ecx,%eax,1),%esi
	for(i = 0; i < pgnum; i++) {
f0101148:	89 c3                	mov    %eax,%ebx
		PTE = pgdir_walk(pgdir, (void*)va, 1);
f010114a:	29 c2                	sub    %eax,%edx
f010114c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	for(i = 0; i < pgnum; i++) {
f010114f:	eb 10                	jmp    f0101161 <boot_map_region+0x30>
		*PTE = pa | perm | PTE_P;	// *PTE == physical addr of va
f0101151:	89 da                	mov    %ebx,%edx
f0101153:	0b 55 0c             	or     0xc(%ebp),%edx
f0101156:	83 ca 01             	or     $0x1,%edx
f0101159:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f010115b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for(i = 0; i < pgnum; i++) {
f0101161:	39 f3                	cmp    %esi,%ebx
f0101163:	74 18                	je     f010117d <boot_map_region+0x4c>
		PTE = pgdir_walk(pgdir, (void*)va, 1);
f0101165:	83 ec 04             	sub    $0x4,%esp
f0101168:	6a 01                	push   $0x1
f010116a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010116d:	01 d8                	add    %ebx,%eax
f010116f:	50                   	push   %eax
f0101170:	57                   	push   %edi
f0101171:	e8 c1 fe ff ff       	call   f0101037 <pgdir_walk>
		if(!PTE) {
f0101176:	83 c4 10             	add    $0x10,%esp
f0101179:	85 c0                	test   %eax,%eax
f010117b:	75 d4                	jne    f0101151 <boot_map_region+0x20>
}
f010117d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101180:	5b                   	pop    %ebx
f0101181:	5e                   	pop    %esi
f0101182:	5f                   	pop    %edi
f0101183:	5d                   	pop    %ebp
f0101184:	c3                   	ret    

f0101185 <page_lookup>:
{
f0101185:	55                   	push   %ebp
f0101186:	89 e5                	mov    %esp,%ebp
f0101188:	56                   	push   %esi
f0101189:	53                   	push   %ebx
f010118a:	e8 d8 ef ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010118f:	81 c3 d9 c6 07 00    	add    $0x7c6d9,%ebx
f0101195:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t* pte = pgdir_walk(pgdir, va, 0);	// find va's pte, not create
f0101198:	83 ec 04             	sub    $0x4,%esp
f010119b:	6a 00                	push   $0x0
f010119d:	ff 75 0c             	push   0xc(%ebp)
f01011a0:	ff 75 08             	push   0x8(%ebp)
f01011a3:	e8 8f fe ff ff       	call   f0101037 <pgdir_walk>
	if(pte == NULL) {
f01011a8:	83 c4 10             	add    $0x10,%esp
f01011ab:	85 c0                	test   %eax,%eax
f01011ad:	74 1c                	je     f01011cb <page_lookup+0x46>
	if(pte_store) {
f01011af:	85 f6                	test   %esi,%esi
f01011b1:	74 02                	je     f01011b5 <page_lookup+0x30>
		*pte_store = pte;
f01011b3:	89 06                	mov    %eax,(%esi)
f01011b5:	8b 00                	mov    (%eax),%eax
f01011b7:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011ba:	39 83 d8 1a 00 00    	cmp    %eax,0x1ad8(%ebx)
f01011c0:	76 10                	jbe    f01011d2 <page_lookup+0x4d>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01011c2:	8b 93 d0 1a 00 00    	mov    0x1ad0(%ebx),%edx
f01011c8:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01011cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011ce:	5b                   	pop    %ebx
f01011cf:	5e                   	pop    %esi
f01011d0:	5d                   	pop    %ebp
f01011d1:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01011d2:	83 ec 04             	sub    $0x4,%esp
f01011d5:	8d 83 d0 76 f8 ff    	lea    -0x78930(%ebx),%eax
f01011db:	50                   	push   %eax
f01011dc:	6a 4f                	push   $0x4f
f01011de:	8d 83 55 7d f8 ff    	lea    -0x782ab(%ebx),%eax
f01011e4:	50                   	push   %eax
f01011e5:	e8 c7 ee ff ff       	call   f01000b1 <_panic>

f01011ea <page_remove>:
{
f01011ea:	55                   	push   %ebp
f01011eb:	89 e5                	mov    %esp,%ebp
f01011ed:	53                   	push   %ebx
f01011ee:	83 ec 18             	sub    $0x18,%esp
f01011f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo* pi = page_lookup(pgdir, va, pte_store);	//get va's pa_PageInfo
f01011f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011f7:	50                   	push   %eax
f01011f8:	53                   	push   %ebx
f01011f9:	ff 75 08             	push   0x8(%ebp)
f01011fc:	e8 84 ff ff ff       	call   f0101185 <page_lookup>
	if(!pi) {
f0101201:	83 c4 10             	add    $0x10,%esp
f0101204:	85 c0                	test   %eax,%eax
f0101206:	74 18                	je     f0101220 <page_remove+0x36>
	page_decref(pi);
f0101208:	83 ec 0c             	sub    $0xc,%esp
f010120b:	50                   	push   %eax
f010120c:	e8 fd fd ff ff       	call   f010100e <page_decref>
	*PTT = 0;		// clear PTE
f0101211:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101214:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010121a:	0f 01 3b             	invlpg (%ebx)
f010121d:	83 c4 10             	add    $0x10,%esp
}
f0101220:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101223:	c9                   	leave  
f0101224:	c3                   	ret    

f0101225 <page_insert>:
{
f0101225:	55                   	push   %ebp
f0101226:	89 e5                	mov    %esp,%ebp
f0101228:	57                   	push   %edi
f0101229:	56                   	push   %esi
f010122a:	53                   	push   %ebx
f010122b:	83 ec 10             	sub    $0x10,%esp
f010122e:	e8 d4 1d 00 00       	call   f0103007 <__x86.get_pc_thunk.di>
f0101233:	81 c7 35 c6 07 00    	add    $0x7c635,%edi
f0101239:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, 1);	// Get pte of va, if not, establish one 
f010123c:	6a 01                	push   $0x1
f010123e:	ff 75 10             	push   0x10(%ebp)
f0101241:	ff 75 08             	push   0x8(%ebp)
f0101244:	e8 ee fd ff ff       	call   f0101037 <pgdir_walk>
	if(pte == NULL) {		// allocate failed, no space
f0101249:	83 c4 10             	add    $0x10,%esp
f010124c:	85 c0                	test   %eax,%eax
f010124e:	74 46                	je     f0101296 <page_insert+0x71>
f0101250:	89 c6                	mov    %eax,%esi
	pp->pp_ref ++;
f0101252:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if(*pte & PTE_P) {
f0101257:	f6 00 01             	testb  $0x1,(%eax)
f010125a:	75 27                	jne    f0101283 <page_insert+0x5e>
	return (pp - pages) << PGSHIFT;
f010125c:	2b 9f d0 1a 00 00    	sub    0x1ad0(%edi),%ebx
f0101262:	c1 fb 03             	sar    $0x3,%ebx
f0101265:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = page2pa(pp) | perm | PTE_P;
f0101268:	0b 5d 14             	or     0x14(%ebp),%ebx
f010126b:	83 cb 01             	or     $0x1,%ebx
f010126e:	89 1e                	mov    %ebx,(%esi)
f0101270:	8b 45 10             	mov    0x10(%ebp),%eax
f0101273:	0f 01 38             	invlpg (%eax)
	return 0;
f0101276:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010127b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010127e:	5b                   	pop    %ebx
f010127f:	5e                   	pop    %esi
f0101280:	5f                   	pop    %edi
f0101281:	5d                   	pop    %ebp
f0101282:	c3                   	ret    
		page_remove(pgdir, va);
f0101283:	83 ec 08             	sub    $0x8,%esp
f0101286:	ff 75 10             	push   0x10(%ebp)
f0101289:	ff 75 08             	push   0x8(%ebp)
f010128c:	e8 59 ff ff ff       	call   f01011ea <page_remove>
f0101291:	83 c4 10             	add    $0x10,%esp
f0101294:	eb c6                	jmp    f010125c <page_insert+0x37>
		return -E_NO_MEM;
f0101296:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010129b:	eb de                	jmp    f010127b <page_insert+0x56>

f010129d <mem_init>:
{
f010129d:	55                   	push   %ebp
f010129e:	89 e5                	mov    %esp,%ebp
f01012a0:	57                   	push   %edi
f01012a1:	56                   	push   %esi
f01012a2:	53                   	push   %ebx
f01012a3:	83 ec 3c             	sub    $0x3c,%esp
f01012a6:	e8 4e f4 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f01012ab:	05 bd c5 07 00       	add    $0x7c5bd,%eax
f01012b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f01012b3:	b8 15 00 00 00       	mov    $0x15,%eax
f01012b8:	e8 37 f7 ff ff       	call   f01009f4 <nvram_read>
f01012bd:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01012bf:	b8 17 00 00 00       	mov    $0x17,%eax
f01012c4:	e8 2b f7 ff ff       	call   f01009f4 <nvram_read>
f01012c9:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01012cb:	b8 34 00 00 00       	mov    $0x34,%eax
f01012d0:	e8 1f f7 ff ff       	call   f01009f4 <nvram_read>
	if (ext16mem)
f01012d5:	c1 e0 06             	shl    $0x6,%eax
f01012d8:	0f 84 cb 00 00 00    	je     f01013a9 <mem_init+0x10c>
		totalmem = 16 * 1024 + ext16mem;
f01012de:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01012e3:	89 c2                	mov    %eax,%edx
f01012e5:	c1 ea 02             	shr    $0x2,%edx
f01012e8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01012eb:	89 91 d8 1a 00 00    	mov    %edx,0x1ad8(%ecx)
	npages_basemem = basemem / (PGSIZE / 1024);
f01012f1:	89 da                	mov    %ebx,%edx
f01012f3:	c1 ea 02             	shr    $0x2,%edx
f01012f6:	89 91 e4 1a 00 00    	mov    %edx,0x1ae4(%ecx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012fc:	89 c2                	mov    %eax,%edx
f01012fe:	29 da                	sub    %ebx,%edx
f0101300:	52                   	push   %edx
f0101301:	53                   	push   %ebx
f0101302:	50                   	push   %eax
f0101303:	8d 81 f0 76 f8 ff    	lea    -0x78910(%ecx),%eax
f0101309:	50                   	push   %eax
f010130a:	89 cb                	mov    %ecx,%ebx
f010130c:	e8 2e 22 00 00       	call   f010353f <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);		// 4KB
f0101311:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101316:	e8 84 f6 ff ff       	call   f010099f <boot_alloc>
f010131b:	89 83 d4 1a 00 00    	mov    %eax,0x1ad4(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f0101321:	83 c4 0c             	add    $0xc,%esp
f0101324:	68 00 10 00 00       	push   $0x1000
f0101329:	6a 00                	push   $0x0
f010132b:	50                   	push   %eax
f010132c:	e8 0b 32 00 00       	call   f010453c <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101331:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0101337:	83 c4 10             	add    $0x10,%esp
f010133a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010133f:	76 78                	jbe    f01013b9 <mem_init+0x11c>
	return (physaddr_t)kva - KERNBASE;
f0101341:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101347:	83 ca 05             	or     $0x5,%edx
f010134a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*) boot_alloc(npages * sizeof(struct PageInfo));
f0101350:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101353:	8b 87 d8 1a 00 00    	mov    0x1ad8(%edi),%eax
f0101359:	c1 e0 03             	shl    $0x3,%eax
f010135c:	e8 3e f6 ff ff       	call   f010099f <boot_alloc>
f0101361:	89 87 d0 1a 00 00    	mov    %eax,0x1ad0(%edi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101367:	83 ec 04             	sub    $0x4,%esp
f010136a:	8b 97 d8 1a 00 00    	mov    0x1ad8(%edi),%edx
f0101370:	c1 e2 03             	shl    $0x3,%edx
f0101373:	52                   	push   %edx
f0101374:	6a 00                	push   $0x0
f0101376:	50                   	push   %eax
f0101377:	89 fb                	mov    %edi,%ebx
f0101379:	e8 be 31 00 00       	call   f010453c <memset>
	page_init();
f010137e:	e8 8f fa ff ff       	call   f0100e12 <page_init>
	check_page_free_list(1);
f0101383:	b8 01 00 00 00       	mov    $0x1,%eax
f0101388:	e8 19 f7 ff ff       	call   f0100aa6 <check_page_free_list>
	if (!pages)
f010138d:	83 c4 10             	add    $0x10,%esp
f0101390:	83 bf d0 1a 00 00 00 	cmpl   $0x0,0x1ad0(%edi)
f0101397:	74 3c                	je     f01013d5 <mem_init+0x138>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101399:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010139c:	8b 80 e0 1a 00 00    	mov    0x1ae0(%eax),%eax
f01013a2:	be 00 00 00 00       	mov    $0x0,%esi
f01013a7:	eb 4f                	jmp    f01013f8 <mem_init+0x15b>
		totalmem = 1 * 1024 + extmem;
f01013a9:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01013af:	85 f6                	test   %esi,%esi
f01013b1:	0f 44 c3             	cmove  %ebx,%eax
f01013b4:	e9 2a ff ff ff       	jmp    f01012e3 <mem_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013b9:	50                   	push   %eax
f01013ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01013bd:	8d 83 88 76 f8 ff    	lea    -0x78978(%ebx),%eax
f01013c3:	50                   	push   %eax
f01013c4:	68 93 00 00 00       	push   $0x93
f01013c9:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01013cf:	50                   	push   %eax
f01013d0:	e8 dc ec ff ff       	call   f01000b1 <_panic>
		panic("'pages' is a null pointer!");
f01013d5:	83 ec 04             	sub    $0x4,%esp
f01013d8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01013db:	8d 83 ff 7d f8 ff    	lea    -0x78201(%ebx),%eax
f01013e1:	50                   	push   %eax
f01013e2:	68 c1 02 00 00       	push   $0x2c1
f01013e7:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01013ed:	50                   	push   %eax
f01013ee:	e8 be ec ff ff       	call   f01000b1 <_panic>
		++nfree;
f01013f3:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013f6:	8b 00                	mov    (%eax),%eax
f01013f8:	85 c0                	test   %eax,%eax
f01013fa:	75 f7                	jne    f01013f3 <mem_init+0x156>
	assert((pp0 = page_alloc(0)));
f01013fc:	83 ec 0c             	sub    $0xc,%esp
f01013ff:	6a 00                	push   $0x0
f0101401:	e8 34 fb ff ff       	call   f0100f3a <page_alloc>
f0101406:	89 c3                	mov    %eax,%ebx
f0101408:	83 c4 10             	add    $0x10,%esp
f010140b:	85 c0                	test   %eax,%eax
f010140d:	0f 84 3a 02 00 00    	je     f010164d <mem_init+0x3b0>
	assert((pp1 = page_alloc(0)));
f0101413:	83 ec 0c             	sub    $0xc,%esp
f0101416:	6a 00                	push   $0x0
f0101418:	e8 1d fb ff ff       	call   f0100f3a <page_alloc>
f010141d:	89 c7                	mov    %eax,%edi
f010141f:	83 c4 10             	add    $0x10,%esp
f0101422:	85 c0                	test   %eax,%eax
f0101424:	0f 84 45 02 00 00    	je     f010166f <mem_init+0x3d2>
	assert((pp2 = page_alloc(0)));
f010142a:	83 ec 0c             	sub    $0xc,%esp
f010142d:	6a 00                	push   $0x0
f010142f:	e8 06 fb ff ff       	call   f0100f3a <page_alloc>
f0101434:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101437:	83 c4 10             	add    $0x10,%esp
f010143a:	85 c0                	test   %eax,%eax
f010143c:	0f 84 4f 02 00 00    	je     f0101691 <mem_init+0x3f4>
	assert(pp1 && pp1 != pp0);
f0101442:	39 fb                	cmp    %edi,%ebx
f0101444:	0f 84 69 02 00 00    	je     f01016b3 <mem_init+0x416>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010144a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010144d:	39 c7                	cmp    %eax,%edi
f010144f:	0f 84 80 02 00 00    	je     f01016d5 <mem_init+0x438>
f0101455:	39 c3                	cmp    %eax,%ebx
f0101457:	0f 84 78 02 00 00    	je     f01016d5 <mem_init+0x438>
	return (pp - pages) << PGSHIFT;
f010145d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101460:	8b 88 d0 1a 00 00    	mov    0x1ad0(%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101466:	8b 90 d8 1a 00 00    	mov    0x1ad8(%eax),%edx
f010146c:	c1 e2 0c             	shl    $0xc,%edx
f010146f:	89 d8                	mov    %ebx,%eax
f0101471:	29 c8                	sub    %ecx,%eax
f0101473:	c1 f8 03             	sar    $0x3,%eax
f0101476:	c1 e0 0c             	shl    $0xc,%eax
f0101479:	39 d0                	cmp    %edx,%eax
f010147b:	0f 83 76 02 00 00    	jae    f01016f7 <mem_init+0x45a>
f0101481:	89 f8                	mov    %edi,%eax
f0101483:	29 c8                	sub    %ecx,%eax
f0101485:	c1 f8 03             	sar    $0x3,%eax
f0101488:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010148b:	39 c2                	cmp    %eax,%edx
f010148d:	0f 86 86 02 00 00    	jbe    f0101719 <mem_init+0x47c>
f0101493:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101496:	29 c8                	sub    %ecx,%eax
f0101498:	c1 f8 03             	sar    $0x3,%eax
f010149b:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f010149e:	39 c2                	cmp    %eax,%edx
f01014a0:	0f 86 95 02 00 00    	jbe    f010173b <mem_init+0x49e>
	fl = page_free_list;
f01014a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014a9:	8b 88 e0 1a 00 00    	mov    0x1ae0(%eax),%ecx
f01014af:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f01014b2:	c7 80 e0 1a 00 00 00 	movl   $0x0,0x1ae0(%eax)
f01014b9:	00 00 00 
	assert(!page_alloc(0));
f01014bc:	83 ec 0c             	sub    $0xc,%esp
f01014bf:	6a 00                	push   $0x0
f01014c1:	e8 74 fa ff ff       	call   f0100f3a <page_alloc>
f01014c6:	83 c4 10             	add    $0x10,%esp
f01014c9:	85 c0                	test   %eax,%eax
f01014cb:	0f 85 8c 02 00 00    	jne    f010175d <mem_init+0x4c0>
	page_free(pp0);
f01014d1:	83 ec 0c             	sub    $0xc,%esp
f01014d4:	53                   	push   %ebx
f01014d5:	e8 e5 fa ff ff       	call   f0100fbf <page_free>
	page_free(pp1);
f01014da:	89 3c 24             	mov    %edi,(%esp)
f01014dd:	e8 dd fa ff ff       	call   f0100fbf <page_free>
	page_free(pp2);
f01014e2:	83 c4 04             	add    $0x4,%esp
f01014e5:	ff 75 d0             	push   -0x30(%ebp)
f01014e8:	e8 d2 fa ff ff       	call   f0100fbf <page_free>
	assert((pp0 = page_alloc(0)));
f01014ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014f4:	e8 41 fa ff ff       	call   f0100f3a <page_alloc>
f01014f9:	89 c7                	mov    %eax,%edi
f01014fb:	83 c4 10             	add    $0x10,%esp
f01014fe:	85 c0                	test   %eax,%eax
f0101500:	0f 84 79 02 00 00    	je     f010177f <mem_init+0x4e2>
	assert((pp1 = page_alloc(0)));
f0101506:	83 ec 0c             	sub    $0xc,%esp
f0101509:	6a 00                	push   $0x0
f010150b:	e8 2a fa ff ff       	call   f0100f3a <page_alloc>
f0101510:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101513:	83 c4 10             	add    $0x10,%esp
f0101516:	85 c0                	test   %eax,%eax
f0101518:	0f 84 83 02 00 00    	je     f01017a1 <mem_init+0x504>
	assert((pp2 = page_alloc(0)));
f010151e:	83 ec 0c             	sub    $0xc,%esp
f0101521:	6a 00                	push   $0x0
f0101523:	e8 12 fa ff ff       	call   f0100f3a <page_alloc>
f0101528:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010152b:	83 c4 10             	add    $0x10,%esp
f010152e:	85 c0                	test   %eax,%eax
f0101530:	0f 84 8d 02 00 00    	je     f01017c3 <mem_init+0x526>
	assert(pp1 && pp1 != pp0);
f0101536:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f0101539:	0f 84 a6 02 00 00    	je     f01017e5 <mem_init+0x548>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010153f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101542:	39 c7                	cmp    %eax,%edi
f0101544:	0f 84 bd 02 00 00    	je     f0101807 <mem_init+0x56a>
f010154a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010154d:	0f 84 b4 02 00 00    	je     f0101807 <mem_init+0x56a>
	assert(!page_alloc(0));
f0101553:	83 ec 0c             	sub    $0xc,%esp
f0101556:	6a 00                	push   $0x0
f0101558:	e8 dd f9 ff ff       	call   f0100f3a <page_alloc>
f010155d:	83 c4 10             	add    $0x10,%esp
f0101560:	85 c0                	test   %eax,%eax
f0101562:	0f 85 c1 02 00 00    	jne    f0101829 <mem_init+0x58c>
f0101568:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010156b:	89 f8                	mov    %edi,%eax
f010156d:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0101573:	c1 f8 03             	sar    $0x3,%eax
f0101576:	89 c2                	mov    %eax,%edx
f0101578:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010157b:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101580:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0101586:	0f 83 bf 02 00 00    	jae    f010184b <mem_init+0x5ae>
	memset(page2kva(pp0), 1, PGSIZE);
f010158c:	83 ec 04             	sub    $0x4,%esp
f010158f:	68 00 10 00 00       	push   $0x1000
f0101594:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101596:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010159c:	52                   	push   %edx
f010159d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01015a0:	e8 97 2f 00 00       	call   f010453c <memset>
	page_free(pp0);
f01015a5:	89 3c 24             	mov    %edi,(%esp)
f01015a8:	e8 12 fa ff ff       	call   f0100fbf <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015b4:	e8 81 f9 ff ff       	call   f0100f3a <page_alloc>
f01015b9:	83 c4 10             	add    $0x10,%esp
f01015bc:	85 c0                	test   %eax,%eax
f01015be:	0f 84 9f 02 00 00    	je     f0101863 <mem_init+0x5c6>
	assert(pp && pp0 == pp);
f01015c4:	39 c7                	cmp    %eax,%edi
f01015c6:	0f 85 b9 02 00 00    	jne    f0101885 <mem_init+0x5e8>
	return (pp - pages) << PGSHIFT;
f01015cc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01015cf:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f01015d5:	c1 f8 03             	sar    $0x3,%eax
f01015d8:	89 c2                	mov    %eax,%edx
f01015da:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01015dd:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01015e2:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f01015e8:	0f 83 b9 02 00 00    	jae    f01018a7 <mem_init+0x60a>
	return (void *)(pa + KERNBASE);
f01015ee:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01015f4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01015fa:	80 38 00             	cmpb   $0x0,(%eax)
f01015fd:	0f 85 bc 02 00 00    	jne    f01018bf <mem_init+0x622>
	for (i = 0; i < PGSIZE; i++)
f0101603:	83 c0 01             	add    $0x1,%eax
f0101606:	39 d0                	cmp    %edx,%eax
f0101608:	75 f0                	jne    f01015fa <mem_init+0x35d>
	page_free_list = fl;
f010160a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010160d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101610:	89 8b e0 1a 00 00    	mov    %ecx,0x1ae0(%ebx)
	page_free(pp0);
f0101616:	83 ec 0c             	sub    $0xc,%esp
f0101619:	57                   	push   %edi
f010161a:	e8 a0 f9 ff ff       	call   f0100fbf <page_free>
	page_free(pp1);
f010161f:	83 c4 04             	add    $0x4,%esp
f0101622:	ff 75 d0             	push   -0x30(%ebp)
f0101625:	e8 95 f9 ff ff       	call   f0100fbf <page_free>
	page_free(pp2);
f010162a:	83 c4 04             	add    $0x4,%esp
f010162d:	ff 75 cc             	push   -0x34(%ebp)
f0101630:	e8 8a f9 ff ff       	call   f0100fbf <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101635:	8b 83 e0 1a 00 00    	mov    0x1ae0(%ebx),%eax
f010163b:	83 c4 10             	add    $0x10,%esp
f010163e:	85 c0                	test   %eax,%eax
f0101640:	0f 84 9b 02 00 00    	je     f01018e1 <mem_init+0x644>
		--nfree;
f0101646:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101649:	8b 00                	mov    (%eax),%eax
f010164b:	eb f1                	jmp    f010163e <mem_init+0x3a1>
	assert((pp0 = page_alloc(0)));
f010164d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101650:	8d 83 1a 7e f8 ff    	lea    -0x781e6(%ebx),%eax
f0101656:	50                   	push   %eax
f0101657:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010165d:	50                   	push   %eax
f010165e:	68 c9 02 00 00       	push   $0x2c9
f0101663:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0101669:	50                   	push   %eax
f010166a:	e8 42 ea ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f010166f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101672:	8d 83 30 7e f8 ff    	lea    -0x781d0(%ebx),%eax
f0101678:	50                   	push   %eax
f0101679:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010167f:	50                   	push   %eax
f0101680:	68 ca 02 00 00       	push   $0x2ca
f0101685:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010168b:	50                   	push   %eax
f010168c:	e8 20 ea ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101691:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101694:	8d 83 46 7e f8 ff    	lea    -0x781ba(%ebx),%eax
f010169a:	50                   	push   %eax
f010169b:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01016a1:	50                   	push   %eax
f01016a2:	68 cb 02 00 00       	push   $0x2cb
f01016a7:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01016ad:	50                   	push   %eax
f01016ae:	e8 fe e9 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01016b3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016b6:	8d 83 5c 7e f8 ff    	lea    -0x781a4(%ebx),%eax
f01016bc:	50                   	push   %eax
f01016bd:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01016c3:	50                   	push   %eax
f01016c4:	68 ce 02 00 00       	push   $0x2ce
f01016c9:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01016cf:	50                   	push   %eax
f01016d0:	e8 dc e9 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016d8:	8d 83 2c 77 f8 ff    	lea    -0x788d4(%ebx),%eax
f01016de:	50                   	push   %eax
f01016df:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01016e5:	50                   	push   %eax
f01016e6:	68 cf 02 00 00       	push   $0x2cf
f01016eb:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01016f1:	50                   	push   %eax
f01016f2:	e8 ba e9 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01016f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016fa:	8d 83 6e 7e f8 ff    	lea    -0x78192(%ebx),%eax
f0101700:	50                   	push   %eax
f0101701:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0101707:	50                   	push   %eax
f0101708:	68 d0 02 00 00       	push   $0x2d0
f010170d:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0101713:	50                   	push   %eax
f0101714:	e8 98 e9 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101719:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010171c:	8d 83 8b 7e f8 ff    	lea    -0x78175(%ebx),%eax
f0101722:	50                   	push   %eax
f0101723:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0101729:	50                   	push   %eax
f010172a:	68 d1 02 00 00       	push   $0x2d1
f010172f:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0101735:	50                   	push   %eax
f0101736:	e8 76 e9 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010173b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010173e:	8d 83 a8 7e f8 ff    	lea    -0x78158(%ebx),%eax
f0101744:	50                   	push   %eax
f0101745:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010174b:	50                   	push   %eax
f010174c:	68 d2 02 00 00       	push   $0x2d2
f0101751:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0101757:	50                   	push   %eax
f0101758:	e8 54 e9 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010175d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101760:	8d 83 c5 7e f8 ff    	lea    -0x7813b(%ebx),%eax
f0101766:	50                   	push   %eax
f0101767:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010176d:	50                   	push   %eax
f010176e:	68 d9 02 00 00       	push   $0x2d9
f0101773:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0101779:	50                   	push   %eax
f010177a:	e8 32 e9 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f010177f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101782:	8d 83 1a 7e f8 ff    	lea    -0x781e6(%ebx),%eax
f0101788:	50                   	push   %eax
f0101789:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010178f:	50                   	push   %eax
f0101790:	68 e0 02 00 00       	push   $0x2e0
f0101795:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010179b:	50                   	push   %eax
f010179c:	e8 10 e9 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01017a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017a4:	8d 83 30 7e f8 ff    	lea    -0x781d0(%ebx),%eax
f01017aa:	50                   	push   %eax
f01017ab:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01017b1:	50                   	push   %eax
f01017b2:	68 e1 02 00 00       	push   $0x2e1
f01017b7:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01017bd:	50                   	push   %eax
f01017be:	e8 ee e8 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01017c3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017c6:	8d 83 46 7e f8 ff    	lea    -0x781ba(%ebx),%eax
f01017cc:	50                   	push   %eax
f01017cd:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01017d3:	50                   	push   %eax
f01017d4:	68 e2 02 00 00       	push   $0x2e2
f01017d9:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01017df:	50                   	push   %eax
f01017e0:	e8 cc e8 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01017e5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017e8:	8d 83 5c 7e f8 ff    	lea    -0x781a4(%ebx),%eax
f01017ee:	50                   	push   %eax
f01017ef:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01017f5:	50                   	push   %eax
f01017f6:	68 e4 02 00 00       	push   $0x2e4
f01017fb:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0101801:	50                   	push   %eax
f0101802:	e8 aa e8 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101807:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010180a:	8d 83 2c 77 f8 ff    	lea    -0x788d4(%ebx),%eax
f0101810:	50                   	push   %eax
f0101811:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0101817:	50                   	push   %eax
f0101818:	68 e5 02 00 00       	push   $0x2e5
f010181d:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0101823:	50                   	push   %eax
f0101824:	e8 88 e8 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101829:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010182c:	8d 83 c5 7e f8 ff    	lea    -0x7813b(%ebx),%eax
f0101832:	50                   	push   %eax
f0101833:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0101839:	50                   	push   %eax
f010183a:	68 e6 02 00 00       	push   $0x2e6
f010183f:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0101845:	50                   	push   %eax
f0101846:	e8 66 e8 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010184b:	52                   	push   %edx
f010184c:	89 cb                	mov    %ecx,%ebx
f010184e:	8d 81 7c 75 f8 ff    	lea    -0x78a84(%ecx),%eax
f0101854:	50                   	push   %eax
f0101855:	6a 56                	push   $0x56
f0101857:	8d 81 55 7d f8 ff    	lea    -0x782ab(%ecx),%eax
f010185d:	50                   	push   %eax
f010185e:	e8 4e e8 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101863:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101866:	8d 83 d4 7e f8 ff    	lea    -0x7812c(%ebx),%eax
f010186c:	50                   	push   %eax
f010186d:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0101873:	50                   	push   %eax
f0101874:	68 eb 02 00 00       	push   $0x2eb
f0101879:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010187f:	50                   	push   %eax
f0101880:	e8 2c e8 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f0101885:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101888:	8d 83 f2 7e f8 ff    	lea    -0x7810e(%ebx),%eax
f010188e:	50                   	push   %eax
f010188f:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0101895:	50                   	push   %eax
f0101896:	68 ec 02 00 00       	push   $0x2ec
f010189b:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01018a1:	50                   	push   %eax
f01018a2:	e8 0a e8 ff ff       	call   f01000b1 <_panic>
f01018a7:	52                   	push   %edx
f01018a8:	89 cb                	mov    %ecx,%ebx
f01018aa:	8d 81 7c 75 f8 ff    	lea    -0x78a84(%ecx),%eax
f01018b0:	50                   	push   %eax
f01018b1:	6a 56                	push   $0x56
f01018b3:	8d 81 55 7d f8 ff    	lea    -0x782ab(%ecx),%eax
f01018b9:	50                   	push   %eax
f01018ba:	e8 f2 e7 ff ff       	call   f01000b1 <_panic>
		assert(c[i] == 0);
f01018bf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018c2:	8d 83 02 7f f8 ff    	lea    -0x780fe(%ebx),%eax
f01018c8:	50                   	push   %eax
f01018c9:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01018cf:	50                   	push   %eax
f01018d0:	68 ef 02 00 00       	push   $0x2ef
f01018d5:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01018db:	50                   	push   %eax
f01018dc:	e8 d0 e7 ff ff       	call   f01000b1 <_panic>
	assert(nfree == 0);
f01018e1:	85 f6                	test   %esi,%esi
f01018e3:	0f 85 2f 08 00 00    	jne    f0102118 <mem_init+0xe7b>
	cprintf("check_page_alloc() succeeded!\n");
f01018e9:	83 ec 0c             	sub    $0xc,%esp
f01018ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018ef:	8d 83 4c 77 f8 ff    	lea    -0x788b4(%ebx),%eax
f01018f5:	50                   	push   %eax
f01018f6:	e8 44 1c 00 00       	call   f010353f <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101902:	e8 33 f6 ff ff       	call   f0100f3a <page_alloc>
f0101907:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010190a:	83 c4 10             	add    $0x10,%esp
f010190d:	85 c0                	test   %eax,%eax
f010190f:	0f 84 25 08 00 00    	je     f010213a <mem_init+0xe9d>
	assert((pp1 = page_alloc(0)));
f0101915:	83 ec 0c             	sub    $0xc,%esp
f0101918:	6a 00                	push   $0x0
f010191a:	e8 1b f6 ff ff       	call   f0100f3a <page_alloc>
f010191f:	89 c7                	mov    %eax,%edi
f0101921:	83 c4 10             	add    $0x10,%esp
f0101924:	85 c0                	test   %eax,%eax
f0101926:	0f 84 30 08 00 00    	je     f010215c <mem_init+0xebf>
	assert((pp2 = page_alloc(0)));
f010192c:	83 ec 0c             	sub    $0xc,%esp
f010192f:	6a 00                	push   $0x0
f0101931:	e8 04 f6 ff ff       	call   f0100f3a <page_alloc>
f0101936:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101939:	83 c4 10             	add    $0x10,%esp
f010193c:	85 c0                	test   %eax,%eax
f010193e:	0f 84 3a 08 00 00    	je     f010217e <mem_init+0xee1>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101944:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0101947:	0f 84 53 08 00 00    	je     f01021a0 <mem_init+0xf03>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010194d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101950:	39 c7                	cmp    %eax,%edi
f0101952:	0f 84 6a 08 00 00    	je     f01021c2 <mem_init+0xf25>
f0101958:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010195b:	0f 84 61 08 00 00    	je     f01021c2 <mem_init+0xf25>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101961:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101964:	8b 88 e0 1a 00 00    	mov    0x1ae0(%eax),%ecx
f010196a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f010196d:	c7 80 e0 1a 00 00 00 	movl   $0x0,0x1ae0(%eax)
f0101974:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101977:	83 ec 0c             	sub    $0xc,%esp
f010197a:	6a 00                	push   $0x0
f010197c:	e8 b9 f5 ff ff       	call   f0100f3a <page_alloc>
f0101981:	83 c4 10             	add    $0x10,%esp
f0101984:	85 c0                	test   %eax,%eax
f0101986:	0f 85 58 08 00 00    	jne    f01021e4 <mem_init+0xf47>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010198c:	83 ec 04             	sub    $0x4,%esp
f010198f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101992:	50                   	push   %eax
f0101993:	6a 00                	push   $0x0
f0101995:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101998:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f010199e:	e8 e2 f7 ff ff       	call   f0101185 <page_lookup>
f01019a3:	83 c4 10             	add    $0x10,%esp
f01019a6:	85 c0                	test   %eax,%eax
f01019a8:	0f 85 58 08 00 00    	jne    f0102206 <mem_init+0xf69>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019ae:	6a 02                	push   $0x2
f01019b0:	6a 00                	push   $0x0
f01019b2:	57                   	push   %edi
f01019b3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019b6:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f01019bc:	e8 64 f8 ff ff       	call   f0101225 <page_insert>
f01019c1:	83 c4 10             	add    $0x10,%esp
f01019c4:	85 c0                	test   %eax,%eax
f01019c6:	0f 89 5c 08 00 00    	jns    f0102228 <mem_init+0xf8b>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01019cc:	83 ec 0c             	sub    $0xc,%esp
f01019cf:	ff 75 cc             	push   -0x34(%ebp)
f01019d2:	e8 e8 f5 ff ff       	call   f0100fbf <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01019d7:	6a 02                	push   $0x2
f01019d9:	6a 00                	push   $0x0
f01019db:	57                   	push   %edi
f01019dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019df:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f01019e5:	e8 3b f8 ff ff       	call   f0101225 <page_insert>
f01019ea:	83 c4 20             	add    $0x20,%esp
f01019ed:	85 c0                	test   %eax,%eax
f01019ef:	0f 85 55 08 00 00    	jne    f010224a <mem_init+0xfad>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019f8:	8b 98 d4 1a 00 00    	mov    0x1ad4(%eax),%ebx
	return (pp - pages) << PGSHIFT;
f01019fe:	8b b0 d0 1a 00 00    	mov    0x1ad0(%eax),%esi
f0101a04:	8b 13                	mov    (%ebx),%edx
f0101a06:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a0c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101a0f:	29 f0                	sub    %esi,%eax
f0101a11:	c1 f8 03             	sar    $0x3,%eax
f0101a14:	c1 e0 0c             	shl    $0xc,%eax
f0101a17:	39 c2                	cmp    %eax,%edx
f0101a19:	0f 85 4d 08 00 00    	jne    f010226c <mem_init+0xfcf>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a1f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a24:	89 d8                	mov    %ebx,%eax
f0101a26:	e8 ff ef ff ff       	call   f0100a2a <check_va2pa>
f0101a2b:	89 c2                	mov    %eax,%edx
f0101a2d:	89 f8                	mov    %edi,%eax
f0101a2f:	29 f0                	sub    %esi,%eax
f0101a31:	c1 f8 03             	sar    $0x3,%eax
f0101a34:	c1 e0 0c             	shl    $0xc,%eax
f0101a37:	39 c2                	cmp    %eax,%edx
f0101a39:	0f 85 4f 08 00 00    	jne    f010228e <mem_init+0xff1>
	assert(pp1->pp_ref == 1);
f0101a3f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a44:	0f 85 66 08 00 00    	jne    f01022b0 <mem_init+0x1013>
	assert(pp0->pp_ref == 1);
f0101a4a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101a4d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a52:	0f 85 7a 08 00 00    	jne    f01022d2 <mem_init+0x1035>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a58:	6a 02                	push   $0x2
f0101a5a:	68 00 10 00 00       	push   $0x1000
f0101a5f:	ff 75 d0             	push   -0x30(%ebp)
f0101a62:	53                   	push   %ebx
f0101a63:	e8 bd f7 ff ff       	call   f0101225 <page_insert>
f0101a68:	83 c4 10             	add    $0x10,%esp
f0101a6b:	85 c0                	test   %eax,%eax
f0101a6d:	0f 85 81 08 00 00    	jne    f01022f4 <mem_init+0x1057>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a73:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a78:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a7b:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
f0101a81:	e8 a4 ef ff ff       	call   f0100a2a <check_va2pa>
f0101a86:	89 c2                	mov    %eax,%edx
f0101a88:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a8b:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101a91:	c1 f8 03             	sar    $0x3,%eax
f0101a94:	c1 e0 0c             	shl    $0xc,%eax
f0101a97:	39 c2                	cmp    %eax,%edx
f0101a99:	0f 85 77 08 00 00    	jne    f0102316 <mem_init+0x1079>
	assert(pp2->pp_ref == 1);
f0101a9f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101aa2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101aa7:	0f 85 8b 08 00 00    	jne    f0102338 <mem_init+0x109b>

	// should be no free memory
	assert(!page_alloc(0));
f0101aad:	83 ec 0c             	sub    $0xc,%esp
f0101ab0:	6a 00                	push   $0x0
f0101ab2:	e8 83 f4 ff ff       	call   f0100f3a <page_alloc>
f0101ab7:	83 c4 10             	add    $0x10,%esp
f0101aba:	85 c0                	test   %eax,%eax
f0101abc:	0f 85 98 08 00 00    	jne    f010235a <mem_init+0x10bd>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ac2:	6a 02                	push   $0x2
f0101ac4:	68 00 10 00 00       	push   $0x1000
f0101ac9:	ff 75 d0             	push   -0x30(%ebp)
f0101acc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101acf:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101ad5:	e8 4b f7 ff ff       	call   f0101225 <page_insert>
f0101ada:	83 c4 10             	add    $0x10,%esp
f0101add:	85 c0                	test   %eax,%eax
f0101adf:	0f 85 97 08 00 00    	jne    f010237c <mem_init+0x10df>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ae5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101aed:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
f0101af3:	e8 32 ef ff ff       	call   f0100a2a <check_va2pa>
f0101af8:	89 c2                	mov    %eax,%edx
f0101afa:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101afd:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101b03:	c1 f8 03             	sar    $0x3,%eax
f0101b06:	c1 e0 0c             	shl    $0xc,%eax
f0101b09:	39 c2                	cmp    %eax,%edx
f0101b0b:	0f 85 8d 08 00 00    	jne    f010239e <mem_init+0x1101>
	assert(pp2->pp_ref == 1);
f0101b11:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b14:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b19:	0f 85 a1 08 00 00    	jne    f01023c0 <mem_init+0x1123>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b1f:	83 ec 0c             	sub    $0xc,%esp
f0101b22:	6a 00                	push   $0x0
f0101b24:	e8 11 f4 ff ff       	call   f0100f3a <page_alloc>
f0101b29:	83 c4 10             	add    $0x10,%esp
f0101b2c:	85 c0                	test   %eax,%eax
f0101b2e:	0f 85 ae 08 00 00    	jne    f01023e2 <mem_init+0x1145>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b34:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b37:	8b 91 d4 1a 00 00    	mov    0x1ad4(%ecx),%edx
f0101b3d:	8b 02                	mov    (%edx),%eax
f0101b3f:	89 c3                	mov    %eax,%ebx
f0101b41:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PGNUM(pa) >= npages)
f0101b47:	c1 e8 0c             	shr    $0xc,%eax
f0101b4a:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0101b50:	0f 83 ae 08 00 00    	jae    f0102404 <mem_init+0x1167>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b56:	83 ec 04             	sub    $0x4,%esp
f0101b59:	6a 00                	push   $0x0
f0101b5b:	68 00 10 00 00       	push   $0x1000
f0101b60:	52                   	push   %edx
f0101b61:	e8 d1 f4 ff ff       	call   f0101037 <pgdir_walk>
f0101b66:	81 eb fc ff ff 0f    	sub    $0xffffffc,%ebx
f0101b6c:	83 c4 10             	add    $0x10,%esp
f0101b6f:	39 d8                	cmp    %ebx,%eax
f0101b71:	0f 85 a8 08 00 00    	jne    f010241f <mem_init+0x1182>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b77:	6a 06                	push   $0x6
f0101b79:	68 00 10 00 00       	push   $0x1000
f0101b7e:	ff 75 d0             	push   -0x30(%ebp)
f0101b81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b84:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101b8a:	e8 96 f6 ff ff       	call   f0101225 <page_insert>
f0101b8f:	83 c4 10             	add    $0x10,%esp
f0101b92:	85 c0                	test   %eax,%eax
f0101b94:	0f 85 a7 08 00 00    	jne    f0102441 <mem_init+0x11a4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b9a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101b9d:	8b 9e d4 1a 00 00    	mov    0x1ad4(%esi),%ebx
f0101ba3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ba8:	89 d8                	mov    %ebx,%eax
f0101baa:	e8 7b ee ff ff       	call   f0100a2a <check_va2pa>
f0101baf:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101bb1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bb4:	2b 86 d0 1a 00 00    	sub    0x1ad0(%esi),%eax
f0101bba:	c1 f8 03             	sar    $0x3,%eax
f0101bbd:	c1 e0 0c             	shl    $0xc,%eax
f0101bc0:	39 c2                	cmp    %eax,%edx
f0101bc2:	0f 85 9b 08 00 00    	jne    f0102463 <mem_init+0x11c6>
	assert(pp2->pp_ref == 1);
f0101bc8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bcb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bd0:	0f 85 af 08 00 00    	jne    f0102485 <mem_init+0x11e8>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101bd6:	83 ec 04             	sub    $0x4,%esp
f0101bd9:	6a 00                	push   $0x0
f0101bdb:	68 00 10 00 00       	push   $0x1000
f0101be0:	53                   	push   %ebx
f0101be1:	e8 51 f4 ff ff       	call   f0101037 <pgdir_walk>
f0101be6:	83 c4 10             	add    $0x10,%esp
f0101be9:	f6 00 04             	testb  $0x4,(%eax)
f0101bec:	0f 84 b5 08 00 00    	je     f01024a7 <mem_init+0x120a>
	assert(kern_pgdir[0] & PTE_U);
f0101bf2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bf5:	8b 80 d4 1a 00 00    	mov    0x1ad4(%eax),%eax
f0101bfb:	f6 00 04             	testb  $0x4,(%eax)
f0101bfe:	0f 84 c5 08 00 00    	je     f01024c9 <mem_init+0x122c>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c04:	6a 02                	push   $0x2
f0101c06:	68 00 10 00 00       	push   $0x1000
f0101c0b:	ff 75 d0             	push   -0x30(%ebp)
f0101c0e:	50                   	push   %eax
f0101c0f:	e8 11 f6 ff ff       	call   f0101225 <page_insert>
f0101c14:	83 c4 10             	add    $0x10,%esp
f0101c17:	85 c0                	test   %eax,%eax
f0101c19:	0f 85 cc 08 00 00    	jne    f01024eb <mem_init+0x124e>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c1f:	83 ec 04             	sub    $0x4,%esp
f0101c22:	6a 00                	push   $0x0
f0101c24:	68 00 10 00 00       	push   $0x1000
f0101c29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c2c:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101c32:	e8 00 f4 ff ff       	call   f0101037 <pgdir_walk>
f0101c37:	83 c4 10             	add    $0x10,%esp
f0101c3a:	f6 00 02             	testb  $0x2,(%eax)
f0101c3d:	0f 84 ca 08 00 00    	je     f010250d <mem_init+0x1270>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c43:	83 ec 04             	sub    $0x4,%esp
f0101c46:	6a 00                	push   $0x0
f0101c48:	68 00 10 00 00       	push   $0x1000
f0101c4d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c50:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101c56:	e8 dc f3 ff ff       	call   f0101037 <pgdir_walk>
f0101c5b:	83 c4 10             	add    $0x10,%esp
f0101c5e:	f6 00 04             	testb  $0x4,(%eax)
f0101c61:	0f 85 c8 08 00 00    	jne    f010252f <mem_init+0x1292>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c67:	6a 02                	push   $0x2
f0101c69:	68 00 00 40 00       	push   $0x400000
f0101c6e:	ff 75 cc             	push   -0x34(%ebp)
f0101c71:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c74:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101c7a:	e8 a6 f5 ff ff       	call   f0101225 <page_insert>
f0101c7f:	83 c4 10             	add    $0x10,%esp
f0101c82:	85 c0                	test   %eax,%eax
f0101c84:	0f 89 c7 08 00 00    	jns    f0102551 <mem_init+0x12b4>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c8a:	6a 02                	push   $0x2
f0101c8c:	68 00 10 00 00       	push   $0x1000
f0101c91:	57                   	push   %edi
f0101c92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c95:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101c9b:	e8 85 f5 ff ff       	call   f0101225 <page_insert>
f0101ca0:	83 c4 10             	add    $0x10,%esp
f0101ca3:	85 c0                	test   %eax,%eax
f0101ca5:	0f 85 c8 08 00 00    	jne    f0102573 <mem_init+0x12d6>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101cab:	83 ec 04             	sub    $0x4,%esp
f0101cae:	6a 00                	push   $0x0
f0101cb0:	68 00 10 00 00       	push   $0x1000
f0101cb5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cb8:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101cbe:	e8 74 f3 ff ff       	call   f0101037 <pgdir_walk>
f0101cc3:	83 c4 10             	add    $0x10,%esp
f0101cc6:	f6 00 04             	testb  $0x4,(%eax)
f0101cc9:	0f 85 c6 08 00 00    	jne    f0102595 <mem_init+0x12f8>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ccf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101cd2:	8b b3 d4 1a 00 00    	mov    0x1ad4(%ebx),%esi
f0101cd8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cdd:	89 f0                	mov    %esi,%eax
f0101cdf:	e8 46 ed ff ff       	call   f0100a2a <check_va2pa>
f0101ce4:	89 d9                	mov    %ebx,%ecx
f0101ce6:	89 fb                	mov    %edi,%ebx
f0101ce8:	2b 99 d0 1a 00 00    	sub    0x1ad0(%ecx),%ebx
f0101cee:	c1 fb 03             	sar    $0x3,%ebx
f0101cf1:	c1 e3 0c             	shl    $0xc,%ebx
f0101cf4:	39 d8                	cmp    %ebx,%eax
f0101cf6:	0f 85 bb 08 00 00    	jne    f01025b7 <mem_init+0x131a>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cfc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d01:	89 f0                	mov    %esi,%eax
f0101d03:	e8 22 ed ff ff       	call   f0100a2a <check_va2pa>
f0101d08:	39 c3                	cmp    %eax,%ebx
f0101d0a:	0f 85 c9 08 00 00    	jne    f01025d9 <mem_init+0x133c>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d10:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101d15:	0f 85 e0 08 00 00    	jne    f01025fb <mem_init+0x135e>
	assert(pp2->pp_ref == 0);
f0101d1b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d1e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101d23:	0f 85 f4 08 00 00    	jne    f010261d <mem_init+0x1380>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d29:	83 ec 0c             	sub    $0xc,%esp
f0101d2c:	6a 00                	push   $0x0
f0101d2e:	e8 07 f2 ff ff       	call   f0100f3a <page_alloc>
f0101d33:	83 c4 10             	add    $0x10,%esp
f0101d36:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101d39:	0f 85 00 09 00 00    	jne    f010263f <mem_init+0x13a2>
f0101d3f:	85 c0                	test   %eax,%eax
f0101d41:	0f 84 f8 08 00 00    	je     f010263f <mem_init+0x13a2>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d47:	83 ec 08             	sub    $0x8,%esp
f0101d4a:	6a 00                	push   $0x0
f0101d4c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d4f:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101d55:	e8 90 f4 ff ff       	call   f01011ea <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d5a:	8b 9b d4 1a 00 00    	mov    0x1ad4(%ebx),%ebx
f0101d60:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d65:	89 d8                	mov    %ebx,%eax
f0101d67:	e8 be ec ff ff       	call   f0100a2a <check_va2pa>
f0101d6c:	83 c4 10             	add    $0x10,%esp
f0101d6f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d72:	0f 85 e9 08 00 00    	jne    f0102661 <mem_init+0x13c4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d78:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d7d:	89 d8                	mov    %ebx,%eax
f0101d7f:	e8 a6 ec ff ff       	call   f0100a2a <check_va2pa>
f0101d84:	89 c2                	mov    %eax,%edx
f0101d86:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d89:	89 f8                	mov    %edi,%eax
f0101d8b:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0101d91:	c1 f8 03             	sar    $0x3,%eax
f0101d94:	c1 e0 0c             	shl    $0xc,%eax
f0101d97:	39 c2                	cmp    %eax,%edx
f0101d99:	0f 85 e4 08 00 00    	jne    f0102683 <mem_init+0x13e6>
	assert(pp1->pp_ref == 1);
f0101d9f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101da4:	0f 85 fa 08 00 00    	jne    f01026a4 <mem_init+0x1407>
	assert(pp2->pp_ref == 0);
f0101daa:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101dad:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101db2:	0f 85 0e 09 00 00    	jne    f01026c6 <mem_init+0x1429>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101db8:	6a 00                	push   $0x0
f0101dba:	68 00 10 00 00       	push   $0x1000
f0101dbf:	57                   	push   %edi
f0101dc0:	53                   	push   %ebx
f0101dc1:	e8 5f f4 ff ff       	call   f0101225 <page_insert>
f0101dc6:	83 c4 10             	add    $0x10,%esp
f0101dc9:	85 c0                	test   %eax,%eax
f0101dcb:	0f 85 17 09 00 00    	jne    f01026e8 <mem_init+0x144b>
	assert(pp1->pp_ref);
f0101dd1:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101dd6:	0f 84 2e 09 00 00    	je     f010270a <mem_init+0x146d>
	assert(pp1->pp_link == NULL);
f0101ddc:	83 3f 00             	cmpl   $0x0,(%edi)
f0101ddf:	0f 85 47 09 00 00    	jne    f010272c <mem_init+0x148f>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101de5:	83 ec 08             	sub    $0x8,%esp
f0101de8:	68 00 10 00 00       	push   $0x1000
f0101ded:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101df0:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101df6:	e8 ef f3 ff ff       	call   f01011ea <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101dfb:	8b 9b d4 1a 00 00    	mov    0x1ad4(%ebx),%ebx
f0101e01:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e06:	89 d8                	mov    %ebx,%eax
f0101e08:	e8 1d ec ff ff       	call   f0100a2a <check_va2pa>
f0101e0d:	83 c4 10             	add    $0x10,%esp
f0101e10:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e13:	0f 85 35 09 00 00    	jne    f010274e <mem_init+0x14b1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101e19:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e1e:	89 d8                	mov    %ebx,%eax
f0101e20:	e8 05 ec ff ff       	call   f0100a2a <check_va2pa>
f0101e25:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e28:	0f 85 42 09 00 00    	jne    f0102770 <mem_init+0x14d3>
	assert(pp1->pp_ref == 0);
f0101e2e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101e33:	0f 85 59 09 00 00    	jne    f0102792 <mem_init+0x14f5>
	assert(pp2->pp_ref == 0);
f0101e39:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e3c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e41:	0f 85 6d 09 00 00    	jne    f01027b4 <mem_init+0x1517>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e47:	83 ec 0c             	sub    $0xc,%esp
f0101e4a:	6a 00                	push   $0x0
f0101e4c:	e8 e9 f0 ff ff       	call   f0100f3a <page_alloc>
f0101e51:	83 c4 10             	add    $0x10,%esp
f0101e54:	85 c0                	test   %eax,%eax
f0101e56:	0f 84 7a 09 00 00    	je     f01027d6 <mem_init+0x1539>
f0101e5c:	39 c7                	cmp    %eax,%edi
f0101e5e:	0f 85 72 09 00 00    	jne    f01027d6 <mem_init+0x1539>

	// should be no free memory
	assert(!page_alloc(0));
f0101e64:	83 ec 0c             	sub    $0xc,%esp
f0101e67:	6a 00                	push   $0x0
f0101e69:	e8 cc f0 ff ff       	call   f0100f3a <page_alloc>
f0101e6e:	83 c4 10             	add    $0x10,%esp
f0101e71:	85 c0                	test   %eax,%eax
f0101e73:	0f 85 7f 09 00 00    	jne    f01027f8 <mem_init+0x155b>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e79:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e7c:	8b 88 d4 1a 00 00    	mov    0x1ad4(%eax),%ecx
f0101e82:	8b 11                	mov    (%ecx),%edx
f0101e84:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e8a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0101e8d:	2b 98 d0 1a 00 00    	sub    0x1ad0(%eax),%ebx
f0101e93:	89 d8                	mov    %ebx,%eax
f0101e95:	c1 f8 03             	sar    $0x3,%eax
f0101e98:	c1 e0 0c             	shl    $0xc,%eax
f0101e9b:	39 c2                	cmp    %eax,%edx
f0101e9d:	0f 85 77 09 00 00    	jne    f010281a <mem_init+0x157d>
	kern_pgdir[0] = 0;
f0101ea3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101ea9:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101eac:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101eb1:	0f 85 85 09 00 00    	jne    f010283c <mem_init+0x159f>
	pp0->pp_ref = 0;
f0101eb7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101eba:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101ec0:	83 ec 0c             	sub    $0xc,%esp
f0101ec3:	50                   	push   %eax
f0101ec4:	e8 f6 f0 ff ff       	call   f0100fbf <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101ec9:	83 c4 0c             	add    $0xc,%esp
f0101ecc:	6a 01                	push   $0x1
f0101ece:	68 00 10 40 00       	push   $0x401000
f0101ed3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ed6:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101edc:	e8 56 f1 ff ff       	call   f0101037 <pgdir_walk>
f0101ee1:	89 c6                	mov    %eax,%esi
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101ee3:	89 d9                	mov    %ebx,%ecx
f0101ee5:	8b 9b d4 1a 00 00    	mov    0x1ad4(%ebx),%ebx
f0101eeb:	8b 43 04             	mov    0x4(%ebx),%eax
f0101eee:	89 c2                	mov    %eax,%edx
f0101ef0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101ef6:	8b 89 d8 1a 00 00    	mov    0x1ad8(%ecx),%ecx
f0101efc:	c1 e8 0c             	shr    $0xc,%eax
f0101eff:	83 c4 10             	add    $0x10,%esp
f0101f02:	39 c8                	cmp    %ecx,%eax
f0101f04:	0f 83 54 09 00 00    	jae    f010285e <mem_init+0x15c1>
	assert(ptep == ptep1 + PTX(va));
f0101f0a:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101f10:	39 d6                	cmp    %edx,%esi
f0101f12:	0f 85 62 09 00 00    	jne    f010287a <mem_init+0x15dd>
	kern_pgdir[PDX(va)] = 0;
f0101f18:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0101f1f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f22:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101f28:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f2b:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101f31:	c1 f8 03             	sar    $0x3,%eax
f0101f34:	89 c2                	mov    %eax,%edx
f0101f36:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f39:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101f3e:	39 c1                	cmp    %eax,%ecx
f0101f40:	0f 86 56 09 00 00    	jbe    f010289c <mem_init+0x15ff>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101f46:	83 ec 04             	sub    $0x4,%esp
f0101f49:	68 00 10 00 00       	push   $0x1000
f0101f4e:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101f53:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101f59:	52                   	push   %edx
f0101f5a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f5d:	e8 da 25 00 00       	call   f010453c <memset>
	page_free(pp0);
f0101f62:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101f65:	89 34 24             	mov    %esi,(%esp)
f0101f68:	e8 52 f0 ff ff       	call   f0100fbf <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101f6d:	83 c4 0c             	add    $0xc,%esp
f0101f70:	6a 01                	push   $0x1
f0101f72:	6a 00                	push   $0x0
f0101f74:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101f7a:	e8 b8 f0 ff ff       	call   f0101037 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101f7f:	89 f0                	mov    %esi,%eax
f0101f81:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101f87:	c1 f8 03             	sar    $0x3,%eax
f0101f8a:	89 c2                	mov    %eax,%edx
f0101f8c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f8f:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101f94:	83 c4 10             	add    $0x10,%esp
f0101f97:	3b 83 d8 1a 00 00    	cmp    0x1ad8(%ebx),%eax
f0101f9d:	0f 83 0f 09 00 00    	jae    f01028b2 <mem_init+0x1615>
	return (void *)(pa + KERNBASE);
f0101fa3:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101fa9:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101faf:	8b 30                	mov    (%eax),%esi
f0101fb1:	83 e6 01             	and    $0x1,%esi
f0101fb4:	0f 85 11 09 00 00    	jne    f01028cb <mem_init+0x162e>
	for(i=0; i<NPTENTRIES; i++)
f0101fba:	83 c0 04             	add    $0x4,%eax
f0101fbd:	39 c2                	cmp    %eax,%edx
f0101fbf:	75 ee                	jne    f0101faf <mem_init+0xd12>
	kern_pgdir[0] = 0;
f0101fc1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fc4:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
f0101fca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101fd0:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101fd3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101fd9:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0101fdc:	89 93 e0 1a 00 00    	mov    %edx,0x1ae0(%ebx)

	// free the pages we took
	page_free(pp0);
f0101fe2:	83 ec 0c             	sub    $0xc,%esp
f0101fe5:	50                   	push   %eax
f0101fe6:	e8 d4 ef ff ff       	call   f0100fbf <page_free>
	page_free(pp1);
f0101feb:	89 3c 24             	mov    %edi,(%esp)
f0101fee:	e8 cc ef ff ff       	call   f0100fbf <page_free>
	page_free(pp2);
f0101ff3:	83 c4 04             	add    $0x4,%esp
f0101ff6:	ff 75 d0             	push   -0x30(%ebp)
f0101ff9:	e8 c1 ef ff ff       	call   f0100fbf <page_free>

	cprintf("check_page() succeeded!\n");
f0101ffe:	8d 83 e3 7f f8 ff    	lea    -0x7801d(%ebx),%eax
f0102004:	89 04 24             	mov    %eax,(%esp)
f0102007:	e8 33 15 00 00       	call   f010353f <cprintf>
	boot_map_region(kern_pgdir, (intptr_t)UPAGES, npages * sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f010200c:	8b 83 d0 1a 00 00    	mov    0x1ad0(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102012:	83 c4 10             	add    $0x10,%esp
f0102015:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010201a:	0f 86 cd 08 00 00    	jbe    f01028ed <mem_init+0x1650>
f0102020:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102023:	8b 8f d8 1a 00 00    	mov    0x1ad8(%edi),%ecx
f0102029:	c1 e1 03             	shl    $0x3,%ecx
f010202c:	83 ec 08             	sub    $0x8,%esp
f010202f:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102031:	05 00 00 00 10       	add    $0x10000000,%eax
f0102036:	50                   	push   %eax
f0102037:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010203c:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f0102042:	e8 ea f0 ff ff       	call   f0101131 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102047:	c7 c0 00 10 11 f0    	mov    $0xf0111000,%eax
f010204d:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102050:	83 c4 10             	add    $0x10,%esp
f0102053:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102058:	0f 86 ab 08 00 00    	jbe    f0102909 <mem_init+0x166c>
	boot_map_region(kern_pgdir, (intptr_t)(KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f010205e:	83 ec 08             	sub    $0x8,%esp
f0102061:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f0102063:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102066:	05 00 00 00 10       	add    $0x10000000,%eax
f010206b:	50                   	push   %eax
f010206c:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102071:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102076:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102079:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f010207f:	e8 ad f0 ff ff       	call   f0101131 <boot_map_region>
	boot_map_region(kern_pgdir, (intptr_t)KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f0102084:	83 c4 08             	add    $0x8,%esp
f0102087:	6a 03                	push   $0x3
f0102089:	6a 00                	push   $0x0
f010208b:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102090:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102095:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f010209b:	e8 91 f0 ff ff       	call   f0101131 <boot_map_region>
	pgdir = kern_pgdir;
f01020a0:	89 f9                	mov    %edi,%ecx
f01020a2:	8b bf d4 1a 00 00    	mov    0x1ad4(%edi),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01020a8:	8b 81 d8 1a 00 00    	mov    0x1ad8(%ecx),%eax
f01020ae:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01020b1:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01020b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01020bd:	89 c2                	mov    %eax,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01020bf:	8b 81 d0 1a 00 00    	mov    0x1ad0(%ecx),%eax
f01020c5:	89 45 bc             	mov    %eax,-0x44(%ebp)
f01020c8:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f01020ce:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01020d1:	83 c4 10             	add    $0x10,%esp
f01020d4:	89 f3                	mov    %esi,%ebx
f01020d6:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01020d9:	89 c7                	mov    %eax,%edi
f01020db:	89 75 c0             	mov    %esi,-0x40(%ebp)
f01020de:	89 d6                	mov    %edx,%esi
f01020e0:	39 de                	cmp    %ebx,%esi
f01020e2:	0f 86 82 08 00 00    	jbe    f010296a <mem_init+0x16cd>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01020e8:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01020ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01020f1:	e8 34 e9 ff ff       	call   f0100a2a <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01020f6:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01020fc:	0f 86 28 08 00 00    	jbe    f010292a <mem_init+0x168d>
f0102102:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102105:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102108:	39 c2                	cmp    %eax,%edx
f010210a:	0f 85 38 08 00 00    	jne    f0102948 <mem_init+0x16ab>
	for (i = 0; i < n; i += PGSIZE)
f0102110:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102116:	eb c8                	jmp    f01020e0 <mem_init+0xe43>
	assert(nfree == 0);
f0102118:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010211b:	8d 83 0c 7f f8 ff    	lea    -0x780f4(%ebx),%eax
f0102121:	50                   	push   %eax
f0102122:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102128:	50                   	push   %eax
f0102129:	68 fc 02 00 00       	push   $0x2fc
f010212e:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102134:	50                   	push   %eax
f0102135:	e8 77 df ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f010213a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010213d:	8d 83 1a 7e f8 ff    	lea    -0x781e6(%ebx),%eax
f0102143:	50                   	push   %eax
f0102144:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010214a:	50                   	push   %eax
f010214b:	68 5a 03 00 00       	push   $0x35a
f0102150:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102156:	50                   	push   %eax
f0102157:	e8 55 df ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f010215c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010215f:	8d 83 30 7e f8 ff    	lea    -0x781d0(%ebx),%eax
f0102165:	50                   	push   %eax
f0102166:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010216c:	50                   	push   %eax
f010216d:	68 5b 03 00 00       	push   $0x35b
f0102172:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102178:	50                   	push   %eax
f0102179:	e8 33 df ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f010217e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102181:	8d 83 46 7e f8 ff    	lea    -0x781ba(%ebx),%eax
f0102187:	50                   	push   %eax
f0102188:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010218e:	50                   	push   %eax
f010218f:	68 5c 03 00 00       	push   $0x35c
f0102194:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010219a:	50                   	push   %eax
f010219b:	e8 11 df ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01021a0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021a3:	8d 83 5c 7e f8 ff    	lea    -0x781a4(%ebx),%eax
f01021a9:	50                   	push   %eax
f01021aa:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01021b0:	50                   	push   %eax
f01021b1:	68 5f 03 00 00       	push   $0x35f
f01021b6:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01021bc:	50                   	push   %eax
f01021bd:	e8 ef de ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01021c2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021c5:	8d 83 2c 77 f8 ff    	lea    -0x788d4(%ebx),%eax
f01021cb:	50                   	push   %eax
f01021cc:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01021d2:	50                   	push   %eax
f01021d3:	68 60 03 00 00       	push   $0x360
f01021d8:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01021de:	50                   	push   %eax
f01021df:	e8 cd de ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01021e4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021e7:	8d 83 c5 7e f8 ff    	lea    -0x7813b(%ebx),%eax
f01021ed:	50                   	push   %eax
f01021ee:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01021f4:	50                   	push   %eax
f01021f5:	68 67 03 00 00       	push   $0x367
f01021fa:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102200:	50                   	push   %eax
f0102201:	e8 ab de ff ff       	call   f01000b1 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102206:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102209:	8d 83 6c 77 f8 ff    	lea    -0x78894(%ebx),%eax
f010220f:	50                   	push   %eax
f0102210:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102216:	50                   	push   %eax
f0102217:	68 6a 03 00 00       	push   $0x36a
f010221c:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102222:	50                   	push   %eax
f0102223:	e8 89 de ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102228:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010222b:	8d 83 a4 77 f8 ff    	lea    -0x7885c(%ebx),%eax
f0102231:	50                   	push   %eax
f0102232:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102238:	50                   	push   %eax
f0102239:	68 6d 03 00 00       	push   $0x36d
f010223e:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102244:	50                   	push   %eax
f0102245:	e8 67 de ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010224a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010224d:	8d 83 d4 77 f8 ff    	lea    -0x7882c(%ebx),%eax
f0102253:	50                   	push   %eax
f0102254:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010225a:	50                   	push   %eax
f010225b:	68 71 03 00 00       	push   $0x371
f0102260:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102266:	50                   	push   %eax
f0102267:	e8 45 de ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010226c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010226f:	8d 83 04 78 f8 ff    	lea    -0x787fc(%ebx),%eax
f0102275:	50                   	push   %eax
f0102276:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010227c:	50                   	push   %eax
f010227d:	68 72 03 00 00       	push   $0x372
f0102282:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102288:	50                   	push   %eax
f0102289:	e8 23 de ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010228e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102291:	8d 83 2c 78 f8 ff    	lea    -0x787d4(%ebx),%eax
f0102297:	50                   	push   %eax
f0102298:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010229e:	50                   	push   %eax
f010229f:	68 73 03 00 00       	push   $0x373
f01022a4:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01022aa:	50                   	push   %eax
f01022ab:	e8 01 de ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f01022b0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022b3:	8d 83 17 7f f8 ff    	lea    -0x780e9(%ebx),%eax
f01022b9:	50                   	push   %eax
f01022ba:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01022c0:	50                   	push   %eax
f01022c1:	68 74 03 00 00       	push   $0x374
f01022c6:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01022cc:	50                   	push   %eax
f01022cd:	e8 df dd ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f01022d2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022d5:	8d 83 28 7f f8 ff    	lea    -0x780d8(%ebx),%eax
f01022db:	50                   	push   %eax
f01022dc:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01022e2:	50                   	push   %eax
f01022e3:	68 75 03 00 00       	push   $0x375
f01022e8:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01022ee:	50                   	push   %eax
f01022ef:	e8 bd dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022f4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022f7:	8d 83 5c 78 f8 ff    	lea    -0x787a4(%ebx),%eax
f01022fd:	50                   	push   %eax
f01022fe:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102304:	50                   	push   %eax
f0102305:	68 78 03 00 00       	push   $0x378
f010230a:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102310:	50                   	push   %eax
f0102311:	e8 9b dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102316:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102319:	8d 83 98 78 f8 ff    	lea    -0x78768(%ebx),%eax
f010231f:	50                   	push   %eax
f0102320:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102326:	50                   	push   %eax
f0102327:	68 79 03 00 00       	push   $0x379
f010232c:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102332:	50                   	push   %eax
f0102333:	e8 79 dd ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102338:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010233b:	8d 83 39 7f f8 ff    	lea    -0x780c7(%ebx),%eax
f0102341:	50                   	push   %eax
f0102342:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102348:	50                   	push   %eax
f0102349:	68 7a 03 00 00       	push   $0x37a
f010234e:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102354:	50                   	push   %eax
f0102355:	e8 57 dd ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010235a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010235d:	8d 83 c5 7e f8 ff    	lea    -0x7813b(%ebx),%eax
f0102363:	50                   	push   %eax
f0102364:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010236a:	50                   	push   %eax
f010236b:	68 7d 03 00 00       	push   $0x37d
f0102370:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102376:	50                   	push   %eax
f0102377:	e8 35 dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010237c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010237f:	8d 83 5c 78 f8 ff    	lea    -0x787a4(%ebx),%eax
f0102385:	50                   	push   %eax
f0102386:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010238c:	50                   	push   %eax
f010238d:	68 80 03 00 00       	push   $0x380
f0102392:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102398:	50                   	push   %eax
f0102399:	e8 13 dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010239e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023a1:	8d 83 98 78 f8 ff    	lea    -0x78768(%ebx),%eax
f01023a7:	50                   	push   %eax
f01023a8:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01023ae:	50                   	push   %eax
f01023af:	68 81 03 00 00       	push   $0x381
f01023b4:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01023ba:	50                   	push   %eax
f01023bb:	e8 f1 dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01023c0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023c3:	8d 83 39 7f f8 ff    	lea    -0x780c7(%ebx),%eax
f01023c9:	50                   	push   %eax
f01023ca:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01023d0:	50                   	push   %eax
f01023d1:	68 82 03 00 00       	push   $0x382
f01023d6:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01023dc:	50                   	push   %eax
f01023dd:	e8 cf dc ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01023e2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023e5:	8d 83 c5 7e f8 ff    	lea    -0x7813b(%ebx),%eax
f01023eb:	50                   	push   %eax
f01023ec:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01023f2:	50                   	push   %eax
f01023f3:	68 86 03 00 00       	push   $0x386
f01023f8:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01023fe:	50                   	push   %eax
f01023ff:	e8 ad dc ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102404:	53                   	push   %ebx
f0102405:	89 cb                	mov    %ecx,%ebx
f0102407:	8d 81 7c 75 f8 ff    	lea    -0x78a84(%ecx),%eax
f010240d:	50                   	push   %eax
f010240e:	68 89 03 00 00       	push   $0x389
f0102413:	8d 81 49 7d f8 ff    	lea    -0x782b7(%ecx),%eax
f0102419:	50                   	push   %eax
f010241a:	e8 92 dc ff ff       	call   f01000b1 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010241f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102422:	8d 83 c8 78 f8 ff    	lea    -0x78738(%ebx),%eax
f0102428:	50                   	push   %eax
f0102429:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010242f:	50                   	push   %eax
f0102430:	68 8a 03 00 00       	push   $0x38a
f0102435:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010243b:	50                   	push   %eax
f010243c:	e8 70 dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102441:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102444:	8d 83 08 79 f8 ff    	lea    -0x786f8(%ebx),%eax
f010244a:	50                   	push   %eax
f010244b:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102451:	50                   	push   %eax
f0102452:	68 8d 03 00 00       	push   $0x38d
f0102457:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010245d:	50                   	push   %eax
f010245e:	e8 4e dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102463:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102466:	8d 83 98 78 f8 ff    	lea    -0x78768(%ebx),%eax
f010246c:	50                   	push   %eax
f010246d:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102473:	50                   	push   %eax
f0102474:	68 8e 03 00 00       	push   $0x38e
f0102479:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010247f:	50                   	push   %eax
f0102480:	e8 2c dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102485:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102488:	8d 83 39 7f f8 ff    	lea    -0x780c7(%ebx),%eax
f010248e:	50                   	push   %eax
f010248f:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102495:	50                   	push   %eax
f0102496:	68 8f 03 00 00       	push   $0x38f
f010249b:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01024a1:	50                   	push   %eax
f01024a2:	e8 0a dc ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024aa:	8d 83 48 79 f8 ff    	lea    -0x786b8(%ebx),%eax
f01024b0:	50                   	push   %eax
f01024b1:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01024b7:	50                   	push   %eax
f01024b8:	68 90 03 00 00       	push   $0x390
f01024bd:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01024c3:	50                   	push   %eax
f01024c4:	e8 e8 db ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024c9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024cc:	8d 83 4a 7f f8 ff    	lea    -0x780b6(%ebx),%eax
f01024d2:	50                   	push   %eax
f01024d3:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01024d9:	50                   	push   %eax
f01024da:	68 91 03 00 00       	push   $0x391
f01024df:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01024e5:	50                   	push   %eax
f01024e6:	e8 c6 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024eb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024ee:	8d 83 5c 78 f8 ff    	lea    -0x787a4(%ebx),%eax
f01024f4:	50                   	push   %eax
f01024f5:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01024fb:	50                   	push   %eax
f01024fc:	68 94 03 00 00       	push   $0x394
f0102501:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102507:	50                   	push   %eax
f0102508:	e8 a4 db ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010250d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102510:	8d 83 7c 79 f8 ff    	lea    -0x78684(%ebx),%eax
f0102516:	50                   	push   %eax
f0102517:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010251d:	50                   	push   %eax
f010251e:	68 95 03 00 00       	push   $0x395
f0102523:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102529:	50                   	push   %eax
f010252a:	e8 82 db ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010252f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102532:	8d 83 b0 79 f8 ff    	lea    -0x78650(%ebx),%eax
f0102538:	50                   	push   %eax
f0102539:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010253f:	50                   	push   %eax
f0102540:	68 96 03 00 00       	push   $0x396
f0102545:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010254b:	50                   	push   %eax
f010254c:	e8 60 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102551:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102554:	8d 83 e8 79 f8 ff    	lea    -0x78618(%ebx),%eax
f010255a:	50                   	push   %eax
f010255b:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102561:	50                   	push   %eax
f0102562:	68 99 03 00 00       	push   $0x399
f0102567:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010256d:	50                   	push   %eax
f010256e:	e8 3e db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102573:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102576:	8d 83 20 7a f8 ff    	lea    -0x785e0(%ebx),%eax
f010257c:	50                   	push   %eax
f010257d:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102583:	50                   	push   %eax
f0102584:	68 9c 03 00 00       	push   $0x39c
f0102589:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010258f:	50                   	push   %eax
f0102590:	e8 1c db ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102595:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102598:	8d 83 b0 79 f8 ff    	lea    -0x78650(%ebx),%eax
f010259e:	50                   	push   %eax
f010259f:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01025a5:	50                   	push   %eax
f01025a6:	68 9d 03 00 00       	push   $0x39d
f01025ab:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01025b1:	50                   	push   %eax
f01025b2:	e8 fa da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01025b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025ba:	8d 83 5c 7a f8 ff    	lea    -0x785a4(%ebx),%eax
f01025c0:	50                   	push   %eax
f01025c1:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01025c7:	50                   	push   %eax
f01025c8:	68 a0 03 00 00       	push   $0x3a0
f01025cd:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01025d3:	50                   	push   %eax
f01025d4:	e8 d8 da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025d9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025dc:	8d 83 88 7a f8 ff    	lea    -0x78578(%ebx),%eax
f01025e2:	50                   	push   %eax
f01025e3:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01025e9:	50                   	push   %eax
f01025ea:	68 a1 03 00 00       	push   $0x3a1
f01025ef:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01025f5:	50                   	push   %eax
f01025f6:	e8 b6 da ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 2);
f01025fb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025fe:	8d 83 60 7f f8 ff    	lea    -0x780a0(%ebx),%eax
f0102604:	50                   	push   %eax
f0102605:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010260b:	50                   	push   %eax
f010260c:	68 a3 03 00 00       	push   $0x3a3
f0102611:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102617:	50                   	push   %eax
f0102618:	e8 94 da ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f010261d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102620:	8d 83 71 7f f8 ff    	lea    -0x7808f(%ebx),%eax
f0102626:	50                   	push   %eax
f0102627:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010262d:	50                   	push   %eax
f010262e:	68 a4 03 00 00       	push   $0x3a4
f0102633:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102639:	50                   	push   %eax
f010263a:	e8 72 da ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010263f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102642:	8d 83 b8 7a f8 ff    	lea    -0x78548(%ebx),%eax
f0102648:	50                   	push   %eax
f0102649:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010264f:	50                   	push   %eax
f0102650:	68 a7 03 00 00       	push   $0x3a7
f0102655:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010265b:	50                   	push   %eax
f010265c:	e8 50 da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102661:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102664:	8d 83 dc 7a f8 ff    	lea    -0x78524(%ebx),%eax
f010266a:	50                   	push   %eax
f010266b:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102671:	50                   	push   %eax
f0102672:	68 ab 03 00 00       	push   $0x3ab
f0102677:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010267d:	50                   	push   %eax
f010267e:	e8 2e da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102683:	89 cb                	mov    %ecx,%ebx
f0102685:	8d 81 88 7a f8 ff    	lea    -0x78578(%ecx),%eax
f010268b:	50                   	push   %eax
f010268c:	8d 81 6f 7d f8 ff    	lea    -0x78291(%ecx),%eax
f0102692:	50                   	push   %eax
f0102693:	68 ac 03 00 00       	push   $0x3ac
f0102698:	8d 81 49 7d f8 ff    	lea    -0x782b7(%ecx),%eax
f010269e:	50                   	push   %eax
f010269f:	e8 0d da ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f01026a4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026a7:	8d 83 17 7f f8 ff    	lea    -0x780e9(%ebx),%eax
f01026ad:	50                   	push   %eax
f01026ae:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01026b4:	50                   	push   %eax
f01026b5:	68 ad 03 00 00       	push   $0x3ad
f01026ba:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01026c0:	50                   	push   %eax
f01026c1:	e8 eb d9 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01026c6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026c9:	8d 83 71 7f f8 ff    	lea    -0x7808f(%ebx),%eax
f01026cf:	50                   	push   %eax
f01026d0:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01026d6:	50                   	push   %eax
f01026d7:	68 ae 03 00 00       	push   $0x3ae
f01026dc:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01026e2:	50                   	push   %eax
f01026e3:	e8 c9 d9 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01026e8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026eb:	8d 83 00 7b f8 ff    	lea    -0x78500(%ebx),%eax
f01026f1:	50                   	push   %eax
f01026f2:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01026f8:	50                   	push   %eax
f01026f9:	68 b1 03 00 00       	push   $0x3b1
f01026fe:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102704:	50                   	push   %eax
f0102705:	e8 a7 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f010270a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010270d:	8d 83 82 7f f8 ff    	lea    -0x7807e(%ebx),%eax
f0102713:	50                   	push   %eax
f0102714:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010271a:	50                   	push   %eax
f010271b:	68 b2 03 00 00       	push   $0x3b2
f0102720:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102726:	50                   	push   %eax
f0102727:	e8 85 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f010272c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010272f:	8d 83 8e 7f f8 ff    	lea    -0x78072(%ebx),%eax
f0102735:	50                   	push   %eax
f0102736:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010273c:	50                   	push   %eax
f010273d:	68 b3 03 00 00       	push   $0x3b3
f0102742:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102748:	50                   	push   %eax
f0102749:	e8 63 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010274e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102751:	8d 83 dc 7a f8 ff    	lea    -0x78524(%ebx),%eax
f0102757:	50                   	push   %eax
f0102758:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010275e:	50                   	push   %eax
f010275f:	68 b7 03 00 00       	push   $0x3b7
f0102764:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010276a:	50                   	push   %eax
f010276b:	e8 41 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102770:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102773:	8d 83 38 7b f8 ff    	lea    -0x784c8(%ebx),%eax
f0102779:	50                   	push   %eax
f010277a:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102780:	50                   	push   %eax
f0102781:	68 b8 03 00 00       	push   $0x3b8
f0102786:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f010278c:	50                   	push   %eax
f010278d:	e8 1f d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102792:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102795:	8d 83 a3 7f f8 ff    	lea    -0x7805d(%ebx),%eax
f010279b:	50                   	push   %eax
f010279c:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01027a2:	50                   	push   %eax
f01027a3:	68 b9 03 00 00       	push   $0x3b9
f01027a8:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01027ae:	50                   	push   %eax
f01027af:	e8 fd d8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01027b4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027b7:	8d 83 71 7f f8 ff    	lea    -0x7808f(%ebx),%eax
f01027bd:	50                   	push   %eax
f01027be:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01027c4:	50                   	push   %eax
f01027c5:	68 ba 03 00 00       	push   $0x3ba
f01027ca:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01027d0:	50                   	push   %eax
f01027d1:	e8 db d8 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01027d6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027d9:	8d 83 60 7b f8 ff    	lea    -0x784a0(%ebx),%eax
f01027df:	50                   	push   %eax
f01027e0:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01027e6:	50                   	push   %eax
f01027e7:	68 bd 03 00 00       	push   $0x3bd
f01027ec:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01027f2:	50                   	push   %eax
f01027f3:	e8 b9 d8 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01027f8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027fb:	8d 83 c5 7e f8 ff    	lea    -0x7813b(%ebx),%eax
f0102801:	50                   	push   %eax
f0102802:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102808:	50                   	push   %eax
f0102809:	68 c0 03 00 00       	push   $0x3c0
f010280e:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102814:	50                   	push   %eax
f0102815:	e8 97 d8 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010281a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010281d:	8d 83 04 78 f8 ff    	lea    -0x787fc(%ebx),%eax
f0102823:	50                   	push   %eax
f0102824:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010282a:	50                   	push   %eax
f010282b:	68 c3 03 00 00       	push   $0x3c3
f0102830:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102836:	50                   	push   %eax
f0102837:	e8 75 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f010283c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010283f:	8d 83 28 7f f8 ff    	lea    -0x780d8(%ebx),%eax
f0102845:	50                   	push   %eax
f0102846:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010284c:	50                   	push   %eax
f010284d:	68 c5 03 00 00       	push   $0x3c5
f0102852:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102858:	50                   	push   %eax
f0102859:	e8 53 d8 ff ff       	call   f01000b1 <_panic>
f010285e:	52                   	push   %edx
f010285f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102862:	8d 83 7c 75 f8 ff    	lea    -0x78a84(%ebx),%eax
f0102868:	50                   	push   %eax
f0102869:	68 cc 03 00 00       	push   $0x3cc
f010286e:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102874:	50                   	push   %eax
f0102875:	e8 37 d8 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010287a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010287d:	8d 83 b4 7f f8 ff    	lea    -0x7804c(%ebx),%eax
f0102883:	50                   	push   %eax
f0102884:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010288a:	50                   	push   %eax
f010288b:	68 cd 03 00 00       	push   $0x3cd
f0102890:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102896:	50                   	push   %eax
f0102897:	e8 15 d8 ff ff       	call   f01000b1 <_panic>
f010289c:	52                   	push   %edx
f010289d:	8d 83 7c 75 f8 ff    	lea    -0x78a84(%ebx),%eax
f01028a3:	50                   	push   %eax
f01028a4:	6a 56                	push   $0x56
f01028a6:	8d 83 55 7d f8 ff    	lea    -0x782ab(%ebx),%eax
f01028ac:	50                   	push   %eax
f01028ad:	e8 ff d7 ff ff       	call   f01000b1 <_panic>
f01028b2:	52                   	push   %edx
f01028b3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028b6:	8d 83 7c 75 f8 ff    	lea    -0x78a84(%ebx),%eax
f01028bc:	50                   	push   %eax
f01028bd:	6a 56                	push   $0x56
f01028bf:	8d 83 55 7d f8 ff    	lea    -0x782ab(%ebx),%eax
f01028c5:	50                   	push   %eax
f01028c6:	e8 e6 d7 ff ff       	call   f01000b1 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f01028cb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028ce:	8d 83 cc 7f f8 ff    	lea    -0x78034(%ebx),%eax
f01028d4:	50                   	push   %eax
f01028d5:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f01028db:	50                   	push   %eax
f01028dc:	68 d7 03 00 00       	push   $0x3d7
f01028e1:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01028e7:	50                   	push   %eax
f01028e8:	e8 c4 d7 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028ed:	50                   	push   %eax
f01028ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028f1:	8d 83 88 76 f8 ff    	lea    -0x78978(%ebx),%eax
f01028f7:	50                   	push   %eax
f01028f8:	68 b9 00 00 00       	push   $0xb9
f01028fd:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102903:	50                   	push   %eax
f0102904:	e8 a8 d7 ff ff       	call   f01000b1 <_panic>
f0102909:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010290c:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f0102912:	8d 83 88 76 f8 ff    	lea    -0x78978(%ebx),%eax
f0102918:	50                   	push   %eax
f0102919:	68 cf 00 00 00       	push   $0xcf
f010291e:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102924:	50                   	push   %eax
f0102925:	e8 87 d7 ff ff       	call   f01000b1 <_panic>
f010292a:	ff 75 bc             	push   -0x44(%ebp)
f010292d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102930:	8d 83 88 76 f8 ff    	lea    -0x78978(%ebx),%eax
f0102936:	50                   	push   %eax
f0102937:	68 14 03 00 00       	push   $0x314
f010293c:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102942:	50                   	push   %eax
f0102943:	e8 69 d7 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102948:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010294b:	8d 83 84 7b f8 ff    	lea    -0x7847c(%ebx),%eax
f0102951:	50                   	push   %eax
f0102952:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102958:	50                   	push   %eax
f0102959:	68 14 03 00 00       	push   $0x314
f010295e:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102964:	50                   	push   %eax
f0102965:	e8 47 d7 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010296a:	8b 7d d0             	mov    -0x30(%ebp),%edi
f010296d:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0102970:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102973:	c7 c0 54 f3 17 f0    	mov    $0xf017f354,%eax
f0102979:	8b 00                	mov    (%eax),%eax
f010297b:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f010297e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102983:	8d 88 00 00 40 21    	lea    0x21400000(%eax),%ecx
f0102989:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010298c:	89 75 cc             	mov    %esi,-0x34(%ebp)
f010298f:	89 c6                	mov    %eax,%esi
f0102991:	89 da                	mov    %ebx,%edx
f0102993:	89 f8                	mov    %edi,%eax
f0102995:	e8 90 e0 ff ff       	call   f0100a2a <check_va2pa>
f010299a:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01029a0:	76 45                	jbe    f01029e7 <mem_init+0x174a>
f01029a2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01029a5:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f01029a8:	39 c2                	cmp    %eax,%edx
f01029aa:	75 59                	jne    f0102a05 <mem_init+0x1768>
	for (i = 0; i < n; i += PGSIZE)
f01029ac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029b2:	81 fb 00 80 c1 ee    	cmp    $0xeec18000,%ebx
f01029b8:	75 d7                	jne    f0102991 <mem_init+0x16f4>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029ba:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01029bd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01029c0:	c1 e0 0c             	shl    $0xc,%eax
f01029c3:	89 f3                	mov    %esi,%ebx
f01029c5:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01029c8:	89 c6                	mov    %eax,%esi
f01029ca:	39 f3                	cmp    %esi,%ebx
f01029cc:	73 7b                	jae    f0102a49 <mem_init+0x17ac>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029ce:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01029d4:	89 f8                	mov    %edi,%eax
f01029d6:	e8 4f e0 ff ff       	call   f0100a2a <check_va2pa>
f01029db:	39 c3                	cmp    %eax,%ebx
f01029dd:	75 48                	jne    f0102a27 <mem_init+0x178a>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029e5:	eb e3                	jmp    f01029ca <mem_init+0x172d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029e7:	ff 75 c0             	push   -0x40(%ebp)
f01029ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029ed:	8d 83 88 76 f8 ff    	lea    -0x78978(%ebx),%eax
f01029f3:	50                   	push   %eax
f01029f4:	68 19 03 00 00       	push   $0x319
f01029f9:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f01029ff:	50                   	push   %eax
f0102a00:	e8 ac d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102a05:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a08:	8d 83 b8 7b f8 ff    	lea    -0x78448(%ebx),%eax
f0102a0e:	50                   	push   %eax
f0102a0f:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102a15:	50                   	push   %eax
f0102a16:	68 19 03 00 00       	push   $0x319
f0102a1b:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102a21:	50                   	push   %eax
f0102a22:	e8 8a d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a27:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a2a:	8d 83 ec 7b f8 ff    	lea    -0x78414(%ebx),%eax
f0102a30:	50                   	push   %eax
f0102a31:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102a37:	50                   	push   %eax
f0102a38:	68 1d 03 00 00       	push   $0x31d
f0102a3d:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102a43:	50                   	push   %eax
f0102a44:	e8 68 d6 ff ff       	call   f01000b1 <_panic>
f0102a49:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a4e:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102a51:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a56:	89 c6                	mov    %eax,%esi
f0102a58:	89 da                	mov    %ebx,%edx
f0102a5a:	89 f8                	mov    %edi,%eax
f0102a5c:	e8 c9 df ff ff       	call   f0100a2a <check_va2pa>
f0102a61:	89 c2                	mov    %eax,%edx
f0102a63:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0102a66:	39 c2                	cmp    %eax,%edx
f0102a68:	75 44                	jne    f0102aae <mem_init+0x1811>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a6a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a70:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102a76:	75 e0                	jne    f0102a58 <mem_init+0x17bb>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a78:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102a7b:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a80:	89 f8                	mov    %edi,%eax
f0102a82:	e8 a3 df ff ff       	call   f0100a2a <check_va2pa>
f0102a87:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a8a:	74 71                	je     f0102afd <mem_init+0x1860>
f0102a8c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a8f:	8d 83 5c 7c f8 ff    	lea    -0x783a4(%ebx),%eax
f0102a95:	50                   	push   %eax
f0102a96:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102a9c:	50                   	push   %eax
f0102a9d:	68 22 03 00 00       	push   $0x322
f0102aa2:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102aa8:	50                   	push   %eax
f0102aa9:	e8 03 d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102aae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ab1:	8d 83 14 7c f8 ff    	lea    -0x783ec(%ebx),%eax
f0102ab7:	50                   	push   %eax
f0102ab8:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102abe:	50                   	push   %eax
f0102abf:	68 21 03 00 00       	push   $0x321
f0102ac4:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102aca:	50                   	push   %eax
f0102acb:	e8 e1 d5 ff ff       	call   f01000b1 <_panic>
		switch (i) {
f0102ad0:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102ad6:	75 25                	jne    f0102afd <mem_init+0x1860>
			assert(pgdir[i] & PTE_P);
f0102ad8:	f6 04 b7 01          	testb  $0x1,(%edi,%esi,4)
f0102adc:	74 4f                	je     f0102b2d <mem_init+0x1890>
	for (i = 0; i < NPDENTRIES; i++) {
f0102ade:	83 c6 01             	add    $0x1,%esi
f0102ae1:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f0102ae7:	0f 87 b1 00 00 00    	ja     f0102b9e <mem_init+0x1901>
		switch (i) {
f0102aed:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f0102af3:	77 db                	ja     f0102ad0 <mem_init+0x1833>
f0102af5:	81 fe ba 03 00 00    	cmp    $0x3ba,%esi
f0102afb:	77 db                	ja     f0102ad8 <mem_init+0x183b>
			if (i >= PDX(KERNBASE)) {
f0102afd:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102b03:	77 4a                	ja     f0102b4f <mem_init+0x18b2>
				assert(pgdir[i] == 0);
f0102b05:	83 3c b7 00          	cmpl   $0x0,(%edi,%esi,4)
f0102b09:	74 d3                	je     f0102ade <mem_init+0x1841>
f0102b0b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b0e:	8d 83 1e 80 f8 ff    	lea    -0x77fe2(%ebx),%eax
f0102b14:	50                   	push   %eax
f0102b15:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102b1b:	50                   	push   %eax
f0102b1c:	68 32 03 00 00       	push   $0x332
f0102b21:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102b27:	50                   	push   %eax
f0102b28:	e8 84 d5 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102b2d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b30:	8d 83 fc 7f f8 ff    	lea    -0x78004(%ebx),%eax
f0102b36:	50                   	push   %eax
f0102b37:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102b3d:	50                   	push   %eax
f0102b3e:	68 2b 03 00 00       	push   $0x32b
f0102b43:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102b49:	50                   	push   %eax
f0102b4a:	e8 62 d5 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b4f:	8b 04 b7             	mov    (%edi,%esi,4),%eax
f0102b52:	a8 01                	test   $0x1,%al
f0102b54:	74 26                	je     f0102b7c <mem_init+0x18df>
				assert(pgdir[i] & PTE_W);
f0102b56:	a8 02                	test   $0x2,%al
f0102b58:	75 84                	jne    f0102ade <mem_init+0x1841>
f0102b5a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b5d:	8d 83 0d 80 f8 ff    	lea    -0x77ff3(%ebx),%eax
f0102b63:	50                   	push   %eax
f0102b64:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102b6a:	50                   	push   %eax
f0102b6b:	68 30 03 00 00       	push   $0x330
f0102b70:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102b76:	50                   	push   %eax
f0102b77:	e8 35 d5 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b7c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b7f:	8d 83 fc 7f f8 ff    	lea    -0x78004(%ebx),%eax
f0102b85:	50                   	push   %eax
f0102b86:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102b8c:	50                   	push   %eax
f0102b8d:	68 2f 03 00 00       	push   $0x32f
f0102b92:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102b98:	50                   	push   %eax
f0102b99:	e8 13 d5 ff ff       	call   f01000b1 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b9e:	83 ec 0c             	sub    $0xc,%esp
f0102ba1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ba4:	8d 83 8c 7c f8 ff    	lea    -0x78374(%ebx),%eax
f0102baa:	50                   	push   %eax
f0102bab:	e8 8f 09 00 00       	call   f010353f <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102bb0:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102bb6:	83 c4 10             	add    $0x10,%esp
f0102bb9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bbe:	0f 86 2c 02 00 00    	jbe    f0102df0 <mem_init+0x1b53>
	return (physaddr_t)kva - KERNBASE;
f0102bc4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102bc9:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102bcc:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bd1:	e8 d0 de ff ff       	call   f0100aa6 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102bd6:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102bd9:	83 e0 f3             	and    $0xfffffff3,%eax
f0102bdc:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102be1:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102be4:	83 ec 0c             	sub    $0xc,%esp
f0102be7:	6a 00                	push   $0x0
f0102be9:	e8 4c e3 ff ff       	call   f0100f3a <page_alloc>
f0102bee:	89 c6                	mov    %eax,%esi
f0102bf0:	83 c4 10             	add    $0x10,%esp
f0102bf3:	85 c0                	test   %eax,%eax
f0102bf5:	0f 84 11 02 00 00    	je     f0102e0c <mem_init+0x1b6f>
	assert((pp1 = page_alloc(0)));
f0102bfb:	83 ec 0c             	sub    $0xc,%esp
f0102bfe:	6a 00                	push   $0x0
f0102c00:	e8 35 e3 ff ff       	call   f0100f3a <page_alloc>
f0102c05:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102c08:	83 c4 10             	add    $0x10,%esp
f0102c0b:	85 c0                	test   %eax,%eax
f0102c0d:	0f 84 1b 02 00 00    	je     f0102e2e <mem_init+0x1b91>
	assert((pp2 = page_alloc(0)));
f0102c13:	83 ec 0c             	sub    $0xc,%esp
f0102c16:	6a 00                	push   $0x0
f0102c18:	e8 1d e3 ff ff       	call   f0100f3a <page_alloc>
f0102c1d:	89 c7                	mov    %eax,%edi
f0102c1f:	83 c4 10             	add    $0x10,%esp
f0102c22:	85 c0                	test   %eax,%eax
f0102c24:	0f 84 26 02 00 00    	je     f0102e50 <mem_init+0x1bb3>
	page_free(pp0);
f0102c2a:	83 ec 0c             	sub    $0xc,%esp
f0102c2d:	56                   	push   %esi
f0102c2e:	e8 8c e3 ff ff       	call   f0100fbf <page_free>
	return (pp - pages) << PGSHIFT;
f0102c33:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102c36:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c39:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0102c3f:	c1 f8 03             	sar    $0x3,%eax
f0102c42:	89 c2                	mov    %eax,%edx
f0102c44:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c47:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c4c:	83 c4 10             	add    $0x10,%esp
f0102c4f:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0102c55:	0f 83 17 02 00 00    	jae    f0102e72 <mem_init+0x1bd5>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c5b:	83 ec 04             	sub    $0x4,%esp
f0102c5e:	68 00 10 00 00       	push   $0x1000
f0102c63:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c65:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c6b:	52                   	push   %edx
f0102c6c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c6f:	e8 c8 18 00 00       	call   f010453c <memset>
	return (pp - pages) << PGSHIFT;
f0102c74:	89 f8                	mov    %edi,%eax
f0102c76:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0102c7c:	c1 f8 03             	sar    $0x3,%eax
f0102c7f:	89 c2                	mov    %eax,%edx
f0102c81:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c84:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c89:	83 c4 10             	add    $0x10,%esp
f0102c8c:	3b 83 d8 1a 00 00    	cmp    0x1ad8(%ebx),%eax
f0102c92:	0f 83 f2 01 00 00    	jae    f0102e8a <mem_init+0x1bed>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c98:	83 ec 04             	sub    $0x4,%esp
f0102c9b:	68 00 10 00 00       	push   $0x1000
f0102ca0:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102ca2:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102ca8:	52                   	push   %edx
f0102ca9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cac:	e8 8b 18 00 00       	call   f010453c <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102cb1:	6a 02                	push   $0x2
f0102cb3:	68 00 10 00 00       	push   $0x1000
f0102cb8:	ff 75 d0             	push   -0x30(%ebp)
f0102cbb:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0102cc1:	e8 5f e5 ff ff       	call   f0101225 <page_insert>
	assert(pp1->pp_ref == 1);
f0102cc6:	83 c4 20             	add    $0x20,%esp
f0102cc9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102ccc:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102cd1:	0f 85 cc 01 00 00    	jne    f0102ea3 <mem_init+0x1c06>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cd7:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cde:	01 01 01 
f0102ce1:	0f 85 de 01 00 00    	jne    f0102ec5 <mem_init+0x1c28>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ce7:	6a 02                	push   $0x2
f0102ce9:	68 00 10 00 00       	push   $0x1000
f0102cee:	57                   	push   %edi
f0102cef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cf2:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0102cf8:	e8 28 e5 ff ff       	call   f0101225 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102cfd:	83 c4 10             	add    $0x10,%esp
f0102d00:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d07:	02 02 02 
f0102d0a:	0f 85 d7 01 00 00    	jne    f0102ee7 <mem_init+0x1c4a>
	assert(pp2->pp_ref == 1);
f0102d10:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d15:	0f 85 ee 01 00 00    	jne    f0102f09 <mem_init+0x1c6c>
	assert(pp1->pp_ref == 0);
f0102d1b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d1e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102d23:	0f 85 02 02 00 00    	jne    f0102f2b <mem_init+0x1c8e>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d29:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d30:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102d33:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102d36:	89 f8                	mov    %edi,%eax
f0102d38:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0102d3e:	c1 f8 03             	sar    $0x3,%eax
f0102d41:	89 c2                	mov    %eax,%edx
f0102d43:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d46:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d4b:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0102d51:	0f 83 f6 01 00 00    	jae    f0102f4d <mem_init+0x1cb0>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d57:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102d5e:	03 03 03 
f0102d61:	0f 85 fe 01 00 00    	jne    f0102f65 <mem_init+0x1cc8>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d67:	83 ec 08             	sub    $0x8,%esp
f0102d6a:	68 00 10 00 00       	push   $0x1000
f0102d6f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d72:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0102d78:	e8 6d e4 ff ff       	call   f01011ea <page_remove>
	assert(pp2->pp_ref == 0);
f0102d7d:	83 c4 10             	add    $0x10,%esp
f0102d80:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d85:	0f 85 fc 01 00 00    	jne    f0102f87 <mem_init+0x1cea>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d8b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d8e:	8b 88 d4 1a 00 00    	mov    0x1ad4(%eax),%ecx
f0102d94:	8b 11                	mov    (%ecx),%edx
f0102d96:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d9c:	89 f7                	mov    %esi,%edi
f0102d9e:	2b b8 d0 1a 00 00    	sub    0x1ad0(%eax),%edi
f0102da4:	89 f8                	mov    %edi,%eax
f0102da6:	c1 f8 03             	sar    $0x3,%eax
f0102da9:	c1 e0 0c             	shl    $0xc,%eax
f0102dac:	39 c2                	cmp    %eax,%edx
f0102dae:	0f 85 f5 01 00 00    	jne    f0102fa9 <mem_init+0x1d0c>
	kern_pgdir[0] = 0;
f0102db4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102dba:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102dbf:	0f 85 06 02 00 00    	jne    f0102fcb <mem_init+0x1d2e>
	pp0->pp_ref = 0;
f0102dc5:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102dcb:	83 ec 0c             	sub    $0xc,%esp
f0102dce:	56                   	push   %esi
f0102dcf:	e8 eb e1 ff ff       	call   f0100fbf <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102dd4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dd7:	8d 83 20 7d f8 ff    	lea    -0x782e0(%ebx),%eax
f0102ddd:	89 04 24             	mov    %eax,(%esp)
f0102de0:	e8 5a 07 00 00       	call   f010353f <cprintf>
}
f0102de5:	83 c4 10             	add    $0x10,%esp
f0102de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102deb:	5b                   	pop    %ebx
f0102dec:	5e                   	pop    %esi
f0102ded:	5f                   	pop    %edi
f0102dee:	5d                   	pop    %ebp
f0102def:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102df0:	50                   	push   %eax
f0102df1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102df4:	8d 83 88 76 f8 ff    	lea    -0x78978(%ebx),%eax
f0102dfa:	50                   	push   %eax
f0102dfb:	68 e5 00 00 00       	push   $0xe5
f0102e00:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102e06:	50                   	push   %eax
f0102e07:	e8 a5 d2 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102e0c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e0f:	8d 83 1a 7e f8 ff    	lea    -0x781e6(%ebx),%eax
f0102e15:	50                   	push   %eax
f0102e16:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102e1c:	50                   	push   %eax
f0102e1d:	68 f2 03 00 00       	push   $0x3f2
f0102e22:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102e28:	50                   	push   %eax
f0102e29:	e8 83 d2 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e2e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e31:	8d 83 30 7e f8 ff    	lea    -0x781d0(%ebx),%eax
f0102e37:	50                   	push   %eax
f0102e38:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102e3e:	50                   	push   %eax
f0102e3f:	68 f3 03 00 00       	push   $0x3f3
f0102e44:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102e4a:	50                   	push   %eax
f0102e4b:	e8 61 d2 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e50:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e53:	8d 83 46 7e f8 ff    	lea    -0x781ba(%ebx),%eax
f0102e59:	50                   	push   %eax
f0102e5a:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102e60:	50                   	push   %eax
f0102e61:	68 f4 03 00 00       	push   $0x3f4
f0102e66:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102e6c:	50                   	push   %eax
f0102e6d:	e8 3f d2 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e72:	52                   	push   %edx
f0102e73:	89 cb                	mov    %ecx,%ebx
f0102e75:	8d 81 7c 75 f8 ff    	lea    -0x78a84(%ecx),%eax
f0102e7b:	50                   	push   %eax
f0102e7c:	6a 56                	push   $0x56
f0102e7e:	8d 81 55 7d f8 ff    	lea    -0x782ab(%ecx),%eax
f0102e84:	50                   	push   %eax
f0102e85:	e8 27 d2 ff ff       	call   f01000b1 <_panic>
f0102e8a:	52                   	push   %edx
f0102e8b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e8e:	8d 83 7c 75 f8 ff    	lea    -0x78a84(%ebx),%eax
f0102e94:	50                   	push   %eax
f0102e95:	6a 56                	push   $0x56
f0102e97:	8d 83 55 7d f8 ff    	lea    -0x782ab(%ebx),%eax
f0102e9d:	50                   	push   %eax
f0102e9e:	e8 0e d2 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102ea3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ea6:	8d 83 17 7f f8 ff    	lea    -0x780e9(%ebx),%eax
f0102eac:	50                   	push   %eax
f0102ead:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102eb3:	50                   	push   %eax
f0102eb4:	68 f9 03 00 00       	push   $0x3f9
f0102eb9:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102ebf:	50                   	push   %eax
f0102ec0:	e8 ec d1 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ec5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ec8:	8d 83 ac 7c f8 ff    	lea    -0x78354(%ebx),%eax
f0102ece:	50                   	push   %eax
f0102ecf:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102ed5:	50                   	push   %eax
f0102ed6:	68 fa 03 00 00       	push   $0x3fa
f0102edb:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102ee1:	50                   	push   %eax
f0102ee2:	e8 ca d1 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ee7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102eea:	8d 83 d0 7c f8 ff    	lea    -0x78330(%ebx),%eax
f0102ef0:	50                   	push   %eax
f0102ef1:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102ef7:	50                   	push   %eax
f0102ef8:	68 fc 03 00 00       	push   $0x3fc
f0102efd:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102f03:	50                   	push   %eax
f0102f04:	e8 a8 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102f09:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f0c:	8d 83 39 7f f8 ff    	lea    -0x780c7(%ebx),%eax
f0102f12:	50                   	push   %eax
f0102f13:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102f19:	50                   	push   %eax
f0102f1a:	68 fd 03 00 00       	push   $0x3fd
f0102f1f:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102f25:	50                   	push   %eax
f0102f26:	e8 86 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102f2b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f2e:	8d 83 a3 7f f8 ff    	lea    -0x7805d(%ebx),%eax
f0102f34:	50                   	push   %eax
f0102f35:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102f3b:	50                   	push   %eax
f0102f3c:	68 fe 03 00 00       	push   $0x3fe
f0102f41:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102f47:	50                   	push   %eax
f0102f48:	e8 64 d1 ff ff       	call   f01000b1 <_panic>
f0102f4d:	52                   	push   %edx
f0102f4e:	89 cb                	mov    %ecx,%ebx
f0102f50:	8d 81 7c 75 f8 ff    	lea    -0x78a84(%ecx),%eax
f0102f56:	50                   	push   %eax
f0102f57:	6a 56                	push   $0x56
f0102f59:	8d 81 55 7d f8 ff    	lea    -0x782ab(%ecx),%eax
f0102f5f:	50                   	push   %eax
f0102f60:	e8 4c d1 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f65:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f68:	8d 83 f4 7c f8 ff    	lea    -0x7830c(%ebx),%eax
f0102f6e:	50                   	push   %eax
f0102f6f:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102f75:	50                   	push   %eax
f0102f76:	68 00 04 00 00       	push   $0x400
f0102f7b:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102f81:	50                   	push   %eax
f0102f82:	e8 2a d1 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102f87:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f8a:	8d 83 71 7f f8 ff    	lea    -0x7808f(%ebx),%eax
f0102f90:	50                   	push   %eax
f0102f91:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102f97:	50                   	push   %eax
f0102f98:	68 02 04 00 00       	push   $0x402
f0102f9d:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102fa3:	50                   	push   %eax
f0102fa4:	e8 08 d1 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102fa9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fac:	8d 83 04 78 f8 ff    	lea    -0x787fc(%ebx),%eax
f0102fb2:	50                   	push   %eax
f0102fb3:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102fb9:	50                   	push   %eax
f0102fba:	68 05 04 00 00       	push   $0x405
f0102fbf:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102fc5:	50                   	push   %eax
f0102fc6:	e8 e6 d0 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102fcb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fce:	8d 83 28 7f f8 ff    	lea    -0x780d8(%ebx),%eax
f0102fd4:	50                   	push   %eax
f0102fd5:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0102fdb:	50                   	push   %eax
f0102fdc:	68 07 04 00 00       	push   $0x407
f0102fe1:	8d 83 49 7d f8 ff    	lea    -0x782b7(%ebx),%eax
f0102fe7:	50                   	push   %eax
f0102fe8:	e8 c4 d0 ff ff       	call   f01000b1 <_panic>

f0102fed <tlb_invalidate>:
{
f0102fed:	55                   	push   %ebp
f0102fee:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ff3:	0f 01 38             	invlpg (%eax)
}
f0102ff6:	5d                   	pop    %ebp
f0102ff7:	c3                   	ret    

f0102ff8 <user_mem_check>:
}
f0102ff8:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ffd:	c3                   	ret    

f0102ffe <user_mem_assert>:
}
f0102ffe:	c3                   	ret    

f0102fff <__x86.get_pc_thunk.dx>:
f0102fff:	8b 14 24             	mov    (%esp),%edx
f0103002:	c3                   	ret    

f0103003 <__x86.get_pc_thunk.cx>:
f0103003:	8b 0c 24             	mov    (%esp),%ecx
f0103006:	c3                   	ret    

f0103007 <__x86.get_pc_thunk.di>:
f0103007:	8b 3c 24             	mov    (%esp),%edi
f010300a:	c3                   	ret    

f010300b <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010300b:	55                   	push   %ebp
f010300c:	89 e5                	mov    %esp,%ebp
f010300e:	53                   	push   %ebx
f010300f:	e8 ef ff ff ff       	call   f0103003 <__x86.get_pc_thunk.cx>
f0103014:	81 c1 54 a8 07 00    	add    $0x7a854,%ecx
f010301a:	8b 45 08             	mov    0x8(%ebp),%eax
f010301d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103020:	85 c0                	test   %eax,%eax
f0103022:	74 4c                	je     f0103070 <envid2env+0x65>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103024:	89 c2                	mov    %eax,%edx
f0103026:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010302c:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010302f:	c1 e2 05             	shl    $0x5,%edx
f0103032:	03 91 ec 1a 00 00    	add    0x1aec(%ecx),%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103038:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f010303c:	74 42                	je     f0103080 <envid2env+0x75>
f010303e:	39 42 48             	cmp    %eax,0x48(%edx)
f0103041:	75 49                	jne    f010308c <envid2env+0x81>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
	return 0;
f0103043:	b8 00 00 00 00       	mov    $0x0,%eax
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103048:	84 db                	test   %bl,%bl
f010304a:	74 2a                	je     f0103076 <envid2env+0x6b>
f010304c:	8b 89 e8 1a 00 00    	mov    0x1ae8(%ecx),%ecx
f0103052:	39 d1                	cmp    %edx,%ecx
f0103054:	74 20                	je     f0103076 <envid2env+0x6b>
f0103056:	8b 42 4c             	mov    0x4c(%edx),%eax
f0103059:	3b 41 48             	cmp    0x48(%ecx),%eax
f010305c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103061:	0f 45 d3             	cmovne %ebx,%edx
f0103064:	0f 94 c0             	sete   %al
f0103067:	0f b6 c0             	movzbl %al,%eax
f010306a:	8d 44 00 fe          	lea    -0x2(%eax,%eax,1),%eax
f010306e:	eb 06                	jmp    f0103076 <envid2env+0x6b>
		*env_store = curenv;
f0103070:	8b 91 e8 1a 00 00    	mov    0x1ae8(%ecx),%edx
f0103076:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103079:	89 11                	mov    %edx,(%ecx)
}
f010307b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010307e:	c9                   	leave  
f010307f:	c3                   	ret    
f0103080:	ba 00 00 00 00       	mov    $0x0,%edx
		return -E_BAD_ENV;
f0103085:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010308a:	eb ea                	jmp    f0103076 <envid2env+0x6b>
f010308c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103091:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103096:	eb de                	jmp    f0103076 <envid2env+0x6b>

f0103098 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103098:	e8 5c d6 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f010309d:	05 cb a7 07 00       	add    $0x7a7cb,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f01030a2:	8d 80 98 17 00 00    	lea    0x1798(%eax),%eax
f01030a8:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01030ab:	b8 23 00 00 00       	mov    $0x23,%eax
f01030b0:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01030b2:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01030b4:	b8 10 00 00 00       	mov    $0x10,%eax
f01030b9:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01030bb:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01030bd:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01030bf:	ea c6 30 10 f0 08 00 	ljmp   $0x8,$0xf01030c6
	asm volatile("lldt %0" : : "r" (sel));
f01030c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01030cb:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01030ce:	c3                   	ret    

f01030cf <env_init>:
{
f01030cf:	55                   	push   %ebp
f01030d0:	89 e5                	mov    %esp,%ebp
f01030d2:	83 ec 08             	sub    $0x8,%esp
	env_init_percpu();
f01030d5:	e8 be ff ff ff       	call   f0103098 <env_init_percpu>
}
f01030da:	c9                   	leave  
f01030db:	c3                   	ret    

f01030dc <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01030dc:	55                   	push   %ebp
f01030dd:	89 e5                	mov    %esp,%ebp
f01030df:	56                   	push   %esi
f01030e0:	53                   	push   %ebx
f01030e1:	e8 81 d0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01030e6:	81 c3 82 a7 07 00    	add    $0x7a782,%ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01030ec:	8b b3 f0 1a 00 00    	mov    0x1af0(%ebx),%esi
f01030f2:	85 f6                	test   %esi,%esi
f01030f4:	0f 84 03 01 00 00    	je     f01031fd <env_alloc+0x121>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01030fa:	83 ec 0c             	sub    $0xc,%esp
f01030fd:	6a 01                	push   $0x1
f01030ff:	e8 36 de ff ff       	call   f0100f3a <page_alloc>
f0103104:	83 c4 10             	add    $0x10,%esp
f0103107:	85 c0                	test   %eax,%eax
f0103109:	0f 84 f5 00 00 00    	je     f0103204 <env_alloc+0x128>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010310f:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103112:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103117:	0f 86 c7 00 00 00    	jbe    f01031e4 <env_alloc+0x108>
	return (physaddr_t)kva - KERNBASE;
f010311d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103123:	83 ca 05             	or     $0x5,%edx
f0103126:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010312c:	8b 46 48             	mov    0x48(%esi),%eax
f010312f:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
		generation = 1 << ENVGENSHIFT;
f0103134:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103139:	ba 00 10 00 00       	mov    $0x1000,%edx
f010313e:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103141:	89 f2                	mov    %esi,%edx
f0103143:	2b 93 ec 1a 00 00    	sub    0x1aec(%ebx),%edx
f0103149:	c1 fa 05             	sar    $0x5,%edx
f010314c:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103152:	09 d0                	or     %edx,%eax
f0103154:	89 46 48             	mov    %eax,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103157:	8b 45 0c             	mov    0xc(%ebp),%eax
f010315a:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f010315d:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0103164:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f010316b:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103172:	83 ec 04             	sub    $0x4,%esp
f0103175:	6a 44                	push   $0x44
f0103177:	6a 00                	push   $0x0
f0103179:	56                   	push   %esi
f010317a:	e8 bd 13 00 00       	call   f010453c <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010317f:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f0103185:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f010318b:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0103191:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f0103198:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f010319e:	8b 46 44             	mov    0x44(%esi),%eax
f01031a1:	89 83 f0 1a 00 00    	mov    %eax,0x1af0(%ebx)
	*newenv_store = e;
f01031a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01031aa:	89 30                	mov    %esi,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01031ac:	8b 4e 48             	mov    0x48(%esi),%ecx
f01031af:	8b 83 e8 1a 00 00    	mov    0x1ae8(%ebx),%eax
f01031b5:	83 c4 10             	add    $0x10,%esp
f01031b8:	ba 00 00 00 00       	mov    $0x0,%edx
f01031bd:	85 c0                	test   %eax,%eax
f01031bf:	74 03                	je     f01031c4 <env_alloc+0xe8>
f01031c1:	8b 50 48             	mov    0x48(%eax),%edx
f01031c4:	83 ec 04             	sub    $0x4,%esp
f01031c7:	51                   	push   %ecx
f01031c8:	52                   	push   %edx
f01031c9:	8d 83 6d 80 f8 ff    	lea    -0x77f93(%ebx),%eax
f01031cf:	50                   	push   %eax
f01031d0:	e8 6a 03 00 00       	call   f010353f <cprintf>
	return 0;
f01031d5:	83 c4 10             	add    $0x10,%esp
f01031d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01031e0:	5b                   	pop    %ebx
f01031e1:	5e                   	pop    %esi
f01031e2:	5d                   	pop    %ebp
f01031e3:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031e4:	50                   	push   %eax
f01031e5:	8d 83 88 76 f8 ff    	lea    -0x78978(%ebx),%eax
f01031eb:	50                   	push   %eax
f01031ec:	68 b9 00 00 00       	push   $0xb9
f01031f1:	8d 83 62 80 f8 ff    	lea    -0x77f9e(%ebx),%eax
f01031f7:	50                   	push   %eax
f01031f8:	e8 b4 ce ff ff       	call   f01000b1 <_panic>
		return -E_NO_FREE_ENV;
f01031fd:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103202:	eb d9                	jmp    f01031dd <env_alloc+0x101>
		return -E_NO_MEM;
f0103204:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103209:	eb d2                	jmp    f01031dd <env_alloc+0x101>

f010320b <env_create>:
//
void
env_create(uint8_t *binary, enum EnvType type)
{
	// LAB 3: Your code here.
}
f010320b:	c3                   	ret    

f010320c <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010320c:	55                   	push   %ebp
f010320d:	89 e5                	mov    %esp,%ebp
f010320f:	57                   	push   %edi
f0103210:	56                   	push   %esi
f0103211:	53                   	push   %ebx
f0103212:	83 ec 2c             	sub    $0x2c,%esp
f0103215:	e8 4d cf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010321a:	81 c3 4e a6 07 00    	add    $0x7a64e,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103220:	8b 93 e8 1a 00 00    	mov    0x1ae8(%ebx),%edx
f0103226:	3b 55 08             	cmp    0x8(%ebp),%edx
f0103229:	74 47                	je     f0103272 <env_free+0x66>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010322b:	8b 45 08             	mov    0x8(%ebp),%eax
f010322e:	8b 48 48             	mov    0x48(%eax),%ecx
f0103231:	b8 00 00 00 00       	mov    $0x0,%eax
f0103236:	85 d2                	test   %edx,%edx
f0103238:	74 03                	je     f010323d <env_free+0x31>
f010323a:	8b 42 48             	mov    0x48(%edx),%eax
f010323d:	83 ec 04             	sub    $0x4,%esp
f0103240:	51                   	push   %ecx
f0103241:	50                   	push   %eax
f0103242:	8d 83 82 80 f8 ff    	lea    -0x77f7e(%ebx),%eax
f0103248:	50                   	push   %eax
f0103249:	e8 f1 02 00 00       	call   f010353f <cprintf>
f010324e:	83 c4 10             	add    $0x10,%esp
f0103251:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	if (PGNUM(pa) >= npages)
f0103258:	c7 c0 40 f3 17 f0    	mov    $0xf017f340,%eax
f010325e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if (PGNUM(pa) >= npages)
f0103261:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return &pages[PGNUM(pa)];
f0103264:	c7 c0 38 f3 17 f0    	mov    $0xf017f338,%eax
f010326a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010326d:	e9 bf 00 00 00       	jmp    f0103331 <env_free+0x125>
		lcr3(PADDR(kern_pgdir));
f0103272:	c7 c0 3c f3 17 f0    	mov    $0xf017f33c,%eax
f0103278:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010327a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010327f:	76 10                	jbe    f0103291 <env_free+0x85>
	return (physaddr_t)kva - KERNBASE;
f0103281:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103286:	0f 22 d8             	mov    %eax,%cr3
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103289:	8b 45 08             	mov    0x8(%ebp),%eax
f010328c:	8b 48 48             	mov    0x48(%eax),%ecx
f010328f:	eb a9                	jmp    f010323a <env_free+0x2e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103291:	50                   	push   %eax
f0103292:	8d 83 88 76 f8 ff    	lea    -0x78978(%ebx),%eax
f0103298:	50                   	push   %eax
f0103299:	68 68 01 00 00       	push   $0x168
f010329e:	8d 83 62 80 f8 ff    	lea    -0x77f9e(%ebx),%eax
f01032a4:	50                   	push   %eax
f01032a5:	e8 07 ce ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032aa:	57                   	push   %edi
f01032ab:	8d 83 7c 75 f8 ff    	lea    -0x78a84(%ebx),%eax
f01032b1:	50                   	push   %eax
f01032b2:	68 77 01 00 00       	push   $0x177
f01032b7:	8d 83 62 80 f8 ff    	lea    -0x77f9e(%ebx),%eax
f01032bd:	50                   	push   %eax
f01032be:	e8 ee cd ff ff       	call   f01000b1 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032c3:	83 c7 04             	add    $0x4,%edi
f01032c6:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01032cc:	81 fe 00 00 40 00    	cmp    $0x400000,%esi
f01032d2:	74 1e                	je     f01032f2 <env_free+0xe6>
			if (pt[pteno] & PTE_P)
f01032d4:	f6 07 01             	testb  $0x1,(%edi)
f01032d7:	74 ea                	je     f01032c3 <env_free+0xb7>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032d9:	83 ec 08             	sub    $0x8,%esp
f01032dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032df:	09 f0                	or     %esi,%eax
f01032e1:	50                   	push   %eax
f01032e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01032e5:	ff 70 5c             	push   0x5c(%eax)
f01032e8:	e8 fd de ff ff       	call   f01011ea <page_remove>
f01032ed:	83 c4 10             	add    $0x10,%esp
f01032f0:	eb d1                	jmp    f01032c3 <env_free+0xb7>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01032f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01032f5:	8b 40 5c             	mov    0x5c(%eax),%eax
f01032f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01032fb:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103302:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103305:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103308:	3b 10                	cmp    (%eax),%edx
f010330a:	73 67                	jae    f0103373 <env_free+0x167>
		page_decref(pa2page(pa));
f010330c:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010330f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103312:	8b 00                	mov    (%eax),%eax
f0103314:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103317:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010331a:	50                   	push   %eax
f010331b:	e8 ee dc ff ff       	call   f010100e <page_decref>
f0103320:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103323:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0103327:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010332a:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f010332f:	74 5a                	je     f010338b <env_free+0x17f>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103331:	8b 45 08             	mov    0x8(%ebp),%eax
f0103334:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103337:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010333a:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f010333d:	a8 01                	test   $0x1,%al
f010333f:	74 e2                	je     f0103323 <env_free+0x117>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103341:	89 c7                	mov    %eax,%edi
f0103343:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0103349:	c1 e8 0c             	shr    $0xc,%eax
f010334c:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010334f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103352:	3b 02                	cmp    (%edx),%eax
f0103354:	0f 83 50 ff ff ff    	jae    f01032aa <env_free+0x9e>
	return (void *)(pa + KERNBASE);
f010335a:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f0103360:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103363:	c1 e0 14             	shl    $0x14,%eax
f0103366:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103369:	be 00 00 00 00       	mov    $0x0,%esi
f010336e:	e9 61 ff ff ff       	jmp    f01032d4 <env_free+0xc8>
		panic("pa2page called with invalid pa");
f0103373:	83 ec 04             	sub    $0x4,%esp
f0103376:	8d 83 d0 76 f8 ff    	lea    -0x78930(%ebx),%eax
f010337c:	50                   	push   %eax
f010337d:	6a 4f                	push   $0x4f
f010337f:	8d 83 55 7d f8 ff    	lea    -0x782ab(%ebx),%eax
f0103385:	50                   	push   %eax
f0103386:	e8 26 cd ff ff       	call   f01000b1 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010338b:	8b 45 08             	mov    0x8(%ebp),%eax
f010338e:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103391:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103396:	76 57                	jbe    f01033ef <env_free+0x1e3>
	e->env_pgdir = 0;
f0103398:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010339b:	c7 41 5c 00 00 00 00 	movl   $0x0,0x5c(%ecx)
	return (physaddr_t)kva - KERNBASE;
f01033a2:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01033a7:	c1 e8 0c             	shr    $0xc,%eax
f01033aa:	c7 c2 40 f3 17 f0    	mov    $0xf017f340,%edx
f01033b0:	3b 02                	cmp    (%edx),%eax
f01033b2:	73 54                	jae    f0103408 <env_free+0x1fc>
	page_decref(pa2page(pa));
f01033b4:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01033b7:	c7 c2 38 f3 17 f0    	mov    $0xf017f338,%edx
f01033bd:	8b 12                	mov    (%edx),%edx
f01033bf:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01033c2:	50                   	push   %eax
f01033c3:	e8 46 dc ff ff       	call   f010100e <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01033c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01033cb:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f01033d2:	8b 83 f0 1a 00 00    	mov    0x1af0(%ebx),%eax
f01033d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01033db:	89 41 44             	mov    %eax,0x44(%ecx)
	env_free_list = e;
f01033de:	89 8b f0 1a 00 00    	mov    %ecx,0x1af0(%ebx)
}
f01033e4:	83 c4 10             	add    $0x10,%esp
f01033e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033ea:	5b                   	pop    %ebx
f01033eb:	5e                   	pop    %esi
f01033ec:	5f                   	pop    %edi
f01033ed:	5d                   	pop    %ebp
f01033ee:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033ef:	50                   	push   %eax
f01033f0:	8d 83 88 76 f8 ff    	lea    -0x78978(%ebx),%eax
f01033f6:	50                   	push   %eax
f01033f7:	68 85 01 00 00       	push   $0x185
f01033fc:	8d 83 62 80 f8 ff    	lea    -0x77f9e(%ebx),%eax
f0103402:	50                   	push   %eax
f0103403:	e8 a9 cc ff ff       	call   f01000b1 <_panic>
		panic("pa2page called with invalid pa");
f0103408:	83 ec 04             	sub    $0x4,%esp
f010340b:	8d 83 d0 76 f8 ff    	lea    -0x78930(%ebx),%eax
f0103411:	50                   	push   %eax
f0103412:	6a 4f                	push   $0x4f
f0103414:	8d 83 55 7d f8 ff    	lea    -0x782ab(%ebx),%eax
f010341a:	50                   	push   %eax
f010341b:	e8 91 cc ff ff       	call   f01000b1 <_panic>

f0103420 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103420:	55                   	push   %ebp
f0103421:	89 e5                	mov    %esp,%ebp
f0103423:	53                   	push   %ebx
f0103424:	83 ec 10             	sub    $0x10,%esp
f0103427:	e8 3b cd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010342c:	81 c3 3c a4 07 00    	add    $0x7a43c,%ebx
	env_free(e);
f0103432:	ff 75 08             	push   0x8(%ebp)
f0103435:	e8 d2 fd ff ff       	call   f010320c <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f010343a:	8d 83 2c 80 f8 ff    	lea    -0x77fd4(%ebx),%eax
f0103440:	89 04 24             	mov    %eax,(%esp)
f0103443:	e8 f7 00 00 00       	call   f010353f <cprintf>
f0103448:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f010344b:	83 ec 0c             	sub    $0xc,%esp
f010344e:	6a 00                	push   $0x0
f0103450:	e8 d3 d3 ff ff       	call   f0100828 <monitor>
f0103455:	83 c4 10             	add    $0x10,%esp
f0103458:	eb f1                	jmp    f010344b <env_destroy+0x2b>

f010345a <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010345a:	55                   	push   %ebp
f010345b:	89 e5                	mov    %esp,%ebp
f010345d:	53                   	push   %ebx
f010345e:	83 ec 08             	sub    $0x8,%esp
f0103461:	e8 01 cd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103466:	81 c3 02 a4 07 00    	add    $0x7a402,%ebx
	asm volatile(
f010346c:	8b 65 08             	mov    0x8(%ebp),%esp
f010346f:	61                   	popa   
f0103470:	07                   	pop    %es
f0103471:	1f                   	pop    %ds
f0103472:	83 c4 08             	add    $0x8,%esp
f0103475:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103476:	8d 83 98 80 f8 ff    	lea    -0x77f68(%ebx),%eax
f010347c:	50                   	push   %eax
f010347d:	68 ae 01 00 00       	push   $0x1ae
f0103482:	8d 83 62 80 f8 ff    	lea    -0x77f9e(%ebx),%eax
f0103488:	50                   	push   %eax
f0103489:	e8 23 cc ff ff       	call   f01000b1 <_panic>

f010348e <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010348e:	55                   	push   %ebp
f010348f:	89 e5                	mov    %esp,%ebp
f0103491:	53                   	push   %ebx
f0103492:	83 ec 08             	sub    $0x8,%esp
f0103495:	e8 cd cc ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010349a:	81 c3 ce a3 07 00    	add    $0x7a3ce,%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f01034a0:	8d 83 a4 80 f8 ff    	lea    -0x77f5c(%ebx),%eax
f01034a6:	50                   	push   %eax
f01034a7:	68 cd 01 00 00       	push   $0x1cd
f01034ac:	8d 83 62 80 f8 ff    	lea    -0x77f9e(%ebx),%eax
f01034b2:	50                   	push   %eax
f01034b3:	e8 f9 cb ff ff       	call   f01000b1 <_panic>

f01034b8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01034b8:	55                   	push   %ebp
f01034b9:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01034be:	ba 70 00 00 00       	mov    $0x70,%edx
f01034c3:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034c4:	ba 71 00 00 00       	mov    $0x71,%edx
f01034c9:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01034ca:	0f b6 c0             	movzbl %al,%eax
}
f01034cd:	5d                   	pop    %ebp
f01034ce:	c3                   	ret    

f01034cf <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01034cf:	55                   	push   %ebp
f01034d0:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01034d5:	ba 70 00 00 00       	mov    $0x70,%edx
f01034da:	ee                   	out    %al,(%dx)
f01034db:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034de:	ba 71 00 00 00       	mov    $0x71,%edx
f01034e3:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01034e4:	5d                   	pop    %ebp
f01034e5:	c3                   	ret    

f01034e6 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01034e6:	55                   	push   %ebp
f01034e7:	89 e5                	mov    %esp,%ebp
f01034e9:	53                   	push   %ebx
f01034ea:	83 ec 10             	sub    $0x10,%esp
f01034ed:	e8 75 cc ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01034f2:	81 c3 76 a3 07 00    	add    $0x7a376,%ebx
	cputchar(ch);
f01034f8:	ff 75 08             	push   0x8(%ebp)
f01034fb:	e8 d2 d1 ff ff       	call   f01006d2 <cputchar>
	*cnt++;
}
f0103500:	83 c4 10             	add    $0x10,%esp
f0103503:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103506:	c9                   	leave  
f0103507:	c3                   	ret    

f0103508 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103508:	55                   	push   %ebp
f0103509:	89 e5                	mov    %esp,%ebp
f010350b:	53                   	push   %ebx
f010350c:	83 ec 14             	sub    $0x14,%esp
f010350f:	e8 53 cc ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103514:	81 c3 54 a3 07 00    	add    $0x7a354,%ebx
	int cnt = 0;
f010351a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103521:	ff 75 0c             	push   0xc(%ebp)
f0103524:	ff 75 08             	push   0x8(%ebp)
f0103527:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010352a:	50                   	push   %eax
f010352b:	8d 83 7e 5c f8 ff    	lea    -0x7a382(%ebx),%eax
f0103531:	50                   	push   %eax
f0103532:	e8 90 08 00 00       	call   f0103dc7 <vprintfmt>
	return cnt;
}
f0103537:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010353a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010353d:	c9                   	leave  
f010353e:	c3                   	ret    

f010353f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010353f:	55                   	push   %ebp
f0103540:	89 e5                	mov    %esp,%ebp
f0103542:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103545:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103548:	50                   	push   %eax
f0103549:	ff 75 08             	push   0x8(%ebp)
f010354c:	e8 b7 ff ff ff       	call   f0103508 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103551:	c9                   	leave  
f0103552:	c3                   	ret    

f0103553 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103553:	55                   	push   %ebp
f0103554:	89 e5                	mov    %esp,%ebp
f0103556:	57                   	push   %edi
f0103557:	56                   	push   %esi
f0103558:	53                   	push   %ebx
f0103559:	83 ec 04             	sub    $0x4,%esp
f010355c:	e8 06 cc ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103561:	81 c3 07 a3 07 00    	add    $0x7a307,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103567:	c7 83 1c 23 00 00 00 	movl   $0xf0000000,0x231c(%ebx)
f010356e:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103571:	66 c7 83 20 23 00 00 	movw   $0x10,0x2320(%ebx)
f0103578:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f010357a:	66 c7 83 7e 23 00 00 	movw   $0x68,0x237e(%ebx)
f0103581:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103583:	c7 c0 00 a3 11 f0    	mov    $0xf011a300,%eax
f0103589:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f010358f:	8d b3 18 23 00 00    	lea    0x2318(%ebx),%esi
f0103595:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103599:	89 f2                	mov    %esi,%edx
f010359b:	c1 ea 10             	shr    $0x10,%edx
f010359e:	88 50 2c             	mov    %dl,0x2c(%eax)
f01035a1:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f01035a5:	83 e2 f0             	and    $0xfffffff0,%edx
f01035a8:	83 ca 09             	or     $0x9,%edx
f01035ab:	83 e2 9f             	and    $0xffffff9f,%edx
f01035ae:	83 ca 80             	or     $0xffffff80,%edx
f01035b1:	88 55 f3             	mov    %dl,-0xd(%ebp)
f01035b4:	88 50 2d             	mov    %dl,0x2d(%eax)
f01035b7:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f01035bb:	83 e1 c0             	and    $0xffffffc0,%ecx
f01035be:	83 c9 40             	or     $0x40,%ecx
f01035c1:	83 e1 7f             	and    $0x7f,%ecx
f01035c4:	88 48 2e             	mov    %cl,0x2e(%eax)
f01035c7:	c1 ee 18             	shr    $0x18,%esi
f01035ca:	89 f1                	mov    %esi,%ecx
f01035cc:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01035cf:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f01035d3:	83 e2 ef             	and    $0xffffffef,%edx
f01035d6:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f01035d9:	b8 28 00 00 00       	mov    $0x28,%eax
f01035de:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f01035e1:	8d 83 a0 17 00 00    	lea    0x17a0(%ebx),%eax
f01035e7:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01035ea:	83 c4 04             	add    $0x4,%esp
f01035ed:	5b                   	pop    %ebx
f01035ee:	5e                   	pop    %esi
f01035ef:	5f                   	pop    %edi
f01035f0:	5d                   	pop    %ebp
f01035f1:	c3                   	ret    

f01035f2 <trap_init>:
{
f01035f2:	55                   	push   %ebp
f01035f3:	89 e5                	mov    %esp,%ebp
	trap_init_percpu();
f01035f5:	e8 59 ff ff ff       	call   f0103553 <trap_init_percpu>
}
f01035fa:	5d                   	pop    %ebp
f01035fb:	c3                   	ret    

f01035fc <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01035fc:	55                   	push   %ebp
f01035fd:	89 e5                	mov    %esp,%ebp
f01035ff:	56                   	push   %esi
f0103600:	53                   	push   %ebx
f0103601:	e8 61 cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103606:	81 c3 62 a2 07 00    	add    $0x7a262,%ebx
f010360c:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010360f:	83 ec 08             	sub    $0x8,%esp
f0103612:	ff 36                	push   (%esi)
f0103614:	8d 83 c0 80 f8 ff    	lea    -0x77f40(%ebx),%eax
f010361a:	50                   	push   %eax
f010361b:	e8 1f ff ff ff       	call   f010353f <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103620:	83 c4 08             	add    $0x8,%esp
f0103623:	ff 76 04             	push   0x4(%esi)
f0103626:	8d 83 cf 80 f8 ff    	lea    -0x77f31(%ebx),%eax
f010362c:	50                   	push   %eax
f010362d:	e8 0d ff ff ff       	call   f010353f <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103632:	83 c4 08             	add    $0x8,%esp
f0103635:	ff 76 08             	push   0x8(%esi)
f0103638:	8d 83 de 80 f8 ff    	lea    -0x77f22(%ebx),%eax
f010363e:	50                   	push   %eax
f010363f:	e8 fb fe ff ff       	call   f010353f <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103644:	83 c4 08             	add    $0x8,%esp
f0103647:	ff 76 0c             	push   0xc(%esi)
f010364a:	8d 83 ed 80 f8 ff    	lea    -0x77f13(%ebx),%eax
f0103650:	50                   	push   %eax
f0103651:	e8 e9 fe ff ff       	call   f010353f <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103656:	83 c4 08             	add    $0x8,%esp
f0103659:	ff 76 10             	push   0x10(%esi)
f010365c:	8d 83 fc 80 f8 ff    	lea    -0x77f04(%ebx),%eax
f0103662:	50                   	push   %eax
f0103663:	e8 d7 fe ff ff       	call   f010353f <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103668:	83 c4 08             	add    $0x8,%esp
f010366b:	ff 76 14             	push   0x14(%esi)
f010366e:	8d 83 0b 81 f8 ff    	lea    -0x77ef5(%ebx),%eax
f0103674:	50                   	push   %eax
f0103675:	e8 c5 fe ff ff       	call   f010353f <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010367a:	83 c4 08             	add    $0x8,%esp
f010367d:	ff 76 18             	push   0x18(%esi)
f0103680:	8d 83 1a 81 f8 ff    	lea    -0x77ee6(%ebx),%eax
f0103686:	50                   	push   %eax
f0103687:	e8 b3 fe ff ff       	call   f010353f <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010368c:	83 c4 08             	add    $0x8,%esp
f010368f:	ff 76 1c             	push   0x1c(%esi)
f0103692:	8d 83 29 81 f8 ff    	lea    -0x77ed7(%ebx),%eax
f0103698:	50                   	push   %eax
f0103699:	e8 a1 fe ff ff       	call   f010353f <cprintf>
}
f010369e:	83 c4 10             	add    $0x10,%esp
f01036a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01036a4:	5b                   	pop    %ebx
f01036a5:	5e                   	pop    %esi
f01036a6:	5d                   	pop    %ebp
f01036a7:	c3                   	ret    

f01036a8 <print_trapframe>:
{
f01036a8:	55                   	push   %ebp
f01036a9:	89 e5                	mov    %esp,%ebp
f01036ab:	57                   	push   %edi
f01036ac:	56                   	push   %esi
f01036ad:	53                   	push   %ebx
f01036ae:	83 ec 14             	sub    $0x14,%esp
f01036b1:	e8 b1 ca ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01036b6:	81 c3 b2 a1 07 00    	add    $0x7a1b2,%ebx
f01036bc:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f01036bf:	56                   	push   %esi
f01036c0:	8d 83 5f 82 f8 ff    	lea    -0x77da1(%ebx),%eax
f01036c6:	50                   	push   %eax
f01036c7:	e8 73 fe ff ff       	call   f010353f <cprintf>
	print_regs(&tf->tf_regs);
f01036cc:	89 34 24             	mov    %esi,(%esp)
f01036cf:	e8 28 ff ff ff       	call   f01035fc <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01036d4:	83 c4 08             	add    $0x8,%esp
f01036d7:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f01036db:	50                   	push   %eax
f01036dc:	8d 83 7a 81 f8 ff    	lea    -0x77e86(%ebx),%eax
f01036e2:	50                   	push   %eax
f01036e3:	e8 57 fe ff ff       	call   f010353f <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01036e8:	83 c4 08             	add    $0x8,%esp
f01036eb:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f01036ef:	50                   	push   %eax
f01036f0:	8d 83 8d 81 f8 ff    	lea    -0x77e73(%ebx),%eax
f01036f6:	50                   	push   %eax
f01036f7:	e8 43 fe ff ff       	call   f010353f <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01036fc:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f01036ff:	83 c4 10             	add    $0x10,%esp
f0103702:	83 fa 13             	cmp    $0x13,%edx
f0103705:	0f 86 e2 00 00 00    	jbe    f01037ed <print_trapframe+0x145>
		return "System call";
f010370b:	83 fa 30             	cmp    $0x30,%edx
f010370e:	8d 83 38 81 f8 ff    	lea    -0x77ec8(%ebx),%eax
f0103714:	8d 8b 47 81 f8 ff    	lea    -0x77eb9(%ebx),%ecx
f010371a:	0f 44 c1             	cmove  %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010371d:	83 ec 04             	sub    $0x4,%esp
f0103720:	50                   	push   %eax
f0103721:	52                   	push   %edx
f0103722:	8d 83 a0 81 f8 ff    	lea    -0x77e60(%ebx),%eax
f0103728:	50                   	push   %eax
f0103729:	e8 11 fe ff ff       	call   f010353f <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010372e:	83 c4 10             	add    $0x10,%esp
f0103731:	39 b3 f8 22 00 00    	cmp    %esi,0x22f8(%ebx)
f0103737:	0f 84 bc 00 00 00    	je     f01037f9 <print_trapframe+0x151>
	cprintf("  err  0x%08x", tf->tf_err);
f010373d:	83 ec 08             	sub    $0x8,%esp
f0103740:	ff 76 2c             	push   0x2c(%esi)
f0103743:	8d 83 c1 81 f8 ff    	lea    -0x77e3f(%ebx),%eax
f0103749:	50                   	push   %eax
f010374a:	e8 f0 fd ff ff       	call   f010353f <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f010374f:	83 c4 10             	add    $0x10,%esp
f0103752:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103756:	0f 85 c2 00 00 00    	jne    f010381e <print_trapframe+0x176>
			tf->tf_err & 1 ? "protection" : "not-present");
f010375c:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f010375f:	a8 01                	test   $0x1,%al
f0103761:	8d 8b 53 81 f8 ff    	lea    -0x77ead(%ebx),%ecx
f0103767:	8d 93 5e 81 f8 ff    	lea    -0x77ea2(%ebx),%edx
f010376d:	0f 44 ca             	cmove  %edx,%ecx
f0103770:	a8 02                	test   $0x2,%al
f0103772:	8d 93 6a 81 f8 ff    	lea    -0x77e96(%ebx),%edx
f0103778:	8d bb 70 81 f8 ff    	lea    -0x77e90(%ebx),%edi
f010377e:	0f 44 d7             	cmove  %edi,%edx
f0103781:	a8 04                	test   $0x4,%al
f0103783:	8d 83 75 81 f8 ff    	lea    -0x77e8b(%ebx),%eax
f0103789:	8d bb 8a 82 f8 ff    	lea    -0x77d76(%ebx),%edi
f010378f:	0f 44 c7             	cmove  %edi,%eax
f0103792:	51                   	push   %ecx
f0103793:	52                   	push   %edx
f0103794:	50                   	push   %eax
f0103795:	8d 83 cf 81 f8 ff    	lea    -0x77e31(%ebx),%eax
f010379b:	50                   	push   %eax
f010379c:	e8 9e fd ff ff       	call   f010353f <cprintf>
f01037a1:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01037a4:	83 ec 08             	sub    $0x8,%esp
f01037a7:	ff 76 30             	push   0x30(%esi)
f01037aa:	8d 83 de 81 f8 ff    	lea    -0x77e22(%ebx),%eax
f01037b0:	50                   	push   %eax
f01037b1:	e8 89 fd ff ff       	call   f010353f <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01037b6:	83 c4 08             	add    $0x8,%esp
f01037b9:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01037bd:	50                   	push   %eax
f01037be:	8d 83 ed 81 f8 ff    	lea    -0x77e13(%ebx),%eax
f01037c4:	50                   	push   %eax
f01037c5:	e8 75 fd ff ff       	call   f010353f <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01037ca:	83 c4 08             	add    $0x8,%esp
f01037cd:	ff 76 38             	push   0x38(%esi)
f01037d0:	8d 83 00 82 f8 ff    	lea    -0x77e00(%ebx),%eax
f01037d6:	50                   	push   %eax
f01037d7:	e8 63 fd ff ff       	call   f010353f <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01037dc:	83 c4 10             	add    $0x10,%esp
f01037df:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f01037e3:	75 50                	jne    f0103835 <print_trapframe+0x18d>
}
f01037e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037e8:	5b                   	pop    %ebx
f01037e9:	5e                   	pop    %esi
f01037ea:	5f                   	pop    %edi
f01037eb:	5d                   	pop    %ebp
f01037ec:	c3                   	ret    
		return excnames[trapno];
f01037ed:	8b 84 93 f8 17 00 00 	mov    0x17f8(%ebx,%edx,4),%eax
f01037f4:	e9 24 ff ff ff       	jmp    f010371d <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01037f9:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f01037fd:	0f 85 3a ff ff ff    	jne    f010373d <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103803:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103806:	83 ec 08             	sub    $0x8,%esp
f0103809:	50                   	push   %eax
f010380a:	8d 83 b2 81 f8 ff    	lea    -0x77e4e(%ebx),%eax
f0103810:	50                   	push   %eax
f0103811:	e8 29 fd ff ff       	call   f010353f <cprintf>
f0103816:	83 c4 10             	add    $0x10,%esp
f0103819:	e9 1f ff ff ff       	jmp    f010373d <print_trapframe+0x95>
		cprintf("\n");
f010381e:	83 ec 0c             	sub    $0xc,%esp
f0103821:	8d 83 fa 7f f8 ff    	lea    -0x78006(%ebx),%eax
f0103827:	50                   	push   %eax
f0103828:	e8 12 fd ff ff       	call   f010353f <cprintf>
f010382d:	83 c4 10             	add    $0x10,%esp
f0103830:	e9 6f ff ff ff       	jmp    f01037a4 <print_trapframe+0xfc>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103835:	83 ec 08             	sub    $0x8,%esp
f0103838:	ff 76 3c             	push   0x3c(%esi)
f010383b:	8d 83 0f 82 f8 ff    	lea    -0x77df1(%ebx),%eax
f0103841:	50                   	push   %eax
f0103842:	e8 f8 fc ff ff       	call   f010353f <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103847:	83 c4 08             	add    $0x8,%esp
f010384a:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f010384e:	50                   	push   %eax
f010384f:	8d 83 1e 82 f8 ff    	lea    -0x77de2(%ebx),%eax
f0103855:	50                   	push   %eax
f0103856:	e8 e4 fc ff ff       	call   f010353f <cprintf>
f010385b:	83 c4 10             	add    $0x10,%esp
}
f010385e:	eb 85                	jmp    f01037e5 <print_trapframe+0x13d>

f0103860 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103860:	55                   	push   %ebp
f0103861:	89 e5                	mov    %esp,%ebp
f0103863:	57                   	push   %edi
f0103864:	56                   	push   %esi
f0103865:	53                   	push   %ebx
f0103866:	83 ec 0c             	sub    $0xc,%esp
f0103869:	e8 f9 c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010386e:	81 c3 fa 9f 07 00    	add    $0x79ffa,%ebx
f0103874:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103877:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103878:	9c                   	pushf  
f0103879:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010387a:	f6 c4 02             	test   $0x2,%ah
f010387d:	74 1f                	je     f010389e <trap+0x3e>
f010387f:	8d 83 31 82 f8 ff    	lea    -0x77dcf(%ebx),%eax
f0103885:	50                   	push   %eax
f0103886:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010388c:	50                   	push   %eax
f010388d:	68 a8 00 00 00       	push   $0xa8
f0103892:	8d 83 4a 82 f8 ff    	lea    -0x77db6(%ebx),%eax
f0103898:	50                   	push   %eax
f0103899:	e8 13 c8 ff ff       	call   f01000b1 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f010389e:	83 ec 08             	sub    $0x8,%esp
f01038a1:	56                   	push   %esi
f01038a2:	8d 83 56 82 f8 ff    	lea    -0x77daa(%ebx),%eax
f01038a8:	50                   	push   %eax
f01038a9:	e8 91 fc ff ff       	call   f010353f <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01038ae:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01038b2:	83 e0 03             	and    $0x3,%eax
f01038b5:	83 c4 10             	add    $0x10,%esp
f01038b8:	66 83 f8 03          	cmp    $0x3,%ax
f01038bc:	75 1d                	jne    f01038db <trap+0x7b>
		// Trapped from user mode.
		assert(curenv);
f01038be:	c7 c0 50 f3 17 f0    	mov    $0xf017f350,%eax
f01038c4:	8b 00                	mov    (%eax),%eax
f01038c6:	85 c0                	test   %eax,%eax
f01038c8:	74 68                	je     f0103932 <trap+0xd2>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01038ca:	b9 11 00 00 00       	mov    $0x11,%ecx
f01038cf:	89 c7                	mov    %eax,%edi
f01038d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01038d3:	c7 c0 50 f3 17 f0    	mov    $0xf017f350,%eax
f01038d9:	8b 30                	mov    (%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01038db:	89 b3 f8 22 00 00    	mov    %esi,0x22f8(%ebx)
	print_trapframe(tf);
f01038e1:	83 ec 0c             	sub    $0xc,%esp
f01038e4:	56                   	push   %esi
f01038e5:	e8 be fd ff ff       	call   f01036a8 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01038ea:	83 c4 10             	add    $0x10,%esp
f01038ed:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01038f2:	74 5d                	je     f0103951 <trap+0xf1>
		env_destroy(curenv);
f01038f4:	83 ec 0c             	sub    $0xc,%esp
f01038f7:	c7 c6 50 f3 17 f0    	mov    $0xf017f350,%esi
f01038fd:	ff 36                	push   (%esi)
f01038ff:	e8 1c fb ff ff       	call   f0103420 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103904:	8b 06                	mov    (%esi),%eax
f0103906:	83 c4 10             	add    $0x10,%esp
f0103909:	85 c0                	test   %eax,%eax
f010390b:	74 06                	je     f0103913 <trap+0xb3>
f010390d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103911:	74 59                	je     f010396c <trap+0x10c>
f0103913:	8d 83 d4 83 f8 ff    	lea    -0x77c2c(%ebx),%eax
f0103919:	50                   	push   %eax
f010391a:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f0103920:	50                   	push   %eax
f0103921:	68 c0 00 00 00       	push   $0xc0
f0103926:	8d 83 4a 82 f8 ff    	lea    -0x77db6(%ebx),%eax
f010392c:	50                   	push   %eax
f010392d:	e8 7f c7 ff ff       	call   f01000b1 <_panic>
		assert(curenv);
f0103932:	8d 83 71 82 f8 ff    	lea    -0x77d8f(%ebx),%eax
f0103938:	50                   	push   %eax
f0103939:	8d 83 6f 7d f8 ff    	lea    -0x78291(%ebx),%eax
f010393f:	50                   	push   %eax
f0103940:	68 ae 00 00 00       	push   $0xae
f0103945:	8d 83 4a 82 f8 ff    	lea    -0x77db6(%ebx),%eax
f010394b:	50                   	push   %eax
f010394c:	e8 60 c7 ff ff       	call   f01000b1 <_panic>
		panic("unhandled trap in kernel");
f0103951:	83 ec 04             	sub    $0x4,%esp
f0103954:	8d 83 78 82 f8 ff    	lea    -0x77d88(%ebx),%eax
f010395a:	50                   	push   %eax
f010395b:	68 97 00 00 00       	push   $0x97
f0103960:	8d 83 4a 82 f8 ff    	lea    -0x77db6(%ebx),%eax
f0103966:	50                   	push   %eax
f0103967:	e8 45 c7 ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f010396c:	83 ec 0c             	sub    $0xc,%esp
f010396f:	50                   	push   %eax
f0103970:	e8 19 fb ff ff       	call   f010348e <env_run>

f0103975 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103975:	55                   	push   %ebp
f0103976:	89 e5                	mov    %esp,%ebp
f0103978:	57                   	push   %edi
f0103979:	56                   	push   %esi
f010397a:	53                   	push   %ebx
f010397b:	83 ec 0c             	sub    $0xc,%esp
f010397e:	e8 e4 c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103983:	81 c3 e5 9e 07 00    	add    $0x79ee5,%ebx
f0103989:	8b 7d 08             	mov    0x8(%ebp),%edi
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010398c:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010398f:	ff 77 30             	push   0x30(%edi)
f0103992:	50                   	push   %eax
f0103993:	c7 c6 50 f3 17 f0    	mov    $0xf017f350,%esi
f0103999:	8b 06                	mov    (%esi),%eax
f010399b:	ff 70 48             	push   0x48(%eax)
f010399e:	8d 83 00 84 f8 ff    	lea    -0x77c00(%ebx),%eax
f01039a4:	50                   	push   %eax
f01039a5:	e8 95 fb ff ff       	call   f010353f <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01039aa:	89 3c 24             	mov    %edi,(%esp)
f01039ad:	e8 f6 fc ff ff       	call   f01036a8 <print_trapframe>
	env_destroy(curenv);
f01039b2:	83 c4 04             	add    $0x4,%esp
f01039b5:	ff 36                	push   (%esi)
f01039b7:	e8 64 fa ff ff       	call   f0103420 <env_destroy>
}
f01039bc:	83 c4 10             	add    $0x10,%esp
f01039bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01039c2:	5b                   	pop    %ebx
f01039c3:	5e                   	pop    %esi
f01039c4:	5f                   	pop    %edi
f01039c5:	5d                   	pop    %ebp
f01039c6:	c3                   	ret    

f01039c7 <syscall>:
f01039c7:	55                   	push   %ebp
f01039c8:	89 e5                	mov    %esp,%ebp
f01039ca:	53                   	push   %ebx
f01039cb:	83 ec 08             	sub    $0x8,%esp
f01039ce:	e8 94 c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01039d3:	81 c3 95 9e 07 00    	add    $0x79e95,%ebx
f01039d9:	8d 83 23 84 f8 ff    	lea    -0x77bdd(%ebx),%eax
f01039df:	50                   	push   %eax
f01039e0:	6a 49                	push   $0x49
f01039e2:	8d 83 3b 84 f8 ff    	lea    -0x77bc5(%ebx),%eax
f01039e8:	50                   	push   %eax
f01039e9:	e8 c3 c6 ff ff       	call   f01000b1 <_panic>

f01039ee <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01039ee:	55                   	push   %ebp
f01039ef:	89 e5                	mov    %esp,%ebp
f01039f1:	57                   	push   %edi
f01039f2:	56                   	push   %esi
f01039f3:	53                   	push   %ebx
f01039f4:	83 ec 14             	sub    $0x14,%esp
f01039f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01039fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01039fd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103a00:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103a03:	8b 1a                	mov    (%edx),%ebx
f0103a05:	8b 01                	mov    (%ecx),%eax
f0103a07:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103a0a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103a11:	eb 2f                	jmp    f0103a42 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103a13:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0103a16:	39 c3                	cmp    %eax,%ebx
f0103a18:	7f 4e                	jg     f0103a68 <stab_binsearch+0x7a>
f0103a1a:	0f b6 0a             	movzbl (%edx),%ecx
f0103a1d:	83 ea 0c             	sub    $0xc,%edx
f0103a20:	39 f1                	cmp    %esi,%ecx
f0103a22:	75 ef                	jne    f0103a13 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103a24:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103a27:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103a2a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103a2e:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103a31:	73 3a                	jae    f0103a6d <stab_binsearch+0x7f>
			*region_left = m;
f0103a33:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103a36:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103a38:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0103a3b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103a42:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103a45:	7f 53                	jg     f0103a9a <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0103a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103a4a:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0103a4d:	89 d0                	mov    %edx,%eax
f0103a4f:	c1 e8 1f             	shr    $0x1f,%eax
f0103a52:	01 d0                	add    %edx,%eax
f0103a54:	89 c7                	mov    %eax,%edi
f0103a56:	d1 ff                	sar    %edi
f0103a58:	83 e0 fe             	and    $0xfffffffe,%eax
f0103a5b:	01 f8                	add    %edi,%eax
f0103a5d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103a60:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103a64:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0103a66:	eb ae                	jmp    f0103a16 <stab_binsearch+0x28>
			l = true_m + 1;
f0103a68:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103a6b:	eb d5                	jmp    f0103a42 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0103a6d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103a70:	76 14                	jbe    f0103a86 <stab_binsearch+0x98>
			*region_right = m - 1;
f0103a72:	83 e8 01             	sub    $0x1,%eax
f0103a75:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103a78:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103a7b:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0103a7d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103a84:	eb bc                	jmp    f0103a42 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103a86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103a89:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0103a8b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103a8f:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0103a91:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103a98:	eb a8                	jmp    f0103a42 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0103a9a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103a9e:	75 15                	jne    f0103ab5 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0103aa0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103aa3:	8b 00                	mov    (%eax),%eax
f0103aa5:	83 e8 01             	sub    $0x1,%eax
f0103aa8:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103aab:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103aad:	83 c4 14             	add    $0x14,%esp
f0103ab0:	5b                   	pop    %ebx
f0103ab1:	5e                   	pop    %esi
f0103ab2:	5f                   	pop    %edi
f0103ab3:	5d                   	pop    %ebp
f0103ab4:	c3                   	ret    
		for (l = *region_right;
f0103ab5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ab8:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103aba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103abd:	8b 0f                	mov    (%edi),%ecx
f0103abf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103ac2:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103ac5:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0103ac9:	39 c1                	cmp    %eax,%ecx
f0103acb:	7d 0f                	jge    f0103adc <stab_binsearch+0xee>
f0103acd:	0f b6 1a             	movzbl (%edx),%ebx
f0103ad0:	83 ea 0c             	sub    $0xc,%edx
f0103ad3:	39 f3                	cmp    %esi,%ebx
f0103ad5:	74 05                	je     f0103adc <stab_binsearch+0xee>
		     l--)
f0103ad7:	83 e8 01             	sub    $0x1,%eax
f0103ada:	eb ed                	jmp    f0103ac9 <stab_binsearch+0xdb>
		*region_left = l;
f0103adc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103adf:	89 07                	mov    %eax,(%edi)
}
f0103ae1:	eb ca                	jmp    f0103aad <stab_binsearch+0xbf>

f0103ae3 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103ae3:	55                   	push   %ebp
f0103ae4:	89 e5                	mov    %esp,%ebp
f0103ae6:	57                   	push   %edi
f0103ae7:	56                   	push   %esi
f0103ae8:	53                   	push   %ebx
f0103ae9:	83 ec 3c             	sub    $0x3c,%esp
f0103aec:	e8 76 c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103af1:	81 c3 77 9d 07 00    	add    $0x79d77,%ebx
f0103af7:	8b 75 08             	mov    0x8(%ebp),%esi
f0103afa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103afd:	8d 83 4a 84 f8 ff    	lea    -0x77bb6(%ebx),%eax
f0103b03:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0103b05:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0103b0c:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0103b0f:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0103b16:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f0103b19:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103b20:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103b26:	0f 87 ea 00 00 00    	ja     f0103c16 <debuginfo_eip+0x133>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103b2c:	a1 00 00 20 00       	mov    0x200000,%eax
f0103b31:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0103b34:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103b39:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0103b3f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0103b42:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0103b48:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103b4b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103b4e:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0103b51:	0f 83 56 01 00 00    	jae    f0103cad <debuginfo_eip+0x1ca>
f0103b57:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0103b5b:	0f 85 53 01 00 00    	jne    f0103cb4 <debuginfo_eip+0x1d1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103b61:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103b68:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0103b6b:	c1 f8 02             	sar    $0x2,%eax
f0103b6e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103b74:	83 e8 01             	sub    $0x1,%eax
f0103b77:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103b7a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103b7d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103b80:	56                   	push   %esi
f0103b81:	6a 64                	push   $0x64
f0103b83:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103b86:	e8 63 fe ff ff       	call   f01039ee <stab_binsearch>
	if (lfile == 0)
f0103b8b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103b8e:	83 c4 08             	add    $0x8,%esp
f0103b91:	85 c9                	test   %ecx,%ecx
f0103b93:	0f 84 22 01 00 00    	je     f0103cbb <debuginfo_eip+0x1d8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103b99:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103b9c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
	rfun = rfile;
f0103b9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ba2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103ba5:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103ba8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103bab:	56                   	push   %esi
f0103bac:	6a 24                	push   $0x24
f0103bae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103bb1:	e8 38 fe ff ff       	call   f01039ee <stab_binsearch>

	if (lfun <= rfun) {
f0103bb6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103bb9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0103bbc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103bbf:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0103bc2:	83 c4 08             	add    $0x8,%esp
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
		lline = lfile;
f0103bc5:	8b 75 c8             	mov    -0x38(%ebp),%esi
	if (lfun <= rfun) {
f0103bc8:	39 c2                	cmp    %eax,%edx
f0103bca:	7f 25                	jg     f0103bf1 <debuginfo_eip+0x10e>
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103bcc:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103bcf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103bd2:	8d 14 86             	lea    (%esi,%eax,4),%edx
f0103bd5:	8b 02                	mov    (%edx),%eax
f0103bd7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103bda:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0103bdd:	29 f1                	sub    %esi,%ecx
f0103bdf:	39 c8                	cmp    %ecx,%eax
f0103be1:	73 05                	jae    f0103be8 <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103be3:	01 f0                	add    %esi,%eax
f0103be5:	89 47 08             	mov    %eax,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103be8:	8b 42 08             	mov    0x8(%edx),%eax
f0103beb:	89 47 10             	mov    %eax,0x10(%edi)
		lline = lfun;
f0103bee:	8b 75 c4             	mov    -0x3c(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103bf1:	83 ec 08             	sub    $0x8,%esp
f0103bf4:	6a 3a                	push   $0x3a
f0103bf6:	ff 77 08             	push   0x8(%edi)
f0103bf9:	e8 22 09 00 00       	call   f0104520 <strfind>
f0103bfe:	2b 47 08             	sub    0x8(%edi),%eax
f0103c01:	89 47 0c             	mov    %eax,0xc(%edi)
f0103c04:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103c07:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103c0a:	8d 44 83 04          	lea    0x4(%ebx,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103c0e:	83 c4 10             	add    $0x10,%esp
f0103c11:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0103c14:	eb 2c                	jmp    f0103c42 <debuginfo_eip+0x15f>
		stabstr_end = __STABSTR_END__;
f0103c16:	c7 c0 fe 0c 11 f0    	mov    $0xf0110cfe,%eax
f0103c1c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0103c1f:	c7 c0 a9 d5 10 f0    	mov    $0xf010d5a9,%eax
f0103c25:	89 45 cc             	mov    %eax,-0x34(%ebp)
		stab_end = __STAB_END__;
f0103c28:	c7 c0 a8 d5 10 f0    	mov    $0xf010d5a8,%eax
		stabs = __STAB_BEGIN__;
f0103c2e:	c7 c1 b0 5e 10 f0    	mov    $0xf0105eb0,%ecx
f0103c34:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103c37:	e9 0f ff ff ff       	jmp    f0103b4b <debuginfo_eip+0x68>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103c3c:	83 ee 01             	sub    $0x1,%esi
f0103c3f:	83 e8 0c             	sub    $0xc,%eax
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103c42:	39 f3                	cmp    %esi,%ebx
f0103c44:	7f 2e                	jg     f0103c74 <debuginfo_eip+0x191>
	       && stabs[lline].n_type != N_SOL
f0103c46:	0f b6 10             	movzbl (%eax),%edx
f0103c49:	80 fa 84             	cmp    $0x84,%dl
f0103c4c:	74 0b                	je     f0103c59 <debuginfo_eip+0x176>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103c4e:	80 fa 64             	cmp    $0x64,%dl
f0103c51:	75 e9                	jne    f0103c3c <debuginfo_eip+0x159>
f0103c53:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0103c57:	74 e3                	je     f0103c3c <debuginfo_eip+0x159>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103c59:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103c5c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103c5f:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0103c62:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103c65:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0103c68:	29 d8                	sub    %ebx,%eax
f0103c6a:	39 c2                	cmp    %eax,%edx
f0103c6c:	73 06                	jae    f0103c74 <debuginfo_eip+0x191>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103c6e:	89 d8                	mov    %ebx,%eax
f0103c70:	01 d0                	add    %edx,%eax
f0103c72:	89 07                	mov    %eax,(%edi)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103c74:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0103c79:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0103c7c:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0103c7f:	39 cb                	cmp    %ecx,%ebx
f0103c81:	7d 44                	jge    f0103cc7 <debuginfo_eip+0x1e4>
		for (lline = lfun + 1;
f0103c83:	8d 53 01             	lea    0x1(%ebx),%edx
f0103c86:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103c89:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103c8c:	8d 44 83 10          	lea    0x10(%ebx,%eax,4),%eax
f0103c90:	eb 07                	jmp    f0103c99 <debuginfo_eip+0x1b6>
			info->eip_fn_narg++;
f0103c92:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0103c96:	83 c2 01             	add    $0x1,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103c99:	39 d1                	cmp    %edx,%ecx
f0103c9b:	74 25                	je     f0103cc2 <debuginfo_eip+0x1df>
f0103c9d:	83 c0 0c             	add    $0xc,%eax
f0103ca0:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0103ca4:	74 ec                	je     f0103c92 <debuginfo_eip+0x1af>
	return 0;
f0103ca6:	b8 00 00 00 00       	mov    $0x0,%eax
f0103cab:	eb 1a                	jmp    f0103cc7 <debuginfo_eip+0x1e4>
		return -1;
f0103cad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cb2:	eb 13                	jmp    f0103cc7 <debuginfo_eip+0x1e4>
f0103cb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cb9:	eb 0c                	jmp    f0103cc7 <debuginfo_eip+0x1e4>
		return -1;
f0103cbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cc0:	eb 05                	jmp    f0103cc7 <debuginfo_eip+0x1e4>
	return 0;
f0103cc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103cca:	5b                   	pop    %ebx
f0103ccb:	5e                   	pop    %esi
f0103ccc:	5f                   	pop    %edi
f0103ccd:	5d                   	pop    %ebp
f0103cce:	c3                   	ret    

f0103ccf <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103ccf:	55                   	push   %ebp
f0103cd0:	89 e5                	mov    %esp,%ebp
f0103cd2:	57                   	push   %edi
f0103cd3:	56                   	push   %esi
f0103cd4:	53                   	push   %ebx
f0103cd5:	83 ec 2c             	sub    $0x2c,%esp
f0103cd8:	e8 26 f3 ff ff       	call   f0103003 <__x86.get_pc_thunk.cx>
f0103cdd:	81 c1 8b 9b 07 00    	add    $0x79b8b,%ecx
f0103ce3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103ce6:	89 c7                	mov    %eax,%edi
f0103ce8:	89 d6                	mov    %edx,%esi
f0103cea:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ced:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103cf0:	89 d1                	mov    %edx,%ecx
f0103cf2:	89 c2                	mov    %eax,%edx
f0103cf4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103cf7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103cfa:	8b 45 10             	mov    0x10(%ebp),%eax
f0103cfd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103d00:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103d03:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103d0a:	39 c2                	cmp    %eax,%edx
f0103d0c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0103d0f:	72 41                	jb     f0103d52 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103d11:	83 ec 0c             	sub    $0xc,%esp
f0103d14:	ff 75 18             	push   0x18(%ebp)
f0103d17:	83 eb 01             	sub    $0x1,%ebx
f0103d1a:	53                   	push   %ebx
f0103d1b:	50                   	push   %eax
f0103d1c:	83 ec 08             	sub    $0x8,%esp
f0103d1f:	ff 75 e4             	push   -0x1c(%ebp)
f0103d22:	ff 75 e0             	push   -0x20(%ebp)
f0103d25:	ff 75 d4             	push   -0x2c(%ebp)
f0103d28:	ff 75 d0             	push   -0x30(%ebp)
f0103d2b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103d2e:	e8 fd 09 00 00       	call   f0104730 <__udivdi3>
f0103d33:	83 c4 18             	add    $0x18,%esp
f0103d36:	52                   	push   %edx
f0103d37:	50                   	push   %eax
f0103d38:	89 f2                	mov    %esi,%edx
f0103d3a:	89 f8                	mov    %edi,%eax
f0103d3c:	e8 8e ff ff ff       	call   f0103ccf <printnum>
f0103d41:	83 c4 20             	add    $0x20,%esp
f0103d44:	eb 13                	jmp    f0103d59 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103d46:	83 ec 08             	sub    $0x8,%esp
f0103d49:	56                   	push   %esi
f0103d4a:	ff 75 18             	push   0x18(%ebp)
f0103d4d:	ff d7                	call   *%edi
f0103d4f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103d52:	83 eb 01             	sub    $0x1,%ebx
f0103d55:	85 db                	test   %ebx,%ebx
f0103d57:	7f ed                	jg     f0103d46 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103d59:	83 ec 08             	sub    $0x8,%esp
f0103d5c:	56                   	push   %esi
f0103d5d:	83 ec 04             	sub    $0x4,%esp
f0103d60:	ff 75 e4             	push   -0x1c(%ebp)
f0103d63:	ff 75 e0             	push   -0x20(%ebp)
f0103d66:	ff 75 d4             	push   -0x2c(%ebp)
f0103d69:	ff 75 d0             	push   -0x30(%ebp)
f0103d6c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103d6f:	e8 dc 0a 00 00       	call   f0104850 <__umoddi3>
f0103d74:	83 c4 14             	add    $0x14,%esp
f0103d77:	0f be 84 03 54 84 f8 	movsbl -0x77bac(%ebx,%eax,1),%eax
f0103d7e:	ff 
f0103d7f:	50                   	push   %eax
f0103d80:	ff d7                	call   *%edi
}
f0103d82:	83 c4 10             	add    $0x10,%esp
f0103d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d88:	5b                   	pop    %ebx
f0103d89:	5e                   	pop    %esi
f0103d8a:	5f                   	pop    %edi
f0103d8b:	5d                   	pop    %ebp
f0103d8c:	c3                   	ret    

f0103d8d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103d8d:	55                   	push   %ebp
f0103d8e:	89 e5                	mov    %esp,%ebp
f0103d90:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103d93:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103d97:	8b 10                	mov    (%eax),%edx
f0103d99:	3b 50 04             	cmp    0x4(%eax),%edx
f0103d9c:	73 0a                	jae    f0103da8 <sprintputch+0x1b>
		*b->buf++ = ch;
f0103d9e:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103da1:	89 08                	mov    %ecx,(%eax)
f0103da3:	8b 45 08             	mov    0x8(%ebp),%eax
f0103da6:	88 02                	mov    %al,(%edx)
}
f0103da8:	5d                   	pop    %ebp
f0103da9:	c3                   	ret    

f0103daa <printfmt>:
{
f0103daa:	55                   	push   %ebp
f0103dab:	89 e5                	mov    %esp,%ebp
f0103dad:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0103db0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103db3:	50                   	push   %eax
f0103db4:	ff 75 10             	push   0x10(%ebp)
f0103db7:	ff 75 0c             	push   0xc(%ebp)
f0103dba:	ff 75 08             	push   0x8(%ebp)
f0103dbd:	e8 05 00 00 00       	call   f0103dc7 <vprintfmt>
}
f0103dc2:	83 c4 10             	add    $0x10,%esp
f0103dc5:	c9                   	leave  
f0103dc6:	c3                   	ret    

f0103dc7 <vprintfmt>:
{
f0103dc7:	55                   	push   %ebp
f0103dc8:	89 e5                	mov    %esp,%ebp
f0103dca:	57                   	push   %edi
f0103dcb:	56                   	push   %esi
f0103dcc:	53                   	push   %ebx
f0103dcd:	83 ec 3c             	sub    $0x3c,%esp
f0103dd0:	e8 24 c9 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0103dd5:	05 93 9a 07 00       	add    $0x79a93,%eax
f0103dda:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103ddd:	8b 75 08             	mov    0x8(%ebp),%esi
f0103de0:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103de3:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103de6:	8d 80 48 18 00 00    	lea    0x1848(%eax),%eax
f0103dec:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0103def:	eb 0a                	jmp    f0103dfb <vprintfmt+0x34>
			putch(ch, putdat);
f0103df1:	83 ec 08             	sub    $0x8,%esp
f0103df4:	57                   	push   %edi
f0103df5:	50                   	push   %eax
f0103df6:	ff d6                	call   *%esi
f0103df8:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103dfb:	83 c3 01             	add    $0x1,%ebx
f0103dfe:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0103e02:	83 f8 25             	cmp    $0x25,%eax
f0103e05:	74 0c                	je     f0103e13 <vprintfmt+0x4c>
			if (ch == '\0')
f0103e07:	85 c0                	test   %eax,%eax
f0103e09:	75 e6                	jne    f0103df1 <vprintfmt+0x2a>
}
f0103e0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e0e:	5b                   	pop    %ebx
f0103e0f:	5e                   	pop    %esi
f0103e10:	5f                   	pop    %edi
f0103e11:	5d                   	pop    %ebp
f0103e12:	c3                   	ret    
		padc = ' ';
f0103e13:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0103e17:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0103e1e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0103e25:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f0103e2c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e31:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103e34:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103e37:	8d 43 01             	lea    0x1(%ebx),%eax
f0103e3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103e3d:	0f b6 13             	movzbl (%ebx),%edx
f0103e40:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103e43:	3c 55                	cmp    $0x55,%al
f0103e45:	0f 87 c5 03 00 00    	ja     f0104210 <.L20>
f0103e4b:	0f b6 c0             	movzbl %al,%eax
f0103e4e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103e51:	89 ce                	mov    %ecx,%esi
f0103e53:	03 b4 81 e0 84 f8 ff 	add    -0x77b20(%ecx,%eax,4),%esi
f0103e5a:	ff e6                	jmp    *%esi

f0103e5c <.L66>:
f0103e5c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0103e5f:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0103e63:	eb d2                	jmp    f0103e37 <vprintfmt+0x70>

f0103e65 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0103e65:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103e68:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0103e6c:	eb c9                	jmp    f0103e37 <vprintfmt+0x70>

f0103e6e <.L31>:
f0103e6e:	0f b6 d2             	movzbl %dl,%edx
f0103e71:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0103e74:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e79:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0103e7c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103e7f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0103e83:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0103e86:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103e89:	83 f9 09             	cmp    $0x9,%ecx
f0103e8c:	77 58                	ja     f0103ee6 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0103e8e:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0103e91:	eb e9                	jmp    f0103e7c <.L31+0xe>

f0103e93 <.L34>:
			precision = va_arg(ap, int);
f0103e93:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e96:	8b 00                	mov    (%eax),%eax
f0103e98:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e9b:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e9e:	8d 40 04             	lea    0x4(%eax),%eax
f0103ea1:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103ea4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0103ea7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0103eab:	79 8a                	jns    f0103e37 <vprintfmt+0x70>
				width = precision, precision = -1;
f0103ead:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103eb0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103eb3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0103eba:	e9 78 ff ff ff       	jmp    f0103e37 <vprintfmt+0x70>

f0103ebf <.L33>:
f0103ebf:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103ec2:	85 d2                	test   %edx,%edx
f0103ec4:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ec9:	0f 49 c2             	cmovns %edx,%eax
f0103ecc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103ecf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0103ed2:	e9 60 ff ff ff       	jmp    f0103e37 <vprintfmt+0x70>

f0103ed7 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0103ed7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0103eda:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0103ee1:	e9 51 ff ff ff       	jmp    f0103e37 <vprintfmt+0x70>
f0103ee6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103ee9:	89 75 08             	mov    %esi,0x8(%ebp)
f0103eec:	eb b9                	jmp    f0103ea7 <.L34+0x14>

f0103eee <.L27>:
			lflag++;
f0103eee:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103ef2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0103ef5:	e9 3d ff ff ff       	jmp    f0103e37 <vprintfmt+0x70>

f0103efa <.L30>:
			putch(va_arg(ap, int), putdat);
f0103efa:	8b 75 08             	mov    0x8(%ebp),%esi
f0103efd:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f00:	8d 58 04             	lea    0x4(%eax),%ebx
f0103f03:	83 ec 08             	sub    $0x8,%esp
f0103f06:	57                   	push   %edi
f0103f07:	ff 30                	push   (%eax)
f0103f09:	ff d6                	call   *%esi
			break;
f0103f0b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0103f0e:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0103f11:	e9 90 02 00 00       	jmp    f01041a6 <.L25+0x45>

f0103f16 <.L28>:
			err = va_arg(ap, int);
f0103f16:	8b 75 08             	mov    0x8(%ebp),%esi
f0103f19:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f1c:	8d 58 04             	lea    0x4(%eax),%ebx
f0103f1f:	8b 10                	mov    (%eax),%edx
f0103f21:	89 d0                	mov    %edx,%eax
f0103f23:	f7 d8                	neg    %eax
f0103f25:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103f28:	83 f8 06             	cmp    $0x6,%eax
f0103f2b:	7f 27                	jg     f0103f54 <.L28+0x3e>
f0103f2d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103f30:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0103f33:	85 d2                	test   %edx,%edx
f0103f35:	74 1d                	je     f0103f54 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f0103f37:	52                   	push   %edx
f0103f38:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f3b:	8d 80 81 7d f8 ff    	lea    -0x7827f(%eax),%eax
f0103f41:	50                   	push   %eax
f0103f42:	57                   	push   %edi
f0103f43:	56                   	push   %esi
f0103f44:	e8 61 fe ff ff       	call   f0103daa <printfmt>
f0103f49:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103f4c:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0103f4f:	e9 52 02 00 00       	jmp    f01041a6 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0103f54:	50                   	push   %eax
f0103f55:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f58:	8d 80 6c 84 f8 ff    	lea    -0x77b94(%eax),%eax
f0103f5e:	50                   	push   %eax
f0103f5f:	57                   	push   %edi
f0103f60:	56                   	push   %esi
f0103f61:	e8 44 fe ff ff       	call   f0103daa <printfmt>
f0103f66:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103f69:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0103f6c:	e9 35 02 00 00       	jmp    f01041a6 <.L25+0x45>

f0103f71 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f0103f71:	8b 75 08             	mov    0x8(%ebp),%esi
f0103f74:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f77:	83 c0 04             	add    $0x4,%eax
f0103f7a:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0103f7d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f80:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0103f82:	85 d2                	test   %edx,%edx
f0103f84:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f87:	8d 80 65 84 f8 ff    	lea    -0x77b9b(%eax),%eax
f0103f8d:	0f 45 c2             	cmovne %edx,%eax
f0103f90:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0103f93:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0103f97:	7e 06                	jle    f0103f9f <.L24+0x2e>
f0103f99:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0103f9d:	75 0d                	jne    f0103fac <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f9f:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103fa2:	89 c3                	mov    %eax,%ebx
f0103fa4:	03 45 d0             	add    -0x30(%ebp),%eax
f0103fa7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103faa:	eb 58                	jmp    f0104004 <.L24+0x93>
f0103fac:	83 ec 08             	sub    $0x8,%esp
f0103faf:	ff 75 d8             	push   -0x28(%ebp)
f0103fb2:	ff 75 c8             	push   -0x38(%ebp)
f0103fb5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103fb8:	e8 0c 04 00 00       	call   f01043c9 <strnlen>
f0103fbd:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103fc0:	29 c2                	sub    %eax,%edx
f0103fc2:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0103fc5:	83 c4 10             	add    $0x10,%esp
f0103fc8:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0103fca:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0103fce:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0103fd1:	eb 0f                	jmp    f0103fe2 <.L24+0x71>
					putch(padc, putdat);
f0103fd3:	83 ec 08             	sub    $0x8,%esp
f0103fd6:	57                   	push   %edi
f0103fd7:	ff 75 d0             	push   -0x30(%ebp)
f0103fda:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103fdc:	83 eb 01             	sub    $0x1,%ebx
f0103fdf:	83 c4 10             	add    $0x10,%esp
f0103fe2:	85 db                	test   %ebx,%ebx
f0103fe4:	7f ed                	jg     f0103fd3 <.L24+0x62>
f0103fe6:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0103fe9:	85 d2                	test   %edx,%edx
f0103feb:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ff0:	0f 49 c2             	cmovns %edx,%eax
f0103ff3:	29 c2                	sub    %eax,%edx
f0103ff5:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103ff8:	eb a5                	jmp    f0103f9f <.L24+0x2e>
					putch(ch, putdat);
f0103ffa:	83 ec 08             	sub    $0x8,%esp
f0103ffd:	57                   	push   %edi
f0103ffe:	52                   	push   %edx
f0103fff:	ff d6                	call   *%esi
f0104001:	83 c4 10             	add    $0x10,%esp
f0104004:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104007:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104009:	83 c3 01             	add    $0x1,%ebx
f010400c:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0104010:	0f be d0             	movsbl %al,%edx
f0104013:	85 d2                	test   %edx,%edx
f0104015:	74 4b                	je     f0104062 <.L24+0xf1>
f0104017:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010401b:	78 06                	js     f0104023 <.L24+0xb2>
f010401d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0104021:	78 1e                	js     f0104041 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0104023:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104027:	74 d1                	je     f0103ffa <.L24+0x89>
f0104029:	0f be c0             	movsbl %al,%eax
f010402c:	83 e8 20             	sub    $0x20,%eax
f010402f:	83 f8 5e             	cmp    $0x5e,%eax
f0104032:	76 c6                	jbe    f0103ffa <.L24+0x89>
					putch('?', putdat);
f0104034:	83 ec 08             	sub    $0x8,%esp
f0104037:	57                   	push   %edi
f0104038:	6a 3f                	push   $0x3f
f010403a:	ff d6                	call   *%esi
f010403c:	83 c4 10             	add    $0x10,%esp
f010403f:	eb c3                	jmp    f0104004 <.L24+0x93>
f0104041:	89 cb                	mov    %ecx,%ebx
f0104043:	eb 0e                	jmp    f0104053 <.L24+0xe2>
				putch(' ', putdat);
f0104045:	83 ec 08             	sub    $0x8,%esp
f0104048:	57                   	push   %edi
f0104049:	6a 20                	push   $0x20
f010404b:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010404d:	83 eb 01             	sub    $0x1,%ebx
f0104050:	83 c4 10             	add    $0x10,%esp
f0104053:	85 db                	test   %ebx,%ebx
f0104055:	7f ee                	jg     f0104045 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f0104057:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010405a:	89 45 14             	mov    %eax,0x14(%ebp)
f010405d:	e9 44 01 00 00       	jmp    f01041a6 <.L25+0x45>
f0104062:	89 cb                	mov    %ecx,%ebx
f0104064:	eb ed                	jmp    f0104053 <.L24+0xe2>

f0104066 <.L29>:
	if (lflag >= 2)
f0104066:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104069:	8b 75 08             	mov    0x8(%ebp),%esi
f010406c:	83 f9 01             	cmp    $0x1,%ecx
f010406f:	7f 1b                	jg     f010408c <.L29+0x26>
	else if (lflag)
f0104071:	85 c9                	test   %ecx,%ecx
f0104073:	74 63                	je     f01040d8 <.L29+0x72>
		return va_arg(*ap, long);
f0104075:	8b 45 14             	mov    0x14(%ebp),%eax
f0104078:	8b 00                	mov    (%eax),%eax
f010407a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010407d:	99                   	cltd   
f010407e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104081:	8b 45 14             	mov    0x14(%ebp),%eax
f0104084:	8d 40 04             	lea    0x4(%eax),%eax
f0104087:	89 45 14             	mov    %eax,0x14(%ebp)
f010408a:	eb 17                	jmp    f01040a3 <.L29+0x3d>
		return va_arg(*ap, long long);
f010408c:	8b 45 14             	mov    0x14(%ebp),%eax
f010408f:	8b 50 04             	mov    0x4(%eax),%edx
f0104092:	8b 00                	mov    (%eax),%eax
f0104094:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104097:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010409a:	8b 45 14             	mov    0x14(%ebp),%eax
f010409d:	8d 40 08             	lea    0x8(%eax),%eax
f01040a0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01040a3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01040a6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f01040a9:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f01040ae:	85 db                	test   %ebx,%ebx
f01040b0:	0f 89 d6 00 00 00    	jns    f010418c <.L25+0x2b>
				putch('-', putdat);
f01040b6:	83 ec 08             	sub    $0x8,%esp
f01040b9:	57                   	push   %edi
f01040ba:	6a 2d                	push   $0x2d
f01040bc:	ff d6                	call   *%esi
				num = -(long long) num;
f01040be:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01040c1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01040c4:	f7 d9                	neg    %ecx
f01040c6:	83 d3 00             	adc    $0x0,%ebx
f01040c9:	f7 db                	neg    %ebx
f01040cb:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01040ce:	ba 0a 00 00 00       	mov    $0xa,%edx
f01040d3:	e9 b4 00 00 00       	jmp    f010418c <.L25+0x2b>
		return va_arg(*ap, int);
f01040d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01040db:	8b 00                	mov    (%eax),%eax
f01040dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01040e0:	99                   	cltd   
f01040e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01040e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01040e7:	8d 40 04             	lea    0x4(%eax),%eax
f01040ea:	89 45 14             	mov    %eax,0x14(%ebp)
f01040ed:	eb b4                	jmp    f01040a3 <.L29+0x3d>

f01040ef <.L23>:
	if (lflag >= 2)
f01040ef:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01040f2:	8b 75 08             	mov    0x8(%ebp),%esi
f01040f5:	83 f9 01             	cmp    $0x1,%ecx
f01040f8:	7f 1b                	jg     f0104115 <.L23+0x26>
	else if (lflag)
f01040fa:	85 c9                	test   %ecx,%ecx
f01040fc:	74 2c                	je     f010412a <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f01040fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0104101:	8b 08                	mov    (%eax),%ecx
f0104103:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104108:	8d 40 04             	lea    0x4(%eax),%eax
f010410b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010410e:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f0104113:	eb 77                	jmp    f010418c <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104115:	8b 45 14             	mov    0x14(%ebp),%eax
f0104118:	8b 08                	mov    (%eax),%ecx
f010411a:	8b 58 04             	mov    0x4(%eax),%ebx
f010411d:	8d 40 08             	lea    0x8(%eax),%eax
f0104120:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104123:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f0104128:	eb 62                	jmp    f010418c <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f010412a:	8b 45 14             	mov    0x14(%ebp),%eax
f010412d:	8b 08                	mov    (%eax),%ecx
f010412f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104134:	8d 40 04             	lea    0x4(%eax),%eax
f0104137:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010413a:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f010413f:	eb 4b                	jmp    f010418c <.L25+0x2b>

f0104141 <.L26>:
			putch('X', putdat);
f0104141:	8b 75 08             	mov    0x8(%ebp),%esi
f0104144:	83 ec 08             	sub    $0x8,%esp
f0104147:	57                   	push   %edi
f0104148:	6a 58                	push   $0x58
f010414a:	ff d6                	call   *%esi
			putch('X', putdat);
f010414c:	83 c4 08             	add    $0x8,%esp
f010414f:	57                   	push   %edi
f0104150:	6a 58                	push   $0x58
f0104152:	ff d6                	call   *%esi
			putch('X', putdat);
f0104154:	83 c4 08             	add    $0x8,%esp
f0104157:	57                   	push   %edi
f0104158:	6a 58                	push   $0x58
f010415a:	ff d6                	call   *%esi
			break;
f010415c:	83 c4 10             	add    $0x10,%esp
f010415f:	eb 45                	jmp    f01041a6 <.L25+0x45>

f0104161 <.L25>:
			putch('0', putdat);
f0104161:	8b 75 08             	mov    0x8(%ebp),%esi
f0104164:	83 ec 08             	sub    $0x8,%esp
f0104167:	57                   	push   %edi
f0104168:	6a 30                	push   $0x30
f010416a:	ff d6                	call   *%esi
			putch('x', putdat);
f010416c:	83 c4 08             	add    $0x8,%esp
f010416f:	57                   	push   %edi
f0104170:	6a 78                	push   $0x78
f0104172:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104174:	8b 45 14             	mov    0x14(%ebp),%eax
f0104177:	8b 08                	mov    (%eax),%ecx
f0104179:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f010417e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104181:	8d 40 04             	lea    0x4(%eax),%eax
f0104184:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104187:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f010418c:	83 ec 0c             	sub    $0xc,%esp
f010418f:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0104193:	50                   	push   %eax
f0104194:	ff 75 d0             	push   -0x30(%ebp)
f0104197:	52                   	push   %edx
f0104198:	53                   	push   %ebx
f0104199:	51                   	push   %ecx
f010419a:	89 fa                	mov    %edi,%edx
f010419c:	89 f0                	mov    %esi,%eax
f010419e:	e8 2c fb ff ff       	call   f0103ccf <printnum>
			break;
f01041a3:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01041a6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01041a9:	e9 4d fc ff ff       	jmp    f0103dfb <vprintfmt+0x34>

f01041ae <.L21>:
	if (lflag >= 2)
f01041ae:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01041b1:	8b 75 08             	mov    0x8(%ebp),%esi
f01041b4:	83 f9 01             	cmp    $0x1,%ecx
f01041b7:	7f 1b                	jg     f01041d4 <.L21+0x26>
	else if (lflag)
f01041b9:	85 c9                	test   %ecx,%ecx
f01041bb:	74 2c                	je     f01041e9 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f01041bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01041c0:	8b 08                	mov    (%eax),%ecx
f01041c2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01041c7:	8d 40 04             	lea    0x4(%eax),%eax
f01041ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01041cd:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f01041d2:	eb b8                	jmp    f010418c <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01041d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01041d7:	8b 08                	mov    (%eax),%ecx
f01041d9:	8b 58 04             	mov    0x4(%eax),%ebx
f01041dc:	8d 40 08             	lea    0x8(%eax),%eax
f01041df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01041e2:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f01041e7:	eb a3                	jmp    f010418c <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01041e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01041ec:	8b 08                	mov    (%eax),%ecx
f01041ee:	bb 00 00 00 00       	mov    $0x0,%ebx
f01041f3:	8d 40 04             	lea    0x4(%eax),%eax
f01041f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01041f9:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f01041fe:	eb 8c                	jmp    f010418c <.L25+0x2b>

f0104200 <.L35>:
			putch(ch, putdat);
f0104200:	8b 75 08             	mov    0x8(%ebp),%esi
f0104203:	83 ec 08             	sub    $0x8,%esp
f0104206:	57                   	push   %edi
f0104207:	6a 25                	push   $0x25
f0104209:	ff d6                	call   *%esi
			break;
f010420b:	83 c4 10             	add    $0x10,%esp
f010420e:	eb 96                	jmp    f01041a6 <.L25+0x45>

f0104210 <.L20>:
			putch('%', putdat);
f0104210:	8b 75 08             	mov    0x8(%ebp),%esi
f0104213:	83 ec 08             	sub    $0x8,%esp
f0104216:	57                   	push   %edi
f0104217:	6a 25                	push   $0x25
f0104219:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010421b:	83 c4 10             	add    $0x10,%esp
f010421e:	89 d8                	mov    %ebx,%eax
f0104220:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104224:	74 05                	je     f010422b <.L20+0x1b>
f0104226:	83 e8 01             	sub    $0x1,%eax
f0104229:	eb f5                	jmp    f0104220 <.L20+0x10>
f010422b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010422e:	e9 73 ff ff ff       	jmp    f01041a6 <.L25+0x45>

f0104233 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104233:	55                   	push   %ebp
f0104234:	89 e5                	mov    %esp,%ebp
f0104236:	53                   	push   %ebx
f0104237:	83 ec 14             	sub    $0x14,%esp
f010423a:	e8 28 bf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010423f:	81 c3 29 96 07 00    	add    $0x79629,%ebx
f0104245:	8b 45 08             	mov    0x8(%ebp),%eax
f0104248:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010424b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010424e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104252:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104255:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010425c:	85 c0                	test   %eax,%eax
f010425e:	74 2b                	je     f010428b <vsnprintf+0x58>
f0104260:	85 d2                	test   %edx,%edx
f0104262:	7e 27                	jle    f010428b <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104264:	ff 75 14             	push   0x14(%ebp)
f0104267:	ff 75 10             	push   0x10(%ebp)
f010426a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010426d:	50                   	push   %eax
f010426e:	8d 83 25 65 f8 ff    	lea    -0x79adb(%ebx),%eax
f0104274:	50                   	push   %eax
f0104275:	e8 4d fb ff ff       	call   f0103dc7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010427a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010427d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104280:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104283:	83 c4 10             	add    $0x10,%esp
}
f0104286:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104289:	c9                   	leave  
f010428a:	c3                   	ret    
		return -E_INVAL;
f010428b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104290:	eb f4                	jmp    f0104286 <vsnprintf+0x53>

f0104292 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104292:	55                   	push   %ebp
f0104293:	89 e5                	mov    %esp,%ebp
f0104295:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104298:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010429b:	50                   	push   %eax
f010429c:	ff 75 10             	push   0x10(%ebp)
f010429f:	ff 75 0c             	push   0xc(%ebp)
f01042a2:	ff 75 08             	push   0x8(%ebp)
f01042a5:	e8 89 ff ff ff       	call   f0104233 <vsnprintf>
	va_end(ap);

	return rc;
}
f01042aa:	c9                   	leave  
f01042ab:	c3                   	ret    

f01042ac <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01042ac:	55                   	push   %ebp
f01042ad:	89 e5                	mov    %esp,%ebp
f01042af:	57                   	push   %edi
f01042b0:	56                   	push   %esi
f01042b1:	53                   	push   %ebx
f01042b2:	83 ec 1c             	sub    $0x1c,%esp
f01042b5:	e8 ad be ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01042ba:	81 c3 ae 95 07 00    	add    $0x795ae,%ebx
f01042c0:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01042c3:	85 c0                	test   %eax,%eax
f01042c5:	74 13                	je     f01042da <readline+0x2e>
		cprintf("%s", prompt);
f01042c7:	83 ec 08             	sub    $0x8,%esp
f01042ca:	50                   	push   %eax
f01042cb:	8d 83 81 7d f8 ff    	lea    -0x7827f(%ebx),%eax
f01042d1:	50                   	push   %eax
f01042d2:	e8 68 f2 ff ff       	call   f010353f <cprintf>
f01042d7:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01042da:	83 ec 0c             	sub    $0xc,%esp
f01042dd:	6a 00                	push   $0x0
f01042df:	e8 0f c4 ff ff       	call   f01006f3 <iscons>
f01042e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01042e7:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01042ea:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f01042ef:	8d 83 98 23 00 00    	lea    0x2398(%ebx),%eax
f01042f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01042f8:	eb 45                	jmp    f010433f <readline+0x93>
			cprintf("read error: %e\n", c);
f01042fa:	83 ec 08             	sub    $0x8,%esp
f01042fd:	50                   	push   %eax
f01042fe:	8d 83 38 86 f8 ff    	lea    -0x779c8(%ebx),%eax
f0104304:	50                   	push   %eax
f0104305:	e8 35 f2 ff ff       	call   f010353f <cprintf>
			return NULL;
f010430a:	83 c4 10             	add    $0x10,%esp
f010430d:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104312:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104315:	5b                   	pop    %ebx
f0104316:	5e                   	pop    %esi
f0104317:	5f                   	pop    %edi
f0104318:	5d                   	pop    %ebp
f0104319:	c3                   	ret    
			if (echoing)
f010431a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010431e:	75 05                	jne    f0104325 <readline+0x79>
			i--;
f0104320:	83 ef 01             	sub    $0x1,%edi
f0104323:	eb 1a                	jmp    f010433f <readline+0x93>
				cputchar('\b');
f0104325:	83 ec 0c             	sub    $0xc,%esp
f0104328:	6a 08                	push   $0x8
f010432a:	e8 a3 c3 ff ff       	call   f01006d2 <cputchar>
f010432f:	83 c4 10             	add    $0x10,%esp
f0104332:	eb ec                	jmp    f0104320 <readline+0x74>
			buf[i++] = c;
f0104334:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104337:	89 f0                	mov    %esi,%eax
f0104339:	88 04 39             	mov    %al,(%ecx,%edi,1)
f010433c:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f010433f:	e8 9e c3 ff ff       	call   f01006e2 <getchar>
f0104344:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104346:	85 c0                	test   %eax,%eax
f0104348:	78 b0                	js     f01042fa <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010434a:	83 f8 08             	cmp    $0x8,%eax
f010434d:	0f 94 c0             	sete   %al
f0104350:	83 fe 7f             	cmp    $0x7f,%esi
f0104353:	0f 94 c2             	sete   %dl
f0104356:	08 d0                	or     %dl,%al
f0104358:	74 04                	je     f010435e <readline+0xb2>
f010435a:	85 ff                	test   %edi,%edi
f010435c:	7f bc                	jg     f010431a <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010435e:	83 fe 1f             	cmp    $0x1f,%esi
f0104361:	7e 1c                	jle    f010437f <readline+0xd3>
f0104363:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0104369:	7f 14                	jg     f010437f <readline+0xd3>
			if (echoing)
f010436b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010436f:	74 c3                	je     f0104334 <readline+0x88>
				cputchar(c);
f0104371:	83 ec 0c             	sub    $0xc,%esp
f0104374:	56                   	push   %esi
f0104375:	e8 58 c3 ff ff       	call   f01006d2 <cputchar>
f010437a:	83 c4 10             	add    $0x10,%esp
f010437d:	eb b5                	jmp    f0104334 <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f010437f:	83 fe 0a             	cmp    $0xa,%esi
f0104382:	74 05                	je     f0104389 <readline+0xdd>
f0104384:	83 fe 0d             	cmp    $0xd,%esi
f0104387:	75 b6                	jne    f010433f <readline+0x93>
			if (echoing)
f0104389:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010438d:	75 13                	jne    f01043a2 <readline+0xf6>
			buf[i] = 0;
f010438f:	c6 84 3b 98 23 00 00 	movb   $0x0,0x2398(%ebx,%edi,1)
f0104396:	00 
			return buf;
f0104397:	8d 83 98 23 00 00    	lea    0x2398(%ebx),%eax
f010439d:	e9 70 ff ff ff       	jmp    f0104312 <readline+0x66>
				cputchar('\n');
f01043a2:	83 ec 0c             	sub    $0xc,%esp
f01043a5:	6a 0a                	push   $0xa
f01043a7:	e8 26 c3 ff ff       	call   f01006d2 <cputchar>
f01043ac:	83 c4 10             	add    $0x10,%esp
f01043af:	eb de                	jmp    f010438f <readline+0xe3>

f01043b1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01043b1:	55                   	push   %ebp
f01043b2:	89 e5                	mov    %esp,%ebp
f01043b4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01043b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01043bc:	eb 03                	jmp    f01043c1 <strlen+0x10>
		n++;
f01043be:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01043c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01043c5:	75 f7                	jne    f01043be <strlen+0xd>
	return n;
}
f01043c7:	5d                   	pop    %ebp
f01043c8:	c3                   	ret    

f01043c9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01043c9:	55                   	push   %ebp
f01043ca:	89 e5                	mov    %esp,%ebp
f01043cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01043cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01043d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01043d7:	eb 03                	jmp    f01043dc <strnlen+0x13>
		n++;
f01043d9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01043dc:	39 d0                	cmp    %edx,%eax
f01043de:	74 08                	je     f01043e8 <strnlen+0x1f>
f01043e0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01043e4:	75 f3                	jne    f01043d9 <strnlen+0x10>
f01043e6:	89 c2                	mov    %eax,%edx
	return n;
}
f01043e8:	89 d0                	mov    %edx,%eax
f01043ea:	5d                   	pop    %ebp
f01043eb:	c3                   	ret    

f01043ec <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01043ec:	55                   	push   %ebp
f01043ed:	89 e5                	mov    %esp,%ebp
f01043ef:	53                   	push   %ebx
f01043f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01043f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01043f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01043fb:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01043ff:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0104402:	83 c0 01             	add    $0x1,%eax
f0104405:	84 d2                	test   %dl,%dl
f0104407:	75 f2                	jne    f01043fb <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104409:	89 c8                	mov    %ecx,%eax
f010440b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010440e:	c9                   	leave  
f010440f:	c3                   	ret    

f0104410 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104410:	55                   	push   %ebp
f0104411:	89 e5                	mov    %esp,%ebp
f0104413:	53                   	push   %ebx
f0104414:	83 ec 10             	sub    $0x10,%esp
f0104417:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010441a:	53                   	push   %ebx
f010441b:	e8 91 ff ff ff       	call   f01043b1 <strlen>
f0104420:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0104423:	ff 75 0c             	push   0xc(%ebp)
f0104426:	01 d8                	add    %ebx,%eax
f0104428:	50                   	push   %eax
f0104429:	e8 be ff ff ff       	call   f01043ec <strcpy>
	return dst;
}
f010442e:	89 d8                	mov    %ebx,%eax
f0104430:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104433:	c9                   	leave  
f0104434:	c3                   	ret    

f0104435 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104435:	55                   	push   %ebp
f0104436:	89 e5                	mov    %esp,%ebp
f0104438:	56                   	push   %esi
f0104439:	53                   	push   %ebx
f010443a:	8b 75 08             	mov    0x8(%ebp),%esi
f010443d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104440:	89 f3                	mov    %esi,%ebx
f0104442:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104445:	89 f0                	mov    %esi,%eax
f0104447:	eb 0f                	jmp    f0104458 <strncpy+0x23>
		*dst++ = *src;
f0104449:	83 c0 01             	add    $0x1,%eax
f010444c:	0f b6 0a             	movzbl (%edx),%ecx
f010444f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104452:	80 f9 01             	cmp    $0x1,%cl
f0104455:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0104458:	39 d8                	cmp    %ebx,%eax
f010445a:	75 ed                	jne    f0104449 <strncpy+0x14>
	}
	return ret;
}
f010445c:	89 f0                	mov    %esi,%eax
f010445e:	5b                   	pop    %ebx
f010445f:	5e                   	pop    %esi
f0104460:	5d                   	pop    %ebp
f0104461:	c3                   	ret    

f0104462 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104462:	55                   	push   %ebp
f0104463:	89 e5                	mov    %esp,%ebp
f0104465:	56                   	push   %esi
f0104466:	53                   	push   %ebx
f0104467:	8b 75 08             	mov    0x8(%ebp),%esi
f010446a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010446d:	8b 55 10             	mov    0x10(%ebp),%edx
f0104470:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104472:	85 d2                	test   %edx,%edx
f0104474:	74 21                	je     f0104497 <strlcpy+0x35>
f0104476:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010447a:	89 f2                	mov    %esi,%edx
f010447c:	eb 09                	jmp    f0104487 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010447e:	83 c1 01             	add    $0x1,%ecx
f0104481:	83 c2 01             	add    $0x1,%edx
f0104484:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0104487:	39 c2                	cmp    %eax,%edx
f0104489:	74 09                	je     f0104494 <strlcpy+0x32>
f010448b:	0f b6 19             	movzbl (%ecx),%ebx
f010448e:	84 db                	test   %bl,%bl
f0104490:	75 ec                	jne    f010447e <strlcpy+0x1c>
f0104492:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0104494:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104497:	29 f0                	sub    %esi,%eax
}
f0104499:	5b                   	pop    %ebx
f010449a:	5e                   	pop    %esi
f010449b:	5d                   	pop    %ebp
f010449c:	c3                   	ret    

f010449d <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010449d:	55                   	push   %ebp
f010449e:	89 e5                	mov    %esp,%ebp
f01044a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01044a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01044a6:	eb 06                	jmp    f01044ae <strcmp+0x11>
		p++, q++;
f01044a8:	83 c1 01             	add    $0x1,%ecx
f01044ab:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01044ae:	0f b6 01             	movzbl (%ecx),%eax
f01044b1:	84 c0                	test   %al,%al
f01044b3:	74 04                	je     f01044b9 <strcmp+0x1c>
f01044b5:	3a 02                	cmp    (%edx),%al
f01044b7:	74 ef                	je     f01044a8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01044b9:	0f b6 c0             	movzbl %al,%eax
f01044bc:	0f b6 12             	movzbl (%edx),%edx
f01044bf:	29 d0                	sub    %edx,%eax
}
f01044c1:	5d                   	pop    %ebp
f01044c2:	c3                   	ret    

f01044c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01044c3:	55                   	push   %ebp
f01044c4:	89 e5                	mov    %esp,%ebp
f01044c6:	53                   	push   %ebx
f01044c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01044ca:	8b 55 0c             	mov    0xc(%ebp),%edx
f01044cd:	89 c3                	mov    %eax,%ebx
f01044cf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01044d2:	eb 06                	jmp    f01044da <strncmp+0x17>
		n--, p++, q++;
f01044d4:	83 c0 01             	add    $0x1,%eax
f01044d7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01044da:	39 d8                	cmp    %ebx,%eax
f01044dc:	74 18                	je     f01044f6 <strncmp+0x33>
f01044de:	0f b6 08             	movzbl (%eax),%ecx
f01044e1:	84 c9                	test   %cl,%cl
f01044e3:	74 04                	je     f01044e9 <strncmp+0x26>
f01044e5:	3a 0a                	cmp    (%edx),%cl
f01044e7:	74 eb                	je     f01044d4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01044e9:	0f b6 00             	movzbl (%eax),%eax
f01044ec:	0f b6 12             	movzbl (%edx),%edx
f01044ef:	29 d0                	sub    %edx,%eax
}
f01044f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01044f4:	c9                   	leave  
f01044f5:	c3                   	ret    
		return 0;
f01044f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01044fb:	eb f4                	jmp    f01044f1 <strncmp+0x2e>

f01044fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01044fd:	55                   	push   %ebp
f01044fe:	89 e5                	mov    %esp,%ebp
f0104500:	8b 45 08             	mov    0x8(%ebp),%eax
f0104503:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104507:	eb 03                	jmp    f010450c <strchr+0xf>
f0104509:	83 c0 01             	add    $0x1,%eax
f010450c:	0f b6 10             	movzbl (%eax),%edx
f010450f:	84 d2                	test   %dl,%dl
f0104511:	74 06                	je     f0104519 <strchr+0x1c>
		if (*s == c)
f0104513:	38 ca                	cmp    %cl,%dl
f0104515:	75 f2                	jne    f0104509 <strchr+0xc>
f0104517:	eb 05                	jmp    f010451e <strchr+0x21>
			return (char *) s;
	return 0;
f0104519:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010451e:	5d                   	pop    %ebp
f010451f:	c3                   	ret    

f0104520 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104520:	55                   	push   %ebp
f0104521:	89 e5                	mov    %esp,%ebp
f0104523:	8b 45 08             	mov    0x8(%ebp),%eax
f0104526:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010452a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010452d:	38 ca                	cmp    %cl,%dl
f010452f:	74 09                	je     f010453a <strfind+0x1a>
f0104531:	84 d2                	test   %dl,%dl
f0104533:	74 05                	je     f010453a <strfind+0x1a>
	for (; *s; s++)
f0104535:	83 c0 01             	add    $0x1,%eax
f0104538:	eb f0                	jmp    f010452a <strfind+0xa>
			break;
	return (char *) s;
}
f010453a:	5d                   	pop    %ebp
f010453b:	c3                   	ret    

f010453c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010453c:	55                   	push   %ebp
f010453d:	89 e5                	mov    %esp,%ebp
f010453f:	57                   	push   %edi
f0104540:	56                   	push   %esi
f0104541:	53                   	push   %ebx
f0104542:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104545:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104548:	85 c9                	test   %ecx,%ecx
f010454a:	74 2f                	je     f010457b <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010454c:	89 f8                	mov    %edi,%eax
f010454e:	09 c8                	or     %ecx,%eax
f0104550:	a8 03                	test   $0x3,%al
f0104552:	75 21                	jne    f0104575 <memset+0x39>
		c &= 0xFF;
f0104554:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104558:	89 d0                	mov    %edx,%eax
f010455a:	c1 e0 08             	shl    $0x8,%eax
f010455d:	89 d3                	mov    %edx,%ebx
f010455f:	c1 e3 18             	shl    $0x18,%ebx
f0104562:	89 d6                	mov    %edx,%esi
f0104564:	c1 e6 10             	shl    $0x10,%esi
f0104567:	09 f3                	or     %esi,%ebx
f0104569:	09 da                	or     %ebx,%edx
f010456b:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010456d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104570:	fc                   	cld    
f0104571:	f3 ab                	rep stos %eax,%es:(%edi)
f0104573:	eb 06                	jmp    f010457b <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104575:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104578:	fc                   	cld    
f0104579:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010457b:	89 f8                	mov    %edi,%eax
f010457d:	5b                   	pop    %ebx
f010457e:	5e                   	pop    %esi
f010457f:	5f                   	pop    %edi
f0104580:	5d                   	pop    %ebp
f0104581:	c3                   	ret    

f0104582 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104582:	55                   	push   %ebp
f0104583:	89 e5                	mov    %esp,%ebp
f0104585:	57                   	push   %edi
f0104586:	56                   	push   %esi
f0104587:	8b 45 08             	mov    0x8(%ebp),%eax
f010458a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010458d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104590:	39 c6                	cmp    %eax,%esi
f0104592:	73 32                	jae    f01045c6 <memmove+0x44>
f0104594:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104597:	39 c2                	cmp    %eax,%edx
f0104599:	76 2b                	jbe    f01045c6 <memmove+0x44>
		s += n;
		d += n;
f010459b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010459e:	89 d6                	mov    %edx,%esi
f01045a0:	09 fe                	or     %edi,%esi
f01045a2:	09 ce                	or     %ecx,%esi
f01045a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01045aa:	75 0e                	jne    f01045ba <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01045ac:	83 ef 04             	sub    $0x4,%edi
f01045af:	8d 72 fc             	lea    -0x4(%edx),%esi
f01045b2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01045b5:	fd                   	std    
f01045b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01045b8:	eb 09                	jmp    f01045c3 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01045ba:	83 ef 01             	sub    $0x1,%edi
f01045bd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01045c0:	fd                   	std    
f01045c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01045c3:	fc                   	cld    
f01045c4:	eb 1a                	jmp    f01045e0 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01045c6:	89 f2                	mov    %esi,%edx
f01045c8:	09 c2                	or     %eax,%edx
f01045ca:	09 ca                	or     %ecx,%edx
f01045cc:	f6 c2 03             	test   $0x3,%dl
f01045cf:	75 0a                	jne    f01045db <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01045d1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01045d4:	89 c7                	mov    %eax,%edi
f01045d6:	fc                   	cld    
f01045d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01045d9:	eb 05                	jmp    f01045e0 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f01045db:	89 c7                	mov    %eax,%edi
f01045dd:	fc                   	cld    
f01045de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01045e0:	5e                   	pop    %esi
f01045e1:	5f                   	pop    %edi
f01045e2:	5d                   	pop    %ebp
f01045e3:	c3                   	ret    

f01045e4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01045e4:	55                   	push   %ebp
f01045e5:	89 e5                	mov    %esp,%ebp
f01045e7:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01045ea:	ff 75 10             	push   0x10(%ebp)
f01045ed:	ff 75 0c             	push   0xc(%ebp)
f01045f0:	ff 75 08             	push   0x8(%ebp)
f01045f3:	e8 8a ff ff ff       	call   f0104582 <memmove>
}
f01045f8:	c9                   	leave  
f01045f9:	c3                   	ret    

f01045fa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01045fa:	55                   	push   %ebp
f01045fb:	89 e5                	mov    %esp,%ebp
f01045fd:	56                   	push   %esi
f01045fe:	53                   	push   %ebx
f01045ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0104602:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104605:	89 c6                	mov    %eax,%esi
f0104607:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010460a:	eb 06                	jmp    f0104612 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010460c:	83 c0 01             	add    $0x1,%eax
f010460f:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0104612:	39 f0                	cmp    %esi,%eax
f0104614:	74 14                	je     f010462a <memcmp+0x30>
		if (*s1 != *s2)
f0104616:	0f b6 08             	movzbl (%eax),%ecx
f0104619:	0f b6 1a             	movzbl (%edx),%ebx
f010461c:	38 d9                	cmp    %bl,%cl
f010461e:	74 ec                	je     f010460c <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0104620:	0f b6 c1             	movzbl %cl,%eax
f0104623:	0f b6 db             	movzbl %bl,%ebx
f0104626:	29 d8                	sub    %ebx,%eax
f0104628:	eb 05                	jmp    f010462f <memcmp+0x35>
	}

	return 0;
f010462a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010462f:	5b                   	pop    %ebx
f0104630:	5e                   	pop    %esi
f0104631:	5d                   	pop    %ebp
f0104632:	c3                   	ret    

f0104633 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104633:	55                   	push   %ebp
f0104634:	89 e5                	mov    %esp,%ebp
f0104636:	8b 45 08             	mov    0x8(%ebp),%eax
f0104639:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010463c:	89 c2                	mov    %eax,%edx
f010463e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104641:	eb 03                	jmp    f0104646 <memfind+0x13>
f0104643:	83 c0 01             	add    $0x1,%eax
f0104646:	39 d0                	cmp    %edx,%eax
f0104648:	73 04                	jae    f010464e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010464a:	38 08                	cmp    %cl,(%eax)
f010464c:	75 f5                	jne    f0104643 <memfind+0x10>
			break;
	return (void *) s;
}
f010464e:	5d                   	pop    %ebp
f010464f:	c3                   	ret    

f0104650 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104650:	55                   	push   %ebp
f0104651:	89 e5                	mov    %esp,%ebp
f0104653:	57                   	push   %edi
f0104654:	56                   	push   %esi
f0104655:	53                   	push   %ebx
f0104656:	8b 55 08             	mov    0x8(%ebp),%edx
f0104659:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010465c:	eb 03                	jmp    f0104661 <strtol+0x11>
		s++;
f010465e:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0104661:	0f b6 02             	movzbl (%edx),%eax
f0104664:	3c 20                	cmp    $0x20,%al
f0104666:	74 f6                	je     f010465e <strtol+0xe>
f0104668:	3c 09                	cmp    $0x9,%al
f010466a:	74 f2                	je     f010465e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010466c:	3c 2b                	cmp    $0x2b,%al
f010466e:	74 2a                	je     f010469a <strtol+0x4a>
	int neg = 0;
f0104670:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0104675:	3c 2d                	cmp    $0x2d,%al
f0104677:	74 2b                	je     f01046a4 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104679:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010467f:	75 0f                	jne    f0104690 <strtol+0x40>
f0104681:	80 3a 30             	cmpb   $0x30,(%edx)
f0104684:	74 28                	je     f01046ae <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104686:	85 db                	test   %ebx,%ebx
f0104688:	b8 0a 00 00 00       	mov    $0xa,%eax
f010468d:	0f 44 d8             	cmove  %eax,%ebx
f0104690:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104695:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104698:	eb 46                	jmp    f01046e0 <strtol+0x90>
		s++;
f010469a:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f010469d:	bf 00 00 00 00       	mov    $0x0,%edi
f01046a2:	eb d5                	jmp    f0104679 <strtol+0x29>
		s++, neg = 1;
f01046a4:	83 c2 01             	add    $0x1,%edx
f01046a7:	bf 01 00 00 00       	mov    $0x1,%edi
f01046ac:	eb cb                	jmp    f0104679 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01046ae:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01046b2:	74 0e                	je     f01046c2 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f01046b4:	85 db                	test   %ebx,%ebx
f01046b6:	75 d8                	jne    f0104690 <strtol+0x40>
		s++, base = 8;
f01046b8:	83 c2 01             	add    $0x1,%edx
f01046bb:	bb 08 00 00 00       	mov    $0x8,%ebx
f01046c0:	eb ce                	jmp    f0104690 <strtol+0x40>
		s += 2, base = 16;
f01046c2:	83 c2 02             	add    $0x2,%edx
f01046c5:	bb 10 00 00 00       	mov    $0x10,%ebx
f01046ca:	eb c4                	jmp    f0104690 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01046cc:	0f be c0             	movsbl %al,%eax
f01046cf:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01046d2:	3b 45 10             	cmp    0x10(%ebp),%eax
f01046d5:	7d 3a                	jge    f0104711 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f01046d7:	83 c2 01             	add    $0x1,%edx
f01046da:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f01046de:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f01046e0:	0f b6 02             	movzbl (%edx),%eax
f01046e3:	8d 70 d0             	lea    -0x30(%eax),%esi
f01046e6:	89 f3                	mov    %esi,%ebx
f01046e8:	80 fb 09             	cmp    $0x9,%bl
f01046eb:	76 df                	jbe    f01046cc <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f01046ed:	8d 70 9f             	lea    -0x61(%eax),%esi
f01046f0:	89 f3                	mov    %esi,%ebx
f01046f2:	80 fb 19             	cmp    $0x19,%bl
f01046f5:	77 08                	ja     f01046ff <strtol+0xaf>
			dig = *s - 'a' + 10;
f01046f7:	0f be c0             	movsbl %al,%eax
f01046fa:	83 e8 57             	sub    $0x57,%eax
f01046fd:	eb d3                	jmp    f01046d2 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f01046ff:	8d 70 bf             	lea    -0x41(%eax),%esi
f0104702:	89 f3                	mov    %esi,%ebx
f0104704:	80 fb 19             	cmp    $0x19,%bl
f0104707:	77 08                	ja     f0104711 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0104709:	0f be c0             	movsbl %al,%eax
f010470c:	83 e8 37             	sub    $0x37,%eax
f010470f:	eb c1                	jmp    f01046d2 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104711:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104715:	74 05                	je     f010471c <strtol+0xcc>
		*endptr = (char *) s;
f0104717:	8b 45 0c             	mov    0xc(%ebp),%eax
f010471a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f010471c:	89 c8                	mov    %ecx,%eax
f010471e:	f7 d8                	neg    %eax
f0104720:	85 ff                	test   %edi,%edi
f0104722:	0f 45 c8             	cmovne %eax,%ecx
}
f0104725:	89 c8                	mov    %ecx,%eax
f0104727:	5b                   	pop    %ebx
f0104728:	5e                   	pop    %esi
f0104729:	5f                   	pop    %edi
f010472a:	5d                   	pop    %ebp
f010472b:	c3                   	ret    
f010472c:	66 90                	xchg   %ax,%ax
f010472e:	66 90                	xchg   %ax,%ax

f0104730 <__udivdi3>:
f0104730:	f3 0f 1e fb          	endbr32 
f0104734:	55                   	push   %ebp
f0104735:	57                   	push   %edi
f0104736:	56                   	push   %esi
f0104737:	53                   	push   %ebx
f0104738:	83 ec 1c             	sub    $0x1c,%esp
f010473b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010473f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0104743:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104747:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010474b:	85 c0                	test   %eax,%eax
f010474d:	75 19                	jne    f0104768 <__udivdi3+0x38>
f010474f:	39 f3                	cmp    %esi,%ebx
f0104751:	76 4d                	jbe    f01047a0 <__udivdi3+0x70>
f0104753:	31 ff                	xor    %edi,%edi
f0104755:	89 e8                	mov    %ebp,%eax
f0104757:	89 f2                	mov    %esi,%edx
f0104759:	f7 f3                	div    %ebx
f010475b:	89 fa                	mov    %edi,%edx
f010475d:	83 c4 1c             	add    $0x1c,%esp
f0104760:	5b                   	pop    %ebx
f0104761:	5e                   	pop    %esi
f0104762:	5f                   	pop    %edi
f0104763:	5d                   	pop    %ebp
f0104764:	c3                   	ret    
f0104765:	8d 76 00             	lea    0x0(%esi),%esi
f0104768:	39 f0                	cmp    %esi,%eax
f010476a:	76 14                	jbe    f0104780 <__udivdi3+0x50>
f010476c:	31 ff                	xor    %edi,%edi
f010476e:	31 c0                	xor    %eax,%eax
f0104770:	89 fa                	mov    %edi,%edx
f0104772:	83 c4 1c             	add    $0x1c,%esp
f0104775:	5b                   	pop    %ebx
f0104776:	5e                   	pop    %esi
f0104777:	5f                   	pop    %edi
f0104778:	5d                   	pop    %ebp
f0104779:	c3                   	ret    
f010477a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104780:	0f bd f8             	bsr    %eax,%edi
f0104783:	83 f7 1f             	xor    $0x1f,%edi
f0104786:	75 48                	jne    f01047d0 <__udivdi3+0xa0>
f0104788:	39 f0                	cmp    %esi,%eax
f010478a:	72 06                	jb     f0104792 <__udivdi3+0x62>
f010478c:	31 c0                	xor    %eax,%eax
f010478e:	39 eb                	cmp    %ebp,%ebx
f0104790:	77 de                	ja     f0104770 <__udivdi3+0x40>
f0104792:	b8 01 00 00 00       	mov    $0x1,%eax
f0104797:	eb d7                	jmp    f0104770 <__udivdi3+0x40>
f0104799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01047a0:	89 d9                	mov    %ebx,%ecx
f01047a2:	85 db                	test   %ebx,%ebx
f01047a4:	75 0b                	jne    f01047b1 <__udivdi3+0x81>
f01047a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01047ab:	31 d2                	xor    %edx,%edx
f01047ad:	f7 f3                	div    %ebx
f01047af:	89 c1                	mov    %eax,%ecx
f01047b1:	31 d2                	xor    %edx,%edx
f01047b3:	89 f0                	mov    %esi,%eax
f01047b5:	f7 f1                	div    %ecx
f01047b7:	89 c6                	mov    %eax,%esi
f01047b9:	89 e8                	mov    %ebp,%eax
f01047bb:	89 f7                	mov    %esi,%edi
f01047bd:	f7 f1                	div    %ecx
f01047bf:	89 fa                	mov    %edi,%edx
f01047c1:	83 c4 1c             	add    $0x1c,%esp
f01047c4:	5b                   	pop    %ebx
f01047c5:	5e                   	pop    %esi
f01047c6:	5f                   	pop    %edi
f01047c7:	5d                   	pop    %ebp
f01047c8:	c3                   	ret    
f01047c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01047d0:	89 f9                	mov    %edi,%ecx
f01047d2:	ba 20 00 00 00       	mov    $0x20,%edx
f01047d7:	29 fa                	sub    %edi,%edx
f01047d9:	d3 e0                	shl    %cl,%eax
f01047db:	89 44 24 08          	mov    %eax,0x8(%esp)
f01047df:	89 d1                	mov    %edx,%ecx
f01047e1:	89 d8                	mov    %ebx,%eax
f01047e3:	d3 e8                	shr    %cl,%eax
f01047e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01047e9:	09 c1                	or     %eax,%ecx
f01047eb:	89 f0                	mov    %esi,%eax
f01047ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01047f1:	89 f9                	mov    %edi,%ecx
f01047f3:	d3 e3                	shl    %cl,%ebx
f01047f5:	89 d1                	mov    %edx,%ecx
f01047f7:	d3 e8                	shr    %cl,%eax
f01047f9:	89 f9                	mov    %edi,%ecx
f01047fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01047ff:	89 eb                	mov    %ebp,%ebx
f0104801:	d3 e6                	shl    %cl,%esi
f0104803:	89 d1                	mov    %edx,%ecx
f0104805:	d3 eb                	shr    %cl,%ebx
f0104807:	09 f3                	or     %esi,%ebx
f0104809:	89 c6                	mov    %eax,%esi
f010480b:	89 f2                	mov    %esi,%edx
f010480d:	89 d8                	mov    %ebx,%eax
f010480f:	f7 74 24 08          	divl   0x8(%esp)
f0104813:	89 d6                	mov    %edx,%esi
f0104815:	89 c3                	mov    %eax,%ebx
f0104817:	f7 64 24 0c          	mull   0xc(%esp)
f010481b:	39 d6                	cmp    %edx,%esi
f010481d:	72 19                	jb     f0104838 <__udivdi3+0x108>
f010481f:	89 f9                	mov    %edi,%ecx
f0104821:	d3 e5                	shl    %cl,%ebp
f0104823:	39 c5                	cmp    %eax,%ebp
f0104825:	73 04                	jae    f010482b <__udivdi3+0xfb>
f0104827:	39 d6                	cmp    %edx,%esi
f0104829:	74 0d                	je     f0104838 <__udivdi3+0x108>
f010482b:	89 d8                	mov    %ebx,%eax
f010482d:	31 ff                	xor    %edi,%edi
f010482f:	e9 3c ff ff ff       	jmp    f0104770 <__udivdi3+0x40>
f0104834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104838:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010483b:	31 ff                	xor    %edi,%edi
f010483d:	e9 2e ff ff ff       	jmp    f0104770 <__udivdi3+0x40>
f0104842:	66 90                	xchg   %ax,%ax
f0104844:	66 90                	xchg   %ax,%ax
f0104846:	66 90                	xchg   %ax,%ax
f0104848:	66 90                	xchg   %ax,%ax
f010484a:	66 90                	xchg   %ax,%ax
f010484c:	66 90                	xchg   %ax,%ax
f010484e:	66 90                	xchg   %ax,%ax

f0104850 <__umoddi3>:
f0104850:	f3 0f 1e fb          	endbr32 
f0104854:	55                   	push   %ebp
f0104855:	57                   	push   %edi
f0104856:	56                   	push   %esi
f0104857:	53                   	push   %ebx
f0104858:	83 ec 1c             	sub    $0x1c,%esp
f010485b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010485f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0104863:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0104867:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f010486b:	89 f0                	mov    %esi,%eax
f010486d:	89 da                	mov    %ebx,%edx
f010486f:	85 ff                	test   %edi,%edi
f0104871:	75 15                	jne    f0104888 <__umoddi3+0x38>
f0104873:	39 dd                	cmp    %ebx,%ebp
f0104875:	76 39                	jbe    f01048b0 <__umoddi3+0x60>
f0104877:	f7 f5                	div    %ebp
f0104879:	89 d0                	mov    %edx,%eax
f010487b:	31 d2                	xor    %edx,%edx
f010487d:	83 c4 1c             	add    $0x1c,%esp
f0104880:	5b                   	pop    %ebx
f0104881:	5e                   	pop    %esi
f0104882:	5f                   	pop    %edi
f0104883:	5d                   	pop    %ebp
f0104884:	c3                   	ret    
f0104885:	8d 76 00             	lea    0x0(%esi),%esi
f0104888:	39 df                	cmp    %ebx,%edi
f010488a:	77 f1                	ja     f010487d <__umoddi3+0x2d>
f010488c:	0f bd cf             	bsr    %edi,%ecx
f010488f:	83 f1 1f             	xor    $0x1f,%ecx
f0104892:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104896:	75 40                	jne    f01048d8 <__umoddi3+0x88>
f0104898:	39 df                	cmp    %ebx,%edi
f010489a:	72 04                	jb     f01048a0 <__umoddi3+0x50>
f010489c:	39 f5                	cmp    %esi,%ebp
f010489e:	77 dd                	ja     f010487d <__umoddi3+0x2d>
f01048a0:	89 da                	mov    %ebx,%edx
f01048a2:	89 f0                	mov    %esi,%eax
f01048a4:	29 e8                	sub    %ebp,%eax
f01048a6:	19 fa                	sbb    %edi,%edx
f01048a8:	eb d3                	jmp    f010487d <__umoddi3+0x2d>
f01048aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01048b0:	89 e9                	mov    %ebp,%ecx
f01048b2:	85 ed                	test   %ebp,%ebp
f01048b4:	75 0b                	jne    f01048c1 <__umoddi3+0x71>
f01048b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01048bb:	31 d2                	xor    %edx,%edx
f01048bd:	f7 f5                	div    %ebp
f01048bf:	89 c1                	mov    %eax,%ecx
f01048c1:	89 d8                	mov    %ebx,%eax
f01048c3:	31 d2                	xor    %edx,%edx
f01048c5:	f7 f1                	div    %ecx
f01048c7:	89 f0                	mov    %esi,%eax
f01048c9:	f7 f1                	div    %ecx
f01048cb:	89 d0                	mov    %edx,%eax
f01048cd:	31 d2                	xor    %edx,%edx
f01048cf:	eb ac                	jmp    f010487d <__umoddi3+0x2d>
f01048d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01048d8:	8b 44 24 04          	mov    0x4(%esp),%eax
f01048dc:	ba 20 00 00 00       	mov    $0x20,%edx
f01048e1:	29 c2                	sub    %eax,%edx
f01048e3:	89 c1                	mov    %eax,%ecx
f01048e5:	89 e8                	mov    %ebp,%eax
f01048e7:	d3 e7                	shl    %cl,%edi
f01048e9:	89 d1                	mov    %edx,%ecx
f01048eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01048ef:	d3 e8                	shr    %cl,%eax
f01048f1:	89 c1                	mov    %eax,%ecx
f01048f3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01048f7:	09 f9                	or     %edi,%ecx
f01048f9:	89 df                	mov    %ebx,%edi
f01048fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01048ff:	89 c1                	mov    %eax,%ecx
f0104901:	d3 e5                	shl    %cl,%ebp
f0104903:	89 d1                	mov    %edx,%ecx
f0104905:	d3 ef                	shr    %cl,%edi
f0104907:	89 c1                	mov    %eax,%ecx
f0104909:	89 f0                	mov    %esi,%eax
f010490b:	d3 e3                	shl    %cl,%ebx
f010490d:	89 d1                	mov    %edx,%ecx
f010490f:	89 fa                	mov    %edi,%edx
f0104911:	d3 e8                	shr    %cl,%eax
f0104913:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104918:	09 d8                	or     %ebx,%eax
f010491a:	f7 74 24 08          	divl   0x8(%esp)
f010491e:	89 d3                	mov    %edx,%ebx
f0104920:	d3 e6                	shl    %cl,%esi
f0104922:	f7 e5                	mul    %ebp
f0104924:	89 c7                	mov    %eax,%edi
f0104926:	89 d1                	mov    %edx,%ecx
f0104928:	39 d3                	cmp    %edx,%ebx
f010492a:	72 06                	jb     f0104932 <__umoddi3+0xe2>
f010492c:	75 0e                	jne    f010493c <__umoddi3+0xec>
f010492e:	39 c6                	cmp    %eax,%esi
f0104930:	73 0a                	jae    f010493c <__umoddi3+0xec>
f0104932:	29 e8                	sub    %ebp,%eax
f0104934:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0104938:	89 d1                	mov    %edx,%ecx
f010493a:	89 c7                	mov    %eax,%edi
f010493c:	89 f5                	mov    %esi,%ebp
f010493e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104942:	29 fd                	sub    %edi,%ebp
f0104944:	19 cb                	sbb    %ecx,%ebx
f0104946:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f010494b:	89 d8                	mov    %ebx,%eax
f010494d:	d3 e0                	shl    %cl,%eax
f010494f:	89 f1                	mov    %esi,%ecx
f0104951:	d3 ed                	shr    %cl,%ebp
f0104953:	d3 eb                	shr    %cl,%ebx
f0104955:	09 e8                	or     %ebp,%eax
f0104957:	89 da                	mov    %ebx,%edx
f0104959:	83 c4 1c             	add    $0x1c,%esp
f010495c:	5b                   	pop    %ebx
f010495d:	5e                   	pop    %esi
f010495e:	5f                   	pop    %edi
f010495f:	5d                   	pop    %ebp
f0104960:	c3                   	ret    
