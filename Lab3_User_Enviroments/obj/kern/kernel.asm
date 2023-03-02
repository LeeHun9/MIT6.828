
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
f0100015:	b8 00 00 18 00       	mov    $0x180000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

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
f010004c:	81 c3 1c f8 07 00    	add    $0x7f81c,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 00 20 18 f0    	mov    $0xf0182000,%eax
f0100058:	c7 c2 e0 10 18 f0    	mov    $0xf01810e0,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 ac 4e 00 00       	call   f0104f15 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 4f 05 00 00       	call   f01005bd <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 f8 5a f8 ff    	lea    -0x7a508(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 64 39 00 00       	call   f01039e6 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 16 12 00 00       	call   f010129d <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 36 32 00 00       	call   f01032c2 <env_init>
	trap_init();
f010008c:	e8 08 3a 00 00       	call   f0103a99 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100091:	83 c4 08             	add    $0x8,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 f4 ff ff ff    	push   -0xc(%ebx)
f010009c:	e8 63 34 00 00       	call   f0103504 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a1:	83 c4 04             	add    $0x4,%esp
f01000a4:	c7 c0 58 13 18 f0    	mov    $0xf0181358,%eax
f01000aa:	ff 30                	push   (%eax)
f01000ac:	e8 39 38 00 00       	call   f01038ea <env_run>

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
f01000bb:	81 c3 ad f7 07 00    	add    $0x7f7ad,%ebx
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
f01000f0:	8d 83 13 5b f8 ff    	lea    -0x7a4ed(%ebx),%eax
f01000f6:	50                   	push   %eax
f01000f7:	e8 ea 38 00 00       	call   f01039e6 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	56                   	push   %esi
f0100100:	ff 75 10             	push   0x10(%ebp)
f0100103:	e8 a7 38 00 00       	call   f01039af <vcprintf>
	cprintf("\n");
f0100108:	8d 83 12 6a f8 ff    	lea    -0x795ee(%ebx),%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 d0 38 00 00       	call   f01039e6 <cprintf>
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
f0100125:	81 c3 43 f7 07 00    	add    $0x7f743,%ebx
	va_list ap;

	va_start(ap, fmt);
f010012b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010012e:	83 ec 04             	sub    $0x4,%esp
f0100131:	ff 75 0c             	push   0xc(%ebp)
f0100134:	ff 75 08             	push   0x8(%ebp)
f0100137:	8d 83 2b 5b f8 ff    	lea    -0x7a4d5(%ebx),%eax
f010013d:	50                   	push   %eax
f010013e:	e8 a3 38 00 00       	call   f01039e6 <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	56                   	push   %esi
f0100147:	ff 75 10             	push   0x10(%ebp)
f010014a:	e8 60 38 00 00       	call   f01039af <vcprintf>
	cprintf("\n");
f010014f:	8d 83 12 6a f8 ff    	lea    -0x795ee(%ebx),%eax
f0100155:	89 04 24             	mov    %eax,(%esp)
f0100158:	e8 89 38 00 00       	call   f01039e6 <cprintf>
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
f0100193:	81 c6 d5 f6 07 00    	add    $0x7f6d5,%esi
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
f01001f3:	81 c3 75 f6 07 00    	add    $0x7f675,%ebx
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
f010023b:	0f b6 84 13 78 5c f8 	movzbl -0x7a388(%ebx,%edx,1),%eax
f0100242:	ff 
f0100243:	0b 83 98 18 00 00    	or     0x1898(%ebx),%eax
	shift ^= togglecode[data];
f0100249:	0f b6 8c 13 78 5b f8 	movzbl -0x7a488(%ebx,%edx,1),%ecx
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
f01002a6:	0f b6 84 13 78 5c f8 	movzbl -0x7a388(%ebx,%edx,1),%eax
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
f01002e2:	8d 83 45 5b f8 ff    	lea    -0x7a4bb(%ebx),%eax
f01002e8:	50                   	push   %eax
f01002e9:	e8 f8 36 00 00       	call   f01039e6 <cprintf>
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
f010031d:	81 c3 4b f5 07 00    	add    $0x7f54b,%ebx
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
f01004f2:	e8 64 4a 00 00       	call   f0104f5b <memmove>
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
f010052a:	05 3e f3 07 00       	add    $0x7f33e,%eax
	if (serial_exists)
f010052f:	80 b8 cc 1a 00 00 00 	cmpb   $0x0,0x1acc(%eax)
f0100536:	75 01                	jne    f0100539 <serial_intr+0x14>
f0100538:	c3                   	ret    
{
f0100539:	55                   	push   %ebp
f010053a:	89 e5                	mov    %esp,%ebp
f010053c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010053f:	8d 80 03 09 f8 ff    	lea    -0x7f6fd(%eax),%eax
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
f0100557:	05 11 f3 07 00       	add    $0x7f311,%eax
	cons_intr(kbd_proc_data);
f010055c:	8d 80 81 09 f8 ff    	lea    -0x7f67f(%eax),%eax
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
f0100575:	81 c3 f3 f2 07 00    	add    $0x7f2f3,%ebx
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
f01005cb:	81 c3 9d f2 07 00    	add    $0x7f29d,%ebx
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
f01006c1:	8d 83 51 5b f8 ff    	lea    -0x7a4af(%ebx),%eax
f01006c7:	50                   	push   %eax
f01006c8:	e8 19 33 00 00       	call   f01039e6 <cprintf>
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
f010070b:	81 c3 5d f1 07 00    	add    $0x7f15d,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100711:	83 ec 04             	sub    $0x4,%esp
f0100714:	8d 83 78 5d f8 ff    	lea    -0x7a288(%ebx),%eax
f010071a:	50                   	push   %eax
f010071b:	8d 83 96 5d f8 ff    	lea    -0x7a26a(%ebx),%eax
f0100721:	50                   	push   %eax
f0100722:	8d b3 9b 5d f8 ff    	lea    -0x7a265(%ebx),%esi
f0100728:	56                   	push   %esi
f0100729:	e8 b8 32 00 00       	call   f01039e6 <cprintf>
f010072e:	83 c4 0c             	add    $0xc,%esp
f0100731:	8d 83 04 5e f8 ff    	lea    -0x7a1fc(%ebx),%eax
f0100737:	50                   	push   %eax
f0100738:	8d 83 a4 5d f8 ff    	lea    -0x7a25c(%ebx),%eax
f010073e:	50                   	push   %eax
f010073f:	56                   	push   %esi
f0100740:	e8 a1 32 00 00       	call   f01039e6 <cprintf>
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
f010075f:	81 c3 09 f1 07 00    	add    $0x7f109,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100765:	8d 83 ad 5d f8 ff    	lea    -0x7a253(%ebx),%eax
f010076b:	50                   	push   %eax
f010076c:	e8 75 32 00 00       	call   f01039e6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100771:	83 c4 08             	add    $0x8,%esp
f0100774:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f010077a:	8d 83 2c 5e f8 ff    	lea    -0x7a1d4(%ebx),%eax
f0100780:	50                   	push   %eax
f0100781:	e8 60 32 00 00       	call   f01039e6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100786:	83 c4 0c             	add    $0xc,%esp
f0100789:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010078f:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100795:	50                   	push   %eax
f0100796:	57                   	push   %edi
f0100797:	8d 83 54 5e f8 ff    	lea    -0x7a1ac(%ebx),%eax
f010079d:	50                   	push   %eax
f010079e:	e8 43 32 00 00       	call   f01039e6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007a3:	83 c4 0c             	add    $0xc,%esp
f01007a6:	c7 c0 41 53 10 f0    	mov    $0xf0105341,%eax
f01007ac:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007b2:	52                   	push   %edx
f01007b3:	50                   	push   %eax
f01007b4:	8d 83 78 5e f8 ff    	lea    -0x7a188(%ebx),%eax
f01007ba:	50                   	push   %eax
f01007bb:	e8 26 32 00 00       	call   f01039e6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007c0:	83 c4 0c             	add    $0xc,%esp
f01007c3:	c7 c0 e0 10 18 f0    	mov    $0xf01810e0,%eax
f01007c9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007cf:	52                   	push   %edx
f01007d0:	50                   	push   %eax
f01007d1:	8d 83 9c 5e f8 ff    	lea    -0x7a164(%ebx),%eax
f01007d7:	50                   	push   %eax
f01007d8:	e8 09 32 00 00       	call   f01039e6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007dd:	83 c4 0c             	add    $0xc,%esp
f01007e0:	c7 c6 00 20 18 f0    	mov    $0xf0182000,%esi
f01007e6:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007ec:	50                   	push   %eax
f01007ed:	56                   	push   %esi
f01007ee:	8d 83 c0 5e f8 ff    	lea    -0x7a140(%ebx),%eax
f01007f4:	50                   	push   %eax
f01007f5:	e8 ec 31 00 00       	call   f01039e6 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007fa:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01007fd:	29 fe                	sub    %edi,%esi
f01007ff:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100805:	c1 fe 0a             	sar    $0xa,%esi
f0100808:	56                   	push   %esi
f0100809:	8d 83 e4 5e f8 ff    	lea    -0x7a11c(%ebx),%eax
f010080f:	50                   	push   %eax
f0100810:	e8 d1 31 00 00       	call   f01039e6 <cprintf>
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
f0100836:	81 c3 32 f0 07 00    	add    $0x7f032,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010083c:	8d 83 10 5f f8 ff    	lea    -0x7a0f0(%ebx),%eax
f0100842:	50                   	push   %eax
f0100843:	e8 9e 31 00 00       	call   f01039e6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100848:	8d 83 34 5f f8 ff    	lea    -0x7a0cc(%ebx),%eax
f010084e:	89 04 24             	mov    %eax,(%esp)
f0100851:	e8 90 31 00 00       	call   f01039e6 <cprintf>

	if (tf != NULL)
f0100856:	83 c4 10             	add    $0x10,%esp
f0100859:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010085d:	74 0e                	je     f010086d <monitor+0x45>
		print_trapframe(tf);
f010085f:	83 ec 0c             	sub    $0xc,%esp
f0100862:	ff 75 08             	push   0x8(%ebp)
f0100865:	e8 59 36 00 00       	call   f0103ec3 <print_trapframe>
f010086a:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010086d:	8d bb ca 5d f8 ff    	lea    -0x7a236(%ebx),%edi
f0100873:	eb 4a                	jmp    f01008bf <monitor+0x97>
f0100875:	83 ec 08             	sub    $0x8,%esp
f0100878:	0f be c0             	movsbl %al,%eax
f010087b:	50                   	push   %eax
f010087c:	57                   	push   %edi
f010087d:	e8 54 46 00 00       	call   f0104ed6 <strchr>
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
f01008b0:	8d 83 cf 5d f8 ff    	lea    -0x7a231(%ebx),%eax
f01008b6:	50                   	push   %eax
f01008b7:	e8 2a 31 00 00       	call   f01039e6 <cprintf>
			return 0;
f01008bc:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01008bf:	8d 83 c6 5d f8 ff    	lea    -0x7a23a(%ebx),%eax
f01008c5:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01008c8:	83 ec 0c             	sub    $0xc,%esp
f01008cb:	ff 75 a4             	push   -0x5c(%ebp)
f01008ce:	e8 b2 43 00 00       	call   f0104c85 <readline>
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
f01008fe:	e8 d3 45 00 00       	call   f0104ed6 <strchr>
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
f0100927:	8d 83 96 5d f8 ff    	lea    -0x7a26a(%ebx),%eax
f010092d:	50                   	push   %eax
f010092e:	ff 75 a8             	push   -0x58(%ebp)
f0100931:	e8 40 45 00 00       	call   f0104e76 <strcmp>
f0100936:	83 c4 10             	add    $0x10,%esp
f0100939:	85 c0                	test   %eax,%eax
f010093b:	74 38                	je     f0100975 <monitor+0x14d>
f010093d:	83 ec 08             	sub    $0x8,%esp
f0100940:	8d 83 a4 5d f8 ff    	lea    -0x7a25c(%ebx),%eax
f0100946:	50                   	push   %eax
f0100947:	ff 75 a8             	push   -0x58(%ebp)
f010094a:	e8 27 45 00 00       	call   f0104e76 <strcmp>
f010094f:	83 c4 10             	add    $0x10,%esp
f0100952:	85 c0                	test   %eax,%eax
f0100954:	74 1a                	je     f0100970 <monitor+0x148>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100956:	83 ec 08             	sub    $0x8,%esp
f0100959:	ff 75 a8             	push   -0x58(%ebp)
f010095c:	8d 83 ec 5d f8 ff    	lea    -0x7a214(%ebx),%eax
f0100962:	50                   	push   %eax
f0100963:	e8 7e 30 00 00       	call   f01039e6 <cprintf>
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
f010099f:	e8 b2 27 00 00       	call   f0103156 <__x86.get_pc_thunk.dx>
f01009a4:	81 c2 c4 ee 07 00    	add    $0x7eec4,%edx
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
f01009d2:	c7 c1 00 20 18 f0    	mov    $0xf0182000,%ecx
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
f0100a02:	81 c3 66 ee 07 00    	add    $0x7ee66,%ebx
f0100a08:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a0a:	50                   	push   %eax
f0100a0b:	e8 4f 2f 00 00       	call   f010395f <mc146818_read>
f0100a10:	89 c7                	mov    %eax,%edi
f0100a12:	83 c6 01             	add    $0x1,%esi
f0100a15:	89 34 24             	mov    %esi,(%esp)
f0100a18:	e8 42 2f 00 00       	call   f010395f <mc146818_read>
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
f0100a31:	e8 24 27 00 00       	call   f010315a <__x86.get_pc_thunk.cx>
f0100a36:	81 c1 32 ee 07 00    	add    $0x7ee32,%ecx
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
f0100a85:	8d 81 5c 5f f8 ff    	lea    -0x7a0a4(%ecx),%eax
f0100a8b:	50                   	push   %eax
f0100a8c:	68 53 03 00 00       	push   $0x353
f0100a91:	8d 81 61 67 f8 ff    	lea    -0x7989f(%ecx),%eax
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
f0100aaf:	e8 aa 26 00 00       	call   f010315e <__x86.get_pc_thunk.di>
f0100ab4:	81 c7 b4 ed 07 00    	add    $0x7edb4,%edi
f0100aba:	89 7d d4             	mov    %edi,-0x2c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100abd:	84 c0                	test   %al,%al
f0100abf:	0f 85 dc 02 00 00    	jne    f0100da1 <check_page_free_list+0x2fb>
	if (!page_free_list)
f0100ac5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ac8:	83 b8 e4 1a 00 00 00 	cmpl   $0x0,0x1ae4(%eax)
f0100acf:	74 0a                	je     f0100adb <check_page_free_list+0x35>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ad1:	bf 00 04 00 00       	mov    $0x400,%edi
f0100ad6:	e9 29 03 00 00       	jmp    f0100e04 <check_page_free_list+0x35e>
		panic("'page_free_list' is a null pointer!");
f0100adb:	83 ec 04             	sub    $0x4,%esp
f0100ade:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ae1:	8d 83 80 5f f8 ff    	lea    -0x7a080(%ebx),%eax
f0100ae7:	50                   	push   %eax
f0100ae8:	68 8f 02 00 00       	push   $0x28f
f0100aed:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0100af3:	50                   	push   %eax
f0100af4:	e8 b8 f5 ff ff       	call   f01000b1 <_panic>
f0100af9:	50                   	push   %eax
f0100afa:	89 cb                	mov    %ecx,%ebx
f0100afc:	8d 81 5c 5f f8 ff    	lea    -0x7a0a4(%ecx),%eax
f0100b02:	50                   	push   %eax
f0100b03:	6a 56                	push   $0x56
f0100b05:	8d 81 6d 67 f8 ff    	lea    -0x79893(%ecx),%eax
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
f0100b54:	e8 bc 43 00 00       	call   f0104f15 <memset>
f0100b59:	83 c4 10             	add    $0x10,%esp
f0100b5c:	eb b3                	jmp    f0100b11 <check_page_free_list+0x6b>
	first_free_page = (char *) boot_alloc(0);
f0100b5e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b63:	e8 37 fe ff ff       	call   f010099f <boot_alloc>
f0100b68:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100b6e:	8b 90 e4 1a 00 00    	mov    0x1ae4(%eax),%edx
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
f0100b9b:	8d 83 7b 67 f8 ff    	lea    -0x79885(%ebx),%eax
f0100ba1:	50                   	push   %eax
f0100ba2:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0100ba8:	50                   	push   %eax
f0100ba9:	68 a9 02 00 00       	push   $0x2a9
f0100bae:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0100bb4:	50                   	push   %eax
f0100bb5:	e8 f7 f4 ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0100bba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100bbd:	8d 83 9c 67 f8 ff    	lea    -0x79864(%ebx),%eax
f0100bc3:	50                   	push   %eax
f0100bc4:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0100bca:	50                   	push   %eax
f0100bcb:	68 aa 02 00 00       	push   $0x2aa
f0100bd0:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0100bd6:	50                   	push   %eax
f0100bd7:	e8 d5 f4 ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bdc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100bdf:	8d 83 a4 5f f8 ff    	lea    -0x7a05c(%ebx),%eax
f0100be5:	50                   	push   %eax
f0100be6:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0100bec:	50                   	push   %eax
f0100bed:	68 ab 02 00 00       	push   $0x2ab
f0100bf2:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0100bf8:	50                   	push   %eax
f0100bf9:	e8 b3 f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != 0);
f0100bfe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c01:	8d 83 b0 67 f8 ff    	lea    -0x79850(%ebx),%eax
f0100c07:	50                   	push   %eax
f0100c08:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0100c0e:	50                   	push   %eax
f0100c0f:	68 ae 02 00 00       	push   $0x2ae
f0100c14:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0100c1a:	50                   	push   %eax
f0100c1b:	e8 91 f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c20:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c23:	8d 83 c1 67 f8 ff    	lea    -0x7983f(%ebx),%eax
f0100c29:	50                   	push   %eax
f0100c2a:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0100c30:	50                   	push   %eax
f0100c31:	68 af 02 00 00       	push   $0x2af
f0100c36:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0100c3c:	50                   	push   %eax
f0100c3d:	e8 6f f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c42:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c45:	8d 83 d8 5f f8 ff    	lea    -0x7a028(%ebx),%eax
f0100c4b:	50                   	push   %eax
f0100c4c:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0100c52:	50                   	push   %eax
f0100c53:	68 b0 02 00 00       	push   $0x2b0
f0100c58:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0100c5e:	50                   	push   %eax
f0100c5f:	e8 4d f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c64:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c67:	8d 83 da 67 f8 ff    	lea    -0x79826(%ebx),%eax
f0100c6d:	50                   	push   %eax
f0100c6e:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0100c74:	50                   	push   %eax
f0100c75:	68 b1 02 00 00       	push   $0x2b1
f0100c7a:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
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
f0100d01:	8d 83 5c 5f f8 ff    	lea    -0x7a0a4(%ebx),%eax
f0100d07:	50                   	push   %eax
f0100d08:	6a 56                	push   $0x56
f0100d0a:	8d 83 6d 67 f8 ff    	lea    -0x79893(%ebx),%eax
f0100d10:	50                   	push   %eax
f0100d11:	e8 9b f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d16:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d19:	8d 83 fc 5f f8 ff    	lea    -0x7a004(%ebx),%eax
f0100d1f:	50                   	push   %eax
f0100d20:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0100d26:	50                   	push   %eax
f0100d27:	68 b2 02 00 00       	push   $0x2b2
f0100d2c:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
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
f0100d49:	8d 83 44 60 f8 ff    	lea    -0x79fbc(%ebx),%eax
f0100d4f:	50                   	push   %eax
f0100d50:	e8 91 2c 00 00       	call   f01039e6 <cprintf>
}
f0100d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d58:	5b                   	pop    %ebx
f0100d59:	5e                   	pop    %esi
f0100d5a:	5f                   	pop    %edi
f0100d5b:	5d                   	pop    %ebp
f0100d5c:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d5d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d60:	8d 83 f4 67 f8 ff    	lea    -0x7980c(%ebx),%eax
f0100d66:	50                   	push   %eax
f0100d67:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0100d6d:	50                   	push   %eax
f0100d6e:	68 ba 02 00 00       	push   $0x2ba
f0100d73:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0100d79:	50                   	push   %eax
f0100d7a:	e8 32 f3 ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0100d7f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d82:	8d 83 06 68 f8 ff    	lea    -0x797fa(%ebx),%eax
f0100d88:	50                   	push   %eax
f0100d89:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0100d8f:	50                   	push   %eax
f0100d90:	68 bb 02 00 00       	push   $0x2bb
f0100d95:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0100d9b:	50                   	push   %eax
f0100d9c:	e8 10 f3 ff ff       	call   f01000b1 <_panic>
	if (!page_free_list)
