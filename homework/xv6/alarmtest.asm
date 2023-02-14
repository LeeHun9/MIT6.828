
_alarmtest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

void periodic();

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
  int i;
  printf(1, "alarmtest starting\n");
  alarm(10, periodic);
  for(i = 0; i < 25*5000000; i++){
   e:	31 db                	xor    %ebx,%ebx
{
  10:	51                   	push   %ecx
  printf(1, "alarmtest starting\n");
  11:	83 ec 08             	sub    $0x8,%esp
  14:	68 c0 07 00 00       	push   $0x7c0
  19:	6a 01                	push   $0x1
  1b:	e8 30 04 00 00       	call   450 <printf>
  alarm(10, periodic);
  20:	58                   	pop    %eax
  21:	5a                   	pop    %edx
  22:	68 80 00 00 00       	push   $0x80
  27:	6a 0a                	push   $0xa
  29:	e8 5d 03 00 00       	call   38b <alarm>
  2e:	83 c4 10             	add    $0x10,%esp
  31:	eb 10                	jmp    43 <main+0x43>
  33:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  37:	90                   	nop
  for(i = 0; i < 25*5000000; i++){
  38:	83 c3 01             	add    $0x1,%ebx
  3b:	81 fb 40 59 73 07    	cmp    $0x7735940,%ebx
  41:	74 2f                	je     72 <main+0x72>
  alarm(10, periodic);
  43:	69 c3 39 61 c2 68    	imul   $0x68c26139,%ebx,%eax
  49:	c1 c8 04             	ror    $0x4,%eax
    if((i % 250000) == 0)
  4c:	3d 1b 43 00 00       	cmp    $0x431b,%eax
  51:	77 e5                	ja     38 <main+0x38>
      write(2, ".", 1);
  53:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 25*5000000; i++){
  56:	83 c3 01             	add    $0x1,%ebx
      write(2, ".", 1);
  59:	6a 01                	push   $0x1
  5b:	68 d4 07 00 00       	push   $0x7d4
  60:	6a 02                	push   $0x2
  62:	e8 9c 02 00 00       	call   303 <write>
  67:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 25*5000000; i++){
  6a:	81 fb 40 59 73 07    	cmp    $0x7735940,%ebx
  70:	75 d1                	jne    43 <main+0x43>
  }
  exit();
  72:	e8 6c 02 00 00       	call   2e3 <exit>
  77:	66 90                	xchg   %ax,%ax
  79:	66 90                	xchg   %ax,%ax
  7b:	66 90                	xchg   %ax,%ax
  7d:	66 90                	xchg   %ax,%ax
  7f:	90                   	nop

00000080 <periodic>:
}

void
periodic()
{
  80:	55                   	push   %ebp
  81:	89 e5                	mov    %esp,%ebp
  83:	83 ec 10             	sub    $0x10,%esp
  printf(1, "alarm!\n");
  86:	68 b8 07 00 00       	push   $0x7b8
  8b:	6a 01                	push   $0x1
  8d:	e8 be 03 00 00       	call   450 <printf>
  92:	83 c4 10             	add    $0x10,%esp
  95:	c9                   	leave  
  96:	c3                   	ret    
  97:	66 90                	xchg   %ax,%ax
  99:	66 90                	xchg   %ax,%ax
  9b:	66 90                	xchg   %ax,%ax
  9d:	66 90                	xchg   %ax,%ax
  9f:	90                   	nop

000000a0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  a0:	55                   	push   %ebp
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a1:	31 c0                	xor    %eax,%eax
{
  a3:	89 e5                	mov    %esp,%ebp
  a5:	53                   	push   %ebx
  a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while((*s++ = *t++) != 0)
  b0:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  b4:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  b7:	83 c0 01             	add    $0x1,%eax
  ba:	84 d2                	test   %dl,%dl
  bc:	75 f2                	jne    b0 <strcpy+0x10>
    ;
  return os;
}
  be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  c1:	89 c8                	mov    %ecx,%eax
  c3:	c9                   	leave  
  c4:	c3                   	ret    
  c5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000000d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d0:	55                   	push   %ebp
  d1:	89 e5                	mov    %esp,%ebp
  d3:	53                   	push   %ebx
  d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  da:	0f b6 01             	movzbl (%ecx),%eax
  dd:	0f b6 1a             	movzbl (%edx),%ebx
  e0:	84 c0                	test   %al,%al
  e2:	75 1c                	jne    100 <strcmp+0x30>
  e4:	eb 2e                	jmp    114 <strcmp+0x44>
  e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  ed:	8d 76 00             	lea    0x0(%esi),%esi
  f0:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
    p++, q++;
  f4:	83 c1 01             	add    $0x1,%ecx
  f7:	8d 5a 01             	lea    0x1(%edx),%ebx
  while(*p && *p == *q)
  fa:	84 c0                	test   %al,%al
  fc:	74 12                	je     110 <strcmp+0x40>
    p++, q++;
  fe:	89 da                	mov    %ebx,%edx
  while(*p && *p == *q)
 100:	0f b6 1a             	movzbl (%edx),%ebx
 103:	38 c3                	cmp    %al,%bl
 105:	74 e9                	je     f0 <strcmp+0x20>
  return (uchar)*p - (uchar)*q;
 107:	29 d8                	sub    %ebx,%eax
}
 109:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 10c:	c9                   	leave  
 10d:	c3                   	ret    
 10e:	66 90                	xchg   %ax,%ax
  return (uchar)*p - (uchar)*q;
 110:	0f b6 5a 01          	movzbl 0x1(%edx),%ebx
 114:	31 c0                	xor    %eax,%eax
 116:	29 d8                	sub    %ebx,%eax
}
 118:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 11b:	c9                   	leave  
 11c:	c3                   	ret    
 11d:	8d 76 00             	lea    0x0(%esi),%esi

