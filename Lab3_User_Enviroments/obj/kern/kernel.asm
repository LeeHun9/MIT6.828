
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
f0100015:	b8 00 f0 17 00       	mov    $0x17f000,%eax
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
f0100034:	bc 00 a0 11 f0       	mov    $0xf011a000,%esp

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
f010004c:	81 c3 1c e8 07 00    	add    $0x7e81c,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 00 10 18 f0    	mov    $0xf0181000,%eax
f0100058:	c7 c2 e0 00 18 f0    	mov    $0xf01800e0,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 90 48 00 00       	call   f01048f9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 4f 05 00 00       	call   f01005bd <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 d8 64 f8 ff    	lea    -0x79b28(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 7a 38 00 00       	call   f01038fc <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 16 12 00 00       	call   f010129d <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 7b 31 00 00       	call   f0103207 <env_init>
	trap_init();
f010008c:	e8 1e 39 00 00       	call   f01039af <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100091:	83 c4 08             	add    $0x8,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 f4 ff ff ff    	push   -0xc(%ebx)
f010009c:	e8 68 33 00 00       	call   f0103409 <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a1:	83 c4 04             	add    $0x4,%esp
f01000a4:	c7 c0 54 03 18 f0    	mov    $0xf0180354,%eax
f01000aa:	ff 30                	push   (%eax)
f01000ac:	e8 4f 37 00 00       	call   f0103800 <env_run>

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
f01000bb:	81 c3 ad e7 07 00    	add    $0x7e7ad,%ebx
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
f01000f0:	8d 83 f3 64 f8 ff    	lea    -0x79b0d(%ebx),%eax
f01000f6:	50                   	push   %eax
f01000f7:	e8 00 38 00 00       	call   f01038fc <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	56                   	push   %esi
f0100100:	ff 75 10             	push   0x10(%ebp)
f0100103:	e8 bd 37 00 00       	call   f01038c5 <vcprintf>
	cprintf("\n");
f0100108:	8d 83 ba 73 f8 ff    	lea    -0x78c46(%ebx),%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 e6 37 00 00       	call   f01038fc <cprintf>
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
f0100125:	81 c3 43 e7 07 00    	add    $0x7e743,%ebx
	va_list ap;

	va_start(ap, fmt);
f010012b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010012e:	83 ec 04             	sub    $0x4,%esp
f0100131:	ff 75 0c             	push   0xc(%ebp)
f0100134:	ff 75 08             	push   0x8(%ebp)
f0100137:	8d 83 0b 65 f8 ff    	lea    -0x79af5(%ebx),%eax
f010013d:	50                   	push   %eax
f010013e:	e8 b9 37 00 00       	call   f01038fc <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	56                   	push   %esi
f0100147:	ff 75 10             	push   0x10(%ebp)
f010014a:	e8 76 37 00 00       	call   f01038c5 <vcprintf>
	cprintf("\n");
f010014f:	8d 83 ba 73 f8 ff    	lea    -0x78c46(%ebx),%eax
f0100155:	89 04 24             	mov    %eax,(%esp)
f0100158:	e8 9f 37 00 00       	call   f01038fc <cprintf>
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
f0100193:	81 c6 d5 e6 07 00    	add    $0x7e6d5,%esi
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
f01001f3:	81 c3 75 e6 07 00    	add    $0x7e675,%ebx
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
f010023b:	0f b6 84 13 58 66 f8 	movzbl -0x799a8(%ebx,%edx,1),%eax
f0100242:	ff 
f0100243:	0b 83 98 18 00 00    	or     0x1898(%ebx),%eax
	shift ^= togglecode[data];
f0100249:	0f b6 8c 13 58 65 f8 	movzbl -0x79aa8(%ebx,%edx,1),%ecx
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
f01002a6:	0f b6 84 13 58 66 f8 	movzbl -0x799a8(%ebx,%edx,1),%eax
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
f01002e2:	8d 83 25 65 f8 ff    	lea    -0x79adb(%ebx),%eax
f01002e8:	50                   	push   %eax
f01002e9:	e8 0e 36 00 00       	call   f01038fc <cprintf>
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
f010031d:	81 c3 4b e5 07 00    	add    $0x7e54b,%ebx
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
f01004f2:	e8 48 44 00 00       	call   f010493f <memmove>
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
f010052a:	05 3e e3 07 00       	add    $0x7e33e,%eax
	if (serial_exists)
f010052f:	80 b8 cc 1a 00 00 00 	cmpb   $0x0,0x1acc(%eax)
f0100536:	75 01                	jne    f0100539 <serial_intr+0x14>
f0100538:	c3                   	ret    
{
f0100539:	55                   	push   %ebp
f010053a:	89 e5                	mov    %esp,%ebp
f010053c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010053f:	8d 80 03 19 f8 ff    	lea    -0x7e6fd(%eax),%eax
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
f0100557:	05 11 e3 07 00       	add    $0x7e311,%eax
	cons_intr(kbd_proc_data);
f010055c:	8d 80 81 19 f8 ff    	lea    -0x7e67f(%eax),%eax
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
f0100575:	81 c3 f3 e2 07 00    	add    $0x7e2f3,%ebx
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
f01005cb:	81 c3 9d e2 07 00    	add    $0x7e29d,%ebx
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
f01006c1:	8d 83 31 65 f8 ff    	lea    -0x79acf(%ebx),%eax
f01006c7:	50                   	push   %eax
f01006c8:	e8 2f 32 00 00       	call   f01038fc <cprintf>
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
f010070b:	81 c3 5d e1 07 00    	add    $0x7e15d,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100711:	83 ec 04             	sub    $0x4,%esp
f0100714:	8d 83 58 67 f8 ff    	lea    -0x798a8(%ebx),%eax
f010071a:	50                   	push   %eax
f010071b:	8d 83 76 67 f8 ff    	lea    -0x7988a(%ebx),%eax
f0100721:	50                   	push   %eax
f0100722:	8d b3 7b 67 f8 ff    	lea    -0x79885(%ebx),%esi
f0100728:	56                   	push   %esi
f0100729:	e8 ce 31 00 00       	call   f01038fc <cprintf>
f010072e:	83 c4 0c             	add    $0xc,%esp
f0100731:	8d 83 e4 67 f8 ff    	lea    -0x7981c(%ebx),%eax
f0100737:	50                   	push   %eax
f0100738:	8d 83 84 67 f8 ff    	lea    -0x7987c(%ebx),%eax
f010073e:	50                   	push   %eax
f010073f:	56                   	push   %esi
f0100740:	e8 b7 31 00 00       	call   f01038fc <cprintf>
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
f010075f:	81 c3 09 e1 07 00    	add    $0x7e109,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100765:	8d 83 8d 67 f8 ff    	lea    -0x79873(%ebx),%eax
f010076b:	50                   	push   %eax
f010076c:	e8 8b 31 00 00       	call   f01038fc <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100771:	83 c4 08             	add    $0x8,%esp
f0100774:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f010077a:	8d 83 0c 68 f8 ff    	lea    -0x797f4(%ebx),%eax
f0100780:	50                   	push   %eax
f0100781:	e8 76 31 00 00       	call   f01038fc <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100786:	83 c4 0c             	add    $0xc,%esp
f0100789:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010078f:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100795:	50                   	push   %eax
f0100796:	57                   	push   %edi
f0100797:	8d 83 34 68 f8 ff    	lea    -0x797cc(%ebx),%eax
f010079d:	50                   	push   %eax
f010079e:	e8 59 31 00 00       	call   f01038fc <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007a3:	83 c4 0c             	add    $0xc,%esp
f01007a6:	c7 c0 21 4d 10 f0    	mov    $0xf0104d21,%eax
f01007ac:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007b2:	52                   	push   %edx
f01007b3:	50                   	push   %eax
f01007b4:	8d 83 58 68 f8 ff    	lea    -0x797a8(%ebx),%eax
f01007ba:	50                   	push   %eax
f01007bb:	e8 3c 31 00 00       	call   f01038fc <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007c0:	83 c4 0c             	add    $0xc,%esp
f01007c3:	c7 c0 e0 00 18 f0    	mov    $0xf01800e0,%eax
f01007c9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007cf:	52                   	push   %edx
f01007d0:	50                   	push   %eax
f01007d1:	8d 83 7c 68 f8 ff    	lea    -0x79784(%ebx),%eax
f01007d7:	50                   	push   %eax
f01007d8:	e8 1f 31 00 00       	call   f01038fc <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007dd:	83 c4 0c             	add    $0xc,%esp
f01007e0:	c7 c6 00 10 18 f0    	mov    $0xf0181000,%esi
f01007e6:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007ec:	50                   	push   %eax
f01007ed:	56                   	push   %esi
f01007ee:	8d 83 a0 68 f8 ff    	lea    -0x79760(%ebx),%eax
f01007f4:	50                   	push   %eax
f01007f5:	e8 02 31 00 00       	call   f01038fc <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007fa:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01007fd:	29 fe                	sub    %edi,%esi
f01007ff:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100805:	c1 fe 0a             	sar    $0xa,%esi
f0100808:	56                   	push   %esi
f0100809:	8d 83 c4 68 f8 ff    	lea    -0x7973c(%ebx),%eax
f010080f:	50                   	push   %eax
f0100810:	e8 e7 30 00 00       	call   f01038fc <cprintf>
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
f0100836:	81 c3 32 e0 07 00    	add    $0x7e032,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010083c:	8d 83 f0 68 f8 ff    	lea    -0x79710(%ebx),%eax
f0100842:	50                   	push   %eax
f0100843:	e8 b4 30 00 00       	call   f01038fc <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100848:	8d 83 14 69 f8 ff    	lea    -0x796ec(%ebx),%eax
f010084e:	89 04 24             	mov    %eax,(%esp)
f0100851:	e8 a6 30 00 00       	call   f01038fc <cprintf>

	if (tf != NULL)
f0100856:	83 c4 10             	add    $0x10,%esp
f0100859:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010085d:	74 0e                	je     f010086d <monitor+0x45>
		print_trapframe(tf);
f010085f:	83 ec 0c             	sub    $0xc,%esp
f0100862:	ff 75 08             	push   0x8(%ebp)
f0100865:	e8 fb 31 00 00       	call   f0103a65 <print_trapframe>
f010086a:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010086d:	8d bb aa 67 f8 ff    	lea    -0x79856(%ebx),%edi
f0100873:	eb 4a                	jmp    f01008bf <monitor+0x97>
f0100875:	83 ec 08             	sub    $0x8,%esp
f0100878:	0f be c0             	movsbl %al,%eax
f010087b:	50                   	push   %eax
f010087c:	57                   	push   %edi
f010087d:	e8 38 40 00 00       	call   f01048ba <strchr>
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
f01008b0:	8d 83 af 67 f8 ff    	lea    -0x79851(%ebx),%eax
f01008b6:	50                   	push   %eax
f01008b7:	e8 40 30 00 00       	call   f01038fc <cprintf>
			return 0;
f01008bc:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01008bf:	8d 83 a6 67 f8 ff    	lea    -0x7985a(%ebx),%eax
f01008c5:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01008c8:	83 ec 0c             	sub    $0xc,%esp
f01008cb:	ff 75 a4             	push   -0x5c(%ebp)
f01008ce:	e8 96 3d 00 00       	call   f0104669 <readline>
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
f01008fe:	e8 b7 3f 00 00       	call   f01048ba <strchr>
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
f0100927:	8d 83 76 67 f8 ff    	lea    -0x7988a(%ebx),%eax
f010092d:	50                   	push   %eax
f010092e:	ff 75 a8             	push   -0x58(%ebp)
f0100931:	e8 24 3f 00 00       	call   f010485a <strcmp>
f0100936:	83 c4 10             	add    $0x10,%esp
f0100939:	85 c0                	test   %eax,%eax
f010093b:	74 38                	je     f0100975 <monitor+0x14d>
f010093d:	83 ec 08             	sub    $0x8,%esp
f0100940:	8d 83 84 67 f8 ff    	lea    -0x7987c(%ebx),%eax
f0100946:	50                   	push   %eax
f0100947:	ff 75 a8             	push   -0x58(%ebp)
f010094a:	e8 0b 3f 00 00       	call   f010485a <strcmp>
f010094f:	83 c4 10             	add    $0x10,%esp
f0100952:	85 c0                	test   %eax,%eax
f0100954:	74 1a                	je     f0100970 <monitor+0x148>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100956:	83 ec 08             	sub    $0x8,%esp
f0100959:	ff 75 a8             	push   -0x58(%ebp)
f010095c:	8d 83 cc 67 f8 ff    	lea    -0x79834(%ebx),%eax
f0100962:	50                   	push   %eax
f0100963:	e8 94 2f 00 00       	call   f01038fc <cprintf>
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
f010099f:	e8 cd 26 00 00       	call   f0103071 <__x86.get_pc_thunk.dx>
f01009a4:	81 c2 c4 de 07 00    	add    $0x7dec4,%edx
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
f01009d2:	c7 c1 00 10 18 f0    	mov    $0xf0181000,%ecx
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
f0100a02:	81 c3 66 de 07 00    	add    $0x7de66,%ebx
f0100a08:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a0a:	50                   	push   %eax
f0100a0b:	e8 65 2e 00 00       	call   f0103875 <mc146818_read>
f0100a10:	89 c7                	mov    %eax,%edi
f0100a12:	83 c6 01             	add    $0x1,%esi
f0100a15:	89 34 24             	mov    %esi,(%esp)
f0100a18:	e8 58 2e 00 00       	call   f0103875 <mc146818_read>
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
f0100a31:	e8 3f 26 00 00       	call   f0103075 <__x86.get_pc_thunk.cx>
f0100a36:	81 c1 32 de 07 00    	add    $0x7de32,%ecx
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
f0100a85:	8d 81 3c 69 f8 ff    	lea    -0x796c4(%ecx),%eax
f0100a8b:	50                   	push   %eax
f0100a8c:	68 49 03 00 00       	push   $0x349
f0100a91:	8d 81 09 71 f8 ff    	lea    -0x78ef7(%ecx),%eax
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
f0100aaf:	e8 c5 25 00 00       	call   f0103079 <__x86.get_pc_thunk.di>
f0100ab4:	81 c7 b4 dd 07 00    	add    $0x7ddb4,%edi
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
f0100ae1:	8d 83 60 69 f8 ff    	lea    -0x796a0(%ebx),%eax
f0100ae7:	50                   	push   %eax
f0100ae8:	68 85 02 00 00       	push   $0x285
f0100aed:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0100af3:	50                   	push   %eax
f0100af4:	e8 b8 f5 ff ff       	call   f01000b1 <_panic>
f0100af9:	50                   	push   %eax
f0100afa:	89 cb                	mov    %ecx,%ebx
f0100afc:	8d 81 3c 69 f8 ff    	lea    -0x796c4(%ecx),%eax
f0100b02:	50                   	push   %eax
f0100b03:	6a 56                	push   $0x56
f0100b05:	8d 81 15 71 f8 ff    	lea    -0x78eeb(%ecx),%eax
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
f0100b54:	e8 a0 3d 00 00       	call   f01048f9 <memset>
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
f0100b9b:	8d 83 23 71 f8 ff    	lea    -0x78edd(%ebx),%eax
f0100ba1:	50                   	push   %eax
f0100ba2:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0100ba8:	50                   	push   %eax
f0100ba9:	68 9f 02 00 00       	push   $0x29f
f0100bae:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0100bb4:	50                   	push   %eax
f0100bb5:	e8 f7 f4 ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0100bba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100bbd:	8d 83 44 71 f8 ff    	lea    -0x78ebc(%ebx),%eax
f0100bc3:	50                   	push   %eax
f0100bc4:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0100bca:	50                   	push   %eax
f0100bcb:	68 a0 02 00 00       	push   $0x2a0
f0100bd0:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0100bd6:	50                   	push   %eax
f0100bd7:	e8 d5 f4 ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bdc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100bdf:	8d 83 84 69 f8 ff    	lea    -0x7967c(%ebx),%eax
f0100be5:	50                   	push   %eax
f0100be6:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0100bec:	50                   	push   %eax
f0100bed:	68 a1 02 00 00       	push   $0x2a1
f0100bf2:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0100bf8:	50                   	push   %eax
f0100bf9:	e8 b3 f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != 0);
f0100bfe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c01:	8d 83 58 71 f8 ff    	lea    -0x78ea8(%ebx),%eax
f0100c07:	50                   	push   %eax
f0100c08:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0100c0e:	50                   	push   %eax
f0100c0f:	68 a4 02 00 00       	push   $0x2a4
f0100c14:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0100c1a:	50                   	push   %eax
f0100c1b:	e8 91 f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c20:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c23:	8d 83 69 71 f8 ff    	lea    -0x78e97(%ebx),%eax
f0100c29:	50                   	push   %eax
f0100c2a:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0100c30:	50                   	push   %eax
f0100c31:	68 a5 02 00 00       	push   $0x2a5
f0100c36:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0100c3c:	50                   	push   %eax
f0100c3d:	e8 6f f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c42:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c45:	8d 83 b8 69 f8 ff    	lea    -0x79648(%ebx),%eax
f0100c4b:	50                   	push   %eax
f0100c4c:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0100c52:	50                   	push   %eax
f0100c53:	68 a6 02 00 00       	push   $0x2a6
f0100c58:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0100c5e:	50                   	push   %eax
f0100c5f:	e8 4d f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c64:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c67:	8d 83 82 71 f8 ff    	lea    -0x78e7e(%ebx),%eax
f0100c6d:	50                   	push   %eax
f0100c6e:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0100c74:	50                   	push   %eax
f0100c75:	68 a7 02 00 00       	push   $0x2a7
f0100c7a:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
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
f0100d01:	8d 83 3c 69 f8 ff    	lea    -0x796c4(%ebx),%eax
f0100d07:	50                   	push   %eax
f0100d08:	6a 56                	push   $0x56
f0100d0a:	8d 83 15 71 f8 ff    	lea    -0x78eeb(%ebx),%eax
f0100d10:	50                   	push   %eax
f0100d11:	e8 9b f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d16:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d19:	8d 83 dc 69 f8 ff    	lea    -0x79624(%ebx),%eax
f0100d1f:	50                   	push   %eax
f0100d20:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0100d26:	50                   	push   %eax
f0100d27:	68 a8 02 00 00       	push   $0x2a8
f0100d2c:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
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
f0100d49:	8d 83 24 6a f8 ff    	lea    -0x795dc(%ebx),%eax
f0100d4f:	50                   	push   %eax
f0100d50:	e8 a7 2b 00 00       	call   f01038fc <cprintf>
}
f0100d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d58:	5b                   	pop    %ebx
f0100d59:	5e                   	pop    %esi
f0100d5a:	5f                   	pop    %edi
f0100d5b:	5d                   	pop    %ebp
f0100d5c:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d5d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d60:	8d 83 9c 71 f8 ff    	lea    -0x78e64(%ebx),%eax
f0100d66:	50                   	push   %eax
f0100d67:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0100d6d:	50                   	push   %eax
f0100d6e:	68 b0 02 00 00       	push   $0x2b0
f0100d73:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0100d79:	50                   	push   %eax
f0100d7a:	e8 32 f3 ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0100d7f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d82:	8d 83 ae 71 f8 ff    	lea    -0x78e52(%ebx),%eax
f0100d88:	50                   	push   %eax
f0100d89:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0100d8f:	50                   	push   %eax
f0100d90:	68 b1 02 00 00       	push   $0x2b1
f0100d95:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
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
f0100e20:	81 c3 48 da 07 00    	add    $0x7da48,%ebx
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
f0100ec4:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f0100eca:	50                   	push   %eax
f0100ecb:	68 1e 01 00 00       	push   $0x11e
f0100ed0:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
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
f0100f44:	81 c3 24 d9 07 00    	add    $0x7d924,%ebx
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
f0100f9f:	e8 55 39 00 00       	call   f01048f9 <memset>
f0100fa4:	83 c4 10             	add    $0x10,%esp
f0100fa7:	eb bf                	jmp    f0100f68 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fa9:	52                   	push   %edx
f0100faa:	8d 83 3c 69 f8 ff    	lea    -0x796c4(%ebx),%eax
f0100fb0:	50                   	push   %eax
f0100fb1:	6a 56                	push   $0x56
f0100fb3:	8d 83 15 71 f8 ff    	lea    -0x78eeb(%ebx),%eax
f0100fb9:	50                   	push   %eax
f0100fba:	e8 f2 f0 ff ff       	call   f01000b1 <_panic>