f0100da1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100da4:	8b 80 e4 1a 00 00    	mov    0x1ae4(%eax),%eax
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
f0100df9:	89 87 e4 1a 00 00    	mov    %eax,0x1ae4(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100dff:	bf 01 00 00 00       	mov    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e07:	8b b0 e4 1a 00 00    	mov    0x1ae4(%eax),%esi
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
f0100e20:	81 c3 48 ea 07 00    	add    $0x7ea48,%ebx
	pages[0].pp_ref = 1;
f0100e26:	8b 83 d0 1a 00 00    	mov    0x1ad0(%ebx),%eax
f0100e2c:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	for (i = 1; i < npages_basemem; i++) {
f0100e32:	8b bb e8 1a 00 00    	mov    0x1ae8(%ebx),%edi
f0100e38:	8b b3 e4 1a 00 00    	mov    0x1ae4(%ebx),%esi
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
f0100e79:	89 b3 e4 1a 00 00    	mov    %esi,0x1ae4(%ebx)
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
f0100ec4:	8d 83 68 60 f8 ff    	lea    -0x79f98(%ebx),%eax
f0100eca:	50                   	push   %eax
f0100ecb:	68 1e 01 00 00       	push   $0x11e
f0100ed0:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0100ed6:	50                   	push   %eax
f0100ed7:	e8 d5 f1 ff ff       	call   f01000b1 <_panic>
		pages[i].pp_ref = 1;
f0100edc:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
	for(i = EXTPHYSMEM/PGSIZE; i < first_free/PGSIZE; i++) {
f0100ee3:	83 c2 01             	add    $0x1,%edx
f0100ee6:	39 d0                	cmp    %edx,%eax
f0100ee8:	77 f2                	ja     f0100edc <page_init+0xca>
f0100eea:	8b b3 e4 1a 00 00    	mov    0x1ae4(%ebx),%esi
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
f0100f2c:	89 b3 e4 1a 00 00    	mov    %esi,0x1ae4(%ebx)
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
f0100f44:	81 c3 24 e9 07 00    	add    $0x7e924,%ebx
	if(page_free_list == NULL) {
f0100f4a:	8b b3 e4 1a 00 00    	mov    0x1ae4(%ebx),%esi
f0100f50:	85 f6                	test   %esi,%esi
f0100f52:	74 14                	je     f0100f68 <page_alloc+0x2e>
	page_free_list = page_free_list->pp_link;
f0100f54:	8b 06                	mov    (%esi),%eax
f0100f56:	89 83 e4 1a 00 00    	mov    %eax,0x1ae4(%ebx)
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
f0100f9f:	e8 71 3f 00 00       	call   f0104f15 <memset>
f0100fa4:	83 c4 10             	add    $0x10,%esp
f0100fa7:	eb bf                	jmp    f0100f68 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fa9:	52                   	push   %edx
f0100faa:	8d 83 5c 5f f8 ff    	lea    -0x7a0a4(%ebx),%eax
f0100fb0:	50                   	push   %eax
f0100fb1:	6a 56                	push   $0x56
f0100fb3:	8d 83 6d 67 f8 ff    	lea    -0x79893(%ebx),%eax
f0100fb9:	50                   	push   %eax
f0100fba:	e8 f2 f0 ff ff       	call   f01000b1 <_panic>

f0100fbf <page_free>:
{
f0100fbf:	55                   	push   %ebp
f0100fc0:	89 e5                	mov    %esp,%ebp
f0100fc2:	53                   	push   %ebx
f0100fc3:	83 ec 04             	sub    $0x4,%esp
f0100fc6:	e8 9c f1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100fcb:	81 c3 9d e8 07 00    	add    $0x7e89d,%ebx
f0100fd1:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_ref != 0 || pp->pp_link != NULL) {
f0100fd4:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fd9:	75 18                	jne    f0100ff3 <page_free+0x34>
f0100fdb:	83 38 00             	cmpl   $0x0,(%eax)
f0100fde:	75 13                	jne    f0100ff3 <page_free+0x34>
	pp->pp_link = page_free_list;
f0100fe0:	8b 8b e4 1a 00 00    	mov    0x1ae4(%ebx),%ecx
f0100fe6:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f0100fe8:	89 83 e4 1a 00 00    	mov    %eax,0x1ae4(%ebx)
}
f0100fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ff1:	c9                   	leave  
f0100ff2:	c3                   	ret    
		panic("Double check failed when free page");
f0100ff3:	83 ec 04             	sub    $0x4,%esp
f0100ff6:	8d 83 8c 60 f8 ff    	lea    -0x79f74(%ebx),%eax
f0100ffc:	50                   	push   %eax
f0100ffd:	68 5e 01 00 00       	push   $0x15e
f0101002:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
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
f0101040:	e8 19 21 00 00       	call   f010315e <__x86.get_pc_thunk.di>
f0101045:	81 c7 23 e8 07 00    	add    $0x7e823,%edi
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
f01010dd:	8d 87 5c 5f f8 ff    	lea    -0x7a0a4(%edi),%eax
f01010e3:	50                   	push   %eax
f01010e4:	68 8f 01 00 00       	push   $0x18f
f01010e9:	8d 87 61 67 f8 ff    	lea    -0x7989f(%edi),%eax
f01010ef:	50                   	push   %eax
f01010f0:	89 fb                	mov    %edi,%ebx
f01010f2:	e8 ba ef ff ff       	call   f01000b1 <_panic>
f01010f7:	52                   	push   %edx
f01010f8:	8d 87 5c 5f f8 ff    	lea    -0x7a0a4(%edi),%eax
f01010fe:	50                   	push   %eax
f01010ff:	6a 56                	push   $0x56
f0101101:	8d 87 6d 67 f8 ff    	lea    -0x79893(%edi),%eax
f0101107:	50                   	push   %eax
f0101108:	89 fb                	mov    %edi,%ebx
f010110a:	e8 a2 ef ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010110f:	51                   	push   %ecx
f0101110:	8d 87 68 60 f8 ff    	lea    -0x79f98(%edi),%eax
f0101116:	50                   	push   %eax
f0101117:	68 98 01 00 00       	push   $0x198
f010111c:	8d 87 61 67 f8 ff    	lea    -0x7989f(%edi),%eax
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
f010118f:	81 c3 d9 e6 07 00    	add    $0x7e6d9,%ebx
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
f01011d5:	8d 83 b0 60 f8 ff    	lea    -0x79f50(%ebx),%eax
f01011db:	50                   	push   %eax
f01011dc:	6a 4f                	push   $0x4f
f01011de:	8d 83 6d 67 f8 ff    	lea    -0x79893(%ebx),%eax
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
f010122e:	e8 2b 1f 00 00       	call   f010315e <__x86.get_pc_thunk.di>
f0101233:	81 c7 35 e6 07 00    	add    $0x7e635,%edi
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
f01012ab:	05 bd e5 07 00       	add    $0x7e5bd,%eax
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
f01012f6:	89 91 e8 1a 00 00    	mov    %edx,0x1ae8(%ecx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012fc:	89 c2                	mov    %eax,%edx
f01012fe:	29 da                	sub    %ebx,%edx
f0101300:	52                   	push   %edx
f0101301:	53                   	push   %ebx
f0101302:	50                   	push   %eax
f0101303:	8d 81 d0 60 f8 ff    	lea    -0x79f30(%ecx),%eax
f0101309:	50                   	push   %eax
f010130a:	89 cb                	mov    %ecx,%ebx
f010130c:	e8 d5 26 00 00       	call   f01039e6 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);		// 4KB
f0101311:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101316:	e8 84 f6 ff ff       	call   f010099f <boot_alloc>
f010131b:	89 83 d4 1a 00 00    	mov    %eax,0x1ad4(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f0101321:	83 c4 0c             	add    $0xc,%esp
f0101324:	68 00 10 00 00       	push   $0x1000
f0101329:	6a 00                	push   $0x0
f010132b:	50                   	push   %eax
f010132c:	e8 e4 3b 00 00       	call   f0104f15 <memset>
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
f010137d:	e8 93 3b 00 00       	call   f0104f15 <memset>
	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f0101382:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101387:	e8 13 f6 ff ff       	call   f010099f <boot_alloc>
f010138c:	c7 c2 58 13 18 f0    	mov    $0xf0181358,%edx
f0101392:	89 02                	mov    %eax,(%edx)
	memset(envs, 0, NENV * sizeof(struct Env));
f0101394:	83 c4 0c             	add    $0xc,%esp
f0101397:	68 00 80 01 00       	push   $0x18000
f010139c:	6a 00                	push   $0x0
f010139e:	50                   	push   %eax
f010139f:	e8 71 3b 00 00       	call   f0104f15 <memset>
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
f01013c2:	8b 80 e4 1a 00 00    	mov    0x1ae4(%eax),%eax
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
f01013e3:	8d 83 68 60 f8 ff    	lea    -0x79f98(%ebx),%eax
f01013e9:	50                   	push   %eax
f01013ea:	68 94 00 00 00       	push   $0x94
f01013ef:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01013f5:	50                   	push   %eax
f01013f6:	e8 b6 ec ff ff       	call   f01000b1 <_panic>
		panic("'pages' is a null pointer!");
f01013fb:	83 ec 04             	sub    $0x4,%esp
f01013fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101401:	8d 83 17 68 f8 ff    	lea    -0x797e9(%ebx),%eax
f0101407:	50                   	push   %eax
f0101408:	68 ce 02 00 00       	push   $0x2ce
f010140d:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
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
f01014cf:	8b 88 e4 1a 00 00    	mov    0x1ae4(%eax),%ecx
f01014d5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f01014d8:	c7 80 e4 1a 00 00 00 	movl   $0x0,0x1ae4(%eax)
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
f01015c6:	e8 4a 39 00 00       	call   f0104f15 <memset>
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
f0101636:	89 8b e4 1a 00 00    	mov    %ecx,0x1ae4(%ebx)
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
f010165b:	8b 83 e4 1a 00 00    	mov    0x1ae4(%ebx),%eax
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
f0101676:	8d 83 32 68 f8 ff    	lea    -0x797ce(%ebx),%eax
f010167c:	50                   	push   %eax
f010167d:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0101683:	50                   	push   %eax
f0101684:	68 d6 02 00 00       	push   $0x2d6
f0101689:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010168f:	50                   	push   %eax
f0101690:	e8 1c ea ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101695:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101698:	8d 83 48 68 f8 ff    	lea    -0x797b8(%ebx),%eax
f010169e:	50                   	push   %eax
f010169f:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01016a5:	50                   	push   %eax
f01016a6:	68 d7 02 00 00       	push   $0x2d7
f01016ab:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01016b1:	50                   	push   %eax
f01016b2:	e8 fa e9 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01016b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016ba:	8d 83 5e 68 f8 ff    	lea    -0x797a2(%ebx),%eax
f01016c0:	50                   	push   %eax
f01016c1:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01016c7:	50                   	push   %eax
f01016c8:	68 d8 02 00 00       	push   $0x2d8
f01016cd:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01016d3:	50                   	push   %eax
f01016d4:	e8 d8 e9 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01016d9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016dc:	8d 83 74 68 f8 ff    	lea    -0x7978c(%ebx),%eax
f01016e2:	50                   	push   %eax
f01016e3:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01016e9:	50                   	push   %eax
f01016ea:	68 db 02 00 00       	push   $0x2db
f01016ef:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01016f5:	50                   	push   %eax
f01016f6:	e8 b6 e9 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016fb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016fe:	8d 83 0c 61 f8 ff    	lea    -0x79ef4(%ebx),%eax
f0101704:	50                   	push   %eax
f0101705:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010170b:	50                   	push   %eax
f010170c:	68 dc 02 00 00       	push   $0x2dc
f0101711:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0101717:	50                   	push   %eax
f0101718:	e8 94 e9 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010171d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101720:	8d 83 86 68 f8 ff    	lea    -0x7977a(%ebx),%eax
f0101726:	50                   	push   %eax
f0101727:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010172d:	50                   	push   %eax
f010172e:	68 dd 02 00 00       	push   $0x2dd
f0101733:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0101739:	50                   	push   %eax
f010173a:	e8 72 e9 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010173f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101742:	8d 83 a3 68 f8 ff    	lea    -0x7975d(%ebx),%eax
f0101748:	50                   	push   %eax
f0101749:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010174f:	50                   	push   %eax
f0101750:	68 de 02 00 00       	push   $0x2de
f0101755:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010175b:	50                   	push   %eax
f010175c:	e8 50 e9 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101761:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101764:	8d 83 c0 68 f8 ff    	lea    -0x79740(%ebx),%eax
f010176a:	50                   	push   %eax
f010176b:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0101771:	50                   	push   %eax
f0101772:	68 df 02 00 00       	push   $0x2df
f0101777:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010177d:	50                   	push   %eax
f010177e:	e8 2e e9 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101783:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101786:	8d 83 dd 68 f8 ff    	lea    -0x79723(%ebx),%eax
f010178c:	50                   	push   %eax
f010178d:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0101793:	50                   	push   %eax
f0101794:	68 e6 02 00 00       	push   $0x2e6
f0101799:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010179f:	50                   	push   %eax
f01017a0:	e8 0c e9 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f01017a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017a8:	8d 83 32 68 f8 ff    	lea    -0x797ce(%ebx),%eax
f01017ae:	50                   	push   %eax
f01017af:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01017b5:	50                   	push   %eax
f01017b6:	68 ed 02 00 00       	push   $0x2ed
f01017bb:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01017c1:	50                   	push   %eax
f01017c2:	e8 ea e8 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01017c7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017ca:	8d 83 48 68 f8 ff    	lea    -0x797b8(%ebx),%eax
f01017d0:	50                   	push   %eax
f01017d1:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01017d7:	50                   	push   %eax
f01017d8:	68 ee 02 00 00       	push   $0x2ee
f01017dd:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01017e3:	50                   	push   %eax
f01017e4:	e8 c8 e8 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01017e9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017ec:	8d 83 5e 68 f8 ff    	lea    -0x797a2(%ebx),%eax
f01017f2:	50                   	push   %eax
f01017f3:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01017f9:	50                   	push   %eax
f01017fa:	68 ef 02 00 00       	push   $0x2ef
f01017ff:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0101805:	50                   	push   %eax
f0101806:	e8 a6 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f010180b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010180e:	8d 83 74 68 f8 ff    	lea    -0x7978c(%ebx),%eax
f0101814:	50                   	push   %eax
f0101815:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010181b:	50                   	push   %eax
f010181c:	68 f1 02 00 00       	push   $0x2f1
f0101821:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0101827:	50                   	push   %eax
f0101828:	e8 84 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010182d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101830:	8d 83 0c 61 f8 ff    	lea    -0x79ef4(%ebx),%eax
f0101836:	50                   	push   %eax
f0101837:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010183d:	50                   	push   %eax
f010183e:	68 f2 02 00 00       	push   $0x2f2
f0101843:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0101849:	50                   	push   %eax
f010184a:	e8 62 e8 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010184f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101852:	8d 83 dd 68 f8 ff    	lea    -0x79723(%ebx),%eax
f0101858:	50                   	push   %eax
f0101859:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010185f:	50                   	push   %eax
f0101860:	68 f3 02 00 00       	push   $0x2f3
f0101865:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010186b:	50                   	push   %eax
f010186c:	e8 40 e8 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101871:	52                   	push   %edx
f0101872:	89 cb                	mov    %ecx,%ebx
f0101874:	8d 81 5c 5f f8 ff    	lea    -0x7a0a4(%ecx),%eax
f010187a:	50                   	push   %eax
f010187b:	6a 56                	push   $0x56
f010187d:	8d 81 6d 67 f8 ff    	lea    -0x79893(%ecx),%eax
f0101883:	50                   	push   %eax
f0101884:	e8 28 e8 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101889:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010188c:	8d 83 ec 68 f8 ff    	lea    -0x79714(%ebx),%eax
f0101892:	50                   	push   %eax
f0101893:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0101899:	50                   	push   %eax
f010189a:	68 f8 02 00 00       	push   $0x2f8
f010189f:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01018a5:	50                   	push   %eax
f01018a6:	e8 06 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f01018ab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018ae:	8d 83 0a 69 f8 ff    	lea    -0x796f6(%ebx),%eax
f01018b4:	50                   	push   %eax
f01018b5:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01018bb:	50                   	push   %eax
f01018bc:	68 f9 02 00 00       	push   $0x2f9
f01018c1:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01018c7:	50                   	push   %eax
f01018c8:	e8 e4 e7 ff ff       	call   f01000b1 <_panic>
f01018cd:	52                   	push   %edx
f01018ce:	89 cb                	mov    %ecx,%ebx
f01018d0:	8d 81 5c 5f f8 ff    	lea    -0x7a0a4(%ecx),%eax
f01018d6:	50                   	push   %eax
f01018d7:	6a 56                	push   $0x56
f01018d9:	8d 81 6d 67 f8 ff    	lea    -0x79893(%ecx),%eax
f01018df:	50                   	push   %eax
f01018e0:	e8 cc e7 ff ff       	call   f01000b1 <_panic>
		assert(c[i] == 0);
f01018e5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018e8:	8d 83 1a 69 f8 ff    	lea    -0x796e6(%ebx),%eax
f01018ee:	50                   	push   %eax
f01018ef:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01018f5:	50                   	push   %eax
f01018f6:	68 fc 02 00 00       	push   $0x2fc
f01018fb:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0101901:	50                   	push   %eax
f0101902:	e8 aa e7 ff ff       	call   f01000b1 <_panic>
	assert(nfree == 0);
f0101907:	85 f6                	test   %esi,%esi
f0101909:	0f 85 35 08 00 00    	jne    f0102144 <mem_init+0xea7>
	cprintf("check_page_alloc() succeeded!\n");
f010190f:	83 ec 0c             	sub    $0xc,%esp
f0101912:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101915:	8d 83 2c 61 f8 ff    	lea    -0x79ed4(%ebx),%eax
f010191b:	50                   	push   %eax
f010191c:	e8 c5 20 00 00       	call   f01039e6 <cprintf>
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
f010198a:	8b 88 e4 1a 00 00    	mov    0x1ae4(%eax),%ecx
f0101990:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101993:	c7 80 e4 1a 00 00 00 	movl   $0x0,0x1ae4(%eax)
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
f0101f83:	e8 8d 2f 00 00       	call   f0104f15 <memset>
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
f0102002:	89 93 e4 1a 00 00    	mov    %edx,0x1ae4(%ebx)

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
f0102024:	8d 83 fb 69 f8 ff    	lea    -0x79605(%ebx),%eax
f010202a:	89 04 24             	mov    %eax,(%esp)
f010202d:	e8 b4 19 00 00       	call   f01039e6 <cprintf>
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
	boot_map_region(kern_pgdir, (uintptr_t)UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f010206d:	c7 c0 58 13 18 f0    	mov    $0xf0181358,%eax
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
f01020a6:	c7 c0 00 30 11 f0    	mov    $0xf0113000,%eax
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
f0102147:	8d 83 24 69 f8 ff    	lea    -0x796dc(%ebx),%eax
f010214d:	50                   	push   %eax
f010214e:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102154:	50                   	push   %eax
f0102155:	68 09 03 00 00       	push   $0x309
f010215a:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102160:	50                   	push   %eax
f0102161:	e8 4b df ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102166:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102169:	8d 83 32 68 f8 ff    	lea    -0x797ce(%ebx),%eax
f010216f:	50                   	push   %eax
f0102170:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102176:	50                   	push   %eax
f0102177:	68 67 03 00 00       	push   $0x367
f010217c:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102182:	50                   	push   %eax
f0102183:	e8 29 df ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102188:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010218b:	8d 83 48 68 f8 ff    	lea    -0x797b8(%ebx),%eax
f0102191:	50                   	push   %eax
f0102192:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102198:	50                   	push   %eax
f0102199:	68 68 03 00 00       	push   $0x368
f010219e:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01021a4:	50                   	push   %eax
f01021a5:	e8 07 df ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01021aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021ad:	8d 83 5e 68 f8 ff    	lea    -0x797a2(%ebx),%eax
f01021b3:	50                   	push   %eax
f01021b4:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01021ba:	50                   	push   %eax
f01021bb:	68 69 03 00 00       	push   $0x369
f01021c0:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01021c6:	50                   	push   %eax
f01021c7:	e8 e5 de ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01021cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021cf:	8d 83 74 68 f8 ff    	lea    -0x7978c(%ebx),%eax
f01021d5:	50                   	push   %eax
f01021d6:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01021dc:	50                   	push   %eax
f01021dd:	68 6c 03 00 00       	push   $0x36c
f01021e2:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01021e8:	50                   	push   %eax
f01021e9:	e8 c3 de ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01021ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021f1:	8d 83 0c 61 f8 ff    	lea    -0x79ef4(%ebx),%eax
f01021f7:	50                   	push   %eax
f01021f8:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01021fe:	50                   	push   %eax
f01021ff:	68 6d 03 00 00       	push   $0x36d
f0102204:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010220a:	50                   	push   %eax
f010220b:	e8 a1 de ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102210:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102213:	8d 83 dd 68 f8 ff    	lea    -0x79723(%ebx),%eax
f0102219:	50                   	push   %eax
f010221a:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102220:	50                   	push   %eax
f0102221:	68 74 03 00 00       	push   $0x374
f0102226:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010222c:	50                   	push   %eax
f010222d:	e8 7f de ff ff       	call   f01000b1 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102232:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102235:	8d 83 4c 61 f8 ff    	lea    -0x79eb4(%ebx),%eax
f010223b:	50                   	push   %eax
f010223c:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102242:	50                   	push   %eax
f0102243:	68 77 03 00 00       	push   $0x377
f0102248:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010224e:	50                   	push   %eax
f010224f:	e8 5d de ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102254:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102257:	8d 83 84 61 f8 ff    	lea    -0x79e7c(%ebx),%eax
f010225d:	50                   	push   %eax
f010225e:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102264:	50                   	push   %eax
f0102265:	68 7a 03 00 00       	push   $0x37a
f010226a:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102270:	50                   	push   %eax
f0102271:	e8 3b de ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102276:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102279:	8d 83 b4 61 f8 ff    	lea    -0x79e4c(%ebx),%eax
f010227f:	50                   	push   %eax
f0102280:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102286:	50                   	push   %eax
f0102287:	68 7e 03 00 00       	push   $0x37e
f010228c:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102292:	50                   	push   %eax
f0102293:	e8 19 de ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102298:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010229b:	8d 83 e4 61 f8 ff    	lea    -0x79e1c(%ebx),%eax
f01022a1:	50                   	push   %eax
f01022a2:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01022a8:	50                   	push   %eax
f01022a9:	68 7f 03 00 00       	push   $0x37f
f01022ae:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01022b4:	50                   	push   %eax
f01022b5:	e8 f7 dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022bd:	8d 83 0c 62 f8 ff    	lea    -0x79df4(%ebx),%eax
f01022c3:	50                   	push   %eax
f01022c4:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01022ca:	50                   	push   %eax
f01022cb:	68 80 03 00 00       	push   $0x380
f01022d0:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01022d6:	50                   	push   %eax
f01022d7:	e8 d5 dd ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f01022dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022df:	8d 83 2f 69 f8 ff    	lea    -0x796d1(%ebx),%eax
f01022e5:	50                   	push   %eax
f01022e6:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01022ec:	50                   	push   %eax
f01022ed:	68 81 03 00 00       	push   $0x381
f01022f2:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01022f8:	50                   	push   %eax
f01022f9:	e8 b3 dd ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f01022fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102301:	8d 83 40 69 f8 ff    	lea    -0x796c0(%ebx),%eax
f0102307:	50                   	push   %eax
f0102308:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010230e:	50                   	push   %eax
f010230f:	68 82 03 00 00       	push   $0x382
f0102314:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010231a:	50                   	push   %eax
f010231b:	e8 91 dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102320:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102323:	8d 83 3c 62 f8 ff    	lea    -0x79dc4(%ebx),%eax
f0102329:	50                   	push   %eax
f010232a:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102330:	50                   	push   %eax
f0102331:	68 85 03 00 00       	push   $0x385
f0102336:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010233c:	50                   	push   %eax
f010233d:	e8 6f dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102342:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102345:	8d 83 78 62 f8 ff    	lea    -0x79d88(%ebx),%eax
f010234b:	50                   	push   %eax
f010234c:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102352:	50                   	push   %eax
f0102353:	68 86 03 00 00       	push   $0x386
f0102358:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010235e:	50                   	push   %eax
f010235f:	e8 4d dd ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102364:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102367:	8d 83 51 69 f8 ff    	lea    -0x796af(%ebx),%eax
f010236d:	50                   	push   %eax
f010236e:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102374:	50                   	push   %eax
f0102375:	68 87 03 00 00       	push   $0x387
f010237a:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102380:	50                   	push   %eax
f0102381:	e8 2b dd ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102386:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102389:	8d 83 dd 68 f8 ff    	lea    -0x79723(%ebx),%eax
f010238f:	50                   	push   %eax
f0102390:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102396:	50                   	push   %eax
f0102397:	68 8a 03 00 00       	push   $0x38a
f010239c:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01023a2:	50                   	push   %eax
f01023a3:	e8 09 dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023a8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ab:	8d 83 3c 62 f8 ff    	lea    -0x79dc4(%ebx),%eax
f01023b1:	50                   	push   %eax
f01023b2:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01023b8:	50                   	push   %eax
f01023b9:	68 8d 03 00 00       	push   $0x38d
f01023be:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01023c4:	50                   	push   %eax
f01023c5:	e8 e7 dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023cd:	8d 83 78 62 f8 ff    	lea    -0x79d88(%ebx),%eax
f01023d3:	50                   	push   %eax
f01023d4:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01023da:	50                   	push   %eax
f01023db:	68 8e 03 00 00       	push   $0x38e
f01023e0:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01023e6:	50                   	push   %eax
f01023e7:	e8 c5 dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01023ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ef:	8d 83 51 69 f8 ff    	lea    -0x796af(%ebx),%eax
f01023f5:	50                   	push   %eax
f01023f6:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01023fc:	50                   	push   %eax
f01023fd:	68 8f 03 00 00       	push   $0x38f
f0102402:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102408:	50                   	push   %eax
f0102409:	e8 a3 dc ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010240e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102411:	8d 83 dd 68 f8 ff    	lea    -0x79723(%ebx),%eax
f0102417:	50                   	push   %eax
f0102418:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010241e:	50                   	push   %eax
f010241f:	68 93 03 00 00       	push   $0x393
f0102424:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010242a:	50                   	push   %eax
f010242b:	e8 81 dc ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102430:	53                   	push   %ebx
f0102431:	89 cb                	mov    %ecx,%ebx
f0102433:	8d 81 5c 5f f8 ff    	lea    -0x7a0a4(%ecx),%eax
f0102439:	50                   	push   %eax
f010243a:	68 96 03 00 00       	push   $0x396
f010243f:	8d 81 61 67 f8 ff    	lea    -0x7989f(%ecx),%eax
f0102445:	50                   	push   %eax
f0102446:	e8 66 dc ff ff       	call   f01000b1 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010244b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010244e:	8d 83 a8 62 f8 ff    	lea    -0x79d58(%ebx),%eax
f0102454:	50                   	push   %eax
f0102455:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010245b:	50                   	push   %eax
f010245c:	68 97 03 00 00       	push   $0x397
f0102461:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102467:	50                   	push   %eax
f0102468:	e8 44 dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010246d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102470:	8d 83 e8 62 f8 ff    	lea    -0x79d18(%ebx),%eax
f0102476:	50                   	push   %eax
f0102477:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010247d:	50                   	push   %eax
f010247e:	68 9a 03 00 00       	push   $0x39a
f0102483:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102489:	50                   	push   %eax
f010248a:	e8 22 dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010248f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102492:	8d 83 78 62 f8 ff    	lea    -0x79d88(%ebx),%eax
f0102498:	50                   	push   %eax
f0102499:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010249f:	50                   	push   %eax
f01024a0:	68 9b 03 00 00       	push   $0x39b
f01024a5:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01024ab:	50                   	push   %eax
f01024ac:	e8 00 dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01024b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024b4:	8d 83 51 69 f8 ff    	lea    -0x796af(%ebx),%eax
f01024ba:	50                   	push   %eax
f01024bb:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01024c1:	50                   	push   %eax
f01024c2:	68 9c 03 00 00       	push   $0x39c
f01024c7:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01024cd:	50                   	push   %eax
f01024ce:	e8 de db ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024d6:	8d 83 28 63 f8 ff    	lea    -0x79cd8(%ebx),%eax
f01024dc:	50                   	push   %eax
f01024dd:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01024e3:	50                   	push   %eax
f01024e4:	68 9d 03 00 00       	push   $0x39d
f01024e9:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01024ef:	50                   	push   %eax
f01024f0:	e8 bc db ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024f8:	8d 83 62 69 f8 ff    	lea    -0x7969e(%ebx),%eax
f01024fe:	50                   	push   %eax
f01024ff:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102505:	50                   	push   %eax
f0102506:	68 9e 03 00 00       	push   $0x39e
f010250b:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102511:	50                   	push   %eax
f0102512:	e8 9a db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102517:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010251a:	8d 83 3c 62 f8 ff    	lea    -0x79dc4(%ebx),%eax
f0102520:	50                   	push   %eax
f0102521:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102527:	50                   	push   %eax
f0102528:	68 a1 03 00 00       	push   $0x3a1
f010252d:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102533:	50                   	push   %eax
f0102534:	e8 78 db ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102539:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010253c:	8d 83 5c 63 f8 ff    	lea    -0x79ca4(%ebx),%eax
f0102542:	50                   	push   %eax
f0102543:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102549:	50                   	push   %eax
f010254a:	68 a2 03 00 00       	push   $0x3a2
f010254f:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102555:	50                   	push   %eax
f0102556:	e8 56 db ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010255b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010255e:	8d 83 90 63 f8 ff    	lea    -0x79c70(%ebx),%eax
f0102564:	50                   	push   %eax
f0102565:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010256b:	50                   	push   %eax
f010256c:	68 a3 03 00 00       	push   $0x3a3
f0102571:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102577:	50                   	push   %eax
f0102578:	e8 34 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010257d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102580:	8d 83 c8 63 f8 ff    	lea    -0x79c38(%ebx),%eax
f0102586:	50                   	push   %eax
f0102587:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010258d:	50                   	push   %eax
f010258e:	68 a6 03 00 00       	push   $0x3a6
f0102593:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102599:	50                   	push   %eax
f010259a:	e8 12 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010259f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025a2:	8d 83 00 64 f8 ff    	lea    -0x79c00(%ebx),%eax
f01025a8:	50                   	push   %eax
f01025a9:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01025af:	50                   	push   %eax
f01025b0:	68 a9 03 00 00       	push   $0x3a9
f01025b5:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01025bb:	50                   	push   %eax
f01025bc:	e8 f0 da ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025c4:	8d 83 90 63 f8 ff    	lea    -0x79c70(%ebx),%eax
f01025ca:	50                   	push   %eax
f01025cb:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01025d1:	50                   	push   %eax
f01025d2:	68 aa 03 00 00       	push   $0x3aa
f01025d7:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01025dd:	50                   	push   %eax
f01025de:	e8 ce da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01025e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025e6:	8d 83 3c 64 f8 ff    	lea    -0x79bc4(%ebx),%eax
f01025ec:	50                   	push   %eax
f01025ed:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01025f3:	50                   	push   %eax
f01025f4:	68 ad 03 00 00       	push   $0x3ad
f01025f9:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01025ff:	50                   	push   %eax
f0102600:	e8 ac da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102605:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102608:	8d 83 68 64 f8 ff    	lea    -0x79b98(%ebx),%eax
f010260e:	50                   	push   %eax
f010260f:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102615:	50                   	push   %eax
f0102616:	68 ae 03 00 00       	push   $0x3ae
f010261b:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102621:	50                   	push   %eax
f0102622:	e8 8a da ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 2);
f0102627:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010262a:	8d 83 78 69 f8 ff    	lea    -0x79688(%ebx),%eax
f0102630:	50                   	push   %eax
f0102631:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102637:	50                   	push   %eax
f0102638:	68 b0 03 00 00       	push   $0x3b0
f010263d:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102643:	50                   	push   %eax
f0102644:	e8 68 da ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102649:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010264c:	8d 83 89 69 f8 ff    	lea    -0x79677(%ebx),%eax
f0102652:	50                   	push   %eax
f0102653:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102659:	50                   	push   %eax
f010265a:	68 b1 03 00 00       	push   $0x3b1
f010265f:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102665:	50                   	push   %eax
f0102666:	e8 46 da ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010266b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010266e:	8d 83 98 64 f8 ff    	lea    -0x79b68(%ebx),%eax
f0102674:	50                   	push   %eax
f0102675:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010267b:	50                   	push   %eax
f010267c:	68 b4 03 00 00       	push   $0x3b4
f0102681:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102687:	50                   	push   %eax
f0102688:	e8 24 da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010268d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102690:	8d 83 bc 64 f8 ff    	lea    -0x79b44(%ebx),%eax
f0102696:	50                   	push   %eax
f0102697:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010269d:	50                   	push   %eax
f010269e:	68 b8 03 00 00       	push   $0x3b8
f01026a3:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01026a9:	50                   	push   %eax
f01026aa:	e8 02 da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026af:	89 cb                	mov    %ecx,%ebx
f01026b1:	8d 81 68 64 f8 ff    	lea    -0x79b98(%ecx),%eax
f01026b7:	50                   	push   %eax
f01026b8:	8d 81 87 67 f8 ff    	lea    -0x79879(%ecx),%eax
f01026be:	50                   	push   %eax
f01026bf:	68 b9 03 00 00       	push   $0x3b9
f01026c4:	8d 81 61 67 f8 ff    	lea    -0x7989f(%ecx),%eax
f01026ca:	50                   	push   %eax
f01026cb:	e8 e1 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f01026d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026d3:	8d 83 2f 69 f8 ff    	lea    -0x796d1(%ebx),%eax
f01026d9:	50                   	push   %eax
f01026da:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01026e0:	50                   	push   %eax
f01026e1:	68 ba 03 00 00       	push   $0x3ba
f01026e6:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01026ec:	50                   	push   %eax
f01026ed:	e8 bf d9 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01026f2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026f5:	8d 83 89 69 f8 ff    	lea    -0x79677(%ebx),%eax
f01026fb:	50                   	push   %eax
f01026fc:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102702:	50                   	push   %eax
f0102703:	68 bb 03 00 00       	push   $0x3bb
f0102708:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010270e:	50                   	push   %eax
f010270f:	e8 9d d9 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102714:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102717:	8d 83 e0 64 f8 ff    	lea    -0x79b20(%ebx),%eax
f010271d:	50                   	push   %eax
f010271e:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102724:	50                   	push   %eax
f0102725:	68 be 03 00 00       	push   $0x3be
f010272a:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102730:	50                   	push   %eax
f0102731:	e8 7b d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f0102736:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102739:	8d 83 9a 69 f8 ff    	lea    -0x79666(%ebx),%eax
f010273f:	50                   	push   %eax
f0102740:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102746:	50                   	push   %eax
f0102747:	68 bf 03 00 00       	push   $0x3bf
f010274c:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102752:	50                   	push   %eax
f0102753:	e8 59 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f0102758:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010275b:	8d 83 a6 69 f8 ff    	lea    -0x7965a(%ebx),%eax
f0102761:	50                   	push   %eax
f0102762:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102768:	50                   	push   %eax
f0102769:	68 c0 03 00 00       	push   $0x3c0
f010276e:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102774:	50                   	push   %eax
f0102775:	e8 37 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010277a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010277d:	8d 83 bc 64 f8 ff    	lea    -0x79b44(%ebx),%eax
f0102783:	50                   	push   %eax
f0102784:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010278a:	50                   	push   %eax
f010278b:	68 c4 03 00 00       	push   $0x3c4
f0102790:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102796:	50                   	push   %eax
f0102797:	e8 15 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010279c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010279f:	8d 83 18 65 f8 ff    	lea    -0x79ae8(%ebx),%eax
f01027a5:	50                   	push   %eax
f01027a6:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01027ac:	50                   	push   %eax
f01027ad:	68 c5 03 00 00       	push   $0x3c5
f01027b2:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01027b8:	50                   	push   %eax
f01027b9:	e8 f3 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f01027be:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027c1:	8d 83 bb 69 f8 ff    	lea    -0x79645(%ebx),%eax
f01027c7:	50                   	push   %eax
f01027c8:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01027ce:	50                   	push   %eax
f01027cf:	68 c6 03 00 00       	push   $0x3c6
f01027d4:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01027da:	50                   	push   %eax
f01027db:	e8 d1 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01027e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027e3:	8d 83 89 69 f8 ff    	lea    -0x79677(%ebx),%eax
f01027e9:	50                   	push   %eax
f01027ea:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01027f0:	50                   	push   %eax
f01027f1:	68 c7 03 00 00       	push   $0x3c7
f01027f6:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01027fc:	50                   	push   %eax
f01027fd:	e8 af d8 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102802:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102805:	8d 83 40 65 f8 ff    	lea    -0x79ac0(%ebx),%eax
f010280b:	50                   	push   %eax
f010280c:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102812:	50                   	push   %eax
f0102813:	68 ca 03 00 00       	push   $0x3ca
f0102818:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010281e:	50                   	push   %eax
f010281f:	e8 8d d8 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102824:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102827:	8d 83 dd 68 f8 ff    	lea    -0x79723(%ebx),%eax
f010282d:	50                   	push   %eax
f010282e:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102834:	50                   	push   %eax
f0102835:	68 cd 03 00 00       	push   $0x3cd
f010283a:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102840:	50                   	push   %eax
f0102841:	e8 6b d8 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102846:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102849:	8d 83 e4 61 f8 ff    	lea    -0x79e1c(%ebx),%eax
f010284f:	50                   	push   %eax
f0102850:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102856:	50                   	push   %eax
f0102857:	68 d0 03 00 00       	push   $0x3d0
f010285c:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102862:	50                   	push   %eax
f0102863:	e8 49 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102868:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010286b:	8d 83 40 69 f8 ff    	lea    -0x796c0(%ebx),%eax
f0102871:	50                   	push   %eax
f0102872:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102878:	50                   	push   %eax
f0102879:	68 d2 03 00 00       	push   $0x3d2
f010287e:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102884:	50                   	push   %eax
f0102885:	e8 27 d8 ff ff       	call   f01000b1 <_panic>
f010288a:	52                   	push   %edx
f010288b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010288e:	8d 83 5c 5f f8 ff    	lea    -0x7a0a4(%ebx),%eax
f0102894:	50                   	push   %eax
f0102895:	68 d9 03 00 00       	push   $0x3d9
f010289a:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01028a0:	50                   	push   %eax
f01028a1:	e8 0b d8 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028a6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028a9:	8d 83 cc 69 f8 ff    	lea    -0x79634(%ebx),%eax
f01028af:	50                   	push   %eax
f01028b0:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01028b6:	50                   	push   %eax
f01028b7:	68 da 03 00 00       	push   $0x3da
f01028bc:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01028c2:	50                   	push   %eax
f01028c3:	e8 e9 d7 ff ff       	call   f01000b1 <_panic>
f01028c8:	52                   	push   %edx
f01028c9:	8d 83 5c 5f f8 ff    	lea    -0x7a0a4(%ebx),%eax
f01028cf:	50                   	push   %eax
f01028d0:	6a 56                	push   $0x56
f01028d2:	8d 83 6d 67 f8 ff    	lea    -0x79893(%ebx),%eax
f01028d8:	50                   	push   %eax
f01028d9:	e8 d3 d7 ff ff       	call   f01000b1 <_panic>
f01028de:	52                   	push   %edx
f01028df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028e2:	8d 83 5c 5f f8 ff    	lea    -0x7a0a4(%ebx),%eax
f01028e8:	50                   	push   %eax
f01028e9:	6a 56                	push   $0x56
f01028eb:	8d 83 6d 67 f8 ff    	lea    -0x79893(%ebx),%eax
f01028f1:	50                   	push   %eax
f01028f2:	e8 ba d7 ff ff       	call   f01000b1 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f01028f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028fa:	8d 83 e4 69 f8 ff    	lea    -0x7961c(%ebx),%eax
f0102900:	50                   	push   %eax
f0102901:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102907:	50                   	push   %eax
f0102908:	68 e4 03 00 00       	push   $0x3e4
f010290d:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102913:	50                   	push   %eax
f0102914:	e8 98 d7 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102919:	50                   	push   %eax
f010291a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010291d:	8d 83 68 60 f8 ff    	lea    -0x79f98(%ebx),%eax
f0102923:	50                   	push   %eax
f0102924:	68 bb 00 00 00       	push   $0xbb
f0102929:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010292f:	50                   	push   %eax
f0102930:	e8 7c d7 ff ff       	call   f01000b1 <_panic>
f0102935:	50                   	push   %eax
f0102936:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102939:	8d 83 68 60 f8 ff    	lea    -0x79f98(%ebx),%eax
f010293f:	50                   	push   %eax
f0102940:	68 c5 00 00 00       	push   $0xc5
f0102945:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010294b:	50                   	push   %eax
f010294c:	e8 60 d7 ff ff       	call   f01000b1 <_panic>
f0102951:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102954:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f010295a:	8d 83 68 60 f8 ff    	lea    -0x79f98(%ebx),%eax
f0102960:	50                   	push   %eax
f0102961:	68 d2 00 00 00       	push   $0xd2
f0102966:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f010296c:	50                   	push   %eax
f010296d:	e8 3f d7 ff ff       	call   f01000b1 <_panic>
f0102972:	ff 75 bc             	push   -0x44(%ebp)
f0102975:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102978:	8d 83 68 60 f8 ff    	lea    -0x79f98(%ebx),%eax
f010297e:	50                   	push   %eax
f010297f:	68 21 03 00 00       	push   $0x321
f0102984:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
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
f01029bd:	8d 83 64 65 f8 ff    	lea    -0x79a9c(%ebx),%eax
f01029c3:	50                   	push   %eax
f01029c4:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01029ca:	50                   	push   %eax
f01029cb:	68 21 03 00 00       	push   $0x321
f01029d0:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f01029d6:	50                   	push   %eax
f01029d7:	e8 d5 d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029dc:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01029df:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01029e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029e5:	c7 c0 58 13 18 f0    	mov    $0xf0181358,%eax
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
f0102a5f:	8d 83 68 60 f8 ff    	lea    -0x79f98(%ebx),%eax
f0102a65:	50                   	push   %eax
f0102a66:	68 26 03 00 00       	push   $0x326
f0102a6b:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102a71:	50                   	push   %eax
f0102a72:	e8 3a d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102a77:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a7a:	8d 83 98 65 f8 ff    	lea    -0x79a68(%ebx),%eax
f0102a80:	50                   	push   %eax
f0102a81:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102a87:	50                   	push   %eax
f0102a88:	68 26 03 00 00       	push   $0x326
f0102a8d:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102a93:	50                   	push   %eax
f0102a94:	e8 18 d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a99:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a9c:	8d 83 cc 65 f8 ff    	lea    -0x79a34(%ebx),%eax
f0102aa2:	50                   	push   %eax
f0102aa3:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102aa9:	50                   	push   %eax
f0102aaa:	68 2a 03 00 00       	push   $0x32a
f0102aaf:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
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
f0102b01:	8d 83 3c 66 f8 ff    	lea    -0x799c4(%ebx),%eax
f0102b07:	50                   	push   %eax
f0102b08:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102b0e:	50                   	push   %eax
f0102b0f:	68 2f 03 00 00       	push   $0x32f
f0102b14:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102b1a:	50                   	push   %eax
f0102b1b:	e8 91 d5 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102b20:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b23:	8d 83 f4 65 f8 ff    	lea    -0x79a0c(%ebx),%eax
f0102b29:	50                   	push   %eax
f0102b2a:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102b30:	50                   	push   %eax
f0102b31:	68 2e 03 00 00       	push   $0x32e
f0102b36:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
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
f0102b80:	8d 83 36 6a f8 ff    	lea    -0x795ca(%ebx),%eax
f0102b86:	50                   	push   %eax
f0102b87:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102b8d:	50                   	push   %eax
f0102b8e:	68 3f 03 00 00       	push   $0x33f
f0102b93:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102b99:	50                   	push   %eax
f0102b9a:	e8 12 d5 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102b9f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ba2:	8d 83 14 6a f8 ff    	lea    -0x795ec(%ebx),%eax
f0102ba8:	50                   	push   %eax
f0102ba9:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102baf:	50                   	push   %eax
f0102bb0:	68 38 03 00 00       	push   $0x338
f0102bb5:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
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
f0102bcf:	8d 83 25 6a f8 ff    	lea    -0x795db(%ebx),%eax
f0102bd5:	50                   	push   %eax
f0102bd6:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102bdc:	50                   	push   %eax
f0102bdd:	68 3d 03 00 00       	push   $0x33d
f0102be2:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102be8:	50                   	push   %eax
f0102be9:	e8 c3 d4 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102bee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bf1:	8d 83 14 6a f8 ff    	lea    -0x795ec(%ebx),%eax
f0102bf7:	50                   	push   %eax
f0102bf8:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102bfe:	50                   	push   %eax
f0102bff:	68 3c 03 00 00       	push   $0x33c
f0102c04:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102c0a:	50                   	push   %eax
f0102c0b:	e8 a1 d4 ff ff       	call   f01000b1 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c10:	83 ec 0c             	sub    $0xc,%esp
f0102c13:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c16:	8d 83 6c 66 f8 ff    	lea    -0x79994(%ebx),%eax
f0102c1c:	50                   	push   %eax
f0102c1d:	e8 c4 0d 00 00       	call   f01039e6 <cprintf>
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
f0102ce1:	e8 2f 22 00 00       	call   f0104f15 <memset>
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
f0102d1e:	e8 f2 21 00 00       	call   f0104f15 <memset>
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
f0102e49:	8d 83 00 67 f8 ff    	lea    -0x79900(%ebx),%eax
f0102e4f:	89 04 24             	mov    %eax,(%esp)
f0102e52:	e8 8f 0b 00 00       	call   f01039e6 <cprintf>
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
f0102e66:	8d 83 68 60 f8 ff    	lea    -0x79f98(%ebx),%eax
f0102e6c:	50                   	push   %eax
f0102e6d:	68 e8 00 00 00       	push   $0xe8
f0102e72:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102e78:	50                   	push   %eax
f0102e79:	e8 33 d2 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102e7e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e81:	8d 83 32 68 f8 ff    	lea    -0x797ce(%ebx),%eax
f0102e87:	50                   	push   %eax
f0102e88:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102e8e:	50                   	push   %eax
f0102e8f:	68 ff 03 00 00       	push   $0x3ff
f0102e94:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102e9a:	50                   	push   %eax
f0102e9b:	e8 11 d2 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102ea0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ea3:	8d 83 48 68 f8 ff    	lea    -0x797b8(%ebx),%eax
f0102ea9:	50                   	push   %eax
f0102eaa:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102eb0:	50                   	push   %eax
f0102eb1:	68 00 04 00 00       	push   $0x400
f0102eb6:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102ebc:	50                   	push   %eax
f0102ebd:	e8 ef d1 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ec2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ec5:	8d 83 5e 68 f8 ff    	lea    -0x797a2(%ebx),%eax
f0102ecb:	50                   	push   %eax
f0102ecc:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102ed2:	50                   	push   %eax
f0102ed3:	68 01 04 00 00       	push   $0x401
f0102ed8:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102ede:	50                   	push   %eax
f0102edf:	e8 cd d1 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ee4:	52                   	push   %edx
f0102ee5:	89 cb                	mov    %ecx,%ebx
f0102ee7:	8d 81 5c 5f f8 ff    	lea    -0x7a0a4(%ecx),%eax
f0102eed:	50                   	push   %eax
f0102eee:	6a 56                	push   $0x56
f0102ef0:	8d 81 6d 67 f8 ff    	lea    -0x79893(%ecx),%eax
f0102ef6:	50                   	push   %eax
f0102ef7:	e8 b5 d1 ff ff       	call   f01000b1 <_panic>
f0102efc:	52                   	push   %edx
f0102efd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f00:	8d 83 5c 5f f8 ff    	lea    -0x7a0a4(%ebx),%eax
f0102f06:	50                   	push   %eax
f0102f07:	6a 56                	push   $0x56
f0102f09:	8d 83 6d 67 f8 ff    	lea    -0x79893(%ebx),%eax
f0102f0f:	50                   	push   %eax
f0102f10:	e8 9c d1 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102f15:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f18:	8d 83 2f 69 f8 ff    	lea    -0x796d1(%ebx),%eax
f0102f1e:	50                   	push   %eax
f0102f1f:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102f25:	50                   	push   %eax
f0102f26:	68 06 04 00 00       	push   $0x406
f0102f2b:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102f31:	50                   	push   %eax
f0102f32:	e8 7a d1 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f37:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f3a:	8d 83 8c 66 f8 ff    	lea    -0x79974(%ebx),%eax
f0102f40:	50                   	push   %eax
f0102f41:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102f47:	50                   	push   %eax
f0102f48:	68 07 04 00 00       	push   $0x407
f0102f4d:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102f53:	50                   	push   %eax
f0102f54:	e8 58 d1 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102f59:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f5c:	8d 83 b0 66 f8 ff    	lea    -0x79950(%ebx),%eax
f0102f62:	50                   	push   %eax
f0102f63:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102f69:	50                   	push   %eax
f0102f6a:	68 09 04 00 00       	push   $0x409
f0102f6f:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102f75:	50                   	push   %eax
f0102f76:	e8 36 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102f7b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f7e:	8d 83 51 69 f8 ff    	lea    -0x796af(%ebx),%eax
f0102f84:	50                   	push   %eax
f0102f85:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102f8b:	50                   	push   %eax
f0102f8c:	68 0a 04 00 00       	push   $0x40a
f0102f91:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102f97:	50                   	push   %eax
f0102f98:	e8 14 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102f9d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fa0:	8d 83 bb 69 f8 ff    	lea    -0x79645(%ebx),%eax
f0102fa6:	50                   	push   %eax
f0102fa7:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102fad:	50                   	push   %eax
f0102fae:	68 0b 04 00 00       	push   $0x40b
f0102fb3:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102fb9:	50                   	push   %eax
f0102fba:	e8 f2 d0 ff ff       	call   f01000b1 <_panic>
f0102fbf:	52                   	push   %edx
f0102fc0:	89 cb                	mov    %ecx,%ebx
f0102fc2:	8d 81 5c 5f f8 ff    	lea    -0x7a0a4(%ecx),%eax
f0102fc8:	50                   	push   %eax
f0102fc9:	6a 56                	push   $0x56
f0102fcb:	8d 81 6d 67 f8 ff    	lea    -0x79893(%ecx),%eax
f0102fd1:	50                   	push   %eax
f0102fd2:	e8 da d0 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102fd7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fda:	8d 83 d4 66 f8 ff    	lea    -0x7992c(%ebx),%eax
f0102fe0:	50                   	push   %eax
f0102fe1:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0102fe7:	50                   	push   %eax
f0102fe8:	68 0d 04 00 00       	push   $0x40d
f0102fed:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0102ff3:	50                   	push   %eax
f0102ff4:	e8 b8 d0 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102ff9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ffc:	8d 83 89 69 f8 ff    	lea    -0x79677(%ebx),%eax
f0103002:	50                   	push   %eax
f0103003:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0103009:	50                   	push   %eax
f010300a:	68 0f 04 00 00       	push   $0x40f
f010300f:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0103015:	50                   	push   %eax
f0103016:	e8 96 d0 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010301b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010301e:	8d 83 e4 61 f8 ff    	lea    -0x79e1c(%ebx),%eax
f0103024:	50                   	push   %eax
f0103025:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010302b:	50                   	push   %eax
f010302c:	68 12 04 00 00       	push   $0x412
f0103031:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
f0103037:	50                   	push   %eax
f0103038:	e8 74 d0 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f010303d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103040:	8d 83 40 69 f8 ff    	lea    -0x796c0(%ebx),%eax
f0103046:	50                   	push   %eax
f0103047:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010304d:	50                   	push   %eax
f010304e:	68 14 04 00 00       	push   $0x414
f0103053:	8d 83 61 67 f8 ff    	lea    -0x7989f(%ebx),%eax
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
{
f010306a:	55                   	push   %ebp
f010306b:	89 e5                	mov    %esp,%ebp
f010306d:	57                   	push   %edi
f010306e:	56                   	push   %esi
f010306f:	53                   	push   %ebx
f0103070:	83 ec 1c             	sub    $0x1c,%esp
f0103073:	e8 81 d6 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0103078:	05 f0 c7 07 00       	add    $0x7c7f0,%eax
f010307d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103080:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint32_t start_addr = ROUNDDOWN((int32_t)va, PGSIZE);
f0103083:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103086:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end_addr = ROUNDUP((int32_t)(va+len), PGSIZE);
f010308c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010308f:	03 75 10             	add    0x10(%ebp),%esi
f0103092:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0103098:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for(; start_addr < end_addr; start_addr += PGSIZE) {
f010309e:	39 f3                	cmp    %esi,%ebx
f01030a0:	73 54                	jae    f01030f6 <user_mem_check+0x8c>
		PTE = pgdir_walk(env->env_pgdir, (const void*)start_addr, 0);
f01030a2:	83 ec 04             	sub    $0x4,%esp
f01030a5:	6a 00                	push   $0x0
f01030a7:	53                   	push   %ebx
f01030a8:	ff 77 5c             	push   0x5c(%edi)
f01030ab:	e8 87 df ff ff       	call   f0101037 <pgdir_walk>
		if (start_addr > (int32_t)ULIM || PTE == NULL || (*PTE & perm) != perm || !(*PTE & PTE_P)) {
f01030b0:	83 c4 10             	add    $0x10,%esp
f01030b3:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f01030b9:	77 1c                	ja     f01030d7 <user_mem_check+0x6d>
f01030bb:	85 c0                	test   %eax,%eax
f01030bd:	74 18                	je     f01030d7 <user_mem_check+0x6d>
f01030bf:	8b 00                	mov    (%eax),%eax
f01030c1:	89 c2                	mov    %eax,%edx
f01030c3:	23 55 14             	and    0x14(%ebp),%edx
f01030c6:	39 55 14             	cmp    %edx,0x14(%ebp)
f01030c9:	75 0c                	jne    f01030d7 <user_mem_check+0x6d>
f01030cb:	a8 01                	test   $0x1,%al
f01030cd:	74 08                	je     f01030d7 <user_mem_check+0x6d>
	for(; start_addr < end_addr; start_addr += PGSIZE) {
f01030cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01030d5:	eb c7                	jmp    f010309e <user_mem_check+0x34>
			user_mem_check_addr = start_addr < (int32_t)va? (int32_t)va: start_addr;
f01030d7:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f01030da:	89 d8                	mov    %ebx,%eax
f01030dc:	0f 43 45 0c          	cmovae 0xc(%ebp),%eax
f01030e0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01030e3:	89 81 e0 1a 00 00    	mov    %eax,0x1ae0(%ecx)
			return -E_FAULT;
f01030e9:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f01030ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030f1:	5b                   	pop    %ebx
f01030f2:	5e                   	pop    %esi
f01030f3:	5f                   	pop    %edi
f01030f4:	5d                   	pop    %ebp
f01030f5:	c3                   	ret    
	return 0;
f01030f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01030fb:	eb f1                	jmp    f01030ee <user_mem_check+0x84>

f01030fd <user_mem_assert>:
{
f01030fd:	55                   	push   %ebp
f01030fe:	89 e5                	mov    %esp,%ebp
f0103100:	56                   	push   %esi
f0103101:	53                   	push   %ebx
f0103102:	e8 60 d0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103107:	81 c3 61 c7 07 00    	add    $0x7c761,%ebx
f010310d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103110:	8b 45 14             	mov    0x14(%ebp),%eax
f0103113:	83 c8 04             	or     $0x4,%eax
f0103116:	50                   	push   %eax
f0103117:	ff 75 10             	push   0x10(%ebp)
f010311a:	ff 75 0c             	push   0xc(%ebp)
f010311d:	56                   	push   %esi
f010311e:	e8 47 ff ff ff       	call   f010306a <user_mem_check>
f0103123:	83 c4 10             	add    $0x10,%esp
f0103126:	85 c0                	test   %eax,%eax
f0103128:	78 07                	js     f0103131 <user_mem_assert+0x34>
}
f010312a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010312d:	5b                   	pop    %ebx
f010312e:	5e                   	pop    %esi
f010312f:	5d                   	pop    %ebp
f0103130:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0103131:	83 ec 04             	sub    $0x4,%esp
f0103134:	ff b3 e0 1a 00 00    	push   0x1ae0(%ebx)
f010313a:	ff 76 48             	push   0x48(%esi)
f010313d:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0103143:	50                   	push   %eax
f0103144:	e8 9d 08 00 00       	call   f01039e6 <cprintf>
		env_destroy(env);	// may not return
f0103149:	89 34 24             	mov    %esi,(%esp)
f010314c:	e8 2b 07 00 00       	call   f010387c <env_destroy>
f0103151:	83 c4 10             	add    $0x10,%esp
}
f0103154:	eb d4                	jmp    f010312a <user_mem_assert+0x2d>

f0103156 <__x86.get_pc_thunk.dx>:
f0103156:	8b 14 24             	mov    (%esp),%edx
f0103159:	c3                   	ret    

f010315a <__x86.get_pc_thunk.cx>:
f010315a:	8b 0c 24             	mov    (%esp),%ecx
f010315d:	c3                   	ret    

f010315e <__x86.get_pc_thunk.di>:
f010315e:	8b 3c 24             	mov    (%esp),%edi
f0103161:	c3                   	ret    

f0103162 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103162:	55                   	push   %ebp
f0103163:	89 e5                	mov    %esp,%ebp
f0103165:	57                   	push   %edi
f0103166:	56                   	push   %esi
f0103167:	53                   	push   %ebx
f0103168:	83 ec 1c             	sub    $0x1c,%esp
f010316b:	e8 f7 cf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103170:	81 c3 f8 c6 07 00    	add    $0x7c6f8,%ebx
f0103176:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uint32_t start = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0103178:	89 d6                	mov    %edx,%esi
f010317a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  	uint32_t end = (uint32_t)ROUNDUP(va + len, PGSIZE);
f0103180:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103187:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010318c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  	struct PageInfo *p = NULL;
  	int re = -1;
  	for(; start<end; start += PGSIZE){
f010318f:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0103192:	73 62                	jae    f01031f6 <region_alloc+0x94>
  	  	p = page_alloc(0);
f0103194:	83 ec 0c             	sub    $0xc,%esp
f0103197:	6a 00                	push   $0x0
f0103199:	e8 9c dd ff ff       	call   f0100f3a <page_alloc>
  	  	if(p == NULL){
f010319e:	83 c4 10             	add    $0x10,%esp
f01031a1:	85 c0                	test   %eax,%eax
f01031a3:	74 1b                	je     f01031c0 <region_alloc+0x5e>
  	  	  	panic("the page allocation failed!\n");
  	  	}

  	  	re = page_insert(e->env_pgdir, p, (void *)start, PTE_U | PTE_W);
f01031a5:	6a 06                	push   $0x6
f01031a7:	56                   	push   %esi
f01031a8:	50                   	push   %eax
f01031a9:	ff 77 5c             	push   0x5c(%edi)
f01031ac:	e8 74 e0 ff ff       	call   f0101225 <page_insert>
  	  	if(re != 0){
f01031b1:	83 c4 10             	add    $0x10,%esp
f01031b4:	85 c0                	test   %eax,%eax
f01031b6:	75 23                	jne    f01031db <region_alloc+0x79>
  	for(; start<end; start += PGSIZE){
f01031b8:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01031be:	eb cf                	jmp    f010318f <region_alloc+0x2d>
  	  	  	panic("the page allocation failed!\n");
f01031c0:	83 ec 04             	sub    $0x4,%esp
f01031c3:	8d 83 44 6a f8 ff    	lea    -0x795bc(%ebx),%eax
f01031c9:	50                   	push   %eax
f01031ca:	68 2b 01 00 00       	push   $0x12b
f01031cf:	8d 83 61 6a f8 ff    	lea    -0x7959f(%ebx),%eax
f01031d5:	50                   	push   %eax
f01031d6:	e8 d6 ce ff ff       	call   f01000b1 <_panic>
  	  	  	panic("the page insert failed!\n");
f01031db:	83 ec 04             	sub    $0x4,%esp
f01031de:	8d 83 6c 6a f8 ff    	lea    -0x79594(%ebx),%eax
f01031e4:	50                   	push   %eax
f01031e5:	68 30 01 00 00       	push   $0x130
f01031ea:	8d 83 61 6a f8 ff    	lea    -0x7959f(%ebx),%eax
f01031f0:	50                   	push   %eax
f01031f1:	e8 bb ce ff ff       	call   f01000b1 <_panic>
  	  	}
  	}
}
f01031f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031f9:	5b                   	pop    %ebx
f01031fa:	5e                   	pop    %esi
f01031fb:	5f                   	pop    %edi
f01031fc:	5d                   	pop    %ebp
f01031fd:	c3                   	ret    

f01031fe <envid2env>:
{
f01031fe:	55                   	push   %ebp
f01031ff:	89 e5                	mov    %esp,%ebp
f0103201:	53                   	push   %ebx
f0103202:	e8 53 ff ff ff       	call   f010315a <__x86.get_pc_thunk.cx>
f0103207:	81 c1 61 c6 07 00    	add    $0x7c661,%ecx
f010320d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103210:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (envid == 0) {
f0103213:	85 c0                	test   %eax,%eax
f0103215:	74 4c                	je     f0103263 <envid2env+0x65>
	e = &envs[ENVX(envid)];
f0103217:	89 c2                	mov    %eax,%edx
f0103219:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010321f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103222:	c1 e2 05             	shl    $0x5,%edx
f0103225:	03 91 f0 1a 00 00    	add    0x1af0(%ecx),%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010322b:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f010322f:	74 42                	je     f0103273 <envid2env+0x75>
f0103231:	39 42 48             	cmp    %eax,0x48(%edx)
f0103234:	75 49                	jne    f010327f <envid2env+0x81>
	return 0;
f0103236:	b8 00 00 00 00       	mov    $0x0,%eax
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010323b:	84 db                	test   %bl,%bl
f010323d:	74 2a                	je     f0103269 <envid2env+0x6b>
f010323f:	8b 89 ec 1a 00 00    	mov    0x1aec(%ecx),%ecx
f0103245:	39 d1                	cmp    %edx,%ecx
f0103247:	74 20                	je     f0103269 <envid2env+0x6b>
f0103249:	8b 42 4c             	mov    0x4c(%edx),%eax
f010324c:	3b 41 48             	cmp    0x48(%ecx),%eax
f010324f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103254:	0f 45 d3             	cmovne %ebx,%edx
f0103257:	0f 94 c0             	sete   %al
f010325a:	0f b6 c0             	movzbl %al,%eax
f010325d:	8d 44 00 fe          	lea    -0x2(%eax,%eax,1),%eax
f0103261:	eb 06                	jmp    f0103269 <envid2env+0x6b>
		*env_store = curenv;
f0103263:	8b 91 ec 1a 00 00    	mov    0x1aec(%ecx),%edx
f0103269:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010326c:	89 11                	mov    %edx,(%ecx)
}
f010326e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103271:	c9                   	leave  
f0103272:	c3                   	ret    
f0103273:	ba 00 00 00 00       	mov    $0x0,%edx
		return -E_BAD_ENV;
f0103278:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010327d:	eb ea                	jmp    f0103269 <envid2env+0x6b>
f010327f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103284:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103289:	eb de                	jmp    f0103269 <envid2env+0x6b>

f010328b <env_init_percpu>:
{
f010328b:	e8 69 d4 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0103290:	05 d8 c5 07 00       	add    $0x7c5d8,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f0103295:	8d 80 98 17 00 00    	lea    0x1798(%eax),%eax
f010329b:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010329e:	b8 23 00 00 00       	mov    $0x23,%eax
f01032a3:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01032a5:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01032a7:	b8 10 00 00 00       	mov    $0x10,%eax
f01032ac:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01032ae:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01032b0:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01032b2:	ea b9 32 10 f0 08 00 	ljmp   $0x8,$0xf01032b9
	asm volatile("lldt %0" : : "r" (sel));
f01032b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01032be:	0f 00 d0             	lldt   %ax
}
f01032c1:	c3                   	ret    

f01032c2 <env_init>:
{
f01032c2:	55                   	push   %ebp
f01032c3:	89 e5                	mov    %esp,%ebp
f01032c5:	56                   	push   %esi
f01032c6:	53                   	push   %ebx
f01032c7:	e8 9b ce ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01032cc:	81 c3 9c c5 07 00    	add    $0x7c59c,%ebx
    	  	envs[i].env_link = &envs[i+1];
f01032d2:	8b 8b f0 1a 00 00    	mov    0x1af0(%ebx),%ecx
  	for(i = 0; i < NENV; i++){
f01032d8:	ba 00 00 00 00       	mov    $0x0,%edx
    	  	envs[i].env_link = &envs[i+1];
f01032dd:	8d 44 52 03          	lea    0x3(%edx,%edx,2),%eax
f01032e1:	c1 e0 05             	shl    $0x5,%eax
f01032e4:	8d 34 01             	lea    (%ecx,%eax,1),%esi
f01032e7:	89 74 01 e4          	mov    %esi,-0x1c(%ecx,%eax,1)
f01032eb:	8d 44 01 e8          	lea    -0x18(%ecx,%eax,1),%eax
    	envs[i].env_id = 0;
f01032ef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    	envs[i].env_parent_id = 0;
f01032f5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    	envs[i].env_type = ENV_TYPE_USER;
f01032fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    	envs[i].env_status = ENV_FREE;
f0103303:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    	envs[i].env_runs = 0;
f010330a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
    	envs[i].env_pgdir = NULL; 
f0103311:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  	for(i = 0; i < NENV; i++){
f0103318:	83 c2 01             	add    $0x1,%edx
f010331b:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0103321:	7f 17                	jg     f010333a <env_init+0x78>
    if(i == NENV - 1){
f0103323:	83 c0 60             	add    $0x60,%eax
f0103326:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f010332c:	75 af                	jne    f01032dd <env_init+0x1b>
    	  	envs[i].env_link = NULL;
f010332e:	c7 81 e4 7f 01 00 00 	movl   $0x0,0x17fe4(%ecx)
f0103335:	00 00 00 
f0103338:	eb b5                	jmp    f01032ef <env_init+0x2d>
  	env_free_list = envs;
f010333a:	8b 83 f0 1a 00 00    	mov    0x1af0(%ebx),%eax
f0103340:	89 83 f4 1a 00 00    	mov    %eax,0x1af4(%ebx)
	env_init_percpu();
f0103346:	e8 40 ff ff ff       	call   f010328b <env_init_percpu>
}
f010334b:	5b                   	pop    %ebx
f010334c:	5e                   	pop    %esi
f010334d:	5d                   	pop    %ebp
f010334e:	c3                   	ret    

f010334f <env_alloc>:
{
f010334f:	55                   	push   %ebp
f0103350:	89 e5                	mov    %esp,%ebp
f0103352:	57                   	push   %edi
f0103353:	56                   	push   %esi
f0103354:	53                   	push   %ebx
f0103355:	83 ec 0c             	sub    $0xc,%esp
f0103358:	e8 0a ce ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010335d:	81 c3 0b c5 07 00    	add    $0x7c50b,%ebx
	if (!(e = env_free_list))
f0103363:	8b b3 f4 1a 00 00    	mov    0x1af4(%ebx),%esi
f0103369:	85 f6                	test   %esi,%esi
f010336b:	0f 84 85 01 00 00    	je     f01034f6 <env_alloc+0x1a7>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103371:	83 ec 0c             	sub    $0xc,%esp
f0103374:	6a 01                	push   $0x1
f0103376:	e8 bf db ff ff       	call   f0100f3a <page_alloc>
f010337b:	89 c2                	mov    %eax,%edx
f010337d:	83 c4 10             	add    $0x10,%esp
f0103380:	85 c0                	test   %eax,%eax
f0103382:	0f 84 75 01 00 00    	je     f01034fd <env_alloc+0x1ae>
	return (pp - pages) << PGSHIFT;
f0103388:	c7 c0 38 13 18 f0    	mov    $0xf0181338,%eax
f010338e:	89 d7                	mov    %edx,%edi
f0103390:	2b 38                	sub    (%eax),%edi
f0103392:	89 f8                	mov    %edi,%eax
f0103394:	c1 f8 03             	sar    $0x3,%eax
f0103397:	89 c1                	mov    %eax,%ecx
f0103399:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f010339c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01033a1:	c7 c7 40 13 18 f0    	mov    $0xf0181340,%edi
f01033a7:	3b 07                	cmp    (%edi),%eax
f01033a9:	0f 83 18 01 00 00    	jae    f01034c7 <env_alloc+0x178>
	return (void *)(pa + KERNBASE);
f01033af:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f01033b5:	89 4e 5c             	mov    %ecx,0x5c(%esi)
  	p->pp_ref++;
f01033b8:	66 83 42 04 01       	addw   $0x1,0x4(%edx)
f01033bd:	b8 00 00 00 00       	mov    $0x0,%eax
  	  	e->env_pgdir[i] = 0;
f01033c2:	8b 56 5c             	mov    0x5c(%esi),%edx
f01033c5:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
  	for(i = 0; i < PDX(UTOP); i++){
f01033cc:	83 c0 04             	add    $0x4,%eax
f01033cf:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01033d4:	75 ec                	jne    f01033c2 <env_alloc+0x73>
  	  	e->env_pgdir[i] = kern_pgdir[i];
f01033d6:	c7 c7 3c 13 18 f0    	mov    $0xf018133c,%edi
f01033dc:	8b 17                	mov    (%edi),%edx
f01033de:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01033e1:	8b 56 5c             	mov    0x5c(%esi),%edx
f01033e4:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
  	for(i = PDX(UTOP); i<NPDENTRIES; i++){
f01033e7:	83 c0 04             	add    $0x4,%eax
f01033ea:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01033ef:	75 eb                	jne    f01033dc <env_alloc+0x8d>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01033f1:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f01033f4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033f9:	0f 86 de 00 00 00    	jbe    f01034dd <env_alloc+0x18e>
	return (physaddr_t)kva - KERNBASE;
f01033ff:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103405:	83 ca 05             	or     $0x5,%edx
f0103408:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010340e:	8b 46 48             	mov    0x48(%esi),%eax
f0103411:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f0103416:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010341b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103420:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103423:	89 f2                	mov    %esi,%edx
f0103425:	2b 93 f0 1a 00 00    	sub    0x1af0(%ebx),%edx
f010342b:	c1 fa 05             	sar    $0x5,%edx
f010342e:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103434:	09 d0                	or     %edx,%eax
f0103436:	89 46 48             	mov    %eax,0x48(%esi)
	e->env_parent_id = parent_id;
f0103439:	8b 45 0c             	mov    0xc(%ebp),%eax
f010343c:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f010343f:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0103446:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f010344d:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103454:	83 ec 04             	sub    $0x4,%esp
f0103457:	6a 44                	push   $0x44
f0103459:	6a 00                	push   $0x0
f010345b:	56                   	push   %esi
f010345c:	e8 b4 1a 00 00       	call   f0104f15 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103461:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f0103467:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f010346d:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0103473:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f010347a:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	env_free_list = e->env_link;
f0103480:	8b 46 44             	mov    0x44(%esi),%eax
f0103483:	89 83 f4 1a 00 00    	mov    %eax,0x1af4(%ebx)
	*newenv_store = e;
f0103489:	8b 45 08             	mov    0x8(%ebp),%eax
f010348c:	89 30                	mov    %esi,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010348e:	8b 4e 48             	mov    0x48(%esi),%ecx
f0103491:	8b 83 ec 1a 00 00    	mov    0x1aec(%ebx),%eax
f0103497:	83 c4 10             	add    $0x10,%esp
f010349a:	ba 00 00 00 00       	mov    $0x0,%edx
f010349f:	85 c0                	test   %eax,%eax
f01034a1:	74 03                	je     f01034a6 <env_alloc+0x157>
f01034a3:	8b 50 48             	mov    0x48(%eax),%edx
f01034a6:	83 ec 04             	sub    $0x4,%esp
f01034a9:	51                   	push   %ecx
f01034aa:	52                   	push   %edx
f01034ab:	8d 83 85 6a f8 ff    	lea    -0x7957b(%ebx),%eax
f01034b1:	50                   	push   %eax
f01034b2:	e8 2f 05 00 00       	call   f01039e6 <cprintf>
	return 0;
f01034b7:	83 c4 10             	add    $0x10,%esp
f01034ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034c2:	5b                   	pop    %ebx
f01034c3:	5e                   	pop    %esi
f01034c4:	5f                   	pop    %edi
f01034c5:	5d                   	pop    %ebp
f01034c6:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01034c7:	51                   	push   %ecx
f01034c8:	8d 83 5c 5f f8 ff    	lea    -0x7a0a4(%ebx),%eax
f01034ce:	50                   	push   %eax
f01034cf:	6a 56                	push   $0x56
f01034d1:	8d 83 6d 67 f8 ff    	lea    -0x79893(%ebx),%eax
f01034d7:	50                   	push   %eax
f01034d8:	e8 d4 cb ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034dd:	50                   	push   %eax
f01034de:	8d 83 68 60 f8 ff    	lea    -0x79f98(%ebx),%eax
f01034e4:	50                   	push   %eax
f01034e5:	68 cf 00 00 00       	push   $0xcf
f01034ea:	8d 83 61 6a f8 ff    	lea    -0x7959f(%ebx),%eax
f01034f0:	50                   	push   %eax
f01034f1:	e8 bb cb ff ff       	call   f01000b1 <_panic>
		return -E_NO_FREE_ENV;
f01034f6:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01034fb:	eb c2                	jmp    f01034bf <env_alloc+0x170>
		return -E_NO_MEM;
f01034fd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103502:	eb bb                	jmp    f01034bf <env_alloc+0x170>

f0103504 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103504:	55                   	push   %ebp
f0103505:	89 e5                	mov    %esp,%ebp
f0103507:	57                   	push   %edi
f0103508:	56                   	push   %esi
f0103509:	53                   	push   %ebx
f010350a:	83 ec 34             	sub    $0x34,%esp
f010350d:	e8 55 cc ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103512:	81 c3 56 c3 07 00    	add    $0x7c356,%ebx
	// LAB 3: Your code here.
	struct Env *e;

  if(env_alloc(&e, 0) != 0){
f0103518:	6a 00                	push   $0x0
f010351a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010351d:	50                   	push   %eax
f010351e:	e8 2c fe ff ff       	call   f010334f <env_alloc>
f0103523:	83 c4 10             	add    $0x10,%esp
f0103526:	85 c0                	test   %eax,%eax
f0103528:	75 51                	jne    f010357b <env_create+0x77>
    panic("env_create faild!\n");
  }

  e->env_type = type;
f010352a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010352d:	89 c1                	mov    %eax,%ecx
f010352f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103532:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103535:	89 41 50             	mov    %eax,0x50(%ecx)
  	if(elf_head->e_magic != ELF_MAGIC){
f0103538:	8b 45 08             	mov    0x8(%ebp),%eax
f010353b:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103541:	75 53                	jne    f0103596 <env_create+0x92>
  	if(elf_head->e_entry == 0){
f0103543:	8b 45 08             	mov    0x8(%ebp),%eax
f0103546:	8b 40 18             	mov    0x18(%eax),%eax
f0103549:	85 c0                	test   %eax,%eax
f010354b:	74 64                	je     f01035b1 <env_create+0xad>
  	e->env_tf.tf_eip = elf_head->e_entry;
f010354d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103550:	89 41 30             	mov    %eax,0x30(%ecx)
  	ph = (struct Proghdr *)((uint8_t *)elf_head + elf_head->e_phoff);
f0103553:	8b 45 08             	mov    0x8(%ebp),%eax
f0103556:	89 c6                	mov    %eax,%esi
f0103558:	03 70 1c             	add    0x1c(%eax),%esi
  	eph = ph + elf_head->e_phnum;
f010355b:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f010355f:	c1 e7 05             	shl    $0x5,%edi
f0103562:	01 f7                	add    %esi,%edi
  	lcr3(PADDR(e->env_pgdir));
f0103564:	8b 41 5c             	mov    0x5c(%ecx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103567:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010356c:	76 5e                	jbe    f01035cc <env_create+0xc8>
	return (physaddr_t)kva - KERNBASE;
f010356e:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103573:	0f 22 d8             	mov    %eax,%cr3
}
f0103576:	e9 a7 00 00 00       	jmp    f0103622 <env_create+0x11e>
    panic("env_create faild!\n");
f010357b:	83 ec 04             	sub    $0x4,%esp
f010357e:	8d 83 9a 6a f8 ff    	lea    -0x79566(%ebx),%eax
f0103584:	50                   	push   %eax
f0103585:	68 9b 01 00 00       	push   $0x19b
f010358a:	8d 83 61 6a f8 ff    	lea    -0x7959f(%ebx),%eax
f0103590:	50                   	push   %eax
f0103591:	e8 1b cb ff ff       	call   f01000b1 <_panic>
  	  panic("load_icode:the file is not elf!\n");
f0103596:	83 ec 04             	sub    $0x4,%esp
f0103599:	8d 83 f0 6a f8 ff    	lea    -0x79510(%ebx),%eax
f010359f:	50                   	push   %eax
f01035a0:	68 6f 01 00 00       	push   $0x16f
f01035a5:	8d 83 61 6a f8 ff    	lea    -0x7959f(%ebx),%eax
f01035ab:	50                   	push   %eax
f01035ac:	e8 00 cb ff ff       	call   f01000b1 <_panic>
  	  panic("load_icode:the entry is null\n");
f01035b1:	83 ec 04             	sub    $0x4,%esp
f01035b4:	8d 83 ad 6a f8 ff    	lea    -0x79553(%ebx),%eax
f01035ba:	50                   	push   %eax
f01035bb:	68 73 01 00 00       	push   $0x173
f01035c0:	8d 83 61 6a f8 ff    	lea    -0x7959f(%ebx),%eax
f01035c6:	50                   	push   %eax
f01035c7:	e8 e5 ca ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035cc:	50                   	push   %eax
f01035cd:	8d 83 68 60 f8 ff    	lea    -0x79f98(%ebx),%eax
f01035d3:	50                   	push   %eax
f01035d4:	68 7a 01 00 00       	push   $0x17a
f01035d9:	8d 83 61 6a f8 ff    	lea    -0x7959f(%ebx),%eax
f01035df:	50                   	push   %eax
f01035e0:	e8 cc ca ff ff       	call   f01000b1 <_panic>
  	    region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01035e5:	8b 56 08             	mov    0x8(%esi),%edx
f01035e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01035eb:	e8 72 fb ff ff       	call   f0103162 <region_alloc>
  	    memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f01035f0:	83 ec 04             	sub    $0x4,%esp
f01035f3:	ff 76 10             	push   0x10(%esi)
f01035f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01035f9:	03 46 04             	add    0x4(%esi),%eax
f01035fc:	50                   	push   %eax
f01035fd:	ff 76 08             	push   0x8(%esi)
f0103600:	e8 56 19 00 00       	call   f0104f5b <memmove>
  	    memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz- ph->p_filesz);
f0103605:	8b 46 10             	mov    0x10(%esi),%eax
f0103608:	83 c4 0c             	add    $0xc,%esp
f010360b:	8b 56 14             	mov    0x14(%esi),%edx
f010360e:	29 c2                	sub    %eax,%edx
f0103610:	52                   	push   %edx
f0103611:	6a 00                	push   $0x0
f0103613:	03 46 08             	add    0x8(%esi),%eax
f0103616:	50                   	push   %eax
f0103617:	e8 f9 18 00 00       	call   f0104f15 <memset>
f010361c:	83 c4 10             	add    $0x10,%esp
  	for(; ph < eph; ph++){
f010361f:	83 c6 20             	add    $0x20,%esi
f0103622:	39 f7                	cmp    %esi,%edi
f0103624:	76 28                	jbe    f010364e <env_create+0x14a>
  	  if(ph->p_type == ELF_PROG_LOAD){
f0103626:	83 3e 01             	cmpl   $0x1,(%esi)
f0103629:	75 f4                	jne    f010361f <env_create+0x11b>
  	    if(ph->p_filesz > ph->p_memsz){
f010362b:	8b 4e 14             	mov    0x14(%esi),%ecx
f010362e:	39 4e 10             	cmp    %ecx,0x10(%esi)
f0103631:	76 b2                	jbe    f01035e5 <env_create+0xe1>
  	      panic("load_icode:the filesz > memsz!\n");
f0103633:	83 ec 04             	sub    $0x4,%esp
f0103636:	8d 83 14 6b f8 ff    	lea    -0x794ec(%ebx),%eax
f010363c:	50                   	push   %eax
f010363d:	68 7e 01 00 00       	push   $0x17e
f0103642:	8d 83 61 6a f8 ff    	lea    -0x7959f(%ebx),%eax
f0103648:	50                   	push   %eax
f0103649:	e8 63 ca ff ff       	call   f01000b1 <_panic>
	region_alloc(e, (void *)(USTACKTOP-PGSIZE), PGSIZE);
f010364e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103653:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103658:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010365b:	e8 02 fb ff ff       	call   f0103162 <region_alloc>
  load_icode(e, binary);
}
f0103660:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103663:	5b                   	pop    %ebx
f0103664:	5e                   	pop    %esi
f0103665:	5f                   	pop    %edi
f0103666:	5d                   	pop    %ebp
f0103667:	c3                   	ret    

f0103668 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103668:	55                   	push   %ebp
f0103669:	89 e5                	mov    %esp,%ebp
f010366b:	57                   	push   %edi
f010366c:	56                   	push   %esi
f010366d:	53                   	push   %ebx
f010366e:	83 ec 2c             	sub    $0x2c,%esp
f0103671:	e8 f1 ca ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103676:	81 c3 f2 c1 07 00    	add    $0x7c1f2,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010367c:	8b 93 ec 1a 00 00    	mov    0x1aec(%ebx),%edx
f0103682:	3b 55 08             	cmp    0x8(%ebp),%edx
f0103685:	74 47                	je     f01036ce <env_free+0x66>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103687:	8b 45 08             	mov    0x8(%ebp),%eax
f010368a:	8b 48 48             	mov    0x48(%eax),%ecx
f010368d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103692:	85 d2                	test   %edx,%edx
f0103694:	74 03                	je     f0103699 <env_free+0x31>
f0103696:	8b 42 48             	mov    0x48(%edx),%eax
f0103699:	83 ec 04             	sub    $0x4,%esp
f010369c:	51                   	push   %ecx
f010369d:	50                   	push   %eax
f010369e:	8d 83 cb 6a f8 ff    	lea    -0x79535(%ebx),%eax
f01036a4:	50                   	push   %eax
f01036a5:	e8 3c 03 00 00       	call   f01039e6 <cprintf>
f01036aa:	83 c4 10             	add    $0x10,%esp
f01036ad:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	if (PGNUM(pa) >= npages)
f01036b4:	c7 c0 40 13 18 f0    	mov    $0xf0181340,%eax
f01036ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if (PGNUM(pa) >= npages)
f01036bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return &pages[PGNUM(pa)];
f01036c0:	c7 c0 38 13 18 f0    	mov    $0xf0181338,%eax
f01036c6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01036c9:	e9 bf 00 00 00       	jmp    f010378d <env_free+0x125>
		lcr3(PADDR(kern_pgdir));
f01036ce:	c7 c0 3c 13 18 f0    	mov    $0xf018133c,%eax
f01036d4:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01036d6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036db:	76 10                	jbe    f01036ed <env_free+0x85>
	return (physaddr_t)kva - KERNBASE;
f01036dd:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01036e2:	0f 22 d8             	mov    %eax,%cr3
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01036e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01036e8:	8b 48 48             	mov    0x48(%eax),%ecx
f01036eb:	eb a9                	jmp    f0103696 <env_free+0x2e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036ed:	50                   	push   %eax
f01036ee:	8d 83 68 60 f8 ff    	lea    -0x79f98(%ebx),%eax
f01036f4:	50                   	push   %eax
f01036f5:	68 b0 01 00 00       	push   $0x1b0
f01036fa:	8d 83 61 6a f8 ff    	lea    -0x7959f(%ebx),%eax
f0103700:	50                   	push   %eax
f0103701:	e8 ab c9 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103706:	57                   	push   %edi
f0103707:	8d 83 5c 5f f8 ff    	lea    -0x7a0a4(%ebx),%eax
f010370d:	50                   	push   %eax
f010370e:	68 bf 01 00 00       	push   $0x1bf
f0103713:	8d 83 61 6a f8 ff    	lea    -0x7959f(%ebx),%eax
f0103719:	50                   	push   %eax
f010371a:	e8 92 c9 ff ff       	call   f01000b1 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010371f:	83 c7 04             	add    $0x4,%edi
f0103722:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103728:	81 fe 00 00 40 00    	cmp    $0x400000,%esi
f010372e:	74 1e                	je     f010374e <env_free+0xe6>
			if (pt[pteno] & PTE_P)
f0103730:	f6 07 01             	testb  $0x1,(%edi)
f0103733:	74 ea                	je     f010371f <env_free+0xb7>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103735:	83 ec 08             	sub    $0x8,%esp
f0103738:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010373b:	09 f0                	or     %esi,%eax
f010373d:	50                   	push   %eax
f010373e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103741:	ff 70 5c             	push   0x5c(%eax)
f0103744:	e8 a1 da ff ff       	call   f01011ea <page_remove>
f0103749:	83 c4 10             	add    $0x10,%esp
f010374c:	eb d1                	jmp    f010371f <env_free+0xb7>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010374e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103751:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103754:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103757:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f010375e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103761:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103764:	3b 10                	cmp    (%eax),%edx
f0103766:	73 67                	jae    f01037cf <env_free+0x167>
		page_decref(pa2page(pa));
f0103768:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010376b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010376e:	8b 00                	mov    (%eax),%eax
f0103770:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103773:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103776:	50                   	push   %eax
f0103777:	e8 92 d8 ff ff       	call   f010100e <page_decref>
f010377c:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010377f:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0103783:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103786:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f010378b:	74 5a                	je     f01037e7 <env_free+0x17f>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010378d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103790:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103793:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103796:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f0103799:	a8 01                	test   $0x1,%al
f010379b:	74 e2                	je     f010377f <env_free+0x117>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010379d:	89 c7                	mov    %eax,%edi
f010379f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f01037a5:	c1 e8 0c             	shr    $0xc,%eax
f01037a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01037ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01037ae:	3b 02                	cmp    (%edx),%eax
f01037b0:	0f 83 50 ff ff ff    	jae    f0103706 <env_free+0x9e>
	return (void *)(pa + KERNBASE);
f01037b6:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f01037bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01037bf:	c1 e0 14             	shl    $0x14,%eax
f01037c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01037c5:	be 00 00 00 00       	mov    $0x0,%esi
f01037ca:	e9 61 ff ff ff       	jmp    f0103730 <env_free+0xc8>
		panic("pa2page called with invalid pa");
f01037cf:	83 ec 04             	sub    $0x4,%esp
f01037d2:	8d 83 b0 60 f8 ff    	lea    -0x79f50(%ebx),%eax
f01037d8:	50                   	push   %eax
f01037d9:	6a 4f                	push   $0x4f
f01037db:	8d 83 6d 67 f8 ff    	lea    -0x79893(%ebx),%eax
f01037e1:	50                   	push   %eax
f01037e2:	e8 ca c8 ff ff       	call   f01000b1 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01037e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01037ea:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01037ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037f2:	76 57                	jbe    f010384b <env_free+0x1e3>
	e->env_pgdir = 0;
f01037f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01037f7:	c7 41 5c 00 00 00 00 	movl   $0x0,0x5c(%ecx)
	return (physaddr_t)kva - KERNBASE;
f01037fe:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103803:	c1 e8 0c             	shr    $0xc,%eax
f0103806:	c7 c2 40 13 18 f0    	mov    $0xf0181340,%edx
f010380c:	3b 02                	cmp    (%edx),%eax
f010380e:	73 54                	jae    f0103864 <env_free+0x1fc>
	page_decref(pa2page(pa));
f0103810:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103813:	c7 c2 38 13 18 f0    	mov    $0xf0181338,%edx
f0103819:	8b 12                	mov    (%edx),%edx
f010381b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010381e:	50                   	push   %eax
f010381f:	e8 ea d7 ff ff       	call   f010100e <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103824:	8b 45 08             	mov    0x8(%ebp),%eax
f0103827:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f010382e:	8b 83 f4 1a 00 00    	mov    0x1af4(%ebx),%eax
f0103834:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103837:	89 41 44             	mov    %eax,0x44(%ecx)
	env_free_list = e;
f010383a:	89 8b f4 1a 00 00    	mov    %ecx,0x1af4(%ebx)
}
f0103840:	83 c4 10             	add    $0x10,%esp
f0103843:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103846:	5b                   	pop    %ebx
f0103847:	5e                   	pop    %esi
f0103848:	5f                   	pop    %edi
f0103849:	5d                   	pop    %ebp
f010384a:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010384b:	50                   	push   %eax
f010384c:	8d 83 68 60 f8 ff    	lea    -0x79f98(%ebx),%eax
f0103852:	50                   	push   %eax
f0103853:	68 cd 01 00 00       	push   $0x1cd
f0103858:	8d 83 61 6a f8 ff    	lea    -0x7959f(%ebx),%eax
f010385e:	50                   	push   %eax
f010385f:	e8 4d c8 ff ff       	call   f01000b1 <_panic>
		panic("pa2page called with invalid pa");
f0103864:	83 ec 04             	sub    $0x4,%esp
f0103867:	8d 83 b0 60 f8 ff    	lea    -0x79f50(%ebx),%eax
f010386d:	50                   	push   %eax
f010386e:	6a 4f                	push   $0x4f
f0103870:	8d 83 6d 67 f8 ff    	lea    -0x79893(%ebx),%eax
f0103876:	50                   	push   %eax
f0103877:	e8 35 c8 ff ff       	call   f01000b1 <_panic>

f010387c <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f010387c:	55                   	push   %ebp
f010387d:	89 e5                	mov    %esp,%ebp
f010387f:	53                   	push   %ebx
f0103880:	83 ec 10             	sub    $0x10,%esp
f0103883:	e8 df c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103888:	81 c3 e0 bf 07 00    	add    $0x7bfe0,%ebx
	env_free(e);
f010388e:	ff 75 08             	push   0x8(%ebp)
f0103891:	e8 d2 fd ff ff       	call   f0103668 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103896:	8d 83 34 6b f8 ff    	lea    -0x794cc(%ebx),%eax
f010389c:	89 04 24             	mov    %eax,(%esp)
f010389f:	e8 42 01 00 00       	call   f01039e6 <cprintf>
f01038a4:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f01038a7:	83 ec 0c             	sub    $0xc,%esp
f01038aa:	6a 00                	push   $0x0
f01038ac:	e8 77 cf ff ff       	call   f0100828 <monitor>
f01038b1:	83 c4 10             	add    $0x10,%esp
f01038b4:	eb f1                	jmp    f01038a7 <env_destroy+0x2b>

f01038b6 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01038b6:	55                   	push   %ebp
f01038b7:	89 e5                	mov    %esp,%ebp
f01038b9:	53                   	push   %ebx
f01038ba:	83 ec 08             	sub    $0x8,%esp
f01038bd:	e8 a5 c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01038c2:	81 c3 a6 bf 07 00    	add    $0x7bfa6,%ebx
	asm volatile(
f01038c8:	8b 65 08             	mov    0x8(%ebp),%esp
f01038cb:	61                   	popa   
f01038cc:	07                   	pop    %es
f01038cd:	1f                   	pop    %ds
f01038ce:	83 c4 08             	add    $0x8,%esp
f01038d1:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01038d2:	8d 83 e1 6a f8 ff    	lea    -0x7951f(%ebx),%eax
f01038d8:	50                   	push   %eax
f01038d9:	68 f6 01 00 00       	push   $0x1f6
f01038de:	8d 83 61 6a f8 ff    	lea    -0x7959f(%ebx),%eax
f01038e4:	50                   	push   %eax
f01038e5:	e8 c7 c7 ff ff       	call   f01000b1 <_panic>

f01038ea <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01038ea:	55                   	push   %ebp
f01038eb:	89 e5                	mov    %esp,%ebp
f01038ed:	53                   	push   %ebx
f01038ee:	83 ec 04             	sub    $0x4,%esp
f01038f1:	e8 71 c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01038f6:	81 c3 72 bf 07 00    	add    $0x7bf72,%ebx
f01038fc:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != NULL && curenv->env_status == ENV_RUNNING){
f01038ff:	8b 93 ec 1a 00 00    	mov    0x1aec(%ebx),%edx
f0103905:	85 d2                	test   %edx,%edx
f0103907:	74 06                	je     f010390f <env_run+0x25>
f0103909:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f010390d:	74 2e                	je     f010393d <env_run+0x53>
  	  	curenv->env_status = ENV_RUNNABLE;
  	}

  	curenv = e;
f010390f:	89 83 ec 1a 00 00    	mov    %eax,0x1aec(%ebx)
  	curenv->env_status = ENV_RUNNING;
f0103915:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
  	curenv->env_runs ++;
f010391c:	83 40 58 01          	addl   $0x1,0x58(%eax)
  	lcr3(PADDR(curenv->env_pgdir));
f0103920:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f0103923:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103929:	76 1b                	jbe    f0103946 <env_run+0x5c>
	return (physaddr_t)kva - KERNBASE;
f010392b:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103931:	0f 22 da             	mov    %edx,%cr3
  	env_pop_tf(&(curenv->env_tf));
f0103934:	83 ec 0c             	sub    $0xc,%esp
f0103937:	50                   	push   %eax
f0103938:	e8 79 ff ff ff       	call   f01038b6 <env_pop_tf>
  	  	curenv->env_status = ENV_RUNNABLE;
f010393d:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
f0103944:	eb c9                	jmp    f010390f <env_run+0x25>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103946:	52                   	push   %edx
f0103947:	8d 83 68 60 f8 ff    	lea    -0x79f98(%ebx),%eax
f010394d:	50                   	push   %eax
f010394e:	68 1b 02 00 00       	push   $0x21b
f0103953:	8d 83 61 6a f8 ff    	lea    -0x7959f(%ebx),%eax
f0103959:	50                   	push   %eax
f010395a:	e8 52 c7 ff ff       	call   f01000b1 <_panic>

f010395f <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010395f:	55                   	push   %ebp
f0103960:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103962:	8b 45 08             	mov    0x8(%ebp),%eax
f0103965:	ba 70 00 00 00       	mov    $0x70,%edx
f010396a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010396b:	ba 71 00 00 00       	mov    $0x71,%edx
f0103970:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103971:	0f b6 c0             	movzbl %al,%eax
}
f0103974:	5d                   	pop    %ebp
f0103975:	c3                   	ret    

f0103976 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103976:	55                   	push   %ebp
f0103977:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103979:	8b 45 08             	mov    0x8(%ebp),%eax
f010397c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103981:	ee                   	out    %al,(%dx)
f0103982:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103985:	ba 71 00 00 00       	mov    $0x71,%edx
f010398a:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010398b:	5d                   	pop    %ebp
f010398c:	c3                   	ret    

f010398d <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010398d:	55                   	push   %ebp
f010398e:	89 e5                	mov    %esp,%ebp
f0103990:	53                   	push   %ebx
f0103991:	83 ec 10             	sub    $0x10,%esp
f0103994:	e8 ce c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103999:	81 c3 cf be 07 00    	add    $0x7becf,%ebx
	cputchar(ch);
f010399f:	ff 75 08             	push   0x8(%ebp)
f01039a2:	e8 2b cd ff ff       	call   f01006d2 <cputchar>
	*cnt++;
}
f01039a7:	83 c4 10             	add    $0x10,%esp
f01039aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01039ad:	c9                   	leave  
f01039ae:	c3                   	ret    

f01039af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01039af:	55                   	push   %ebp
f01039b0:	89 e5                	mov    %esp,%ebp
f01039b2:	53                   	push   %ebx
f01039b3:	83 ec 14             	sub    $0x14,%esp
f01039b6:	e8 ac c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01039bb:	81 c3 ad be 07 00    	add    $0x7bead,%ebx
	int cnt = 0;
f01039c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01039c8:	ff 75 0c             	push   0xc(%ebp)
f01039cb:	ff 75 08             	push   0x8(%ebp)
f01039ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01039d1:	50                   	push   %eax
f01039d2:	8d 83 25 41 f8 ff    	lea    -0x7bedb(%ebx),%eax
f01039d8:	50                   	push   %eax
f01039d9:	e8 c2 0d 00 00       	call   f01047a0 <vprintfmt>
	return cnt;
}
f01039de:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01039e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01039e4:	c9                   	leave  
f01039e5:	c3                   	ret    

f01039e6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01039e6:	55                   	push   %ebp
f01039e7:	89 e5                	mov    %esp,%ebp
f01039e9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01039ec:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01039ef:	50                   	push   %eax
f01039f0:	ff 75 08             	push   0x8(%ebp)
f01039f3:	e8 b7 ff ff ff       	call   f01039af <vcprintf>
	va_end(ap);

	return cnt;
}
f01039f8:	c9                   	leave  
f01039f9:	c3                   	ret    

f01039fa <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01039fa:	55                   	push   %ebp
f01039fb:	89 e5                	mov    %esp,%ebp
f01039fd:	57                   	push   %edi
f01039fe:	56                   	push   %esi
f01039ff:	53                   	push   %ebx
f0103a00:	83 ec 04             	sub    $0x4,%esp
f0103a03:	e8 5f c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103a08:	81 c3 60 be 07 00    	add    $0x7be60,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103a0e:	c7 83 1c 23 00 00 00 	movl   $0xf0000000,0x231c(%ebx)
f0103a15:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103a18:	66 c7 83 20 23 00 00 	movw   $0x10,0x2320(%ebx)
f0103a1f:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103a21:	66 c7 83 7e 23 00 00 	movw   $0x68,0x237e(%ebx)
f0103a28:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103a2a:	c7 c0 00 c3 11 f0    	mov    $0xf011c300,%eax
f0103a30:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f0103a36:	8d b3 18 23 00 00    	lea    0x2318(%ebx),%esi
f0103a3c:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103a40:	89 f2                	mov    %esi,%edx
f0103a42:	c1 ea 10             	shr    $0x10,%edx
f0103a45:	88 50 2c             	mov    %dl,0x2c(%eax)
f0103a48:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f0103a4c:	83 e2 f0             	and    $0xfffffff0,%edx
f0103a4f:	83 ca 09             	or     $0x9,%edx
f0103a52:	83 e2 9f             	and    $0xffffff9f,%edx
f0103a55:	83 ca 80             	or     $0xffffff80,%edx
f0103a58:	88 55 f3             	mov    %dl,-0xd(%ebp)
f0103a5b:	88 50 2d             	mov    %dl,0x2d(%eax)
f0103a5e:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f0103a62:	83 e1 c0             	and    $0xffffffc0,%ecx
f0103a65:	83 c9 40             	or     $0x40,%ecx
f0103a68:	83 e1 7f             	and    $0x7f,%ecx
f0103a6b:	88 48 2e             	mov    %cl,0x2e(%eax)
f0103a6e:	c1 ee 18             	shr    $0x18,%esi
f0103a71:	89 f1                	mov    %esi,%ecx
f0103a73:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103a76:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f0103a7a:	83 e2 ef             	and    $0xffffffef,%edx
f0103a7d:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f0103a80:	b8 28 00 00 00       	mov    $0x28,%eax
f0103a85:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103a88:	8d 83 a0 17 00 00    	lea    0x17a0(%ebx),%eax
f0103a8e:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103a91:	83 c4 04             	add    $0x4,%esp
f0103a94:	5b                   	pop    %ebx
f0103a95:	5e                   	pop    %esi
f0103a96:	5f                   	pop    %edi
f0103a97:	5d                   	pop    %ebp
f0103a98:	c3                   	ret    

f0103a99 <trap_init>:
{
f0103a99:	55                   	push   %ebp
f0103a9a:	89 e5                	mov    %esp,%ebp
f0103a9c:	e8 58 cc ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0103aa1:	05 c7 bd 07 00       	add    $0x7bdc7,%eax
	SETGATE(idt[T_DIVIDE], 0, GD_KT, divide_handler, 0);
f0103aa6:	c7 c2 66 42 10 f0    	mov    $0xf0104266,%edx
f0103aac:	66 89 90 f8 1a 00 00 	mov    %dx,0x1af8(%eax)
f0103ab3:	66 c7 80 fa 1a 00 00 	movw   $0x8,0x1afa(%eax)
f0103aba:	08 00 
f0103abc:	c6 80 fc 1a 00 00 00 	movb   $0x0,0x1afc(%eax)
f0103ac3:	c6 80 fd 1a 00 00 8e 	movb   $0x8e,0x1afd(%eax)
f0103aca:	c1 ea 10             	shr    $0x10,%edx
f0103acd:	66 89 90 fe 1a 00 00 	mov    %dx,0x1afe(%eax)
  	SETGATE(idt[T_DEBUG], 0, GD_KT, debug_handler, 0);
f0103ad4:	c7 c2 6c 42 10 f0    	mov    $0xf010426c,%edx
f0103ada:	66 89 90 00 1b 00 00 	mov    %dx,0x1b00(%eax)
f0103ae1:	66 c7 80 02 1b 00 00 	movw   $0x8,0x1b02(%eax)
f0103ae8:	08 00 
f0103aea:	c6 80 04 1b 00 00 00 	movb   $0x0,0x1b04(%eax)
f0103af1:	c6 80 05 1b 00 00 8e 	movb   $0x8e,0x1b05(%eax)
f0103af8:	c1 ea 10             	shr    $0x10,%edx
f0103afb:	66 89 90 06 1b 00 00 	mov    %dx,0x1b06(%eax)
  	SETGATE(idt[T_NMI], 0, GD_KT, nmi_handler, 0);
f0103b02:	c7 c2 72 42 10 f0    	mov    $0xf0104272,%edx
f0103b08:	66 89 90 08 1b 00 00 	mov    %dx,0x1b08(%eax)
f0103b0f:	66 c7 80 0a 1b 00 00 	movw   $0x8,0x1b0a(%eax)
f0103b16:	08 00 
f0103b18:	c6 80 0c 1b 00 00 00 	movb   $0x0,0x1b0c(%eax)
f0103b1f:	c6 80 0d 1b 00 00 8e 	movb   $0x8e,0x1b0d(%eax)
f0103b26:	c1 ea 10             	shr    $0x10,%edx
f0103b29:	66 89 90 0e 1b 00 00 	mov    %dx,0x1b0e(%eax)
  	SETGATE(idt[T_BRKPT], 0, GD_KT, brkpt_handler, 3);
f0103b30:	c7 c2 78 42 10 f0    	mov    $0xf0104278,%edx
f0103b36:	66 89 90 10 1b 00 00 	mov    %dx,0x1b10(%eax)
f0103b3d:	66 c7 80 12 1b 00 00 	movw   $0x8,0x1b12(%eax)
f0103b44:	08 00 
f0103b46:	c6 80 14 1b 00 00 00 	movb   $0x0,0x1b14(%eax)
f0103b4d:	c6 80 15 1b 00 00 ee 	movb   $0xee,0x1b15(%eax)
f0103b54:	c1 ea 10             	shr    $0x10,%edx
f0103b57:	66 89 90 16 1b 00 00 	mov    %dx,0x1b16(%eax)
  	SETGATE(idt[T_OFLOW], 0, GD_KT, oflow_handler, 0);
f0103b5e:	c7 c2 7e 42 10 f0    	mov    $0xf010427e,%edx
f0103b64:	66 89 90 18 1b 00 00 	mov    %dx,0x1b18(%eax)
f0103b6b:	66 c7 80 1a 1b 00 00 	movw   $0x8,0x1b1a(%eax)
f0103b72:	08 00 
f0103b74:	c6 80 1c 1b 00 00 00 	movb   $0x0,0x1b1c(%eax)
f0103b7b:	c6 80 1d 1b 00 00 8e 	movb   $0x8e,0x1b1d(%eax)
f0103b82:	c1 ea 10             	shr    $0x10,%edx
f0103b85:	66 89 90 1e 1b 00 00 	mov    %dx,0x1b1e(%eax)
  	SETGATE(idt[T_BOUND], 0, GD_KT, bound_handler, 0);
f0103b8c:	c7 c2 84 42 10 f0    	mov    $0xf0104284,%edx
f0103b92:	66 89 90 20 1b 00 00 	mov    %dx,0x1b20(%eax)
f0103b99:	66 c7 80 22 1b 00 00 	movw   $0x8,0x1b22(%eax)
f0103ba0:	08 00 
f0103ba2:	c6 80 24 1b 00 00 00 	movb   $0x0,0x1b24(%eax)
f0103ba9:	c6 80 25 1b 00 00 8e 	movb   $0x8e,0x1b25(%eax)
f0103bb0:	c1 ea 10             	shr    $0x10,%edx
f0103bb3:	66 89 90 26 1b 00 00 	mov    %dx,0x1b26(%eax)
  	SETGATE(idt[T_ILLOP], 0, GD_KT, illop_handler, 0);
f0103bba:	c7 c2 8a 42 10 f0    	mov    $0xf010428a,%edx
f0103bc0:	66 89 90 28 1b 00 00 	mov    %dx,0x1b28(%eax)
f0103bc7:	66 c7 80 2a 1b 00 00 	movw   $0x8,0x1b2a(%eax)
f0103bce:	08 00 
f0103bd0:	c6 80 2c 1b 00 00 00 	movb   $0x0,0x1b2c(%eax)
f0103bd7:	c6 80 2d 1b 00 00 8e 	movb   $0x8e,0x1b2d(%eax)
f0103bde:	c1 ea 10             	shr    $0x10,%edx
f0103be1:	66 89 90 2e 1b 00 00 	mov    %dx,0x1b2e(%eax)
  	SETGATE(idt[T_DEVICE], 0, GD_KT, device_handler, 0);
f0103be8:	c7 c2 90 42 10 f0    	mov    $0xf0104290,%edx
f0103bee:	66 89 90 30 1b 00 00 	mov    %dx,0x1b30(%eax)
f0103bf5:	66 c7 80 32 1b 00 00 	movw   $0x8,0x1b32(%eax)
f0103bfc:	08 00 
f0103bfe:	c6 80 34 1b 00 00 00 	movb   $0x0,0x1b34(%eax)
f0103c05:	c6 80 35 1b 00 00 8e 	movb   $0x8e,0x1b35(%eax)
f0103c0c:	c1 ea 10             	shr    $0x10,%edx
f0103c0f:	66 89 90 36 1b 00 00 	mov    %dx,0x1b36(%eax)
  	SETGATE(idt[T_DBLFLT], 0, GD_KT, dblflt_handler, 0);
f0103c16:	c7 c2 96 42 10 f0    	mov    $0xf0104296,%edx
f0103c1c:	66 89 90 38 1b 00 00 	mov    %dx,0x1b38(%eax)
f0103c23:	66 c7 80 3a 1b 00 00 	movw   $0x8,0x1b3a(%eax)
f0103c2a:	08 00 
f0103c2c:	c6 80 3c 1b 00 00 00 	movb   $0x0,0x1b3c(%eax)
f0103c33:	c6 80 3d 1b 00 00 8e 	movb   $0x8e,0x1b3d(%eax)
f0103c3a:	c1 ea 10             	shr    $0x10,%edx
f0103c3d:	66 89 90 3e 1b 00 00 	mov    %dx,0x1b3e(%eax)
  	SETGATE(idt[T_TSS], 0, GD_KT, tss_handler, 0);
f0103c44:	c7 c2 9a 42 10 f0    	mov    $0xf010429a,%edx
f0103c4a:	66 89 90 48 1b 00 00 	mov    %dx,0x1b48(%eax)
f0103c51:	66 c7 80 4a 1b 00 00 	movw   $0x8,0x1b4a(%eax)
f0103c58:	08 00 
f0103c5a:	c6 80 4c 1b 00 00 00 	movb   $0x0,0x1b4c(%eax)
f0103c61:	c6 80 4d 1b 00 00 8e 	movb   $0x8e,0x1b4d(%eax)
f0103c68:	c1 ea 10             	shr    $0x10,%edx
f0103c6b:	66 89 90 4e 1b 00 00 	mov    %dx,0x1b4e(%eax)
  	SETGATE(idt[T_SEGNP], 0, GD_KT, segnp_handler, 0);
f0103c72:	c7 c2 9e 42 10 f0    	mov    $0xf010429e,%edx
f0103c78:	66 89 90 50 1b 00 00 	mov    %dx,0x1b50(%eax)
f0103c7f:	66 c7 80 52 1b 00 00 	movw   $0x8,0x1b52(%eax)
f0103c86:	08 00 
f0103c88:	c6 80 54 1b 00 00 00 	movb   $0x0,0x1b54(%eax)
f0103c8f:	c6 80 55 1b 00 00 8e 	movb   $0x8e,0x1b55(%eax)
f0103c96:	c1 ea 10             	shr    $0x10,%edx
f0103c99:	66 89 90 56 1b 00 00 	mov    %dx,0x1b56(%eax)
  	SETGATE(idt[T_STACK], 0, GD_KT, stack_handler, 0);
f0103ca0:	c7 c2 a2 42 10 f0    	mov    $0xf01042a2,%edx
f0103ca6:	66 89 90 58 1b 00 00 	mov    %dx,0x1b58(%eax)
f0103cad:	66 c7 80 5a 1b 00 00 	movw   $0x8,0x1b5a(%eax)
f0103cb4:	08 00 
f0103cb6:	c6 80 5c 1b 00 00 00 	movb   $0x0,0x1b5c(%eax)
f0103cbd:	c6 80 5d 1b 00 00 8e 	movb   $0x8e,0x1b5d(%eax)
f0103cc4:	c1 ea 10             	shr    $0x10,%edx
f0103cc7:	66 89 90 5e 1b 00 00 	mov    %dx,0x1b5e(%eax)
  	SETGATE(idt[T_GPFLT], 0, GD_KT, gpflt_handler, 0);
f0103cce:	c7 c2 a6 42 10 f0    	mov    $0xf01042a6,%edx
f0103cd4:	66 89 90 60 1b 00 00 	mov    %dx,0x1b60(%eax)
f0103cdb:	66 c7 80 62 1b 00 00 	movw   $0x8,0x1b62(%eax)
f0103ce2:	08 00 
f0103ce4:	c6 80 64 1b 00 00 00 	movb   $0x0,0x1b64(%eax)
f0103ceb:	c6 80 65 1b 00 00 8e 	movb   $0x8e,0x1b65(%eax)
f0103cf2:	c1 ea 10             	shr    $0x10,%edx
f0103cf5:	66 89 90 66 1b 00 00 	mov    %dx,0x1b66(%eax)
  	SETGATE(idt[T_PGFLT], 0, GD_KT, pgflt_handler, 0);
f0103cfc:	c7 c2 aa 42 10 f0    	mov    $0xf01042aa,%edx
f0103d02:	66 89 90 68 1b 00 00 	mov    %dx,0x1b68(%eax)
f0103d09:	66 c7 80 6a 1b 00 00 	movw   $0x8,0x1b6a(%eax)
f0103d10:	08 00 
f0103d12:	c6 80 6c 1b 00 00 00 	movb   $0x0,0x1b6c(%eax)
f0103d19:	c6 80 6d 1b 00 00 8e 	movb   $0x8e,0x1b6d(%eax)
f0103d20:	c1 ea 10             	shr    $0x10,%edx
f0103d23:	66 89 90 6e 1b 00 00 	mov    %dx,0x1b6e(%eax)
  	SETGATE(idt[T_FPERR], 0, GD_KT, fperr_handler, 0);
f0103d2a:	c7 c2 ae 42 10 f0    	mov    $0xf01042ae,%edx
f0103d30:	66 89 90 78 1b 00 00 	mov    %dx,0x1b78(%eax)
f0103d37:	66 c7 80 7a 1b 00 00 	movw   $0x8,0x1b7a(%eax)
f0103d3e:	08 00 
f0103d40:	c6 80 7c 1b 00 00 00 	movb   $0x0,0x1b7c(%eax)
f0103d47:	c6 80 7d 1b 00 00 8e 	movb   $0x8e,0x1b7d(%eax)
f0103d4e:	c1 ea 10             	shr    $0x10,%edx
f0103d51:	66 89 90 7e 1b 00 00 	mov    %dx,0x1b7e(%eax)
  	SETGATE(idt[T_ALIGN], 0, GD_KT, align_handler, 0);
f0103d58:	c7 c2 b4 42 10 f0    	mov    $0xf01042b4,%edx
f0103d5e:	66 89 90 80 1b 00 00 	mov    %dx,0x1b80(%eax)
f0103d65:	66 c7 80 82 1b 00 00 	movw   $0x8,0x1b82(%eax)
f0103d6c:	08 00 
f0103d6e:	c6 80 84 1b 00 00 00 	movb   $0x0,0x1b84(%eax)
f0103d75:	c6 80 85 1b 00 00 8e 	movb   $0x8e,0x1b85(%eax)
f0103d7c:	c1 ea 10             	shr    $0x10,%edx
f0103d7f:	66 89 90 86 1b 00 00 	mov    %dx,0x1b86(%eax)
  	SETGATE(idt[T_MCHK], 0, GD_KT, mchk_handler, 0);
f0103d86:	c7 c2 ba 42 10 f0    	mov    $0xf01042ba,%edx
f0103d8c:	66 89 90 88 1b 00 00 	mov    %dx,0x1b88(%eax)
f0103d93:	66 c7 80 8a 1b 00 00 	movw   $0x8,0x1b8a(%eax)
f0103d9a:	08 00 
f0103d9c:	c6 80 8c 1b 00 00 00 	movb   $0x0,0x1b8c(%eax)
f0103da3:	c6 80 8d 1b 00 00 8e 	movb   $0x8e,0x1b8d(%eax)
f0103daa:	c1 ea 10             	shr    $0x10,%edx
f0103dad:	66 89 90 8e 1b 00 00 	mov    %dx,0x1b8e(%eax)
  	SETGATE(idt[T_SIMDERR], 0, GD_KT, simderr_handler, 0);
f0103db4:	c7 c2 c0 42 10 f0    	mov    $0xf01042c0,%edx
f0103dba:	66 89 90 90 1b 00 00 	mov    %dx,0x1b90(%eax)
f0103dc1:	66 c7 80 92 1b 00 00 	movw   $0x8,0x1b92(%eax)
f0103dc8:	08 00 
f0103dca:	c6 80 94 1b 00 00 00 	movb   $0x0,0x1b94(%eax)
f0103dd1:	c6 80 95 1b 00 00 8e 	movb   $0x8e,0x1b95(%eax)
f0103dd8:	c1 ea 10             	shr    $0x10,%edx
f0103ddb:	66 89 90 96 1b 00 00 	mov    %dx,0x1b96(%eax)
  	SETGATE(idt[T_SYSCALL], 0, GD_KT, syscall_handler, 3);
f0103de2:	c7 c2 c6 42 10 f0    	mov    $0xf01042c6,%edx
f0103de8:	66 89 90 78 1c 00 00 	mov    %dx,0x1c78(%eax)
f0103def:	66 c7 80 7a 1c 00 00 	movw   $0x8,0x1c7a(%eax)
f0103df6:	08 00 
f0103df8:	c6 80 7c 1c 00 00 00 	movb   $0x0,0x1c7c(%eax)
f0103dff:	c6 80 7d 1c 00 00 ee 	movb   $0xee,0x1c7d(%eax)
f0103e06:	c1 ea 10             	shr    $0x10,%edx
f0103e09:	66 89 90 7e 1c 00 00 	mov    %dx,0x1c7e(%eax)
	trap_init_percpu();
f0103e10:	e8 e5 fb ff ff       	call   f01039fa <trap_init_percpu>
}
f0103e15:	5d                   	pop    %ebp
f0103e16:	c3                   	ret    

f0103e17 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e17:	55                   	push   %ebp
f0103e18:	89 e5                	mov    %esp,%ebp
f0103e1a:	56                   	push   %esi
f0103e1b:	53                   	push   %ebx
f0103e1c:	e8 46 c3 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103e21:	81 c3 47 ba 07 00    	add    $0x7ba47,%ebx
f0103e27:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e2a:	83 ec 08             	sub    $0x8,%esp
f0103e2d:	ff 36                	push   (%esi)
f0103e2f:	8d 83 6a 6b f8 ff    	lea    -0x79496(%ebx),%eax
f0103e35:	50                   	push   %eax
f0103e36:	e8 ab fb ff ff       	call   f01039e6 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e3b:	83 c4 08             	add    $0x8,%esp
f0103e3e:	ff 76 04             	push   0x4(%esi)
f0103e41:	8d 83 79 6b f8 ff    	lea    -0x79487(%ebx),%eax
f0103e47:	50                   	push   %eax
f0103e48:	e8 99 fb ff ff       	call   f01039e6 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e4d:	83 c4 08             	add    $0x8,%esp
f0103e50:	ff 76 08             	push   0x8(%esi)
f0103e53:	8d 83 88 6b f8 ff    	lea    -0x79478(%ebx),%eax
f0103e59:	50                   	push   %eax
f0103e5a:	e8 87 fb ff ff       	call   f01039e6 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e5f:	83 c4 08             	add    $0x8,%esp
f0103e62:	ff 76 0c             	push   0xc(%esi)
f0103e65:	8d 83 97 6b f8 ff    	lea    -0x79469(%ebx),%eax
f0103e6b:	50                   	push   %eax
f0103e6c:	e8 75 fb ff ff       	call   f01039e6 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e71:	83 c4 08             	add    $0x8,%esp
f0103e74:	ff 76 10             	push   0x10(%esi)
f0103e77:	8d 83 a6 6b f8 ff    	lea    -0x7945a(%ebx),%eax
f0103e7d:	50                   	push   %eax
f0103e7e:	e8 63 fb ff ff       	call   f01039e6 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e83:	83 c4 08             	add    $0x8,%esp
f0103e86:	ff 76 14             	push   0x14(%esi)
f0103e89:	8d 83 b5 6b f8 ff    	lea    -0x7944b(%ebx),%eax
f0103e8f:	50                   	push   %eax
f0103e90:	e8 51 fb ff ff       	call   f01039e6 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e95:	83 c4 08             	add    $0x8,%esp
f0103e98:	ff 76 18             	push   0x18(%esi)
f0103e9b:	8d 83 c4 6b f8 ff    	lea    -0x7943c(%ebx),%eax
f0103ea1:	50                   	push   %eax
f0103ea2:	e8 3f fb ff ff       	call   f01039e6 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103ea7:	83 c4 08             	add    $0x8,%esp
f0103eaa:	ff 76 1c             	push   0x1c(%esi)
f0103ead:	8d 83 d3 6b f8 ff    	lea    -0x7942d(%ebx),%eax
f0103eb3:	50                   	push   %eax
f0103eb4:	e8 2d fb ff ff       	call   f01039e6 <cprintf>
}
f0103eb9:	83 c4 10             	add    $0x10,%esp
f0103ebc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103ebf:	5b                   	pop    %ebx
f0103ec0:	5e                   	pop    %esi
f0103ec1:	5d                   	pop    %ebp
f0103ec2:	c3                   	ret    

f0103ec3 <print_trapframe>:
{
f0103ec3:	55                   	push   %ebp
f0103ec4:	89 e5                	mov    %esp,%ebp
f0103ec6:	57                   	push   %edi
f0103ec7:	56                   	push   %esi
f0103ec8:	53                   	push   %ebx
f0103ec9:	83 ec 14             	sub    $0x14,%esp
f0103ecc:	e8 96 c2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103ed1:	81 c3 97 b9 07 00    	add    $0x7b997,%ebx
f0103ed7:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0103eda:	56                   	push   %esi
f0103edb:	8d 83 24 6d f8 ff    	lea    -0x792dc(%ebx),%eax
f0103ee1:	50                   	push   %eax
f0103ee2:	e8 ff fa ff ff       	call   f01039e6 <cprintf>
	print_regs(&tf->tf_regs);
f0103ee7:	89 34 24             	mov    %esi,(%esp)
f0103eea:	e8 28 ff ff ff       	call   f0103e17 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103eef:	83 c4 08             	add    $0x8,%esp
f0103ef2:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0103ef6:	50                   	push   %eax
f0103ef7:	8d 83 24 6c f8 ff    	lea    -0x793dc(%ebx),%eax
f0103efd:	50                   	push   %eax
f0103efe:	e8 e3 fa ff ff       	call   f01039e6 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103f03:	83 c4 08             	add    $0x8,%esp
f0103f06:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f0103f0a:	50                   	push   %eax
f0103f0b:	8d 83 37 6c f8 ff    	lea    -0x793c9(%ebx),%eax
f0103f11:	50                   	push   %eax
f0103f12:	e8 cf fa ff ff       	call   f01039e6 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f17:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f0103f1a:	83 c4 10             	add    $0x10,%esp
f0103f1d:	83 fa 13             	cmp    $0x13,%edx
f0103f20:	0f 86 e2 00 00 00    	jbe    f0104008 <print_trapframe+0x145>
		return "System call";
f0103f26:	83 fa 30             	cmp    $0x30,%edx
f0103f29:	8d 83 e2 6b f8 ff    	lea    -0x7941e(%ebx),%eax
f0103f2f:	8d 8b f1 6b f8 ff    	lea    -0x7940f(%ebx),%ecx
f0103f35:	0f 44 c1             	cmove  %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f38:	83 ec 04             	sub    $0x4,%esp
f0103f3b:	50                   	push   %eax
f0103f3c:	52                   	push   %edx
f0103f3d:	8d 83 4a 6c f8 ff    	lea    -0x793b6(%ebx),%eax
f0103f43:	50                   	push   %eax
f0103f44:	e8 9d fa ff ff       	call   f01039e6 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f49:	83 c4 10             	add    $0x10,%esp
f0103f4c:	39 b3 f8 22 00 00    	cmp    %esi,0x22f8(%ebx)
f0103f52:	0f 84 bc 00 00 00    	je     f0104014 <print_trapframe+0x151>
	cprintf("  err  0x%08x", tf->tf_err);
f0103f58:	83 ec 08             	sub    $0x8,%esp
f0103f5b:	ff 76 2c             	push   0x2c(%esi)
f0103f5e:	8d 83 6b 6c f8 ff    	lea    -0x79395(%ebx),%eax
f0103f64:	50                   	push   %eax
f0103f65:	e8 7c fa ff ff       	call   f01039e6 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103f6a:	83 c4 10             	add    $0x10,%esp
f0103f6d:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103f71:	0f 85 c2 00 00 00    	jne    f0104039 <print_trapframe+0x176>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f77:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f0103f7a:	a8 01                	test   $0x1,%al
f0103f7c:	8d 8b fd 6b f8 ff    	lea    -0x79403(%ebx),%ecx
f0103f82:	8d 93 08 6c f8 ff    	lea    -0x793f8(%ebx),%edx
f0103f88:	0f 44 ca             	cmove  %edx,%ecx
f0103f8b:	a8 02                	test   $0x2,%al
f0103f8d:	8d 93 14 6c f8 ff    	lea    -0x793ec(%ebx),%edx
f0103f93:	8d bb 1a 6c f8 ff    	lea    -0x793e6(%ebx),%edi
f0103f99:	0f 44 d7             	cmove  %edi,%edx
f0103f9c:	a8 04                	test   $0x4,%al
f0103f9e:	8d 83 1f 6c f8 ff    	lea    -0x793e1(%ebx),%eax
f0103fa4:	8d bb 4f 6d f8 ff    	lea    -0x792b1(%ebx),%edi
f0103faa:	0f 44 c7             	cmove  %edi,%eax
f0103fad:	51                   	push   %ecx
f0103fae:	52                   	push   %edx
f0103faf:	50                   	push   %eax
f0103fb0:	8d 83 79 6c f8 ff    	lea    -0x79387(%ebx),%eax
f0103fb6:	50                   	push   %eax
f0103fb7:	e8 2a fa ff ff       	call   f01039e6 <cprintf>
f0103fbc:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103fbf:	83 ec 08             	sub    $0x8,%esp
f0103fc2:	ff 76 30             	push   0x30(%esi)
f0103fc5:	8d 83 88 6c f8 ff    	lea    -0x79378(%ebx),%eax
f0103fcb:	50                   	push   %eax
f0103fcc:	e8 15 fa ff ff       	call   f01039e6 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103fd1:	83 c4 08             	add    $0x8,%esp
f0103fd4:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103fd8:	50                   	push   %eax
f0103fd9:	8d 83 97 6c f8 ff    	lea    -0x79369(%ebx),%eax
f0103fdf:	50                   	push   %eax
f0103fe0:	e8 01 fa ff ff       	call   f01039e6 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103fe5:	83 c4 08             	add    $0x8,%esp
f0103fe8:	ff 76 38             	push   0x38(%esi)
f0103feb:	8d 83 aa 6c f8 ff    	lea    -0x79356(%ebx),%eax
f0103ff1:	50                   	push   %eax
f0103ff2:	e8 ef f9 ff ff       	call   f01039e6 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103ff7:	83 c4 10             	add    $0x10,%esp
f0103ffa:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0103ffe:	75 50                	jne    f0104050 <print_trapframe+0x18d>
}
f0104000:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104003:	5b                   	pop    %ebx
f0104004:	5e                   	pop    %esi
f0104005:	5f                   	pop    %edi
f0104006:	5d                   	pop    %ebp
f0104007:	c3                   	ret    
		return excnames[trapno];
f0104008:	8b 84 93 f8 17 00 00 	mov    0x17f8(%ebx,%edx,4),%eax
f010400f:	e9 24 ff ff ff       	jmp    f0103f38 <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104014:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0104018:	0f 85 3a ff ff ff    	jne    f0103f58 <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010401e:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104021:	83 ec 08             	sub    $0x8,%esp
f0104024:	50                   	push   %eax
f0104025:	8d 83 5c 6c f8 ff    	lea    -0x793a4(%ebx),%eax
f010402b:	50                   	push   %eax
f010402c:	e8 b5 f9 ff ff       	call   f01039e6 <cprintf>
f0104031:	83 c4 10             	add    $0x10,%esp
f0104034:	e9 1f ff ff ff       	jmp    f0103f58 <print_trapframe+0x95>
		cprintf("\n");
f0104039:	83 ec 0c             	sub    $0xc,%esp
f010403c:	8d 83 12 6a f8 ff    	lea    -0x795ee(%ebx),%eax
f0104042:	50                   	push   %eax
f0104043:	e8 9e f9 ff ff       	call   f01039e6 <cprintf>
f0104048:	83 c4 10             	add    $0x10,%esp
f010404b:	e9 6f ff ff ff       	jmp    f0103fbf <print_trapframe+0xfc>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104050:	83 ec 08             	sub    $0x8,%esp
f0104053:	ff 76 3c             	push   0x3c(%esi)
f0104056:	8d 83 b9 6c f8 ff    	lea    -0x79347(%ebx),%eax
f010405c:	50                   	push   %eax
f010405d:	e8 84 f9 ff ff       	call   f01039e6 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104062:	83 c4 08             	add    $0x8,%esp
f0104065:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0104069:	50                   	push   %eax
f010406a:	8d 83 c8 6c f8 ff    	lea    -0x79338(%ebx),%eax
f0104070:	50                   	push   %eax
f0104071:	e8 70 f9 ff ff       	call   f01039e6 <cprintf>
f0104076:	83 c4 10             	add    $0x10,%esp
}
f0104079:	eb 85                	jmp    f0104000 <print_trapframe+0x13d>

f010407b <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010407b:	55                   	push   %ebp
f010407c:	89 e5                	mov    %esp,%ebp
f010407e:	57                   	push   %edi
f010407f:	56                   	push   %esi
f0104080:	53                   	push   %ebx
f0104081:	83 ec 0c             	sub    $0xc,%esp
f0104084:	e8 de c0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104089:	81 c3 df b7 07 00    	add    $0x7b7df,%ebx
f010408f:	8b 75 08             	mov    0x8(%ebp),%esi
f0104092:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (!(tf->tf_cs && 0x3)) {
f0104095:	66 83 7e 34 00       	cmpw   $0x0,0x34(%esi)
f010409a:	74 38                	je     f01040d4 <page_fault_handler+0x59>
	}
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010409c:	ff 76 30             	push   0x30(%esi)
f010409f:	50                   	push   %eax
f01040a0:	c7 c7 54 13 18 f0    	mov    $0xf0181354,%edi
f01040a6:	8b 07                	mov    (%edi),%eax
f01040a8:	ff 70 48             	push   0x48(%eax)
f01040ab:	8d 83 9c 6e f8 ff    	lea    -0x79164(%ebx),%eax
f01040b1:	50                   	push   %eax
f01040b2:	e8 2f f9 ff ff       	call   f01039e6 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01040b7:	89 34 24             	mov    %esi,(%esp)
f01040ba:	e8 04 fe ff ff       	call   f0103ec3 <print_trapframe>
	env_destroy(curenv);
f01040bf:	83 c4 04             	add    $0x4,%esp
f01040c2:	ff 37                	push   (%edi)
f01040c4:	e8 b3 f7 ff ff       	call   f010387c <env_destroy>
}
f01040c9:	83 c4 10             	add    $0x10,%esp
f01040cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040cf:	5b                   	pop    %ebx
f01040d0:	5e                   	pop    %esi
f01040d1:	5f                   	pop    %edi
f01040d2:	5d                   	pop    %ebp
f01040d3:	c3                   	ret    
		panic("page faults in kernel mode");
f01040d4:	83 ec 04             	sub    $0x4,%esp
f01040d7:	8d 83 db 6c f8 ff    	lea    -0x79325(%ebx),%eax
f01040dd:	50                   	push   %eax
f01040de:	68 08 01 00 00       	push   $0x108
f01040e3:	8d 83 f6 6c f8 ff    	lea    -0x7930a(%ebx),%eax
f01040e9:	50                   	push   %eax
f01040ea:	e8 c2 bf ff ff       	call   f01000b1 <_panic>

f01040ef <trap>:
{
f01040ef:	55                   	push   %ebp
f01040f0:	89 e5                	mov    %esp,%ebp
f01040f2:	57                   	push   %edi
f01040f3:	56                   	push   %esi
f01040f4:	53                   	push   %ebx
f01040f5:	83 ec 0c             	sub    $0xc,%esp
f01040f8:	e8 6a c0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01040fd:	81 c3 6b b7 07 00    	add    $0x7b76b,%ebx
f0104103:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0104106:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104107:	9c                   	pushf  
f0104108:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104109:	f6 c4 02             	test   $0x2,%ah
f010410c:	74 1f                	je     f010412d <trap+0x3e>
f010410e:	8d 83 02 6d f8 ff    	lea    -0x792fe(%ebx),%eax
f0104114:	50                   	push   %eax
f0104115:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f010411b:	50                   	push   %eax
f010411c:	68 df 00 00 00       	push   $0xdf
f0104121:	8d 83 f6 6c f8 ff    	lea    -0x7930a(%ebx),%eax
f0104127:	50                   	push   %eax
f0104128:	e8 84 bf ff ff       	call   f01000b1 <_panic>
	cprintf("Incoming TRAP frame at %p\n", tf);
f010412d:	83 ec 08             	sub    $0x8,%esp
f0104130:	56                   	push   %esi
f0104131:	8d 83 1b 6d f8 ff    	lea    -0x792e5(%ebx),%eax
f0104137:	50                   	push   %eax
f0104138:	e8 a9 f8 ff ff       	call   f01039e6 <cprintf>
	if ((tf->tf_cs & 3) == 3) {
f010413d:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104141:	83 e0 03             	and    $0x3,%eax
f0104144:	83 c4 10             	add    $0x10,%esp
f0104147:	66 83 f8 03          	cmp    $0x3,%ax
f010414b:	75 1d                	jne    f010416a <trap+0x7b>
		assert(curenv);
f010414d:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f0104153:	8b 00                	mov    (%eax),%eax
f0104155:	85 c0                	test   %eax,%eax
f0104157:	74 5d                	je     f01041b6 <trap+0xc7>
		curenv->env_tf = *tf;
f0104159:	b9 11 00 00 00       	mov    $0x11,%ecx
f010415e:	89 c7                	mov    %eax,%edi
f0104160:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104162:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f0104168:	8b 30                	mov    (%eax),%esi
	last_tf = tf;
f010416a:	89 b3 f8 22 00 00    	mov    %esi,0x22f8(%ebx)
	switch(tf->tf_trapno) {
f0104170:	8b 46 28             	mov    0x28(%esi),%eax
f0104173:	83 f8 0e             	cmp    $0xe,%eax
f0104176:	74 5d                	je     f01041d5 <trap+0xe6>
f0104178:	83 f8 30             	cmp    $0x30,%eax
f010417b:	0f 84 9f 00 00 00    	je     f0104220 <trap+0x131>
f0104181:	83 f8 03             	cmp    $0x3,%eax
f0104184:	0f 84 88 00 00 00    	je     f0104212 <trap+0x123>
			print_trapframe(tf);
f010418a:	83 ec 0c             	sub    $0xc,%esp
f010418d:	56                   	push   %esi
f010418e:	e8 30 fd ff ff       	call   f0103ec3 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0104193:	83 c4 10             	add    $0x10,%esp
f0104196:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010419b:	0f 84 a0 00 00 00    	je     f0104241 <trap+0x152>
				env_destroy(curenv);
f01041a1:	83 ec 0c             	sub    $0xc,%esp
f01041a4:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f01041aa:	ff 30                	push   (%eax)
f01041ac:	e8 cb f6 ff ff       	call   f010387c <env_destroy>
				return;
f01041b1:	83 c4 10             	add    $0x10,%esp
f01041b4:	eb 2b                	jmp    f01041e1 <trap+0xf2>
		assert(curenv);
f01041b6:	8d 83 36 6d f8 ff    	lea    -0x792ca(%ebx),%eax
f01041bc:	50                   	push   %eax
f01041bd:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f01041c3:	50                   	push   %eax
f01041c4:	68 e5 00 00 00       	push   $0xe5
f01041c9:	8d 83 f6 6c f8 ff    	lea    -0x7930a(%ebx),%eax
f01041cf:	50                   	push   %eax
f01041d0:	e8 dc be ff ff       	call   f01000b1 <_panic>
			page_fault_handler(tf);
f01041d5:	83 ec 0c             	sub    $0xc,%esp
f01041d8:	56                   	push   %esi
f01041d9:	e8 9d fe ff ff       	call   f010407b <page_fault_handler>
			break;
f01041de:	83 c4 10             	add    $0x10,%esp
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01041e1:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f01041e7:	8b 00                	mov    (%eax),%eax
f01041e9:	85 c0                	test   %eax,%eax
f01041eb:	74 06                	je     f01041f3 <trap+0x104>
f01041ed:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01041f1:	74 69                	je     f010425c <trap+0x16d>
f01041f3:	8d 83 c0 6e f8 ff    	lea    -0x79140(%ebx),%eax
f01041f9:	50                   	push   %eax
f01041fa:	8d 83 87 67 f8 ff    	lea    -0x79879(%ebx),%eax
f0104200:	50                   	push   %eax
f0104201:	68 f7 00 00 00       	push   $0xf7
f0104206:	8d 83 f6 6c f8 ff    	lea    -0x7930a(%ebx),%eax
f010420c:	50                   	push   %eax
f010420d:	e8 9f be ff ff       	call   f01000b1 <_panic>
			monitor(tf);		
f0104212:	83 ec 0c             	sub    $0xc,%esp
f0104215:	56                   	push   %esi
f0104216:	e8 0d c6 ff ff       	call   f0100828 <monitor>
			break;
f010421b:	83 c4 10             	add    $0x10,%esp
f010421e:	eb c1                	jmp    f01041e1 <trap+0xf2>
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
f0104220:	83 ec 08             	sub    $0x8,%esp
f0104223:	ff 76 04             	push   0x4(%esi)
f0104226:	ff 36                	push   (%esi)
f0104228:	ff 76 10             	push   0x10(%esi)
f010422b:	ff 76 18             	push   0x18(%esi)
f010422e:	ff 76 14             	push   0x14(%esi)
f0104231:	ff 76 1c             	push   0x1c(%esi)
f0104234:	e8 a5 00 00 00       	call   f01042de <syscall>
f0104239:	89 46 1c             	mov    %eax,0x1c(%esi)
			break;
f010423c:	83 c4 20             	add    $0x20,%esp
f010423f:	eb a0                	jmp    f01041e1 <trap+0xf2>
				panic("unhandled trap in kernel");
f0104241:	83 ec 04             	sub    $0x4,%esp
f0104244:	8d 83 3d 6d f8 ff    	lea    -0x792c3(%ebx),%eax
f010424a:	50                   	push   %eax
f010424b:	68 cd 00 00 00       	push   $0xcd
f0104250:	8d 83 f6 6c f8 ff    	lea    -0x7930a(%ebx),%eax
f0104256:	50                   	push   %eax
f0104257:	e8 55 be ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f010425c:	83 ec 0c             	sub    $0xc,%esp
f010425f:	50                   	push   %eax
f0104260:	e8 85 f6 ff ff       	call   f01038ea <env_run>
f0104265:	90                   	nop

f0104266 <divide_handler>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(divide_handler, T_DIVIDE);
f0104266:	6a 00                	push   $0x0
f0104268:	6a 00                	push   $0x0
f010426a:	eb 60                	jmp    f01042cc <_alltraps>

f010426c <debug_handler>:
TRAPHANDLER_NOEC(debug_handler, T_DEBUG);
f010426c:	6a 00                	push   $0x0
f010426e:	6a 01                	push   $0x1
f0104270:	eb 5a                	jmp    f01042cc <_alltraps>

f0104272 <nmi_handler>:
TRAPHANDLER_NOEC(nmi_handler, T_NMI)
f0104272:	6a 00                	push   $0x0
f0104274:	6a 02                	push   $0x2
f0104276:	eb 54                	jmp    f01042cc <_alltraps>

f0104278 <brkpt_handler>:
TRAPHANDLER_NOEC(brkpt_handler, T_BRKPT)
f0104278:	6a 00                	push   $0x0
f010427a:	6a 03                	push   $0x3
f010427c:	eb 4e                	jmp    f01042cc <_alltraps>

f010427e <oflow_handler>:
TRAPHANDLER_NOEC(oflow_handler, T_OFLOW)
f010427e:	6a 00                	push   $0x0
f0104280:	6a 04                	push   $0x4
f0104282:	eb 48                	jmp    f01042cc <_alltraps>

f0104284 <bound_handler>:
TRAPHANDLER_NOEC(bound_handler, T_BOUND)
f0104284:	6a 00                	push   $0x0
f0104286:	6a 05                	push   $0x5
f0104288:	eb 42                	jmp    f01042cc <_alltraps>

f010428a <illop_handler>:
TRAPHANDLER_NOEC(illop_handler, T_ILLOP)
f010428a:	6a 00                	push   $0x0
f010428c:	6a 06                	push   $0x6
f010428e:	eb 3c                	jmp    f01042cc <_alltraps>

f0104290 <device_handler>:
TRAPHANDLER_NOEC(device_handler, T_DEVICE)
f0104290:	6a 00                	push   $0x0
f0104292:	6a 07                	push   $0x7
f0104294:	eb 36                	jmp    f01042cc <_alltraps>

f0104296 <dblflt_handler>:
TRAPHANDLER(dblflt_handler, T_DBLFLT)
f0104296:	6a 08                	push   $0x8
f0104298:	eb 32                	jmp    f01042cc <_alltraps>

f010429a <tss_handler>:
TRAPHANDLER(tss_handler, T_TSS)
f010429a:	6a 0a                	push   $0xa
f010429c:	eb 2e                	jmp    f01042cc <_alltraps>

f010429e <segnp_handler>:
TRAPHANDLER(segnp_handler, T_SEGNP)
f010429e:	6a 0b                	push   $0xb
f01042a0:	eb 2a                	jmp    f01042cc <_alltraps>

f01042a2 <stack_handler>:
TRAPHANDLER(stack_handler, T_STACK)
f01042a2:	6a 0c                	push   $0xc
f01042a4:	eb 26                	jmp    f01042cc <_alltraps>

f01042a6 <gpflt_handler>:
TRAPHANDLER(gpflt_handler, T_GPFLT)
f01042a6:	6a 0d                	push   $0xd
f01042a8:	eb 22                	jmp    f01042cc <_alltraps>

f01042aa <pgflt_handler>:
TRAPHANDLER(pgflt_handler, T_PGFLT)
f01042aa:	6a 0e                	push   $0xe
f01042ac:	eb 1e                	jmp    f01042cc <_alltraps>

f01042ae <fperr_handler>:
TRAPHANDLER_NOEC(fperr_handler, T_FPERR)
f01042ae:	6a 00                	push   $0x0
f01042b0:	6a 10                	push   $0x10
f01042b2:	eb 18                	jmp    f01042cc <_alltraps>

f01042b4 <align_handler>:
TRAPHANDLER_NOEC(align_handler, T_ALIGN)
f01042b4:	6a 00                	push   $0x0
f01042b6:	6a 11                	push   $0x11
f01042b8:	eb 12                	jmp    f01042cc <_alltraps>

f01042ba <mchk_handler>:
TRAPHANDLER_NOEC(mchk_handler, T_MCHK)
f01042ba:	6a 00                	push   $0x0
f01042bc:	6a 12                	push   $0x12
f01042be:	eb 0c                	jmp    f01042cc <_alltraps>

f01042c0 <simderr_handler>:
TRAPHANDLER_NOEC(simderr_handler, T_SIMDERR)
f01042c0:	6a 00                	push   $0x0
f01042c2:	6a 13                	push   $0x13
f01042c4:	eb 06                	jmp    f01042cc <_alltraps>

f01042c6 <syscall_handler>:
TRAPHANDLER_NOEC(syscall_handler, T_SYSCALL)
f01042c6:	6a 00                	push   $0x0
f01042c8:	6a 30                	push   $0x30
f01042ca:	eb 00                	jmp    f01042cc <_alltraps>

f01042cc <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f01042cc:	1e                   	push   %ds
	pushl %es 
f01042cd:	06                   	push   %es
	pushal
f01042ce:	60                   	pusha  

	movl $GD_KD, %eax
f01042cf:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f01042d4:	8e d8                	mov    %eax,%ds
  	movl %eax, %es
f01042d6:	8e c0                	mov    %eax,%es
	pushl %esp
f01042d8:	54                   	push   %esp

f01042d9:	e8 11 fe ff ff       	call   f01040ef <trap>

f01042de <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01042de:	55                   	push   %ebp
f01042df:	89 e5                	mov    %esp,%ebp
f01042e1:	53                   	push   %ebx
f01042e2:	83 ec 14             	sub    $0x14,%esp
f01042e5:	e8 7d be ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01042ea:	81 c3 7e b5 07 00    	add    $0x7b57e,%ebx
f01042f0:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	int ret = 0;
	switch (syscallno) {
f01042f3:	83 f8 02             	cmp    $0x2,%eax
f01042f6:	0f 84 a7 00 00 00    	je     f01043a3 <syscall+0xc5>
f01042fc:	83 f8 02             	cmp    $0x2,%eax
f01042ff:	77 0b                	ja     f010430c <syscall+0x2e>
f0104301:	85 c0                	test   %eax,%eax
f0104303:	74 6a                	je     f010436f <syscall+0x91>
	return cons_getc();
f0104305:	e8 5f c2 ff ff       	call   f0100569 <cons_getc>
	case SYS_cputs:
		sys_cputs((const char*)a1, a2);
		break;
	case SYS_cgetc:
		ret = sys_cgetc();
		break;
f010430a:	eb 5e                	jmp    f010436a <syscall+0x8c>
	switch (syscallno) {
f010430c:	83 f8 03             	cmp    $0x3,%eax
f010430f:	75 54                	jne    f0104365 <syscall+0x87>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104311:	83 ec 04             	sub    $0x4,%esp
f0104314:	6a 01                	push   $0x1
f0104316:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104319:	50                   	push   %eax
f010431a:	ff 75 0c             	push   0xc(%ebp)
f010431d:	e8 dc ee ff ff       	call   f01031fe <envid2env>
f0104322:	83 c4 10             	add    $0x10,%esp
f0104325:	85 c0                	test   %eax,%eax
f0104327:	78 41                	js     f010436a <syscall+0x8c>
	if (e == curenv)
f0104329:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010432c:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f0104332:	8b 00                	mov    (%eax),%eax
f0104334:	39 c2                	cmp    %eax,%edx
f0104336:	74 78                	je     f01043b0 <syscall+0xd2>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104338:	83 ec 04             	sub    $0x4,%esp
f010433b:	ff 72 48             	push   0x48(%edx)
f010433e:	ff 70 48             	push   0x48(%eax)
f0104341:	8d 83 0c 6f f8 ff    	lea    -0x790f4(%ebx),%eax
f0104347:	50                   	push   %eax
f0104348:	e8 99 f6 ff ff       	call   f01039e6 <cprintf>
f010434d:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104350:	83 ec 0c             	sub    $0xc,%esp
f0104353:	ff 75 f4             	push   -0xc(%ebp)
f0104356:	e8 21 f5 ff ff       	call   f010387c <env_destroy>
	return 0;
f010435b:	83 c4 10             	add    $0x10,%esp
f010435e:	b8 00 00 00 00       	mov    $0x0,%eax
	case SYS_getenvid:
		ret = sys_getenvid();
		break;
	case SYS_env_destroy:
		ret = sys_env_destroy(a1);
		break;
f0104363:	eb 05                	jmp    f010436a <syscall+0x8c>
	switch (syscallno) {
f0104365:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	default:
		return -E_INVAL;
	}
	return ret;
}
f010436a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010436d:	c9                   	leave  
f010436e:	c3                   	ret    
	user_mem_assert(curenv, s, len, 0);
f010436f:	6a 00                	push   $0x0
f0104371:	ff 75 10             	push   0x10(%ebp)
f0104374:	ff 75 0c             	push   0xc(%ebp)
f0104377:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f010437d:	ff 30                	push   (%eax)
f010437f:	e8 79 ed ff ff       	call   f01030fd <user_mem_assert>
	cprintf("%.*s", len, s);
f0104384:	83 c4 0c             	add    $0xc,%esp
f0104387:	ff 75 0c             	push   0xc(%ebp)
f010438a:	ff 75 10             	push   0x10(%ebp)
f010438d:	8d 83 ec 6e f8 ff    	lea    -0x79114(%ebx),%eax
f0104393:	50                   	push   %eax
f0104394:	e8 4d f6 ff ff       	call   f01039e6 <cprintf>
}
f0104399:	83 c4 10             	add    $0x10,%esp
	int ret = 0;
f010439c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01043a1:	eb c7                	jmp    f010436a <syscall+0x8c>
	return curenv->env_id;
f01043a3:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f01043a9:	8b 00                	mov    (%eax),%eax
f01043ab:	8b 40 48             	mov    0x48(%eax),%eax
		break;
f01043ae:	eb ba                	jmp    f010436a <syscall+0x8c>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01043b0:	83 ec 08             	sub    $0x8,%esp
f01043b3:	ff 70 48             	push   0x48(%eax)
f01043b6:	8d 83 f1 6e f8 ff    	lea    -0x7910f(%ebx),%eax
f01043bc:	50                   	push   %eax
f01043bd:	e8 24 f6 ff ff       	call   f01039e6 <cprintf>
f01043c2:	83 c4 10             	add    $0x10,%esp
f01043c5:	eb 89                	jmp    f0104350 <syscall+0x72>

f01043c7 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01043c7:	55                   	push   %ebp
f01043c8:	89 e5                	mov    %esp,%ebp
f01043ca:	57                   	push   %edi
f01043cb:	56                   	push   %esi
f01043cc:	53                   	push   %ebx
f01043cd:	83 ec 14             	sub    $0x14,%esp
f01043d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01043d3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01043d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01043d9:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01043dc:	8b 1a                	mov    (%edx),%ebx
f01043de:	8b 01                	mov    (%ecx),%eax
f01043e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01043e3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01043ea:	eb 2f                	jmp    f010441b <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01043ec:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f01043ef:	39 c3                	cmp    %eax,%ebx
f01043f1:	7f 4e                	jg     f0104441 <stab_binsearch+0x7a>
f01043f3:	0f b6 0a             	movzbl (%edx),%ecx
f01043f6:	83 ea 0c             	sub    $0xc,%edx
f01043f9:	39 f1                	cmp    %esi,%ecx
f01043fb:	75 ef                	jne    f01043ec <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01043fd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104400:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104403:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104407:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010440a:	73 3a                	jae    f0104446 <stab_binsearch+0x7f>
			*region_left = m;
f010440c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010440f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104411:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104414:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f010441b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010441e:	7f 53                	jg     f0104473 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0104420:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104423:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0104426:	89 d0                	mov    %edx,%eax
f0104428:	c1 e8 1f             	shr    $0x1f,%eax
f010442b:	01 d0                	add    %edx,%eax
f010442d:	89 c7                	mov    %eax,%edi
f010442f:	d1 ff                	sar    %edi
f0104431:	83 e0 fe             	and    $0xfffffffe,%eax
f0104434:	01 f8                	add    %edi,%eax
f0104436:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104439:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f010443d:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f010443f:	eb ae                	jmp    f01043ef <stab_binsearch+0x28>
			l = true_m + 1;
f0104441:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104444:	eb d5                	jmp    f010441b <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104446:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104449:	76 14                	jbe    f010445f <stab_binsearch+0x98>
			*region_right = m - 1;
f010444b:	83 e8 01             	sub    $0x1,%eax
f010444e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104451:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104454:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104456:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010445d:	eb bc                	jmp    f010441b <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010445f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104462:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104464:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104468:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010446a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104471:	eb a8                	jmp    f010441b <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104473:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104477:	75 15                	jne    f010448e <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010447c:	8b 00                	mov    (%eax),%eax
f010447e:	83 e8 01             	sub    $0x1,%eax
f0104481:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104484:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104486:	83 c4 14             	add    $0x14,%esp
f0104489:	5b                   	pop    %ebx
f010448a:	5e                   	pop    %esi
f010448b:	5f                   	pop    %edi
f010448c:	5d                   	pop    %ebp
f010448d:	c3                   	ret    
		for (l = *region_right;
f010448e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104491:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104496:	8b 0f                	mov    (%edi),%ecx
f0104498:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010449b:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010449e:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01044a2:	39 c1                	cmp    %eax,%ecx
f01044a4:	7d 0f                	jge    f01044b5 <stab_binsearch+0xee>
f01044a6:	0f b6 1a             	movzbl (%edx),%ebx
f01044a9:	83 ea 0c             	sub    $0xc,%edx
f01044ac:	39 f3                	cmp    %esi,%ebx
f01044ae:	74 05                	je     f01044b5 <stab_binsearch+0xee>
		     l--)
f01044b0:	83 e8 01             	sub    $0x1,%eax
f01044b3:	eb ed                	jmp    f01044a2 <stab_binsearch+0xdb>
		*region_left = l;
f01044b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01044b8:	89 07                	mov    %eax,(%edi)
}
f01044ba:	eb ca                	jmp    f0104486 <stab_binsearch+0xbf>

f01044bc <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01044bc:	55                   	push   %ebp
f01044bd:	89 e5                	mov    %esp,%ebp
f01044bf:	57                   	push   %edi
f01044c0:	56                   	push   %esi
f01044c1:	53                   	push   %ebx
f01044c2:	83 ec 3c             	sub    $0x3c,%esp
f01044c5:	e8 9d bc ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01044ca:	81 c3 9e b3 07 00    	add    $0x7b39e,%ebx
f01044d0:	8b 75 08             	mov    0x8(%ebp),%esi
f01044d3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01044d6:	8d 83 24 6f f8 ff    	lea    -0x790dc(%ebx),%eax
f01044dc:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f01044de:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f01044e5:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f01044e8:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f01044ef:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f01044f2:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01044f9:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01044ff:	0f 87 ea 00 00 00    	ja     f01045ef <debuginfo_eip+0x133>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104505:	a1 00 00 20 00       	mov    0x200000,%eax
f010450a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f010450d:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104512:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104518:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f010451b:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104521:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104524:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104527:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f010452a:	0f 83 56 01 00 00    	jae    f0104686 <debuginfo_eip+0x1ca>
f0104530:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104534:	0f 85 53 01 00 00    	jne    f010468d <debuginfo_eip+0x1d1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010453a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104541:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0104544:	c1 f8 02             	sar    $0x2,%eax
f0104547:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010454d:	83 e8 01             	sub    $0x1,%eax
f0104550:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104553:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104556:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104559:	56                   	push   %esi
f010455a:	6a 64                	push   $0x64
f010455c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010455f:	e8 63 fe ff ff       	call   f01043c7 <stab_binsearch>
	if (lfile == 0)
f0104564:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104567:	83 c4 08             	add    $0x8,%esp
f010456a:	85 c9                	test   %ecx,%ecx
f010456c:	0f 84 22 01 00 00    	je     f0104694 <debuginfo_eip+0x1d8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104572:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0104575:	89 4d dc             	mov    %ecx,-0x24(%ebp)
	rfun = rfile;
f0104578:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010457b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010457e:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104581:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104584:	56                   	push   %esi
f0104585:	6a 24                	push   $0x24
f0104587:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010458a:	e8 38 fe ff ff       	call   f01043c7 <stab_binsearch>

	if (lfun <= rfun) {
f010458f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104592:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104595:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104598:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010459b:	83 c4 08             	add    $0x8,%esp
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
		lline = lfile;
f010459e:	8b 75 c8             	mov    -0x38(%ebp),%esi
	if (lfun <= rfun) {
f01045a1:	39 c2                	cmp    %eax,%edx
f01045a3:	7f 25                	jg     f01045ca <debuginfo_eip+0x10e>
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01045a5:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01045a8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01045ab:	8d 14 86             	lea    (%esi,%eax,4),%edx
f01045ae:	8b 02                	mov    (%edx),%eax
f01045b0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01045b3:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01045b6:	29 f1                	sub    %esi,%ecx
f01045b8:	39 c8                	cmp    %ecx,%eax
f01045ba:	73 05                	jae    f01045c1 <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01045bc:	01 f0                	add    %esi,%eax
f01045be:	89 47 08             	mov    %eax,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01045c1:	8b 42 08             	mov    0x8(%edx),%eax
f01045c4:	89 47 10             	mov    %eax,0x10(%edi)
		lline = lfun;
f01045c7:	8b 75 c4             	mov    -0x3c(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01045ca:	83 ec 08             	sub    $0x8,%esp
f01045cd:	6a 3a                	push   $0x3a
f01045cf:	ff 77 08             	push   0x8(%edi)
f01045d2:	e8 22 09 00 00       	call   f0104ef9 <strfind>
f01045d7:	2b 47 08             	sub    0x8(%edi),%eax
f01045da:	89 47 0c             	mov    %eax,0xc(%edi)
f01045dd:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01045e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01045e3:	8d 44 83 04          	lea    0x4(%ebx,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01045e7:	83 c4 10             	add    $0x10,%esp
f01045ea:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f01045ed:	eb 2c                	jmp    f010461b <debuginfo_eip+0x15f>
		stabstr_end = __STABSTR_END__;
f01045ef:	c7 c0 df 29 11 f0    	mov    $0xf01129df,%eax
f01045f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01045f8:	c7 c0 35 ed 10 f0    	mov    $0xf010ed35,%eax
f01045fe:	89 45 cc             	mov    %eax,-0x34(%ebp)
		stab_end = __STAB_END__;
f0104601:	c7 c0 34 ed 10 f0    	mov    $0xf010ed34,%eax
		stabs = __STAB_BEGIN__;
f0104607:	c7 c1 88 69 10 f0    	mov    $0xf0106988,%ecx
f010460d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104610:	e9 0f ff ff ff       	jmp    f0104524 <debuginfo_eip+0x68>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104615:	83 ee 01             	sub    $0x1,%esi
f0104618:	83 e8 0c             	sub    $0xc,%eax
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010461b:	39 f3                	cmp    %esi,%ebx
f010461d:	7f 2e                	jg     f010464d <debuginfo_eip+0x191>
	       && stabs[lline].n_type != N_SOL
f010461f:	0f b6 10             	movzbl (%eax),%edx
f0104622:	80 fa 84             	cmp    $0x84,%dl
f0104625:	74 0b                	je     f0104632 <debuginfo_eip+0x176>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104627:	80 fa 64             	cmp    $0x64,%dl
f010462a:	75 e9                	jne    f0104615 <debuginfo_eip+0x159>
f010462c:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0104630:	74 e3                	je     f0104615 <debuginfo_eip+0x159>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104632:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104635:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104638:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010463b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010463e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104641:	29 d8                	sub    %ebx,%eax
f0104643:	39 c2                	cmp    %eax,%edx
f0104645:	73 06                	jae    f010464d <debuginfo_eip+0x191>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104647:	89 d8                	mov    %ebx,%eax
f0104649:	01 d0                	add    %edx,%eax
f010464b:	89 07                	mov    %eax,(%edi)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010464d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104652:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0104655:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104658:	39 cb                	cmp    %ecx,%ebx
f010465a:	7d 44                	jge    f01046a0 <debuginfo_eip+0x1e4>
		for (lline = lfun + 1;
f010465c:	8d 53 01             	lea    0x1(%ebx),%edx
f010465f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104662:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104665:	8d 44 83 10          	lea    0x10(%ebx,%eax,4),%eax
f0104669:	eb 07                	jmp    f0104672 <debuginfo_eip+0x1b6>
			info->eip_fn_narg++;
f010466b:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f010466f:	83 c2 01             	add    $0x1,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104672:	39 d1                	cmp    %edx,%ecx
f0104674:	74 25                	je     f010469b <debuginfo_eip+0x1df>
f0104676:	83 c0 0c             	add    $0xc,%eax
f0104679:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f010467d:	74 ec                	je     f010466b <debuginfo_eip+0x1af>
	return 0;
f010467f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104684:	eb 1a                	jmp    f01046a0 <debuginfo_eip+0x1e4>
		return -1;
f0104686:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010468b:	eb 13                	jmp    f01046a0 <debuginfo_eip+0x1e4>
f010468d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104692:	eb 0c                	jmp    f01046a0 <debuginfo_eip+0x1e4>
		return -1;
f0104694:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104699:	eb 05                	jmp    f01046a0 <debuginfo_eip+0x1e4>
	return 0;
f010469b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01046a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01046a3:	5b                   	pop    %ebx
f01046a4:	5e                   	pop    %esi
f01046a5:	5f                   	pop    %edi
f01046a6:	5d                   	pop    %ebp
f01046a7:	c3                   	ret    

f01046a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01046a8:	55                   	push   %ebp
f01046a9:	89 e5                	mov    %esp,%ebp
f01046ab:	57                   	push   %edi
f01046ac:	56                   	push   %esi
f01046ad:	53                   	push   %ebx
f01046ae:	83 ec 2c             	sub    $0x2c,%esp
f01046b1:	e8 a4 ea ff ff       	call   f010315a <__x86.get_pc_thunk.cx>
f01046b6:	81 c1 b2 b1 07 00    	add    $0x7b1b2,%ecx
f01046bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01046bf:	89 c7                	mov    %eax,%edi
f01046c1:	89 d6                	mov    %edx,%esi
f01046c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01046c6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01046c9:	89 d1                	mov    %edx,%ecx
f01046cb:	89 c2                	mov    %eax,%edx
f01046cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01046d0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01046d3:	8b 45 10             	mov    0x10(%ebp),%eax
f01046d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01046d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01046dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01046e3:	39 c2                	cmp    %eax,%edx
f01046e5:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f01046e8:	72 41                	jb     f010472b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01046ea:	83 ec 0c             	sub    $0xc,%esp
f01046ed:	ff 75 18             	push   0x18(%ebp)
f01046f0:	83 eb 01             	sub    $0x1,%ebx
f01046f3:	53                   	push   %ebx
f01046f4:	50                   	push   %eax
f01046f5:	83 ec 08             	sub    $0x8,%esp
f01046f8:	ff 75 e4             	push   -0x1c(%ebp)
f01046fb:	ff 75 e0             	push   -0x20(%ebp)
f01046fe:	ff 75 d4             	push   -0x2c(%ebp)
f0104701:	ff 75 d0             	push   -0x30(%ebp)
f0104704:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104707:	e8 04 0a 00 00       	call   f0105110 <__udivdi3>
f010470c:	83 c4 18             	add    $0x18,%esp
f010470f:	52                   	push   %edx
f0104710:	50                   	push   %eax
f0104711:	89 f2                	mov    %esi,%edx
f0104713:	89 f8                	mov    %edi,%eax
f0104715:	e8 8e ff ff ff       	call   f01046a8 <printnum>
f010471a:	83 c4 20             	add    $0x20,%esp
f010471d:	eb 13                	jmp    f0104732 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010471f:	83 ec 08             	sub    $0x8,%esp
f0104722:	56                   	push   %esi
f0104723:	ff 75 18             	push   0x18(%ebp)
f0104726:	ff d7                	call   *%edi
f0104728:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010472b:	83 eb 01             	sub    $0x1,%ebx
f010472e:	85 db                	test   %ebx,%ebx
f0104730:	7f ed                	jg     f010471f <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104732:	83 ec 08             	sub    $0x8,%esp
f0104735:	56                   	push   %esi
f0104736:	83 ec 04             	sub    $0x4,%esp
f0104739:	ff 75 e4             	push   -0x1c(%ebp)
f010473c:	ff 75 e0             	push   -0x20(%ebp)
f010473f:	ff 75 d4             	push   -0x2c(%ebp)
f0104742:	ff 75 d0             	push   -0x30(%ebp)
f0104745:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104748:	e8 e3 0a 00 00       	call   f0105230 <__umoddi3>
f010474d:	83 c4 14             	add    $0x14,%esp
f0104750:	0f be 84 03 2e 6f f8 	movsbl -0x790d2(%ebx,%eax,1),%eax
f0104757:	ff 
f0104758:	50                   	push   %eax
f0104759:	ff d7                	call   *%edi
}
f010475b:	83 c4 10             	add    $0x10,%esp
f010475e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104761:	5b                   	pop    %ebx
f0104762:	5e                   	pop    %esi
f0104763:	5f                   	pop    %edi
f0104764:	5d                   	pop    %ebp
f0104765:	c3                   	ret    

f0104766 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104766:	55                   	push   %ebp
f0104767:	89 e5                	mov    %esp,%ebp
f0104769:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010476c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104770:	8b 10                	mov    (%eax),%edx
f0104772:	3b 50 04             	cmp    0x4(%eax),%edx
f0104775:	73 0a                	jae    f0104781 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104777:	8d 4a 01             	lea    0x1(%edx),%ecx
f010477a:	89 08                	mov    %ecx,(%eax)
f010477c:	8b 45 08             	mov    0x8(%ebp),%eax
f010477f:	88 02                	mov    %al,(%edx)
}
f0104781:	5d                   	pop    %ebp
f0104782:	c3                   	ret    

f0104783 <printfmt>:
{
f0104783:	55                   	push   %ebp
f0104784:	89 e5                	mov    %esp,%ebp
f0104786:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104789:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010478c:	50                   	push   %eax
f010478d:	ff 75 10             	push   0x10(%ebp)
f0104790:	ff 75 0c             	push   0xc(%ebp)
f0104793:	ff 75 08             	push   0x8(%ebp)
f0104796:	e8 05 00 00 00       	call   f01047a0 <vprintfmt>
}
f010479b:	83 c4 10             	add    $0x10,%esp
f010479e:	c9                   	leave  
f010479f:	c3                   	ret    

f01047a0 <vprintfmt>:
{
f01047a0:	55                   	push   %ebp
f01047a1:	89 e5                	mov    %esp,%ebp
f01047a3:	57                   	push   %edi
f01047a4:	56                   	push   %esi
f01047a5:	53                   	push   %ebx
f01047a6:	83 ec 3c             	sub    $0x3c,%esp
f01047a9:	e8 4b bf ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f01047ae:	05 ba b0 07 00       	add    $0x7b0ba,%eax
f01047b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01047b6:	8b 75 08             	mov    0x8(%ebp),%esi
f01047b9:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01047bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01047bf:	8d 80 48 18 00 00    	lea    0x1848(%eax),%eax
f01047c5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01047c8:	eb 0a                	jmp    f01047d4 <vprintfmt+0x34>
			putch(ch, putdat);
f01047ca:	83 ec 08             	sub    $0x8,%esp
f01047cd:	57                   	push   %edi
f01047ce:	50                   	push   %eax
f01047cf:	ff d6                	call   *%esi
f01047d1:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01047d4:	83 c3 01             	add    $0x1,%ebx
f01047d7:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01047db:	83 f8 25             	cmp    $0x25,%eax
f01047de:	74 0c                	je     f01047ec <vprintfmt+0x4c>
			if (ch == '\0')
f01047e0:	85 c0                	test   %eax,%eax
f01047e2:	75 e6                	jne    f01047ca <vprintfmt+0x2a>
}
f01047e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01047e7:	5b                   	pop    %ebx
f01047e8:	5e                   	pop    %esi
f01047e9:	5f                   	pop    %edi
f01047ea:	5d                   	pop    %ebp
f01047eb:	c3                   	ret    
		padc = ' ';
f01047ec:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f01047f0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f01047f7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f01047fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f0104805:	b9 00 00 00 00       	mov    $0x0,%ecx
f010480a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010480d:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104810:	8d 43 01             	lea    0x1(%ebx),%eax
f0104813:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104816:	0f b6 13             	movzbl (%ebx),%edx
f0104819:	8d 42 dd             	lea    -0x23(%edx),%eax
f010481c:	3c 55                	cmp    $0x55,%al
f010481e:	0f 87 c5 03 00 00    	ja     f0104be9 <.L20>
f0104824:	0f b6 c0             	movzbl %al,%eax
f0104827:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010482a:	89 ce                	mov    %ecx,%esi
f010482c:	03 b4 81 b8 6f f8 ff 	add    -0x79048(%ecx,%eax,4),%esi
f0104833:	ff e6                	jmp    *%esi

f0104835 <.L66>:
f0104835:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0104838:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f010483c:	eb d2                	jmp    f0104810 <vprintfmt+0x70>

f010483e <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f010483e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104841:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0104845:	eb c9                	jmp    f0104810 <vprintfmt+0x70>

f0104847 <.L31>:
f0104847:	0f b6 d2             	movzbl %dl,%edx
f010484a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f010484d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104852:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0104855:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104858:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010485c:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f010485f:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104862:	83 f9 09             	cmp    $0x9,%ecx
f0104865:	77 58                	ja     f01048bf <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0104867:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f010486a:	eb e9                	jmp    f0104855 <.L31+0xe>

f010486c <.L34>:
			precision = va_arg(ap, int);
f010486c:	8b 45 14             	mov    0x14(%ebp),%eax
f010486f:	8b 00                	mov    (%eax),%eax
f0104871:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104874:	8b 45 14             	mov    0x14(%ebp),%eax
f0104877:	8d 40 04             	lea    0x4(%eax),%eax
f010487a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010487d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0104880:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0104884:	79 8a                	jns    f0104810 <vprintfmt+0x70>
				width = precision, precision = -1;
f0104886:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104889:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010488c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0104893:	e9 78 ff ff ff       	jmp    f0104810 <vprintfmt+0x70>

f0104898 <.L33>:
f0104898:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010489b:	85 d2                	test   %edx,%edx
f010489d:	b8 00 00 00 00       	mov    $0x0,%eax
f01048a2:	0f 49 c2             	cmovns %edx,%eax
f01048a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01048a8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01048ab:	e9 60 ff ff ff       	jmp    f0104810 <vprintfmt+0x70>

f01048b0 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f01048b0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f01048b3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01048ba:	e9 51 ff ff ff       	jmp    f0104810 <vprintfmt+0x70>
f01048bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01048c2:	89 75 08             	mov    %esi,0x8(%ebp)
f01048c5:	eb b9                	jmp    f0104880 <.L34+0x14>

f01048c7 <.L27>:
			lflag++;
f01048c7:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01048cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01048ce:	e9 3d ff ff ff       	jmp    f0104810 <vprintfmt+0x70>

f01048d3 <.L30>:
			putch(va_arg(ap, int), putdat);
f01048d3:	8b 75 08             	mov    0x8(%ebp),%esi
f01048d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01048d9:	8d 58 04             	lea    0x4(%eax),%ebx
f01048dc:	83 ec 08             	sub    $0x8,%esp
f01048df:	57                   	push   %edi
f01048e0:	ff 30                	push   (%eax)
f01048e2:	ff d6                	call   *%esi
			break;
f01048e4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01048e7:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f01048ea:	e9 90 02 00 00       	jmp    f0104b7f <.L25+0x45>

f01048ef <.L28>:
			err = va_arg(ap, int);
f01048ef:	8b 75 08             	mov    0x8(%ebp),%esi
f01048f2:	8b 45 14             	mov    0x14(%ebp),%eax
f01048f5:	8d 58 04             	lea    0x4(%eax),%ebx
f01048f8:	8b 10                	mov    (%eax),%edx
f01048fa:	89 d0                	mov    %edx,%eax
f01048fc:	f7 d8                	neg    %eax
f01048fe:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104901:	83 f8 06             	cmp    $0x6,%eax
f0104904:	7f 27                	jg     f010492d <.L28+0x3e>
f0104906:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104909:	8b 14 82             	mov    (%edx,%eax,4),%edx
f010490c:	85 d2                	test   %edx,%edx
f010490e:	74 1d                	je     f010492d <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f0104910:	52                   	push   %edx
f0104911:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104914:	8d 80 99 67 f8 ff    	lea    -0x79867(%eax),%eax
f010491a:	50                   	push   %eax
f010491b:	57                   	push   %edi
f010491c:	56                   	push   %esi
f010491d:	e8 61 fe ff ff       	call   f0104783 <printfmt>
f0104922:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104925:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0104928:	e9 52 02 00 00       	jmp    f0104b7f <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f010492d:	50                   	push   %eax
f010492e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104931:	8d 80 46 6f f8 ff    	lea    -0x790ba(%eax),%eax
f0104937:	50                   	push   %eax
f0104938:	57                   	push   %edi
f0104939:	56                   	push   %esi
f010493a:	e8 44 fe ff ff       	call   f0104783 <printfmt>
f010493f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104942:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104945:	e9 35 02 00 00       	jmp    f0104b7f <.L25+0x45>

f010494a <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f010494a:	8b 75 08             	mov    0x8(%ebp),%esi
f010494d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104950:	83 c0 04             	add    $0x4,%eax
f0104953:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0104956:	8b 45 14             	mov    0x14(%ebp),%eax
f0104959:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010495b:	85 d2                	test   %edx,%edx
f010495d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104960:	8d 80 3f 6f f8 ff    	lea    -0x790c1(%eax),%eax
f0104966:	0f 45 c2             	cmovne %edx,%eax
f0104969:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f010496c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0104970:	7e 06                	jle    f0104978 <.L24+0x2e>
f0104972:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0104976:	75 0d                	jne    f0104985 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104978:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010497b:	89 c3                	mov    %eax,%ebx
f010497d:	03 45 d0             	add    -0x30(%ebp),%eax
f0104980:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104983:	eb 58                	jmp    f01049dd <.L24+0x93>
f0104985:	83 ec 08             	sub    $0x8,%esp
f0104988:	ff 75 d8             	push   -0x28(%ebp)
f010498b:	ff 75 c8             	push   -0x38(%ebp)
f010498e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104991:	e8 0c 04 00 00       	call   f0104da2 <strnlen>
f0104996:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104999:	29 c2                	sub    %eax,%edx
f010499b:	89 55 bc             	mov    %edx,-0x44(%ebp)
f010499e:	83 c4 10             	add    $0x10,%esp
f01049a1:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01049a3:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01049a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01049aa:	eb 0f                	jmp    f01049bb <.L24+0x71>
					putch(padc, putdat);
f01049ac:	83 ec 08             	sub    $0x8,%esp
f01049af:	57                   	push   %edi
f01049b0:	ff 75 d0             	push   -0x30(%ebp)
f01049b3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01049b5:	83 eb 01             	sub    $0x1,%ebx
f01049b8:	83 c4 10             	add    $0x10,%esp
f01049bb:	85 db                	test   %ebx,%ebx
f01049bd:	7f ed                	jg     f01049ac <.L24+0x62>
f01049bf:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01049c2:	85 d2                	test   %edx,%edx
f01049c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01049c9:	0f 49 c2             	cmovns %edx,%eax
f01049cc:	29 c2                	sub    %eax,%edx
f01049ce:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01049d1:	eb a5                	jmp    f0104978 <.L24+0x2e>
					putch(ch, putdat);
f01049d3:	83 ec 08             	sub    $0x8,%esp
f01049d6:	57                   	push   %edi
f01049d7:	52                   	push   %edx
f01049d8:	ff d6                	call   *%esi
f01049da:	83 c4 10             	add    $0x10,%esp
f01049dd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01049e0:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01049e2:	83 c3 01             	add    $0x1,%ebx
f01049e5:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01049e9:	0f be d0             	movsbl %al,%edx
f01049ec:	85 d2                	test   %edx,%edx
f01049ee:	74 4b                	je     f0104a3b <.L24+0xf1>
f01049f0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01049f4:	78 06                	js     f01049fc <.L24+0xb2>
f01049f6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01049fa:	78 1e                	js     f0104a1a <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f01049fc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104a00:	74 d1                	je     f01049d3 <.L24+0x89>
f0104a02:	0f be c0             	movsbl %al,%eax
f0104a05:	83 e8 20             	sub    $0x20,%eax
f0104a08:	83 f8 5e             	cmp    $0x5e,%eax
f0104a0b:	76 c6                	jbe    f01049d3 <.L24+0x89>
					putch('?', putdat);
f0104a0d:	83 ec 08             	sub    $0x8,%esp
f0104a10:	57                   	push   %edi
f0104a11:	6a 3f                	push   $0x3f
f0104a13:	ff d6                	call   *%esi
f0104a15:	83 c4 10             	add    $0x10,%esp
f0104a18:	eb c3                	jmp    f01049dd <.L24+0x93>
f0104a1a:	89 cb                	mov    %ecx,%ebx
f0104a1c:	eb 0e                	jmp    f0104a2c <.L24+0xe2>
				putch(' ', putdat);
f0104a1e:	83 ec 08             	sub    $0x8,%esp
f0104a21:	57                   	push   %edi
f0104a22:	6a 20                	push   $0x20
f0104a24:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0104a26:	83 eb 01             	sub    $0x1,%ebx
f0104a29:	83 c4 10             	add    $0x10,%esp
f0104a2c:	85 db                	test   %ebx,%ebx
f0104a2e:	7f ee                	jg     f0104a1e <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f0104a30:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104a33:	89 45 14             	mov    %eax,0x14(%ebp)
f0104a36:	e9 44 01 00 00       	jmp    f0104b7f <.L25+0x45>
f0104a3b:	89 cb                	mov    %ecx,%ebx
f0104a3d:	eb ed                	jmp    f0104a2c <.L24+0xe2>

f0104a3f <.L29>:
	if (lflag >= 2)
f0104a3f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104a42:	8b 75 08             	mov    0x8(%ebp),%esi
f0104a45:	83 f9 01             	cmp    $0x1,%ecx
f0104a48:	7f 1b                	jg     f0104a65 <.L29+0x26>
	else if (lflag)
f0104a4a:	85 c9                	test   %ecx,%ecx
f0104a4c:	74 63                	je     f0104ab1 <.L29+0x72>
		return va_arg(*ap, long);
f0104a4e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a51:	8b 00                	mov    (%eax),%eax
f0104a53:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104a56:	99                   	cltd   
f0104a57:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104a5a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a5d:	8d 40 04             	lea    0x4(%eax),%eax
f0104a60:	89 45 14             	mov    %eax,0x14(%ebp)
f0104a63:	eb 17                	jmp    f0104a7c <.L29+0x3d>
		return va_arg(*ap, long long);
f0104a65:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a68:	8b 50 04             	mov    0x4(%eax),%edx
f0104a6b:	8b 00                	mov    (%eax),%eax
f0104a6d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104a70:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104a73:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a76:	8d 40 08             	lea    0x8(%eax),%eax
f0104a79:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104a7c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104a7f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f0104a82:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f0104a87:	85 db                	test   %ebx,%ebx
f0104a89:	0f 89 d6 00 00 00    	jns    f0104b65 <.L25+0x2b>
				putch('-', putdat);
f0104a8f:	83 ec 08             	sub    $0x8,%esp
f0104a92:	57                   	push   %edi
f0104a93:	6a 2d                	push   $0x2d
f0104a95:	ff d6                	call   *%esi
				num = -(long long) num;
f0104a97:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104a9a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104a9d:	f7 d9                	neg    %ecx
f0104a9f:	83 d3 00             	adc    $0x0,%ebx
f0104aa2:	f7 db                	neg    %ebx
f0104aa4:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104aa7:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104aac:	e9 b4 00 00 00       	jmp    f0104b65 <.L25+0x2b>
		return va_arg(*ap, int);
f0104ab1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ab4:	8b 00                	mov    (%eax),%eax
f0104ab6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ab9:	99                   	cltd   
f0104aba:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104abd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ac0:	8d 40 04             	lea    0x4(%eax),%eax
f0104ac3:	89 45 14             	mov    %eax,0x14(%ebp)
f0104ac6:	eb b4                	jmp    f0104a7c <.L29+0x3d>

f0104ac8 <.L23>:
	if (lflag >= 2)
f0104ac8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104acb:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ace:	83 f9 01             	cmp    $0x1,%ecx
f0104ad1:	7f 1b                	jg     f0104aee <.L23+0x26>
	else if (lflag)
f0104ad3:	85 c9                	test   %ecx,%ecx
f0104ad5:	74 2c                	je     f0104b03 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f0104ad7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ada:	8b 08                	mov    (%eax),%ecx
f0104adc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ae1:	8d 40 04             	lea    0x4(%eax),%eax
f0104ae4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104ae7:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f0104aec:	eb 77                	jmp    f0104b65 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104aee:	8b 45 14             	mov    0x14(%ebp),%eax
f0104af1:	8b 08                	mov    (%eax),%ecx
f0104af3:	8b 58 04             	mov    0x4(%eax),%ebx
f0104af6:	8d 40 08             	lea    0x8(%eax),%eax
f0104af9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104afc:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f0104b01:	eb 62                	jmp    f0104b65 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0104b03:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b06:	8b 08                	mov    (%eax),%ecx
f0104b08:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b0d:	8d 40 04             	lea    0x4(%eax),%eax
f0104b10:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104b13:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f0104b18:	eb 4b                	jmp    f0104b65 <.L25+0x2b>

f0104b1a <.L26>:
			putch('X', putdat);
f0104b1a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b1d:	83 ec 08             	sub    $0x8,%esp
f0104b20:	57                   	push   %edi
f0104b21:	6a 58                	push   $0x58
f0104b23:	ff d6                	call   *%esi
			putch('X', putdat);
f0104b25:	83 c4 08             	add    $0x8,%esp
f0104b28:	57                   	push   %edi
f0104b29:	6a 58                	push   $0x58
f0104b2b:	ff d6                	call   *%esi
			putch('X', putdat);
f0104b2d:	83 c4 08             	add    $0x8,%esp
f0104b30:	57                   	push   %edi
f0104b31:	6a 58                	push   $0x58
f0104b33:	ff d6                	call   *%esi
			break;
f0104b35:	83 c4 10             	add    $0x10,%esp
f0104b38:	eb 45                	jmp    f0104b7f <.L25+0x45>

f0104b3a <.L25>:
			putch('0', putdat);
f0104b3a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b3d:	83 ec 08             	sub    $0x8,%esp
f0104b40:	57                   	push   %edi
f0104b41:	6a 30                	push   $0x30
f0104b43:	ff d6                	call   *%esi
			putch('x', putdat);
f0104b45:	83 c4 08             	add    $0x8,%esp
f0104b48:	57                   	push   %edi
f0104b49:	6a 78                	push   $0x78
f0104b4b:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104b4d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b50:	8b 08                	mov    (%eax),%ecx
f0104b52:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f0104b57:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104b5a:	8d 40 04             	lea    0x4(%eax),%eax
f0104b5d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104b60:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0104b65:	83 ec 0c             	sub    $0xc,%esp
f0104b68:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0104b6c:	50                   	push   %eax
f0104b6d:	ff 75 d0             	push   -0x30(%ebp)
f0104b70:	52                   	push   %edx
f0104b71:	53                   	push   %ebx
f0104b72:	51                   	push   %ecx
f0104b73:	89 fa                	mov    %edi,%edx
f0104b75:	89 f0                	mov    %esi,%eax
f0104b77:	e8 2c fb ff ff       	call   f01046a8 <printnum>
			break;
f0104b7c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104b7f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104b82:	e9 4d fc ff ff       	jmp    f01047d4 <vprintfmt+0x34>

f0104b87 <.L21>:
	if (lflag >= 2)
f0104b87:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104b8a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b8d:	83 f9 01             	cmp    $0x1,%ecx
f0104b90:	7f 1b                	jg     f0104bad <.L21+0x26>
	else if (lflag)
f0104b92:	85 c9                	test   %ecx,%ecx
f0104b94:	74 2c                	je     f0104bc2 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0104b96:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b99:	8b 08                	mov    (%eax),%ecx
f0104b9b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ba0:	8d 40 04             	lea    0x4(%eax),%eax
f0104ba3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104ba6:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f0104bab:	eb b8                	jmp    f0104b65 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104bad:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bb0:	8b 08                	mov    (%eax),%ecx
f0104bb2:	8b 58 04             	mov    0x4(%eax),%ebx
f0104bb5:	8d 40 08             	lea    0x8(%eax),%eax
f0104bb8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104bbb:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f0104bc0:	eb a3                	jmp    f0104b65 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0104bc2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bc5:	8b 08                	mov    (%eax),%ecx
f0104bc7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104bcc:	8d 40 04             	lea    0x4(%eax),%eax
f0104bcf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104bd2:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0104bd7:	eb 8c                	jmp    f0104b65 <.L25+0x2b>

f0104bd9 <.L35>:
			putch(ch, putdat);
f0104bd9:	8b 75 08             	mov    0x8(%ebp),%esi
f0104bdc:	83 ec 08             	sub    $0x8,%esp
f0104bdf:	57                   	push   %edi
f0104be0:	6a 25                	push   $0x25
f0104be2:	ff d6                	call   *%esi
			break;
f0104be4:	83 c4 10             	add    $0x10,%esp
f0104be7:	eb 96                	jmp    f0104b7f <.L25+0x45>

f0104be9 <.L20>:
			putch('%', putdat);
f0104be9:	8b 75 08             	mov    0x8(%ebp),%esi
f0104bec:	83 ec 08             	sub    $0x8,%esp
f0104bef:	57                   	push   %edi
f0104bf0:	6a 25                	push   $0x25
f0104bf2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104bf4:	83 c4 10             	add    $0x10,%esp
f0104bf7:	89 d8                	mov    %ebx,%eax
f0104bf9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104bfd:	74 05                	je     f0104c04 <.L20+0x1b>
f0104bff:	83 e8 01             	sub    $0x1,%eax
f0104c02:	eb f5                	jmp    f0104bf9 <.L20+0x10>
f0104c04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104c07:	e9 73 ff ff ff       	jmp    f0104b7f <.L25+0x45>

f0104c0c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104c0c:	55                   	push   %ebp
f0104c0d:	89 e5                	mov    %esp,%ebp
f0104c0f:	53                   	push   %ebx
f0104c10:	83 ec 14             	sub    $0x14,%esp
f0104c13:	e8 4f b5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104c18:	81 c3 50 ac 07 00    	add    $0x7ac50,%ebx
f0104c1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c21:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104c24:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c27:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104c2b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104c2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104c35:	85 c0                	test   %eax,%eax
f0104c37:	74 2b                	je     f0104c64 <vsnprintf+0x58>
f0104c39:	85 d2                	test   %edx,%edx
f0104c3b:	7e 27                	jle    f0104c64 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104c3d:	ff 75 14             	push   0x14(%ebp)
f0104c40:	ff 75 10             	push   0x10(%ebp)
f0104c43:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104c46:	50                   	push   %eax
f0104c47:	8d 83 fe 4e f8 ff    	lea    -0x7b102(%ebx),%eax
f0104c4d:	50                   	push   %eax
f0104c4e:	e8 4d fb ff ff       	call   f01047a0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104c56:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c5c:	83 c4 10             	add    $0x10,%esp
}
f0104c5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104c62:	c9                   	leave  
f0104c63:	c3                   	ret    
		return -E_INVAL;
f0104c64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c69:	eb f4                	jmp    f0104c5f <vsnprintf+0x53>

f0104c6b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104c6b:	55                   	push   %ebp
f0104c6c:	89 e5                	mov    %esp,%ebp
f0104c6e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104c71:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104c74:	50                   	push   %eax
f0104c75:	ff 75 10             	push   0x10(%ebp)
f0104c78:	ff 75 0c             	push   0xc(%ebp)
f0104c7b:	ff 75 08             	push   0x8(%ebp)
f0104c7e:	e8 89 ff ff ff       	call   f0104c0c <vsnprintf>
	va_end(ap);

	return rc;
}
f0104c83:	c9                   	leave  
f0104c84:	c3                   	ret    

f0104c85 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104c85:	55                   	push   %ebp
f0104c86:	89 e5                	mov    %esp,%ebp
f0104c88:	57                   	push   %edi
f0104c89:	56                   	push   %esi
f0104c8a:	53                   	push   %ebx
f0104c8b:	83 ec 1c             	sub    $0x1c,%esp
f0104c8e:	e8 d4 b4 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104c93:	81 c3 d5 ab 07 00    	add    $0x7abd5,%ebx
f0104c99:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104c9c:	85 c0                	test   %eax,%eax
f0104c9e:	74 13                	je     f0104cb3 <readline+0x2e>
		cprintf("%s", prompt);
f0104ca0:	83 ec 08             	sub    $0x8,%esp
f0104ca3:	50                   	push   %eax
f0104ca4:	8d 83 99 67 f8 ff    	lea    -0x79867(%ebx),%eax
f0104caa:	50                   	push   %eax
f0104cab:	e8 36 ed ff ff       	call   f01039e6 <cprintf>
f0104cb0:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104cb3:	83 ec 0c             	sub    $0xc,%esp
f0104cb6:	6a 00                	push   $0x0
f0104cb8:	e8 36 ba ff ff       	call   f01006f3 <iscons>
f0104cbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104cc0:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104cc3:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0104cc8:	8d 83 98 23 00 00    	lea    0x2398(%ebx),%eax
f0104cce:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104cd1:	eb 45                	jmp    f0104d18 <readline+0x93>
			cprintf("read error: %e\n", c);
f0104cd3:	83 ec 08             	sub    $0x8,%esp
f0104cd6:	50                   	push   %eax
f0104cd7:	8d 83 10 71 f8 ff    	lea    -0x78ef0(%ebx),%eax
f0104cdd:	50                   	push   %eax
f0104cde:	e8 03 ed ff ff       	call   f01039e6 <cprintf>
			return NULL;
f0104ce3:	83 c4 10             	add    $0x10,%esp
f0104ce6:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104ceb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104cee:	5b                   	pop    %ebx
f0104cef:	5e                   	pop    %esi
f0104cf0:	5f                   	pop    %edi
f0104cf1:	5d                   	pop    %ebp
f0104cf2:	c3                   	ret    
			if (echoing)
f0104cf3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104cf7:	75 05                	jne    f0104cfe <readline+0x79>
			i--;
f0104cf9:	83 ef 01             	sub    $0x1,%edi
f0104cfc:	eb 1a                	jmp    f0104d18 <readline+0x93>
				cputchar('\b');
f0104cfe:	83 ec 0c             	sub    $0xc,%esp
f0104d01:	6a 08                	push   $0x8
f0104d03:	e8 ca b9 ff ff       	call   f01006d2 <cputchar>
f0104d08:	83 c4 10             	add    $0x10,%esp
f0104d0b:	eb ec                	jmp    f0104cf9 <readline+0x74>
			buf[i++] = c;
f0104d0d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104d10:	89 f0                	mov    %esi,%eax
f0104d12:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0104d15:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0104d18:	e8 c5 b9 ff ff       	call   f01006e2 <getchar>
f0104d1d:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104d1f:	85 c0                	test   %eax,%eax
f0104d21:	78 b0                	js     f0104cd3 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104d23:	83 f8 08             	cmp    $0x8,%eax
f0104d26:	0f 94 c0             	sete   %al
f0104d29:	83 fe 7f             	cmp    $0x7f,%esi
f0104d2c:	0f 94 c2             	sete   %dl
f0104d2f:	08 d0                	or     %dl,%al
f0104d31:	74 04                	je     f0104d37 <readline+0xb2>
f0104d33:	85 ff                	test   %edi,%edi
f0104d35:	7f bc                	jg     f0104cf3 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104d37:	83 fe 1f             	cmp    $0x1f,%esi
f0104d3a:	7e 1c                	jle    f0104d58 <readline+0xd3>
f0104d3c:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0104d42:	7f 14                	jg     f0104d58 <readline+0xd3>
			if (echoing)
f0104d44:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104d48:	74 c3                	je     f0104d0d <readline+0x88>
				cputchar(c);
f0104d4a:	83 ec 0c             	sub    $0xc,%esp
f0104d4d:	56                   	push   %esi
f0104d4e:	e8 7f b9 ff ff       	call   f01006d2 <cputchar>
f0104d53:	83 c4 10             	add    $0x10,%esp
f0104d56:	eb b5                	jmp    f0104d0d <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f0104d58:	83 fe 0a             	cmp    $0xa,%esi
f0104d5b:	74 05                	je     f0104d62 <readline+0xdd>
f0104d5d:	83 fe 0d             	cmp    $0xd,%esi
f0104d60:	75 b6                	jne    f0104d18 <readline+0x93>
			if (echoing)
f0104d62:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104d66:	75 13                	jne    f0104d7b <readline+0xf6>
			buf[i] = 0;
f0104d68:	c6 84 3b 98 23 00 00 	movb   $0x0,0x2398(%ebx,%edi,1)
f0104d6f:	00 
			return buf;
f0104d70:	8d 83 98 23 00 00    	lea    0x2398(%ebx),%eax
f0104d76:	e9 70 ff ff ff       	jmp    f0104ceb <readline+0x66>
				cputchar('\n');
f0104d7b:	83 ec 0c             	sub    $0xc,%esp
f0104d7e:	6a 0a                	push   $0xa
f0104d80:	e8 4d b9 ff ff       	call   f01006d2 <cputchar>
f0104d85:	83 c4 10             	add    $0x10,%esp
f0104d88:	eb de                	jmp    f0104d68 <readline+0xe3>

f0104d8a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104d8a:	55                   	push   %ebp
f0104d8b:	89 e5                	mov    %esp,%ebp
f0104d8d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104d90:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d95:	eb 03                	jmp    f0104d9a <strlen+0x10>
		n++;
f0104d97:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0104d9a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104d9e:	75 f7                	jne    f0104d97 <strlen+0xd>
	return n;
}
f0104da0:	5d                   	pop    %ebp
f0104da1:	c3                   	ret    

f0104da2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104da2:	55                   	push   %ebp
f0104da3:	89 e5                	mov    %esp,%ebp
f0104da5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104da8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104dab:	b8 00 00 00 00       	mov    $0x0,%eax
f0104db0:	eb 03                	jmp    f0104db5 <strnlen+0x13>
		n++;
f0104db2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104db5:	39 d0                	cmp    %edx,%eax
f0104db7:	74 08                	je     f0104dc1 <strnlen+0x1f>
f0104db9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104dbd:	75 f3                	jne    f0104db2 <strnlen+0x10>
f0104dbf:	89 c2                	mov    %eax,%edx
	return n;
}
f0104dc1:	89 d0                	mov    %edx,%eax
f0104dc3:	5d                   	pop    %ebp
f0104dc4:	c3                   	ret    

f0104dc5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104dc5:	55                   	push   %ebp
f0104dc6:	89 e5                	mov    %esp,%ebp
f0104dc8:	53                   	push   %ebx
f0104dc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104dcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104dcf:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dd4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0104dd8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0104ddb:	83 c0 01             	add    $0x1,%eax
f0104dde:	84 d2                	test   %dl,%dl
f0104de0:	75 f2                	jne    f0104dd4 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104de2:	89 c8                	mov    %ecx,%eax
f0104de4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104de7:	c9                   	leave  
f0104de8:	c3                   	ret    

f0104de9 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104de9:	55                   	push   %ebp
f0104dea:	89 e5                	mov    %esp,%ebp
f0104dec:	53                   	push   %ebx
f0104ded:	83 ec 10             	sub    $0x10,%esp
f0104df0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104df3:	53                   	push   %ebx
f0104df4:	e8 91 ff ff ff       	call   f0104d8a <strlen>
f0104df9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0104dfc:	ff 75 0c             	push   0xc(%ebp)
f0104dff:	01 d8                	add    %ebx,%eax
f0104e01:	50                   	push   %eax
f0104e02:	e8 be ff ff ff       	call   f0104dc5 <strcpy>
	return dst;
}
f0104e07:	89 d8                	mov    %ebx,%eax
f0104e09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104e0c:	c9                   	leave  
f0104e0d:	c3                   	ret    

f0104e0e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104e0e:	55                   	push   %ebp
f0104e0f:	89 e5                	mov    %esp,%ebp
f0104e11:	56                   	push   %esi
f0104e12:	53                   	push   %ebx
f0104e13:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e16:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e19:	89 f3                	mov    %esi,%ebx
f0104e1b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104e1e:	89 f0                	mov    %esi,%eax
f0104e20:	eb 0f                	jmp    f0104e31 <strncpy+0x23>
		*dst++ = *src;
f0104e22:	83 c0 01             	add    $0x1,%eax
f0104e25:	0f b6 0a             	movzbl (%edx),%ecx
f0104e28:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104e2b:	80 f9 01             	cmp    $0x1,%cl
f0104e2e:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0104e31:	39 d8                	cmp    %ebx,%eax
f0104e33:	75 ed                	jne    f0104e22 <strncpy+0x14>
	}
	return ret;
}
f0104e35:	89 f0                	mov    %esi,%eax
f0104e37:	5b                   	pop    %ebx
f0104e38:	5e                   	pop    %esi
f0104e39:	5d                   	pop    %ebp
f0104e3a:	c3                   	ret    

f0104e3b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104e3b:	55                   	push   %ebp
f0104e3c:	89 e5                	mov    %esp,%ebp
f0104e3e:	56                   	push   %esi
f0104e3f:	53                   	push   %ebx
f0104e40:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104e46:	8b 55 10             	mov    0x10(%ebp),%edx
f0104e49:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104e4b:	85 d2                	test   %edx,%edx
f0104e4d:	74 21                	je     f0104e70 <strlcpy+0x35>
f0104e4f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104e53:	89 f2                	mov    %esi,%edx
f0104e55:	eb 09                	jmp    f0104e60 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104e57:	83 c1 01             	add    $0x1,%ecx
f0104e5a:	83 c2 01             	add    $0x1,%edx
f0104e5d:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0104e60:	39 c2                	cmp    %eax,%edx
f0104e62:	74 09                	je     f0104e6d <strlcpy+0x32>
f0104e64:	0f b6 19             	movzbl (%ecx),%ebx
f0104e67:	84 db                	test   %bl,%bl
f0104e69:	75 ec                	jne    f0104e57 <strlcpy+0x1c>
f0104e6b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0104e6d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104e70:	29 f0                	sub    %esi,%eax
}
f0104e72:	5b                   	pop    %ebx
f0104e73:	5e                   	pop    %esi
f0104e74:	5d                   	pop    %ebp
f0104e75:	c3                   	ret    

f0104e76 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104e76:	55                   	push   %ebp
f0104e77:	89 e5                	mov    %esp,%ebp
f0104e79:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104e7c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104e7f:	eb 06                	jmp    f0104e87 <strcmp+0x11>
		p++, q++;
f0104e81:	83 c1 01             	add    $0x1,%ecx
f0104e84:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0104e87:	0f b6 01             	movzbl (%ecx),%eax
f0104e8a:	84 c0                	test   %al,%al
f0104e8c:	74 04                	je     f0104e92 <strcmp+0x1c>
f0104e8e:	3a 02                	cmp    (%edx),%al
f0104e90:	74 ef                	je     f0104e81 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104e92:	0f b6 c0             	movzbl %al,%eax
f0104e95:	0f b6 12             	movzbl (%edx),%edx
f0104e98:	29 d0                	sub    %edx,%eax
}
f0104e9a:	5d                   	pop    %ebp
f0104e9b:	c3                   	ret    

f0104e9c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104e9c:	55                   	push   %ebp
f0104e9d:	89 e5                	mov    %esp,%ebp
f0104e9f:	53                   	push   %ebx
f0104ea0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ea3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ea6:	89 c3                	mov    %eax,%ebx
f0104ea8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104eab:	eb 06                	jmp    f0104eb3 <strncmp+0x17>
		n--, p++, q++;
f0104ead:	83 c0 01             	add    $0x1,%eax
f0104eb0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104eb3:	39 d8                	cmp    %ebx,%eax
f0104eb5:	74 18                	je     f0104ecf <strncmp+0x33>
f0104eb7:	0f b6 08             	movzbl (%eax),%ecx
f0104eba:	84 c9                	test   %cl,%cl
f0104ebc:	74 04                	je     f0104ec2 <strncmp+0x26>
f0104ebe:	3a 0a                	cmp    (%edx),%cl
f0104ec0:	74 eb                	je     f0104ead <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104ec2:	0f b6 00             	movzbl (%eax),%eax
f0104ec5:	0f b6 12             	movzbl (%edx),%edx
f0104ec8:	29 d0                	sub    %edx,%eax
}
f0104eca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104ecd:	c9                   	leave  
f0104ece:	c3                   	ret    
		return 0;
f0104ecf:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ed4:	eb f4                	jmp    f0104eca <strncmp+0x2e>

f0104ed6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104ed6:	55                   	push   %ebp
f0104ed7:	89 e5                	mov    %esp,%ebp
f0104ed9:	8b 45 08             	mov    0x8(%ebp),%eax
f0104edc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104ee0:	eb 03                	jmp    f0104ee5 <strchr+0xf>
f0104ee2:	83 c0 01             	add    $0x1,%eax
f0104ee5:	0f b6 10             	movzbl (%eax),%edx
f0104ee8:	84 d2                	test   %dl,%dl
f0104eea:	74 06                	je     f0104ef2 <strchr+0x1c>
		if (*s == c)
f0104eec:	38 ca                	cmp    %cl,%dl
f0104eee:	75 f2                	jne    f0104ee2 <strchr+0xc>
f0104ef0:	eb 05                	jmp    f0104ef7 <strchr+0x21>
			return (char *) s;
	return 0;
f0104ef2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104ef7:	5d                   	pop    %ebp
f0104ef8:	c3                   	ret    

f0104ef9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104ef9:	55                   	push   %ebp
f0104efa:	89 e5                	mov    %esp,%ebp
f0104efc:	8b 45 08             	mov    0x8(%ebp),%eax
f0104eff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104f03:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104f06:	38 ca                	cmp    %cl,%dl
f0104f08:	74 09                	je     f0104f13 <strfind+0x1a>
f0104f0a:	84 d2                	test   %dl,%dl
f0104f0c:	74 05                	je     f0104f13 <strfind+0x1a>
	for (; *s; s++)
f0104f0e:	83 c0 01             	add    $0x1,%eax
f0104f11:	eb f0                	jmp    f0104f03 <strfind+0xa>
			break;
	return (char *) s;
}
f0104f13:	5d                   	pop    %ebp
f0104f14:	c3                   	ret    

f0104f15 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104f15:	55                   	push   %ebp
f0104f16:	89 e5                	mov    %esp,%ebp
f0104f18:	57                   	push   %edi
f0104f19:	56                   	push   %esi
f0104f1a:	53                   	push   %ebx
f0104f1b:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104f1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104f21:	85 c9                	test   %ecx,%ecx
f0104f23:	74 2f                	je     f0104f54 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104f25:	89 f8                	mov    %edi,%eax
f0104f27:	09 c8                	or     %ecx,%eax
f0104f29:	a8 03                	test   $0x3,%al
f0104f2b:	75 21                	jne    f0104f4e <memset+0x39>
		c &= 0xFF;
f0104f2d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104f31:	89 d0                	mov    %edx,%eax
f0104f33:	c1 e0 08             	shl    $0x8,%eax
f0104f36:	89 d3                	mov    %edx,%ebx
f0104f38:	c1 e3 18             	shl    $0x18,%ebx
f0104f3b:	89 d6                	mov    %edx,%esi
f0104f3d:	c1 e6 10             	shl    $0x10,%esi
f0104f40:	09 f3                	or     %esi,%ebx
f0104f42:	09 da                	or     %ebx,%edx
f0104f44:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104f46:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104f49:	fc                   	cld    
f0104f4a:	f3 ab                	rep stos %eax,%es:(%edi)
f0104f4c:	eb 06                	jmp    f0104f54 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f51:	fc                   	cld    
f0104f52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104f54:	89 f8                	mov    %edi,%eax
f0104f56:	5b                   	pop    %ebx
f0104f57:	5e                   	pop    %esi
f0104f58:	5f                   	pop    %edi
f0104f59:	5d                   	pop    %ebp
f0104f5a:	c3                   	ret    

f0104f5b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104f5b:	55                   	push   %ebp
f0104f5c:	89 e5                	mov    %esp,%ebp
f0104f5e:	57                   	push   %edi
f0104f5f:	56                   	push   %esi
f0104f60:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f63:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104f66:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104f69:	39 c6                	cmp    %eax,%esi
f0104f6b:	73 32                	jae    f0104f9f <memmove+0x44>
f0104f6d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104f70:	39 c2                	cmp    %eax,%edx
f0104f72:	76 2b                	jbe    f0104f9f <memmove+0x44>
		s += n;
		d += n;
f0104f74:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104f77:	89 d6                	mov    %edx,%esi
f0104f79:	09 fe                	or     %edi,%esi
f0104f7b:	09 ce                	or     %ecx,%esi
f0104f7d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104f83:	75 0e                	jne    f0104f93 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104f85:	83 ef 04             	sub    $0x4,%edi
f0104f88:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104f8b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104f8e:	fd                   	std    
f0104f8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104f91:	eb 09                	jmp    f0104f9c <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104f93:	83 ef 01             	sub    $0x1,%edi
f0104f96:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104f99:	fd                   	std    
f0104f9a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104f9c:	fc                   	cld    
f0104f9d:	eb 1a                	jmp    f0104fb9 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104f9f:	89 f2                	mov    %esi,%edx
f0104fa1:	09 c2                	or     %eax,%edx
f0104fa3:	09 ca                	or     %ecx,%edx
f0104fa5:	f6 c2 03             	test   $0x3,%dl
f0104fa8:	75 0a                	jne    f0104fb4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104faa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104fad:	89 c7                	mov    %eax,%edi
f0104faf:	fc                   	cld    
f0104fb0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104fb2:	eb 05                	jmp    f0104fb9 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0104fb4:	89 c7                	mov    %eax,%edi
f0104fb6:	fc                   	cld    
f0104fb7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104fb9:	5e                   	pop    %esi
f0104fba:	5f                   	pop    %edi
f0104fbb:	5d                   	pop    %ebp
f0104fbc:	c3                   	ret    

f0104fbd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104fbd:	55                   	push   %ebp
f0104fbe:	89 e5                	mov    %esp,%ebp
f0104fc0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104fc3:	ff 75 10             	push   0x10(%ebp)
f0104fc6:	ff 75 0c             	push   0xc(%ebp)
f0104fc9:	ff 75 08             	push   0x8(%ebp)
f0104fcc:	e8 8a ff ff ff       	call   f0104f5b <memmove>
}
f0104fd1:	c9                   	leave  
f0104fd2:	c3                   	ret    

f0104fd3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104fd3:	55                   	push   %ebp
f0104fd4:	89 e5                	mov    %esp,%ebp
f0104fd6:	56                   	push   %esi
f0104fd7:	53                   	push   %ebx
f0104fd8:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104fde:	89 c6                	mov    %eax,%esi
f0104fe0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104fe3:	eb 06                	jmp    f0104feb <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0104fe5:	83 c0 01             	add    $0x1,%eax
f0104fe8:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0104feb:	39 f0                	cmp    %esi,%eax
f0104fed:	74 14                	je     f0105003 <memcmp+0x30>
		if (*s1 != *s2)
f0104fef:	0f b6 08             	movzbl (%eax),%ecx
f0104ff2:	0f b6 1a             	movzbl (%edx),%ebx
f0104ff5:	38 d9                	cmp    %bl,%cl
f0104ff7:	74 ec                	je     f0104fe5 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0104ff9:	0f b6 c1             	movzbl %cl,%eax
f0104ffc:	0f b6 db             	movzbl %bl,%ebx
f0104fff:	29 d8                	sub    %ebx,%eax
f0105001:	eb 05                	jmp    f0105008 <memcmp+0x35>
	}

	return 0;
f0105003:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105008:	5b                   	pop    %ebx
f0105009:	5e                   	pop    %esi
f010500a:	5d                   	pop    %ebp
f010500b:	c3                   	ret    

f010500c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010500c:	55                   	push   %ebp
f010500d:	89 e5                	mov    %esp,%ebp
f010500f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105012:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105015:	89 c2                	mov    %eax,%edx
f0105017:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010501a:	eb 03                	jmp    f010501f <memfind+0x13>
f010501c:	83 c0 01             	add    $0x1,%eax
f010501f:	39 d0                	cmp    %edx,%eax
f0105021:	73 04                	jae    f0105027 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105023:	38 08                	cmp    %cl,(%eax)
f0105025:	75 f5                	jne    f010501c <memfind+0x10>
			break;
	return (void *) s;
}
f0105027:	5d                   	pop    %ebp
f0105028:	c3                   	ret    

f0105029 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105029:	55                   	push   %ebp
f010502a:	89 e5                	mov    %esp,%ebp
f010502c:	57                   	push   %edi
f010502d:	56                   	push   %esi
f010502e:	53                   	push   %ebx
f010502f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105032:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105035:	eb 03                	jmp    f010503a <strtol+0x11>
		s++;
f0105037:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f010503a:	0f b6 02             	movzbl (%edx),%eax
f010503d:	3c 20                	cmp    $0x20,%al
f010503f:	74 f6                	je     f0105037 <strtol+0xe>
f0105041:	3c 09                	cmp    $0x9,%al
f0105043:	74 f2                	je     f0105037 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105045:	3c 2b                	cmp    $0x2b,%al
f0105047:	74 2a                	je     f0105073 <strtol+0x4a>
	int neg = 0;
f0105049:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f010504e:	3c 2d                	cmp    $0x2d,%al
f0105050:	74 2b                	je     f010507d <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105052:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105058:	75 0f                	jne    f0105069 <strtol+0x40>
f010505a:	80 3a 30             	cmpb   $0x30,(%edx)
f010505d:	74 28                	je     f0105087 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010505f:	85 db                	test   %ebx,%ebx
f0105061:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105066:	0f 44 d8             	cmove  %eax,%ebx
f0105069:	b9 00 00 00 00       	mov    $0x0,%ecx
f010506e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105071:	eb 46                	jmp    f01050b9 <strtol+0x90>
		s++;
f0105073:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0105076:	bf 00 00 00 00       	mov    $0x0,%edi
f010507b:	eb d5                	jmp    f0105052 <strtol+0x29>
		s++, neg = 1;
f010507d:	83 c2 01             	add    $0x1,%edx
f0105080:	bf 01 00 00 00       	mov    $0x1,%edi
f0105085:	eb cb                	jmp    f0105052 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105087:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010508b:	74 0e                	je     f010509b <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f010508d:	85 db                	test   %ebx,%ebx
f010508f:	75 d8                	jne    f0105069 <strtol+0x40>
		s++, base = 8;
f0105091:	83 c2 01             	add    $0x1,%edx
f0105094:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105099:	eb ce                	jmp    f0105069 <strtol+0x40>
		s += 2, base = 16;
f010509b:	83 c2 02             	add    $0x2,%edx
f010509e:	bb 10 00 00 00       	mov    $0x10,%ebx
f01050a3:	eb c4                	jmp    f0105069 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01050a5:	0f be c0             	movsbl %al,%eax
f01050a8:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01050ab:	3b 45 10             	cmp    0x10(%ebp),%eax
f01050ae:	7d 3a                	jge    f01050ea <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f01050b0:	83 c2 01             	add    $0x1,%edx
f01050b3:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f01050b7:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f01050b9:	0f b6 02             	movzbl (%edx),%eax
f01050bc:	8d 70 d0             	lea    -0x30(%eax),%esi
f01050bf:	89 f3                	mov    %esi,%ebx
f01050c1:	80 fb 09             	cmp    $0x9,%bl
f01050c4:	76 df                	jbe    f01050a5 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f01050c6:	8d 70 9f             	lea    -0x61(%eax),%esi
f01050c9:	89 f3                	mov    %esi,%ebx
f01050cb:	80 fb 19             	cmp    $0x19,%bl
f01050ce:	77 08                	ja     f01050d8 <strtol+0xaf>
			dig = *s - 'a' + 10;
f01050d0:	0f be c0             	movsbl %al,%eax
f01050d3:	83 e8 57             	sub    $0x57,%eax
f01050d6:	eb d3                	jmp    f01050ab <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f01050d8:	8d 70 bf             	lea    -0x41(%eax),%esi
f01050db:	89 f3                	mov    %esi,%ebx
f01050dd:	80 fb 19             	cmp    $0x19,%bl
f01050e0:	77 08                	ja     f01050ea <strtol+0xc1>
			dig = *s - 'A' + 10;
f01050e2:	0f be c0             	movsbl %al,%eax
f01050e5:	83 e8 37             	sub    $0x37,%eax
f01050e8:	eb c1                	jmp    f01050ab <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f01050ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01050ee:	74 05                	je     f01050f5 <strtol+0xcc>
		*endptr = (char *) s;
f01050f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01050f3:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f01050f5:	89 c8                	mov    %ecx,%eax
f01050f7:	f7 d8                	neg    %eax
f01050f9:	85 ff                	test   %edi,%edi
f01050fb:	0f 45 c8             	cmovne %eax,%ecx
}
f01050fe:	89 c8                	mov    %ecx,%eax
f0105100:	5b                   	pop    %ebx
f0105101:	5e                   	pop    %esi
f0105102:	5f                   	pop    %edi
f0105103:	5d                   	pop    %ebp
f0105104:	c3                   	ret    
f0105105:	66 90                	xchg   %ax,%ax
f0105107:	66 90                	xchg   %ax,%ax
f0105109:	66 90                	xchg   %ax,%ax
f010510b:	66 90                	xchg   %ax,%ax
f010510d:	66 90                	xchg   %ax,%ax
f010510f:	90                   	nop