00000120 <strlen>:

uint
strlen(const char *s)
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
 126:	80 3a 00             	cmpb   $0x0,(%edx)
 129:	74 15                	je     140 <strlen+0x20>
 12b:	31 c0                	xor    %eax,%eax
 12d:	8d 76 00             	lea    0x0(%esi),%esi
 130:	83 c0 01             	add    $0x1,%eax
 133:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
 137:	89 c1                	mov    %eax,%ecx
 139:	75 f5                	jne    130 <strlen+0x10>
    ;
  return n;
}
 13b:	89 c8                	mov    %ecx,%eax
 13d:	5d                   	pop    %ebp
 13e:	c3                   	ret    
 13f:	90                   	nop
  for(n = 0; s[n]; n++)
 140:	31 c9                	xor    %ecx,%ecx
}
 142:	5d                   	pop    %ebp
 143:	89 c8                	mov    %ecx,%eax
 145:	c3                   	ret    
 146:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 14d:	8d 76 00             	lea    0x0(%esi),%esi

00000150 <memset>:

void*
memset(void *dst, int c, uint n)
{
 150:	55                   	push   %ebp
 151:	89 e5                	mov    %esp,%ebp
 153:	57                   	push   %edi
 154:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 157:	8b 4d 10             	mov    0x10(%ebp),%ecx
 15a:	8b 45 0c             	mov    0xc(%ebp),%eax
 15d:	89 d7                	mov    %edx,%edi
 15f:	fc                   	cld    
 160:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 162:	8b 7d fc             	mov    -0x4(%ebp),%edi
 165:	89 d0                	mov    %edx,%eax
 167:	c9                   	leave  
 168:	c3                   	ret    
 169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000170 <strchr>:

char*
strchr(const char *s, char c)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	8b 45 08             	mov    0x8(%ebp),%eax
 176:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 17a:	0f b6 10             	movzbl (%eax),%edx
 17d:	84 d2                	test   %dl,%dl
 17f:	75 12                	jne    193 <strchr+0x23>
 181:	eb 1d                	jmp    1a0 <strchr+0x30>
 183:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 187:	90                   	nop
 188:	0f b6 50 01          	movzbl 0x1(%eax),%edx
 18c:	83 c0 01             	add    $0x1,%eax
 18f:	84 d2                	test   %dl,%dl
 191:	74 0d                	je     1a0 <strchr+0x30>
    if(*s == c)
 193:	38 d1                	cmp    %dl,%cl
 195:	75 f1                	jne    188 <strchr+0x18>
      return (char*)s;
  return 0;
}
 197:	5d                   	pop    %ebp
 198:	c3                   	ret    
 199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return 0;
 1a0:	31 c0                	xor    %eax,%eax
}
 1a2:	5d                   	pop    %ebp
 1a3:	c3                   	ret    
 1a4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 1ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 1af:	90                   	nop

000001b0 <gets>:

char*
gets(char *buf, int max)
{
 1b0:	55                   	push   %ebp
 1b1:	89 e5                	mov    %esp,%ebp
 1b3:	57                   	push   %edi
 1b4:	56                   	push   %esi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    cc = read(0, &c, 1);
 1b5:	8d 7d e7             	lea    -0x19(%ebp),%edi
{
 1b8:	53                   	push   %ebx
  for(i=0; i+1 < max; ){
 1b9:	31 db                	xor    %ebx,%ebx
{
 1bb:	83 ec 1c             	sub    $0x1c,%esp
  for(i=0; i+1 < max; ){
 1be:	eb 27                	jmp    1e7 <gets+0x37>
    cc = read(0, &c, 1);
 1c0:	83 ec 04             	sub    $0x4,%esp
 1c3:	6a 01                	push   $0x1
 1c5:	57                   	push   %edi
 1c6:	6a 00                	push   $0x0
 1c8:	e8 2e 01 00 00       	call   2fb <read>
    if(cc < 1)
 1cd:	83 c4 10             	add    $0x10,%esp
 1d0:	85 c0                	test   %eax,%eax
 1d2:	7e 1d                	jle    1f1 <gets+0x41>
      break;
    buf[i++] = c;
 1d4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1d8:	8b 55 08             	mov    0x8(%ebp),%edx
 1db:	88 44 1a ff          	mov    %al,-0x1(%edx,%ebx,1)
    if(c == '\n' || c == '\r')
 1df:	3c 0a                	cmp    $0xa,%al
 1e1:	74 1d                	je     200 <gets+0x50>
 1e3:	3c 0d                	cmp    $0xd,%al
 1e5:	74 19                	je     200 <gets+0x50>
  for(i=0; i+1 < max; ){
 1e7:	89 de                	mov    %ebx,%esi
 1e9:	83 c3 01             	add    $0x1,%ebx
 1ec:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 1ef:	7c cf                	jl     1c0 <gets+0x10>
      break;
  }
  buf[i] = '\0';
 1f1:	8b 45 08             	mov    0x8(%ebp),%eax
 1f4:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)
  return buf;
}
 1f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1fb:	5b                   	pop    %ebx
 1fc:	5e                   	pop    %esi
 1fd:	5f                   	pop    %edi
 1fe:	5d                   	pop    %ebp
 1ff:	c3                   	ret    
  buf[i] = '\0';
 200:	8b 45 08             	mov    0x8(%ebp),%eax
 203:	89 de                	mov    %ebx,%esi
 205:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)
}
 209:	8d 65 f4             	lea    -0xc(%ebp),%esp
 20c:	5b                   	pop    %ebx
 20d:	5e                   	pop    %esi
 20e:	5f                   	pop    %edi
 20f:	5d                   	pop    %ebp
 210:	c3                   	ret    
 211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 218:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 21f:	90                   	nop

00000220 <stat>:

int
stat(const char *n, struct stat *st)
{
 220:	55                   	push   %ebp
 221:	89 e5                	mov    %esp,%ebp
 223:	56                   	push   %esi
 224:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 225:	83 ec 08             	sub    $0x8,%esp
 228:	6a 00                	push   $0x0
 22a:	ff 75 08             	push   0x8(%ebp)
 22d:	e8 f1 00 00 00       	call   323 <open>
  if(fd < 0)
 232:	83 c4 10             	add    $0x10,%esp
 235:	85 c0                	test   %eax,%eax
 237:	78 27                	js     260 <stat+0x40>
    return -1;
  r = fstat(fd, st);
 239:	83 ec 08             	sub    $0x8,%esp
 23c:	ff 75 0c             	push   0xc(%ebp)
 23f:	89 c3                	mov    %eax,%ebx
 241:	50                   	push   %eax
 242:	e8 f4 00 00 00       	call   33b <fstat>
  close(fd);
 247:	89 1c 24             	mov    %ebx,(%esp)
  r = fstat(fd, st);
 24a:	89 c6                	mov    %eax,%esi
  close(fd);
 24c:	e8 ba 00 00 00       	call   30b <close>
  return r;
 251:	83 c4 10             	add    $0x10,%esp
}
 254:	8d 65 f8             	lea    -0x8(%ebp),%esp
 257:	89 f0                	mov    %esi,%eax
 259:	5b                   	pop    %ebx
 25a:	5e                   	pop    %esi
 25b:	5d                   	pop    %ebp
 25c:	c3                   	ret    
 25d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
 260:	be ff ff ff ff       	mov    $0xffffffff,%esi
 265:	eb ed                	jmp    254 <stat+0x34>
 267:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 26e:	66 90                	xchg   %ax,%ax

00000270 <atoi>:

int
atoi(const char *s)
{
 270:	55                   	push   %ebp
 271:	89 e5                	mov    %esp,%ebp
 273:	53                   	push   %ebx
 274:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 277:	0f be 02             	movsbl (%edx),%eax
 27a:	8d 48 d0             	lea    -0x30(%eax),%ecx
 27d:	80 f9 09             	cmp    $0x9,%cl
  n = 0;
 280:	b9 00 00 00 00       	mov    $0x0,%ecx
  while('0' <= *s && *s <= '9')
 285:	77 1e                	ja     2a5 <atoi+0x35>
 287:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 28e:	66 90                	xchg   %ax,%ax
    n = n*10 + *s++ - '0';
 290:	83 c2 01             	add    $0x1,%edx
 293:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
 296:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
  while('0' <= *s && *s <= '9')
 29a:	0f be 02             	movsbl (%edx),%eax
 29d:	8d 58 d0             	lea    -0x30(%eax),%ebx
 2a0:	80 fb 09             	cmp    $0x9,%bl
 2a3:	76 eb                	jbe    290 <atoi+0x20>
  return n;
}
 2a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 2a8:	89 c8                	mov    %ecx,%eax
 2aa:	c9                   	leave  
 2ab:	c3                   	ret    
 2ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000002b0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b0:	55                   	push   %ebp
 2b1:	89 e5                	mov    %esp,%ebp
 2b3:	57                   	push   %edi
 2b4:	8b 45 10             	mov    0x10(%ebp),%eax
 2b7:	8b 55 08             	mov    0x8(%ebp),%edx
 2ba:	56                   	push   %esi
 2bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2be:	85 c0                	test   %eax,%eax
 2c0:	7e 13                	jle    2d5 <memmove+0x25>
 2c2:	01 d0                	add    %edx,%eax
  dst = vdst;
 2c4:	89 d7                	mov    %edx,%edi
 2c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 2cd:	8d 76 00             	lea    0x0(%esi),%esi
    *dst++ = *src++;
 2d0:	a4                   	movsb  %ds:(%esi),%es:(%edi)
  while(n-- > 0)
 2d1:	39 f8                	cmp    %edi,%eax
 2d3:	75 fb                	jne    2d0 <memmove+0x20>
  return vdst;
}
 2d5:	5e                   	pop    %esi
 2d6:	89 d0                	mov    %edx,%eax
 2d8:	5f                   	pop    %edi
 2d9:	5d                   	pop    %ebp
 2da:	c3                   	ret    