f0100fbf <page_free>:
{
f0100fbf:	55                   	push   %ebp
f0100fc0:	89 e5                	mov    %esp,%ebp
f0100fc2:	53                   	push   %ebx
f0100fc3:	83 ec 04             	sub    $0x4,%esp
f0100fc6:	e8 9c f1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100fcb:	81 c3 9d d8 07 00    	add    $0x7d89d,%ebx
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
f0100ff6:	8d 83 6c 6a f8 ff    	lea    -0x79594(%ebx),%eax
f0100ffc:	50                   	push   %eax
f0100ffd:	68 5e 01 00 00       	push   $0x15e
f0101002:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
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
f0101040:	e8 34 20 00 00       	call   f0103079 <__x86.get_pc_thunk.di>
f0101045:	81 c7 23 d8 07 00    	add    $0x7d823,%edi
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
f01010dd:	8d 87 3c 69 f8 ff    	lea    -0x796c4(%edi),%eax
f01010e3:	50                   	push   %eax
f01010e4:	68 8f 01 00 00       	push   $0x18f
f01010e9:	8d 87 09 71 f8 ff    	lea    -0x78ef7(%edi),%eax
f01010ef:	50                   	push   %eax
f01010f0:	89 fb                	mov    %edi,%ebx
f01010f2:	e8 ba ef ff ff       	call   f01000b1 <_panic>
f01010f7:	52                   	push   %edx
f01010f8:	8d 87 3c 69 f8 ff    	lea    -0x796c4(%edi),%eax
f01010fe:	50                   	push   %eax
f01010ff:	6a 56                	push   $0x56
f0101101:	8d 87 15 71 f8 ff    	lea    -0x78eeb(%edi),%eax
f0101107:	50                   	push   %eax
f0101108:	89 fb                	mov    %edi,%ebx
f010110a:	e8 a2 ef ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010110f:	51                   	push   %ecx
f0101110:	8d 87 48 6a f8 ff    	lea    -0x795b8(%edi),%eax
f0101116:	50                   	push   %eax
f0101117:	68 98 01 00 00       	push   $0x198
f010111c:	8d 87 09 71 f8 ff    	lea    -0x78ef7(%edi),%eax
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
f010118f:	81 c3 d9 d6 07 00    	add    $0x7d6d9,%ebx
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
f01011d5:	8d 83 90 6a f8 ff    	lea    -0x79570(%ebx),%eax
f01011db:	50                   	push   %eax
f01011dc:	6a 4f                	push   $0x4f
f01011de:	8d 83 15 71 f8 ff    	lea    -0x78eeb(%ebx),%eax
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
f010122e:	e8 46 1e 00 00       	call   f0103079 <__x86.get_pc_thunk.di>
f0101233:	81 c7 35 d6 07 00    	add    $0x7d635,%edi
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
f01012ab:	05 bd d5 07 00       	add    $0x7d5bd,%eax
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
f01012d8:	0f 84 f1 00 00 00    	je     f01013cf <mem_init+0x132>
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
f0101303:	8d 81 b0 6a f8 ff    	lea    -0x79550(%ecx),%eax
f0101309:	50                   	push   %eax
f010130a:	89 cb                	mov    %ecx,%ebx
f010130c:	e8 eb 25 00 00       	call   f01038fc <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);		// 4KB
f0101311:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101316:	e8 84 f6 ff ff       	call   f010099f <boot_alloc>
f010131b:	89 83 d4 1a 00 00    	mov    %eax,0x1ad4(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f0101321:	83 c4 0c             	add    $0xc,%esp
f0101324:	68 00 10 00 00       	push   $0x1000
f0101329:	6a 00                	push   $0x0
f010132b:	50                   	push   %eax
f010132c:	e8 c8 35 00 00       	call   f01048f9 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101331:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0101337:	83 c4 10             	add    $0x10,%esp
f010133a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010133f:	0f 86 9a 00 00 00    	jbe    f01013df <mem_init+0x142>
	return (physaddr_t)kva - KERNBASE;
f0101345:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010134b:	83 ca 05             	or     $0x5,%edx
f010134e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*) boot_alloc(npages * sizeof(struct PageInfo));
f0101354:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101357:	8b 87 d8 1a 00 00    	mov    0x1ad8(%edi),%eax
f010135d:	c1 e0 03             	shl    $0x3,%eax
f0101360:	e8 3a f6 ff ff       	call   f010099f <boot_alloc>
f0101365:	89 87 d0 1a 00 00    	mov    %eax,0x1ad0(%edi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f010136b:	83 ec 04             	sub    $0x4,%esp
f010136e:	8b 97 d8 1a 00 00    	mov    0x1ad8(%edi),%edx
f0101374:	c1 e2 03             	shl    $0x3,%edx
f0101377:	52                   	push   %edx
f0101378:	6a 00                	push   $0x0
f010137a:	50                   	push   %eax
f010137b:	89 fb                	mov    %edi,%ebx
f010137d:	e8 77 35 00 00       	call   f01048f9 <memset>
	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f0101382:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101387:	e8 13 f6 ff ff       	call   f010099f <boot_alloc>
f010138c:	c7 c2 54 03 18 f0    	mov    $0xf0180354,%edx
f0101392:	89 02                	mov    %eax,(%edx)
	memset(envs, 0, NENV * sizeof(struct Env));
f0101394:	83 c4 0c             	add    $0xc,%esp
f0101397:	68 00 80 01 00       	push   $0x18000
f010139c:	6a 00                	push   $0x0
f010139e:	50                   	push   %eax
f010139f:	e8 55 35 00 00       	call   f01048f9 <memset>
	page_init();
f01013a4:	e8 69 fa ff ff       	call   f0100e12 <page_init>
	check_page_free_list(1);
f01013a9:	b8 01 00 00 00       	mov    $0x1,%eax
f01013ae:	e8 f3 f6 ff ff       	call   f0100aa6 <check_page_free_list>
	if (!pages)
f01013b3:	83 c4 10             	add    $0x10,%esp
f01013b6:	83 bf d0 1a 00 00 00 	cmpl   $0x0,0x1ad0(%edi)
f01013bd:	74 3c                	je     f01013fb <mem_init+0x15e>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013c2:	8b 80 e0 1a 00 00    	mov    0x1ae0(%eax),%eax
f01013c8:	be 00 00 00 00       	mov    $0x0,%esi
f01013cd:	eb 4f                	jmp    f010141e <mem_init+0x181>
		totalmem = 1 * 1024 + extmem;
f01013cf:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01013d5:	85 f6                	test   %esi,%esi
f01013d7:	0f 44 c3             	cmove  %ebx,%eax
f01013da:	e9 04 ff ff ff       	jmp    f01012e3 <mem_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013df:	50                   	push   %eax
f01013e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01013e3:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f01013e9:	50                   	push   %eax
f01013ea:	68 93 00 00 00       	push   $0x93
f01013ef:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01013f5:	50                   	push   %eax
f01013f6:	e8 b6 ec ff ff       	call   f01000b1 <_panic>
		panic("'pages' is a null pointer!");
f01013fb:	83 ec 04             	sub    $0x4,%esp
f01013fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101401:	8d 83 bf 71 f8 ff    	lea    -0x78e41(%ebx),%eax
f0101407:	50                   	push   %eax
f0101408:	68 c4 02 00 00       	push   $0x2c4
f010140d:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0101413:	50                   	push   %eax
f0101414:	e8 98 ec ff ff       	call   f01000b1 <_panic>
		++nfree;
f0101419:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010141c:	8b 00                	mov    (%eax),%eax
f010141e:	85 c0                	test   %eax,%eax
f0101420:	75 f7                	jne    f0101419 <mem_init+0x17c>
	assert((pp0 = page_alloc(0)));
f0101422:	83 ec 0c             	sub    $0xc,%esp
f0101425:	6a 00                	push   $0x0
f0101427:	e8 0e fb ff ff       	call   f0100f3a <page_alloc>
f010142c:	89 c3                	mov    %eax,%ebx
f010142e:	83 c4 10             	add    $0x10,%esp
f0101431:	85 c0                	test   %eax,%eax
f0101433:	0f 84 3a 02 00 00    	je     f0101673 <mem_init+0x3d6>
	assert((pp1 = page_alloc(0)));
f0101439:	83 ec 0c             	sub    $0xc,%esp
f010143c:	6a 00                	push   $0x0
f010143e:	e8 f7 fa ff ff       	call   f0100f3a <page_alloc>
f0101443:	89 c7                	mov    %eax,%edi
f0101445:	83 c4 10             	add    $0x10,%esp
f0101448:	85 c0                	test   %eax,%eax
f010144a:	0f 84 45 02 00 00    	je     f0101695 <mem_init+0x3f8>
	assert((pp2 = page_alloc(0)));
f0101450:	83 ec 0c             	sub    $0xc,%esp
f0101453:	6a 00                	push   $0x0
f0101455:	e8 e0 fa ff ff       	call   f0100f3a <page_alloc>
f010145a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010145d:	83 c4 10             	add    $0x10,%esp
f0101460:	85 c0                	test   %eax,%eax
f0101462:	0f 84 4f 02 00 00    	je     f01016b7 <mem_init+0x41a>
	assert(pp1 && pp1 != pp0);
f0101468:	39 fb                	cmp    %edi,%ebx
f010146a:	0f 84 69 02 00 00    	je     f01016d9 <mem_init+0x43c>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101470:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101473:	39 c7                	cmp    %eax,%edi
f0101475:	0f 84 80 02 00 00    	je     f01016fb <mem_init+0x45e>
f010147b:	39 c3                	cmp    %eax,%ebx
f010147d:	0f 84 78 02 00 00    	je     f01016fb <mem_init+0x45e>
	return (pp - pages) << PGSHIFT;
f0101483:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101486:	8b 88 d0 1a 00 00    	mov    0x1ad0(%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010148c:	8b 90 d8 1a 00 00    	mov    0x1ad8(%eax),%edx
f0101492:	c1 e2 0c             	shl    $0xc,%edx
f0101495:	89 d8                	mov    %ebx,%eax
f0101497:	29 c8                	sub    %ecx,%eax
f0101499:	c1 f8 03             	sar    $0x3,%eax
f010149c:	c1 e0 0c             	shl    $0xc,%eax
f010149f:	39 d0                	cmp    %edx,%eax
f01014a1:	0f 83 76 02 00 00    	jae    f010171d <mem_init+0x480>
f01014a7:	89 f8                	mov    %edi,%eax
f01014a9:	29 c8                	sub    %ecx,%eax
f01014ab:	c1 f8 03             	sar    $0x3,%eax
f01014ae:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01014b1:	39 c2                	cmp    %eax,%edx
f01014b3:	0f 86 86 02 00 00    	jbe    f010173f <mem_init+0x4a2>
f01014b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01014bc:	29 c8                	sub    %ecx,%eax
f01014be:	c1 f8 03             	sar    $0x3,%eax
f01014c1:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01014c4:	39 c2                	cmp    %eax,%edx
f01014c6:	0f 86 95 02 00 00    	jbe    f0101761 <mem_init+0x4c4>
	fl = page_free_list;
f01014cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014cf:	8b 88 e0 1a 00 00    	mov    0x1ae0(%eax),%ecx
f01014d5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f01014d8:	c7 80 e0 1a 00 00 00 	movl   $0x0,0x1ae0(%eax)
f01014df:	00 00 00 
	assert(!page_alloc(0));
f01014e2:	83 ec 0c             	sub    $0xc,%esp
f01014e5:	6a 00                	push   $0x0
f01014e7:	e8 4e fa ff ff       	call   f0100f3a <page_alloc>
f01014ec:	83 c4 10             	add    $0x10,%esp
f01014ef:	85 c0                	test   %eax,%eax
f01014f1:	0f 85 8c 02 00 00    	jne    f0101783 <mem_init+0x4e6>
	page_free(pp0);
f01014f7:	83 ec 0c             	sub    $0xc,%esp
f01014fa:	53                   	push   %ebx
f01014fb:	e8 bf fa ff ff       	call   f0100fbf <page_free>
	page_free(pp1);
f0101500:	89 3c 24             	mov    %edi,(%esp)
f0101503:	e8 b7 fa ff ff       	call   f0100fbf <page_free>
	page_free(pp2);
f0101508:	83 c4 04             	add    $0x4,%esp
f010150b:	ff 75 d0             	push   -0x30(%ebp)
f010150e:	e8 ac fa ff ff       	call   f0100fbf <page_free>
	assert((pp0 = page_alloc(0)));
f0101513:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010151a:	e8 1b fa ff ff       	call   f0100f3a <page_alloc>
f010151f:	89 c7                	mov    %eax,%edi
f0101521:	83 c4 10             	add    $0x10,%esp
f0101524:	85 c0                	test   %eax,%eax
f0101526:	0f 84 79 02 00 00    	je     f01017a5 <mem_init+0x508>
	assert((pp1 = page_alloc(0)));
f010152c:	83 ec 0c             	sub    $0xc,%esp
f010152f:	6a 00                	push   $0x0
f0101531:	e8 04 fa ff ff       	call   f0100f3a <page_alloc>
f0101536:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101539:	83 c4 10             	add    $0x10,%esp
f010153c:	85 c0                	test   %eax,%eax
f010153e:	0f 84 83 02 00 00    	je     f01017c7 <mem_init+0x52a>
	assert((pp2 = page_alloc(0)));
f0101544:	83 ec 0c             	sub    $0xc,%esp
f0101547:	6a 00                	push   $0x0
f0101549:	e8 ec f9 ff ff       	call   f0100f3a <page_alloc>
f010154e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101551:	83 c4 10             	add    $0x10,%esp
f0101554:	85 c0                	test   %eax,%eax
f0101556:	0f 84 8d 02 00 00    	je     f01017e9 <mem_init+0x54c>
	assert(pp1 && pp1 != pp0);
f010155c:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f010155f:	0f 84 a6 02 00 00    	je     f010180b <mem_init+0x56e>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101565:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101568:	39 c7                	cmp    %eax,%edi
f010156a:	0f 84 bd 02 00 00    	je     f010182d <mem_init+0x590>
f0101570:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101573:	0f 84 b4 02 00 00    	je     f010182d <mem_init+0x590>
	assert(!page_alloc(0));
f0101579:	83 ec 0c             	sub    $0xc,%esp
f010157c:	6a 00                	push   $0x0
f010157e:	e8 b7 f9 ff ff       	call   f0100f3a <page_alloc>
f0101583:	83 c4 10             	add    $0x10,%esp
f0101586:	85 c0                	test   %eax,%eax
f0101588:	0f 85 c1 02 00 00    	jne    f010184f <mem_init+0x5b2>
f010158e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101591:	89 f8                	mov    %edi,%eax
f0101593:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0101599:	c1 f8 03             	sar    $0x3,%eax
f010159c:	89 c2                	mov    %eax,%edx
f010159e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01015a1:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01015a6:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f01015ac:	0f 83 bf 02 00 00    	jae    f0101871 <mem_init+0x5d4>
	memset(page2kva(pp0), 1, PGSIZE);
f01015b2:	83 ec 04             	sub    $0x4,%esp
f01015b5:	68 00 10 00 00       	push   $0x1000
f01015ba:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015bc:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01015c2:	52                   	push   %edx
f01015c3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01015c6:	e8 2e 33 00 00       	call   f01048f9 <memset>
	page_free(pp0);
f01015cb:	89 3c 24             	mov    %edi,(%esp)
f01015ce:	e8 ec f9 ff ff       	call   f0100fbf <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015da:	e8 5b f9 ff ff       	call   f0100f3a <page_alloc>
f01015df:	83 c4 10             	add    $0x10,%esp
f01015e2:	85 c0                	test   %eax,%eax
f01015e4:	0f 84 9f 02 00 00    	je     f0101889 <mem_init+0x5ec>
	assert(pp && pp0 == pp);
f01015ea:	39 c7                	cmp    %eax,%edi
f01015ec:	0f 85 b9 02 00 00    	jne    f01018ab <mem_init+0x60e>
	return (pp - pages) << PGSHIFT;
f01015f2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01015f5:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f01015fb:	c1 f8 03             	sar    $0x3,%eax
f01015fe:	89 c2                	mov    %eax,%edx
f0101600:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101603:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101608:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f010160e:	0f 83 b9 02 00 00    	jae    f01018cd <mem_init+0x630>
	return (void *)(pa + KERNBASE);
f0101614:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010161a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101620:	80 38 00             	cmpb   $0x0,(%eax)
f0101623:	0f 85 bc 02 00 00    	jne    f01018e5 <mem_init+0x648>
	for (i = 0; i < PGSIZE; i++)
f0101629:	83 c0 01             	add    $0x1,%eax
f010162c:	39 d0                	cmp    %edx,%eax
f010162e:	75 f0                	jne    f0101620 <mem_init+0x383>
	page_free_list = fl;
f0101630:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101633:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101636:	89 8b e0 1a 00 00    	mov    %ecx,0x1ae0(%ebx)
	page_free(pp0);
f010163c:	83 ec 0c             	sub    $0xc,%esp
f010163f:	57                   	push   %edi
f0101640:	e8 7a f9 ff ff       	call   f0100fbf <page_free>
	page_free(pp1);
f0101645:	83 c4 04             	add    $0x4,%esp
f0101648:	ff 75 d0             	push   -0x30(%ebp)
f010164b:	e8 6f f9 ff ff       	call   f0100fbf <page_free>
	page_free(pp2);
f0101650:	83 c4 04             	add    $0x4,%esp
f0101653:	ff 75 cc             	push   -0x34(%ebp)
f0101656:	e8 64 f9 ff ff       	call   f0100fbf <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010165b:	8b 83 e0 1a 00 00    	mov    0x1ae0(%ebx),%eax
f0101661:	83 c4 10             	add    $0x10,%esp
f0101664:	85 c0                	test   %eax,%eax
f0101666:	0f 84 9b 02 00 00    	je     f0101907 <mem_init+0x66a>
		--nfree;
f010166c:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010166f:	8b 00                	mov    (%eax),%eax
f0101671:	eb f1                	jmp    f0101664 <mem_init+0x3c7>
	assert((pp0 = page_alloc(0)));
f0101673:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101676:	8d 83 da 71 f8 ff    	lea    -0x78e26(%ebx),%eax
f010167c:	50                   	push   %eax
f010167d:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0101683:	50                   	push   %eax
f0101684:	68 cc 02 00 00       	push   $0x2cc
f0101689:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010168f:	50                   	push   %eax
f0101690:	e8 1c ea ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101695:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101698:	8d 83 f0 71 f8 ff    	lea    -0x78e10(%ebx),%eax
f010169e:	50                   	push   %eax
f010169f:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01016a5:	50                   	push   %eax
f01016a6:	68 cd 02 00 00       	push   $0x2cd
f01016ab:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01016b1:	50                   	push   %eax
f01016b2:	e8 fa e9 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01016b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016ba:	8d 83 06 72 f8 ff    	lea    -0x78dfa(%ebx),%eax
f01016c0:	50                   	push   %eax
f01016c1:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01016c7:	50                   	push   %eax
f01016c8:	68 ce 02 00 00       	push   $0x2ce
f01016cd:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01016d3:	50                   	push   %eax
f01016d4:	e8 d8 e9 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01016d9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016dc:	8d 83 1c 72 f8 ff    	lea    -0x78de4(%ebx),%eax
f01016e2:	50                   	push   %eax
f01016e3:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01016e9:	50                   	push   %eax
f01016ea:	68 d1 02 00 00       	push   $0x2d1
f01016ef:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01016f5:	50                   	push   %eax
f01016f6:	e8 b6 e9 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016fb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016fe:	8d 83 ec 6a f8 ff    	lea    -0x79514(%ebx),%eax
f0101704:	50                   	push   %eax
f0101705:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010170b:	50                   	push   %eax
f010170c:	68 d2 02 00 00       	push   $0x2d2
f0101711:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0101717:	50                   	push   %eax
f0101718:	e8 94 e9 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010171d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101720:	8d 83 2e 72 f8 ff    	lea    -0x78dd2(%ebx),%eax
f0101726:	50                   	push   %eax
f0101727:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010172d:	50                   	push   %eax
f010172e:	68 d3 02 00 00       	push   $0x2d3
f0101733:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0101739:	50                   	push   %eax
f010173a:	e8 72 e9 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010173f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101742:	8d 83 4b 72 f8 ff    	lea    -0x78db5(%ebx),%eax
f0101748:	50                   	push   %eax
f0101749:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010174f:	50                   	push   %eax
f0101750:	68 d4 02 00 00       	push   $0x2d4
f0101755:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010175b:	50                   	push   %eax
f010175c:	e8 50 e9 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101761:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101764:	8d 83 68 72 f8 ff    	lea    -0x78d98(%ebx),%eax
f010176a:	50                   	push   %eax
f010176b:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0101771:	50                   	push   %eax
f0101772:	68 d5 02 00 00       	push   $0x2d5
f0101777:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010177d:	50                   	push   %eax
f010177e:	e8 2e e9 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101783:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101786:	8d 83 85 72 f8 ff    	lea    -0x78d7b(%ebx),%eax
f010178c:	50                   	push   %eax
f010178d:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0101793:	50                   	push   %eax
f0101794:	68 dc 02 00 00       	push   $0x2dc
f0101799:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010179f:	50                   	push   %eax
f01017a0:	e8 0c e9 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f01017a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017a8:	8d 83 da 71 f8 ff    	lea    -0x78e26(%ebx),%eax
f01017ae:	50                   	push   %eax
f01017af:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01017b5:	50                   	push   %eax
f01017b6:	68 e3 02 00 00       	push   $0x2e3
f01017bb:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01017c1:	50                   	push   %eax
f01017c2:	e8 ea e8 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01017c7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017ca:	8d 83 f0 71 f8 ff    	lea    -0x78e10(%ebx),%eax
f01017d0:	50                   	push   %eax
f01017d1:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01017d7:	50                   	push   %eax
f01017d8:	68 e4 02 00 00       	push   $0x2e4
f01017dd:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01017e3:	50                   	push   %eax
f01017e4:	e8 c8 e8 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01017e9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017ec:	8d 83 06 72 f8 ff    	lea    -0x78dfa(%ebx),%eax
f01017f2:	50                   	push   %eax
f01017f3:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01017f9:	50                   	push   %eax
f01017fa:	68 e5 02 00 00       	push   $0x2e5
f01017ff:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0101805:	50                   	push   %eax
f0101806:	e8 a6 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f010180b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010180e:	8d 83 1c 72 f8 ff    	lea    -0x78de4(%ebx),%eax
f0101814:	50                   	push   %eax
f0101815:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010181b:	50                   	push   %eax
f010181c:	68 e7 02 00 00       	push   $0x2e7
f0101821:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0101827:	50                   	push   %eax
f0101828:	e8 84 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010182d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101830:	8d 83 ec 6a f8 ff    	lea    -0x79514(%ebx),%eax
f0101836:	50                   	push   %eax
f0101837:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010183d:	50                   	push   %eax
f010183e:	68 e8 02 00 00       	push   $0x2e8
f0101843:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0101849:	50                   	push   %eax
f010184a:	e8 62 e8 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010184f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101852:	8d 83 85 72 f8 ff    	lea    -0x78d7b(%ebx),%eax
f0101858:	50                   	push   %eax
f0101859:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010185f:	50                   	push   %eax
f0101860:	68 e9 02 00 00       	push   $0x2e9
f0101865:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010186b:	50                   	push   %eax
f010186c:	e8 40 e8 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101871:	52                   	push   %edx
f0101872:	89 cb                	mov    %ecx,%ebx
f0101874:	8d 81 3c 69 f8 ff    	lea    -0x796c4(%ecx),%eax
f010187a:	50                   	push   %eax
f010187b:	6a 56                	push   $0x56
f010187d:	8d 81 15 71 f8 ff    	lea    -0x78eeb(%ecx),%eax
f0101883:	50                   	push   %eax
f0101884:	e8 28 e8 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101889:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010188c:	8d 83 94 72 f8 ff    	lea    -0x78d6c(%ebx),%eax
f0101892:	50                   	push   %eax
f0101893:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0101899:	50                   	push   %eax
f010189a:	68 ee 02 00 00       	push   $0x2ee
f010189f:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01018a5:	50                   	push   %eax
f01018a6:	e8 06 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f01018ab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018ae:	8d 83 b2 72 f8 ff    	lea    -0x78d4e(%ebx),%eax
f01018b4:	50                   	push   %eax
f01018b5:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01018bb:	50                   	push   %eax
f01018bc:	68 ef 02 00 00       	push   $0x2ef
f01018c1:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01018c7:	50                   	push   %eax
f01018c8:	e8 e4 e7 ff ff       	call   f01000b1 <_panic>
f01018cd:	52                   	push   %edx
f01018ce:	89 cb                	mov    %ecx,%ebx
f01018d0:	8d 81 3c 69 f8 ff    	lea    -0x796c4(%ecx),%eax
f01018d6:	50                   	push   %eax
f01018d7:	6a 56                	push   $0x56
f01018d9:	8d 81 15 71 f8 ff    	lea    -0x78eeb(%ecx),%eax
f01018df:	50                   	push   %eax
f01018e0:	e8 cc e7 ff ff       	call   f01000b1 <_panic>
		assert(c[i] == 0);
f01018e5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018e8:	8d 83 c2 72 f8 ff    	lea    -0x78d3e(%ebx),%eax
f01018ee:	50                   	push   %eax
f01018ef:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01018f5:	50                   	push   %eax
f01018f6:	68 f2 02 00 00       	push   $0x2f2
f01018fb:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0101901:	50                   	push   %eax
f0101902:	e8 aa e7 ff ff       	call   f01000b1 <_panic>
	assert(nfree == 0);
f0101907:	85 f6                	test   %esi,%esi
f0101909:	0f 85 35 08 00 00    	jne    f0102144 <mem_init+0xea7>
	cprintf("check_page_alloc() succeeded!\n");
f010190f:	83 ec 0c             	sub    $0xc,%esp
f0101912:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101915:	8d 83 0c 6b f8 ff    	lea    -0x794f4(%ebx),%eax
f010191b:	50                   	push   %eax
f010191c:	e8 db 1f 00 00       	call   f01038fc <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101921:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101928:	e8 0d f6 ff ff       	call   f0100f3a <page_alloc>
f010192d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101930:	83 c4 10             	add    $0x10,%esp
f0101933:	85 c0                	test   %eax,%eax
f0101935:	0f 84 2b 08 00 00    	je     f0102166 <mem_init+0xec9>
	assert((pp1 = page_alloc(0)));
f010193b:	83 ec 0c             	sub    $0xc,%esp
f010193e:	6a 00                	push   $0x0
f0101940:	e8 f5 f5 ff ff       	call   f0100f3a <page_alloc>
f0101945:	89 c7                	mov    %eax,%edi
f0101947:	83 c4 10             	add    $0x10,%esp
f010194a:	85 c0                	test   %eax,%eax
f010194c:	0f 84 36 08 00 00    	je     f0102188 <mem_init+0xeeb>
	assert((pp2 = page_alloc(0)));
f0101952:	83 ec 0c             	sub    $0xc,%esp
f0101955:	6a 00                	push   $0x0
f0101957:	e8 de f5 ff ff       	call   f0100f3a <page_alloc>
f010195c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010195f:	83 c4 10             	add    $0x10,%esp
f0101962:	85 c0                	test   %eax,%eax
f0101964:	0f 84 40 08 00 00    	je     f01021aa <mem_init+0xf0d>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010196a:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f010196d:	0f 84 59 08 00 00    	je     f01021cc <mem_init+0xf2f>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101973:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101976:	39 c7                	cmp    %eax,%edi
f0101978:	0f 84 70 08 00 00    	je     f01021ee <mem_init+0xf51>
f010197e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101981:	0f 84 67 08 00 00    	je     f01021ee <mem_init+0xf51>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101987:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010198a:	8b 88 e0 1a 00 00    	mov    0x1ae0(%eax),%ecx
f0101990:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101993:	c7 80 e0 1a 00 00 00 	movl   $0x0,0x1ae0(%eax)
f010199a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010199d:	83 ec 0c             	sub    $0xc,%esp
f01019a0:	6a 00                	push   $0x0
f01019a2:	e8 93 f5 ff ff       	call   f0100f3a <page_alloc>
f01019a7:	83 c4 10             	add    $0x10,%esp
f01019aa:	85 c0                	test   %eax,%eax
f01019ac:	0f 85 5e 08 00 00    	jne    f0102210 <mem_init+0xf73>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01019b2:	83 ec 04             	sub    $0x4,%esp
f01019b5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01019b8:	50                   	push   %eax
f01019b9:	6a 00                	push   $0x0
f01019bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019be:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f01019c4:	e8 bc f7 ff ff       	call   f0101185 <page_lookup>
f01019c9:	83 c4 10             	add    $0x10,%esp
f01019cc:	85 c0                	test   %eax,%eax
f01019ce:	0f 85 5e 08 00 00    	jne    f0102232 <mem_init+0xf95>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019d4:	6a 02                	push   $0x2
f01019d6:	6a 00                	push   $0x0
f01019d8:	57                   	push   %edi
f01019d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019dc:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f01019e2:	e8 3e f8 ff ff       	call   f0101225 <page_insert>
f01019e7:	83 c4 10             	add    $0x10,%esp
f01019ea:	85 c0                	test   %eax,%eax
f01019ec:	0f 89 62 08 00 00    	jns    f0102254 <mem_init+0xfb7>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01019f2:	83 ec 0c             	sub    $0xc,%esp
f01019f5:	ff 75 cc             	push   -0x34(%ebp)
f01019f8:	e8 c2 f5 ff ff       	call   f0100fbf <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01019fd:	6a 02                	push   $0x2
f01019ff:	6a 00                	push   $0x0
f0101a01:	57                   	push   %edi
f0101a02:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a05:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101a0b:	e8 15 f8 ff ff       	call   f0101225 <page_insert>
f0101a10:	83 c4 20             	add    $0x20,%esp
f0101a13:	85 c0                	test   %eax,%eax
f0101a15:	0f 85 5b 08 00 00    	jne    f0102276 <mem_init+0xfd9>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a1b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a1e:	8b 98 d4 1a 00 00    	mov    0x1ad4(%eax),%ebx
	return (pp - pages) << PGSHIFT;
f0101a24:	8b b0 d0 1a 00 00    	mov    0x1ad0(%eax),%esi
f0101a2a:	8b 13                	mov    (%ebx),%edx
f0101a2c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a32:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101a35:	29 f0                	sub    %esi,%eax
f0101a37:	c1 f8 03             	sar    $0x3,%eax
f0101a3a:	c1 e0 0c             	shl    $0xc,%eax
f0101a3d:	39 c2                	cmp    %eax,%edx
f0101a3f:	0f 85 53 08 00 00    	jne    f0102298 <mem_init+0xffb>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a45:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a4a:	89 d8                	mov    %ebx,%eax
f0101a4c:	e8 d9 ef ff ff       	call   f0100a2a <check_va2pa>
f0101a51:	89 c2                	mov    %eax,%edx
f0101a53:	89 f8                	mov    %edi,%eax
f0101a55:	29 f0                	sub    %esi,%eax
f0101a57:	c1 f8 03             	sar    $0x3,%eax
f0101a5a:	c1 e0 0c             	shl    $0xc,%eax
f0101a5d:	39 c2                	cmp    %eax,%edx
f0101a5f:	0f 85 55 08 00 00    	jne    f01022ba <mem_init+0x101d>
	assert(pp1->pp_ref == 1);
f0101a65:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a6a:	0f 85 6c 08 00 00    	jne    f01022dc <mem_init+0x103f>
	assert(pp0->pp_ref == 1);
f0101a70:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101a73:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a78:	0f 85 80 08 00 00    	jne    f01022fe <mem_init+0x1061>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a7e:	6a 02                	push   $0x2
f0101a80:	68 00 10 00 00       	push   $0x1000
f0101a85:	ff 75 d0             	push   -0x30(%ebp)
f0101a88:	53                   	push   %ebx
f0101a89:	e8 97 f7 ff ff       	call   f0101225 <page_insert>
f0101a8e:	83 c4 10             	add    $0x10,%esp
f0101a91:	85 c0                	test   %eax,%eax
f0101a93:	0f 85 87 08 00 00    	jne    f0102320 <mem_init+0x1083>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a99:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a9e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101aa1:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
f0101aa7:	e8 7e ef ff ff       	call   f0100a2a <check_va2pa>
f0101aac:	89 c2                	mov    %eax,%edx
f0101aae:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ab1:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101ab7:	c1 f8 03             	sar    $0x3,%eax
f0101aba:	c1 e0 0c             	shl    $0xc,%eax
f0101abd:	39 c2                	cmp    %eax,%edx
f0101abf:	0f 85 7d 08 00 00    	jne    f0102342 <mem_init+0x10a5>
	assert(pp2->pp_ref == 1);
f0101ac5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ac8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101acd:	0f 85 91 08 00 00    	jne    f0102364 <mem_init+0x10c7>

	// should be no free memory
	assert(!page_alloc(0));
f0101ad3:	83 ec 0c             	sub    $0xc,%esp
f0101ad6:	6a 00                	push   $0x0
f0101ad8:	e8 5d f4 ff ff       	call   f0100f3a <page_alloc>
f0101add:	83 c4 10             	add    $0x10,%esp
f0101ae0:	85 c0                	test   %eax,%eax
f0101ae2:	0f 85 9e 08 00 00    	jne    f0102386 <mem_init+0x10e9>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ae8:	6a 02                	push   $0x2
f0101aea:	68 00 10 00 00       	push   $0x1000
f0101aef:	ff 75 d0             	push   -0x30(%ebp)
f0101af2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101af5:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101afb:	e8 25 f7 ff ff       	call   f0101225 <page_insert>
f0101b00:	83 c4 10             	add    $0x10,%esp
f0101b03:	85 c0                	test   %eax,%eax
f0101b05:	0f 85 9d 08 00 00    	jne    f01023a8 <mem_init+0x110b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b0b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b10:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b13:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
f0101b19:	e8 0c ef ff ff       	call   f0100a2a <check_va2pa>
f0101b1e:	89 c2                	mov    %eax,%edx
f0101b20:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b23:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101b29:	c1 f8 03             	sar    $0x3,%eax
f0101b2c:	c1 e0 0c             	shl    $0xc,%eax
f0101b2f:	39 c2                	cmp    %eax,%edx
f0101b31:	0f 85 93 08 00 00    	jne    f01023ca <mem_init+0x112d>
	assert(pp2->pp_ref == 1);
f0101b37:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b3a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b3f:	0f 85 a7 08 00 00    	jne    f01023ec <mem_init+0x114f>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b45:	83 ec 0c             	sub    $0xc,%esp
f0101b48:	6a 00                	push   $0x0
f0101b4a:	e8 eb f3 ff ff       	call   f0100f3a <page_alloc>
f0101b4f:	83 c4 10             	add    $0x10,%esp
f0101b52:	85 c0                	test   %eax,%eax
f0101b54:	0f 85 b4 08 00 00    	jne    f010240e <mem_init+0x1171>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b5a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b5d:	8b 91 d4 1a 00 00    	mov    0x1ad4(%ecx),%edx
f0101b63:	8b 02                	mov    (%edx),%eax
f0101b65:	89 c3                	mov    %eax,%ebx
f0101b67:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PGNUM(pa) >= npages)
f0101b6d:	c1 e8 0c             	shr    $0xc,%eax
f0101b70:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0101b76:	0f 83 b4 08 00 00    	jae    f0102430 <mem_init+0x1193>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b7c:	83 ec 04             	sub    $0x4,%esp
f0101b7f:	6a 00                	push   $0x0
f0101b81:	68 00 10 00 00       	push   $0x1000
f0101b86:	52                   	push   %edx
f0101b87:	e8 ab f4 ff ff       	call   f0101037 <pgdir_walk>
f0101b8c:	81 eb fc ff ff 0f    	sub    $0xffffffc,%ebx
f0101b92:	83 c4 10             	add    $0x10,%esp
f0101b95:	39 d8                	cmp    %ebx,%eax
f0101b97:	0f 85 ae 08 00 00    	jne    f010244b <mem_init+0x11ae>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b9d:	6a 06                	push   $0x6
f0101b9f:	68 00 10 00 00       	push   $0x1000
f0101ba4:	ff 75 d0             	push   -0x30(%ebp)
f0101ba7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101baa:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101bb0:	e8 70 f6 ff ff       	call   f0101225 <page_insert>
f0101bb5:	83 c4 10             	add    $0x10,%esp
f0101bb8:	85 c0                	test   %eax,%eax
f0101bba:	0f 85 ad 08 00 00    	jne    f010246d <mem_init+0x11d0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bc0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101bc3:	8b 9e d4 1a 00 00    	mov    0x1ad4(%esi),%ebx
f0101bc9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bce:	89 d8                	mov    %ebx,%eax
f0101bd0:	e8 55 ee ff ff       	call   f0100a2a <check_va2pa>
f0101bd5:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101bd7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bda:	2b 86 d0 1a 00 00    	sub    0x1ad0(%esi),%eax
f0101be0:	c1 f8 03             	sar    $0x3,%eax
f0101be3:	c1 e0 0c             	shl    $0xc,%eax
f0101be6:	39 c2                	cmp    %eax,%edx
f0101be8:	0f 85 a1 08 00 00    	jne    f010248f <mem_init+0x11f2>
	assert(pp2->pp_ref == 1);
f0101bee:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bf1:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bf6:	0f 85 b5 08 00 00    	jne    f01024b1 <mem_init+0x1214>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101bfc:	83 ec 04             	sub    $0x4,%esp
f0101bff:	6a 00                	push   $0x0
f0101c01:	68 00 10 00 00       	push   $0x1000
f0101c06:	53                   	push   %ebx
f0101c07:	e8 2b f4 ff ff       	call   f0101037 <pgdir_walk>
f0101c0c:	83 c4 10             	add    $0x10,%esp
f0101c0f:	f6 00 04             	testb  $0x4,(%eax)
f0101c12:	0f 84 bb 08 00 00    	je     f01024d3 <mem_init+0x1236>
	assert(kern_pgdir[0] & PTE_U);
f0101c18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c1b:	8b 80 d4 1a 00 00    	mov    0x1ad4(%eax),%eax
f0101c21:	f6 00 04             	testb  $0x4,(%eax)
f0101c24:	0f 84 cb 08 00 00    	je     f01024f5 <mem_init+0x1258>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c2a:	6a 02                	push   $0x2
f0101c2c:	68 00 10 00 00       	push   $0x1000
f0101c31:	ff 75 d0             	push   -0x30(%ebp)
f0101c34:	50                   	push   %eax
f0101c35:	e8 eb f5 ff ff       	call   f0101225 <page_insert>
f0101c3a:	83 c4 10             	add    $0x10,%esp
f0101c3d:	85 c0                	test   %eax,%eax
f0101c3f:	0f 85 d2 08 00 00    	jne    f0102517 <mem_init+0x127a>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c45:	83 ec 04             	sub    $0x4,%esp
f0101c48:	6a 00                	push   $0x0
f0101c4a:	68 00 10 00 00       	push   $0x1000
f0101c4f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c52:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101c58:	e8 da f3 ff ff       	call   f0101037 <pgdir_walk>
f0101c5d:	83 c4 10             	add    $0x10,%esp
f0101c60:	f6 00 02             	testb  $0x2,(%eax)
f0101c63:	0f 84 d0 08 00 00    	je     f0102539 <mem_init+0x129c>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c69:	83 ec 04             	sub    $0x4,%esp
f0101c6c:	6a 00                	push   $0x0
f0101c6e:	68 00 10 00 00       	push   $0x1000
f0101c73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c76:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101c7c:	e8 b6 f3 ff ff       	call   f0101037 <pgdir_walk>
f0101c81:	83 c4 10             	add    $0x10,%esp
f0101c84:	f6 00 04             	testb  $0x4,(%eax)
f0101c87:	0f 85 ce 08 00 00    	jne    f010255b <mem_init+0x12be>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c8d:	6a 02                	push   $0x2
f0101c8f:	68 00 00 40 00       	push   $0x400000
f0101c94:	ff 75 cc             	push   -0x34(%ebp)
f0101c97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c9a:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101ca0:	e8 80 f5 ff ff       	call   f0101225 <page_insert>
f0101ca5:	83 c4 10             	add    $0x10,%esp
f0101ca8:	85 c0                	test   %eax,%eax
f0101caa:	0f 89 cd 08 00 00    	jns    f010257d <mem_init+0x12e0>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101cb0:	6a 02                	push   $0x2
f0101cb2:	68 00 10 00 00       	push   $0x1000
f0101cb7:	57                   	push   %edi
f0101cb8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cbb:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101cc1:	e8 5f f5 ff ff       	call   f0101225 <page_insert>
f0101cc6:	83 c4 10             	add    $0x10,%esp
f0101cc9:	85 c0                	test   %eax,%eax
f0101ccb:	0f 85 ce 08 00 00    	jne    f010259f <mem_init+0x1302>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101cd1:	83 ec 04             	sub    $0x4,%esp
f0101cd4:	6a 00                	push   $0x0
f0101cd6:	68 00 10 00 00       	push   $0x1000
f0101cdb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cde:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101ce4:	e8 4e f3 ff ff       	call   f0101037 <pgdir_walk>
f0101ce9:	83 c4 10             	add    $0x10,%esp
f0101cec:	f6 00 04             	testb  $0x4,(%eax)
f0101cef:	0f 85 cc 08 00 00    	jne    f01025c1 <mem_init+0x1324>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101cf5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101cf8:	8b b3 d4 1a 00 00    	mov    0x1ad4(%ebx),%esi
f0101cfe:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d03:	89 f0                	mov    %esi,%eax
f0101d05:	e8 20 ed ff ff       	call   f0100a2a <check_va2pa>
f0101d0a:	89 d9                	mov    %ebx,%ecx
f0101d0c:	89 fb                	mov    %edi,%ebx
f0101d0e:	2b 99 d0 1a 00 00    	sub    0x1ad0(%ecx),%ebx
f0101d14:	c1 fb 03             	sar    $0x3,%ebx
f0101d17:	c1 e3 0c             	shl    $0xc,%ebx
f0101d1a:	39 d8                	cmp    %ebx,%eax
f0101d1c:	0f 85 c1 08 00 00    	jne    f01025e3 <mem_init+0x1346>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d22:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d27:	89 f0                	mov    %esi,%eax
f0101d29:	e8 fc ec ff ff       	call   f0100a2a <check_va2pa>
f0101d2e:	39 c3                	cmp    %eax,%ebx
f0101d30:	0f 85 cf 08 00 00    	jne    f0102605 <mem_init+0x1368>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d36:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101d3b:	0f 85 e6 08 00 00    	jne    f0102627 <mem_init+0x138a>
	assert(pp2->pp_ref == 0);
f0101d41:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d44:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101d49:	0f 85 fa 08 00 00    	jne    f0102649 <mem_init+0x13ac>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d4f:	83 ec 0c             	sub    $0xc,%esp
f0101d52:	6a 00                	push   $0x0
f0101d54:	e8 e1 f1 ff ff       	call   f0100f3a <page_alloc>
f0101d59:	83 c4 10             	add    $0x10,%esp
f0101d5c:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101d5f:	0f 85 06 09 00 00    	jne    f010266b <mem_init+0x13ce>
f0101d65:	85 c0                	test   %eax,%eax
f0101d67:	0f 84 fe 08 00 00    	je     f010266b <mem_init+0x13ce>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d6d:	83 ec 08             	sub    $0x8,%esp
f0101d70:	6a 00                	push   $0x0
f0101d72:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d75:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101d7b:	e8 6a f4 ff ff       	call   f01011ea <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d80:	8b 9b d4 1a 00 00    	mov    0x1ad4(%ebx),%ebx
f0101d86:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d8b:	89 d8                	mov    %ebx,%eax
f0101d8d:	e8 98 ec ff ff       	call   f0100a2a <check_va2pa>
f0101d92:	83 c4 10             	add    $0x10,%esp
f0101d95:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d98:	0f 85 ef 08 00 00    	jne    f010268d <mem_init+0x13f0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d9e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101da3:	89 d8                	mov    %ebx,%eax
f0101da5:	e8 80 ec ff ff       	call   f0100a2a <check_va2pa>
f0101daa:	89 c2                	mov    %eax,%edx
f0101dac:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101daf:	89 f8                	mov    %edi,%eax
f0101db1:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0101db7:	c1 f8 03             	sar    $0x3,%eax
f0101dba:	c1 e0 0c             	shl    $0xc,%eax
f0101dbd:	39 c2                	cmp    %eax,%edx
f0101dbf:	0f 85 ea 08 00 00    	jne    f01026af <mem_init+0x1412>
	assert(pp1->pp_ref == 1);
f0101dc5:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101dca:	0f 85 00 09 00 00    	jne    f01026d0 <mem_init+0x1433>
	assert(pp2->pp_ref == 0);
f0101dd0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101dd3:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101dd8:	0f 85 14 09 00 00    	jne    f01026f2 <mem_init+0x1455>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101dde:	6a 00                	push   $0x0
f0101de0:	68 00 10 00 00       	push   $0x1000
f0101de5:	57                   	push   %edi
f0101de6:	53                   	push   %ebx
f0101de7:	e8 39 f4 ff ff       	call   f0101225 <page_insert>
f0101dec:	83 c4 10             	add    $0x10,%esp
f0101def:	85 c0                	test   %eax,%eax
f0101df1:	0f 85 1d 09 00 00    	jne    f0102714 <mem_init+0x1477>
	assert(pp1->pp_ref);
f0101df7:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101dfc:	0f 84 34 09 00 00    	je     f0102736 <mem_init+0x1499>
	assert(pp1->pp_link == NULL);
f0101e02:	83 3f 00             	cmpl   $0x0,(%edi)
f0101e05:	0f 85 4d 09 00 00    	jne    f0102758 <mem_init+0x14bb>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e0b:	83 ec 08             	sub    $0x8,%esp
f0101e0e:	68 00 10 00 00       	push   $0x1000
f0101e13:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e16:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101e1c:	e8 c9 f3 ff ff       	call   f01011ea <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e21:	8b 9b d4 1a 00 00    	mov    0x1ad4(%ebx),%ebx
f0101e27:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e2c:	89 d8                	mov    %ebx,%eax
f0101e2e:	e8 f7 eb ff ff       	call   f0100a2a <check_va2pa>
f0101e33:	83 c4 10             	add    $0x10,%esp
f0101e36:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e39:	0f 85 3b 09 00 00    	jne    f010277a <mem_init+0x14dd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101e3f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e44:	89 d8                	mov    %ebx,%eax
f0101e46:	e8 df eb ff ff       	call   f0100a2a <check_va2pa>
f0101e4b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e4e:	0f 85 48 09 00 00    	jne    f010279c <mem_init+0x14ff>
	assert(pp1->pp_ref == 0);
f0101e54:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101e59:	0f 85 5f 09 00 00    	jne    f01027be <mem_init+0x1521>
	assert(pp2->pp_ref == 0);
f0101e5f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e62:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e67:	0f 85 73 09 00 00    	jne    f01027e0 <mem_init+0x1543>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e6d:	83 ec 0c             	sub    $0xc,%esp
f0101e70:	6a 00                	push   $0x0
f0101e72:	e8 c3 f0 ff ff       	call   f0100f3a <page_alloc>
f0101e77:	83 c4 10             	add    $0x10,%esp
f0101e7a:	85 c0                	test   %eax,%eax
f0101e7c:	0f 84 80 09 00 00    	je     f0102802 <mem_init+0x1565>
f0101e82:	39 c7                	cmp    %eax,%edi
f0101e84:	0f 85 78 09 00 00    	jne    f0102802 <mem_init+0x1565>

	// should be no free memory
	assert(!page_alloc(0));
f0101e8a:	83 ec 0c             	sub    $0xc,%esp
f0101e8d:	6a 00                	push   $0x0
f0101e8f:	e8 a6 f0 ff ff       	call   f0100f3a <page_alloc>
f0101e94:	83 c4 10             	add    $0x10,%esp
f0101e97:	85 c0                	test   %eax,%eax
f0101e99:	0f 85 85 09 00 00    	jne    f0102824 <mem_init+0x1587>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e9f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ea2:	8b 88 d4 1a 00 00    	mov    0x1ad4(%eax),%ecx
f0101ea8:	8b 11                	mov    (%ecx),%edx
f0101eaa:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101eb0:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0101eb3:	2b 98 d0 1a 00 00    	sub    0x1ad0(%eax),%ebx
f0101eb9:	89 d8                	mov    %ebx,%eax
f0101ebb:	c1 f8 03             	sar    $0x3,%eax
f0101ebe:	c1 e0 0c             	shl    $0xc,%eax
f0101ec1:	39 c2                	cmp    %eax,%edx
f0101ec3:	0f 85 7d 09 00 00    	jne    f0102846 <mem_init+0x15a9>
	kern_pgdir[0] = 0;
f0101ec9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101ecf:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101ed2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ed7:	0f 85 8b 09 00 00    	jne    f0102868 <mem_init+0x15cb>
	pp0->pp_ref = 0;
f0101edd:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101ee0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101ee6:	83 ec 0c             	sub    $0xc,%esp
f0101ee9:	50                   	push   %eax
f0101eea:	e8 d0 f0 ff ff       	call   f0100fbf <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101eef:	83 c4 0c             	add    $0xc,%esp
f0101ef2:	6a 01                	push   $0x1
f0101ef4:	68 00 10 40 00       	push   $0x401000
f0101ef9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101efc:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101f02:	e8 30 f1 ff ff       	call   f0101037 <pgdir_walk>
f0101f07:	89 c6                	mov    %eax,%esi
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101f09:	89 d9                	mov    %ebx,%ecx
f0101f0b:	8b 9b d4 1a 00 00    	mov    0x1ad4(%ebx),%ebx
f0101f11:	8b 43 04             	mov    0x4(%ebx),%eax
f0101f14:	89 c2                	mov    %eax,%edx
f0101f16:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101f1c:	8b 89 d8 1a 00 00    	mov    0x1ad8(%ecx),%ecx
f0101f22:	c1 e8 0c             	shr    $0xc,%eax
f0101f25:	83 c4 10             	add    $0x10,%esp
f0101f28:	39 c8                	cmp    %ecx,%eax
f0101f2a:	0f 83 5a 09 00 00    	jae    f010288a <mem_init+0x15ed>
	assert(ptep == ptep1 + PTX(va));
f0101f30:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101f36:	39 d6                	cmp    %edx,%esi
f0101f38:	0f 85 68 09 00 00    	jne    f01028a6 <mem_init+0x1609>
	kern_pgdir[PDX(va)] = 0;
f0101f3e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0101f45:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f48:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101f4e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f51:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101f57:	c1 f8 03             	sar    $0x3,%eax
f0101f5a:	89 c2                	mov    %eax,%edx
f0101f5c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f5f:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101f64:	39 c1                	cmp    %eax,%ecx
f0101f66:	0f 86 5c 09 00 00    	jbe    f01028c8 <mem_init+0x162b>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101f6c:	83 ec 04             	sub    $0x4,%esp
f0101f6f:	68 00 10 00 00       	push   $0x1000
f0101f74:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101f79:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101f7f:	52                   	push   %edx
f0101f80:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f83:	e8 71 29 00 00       	call   f01048f9 <memset>
	page_free(pp0);
f0101f88:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101f8b:	89 34 24             	mov    %esi,(%esp)
f0101f8e:	e8 2c f0 ff ff       	call   f0100fbf <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101f93:	83 c4 0c             	add    $0xc,%esp
f0101f96:	6a 01                	push   $0x1
f0101f98:	6a 00                	push   $0x0
f0101f9a:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101fa0:	e8 92 f0 ff ff       	call   f0101037 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101fa5:	89 f0                	mov    %esi,%eax
f0101fa7:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101fad:	c1 f8 03             	sar    $0x3,%eax
f0101fb0:	89 c2                	mov    %eax,%edx
f0101fb2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101fb5:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101fba:	83 c4 10             	add    $0x10,%esp
f0101fbd:	3b 83 d8 1a 00 00    	cmp    0x1ad8(%ebx),%eax
f0101fc3:	0f 83 15 09 00 00    	jae    f01028de <mem_init+0x1641>
	return (void *)(pa + KERNBASE);
f0101fc9:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101fcf:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101fd5:	8b 30                	mov    (%eax),%esi
f0101fd7:	83 e6 01             	and    $0x1,%esi
f0101fda:	0f 85 17 09 00 00    	jne    f01028f7 <mem_init+0x165a>
	for(i=0; i<NPTENTRIES; i++)
f0101fe0:	83 c0 04             	add    $0x4,%eax
f0101fe3:	39 c2                	cmp    %eax,%edx
f0101fe5:	75 ee                	jne    f0101fd5 <mem_init+0xd38>
	kern_pgdir[0] = 0;
f0101fe7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fea:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
f0101ff0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101ff6:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101ff9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101fff:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102002:	89 93 e0 1a 00 00    	mov    %edx,0x1ae0(%ebx)

	// free the pages we took
	page_free(pp0);
f0102008:	83 ec 0c             	sub    $0xc,%esp
f010200b:	50                   	push   %eax
f010200c:	e8 ae ef ff ff       	call   f0100fbf <page_free>
	page_free(pp1);
f0102011:	89 3c 24             	mov    %edi,(%esp)
f0102014:	e8 a6 ef ff ff       	call   f0100fbf <page_free>
	page_free(pp2);
f0102019:	83 c4 04             	add    $0x4,%esp
f010201c:	ff 75 d0             	push   -0x30(%ebp)
f010201f:	e8 9b ef ff ff       	call   f0100fbf <page_free>

	cprintf("check_page() succeeded!\n");
f0102024:	8d 83 a3 73 f8 ff    	lea    -0x78c5d(%ebx),%eax
f010202a:	89 04 24             	mov    %eax,(%esp)
f010202d:	e8 ca 18 00 00       	call   f01038fc <cprintf>
	boot_map_region(kern_pgdir, (intptr_t)UPAGES, npages * sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f0102032:	8b 83 d0 1a 00 00    	mov    0x1ad0(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102038:	83 c4 10             	add    $0x10,%esp
f010203b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102040:	0f 86 d3 08 00 00    	jbe    f0102919 <mem_init+0x167c>
f0102046:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102049:	8b 8f d8 1a 00 00    	mov    0x1ad8(%edi),%ecx
f010204f:	c1 e1 03             	shl    $0x3,%ecx
f0102052:	83 ec 08             	sub    $0x8,%esp
f0102055:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102057:	05 00 00 00 10       	add    $0x10000000,%eax
f010205c:	50                   	push   %eax
f010205d:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102062:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f0102068:	e8 c4 f0 ff ff       	call   f0101131 <boot_map_region>
	boot_map_region(kern_pgdir, (intptr_t)UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f010206d:	c7 c0 54 03 18 f0    	mov    $0xf0180354,%eax
f0102073:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102075:	83 c4 10             	add    $0x10,%esp
f0102078:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010207d:	0f 86 b2 08 00 00    	jbe    f0102935 <mem_init+0x1698>
f0102083:	83 ec 08             	sub    $0x8,%esp
f0102086:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102088:	05 00 00 00 10       	add    $0x10000000,%eax
f010208d:	50                   	push   %eax
f010208e:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102093:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102098:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010209b:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f01020a1:	e8 8b f0 ff ff       	call   f0101131 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01020a6:	c7 c0 00 20 11 f0    	mov    $0xf0112000,%eax
f01020ac:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01020af:	83 c4 10             	add    $0x10,%esp
f01020b2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020b7:	0f 86 94 08 00 00    	jbe    f0102951 <mem_init+0x16b4>
	boot_map_region(kern_pgdir, (intptr_t)(KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01020bd:	83 ec 08             	sub    $0x8,%esp
f01020c0:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f01020c2:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01020c5:	05 00 00 00 10       	add    $0x10000000,%eax
f01020ca:	50                   	push   %eax
f01020cb:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020d0:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020d5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01020d8:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f01020de:	e8 4e f0 ff ff       	call   f0101131 <boot_map_region>
	boot_map_region(kern_pgdir, (intptr_t)KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f01020e3:	83 c4 08             	add    $0x8,%esp
f01020e6:	6a 03                	push   $0x3
f01020e8:	6a 00                	push   $0x0
f01020ea:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01020ef:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01020f4:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f01020fa:	e8 32 f0 ff ff       	call   f0101131 <boot_map_region>
	pgdir = kern_pgdir;
f01020ff:	89 f9                	mov    %edi,%ecx
f0102101:	8b bf d4 1a 00 00    	mov    0x1ad4(%edi),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102107:	8b 81 d8 1a 00 00    	mov    0x1ad8(%ecx),%eax
f010210d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102110:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102117:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010211c:	89 c2                	mov    %eax,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010211e:	8b 81 d0 1a 00 00    	mov    0x1ad0(%ecx),%eax
f0102124:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0102127:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f010212d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102130:	83 c4 10             	add    $0x10,%esp
f0102133:	89 f3                	mov    %esi,%ebx
f0102135:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102138:	89 c7                	mov    %eax,%edi
f010213a:	89 75 c0             	mov    %esi,-0x40(%ebp)
f010213d:	89 d6                	mov    %edx,%esi
f010213f:	e9 52 08 00 00       	jmp    f0102996 <mem_init+0x16f9>
	assert(nfree == 0);
f0102144:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102147:	8d 83 cc 72 f8 ff    	lea    -0x78d34(%ebx),%eax
f010214d:	50                   	push   %eax
f010214e:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102154:	50                   	push   %eax
f0102155:	68 ff 02 00 00       	push   $0x2ff
f010215a:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102160:	50                   	push   %eax
f0102161:	e8 4b df ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102166:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102169:	8d 83 da 71 f8 ff    	lea    -0x78e26(%ebx),%eax
f010216f:	50                   	push   %eax
f0102170:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102176:	50                   	push   %eax
f0102177:	68 5d 03 00 00       	push   $0x35d
f010217c:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102182:	50                   	push   %eax
f0102183:	e8 29 df ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102188:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010218b:	8d 83 f0 71 f8 ff    	lea    -0x78e10(%ebx),%eax
f0102191:	50                   	push   %eax
f0102192:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102198:	50                   	push   %eax
f0102199:	68 5e 03 00 00       	push   $0x35e
f010219e:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01021a4:	50                   	push   %eax
f01021a5:	e8 07 df ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01021aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021ad:	8d 83 06 72 f8 ff    	lea    -0x78dfa(%ebx),%eax
f01021b3:	50                   	push   %eax
f01021b4:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01021ba:	50                   	push   %eax
f01021bb:	68 5f 03 00 00       	push   $0x35f
f01021c0:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01021c6:	50                   	push   %eax
f01021c7:	e8 e5 de ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01021cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021cf:	8d 83 1c 72 f8 ff    	lea    -0x78de4(%ebx),%eax
f01021d5:	50                   	push   %eax
f01021d6:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01021dc:	50                   	push   %eax
f01021dd:	68 62 03 00 00       	push   $0x362
f01021e2:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01021e8:	50                   	push   %eax
f01021e9:	e8 c3 de ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01021ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021f1:	8d 83 ec 6a f8 ff    	lea    -0x79514(%ebx),%eax
f01021f7:	50                   	push   %eax
f01021f8:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01021fe:	50                   	push   %eax
f01021ff:	68 63 03 00 00       	push   $0x363
f0102204:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010220a:	50                   	push   %eax
f010220b:	e8 a1 de ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102210:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102213:	8d 83 85 72 f8 ff    	lea    -0x78d7b(%ebx),%eax
f0102219:	50                   	push   %eax
f010221a:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102220:	50                   	push   %eax
f0102221:	68 6a 03 00 00       	push   $0x36a
f0102226:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010222c:	50                   	push   %eax
f010222d:	e8 7f de ff ff       	call   f01000b1 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102232:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102235:	8d 83 2c 6b f8 ff    	lea    -0x794d4(%ebx),%eax
f010223b:	50                   	push   %eax
f010223c:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102242:	50                   	push   %eax
f0102243:	68 6d 03 00 00       	push   $0x36d
f0102248:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010224e:	50                   	push   %eax
f010224f:	e8 5d de ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102254:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102257:	8d 83 64 6b f8 ff    	lea    -0x7949c(%ebx),%eax
f010225d:	50                   	push   %eax
f010225e:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102264:	50                   	push   %eax
f0102265:	68 70 03 00 00       	push   $0x370
f010226a:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102270:	50                   	push   %eax
f0102271:	e8 3b de ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102276:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102279:	8d 83 94 6b f8 ff    	lea    -0x7946c(%ebx),%eax
f010227f:	50                   	push   %eax
f0102280:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102286:	50                   	push   %eax
f0102287:	68 74 03 00 00       	push   $0x374
f010228c:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102292:	50                   	push   %eax
f0102293:	e8 19 de ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102298:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010229b:	8d 83 c4 6b f8 ff    	lea    -0x7943c(%ebx),%eax
f01022a1:	50                   	push   %eax
f01022a2:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01022a8:	50                   	push   %eax
f01022a9:	68 75 03 00 00       	push   $0x375
f01022ae:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01022b4:	50                   	push   %eax
f01022b5:	e8 f7 dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022bd:	8d 83 ec 6b f8 ff    	lea    -0x79414(%ebx),%eax
f01022c3:	50                   	push   %eax
f01022c4:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01022ca:	50                   	push   %eax
f01022cb:	68 76 03 00 00       	push   $0x376
f01022d0:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01022d6:	50                   	push   %eax
f01022d7:	e8 d5 dd ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f01022dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022df:	8d 83 d7 72 f8 ff    	lea    -0x78d29(%ebx),%eax
f01022e5:	50                   	push   %eax
f01022e6:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01022ec:	50                   	push   %eax
f01022ed:	68 77 03 00 00       	push   $0x377
f01022f2:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01022f8:	50                   	push   %eax
f01022f9:	e8 b3 dd ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f01022fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102301:	8d 83 e8 72 f8 ff    	lea    -0x78d18(%ebx),%eax
f0102307:	50                   	push   %eax
f0102308:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010230e:	50                   	push   %eax
f010230f:	68 78 03 00 00       	push   $0x378
f0102314:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010231a:	50                   	push   %eax
f010231b:	e8 91 dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102320:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102323:	8d 83 1c 6c f8 ff    	lea    -0x793e4(%ebx),%eax
f0102329:	50                   	push   %eax
f010232a:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102330:	50                   	push   %eax
f0102331:	68 7b 03 00 00       	push   $0x37b
f0102336:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010233c:	50                   	push   %eax
f010233d:	e8 6f dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102342:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102345:	8d 83 58 6c f8 ff    	lea    -0x793a8(%ebx),%eax
f010234b:	50                   	push   %eax
f010234c:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102352:	50                   	push   %eax
f0102353:	68 7c 03 00 00       	push   $0x37c
f0102358:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010235e:	50                   	push   %eax
f010235f:	e8 4d dd ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102364:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102367:	8d 83 f9 72 f8 ff    	lea    -0x78d07(%ebx),%eax
f010236d:	50                   	push   %eax
f010236e:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102374:	50                   	push   %eax
f0102375:	68 7d 03 00 00       	push   $0x37d
f010237a:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102380:	50                   	push   %eax
f0102381:	e8 2b dd ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102386:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102389:	8d 83 85 72 f8 ff    	lea    -0x78d7b(%ebx),%eax
f010238f:	50                   	push   %eax
f0102390:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102396:	50                   	push   %eax
f0102397:	68 80 03 00 00       	push   $0x380
f010239c:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01023a2:	50                   	push   %eax
f01023a3:	e8 09 dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023a8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ab:	8d 83 1c 6c f8 ff    	lea    -0x793e4(%ebx),%eax
f01023b1:	50                   	push   %eax
f01023b2:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01023b8:	50                   	push   %eax
f01023b9:	68 83 03 00 00       	push   $0x383
f01023be:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01023c4:	50                   	push   %eax
f01023c5:	e8 e7 dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023cd:	8d 83 58 6c f8 ff    	lea    -0x793a8(%ebx),%eax
f01023d3:	50                   	push   %eax
f01023d4:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01023da:	50                   	push   %eax
f01023db:	68 84 03 00 00       	push   $0x384
f01023e0:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01023e6:	50                   	push   %eax
f01023e7:	e8 c5 dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01023ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ef:	8d 83 f9 72 f8 ff    	lea    -0x78d07(%ebx),%eax
f01023f5:	50                   	push   %eax
f01023f6:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01023fc:	50                   	push   %eax
f01023fd:	68 85 03 00 00       	push   $0x385
f0102402:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102408:	50                   	push   %eax
f0102409:	e8 a3 dc ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010240e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102411:	8d 83 85 72 f8 ff    	lea    -0x78d7b(%ebx),%eax
f0102417:	50                   	push   %eax
f0102418:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010241e:	50                   	push   %eax
f010241f:	68 89 03 00 00       	push   $0x389
f0102424:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010242a:	50                   	push   %eax
f010242b:	e8 81 dc ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102430:	53                   	push   %ebx
f0102431:	89 cb                	mov    %ecx,%ebx
f0102433:	8d 81 3c 69 f8 ff    	lea    -0x796c4(%ecx),%eax
f0102439:	50                   	push   %eax
f010243a:	68 8c 03 00 00       	push   $0x38c
f010243f:	8d 81 09 71 f8 ff    	lea    -0x78ef7(%ecx),%eax
f0102445:	50                   	push   %eax
f0102446:	e8 66 dc ff ff       	call   f01000b1 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010244b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010244e:	8d 83 88 6c f8 ff    	lea    -0x79378(%ebx),%eax
f0102454:	50                   	push   %eax
f0102455:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010245b:	50                   	push   %eax
f010245c:	68 8d 03 00 00       	push   $0x38d
f0102461:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102467:	50                   	push   %eax
f0102468:	e8 44 dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010246d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102470:	8d 83 c8 6c f8 ff    	lea    -0x79338(%ebx),%eax
f0102476:	50                   	push   %eax
f0102477:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010247d:	50                   	push   %eax
f010247e:	68 90 03 00 00       	push   $0x390
f0102483:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102489:	50                   	push   %eax
f010248a:	e8 22 dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010248f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102492:	8d 83 58 6c f8 ff    	lea    -0x793a8(%ebx),%eax
f0102498:	50                   	push   %eax
f0102499:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010249f:	50                   	push   %eax
f01024a0:	68 91 03 00 00       	push   $0x391
f01024a5:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01024ab:	50                   	push   %eax
f01024ac:	e8 00 dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01024b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024b4:	8d 83 f9 72 f8 ff    	lea    -0x78d07(%ebx),%eax
f01024ba:	50                   	push   %eax
f01024bb:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01024c1:	50                   	push   %eax
f01024c2:	68 92 03 00 00       	push   $0x392
f01024c7:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01024cd:	50                   	push   %eax
f01024ce:	e8 de db ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024d6:	8d 83 08 6d f8 ff    	lea    -0x792f8(%ebx),%eax
f01024dc:	50                   	push   %eax
f01024dd:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01024e3:	50                   	push   %eax
f01024e4:	68 93 03 00 00       	push   $0x393
f01024e9:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01024ef:	50                   	push   %eax
f01024f0:	e8 bc db ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024f8:	8d 83 0a 73 f8 ff    	lea    -0x78cf6(%ebx),%eax
f01024fe:	50                   	push   %eax
f01024ff:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102505:	50                   	push   %eax
f0102506:	68 94 03 00 00       	push   $0x394
f010250b:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102511:	50                   	push   %eax
f0102512:	e8 9a db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102517:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010251a:	8d 83 1c 6c f8 ff    	lea    -0x793e4(%ebx),%eax
f0102520:	50                   	push   %eax
f0102521:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102527:	50                   	push   %eax
f0102528:	68 97 03 00 00       	push   $0x397
f010252d:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102533:	50                   	push   %eax
f0102534:	e8 78 db ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102539:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010253c:	8d 83 3c 6d f8 ff    	lea    -0x792c4(%ebx),%eax
f0102542:	50                   	push   %eax
f0102543:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102549:	50                   	push   %eax
f010254a:	68 98 03 00 00       	push   $0x398
f010254f:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102555:	50                   	push   %eax
f0102556:	e8 56 db ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010255b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010255e:	8d 83 70 6d f8 ff    	lea    -0x79290(%ebx),%eax
f0102564:	50                   	push   %eax
f0102565:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010256b:	50                   	push   %eax
f010256c:	68 99 03 00 00       	push   $0x399
f0102571:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102577:	50                   	push   %eax
f0102578:	e8 34 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010257d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102580:	8d 83 a8 6d f8 ff    	lea    -0x79258(%ebx),%eax
f0102586:	50                   	push   %eax
f0102587:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010258d:	50                   	push   %eax
f010258e:	68 9c 03 00 00       	push   $0x39c
f0102593:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102599:	50                   	push   %eax
f010259a:	e8 12 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010259f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025a2:	8d 83 e0 6d f8 ff    	lea    -0x79220(%ebx),%eax
f01025a8:	50                   	push   %eax
f01025a9:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01025af:	50                   	push   %eax
f01025b0:	68 9f 03 00 00       	push   $0x39f
f01025b5:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01025bb:	50                   	push   %eax
f01025bc:	e8 f0 da ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025c4:	8d 83 70 6d f8 ff    	lea    -0x79290(%ebx),%eax
f01025ca:	50                   	push   %eax
f01025cb:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01025d1:	50                   	push   %eax
f01025d2:	68 a0 03 00 00       	push   $0x3a0
f01025d7:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01025dd:	50                   	push   %eax
f01025de:	e8 ce da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01025e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025e6:	8d 83 1c 6e f8 ff    	lea    -0x791e4(%ebx),%eax
f01025ec:	50                   	push   %eax
f01025ed:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01025f3:	50                   	push   %eax
f01025f4:	68 a3 03 00 00       	push   $0x3a3
f01025f9:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01025ff:	50                   	push   %eax
f0102600:	e8 ac da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102605:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102608:	8d 83 48 6e f8 ff    	lea    -0x791b8(%ebx),%eax
f010260e:	50                   	push   %eax
f010260f:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102615:	50                   	push   %eax
f0102616:	68 a4 03 00 00       	push   $0x3a4
f010261b:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102621:	50                   	push   %eax
f0102622:	e8 8a da ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 2);
f0102627:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010262a:	8d 83 20 73 f8 ff    	lea    -0x78ce0(%ebx),%eax
f0102630:	50                   	push   %eax
f0102631:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102637:	50                   	push   %eax
f0102638:	68 a6 03 00 00       	push   $0x3a6
f010263d:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102643:	50                   	push   %eax
f0102644:	e8 68 da ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102649:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010264c:	8d 83 31 73 f8 ff    	lea    -0x78ccf(%ebx),%eax
f0102652:	50                   	push   %eax
f0102653:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102659:	50                   	push   %eax
f010265a:	68 a7 03 00 00       	push   $0x3a7
f010265f:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102665:	50                   	push   %eax
f0102666:	e8 46 da ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010266b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010266e:	8d 83 78 6e f8 ff    	lea    -0x79188(%ebx),%eax
f0102674:	50                   	push   %eax
f0102675:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010267b:	50                   	push   %eax
f010267c:	68 aa 03 00 00       	push   $0x3aa
f0102681:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102687:	50                   	push   %eax
f0102688:	e8 24 da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010268d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102690:	8d 83 9c 6e f8 ff    	lea    -0x79164(%ebx),%eax
f0102696:	50                   	push   %eax
f0102697:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010269d:	50                   	push   %eax
f010269e:	68 ae 03 00 00       	push   $0x3ae
f01026a3:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01026a9:	50                   	push   %eax
f01026aa:	e8 02 da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026af:	89 cb                	mov    %ecx,%ebx
f01026b1:	8d 81 48 6e f8 ff    	lea    -0x791b8(%ecx),%eax
f01026b7:	50                   	push   %eax
f01026b8:	8d 81 2f 71 f8 ff    	lea    -0x78ed1(%ecx),%eax
f01026be:	50                   	push   %eax
f01026bf:	68 af 03 00 00       	push   $0x3af
f01026c4:	8d 81 09 71 f8 ff    	lea    -0x78ef7(%ecx),%eax
f01026ca:	50                   	push   %eax
f01026cb:	e8 e1 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f01026d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026d3:	8d 83 d7 72 f8 ff    	lea    -0x78d29(%ebx),%eax
f01026d9:	50                   	push   %eax
f01026da:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01026e0:	50                   	push   %eax
f01026e1:	68 b0 03 00 00       	push   $0x3b0
f01026e6:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01026ec:	50                   	push   %eax
f01026ed:	e8 bf d9 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01026f2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026f5:	8d 83 31 73 f8 ff    	lea    -0x78ccf(%ebx),%eax
f01026fb:	50                   	push   %eax
f01026fc:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102702:	50                   	push   %eax
f0102703:	68 b1 03 00 00       	push   $0x3b1
f0102708:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010270e:	50                   	push   %eax
f010270f:	e8 9d d9 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102714:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102717:	8d 83 c0 6e f8 ff    	lea    -0x79140(%ebx),%eax
f010271d:	50                   	push   %eax
f010271e:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102724:	50                   	push   %eax
f0102725:	68 b4 03 00 00       	push   $0x3b4
f010272a:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102730:	50                   	push   %eax
f0102731:	e8 7b d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f0102736:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102739:	8d 83 42 73 f8 ff    	lea    -0x78cbe(%ebx),%eax
f010273f:	50                   	push   %eax
f0102740:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102746:	50                   	push   %eax
f0102747:	68 b5 03 00 00       	push   $0x3b5
f010274c:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102752:	50                   	push   %eax
f0102753:	e8 59 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f0102758:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010275b:	8d 83 4e 73 f8 ff    	lea    -0x78cb2(%ebx),%eax
f0102761:	50                   	push   %eax
f0102762:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102768:	50                   	push   %eax
f0102769:	68 b6 03 00 00       	push   $0x3b6
f010276e:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102774:	50                   	push   %eax
f0102775:	e8 37 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010277a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010277d:	8d 83 9c 6e f8 ff    	lea    -0x79164(%ebx),%eax
f0102783:	50                   	push   %eax
f0102784:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010278a:	50                   	push   %eax
f010278b:	68 ba 03 00 00       	push   $0x3ba
f0102790:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102796:	50                   	push   %eax
f0102797:	e8 15 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010279c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010279f:	8d 83 f8 6e f8 ff    	lea    -0x79108(%ebx),%eax
f01027a5:	50                   	push   %eax
f01027a6:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01027ac:	50                   	push   %eax
f01027ad:	68 bb 03 00 00       	push   $0x3bb
f01027b2:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01027b8:	50                   	push   %eax
f01027b9:	e8 f3 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f01027be:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027c1:	8d 83 63 73 f8 ff    	lea    -0x78c9d(%ebx),%eax
f01027c7:	50                   	push   %eax
f01027c8:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01027ce:	50                   	push   %eax
f01027cf:	68 bc 03 00 00       	push   $0x3bc
f01027d4:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01027da:	50                   	push   %eax
f01027db:	e8 d1 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01027e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027e3:	8d 83 31 73 f8 ff    	lea    -0x78ccf(%ebx),%eax
f01027e9:	50                   	push   %eax
f01027ea:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01027f0:	50                   	push   %eax
f01027f1:	68 bd 03 00 00       	push   $0x3bd
f01027f6:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01027fc:	50                   	push   %eax
f01027fd:	e8 af d8 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102802:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102805:	8d 83 20 6f f8 ff    	lea    -0x790e0(%ebx),%eax
f010280b:	50                   	push   %eax
f010280c:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102812:	50                   	push   %eax
f0102813:	68 c0 03 00 00       	push   $0x3c0
f0102818:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010281e:	50                   	push   %eax
f010281f:	e8 8d d8 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102824:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102827:	8d 83 85 72 f8 ff    	lea    -0x78d7b(%ebx),%eax
f010282d:	50                   	push   %eax
f010282e:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102834:	50                   	push   %eax
f0102835:	68 c3 03 00 00       	push   $0x3c3
f010283a:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102840:	50                   	push   %eax
f0102841:	e8 6b d8 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102846:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102849:	8d 83 c4 6b f8 ff    	lea    -0x7943c(%ebx),%eax
f010284f:	50                   	push   %eax
f0102850:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102856:	50                   	push   %eax
f0102857:	68 c6 03 00 00       	push   $0x3c6
f010285c:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102862:	50                   	push   %eax
f0102863:	e8 49 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102868:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010286b:	8d 83 e8 72 f8 ff    	lea    -0x78d18(%ebx),%eax
f0102871:	50                   	push   %eax
f0102872:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102878:	50                   	push   %eax
f0102879:	68 c8 03 00 00       	push   $0x3c8
f010287e:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102884:	50                   	push   %eax
f0102885:	e8 27 d8 ff ff       	call   f01000b1 <_panic>
f010288a:	52                   	push   %edx
f010288b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010288e:	8d 83 3c 69 f8 ff    	lea    -0x796c4(%ebx),%eax
f0102894:	50                   	push   %eax
f0102895:	68 cf 03 00 00       	push   $0x3cf
f010289a:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01028a0:	50                   	push   %eax
f01028a1:	e8 0b d8 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028a6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028a9:	8d 83 74 73 f8 ff    	lea    -0x78c8c(%ebx),%eax
f01028af:	50                   	push   %eax
f01028b0:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01028b6:	50                   	push   %eax
f01028b7:	68 d0 03 00 00       	push   $0x3d0
f01028bc:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01028c2:	50                   	push   %eax
f01028c3:	e8 e9 d7 ff ff       	call   f01000b1 <_panic>
f01028c8:	52                   	push   %edx
f01028c9:	8d 83 3c 69 f8 ff    	lea    -0x796c4(%ebx),%eax
f01028cf:	50                   	push   %eax
f01028d0:	6a 56                	push   $0x56
f01028d2:	8d 83 15 71 f8 ff    	lea    -0x78eeb(%ebx),%eax
f01028d8:	50                   	push   %eax
f01028d9:	e8 d3 d7 ff ff       	call   f01000b1 <_panic>
f01028de:	52                   	push   %edx
f01028df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028e2:	8d 83 3c 69 f8 ff    	lea    -0x796c4(%ebx),%eax
f01028e8:	50                   	push   %eax
f01028e9:	6a 56                	push   $0x56
f01028eb:	8d 83 15 71 f8 ff    	lea    -0x78eeb(%ebx),%eax
f01028f1:	50                   	push   %eax
f01028f2:	e8 ba d7 ff ff       	call   f01000b1 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f01028f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028fa:	8d 83 8c 73 f8 ff    	lea    -0x78c74(%ebx),%eax
f0102900:	50                   	push   %eax
f0102901:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102907:	50                   	push   %eax
f0102908:	68 da 03 00 00       	push   $0x3da
f010290d:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102913:	50                   	push   %eax
f0102914:	e8 98 d7 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102919:	50                   	push   %eax
f010291a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010291d:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f0102923:	50                   	push   %eax
f0102924:	68 bb 00 00 00       	push   $0xbb
f0102929:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010292f:	50                   	push   %eax
f0102930:	e8 7c d7 ff ff       	call   f01000b1 <_panic>
f0102935:	50                   	push   %eax
f0102936:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102939:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f010293f:	50                   	push   %eax
f0102940:	68 c5 00 00 00       	push   $0xc5
f0102945:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010294b:	50                   	push   %eax
f010294c:	e8 60 d7 ff ff       	call   f01000b1 <_panic>
f0102951:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102954:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f010295a:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f0102960:	50                   	push   %eax
f0102961:	68 d2 00 00 00       	push   $0xd2
f0102966:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010296c:	50                   	push   %eax
f010296d:	e8 3f d7 ff ff       	call   f01000b1 <_panic>
f0102972:	ff 75 bc             	push   -0x44(%ebp)
f0102975:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102978:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f010297e:	50                   	push   %eax
f010297f:	68 17 03 00 00       	push   $0x317
f0102984:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f010298a:	50                   	push   %eax
f010298b:	e8 21 d7 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102990:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102996:	39 de                	cmp    %ebx,%esi
f0102998:	76 42                	jbe    f01029dc <mem_init+0x173f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010299a:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01029a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01029a3:	e8 82 e0 ff ff       	call   f0100a2a <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01029a8:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01029ae:	76 c2                	jbe    f0102972 <mem_init+0x16d5>
f01029b0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01029b3:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01029b6:	39 c2                	cmp    %eax,%edx
f01029b8:	74 d6                	je     f0102990 <mem_init+0x16f3>
f01029ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029bd:	8d 83 44 6f f8 ff    	lea    -0x790bc(%ebx),%eax
f01029c3:	50                   	push   %eax
f01029c4:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f01029ca:	50                   	push   %eax
f01029cb:	68 17 03 00 00       	push   $0x317
f01029d0:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f01029d6:	50                   	push   %eax
f01029d7:	e8 d5 d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029dc:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01029df:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01029e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029e5:	c7 c0 54 03 18 f0    	mov    $0xf0180354,%eax
f01029eb:	8b 00                	mov    (%eax),%eax
f01029ed:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01029f0:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01029f5:	8d 88 00 00 40 21    	lea    0x21400000(%eax),%ecx
f01029fb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01029fe:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102a01:	89 c6                	mov    %eax,%esi
f0102a03:	89 da                	mov    %ebx,%edx
f0102a05:	89 f8                	mov    %edi,%eax
f0102a07:	e8 1e e0 ff ff       	call   f0100a2a <check_va2pa>
f0102a0c:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102a12:	76 45                	jbe    f0102a59 <mem_init+0x17bc>
f0102a14:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102a17:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102a1a:	39 c2                	cmp    %eax,%edx
f0102a1c:	75 59                	jne    f0102a77 <mem_init+0x17da>
	for (i = 0; i < n; i += PGSIZE)
f0102a1e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a24:	81 fb 00 80 c1 ee    	cmp    $0xeec18000,%ebx
f0102a2a:	75 d7                	jne    f0102a03 <mem_init+0x1766>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a2c:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102a2f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0102a32:	c1 e0 0c             	shl    $0xc,%eax
f0102a35:	89 f3                	mov    %esi,%ebx
f0102a37:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102a3a:	89 c6                	mov    %eax,%esi
f0102a3c:	39 f3                	cmp    %esi,%ebx
f0102a3e:	73 7b                	jae    f0102abb <mem_init+0x181e>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a40:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102a46:	89 f8                	mov    %edi,%eax
f0102a48:	e8 dd df ff ff       	call   f0100a2a <check_va2pa>
f0102a4d:	39 c3                	cmp    %eax,%ebx
f0102a4f:	75 48                	jne    f0102a99 <mem_init+0x17fc>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a51:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a57:	eb e3                	jmp    f0102a3c <mem_init+0x179f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a59:	ff 75 c0             	push   -0x40(%ebp)
f0102a5c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a5f:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f0102a65:	50                   	push   %eax
f0102a66:	68 1c 03 00 00       	push   $0x31c
f0102a6b:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102a71:	50                   	push   %eax
f0102a72:	e8 3a d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102a77:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a7a:	8d 83 78 6f f8 ff    	lea    -0x79088(%ebx),%eax
f0102a80:	50                   	push   %eax
f0102a81:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102a87:	50                   	push   %eax
f0102a88:	68 1c 03 00 00       	push   $0x31c
f0102a8d:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102a93:	50                   	push   %eax
f0102a94:	e8 18 d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a99:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a9c:	8d 83 ac 6f f8 ff    	lea    -0x79054(%ebx),%eax
f0102aa2:	50                   	push   %eax
f0102aa3:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102aa9:	50                   	push   %eax
f0102aaa:	68 20 03 00 00       	push   $0x320
f0102aaf:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102ab5:	50                   	push   %eax
f0102ab6:	e8 f6 d5 ff ff       	call   f01000b1 <_panic>
f0102abb:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102ac0:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102ac3:	05 00 80 00 20       	add    $0x20008000,%eax
f0102ac8:	89 c6                	mov    %eax,%esi
f0102aca:	89 da                	mov    %ebx,%edx
f0102acc:	89 f8                	mov    %edi,%eax
f0102ace:	e8 57 df ff ff       	call   f0100a2a <check_va2pa>
f0102ad3:	89 c2                	mov    %eax,%edx
f0102ad5:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0102ad8:	39 c2                	cmp    %eax,%edx
f0102ada:	75 44                	jne    f0102b20 <mem_init+0x1883>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102adc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ae2:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102ae8:	75 e0                	jne    f0102aca <mem_init+0x182d>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102aea:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102aed:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102af2:	89 f8                	mov    %edi,%eax
f0102af4:	e8 31 df ff ff       	call   f0100a2a <check_va2pa>
f0102af9:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102afc:	74 71                	je     f0102b6f <mem_init+0x18d2>
f0102afe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b01:	8d 83 1c 70 f8 ff    	lea    -0x78fe4(%ebx),%eax
f0102b07:	50                   	push   %eax
f0102b08:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102b0e:	50                   	push   %eax
f0102b0f:	68 25 03 00 00       	push   $0x325
f0102b14:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102b1a:	50                   	push   %eax
f0102b1b:	e8 91 d5 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102b20:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b23:	8d 83 d4 6f f8 ff    	lea    -0x7902c(%ebx),%eax
f0102b29:	50                   	push   %eax
f0102b2a:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102b30:	50                   	push   %eax
f0102b31:	68 24 03 00 00       	push   $0x324
f0102b36:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102b3c:	50                   	push   %eax
f0102b3d:	e8 6f d5 ff ff       	call   f01000b1 <_panic>
		switch (i) {
f0102b42:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102b48:	75 25                	jne    f0102b6f <mem_init+0x18d2>
			assert(pgdir[i] & PTE_P);
f0102b4a:	f6 04 b7 01          	testb  $0x1,(%edi,%esi,4)
f0102b4e:	74 4f                	je     f0102b9f <mem_init+0x1902>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b50:	83 c6 01             	add    $0x1,%esi
f0102b53:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f0102b59:	0f 87 b1 00 00 00    	ja     f0102c10 <mem_init+0x1973>
		switch (i) {
f0102b5f:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f0102b65:	77 db                	ja     f0102b42 <mem_init+0x18a5>
f0102b67:	81 fe ba 03 00 00    	cmp    $0x3ba,%esi
f0102b6d:	77 db                	ja     f0102b4a <mem_init+0x18ad>
			if (i >= PDX(KERNBASE)) {
f0102b6f:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102b75:	77 4a                	ja     f0102bc1 <mem_init+0x1924>
				assert(pgdir[i] == 0);
f0102b77:	83 3c b7 00          	cmpl   $0x0,(%edi,%esi,4)
f0102b7b:	74 d3                	je     f0102b50 <mem_init+0x18b3>
f0102b7d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b80:	8d 83 de 73 f8 ff    	lea    -0x78c22(%ebx),%eax
f0102b86:	50                   	push   %eax
f0102b87:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102b8d:	50                   	push   %eax
f0102b8e:	68 35 03 00 00       	push   $0x335
f0102b93:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102b99:	50                   	push   %eax
f0102b9a:	e8 12 d5 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102b9f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ba2:	8d 83 bc 73 f8 ff    	lea    -0x78c44(%ebx),%eax
f0102ba8:	50                   	push   %eax
f0102ba9:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102baf:	50                   	push   %eax
f0102bb0:	68 2e 03 00 00       	push   $0x32e
f0102bb5:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102bbb:	50                   	push   %eax
f0102bbc:	e8 f0 d4 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102bc1:	8b 04 b7             	mov    (%edi,%esi,4),%eax
f0102bc4:	a8 01                	test   $0x1,%al
f0102bc6:	74 26                	je     f0102bee <mem_init+0x1951>
				assert(pgdir[i] & PTE_W);
f0102bc8:	a8 02                	test   $0x2,%al
f0102bca:	75 84                	jne    f0102b50 <mem_init+0x18b3>
f0102bcc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bcf:	8d 83 cd 73 f8 ff    	lea    -0x78c33(%ebx),%eax
f0102bd5:	50                   	push   %eax
f0102bd6:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102bdc:	50                   	push   %eax
f0102bdd:	68 33 03 00 00       	push   $0x333
f0102be2:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102be8:	50                   	push   %eax
f0102be9:	e8 c3 d4 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102bee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bf1:	8d 83 bc 73 f8 ff    	lea    -0x78c44(%ebx),%eax
f0102bf7:	50                   	push   %eax
f0102bf8:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102bfe:	50                   	push   %eax
f0102bff:	68 32 03 00 00       	push   $0x332
f0102c04:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102c0a:	50                   	push   %eax
f0102c0b:	e8 a1 d4 ff ff       	call   f01000b1 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c10:	83 ec 0c             	sub    $0xc,%esp
f0102c13:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c16:	8d 83 4c 70 f8 ff    	lea    -0x78fb4(%ebx),%eax
f0102c1c:	50                   	push   %eax
f0102c1d:	e8 da 0c 00 00       	call   f01038fc <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102c22:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102c28:	83 c4 10             	add    $0x10,%esp
f0102c2b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c30:	0f 86 2c 02 00 00    	jbe    f0102e62 <mem_init+0x1bc5>
	return (physaddr_t)kva - KERNBASE;
f0102c36:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102c3b:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102c3e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c43:	e8 5e de ff ff       	call   f0100aa6 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102c48:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102c4b:	83 e0 f3             	and    $0xfffffff3,%eax
f0102c4e:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102c53:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c56:	83 ec 0c             	sub    $0xc,%esp
f0102c59:	6a 00                	push   $0x0
f0102c5b:	e8 da e2 ff ff       	call   f0100f3a <page_alloc>
f0102c60:	89 c6                	mov    %eax,%esi
f0102c62:	83 c4 10             	add    $0x10,%esp
f0102c65:	85 c0                	test   %eax,%eax
f0102c67:	0f 84 11 02 00 00    	je     f0102e7e <mem_init+0x1be1>
	assert((pp1 = page_alloc(0)));
f0102c6d:	83 ec 0c             	sub    $0xc,%esp
f0102c70:	6a 00                	push   $0x0
f0102c72:	e8 c3 e2 ff ff       	call   f0100f3a <page_alloc>
f0102c77:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102c7a:	83 c4 10             	add    $0x10,%esp
f0102c7d:	85 c0                	test   %eax,%eax
f0102c7f:	0f 84 1b 02 00 00    	je     f0102ea0 <mem_init+0x1c03>
	assert((pp2 = page_alloc(0)));
f0102c85:	83 ec 0c             	sub    $0xc,%esp
f0102c88:	6a 00                	push   $0x0
f0102c8a:	e8 ab e2 ff ff       	call   f0100f3a <page_alloc>
f0102c8f:	89 c7                	mov    %eax,%edi
f0102c91:	83 c4 10             	add    $0x10,%esp
f0102c94:	85 c0                	test   %eax,%eax
f0102c96:	0f 84 26 02 00 00    	je     f0102ec2 <mem_init+0x1c25>
	page_free(pp0);
f0102c9c:	83 ec 0c             	sub    $0xc,%esp
f0102c9f:	56                   	push   %esi
f0102ca0:	e8 1a e3 ff ff       	call   f0100fbf <page_free>
	return (pp - pages) << PGSHIFT;
f0102ca5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102ca8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102cab:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0102cb1:	c1 f8 03             	sar    $0x3,%eax
f0102cb4:	89 c2                	mov    %eax,%edx
f0102cb6:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102cb9:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102cbe:	83 c4 10             	add    $0x10,%esp
f0102cc1:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0102cc7:	0f 83 17 02 00 00    	jae    f0102ee4 <mem_init+0x1c47>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ccd:	83 ec 04             	sub    $0x4,%esp
f0102cd0:	68 00 10 00 00       	push   $0x1000
f0102cd5:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102cd7:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102cdd:	52                   	push   %edx
f0102cde:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ce1:	e8 13 1c 00 00       	call   f01048f9 <memset>
	return (pp - pages) << PGSHIFT;
f0102ce6:	89 f8                	mov    %edi,%eax
f0102ce8:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0102cee:	c1 f8 03             	sar    $0x3,%eax
f0102cf1:	89 c2                	mov    %eax,%edx
f0102cf3:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102cf6:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102cfb:	83 c4 10             	add    $0x10,%esp
f0102cfe:	3b 83 d8 1a 00 00    	cmp    0x1ad8(%ebx),%eax
f0102d04:	0f 83 f2 01 00 00    	jae    f0102efc <mem_init+0x1c5f>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d0a:	83 ec 04             	sub    $0x4,%esp
f0102d0d:	68 00 10 00 00       	push   $0x1000
f0102d12:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102d14:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d1a:	52                   	push   %edx
f0102d1b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d1e:	e8 d6 1b 00 00       	call   f01048f9 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d23:	6a 02                	push   $0x2
f0102d25:	68 00 10 00 00       	push   $0x1000
f0102d2a:	ff 75 d0             	push   -0x30(%ebp)
f0102d2d:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0102d33:	e8 ed e4 ff ff       	call   f0101225 <page_insert>
	assert(pp1->pp_ref == 1);
f0102d38:	83 c4 20             	add    $0x20,%esp
f0102d3b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d3e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102d43:	0f 85 cc 01 00 00    	jne    f0102f15 <mem_init+0x1c78>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d49:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d50:	01 01 01 
f0102d53:	0f 85 de 01 00 00    	jne    f0102f37 <mem_init+0x1c9a>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d59:	6a 02                	push   $0x2
f0102d5b:	68 00 10 00 00       	push   $0x1000
f0102d60:	57                   	push   %edi
f0102d61:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d64:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0102d6a:	e8 b6 e4 ff ff       	call   f0101225 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d6f:	83 c4 10             	add    $0x10,%esp
f0102d72:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d79:	02 02 02 
f0102d7c:	0f 85 d7 01 00 00    	jne    f0102f59 <mem_init+0x1cbc>
	assert(pp2->pp_ref == 1);
f0102d82:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d87:	0f 85 ee 01 00 00    	jne    f0102f7b <mem_init+0x1cde>
	assert(pp1->pp_ref == 0);
f0102d8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d90:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102d95:	0f 85 02 02 00 00    	jne    f0102f9d <mem_init+0x1d00>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d9b:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102da2:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102da5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102da8:	89 f8                	mov    %edi,%eax
f0102daa:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0102db0:	c1 f8 03             	sar    $0x3,%eax
f0102db3:	89 c2                	mov    %eax,%edx
f0102db5:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102db8:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102dbd:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0102dc3:	0f 83 f6 01 00 00    	jae    f0102fbf <mem_init+0x1d22>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102dc9:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102dd0:	03 03 03 
f0102dd3:	0f 85 fe 01 00 00    	jne    f0102fd7 <mem_init+0x1d3a>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102dd9:	83 ec 08             	sub    $0x8,%esp
f0102ddc:	68 00 10 00 00       	push   $0x1000
f0102de1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102de4:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0102dea:	e8 fb e3 ff ff       	call   f01011ea <page_remove>
	assert(pp2->pp_ref == 0);
f0102def:	83 c4 10             	add    $0x10,%esp
f0102df2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102df7:	0f 85 fc 01 00 00    	jne    f0102ff9 <mem_init+0x1d5c>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102dfd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e00:	8b 88 d4 1a 00 00    	mov    0x1ad4(%eax),%ecx
f0102e06:	8b 11                	mov    (%ecx),%edx
f0102e08:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102e0e:	89 f7                	mov    %esi,%edi
f0102e10:	2b b8 d0 1a 00 00    	sub    0x1ad0(%eax),%edi
f0102e16:	89 f8                	mov    %edi,%eax
f0102e18:	c1 f8 03             	sar    $0x3,%eax
f0102e1b:	c1 e0 0c             	shl    $0xc,%eax
f0102e1e:	39 c2                	cmp    %eax,%edx
f0102e20:	0f 85 f5 01 00 00    	jne    f010301b <mem_init+0x1d7e>
	kern_pgdir[0] = 0;
f0102e26:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102e2c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e31:	0f 85 06 02 00 00    	jne    f010303d <mem_init+0x1da0>
	pp0->pp_ref = 0;
f0102e37:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102e3d:	83 ec 0c             	sub    $0xc,%esp
f0102e40:	56                   	push   %esi
f0102e41:	e8 79 e1 ff ff       	call   f0100fbf <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e46:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e49:	8d 83 e0 70 f8 ff    	lea    -0x78f20(%ebx),%eax
f0102e4f:	89 04 24             	mov    %eax,(%esp)
f0102e52:	e8 a5 0a 00 00       	call   f01038fc <cprintf>
}
f0102e57:	83 c4 10             	add    $0x10,%esp
f0102e5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e5d:	5b                   	pop    %ebx
f0102e5e:	5e                   	pop    %esi
f0102e5f:	5f                   	pop    %edi
f0102e60:	5d                   	pop    %ebp
f0102e61:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e62:	50                   	push   %eax
f0102e63:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e66:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f0102e6c:	50                   	push   %eax
f0102e6d:	68 e8 00 00 00       	push   $0xe8
f0102e72:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102e78:	50                   	push   %eax
f0102e79:	e8 33 d2 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102e7e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e81:	8d 83 da 71 f8 ff    	lea    -0x78e26(%ebx),%eax
f0102e87:	50                   	push   %eax
f0102e88:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102e8e:	50                   	push   %eax
f0102e8f:	68 f5 03 00 00       	push   $0x3f5
f0102e94:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102e9a:	50                   	push   %eax
f0102e9b:	e8 11 d2 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102ea0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ea3:	8d 83 f0 71 f8 ff    	lea    -0x78e10(%ebx),%eax
f0102ea9:	50                   	push   %eax
f0102eaa:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102eb0:	50                   	push   %eax
f0102eb1:	68 f6 03 00 00       	push   $0x3f6
f0102eb6:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102ebc:	50                   	push   %eax
f0102ebd:	e8 ef d1 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ec2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ec5:	8d 83 06 72 f8 ff    	lea    -0x78dfa(%ebx),%eax
f0102ecb:	50                   	push   %eax
f0102ecc:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102ed2:	50                   	push   %eax
f0102ed3:	68 f7 03 00 00       	push   $0x3f7
f0102ed8:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102ede:	50                   	push   %eax
f0102edf:	e8 cd d1 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ee4:	52                   	push   %edx
f0102ee5:	89 cb                	mov    %ecx,%ebx
f0102ee7:	8d 81 3c 69 f8 ff    	lea    -0x796c4(%ecx),%eax
f0102eed:	50                   	push   %eax
f0102eee:	6a 56                	push   $0x56
f0102ef0:	8d 81 15 71 f8 ff    	lea    -0x78eeb(%ecx),%eax
f0102ef6:	50                   	push   %eax
f0102ef7:	e8 b5 d1 ff ff       	call   f01000b1 <_panic>
f0102efc:	52                   	push   %edx
f0102efd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f00:	8d 83 3c 69 f8 ff    	lea    -0x796c4(%ebx),%eax
f0102f06:	50                   	push   %eax
f0102f07:	6a 56                	push   $0x56
f0102f09:	8d 83 15 71 f8 ff    	lea    -0x78eeb(%ebx),%eax
f0102f0f:	50                   	push   %eax
f0102f10:	e8 9c d1 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102f15:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f18:	8d 83 d7 72 f8 ff    	lea    -0x78d29(%ebx),%eax
f0102f1e:	50                   	push   %eax
f0102f1f:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102f25:	50                   	push   %eax
f0102f26:	68 fc 03 00 00       	push   $0x3fc
f0102f2b:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102f31:	50                   	push   %eax
f0102f32:	e8 7a d1 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f37:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f3a:	8d 83 6c 70 f8 ff    	lea    -0x78f94(%ebx),%eax
f0102f40:	50                   	push   %eax
f0102f41:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102f47:	50                   	push   %eax
f0102f48:	68 fd 03 00 00       	push   $0x3fd
f0102f4d:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102f53:	50                   	push   %eax
f0102f54:	e8 58 d1 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102f59:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f5c:	8d 83 90 70 f8 ff    	lea    -0x78f70(%ebx),%eax
f0102f62:	50                   	push   %eax
f0102f63:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102f69:	50                   	push   %eax
f0102f6a:	68 ff 03 00 00       	push   $0x3ff
f0102f6f:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102f75:	50                   	push   %eax
f0102f76:	e8 36 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102f7b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f7e:	8d 83 f9 72 f8 ff    	lea    -0x78d07(%ebx),%eax
f0102f84:	50                   	push   %eax
f0102f85:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102f8b:	50                   	push   %eax
f0102f8c:	68 00 04 00 00       	push   $0x400
f0102f91:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102f97:	50                   	push   %eax
f0102f98:	e8 14 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102f9d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fa0:	8d 83 63 73 f8 ff    	lea    -0x78c9d(%ebx),%eax
f0102fa6:	50                   	push   %eax
f0102fa7:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102fad:	50                   	push   %eax
f0102fae:	68 01 04 00 00       	push   $0x401
f0102fb3:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102fb9:	50                   	push   %eax
f0102fba:	e8 f2 d0 ff ff       	call   f01000b1 <_panic>
f0102fbf:	52                   	push   %edx
f0102fc0:	89 cb                	mov    %ecx,%ebx
f0102fc2:	8d 81 3c 69 f8 ff    	lea    -0x796c4(%ecx),%eax
f0102fc8:	50                   	push   %eax
f0102fc9:	6a 56                	push   $0x56
f0102fcb:	8d 81 15 71 f8 ff    	lea    -0x78eeb(%ecx),%eax
f0102fd1:	50                   	push   %eax
f0102fd2:	e8 da d0 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102fd7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fda:	8d 83 b4 70 f8 ff    	lea    -0x78f4c(%ebx),%eax
f0102fe0:	50                   	push   %eax
f0102fe1:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0102fe7:	50                   	push   %eax
f0102fe8:	68 03 04 00 00       	push   $0x403
f0102fed:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0102ff3:	50                   	push   %eax
f0102ff4:	e8 b8 d0 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102ff9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ffc:	8d 83 31 73 f8 ff    	lea    -0x78ccf(%ebx),%eax
f0103002:	50                   	push   %eax
f0103003:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0103009:	50                   	push   %eax
f010300a:	68 05 04 00 00       	push   $0x405
f010300f:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0103015:	50                   	push   %eax
f0103016:	e8 96 d0 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010301b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010301e:	8d 83 c4 6b f8 ff    	lea    -0x7943c(%ebx),%eax
f0103024:	50                   	push   %eax
f0103025:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010302b:	50                   	push   %eax
f010302c:	68 08 04 00 00       	push   $0x408
f0103031:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0103037:	50                   	push   %eax
f0103038:	e8 74 d0 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f010303d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103040:	8d 83 e8 72 f8 ff    	lea    -0x78d18(%ebx),%eax
f0103046:	50                   	push   %eax
f0103047:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f010304d:	50                   	push   %eax
f010304e:	68 0a 04 00 00       	push   $0x40a
f0103053:	8d 83 09 71 f8 ff    	lea    -0x78ef7(%ebx),%eax
f0103059:	50                   	push   %eax
f010305a:	e8 52 d0 ff ff       	call   f01000b1 <_panic>

f010305f <tlb_invalidate>:
{
f010305f:	55                   	push   %ebp
f0103060:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0103062:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103065:	0f 01 38             	invlpg (%eax)
}
f0103068:	5d                   	pop    %ebp
f0103069:	c3                   	ret    

f010306a <user_mem_check>:
}
f010306a:	b8 00 00 00 00       	mov    $0x0,%eax
f010306f:	c3                   	ret    

f0103070 <user_mem_assert>:
}
f0103070:	c3                   	ret    

f0103071 <__x86.get_pc_thunk.dx>:
f0103071:	8b 14 24             	mov    (%esp),%edx
f0103074:	c3                   	ret    

f0103075 <__x86.get_pc_thunk.cx>:
f0103075:	8b 0c 24             	mov    (%esp),%ecx
f0103078:	c3                   	ret    

f0103079 <__x86.get_pc_thunk.di>:
f0103079:	8b 3c 24             	mov    (%esp),%edi
f010307c:	c3                   	ret    

f010307d <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010307d:	55                   	push   %ebp
f010307e:	89 e5                	mov    %esp,%ebp
f0103080:	57                   	push   %edi
f0103081:	56                   	push   %esi
f0103082:	53                   	push   %ebx
f0103083:	83 ec 20             	sub    $0x20,%esp
f0103086:	e8 dc d0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010308b:	81 c3 dd b7 07 00    	add    $0x7b7dd,%ebx
f0103091:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103094:	89 cf                	mov    %ecx,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	size_t pgnum = ROUNDUP(len, PGSIZE) / PGSIZE;
	uintptr_t va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
f0103096:	89 d6                	mov    %edx,%esi
f0103098:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	struct PageInfo *pginfo = NULL;
	cprintf("Allocate size: %d, Start from: %08x\n", len, va);
f010309e:	52                   	push   %edx
f010309f:	51                   	push   %ecx
f01030a0:	8d 83 ec 73 f8 ff    	lea    -0x78c14(%ebx),%eax
f01030a6:	50                   	push   %eax
f01030a7:	e8 50 08 00 00       	call   f01038fc <cprintf>
	size_t pgnum = ROUNDUP(len, PGSIZE) / PGSIZE;
f01030ac:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f01030b2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01030b8:	8d 04 37             	lea    (%edi,%esi,1),%eax
f01030bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (size_t i=0; i<pgnum; i++) {
f01030be:	83 c4 10             	add    $0x10,%esp
		}
		int r = page_insert(e->env_pgdir, pginfo, (void *)va_start, PTE_W | PTE_U | PTE_P);
		if (r < 0) {
			panic("region_alloc: %e" , r);
		}
		cprintf("Va_start = %08x\n",va_start);
f01030c1:	8d bb 9a 74 f8 ff    	lea    -0x78b66(%ebx),%edi
	for (size_t i=0; i<pgnum; i++) {
f01030c7:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01030ca:	74 6f                	je     f010313b <region_alloc+0xbe>
		pginfo = page_alloc(0);
f01030cc:	83 ec 0c             	sub    $0xc,%esp
f01030cf:	6a 00                	push   $0x0
f01030d1:	e8 64 de ff ff       	call   f0100f3a <page_alloc>
		if (! pginfo) {
f01030d6:	83 c4 10             	add    $0x10,%esp
f01030d9:	85 c0                	test   %eax,%eax
f01030db:	74 2b                	je     f0103108 <region_alloc+0x8b>
		int r = page_insert(e->env_pgdir, pginfo, (void *)va_start, PTE_W | PTE_U | PTE_P);
f01030dd:	6a 07                	push   $0x7
f01030df:	56                   	push   %esi
f01030e0:	50                   	push   %eax
f01030e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01030e4:	ff 70 5c             	push   0x5c(%eax)
f01030e7:	e8 39 e1 ff ff       	call   f0101225 <page_insert>
		if (r < 0) {
f01030ec:	83 c4 10             	add    $0x10,%esp
f01030ef:	85 c0                	test   %eax,%eax
f01030f1:	78 2f                	js     f0103122 <region_alloc+0xa5>
		cprintf("Va_start = %08x\n",va_start);
f01030f3:	83 ec 08             	sub    $0x8,%esp
f01030f6:	56                   	push   %esi
f01030f7:	57                   	push   %edi
f01030f8:	e8 ff 07 00 00       	call   f01038fc <cprintf>
		va_start += PGSIZE;
f01030fd:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103103:	83 c4 10             	add    $0x10,%esp
f0103106:	eb bf                	jmp    f01030c7 <region_alloc+0x4a>
			panic("region_alloc: %e" , r);
f0103108:	6a fc                	push   $0xfffffffc
f010310a:	8d 83 7e 74 f8 ff    	lea    -0x78b82(%ebx),%eax
f0103110:	50                   	push   %eax
f0103111:	68 1f 01 00 00       	push   $0x11f
f0103116:	8d 83 8f 74 f8 ff    	lea    -0x78b71(%ebx),%eax
f010311c:	50                   	push   %eax
f010311d:	e8 8f cf ff ff       	call   f01000b1 <_panic>
			panic("region_alloc: %e" , r);
f0103122:	50                   	push   %eax
f0103123:	8d 83 7e 74 f8 ff    	lea    -0x78b82(%ebx),%eax
f0103129:	50                   	push   %eax
f010312a:	68 23 01 00 00       	push   $0x123
f010312f:	8d 83 8f 74 f8 ff    	lea    -0x78b71(%ebx),%eax
f0103135:	50                   	push   %eax
f0103136:	e8 76 cf ff ff       	call   f01000b1 <_panic>
	}
	
}
f010313b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010313e:	5b                   	pop    %ebx
f010313f:	5e                   	pop    %esi
f0103140:	5f                   	pop    %edi
f0103141:	5d                   	pop    %ebp
f0103142:	c3                   	ret    

f0103143 <envid2env>:
{
f0103143:	55                   	push   %ebp
f0103144:	89 e5                	mov    %esp,%ebp
f0103146:	53                   	push   %ebx
f0103147:	e8 29 ff ff ff       	call   f0103075 <__x86.get_pc_thunk.cx>
f010314c:	81 c1 1c b7 07 00    	add    $0x7b71c,%ecx
f0103152:	8b 45 08             	mov    0x8(%ebp),%eax
f0103155:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (envid == 0) {
f0103158:	85 c0                	test   %eax,%eax
f010315a:	74 4c                	je     f01031a8 <envid2env+0x65>
	e = &envs[ENVX(envid)];
f010315c:	89 c2                	mov    %eax,%edx
f010315e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103164:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103167:	c1 e2 05             	shl    $0x5,%edx
f010316a:	03 91 ec 1a 00 00    	add    0x1aec(%ecx),%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103170:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0103174:	74 42                	je     f01031b8 <envid2env+0x75>
f0103176:	39 42 48             	cmp    %eax,0x48(%edx)
f0103179:	75 49                	jne    f01031c4 <envid2env+0x81>
	return 0;
f010317b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103180:	84 db                	test   %bl,%bl
f0103182:	74 2a                	je     f01031ae <envid2env+0x6b>
f0103184:	8b 89 e8 1a 00 00    	mov    0x1ae8(%ecx),%ecx
f010318a:	39 d1                	cmp    %edx,%ecx
f010318c:	74 20                	je     f01031ae <envid2env+0x6b>
f010318e:	8b 42 4c             	mov    0x4c(%edx),%eax
f0103191:	3b 41 48             	cmp    0x48(%ecx),%eax
f0103194:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103199:	0f 45 d3             	cmovne %ebx,%edx
f010319c:	0f 94 c0             	sete   %al
f010319f:	0f b6 c0             	movzbl %al,%eax
f01031a2:	8d 44 00 fe          	lea    -0x2(%eax,%eax,1),%eax
f01031a6:	eb 06                	jmp    f01031ae <envid2env+0x6b>
		*env_store = curenv;
f01031a8:	8b 91 e8 1a 00 00    	mov    0x1ae8(%ecx),%edx
f01031ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01031b1:	89 11                	mov    %edx,(%ecx)
}
f01031b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01031b6:	c9                   	leave  
f01031b7:	c3                   	ret    
f01031b8:	ba 00 00 00 00       	mov    $0x0,%edx
		return -E_BAD_ENV;
f01031bd:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031c2:	eb ea                	jmp    f01031ae <envid2env+0x6b>
f01031c4:	ba 00 00 00 00       	mov    $0x0,%edx
f01031c9:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031ce:	eb de                	jmp    f01031ae <envid2env+0x6b>

f01031d0 <env_init_percpu>:
{
f01031d0:	e8 24 d5 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f01031d5:	05 93 b6 07 00       	add    $0x7b693,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f01031da:	8d 80 98 17 00 00    	lea    0x1798(%eax),%eax
f01031e0:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01031e3:	b8 23 00 00 00       	mov    $0x23,%eax
f01031e8:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01031ea:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01031ec:	b8 10 00 00 00       	mov    $0x10,%eax
f01031f1:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01031f3:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01031f5:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01031f7:	ea fe 31 10 f0 08 00 	ljmp   $0x8,$0xf01031fe
	asm volatile("lldt %0" : : "r" (sel));
f01031fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0103203:	0f 00 d0             	lldt   %ax
}
f0103206:	c3                   	ret    

f0103207 <env_init>:
{
f0103207:	55                   	push   %ebp
f0103208:	89 e5                	mov    %esp,%ebp
f010320a:	56                   	push   %esi
f010320b:	53                   	push   %ebx
f010320c:	e8 56 cf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103211:	81 c3 57 b6 07 00    	add    $0x7b657,%ebx
		else envs[i].env_link = &envs[i+1];
f0103217:	8b 8b ec 1a 00 00    	mov    0x1aec(%ebx),%ecx
	for(i = 0; i < NENV; i++) {
f010321d:	b8 00 00 00 00       	mov    $0x0,%eax
		else envs[i].env_link = &envs[i+1];
f0103222:	8d 54 40 03          	lea    0x3(%eax,%eax,2),%edx
f0103226:	c1 e2 05             	shl    $0x5,%edx
f0103229:	8d 34 11             	lea    (%ecx,%edx,1),%esi
f010322c:	89 74 11 e4          	mov    %esi,-0x1c(%ecx,%edx,1)
f0103230:	8d 54 11 e8          	lea    -0x18(%ecx,%edx,1),%edx
		envs[i].env_id = 0;
f0103234:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	for(i = 0; i < NENV; i++) {
f010323a:	83 c0 01             	add    $0x1,%eax
f010323d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0103242:	7f 16                	jg     f010325a <env_init+0x53>
		if(i == NENV-1) envs[i].env_link = NULL;
f0103244:	83 c2 60             	add    $0x60,%edx
f0103247:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010324c:	75 d4                	jne    f0103222 <env_init+0x1b>
f010324e:	c7 81 e4 7f 01 00 00 	movl   $0x0,0x17fe4(%ecx)
f0103255:	00 00 00 
f0103258:	eb da                	jmp    f0103234 <env_init+0x2d>
	env_free_list = envs;
f010325a:	8b 83 ec 1a 00 00    	mov    0x1aec(%ebx),%eax
f0103260:	89 83 f0 1a 00 00    	mov    %eax,0x1af0(%ebx)
	env_init_percpu();
f0103266:	e8 65 ff ff ff       	call   f01031d0 <env_init_percpu>
}
f010326b:	5b                   	pop    %ebx
f010326c:	5e                   	pop    %esi
f010326d:	5d                   	pop    %ebp
f010326e:	c3                   	ret    

f010326f <env_alloc>:
{
f010326f:	55                   	push   %ebp
f0103270:	89 e5                	mov    %esp,%ebp
f0103272:	57                   	push   %edi
f0103273:	56                   	push   %esi
f0103274:	53                   	push   %ebx
f0103275:	83 ec 0c             	sub    $0xc,%esp
f0103278:	e8 ea ce ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010327d:	81 c3 eb b5 07 00    	add    $0x7b5eb,%ebx
	if (!(e = env_free_list))
f0103283:	8b b3 f0 1a 00 00    	mov    0x1af0(%ebx),%esi
f0103289:	85 f6                	test   %esi,%esi
f010328b:	0f 84 6a 01 00 00    	je     f01033fb <env_alloc+0x18c>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103291:	83 ec 0c             	sub    $0xc,%esp
f0103294:	6a 01                	push   $0x1
f0103296:	e8 9f dc ff ff       	call   f0100f3a <page_alloc>
f010329b:	89 c7                	mov    %eax,%edi
f010329d:	83 c4 10             	add    $0x10,%esp
f01032a0:	85 c0                	test   %eax,%eax
f01032a2:	0f 84 5a 01 00 00    	je     f0103402 <env_alloc+0x193>
	return (pp - pages) << PGSHIFT;
f01032a8:	c7 c0 38 03 18 f0    	mov    $0xf0180338,%eax
f01032ae:	89 f9                	mov    %edi,%ecx
f01032b0:	2b 08                	sub    (%eax),%ecx
f01032b2:	89 c8                	mov    %ecx,%eax
f01032b4:	c1 f8 03             	sar    $0x3,%eax
f01032b7:	89 c2                	mov    %eax,%edx
f01032b9:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01032bc:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01032c1:	c7 c1 40 03 18 f0    	mov    $0xf0180340,%ecx
f01032c7:	3b 01                	cmp    (%ecx),%eax
f01032c9:	0f 83 fd 00 00 00    	jae    f01033cc <env_alloc+0x15d>
	return (void *)(pa + KERNBASE);
f01032cf:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	e->env_pgdir = page2kva(p);
f01032d5:	89 46 5c             	mov    %eax,0x5c(%esi)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE); // use kern_pgdir as template 
f01032d8:	83 ec 04             	sub    $0x4,%esp
f01032db:	68 00 10 00 00       	push   $0x1000
f01032e0:	c7 c2 3c 03 18 f0    	mov    $0xf018033c,%edx
f01032e6:	ff 32                	push   (%edx)
f01032e8:	50                   	push   %eax
f01032e9:	e8 b3 16 00 00       	call   f01049a1 <memcpy>
	p->pp_ref++;
f01032ee:	66 83 47 04 01       	addw   $0x1,0x4(%edi)
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01032f3:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f01032f6:	83 c4 10             	add    $0x10,%esp
f01032f9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032fe:	0f 86 de 00 00 00    	jbe    f01033e2 <env_alloc+0x173>
	return (physaddr_t)kva - KERNBASE;
f0103304:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010330a:	83 ca 05             	or     $0x5,%edx
f010330d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103313:	8b 46 48             	mov    0x48(%esi),%eax
f0103316:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f010331b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103320:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103325:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103328:	89 f2                	mov    %esi,%edx
f010332a:	2b 93 ec 1a 00 00    	sub    0x1aec(%ebx),%edx
f0103330:	c1 fa 05             	sar    $0x5,%edx
f0103333:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103339:	09 d0                	or     %edx,%eax
f010333b:	89 46 48             	mov    %eax,0x48(%esi)
	e->env_parent_id = parent_id;
f010333e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103341:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f0103344:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f010334b:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0103352:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103359:	83 ec 04             	sub    $0x4,%esp
f010335c:	6a 44                	push   $0x44
f010335e:	6a 00                	push   $0x0
f0103360:	56                   	push   %esi
f0103361:	e8 93 15 00 00       	call   f01048f9 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103366:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f010336c:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f0103372:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0103378:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f010337f:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	env_free_list = e->env_link;
f0103385:	8b 46 44             	mov    0x44(%esi),%eax
f0103388:	89 83 f0 1a 00 00    	mov    %eax,0x1af0(%ebx)
	*newenv_store = e;
f010338e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103391:	89 30                	mov    %esi,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103393:	8b 4e 48             	mov    0x48(%esi),%ecx
f0103396:	8b 83 e8 1a 00 00    	mov    0x1ae8(%ebx),%eax
f010339c:	83 c4 10             	add    $0x10,%esp
f010339f:	ba 00 00 00 00       	mov    $0x0,%edx
f01033a4:	85 c0                	test   %eax,%eax
f01033a6:	74 03                	je     f01033ab <env_alloc+0x13c>
f01033a8:	8b 50 48             	mov    0x48(%eax),%edx
f01033ab:	83 ec 04             	sub    $0x4,%esp
f01033ae:	51                   	push   %ecx
f01033af:	52                   	push   %edx
f01033b0:	8d 83 ab 74 f8 ff    	lea    -0x78b55(%ebx),%eax
f01033b6:	50                   	push   %eax
f01033b7:	e8 40 05 00 00       	call   f01038fc <cprintf>
	return 0;
f01033bc:	83 c4 10             	add    $0x10,%esp
f01033bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033c7:	5b                   	pop    %ebx
f01033c8:	5e                   	pop    %esi
f01033c9:	5f                   	pop    %edi
f01033ca:	5d                   	pop    %ebp
f01033cb:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033cc:	52                   	push   %edx
f01033cd:	8d 83 3c 69 f8 ff    	lea    -0x796c4(%ebx),%eax
f01033d3:	50                   	push   %eax
f01033d4:	6a 56                	push   $0x56
f01033d6:	8d 83 15 71 f8 ff    	lea    -0x78eeb(%ebx),%eax
f01033dc:	50                   	push   %eax
f01033dd:	e8 cf cc ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033e2:	50                   	push   %eax
f01033e3:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f01033e9:	50                   	push   %eax
f01033ea:	68 c2 00 00 00       	push   $0xc2
f01033ef:	8d 83 8f 74 f8 ff    	lea    -0x78b71(%ebx),%eax
f01033f5:	50                   	push   %eax
f01033f6:	e8 b6 cc ff ff       	call   f01000b1 <_panic>
		return -E_NO_FREE_ENV;
f01033fb:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103400:	eb c2                	jmp    f01033c4 <env_alloc+0x155>
		return -E_NO_MEM;
f0103402:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103407:	eb bb                	jmp    f01033c4 <env_alloc+0x155>

f0103409 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103409:	55                   	push   %ebp
f010340a:	89 e5                	mov    %esp,%ebp
f010340c:	57                   	push   %edi
f010340d:	56                   	push   %esi
f010340e:	53                   	push   %ebx
f010340f:	83 ec 34             	sub    $0x34,%esp
f0103412:	e8 50 cd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103417:	81 c3 51 b4 07 00    	add    $0x7b451,%ebx
	// LAB 3: Your code here.
	struct Env *e;
	int r = env_alloc(&e, 0);
f010341d:	6a 00                	push   $0x0
f010341f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103422:	50                   	push   %eax
f0103423:	e8 47 fe ff ff       	call   f010326f <env_alloc>
	if (r<0) {
f0103428:	83 c4 10             	add    $0x10,%esp
f010342b:	85 c0                	test   %eax,%eax
f010342d:	78 44                	js     f0103473 <env_create+0x6a>
		panic("env_create: %e",r);
	}
	e->env_type = type;
f010342f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103432:	89 c1                	mov    %eax,%ecx
f0103434:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103437:	8b 45 0c             	mov    0xc(%ebp),%eax
f010343a:	89 41 50             	mov    %eax,0x50(%ecx)
	if (elf->e_magic != ELF_MAGIC) {
f010343d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103440:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103446:	75 44                	jne    f010348c <env_create+0x83>
	ph = (struct Proghdr *)(binary + elf->e_phoff);
f0103448:	8b 45 08             	mov    0x8(%ebp),%eax
f010344b:	89 c6                	mov    %eax,%esi
f010344d:	03 70 1c             	add    0x1c(%eax),%esi
	eph = ph + elf->e_phnum;
f0103450:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f0103454:	c1 e7 05             	shl    $0x5,%edi
f0103457:	01 f7                	add    %esi,%edi
	lcr3(PADDR(e->env_pgdir));
f0103459:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010345c:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010345f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103464:	76 41                	jbe    f01034a7 <env_create+0x9e>
	return (physaddr_t)kva - KERNBASE;
f0103466:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010346b:	0f 22 d8             	mov    %eax,%cr3
}
f010346e:	e9 8a 00 00 00       	jmp    f01034fd <env_create+0xf4>
		panic("env_create: %e",r);
f0103473:	50                   	push   %eax
f0103474:	8d 83 c0 74 f8 ff    	lea    -0x78b40(%ebx),%eax
f010347a:	50                   	push   %eax
f010347b:	68 8b 01 00 00       	push   $0x18b
f0103480:	8d 83 8f 74 f8 ff    	lea    -0x78b71(%ebx),%eax
f0103486:	50                   	push   %eax
f0103487:	e8 25 cc ff ff       	call   f01000b1 <_panic>
		panic("load_icode: not an ELF file");
f010348c:	83 ec 04             	sub    $0x4,%esp
f010348f:	8d 83 cf 74 f8 ff    	lea    -0x78b31(%ebx),%eax
f0103495:	50                   	push   %eax
f0103496:	68 64 01 00 00       	push   $0x164
f010349b:	8d 83 8f 74 f8 ff    	lea    -0x78b71(%ebx),%eax
f01034a1:	50                   	push   %eax
f01034a2:	e8 0a cc ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034a7:	50                   	push   %eax
f01034a8:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f01034ae:	50                   	push   %eax
f01034af:	68 69 01 00 00       	push   $0x169
f01034b4:	8d 83 8f 74 f8 ff    	lea    -0x78b71(%ebx),%eax
f01034ba:	50                   	push   %eax
f01034bb:	e8 f1 cb ff ff       	call   f01000b1 <_panic>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01034c0:	8b 56 08             	mov    0x8(%esi),%edx
f01034c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01034c6:	e8 b2 fb ff ff       	call   f010307d <region_alloc>
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01034cb:	83 ec 04             	sub    $0x4,%esp
f01034ce:	ff 76 10             	push   0x10(%esi)
f01034d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01034d4:	03 46 04             	add    0x4(%esi),%eax
f01034d7:	50                   	push   %eax
f01034d8:	ff 76 08             	push   0x8(%esi)
f01034db:	e8 c1 14 00 00       	call   f01049a1 <memcpy>
			memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f01034e0:	8b 46 10             	mov    0x10(%esi),%eax
f01034e3:	83 c4 0c             	add    $0xc,%esp
f01034e6:	8b 56 14             	mov    0x14(%esi),%edx
f01034e9:	29 c2                	sub    %eax,%edx
f01034eb:	52                   	push   %edx
f01034ec:	6a 00                	push   $0x0
f01034ee:	03 46 08             	add    0x8(%esi),%eax
f01034f1:	50                   	push   %eax
f01034f2:	e8 02 14 00 00       	call   f01048f9 <memset>
f01034f7:	83 c4 10             	add    $0x10,%esp
	for (; ph<eph; ph++) {
f01034fa:	83 c6 20             	add    $0x20,%esi
f01034fd:	39 f7                	cmp    %esi,%edi
f01034ff:	76 28                	jbe    f0103529 <env_create+0x120>
		if (ph->p_type == ELF_PROG_LOAD) {
f0103501:	83 3e 01             	cmpl   $0x1,(%esi)
f0103504:	75 f4                	jne    f01034fa <env_create+0xf1>
			if (ph->p_filesz > ph->p_memsz) {
f0103506:	8b 4e 14             	mov    0x14(%esi),%ecx
f0103509:	39 4e 10             	cmp    %ecx,0x10(%esi)
f010350c:	76 b2                	jbe    f01034c0 <env_create+0xb7>
				panic("load_icode: file size is greater than memory size");
f010350e:	83 ec 04             	sub    $0x4,%esp
f0103511:	8d 83 14 74 f8 ff    	lea    -0x78bec(%ebx),%eax
f0103517:	50                   	push   %eax
f0103518:	68 6d 01 00 00       	push   $0x16d
f010351d:	8d 83 8f 74 f8 ff    	lea    -0x78b71(%ebx),%eax
f0103523:	50                   	push   %eax
f0103524:	e8 88 cb ff ff       	call   f01000b1 <_panic>
	e->env_tf.tf_eip = elf->e_entry;
f0103529:	8b 45 08             	mov    0x8(%ebp),%eax
f010352c:	8b 40 18             	mov    0x18(%eax),%eax
f010352f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103532:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f0103535:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010353a:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010353f:	89 f8                	mov    %edi,%eax
f0103541:	e8 37 fb ff ff       	call   f010307d <region_alloc>
	lcr3(PADDR(kern_pgdir));
f0103546:	c7 c0 3c 03 18 f0    	mov    $0xf018033c,%eax
f010354c:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010354e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103553:	76 10                	jbe    f0103565 <env_create+0x15c>
	return (physaddr_t)kva - KERNBASE;
f0103555:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010355a:	0f 22 d8             	mov    %eax,%cr3
	load_icode(e, binary);
}
f010355d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103560:	5b                   	pop    %ebx
f0103561:	5e                   	pop    %esi
f0103562:	5f                   	pop    %edi
f0103563:	5d                   	pop    %ebp
f0103564:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103565:	50                   	push   %eax
f0103566:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f010356c:	50                   	push   %eax
f010356d:	68 7a 01 00 00       	push   $0x17a
f0103572:	8d 83 8f 74 f8 ff    	lea    -0x78b71(%ebx),%eax
f0103578:	50                   	push   %eax
f0103579:	e8 33 cb ff ff       	call   f01000b1 <_panic>

f010357e <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010357e:	55                   	push   %ebp
f010357f:	89 e5                	mov    %esp,%ebp
f0103581:	57                   	push   %edi
f0103582:	56                   	push   %esi
f0103583:	53                   	push   %ebx
f0103584:	83 ec 2c             	sub    $0x2c,%esp
f0103587:	e8 db cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010358c:	81 c3 dc b2 07 00    	add    $0x7b2dc,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103592:	8b 93 e8 1a 00 00    	mov    0x1ae8(%ebx),%edx
f0103598:	3b 55 08             	cmp    0x8(%ebp),%edx
f010359b:	74 47                	je     f01035e4 <env_free+0x66>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010359d:	8b 45 08             	mov    0x8(%ebp),%eax
f01035a0:	8b 48 48             	mov    0x48(%eax),%ecx
f01035a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01035a8:	85 d2                	test   %edx,%edx
f01035aa:	74 03                	je     f01035af <env_free+0x31>
f01035ac:	8b 42 48             	mov    0x48(%edx),%eax
f01035af:	83 ec 04             	sub    $0x4,%esp
f01035b2:	51                   	push   %ecx
f01035b3:	50                   	push   %eax
f01035b4:	8d 83 eb 74 f8 ff    	lea    -0x78b15(%ebx),%eax
f01035ba:	50                   	push   %eax
f01035bb:	e8 3c 03 00 00       	call   f01038fc <cprintf>
f01035c0:	83 c4 10             	add    $0x10,%esp
f01035c3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	if (PGNUM(pa) >= npages)
f01035ca:	c7 c0 40 03 18 f0    	mov    $0xf0180340,%eax
f01035d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if (PGNUM(pa) >= npages)
f01035d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return &pages[PGNUM(pa)];
f01035d6:	c7 c0 38 03 18 f0    	mov    $0xf0180338,%eax
f01035dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01035df:	e9 bf 00 00 00       	jmp    f01036a3 <env_free+0x125>
		lcr3(PADDR(kern_pgdir));
f01035e4:	c7 c0 3c 03 18 f0    	mov    $0xf018033c,%eax
f01035ea:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01035ec:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035f1:	76 10                	jbe    f0103603 <env_free+0x85>
	return (physaddr_t)kva - KERNBASE;
f01035f3:	05 00 00 00 10       	add    $0x10000000,%eax
f01035f8:	0f 22 d8             	mov    %eax,%cr3
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01035fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01035fe:	8b 48 48             	mov    0x48(%eax),%ecx
f0103601:	eb a9                	jmp    f01035ac <env_free+0x2e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103603:	50                   	push   %eax
f0103604:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f010360a:	50                   	push   %eax
f010360b:	68 9f 01 00 00       	push   $0x19f
f0103610:	8d 83 8f 74 f8 ff    	lea    -0x78b71(%ebx),%eax
f0103616:	50                   	push   %eax
f0103617:	e8 95 ca ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010361c:	57                   	push   %edi
f010361d:	8d 83 3c 69 f8 ff    	lea    -0x796c4(%ebx),%eax
f0103623:	50                   	push   %eax
f0103624:	68 ae 01 00 00       	push   $0x1ae
f0103629:	8d 83 8f 74 f8 ff    	lea    -0x78b71(%ebx),%eax
f010362f:	50                   	push   %eax
f0103630:	e8 7c ca ff ff       	call   f01000b1 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103635:	83 c7 04             	add    $0x4,%edi
f0103638:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010363e:	81 fe 00 00 40 00    	cmp    $0x400000,%esi
f0103644:	74 1e                	je     f0103664 <env_free+0xe6>
			if (pt[pteno] & PTE_P)
f0103646:	f6 07 01             	testb  $0x1,(%edi)
f0103649:	74 ea                	je     f0103635 <env_free+0xb7>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010364b:	83 ec 08             	sub    $0x8,%esp
f010364e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103651:	09 f0                	or     %esi,%eax
f0103653:	50                   	push   %eax
f0103654:	8b 45 08             	mov    0x8(%ebp),%eax
f0103657:	ff 70 5c             	push   0x5c(%eax)
f010365a:	e8 8b db ff ff       	call   f01011ea <page_remove>
f010365f:	83 c4 10             	add    $0x10,%esp
f0103662:	eb d1                	jmp    f0103635 <env_free+0xb7>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103664:	8b 45 08             	mov    0x8(%ebp),%eax
f0103667:	8b 40 5c             	mov    0x5c(%eax),%eax
f010366a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010366d:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103674:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103677:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010367a:	3b 10                	cmp    (%eax),%edx
f010367c:	73 67                	jae    f01036e5 <env_free+0x167>
		page_decref(pa2page(pa));
f010367e:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103681:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103684:	8b 00                	mov    (%eax),%eax
f0103686:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103689:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010368c:	50                   	push   %eax
f010368d:	e8 7c d9 ff ff       	call   f010100e <page_decref>
f0103692:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103695:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0103699:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010369c:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01036a1:	74 5a                	je     f01036fd <env_free+0x17f>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01036a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01036a6:	8b 40 5c             	mov    0x5c(%eax),%eax
f01036a9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01036ac:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f01036af:	a8 01                	test   $0x1,%al
f01036b1:	74 e2                	je     f0103695 <env_free+0x117>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01036b3:	89 c7                	mov    %eax,%edi
f01036b5:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f01036bb:	c1 e8 0c             	shr    $0xc,%eax
f01036be:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01036c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01036c4:	3b 02                	cmp    (%edx),%eax
f01036c6:	0f 83 50 ff ff ff    	jae    f010361c <env_free+0x9e>
	return (void *)(pa + KERNBASE);
f01036cc:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f01036d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036d5:	c1 e0 14             	shl    $0x14,%eax
f01036d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01036db:	be 00 00 00 00       	mov    $0x0,%esi
f01036e0:	e9 61 ff ff ff       	jmp    f0103646 <env_free+0xc8>
		panic("pa2page called with invalid pa");
f01036e5:	83 ec 04             	sub    $0x4,%esp
f01036e8:	8d 83 90 6a f8 ff    	lea    -0x79570(%ebx),%eax
f01036ee:	50                   	push   %eax
f01036ef:	6a 4f                	push   $0x4f
f01036f1:	8d 83 15 71 f8 ff    	lea    -0x78eeb(%ebx),%eax
f01036f7:	50                   	push   %eax
f01036f8:	e8 b4 c9 ff ff       	call   f01000b1 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01036fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0103700:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103703:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103708:	76 57                	jbe    f0103761 <env_free+0x1e3>
	e->env_pgdir = 0;
f010370a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010370d:	c7 41 5c 00 00 00 00 	movl   $0x0,0x5c(%ecx)
	return (physaddr_t)kva - KERNBASE;
f0103714:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103719:	c1 e8 0c             	shr    $0xc,%eax
f010371c:	c7 c2 40 03 18 f0    	mov    $0xf0180340,%edx
f0103722:	3b 02                	cmp    (%edx),%eax
f0103724:	73 54                	jae    f010377a <env_free+0x1fc>
	page_decref(pa2page(pa));
f0103726:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103729:	c7 c2 38 03 18 f0    	mov    $0xf0180338,%edx
f010372f:	8b 12                	mov    (%edx),%edx
f0103731:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103734:	50                   	push   %eax
f0103735:	e8 d4 d8 ff ff       	call   f010100e <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010373a:	8b 45 08             	mov    0x8(%ebp),%eax
f010373d:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103744:	8b 83 f0 1a 00 00    	mov    0x1af0(%ebx),%eax
f010374a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010374d:	89 41 44             	mov    %eax,0x44(%ecx)
	env_free_list = e;
f0103750:	89 8b f0 1a 00 00    	mov    %ecx,0x1af0(%ebx)
}
f0103756:	83 c4 10             	add    $0x10,%esp
f0103759:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010375c:	5b                   	pop    %ebx
f010375d:	5e                   	pop    %esi
f010375e:	5f                   	pop    %edi
f010375f:	5d                   	pop    %ebp
f0103760:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103761:	50                   	push   %eax
f0103762:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f0103768:	50                   	push   %eax
f0103769:	68 bc 01 00 00       	push   $0x1bc
f010376e:	8d 83 8f 74 f8 ff    	lea    -0x78b71(%ebx),%eax
f0103774:	50                   	push   %eax
f0103775:	e8 37 c9 ff ff       	call   f01000b1 <_panic>
		panic("pa2page called with invalid pa");
f010377a:	83 ec 04             	sub    $0x4,%esp
f010377d:	8d 83 90 6a f8 ff    	lea    -0x79570(%ebx),%eax
f0103783:	50                   	push   %eax
f0103784:	6a 4f                	push   $0x4f
f0103786:	8d 83 15 71 f8 ff    	lea    -0x78eeb(%ebx),%eax
f010378c:	50                   	push   %eax
f010378d:	e8 1f c9 ff ff       	call   f01000b1 <_panic>

f0103792 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103792:	55                   	push   %ebp
f0103793:	89 e5                	mov    %esp,%ebp
f0103795:	53                   	push   %ebx
f0103796:	83 ec 10             	sub    $0x10,%esp
f0103799:	e8 c9 c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010379e:	81 c3 ca b0 07 00    	add    $0x7b0ca,%ebx
	env_free(e);
f01037a4:	ff 75 08             	push   0x8(%ebp)
f01037a7:	e8 d2 fd ff ff       	call   f010357e <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01037ac:	8d 83 48 74 f8 ff    	lea    -0x78bb8(%ebx),%eax
f01037b2:	89 04 24             	mov    %eax,(%esp)
f01037b5:	e8 42 01 00 00       	call   f01038fc <cprintf>
f01037ba:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f01037bd:	83 ec 0c             	sub    $0xc,%esp
f01037c0:	6a 00                	push   $0x0
f01037c2:	e8 61 d0 ff ff       	call   f0100828 <monitor>
f01037c7:	83 c4 10             	add    $0x10,%esp
f01037ca:	eb f1                	jmp    f01037bd <env_destroy+0x2b>

f01037cc <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01037cc:	55                   	push   %ebp
f01037cd:	89 e5                	mov    %esp,%ebp
f01037cf:	53                   	push   %ebx
f01037d0:	83 ec 08             	sub    $0x8,%esp
f01037d3:	e8 8f c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01037d8:	81 c3 90 b0 07 00    	add    $0x7b090,%ebx
	asm volatile(
f01037de:	8b 65 08             	mov    0x8(%ebp),%esp
f01037e1:	61                   	popa   
f01037e2:	07                   	pop    %es
f01037e3:	1f                   	pop    %ds
f01037e4:	83 c4 08             	add    $0x8,%esp
f01037e7:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01037e8:	8d 83 01 75 f8 ff    	lea    -0x78aff(%ebx),%eax
f01037ee:	50                   	push   %eax
f01037ef:	68 e5 01 00 00       	push   $0x1e5
f01037f4:	8d 83 8f 74 f8 ff    	lea    -0x78b71(%ebx),%eax
f01037fa:	50                   	push   %eax
f01037fb:	e8 b1 c8 ff ff       	call   f01000b1 <_panic>

f0103800 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103800:	55                   	push   %ebp
f0103801:	89 e5                	mov    %esp,%ebp
f0103803:	53                   	push   %ebx
f0103804:	83 ec 04             	sub    $0x4,%esp
f0103807:	e8 5b c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010380c:	81 c3 5c b0 07 00    	add    $0x7b05c,%ebx
f0103812:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103815:	8b 93 e8 1a 00 00    	mov    0x1ae8(%ebx),%edx
f010381b:	85 d2                	test   %edx,%edx
f010381d:	74 06                	je     f0103825 <env_run+0x25>
f010381f:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103823:	74 2e                	je     f0103853 <env_run+0x53>
		curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
f0103825:	89 83 e8 1a 00 00    	mov    %eax,0x1ae8(%ebx)
	e->env_status = ENV_RUNNING;
f010382b:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	e->env_runs++;
f0103832:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(e->env_pgdir));
f0103836:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f0103839:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010383f:	76 1b                	jbe    f010385c <env_run+0x5c>
	return (physaddr_t)kva - KERNBASE;
f0103841:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103847:	0f 22 da             	mov    %edx,%cr3
	
	env_pop_tf(&e->env_tf);
f010384a:	83 ec 0c             	sub    $0xc,%esp
f010384d:	50                   	push   %eax
f010384e:	e8 79 ff ff ff       	call   f01037cc <env_pop_tf>
		curenv->env_status = ENV_RUNNABLE;
f0103853:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
f010385a:	eb c9                	jmp    f0103825 <env_run+0x25>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010385c:	52                   	push   %edx
f010385d:	8d 83 48 6a f8 ff    	lea    -0x795b8(%ebx),%eax
f0103863:	50                   	push   %eax
f0103864:	68 09 02 00 00       	push   $0x209
f0103869:	8d 83 8f 74 f8 ff    	lea    -0x78b71(%ebx),%eax
f010386f:	50                   	push   %eax
f0103870:	e8 3c c8 ff ff       	call   f01000b1 <_panic>

f0103875 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103875:	55                   	push   %ebp
f0103876:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103878:	8b 45 08             	mov    0x8(%ebp),%eax
f010387b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103880:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103881:	ba 71 00 00 00       	mov    $0x71,%edx
f0103886:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103887:	0f b6 c0             	movzbl %al,%eax
}
f010388a:	5d                   	pop    %ebp
f010388b:	c3                   	ret    

f010388c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010388c:	55                   	push   %ebp
f010388d:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010388f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103892:	ba 70 00 00 00       	mov    $0x70,%edx
f0103897:	ee                   	out    %al,(%dx)
f0103898:	8b 45 0c             	mov    0xc(%ebp),%eax
f010389b:	ba 71 00 00 00       	mov    $0x71,%edx
f01038a0:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01038a1:	5d                   	pop    %ebp
f01038a2:	c3                   	ret    

f01038a3 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01038a3:	55                   	push   %ebp
f01038a4:	89 e5                	mov    %esp,%ebp
f01038a6:	53                   	push   %ebx
f01038a7:	83 ec 10             	sub    $0x10,%esp
f01038aa:	e8 b8 c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01038af:	81 c3 b9 af 07 00    	add    $0x7afb9,%ebx
	cputchar(ch);
f01038b5:	ff 75 08             	push   0x8(%ebp)
f01038b8:	e8 15 ce ff ff       	call   f01006d2 <cputchar>
	*cnt++;
}
f01038bd:	83 c4 10             	add    $0x10,%esp
f01038c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038c3:	c9                   	leave  
f01038c4:	c3                   	ret    

f01038c5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01038c5:	55                   	push   %ebp
f01038c6:	89 e5                	mov    %esp,%ebp
f01038c8:	53                   	push   %ebx
f01038c9:	83 ec 14             	sub    $0x14,%esp
f01038cc:	e8 96 c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01038d1:	81 c3 97 af 07 00    	add    $0x7af97,%ebx
	int cnt = 0;
f01038d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01038de:	ff 75 0c             	push   0xc(%ebp)
f01038e1:	ff 75 08             	push   0x8(%ebp)
f01038e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01038e7:	50                   	push   %eax
f01038e8:	8d 83 3b 50 f8 ff    	lea    -0x7afc5(%ebx),%eax
f01038ee:	50                   	push   %eax
f01038ef:	e8 90 08 00 00       	call   f0104184 <vprintfmt>
	return cnt;
}
f01038f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01038f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038fa:	c9                   	leave  
f01038fb:	c3                   	ret    

f01038fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01038fc:	55                   	push   %ebp
f01038fd:	89 e5                	mov    %esp,%ebp
f01038ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103902:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103905:	50                   	push   %eax
f0103906:	ff 75 08             	push   0x8(%ebp)
f0103909:	e8 b7 ff ff ff       	call   f01038c5 <vcprintf>
	va_end(ap);

	return cnt;
}
f010390e:	c9                   	leave  
f010390f:	c3                   	ret    

f0103910 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103910:	55                   	push   %ebp
f0103911:	89 e5                	mov    %esp,%ebp
f0103913:	57                   	push   %edi
f0103914:	56                   	push   %esi
f0103915:	53                   	push   %ebx
f0103916:	83 ec 04             	sub    $0x4,%esp
f0103919:	e8 49 c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010391e:	81 c3 4a af 07 00    	add    $0x7af4a,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103924:	c7 83 1c 23 00 00 00 	movl   $0xf0000000,0x231c(%ebx)
f010392b:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010392e:	66 c7 83 20 23 00 00 	movw   $0x10,0x2320(%ebx)
f0103935:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103937:	66 c7 83 7e 23 00 00 	movw   $0x68,0x237e(%ebx)
f010393e:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103940:	c7 c0 00 b3 11 f0    	mov    $0xf011b300,%eax
f0103946:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f010394c:	8d b3 18 23 00 00    	lea    0x2318(%ebx),%esi
f0103952:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103956:	89 f2                	mov    %esi,%edx
f0103958:	c1 ea 10             	shr    $0x10,%edx
f010395b:	88 50 2c             	mov    %dl,0x2c(%eax)
f010395e:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f0103962:	83 e2 f0             	and    $0xfffffff0,%edx
f0103965:	83 ca 09             	or     $0x9,%edx
f0103968:	83 e2 9f             	and    $0xffffff9f,%edx
f010396b:	83 ca 80             	or     $0xffffff80,%edx
f010396e:	88 55 f3             	mov    %dl,-0xd(%ebp)
f0103971:	88 50 2d             	mov    %dl,0x2d(%eax)
f0103974:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f0103978:	83 e1 c0             	and    $0xffffffc0,%ecx
f010397b:	83 c9 40             	or     $0x40,%ecx
f010397e:	83 e1 7f             	and    $0x7f,%ecx
f0103981:	88 48 2e             	mov    %cl,0x2e(%eax)
f0103984:	c1 ee 18             	shr    $0x18,%esi
f0103987:	89 f1                	mov    %esi,%ecx
f0103989:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f010398c:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f0103990:	83 e2 ef             	and    $0xffffffef,%edx
f0103993:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f0103996:	b8 28 00 00 00       	mov    $0x28,%eax
f010399b:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f010399e:	8d 83 a0 17 00 00    	lea    0x17a0(%ebx),%eax
f01039a4:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01039a7:	83 c4 04             	add    $0x4,%esp
f01039aa:	5b                   	pop    %ebx
f01039ab:	5e                   	pop    %esi
f01039ac:	5f                   	pop    %edi
f01039ad:	5d                   	pop    %ebp
f01039ae:	c3                   	ret    

f01039af <trap_init>:
{
f01039af:	55                   	push   %ebp
f01039b0:	89 e5                	mov    %esp,%ebp
	trap_init_percpu();
f01039b2:	e8 59 ff ff ff       	call   f0103910 <trap_init_percpu>
}
f01039b7:	5d                   	pop    %ebp
f01039b8:	c3                   	ret    

f01039b9 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01039b9:	55                   	push   %ebp
f01039ba:	89 e5                	mov    %esp,%ebp
f01039bc:	56                   	push   %esi
f01039bd:	53                   	push   %ebx
f01039be:	e8 a4 c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01039c3:	81 c3 a5 ae 07 00    	add    $0x7aea5,%ebx
f01039c9:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01039cc:	83 ec 08             	sub    $0x8,%esp
f01039cf:	ff 36                	push   (%esi)
f01039d1:	8d 83 0d 75 f8 ff    	lea    -0x78af3(%ebx),%eax
f01039d7:	50                   	push   %eax
f01039d8:	e8 1f ff ff ff       	call   f01038fc <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01039dd:	83 c4 08             	add    $0x8,%esp
f01039e0:	ff 76 04             	push   0x4(%esi)
f01039e3:	8d 83 1c 75 f8 ff    	lea    -0x78ae4(%ebx),%eax
f01039e9:	50                   	push   %eax
f01039ea:	e8 0d ff ff ff       	call   f01038fc <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01039ef:	83 c4 08             	add    $0x8,%esp
f01039f2:	ff 76 08             	push   0x8(%esi)
f01039f5:	8d 83 2b 75 f8 ff    	lea    -0x78ad5(%ebx),%eax
f01039fb:	50                   	push   %eax
f01039fc:	e8 fb fe ff ff       	call   f01038fc <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103a01:	83 c4 08             	add    $0x8,%esp
f0103a04:	ff 76 0c             	push   0xc(%esi)
f0103a07:	8d 83 3a 75 f8 ff    	lea    -0x78ac6(%ebx),%eax
f0103a0d:	50                   	push   %eax
f0103a0e:	e8 e9 fe ff ff       	call   f01038fc <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103a13:	83 c4 08             	add    $0x8,%esp
f0103a16:	ff 76 10             	push   0x10(%esi)
f0103a19:	8d 83 49 75 f8 ff    	lea    -0x78ab7(%ebx),%eax
f0103a1f:	50                   	push   %eax
f0103a20:	e8 d7 fe ff ff       	call   f01038fc <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103a25:	83 c4 08             	add    $0x8,%esp
f0103a28:	ff 76 14             	push   0x14(%esi)
f0103a2b:	8d 83 58 75 f8 ff    	lea    -0x78aa8(%ebx),%eax
f0103a31:	50                   	push   %eax
f0103a32:	e8 c5 fe ff ff       	call   f01038fc <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103a37:	83 c4 08             	add    $0x8,%esp
f0103a3a:	ff 76 18             	push   0x18(%esi)
f0103a3d:	8d 83 67 75 f8 ff    	lea    -0x78a99(%ebx),%eax
f0103a43:	50                   	push   %eax
f0103a44:	e8 b3 fe ff ff       	call   f01038fc <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103a49:	83 c4 08             	add    $0x8,%esp
f0103a4c:	ff 76 1c             	push   0x1c(%esi)
f0103a4f:	8d 83 76 75 f8 ff    	lea    -0x78a8a(%ebx),%eax
f0103a55:	50                   	push   %eax
f0103a56:	e8 a1 fe ff ff       	call   f01038fc <cprintf>
}
f0103a5b:	83 c4 10             	add    $0x10,%esp
f0103a5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a61:	5b                   	pop    %ebx
f0103a62:	5e                   	pop    %esi
f0103a63:	5d                   	pop    %ebp
f0103a64:	c3                   	ret    

f0103a65 <print_trapframe>:
{
f0103a65:	55                   	push   %ebp
f0103a66:	89 e5                	mov    %esp,%ebp
f0103a68:	57                   	push   %edi
f0103a69:	56                   	push   %esi
f0103a6a:	53                   	push   %ebx
f0103a6b:	83 ec 14             	sub    $0x14,%esp
f0103a6e:	e8 f4 c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103a73:	81 c3 f5 ad 07 00    	add    $0x7adf5,%ebx
f0103a79:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0103a7c:	56                   	push   %esi
f0103a7d:	8d 83 ac 76 f8 ff    	lea    -0x78954(%ebx),%eax
f0103a83:	50                   	push   %eax
f0103a84:	e8 73 fe ff ff       	call   f01038fc <cprintf>
	print_regs(&tf->tf_regs);
f0103a89:	89 34 24             	mov    %esi,(%esp)
f0103a8c:	e8 28 ff ff ff       	call   f01039b9 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103a91:	83 c4 08             	add    $0x8,%esp
f0103a94:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0103a98:	50                   	push   %eax
f0103a99:	8d 83 c7 75 f8 ff    	lea    -0x78a39(%ebx),%eax
f0103a9f:	50                   	push   %eax
f0103aa0:	e8 57 fe ff ff       	call   f01038fc <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103aa5:	83 c4 08             	add    $0x8,%esp
f0103aa8:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f0103aac:	50                   	push   %eax
f0103aad:	8d 83 da 75 f8 ff    	lea    -0x78a26(%ebx),%eax
f0103ab3:	50                   	push   %eax
f0103ab4:	e8 43 fe ff ff       	call   f01038fc <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ab9:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f0103abc:	83 c4 10             	add    $0x10,%esp
f0103abf:	83 fa 13             	cmp    $0x13,%edx
f0103ac2:	0f 86 e2 00 00 00    	jbe    f0103baa <print_trapframe+0x145>
		return "System call";
f0103ac8:	83 fa 30             	cmp    $0x30,%edx
f0103acb:	8d 83 85 75 f8 ff    	lea    -0x78a7b(%ebx),%eax
f0103ad1:	8d 8b 94 75 f8 ff    	lea    -0x78a6c(%ebx),%ecx
f0103ad7:	0f 44 c1             	cmove  %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ada:	83 ec 04             	sub    $0x4,%esp
f0103add:	50                   	push   %eax
f0103ade:	52                   	push   %edx
f0103adf:	8d 83 ed 75 f8 ff    	lea    -0x78a13(%ebx),%eax
f0103ae5:	50                   	push   %eax
f0103ae6:	e8 11 fe ff ff       	call   f01038fc <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103aeb:	83 c4 10             	add    $0x10,%esp
f0103aee:	39 b3 f8 22 00 00    	cmp    %esi,0x22f8(%ebx)
f0103af4:	0f 84 bc 00 00 00    	je     f0103bb6 <print_trapframe+0x151>
	cprintf("  err  0x%08x", tf->tf_err);
f0103afa:	83 ec 08             	sub    $0x8,%esp
f0103afd:	ff 76 2c             	push   0x2c(%esi)
f0103b00:	8d 83 0e 76 f8 ff    	lea    -0x789f2(%ebx),%eax
f0103b06:	50                   	push   %eax
f0103b07:	e8 f0 fd ff ff       	call   f01038fc <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103b0c:	83 c4 10             	add    $0x10,%esp
f0103b0f:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103b13:	0f 85 c2 00 00 00    	jne    f0103bdb <print_trapframe+0x176>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103b19:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f0103b1c:	a8 01                	test   $0x1,%al
f0103b1e:	8d 8b a0 75 f8 ff    	lea    -0x78a60(%ebx),%ecx
f0103b24:	8d 93 ab 75 f8 ff    	lea    -0x78a55(%ebx),%edx
f0103b2a:	0f 44 ca             	cmove  %edx,%ecx
f0103b2d:	a8 02                	test   $0x2,%al
f0103b2f:	8d 93 b7 75 f8 ff    	lea    -0x78a49(%ebx),%edx
f0103b35:	8d bb bd 75 f8 ff    	lea    -0x78a43(%ebx),%edi
f0103b3b:	0f 44 d7             	cmove  %edi,%edx
f0103b3e:	a8 04                	test   $0x4,%al
f0103b40:	8d 83 c2 75 f8 ff    	lea    -0x78a3e(%ebx),%eax
f0103b46:	8d bb d7 76 f8 ff    	lea    -0x78929(%ebx),%edi
f0103b4c:	0f 44 c7             	cmove  %edi,%eax
f0103b4f:	51                   	push   %ecx
f0103b50:	52                   	push   %edx
f0103b51:	50                   	push   %eax
f0103b52:	8d 83 1c 76 f8 ff    	lea    -0x789e4(%ebx),%eax
f0103b58:	50                   	push   %eax
f0103b59:	e8 9e fd ff ff       	call   f01038fc <cprintf>
f0103b5e:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103b61:	83 ec 08             	sub    $0x8,%esp
f0103b64:	ff 76 30             	push   0x30(%esi)
f0103b67:	8d 83 2b 76 f8 ff    	lea    -0x789d5(%ebx),%eax
f0103b6d:	50                   	push   %eax
f0103b6e:	e8 89 fd ff ff       	call   f01038fc <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103b73:	83 c4 08             	add    $0x8,%esp
f0103b76:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103b7a:	50                   	push   %eax
f0103b7b:	8d 83 3a 76 f8 ff    	lea    -0x789c6(%ebx),%eax
f0103b81:	50                   	push   %eax
f0103b82:	e8 75 fd ff ff       	call   f01038fc <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103b87:	83 c4 08             	add    $0x8,%esp
f0103b8a:	ff 76 38             	push   0x38(%esi)
f0103b8d:	8d 83 4d 76 f8 ff    	lea    -0x789b3(%ebx),%eax
f0103b93:	50                   	push   %eax
f0103b94:	e8 63 fd ff ff       	call   f01038fc <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103b99:	83 c4 10             	add    $0x10,%esp
f0103b9c:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0103ba0:	75 50                	jne    f0103bf2 <print_trapframe+0x18d>
}
f0103ba2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ba5:	5b                   	pop    %ebx
f0103ba6:	5e                   	pop    %esi
f0103ba7:	5f                   	pop    %edi
f0103ba8:	5d                   	pop    %ebp
f0103ba9:	c3                   	ret    
		return excnames[trapno];
f0103baa:	8b 84 93 f8 17 00 00 	mov    0x17f8(%ebx,%edx,4),%eax
f0103bb1:	e9 24 ff ff ff       	jmp    f0103ada <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103bb6:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103bba:	0f 85 3a ff ff ff    	jne    f0103afa <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103bc0:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103bc3:	83 ec 08             	sub    $0x8,%esp
f0103bc6:	50                   	push   %eax
f0103bc7:	8d 83 ff 75 f8 ff    	lea    -0x78a01(%ebx),%eax
f0103bcd:	50                   	push   %eax
f0103bce:	e8 29 fd ff ff       	call   f01038fc <cprintf>
f0103bd3:	83 c4 10             	add    $0x10,%esp
f0103bd6:	e9 1f ff ff ff       	jmp    f0103afa <print_trapframe+0x95>
		cprintf("\n");
f0103bdb:	83 ec 0c             	sub    $0xc,%esp
f0103bde:	8d 83 ba 73 f8 ff    	lea    -0x78c46(%ebx),%eax
f0103be4:	50                   	push   %eax
f0103be5:	e8 12 fd ff ff       	call   f01038fc <cprintf>
f0103bea:	83 c4 10             	add    $0x10,%esp
f0103bed:	e9 6f ff ff ff       	jmp    f0103b61 <print_trapframe+0xfc>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103bf2:	83 ec 08             	sub    $0x8,%esp
f0103bf5:	ff 76 3c             	push   0x3c(%esi)
f0103bf8:	8d 83 5c 76 f8 ff    	lea    -0x789a4(%ebx),%eax
f0103bfe:	50                   	push   %eax
f0103bff:	e8 f8 fc ff ff       	call   f01038fc <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103c04:	83 c4 08             	add    $0x8,%esp
f0103c07:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0103c0b:	50                   	push   %eax
f0103c0c:	8d 83 6b 76 f8 ff    	lea    -0x78995(%ebx),%eax
f0103c12:	50                   	push   %eax
f0103c13:	e8 e4 fc ff ff       	call   f01038fc <cprintf>
f0103c18:	83 c4 10             	add    $0x10,%esp
}
f0103c1b:	eb 85                	jmp    f0103ba2 <print_trapframe+0x13d>

f0103c1d <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103c1d:	55                   	push   %ebp
f0103c1e:	89 e5                	mov    %esp,%ebp
f0103c20:	57                   	push   %edi
f0103c21:	56                   	push   %esi
f0103c22:	53                   	push   %ebx
f0103c23:	83 ec 0c             	sub    $0xc,%esp
f0103c26:	e8 3c c5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103c2b:	81 c3 3d ac 07 00    	add    $0x7ac3d,%ebx
f0103c31:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103c34:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103c35:	9c                   	pushf  
f0103c36:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103c37:	f6 c4 02             	test   $0x2,%ah
f0103c3a:	74 1f                	je     f0103c5b <trap+0x3e>
f0103c3c:	8d 83 7e 76 f8 ff    	lea    -0x78982(%ebx),%eax
f0103c42:	50                   	push   %eax
f0103c43:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0103c49:	50                   	push   %eax
f0103c4a:	68 a8 00 00 00       	push   $0xa8
f0103c4f:	8d 83 97 76 f8 ff    	lea    -0x78969(%ebx),%eax
f0103c55:	50                   	push   %eax
f0103c56:	e8 56 c4 ff ff       	call   f01000b1 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103c5b:	83 ec 08             	sub    $0x8,%esp
f0103c5e:	56                   	push   %esi
f0103c5f:	8d 83 a3 76 f8 ff    	lea    -0x7895d(%ebx),%eax
f0103c65:	50                   	push   %eax
f0103c66:	e8 91 fc ff ff       	call   f01038fc <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103c6b:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103c6f:	83 e0 03             	and    $0x3,%eax
f0103c72:	83 c4 10             	add    $0x10,%esp
f0103c75:	66 83 f8 03          	cmp    $0x3,%ax
f0103c79:	75 1d                	jne    f0103c98 <trap+0x7b>
		// Trapped from user mode.
		assert(curenv);
f0103c7b:	c7 c0 50 03 18 f0    	mov    $0xf0180350,%eax
f0103c81:	8b 00                	mov    (%eax),%eax
f0103c83:	85 c0                	test   %eax,%eax
f0103c85:	74 68                	je     f0103cef <trap+0xd2>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103c87:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103c8c:	89 c7                	mov    %eax,%edi
f0103c8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103c90:	c7 c0 50 03 18 f0    	mov    $0xf0180350,%eax
f0103c96:	8b 30                	mov    (%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103c98:	89 b3 f8 22 00 00    	mov    %esi,0x22f8(%ebx)
	print_trapframe(tf);
f0103c9e:	83 ec 0c             	sub    $0xc,%esp
f0103ca1:	56                   	push   %esi
f0103ca2:	e8 be fd ff ff       	call   f0103a65 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103ca7:	83 c4 10             	add    $0x10,%esp
f0103caa:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103caf:	74 5d                	je     f0103d0e <trap+0xf1>
		env_destroy(curenv);
f0103cb1:	83 ec 0c             	sub    $0xc,%esp
f0103cb4:	c7 c6 50 03 18 f0    	mov    $0xf0180350,%esi
f0103cba:	ff 36                	push   (%esi)
f0103cbc:	e8 d1 fa ff ff       	call   f0103792 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103cc1:	8b 06                	mov    (%esi),%eax
f0103cc3:	83 c4 10             	add    $0x10,%esp
f0103cc6:	85 c0                	test   %eax,%eax
f0103cc8:	74 06                	je     f0103cd0 <trap+0xb3>
f0103cca:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103cce:	74 59                	je     f0103d29 <trap+0x10c>
f0103cd0:	8d 83 24 78 f8 ff    	lea    -0x787dc(%ebx),%eax
f0103cd6:	50                   	push   %eax
f0103cd7:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0103cdd:	50                   	push   %eax
f0103cde:	68 c0 00 00 00       	push   $0xc0
f0103ce3:	8d 83 97 76 f8 ff    	lea    -0x78969(%ebx),%eax
f0103ce9:	50                   	push   %eax
f0103cea:	e8 c2 c3 ff ff       	call   f01000b1 <_panic>
		assert(curenv);
f0103cef:	8d 83 be 76 f8 ff    	lea    -0x78942(%ebx),%eax
f0103cf5:	50                   	push   %eax
f0103cf6:	8d 83 2f 71 f8 ff    	lea    -0x78ed1(%ebx),%eax
f0103cfc:	50                   	push   %eax
f0103cfd:	68 ae 00 00 00       	push   $0xae
f0103d02:	8d 83 97 76 f8 ff    	lea    -0x78969(%ebx),%eax
f0103d08:	50                   	push   %eax
f0103d09:	e8 a3 c3 ff ff       	call   f01000b1 <_panic>
		panic("unhandled trap in kernel");
f0103d0e:	83 ec 04             	sub    $0x4,%esp
f0103d11:	8d 83 c5 76 f8 ff    	lea    -0x7893b(%ebx),%eax
f0103d17:	50                   	push   %eax
f0103d18:	68 97 00 00 00       	push   $0x97
f0103d1d:	8d 83 97 76 f8 ff    	lea    -0x78969(%ebx),%eax
f0103d23:	50                   	push   %eax
f0103d24:	e8 88 c3 ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f0103d29:	83 ec 0c             	sub    $0xc,%esp
f0103d2c:	50                   	push   %eax
f0103d2d:	e8 ce fa ff ff       	call   f0103800 <env_run>

f0103d32 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103d32:	55                   	push   %ebp
f0103d33:	89 e5                	mov    %esp,%ebp
f0103d35:	57                   	push   %edi
f0103d36:	56                   	push   %esi
f0103d37:	53                   	push   %ebx
f0103d38:	83 ec 0c             	sub    $0xc,%esp
f0103d3b:	e8 27 c4 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103d40:	81 c3 28 ab 07 00    	add    $0x7ab28,%ebx
f0103d46:	8b 7d 08             	mov    0x8(%ebp),%edi
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103d49:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103d4c:	ff 77 30             	push   0x30(%edi)
f0103d4f:	50                   	push   %eax
f0103d50:	c7 c6 50 03 18 f0    	mov    $0xf0180350,%esi
f0103d56:	8b 06                	mov    (%esi),%eax
f0103d58:	ff 70 48             	push   0x48(%eax)
f0103d5b:	8d 83 50 78 f8 ff    	lea    -0x787b0(%ebx),%eax
f0103d61:	50                   	push   %eax
f0103d62:	e8 95 fb ff ff       	call   f01038fc <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103d67:	89 3c 24             	mov    %edi,(%esp)
f0103d6a:	e8 f6 fc ff ff       	call   f0103a65 <print_trapframe>
	env_destroy(curenv);
f0103d6f:	83 c4 04             	add    $0x4,%esp
f0103d72:	ff 36                	push   (%esi)
f0103d74:	e8 19 fa ff ff       	call   f0103792 <env_destroy>
}
f0103d79:	83 c4 10             	add    $0x10,%esp
f0103d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d7f:	5b                   	pop    %ebx
f0103d80:	5e                   	pop    %esi
f0103d81:	5f                   	pop    %edi
f0103d82:	5d                   	pop    %ebp
f0103d83:	c3                   	ret    

f0103d84 <syscall>:
f0103d84:	55                   	push   %ebp
f0103d85:	89 e5                	mov    %esp,%ebp
f0103d87:	53                   	push   %ebx
f0103d88:	83 ec 08             	sub    $0x8,%esp
f0103d8b:	e8 d7 c3 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103d90:	81 c3 d8 aa 07 00    	add    $0x7aad8,%ebx
f0103d96:	8d 83 73 78 f8 ff    	lea    -0x7878d(%ebx),%eax
f0103d9c:	50                   	push   %eax
f0103d9d:	6a 49                	push   $0x49
f0103d9f:	8d 83 8b 78 f8 ff    	lea    -0x78775(%ebx),%eax
f0103da5:	50                   	push   %eax
f0103da6:	e8 06 c3 ff ff       	call   f01000b1 <_panic>

f0103dab <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103dab:	55                   	push   %ebp
f0103dac:	89 e5                	mov    %esp,%ebp
f0103dae:	57                   	push   %edi
f0103daf:	56                   	push   %esi
f0103db0:	53                   	push   %ebx
f0103db1:	83 ec 14             	sub    $0x14,%esp
f0103db4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103db7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103dba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103dbd:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103dc0:	8b 1a                	mov    (%edx),%ebx
f0103dc2:	8b 01                	mov    (%ecx),%eax
f0103dc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103dc7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103dce:	eb 2f                	jmp    f0103dff <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103dd0:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0103dd3:	39 c3                	cmp    %eax,%ebx
f0103dd5:	7f 4e                	jg     f0103e25 <stab_binsearch+0x7a>
f0103dd7:	0f b6 0a             	movzbl (%edx),%ecx
f0103dda:	83 ea 0c             	sub    $0xc,%edx
f0103ddd:	39 f1                	cmp    %esi,%ecx
f0103ddf:	75 ef                	jne    f0103dd0 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103de1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103de4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103de7:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103deb:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103dee:	73 3a                	jae    f0103e2a <stab_binsearch+0x7f>
			*region_left = m;
f0103df0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103df3:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103df5:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0103df8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103dff:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103e02:	7f 53                	jg     f0103e57 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0103e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103e07:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0103e0a:	89 d0                	mov    %edx,%eax
f0103e0c:	c1 e8 1f             	shr    $0x1f,%eax
f0103e0f:	01 d0                	add    %edx,%eax
f0103e11:	89 c7                	mov    %eax,%edi
f0103e13:	d1 ff                	sar    %edi
f0103e15:	83 e0 fe             	and    $0xfffffffe,%eax
f0103e18:	01 f8                	add    %edi,%eax
f0103e1a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103e1d:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103e21:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0103e23:	eb ae                	jmp    f0103dd3 <stab_binsearch+0x28>
			l = true_m + 1;
f0103e25:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103e28:	eb d5                	jmp    f0103dff <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0103e2a:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103e2d:	76 14                	jbe    f0103e43 <stab_binsearch+0x98>
			*region_right = m - 1;
f0103e2f:	83 e8 01             	sub    $0x1,%eax
f0103e32:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103e35:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103e38:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0103e3a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103e41:	eb bc                	jmp    f0103dff <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103e43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e46:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0103e48:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103e4c:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0103e4e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103e55:	eb a8                	jmp    f0103dff <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0103e57:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103e5b:	75 15                	jne    f0103e72 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0103e5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103e60:	8b 00                	mov    (%eax),%eax
f0103e62:	83 e8 01             	sub    $0x1,%eax
f0103e65:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103e68:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103e6a:	83 c4 14             	add    $0x14,%esp
f0103e6d:	5b                   	pop    %ebx
f0103e6e:	5e                   	pop    %esi
f0103e6f:	5f                   	pop    %edi
f0103e70:	5d                   	pop    %ebp
f0103e71:	c3                   	ret    
		for (l = *region_right;
f0103e72:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e75:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103e77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e7a:	8b 0f                	mov    (%edi),%ecx
f0103e7c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103e7f:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103e82:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0103e86:	39 c1                	cmp    %eax,%ecx
f0103e88:	7d 0f                	jge    f0103e99 <stab_binsearch+0xee>
f0103e8a:	0f b6 1a             	movzbl (%edx),%ebx
f0103e8d:	83 ea 0c             	sub    $0xc,%edx
f0103e90:	39 f3                	cmp    %esi,%ebx
f0103e92:	74 05                	je     f0103e99 <stab_binsearch+0xee>
		     l--)
f0103e94:	83 e8 01             	sub    $0x1,%eax
f0103e97:	eb ed                	jmp    f0103e86 <stab_binsearch+0xdb>
		*region_left = l;
f0103e99:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e9c:	89 07                	mov    %eax,(%edi)
}
f0103e9e:	eb ca                	jmp    f0103e6a <stab_binsearch+0xbf>

f0103ea0 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103ea0:	55                   	push   %ebp
f0103ea1:	89 e5                	mov    %esp,%ebp
f0103ea3:	57                   	push   %edi
f0103ea4:	56                   	push   %esi
f0103ea5:	53                   	push   %ebx
f0103ea6:	83 ec 3c             	sub    $0x3c,%esp
f0103ea9:	e8 b9 c2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103eae:	81 c3 ba a9 07 00    	add    $0x7a9ba,%ebx
f0103eb4:	8b 75 08             	mov    0x8(%ebp),%esi
f0103eb7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103eba:	8d 83 9a 78 f8 ff    	lea    -0x78766(%ebx),%eax
f0103ec0:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0103ec2:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0103ec9:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0103ecc:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0103ed3:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f0103ed6:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103edd:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103ee3:	0f 87 ea 00 00 00    	ja     f0103fd3 <debuginfo_eip+0x133>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103ee9:	a1 00 00 20 00       	mov    0x200000,%eax
f0103eee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0103ef1:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103ef6:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0103efc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0103eff:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0103f05:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103f08:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103f0b:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0103f0e:	0f 83 56 01 00 00    	jae    f010406a <debuginfo_eip+0x1ca>
f0103f14:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0103f18:	0f 85 53 01 00 00    	jne    f0104071 <debuginfo_eip+0x1d1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103f1e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103f25:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0103f28:	c1 f8 02             	sar    $0x2,%eax
f0103f2b:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103f31:	83 e8 01             	sub    $0x1,%eax
f0103f34:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103f37:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103f3a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103f3d:	56                   	push   %esi
f0103f3e:	6a 64                	push   $0x64
f0103f40:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103f43:	e8 63 fe ff ff       	call   f0103dab <stab_binsearch>
	if (lfile == 0)
f0103f48:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103f4b:	83 c4 08             	add    $0x8,%esp
f0103f4e:	85 c9                	test   %ecx,%ecx
f0103f50:	0f 84 22 01 00 00    	je     f0104078 <debuginfo_eip+0x1d8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103f56:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103f59:	89 4d dc             	mov    %ecx,-0x24(%ebp)
	rfun = rfile;
f0103f5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f5f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103f62:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103f65:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103f68:	56                   	push   %esi
f0103f69:	6a 24                	push   $0x24
f0103f6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103f6e:	e8 38 fe ff ff       	call   f0103dab <stab_binsearch>

	if (lfun <= rfun) {
f0103f73:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103f76:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0103f79:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103f7c:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0103f7f:	83 c4 08             	add    $0x8,%esp
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
		lline = lfile;
f0103f82:	8b 75 c8             	mov    -0x38(%ebp),%esi
	if (lfun <= rfun) {
f0103f85:	39 c2                	cmp    %eax,%edx
f0103f87:	7f 25                	jg     f0103fae <debuginfo_eip+0x10e>
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103f89:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103f8c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103f8f:	8d 14 86             	lea    (%esi,%eax,4),%edx
f0103f92:	8b 02                	mov    (%edx),%eax
f0103f94:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103f97:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0103f9a:	29 f1                	sub    %esi,%ecx
f0103f9c:	39 c8                	cmp    %ecx,%eax
f0103f9e:	73 05                	jae    f0103fa5 <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103fa0:	01 f0                	add    %esi,%eax
f0103fa2:	89 47 08             	mov    %eax,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103fa5:	8b 42 08             	mov    0x8(%edx),%eax
f0103fa8:	89 47 10             	mov    %eax,0x10(%edi)
		lline = lfun;
f0103fab:	8b 75 c4             	mov    -0x3c(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103fae:	83 ec 08             	sub    $0x8,%esp
f0103fb1:	6a 3a                	push   $0x3a
f0103fb3:	ff 77 08             	push   0x8(%edi)
f0103fb6:	e8 22 09 00 00       	call   f01048dd <strfind>
f0103fbb:	2b 47 08             	sub    0x8(%edi),%eax
f0103fbe:	89 47 0c             	mov    %eax,0xc(%edi)
f0103fc1:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103fc4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103fc7:	8d 44 83 04          	lea    0x4(%ebx,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103fcb:	83 c4 10             	add    $0x10,%esp
f0103fce:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0103fd1:	eb 2c                	jmp    f0103fff <debuginfo_eip+0x15f>
		stabstr_end = __STABSTR_END__;
f0103fd3:	c7 c0 0c 1a 11 f0    	mov    $0xf0111a0c,%eax
f0103fd9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0103fdc:	c7 c0 79 e1 10 f0    	mov    $0xf010e179,%eax
f0103fe2:	89 45 cc             	mov    %eax,-0x34(%ebp)
		stab_end = __STAB_END__;
f0103fe5:	c7 c0 78 e1 10 f0    	mov    $0xf010e178,%eax
		stabs = __STAB_BEGIN__;
f0103feb:	c7 c1 00 63 10 f0    	mov    $0xf0106300,%ecx
f0103ff1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103ff4:	e9 0f ff ff ff       	jmp    f0103f08 <debuginfo_eip+0x68>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103ff9:	83 ee 01             	sub    $0x1,%esi
f0103ffc:	83 e8 0c             	sub    $0xc,%eax
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103fff:	39 f3                	cmp    %esi,%ebx
f0104001:	7f 2e                	jg     f0104031 <debuginfo_eip+0x191>
	       && stabs[lline].n_type != N_SOL
f0104003:	0f b6 10             	movzbl (%eax),%edx
f0104006:	80 fa 84             	cmp    $0x84,%dl
f0104009:	74 0b                	je     f0104016 <debuginfo_eip+0x176>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010400b:	80 fa 64             	cmp    $0x64,%dl
f010400e:	75 e9                	jne    f0103ff9 <debuginfo_eip+0x159>
f0104010:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0104014:	74 e3                	je     f0103ff9 <debuginfo_eip+0x159>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104016:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104019:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010401c:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010401f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104022:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104025:	29 d8                	sub    %ebx,%eax
f0104027:	39 c2                	cmp    %eax,%edx
f0104029:	73 06                	jae    f0104031 <debuginfo_eip+0x191>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010402b:	89 d8                	mov    %ebx,%eax
f010402d:	01 d0                	add    %edx,%eax
f010402f:	89 07                	mov    %eax,(%edi)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104031:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104036:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0104039:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010403c:	39 cb                	cmp    %ecx,%ebx
f010403e:	7d 44                	jge    f0104084 <debuginfo_eip+0x1e4>
		for (lline = lfun + 1;
f0104040:	8d 53 01             	lea    0x1(%ebx),%edx
f0104043:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104046:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104049:	8d 44 83 10          	lea    0x10(%ebx,%eax,4),%eax
f010404d:	eb 07                	jmp    f0104056 <debuginfo_eip+0x1b6>
			info->eip_fn_narg++;
f010404f:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0104053:	83 c2 01             	add    $0x1,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104056:	39 d1                	cmp    %edx,%ecx
f0104058:	74 25                	je     f010407f <debuginfo_eip+0x1df>
f010405a:	83 c0 0c             	add    $0xc,%eax
f010405d:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0104061:	74 ec                	je     f010404f <debuginfo_eip+0x1af>
	return 0;
f0104063:	b8 00 00 00 00       	mov    $0x0,%eax
f0104068:	eb 1a                	jmp    f0104084 <debuginfo_eip+0x1e4>
		return -1;
f010406a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010406f:	eb 13                	jmp    f0104084 <debuginfo_eip+0x1e4>
f0104071:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104076:	eb 0c                	jmp    f0104084 <debuginfo_eip+0x1e4>
		return -1;
f0104078:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010407d:	eb 05                	jmp    f0104084 <debuginfo_eip+0x1e4>
	return 0;
f010407f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104084:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104087:	5b                   	pop    %ebx
f0104088:	5e                   	pop    %esi
f0104089:	5f                   	pop    %edi
f010408a:	5d                   	pop    %ebp
f010408b:	c3                   	ret    

f010408c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010408c:	55                   	push   %ebp
f010408d:	89 e5                	mov    %esp,%ebp
f010408f:	57                   	push   %edi
f0104090:	56                   	push   %esi
f0104091:	53                   	push   %ebx
f0104092:	83 ec 2c             	sub    $0x2c,%esp
f0104095:	e8 db ef ff ff       	call   f0103075 <__x86.get_pc_thunk.cx>
f010409a:	81 c1 ce a7 07 00    	add    $0x7a7ce,%ecx
f01040a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01040a3:	89 c7                	mov    %eax,%edi
f01040a5:	89 d6                	mov    %edx,%esi
f01040a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01040aa:	8b 55 0c             	mov    0xc(%ebp),%edx
f01040ad:	89 d1                	mov    %edx,%ecx
f01040af:	89 c2                	mov    %eax,%edx
f01040b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01040b4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01040b7:	8b 45 10             	mov    0x10(%ebp),%eax
f01040ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01040bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01040c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01040c7:	39 c2                	cmp    %eax,%edx
f01040c9:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f01040cc:	72 41                	jb     f010410f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01040ce:	83 ec 0c             	sub    $0xc,%esp
f01040d1:	ff 75 18             	push   0x18(%ebp)
f01040d4:	83 eb 01             	sub    $0x1,%ebx
f01040d7:	53                   	push   %ebx
f01040d8:	50                   	push   %eax
f01040d9:	83 ec 08             	sub    $0x8,%esp
f01040dc:	ff 75 e4             	push   -0x1c(%ebp)
f01040df:	ff 75 e0             	push   -0x20(%ebp)
f01040e2:	ff 75 d4             	push   -0x2c(%ebp)
f01040e5:	ff 75 d0             	push   -0x30(%ebp)
f01040e8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01040eb:	e8 00 0a 00 00       	call   f0104af0 <__udivdi3>
f01040f0:	83 c4 18             	add    $0x18,%esp
f01040f3:	52                   	push   %edx
f01040f4:	50                   	push   %eax
f01040f5:	89 f2                	mov    %esi,%edx
f01040f7:	89 f8                	mov    %edi,%eax
f01040f9:	e8 8e ff ff ff       	call   f010408c <printnum>
f01040fe:	83 c4 20             	add    $0x20,%esp
f0104101:	eb 13                	jmp    f0104116 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104103:	83 ec 08             	sub    $0x8,%esp
f0104106:	56                   	push   %esi
f0104107:	ff 75 18             	push   0x18(%ebp)
f010410a:	ff d7                	call   *%edi
f010410c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010410f:	83 eb 01             	sub    $0x1,%ebx
f0104112:	85 db                	test   %ebx,%ebx
f0104114:	7f ed                	jg     f0104103 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104116:	83 ec 08             	sub    $0x8,%esp
f0104119:	56                   	push   %esi
f010411a:	83 ec 04             	sub    $0x4,%esp
f010411d:	ff 75 e4             	push   -0x1c(%ebp)
f0104120:	ff 75 e0             	push   -0x20(%ebp)
f0104123:	ff 75 d4             	push   -0x2c(%ebp)
f0104126:	ff 75 d0             	push   -0x30(%ebp)
f0104129:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010412c:	e8 df 0a 00 00       	call   f0104c10 <__umoddi3>
f0104131:	83 c4 14             	add    $0x14,%esp
f0104134:	0f be 84 03 a4 78 f8 	movsbl -0x7875c(%ebx,%eax,1),%eax
f010413b:	ff 
f010413c:	50                   	push   %eax
f010413d:	ff d7                	call   *%edi
}
f010413f:	83 c4 10             	add    $0x10,%esp
f0104142:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104145:	5b                   	pop    %ebx
f0104146:	5e                   	pop    %esi
f0104147:	5f                   	pop    %edi
f0104148:	5d                   	pop    %ebp
f0104149:	c3                   	ret    

f010414a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010414a:	55                   	push   %ebp
f010414b:	89 e5                	mov    %esp,%ebp
f010414d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104150:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104154:	8b 10                	mov    (%eax),%edx
f0104156:	3b 50 04             	cmp    0x4(%eax),%edx
f0104159:	73 0a                	jae    f0104165 <sprintputch+0x1b>
		*b->buf++ = ch;
f010415b:	8d 4a 01             	lea    0x1(%edx),%ecx
f010415e:	89 08                	mov    %ecx,(%eax)
f0104160:	8b 45 08             	mov    0x8(%ebp),%eax
f0104163:	88 02                	mov    %al,(%edx)
}
f0104165:	5d                   	pop    %ebp
f0104166:	c3                   	ret    

f0104167 <printfmt>:
{
f0104167:	55                   	push   %ebp
f0104168:	89 e5                	mov    %esp,%ebp
f010416a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f010416d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104170:	50                   	push   %eax
f0104171:	ff 75 10             	push   0x10(%ebp)
f0104174:	ff 75 0c             	push   0xc(%ebp)
f0104177:	ff 75 08             	push   0x8(%ebp)
f010417a:	e8 05 00 00 00       	call   f0104184 <vprintfmt>
}
f010417f:	83 c4 10             	add    $0x10,%esp
f0104182:	c9                   	leave  
f0104183:	c3                   	ret    

f0104184 <vprintfmt>:
{
f0104184:	55                   	push   %ebp
f0104185:	89 e5                	mov    %esp,%ebp
f0104187:	57                   	push   %edi
f0104188:	56                   	push   %esi
f0104189:	53                   	push   %ebx
f010418a:	83 ec 3c             	sub    $0x3c,%esp
f010418d:	e8 67 c5 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0104192:	05 d6 a6 07 00       	add    $0x7a6d6,%eax
f0104197:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010419a:	8b 75 08             	mov    0x8(%ebp),%esi
f010419d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01041a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01041a3:	8d 80 48 18 00 00    	lea    0x1848(%eax),%eax
f01041a9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01041ac:	eb 0a                	jmp    f01041b8 <vprintfmt+0x34>
			putch(ch, putdat);
f01041ae:	83 ec 08             	sub    $0x8,%esp
f01041b1:	57                   	push   %edi
f01041b2:	50                   	push   %eax
f01041b3:	ff d6                	call   *%esi
f01041b5:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01041b8:	83 c3 01             	add    $0x1,%ebx
f01041bb:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01041bf:	83 f8 25             	cmp    $0x25,%eax
f01041c2:	74 0c                	je     f01041d0 <vprintfmt+0x4c>
			if (ch == '\0')
f01041c4:	85 c0                	test   %eax,%eax
f01041c6:	75 e6                	jne    f01041ae <vprintfmt+0x2a>
}
f01041c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01041cb:	5b                   	pop    %ebx
f01041cc:	5e                   	pop    %esi
f01041cd:	5f                   	pop    %edi
f01041ce:	5d                   	pop    %ebp
f01041cf:	c3                   	ret    
		padc = ' ';
f01041d0:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f01041d4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f01041db:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f01041e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f01041e9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01041ee:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01041f1:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01041f4:	8d 43 01             	lea    0x1(%ebx),%eax
f01041f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01041fa:	0f b6 13             	movzbl (%ebx),%edx
f01041fd:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104200:	3c 55                	cmp    $0x55,%al
f0104202:	0f 87 c5 03 00 00    	ja     f01045cd <.L20>
f0104208:	0f b6 c0             	movzbl %al,%eax
f010420b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010420e:	89 ce                	mov    %ecx,%esi
f0104210:	03 b4 81 30 79 f8 ff 	add    -0x786d0(%ecx,%eax,4),%esi
f0104217:	ff e6                	jmp    *%esi

f0104219 <.L66>:
f0104219:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f010421c:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0104220:	eb d2                	jmp    f01041f4 <vprintfmt+0x70>

f0104222 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0104222:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104225:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0104229:	eb c9                	jmp    f01041f4 <vprintfmt+0x70>

f010422b <.L31>:
f010422b:	0f b6 d2             	movzbl %dl,%edx
f010422e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0104231:	b8 00 00 00 00       	mov    $0x0,%eax
f0104236:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0104239:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010423c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104240:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0104243:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104246:	83 f9 09             	cmp    $0x9,%ecx
f0104249:	77 58                	ja     f01042a3 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f010424b:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f010424e:	eb e9                	jmp    f0104239 <.L31+0xe>

f0104250 <.L34>:
			precision = va_arg(ap, int);
f0104250:	8b 45 14             	mov    0x14(%ebp),%eax
f0104253:	8b 00                	mov    (%eax),%eax
f0104255:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104258:	8b 45 14             	mov    0x14(%ebp),%eax
f010425b:	8d 40 04             	lea    0x4(%eax),%eax
f010425e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104261:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0104264:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0104268:	79 8a                	jns    f01041f4 <vprintfmt+0x70>
				width = precision, precision = -1;
f010426a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010426d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104270:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0104277:	e9 78 ff ff ff       	jmp    f01041f4 <vprintfmt+0x70>

f010427c <.L33>:
f010427c:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010427f:	85 d2                	test   %edx,%edx
f0104281:	b8 00 00 00 00       	mov    $0x0,%eax
f0104286:	0f 49 c2             	cmovns %edx,%eax
f0104289:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010428c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010428f:	e9 60 ff ff ff       	jmp    f01041f4 <vprintfmt+0x70>

f0104294 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0104294:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0104297:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f010429e:	e9 51 ff ff ff       	jmp    f01041f4 <vprintfmt+0x70>
f01042a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01042a6:	89 75 08             	mov    %esi,0x8(%ebp)
f01042a9:	eb b9                	jmp    f0104264 <.L34+0x14>

f01042ab <.L27>:
			lflag++;
f01042ab:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01042af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01042b2:	e9 3d ff ff ff       	jmp    f01041f4 <vprintfmt+0x70>

f01042b7 <.L30>:
			putch(va_arg(ap, int), putdat);
f01042b7:	8b 75 08             	mov    0x8(%ebp),%esi
f01042ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01042bd:	8d 58 04             	lea    0x4(%eax),%ebx
f01042c0:	83 ec 08             	sub    $0x8,%esp
f01042c3:	57                   	push   %edi
f01042c4:	ff 30                	push   (%eax)
f01042c6:	ff d6                	call   *%esi
			break;
f01042c8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01042cb:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f01042ce:	e9 90 02 00 00       	jmp    f0104563 <.L25+0x45>

f01042d3 <.L28>:
			err = va_arg(ap, int);
f01042d3:	8b 75 08             	mov    0x8(%ebp),%esi
f01042d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01042d9:	8d 58 04             	lea    0x4(%eax),%ebx
f01042dc:	8b 10                	mov    (%eax),%edx
f01042de:	89 d0                	mov    %edx,%eax
f01042e0:	f7 d8                	neg    %eax
f01042e2:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01042e5:	83 f8 06             	cmp    $0x6,%eax
f01042e8:	7f 27                	jg     f0104311 <.L28+0x3e>
f01042ea:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01042ed:	8b 14 82             	mov    (%edx,%eax,4),%edx
f01042f0:	85 d2                	test   %edx,%edx
f01042f2:	74 1d                	je     f0104311 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f01042f4:	52                   	push   %edx
f01042f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01042f8:	8d 80 41 71 f8 ff    	lea    -0x78ebf(%eax),%eax
f01042fe:	50                   	push   %eax
f01042ff:	57                   	push   %edi
f0104300:	56                   	push   %esi
f0104301:	e8 61 fe ff ff       	call   f0104167 <printfmt>
f0104306:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104309:	89 5d 14             	mov    %ebx,0x14(%ebp)
f010430c:	e9 52 02 00 00       	jmp    f0104563 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0104311:	50                   	push   %eax
f0104312:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104315:	8d 80 bc 78 f8 ff    	lea    -0x78744(%eax),%eax
f010431b:	50                   	push   %eax
f010431c:	57                   	push   %edi
f010431d:	56                   	push   %esi
f010431e:	e8 44 fe ff ff       	call   f0104167 <printfmt>
f0104323:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104326:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104329:	e9 35 02 00 00       	jmp    f0104563 <.L25+0x45>

f010432e <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f010432e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104331:	8b 45 14             	mov    0x14(%ebp),%eax
f0104334:	83 c0 04             	add    $0x4,%eax
f0104337:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010433a:	8b 45 14             	mov    0x14(%ebp),%eax
f010433d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010433f:	85 d2                	test   %edx,%edx
f0104341:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104344:	8d 80 b5 78 f8 ff    	lea    -0x7874b(%eax),%eax
f010434a:	0f 45 c2             	cmovne %edx,%eax
f010434d:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0104350:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0104354:	7e 06                	jle    f010435c <.L24+0x2e>
f0104356:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f010435a:	75 0d                	jne    f0104369 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f010435c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010435f:	89 c3                	mov    %eax,%ebx
f0104361:	03 45 d0             	add    -0x30(%ebp),%eax
f0104364:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104367:	eb 58                	jmp    f01043c1 <.L24+0x93>
f0104369:	83 ec 08             	sub    $0x8,%esp
f010436c:	ff 75 d8             	push   -0x28(%ebp)
f010436f:	ff 75 c8             	push   -0x38(%ebp)
f0104372:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104375:	e8 0c 04 00 00       	call   f0104786 <strnlen>
f010437a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010437d:	29 c2                	sub    %eax,%edx
f010437f:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0104382:	83 c4 10             	add    $0x10,%esp
f0104385:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0104387:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f010438b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010438e:	eb 0f                	jmp    f010439f <.L24+0x71>
					putch(padc, putdat);
f0104390:	83 ec 08             	sub    $0x8,%esp
f0104393:	57                   	push   %edi
f0104394:	ff 75 d0             	push   -0x30(%ebp)
f0104397:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104399:	83 eb 01             	sub    $0x1,%ebx
f010439c:	83 c4 10             	add    $0x10,%esp
f010439f:	85 db                	test   %ebx,%ebx
f01043a1:	7f ed                	jg     f0104390 <.L24+0x62>
f01043a3:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01043a6:	85 d2                	test   %edx,%edx
f01043a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01043ad:	0f 49 c2             	cmovns %edx,%eax
f01043b0:	29 c2                	sub    %eax,%edx
f01043b2:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01043b5:	eb a5                	jmp    f010435c <.L24+0x2e>
					putch(ch, putdat);
f01043b7:	83 ec 08             	sub    $0x8,%esp
f01043ba:	57                   	push   %edi
f01043bb:	52                   	push   %edx
f01043bc:	ff d6                	call   *%esi
f01043be:	83 c4 10             	add    $0x10,%esp
f01043c1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01043c4:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01043c6:	83 c3 01             	add    $0x1,%ebx
f01043c9:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01043cd:	0f be d0             	movsbl %al,%edx
f01043d0:	85 d2                	test   %edx,%edx
f01043d2:	74 4b                	je     f010441f <.L24+0xf1>
f01043d4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01043d8:	78 06                	js     f01043e0 <.L24+0xb2>
f01043da:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01043de:	78 1e                	js     f01043fe <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f01043e0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01043e4:	74 d1                	je     f01043b7 <.L24+0x89>
f01043e6:	0f be c0             	movsbl %al,%eax
f01043e9:	83 e8 20             	sub    $0x20,%eax
f01043ec:	83 f8 5e             	cmp    $0x5e,%eax
f01043ef:	76 c6                	jbe    f01043b7 <.L24+0x89>
					putch('?', putdat);
f01043f1:	83 ec 08             	sub    $0x8,%esp
f01043f4:	57                   	push   %edi
f01043f5:	6a 3f                	push   $0x3f
f01043f7:	ff d6                	call   *%esi
f01043f9:	83 c4 10             	add    $0x10,%esp
f01043fc:	eb c3                	jmp    f01043c1 <.L24+0x93>
f01043fe:	89 cb                	mov    %ecx,%ebx
f0104400:	eb 0e                	jmp    f0104410 <.L24+0xe2>
				putch(' ', putdat);
f0104402:	83 ec 08             	sub    $0x8,%esp
f0104405:	57                   	push   %edi
f0104406:	6a 20                	push   $0x20
f0104408:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010440a:	83 eb 01             	sub    $0x1,%ebx
f010440d:	83 c4 10             	add    $0x10,%esp
f0104410:	85 db                	test   %ebx,%ebx
f0104412:	7f ee                	jg     f0104402 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f0104414:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104417:	89 45 14             	mov    %eax,0x14(%ebp)
f010441a:	e9 44 01 00 00       	jmp    f0104563 <.L25+0x45>
f010441f:	89 cb                	mov    %ecx,%ebx
f0104421:	eb ed                	jmp    f0104410 <.L24+0xe2>

f0104423 <.L29>:
	if (lflag >= 2)
f0104423:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104426:	8b 75 08             	mov    0x8(%ebp),%esi
f0104429:	83 f9 01             	cmp    $0x1,%ecx
f010442c:	7f 1b                	jg     f0104449 <.L29+0x26>
	else if (lflag)
f010442e:	85 c9                	test   %ecx,%ecx
f0104430:	74 63                	je     f0104495 <.L29+0x72>
		return va_arg(*ap, long);
f0104432:	8b 45 14             	mov    0x14(%ebp),%eax
f0104435:	8b 00                	mov    (%eax),%eax
f0104437:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010443a:	99                   	cltd   
f010443b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010443e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104441:	8d 40 04             	lea    0x4(%eax),%eax
f0104444:	89 45 14             	mov    %eax,0x14(%ebp)
f0104447:	eb 17                	jmp    f0104460 <.L29+0x3d>
		return va_arg(*ap, long long);
f0104449:	8b 45 14             	mov    0x14(%ebp),%eax
f010444c:	8b 50 04             	mov    0x4(%eax),%edx
f010444f:	8b 00                	mov    (%eax),%eax
f0104451:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104454:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104457:	8b 45 14             	mov    0x14(%ebp),%eax
f010445a:	8d 40 08             	lea    0x8(%eax),%eax
f010445d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104460:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104463:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f0104466:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f010446b:	85 db                	test   %ebx,%ebx
f010446d:	0f 89 d6 00 00 00    	jns    f0104549 <.L25+0x2b>
				putch('-', putdat);
f0104473:	83 ec 08             	sub    $0x8,%esp
f0104476:	57                   	push   %edi
f0104477:	6a 2d                	push   $0x2d
f0104479:	ff d6                	call   *%esi
				num = -(long long) num;
f010447b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010447e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104481:	f7 d9                	neg    %ecx
f0104483:	83 d3 00             	adc    $0x0,%ebx
f0104486:	f7 db                	neg    %ebx
f0104488:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010448b:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104490:	e9 b4 00 00 00       	jmp    f0104549 <.L25+0x2b>
		return va_arg(*ap, int);
f0104495:	8b 45 14             	mov    0x14(%ebp),%eax
f0104498:	8b 00                	mov    (%eax),%eax
f010449a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010449d:	99                   	cltd   
f010449e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01044a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01044a4:	8d 40 04             	lea    0x4(%eax),%eax
f01044a7:	89 45 14             	mov    %eax,0x14(%ebp)
f01044aa:	eb b4                	jmp    f0104460 <.L29+0x3d>

f01044ac <.L23>:
	if (lflag >= 2)
f01044ac:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01044af:	8b 75 08             	mov    0x8(%ebp),%esi
f01044b2:	83 f9 01             	cmp    $0x1,%ecx
f01044b5:	7f 1b                	jg     f01044d2 <.L23+0x26>
	else if (lflag)
f01044b7:	85 c9                	test   %ecx,%ecx
f01044b9:	74 2c                	je     f01044e7 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f01044bb:	8b 45 14             	mov    0x14(%ebp),%eax
f01044be:	8b 08                	mov    (%eax),%ecx
f01044c0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01044c5:	8d 40 04             	lea    0x4(%eax),%eax
f01044c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01044cb:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f01044d0:	eb 77                	jmp    f0104549 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01044d2:	8b 45 14             	mov    0x14(%ebp),%eax
f01044d5:	8b 08                	mov    (%eax),%ecx
f01044d7:	8b 58 04             	mov    0x4(%eax),%ebx
f01044da:	8d 40 08             	lea    0x8(%eax),%eax
f01044dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01044e0:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f01044e5:	eb 62                	jmp    f0104549 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01044e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01044ea:	8b 08                	mov    (%eax),%ecx
f01044ec:	bb 00 00 00 00       	mov    $0x0,%ebx
f01044f1:	8d 40 04             	lea    0x4(%eax),%eax
f01044f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01044f7:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f01044fc:	eb 4b                	jmp    f0104549 <.L25+0x2b>

f01044fe <.L26>:
			putch('X', putdat);
f01044fe:	8b 75 08             	mov    0x8(%ebp),%esi
f0104501:	83 ec 08             	sub    $0x8,%esp
f0104504:	57                   	push   %edi
f0104505:	6a 58                	push   $0x58
f0104507:	ff d6                	call   *%esi
			putch('X', putdat);
f0104509:	83 c4 08             	add    $0x8,%esp
f010450c:	57                   	push   %edi
f010450d:	6a 58                	push   $0x58
f010450f:	ff d6                	call   *%esi
			putch('X', putdat);
f0104511:	83 c4 08             	add    $0x8,%esp
f0104514:	57                   	push   %edi
f0104515:	6a 58                	push   $0x58
f0104517:	ff d6                	call   *%esi
			break;
f0104519:	83 c4 10             	add    $0x10,%esp
f010451c:	eb 45                	jmp    f0104563 <.L25+0x45>

f010451e <.L25>:
			putch('0', putdat);
f010451e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104521:	83 ec 08             	sub    $0x8,%esp
f0104524:	57                   	push   %edi
f0104525:	6a 30                	push   $0x30
f0104527:	ff d6                	call   *%esi
			putch('x', putdat);
f0104529:	83 c4 08             	add    $0x8,%esp
f010452c:	57                   	push   %edi
f010452d:	6a 78                	push   $0x78
f010452f:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104531:	8b 45 14             	mov    0x14(%ebp),%eax
f0104534:	8b 08                	mov    (%eax),%ecx
f0104536:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f010453b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010453e:	8d 40 04             	lea    0x4(%eax),%eax
f0104541:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104544:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0104549:	83 ec 0c             	sub    $0xc,%esp
f010454c:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0104550:	50                   	push   %eax
f0104551:	ff 75 d0             	push   -0x30(%ebp)
f0104554:	52                   	push   %edx
f0104555:	53                   	push   %ebx
f0104556:	51                   	push   %ecx
f0104557:	89 fa                	mov    %edi,%edx
f0104559:	89 f0                	mov    %esi,%eax
f010455b:	e8 2c fb ff ff       	call   f010408c <printnum>
			break;
f0104560:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104563:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104566:	e9 4d fc ff ff       	jmp    f01041b8 <vprintfmt+0x34>

f010456b <.L21>:
	if (lflag >= 2)
f010456b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010456e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104571:	83 f9 01             	cmp    $0x1,%ecx
f0104574:	7f 1b                	jg     f0104591 <.L21+0x26>
	else if (lflag)
f0104576:	85 c9                	test   %ecx,%ecx
f0104578:	74 2c                	je     f01045a6 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f010457a:	8b 45 14             	mov    0x14(%ebp),%eax
f010457d:	8b 08                	mov    (%eax),%ecx
f010457f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104584:	8d 40 04             	lea    0x4(%eax),%eax
f0104587:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010458a:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f010458f:	eb b8                	jmp    f0104549 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104591:	8b 45 14             	mov    0x14(%ebp),%eax
f0104594:	8b 08                	mov    (%eax),%ecx
f0104596:	8b 58 04             	mov    0x4(%eax),%ebx
f0104599:	8d 40 08             	lea    0x8(%eax),%eax
f010459c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010459f:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f01045a4:	eb a3                	jmp    f0104549 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01045a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01045a9:	8b 08                	mov    (%eax),%ecx
f01045ab:	bb 00 00 00 00       	mov    $0x0,%ebx
f01045b0:	8d 40 04             	lea    0x4(%eax),%eax
f01045b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01045b6:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f01045bb:	eb 8c                	jmp    f0104549 <.L25+0x2b>

f01045bd <.L35>:
			putch(ch, putdat);
f01045bd:	8b 75 08             	mov    0x8(%ebp),%esi
f01045c0:	83 ec 08             	sub    $0x8,%esp
f01045c3:	57                   	push   %edi
f01045c4:	6a 25                	push   $0x25
f01045c6:	ff d6                	call   *%esi
			break;
f01045c8:	83 c4 10             	add    $0x10,%esp
f01045cb:	eb 96                	jmp    f0104563 <.L25+0x45>

f01045cd <.L20>:
			putch('%', putdat);
f01045cd:	8b 75 08             	mov    0x8(%ebp),%esi
f01045d0:	83 ec 08             	sub    $0x8,%esp
f01045d3:	57                   	push   %edi
f01045d4:	6a 25                	push   $0x25
f01045d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01045d8:	83 c4 10             	add    $0x10,%esp
f01045db:	89 d8                	mov    %ebx,%eax
f01045dd:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01045e1:	74 05                	je     f01045e8 <.L20+0x1b>
f01045e3:	83 e8 01             	sub    $0x1,%eax
f01045e6:	eb f5                	jmp    f01045dd <.L20+0x10>
f01045e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01045eb:	e9 73 ff ff ff       	jmp    f0104563 <.L25+0x45>

f01045f0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01045f0:	55                   	push   %ebp
f01045f1:	89 e5                	mov    %esp,%ebp
f01045f3:	53                   	push   %ebx
f01045f4:	83 ec 14             	sub    $0x14,%esp
f01045f7:	e8 6b bb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01045fc:	81 c3 6c a2 07 00    	add    $0x7a26c,%ebx
f0104602:	8b 45 08             	mov    0x8(%ebp),%eax
f0104605:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104608:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010460b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010460f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104612:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104619:	85 c0                	test   %eax,%eax
f010461b:	74 2b                	je     f0104648 <vsnprintf+0x58>
f010461d:	85 d2                	test   %edx,%edx
f010461f:	7e 27                	jle    f0104648 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104621:	ff 75 14             	push   0x14(%ebp)
f0104624:	ff 75 10             	push   0x10(%ebp)
f0104627:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010462a:	50                   	push   %eax
f010462b:	8d 83 e2 58 f8 ff    	lea    -0x7a71e(%ebx),%eax
f0104631:	50                   	push   %eax
f0104632:	e8 4d fb ff ff       	call   f0104184 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104637:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010463a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010463d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104640:	83 c4 10             	add    $0x10,%esp
}
f0104643:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104646:	c9                   	leave  
f0104647:	c3                   	ret    
		return -E_INVAL;
f0104648:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010464d:	eb f4                	jmp    f0104643 <vsnprintf+0x53>

f010464f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010464f:	55                   	push   %ebp
f0104650:	89 e5                	mov    %esp,%ebp
f0104652:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104655:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104658:	50                   	push   %eax
f0104659:	ff 75 10             	push   0x10(%ebp)
f010465c:	ff 75 0c             	push   0xc(%ebp)
f010465f:	ff 75 08             	push   0x8(%ebp)
f0104662:	e8 89 ff ff ff       	call   f01045f0 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104667:	c9                   	leave  
f0104668:	c3                   	ret    

f0104669 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104669:	55                   	push   %ebp
f010466a:	89 e5                	mov    %esp,%ebp
f010466c:	57                   	push   %edi
f010466d:	56                   	push   %esi
f010466e:	53                   	push   %ebx
f010466f:	83 ec 1c             	sub    $0x1c,%esp
f0104672:	e8 f0 ba ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104677:	81 c3 f1 a1 07 00    	add    $0x7a1f1,%ebx
f010467d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104680:	85 c0                	test   %eax,%eax
f0104682:	74 13                	je     f0104697 <readline+0x2e>
		cprintf("%s", prompt);
f0104684:	83 ec 08             	sub    $0x8,%esp
f0104687:	50                   	push   %eax
f0104688:	8d 83 41 71 f8 ff    	lea    -0x78ebf(%ebx),%eax
f010468e:	50                   	push   %eax
f010468f:	e8 68 f2 ff ff       	call   f01038fc <cprintf>
f0104694:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104697:	83 ec 0c             	sub    $0xc,%esp
f010469a:	6a 00                	push   $0x0
f010469c:	e8 52 c0 ff ff       	call   f01006f3 <iscons>
f01046a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01046a4:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01046a7:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f01046ac:	8d 83 98 23 00 00    	lea    0x2398(%ebx),%eax
f01046b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01046b5:	eb 45                	jmp    f01046fc <readline+0x93>
			cprintf("read error: %e\n", c);
f01046b7:	83 ec 08             	sub    $0x8,%esp
f01046ba:	50                   	push   %eax
f01046bb:	8d 83 88 7a f8 ff    	lea    -0x78578(%ebx),%eax
f01046c1:	50                   	push   %eax
f01046c2:	e8 35 f2 ff ff       	call   f01038fc <cprintf>
			return NULL;
f01046c7:	83 c4 10             	add    $0x10,%esp
f01046ca:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01046cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01046d2:	5b                   	pop    %ebx
f01046d3:	5e                   	pop    %esi
f01046d4:	5f                   	pop    %edi
f01046d5:	5d                   	pop    %ebp
f01046d6:	c3                   	ret    
			if (echoing)
f01046d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01046db:	75 05                	jne    f01046e2 <readline+0x79>
			i--;
f01046dd:	83 ef 01             	sub    $0x1,%edi
f01046e0:	eb 1a                	jmp    f01046fc <readline+0x93>
				cputchar('\b');
f01046e2:	83 ec 0c             	sub    $0xc,%esp
f01046e5:	6a 08                	push   $0x8
f01046e7:	e8 e6 bf ff ff       	call   f01006d2 <cputchar>
f01046ec:	83 c4 10             	add    $0x10,%esp
f01046ef:	eb ec                	jmp    f01046dd <readline+0x74>
			buf[i++] = c;
f01046f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01046f4:	89 f0                	mov    %esi,%eax
f01046f6:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01046f9:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01046fc:	e8 e1 bf ff ff       	call   f01006e2 <getchar>
f0104701:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104703:	85 c0                	test   %eax,%eax
f0104705:	78 b0                	js     f01046b7 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104707:	83 f8 08             	cmp    $0x8,%eax
f010470a:	0f 94 c0             	sete   %al
f010470d:	83 fe 7f             	cmp    $0x7f,%esi
f0104710:	0f 94 c2             	sete   %dl
f0104713:	08 d0                	or     %dl,%al
f0104715:	74 04                	je     f010471b <readline+0xb2>
f0104717:	85 ff                	test   %edi,%edi
f0104719:	7f bc                	jg     f01046d7 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010471b:	83 fe 1f             	cmp    $0x1f,%esi
f010471e:	7e 1c                	jle    f010473c <readline+0xd3>
f0104720:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0104726:	7f 14                	jg     f010473c <readline+0xd3>
			if (echoing)
f0104728:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010472c:	74 c3                	je     f01046f1 <readline+0x88>
				cputchar(c);
f010472e:	83 ec 0c             	sub    $0xc,%esp
f0104731:	56                   	push   %esi
f0104732:	e8 9b bf ff ff       	call   f01006d2 <cputchar>
f0104737:	83 c4 10             	add    $0x10,%esp
f010473a:	eb b5                	jmp    f01046f1 <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f010473c:	83 fe 0a             	cmp    $0xa,%esi
f010473f:	74 05                	je     f0104746 <readline+0xdd>
f0104741:	83 fe 0d             	cmp    $0xd,%esi
f0104744:	75 b6                	jne    f01046fc <readline+0x93>
			if (echoing)
f0104746:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010474a:	75 13                	jne    f010475f <readline+0xf6>
			buf[i] = 0;
f010474c:	c6 84 3b 98 23 00 00 	movb   $0x0,0x2398(%ebx,%edi,1)
f0104753:	00 
			return buf;
f0104754:	8d 83 98 23 00 00    	lea    0x2398(%ebx),%eax
f010475a:	e9 70 ff ff ff       	jmp    f01046cf <readline+0x66>
				cputchar('\n');
f010475f:	83 ec 0c             	sub    $0xc,%esp
f0104762:	6a 0a                	push   $0xa
f0104764:	e8 69 bf ff ff       	call   f01006d2 <cputchar>
f0104769:	83 c4 10             	add    $0x10,%esp
f010476c:	eb de                	jmp    f010474c <readline+0xe3>

f010476e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010476e:	55                   	push   %ebp
f010476f:	89 e5                	mov    %esp,%ebp
f0104771:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104774:	b8 00 00 00 00       	mov    $0x0,%eax
f0104779:	eb 03                	jmp    f010477e <strlen+0x10>
		n++;
f010477b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010477e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104782:	75 f7                	jne    f010477b <strlen+0xd>
	return n;
}
f0104784:	5d                   	pop    %ebp
f0104785:	c3                   	ret    

f0104786 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104786:	55                   	push   %ebp
f0104787:	89 e5                	mov    %esp,%ebp
f0104789:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010478c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010478f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104794:	eb 03                	jmp    f0104799 <strnlen+0x13>
		n++;
f0104796:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104799:	39 d0                	cmp    %edx,%eax
f010479b:	74 08                	je     f01047a5 <strnlen+0x1f>
f010479d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01047a1:	75 f3                	jne    f0104796 <strnlen+0x10>
f01047a3:	89 c2                	mov    %eax,%edx
	return n;
}
f01047a5:	89 d0                	mov    %edx,%eax
f01047a7:	5d                   	pop    %ebp
f01047a8:	c3                   	ret    

f01047a9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01047a9:	55                   	push   %ebp
f01047aa:	89 e5                	mov    %esp,%ebp
f01047ac:	53                   	push   %ebx
f01047ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01047b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01047b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01047b8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01047bc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01047bf:	83 c0 01             	add    $0x1,%eax
f01047c2:	84 d2                	test   %dl,%dl
f01047c4:	75 f2                	jne    f01047b8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01047c6:	89 c8                	mov    %ecx,%eax
f01047c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01047cb:	c9                   	leave  
f01047cc:	c3                   	ret    

f01047cd <strcat>:

char *
strcat(char *dst, const char *src)
{
f01047cd:	55                   	push   %ebp
f01047ce:	89 e5                	mov    %esp,%ebp
f01047d0:	53                   	push   %ebx
f01047d1:	83 ec 10             	sub    $0x10,%esp
f01047d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01047d7:	53                   	push   %ebx
f01047d8:	e8 91 ff ff ff       	call   f010476e <strlen>
f01047dd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01047e0:	ff 75 0c             	push   0xc(%ebp)
f01047e3:	01 d8                	add    %ebx,%eax
f01047e5:	50                   	push   %eax
f01047e6:	e8 be ff ff ff       	call   f01047a9 <strcpy>
	return dst;
}
f01047eb:	89 d8                	mov    %ebx,%eax
f01047ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01047f0:	c9                   	leave  
f01047f1:	c3                   	ret    

f01047f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01047f2:	55                   	push   %ebp
f01047f3:	89 e5                	mov    %esp,%ebp
f01047f5:	56                   	push   %esi
f01047f6:	53                   	push   %ebx
f01047f7:	8b 75 08             	mov    0x8(%ebp),%esi
f01047fa:	8b 55 0c             	mov    0xc(%ebp),%edx
f01047fd:	89 f3                	mov    %esi,%ebx
f01047ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104802:	89 f0                	mov    %esi,%eax
f0104804:	eb 0f                	jmp    f0104815 <strncpy+0x23>
		*dst++ = *src;
f0104806:	83 c0 01             	add    $0x1,%eax
f0104809:	0f b6 0a             	movzbl (%edx),%ecx
f010480c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010480f:	80 f9 01             	cmp    $0x1,%cl
f0104812:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0104815:	39 d8                	cmp    %ebx,%eax
f0104817:	75 ed                	jne    f0104806 <strncpy+0x14>
	}
	return ret;
}
f0104819:	89 f0                	mov    %esi,%eax
f010481b:	5b                   	pop    %ebx
f010481c:	5e                   	pop    %esi
f010481d:	5d                   	pop    %ebp
f010481e:	c3                   	ret    

f010481f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010481f:	55                   	push   %ebp
f0104820:	89 e5                	mov    %esp,%ebp
f0104822:	56                   	push   %esi
f0104823:	53                   	push   %ebx
f0104824:	8b 75 08             	mov    0x8(%ebp),%esi
f0104827:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010482a:	8b 55 10             	mov    0x10(%ebp),%edx
f010482d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010482f:	85 d2                	test   %edx,%edx
f0104831:	74 21                	je     f0104854 <strlcpy+0x35>
f0104833:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104837:	89 f2                	mov    %esi,%edx
f0104839:	eb 09                	jmp    f0104844 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010483b:	83 c1 01             	add    $0x1,%ecx
f010483e:	83 c2 01             	add    $0x1,%edx
f0104841:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0104844:	39 c2                	cmp    %eax,%edx
f0104846:	74 09                	je     f0104851 <strlcpy+0x32>
f0104848:	0f b6 19             	movzbl (%ecx),%ebx
f010484b:	84 db                	test   %bl,%bl
f010484d:	75 ec                	jne    f010483b <strlcpy+0x1c>
f010484f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0104851:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104854:	29 f0                	sub    %esi,%eax
}
f0104856:	5b                   	pop    %ebx
f0104857:	5e                   	pop    %esi
f0104858:	5d                   	pop    %ebp
f0104859:	c3                   	ret    

f010485a <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010485a:	55                   	push   %ebp
f010485b:	89 e5                	mov    %esp,%ebp
f010485d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104860:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104863:	eb 06                	jmp    f010486b <strcmp+0x11>
		p++, q++;
f0104865:	83 c1 01             	add    $0x1,%ecx
f0104868:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010486b:	0f b6 01             	movzbl (%ecx),%eax
f010486e:	84 c0                	test   %al,%al
f0104870:	74 04                	je     f0104876 <strcmp+0x1c>
f0104872:	3a 02                	cmp    (%edx),%al
f0104874:	74 ef                	je     f0104865 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104876:	0f b6 c0             	movzbl %al,%eax
f0104879:	0f b6 12             	movzbl (%edx),%edx
f010487c:	29 d0                	sub    %edx,%eax
}
f010487e:	5d                   	pop    %ebp
f010487f:	c3                   	ret    

