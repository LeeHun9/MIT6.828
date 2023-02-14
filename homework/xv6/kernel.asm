
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:
8010000c:	0f 20 e0             	mov    %cr4,%eax
8010000f:	83 c8 10             	or     $0x10,%eax
80100012:	0f 22 e0             	mov    %eax,%cr4
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
8010001a:	0f 22 d8             	mov    %eax,%cr3
8010001d:	0f 20 c0             	mov    %cr0,%eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
80100025:	0f 22 c0             	mov    %eax,%cr0
80100028:	bc d0 57 11 80       	mov    $0x801157d0,%esp
8010002d:	b8 80 31 10 80       	mov    $0x80103180,%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	53                   	push   %ebx

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100044:	bb 54 a5 10 80       	mov    $0x8010a554,%ebx
{
80100049:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
8010004c:	68 00 74 10 80       	push   $0x80107400
80100051:	68 20 a5 10 80       	push   $0x8010a520
80100056:	e8 d5 44 00 00       	call   80104530 <initlock>
  bcache.head.next = &bcache.head;
8010005b:	83 c4 10             	add    $0x10,%esp
8010005e:	b8 1c ec 10 80       	mov    $0x8010ec1c,%eax
  bcache.head.prev = &bcache.head;
80100063:	c7 05 6c ec 10 80 1c 	movl   $0x8010ec1c,0x8010ec6c
8010006a:	ec 10 80 
  bcache.head.next = &bcache.head;
8010006d:	c7 05 70 ec 10 80 1c 	movl   $0x8010ec1c,0x8010ec70
80100074:	ec 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100077:	eb 09                	jmp    80100082 <binit+0x42>
80100079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100080:	89 d3                	mov    %edx,%ebx
    b->next = bcache.head.next;
80100082:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
80100085:	83 ec 08             	sub    $0x8,%esp
80100088:	8d 43 0c             	lea    0xc(%ebx),%eax
    b->prev = &bcache.head;
8010008b:	c7 43 50 1c ec 10 80 	movl   $0x8010ec1c,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100092:	68 07 74 10 80       	push   $0x80107407
80100097:	50                   	push   %eax
80100098:	e8 63 43 00 00       	call   80104400 <initsleeplock>
    bcache.head.next->prev = b;
8010009d:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000a2:	8d 93 5c 02 00 00    	lea    0x25c(%ebx),%edx
801000a8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000ab:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
801000ae:	89 d8                	mov    %ebx,%eax
801000b0:	89 1d 70 ec 10 80    	mov    %ebx,0x8010ec70
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b6:	81 fb c0 e9 10 80    	cmp    $0x8010e9c0,%ebx
801000bc:	75 c2                	jne    80100080 <binit+0x40>
  }
}
801000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801000c1:	c9                   	leave  
801000c2:	c3                   	ret    
801000c3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801000ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801000d0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801000d0:	55                   	push   %ebp
801000d1:	89 e5                	mov    %esp,%ebp
801000d3:	57                   	push   %edi
801000d4:	56                   	push   %esi
801000d5:	53                   	push   %ebx
801000d6:	83 ec 18             	sub    $0x18,%esp
801000d9:	8b 75 08             	mov    0x8(%ebp),%esi
801000dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  acquire(&bcache.lock);
801000df:	68 20 a5 10 80       	push   $0x8010a520
801000e4:	e8 17 46 00 00       	call   80104700 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000e9:	8b 1d 70 ec 10 80    	mov    0x8010ec70,%ebx
801000ef:	83 c4 10             	add    $0x10,%esp
801000f2:	81 fb 1c ec 10 80    	cmp    $0x8010ec1c,%ebx
801000f8:	75 11                	jne    8010010b <bread+0x3b>
801000fa:	eb 24                	jmp    80100120 <bread+0x50>
801000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100100:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100103:	81 fb 1c ec 10 80    	cmp    $0x8010ec1c,%ebx
80100109:	74 15                	je     80100120 <bread+0x50>
    if(b->dev == dev && b->blockno == blockno){
8010010b:	3b 73 04             	cmp    0x4(%ebx),%esi
8010010e:	75 f0                	jne    80100100 <bread+0x30>
80100110:	3b 7b 08             	cmp    0x8(%ebx),%edi
80100113:	75 eb                	jne    80100100 <bread+0x30>
      b->refcnt++;
80100115:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100119:	eb 3f                	jmp    8010015a <bread+0x8a>
8010011b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010011f:	90                   	nop
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100120:	8b 1d 6c ec 10 80    	mov    0x8010ec6c,%ebx
80100126:	81 fb 1c ec 10 80    	cmp    $0x8010ec1c,%ebx
8010012c:	75 0d                	jne    8010013b <bread+0x6b>
8010012e:	eb 6e                	jmp    8010019e <bread+0xce>
80100130:	8b 5b 50             	mov    0x50(%ebx),%ebx
80100133:	81 fb 1c ec 10 80    	cmp    $0x8010ec1c,%ebx
80100139:	74 63                	je     8010019e <bread+0xce>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010013e:	85 c0                	test   %eax,%eax
80100140:	75 ee                	jne    80100130 <bread+0x60>
80100142:	f6 03 04             	testb  $0x4,(%ebx)
80100145:	75 e9                	jne    80100130 <bread+0x60>
      b->dev = dev;
80100147:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
8010014a:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
8010014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
80100153:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
8010015a:	83 ec 0c             	sub    $0xc,%esp
8010015d:	68 20 a5 10 80       	push   $0x8010a520
80100162:	e8 39 45 00 00       	call   801046a0 <release>
      acquiresleep(&b->lock);
80100167:	8d 43 0c             	lea    0xc(%ebx),%eax
8010016a:	89 04 24             	mov    %eax,(%esp)
8010016d:	e8 ce 42 00 00       	call   80104440 <acquiresleep>
      return b;
80100172:	83 c4 10             	add    $0x10,%esp
  struct buf *b;

  b = bget(dev, blockno);
  if((b->flags & B_VALID) == 0) {
80100175:	f6 03 02             	testb  $0x2,(%ebx)
80100178:	74 0e                	je     80100188 <bread+0xb8>
    iderw(b);
  }
  return b;
}
8010017a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010017d:	89 d8                	mov    %ebx,%eax
8010017f:	5b                   	pop    %ebx
80100180:	5e                   	pop    %esi
80100181:	5f                   	pop    %edi
80100182:	5d                   	pop    %ebp
80100183:	c3                   	ret    
80100184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    iderw(b);
80100188:	83 ec 0c             	sub    $0xc,%esp
8010018b:	53                   	push   %ebx
8010018c:	e8 6f 22 00 00       	call   80102400 <iderw>
80100191:	83 c4 10             	add    $0x10,%esp
}
80100194:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100197:	89 d8                	mov    %ebx,%eax
80100199:	5b                   	pop    %ebx
8010019a:	5e                   	pop    %esi
8010019b:	5f                   	pop    %edi
8010019c:	5d                   	pop    %ebp
8010019d:	c3                   	ret    
  panic("bget: no buffers");
8010019e:	83 ec 0c             	sub    $0xc,%esp
801001a1:	68 0e 74 10 80       	push   $0x8010740e
801001a6:	e8 d5 01 00 00       	call   80100380 <panic>
801001ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801001af:	90                   	nop

801001b0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001b0:	55                   	push   %ebp
801001b1:	89 e5                	mov    %esp,%ebp
801001b3:	53                   	push   %ebx
801001b4:	83 ec 10             	sub    $0x10,%esp
801001b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001ba:	8d 43 0c             	lea    0xc(%ebx),%eax
801001bd:	50                   	push   %eax
801001be:	e8 1d 43 00 00       	call   801044e0 <holdingsleep>
801001c3:	83 c4 10             	add    $0x10,%esp
801001c6:	85 c0                	test   %eax,%eax
801001c8:	74 0f                	je     801001d9 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001ca:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001cd:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001d3:	c9                   	leave  
  iderw(b);
801001d4:	e9 27 22 00 00       	jmp    80102400 <iderw>
    panic("bwrite");
801001d9:	83 ec 0c             	sub    $0xc,%esp
801001dc:	68 1f 74 10 80       	push   $0x8010741f
801001e1:	e8 9a 01 00 00       	call   80100380 <panic>
801001e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801001ed:	8d 76 00             	lea    0x0(%esi),%esi

801001f0 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001f0:	55                   	push   %ebp
801001f1:	89 e5                	mov    %esp,%ebp
801001f3:	56                   	push   %esi
801001f4:	53                   	push   %ebx
801001f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001f8:	8d 73 0c             	lea    0xc(%ebx),%esi
801001fb:	83 ec 0c             	sub    $0xc,%esp
801001fe:	56                   	push   %esi
801001ff:	e8 dc 42 00 00       	call   801044e0 <holdingsleep>
80100204:	83 c4 10             	add    $0x10,%esp
80100207:	85 c0                	test   %eax,%eax
80100209:	74 66                	je     80100271 <brelse+0x81>
    panic("brelse");

  releasesleep(&b->lock);
8010020b:	83 ec 0c             	sub    $0xc,%esp
8010020e:	56                   	push   %esi
8010020f:	e8 8c 42 00 00       	call   801044a0 <releasesleep>

  acquire(&bcache.lock);
80100214:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010021b:	e8 e0 44 00 00       	call   80104700 <acquire>
  b->refcnt--;
80100220:	8b 43 4c             	mov    0x4c(%ebx),%eax
  if (b->refcnt == 0) {
80100223:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
80100226:	83 e8 01             	sub    $0x1,%eax
80100229:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010022c:	85 c0                	test   %eax,%eax
8010022e:	75 2f                	jne    8010025f <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100230:	8b 43 54             	mov    0x54(%ebx),%eax
80100233:	8b 53 50             	mov    0x50(%ebx),%edx
80100236:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100239:	8b 43 50             	mov    0x50(%ebx),%eax
8010023c:	8b 53 54             	mov    0x54(%ebx),%edx
8010023f:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100242:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
    b->prev = &bcache.head;
80100247:	c7 43 50 1c ec 10 80 	movl   $0x8010ec1c,0x50(%ebx)
    b->next = bcache.head.next;
8010024e:	89 43 54             	mov    %eax,0x54(%ebx)
    bcache.head.next->prev = b;
80100251:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
80100256:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100259:	89 1d 70 ec 10 80    	mov    %ebx,0x8010ec70
  }
  
  release(&bcache.lock);
8010025f:	c7 45 08 20 a5 10 80 	movl   $0x8010a520,0x8(%ebp)
}
80100266:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100269:	5b                   	pop    %ebx
8010026a:	5e                   	pop    %esi
8010026b:	5d                   	pop    %ebp
  release(&bcache.lock);
8010026c:	e9 2f 44 00 00       	jmp    801046a0 <release>
    panic("brelse");
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	68 26 74 10 80       	push   $0x80107426
80100279:	e8 02 01 00 00       	call   80100380 <panic>
8010027e:	66 90                	xchg   %ax,%ax

80100280 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100280:	55                   	push   %ebp
80100281:	89 e5                	mov    %esp,%ebp
80100283:	57                   	push   %edi
80100284:	56                   	push   %esi
80100285:	53                   	push   %ebx
80100286:	83 ec 18             	sub    $0x18,%esp
80100289:	8b 5d 10             	mov    0x10(%ebp),%ebx
8010028c:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
8010028f:	ff 75 08             	push   0x8(%ebp)
  target = n;
80100292:	89 df                	mov    %ebx,%edi
  iunlock(ip);
80100294:	e8 e7 16 00 00       	call   80101980 <iunlock>
  acquire(&cons.lock);
80100299:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
801002a0:	e8 5b 44 00 00       	call   80104700 <acquire>
  while(n > 0){
801002a5:	83 c4 10             	add    $0x10,%esp
801002a8:	85 db                	test   %ebx,%ebx
801002aa:	0f 8e 94 00 00 00    	jle    80100344 <consoleread+0xc4>
    while(input.r == input.w){
801002b0:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
801002b5:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
801002bb:	74 25                	je     801002e2 <consoleread+0x62>
801002bd:	eb 59                	jmp    80100318 <consoleread+0x98>
801002bf:	90                   	nop
      if(myproc()->killed){
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002c0:	83 ec 08             	sub    $0x8,%esp
801002c3:	68 20 ef 10 80       	push   $0x8010ef20
801002c8:	68 00 ef 10 80       	push   $0x8010ef00
801002cd:	e8 ce 3e 00 00       	call   801041a0 <sleep>
    while(input.r == input.w){
801002d2:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
801002d7:	83 c4 10             	add    $0x10,%esp
801002da:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
801002e0:	75 36                	jne    80100318 <consoleread+0x98>
      if(myproc()->killed){
801002e2:	e8 e9 37 00 00       	call   80103ad0 <myproc>
801002e7:	8b 48 24             	mov    0x24(%eax),%ecx
801002ea:	85 c9                	test   %ecx,%ecx
801002ec:	74 d2                	je     801002c0 <consoleread+0x40>
        release(&cons.lock);
801002ee:	83 ec 0c             	sub    $0xc,%esp
801002f1:	68 20 ef 10 80       	push   $0x8010ef20
801002f6:	e8 a5 43 00 00       	call   801046a0 <release>
        ilock(ip);
801002fb:	5a                   	pop    %edx
801002fc:	ff 75 08             	push   0x8(%ebp)
801002ff:	e8 9c 15 00 00       	call   801018a0 <ilock>
        return -1;
80100304:	83 c4 10             	add    $0x10,%esp
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
80100307:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return -1;
8010030a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010030f:	5b                   	pop    %ebx
80100310:	5e                   	pop    %esi
80100311:	5f                   	pop    %edi
80100312:	5d                   	pop    %ebp
80100313:	c3                   	ret    
80100314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = input.buf[input.r++ % INPUT_BUF];
80100318:	8d 50 01             	lea    0x1(%eax),%edx
8010031b:	89 15 00 ef 10 80    	mov    %edx,0x8010ef00
80100321:	89 c2                	mov    %eax,%edx
80100323:	83 e2 7f             	and    $0x7f,%edx
80100326:	0f be 8a 80 ee 10 80 	movsbl -0x7fef1180(%edx),%ecx
    if(c == C('D')){  // EOF
8010032d:	80 f9 04             	cmp    $0x4,%cl
80100330:	74 37                	je     80100369 <consoleread+0xe9>
    *dst++ = c;
80100332:	83 c6 01             	add    $0x1,%esi
    --n;
80100335:	83 eb 01             	sub    $0x1,%ebx
    *dst++ = c;
80100338:	88 4e ff             	mov    %cl,-0x1(%esi)
    if(c == '\n')
8010033b:	83 f9 0a             	cmp    $0xa,%ecx
8010033e:	0f 85 64 ff ff ff    	jne    801002a8 <consoleread+0x28>
  release(&cons.lock);
80100344:	83 ec 0c             	sub    $0xc,%esp
80100347:	68 20 ef 10 80       	push   $0x8010ef20
8010034c:	e8 4f 43 00 00       	call   801046a0 <release>
  ilock(ip);
80100351:	58                   	pop    %eax
80100352:	ff 75 08             	push   0x8(%ebp)
80100355:	e8 46 15 00 00       	call   801018a0 <ilock>
  return target - n;
8010035a:	89 f8                	mov    %edi,%eax
8010035c:	83 c4 10             	add    $0x10,%esp
}
8010035f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return target - n;
80100362:	29 d8                	sub    %ebx,%eax
}
80100364:	5b                   	pop    %ebx
80100365:	5e                   	pop    %esi
80100366:	5f                   	pop    %edi
80100367:	5d                   	pop    %ebp
80100368:	c3                   	ret    
      if(n < target){
80100369:	39 fb                	cmp    %edi,%ebx
8010036b:	73 d7                	jae    80100344 <consoleread+0xc4>
        input.r--;
8010036d:	a3 00 ef 10 80       	mov    %eax,0x8010ef00
80100372:	eb d0                	jmp    80100344 <consoleread+0xc4>
80100374:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010037b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010037f:	90                   	nop

80100380 <panic>:
{
80100380:	55                   	push   %ebp
80100381:	89 e5                	mov    %esp,%ebp
80100383:	56                   	push   %esi
80100384:	53                   	push   %ebx
80100385:	83 ec 30             	sub    $0x30,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100388:	fa                   	cli    
  cons.locking = 0;
80100389:	c7 05 54 ef 10 80 00 	movl   $0x0,0x8010ef54
80100390:	00 00 00 
  getcallerpcs(&s, pcs);
80100393:	8d 5d d0             	lea    -0x30(%ebp),%ebx
80100396:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("lapicid %d: panic: ", lapicid());
80100399:	e8 72 26 00 00       	call   80102a10 <lapicid>
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	50                   	push   %eax
801003a2:	68 2d 74 10 80       	push   $0x8010742d
801003a7:	e8 d4 02 00 00       	call   80100680 <cprintf>
  cprintf(s);
801003ac:	58                   	pop    %eax
801003ad:	ff 75 08             	push   0x8(%ebp)
801003b0:	e8 cb 02 00 00       	call   80100680 <cprintf>
  cprintf("\n");
801003b5:	c7 04 24 5f 7d 10 80 	movl   $0x80107d5f,(%esp)
801003bc:	e8 bf 02 00 00       	call   80100680 <cprintf>
  getcallerpcs(&s, pcs);
801003c1:	8d 45 08             	lea    0x8(%ebp),%eax
801003c4:	5a                   	pop    %edx
801003c5:	59                   	pop    %ecx
801003c6:	53                   	push   %ebx
801003c7:	50                   	push   %eax
801003c8:	e8 83 41 00 00       	call   80104550 <getcallerpcs>
  for(i=0; i<10; i++)
801003cd:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
801003d0:	83 ec 08             	sub    $0x8,%esp
801003d3:	ff 33                	push   (%ebx)
  for(i=0; i<10; i++)
801003d5:	83 c3 04             	add    $0x4,%ebx
    cprintf(" %p", pcs[i]);
801003d8:	68 41 74 10 80       	push   $0x80107441
801003dd:	e8 9e 02 00 00       	call   80100680 <cprintf>
  for(i=0; i<10; i++)
801003e2:	83 c4 10             	add    $0x10,%esp
801003e5:	39 f3                	cmp    %esi,%ebx
801003e7:	75 e7                	jne    801003d0 <panic+0x50>
  panicked = 1; // freeze other CPU
801003e9:	c7 05 58 ef 10 80 01 	movl   $0x1,0x8010ef58
801003f0:	00 00 00 
  for(;;)
801003f3:	eb fe                	jmp    801003f3 <panic+0x73>
801003f5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801003fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100400 <cgaputc>:
{
80100400:	55                   	push   %ebp
80100401:	89 c1                	mov    %eax,%ecx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100403:	b8 0e 00 00 00       	mov    $0xe,%eax
80100408:	89 e5                	mov    %esp,%ebp
8010040a:	57                   	push   %edi
8010040b:	bf d4 03 00 00       	mov    $0x3d4,%edi
80100410:	56                   	push   %esi
80100411:	89 fa                	mov    %edi,%edx
80100413:	53                   	push   %ebx
80100414:	83 ec 1c             	sub    $0x1c,%esp
80100417:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100418:	be d5 03 00 00       	mov    $0x3d5,%esi
8010041d:	89 f2                	mov    %esi,%edx
8010041f:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
80100420:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100423:	89 fa                	mov    %edi,%edx
80100425:	c1 e0 08             	shl    $0x8,%eax
80100428:	89 c3                	mov    %eax,%ebx
8010042a:	b8 0f 00 00 00       	mov    $0xf,%eax
8010042f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100430:	89 f2                	mov    %esi,%edx
80100432:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
80100433:	0f b6 c0             	movzbl %al,%eax
80100436:	09 d8                	or     %ebx,%eax
  if(c == '\n')
80100438:	83 f9 0a             	cmp    $0xa,%ecx
8010043b:	0f 84 97 00 00 00    	je     801004d8 <cgaputc+0xd8>
  else if(c == BACKSPACE){
80100441:	81 f9 00 01 00 00    	cmp    $0x100,%ecx
80100447:	74 77                	je     801004c0 <cgaputc+0xc0>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100449:	0f b6 c9             	movzbl %cl,%ecx
8010044c:	8d 58 01             	lea    0x1(%eax),%ebx
8010044f:	80 cd 07             	or     $0x7,%ch
80100452:	66 89 8c 00 00 80 0b 	mov    %cx,-0x7ff48000(%eax,%eax,1)
80100459:	80 
  if(pos < 0 || pos > 25*80)
8010045a:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100460:	0f 8f cc 00 00 00    	jg     80100532 <cgaputc+0x132>
  if((pos/80) >= 24){  // Scroll up.
80100466:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
8010046c:	0f 8f 7e 00 00 00    	jg     801004f0 <cgaputc+0xf0>
  outb(CRTPORT+1, pos>>8);
80100472:	0f b6 c7             	movzbl %bh,%eax
  outb(CRTPORT+1, pos);
80100475:	89 df                	mov    %ebx,%edi
  crt[pos] = ' ' | 0x0700;
80100477:	8d b4 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%esi
  outb(CRTPORT+1, pos>>8);
8010047e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100481:	bb d4 03 00 00       	mov    $0x3d4,%ebx
80100486:	b8 0e 00 00 00       	mov    $0xe,%eax
8010048b:	89 da                	mov    %ebx,%edx
8010048d:	ee                   	out    %al,(%dx)
8010048e:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
80100493:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80100497:	89 ca                	mov    %ecx,%edx
80100499:	ee                   	out    %al,(%dx)
8010049a:	b8 0f 00 00 00       	mov    $0xf,%eax
8010049f:	89 da                	mov    %ebx,%edx
801004a1:	ee                   	out    %al,(%dx)
801004a2:	89 f8                	mov    %edi,%eax
801004a4:	89 ca                	mov    %ecx,%edx
801004a6:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
801004a7:	b8 20 07 00 00       	mov    $0x720,%eax
801004ac:	66 89 06             	mov    %ax,(%esi)
}
801004af:	8d 65 f4             	lea    -0xc(%ebp),%esp
801004b2:	5b                   	pop    %ebx
801004b3:	5e                   	pop    %esi
801004b4:	5f                   	pop    %edi
801004b5:	5d                   	pop    %ebp
801004b6:	c3                   	ret    
801004b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801004be:	66 90                	xchg   %ax,%ax
    if(pos > 0) --pos;
801004c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
801004c3:	85 c0                	test   %eax,%eax
801004c5:	75 93                	jne    8010045a <cgaputc+0x5a>
801004c7:	c6 45 e4 00          	movb   $0x0,-0x1c(%ebp)
801004cb:	be 00 80 0b 80       	mov    $0x800b8000,%esi
801004d0:	31 ff                	xor    %edi,%edi
801004d2:	eb ad                	jmp    80100481 <cgaputc+0x81>
801004d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pos += 80 - pos%80;
801004d8:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801004dd:	f7 e2                	mul    %edx
801004df:	c1 ea 06             	shr    $0x6,%edx
801004e2:	8d 04 92             	lea    (%edx,%edx,4),%eax
801004e5:	c1 e0 04             	shl    $0x4,%eax
801004e8:	8d 58 50             	lea    0x50(%eax),%ebx
801004eb:	e9 6a ff ff ff       	jmp    8010045a <cgaputc+0x5a>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004f0:	83 ec 04             	sub    $0x4,%esp
    pos -= 80;
801004f3:	8d 7b b0             	lea    -0x50(%ebx),%edi
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004f6:	8d b4 1b 60 7f 0b 80 	lea    -0x7ff480a0(%ebx,%ebx,1),%esi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004fd:	68 60 0e 00 00       	push   $0xe60
80100502:	68 a0 80 0b 80       	push   $0x800b80a0
80100507:	68 00 80 0b 80       	push   $0x800b8000
8010050c:	e8 4f 43 00 00       	call   80104860 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100511:	b8 80 07 00 00       	mov    $0x780,%eax
80100516:	83 c4 0c             	add    $0xc,%esp
80100519:	29 f8                	sub    %edi,%eax
8010051b:	01 c0                	add    %eax,%eax
8010051d:	50                   	push   %eax
8010051e:	6a 00                	push   $0x0
80100520:	56                   	push   %esi
80100521:	e8 9a 42 00 00       	call   801047c0 <memset>
  outb(CRTPORT+1, pos);
80100526:	c6 45 e4 07          	movb   $0x7,-0x1c(%ebp)
8010052a:	83 c4 10             	add    $0x10,%esp
8010052d:	e9 4f ff ff ff       	jmp    80100481 <cgaputc+0x81>
    panic("pos under/overflow");
80100532:	83 ec 0c             	sub    $0xc,%esp
80100535:	68 45 74 10 80       	push   $0x80107445
8010053a:	e8 41 fe ff ff       	call   80100380 <panic>
8010053f:	90                   	nop

80100540 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100540:	55                   	push   %ebp
80100541:	89 e5                	mov    %esp,%ebp
80100543:	57                   	push   %edi
80100544:	56                   	push   %esi
80100545:	53                   	push   %ebx
80100546:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100549:	ff 75 08             	push   0x8(%ebp)
{
8010054c:	8b 75 10             	mov    0x10(%ebp),%esi
  iunlock(ip);
8010054f:	e8 2c 14 00 00       	call   80101980 <iunlock>
  acquire(&cons.lock);
80100554:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
8010055b:	e8 a0 41 00 00       	call   80104700 <acquire>
  for(i = 0; i < n; i++)
80100560:	83 c4 10             	add    $0x10,%esp
80100563:	85 f6                	test   %esi,%esi
80100565:	7e 3a                	jle    801005a1 <consolewrite+0x61>
80100567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010056a:	8d 3c 33             	lea    (%ebx,%esi,1),%edi
  if(panicked){
8010056d:	8b 15 58 ef 10 80    	mov    0x8010ef58,%edx
80100573:	85 d2                	test   %edx,%edx
80100575:	74 09                	je     80100580 <consolewrite+0x40>
  asm volatile("cli");
80100577:	fa                   	cli    
    for(;;)
80100578:	eb fe                	jmp    80100578 <consolewrite+0x38>
8010057a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    consputc(buf[i] & 0xff);
80100580:	0f b6 03             	movzbl (%ebx),%eax
    uartputc(c);
80100583:	83 ec 0c             	sub    $0xc,%esp
  for(i = 0; i < n; i++)
80100586:	83 c3 01             	add    $0x1,%ebx
    uartputc(c);
80100589:	50                   	push   %eax
8010058a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010058d:	e8 7e 59 00 00       	call   80105f10 <uartputc>
  cgaputc(c);
80100592:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100595:	e8 66 fe ff ff       	call   80100400 <cgaputc>
  for(i = 0; i < n; i++)
8010059a:	83 c4 10             	add    $0x10,%esp
8010059d:	39 df                	cmp    %ebx,%edi
8010059f:	75 cc                	jne    8010056d <consolewrite+0x2d>
  release(&cons.lock);
801005a1:	83 ec 0c             	sub    $0xc,%esp
801005a4:	68 20 ef 10 80       	push   $0x8010ef20
801005a9:	e8 f2 40 00 00       	call   801046a0 <release>
  ilock(ip);
801005ae:	58                   	pop    %eax
801005af:	ff 75 08             	push   0x8(%ebp)
801005b2:	e8 e9 12 00 00       	call   801018a0 <ilock>

  return n;
}
801005b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801005ba:	89 f0                	mov    %esi,%eax
801005bc:	5b                   	pop    %ebx
801005bd:	5e                   	pop    %esi
801005be:	5f                   	pop    %edi
801005bf:	5d                   	pop    %ebp
801005c0:	c3                   	ret    
801005c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801005c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801005cf:	90                   	nop

801005d0 <printint>:
{
801005d0:	55                   	push   %ebp
801005d1:	89 e5                	mov    %esp,%ebp
801005d3:	57                   	push   %edi
801005d4:	56                   	push   %esi
801005d5:	53                   	push   %ebx
801005d6:	83 ec 2c             	sub    $0x2c,%esp
801005d9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801005dc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  if(sign && (sign = xx < 0))
801005df:	85 c9                	test   %ecx,%ecx
801005e1:	74 04                	je     801005e7 <printint+0x17>
801005e3:	85 c0                	test   %eax,%eax
801005e5:	78 7e                	js     80100665 <printint+0x95>
    x = xx;
801005e7:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
801005ee:	89 c1                	mov    %eax,%ecx
  i = 0;
801005f0:	31 db                	xor    %ebx,%ebx
801005f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    buf[i++] = digits[x % base];
801005f8:	89 c8                	mov    %ecx,%eax
801005fa:	31 d2                	xor    %edx,%edx
801005fc:	89 de                	mov    %ebx,%esi
801005fe:	89 cf                	mov    %ecx,%edi
80100600:	f7 75 d4             	divl   -0x2c(%ebp)
80100603:	8d 5b 01             	lea    0x1(%ebx),%ebx
80100606:	0f b6 92 70 74 10 80 	movzbl -0x7fef8b90(%edx),%edx
  }while((x /= base) != 0);
8010060d:	89 c1                	mov    %eax,%ecx
    buf[i++] = digits[x % base];
8010060f:	88 54 1d d7          	mov    %dl,-0x29(%ebp,%ebx,1)
  }while((x /= base) != 0);
80100613:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
80100616:	73 e0                	jae    801005f8 <printint+0x28>
  if(sign)
80100618:	8b 4d d0             	mov    -0x30(%ebp),%ecx
8010061b:	85 c9                	test   %ecx,%ecx
8010061d:	74 0c                	je     8010062b <printint+0x5b>
    buf[i++] = '-';
8010061f:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    buf[i++] = digits[x % base];
80100624:	89 de                	mov    %ebx,%esi
    buf[i++] = '-';
80100626:	ba 2d 00 00 00       	mov    $0x2d,%edx
  while(--i >= 0)
8010062b:	8d 5c 35 d7          	lea    -0x29(%ebp,%esi,1),%ebx
  if(panicked){
8010062f:	a1 58 ef 10 80       	mov    0x8010ef58,%eax
80100634:	85 c0                	test   %eax,%eax
80100636:	74 08                	je     80100640 <printint+0x70>
80100638:	fa                   	cli    
    for(;;)
80100639:	eb fe                	jmp    80100639 <printint+0x69>
8010063b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010063f:	90                   	nop
    consputc(buf[i]);
80100640:	0f be f2             	movsbl %dl,%esi
    uartputc(c);
80100643:	83 ec 0c             	sub    $0xc,%esp
80100646:	56                   	push   %esi
80100647:	e8 c4 58 00 00       	call   80105f10 <uartputc>
  cgaputc(c);
8010064c:	89 f0                	mov    %esi,%eax
8010064e:	e8 ad fd ff ff       	call   80100400 <cgaputc>
  while(--i >= 0)
80100653:	8d 45 d7             	lea    -0x29(%ebp),%eax
80100656:	83 c4 10             	add    $0x10,%esp
80100659:	39 c3                	cmp    %eax,%ebx
8010065b:	74 0e                	je     8010066b <printint+0x9b>
    consputc(buf[i]);
8010065d:	0f b6 13             	movzbl (%ebx),%edx
80100660:	83 eb 01             	sub    $0x1,%ebx
80100663:	eb ca                	jmp    8010062f <printint+0x5f>
    x = -xx;
80100665:	f7 d8                	neg    %eax
80100667:	89 c1                	mov    %eax,%ecx
80100669:	eb 85                	jmp    801005f0 <printint+0x20>
}
8010066b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010066e:	5b                   	pop    %ebx
8010066f:	5e                   	pop    %esi
80100670:	5f                   	pop    %edi
80100671:	5d                   	pop    %ebp
80100672:	c3                   	ret    
80100673:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010067a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100680 <cprintf>:
{
80100680:	55                   	push   %ebp
80100681:	89 e5                	mov    %esp,%ebp
80100683:	57                   	push   %edi
80100684:	56                   	push   %esi
80100685:	53                   	push   %ebx
80100686:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100689:	a1 54 ef 10 80       	mov    0x8010ef54,%eax
8010068e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
80100691:	85 c0                	test   %eax,%eax
80100693:	0f 85 37 01 00 00    	jne    801007d0 <cprintf+0x150>
  if (fmt == 0)
80100699:	8b 75 08             	mov    0x8(%ebp),%esi
8010069c:	85 f6                	test   %esi,%esi
8010069e:	0f 84 3f 02 00 00    	je     801008e3 <cprintf+0x263>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006a4:	0f b6 06             	movzbl (%esi),%eax
  argp = (uint*)(void*)(&fmt + 1);
801006a7:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006aa:	31 db                	xor    %ebx,%ebx
801006ac:	85 c0                	test   %eax,%eax
801006ae:	74 56                	je     80100706 <cprintf+0x86>
    if(c != '%'){
801006b0:	83 f8 25             	cmp    $0x25,%eax
801006b3:	0f 85 d7 00 00 00    	jne    80100790 <cprintf+0x110>
    c = fmt[++i] & 0xff;
801006b9:	83 c3 01             	add    $0x1,%ebx
801006bc:	0f b6 14 1e          	movzbl (%esi,%ebx,1),%edx
    if(c == 0)
801006c0:	85 d2                	test   %edx,%edx
801006c2:	74 42                	je     80100706 <cprintf+0x86>
    switch(c){
801006c4:	83 fa 70             	cmp    $0x70,%edx
801006c7:	0f 84 94 00 00 00    	je     80100761 <cprintf+0xe1>
801006cd:	7f 51                	jg     80100720 <cprintf+0xa0>
801006cf:	83 fa 25             	cmp    $0x25,%edx
801006d2:	0f 84 48 01 00 00    	je     80100820 <cprintf+0x1a0>
801006d8:	83 fa 64             	cmp    $0x64,%edx
801006db:	0f 85 04 01 00 00    	jne    801007e5 <cprintf+0x165>
      printint(*argp++, 10, 1);
801006e1:	8d 47 04             	lea    0x4(%edi),%eax
801006e4:	b9 01 00 00 00       	mov    $0x1,%ecx
801006e9:	ba 0a 00 00 00       	mov    $0xa,%edx
801006ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
801006f1:	8b 07                	mov    (%edi),%eax
801006f3:	e8 d8 fe ff ff       	call   801005d0 <printint>
801006f8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006fb:	83 c3 01             	add    $0x1,%ebx
801006fe:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
80100702:	85 c0                	test   %eax,%eax
80100704:	75 aa                	jne    801006b0 <cprintf+0x30>
  if(locking)
80100706:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100709:	85 c0                	test   %eax,%eax
8010070b:	0f 85 b5 01 00 00    	jne    801008c6 <cprintf+0x246>
}
80100711:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100714:	5b                   	pop    %ebx
80100715:	5e                   	pop    %esi
80100716:	5f                   	pop    %edi
80100717:	5d                   	pop    %ebp
80100718:	c3                   	ret    
80100719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(c){
80100720:	83 fa 73             	cmp    $0x73,%edx
80100723:	75 33                	jne    80100758 <cprintf+0xd8>
      if((s = (char*)*argp++) == 0)
80100725:	8d 47 04             	lea    0x4(%edi),%eax
80100728:	8b 3f                	mov    (%edi),%edi
8010072a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010072d:	85 ff                	test   %edi,%edi
8010072f:	0f 85 33 01 00 00    	jne    80100868 <cprintf+0x1e8>
        s = "(null)";
80100735:	bf 58 74 10 80       	mov    $0x80107458,%edi
      for(; *s; s++)
8010073a:	89 5d dc             	mov    %ebx,-0x24(%ebp)
8010073d:	b8 28 00 00 00       	mov    $0x28,%eax
80100742:	89 fb                	mov    %edi,%ebx
  if(panicked){
80100744:	8b 15 58 ef 10 80    	mov    0x8010ef58,%edx
8010074a:	85 d2                	test   %edx,%edx
8010074c:	0f 84 27 01 00 00    	je     80100879 <cprintf+0x1f9>
80100752:	fa                   	cli    
    for(;;)
80100753:	eb fe                	jmp    80100753 <cprintf+0xd3>
80100755:	8d 76 00             	lea    0x0(%esi),%esi
    switch(c){
80100758:	83 fa 78             	cmp    $0x78,%edx
8010075b:	0f 85 84 00 00 00    	jne    801007e5 <cprintf+0x165>
      printint(*argp++, 16, 0);
80100761:	8d 47 04             	lea    0x4(%edi),%eax
80100764:	31 c9                	xor    %ecx,%ecx
80100766:	ba 10 00 00 00       	mov    $0x10,%edx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010076b:	83 c3 01             	add    $0x1,%ebx
      printint(*argp++, 16, 0);
8010076e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100771:	8b 07                	mov    (%edi),%eax
80100773:	e8 58 fe ff ff       	call   801005d0 <printint>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100778:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
      printint(*argp++, 16, 0);
8010077c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010077f:	85 c0                	test   %eax,%eax
80100781:	0f 85 29 ff ff ff    	jne    801006b0 <cprintf+0x30>
80100787:	e9 7a ff ff ff       	jmp    80100706 <cprintf+0x86>
8010078c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(panicked){
80100790:	8b 0d 58 ef 10 80    	mov    0x8010ef58,%ecx
80100796:	85 c9                	test   %ecx,%ecx
80100798:	74 06                	je     801007a0 <cprintf+0x120>
8010079a:	fa                   	cli    
    for(;;)
8010079b:	eb fe                	jmp    8010079b <cprintf+0x11b>
8010079d:	8d 76 00             	lea    0x0(%esi),%esi
    uartputc(c);
801007a0:	83 ec 0c             	sub    $0xc,%esp
801007a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007a6:	83 c3 01             	add    $0x1,%ebx
    uartputc(c);
801007a9:	50                   	push   %eax
801007aa:	e8 61 57 00 00       	call   80105f10 <uartputc>
  cgaputc(c);
801007af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801007b2:	e8 49 fc ff ff       	call   80100400 <cgaputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007b7:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
      continue;
801007bb:	83 c4 10             	add    $0x10,%esp
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007be:	85 c0                	test   %eax,%eax
801007c0:	0f 85 ea fe ff ff    	jne    801006b0 <cprintf+0x30>
801007c6:	e9 3b ff ff ff       	jmp    80100706 <cprintf+0x86>
801007cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801007cf:	90                   	nop
    acquire(&cons.lock);
801007d0:	83 ec 0c             	sub    $0xc,%esp
801007d3:	68 20 ef 10 80       	push   $0x8010ef20
801007d8:	e8 23 3f 00 00       	call   80104700 <acquire>
801007dd:	83 c4 10             	add    $0x10,%esp
801007e0:	e9 b4 fe ff ff       	jmp    80100699 <cprintf+0x19>
  if(panicked){
801007e5:	8b 0d 58 ef 10 80    	mov    0x8010ef58,%ecx
801007eb:	85 c9                	test   %ecx,%ecx
801007ed:	75 71                	jne    80100860 <cprintf+0x1e0>
    uartputc(c);
801007ef:	83 ec 0c             	sub    $0xc,%esp
801007f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
801007f5:	6a 25                	push   $0x25
801007f7:	e8 14 57 00 00       	call   80105f10 <uartputc>
  cgaputc(c);
801007fc:	b8 25 00 00 00       	mov    $0x25,%eax
80100801:	e8 fa fb ff ff       	call   80100400 <cgaputc>
  if(panicked){
80100806:	8b 15 58 ef 10 80    	mov    0x8010ef58,%edx
8010080c:	83 c4 10             	add    $0x10,%esp
8010080f:	85 d2                	test   %edx,%edx
80100811:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100814:	0f 84 8e 00 00 00    	je     801008a8 <cprintf+0x228>
8010081a:	fa                   	cli    
    for(;;)
8010081b:	eb fe                	jmp    8010081b <cprintf+0x19b>
8010081d:	8d 76 00             	lea    0x0(%esi),%esi
  if(panicked){
80100820:	a1 58 ef 10 80       	mov    0x8010ef58,%eax
80100825:	85 c0                	test   %eax,%eax
80100827:	74 07                	je     80100830 <cprintf+0x1b0>
80100829:	fa                   	cli    
    for(;;)
8010082a:	eb fe                	jmp    8010082a <cprintf+0x1aa>
8010082c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    uartputc(c);
80100830:	83 ec 0c             	sub    $0xc,%esp
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100833:	83 c3 01             	add    $0x1,%ebx
    uartputc(c);
80100836:	6a 25                	push   $0x25
80100838:	e8 d3 56 00 00       	call   80105f10 <uartputc>
  cgaputc(c);
8010083d:	b8 25 00 00 00       	mov    $0x25,%eax
80100842:	e8 b9 fb ff ff       	call   80100400 <cgaputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100847:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
}
8010084b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010084e:	85 c0                	test   %eax,%eax
80100850:	0f 85 5a fe ff ff    	jne    801006b0 <cprintf+0x30>
80100856:	e9 ab fe ff ff       	jmp    80100706 <cprintf+0x86>
8010085b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010085f:	90                   	nop
80100860:	fa                   	cli    
    for(;;)
80100861:	eb fe                	jmp    80100861 <cprintf+0x1e1>
80100863:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100867:	90                   	nop
      for(; *s; s++)
80100868:	0f b6 07             	movzbl (%edi),%eax
8010086b:	84 c0                	test   %al,%al
8010086d:	74 6c                	je     801008db <cprintf+0x25b>
8010086f:	89 5d dc             	mov    %ebx,-0x24(%ebp)
80100872:	89 fb                	mov    %edi,%ebx
80100874:	e9 cb fe ff ff       	jmp    80100744 <cprintf+0xc4>
    uartputc(c);
80100879:	83 ec 0c             	sub    $0xc,%esp
        consputc(*s);
8010087c:	0f be f8             	movsbl %al,%edi
      for(; *s; s++)
8010087f:	83 c3 01             	add    $0x1,%ebx
    uartputc(c);
80100882:	57                   	push   %edi
80100883:	e8 88 56 00 00       	call   80105f10 <uartputc>
  cgaputc(c);
80100888:	89 f8                	mov    %edi,%eax
8010088a:	e8 71 fb ff ff       	call   80100400 <cgaputc>
      for(; *s; s++)
8010088f:	0f b6 03             	movzbl (%ebx),%eax
80100892:	83 c4 10             	add    $0x10,%esp
80100895:	84 c0                	test   %al,%al
80100897:	0f 85 a7 fe ff ff    	jne    80100744 <cprintf+0xc4>
      if((s = (char*)*argp++) == 0)
8010089d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
801008a0:	8b 7d e0             	mov    -0x20(%ebp),%edi
801008a3:	e9 53 fe ff ff       	jmp    801006fb <cprintf+0x7b>
    uartputc(c);
801008a8:	83 ec 0c             	sub    $0xc,%esp
801008ab:	89 55 e0             	mov    %edx,-0x20(%ebp)
801008ae:	52                   	push   %edx
801008af:	e8 5c 56 00 00       	call   80105f10 <uartputc>
  cgaputc(c);
801008b4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801008b7:	89 d0                	mov    %edx,%eax
801008b9:	e8 42 fb ff ff       	call   80100400 <cgaputc>
}
801008be:	83 c4 10             	add    $0x10,%esp
801008c1:	e9 35 fe ff ff       	jmp    801006fb <cprintf+0x7b>
    release(&cons.lock);
801008c6:	83 ec 0c             	sub    $0xc,%esp
801008c9:	68 20 ef 10 80       	push   $0x8010ef20
801008ce:	e8 cd 3d 00 00       	call   801046a0 <release>
801008d3:	83 c4 10             	add    $0x10,%esp
}
801008d6:	e9 36 fe ff ff       	jmp    80100711 <cprintf+0x91>
      if((s = (char*)*argp++) == 0)
801008db:	8b 7d e0             	mov    -0x20(%ebp),%edi
801008de:	e9 18 fe ff ff       	jmp    801006fb <cprintf+0x7b>
    panic("null fmt");
801008e3:	83 ec 0c             	sub    $0xc,%esp
801008e6:	68 5f 74 10 80       	push   $0x8010745f
801008eb:	e8 90 fa ff ff       	call   80100380 <panic>

801008f0 <consoleintr>:
{
801008f0:	55                   	push   %ebp
801008f1:	89 e5                	mov    %esp,%ebp
801008f3:	57                   	push   %edi
801008f4:	56                   	push   %esi
801008f5:	53                   	push   %ebx
  int c, doprocdump = 0;
801008f6:	31 db                	xor    %ebx,%ebx
{
801008f8:	83 ec 28             	sub    $0x28,%esp
801008fb:	8b 75 08             	mov    0x8(%ebp),%esi
  acquire(&cons.lock);
801008fe:	68 20 ef 10 80       	push   $0x8010ef20
80100903:	e8 f8 3d 00 00       	call   80104700 <acquire>
  while((c = getc()) >= 0){
80100908:	83 c4 10             	add    $0x10,%esp
8010090b:	eb 1a                	jmp    80100927 <consoleintr+0x37>
8010090d:	8d 76 00             	lea    0x0(%esi),%esi
    switch(c){
80100910:	83 f8 08             	cmp    $0x8,%eax
80100913:	0f 84 17 01 00 00    	je     80100a30 <consoleintr+0x140>
80100919:	83 f8 10             	cmp    $0x10,%eax
8010091c:	0f 85 9a 01 00 00    	jne    80100abc <consoleintr+0x1cc>
80100922:	bb 01 00 00 00       	mov    $0x1,%ebx
  while((c = getc()) >= 0){
80100927:	ff d6                	call   *%esi
80100929:	85 c0                	test   %eax,%eax
8010092b:	0f 88 6f 01 00 00    	js     80100aa0 <consoleintr+0x1b0>
    switch(c){
80100931:	83 f8 15             	cmp    $0x15,%eax
80100934:	0f 84 b6 00 00 00    	je     801009f0 <consoleintr+0x100>
8010093a:	7e d4                	jle    80100910 <consoleintr+0x20>
8010093c:	83 f8 7f             	cmp    $0x7f,%eax
8010093f:	0f 84 eb 00 00 00    	je     80100a30 <consoleintr+0x140>
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100945:	8b 15 08 ef 10 80    	mov    0x8010ef08,%edx
8010094b:	89 d1                	mov    %edx,%ecx
8010094d:	2b 0d 00 ef 10 80    	sub    0x8010ef00,%ecx
80100953:	83 f9 7f             	cmp    $0x7f,%ecx
80100956:	77 cf                	ja     80100927 <consoleintr+0x37>
        input.buf[input.e++ % INPUT_BUF] = c;
80100958:	89 d1                	mov    %edx,%ecx
8010095a:	83 c2 01             	add    $0x1,%edx
  if(panicked){
8010095d:	8b 3d 58 ef 10 80    	mov    0x8010ef58,%edi
        input.buf[input.e++ % INPUT_BUF] = c;
80100963:	89 15 08 ef 10 80    	mov    %edx,0x8010ef08
80100969:	83 e1 7f             	and    $0x7f,%ecx
        c = (c == '\r') ? '\n' : c;
8010096c:	83 f8 0d             	cmp    $0xd,%eax
8010096f:	0f 84 9b 01 00 00    	je     80100b10 <consoleintr+0x220>
        input.buf[input.e++ % INPUT_BUF] = c;
80100975:	88 81 80 ee 10 80    	mov    %al,-0x7fef1180(%ecx)
  if(panicked){
8010097b:	85 ff                	test   %edi,%edi
8010097d:	0f 85 98 01 00 00    	jne    80100b1b <consoleintr+0x22b>
  if(c == BACKSPACE){
80100983:	3d 00 01 00 00       	cmp    $0x100,%eax
80100988:	0f 85 b3 01 00 00    	jne    80100b41 <consoleintr+0x251>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010098e:	83 ec 0c             	sub    $0xc,%esp
80100991:	6a 08                	push   $0x8
80100993:	e8 78 55 00 00       	call   80105f10 <uartputc>
80100998:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010099f:	e8 6c 55 00 00       	call   80105f10 <uartputc>
801009a4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801009ab:	e8 60 55 00 00       	call   80105f10 <uartputc>
  cgaputc(c);
801009b0:	b8 00 01 00 00       	mov    $0x100,%eax
801009b5:	e8 46 fa ff ff       	call   80100400 <cgaputc>
801009ba:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009bd:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
801009c2:	83 e8 80             	sub    $0xffffff80,%eax
801009c5:	39 05 08 ef 10 80    	cmp    %eax,0x8010ef08
801009cb:	0f 85 56 ff ff ff    	jne    80100927 <consoleintr+0x37>
          wakeup(&input.r);
801009d1:	83 ec 0c             	sub    $0xc,%esp
          input.w = input.e;
801009d4:	a3 04 ef 10 80       	mov    %eax,0x8010ef04
          wakeup(&input.r);
801009d9:	68 00 ef 10 80       	push   $0x8010ef00
801009de:	e8 7d 38 00 00       	call   80104260 <wakeup>
801009e3:	83 c4 10             	add    $0x10,%esp
801009e6:	e9 3c ff ff ff       	jmp    80100927 <consoleintr+0x37>
801009eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801009ef:	90                   	nop
      while(input.e != input.w &&
801009f0:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
801009f5:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
801009fb:	0f 84 26 ff ff ff    	je     80100927 <consoleintr+0x37>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100a01:	83 e8 01             	sub    $0x1,%eax
80100a04:	89 c2                	mov    %eax,%edx
80100a06:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100a09:	80 ba 80 ee 10 80 0a 	cmpb   $0xa,-0x7fef1180(%edx)
80100a10:	0f 84 11 ff ff ff    	je     80100927 <consoleintr+0x37>
  if(panicked){
80100a16:	8b 15 58 ef 10 80    	mov    0x8010ef58,%edx
        input.e--;
80100a1c:	a3 08 ef 10 80       	mov    %eax,0x8010ef08
  if(panicked){
80100a21:	85 d2                	test   %edx,%edx
80100a23:	74 33                	je     80100a58 <consoleintr+0x168>
80100a25:	fa                   	cli    
    for(;;)
80100a26:	eb fe                	jmp    80100a26 <consoleintr+0x136>
80100a28:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a2f:	90                   	nop
      if(input.e != input.w){
80100a30:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
80100a35:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
80100a3b:	0f 84 e6 fe ff ff    	je     80100927 <consoleintr+0x37>
        input.e--;
80100a41:	83 e8 01             	sub    $0x1,%eax
80100a44:	a3 08 ef 10 80       	mov    %eax,0x8010ef08
  if(panicked){
80100a49:	a1 58 ef 10 80       	mov    0x8010ef58,%eax
80100a4e:	85 c0                	test   %eax,%eax
80100a50:	74 7e                	je     80100ad0 <consoleintr+0x1e0>
80100a52:	fa                   	cli    
    for(;;)
80100a53:	eb fe                	jmp    80100a53 <consoleintr+0x163>
80100a55:	8d 76 00             	lea    0x0(%esi),%esi
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100a58:	83 ec 0c             	sub    $0xc,%esp
80100a5b:	6a 08                	push   $0x8
80100a5d:	e8 ae 54 00 00       	call   80105f10 <uartputc>
80100a62:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100a69:	e8 a2 54 00 00       	call   80105f10 <uartputc>
80100a6e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100a75:	e8 96 54 00 00       	call   80105f10 <uartputc>
  cgaputc(c);
80100a7a:	b8 00 01 00 00       	mov    $0x100,%eax
80100a7f:	e8 7c f9 ff ff       	call   80100400 <cgaputc>
      while(input.e != input.w &&
80100a84:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
80100a89:	83 c4 10             	add    $0x10,%esp
80100a8c:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
80100a92:	0f 85 69 ff ff ff    	jne    80100a01 <consoleintr+0x111>
80100a98:	e9 8a fe ff ff       	jmp    80100927 <consoleintr+0x37>
80100a9d:	8d 76 00             	lea    0x0(%esi),%esi
  release(&cons.lock);
80100aa0:	83 ec 0c             	sub    $0xc,%esp
80100aa3:	68 20 ef 10 80       	push   $0x8010ef20
80100aa8:	e8 f3 3b 00 00       	call   801046a0 <release>
  if(doprocdump) {
80100aad:	83 c4 10             	add    $0x10,%esp
80100ab0:	85 db                	test   %ebx,%ebx
80100ab2:	75 50                	jne    80100b04 <consoleintr+0x214>
}
80100ab4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100ab7:	5b                   	pop    %ebx
80100ab8:	5e                   	pop    %esi
80100ab9:	5f                   	pop    %edi
80100aba:	5d                   	pop    %ebp
80100abb:	c3                   	ret    
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100abc:	85 c0                	test   %eax,%eax
80100abe:	0f 84 63 fe ff ff    	je     80100927 <consoleintr+0x37>
80100ac4:	e9 7c fe ff ff       	jmp    80100945 <consoleintr+0x55>
80100ac9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100ad0:	83 ec 0c             	sub    $0xc,%esp
80100ad3:	6a 08                	push   $0x8
80100ad5:	e8 36 54 00 00       	call   80105f10 <uartputc>
80100ada:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100ae1:	e8 2a 54 00 00       	call   80105f10 <uartputc>
80100ae6:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100aed:	e8 1e 54 00 00       	call   80105f10 <uartputc>
  cgaputc(c);
80100af2:	b8 00 01 00 00       	mov    $0x100,%eax
80100af7:	e8 04 f9 ff ff       	call   80100400 <cgaputc>
}
80100afc:	83 c4 10             	add    $0x10,%esp
80100aff:	e9 23 fe ff ff       	jmp    80100927 <consoleintr+0x37>
}
80100b04:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100b07:	5b                   	pop    %ebx
80100b08:	5e                   	pop    %esi
80100b09:	5f                   	pop    %edi
80100b0a:	5d                   	pop    %ebp
    procdump();  // now call procdump() wo. cons.lock held
80100b0b:	e9 30 38 00 00       	jmp    80104340 <procdump>
        input.buf[input.e++ % INPUT_BUF] = c;
80100b10:	c6 81 80 ee 10 80 0a 	movb   $0xa,-0x7fef1180(%ecx)
  if(panicked){
80100b17:	85 ff                	test   %edi,%edi
80100b19:	74 05                	je     80100b20 <consoleintr+0x230>
80100b1b:	fa                   	cli    
    for(;;)
80100b1c:	eb fe                	jmp    80100b1c <consoleintr+0x22c>
80100b1e:	66 90                	xchg   %ax,%ax
    uartputc(c);
80100b20:	83 ec 0c             	sub    $0xc,%esp
80100b23:	6a 0a                	push   $0xa
80100b25:	e8 e6 53 00 00       	call   80105f10 <uartputc>
  cgaputc(c);
80100b2a:	b8 0a 00 00 00       	mov    $0xa,%eax
80100b2f:	e8 cc f8 ff ff       	call   80100400 <cgaputc>
          input.w = input.e;
80100b34:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
80100b39:	83 c4 10             	add    $0x10,%esp
80100b3c:	e9 90 fe ff ff       	jmp    801009d1 <consoleintr+0xe1>
    uartputc(c);
80100b41:	83 ec 0c             	sub    $0xc,%esp
80100b44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100b47:	50                   	push   %eax
80100b48:	e8 c3 53 00 00       	call   80105f10 <uartputc>
  cgaputc(c);
80100b4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b50:	e8 ab f8 ff ff       	call   80100400 <cgaputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100b55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b58:	83 c4 10             	add    $0x10,%esp
80100b5b:	83 f8 0a             	cmp    $0xa,%eax
80100b5e:	74 09                	je     80100b69 <consoleintr+0x279>
80100b60:	83 f8 04             	cmp    $0x4,%eax
80100b63:	0f 85 54 fe ff ff    	jne    801009bd <consoleintr+0xcd>
          input.w = input.e;
80100b69:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
80100b6e:	e9 5e fe ff ff       	jmp    801009d1 <consoleintr+0xe1>
80100b73:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100b7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100b80 <consoleinit>:

void
consoleinit(void)
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100b86:	68 68 74 10 80       	push   $0x80107468
80100b8b:	68 20 ef 10 80       	push   $0x8010ef20
80100b90:	e8 9b 39 00 00       	call   80104530 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  ioapicenable(IRQ_KBD, 0);
80100b95:	58                   	pop    %eax
80100b96:	5a                   	pop    %edx
80100b97:	6a 00                	push   $0x0
80100b99:	6a 01                	push   $0x1
  devsw[CONSOLE].write = consolewrite;
80100b9b:	c7 05 0c f9 10 80 40 	movl   $0x80100540,0x8010f90c
80100ba2:	05 10 80 
  devsw[CONSOLE].read = consoleread;
80100ba5:	c7 05 08 f9 10 80 80 	movl   $0x80100280,0x8010f908
80100bac:	02 10 80 
  cons.locking = 1;
80100baf:	c7 05 54 ef 10 80 01 	movl   $0x1,0x8010ef54
80100bb6:	00 00 00 
  ioapicenable(IRQ_KBD, 0);
80100bb9:	e8 e2 19 00 00       	call   801025a0 <ioapicenable>
}
80100bbe:	83 c4 10             	add    $0x10,%esp
80100bc1:	c9                   	leave  
80100bc2:	c3                   	ret    
80100bc3:	66 90                	xchg   %ax,%ax
80100bc5:	66 90                	xchg   %ax,%ax
80100bc7:	66 90                	xchg   %ax,%ax
80100bc9:	66 90                	xchg   %ax,%ax
80100bcb:	66 90                	xchg   %ax,%ax
80100bcd:	66 90                	xchg   %ax,%ax
80100bcf:	90                   	nop

80100bd0 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100bd0:	55                   	push   %ebp
80100bd1:	89 e5                	mov    %esp,%ebp
80100bd3:	57                   	push   %edi
80100bd4:	56                   	push   %esi
80100bd5:	53                   	push   %ebx
80100bd6:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bdc:	e8 ef 2e 00 00       	call   80103ad0 <myproc>
80100be1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100be7:	e8 94 22 00 00       	call   80102e80 <begin_op>

  if((ip = namei(path)) == 0){
80100bec:	83 ec 0c             	sub    $0xc,%esp
80100bef:	ff 75 08             	push   0x8(%ebp)
80100bf2:	e8 c9 15 00 00       	call   801021c0 <namei>
80100bf7:	83 c4 10             	add    $0x10,%esp
80100bfa:	85 c0                	test   %eax,%eax
80100bfc:	0f 84 02 03 00 00    	je     80100f04 <exec+0x334>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100c02:	83 ec 0c             	sub    $0xc,%esp
80100c05:	89 c3                	mov    %eax,%ebx
80100c07:	50                   	push   %eax
80100c08:	e8 93 0c 00 00       	call   801018a0 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c0d:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100c13:	6a 34                	push   $0x34
80100c15:	6a 00                	push   $0x0
80100c17:	50                   	push   %eax
80100c18:	53                   	push   %ebx
80100c19:	e8 92 0f 00 00       	call   80101bb0 <readi>
80100c1e:	83 c4 20             	add    $0x20,%esp
80100c21:	83 f8 34             	cmp    $0x34,%eax
80100c24:	74 22                	je     80100c48 <exec+0x78>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
80100c26:	83 ec 0c             	sub    $0xc,%esp
80100c29:	53                   	push   %ebx
80100c2a:	e8 01 0f 00 00       	call   80101b30 <iunlockput>
    end_op();
80100c2f:	e8 bc 22 00 00       	call   80102ef0 <end_op>
80100c34:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100c37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100c3f:	5b                   	pop    %ebx
80100c40:	5e                   	pop    %esi
80100c41:	5f                   	pop    %edi
80100c42:	5d                   	pop    %ebp
80100c43:	c3                   	ret    
80100c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(elf.magic != ELF_MAGIC)
80100c48:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100c4f:	45 4c 46 
80100c52:	75 d2                	jne    80100c26 <exec+0x56>
  if((pgdir = setupkvm()) == 0)
80100c54:	e8 47 64 00 00       	call   801070a0 <setupkvm>
80100c59:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100c5f:	85 c0                	test   %eax,%eax
80100c61:	74 c3                	je     80100c26 <exec+0x56>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c63:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
80100c6a:	00 
80100c6b:	8b b5 40 ff ff ff    	mov    -0xc0(%ebp),%esi
80100c71:	0f 84 ac 02 00 00    	je     80100f23 <exec+0x353>
  sz = 0;
80100c77:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100c7e:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c81:	31 ff                	xor    %edi,%edi
80100c83:	e9 8e 00 00 00       	jmp    80100d16 <exec+0x146>
80100c88:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100c8f:	90                   	nop
    if(ph.type != ELF_PROG_LOAD)
80100c90:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100c97:	75 6c                	jne    80100d05 <exec+0x135>
    if(ph.memsz < ph.filesz)
80100c99:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100c9f:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100ca5:	0f 82 87 00 00 00    	jb     80100d32 <exec+0x162>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cab:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100cb1:	72 7f                	jb     80100d32 <exec+0x162>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cb3:	83 ec 04             	sub    $0x4,%esp
80100cb6:	50                   	push   %eax
80100cb7:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100cbd:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100cc3:	e8 f8 61 00 00       	call   80106ec0 <allocuvm>
80100cc8:	83 c4 10             	add    $0x10,%esp
80100ccb:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100cd1:	85 c0                	test   %eax,%eax
80100cd3:	74 5d                	je     80100d32 <exec+0x162>
    if(ph.vaddr % PGSIZE != 0)
80100cd5:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100cdb:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100ce0:	75 50                	jne    80100d32 <exec+0x162>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100ce2:	83 ec 0c             	sub    $0xc,%esp
80100ce5:	ff b5 14 ff ff ff    	push   -0xec(%ebp)
80100ceb:	ff b5 08 ff ff ff    	push   -0xf8(%ebp)
80100cf1:	53                   	push   %ebx
80100cf2:	50                   	push   %eax
80100cf3:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100cf9:	e8 d2 60 00 00       	call   80106dd0 <loaduvm>
80100cfe:	83 c4 20             	add    $0x20,%esp
80100d01:	85 c0                	test   %eax,%eax
80100d03:	78 2d                	js     80100d32 <exec+0x162>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d05:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
80100d0c:	83 c7 01             	add    $0x1,%edi
80100d0f:	83 c6 20             	add    $0x20,%esi
80100d12:	39 f8                	cmp    %edi,%eax
80100d14:	7e 3a                	jle    80100d50 <exec+0x180>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d16:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100d1c:	6a 20                	push   $0x20
80100d1e:	56                   	push   %esi
80100d1f:	50                   	push   %eax
80100d20:	53                   	push   %ebx
80100d21:	e8 8a 0e 00 00       	call   80101bb0 <readi>
80100d26:	83 c4 10             	add    $0x10,%esp
80100d29:	83 f8 20             	cmp    $0x20,%eax
80100d2c:	0f 84 5e ff ff ff    	je     80100c90 <exec+0xc0>
    freevm(pgdir);
80100d32:	83 ec 0c             	sub    $0xc,%esp
80100d35:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100d3b:	e8 e0 62 00 00       	call   80107020 <freevm>
  if(ip){
80100d40:	83 c4 10             	add    $0x10,%esp
80100d43:	e9 de fe ff ff       	jmp    80100c26 <exec+0x56>
80100d48:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100d4f:	90                   	nop
  sz = PGROUNDUP(sz);
80100d50:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100d56:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
80100d5c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d62:	8d b7 00 20 00 00    	lea    0x2000(%edi),%esi
  iunlockput(ip);
80100d68:	83 ec 0c             	sub    $0xc,%esp
80100d6b:	53                   	push   %ebx
80100d6c:	e8 bf 0d 00 00       	call   80101b30 <iunlockput>
  end_op();
80100d71:	e8 7a 21 00 00       	call   80102ef0 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d76:	83 c4 0c             	add    $0xc,%esp
80100d79:	56                   	push   %esi
80100d7a:	57                   	push   %edi
80100d7b:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
80100d81:	57                   	push   %edi
80100d82:	e8 39 61 00 00       	call   80106ec0 <allocuvm>
80100d87:	83 c4 10             	add    $0x10,%esp
80100d8a:	89 c6                	mov    %eax,%esi
80100d8c:	85 c0                	test   %eax,%eax
80100d8e:	0f 84 94 00 00 00    	je     80100e28 <exec+0x258>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d94:	83 ec 08             	sub    $0x8,%esp
80100d97:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
  for(argc = 0; argv[argc]; argc++) {
80100d9d:	89 f3                	mov    %esi,%ebx
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d9f:	50                   	push   %eax
80100da0:	57                   	push   %edi
  for(argc = 0; argv[argc]; argc++) {
80100da1:	31 ff                	xor    %edi,%edi
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100da3:	e8 98 63 00 00       	call   80107140 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100da8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dab:	83 c4 10             	add    $0x10,%esp
80100dae:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
80100db4:	8b 00                	mov    (%eax),%eax
80100db6:	85 c0                	test   %eax,%eax
80100db8:	0f 84 8b 00 00 00    	je     80100e49 <exec+0x279>
80100dbe:	89 b5 f0 fe ff ff    	mov    %esi,-0x110(%ebp)
80100dc4:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100dca:	eb 23                	jmp    80100def <exec+0x21f>
80100dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100dd0:	8b 45 0c             	mov    0xc(%ebp),%eax
    ustack[3+argc] = sp;
80100dd3:	89 9c bd 64 ff ff ff 	mov    %ebx,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100dda:	83 c7 01             	add    $0x1,%edi
    ustack[3+argc] = sp;
80100ddd:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
  for(argc = 0; argv[argc]; argc++) {
80100de3:	8b 04 b8             	mov    (%eax,%edi,4),%eax
80100de6:	85 c0                	test   %eax,%eax
80100de8:	74 59                	je     80100e43 <exec+0x273>
    if(argc >= MAXARG)
80100dea:	83 ff 20             	cmp    $0x20,%edi
80100ded:	74 39                	je     80100e28 <exec+0x258>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100def:	83 ec 0c             	sub    $0xc,%esp
80100df2:	50                   	push   %eax
80100df3:	e8 c8 3b 00 00       	call   801049c0 <strlen>
80100df8:	f7 d0                	not    %eax
80100dfa:	01 c3                	add    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100dfc:	58                   	pop    %eax
80100dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e00:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e03:	ff 34 b8             	push   (%eax,%edi,4)
80100e06:	e8 b5 3b 00 00       	call   801049c0 <strlen>
80100e0b:	83 c0 01             	add    $0x1,%eax
80100e0e:	50                   	push   %eax
80100e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e12:	ff 34 b8             	push   (%eax,%edi,4)
80100e15:	53                   	push   %ebx
80100e16:	56                   	push   %esi
80100e17:	e8 f4 64 00 00       	call   80107310 <copyout>
80100e1c:	83 c4 20             	add    $0x20,%esp
80100e1f:	85 c0                	test   %eax,%eax
80100e21:	79 ad                	jns    80100dd0 <exec+0x200>
80100e23:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100e27:	90                   	nop
    freevm(pgdir);
80100e28:	83 ec 0c             	sub    $0xc,%esp
80100e2b:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100e31:	e8 ea 61 00 00       	call   80107020 <freevm>
80100e36:	83 c4 10             	add    $0x10,%esp
  return -1;
80100e39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e3e:	e9 f9 fd ff ff       	jmp    80100c3c <exec+0x6c>
80100e43:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e49:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80100e50:	89 d9                	mov    %ebx,%ecx
  ustack[3+argc] = 0;
80100e52:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100e59:	00 00 00 00 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e5d:	29 c1                	sub    %eax,%ecx
  sp -= (3+argc+1) * 4;
80100e5f:	83 c0 0c             	add    $0xc,%eax
  ustack[1] = argc;
80100e62:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  sp -= (3+argc+1) * 4;
80100e68:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e6a:	50                   	push   %eax
80100e6b:	52                   	push   %edx
80100e6c:	53                   	push   %ebx
80100e6d:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
  ustack[0] = 0xffffffff;  // fake return PC
80100e73:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100e7a:	ff ff ff 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7d:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e83:	e8 88 64 00 00       	call   80107310 <copyout>
80100e88:	83 c4 10             	add    $0x10,%esp
80100e8b:	85 c0                	test   %eax,%eax
80100e8d:	78 99                	js     80100e28 <exec+0x258>
  for(last=s=path; *s; s++)
80100e8f:	8b 45 08             	mov    0x8(%ebp),%eax
80100e92:	8b 55 08             	mov    0x8(%ebp),%edx
80100e95:	0f b6 00             	movzbl (%eax),%eax
80100e98:	84 c0                	test   %al,%al
80100e9a:	74 13                	je     80100eaf <exec+0x2df>
80100e9c:	89 d1                	mov    %edx,%ecx
80100e9e:	66 90                	xchg   %ax,%ax
      last = s+1;
80100ea0:	83 c1 01             	add    $0x1,%ecx
80100ea3:	3c 2f                	cmp    $0x2f,%al
  for(last=s=path; *s; s++)
80100ea5:	0f b6 01             	movzbl (%ecx),%eax
      last = s+1;
80100ea8:	0f 44 d1             	cmove  %ecx,%edx
  for(last=s=path; *s; s++)
80100eab:	84 c0                	test   %al,%al
80100ead:	75 f1                	jne    80100ea0 <exec+0x2d0>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100eaf:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100eb5:	83 ec 04             	sub    $0x4,%esp
80100eb8:	6a 10                	push   $0x10
80100eba:	89 f8                	mov    %edi,%eax
80100ebc:	52                   	push   %edx
80100ebd:	83 c0 6c             	add    $0x6c,%eax
80100ec0:	50                   	push   %eax
80100ec1:	e8 ba 3a 00 00       	call   80104980 <safestrcpy>
  curproc->pgdir = pgdir;
80100ec6:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  oldpgdir = curproc->pgdir;
80100ecc:	89 f8                	mov    %edi,%eax
80100ece:	8b 7f 04             	mov    0x4(%edi),%edi
  curproc->sz = sz;
80100ed1:	89 30                	mov    %esi,(%eax)
  curproc->pgdir = pgdir;
80100ed3:	89 48 04             	mov    %ecx,0x4(%eax)
  curproc->tf->eip = elf.entry;  // main
80100ed6:	89 c1                	mov    %eax,%ecx
80100ed8:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100ede:	8b 40 18             	mov    0x18(%eax),%eax
80100ee1:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100ee4:	8b 41 18             	mov    0x18(%ecx),%eax
80100ee7:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100eea:	89 0c 24             	mov    %ecx,(%esp)
80100eed:	e8 4e 5d 00 00       	call   80106c40 <switchuvm>
  freevm(oldpgdir);
80100ef2:	89 3c 24             	mov    %edi,(%esp)
80100ef5:	e8 26 61 00 00       	call   80107020 <freevm>
  return 0;
80100efa:	83 c4 10             	add    $0x10,%esp
80100efd:	31 c0                	xor    %eax,%eax
80100eff:	e9 38 fd ff ff       	jmp    80100c3c <exec+0x6c>
    end_op();
80100f04:	e8 e7 1f 00 00       	call   80102ef0 <end_op>
    cprintf("exec: fail\n");
80100f09:	83 ec 0c             	sub    $0xc,%esp
80100f0c:	68 81 74 10 80       	push   $0x80107481
80100f11:	e8 6a f7 ff ff       	call   80100680 <cprintf>
    return -1;
80100f16:	83 c4 10             	add    $0x10,%esp
80100f19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f1e:	e9 19 fd ff ff       	jmp    80100c3c <exec+0x6c>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100f23:	31 ff                	xor    %edi,%edi
80100f25:	be 00 20 00 00       	mov    $0x2000,%esi
80100f2a:	e9 39 fe ff ff       	jmp    80100d68 <exec+0x198>
80100f2f:	90                   	nop

80100f30 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f30:	55                   	push   %ebp
80100f31:	89 e5                	mov    %esp,%ebp
80100f33:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100f36:	68 8d 74 10 80       	push   $0x8010748d
80100f3b:	68 60 ef 10 80       	push   $0x8010ef60
80100f40:	e8 eb 35 00 00       	call   80104530 <initlock>
}
80100f45:	83 c4 10             	add    $0x10,%esp
80100f48:	c9                   	leave  
80100f49:	c3                   	ret    
80100f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100f50 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f50:	55                   	push   %ebp
80100f51:	89 e5                	mov    %esp,%ebp
80100f53:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f54:	bb 94 ef 10 80       	mov    $0x8010ef94,%ebx
{
80100f59:	83 ec 10             	sub    $0x10,%esp
  acquire(&ftable.lock);
80100f5c:	68 60 ef 10 80       	push   $0x8010ef60
80100f61:	e8 9a 37 00 00       	call   80104700 <acquire>
80100f66:	83 c4 10             	add    $0x10,%esp
80100f69:	eb 10                	jmp    80100f7b <filealloc+0x2b>
80100f6b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100f6f:	90                   	nop
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f70:	83 c3 18             	add    $0x18,%ebx
80100f73:	81 fb f4 f8 10 80    	cmp    $0x8010f8f4,%ebx
80100f79:	74 25                	je     80100fa0 <filealloc+0x50>
    if(f->ref == 0){
80100f7b:	8b 43 04             	mov    0x4(%ebx),%eax
80100f7e:	85 c0                	test   %eax,%eax
80100f80:	75 ee                	jne    80100f70 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100f82:	83 ec 0c             	sub    $0xc,%esp
      f->ref = 1;
80100f85:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100f8c:	68 60 ef 10 80       	push   $0x8010ef60
80100f91:	e8 0a 37 00 00       	call   801046a0 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100f96:	89 d8                	mov    %ebx,%eax
      return f;
80100f98:	83 c4 10             	add    $0x10,%esp
}
80100f9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100f9e:	c9                   	leave  
80100f9f:	c3                   	ret    
  release(&ftable.lock);
80100fa0:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80100fa3:	31 db                	xor    %ebx,%ebx
  release(&ftable.lock);
80100fa5:	68 60 ef 10 80       	push   $0x8010ef60
80100faa:	e8 f1 36 00 00       	call   801046a0 <release>
}
80100faf:	89 d8                	mov    %ebx,%eax
  return 0;
80100fb1:	83 c4 10             	add    $0x10,%esp
}
80100fb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100fb7:	c9                   	leave  
80100fb8:	c3                   	ret    
80100fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100fc0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fc0:	55                   	push   %ebp
80100fc1:	89 e5                	mov    %esp,%ebp
80100fc3:	53                   	push   %ebx
80100fc4:	83 ec 10             	sub    $0x10,%esp
80100fc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100fca:	68 60 ef 10 80       	push   $0x8010ef60
80100fcf:	e8 2c 37 00 00       	call   80104700 <acquire>
  if(f->ref < 1)
80100fd4:	8b 43 04             	mov    0x4(%ebx),%eax
80100fd7:	83 c4 10             	add    $0x10,%esp
80100fda:	85 c0                	test   %eax,%eax
80100fdc:	7e 1a                	jle    80100ff8 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100fde:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80100fe1:	83 ec 0c             	sub    $0xc,%esp
  f->ref++;
80100fe4:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100fe7:	68 60 ef 10 80       	push   $0x8010ef60
80100fec:	e8 af 36 00 00       	call   801046a0 <release>
  return f;
}
80100ff1:	89 d8                	mov    %ebx,%eax
80100ff3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ff6:	c9                   	leave  
80100ff7:	c3                   	ret    
    panic("filedup");
80100ff8:	83 ec 0c             	sub    $0xc,%esp
80100ffb:	68 94 74 10 80       	push   $0x80107494
80101000:	e8 7b f3 ff ff       	call   80100380 <panic>
80101005:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010100c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101010 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101010:	55                   	push   %ebp
80101011:	89 e5                	mov    %esp,%ebp
80101013:	57                   	push   %edi
80101014:	56                   	push   %esi
80101015:	53                   	push   %ebx
80101016:	83 ec 28             	sub    $0x28,%esp
80101019:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
8010101c:	68 60 ef 10 80       	push   $0x8010ef60
80101021:	e8 da 36 00 00       	call   80104700 <acquire>
  if(f->ref < 1)
80101026:	8b 53 04             	mov    0x4(%ebx),%edx
80101029:	83 c4 10             	add    $0x10,%esp
8010102c:	85 d2                	test   %edx,%edx
8010102e:	0f 8e a5 00 00 00    	jle    801010d9 <fileclose+0xc9>
    panic("fileclose");
  if(--f->ref > 0){
80101034:	83 ea 01             	sub    $0x1,%edx
80101037:	89 53 04             	mov    %edx,0x4(%ebx)
8010103a:	75 44                	jne    80101080 <fileclose+0x70>
    release(&ftable.lock);
    return;
  }
  ff = *f;
8010103c:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80101040:	83 ec 0c             	sub    $0xc,%esp
  ff = *f;
80101043:	8b 3b                	mov    (%ebx),%edi
  f->type = FD_NONE;
80101045:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  ff = *f;
8010104b:	8b 73 0c             	mov    0xc(%ebx),%esi
8010104e:	88 45 e7             	mov    %al,-0x19(%ebp)
80101051:	8b 43 10             	mov    0x10(%ebx),%eax
  release(&ftable.lock);
80101054:	68 60 ef 10 80       	push   $0x8010ef60
  ff = *f;
80101059:	89 45 e0             	mov    %eax,-0x20(%ebp)
  release(&ftable.lock);
8010105c:	e8 3f 36 00 00       	call   801046a0 <release>

  if(ff.type == FD_PIPE)
80101061:	83 c4 10             	add    $0x10,%esp
80101064:	83 ff 01             	cmp    $0x1,%edi
80101067:	74 57                	je     801010c0 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80101069:	83 ff 02             	cmp    $0x2,%edi
8010106c:	74 2a                	je     80101098 <fileclose+0x88>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
8010106e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101071:	5b                   	pop    %ebx
80101072:	5e                   	pop    %esi
80101073:	5f                   	pop    %edi
80101074:	5d                   	pop    %ebp
80101075:	c3                   	ret    
80101076:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010107d:	8d 76 00             	lea    0x0(%esi),%esi
    release(&ftable.lock);
80101080:	c7 45 08 60 ef 10 80 	movl   $0x8010ef60,0x8(%ebp)
}
80101087:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010108a:	5b                   	pop    %ebx
8010108b:	5e                   	pop    %esi
8010108c:	5f                   	pop    %edi
8010108d:	5d                   	pop    %ebp
    release(&ftable.lock);
8010108e:	e9 0d 36 00 00       	jmp    801046a0 <release>
80101093:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101097:	90                   	nop
    begin_op();
80101098:	e8 e3 1d 00 00       	call   80102e80 <begin_op>
    iput(ff.ip);
8010109d:	83 ec 0c             	sub    $0xc,%esp
801010a0:	ff 75 e0             	push   -0x20(%ebp)
801010a3:	e8 28 09 00 00       	call   801019d0 <iput>
    end_op();
801010a8:	83 c4 10             	add    $0x10,%esp
}
801010ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010ae:	5b                   	pop    %ebx
801010af:	5e                   	pop    %esi
801010b0:	5f                   	pop    %edi
801010b1:	5d                   	pop    %ebp
    end_op();
801010b2:	e9 39 1e 00 00       	jmp    80102ef0 <end_op>
801010b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801010be:	66 90                	xchg   %ax,%ax
    pipeclose(ff.pipe, ff.writable);
801010c0:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
801010c4:	83 ec 08             	sub    $0x8,%esp
801010c7:	53                   	push   %ebx
801010c8:	56                   	push   %esi
801010c9:	e8 82 25 00 00       	call   80103650 <pipeclose>
801010ce:	83 c4 10             	add    $0x10,%esp
}
801010d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010d4:	5b                   	pop    %ebx
801010d5:	5e                   	pop    %esi
801010d6:	5f                   	pop    %edi
801010d7:	5d                   	pop    %ebp
801010d8:	c3                   	ret    
    panic("fileclose");
801010d9:	83 ec 0c             	sub    $0xc,%esp
801010dc:	68 9c 74 10 80       	push   $0x8010749c
801010e1:	e8 9a f2 ff ff       	call   80100380 <panic>
801010e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801010ed:	8d 76 00             	lea    0x0(%esi),%esi

801010f0 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010f0:	55                   	push   %ebp
801010f1:	89 e5                	mov    %esp,%ebp
801010f3:	53                   	push   %ebx
801010f4:	83 ec 04             	sub    $0x4,%esp
801010f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
801010fa:	83 3b 02             	cmpl   $0x2,(%ebx)
801010fd:	75 31                	jne    80101130 <filestat+0x40>
    ilock(f->ip);
801010ff:	83 ec 0c             	sub    $0xc,%esp
80101102:	ff 73 10             	push   0x10(%ebx)
80101105:	e8 96 07 00 00       	call   801018a0 <ilock>
    stati(f->ip, st);
8010110a:	58                   	pop    %eax
8010110b:	5a                   	pop    %edx
8010110c:	ff 75 0c             	push   0xc(%ebp)
8010110f:	ff 73 10             	push   0x10(%ebx)
80101112:	e8 69 0a 00 00       	call   80101b80 <stati>
    iunlock(f->ip);
80101117:	59                   	pop    %ecx
80101118:	ff 73 10             	push   0x10(%ebx)
8010111b:	e8 60 08 00 00       	call   80101980 <iunlock>
    return 0;
  }
  return -1;
}
80101120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return 0;
80101123:	83 c4 10             	add    $0x10,%esp
80101126:	31 c0                	xor    %eax,%eax
}
80101128:	c9                   	leave  
80101129:	c3                   	ret    
8010112a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101130:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80101133:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101138:	c9                   	leave  
80101139:	c3                   	ret    
8010113a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101140 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101140:	55                   	push   %ebp
80101141:	89 e5                	mov    %esp,%ebp
80101143:	57                   	push   %edi
80101144:	56                   	push   %esi
80101145:	53                   	push   %ebx
80101146:	83 ec 0c             	sub    $0xc,%esp
80101149:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010114c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010114f:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80101152:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80101156:	74 60                	je     801011b8 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
80101158:	8b 03                	mov    (%ebx),%eax
8010115a:	83 f8 01             	cmp    $0x1,%eax
8010115d:	74 41                	je     801011a0 <fileread+0x60>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
8010115f:	83 f8 02             	cmp    $0x2,%eax
80101162:	75 5b                	jne    801011bf <fileread+0x7f>
    ilock(f->ip);
80101164:	83 ec 0c             	sub    $0xc,%esp
80101167:	ff 73 10             	push   0x10(%ebx)
8010116a:	e8 31 07 00 00       	call   801018a0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010116f:	57                   	push   %edi
80101170:	ff 73 14             	push   0x14(%ebx)
80101173:	56                   	push   %esi
80101174:	ff 73 10             	push   0x10(%ebx)
80101177:	e8 34 0a 00 00       	call   80101bb0 <readi>
8010117c:	83 c4 20             	add    $0x20,%esp
8010117f:	89 c6                	mov    %eax,%esi
80101181:	85 c0                	test   %eax,%eax
80101183:	7e 03                	jle    80101188 <fileread+0x48>
      f->off += r;
80101185:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80101188:	83 ec 0c             	sub    $0xc,%esp
8010118b:	ff 73 10             	push   0x10(%ebx)
8010118e:	e8 ed 07 00 00       	call   80101980 <iunlock>
    return r;
80101193:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80101196:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101199:	89 f0                	mov    %esi,%eax
8010119b:	5b                   	pop    %ebx
8010119c:	5e                   	pop    %esi
8010119d:	5f                   	pop    %edi
8010119e:	5d                   	pop    %ebp
8010119f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
801011a0:	8b 43 0c             	mov    0xc(%ebx),%eax
801011a3:	89 45 08             	mov    %eax,0x8(%ebp)
}
801011a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011a9:	5b                   	pop    %ebx
801011aa:	5e                   	pop    %esi
801011ab:	5f                   	pop    %edi
801011ac:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
801011ad:	e9 3e 26 00 00       	jmp    801037f0 <piperead>
801011b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
801011b8:	be ff ff ff ff       	mov    $0xffffffff,%esi
801011bd:	eb d7                	jmp    80101196 <fileread+0x56>
  panic("fileread");
801011bf:	83 ec 0c             	sub    $0xc,%esp
801011c2:	68 a6 74 10 80       	push   $0x801074a6
801011c7:	e8 b4 f1 ff ff       	call   80100380 <panic>
801011cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801011d0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011d0:	55                   	push   %ebp
801011d1:	89 e5                	mov    %esp,%ebp
801011d3:	57                   	push   %edi
801011d4:	56                   	push   %esi
801011d5:	53                   	push   %ebx
801011d6:	83 ec 1c             	sub    $0x1c,%esp
801011d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801011dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
801011df:	89 45 dc             	mov    %eax,-0x24(%ebp)
801011e2:	8b 45 10             	mov    0x10(%ebp),%eax
  int r;

  if(f->writable == 0)
801011e5:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
{
801011e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(f->writable == 0)
801011ec:	0f 84 bd 00 00 00    	je     801012af <filewrite+0xdf>
    return -1;
  if(f->type == FD_PIPE)
801011f2:	8b 03                	mov    (%ebx),%eax
801011f4:	83 f8 01             	cmp    $0x1,%eax
801011f7:	0f 84 bf 00 00 00    	je     801012bc <filewrite+0xec>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
801011fd:	83 f8 02             	cmp    $0x2,%eax
80101200:	0f 85 c8 00 00 00    	jne    801012ce <filewrite+0xfe>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101206:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int i = 0;
80101209:	31 f6                	xor    %esi,%esi
    while(i < n){
8010120b:	85 c0                	test   %eax,%eax
8010120d:	7f 30                	jg     8010123f <filewrite+0x6f>
8010120f:	e9 94 00 00 00       	jmp    801012a8 <filewrite+0xd8>
80101214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80101218:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
8010121b:	83 ec 0c             	sub    $0xc,%esp
8010121e:	ff 73 10             	push   0x10(%ebx)
        f->off += r;
80101221:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
80101224:	e8 57 07 00 00       	call   80101980 <iunlock>
      end_op();
80101229:	e8 c2 1c 00 00       	call   80102ef0 <end_op>

      if(r < 0)
        break;
      if(r != n1)
8010122e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101231:	83 c4 10             	add    $0x10,%esp
80101234:	39 c7                	cmp    %eax,%edi
80101236:	75 5c                	jne    80101294 <filewrite+0xc4>
        panic("short filewrite");
      i += r;
80101238:	01 fe                	add    %edi,%esi
    while(i < n){
8010123a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
8010123d:	7e 69                	jle    801012a8 <filewrite+0xd8>
      int n1 = n - i;
8010123f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101242:	b8 00 06 00 00       	mov    $0x600,%eax
80101247:	29 f7                	sub    %esi,%edi
80101249:	39 c7                	cmp    %eax,%edi
8010124b:	0f 4f f8             	cmovg  %eax,%edi
      begin_op();
8010124e:	e8 2d 1c 00 00       	call   80102e80 <begin_op>
      ilock(f->ip);
80101253:	83 ec 0c             	sub    $0xc,%esp
80101256:	ff 73 10             	push   0x10(%ebx)
80101259:	e8 42 06 00 00       	call   801018a0 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010125e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101261:	57                   	push   %edi
80101262:	ff 73 14             	push   0x14(%ebx)
80101265:	01 f0                	add    %esi,%eax
80101267:	50                   	push   %eax
80101268:	ff 73 10             	push   0x10(%ebx)
8010126b:	e8 40 0a 00 00       	call   80101cb0 <writei>
80101270:	83 c4 20             	add    $0x20,%esp
80101273:	85 c0                	test   %eax,%eax
80101275:	7f a1                	jg     80101218 <filewrite+0x48>
      iunlock(f->ip);
80101277:	83 ec 0c             	sub    $0xc,%esp
8010127a:	ff 73 10             	push   0x10(%ebx)
8010127d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101280:	e8 fb 06 00 00       	call   80101980 <iunlock>
      end_op();
80101285:	e8 66 1c 00 00       	call   80102ef0 <end_op>
      if(r < 0)
8010128a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010128d:	83 c4 10             	add    $0x10,%esp
80101290:	85 c0                	test   %eax,%eax
80101292:	75 1b                	jne    801012af <filewrite+0xdf>
        panic("short filewrite");
80101294:	83 ec 0c             	sub    $0xc,%esp
80101297:	68 af 74 10 80       	push   $0x801074af
8010129c:	e8 df f0 ff ff       	call   80100380 <panic>
801012a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    }
    return i == n ? n : -1;
801012a8:	89 f0                	mov    %esi,%eax
801012aa:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
801012ad:	74 05                	je     801012b4 <filewrite+0xe4>
801012af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
801012b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012b7:	5b                   	pop    %ebx
801012b8:	5e                   	pop    %esi
801012b9:	5f                   	pop    %edi
801012ba:	5d                   	pop    %ebp
801012bb:	c3                   	ret    
    return pipewrite(f->pipe, addr, n);
801012bc:	8b 43 0c             	mov    0xc(%ebx),%eax
801012bf:	89 45 08             	mov    %eax,0x8(%ebp)
}
801012c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012c5:	5b                   	pop    %ebx
801012c6:	5e                   	pop    %esi
801012c7:	5f                   	pop    %edi
801012c8:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
801012c9:	e9 22 24 00 00       	jmp    801036f0 <pipewrite>
  panic("filewrite");
801012ce:	83 ec 0c             	sub    $0xc,%esp
801012d1:	68 b5 74 10 80       	push   $0x801074b5
801012d6:	e8 a5 f0 ff ff       	call   80100380 <panic>
801012db:	66 90                	xchg   %ax,%ax
801012dd:	66 90                	xchg   %ax,%ax
801012df:	90                   	nop

801012e0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801012e0:	55                   	push   %ebp
801012e1:	89 c1                	mov    %eax,%ecx
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801012e3:	89 d0                	mov    %edx,%eax
801012e5:	c1 e8 0c             	shr    $0xc,%eax
801012e8:	03 05 cc 15 11 80    	add    0x801115cc,%eax
{
801012ee:	89 e5                	mov    %esp,%ebp
801012f0:	56                   	push   %esi
801012f1:	53                   	push   %ebx
801012f2:	89 d3                	mov    %edx,%ebx
  bp = bread(dev, BBLOCK(b, sb));
801012f4:	83 ec 08             	sub    $0x8,%esp
801012f7:	50                   	push   %eax
801012f8:	51                   	push   %ecx
801012f9:	e8 d2 ed ff ff       	call   801000d0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
801012fe:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
80101300:	c1 fb 03             	sar    $0x3,%ebx
80101303:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101306:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
80101308:	83 e1 07             	and    $0x7,%ecx
8010130b:	b8 01 00 00 00       	mov    $0x1,%eax
  if((bp->data[bi/8] & m) == 0)
80101310:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
  m = 1 << (bi % 8);
80101316:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101318:	0f b6 4c 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%ecx
8010131d:	85 c1                	test   %eax,%ecx
8010131f:	74 23                	je     80101344 <bfree+0x64>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
80101321:	f7 d0                	not    %eax
  log_write(bp);
80101323:	83 ec 0c             	sub    $0xc,%esp
  bp->data[bi/8] &= ~m;
80101326:	21 c8                	and    %ecx,%eax
80101328:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
8010132c:	56                   	push   %esi
8010132d:	e8 2e 1d 00 00       	call   80103060 <log_write>
  brelse(bp);
80101332:	89 34 24             	mov    %esi,(%esp)
80101335:	e8 b6 ee ff ff       	call   801001f0 <brelse>
}
8010133a:	83 c4 10             	add    $0x10,%esp
8010133d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101340:	5b                   	pop    %ebx
80101341:	5e                   	pop    %esi
80101342:	5d                   	pop    %ebp
80101343:	c3                   	ret    
    panic("freeing free block");
80101344:	83 ec 0c             	sub    $0xc,%esp
80101347:	68 bf 74 10 80       	push   $0x801074bf
8010134c:	e8 2f f0 ff ff       	call   80100380 <panic>
80101351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101358:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010135f:	90                   	nop

80101360 <balloc>:
{
80101360:	55                   	push   %ebp
80101361:	89 e5                	mov    %esp,%ebp
80101363:	57                   	push   %edi
80101364:	56                   	push   %esi
80101365:	53                   	push   %ebx
80101366:	83 ec 1c             	sub    $0x1c,%esp
  for(b = 0; b < sb.size; b += BPB){
80101369:	8b 0d b4 15 11 80    	mov    0x801115b4,%ecx
{
8010136f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101372:	85 c9                	test   %ecx,%ecx
80101374:	0f 84 87 00 00 00    	je     80101401 <balloc+0xa1>
8010137a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101381:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101384:	83 ec 08             	sub    $0x8,%esp
80101387:	89 f0                	mov    %esi,%eax
80101389:	c1 f8 0c             	sar    $0xc,%eax
8010138c:	03 05 cc 15 11 80    	add    0x801115cc,%eax
80101392:	50                   	push   %eax
80101393:	ff 75 d8             	push   -0x28(%ebp)
80101396:	e8 35 ed ff ff       	call   801000d0 <bread>
8010139b:	83 c4 10             	add    $0x10,%esp
8010139e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013a1:	a1 b4 15 11 80       	mov    0x801115b4,%eax
801013a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801013a9:	31 c0                	xor    %eax,%eax
801013ab:	eb 2f                	jmp    801013dc <balloc+0x7c>
801013ad:	8d 76 00             	lea    0x0(%esi),%esi
      m = 1 << (bi % 8);
801013b0:	89 c1                	mov    %eax,%ecx
801013b2:	bb 01 00 00 00       	mov    $0x1,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801013b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      m = 1 << (bi % 8);
801013ba:	83 e1 07             	and    $0x7,%ecx
801013bd:	d3 e3                	shl    %cl,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801013bf:	89 c1                	mov    %eax,%ecx
801013c1:	c1 f9 03             	sar    $0x3,%ecx
801013c4:	0f b6 7c 0a 5c       	movzbl 0x5c(%edx,%ecx,1),%edi
801013c9:	89 fa                	mov    %edi,%edx
801013cb:	85 df                	test   %ebx,%edi
801013cd:	74 41                	je     80101410 <balloc+0xb0>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013cf:	83 c0 01             	add    $0x1,%eax
801013d2:	83 c6 01             	add    $0x1,%esi
801013d5:	3d 00 10 00 00       	cmp    $0x1000,%eax
801013da:	74 05                	je     801013e1 <balloc+0x81>
801013dc:	39 75 e0             	cmp    %esi,-0x20(%ebp)
801013df:	77 cf                	ja     801013b0 <balloc+0x50>
    brelse(bp);
801013e1:	83 ec 0c             	sub    $0xc,%esp
801013e4:	ff 75 e4             	push   -0x1c(%ebp)
801013e7:	e8 04 ee ff ff       	call   801001f0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
801013ec:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
801013f3:	83 c4 10             	add    $0x10,%esp
801013f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801013f9:	39 05 b4 15 11 80    	cmp    %eax,0x801115b4
801013ff:	77 80                	ja     80101381 <balloc+0x21>
  panic("balloc: out of blocks");
80101401:	83 ec 0c             	sub    $0xc,%esp
80101404:	68 d2 74 10 80       	push   $0x801074d2
80101409:	e8 72 ef ff ff       	call   80100380 <panic>
8010140e:	66 90                	xchg   %ax,%ax
        bp->data[bi/8] |= m;  // Mark block in use.
80101410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        log_write(bp);
80101413:	83 ec 0c             	sub    $0xc,%esp
        bp->data[bi/8] |= m;  // Mark block in use.
80101416:	09 da                	or     %ebx,%edx
80101418:	88 54 0f 5c          	mov    %dl,0x5c(%edi,%ecx,1)
        log_write(bp);
8010141c:	57                   	push   %edi
8010141d:	e8 3e 1c 00 00       	call   80103060 <log_write>
        brelse(bp);
80101422:	89 3c 24             	mov    %edi,(%esp)
80101425:	e8 c6 ed ff ff       	call   801001f0 <brelse>
  bp = bread(dev, bno);
8010142a:	58                   	pop    %eax
8010142b:	5a                   	pop    %edx
8010142c:	56                   	push   %esi
8010142d:	ff 75 d8             	push   -0x28(%ebp)
80101430:	e8 9b ec ff ff       	call   801000d0 <bread>
  memset(bp->data, 0, BSIZE);
80101435:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, bno);
80101438:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
8010143a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010143d:	68 00 02 00 00       	push   $0x200
80101442:	6a 00                	push   $0x0
80101444:	50                   	push   %eax
80101445:	e8 76 33 00 00       	call   801047c0 <memset>
  log_write(bp);
8010144a:	89 1c 24             	mov    %ebx,(%esp)
8010144d:	e8 0e 1c 00 00       	call   80103060 <log_write>
  brelse(bp);
80101452:	89 1c 24             	mov    %ebx,(%esp)
80101455:	e8 96 ed ff ff       	call   801001f0 <brelse>
}
8010145a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010145d:	89 f0                	mov    %esi,%eax
8010145f:	5b                   	pop    %ebx
80101460:	5e                   	pop    %esi
80101461:	5f                   	pop    %edi
80101462:	5d                   	pop    %ebp
80101463:	c3                   	ret    
80101464:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010146b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010146f:	90                   	nop

80101470 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101470:	55                   	push   %ebp
80101471:	89 e5                	mov    %esp,%ebp
80101473:	57                   	push   %edi
80101474:	89 c7                	mov    %eax,%edi
80101476:	56                   	push   %esi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
80101477:	31 f6                	xor    %esi,%esi
{
80101479:	53                   	push   %ebx
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010147a:	bb 94 f9 10 80       	mov    $0x8010f994,%ebx
{
8010147f:	83 ec 28             	sub    $0x28,%esp
80101482:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101485:	68 60 f9 10 80       	push   $0x8010f960
8010148a:	e8 71 32 00 00       	call   80104700 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010148f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  acquire(&icache.lock);
80101492:	83 c4 10             	add    $0x10,%esp
80101495:	eb 1b                	jmp    801014b2 <iget+0x42>
80101497:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010149e:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801014a0:	39 3b                	cmp    %edi,(%ebx)
801014a2:	74 6c                	je     80101510 <iget+0xa0>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801014a4:	81 c3 90 00 00 00    	add    $0x90,%ebx
801014aa:	81 fb b4 15 11 80    	cmp    $0x801115b4,%ebx
801014b0:	73 26                	jae    801014d8 <iget+0x68>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801014b2:	8b 43 08             	mov    0x8(%ebx),%eax
801014b5:	85 c0                	test   %eax,%eax
801014b7:	7f e7                	jg     801014a0 <iget+0x30>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801014b9:	85 f6                	test   %esi,%esi
801014bb:	75 e7                	jne    801014a4 <iget+0x34>
801014bd:	85 c0                	test   %eax,%eax
801014bf:	75 76                	jne    80101537 <iget+0xc7>
801014c1:	89 de                	mov    %ebx,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801014c3:	81 c3 90 00 00 00    	add    $0x90,%ebx
801014c9:	81 fb b4 15 11 80    	cmp    $0x801115b4,%ebx
801014cf:	72 e1                	jb     801014b2 <iget+0x42>
801014d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801014d8:	85 f6                	test   %esi,%esi
801014da:	74 79                	je     80101555 <iget+0xe5>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);
801014dc:	83 ec 0c             	sub    $0xc,%esp
  ip->dev = dev;
801014df:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801014e1:	89 56 04             	mov    %edx,0x4(%esi)
  ip->ref = 1;
801014e4:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
801014eb:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
801014f2:	68 60 f9 10 80       	push   $0x8010f960
801014f7:	e8 a4 31 00 00       	call   801046a0 <release>

  return ip;
801014fc:	83 c4 10             	add    $0x10,%esp
}
801014ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101502:	89 f0                	mov    %esi,%eax
80101504:	5b                   	pop    %ebx
80101505:	5e                   	pop    %esi
80101506:	5f                   	pop    %edi
80101507:	5d                   	pop    %ebp
80101508:	c3                   	ret    
80101509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101510:	39 53 04             	cmp    %edx,0x4(%ebx)
80101513:	75 8f                	jne    801014a4 <iget+0x34>
      release(&icache.lock);
80101515:	83 ec 0c             	sub    $0xc,%esp
      ip->ref++;
80101518:	83 c0 01             	add    $0x1,%eax
      return ip;
8010151b:	89 de                	mov    %ebx,%esi
      release(&icache.lock);
8010151d:	68 60 f9 10 80       	push   $0x8010f960
      ip->ref++;
80101522:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101525:	e8 76 31 00 00       	call   801046a0 <release>
      return ip;
8010152a:	83 c4 10             	add    $0x10,%esp
}
8010152d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101530:	89 f0                	mov    %esi,%eax
80101532:	5b                   	pop    %ebx
80101533:	5e                   	pop    %esi
80101534:	5f                   	pop    %edi
80101535:	5d                   	pop    %ebp
80101536:	c3                   	ret    
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101537:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010153d:	81 fb b4 15 11 80    	cmp    $0x801115b4,%ebx
80101543:	73 10                	jae    80101555 <iget+0xe5>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101545:	8b 43 08             	mov    0x8(%ebx),%eax
80101548:	85 c0                	test   %eax,%eax
8010154a:	0f 8f 50 ff ff ff    	jg     801014a0 <iget+0x30>
80101550:	e9 68 ff ff ff       	jmp    801014bd <iget+0x4d>
    panic("iget: no inodes");
80101555:	83 ec 0c             	sub    $0xc,%esp
80101558:	68 e8 74 10 80       	push   $0x801074e8
8010155d:	e8 1e ee ff ff       	call   80100380 <panic>
80101562:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101570 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101570:	55                   	push   %ebp
80101571:	89 e5                	mov    %esp,%ebp
80101573:	57                   	push   %edi
80101574:	56                   	push   %esi
80101575:	89 c6                	mov    %eax,%esi
80101577:	53                   	push   %ebx
80101578:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
8010157b:	83 fa 0b             	cmp    $0xb,%edx
8010157e:	0f 86 8c 00 00 00    	jbe    80101610 <bmap+0xa0>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
80101584:	8d 5a f4             	lea    -0xc(%edx),%ebx

  if(bn < NINDIRECT){
80101587:	83 fb 7f             	cmp    $0x7f,%ebx
8010158a:	0f 87 a2 00 00 00    	ja     80101632 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101590:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101596:	85 c0                	test   %eax,%eax
80101598:	74 5e                	je     801015f8 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
8010159a:	83 ec 08             	sub    $0x8,%esp
8010159d:	50                   	push   %eax
8010159e:	ff 36                	push   (%esi)
801015a0:	e8 2b eb ff ff       	call   801000d0 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
801015a5:	83 c4 10             	add    $0x10,%esp
801015a8:	8d 5c 98 5c          	lea    0x5c(%eax,%ebx,4),%ebx
    bp = bread(ip->dev, addr);
801015ac:	89 c2                	mov    %eax,%edx
    if((addr = a[bn]) == 0){
801015ae:	8b 3b                	mov    (%ebx),%edi
801015b0:	85 ff                	test   %edi,%edi
801015b2:	74 1c                	je     801015d0 <bmap+0x60>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
801015b4:	83 ec 0c             	sub    $0xc,%esp
801015b7:	52                   	push   %edx
801015b8:	e8 33 ec ff ff       	call   801001f0 <brelse>
801015bd:	83 c4 10             	add    $0x10,%esp
    return addr;
  }

  panic("bmap: out of range");
}
801015c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801015c3:	89 f8                	mov    %edi,%eax
801015c5:	5b                   	pop    %ebx
801015c6:	5e                   	pop    %esi
801015c7:	5f                   	pop    %edi
801015c8:	5d                   	pop    %ebp
801015c9:	c3                   	ret    
801015ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801015d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      a[bn] = addr = balloc(ip->dev);
801015d3:	8b 06                	mov    (%esi),%eax
801015d5:	e8 86 fd ff ff       	call   80101360 <balloc>
      log_write(bp);
801015da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801015dd:	83 ec 0c             	sub    $0xc,%esp
      a[bn] = addr = balloc(ip->dev);
801015e0:	89 03                	mov    %eax,(%ebx)
801015e2:	89 c7                	mov    %eax,%edi
      log_write(bp);
801015e4:	52                   	push   %edx
801015e5:	e8 76 1a 00 00       	call   80103060 <log_write>
801015ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801015ed:	83 c4 10             	add    $0x10,%esp
801015f0:	eb c2                	jmp    801015b4 <bmap+0x44>
801015f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801015f8:	8b 06                	mov    (%esi),%eax
801015fa:	e8 61 fd ff ff       	call   80101360 <balloc>
801015ff:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
80101605:	eb 93                	jmp    8010159a <bmap+0x2a>
80101607:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010160e:	66 90                	xchg   %ax,%ax
    if((addr = ip->addrs[bn]) == 0)
80101610:	8d 5a 14             	lea    0x14(%edx),%ebx
80101613:	8b 7c 98 0c          	mov    0xc(%eax,%ebx,4),%edi
80101617:	85 ff                	test   %edi,%edi
80101619:	75 a5                	jne    801015c0 <bmap+0x50>
      ip->addrs[bn] = addr = balloc(ip->dev);
8010161b:	8b 00                	mov    (%eax),%eax
8010161d:	e8 3e fd ff ff       	call   80101360 <balloc>
80101622:	89 44 9e 0c          	mov    %eax,0xc(%esi,%ebx,4)
80101626:	89 c7                	mov    %eax,%edi
}
80101628:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010162b:	5b                   	pop    %ebx
8010162c:	89 f8                	mov    %edi,%eax
8010162e:	5e                   	pop    %esi
8010162f:	5f                   	pop    %edi
80101630:	5d                   	pop    %ebp
80101631:	c3                   	ret    
  panic("bmap: out of range");
80101632:	83 ec 0c             	sub    $0xc,%esp
80101635:	68 f8 74 10 80       	push   $0x801074f8
8010163a:	e8 41 ed ff ff       	call   80100380 <panic>
8010163f:	90                   	nop

80101640 <readsb>:
{
80101640:	55                   	push   %ebp
80101641:	89 e5                	mov    %esp,%ebp
80101643:	56                   	push   %esi
80101644:	53                   	push   %ebx
80101645:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
80101648:	83 ec 08             	sub    $0x8,%esp
8010164b:	6a 01                	push   $0x1
8010164d:	ff 75 08             	push   0x8(%ebp)
80101650:	e8 7b ea ff ff       	call   801000d0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
80101655:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
80101658:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010165a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010165d:	6a 1c                	push   $0x1c
8010165f:	50                   	push   %eax
80101660:	56                   	push   %esi
80101661:	e8 fa 31 00 00       	call   80104860 <memmove>
  brelse(bp);
80101666:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101669:	83 c4 10             	add    $0x10,%esp
}
8010166c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010166f:	5b                   	pop    %ebx
80101670:	5e                   	pop    %esi
80101671:	5d                   	pop    %ebp
  brelse(bp);
80101672:	e9 79 eb ff ff       	jmp    801001f0 <brelse>
80101677:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010167e:	66 90                	xchg   %ax,%ax

80101680 <iinit>:
{
80101680:	55                   	push   %ebp
80101681:	89 e5                	mov    %esp,%ebp
80101683:	53                   	push   %ebx
80101684:	bb a0 f9 10 80       	mov    $0x8010f9a0,%ebx
80101689:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
8010168c:	68 0b 75 10 80       	push   $0x8010750b
80101691:	68 60 f9 10 80       	push   $0x8010f960
80101696:	e8 95 2e 00 00       	call   80104530 <initlock>
  for(i = 0; i < NINODE; i++) {
8010169b:	83 c4 10             	add    $0x10,%esp
8010169e:	66 90                	xchg   %ax,%ax
    initsleeplock(&icache.inode[i].lock, "inode");
801016a0:	83 ec 08             	sub    $0x8,%esp
801016a3:	68 12 75 10 80       	push   $0x80107512
801016a8:	53                   	push   %ebx
  for(i = 0; i < NINODE; i++) {
801016a9:	81 c3 90 00 00 00    	add    $0x90,%ebx
    initsleeplock(&icache.inode[i].lock, "inode");
801016af:	e8 4c 2d 00 00       	call   80104400 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
801016b4:	83 c4 10             	add    $0x10,%esp
801016b7:	81 fb c0 15 11 80    	cmp    $0x801115c0,%ebx
801016bd:	75 e1                	jne    801016a0 <iinit+0x20>
  bp = bread(dev, 1);
801016bf:	83 ec 08             	sub    $0x8,%esp
801016c2:	6a 01                	push   $0x1
801016c4:	ff 75 08             	push   0x8(%ebp)
801016c7:	e8 04 ea ff ff       	call   801000d0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
801016cc:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
801016cf:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801016d1:	8d 40 5c             	lea    0x5c(%eax),%eax
801016d4:	6a 1c                	push   $0x1c
801016d6:	50                   	push   %eax
801016d7:	68 b4 15 11 80       	push   $0x801115b4
801016dc:	e8 7f 31 00 00       	call   80104860 <memmove>
  brelse(bp);
801016e1:	89 1c 24             	mov    %ebx,(%esp)
801016e4:	e8 07 eb ff ff       	call   801001f0 <brelse>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016e9:	ff 35 cc 15 11 80    	push   0x801115cc
801016ef:	ff 35 c8 15 11 80    	push   0x801115c8
801016f5:	ff 35 c4 15 11 80    	push   0x801115c4
801016fb:	ff 35 c0 15 11 80    	push   0x801115c0
80101701:	ff 35 bc 15 11 80    	push   0x801115bc
80101707:	ff 35 b8 15 11 80    	push   0x801115b8
8010170d:	ff 35 b4 15 11 80    	push   0x801115b4
80101713:	68 78 75 10 80       	push   $0x80107578
80101718:	e8 63 ef ff ff       	call   80100680 <cprintf>
}
8010171d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101720:	83 c4 30             	add    $0x30,%esp
80101723:	c9                   	leave  
80101724:	c3                   	ret    
80101725:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010172c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101730 <ialloc>:
{
80101730:	55                   	push   %ebp
80101731:	89 e5                	mov    %esp,%ebp
80101733:	57                   	push   %edi
80101734:	56                   	push   %esi
80101735:	53                   	push   %ebx
80101736:	83 ec 1c             	sub    $0x1c,%esp
80101739:	8b 45 0c             	mov    0xc(%ebp),%eax
  for(inum = 1; inum < sb.ninodes; inum++){
8010173c:	83 3d bc 15 11 80 01 	cmpl   $0x1,0x801115bc
{
80101743:	8b 75 08             	mov    0x8(%ebp),%esi
80101746:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101749:	0f 86 91 00 00 00    	jbe    801017e0 <ialloc+0xb0>
8010174f:	bf 01 00 00 00       	mov    $0x1,%edi
80101754:	eb 21                	jmp    80101777 <ialloc+0x47>
80101756:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010175d:	8d 76 00             	lea    0x0(%esi),%esi
    brelse(bp);
80101760:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101763:	83 c7 01             	add    $0x1,%edi
    brelse(bp);
80101766:	53                   	push   %ebx
80101767:	e8 84 ea ff ff       	call   801001f0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010176c:	83 c4 10             	add    $0x10,%esp
8010176f:	3b 3d bc 15 11 80    	cmp    0x801115bc,%edi
80101775:	73 69                	jae    801017e0 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
80101777:	89 f8                	mov    %edi,%eax
80101779:	83 ec 08             	sub    $0x8,%esp
8010177c:	c1 e8 03             	shr    $0x3,%eax
8010177f:	03 05 c8 15 11 80    	add    0x801115c8,%eax
80101785:	50                   	push   %eax
80101786:	56                   	push   %esi
80101787:	e8 44 e9 ff ff       	call   801000d0 <bread>
    if(dip->type == 0){  // a free inode
8010178c:	83 c4 10             	add    $0x10,%esp
    bp = bread(dev, IBLOCK(inum, sb));
8010178f:	89 c3                	mov    %eax,%ebx
    dip = (struct dinode*)bp->data + inum%IPB;
80101791:	89 f8                	mov    %edi,%eax
80101793:	83 e0 07             	and    $0x7,%eax
80101796:	c1 e0 06             	shl    $0x6,%eax
80101799:	8d 4c 03 5c          	lea    0x5c(%ebx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
8010179d:	66 83 39 00          	cmpw   $0x0,(%ecx)
801017a1:	75 bd                	jne    80101760 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
801017a3:	83 ec 04             	sub    $0x4,%esp
801017a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801017a9:	6a 40                	push   $0x40
801017ab:	6a 00                	push   $0x0
801017ad:	51                   	push   %ecx
801017ae:	e8 0d 30 00 00       	call   801047c0 <memset>
      dip->type = type;
801017b3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801017b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801017ba:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
801017bd:	89 1c 24             	mov    %ebx,(%esp)
801017c0:	e8 9b 18 00 00       	call   80103060 <log_write>
      brelse(bp);
801017c5:	89 1c 24             	mov    %ebx,(%esp)
801017c8:	e8 23 ea ff ff       	call   801001f0 <brelse>
      return iget(dev, inum);
801017cd:	83 c4 10             	add    $0x10,%esp
}
801017d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
801017d3:	89 fa                	mov    %edi,%edx
}
801017d5:	5b                   	pop    %ebx
      return iget(dev, inum);
801017d6:	89 f0                	mov    %esi,%eax
}
801017d8:	5e                   	pop    %esi
801017d9:	5f                   	pop    %edi
801017da:	5d                   	pop    %ebp
      return iget(dev, inum);
801017db:	e9 90 fc ff ff       	jmp    80101470 <iget>
  panic("ialloc: no inodes");
801017e0:	83 ec 0c             	sub    $0xc,%esp
801017e3:	68 18 75 10 80       	push   $0x80107518
801017e8:	e8 93 eb ff ff       	call   80100380 <panic>
801017ed:	8d 76 00             	lea    0x0(%esi),%esi

801017f0 <iupdate>:
{
801017f0:	55                   	push   %ebp
801017f1:	89 e5                	mov    %esp,%ebp
801017f3:	56                   	push   %esi
801017f4:	53                   	push   %ebx
801017f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017f8:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017fb:	83 c3 5c             	add    $0x5c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017fe:	83 ec 08             	sub    $0x8,%esp
80101801:	c1 e8 03             	shr    $0x3,%eax
80101804:	03 05 c8 15 11 80    	add    0x801115c8,%eax
8010180a:	50                   	push   %eax
8010180b:	ff 73 a4             	push   -0x5c(%ebx)
8010180e:	e8 bd e8 ff ff       	call   801000d0 <bread>
  dip->type = ip->type;
80101813:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101817:	83 c4 0c             	add    $0xc,%esp
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010181a:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010181c:	8b 43 a8             	mov    -0x58(%ebx),%eax
8010181f:	83 e0 07             	and    $0x7,%eax
80101822:	c1 e0 06             	shl    $0x6,%eax
80101825:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101829:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010182c:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101830:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
80101833:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
80101837:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
8010183b:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
8010183f:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
80101843:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
80101847:	8b 53 fc             	mov    -0x4(%ebx),%edx
8010184a:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010184d:	6a 34                	push   $0x34
8010184f:	53                   	push   %ebx
80101850:	50                   	push   %eax
80101851:	e8 0a 30 00 00       	call   80104860 <memmove>
  log_write(bp);
80101856:	89 34 24             	mov    %esi,(%esp)
80101859:	e8 02 18 00 00       	call   80103060 <log_write>
  brelse(bp);
8010185e:	89 75 08             	mov    %esi,0x8(%ebp)
80101861:	83 c4 10             	add    $0x10,%esp
}
80101864:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101867:	5b                   	pop    %ebx
80101868:	5e                   	pop    %esi
80101869:	5d                   	pop    %ebp
  brelse(bp);
8010186a:	e9 81 e9 ff ff       	jmp    801001f0 <brelse>
8010186f:	90                   	nop

80101870 <idup>:
{
80101870:	55                   	push   %ebp
80101871:	89 e5                	mov    %esp,%ebp
80101873:	53                   	push   %ebx
80101874:	83 ec 10             	sub    $0x10,%esp
80101877:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010187a:	68 60 f9 10 80       	push   $0x8010f960
8010187f:	e8 7c 2e 00 00       	call   80104700 <acquire>
  ip->ref++;
80101884:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101888:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
8010188f:	e8 0c 2e 00 00       	call   801046a0 <release>
}
80101894:	89 d8                	mov    %ebx,%eax
80101896:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101899:	c9                   	leave  
8010189a:	c3                   	ret    
8010189b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010189f:	90                   	nop

801018a0 <ilock>:
{
801018a0:	55                   	push   %ebp
801018a1:	89 e5                	mov    %esp,%ebp
801018a3:	56                   	push   %esi
801018a4:	53                   	push   %ebx
801018a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
801018a8:	85 db                	test   %ebx,%ebx
801018aa:	0f 84 b7 00 00 00    	je     80101967 <ilock+0xc7>
801018b0:	8b 53 08             	mov    0x8(%ebx),%edx
801018b3:	85 d2                	test   %edx,%edx
801018b5:	0f 8e ac 00 00 00    	jle    80101967 <ilock+0xc7>
  acquiresleep(&ip->lock);
801018bb:	83 ec 0c             	sub    $0xc,%esp
801018be:	8d 43 0c             	lea    0xc(%ebx),%eax
801018c1:	50                   	push   %eax
801018c2:	e8 79 2b 00 00       	call   80104440 <acquiresleep>
  if(ip->valid == 0){
801018c7:	8b 43 4c             	mov    0x4c(%ebx),%eax
801018ca:	83 c4 10             	add    $0x10,%esp
801018cd:	85 c0                	test   %eax,%eax
801018cf:	74 0f                	je     801018e0 <ilock+0x40>
}
801018d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801018d4:	5b                   	pop    %ebx
801018d5:	5e                   	pop    %esi
801018d6:	5d                   	pop    %ebp
801018d7:	c3                   	ret    
801018d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801018df:	90                   	nop
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018e0:	8b 43 04             	mov    0x4(%ebx),%eax
801018e3:	83 ec 08             	sub    $0x8,%esp
801018e6:	c1 e8 03             	shr    $0x3,%eax
801018e9:	03 05 c8 15 11 80    	add    0x801115c8,%eax
801018ef:	50                   	push   %eax
801018f0:	ff 33                	push   (%ebx)
801018f2:	e8 d9 e7 ff ff       	call   801000d0 <bread>
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801018f7:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018fa:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801018fc:	8b 43 04             	mov    0x4(%ebx),%eax
801018ff:	83 e0 07             	and    $0x7,%eax
80101902:	c1 e0 06             	shl    $0x6,%eax
80101905:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101909:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010190c:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
8010190f:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101913:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
80101917:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
8010191b:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
8010191f:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101923:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
80101927:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
8010192b:	8b 50 fc             	mov    -0x4(%eax),%edx
8010192e:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101931:	6a 34                	push   $0x34
80101933:	50                   	push   %eax
80101934:	8d 43 5c             	lea    0x5c(%ebx),%eax
80101937:	50                   	push   %eax
80101938:	e8 23 2f 00 00       	call   80104860 <memmove>
    brelse(bp);
8010193d:	89 34 24             	mov    %esi,(%esp)
80101940:	e8 ab e8 ff ff       	call   801001f0 <brelse>
    if(ip->type == 0)
80101945:	83 c4 10             	add    $0x10,%esp
80101948:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->valid = 1;
8010194d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101954:	0f 85 77 ff ff ff    	jne    801018d1 <ilock+0x31>
      panic("ilock: no type");
8010195a:	83 ec 0c             	sub    $0xc,%esp
8010195d:	68 30 75 10 80       	push   $0x80107530
80101962:	e8 19 ea ff ff       	call   80100380 <panic>
    panic("ilock");
80101967:	83 ec 0c             	sub    $0xc,%esp
8010196a:	68 2a 75 10 80       	push   $0x8010752a
8010196f:	e8 0c ea ff ff       	call   80100380 <panic>
80101974:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010197b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010197f:	90                   	nop

80101980 <iunlock>:
{
80101980:	55                   	push   %ebp
80101981:	89 e5                	mov    %esp,%ebp
80101983:	56                   	push   %esi
80101984:	53                   	push   %ebx
80101985:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101988:	85 db                	test   %ebx,%ebx
8010198a:	74 28                	je     801019b4 <iunlock+0x34>
8010198c:	83 ec 0c             	sub    $0xc,%esp
8010198f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101992:	56                   	push   %esi
80101993:	e8 48 2b 00 00       	call   801044e0 <holdingsleep>
80101998:	83 c4 10             	add    $0x10,%esp
8010199b:	85 c0                	test   %eax,%eax
8010199d:	74 15                	je     801019b4 <iunlock+0x34>
8010199f:	8b 43 08             	mov    0x8(%ebx),%eax
801019a2:	85 c0                	test   %eax,%eax
801019a4:	7e 0e                	jle    801019b4 <iunlock+0x34>
  releasesleep(&ip->lock);
801019a6:	89 75 08             	mov    %esi,0x8(%ebp)
}
801019a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801019ac:	5b                   	pop    %ebx
801019ad:	5e                   	pop    %esi
801019ae:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
801019af:	e9 ec 2a 00 00       	jmp    801044a0 <releasesleep>
    panic("iunlock");
801019b4:	83 ec 0c             	sub    $0xc,%esp
801019b7:	68 3f 75 10 80       	push   $0x8010753f
801019bc:	e8 bf e9 ff ff       	call   80100380 <panic>
801019c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801019c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801019cf:	90                   	nop

801019d0 <iput>:
{
801019d0:	55                   	push   %ebp
801019d1:	89 e5                	mov    %esp,%ebp
801019d3:	57                   	push   %edi
801019d4:	56                   	push   %esi
801019d5:	53                   	push   %ebx
801019d6:	83 ec 28             	sub    $0x28,%esp
801019d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
801019dc:	8d 7b 0c             	lea    0xc(%ebx),%edi
801019df:	57                   	push   %edi
801019e0:	e8 5b 2a 00 00       	call   80104440 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801019e5:	8b 53 4c             	mov    0x4c(%ebx),%edx
801019e8:	83 c4 10             	add    $0x10,%esp
801019eb:	85 d2                	test   %edx,%edx
801019ed:	74 07                	je     801019f6 <iput+0x26>
801019ef:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801019f4:	74 32                	je     80101a28 <iput+0x58>
  releasesleep(&ip->lock);
801019f6:	83 ec 0c             	sub    $0xc,%esp
801019f9:	57                   	push   %edi
801019fa:	e8 a1 2a 00 00       	call   801044a0 <releasesleep>
  acquire(&icache.lock);
801019ff:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101a06:	e8 f5 2c 00 00       	call   80104700 <acquire>
  ip->ref--;
80101a0b:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101a0f:	83 c4 10             	add    $0x10,%esp
80101a12:	c7 45 08 60 f9 10 80 	movl   $0x8010f960,0x8(%ebp)
}
80101a19:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a1c:	5b                   	pop    %ebx
80101a1d:	5e                   	pop    %esi
80101a1e:	5f                   	pop    %edi
80101a1f:	5d                   	pop    %ebp
  release(&icache.lock);
80101a20:	e9 7b 2c 00 00       	jmp    801046a0 <release>
80101a25:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&icache.lock);
80101a28:	83 ec 0c             	sub    $0xc,%esp
80101a2b:	68 60 f9 10 80       	push   $0x8010f960
80101a30:	e8 cb 2c 00 00       	call   80104700 <acquire>
    int r = ip->ref;
80101a35:	8b 73 08             	mov    0x8(%ebx),%esi
    release(&icache.lock);
80101a38:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101a3f:	e8 5c 2c 00 00       	call   801046a0 <release>
    if(r == 1){
80101a44:	83 c4 10             	add    $0x10,%esp
80101a47:	83 fe 01             	cmp    $0x1,%esi
80101a4a:	75 aa                	jne    801019f6 <iput+0x26>
80101a4c:	8d 8b 8c 00 00 00    	lea    0x8c(%ebx),%ecx
80101a52:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101a55:	8d 73 5c             	lea    0x5c(%ebx),%esi
80101a58:	89 cf                	mov    %ecx,%edi
80101a5a:	eb 0b                	jmp    80101a67 <iput+0x97>
80101a5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101a60:	83 c6 04             	add    $0x4,%esi
80101a63:	39 fe                	cmp    %edi,%esi
80101a65:	74 19                	je     80101a80 <iput+0xb0>
    if(ip->addrs[i]){
80101a67:	8b 16                	mov    (%esi),%edx
80101a69:	85 d2                	test   %edx,%edx
80101a6b:	74 f3                	je     80101a60 <iput+0x90>
      bfree(ip->dev, ip->addrs[i]);
80101a6d:	8b 03                	mov    (%ebx),%eax
80101a6f:	e8 6c f8 ff ff       	call   801012e0 <bfree>
      ip->addrs[i] = 0;
80101a74:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80101a7a:	eb e4                	jmp    80101a60 <iput+0x90>
80101a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101a80:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80101a86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101a89:	85 c0                	test   %eax,%eax
80101a8b:	75 2d                	jne    80101aba <iput+0xea>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
80101a8d:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101a90:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101a97:	53                   	push   %ebx
80101a98:	e8 53 fd ff ff       	call   801017f0 <iupdate>
      ip->type = 0;
80101a9d:	31 c0                	xor    %eax,%eax
80101a9f:	66 89 43 50          	mov    %ax,0x50(%ebx)
      iupdate(ip);
80101aa3:	89 1c 24             	mov    %ebx,(%esp)
80101aa6:	e8 45 fd ff ff       	call   801017f0 <iupdate>
      ip->valid = 0;
80101aab:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101ab2:	83 c4 10             	add    $0x10,%esp
80101ab5:	e9 3c ff ff ff       	jmp    801019f6 <iput+0x26>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101aba:	83 ec 08             	sub    $0x8,%esp
80101abd:	50                   	push   %eax
80101abe:	ff 33                	push   (%ebx)
80101ac0:	e8 0b e6 ff ff       	call   801000d0 <bread>
80101ac5:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101ac8:	83 c4 10             	add    $0x10,%esp
80101acb:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
80101ad1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ad4:	8d 70 5c             	lea    0x5c(%eax),%esi
80101ad7:	89 cf                	mov    %ecx,%edi
80101ad9:	eb 0c                	jmp    80101ae7 <iput+0x117>
80101adb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101adf:	90                   	nop
80101ae0:	83 c6 04             	add    $0x4,%esi
80101ae3:	39 f7                	cmp    %esi,%edi
80101ae5:	74 0f                	je     80101af6 <iput+0x126>
      if(a[j])
80101ae7:	8b 16                	mov    (%esi),%edx
80101ae9:	85 d2                	test   %edx,%edx
80101aeb:	74 f3                	je     80101ae0 <iput+0x110>
        bfree(ip->dev, a[j]);
80101aed:	8b 03                	mov    (%ebx),%eax
80101aef:	e8 ec f7 ff ff       	call   801012e0 <bfree>
80101af4:	eb ea                	jmp    80101ae0 <iput+0x110>
    brelse(bp);
80101af6:	83 ec 0c             	sub    $0xc,%esp
80101af9:	ff 75 e4             	push   -0x1c(%ebp)
80101afc:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101aff:	e8 ec e6 ff ff       	call   801001f0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101b04:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
80101b0a:	8b 03                	mov    (%ebx),%eax
80101b0c:	e8 cf f7 ff ff       	call   801012e0 <bfree>
    ip->addrs[NDIRECT] = 0;
80101b11:	83 c4 10             	add    $0x10,%esp
80101b14:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80101b1b:	00 00 00 
80101b1e:	e9 6a ff ff ff       	jmp    80101a8d <iput+0xbd>
80101b23:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101b2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101b30 <iunlockput>:
{
80101b30:	55                   	push   %ebp
80101b31:	89 e5                	mov    %esp,%ebp
80101b33:	56                   	push   %esi
80101b34:	53                   	push   %ebx
80101b35:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b38:	85 db                	test   %ebx,%ebx
80101b3a:	74 34                	je     80101b70 <iunlockput+0x40>
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101b42:	56                   	push   %esi
80101b43:	e8 98 29 00 00       	call   801044e0 <holdingsleep>
80101b48:	83 c4 10             	add    $0x10,%esp
80101b4b:	85 c0                	test   %eax,%eax
80101b4d:	74 21                	je     80101b70 <iunlockput+0x40>
80101b4f:	8b 43 08             	mov    0x8(%ebx),%eax
80101b52:	85 c0                	test   %eax,%eax
80101b54:	7e 1a                	jle    80101b70 <iunlockput+0x40>
  releasesleep(&ip->lock);
80101b56:	83 ec 0c             	sub    $0xc,%esp
80101b59:	56                   	push   %esi
80101b5a:	e8 41 29 00 00       	call   801044a0 <releasesleep>
  iput(ip);
80101b5f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101b62:	83 c4 10             	add    $0x10,%esp
}
80101b65:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101b68:	5b                   	pop    %ebx
80101b69:	5e                   	pop    %esi
80101b6a:	5d                   	pop    %ebp
  iput(ip);
80101b6b:	e9 60 fe ff ff       	jmp    801019d0 <iput>
    panic("iunlock");
80101b70:	83 ec 0c             	sub    $0xc,%esp
80101b73:	68 3f 75 10 80       	push   $0x8010753f
80101b78:	e8 03 e8 ff ff       	call   80100380 <panic>
80101b7d:	8d 76 00             	lea    0x0(%esi),%esi

80101b80 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101b80:	55                   	push   %ebp
80101b81:	89 e5                	mov    %esp,%ebp
80101b83:	8b 55 08             	mov    0x8(%ebp),%edx
80101b86:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101b89:	8b 0a                	mov    (%edx),%ecx
80101b8b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101b8e:	8b 4a 04             	mov    0x4(%edx),%ecx
80101b91:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101b94:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101b98:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101b9b:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101b9f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101ba3:	8b 52 58             	mov    0x58(%edx),%edx
80101ba6:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ba9:	5d                   	pop    %ebp
80101baa:	c3                   	ret    
80101bab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101baf:	90                   	nop

80101bb0 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101bb0:	55                   	push   %ebp
80101bb1:	89 e5                	mov    %esp,%ebp
80101bb3:	57                   	push   %edi
80101bb4:	56                   	push   %esi
80101bb5:	53                   	push   %ebx
80101bb6:	83 ec 1c             	sub    $0x1c,%esp
80101bb9:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101bbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbf:	8b 75 10             	mov    0x10(%ebp),%esi
80101bc2:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101bc5:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101bc8:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101bcd:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101bd0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  if(ip->type == T_DEV){
80101bd3:	0f 84 a7 00 00 00    	je     80101c80 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101bd9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101bdc:	8b 40 58             	mov    0x58(%eax),%eax
80101bdf:	39 c6                	cmp    %eax,%esi
80101be1:	0f 87 ba 00 00 00    	ja     80101ca1 <readi+0xf1>
80101be7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101bea:	31 c9                	xor    %ecx,%ecx
80101bec:	89 da                	mov    %ebx,%edx
80101bee:	01 f2                	add    %esi,%edx
80101bf0:	0f 92 c1             	setb   %cl
80101bf3:	89 cf                	mov    %ecx,%edi
80101bf5:	0f 82 a6 00 00 00    	jb     80101ca1 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101bfb:	89 c1                	mov    %eax,%ecx
80101bfd:	29 f1                	sub    %esi,%ecx
80101bff:	39 d0                	cmp    %edx,%eax
80101c01:	0f 43 cb             	cmovae %ebx,%ecx
80101c04:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c07:	85 c9                	test   %ecx,%ecx
80101c09:	74 67                	je     80101c72 <readi+0xc2>
80101c0b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101c0f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c10:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101c13:	89 f2                	mov    %esi,%edx
80101c15:	c1 ea 09             	shr    $0x9,%edx
80101c18:	89 d8                	mov    %ebx,%eax
80101c1a:	e8 51 f9 ff ff       	call   80101570 <bmap>
80101c1f:	83 ec 08             	sub    $0x8,%esp
80101c22:	50                   	push   %eax
80101c23:	ff 33                	push   (%ebx)
80101c25:	e8 a6 e4 ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101c2a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101c2d:	b9 00 02 00 00       	mov    $0x200,%ecx
80101c32:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c35:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101c37:	89 f0                	mov    %esi,%eax
80101c39:	25 ff 01 00 00       	and    $0x1ff,%eax
80101c3e:	29 fb                	sub    %edi,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101c40:	89 55 dc             	mov    %edx,-0x24(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101c43:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
80101c45:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101c49:	39 d9                	cmp    %ebx,%ecx
80101c4b:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101c4e:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c4f:	01 df                	add    %ebx,%edi
80101c51:	01 de                	add    %ebx,%esi
    memmove(dst, bp->data + off%BSIZE, m);
80101c53:	50                   	push   %eax
80101c54:	ff 75 e0             	push   -0x20(%ebp)
80101c57:	e8 04 2c 00 00       	call   80104860 <memmove>
    brelse(bp);
80101c5c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101c5f:	89 14 24             	mov    %edx,(%esp)
80101c62:	e8 89 e5 ff ff       	call   801001f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c67:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101c6a:	83 c4 10             	add    $0x10,%esp
80101c6d:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101c70:	77 9e                	ja     80101c10 <readi+0x60>
  }
  return n;
80101c72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c78:	5b                   	pop    %ebx
80101c79:	5e                   	pop    %esi
80101c7a:	5f                   	pop    %edi
80101c7b:	5d                   	pop    %ebp
80101c7c:	c3                   	ret    
80101c7d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101c80:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101c84:	66 83 f8 09          	cmp    $0x9,%ax
80101c88:	77 17                	ja     80101ca1 <readi+0xf1>
80101c8a:	8b 04 c5 00 f9 10 80 	mov    -0x7fef0700(,%eax,8),%eax
80101c91:	85 c0                	test   %eax,%eax
80101c93:	74 0c                	je     80101ca1 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101c95:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c9b:	5b                   	pop    %ebx
80101c9c:	5e                   	pop    %esi
80101c9d:	5f                   	pop    %edi
80101c9e:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101c9f:	ff e0                	jmp    *%eax
      return -1;
80101ca1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ca6:	eb cd                	jmp    80101c75 <readi+0xc5>
80101ca8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101caf:	90                   	nop

80101cb0 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101cb0:	55                   	push   %ebp
80101cb1:	89 e5                	mov    %esp,%ebp
80101cb3:	57                   	push   %edi
80101cb4:	56                   	push   %esi
80101cb5:	53                   	push   %ebx
80101cb6:	83 ec 1c             	sub    $0x1c,%esp
80101cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbc:	8b 75 0c             	mov    0xc(%ebp),%esi
80101cbf:	8b 55 14             	mov    0x14(%ebp),%edx
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101cc2:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101cc7:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101cca:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101ccd:	8b 75 10             	mov    0x10(%ebp),%esi
80101cd0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  if(ip->type == T_DEV){
80101cd3:	0f 84 b7 00 00 00    	je     80101d90 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101cd9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101cdc:	3b 70 58             	cmp    0x58(%eax),%esi
80101cdf:	0f 87 e7 00 00 00    	ja     80101dcc <writei+0x11c>
80101ce5:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101ce8:	31 d2                	xor    %edx,%edx
80101cea:	89 f8                	mov    %edi,%eax
80101cec:	01 f0                	add    %esi,%eax
80101cee:	0f 92 c2             	setb   %dl
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101cf1:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101cf6:	0f 87 d0 00 00 00    	ja     80101dcc <writei+0x11c>
80101cfc:	85 d2                	test   %edx,%edx
80101cfe:	0f 85 c8 00 00 00    	jne    80101dcc <writei+0x11c>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d04:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101d0b:	85 ff                	test   %edi,%edi
80101d0d:	74 72                	je     80101d81 <writei+0xd1>
80101d0f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101d10:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101d13:	89 f2                	mov    %esi,%edx
80101d15:	c1 ea 09             	shr    $0x9,%edx
80101d18:	89 f8                	mov    %edi,%eax
80101d1a:	e8 51 f8 ff ff       	call   80101570 <bmap>
80101d1f:	83 ec 08             	sub    $0x8,%esp
80101d22:	50                   	push   %eax
80101d23:	ff 37                	push   (%edi)
80101d25:	e8 a6 e3 ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101d2a:	b9 00 02 00 00       	mov    $0x200,%ecx
80101d2f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101d32:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101d35:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101d37:	89 f0                	mov    %esi,%eax
80101d39:	83 c4 0c             	add    $0xc,%esp
80101d3c:	25 ff 01 00 00       	and    $0x1ff,%eax
80101d41:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101d43:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101d47:	39 d9                	cmp    %ebx,%ecx
80101d49:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101d4c:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d4d:	01 de                	add    %ebx,%esi
    memmove(bp->data + off%BSIZE, src, m);
80101d4f:	ff 75 dc             	push   -0x24(%ebp)
80101d52:	50                   	push   %eax
80101d53:	e8 08 2b 00 00       	call   80104860 <memmove>
    log_write(bp);
80101d58:	89 3c 24             	mov    %edi,(%esp)
80101d5b:	e8 00 13 00 00       	call   80103060 <log_write>
    brelse(bp);
80101d60:	89 3c 24             	mov    %edi,(%esp)
80101d63:	e8 88 e4 ff ff       	call   801001f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d68:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101d6b:	83 c4 10             	add    $0x10,%esp
80101d6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101d71:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101d74:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101d77:	77 97                	ja     80101d10 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101d79:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101d7c:	3b 70 58             	cmp    0x58(%eax),%esi
80101d7f:	77 37                	ja     80101db8 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101d87:	5b                   	pop    %ebx
80101d88:	5e                   	pop    %esi
80101d89:	5f                   	pop    %edi
80101d8a:	5d                   	pop    %ebp
80101d8b:	c3                   	ret    
80101d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101d90:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101d94:	66 83 f8 09          	cmp    $0x9,%ax
80101d98:	77 32                	ja     80101dcc <writei+0x11c>
80101d9a:	8b 04 c5 04 f9 10 80 	mov    -0x7fef06fc(,%eax,8),%eax
80101da1:	85 c0                	test   %eax,%eax
80101da3:	74 27                	je     80101dcc <writei+0x11c>
    return devsw[ip->major].write(ip, src, n);
80101da5:	89 55 10             	mov    %edx,0x10(%ebp)
}
80101da8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101dab:	5b                   	pop    %ebx
80101dac:	5e                   	pop    %esi
80101dad:	5f                   	pop    %edi
80101dae:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101daf:	ff e0                	jmp    *%eax
80101db1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    ip->size = off;
80101db8:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101dbb:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101dbe:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
80101dc1:	50                   	push   %eax
80101dc2:	e8 29 fa ff ff       	call   801017f0 <iupdate>
80101dc7:	83 c4 10             	add    $0x10,%esp
80101dca:	eb b5                	jmp    80101d81 <writei+0xd1>
      return -1;
80101dcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dd1:	eb b1                	jmp    80101d84 <writei+0xd4>
80101dd3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101dda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101de0 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101de0:	55                   	push   %ebp
80101de1:	89 e5                	mov    %esp,%ebp
80101de3:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101de6:	6a 0e                	push   $0xe
80101de8:	ff 75 0c             	push   0xc(%ebp)
80101deb:	ff 75 08             	push   0x8(%ebp)
80101dee:	e8 dd 2a 00 00       	call   801048d0 <strncmp>
}
80101df3:	c9                   	leave  
80101df4:	c3                   	ret    
80101df5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101e00 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101e00:	55                   	push   %ebp
80101e01:	89 e5                	mov    %esp,%ebp
80101e03:	57                   	push   %edi
80101e04:	56                   	push   %esi
80101e05:	53                   	push   %ebx
80101e06:	83 ec 1c             	sub    $0x1c,%esp
80101e09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101e0c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101e11:	0f 85 85 00 00 00    	jne    80101e9c <dirlookup+0x9c>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101e17:	8b 53 58             	mov    0x58(%ebx),%edx
80101e1a:	31 ff                	xor    %edi,%edi
80101e1c:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101e1f:	85 d2                	test   %edx,%edx
80101e21:	74 3e                	je     80101e61 <dirlookup+0x61>
80101e23:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101e27:	90                   	nop
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101e28:	6a 10                	push   $0x10
80101e2a:	57                   	push   %edi
80101e2b:	56                   	push   %esi
80101e2c:	53                   	push   %ebx
80101e2d:	e8 7e fd ff ff       	call   80101bb0 <readi>
80101e32:	83 c4 10             	add    $0x10,%esp
80101e35:	83 f8 10             	cmp    $0x10,%eax
80101e38:	75 55                	jne    80101e8f <dirlookup+0x8f>
      panic("dirlookup read");
    if(de.inum == 0)
80101e3a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101e3f:	74 18                	je     80101e59 <dirlookup+0x59>
  return strncmp(s, t, DIRSIZ);
80101e41:	83 ec 04             	sub    $0x4,%esp
80101e44:	8d 45 da             	lea    -0x26(%ebp),%eax
80101e47:	6a 0e                	push   $0xe
80101e49:	50                   	push   %eax
80101e4a:	ff 75 0c             	push   0xc(%ebp)
80101e4d:	e8 7e 2a 00 00       	call   801048d0 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101e52:	83 c4 10             	add    $0x10,%esp
80101e55:	85 c0                	test   %eax,%eax
80101e57:	74 17                	je     80101e70 <dirlookup+0x70>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101e59:	83 c7 10             	add    $0x10,%edi
80101e5c:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101e5f:	72 c7                	jb     80101e28 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101e61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101e64:	31 c0                	xor    %eax,%eax
}
80101e66:	5b                   	pop    %ebx
80101e67:	5e                   	pop    %esi
80101e68:	5f                   	pop    %edi
80101e69:	5d                   	pop    %ebp
80101e6a:	c3                   	ret    
80101e6b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101e6f:	90                   	nop
      if(poff)
80101e70:	8b 45 10             	mov    0x10(%ebp),%eax
80101e73:	85 c0                	test   %eax,%eax
80101e75:	74 05                	je     80101e7c <dirlookup+0x7c>
        *poff = off;
80101e77:	8b 45 10             	mov    0x10(%ebp),%eax
80101e7a:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101e7c:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101e80:	8b 03                	mov    (%ebx),%eax
80101e82:	e8 e9 f5 ff ff       	call   80101470 <iget>
}
80101e87:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101e8a:	5b                   	pop    %ebx
80101e8b:	5e                   	pop    %esi
80101e8c:	5f                   	pop    %edi
80101e8d:	5d                   	pop    %ebp
80101e8e:	c3                   	ret    
      panic("dirlookup read");
80101e8f:	83 ec 0c             	sub    $0xc,%esp
80101e92:	68 59 75 10 80       	push   $0x80107559
80101e97:	e8 e4 e4 ff ff       	call   80100380 <panic>
    panic("dirlookup not DIR");
80101e9c:	83 ec 0c             	sub    $0xc,%esp
80101e9f:	68 47 75 10 80       	push   $0x80107547
80101ea4:	e8 d7 e4 ff ff       	call   80100380 <panic>
80101ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101eb0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101eb0:	55                   	push   %ebp
80101eb1:	89 e5                	mov    %esp,%ebp
80101eb3:	57                   	push   %edi
80101eb4:	56                   	push   %esi
80101eb5:	53                   	push   %ebx
80101eb6:	89 c3                	mov    %eax,%ebx
80101eb8:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101ebb:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101ebe:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101ec1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  if(*path == '/')
80101ec4:	0f 84 64 01 00 00    	je     8010202e <namex+0x17e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101eca:	e8 01 1c 00 00       	call   80103ad0 <myproc>
  acquire(&icache.lock);
80101ecf:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(myproc()->cwd);
80101ed2:	8b 70 68             	mov    0x68(%eax),%esi
  acquire(&icache.lock);
80101ed5:	68 60 f9 10 80       	push   $0x8010f960
80101eda:	e8 21 28 00 00       	call   80104700 <acquire>
  ip->ref++;
80101edf:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101ee3:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101eea:	e8 b1 27 00 00       	call   801046a0 <release>
80101eef:	83 c4 10             	add    $0x10,%esp
80101ef2:	eb 07                	jmp    80101efb <namex+0x4b>
80101ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101ef8:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101efb:	0f b6 03             	movzbl (%ebx),%eax
80101efe:	3c 2f                	cmp    $0x2f,%al
80101f00:	74 f6                	je     80101ef8 <namex+0x48>
  if(*path == 0)
80101f02:	84 c0                	test   %al,%al
80101f04:	0f 84 06 01 00 00    	je     80102010 <namex+0x160>
  while(*path != '/' && *path != 0)
80101f0a:	0f b6 03             	movzbl (%ebx),%eax
80101f0d:	84 c0                	test   %al,%al
80101f0f:	0f 84 10 01 00 00    	je     80102025 <namex+0x175>
80101f15:	89 df                	mov    %ebx,%edi
80101f17:	3c 2f                	cmp    $0x2f,%al
80101f19:	0f 84 06 01 00 00    	je     80102025 <namex+0x175>
80101f1f:	90                   	nop
80101f20:	0f b6 47 01          	movzbl 0x1(%edi),%eax
    path++;
80101f24:	83 c7 01             	add    $0x1,%edi
  while(*path != '/' && *path != 0)
80101f27:	3c 2f                	cmp    $0x2f,%al
80101f29:	74 04                	je     80101f2f <namex+0x7f>
80101f2b:	84 c0                	test   %al,%al
80101f2d:	75 f1                	jne    80101f20 <namex+0x70>
  len = path - s;
80101f2f:	89 f8                	mov    %edi,%eax
80101f31:	29 d8                	sub    %ebx,%eax
  if(len >= DIRSIZ)
80101f33:	83 f8 0d             	cmp    $0xd,%eax
80101f36:	0f 8e ac 00 00 00    	jle    80101fe8 <namex+0x138>
    memmove(name, s, DIRSIZ);
80101f3c:	83 ec 04             	sub    $0x4,%esp
80101f3f:	6a 0e                	push   $0xe
80101f41:	53                   	push   %ebx
    path++;
80101f42:	89 fb                	mov    %edi,%ebx
    memmove(name, s, DIRSIZ);
80101f44:	ff 75 e4             	push   -0x1c(%ebp)
80101f47:	e8 14 29 00 00       	call   80104860 <memmove>
80101f4c:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
80101f4f:	80 3f 2f             	cmpb   $0x2f,(%edi)
80101f52:	75 0c                	jne    80101f60 <namex+0xb0>
80101f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101f58:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101f5b:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101f5e:	74 f8                	je     80101f58 <namex+0xa8>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101f60:	83 ec 0c             	sub    $0xc,%esp
80101f63:	56                   	push   %esi
80101f64:	e8 37 f9 ff ff       	call   801018a0 <ilock>
    if(ip->type != T_DIR){
80101f69:	83 c4 10             	add    $0x10,%esp
80101f6c:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101f71:	0f 85 cd 00 00 00    	jne    80102044 <namex+0x194>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101f77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101f7a:	85 c0                	test   %eax,%eax
80101f7c:	74 09                	je     80101f87 <namex+0xd7>
80101f7e:	80 3b 00             	cmpb   $0x0,(%ebx)
80101f81:	0f 84 22 01 00 00    	je     801020a9 <namex+0x1f9>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101f87:	83 ec 04             	sub    $0x4,%esp
80101f8a:	6a 00                	push   $0x0
80101f8c:	ff 75 e4             	push   -0x1c(%ebp)
80101f8f:	56                   	push   %esi
80101f90:	e8 6b fe ff ff       	call   80101e00 <dirlookup>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101f95:	8d 56 0c             	lea    0xc(%esi),%edx
    if((next = dirlookup(ip, name, 0)) == 0){
80101f98:	83 c4 10             	add    $0x10,%esp
80101f9b:	89 c7                	mov    %eax,%edi
80101f9d:	85 c0                	test   %eax,%eax
80101f9f:	0f 84 e1 00 00 00    	je     80102086 <namex+0x1d6>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101fa5:	83 ec 0c             	sub    $0xc,%esp
80101fa8:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101fab:	52                   	push   %edx
80101fac:	e8 2f 25 00 00       	call   801044e0 <holdingsleep>
80101fb1:	83 c4 10             	add    $0x10,%esp
80101fb4:	85 c0                	test   %eax,%eax
80101fb6:	0f 84 30 01 00 00    	je     801020ec <namex+0x23c>
80101fbc:	8b 56 08             	mov    0x8(%esi),%edx
80101fbf:	85 d2                	test   %edx,%edx
80101fc1:	0f 8e 25 01 00 00    	jle    801020ec <namex+0x23c>
  releasesleep(&ip->lock);
80101fc7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101fca:	83 ec 0c             	sub    $0xc,%esp
80101fcd:	52                   	push   %edx
80101fce:	e8 cd 24 00 00       	call   801044a0 <releasesleep>
  iput(ip);
80101fd3:	89 34 24             	mov    %esi,(%esp)
80101fd6:	89 fe                	mov    %edi,%esi
80101fd8:	e8 f3 f9 ff ff       	call   801019d0 <iput>
80101fdd:	83 c4 10             	add    $0x10,%esp
80101fe0:	e9 16 ff ff ff       	jmp    80101efb <namex+0x4b>
80101fe5:	8d 76 00             	lea    0x0(%esi),%esi
    name[len] = 0;
80101fe8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101feb:	8d 14 01             	lea    (%ecx,%eax,1),%edx
    memmove(name, s, len);
80101fee:	83 ec 04             	sub    $0x4,%esp
80101ff1:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101ff4:	50                   	push   %eax
80101ff5:	53                   	push   %ebx
    name[len] = 0;
80101ff6:	89 fb                	mov    %edi,%ebx
    memmove(name, s, len);
80101ff8:	ff 75 e4             	push   -0x1c(%ebp)
80101ffb:	e8 60 28 00 00       	call   80104860 <memmove>
    name[len] = 0;
80102000:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102003:	83 c4 10             	add    $0x10,%esp
80102006:	c6 02 00             	movb   $0x0,(%edx)
80102009:	e9 41 ff ff ff       	jmp    80101f4f <namex+0x9f>
8010200e:	66 90                	xchg   %ax,%ax
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102010:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102013:	85 c0                	test   %eax,%eax
80102015:	0f 85 be 00 00 00    	jne    801020d9 <namex+0x229>
    iput(ip);
    return 0;
  }
  return ip;
}
8010201b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010201e:	89 f0                	mov    %esi,%eax
80102020:	5b                   	pop    %ebx
80102021:	5e                   	pop    %esi
80102022:	5f                   	pop    %edi
80102023:	5d                   	pop    %ebp
80102024:	c3                   	ret    
  while(*path != '/' && *path != 0)
80102025:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102028:	89 df                	mov    %ebx,%edi
8010202a:	31 c0                	xor    %eax,%eax
8010202c:	eb c0                	jmp    80101fee <namex+0x13e>
    ip = iget(ROOTDEV, ROOTINO);
8010202e:	ba 01 00 00 00       	mov    $0x1,%edx
80102033:	b8 01 00 00 00       	mov    $0x1,%eax
80102038:	e8 33 f4 ff ff       	call   80101470 <iget>
8010203d:	89 c6                	mov    %eax,%esi
8010203f:	e9 b7 fe ff ff       	jmp    80101efb <namex+0x4b>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80102044:	83 ec 0c             	sub    $0xc,%esp
80102047:	8d 5e 0c             	lea    0xc(%esi),%ebx
8010204a:	53                   	push   %ebx
8010204b:	e8 90 24 00 00       	call   801044e0 <holdingsleep>
80102050:	83 c4 10             	add    $0x10,%esp
80102053:	85 c0                	test   %eax,%eax
80102055:	0f 84 91 00 00 00    	je     801020ec <namex+0x23c>
8010205b:	8b 46 08             	mov    0x8(%esi),%eax
8010205e:	85 c0                	test   %eax,%eax
80102060:	0f 8e 86 00 00 00    	jle    801020ec <namex+0x23c>
  releasesleep(&ip->lock);
80102066:	83 ec 0c             	sub    $0xc,%esp
80102069:	53                   	push   %ebx
8010206a:	e8 31 24 00 00       	call   801044a0 <releasesleep>
  iput(ip);
8010206f:	89 34 24             	mov    %esi,(%esp)
      return 0;
80102072:	31 f6                	xor    %esi,%esi
  iput(ip);
80102074:	e8 57 f9 ff ff       	call   801019d0 <iput>
      return 0;
80102079:	83 c4 10             	add    $0x10,%esp
}
8010207c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010207f:	89 f0                	mov    %esi,%eax
80102081:	5b                   	pop    %ebx
80102082:	5e                   	pop    %esi
80102083:	5f                   	pop    %edi
80102084:	5d                   	pop    %ebp
80102085:	c3                   	ret    
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80102086:	83 ec 0c             	sub    $0xc,%esp
80102089:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010208c:	52                   	push   %edx
8010208d:	e8 4e 24 00 00       	call   801044e0 <holdingsleep>
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	85 c0                	test   %eax,%eax
80102097:	74 53                	je     801020ec <namex+0x23c>
80102099:	8b 4e 08             	mov    0x8(%esi),%ecx
8010209c:	85 c9                	test   %ecx,%ecx
8010209e:	7e 4c                	jle    801020ec <namex+0x23c>
  releasesleep(&ip->lock);
801020a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801020a3:	83 ec 0c             	sub    $0xc,%esp
801020a6:	52                   	push   %edx
801020a7:	eb c1                	jmp    8010206a <namex+0x1ba>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801020a9:	83 ec 0c             	sub    $0xc,%esp
801020ac:	8d 5e 0c             	lea    0xc(%esi),%ebx
801020af:	53                   	push   %ebx
801020b0:	e8 2b 24 00 00       	call   801044e0 <holdingsleep>
801020b5:	83 c4 10             	add    $0x10,%esp
801020b8:	85 c0                	test   %eax,%eax
801020ba:	74 30                	je     801020ec <namex+0x23c>
801020bc:	8b 7e 08             	mov    0x8(%esi),%edi
801020bf:	85 ff                	test   %edi,%edi
801020c1:	7e 29                	jle    801020ec <namex+0x23c>
  releasesleep(&ip->lock);
801020c3:	83 ec 0c             	sub    $0xc,%esp
801020c6:	53                   	push   %ebx
801020c7:	e8 d4 23 00 00       	call   801044a0 <releasesleep>
}
801020cc:	83 c4 10             	add    $0x10,%esp
}
801020cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801020d2:	89 f0                	mov    %esi,%eax
801020d4:	5b                   	pop    %ebx
801020d5:	5e                   	pop    %esi
801020d6:	5f                   	pop    %edi
801020d7:	5d                   	pop    %ebp
801020d8:	c3                   	ret    
    iput(ip);
801020d9:	83 ec 0c             	sub    $0xc,%esp
801020dc:	56                   	push   %esi
    return 0;
801020dd:	31 f6                	xor    %esi,%esi
    iput(ip);
801020df:	e8 ec f8 ff ff       	call   801019d0 <iput>
    return 0;
801020e4:	83 c4 10             	add    $0x10,%esp
801020e7:	e9 2f ff ff ff       	jmp    8010201b <namex+0x16b>
    panic("iunlock");
801020ec:	83 ec 0c             	sub    $0xc,%esp
801020ef:	68 3f 75 10 80       	push   $0x8010753f
801020f4:	e8 87 e2 ff ff       	call   80100380 <panic>
801020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102100 <dirlink>:
{
80102100:	55                   	push   %ebp
80102101:	89 e5                	mov    %esp,%ebp
80102103:	57                   	push   %edi
80102104:	56                   	push   %esi
80102105:	53                   	push   %ebx
80102106:	83 ec 20             	sub    $0x20,%esp
80102109:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
8010210c:	6a 00                	push   $0x0
8010210e:	ff 75 0c             	push   0xc(%ebp)
80102111:	53                   	push   %ebx
80102112:	e8 e9 fc ff ff       	call   80101e00 <dirlookup>
80102117:	83 c4 10             	add    $0x10,%esp
8010211a:	85 c0                	test   %eax,%eax
8010211c:	75 67                	jne    80102185 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010211e:	8b 7b 58             	mov    0x58(%ebx),%edi
80102121:	8d 75 d8             	lea    -0x28(%ebp),%esi
80102124:	85 ff                	test   %edi,%edi
80102126:	74 29                	je     80102151 <dirlink+0x51>
80102128:	31 ff                	xor    %edi,%edi
8010212a:	8d 75 d8             	lea    -0x28(%ebp),%esi
8010212d:	eb 09                	jmp    80102138 <dirlink+0x38>
8010212f:	90                   	nop
80102130:	83 c7 10             	add    $0x10,%edi
80102133:	3b 7b 58             	cmp    0x58(%ebx),%edi
80102136:	73 19                	jae    80102151 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102138:	6a 10                	push   $0x10
8010213a:	57                   	push   %edi
8010213b:	56                   	push   %esi
8010213c:	53                   	push   %ebx
8010213d:	e8 6e fa ff ff       	call   80101bb0 <readi>
80102142:	83 c4 10             	add    $0x10,%esp
80102145:	83 f8 10             	cmp    $0x10,%eax
80102148:	75 4e                	jne    80102198 <dirlink+0x98>
    if(de.inum == 0)
8010214a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010214f:	75 df                	jne    80102130 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80102151:	83 ec 04             	sub    $0x4,%esp
80102154:	8d 45 da             	lea    -0x26(%ebp),%eax
80102157:	6a 0e                	push   $0xe
80102159:	ff 75 0c             	push   0xc(%ebp)
8010215c:	50                   	push   %eax
8010215d:	e8 be 27 00 00       	call   80104920 <strncpy>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102162:	6a 10                	push   $0x10
  de.inum = inum;
80102164:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102167:	57                   	push   %edi
80102168:	56                   	push   %esi
80102169:	53                   	push   %ebx
  de.inum = inum;
8010216a:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010216e:	e8 3d fb ff ff       	call   80101cb0 <writei>
80102173:	83 c4 20             	add    $0x20,%esp
80102176:	83 f8 10             	cmp    $0x10,%eax
80102179:	75 2a                	jne    801021a5 <dirlink+0xa5>
  return 0;
8010217b:	31 c0                	xor    %eax,%eax
}
8010217d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102180:	5b                   	pop    %ebx
80102181:	5e                   	pop    %esi
80102182:	5f                   	pop    %edi
80102183:	5d                   	pop    %ebp
80102184:	c3                   	ret    
    iput(ip);
80102185:	83 ec 0c             	sub    $0xc,%esp
80102188:	50                   	push   %eax
80102189:	e8 42 f8 ff ff       	call   801019d0 <iput>
    return -1;
8010218e:	83 c4 10             	add    $0x10,%esp
80102191:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102196:	eb e5                	jmp    8010217d <dirlink+0x7d>
      panic("dirlink read");
80102198:	83 ec 0c             	sub    $0xc,%esp
8010219b:	68 68 75 10 80       	push   $0x80107568
801021a0:	e8 db e1 ff ff       	call   80100380 <panic>
    panic("dirlink");
801021a5:	83 ec 0c             	sub    $0xc,%esp
801021a8:	68 46 7b 10 80       	push   $0x80107b46
801021ad:	e8 ce e1 ff ff       	call   80100380 <panic>
801021b2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801021c0 <namei>:

struct inode*
namei(char *path)
{
801021c0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
801021c1:	31 d2                	xor    %edx,%edx
{
801021c3:	89 e5                	mov    %esp,%ebp
801021c5:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
801021c8:	8b 45 08             	mov    0x8(%ebp),%eax
801021cb:	8d 4d ea             	lea    -0x16(%ebp),%ecx
801021ce:	e8 dd fc ff ff       	call   80101eb0 <namex>
}
801021d3:	c9                   	leave  
801021d4:	c3                   	ret    
801021d5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801021dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801021e0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801021e0:	55                   	push   %ebp
  return namex(path, 1, name);
801021e1:	ba 01 00 00 00       	mov    $0x1,%edx
{
801021e6:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
801021e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801021eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801021ee:	5d                   	pop    %ebp
  return namex(path, 1, name);
801021ef:	e9 bc fc ff ff       	jmp    80101eb0 <namex>
801021f4:	66 90                	xchg   %ax,%ax
801021f6:	66 90                	xchg   %ax,%ax
801021f8:	66 90                	xchg   %ax,%ax
801021fa:	66 90                	xchg   %ax,%ax
801021fc:	66 90                	xchg   %ax,%ax
801021fe:	66 90                	xchg   %ax,%ax

80102200 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102200:	55                   	push   %ebp
80102201:	89 e5                	mov    %esp,%ebp
80102203:	57                   	push   %edi
80102204:	56                   	push   %esi
80102205:	53                   	push   %ebx
80102206:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
80102209:	85 c0                	test   %eax,%eax
8010220b:	0f 84 b4 00 00 00    	je     801022c5 <idestart+0xc5>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80102211:	8b 70 08             	mov    0x8(%eax),%esi
80102214:	89 c3                	mov    %eax,%ebx
80102216:	81 fe e7 03 00 00    	cmp    $0x3e7,%esi
8010221c:	0f 87 96 00 00 00    	ja     801022b8 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102222:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80102227:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010222e:	66 90                	xchg   %ax,%ax
80102230:	89 ca                	mov    %ecx,%edx
80102232:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102233:	83 e0 c0             	and    $0xffffffc0,%eax
80102236:	3c 40                	cmp    $0x40,%al
80102238:	75 f6                	jne    80102230 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010223a:	31 ff                	xor    %edi,%edi
8010223c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80102241:	89 f8                	mov    %edi,%eax
80102243:	ee                   	out    %al,(%dx)
80102244:	b8 01 00 00 00       	mov    $0x1,%eax
80102249:	ba f2 01 00 00       	mov    $0x1f2,%edx
8010224e:	ee                   	out    %al,(%dx)
8010224f:	ba f3 01 00 00       	mov    $0x1f3,%edx
80102254:	89 f0                	mov    %esi,%eax
80102256:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80102257:	89 f0                	mov    %esi,%eax
80102259:	ba f4 01 00 00       	mov    $0x1f4,%edx
8010225e:	c1 f8 08             	sar    $0x8,%eax
80102261:	ee                   	out    %al,(%dx)
80102262:	ba f5 01 00 00       	mov    $0x1f5,%edx
80102267:	89 f8                	mov    %edi,%eax
80102269:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010226a:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
8010226e:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102273:	c1 e0 04             	shl    $0x4,%eax
80102276:	83 e0 10             	and    $0x10,%eax
80102279:	83 c8 e0             	or     $0xffffffe0,%eax
8010227c:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
8010227d:	f6 03 04             	testb  $0x4,(%ebx)
80102280:	75 16                	jne    80102298 <idestart+0x98>
80102282:	b8 20 00 00 00       	mov    $0x20,%eax
80102287:	89 ca                	mov    %ecx,%edx
80102289:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010228a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010228d:	5b                   	pop    %ebx
8010228e:	5e                   	pop    %esi
8010228f:	5f                   	pop    %edi
80102290:	5d                   	pop    %ebp
80102291:	c3                   	ret    
80102292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102298:	b8 30 00 00 00       	mov    $0x30,%eax
8010229d:	89 ca                	mov    %ecx,%edx
8010229f:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
801022a0:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
801022a5:	8d 73 5c             	lea    0x5c(%ebx),%esi
801022a8:	ba f0 01 00 00       	mov    $0x1f0,%edx
801022ad:	fc                   	cld    
801022ae:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
801022b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801022b3:	5b                   	pop    %ebx
801022b4:	5e                   	pop    %esi
801022b5:	5f                   	pop    %edi
801022b6:	5d                   	pop    %ebp
801022b7:	c3                   	ret    
    panic("incorrect blockno");
801022b8:	83 ec 0c             	sub    $0xc,%esp
801022bb:	68 d4 75 10 80       	push   $0x801075d4
801022c0:	e8 bb e0 ff ff       	call   80100380 <panic>
    panic("idestart");
801022c5:	83 ec 0c             	sub    $0xc,%esp
801022c8:	68 cb 75 10 80       	push   $0x801075cb
801022cd:	e8 ae e0 ff ff       	call   80100380 <panic>
801022d2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801022e0 <ideinit>:
{
801022e0:	55                   	push   %ebp
801022e1:	89 e5                	mov    %esp,%ebp
801022e3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
801022e6:	68 e6 75 10 80       	push   $0x801075e6
801022eb:	68 00 16 11 80       	push   $0x80111600
801022f0:	e8 3b 22 00 00       	call   80104530 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801022f5:	58                   	pop    %eax
801022f6:	a1 84 17 11 80       	mov    0x80111784,%eax
801022fb:	5a                   	pop    %edx
801022fc:	83 e8 01             	sub    $0x1,%eax
801022ff:	50                   	push   %eax
80102300:	6a 0e                	push   $0xe
80102302:	e8 99 02 00 00       	call   801025a0 <ioapicenable>
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102307:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010230a:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010230f:	90                   	nop
80102310:	ec                   	in     (%dx),%al
80102311:	83 e0 c0             	and    $0xffffffc0,%eax
80102314:	3c 40                	cmp    $0x40,%al
80102316:	75 f8                	jne    80102310 <ideinit+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102318:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
8010231d:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102322:	ee                   	out    %al,(%dx)
80102323:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102328:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010232d:	eb 06                	jmp    80102335 <ideinit+0x55>
8010232f:	90                   	nop
  for(i=0; i<1000; i++){
80102330:	83 e9 01             	sub    $0x1,%ecx
80102333:	74 0f                	je     80102344 <ideinit+0x64>
80102335:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102336:	84 c0                	test   %al,%al
80102338:	74 f6                	je     80102330 <ideinit+0x50>
      havedisk1 = 1;
8010233a:	c7 05 e0 15 11 80 01 	movl   $0x1,0x801115e0
80102341:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102344:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102349:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010234e:	ee                   	out    %al,(%dx)
}
8010234f:	c9                   	leave  
80102350:	c3                   	ret    
80102351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102358:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010235f:	90                   	nop

80102360 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102360:	55                   	push   %ebp
80102361:	89 e5                	mov    %esp,%ebp
80102363:	57                   	push   %edi
80102364:	56                   	push   %esi
80102365:	53                   	push   %ebx
80102366:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102369:	68 00 16 11 80       	push   $0x80111600
8010236e:	e8 8d 23 00 00       	call   80104700 <acquire>

  if((b = idequeue) == 0){
80102373:	8b 1d e4 15 11 80    	mov    0x801115e4,%ebx
80102379:	83 c4 10             	add    $0x10,%esp
8010237c:	85 db                	test   %ebx,%ebx
8010237e:	74 63                	je     801023e3 <ideintr+0x83>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80102380:	8b 43 58             	mov    0x58(%ebx),%eax
80102383:	a3 e4 15 11 80       	mov    %eax,0x801115e4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102388:	8b 33                	mov    (%ebx),%esi
8010238a:	f7 c6 04 00 00 00    	test   $0x4,%esi
80102390:	75 2f                	jne    801023c1 <ideintr+0x61>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102392:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102397:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010239e:	66 90                	xchg   %ax,%ax
801023a0:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801023a1:	89 c1                	mov    %eax,%ecx
801023a3:	83 e1 c0             	and    $0xffffffc0,%ecx
801023a6:	80 f9 40             	cmp    $0x40,%cl
801023a9:	75 f5                	jne    801023a0 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801023ab:	a8 21                	test   $0x21,%al
801023ad:	75 12                	jne    801023c1 <ideintr+0x61>
    insl(0x1f0, b->data, BSIZE/4);
801023af:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
801023b2:	b9 80 00 00 00       	mov    $0x80,%ecx
801023b7:	ba f0 01 00 00       	mov    $0x1f0,%edx
801023bc:	fc                   	cld    
801023bd:	f3 6d                	rep insl (%dx),%es:(%edi)

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801023bf:	8b 33                	mov    (%ebx),%esi
  b->flags &= ~B_DIRTY;
801023c1:	83 e6 fb             	and    $0xfffffffb,%esi
  wakeup(b);
801023c4:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
801023c7:	83 ce 02             	or     $0x2,%esi
801023ca:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
801023cc:	53                   	push   %ebx
801023cd:	e8 8e 1e 00 00       	call   80104260 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801023d2:	a1 e4 15 11 80       	mov    0x801115e4,%eax
801023d7:	83 c4 10             	add    $0x10,%esp
801023da:	85 c0                	test   %eax,%eax
801023dc:	74 05                	je     801023e3 <ideintr+0x83>
    idestart(idequeue);
801023de:	e8 1d fe ff ff       	call   80102200 <idestart>
    release(&idelock);
801023e3:	83 ec 0c             	sub    $0xc,%esp
801023e6:	68 00 16 11 80       	push   $0x80111600
801023eb:	e8 b0 22 00 00       	call   801046a0 <release>

  release(&idelock);
}
801023f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801023f3:	5b                   	pop    %ebx
801023f4:	5e                   	pop    %esi
801023f5:	5f                   	pop    %edi
801023f6:	5d                   	pop    %ebp
801023f7:	c3                   	ret    
801023f8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801023ff:	90                   	nop

80102400 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102400:	55                   	push   %ebp
80102401:	89 e5                	mov    %esp,%ebp
80102403:	53                   	push   %ebx
80102404:	83 ec 10             	sub    $0x10,%esp
80102407:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010240a:	8d 43 0c             	lea    0xc(%ebx),%eax
8010240d:	50                   	push   %eax
8010240e:	e8 cd 20 00 00       	call   801044e0 <holdingsleep>
80102413:	83 c4 10             	add    $0x10,%esp
80102416:	85 c0                	test   %eax,%eax
80102418:	0f 84 c3 00 00 00    	je     801024e1 <iderw+0xe1>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010241e:	8b 03                	mov    (%ebx),%eax
80102420:	83 e0 06             	and    $0x6,%eax
80102423:	83 f8 02             	cmp    $0x2,%eax
80102426:	0f 84 a8 00 00 00    	je     801024d4 <iderw+0xd4>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
8010242c:	8b 53 04             	mov    0x4(%ebx),%edx
8010242f:	85 d2                	test   %edx,%edx
80102431:	74 0d                	je     80102440 <iderw+0x40>
80102433:	a1 e0 15 11 80       	mov    0x801115e0,%eax
80102438:	85 c0                	test   %eax,%eax
8010243a:	0f 84 87 00 00 00    	je     801024c7 <iderw+0xc7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102440:	83 ec 0c             	sub    $0xc,%esp
80102443:	68 00 16 11 80       	push   $0x80111600
80102448:	e8 b3 22 00 00       	call   80104700 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010244d:	a1 e4 15 11 80       	mov    0x801115e4,%eax
  b->qnext = 0;
80102452:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102459:	83 c4 10             	add    $0x10,%esp
8010245c:	85 c0                	test   %eax,%eax
8010245e:	74 60                	je     801024c0 <iderw+0xc0>
80102460:	89 c2                	mov    %eax,%edx
80102462:	8b 40 58             	mov    0x58(%eax),%eax
80102465:	85 c0                	test   %eax,%eax
80102467:	75 f7                	jne    80102460 <iderw+0x60>
80102469:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
8010246c:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
8010246e:	39 1d e4 15 11 80    	cmp    %ebx,0x801115e4
80102474:	74 3a                	je     801024b0 <iderw+0xb0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102476:	8b 03                	mov    (%ebx),%eax
80102478:	83 e0 06             	and    $0x6,%eax
8010247b:	83 f8 02             	cmp    $0x2,%eax
8010247e:	74 1b                	je     8010249b <iderw+0x9b>
    sleep(b, &idelock);
80102480:	83 ec 08             	sub    $0x8,%esp
80102483:	68 00 16 11 80       	push   $0x80111600
80102488:	53                   	push   %ebx
80102489:	e8 12 1d 00 00       	call   801041a0 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010248e:	8b 03                	mov    (%ebx),%eax
80102490:	83 c4 10             	add    $0x10,%esp
80102493:	83 e0 06             	and    $0x6,%eax
80102496:	83 f8 02             	cmp    $0x2,%eax
80102499:	75 e5                	jne    80102480 <iderw+0x80>
  }


  release(&idelock);
8010249b:	c7 45 08 00 16 11 80 	movl   $0x80111600,0x8(%ebp)
}
801024a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801024a5:	c9                   	leave  
  release(&idelock);
801024a6:	e9 f5 21 00 00       	jmp    801046a0 <release>
801024ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801024af:	90                   	nop
    idestart(b);
801024b0:	89 d8                	mov    %ebx,%eax
801024b2:	e8 49 fd ff ff       	call   80102200 <idestart>
801024b7:	eb bd                	jmp    80102476 <iderw+0x76>
801024b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801024c0:	ba e4 15 11 80       	mov    $0x801115e4,%edx
801024c5:	eb a5                	jmp    8010246c <iderw+0x6c>
    panic("iderw: ide disk 1 not present");
801024c7:	83 ec 0c             	sub    $0xc,%esp
801024ca:	68 15 76 10 80       	push   $0x80107615
801024cf:	e8 ac de ff ff       	call   80100380 <panic>
    panic("iderw: nothing to do");
801024d4:	83 ec 0c             	sub    $0xc,%esp
801024d7:	68 00 76 10 80       	push   $0x80107600
801024dc:	e8 9f de ff ff       	call   80100380 <panic>
    panic("iderw: buf not locked");
801024e1:	83 ec 0c             	sub    $0xc,%esp
801024e4:	68 ea 75 10 80       	push   $0x801075ea
801024e9:	e8 92 de ff ff       	call   80100380 <panic>
801024ee:	66 90                	xchg   %ax,%ax

801024f0 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
801024f0:	55                   	push   %ebp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801024f1:	c7 05 34 16 11 80 00 	movl   $0xfec00000,0x80111634
801024f8:	00 c0 fe 
{
801024fb:	89 e5                	mov    %esp,%ebp
801024fd:	56                   	push   %esi
801024fe:	53                   	push   %ebx
  ioapic->reg = reg;
801024ff:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80102506:	00 00 00 
  return ioapic->data;
80102509:	8b 15 34 16 11 80    	mov    0x80111634,%edx
8010250f:	8b 72 10             	mov    0x10(%edx),%esi
  ioapic->reg = reg;
80102512:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
80102518:	8b 0d 34 16 11 80    	mov    0x80111634,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
8010251e:	0f b6 15 80 17 11 80 	movzbl 0x80111780,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102525:	c1 ee 10             	shr    $0x10,%esi
80102528:	89 f0                	mov    %esi,%eax
8010252a:	0f b6 f0             	movzbl %al,%esi
  return ioapic->data;
8010252d:	8b 41 10             	mov    0x10(%ecx),%eax
  id = ioapicread(REG_ID) >> 24;
80102530:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102533:	39 c2                	cmp    %eax,%edx
80102535:	74 16                	je     8010254d <ioapicinit+0x5d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102537:	83 ec 0c             	sub    $0xc,%esp
8010253a:	68 34 76 10 80       	push   $0x80107634
8010253f:	e8 3c e1 ff ff       	call   80100680 <cprintf>
  ioapic->reg = reg;
80102544:	8b 0d 34 16 11 80    	mov    0x80111634,%ecx
8010254a:	83 c4 10             	add    $0x10,%esp
8010254d:	83 c6 21             	add    $0x21,%esi
{
80102550:	ba 10 00 00 00       	mov    $0x10,%edx
80102555:	b8 20 00 00 00       	mov    $0x20,%eax
8010255a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  ioapic->reg = reg;
80102560:	89 11                	mov    %edx,(%ecx)

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102562:	89 c3                	mov    %eax,%ebx
  ioapic->data = data;
80102564:	8b 0d 34 16 11 80    	mov    0x80111634,%ecx
  for(i = 0; i <= maxintr; i++){
8010256a:	83 c0 01             	add    $0x1,%eax
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010256d:	81 cb 00 00 01 00    	or     $0x10000,%ebx
  ioapic->data = data;
80102573:	89 59 10             	mov    %ebx,0x10(%ecx)
  ioapic->reg = reg;
80102576:	8d 5a 01             	lea    0x1(%edx),%ebx
  for(i = 0; i <= maxintr; i++){
80102579:	83 c2 02             	add    $0x2,%edx
  ioapic->reg = reg;
8010257c:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
8010257e:	8b 0d 34 16 11 80    	mov    0x80111634,%ecx
80102584:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
8010258b:	39 f0                	cmp    %esi,%eax
8010258d:	75 d1                	jne    80102560 <ioapicinit+0x70>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010258f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102592:	5b                   	pop    %ebx
80102593:	5e                   	pop    %esi
80102594:	5d                   	pop    %ebp
80102595:	c3                   	ret    
80102596:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010259d:	8d 76 00             	lea    0x0(%esi),%esi

801025a0 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801025a0:	55                   	push   %ebp
  ioapic->reg = reg;
801025a1:	8b 0d 34 16 11 80    	mov    0x80111634,%ecx
{
801025a7:	89 e5                	mov    %esp,%ebp
801025a9:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801025ac:	8d 50 20             	lea    0x20(%eax),%edx
801025af:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
801025b3:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801025b5:	8b 0d 34 16 11 80    	mov    0x80111634,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801025bb:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
801025be:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801025c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
801025c4:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801025c6:	a1 34 16 11 80       	mov    0x80111634,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801025cb:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
801025ce:	89 50 10             	mov    %edx,0x10(%eax)
}
801025d1:	5d                   	pop    %ebp
801025d2:	c3                   	ret    
801025d3:	66 90                	xchg   %ax,%ax
801025d5:	66 90                	xchg   %ax,%ax
801025d7:	66 90                	xchg   %ax,%ax
801025d9:	66 90                	xchg   %ax,%ax
801025db:	66 90                	xchg   %ax,%ax
801025dd:	66 90                	xchg   %ax,%ax
801025df:	90                   	nop

801025e0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801025e0:	55                   	push   %ebp
801025e1:	89 e5                	mov    %esp,%ebp
801025e3:	53                   	push   %ebx
801025e4:	83 ec 04             	sub    $0x4,%esp
801025e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801025ea:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
801025f0:	75 76                	jne    80102668 <kfree+0x88>
801025f2:	81 fb d0 57 11 80    	cmp    $0x801157d0,%ebx
801025f8:	72 6e                	jb     80102668 <kfree+0x88>
801025fa:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102600:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102605:	77 61                	ja     80102668 <kfree+0x88>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102607:	83 ec 04             	sub    $0x4,%esp
8010260a:	68 00 10 00 00       	push   $0x1000
8010260f:	6a 01                	push   $0x1
80102611:	53                   	push   %ebx
80102612:	e8 a9 21 00 00       	call   801047c0 <memset>

  if(kmem.use_lock)
80102617:	8b 15 74 16 11 80    	mov    0x80111674,%edx
8010261d:	83 c4 10             	add    $0x10,%esp
80102620:	85 d2                	test   %edx,%edx
80102622:	75 1c                	jne    80102640 <kfree+0x60>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102624:	a1 78 16 11 80       	mov    0x80111678,%eax
80102629:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  if(kmem.use_lock)
8010262b:	a1 74 16 11 80       	mov    0x80111674,%eax
  kmem.freelist = r;
80102630:	89 1d 78 16 11 80    	mov    %ebx,0x80111678
  if(kmem.use_lock)
80102636:	85 c0                	test   %eax,%eax
80102638:	75 1e                	jne    80102658 <kfree+0x78>
    release(&kmem.lock);
}
8010263a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010263d:	c9                   	leave  
8010263e:	c3                   	ret    
8010263f:	90                   	nop
    acquire(&kmem.lock);
80102640:	83 ec 0c             	sub    $0xc,%esp
80102643:	68 40 16 11 80       	push   $0x80111640
80102648:	e8 b3 20 00 00       	call   80104700 <acquire>
8010264d:	83 c4 10             	add    $0x10,%esp
80102650:	eb d2                	jmp    80102624 <kfree+0x44>
80102652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&kmem.lock);
80102658:	c7 45 08 40 16 11 80 	movl   $0x80111640,0x8(%ebp)
}
8010265f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102662:	c9                   	leave  
    release(&kmem.lock);
80102663:	e9 38 20 00 00       	jmp    801046a0 <release>
    panic("kfree");
80102668:	83 ec 0c             	sub    $0xc,%esp
8010266b:	68 66 76 10 80       	push   $0x80107666
80102670:	e8 0b dd ff ff       	call   80100380 <panic>
80102675:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010267c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102680 <freerange>:
{
80102680:	55                   	push   %ebp
80102681:	89 e5                	mov    %esp,%ebp
80102683:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
80102684:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102687:	8b 75 0c             	mov    0xc(%ebp),%esi
8010268a:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010268b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102691:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102697:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010269d:	39 de                	cmp    %ebx,%esi
8010269f:	72 23                	jb     801026c4 <freerange+0x44>
801026a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026b1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801026b7:	50                   	push   %eax
801026b8:	e8 23 ff ff ff       	call   801025e0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026bd:	83 c4 10             	add    $0x10,%esp
801026c0:	39 f3                	cmp    %esi,%ebx
801026c2:	76 e4                	jbe    801026a8 <freerange+0x28>
}
801026c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801026c7:	5b                   	pop    %ebx
801026c8:	5e                   	pop    %esi
801026c9:	5d                   	pop    %ebp
801026ca:	c3                   	ret    
801026cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801026cf:	90                   	nop

801026d0 <kinit2>:
{
801026d0:	55                   	push   %ebp
801026d1:	89 e5                	mov    %esp,%ebp
801026d3:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
801026d4:	8b 45 08             	mov    0x8(%ebp),%eax
{
801026d7:	8b 75 0c             	mov    0xc(%ebp),%esi
801026da:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
801026db:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801026e1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026e7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801026ed:	39 de                	cmp    %ebx,%esi
801026ef:	72 23                	jb     80102714 <kinit2+0x44>
801026f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801026f8:	83 ec 0c             	sub    $0xc,%esp
801026fb:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102701:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102707:	50                   	push   %eax
80102708:	e8 d3 fe ff ff       	call   801025e0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010270d:	83 c4 10             	add    $0x10,%esp
80102710:	39 de                	cmp    %ebx,%esi
80102712:	73 e4                	jae    801026f8 <kinit2+0x28>
  kmem.use_lock = 1;
80102714:	c7 05 74 16 11 80 01 	movl   $0x1,0x80111674
8010271b:	00 00 00 
}
8010271e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102721:	5b                   	pop    %ebx
80102722:	5e                   	pop    %esi
80102723:	5d                   	pop    %ebp
80102724:	c3                   	ret    
80102725:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010272c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102730 <kinit1>:
{
80102730:	55                   	push   %ebp
80102731:	89 e5                	mov    %esp,%ebp
80102733:	56                   	push   %esi
80102734:	53                   	push   %ebx
80102735:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
80102738:	83 ec 08             	sub    $0x8,%esp
8010273b:	68 6c 76 10 80       	push   $0x8010766c
80102740:	68 40 16 11 80       	push   $0x80111640
80102745:	e8 e6 1d 00 00       	call   80104530 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
8010274a:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010274d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102750:	c7 05 74 16 11 80 00 	movl   $0x0,0x80111674
80102757:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
8010275a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102760:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102766:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010276c:	39 de                	cmp    %ebx,%esi
8010276e:	72 1c                	jb     8010278c <kinit1+0x5c>
    kfree(p);
80102770:	83 ec 0c             	sub    $0xc,%esp
80102773:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102779:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
8010277f:	50                   	push   %eax
80102780:	e8 5b fe ff ff       	call   801025e0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102785:	83 c4 10             	add    $0x10,%esp
80102788:	39 de                	cmp    %ebx,%esi
8010278a:	73 e4                	jae    80102770 <kinit1+0x40>
}
8010278c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010278f:	5b                   	pop    %ebx
80102790:	5e                   	pop    %esi
80102791:	5d                   	pop    %ebp
80102792:	c3                   	ret    
80102793:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010279a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801027a0 <kalloc>:
char*
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
801027a0:	a1 74 16 11 80       	mov    0x80111674,%eax
801027a5:	85 c0                	test   %eax,%eax
801027a7:	75 1f                	jne    801027c8 <kalloc+0x28>
    acquire(&kmem.lock);
  r = kmem.freelist;
801027a9:	a1 78 16 11 80       	mov    0x80111678,%eax
  if(r)
801027ae:	85 c0                	test   %eax,%eax
801027b0:	74 0e                	je     801027c0 <kalloc+0x20>
    kmem.freelist = r->next;
801027b2:	8b 10                	mov    (%eax),%edx
801027b4:	89 15 78 16 11 80    	mov    %edx,0x80111678
  if(kmem.use_lock)
801027ba:	c3                   	ret    
801027bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801027bf:	90                   	nop
    release(&kmem.lock);
  return (char*)r;
}
801027c0:	c3                   	ret    
801027c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
801027c8:	55                   	push   %ebp
801027c9:	89 e5                	mov    %esp,%ebp
801027cb:	83 ec 24             	sub    $0x24,%esp
    acquire(&kmem.lock);
801027ce:	68 40 16 11 80       	push   $0x80111640
801027d3:	e8 28 1f 00 00       	call   80104700 <acquire>
  r = kmem.freelist;
801027d8:	a1 78 16 11 80       	mov    0x80111678,%eax
  if(kmem.use_lock)
801027dd:	8b 15 74 16 11 80    	mov    0x80111674,%edx
  if(r)
801027e3:	83 c4 10             	add    $0x10,%esp
801027e6:	85 c0                	test   %eax,%eax
801027e8:	74 08                	je     801027f2 <kalloc+0x52>
    kmem.freelist = r->next;
801027ea:	8b 08                	mov    (%eax),%ecx
801027ec:	89 0d 78 16 11 80    	mov    %ecx,0x80111678
  if(kmem.use_lock)
801027f2:	85 d2                	test   %edx,%edx
801027f4:	74 16                	je     8010280c <kalloc+0x6c>
    release(&kmem.lock);
801027f6:	83 ec 0c             	sub    $0xc,%esp
801027f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027fc:	68 40 16 11 80       	push   $0x80111640
80102801:	e8 9a 1e 00 00       	call   801046a0 <release>
  return (char*)r;
80102806:	8b 45 f4             	mov    -0xc(%ebp),%eax
    release(&kmem.lock);
80102809:	83 c4 10             	add    $0x10,%esp
}
8010280c:	c9                   	leave  
8010280d:	c3                   	ret    
8010280e:	66 90                	xchg   %ax,%ax

80102810 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102810:	ba 64 00 00 00       	mov    $0x64,%edx
80102815:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102816:	a8 01                	test   $0x1,%al
80102818:	0f 84 c2 00 00 00    	je     801028e0 <kbdgetc+0xd0>
{
8010281e:	55                   	push   %ebp
8010281f:	ba 60 00 00 00       	mov    $0x60,%edx
80102824:	89 e5                	mov    %esp,%ebp
80102826:	53                   	push   %ebx
80102827:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
80102828:	8b 1d 7c 16 11 80    	mov    0x8011167c,%ebx
  data = inb(KBDATAP);
8010282e:	0f b6 c8             	movzbl %al,%ecx
  if(data == 0xE0){
80102831:	3c e0                	cmp    $0xe0,%al
80102833:	74 5b                	je     80102890 <kbdgetc+0x80>
    return 0;
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102835:	89 da                	mov    %ebx,%edx
80102837:	83 e2 40             	and    $0x40,%edx
  } else if(data & 0x80){
8010283a:	84 c0                	test   %al,%al
8010283c:	78 62                	js     801028a0 <kbdgetc+0x90>
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
8010283e:	85 d2                	test   %edx,%edx
80102840:	74 09                	je     8010284b <kbdgetc+0x3b>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102842:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
80102845:	83 e3 bf             	and    $0xffffffbf,%ebx
    data |= 0x80;
80102848:	0f b6 c8             	movzbl %al,%ecx
  }

  shift |= shiftcode[data];
8010284b:	0f b6 91 a0 77 10 80 	movzbl -0x7fef8860(%ecx),%edx
  shift ^= togglecode[data];
80102852:	0f b6 81 a0 76 10 80 	movzbl -0x7fef8960(%ecx),%eax
  shift |= shiftcode[data];
80102859:	09 da                	or     %ebx,%edx
  shift ^= togglecode[data];
8010285b:	31 c2                	xor    %eax,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010285d:	89 d0                	mov    %edx,%eax
  shift ^= togglecode[data];
8010285f:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  c = charcode[shift & (CTL | SHIFT)][data];
80102865:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
80102868:	83 e2 08             	and    $0x8,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010286b:	8b 04 85 80 76 10 80 	mov    -0x7fef8980(,%eax,4),%eax
80102872:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
80102876:	74 0b                	je     80102883 <kbdgetc+0x73>
    if('a' <= c && c <= 'z')
80102878:	8d 50 9f             	lea    -0x61(%eax),%edx
8010287b:	83 fa 19             	cmp    $0x19,%edx
8010287e:	77 48                	ja     801028c8 <kbdgetc+0xb8>
      c += 'A' - 'a';
80102880:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102886:	c9                   	leave  
80102887:	c3                   	ret    
80102888:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010288f:	90                   	nop
    shift |= E0ESC;
80102890:	83 cb 40             	or     $0x40,%ebx
    return 0;
80102893:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
80102895:	89 1d 7c 16 11 80    	mov    %ebx,0x8011167c
}
8010289b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010289e:	c9                   	leave  
8010289f:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801028a0:	83 e0 7f             	and    $0x7f,%eax
801028a3:	85 d2                	test   %edx,%edx
801028a5:	0f 44 c8             	cmove  %eax,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
801028a8:	0f b6 81 a0 77 10 80 	movzbl -0x7fef8860(%ecx),%eax
801028af:	83 c8 40             	or     $0x40,%eax
801028b2:	0f b6 c0             	movzbl %al,%eax
801028b5:	f7 d0                	not    %eax
801028b7:	21 d8                	and    %ebx,%eax
}
801028b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    shift &= ~(shiftcode[data] | E0ESC);
801028bc:	a3 7c 16 11 80       	mov    %eax,0x8011167c
    return 0;
801028c1:	31 c0                	xor    %eax,%eax
}
801028c3:	c9                   	leave  
801028c4:	c3                   	ret    
801028c5:	8d 76 00             	lea    0x0(%esi),%esi
    else if('A' <= c && c <= 'Z')
801028c8:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
801028cb:	8d 50 20             	lea    0x20(%eax),%edx
}
801028ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028d1:	c9                   	leave  
      c += 'a' - 'A';
801028d2:	83 f9 1a             	cmp    $0x1a,%ecx
801028d5:	0f 42 c2             	cmovb  %edx,%eax
}
801028d8:	c3                   	ret    
801028d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
801028e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801028e5:	c3                   	ret    
801028e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801028ed:	8d 76 00             	lea    0x0(%esi),%esi

801028f0 <kbdintr>:

void
kbdintr(void)
{
801028f0:	55                   	push   %ebp
801028f1:	89 e5                	mov    %esp,%ebp
801028f3:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801028f6:	68 10 28 10 80       	push   $0x80102810
801028fb:	e8 f0 df ff ff       	call   801008f0 <consoleintr>
}
80102900:	83 c4 10             	add    $0x10,%esp
80102903:	c9                   	leave  
80102904:	c3                   	ret    
80102905:	66 90                	xchg   %ax,%ax
80102907:	66 90                	xchg   %ax,%ax
80102909:	66 90                	xchg   %ax,%ax
8010290b:	66 90                	xchg   %ax,%ax
8010290d:	66 90                	xchg   %ax,%ax
8010290f:	90                   	nop

80102910 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
80102910:	a1 80 16 11 80       	mov    0x80111680,%eax
80102915:	85 c0                	test   %eax,%eax
80102917:	0f 84 cb 00 00 00    	je     801029e8 <lapicinit+0xd8>
  lapic[index] = value;
8010291d:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102924:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102927:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010292a:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102931:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102934:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102937:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
8010293e:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102941:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102944:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
8010294b:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
8010294e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102951:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
80102958:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010295b:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010295e:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102965:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102968:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010296b:	8b 50 30             	mov    0x30(%eax),%edx
8010296e:	c1 ea 10             	shr    $0x10,%edx
80102971:	81 e2 fc 00 00 00    	and    $0xfc,%edx
80102977:	75 77                	jne    801029f0 <lapicinit+0xe0>
  lapic[index] = value;
80102979:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102980:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102983:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102986:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010298d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102990:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102993:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010299a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010299d:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029a0:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
801029a7:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029aa:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029ad:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
801029b4:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029b7:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029ba:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
801029c1:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
801029c4:	8b 50 20             	mov    0x20(%eax),%edx
801029c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801029ce:	66 90                	xchg   %ax,%ax
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
801029d0:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
801029d6:	80 e6 10             	and    $0x10,%dh
801029d9:	75 f5                	jne    801029d0 <lapicinit+0xc0>
  lapic[index] = value;
801029db:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801029e2:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029e5:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801029e8:	c3                   	ret    
801029e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  lapic[index] = value;
801029f0:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
801029f7:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801029fa:	8b 50 20             	mov    0x20(%eax),%edx
}
801029fd:	e9 77 ff ff ff       	jmp    80102979 <lapicinit+0x69>
80102a02:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102a10 <lapicid>:

int
lapicid(void)
{
  if (!lapic)
80102a10:	a1 80 16 11 80       	mov    0x80111680,%eax
80102a15:	85 c0                	test   %eax,%eax
80102a17:	74 07                	je     80102a20 <lapicid+0x10>
    return 0;
  return lapic[ID] >> 24;
80102a19:	8b 40 20             	mov    0x20(%eax),%eax
80102a1c:	c1 e8 18             	shr    $0x18,%eax
80102a1f:	c3                   	ret    
    return 0;
80102a20:	31 c0                	xor    %eax,%eax
}
80102a22:	c3                   	ret    
80102a23:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102a30 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102a30:	a1 80 16 11 80       	mov    0x80111680,%eax
80102a35:	85 c0                	test   %eax,%eax
80102a37:	74 0d                	je     80102a46 <lapiceoi+0x16>
  lapic[index] = value;
80102a39:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102a40:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a43:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102a46:	c3                   	ret    
80102a47:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a4e:	66 90                	xchg   %ax,%ax

80102a50 <microdelay>:
// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
}
80102a50:	c3                   	ret    
80102a51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a58:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a5f:	90                   	nop

80102a60 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102a60:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a61:	b8 0f 00 00 00       	mov    $0xf,%eax
80102a66:	ba 70 00 00 00       	mov    $0x70,%edx
80102a6b:	89 e5                	mov    %esp,%ebp
80102a6d:	53                   	push   %ebx
80102a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102a71:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102a74:	ee                   	out    %al,(%dx)
80102a75:	b8 0a 00 00 00       	mov    $0xa,%eax
80102a7a:	ba 71 00 00 00       	mov    $0x71,%edx
80102a7f:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102a80:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102a82:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102a85:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
80102a8b:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
80102a8d:	c1 e9 0c             	shr    $0xc,%ecx
  lapicw(ICRHI, apicid<<24);
80102a90:	89 da                	mov    %ebx,%edx
  wrv[1] = addr >> 4;
80102a92:	c1 e8 04             	shr    $0x4,%eax
    lapicw(ICRLO, STARTUP | (addr>>12));
80102a95:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102a98:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
80102a9e:	a1 80 16 11 80       	mov    0x80111680,%eax
80102aa3:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102aa9:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102aac:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102ab3:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102ab6:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102ab9:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102ac0:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102ac3:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102ac6:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102acc:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102acf:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102ad5:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102ad8:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102ade:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102ae1:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102ae7:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
80102aea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102aed:	c9                   	leave  
80102aee:	c3                   	ret    
80102aef:	90                   	nop

80102af0 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102af0:	55                   	push   %ebp
80102af1:	b8 0b 00 00 00       	mov    $0xb,%eax
80102af6:	ba 70 00 00 00       	mov    $0x70,%edx
80102afb:	89 e5                	mov    %esp,%ebp
80102afd:	57                   	push   %edi
80102afe:	56                   	push   %esi
80102aff:	53                   	push   %ebx
80102b00:	83 ec 4c             	sub    $0x4c,%esp
80102b03:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b04:	ba 71 00 00 00       	mov    $0x71,%edx
80102b09:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
80102b0a:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b0d:	bb 70 00 00 00       	mov    $0x70,%ebx
80102b12:	88 45 b3             	mov    %al,-0x4d(%ebp)
80102b15:	8d 76 00             	lea    0x0(%esi),%esi
80102b18:	31 c0                	xor    %eax,%eax
80102b1a:	89 da                	mov    %ebx,%edx
80102b1c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b1d:	b9 71 00 00 00       	mov    $0x71,%ecx
80102b22:	89 ca                	mov    %ecx,%edx
80102b24:	ec                   	in     (%dx),%al
80102b25:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b28:	89 da                	mov    %ebx,%edx
80102b2a:	b8 02 00 00 00       	mov    $0x2,%eax
80102b2f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b30:	89 ca                	mov    %ecx,%edx
80102b32:	ec                   	in     (%dx),%al
80102b33:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b36:	89 da                	mov    %ebx,%edx
80102b38:	b8 04 00 00 00       	mov    $0x4,%eax
80102b3d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b3e:	89 ca                	mov    %ecx,%edx
80102b40:	ec                   	in     (%dx),%al
80102b41:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b44:	89 da                	mov    %ebx,%edx
80102b46:	b8 07 00 00 00       	mov    $0x7,%eax
80102b4b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b4c:	89 ca                	mov    %ecx,%edx
80102b4e:	ec                   	in     (%dx),%al
80102b4f:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b52:	89 da                	mov    %ebx,%edx
80102b54:	b8 08 00 00 00       	mov    $0x8,%eax
80102b59:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b5a:	89 ca                	mov    %ecx,%edx
80102b5c:	ec                   	in     (%dx),%al
80102b5d:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b5f:	89 da                	mov    %ebx,%edx
80102b61:	b8 09 00 00 00       	mov    $0x9,%eax
80102b66:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b67:	89 ca                	mov    %ecx,%edx
80102b69:	ec                   	in     (%dx),%al
80102b6a:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b6c:	89 da                	mov    %ebx,%edx
80102b6e:	b8 0a 00 00 00       	mov    $0xa,%eax
80102b73:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b74:	89 ca                	mov    %ecx,%edx
80102b76:	ec                   	in     (%dx),%al

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102b77:	84 c0                	test   %al,%al
80102b79:	78 9d                	js     80102b18 <cmostime+0x28>
  return inb(CMOS_RETURN);
80102b7b:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102b7f:	89 fa                	mov    %edi,%edx
80102b81:	0f b6 fa             	movzbl %dl,%edi
80102b84:	89 f2                	mov    %esi,%edx
80102b86:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102b89:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102b8d:	0f b6 f2             	movzbl %dl,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b90:	89 da                	mov    %ebx,%edx
80102b92:	89 7d c8             	mov    %edi,-0x38(%ebp)
80102b95:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102b98:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
80102b9c:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102b9f:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102ba2:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102ba6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102ba9:	31 c0                	xor    %eax,%eax
80102bab:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bac:	89 ca                	mov    %ecx,%edx
80102bae:	ec                   	in     (%dx),%al
80102baf:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bb2:	89 da                	mov    %ebx,%edx
80102bb4:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102bb7:	b8 02 00 00 00       	mov    $0x2,%eax
80102bbc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bbd:	89 ca                	mov    %ecx,%edx
80102bbf:	ec                   	in     (%dx),%al
80102bc0:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bc3:	89 da                	mov    %ebx,%edx
80102bc5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102bc8:	b8 04 00 00 00       	mov    $0x4,%eax
80102bcd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bce:	89 ca                	mov    %ecx,%edx
80102bd0:	ec                   	in     (%dx),%al
80102bd1:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bd4:	89 da                	mov    %ebx,%edx
80102bd6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102bd9:	b8 07 00 00 00       	mov    $0x7,%eax
80102bde:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bdf:	89 ca                	mov    %ecx,%edx
80102be1:	ec                   	in     (%dx),%al
80102be2:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102be5:	89 da                	mov    %ebx,%edx
80102be7:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102bea:	b8 08 00 00 00       	mov    $0x8,%eax
80102bef:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bf0:	89 ca                	mov    %ecx,%edx
80102bf2:	ec                   	in     (%dx),%al
80102bf3:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bf6:	89 da                	mov    %ebx,%edx
80102bf8:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102bfb:	b8 09 00 00 00       	mov    $0x9,%eax
80102c00:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c01:	89 ca                	mov    %ecx,%edx
80102c03:	ec                   	in     (%dx),%al
80102c04:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102c07:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
80102c0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102c0d:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102c10:	6a 18                	push   $0x18
80102c12:	50                   	push   %eax
80102c13:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102c16:	50                   	push   %eax
80102c17:	e8 f4 1b 00 00       	call   80104810 <memcmp>
80102c1c:	83 c4 10             	add    $0x10,%esp
80102c1f:	85 c0                	test   %eax,%eax
80102c21:	0f 85 f1 fe ff ff    	jne    80102b18 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
80102c27:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
80102c2b:	75 78                	jne    80102ca5 <cmostime+0x1b5>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102c2d:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102c30:	89 c2                	mov    %eax,%edx
80102c32:	83 e0 0f             	and    $0xf,%eax
80102c35:	c1 ea 04             	shr    $0x4,%edx
80102c38:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102c3b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102c3e:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102c41:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102c44:	89 c2                	mov    %eax,%edx
80102c46:	83 e0 0f             	and    $0xf,%eax
80102c49:	c1 ea 04             	shr    $0x4,%edx
80102c4c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102c4f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102c52:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102c55:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102c58:	89 c2                	mov    %eax,%edx
80102c5a:	83 e0 0f             	and    $0xf,%eax
80102c5d:	c1 ea 04             	shr    $0x4,%edx
80102c60:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102c63:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102c66:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102c69:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102c6c:	89 c2                	mov    %eax,%edx
80102c6e:	83 e0 0f             	and    $0xf,%eax
80102c71:	c1 ea 04             	shr    $0x4,%edx
80102c74:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102c77:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102c7a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102c7d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102c80:	89 c2                	mov    %eax,%edx
80102c82:	83 e0 0f             	and    $0xf,%eax
80102c85:	c1 ea 04             	shr    $0x4,%edx
80102c88:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102c8b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102c8e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102c91:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102c94:	89 c2                	mov    %eax,%edx
80102c96:	83 e0 0f             	and    $0xf,%eax
80102c99:	c1 ea 04             	shr    $0x4,%edx
80102c9c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102c9f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102ca2:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102ca5:	8b 75 08             	mov    0x8(%ebp),%esi
80102ca8:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102cab:	89 06                	mov    %eax,(%esi)
80102cad:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102cb0:	89 46 04             	mov    %eax,0x4(%esi)
80102cb3:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102cb6:	89 46 08             	mov    %eax,0x8(%esi)
80102cb9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102cbc:	89 46 0c             	mov    %eax,0xc(%esi)
80102cbf:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102cc2:	89 46 10             	mov    %eax,0x10(%esi)
80102cc5:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102cc8:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102ccb:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102cd5:	5b                   	pop    %ebx
80102cd6:	5e                   	pop    %esi
80102cd7:	5f                   	pop    %edi
80102cd8:	5d                   	pop    %ebp
80102cd9:	c3                   	ret    
80102cda:	66 90                	xchg   %ax,%ax
80102cdc:	66 90                	xchg   %ax,%ax
80102cde:	66 90                	xchg   %ax,%ax

80102ce0 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102ce0:	8b 0d e8 16 11 80    	mov    0x801116e8,%ecx
80102ce6:	85 c9                	test   %ecx,%ecx
80102ce8:	0f 8e 8a 00 00 00    	jle    80102d78 <install_trans+0x98>
{
80102cee:	55                   	push   %ebp
80102cef:	89 e5                	mov    %esp,%ebp
80102cf1:	57                   	push   %edi
  for (tail = 0; tail < log.lh.n; tail++) {
80102cf2:	31 ff                	xor    %edi,%edi
{
80102cf4:	56                   	push   %esi
80102cf5:	53                   	push   %ebx
80102cf6:	83 ec 0c             	sub    $0xc,%esp
80102cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102d00:	a1 d4 16 11 80       	mov    0x801116d4,%eax
80102d05:	83 ec 08             	sub    $0x8,%esp
80102d08:	01 f8                	add    %edi,%eax
80102d0a:	83 c0 01             	add    $0x1,%eax
80102d0d:	50                   	push   %eax
80102d0e:	ff 35 e4 16 11 80    	push   0x801116e4
80102d14:	e8 b7 d3 ff ff       	call   801000d0 <bread>
80102d19:	89 c6                	mov    %eax,%esi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102d1b:	58                   	pop    %eax
80102d1c:	5a                   	pop    %edx
80102d1d:	ff 34 bd ec 16 11 80 	push   -0x7feee914(,%edi,4)
80102d24:	ff 35 e4 16 11 80    	push   0x801116e4
  for (tail = 0; tail < log.lh.n; tail++) {
80102d2a:	83 c7 01             	add    $0x1,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102d2d:	e8 9e d3 ff ff       	call   801000d0 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102d32:	83 c4 0c             	add    $0xc,%esp
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102d35:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102d37:	8d 46 5c             	lea    0x5c(%esi),%eax
80102d3a:	68 00 02 00 00       	push   $0x200
80102d3f:	50                   	push   %eax
80102d40:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102d43:	50                   	push   %eax
80102d44:	e8 17 1b 00 00       	call   80104860 <memmove>
    bwrite(dbuf);  // write dst to disk
80102d49:	89 1c 24             	mov    %ebx,(%esp)
80102d4c:	e8 5f d4 ff ff       	call   801001b0 <bwrite>
    brelse(lbuf);
80102d51:	89 34 24             	mov    %esi,(%esp)
80102d54:	e8 97 d4 ff ff       	call   801001f0 <brelse>
    brelse(dbuf);
80102d59:	89 1c 24             	mov    %ebx,(%esp)
80102d5c:	e8 8f d4 ff ff       	call   801001f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102d61:	83 c4 10             	add    $0x10,%esp
80102d64:	39 3d e8 16 11 80    	cmp    %edi,0x801116e8
80102d6a:	7f 94                	jg     80102d00 <install_trans+0x20>
  }
}
80102d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d6f:	5b                   	pop    %ebx
80102d70:	5e                   	pop    %esi
80102d71:	5f                   	pop    %edi
80102d72:	5d                   	pop    %ebp
80102d73:	c3                   	ret    
80102d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102d78:	c3                   	ret    
80102d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102d80 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102d80:	55                   	push   %ebp
80102d81:	89 e5                	mov    %esp,%ebp
80102d83:	53                   	push   %ebx
80102d84:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102d87:	ff 35 d4 16 11 80    	push   0x801116d4
80102d8d:	ff 35 e4 16 11 80    	push   0x801116e4
80102d93:	e8 38 d3 ff ff       	call   801000d0 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102d98:	83 c4 10             	add    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102d9b:	89 c3                	mov    %eax,%ebx
  hb->n = log.lh.n;
80102d9d:	a1 e8 16 11 80       	mov    0x801116e8,%eax
80102da2:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102da5:	85 c0                	test   %eax,%eax
80102da7:	7e 19                	jle    80102dc2 <write_head+0x42>
80102da9:	31 d2                	xor    %edx,%edx
80102dab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102daf:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102db0:	8b 0c 95 ec 16 11 80 	mov    -0x7feee914(,%edx,4),%ecx
80102db7:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102dbb:	83 c2 01             	add    $0x1,%edx
80102dbe:	39 d0                	cmp    %edx,%eax
80102dc0:	75 ee                	jne    80102db0 <write_head+0x30>
  }
  bwrite(buf);
80102dc2:	83 ec 0c             	sub    $0xc,%esp
80102dc5:	53                   	push   %ebx
80102dc6:	e8 e5 d3 ff ff       	call   801001b0 <bwrite>
  brelse(buf);
80102dcb:	89 1c 24             	mov    %ebx,(%esp)
80102dce:	e8 1d d4 ff ff       	call   801001f0 <brelse>
}
80102dd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102dd6:	83 c4 10             	add    $0x10,%esp
80102dd9:	c9                   	leave  
80102dda:	c3                   	ret    
80102ddb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102ddf:	90                   	nop

80102de0 <initlog>:
{
80102de0:	55                   	push   %ebp
80102de1:	89 e5                	mov    %esp,%ebp
80102de3:	53                   	push   %ebx
80102de4:	83 ec 2c             	sub    $0x2c,%esp
80102de7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102dea:	68 a0 78 10 80       	push   $0x801078a0
80102def:	68 a0 16 11 80       	push   $0x801116a0
80102df4:	e8 37 17 00 00       	call   80104530 <initlock>
  readsb(dev, &sb);
80102df9:	58                   	pop    %eax
80102dfa:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102dfd:	5a                   	pop    %edx
80102dfe:	50                   	push   %eax
80102dff:	53                   	push   %ebx
80102e00:	e8 3b e8 ff ff       	call   80101640 <readsb>
  log.start = sb.logstart;
80102e05:	8b 45 ec             	mov    -0x14(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102e08:	59                   	pop    %ecx
  log.dev = dev;
80102e09:	89 1d e4 16 11 80    	mov    %ebx,0x801116e4
  log.size = sb.nlog;
80102e0f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  log.start = sb.logstart;
80102e12:	a3 d4 16 11 80       	mov    %eax,0x801116d4
  log.size = sb.nlog;
80102e17:	89 15 d8 16 11 80    	mov    %edx,0x801116d8
  struct buf *buf = bread(log.dev, log.start);
80102e1d:	5a                   	pop    %edx
80102e1e:	50                   	push   %eax
80102e1f:	53                   	push   %ebx
80102e20:	e8 ab d2 ff ff       	call   801000d0 <bread>
  for (i = 0; i < log.lh.n; i++) {
80102e25:	83 c4 10             	add    $0x10,%esp
  log.lh.n = lh->n;
80102e28:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102e2b:	89 1d e8 16 11 80    	mov    %ebx,0x801116e8
  for (i = 0; i < log.lh.n; i++) {
80102e31:	85 db                	test   %ebx,%ebx
80102e33:	7e 1d                	jle    80102e52 <initlog+0x72>
80102e35:	31 d2                	xor    %edx,%edx
80102e37:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102e3e:	66 90                	xchg   %ax,%ax
    log.lh.block[i] = lh->block[i];
80102e40:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102e44:	89 0c 95 ec 16 11 80 	mov    %ecx,-0x7feee914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102e4b:	83 c2 01             	add    $0x1,%edx
80102e4e:	39 d3                	cmp    %edx,%ebx
80102e50:	75 ee                	jne    80102e40 <initlog+0x60>
  brelse(buf);
80102e52:	83 ec 0c             	sub    $0xc,%esp
80102e55:	50                   	push   %eax
80102e56:	e8 95 d3 ff ff       	call   801001f0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102e5b:	e8 80 fe ff ff       	call   80102ce0 <install_trans>
  log.lh.n = 0;
80102e60:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
80102e67:	00 00 00 
  write_head(); // clear the log
80102e6a:	e8 11 ff ff ff       	call   80102d80 <write_head>
}
80102e6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102e72:	83 c4 10             	add    $0x10,%esp
80102e75:	c9                   	leave  
80102e76:	c3                   	ret    
80102e77:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102e7e:	66 90                	xchg   %ax,%ax

80102e80 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102e80:	55                   	push   %ebp
80102e81:	89 e5                	mov    %esp,%ebp
80102e83:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102e86:	68 a0 16 11 80       	push   $0x801116a0
80102e8b:	e8 70 18 00 00       	call   80104700 <acquire>
80102e90:	83 c4 10             	add    $0x10,%esp
80102e93:	eb 18                	jmp    80102ead <begin_op+0x2d>
80102e95:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102e98:	83 ec 08             	sub    $0x8,%esp
80102e9b:	68 a0 16 11 80       	push   $0x801116a0
80102ea0:	68 a0 16 11 80       	push   $0x801116a0
80102ea5:	e8 f6 12 00 00       	call   801041a0 <sleep>
80102eaa:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102ead:	a1 e0 16 11 80       	mov    0x801116e0,%eax
80102eb2:	85 c0                	test   %eax,%eax
80102eb4:	75 e2                	jne    80102e98 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102eb6:	a1 dc 16 11 80       	mov    0x801116dc,%eax
80102ebb:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
80102ec1:	83 c0 01             	add    $0x1,%eax
80102ec4:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102ec7:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102eca:	83 fa 1e             	cmp    $0x1e,%edx
80102ecd:	7f c9                	jg     80102e98 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102ecf:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80102ed2:	a3 dc 16 11 80       	mov    %eax,0x801116dc
      release(&log.lock);
80102ed7:	68 a0 16 11 80       	push   $0x801116a0
80102edc:	e8 bf 17 00 00       	call   801046a0 <release>
      break;
    }
  }
}
80102ee1:	83 c4 10             	add    $0x10,%esp
80102ee4:	c9                   	leave  
80102ee5:	c3                   	ret    
80102ee6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102eed:	8d 76 00             	lea    0x0(%esi),%esi

80102ef0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102ef0:	55                   	push   %ebp
80102ef1:	89 e5                	mov    %esp,%ebp
80102ef3:	57                   	push   %edi
80102ef4:	56                   	push   %esi
80102ef5:	53                   	push   %ebx
80102ef6:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102ef9:	68 a0 16 11 80       	push   $0x801116a0
80102efe:	e8 fd 17 00 00       	call   80104700 <acquire>
  log.outstanding -= 1;
80102f03:	a1 dc 16 11 80       	mov    0x801116dc,%eax
  if(log.committing)
80102f08:	8b 35 e0 16 11 80    	mov    0x801116e0,%esi
80102f0e:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80102f11:	8d 58 ff             	lea    -0x1(%eax),%ebx
80102f14:	89 1d dc 16 11 80    	mov    %ebx,0x801116dc
  if(log.committing)
80102f1a:	85 f6                	test   %esi,%esi
80102f1c:	0f 85 22 01 00 00    	jne    80103044 <end_op+0x154>
    panic("log.committing");
  if(log.outstanding == 0){
80102f22:	85 db                	test   %ebx,%ebx
80102f24:	0f 85 f6 00 00 00    	jne    80103020 <end_op+0x130>
    do_commit = 1;
    log.committing = 1;
80102f2a:	c7 05 e0 16 11 80 01 	movl   $0x1,0x801116e0
80102f31:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102f34:	83 ec 0c             	sub    $0xc,%esp
80102f37:	68 a0 16 11 80       	push   $0x801116a0
80102f3c:	e8 5f 17 00 00       	call   801046a0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102f41:	8b 0d e8 16 11 80    	mov    0x801116e8,%ecx
80102f47:	83 c4 10             	add    $0x10,%esp
80102f4a:	85 c9                	test   %ecx,%ecx
80102f4c:	7f 42                	jg     80102f90 <end_op+0xa0>
    acquire(&log.lock);
80102f4e:	83 ec 0c             	sub    $0xc,%esp
80102f51:	68 a0 16 11 80       	push   $0x801116a0
80102f56:	e8 a5 17 00 00       	call   80104700 <acquire>
    wakeup(&log);
80102f5b:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
    log.committing = 0;
80102f62:	c7 05 e0 16 11 80 00 	movl   $0x0,0x801116e0
80102f69:	00 00 00 
    wakeup(&log);
80102f6c:	e8 ef 12 00 00       	call   80104260 <wakeup>
    release(&log.lock);
80102f71:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
80102f78:	e8 23 17 00 00       	call   801046a0 <release>
80102f7d:	83 c4 10             	add    $0x10,%esp
}
80102f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f83:	5b                   	pop    %ebx
80102f84:	5e                   	pop    %esi
80102f85:	5f                   	pop    %edi
80102f86:	5d                   	pop    %ebp
80102f87:	c3                   	ret    
80102f88:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102f8f:	90                   	nop
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102f90:	a1 d4 16 11 80       	mov    0x801116d4,%eax
80102f95:	83 ec 08             	sub    $0x8,%esp
80102f98:	01 d8                	add    %ebx,%eax
80102f9a:	83 c0 01             	add    $0x1,%eax
80102f9d:	50                   	push   %eax
80102f9e:	ff 35 e4 16 11 80    	push   0x801116e4
80102fa4:	e8 27 d1 ff ff       	call   801000d0 <bread>
80102fa9:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102fab:	58                   	pop    %eax
80102fac:	5a                   	pop    %edx
80102fad:	ff 34 9d ec 16 11 80 	push   -0x7feee914(,%ebx,4)
80102fb4:	ff 35 e4 16 11 80    	push   0x801116e4
  for (tail = 0; tail < log.lh.n; tail++) {
80102fba:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102fbd:	e8 0e d1 ff ff       	call   801000d0 <bread>
    memmove(to->data, from->data, BSIZE);
80102fc2:	83 c4 0c             	add    $0xc,%esp
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102fc5:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102fc7:	8d 40 5c             	lea    0x5c(%eax),%eax
80102fca:	68 00 02 00 00       	push   $0x200
80102fcf:	50                   	push   %eax
80102fd0:	8d 46 5c             	lea    0x5c(%esi),%eax
80102fd3:	50                   	push   %eax
80102fd4:	e8 87 18 00 00       	call   80104860 <memmove>
    bwrite(to);  // write the log
80102fd9:	89 34 24             	mov    %esi,(%esp)
80102fdc:	e8 cf d1 ff ff       	call   801001b0 <bwrite>
    brelse(from);
80102fe1:	89 3c 24             	mov    %edi,(%esp)
80102fe4:	e8 07 d2 ff ff       	call   801001f0 <brelse>
    brelse(to);
80102fe9:	89 34 24             	mov    %esi,(%esp)
80102fec:	e8 ff d1 ff ff       	call   801001f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102ff1:	83 c4 10             	add    $0x10,%esp
80102ff4:	3b 1d e8 16 11 80    	cmp    0x801116e8,%ebx
80102ffa:	7c 94                	jl     80102f90 <end_op+0xa0>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
80102ffc:	e8 7f fd ff ff       	call   80102d80 <write_head>
    install_trans(); // Now install writes to home locations
80103001:	e8 da fc ff ff       	call   80102ce0 <install_trans>
    log.lh.n = 0;
80103006:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
8010300d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103010:	e8 6b fd ff ff       	call   80102d80 <write_head>
80103015:	e9 34 ff ff ff       	jmp    80102f4e <end_op+0x5e>
8010301a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&log);
80103020:	83 ec 0c             	sub    $0xc,%esp
80103023:	68 a0 16 11 80       	push   $0x801116a0
80103028:	e8 33 12 00 00       	call   80104260 <wakeup>
  release(&log.lock);
8010302d:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
80103034:	e8 67 16 00 00       	call   801046a0 <release>
80103039:	83 c4 10             	add    $0x10,%esp
}
8010303c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010303f:	5b                   	pop    %ebx
80103040:	5e                   	pop    %esi
80103041:	5f                   	pop    %edi
80103042:	5d                   	pop    %ebp
80103043:	c3                   	ret    
    panic("log.committing");
80103044:	83 ec 0c             	sub    $0xc,%esp
80103047:	68 a4 78 10 80       	push   $0x801078a4
8010304c:	e8 2f d3 ff ff       	call   80100380 <panic>
80103051:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103058:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010305f:	90                   	nop

80103060 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103060:	55                   	push   %ebp
80103061:	89 e5                	mov    %esp,%ebp
80103063:	53                   	push   %ebx
80103064:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103067:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
{
8010306d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103070:	83 fa 1d             	cmp    $0x1d,%edx
80103073:	0f 8f 85 00 00 00    	jg     801030fe <log_write+0x9e>
80103079:	a1 d8 16 11 80       	mov    0x801116d8,%eax
8010307e:	83 e8 01             	sub    $0x1,%eax
80103081:	39 c2                	cmp    %eax,%edx
80103083:	7d 79                	jge    801030fe <log_write+0x9e>
    panic("too big a transaction");
  if (log.outstanding < 1)
80103085:	a1 dc 16 11 80       	mov    0x801116dc,%eax
8010308a:	85 c0                	test   %eax,%eax
8010308c:	7e 7d                	jle    8010310b <log_write+0xab>
    panic("log_write outside of trans");

  acquire(&log.lock);
8010308e:	83 ec 0c             	sub    $0xc,%esp
80103091:	68 a0 16 11 80       	push   $0x801116a0
80103096:	e8 65 16 00 00       	call   80104700 <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010309b:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
801030a1:	83 c4 10             	add    $0x10,%esp
801030a4:	85 d2                	test   %edx,%edx
801030a6:	7e 4a                	jle    801030f2 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801030a8:	8b 4b 08             	mov    0x8(%ebx),%ecx
  for (i = 0; i < log.lh.n; i++) {
801030ab:	31 c0                	xor    %eax,%eax
801030ad:	eb 08                	jmp    801030b7 <log_write+0x57>
801030af:	90                   	nop
801030b0:	83 c0 01             	add    $0x1,%eax
801030b3:	39 c2                	cmp    %eax,%edx
801030b5:	74 29                	je     801030e0 <log_write+0x80>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801030b7:	39 0c 85 ec 16 11 80 	cmp    %ecx,-0x7feee914(,%eax,4)
801030be:	75 f0                	jne    801030b0 <log_write+0x50>
      break;
  }
  log.lh.block[i] = b->blockno;
801030c0:	89 0c 85 ec 16 11 80 	mov    %ecx,-0x7feee914(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
801030c7:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
}
801030ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  release(&log.lock);
801030cd:	c7 45 08 a0 16 11 80 	movl   $0x801116a0,0x8(%ebp)
}
801030d4:	c9                   	leave  
  release(&log.lock);
801030d5:	e9 c6 15 00 00       	jmp    801046a0 <release>
801030da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
801030e0:	89 0c 95 ec 16 11 80 	mov    %ecx,-0x7feee914(,%edx,4)
    log.lh.n++;
801030e7:	83 c2 01             	add    $0x1,%edx
801030ea:	89 15 e8 16 11 80    	mov    %edx,0x801116e8
801030f0:	eb d5                	jmp    801030c7 <log_write+0x67>
  log.lh.block[i] = b->blockno;
801030f2:	8b 43 08             	mov    0x8(%ebx),%eax
801030f5:	a3 ec 16 11 80       	mov    %eax,0x801116ec
  if (i == log.lh.n)
801030fa:	75 cb                	jne    801030c7 <log_write+0x67>
801030fc:	eb e9                	jmp    801030e7 <log_write+0x87>
    panic("too big a transaction");
801030fe:	83 ec 0c             	sub    $0xc,%esp
80103101:	68 b3 78 10 80       	push   $0x801078b3
80103106:	e8 75 d2 ff ff       	call   80100380 <panic>
    panic("log_write outside of trans");
8010310b:	83 ec 0c             	sub    $0xc,%esp
8010310e:	68 c9 78 10 80       	push   $0x801078c9
80103113:	e8 68 d2 ff ff       	call   80100380 <panic>
80103118:	66 90                	xchg   %ax,%ax
8010311a:	66 90                	xchg   %ax,%ax
8010311c:	66 90                	xchg   %ax,%ax
8010311e:	66 90                	xchg   %ax,%ax

80103120 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103120:	55                   	push   %ebp
80103121:	89 e5                	mov    %esp,%ebp
80103123:	53                   	push   %ebx
80103124:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103127:	e8 84 09 00 00       	call   80103ab0 <cpuid>
8010312c:	89 c3                	mov    %eax,%ebx
8010312e:	e8 7d 09 00 00       	call   80103ab0 <cpuid>
80103133:	83 ec 04             	sub    $0x4,%esp
80103136:	53                   	push   %ebx
80103137:	50                   	push   %eax
80103138:	68 e4 78 10 80       	push   $0x801078e4
8010313d:	e8 3e d5 ff ff       	call   80100680 <cprintf>
  idtinit();       // load idt register
80103142:	e8 99 29 00 00       	call   80105ae0 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103147:	e8 f4 08 00 00       	call   80103a40 <mycpu>
8010314c:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010314e:	b8 01 00 00 00       	mov    $0x1,%eax
80103153:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
8010315a:	e8 31 0c 00 00       	call   80103d90 <scheduler>
8010315f:	90                   	nop

80103160 <mpenter>:
{
80103160:	55                   	push   %ebp
80103161:	89 e5                	mov    %esp,%ebp
80103163:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103166:	e8 c5 3a 00 00       	call   80106c30 <switchkvm>
  seginit();
8010316b:	e8 30 3a 00 00       	call   80106ba0 <seginit>
  lapicinit();
80103170:	e8 9b f7 ff ff       	call   80102910 <lapicinit>
  mpmain();
80103175:	e8 a6 ff ff ff       	call   80103120 <mpmain>
8010317a:	66 90                	xchg   %ax,%ax
8010317c:	66 90                	xchg   %ax,%ax
8010317e:	66 90                	xchg   %ax,%ax

80103180 <main>:
{
80103180:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103184:	83 e4 f0             	and    $0xfffffff0,%esp
80103187:	ff 71 fc             	push   -0x4(%ecx)
8010318a:	55                   	push   %ebp
8010318b:	89 e5                	mov    %esp,%ebp
8010318d:	53                   	push   %ebx
8010318e:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010318f:	83 ec 08             	sub    $0x8,%esp
80103192:	68 00 00 40 80       	push   $0x80400000
80103197:	68 d0 57 11 80       	push   $0x801157d0
8010319c:	e8 8f f5 ff ff       	call   80102730 <kinit1>
  kvmalloc();      // kernel page table
801031a1:	e8 7a 3f 00 00       	call   80107120 <kvmalloc>
  mpinit();        // detect other processors
801031a6:	e8 85 01 00 00       	call   80103330 <mpinit>
  lapicinit();     // interrupt controller
801031ab:	e8 60 f7 ff ff       	call   80102910 <lapicinit>
  seginit();       // segment descriptors
801031b0:	e8 eb 39 00 00       	call   80106ba0 <seginit>
  picinit();       // disable pic
801031b5:	e8 76 03 00 00       	call   80103530 <picinit>
  ioapicinit();    // another interrupt controller
801031ba:	e8 31 f3 ff ff       	call   801024f0 <ioapicinit>
  consoleinit();   // console hardware
801031bf:	e8 bc d9 ff ff       	call   80100b80 <consoleinit>
  uartinit();      // serial port
801031c4:	e8 67 2c 00 00       	call   80105e30 <uartinit>
  pinit();         // process table
801031c9:	e8 52 08 00 00       	call   80103a20 <pinit>
  tvinit();        // trap vectors
801031ce:	e8 8d 28 00 00       	call   80105a60 <tvinit>
  binit();         // buffer cache
801031d3:	e8 68 ce ff ff       	call   80100040 <binit>
  fileinit();      // file table
801031d8:	e8 53 dd ff ff       	call   80100f30 <fileinit>
  ideinit();       // disk 
801031dd:	e8 fe f0 ff ff       	call   801022e0 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801031e2:	83 c4 0c             	add    $0xc,%esp
801031e5:	68 8a 00 00 00       	push   $0x8a
801031ea:	68 8c a4 10 80       	push   $0x8010a48c
801031ef:	68 00 70 00 80       	push   $0x80007000
801031f4:	e8 67 16 00 00       	call   80104860 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801031f9:	83 c4 10             	add    $0x10,%esp
801031fc:	69 05 84 17 11 80 b0 	imul   $0xb0,0x80111784,%eax
80103203:	00 00 00 
80103206:	05 a0 17 11 80       	add    $0x801117a0,%eax
8010320b:	3d a0 17 11 80       	cmp    $0x801117a0,%eax
80103210:	76 7e                	jbe    80103290 <main+0x110>
80103212:	bb a0 17 11 80       	mov    $0x801117a0,%ebx
80103217:	eb 20                	jmp    80103239 <main+0xb9>
80103219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103220:	69 05 84 17 11 80 b0 	imul   $0xb0,0x80111784,%eax
80103227:	00 00 00 
8010322a:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103230:	05 a0 17 11 80       	add    $0x801117a0,%eax
80103235:	39 c3                	cmp    %eax,%ebx
80103237:	73 57                	jae    80103290 <main+0x110>
    if(c == mycpu())  // We've started already.
80103239:	e8 02 08 00 00       	call   80103a40 <mycpu>
8010323e:	39 c3                	cmp    %eax,%ebx
80103240:	74 de                	je     80103220 <main+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103242:	e8 59 f5 ff ff       	call   801027a0 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void(**)(void))(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
80103247:	83 ec 08             	sub    $0x8,%esp
    *(void(**)(void))(code-8) = mpenter;
8010324a:	c7 05 f8 6f 00 80 60 	movl   $0x80103160,0x80006ff8
80103251:	31 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103254:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
8010325b:	90 10 00 
    *(void**)(code-4) = stack + KSTACKSIZE;
8010325e:	05 00 10 00 00       	add    $0x1000,%eax
80103263:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    lapicstartap(c->apicid, V2P(code));
80103268:	0f b6 03             	movzbl (%ebx),%eax
8010326b:	68 00 70 00 00       	push   $0x7000
80103270:	50                   	push   %eax
80103271:	e8 ea f7 ff ff       	call   80102a60 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103276:	83 c4 10             	add    $0x10,%esp
80103279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103280:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80103286:	85 c0                	test   %eax,%eax
80103288:	74 f6                	je     80103280 <main+0x100>
8010328a:	eb 94                	jmp    80103220 <main+0xa0>
8010328c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103290:	83 ec 08             	sub    $0x8,%esp
80103293:	68 00 00 00 8e       	push   $0x8e000000
80103298:	68 00 00 40 80       	push   $0x80400000
8010329d:	e8 2e f4 ff ff       	call   801026d0 <kinit2>
  userinit();      // first user process
801032a2:	e8 59 08 00 00       	call   80103b00 <userinit>
  mpmain();        // finish this processor's setup
801032a7:	e8 74 fe ff ff       	call   80103120 <mpmain>
801032ac:	66 90                	xchg   %ax,%ax
801032ae:	66 90                	xchg   %ax,%ax

801032b0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801032b0:	55                   	push   %ebp
801032b1:	89 e5                	mov    %esp,%ebp
801032b3:	57                   	push   %edi
801032b4:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
801032b5:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
801032bb:	53                   	push   %ebx
  e = addr+len;
801032bc:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
801032bf:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
801032c2:	39 de                	cmp    %ebx,%esi
801032c4:	72 10                	jb     801032d6 <mpsearch1+0x26>
801032c6:	eb 50                	jmp    80103318 <mpsearch1+0x68>
801032c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801032cf:	90                   	nop
801032d0:	89 fe                	mov    %edi,%esi
801032d2:	39 fb                	cmp    %edi,%ebx
801032d4:	76 42                	jbe    80103318 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801032d6:	83 ec 04             	sub    $0x4,%esp
801032d9:	8d 7e 10             	lea    0x10(%esi),%edi
801032dc:	6a 04                	push   $0x4
801032de:	68 f8 78 10 80       	push   $0x801078f8
801032e3:	56                   	push   %esi
801032e4:	e8 27 15 00 00       	call   80104810 <memcmp>
801032e9:	83 c4 10             	add    $0x10,%esp
801032ec:	89 c2                	mov    %eax,%edx
801032ee:	85 c0                	test   %eax,%eax
801032f0:	75 de                	jne    801032d0 <mpsearch1+0x20>
801032f2:	89 f0                	mov    %esi,%eax
801032f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    sum += addr[i];
801032f8:	0f b6 08             	movzbl (%eax),%ecx
  for(i=0; i<len; i++)
801032fb:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
801032fe:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
80103300:	39 f8                	cmp    %edi,%eax
80103302:	75 f4                	jne    801032f8 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103304:	84 d2                	test   %dl,%dl
80103306:	75 c8                	jne    801032d0 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
80103308:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010330b:	89 f0                	mov    %esi,%eax
8010330d:	5b                   	pop    %ebx
8010330e:	5e                   	pop    %esi
8010330f:	5f                   	pop    %edi
80103310:	5d                   	pop    %ebp
80103311:	c3                   	ret    
80103312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103318:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010331b:	31 f6                	xor    %esi,%esi
}
8010331d:	5b                   	pop    %ebx
8010331e:	89 f0                	mov    %esi,%eax
80103320:	5e                   	pop    %esi
80103321:	5f                   	pop    %edi
80103322:	5d                   	pop    %ebp
80103323:	c3                   	ret    
80103324:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010332b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010332f:	90                   	nop

80103330 <mpinit>:
  return conf;
}

void
mpinit(void)
{
80103330:	55                   	push   %ebp
80103331:	89 e5                	mov    %esp,%ebp
80103333:	57                   	push   %edi
80103334:	56                   	push   %esi
80103335:	53                   	push   %ebx
80103336:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103339:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80103340:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80103347:	c1 e0 08             	shl    $0x8,%eax
8010334a:	09 d0                	or     %edx,%eax
8010334c:	c1 e0 04             	shl    $0x4,%eax
8010334f:	75 1b                	jne    8010336c <mpinit+0x3c>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103351:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80103358:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
8010335f:	c1 e0 08             	shl    $0x8,%eax
80103362:	09 d0                	or     %edx,%eax
80103364:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80103367:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
8010336c:	ba 00 04 00 00       	mov    $0x400,%edx
80103371:	e8 3a ff ff ff       	call   801032b0 <mpsearch1>
80103376:	89 c3                	mov    %eax,%ebx
80103378:	85 c0                	test   %eax,%eax
8010337a:	0f 84 40 01 00 00    	je     801034c0 <mpinit+0x190>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103380:	8b 73 04             	mov    0x4(%ebx),%esi
80103383:	85 f6                	test   %esi,%esi
80103385:	0f 84 25 01 00 00    	je     801034b0 <mpinit+0x180>
  if(memcmp(conf, "PCMP", 4) != 0)
8010338b:	83 ec 04             	sub    $0x4,%esp
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010338e:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
  if(memcmp(conf, "PCMP", 4) != 0)
80103394:	6a 04                	push   $0x4
80103396:	68 fd 78 10 80       	push   $0x801078fd
8010339b:	50                   	push   %eax
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010339c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010339f:	e8 6c 14 00 00       	call   80104810 <memcmp>
801033a4:	83 c4 10             	add    $0x10,%esp
801033a7:	85 c0                	test   %eax,%eax
801033a9:	0f 85 01 01 00 00    	jne    801034b0 <mpinit+0x180>
  if(conf->version != 1 && conf->version != 4)
801033af:	0f b6 86 06 00 00 80 	movzbl -0x7ffffffa(%esi),%eax
801033b6:	3c 01                	cmp    $0x1,%al
801033b8:	74 08                	je     801033c2 <mpinit+0x92>
801033ba:	3c 04                	cmp    $0x4,%al
801033bc:	0f 85 ee 00 00 00    	jne    801034b0 <mpinit+0x180>
  if(sum((uchar*)conf, conf->length) != 0)
801033c2:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
  for(i=0; i<len; i++)
801033c9:	66 85 d2             	test   %dx,%dx
801033cc:	74 22                	je     801033f0 <mpinit+0xc0>
801033ce:	8d 3c 32             	lea    (%edx,%esi,1),%edi
801033d1:	89 f0                	mov    %esi,%eax
  sum = 0;
801033d3:	31 d2                	xor    %edx,%edx
801033d5:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
801033d8:	0f b6 88 00 00 00 80 	movzbl -0x80000000(%eax),%ecx
  for(i=0; i<len; i++)
801033df:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
801033e2:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
801033e4:	39 f8                	cmp    %edi,%eax
801033e6:	75 f0                	jne    801033d8 <mpinit+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
801033e8:	84 d2                	test   %dl,%dl
801033ea:	0f 85 c0 00 00 00    	jne    801034b0 <mpinit+0x180>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
801033f0:	8b 86 24 00 00 80    	mov    -0x7fffffdc(%esi),%eax
801033f6:	a3 80 16 11 80       	mov    %eax,0x80111680
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801033fb:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
80103402:	8d 86 2c 00 00 80    	lea    -0x7fffffd4(%esi),%eax
  ismp = 1;
80103408:	be 01 00 00 00       	mov    $0x1,%esi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010340d:	03 55 e4             	add    -0x1c(%ebp),%edx
80103410:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80103413:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103417:	90                   	nop
80103418:	39 d0                	cmp    %edx,%eax
8010341a:	73 15                	jae    80103431 <mpinit+0x101>
    switch(*p){
8010341c:	0f b6 08             	movzbl (%eax),%ecx
8010341f:	80 f9 02             	cmp    $0x2,%cl
80103422:	74 4c                	je     80103470 <mpinit+0x140>
80103424:	77 3a                	ja     80103460 <mpinit+0x130>
80103426:	84 c9                	test   %cl,%cl
80103428:	74 56                	je     80103480 <mpinit+0x150>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010342a:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010342d:	39 d0                	cmp    %edx,%eax
8010342f:	72 eb                	jb     8010341c <mpinit+0xec>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103431:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103434:	85 f6                	test   %esi,%esi
80103436:	0f 84 d9 00 00 00    	je     80103515 <mpinit+0x1e5>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
8010343c:	80 7b 0c 00          	cmpb   $0x0,0xc(%ebx)
80103440:	74 15                	je     80103457 <mpinit+0x127>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103442:	b8 70 00 00 00       	mov    $0x70,%eax
80103447:	ba 22 00 00 00       	mov    $0x22,%edx
8010344c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010344d:	ba 23 00 00 00       	mov    $0x23,%edx
80103452:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103453:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103456:	ee                   	out    %al,(%dx)
  }
}
80103457:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010345a:	5b                   	pop    %ebx
8010345b:	5e                   	pop    %esi
8010345c:	5f                   	pop    %edi
8010345d:	5d                   	pop    %ebp
8010345e:	c3                   	ret    
8010345f:	90                   	nop
    switch(*p){
80103460:	83 e9 03             	sub    $0x3,%ecx
80103463:	80 f9 01             	cmp    $0x1,%cl
80103466:	76 c2                	jbe    8010342a <mpinit+0xfa>
80103468:	31 f6                	xor    %esi,%esi
8010346a:	eb ac                	jmp    80103418 <mpinit+0xe8>
8010346c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
80103470:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
      p += sizeof(struct mpioapic);
80103474:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
80103477:	88 0d 80 17 11 80    	mov    %cl,0x80111780
      continue;
8010347d:	eb 99                	jmp    80103418 <mpinit+0xe8>
8010347f:	90                   	nop
      if(ncpu < NCPU) {
80103480:	8b 0d 84 17 11 80    	mov    0x80111784,%ecx
80103486:	83 f9 07             	cmp    $0x7,%ecx
80103489:	7f 19                	jg     801034a4 <mpinit+0x174>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010348b:	69 f9 b0 00 00 00    	imul   $0xb0,%ecx,%edi
80103491:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
        ncpu++;
80103495:	83 c1 01             	add    $0x1,%ecx
80103498:	89 0d 84 17 11 80    	mov    %ecx,0x80111784
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010349e:	88 9f a0 17 11 80    	mov    %bl,-0x7feee860(%edi)
      p += sizeof(struct mpproc);
801034a4:	83 c0 14             	add    $0x14,%eax
      continue;
801034a7:	e9 6c ff ff ff       	jmp    80103418 <mpinit+0xe8>
801034ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    panic("Expect to run on an SMP");
801034b0:	83 ec 0c             	sub    $0xc,%esp
801034b3:	68 02 79 10 80       	push   $0x80107902
801034b8:	e8 c3 ce ff ff       	call   80100380 <panic>
801034bd:	8d 76 00             	lea    0x0(%esi),%esi
{
801034c0:	bb 00 00 0f 80       	mov    $0x800f0000,%ebx
801034c5:	eb 13                	jmp    801034da <mpinit+0x1aa>
801034c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801034ce:	66 90                	xchg   %ax,%ax
  for(p = addr; p < e; p += sizeof(struct mp))
801034d0:	89 f3                	mov    %esi,%ebx
801034d2:	81 fe 00 00 10 80    	cmp    $0x80100000,%esi
801034d8:	74 d6                	je     801034b0 <mpinit+0x180>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801034da:	83 ec 04             	sub    $0x4,%esp
801034dd:	8d 73 10             	lea    0x10(%ebx),%esi
801034e0:	6a 04                	push   $0x4
801034e2:	68 f8 78 10 80       	push   $0x801078f8
801034e7:	53                   	push   %ebx
801034e8:	e8 23 13 00 00       	call   80104810 <memcmp>
801034ed:	83 c4 10             	add    $0x10,%esp
801034f0:	89 c2                	mov    %eax,%edx
801034f2:	85 c0                	test   %eax,%eax
801034f4:	75 da                	jne    801034d0 <mpinit+0x1a0>
801034f6:	89 d8                	mov    %ebx,%eax
801034f8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801034ff:	90                   	nop
    sum += addr[i];
80103500:	0f b6 08             	movzbl (%eax),%ecx
  for(i=0; i<len; i++)
80103503:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
80103506:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
80103508:	39 f0                	cmp    %esi,%eax
8010350a:	75 f4                	jne    80103500 <mpinit+0x1d0>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010350c:	84 d2                	test   %dl,%dl
8010350e:	75 c0                	jne    801034d0 <mpinit+0x1a0>
80103510:	e9 6b fe ff ff       	jmp    80103380 <mpinit+0x50>
    panic("Didn't find a suitable machine");
80103515:	83 ec 0c             	sub    $0xc,%esp
80103518:	68 1c 79 10 80       	push   $0x8010791c
8010351d:	e8 5e ce ff ff       	call   80100380 <panic>
80103522:	66 90                	xchg   %ax,%ax
80103524:	66 90                	xchg   %ax,%ax
80103526:	66 90                	xchg   %ax,%ax
80103528:	66 90                	xchg   %ax,%ax
8010352a:	66 90                	xchg   %ax,%ax
8010352c:	66 90                	xchg   %ax,%ax
8010352e:	66 90                	xchg   %ax,%ax

80103530 <picinit>:
80103530:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103535:	ba 21 00 00 00       	mov    $0x21,%edx
8010353a:	ee                   	out    %al,(%dx)
8010353b:	ba a1 00 00 00       	mov    $0xa1,%edx
80103540:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80103541:	c3                   	ret    
80103542:	66 90                	xchg   %ax,%ax
80103544:	66 90                	xchg   %ax,%ax
80103546:	66 90                	xchg   %ax,%ax
80103548:	66 90                	xchg   %ax,%ax
8010354a:	66 90                	xchg   %ax,%ax
8010354c:	66 90                	xchg   %ax,%ax
8010354e:	66 90                	xchg   %ax,%ax

80103550 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103550:	55                   	push   %ebp
80103551:	89 e5                	mov    %esp,%ebp
80103553:	57                   	push   %edi
80103554:	56                   	push   %esi
80103555:	53                   	push   %ebx
80103556:	83 ec 0c             	sub    $0xc,%esp
80103559:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010355c:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
8010355f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80103565:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010356b:	e8 e0 d9 ff ff       	call   80100f50 <filealloc>
80103570:	89 03                	mov    %eax,(%ebx)
80103572:	85 c0                	test   %eax,%eax
80103574:	0f 84 a8 00 00 00    	je     80103622 <pipealloc+0xd2>
8010357a:	e8 d1 d9 ff ff       	call   80100f50 <filealloc>
8010357f:	89 06                	mov    %eax,(%esi)
80103581:	85 c0                	test   %eax,%eax
80103583:	0f 84 87 00 00 00    	je     80103610 <pipealloc+0xc0>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103589:	e8 12 f2 ff ff       	call   801027a0 <kalloc>
8010358e:	89 c7                	mov    %eax,%edi
80103590:	85 c0                	test   %eax,%eax
80103592:	0f 84 b0 00 00 00    	je     80103648 <pipealloc+0xf8>
    goto bad;
  p->readopen = 1;
80103598:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010359f:	00 00 00 
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
801035a2:	83 ec 08             	sub    $0x8,%esp
  p->writeopen = 1;
801035a5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035ac:	00 00 00 
  p->nwrite = 0;
801035af:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035b6:	00 00 00 
  p->nread = 0;
801035b9:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035c0:	00 00 00 
  initlock(&p->lock, "pipe");
801035c3:	68 3b 79 10 80       	push   $0x8010793b
801035c8:	50                   	push   %eax
801035c9:	e8 62 0f 00 00       	call   80104530 <initlock>
  (*f0)->type = FD_PIPE;
801035ce:	8b 03                	mov    (%ebx),%eax
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
801035d0:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801035d3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801035d9:	8b 03                	mov    (%ebx),%eax
801035db:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801035df:	8b 03                	mov    (%ebx),%eax
801035e1:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801035e5:	8b 03                	mov    (%ebx),%eax
801035e7:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
801035ea:	8b 06                	mov    (%esi),%eax
801035ec:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801035f2:	8b 06                	mov    (%esi),%eax
801035f4:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801035f8:	8b 06                	mov    (%esi),%eax
801035fa:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801035fe:	8b 06                	mov    (%esi),%eax
80103600:	89 78 0c             	mov    %edi,0xc(%eax)
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
80103603:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80103606:	31 c0                	xor    %eax,%eax
}
80103608:	5b                   	pop    %ebx
80103609:	5e                   	pop    %esi
8010360a:	5f                   	pop    %edi
8010360b:	5d                   	pop    %ebp
8010360c:	c3                   	ret    
8010360d:	8d 76 00             	lea    0x0(%esi),%esi
  if(*f0)
80103610:	8b 03                	mov    (%ebx),%eax
80103612:	85 c0                	test   %eax,%eax
80103614:	74 1e                	je     80103634 <pipealloc+0xe4>
    fileclose(*f0);
80103616:	83 ec 0c             	sub    $0xc,%esp
80103619:	50                   	push   %eax
8010361a:	e8 f1 d9 ff ff       	call   80101010 <fileclose>
8010361f:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103622:	8b 06                	mov    (%esi),%eax
80103624:	85 c0                	test   %eax,%eax
80103626:	74 0c                	je     80103634 <pipealloc+0xe4>
    fileclose(*f1);
80103628:	83 ec 0c             	sub    $0xc,%esp
8010362b:	50                   	push   %eax
8010362c:	e8 df d9 ff ff       	call   80101010 <fileclose>
80103631:	83 c4 10             	add    $0x10,%esp
}
80103634:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
80103637:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010363c:	5b                   	pop    %ebx
8010363d:	5e                   	pop    %esi
8010363e:	5f                   	pop    %edi
8010363f:	5d                   	pop    %ebp
80103640:	c3                   	ret    
80103641:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(*f0)
80103648:	8b 03                	mov    (%ebx),%eax
8010364a:	85 c0                	test   %eax,%eax
8010364c:	75 c8                	jne    80103616 <pipealloc+0xc6>
8010364e:	eb d2                	jmp    80103622 <pipealloc+0xd2>

80103650 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103650:	55                   	push   %ebp
80103651:	89 e5                	mov    %esp,%ebp
80103653:	56                   	push   %esi
80103654:	53                   	push   %ebx
80103655:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103658:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
8010365b:	83 ec 0c             	sub    $0xc,%esp
8010365e:	53                   	push   %ebx
8010365f:	e8 9c 10 00 00       	call   80104700 <acquire>
  if(writable){
80103664:	83 c4 10             	add    $0x10,%esp
80103667:	85 f6                	test   %esi,%esi
80103669:	74 65                	je     801036d0 <pipeclose+0x80>
    p->writeopen = 0;
    wakeup(&p->nread);
8010366b:	83 ec 0c             	sub    $0xc,%esp
8010366e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
    p->writeopen = 0;
80103674:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
8010367b:	00 00 00 
    wakeup(&p->nread);
8010367e:	50                   	push   %eax
8010367f:	e8 dc 0b 00 00       	call   80104260 <wakeup>
80103684:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103687:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010368d:	85 d2                	test   %edx,%edx
8010368f:	75 0a                	jne    8010369b <pipeclose+0x4b>
80103691:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103697:	85 c0                	test   %eax,%eax
80103699:	74 15                	je     801036b0 <pipeclose+0x60>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010369b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010369e:	8d 65 f8             	lea    -0x8(%ebp),%esp
801036a1:	5b                   	pop    %ebx
801036a2:	5e                   	pop    %esi
801036a3:	5d                   	pop    %ebp
    release(&p->lock);
801036a4:	e9 f7 0f 00 00       	jmp    801046a0 <release>
801036a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    release(&p->lock);
801036b0:	83 ec 0c             	sub    $0xc,%esp
801036b3:	53                   	push   %ebx
801036b4:	e8 e7 0f 00 00       	call   801046a0 <release>
    kfree((char*)p);
801036b9:	89 5d 08             	mov    %ebx,0x8(%ebp)
801036bc:	83 c4 10             	add    $0x10,%esp
}
801036bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
801036c2:	5b                   	pop    %ebx
801036c3:	5e                   	pop    %esi
801036c4:	5d                   	pop    %ebp
    kfree((char*)p);
801036c5:	e9 16 ef ff ff       	jmp    801025e0 <kfree>
801036ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&p->nwrite);
801036d0:	83 ec 0c             	sub    $0xc,%esp
801036d3:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
    p->readopen = 0;
801036d9:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
801036e0:	00 00 00 
    wakeup(&p->nwrite);
801036e3:	50                   	push   %eax
801036e4:	e8 77 0b 00 00       	call   80104260 <wakeup>
801036e9:	83 c4 10             	add    $0x10,%esp
801036ec:	eb 99                	jmp    80103687 <pipeclose+0x37>
801036ee:	66 90                	xchg   %ax,%ax

801036f0 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801036f0:	55                   	push   %ebp
801036f1:	89 e5                	mov    %esp,%ebp
801036f3:	57                   	push   %edi
801036f4:	56                   	push   %esi
801036f5:	53                   	push   %ebx
801036f6:	83 ec 28             	sub    $0x28,%esp
801036f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801036fc:	53                   	push   %ebx
801036fd:	e8 fe 0f 00 00       	call   80104700 <acquire>
  for(i = 0; i < n; i++){
80103702:	8b 45 10             	mov    0x10(%ebp),%eax
80103705:	83 c4 10             	add    $0x10,%esp
80103708:	85 c0                	test   %eax,%eax
8010370a:	0f 8e c0 00 00 00    	jle    801037d0 <pipewrite+0xe0>
80103710:	8b 45 0c             	mov    0xc(%ebp),%eax
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103713:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103719:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
8010371f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103722:	03 45 10             	add    0x10(%ebp),%eax
80103725:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103728:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010372e:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103734:	89 ca                	mov    %ecx,%edx
80103736:	05 00 02 00 00       	add    $0x200,%eax
8010373b:	39 c1                	cmp    %eax,%ecx
8010373d:	74 3f                	je     8010377e <pipewrite+0x8e>
8010373f:	eb 67                	jmp    801037a8 <pipewrite+0xb8>
80103741:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->readopen == 0 || myproc()->killed){
80103748:	e8 83 03 00 00       	call   80103ad0 <myproc>
8010374d:	8b 48 24             	mov    0x24(%eax),%ecx
80103750:	85 c9                	test   %ecx,%ecx
80103752:	75 34                	jne    80103788 <pipewrite+0x98>
      wakeup(&p->nread);
80103754:	83 ec 0c             	sub    $0xc,%esp
80103757:	57                   	push   %edi
80103758:	e8 03 0b 00 00       	call   80104260 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010375d:	58                   	pop    %eax
8010375e:	5a                   	pop    %edx
8010375f:	53                   	push   %ebx
80103760:	56                   	push   %esi
80103761:	e8 3a 0a 00 00       	call   801041a0 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103766:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010376c:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103772:	83 c4 10             	add    $0x10,%esp
80103775:	05 00 02 00 00       	add    $0x200,%eax
8010377a:	39 c2                	cmp    %eax,%edx
8010377c:	75 2a                	jne    801037a8 <pipewrite+0xb8>
      if(p->readopen == 0 || myproc()->killed){
8010377e:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
80103784:	85 c0                	test   %eax,%eax
80103786:	75 c0                	jne    80103748 <pipewrite+0x58>
        release(&p->lock);
80103788:	83 ec 0c             	sub    $0xc,%esp
8010378b:	53                   	push   %ebx
8010378c:	e8 0f 0f 00 00       	call   801046a0 <release>
        return -1;
80103791:	83 c4 10             	add    $0x10,%esp
80103794:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103799:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010379c:	5b                   	pop    %ebx
8010379d:	5e                   	pop    %esi
8010379e:	5f                   	pop    %edi
8010379f:	5d                   	pop    %ebp
801037a0:	c3                   	ret    
801037a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801037a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
801037ab:	8d 4a 01             	lea    0x1(%edx),%ecx
801037ae:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801037b4:	89 8b 38 02 00 00    	mov    %ecx,0x238(%ebx)
801037ba:	0f b6 06             	movzbl (%esi),%eax
  for(i = 0; i < n; i++){
801037bd:	83 c6 01             	add    $0x1,%esi
801037c0:	89 75 e4             	mov    %esi,-0x1c(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801037c3:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
801037c7:	3b 75 e0             	cmp    -0x20(%ebp),%esi
801037ca:	0f 85 58 ff ff ff    	jne    80103728 <pipewrite+0x38>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801037d0:	83 ec 0c             	sub    $0xc,%esp
801037d3:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801037d9:	50                   	push   %eax
801037da:	e8 81 0a 00 00       	call   80104260 <wakeup>
  release(&p->lock);
801037df:	89 1c 24             	mov    %ebx,(%esp)
801037e2:	e8 b9 0e 00 00       	call   801046a0 <release>
  return n;
801037e7:	8b 45 10             	mov    0x10(%ebp),%eax
801037ea:	83 c4 10             	add    $0x10,%esp
801037ed:	eb aa                	jmp    80103799 <pipewrite+0xa9>
801037ef:	90                   	nop

801037f0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801037f0:	55                   	push   %ebp
801037f1:	89 e5                	mov    %esp,%ebp
801037f3:	57                   	push   %edi
801037f4:	56                   	push   %esi
801037f5:	53                   	push   %ebx
801037f6:	83 ec 18             	sub    $0x18,%esp
801037f9:	8b 75 08             	mov    0x8(%ebp),%esi
801037fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
801037ff:	56                   	push   %esi
80103800:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
80103806:	e8 f5 0e 00 00       	call   80104700 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010380b:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103811:	83 c4 10             	add    $0x10,%esp
80103814:	39 86 38 02 00 00    	cmp    %eax,0x238(%esi)
8010381a:	74 2f                	je     8010384b <piperead+0x5b>
8010381c:	eb 37                	jmp    80103855 <piperead+0x65>
8010381e:	66 90                	xchg   %ax,%ax
    if(myproc()->killed){
80103820:	e8 ab 02 00 00       	call   80103ad0 <myproc>
80103825:	8b 48 24             	mov    0x24(%eax),%ecx
80103828:	85 c9                	test   %ecx,%ecx
8010382a:	0f 85 80 00 00 00    	jne    801038b0 <piperead+0xc0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103830:	83 ec 08             	sub    $0x8,%esp
80103833:	56                   	push   %esi
80103834:	53                   	push   %ebx
80103835:	e8 66 09 00 00       	call   801041a0 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010383a:	8b 86 38 02 00 00    	mov    0x238(%esi),%eax
80103840:	83 c4 10             	add    $0x10,%esp
80103843:	39 86 34 02 00 00    	cmp    %eax,0x234(%esi)
80103849:	75 0a                	jne    80103855 <piperead+0x65>
8010384b:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
80103851:	85 c0                	test   %eax,%eax
80103853:	75 cb                	jne    80103820 <piperead+0x30>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103855:	8b 55 10             	mov    0x10(%ebp),%edx
80103858:	31 db                	xor    %ebx,%ebx
8010385a:	85 d2                	test   %edx,%edx
8010385c:	7f 20                	jg     8010387e <piperead+0x8e>
8010385e:	eb 2c                	jmp    8010388c <piperead+0x9c>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103860:	8d 48 01             	lea    0x1(%eax),%ecx
80103863:	25 ff 01 00 00       	and    $0x1ff,%eax
80103868:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
8010386e:	0f b6 44 06 34       	movzbl 0x34(%esi,%eax,1),%eax
80103873:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103876:	83 c3 01             	add    $0x1,%ebx
80103879:	39 5d 10             	cmp    %ebx,0x10(%ebp)
8010387c:	74 0e                	je     8010388c <piperead+0x9c>
    if(p->nread == p->nwrite)
8010387e:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103884:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
8010388a:	75 d4                	jne    80103860 <piperead+0x70>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010388c:	83 ec 0c             	sub    $0xc,%esp
8010388f:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80103895:	50                   	push   %eax
80103896:	e8 c5 09 00 00       	call   80104260 <wakeup>
  release(&p->lock);
8010389b:	89 34 24             	mov    %esi,(%esp)
8010389e:	e8 fd 0d 00 00       	call   801046a0 <release>
  return i;
801038a3:	83 c4 10             	add    $0x10,%esp
}
801038a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801038a9:	89 d8                	mov    %ebx,%eax
801038ab:	5b                   	pop    %ebx
801038ac:	5e                   	pop    %esi
801038ad:	5f                   	pop    %edi
801038ae:	5d                   	pop    %ebp
801038af:	c3                   	ret    
      release(&p->lock);
801038b0:	83 ec 0c             	sub    $0xc,%esp
      return -1;
801038b3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
801038b8:	56                   	push   %esi
801038b9:	e8 e2 0d 00 00       	call   801046a0 <release>
      return -1;
801038be:	83 c4 10             	add    $0x10,%esp
}
801038c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801038c4:	89 d8                	mov    %ebx,%eax
801038c6:	5b                   	pop    %ebx
801038c7:	5e                   	pop    %esi
801038c8:	5f                   	pop    %edi
801038c9:	5d                   	pop    %ebp
801038ca:	c3                   	ret    
801038cb:	66 90                	xchg   %ax,%ax
801038cd:	66 90                	xchg   %ax,%ax
801038cf:	90                   	nop

801038d0 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801038d0:	55                   	push   %ebp
801038d1:	89 e5                	mov    %esp,%ebp
801038d3:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801038d4:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
{
801038d9:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
801038dc:	68 20 1d 11 80       	push   $0x80111d20
801038e1:	e8 1a 0e 00 00       	call   80104700 <acquire>
801038e6:	83 c4 10             	add    $0x10,%esp
801038e9:	eb 17                	jmp    80103902 <allocproc+0x32>
801038eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801038ef:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801038f0:	81 c3 88 00 00 00    	add    $0x88,%ebx
801038f6:	81 fb 54 3f 11 80    	cmp    $0x80113f54,%ebx
801038fc:	0f 84 96 00 00 00    	je     80103998 <allocproc+0xc8>
    if(p->state == UNUSED)
80103902:	8b 43 0c             	mov    0xc(%ebx),%eax
80103905:	85 c0                	test   %eax,%eax
80103907:	75 e7                	jne    801038f0 <allocproc+0x20>
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;  // mark as used
  p->pid = nextpid++; // give a unique pid
80103909:	a1 04 a0 10 80       	mov    0x8010a004,%eax

  release(&ptable.lock);
8010390e:	83 ec 0c             	sub    $0xc,%esp
  p->state = EMBRYO;  // mark as used
80103911:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++; // give a unique pid
80103918:	89 43 10             	mov    %eax,0x10(%ebx)
8010391b:	8d 50 01             	lea    0x1(%eax),%edx
  release(&ptable.lock);
8010391e:	68 20 1d 11 80       	push   $0x80111d20
  p->pid = nextpid++; // give a unique pid
80103923:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
  release(&ptable.lock);
80103929:	e8 72 0d 00 00       	call   801046a0 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){ // if alloc stack failed
8010392e:	e8 6d ee ff ff       	call   801027a0 <kalloc>
80103933:	83 c4 10             	add    $0x10,%esp
80103936:	89 43 08             	mov    %eax,0x8(%ebx)
80103939:	85 c0                	test   %eax,%eax
8010393b:	74 74                	je     801039b1 <allocproc+0xe1>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010393d:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
80103943:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
80103946:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
8010394b:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
8010394e:	c7 40 14 4f 5a 10 80 	movl   $0x80105a4f,0x14(%eax)
  p->context = (struct context*)sp;
80103955:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103958:	6a 14                	push   $0x14
8010395a:	6a 00                	push   $0x0
8010395c:	50                   	push   %eax
8010395d:	e8 5e 0e 00 00       	call   801047c0 <memset>
  p->context->eip = (uint)forkret;
80103962:	8b 43 1c             	mov    0x1c(%ebx),%eax
  // HW5
  p->alarmticks = 0;
  p->alarmticked = 0;
  p->alarmhandler = 0;
  
  return p;
80103965:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103968:	c7 40 10 d0 39 10 80 	movl   $0x801039d0,0x10(%eax)
}
8010396f:	89 d8                	mov    %ebx,%eax
  p->alarmticks = 0;
80103971:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
  p->alarmticked = 0;
80103978:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
8010397f:	00 00 00 
  p->alarmhandler = 0;
80103982:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
80103989:	00 00 00 
}
8010398c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010398f:	c9                   	leave  
80103990:	c3                   	ret    
80103991:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  release(&ptable.lock);
80103998:	83 ec 0c             	sub    $0xc,%esp
  return 0;
8010399b:	31 db                	xor    %ebx,%ebx
  release(&ptable.lock);
8010399d:	68 20 1d 11 80       	push   $0x80111d20
801039a2:	e8 f9 0c 00 00       	call   801046a0 <release>
}
801039a7:	89 d8                	mov    %ebx,%eax
  return 0;
801039a9:	83 c4 10             	add    $0x10,%esp
}
801039ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039af:	c9                   	leave  
801039b0:	c3                   	ret    
    p->state = UNUSED;
801039b1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801039b8:	31 db                	xor    %ebx,%ebx
}
801039ba:	89 d8                	mov    %ebx,%eax
801039bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039bf:	c9                   	leave  
801039c0:	c3                   	ret    
801039c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801039c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801039cf:	90                   	nop

801039d0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801039d0:	55                   	push   %ebp
801039d1:	89 e5                	mov    %esp,%ebp
801039d3:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801039d6:	68 20 1d 11 80       	push   $0x80111d20
801039db:	e8 c0 0c 00 00       	call   801046a0 <release>

  if (first) {
801039e0:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801039e5:	83 c4 10             	add    $0x10,%esp
801039e8:	85 c0                	test   %eax,%eax
801039ea:	75 04                	jne    801039f0 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
801039ec:	c9                   	leave  
801039ed:	c3                   	ret    
801039ee:	66 90                	xchg   %ax,%ax
    first = 0;
801039f0:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
801039f7:	00 00 00 
    iinit(ROOTDEV);
801039fa:	83 ec 0c             	sub    $0xc,%esp
801039fd:	6a 01                	push   $0x1
801039ff:	e8 7c dc ff ff       	call   80101680 <iinit>
    initlog(ROOTDEV);
80103a04:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103a0b:	e8 d0 f3 ff ff       	call   80102de0 <initlog>
}
80103a10:	83 c4 10             	add    $0x10,%esp
80103a13:	c9                   	leave  
80103a14:	c3                   	ret    
80103a15:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103a1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103a20 <pinit>:
{
80103a20:	55                   	push   %ebp
80103a21:	89 e5                	mov    %esp,%ebp
80103a23:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103a26:	68 40 79 10 80       	push   $0x80107940
80103a2b:	68 20 1d 11 80       	push   $0x80111d20
80103a30:	e8 fb 0a 00 00       	call   80104530 <initlock>
}
80103a35:	83 c4 10             	add    $0x10,%esp
80103a38:	c9                   	leave  
80103a39:	c3                   	ret    
80103a3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103a40 <mycpu>:
{
80103a40:	55                   	push   %ebp
80103a41:	89 e5                	mov    %esp,%ebp
80103a43:	56                   	push   %esi
80103a44:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103a45:	9c                   	pushf  
80103a46:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103a47:	f6 c4 02             	test   $0x2,%ah
80103a4a:	75 4e                	jne    80103a9a <mycpu+0x5a>
  apicid = lapicid();
80103a4c:	e8 bf ef ff ff       	call   80102a10 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103a51:	8b 35 84 17 11 80    	mov    0x80111784,%esi
  apicid = lapicid();
80103a57:	89 c3                	mov    %eax,%ebx
  for (i = 0; i < ncpu; ++i) {
80103a59:	85 f6                	test   %esi,%esi
80103a5b:	7e 30                	jle    80103a8d <mycpu+0x4d>
80103a5d:	31 c0                	xor    %eax,%eax
80103a5f:	eb 0e                	jmp    80103a6f <mycpu+0x2f>
80103a61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103a68:	83 c0 01             	add    $0x1,%eax
80103a6b:	39 f0                	cmp    %esi,%eax
80103a6d:	74 1e                	je     80103a8d <mycpu+0x4d>
    if (cpus[i].apicid == apicid)
80103a6f:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
80103a75:	0f b6 8a a0 17 11 80 	movzbl -0x7feee860(%edx),%ecx
80103a7c:	39 d9                	cmp    %ebx,%ecx
80103a7e:	75 e8                	jne    80103a68 <mycpu+0x28>
}
80103a80:	8d 65 f8             	lea    -0x8(%ebp),%esp
      return &cpus[i];
80103a83:	8d 82 a0 17 11 80    	lea    -0x7feee860(%edx),%eax
}
80103a89:	5b                   	pop    %ebx
80103a8a:	5e                   	pop    %esi
80103a8b:	5d                   	pop    %ebp
80103a8c:	c3                   	ret    
  panic("unknown apicid\n");
80103a8d:	83 ec 0c             	sub    $0xc,%esp
80103a90:	68 47 79 10 80       	push   $0x80107947
80103a95:	e8 e6 c8 ff ff       	call   80100380 <panic>
    panic("mycpu called with interrupts enabled\n");
80103a9a:	83 ec 0c             	sub    $0xc,%esp
80103a9d:	68 24 7a 10 80       	push   $0x80107a24
80103aa2:	e8 d9 c8 ff ff       	call   80100380 <panic>
80103aa7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103aae:	66 90                	xchg   %ax,%ax

80103ab0 <cpuid>:
cpuid() {
80103ab0:	55                   	push   %ebp
80103ab1:	89 e5                	mov    %esp,%ebp
80103ab3:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103ab6:	e8 85 ff ff ff       	call   80103a40 <mycpu>
}
80103abb:	c9                   	leave  
  return mycpu()-cpus;
80103abc:	2d a0 17 11 80       	sub    $0x801117a0,%eax
80103ac1:	c1 f8 04             	sar    $0x4,%eax
80103ac4:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103aca:	c3                   	ret    
80103acb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103acf:	90                   	nop

80103ad0 <myproc>:
myproc(void) {
80103ad0:	55                   	push   %ebp
80103ad1:	89 e5                	mov    %esp,%ebp
80103ad3:	53                   	push   %ebx
80103ad4:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103ad7:	e8 d4 0a 00 00       	call   801045b0 <pushcli>
  c = mycpu();
80103adc:	e8 5f ff ff ff       	call   80103a40 <mycpu>
  p = c->proc;
80103ae1:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103ae7:	e8 14 0b 00 00       	call   80104600 <popcli>
}
80103aec:	89 d8                	mov    %ebx,%eax
80103aee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103af1:	c9                   	leave  
80103af2:	c3                   	ret    
80103af3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103afa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103b00 <userinit>:
{
80103b00:	55                   	push   %ebp
80103b01:	89 e5                	mov    %esp,%ebp
80103b03:	53                   	push   %ebx
80103b04:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();  // alloc a slot(struct proc), init parts of process's state
80103b07:	e8 c4 fd ff ff       	call   801038d0 <allocproc>
80103b0c:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103b0e:	a3 54 3f 11 80       	mov    %eax,0x80113f54
  if((p->pgdir = setupkvm()) == 0)    // 建一个（最初）只映射内核区的页表
80103b13:	e8 88 35 00 00       	call   801070a0 <setupkvm>
80103b18:	89 43 04             	mov    %eax,0x4(%ebx)
80103b1b:	85 c0                	test   %eax,%eax
80103b1d:	0f 84 bd 00 00 00    	je     80103be0 <userinit+0xe0>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);  // 分配一页物理内存，将虚拟地址0映射到那一段内存，并把二进制码拷贝到那一页中
80103b23:	83 ec 04             	sub    $0x4,%esp
80103b26:	68 2c 00 00 00       	push   $0x2c
80103b2b:	68 60 a4 10 80       	push   $0x8010a460
80103b30:	50                   	push   %eax
80103b31:	e8 1a 32 00 00       	call   80106d50 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
80103b36:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
80103b39:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103b3f:	6a 4c                	push   $0x4c
80103b41:	6a 00                	push   $0x0
80103b43:	ff 73 18             	push   0x18(%ebx)
80103b46:	e8 75 0c 00 00       	call   801047c0 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103b4b:	8b 43 18             	mov    0x18(%ebx),%eax
80103b4e:	ba 1b 00 00 00       	mov    $0x1b,%edx
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103b53:	83 c4 0c             	add    $0xc,%esp
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103b56:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103b5b:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103b5f:	8b 43 18             	mov    0x18(%ebx),%eax
80103b62:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103b66:	8b 43 18             	mov    0x18(%ebx),%eax
80103b69:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103b6d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103b71:	8b 43 18             	mov    0x18(%ebx),%eax
80103b74:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103b78:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103b7c:	8b 43 18             	mov    0x18(%ebx),%eax
80103b7f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103b86:	8b 43 18             	mov    0x18(%ebx),%eax
80103b89:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103b90:	8b 43 18             	mov    0x18(%ebx),%eax
80103b93:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103b9a:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103b9d:	6a 10                	push   $0x10
80103b9f:	68 70 79 10 80       	push   $0x80107970
80103ba4:	50                   	push   %eax
80103ba5:	e8 d6 0d 00 00       	call   80104980 <safestrcpy>
  p->cwd = namei("/");
80103baa:	c7 04 24 79 79 10 80 	movl   $0x80107979,(%esp)
80103bb1:	e8 0a e6 ff ff       	call   801021c0 <namei>
80103bb6:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103bb9:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103bc0:	e8 3b 0b 00 00       	call   80104700 <acquire>
  p->state = RUNNABLE;    // 使进程能够被调度
80103bc5:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103bcc:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103bd3:	e8 c8 0a 00 00       	call   801046a0 <release>
}
80103bd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103bdb:	83 c4 10             	add    $0x10,%esp
80103bde:	c9                   	leave  
80103bdf:	c3                   	ret    
    panic("userinit: out of memory?");
80103be0:	83 ec 0c             	sub    $0xc,%esp
80103be3:	68 57 79 10 80       	push   $0x80107957
80103be8:	e8 93 c7 ff ff       	call   80100380 <panic>
80103bed:	8d 76 00             	lea    0x0(%esi),%esi

80103bf0 <growproc>:
{
80103bf0:	55                   	push   %ebp
80103bf1:	89 e5                	mov    %esp,%ebp
80103bf3:	56                   	push   %esi
80103bf4:	53                   	push   %ebx
80103bf5:	8b 75 08             	mov    0x8(%ebp),%esi
  pushcli();
80103bf8:	e8 b3 09 00 00       	call   801045b0 <pushcli>
  c = mycpu();
80103bfd:	e8 3e fe ff ff       	call   80103a40 <mycpu>
  p = c->proc;
80103c02:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103c08:	e8 f3 09 00 00       	call   80104600 <popcli>
  sz = curproc->sz;
80103c0d:	8b 03                	mov    (%ebx),%eax
  if(n > 0){
80103c0f:	85 f6                	test   %esi,%esi
80103c11:	7f 1d                	jg     80103c30 <growproc+0x40>
  } else if(n < 0){
80103c13:	75 3b                	jne    80103c50 <growproc+0x60>
  switchuvm(curproc);
80103c15:	83 ec 0c             	sub    $0xc,%esp
  curproc->sz = sz;
80103c18:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103c1a:	53                   	push   %ebx
80103c1b:	e8 20 30 00 00       	call   80106c40 <switchuvm>
  return 0;
80103c20:	83 c4 10             	add    $0x10,%esp
80103c23:	31 c0                	xor    %eax,%eax
}
80103c25:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c28:	5b                   	pop    %ebx
80103c29:	5e                   	pop    %esi
80103c2a:	5d                   	pop    %ebp
80103c2b:	c3                   	ret    
80103c2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103c30:	83 ec 04             	sub    $0x4,%esp
80103c33:	01 c6                	add    %eax,%esi
80103c35:	56                   	push   %esi
80103c36:	50                   	push   %eax
80103c37:	ff 73 04             	push   0x4(%ebx)
80103c3a:	e8 81 32 00 00       	call   80106ec0 <allocuvm>
80103c3f:	83 c4 10             	add    $0x10,%esp
80103c42:	85 c0                	test   %eax,%eax
80103c44:	75 cf                	jne    80103c15 <growproc+0x25>
      return -1;
80103c46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103c4b:	eb d8                	jmp    80103c25 <growproc+0x35>
80103c4d:	8d 76 00             	lea    0x0(%esi),%esi
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103c50:	83 ec 04             	sub    $0x4,%esp
80103c53:	01 c6                	add    %eax,%esi
80103c55:	56                   	push   %esi
80103c56:	50                   	push   %eax
80103c57:	ff 73 04             	push   0x4(%ebx)
80103c5a:	e8 91 33 00 00       	call   80106ff0 <deallocuvm>
80103c5f:	83 c4 10             	add    $0x10,%esp
80103c62:	85 c0                	test   %eax,%eax
80103c64:	75 af                	jne    80103c15 <growproc+0x25>
80103c66:	eb de                	jmp    80103c46 <growproc+0x56>
80103c68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103c6f:	90                   	nop

80103c70 <fork>:
{
80103c70:	55                   	push   %ebp
80103c71:	89 e5                	mov    %esp,%ebp
80103c73:	57                   	push   %edi
80103c74:	56                   	push   %esi
80103c75:	53                   	push   %ebx
80103c76:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
80103c79:	e8 32 09 00 00       	call   801045b0 <pushcli>
  c = mycpu();
80103c7e:	e8 bd fd ff ff       	call   80103a40 <mycpu>
  p = c->proc;
80103c83:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103c89:	e8 72 09 00 00       	call   80104600 <popcli>
  if((np = allocproc()) == 0){
80103c8e:	e8 3d fc ff ff       	call   801038d0 <allocproc>
80103c93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103c96:	85 c0                	test   %eax,%eax
80103c98:	0f 84 b7 00 00 00    	je     80103d55 <fork+0xe5>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103c9e:	83 ec 08             	sub    $0x8,%esp
80103ca1:	ff 33                	push   (%ebx)
80103ca3:	89 c7                	mov    %eax,%edi
80103ca5:	ff 73 04             	push   0x4(%ebx)
80103ca8:	e8 e3 34 00 00       	call   80107190 <copyuvm>
80103cad:	83 c4 10             	add    $0x10,%esp
80103cb0:	89 47 04             	mov    %eax,0x4(%edi)
80103cb3:	85 c0                	test   %eax,%eax
80103cb5:	0f 84 a1 00 00 00    	je     80103d5c <fork+0xec>
  np->sz = curproc->sz;
80103cbb:	8b 03                	mov    (%ebx),%eax
80103cbd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103cc0:	89 01                	mov    %eax,(%ecx)
  *np->tf = *curproc->tf;
80103cc2:	8b 79 18             	mov    0x18(%ecx),%edi
  np->parent = curproc;
80103cc5:	89 c8                	mov    %ecx,%eax
80103cc7:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103cca:	b9 13 00 00 00       	mov    $0x13,%ecx
80103ccf:	8b 73 18             	mov    0x18(%ebx),%esi
80103cd2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103cd4:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103cd6:	8b 40 18             	mov    0x18(%eax),%eax
80103cd9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    if(curproc->ofile[i])
80103ce0:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103ce4:	85 c0                	test   %eax,%eax
80103ce6:	74 13                	je     80103cfb <fork+0x8b>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103ce8:	83 ec 0c             	sub    $0xc,%esp
80103ceb:	50                   	push   %eax
80103cec:	e8 cf d2 ff ff       	call   80100fc0 <filedup>
80103cf1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103cf4:	83 c4 10             	add    $0x10,%esp
80103cf7:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
  for(i = 0; i < NOFILE; i++)
80103cfb:	83 c6 01             	add    $0x1,%esi
80103cfe:	83 fe 10             	cmp    $0x10,%esi
80103d01:	75 dd                	jne    80103ce0 <fork+0x70>
  np->cwd = idup(curproc->cwd);
80103d03:	83 ec 0c             	sub    $0xc,%esp
80103d06:	ff 73 68             	push   0x68(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103d09:	83 c3 6c             	add    $0x6c,%ebx
  np->cwd = idup(curproc->cwd);
80103d0c:	e8 5f db ff ff       	call   80101870 <idup>
80103d11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103d14:	83 c4 0c             	add    $0xc,%esp
  np->cwd = idup(curproc->cwd);
80103d17:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103d1a:	8d 47 6c             	lea    0x6c(%edi),%eax
80103d1d:	6a 10                	push   $0x10
80103d1f:	53                   	push   %ebx
80103d20:	50                   	push   %eax
80103d21:	e8 5a 0c 00 00       	call   80104980 <safestrcpy>
  pid = np->pid;
80103d26:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
80103d29:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103d30:	e8 cb 09 00 00       	call   80104700 <acquire>
  np->state = RUNNABLE;
80103d35:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103d3c:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103d43:	e8 58 09 00 00       	call   801046a0 <release>
  return pid;
80103d48:	83 c4 10             	add    $0x10,%esp
}
80103d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103d4e:	89 d8                	mov    %ebx,%eax
80103d50:	5b                   	pop    %ebx
80103d51:	5e                   	pop    %esi
80103d52:	5f                   	pop    %edi
80103d53:	5d                   	pop    %ebp
80103d54:	c3                   	ret    
    return -1;
80103d55:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103d5a:	eb ef                	jmp    80103d4b <fork+0xdb>
    kfree(np->kstack);
80103d5c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103d5f:	83 ec 0c             	sub    $0xc,%esp
80103d62:	ff 73 08             	push   0x8(%ebx)
80103d65:	e8 76 e8 ff ff       	call   801025e0 <kfree>
    np->kstack = 0;
80103d6a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    return -1;
80103d71:	83 c4 10             	add    $0x10,%esp
    np->state = UNUSED;
80103d74:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103d7b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103d80:	eb c9                	jmp    80103d4b <fork+0xdb>
80103d82:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103d90 <scheduler>:
{
80103d90:	55                   	push   %ebp
80103d91:	89 e5                	mov    %esp,%ebp
80103d93:	57                   	push   %edi
80103d94:	56                   	push   %esi
80103d95:	53                   	push   %ebx
80103d96:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
80103d99:	e8 a2 fc ff ff       	call   80103a40 <mycpu>
  c->proc = 0;
80103d9e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103da5:	00 00 00 
  struct cpu *c = mycpu();
80103da8:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103daa:	8d 78 04             	lea    0x4(%eax),%edi
80103dad:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("sti");
80103db0:	fb                   	sti    
    acquire(&ptable.lock);
80103db1:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103db4:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
    acquire(&ptable.lock);
80103db9:	68 20 1d 11 80       	push   $0x80111d20
80103dbe:	e8 3d 09 00 00       	call   80104700 <acquire>
80103dc3:	83 c4 10             	add    $0x10,%esp
80103dc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103dcd:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->state != RUNNABLE)
80103dd0:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103dd4:	75 33                	jne    80103e09 <scheduler+0x79>
      switchuvm(p);       // 通知硬件开始使用目标进程的页表
80103dd6:	83 ec 0c             	sub    $0xc,%esp
      c->proc = p;
80103dd9:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);       // 通知硬件开始使用目标进程的页表
80103ddf:	53                   	push   %ebx
80103de0:	e8 5b 2e 00 00       	call   80106c40 <switchuvm>
      swtch(&(c->scheduler), p->context); // 切换上下文到目标进程的内核线程中。
80103de5:	58                   	pop    %eax
80103de6:	5a                   	pop    %edx
80103de7:	ff 73 1c             	push   0x1c(%ebx)
80103dea:	57                   	push   %edi
      p->state = RUNNING;
80103deb:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context); // 切换上下文到目标进程的内核线程中。
80103df2:	e8 e4 0b 00 00       	call   801049db <swtch>
      switchkvm();    // 切换内核虚拟映射
80103df7:	e8 34 2e 00 00       	call   80106c30 <switchkvm>
      c->proc = 0;
80103dfc:	83 c4 10             	add    $0x10,%esp
80103dff:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103e06:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103e09:	81 c3 88 00 00 00    	add    $0x88,%ebx
80103e0f:	81 fb 54 3f 11 80    	cmp    $0x80113f54,%ebx
80103e15:	75 b9                	jne    80103dd0 <scheduler+0x40>
    release(&ptable.lock);
80103e17:	83 ec 0c             	sub    $0xc,%esp
80103e1a:	68 20 1d 11 80       	push   $0x80111d20
80103e1f:	e8 7c 08 00 00       	call   801046a0 <release>
    sti();
80103e24:	83 c4 10             	add    $0x10,%esp
80103e27:	eb 87                	jmp    80103db0 <scheduler+0x20>
80103e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103e30 <sched>:
{
80103e30:	55                   	push   %ebp
80103e31:	89 e5                	mov    %esp,%ebp
80103e33:	56                   	push   %esi
80103e34:	53                   	push   %ebx
  pushcli();
80103e35:	e8 76 07 00 00       	call   801045b0 <pushcli>
  c = mycpu();
80103e3a:	e8 01 fc ff ff       	call   80103a40 <mycpu>
  p = c->proc;
80103e3f:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103e45:	e8 b6 07 00 00       	call   80104600 <popcli>
  if(!holding(&ptable.lock))
80103e4a:	83 ec 0c             	sub    $0xc,%esp
80103e4d:	68 20 1d 11 80       	push   $0x80111d20
80103e52:	e8 09 08 00 00       	call   80104660 <holding>
80103e57:	83 c4 10             	add    $0x10,%esp
80103e5a:	85 c0                	test   %eax,%eax
80103e5c:	74 4f                	je     80103ead <sched+0x7d>
  if(mycpu()->ncli != 1)
80103e5e:	e8 dd fb ff ff       	call   80103a40 <mycpu>
80103e63:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103e6a:	75 68                	jne    80103ed4 <sched+0xa4>
  if(p->state == RUNNING)
80103e6c:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103e70:	74 55                	je     80103ec7 <sched+0x97>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103e72:	9c                   	pushf  
80103e73:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103e74:	f6 c4 02             	test   $0x2,%ah
80103e77:	75 41                	jne    80103eba <sched+0x8a>
  intena = mycpu()->intena;
80103e79:	e8 c2 fb ff ff       	call   80103a40 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
80103e7e:	83 c3 1c             	add    $0x1c,%ebx
  intena = mycpu()->intena;
80103e81:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103e87:	e8 b4 fb ff ff       	call   80103a40 <mycpu>
80103e8c:	83 ec 08             	sub    $0x8,%esp
80103e8f:	ff 70 04             	push   0x4(%eax)
80103e92:	53                   	push   %ebx
80103e93:	e8 43 0b 00 00       	call   801049db <swtch>
  mycpu()->intena = intena;
80103e98:	e8 a3 fb ff ff       	call   80103a40 <mycpu>
}
80103e9d:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80103ea0:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103ea6:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ea9:	5b                   	pop    %ebx
80103eaa:	5e                   	pop    %esi
80103eab:	5d                   	pop    %ebp
80103eac:	c3                   	ret    
    panic("sched ptable.lock");
80103ead:	83 ec 0c             	sub    $0xc,%esp
80103eb0:	68 7b 79 10 80       	push   $0x8010797b
80103eb5:	e8 c6 c4 ff ff       	call   80100380 <panic>
    panic("sched interruptible");
80103eba:	83 ec 0c             	sub    $0xc,%esp
80103ebd:	68 a7 79 10 80       	push   $0x801079a7
80103ec2:	e8 b9 c4 ff ff       	call   80100380 <panic>
    panic("sched running");
80103ec7:	83 ec 0c             	sub    $0xc,%esp
80103eca:	68 99 79 10 80       	push   $0x80107999
80103ecf:	e8 ac c4 ff ff       	call   80100380 <panic>
    panic("sched locks");
80103ed4:	83 ec 0c             	sub    $0xc,%esp
80103ed7:	68 8d 79 10 80       	push   $0x8010798d
80103edc:	e8 9f c4 ff ff       	call   80100380 <panic>
80103ee1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103ee8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103eef:	90                   	nop

80103ef0 <exit>:
{
80103ef0:	55                   	push   %ebp
80103ef1:	89 e5                	mov    %esp,%ebp
80103ef3:	57                   	push   %edi
80103ef4:	56                   	push   %esi
80103ef5:	53                   	push   %ebx
80103ef6:	83 ec 0c             	sub    $0xc,%esp
  struct proc *curproc = myproc();
80103ef9:	e8 d2 fb ff ff       	call   80103ad0 <myproc>
  if(curproc == initproc)
80103efe:	39 05 54 3f 11 80    	cmp    %eax,0x80113f54
80103f04:	0f 84 07 01 00 00    	je     80104011 <exit+0x121>
80103f0a:	89 c3                	mov    %eax,%ebx
80103f0c:	8d 70 28             	lea    0x28(%eax),%esi
80103f0f:	8d 78 68             	lea    0x68(%eax),%edi
80103f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(curproc->ofile[fd]){
80103f18:	8b 06                	mov    (%esi),%eax
80103f1a:	85 c0                	test   %eax,%eax
80103f1c:	74 12                	je     80103f30 <exit+0x40>
      fileclose(curproc->ofile[fd]);
80103f1e:	83 ec 0c             	sub    $0xc,%esp
80103f21:	50                   	push   %eax
80103f22:	e8 e9 d0 ff ff       	call   80101010 <fileclose>
      curproc->ofile[fd] = 0;
80103f27:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80103f2d:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80103f30:	83 c6 04             	add    $0x4,%esi
80103f33:	39 f7                	cmp    %esi,%edi
80103f35:	75 e1                	jne    80103f18 <exit+0x28>
  begin_op();
80103f37:	e8 44 ef ff ff       	call   80102e80 <begin_op>
  iput(curproc->cwd);
80103f3c:	83 ec 0c             	sub    $0xc,%esp
80103f3f:	ff 73 68             	push   0x68(%ebx)
80103f42:	e8 89 da ff ff       	call   801019d0 <iput>
  end_op();
80103f47:	e8 a4 ef ff ff       	call   80102ef0 <end_op>
  curproc->cwd = 0;
80103f4c:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)
  acquire(&ptable.lock);
80103f53:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103f5a:	e8 a1 07 00 00       	call   80104700 <acquire>
  wakeup1(curproc->parent);
80103f5f:	8b 53 14             	mov    0x14(%ebx),%edx
80103f62:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f65:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
80103f6a:	eb 10                	jmp    80103f7c <exit+0x8c>
80103f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103f70:	05 88 00 00 00       	add    $0x88,%eax
80103f75:	3d 54 3f 11 80       	cmp    $0x80113f54,%eax
80103f7a:	74 1e                	je     80103f9a <exit+0xaa>
    if(p->state == SLEEPING && p->chan == chan)
80103f7c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103f80:	75 ee                	jne    80103f70 <exit+0x80>
80103f82:	3b 50 20             	cmp    0x20(%eax),%edx
80103f85:	75 e9                	jne    80103f70 <exit+0x80>
      p->state = RUNNABLE;
80103f87:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f8e:	05 88 00 00 00       	add    $0x88,%eax
80103f93:	3d 54 3f 11 80       	cmp    $0x80113f54,%eax
80103f98:	75 e2                	jne    80103f7c <exit+0x8c>
      p->parent = initproc;
80103f9a:	8b 0d 54 3f 11 80    	mov    0x80113f54,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fa0:	ba 54 1d 11 80       	mov    $0x80111d54,%edx
80103fa5:	eb 17                	jmp    80103fbe <exit+0xce>
80103fa7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103fae:	66 90                	xchg   %ax,%ax
80103fb0:	81 c2 88 00 00 00    	add    $0x88,%edx
80103fb6:	81 fa 54 3f 11 80    	cmp    $0x80113f54,%edx
80103fbc:	74 3a                	je     80103ff8 <exit+0x108>
    if(p->parent == curproc){
80103fbe:	39 5a 14             	cmp    %ebx,0x14(%edx)
80103fc1:	75 ed                	jne    80103fb0 <exit+0xc0>
      if(p->state == ZOMBIE)
80103fc3:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
      p->parent = initproc;
80103fc7:	89 4a 14             	mov    %ecx,0x14(%edx)
      if(p->state == ZOMBIE)
80103fca:	75 e4                	jne    80103fb0 <exit+0xc0>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103fcc:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
80103fd1:	eb 11                	jmp    80103fe4 <exit+0xf4>
80103fd3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103fd7:	90                   	nop
80103fd8:	05 88 00 00 00       	add    $0x88,%eax
80103fdd:	3d 54 3f 11 80       	cmp    $0x80113f54,%eax
80103fe2:	74 cc                	je     80103fb0 <exit+0xc0>
    if(p->state == SLEEPING && p->chan == chan)
80103fe4:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103fe8:	75 ee                	jne    80103fd8 <exit+0xe8>
80103fea:	3b 48 20             	cmp    0x20(%eax),%ecx
80103fed:	75 e9                	jne    80103fd8 <exit+0xe8>
      p->state = RUNNABLE;
80103fef:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103ff6:	eb e0                	jmp    80103fd8 <exit+0xe8>
  curproc->state = ZOMBIE;
80103ff8:	c7 43 0c 05 00 00 00 	movl   $0x5,0xc(%ebx)
  sched();
80103fff:	e8 2c fe ff ff       	call   80103e30 <sched>
  panic("zombie exit");
80104004:	83 ec 0c             	sub    $0xc,%esp
80104007:	68 c8 79 10 80       	push   $0x801079c8
8010400c:	e8 6f c3 ff ff       	call   80100380 <panic>
    panic("init exiting");
80104011:	83 ec 0c             	sub    $0xc,%esp
80104014:	68 bb 79 10 80       	push   $0x801079bb
80104019:	e8 62 c3 ff ff       	call   80100380 <panic>
8010401e:	66 90                	xchg   %ax,%ax

80104020 <wait>:
{
80104020:	55                   	push   %ebp
80104021:	89 e5                	mov    %esp,%ebp
80104023:	56                   	push   %esi
80104024:	53                   	push   %ebx
  pushcli();
80104025:	e8 86 05 00 00       	call   801045b0 <pushcli>
  c = mycpu();
8010402a:	e8 11 fa ff ff       	call   80103a40 <mycpu>
  p = c->proc;
8010402f:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80104035:	e8 c6 05 00 00       	call   80104600 <popcli>
  acquire(&ptable.lock);
8010403a:	83 ec 0c             	sub    $0xc,%esp
8010403d:	68 20 1d 11 80       	push   $0x80111d20
80104042:	e8 b9 06 00 00       	call   80104700 <acquire>
80104047:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010404a:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010404c:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80104051:	eb 13                	jmp    80104066 <wait+0x46>
80104053:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104057:	90                   	nop
80104058:	81 c3 88 00 00 00    	add    $0x88,%ebx
8010405e:	81 fb 54 3f 11 80    	cmp    $0x80113f54,%ebx
80104064:	74 1e                	je     80104084 <wait+0x64>
      if(p->parent != curproc)
80104066:	39 73 14             	cmp    %esi,0x14(%ebx)
80104069:	75 ed                	jne    80104058 <wait+0x38>
      if(p->state == ZOMBIE){
8010406b:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010406f:	74 5f                	je     801040d0 <wait+0xb0>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104071:	81 c3 88 00 00 00    	add    $0x88,%ebx
      havekids = 1;
80104077:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010407c:	81 fb 54 3f 11 80    	cmp    $0x80113f54,%ebx
80104082:	75 e2                	jne    80104066 <wait+0x46>
    if(!havekids || curproc->killed){
80104084:	85 c0                	test   %eax,%eax
80104086:	0f 84 9a 00 00 00    	je     80104126 <wait+0x106>
8010408c:	8b 46 24             	mov    0x24(%esi),%eax
8010408f:	85 c0                	test   %eax,%eax
80104091:	0f 85 8f 00 00 00    	jne    80104126 <wait+0x106>
  pushcli();
80104097:	e8 14 05 00 00       	call   801045b0 <pushcli>
  c = mycpu();
8010409c:	e8 9f f9 ff ff       	call   80103a40 <mycpu>
  p = c->proc;
801040a1:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801040a7:	e8 54 05 00 00       	call   80104600 <popcli>
  if(p == 0)
801040ac:	85 db                	test   %ebx,%ebx
801040ae:	0f 84 89 00 00 00    	je     8010413d <wait+0x11d>
  p->chan = chan;
801040b4:	89 73 20             	mov    %esi,0x20(%ebx)
  p->state = SLEEPING;
801040b7:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
801040be:	e8 6d fd ff ff       	call   80103e30 <sched>
  p->chan = 0;
801040c3:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
801040ca:	e9 7b ff ff ff       	jmp    8010404a <wait+0x2a>
801040cf:	90                   	nop
        kfree(p->kstack);
801040d0:	83 ec 0c             	sub    $0xc,%esp
        pid = p->pid;
801040d3:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801040d6:	ff 73 08             	push   0x8(%ebx)
801040d9:	e8 02 e5 ff ff       	call   801025e0 <kfree>
        p->kstack = 0;
801040de:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801040e5:	5a                   	pop    %edx
801040e6:	ff 73 04             	push   0x4(%ebx)
801040e9:	e8 32 2f 00 00       	call   80107020 <freevm>
        p->pid = 0;
801040ee:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801040f5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801040fc:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80104100:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80104107:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
8010410e:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80104115:	e8 86 05 00 00       	call   801046a0 <release>
        return pid;
8010411a:	83 c4 10             	add    $0x10,%esp
}
8010411d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104120:	89 f0                	mov    %esi,%eax
80104122:	5b                   	pop    %ebx
80104123:	5e                   	pop    %esi
80104124:	5d                   	pop    %ebp
80104125:	c3                   	ret    
      release(&ptable.lock);
80104126:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80104129:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
8010412e:	68 20 1d 11 80       	push   $0x80111d20
80104133:	e8 68 05 00 00       	call   801046a0 <release>
      return -1;
80104138:	83 c4 10             	add    $0x10,%esp
8010413b:	eb e0                	jmp    8010411d <wait+0xfd>
    panic("sleep");
8010413d:	83 ec 0c             	sub    $0xc,%esp
80104140:	68 d4 79 10 80       	push   $0x801079d4
80104145:	e8 36 c2 ff ff       	call   80100380 <panic>
8010414a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104150 <yield>:
{
80104150:	55                   	push   %ebp
80104151:	89 e5                	mov    %esp,%ebp
80104153:	53                   	push   %ebx
80104154:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104157:	68 20 1d 11 80       	push   $0x80111d20
8010415c:	e8 9f 05 00 00       	call   80104700 <acquire>
  pushcli();
80104161:	e8 4a 04 00 00       	call   801045b0 <pushcli>
  c = mycpu();
80104166:	e8 d5 f8 ff ff       	call   80103a40 <mycpu>
  p = c->proc;
8010416b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104171:	e8 8a 04 00 00       	call   80104600 <popcli>
  myproc()->state = RUNNABLE;
80104176:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  sched();
8010417d:	e8 ae fc ff ff       	call   80103e30 <sched>
  release(&ptable.lock);
80104182:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80104189:	e8 12 05 00 00       	call   801046a0 <release>
}
8010418e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104191:	83 c4 10             	add    $0x10,%esp
80104194:	c9                   	leave  
80104195:	c3                   	ret    
80104196:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010419d:	8d 76 00             	lea    0x0(%esi),%esi

801041a0 <sleep>:
{
801041a0:	55                   	push   %ebp
801041a1:	89 e5                	mov    %esp,%ebp
801041a3:	57                   	push   %edi
801041a4:	56                   	push   %esi
801041a5:	53                   	push   %ebx
801041a6:	83 ec 0c             	sub    $0xc,%esp
801041a9:	8b 7d 08             	mov    0x8(%ebp),%edi
801041ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
801041af:	e8 fc 03 00 00       	call   801045b0 <pushcli>
  c = mycpu();
801041b4:	e8 87 f8 ff ff       	call   80103a40 <mycpu>
  p = c->proc;
801041b9:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801041bf:	e8 3c 04 00 00       	call   80104600 <popcli>
  if(p == 0)
801041c4:	85 db                	test   %ebx,%ebx
801041c6:	0f 84 87 00 00 00    	je     80104253 <sleep+0xb3>
  if(lk == 0)
801041cc:	85 f6                	test   %esi,%esi
801041ce:	74 76                	je     80104246 <sleep+0xa6>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801041d0:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
801041d6:	74 50                	je     80104228 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
801041d8:	83 ec 0c             	sub    $0xc,%esp
801041db:	68 20 1d 11 80       	push   $0x80111d20
801041e0:	e8 1b 05 00 00       	call   80104700 <acquire>
    release(lk);
801041e5:	89 34 24             	mov    %esi,(%esp)
801041e8:	e8 b3 04 00 00       	call   801046a0 <release>
  p->chan = chan;
801041ed:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
801041f0:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
801041f7:	e8 34 fc ff ff       	call   80103e30 <sched>
  p->chan = 0;
801041fc:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
    release(&ptable.lock);
80104203:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010420a:	e8 91 04 00 00       	call   801046a0 <release>
    acquire(lk);
8010420f:	89 75 08             	mov    %esi,0x8(%ebp)
80104212:	83 c4 10             	add    $0x10,%esp
}
80104215:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104218:	5b                   	pop    %ebx
80104219:	5e                   	pop    %esi
8010421a:	5f                   	pop    %edi
8010421b:	5d                   	pop    %ebp
    acquire(lk);
8010421c:	e9 df 04 00 00       	jmp    80104700 <acquire>
80104221:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  p->chan = chan;
80104228:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
8010422b:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80104232:	e8 f9 fb ff ff       	call   80103e30 <sched>
  p->chan = 0;
80104237:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
8010423e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104241:	5b                   	pop    %ebx
80104242:	5e                   	pop    %esi
80104243:	5f                   	pop    %edi
80104244:	5d                   	pop    %ebp
80104245:	c3                   	ret    
    panic("sleep without lk");
80104246:	83 ec 0c             	sub    $0xc,%esp
80104249:	68 da 79 10 80       	push   $0x801079da
8010424e:	e8 2d c1 ff ff       	call   80100380 <panic>
    panic("sleep");
80104253:	83 ec 0c             	sub    $0xc,%esp
80104256:	68 d4 79 10 80       	push   $0x801079d4
8010425b:	e8 20 c1 ff ff       	call   80100380 <panic>

80104260 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104260:	55                   	push   %ebp
80104261:	89 e5                	mov    %esp,%ebp
80104263:	53                   	push   %ebx
80104264:	83 ec 10             	sub    $0x10,%esp
80104267:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010426a:	68 20 1d 11 80       	push   $0x80111d20
8010426f:	e8 8c 04 00 00       	call   80104700 <acquire>
80104274:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104277:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
8010427c:	eb 0e                	jmp    8010428c <wakeup+0x2c>
8010427e:	66 90                	xchg   %ax,%ax
80104280:	05 88 00 00 00       	add    $0x88,%eax
80104285:	3d 54 3f 11 80       	cmp    $0x80113f54,%eax
8010428a:	74 1e                	je     801042aa <wakeup+0x4a>
    if(p->state == SLEEPING && p->chan == chan)
8010428c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104290:	75 ee                	jne    80104280 <wakeup+0x20>
80104292:	3b 58 20             	cmp    0x20(%eax),%ebx
80104295:	75 e9                	jne    80104280 <wakeup+0x20>
      p->state = RUNNABLE;
80104297:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010429e:	05 88 00 00 00       	add    $0x88,%eax
801042a3:	3d 54 3f 11 80       	cmp    $0x80113f54,%eax
801042a8:	75 e2                	jne    8010428c <wakeup+0x2c>
  wakeup1(chan);
  release(&ptable.lock);
801042aa:	c7 45 08 20 1d 11 80 	movl   $0x80111d20,0x8(%ebp)
}
801042b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042b4:	c9                   	leave  
  release(&ptable.lock);
801042b5:	e9 e6 03 00 00       	jmp    801046a0 <release>
801042ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801042c0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801042c0:	55                   	push   %ebp
801042c1:	89 e5                	mov    %esp,%ebp
801042c3:	53                   	push   %ebx
801042c4:	83 ec 10             	sub    $0x10,%esp
801042c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801042ca:	68 20 1d 11 80       	push   $0x80111d20
801042cf:	e8 2c 04 00 00       	call   80104700 <acquire>
801042d4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042d7:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
801042dc:	eb 0e                	jmp    801042ec <kill+0x2c>
801042de:	66 90                	xchg   %ax,%ax
801042e0:	05 88 00 00 00       	add    $0x88,%eax
801042e5:	3d 54 3f 11 80       	cmp    $0x80113f54,%eax
801042ea:	74 34                	je     80104320 <kill+0x60>
    if(p->pid == pid){
801042ec:	39 58 10             	cmp    %ebx,0x10(%eax)
801042ef:	75 ef                	jne    801042e0 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801042f1:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
      p->killed = 1;
801042f5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
801042fc:	75 07                	jne    80104305 <kill+0x45>
        p->state = RUNNABLE;
801042fe:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104305:	83 ec 0c             	sub    $0xc,%esp
80104308:	68 20 1d 11 80       	push   $0x80111d20
8010430d:	e8 8e 03 00 00       	call   801046a0 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
80104312:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return 0;
80104315:	83 c4 10             	add    $0x10,%esp
80104318:	31 c0                	xor    %eax,%eax
}
8010431a:	c9                   	leave  
8010431b:	c3                   	ret    
8010431c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  release(&ptable.lock);
80104320:	83 ec 0c             	sub    $0xc,%esp
80104323:	68 20 1d 11 80       	push   $0x80111d20
80104328:	e8 73 03 00 00       	call   801046a0 <release>
}
8010432d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80104330:	83 c4 10             	add    $0x10,%esp
80104333:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104338:	c9                   	leave  
80104339:	c3                   	ret    
8010433a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104340 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104340:	55                   	push   %ebp
80104341:	89 e5                	mov    %esp,%ebp
80104343:	57                   	push   %edi
80104344:	56                   	push   %esi
80104345:	8d 75 e8             	lea    -0x18(%ebp),%esi
80104348:	53                   	push   %ebx
80104349:	bb c0 1d 11 80       	mov    $0x80111dc0,%ebx
8010434e:	83 ec 3c             	sub    $0x3c,%esp
80104351:	eb 27                	jmp    8010437a <procdump+0x3a>
80104353:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104357:	90                   	nop
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104358:	83 ec 0c             	sub    $0xc,%esp
8010435b:	68 5f 7d 10 80       	push   $0x80107d5f
80104360:	e8 1b c3 ff ff       	call   80100680 <cprintf>
80104365:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104368:	81 c3 88 00 00 00    	add    $0x88,%ebx
8010436e:	81 fb c0 3f 11 80    	cmp    $0x80113fc0,%ebx
80104374:	0f 84 7e 00 00 00    	je     801043f8 <procdump+0xb8>
    if(p->state == UNUSED)
8010437a:	8b 43 a0             	mov    -0x60(%ebx),%eax
8010437d:	85 c0                	test   %eax,%eax
8010437f:	74 e7                	je     80104368 <procdump+0x28>
      state = "???";
80104381:	ba eb 79 10 80       	mov    $0x801079eb,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104386:	83 f8 05             	cmp    $0x5,%eax
80104389:	77 11                	ja     8010439c <procdump+0x5c>
8010438b:	8b 14 85 4c 7a 10 80 	mov    -0x7fef85b4(,%eax,4),%edx
      state = "???";
80104392:	b8 eb 79 10 80       	mov    $0x801079eb,%eax
80104397:	85 d2                	test   %edx,%edx
80104399:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
8010439c:	53                   	push   %ebx
8010439d:	52                   	push   %edx
8010439e:	ff 73 a4             	push   -0x5c(%ebx)
801043a1:	68 ef 79 10 80       	push   $0x801079ef
801043a6:	e8 d5 c2 ff ff       	call   80100680 <cprintf>
    if(p->state == SLEEPING){
801043ab:	83 c4 10             	add    $0x10,%esp
801043ae:	83 7b a0 02          	cmpl   $0x2,-0x60(%ebx)
801043b2:	75 a4                	jne    80104358 <procdump+0x18>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801043b4:	83 ec 08             	sub    $0x8,%esp
801043b7:	8d 45 c0             	lea    -0x40(%ebp),%eax
801043ba:	8d 7d c0             	lea    -0x40(%ebp),%edi
801043bd:	50                   	push   %eax
801043be:	8b 43 b0             	mov    -0x50(%ebx),%eax
801043c1:	8b 40 0c             	mov    0xc(%eax),%eax
801043c4:	83 c0 08             	add    $0x8,%eax
801043c7:	50                   	push   %eax
801043c8:	e8 83 01 00 00       	call   80104550 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801043cd:	83 c4 10             	add    $0x10,%esp
801043d0:	8b 17                	mov    (%edi),%edx
801043d2:	85 d2                	test   %edx,%edx
801043d4:	74 82                	je     80104358 <procdump+0x18>
        cprintf(" %p", pc[i]);
801043d6:	83 ec 08             	sub    $0x8,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801043d9:	83 c7 04             	add    $0x4,%edi
        cprintf(" %p", pc[i]);
801043dc:	52                   	push   %edx
801043dd:	68 41 74 10 80       	push   $0x80107441
801043e2:	e8 99 c2 ff ff       	call   80100680 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801043e7:	83 c4 10             	add    $0x10,%esp
801043ea:	39 fe                	cmp    %edi,%esi
801043ec:	75 e2                	jne    801043d0 <procdump+0x90>
801043ee:	e9 65 ff ff ff       	jmp    80104358 <procdump+0x18>
801043f3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801043f7:	90                   	nop
  }
}
801043f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801043fb:	5b                   	pop    %ebx
801043fc:	5e                   	pop    %esi
801043fd:	5f                   	pop    %edi
801043fe:	5d                   	pop    %ebp
801043ff:	c3                   	ret    

80104400 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104400:	55                   	push   %ebp
80104401:	89 e5                	mov    %esp,%ebp
80104403:	53                   	push   %ebx
80104404:	83 ec 0c             	sub    $0xc,%esp
80104407:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
8010440a:	68 64 7a 10 80       	push   $0x80107a64
8010440f:	8d 43 04             	lea    0x4(%ebx),%eax
80104412:	50                   	push   %eax
80104413:	e8 18 01 00 00       	call   80104530 <initlock>
  lk->name = name;
80104418:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
8010441b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
80104421:	83 c4 10             	add    $0x10,%esp
  lk->pid = 0;
80104424:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  lk->name = name;
8010442b:	89 43 38             	mov    %eax,0x38(%ebx)
}
8010442e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104431:	c9                   	leave  
80104432:	c3                   	ret    
80104433:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010443a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104440 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104440:	55                   	push   %ebp
80104441:	89 e5                	mov    %esp,%ebp
80104443:	56                   	push   %esi
80104444:	53                   	push   %ebx
80104445:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104448:	8d 73 04             	lea    0x4(%ebx),%esi
8010444b:	83 ec 0c             	sub    $0xc,%esp
8010444e:	56                   	push   %esi
8010444f:	e8 ac 02 00 00       	call   80104700 <acquire>
  while (lk->locked) {
80104454:	8b 13                	mov    (%ebx),%edx
80104456:	83 c4 10             	add    $0x10,%esp
80104459:	85 d2                	test   %edx,%edx
8010445b:	74 16                	je     80104473 <acquiresleep+0x33>
8010445d:	8d 76 00             	lea    0x0(%esi),%esi
    sleep(lk, &lk->lk);
80104460:	83 ec 08             	sub    $0x8,%esp
80104463:	56                   	push   %esi
80104464:	53                   	push   %ebx
80104465:	e8 36 fd ff ff       	call   801041a0 <sleep>
  while (lk->locked) {
8010446a:	8b 03                	mov    (%ebx),%eax
8010446c:	83 c4 10             	add    $0x10,%esp
8010446f:	85 c0                	test   %eax,%eax
80104471:	75 ed                	jne    80104460 <acquiresleep+0x20>
  }
  lk->locked = 1;
80104473:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80104479:	e8 52 f6 ff ff       	call   80103ad0 <myproc>
8010447e:	8b 40 10             	mov    0x10(%eax),%eax
80104481:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80104484:	89 75 08             	mov    %esi,0x8(%ebp)
}
80104487:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010448a:	5b                   	pop    %ebx
8010448b:	5e                   	pop    %esi
8010448c:	5d                   	pop    %ebp
  release(&lk->lk);
8010448d:	e9 0e 02 00 00       	jmp    801046a0 <release>
80104492:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801044a0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801044a0:	55                   	push   %ebp
801044a1:	89 e5                	mov    %esp,%ebp
801044a3:	56                   	push   %esi
801044a4:	53                   	push   %ebx
801044a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801044a8:	8d 73 04             	lea    0x4(%ebx),%esi
801044ab:	83 ec 0c             	sub    $0xc,%esp
801044ae:	56                   	push   %esi
801044af:	e8 4c 02 00 00       	call   80104700 <acquire>
  lk->locked = 0;
801044b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
801044ba:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
801044c1:	89 1c 24             	mov    %ebx,(%esp)
801044c4:	e8 97 fd ff ff       	call   80104260 <wakeup>
  release(&lk->lk);
801044c9:	89 75 08             	mov    %esi,0x8(%ebp)
801044cc:	83 c4 10             	add    $0x10,%esp
}
801044cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
801044d2:	5b                   	pop    %ebx
801044d3:	5e                   	pop    %esi
801044d4:	5d                   	pop    %ebp
  release(&lk->lk);
801044d5:	e9 c6 01 00 00       	jmp    801046a0 <release>
801044da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801044e0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801044e0:	55                   	push   %ebp
801044e1:	89 e5                	mov    %esp,%ebp
801044e3:	57                   	push   %edi
801044e4:	31 ff                	xor    %edi,%edi
801044e6:	56                   	push   %esi
801044e7:	53                   	push   %ebx
801044e8:	83 ec 18             	sub    $0x18,%esp
801044eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
801044ee:	8d 73 04             	lea    0x4(%ebx),%esi
801044f1:	56                   	push   %esi
801044f2:	e8 09 02 00 00       	call   80104700 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
801044f7:	8b 03                	mov    (%ebx),%eax
801044f9:	83 c4 10             	add    $0x10,%esp
801044fc:	85 c0                	test   %eax,%eax
801044fe:	75 18                	jne    80104518 <holdingsleep+0x38>
  release(&lk->lk);
80104500:	83 ec 0c             	sub    $0xc,%esp
80104503:	56                   	push   %esi
80104504:	e8 97 01 00 00       	call   801046a0 <release>
  return r;
}
80104509:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010450c:	89 f8                	mov    %edi,%eax
8010450e:	5b                   	pop    %ebx
8010450f:	5e                   	pop    %esi
80104510:	5f                   	pop    %edi
80104511:	5d                   	pop    %ebp
80104512:	c3                   	ret    
80104513:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104517:	90                   	nop
  r = lk->locked && (lk->pid == myproc()->pid);
80104518:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
8010451b:	e8 b0 f5 ff ff       	call   80103ad0 <myproc>
80104520:	39 58 10             	cmp    %ebx,0x10(%eax)
80104523:	0f 94 c0             	sete   %al
80104526:	0f b6 c0             	movzbl %al,%eax
80104529:	89 c7                	mov    %eax,%edi
8010452b:	eb d3                	jmp    80104500 <holdingsleep+0x20>
8010452d:	66 90                	xchg   %ax,%ax
8010452f:	90                   	nop

80104530 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104530:	55                   	push   %ebp
80104531:	89 e5                	mov    %esp,%ebp
80104533:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104536:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
80104539:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
8010453f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
80104542:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104549:	5d                   	pop    %ebp
8010454a:	c3                   	ret    
8010454b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010454f:	90                   	nop

80104550 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104550:	55                   	push   %ebp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104551:	31 d2                	xor    %edx,%edx
{
80104553:	89 e5                	mov    %esp,%ebp
80104555:	53                   	push   %ebx
  ebp = (uint*)v - 2;
80104556:	8b 45 08             	mov    0x8(%ebp),%eax
{
80104559:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
8010455c:	83 e8 08             	sub    $0x8,%eax
  for(i = 0; i < 10; i++){
8010455f:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104560:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104566:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
8010456c:	77 1a                	ja     80104588 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010456e:	8b 58 04             	mov    0x4(%eax),%ebx
80104571:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104574:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104577:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104579:	83 fa 0a             	cmp    $0xa,%edx
8010457c:	75 e2                	jne    80104560 <getcallerpcs+0x10>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
8010457e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104581:	c9                   	leave  
80104582:	c3                   	ret    
80104583:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104587:	90                   	nop
  for(; i < 10; i++)
80104588:	8d 04 91             	lea    (%ecx,%edx,4),%eax
8010458b:	8d 51 28             	lea    0x28(%ecx),%edx
8010458e:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104590:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104596:	83 c0 04             	add    $0x4,%eax
80104599:	39 d0                	cmp    %edx,%eax
8010459b:	75 f3                	jne    80104590 <getcallerpcs+0x40>
}
8010459d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801045a0:	c9                   	leave  
801045a1:	c3                   	ret    
801045a2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801045a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801045b0 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801045b0:	55                   	push   %ebp
801045b1:	89 e5                	mov    %esp,%ebp
801045b3:	53                   	push   %ebx
801045b4:	83 ec 04             	sub    $0x4,%esp
801045b7:	9c                   	pushf  
801045b8:	5b                   	pop    %ebx
  asm volatile("cli");
801045b9:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
801045ba:	e8 81 f4 ff ff       	call   80103a40 <mycpu>
801045bf:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801045c5:	85 c0                	test   %eax,%eax
801045c7:	74 17                	je     801045e0 <pushcli+0x30>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
801045c9:	e8 72 f4 ff ff       	call   80103a40 <mycpu>
801045ce:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
801045d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801045d8:	c9                   	leave  
801045d9:	c3                   	ret    
801045da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    mycpu()->intena = eflags & FL_IF;
801045e0:	e8 5b f4 ff ff       	call   80103a40 <mycpu>
801045e5:	81 e3 00 02 00 00    	and    $0x200,%ebx
801045eb:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
801045f1:	eb d6                	jmp    801045c9 <pushcli+0x19>
801045f3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801045fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104600 <popcli>:

void
popcli(void)
{
80104600:	55                   	push   %ebp
80104601:	89 e5                	mov    %esp,%ebp
80104603:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104606:	9c                   	pushf  
80104607:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104608:	f6 c4 02             	test   $0x2,%ah
8010460b:	75 35                	jne    80104642 <popcli+0x42>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
8010460d:	e8 2e f4 ff ff       	call   80103a40 <mycpu>
80104612:	83 a8 a4 00 00 00 01 	subl   $0x1,0xa4(%eax)
80104619:	78 34                	js     8010464f <popcli+0x4f>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010461b:	e8 20 f4 ff ff       	call   80103a40 <mycpu>
80104620:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104626:	85 d2                	test   %edx,%edx
80104628:	74 06                	je     80104630 <popcli+0x30>
    sti();
}
8010462a:	c9                   	leave  
8010462b:	c3                   	ret    
8010462c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104630:	e8 0b f4 ff ff       	call   80103a40 <mycpu>
80104635:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010463b:	85 c0                	test   %eax,%eax
8010463d:	74 eb                	je     8010462a <popcli+0x2a>
  asm volatile("sti");
8010463f:	fb                   	sti    
}
80104640:	c9                   	leave  
80104641:	c3                   	ret    
    panic("popcli - interruptible");
80104642:	83 ec 0c             	sub    $0xc,%esp
80104645:	68 6f 7a 10 80       	push   $0x80107a6f
8010464a:	e8 31 bd ff ff       	call   80100380 <panic>
    panic("popcli");
8010464f:	83 ec 0c             	sub    $0xc,%esp
80104652:	68 86 7a 10 80       	push   $0x80107a86
80104657:	e8 24 bd ff ff       	call   80100380 <panic>
8010465c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104660 <holding>:
{
80104660:	55                   	push   %ebp
80104661:	89 e5                	mov    %esp,%ebp
80104663:	56                   	push   %esi
80104664:	53                   	push   %ebx
80104665:	8b 75 08             	mov    0x8(%ebp),%esi
80104668:	31 db                	xor    %ebx,%ebx
  pushcli();
8010466a:	e8 41 ff ff ff       	call   801045b0 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010466f:	8b 06                	mov    (%esi),%eax
80104671:	85 c0                	test   %eax,%eax
80104673:	75 0b                	jne    80104680 <holding+0x20>
  popcli();
80104675:	e8 86 ff ff ff       	call   80104600 <popcli>
}
8010467a:	89 d8                	mov    %ebx,%eax
8010467c:	5b                   	pop    %ebx
8010467d:	5e                   	pop    %esi
8010467e:	5d                   	pop    %ebp
8010467f:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80104680:	8b 5e 08             	mov    0x8(%esi),%ebx
80104683:	e8 b8 f3 ff ff       	call   80103a40 <mycpu>
80104688:	39 c3                	cmp    %eax,%ebx
8010468a:	0f 94 c3             	sete   %bl
  popcli();
8010468d:	e8 6e ff ff ff       	call   80104600 <popcli>
  r = lock->locked && lock->cpu == mycpu();
80104692:	0f b6 db             	movzbl %bl,%ebx
}
80104695:	89 d8                	mov    %ebx,%eax
80104697:	5b                   	pop    %ebx
80104698:	5e                   	pop    %esi
80104699:	5d                   	pop    %ebp
8010469a:	c3                   	ret    
8010469b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010469f:	90                   	nop

801046a0 <release>:
{
801046a0:	55                   	push   %ebp
801046a1:	89 e5                	mov    %esp,%ebp
801046a3:	56                   	push   %esi
801046a4:	53                   	push   %ebx
801046a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
801046a8:	e8 03 ff ff ff       	call   801045b0 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801046ad:	8b 03                	mov    (%ebx),%eax
801046af:	85 c0                	test   %eax,%eax
801046b1:	75 15                	jne    801046c8 <release+0x28>
  popcli();
801046b3:	e8 48 ff ff ff       	call   80104600 <popcli>
    panic("release");
801046b8:	83 ec 0c             	sub    $0xc,%esp
801046bb:	68 8d 7a 10 80       	push   $0x80107a8d
801046c0:	e8 bb bc ff ff       	call   80100380 <panic>
801046c5:	8d 76 00             	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
801046c8:	8b 73 08             	mov    0x8(%ebx),%esi
801046cb:	e8 70 f3 ff ff       	call   80103a40 <mycpu>
801046d0:	39 c6                	cmp    %eax,%esi
801046d2:	75 df                	jne    801046b3 <release+0x13>
  popcli();
801046d4:	e8 27 ff ff ff       	call   80104600 <popcli>
  lk->pcs[0] = 0;
801046d9:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
801046e0:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
801046e7:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801046ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
801046f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801046f5:	5b                   	pop    %ebx
801046f6:	5e                   	pop    %esi
801046f7:	5d                   	pop    %ebp
  popcli();
801046f8:	e9 03 ff ff ff       	jmp    80104600 <popcli>
801046fd:	8d 76 00             	lea    0x0(%esi),%esi

80104700 <acquire>:
{
80104700:	55                   	push   %ebp
80104701:	89 e5                	mov    %esp,%ebp
80104703:	53                   	push   %ebx
80104704:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104707:	e8 a4 fe ff ff       	call   801045b0 <pushcli>
  if(holding(lk))
8010470c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
8010470f:	e8 9c fe ff ff       	call   801045b0 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104714:	8b 03                	mov    (%ebx),%eax
80104716:	85 c0                	test   %eax,%eax
80104718:	75 7e                	jne    80104798 <acquire+0x98>
  popcli();
8010471a:	e8 e1 fe ff ff       	call   80104600 <popcli>
  asm volatile("lock; xchgl %0, %1" :
8010471f:	b9 01 00 00 00       	mov    $0x1,%ecx
80104724:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(xchg(&lk->locked, 1) != 0)
80104728:	8b 55 08             	mov    0x8(%ebp),%edx
8010472b:	89 c8                	mov    %ecx,%eax
8010472d:	f0 87 02             	lock xchg %eax,(%edx)
80104730:	85 c0                	test   %eax,%eax
80104732:	75 f4                	jne    80104728 <acquire+0x28>
  __sync_synchronize();
80104734:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104739:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010473c:	e8 ff f2 ff ff       	call   80103a40 <mycpu>
  getcallerpcs(&lk, lk->pcs);
80104741:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ebp = (uint*)v - 2;
80104744:	89 ea                	mov    %ebp,%edx
  lk->cpu = mycpu();
80104746:	89 43 08             	mov    %eax,0x8(%ebx)
  for(i = 0; i < 10; i++){
80104749:	31 c0                	xor    %eax,%eax
8010474b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010474f:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104750:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80104756:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
8010475c:	77 1a                	ja     80104778 <acquire+0x78>
    pcs[i] = ebp[1];     // saved %eip
8010475e:	8b 5a 04             	mov    0x4(%edx),%ebx
80104761:	89 5c 81 0c          	mov    %ebx,0xc(%ecx,%eax,4)
  for(i = 0; i < 10; i++){
80104765:	83 c0 01             	add    $0x1,%eax
    ebp = (uint*)ebp[0]; // saved %ebp
80104768:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
8010476a:	83 f8 0a             	cmp    $0xa,%eax
8010476d:	75 e1                	jne    80104750 <acquire+0x50>
}
8010476f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104772:	c9                   	leave  
80104773:	c3                   	ret    
80104774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(; i < 10; i++)
80104778:	8d 44 81 0c          	lea    0xc(%ecx,%eax,4),%eax
8010477c:	8d 51 34             	lea    0x34(%ecx),%edx
8010477f:	90                   	nop
    pcs[i] = 0;
80104780:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104786:	83 c0 04             	add    $0x4,%eax
80104789:	39 c2                	cmp    %eax,%edx
8010478b:	75 f3                	jne    80104780 <acquire+0x80>
}
8010478d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104790:	c9                   	leave  
80104791:	c3                   	ret    
80104792:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
80104798:	8b 5b 08             	mov    0x8(%ebx),%ebx
8010479b:	e8 a0 f2 ff ff       	call   80103a40 <mycpu>
801047a0:	39 c3                	cmp    %eax,%ebx
801047a2:	0f 85 72 ff ff ff    	jne    8010471a <acquire+0x1a>
  popcli();
801047a8:	e8 53 fe ff ff       	call   80104600 <popcli>
    panic("acquire");
801047ad:	83 ec 0c             	sub    $0xc,%esp
801047b0:	68 95 7a 10 80       	push   $0x80107a95
801047b5:	e8 c6 bb ff ff       	call   80100380 <panic>
801047ba:	66 90                	xchg   %ax,%ax
801047bc:	66 90                	xchg   %ax,%ax
801047be:	66 90                	xchg   %ax,%ax

801047c0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801047c0:	55                   	push   %ebp
801047c1:	89 e5                	mov    %esp,%ebp
801047c3:	57                   	push   %edi
801047c4:	8b 55 08             	mov    0x8(%ebp),%edx
801047c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
801047ca:	53                   	push   %ebx
801047cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
801047ce:	89 d7                	mov    %edx,%edi
801047d0:	09 cf                	or     %ecx,%edi
801047d2:	83 e7 03             	and    $0x3,%edi
801047d5:	75 29                	jne    80104800 <memset+0x40>
    c &= 0xFF;
801047d7:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801047da:	c1 e0 18             	shl    $0x18,%eax
801047dd:	89 fb                	mov    %edi,%ebx
801047df:	c1 e9 02             	shr    $0x2,%ecx
801047e2:	c1 e3 10             	shl    $0x10,%ebx
801047e5:	09 d8                	or     %ebx,%eax
801047e7:	09 f8                	or     %edi,%eax
801047e9:	c1 e7 08             	shl    $0x8,%edi
801047ec:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
801047ee:	89 d7                	mov    %edx,%edi
801047f0:	fc                   	cld    
801047f1:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
801047f3:	5b                   	pop    %ebx
801047f4:	89 d0                	mov    %edx,%eax
801047f6:	5f                   	pop    %edi
801047f7:	5d                   	pop    %ebp
801047f8:	c3                   	ret    
801047f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  asm volatile("cld; rep stosb" :
80104800:	89 d7                	mov    %edx,%edi
80104802:	fc                   	cld    
80104803:	f3 aa                	rep stos %al,%es:(%edi)
80104805:	5b                   	pop    %ebx
80104806:	89 d0                	mov    %edx,%eax
80104808:	5f                   	pop    %edi
80104809:	5d                   	pop    %ebp
8010480a:	c3                   	ret    
8010480b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010480f:	90                   	nop

80104810 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104810:	55                   	push   %ebp
80104811:	89 e5                	mov    %esp,%ebp
80104813:	56                   	push   %esi
80104814:	8b 75 10             	mov    0x10(%ebp),%esi
80104817:	8b 55 08             	mov    0x8(%ebp),%edx
8010481a:	53                   	push   %ebx
8010481b:	8b 45 0c             	mov    0xc(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010481e:	85 f6                	test   %esi,%esi
80104820:	74 2e                	je     80104850 <memcmp+0x40>
80104822:	01 c6                	add    %eax,%esi
80104824:	eb 14                	jmp    8010483a <memcmp+0x2a>
80104826:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010482d:	8d 76 00             	lea    0x0(%esi),%esi
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80104830:	83 c0 01             	add    $0x1,%eax
80104833:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80104836:	39 f0                	cmp    %esi,%eax
80104838:	74 16                	je     80104850 <memcmp+0x40>
    if(*s1 != *s2)
8010483a:	0f b6 0a             	movzbl (%edx),%ecx
8010483d:	0f b6 18             	movzbl (%eax),%ebx
80104840:	38 d9                	cmp    %bl,%cl
80104842:	74 ec                	je     80104830 <memcmp+0x20>
      return *s1 - *s2;
80104844:	0f b6 c1             	movzbl %cl,%eax
80104847:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80104849:	5b                   	pop    %ebx
8010484a:	5e                   	pop    %esi
8010484b:	5d                   	pop    %ebp
8010484c:	c3                   	ret    
8010484d:	8d 76 00             	lea    0x0(%esi),%esi
80104850:	5b                   	pop    %ebx
  return 0;
80104851:	31 c0                	xor    %eax,%eax
}
80104853:	5e                   	pop    %esi
80104854:	5d                   	pop    %ebp
80104855:	c3                   	ret    
80104856:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010485d:	8d 76 00             	lea    0x0(%esi),%esi

80104860 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104860:	55                   	push   %ebp
80104861:	89 e5                	mov    %esp,%ebp
80104863:	57                   	push   %edi
80104864:	8b 55 08             	mov    0x8(%ebp),%edx
80104867:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010486a:	56                   	push   %esi
8010486b:	8b 75 0c             	mov    0xc(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010486e:	39 d6                	cmp    %edx,%esi
80104870:	73 26                	jae    80104898 <memmove+0x38>
80104872:	8d 3c 0e             	lea    (%esi,%ecx,1),%edi
80104875:	39 fa                	cmp    %edi,%edx
80104877:	73 1f                	jae    80104898 <memmove+0x38>
80104879:	8d 41 ff             	lea    -0x1(%ecx),%eax
    s += n;
    d += n;
    while(n-- > 0)
8010487c:	85 c9                	test   %ecx,%ecx
8010487e:	74 0c                	je     8010488c <memmove+0x2c>
      *--d = *--s;
80104880:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
80104884:	88 0c 02             	mov    %cl,(%edx,%eax,1)
    while(n-- > 0)
80104887:	83 e8 01             	sub    $0x1,%eax
8010488a:	73 f4                	jae    80104880 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
8010488c:	5e                   	pop    %esi
8010488d:	89 d0                	mov    %edx,%eax
8010488f:	5f                   	pop    %edi
80104890:	5d                   	pop    %ebp
80104891:	c3                   	ret    
80104892:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    while(n-- > 0)
80104898:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
8010489b:	89 d7                	mov    %edx,%edi
8010489d:	85 c9                	test   %ecx,%ecx
8010489f:	74 eb                	je     8010488c <memmove+0x2c>
801048a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      *d++ = *s++;
801048a8:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    while(n-- > 0)
801048a9:	39 c6                	cmp    %eax,%esi
801048ab:	75 fb                	jne    801048a8 <memmove+0x48>
}
801048ad:	5e                   	pop    %esi
801048ae:	89 d0                	mov    %edx,%eax
801048b0:	5f                   	pop    %edi
801048b1:	5d                   	pop    %ebp
801048b2:	c3                   	ret    
801048b3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801048ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801048c0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
801048c0:	eb 9e                	jmp    80104860 <memmove>
801048c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801048c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801048d0 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
801048d0:	55                   	push   %ebp
801048d1:	89 e5                	mov    %esp,%ebp
801048d3:	56                   	push   %esi
801048d4:	8b 75 10             	mov    0x10(%ebp),%esi
801048d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
801048da:	53                   	push   %ebx
801048db:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(n > 0 && *p && *p == *q)
801048de:	85 f6                	test   %esi,%esi
801048e0:	74 2e                	je     80104910 <strncmp+0x40>
801048e2:	01 d6                	add    %edx,%esi
801048e4:	eb 18                	jmp    801048fe <strncmp+0x2e>
801048e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801048ed:	8d 76 00             	lea    0x0(%esi),%esi
801048f0:	38 d8                	cmp    %bl,%al
801048f2:	75 14                	jne    80104908 <strncmp+0x38>
    n--, p++, q++;
801048f4:	83 c2 01             	add    $0x1,%edx
801048f7:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
801048fa:	39 f2                	cmp    %esi,%edx
801048fc:	74 12                	je     80104910 <strncmp+0x40>
801048fe:	0f b6 01             	movzbl (%ecx),%eax
80104901:	0f b6 1a             	movzbl (%edx),%ebx
80104904:	84 c0                	test   %al,%al
80104906:	75 e8                	jne    801048f0 <strncmp+0x20>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
80104908:	29 d8                	sub    %ebx,%eax
}
8010490a:	5b                   	pop    %ebx
8010490b:	5e                   	pop    %esi
8010490c:	5d                   	pop    %ebp
8010490d:	c3                   	ret    
8010490e:	66 90                	xchg   %ax,%ax
80104910:	5b                   	pop    %ebx
    return 0;
80104911:	31 c0                	xor    %eax,%eax
}
80104913:	5e                   	pop    %esi
80104914:	5d                   	pop    %ebp
80104915:	c3                   	ret    
80104916:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010491d:	8d 76 00             	lea    0x0(%esi),%esi

80104920 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104920:	55                   	push   %ebp
80104921:	89 e5                	mov    %esp,%ebp
80104923:	57                   	push   %edi
80104924:	56                   	push   %esi
80104925:	8b 75 08             	mov    0x8(%ebp),%esi
80104928:	53                   	push   %ebx
80104929:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
8010492c:	89 f0                	mov    %esi,%eax
8010492e:	eb 15                	jmp    80104945 <strncpy+0x25>
80104930:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80104934:	8b 7d 0c             	mov    0xc(%ebp),%edi
80104937:	83 c0 01             	add    $0x1,%eax
8010493a:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
8010493e:	88 50 ff             	mov    %dl,-0x1(%eax)
80104941:	84 d2                	test   %dl,%dl
80104943:	74 09                	je     8010494e <strncpy+0x2e>
80104945:	89 cb                	mov    %ecx,%ebx
80104947:	83 e9 01             	sub    $0x1,%ecx
8010494a:	85 db                	test   %ebx,%ebx
8010494c:	7f e2                	jg     80104930 <strncpy+0x10>
    ;
  while(n-- > 0)
8010494e:	89 c2                	mov    %eax,%edx
80104950:	85 c9                	test   %ecx,%ecx
80104952:	7e 17                	jle    8010496b <strncpy+0x4b>
80104954:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104958:	83 c2 01             	add    $0x1,%edx
8010495b:	89 c1                	mov    %eax,%ecx
8010495d:	c6 42 ff 00          	movb   $0x0,-0x1(%edx)
  while(n-- > 0)
80104961:	29 d1                	sub    %edx,%ecx
80104963:	8d 4c 0b ff          	lea    -0x1(%ebx,%ecx,1),%ecx
80104967:	85 c9                	test   %ecx,%ecx
80104969:	7f ed                	jg     80104958 <strncpy+0x38>
  return os;
}
8010496b:	5b                   	pop    %ebx
8010496c:	89 f0                	mov    %esi,%eax
8010496e:	5e                   	pop    %esi
8010496f:	5f                   	pop    %edi
80104970:	5d                   	pop    %ebp
80104971:	c3                   	ret    
80104972:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104979:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104980 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104980:	55                   	push   %ebp
80104981:	89 e5                	mov    %esp,%ebp
80104983:	56                   	push   %esi
80104984:	8b 55 10             	mov    0x10(%ebp),%edx
80104987:	8b 75 08             	mov    0x8(%ebp),%esi
8010498a:	53                   	push   %ebx
8010498b:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
8010498e:	85 d2                	test   %edx,%edx
80104990:	7e 25                	jle    801049b7 <safestrcpy+0x37>
80104992:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
80104996:	89 f2                	mov    %esi,%edx
80104998:	eb 16                	jmp    801049b0 <safestrcpy+0x30>
8010499a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
801049a0:	0f b6 08             	movzbl (%eax),%ecx
801049a3:	83 c0 01             	add    $0x1,%eax
801049a6:	83 c2 01             	add    $0x1,%edx
801049a9:	88 4a ff             	mov    %cl,-0x1(%edx)
801049ac:	84 c9                	test   %cl,%cl
801049ae:	74 04                	je     801049b4 <safestrcpy+0x34>
801049b0:	39 d8                	cmp    %ebx,%eax
801049b2:	75 ec                	jne    801049a0 <safestrcpy+0x20>
    ;
  *s = 0;
801049b4:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
801049b7:	89 f0                	mov    %esi,%eax
801049b9:	5b                   	pop    %ebx
801049ba:	5e                   	pop    %esi
801049bb:	5d                   	pop    %ebp
801049bc:	c3                   	ret    
801049bd:	8d 76 00             	lea    0x0(%esi),%esi

801049c0 <strlen>:

int
strlen(const char *s)
{
801049c0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
801049c1:	31 c0                	xor    %eax,%eax
{
801049c3:	89 e5                	mov    %esp,%ebp
801049c5:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
801049c8:	80 3a 00             	cmpb   $0x0,(%edx)
801049cb:	74 0c                	je     801049d9 <strlen+0x19>
801049cd:	8d 76 00             	lea    0x0(%esi),%esi
801049d0:	83 c0 01             	add    $0x1,%eax
801049d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
801049d7:	75 f7                	jne    801049d0 <strlen+0x10>
    ;
  return n;
}
801049d9:	5d                   	pop    %ebp
801049da:	c3                   	ret    

801049db <swtch>:
801049db:	8b 44 24 04          	mov    0x4(%esp),%eax
801049df:	8b 54 24 08          	mov    0x8(%esp),%edx
801049e3:	55                   	push   %ebp
801049e4:	53                   	push   %ebx
801049e5:	56                   	push   %esi
801049e6:	57                   	push   %edi
801049e7:	89 20                	mov    %esp,(%eax)
801049e9:	89 d4                	mov    %edx,%esp
801049eb:	5f                   	pop    %edi
801049ec:	5e                   	pop    %esi
801049ed:	5b                   	pop    %ebx
801049ee:	5d                   	pop    %ebp
801049ef:	c3                   	ret    

801049f0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801049f0:	55                   	push   %ebp
801049f1:	89 e5                	mov    %esp,%ebp
801049f3:	53                   	push   %ebx
801049f4:	83 ec 04             	sub    $0x4,%esp
801049f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801049fa:	e8 d1 f0 ff ff       	call   80103ad0 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801049ff:	8b 00                	mov    (%eax),%eax
80104a01:	39 d8                	cmp    %ebx,%eax
80104a03:	76 1b                	jbe    80104a20 <fetchint+0x30>
80104a05:	8d 53 04             	lea    0x4(%ebx),%edx
80104a08:	39 d0                	cmp    %edx,%eax
80104a0a:	72 14                	jb     80104a20 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
80104a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a0f:	8b 13                	mov    (%ebx),%edx
80104a11:	89 10                	mov    %edx,(%eax)
  return 0;
80104a13:	31 c0                	xor    %eax,%eax
}
80104a15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a18:	c9                   	leave  
80104a19:	c3                   	ret    
80104a1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80104a20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a25:	eb ee                	jmp    80104a15 <fetchint+0x25>
80104a27:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a2e:	66 90                	xchg   %ax,%ax

80104a30 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104a30:	55                   	push   %ebp
80104a31:	89 e5                	mov    %esp,%ebp
80104a33:	53                   	push   %ebx
80104a34:	83 ec 04             	sub    $0x4,%esp
80104a37:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104a3a:	e8 91 f0 ff ff       	call   80103ad0 <myproc>

  if(addr >= curproc->sz)
80104a3f:	39 18                	cmp    %ebx,(%eax)
80104a41:	76 2d                	jbe    80104a70 <fetchstr+0x40>
    return -1;
  *pp = (char*)addr;
80104a43:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a46:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104a48:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104a4a:	39 d3                	cmp    %edx,%ebx
80104a4c:	73 22                	jae    80104a70 <fetchstr+0x40>
80104a4e:	89 d8                	mov    %ebx,%eax
80104a50:	eb 0d                	jmp    80104a5f <fetchstr+0x2f>
80104a52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104a58:	83 c0 01             	add    $0x1,%eax
80104a5b:	39 c2                	cmp    %eax,%edx
80104a5d:	76 11                	jbe    80104a70 <fetchstr+0x40>
    if(*s == 0)
80104a5f:	80 38 00             	cmpb   $0x0,(%eax)
80104a62:	75 f4                	jne    80104a58 <fetchstr+0x28>
      return s - *pp;
80104a64:	29 d8                	sub    %ebx,%eax
  }
  return -1;
}
80104a66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a69:	c9                   	leave  
80104a6a:	c3                   	ret    
80104a6b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104a6f:	90                   	nop
80104a70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return -1;
80104a73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104a78:	c9                   	leave  
80104a79:	c3                   	ret    
80104a7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104a80 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104a80:	55                   	push   %ebp
80104a81:	89 e5                	mov    %esp,%ebp
80104a83:	56                   	push   %esi
80104a84:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104a85:	e8 46 f0 ff ff       	call   80103ad0 <myproc>
80104a8a:	8b 55 08             	mov    0x8(%ebp),%edx
80104a8d:	8b 40 18             	mov    0x18(%eax),%eax
80104a90:	8b 40 44             	mov    0x44(%eax),%eax
80104a93:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104a96:	e8 35 f0 ff ff       	call   80103ad0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104a9b:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104a9e:	8b 00                	mov    (%eax),%eax
80104aa0:	39 c6                	cmp    %eax,%esi
80104aa2:	73 1c                	jae    80104ac0 <argint+0x40>
80104aa4:	8d 53 08             	lea    0x8(%ebx),%edx
80104aa7:	39 d0                	cmp    %edx,%eax
80104aa9:	72 15                	jb     80104ac0 <argint+0x40>
  *ip = *(int*)(addr);
80104aab:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aae:	8b 53 04             	mov    0x4(%ebx),%edx
80104ab1:	89 10                	mov    %edx,(%eax)
  return 0;
80104ab3:	31 c0                	xor    %eax,%eax
}
80104ab5:	5b                   	pop    %ebx
80104ab6:	5e                   	pop    %esi
80104ab7:	5d                   	pop    %ebp
80104ab8:	c3                   	ret    
80104ab9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80104ac0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104ac5:	eb ee                	jmp    80104ab5 <argint+0x35>
80104ac7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ace:	66 90                	xchg   %ax,%ax

80104ad0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104ad0:	55                   	push   %ebp
80104ad1:	89 e5                	mov    %esp,%ebp
80104ad3:	57                   	push   %edi
80104ad4:	56                   	push   %esi
80104ad5:	53                   	push   %ebx
80104ad6:	83 ec 0c             	sub    $0xc,%esp
  int i;
  struct proc *curproc = myproc();
80104ad9:	e8 f2 ef ff ff       	call   80103ad0 <myproc>
80104ade:	89 c6                	mov    %eax,%esi
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104ae0:	e8 eb ef ff ff       	call   80103ad0 <myproc>
80104ae5:	8b 55 08             	mov    0x8(%ebp),%edx
80104ae8:	8b 40 18             	mov    0x18(%eax),%eax
80104aeb:	8b 40 44             	mov    0x44(%eax),%eax
80104aee:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104af1:	e8 da ef ff ff       	call   80103ad0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104af6:	8d 7b 04             	lea    0x4(%ebx),%edi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104af9:	8b 00                	mov    (%eax),%eax
80104afb:	39 c7                	cmp    %eax,%edi
80104afd:	73 31                	jae    80104b30 <argptr+0x60>
80104aff:	8d 4b 08             	lea    0x8(%ebx),%ecx
80104b02:	39 c8                	cmp    %ecx,%eax
80104b04:	72 2a                	jb     80104b30 <argptr+0x60>
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104b06:	8b 55 10             	mov    0x10(%ebp),%edx
  *ip = *(int*)(addr);
80104b09:	8b 43 04             	mov    0x4(%ebx),%eax
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104b0c:	85 d2                	test   %edx,%edx
80104b0e:	78 20                	js     80104b30 <argptr+0x60>
80104b10:	8b 16                	mov    (%esi),%edx
80104b12:	39 c2                	cmp    %eax,%edx
80104b14:	76 1a                	jbe    80104b30 <argptr+0x60>
80104b16:	8b 5d 10             	mov    0x10(%ebp),%ebx
80104b19:	01 c3                	add    %eax,%ebx
80104b1b:	39 da                	cmp    %ebx,%edx
80104b1d:	72 11                	jb     80104b30 <argptr+0x60>
    return -1;
  *pp = (char*)i;
80104b1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b22:	89 02                	mov    %eax,(%edx)
  return 0;
80104b24:	31 c0                	xor    %eax,%eax
}
80104b26:	83 c4 0c             	add    $0xc,%esp
80104b29:	5b                   	pop    %ebx
80104b2a:	5e                   	pop    %esi
80104b2b:	5f                   	pop    %edi
80104b2c:	5d                   	pop    %ebp
80104b2d:	c3                   	ret    
80104b2e:	66 90                	xchg   %ax,%ax
    return -1;
80104b30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b35:	eb ef                	jmp    80104b26 <argptr+0x56>
80104b37:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b3e:	66 90                	xchg   %ax,%ax

80104b40 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104b40:	55                   	push   %ebp
80104b41:	89 e5                	mov    %esp,%ebp
80104b43:	56                   	push   %esi
80104b44:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104b45:	e8 86 ef ff ff       	call   80103ad0 <myproc>
80104b4a:	8b 55 08             	mov    0x8(%ebp),%edx
80104b4d:	8b 40 18             	mov    0x18(%eax),%eax
80104b50:	8b 40 44             	mov    0x44(%eax),%eax
80104b53:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104b56:	e8 75 ef ff ff       	call   80103ad0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104b5b:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104b5e:	8b 00                	mov    (%eax),%eax
80104b60:	39 c6                	cmp    %eax,%esi
80104b62:	73 44                	jae    80104ba8 <argstr+0x68>
80104b64:	8d 53 08             	lea    0x8(%ebx),%edx
80104b67:	39 d0                	cmp    %edx,%eax
80104b69:	72 3d                	jb     80104ba8 <argstr+0x68>
  *ip = *(int*)(addr);
80104b6b:	8b 5b 04             	mov    0x4(%ebx),%ebx
  struct proc *curproc = myproc();
80104b6e:	e8 5d ef ff ff       	call   80103ad0 <myproc>
  if(addr >= curproc->sz)
80104b73:	3b 18                	cmp    (%eax),%ebx
80104b75:	73 31                	jae    80104ba8 <argstr+0x68>
  *pp = (char*)addr;
80104b77:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b7a:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104b7c:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104b7e:	39 d3                	cmp    %edx,%ebx
80104b80:	73 26                	jae    80104ba8 <argstr+0x68>
80104b82:	89 d8                	mov    %ebx,%eax
80104b84:	eb 11                	jmp    80104b97 <argstr+0x57>
80104b86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b8d:	8d 76 00             	lea    0x0(%esi),%esi
80104b90:	83 c0 01             	add    $0x1,%eax
80104b93:	39 c2                	cmp    %eax,%edx
80104b95:	76 11                	jbe    80104ba8 <argstr+0x68>
    if(*s == 0)
80104b97:	80 38 00             	cmpb   $0x0,(%eax)
80104b9a:	75 f4                	jne    80104b90 <argstr+0x50>
      return s - *pp;
80104b9c:	29 d8                	sub    %ebx,%eax
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(addr, pp);
}
80104b9e:	5b                   	pop    %ebx
80104b9f:	5e                   	pop    %esi
80104ba0:	5d                   	pop    %ebp
80104ba1:	c3                   	ret    
80104ba2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104ba8:	5b                   	pop    %ebx
    return -1;
80104ba9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104bae:	5e                   	pop    %esi
80104baf:	5d                   	pop    %ebp
80104bb0:	c3                   	ret    
80104bb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104bb8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104bbf:	90                   	nop

80104bc0 <syscall>:
[SYS_alarm]    sys_alarm,
};

void
syscall(void)
{
80104bc0:	55                   	push   %ebp
80104bc1:	89 e5                	mov    %esp,%ebp
80104bc3:	53                   	push   %ebx
80104bc4:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104bc7:	e8 04 ef ff ff       	call   80103ad0 <myproc>
80104bcc:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax; // eax means sys call num
80104bce:	8b 40 18             	mov    0x18(%eax),%eax
80104bd1:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104bd4:	8d 50 ff             	lea    -0x1(%eax),%edx
80104bd7:	83 fa 16             	cmp    $0x16,%edx
80104bda:	77 24                	ja     80104c00 <syscall+0x40>
80104bdc:	8b 14 85 c0 7a 10 80 	mov    -0x7fef8540(,%eax,4),%edx
80104be3:	85 d2                	test   %edx,%edx
80104be5:	74 19                	je     80104c00 <syscall+0x40>
    curproc->tf->eax = syscalls[num]();
80104be7:	ff d2                	call   *%edx
80104be9:	89 c2                	mov    %eax,%edx
80104beb:	8b 43 18             	mov    0x18(%ebx),%eax
80104bee:	89 50 1c             	mov    %edx,0x1c(%eax)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104bf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bf4:	c9                   	leave  
80104bf5:	c3                   	ret    
80104bf6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104bfd:	8d 76 00             	lea    0x0(%esi),%esi
    cprintf("%d %s: unknown sys call %d\n",
80104c00:	50                   	push   %eax
            curproc->pid, curproc->name, num);
80104c01:	8d 43 6c             	lea    0x6c(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80104c04:	50                   	push   %eax
80104c05:	ff 73 10             	push   0x10(%ebx)
80104c08:	68 9d 7a 10 80       	push   $0x80107a9d
80104c0d:	e8 6e ba ff ff       	call   80100680 <cprintf>
    curproc->tf->eax = -1;
80104c12:	8b 43 18             	mov    0x18(%ebx),%eax
80104c15:	83 c4 10             	add    $0x10,%esp
80104c18:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
80104c1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c22:	c9                   	leave  
80104c23:	c3                   	ret    
80104c24:	66 90                	xchg   %ax,%ax
80104c26:	66 90                	xchg   %ax,%ax
80104c28:	66 90                	xchg   %ax,%ax
80104c2a:	66 90                	xchg   %ax,%ax
80104c2c:	66 90                	xchg   %ax,%ax
80104c2e:	66 90                	xchg   %ax,%ax

80104c30 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104c30:	55                   	push   %ebp
80104c31:	89 e5                	mov    %esp,%ebp
80104c33:	57                   	push   %edi
80104c34:	56                   	push   %esi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104c35:	8d 7d da             	lea    -0x26(%ebp),%edi
{
80104c38:	53                   	push   %ebx
80104c39:	83 ec 34             	sub    $0x34,%esp
80104c3c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104c3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
80104c42:	57                   	push   %edi
80104c43:	50                   	push   %eax
{
80104c44:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80104c47:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  if((dp = nameiparent(path, name)) == 0)
80104c4a:	e8 91 d5 ff ff       	call   801021e0 <nameiparent>
80104c4f:	83 c4 10             	add    $0x10,%esp
80104c52:	85 c0                	test   %eax,%eax
80104c54:	0f 84 46 01 00 00    	je     80104da0 <create+0x170>
    return 0;
  ilock(dp);
80104c5a:	83 ec 0c             	sub    $0xc,%esp
80104c5d:	89 c3                	mov    %eax,%ebx
80104c5f:	50                   	push   %eax
80104c60:	e8 3b cc ff ff       	call   801018a0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104c65:	83 c4 0c             	add    $0xc,%esp
80104c68:	6a 00                	push   $0x0
80104c6a:	57                   	push   %edi
80104c6b:	53                   	push   %ebx
80104c6c:	e8 8f d1 ff ff       	call   80101e00 <dirlookup>
80104c71:	83 c4 10             	add    $0x10,%esp
80104c74:	89 c6                	mov    %eax,%esi
80104c76:	85 c0                	test   %eax,%eax
80104c78:	74 56                	je     80104cd0 <create+0xa0>
    iunlockput(dp);
80104c7a:	83 ec 0c             	sub    $0xc,%esp
80104c7d:	53                   	push   %ebx
80104c7e:	e8 ad ce ff ff       	call   80101b30 <iunlockput>
    ilock(ip);
80104c83:	89 34 24             	mov    %esi,(%esp)
80104c86:	e8 15 cc ff ff       	call   801018a0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104c8b:	83 c4 10             	add    $0x10,%esp
80104c8e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80104c93:	75 1b                	jne    80104cb0 <create+0x80>
80104c95:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
80104c9a:	75 14                	jne    80104cb0 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104c9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104c9f:	89 f0                	mov    %esi,%eax
80104ca1:	5b                   	pop    %ebx
80104ca2:	5e                   	pop    %esi
80104ca3:	5f                   	pop    %edi
80104ca4:	5d                   	pop    %ebp
80104ca5:	c3                   	ret    
80104ca6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104cad:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80104cb0:	83 ec 0c             	sub    $0xc,%esp
80104cb3:	56                   	push   %esi
    return 0;
80104cb4:	31 f6                	xor    %esi,%esi
    iunlockput(ip);
80104cb6:	e8 75 ce ff ff       	call   80101b30 <iunlockput>
    return 0;
80104cbb:	83 c4 10             	add    $0x10,%esp
}
80104cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104cc1:	89 f0                	mov    %esi,%eax
80104cc3:	5b                   	pop    %ebx
80104cc4:	5e                   	pop    %esi
80104cc5:	5f                   	pop    %edi
80104cc6:	5d                   	pop    %ebp
80104cc7:	c3                   	ret    
80104cc8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ccf:	90                   	nop
  if((ip = ialloc(dp->dev, type)) == 0)
80104cd0:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80104cd4:	83 ec 08             	sub    $0x8,%esp
80104cd7:	50                   	push   %eax
80104cd8:	ff 33                	push   (%ebx)
80104cda:	e8 51 ca ff ff       	call   80101730 <ialloc>
80104cdf:	83 c4 10             	add    $0x10,%esp
80104ce2:	89 c6                	mov    %eax,%esi
80104ce4:	85 c0                	test   %eax,%eax
80104ce6:	0f 84 cd 00 00 00    	je     80104db9 <create+0x189>
  ilock(ip);
80104cec:	83 ec 0c             	sub    $0xc,%esp
80104cef:	50                   	push   %eax
80104cf0:	e8 ab cb ff ff       	call   801018a0 <ilock>
  ip->major = major;
80104cf5:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80104cf9:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
80104cfd:	0f b7 45 cc          	movzwl -0x34(%ebp),%eax
80104d01:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
80104d05:	b8 01 00 00 00       	mov    $0x1,%eax
80104d0a:	66 89 46 56          	mov    %ax,0x56(%esi)
  iupdate(ip);
80104d0e:	89 34 24             	mov    %esi,(%esp)
80104d11:	e8 da ca ff ff       	call   801017f0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104d16:	83 c4 10             	add    $0x10,%esp
80104d19:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80104d1e:	74 30                	je     80104d50 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80104d20:	83 ec 04             	sub    $0x4,%esp
80104d23:	ff 76 04             	push   0x4(%esi)
80104d26:	57                   	push   %edi
80104d27:	53                   	push   %ebx
80104d28:	e8 d3 d3 ff ff       	call   80102100 <dirlink>
80104d2d:	83 c4 10             	add    $0x10,%esp
80104d30:	85 c0                	test   %eax,%eax
80104d32:	78 78                	js     80104dac <create+0x17c>
  iunlockput(dp);
80104d34:	83 ec 0c             	sub    $0xc,%esp
80104d37:	53                   	push   %ebx
80104d38:	e8 f3 cd ff ff       	call   80101b30 <iunlockput>
  return ip;
80104d3d:	83 c4 10             	add    $0x10,%esp
}
80104d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104d43:	89 f0                	mov    %esi,%eax
80104d45:	5b                   	pop    %ebx
80104d46:	5e                   	pop    %esi
80104d47:	5f                   	pop    %edi
80104d48:	5d                   	pop    %ebp
80104d49:	c3                   	ret    
80104d4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iupdate(dp);
80104d50:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink++;  // for ".."
80104d53:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
80104d58:	53                   	push   %ebx
80104d59:	e8 92 ca ff ff       	call   801017f0 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104d5e:	83 c4 0c             	add    $0xc,%esp
80104d61:	ff 76 04             	push   0x4(%esi)
80104d64:	68 3c 7b 10 80       	push   $0x80107b3c
80104d69:	56                   	push   %esi
80104d6a:	e8 91 d3 ff ff       	call   80102100 <dirlink>
80104d6f:	83 c4 10             	add    $0x10,%esp
80104d72:	85 c0                	test   %eax,%eax
80104d74:	78 18                	js     80104d8e <create+0x15e>
80104d76:	83 ec 04             	sub    $0x4,%esp
80104d79:	ff 73 04             	push   0x4(%ebx)
80104d7c:	68 3b 7b 10 80       	push   $0x80107b3b
80104d81:	56                   	push   %esi
80104d82:	e8 79 d3 ff ff       	call   80102100 <dirlink>
80104d87:	83 c4 10             	add    $0x10,%esp
80104d8a:	85 c0                	test   %eax,%eax
80104d8c:	79 92                	jns    80104d20 <create+0xf0>
      panic("create dots");
80104d8e:	83 ec 0c             	sub    $0xc,%esp
80104d91:	68 2f 7b 10 80       	push   $0x80107b2f
80104d96:	e8 e5 b5 ff ff       	call   80100380 <panic>
80104d9b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104d9f:	90                   	nop
}
80104da0:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80104da3:	31 f6                	xor    %esi,%esi
}
80104da5:	5b                   	pop    %ebx
80104da6:	89 f0                	mov    %esi,%eax
80104da8:	5e                   	pop    %esi
80104da9:	5f                   	pop    %edi
80104daa:	5d                   	pop    %ebp
80104dab:	c3                   	ret    
    panic("create: dirlink");
80104dac:	83 ec 0c             	sub    $0xc,%esp
80104daf:	68 3e 7b 10 80       	push   $0x80107b3e
80104db4:	e8 c7 b5 ff ff       	call   80100380 <panic>
    panic("create: ialloc");
80104db9:	83 ec 0c             	sub    $0xc,%esp
80104dbc:	68 20 7b 10 80       	push   $0x80107b20
80104dc1:	e8 ba b5 ff ff       	call   80100380 <panic>
80104dc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104dcd:	8d 76 00             	lea    0x0(%esi),%esi

80104dd0 <sys_dup>:
{
80104dd0:	55                   	push   %ebp
80104dd1:	89 e5                	mov    %esp,%ebp
80104dd3:	56                   	push   %esi
80104dd4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80104dd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80104dd8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104ddb:	50                   	push   %eax
80104ddc:	6a 00                	push   $0x0
80104dde:	e8 9d fc ff ff       	call   80104a80 <argint>
80104de3:	83 c4 10             	add    $0x10,%esp
80104de6:	85 c0                	test   %eax,%eax
80104de8:	78 36                	js     80104e20 <sys_dup+0x50>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104dea:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104dee:	77 30                	ja     80104e20 <sys_dup+0x50>
80104df0:	e8 db ec ff ff       	call   80103ad0 <myproc>
80104df5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104df8:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
80104dfc:	85 f6                	test   %esi,%esi
80104dfe:	74 20                	je     80104e20 <sys_dup+0x50>
  struct proc *curproc = myproc();
80104e00:	e8 cb ec ff ff       	call   80103ad0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80104e05:	31 db                	xor    %ebx,%ebx
80104e07:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104e0e:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80104e10:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80104e14:	85 d2                	test   %edx,%edx
80104e16:	74 18                	je     80104e30 <sys_dup+0x60>
  for(fd = 0; fd < NOFILE; fd++){
80104e18:	83 c3 01             	add    $0x1,%ebx
80104e1b:	83 fb 10             	cmp    $0x10,%ebx
80104e1e:	75 f0                	jne    80104e10 <sys_dup+0x40>
}
80104e20:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return -1;
80104e23:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80104e28:	89 d8                	mov    %ebx,%eax
80104e2a:	5b                   	pop    %ebx
80104e2b:	5e                   	pop    %esi
80104e2c:	5d                   	pop    %ebp
80104e2d:	c3                   	ret    
80104e2e:	66 90                	xchg   %ax,%ax
  filedup(f);
80104e30:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
80104e33:	89 74 98 28          	mov    %esi,0x28(%eax,%ebx,4)
  filedup(f);
80104e37:	56                   	push   %esi
80104e38:	e8 83 c1 ff ff       	call   80100fc0 <filedup>
  return fd;
80104e3d:	83 c4 10             	add    $0x10,%esp
}
80104e40:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104e43:	89 d8                	mov    %ebx,%eax
80104e45:	5b                   	pop    %ebx
80104e46:	5e                   	pop    %esi
80104e47:	5d                   	pop    %ebp
80104e48:	c3                   	ret    
80104e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104e50 <sys_read>:
{
80104e50:	55                   	push   %ebp
80104e51:	89 e5                	mov    %esp,%ebp
80104e53:	56                   	push   %esi
80104e54:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80104e55:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80104e58:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104e5b:	53                   	push   %ebx
80104e5c:	6a 00                	push   $0x0
80104e5e:	e8 1d fc ff ff       	call   80104a80 <argint>
80104e63:	83 c4 10             	add    $0x10,%esp
80104e66:	85 c0                	test   %eax,%eax
80104e68:	78 5e                	js     80104ec8 <sys_read+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104e6a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104e6e:	77 58                	ja     80104ec8 <sys_read+0x78>
80104e70:	e8 5b ec ff ff       	call   80103ad0 <myproc>
80104e75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e78:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
80104e7c:	85 f6                	test   %esi,%esi
80104e7e:	74 48                	je     80104ec8 <sys_read+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104e80:	83 ec 08             	sub    $0x8,%esp
80104e83:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e86:	50                   	push   %eax
80104e87:	6a 02                	push   $0x2
80104e89:	e8 f2 fb ff ff       	call   80104a80 <argint>
80104e8e:	83 c4 10             	add    $0x10,%esp
80104e91:	85 c0                	test   %eax,%eax
80104e93:	78 33                	js     80104ec8 <sys_read+0x78>
80104e95:	83 ec 04             	sub    $0x4,%esp
80104e98:	ff 75 f0             	push   -0x10(%ebp)
80104e9b:	53                   	push   %ebx
80104e9c:	6a 01                	push   $0x1
80104e9e:	e8 2d fc ff ff       	call   80104ad0 <argptr>
80104ea3:	83 c4 10             	add    $0x10,%esp
80104ea6:	85 c0                	test   %eax,%eax
80104ea8:	78 1e                	js     80104ec8 <sys_read+0x78>
  return fileread(f, p, n);
80104eaa:	83 ec 04             	sub    $0x4,%esp
80104ead:	ff 75 f0             	push   -0x10(%ebp)
80104eb0:	ff 75 f4             	push   -0xc(%ebp)
80104eb3:	56                   	push   %esi
80104eb4:	e8 87 c2 ff ff       	call   80101140 <fileread>
80104eb9:	83 c4 10             	add    $0x10,%esp
}
80104ebc:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104ebf:	5b                   	pop    %ebx
80104ec0:	5e                   	pop    %esi
80104ec1:	5d                   	pop    %ebp
80104ec2:	c3                   	ret    
80104ec3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104ec7:	90                   	nop
    return -1;
80104ec8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ecd:	eb ed                	jmp    80104ebc <sys_read+0x6c>
80104ecf:	90                   	nop

80104ed0 <sys_write>:
{
80104ed0:	55                   	push   %ebp
80104ed1:	89 e5                	mov    %esp,%ebp
80104ed3:	56                   	push   %esi
80104ed4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80104ed5:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80104ed8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104edb:	53                   	push   %ebx
80104edc:	6a 00                	push   $0x0
80104ede:	e8 9d fb ff ff       	call   80104a80 <argint>
80104ee3:	83 c4 10             	add    $0x10,%esp
80104ee6:	85 c0                	test   %eax,%eax
80104ee8:	78 5e                	js     80104f48 <sys_write+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104eea:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104eee:	77 58                	ja     80104f48 <sys_write+0x78>
80104ef0:	e8 db eb ff ff       	call   80103ad0 <myproc>
80104ef5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ef8:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
80104efc:	85 f6                	test   %esi,%esi
80104efe:	74 48                	je     80104f48 <sys_write+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f00:	83 ec 08             	sub    $0x8,%esp
80104f03:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f06:	50                   	push   %eax
80104f07:	6a 02                	push   $0x2
80104f09:	e8 72 fb ff ff       	call   80104a80 <argint>
80104f0e:	83 c4 10             	add    $0x10,%esp
80104f11:	85 c0                	test   %eax,%eax
80104f13:	78 33                	js     80104f48 <sys_write+0x78>
80104f15:	83 ec 04             	sub    $0x4,%esp
80104f18:	ff 75 f0             	push   -0x10(%ebp)
80104f1b:	53                   	push   %ebx
80104f1c:	6a 01                	push   $0x1
80104f1e:	e8 ad fb ff ff       	call   80104ad0 <argptr>
80104f23:	83 c4 10             	add    $0x10,%esp
80104f26:	85 c0                	test   %eax,%eax
80104f28:	78 1e                	js     80104f48 <sys_write+0x78>
  return filewrite(f, p, n);
80104f2a:	83 ec 04             	sub    $0x4,%esp
80104f2d:	ff 75 f0             	push   -0x10(%ebp)
80104f30:	ff 75 f4             	push   -0xc(%ebp)
80104f33:	56                   	push   %esi
80104f34:	e8 97 c2 ff ff       	call   801011d0 <filewrite>
80104f39:	83 c4 10             	add    $0x10,%esp
}
80104f3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104f3f:	5b                   	pop    %ebx
80104f40:	5e                   	pop    %esi
80104f41:	5d                   	pop    %ebp
80104f42:	c3                   	ret    
80104f43:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104f47:	90                   	nop
    return -1;
80104f48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f4d:	eb ed                	jmp    80104f3c <sys_write+0x6c>
80104f4f:	90                   	nop

80104f50 <sys_close>:
{
80104f50:	55                   	push   %ebp
80104f51:	89 e5                	mov    %esp,%ebp
80104f53:	56                   	push   %esi
80104f54:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80104f55:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80104f58:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104f5b:	50                   	push   %eax
80104f5c:	6a 00                	push   $0x0
80104f5e:	e8 1d fb ff ff       	call   80104a80 <argint>
80104f63:	83 c4 10             	add    $0x10,%esp
80104f66:	85 c0                	test   %eax,%eax
80104f68:	78 3e                	js     80104fa8 <sys_close+0x58>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104f6a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104f6e:	77 38                	ja     80104fa8 <sys_close+0x58>
80104f70:	e8 5b eb ff ff       	call   80103ad0 <myproc>
80104f75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f78:	8d 5a 08             	lea    0x8(%edx),%ebx
80104f7b:	8b 74 98 08          	mov    0x8(%eax,%ebx,4),%esi
80104f7f:	85 f6                	test   %esi,%esi
80104f81:	74 25                	je     80104fa8 <sys_close+0x58>
  myproc()->ofile[fd] = 0;
80104f83:	e8 48 eb ff ff       	call   80103ad0 <myproc>
  fileclose(f);
80104f88:	83 ec 0c             	sub    $0xc,%esp
  myproc()->ofile[fd] = 0;
80104f8b:	c7 44 98 08 00 00 00 	movl   $0x0,0x8(%eax,%ebx,4)
80104f92:	00 
  fileclose(f);
80104f93:	56                   	push   %esi
80104f94:	e8 77 c0 ff ff       	call   80101010 <fileclose>
  return 0;
80104f99:	83 c4 10             	add    $0x10,%esp
80104f9c:	31 c0                	xor    %eax,%eax
}
80104f9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104fa1:	5b                   	pop    %ebx
80104fa2:	5e                   	pop    %esi
80104fa3:	5d                   	pop    %ebp
80104fa4:	c3                   	ret    
80104fa5:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104fa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fad:	eb ef                	jmp    80104f9e <sys_close+0x4e>
80104faf:	90                   	nop

80104fb0 <sys_fstat>:
{
80104fb0:	55                   	push   %ebp
80104fb1:	89 e5                	mov    %esp,%ebp
80104fb3:	56                   	push   %esi
80104fb4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80104fb5:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80104fb8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104fbb:	53                   	push   %ebx
80104fbc:	6a 00                	push   $0x0
80104fbe:	e8 bd fa ff ff       	call   80104a80 <argint>
80104fc3:	83 c4 10             	add    $0x10,%esp
80104fc6:	85 c0                	test   %eax,%eax
80104fc8:	78 46                	js     80105010 <sys_fstat+0x60>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104fca:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104fce:	77 40                	ja     80105010 <sys_fstat+0x60>
80104fd0:	e8 fb ea ff ff       	call   80103ad0 <myproc>
80104fd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fd8:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
80104fdc:	85 f6                	test   %esi,%esi
80104fde:	74 30                	je     80105010 <sys_fstat+0x60>
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104fe0:	83 ec 04             	sub    $0x4,%esp
80104fe3:	6a 14                	push   $0x14
80104fe5:	53                   	push   %ebx
80104fe6:	6a 01                	push   $0x1
80104fe8:	e8 e3 fa ff ff       	call   80104ad0 <argptr>
80104fed:	83 c4 10             	add    $0x10,%esp
80104ff0:	85 c0                	test   %eax,%eax
80104ff2:	78 1c                	js     80105010 <sys_fstat+0x60>
  return filestat(f, st);
80104ff4:	83 ec 08             	sub    $0x8,%esp
80104ff7:	ff 75 f4             	push   -0xc(%ebp)
80104ffa:	56                   	push   %esi
80104ffb:	e8 f0 c0 ff ff       	call   801010f0 <filestat>
80105000:	83 c4 10             	add    $0x10,%esp
}
80105003:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105006:	5b                   	pop    %ebx
80105007:	5e                   	pop    %esi
80105008:	5d                   	pop    %ebp
80105009:	c3                   	ret    
8010500a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80105010:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105015:	eb ec                	jmp    80105003 <sys_fstat+0x53>
80105017:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010501e:	66 90                	xchg   %ax,%ax

80105020 <sys_link>:
{
80105020:	55                   	push   %ebp
80105021:	89 e5                	mov    %esp,%ebp
80105023:	57                   	push   %edi
80105024:	56                   	push   %esi
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105025:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80105028:	53                   	push   %ebx
80105029:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010502c:	50                   	push   %eax
8010502d:	6a 00                	push   $0x0
8010502f:	e8 0c fb ff ff       	call   80104b40 <argstr>
80105034:	83 c4 10             	add    $0x10,%esp
80105037:	85 c0                	test   %eax,%eax
80105039:	0f 88 fb 00 00 00    	js     8010513a <sys_link+0x11a>
8010503f:	83 ec 08             	sub    $0x8,%esp
80105042:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105045:	50                   	push   %eax
80105046:	6a 01                	push   $0x1
80105048:	e8 f3 fa ff ff       	call   80104b40 <argstr>
8010504d:	83 c4 10             	add    $0x10,%esp
80105050:	85 c0                	test   %eax,%eax
80105052:	0f 88 e2 00 00 00    	js     8010513a <sys_link+0x11a>
  begin_op();
80105058:	e8 23 de ff ff       	call   80102e80 <begin_op>
  if((ip = namei(old)) == 0){
8010505d:	83 ec 0c             	sub    $0xc,%esp
80105060:	ff 75 d4             	push   -0x2c(%ebp)
80105063:	e8 58 d1 ff ff       	call   801021c0 <namei>
80105068:	83 c4 10             	add    $0x10,%esp
8010506b:	89 c3                	mov    %eax,%ebx
8010506d:	85 c0                	test   %eax,%eax
8010506f:	0f 84 e4 00 00 00    	je     80105159 <sys_link+0x139>
  ilock(ip);
80105075:	83 ec 0c             	sub    $0xc,%esp
80105078:	50                   	push   %eax
80105079:	e8 22 c8 ff ff       	call   801018a0 <ilock>
  if(ip->type == T_DIR){
8010507e:	83 c4 10             	add    $0x10,%esp
80105081:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105086:	0f 84 b5 00 00 00    	je     80105141 <sys_link+0x121>
  iupdate(ip);
8010508c:	83 ec 0c             	sub    $0xc,%esp
  ip->nlink++;
8010508f:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  if((dp = nameiparent(new, name)) == 0)
80105094:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
80105097:	53                   	push   %ebx
80105098:	e8 53 c7 ff ff       	call   801017f0 <iupdate>
  iunlock(ip);
8010509d:	89 1c 24             	mov    %ebx,(%esp)
801050a0:	e8 db c8 ff ff       	call   80101980 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801050a5:	58                   	pop    %eax
801050a6:	5a                   	pop    %edx
801050a7:	57                   	push   %edi
801050a8:	ff 75 d0             	push   -0x30(%ebp)
801050ab:	e8 30 d1 ff ff       	call   801021e0 <nameiparent>
801050b0:	83 c4 10             	add    $0x10,%esp
801050b3:	89 c6                	mov    %eax,%esi
801050b5:	85 c0                	test   %eax,%eax
801050b7:	74 5b                	je     80105114 <sys_link+0xf4>
  ilock(dp);
801050b9:	83 ec 0c             	sub    $0xc,%esp
801050bc:	50                   	push   %eax
801050bd:	e8 de c7 ff ff       	call   801018a0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801050c2:	8b 03                	mov    (%ebx),%eax
801050c4:	83 c4 10             	add    $0x10,%esp
801050c7:	39 06                	cmp    %eax,(%esi)
801050c9:	75 3d                	jne    80105108 <sys_link+0xe8>
801050cb:	83 ec 04             	sub    $0x4,%esp
801050ce:	ff 73 04             	push   0x4(%ebx)
801050d1:	57                   	push   %edi
801050d2:	56                   	push   %esi
801050d3:	e8 28 d0 ff ff       	call   80102100 <dirlink>
801050d8:	83 c4 10             	add    $0x10,%esp
801050db:	85 c0                	test   %eax,%eax
801050dd:	78 29                	js     80105108 <sys_link+0xe8>
  iunlockput(dp);
801050df:	83 ec 0c             	sub    $0xc,%esp
801050e2:	56                   	push   %esi
801050e3:	e8 48 ca ff ff       	call   80101b30 <iunlockput>
  iput(ip);
801050e8:	89 1c 24             	mov    %ebx,(%esp)
801050eb:	e8 e0 c8 ff ff       	call   801019d0 <iput>
  end_op();
801050f0:	e8 fb dd ff ff       	call   80102ef0 <end_op>
  return 0;
801050f5:	83 c4 10             	add    $0x10,%esp
801050f8:	31 c0                	xor    %eax,%eax
}
801050fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801050fd:	5b                   	pop    %ebx
801050fe:	5e                   	pop    %esi
801050ff:	5f                   	pop    %edi
80105100:	5d                   	pop    %ebp
80105101:	c3                   	ret    
80105102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
80105108:	83 ec 0c             	sub    $0xc,%esp
8010510b:	56                   	push   %esi
8010510c:	e8 1f ca ff ff       	call   80101b30 <iunlockput>
    goto bad;
80105111:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80105114:	83 ec 0c             	sub    $0xc,%esp
80105117:	53                   	push   %ebx
80105118:	e8 83 c7 ff ff       	call   801018a0 <ilock>
  ip->nlink--;
8010511d:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80105122:	89 1c 24             	mov    %ebx,(%esp)
80105125:	e8 c6 c6 ff ff       	call   801017f0 <iupdate>
  iunlockput(ip);
8010512a:	89 1c 24             	mov    %ebx,(%esp)
8010512d:	e8 fe c9 ff ff       	call   80101b30 <iunlockput>
  end_op();
80105132:	e8 b9 dd ff ff       	call   80102ef0 <end_op>
  return -1;
80105137:	83 c4 10             	add    $0x10,%esp
8010513a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010513f:	eb b9                	jmp    801050fa <sys_link+0xda>
    iunlockput(ip);
80105141:	83 ec 0c             	sub    $0xc,%esp
80105144:	53                   	push   %ebx
80105145:	e8 e6 c9 ff ff       	call   80101b30 <iunlockput>
    end_op();
8010514a:	e8 a1 dd ff ff       	call   80102ef0 <end_op>
    return -1;
8010514f:	83 c4 10             	add    $0x10,%esp
80105152:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105157:	eb a1                	jmp    801050fa <sys_link+0xda>
    end_op();
80105159:	e8 92 dd ff ff       	call   80102ef0 <end_op>
    return -1;
8010515e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105163:	eb 95                	jmp    801050fa <sys_link+0xda>
80105165:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010516c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105170 <sys_unlink>:
{
80105170:	55                   	push   %ebp
80105171:	89 e5                	mov    %esp,%ebp
80105173:	57                   	push   %edi
80105174:	56                   	push   %esi
  if(argstr(0, &path) < 0)
80105175:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
80105178:	53                   	push   %ebx
80105179:	83 ec 54             	sub    $0x54,%esp
  if(argstr(0, &path) < 0)
8010517c:	50                   	push   %eax
8010517d:	6a 00                	push   $0x0
8010517f:	e8 bc f9 ff ff       	call   80104b40 <argstr>
80105184:	83 c4 10             	add    $0x10,%esp
80105187:	85 c0                	test   %eax,%eax
80105189:	0f 88 7a 01 00 00    	js     80105309 <sys_unlink+0x199>
  begin_op();
8010518f:	e8 ec dc ff ff       	call   80102e80 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105194:	8d 5d ca             	lea    -0x36(%ebp),%ebx
80105197:	83 ec 08             	sub    $0x8,%esp
8010519a:	53                   	push   %ebx
8010519b:	ff 75 c0             	push   -0x40(%ebp)
8010519e:	e8 3d d0 ff ff       	call   801021e0 <nameiparent>
801051a3:	83 c4 10             	add    $0x10,%esp
801051a6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
801051a9:	85 c0                	test   %eax,%eax
801051ab:	0f 84 62 01 00 00    	je     80105313 <sys_unlink+0x1a3>
  ilock(dp);
801051b1:	8b 7d b4             	mov    -0x4c(%ebp),%edi
801051b4:	83 ec 0c             	sub    $0xc,%esp
801051b7:	57                   	push   %edi
801051b8:	e8 e3 c6 ff ff       	call   801018a0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801051bd:	58                   	pop    %eax
801051be:	5a                   	pop    %edx
801051bf:	68 3c 7b 10 80       	push   $0x80107b3c
801051c4:	53                   	push   %ebx
801051c5:	e8 16 cc ff ff       	call   80101de0 <namecmp>
801051ca:	83 c4 10             	add    $0x10,%esp
801051cd:	85 c0                	test   %eax,%eax
801051cf:	0f 84 fb 00 00 00    	je     801052d0 <sys_unlink+0x160>
801051d5:	83 ec 08             	sub    $0x8,%esp
801051d8:	68 3b 7b 10 80       	push   $0x80107b3b
801051dd:	53                   	push   %ebx
801051de:	e8 fd cb ff ff       	call   80101de0 <namecmp>
801051e3:	83 c4 10             	add    $0x10,%esp
801051e6:	85 c0                	test   %eax,%eax
801051e8:	0f 84 e2 00 00 00    	je     801052d0 <sys_unlink+0x160>
  if((ip = dirlookup(dp, name, &off)) == 0)
801051ee:	83 ec 04             	sub    $0x4,%esp
801051f1:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801051f4:	50                   	push   %eax
801051f5:	53                   	push   %ebx
801051f6:	57                   	push   %edi
801051f7:	e8 04 cc ff ff       	call   80101e00 <dirlookup>
801051fc:	83 c4 10             	add    $0x10,%esp
801051ff:	89 c3                	mov    %eax,%ebx
80105201:	85 c0                	test   %eax,%eax
80105203:	0f 84 c7 00 00 00    	je     801052d0 <sys_unlink+0x160>
  ilock(ip);
80105209:	83 ec 0c             	sub    $0xc,%esp
8010520c:	50                   	push   %eax
8010520d:	e8 8e c6 ff ff       	call   801018a0 <ilock>
  if(ip->nlink < 1)
80105212:	83 c4 10             	add    $0x10,%esp
80105215:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010521a:	0f 8e 1c 01 00 00    	jle    8010533c <sys_unlink+0x1cc>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105220:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105225:	8d 7d d8             	lea    -0x28(%ebp),%edi
80105228:	74 66                	je     80105290 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
8010522a:	83 ec 04             	sub    $0x4,%esp
8010522d:	6a 10                	push   $0x10
8010522f:	6a 00                	push   $0x0
80105231:	57                   	push   %edi
80105232:	e8 89 f5 ff ff       	call   801047c0 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105237:	6a 10                	push   $0x10
80105239:	ff 75 c4             	push   -0x3c(%ebp)
8010523c:	57                   	push   %edi
8010523d:	ff 75 b4             	push   -0x4c(%ebp)
80105240:	e8 6b ca ff ff       	call   80101cb0 <writei>
80105245:	83 c4 20             	add    $0x20,%esp
80105248:	83 f8 10             	cmp    $0x10,%eax
8010524b:	0f 85 de 00 00 00    	jne    8010532f <sys_unlink+0x1bf>
  if(ip->type == T_DIR){
80105251:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105256:	0f 84 94 00 00 00    	je     801052f0 <sys_unlink+0x180>
  iunlockput(dp);
8010525c:	83 ec 0c             	sub    $0xc,%esp
8010525f:	ff 75 b4             	push   -0x4c(%ebp)
80105262:	e8 c9 c8 ff ff       	call   80101b30 <iunlockput>
  ip->nlink--;
80105267:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
8010526c:	89 1c 24             	mov    %ebx,(%esp)
8010526f:	e8 7c c5 ff ff       	call   801017f0 <iupdate>
  iunlockput(ip);
80105274:	89 1c 24             	mov    %ebx,(%esp)
80105277:	e8 b4 c8 ff ff       	call   80101b30 <iunlockput>
  end_op();
8010527c:	e8 6f dc ff ff       	call   80102ef0 <end_op>
  return 0;
80105281:	83 c4 10             	add    $0x10,%esp
80105284:	31 c0                	xor    %eax,%eax
}
80105286:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105289:	5b                   	pop    %ebx
8010528a:	5e                   	pop    %esi
8010528b:	5f                   	pop    %edi
8010528c:	5d                   	pop    %ebp
8010528d:	c3                   	ret    
8010528e:	66 90                	xchg   %ax,%ax
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105290:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
80105294:	76 94                	jbe    8010522a <sys_unlink+0xba>
80105296:	be 20 00 00 00       	mov    $0x20,%esi
8010529b:	eb 0b                	jmp    801052a8 <sys_unlink+0x138>
8010529d:	8d 76 00             	lea    0x0(%esi),%esi
801052a0:	83 c6 10             	add    $0x10,%esi
801052a3:	3b 73 58             	cmp    0x58(%ebx),%esi
801052a6:	73 82                	jae    8010522a <sys_unlink+0xba>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801052a8:	6a 10                	push   $0x10
801052aa:	56                   	push   %esi
801052ab:	57                   	push   %edi
801052ac:	53                   	push   %ebx
801052ad:	e8 fe c8 ff ff       	call   80101bb0 <readi>
801052b2:	83 c4 10             	add    $0x10,%esp
801052b5:	83 f8 10             	cmp    $0x10,%eax
801052b8:	75 68                	jne    80105322 <sys_unlink+0x1b2>
    if(de.inum != 0)
801052ba:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801052bf:	74 df                	je     801052a0 <sys_unlink+0x130>
    iunlockput(ip);
801052c1:	83 ec 0c             	sub    $0xc,%esp
801052c4:	53                   	push   %ebx
801052c5:	e8 66 c8 ff ff       	call   80101b30 <iunlockput>
    goto bad;
801052ca:	83 c4 10             	add    $0x10,%esp
801052cd:	8d 76 00             	lea    0x0(%esi),%esi
  iunlockput(dp);
801052d0:	83 ec 0c             	sub    $0xc,%esp
801052d3:	ff 75 b4             	push   -0x4c(%ebp)
801052d6:	e8 55 c8 ff ff       	call   80101b30 <iunlockput>
  end_op();
801052db:	e8 10 dc ff ff       	call   80102ef0 <end_op>
  return -1;
801052e0:	83 c4 10             	add    $0x10,%esp
801052e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052e8:	eb 9c                	jmp    80105286 <sys_unlink+0x116>
801052ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    dp->nlink--;
801052f0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
    iupdate(dp);
801052f3:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink--;
801052f6:	66 83 68 56 01       	subw   $0x1,0x56(%eax)
    iupdate(dp);
801052fb:	50                   	push   %eax
801052fc:	e8 ef c4 ff ff       	call   801017f0 <iupdate>
80105301:	83 c4 10             	add    $0x10,%esp
80105304:	e9 53 ff ff ff       	jmp    8010525c <sys_unlink+0xec>
    return -1;
80105309:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010530e:	e9 73 ff ff ff       	jmp    80105286 <sys_unlink+0x116>
    end_op();
80105313:	e8 d8 db ff ff       	call   80102ef0 <end_op>
    return -1;
80105318:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010531d:	e9 64 ff ff ff       	jmp    80105286 <sys_unlink+0x116>
      panic("isdirempty: readi");
80105322:	83 ec 0c             	sub    $0xc,%esp
80105325:	68 60 7b 10 80       	push   $0x80107b60
8010532a:	e8 51 b0 ff ff       	call   80100380 <panic>
    panic("unlink: writei");
8010532f:	83 ec 0c             	sub    $0xc,%esp
80105332:	68 72 7b 10 80       	push   $0x80107b72
80105337:	e8 44 b0 ff ff       	call   80100380 <panic>
    panic("unlink: nlink < 1");
8010533c:	83 ec 0c             	sub    $0xc,%esp
8010533f:	68 4e 7b 10 80       	push   $0x80107b4e
80105344:	e8 37 b0 ff ff       	call   80100380 <panic>
80105349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105350 <sys_open>:

int
sys_open(void)
{
80105350:	55                   	push   %ebp
80105351:	89 e5                	mov    %esp,%ebp
80105353:	57                   	push   %edi
80105354:	56                   	push   %esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105355:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
80105358:	53                   	push   %ebx
80105359:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010535c:	50                   	push   %eax
8010535d:	6a 00                	push   $0x0
8010535f:	e8 dc f7 ff ff       	call   80104b40 <argstr>
80105364:	83 c4 10             	add    $0x10,%esp
80105367:	85 c0                	test   %eax,%eax
80105369:	0f 88 8e 00 00 00    	js     801053fd <sys_open+0xad>
8010536f:	83 ec 08             	sub    $0x8,%esp
80105372:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105375:	50                   	push   %eax
80105376:	6a 01                	push   $0x1
80105378:	e8 03 f7 ff ff       	call   80104a80 <argint>
8010537d:	83 c4 10             	add    $0x10,%esp
80105380:	85 c0                	test   %eax,%eax
80105382:	78 79                	js     801053fd <sys_open+0xad>
    return -1;

  begin_op();
80105384:	e8 f7 da ff ff       	call   80102e80 <begin_op>

  if(omode & O_CREATE){
80105389:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
8010538d:	75 79                	jne    80105408 <sys_open+0xb8>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
8010538f:	83 ec 0c             	sub    $0xc,%esp
80105392:	ff 75 e0             	push   -0x20(%ebp)
80105395:	e8 26 ce ff ff       	call   801021c0 <namei>
8010539a:	83 c4 10             	add    $0x10,%esp
8010539d:	89 c6                	mov    %eax,%esi
8010539f:	85 c0                	test   %eax,%eax
801053a1:	0f 84 7e 00 00 00    	je     80105425 <sys_open+0xd5>
      end_op();
      return -1;
    }
    ilock(ip);
801053a7:	83 ec 0c             	sub    $0xc,%esp
801053aa:	50                   	push   %eax
801053ab:	e8 f0 c4 ff ff       	call   801018a0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801053b0:	83 c4 10             	add    $0x10,%esp
801053b3:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801053b8:	0f 84 c2 00 00 00    	je     80105480 <sys_open+0x130>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801053be:	e8 8d bb ff ff       	call   80100f50 <filealloc>
801053c3:	89 c7                	mov    %eax,%edi
801053c5:	85 c0                	test   %eax,%eax
801053c7:	74 23                	je     801053ec <sys_open+0x9c>
  struct proc *curproc = myproc();
801053c9:	e8 02 e7 ff ff       	call   80103ad0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
801053ce:	31 db                	xor    %ebx,%ebx
    if(curproc->ofile[fd] == 0){
801053d0:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
801053d4:	85 d2                	test   %edx,%edx
801053d6:	74 60                	je     80105438 <sys_open+0xe8>
  for(fd = 0; fd < NOFILE; fd++){
801053d8:	83 c3 01             	add    $0x1,%ebx
801053db:	83 fb 10             	cmp    $0x10,%ebx
801053de:	75 f0                	jne    801053d0 <sys_open+0x80>
    if(f)
      fileclose(f);
801053e0:	83 ec 0c             	sub    $0xc,%esp
801053e3:	57                   	push   %edi
801053e4:	e8 27 bc ff ff       	call   80101010 <fileclose>
801053e9:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801053ec:	83 ec 0c             	sub    $0xc,%esp
801053ef:	56                   	push   %esi
801053f0:	e8 3b c7 ff ff       	call   80101b30 <iunlockput>
    end_op();
801053f5:	e8 f6 da ff ff       	call   80102ef0 <end_op>
    return -1;
801053fa:	83 c4 10             	add    $0x10,%esp
801053fd:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105402:	eb 6d                	jmp    80105471 <sys_open+0x121>
80105404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ip = create(path, T_FILE, 0, 0);
80105408:	83 ec 0c             	sub    $0xc,%esp
8010540b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010540e:	31 c9                	xor    %ecx,%ecx
80105410:	ba 02 00 00 00       	mov    $0x2,%edx
80105415:	6a 00                	push   $0x0
80105417:	e8 14 f8 ff ff       	call   80104c30 <create>
    if(ip == 0){
8010541c:	83 c4 10             	add    $0x10,%esp
    ip = create(path, T_FILE, 0, 0);
8010541f:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80105421:	85 c0                	test   %eax,%eax
80105423:	75 99                	jne    801053be <sys_open+0x6e>
      end_op();
80105425:	e8 c6 da ff ff       	call   80102ef0 <end_op>
      return -1;
8010542a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010542f:	eb 40                	jmp    80105471 <sys_open+0x121>
80105431:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }
  iunlock(ip);
80105438:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
8010543b:	89 7c 98 28          	mov    %edi,0x28(%eax,%ebx,4)
  iunlock(ip);
8010543f:	56                   	push   %esi
80105440:	e8 3b c5 ff ff       	call   80101980 <iunlock>
  end_op();
80105445:	e8 a6 da ff ff       	call   80102ef0 <end_op>

  f->type = FD_INODE;
8010544a:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
80105450:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105453:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
80105456:	89 77 10             	mov    %esi,0x10(%edi)
  f->readable = !(omode & O_WRONLY);
80105459:	89 d0                	mov    %edx,%eax
  f->off = 0;
8010545b:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
80105462:	f7 d0                	not    %eax
80105464:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105467:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
8010546a:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010546d:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
80105471:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105474:	89 d8                	mov    %ebx,%eax
80105476:	5b                   	pop    %ebx
80105477:	5e                   	pop    %esi
80105478:	5f                   	pop    %edi
80105479:	5d                   	pop    %ebp
8010547a:	c3                   	ret    
8010547b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010547f:	90                   	nop
    if(ip->type == T_DIR && omode != O_RDONLY){
80105480:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105483:	85 c9                	test   %ecx,%ecx
80105485:	0f 84 33 ff ff ff    	je     801053be <sys_open+0x6e>
8010548b:	e9 5c ff ff ff       	jmp    801053ec <sys_open+0x9c>

80105490 <sys_mkdir>:

int
sys_mkdir(void)
{
80105490:	55                   	push   %ebp
80105491:	89 e5                	mov    %esp,%ebp
80105493:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105496:	e8 e5 d9 ff ff       	call   80102e80 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010549b:	83 ec 08             	sub    $0x8,%esp
8010549e:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054a1:	50                   	push   %eax
801054a2:	6a 00                	push   $0x0
801054a4:	e8 97 f6 ff ff       	call   80104b40 <argstr>
801054a9:	83 c4 10             	add    $0x10,%esp
801054ac:	85 c0                	test   %eax,%eax
801054ae:	78 30                	js     801054e0 <sys_mkdir+0x50>
801054b0:	83 ec 0c             	sub    $0xc,%esp
801054b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b6:	31 c9                	xor    %ecx,%ecx
801054b8:	ba 01 00 00 00       	mov    $0x1,%edx
801054bd:	6a 00                	push   $0x0
801054bf:	e8 6c f7 ff ff       	call   80104c30 <create>
801054c4:	83 c4 10             	add    $0x10,%esp
801054c7:	85 c0                	test   %eax,%eax
801054c9:	74 15                	je     801054e0 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
801054cb:	83 ec 0c             	sub    $0xc,%esp
801054ce:	50                   	push   %eax
801054cf:	e8 5c c6 ff ff       	call   80101b30 <iunlockput>
  end_op();
801054d4:	e8 17 da ff ff       	call   80102ef0 <end_op>
  return 0;
801054d9:	83 c4 10             	add    $0x10,%esp
801054dc:	31 c0                	xor    %eax,%eax
}
801054de:	c9                   	leave  
801054df:	c3                   	ret    
    end_op();
801054e0:	e8 0b da ff ff       	call   80102ef0 <end_op>
    return -1;
801054e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054ea:	c9                   	leave  
801054eb:	c3                   	ret    
801054ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801054f0 <sys_mknod>:

int
sys_mknod(void)
{
801054f0:	55                   	push   %ebp
801054f1:	89 e5                	mov    %esp,%ebp
801054f3:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801054f6:	e8 85 d9 ff ff       	call   80102e80 <begin_op>
  if((argstr(0, &path)) < 0 ||
801054fb:	83 ec 08             	sub    $0x8,%esp
801054fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105501:	50                   	push   %eax
80105502:	6a 00                	push   $0x0
80105504:	e8 37 f6 ff ff       	call   80104b40 <argstr>
80105509:	83 c4 10             	add    $0x10,%esp
8010550c:	85 c0                	test   %eax,%eax
8010550e:	78 60                	js     80105570 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105510:	83 ec 08             	sub    $0x8,%esp
80105513:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105516:	50                   	push   %eax
80105517:	6a 01                	push   $0x1
80105519:	e8 62 f5 ff ff       	call   80104a80 <argint>
  if((argstr(0, &path)) < 0 ||
8010551e:	83 c4 10             	add    $0x10,%esp
80105521:	85 c0                	test   %eax,%eax
80105523:	78 4b                	js     80105570 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
80105525:	83 ec 08             	sub    $0x8,%esp
80105528:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010552b:	50                   	push   %eax
8010552c:	6a 02                	push   $0x2
8010552e:	e8 4d f5 ff ff       	call   80104a80 <argint>
     argint(1, &major) < 0 ||
80105533:	83 c4 10             	add    $0x10,%esp
80105536:	85 c0                	test   %eax,%eax
80105538:	78 36                	js     80105570 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010553a:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
8010553e:	83 ec 0c             	sub    $0xc,%esp
80105541:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80105545:	ba 03 00 00 00       	mov    $0x3,%edx
8010554a:	50                   	push   %eax
8010554b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010554e:	e8 dd f6 ff ff       	call   80104c30 <create>
     argint(2, &minor) < 0 ||
80105553:	83 c4 10             	add    $0x10,%esp
80105556:	85 c0                	test   %eax,%eax
80105558:	74 16                	je     80105570 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010555a:	83 ec 0c             	sub    $0xc,%esp
8010555d:	50                   	push   %eax
8010555e:	e8 cd c5 ff ff       	call   80101b30 <iunlockput>
  end_op();
80105563:	e8 88 d9 ff ff       	call   80102ef0 <end_op>
  return 0;
80105568:	83 c4 10             	add    $0x10,%esp
8010556b:	31 c0                	xor    %eax,%eax
}
8010556d:	c9                   	leave  
8010556e:	c3                   	ret    
8010556f:	90                   	nop
    end_op();
80105570:	e8 7b d9 ff ff       	call   80102ef0 <end_op>
    return -1;
80105575:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010557a:	c9                   	leave  
8010557b:	c3                   	ret    
8010557c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105580 <sys_chdir>:

int
sys_chdir(void)
{
80105580:	55                   	push   %ebp
80105581:	89 e5                	mov    %esp,%ebp
80105583:	56                   	push   %esi
80105584:	53                   	push   %ebx
80105585:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105588:	e8 43 e5 ff ff       	call   80103ad0 <myproc>
8010558d:	89 c6                	mov    %eax,%esi
  
  begin_op();
8010558f:	e8 ec d8 ff ff       	call   80102e80 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105594:	83 ec 08             	sub    $0x8,%esp
80105597:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010559a:	50                   	push   %eax
8010559b:	6a 00                	push   $0x0
8010559d:	e8 9e f5 ff ff       	call   80104b40 <argstr>
801055a2:	83 c4 10             	add    $0x10,%esp
801055a5:	85 c0                	test   %eax,%eax
801055a7:	78 77                	js     80105620 <sys_chdir+0xa0>
801055a9:	83 ec 0c             	sub    $0xc,%esp
801055ac:	ff 75 f4             	push   -0xc(%ebp)
801055af:	e8 0c cc ff ff       	call   801021c0 <namei>
801055b4:	83 c4 10             	add    $0x10,%esp
801055b7:	89 c3                	mov    %eax,%ebx
801055b9:	85 c0                	test   %eax,%eax
801055bb:	74 63                	je     80105620 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
801055bd:	83 ec 0c             	sub    $0xc,%esp
801055c0:	50                   	push   %eax
801055c1:	e8 da c2 ff ff       	call   801018a0 <ilock>
  if(ip->type != T_DIR){
801055c6:	83 c4 10             	add    $0x10,%esp
801055c9:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801055ce:	75 30                	jne    80105600 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801055d0:	83 ec 0c             	sub    $0xc,%esp
801055d3:	53                   	push   %ebx
801055d4:	e8 a7 c3 ff ff       	call   80101980 <iunlock>
  iput(curproc->cwd);
801055d9:	58                   	pop    %eax
801055da:	ff 76 68             	push   0x68(%esi)
801055dd:	e8 ee c3 ff ff       	call   801019d0 <iput>
  end_op();
801055e2:	e8 09 d9 ff ff       	call   80102ef0 <end_op>
  curproc->cwd = ip;
801055e7:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
801055ea:	83 c4 10             	add    $0x10,%esp
801055ed:	31 c0                	xor    %eax,%eax
}
801055ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
801055f2:	5b                   	pop    %ebx
801055f3:	5e                   	pop    %esi
801055f4:	5d                   	pop    %ebp
801055f5:	c3                   	ret    
801055f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801055fd:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80105600:	83 ec 0c             	sub    $0xc,%esp
80105603:	53                   	push   %ebx
80105604:	e8 27 c5 ff ff       	call   80101b30 <iunlockput>
    end_op();
80105609:	e8 e2 d8 ff ff       	call   80102ef0 <end_op>
    return -1;
8010560e:	83 c4 10             	add    $0x10,%esp
80105611:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105616:	eb d7                	jmp    801055ef <sys_chdir+0x6f>
80105618:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010561f:	90                   	nop
    end_op();
80105620:	e8 cb d8 ff ff       	call   80102ef0 <end_op>
    return -1;
80105625:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010562a:	eb c3                	jmp    801055ef <sys_chdir+0x6f>
8010562c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105630 <sys_exec>:

int
sys_exec(void)
{
80105630:	55                   	push   %ebp
80105631:	89 e5                	mov    %esp,%ebp
80105633:	57                   	push   %edi
80105634:	56                   	push   %esi
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105635:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
8010563b:	53                   	push   %ebx
8010563c:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105642:	50                   	push   %eax
80105643:	6a 00                	push   $0x0
80105645:	e8 f6 f4 ff ff       	call   80104b40 <argstr>
8010564a:	83 c4 10             	add    $0x10,%esp
8010564d:	85 c0                	test   %eax,%eax
8010564f:	0f 88 87 00 00 00    	js     801056dc <sys_exec+0xac>
80105655:	83 ec 08             	sub    $0x8,%esp
80105658:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
8010565e:	50                   	push   %eax
8010565f:	6a 01                	push   $0x1
80105661:	e8 1a f4 ff ff       	call   80104a80 <argint>
80105666:	83 c4 10             	add    $0x10,%esp
80105669:	85 c0                	test   %eax,%eax
8010566b:	78 6f                	js     801056dc <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
8010566d:	83 ec 04             	sub    $0x4,%esp
80105670:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  for(i=0;; i++){
80105676:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80105678:	68 80 00 00 00       	push   $0x80
8010567d:	6a 00                	push   $0x0
8010567f:	56                   	push   %esi
80105680:	e8 3b f1 ff ff       	call   801047c0 <memset>
80105685:	83 c4 10             	add    $0x10,%esp
80105688:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010568f:	90                   	nop
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105690:	83 ec 08             	sub    $0x8,%esp
80105693:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80105699:	8d 3c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edi
801056a0:	50                   	push   %eax
801056a1:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
801056a7:	01 f8                	add    %edi,%eax
801056a9:	50                   	push   %eax
801056aa:	e8 41 f3 ff ff       	call   801049f0 <fetchint>
801056af:	83 c4 10             	add    $0x10,%esp
801056b2:	85 c0                	test   %eax,%eax
801056b4:	78 26                	js     801056dc <sys_exec+0xac>
      return -1;
    if(uarg == 0){
801056b6:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
801056bc:	85 c0                	test   %eax,%eax
801056be:	74 30                	je     801056f0 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801056c0:	83 ec 08             	sub    $0x8,%esp
801056c3:	8d 14 3e             	lea    (%esi,%edi,1),%edx
801056c6:	52                   	push   %edx
801056c7:	50                   	push   %eax
801056c8:	e8 63 f3 ff ff       	call   80104a30 <fetchstr>
801056cd:	83 c4 10             	add    $0x10,%esp
801056d0:	85 c0                	test   %eax,%eax
801056d2:	78 08                	js     801056dc <sys_exec+0xac>
  for(i=0;; i++){
801056d4:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
801056d7:	83 fb 20             	cmp    $0x20,%ebx
801056da:	75 b4                	jne    80105690 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
801056dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
801056df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056e4:	5b                   	pop    %ebx
801056e5:	5e                   	pop    %esi
801056e6:	5f                   	pop    %edi
801056e7:	5d                   	pop    %ebp
801056e8:	c3                   	ret    
801056e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      argv[i] = 0;
801056f0:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
801056f7:	00 00 00 00 
  return exec(path, argv);
801056fb:	83 ec 08             	sub    $0x8,%esp
801056fe:	56                   	push   %esi
801056ff:	ff b5 5c ff ff ff    	push   -0xa4(%ebp)
80105705:	e8 c6 b4 ff ff       	call   80100bd0 <exec>
8010570a:	83 c4 10             	add    $0x10,%esp
}
8010570d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105710:	5b                   	pop    %ebx
80105711:	5e                   	pop    %esi
80105712:	5f                   	pop    %edi
80105713:	5d                   	pop    %ebp
80105714:	c3                   	ret    
80105715:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010571c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105720 <sys_pipe>:

int
sys_pipe(void)
{
80105720:	55                   	push   %ebp
80105721:	89 e5                	mov    %esp,%ebp
80105723:	57                   	push   %edi
80105724:	56                   	push   %esi
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105725:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105728:	53                   	push   %ebx
80105729:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010572c:	6a 08                	push   $0x8
8010572e:	50                   	push   %eax
8010572f:	6a 00                	push   $0x0
80105731:	e8 9a f3 ff ff       	call   80104ad0 <argptr>
80105736:	83 c4 10             	add    $0x10,%esp
80105739:	85 c0                	test   %eax,%eax
8010573b:	78 4a                	js     80105787 <sys_pipe+0x67>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
8010573d:	83 ec 08             	sub    $0x8,%esp
80105740:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105743:	50                   	push   %eax
80105744:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105747:	50                   	push   %eax
80105748:	e8 03 de ff ff       	call   80103550 <pipealloc>
8010574d:	83 c4 10             	add    $0x10,%esp
80105750:	85 c0                	test   %eax,%eax
80105752:	78 33                	js     80105787 <sys_pipe+0x67>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105754:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
80105757:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
80105759:	e8 72 e3 ff ff       	call   80103ad0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010575e:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80105760:	8b 74 98 28          	mov    0x28(%eax,%ebx,4),%esi
80105764:	85 f6                	test   %esi,%esi
80105766:	74 28                	je     80105790 <sys_pipe+0x70>
  for(fd = 0; fd < NOFILE; fd++){
80105768:	83 c3 01             	add    $0x1,%ebx
8010576b:	83 fb 10             	cmp    $0x10,%ebx
8010576e:	75 f0                	jne    80105760 <sys_pipe+0x40>
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
80105770:	83 ec 0c             	sub    $0xc,%esp
80105773:	ff 75 e0             	push   -0x20(%ebp)
80105776:	e8 95 b8 ff ff       	call   80101010 <fileclose>
    fileclose(wf);
8010577b:	58                   	pop    %eax
8010577c:	ff 75 e4             	push   -0x1c(%ebp)
8010577f:	e8 8c b8 ff ff       	call   80101010 <fileclose>
    return -1;
80105784:	83 c4 10             	add    $0x10,%esp
80105787:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010578c:	eb 53                	jmp    801057e1 <sys_pipe+0xc1>
8010578e:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105790:	8d 73 08             	lea    0x8(%ebx),%esi
80105793:	89 7c b0 08          	mov    %edi,0x8(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105797:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
8010579a:	e8 31 e3 ff ff       	call   80103ad0 <myproc>
8010579f:	89 c2                	mov    %eax,%edx
  for(fd = 0; fd < NOFILE; fd++){
801057a1:	31 c0                	xor    %eax,%eax
801057a3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801057a7:	90                   	nop
    if(curproc->ofile[fd] == 0){
801057a8:	8b 4c 82 28          	mov    0x28(%edx,%eax,4),%ecx
801057ac:	85 c9                	test   %ecx,%ecx
801057ae:	74 20                	je     801057d0 <sys_pipe+0xb0>
  for(fd = 0; fd < NOFILE; fd++){
801057b0:	83 c0 01             	add    $0x1,%eax
801057b3:	83 f8 10             	cmp    $0x10,%eax
801057b6:	75 f0                	jne    801057a8 <sys_pipe+0x88>
      myproc()->ofile[fd0] = 0;
801057b8:	e8 13 e3 ff ff       	call   80103ad0 <myproc>
801057bd:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
801057c4:	00 
801057c5:	eb a9                	jmp    80105770 <sys_pipe+0x50>
801057c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801057ce:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
801057d0:	89 7c 82 28          	mov    %edi,0x28(%edx,%eax,4)
  }
  fd[0] = fd0;
801057d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801057d7:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
801057d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
801057dc:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
801057df:	31 c0                	xor    %eax,%eax
}
801057e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801057e4:	5b                   	pop    %ebx
801057e5:	5e                   	pop    %esi
801057e6:	5f                   	pop    %edi
801057e7:	5d                   	pop    %ebp
801057e8:	c3                   	ret    
801057e9:	66 90                	xchg   %ax,%ax
801057eb:	66 90                	xchg   %ax,%ax
801057ed:	66 90                	xchg   %ax,%ax
801057ef:	90                   	nop

801057f0 <sys_fork>:
#include "proc.h"

int
sys_fork(void)
{
  return fork();
801057f0:	e9 7b e4 ff ff       	jmp    80103c70 <fork>
801057f5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801057fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105800 <sys_exit>:
}

int
sys_exit(void)
{
80105800:	55                   	push   %ebp
80105801:	89 e5                	mov    %esp,%ebp
80105803:	83 ec 08             	sub    $0x8,%esp
  exit();
80105806:	e8 e5 e6 ff ff       	call   80103ef0 <exit>
  return 0;  // not reached
}
8010580b:	31 c0                	xor    %eax,%eax
8010580d:	c9                   	leave  
8010580e:	c3                   	ret    
8010580f:	90                   	nop

80105810 <sys_wait>:

int
sys_wait(void)
{
  return wait();
80105810:	e9 0b e8 ff ff       	jmp    80104020 <wait>
80105815:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010581c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105820 <sys_kill>:
}

int
sys_kill(void)
{
80105820:	55                   	push   %ebp
80105821:	89 e5                	mov    %esp,%ebp
80105823:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105826:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105829:	50                   	push   %eax
8010582a:	6a 00                	push   $0x0
8010582c:	e8 4f f2 ff ff       	call   80104a80 <argint>
80105831:	83 c4 10             	add    $0x10,%esp
80105834:	85 c0                	test   %eax,%eax
80105836:	78 18                	js     80105850 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105838:	83 ec 0c             	sub    $0xc,%esp
8010583b:	ff 75 f4             	push   -0xc(%ebp)
8010583e:	e8 7d ea ff ff       	call   801042c0 <kill>
80105843:	83 c4 10             	add    $0x10,%esp
}
80105846:	c9                   	leave  
80105847:	c3                   	ret    
80105848:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010584f:	90                   	nop
80105850:	c9                   	leave  
    return -1;
80105851:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105856:	c3                   	ret    
80105857:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010585e:	66 90                	xchg   %ax,%ax

80105860 <sys_getpid>:

int
sys_getpid(void)
{
80105860:	55                   	push   %ebp
80105861:	89 e5                	mov    %esp,%ebp
80105863:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105866:	e8 65 e2 ff ff       	call   80103ad0 <myproc>
8010586b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010586e:	c9                   	leave  
8010586f:	c3                   	ret    

80105870 <sys_sbrk>:

int
sys_sbrk(void)
{
80105870:	55                   	push   %ebp
80105871:	89 e5                	mov    %esp,%ebp
80105873:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105874:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105877:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
8010587a:	50                   	push   %eax
8010587b:	6a 00                	push   $0x0
8010587d:	e8 fe f1 ff ff       	call   80104a80 <argint>
80105882:	83 c4 10             	add    $0x10,%esp
80105885:	85 c0                	test   %eax,%eax
80105887:	78 27                	js     801058b0 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80105889:	e8 42 e2 ff ff       	call   80103ad0 <myproc>
  //myproc()->sz += n;
  if(growproc(n) < 0)
8010588e:	83 ec 0c             	sub    $0xc,%esp
  addr = myproc()->sz;
80105891:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105893:	ff 75 f4             	push   -0xc(%ebp)
80105896:	e8 55 e3 ff ff       	call   80103bf0 <growproc>
8010589b:	83 c4 10             	add    $0x10,%esp
8010589e:	85 c0                	test   %eax,%eax
801058a0:	78 0e                	js     801058b0 <sys_sbrk+0x40>
    return -1;
  return addr;
}
801058a2:	89 d8                	mov    %ebx,%eax
801058a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801058a7:	c9                   	leave  
801058a8:	c3                   	ret    
801058a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
801058b0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801058b5:	eb eb                	jmp    801058a2 <sys_sbrk+0x32>
801058b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801058be:	66 90                	xchg   %ax,%ax

801058c0 <sys_sleep>:

int
sys_sleep(void)
{
801058c0:	55                   	push   %ebp
801058c1:	89 e5                	mov    %esp,%ebp
801058c3:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801058c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
801058c7:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
801058ca:	50                   	push   %eax
801058cb:	6a 00                	push   $0x0
801058cd:	e8 ae f1 ff ff       	call   80104a80 <argint>
801058d2:	83 c4 10             	add    $0x10,%esp
801058d5:	85 c0                	test   %eax,%eax
801058d7:	0f 88 8a 00 00 00    	js     80105967 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
801058dd:	83 ec 0c             	sub    $0xc,%esp
801058e0:	68 80 3f 11 80       	push   $0x80113f80
801058e5:	e8 16 ee ff ff       	call   80104700 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801058ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ticks0 = ticks;
801058ed:	8b 1d 60 3f 11 80    	mov    0x80113f60,%ebx
  while(ticks - ticks0 < n){
801058f3:	83 c4 10             	add    $0x10,%esp
801058f6:	85 d2                	test   %edx,%edx
801058f8:	75 27                	jne    80105921 <sys_sleep+0x61>
801058fa:	eb 54                	jmp    80105950 <sys_sleep+0x90>
801058fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105900:	83 ec 08             	sub    $0x8,%esp
80105903:	68 80 3f 11 80       	push   $0x80113f80
80105908:	68 60 3f 11 80       	push   $0x80113f60
8010590d:	e8 8e e8 ff ff       	call   801041a0 <sleep>
  while(ticks - ticks0 < n){
80105912:	a1 60 3f 11 80       	mov    0x80113f60,%eax
80105917:	83 c4 10             	add    $0x10,%esp
8010591a:	29 d8                	sub    %ebx,%eax
8010591c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010591f:	73 2f                	jae    80105950 <sys_sleep+0x90>
    if(myproc()->killed){
80105921:	e8 aa e1 ff ff       	call   80103ad0 <myproc>
80105926:	8b 40 24             	mov    0x24(%eax),%eax
80105929:	85 c0                	test   %eax,%eax
8010592b:	74 d3                	je     80105900 <sys_sleep+0x40>
      release(&tickslock);
8010592d:	83 ec 0c             	sub    $0xc,%esp
80105930:	68 80 3f 11 80       	push   $0x80113f80
80105935:	e8 66 ed ff ff       	call   801046a0 <release>
  }
  release(&tickslock);
  return 0;
}
8010593a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return -1;
8010593d:	83 c4 10             	add    $0x10,%esp
80105940:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105945:	c9                   	leave  
80105946:	c3                   	ret    
80105947:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010594e:	66 90                	xchg   %ax,%ax
  release(&tickslock);
80105950:	83 ec 0c             	sub    $0xc,%esp
80105953:	68 80 3f 11 80       	push   $0x80113f80
80105958:	e8 43 ed ff ff       	call   801046a0 <release>
  return 0;
8010595d:	83 c4 10             	add    $0x10,%esp
80105960:	31 c0                	xor    %eax,%eax
}
80105962:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105965:	c9                   	leave  
80105966:	c3                   	ret    
    return -1;
80105967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010596c:	eb f4                	jmp    80105962 <sys_sleep+0xa2>
8010596e:	66 90                	xchg   %ax,%ax

80105970 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105970:	55                   	push   %ebp
80105971:	89 e5                	mov    %esp,%ebp
80105973:	53                   	push   %ebx
80105974:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105977:	68 80 3f 11 80       	push   $0x80113f80
8010597c:	e8 7f ed ff ff       	call   80104700 <acquire>
  xticks = ticks;
80105981:	8b 1d 60 3f 11 80    	mov    0x80113f60,%ebx
  release(&tickslock);
80105987:	c7 04 24 80 3f 11 80 	movl   $0x80113f80,(%esp)
8010598e:	e8 0d ed ff ff       	call   801046a0 <release>
  return xticks;
}
80105993:	89 d8                	mov    %ebx,%eax
80105995:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105998:	c9                   	leave  
80105999:	c3                   	ret    
8010599a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801059a0 <sys_date>:

int 
sys_date(void)
{
801059a0:	55                   	push   %ebp
801059a1:	89 e5                	mov    %esp,%ebp
801059a3:	83 ec 1c             	sub    $0x1c,%esp
  struct rtcdate* r;

  if(argptr(0, (void*) &r, sizeof(*r)) < 0) {
801059a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059a9:	6a 18                	push   $0x18
801059ab:	50                   	push   %eax
801059ac:	6a 00                	push   $0x0
801059ae:	e8 1d f1 ff ff       	call   80104ad0 <argptr>
801059b3:	83 c4 10             	add    $0x10,%esp
801059b6:	85 c0                	test   %eax,%eax
801059b8:	78 16                	js     801059d0 <sys_date+0x30>
    return -1;
  }

  cmostime(r);
801059ba:	83 ec 0c             	sub    $0xc,%esp
801059bd:	ff 75 f4             	push   -0xc(%ebp)
801059c0:	e8 2b d1 ff ff       	call   80102af0 <cmostime>

  return 0;
801059c5:	83 c4 10             	add    $0x10,%esp
801059c8:	31 c0                	xor    %eax,%eax
}
801059ca:	c9                   	leave  
801059cb:	c3                   	ret    
801059cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801059d0:	c9                   	leave  
    return -1;
801059d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059d6:	c3                   	ret    
801059d7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801059de:	66 90                	xchg   %ax,%ax

801059e0 <sys_alarm>:

int
sys_alarm(void)
{
801059e0:	55                   	push   %ebp
801059e1:	89 e5                	mov    %esp,%ebp
801059e3:	83 ec 20             	sub    $0x20,%esp
  int ticks;
  void (*handler)();
  if(argint(0, &ticks) < 0)
801059e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059e9:	50                   	push   %eax
801059ea:	6a 00                	push   $0x0
801059ec:	e8 8f f0 ff ff       	call   80104a80 <argint>
801059f1:	83 c4 10             	add    $0x10,%esp
801059f4:	85 c0                	test   %eax,%eax
801059f6:	78 38                	js     80105a30 <sys_alarm+0x50>
    return -1;
  if(argptr(1, (char**)&handler, 1) < 0)
801059f8:	83 ec 04             	sub    $0x4,%esp
801059fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059fe:	6a 01                	push   $0x1
80105a00:	50                   	push   %eax
80105a01:	6a 01                	push   $0x1
80105a03:	e8 c8 f0 ff ff       	call   80104ad0 <argptr>
80105a08:	83 c4 10             	add    $0x10,%esp
80105a0b:	85 c0                	test   %eax,%eax
80105a0d:	78 21                	js     80105a30 <sys_alarm+0x50>
    return -1;
  myproc()->alarmticks = ticks;
80105a0f:	e8 bc e0 ff ff       	call   80103ad0 <myproc>
80105a14:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a17:	89 50 7c             	mov    %edx,0x7c(%eax)
  myproc()->alarmhandler = handler;
80105a1a:	e8 b1 e0 ff ff       	call   80103ad0 <myproc>
80105a1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a22:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
  return 0;
80105a28:	31 c0                	xor    %eax,%eax
}
80105a2a:	c9                   	leave  
80105a2b:	c3                   	ret    
80105a2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105a30:	c9                   	leave  
    return -1;
80105a31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a36:	c3                   	ret    

80105a37 <alltraps>:
80105a37:	1e                   	push   %ds
80105a38:	06                   	push   %es
80105a39:	0f a0                	push   %fs
80105a3b:	0f a8                	push   %gs
80105a3d:	60                   	pusha  
80105a3e:	66 b8 10 00          	mov    $0x10,%ax
80105a42:	8e d8                	mov    %eax,%ds
80105a44:	8e c0                	mov    %eax,%es
80105a46:	54                   	push   %esp
80105a47:	e8 c4 00 00 00       	call   80105b10 <trap>
80105a4c:	83 c4 04             	add    $0x4,%esp

80105a4f <trapret>:
80105a4f:	61                   	popa   
80105a50:	0f a9                	pop    %gs
80105a52:	0f a1                	pop    %fs
80105a54:	07                   	pop    %es
80105a55:	1f                   	pop    %ds
80105a56:	83 c4 08             	add    $0x8,%esp
80105a59:	cf                   	iret   
80105a5a:	66 90                	xchg   %ax,%ax
80105a5c:	66 90                	xchg   %ax,%ax
80105a5e:	66 90                	xchg   %ax,%ax

80105a60 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105a60:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80105a61:	31 c0                	xor    %eax,%eax
{
80105a63:	89 e5                	mov    %esp,%ebp
80105a65:	83 ec 08             	sub    $0x8,%esp
80105a68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a6f:	90                   	nop
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105a70:	8b 14 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%edx
80105a77:	c7 04 c5 c2 3f 11 80 	movl   $0x8e000008,-0x7feec03e(,%eax,8)
80105a7e:	08 00 00 8e 
80105a82:	66 89 14 c5 c0 3f 11 	mov    %dx,-0x7feec040(,%eax,8)
80105a89:	80 
80105a8a:	c1 ea 10             	shr    $0x10,%edx
80105a8d:	66 89 14 c5 c6 3f 11 	mov    %dx,-0x7feec03a(,%eax,8)
80105a94:	80 
  for(i = 0; i < 256; i++)
80105a95:	83 c0 01             	add    $0x1,%eax
80105a98:	3d 00 01 00 00       	cmp    $0x100,%eax
80105a9d:	75 d1                	jne    80105a70 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
80105a9f:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105aa2:	a1 08 a1 10 80       	mov    0x8010a108,%eax
80105aa7:	c7 05 c2 41 11 80 08 	movl   $0xef000008,0x801141c2
80105aae:	00 00 ef 
  initlock(&tickslock, "time");
80105ab1:	68 81 7b 10 80       	push   $0x80107b81
80105ab6:	68 80 3f 11 80       	push   $0x80113f80
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105abb:	66 a3 c0 41 11 80    	mov    %ax,0x801141c0
80105ac1:	c1 e8 10             	shr    $0x10,%eax
80105ac4:	66 a3 c6 41 11 80    	mov    %ax,0x801141c6
  initlock(&tickslock, "time");
80105aca:	e8 61 ea ff ff       	call   80104530 <initlock>
}
80105acf:	83 c4 10             	add    $0x10,%esp
80105ad2:	c9                   	leave  
80105ad3:	c3                   	ret    
80105ad4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105adb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105adf:	90                   	nop

80105ae0 <idtinit>:

void
idtinit(void)
{
80105ae0:	55                   	push   %ebp
  pd[0] = size-1;
80105ae1:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80105ae6:	89 e5                	mov    %esp,%ebp
80105ae8:	83 ec 10             	sub    $0x10,%esp
80105aeb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105aef:	b8 c0 3f 11 80       	mov    $0x80113fc0,%eax
80105af4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105af8:	c1 e8 10             	shr    $0x10,%eax
80105afb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105aff:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105b02:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105b05:	c9                   	leave  
80105b06:	c3                   	ret    
80105b07:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105b0e:	66 90                	xchg   %ax,%ax

80105b10 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105b10:	55                   	push   %ebp
80105b11:	89 e5                	mov    %esp,%ebp
80105b13:	57                   	push   %edi
80105b14:	56                   	push   %esi
80105b15:	53                   	push   %ebx
80105b16:	83 ec 1c             	sub    $0x1c,%esp
80105b19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105b1c:	8b 43 30             	mov    0x30(%ebx),%eax
80105b1f:	83 f8 40             	cmp    $0x40,%eax
80105b22:	0f 84 68 01 00 00    	je     80105c90 <trap+0x180>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105b28:	83 e8 20             	sub    $0x20,%eax
80105b2b:	83 f8 1f             	cmp    $0x1f,%eax
80105b2e:	0f 87 8c 00 00 00    	ja     80105bc0 <trap+0xb0>
80105b34:	ff 24 85 28 7c 10 80 	jmp    *-0x7fef83d8(,%eax,4)
80105b3b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105b3f:	90                   	nop
    }

    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80105b40:	e8 1b c8 ff ff       	call   80102360 <ideintr>
    lapiceoi();
80105b45:	e8 e6 ce ff ff       	call   80102a30 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105b4a:	e8 81 df ff ff       	call   80103ad0 <myproc>
80105b4f:	85 c0                	test   %eax,%eax
80105b51:	74 1d                	je     80105b70 <trap+0x60>
80105b53:	e8 78 df ff ff       	call   80103ad0 <myproc>
80105b58:	8b 50 24             	mov    0x24(%eax),%edx
80105b5b:	85 d2                	test   %edx,%edx
80105b5d:	74 11                	je     80105b70 <trap+0x60>
80105b5f:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105b63:	83 e0 03             	and    $0x3,%eax
80105b66:	66 83 f8 03          	cmp    $0x3,%ax
80105b6a:	0f 84 10 02 00 00    	je     80105d80 <trap+0x270>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105b70:	e8 5b df ff ff       	call   80103ad0 <myproc>
80105b75:	85 c0                	test   %eax,%eax
80105b77:	74 0f                	je     80105b88 <trap+0x78>
80105b79:	e8 52 df ff ff       	call   80103ad0 <myproc>
80105b7e:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105b82:	0f 84 b8 00 00 00    	je     80105c40 <trap+0x130>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105b88:	e8 43 df ff ff       	call   80103ad0 <myproc>
80105b8d:	85 c0                	test   %eax,%eax
80105b8f:	74 1d                	je     80105bae <trap+0x9e>
80105b91:	e8 3a df ff ff       	call   80103ad0 <myproc>
80105b96:	8b 40 24             	mov    0x24(%eax),%eax
80105b99:	85 c0                	test   %eax,%eax
80105b9b:	74 11                	je     80105bae <trap+0x9e>
80105b9d:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105ba1:	83 e0 03             	and    $0x3,%eax
80105ba4:	66 83 f8 03          	cmp    $0x3,%ax
80105ba8:	0f 84 0f 01 00 00    	je     80105cbd <trap+0x1ad>
    exit();
}
80105bae:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105bb1:	5b                   	pop    %ebx
80105bb2:	5e                   	pop    %esi
80105bb3:	5f                   	pop    %edi
80105bb4:	5d                   	pop    %ebp
80105bb5:	c3                   	ret    
80105bb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105bbd:	8d 76 00             	lea    0x0(%esi),%esi
    if(myproc() == 0 || (tf->cs&3) == 0){
80105bc0:	e8 0b df ff ff       	call   80103ad0 <myproc>
80105bc5:	8b 7b 38             	mov    0x38(%ebx),%edi
80105bc8:	85 c0                	test   %eax,%eax
80105bca:	0f 84 02 02 00 00    	je     80105dd2 <trap+0x2c2>
80105bd0:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105bd4:	0f 84 f8 01 00 00    	je     80105dd2 <trap+0x2c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105bda:	0f 20 d1             	mov    %cr2,%ecx
80105bdd:	89 4d d8             	mov    %ecx,-0x28(%ebp)
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105be0:	e8 cb de ff ff       	call   80103ab0 <cpuid>
80105be5:	8b 73 30             	mov    0x30(%ebx),%esi
80105be8:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105beb:	8b 43 34             	mov    0x34(%ebx),%eax
80105bee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            myproc()->pid, myproc()->name, tf->trapno,
80105bf1:	e8 da de ff ff       	call   80103ad0 <myproc>
80105bf6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105bf9:	e8 d2 de ff ff       	call   80103ad0 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105bfe:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105c01:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105c04:	51                   	push   %ecx
80105c05:	57                   	push   %edi
80105c06:	52                   	push   %edx
80105c07:	ff 75 e4             	push   -0x1c(%ebp)
80105c0a:	56                   	push   %esi
            myproc()->pid, myproc()->name, tf->trapno,
80105c0b:	8b 75 e0             	mov    -0x20(%ebp),%esi
80105c0e:	83 c6 6c             	add    $0x6c,%esi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105c11:	56                   	push   %esi
80105c12:	ff 70 10             	push   0x10(%eax)
80105c15:	68 e4 7b 10 80       	push   $0x80107be4
80105c1a:	e8 61 aa ff ff       	call   80100680 <cprintf>
    myproc()->killed = 1;
80105c1f:	83 c4 20             	add    $0x20,%esp
80105c22:	e8 a9 de ff ff       	call   80103ad0 <myproc>
80105c27:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105c2e:	e8 9d de ff ff       	call   80103ad0 <myproc>
80105c33:	85 c0                	test   %eax,%eax
80105c35:	0f 85 18 ff ff ff    	jne    80105b53 <trap+0x43>
80105c3b:	e9 30 ff ff ff       	jmp    80105b70 <trap+0x60>
  if(myproc() && myproc()->state == RUNNING &&
80105c40:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105c44:	0f 85 3e ff ff ff    	jne    80105b88 <trap+0x78>
    yield();
80105c4a:	e8 01 e5 ff ff       	call   80104150 <yield>
80105c4f:	e9 34 ff ff ff       	jmp    80105b88 <trap+0x78>
80105c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105c58:	8b 7b 38             	mov    0x38(%ebx),%edi
80105c5b:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
80105c5f:	e8 4c de ff ff       	call   80103ab0 <cpuid>
80105c64:	57                   	push   %edi
80105c65:	56                   	push   %esi
80105c66:	50                   	push   %eax
80105c67:	68 8c 7b 10 80       	push   $0x80107b8c
80105c6c:	e8 0f aa ff ff       	call   80100680 <cprintf>
    lapiceoi();
80105c71:	e8 ba cd ff ff       	call   80102a30 <lapiceoi>
    break;
80105c76:	83 c4 10             	add    $0x10,%esp
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105c79:	e8 52 de ff ff       	call   80103ad0 <myproc>
80105c7e:	85 c0                	test   %eax,%eax
80105c80:	0f 85 cd fe ff ff    	jne    80105b53 <trap+0x43>
80105c86:	e9 e5 fe ff ff       	jmp    80105b70 <trap+0x60>
80105c8b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105c8f:	90                   	nop
    if(myproc()->killed)
80105c90:	e8 3b de ff ff       	call   80103ad0 <myproc>
80105c95:	8b 70 24             	mov    0x24(%eax),%esi
80105c98:	85 f6                	test   %esi,%esi
80105c9a:	0f 85 28 01 00 00    	jne    80105dc8 <trap+0x2b8>
    myproc()->tf = tf;
80105ca0:	e8 2b de ff ff       	call   80103ad0 <myproc>
80105ca5:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105ca8:	e8 13 ef ff ff       	call   80104bc0 <syscall>
    if(myproc()->killed)
80105cad:	e8 1e de ff ff       	call   80103ad0 <myproc>
80105cb2:	8b 48 24             	mov    0x24(%eax),%ecx
80105cb5:	85 c9                	test   %ecx,%ecx
80105cb7:	0f 84 f1 fe ff ff    	je     80105bae <trap+0x9e>
}
80105cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105cc0:	5b                   	pop    %ebx
80105cc1:	5e                   	pop    %esi
80105cc2:	5f                   	pop    %edi
80105cc3:	5d                   	pop    %ebp
      exit();
80105cc4:	e9 27 e2 ff ff       	jmp    80103ef0 <exit>
80105cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    uartintr();
80105cd0:	e8 9b 02 00 00       	call   80105f70 <uartintr>
    lapiceoi();
80105cd5:	e8 56 cd ff ff       	call   80102a30 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105cda:	e8 f1 dd ff ff       	call   80103ad0 <myproc>
80105cdf:	85 c0                	test   %eax,%eax
80105ce1:	0f 85 6c fe ff ff    	jne    80105b53 <trap+0x43>
80105ce7:	e9 84 fe ff ff       	jmp    80105b70 <trap+0x60>
80105cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    kbdintr();
80105cf0:	e8 fb cb ff ff       	call   801028f0 <kbdintr>
    lapiceoi();
80105cf5:	e8 36 cd ff ff       	call   80102a30 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105cfa:	e8 d1 dd ff ff       	call   80103ad0 <myproc>
80105cff:	85 c0                	test   %eax,%eax
80105d01:	0f 85 4c fe ff ff    	jne    80105b53 <trap+0x43>
80105d07:	e9 64 fe ff ff       	jmp    80105b70 <trap+0x60>
80105d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(cpuid() == 0){
80105d10:	e8 9b dd ff ff       	call   80103ab0 <cpuid>
80105d15:	85 c0                	test   %eax,%eax
80105d17:	74 77                	je     80105d90 <trap+0x280>
    if(myproc() != 0 && (tf->cs & 3) == 3)
80105d19:	e8 b2 dd ff ff       	call   80103ad0 <myproc>
80105d1e:	85 c0                	test   %eax,%eax
80105d20:	0f 84 1f fe ff ff    	je     80105b45 <trap+0x35>
80105d26:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105d2a:	83 e0 03             	and    $0x3,%eax
80105d2d:	66 83 f8 03          	cmp    $0x3,%ax
80105d31:	0f 85 0e fe ff ff    	jne    80105b45 <trap+0x35>
      struct proc* p = myproc();
80105d37:	e8 94 dd ff ff       	call   80103ad0 <myproc>
      p->alarmticked ++;  // ticks need ++
80105d3c:	8b b8 80 00 00 00    	mov    0x80(%eax),%edi
80105d42:	8d 57 01             	lea    0x1(%edi),%edx
80105d45:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
      if(p->alarmticked >= p->alarmticks) 
80105d4b:	3b 50 7c             	cmp    0x7c(%eax),%edx
80105d4e:	0f 8c f1 fd ff ff    	jl     80105b45 <trap+0x35>
        p->alarmticked = 0;
80105d54:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80105d5b:	00 00 00 
        tf->esp -= 4;
80105d5e:	8b 53 44             	mov    0x44(%ebx),%edx
80105d61:	8d 4a fc             	lea    -0x4(%edx),%ecx
80105d64:	89 4b 44             	mov    %ecx,0x44(%ebx)
        (*(uint *)(tf->esp)) = tf->eip; // resume where it left off
80105d67:	8b 4b 38             	mov    0x38(%ebx),%ecx
80105d6a:	89 4a fc             	mov    %ecx,-0x4(%edx)
        tf->eip = (uint)p->alarmhandler;  // handler
80105d6d:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80105d73:	89 43 38             	mov    %eax,0x38(%ebx)
    lapiceoi();
80105d76:	e9 ca fd ff ff       	jmp    80105b45 <trap+0x35>
80105d7b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105d7f:	90                   	nop
    exit();
80105d80:	e8 6b e1 ff ff       	call   80103ef0 <exit>
80105d85:	e9 e6 fd ff ff       	jmp    80105b70 <trap+0x60>
80105d8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      acquire(&tickslock);
80105d90:	83 ec 0c             	sub    $0xc,%esp
80105d93:	68 80 3f 11 80       	push   $0x80113f80
80105d98:	e8 63 e9 ff ff       	call   80104700 <acquire>
      wakeup(&ticks);
80105d9d:	c7 04 24 60 3f 11 80 	movl   $0x80113f60,(%esp)
      ticks++;
80105da4:	83 05 60 3f 11 80 01 	addl   $0x1,0x80113f60
      wakeup(&ticks);
80105dab:	e8 b0 e4 ff ff       	call   80104260 <wakeup>
      release(&tickslock);
80105db0:	c7 04 24 80 3f 11 80 	movl   $0x80113f80,(%esp)
80105db7:	e8 e4 e8 ff ff       	call   801046a0 <release>
80105dbc:	83 c4 10             	add    $0x10,%esp
80105dbf:	e9 55 ff ff ff       	jmp    80105d19 <trap+0x209>
80105dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      exit();
80105dc8:	e8 23 e1 ff ff       	call   80103ef0 <exit>
80105dcd:	e9 ce fe ff ff       	jmp    80105ca0 <trap+0x190>
80105dd2:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105dd5:	e8 d6 dc ff ff       	call   80103ab0 <cpuid>
80105dda:	83 ec 0c             	sub    $0xc,%esp
80105ddd:	56                   	push   %esi
80105dde:	57                   	push   %edi
80105ddf:	50                   	push   %eax
80105de0:	ff 73 30             	push   0x30(%ebx)
80105de3:	68 b0 7b 10 80       	push   $0x80107bb0
80105de8:	e8 93 a8 ff ff       	call   80100680 <cprintf>
      panic("trap");
80105ded:	83 c4 14             	add    $0x14,%esp
80105df0:	68 86 7b 10 80       	push   $0x80107b86
80105df5:	e8 86 a5 ff ff       	call   80100380 <panic>
80105dfa:	66 90                	xchg   %ax,%ax
80105dfc:	66 90                	xchg   %ax,%ax
80105dfe:	66 90                	xchg   %ax,%ax

80105e00 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105e00:	a1 c0 47 11 80       	mov    0x801147c0,%eax
80105e05:	85 c0                	test   %eax,%eax
80105e07:	74 17                	je     80105e20 <uartgetc+0x20>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105e09:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105e0e:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105e0f:	a8 01                	test   $0x1,%al
80105e11:	74 0d                	je     80105e20 <uartgetc+0x20>
80105e13:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105e18:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105e19:	0f b6 c0             	movzbl %al,%eax
80105e1c:	c3                   	ret    
80105e1d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105e20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e25:	c3                   	ret    
80105e26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105e2d:	8d 76 00             	lea    0x0(%esi),%esi

80105e30 <uartinit>:
{
80105e30:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105e31:	31 c9                	xor    %ecx,%ecx
80105e33:	89 c8                	mov    %ecx,%eax
80105e35:	89 e5                	mov    %esp,%ebp
80105e37:	57                   	push   %edi
80105e38:	bf fa 03 00 00       	mov    $0x3fa,%edi
80105e3d:	56                   	push   %esi
80105e3e:	89 fa                	mov    %edi,%edx
80105e40:	53                   	push   %ebx
80105e41:	83 ec 1c             	sub    $0x1c,%esp
80105e44:	ee                   	out    %al,(%dx)
80105e45:	be fb 03 00 00       	mov    $0x3fb,%esi
80105e4a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105e4f:	89 f2                	mov    %esi,%edx
80105e51:	ee                   	out    %al,(%dx)
80105e52:	b8 0c 00 00 00       	mov    $0xc,%eax
80105e57:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105e5c:	ee                   	out    %al,(%dx)
80105e5d:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105e62:	89 c8                	mov    %ecx,%eax
80105e64:	89 da                	mov    %ebx,%edx
80105e66:	ee                   	out    %al,(%dx)
80105e67:	b8 03 00 00 00       	mov    $0x3,%eax
80105e6c:	89 f2                	mov    %esi,%edx
80105e6e:	ee                   	out    %al,(%dx)
80105e6f:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105e74:	89 c8                	mov    %ecx,%eax
80105e76:	ee                   	out    %al,(%dx)
80105e77:	b8 01 00 00 00       	mov    $0x1,%eax
80105e7c:	89 da                	mov    %ebx,%edx
80105e7e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105e7f:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105e84:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105e85:	3c ff                	cmp    $0xff,%al
80105e87:	74 78                	je     80105f01 <uartinit+0xd1>
  uart = 1;
80105e89:	c7 05 c0 47 11 80 01 	movl   $0x1,0x801147c0
80105e90:	00 00 00 
80105e93:	89 fa                	mov    %edi,%edx
80105e95:	ec                   	in     (%dx),%al
80105e96:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105e9b:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105e9c:	83 ec 08             	sub    $0x8,%esp
  for(p="xv6...\n"; *p; p++)
80105e9f:	bf a8 7c 10 80       	mov    $0x80107ca8,%edi
80105ea4:	be fd 03 00 00       	mov    $0x3fd,%esi
  ioapicenable(IRQ_COM1, 0);
80105ea9:	6a 00                	push   $0x0
80105eab:	6a 04                	push   $0x4
80105ead:	e8 ee c6 ff ff       	call   801025a0 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105eb2:	c6 45 e7 78          	movb   $0x78,-0x19(%ebp)
  ioapicenable(IRQ_COM1, 0);
80105eb6:	83 c4 10             	add    $0x10,%esp
80105eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(!uart)
80105ec0:	a1 c0 47 11 80       	mov    0x801147c0,%eax
80105ec5:	bb 80 00 00 00       	mov    $0x80,%ebx
80105eca:	85 c0                	test   %eax,%eax
80105ecc:	75 14                	jne    80105ee2 <uartinit+0xb2>
80105ece:	eb 23                	jmp    80105ef3 <uartinit+0xc3>
    microdelay(10);
80105ed0:	83 ec 0c             	sub    $0xc,%esp
80105ed3:	6a 0a                	push   $0xa
80105ed5:	e8 76 cb ff ff       	call   80102a50 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105eda:	83 c4 10             	add    $0x10,%esp
80105edd:	83 eb 01             	sub    $0x1,%ebx
80105ee0:	74 07                	je     80105ee9 <uartinit+0xb9>
80105ee2:	89 f2                	mov    %esi,%edx
80105ee4:	ec                   	in     (%dx),%al
80105ee5:	a8 20                	test   $0x20,%al
80105ee7:	74 e7                	je     80105ed0 <uartinit+0xa0>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105ee9:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
80105eed:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105ef2:	ee                   	out    %al,(%dx)
  for(p="xv6...\n"; *p; p++)
80105ef3:	0f b6 47 01          	movzbl 0x1(%edi),%eax
80105ef7:	83 c7 01             	add    $0x1,%edi
80105efa:	88 45 e7             	mov    %al,-0x19(%ebp)
80105efd:	84 c0                	test   %al,%al
80105eff:	75 bf                	jne    80105ec0 <uartinit+0x90>
}
80105f01:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f04:	5b                   	pop    %ebx
80105f05:	5e                   	pop    %esi
80105f06:	5f                   	pop    %edi
80105f07:	5d                   	pop    %ebp
80105f08:	c3                   	ret    
80105f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105f10 <uartputc>:
  if(!uart)
80105f10:	a1 c0 47 11 80       	mov    0x801147c0,%eax
80105f15:	85 c0                	test   %eax,%eax
80105f17:	74 47                	je     80105f60 <uartputc+0x50>
{
80105f19:	55                   	push   %ebp
80105f1a:	89 e5                	mov    %esp,%ebp
80105f1c:	56                   	push   %esi
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105f1d:	be fd 03 00 00       	mov    $0x3fd,%esi
80105f22:	53                   	push   %ebx
80105f23:	bb 80 00 00 00       	mov    $0x80,%ebx
80105f28:	eb 18                	jmp    80105f42 <uartputc+0x32>
80105f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    microdelay(10);
80105f30:	83 ec 0c             	sub    $0xc,%esp
80105f33:	6a 0a                	push   $0xa
80105f35:	e8 16 cb ff ff       	call   80102a50 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105f3a:	83 c4 10             	add    $0x10,%esp
80105f3d:	83 eb 01             	sub    $0x1,%ebx
80105f40:	74 07                	je     80105f49 <uartputc+0x39>
80105f42:	89 f2                	mov    %esi,%edx
80105f44:	ec                   	in     (%dx),%al
80105f45:	a8 20                	test   $0x20,%al
80105f47:	74 e7                	je     80105f30 <uartputc+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105f49:	8b 45 08             	mov    0x8(%ebp),%eax
80105f4c:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105f51:	ee                   	out    %al,(%dx)
}
80105f52:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105f55:	5b                   	pop    %ebx
80105f56:	5e                   	pop    %esi
80105f57:	5d                   	pop    %ebp
80105f58:	c3                   	ret    
80105f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105f60:	c3                   	ret    
80105f61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105f68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105f6f:	90                   	nop

80105f70 <uartintr>:

void
uartintr(void)
{
80105f70:	55                   	push   %ebp
80105f71:	89 e5                	mov    %esp,%ebp
80105f73:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105f76:	68 00 5e 10 80       	push   $0x80105e00
80105f7b:	e8 70 a9 ff ff       	call   801008f0 <consoleintr>
}
80105f80:	83 c4 10             	add    $0x10,%esp
80105f83:	c9                   	leave  
80105f84:	c3                   	ret    

80105f85 <vector0>:
80105f85:	6a 00                	push   $0x0
80105f87:	6a 00                	push   $0x0
80105f89:	e9 a9 fa ff ff       	jmp    80105a37 <alltraps>

80105f8e <vector1>:
80105f8e:	6a 00                	push   $0x0
80105f90:	6a 01                	push   $0x1
80105f92:	e9 a0 fa ff ff       	jmp    80105a37 <alltraps>

80105f97 <vector2>:
80105f97:	6a 00                	push   $0x0
80105f99:	6a 02                	push   $0x2
80105f9b:	e9 97 fa ff ff       	jmp    80105a37 <alltraps>

80105fa0 <vector3>:
80105fa0:	6a 00                	push   $0x0
80105fa2:	6a 03                	push   $0x3
80105fa4:	e9 8e fa ff ff       	jmp    80105a37 <alltraps>

80105fa9 <vector4>:
80105fa9:	6a 00                	push   $0x0
80105fab:	6a 04                	push   $0x4
80105fad:	e9 85 fa ff ff       	jmp    80105a37 <alltraps>

80105fb2 <vector5>:
80105fb2:	6a 00                	push   $0x0
80105fb4:	6a 05                	push   $0x5
80105fb6:	e9 7c fa ff ff       	jmp    80105a37 <alltraps>

80105fbb <vector6>:
80105fbb:	6a 00                	push   $0x0
80105fbd:	6a 06                	push   $0x6
80105fbf:	e9 73 fa ff ff       	jmp    80105a37 <alltraps>

80105fc4 <vector7>:
80105fc4:	6a 00                	push   $0x0
80105fc6:	6a 07                	push   $0x7
80105fc8:	e9 6a fa ff ff       	jmp    80105a37 <alltraps>

80105fcd <vector8>:
80105fcd:	6a 08                	push   $0x8
80105fcf:	e9 63 fa ff ff       	jmp    80105a37 <alltraps>

80105fd4 <vector9>:
80105fd4:	6a 00                	push   $0x0
80105fd6:	6a 09                	push   $0x9
80105fd8:	e9 5a fa ff ff       	jmp    80105a37 <alltraps>

80105fdd <vector10>:
80105fdd:	6a 0a                	push   $0xa
80105fdf:	e9 53 fa ff ff       	jmp    80105a37 <alltraps>

80105fe4 <vector11>:
80105fe4:	6a 0b                	push   $0xb
80105fe6:	e9 4c fa ff ff       	jmp    80105a37 <alltraps>

80105feb <vector12>:
80105feb:	6a 0c                	push   $0xc
80105fed:	e9 45 fa ff ff       	jmp    80105a37 <alltraps>

80105ff2 <vector13>:
80105ff2:	6a 0d                	push   $0xd
80105ff4:	e9 3e fa ff ff       	jmp    80105a37 <alltraps>

80105ff9 <vector14>:
80105ff9:	6a 0e                	push   $0xe
80105ffb:	e9 37 fa ff ff       	jmp    80105a37 <alltraps>

80106000 <vector15>:
80106000:	6a 00                	push   $0x0
80106002:	6a 0f                	push   $0xf
80106004:	e9 2e fa ff ff       	jmp    80105a37 <alltraps>

80106009 <vector16>:
80106009:	6a 00                	push   $0x0
8010600b:	6a 10                	push   $0x10
8010600d:	e9 25 fa ff ff       	jmp    80105a37 <alltraps>

80106012 <vector17>:
80106012:	6a 11                	push   $0x11
80106014:	e9 1e fa ff ff       	jmp    80105a37 <alltraps>

80106019 <vector18>:
80106019:	6a 00                	push   $0x0
8010601b:	6a 12                	push   $0x12
8010601d:	e9 15 fa ff ff       	jmp    80105a37 <alltraps>

80106022 <vector19>:
80106022:	6a 00                	push   $0x0
80106024:	6a 13                	push   $0x13
80106026:	e9 0c fa ff ff       	jmp    80105a37 <alltraps>

8010602b <vector20>:
8010602b:	6a 00                	push   $0x0
8010602d:	6a 14                	push   $0x14
8010602f:	e9 03 fa ff ff       	jmp    80105a37 <alltraps>

80106034 <vector21>:
80106034:	6a 00                	push   $0x0
80106036:	6a 15                	push   $0x15
80106038:	e9 fa f9 ff ff       	jmp    80105a37 <alltraps>

8010603d <vector22>:
8010603d:	6a 00                	push   $0x0
8010603f:	6a 16                	push   $0x16
80106041:	e9 f1 f9 ff ff       	jmp    80105a37 <alltraps>

80106046 <vector23>:
80106046:	6a 00                	push   $0x0
80106048:	6a 17                	push   $0x17
8010604a:	e9 e8 f9 ff ff       	jmp    80105a37 <alltraps>

8010604f <vector24>:
8010604f:	6a 00                	push   $0x0
80106051:	6a 18                	push   $0x18
80106053:	e9 df f9 ff ff       	jmp    80105a37 <alltraps>

80106058 <vector25>:
80106058:	6a 00                	push   $0x0
8010605a:	6a 19                	push   $0x19
8010605c:	e9 d6 f9 ff ff       	jmp    80105a37 <alltraps>

80106061 <vector26>:
80106061:	6a 00                	push   $0x0
80106063:	6a 1a                	push   $0x1a
80106065:	e9 cd f9 ff ff       	jmp    80105a37 <alltraps>

8010606a <vector27>:
8010606a:	6a 00                	push   $0x0
8010606c:	6a 1b                	push   $0x1b
8010606e:	e9 c4 f9 ff ff       	jmp    80105a37 <alltraps>

80106073 <vector28>:
80106073:	6a 00                	push   $0x0
80106075:	6a 1c                	push   $0x1c
80106077:	e9 bb f9 ff ff       	jmp    80105a37 <alltraps>

8010607c <vector29>:
8010607c:	6a 00                	push   $0x0
8010607e:	6a 1d                	push   $0x1d
80106080:	e9 b2 f9 ff ff       	jmp    80105a37 <alltraps>

80106085 <vector30>:
80106085:	6a 00                	push   $0x0
80106087:	6a 1e                	push   $0x1e
80106089:	e9 a9 f9 ff ff       	jmp    80105a37 <alltraps>

8010608e <vector31>:
8010608e:	6a 00                	push   $0x0
80106090:	6a 1f                	push   $0x1f
80106092:	e9 a0 f9 ff ff       	jmp    80105a37 <alltraps>

80106097 <vector32>:
80106097:	6a 00                	push   $0x0
80106099:	6a 20                	push   $0x20
8010609b:	e9 97 f9 ff ff       	jmp    80105a37 <alltraps>

801060a0 <vector33>:
801060a0:	6a 00                	push   $0x0
801060a2:	6a 21                	push   $0x21
801060a4:	e9 8e f9 ff ff       	jmp    80105a37 <alltraps>

801060a9 <vector34>:
801060a9:	6a 00                	push   $0x0
801060ab:	6a 22                	push   $0x22
801060ad:	e9 85 f9 ff ff       	jmp    80105a37 <alltraps>

801060b2 <vector35>:
801060b2:	6a 00                	push   $0x0
801060b4:	6a 23                	push   $0x23
801060b6:	e9 7c f9 ff ff       	jmp    80105a37 <alltraps>

801060bb <vector36>:
801060bb:	6a 00                	push   $0x0
801060bd:	6a 24                	push   $0x24
801060bf:	e9 73 f9 ff ff       	jmp    80105a37 <alltraps>

801060c4 <vector37>:
801060c4:	6a 00                	push   $0x0
801060c6:	6a 25                	push   $0x25
801060c8:	e9 6a f9 ff ff       	jmp    80105a37 <alltraps>

801060cd <vector38>:
801060cd:	6a 00                	push   $0x0
801060cf:	6a 26                	push   $0x26
801060d1:	e9 61 f9 ff ff       	jmp    80105a37 <alltraps>

801060d6 <vector39>:
801060d6:	6a 00                	push   $0x0
801060d8:	6a 27                	push   $0x27
801060da:	e9 58 f9 ff ff       	jmp    80105a37 <alltraps>

801060df <vector40>:
801060df:	6a 00                	push   $0x0
801060e1:	6a 28                	push   $0x28
801060e3:	e9 4f f9 ff ff       	jmp    80105a37 <alltraps>

801060e8 <vector41>:
801060e8:	6a 00                	push   $0x0
801060ea:	6a 29                	push   $0x29
801060ec:	e9 46 f9 ff ff       	jmp    80105a37 <alltraps>

801060f1 <vector42>:
801060f1:	6a 00                	push   $0x0
801060f3:	6a 2a                	push   $0x2a
801060f5:	e9 3d f9 ff ff       	jmp    80105a37 <alltraps>

801060fa <vector43>:
801060fa:	6a 00                	push   $0x0
801060fc:	6a 2b                	push   $0x2b
801060fe:	e9 34 f9 ff ff       	jmp    80105a37 <alltraps>

80106103 <vector44>:
80106103:	6a 00                	push   $0x0
80106105:	6a 2c                	push   $0x2c
80106107:	e9 2b f9 ff ff       	jmp    80105a37 <alltraps>

8010610c <vector45>:
8010610c:	6a 00                	push   $0x0
8010610e:	6a 2d                	push   $0x2d
80106110:	e9 22 f9 ff ff       	jmp    80105a37 <alltraps>

80106115 <vector46>:
80106115:	6a 00                	push   $0x0
80106117:	6a 2e                	push   $0x2e
80106119:	e9 19 f9 ff ff       	jmp    80105a37 <alltraps>

8010611e <vector47>:
8010611e:	6a 00                	push   $0x0
80106120:	6a 2f                	push   $0x2f
80106122:	e9 10 f9 ff ff       	jmp    80105a37 <alltraps>

80106127 <vector48>:
80106127:	6a 00                	push   $0x0
80106129:	6a 30                	push   $0x30
8010612b:	e9 07 f9 ff ff       	jmp    80105a37 <alltraps>

80106130 <vector49>:
80106130:	6a 00                	push   $0x0
80106132:	6a 31                	push   $0x31
80106134:	e9 fe f8 ff ff       	jmp    80105a37 <alltraps>

80106139 <vector50>:
80106139:	6a 00                	push   $0x0
8010613b:	6a 32                	push   $0x32
8010613d:	e9 f5 f8 ff ff       	jmp    80105a37 <alltraps>

80106142 <vector51>:
80106142:	6a 00                	push   $0x0
80106144:	6a 33                	push   $0x33
80106146:	e9 ec f8 ff ff       	jmp    80105a37 <alltraps>

8010614b <vector52>:
8010614b:	6a 00                	push   $0x0
8010614d:	6a 34                	push   $0x34
8010614f:	e9 e3 f8 ff ff       	jmp    80105a37 <alltraps>

80106154 <vector53>:
80106154:	6a 00                	push   $0x0
80106156:	6a 35                	push   $0x35
80106158:	e9 da f8 ff ff       	jmp    80105a37 <alltraps>

8010615d <vector54>:
8010615d:	6a 00                	push   $0x0
8010615f:	6a 36                	push   $0x36
80106161:	e9 d1 f8 ff ff       	jmp    80105a37 <alltraps>

80106166 <vector55>:
80106166:	6a 00                	push   $0x0
80106168:	6a 37                	push   $0x37
8010616a:	e9 c8 f8 ff ff       	jmp    80105a37 <alltraps>

8010616f <vector56>:
8010616f:	6a 00                	push   $0x0
80106171:	6a 38                	push   $0x38
80106173:	e9 bf f8 ff ff       	jmp    80105a37 <alltraps>

80106178 <vector57>:
80106178:	6a 00                	push   $0x0
8010617a:	6a 39                	push   $0x39
8010617c:	e9 b6 f8 ff ff       	jmp    80105a37 <alltraps>

80106181 <vector58>:
80106181:	6a 00                	push   $0x0
80106183:	6a 3a                	push   $0x3a
80106185:	e9 ad f8 ff ff       	jmp    80105a37 <alltraps>

8010618a <vector59>:
8010618a:	6a 00                	push   $0x0
8010618c:	6a 3b                	push   $0x3b
8010618e:	e9 a4 f8 ff ff       	jmp    80105a37 <alltraps>

80106193 <vector60>:
80106193:	6a 00                	push   $0x0
80106195:	6a 3c                	push   $0x3c
80106197:	e9 9b f8 ff ff       	jmp    80105a37 <alltraps>

8010619c <vector61>:
8010619c:	6a 00                	push   $0x0
8010619e:	6a 3d                	push   $0x3d
801061a0:	e9 92 f8 ff ff       	jmp    80105a37 <alltraps>

801061a5 <vector62>:
801061a5:	6a 00                	push   $0x0
801061a7:	6a 3e                	push   $0x3e
801061a9:	e9 89 f8 ff ff       	jmp    80105a37 <alltraps>

801061ae <vector63>:
801061ae:	6a 00                	push   $0x0
801061b0:	6a 3f                	push   $0x3f
801061b2:	e9 80 f8 ff ff       	jmp    80105a37 <alltraps>

801061b7 <vector64>:
801061b7:	6a 00                	push   $0x0
801061b9:	6a 40                	push   $0x40
801061bb:	e9 77 f8 ff ff       	jmp    80105a37 <alltraps>

801061c0 <vector65>:
801061c0:	6a 00                	push   $0x0
801061c2:	6a 41                	push   $0x41
801061c4:	e9 6e f8 ff ff       	jmp    80105a37 <alltraps>

801061c9 <vector66>:
801061c9:	6a 00                	push   $0x0
801061cb:	6a 42                	push   $0x42
801061cd:	e9 65 f8 ff ff       	jmp    80105a37 <alltraps>

801061d2 <vector67>:
801061d2:	6a 00                	push   $0x0
801061d4:	6a 43                	push   $0x43
801061d6:	e9 5c f8 ff ff       	jmp    80105a37 <alltraps>

801061db <vector68>:
801061db:	6a 00                	push   $0x0
801061dd:	6a 44                	push   $0x44
801061df:	e9 53 f8 ff ff       	jmp    80105a37 <alltraps>

801061e4 <vector69>:
801061e4:	6a 00                	push   $0x0
801061e6:	6a 45                	push   $0x45
801061e8:	e9 4a f8 ff ff       	jmp    80105a37 <alltraps>

801061ed <vector70>:
801061ed:	6a 00                	push   $0x0
801061ef:	6a 46                	push   $0x46
801061f1:	e9 41 f8 ff ff       	jmp    80105a37 <alltraps>

801061f6 <vector71>:
801061f6:	6a 00                	push   $0x0
801061f8:	6a 47                	push   $0x47
801061fa:	e9 38 f8 ff ff       	jmp    80105a37 <alltraps>

801061ff <vector72>:
801061ff:	6a 00                	push   $0x0
80106201:	6a 48                	push   $0x48
80106203:	e9 2f f8 ff ff       	jmp    80105a37 <alltraps>

80106208 <vector73>:
80106208:	6a 00                	push   $0x0
8010620a:	6a 49                	push   $0x49
8010620c:	e9 26 f8 ff ff       	jmp    80105a37 <alltraps>

80106211 <vector74>:
80106211:	6a 00                	push   $0x0
80106213:	6a 4a                	push   $0x4a
80106215:	e9 1d f8 ff ff       	jmp    80105a37 <alltraps>

8010621a <vector75>:
8010621a:	6a 00                	push   $0x0
8010621c:	6a 4b                	push   $0x4b
8010621e:	e9 14 f8 ff ff       	jmp    80105a37 <alltraps>

80106223 <vector76>:
80106223:	6a 00                	push   $0x0
80106225:	6a 4c                	push   $0x4c
80106227:	e9 0b f8 ff ff       	jmp    80105a37 <alltraps>

8010622c <vector77>:
8010622c:	6a 00                	push   $0x0
8010622e:	6a 4d                	push   $0x4d
80106230:	e9 02 f8 ff ff       	jmp    80105a37 <alltraps>

80106235 <vector78>:
80106235:	6a 00                	push   $0x0
80106237:	6a 4e                	push   $0x4e
80106239:	e9 f9 f7 ff ff       	jmp    80105a37 <alltraps>

8010623e <vector79>:
8010623e:	6a 00                	push   $0x0
80106240:	6a 4f                	push   $0x4f
80106242:	e9 f0 f7 ff ff       	jmp    80105a37 <alltraps>

80106247 <vector80>:
80106247:	6a 00                	push   $0x0
80106249:	6a 50                	push   $0x50
8010624b:	e9 e7 f7 ff ff       	jmp    80105a37 <alltraps>

80106250 <vector81>:
80106250:	6a 00                	push   $0x0
80106252:	6a 51                	push   $0x51
80106254:	e9 de f7 ff ff       	jmp    80105a37 <alltraps>

80106259 <vector82>:
80106259:	6a 00                	push   $0x0
8010625b:	6a 52                	push   $0x52
8010625d:	e9 d5 f7 ff ff       	jmp    80105a37 <alltraps>

80106262 <vector83>:
80106262:	6a 00                	push   $0x0
80106264:	6a 53                	push   $0x53
80106266:	e9 cc f7 ff ff       	jmp    80105a37 <alltraps>

8010626b <vector84>:
8010626b:	6a 00                	push   $0x0
8010626d:	6a 54                	push   $0x54
8010626f:	e9 c3 f7 ff ff       	jmp    80105a37 <alltraps>

80106274 <vector85>:
80106274:	6a 00                	push   $0x0
80106276:	6a 55                	push   $0x55
80106278:	e9 ba f7 ff ff       	jmp    80105a37 <alltraps>

8010627d <vector86>:
8010627d:	6a 00                	push   $0x0
8010627f:	6a 56                	push   $0x56
80106281:	e9 b1 f7 ff ff       	jmp    80105a37 <alltraps>

80106286 <vector87>:
80106286:	6a 00                	push   $0x0
80106288:	6a 57                	push   $0x57
8010628a:	e9 a8 f7 ff ff       	jmp    80105a37 <alltraps>

8010628f <vector88>:
8010628f:	6a 00                	push   $0x0
80106291:	6a 58                	push   $0x58
80106293:	e9 9f f7 ff ff       	jmp    80105a37 <alltraps>

80106298 <vector89>:
80106298:	6a 00                	push   $0x0
8010629a:	6a 59                	push   $0x59
8010629c:	e9 96 f7 ff ff       	jmp    80105a37 <alltraps>

801062a1 <vector90>:
801062a1:	6a 00                	push   $0x0
801062a3:	6a 5a                	push   $0x5a
801062a5:	e9 8d f7 ff ff       	jmp    80105a37 <alltraps>

801062aa <vector91>:
801062aa:	6a 00                	push   $0x0
801062ac:	6a 5b                	push   $0x5b
801062ae:	e9 84 f7 ff ff       	jmp    80105a37 <alltraps>

801062b3 <vector92>:
801062b3:	6a 00                	push   $0x0
801062b5:	6a 5c                	push   $0x5c
801062b7:	e9 7b f7 ff ff       	jmp    80105a37 <alltraps>

801062bc <vector93>:
801062bc:	6a 00                	push   $0x0
801062be:	6a 5d                	push   $0x5d
801062c0:	e9 72 f7 ff ff       	jmp    80105a37 <alltraps>

801062c5 <vector94>:
801062c5:	6a 00                	push   $0x0
801062c7:	6a 5e                	push   $0x5e
801062c9:	e9 69 f7 ff ff       	jmp    80105a37 <alltraps>

801062ce <vector95>:
801062ce:	6a 00                	push   $0x0
801062d0:	6a 5f                	push   $0x5f
801062d2:	e9 60 f7 ff ff       	jmp    80105a37 <alltraps>

801062d7 <vector96>:
801062d7:	6a 00                	push   $0x0
801062d9:	6a 60                	push   $0x60
801062db:	e9 57 f7 ff ff       	jmp    80105a37 <alltraps>

801062e0 <vector97>:
801062e0:	6a 00                	push   $0x0
801062e2:	6a 61                	push   $0x61
801062e4:	e9 4e f7 ff ff       	jmp    80105a37 <alltraps>

801062e9 <vector98>:
801062e9:	6a 00                	push   $0x0
801062eb:	6a 62                	push   $0x62
801062ed:	e9 45 f7 ff ff       	jmp    80105a37 <alltraps>

801062f2 <vector99>:
801062f2:	6a 00                	push   $0x0
801062f4:	6a 63                	push   $0x63
801062f6:	e9 3c f7 ff ff       	jmp    80105a37 <alltraps>

801062fb <vector100>:
801062fb:	6a 00                	push   $0x0
801062fd:	6a 64                	push   $0x64
801062ff:	e9 33 f7 ff ff       	jmp    80105a37 <alltraps>

80106304 <vector101>:
80106304:	6a 00                	push   $0x0
80106306:	6a 65                	push   $0x65
80106308:	e9 2a f7 ff ff       	jmp    80105a37 <alltraps>

8010630d <vector102>:
8010630d:	6a 00                	push   $0x0
8010630f:	6a 66                	push   $0x66
80106311:	e9 21 f7 ff ff       	jmp    80105a37 <alltraps>

80106316 <vector103>:
80106316:	6a 00                	push   $0x0
80106318:	6a 67                	push   $0x67
8010631a:	e9 18 f7 ff ff       	jmp    80105a37 <alltraps>

8010631f <vector104>:
8010631f:	6a 00                	push   $0x0
80106321:	6a 68                	push   $0x68
80106323:	e9 0f f7 ff ff       	jmp    80105a37 <alltraps>

80106328 <vector105>:
80106328:	6a 00                	push   $0x0
8010632a:	6a 69                	push   $0x69
8010632c:	e9 06 f7 ff ff       	jmp    80105a37 <alltraps>

80106331 <vector106>:
80106331:	6a 00                	push   $0x0
80106333:	6a 6a                	push   $0x6a
80106335:	e9 fd f6 ff ff       	jmp    80105a37 <alltraps>

8010633a <vector107>:
8010633a:	6a 00                	push   $0x0
8010633c:	6a 6b                	push   $0x6b
8010633e:	e9 f4 f6 ff ff       	jmp    80105a37 <alltraps>

80106343 <vector108>:
80106343:	6a 00                	push   $0x0
80106345:	6a 6c                	push   $0x6c
80106347:	e9 eb f6 ff ff       	jmp    80105a37 <alltraps>

8010634c <vector109>:
8010634c:	6a 00                	push   $0x0
8010634e:	6a 6d                	push   $0x6d
80106350:	e9 e2 f6 ff ff       	jmp    80105a37 <alltraps>

80106355 <vector110>:
80106355:	6a 00                	push   $0x0
80106357:	6a 6e                	push   $0x6e
80106359:	e9 d9 f6 ff ff       	jmp    80105a37 <alltraps>

8010635e <vector111>:
8010635e:	6a 00                	push   $0x0
80106360:	6a 6f                	push   $0x6f
80106362:	e9 d0 f6 ff ff       	jmp    80105a37 <alltraps>

80106367 <vector112>:
80106367:	6a 00                	push   $0x0
80106369:	6a 70                	push   $0x70
8010636b:	e9 c7 f6 ff ff       	jmp    80105a37 <alltraps>

80106370 <vector113>:
80106370:	6a 00                	push   $0x0
80106372:	6a 71                	push   $0x71
80106374:	e9 be f6 ff ff       	jmp    80105a37 <alltraps>

80106379 <vector114>:
80106379:	6a 00                	push   $0x0
8010637b:	6a 72                	push   $0x72
8010637d:	e9 b5 f6 ff ff       	jmp    80105a37 <alltraps>

80106382 <vector115>:
80106382:	6a 00                	push   $0x0
80106384:	6a 73                	push   $0x73
80106386:	e9 ac f6 ff ff       	jmp    80105a37 <alltraps>

8010638b <vector116>:
8010638b:	6a 00                	push   $0x0
8010638d:	6a 74                	push   $0x74
8010638f:	e9 a3 f6 ff ff       	jmp    80105a37 <alltraps>

80106394 <vector117>:
80106394:	6a 00                	push   $0x0
80106396:	6a 75                	push   $0x75
80106398:	e9 9a f6 ff ff       	jmp    80105a37 <alltraps>

8010639d <vector118>:
8010639d:	6a 00                	push   $0x0
8010639f:	6a 76                	push   $0x76
801063a1:	e9 91 f6 ff ff       	jmp    80105a37 <alltraps>

801063a6 <vector119>:
801063a6:	6a 00                	push   $0x0
801063a8:	6a 77                	push   $0x77
801063aa:	e9 88 f6 ff ff       	jmp    80105a37 <alltraps>

801063af <vector120>:
801063af:	6a 00                	push   $0x0
801063b1:	6a 78                	push   $0x78
801063b3:	e9 7f f6 ff ff       	jmp    80105a37 <alltraps>

801063b8 <vector121>:
801063b8:	6a 00                	push   $0x0
801063ba:	6a 79                	push   $0x79
801063bc:	e9 76 f6 ff ff       	jmp    80105a37 <alltraps>

801063c1 <vector122>:
801063c1:	6a 00                	push   $0x0
801063c3:	6a 7a                	push   $0x7a
801063c5:	e9 6d f6 ff ff       	jmp    80105a37 <alltraps>

801063ca <vector123>:
801063ca:	6a 00                	push   $0x0
801063cc:	6a 7b                	push   $0x7b
801063ce:	e9 64 f6 ff ff       	jmp    80105a37 <alltraps>

801063d3 <vector124>:
801063d3:	6a 00                	push   $0x0
801063d5:	6a 7c                	push   $0x7c
801063d7:	e9 5b f6 ff ff       	jmp    80105a37 <alltraps>

801063dc <vector125>:
801063dc:	6a 00                	push   $0x0
801063de:	6a 7d                	push   $0x7d
801063e0:	e9 52 f6 ff ff       	jmp    80105a37 <alltraps>

801063e5 <vector126>:
801063e5:	6a 00                	push   $0x0
801063e7:	6a 7e                	push   $0x7e
801063e9:	e9 49 f6 ff ff       	jmp    80105a37 <alltraps>

801063ee <vector127>:
801063ee:	6a 00                	push   $0x0
801063f0:	6a 7f                	push   $0x7f
801063f2:	e9 40 f6 ff ff       	jmp    80105a37 <alltraps>

801063f7 <vector128>:
801063f7:	6a 00                	push   $0x0
801063f9:	68 80 00 00 00       	push   $0x80
801063fe:	e9 34 f6 ff ff       	jmp    80105a37 <alltraps>

80106403 <vector129>:
80106403:	6a 00                	push   $0x0
80106405:	68 81 00 00 00       	push   $0x81
8010640a:	e9 28 f6 ff ff       	jmp    80105a37 <alltraps>

8010640f <vector130>:
8010640f:	6a 00                	push   $0x0
80106411:	68 82 00 00 00       	push   $0x82
80106416:	e9 1c f6 ff ff       	jmp    80105a37 <alltraps>

8010641b <vector131>:
8010641b:	6a 00                	push   $0x0
8010641d:	68 83 00 00 00       	push   $0x83
80106422:	e9 10 f6 ff ff       	jmp    80105a37 <alltraps>

80106427 <vector132>:
80106427:	6a 00                	push   $0x0
80106429:	68 84 00 00 00       	push   $0x84
8010642e:	e9 04 f6 ff ff       	jmp    80105a37 <alltraps>

80106433 <vector133>:
80106433:	6a 00                	push   $0x0
80106435:	68 85 00 00 00       	push   $0x85
8010643a:	e9 f8 f5 ff ff       	jmp    80105a37 <alltraps>

8010643f <vector134>:
8010643f:	6a 00                	push   $0x0
80106441:	68 86 00 00 00       	push   $0x86
80106446:	e9 ec f5 ff ff       	jmp    80105a37 <alltraps>

8010644b <vector135>:
8010644b:	6a 00                	push   $0x0
8010644d:	68 87 00 00 00       	push   $0x87
80106452:	e9 e0 f5 ff ff       	jmp    80105a37 <alltraps>

80106457 <vector136>:
80106457:	6a 00                	push   $0x0
80106459:	68 88 00 00 00       	push   $0x88
8010645e:	e9 d4 f5 ff ff       	jmp    80105a37 <alltraps>

80106463 <vector137>:
80106463:	6a 00                	push   $0x0
80106465:	68 89 00 00 00       	push   $0x89
8010646a:	e9 c8 f5 ff ff       	jmp    80105a37 <alltraps>

8010646f <vector138>:
8010646f:	6a 00                	push   $0x0
80106471:	68 8a 00 00 00       	push   $0x8a
80106476:	e9 bc f5 ff ff       	jmp    80105a37 <alltraps>

8010647b <vector139>:
8010647b:	6a 00                	push   $0x0
8010647d:	68 8b 00 00 00       	push   $0x8b
80106482:	e9 b0 f5 ff ff       	jmp    80105a37 <alltraps>

80106487 <vector140>:
80106487:	6a 00                	push   $0x0
80106489:	68 8c 00 00 00       	push   $0x8c
8010648e:	e9 a4 f5 ff ff       	jmp    80105a37 <alltraps>

80106493 <vector141>:
80106493:	6a 00                	push   $0x0
80106495:	68 8d 00 00 00       	push   $0x8d
8010649a:	e9 98 f5 ff ff       	jmp    80105a37 <alltraps>

8010649f <vector142>:
8010649f:	6a 00                	push   $0x0
801064a1:	68 8e 00 00 00       	push   $0x8e
801064a6:	e9 8c f5 ff ff       	jmp    80105a37 <alltraps>

801064ab <vector143>:
801064ab:	6a 00                	push   $0x0
801064ad:	68 8f 00 00 00       	push   $0x8f
801064b2:	e9 80 f5 ff ff       	jmp    80105a37 <alltraps>

801064b7 <vector144>:
801064b7:	6a 00                	push   $0x0
801064b9:	68 90 00 00 00       	push   $0x90
801064be:	e9 74 f5 ff ff       	jmp    80105a37 <alltraps>

801064c3 <vector145>:
801064c3:	6a 00                	push   $0x0
801064c5:	68 91 00 00 00       	push   $0x91
801064ca:	e9 68 f5 ff ff       	jmp    80105a37 <alltraps>

801064cf <vector146>:
801064cf:	6a 00                	push   $0x0
801064d1:	68 92 00 00 00       	push   $0x92
801064d6:	e9 5c f5 ff ff       	jmp    80105a37 <alltraps>

801064db <vector147>:
801064db:	6a 00                	push   $0x0
801064dd:	68 93 00 00 00       	push   $0x93
801064e2:	e9 50 f5 ff ff       	jmp    80105a37 <alltraps>

801064e7 <vector148>:
801064e7:	6a 00                	push   $0x0
801064e9:	68 94 00 00 00       	push   $0x94
801064ee:	e9 44 f5 ff ff       	jmp    80105a37 <alltraps>

801064f3 <vector149>:
801064f3:	6a 00                	push   $0x0
801064f5:	68 95 00 00 00       	push   $0x95
801064fa:	e9 38 f5 ff ff       	jmp    80105a37 <alltraps>

801064ff <vector150>:
801064ff:	6a 00                	push   $0x0
80106501:	68 96 00 00 00       	push   $0x96
80106506:	e9 2c f5 ff ff       	jmp    80105a37 <alltraps>

8010650b <vector151>:
8010650b:	6a 00                	push   $0x0
8010650d:	68 97 00 00 00       	push   $0x97
80106512:	e9 20 f5 ff ff       	jmp    80105a37 <alltraps>

80106517 <vector152>:
80106517:	6a 00                	push   $0x0
80106519:	68 98 00 00 00       	push   $0x98
8010651e:	e9 14 f5 ff ff       	jmp    80105a37 <alltraps>

80106523 <vector153>:
80106523:	6a 00                	push   $0x0
80106525:	68 99 00 00 00       	push   $0x99
8010652a:	e9 08 f5 ff ff       	jmp    80105a37 <alltraps>

8010652f <vector154>:
8010652f:	6a 00                	push   $0x0
80106531:	68 9a 00 00 00       	push   $0x9a
80106536:	e9 fc f4 ff ff       	jmp    80105a37 <alltraps>

8010653b <vector155>:
8010653b:	6a 00                	push   $0x0
8010653d:	68 9b 00 00 00       	push   $0x9b
80106542:	e9 f0 f4 ff ff       	jmp    80105a37 <alltraps>

80106547 <vector156>:
80106547:	6a 00                	push   $0x0
80106549:	68 9c 00 00 00       	push   $0x9c
8010654e:	e9 e4 f4 ff ff       	jmp    80105a37 <alltraps>

80106553 <vector157>:
80106553:	6a 00                	push   $0x0
80106555:	68 9d 00 00 00       	push   $0x9d
8010655a:	e9 d8 f4 ff ff       	jmp    80105a37 <alltraps>

8010655f <vector158>:
8010655f:	6a 00                	push   $0x0
80106561:	68 9e 00 00 00       	push   $0x9e
80106566:	e9 cc f4 ff ff       	jmp    80105a37 <alltraps>

8010656b <vector159>:
8010656b:	6a 00                	push   $0x0
8010656d:	68 9f 00 00 00       	push   $0x9f
80106572:	e9 c0 f4 ff ff       	jmp    80105a37 <alltraps>

80106577 <vector160>:
80106577:	6a 00                	push   $0x0
80106579:	68 a0 00 00 00       	push   $0xa0
8010657e:	e9 b4 f4 ff ff       	jmp    80105a37 <alltraps>

80106583 <vector161>:
80106583:	6a 00                	push   $0x0
80106585:	68 a1 00 00 00       	push   $0xa1
8010658a:	e9 a8 f4 ff ff       	jmp    80105a37 <alltraps>

8010658f <vector162>:
8010658f:	6a 00                	push   $0x0
80106591:	68 a2 00 00 00       	push   $0xa2
80106596:	e9 9c f4 ff ff       	jmp    80105a37 <alltraps>

8010659b <vector163>:
8010659b:	6a 00                	push   $0x0
8010659d:	68 a3 00 00 00       	push   $0xa3
801065a2:	e9 90 f4 ff ff       	jmp    80105a37 <alltraps>

801065a7 <vector164>:
801065a7:	6a 00                	push   $0x0
801065a9:	68 a4 00 00 00       	push   $0xa4
801065ae:	e9 84 f4 ff ff       	jmp    80105a37 <alltraps>

801065b3 <vector165>:
801065b3:	6a 00                	push   $0x0
801065b5:	68 a5 00 00 00       	push   $0xa5
801065ba:	e9 78 f4 ff ff       	jmp    80105a37 <alltraps>

801065bf <vector166>:
801065bf:	6a 00                	push   $0x0
801065c1:	68 a6 00 00 00       	push   $0xa6
801065c6:	e9 6c f4 ff ff       	jmp    80105a37 <alltraps>

801065cb <vector167>:
801065cb:	6a 00                	push   $0x0
801065cd:	68 a7 00 00 00       	push   $0xa7
801065d2:	e9 60 f4 ff ff       	jmp    80105a37 <alltraps>

801065d7 <vector168>:
801065d7:	6a 00                	push   $0x0
801065d9:	68 a8 00 00 00       	push   $0xa8
801065de:	e9 54 f4 ff ff       	jmp    80105a37 <alltraps>

801065e3 <vector169>:
801065e3:	6a 00                	push   $0x0
801065e5:	68 a9 00 00 00       	push   $0xa9
801065ea:	e9 48 f4 ff ff       	jmp    80105a37 <alltraps>

801065ef <vector170>:
801065ef:	6a 00                	push   $0x0
801065f1:	68 aa 00 00 00       	push   $0xaa
801065f6:	e9 3c f4 ff ff       	jmp    80105a37 <alltraps>

801065fb <vector171>:
801065fb:	6a 00                	push   $0x0
801065fd:	68 ab 00 00 00       	push   $0xab
80106602:	e9 30 f4 ff ff       	jmp    80105a37 <alltraps>

80106607 <vector172>:
80106607:	6a 00                	push   $0x0
80106609:	68 ac 00 00 00       	push   $0xac
8010660e:	e9 24 f4 ff ff       	jmp    80105a37 <alltraps>

80106613 <vector173>:
80106613:	6a 00                	push   $0x0
80106615:	68 ad 00 00 00       	push   $0xad
8010661a:	e9 18 f4 ff ff       	jmp    80105a37 <alltraps>

8010661f <vector174>:
8010661f:	6a 00                	push   $0x0
80106621:	68 ae 00 00 00       	push   $0xae
80106626:	e9 0c f4 ff ff       	jmp    80105a37 <alltraps>

8010662b <vector175>:
8010662b:	6a 00                	push   $0x0
8010662d:	68 af 00 00 00       	push   $0xaf
80106632:	e9 00 f4 ff ff       	jmp    80105a37 <alltraps>

80106637 <vector176>:
80106637:	6a 00                	push   $0x0
80106639:	68 b0 00 00 00       	push   $0xb0
8010663e:	e9 f4 f3 ff ff       	jmp    80105a37 <alltraps>

80106643 <vector177>:
80106643:	6a 00                	push   $0x0
80106645:	68 b1 00 00 00       	push   $0xb1
8010664a:	e9 e8 f3 ff ff       	jmp    80105a37 <alltraps>

8010664f <vector178>:
8010664f:	6a 00                	push   $0x0
80106651:	68 b2 00 00 00       	push   $0xb2
80106656:	e9 dc f3 ff ff       	jmp    80105a37 <alltraps>

8010665b <vector179>:
8010665b:	6a 00                	push   $0x0
8010665d:	68 b3 00 00 00       	push   $0xb3
80106662:	e9 d0 f3 ff ff       	jmp    80105a37 <alltraps>

80106667 <vector180>:
80106667:	6a 00                	push   $0x0
80106669:	68 b4 00 00 00       	push   $0xb4
8010666e:	e9 c4 f3 ff ff       	jmp    80105a37 <alltraps>

80106673 <vector181>:
80106673:	6a 00                	push   $0x0
80106675:	68 b5 00 00 00       	push   $0xb5
8010667a:	e9 b8 f3 ff ff       	jmp    80105a37 <alltraps>

8010667f <vector182>:
8010667f:	6a 00                	push   $0x0
80106681:	68 b6 00 00 00       	push   $0xb6
80106686:	e9 ac f3 ff ff       	jmp    80105a37 <alltraps>

8010668b <vector183>:
8010668b:	6a 00                	push   $0x0
8010668d:	68 b7 00 00 00       	push   $0xb7
80106692:	e9 a0 f3 ff ff       	jmp    80105a37 <alltraps>

80106697 <vector184>:
80106697:	6a 00                	push   $0x0
80106699:	68 b8 00 00 00       	push   $0xb8
8010669e:	e9 94 f3 ff ff       	jmp    80105a37 <alltraps>

801066a3 <vector185>:
801066a3:	6a 00                	push   $0x0
801066a5:	68 b9 00 00 00       	push   $0xb9
801066aa:	e9 88 f3 ff ff       	jmp    80105a37 <alltraps>

801066af <vector186>:
801066af:	6a 00                	push   $0x0
801066b1:	68 ba 00 00 00       	push   $0xba
801066b6:	e9 7c f3 ff ff       	jmp    80105a37 <alltraps>

801066bb <vector187>:
801066bb:	6a 00                	push   $0x0
801066bd:	68 bb 00 00 00       	push   $0xbb
801066c2:	e9 70 f3 ff ff       	jmp    80105a37 <alltraps>

801066c7 <vector188>:
801066c7:	6a 00                	push   $0x0
801066c9:	68 bc 00 00 00       	push   $0xbc
801066ce:	e9 64 f3 ff ff       	jmp    80105a37 <alltraps>

801066d3 <vector189>:
801066d3:	6a 00                	push   $0x0
801066d5:	68 bd 00 00 00       	push   $0xbd
801066da:	e9 58 f3 ff ff       	jmp    80105a37 <alltraps>

801066df <vector190>:
801066df:	6a 00                	push   $0x0
801066e1:	68 be 00 00 00       	push   $0xbe
801066e6:	e9 4c f3 ff ff       	jmp    80105a37 <alltraps>

801066eb <vector191>:
801066eb:	6a 00                	push   $0x0
801066ed:	68 bf 00 00 00       	push   $0xbf
801066f2:	e9 40 f3 ff ff       	jmp    80105a37 <alltraps>

801066f7 <vector192>:
801066f7:	6a 00                	push   $0x0
801066f9:	68 c0 00 00 00       	push   $0xc0
801066fe:	e9 34 f3 ff ff       	jmp    80105a37 <alltraps>

80106703 <vector193>:
80106703:	6a 00                	push   $0x0
80106705:	68 c1 00 00 00       	push   $0xc1
8010670a:	e9 28 f3 ff ff       	jmp    80105a37 <alltraps>

8010670f <vector194>:
8010670f:	6a 00                	push   $0x0
80106711:	68 c2 00 00 00       	push   $0xc2
80106716:	e9 1c f3 ff ff       	jmp    80105a37 <alltraps>

8010671b <vector195>:
8010671b:	6a 00                	push   $0x0
8010671d:	68 c3 00 00 00       	push   $0xc3
80106722:	e9 10 f3 ff ff       	jmp    80105a37 <alltraps>

80106727 <vector196>:
80106727:	6a 00                	push   $0x0
80106729:	68 c4 00 00 00       	push   $0xc4
8010672e:	e9 04 f3 ff ff       	jmp    80105a37 <alltraps>

80106733 <vector197>:
80106733:	6a 00                	push   $0x0
80106735:	68 c5 00 00 00       	push   $0xc5
8010673a:	e9 f8 f2 ff ff       	jmp    80105a37 <alltraps>

8010673f <vector198>:
8010673f:	6a 00                	push   $0x0
80106741:	68 c6 00 00 00       	push   $0xc6
80106746:	e9 ec f2 ff ff       	jmp    80105a37 <alltraps>

8010674b <vector199>:
8010674b:	6a 00                	push   $0x0
8010674d:	68 c7 00 00 00       	push   $0xc7
80106752:	e9 e0 f2 ff ff       	jmp    80105a37 <alltraps>

80106757 <vector200>:
80106757:	6a 00                	push   $0x0
80106759:	68 c8 00 00 00       	push   $0xc8
8010675e:	e9 d4 f2 ff ff       	jmp    80105a37 <alltraps>

80106763 <vector201>:
80106763:	6a 00                	push   $0x0
80106765:	68 c9 00 00 00       	push   $0xc9
8010676a:	e9 c8 f2 ff ff       	jmp    80105a37 <alltraps>

8010676f <vector202>:
8010676f:	6a 00                	push   $0x0
80106771:	68 ca 00 00 00       	push   $0xca
80106776:	e9 bc f2 ff ff       	jmp    80105a37 <alltraps>

8010677b <vector203>:
8010677b:	6a 00                	push   $0x0
8010677d:	68 cb 00 00 00       	push   $0xcb
80106782:	e9 b0 f2 ff ff       	jmp    80105a37 <alltraps>

80106787 <vector204>:
80106787:	6a 00                	push   $0x0
80106789:	68 cc 00 00 00       	push   $0xcc
8010678e:	e9 a4 f2 ff ff       	jmp    80105a37 <alltraps>

80106793 <vector205>:
80106793:	6a 00                	push   $0x0
80106795:	68 cd 00 00 00       	push   $0xcd
8010679a:	e9 98 f2 ff ff       	jmp    80105a37 <alltraps>

8010679f <vector206>:
8010679f:	6a 00                	push   $0x0
801067a1:	68 ce 00 00 00       	push   $0xce
801067a6:	e9 8c f2 ff ff       	jmp    80105a37 <alltraps>

801067ab <vector207>:
801067ab:	6a 00                	push   $0x0
801067ad:	68 cf 00 00 00       	push   $0xcf
801067b2:	e9 80 f2 ff ff       	jmp    80105a37 <alltraps>

801067b7 <vector208>:
801067b7:	6a 00                	push   $0x0
801067b9:	68 d0 00 00 00       	push   $0xd0
801067be:	e9 74 f2 ff ff       	jmp    80105a37 <alltraps>

801067c3 <vector209>:
801067c3:	6a 00                	push   $0x0
801067c5:	68 d1 00 00 00       	push   $0xd1
801067ca:	e9 68 f2 ff ff       	jmp    80105a37 <alltraps>

801067cf <vector210>:
801067cf:	6a 00                	push   $0x0
801067d1:	68 d2 00 00 00       	push   $0xd2
801067d6:	e9 5c f2 ff ff       	jmp    80105a37 <alltraps>

801067db <vector211>:
801067db:	6a 00                	push   $0x0
801067dd:	68 d3 00 00 00       	push   $0xd3
801067e2:	e9 50 f2 ff ff       	jmp    80105a37 <alltraps>

801067e7 <vector212>:
801067e7:	6a 00                	push   $0x0
801067e9:	68 d4 00 00 00       	push   $0xd4
801067ee:	e9 44 f2 ff ff       	jmp    80105a37 <alltraps>

801067f3 <vector213>:
801067f3:	6a 00                	push   $0x0
801067f5:	68 d5 00 00 00       	push   $0xd5
801067fa:	e9 38 f2 ff ff       	jmp    80105a37 <alltraps>

801067ff <vector214>:
801067ff:	6a 00                	push   $0x0
80106801:	68 d6 00 00 00       	push   $0xd6
80106806:	e9 2c f2 ff ff       	jmp    80105a37 <alltraps>

8010680b <vector215>:
8010680b:	6a 00                	push   $0x0
8010680d:	68 d7 00 00 00       	push   $0xd7
80106812:	e9 20 f2 ff ff       	jmp    80105a37 <alltraps>

80106817 <vector216>:
80106817:	6a 00                	push   $0x0
80106819:	68 d8 00 00 00       	push   $0xd8
8010681e:	e9 14 f2 ff ff       	jmp    80105a37 <alltraps>

80106823 <vector217>:
80106823:	6a 00                	push   $0x0
80106825:	68 d9 00 00 00       	push   $0xd9
8010682a:	e9 08 f2 ff ff       	jmp    80105a37 <alltraps>

8010682f <vector218>:
8010682f:	6a 00                	push   $0x0
80106831:	68 da 00 00 00       	push   $0xda
80106836:	e9 fc f1 ff ff       	jmp    80105a37 <alltraps>

8010683b <vector219>:
8010683b:	6a 00                	push   $0x0
8010683d:	68 db 00 00 00       	push   $0xdb
80106842:	e9 f0 f1 ff ff       	jmp    80105a37 <alltraps>

80106847 <vector220>:
80106847:	6a 00                	push   $0x0
80106849:	68 dc 00 00 00       	push   $0xdc
8010684e:	e9 e4 f1 ff ff       	jmp    80105a37 <alltraps>

80106853 <vector221>:
80106853:	6a 00                	push   $0x0
80106855:	68 dd 00 00 00       	push   $0xdd
8010685a:	e9 d8 f1 ff ff       	jmp    80105a37 <alltraps>

8010685f <vector222>:
8010685f:	6a 00                	push   $0x0
80106861:	68 de 00 00 00       	push   $0xde
80106866:	e9 cc f1 ff ff       	jmp    80105a37 <alltraps>

8010686b <vector223>:
8010686b:	6a 00                	push   $0x0
8010686d:	68 df 00 00 00       	push   $0xdf
80106872:	e9 c0 f1 ff ff       	jmp    80105a37 <alltraps>

80106877 <vector224>:
80106877:	6a 00                	push   $0x0
80106879:	68 e0 00 00 00       	push   $0xe0
8010687e:	e9 b4 f1 ff ff       	jmp    80105a37 <alltraps>

80106883 <vector225>:
80106883:	6a 00                	push   $0x0
80106885:	68 e1 00 00 00       	push   $0xe1
8010688a:	e9 a8 f1 ff ff       	jmp    80105a37 <alltraps>

8010688f <vector226>:
8010688f:	6a 00                	push   $0x0
80106891:	68 e2 00 00 00       	push   $0xe2
80106896:	e9 9c f1 ff ff       	jmp    80105a37 <alltraps>

8010689b <vector227>:
8010689b:	6a 00                	push   $0x0
8010689d:	68 e3 00 00 00       	push   $0xe3
801068a2:	e9 90 f1 ff ff       	jmp    80105a37 <alltraps>

801068a7 <vector228>:
801068a7:	6a 00                	push   $0x0
801068a9:	68 e4 00 00 00       	push   $0xe4
801068ae:	e9 84 f1 ff ff       	jmp    80105a37 <alltraps>

801068b3 <vector229>:
801068b3:	6a 00                	push   $0x0
801068b5:	68 e5 00 00 00       	push   $0xe5
801068ba:	e9 78 f1 ff ff       	jmp    80105a37 <alltraps>

801068bf <vector230>:
801068bf:	6a 00                	push   $0x0
801068c1:	68 e6 00 00 00       	push   $0xe6
801068c6:	e9 6c f1 ff ff       	jmp    80105a37 <alltraps>

801068cb <vector231>:
801068cb:	6a 00                	push   $0x0
801068cd:	68 e7 00 00 00       	push   $0xe7
801068d2:	e9 60 f1 ff ff       	jmp    80105a37 <alltraps>

801068d7 <vector232>:
801068d7:	6a 00                	push   $0x0
801068d9:	68 e8 00 00 00       	push   $0xe8
801068de:	e9 54 f1 ff ff       	jmp    80105a37 <alltraps>

801068e3 <vector233>:
801068e3:	6a 00                	push   $0x0
801068e5:	68 e9 00 00 00       	push   $0xe9
801068ea:	e9 48 f1 ff ff       	jmp    80105a37 <alltraps>

801068ef <vector234>:
801068ef:	6a 00                	push   $0x0
801068f1:	68 ea 00 00 00       	push   $0xea
801068f6:	e9 3c f1 ff ff       	jmp    80105a37 <alltraps>

801068fb <vector235>:
801068fb:	6a 00                	push   $0x0
801068fd:	68 eb 00 00 00       	push   $0xeb
80106902:	e9 30 f1 ff ff       	jmp    80105a37 <alltraps>

80106907 <vector236>:
80106907:	6a 00                	push   $0x0
80106909:	68 ec 00 00 00       	push   $0xec
8010690e:	e9 24 f1 ff ff       	jmp    80105a37 <alltraps>

80106913 <vector237>:
80106913:	6a 00                	push   $0x0
80106915:	68 ed 00 00 00       	push   $0xed
8010691a:	e9 18 f1 ff ff       	jmp    80105a37 <alltraps>

8010691f <vector238>:
8010691f:	6a 00                	push   $0x0
80106921:	68 ee 00 00 00       	push   $0xee
80106926:	e9 0c f1 ff ff       	jmp    80105a37 <alltraps>

8010692b <vector239>:
8010692b:	6a 00                	push   $0x0
8010692d:	68 ef 00 00 00       	push   $0xef
80106932:	e9 00 f1 ff ff       	jmp    80105a37 <alltraps>

80106937 <vector240>:
80106937:	6a 00                	push   $0x0
80106939:	68 f0 00 00 00       	push   $0xf0
8010693e:	e9 f4 f0 ff ff       	jmp    80105a37 <alltraps>

80106943 <vector241>:
80106943:	6a 00                	push   $0x0
80106945:	68 f1 00 00 00       	push   $0xf1
8010694a:	e9 e8 f0 ff ff       	jmp    80105a37 <alltraps>

8010694f <vector242>:
8010694f:	6a 00                	push   $0x0
80106951:	68 f2 00 00 00       	push   $0xf2
80106956:	e9 dc f0 ff ff       	jmp    80105a37 <alltraps>

8010695b <vector243>:
8010695b:	6a 00                	push   $0x0
8010695d:	68 f3 00 00 00       	push   $0xf3
80106962:	e9 d0 f0 ff ff       	jmp    80105a37 <alltraps>

80106967 <vector244>:
80106967:	6a 00                	push   $0x0
80106969:	68 f4 00 00 00       	push   $0xf4
8010696e:	e9 c4 f0 ff ff       	jmp    80105a37 <alltraps>

80106973 <vector245>:
80106973:	6a 00                	push   $0x0
80106975:	68 f5 00 00 00       	push   $0xf5
8010697a:	e9 b8 f0 ff ff       	jmp    80105a37 <alltraps>

8010697f <vector246>:
8010697f:	6a 00                	push   $0x0
80106981:	68 f6 00 00 00       	push   $0xf6
80106986:	e9 ac f0 ff ff       	jmp    80105a37 <alltraps>

8010698b <vector247>:
8010698b:	6a 00                	push   $0x0
8010698d:	68 f7 00 00 00       	push   $0xf7
80106992:	e9 a0 f0 ff ff       	jmp    80105a37 <alltraps>

80106997 <vector248>:
80106997:	6a 00                	push   $0x0
80106999:	68 f8 00 00 00       	push   $0xf8
8010699e:	e9 94 f0 ff ff       	jmp    80105a37 <alltraps>

801069a3 <vector249>:
801069a3:	6a 00                	push   $0x0
801069a5:	68 f9 00 00 00       	push   $0xf9
801069aa:	e9 88 f0 ff ff       	jmp    80105a37 <alltraps>

801069af <vector250>:
801069af:	6a 00                	push   $0x0
801069b1:	68 fa 00 00 00       	push   $0xfa
801069b6:	e9 7c f0 ff ff       	jmp    80105a37 <alltraps>

801069bb <vector251>:
801069bb:	6a 00                	push   $0x0
801069bd:	68 fb 00 00 00       	push   $0xfb
801069c2:	e9 70 f0 ff ff       	jmp    80105a37 <alltraps>

801069c7 <vector252>:
801069c7:	6a 00                	push   $0x0
801069c9:	68 fc 00 00 00       	push   $0xfc
801069ce:	e9 64 f0 ff ff       	jmp    80105a37 <alltraps>

801069d3 <vector253>:
801069d3:	6a 00                	push   $0x0
801069d5:	68 fd 00 00 00       	push   $0xfd
801069da:	e9 58 f0 ff ff       	jmp    80105a37 <alltraps>

801069df <vector254>:
801069df:	6a 00                	push   $0x0
801069e1:	68 fe 00 00 00       	push   $0xfe
801069e6:	e9 4c f0 ff ff       	jmp    80105a37 <alltraps>

801069eb <vector255>:
801069eb:	6a 00                	push   $0x0
801069ed:	68 ff 00 00 00       	push   $0xff
801069f2:	e9 40 f0 ff ff       	jmp    80105a37 <alltraps>
801069f7:	66 90                	xchg   %ax,%ax
801069f9:	66 90                	xchg   %ax,%ax
801069fb:	66 90                	xchg   %ax,%ax
801069fd:	66 90                	xchg   %ax,%ax
801069ff:	90                   	nop

80106a00 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106a00:	55                   	push   %ebp
80106a01:	89 e5                	mov    %esp,%ebp
80106a03:	57                   	push   %edi
80106a04:	56                   	push   %esi
80106a05:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80106a06:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
80106a0c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106a12:	83 ec 1c             	sub    $0x1c,%esp
80106a15:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106a18:	39 d3                	cmp    %edx,%ebx
80106a1a:	73 45                	jae    80106a61 <deallocuvm.part.0+0x61>
80106a1c:	89 c7                	mov    %eax,%edi
80106a1e:	eb 0a                	jmp    80106a2a <deallocuvm.part.0+0x2a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106a20:	8d 59 01             	lea    0x1(%ecx),%ebx
80106a23:	c1 e3 16             	shl    $0x16,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106a26:	39 da                	cmp    %ebx,%edx
80106a28:	76 37                	jbe    80106a61 <deallocuvm.part.0+0x61>
  pde = &pgdir[PDX(va)];
80106a2a:	89 d9                	mov    %ebx,%ecx
80106a2c:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
80106a2f:	8b 04 8f             	mov    (%edi,%ecx,4),%eax
80106a32:	a8 01                	test   $0x1,%al
80106a34:	74 ea                	je     80106a20 <deallocuvm.part.0+0x20>
  return &pgtab[PTX(va)];
80106a36:	89 de                	mov    %ebx,%esi
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106a38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80106a3d:	c1 ee 0a             	shr    $0xa,%esi
80106a40:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
80106a46:	8d b4 30 00 00 00 80 	lea    -0x80000000(%eax,%esi,1),%esi
    if(!pte)
80106a4d:	85 f6                	test   %esi,%esi
80106a4f:	74 cf                	je     80106a20 <deallocuvm.part.0+0x20>
    else if((*pte & PTE_P) != 0){
80106a51:	8b 06                	mov    (%esi),%eax
80106a53:	a8 01                	test   $0x1,%al
80106a55:	75 19                	jne    80106a70 <deallocuvm.part.0+0x70>
  for(; a  < oldsz; a += PGSIZE){
80106a57:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106a5d:	39 da                	cmp    %ebx,%edx
80106a5f:	77 c9                	ja     80106a2a <deallocuvm.part.0+0x2a>
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
}
80106a61:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106a64:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106a67:	5b                   	pop    %ebx
80106a68:	5e                   	pop    %esi
80106a69:	5f                   	pop    %edi
80106a6a:	5d                   	pop    %ebp
80106a6b:	c3                   	ret    
80106a6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(pa == 0)
80106a70:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106a75:	74 25                	je     80106a9c <deallocuvm.part.0+0x9c>
      kfree(v);
80106a77:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
80106a7a:	05 00 00 00 80       	add    $0x80000000,%eax
80106a7f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106a82:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      kfree(v);
80106a88:	50                   	push   %eax
80106a89:	e8 52 bb ff ff       	call   801025e0 <kfree>
      *pte = 0;
80106a8e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  for(; a  < oldsz; a += PGSIZE){
80106a94:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106a97:	83 c4 10             	add    $0x10,%esp
80106a9a:	eb 8a                	jmp    80106a26 <deallocuvm.part.0+0x26>
        panic("kfree");
80106a9c:	83 ec 0c             	sub    $0xc,%esp
80106a9f:	68 66 76 10 80       	push   $0x80107666
80106aa4:	e8 d7 98 ff ff       	call   80100380 <panic>
80106aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106ab0 <mappages>:
{
80106ab0:	55                   	push   %ebp
80106ab1:	89 e5                	mov    %esp,%ebp
80106ab3:	57                   	push   %edi
80106ab4:	56                   	push   %esi
80106ab5:	53                   	push   %ebx
  a = (char*)PGROUNDDOWN((uint)va);
80106ab6:	89 d3                	mov    %edx,%ebx
80106ab8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
{
80106abe:	83 ec 1c             	sub    $0x1c,%esp
80106ac1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106ac4:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
80106ac8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106acd:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ad3:	29 d8                	sub    %ebx,%eax
80106ad5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106ad8:	eb 3d                	jmp    80106b17 <mappages+0x67>
80106ada:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80106ae0:	89 da                	mov    %ebx,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106ae2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80106ae7:	c1 ea 0a             	shr    $0xa,%edx
80106aea:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80106af0:	8d 94 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%edx
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106af7:	85 d2                	test   %edx,%edx
80106af9:	74 75                	je     80106b70 <mappages+0xc0>
    if(*pte & PTE_P)
80106afb:	f6 02 01             	testb  $0x1,(%edx)
80106afe:	0f 85 86 00 00 00    	jne    80106b8a <mappages+0xda>
    *pte = pa | perm | PTE_P;
80106b04:	0b 75 0c             	or     0xc(%ebp),%esi
80106b07:	83 ce 01             	or     $0x1,%esi
80106b0a:	89 32                	mov    %esi,(%edx)
    if(a == last)
80106b0c:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
80106b0f:	74 6f                	je     80106b80 <mappages+0xd0>
    a += PGSIZE;
80106b11:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  for(;;){
80106b17:	8b 45 e0             	mov    -0x20(%ebp),%eax
  pde = &pgdir[PDX(va)];
80106b1a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80106b1d:	8d 34 18             	lea    (%eax,%ebx,1),%esi
80106b20:	89 d8                	mov    %ebx,%eax
80106b22:	c1 e8 16             	shr    $0x16,%eax
80106b25:	8d 3c 81             	lea    (%ecx,%eax,4),%edi
  if(*pde & PTE_P){
80106b28:	8b 07                	mov    (%edi),%eax
80106b2a:	a8 01                	test   $0x1,%al
80106b2c:	75 b2                	jne    80106ae0 <mappages+0x30>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106b2e:	e8 6d bc ff ff       	call   801027a0 <kalloc>
80106b33:	85 c0                	test   %eax,%eax
80106b35:	74 39                	je     80106b70 <mappages+0xc0>
    memset(pgtab, 0, PGSIZE);
80106b37:	83 ec 04             	sub    $0x4,%esp
80106b3a:	89 45 d8             	mov    %eax,-0x28(%ebp)
80106b3d:	68 00 10 00 00       	push   $0x1000
80106b42:	6a 00                	push   $0x0
80106b44:	50                   	push   %eax
80106b45:	e8 76 dc ff ff       	call   801047c0 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106b4a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  return &pgtab[PTX(va)];
80106b4d:	83 c4 10             	add    $0x10,%esp
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106b50:	8d 82 00 00 00 80    	lea    -0x80000000(%edx),%eax
80106b56:	83 c8 07             	or     $0x7,%eax
80106b59:	89 07                	mov    %eax,(%edi)
  return &pgtab[PTX(va)];
80106b5b:	89 d8                	mov    %ebx,%eax
80106b5d:	c1 e8 0a             	shr    $0xa,%eax
80106b60:	25 fc 0f 00 00       	and    $0xffc,%eax
80106b65:	01 c2                	add    %eax,%edx
80106b67:	eb 92                	jmp    80106afb <mappages+0x4b>
80106b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}
80106b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106b73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106b78:	5b                   	pop    %ebx
80106b79:	5e                   	pop    %esi
80106b7a:	5f                   	pop    %edi
80106b7b:	5d                   	pop    %ebp
80106b7c:	c3                   	ret    
80106b7d:	8d 76 00             	lea    0x0(%esi),%esi
80106b80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106b83:	31 c0                	xor    %eax,%eax
}
80106b85:	5b                   	pop    %ebx
80106b86:	5e                   	pop    %esi
80106b87:	5f                   	pop    %edi
80106b88:	5d                   	pop    %ebp
80106b89:	c3                   	ret    
      panic("remap");
80106b8a:	83 ec 0c             	sub    $0xc,%esp
80106b8d:	68 b0 7c 10 80       	push   $0x80107cb0
80106b92:	e8 e9 97 ff ff       	call   80100380 <panic>
80106b97:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106b9e:	66 90                	xchg   %ax,%ax

80106ba0 <seginit>:
{
80106ba0:	55                   	push   %ebp
80106ba1:	89 e5                	mov    %esp,%ebp
80106ba3:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
80106ba6:	e8 05 cf ff ff       	call   80103ab0 <cpuid>
  pd[0] = size-1;
80106bab:	ba 2f 00 00 00       	mov    $0x2f,%edx
80106bb0:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106bb6:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106bba:	c7 80 18 18 11 80 ff 	movl   $0xffff,-0x7feee7e8(%eax)
80106bc1:	ff 00 00 
80106bc4:	c7 80 1c 18 11 80 00 	movl   $0xcf9a00,-0x7feee7e4(%eax)
80106bcb:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106bce:	c7 80 20 18 11 80 ff 	movl   $0xffff,-0x7feee7e0(%eax)
80106bd5:	ff 00 00 
80106bd8:	c7 80 24 18 11 80 00 	movl   $0xcf9200,-0x7feee7dc(%eax)
80106bdf:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106be2:	c7 80 28 18 11 80 ff 	movl   $0xffff,-0x7feee7d8(%eax)
80106be9:	ff 00 00 
80106bec:	c7 80 2c 18 11 80 00 	movl   $0xcffa00,-0x7feee7d4(%eax)
80106bf3:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106bf6:	c7 80 30 18 11 80 ff 	movl   $0xffff,-0x7feee7d0(%eax)
80106bfd:	ff 00 00 
80106c00:	c7 80 34 18 11 80 00 	movl   $0xcff200,-0x7feee7cc(%eax)
80106c07:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
80106c0a:	05 10 18 11 80       	add    $0x80111810,%eax
  pd[1] = (uint)p;
80106c0f:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106c13:	c1 e8 10             	shr    $0x10,%eax
80106c16:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106c1a:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106c1d:	0f 01 10             	lgdtl  (%eax)
}
80106c20:	c9                   	leave  
80106c21:	c3                   	ret    
80106c22:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106c30 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106c30:	a1 c4 47 11 80       	mov    0x801147c4,%eax
80106c35:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106c3a:	0f 22 d8             	mov    %eax,%cr3
}
80106c3d:	c3                   	ret    
80106c3e:	66 90                	xchg   %ax,%ax

80106c40 <switchuvm>:
{
80106c40:	55                   	push   %ebp
80106c41:	89 e5                	mov    %esp,%ebp
80106c43:	57                   	push   %edi
80106c44:	56                   	push   %esi
80106c45:	53                   	push   %ebx
80106c46:	83 ec 1c             	sub    $0x1c,%esp
80106c49:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106c4c:	85 f6                	test   %esi,%esi
80106c4e:	0f 84 cb 00 00 00    	je     80106d1f <switchuvm+0xdf>
  if(p->kstack == 0)
80106c54:	8b 46 08             	mov    0x8(%esi),%eax
80106c57:	85 c0                	test   %eax,%eax
80106c59:	0f 84 da 00 00 00    	je     80106d39 <switchuvm+0xf9>
  if(p->pgdir == 0)
80106c5f:	8b 46 04             	mov    0x4(%esi),%eax
80106c62:	85 c0                	test   %eax,%eax
80106c64:	0f 84 c2 00 00 00    	je     80106d2c <switchuvm+0xec>
  pushcli();
80106c6a:	e8 41 d9 ff ff       	call   801045b0 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106c6f:	e8 cc cd ff ff       	call   80103a40 <mycpu>
80106c74:	89 c3                	mov    %eax,%ebx
80106c76:	e8 c5 cd ff ff       	call   80103a40 <mycpu>
80106c7b:	89 c7                	mov    %eax,%edi
80106c7d:	e8 be cd ff ff       	call   80103a40 <mycpu>
80106c82:	83 c7 08             	add    $0x8,%edi
80106c85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106c88:	e8 b3 cd ff ff       	call   80103a40 <mycpu>
80106c8d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80106c90:	ba 67 00 00 00       	mov    $0x67,%edx
80106c95:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106c9c:	83 c0 08             	add    $0x8,%eax
80106c9f:	66 89 93 98 00 00 00 	mov    %dx,0x98(%ebx)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106ca6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106cab:	83 c1 08             	add    $0x8,%ecx
80106cae:	c1 e8 18             	shr    $0x18,%eax
80106cb1:	c1 e9 10             	shr    $0x10,%ecx
80106cb4:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
80106cba:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106cc0:	b9 99 40 00 00       	mov    $0x4099,%ecx
80106cc5:	66 89 8b 9d 00 00 00 	mov    %cx,0x9d(%ebx)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106ccc:	bb 10 00 00 00       	mov    $0x10,%ebx
  mycpu()->gdt[SEG_TSS].s = 0;
80106cd1:	e8 6a cd ff ff       	call   80103a40 <mycpu>
80106cd6:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106cdd:	e8 5e cd ff ff       	call   80103a40 <mycpu>
80106ce2:	66 89 58 10          	mov    %bx,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106ce6:	8b 5e 08             	mov    0x8(%esi),%ebx
80106ce9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106cef:	e8 4c cd ff ff       	call   80103a40 <mycpu>
80106cf4:	89 58 0c             	mov    %ebx,0xc(%eax)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106cf7:	e8 44 cd ff ff       	call   80103a40 <mycpu>
80106cfc:	66 89 78 6e          	mov    %di,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106d00:	b8 28 00 00 00       	mov    $0x28,%eax
80106d05:	0f 00 d8             	ltr    %ax
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106d08:	8b 46 04             	mov    0x4(%esi),%eax
80106d0b:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106d10:	0f 22 d8             	mov    %eax,%cr3
}
80106d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106d16:	5b                   	pop    %ebx
80106d17:	5e                   	pop    %esi
80106d18:	5f                   	pop    %edi
80106d19:	5d                   	pop    %ebp
  popcli();
80106d1a:	e9 e1 d8 ff ff       	jmp    80104600 <popcli>
    panic("switchuvm: no process");
80106d1f:	83 ec 0c             	sub    $0xc,%esp
80106d22:	68 b6 7c 10 80       	push   $0x80107cb6
80106d27:	e8 54 96 ff ff       	call   80100380 <panic>
    panic("switchuvm: no pgdir");
80106d2c:	83 ec 0c             	sub    $0xc,%esp
80106d2f:	68 e1 7c 10 80       	push   $0x80107ce1
80106d34:	e8 47 96 ff ff       	call   80100380 <panic>
    panic("switchuvm: no kstack");
80106d39:	83 ec 0c             	sub    $0xc,%esp
80106d3c:	68 cc 7c 10 80       	push   $0x80107ccc
80106d41:	e8 3a 96 ff ff       	call   80100380 <panic>
80106d46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106d4d:	8d 76 00             	lea    0x0(%esi),%esi

80106d50 <inituvm>:
{
80106d50:	55                   	push   %ebp
80106d51:	89 e5                	mov    %esp,%ebp
80106d53:	57                   	push   %edi
80106d54:	56                   	push   %esi
80106d55:	53                   	push   %ebx
80106d56:	83 ec 1c             	sub    $0x1c,%esp
80106d59:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d5c:	8b 75 10             	mov    0x10(%ebp),%esi
80106d5f:	8b 7d 08             	mov    0x8(%ebp),%edi
80106d62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
80106d65:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106d6b:	77 4b                	ja     80106db8 <inituvm+0x68>
  mem = kalloc();
80106d6d:	e8 2e ba ff ff       	call   801027a0 <kalloc>
  memset(mem, 0, PGSIZE);
80106d72:	83 ec 04             	sub    $0x4,%esp
80106d75:	68 00 10 00 00       	push   $0x1000
  mem = kalloc();
80106d7a:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106d7c:	6a 00                	push   $0x0
80106d7e:	50                   	push   %eax
80106d7f:	e8 3c da ff ff       	call   801047c0 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106d84:	58                   	pop    %eax
80106d85:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106d8b:	5a                   	pop    %edx
80106d8c:	6a 06                	push   $0x6
80106d8e:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106d93:	31 d2                	xor    %edx,%edx
80106d95:	50                   	push   %eax
80106d96:	89 f8                	mov    %edi,%eax
80106d98:	e8 13 fd ff ff       	call   80106ab0 <mappages>
  memmove(mem, init, sz);
80106d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106da0:	89 75 10             	mov    %esi,0x10(%ebp)
80106da3:	83 c4 10             	add    $0x10,%esp
80106da6:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106da9:	89 45 0c             	mov    %eax,0xc(%ebp)
}
80106dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106daf:	5b                   	pop    %ebx
80106db0:	5e                   	pop    %esi
80106db1:	5f                   	pop    %edi
80106db2:	5d                   	pop    %ebp
  memmove(mem, init, sz);
80106db3:	e9 a8 da ff ff       	jmp    80104860 <memmove>
    panic("inituvm: more than a page");
80106db8:	83 ec 0c             	sub    $0xc,%esp
80106dbb:	68 f5 7c 10 80       	push   $0x80107cf5
80106dc0:	e8 bb 95 ff ff       	call   80100380 <panic>
80106dc5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106dd0 <loaduvm>:
{
80106dd0:	55                   	push   %ebp
80106dd1:	89 e5                	mov    %esp,%ebp
80106dd3:	57                   	push   %edi
80106dd4:	56                   	push   %esi
80106dd5:	53                   	push   %ebx
80106dd6:	83 ec 1c             	sub    $0x1c,%esp
80106dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ddc:	8b 75 18             	mov    0x18(%ebp),%esi
  if((uint) addr % PGSIZE != 0)
80106ddf:	a9 ff 0f 00 00       	test   $0xfff,%eax
80106de4:	0f 85 bb 00 00 00    	jne    80106ea5 <loaduvm+0xd5>
  for(i = 0; i < sz; i += PGSIZE){
80106dea:	01 f0                	add    %esi,%eax
80106dec:	89 f3                	mov    %esi,%ebx
80106dee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106df1:	8b 45 14             	mov    0x14(%ebp),%eax
80106df4:	01 f0                	add    %esi,%eax
80106df6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sz; i += PGSIZE){
80106df9:	85 f6                	test   %esi,%esi
80106dfb:	0f 84 87 00 00 00    	je     80106e88 <loaduvm+0xb8>
80106e01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  pde = &pgdir[PDX(va)];
80106e08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  if(*pde & PTE_P){
80106e0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106e0e:	29 d8                	sub    %ebx,%eax
  pde = &pgdir[PDX(va)];
80106e10:	89 c2                	mov    %eax,%edx
80106e12:	c1 ea 16             	shr    $0x16,%edx
  if(*pde & PTE_P){
80106e15:	8b 14 91             	mov    (%ecx,%edx,4),%edx
80106e18:	f6 c2 01             	test   $0x1,%dl
80106e1b:	75 13                	jne    80106e30 <loaduvm+0x60>
      panic("loaduvm: address should exist");
80106e1d:	83 ec 0c             	sub    $0xc,%esp
80106e20:	68 0f 7d 10 80       	push   $0x80107d0f
80106e25:	e8 56 95 ff ff       	call   80100380 <panic>
80106e2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80106e30:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106e33:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80106e39:	25 fc 0f 00 00       	and    $0xffc,%eax
80106e3e:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106e45:	85 c0                	test   %eax,%eax
80106e47:	74 d4                	je     80106e1d <loaduvm+0x4d>
    pa = PTE_ADDR(*pte);
80106e49:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106e4b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
    if(sz - i < PGSIZE)
80106e4e:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
80106e53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106e58:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
80106e5e:	0f 46 fb             	cmovbe %ebx,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106e61:	29 d9                	sub    %ebx,%ecx
80106e63:	05 00 00 00 80       	add    $0x80000000,%eax
80106e68:	57                   	push   %edi
80106e69:	51                   	push   %ecx
80106e6a:	50                   	push   %eax
80106e6b:	ff 75 10             	push   0x10(%ebp)
80106e6e:	e8 3d ad ff ff       	call   80101bb0 <readi>
80106e73:	83 c4 10             	add    $0x10,%esp
80106e76:	39 f8                	cmp    %edi,%eax
80106e78:	75 1e                	jne    80106e98 <loaduvm+0xc8>
  for(i = 0; i < sz; i += PGSIZE){
80106e7a:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
80106e80:	89 f0                	mov    %esi,%eax
80106e82:	29 d8                	sub    %ebx,%eax
80106e84:	39 c6                	cmp    %eax,%esi
80106e86:	77 80                	ja     80106e08 <loaduvm+0x38>
}
80106e88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106e8b:	31 c0                	xor    %eax,%eax
}
80106e8d:	5b                   	pop    %ebx
80106e8e:	5e                   	pop    %esi
80106e8f:	5f                   	pop    %edi
80106e90:	5d                   	pop    %ebp
80106e91:	c3                   	ret    
80106e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106e98:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106e9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106ea0:	5b                   	pop    %ebx
80106ea1:	5e                   	pop    %esi
80106ea2:	5f                   	pop    %edi
80106ea3:	5d                   	pop    %ebp
80106ea4:	c3                   	ret    
    panic("loaduvm: addr must be page aligned");
80106ea5:	83 ec 0c             	sub    $0xc,%esp
80106ea8:	68 b0 7d 10 80       	push   $0x80107db0
80106ead:	e8 ce 94 ff ff       	call   80100380 <panic>
80106eb2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106ec0 <allocuvm>:
{
80106ec0:	55                   	push   %ebp
80106ec1:	89 e5                	mov    %esp,%ebp
80106ec3:	57                   	push   %edi
80106ec4:	56                   	push   %esi
80106ec5:	53                   	push   %ebx
80106ec6:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
80106ec9:	8b 45 10             	mov    0x10(%ebp),%eax
{
80106ecc:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
80106ecf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106ed2:	85 c0                	test   %eax,%eax
80106ed4:	0f 88 b6 00 00 00    	js     80106f90 <allocuvm+0xd0>
  if(newsz < oldsz)
80106eda:	3b 45 0c             	cmp    0xc(%ebp),%eax
    return oldsz;
80106edd:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(newsz < oldsz)
80106ee0:	0f 82 9a 00 00 00    	jb     80106f80 <allocuvm+0xc0>
  a = PGROUNDUP(oldsz);
80106ee6:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80106eec:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80106ef2:	39 75 10             	cmp    %esi,0x10(%ebp)
80106ef5:	77 44                	ja     80106f3b <allocuvm+0x7b>
80106ef7:	e9 87 00 00 00       	jmp    80106f83 <allocuvm+0xc3>
80106efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    memset(mem, 0, PGSIZE);
80106f00:	83 ec 04             	sub    $0x4,%esp
80106f03:	68 00 10 00 00       	push   $0x1000
80106f08:	6a 00                	push   $0x0
80106f0a:	50                   	push   %eax
80106f0b:	e8 b0 d8 ff ff       	call   801047c0 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106f10:	58                   	pop    %eax
80106f11:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106f17:	5a                   	pop    %edx
80106f18:	6a 06                	push   $0x6
80106f1a:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106f1f:	89 f2                	mov    %esi,%edx
80106f21:	50                   	push   %eax
80106f22:	89 f8                	mov    %edi,%eax
80106f24:	e8 87 fb ff ff       	call   80106ab0 <mappages>
80106f29:	83 c4 10             	add    $0x10,%esp
80106f2c:	85 c0                	test   %eax,%eax
80106f2e:	78 78                	js     80106fa8 <allocuvm+0xe8>
  for(; a < newsz; a += PGSIZE){
80106f30:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106f36:	39 75 10             	cmp    %esi,0x10(%ebp)
80106f39:	76 48                	jbe    80106f83 <allocuvm+0xc3>
    mem = kalloc();
80106f3b:	e8 60 b8 ff ff       	call   801027a0 <kalloc>
80106f40:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106f42:	85 c0                	test   %eax,%eax
80106f44:	75 ba                	jne    80106f00 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
80106f46:	83 ec 0c             	sub    $0xc,%esp
80106f49:	68 2d 7d 10 80       	push   $0x80107d2d
80106f4e:	e8 2d 97 ff ff       	call   80100680 <cprintf>
  if(newsz >= oldsz)
80106f53:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f56:	83 c4 10             	add    $0x10,%esp
80106f59:	39 45 10             	cmp    %eax,0x10(%ebp)
80106f5c:	74 32                	je     80106f90 <allocuvm+0xd0>
80106f5e:	8b 55 10             	mov    0x10(%ebp),%edx
80106f61:	89 c1                	mov    %eax,%ecx
80106f63:	89 f8                	mov    %edi,%eax
80106f65:	e8 96 fa ff ff       	call   80106a00 <deallocuvm.part.0>
      return 0;
80106f6a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106f71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f74:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f77:	5b                   	pop    %ebx
80106f78:	5e                   	pop    %esi
80106f79:	5f                   	pop    %edi
80106f7a:	5d                   	pop    %ebp
80106f7b:	c3                   	ret    
80106f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return oldsz;
80106f80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}
80106f83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f86:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f89:	5b                   	pop    %ebx
80106f8a:	5e                   	pop    %esi
80106f8b:	5f                   	pop    %edi
80106f8c:	5d                   	pop    %ebp
80106f8d:	c3                   	ret    
80106f8e:	66 90                	xchg   %ax,%ax
    return 0;
80106f90:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106f97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f9d:	5b                   	pop    %ebx
80106f9e:	5e                   	pop    %esi
80106f9f:	5f                   	pop    %edi
80106fa0:	5d                   	pop    %ebp
80106fa1:	c3                   	ret    
80106fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      cprintf("allocuvm out of memory (2)\n");
80106fa8:	83 ec 0c             	sub    $0xc,%esp
80106fab:	68 45 7d 10 80       	push   $0x80107d45
80106fb0:	e8 cb 96 ff ff       	call   80100680 <cprintf>
  if(newsz >= oldsz)
80106fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fb8:	83 c4 10             	add    $0x10,%esp
80106fbb:	39 45 10             	cmp    %eax,0x10(%ebp)
80106fbe:	74 0c                	je     80106fcc <allocuvm+0x10c>
80106fc0:	8b 55 10             	mov    0x10(%ebp),%edx
80106fc3:	89 c1                	mov    %eax,%ecx
80106fc5:	89 f8                	mov    %edi,%eax
80106fc7:	e8 34 fa ff ff       	call   80106a00 <deallocuvm.part.0>
      kfree(mem);
80106fcc:	83 ec 0c             	sub    $0xc,%esp
80106fcf:	53                   	push   %ebx
80106fd0:	e8 0b b6 ff ff       	call   801025e0 <kfree>
      return 0;
80106fd5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106fdc:	83 c4 10             	add    $0x10,%esp
}
80106fdf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106fe2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106fe5:	5b                   	pop    %ebx
80106fe6:	5e                   	pop    %esi
80106fe7:	5f                   	pop    %edi
80106fe8:	5d                   	pop    %ebp
80106fe9:	c3                   	ret    
80106fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106ff0 <deallocuvm>:
{
80106ff0:	55                   	push   %ebp
80106ff1:	89 e5                	mov    %esp,%ebp
80106ff3:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ff6:	8b 4d 10             	mov    0x10(%ebp),%ecx
80106ff9:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
80106ffc:	39 d1                	cmp    %edx,%ecx
80106ffe:	73 10                	jae    80107010 <deallocuvm+0x20>
}
80107000:	5d                   	pop    %ebp
80107001:	e9 fa f9 ff ff       	jmp    80106a00 <deallocuvm.part.0>
80107006:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010700d:	8d 76 00             	lea    0x0(%esi),%esi
80107010:	89 d0                	mov    %edx,%eax
80107012:	5d                   	pop    %ebp
80107013:	c3                   	ret    
80107014:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010701b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010701f:	90                   	nop

80107020 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107020:	55                   	push   %ebp
80107021:	89 e5                	mov    %esp,%ebp
80107023:	57                   	push   %edi
80107024:	56                   	push   %esi
80107025:	53                   	push   %ebx
80107026:	83 ec 0c             	sub    $0xc,%esp
80107029:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010702c:	85 f6                	test   %esi,%esi
8010702e:	74 59                	je     80107089 <freevm+0x69>
  if(newsz >= oldsz)
80107030:	31 c9                	xor    %ecx,%ecx
80107032:	ba 00 00 00 80       	mov    $0x80000000,%edx
80107037:	89 f0                	mov    %esi,%eax
80107039:	89 f3                	mov    %esi,%ebx
8010703b:	e8 c0 f9 ff ff       	call   80106a00 <deallocuvm.part.0>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107040:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
80107046:	eb 0f                	jmp    80107057 <freevm+0x37>
80107048:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010704f:	90                   	nop
80107050:	83 c3 04             	add    $0x4,%ebx
80107053:	39 df                	cmp    %ebx,%edi
80107055:	74 23                	je     8010707a <freevm+0x5a>
    if(pgdir[i] & PTE_P){
80107057:	8b 03                	mov    (%ebx),%eax
80107059:	a8 01                	test   $0x1,%al
8010705b:	74 f3                	je     80107050 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010705d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
80107062:	83 ec 0c             	sub    $0xc,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107065:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107068:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010706d:	50                   	push   %eax
8010706e:	e8 6d b5 ff ff       	call   801025e0 <kfree>
80107073:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107076:	39 df                	cmp    %ebx,%edi
80107078:	75 dd                	jne    80107057 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010707a:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010707d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107080:	5b                   	pop    %ebx
80107081:	5e                   	pop    %esi
80107082:	5f                   	pop    %edi
80107083:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80107084:	e9 57 b5 ff ff       	jmp    801025e0 <kfree>
    panic("freevm: no pgdir");
80107089:	83 ec 0c             	sub    $0xc,%esp
8010708c:	68 61 7d 10 80       	push   $0x80107d61
80107091:	e8 ea 92 ff ff       	call   80100380 <panic>
80107096:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010709d:	8d 76 00             	lea    0x0(%esi),%esi

801070a0 <setupkvm>:
{
801070a0:	55                   	push   %ebp
801070a1:	89 e5                	mov    %esp,%ebp
801070a3:	56                   	push   %esi
801070a4:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801070a5:	e8 f6 b6 ff ff       	call   801027a0 <kalloc>
801070aa:	89 c6                	mov    %eax,%esi
801070ac:	85 c0                	test   %eax,%eax
801070ae:	74 42                	je     801070f2 <setupkvm+0x52>
  memset(pgdir, 0, PGSIZE);
801070b0:	83 ec 04             	sub    $0x4,%esp
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801070b3:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
  memset(pgdir, 0, PGSIZE);
801070b8:	68 00 10 00 00       	push   $0x1000
801070bd:	6a 00                	push   $0x0
801070bf:	50                   	push   %eax
801070c0:	e8 fb d6 ff ff       	call   801047c0 <memset>
801070c5:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0) {
801070c8:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801070cb:	83 ec 08             	sub    $0x8,%esp
801070ce:	8b 4b 08             	mov    0x8(%ebx),%ecx
801070d1:	ff 73 0c             	push   0xc(%ebx)
801070d4:	8b 13                	mov    (%ebx),%edx
801070d6:	50                   	push   %eax
801070d7:	29 c1                	sub    %eax,%ecx
801070d9:	89 f0                	mov    %esi,%eax
801070db:	e8 d0 f9 ff ff       	call   80106ab0 <mappages>
801070e0:	83 c4 10             	add    $0x10,%esp
801070e3:	85 c0                	test   %eax,%eax
801070e5:	78 19                	js     80107100 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801070e7:	83 c3 10             	add    $0x10,%ebx
801070ea:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
801070f0:	75 d6                	jne    801070c8 <setupkvm+0x28>
}
801070f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801070f5:	89 f0                	mov    %esi,%eax
801070f7:	5b                   	pop    %ebx
801070f8:	5e                   	pop    %esi
801070f9:	5d                   	pop    %ebp
801070fa:	c3                   	ret    
801070fb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801070ff:	90                   	nop
      freevm(pgdir);
80107100:	83 ec 0c             	sub    $0xc,%esp
80107103:	56                   	push   %esi
      return 0;
80107104:	31 f6                	xor    %esi,%esi
      freevm(pgdir);
80107106:	e8 15 ff ff ff       	call   80107020 <freevm>
      return 0;
8010710b:	83 c4 10             	add    $0x10,%esp
}
8010710e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107111:	89 f0                	mov    %esi,%eax
80107113:	5b                   	pop    %ebx
80107114:	5e                   	pop    %esi
80107115:	5d                   	pop    %ebp
80107116:	c3                   	ret    
80107117:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010711e:	66 90                	xchg   %ax,%ax

80107120 <kvmalloc>:
{
80107120:	55                   	push   %ebp
80107121:	89 e5                	mov    %esp,%ebp
80107123:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107126:	e8 75 ff ff ff       	call   801070a0 <setupkvm>
8010712b:	a3 c4 47 11 80       	mov    %eax,0x801147c4
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107130:	05 00 00 00 80       	add    $0x80000000,%eax
80107135:	0f 22 d8             	mov    %eax,%cr3
}
80107138:	c9                   	leave  
80107139:	c3                   	ret    
8010713a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107140 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107140:	55                   	push   %ebp
80107141:	89 e5                	mov    %esp,%ebp
80107143:	83 ec 08             	sub    $0x8,%esp
80107146:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
80107149:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
8010714c:	89 c1                	mov    %eax,%ecx
8010714e:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
80107151:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80107154:	f6 c2 01             	test   $0x1,%dl
80107157:	75 17                	jne    80107170 <clearpteu+0x30>
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
80107159:	83 ec 0c             	sub    $0xc,%esp
8010715c:	68 72 7d 10 80       	push   $0x80107d72
80107161:	e8 1a 92 ff ff       	call   80100380 <panic>
80107166:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010716d:	8d 76 00             	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80107170:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107173:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80107179:	25 fc 0f 00 00       	and    $0xffc,%eax
8010717e:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
  if(pte == 0)
80107185:	85 c0                	test   %eax,%eax
80107187:	74 d0                	je     80107159 <clearpteu+0x19>
  *pte &= ~PTE_U;
80107189:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010718c:	c9                   	leave  
8010718d:	c3                   	ret    
8010718e:	66 90                	xchg   %ax,%ax

80107190 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107190:	55                   	push   %ebp
80107191:	89 e5                	mov    %esp,%ebp
80107193:	57                   	push   %edi
80107194:	56                   	push   %esi
80107195:	53                   	push   %ebx
80107196:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107199:	e8 02 ff ff ff       	call   801070a0 <setupkvm>
8010719e:	89 45 e0             	mov    %eax,-0x20(%ebp)
801071a1:	85 c0                	test   %eax,%eax
801071a3:	0f 84 bd 00 00 00    	je     80107266 <copyuvm+0xd6>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801071a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801071ac:	85 c9                	test   %ecx,%ecx
801071ae:	0f 84 b2 00 00 00    	je     80107266 <copyuvm+0xd6>
801071b4:	31 f6                	xor    %esi,%esi
801071b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801071bd:	8d 76 00             	lea    0x0(%esi),%esi
  if(*pde & PTE_P){
801071c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  pde = &pgdir[PDX(va)];
801071c3:	89 f0                	mov    %esi,%eax
801071c5:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
801071c8:	8b 04 81             	mov    (%ecx,%eax,4),%eax
801071cb:	a8 01                	test   $0x1,%al
801071cd:	75 11                	jne    801071e0 <copyuvm+0x50>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
801071cf:	83 ec 0c             	sub    $0xc,%esp
801071d2:	68 7c 7d 10 80       	push   $0x80107d7c
801071d7:	e8 a4 91 ff ff       	call   80100380 <panic>
801071dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return &pgtab[PTX(va)];
801071e0:	89 f2                	mov    %esi,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801071e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
801071e7:	c1 ea 0a             	shr    $0xa,%edx
801071ea:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
801071f0:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801071f7:	85 c0                	test   %eax,%eax
801071f9:	74 d4                	je     801071cf <copyuvm+0x3f>
    if(!(*pte & PTE_P))
801071fb:	8b 00                	mov    (%eax),%eax
801071fd:	a8 01                	test   $0x1,%al
801071ff:	0f 84 9f 00 00 00    	je     801072a4 <copyuvm+0x114>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80107205:	89 c7                	mov    %eax,%edi
    flags = PTE_FLAGS(*pte);
80107207:	25 ff 0f 00 00       	and    $0xfff,%eax
8010720c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pa = PTE_ADDR(*pte);
8010720f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
80107215:	e8 86 b5 ff ff       	call   801027a0 <kalloc>
8010721a:	89 c3                	mov    %eax,%ebx
8010721c:	85 c0                	test   %eax,%eax
8010721e:	74 64                	je     80107284 <copyuvm+0xf4>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107220:	83 ec 04             	sub    $0x4,%esp
80107223:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80107229:	68 00 10 00 00       	push   $0x1000
8010722e:	57                   	push   %edi
8010722f:	50                   	push   %eax
80107230:	e8 2b d6 ff ff       	call   80104860 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80107235:	58                   	pop    %eax
80107236:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010723c:	5a                   	pop    %edx
8010723d:	ff 75 e4             	push   -0x1c(%ebp)
80107240:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107245:	89 f2                	mov    %esi,%edx
80107247:	50                   	push   %eax
80107248:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010724b:	e8 60 f8 ff ff       	call   80106ab0 <mappages>
80107250:	83 c4 10             	add    $0x10,%esp
80107253:	85 c0                	test   %eax,%eax
80107255:	78 21                	js     80107278 <copyuvm+0xe8>
  for(i = 0; i < sz; i += PGSIZE){
80107257:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010725d:	39 75 0c             	cmp    %esi,0xc(%ebp)
80107260:	0f 87 5a ff ff ff    	ja     801071c0 <copyuvm+0x30>
  return d;

bad:
  freevm(d);
  return 0;
}
80107266:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107269:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010726c:	5b                   	pop    %ebx
8010726d:	5e                   	pop    %esi
8010726e:	5f                   	pop    %edi
8010726f:	5d                   	pop    %ebp
80107270:	c3                   	ret    
80107271:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      kfree(mem);
80107278:	83 ec 0c             	sub    $0xc,%esp
8010727b:	53                   	push   %ebx
8010727c:	e8 5f b3 ff ff       	call   801025e0 <kfree>
      goto bad;
80107281:	83 c4 10             	add    $0x10,%esp
  freevm(d);
80107284:	83 ec 0c             	sub    $0xc,%esp
80107287:	ff 75 e0             	push   -0x20(%ebp)
8010728a:	e8 91 fd ff ff       	call   80107020 <freevm>
  return 0;
8010728f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80107296:	83 c4 10             	add    $0x10,%esp
}
80107299:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010729c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010729f:	5b                   	pop    %ebx
801072a0:	5e                   	pop    %esi
801072a1:	5f                   	pop    %edi
801072a2:	5d                   	pop    %ebp
801072a3:	c3                   	ret    
      panic("copyuvm: page not present");
801072a4:	83 ec 0c             	sub    $0xc,%esp
801072a7:	68 96 7d 10 80       	push   $0x80107d96
801072ac:	e8 cf 90 ff ff       	call   80100380 <panic>
801072b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801072b8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801072bf:	90                   	nop

801072c0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801072c0:	55                   	push   %ebp
801072c1:	89 e5                	mov    %esp,%ebp
801072c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
801072c6:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
801072c9:	89 c1                	mov    %eax,%ecx
801072cb:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
801072ce:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
801072d1:	f6 c2 01             	test   $0x1,%dl
801072d4:	0f 84 00 01 00 00    	je     801073da <uva2ka.cold>
  return &pgtab[PTX(va)];
801072da:	c1 e8 0c             	shr    $0xc,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801072dd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
801072e3:	5d                   	pop    %ebp
  return &pgtab[PTX(va)];
801072e4:	25 ff 03 00 00       	and    $0x3ff,%eax
  if((*pte & PTE_P) == 0)
801072e9:	8b 84 82 00 00 00 80 	mov    -0x80000000(%edx,%eax,4),%eax
  if((*pte & PTE_U) == 0)
801072f0:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
801072f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
801072f7:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
801072fa:	05 00 00 00 80       	add    $0x80000000,%eax
801072ff:	83 fa 05             	cmp    $0x5,%edx
80107302:	ba 00 00 00 00       	mov    $0x0,%edx
80107307:	0f 45 c2             	cmovne %edx,%eax
}
8010730a:	c3                   	ret    
8010730b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010730f:	90                   	nop

80107310 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107310:	55                   	push   %ebp
80107311:	89 e5                	mov    %esp,%ebp
80107313:	57                   	push   %edi
80107314:	56                   	push   %esi
80107315:	53                   	push   %ebx
80107316:	83 ec 0c             	sub    $0xc,%esp
80107319:	8b 75 14             	mov    0x14(%ebp),%esi
8010731c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010731f:	8b 55 10             	mov    0x10(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80107322:	85 f6                	test   %esi,%esi
80107324:	75 51                	jne    80107377 <copyout+0x67>
80107326:	e9 a5 00 00 00       	jmp    801073d0 <copyout+0xc0>
8010732b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010732f:	90                   	nop
  return (char*)P2V(PTE_ADDR(*pte));
80107330:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80107336:	8d 8b 00 00 00 80    	lea    -0x80000000(%ebx),%ecx
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
8010733c:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80107342:	74 75                	je     801073b9 <copyout+0xa9>
      return -1;
    n = PGSIZE - (va - va0);
80107344:	89 fb                	mov    %edi,%ebx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80107346:	89 55 10             	mov    %edx,0x10(%ebp)
    n = PGSIZE - (va - va0);
80107349:	29 c3                	sub    %eax,%ebx
8010734b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80107351:	39 f3                	cmp    %esi,%ebx
80107353:	0f 47 de             	cmova  %esi,%ebx
    memmove(pa0 + (va - va0), buf, n);
80107356:	29 f8                	sub    %edi,%eax
80107358:	83 ec 04             	sub    $0x4,%esp
8010735b:	01 c8                	add    %ecx,%eax
8010735d:	53                   	push   %ebx
8010735e:	52                   	push   %edx
8010735f:	50                   	push   %eax
80107360:	e8 fb d4 ff ff       	call   80104860 <memmove>
    len -= n;
    buf += n;
80107365:	8b 55 10             	mov    0x10(%ebp),%edx
    va = va0 + PGSIZE;
80107368:	8d 87 00 10 00 00    	lea    0x1000(%edi),%eax
  while(len > 0){
8010736e:	83 c4 10             	add    $0x10,%esp
    buf += n;
80107371:	01 da                	add    %ebx,%edx
  while(len > 0){
80107373:	29 de                	sub    %ebx,%esi
80107375:	74 59                	je     801073d0 <copyout+0xc0>
  if(*pde & PTE_P){
80107377:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pde = &pgdir[PDX(va)];
8010737a:	89 c1                	mov    %eax,%ecx
    va0 = (uint)PGROUNDDOWN(va);
8010737c:	89 c7                	mov    %eax,%edi
  pde = &pgdir[PDX(va)];
8010737e:	c1 e9 16             	shr    $0x16,%ecx
    va0 = (uint)PGROUNDDOWN(va);
80107381:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if(*pde & PTE_P){
80107387:	8b 0c 8b             	mov    (%ebx,%ecx,4),%ecx
8010738a:	f6 c1 01             	test   $0x1,%cl
8010738d:	0f 84 4e 00 00 00    	je     801073e1 <copyout.cold>
  return &pgtab[PTX(va)];
80107393:	89 fb                	mov    %edi,%ebx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107395:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
8010739b:	c1 eb 0c             	shr    $0xc,%ebx
8010739e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  if((*pte & PTE_P) == 0)
801073a4:	8b 9c 99 00 00 00 80 	mov    -0x80000000(%ecx,%ebx,4),%ebx
  if((*pte & PTE_U) == 0)
801073ab:	89 d9                	mov    %ebx,%ecx
801073ad:	83 e1 05             	and    $0x5,%ecx
801073b0:	83 f9 05             	cmp    $0x5,%ecx
801073b3:	0f 84 77 ff ff ff    	je     80107330 <copyout+0x20>
  }
  return 0;
}
801073b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
801073bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801073c1:	5b                   	pop    %ebx
801073c2:	5e                   	pop    %esi
801073c3:	5f                   	pop    %edi
801073c4:	5d                   	pop    %ebp
801073c5:	c3                   	ret    
801073c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801073cd:	8d 76 00             	lea    0x0(%esi),%esi
801073d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801073d3:	31 c0                	xor    %eax,%eax
}
801073d5:	5b                   	pop    %ebx
801073d6:	5e                   	pop    %esi
801073d7:	5f                   	pop    %edi
801073d8:	5d                   	pop    %ebp
801073d9:	c3                   	ret    

801073da <uva2ka.cold>:
  if((*pte & PTE_P) == 0)
801073da:	a1 00 00 00 00       	mov    0x0,%eax
801073df:	0f 0b                	ud2    

801073e1 <copyout.cold>:
801073e1:	a1 00 00 00 00       	mov    0x0,%eax
801073e6:	0f 0b                	ud2    