000002db <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2db:	b8 01 00 00 00       	mov    $0x1,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <exit>:
SYSCALL(exit)
 2e3:	b8 02 00 00 00       	mov    $0x2,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <wait>:
SYSCALL(wait)
 2eb:	b8 03 00 00 00       	mov    $0x3,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <pipe>:
SYSCALL(pipe)
 2f3:	b8 04 00 00 00       	mov    $0x4,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <read>:
SYSCALL(read)
 2fb:	b8 05 00 00 00       	mov    $0x5,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <write>:
SYSCALL(write)
 303:	b8 10 00 00 00       	mov    $0x10,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <close>:
SYSCALL(close)
 30b:	b8 15 00 00 00       	mov    $0x15,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <kill>:
SYSCALL(kill)
 313:	b8 06 00 00 00       	mov    $0x6,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <exec>:
SYSCALL(exec)
 31b:	b8 07 00 00 00       	mov    $0x7,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <open>:
SYSCALL(open)
 323:	b8 0f 00 00 00       	mov    $0xf,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <mknod>:
SYSCALL(mknod)
 32b:	b8 11 00 00 00       	mov    $0x11,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <unlink>:
SYSCALL(unlink)
 333:	b8 12 00 00 00       	mov    $0x12,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <fstat>:
SYSCALL(fstat)
 33b:	b8 08 00 00 00       	mov    $0x8,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <link>:
SYSCALL(link)
 343:	b8 13 00 00 00       	mov    $0x13,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <mkdir>:
SYSCALL(mkdir)
 34b:	b8 14 00 00 00       	mov    $0x14,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <chdir>:
SYSCALL(chdir)
 353:	b8 09 00 00 00       	mov    $0x9,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <dup>:
SYSCALL(dup)
 35b:	b8 0a 00 00 00       	mov    $0xa,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <getpid>:
SYSCALL(getpid)
 363:	b8 0b 00 00 00       	mov    $0xb,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <sbrk>:
SYSCALL(sbrk)
 36b:	b8 0c 00 00 00       	mov    $0xc,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <sleep>:
SYSCALL(sleep)
 373:	b8 0d 00 00 00       	mov    $0xd,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	ret    

0000037b <uptime>:
SYSCALL(uptime)
 37b:	b8 0e 00 00 00       	mov    $0xe,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	ret    

00000383 <date>:
SYSCALL(date)
 383:	b8 16 00 00 00       	mov    $0x16,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	ret    

0000038b <alarm>:
 38b:	b8 17 00 00 00       	mov    $0x17,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	ret    
 393:	66 90                	xchg   %ax,%ax
 395:	66 90                	xchg   %ax,%ax
 397:	66 90                	xchg   %ax,%ax
 399:	66 90                	xchg   %ax,%ax
 39b:	66 90                	xchg   %ax,%ax
 39d:	66 90                	xchg   %ax,%ax
 39f:	90                   	nop

000003a0 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 3a0:	55                   	push   %ebp
 3a1:	89 e5                	mov    %esp,%ebp
 3a3:	57                   	push   %edi
 3a4:	56                   	push   %esi
 3a5:	53                   	push   %ebx
 3a6:	83 ec 3c             	sub    $0x3c,%esp
 3a9:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 3ac:	89 d1                	mov    %edx,%ecx
{
 3ae:	89 45 b8             	mov    %eax,-0x48(%ebp)
  if(sgn && xx < 0){
 3b1:	85 d2                	test   %edx,%edx
 3b3:	0f 89 7f 00 00 00    	jns    438 <printint+0x98>
 3b9:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 3bd:	74 79                	je     438 <printint+0x98>
    neg = 1;
 3bf:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
    x = -xx;
 3c6:	f7 d9                	neg    %ecx
  } else {
    x = xx;
  }

  i = 0;
 3c8:	31 db                	xor    %ebx,%ebx
 3ca:	8d 75 d7             	lea    -0x29(%ebp),%esi
 3cd:	8d 76 00             	lea    0x0(%esi),%esi
  do{
    buf[i++] = digits[x % base];
 3d0:	89 c8                	mov    %ecx,%eax
 3d2:	31 d2                	xor    %edx,%edx
 3d4:	89 cf                	mov    %ecx,%edi
 3d6:	f7 75 c4             	divl   -0x3c(%ebp)
 3d9:	0f b6 92 e0 07 00 00 	movzbl 0x7e0(%edx),%edx
 3e0:	89 45 c0             	mov    %eax,-0x40(%ebp)
 3e3:	89 d8                	mov    %ebx,%eax
 3e5:	8d 5b 01             	lea    0x1(%ebx),%ebx
  }while((x /= base) != 0);
 3e8:	8b 4d c0             	mov    -0x40(%ebp),%ecx
    buf[i++] = digits[x % base];
 3eb:	88 14 1e             	mov    %dl,(%esi,%ebx,1)
  }while((x /= base) != 0);
 3ee:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
 3f1:	76 dd                	jbe    3d0 <printint+0x30>
  if(neg)
 3f3:	8b 4d bc             	mov    -0x44(%ebp),%ecx
 3f6:	85 c9                	test   %ecx,%ecx
 3f8:	74 0c                	je     406 <printint+0x66>
    buf[i++] = '-';
 3fa:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    buf[i++] = digits[x % base];
 3ff:	89 d8                	mov    %ebx,%eax
    buf[i++] = '-';
 401:	ba 2d 00 00 00       	mov    $0x2d,%edx

  while(--i >= 0)
 406:	8b 7d b8             	mov    -0x48(%ebp),%edi
 409:	8d 5c 05 d7          	lea    -0x29(%ebp,%eax,1),%ebx
 40d:	eb 07                	jmp    416 <printint+0x76>
 40f:	90                   	nop
    putc(fd, buf[i]);
 410:	0f b6 13             	movzbl (%ebx),%edx
 413:	83 eb 01             	sub    $0x1,%ebx
  write(fd, &c, 1);
 416:	83 ec 04             	sub    $0x4,%esp
 419:	88 55 d7             	mov    %dl,-0x29(%ebp)
 41c:	6a 01                	push   $0x1
 41e:	56                   	push   %esi
 41f:	57                   	push   %edi
 420:	e8 de fe ff ff       	call   303 <write>
  while(--i >= 0)
 425:	83 c4 10             	add    $0x10,%esp
 428:	39 de                	cmp    %ebx,%esi
 42a:	75 e4                	jne    410 <printint+0x70>
}
 42c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 42f:	5b                   	pop    %ebx
 430:	5e                   	pop    %esi
 431:	5f                   	pop    %edi
 432:	5d                   	pop    %ebp
 433:	c3                   	ret    
 434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 438:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
 43f:	eb 87                	jmp    3c8 <printint+0x28>
 441:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 448:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 44f:	90                   	nop