f0104880 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104880:	55                   	push   %ebp
f0104881:	89 e5                	mov    %esp,%ebp
f0104883:	53                   	push   %ebx
f0104884:	8b 45 08             	mov    0x8(%ebp),%eax
f0104887:	8b 55 0c             	mov    0xc(%ebp),%edx
f010488a:	89 c3                	mov    %eax,%ebx
f010488c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010488f:	eb 06                	jmp    f0104897 <strncmp+0x17>
		n--, p++, q++;
f0104891:	83 c0 01             	add    $0x1,%eax
f0104894:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104897:	39 d8                	cmp    %ebx,%eax
f0104899:	74 18                	je     f01048b3 <strncmp+0x33>
f010489b:	0f b6 08             	movzbl (%eax),%ecx
f010489e:	84 c9                	test   %cl,%cl
f01048a0:	74 04                	je     f01048a6 <strncmp+0x26>
f01048a2:	3a 0a                	cmp    (%edx),%cl
f01048a4:	74 eb                	je     f0104891 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01048a6:	0f b6 00             	movzbl (%eax),%eax
f01048a9:	0f b6 12             	movzbl (%edx),%edx
f01048ac:	29 d0                	sub    %edx,%eax
}
f01048ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01048b1:	c9                   	leave  
f01048b2:	c3                   	ret    
		return 0;