f0105110 <__udivdi3>:
f0105110:	f3 0f 1e fb          	endbr32 
f0105114:	55                   	push   %ebp
f0105115:	57                   	push   %edi
f0105116:	56                   	push   %esi
f0105117:	53                   	push   %ebx
f0105118:	83 ec 1c             	sub    $0x1c,%esp
f010511b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010511f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0105123:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105127:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010512b:	85 c0                	test   %eax,%eax
f010512d:	75 19                	jne    f0105148 <__udivdi3+0x38>
f010512f:	39 f3                	cmp    %esi,%ebx
f0105131:	76 4d                	jbe    f0105180 <__udivdi3+0x70>
f0105133:	31 ff                	xor    %edi,%edi
f0105135:	89 e8                	mov    %ebp,%eax
f0105137:	89 f2                	mov    %esi,%edx
f0105139:	f7 f3                	div    %ebx
f010513b:	89 fa                	mov    %edi,%edx
f010513d:	83 c4 1c             	add    $0x1c,%esp
f0105140:	5b                   	pop    %ebx
f0105141:	5e                   	pop    %esi
f0105142:	5f                   	pop    %edi
f0105143:	5d                   	pop    %ebp
f0105144:	c3                   	ret    
f0105145:	8d 76 00             	lea    0x0(%esi),%esi
f0105148:	39 f0                	cmp    %esi,%eax
f010514a:	76 14                	jbe    f0105160 <__udivdi3+0x50>
f010514c:	31 ff                	xor    %edi,%edi
f010514e:	31 c0                	xor    %eax,%eax
f0105150:	89 fa                	mov    %edi,%edx
f0105152:	83 c4 1c             	add    $0x1c,%esp
f0105155:	5b                   	pop    %ebx
f0105156:	5e                   	pop    %esi
f0105157:	5f                   	pop    %edi
f0105158:	5d                   	pop    %ebp
f0105159:	c3                   	ret    
f010515a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105160:	0f bd f8             	bsr    %eax,%edi
f0105163:	83 f7 1f             	xor    $0x1f,%edi
f0105166:	75 48                	jne    f01051b0 <__udivdi3+0xa0>
f0105168:	39 f0                	cmp    %esi,%eax
f010516a:	72 06                	jb     f0105172 <__udivdi3+0x62>
f010516c:	31 c0                	xor    %eax,%eax
f010516e:	39 eb                	cmp    %ebp,%ebx
f0105170:	77 de                	ja     f0105150 <__udivdi3+0x40>
f0105172:	b8 01 00 00 00       	mov    $0x1,%eax
f0105177:	eb d7                	jmp    f0105150 <__udivdi3+0x40>
f0105179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105180:	89 d9                	mov    %ebx,%ecx
f0105182:	85 db                	test   %ebx,%ebx
f0105184:	75 0b                	jne    f0105191 <__udivdi3+0x81>
f0105186:	b8 01 00 00 00       	mov    $0x1,%eax
f010518b:	31 d2                	xor    %edx,%edx
f010518d:	f7 f3                	div    %ebx
f010518f:	89 c1                	mov    %eax,%ecx
f0105191:	31 d2                	xor    %edx,%edx
f0105193:	89 f0                	mov    %esi,%eax
f0105195:	f7 f1                	div    %ecx
f0105197:	89 c6                	mov    %eax,%esi
f0105199:	89 e8                	mov    %ebp,%eax
f010519b:	89 f7                	mov    %esi,%edi
f010519d:	f7 f1                	div    %ecx
f010519f:	89 fa                	mov    %edi,%edx
f01051a1:	83 c4 1c             	add    $0x1c,%esp
f01051a4:	5b                   	pop    %ebx
f01051a5:	5e                   	pop    %esi
f01051a6:	5f                   	pop    %edi
f01051a7:	5d                   	pop    %ebp
f01051a8:	c3                   	ret    
f01051a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01051b0:	89 f9                	mov    %edi,%ecx
f01051b2:	ba 20 00 00 00       	mov    $0x20,%edx
f01051b7:	29 fa                	sub    %edi,%edx
f01051b9:	d3 e0                	shl    %cl,%eax
f01051bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01051bf:	89 d1                	mov    %edx,%ecx
f01051c1:	89 d8                	mov    %ebx,%eax
f01051c3:	d3 e8                	shr    %cl,%eax
f01051c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01051c9:	09 c1                	or     %eax,%ecx
f01051cb:	89 f0                	mov    %esi,%eax
f01051cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01051d1:	89 f9                	mov    %edi,%ecx
f01051d3:	d3 e3                	shl    %cl,%ebx
f01051d5:	89 d1                	mov    %edx,%ecx
f01051d7:	d3 e8                	shr    %cl,%eax
f01051d9:	89 f9                	mov    %edi,%ecx
f01051db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01051df:	89 eb                	mov    %ebp,%ebx
f01051e1:	d3 e6                	shl    %cl,%esi
f01051e3:	89 d1                	mov    %edx,%ecx
f01051e5:	d3 eb                	shr    %cl,%ebx
f01051e7:	09 f3                	or     %esi,%ebx
f01051e9:	89 c6                	mov    %eax,%esi
f01051eb:	89 f2                	mov    %esi,%edx
f01051ed:	89 d8                	mov    %ebx,%eax
f01051ef:	f7 74 24 08          	divl   0x8(%esp)
f01051f3:	89 d6                	mov    %edx,%esi
f01051f5:	89 c3                	mov    %eax,%ebx
f01051f7:	f7 64 24 0c          	mull   0xc(%esp)
f01051fb:	39 d6                	cmp    %edx,%esi
f01051fd:	72 19                	jb     f0105218 <__udivdi3+0x108>
f01051ff:	89 f9                	mov    %edi,%ecx
f0105201:	d3 e5                	shl    %cl,%ebp
f0105203:	39 c5                	cmp    %eax,%ebp
f0105205:	73 04                	jae    f010520b <__udivdi3+0xfb>
f0105207:	39 d6                	cmp    %edx,%esi
f0105209:	74 0d                	je     f0105218 <__udivdi3+0x108>
f010520b:	89 d8                	mov    %ebx,%eax
f010520d:	31 ff                	xor    %edi,%edi
f010520f:	e9 3c ff ff ff       	jmp    f0105150 <__udivdi3+0x40>
f0105214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105218:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010521b:	31 ff                	xor    %edi,%edi
f010521d:	e9 2e ff ff ff       	jmp    f0105150 <__udivdi3+0x40>
f0105222:	66 90                	xchg   %ax,%ax
f0105224:	66 90                	xchg   %ax,%ax
f0105226:	66 90                	xchg   %ax,%ax
f0105228:	66 90                	xchg   %ax,%ax
f010522a:	66 90                	xchg   %ax,%ax
f010522c:	66 90                	xchg   %ax,%ax
f010522e:	66 90                	xchg   %ax,%ax