00000450 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 450:	55                   	push   %ebp
 451:	89 e5                	mov    %esp,%ebp
 453:	57                   	push   %edi
 454:	56                   	push   %esi
 455:	53                   	push   %ebx
 456:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 459:	8b 75 0c             	mov    0xc(%ebp),%esi
 45c:	0f b6 1e             	movzbl (%esi),%ebx
 45f:	84 db                	test   %bl,%bl
 461:	0f 84 b8 00 00 00    	je     51f <printf+0xcf>
  ap = (uint*)(void*)&fmt + 1;
 467:	8d 45 10             	lea    0x10(%ebp),%eax
 46a:	83 c6 01             	add    $0x1,%esi
  write(fd, &c, 1);
 46d:	8d 7d e7             	lea    -0x19(%ebp),%edi
  state = 0;
 470:	31 d2                	xor    %edx,%edx
  ap = (uint*)(void*)&fmt + 1;
 472:	89 45 d0             	mov    %eax,-0x30(%ebp)
 475:	eb 37                	jmp    4ae <printf+0x5e>
 477:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 47e:	66 90                	xchg   %ax,%ax
 480:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 483:	ba 25 00 00 00       	mov    $0x25,%edx
      if(c == '%'){
 488:	83 f8 25             	cmp    $0x25,%eax
 48b:	74 17                	je     4a4 <printf+0x54>
  write(fd, &c, 1);
 48d:	83 ec 04             	sub    $0x4,%esp
 490:	88 5d e7             	mov    %bl,-0x19(%ebp)
 493:	6a 01                	push   $0x1
 495:	57                   	push   %edi
 496:	ff 75 08             	push   0x8(%ebp)
 499:	e8 65 fe ff ff       	call   303 <write>
 49e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
      } else {
        putc(fd, c);
 4a1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 4a4:	0f b6 1e             	movzbl (%esi),%ebx
 4a7:	83 c6 01             	add    $0x1,%esi
 4aa:	84 db                	test   %bl,%bl
 4ac:	74 71                	je     51f <printf+0xcf>
    c = fmt[i] & 0xff;
 4ae:	0f be cb             	movsbl %bl,%ecx
 4b1:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 4b4:	85 d2                	test   %edx,%edx
 4b6:	74 c8                	je     480 <printf+0x30>
      }
    } else if(state == '%'){
 4b8:	83 fa 25             	cmp    $0x25,%edx
 4bb:	75 e7                	jne    4a4 <printf+0x54>
      if(c == 'd'){
 4bd:	83 f8 64             	cmp    $0x64,%eax
 4c0:	0f 84 9a 00 00 00    	je     560 <printf+0x110>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 4c6:	81 e1 f7 00 00 00    	and    $0xf7,%ecx
 4cc:	83 f9 70             	cmp    $0x70,%ecx
 4cf:	74 5f                	je     530 <printf+0xe0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 4d1:	83 f8 73             	cmp    $0x73,%eax
 4d4:	0f 84 d6 00 00 00    	je     5b0 <printf+0x160>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4da:	83 f8 63             	cmp    $0x63,%eax
 4dd:	0f 84 8d 00 00 00    	je     570 <printf+0x120>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 4e3:	83 f8 25             	cmp    $0x25,%eax
 4e6:	0f 84 b4 00 00 00    	je     5a0 <printf+0x150>
  write(fd, &c, 1);
 4ec:	83 ec 04             	sub    $0x4,%esp
 4ef:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 4f3:	6a 01                	push   $0x1
 4f5:	57                   	push   %edi
 4f6:	ff 75 08             	push   0x8(%ebp)
 4f9:	e8 05 fe ff ff       	call   303 <write>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 4fe:	88 5d e7             	mov    %bl,-0x19(%ebp)
  write(fd, &c, 1);
 501:	83 c4 0c             	add    $0xc,%esp
 504:	6a 01                	push   $0x1
  for(i = 0; fmt[i]; i++){
 506:	83 c6 01             	add    $0x1,%esi
  write(fd, &c, 1);
 509:	57                   	push   %edi
 50a:	ff 75 08             	push   0x8(%ebp)
 50d:	e8 f1 fd ff ff       	call   303 <write>
  for(i = 0; fmt[i]; i++){
 512:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
        putc(fd, c);
 516:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 519:	31 d2                	xor    %edx,%edx
  for(i = 0; fmt[i]; i++){
 51b:	84 db                	test   %bl,%bl
 51d:	75 8f                	jne    4ae <printf+0x5e>
    }
  }
}
 51f:	8d 65 f4             	lea    -0xc(%ebp),%esp
 522:	5b                   	pop    %ebx
 523:	5e                   	pop    %esi
 524:	5f                   	pop    %edi
 525:	5d                   	pop    %ebp
 526:	c3                   	ret    
 527:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 52e:	66 90                	xchg   %ax,%ax
        printint(fd, *ap, 16, 0);
 530:	83 ec 0c             	sub    $0xc,%esp
 533:	b9 10 00 00 00       	mov    $0x10,%ecx
 538:	6a 00                	push   $0x0
 53a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 53d:	8b 45 08             	mov    0x8(%ebp),%eax
 540:	8b 13                	mov    (%ebx),%edx
 542:	e8 59 fe ff ff       	call   3a0 <printint>
        ap++;
 547:	89 d8                	mov    %ebx,%eax
 549:	83 c4 10             	add    $0x10,%esp
      state = 0;
 54c:	31 d2                	xor    %edx,%edx
        ap++;
 54e:	83 c0 04             	add    $0x4,%eax
 551:	89 45 d0             	mov    %eax,-0x30(%ebp)
 554:	e9 4b ff ff ff       	jmp    4a4 <printf+0x54>
 559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        printint(fd, *ap, 10, 1);
 560:	83 ec 0c             	sub    $0xc,%esp
 563:	b9 0a 00 00 00       	mov    $0xa,%ecx
 568:	6a 01                	push   $0x1
 56a:	eb ce                	jmp    53a <printf+0xea>
 56c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        putc(fd, *ap);
 570:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  write(fd, &c, 1);
 573:	83 ec 04             	sub    $0x4,%esp
        putc(fd, *ap);
 576:	8b 03                	mov    (%ebx),%eax
  write(fd, &c, 1);
 578:	6a 01                	push   $0x1
        ap++;
 57a:	83 c3 04             	add    $0x4,%ebx
  write(fd, &c, 1);
 57d:	57                   	push   %edi
 57e:	ff 75 08             	push   0x8(%ebp)
        putc(fd, *ap);
 581:	88 45 e7             	mov    %al,-0x19(%ebp)
  write(fd, &c, 1);
 584:	e8 7a fd ff ff       	call   303 <write>
        ap++;
 589:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 58c:	83 c4 10             	add    $0x10,%esp
      state = 0;
 58f:	31 d2                	xor    %edx,%edx
 591:	e9 0e ff ff ff       	jmp    4a4 <printf+0x54>
 596:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 59d:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
 5a0:	88 5d e7             	mov    %bl,-0x19(%ebp)
  write(fd, &c, 1);
 5a3:	83 ec 04             	sub    $0x4,%esp
 5a6:	e9 59 ff ff ff       	jmp    504 <printf+0xb4>
 5ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 5af:	90                   	nop
        s = (char*)*ap;
 5b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
 5b3:	8b 18                	mov    (%eax),%ebx
        ap++;
 5b5:	83 c0 04             	add    $0x4,%eax
 5b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
        if(s == 0)
 5bb:	85 db                	test   %ebx,%ebx
 5bd:	74 17                	je     5d6 <printf+0x186>
        while(*s != 0){
 5bf:	0f b6 03             	movzbl (%ebx),%eax
      state = 0;
 5c2:	31 d2                	xor    %edx,%edx
        while(*s != 0){
 5c4:	84 c0                	test   %al,%al
 5c6:	0f 84 d8 fe ff ff    	je     4a4 <printf+0x54>
 5cc:	89 75 d4             	mov    %esi,-0x2c(%ebp)
 5cf:	89 de                	mov    %ebx,%esi
 5d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
 5d4:	eb 1a                	jmp    5f0 <printf+0x1a0>
          s = "(null)";
 5d6:	bb d6 07 00 00       	mov    $0x7d6,%ebx
        while(*s != 0){
 5db:	89 75 d4             	mov    %esi,-0x2c(%ebp)
 5de:	b8 28 00 00 00       	mov    $0x28,%eax
 5e3:	89 de                	mov    %ebx,%esi
 5e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
 5e8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 5ef:	90                   	nop
  write(fd, &c, 1);
 5f0:	83 ec 04             	sub    $0x4,%esp
          s++;
 5f3:	83 c6 01             	add    $0x1,%esi
 5f6:	88 45 e7             	mov    %al,-0x19(%ebp)
  write(fd, &c, 1);
 5f9:	6a 01                	push   $0x1
 5fb:	57                   	push   %edi
 5fc:	53                   	push   %ebx
 5fd:	e8 01 fd ff ff       	call   303 <write>
        while(*s != 0){
 602:	0f b6 06             	movzbl (%esi),%eax
 605:	83 c4 10             	add    $0x10,%esp
 608:	84 c0                	test   %al,%al
 60a:	75 e4                	jne    5f0 <printf+0x1a0>
      state = 0;
 60c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
 60f:	31 d2                	xor    %edx,%edx
 611:	e9 8e fe ff ff       	jmp    4a4 <printf+0x54>
 616:	66 90                	xchg   %ax,%ax
 618:	66 90                	xchg   %ax,%ax
 61a:	66 90                	xchg   %ax,%ax
 61c:	66 90                	xchg   %ax,%ax
 61e:	66 90                	xchg   %ax,%ax

00000620 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 620:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 621:	a1 a8 0a 00 00       	mov    0xaa8,%eax
{
 626:	89 e5                	mov    %esp,%ebp
 628:	57                   	push   %edi
 629:	56                   	push   %esi
 62a:	53                   	push   %ebx
 62b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = (Header*)ap - 1;
 62e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 631:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 638:	89 c2                	mov    %eax,%edx
 63a:	8b 00                	mov    (%eax),%eax
 63c:	39 ca                	cmp    %ecx,%edx
 63e:	73 30                	jae    670 <free+0x50>
 640:	39 c1                	cmp    %eax,%ecx
 642:	72 04                	jb     648 <free+0x28>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 644:	39 c2                	cmp    %eax,%edx
 646:	72 f0                	jb     638 <free+0x18>
      break;
  if(bp + bp->s.size == p->s.ptr){
 648:	8b 73 fc             	mov    -0x4(%ebx),%esi
 64b:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 64e:	39 f8                	cmp    %edi,%eax
 650:	74 30                	je     682 <free+0x62>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 652:	89 43 f8             	mov    %eax,-0x8(%ebx)
  if(p + p->s.size == bp){
 655:	8b 42 04             	mov    0x4(%edx),%eax
 658:	8d 34 c2             	lea    (%edx,%eax,8),%esi
 65b:	39 f1                	cmp    %esi,%ecx
 65d:	74 3a                	je     699 <free+0x79>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 65f:	89 0a                	mov    %ecx,(%edx)
  freep = p;
}
 661:	5b                   	pop    %ebx
  freep = p;
 662:	89 15 a8 0a 00 00    	mov    %edx,0xaa8
}
 668:	5e                   	pop    %esi
 669:	5f                   	pop    %edi
 66a:	5d                   	pop    %ebp
 66b:	c3                   	ret    
 66c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 670:	39 c2                	cmp    %eax,%edx
 672:	72 c4                	jb     638 <free+0x18>
 674:	39 c1                	cmp    %eax,%ecx
 676:	73 c0                	jae    638 <free+0x18>
  if(bp + bp->s.size == p->s.ptr){
 678:	8b 73 fc             	mov    -0x4(%ebx),%esi
 67b:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 67e:	39 f8                	cmp    %edi,%eax
 680:	75 d0                	jne    652 <free+0x32>
    bp->s.size += p->s.ptr->s.size;
 682:	03 70 04             	add    0x4(%eax),%esi
 685:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 688:	8b 02                	mov    (%edx),%eax
 68a:	8b 00                	mov    (%eax),%eax
 68c:	89 43 f8             	mov    %eax,-0x8(%ebx)
  if(p + p->s.size == bp){
 68f:	8b 42 04             	mov    0x4(%edx),%eax
 692:	8d 34 c2             	lea    (%edx,%eax,8),%esi
 695:	39 f1                	cmp    %esi,%ecx
 697:	75 c6                	jne    65f <free+0x3f>
    p->s.size += bp->s.size;
 699:	03 43 fc             	add    -0x4(%ebx),%eax
  freep = p;
 69c:	89 15 a8 0a 00 00    	mov    %edx,0xaa8
    p->s.size += bp->s.size;
 6a2:	89 42 04             	mov    %eax,0x4(%edx)
    p->s.ptr = bp->s.ptr;
 6a5:	8b 43 f8             	mov    -0x8(%ebx),%eax
 6a8:	89 02                	mov    %eax,(%edx)
}
 6aa:	5b                   	pop    %ebx
 6ab:	5e                   	pop    %esi
 6ac:	5f                   	pop    %edi
 6ad:	5d                   	pop    %ebp
 6ae:	c3                   	ret    
 6af:	90                   	nop

000006b0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6b0:	55                   	push   %ebp
 6b1:	89 e5                	mov    %esp,%ebp
 6b3:	57                   	push   %edi
 6b4:	56                   	push   %esi
 6b5:	53                   	push   %ebx
 6b6:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6b9:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 6bc:	8b 3d a8 0a 00 00    	mov    0xaa8,%edi
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6c2:	8d 70 07             	lea    0x7(%eax),%esi
 6c5:	c1 ee 03             	shr    $0x3,%esi
 6c8:	83 c6 01             	add    $0x1,%esi
  if((prevp = freep) == 0){
 6cb:	85 ff                	test   %edi,%edi
 6cd:	0f 84 ad 00 00 00    	je     780 <malloc+0xd0>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6d3:	8b 07                	mov    (%edi),%eax
    if(p->s.size >= nunits){
 6d5:	8b 48 04             	mov    0x4(%eax),%ecx
 6d8:	39 f1                	cmp    %esi,%ecx
 6da:	73 71                	jae    74d <malloc+0x9d>
 6dc:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
 6e2:	bb 00 10 00 00       	mov    $0x1000,%ebx
 6e7:	0f 43 de             	cmovae %esi,%ebx
  p = sbrk(nu * sizeof(Header));
 6ea:	8d 0c dd 00 00 00 00 	lea    0x0(,%ebx,8),%ecx
 6f1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
 6f4:	eb 1b                	jmp    711 <malloc+0x61>
 6f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 6fd:	8d 76 00             	lea    0x0(%esi),%esi
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 700:	8b 10                	mov    (%eax),%edx
    if(p->s.size >= nunits){
 702:	8b 4a 04             	mov    0x4(%edx),%ecx
 705:	39 f1                	cmp    %esi,%ecx
 707:	73 4f                	jae    758 <malloc+0xa8>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 709:	8b 3d a8 0a 00 00    	mov    0xaa8,%edi
 70f:	89 d0                	mov    %edx,%eax
 711:	39 c7                	cmp    %eax,%edi
 713:	75 eb                	jne    700 <malloc+0x50>
  p = sbrk(nu * sizeof(Header));
 715:	83 ec 0c             	sub    $0xc,%esp
 718:	ff 75 e4             	push   -0x1c(%ebp)
 71b:	e8 4b fc ff ff       	call   36b <sbrk>
  if(p == (char*)-1)
 720:	83 c4 10             	add    $0x10,%esp
 723:	83 f8 ff             	cmp    $0xffffffff,%eax
 726:	74 1b                	je     743 <malloc+0x93>
  hp->s.size = nu;
 728:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 72b:	83 ec 0c             	sub    $0xc,%esp
 72e:	83 c0 08             	add    $0x8,%eax
 731:	50                   	push   %eax
 732:	e8 e9 fe ff ff       	call   620 <free>
  return freep;
 737:	a1 a8 0a 00 00       	mov    0xaa8,%eax
      if((p = morecore(nunits)) == 0)
 73c:	83 c4 10             	add    $0x10,%esp
 73f:	85 c0                	test   %eax,%eax
 741:	75 bd                	jne    700 <malloc+0x50>
        return 0;
  }
}
 743:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 746:	31 c0                	xor    %eax,%eax
}
 748:	5b                   	pop    %ebx
 749:	5e                   	pop    %esi
 74a:	5f                   	pop    %edi
 74b:	5d                   	pop    %ebp
 74c:	c3                   	ret    
    if(p->s.size >= nunits){
 74d:	89 c2                	mov    %eax,%edx
 74f:	89 f8                	mov    %edi,%eax
 751:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->s.size == nunits)
 758:	39 ce                	cmp    %ecx,%esi
 75a:	74 54                	je     7b0 <malloc+0x100>
        p->s.size -= nunits;
 75c:	29 f1                	sub    %esi,%ecx
 75e:	89 4a 04             	mov    %ecx,0x4(%edx)
        p += p->s.size;
 761:	8d 14 ca             	lea    (%edx,%ecx,8),%edx
        p->s.size = nunits;
 764:	89 72 04             	mov    %esi,0x4(%edx)
      freep = prevp;
 767:	a3 a8 0a 00 00       	mov    %eax,0xaa8
}
 76c:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 76f:	8d 42 08             	lea    0x8(%edx),%eax
}
 772:	5b                   	pop    %ebx
 773:	5e                   	pop    %esi
 774:	5f                   	pop    %edi
 775:	5d                   	pop    %ebp
 776:	c3                   	ret    
 777:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 77e:	66 90                	xchg   %ax,%ax
    base.s.ptr = freep = prevp = &base;
 780:	c7 05 a8 0a 00 00 ac 	movl   $0xaac,0xaa8
 787:	0a 00 00 
    base.s.size = 0;
 78a:	bf ac 0a 00 00       	mov    $0xaac,%edi
    base.s.ptr = freep = prevp = &base;
 78f:	c7 05 ac 0a 00 00 ac 	movl   $0xaac,0xaac
 796:	0a 00 00 
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 799:	89 f8                	mov    %edi,%eax
    base.s.size = 0;
 79b:	c7 05 b0 0a 00 00 00 	movl   $0x0,0xab0
 7a2:	00 00 00 
    if(p->s.size >= nunits){
 7a5:	e9 32 ff ff ff       	jmp    6dc <malloc+0x2c>
 7aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        prevp->s.ptr = p->s.ptr;
 7b0:	8b 0a                	mov    (%edx),%ecx
 7b2:	89 08                	mov    %ecx,(%eax)
 7b4:	eb b1                	jmp    767 <malloc+0xb7>