f01048b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01048b8:	eb f4                	jmp    f01048ae <strncmp+0x2e>

f01048ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01048ba:	55                   	push   %ebp
f01048bb:	89 e5                	mov    %esp,%ebp
f01048bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01048c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01048c4:	eb 03                	jmp    f01048c9 <strchr+0xf>
f01048c6:	83 c0 01             	add    $0x1,%eax
f01048c9:	0f b6 10             	movzbl (%eax),%edx
f01048cc:	84 d2                	test   %dl,%dl
f01048ce:	74 06                	je     f01048d6 <strchr+0x1c>
		if (*s == c)
f01048d0:	38 ca                	cmp    %cl,%dl
f01048d2:	75 f2                	jne    f01048c6 <strchr+0xc>
f01048d4:	eb 05                	jmp    f01048db <strchr+0x21>
			return (char *) s;
	return 0;
f01048d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01048db:	5d                   	pop    %ebp
f01048dc:	c3                   	ret    

f01048dd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01048dd:	55                   	push   %ebp
f01048de:	89 e5                	mov    %esp,%ebp
f01048e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01048e3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01048e7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01048ea:	38 ca                	cmp    %cl,%dl
f01048ec:	74 09                	je     f01048f7 <strfind+0x1a>
f01048ee:	84 d2                	test   %dl,%dl
f01048f0:	74 05                	je     f01048f7 <strfind+0x1a>
	for (; *s; s++)