f0105230 <__umoddi3>:
f0105230:	f3 0f 1e fb          	endbr32 
f0105234:	55                   	push   %ebp
f0105235:	57                   	push   %edi
f0105236:	56                   	push   %esi
f0105237:	53                   	push   %ebx
f0105238:	83 ec 1c             	sub    $0x1c,%esp
f010523b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010523f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0105243:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0105247:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f010524b:	89 f0                	mov    %esi,%eax
f010524d:	89 da                	mov    %ebx,%edx
f010524f:	85 ff                	test   %edi,%edi
f0105251:	75 15                	jne    f0105268 <__umoddi3+0x38>
f0105253:	39 dd                	cmp    %ebx,%ebp
f0105255:	76 39                	jbe    f0105290 <__umoddi3+0x60>
f0105257:	f7 f5                	div    %ebp
f0105259:	89 d0                	mov    %edx,%eax
f010525b:	31 d2                	xor    %edx,%edx
f010525d:	83 c4 1c             	add    $0x1c,%esp
f0105260:	5b                   	pop    %ebx
f0105261:	5e                   	pop    %esi
f0105262:	5f                   	pop    %edi
f0105263:	5d                   	pop    %ebp
f0105264:	c3                   	ret    
f0105265:	8d 76 00             	lea    0x0(%esi),%esi
f0105268:	39 df                	cmp    %ebx,%edi
f010526a:	77 f1                	ja     f010525d <__umoddi3+0x2d>
f010526c:	0f bd cf             	bsr    %edi,%ecx
f010526f:	83 f1 1f             	xor    $0x1f,%ecx
f0105272:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105276:	75 40                	jne    f01052b8 <__umoddi3+0x88>
f0105278:	39 df                	cmp    %ebx,%edi
f010527a:	72 04                	jb     f0105280 <__umoddi3+0x50>
f010527c:	39 f5                	cmp    %esi,%ebp
f010527e:	77 dd                	ja     f010525d <__umoddi3+0x2d>
f0105280:	89 da                	mov    %ebx,%edx
f0105282:	89 f0                	mov    %esi,%eax
f0105284:	29 e8                	sub    %ebp,%eax
f0105286:	19 fa                	sbb    %edi,%edx
f0105288:	eb d3                	jmp    f010525d <__umoddi3+0x2d>
f010528a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105290:	89 e9                	mov    %ebp,%ecx
f0105292:	85 ed                	test   %ebp,%ebp
f0105294:	75 0b                	jne    f01052a1 <__umoddi3+0x71>
f0105296:	b8 01 00 00 00       	mov    $0x1,%eax
f010529b:	31 d2                	xor    %edx,%edx
f010529d:	f7 f5                	div    %ebp
f010529f:	89 c1                	mov    %eax,%ecx
f01052a1:	89 d8                	mov    %ebx,%eax
f01052a3:	31 d2                	xor    %edx,%edx
f01052a5:	f7 f1                	div    %ecx
f01052a7:	89 f0                	mov    %esi,%eax
f01052a9:	f7 f1                	div    %ecx
f01052ab:	89 d0                	mov    %edx,%eax
f01052ad:	31 d2                	xor    %edx,%edx
f01052af:	eb ac                	jmp    f010525d <__umoddi3+0x2d>
f01052b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01052b8:	8b 44 24 04          	mov    0x4(%esp),%eax
f01052bc:	ba 20 00 00 00       	mov    $0x20,%edx
f01052c1:	29 c2                	sub    %eax,%edx
f01052c3:	89 c1                	mov    %eax,%ecx
f01052c5:	89 e8                	mov    %ebp,%eax
f01052c7:	d3 e7                	shl    %cl,%edi
f01052c9:	89 d1                	mov    %edx,%ecx
f01052cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01052cf:	d3 e8                	shr    %cl,%eax
f01052d1:	89 c1                	mov    %eax,%ecx
f01052d3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01052d7:	09 f9                	or     %edi,%ecx
f01052d9:	89 df                	mov    %ebx,%edi
f01052db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01052df:	89 c1                	mov    %eax,%ecx
f01052e1:	d3 e5                	shl    %cl,%ebp
f01052e3:	89 d1                	mov    %edx,%ecx
f01052e5:	d3 ef                	shr    %cl,%edi
f01052e7:	89 c1                	mov    %eax,%ecx
f01052e9:	89 f0                	mov    %esi,%eax
f01052eb:	d3 e3                	shl    %cl,%ebx
f01052ed:	89 d1                	mov    %edx,%ecx
f01052ef:	89 fa                	mov    %edi,%edx
f01052f1:	d3 e8                	shr    %cl,%eax
f01052f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01052f8:	09 d8                	or     %ebx,%eax
f01052fa:	f7 74 24 08          	divl   0x8(%esp)
f01052fe:	89 d3                	mov    %edx,%ebx
f0105300:	d3 e6                	shl    %cl,%esi
f0105302:	f7 e5                	mul    %ebp
f0105304:	89 c7                	mov    %eax,%edi
f0105306:	89 d1                	mov    %edx,%ecx
f0105308:	39 d3                	cmp    %edx,%ebx
f010530a:	72 06                	jb     f0105312 <__umoddi3+0xe2>
f010530c:	75 0e                	jne    f010531c <__umoddi3+0xec>
f010530e:	39 c6                	cmp    %eax,%esi
f0105310:	73 0a                	jae    f010531c <__umoddi3+0xec>
f0105312:	29 e8                	sub    %ebp,%eax
f0105314:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0105318:	89 d1                	mov    %edx,%ecx
f010531a:	89 c7                	mov    %eax,%edi
f010531c:	89 f5                	mov    %esi,%ebp
f010531e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0105322:	29 fd                	sub    %edi,%ebp
f0105324:	19 cb                	sbb    %ecx,%ebx
f0105326:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f010532b:	89 d8                	mov    %ebx,%eax
f010532d:	d3 e0                	shl    %cl,%eax
f010532f:	89 f1                	mov    %esi,%ecx
f0105331:	d3 ed                	shr    %cl,%ebp
f0105333:	d3 eb                	shr    %cl,%ebx
f0105335:	09 e8                	or     %ebp,%eax
f0105337:	89 da                	mov    %ebx,%edx
f0105339:	83 c4 1c             	add    $0x1c,%esp
f010533c:	5b                   	pop    %ebx
f010533d:	5e                   	pop    %esi
f010533e:	5f                   	pop    %edi
f010533f:	5d                   	pop    %ebp
f0105340:	c3                   	ret    