f01048f2:	83 c0 01             	add    $0x1,%eax
f01048f5:	eb f0                	jmp    f01048e7 <strfind+0xa>
			break;
	return (char *) s;
}
f01048f7:	5d                   	pop    %ebp
f01048f8:	c3                   	ret    

f01048f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01048f9:	55                   	push   %ebp
f01048fa:	89 e5                	mov    %esp,%ebp
f01048fc:	57                   	push   %edi
f01048fd:	56                   	push   %esi
f01048fe:	53                   	push   %ebx
f01048ff:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104902:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104905:	85 c9                	test   %ecx,%ecx
f0104907:	74 2f                	je     f0104938 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104909:	89 f8                	mov    %edi,%eax
f010490b:	09 c8                	or     %ecx,%eax
f010490d:	a8 03                	test   $0x3,%al
f010490f:	75 21                	jne    f0104932 <memset+0x39>
		c &= 0xFF;
f0104911:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104915:	89 d0                	mov    %edx,%eax
f0104917:	c1 e0 08             	shl    $0x8,%eax
f010491a:	89 d3                	mov    %edx,%ebx
f010491c:	c1 e3 18             	shl    $0x18,%ebx
f010491f:	89 d6                	mov    %edx,%esi
f0104921:	c1 e6 10             	shl    $0x10,%esi
f0104924:	09 f3                	or     %esi,%ebx
f0104926:	09 da                	or     %ebx,%edx
f0104928:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010492a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010492d:	fc                   	cld    
f010492e:	f3 ab                	rep stos %eax,%es:(%edi)
f0104930:	eb 06                	jmp    f0104938 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104932:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104935:	fc                   	cld    
f0104936:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104938:	89 f8                	mov    %edi,%eax
f010493a:	5b                   	pop    %ebx
f010493b:	5e                   	pop    %esi
f010493c:	5f                   	pop    %edi
f010493d:	5d                   	pop    %ebp
f010493e:	c3                   	ret    

f010493f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010493f:	55                   	push   %ebp
f0104940:	89 e5                	mov    %esp,%ebp
f0104942:	57                   	push   %edi
f0104943:	56                   	push   %esi
f0104944:	8b 45 08             	mov    0x8(%ebp),%eax
f0104947:	8b 75 0c             	mov    0xc(%ebp),%esi
f010494a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010494d:	39 c6                	cmp    %eax,%esi
f010494f:	73 32                	jae    f0104983 <memmove+0x44>
f0104951:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104954:	39 c2                	cmp    %eax,%edx
f0104956:	76 2b                	jbe    f0104983 <memmove+0x44>
		s += n;
		d += n;
f0104958:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010495b:	89 d6                	mov    %edx,%esi
f010495d:	09 fe                	or     %edi,%esi
f010495f:	09 ce                	or     %ecx,%esi
f0104961:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104967:	75 0e                	jne    f0104977 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104969:	83 ef 04             	sub    $0x4,%edi
f010496c:	8d 72 fc             	lea    -0x4(%edx),%esi
f010496f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104972:	fd                   	std    
f0104973:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104975:	eb 09                	jmp    f0104980 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104977:	83 ef 01             	sub    $0x1,%edi
f010497a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010497d:	fd                   	std    
f010497e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104980:	fc                   	cld    
f0104981:	eb 1a                	jmp    f010499d <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104983:	89 f2                	mov    %esi,%edx
f0104985:	09 c2                	or     %eax,%edx
f0104987:	09 ca                	or     %ecx,%edx
f0104989:	f6 c2 03             	test   $0x3,%dl
f010498c:	75 0a                	jne    f0104998 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010498e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104991:	89 c7                	mov    %eax,%edi
f0104993:	fc                   	cld    
f0104994:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104996:	eb 05                	jmp    f010499d <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0104998:	89 c7                	mov    %eax,%edi
f010499a:	fc                   	cld    
f010499b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010499d:	5e                   	pop    %esi
f010499e:	5f                   	pop    %edi
f010499f:	5d                   	pop    %ebp
f01049a0:	c3                   	ret    

f01049a1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01049a1:	55                   	push   %ebp
f01049a2:	89 e5                	mov    %esp,%ebp
f01049a4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01049a7:	ff 75 10             	push   0x10(%ebp)
f01049aa:	ff 75 0c             	push   0xc(%ebp)
f01049ad:	ff 75 08             	push   0x8(%ebp)
f01049b0:	e8 8a ff ff ff       	call   f010493f <memmove>
}
f01049b5:	c9                   	leave  
f01049b6:	c3                   	ret    

f01049b7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01049b7:	55                   	push   %ebp
f01049b8:	89 e5                	mov    %esp,%ebp
f01049ba:	56                   	push   %esi
f01049bb:	53                   	push   %ebx
f01049bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01049bf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01049c2:	89 c6                	mov    %eax,%esi
f01049c4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01049c7:	eb 06                	jmp    f01049cf <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01049c9:	83 c0 01             	add    $0x1,%eax
f01049cc:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f01049cf:	39 f0                	cmp    %esi,%eax
f01049d1:	74 14                	je     f01049e7 <memcmp+0x30>
		if (*s1 != *s2)
f01049d3:	0f b6 08             	movzbl (%eax),%ecx
f01049d6:	0f b6 1a             	movzbl (%edx),%ebx
f01049d9:	38 d9                	cmp    %bl,%cl
f01049db:	74 ec                	je     f01049c9 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f01049dd:	0f b6 c1             	movzbl %cl,%eax
f01049e0:	0f b6 db             	movzbl %bl,%ebx
f01049e3:	29 d8                	sub    %ebx,%eax
f01049e5:	eb 05                	jmp    f01049ec <memcmp+0x35>
	}

	return 0;
f01049e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01049ec:	5b                   	pop    %ebx
f01049ed:	5e                   	pop    %esi
f01049ee:	5d                   	pop    %ebp
f01049ef:	c3                   	ret    

f01049f0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01049f0:	55                   	push   %ebp
f01049f1:	89 e5                	mov    %esp,%ebp
f01049f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01049f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01049f9:	89 c2                	mov    %eax,%edx
f01049fb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01049fe:	eb 03                	jmp    f0104a03 <memfind+0x13>
f0104a00:	83 c0 01             	add    $0x1,%eax
f0104a03:	39 d0                	cmp    %edx,%eax
f0104a05:	73 04                	jae    f0104a0b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104a07:	38 08                	cmp    %cl,(%eax)
f0104a09:	75 f5                	jne    f0104a00 <memfind+0x10>
			break;
	return (void *) s;
}
f0104a0b:	5d                   	pop    %ebp
f0104a0c:	c3                   	ret    

f0104a0d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104a0d:	55                   	push   %ebp
f0104a0e:	89 e5                	mov    %esp,%ebp
f0104a10:	57                   	push   %edi
f0104a11:	56                   	push   %esi
f0104a12:	53                   	push   %ebx
f0104a13:	8b 55 08             	mov    0x8(%ebp),%edx
f0104a16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104a19:	eb 03                	jmp    f0104a1e <strtol+0x11>
		s++;
f0104a1b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0104a1e:	0f b6 02             	movzbl (%edx),%eax
f0104a21:	3c 20                	cmp    $0x20,%al
f0104a23:	74 f6                	je     f0104a1b <strtol+0xe>
f0104a25:	3c 09                	cmp    $0x9,%al
f0104a27:	74 f2                	je     f0104a1b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0104a29:	3c 2b                	cmp    $0x2b,%al
f0104a2b:	74 2a                	je     f0104a57 <strtol+0x4a>
	int neg = 0;
f0104a2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0104a32:	3c 2d                	cmp    $0x2d,%al
f0104a34:	74 2b                	je     f0104a61 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104a36:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104a3c:	75 0f                	jne    f0104a4d <strtol+0x40>
f0104a3e:	80 3a 30             	cmpb   $0x30,(%edx)
f0104a41:	74 28                	je     f0104a6b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104a43:	85 db                	test   %ebx,%ebx
f0104a45:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104a4a:	0f 44 d8             	cmove  %eax,%ebx
f0104a4d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104a52:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104a55:	eb 46                	jmp    f0104a9d <strtol+0x90>
		s++;
f0104a57:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0104a5a:	bf 00 00 00 00       	mov    $0x0,%edi
f0104a5f:	eb d5                	jmp    f0104a36 <strtol+0x29>
		s++, neg = 1;
f0104a61:	83 c2 01             	add    $0x1,%edx
f0104a64:	bf 01 00 00 00       	mov    $0x1,%edi
f0104a69:	eb cb                	jmp    f0104a36 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104a6b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104a6f:	74 0e                	je     f0104a7f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0104a71:	85 db                	test   %ebx,%ebx
f0104a73:	75 d8                	jne    f0104a4d <strtol+0x40>
		s++, base = 8;
f0104a75:	83 c2 01             	add    $0x1,%edx
f0104a78:	bb 08 00 00 00       	mov    $0x8,%ebx
f0104a7d:	eb ce                	jmp    f0104a4d <strtol+0x40>
		s += 2, base = 16;
f0104a7f:	83 c2 02             	add    $0x2,%edx
f0104a82:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104a87:	eb c4                	jmp    f0104a4d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0104a89:	0f be c0             	movsbl %al,%eax
f0104a8c:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104a8f:	3b 45 10             	cmp    0x10(%ebp),%eax
f0104a92:	7d 3a                	jge    f0104ace <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0104a94:	83 c2 01             	add    $0x1,%edx
f0104a97:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0104a9b:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0104a9d:	0f b6 02             	movzbl (%edx),%eax
f0104aa0:	8d 70 d0             	lea    -0x30(%eax),%esi
f0104aa3:	89 f3                	mov    %esi,%ebx
f0104aa5:	80 fb 09             	cmp    $0x9,%bl
f0104aa8:	76 df                	jbe    f0104a89 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0104aaa:	8d 70 9f             	lea    -0x61(%eax),%esi
f0104aad:	89 f3                	mov    %esi,%ebx
f0104aaf:	80 fb 19             	cmp    $0x19,%bl
f0104ab2:	77 08                	ja     f0104abc <strtol+0xaf>
			dig = *s - 'a' + 10;
f0104ab4:	0f be c0             	movsbl %al,%eax
f0104ab7:	83 e8 57             	sub    $0x57,%eax
f0104aba:	eb d3                	jmp    f0104a8f <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0104abc:	8d 70 bf             	lea    -0x41(%eax),%esi
f0104abf:	89 f3                	mov    %esi,%ebx
f0104ac1:	80 fb 19             	cmp    $0x19,%bl
f0104ac4:	77 08                	ja     f0104ace <strtol+0xc1>
			dig = *s - 'A' + 10;
f0104ac6:	0f be c0             	movsbl %al,%eax
f0104ac9:	83 e8 37             	sub    $0x37,%eax
f0104acc:	eb c1                	jmp    f0104a8f <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104ace:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104ad2:	74 05                	je     f0104ad9 <strtol+0xcc>
		*endptr = (char *) s;
f0104ad4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ad7:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0104ad9:	89 c8                	mov    %ecx,%eax
f0104adb:	f7 d8                	neg    %eax
f0104add:	85 ff                	test   %edi,%edi
f0104adf:	0f 45 c8             	cmovne %eax,%ecx
}
f0104ae2:	89 c8                	mov    %ecx,%eax
f0104ae4:	5b                   	pop    %ebx
f0104ae5:	5e                   	pop    %esi
f0104ae6:	5f                   	pop    %edi
f0104ae7:	5d                   	pop    %ebp
f0104ae8:	c3                   	ret    
f0104ae9:	66 90                	xchg   %ax,%ax
f0104aeb:	66 90                	xchg   %ax,%ax
f0104aed:	66 90                	xchg   %ax,%ax
f0104aef:	90                   	nop

f0104af0 <__udivdi3>:
f0104af0:	f3 0f 1e fb          	endbr32 
f0104af4:	55                   	push   %ebp
f0104af5:	57                   	push   %edi
f0104af6:	56                   	push   %esi
f0104af7:	53                   	push   %ebx
f0104af8:	83 ec 1c             	sub    $0x1c,%esp
f0104afb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0104aff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0104b03:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104b07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0104b0b:	85 c0                	test   %eax,%eax
f0104b0d:	75 19                	jne    f0104b28 <__udivdi3+0x38>
f0104b0f:	39 f3                	cmp    %esi,%ebx
f0104b11:	76 4d                	jbe    f0104b60 <__udivdi3+0x70>
f0104b13:	31 ff                	xor    %edi,%edi
f0104b15:	89 e8                	mov    %ebp,%eax
f0104b17:	89 f2                	mov    %esi,%edx
f0104b19:	f7 f3                	div    %ebx
f0104b1b:	89 fa                	mov    %edi,%edx
f0104b1d:	83 c4 1c             	add    $0x1c,%esp
f0104b20:	5b                   	pop    %ebx
f0104b21:	5e                   	pop    %esi
f0104b22:	5f                   	pop    %edi
f0104b23:	5d                   	pop    %ebp
f0104b24:	c3                   	ret    
f0104b25:	8d 76 00             	lea    0x0(%esi),%esi
f0104b28:	39 f0                	cmp    %esi,%eax
f0104b2a:	76 14                	jbe    f0104b40 <__udivdi3+0x50>
f0104b2c:	31 ff                	xor    %edi,%edi
f0104b2e:	31 c0                	xor    %eax,%eax
f0104b30:	89 fa                	mov    %edi,%edx
f0104b32:	83 c4 1c             	add    $0x1c,%esp
f0104b35:	5b                   	pop    %ebx
f0104b36:	5e                   	pop    %esi
f0104b37:	5f                   	pop    %edi
f0104b38:	5d                   	pop    %ebp
f0104b39:	c3                   	ret    
f0104b3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104b40:	0f bd f8             	bsr    %eax,%edi
f0104b43:	83 f7 1f             	xor    $0x1f,%edi
f0104b46:	75 48                	jne    f0104b90 <__udivdi3+0xa0>
f0104b48:	39 f0                	cmp    %esi,%eax
f0104b4a:	72 06                	jb     f0104b52 <__udivdi3+0x62>
f0104b4c:	31 c0                	xor    %eax,%eax
f0104b4e:	39 eb                	cmp    %ebp,%ebx
f0104b50:	77 de                	ja     f0104b30 <__udivdi3+0x40>
f0104b52:	b8 01 00 00 00       	mov    $0x1,%eax
f0104b57:	eb d7                	jmp    f0104b30 <__udivdi3+0x40>
f0104b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104b60:	89 d9                	mov    %ebx,%ecx
f0104b62:	85 db                	test   %ebx,%ebx
f0104b64:	75 0b                	jne    f0104b71 <__udivdi3+0x81>
f0104b66:	b8 01 00 00 00       	mov    $0x1,%eax
f0104b6b:	31 d2                	xor    %edx,%edx
f0104b6d:	f7 f3                	div    %ebx
f0104b6f:	89 c1                	mov    %eax,%ecx
f0104b71:	31 d2                	xor    %edx,%edx
f0104b73:	89 f0                	mov    %esi,%eax
f0104b75:	f7 f1                	div    %ecx
f0104b77:	89 c6                	mov    %eax,%esi
f0104b79:	89 e8                	mov    %ebp,%eax
f0104b7b:	89 f7                	mov    %esi,%edi
f0104b7d:	f7 f1                	div    %ecx
f0104b7f:	89 fa                	mov    %edi,%edx
f0104b81:	83 c4 1c             	add    $0x1c,%esp
f0104b84:	5b                   	pop    %ebx
f0104b85:	5e                   	pop    %esi
f0104b86:	5f                   	pop    %edi
f0104b87:	5d                   	pop    %ebp
f0104b88:	c3                   	ret    
f0104b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104b90:	89 f9                	mov    %edi,%ecx
f0104b92:	ba 20 00 00 00       	mov    $0x20,%edx
f0104b97:	29 fa                	sub    %edi,%edx
f0104b99:	d3 e0                	shl    %cl,%eax
f0104b9b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b9f:	89 d1                	mov    %edx,%ecx
f0104ba1:	89 d8                	mov    %ebx,%eax
f0104ba3:	d3 e8                	shr    %cl,%eax
f0104ba5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104ba9:	09 c1                	or     %eax,%ecx
f0104bab:	89 f0                	mov    %esi,%eax
f0104bad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104bb1:	89 f9                	mov    %edi,%ecx
f0104bb3:	d3 e3                	shl    %cl,%ebx
f0104bb5:	89 d1                	mov    %edx,%ecx
f0104bb7:	d3 e8                	shr    %cl,%eax
f0104bb9:	89 f9                	mov    %edi,%ecx
f0104bbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104bbf:	89 eb                	mov    %ebp,%ebx
f0104bc1:	d3 e6                	shl    %cl,%esi
f0104bc3:	89 d1                	mov    %edx,%ecx
f0104bc5:	d3 eb                	shr    %cl,%ebx
f0104bc7:	09 f3                	or     %esi,%ebx
f0104bc9:	89 c6                	mov    %eax,%esi
f0104bcb:	89 f2                	mov    %esi,%edx
f0104bcd:	89 d8                	mov    %ebx,%eax
f0104bcf:	f7 74 24 08          	divl   0x8(%esp)
f0104bd3:	89 d6                	mov    %edx,%esi
f0104bd5:	89 c3                	mov    %eax,%ebx
f0104bd7:	f7 64 24 0c          	mull   0xc(%esp)
f0104bdb:	39 d6                	cmp    %edx,%esi
f0104bdd:	72 19                	jb     f0104bf8 <__udivdi3+0x108>
f0104bdf:	89 f9                	mov    %edi,%ecx
f0104be1:	d3 e5                	shl    %cl,%ebp
f0104be3:	39 c5                	cmp    %eax,%ebp
f0104be5:	73 04                	jae    f0104beb <__udivdi3+0xfb>
f0104be7:	39 d6                	cmp    %edx,%esi
f0104be9:	74 0d                	je     f0104bf8 <__udivdi3+0x108>
f0104beb:	89 d8                	mov    %ebx,%eax
f0104bed:	31 ff                	xor    %edi,%edi
f0104bef:	e9 3c ff ff ff       	jmp    f0104b30 <__udivdi3+0x40>
f0104bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104bf8:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0104bfb:	31 ff                	xor    %edi,%edi
f0104bfd:	e9 2e ff ff ff       	jmp    f0104b30 <__udivdi3+0x40>
f0104c02:	66 90                	xchg   %ax,%ax
f0104c04:	66 90                	xchg   %ax,%ax
f0104c06:	66 90                	xchg   %ax,%ax
f0104c08:	66 90                	xchg   %ax,%ax
f0104c0a:	66 90                	xchg   %ax,%ax
f0104c0c:	66 90                	xchg   %ax,%ax
f0104c0e:	66 90                	xchg   %ax,%ax

f0104c10 <__umoddi3>:
f0104c10:	f3 0f 1e fb          	endbr32 
f0104c14:	55                   	push   %ebp
f0104c15:	57                   	push   %edi
f0104c16:	56                   	push   %esi
f0104c17:	53                   	push   %ebx
f0104c18:	83 ec 1c             	sub    $0x1c,%esp
f0104c1b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0104c1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0104c23:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0104c27:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0104c2b:	89 f0                	mov    %esi,%eax
f0104c2d:	89 da                	mov    %ebx,%edx
f0104c2f:	85 ff                	test   %edi,%edi
f0104c31:	75 15                	jne    f0104c48 <__umoddi3+0x38>
f0104c33:	39 dd                	cmp    %ebx,%ebp
f0104c35:	76 39                	jbe    f0104c70 <__umoddi3+0x60>
f0104c37:	f7 f5                	div    %ebp
f0104c39:	89 d0                	mov    %edx,%eax
f0104c3b:	31 d2                	xor    %edx,%edx
f0104c3d:	83 c4 1c             	add    $0x1c,%esp
f0104c40:	5b                   	pop    %ebx
f0104c41:	5e                   	pop    %esi
f0104c42:	5f                   	pop    %edi
f0104c43:	5d                   	pop    %ebp
f0104c44:	c3                   	ret    
f0104c45:	8d 76 00             	lea    0x0(%esi),%esi
f0104c48:	39 df                	cmp    %ebx,%edi
f0104c4a:	77 f1                	ja     f0104c3d <__umoddi3+0x2d>
f0104c4c:	0f bd cf             	bsr    %edi,%ecx
f0104c4f:	83 f1 1f             	xor    $0x1f,%ecx
f0104c52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104c56:	75 40                	jne    f0104c98 <__umoddi3+0x88>
f0104c58:	39 df                	cmp    %ebx,%edi
f0104c5a:	72 04                	jb     f0104c60 <__umoddi3+0x50>
f0104c5c:	39 f5                	cmp    %esi,%ebp
f0104c5e:	77 dd                	ja     f0104c3d <__umoddi3+0x2d>
f0104c60:	89 da                	mov    %ebx,%edx
f0104c62:	89 f0                	mov    %esi,%eax
f0104c64:	29 e8                	sub    %ebp,%eax
f0104c66:	19 fa                	sbb    %edi,%edx
f0104c68:	eb d3                	jmp    f0104c3d <__umoddi3+0x2d>
f0104c6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104c70:	89 e9                	mov    %ebp,%ecx
f0104c72:	85 ed                	test   %ebp,%ebp
f0104c74:	75 0b                	jne    f0104c81 <__umoddi3+0x71>
f0104c76:	b8 01 00 00 00       	mov    $0x1,%eax
f0104c7b:	31 d2                	xor    %edx,%edx
f0104c7d:	f7 f5                	div    %ebp
f0104c7f:	89 c1                	mov    %eax,%ecx
f0104c81:	89 d8                	mov    %ebx,%eax
f0104c83:	31 d2                	xor    %edx,%edx
f0104c85:	f7 f1                	div    %ecx
f0104c87:	89 f0                	mov    %esi,%eax
f0104c89:	f7 f1                	div    %ecx
f0104c8b:	89 d0                	mov    %edx,%eax
f0104c8d:	31 d2                	xor    %edx,%edx
f0104c8f:	eb ac                	jmp    f0104c3d <__umoddi3+0x2d>
f0104c91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104c98:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104c9c:	ba 20 00 00 00       	mov    $0x20,%edx
f0104ca1:	29 c2                	sub    %eax,%edx
f0104ca3:	89 c1                	mov    %eax,%ecx
f0104ca5:	89 e8                	mov    %ebp,%eax
f0104ca7:	d3 e7                	shl    %cl,%edi
f0104ca9:	89 d1                	mov    %edx,%ecx
f0104cab:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104caf:	d3 e8                	shr    %cl,%eax
f0104cb1:	89 c1                	mov    %eax,%ecx
f0104cb3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104cb7:	09 f9                	or     %edi,%ecx
f0104cb9:	89 df                	mov    %ebx,%edi
f0104cbb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104cbf:	89 c1                	mov    %eax,%ecx
f0104cc1:	d3 e5                	shl    %cl,%ebp
f0104cc3:	89 d1                	mov    %edx,%ecx
f0104cc5:	d3 ef                	shr    %cl,%edi
f0104cc7:	89 c1                	mov    %eax,%ecx
f0104cc9:	89 f0                	mov    %esi,%eax
f0104ccb:	d3 e3                	shl    %cl,%ebx
f0104ccd:	89 d1                	mov    %edx,%ecx
f0104ccf:	89 fa                	mov    %edi,%edx
f0104cd1:	d3 e8                	shr    %cl,%eax
f0104cd3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104cd8:	09 d8                	or     %ebx,%eax
f0104cda:	f7 74 24 08          	divl   0x8(%esp)
f0104cde:	89 d3                	mov    %edx,%ebx
f0104ce0:	d3 e6                	shl    %cl,%esi
f0104ce2:	f7 e5                	mul    %ebp
f0104ce4:	89 c7                	mov    %eax,%edi
f0104ce6:	89 d1                	mov    %edx,%ecx
f0104ce8:	39 d3                	cmp    %edx,%ebx
f0104cea:	72 06                	jb     f0104cf2 <__umoddi3+0xe2>
f0104cec:	75 0e                	jne    f0104cfc <__umoddi3+0xec>
f0104cee:	39 c6                	cmp    %eax,%esi
f0104cf0:	73 0a                	jae    f0104cfc <__umoddi3+0xec>
f0104cf2:	29 e8                	sub    %ebp,%eax
f0104cf4:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0104cf8:	89 d1                	mov    %edx,%ecx
f0104cfa:	89 c7                	mov    %eax,%edi
f0104cfc:	89 f5                	mov    %esi,%ebp
f0104cfe:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104d02:	29 fd                	sub    %edi,%ebp
f0104d04:	19 cb                	sbb    %ecx,%ebx
f0104d06:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0104d0b:	89 d8                	mov    %ebx,%eax
f0104d0d:	d3 e0                	shl    %cl,%eax
f0104d0f:	89 f1                	mov    %esi,%ecx
f0104d11:	d3 ed                	shr    %cl,%ebp
f0104d13:	d3 eb                	shr    %cl,%ebx
f0104d15:	09 e8                	or     %ebp,%eax
f0104d17:	89 da                	mov    %ebx,%edx
f0104d19:	83 c4 1c             	add    $0x1c,%esp
f0104d1c:	5b                   	pop    %ebx
f0104d1d:	5e                   	pop    %esi
f0104d1e:	5f                   	pop    %edi
f0104d1f:	5d                   	pop    %ebp
f0104d20:	c3                   	ret    
