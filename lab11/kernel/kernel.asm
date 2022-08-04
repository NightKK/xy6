
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0001f117          	auipc	sp,0x1f
    80000004:	49010113          	addi	sp,sp,1168 # 8001f490 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	782060ef          	jal	ra,80006798 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	ebb9                	bnez	a5,80000082 <kfree+0x66>
    8000002e:	84aa                	mv	s1,a0
    80000030:	00027797          	auipc	a5,0x27
    80000034:	56078793          	addi	a5,a5,1376 # 80027590 <end>
    80000038:	04f56563          	bltu	a0,a5,80000082 <kfree+0x66>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	04f57163          	bgeu	a0,a5,80000082 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	00000097          	auipc	ra,0x0
    8000004c:	130080e7          	jalr	304(ra) # 80000178 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000050:	0000a917          	auipc	s2,0xa
    80000054:	00090913          	mv	s2,s2
    80000058:	854a                	mv	a0,s2
    8000005a:	00007097          	auipc	ra,0x7
    8000005e:	116080e7          	jalr	278(ra) # 80007170 <acquire>
  r->next = kmem.freelist;
    80000062:	01893783          	ld	a5,24(s2) # 8000a068 <kmem+0x18>
    80000066:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000068:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000006c:	854a                	mv	a0,s2
    8000006e:	00007097          	auipc	ra,0x7
    80000072:	1b6080e7          	jalr	438(ra) # 80007224 <release>
}
    80000076:	60e2                	ld	ra,24(sp)
    80000078:	6442                	ld	s0,16(sp)
    8000007a:	64a2                	ld	s1,8(sp)
    8000007c:	6902                	ld	s2,0(sp)
    8000007e:	6105                	addi	sp,sp,32
    80000080:	8082                	ret
    panic("kfree");
    80000082:	00009517          	auipc	a0,0x9
    80000086:	f8e50513          	addi	a0,a0,-114 # 80009010 <etext+0x10>
    8000008a:	00007097          	auipc	ra,0x7
    8000008e:	baa080e7          	jalr	-1110(ra) # 80006c34 <panic>

0000000080000092 <freerange>:
{
    80000092:	7179                	addi	sp,sp,-48
    80000094:	f406                	sd	ra,40(sp)
    80000096:	f022                	sd	s0,32(sp)
    80000098:	ec26                	sd	s1,24(sp)
    8000009a:	e84a                	sd	s2,16(sp)
    8000009c:	e44e                	sd	s3,8(sp)
    8000009e:	e052                	sd	s4,0(sp)
    800000a0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800000a2:	6785                	lui	a5,0x1
    800000a4:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800000a8:	94aa                	add	s1,s1,a0
    800000aa:	757d                	lui	a0,0xfffff
    800000ac:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000ae:	94be                	add	s1,s1,a5
    800000b0:	0095ee63          	bltu	a1,s1,800000cc <freerange+0x3a>
    800000b4:	892e                	mv	s2,a1
    kfree(p);
    800000b6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000b8:	6985                	lui	s3,0x1
    kfree(p);
    800000ba:	01448533          	add	a0,s1,s4
    800000be:	00000097          	auipc	ra,0x0
    800000c2:	f5e080e7          	jalr	-162(ra) # 8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000c6:	94ce                	add	s1,s1,s3
    800000c8:	fe9979e3          	bgeu	s2,s1,800000ba <freerange+0x28>
}
    800000cc:	70a2                	ld	ra,40(sp)
    800000ce:	7402                	ld	s0,32(sp)
    800000d0:	64e2                	ld	s1,24(sp)
    800000d2:	6942                	ld	s2,16(sp)
    800000d4:	69a2                	ld	s3,8(sp)
    800000d6:	6a02                	ld	s4,0(sp)
    800000d8:	6145                	addi	sp,sp,48
    800000da:	8082                	ret

00000000800000dc <kinit>:
{
    800000dc:	1141                	addi	sp,sp,-16
    800000de:	e406                	sd	ra,8(sp)
    800000e0:	e022                	sd	s0,0(sp)
    800000e2:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000e4:	00009597          	auipc	a1,0x9
    800000e8:	f3458593          	addi	a1,a1,-204 # 80009018 <etext+0x18>
    800000ec:	0000a517          	auipc	a0,0xa
    800000f0:	f6450513          	addi	a0,a0,-156 # 8000a050 <kmem>
    800000f4:	00007097          	auipc	ra,0x7
    800000f8:	fec080e7          	jalr	-20(ra) # 800070e0 <initlock>
  freerange(end, (void*)PHYSTOP);
    800000fc:	45c5                	li	a1,17
    800000fe:	05ee                	slli	a1,a1,0x1b
    80000100:	00027517          	auipc	a0,0x27
    80000104:	49050513          	addi	a0,a0,1168 # 80027590 <end>
    80000108:	00000097          	auipc	ra,0x0
    8000010c:	f8a080e7          	jalr	-118(ra) # 80000092 <freerange>
}
    80000110:	60a2                	ld	ra,8(sp)
    80000112:	6402                	ld	s0,0(sp)
    80000114:	0141                	addi	sp,sp,16
    80000116:	8082                	ret

0000000080000118 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000118:	1101                	addi	sp,sp,-32
    8000011a:	ec06                	sd	ra,24(sp)
    8000011c:	e822                	sd	s0,16(sp)
    8000011e:	e426                	sd	s1,8(sp)
    80000120:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000122:	0000a497          	auipc	s1,0xa
    80000126:	f2e48493          	addi	s1,s1,-210 # 8000a050 <kmem>
    8000012a:	8526                	mv	a0,s1
    8000012c:	00007097          	auipc	ra,0x7
    80000130:	044080e7          	jalr	68(ra) # 80007170 <acquire>
  r = kmem.freelist;
    80000134:	6c84                	ld	s1,24(s1)
  if(r)
    80000136:	c885                	beqz	s1,80000166 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000138:	609c                	ld	a5,0(s1)
    8000013a:	0000a517          	auipc	a0,0xa
    8000013e:	f1650513          	addi	a0,a0,-234 # 8000a050 <kmem>
    80000142:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000144:	00007097          	auipc	ra,0x7
    80000148:	0e0080e7          	jalr	224(ra) # 80007224 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000014c:	6605                	lui	a2,0x1
    8000014e:	4595                	li	a1,5
    80000150:	8526                	mv	a0,s1
    80000152:	00000097          	auipc	ra,0x0
    80000156:	026080e7          	jalr	38(ra) # 80000178 <memset>
  return (void*)r;
}
    8000015a:	8526                	mv	a0,s1
    8000015c:	60e2                	ld	ra,24(sp)
    8000015e:	6442                	ld	s0,16(sp)
    80000160:	64a2                	ld	s1,8(sp)
    80000162:	6105                	addi	sp,sp,32
    80000164:	8082                	ret
  release(&kmem.lock);
    80000166:	0000a517          	auipc	a0,0xa
    8000016a:	eea50513          	addi	a0,a0,-278 # 8000a050 <kmem>
    8000016e:	00007097          	auipc	ra,0x7
    80000172:	0b6080e7          	jalr	182(ra) # 80007224 <release>
  if(r)
    80000176:	b7d5                	j	8000015a <kalloc+0x42>

0000000080000178 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000178:	1141                	addi	sp,sp,-16
    8000017a:	e422                	sd	s0,8(sp)
    8000017c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    8000017e:	ca19                	beqz	a2,80000194 <memset+0x1c>
    80000180:	87aa                	mv	a5,a0
    80000182:	1602                	slli	a2,a2,0x20
    80000184:	9201                	srli	a2,a2,0x20
    80000186:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    8000018a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    8000018e:	0785                	addi	a5,a5,1
    80000190:	fee79de3          	bne	a5,a4,8000018a <memset+0x12>
  }
  return dst;
}
    80000194:	6422                	ld	s0,8(sp)
    80000196:	0141                	addi	sp,sp,16
    80000198:	8082                	ret

000000008000019a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    8000019a:	1141                	addi	sp,sp,-16
    8000019c:	e422                	sd	s0,8(sp)
    8000019e:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800001a0:	ca05                	beqz	a2,800001d0 <memcmp+0x36>
    800001a2:	fff6069b          	addiw	a3,a2,-1
    800001a6:	1682                	slli	a3,a3,0x20
    800001a8:	9281                	srli	a3,a3,0x20
    800001aa:	0685                	addi	a3,a3,1
    800001ac:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800001ae:	00054783          	lbu	a5,0(a0)
    800001b2:	0005c703          	lbu	a4,0(a1)
    800001b6:	00e79863          	bne	a5,a4,800001c6 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    800001ba:	0505                	addi	a0,a0,1
    800001bc:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800001be:	fed518e3          	bne	a0,a3,800001ae <memcmp+0x14>
  }

  return 0;
    800001c2:	4501                	li	a0,0
    800001c4:	a019                	j	800001ca <memcmp+0x30>
      return *s1 - *s2;
    800001c6:	40e7853b          	subw	a0,a5,a4
}
    800001ca:	6422                	ld	s0,8(sp)
    800001cc:	0141                	addi	sp,sp,16
    800001ce:	8082                	ret
  return 0;
    800001d0:	4501                	li	a0,0
    800001d2:	bfe5                	j	800001ca <memcmp+0x30>

00000000800001d4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800001d4:	1141                	addi	sp,sp,-16
    800001d6:	e422                	sd	s0,8(sp)
    800001d8:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    800001da:	02a5e563          	bltu	a1,a0,80000204 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800001de:	fff6069b          	addiw	a3,a2,-1
    800001e2:	ce11                	beqz	a2,800001fe <memmove+0x2a>
    800001e4:	1682                	slli	a3,a3,0x20
    800001e6:	9281                	srli	a3,a3,0x20
    800001e8:	0685                	addi	a3,a3,1
    800001ea:	96ae                	add	a3,a3,a1
    800001ec:	87aa                	mv	a5,a0
      *d++ = *s++;
    800001ee:	0585                	addi	a1,a1,1
    800001f0:	0785                	addi	a5,a5,1
    800001f2:	fff5c703          	lbu	a4,-1(a1)
    800001f6:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    800001fa:	fed59ae3          	bne	a1,a3,800001ee <memmove+0x1a>

  return dst;
}
    800001fe:	6422                	ld	s0,8(sp)
    80000200:	0141                	addi	sp,sp,16
    80000202:	8082                	ret
  if(s < d && s + n > d){
    80000204:	02061713          	slli	a4,a2,0x20
    80000208:	9301                	srli	a4,a4,0x20
    8000020a:	00e587b3          	add	a5,a1,a4
    8000020e:	fcf578e3          	bgeu	a0,a5,800001de <memmove+0xa>
    d += n;
    80000212:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000214:	fff6069b          	addiw	a3,a2,-1
    80000218:	d27d                	beqz	a2,800001fe <memmove+0x2a>
    8000021a:	02069613          	slli	a2,a3,0x20
    8000021e:	9201                	srli	a2,a2,0x20
    80000220:	fff64613          	not	a2,a2
    80000224:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000226:	17fd                	addi	a5,a5,-1
    80000228:	177d                	addi	a4,a4,-1
    8000022a:	0007c683          	lbu	a3,0(a5)
    8000022e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000232:	fef61ae3          	bne	a2,a5,80000226 <memmove+0x52>
    80000236:	b7e1                	j	800001fe <memmove+0x2a>

0000000080000238 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000238:	1141                	addi	sp,sp,-16
    8000023a:	e406                	sd	ra,8(sp)
    8000023c:	e022                	sd	s0,0(sp)
    8000023e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000240:	00000097          	auipc	ra,0x0
    80000244:	f94080e7          	jalr	-108(ra) # 800001d4 <memmove>
}
    80000248:	60a2                	ld	ra,8(sp)
    8000024a:	6402                	ld	s0,0(sp)
    8000024c:	0141                	addi	sp,sp,16
    8000024e:	8082                	ret

0000000080000250 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000250:	1141                	addi	sp,sp,-16
    80000252:	e422                	sd	s0,8(sp)
    80000254:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000256:	ce11                	beqz	a2,80000272 <strncmp+0x22>
    80000258:	00054783          	lbu	a5,0(a0)
    8000025c:	cf89                	beqz	a5,80000276 <strncmp+0x26>
    8000025e:	0005c703          	lbu	a4,0(a1)
    80000262:	00f71a63          	bne	a4,a5,80000276 <strncmp+0x26>
    n--, p++, q++;
    80000266:	367d                	addiw	a2,a2,-1
    80000268:	0505                	addi	a0,a0,1
    8000026a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000026c:	f675                	bnez	a2,80000258 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000026e:	4501                	li	a0,0
    80000270:	a809                	j	80000282 <strncmp+0x32>
    80000272:	4501                	li	a0,0
    80000274:	a039                	j	80000282 <strncmp+0x32>
  if(n == 0)
    80000276:	ca09                	beqz	a2,80000288 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000278:	00054503          	lbu	a0,0(a0)
    8000027c:	0005c783          	lbu	a5,0(a1)
    80000280:	9d1d                	subw	a0,a0,a5
}
    80000282:	6422                	ld	s0,8(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    return 0;
    80000288:	4501                	li	a0,0
    8000028a:	bfe5                	j	80000282 <strncmp+0x32>

000000008000028c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000028c:	1141                	addi	sp,sp,-16
    8000028e:	e422                	sd	s0,8(sp)
    80000290:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000292:	872a                	mv	a4,a0
    80000294:	8832                	mv	a6,a2
    80000296:	367d                	addiw	a2,a2,-1
    80000298:	01005963          	blez	a6,800002aa <strncpy+0x1e>
    8000029c:	0705                	addi	a4,a4,1
    8000029e:	0005c783          	lbu	a5,0(a1)
    800002a2:	fef70fa3          	sb	a5,-1(a4)
    800002a6:	0585                	addi	a1,a1,1
    800002a8:	f7f5                	bnez	a5,80000294 <strncpy+0x8>
    ;
  while(n-- > 0)
    800002aa:	86ba                	mv	a3,a4
    800002ac:	00c05c63          	blez	a2,800002c4 <strncpy+0x38>
    *s++ = 0;
    800002b0:	0685                	addi	a3,a3,1
    800002b2:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800002b6:	fff6c793          	not	a5,a3
    800002ba:	9fb9                	addw	a5,a5,a4
    800002bc:	010787bb          	addw	a5,a5,a6
    800002c0:	fef048e3          	bgtz	a5,800002b0 <strncpy+0x24>
  return os;
}
    800002c4:	6422                	ld	s0,8(sp)
    800002c6:	0141                	addi	sp,sp,16
    800002c8:	8082                	ret

00000000800002ca <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800002ca:	1141                	addi	sp,sp,-16
    800002cc:	e422                	sd	s0,8(sp)
    800002ce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800002d0:	02c05363          	blez	a2,800002f6 <safestrcpy+0x2c>
    800002d4:	fff6069b          	addiw	a3,a2,-1
    800002d8:	1682                	slli	a3,a3,0x20
    800002da:	9281                	srli	a3,a3,0x20
    800002dc:	96ae                	add	a3,a3,a1
    800002de:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800002e0:	00d58963          	beq	a1,a3,800002f2 <safestrcpy+0x28>
    800002e4:	0585                	addi	a1,a1,1
    800002e6:	0785                	addi	a5,a5,1
    800002e8:	fff5c703          	lbu	a4,-1(a1)
    800002ec:	fee78fa3          	sb	a4,-1(a5)
    800002f0:	fb65                	bnez	a4,800002e0 <safestrcpy+0x16>
    ;
  *s = 0;
    800002f2:	00078023          	sb	zero,0(a5)
  return os;
}
    800002f6:	6422                	ld	s0,8(sp)
    800002f8:	0141                	addi	sp,sp,16
    800002fa:	8082                	ret

00000000800002fc <strlen>:

int
strlen(const char *s)
{
    800002fc:	1141                	addi	sp,sp,-16
    800002fe:	e422                	sd	s0,8(sp)
    80000300:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000302:	00054783          	lbu	a5,0(a0)
    80000306:	cf91                	beqz	a5,80000322 <strlen+0x26>
    80000308:	0505                	addi	a0,a0,1
    8000030a:	87aa                	mv	a5,a0
    8000030c:	4685                	li	a3,1
    8000030e:	9e89                	subw	a3,a3,a0
    80000310:	00f6853b          	addw	a0,a3,a5
    80000314:	0785                	addi	a5,a5,1
    80000316:	fff7c703          	lbu	a4,-1(a5)
    8000031a:	fb7d                	bnez	a4,80000310 <strlen+0x14>
    ;
  return n;
}
    8000031c:	6422                	ld	s0,8(sp)
    8000031e:	0141                	addi	sp,sp,16
    80000320:	8082                	ret
  for(n = 0; s[n]; n++)
    80000322:	4501                	li	a0,0
    80000324:	bfe5                	j	8000031c <strlen+0x20>

0000000080000326 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000326:	1101                	addi	sp,sp,-32
    80000328:	ec06                	sd	ra,24(sp)
    8000032a:	e822                	sd	s0,16(sp)
    8000032c:	e426                	sd	s1,8(sp)
    8000032e:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80000330:	00001097          	auipc	ra,0x1
    80000334:	b64080e7          	jalr	-1180(ra) # 80000e94 <cpuid>
    kcsaninit();
#endif
    __sync_synchronize();
    started = 1;
  } else {
    while(lockfree_read4((int *) &started) == 0)
    80000338:	0000a497          	auipc	s1,0xa
    8000033c:	cc848493          	addi	s1,s1,-824 # 8000a000 <started>
  if(cpuid() == 0){
    80000340:	c531                	beqz	a0,8000038c <main+0x66>
    while(lockfree_read4((int *) &started) == 0)
    80000342:	8526                	mv	a0,s1
    80000344:	00007097          	auipc	ra,0x7
    80000348:	f3e080e7          	jalr	-194(ra) # 80007282 <lockfree_read4>
    8000034c:	d97d                	beqz	a0,80000342 <main+0x1c>
      ;
    __sync_synchronize();
    8000034e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000352:	00001097          	auipc	ra,0x1
    80000356:	b42080e7          	jalr	-1214(ra) # 80000e94 <cpuid>
    8000035a:	85aa                	mv	a1,a0
    8000035c:	00009517          	auipc	a0,0x9
    80000360:	cdc50513          	addi	a0,a0,-804 # 80009038 <etext+0x38>
    80000364:	00007097          	auipc	ra,0x7
    80000368:	91a080e7          	jalr	-1766(ra) # 80006c7e <printf>
    kvminithart();    // turn on paging
    8000036c:	00000097          	auipc	ra,0x0
    80000370:	0e8080e7          	jalr	232(ra) # 80000454 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000374:	00001097          	auipc	ra,0x1
    80000378:	7a6080e7          	jalr	1958(ra) # 80001b1a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000037c:	00005097          	auipc	ra,0x5
    80000380:	e18080e7          	jalr	-488(ra) # 80005194 <plicinithart>
  }

  scheduler();        
    80000384:	00001097          	auipc	ra,0x1
    80000388:	070080e7          	jalr	112(ra) # 800013f4 <scheduler>
    consoleinit();
    8000038c:	00006097          	auipc	ra,0x6
    80000390:	7ba080e7          	jalr	1978(ra) # 80006b46 <consoleinit>
    printfinit();
    80000394:	00007097          	auipc	ra,0x7
    80000398:	aca080e7          	jalr	-1334(ra) # 80006e5e <printfinit>
    printf("\n");
    8000039c:	00009517          	auipc	a0,0x9
    800003a0:	cac50513          	addi	a0,a0,-852 # 80009048 <etext+0x48>
    800003a4:	00007097          	auipc	ra,0x7
    800003a8:	8da080e7          	jalr	-1830(ra) # 80006c7e <printf>
    printf("xv6 kernel is booting\n");
    800003ac:	00009517          	auipc	a0,0x9
    800003b0:	c7450513          	addi	a0,a0,-908 # 80009020 <etext+0x20>
    800003b4:	00007097          	auipc	ra,0x7
    800003b8:	8ca080e7          	jalr	-1846(ra) # 80006c7e <printf>
    printf("\n");
    800003bc:	00009517          	auipc	a0,0x9
    800003c0:	c8c50513          	addi	a0,a0,-884 # 80009048 <etext+0x48>
    800003c4:	00007097          	auipc	ra,0x7
    800003c8:	8ba080e7          	jalr	-1862(ra) # 80006c7e <printf>
    kinit();         // physical page allocator
    800003cc:	00000097          	auipc	ra,0x0
    800003d0:	d10080e7          	jalr	-752(ra) # 800000dc <kinit>
    kvminit();       // create kernel page table
    800003d4:	00000097          	auipc	ra,0x0
    800003d8:	350080e7          	jalr	848(ra) # 80000724 <kvminit>
    kvminithart();   // turn on paging
    800003dc:	00000097          	auipc	ra,0x0
    800003e0:	078080e7          	jalr	120(ra) # 80000454 <kvminithart>
    procinit();      // process table
    800003e4:	00001097          	auipc	ra,0x1
    800003e8:	a18080e7          	jalr	-1512(ra) # 80000dfc <procinit>
    trapinit();      // trap vectors
    800003ec:	00001097          	auipc	ra,0x1
    800003f0:	706080e7          	jalr	1798(ra) # 80001af2 <trapinit>
    trapinithart();  // install kernel trap vector
    800003f4:	00001097          	auipc	ra,0x1
    800003f8:	726080e7          	jalr	1830(ra) # 80001b1a <trapinithart>
    plicinit();      // set up interrupt controller
    800003fc:	00005097          	auipc	ra,0x5
    80000400:	d6e080e7          	jalr	-658(ra) # 8000516a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000404:	00005097          	auipc	ra,0x5
    80000408:	d90080e7          	jalr	-624(ra) # 80005194 <plicinithart>
    binit();         // buffer cache
    8000040c:	00002097          	auipc	ra,0x2
    80000410:	e7e080e7          	jalr	-386(ra) # 8000228a <binit>
    iinit();         // inode cache
    80000414:	00002097          	auipc	ra,0x2
    80000418:	50e080e7          	jalr	1294(ra) # 80002922 <iinit>
    fileinit();      // file table
    8000041c:	00003097          	auipc	ra,0x3
    80000420:	4c0080e7          	jalr	1216(ra) # 800038dc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000424:	00005097          	auipc	ra,0x5
    80000428:	e98080e7          	jalr	-360(ra) # 800052bc <virtio_disk_init>
    pci_init();
    8000042c:	00006097          	auipc	ra,0x6
    80000430:	26e080e7          	jalr	622(ra) # 8000669a <pci_init>
    sockinit();
    80000434:	00006097          	auipc	ra,0x6
    80000438:	e5c080e7          	jalr	-420(ra) # 80006290 <sockinit>
    userinit();      // first user process
    8000043c:	00001097          	auipc	ra,0x1
    80000440:	d4e080e7          	jalr	-690(ra) # 8000118a <userinit>
    __sync_synchronize();
    80000444:	0ff0000f          	fence
    started = 1;
    80000448:	4785                	li	a5,1
    8000044a:	0000a717          	auipc	a4,0xa
    8000044e:	baf72b23          	sw	a5,-1098(a4) # 8000a000 <started>
    80000452:	bf0d                	j	80000384 <main+0x5e>

0000000080000454 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000454:	1141                	addi	sp,sp,-16
    80000456:	e422                	sd	s0,8(sp)
    80000458:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000045a:	0000a797          	auipc	a5,0xa
    8000045e:	bae7b783          	ld	a5,-1106(a5) # 8000a008 <kernel_pagetable>
    80000462:	83b1                	srli	a5,a5,0xc
    80000464:	577d                	li	a4,-1
    80000466:	177e                	slli	a4,a4,0x3f
    80000468:	8fd9                	or	a5,a5,a4
// supervisor address translation and protection;
// holds the address of the page table.
static inline void 
w_satp(uint64 x)
{
  asm volatile("csrw satp, %0" : : "r" (x));
    8000046a:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000046e:	12000073          	sfence.vma
  sfence_vma();
}
    80000472:	6422                	ld	s0,8(sp)
    80000474:	0141                	addi	sp,sp,16
    80000476:	8082                	ret

0000000080000478 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000478:	7139                	addi	sp,sp,-64
    8000047a:	fc06                	sd	ra,56(sp)
    8000047c:	f822                	sd	s0,48(sp)
    8000047e:	f426                	sd	s1,40(sp)
    80000480:	f04a                	sd	s2,32(sp)
    80000482:	ec4e                	sd	s3,24(sp)
    80000484:	e852                	sd	s4,16(sp)
    80000486:	e456                	sd	s5,8(sp)
    80000488:	e05a                	sd	s6,0(sp)
    8000048a:	0080                	addi	s0,sp,64
    8000048c:	84aa                	mv	s1,a0
    8000048e:	89ae                	mv	s3,a1
    80000490:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000492:	57fd                	li	a5,-1
    80000494:	83e9                	srli	a5,a5,0x1a
    80000496:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000498:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000049a:	04b7f263          	bgeu	a5,a1,800004de <walk+0x66>
    panic("walk");
    8000049e:	00009517          	auipc	a0,0x9
    800004a2:	bb250513          	addi	a0,a0,-1102 # 80009050 <etext+0x50>
    800004a6:	00006097          	auipc	ra,0x6
    800004aa:	78e080e7          	jalr	1934(ra) # 80006c34 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800004ae:	060a8663          	beqz	s5,8000051a <walk+0xa2>
    800004b2:	00000097          	auipc	ra,0x0
    800004b6:	c66080e7          	jalr	-922(ra) # 80000118 <kalloc>
    800004ba:	84aa                	mv	s1,a0
    800004bc:	c529                	beqz	a0,80000506 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800004be:	6605                	lui	a2,0x1
    800004c0:	4581                	li	a1,0
    800004c2:	00000097          	auipc	ra,0x0
    800004c6:	cb6080e7          	jalr	-842(ra) # 80000178 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800004ca:	00c4d793          	srli	a5,s1,0xc
    800004ce:	07aa                	slli	a5,a5,0xa
    800004d0:	0017e793          	ori	a5,a5,1
    800004d4:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800004d8:	3a5d                	addiw	s4,s4,-9
    800004da:	036a0063          	beq	s4,s6,800004fa <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800004de:	0149d933          	srl	s2,s3,s4
    800004e2:	1ff97913          	andi	s2,s2,511
    800004e6:	090e                	slli	s2,s2,0x3
    800004e8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800004ea:	00093483          	ld	s1,0(s2)
    800004ee:	0014f793          	andi	a5,s1,1
    800004f2:	dfd5                	beqz	a5,800004ae <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800004f4:	80a9                	srli	s1,s1,0xa
    800004f6:	04b2                	slli	s1,s1,0xc
    800004f8:	b7c5                	j	800004d8 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800004fa:	00c9d513          	srli	a0,s3,0xc
    800004fe:	1ff57513          	andi	a0,a0,511
    80000502:	050e                	slli	a0,a0,0x3
    80000504:	9526                	add	a0,a0,s1
}
    80000506:	70e2                	ld	ra,56(sp)
    80000508:	7442                	ld	s0,48(sp)
    8000050a:	74a2                	ld	s1,40(sp)
    8000050c:	7902                	ld	s2,32(sp)
    8000050e:	69e2                	ld	s3,24(sp)
    80000510:	6a42                	ld	s4,16(sp)
    80000512:	6aa2                	ld	s5,8(sp)
    80000514:	6b02                	ld	s6,0(sp)
    80000516:	6121                	addi	sp,sp,64
    80000518:	8082                	ret
        return 0;
    8000051a:	4501                	li	a0,0
    8000051c:	b7ed                	j	80000506 <walk+0x8e>

000000008000051e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000051e:	57fd                	li	a5,-1
    80000520:	83e9                	srli	a5,a5,0x1a
    80000522:	00b7f463          	bgeu	a5,a1,8000052a <walkaddr+0xc>
    return 0;
    80000526:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000528:	8082                	ret
{
    8000052a:	1141                	addi	sp,sp,-16
    8000052c:	e406                	sd	ra,8(sp)
    8000052e:	e022                	sd	s0,0(sp)
    80000530:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000532:	4601                	li	a2,0
    80000534:	00000097          	auipc	ra,0x0
    80000538:	f44080e7          	jalr	-188(ra) # 80000478 <walk>
  if(pte == 0)
    8000053c:	c105                	beqz	a0,8000055c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000053e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000540:	0117f693          	andi	a3,a5,17
    80000544:	4745                	li	a4,17
    return 0;
    80000546:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000548:	00e68663          	beq	a3,a4,80000554 <walkaddr+0x36>
}
    8000054c:	60a2                	ld	ra,8(sp)
    8000054e:	6402                	ld	s0,0(sp)
    80000550:	0141                	addi	sp,sp,16
    80000552:	8082                	ret
  pa = PTE2PA(*pte);
    80000554:	00a7d513          	srli	a0,a5,0xa
    80000558:	0532                	slli	a0,a0,0xc
  return pa;
    8000055a:	bfcd                	j	8000054c <walkaddr+0x2e>
    return 0;
    8000055c:	4501                	li	a0,0
    8000055e:	b7fd                	j	8000054c <walkaddr+0x2e>

0000000080000560 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000560:	715d                	addi	sp,sp,-80
    80000562:	e486                	sd	ra,72(sp)
    80000564:	e0a2                	sd	s0,64(sp)
    80000566:	fc26                	sd	s1,56(sp)
    80000568:	f84a                	sd	s2,48(sp)
    8000056a:	f44e                	sd	s3,40(sp)
    8000056c:	f052                	sd	s4,32(sp)
    8000056e:	ec56                	sd	s5,24(sp)
    80000570:	e85a                	sd	s6,16(sp)
    80000572:	e45e                	sd	s7,8(sp)
    80000574:	0880                	addi	s0,sp,80
    80000576:	8aaa                	mv	s5,a0
    80000578:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    8000057a:	777d                	lui	a4,0xfffff
    8000057c:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80000580:	167d                	addi	a2,a2,-1
    80000582:	00b609b3          	add	s3,a2,a1
    80000586:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000058a:	893e                	mv	s2,a5
    8000058c:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80000590:	6b85                	lui	s7,0x1
    80000592:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80000596:	4605                	li	a2,1
    80000598:	85ca                	mv	a1,s2
    8000059a:	8556                	mv	a0,s5
    8000059c:	00000097          	auipc	ra,0x0
    800005a0:	edc080e7          	jalr	-292(ra) # 80000478 <walk>
    800005a4:	c51d                	beqz	a0,800005d2 <mappages+0x72>
    if(*pte & PTE_V)
    800005a6:	611c                	ld	a5,0(a0)
    800005a8:	8b85                	andi	a5,a5,1
    800005aa:	ef81                	bnez	a5,800005c2 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800005ac:	80b1                	srli	s1,s1,0xc
    800005ae:	04aa                	slli	s1,s1,0xa
    800005b0:	0164e4b3          	or	s1,s1,s6
    800005b4:	0014e493          	ori	s1,s1,1
    800005b8:	e104                	sd	s1,0(a0)
    if(a == last)
    800005ba:	03390863          	beq	s2,s3,800005ea <mappages+0x8a>
    a += PGSIZE;
    800005be:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800005c0:	bfc9                	j	80000592 <mappages+0x32>
      panic("remap");
    800005c2:	00009517          	auipc	a0,0x9
    800005c6:	a9650513          	addi	a0,a0,-1386 # 80009058 <etext+0x58>
    800005ca:	00006097          	auipc	ra,0x6
    800005ce:	66a080e7          	jalr	1642(ra) # 80006c34 <panic>
      return -1;
    800005d2:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800005d4:	60a6                	ld	ra,72(sp)
    800005d6:	6406                	ld	s0,64(sp)
    800005d8:	74e2                	ld	s1,56(sp)
    800005da:	7942                	ld	s2,48(sp)
    800005dc:	79a2                	ld	s3,40(sp)
    800005de:	7a02                	ld	s4,32(sp)
    800005e0:	6ae2                	ld	s5,24(sp)
    800005e2:	6b42                	ld	s6,16(sp)
    800005e4:	6ba2                	ld	s7,8(sp)
    800005e6:	6161                	addi	sp,sp,80
    800005e8:	8082                	ret
  return 0;
    800005ea:	4501                	li	a0,0
    800005ec:	b7e5                	j	800005d4 <mappages+0x74>

00000000800005ee <kvmmap>:
{
    800005ee:	1141                	addi	sp,sp,-16
    800005f0:	e406                	sd	ra,8(sp)
    800005f2:	e022                	sd	s0,0(sp)
    800005f4:	0800                	addi	s0,sp,16
    800005f6:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800005f8:	86b2                	mv	a3,a2
    800005fa:	863e                	mv	a2,a5
    800005fc:	00000097          	auipc	ra,0x0
    80000600:	f64080e7          	jalr	-156(ra) # 80000560 <mappages>
    80000604:	e509                	bnez	a0,8000060e <kvmmap+0x20>
}
    80000606:	60a2                	ld	ra,8(sp)
    80000608:	6402                	ld	s0,0(sp)
    8000060a:	0141                	addi	sp,sp,16
    8000060c:	8082                	ret
    panic("kvmmap");
    8000060e:	00009517          	auipc	a0,0x9
    80000612:	a5250513          	addi	a0,a0,-1454 # 80009060 <etext+0x60>
    80000616:	00006097          	auipc	ra,0x6
    8000061a:	61e080e7          	jalr	1566(ra) # 80006c34 <panic>

000000008000061e <kvmmake>:
{
    8000061e:	1101                	addi	sp,sp,-32
    80000620:	ec06                	sd	ra,24(sp)
    80000622:	e822                	sd	s0,16(sp)
    80000624:	e426                	sd	s1,8(sp)
    80000626:	e04a                	sd	s2,0(sp)
    80000628:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000062a:	00000097          	auipc	ra,0x0
    8000062e:	aee080e7          	jalr	-1298(ra) # 80000118 <kalloc>
    80000632:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000634:	6605                	lui	a2,0x1
    80000636:	4581                	li	a1,0
    80000638:	00000097          	auipc	ra,0x0
    8000063c:	b40080e7          	jalr	-1216(ra) # 80000178 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80000640:	4719                	li	a4,6
    80000642:	6685                	lui	a3,0x1
    80000644:	10000637          	lui	a2,0x10000
    80000648:	100005b7          	lui	a1,0x10000
    8000064c:	8526                	mv	a0,s1
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	fa0080e7          	jalr	-96(ra) # 800005ee <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000656:	4719                	li	a4,6
    80000658:	6685                	lui	a3,0x1
    8000065a:	10001637          	lui	a2,0x10001
    8000065e:	100015b7          	lui	a1,0x10001
    80000662:	8526                	mv	a0,s1
    80000664:	00000097          	auipc	ra,0x0
    80000668:	f8a080e7          	jalr	-118(ra) # 800005ee <kvmmap>
  kvmmap(kpgtbl, 0x30000000L, 0x30000000L, 0x10000000, PTE_R | PTE_W);
    8000066c:	4719                	li	a4,6
    8000066e:	100006b7          	lui	a3,0x10000
    80000672:	30000637          	lui	a2,0x30000
    80000676:	300005b7          	lui	a1,0x30000
    8000067a:	8526                	mv	a0,s1
    8000067c:	00000097          	auipc	ra,0x0
    80000680:	f72080e7          	jalr	-142(ra) # 800005ee <kvmmap>
  kvmmap(kpgtbl, 0x40000000L, 0x40000000L, 0x20000, PTE_R | PTE_W);
    80000684:	4719                	li	a4,6
    80000686:	000206b7          	lui	a3,0x20
    8000068a:	40000637          	lui	a2,0x40000
    8000068e:	400005b7          	lui	a1,0x40000
    80000692:	8526                	mv	a0,s1
    80000694:	00000097          	auipc	ra,0x0
    80000698:	f5a080e7          	jalr	-166(ra) # 800005ee <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000069c:	4719                	li	a4,6
    8000069e:	004006b7          	lui	a3,0x400
    800006a2:	0c000637          	lui	a2,0xc000
    800006a6:	0c0005b7          	lui	a1,0xc000
    800006aa:	8526                	mv	a0,s1
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	f42080e7          	jalr	-190(ra) # 800005ee <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800006b4:	00009917          	auipc	s2,0x9
    800006b8:	94c90913          	addi	s2,s2,-1716 # 80009000 <etext>
    800006bc:	4729                	li	a4,10
    800006be:	80009697          	auipc	a3,0x80009
    800006c2:	94268693          	addi	a3,a3,-1726 # 9000 <_entry-0x7fff7000>
    800006c6:	4605                	li	a2,1
    800006c8:	067e                	slli	a2,a2,0x1f
    800006ca:	85b2                	mv	a1,a2
    800006cc:	8526                	mv	a0,s1
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	f20080e7          	jalr	-224(ra) # 800005ee <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800006d6:	4719                	li	a4,6
    800006d8:	46c5                	li	a3,17
    800006da:	06ee                	slli	a3,a3,0x1b
    800006dc:	412686b3          	sub	a3,a3,s2
    800006e0:	864a                	mv	a2,s2
    800006e2:	85ca                	mv	a1,s2
    800006e4:	8526                	mv	a0,s1
    800006e6:	00000097          	auipc	ra,0x0
    800006ea:	f08080e7          	jalr	-248(ra) # 800005ee <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800006ee:	4729                	li	a4,10
    800006f0:	6685                	lui	a3,0x1
    800006f2:	00008617          	auipc	a2,0x8
    800006f6:	90e60613          	addi	a2,a2,-1778 # 80008000 <_trampoline>
    800006fa:	040005b7          	lui	a1,0x4000
    800006fe:	15fd                	addi	a1,a1,-1
    80000700:	05b2                	slli	a1,a1,0xc
    80000702:	8526                	mv	a0,s1
    80000704:	00000097          	auipc	ra,0x0
    80000708:	eea080e7          	jalr	-278(ra) # 800005ee <kvmmap>
  proc_mapstacks(kpgtbl);
    8000070c:	8526                	mv	a0,s1
    8000070e:	00000097          	auipc	ra,0x0
    80000712:	658080e7          	jalr	1624(ra) # 80000d66 <proc_mapstacks>
}
    80000716:	8526                	mv	a0,s1
    80000718:	60e2                	ld	ra,24(sp)
    8000071a:	6442                	ld	s0,16(sp)
    8000071c:	64a2                	ld	s1,8(sp)
    8000071e:	6902                	ld	s2,0(sp)
    80000720:	6105                	addi	sp,sp,32
    80000722:	8082                	ret

0000000080000724 <kvminit>:
{
    80000724:	1141                	addi	sp,sp,-16
    80000726:	e406                	sd	ra,8(sp)
    80000728:	e022                	sd	s0,0(sp)
    8000072a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	ef2080e7          	jalr	-270(ra) # 8000061e <kvmmake>
    80000734:	0000a797          	auipc	a5,0xa
    80000738:	8ca7ba23          	sd	a0,-1836(a5) # 8000a008 <kernel_pagetable>
}
    8000073c:	60a2                	ld	ra,8(sp)
    8000073e:	6402                	ld	s0,0(sp)
    80000740:	0141                	addi	sp,sp,16
    80000742:	8082                	ret

0000000080000744 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000744:	715d                	addi	sp,sp,-80
    80000746:	e486                	sd	ra,72(sp)
    80000748:	e0a2                	sd	s0,64(sp)
    8000074a:	fc26                	sd	s1,56(sp)
    8000074c:	f84a                	sd	s2,48(sp)
    8000074e:	f44e                	sd	s3,40(sp)
    80000750:	f052                	sd	s4,32(sp)
    80000752:	ec56                	sd	s5,24(sp)
    80000754:	e85a                	sd	s6,16(sp)
    80000756:	e45e                	sd	s7,8(sp)
    80000758:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000075a:	03459793          	slli	a5,a1,0x34
    8000075e:	e795                	bnez	a5,8000078a <uvmunmap+0x46>
    80000760:	8a2a                	mv	s4,a0
    80000762:	892e                	mv	s2,a1
    80000764:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000766:	0632                	slli	a2,a2,0xc
    80000768:	00b609b3          	add	s3,a2,a1
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0) {
      printf("va=%p pte=%p\n", a, *pte);
      panic("uvmunmap: not mapped");
    }
    if(PTE_FLAGS(*pte) == PTE_V)
    8000076c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000076e:	6b05                	lui	s6,0x1
    80000770:	0735eb63          	bltu	a1,s3,800007e6 <uvmunmap+0xa2>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80000774:	60a6                	ld	ra,72(sp)
    80000776:	6406                	ld	s0,64(sp)
    80000778:	74e2                	ld	s1,56(sp)
    8000077a:	7942                	ld	s2,48(sp)
    8000077c:	79a2                	ld	s3,40(sp)
    8000077e:	7a02                	ld	s4,32(sp)
    80000780:	6ae2                	ld	s5,24(sp)
    80000782:	6b42                	ld	s6,16(sp)
    80000784:	6ba2                	ld	s7,8(sp)
    80000786:	6161                	addi	sp,sp,80
    80000788:	8082                	ret
    panic("uvmunmap: not aligned");
    8000078a:	00009517          	auipc	a0,0x9
    8000078e:	8de50513          	addi	a0,a0,-1826 # 80009068 <etext+0x68>
    80000792:	00006097          	auipc	ra,0x6
    80000796:	4a2080e7          	jalr	1186(ra) # 80006c34 <panic>
      panic("uvmunmap: walk");
    8000079a:	00009517          	auipc	a0,0x9
    8000079e:	8e650513          	addi	a0,a0,-1818 # 80009080 <etext+0x80>
    800007a2:	00006097          	auipc	ra,0x6
    800007a6:	492080e7          	jalr	1170(ra) # 80006c34 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    800007aa:	85ca                	mv	a1,s2
    800007ac:	00009517          	auipc	a0,0x9
    800007b0:	8e450513          	addi	a0,a0,-1820 # 80009090 <etext+0x90>
    800007b4:	00006097          	auipc	ra,0x6
    800007b8:	4ca080e7          	jalr	1226(ra) # 80006c7e <printf>
      panic("uvmunmap: not mapped");
    800007bc:	00009517          	auipc	a0,0x9
    800007c0:	8e450513          	addi	a0,a0,-1820 # 800090a0 <etext+0xa0>
    800007c4:	00006097          	auipc	ra,0x6
    800007c8:	470080e7          	jalr	1136(ra) # 80006c34 <panic>
      panic("uvmunmap: not a leaf");
    800007cc:	00009517          	auipc	a0,0x9
    800007d0:	8ec50513          	addi	a0,a0,-1812 # 800090b8 <etext+0xb8>
    800007d4:	00006097          	auipc	ra,0x6
    800007d8:	460080e7          	jalr	1120(ra) # 80006c34 <panic>
    *pte = 0;
    800007dc:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800007e0:	995a                	add	s2,s2,s6
    800007e2:	f93979e3          	bgeu	s2,s3,80000774 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800007e6:	4601                	li	a2,0
    800007e8:	85ca                	mv	a1,s2
    800007ea:	8552                	mv	a0,s4
    800007ec:	00000097          	auipc	ra,0x0
    800007f0:	c8c080e7          	jalr	-884(ra) # 80000478 <walk>
    800007f4:	84aa                	mv	s1,a0
    800007f6:	d155                	beqz	a0,8000079a <uvmunmap+0x56>
    if((*pte & PTE_V) == 0) {
    800007f8:	6110                	ld	a2,0(a0)
    800007fa:	00167793          	andi	a5,a2,1
    800007fe:	d7d5                	beqz	a5,800007aa <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80000800:	3ff67793          	andi	a5,a2,1023
    80000804:	fd7784e3          	beq	a5,s7,800007cc <uvmunmap+0x88>
    if(do_free){
    80000808:	fc0a8ae3          	beqz	s5,800007dc <uvmunmap+0x98>
      uint64 pa = PTE2PA(*pte);
    8000080c:	8229                	srli	a2,a2,0xa
      kfree((void*)pa);
    8000080e:	00c61513          	slli	a0,a2,0xc
    80000812:	00000097          	auipc	ra,0x0
    80000816:	80a080e7          	jalr	-2038(ra) # 8000001c <kfree>
    8000081a:	b7c9                	j	800007dc <uvmunmap+0x98>

000000008000081c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000081c:	1101                	addi	sp,sp,-32
    8000081e:	ec06                	sd	ra,24(sp)
    80000820:	e822                	sd	s0,16(sp)
    80000822:	e426                	sd	s1,8(sp)
    80000824:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	8f2080e7          	jalr	-1806(ra) # 80000118 <kalloc>
    8000082e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000830:	c519                	beqz	a0,8000083e <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80000832:	6605                	lui	a2,0x1
    80000834:	4581                	li	a1,0
    80000836:	00000097          	auipc	ra,0x0
    8000083a:	942080e7          	jalr	-1726(ra) # 80000178 <memset>
  return pagetable;
}
    8000083e:	8526                	mv	a0,s1
    80000840:	60e2                	ld	ra,24(sp)
    80000842:	6442                	ld	s0,16(sp)
    80000844:	64a2                	ld	s1,8(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000084a:	7179                	addi	sp,sp,-48
    8000084c:	f406                	sd	ra,40(sp)
    8000084e:	f022                	sd	s0,32(sp)
    80000850:	ec26                	sd	s1,24(sp)
    80000852:	e84a                	sd	s2,16(sp)
    80000854:	e44e                	sd	s3,8(sp)
    80000856:	e052                	sd	s4,0(sp)
    80000858:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000085a:	6785                	lui	a5,0x1
    8000085c:	04f67863          	bgeu	a2,a5,800008ac <uvminit+0x62>
    80000860:	8a2a                	mv	s4,a0
    80000862:	89ae                	mv	s3,a1
    80000864:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80000866:	00000097          	auipc	ra,0x0
    8000086a:	8b2080e7          	jalr	-1870(ra) # 80000118 <kalloc>
    8000086e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000870:	6605                	lui	a2,0x1
    80000872:	4581                	li	a1,0
    80000874:	00000097          	auipc	ra,0x0
    80000878:	904080e7          	jalr	-1788(ra) # 80000178 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000087c:	4779                	li	a4,30
    8000087e:	86ca                	mv	a3,s2
    80000880:	6605                	lui	a2,0x1
    80000882:	4581                	li	a1,0
    80000884:	8552                	mv	a0,s4
    80000886:	00000097          	auipc	ra,0x0
    8000088a:	cda080e7          	jalr	-806(ra) # 80000560 <mappages>
  memmove(mem, src, sz);
    8000088e:	8626                	mv	a2,s1
    80000890:	85ce                	mv	a1,s3
    80000892:	854a                	mv	a0,s2
    80000894:	00000097          	auipc	ra,0x0
    80000898:	940080e7          	jalr	-1728(ra) # 800001d4 <memmove>
}
    8000089c:	70a2                	ld	ra,40(sp)
    8000089e:	7402                	ld	s0,32(sp)
    800008a0:	64e2                	ld	s1,24(sp)
    800008a2:	6942                	ld	s2,16(sp)
    800008a4:	69a2                	ld	s3,8(sp)
    800008a6:	6a02                	ld	s4,0(sp)
    800008a8:	6145                	addi	sp,sp,48
    800008aa:	8082                	ret
    panic("inituvm: more than a page");
    800008ac:	00009517          	auipc	a0,0x9
    800008b0:	82450513          	addi	a0,a0,-2012 # 800090d0 <etext+0xd0>
    800008b4:	00006097          	auipc	ra,0x6
    800008b8:	380080e7          	jalr	896(ra) # 80006c34 <panic>

00000000800008bc <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800008bc:	1101                	addi	sp,sp,-32
    800008be:	ec06                	sd	ra,24(sp)
    800008c0:	e822                	sd	s0,16(sp)
    800008c2:	e426                	sd	s1,8(sp)
    800008c4:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800008c6:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800008c8:	00b67d63          	bgeu	a2,a1,800008e2 <uvmdealloc+0x26>
    800008cc:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800008ce:	6785                	lui	a5,0x1
    800008d0:	17fd                	addi	a5,a5,-1
    800008d2:	00f60733          	add	a4,a2,a5
    800008d6:	767d                	lui	a2,0xfffff
    800008d8:	8f71                	and	a4,a4,a2
    800008da:	97ae                	add	a5,a5,a1
    800008dc:	8ff1                	and	a5,a5,a2
    800008de:	00f76863          	bltu	a4,a5,800008ee <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800008e2:	8526                	mv	a0,s1
    800008e4:	60e2                	ld	ra,24(sp)
    800008e6:	6442                	ld	s0,16(sp)
    800008e8:	64a2                	ld	s1,8(sp)
    800008ea:	6105                	addi	sp,sp,32
    800008ec:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800008ee:	8f99                	sub	a5,a5,a4
    800008f0:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800008f2:	4685                	li	a3,1
    800008f4:	0007861b          	sext.w	a2,a5
    800008f8:	85ba                	mv	a1,a4
    800008fa:	00000097          	auipc	ra,0x0
    800008fe:	e4a080e7          	jalr	-438(ra) # 80000744 <uvmunmap>
    80000902:	b7c5                	j	800008e2 <uvmdealloc+0x26>

0000000080000904 <uvmalloc>:
  if(newsz < oldsz)
    80000904:	0ab66163          	bltu	a2,a1,800009a6 <uvmalloc+0xa2>
{
    80000908:	7139                	addi	sp,sp,-64
    8000090a:	fc06                	sd	ra,56(sp)
    8000090c:	f822                	sd	s0,48(sp)
    8000090e:	f426                	sd	s1,40(sp)
    80000910:	f04a                	sd	s2,32(sp)
    80000912:	ec4e                	sd	s3,24(sp)
    80000914:	e852                	sd	s4,16(sp)
    80000916:	e456                	sd	s5,8(sp)
    80000918:	0080                	addi	s0,sp,64
    8000091a:	8aaa                	mv	s5,a0
    8000091c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000091e:	6985                	lui	s3,0x1
    80000920:	19fd                	addi	s3,s3,-1
    80000922:	95ce                	add	a1,a1,s3
    80000924:	79fd                	lui	s3,0xfffff
    80000926:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000092a:	08c9f063          	bgeu	s3,a2,800009aa <uvmalloc+0xa6>
    8000092e:	894e                	mv	s2,s3
    mem = kalloc();
    80000930:	fffff097          	auipc	ra,0xfffff
    80000934:	7e8080e7          	jalr	2024(ra) # 80000118 <kalloc>
    80000938:	84aa                	mv	s1,a0
    if(mem == 0){
    8000093a:	c51d                	beqz	a0,80000968 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000093c:	6605                	lui	a2,0x1
    8000093e:	4581                	li	a1,0
    80000940:	00000097          	auipc	ra,0x0
    80000944:	838080e7          	jalr	-1992(ra) # 80000178 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80000948:	4779                	li	a4,30
    8000094a:	86a6                	mv	a3,s1
    8000094c:	6605                	lui	a2,0x1
    8000094e:	85ca                	mv	a1,s2
    80000950:	8556                	mv	a0,s5
    80000952:	00000097          	auipc	ra,0x0
    80000956:	c0e080e7          	jalr	-1010(ra) # 80000560 <mappages>
    8000095a:	e905                	bnez	a0,8000098a <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000095c:	6785                	lui	a5,0x1
    8000095e:	993e                	add	s2,s2,a5
    80000960:	fd4968e3          	bltu	s2,s4,80000930 <uvmalloc+0x2c>
  return newsz;
    80000964:	8552                	mv	a0,s4
    80000966:	a809                	j	80000978 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80000968:	864e                	mv	a2,s3
    8000096a:	85ca                	mv	a1,s2
    8000096c:	8556                	mv	a0,s5
    8000096e:	00000097          	auipc	ra,0x0
    80000972:	f4e080e7          	jalr	-178(ra) # 800008bc <uvmdealloc>
      return 0;
    80000976:	4501                	li	a0,0
}
    80000978:	70e2                	ld	ra,56(sp)
    8000097a:	7442                	ld	s0,48(sp)
    8000097c:	74a2                	ld	s1,40(sp)
    8000097e:	7902                	ld	s2,32(sp)
    80000980:	69e2                	ld	s3,24(sp)
    80000982:	6a42                	ld	s4,16(sp)
    80000984:	6aa2                	ld	s5,8(sp)
    80000986:	6121                	addi	sp,sp,64
    80000988:	8082                	ret
      kfree(mem);
    8000098a:	8526                	mv	a0,s1
    8000098c:	fffff097          	auipc	ra,0xfffff
    80000990:	690080e7          	jalr	1680(ra) # 8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80000994:	864e                	mv	a2,s3
    80000996:	85ca                	mv	a1,s2
    80000998:	8556                	mv	a0,s5
    8000099a:	00000097          	auipc	ra,0x0
    8000099e:	f22080e7          	jalr	-222(ra) # 800008bc <uvmdealloc>
      return 0;
    800009a2:	4501                	li	a0,0
    800009a4:	bfd1                	j	80000978 <uvmalloc+0x74>
    return oldsz;
    800009a6:	852e                	mv	a0,a1
}
    800009a8:	8082                	ret
  return newsz;
    800009aa:	8532                	mv	a0,a2
    800009ac:	b7f1                	j	80000978 <uvmalloc+0x74>

00000000800009ae <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800009ae:	7179                	addi	sp,sp,-48
    800009b0:	f406                	sd	ra,40(sp)
    800009b2:	f022                	sd	s0,32(sp)
    800009b4:	ec26                	sd	s1,24(sp)
    800009b6:	e84a                	sd	s2,16(sp)
    800009b8:	e44e                	sd	s3,8(sp)
    800009ba:	e052                	sd	s4,0(sp)
    800009bc:	1800                	addi	s0,sp,48
    800009be:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800009c0:	84aa                	mv	s1,a0
    800009c2:	6905                	lui	s2,0x1
    800009c4:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800009c6:	4985                	li	s3,1
    800009c8:	a821                	j	800009e0 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800009ca:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800009cc:	0532                	slli	a0,a0,0xc
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	fe0080e7          	jalr	-32(ra) # 800009ae <freewalk>
      pagetable[i] = 0;
    800009d6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800009da:	04a1                	addi	s1,s1,8
    800009dc:	03248163          	beq	s1,s2,800009fe <freewalk+0x50>
    pte_t pte = pagetable[i];
    800009e0:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800009e2:	00f57793          	andi	a5,a0,15
    800009e6:	ff3782e3          	beq	a5,s3,800009ca <freewalk+0x1c>
    } else if(pte & PTE_V){
    800009ea:	8905                	andi	a0,a0,1
    800009ec:	d57d                	beqz	a0,800009da <freewalk+0x2c>
      panic("freewalk: leaf");
    800009ee:	00008517          	auipc	a0,0x8
    800009f2:	70250513          	addi	a0,a0,1794 # 800090f0 <etext+0xf0>
    800009f6:	00006097          	auipc	ra,0x6
    800009fa:	23e080e7          	jalr	574(ra) # 80006c34 <panic>
    }
  }
  kfree((void*)pagetable);
    800009fe:	8552                	mv	a0,s4
    80000a00:	fffff097          	auipc	ra,0xfffff
    80000a04:	61c080e7          	jalr	1564(ra) # 8000001c <kfree>
}
    80000a08:	70a2                	ld	ra,40(sp)
    80000a0a:	7402                	ld	s0,32(sp)
    80000a0c:	64e2                	ld	s1,24(sp)
    80000a0e:	6942                	ld	s2,16(sp)
    80000a10:	69a2                	ld	s3,8(sp)
    80000a12:	6a02                	ld	s4,0(sp)
    80000a14:	6145                	addi	sp,sp,48
    80000a16:	8082                	ret

0000000080000a18 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000a18:	1101                	addi	sp,sp,-32
    80000a1a:	ec06                	sd	ra,24(sp)
    80000a1c:	e822                	sd	s0,16(sp)
    80000a1e:	e426                	sd	s1,8(sp)
    80000a20:	1000                	addi	s0,sp,32
    80000a22:	84aa                	mv	s1,a0
  if(sz > 0)
    80000a24:	e999                	bnez	a1,80000a3a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80000a26:	8526                	mv	a0,s1
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	f86080e7          	jalr	-122(ra) # 800009ae <freewalk>
}
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6105                	addi	sp,sp,32
    80000a38:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80000a3a:	6605                	lui	a2,0x1
    80000a3c:	167d                	addi	a2,a2,-1
    80000a3e:	962e                	add	a2,a2,a1
    80000a40:	4685                	li	a3,1
    80000a42:	8231                	srli	a2,a2,0xc
    80000a44:	4581                	li	a1,0
    80000a46:	00000097          	auipc	ra,0x0
    80000a4a:	cfe080e7          	jalr	-770(ra) # 80000744 <uvmunmap>
    80000a4e:	bfe1                	j	80000a26 <uvmfree+0xe>

0000000080000a50 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80000a50:	c679                	beqz	a2,80000b1e <uvmcopy+0xce>
{
    80000a52:	715d                	addi	sp,sp,-80
    80000a54:	e486                	sd	ra,72(sp)
    80000a56:	e0a2                	sd	s0,64(sp)
    80000a58:	fc26                	sd	s1,56(sp)
    80000a5a:	f84a                	sd	s2,48(sp)
    80000a5c:	f44e                	sd	s3,40(sp)
    80000a5e:	f052                	sd	s4,32(sp)
    80000a60:	ec56                	sd	s5,24(sp)
    80000a62:	e85a                	sd	s6,16(sp)
    80000a64:	e45e                	sd	s7,8(sp)
    80000a66:	0880                	addi	s0,sp,80
    80000a68:	8b2a                	mv	s6,a0
    80000a6a:	8aae                	mv	s5,a1
    80000a6c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80000a6e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80000a70:	4601                	li	a2,0
    80000a72:	85ce                	mv	a1,s3
    80000a74:	855a                	mv	a0,s6
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	a02080e7          	jalr	-1534(ra) # 80000478 <walk>
    80000a7e:	c531                	beqz	a0,80000aca <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80000a80:	6118                	ld	a4,0(a0)
    80000a82:	00177793          	andi	a5,a4,1
    80000a86:	cbb1                	beqz	a5,80000ada <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000a88:	00a75593          	srli	a1,a4,0xa
    80000a8c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80000a90:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80000a94:	fffff097          	auipc	ra,0xfffff
    80000a98:	684080e7          	jalr	1668(ra) # 80000118 <kalloc>
    80000a9c:	892a                	mv	s2,a0
    80000a9e:	c939                	beqz	a0,80000af4 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80000aa0:	6605                	lui	a2,0x1
    80000aa2:	85de                	mv	a1,s7
    80000aa4:	fffff097          	auipc	ra,0xfffff
    80000aa8:	730080e7          	jalr	1840(ra) # 800001d4 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80000aac:	8726                	mv	a4,s1
    80000aae:	86ca                	mv	a3,s2
    80000ab0:	6605                	lui	a2,0x1
    80000ab2:	85ce                	mv	a1,s3
    80000ab4:	8556                	mv	a0,s5
    80000ab6:	00000097          	auipc	ra,0x0
    80000aba:	aaa080e7          	jalr	-1366(ra) # 80000560 <mappages>
    80000abe:	e515                	bnez	a0,80000aea <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80000ac0:	6785                	lui	a5,0x1
    80000ac2:	99be                	add	s3,s3,a5
    80000ac4:	fb49e6e3          	bltu	s3,s4,80000a70 <uvmcopy+0x20>
    80000ac8:	a081                	j	80000b08 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80000aca:	00008517          	auipc	a0,0x8
    80000ace:	63650513          	addi	a0,a0,1590 # 80009100 <etext+0x100>
    80000ad2:	00006097          	auipc	ra,0x6
    80000ad6:	162080e7          	jalr	354(ra) # 80006c34 <panic>
      panic("uvmcopy: page not present");
    80000ada:	00008517          	auipc	a0,0x8
    80000ade:	64650513          	addi	a0,a0,1606 # 80009120 <etext+0x120>
    80000ae2:	00006097          	auipc	ra,0x6
    80000ae6:	152080e7          	jalr	338(ra) # 80006c34 <panic>
      kfree(mem);
    80000aea:	854a                	mv	a0,s2
    80000aec:	fffff097          	auipc	ra,0xfffff
    80000af0:	530080e7          	jalr	1328(ra) # 8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000af4:	4685                	li	a3,1
    80000af6:	00c9d613          	srli	a2,s3,0xc
    80000afa:	4581                	li	a1,0
    80000afc:	8556                	mv	a0,s5
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	c46080e7          	jalr	-954(ra) # 80000744 <uvmunmap>
  return -1;
    80000b06:	557d                	li	a0,-1
}
    80000b08:	60a6                	ld	ra,72(sp)
    80000b0a:	6406                	ld	s0,64(sp)
    80000b0c:	74e2                	ld	s1,56(sp)
    80000b0e:	7942                	ld	s2,48(sp)
    80000b10:	79a2                	ld	s3,40(sp)
    80000b12:	7a02                	ld	s4,32(sp)
    80000b14:	6ae2                	ld	s5,24(sp)
    80000b16:	6b42                	ld	s6,16(sp)
    80000b18:	6ba2                	ld	s7,8(sp)
    80000b1a:	6161                	addi	sp,sp,80
    80000b1c:	8082                	ret
  return 0;
    80000b1e:	4501                	li	a0,0
}
    80000b20:	8082                	ret

0000000080000b22 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000b22:	1141                	addi	sp,sp,-16
    80000b24:	e406                	sd	ra,8(sp)
    80000b26:	e022                	sd	s0,0(sp)
    80000b28:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000b2a:	4601                	li	a2,0
    80000b2c:	00000097          	auipc	ra,0x0
    80000b30:	94c080e7          	jalr	-1716(ra) # 80000478 <walk>
  if(pte == 0)
    80000b34:	c901                	beqz	a0,80000b44 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000b36:	611c                	ld	a5,0(a0)
    80000b38:	9bbd                	andi	a5,a5,-17
    80000b3a:	e11c                	sd	a5,0(a0)
}
    80000b3c:	60a2                	ld	ra,8(sp)
    80000b3e:	6402                	ld	s0,0(sp)
    80000b40:	0141                	addi	sp,sp,16
    80000b42:	8082                	ret
    panic("uvmclear");
    80000b44:	00008517          	auipc	a0,0x8
    80000b48:	5fc50513          	addi	a0,a0,1532 # 80009140 <etext+0x140>
    80000b4c:	00006097          	auipc	ra,0x6
    80000b50:	0e8080e7          	jalr	232(ra) # 80006c34 <panic>

0000000080000b54 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000b54:	c6bd                	beqz	a3,80000bc2 <copyout+0x6e>
{
    80000b56:	715d                	addi	sp,sp,-80
    80000b58:	e486                	sd	ra,72(sp)
    80000b5a:	e0a2                	sd	s0,64(sp)
    80000b5c:	fc26                	sd	s1,56(sp)
    80000b5e:	f84a                	sd	s2,48(sp)
    80000b60:	f44e                	sd	s3,40(sp)
    80000b62:	f052                	sd	s4,32(sp)
    80000b64:	ec56                	sd	s5,24(sp)
    80000b66:	e85a                	sd	s6,16(sp)
    80000b68:	e45e                	sd	s7,8(sp)
    80000b6a:	e062                	sd	s8,0(sp)
    80000b6c:	0880                	addi	s0,sp,80
    80000b6e:	8b2a                	mv	s6,a0
    80000b70:	8c2e                	mv	s8,a1
    80000b72:	8a32                	mv	s4,a2
    80000b74:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000b76:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80000b78:	6a85                	lui	s5,0x1
    80000b7a:	a015                	j	80000b9e <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000b7c:	9562                	add	a0,a0,s8
    80000b7e:	0004861b          	sext.w	a2,s1
    80000b82:	85d2                	mv	a1,s4
    80000b84:	41250533          	sub	a0,a0,s2
    80000b88:	fffff097          	auipc	ra,0xfffff
    80000b8c:	64c080e7          	jalr	1612(ra) # 800001d4 <memmove>

    len -= n;
    80000b90:	409989b3          	sub	s3,s3,s1
    src += n;
    80000b94:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80000b96:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000b9a:	02098263          	beqz	s3,80000bbe <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80000b9e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000ba2:	85ca                	mv	a1,s2
    80000ba4:	855a                	mv	a0,s6
    80000ba6:	00000097          	auipc	ra,0x0
    80000baa:	978080e7          	jalr	-1672(ra) # 8000051e <walkaddr>
    if(pa0 == 0)
    80000bae:	cd01                	beqz	a0,80000bc6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80000bb0:	418904b3          	sub	s1,s2,s8
    80000bb4:	94d6                	add	s1,s1,s5
    if(n > len)
    80000bb6:	fc99f3e3          	bgeu	s3,s1,80000b7c <copyout+0x28>
    80000bba:	84ce                	mv	s1,s3
    80000bbc:	b7c1                	j	80000b7c <copyout+0x28>
  }
  return 0;
    80000bbe:	4501                	li	a0,0
    80000bc0:	a021                	j	80000bc8 <copyout+0x74>
    80000bc2:	4501                	li	a0,0
}
    80000bc4:	8082                	ret
      return -1;
    80000bc6:	557d                	li	a0,-1
}
    80000bc8:	60a6                	ld	ra,72(sp)
    80000bca:	6406                	ld	s0,64(sp)
    80000bcc:	74e2                	ld	s1,56(sp)
    80000bce:	7942                	ld	s2,48(sp)
    80000bd0:	79a2                	ld	s3,40(sp)
    80000bd2:	7a02                	ld	s4,32(sp)
    80000bd4:	6ae2                	ld	s5,24(sp)
    80000bd6:	6b42                	ld	s6,16(sp)
    80000bd8:	6ba2                	ld	s7,8(sp)
    80000bda:	6c02                	ld	s8,0(sp)
    80000bdc:	6161                	addi	sp,sp,80
    80000bde:	8082                	ret

0000000080000be0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;
  
  while(len > 0){
    80000be0:	caa5                	beqz	a3,80000c50 <copyin+0x70>
{
    80000be2:	715d                	addi	sp,sp,-80
    80000be4:	e486                	sd	ra,72(sp)
    80000be6:	e0a2                	sd	s0,64(sp)
    80000be8:	fc26                	sd	s1,56(sp)
    80000bea:	f84a                	sd	s2,48(sp)
    80000bec:	f44e                	sd	s3,40(sp)
    80000bee:	f052                	sd	s4,32(sp)
    80000bf0:	ec56                	sd	s5,24(sp)
    80000bf2:	e85a                	sd	s6,16(sp)
    80000bf4:	e45e                	sd	s7,8(sp)
    80000bf6:	e062                	sd	s8,0(sp)
    80000bf8:	0880                	addi	s0,sp,80
    80000bfa:	8b2a                	mv	s6,a0
    80000bfc:	8a2e                	mv	s4,a1
    80000bfe:	8c32                	mv	s8,a2
    80000c00:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000c02:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000c04:	6a85                	lui	s5,0x1
    80000c06:	a01d                	j	80000c2c <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000c08:	018505b3          	add	a1,a0,s8
    80000c0c:	0004861b          	sext.w	a2,s1
    80000c10:	412585b3          	sub	a1,a1,s2
    80000c14:	8552                	mv	a0,s4
    80000c16:	fffff097          	auipc	ra,0xfffff
    80000c1a:	5be080e7          	jalr	1470(ra) # 800001d4 <memmove>

    len -= n;
    80000c1e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000c22:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000c24:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000c28:	02098263          	beqz	s3,80000c4c <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80000c2c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000c30:	85ca                	mv	a1,s2
    80000c32:	855a                	mv	a0,s6
    80000c34:	00000097          	auipc	ra,0x0
    80000c38:	8ea080e7          	jalr	-1814(ra) # 8000051e <walkaddr>
    if(pa0 == 0)
    80000c3c:	cd01                	beqz	a0,80000c54 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80000c3e:	418904b3          	sub	s1,s2,s8
    80000c42:	94d6                	add	s1,s1,s5
    if(n > len)
    80000c44:	fc99f2e3          	bgeu	s3,s1,80000c08 <copyin+0x28>
    80000c48:	84ce                	mv	s1,s3
    80000c4a:	bf7d                	j	80000c08 <copyin+0x28>
  }
  return 0;
    80000c4c:	4501                	li	a0,0
    80000c4e:	a021                	j	80000c56 <copyin+0x76>
    80000c50:	4501                	li	a0,0
}
    80000c52:	8082                	ret
      return -1;
    80000c54:	557d                	li	a0,-1
}
    80000c56:	60a6                	ld	ra,72(sp)
    80000c58:	6406                	ld	s0,64(sp)
    80000c5a:	74e2                	ld	s1,56(sp)
    80000c5c:	7942                	ld	s2,48(sp)
    80000c5e:	79a2                	ld	s3,40(sp)
    80000c60:	7a02                	ld	s4,32(sp)
    80000c62:	6ae2                	ld	s5,24(sp)
    80000c64:	6b42                	ld	s6,16(sp)
    80000c66:	6ba2                	ld	s7,8(sp)
    80000c68:	6c02                	ld	s8,0(sp)
    80000c6a:	6161                	addi	sp,sp,80
    80000c6c:	8082                	ret

0000000080000c6e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000c6e:	c6c5                	beqz	a3,80000d16 <copyinstr+0xa8>
{
    80000c70:	715d                	addi	sp,sp,-80
    80000c72:	e486                	sd	ra,72(sp)
    80000c74:	e0a2                	sd	s0,64(sp)
    80000c76:	fc26                	sd	s1,56(sp)
    80000c78:	f84a                	sd	s2,48(sp)
    80000c7a:	f44e                	sd	s3,40(sp)
    80000c7c:	f052                	sd	s4,32(sp)
    80000c7e:	ec56                	sd	s5,24(sp)
    80000c80:	e85a                	sd	s6,16(sp)
    80000c82:	e45e                	sd	s7,8(sp)
    80000c84:	0880                	addi	s0,sp,80
    80000c86:	8a2a                	mv	s4,a0
    80000c88:	8b2e                	mv	s6,a1
    80000c8a:	8bb2                	mv	s7,a2
    80000c8c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000c8e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000c90:	6985                	lui	s3,0x1
    80000c92:	a035                	j	80000cbe <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000c94:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000c98:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000c9a:	0017b793          	seqz	a5,a5
    80000c9e:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000ca2:	60a6                	ld	ra,72(sp)
    80000ca4:	6406                	ld	s0,64(sp)
    80000ca6:	74e2                	ld	s1,56(sp)
    80000ca8:	7942                	ld	s2,48(sp)
    80000caa:	79a2                	ld	s3,40(sp)
    80000cac:	7a02                	ld	s4,32(sp)
    80000cae:	6ae2                	ld	s5,24(sp)
    80000cb0:	6b42                	ld	s6,16(sp)
    80000cb2:	6ba2                	ld	s7,8(sp)
    80000cb4:	6161                	addi	sp,sp,80
    80000cb6:	8082                	ret
    srcva = va0 + PGSIZE;
    80000cb8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000cbc:	c8a9                	beqz	s1,80000d0e <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80000cbe:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000cc2:	85ca                	mv	a1,s2
    80000cc4:	8552                	mv	a0,s4
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	858080e7          	jalr	-1960(ra) # 8000051e <walkaddr>
    if(pa0 == 0)
    80000cce:	c131                	beqz	a0,80000d12 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80000cd0:	41790833          	sub	a6,s2,s7
    80000cd4:	984e                	add	a6,a6,s3
    if(n > max)
    80000cd6:	0104f363          	bgeu	s1,a6,80000cdc <copyinstr+0x6e>
    80000cda:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80000cdc:	955e                	add	a0,a0,s7
    80000cde:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000ce2:	fc080be3          	beqz	a6,80000cb8 <copyinstr+0x4a>
    80000ce6:	985a                	add	a6,a6,s6
    80000ce8:	87da                	mv	a5,s6
      if(*p == '\0'){
    80000cea:	41650633          	sub	a2,a0,s6
    80000cee:	14fd                	addi	s1,s1,-1
    80000cf0:	9b26                	add	s6,s6,s1
    80000cf2:	00f60733          	add	a4,a2,a5
    80000cf6:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd7a70>
    80000cfa:	df49                	beqz	a4,80000c94 <copyinstr+0x26>
        *dst = *p;
    80000cfc:	00e78023          	sb	a4,0(a5)
      --max;
    80000d00:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80000d04:	0785                	addi	a5,a5,1
    while(n > 0){
    80000d06:	ff0796e3          	bne	a5,a6,80000cf2 <copyinstr+0x84>
      dst++;
    80000d0a:	8b42                	mv	s6,a6
    80000d0c:	b775                	j	80000cb8 <copyinstr+0x4a>
    80000d0e:	4781                	li	a5,0
    80000d10:	b769                	j	80000c9a <copyinstr+0x2c>
      return -1;
    80000d12:	557d                	li	a0,-1
    80000d14:	b779                	j	80000ca2 <copyinstr+0x34>
  int got_null = 0;
    80000d16:	4781                	li	a5,0
  if(got_null){
    80000d18:	0017b793          	seqz	a5,a5
    80000d1c:	40f00533          	neg	a0,a5
}
    80000d20:	8082                	ret

0000000080000d22 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80000d22:	1101                	addi	sp,sp,-32
    80000d24:	ec06                	sd	ra,24(sp)
    80000d26:	e822                	sd	s0,16(sp)
    80000d28:	e426                	sd	s1,8(sp)
    80000d2a:	1000                	addi	s0,sp,32
    80000d2c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80000d2e:	00006097          	auipc	ra,0x6
    80000d32:	3c8080e7          	jalr	968(ra) # 800070f6 <holding>
    80000d36:	c909                	beqz	a0,80000d48 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80000d38:	749c                	ld	a5,40(s1)
    80000d3a:	00978f63          	beq	a5,s1,80000d58 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80000d3e:	60e2                	ld	ra,24(sp)
    80000d40:	6442                	ld	s0,16(sp)
    80000d42:	64a2                	ld	s1,8(sp)
    80000d44:	6105                	addi	sp,sp,32
    80000d46:	8082                	ret
    panic("wakeup1");
    80000d48:	00008517          	auipc	a0,0x8
    80000d4c:	40850513          	addi	a0,a0,1032 # 80009150 <etext+0x150>
    80000d50:	00006097          	auipc	ra,0x6
    80000d54:	ee4080e7          	jalr	-284(ra) # 80006c34 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80000d58:	4c98                	lw	a4,24(s1)
    80000d5a:	4785                	li	a5,1
    80000d5c:	fef711e3          	bne	a4,a5,80000d3e <wakeup1+0x1c>
    p->state = RUNNABLE;
    80000d60:	4789                	li	a5,2
    80000d62:	cc9c                	sw	a5,24(s1)
}
    80000d64:	bfe9                	j	80000d3e <wakeup1+0x1c>

0000000080000d66 <proc_mapstacks>:
proc_mapstacks(pagetable_t kpgtbl) {
    80000d66:	7139                	addi	sp,sp,-64
    80000d68:	fc06                	sd	ra,56(sp)
    80000d6a:	f822                	sd	s0,48(sp)
    80000d6c:	f426                	sd	s1,40(sp)
    80000d6e:	f04a                	sd	s2,32(sp)
    80000d70:	ec4e                	sd	s3,24(sp)
    80000d72:	e852                	sd	s4,16(sp)
    80000d74:	e456                	sd	s5,8(sp)
    80000d76:	e05a                	sd	s6,0(sp)
    80000d78:	0080                	addi	s0,sp,64
    80000d7a:	89aa                	mv	s3,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d7c:	00009497          	auipc	s1,0x9
    80000d80:	70c48493          	addi	s1,s1,1804 # 8000a488 <proc>
    uint64 va = KSTACK((int) (p - proc));
    80000d84:	8b26                	mv	s6,s1
    80000d86:	00008a97          	auipc	s5,0x8
    80000d8a:	27aa8a93          	addi	s5,s5,634 # 80009000 <etext>
    80000d8e:	04000937          	lui	s2,0x4000
    80000d92:	197d                	addi	s2,s2,-1
    80000d94:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d96:	0000fa17          	auipc	s4,0xf
    80000d9a:	0f2a0a13          	addi	s4,s4,242 # 8000fe88 <tickslock>
    char *pa = kalloc();
    80000d9e:	fffff097          	auipc	ra,0xfffff
    80000da2:	37a080e7          	jalr	890(ra) # 80000118 <kalloc>
    80000da6:	862a                	mv	a2,a0
    if(pa == 0)
    80000da8:	c131                	beqz	a0,80000dec <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80000daa:	416485b3          	sub	a1,s1,s6
    80000dae:	858d                	srai	a1,a1,0x3
    80000db0:	000ab783          	ld	a5,0(s5)
    80000db4:	02f585b3          	mul	a1,a1,a5
    80000db8:	2585                	addiw	a1,a1,1
    80000dba:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000dbe:	4719                	li	a4,6
    80000dc0:	6685                	lui	a3,0x1
    80000dc2:	40b905b3          	sub	a1,s2,a1
    80000dc6:	854e                	mv	a0,s3
    80000dc8:	00000097          	auipc	ra,0x0
    80000dcc:	826080e7          	jalr	-2010(ra) # 800005ee <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000dd0:	16848493          	addi	s1,s1,360
    80000dd4:	fd4495e3          	bne	s1,s4,80000d9e <proc_mapstacks+0x38>
}
    80000dd8:	70e2                	ld	ra,56(sp)
    80000dda:	7442                	ld	s0,48(sp)
    80000ddc:	74a2                	ld	s1,40(sp)
    80000dde:	7902                	ld	s2,32(sp)
    80000de0:	69e2                	ld	s3,24(sp)
    80000de2:	6a42                	ld	s4,16(sp)
    80000de4:	6aa2                	ld	s5,8(sp)
    80000de6:	6b02                	ld	s6,0(sp)
    80000de8:	6121                	addi	sp,sp,64
    80000dea:	8082                	ret
      panic("kalloc");
    80000dec:	00008517          	auipc	a0,0x8
    80000df0:	36c50513          	addi	a0,a0,876 # 80009158 <etext+0x158>
    80000df4:	00006097          	auipc	ra,0x6
    80000df8:	e40080e7          	jalr	-448(ra) # 80006c34 <panic>

0000000080000dfc <procinit>:
{
    80000dfc:	7139                	addi	sp,sp,-64
    80000dfe:	fc06                	sd	ra,56(sp)
    80000e00:	f822                	sd	s0,48(sp)
    80000e02:	f426                	sd	s1,40(sp)
    80000e04:	f04a                	sd	s2,32(sp)
    80000e06:	ec4e                	sd	s3,24(sp)
    80000e08:	e852                	sd	s4,16(sp)
    80000e0a:	e456                	sd	s5,8(sp)
    80000e0c:	e05a                	sd	s6,0(sp)
    80000e0e:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    80000e10:	00008597          	auipc	a1,0x8
    80000e14:	35058593          	addi	a1,a1,848 # 80009160 <etext+0x160>
    80000e18:	00009517          	auipc	a0,0x9
    80000e1c:	25850513          	addi	a0,a0,600 # 8000a070 <pid_lock>
    80000e20:	00006097          	auipc	ra,0x6
    80000e24:	2c0080e7          	jalr	704(ra) # 800070e0 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e28:	00009497          	auipc	s1,0x9
    80000e2c:	66048493          	addi	s1,s1,1632 # 8000a488 <proc>
      initlock(&p->lock, "proc");
    80000e30:	00008b17          	auipc	s6,0x8
    80000e34:	338b0b13          	addi	s6,s6,824 # 80009168 <etext+0x168>
      p->kstack = KSTACK((int) (p - proc));
    80000e38:	8aa6                	mv	s5,s1
    80000e3a:	00008a17          	auipc	s4,0x8
    80000e3e:	1c6a0a13          	addi	s4,s4,454 # 80009000 <etext>
    80000e42:	04000937          	lui	s2,0x4000
    80000e46:	197d                	addi	s2,s2,-1
    80000e48:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e4a:	0000f997          	auipc	s3,0xf
    80000e4e:	03e98993          	addi	s3,s3,62 # 8000fe88 <tickslock>
      initlock(&p->lock, "proc");
    80000e52:	85da                	mv	a1,s6
    80000e54:	8526                	mv	a0,s1
    80000e56:	00006097          	auipc	ra,0x6
    80000e5a:	28a080e7          	jalr	650(ra) # 800070e0 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80000e5e:	415487b3          	sub	a5,s1,s5
    80000e62:	878d                	srai	a5,a5,0x3
    80000e64:	000a3703          	ld	a4,0(s4)
    80000e68:	02e787b3          	mul	a5,a5,a4
    80000e6c:	2785                	addiw	a5,a5,1
    80000e6e:	00d7979b          	slliw	a5,a5,0xd
    80000e72:	40f907b3          	sub	a5,s2,a5
    80000e76:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e78:	16848493          	addi	s1,s1,360
    80000e7c:	fd349be3          	bne	s1,s3,80000e52 <procinit+0x56>
}
    80000e80:	70e2                	ld	ra,56(sp)
    80000e82:	7442                	ld	s0,48(sp)
    80000e84:	74a2                	ld	s1,40(sp)
    80000e86:	7902                	ld	s2,32(sp)
    80000e88:	69e2                	ld	s3,24(sp)
    80000e8a:	6a42                	ld	s4,16(sp)
    80000e8c:	6aa2                	ld	s5,8(sp)
    80000e8e:	6b02                	ld	s6,0(sp)
    80000e90:	6121                	addi	sp,sp,64
    80000e92:	8082                	ret

0000000080000e94 <cpuid>:
{
    80000e94:	1141                	addi	sp,sp,-16
    80000e96:	e422                	sd	s0,8(sp)
    80000e98:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000e9a:	8512                	mv	a0,tp
}
    80000e9c:	2501                	sext.w	a0,a0
    80000e9e:	6422                	ld	s0,8(sp)
    80000ea0:	0141                	addi	sp,sp,16
    80000ea2:	8082                	ret

0000000080000ea4 <mycpu>:
mycpu(void) {
    80000ea4:	1141                	addi	sp,sp,-16
    80000ea6:	e422                	sd	s0,8(sp)
    80000ea8:	0800                	addi	s0,sp,16
    80000eaa:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80000eac:	2781                	sext.w	a5,a5
    80000eae:	079e                	slli	a5,a5,0x7
}
    80000eb0:	00009517          	auipc	a0,0x9
    80000eb4:	1d850513          	addi	a0,a0,472 # 8000a088 <cpus>
    80000eb8:	953e                	add	a0,a0,a5
    80000eba:	6422                	ld	s0,8(sp)
    80000ebc:	0141                	addi	sp,sp,16
    80000ebe:	8082                	ret

0000000080000ec0 <myproc>:
myproc(void) {
    80000ec0:	1101                	addi	sp,sp,-32
    80000ec2:	ec06                	sd	ra,24(sp)
    80000ec4:	e822                	sd	s0,16(sp)
    80000ec6:	e426                	sd	s1,8(sp)
    80000ec8:	1000                	addi	s0,sp,32
  push_off();
    80000eca:	00006097          	auipc	ra,0x6
    80000ece:	25a080e7          	jalr	602(ra) # 80007124 <push_off>
    80000ed2:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80000ed4:	2781                	sext.w	a5,a5
    80000ed6:	079e                	slli	a5,a5,0x7
    80000ed8:	00009717          	auipc	a4,0x9
    80000edc:	19870713          	addi	a4,a4,408 # 8000a070 <pid_lock>
    80000ee0:	97ba                	add	a5,a5,a4
    80000ee2:	6f84                	ld	s1,24(a5)
  pop_off();
    80000ee4:	00006097          	auipc	ra,0x6
    80000ee8:	2e0080e7          	jalr	736(ra) # 800071c4 <pop_off>
}
    80000eec:	8526                	mv	a0,s1
    80000eee:	60e2                	ld	ra,24(sp)
    80000ef0:	6442                	ld	s0,16(sp)
    80000ef2:	64a2                	ld	s1,8(sp)
    80000ef4:	6105                	addi	sp,sp,32
    80000ef6:	8082                	ret

0000000080000ef8 <forkret>:
{
    80000ef8:	1141                	addi	sp,sp,-16
    80000efa:	e406                	sd	ra,8(sp)
    80000efc:	e022                	sd	s0,0(sp)
    80000efe:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80000f00:	00000097          	auipc	ra,0x0
    80000f04:	fc0080e7          	jalr	-64(ra) # 80000ec0 <myproc>
    80000f08:	00006097          	auipc	ra,0x6
    80000f0c:	31c080e7          	jalr	796(ra) # 80007224 <release>
  if (first) {
    80000f10:	00009797          	auipc	a5,0x9
    80000f14:	9707a783          	lw	a5,-1680(a5) # 80009880 <first.1>
    80000f18:	eb89                	bnez	a5,80000f2a <forkret+0x32>
  usertrapret();
    80000f1a:	00001097          	auipc	ra,0x1
    80000f1e:	c18080e7          	jalr	-1000(ra) # 80001b32 <usertrapret>
}
    80000f22:	60a2                	ld	ra,8(sp)
    80000f24:	6402                	ld	s0,0(sp)
    80000f26:	0141                	addi	sp,sp,16
    80000f28:	8082                	ret
    first = 0;
    80000f2a:	00009797          	auipc	a5,0x9
    80000f2e:	9407ab23          	sw	zero,-1706(a5) # 80009880 <first.1>
    fsinit(ROOTDEV);
    80000f32:	4505                	li	a0,1
    80000f34:	00002097          	auipc	ra,0x2
    80000f38:	96e080e7          	jalr	-1682(ra) # 800028a2 <fsinit>
    80000f3c:	bff9                	j	80000f1a <forkret+0x22>

0000000080000f3e <allocpid>:
allocpid() {
    80000f3e:	1101                	addi	sp,sp,-32
    80000f40:	ec06                	sd	ra,24(sp)
    80000f42:	e822                	sd	s0,16(sp)
    80000f44:	e426                	sd	s1,8(sp)
    80000f46:	e04a                	sd	s2,0(sp)
    80000f48:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000f4a:	00009917          	auipc	s2,0x9
    80000f4e:	12690913          	addi	s2,s2,294 # 8000a070 <pid_lock>
    80000f52:	854a                	mv	a0,s2
    80000f54:	00006097          	auipc	ra,0x6
    80000f58:	21c080e7          	jalr	540(ra) # 80007170 <acquire>
  pid = nextpid;
    80000f5c:	00009797          	auipc	a5,0x9
    80000f60:	92878793          	addi	a5,a5,-1752 # 80009884 <nextpid>
    80000f64:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000f66:	0014871b          	addiw	a4,s1,1
    80000f6a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000f6c:	854a                	mv	a0,s2
    80000f6e:	00006097          	auipc	ra,0x6
    80000f72:	2b6080e7          	jalr	694(ra) # 80007224 <release>
}
    80000f76:	8526                	mv	a0,s1
    80000f78:	60e2                	ld	ra,24(sp)
    80000f7a:	6442                	ld	s0,16(sp)
    80000f7c:	64a2                	ld	s1,8(sp)
    80000f7e:	6902                	ld	s2,0(sp)
    80000f80:	6105                	addi	sp,sp,32
    80000f82:	8082                	ret

0000000080000f84 <proc_pagetable>:
{
    80000f84:	1101                	addi	sp,sp,-32
    80000f86:	ec06                	sd	ra,24(sp)
    80000f88:	e822                	sd	s0,16(sp)
    80000f8a:	e426                	sd	s1,8(sp)
    80000f8c:	e04a                	sd	s2,0(sp)
    80000f8e:	1000                	addi	s0,sp,32
    80000f90:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000f92:	00000097          	auipc	ra,0x0
    80000f96:	88a080e7          	jalr	-1910(ra) # 8000081c <uvmcreate>
    80000f9a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000f9c:	c121                	beqz	a0,80000fdc <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000f9e:	4729                	li	a4,10
    80000fa0:	00007697          	auipc	a3,0x7
    80000fa4:	06068693          	addi	a3,a3,96 # 80008000 <_trampoline>
    80000fa8:	6605                	lui	a2,0x1
    80000faa:	040005b7          	lui	a1,0x4000
    80000fae:	15fd                	addi	a1,a1,-1
    80000fb0:	05b2                	slli	a1,a1,0xc
    80000fb2:	fffff097          	auipc	ra,0xfffff
    80000fb6:	5ae080e7          	jalr	1454(ra) # 80000560 <mappages>
    80000fba:	02054863          	bltz	a0,80000fea <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000fbe:	4719                	li	a4,6
    80000fc0:	05893683          	ld	a3,88(s2)
    80000fc4:	6605                	lui	a2,0x1
    80000fc6:	020005b7          	lui	a1,0x2000
    80000fca:	15fd                	addi	a1,a1,-1
    80000fcc:	05b6                	slli	a1,a1,0xd
    80000fce:	8526                	mv	a0,s1
    80000fd0:	fffff097          	auipc	ra,0xfffff
    80000fd4:	590080e7          	jalr	1424(ra) # 80000560 <mappages>
    80000fd8:	02054163          	bltz	a0,80000ffa <proc_pagetable+0x76>
}
    80000fdc:	8526                	mv	a0,s1
    80000fde:	60e2                	ld	ra,24(sp)
    80000fe0:	6442                	ld	s0,16(sp)
    80000fe2:	64a2                	ld	s1,8(sp)
    80000fe4:	6902                	ld	s2,0(sp)
    80000fe6:	6105                	addi	sp,sp,32
    80000fe8:	8082                	ret
    uvmfree(pagetable, 0);
    80000fea:	4581                	li	a1,0
    80000fec:	8526                	mv	a0,s1
    80000fee:	00000097          	auipc	ra,0x0
    80000ff2:	a2a080e7          	jalr	-1494(ra) # 80000a18 <uvmfree>
    return 0;
    80000ff6:	4481                	li	s1,0
    80000ff8:	b7d5                	j	80000fdc <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000ffa:	4681                	li	a3,0
    80000ffc:	4605                	li	a2,1
    80000ffe:	040005b7          	lui	a1,0x4000
    80001002:	15fd                	addi	a1,a1,-1
    80001004:	05b2                	slli	a1,a1,0xc
    80001006:	8526                	mv	a0,s1
    80001008:	fffff097          	auipc	ra,0xfffff
    8000100c:	73c080e7          	jalr	1852(ra) # 80000744 <uvmunmap>
    uvmfree(pagetable, 0);
    80001010:	4581                	li	a1,0
    80001012:	8526                	mv	a0,s1
    80001014:	00000097          	auipc	ra,0x0
    80001018:	a04080e7          	jalr	-1532(ra) # 80000a18 <uvmfree>
    return 0;
    8000101c:	4481                	li	s1,0
    8000101e:	bf7d                	j	80000fdc <proc_pagetable+0x58>

0000000080001020 <proc_freepagetable>:
{
    80001020:	1101                	addi	sp,sp,-32
    80001022:	ec06                	sd	ra,24(sp)
    80001024:	e822                	sd	s0,16(sp)
    80001026:	e426                	sd	s1,8(sp)
    80001028:	e04a                	sd	s2,0(sp)
    8000102a:	1000                	addi	s0,sp,32
    8000102c:	84aa                	mv	s1,a0
    8000102e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001030:	4681                	li	a3,0
    80001032:	4605                	li	a2,1
    80001034:	040005b7          	lui	a1,0x4000
    80001038:	15fd                	addi	a1,a1,-1
    8000103a:	05b2                	slli	a1,a1,0xc
    8000103c:	fffff097          	auipc	ra,0xfffff
    80001040:	708080e7          	jalr	1800(ra) # 80000744 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001044:	4681                	li	a3,0
    80001046:	4605                	li	a2,1
    80001048:	020005b7          	lui	a1,0x2000
    8000104c:	15fd                	addi	a1,a1,-1
    8000104e:	05b6                	slli	a1,a1,0xd
    80001050:	8526                	mv	a0,s1
    80001052:	fffff097          	auipc	ra,0xfffff
    80001056:	6f2080e7          	jalr	1778(ra) # 80000744 <uvmunmap>
  uvmfree(pagetable, sz);
    8000105a:	85ca                	mv	a1,s2
    8000105c:	8526                	mv	a0,s1
    8000105e:	00000097          	auipc	ra,0x0
    80001062:	9ba080e7          	jalr	-1606(ra) # 80000a18 <uvmfree>
}
    80001066:	60e2                	ld	ra,24(sp)
    80001068:	6442                	ld	s0,16(sp)
    8000106a:	64a2                	ld	s1,8(sp)
    8000106c:	6902                	ld	s2,0(sp)
    8000106e:	6105                	addi	sp,sp,32
    80001070:	8082                	ret

0000000080001072 <freeproc>:
{
    80001072:	1101                	addi	sp,sp,-32
    80001074:	ec06                	sd	ra,24(sp)
    80001076:	e822                	sd	s0,16(sp)
    80001078:	e426                	sd	s1,8(sp)
    8000107a:	1000                	addi	s0,sp,32
    8000107c:	84aa                	mv	s1,a0
  if(p->trapframe)
    8000107e:	6d28                	ld	a0,88(a0)
    80001080:	c509                	beqz	a0,8000108a <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001082:	fffff097          	auipc	ra,0xfffff
    80001086:	f9a080e7          	jalr	-102(ra) # 8000001c <kfree>
  p->trapframe = 0;
    8000108a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    8000108e:	68a8                	ld	a0,80(s1)
    80001090:	c511                	beqz	a0,8000109c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001092:	64ac                	ld	a1,72(s1)
    80001094:	00000097          	auipc	ra,0x0
    80001098:	f8c080e7          	jalr	-116(ra) # 80001020 <proc_freepagetable>
  p->pagetable = 0;
    8000109c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800010a0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800010a4:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    800010a8:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    800010ac:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800010b0:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    800010b4:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    800010b8:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    800010bc:	0004ac23          	sw	zero,24(s1)
}
    800010c0:	60e2                	ld	ra,24(sp)
    800010c2:	6442                	ld	s0,16(sp)
    800010c4:	64a2                	ld	s1,8(sp)
    800010c6:	6105                	addi	sp,sp,32
    800010c8:	8082                	ret

00000000800010ca <allocproc>:
{
    800010ca:	1101                	addi	sp,sp,-32
    800010cc:	ec06                	sd	ra,24(sp)
    800010ce:	e822                	sd	s0,16(sp)
    800010d0:	e426                	sd	s1,8(sp)
    800010d2:	e04a                	sd	s2,0(sp)
    800010d4:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    800010d6:	00009497          	auipc	s1,0x9
    800010da:	3b248493          	addi	s1,s1,946 # 8000a488 <proc>
    800010de:	0000f917          	auipc	s2,0xf
    800010e2:	daa90913          	addi	s2,s2,-598 # 8000fe88 <tickslock>
    acquire(&p->lock);
    800010e6:	8526                	mv	a0,s1
    800010e8:	00006097          	auipc	ra,0x6
    800010ec:	088080e7          	jalr	136(ra) # 80007170 <acquire>
    if(p->state == UNUSED) {
    800010f0:	4c9c                	lw	a5,24(s1)
    800010f2:	cf81                	beqz	a5,8000110a <allocproc+0x40>
      release(&p->lock);
    800010f4:	8526                	mv	a0,s1
    800010f6:	00006097          	auipc	ra,0x6
    800010fa:	12e080e7          	jalr	302(ra) # 80007224 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800010fe:	16848493          	addi	s1,s1,360
    80001102:	ff2492e3          	bne	s1,s2,800010e6 <allocproc+0x1c>
  return 0;
    80001106:	4481                	li	s1,0
    80001108:	a0b9                	j	80001156 <allocproc+0x8c>
  p->pid = allocpid();
    8000110a:	00000097          	auipc	ra,0x0
    8000110e:	e34080e7          	jalr	-460(ra) # 80000f3e <allocpid>
    80001112:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	004080e7          	jalr	4(ra) # 80000118 <kalloc>
    8000111c:	892a                	mv	s2,a0
    8000111e:	eca8                	sd	a0,88(s1)
    80001120:	c131                	beqz	a0,80001164 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001122:	8526                	mv	a0,s1
    80001124:	00000097          	auipc	ra,0x0
    80001128:	e60080e7          	jalr	-416(ra) # 80000f84 <proc_pagetable>
    8000112c:	892a                	mv	s2,a0
    8000112e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001130:	c129                	beqz	a0,80001172 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001132:	07000613          	li	a2,112
    80001136:	4581                	li	a1,0
    80001138:	06048513          	addi	a0,s1,96
    8000113c:	fffff097          	auipc	ra,0xfffff
    80001140:	03c080e7          	jalr	60(ra) # 80000178 <memset>
  p->context.ra = (uint64)forkret;
    80001144:	00000797          	auipc	a5,0x0
    80001148:	db478793          	addi	a5,a5,-588 # 80000ef8 <forkret>
    8000114c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    8000114e:	60bc                	ld	a5,64(s1)
    80001150:	6705                	lui	a4,0x1
    80001152:	97ba                	add	a5,a5,a4
    80001154:	f4bc                	sd	a5,104(s1)
}
    80001156:	8526                	mv	a0,s1
    80001158:	60e2                	ld	ra,24(sp)
    8000115a:	6442                	ld	s0,16(sp)
    8000115c:	64a2                	ld	s1,8(sp)
    8000115e:	6902                	ld	s2,0(sp)
    80001160:	6105                	addi	sp,sp,32
    80001162:	8082                	ret
    release(&p->lock);
    80001164:	8526                	mv	a0,s1
    80001166:	00006097          	auipc	ra,0x6
    8000116a:	0be080e7          	jalr	190(ra) # 80007224 <release>
    return 0;
    8000116e:	84ca                	mv	s1,s2
    80001170:	b7dd                	j	80001156 <allocproc+0x8c>
    freeproc(p);
    80001172:	8526                	mv	a0,s1
    80001174:	00000097          	auipc	ra,0x0
    80001178:	efe080e7          	jalr	-258(ra) # 80001072 <freeproc>
    release(&p->lock);
    8000117c:	8526                	mv	a0,s1
    8000117e:	00006097          	auipc	ra,0x6
    80001182:	0a6080e7          	jalr	166(ra) # 80007224 <release>
    return 0;
    80001186:	84ca                	mv	s1,s2
    80001188:	b7f9                	j	80001156 <allocproc+0x8c>

000000008000118a <userinit>:
{
    8000118a:	1101                	addi	sp,sp,-32
    8000118c:	ec06                	sd	ra,24(sp)
    8000118e:	e822                	sd	s0,16(sp)
    80001190:	e426                	sd	s1,8(sp)
    80001192:	1000                	addi	s0,sp,32
  p = allocproc();
    80001194:	00000097          	auipc	ra,0x0
    80001198:	f36080e7          	jalr	-202(ra) # 800010ca <allocproc>
    8000119c:	84aa                	mv	s1,a0
  initproc = p;
    8000119e:	00009797          	auipc	a5,0x9
    800011a2:	e6a7b923          	sd	a0,-398(a5) # 8000a010 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    800011a6:	03400613          	li	a2,52
    800011aa:	00008597          	auipc	a1,0x8
    800011ae:	6f658593          	addi	a1,a1,1782 # 800098a0 <initcode>
    800011b2:	6928                	ld	a0,80(a0)
    800011b4:	fffff097          	auipc	ra,0xfffff
    800011b8:	696080e7          	jalr	1686(ra) # 8000084a <uvminit>
  p->sz = PGSIZE;
    800011bc:	6785                	lui	a5,0x1
    800011be:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800011c0:	6cb8                	ld	a4,88(s1)
    800011c2:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800011c6:	6cb8                	ld	a4,88(s1)
    800011c8:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800011ca:	4641                	li	a2,16
    800011cc:	00008597          	auipc	a1,0x8
    800011d0:	fa458593          	addi	a1,a1,-92 # 80009170 <etext+0x170>
    800011d4:	15848513          	addi	a0,s1,344
    800011d8:	fffff097          	auipc	ra,0xfffff
    800011dc:	0f2080e7          	jalr	242(ra) # 800002ca <safestrcpy>
  p->cwd = namei("/");
    800011e0:	00008517          	auipc	a0,0x8
    800011e4:	fa050513          	addi	a0,a0,-96 # 80009180 <etext+0x180>
    800011e8:	00002097          	auipc	ra,0x2
    800011ec:	0e8080e7          	jalr	232(ra) # 800032d0 <namei>
    800011f0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800011f4:	4789                	li	a5,2
    800011f6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800011f8:	8526                	mv	a0,s1
    800011fa:	00006097          	auipc	ra,0x6
    800011fe:	02a080e7          	jalr	42(ra) # 80007224 <release>
}
    80001202:	60e2                	ld	ra,24(sp)
    80001204:	6442                	ld	s0,16(sp)
    80001206:	64a2                	ld	s1,8(sp)
    80001208:	6105                	addi	sp,sp,32
    8000120a:	8082                	ret

000000008000120c <growproc>:
{
    8000120c:	1101                	addi	sp,sp,-32
    8000120e:	ec06                	sd	ra,24(sp)
    80001210:	e822                	sd	s0,16(sp)
    80001212:	e426                	sd	s1,8(sp)
    80001214:	e04a                	sd	s2,0(sp)
    80001216:	1000                	addi	s0,sp,32
    80001218:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000121a:	00000097          	auipc	ra,0x0
    8000121e:	ca6080e7          	jalr	-858(ra) # 80000ec0 <myproc>
    80001222:	892a                	mv	s2,a0
  sz = p->sz;
    80001224:	652c                	ld	a1,72(a0)
    80001226:	0005861b          	sext.w	a2,a1
  if(n > 0){
    8000122a:	00904f63          	bgtz	s1,80001248 <growproc+0x3c>
  } else if(n < 0){
    8000122e:	0204cc63          	bltz	s1,80001266 <growproc+0x5a>
  p->sz = sz;
    80001232:	1602                	slli	a2,a2,0x20
    80001234:	9201                	srli	a2,a2,0x20
    80001236:	04c93423          	sd	a2,72(s2)
  return 0;
    8000123a:	4501                	li	a0,0
}
    8000123c:	60e2                	ld	ra,24(sp)
    8000123e:	6442                	ld	s0,16(sp)
    80001240:	64a2                	ld	s1,8(sp)
    80001242:	6902                	ld	s2,0(sp)
    80001244:	6105                	addi	sp,sp,32
    80001246:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001248:	9e25                	addw	a2,a2,s1
    8000124a:	1602                	slli	a2,a2,0x20
    8000124c:	9201                	srli	a2,a2,0x20
    8000124e:	1582                	slli	a1,a1,0x20
    80001250:	9181                	srli	a1,a1,0x20
    80001252:	6928                	ld	a0,80(a0)
    80001254:	fffff097          	auipc	ra,0xfffff
    80001258:	6b0080e7          	jalr	1712(ra) # 80000904 <uvmalloc>
    8000125c:	0005061b          	sext.w	a2,a0
    80001260:	fa69                	bnez	a2,80001232 <growproc+0x26>
      return -1;
    80001262:	557d                	li	a0,-1
    80001264:	bfe1                	j	8000123c <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001266:	9e25                	addw	a2,a2,s1
    80001268:	1602                	slli	a2,a2,0x20
    8000126a:	9201                	srli	a2,a2,0x20
    8000126c:	1582                	slli	a1,a1,0x20
    8000126e:	9181                	srli	a1,a1,0x20
    80001270:	6928                	ld	a0,80(a0)
    80001272:	fffff097          	auipc	ra,0xfffff
    80001276:	64a080e7          	jalr	1610(ra) # 800008bc <uvmdealloc>
    8000127a:	0005061b          	sext.w	a2,a0
    8000127e:	bf55                	j	80001232 <growproc+0x26>

0000000080001280 <fork>:
{
    80001280:	7139                	addi	sp,sp,-64
    80001282:	fc06                	sd	ra,56(sp)
    80001284:	f822                	sd	s0,48(sp)
    80001286:	f426                	sd	s1,40(sp)
    80001288:	f04a                	sd	s2,32(sp)
    8000128a:	ec4e                	sd	s3,24(sp)
    8000128c:	e852                	sd	s4,16(sp)
    8000128e:	e456                	sd	s5,8(sp)
    80001290:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001292:	00000097          	auipc	ra,0x0
    80001296:	c2e080e7          	jalr	-978(ra) # 80000ec0 <myproc>
    8000129a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	e2e080e7          	jalr	-466(ra) # 800010ca <allocproc>
    800012a4:	c17d                	beqz	a0,8000138a <fork+0x10a>
    800012a6:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800012a8:	048ab603          	ld	a2,72(s5)
    800012ac:	692c                	ld	a1,80(a0)
    800012ae:	050ab503          	ld	a0,80(s5)
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	79e080e7          	jalr	1950(ra) # 80000a50 <uvmcopy>
    800012ba:	04054a63          	bltz	a0,8000130e <fork+0x8e>
  np->sz = p->sz;
    800012be:	048ab783          	ld	a5,72(s5)
    800012c2:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    800012c6:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    800012ca:	058ab683          	ld	a3,88(s5)
    800012ce:	87b6                	mv	a5,a3
    800012d0:	058a3703          	ld	a4,88(s4)
    800012d4:	12068693          	addi	a3,a3,288
    800012d8:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800012dc:	6788                	ld	a0,8(a5)
    800012de:	6b8c                	ld	a1,16(a5)
    800012e0:	6f90                	ld	a2,24(a5)
    800012e2:	01073023          	sd	a6,0(a4)
    800012e6:	e708                	sd	a0,8(a4)
    800012e8:	eb0c                	sd	a1,16(a4)
    800012ea:	ef10                	sd	a2,24(a4)
    800012ec:	02078793          	addi	a5,a5,32
    800012f0:	02070713          	addi	a4,a4,32
    800012f4:	fed792e3          	bne	a5,a3,800012d8 <fork+0x58>
  np->trapframe->a0 = 0;
    800012f8:	058a3783          	ld	a5,88(s4)
    800012fc:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001300:	0d0a8493          	addi	s1,s5,208
    80001304:	0d0a0913          	addi	s2,s4,208
    80001308:	150a8993          	addi	s3,s5,336
    8000130c:	a00d                	j	8000132e <fork+0xae>
    freeproc(np);
    8000130e:	8552                	mv	a0,s4
    80001310:	00000097          	auipc	ra,0x0
    80001314:	d62080e7          	jalr	-670(ra) # 80001072 <freeproc>
    release(&np->lock);
    80001318:	8552                	mv	a0,s4
    8000131a:	00006097          	auipc	ra,0x6
    8000131e:	f0a080e7          	jalr	-246(ra) # 80007224 <release>
    return -1;
    80001322:	54fd                	li	s1,-1
    80001324:	a889                	j	80001376 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001326:	04a1                	addi	s1,s1,8
    80001328:	0921                	addi	s2,s2,8
    8000132a:	01348b63          	beq	s1,s3,80001340 <fork+0xc0>
    if(p->ofile[i])
    8000132e:	6088                	ld	a0,0(s1)
    80001330:	d97d                	beqz	a0,80001326 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001332:	00002097          	auipc	ra,0x2
    80001336:	63c080e7          	jalr	1596(ra) # 8000396e <filedup>
    8000133a:	00a93023          	sd	a0,0(s2)
    8000133e:	b7e5                	j	80001326 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001340:	150ab503          	ld	a0,336(s5)
    80001344:	00001097          	auipc	ra,0x1
    80001348:	798080e7          	jalr	1944(ra) # 80002adc <idup>
    8000134c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001350:	4641                	li	a2,16
    80001352:	158a8593          	addi	a1,s5,344
    80001356:	158a0513          	addi	a0,s4,344
    8000135a:	fffff097          	auipc	ra,0xfffff
    8000135e:	f70080e7          	jalr	-144(ra) # 800002ca <safestrcpy>
  pid = np->pid;
    80001362:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001366:	4789                	li	a5,2
    80001368:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    8000136c:	8552                	mv	a0,s4
    8000136e:	00006097          	auipc	ra,0x6
    80001372:	eb6080e7          	jalr	-330(ra) # 80007224 <release>
}
    80001376:	8526                	mv	a0,s1
    80001378:	70e2                	ld	ra,56(sp)
    8000137a:	7442                	ld	s0,48(sp)
    8000137c:	74a2                	ld	s1,40(sp)
    8000137e:	7902                	ld	s2,32(sp)
    80001380:	69e2                	ld	s3,24(sp)
    80001382:	6a42                	ld	s4,16(sp)
    80001384:	6aa2                	ld	s5,8(sp)
    80001386:	6121                	addi	sp,sp,64
    80001388:	8082                	ret
    return -1;
    8000138a:	54fd                	li	s1,-1
    8000138c:	b7ed                	j	80001376 <fork+0xf6>

000000008000138e <reparent>:
{
    8000138e:	7179                	addi	sp,sp,-48
    80001390:	f406                	sd	ra,40(sp)
    80001392:	f022                	sd	s0,32(sp)
    80001394:	ec26                	sd	s1,24(sp)
    80001396:	e84a                	sd	s2,16(sp)
    80001398:	e44e                	sd	s3,8(sp)
    8000139a:	e052                	sd	s4,0(sp)
    8000139c:	1800                	addi	s0,sp,48
    8000139e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800013a0:	00009497          	auipc	s1,0x9
    800013a4:	0e848493          	addi	s1,s1,232 # 8000a488 <proc>
      pp->parent = initproc;
    800013a8:	00009a17          	auipc	s4,0x9
    800013ac:	c68a0a13          	addi	s4,s4,-920 # 8000a010 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800013b0:	0000f997          	auipc	s3,0xf
    800013b4:	ad898993          	addi	s3,s3,-1320 # 8000fe88 <tickslock>
    800013b8:	a029                	j	800013c2 <reparent+0x34>
    800013ba:	16848493          	addi	s1,s1,360
    800013be:	03348363          	beq	s1,s3,800013e4 <reparent+0x56>
    if(pp->parent == p){
    800013c2:	709c                	ld	a5,32(s1)
    800013c4:	ff279be3          	bne	a5,s2,800013ba <reparent+0x2c>
      acquire(&pp->lock);
    800013c8:	8526                	mv	a0,s1
    800013ca:	00006097          	auipc	ra,0x6
    800013ce:	da6080e7          	jalr	-602(ra) # 80007170 <acquire>
      pp->parent = initproc;
    800013d2:	000a3783          	ld	a5,0(s4)
    800013d6:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    800013d8:	8526                	mv	a0,s1
    800013da:	00006097          	auipc	ra,0x6
    800013de:	e4a080e7          	jalr	-438(ra) # 80007224 <release>
    800013e2:	bfe1                	j	800013ba <reparent+0x2c>
}
    800013e4:	70a2                	ld	ra,40(sp)
    800013e6:	7402                	ld	s0,32(sp)
    800013e8:	64e2                	ld	s1,24(sp)
    800013ea:	6942                	ld	s2,16(sp)
    800013ec:	69a2                	ld	s3,8(sp)
    800013ee:	6a02                	ld	s4,0(sp)
    800013f0:	6145                	addi	sp,sp,48
    800013f2:	8082                	ret

00000000800013f4 <scheduler>:
{
    800013f4:	711d                	addi	sp,sp,-96
    800013f6:	ec86                	sd	ra,88(sp)
    800013f8:	e8a2                	sd	s0,80(sp)
    800013fa:	e4a6                	sd	s1,72(sp)
    800013fc:	e0ca                	sd	s2,64(sp)
    800013fe:	fc4e                	sd	s3,56(sp)
    80001400:	f852                	sd	s4,48(sp)
    80001402:	f456                	sd	s5,40(sp)
    80001404:	f05a                	sd	s6,32(sp)
    80001406:	ec5e                	sd	s7,24(sp)
    80001408:	e862                	sd	s8,16(sp)
    8000140a:	e466                	sd	s9,8(sp)
    8000140c:	1080                	addi	s0,sp,96
    8000140e:	8792                	mv	a5,tp
  int id = r_tp();
    80001410:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001412:	00779c13          	slli	s8,a5,0x7
    80001416:	00009717          	auipc	a4,0x9
    8000141a:	c5a70713          	addi	a4,a4,-934 # 8000a070 <pid_lock>
    8000141e:	9762                	add	a4,a4,s8
    80001420:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001424:	00009717          	auipc	a4,0x9
    80001428:	c6c70713          	addi	a4,a4,-916 # 8000a090 <cpus+0x8>
    8000142c:	9c3a                	add	s8,s8,a4
    int nproc = 0;
    8000142e:	4c81                	li	s9,0
      if(p->state == RUNNABLE) {
    80001430:	4a89                	li	s5,2
        c->proc = p;
    80001432:	079e                	slli	a5,a5,0x7
    80001434:	00009b17          	auipc	s6,0x9
    80001438:	c3cb0b13          	addi	s6,s6,-964 # 8000a070 <pid_lock>
    8000143c:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000143e:	0000fa17          	auipc	s4,0xf
    80001442:	a4aa0a13          	addi	s4,s4,-1462 # 8000fe88 <tickslock>
    80001446:	a8a1                	j	8000149e <scheduler+0xaa>
      release(&p->lock);
    80001448:	8526                	mv	a0,s1
    8000144a:	00006097          	auipc	ra,0x6
    8000144e:	dda080e7          	jalr	-550(ra) # 80007224 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001452:	16848493          	addi	s1,s1,360
    80001456:	03448a63          	beq	s1,s4,8000148a <scheduler+0x96>
      acquire(&p->lock);
    8000145a:	8526                	mv	a0,s1
    8000145c:	00006097          	auipc	ra,0x6
    80001460:	d14080e7          	jalr	-748(ra) # 80007170 <acquire>
      if(p->state != UNUSED) {
    80001464:	4c9c                	lw	a5,24(s1)
    80001466:	d3ed                	beqz	a5,80001448 <scheduler+0x54>
        nproc++;
    80001468:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    8000146a:	fd579fe3          	bne	a5,s5,80001448 <scheduler+0x54>
        p->state = RUNNING;
    8000146e:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80001472:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    80001476:	06048593          	addi	a1,s1,96
    8000147a:	8562                	mv	a0,s8
    8000147c:	00000097          	auipc	ra,0x0
    80001480:	60c080e7          	jalr	1548(ra) # 80001a88 <swtch>
        c->proc = 0;
    80001484:	000b3c23          	sd	zero,24(s6)
    80001488:	b7c1                	j	80001448 <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    8000148a:	013aca63          	blt	s5,s3,8000149e <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000148e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001492:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001496:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000149a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000149e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800014a2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800014a6:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    800014aa:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    800014ac:	00009497          	auipc	s1,0x9
    800014b0:	fdc48493          	addi	s1,s1,-36 # 8000a488 <proc>
        p->state = RUNNING;
    800014b4:	4b8d                	li	s7,3
    800014b6:	b755                	j	8000145a <scheduler+0x66>

00000000800014b8 <sched>:
{
    800014b8:	7179                	addi	sp,sp,-48
    800014ba:	f406                	sd	ra,40(sp)
    800014bc:	f022                	sd	s0,32(sp)
    800014be:	ec26                	sd	s1,24(sp)
    800014c0:	e84a                	sd	s2,16(sp)
    800014c2:	e44e                	sd	s3,8(sp)
    800014c4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800014c6:	00000097          	auipc	ra,0x0
    800014ca:	9fa080e7          	jalr	-1542(ra) # 80000ec0 <myproc>
    800014ce:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800014d0:	00006097          	auipc	ra,0x6
    800014d4:	c26080e7          	jalr	-986(ra) # 800070f6 <holding>
    800014d8:	c93d                	beqz	a0,8000154e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800014da:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800014dc:	2781                	sext.w	a5,a5
    800014de:	079e                	slli	a5,a5,0x7
    800014e0:	00009717          	auipc	a4,0x9
    800014e4:	b9070713          	addi	a4,a4,-1136 # 8000a070 <pid_lock>
    800014e8:	97ba                	add	a5,a5,a4
    800014ea:	0907a703          	lw	a4,144(a5)
    800014ee:	4785                	li	a5,1
    800014f0:	06f71763          	bne	a4,a5,8000155e <sched+0xa6>
  if(p->state == RUNNING)
    800014f4:	4c98                	lw	a4,24(s1)
    800014f6:	478d                	li	a5,3
    800014f8:	06f70b63          	beq	a4,a5,8000156e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800014fc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001500:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001502:	efb5                	bnez	a5,8000157e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001504:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001506:	00009917          	auipc	s2,0x9
    8000150a:	b6a90913          	addi	s2,s2,-1174 # 8000a070 <pid_lock>
    8000150e:	2781                	sext.w	a5,a5
    80001510:	079e                	slli	a5,a5,0x7
    80001512:	97ca                	add	a5,a5,s2
    80001514:	0947a983          	lw	s3,148(a5)
    80001518:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000151a:	2781                	sext.w	a5,a5
    8000151c:	079e                	slli	a5,a5,0x7
    8000151e:	00009597          	auipc	a1,0x9
    80001522:	b7258593          	addi	a1,a1,-1166 # 8000a090 <cpus+0x8>
    80001526:	95be                	add	a1,a1,a5
    80001528:	06048513          	addi	a0,s1,96
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	55c080e7          	jalr	1372(ra) # 80001a88 <swtch>
    80001534:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001536:	2781                	sext.w	a5,a5
    80001538:	079e                	slli	a5,a5,0x7
    8000153a:	97ca                	add	a5,a5,s2
    8000153c:	0937aa23          	sw	s3,148(a5)
}
    80001540:	70a2                	ld	ra,40(sp)
    80001542:	7402                	ld	s0,32(sp)
    80001544:	64e2                	ld	s1,24(sp)
    80001546:	6942                	ld	s2,16(sp)
    80001548:	69a2                	ld	s3,8(sp)
    8000154a:	6145                	addi	sp,sp,48
    8000154c:	8082                	ret
    panic("sched p->lock");
    8000154e:	00008517          	auipc	a0,0x8
    80001552:	c3a50513          	addi	a0,a0,-966 # 80009188 <etext+0x188>
    80001556:	00005097          	auipc	ra,0x5
    8000155a:	6de080e7          	jalr	1758(ra) # 80006c34 <panic>
    panic("sched locks");
    8000155e:	00008517          	auipc	a0,0x8
    80001562:	c3a50513          	addi	a0,a0,-966 # 80009198 <etext+0x198>
    80001566:	00005097          	auipc	ra,0x5
    8000156a:	6ce080e7          	jalr	1742(ra) # 80006c34 <panic>
    panic("sched running");
    8000156e:	00008517          	auipc	a0,0x8
    80001572:	c3a50513          	addi	a0,a0,-966 # 800091a8 <etext+0x1a8>
    80001576:	00005097          	auipc	ra,0x5
    8000157a:	6be080e7          	jalr	1726(ra) # 80006c34 <panic>
    panic("sched interruptible");
    8000157e:	00008517          	auipc	a0,0x8
    80001582:	c3a50513          	addi	a0,a0,-966 # 800091b8 <etext+0x1b8>
    80001586:	00005097          	auipc	ra,0x5
    8000158a:	6ae080e7          	jalr	1710(ra) # 80006c34 <panic>

000000008000158e <exit>:
{
    8000158e:	7179                	addi	sp,sp,-48
    80001590:	f406                	sd	ra,40(sp)
    80001592:	f022                	sd	s0,32(sp)
    80001594:	ec26                	sd	s1,24(sp)
    80001596:	e84a                	sd	s2,16(sp)
    80001598:	e44e                	sd	s3,8(sp)
    8000159a:	e052                	sd	s4,0(sp)
    8000159c:	1800                	addi	s0,sp,48
    8000159e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800015a0:	00000097          	auipc	ra,0x0
    800015a4:	920080e7          	jalr	-1760(ra) # 80000ec0 <myproc>
    800015a8:	89aa                	mv	s3,a0
  if(p == initproc)
    800015aa:	00009797          	auipc	a5,0x9
    800015ae:	a667b783          	ld	a5,-1434(a5) # 8000a010 <initproc>
    800015b2:	0d050493          	addi	s1,a0,208
    800015b6:	15050913          	addi	s2,a0,336
    800015ba:	02a79363          	bne	a5,a0,800015e0 <exit+0x52>
    panic("init exiting");
    800015be:	00008517          	auipc	a0,0x8
    800015c2:	c1250513          	addi	a0,a0,-1006 # 800091d0 <etext+0x1d0>
    800015c6:	00005097          	auipc	ra,0x5
    800015ca:	66e080e7          	jalr	1646(ra) # 80006c34 <panic>
      fileclose(f);
    800015ce:	00002097          	auipc	ra,0x2
    800015d2:	3f2080e7          	jalr	1010(ra) # 800039c0 <fileclose>
      p->ofile[fd] = 0;
    800015d6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800015da:	04a1                	addi	s1,s1,8
    800015dc:	01248563          	beq	s1,s2,800015e6 <exit+0x58>
    if(p->ofile[fd]){
    800015e0:	6088                	ld	a0,0(s1)
    800015e2:	f575                	bnez	a0,800015ce <exit+0x40>
    800015e4:	bfdd                	j	800015da <exit+0x4c>
  begin_op();
    800015e6:	00002097          	auipc	ra,0x2
    800015ea:	f06080e7          	jalr	-250(ra) # 800034ec <begin_op>
  iput(p->cwd);
    800015ee:	1509b503          	ld	a0,336(s3)
    800015f2:	00001097          	auipc	ra,0x1
    800015f6:	6e2080e7          	jalr	1762(ra) # 80002cd4 <iput>
  end_op();
    800015fa:	00002097          	auipc	ra,0x2
    800015fe:	f72080e7          	jalr	-142(ra) # 8000356c <end_op>
  p->cwd = 0;
    80001602:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    80001606:	00009497          	auipc	s1,0x9
    8000160a:	a0a48493          	addi	s1,s1,-1526 # 8000a010 <initproc>
    8000160e:	6088                	ld	a0,0(s1)
    80001610:	00006097          	auipc	ra,0x6
    80001614:	b60080e7          	jalr	-1184(ra) # 80007170 <acquire>
  wakeup1(initproc);
    80001618:	6088                	ld	a0,0(s1)
    8000161a:	fffff097          	auipc	ra,0xfffff
    8000161e:	708080e7          	jalr	1800(ra) # 80000d22 <wakeup1>
  release(&initproc->lock);
    80001622:	6088                	ld	a0,0(s1)
    80001624:	00006097          	auipc	ra,0x6
    80001628:	c00080e7          	jalr	-1024(ra) # 80007224 <release>
  acquire(&p->lock);
    8000162c:	854e                	mv	a0,s3
    8000162e:	00006097          	auipc	ra,0x6
    80001632:	b42080e7          	jalr	-1214(ra) # 80007170 <acquire>
  struct proc *original_parent = p->parent;
    80001636:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    8000163a:	854e                	mv	a0,s3
    8000163c:	00006097          	auipc	ra,0x6
    80001640:	be8080e7          	jalr	-1048(ra) # 80007224 <release>
  acquire(&original_parent->lock);
    80001644:	8526                	mv	a0,s1
    80001646:	00006097          	auipc	ra,0x6
    8000164a:	b2a080e7          	jalr	-1238(ra) # 80007170 <acquire>
  acquire(&p->lock);
    8000164e:	854e                	mv	a0,s3
    80001650:	00006097          	auipc	ra,0x6
    80001654:	b20080e7          	jalr	-1248(ra) # 80007170 <acquire>
  reparent(p);
    80001658:	854e                	mv	a0,s3
    8000165a:	00000097          	auipc	ra,0x0
    8000165e:	d34080e7          	jalr	-716(ra) # 8000138e <reparent>
  wakeup1(original_parent);
    80001662:	8526                	mv	a0,s1
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	6be080e7          	jalr	1726(ra) # 80000d22 <wakeup1>
  p->xstate = status;
    8000166c:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80001670:	4791                	li	a5,4
    80001672:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80001676:	8526                	mv	a0,s1
    80001678:	00006097          	auipc	ra,0x6
    8000167c:	bac080e7          	jalr	-1108(ra) # 80007224 <release>
  sched();
    80001680:	00000097          	auipc	ra,0x0
    80001684:	e38080e7          	jalr	-456(ra) # 800014b8 <sched>
  panic("zombie exit");
    80001688:	00008517          	auipc	a0,0x8
    8000168c:	b5850513          	addi	a0,a0,-1192 # 800091e0 <etext+0x1e0>
    80001690:	00005097          	auipc	ra,0x5
    80001694:	5a4080e7          	jalr	1444(ra) # 80006c34 <panic>

0000000080001698 <yield>:
{
    80001698:	1101                	addi	sp,sp,-32
    8000169a:	ec06                	sd	ra,24(sp)
    8000169c:	e822                	sd	s0,16(sp)
    8000169e:	e426                	sd	s1,8(sp)
    800016a0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800016a2:	00000097          	auipc	ra,0x0
    800016a6:	81e080e7          	jalr	-2018(ra) # 80000ec0 <myproc>
    800016aa:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800016ac:	00006097          	auipc	ra,0x6
    800016b0:	ac4080e7          	jalr	-1340(ra) # 80007170 <acquire>
  p->state = RUNNABLE;
    800016b4:	4789                	li	a5,2
    800016b6:	cc9c                	sw	a5,24(s1)
  sched();
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	e00080e7          	jalr	-512(ra) # 800014b8 <sched>
  release(&p->lock);
    800016c0:	8526                	mv	a0,s1
    800016c2:	00006097          	auipc	ra,0x6
    800016c6:	b62080e7          	jalr	-1182(ra) # 80007224 <release>
}
    800016ca:	60e2                	ld	ra,24(sp)
    800016cc:	6442                	ld	s0,16(sp)
    800016ce:	64a2                	ld	s1,8(sp)
    800016d0:	6105                	addi	sp,sp,32
    800016d2:	8082                	ret

00000000800016d4 <sleep>:
{
    800016d4:	7179                	addi	sp,sp,-48
    800016d6:	f406                	sd	ra,40(sp)
    800016d8:	f022                	sd	s0,32(sp)
    800016da:	ec26                	sd	s1,24(sp)
    800016dc:	e84a                	sd	s2,16(sp)
    800016de:	e44e                	sd	s3,8(sp)
    800016e0:	1800                	addi	s0,sp,48
    800016e2:	89aa                	mv	s3,a0
    800016e4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800016e6:	fffff097          	auipc	ra,0xfffff
    800016ea:	7da080e7          	jalr	2010(ra) # 80000ec0 <myproc>
    800016ee:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800016f0:	05250663          	beq	a0,s2,8000173c <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800016f4:	00006097          	auipc	ra,0x6
    800016f8:	a7c080e7          	jalr	-1412(ra) # 80007170 <acquire>
    release(lk);
    800016fc:	854a                	mv	a0,s2
    800016fe:	00006097          	auipc	ra,0x6
    80001702:	b26080e7          	jalr	-1242(ra) # 80007224 <release>
  p->chan = chan;
    80001706:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    8000170a:	4785                	li	a5,1
    8000170c:	cc9c                	sw	a5,24(s1)
  sched();
    8000170e:	00000097          	auipc	ra,0x0
    80001712:	daa080e7          	jalr	-598(ra) # 800014b8 <sched>
  p->chan = 0;
    80001716:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    8000171a:	8526                	mv	a0,s1
    8000171c:	00006097          	auipc	ra,0x6
    80001720:	b08080e7          	jalr	-1272(ra) # 80007224 <release>
    acquire(lk);
    80001724:	854a                	mv	a0,s2
    80001726:	00006097          	auipc	ra,0x6
    8000172a:	a4a080e7          	jalr	-1462(ra) # 80007170 <acquire>
}
    8000172e:	70a2                	ld	ra,40(sp)
    80001730:	7402                	ld	s0,32(sp)
    80001732:	64e2                	ld	s1,24(sp)
    80001734:	6942                	ld	s2,16(sp)
    80001736:	69a2                	ld	s3,8(sp)
    80001738:	6145                	addi	sp,sp,48
    8000173a:	8082                	ret
  p->chan = chan;
    8000173c:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80001740:	4785                	li	a5,1
    80001742:	cd1c                	sw	a5,24(a0)
  sched();
    80001744:	00000097          	auipc	ra,0x0
    80001748:	d74080e7          	jalr	-652(ra) # 800014b8 <sched>
  p->chan = 0;
    8000174c:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80001750:	bff9                	j	8000172e <sleep+0x5a>

0000000080001752 <wait>:
{
    80001752:	715d                	addi	sp,sp,-80
    80001754:	e486                	sd	ra,72(sp)
    80001756:	e0a2                	sd	s0,64(sp)
    80001758:	fc26                	sd	s1,56(sp)
    8000175a:	f84a                	sd	s2,48(sp)
    8000175c:	f44e                	sd	s3,40(sp)
    8000175e:	f052                	sd	s4,32(sp)
    80001760:	ec56                	sd	s5,24(sp)
    80001762:	e85a                	sd	s6,16(sp)
    80001764:	e45e                	sd	s7,8(sp)
    80001766:	0880                	addi	s0,sp,80
    80001768:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000176a:	fffff097          	auipc	ra,0xfffff
    8000176e:	756080e7          	jalr	1878(ra) # 80000ec0 <myproc>
    80001772:	892a                	mv	s2,a0
  acquire(&p->lock);
    80001774:	00006097          	auipc	ra,0x6
    80001778:	9fc080e7          	jalr	-1540(ra) # 80007170 <acquire>
    havekids = 0;
    8000177c:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000177e:	4a11                	li	s4,4
        havekids = 1;
    80001780:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80001782:	0000e997          	auipc	s3,0xe
    80001786:	70698993          	addi	s3,s3,1798 # 8000fe88 <tickslock>
    havekids = 0;
    8000178a:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000178c:	00009497          	auipc	s1,0x9
    80001790:	cfc48493          	addi	s1,s1,-772 # 8000a488 <proc>
    80001794:	a08d                	j	800017f6 <wait+0xa4>
          pid = np->pid;
    80001796:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000179a:	000b0e63          	beqz	s6,800017b6 <wait+0x64>
    8000179e:	4691                	li	a3,4
    800017a0:	03448613          	addi	a2,s1,52
    800017a4:	85da                	mv	a1,s6
    800017a6:	05093503          	ld	a0,80(s2)
    800017aa:	fffff097          	auipc	ra,0xfffff
    800017ae:	3aa080e7          	jalr	938(ra) # 80000b54 <copyout>
    800017b2:	02054263          	bltz	a0,800017d6 <wait+0x84>
          freeproc(np);
    800017b6:	8526                	mv	a0,s1
    800017b8:	00000097          	auipc	ra,0x0
    800017bc:	8ba080e7          	jalr	-1862(ra) # 80001072 <freeproc>
          release(&np->lock);
    800017c0:	8526                	mv	a0,s1
    800017c2:	00006097          	auipc	ra,0x6
    800017c6:	a62080e7          	jalr	-1438(ra) # 80007224 <release>
          release(&p->lock);
    800017ca:	854a                	mv	a0,s2
    800017cc:	00006097          	auipc	ra,0x6
    800017d0:	a58080e7          	jalr	-1448(ra) # 80007224 <release>
          return pid;
    800017d4:	a8a9                	j	8000182e <wait+0xdc>
            release(&np->lock);
    800017d6:	8526                	mv	a0,s1
    800017d8:	00006097          	auipc	ra,0x6
    800017dc:	a4c080e7          	jalr	-1460(ra) # 80007224 <release>
            release(&p->lock);
    800017e0:	854a                	mv	a0,s2
    800017e2:	00006097          	auipc	ra,0x6
    800017e6:	a42080e7          	jalr	-1470(ra) # 80007224 <release>
            return -1;
    800017ea:	59fd                	li	s3,-1
    800017ec:	a089                	j	8000182e <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    800017ee:	16848493          	addi	s1,s1,360
    800017f2:	03348463          	beq	s1,s3,8000181a <wait+0xc8>
      if(np->parent == p){
    800017f6:	709c                	ld	a5,32(s1)
    800017f8:	ff279be3          	bne	a5,s2,800017ee <wait+0x9c>
        acquire(&np->lock);
    800017fc:	8526                	mv	a0,s1
    800017fe:	00006097          	auipc	ra,0x6
    80001802:	972080e7          	jalr	-1678(ra) # 80007170 <acquire>
        if(np->state == ZOMBIE){
    80001806:	4c9c                	lw	a5,24(s1)
    80001808:	f94787e3          	beq	a5,s4,80001796 <wait+0x44>
        release(&np->lock);
    8000180c:	8526                	mv	a0,s1
    8000180e:	00006097          	auipc	ra,0x6
    80001812:	a16080e7          	jalr	-1514(ra) # 80007224 <release>
        havekids = 1;
    80001816:	8756                	mv	a4,s5
    80001818:	bfd9                	j	800017ee <wait+0x9c>
    if(!havekids || p->killed){
    8000181a:	c701                	beqz	a4,80001822 <wait+0xd0>
    8000181c:	03092783          	lw	a5,48(s2)
    80001820:	c39d                	beqz	a5,80001846 <wait+0xf4>
      release(&p->lock);
    80001822:	854a                	mv	a0,s2
    80001824:	00006097          	auipc	ra,0x6
    80001828:	a00080e7          	jalr	-1536(ra) # 80007224 <release>
      return -1;
    8000182c:	59fd                	li	s3,-1
}
    8000182e:	854e                	mv	a0,s3
    80001830:	60a6                	ld	ra,72(sp)
    80001832:	6406                	ld	s0,64(sp)
    80001834:	74e2                	ld	s1,56(sp)
    80001836:	7942                	ld	s2,48(sp)
    80001838:	79a2                	ld	s3,40(sp)
    8000183a:	7a02                	ld	s4,32(sp)
    8000183c:	6ae2                	ld	s5,24(sp)
    8000183e:	6b42                	ld	s6,16(sp)
    80001840:	6ba2                	ld	s7,8(sp)
    80001842:	6161                	addi	sp,sp,80
    80001844:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80001846:	85ca                	mv	a1,s2
    80001848:	854a                	mv	a0,s2
    8000184a:	00000097          	auipc	ra,0x0
    8000184e:	e8a080e7          	jalr	-374(ra) # 800016d4 <sleep>
    havekids = 0;
    80001852:	bf25                	j	8000178a <wait+0x38>

0000000080001854 <wakeup>:
{
    80001854:	7139                	addi	sp,sp,-64
    80001856:	fc06                	sd	ra,56(sp)
    80001858:	f822                	sd	s0,48(sp)
    8000185a:	f426                	sd	s1,40(sp)
    8000185c:	f04a                	sd	s2,32(sp)
    8000185e:	ec4e                	sd	s3,24(sp)
    80001860:	e852                	sd	s4,16(sp)
    80001862:	e456                	sd	s5,8(sp)
    80001864:	0080                	addi	s0,sp,64
    80001866:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001868:	00009497          	auipc	s1,0x9
    8000186c:	c2048493          	addi	s1,s1,-992 # 8000a488 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80001870:	4985                	li	s3,1
      p->state = RUNNABLE;
    80001872:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80001874:	0000e917          	auipc	s2,0xe
    80001878:	61490913          	addi	s2,s2,1556 # 8000fe88 <tickslock>
    8000187c:	a811                	j	80001890 <wakeup+0x3c>
    release(&p->lock);
    8000187e:	8526                	mv	a0,s1
    80001880:	00006097          	auipc	ra,0x6
    80001884:	9a4080e7          	jalr	-1628(ra) # 80007224 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001888:	16848493          	addi	s1,s1,360
    8000188c:	03248063          	beq	s1,s2,800018ac <wakeup+0x58>
    acquire(&p->lock);
    80001890:	8526                	mv	a0,s1
    80001892:	00006097          	auipc	ra,0x6
    80001896:	8de080e7          	jalr	-1826(ra) # 80007170 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000189a:	4c9c                	lw	a5,24(s1)
    8000189c:	ff3791e3          	bne	a5,s3,8000187e <wakeup+0x2a>
    800018a0:	749c                	ld	a5,40(s1)
    800018a2:	fd479ee3          	bne	a5,s4,8000187e <wakeup+0x2a>
      p->state = RUNNABLE;
    800018a6:	0154ac23          	sw	s5,24(s1)
    800018aa:	bfd1                	j	8000187e <wakeup+0x2a>
}
    800018ac:	70e2                	ld	ra,56(sp)
    800018ae:	7442                	ld	s0,48(sp)
    800018b0:	74a2                	ld	s1,40(sp)
    800018b2:	7902                	ld	s2,32(sp)
    800018b4:	69e2                	ld	s3,24(sp)
    800018b6:	6a42                	ld	s4,16(sp)
    800018b8:	6aa2                	ld	s5,8(sp)
    800018ba:	6121                	addi	sp,sp,64
    800018bc:	8082                	ret

00000000800018be <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800018be:	7179                	addi	sp,sp,-48
    800018c0:	f406                	sd	ra,40(sp)
    800018c2:	f022                	sd	s0,32(sp)
    800018c4:	ec26                	sd	s1,24(sp)
    800018c6:	e84a                	sd	s2,16(sp)
    800018c8:	e44e                	sd	s3,8(sp)
    800018ca:	1800                	addi	s0,sp,48
    800018cc:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800018ce:	00009497          	auipc	s1,0x9
    800018d2:	bba48493          	addi	s1,s1,-1094 # 8000a488 <proc>
    800018d6:	0000e997          	auipc	s3,0xe
    800018da:	5b298993          	addi	s3,s3,1458 # 8000fe88 <tickslock>
    acquire(&p->lock);
    800018de:	8526                	mv	a0,s1
    800018e0:	00006097          	auipc	ra,0x6
    800018e4:	890080e7          	jalr	-1904(ra) # 80007170 <acquire>
    if(p->pid == pid){
    800018e8:	5c9c                	lw	a5,56(s1)
    800018ea:	01278d63          	beq	a5,s2,80001904 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800018ee:	8526                	mv	a0,s1
    800018f0:	00006097          	auipc	ra,0x6
    800018f4:	934080e7          	jalr	-1740(ra) # 80007224 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800018f8:	16848493          	addi	s1,s1,360
    800018fc:	ff3491e3          	bne	s1,s3,800018de <kill+0x20>
  }
  return -1;
    80001900:	557d                	li	a0,-1
    80001902:	a821                	j	8000191a <kill+0x5c>
      p->killed = 1;
    80001904:	4785                	li	a5,1
    80001906:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80001908:	4c98                	lw	a4,24(s1)
    8000190a:	00f70f63          	beq	a4,a5,80001928 <kill+0x6a>
      release(&p->lock);
    8000190e:	8526                	mv	a0,s1
    80001910:	00006097          	auipc	ra,0x6
    80001914:	914080e7          	jalr	-1772(ra) # 80007224 <release>
      return 0;
    80001918:	4501                	li	a0,0
}
    8000191a:	70a2                	ld	ra,40(sp)
    8000191c:	7402                	ld	s0,32(sp)
    8000191e:	64e2                	ld	s1,24(sp)
    80001920:	6942                	ld	s2,16(sp)
    80001922:	69a2                	ld	s3,8(sp)
    80001924:	6145                	addi	sp,sp,48
    80001926:	8082                	ret
        p->state = RUNNABLE;
    80001928:	4789                	li	a5,2
    8000192a:	cc9c                	sw	a5,24(s1)
    8000192c:	b7cd                	j	8000190e <kill+0x50>

000000008000192e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000192e:	7179                	addi	sp,sp,-48
    80001930:	f406                	sd	ra,40(sp)
    80001932:	f022                	sd	s0,32(sp)
    80001934:	ec26                	sd	s1,24(sp)
    80001936:	e84a                	sd	s2,16(sp)
    80001938:	e44e                	sd	s3,8(sp)
    8000193a:	e052                	sd	s4,0(sp)
    8000193c:	1800                	addi	s0,sp,48
    8000193e:	84aa                	mv	s1,a0
    80001940:	892e                	mv	s2,a1
    80001942:	89b2                	mv	s3,a2
    80001944:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001946:	fffff097          	auipc	ra,0xfffff
    8000194a:	57a080e7          	jalr	1402(ra) # 80000ec0 <myproc>
  if(user_dst){
    8000194e:	c08d                	beqz	s1,80001970 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80001950:	86d2                	mv	a3,s4
    80001952:	864e                	mv	a2,s3
    80001954:	85ca                	mv	a1,s2
    80001956:	6928                	ld	a0,80(a0)
    80001958:	fffff097          	auipc	ra,0xfffff
    8000195c:	1fc080e7          	jalr	508(ra) # 80000b54 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001960:	70a2                	ld	ra,40(sp)
    80001962:	7402                	ld	s0,32(sp)
    80001964:	64e2                	ld	s1,24(sp)
    80001966:	6942                	ld	s2,16(sp)
    80001968:	69a2                	ld	s3,8(sp)
    8000196a:	6a02                	ld	s4,0(sp)
    8000196c:	6145                	addi	sp,sp,48
    8000196e:	8082                	ret
    memmove((char *)dst, src, len);
    80001970:	000a061b          	sext.w	a2,s4
    80001974:	85ce                	mv	a1,s3
    80001976:	854a                	mv	a0,s2
    80001978:	fffff097          	auipc	ra,0xfffff
    8000197c:	85c080e7          	jalr	-1956(ra) # 800001d4 <memmove>
    return 0;
    80001980:	8526                	mv	a0,s1
    80001982:	bff9                	j	80001960 <either_copyout+0x32>

0000000080001984 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001984:	7179                	addi	sp,sp,-48
    80001986:	f406                	sd	ra,40(sp)
    80001988:	f022                	sd	s0,32(sp)
    8000198a:	ec26                	sd	s1,24(sp)
    8000198c:	e84a                	sd	s2,16(sp)
    8000198e:	e44e                	sd	s3,8(sp)
    80001990:	e052                	sd	s4,0(sp)
    80001992:	1800                	addi	s0,sp,48
    80001994:	892a                	mv	s2,a0
    80001996:	84ae                	mv	s1,a1
    80001998:	89b2                	mv	s3,a2
    8000199a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000199c:	fffff097          	auipc	ra,0xfffff
    800019a0:	524080e7          	jalr	1316(ra) # 80000ec0 <myproc>
  if(user_src){
    800019a4:	c08d                	beqz	s1,800019c6 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800019a6:	86d2                	mv	a3,s4
    800019a8:	864e                	mv	a2,s3
    800019aa:	85ca                	mv	a1,s2
    800019ac:	6928                	ld	a0,80(a0)
    800019ae:	fffff097          	auipc	ra,0xfffff
    800019b2:	232080e7          	jalr	562(ra) # 80000be0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800019b6:	70a2                	ld	ra,40(sp)
    800019b8:	7402                	ld	s0,32(sp)
    800019ba:	64e2                	ld	s1,24(sp)
    800019bc:	6942                	ld	s2,16(sp)
    800019be:	69a2                	ld	s3,8(sp)
    800019c0:	6a02                	ld	s4,0(sp)
    800019c2:	6145                	addi	sp,sp,48
    800019c4:	8082                	ret
    memmove(dst, (char*)src, len);
    800019c6:	000a061b          	sext.w	a2,s4
    800019ca:	85ce                	mv	a1,s3
    800019cc:	854a                	mv	a0,s2
    800019ce:	fffff097          	auipc	ra,0xfffff
    800019d2:	806080e7          	jalr	-2042(ra) # 800001d4 <memmove>
    return 0;
    800019d6:	8526                	mv	a0,s1
    800019d8:	bff9                	j	800019b6 <either_copyin+0x32>

00000000800019da <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800019da:	715d                	addi	sp,sp,-80
    800019dc:	e486                	sd	ra,72(sp)
    800019de:	e0a2                	sd	s0,64(sp)
    800019e0:	fc26                	sd	s1,56(sp)
    800019e2:	f84a                	sd	s2,48(sp)
    800019e4:	f44e                	sd	s3,40(sp)
    800019e6:	f052                	sd	s4,32(sp)
    800019e8:	ec56                	sd	s5,24(sp)
    800019ea:	e85a                	sd	s6,16(sp)
    800019ec:	e45e                	sd	s7,8(sp)
    800019ee:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800019f0:	00007517          	auipc	a0,0x7
    800019f4:	65850513          	addi	a0,a0,1624 # 80009048 <etext+0x48>
    800019f8:	00005097          	auipc	ra,0x5
    800019fc:	286080e7          	jalr	646(ra) # 80006c7e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a00:	00009497          	auipc	s1,0x9
    80001a04:	be048493          	addi	s1,s1,-1056 # 8000a5e0 <proc+0x158>
    80001a08:	0000e917          	auipc	s2,0xe
    80001a0c:	5d890913          	addi	s2,s2,1496 # 8000ffe0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a10:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80001a12:	00007997          	auipc	s3,0x7
    80001a16:	7de98993          	addi	s3,s3,2014 # 800091f0 <etext+0x1f0>
    printf("%d %s %s", p->pid, state, p->name);
    80001a1a:	00007a97          	auipc	s5,0x7
    80001a1e:	7dea8a93          	addi	s5,s5,2014 # 800091f8 <etext+0x1f8>
    printf("\n");
    80001a22:	00007a17          	auipc	s4,0x7
    80001a26:	626a0a13          	addi	s4,s4,1574 # 80009048 <etext+0x48>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a2a:	00008b97          	auipc	s7,0x8
    80001a2e:	806b8b93          	addi	s7,s7,-2042 # 80009230 <states.0>
    80001a32:	a00d                	j	80001a54 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001a34:	ee06a583          	lw	a1,-288(a3)
    80001a38:	8556                	mv	a0,s5
    80001a3a:	00005097          	auipc	ra,0x5
    80001a3e:	244080e7          	jalr	580(ra) # 80006c7e <printf>
    printf("\n");
    80001a42:	8552                	mv	a0,s4
    80001a44:	00005097          	auipc	ra,0x5
    80001a48:	23a080e7          	jalr	570(ra) # 80006c7e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a4c:	16848493          	addi	s1,s1,360
    80001a50:	03248163          	beq	s1,s2,80001a72 <procdump+0x98>
    if(p->state == UNUSED)
    80001a54:	86a6                	mv	a3,s1
    80001a56:	ec04a783          	lw	a5,-320(s1)
    80001a5a:	dbed                	beqz	a5,80001a4c <procdump+0x72>
      state = "???";
    80001a5c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a5e:	fcfb6be3          	bltu	s6,a5,80001a34 <procdump+0x5a>
    80001a62:	1782                	slli	a5,a5,0x20
    80001a64:	9381                	srli	a5,a5,0x20
    80001a66:	078e                	slli	a5,a5,0x3
    80001a68:	97de                	add	a5,a5,s7
    80001a6a:	6390                	ld	a2,0(a5)
    80001a6c:	f661                	bnez	a2,80001a34 <procdump+0x5a>
      state = "???";
    80001a6e:	864e                	mv	a2,s3
    80001a70:	b7d1                	j	80001a34 <procdump+0x5a>
  }
}
    80001a72:	60a6                	ld	ra,72(sp)
    80001a74:	6406                	ld	s0,64(sp)
    80001a76:	74e2                	ld	s1,56(sp)
    80001a78:	7942                	ld	s2,48(sp)
    80001a7a:	79a2                	ld	s3,40(sp)
    80001a7c:	7a02                	ld	s4,32(sp)
    80001a7e:	6ae2                	ld	s5,24(sp)
    80001a80:	6b42                	ld	s6,16(sp)
    80001a82:	6ba2                	ld	s7,8(sp)
    80001a84:	6161                	addi	sp,sp,80
    80001a86:	8082                	ret

0000000080001a88 <swtch>:
    80001a88:	00153023          	sd	ra,0(a0)
    80001a8c:	00253423          	sd	sp,8(a0)
    80001a90:	e900                	sd	s0,16(a0)
    80001a92:	ed04                	sd	s1,24(a0)
    80001a94:	03253023          	sd	s2,32(a0)
    80001a98:	03353423          	sd	s3,40(a0)
    80001a9c:	03453823          	sd	s4,48(a0)
    80001aa0:	03553c23          	sd	s5,56(a0)
    80001aa4:	05653023          	sd	s6,64(a0)
    80001aa8:	05753423          	sd	s7,72(a0)
    80001aac:	05853823          	sd	s8,80(a0)
    80001ab0:	05953c23          	sd	s9,88(a0)
    80001ab4:	07a53023          	sd	s10,96(a0)
    80001ab8:	07b53423          	sd	s11,104(a0)
    80001abc:	0005b083          	ld	ra,0(a1)
    80001ac0:	0085b103          	ld	sp,8(a1)
    80001ac4:	6980                	ld	s0,16(a1)
    80001ac6:	6d84                	ld	s1,24(a1)
    80001ac8:	0205b903          	ld	s2,32(a1)
    80001acc:	0285b983          	ld	s3,40(a1)
    80001ad0:	0305ba03          	ld	s4,48(a1)
    80001ad4:	0385ba83          	ld	s5,56(a1)
    80001ad8:	0405bb03          	ld	s6,64(a1)
    80001adc:	0485bb83          	ld	s7,72(a1)
    80001ae0:	0505bc03          	ld	s8,80(a1)
    80001ae4:	0585bc83          	ld	s9,88(a1)
    80001ae8:	0605bd03          	ld	s10,96(a1)
    80001aec:	0685bd83          	ld	s11,104(a1)
    80001af0:	8082                	ret

0000000080001af2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001af2:	1141                	addi	sp,sp,-16
    80001af4:	e406                	sd	ra,8(sp)
    80001af6:	e022                	sd	s0,0(sp)
    80001af8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001afa:	00007597          	auipc	a1,0x7
    80001afe:	75e58593          	addi	a1,a1,1886 # 80009258 <states.0+0x28>
    80001b02:	0000e517          	auipc	a0,0xe
    80001b06:	38650513          	addi	a0,a0,902 # 8000fe88 <tickslock>
    80001b0a:	00005097          	auipc	ra,0x5
    80001b0e:	5d6080e7          	jalr	1494(ra) # 800070e0 <initlock>
}
    80001b12:	60a2                	ld	ra,8(sp)
    80001b14:	6402                	ld	s0,0(sp)
    80001b16:	0141                	addi	sp,sp,16
    80001b18:	8082                	ret

0000000080001b1a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001b1a:	1141                	addi	sp,sp,-16
    80001b1c:	e422                	sd	s0,8(sp)
    80001b1e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b20:	00003797          	auipc	a5,0x3
    80001b24:	59078793          	addi	a5,a5,1424 # 800050b0 <kernelvec>
    80001b28:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001b2c:	6422                	ld	s0,8(sp)
    80001b2e:	0141                	addi	sp,sp,16
    80001b30:	8082                	ret

0000000080001b32 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001b32:	1141                	addi	sp,sp,-16
    80001b34:	e406                	sd	ra,8(sp)
    80001b36:	e022                	sd	s0,0(sp)
    80001b38:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001b3a:	fffff097          	auipc	ra,0xfffff
    80001b3e:	386080e7          	jalr	902(ra) # 80000ec0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b42:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001b46:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b48:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80001b4c:	00006617          	auipc	a2,0x6
    80001b50:	4b460613          	addi	a2,a2,1204 # 80008000 <_trampoline>
    80001b54:	00006697          	auipc	a3,0x6
    80001b58:	4ac68693          	addi	a3,a3,1196 # 80008000 <_trampoline>
    80001b5c:	8e91                	sub	a3,a3,a2
    80001b5e:	040007b7          	lui	a5,0x4000
    80001b62:	17fd                	addi	a5,a5,-1
    80001b64:	07b2                	slli	a5,a5,0xc
    80001b66:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b68:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001b6c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001b6e:	180026f3          	csrr	a3,satp
    80001b72:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001b74:	6d38                	ld	a4,88(a0)
    80001b76:	6134                	ld	a3,64(a0)
    80001b78:	6585                	lui	a1,0x1
    80001b7a:	96ae                	add	a3,a3,a1
    80001b7c:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001b7e:	6d38                	ld	a4,88(a0)
    80001b80:	00000697          	auipc	a3,0x0
    80001b84:	14a68693          	addi	a3,a3,330 # 80001cca <usertrap>
    80001b88:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001b8a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b8c:	8692                	mv	a3,tp
    80001b8e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b90:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001b94:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001b98:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b9c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001ba0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001ba2:	6f18                	ld	a4,24(a4)
    80001ba4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001ba8:	692c                	ld	a1,80(a0)
    80001baa:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80001bac:	00006717          	auipc	a4,0x6
    80001bb0:	4e470713          	addi	a4,a4,1252 # 80008090 <userret>
    80001bb4:	8f11                	sub	a4,a4,a2
    80001bb6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80001bb8:	577d                	li	a4,-1
    80001bba:	177e                	slli	a4,a4,0x3f
    80001bbc:	8dd9                	or	a1,a1,a4
    80001bbe:	02000537          	lui	a0,0x2000
    80001bc2:	157d                	addi	a0,a0,-1
    80001bc4:	0536                	slli	a0,a0,0xd
    80001bc6:	9782                	jalr	a5
}
    80001bc8:	60a2                	ld	ra,8(sp)
    80001bca:	6402                	ld	s0,0(sp)
    80001bcc:	0141                	addi	sp,sp,16
    80001bce:	8082                	ret

0000000080001bd0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001bda:	0000e497          	auipc	s1,0xe
    80001bde:	2ae48493          	addi	s1,s1,686 # 8000fe88 <tickslock>
    80001be2:	8526                	mv	a0,s1
    80001be4:	00005097          	auipc	ra,0x5
    80001be8:	58c080e7          	jalr	1420(ra) # 80007170 <acquire>
  ticks++;
    80001bec:	00008517          	auipc	a0,0x8
    80001bf0:	42c50513          	addi	a0,a0,1068 # 8000a018 <ticks>
    80001bf4:	411c                	lw	a5,0(a0)
    80001bf6:	2785                	addiw	a5,a5,1
    80001bf8:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001bfa:	00000097          	auipc	ra,0x0
    80001bfe:	c5a080e7          	jalr	-934(ra) # 80001854 <wakeup>
  release(&tickslock);
    80001c02:	8526                	mv	a0,s1
    80001c04:	00005097          	auipc	ra,0x5
    80001c08:	620080e7          	jalr	1568(ra) # 80007224 <release>
}
    80001c0c:	60e2                	ld	ra,24(sp)
    80001c0e:	6442                	ld	s0,16(sp)
    80001c10:	64a2                	ld	s1,8(sp)
    80001c12:	6105                	addi	sp,sp,32
    80001c14:	8082                	ret

0000000080001c16 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001c16:	1101                	addi	sp,sp,-32
    80001c18:	ec06                	sd	ra,24(sp)
    80001c1a:	e822                	sd	s0,16(sp)
    80001c1c:	e426                	sd	s1,8(sp)
    80001c1e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001c20:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001c24:	00074d63          	bltz	a4,80001c3e <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001c28:	57fd                	li	a5,-1
    80001c2a:	17fe                	slli	a5,a5,0x3f
    80001c2c:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001c2e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001c30:	06f70c63          	beq	a4,a5,80001ca8 <devintr+0x92>
  }
}
    80001c34:	60e2                	ld	ra,24(sp)
    80001c36:	6442                	ld	s0,16(sp)
    80001c38:	64a2                	ld	s1,8(sp)
    80001c3a:	6105                	addi	sp,sp,32
    80001c3c:	8082                	ret
     (scause & 0xff) == 9){
    80001c3e:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80001c42:	46a5                	li	a3,9
    80001c44:	fed792e3          	bne	a5,a3,80001c28 <devintr+0x12>
    int irq = plic_claim();
    80001c48:	00003097          	auipc	ra,0x3
    80001c4c:	58a080e7          	jalr	1418(ra) # 800051d2 <plic_claim>
    80001c50:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001c52:	47a9                	li	a5,10
    80001c54:	02f50563          	beq	a0,a5,80001c7e <devintr+0x68>
    } else if(irq == VIRTIO0_IRQ){
    80001c58:	4785                	li	a5,1
    80001c5a:	02f50d63          	beq	a0,a5,80001c94 <devintr+0x7e>
    else if(irq == E1000_IRQ){
    80001c5e:	02100793          	li	a5,33
    80001c62:	02f50e63          	beq	a0,a5,80001c9e <devintr+0x88>
    return 1;
    80001c66:	4505                	li	a0,1
    else if(irq){
    80001c68:	d4f1                	beqz	s1,80001c34 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001c6a:	85a6                	mv	a1,s1
    80001c6c:	00007517          	auipc	a0,0x7
    80001c70:	5f450513          	addi	a0,a0,1524 # 80009260 <states.0+0x30>
    80001c74:	00005097          	auipc	ra,0x5
    80001c78:	00a080e7          	jalr	10(ra) # 80006c7e <printf>
    80001c7c:	a029                	j	80001c86 <devintr+0x70>
      uartintr();
    80001c7e:	00005097          	auipc	ra,0x5
    80001c82:	412080e7          	jalr	1042(ra) # 80007090 <uartintr>
      plic_complete(irq);
    80001c86:	8526                	mv	a0,s1
    80001c88:	00003097          	auipc	ra,0x3
    80001c8c:	56e080e7          	jalr	1390(ra) # 800051f6 <plic_complete>
    return 1;
    80001c90:	4505                	li	a0,1
    80001c92:	b74d                	j	80001c34 <devintr+0x1e>
      virtio_disk_intr();
    80001c94:	00004097          	auipc	ra,0x4
    80001c98:	9f4080e7          	jalr	-1548(ra) # 80005688 <virtio_disk_intr>
    80001c9c:	b7ed                	j	80001c86 <devintr+0x70>
      e1000_intr();
    80001c9e:	00004097          	auipc	ra,0x4
    80001ca2:	d64080e7          	jalr	-668(ra) # 80005a02 <e1000_intr>
    80001ca6:	b7c5                	j	80001c86 <devintr+0x70>
    if(cpuid() == 0){
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	1ec080e7          	jalr	492(ra) # 80000e94 <cpuid>
    80001cb0:	c901                	beqz	a0,80001cc0 <devintr+0xaa>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001cb2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001cb6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001cb8:	14479073          	csrw	sip,a5
    return 2;
    80001cbc:	4509                	li	a0,2
    80001cbe:	bf9d                	j	80001c34 <devintr+0x1e>
      clockintr();
    80001cc0:	00000097          	auipc	ra,0x0
    80001cc4:	f10080e7          	jalr	-240(ra) # 80001bd0 <clockintr>
    80001cc8:	b7ed                	j	80001cb2 <devintr+0x9c>

0000000080001cca <usertrap>:
{
    80001cca:	1101                	addi	sp,sp,-32
    80001ccc:	ec06                	sd	ra,24(sp)
    80001cce:	e822                	sd	s0,16(sp)
    80001cd0:	e426                	sd	s1,8(sp)
    80001cd2:	e04a                	sd	s2,0(sp)
    80001cd4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cd6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001cda:	1007f793          	andi	a5,a5,256
    80001cde:	e3b9                	bnez	a5,80001d24 <usertrap+0x5a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001ce0:	00003797          	auipc	a5,0x3
    80001ce4:	3d078793          	addi	a5,a5,976 # 800050b0 <kernelvec>
    80001ce8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001cec:	fffff097          	auipc	ra,0xfffff
    80001cf0:	1d4080e7          	jalr	468(ra) # 80000ec0 <myproc>
    80001cf4:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001cf6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001cf8:	14102773          	csrr	a4,sepc
    80001cfc:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001cfe:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001d02:	47a1                	li	a5,8
    80001d04:	02f70863          	beq	a4,a5,80001d34 <usertrap+0x6a>
  } else if((which_dev = devintr()) != 0){
    80001d08:	00000097          	auipc	ra,0x0
    80001d0c:	f0e080e7          	jalr	-242(ra) # 80001c16 <devintr>
    80001d10:	892a                	mv	s2,a0
    80001d12:	c551                	beqz	a0,80001d9e <usertrap+0xd4>
  if(lockfree_read4(&p->killed))
    80001d14:	03048513          	addi	a0,s1,48
    80001d18:	00005097          	auipc	ra,0x5
    80001d1c:	56a080e7          	jalr	1386(ra) # 80007282 <lockfree_read4>
    80001d20:	cd21                	beqz	a0,80001d78 <usertrap+0xae>
    80001d22:	a0b1                	j	80001d6e <usertrap+0xa4>
    panic("usertrap: not from user mode");
    80001d24:	00007517          	auipc	a0,0x7
    80001d28:	55c50513          	addi	a0,a0,1372 # 80009280 <states.0+0x50>
    80001d2c:	00005097          	auipc	ra,0x5
    80001d30:	f08080e7          	jalr	-248(ra) # 80006c34 <panic>
    if(lockfree_read4(&p->killed))
    80001d34:	03050513          	addi	a0,a0,48
    80001d38:	00005097          	auipc	ra,0x5
    80001d3c:	54a080e7          	jalr	1354(ra) # 80007282 <lockfree_read4>
    80001d40:	e929                	bnez	a0,80001d92 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80001d42:	6cb8                	ld	a4,88(s1)
    80001d44:	6f1c                	ld	a5,24(a4)
    80001d46:	0791                	addi	a5,a5,4
    80001d48:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d4a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d4e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d52:	10079073          	csrw	sstatus,a5
    syscall();
    80001d56:	00000097          	auipc	ra,0x0
    80001d5a:	2c8080e7          	jalr	712(ra) # 8000201e <syscall>
  if(lockfree_read4(&p->killed))
    80001d5e:	03048513          	addi	a0,s1,48
    80001d62:	00005097          	auipc	ra,0x5
    80001d66:	520080e7          	jalr	1312(ra) # 80007282 <lockfree_read4>
    80001d6a:	c911                	beqz	a0,80001d7e <usertrap+0xb4>
    80001d6c:	4901                	li	s2,0
    exit(-1);
    80001d6e:	557d                	li	a0,-1
    80001d70:	00000097          	auipc	ra,0x0
    80001d74:	81e080e7          	jalr	-2018(ra) # 8000158e <exit>
  if(which_dev == 2)
    80001d78:	4789                	li	a5,2
    80001d7a:	04f90c63          	beq	s2,a5,80001dd2 <usertrap+0x108>
  usertrapret();
    80001d7e:	00000097          	auipc	ra,0x0
    80001d82:	db4080e7          	jalr	-588(ra) # 80001b32 <usertrapret>
}
    80001d86:	60e2                	ld	ra,24(sp)
    80001d88:	6442                	ld	s0,16(sp)
    80001d8a:	64a2                	ld	s1,8(sp)
    80001d8c:	6902                	ld	s2,0(sp)
    80001d8e:	6105                	addi	sp,sp,32
    80001d90:	8082                	ret
      exit(-1);
    80001d92:	557d                	li	a0,-1
    80001d94:	fffff097          	auipc	ra,0xfffff
    80001d98:	7fa080e7          	jalr	2042(ra) # 8000158e <exit>
    80001d9c:	b75d                	j	80001d42 <usertrap+0x78>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d9e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80001da2:	5c90                	lw	a2,56(s1)
    80001da4:	00007517          	auipc	a0,0x7
    80001da8:	4fc50513          	addi	a0,a0,1276 # 800092a0 <states.0+0x70>
    80001dac:	00005097          	auipc	ra,0x5
    80001db0:	ed2080e7          	jalr	-302(ra) # 80006c7e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001db4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001db8:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001dbc:	00007517          	auipc	a0,0x7
    80001dc0:	51450513          	addi	a0,a0,1300 # 800092d0 <states.0+0xa0>
    80001dc4:	00005097          	auipc	ra,0x5
    80001dc8:	eba080e7          	jalr	-326(ra) # 80006c7e <printf>
    p->killed = 1;
    80001dcc:	4785                	li	a5,1
    80001dce:	d89c                	sw	a5,48(s1)
    80001dd0:	b779                	j	80001d5e <usertrap+0x94>
    yield();
    80001dd2:	00000097          	auipc	ra,0x0
    80001dd6:	8c6080e7          	jalr	-1850(ra) # 80001698 <yield>
    80001dda:	b755                	j	80001d7e <usertrap+0xb4>

0000000080001ddc <kerneltrap>:
{
    80001ddc:	7179                	addi	sp,sp,-48
    80001dde:	f406                	sd	ra,40(sp)
    80001de0:	f022                	sd	s0,32(sp)
    80001de2:	ec26                	sd	s1,24(sp)
    80001de4:	e84a                	sd	s2,16(sp)
    80001de6:	e44e                	sd	s3,8(sp)
    80001de8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001dea:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dee:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001df2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001df6:	1004f793          	andi	a5,s1,256
    80001dfa:	cb85                	beqz	a5,80001e2a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dfc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e00:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001e02:	ef85                	bnez	a5,80001e3a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80001e04:	00000097          	auipc	ra,0x0
    80001e08:	e12080e7          	jalr	-494(ra) # 80001c16 <devintr>
    80001e0c:	cd1d                	beqz	a0,80001e4a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001e0e:	4789                	li	a5,2
    80001e10:	06f50a63          	beq	a0,a5,80001e84 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001e14:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e18:	10049073          	csrw	sstatus,s1
}
    80001e1c:	70a2                	ld	ra,40(sp)
    80001e1e:	7402                	ld	s0,32(sp)
    80001e20:	64e2                	ld	s1,24(sp)
    80001e22:	6942                	ld	s2,16(sp)
    80001e24:	69a2                	ld	s3,8(sp)
    80001e26:	6145                	addi	sp,sp,48
    80001e28:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001e2a:	00007517          	auipc	a0,0x7
    80001e2e:	4c650513          	addi	a0,a0,1222 # 800092f0 <states.0+0xc0>
    80001e32:	00005097          	auipc	ra,0x5
    80001e36:	e02080e7          	jalr	-510(ra) # 80006c34 <panic>
    panic("kerneltrap: interrupts enabled");
    80001e3a:	00007517          	auipc	a0,0x7
    80001e3e:	4de50513          	addi	a0,a0,1246 # 80009318 <states.0+0xe8>
    80001e42:	00005097          	auipc	ra,0x5
    80001e46:	df2080e7          	jalr	-526(ra) # 80006c34 <panic>
    printf("scause %p\n", scause);
    80001e4a:	85ce                	mv	a1,s3
    80001e4c:	00007517          	auipc	a0,0x7
    80001e50:	4ec50513          	addi	a0,a0,1260 # 80009338 <states.0+0x108>
    80001e54:	00005097          	auipc	ra,0x5
    80001e58:	e2a080e7          	jalr	-470(ra) # 80006c7e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e5c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e60:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001e64:	00007517          	auipc	a0,0x7
    80001e68:	4e450513          	addi	a0,a0,1252 # 80009348 <states.0+0x118>
    80001e6c:	00005097          	auipc	ra,0x5
    80001e70:	e12080e7          	jalr	-494(ra) # 80006c7e <printf>
    panic("kerneltrap");
    80001e74:	00007517          	auipc	a0,0x7
    80001e78:	4ec50513          	addi	a0,a0,1260 # 80009360 <states.0+0x130>
    80001e7c:	00005097          	auipc	ra,0x5
    80001e80:	db8080e7          	jalr	-584(ra) # 80006c34 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001e84:	fffff097          	auipc	ra,0xfffff
    80001e88:	03c080e7          	jalr	60(ra) # 80000ec0 <myproc>
    80001e8c:	d541                	beqz	a0,80001e14 <kerneltrap+0x38>
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	032080e7          	jalr	50(ra) # 80000ec0 <myproc>
    80001e96:	4d18                	lw	a4,24(a0)
    80001e98:	478d                	li	a5,3
    80001e9a:	f6f71de3          	bne	a4,a5,80001e14 <kerneltrap+0x38>
    yield();
    80001e9e:	fffff097          	auipc	ra,0xfffff
    80001ea2:	7fa080e7          	jalr	2042(ra) # 80001698 <yield>
    80001ea6:	b7bd                	j	80001e14 <kerneltrap+0x38>

0000000080001ea8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001ea8:	1101                	addi	sp,sp,-32
    80001eaa:	ec06                	sd	ra,24(sp)
    80001eac:	e822                	sd	s0,16(sp)
    80001eae:	e426                	sd	s1,8(sp)
    80001eb0:	1000                	addi	s0,sp,32
    80001eb2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001eb4:	fffff097          	auipc	ra,0xfffff
    80001eb8:	00c080e7          	jalr	12(ra) # 80000ec0 <myproc>
  switch (n) {
    80001ebc:	4795                	li	a5,5
    80001ebe:	0497e163          	bltu	a5,s1,80001f00 <argraw+0x58>
    80001ec2:	048a                	slli	s1,s1,0x2
    80001ec4:	00007717          	auipc	a4,0x7
    80001ec8:	4d470713          	addi	a4,a4,1236 # 80009398 <states.0+0x168>
    80001ecc:	94ba                	add	s1,s1,a4
    80001ece:	409c                	lw	a5,0(s1)
    80001ed0:	97ba                	add	a5,a5,a4
    80001ed2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001ed4:	6d3c                	ld	a5,88(a0)
    80001ed6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001ed8:	60e2                	ld	ra,24(sp)
    80001eda:	6442                	ld	s0,16(sp)
    80001edc:	64a2                	ld	s1,8(sp)
    80001ede:	6105                	addi	sp,sp,32
    80001ee0:	8082                	ret
    return p->trapframe->a1;
    80001ee2:	6d3c                	ld	a5,88(a0)
    80001ee4:	7fa8                	ld	a0,120(a5)
    80001ee6:	bfcd                	j	80001ed8 <argraw+0x30>
    return p->trapframe->a2;
    80001ee8:	6d3c                	ld	a5,88(a0)
    80001eea:	63c8                	ld	a0,128(a5)
    80001eec:	b7f5                	j	80001ed8 <argraw+0x30>
    return p->trapframe->a3;
    80001eee:	6d3c                	ld	a5,88(a0)
    80001ef0:	67c8                	ld	a0,136(a5)
    80001ef2:	b7dd                	j	80001ed8 <argraw+0x30>
    return p->trapframe->a4;
    80001ef4:	6d3c                	ld	a5,88(a0)
    80001ef6:	6bc8                	ld	a0,144(a5)
    80001ef8:	b7c5                	j	80001ed8 <argraw+0x30>
    return p->trapframe->a5;
    80001efa:	6d3c                	ld	a5,88(a0)
    80001efc:	6fc8                	ld	a0,152(a5)
    80001efe:	bfe9                	j	80001ed8 <argraw+0x30>
  panic("argraw");
    80001f00:	00007517          	auipc	a0,0x7
    80001f04:	47050513          	addi	a0,a0,1136 # 80009370 <states.0+0x140>
    80001f08:	00005097          	auipc	ra,0x5
    80001f0c:	d2c080e7          	jalr	-724(ra) # 80006c34 <panic>

0000000080001f10 <fetchaddr>:
{
    80001f10:	1101                	addi	sp,sp,-32
    80001f12:	ec06                	sd	ra,24(sp)
    80001f14:	e822                	sd	s0,16(sp)
    80001f16:	e426                	sd	s1,8(sp)
    80001f18:	e04a                	sd	s2,0(sp)
    80001f1a:	1000                	addi	s0,sp,32
    80001f1c:	84aa                	mv	s1,a0
    80001f1e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	fa0080e7          	jalr	-96(ra) # 80000ec0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80001f28:	653c                	ld	a5,72(a0)
    80001f2a:	02f4f863          	bgeu	s1,a5,80001f5a <fetchaddr+0x4a>
    80001f2e:	00848713          	addi	a4,s1,8
    80001f32:	02e7e663          	bltu	a5,a4,80001f5e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001f36:	46a1                	li	a3,8
    80001f38:	8626                	mv	a2,s1
    80001f3a:	85ca                	mv	a1,s2
    80001f3c:	6928                	ld	a0,80(a0)
    80001f3e:	fffff097          	auipc	ra,0xfffff
    80001f42:	ca2080e7          	jalr	-862(ra) # 80000be0 <copyin>
    80001f46:	00a03533          	snez	a0,a0
    80001f4a:	40a00533          	neg	a0,a0
}
    80001f4e:	60e2                	ld	ra,24(sp)
    80001f50:	6442                	ld	s0,16(sp)
    80001f52:	64a2                	ld	s1,8(sp)
    80001f54:	6902                	ld	s2,0(sp)
    80001f56:	6105                	addi	sp,sp,32
    80001f58:	8082                	ret
    return -1;
    80001f5a:	557d                	li	a0,-1
    80001f5c:	bfcd                	j	80001f4e <fetchaddr+0x3e>
    80001f5e:	557d                	li	a0,-1
    80001f60:	b7fd                	j	80001f4e <fetchaddr+0x3e>

0000000080001f62 <fetchstr>:
{
    80001f62:	7179                	addi	sp,sp,-48
    80001f64:	f406                	sd	ra,40(sp)
    80001f66:	f022                	sd	s0,32(sp)
    80001f68:	ec26                	sd	s1,24(sp)
    80001f6a:	e84a                	sd	s2,16(sp)
    80001f6c:	e44e                	sd	s3,8(sp)
    80001f6e:	1800                	addi	s0,sp,48
    80001f70:	892a                	mv	s2,a0
    80001f72:	84ae                	mv	s1,a1
    80001f74:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001f76:	fffff097          	auipc	ra,0xfffff
    80001f7a:	f4a080e7          	jalr	-182(ra) # 80000ec0 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80001f7e:	86ce                	mv	a3,s3
    80001f80:	864a                	mv	a2,s2
    80001f82:	85a6                	mv	a1,s1
    80001f84:	6928                	ld	a0,80(a0)
    80001f86:	fffff097          	auipc	ra,0xfffff
    80001f8a:	ce8080e7          	jalr	-792(ra) # 80000c6e <copyinstr>
  if(err < 0)
    80001f8e:	00054763          	bltz	a0,80001f9c <fetchstr+0x3a>
  return strlen(buf);
    80001f92:	8526                	mv	a0,s1
    80001f94:	ffffe097          	auipc	ra,0xffffe
    80001f98:	368080e7          	jalr	872(ra) # 800002fc <strlen>
}
    80001f9c:	70a2                	ld	ra,40(sp)
    80001f9e:	7402                	ld	s0,32(sp)
    80001fa0:	64e2                	ld	s1,24(sp)
    80001fa2:	6942                	ld	s2,16(sp)
    80001fa4:	69a2                	ld	s3,8(sp)
    80001fa6:	6145                	addi	sp,sp,48
    80001fa8:	8082                	ret

0000000080001faa <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80001faa:	1101                	addi	sp,sp,-32
    80001fac:	ec06                	sd	ra,24(sp)
    80001fae:	e822                	sd	s0,16(sp)
    80001fb0:	e426                	sd	s1,8(sp)
    80001fb2:	1000                	addi	s0,sp,32
    80001fb4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001fb6:	00000097          	auipc	ra,0x0
    80001fba:	ef2080e7          	jalr	-270(ra) # 80001ea8 <argraw>
    80001fbe:	c088                	sw	a0,0(s1)
  return 0;
}
    80001fc0:	4501                	li	a0,0
    80001fc2:	60e2                	ld	ra,24(sp)
    80001fc4:	6442                	ld	s0,16(sp)
    80001fc6:	64a2                	ld	s1,8(sp)
    80001fc8:	6105                	addi	sp,sp,32
    80001fca:	8082                	ret

0000000080001fcc <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80001fcc:	1101                	addi	sp,sp,-32
    80001fce:	ec06                	sd	ra,24(sp)
    80001fd0:	e822                	sd	s0,16(sp)
    80001fd2:	e426                	sd	s1,8(sp)
    80001fd4:	1000                	addi	s0,sp,32
    80001fd6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001fd8:	00000097          	auipc	ra,0x0
    80001fdc:	ed0080e7          	jalr	-304(ra) # 80001ea8 <argraw>
    80001fe0:	e088                	sd	a0,0(s1)
  return 0;
}
    80001fe2:	4501                	li	a0,0
    80001fe4:	60e2                	ld	ra,24(sp)
    80001fe6:	6442                	ld	s0,16(sp)
    80001fe8:	64a2                	ld	s1,8(sp)
    80001fea:	6105                	addi	sp,sp,32
    80001fec:	8082                	ret

0000000080001fee <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001fee:	1101                	addi	sp,sp,-32
    80001ff0:	ec06                	sd	ra,24(sp)
    80001ff2:	e822                	sd	s0,16(sp)
    80001ff4:	e426                	sd	s1,8(sp)
    80001ff6:	e04a                	sd	s2,0(sp)
    80001ff8:	1000                	addi	s0,sp,32
    80001ffa:	84ae                	mv	s1,a1
    80001ffc:	8932                	mv	s2,a2
  *ip = argraw(n);
    80001ffe:	00000097          	auipc	ra,0x0
    80002002:	eaa080e7          	jalr	-342(ra) # 80001ea8 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002006:	864a                	mv	a2,s2
    80002008:	85a6                	mv	a1,s1
    8000200a:	00000097          	auipc	ra,0x0
    8000200e:	f58080e7          	jalr	-168(ra) # 80001f62 <fetchstr>
}
    80002012:	60e2                	ld	ra,24(sp)
    80002014:	6442                	ld	s0,16(sp)
    80002016:	64a2                	ld	s1,8(sp)
    80002018:	6902                	ld	s2,0(sp)
    8000201a:	6105                	addi	sp,sp,32
    8000201c:	8082                	ret

000000008000201e <syscall>:



void
syscall(void)
{
    8000201e:	1101                	addi	sp,sp,-32
    80002020:	ec06                	sd	ra,24(sp)
    80002022:	e822                	sd	s0,16(sp)
    80002024:	e426                	sd	s1,8(sp)
    80002026:	e04a                	sd	s2,0(sp)
    80002028:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000202a:	fffff097          	auipc	ra,0xfffff
    8000202e:	e96080e7          	jalr	-362(ra) # 80000ec0 <myproc>
    80002032:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002034:	05853903          	ld	s2,88(a0)
    80002038:	0a893783          	ld	a5,168(s2)
    8000203c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002040:	37fd                	addiw	a5,a5,-1
    80002042:	4771                	li	a4,28
    80002044:	00f76f63          	bltu	a4,a5,80002062 <syscall+0x44>
    80002048:	00369713          	slli	a4,a3,0x3
    8000204c:	00007797          	auipc	a5,0x7
    80002050:	36478793          	addi	a5,a5,868 # 800093b0 <syscalls>
    80002054:	97ba                	add	a5,a5,a4
    80002056:	639c                	ld	a5,0(a5)
    80002058:	c789                	beqz	a5,80002062 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    8000205a:	9782                	jalr	a5
    8000205c:	06a93823          	sd	a0,112(s2)
    80002060:	a839                	j	8000207e <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002062:	15848613          	addi	a2,s1,344
    80002066:	5c8c                	lw	a1,56(s1)
    80002068:	00007517          	auipc	a0,0x7
    8000206c:	31050513          	addi	a0,a0,784 # 80009378 <states.0+0x148>
    80002070:	00005097          	auipc	ra,0x5
    80002074:	c0e080e7          	jalr	-1010(ra) # 80006c7e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002078:	6cbc                	ld	a5,88(s1)
    8000207a:	577d                	li	a4,-1
    8000207c:	fbb8                	sd	a4,112(a5)
  }
}
    8000207e:	60e2                	ld	ra,24(sp)
    80002080:	6442                	ld	s0,16(sp)
    80002082:	64a2                	ld	s1,8(sp)
    80002084:	6902                	ld	s2,0(sp)
    80002086:	6105                	addi	sp,sp,32
    80002088:	8082                	ret

000000008000208a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000208a:	1101                	addi	sp,sp,-32
    8000208c:	ec06                	sd	ra,24(sp)
    8000208e:	e822                	sd	s0,16(sp)
    80002090:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002092:	fec40593          	addi	a1,s0,-20
    80002096:	4501                	li	a0,0
    80002098:	00000097          	auipc	ra,0x0
    8000209c:	f12080e7          	jalr	-238(ra) # 80001faa <argint>
    return -1;
    800020a0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800020a2:	00054963          	bltz	a0,800020b4 <sys_exit+0x2a>
  exit(n);
    800020a6:	fec42503          	lw	a0,-20(s0)
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	4e4080e7          	jalr	1252(ra) # 8000158e <exit>
  return 0;  // not reached
    800020b2:	4781                	li	a5,0
}
    800020b4:	853e                	mv	a0,a5
    800020b6:	60e2                	ld	ra,24(sp)
    800020b8:	6442                	ld	s0,16(sp)
    800020ba:	6105                	addi	sp,sp,32
    800020bc:	8082                	ret

00000000800020be <sys_getpid>:

uint64
sys_getpid(void)
{
    800020be:	1141                	addi	sp,sp,-16
    800020c0:	e406                	sd	ra,8(sp)
    800020c2:	e022                	sd	s0,0(sp)
    800020c4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800020c6:	fffff097          	auipc	ra,0xfffff
    800020ca:	dfa080e7          	jalr	-518(ra) # 80000ec0 <myproc>
}
    800020ce:	5d08                	lw	a0,56(a0)
    800020d0:	60a2                	ld	ra,8(sp)
    800020d2:	6402                	ld	s0,0(sp)
    800020d4:	0141                	addi	sp,sp,16
    800020d6:	8082                	ret

00000000800020d8 <sys_fork>:

uint64
sys_fork(void)
{
    800020d8:	1141                	addi	sp,sp,-16
    800020da:	e406                	sd	ra,8(sp)
    800020dc:	e022                	sd	s0,0(sp)
    800020de:	0800                	addi	s0,sp,16
  return fork();
    800020e0:	fffff097          	auipc	ra,0xfffff
    800020e4:	1a0080e7          	jalr	416(ra) # 80001280 <fork>
}
    800020e8:	60a2                	ld	ra,8(sp)
    800020ea:	6402                	ld	s0,0(sp)
    800020ec:	0141                	addi	sp,sp,16
    800020ee:	8082                	ret

00000000800020f0 <sys_wait>:

uint64
sys_wait(void)
{
    800020f0:	1101                	addi	sp,sp,-32
    800020f2:	ec06                	sd	ra,24(sp)
    800020f4:	e822                	sd	s0,16(sp)
    800020f6:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800020f8:	fe840593          	addi	a1,s0,-24
    800020fc:	4501                	li	a0,0
    800020fe:	00000097          	auipc	ra,0x0
    80002102:	ece080e7          	jalr	-306(ra) # 80001fcc <argaddr>
    80002106:	87aa                	mv	a5,a0
    return -1;
    80002108:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    8000210a:	0007c863          	bltz	a5,8000211a <sys_wait+0x2a>
  return wait(p);
    8000210e:	fe843503          	ld	a0,-24(s0)
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	640080e7          	jalr	1600(ra) # 80001752 <wait>
}
    8000211a:	60e2                	ld	ra,24(sp)
    8000211c:	6442                	ld	s0,16(sp)
    8000211e:	6105                	addi	sp,sp,32
    80002120:	8082                	ret

0000000080002122 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002122:	7179                	addi	sp,sp,-48
    80002124:	f406                	sd	ra,40(sp)
    80002126:	f022                	sd	s0,32(sp)
    80002128:	ec26                	sd	s1,24(sp)
    8000212a:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000212c:	fdc40593          	addi	a1,s0,-36
    80002130:	4501                	li	a0,0
    80002132:	00000097          	auipc	ra,0x0
    80002136:	e78080e7          	jalr	-392(ra) # 80001faa <argint>
    return -1;
    8000213a:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    8000213c:	00054f63          	bltz	a0,8000215a <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	d80080e7          	jalr	-640(ra) # 80000ec0 <myproc>
    80002148:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    8000214a:	fdc42503          	lw	a0,-36(s0)
    8000214e:	fffff097          	auipc	ra,0xfffff
    80002152:	0be080e7          	jalr	190(ra) # 8000120c <growproc>
    80002156:	00054863          	bltz	a0,80002166 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    8000215a:	8526                	mv	a0,s1
    8000215c:	70a2                	ld	ra,40(sp)
    8000215e:	7402                	ld	s0,32(sp)
    80002160:	64e2                	ld	s1,24(sp)
    80002162:	6145                	addi	sp,sp,48
    80002164:	8082                	ret
    return -1;
    80002166:	54fd                	li	s1,-1
    80002168:	bfcd                	j	8000215a <sys_sbrk+0x38>

000000008000216a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000216a:	7139                	addi	sp,sp,-64
    8000216c:	fc06                	sd	ra,56(sp)
    8000216e:	f822                	sd	s0,48(sp)
    80002170:	f426                	sd	s1,40(sp)
    80002172:	f04a                	sd	s2,32(sp)
    80002174:	ec4e                	sd	s3,24(sp)
    80002176:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002178:	fcc40593          	addi	a1,s0,-52
    8000217c:	4501                	li	a0,0
    8000217e:	00000097          	auipc	ra,0x0
    80002182:	e2c080e7          	jalr	-468(ra) # 80001faa <argint>
    return -1;
    80002186:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002188:	06054563          	bltz	a0,800021f2 <sys_sleep+0x88>
  acquire(&tickslock);
    8000218c:	0000e517          	auipc	a0,0xe
    80002190:	cfc50513          	addi	a0,a0,-772 # 8000fe88 <tickslock>
    80002194:	00005097          	auipc	ra,0x5
    80002198:	fdc080e7          	jalr	-36(ra) # 80007170 <acquire>
  ticks0 = ticks;
    8000219c:	00008917          	auipc	s2,0x8
    800021a0:	e7c92903          	lw	s2,-388(s2) # 8000a018 <ticks>
  while(ticks - ticks0 < n){
    800021a4:	fcc42783          	lw	a5,-52(s0)
    800021a8:	cf85                	beqz	a5,800021e0 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800021aa:	0000e997          	auipc	s3,0xe
    800021ae:	cde98993          	addi	s3,s3,-802 # 8000fe88 <tickslock>
    800021b2:	00008497          	auipc	s1,0x8
    800021b6:	e6648493          	addi	s1,s1,-410 # 8000a018 <ticks>
    if(myproc()->killed){
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	d06080e7          	jalr	-762(ra) # 80000ec0 <myproc>
    800021c2:	591c                	lw	a5,48(a0)
    800021c4:	ef9d                	bnez	a5,80002202 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800021c6:	85ce                	mv	a1,s3
    800021c8:	8526                	mv	a0,s1
    800021ca:	fffff097          	auipc	ra,0xfffff
    800021ce:	50a080e7          	jalr	1290(ra) # 800016d4 <sleep>
  while(ticks - ticks0 < n){
    800021d2:	409c                	lw	a5,0(s1)
    800021d4:	412787bb          	subw	a5,a5,s2
    800021d8:	fcc42703          	lw	a4,-52(s0)
    800021dc:	fce7efe3          	bltu	a5,a4,800021ba <sys_sleep+0x50>
  }
  release(&tickslock);
    800021e0:	0000e517          	auipc	a0,0xe
    800021e4:	ca850513          	addi	a0,a0,-856 # 8000fe88 <tickslock>
    800021e8:	00005097          	auipc	ra,0x5
    800021ec:	03c080e7          	jalr	60(ra) # 80007224 <release>
  return 0;
    800021f0:	4781                	li	a5,0
}
    800021f2:	853e                	mv	a0,a5
    800021f4:	70e2                	ld	ra,56(sp)
    800021f6:	7442                	ld	s0,48(sp)
    800021f8:	74a2                	ld	s1,40(sp)
    800021fa:	7902                	ld	s2,32(sp)
    800021fc:	69e2                	ld	s3,24(sp)
    800021fe:	6121                	addi	sp,sp,64
    80002200:	8082                	ret
      release(&tickslock);
    80002202:	0000e517          	auipc	a0,0xe
    80002206:	c8650513          	addi	a0,a0,-890 # 8000fe88 <tickslock>
    8000220a:	00005097          	auipc	ra,0x5
    8000220e:	01a080e7          	jalr	26(ra) # 80007224 <release>
      return -1;
    80002212:	57fd                	li	a5,-1
    80002214:	bff9                	j	800021f2 <sys_sleep+0x88>

0000000080002216 <sys_kill>:

uint64
sys_kill(void)
{
    80002216:	1101                	addi	sp,sp,-32
    80002218:	ec06                	sd	ra,24(sp)
    8000221a:	e822                	sd	s0,16(sp)
    8000221c:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000221e:	fec40593          	addi	a1,s0,-20
    80002222:	4501                	li	a0,0
    80002224:	00000097          	auipc	ra,0x0
    80002228:	d86080e7          	jalr	-634(ra) # 80001faa <argint>
    8000222c:	87aa                	mv	a5,a0
    return -1;
    8000222e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002230:	0007c863          	bltz	a5,80002240 <sys_kill+0x2a>
  return kill(pid);
    80002234:	fec42503          	lw	a0,-20(s0)
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	686080e7          	jalr	1670(ra) # 800018be <kill>
}
    80002240:	60e2                	ld	ra,24(sp)
    80002242:	6442                	ld	s0,16(sp)
    80002244:	6105                	addi	sp,sp,32
    80002246:	8082                	ret

0000000080002248 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002248:	1101                	addi	sp,sp,-32
    8000224a:	ec06                	sd	ra,24(sp)
    8000224c:	e822                	sd	s0,16(sp)
    8000224e:	e426                	sd	s1,8(sp)
    80002250:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002252:	0000e517          	auipc	a0,0xe
    80002256:	c3650513          	addi	a0,a0,-970 # 8000fe88 <tickslock>
    8000225a:	00005097          	auipc	ra,0x5
    8000225e:	f16080e7          	jalr	-234(ra) # 80007170 <acquire>
  xticks = ticks;
    80002262:	00008497          	auipc	s1,0x8
    80002266:	db64a483          	lw	s1,-586(s1) # 8000a018 <ticks>
  release(&tickslock);
    8000226a:	0000e517          	auipc	a0,0xe
    8000226e:	c1e50513          	addi	a0,a0,-994 # 8000fe88 <tickslock>
    80002272:	00005097          	auipc	ra,0x5
    80002276:	fb2080e7          	jalr	-78(ra) # 80007224 <release>
  return xticks;
}
    8000227a:	02049513          	slli	a0,s1,0x20
    8000227e:	9101                	srli	a0,a0,0x20
    80002280:	60e2                	ld	ra,24(sp)
    80002282:	6442                	ld	s0,16(sp)
    80002284:	64a2                	ld	s1,8(sp)
    80002286:	6105                	addi	sp,sp,32
    80002288:	8082                	ret

000000008000228a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000228a:	7179                	addi	sp,sp,-48
    8000228c:	f406                	sd	ra,40(sp)
    8000228e:	f022                	sd	s0,32(sp)
    80002290:	ec26                	sd	s1,24(sp)
    80002292:	e84a                	sd	s2,16(sp)
    80002294:	e44e                	sd	s3,8(sp)
    80002296:	e052                	sd	s4,0(sp)
    80002298:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000229a:	00007597          	auipc	a1,0x7
    8000229e:	20658593          	addi	a1,a1,518 # 800094a0 <syscalls+0xf0>
    800022a2:	0000e517          	auipc	a0,0xe
    800022a6:	bfe50513          	addi	a0,a0,-1026 # 8000fea0 <bcache>
    800022aa:	00005097          	auipc	ra,0x5
    800022ae:	e36080e7          	jalr	-458(ra) # 800070e0 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800022b2:	00016797          	auipc	a5,0x16
    800022b6:	bee78793          	addi	a5,a5,-1042 # 80017ea0 <bcache+0x8000>
    800022ba:	00016717          	auipc	a4,0x16
    800022be:	e4e70713          	addi	a4,a4,-434 # 80018108 <bcache+0x8268>
    800022c2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800022c6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800022ca:	0000e497          	auipc	s1,0xe
    800022ce:	bee48493          	addi	s1,s1,-1042 # 8000feb8 <bcache+0x18>
    b->next = bcache.head.next;
    800022d2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800022d4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800022d6:	00007a17          	auipc	s4,0x7
    800022da:	1d2a0a13          	addi	s4,s4,466 # 800094a8 <syscalls+0xf8>
    b->next = bcache.head.next;
    800022de:	2b893783          	ld	a5,696(s2)
    800022e2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800022e4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800022e8:	85d2                	mv	a1,s4
    800022ea:	01048513          	addi	a0,s1,16
    800022ee:	00001097          	auipc	ra,0x1
    800022f2:	4c4080e7          	jalr	1220(ra) # 800037b2 <initsleeplock>
    bcache.head.next->prev = b;
    800022f6:	2b893783          	ld	a5,696(s2)
    800022fa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800022fc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002300:	45848493          	addi	s1,s1,1112
    80002304:	fd349de3          	bne	s1,s3,800022de <binit+0x54>
  }
}
    80002308:	70a2                	ld	ra,40(sp)
    8000230a:	7402                	ld	s0,32(sp)
    8000230c:	64e2                	ld	s1,24(sp)
    8000230e:	6942                	ld	s2,16(sp)
    80002310:	69a2                	ld	s3,8(sp)
    80002312:	6a02                	ld	s4,0(sp)
    80002314:	6145                	addi	sp,sp,48
    80002316:	8082                	ret

0000000080002318 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002318:	7179                	addi	sp,sp,-48
    8000231a:	f406                	sd	ra,40(sp)
    8000231c:	f022                	sd	s0,32(sp)
    8000231e:	ec26                	sd	s1,24(sp)
    80002320:	e84a                	sd	s2,16(sp)
    80002322:	e44e                	sd	s3,8(sp)
    80002324:	1800                	addi	s0,sp,48
    80002326:	892a                	mv	s2,a0
    80002328:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000232a:	0000e517          	auipc	a0,0xe
    8000232e:	b7650513          	addi	a0,a0,-1162 # 8000fea0 <bcache>
    80002332:	00005097          	auipc	ra,0x5
    80002336:	e3e080e7          	jalr	-450(ra) # 80007170 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000233a:	00016497          	auipc	s1,0x16
    8000233e:	e1e4b483          	ld	s1,-482(s1) # 80018158 <bcache+0x82b8>
    80002342:	00016797          	auipc	a5,0x16
    80002346:	dc678793          	addi	a5,a5,-570 # 80018108 <bcache+0x8268>
    8000234a:	02f48f63          	beq	s1,a5,80002388 <bread+0x70>
    8000234e:	873e                	mv	a4,a5
    80002350:	a021                	j	80002358 <bread+0x40>
    80002352:	68a4                	ld	s1,80(s1)
    80002354:	02e48a63          	beq	s1,a4,80002388 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002358:	449c                	lw	a5,8(s1)
    8000235a:	ff279ce3          	bne	a5,s2,80002352 <bread+0x3a>
    8000235e:	44dc                	lw	a5,12(s1)
    80002360:	ff3799e3          	bne	a5,s3,80002352 <bread+0x3a>
      b->refcnt++;
    80002364:	40bc                	lw	a5,64(s1)
    80002366:	2785                	addiw	a5,a5,1
    80002368:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000236a:	0000e517          	auipc	a0,0xe
    8000236e:	b3650513          	addi	a0,a0,-1226 # 8000fea0 <bcache>
    80002372:	00005097          	auipc	ra,0x5
    80002376:	eb2080e7          	jalr	-334(ra) # 80007224 <release>
      acquiresleep(&b->lock);
    8000237a:	01048513          	addi	a0,s1,16
    8000237e:	00001097          	auipc	ra,0x1
    80002382:	46e080e7          	jalr	1134(ra) # 800037ec <acquiresleep>
      return b;
    80002386:	a8b9                	j	800023e4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002388:	00016497          	auipc	s1,0x16
    8000238c:	dc84b483          	ld	s1,-568(s1) # 80018150 <bcache+0x82b0>
    80002390:	00016797          	auipc	a5,0x16
    80002394:	d7878793          	addi	a5,a5,-648 # 80018108 <bcache+0x8268>
    80002398:	00f48863          	beq	s1,a5,800023a8 <bread+0x90>
    8000239c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000239e:	40bc                	lw	a5,64(s1)
    800023a0:	cf81                	beqz	a5,800023b8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800023a2:	64a4                	ld	s1,72(s1)
    800023a4:	fee49de3          	bne	s1,a4,8000239e <bread+0x86>
  panic("bget: no buffers");
    800023a8:	00007517          	auipc	a0,0x7
    800023ac:	10850513          	addi	a0,a0,264 # 800094b0 <syscalls+0x100>
    800023b0:	00005097          	auipc	ra,0x5
    800023b4:	884080e7          	jalr	-1916(ra) # 80006c34 <panic>
      b->dev = dev;
    800023b8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800023bc:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800023c0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800023c4:	4785                	li	a5,1
    800023c6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800023c8:	0000e517          	auipc	a0,0xe
    800023cc:	ad850513          	addi	a0,a0,-1320 # 8000fea0 <bcache>
    800023d0:	00005097          	auipc	ra,0x5
    800023d4:	e54080e7          	jalr	-428(ra) # 80007224 <release>
      acquiresleep(&b->lock);
    800023d8:	01048513          	addi	a0,s1,16
    800023dc:	00001097          	auipc	ra,0x1
    800023e0:	410080e7          	jalr	1040(ra) # 800037ec <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800023e4:	409c                	lw	a5,0(s1)
    800023e6:	cb89                	beqz	a5,800023f8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800023e8:	8526                	mv	a0,s1
    800023ea:	70a2                	ld	ra,40(sp)
    800023ec:	7402                	ld	s0,32(sp)
    800023ee:	64e2                	ld	s1,24(sp)
    800023f0:	6942                	ld	s2,16(sp)
    800023f2:	69a2                	ld	s3,8(sp)
    800023f4:	6145                	addi	sp,sp,48
    800023f6:	8082                	ret
    virtio_disk_rw(b, 0);
    800023f8:	4581                	li	a1,0
    800023fa:	8526                	mv	a0,s1
    800023fc:	00003097          	auipc	ra,0x3
    80002400:	004080e7          	jalr	4(ra) # 80005400 <virtio_disk_rw>
    b->valid = 1;
    80002404:	4785                	li	a5,1
    80002406:	c09c                	sw	a5,0(s1)
  return b;
    80002408:	b7c5                	j	800023e8 <bread+0xd0>

000000008000240a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000240a:	1101                	addi	sp,sp,-32
    8000240c:	ec06                	sd	ra,24(sp)
    8000240e:	e822                	sd	s0,16(sp)
    80002410:	e426                	sd	s1,8(sp)
    80002412:	1000                	addi	s0,sp,32
    80002414:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002416:	0541                	addi	a0,a0,16
    80002418:	00001097          	auipc	ra,0x1
    8000241c:	46e080e7          	jalr	1134(ra) # 80003886 <holdingsleep>
    80002420:	cd01                	beqz	a0,80002438 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002422:	4585                	li	a1,1
    80002424:	8526                	mv	a0,s1
    80002426:	00003097          	auipc	ra,0x3
    8000242a:	fda080e7          	jalr	-38(ra) # 80005400 <virtio_disk_rw>
}
    8000242e:	60e2                	ld	ra,24(sp)
    80002430:	6442                	ld	s0,16(sp)
    80002432:	64a2                	ld	s1,8(sp)
    80002434:	6105                	addi	sp,sp,32
    80002436:	8082                	ret
    panic("bwrite");
    80002438:	00007517          	auipc	a0,0x7
    8000243c:	09050513          	addi	a0,a0,144 # 800094c8 <syscalls+0x118>
    80002440:	00004097          	auipc	ra,0x4
    80002444:	7f4080e7          	jalr	2036(ra) # 80006c34 <panic>

0000000080002448 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002448:	1101                	addi	sp,sp,-32
    8000244a:	ec06                	sd	ra,24(sp)
    8000244c:	e822                	sd	s0,16(sp)
    8000244e:	e426                	sd	s1,8(sp)
    80002450:	e04a                	sd	s2,0(sp)
    80002452:	1000                	addi	s0,sp,32
    80002454:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002456:	01050913          	addi	s2,a0,16
    8000245a:	854a                	mv	a0,s2
    8000245c:	00001097          	auipc	ra,0x1
    80002460:	42a080e7          	jalr	1066(ra) # 80003886 <holdingsleep>
    80002464:	c92d                	beqz	a0,800024d6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002466:	854a                	mv	a0,s2
    80002468:	00001097          	auipc	ra,0x1
    8000246c:	3da080e7          	jalr	986(ra) # 80003842 <releasesleep>

  acquire(&bcache.lock);
    80002470:	0000e517          	auipc	a0,0xe
    80002474:	a3050513          	addi	a0,a0,-1488 # 8000fea0 <bcache>
    80002478:	00005097          	auipc	ra,0x5
    8000247c:	cf8080e7          	jalr	-776(ra) # 80007170 <acquire>
  b->refcnt--;
    80002480:	40bc                	lw	a5,64(s1)
    80002482:	37fd                	addiw	a5,a5,-1
    80002484:	0007871b          	sext.w	a4,a5
    80002488:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000248a:	eb05                	bnez	a4,800024ba <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000248c:	68bc                	ld	a5,80(s1)
    8000248e:	64b8                	ld	a4,72(s1)
    80002490:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002492:	64bc                	ld	a5,72(s1)
    80002494:	68b8                	ld	a4,80(s1)
    80002496:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002498:	00016797          	auipc	a5,0x16
    8000249c:	a0878793          	addi	a5,a5,-1528 # 80017ea0 <bcache+0x8000>
    800024a0:	2b87b703          	ld	a4,696(a5)
    800024a4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800024a6:	00016717          	auipc	a4,0x16
    800024aa:	c6270713          	addi	a4,a4,-926 # 80018108 <bcache+0x8268>
    800024ae:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800024b0:	2b87b703          	ld	a4,696(a5)
    800024b4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800024b6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800024ba:	0000e517          	auipc	a0,0xe
    800024be:	9e650513          	addi	a0,a0,-1562 # 8000fea0 <bcache>
    800024c2:	00005097          	auipc	ra,0x5
    800024c6:	d62080e7          	jalr	-670(ra) # 80007224 <release>
}
    800024ca:	60e2                	ld	ra,24(sp)
    800024cc:	6442                	ld	s0,16(sp)
    800024ce:	64a2                	ld	s1,8(sp)
    800024d0:	6902                	ld	s2,0(sp)
    800024d2:	6105                	addi	sp,sp,32
    800024d4:	8082                	ret
    panic("brelse");
    800024d6:	00007517          	auipc	a0,0x7
    800024da:	ffa50513          	addi	a0,a0,-6 # 800094d0 <syscalls+0x120>
    800024de:	00004097          	auipc	ra,0x4
    800024e2:	756080e7          	jalr	1878(ra) # 80006c34 <panic>

00000000800024e6 <bpin>:

void
bpin(struct buf *b) {
    800024e6:	1101                	addi	sp,sp,-32
    800024e8:	ec06                	sd	ra,24(sp)
    800024ea:	e822                	sd	s0,16(sp)
    800024ec:	e426                	sd	s1,8(sp)
    800024ee:	1000                	addi	s0,sp,32
    800024f0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800024f2:	0000e517          	auipc	a0,0xe
    800024f6:	9ae50513          	addi	a0,a0,-1618 # 8000fea0 <bcache>
    800024fa:	00005097          	auipc	ra,0x5
    800024fe:	c76080e7          	jalr	-906(ra) # 80007170 <acquire>
  b->refcnt++;
    80002502:	40bc                	lw	a5,64(s1)
    80002504:	2785                	addiw	a5,a5,1
    80002506:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002508:	0000e517          	auipc	a0,0xe
    8000250c:	99850513          	addi	a0,a0,-1640 # 8000fea0 <bcache>
    80002510:	00005097          	auipc	ra,0x5
    80002514:	d14080e7          	jalr	-748(ra) # 80007224 <release>
}
    80002518:	60e2                	ld	ra,24(sp)
    8000251a:	6442                	ld	s0,16(sp)
    8000251c:	64a2                	ld	s1,8(sp)
    8000251e:	6105                	addi	sp,sp,32
    80002520:	8082                	ret

0000000080002522 <bunpin>:

void
bunpin(struct buf *b) {
    80002522:	1101                	addi	sp,sp,-32
    80002524:	ec06                	sd	ra,24(sp)
    80002526:	e822                	sd	s0,16(sp)
    80002528:	e426                	sd	s1,8(sp)
    8000252a:	1000                	addi	s0,sp,32
    8000252c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000252e:	0000e517          	auipc	a0,0xe
    80002532:	97250513          	addi	a0,a0,-1678 # 8000fea0 <bcache>
    80002536:	00005097          	auipc	ra,0x5
    8000253a:	c3a080e7          	jalr	-966(ra) # 80007170 <acquire>
  b->refcnt--;
    8000253e:	40bc                	lw	a5,64(s1)
    80002540:	37fd                	addiw	a5,a5,-1
    80002542:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002544:	0000e517          	auipc	a0,0xe
    80002548:	95c50513          	addi	a0,a0,-1700 # 8000fea0 <bcache>
    8000254c:	00005097          	auipc	ra,0x5
    80002550:	cd8080e7          	jalr	-808(ra) # 80007224 <release>
}
    80002554:	60e2                	ld	ra,24(sp)
    80002556:	6442                	ld	s0,16(sp)
    80002558:	64a2                	ld	s1,8(sp)
    8000255a:	6105                	addi	sp,sp,32
    8000255c:	8082                	ret

000000008000255e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000255e:	1101                	addi	sp,sp,-32
    80002560:	ec06                	sd	ra,24(sp)
    80002562:	e822                	sd	s0,16(sp)
    80002564:	e426                	sd	s1,8(sp)
    80002566:	e04a                	sd	s2,0(sp)
    80002568:	1000                	addi	s0,sp,32
    8000256a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000256c:	00d5d59b          	srliw	a1,a1,0xd
    80002570:	00016797          	auipc	a5,0x16
    80002574:	00c7a783          	lw	a5,12(a5) # 8001857c <sb+0x1c>
    80002578:	9dbd                	addw	a1,a1,a5
    8000257a:	00000097          	auipc	ra,0x0
    8000257e:	d9e080e7          	jalr	-610(ra) # 80002318 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002582:	0074f713          	andi	a4,s1,7
    80002586:	4785                	li	a5,1
    80002588:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000258c:	14ce                	slli	s1,s1,0x33
    8000258e:	90d9                	srli	s1,s1,0x36
    80002590:	00950733          	add	a4,a0,s1
    80002594:	05874703          	lbu	a4,88(a4)
    80002598:	00e7f6b3          	and	a3,a5,a4
    8000259c:	c69d                	beqz	a3,800025ca <bfree+0x6c>
    8000259e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800025a0:	94aa                	add	s1,s1,a0
    800025a2:	fff7c793          	not	a5,a5
    800025a6:	8ff9                	and	a5,a5,a4
    800025a8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800025ac:	00001097          	auipc	ra,0x1
    800025b0:	118080e7          	jalr	280(ra) # 800036c4 <log_write>
  brelse(bp);
    800025b4:	854a                	mv	a0,s2
    800025b6:	00000097          	auipc	ra,0x0
    800025ba:	e92080e7          	jalr	-366(ra) # 80002448 <brelse>
}
    800025be:	60e2                	ld	ra,24(sp)
    800025c0:	6442                	ld	s0,16(sp)
    800025c2:	64a2                	ld	s1,8(sp)
    800025c4:	6902                	ld	s2,0(sp)
    800025c6:	6105                	addi	sp,sp,32
    800025c8:	8082                	ret
    panic("freeing free block");
    800025ca:	00007517          	auipc	a0,0x7
    800025ce:	f0e50513          	addi	a0,a0,-242 # 800094d8 <syscalls+0x128>
    800025d2:	00004097          	auipc	ra,0x4
    800025d6:	662080e7          	jalr	1634(ra) # 80006c34 <panic>

00000000800025da <balloc>:
{
    800025da:	711d                	addi	sp,sp,-96
    800025dc:	ec86                	sd	ra,88(sp)
    800025de:	e8a2                	sd	s0,80(sp)
    800025e0:	e4a6                	sd	s1,72(sp)
    800025e2:	e0ca                	sd	s2,64(sp)
    800025e4:	fc4e                	sd	s3,56(sp)
    800025e6:	f852                	sd	s4,48(sp)
    800025e8:	f456                	sd	s5,40(sp)
    800025ea:	f05a                	sd	s6,32(sp)
    800025ec:	ec5e                	sd	s7,24(sp)
    800025ee:	e862                	sd	s8,16(sp)
    800025f0:	e466                	sd	s9,8(sp)
    800025f2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800025f4:	00016797          	auipc	a5,0x16
    800025f8:	f707a783          	lw	a5,-144(a5) # 80018564 <sb+0x4>
    800025fc:	cbd1                	beqz	a5,80002690 <balloc+0xb6>
    800025fe:	8baa                	mv	s7,a0
    80002600:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002602:	00016b17          	auipc	s6,0x16
    80002606:	f5eb0b13          	addi	s6,s6,-162 # 80018560 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000260a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000260c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000260e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002610:	6c89                	lui	s9,0x2
    80002612:	a831                	j	8000262e <balloc+0x54>
    brelse(bp);
    80002614:	854a                	mv	a0,s2
    80002616:	00000097          	auipc	ra,0x0
    8000261a:	e32080e7          	jalr	-462(ra) # 80002448 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000261e:	015c87bb          	addw	a5,s9,s5
    80002622:	00078a9b          	sext.w	s5,a5
    80002626:	004b2703          	lw	a4,4(s6)
    8000262a:	06eaf363          	bgeu	s5,a4,80002690 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000262e:	41fad79b          	sraiw	a5,s5,0x1f
    80002632:	0137d79b          	srliw	a5,a5,0x13
    80002636:	015787bb          	addw	a5,a5,s5
    8000263a:	40d7d79b          	sraiw	a5,a5,0xd
    8000263e:	01cb2583          	lw	a1,28(s6)
    80002642:	9dbd                	addw	a1,a1,a5
    80002644:	855e                	mv	a0,s7
    80002646:	00000097          	auipc	ra,0x0
    8000264a:	cd2080e7          	jalr	-814(ra) # 80002318 <bread>
    8000264e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002650:	004b2503          	lw	a0,4(s6)
    80002654:	000a849b          	sext.w	s1,s5
    80002658:	8662                	mv	a2,s8
    8000265a:	faa4fde3          	bgeu	s1,a0,80002614 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000265e:	41f6579b          	sraiw	a5,a2,0x1f
    80002662:	01d7d69b          	srliw	a3,a5,0x1d
    80002666:	00c6873b          	addw	a4,a3,a2
    8000266a:	00777793          	andi	a5,a4,7
    8000266e:	9f95                	subw	a5,a5,a3
    80002670:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002674:	4037571b          	sraiw	a4,a4,0x3
    80002678:	00e906b3          	add	a3,s2,a4
    8000267c:	0586c683          	lbu	a3,88(a3)
    80002680:	00d7f5b3          	and	a1,a5,a3
    80002684:	cd91                	beqz	a1,800026a0 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002686:	2605                	addiw	a2,a2,1
    80002688:	2485                	addiw	s1,s1,1
    8000268a:	fd4618e3          	bne	a2,s4,8000265a <balloc+0x80>
    8000268e:	b759                	j	80002614 <balloc+0x3a>
  panic("balloc: out of blocks");
    80002690:	00007517          	auipc	a0,0x7
    80002694:	e6050513          	addi	a0,a0,-416 # 800094f0 <syscalls+0x140>
    80002698:	00004097          	auipc	ra,0x4
    8000269c:	59c080e7          	jalr	1436(ra) # 80006c34 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800026a0:	974a                	add	a4,a4,s2
    800026a2:	8fd5                	or	a5,a5,a3
    800026a4:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800026a8:	854a                	mv	a0,s2
    800026aa:	00001097          	auipc	ra,0x1
    800026ae:	01a080e7          	jalr	26(ra) # 800036c4 <log_write>
        brelse(bp);
    800026b2:	854a                	mv	a0,s2
    800026b4:	00000097          	auipc	ra,0x0
    800026b8:	d94080e7          	jalr	-620(ra) # 80002448 <brelse>
  bp = bread(dev, bno);
    800026bc:	85a6                	mv	a1,s1
    800026be:	855e                	mv	a0,s7
    800026c0:	00000097          	auipc	ra,0x0
    800026c4:	c58080e7          	jalr	-936(ra) # 80002318 <bread>
    800026c8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800026ca:	40000613          	li	a2,1024
    800026ce:	4581                	li	a1,0
    800026d0:	05850513          	addi	a0,a0,88
    800026d4:	ffffe097          	auipc	ra,0xffffe
    800026d8:	aa4080e7          	jalr	-1372(ra) # 80000178 <memset>
  log_write(bp);
    800026dc:	854a                	mv	a0,s2
    800026de:	00001097          	auipc	ra,0x1
    800026e2:	fe6080e7          	jalr	-26(ra) # 800036c4 <log_write>
  brelse(bp);
    800026e6:	854a                	mv	a0,s2
    800026e8:	00000097          	auipc	ra,0x0
    800026ec:	d60080e7          	jalr	-672(ra) # 80002448 <brelse>
}
    800026f0:	8526                	mv	a0,s1
    800026f2:	60e6                	ld	ra,88(sp)
    800026f4:	6446                	ld	s0,80(sp)
    800026f6:	64a6                	ld	s1,72(sp)
    800026f8:	6906                	ld	s2,64(sp)
    800026fa:	79e2                	ld	s3,56(sp)
    800026fc:	7a42                	ld	s4,48(sp)
    800026fe:	7aa2                	ld	s5,40(sp)
    80002700:	7b02                	ld	s6,32(sp)
    80002702:	6be2                	ld	s7,24(sp)
    80002704:	6c42                	ld	s8,16(sp)
    80002706:	6ca2                	ld	s9,8(sp)
    80002708:	6125                	addi	sp,sp,96
    8000270a:	8082                	ret

000000008000270c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000270c:	7179                	addi	sp,sp,-48
    8000270e:	f406                	sd	ra,40(sp)
    80002710:	f022                	sd	s0,32(sp)
    80002712:	ec26                	sd	s1,24(sp)
    80002714:	e84a                	sd	s2,16(sp)
    80002716:	e44e                	sd	s3,8(sp)
    80002718:	e052                	sd	s4,0(sp)
    8000271a:	1800                	addi	s0,sp,48
    8000271c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000271e:	47ad                	li	a5,11
    80002720:	04b7fe63          	bgeu	a5,a1,8000277c <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80002724:	ff45849b          	addiw	s1,a1,-12
    80002728:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000272c:	0ff00793          	li	a5,255
    80002730:	0ae7e363          	bltu	a5,a4,800027d6 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80002734:	08052583          	lw	a1,128(a0)
    80002738:	c5ad                	beqz	a1,800027a2 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000273a:	00092503          	lw	a0,0(s2)
    8000273e:	00000097          	auipc	ra,0x0
    80002742:	bda080e7          	jalr	-1062(ra) # 80002318 <bread>
    80002746:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002748:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000274c:	02049593          	slli	a1,s1,0x20
    80002750:	9181                	srli	a1,a1,0x20
    80002752:	058a                	slli	a1,a1,0x2
    80002754:	00b784b3          	add	s1,a5,a1
    80002758:	0004a983          	lw	s3,0(s1)
    8000275c:	04098d63          	beqz	s3,800027b6 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80002760:	8552                	mv	a0,s4
    80002762:	00000097          	auipc	ra,0x0
    80002766:	ce6080e7          	jalr	-794(ra) # 80002448 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000276a:	854e                	mv	a0,s3
    8000276c:	70a2                	ld	ra,40(sp)
    8000276e:	7402                	ld	s0,32(sp)
    80002770:	64e2                	ld	s1,24(sp)
    80002772:	6942                	ld	s2,16(sp)
    80002774:	69a2                	ld	s3,8(sp)
    80002776:	6a02                	ld	s4,0(sp)
    80002778:	6145                	addi	sp,sp,48
    8000277a:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000277c:	02059493          	slli	s1,a1,0x20
    80002780:	9081                	srli	s1,s1,0x20
    80002782:	048a                	slli	s1,s1,0x2
    80002784:	94aa                	add	s1,s1,a0
    80002786:	0504a983          	lw	s3,80(s1)
    8000278a:	fe0990e3          	bnez	s3,8000276a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000278e:	4108                	lw	a0,0(a0)
    80002790:	00000097          	auipc	ra,0x0
    80002794:	e4a080e7          	jalr	-438(ra) # 800025da <balloc>
    80002798:	0005099b          	sext.w	s3,a0
    8000279c:	0534a823          	sw	s3,80(s1)
    800027a0:	b7e9                	j	8000276a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800027a2:	4108                	lw	a0,0(a0)
    800027a4:	00000097          	auipc	ra,0x0
    800027a8:	e36080e7          	jalr	-458(ra) # 800025da <balloc>
    800027ac:	0005059b          	sext.w	a1,a0
    800027b0:	08b92023          	sw	a1,128(s2)
    800027b4:	b759                	j	8000273a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800027b6:	00092503          	lw	a0,0(s2)
    800027ba:	00000097          	auipc	ra,0x0
    800027be:	e20080e7          	jalr	-480(ra) # 800025da <balloc>
    800027c2:	0005099b          	sext.w	s3,a0
    800027c6:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800027ca:	8552                	mv	a0,s4
    800027cc:	00001097          	auipc	ra,0x1
    800027d0:	ef8080e7          	jalr	-264(ra) # 800036c4 <log_write>
    800027d4:	b771                	j	80002760 <bmap+0x54>
  panic("bmap: out of range");
    800027d6:	00007517          	auipc	a0,0x7
    800027da:	d3250513          	addi	a0,a0,-718 # 80009508 <syscalls+0x158>
    800027de:	00004097          	auipc	ra,0x4
    800027e2:	456080e7          	jalr	1110(ra) # 80006c34 <panic>

00000000800027e6 <iget>:
{
    800027e6:	7179                	addi	sp,sp,-48
    800027e8:	f406                	sd	ra,40(sp)
    800027ea:	f022                	sd	s0,32(sp)
    800027ec:	ec26                	sd	s1,24(sp)
    800027ee:	e84a                	sd	s2,16(sp)
    800027f0:	e44e                	sd	s3,8(sp)
    800027f2:	e052                	sd	s4,0(sp)
    800027f4:	1800                	addi	s0,sp,48
    800027f6:	89aa                	mv	s3,a0
    800027f8:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800027fa:	00016517          	auipc	a0,0x16
    800027fe:	d8650513          	addi	a0,a0,-634 # 80018580 <icache>
    80002802:	00005097          	auipc	ra,0x5
    80002806:	96e080e7          	jalr	-1682(ra) # 80007170 <acquire>
  empty = 0;
    8000280a:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000280c:	00016497          	auipc	s1,0x16
    80002810:	d8c48493          	addi	s1,s1,-628 # 80018598 <icache+0x18>
    80002814:	00018697          	auipc	a3,0x18
    80002818:	81468693          	addi	a3,a3,-2028 # 8001a028 <log>
    8000281c:	a039                	j	8000282a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000281e:	02090b63          	beqz	s2,80002854 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80002822:	08848493          	addi	s1,s1,136
    80002826:	02d48a63          	beq	s1,a3,8000285a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000282a:	449c                	lw	a5,8(s1)
    8000282c:	fef059e3          	blez	a5,8000281e <iget+0x38>
    80002830:	4098                	lw	a4,0(s1)
    80002832:	ff3716e3          	bne	a4,s3,8000281e <iget+0x38>
    80002836:	40d8                	lw	a4,4(s1)
    80002838:	ff4713e3          	bne	a4,s4,8000281e <iget+0x38>
      ip->ref++;
    8000283c:	2785                	addiw	a5,a5,1
    8000283e:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80002840:	00016517          	auipc	a0,0x16
    80002844:	d4050513          	addi	a0,a0,-704 # 80018580 <icache>
    80002848:	00005097          	auipc	ra,0x5
    8000284c:	9dc080e7          	jalr	-1572(ra) # 80007224 <release>
      return ip;
    80002850:	8926                	mv	s2,s1
    80002852:	a03d                	j	80002880 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002854:	f7f9                	bnez	a5,80002822 <iget+0x3c>
    80002856:	8926                	mv	s2,s1
    80002858:	b7e9                	j	80002822 <iget+0x3c>
  if(empty == 0)
    8000285a:	02090c63          	beqz	s2,80002892 <iget+0xac>
  ip->dev = dev;
    8000285e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002862:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002866:	4785                	li	a5,1
    80002868:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000286c:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80002870:	00016517          	auipc	a0,0x16
    80002874:	d1050513          	addi	a0,a0,-752 # 80018580 <icache>
    80002878:	00005097          	auipc	ra,0x5
    8000287c:	9ac080e7          	jalr	-1620(ra) # 80007224 <release>
}
    80002880:	854a                	mv	a0,s2
    80002882:	70a2                	ld	ra,40(sp)
    80002884:	7402                	ld	s0,32(sp)
    80002886:	64e2                	ld	s1,24(sp)
    80002888:	6942                	ld	s2,16(sp)
    8000288a:	69a2                	ld	s3,8(sp)
    8000288c:	6a02                	ld	s4,0(sp)
    8000288e:	6145                	addi	sp,sp,48
    80002890:	8082                	ret
    panic("iget: no inodes");
    80002892:	00007517          	auipc	a0,0x7
    80002896:	c8e50513          	addi	a0,a0,-882 # 80009520 <syscalls+0x170>
    8000289a:	00004097          	auipc	ra,0x4
    8000289e:	39a080e7          	jalr	922(ra) # 80006c34 <panic>

00000000800028a2 <fsinit>:
fsinit(int dev) {
    800028a2:	7179                	addi	sp,sp,-48
    800028a4:	f406                	sd	ra,40(sp)
    800028a6:	f022                	sd	s0,32(sp)
    800028a8:	ec26                	sd	s1,24(sp)
    800028aa:	e84a                	sd	s2,16(sp)
    800028ac:	e44e                	sd	s3,8(sp)
    800028ae:	1800                	addi	s0,sp,48
    800028b0:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800028b2:	4585                	li	a1,1
    800028b4:	00000097          	auipc	ra,0x0
    800028b8:	a64080e7          	jalr	-1436(ra) # 80002318 <bread>
    800028bc:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800028be:	00016997          	auipc	s3,0x16
    800028c2:	ca298993          	addi	s3,s3,-862 # 80018560 <sb>
    800028c6:	02000613          	li	a2,32
    800028ca:	05850593          	addi	a1,a0,88
    800028ce:	854e                	mv	a0,s3
    800028d0:	ffffe097          	auipc	ra,0xffffe
    800028d4:	904080e7          	jalr	-1788(ra) # 800001d4 <memmove>
  brelse(bp);
    800028d8:	8526                	mv	a0,s1
    800028da:	00000097          	auipc	ra,0x0
    800028de:	b6e080e7          	jalr	-1170(ra) # 80002448 <brelse>
  if(sb.magic != FSMAGIC)
    800028e2:	0009a703          	lw	a4,0(s3)
    800028e6:	102037b7          	lui	a5,0x10203
    800028ea:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800028ee:	02f71263          	bne	a4,a5,80002912 <fsinit+0x70>
  initlog(dev, &sb);
    800028f2:	00016597          	auipc	a1,0x16
    800028f6:	c6e58593          	addi	a1,a1,-914 # 80018560 <sb>
    800028fa:	854a                	mv	a0,s2
    800028fc:	00001097          	auipc	ra,0x1
    80002900:	b4c080e7          	jalr	-1204(ra) # 80003448 <initlog>
}
    80002904:	70a2                	ld	ra,40(sp)
    80002906:	7402                	ld	s0,32(sp)
    80002908:	64e2                	ld	s1,24(sp)
    8000290a:	6942                	ld	s2,16(sp)
    8000290c:	69a2                	ld	s3,8(sp)
    8000290e:	6145                	addi	sp,sp,48
    80002910:	8082                	ret
    panic("invalid file system");
    80002912:	00007517          	auipc	a0,0x7
    80002916:	c1e50513          	addi	a0,a0,-994 # 80009530 <syscalls+0x180>
    8000291a:	00004097          	auipc	ra,0x4
    8000291e:	31a080e7          	jalr	794(ra) # 80006c34 <panic>

0000000080002922 <iinit>:
{
    80002922:	7179                	addi	sp,sp,-48
    80002924:	f406                	sd	ra,40(sp)
    80002926:	f022                	sd	s0,32(sp)
    80002928:	ec26                	sd	s1,24(sp)
    8000292a:	e84a                	sd	s2,16(sp)
    8000292c:	e44e                	sd	s3,8(sp)
    8000292e:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80002930:	00007597          	auipc	a1,0x7
    80002934:	c1858593          	addi	a1,a1,-1000 # 80009548 <syscalls+0x198>
    80002938:	00016517          	auipc	a0,0x16
    8000293c:	c4850513          	addi	a0,a0,-952 # 80018580 <icache>
    80002940:	00004097          	auipc	ra,0x4
    80002944:	7a0080e7          	jalr	1952(ra) # 800070e0 <initlock>
  for(i = 0; i < NINODE; i++) {
    80002948:	00016497          	auipc	s1,0x16
    8000294c:	c6048493          	addi	s1,s1,-928 # 800185a8 <icache+0x28>
    80002950:	00017997          	auipc	s3,0x17
    80002954:	6e898993          	addi	s3,s3,1768 # 8001a038 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80002958:	00007917          	auipc	s2,0x7
    8000295c:	bf890913          	addi	s2,s2,-1032 # 80009550 <syscalls+0x1a0>
    80002960:	85ca                	mv	a1,s2
    80002962:	8526                	mv	a0,s1
    80002964:	00001097          	auipc	ra,0x1
    80002968:	e4e080e7          	jalr	-434(ra) # 800037b2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000296c:	08848493          	addi	s1,s1,136
    80002970:	ff3498e3          	bne	s1,s3,80002960 <iinit+0x3e>
}
    80002974:	70a2                	ld	ra,40(sp)
    80002976:	7402                	ld	s0,32(sp)
    80002978:	64e2                	ld	s1,24(sp)
    8000297a:	6942                	ld	s2,16(sp)
    8000297c:	69a2                	ld	s3,8(sp)
    8000297e:	6145                	addi	sp,sp,48
    80002980:	8082                	ret

0000000080002982 <ialloc>:
{
    80002982:	715d                	addi	sp,sp,-80
    80002984:	e486                	sd	ra,72(sp)
    80002986:	e0a2                	sd	s0,64(sp)
    80002988:	fc26                	sd	s1,56(sp)
    8000298a:	f84a                	sd	s2,48(sp)
    8000298c:	f44e                	sd	s3,40(sp)
    8000298e:	f052                	sd	s4,32(sp)
    80002990:	ec56                	sd	s5,24(sp)
    80002992:	e85a                	sd	s6,16(sp)
    80002994:	e45e                	sd	s7,8(sp)
    80002996:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002998:	00016717          	auipc	a4,0x16
    8000299c:	bd472703          	lw	a4,-1068(a4) # 8001856c <sb+0xc>
    800029a0:	4785                	li	a5,1
    800029a2:	04e7fa63          	bgeu	a5,a4,800029f6 <ialloc+0x74>
    800029a6:	8aaa                	mv	s5,a0
    800029a8:	8bae                	mv	s7,a1
    800029aa:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800029ac:	00016a17          	auipc	s4,0x16
    800029b0:	bb4a0a13          	addi	s4,s4,-1100 # 80018560 <sb>
    800029b4:	00048b1b          	sext.w	s6,s1
    800029b8:	0044d793          	srli	a5,s1,0x4
    800029bc:	018a2583          	lw	a1,24(s4)
    800029c0:	9dbd                	addw	a1,a1,a5
    800029c2:	8556                	mv	a0,s5
    800029c4:	00000097          	auipc	ra,0x0
    800029c8:	954080e7          	jalr	-1708(ra) # 80002318 <bread>
    800029cc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800029ce:	05850993          	addi	s3,a0,88
    800029d2:	00f4f793          	andi	a5,s1,15
    800029d6:	079a                	slli	a5,a5,0x6
    800029d8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800029da:	00099783          	lh	a5,0(s3)
    800029de:	c785                	beqz	a5,80002a06 <ialloc+0x84>
    brelse(bp);
    800029e0:	00000097          	auipc	ra,0x0
    800029e4:	a68080e7          	jalr	-1432(ra) # 80002448 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800029e8:	0485                	addi	s1,s1,1
    800029ea:	00ca2703          	lw	a4,12(s4)
    800029ee:	0004879b          	sext.w	a5,s1
    800029f2:	fce7e1e3          	bltu	a5,a4,800029b4 <ialloc+0x32>
  panic("ialloc: no inodes");
    800029f6:	00007517          	auipc	a0,0x7
    800029fa:	b6250513          	addi	a0,a0,-1182 # 80009558 <syscalls+0x1a8>
    800029fe:	00004097          	auipc	ra,0x4
    80002a02:	236080e7          	jalr	566(ra) # 80006c34 <panic>
      memset(dip, 0, sizeof(*dip));
    80002a06:	04000613          	li	a2,64
    80002a0a:	4581                	li	a1,0
    80002a0c:	854e                	mv	a0,s3
    80002a0e:	ffffd097          	auipc	ra,0xffffd
    80002a12:	76a080e7          	jalr	1898(ra) # 80000178 <memset>
      dip->type = type;
    80002a16:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002a1a:	854a                	mv	a0,s2
    80002a1c:	00001097          	auipc	ra,0x1
    80002a20:	ca8080e7          	jalr	-856(ra) # 800036c4 <log_write>
      brelse(bp);
    80002a24:	854a                	mv	a0,s2
    80002a26:	00000097          	auipc	ra,0x0
    80002a2a:	a22080e7          	jalr	-1502(ra) # 80002448 <brelse>
      return iget(dev, inum);
    80002a2e:	85da                	mv	a1,s6
    80002a30:	8556                	mv	a0,s5
    80002a32:	00000097          	auipc	ra,0x0
    80002a36:	db4080e7          	jalr	-588(ra) # 800027e6 <iget>
}
    80002a3a:	60a6                	ld	ra,72(sp)
    80002a3c:	6406                	ld	s0,64(sp)
    80002a3e:	74e2                	ld	s1,56(sp)
    80002a40:	7942                	ld	s2,48(sp)
    80002a42:	79a2                	ld	s3,40(sp)
    80002a44:	7a02                	ld	s4,32(sp)
    80002a46:	6ae2                	ld	s5,24(sp)
    80002a48:	6b42                	ld	s6,16(sp)
    80002a4a:	6ba2                	ld	s7,8(sp)
    80002a4c:	6161                	addi	sp,sp,80
    80002a4e:	8082                	ret

0000000080002a50 <iupdate>:
{
    80002a50:	1101                	addi	sp,sp,-32
    80002a52:	ec06                	sd	ra,24(sp)
    80002a54:	e822                	sd	s0,16(sp)
    80002a56:	e426                	sd	s1,8(sp)
    80002a58:	e04a                	sd	s2,0(sp)
    80002a5a:	1000                	addi	s0,sp,32
    80002a5c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002a5e:	415c                	lw	a5,4(a0)
    80002a60:	0047d79b          	srliw	a5,a5,0x4
    80002a64:	00016597          	auipc	a1,0x16
    80002a68:	b145a583          	lw	a1,-1260(a1) # 80018578 <sb+0x18>
    80002a6c:	9dbd                	addw	a1,a1,a5
    80002a6e:	4108                	lw	a0,0(a0)
    80002a70:	00000097          	auipc	ra,0x0
    80002a74:	8a8080e7          	jalr	-1880(ra) # 80002318 <bread>
    80002a78:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002a7a:	05850793          	addi	a5,a0,88
    80002a7e:	40c8                	lw	a0,4(s1)
    80002a80:	893d                	andi	a0,a0,15
    80002a82:	051a                	slli	a0,a0,0x6
    80002a84:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80002a86:	04449703          	lh	a4,68(s1)
    80002a8a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80002a8e:	04649703          	lh	a4,70(s1)
    80002a92:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80002a96:	04849703          	lh	a4,72(s1)
    80002a9a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80002a9e:	04a49703          	lh	a4,74(s1)
    80002aa2:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80002aa6:	44f8                	lw	a4,76(s1)
    80002aa8:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002aaa:	03400613          	li	a2,52
    80002aae:	05048593          	addi	a1,s1,80
    80002ab2:	0531                	addi	a0,a0,12
    80002ab4:	ffffd097          	auipc	ra,0xffffd
    80002ab8:	720080e7          	jalr	1824(ra) # 800001d4 <memmove>
  log_write(bp);
    80002abc:	854a                	mv	a0,s2
    80002abe:	00001097          	auipc	ra,0x1
    80002ac2:	c06080e7          	jalr	-1018(ra) # 800036c4 <log_write>
  brelse(bp);
    80002ac6:	854a                	mv	a0,s2
    80002ac8:	00000097          	auipc	ra,0x0
    80002acc:	980080e7          	jalr	-1664(ra) # 80002448 <brelse>
}
    80002ad0:	60e2                	ld	ra,24(sp)
    80002ad2:	6442                	ld	s0,16(sp)
    80002ad4:	64a2                	ld	s1,8(sp)
    80002ad6:	6902                	ld	s2,0(sp)
    80002ad8:	6105                	addi	sp,sp,32
    80002ada:	8082                	ret

0000000080002adc <idup>:
{
    80002adc:	1101                	addi	sp,sp,-32
    80002ade:	ec06                	sd	ra,24(sp)
    80002ae0:	e822                	sd	s0,16(sp)
    80002ae2:	e426                	sd	s1,8(sp)
    80002ae4:	1000                	addi	s0,sp,32
    80002ae6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80002ae8:	00016517          	auipc	a0,0x16
    80002aec:	a9850513          	addi	a0,a0,-1384 # 80018580 <icache>
    80002af0:	00004097          	auipc	ra,0x4
    80002af4:	680080e7          	jalr	1664(ra) # 80007170 <acquire>
  ip->ref++;
    80002af8:	449c                	lw	a5,8(s1)
    80002afa:	2785                	addiw	a5,a5,1
    80002afc:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80002afe:	00016517          	auipc	a0,0x16
    80002b02:	a8250513          	addi	a0,a0,-1406 # 80018580 <icache>
    80002b06:	00004097          	auipc	ra,0x4
    80002b0a:	71e080e7          	jalr	1822(ra) # 80007224 <release>
}
    80002b0e:	8526                	mv	a0,s1
    80002b10:	60e2                	ld	ra,24(sp)
    80002b12:	6442                	ld	s0,16(sp)
    80002b14:	64a2                	ld	s1,8(sp)
    80002b16:	6105                	addi	sp,sp,32
    80002b18:	8082                	ret

0000000080002b1a <ilock>:
{
    80002b1a:	1101                	addi	sp,sp,-32
    80002b1c:	ec06                	sd	ra,24(sp)
    80002b1e:	e822                	sd	s0,16(sp)
    80002b20:	e426                	sd	s1,8(sp)
    80002b22:	e04a                	sd	s2,0(sp)
    80002b24:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002b26:	c115                	beqz	a0,80002b4a <ilock+0x30>
    80002b28:	84aa                	mv	s1,a0
    80002b2a:	451c                	lw	a5,8(a0)
    80002b2c:	00f05f63          	blez	a5,80002b4a <ilock+0x30>
  acquiresleep(&ip->lock);
    80002b30:	0541                	addi	a0,a0,16
    80002b32:	00001097          	auipc	ra,0x1
    80002b36:	cba080e7          	jalr	-838(ra) # 800037ec <acquiresleep>
  if(ip->valid == 0){
    80002b3a:	40bc                	lw	a5,64(s1)
    80002b3c:	cf99                	beqz	a5,80002b5a <ilock+0x40>
}
    80002b3e:	60e2                	ld	ra,24(sp)
    80002b40:	6442                	ld	s0,16(sp)
    80002b42:	64a2                	ld	s1,8(sp)
    80002b44:	6902                	ld	s2,0(sp)
    80002b46:	6105                	addi	sp,sp,32
    80002b48:	8082                	ret
    panic("ilock");
    80002b4a:	00007517          	auipc	a0,0x7
    80002b4e:	a2650513          	addi	a0,a0,-1498 # 80009570 <syscalls+0x1c0>
    80002b52:	00004097          	auipc	ra,0x4
    80002b56:	0e2080e7          	jalr	226(ra) # 80006c34 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002b5a:	40dc                	lw	a5,4(s1)
    80002b5c:	0047d79b          	srliw	a5,a5,0x4
    80002b60:	00016597          	auipc	a1,0x16
    80002b64:	a185a583          	lw	a1,-1512(a1) # 80018578 <sb+0x18>
    80002b68:	9dbd                	addw	a1,a1,a5
    80002b6a:	4088                	lw	a0,0(s1)
    80002b6c:	fffff097          	auipc	ra,0xfffff
    80002b70:	7ac080e7          	jalr	1964(ra) # 80002318 <bread>
    80002b74:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002b76:	05850593          	addi	a1,a0,88
    80002b7a:	40dc                	lw	a5,4(s1)
    80002b7c:	8bbd                	andi	a5,a5,15
    80002b7e:	079a                	slli	a5,a5,0x6
    80002b80:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002b82:	00059783          	lh	a5,0(a1)
    80002b86:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002b8a:	00259783          	lh	a5,2(a1)
    80002b8e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002b92:	00459783          	lh	a5,4(a1)
    80002b96:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002b9a:	00659783          	lh	a5,6(a1)
    80002b9e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002ba2:	459c                	lw	a5,8(a1)
    80002ba4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002ba6:	03400613          	li	a2,52
    80002baa:	05b1                	addi	a1,a1,12
    80002bac:	05048513          	addi	a0,s1,80
    80002bb0:	ffffd097          	auipc	ra,0xffffd
    80002bb4:	624080e7          	jalr	1572(ra) # 800001d4 <memmove>
    brelse(bp);
    80002bb8:	854a                	mv	a0,s2
    80002bba:	00000097          	auipc	ra,0x0
    80002bbe:	88e080e7          	jalr	-1906(ra) # 80002448 <brelse>
    ip->valid = 1;
    80002bc2:	4785                	li	a5,1
    80002bc4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002bc6:	04449783          	lh	a5,68(s1)
    80002bca:	fbb5                	bnez	a5,80002b3e <ilock+0x24>
      panic("ilock: no type");
    80002bcc:	00007517          	auipc	a0,0x7
    80002bd0:	9ac50513          	addi	a0,a0,-1620 # 80009578 <syscalls+0x1c8>
    80002bd4:	00004097          	auipc	ra,0x4
    80002bd8:	060080e7          	jalr	96(ra) # 80006c34 <panic>

0000000080002bdc <iunlock>:
{
    80002bdc:	1101                	addi	sp,sp,-32
    80002bde:	ec06                	sd	ra,24(sp)
    80002be0:	e822                	sd	s0,16(sp)
    80002be2:	e426                	sd	s1,8(sp)
    80002be4:	e04a                	sd	s2,0(sp)
    80002be6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002be8:	c905                	beqz	a0,80002c18 <iunlock+0x3c>
    80002bea:	84aa                	mv	s1,a0
    80002bec:	01050913          	addi	s2,a0,16
    80002bf0:	854a                	mv	a0,s2
    80002bf2:	00001097          	auipc	ra,0x1
    80002bf6:	c94080e7          	jalr	-876(ra) # 80003886 <holdingsleep>
    80002bfa:	cd19                	beqz	a0,80002c18 <iunlock+0x3c>
    80002bfc:	449c                	lw	a5,8(s1)
    80002bfe:	00f05d63          	blez	a5,80002c18 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002c02:	854a                	mv	a0,s2
    80002c04:	00001097          	auipc	ra,0x1
    80002c08:	c3e080e7          	jalr	-962(ra) # 80003842 <releasesleep>
}
    80002c0c:	60e2                	ld	ra,24(sp)
    80002c0e:	6442                	ld	s0,16(sp)
    80002c10:	64a2                	ld	s1,8(sp)
    80002c12:	6902                	ld	s2,0(sp)
    80002c14:	6105                	addi	sp,sp,32
    80002c16:	8082                	ret
    panic("iunlock");
    80002c18:	00007517          	auipc	a0,0x7
    80002c1c:	97050513          	addi	a0,a0,-1680 # 80009588 <syscalls+0x1d8>
    80002c20:	00004097          	auipc	ra,0x4
    80002c24:	014080e7          	jalr	20(ra) # 80006c34 <panic>

0000000080002c28 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002c28:	7179                	addi	sp,sp,-48
    80002c2a:	f406                	sd	ra,40(sp)
    80002c2c:	f022                	sd	s0,32(sp)
    80002c2e:	ec26                	sd	s1,24(sp)
    80002c30:	e84a                	sd	s2,16(sp)
    80002c32:	e44e                	sd	s3,8(sp)
    80002c34:	e052                	sd	s4,0(sp)
    80002c36:	1800                	addi	s0,sp,48
    80002c38:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002c3a:	05050493          	addi	s1,a0,80
    80002c3e:	08050913          	addi	s2,a0,128
    80002c42:	a021                	j	80002c4a <itrunc+0x22>
    80002c44:	0491                	addi	s1,s1,4
    80002c46:	01248d63          	beq	s1,s2,80002c60 <itrunc+0x38>
    if(ip->addrs[i]){
    80002c4a:	408c                	lw	a1,0(s1)
    80002c4c:	dde5                	beqz	a1,80002c44 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002c4e:	0009a503          	lw	a0,0(s3)
    80002c52:	00000097          	auipc	ra,0x0
    80002c56:	90c080e7          	jalr	-1780(ra) # 8000255e <bfree>
      ip->addrs[i] = 0;
    80002c5a:	0004a023          	sw	zero,0(s1)
    80002c5e:	b7dd                	j	80002c44 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002c60:	0809a583          	lw	a1,128(s3)
    80002c64:	e185                	bnez	a1,80002c84 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002c66:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002c6a:	854e                	mv	a0,s3
    80002c6c:	00000097          	auipc	ra,0x0
    80002c70:	de4080e7          	jalr	-540(ra) # 80002a50 <iupdate>
}
    80002c74:	70a2                	ld	ra,40(sp)
    80002c76:	7402                	ld	s0,32(sp)
    80002c78:	64e2                	ld	s1,24(sp)
    80002c7a:	6942                	ld	s2,16(sp)
    80002c7c:	69a2                	ld	s3,8(sp)
    80002c7e:	6a02                	ld	s4,0(sp)
    80002c80:	6145                	addi	sp,sp,48
    80002c82:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002c84:	0009a503          	lw	a0,0(s3)
    80002c88:	fffff097          	auipc	ra,0xfffff
    80002c8c:	690080e7          	jalr	1680(ra) # 80002318 <bread>
    80002c90:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002c92:	05850493          	addi	s1,a0,88
    80002c96:	45850913          	addi	s2,a0,1112
    80002c9a:	a021                	j	80002ca2 <itrunc+0x7a>
    80002c9c:	0491                	addi	s1,s1,4
    80002c9e:	01248b63          	beq	s1,s2,80002cb4 <itrunc+0x8c>
      if(a[j])
    80002ca2:	408c                	lw	a1,0(s1)
    80002ca4:	dde5                	beqz	a1,80002c9c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80002ca6:	0009a503          	lw	a0,0(s3)
    80002caa:	00000097          	auipc	ra,0x0
    80002cae:	8b4080e7          	jalr	-1868(ra) # 8000255e <bfree>
    80002cb2:	b7ed                	j	80002c9c <itrunc+0x74>
    brelse(bp);
    80002cb4:	8552                	mv	a0,s4
    80002cb6:	fffff097          	auipc	ra,0xfffff
    80002cba:	792080e7          	jalr	1938(ra) # 80002448 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002cbe:	0809a583          	lw	a1,128(s3)
    80002cc2:	0009a503          	lw	a0,0(s3)
    80002cc6:	00000097          	auipc	ra,0x0
    80002cca:	898080e7          	jalr	-1896(ra) # 8000255e <bfree>
    ip->addrs[NDIRECT] = 0;
    80002cce:	0809a023          	sw	zero,128(s3)
    80002cd2:	bf51                	j	80002c66 <itrunc+0x3e>

0000000080002cd4 <iput>:
{
    80002cd4:	1101                	addi	sp,sp,-32
    80002cd6:	ec06                	sd	ra,24(sp)
    80002cd8:	e822                	sd	s0,16(sp)
    80002cda:	e426                	sd	s1,8(sp)
    80002cdc:	e04a                	sd	s2,0(sp)
    80002cde:	1000                	addi	s0,sp,32
    80002ce0:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80002ce2:	00016517          	auipc	a0,0x16
    80002ce6:	89e50513          	addi	a0,a0,-1890 # 80018580 <icache>
    80002cea:	00004097          	auipc	ra,0x4
    80002cee:	486080e7          	jalr	1158(ra) # 80007170 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002cf2:	4498                	lw	a4,8(s1)
    80002cf4:	4785                	li	a5,1
    80002cf6:	02f70363          	beq	a4,a5,80002d1c <iput+0x48>
  ip->ref--;
    80002cfa:	449c                	lw	a5,8(s1)
    80002cfc:	37fd                	addiw	a5,a5,-1
    80002cfe:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80002d00:	00016517          	auipc	a0,0x16
    80002d04:	88050513          	addi	a0,a0,-1920 # 80018580 <icache>
    80002d08:	00004097          	auipc	ra,0x4
    80002d0c:	51c080e7          	jalr	1308(ra) # 80007224 <release>
}
    80002d10:	60e2                	ld	ra,24(sp)
    80002d12:	6442                	ld	s0,16(sp)
    80002d14:	64a2                	ld	s1,8(sp)
    80002d16:	6902                	ld	s2,0(sp)
    80002d18:	6105                	addi	sp,sp,32
    80002d1a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002d1c:	40bc                	lw	a5,64(s1)
    80002d1e:	dff1                	beqz	a5,80002cfa <iput+0x26>
    80002d20:	04a49783          	lh	a5,74(s1)
    80002d24:	fbf9                	bnez	a5,80002cfa <iput+0x26>
    acquiresleep(&ip->lock);
    80002d26:	01048913          	addi	s2,s1,16
    80002d2a:	854a                	mv	a0,s2
    80002d2c:	00001097          	auipc	ra,0x1
    80002d30:	ac0080e7          	jalr	-1344(ra) # 800037ec <acquiresleep>
    release(&icache.lock);
    80002d34:	00016517          	auipc	a0,0x16
    80002d38:	84c50513          	addi	a0,a0,-1972 # 80018580 <icache>
    80002d3c:	00004097          	auipc	ra,0x4
    80002d40:	4e8080e7          	jalr	1256(ra) # 80007224 <release>
    itrunc(ip);
    80002d44:	8526                	mv	a0,s1
    80002d46:	00000097          	auipc	ra,0x0
    80002d4a:	ee2080e7          	jalr	-286(ra) # 80002c28 <itrunc>
    ip->type = 0;
    80002d4e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002d52:	8526                	mv	a0,s1
    80002d54:	00000097          	auipc	ra,0x0
    80002d58:	cfc080e7          	jalr	-772(ra) # 80002a50 <iupdate>
    ip->valid = 0;
    80002d5c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002d60:	854a                	mv	a0,s2
    80002d62:	00001097          	auipc	ra,0x1
    80002d66:	ae0080e7          	jalr	-1312(ra) # 80003842 <releasesleep>
    acquire(&icache.lock);
    80002d6a:	00016517          	auipc	a0,0x16
    80002d6e:	81650513          	addi	a0,a0,-2026 # 80018580 <icache>
    80002d72:	00004097          	auipc	ra,0x4
    80002d76:	3fe080e7          	jalr	1022(ra) # 80007170 <acquire>
    80002d7a:	b741                	j	80002cfa <iput+0x26>

0000000080002d7c <iunlockput>:
{
    80002d7c:	1101                	addi	sp,sp,-32
    80002d7e:	ec06                	sd	ra,24(sp)
    80002d80:	e822                	sd	s0,16(sp)
    80002d82:	e426                	sd	s1,8(sp)
    80002d84:	1000                	addi	s0,sp,32
    80002d86:	84aa                	mv	s1,a0
  iunlock(ip);
    80002d88:	00000097          	auipc	ra,0x0
    80002d8c:	e54080e7          	jalr	-428(ra) # 80002bdc <iunlock>
  iput(ip);
    80002d90:	8526                	mv	a0,s1
    80002d92:	00000097          	auipc	ra,0x0
    80002d96:	f42080e7          	jalr	-190(ra) # 80002cd4 <iput>
}
    80002d9a:	60e2                	ld	ra,24(sp)
    80002d9c:	6442                	ld	s0,16(sp)
    80002d9e:	64a2                	ld	s1,8(sp)
    80002da0:	6105                	addi	sp,sp,32
    80002da2:	8082                	ret

0000000080002da4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002da4:	1141                	addi	sp,sp,-16
    80002da6:	e422                	sd	s0,8(sp)
    80002da8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002daa:	411c                	lw	a5,0(a0)
    80002dac:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002dae:	415c                	lw	a5,4(a0)
    80002db0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002db2:	04451783          	lh	a5,68(a0)
    80002db6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002dba:	04a51783          	lh	a5,74(a0)
    80002dbe:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002dc2:	04c56783          	lwu	a5,76(a0)
    80002dc6:	e99c                	sd	a5,16(a1)
}
    80002dc8:	6422                	ld	s0,8(sp)
    80002dca:	0141                	addi	sp,sp,16
    80002dcc:	8082                	ret

0000000080002dce <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002dce:	457c                	lw	a5,76(a0)
    80002dd0:	0ed7e963          	bltu	a5,a3,80002ec2 <readi+0xf4>
{
    80002dd4:	7159                	addi	sp,sp,-112
    80002dd6:	f486                	sd	ra,104(sp)
    80002dd8:	f0a2                	sd	s0,96(sp)
    80002dda:	eca6                	sd	s1,88(sp)
    80002ddc:	e8ca                	sd	s2,80(sp)
    80002dde:	e4ce                	sd	s3,72(sp)
    80002de0:	e0d2                	sd	s4,64(sp)
    80002de2:	fc56                	sd	s5,56(sp)
    80002de4:	f85a                	sd	s6,48(sp)
    80002de6:	f45e                	sd	s7,40(sp)
    80002de8:	f062                	sd	s8,32(sp)
    80002dea:	ec66                	sd	s9,24(sp)
    80002dec:	e86a                	sd	s10,16(sp)
    80002dee:	e46e                	sd	s11,8(sp)
    80002df0:	1880                	addi	s0,sp,112
    80002df2:	8baa                	mv	s7,a0
    80002df4:	8c2e                	mv	s8,a1
    80002df6:	8ab2                	mv	s5,a2
    80002df8:	84b6                	mv	s1,a3
    80002dfa:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002dfc:	9f35                	addw	a4,a4,a3
    return 0;
    80002dfe:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002e00:	0ad76063          	bltu	a4,a3,80002ea0 <readi+0xd2>
  if(off + n > ip->size)
    80002e04:	00e7f463          	bgeu	a5,a4,80002e0c <readi+0x3e>
    n = ip->size - off;
    80002e08:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002e0c:	0a0b0963          	beqz	s6,80002ebe <readi+0xf0>
    80002e10:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80002e12:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002e16:	5cfd                	li	s9,-1
    80002e18:	a82d                	j	80002e52 <readi+0x84>
    80002e1a:	020a1d93          	slli	s11,s4,0x20
    80002e1e:	020ddd93          	srli	s11,s11,0x20
    80002e22:	05890793          	addi	a5,s2,88
    80002e26:	86ee                	mv	a3,s11
    80002e28:	963e                	add	a2,a2,a5
    80002e2a:	85d6                	mv	a1,s5
    80002e2c:	8562                	mv	a0,s8
    80002e2e:	fffff097          	auipc	ra,0xfffff
    80002e32:	b00080e7          	jalr	-1280(ra) # 8000192e <either_copyout>
    80002e36:	05950d63          	beq	a0,s9,80002e90 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002e3a:	854a                	mv	a0,s2
    80002e3c:	fffff097          	auipc	ra,0xfffff
    80002e40:	60c080e7          	jalr	1548(ra) # 80002448 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002e44:	013a09bb          	addw	s3,s4,s3
    80002e48:	009a04bb          	addw	s1,s4,s1
    80002e4c:	9aee                	add	s5,s5,s11
    80002e4e:	0569f763          	bgeu	s3,s6,80002e9c <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80002e52:	000ba903          	lw	s2,0(s7)
    80002e56:	00a4d59b          	srliw	a1,s1,0xa
    80002e5a:	855e                	mv	a0,s7
    80002e5c:	00000097          	auipc	ra,0x0
    80002e60:	8b0080e7          	jalr	-1872(ra) # 8000270c <bmap>
    80002e64:	0005059b          	sext.w	a1,a0
    80002e68:	854a                	mv	a0,s2
    80002e6a:	fffff097          	auipc	ra,0xfffff
    80002e6e:	4ae080e7          	jalr	1198(ra) # 80002318 <bread>
    80002e72:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002e74:	3ff4f613          	andi	a2,s1,1023
    80002e78:	40cd07bb          	subw	a5,s10,a2
    80002e7c:	413b073b          	subw	a4,s6,s3
    80002e80:	8a3e                	mv	s4,a5
    80002e82:	2781                	sext.w	a5,a5
    80002e84:	0007069b          	sext.w	a3,a4
    80002e88:	f8f6f9e3          	bgeu	a3,a5,80002e1a <readi+0x4c>
    80002e8c:	8a3a                	mv	s4,a4
    80002e8e:	b771                	j	80002e1a <readi+0x4c>
      brelse(bp);
    80002e90:	854a                	mv	a0,s2
    80002e92:	fffff097          	auipc	ra,0xfffff
    80002e96:	5b6080e7          	jalr	1462(ra) # 80002448 <brelse>
      tot = -1;
    80002e9a:	59fd                	li	s3,-1
  }
  return tot;
    80002e9c:	0009851b          	sext.w	a0,s3
}
    80002ea0:	70a6                	ld	ra,104(sp)
    80002ea2:	7406                	ld	s0,96(sp)
    80002ea4:	64e6                	ld	s1,88(sp)
    80002ea6:	6946                	ld	s2,80(sp)
    80002ea8:	69a6                	ld	s3,72(sp)
    80002eaa:	6a06                	ld	s4,64(sp)
    80002eac:	7ae2                	ld	s5,56(sp)
    80002eae:	7b42                	ld	s6,48(sp)
    80002eb0:	7ba2                	ld	s7,40(sp)
    80002eb2:	7c02                	ld	s8,32(sp)
    80002eb4:	6ce2                	ld	s9,24(sp)
    80002eb6:	6d42                	ld	s10,16(sp)
    80002eb8:	6da2                	ld	s11,8(sp)
    80002eba:	6165                	addi	sp,sp,112
    80002ebc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002ebe:	89da                	mv	s3,s6
    80002ec0:	bff1                	j	80002e9c <readi+0xce>
    return 0;
    80002ec2:	4501                	li	a0,0
}
    80002ec4:	8082                	ret

0000000080002ec6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002ec6:	457c                	lw	a5,76(a0)
    80002ec8:	10d7e863          	bltu	a5,a3,80002fd8 <writei+0x112>
{
    80002ecc:	7159                	addi	sp,sp,-112
    80002ece:	f486                	sd	ra,104(sp)
    80002ed0:	f0a2                	sd	s0,96(sp)
    80002ed2:	eca6                	sd	s1,88(sp)
    80002ed4:	e8ca                	sd	s2,80(sp)
    80002ed6:	e4ce                	sd	s3,72(sp)
    80002ed8:	e0d2                	sd	s4,64(sp)
    80002eda:	fc56                	sd	s5,56(sp)
    80002edc:	f85a                	sd	s6,48(sp)
    80002ede:	f45e                	sd	s7,40(sp)
    80002ee0:	f062                	sd	s8,32(sp)
    80002ee2:	ec66                	sd	s9,24(sp)
    80002ee4:	e86a                	sd	s10,16(sp)
    80002ee6:	e46e                	sd	s11,8(sp)
    80002ee8:	1880                	addi	s0,sp,112
    80002eea:	8b2a                	mv	s6,a0
    80002eec:	8c2e                	mv	s8,a1
    80002eee:	8ab2                	mv	s5,a2
    80002ef0:	8936                	mv	s2,a3
    80002ef2:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80002ef4:	00e687bb          	addw	a5,a3,a4
    80002ef8:	0ed7e263          	bltu	a5,a3,80002fdc <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002efc:	00043737          	lui	a4,0x43
    80002f00:	0ef76063          	bltu	a4,a5,80002fe0 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002f04:	0c0b8863          	beqz	s7,80002fd4 <writei+0x10e>
    80002f08:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f0a:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002f0e:	5cfd                	li	s9,-1
    80002f10:	a091                	j	80002f54 <writei+0x8e>
    80002f12:	02099d93          	slli	s11,s3,0x20
    80002f16:	020ddd93          	srli	s11,s11,0x20
    80002f1a:	05848793          	addi	a5,s1,88
    80002f1e:	86ee                	mv	a3,s11
    80002f20:	8656                	mv	a2,s5
    80002f22:	85e2                	mv	a1,s8
    80002f24:	953e                	add	a0,a0,a5
    80002f26:	fffff097          	auipc	ra,0xfffff
    80002f2a:	a5e080e7          	jalr	-1442(ra) # 80001984 <either_copyin>
    80002f2e:	07950263          	beq	a0,s9,80002f92 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002f32:	8526                	mv	a0,s1
    80002f34:	00000097          	auipc	ra,0x0
    80002f38:	790080e7          	jalr	1936(ra) # 800036c4 <log_write>
    brelse(bp);
    80002f3c:	8526                	mv	a0,s1
    80002f3e:	fffff097          	auipc	ra,0xfffff
    80002f42:	50a080e7          	jalr	1290(ra) # 80002448 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002f46:	01498a3b          	addw	s4,s3,s4
    80002f4a:	0129893b          	addw	s2,s3,s2
    80002f4e:	9aee                	add	s5,s5,s11
    80002f50:	057a7663          	bgeu	s4,s7,80002f9c <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80002f54:	000b2483          	lw	s1,0(s6)
    80002f58:	00a9559b          	srliw	a1,s2,0xa
    80002f5c:	855a                	mv	a0,s6
    80002f5e:	fffff097          	auipc	ra,0xfffff
    80002f62:	7ae080e7          	jalr	1966(ra) # 8000270c <bmap>
    80002f66:	0005059b          	sext.w	a1,a0
    80002f6a:	8526                	mv	a0,s1
    80002f6c:	fffff097          	auipc	ra,0xfffff
    80002f70:	3ac080e7          	jalr	940(ra) # 80002318 <bread>
    80002f74:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f76:	3ff97513          	andi	a0,s2,1023
    80002f7a:	40ad07bb          	subw	a5,s10,a0
    80002f7e:	414b873b          	subw	a4,s7,s4
    80002f82:	89be                	mv	s3,a5
    80002f84:	2781                	sext.w	a5,a5
    80002f86:	0007069b          	sext.w	a3,a4
    80002f8a:	f8f6f4e3          	bgeu	a3,a5,80002f12 <writei+0x4c>
    80002f8e:	89ba                	mv	s3,a4
    80002f90:	b749                	j	80002f12 <writei+0x4c>
      brelse(bp);
    80002f92:	8526                	mv	a0,s1
    80002f94:	fffff097          	auipc	ra,0xfffff
    80002f98:	4b4080e7          	jalr	1204(ra) # 80002448 <brelse>
  }

  if(off > ip->size)
    80002f9c:	04cb2783          	lw	a5,76(s6)
    80002fa0:	0127f463          	bgeu	a5,s2,80002fa8 <writei+0xe2>
    ip->size = off;
    80002fa4:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002fa8:	855a                	mv	a0,s6
    80002faa:	00000097          	auipc	ra,0x0
    80002fae:	aa6080e7          	jalr	-1370(ra) # 80002a50 <iupdate>

  return tot;
    80002fb2:	000a051b          	sext.w	a0,s4
}
    80002fb6:	70a6                	ld	ra,104(sp)
    80002fb8:	7406                	ld	s0,96(sp)
    80002fba:	64e6                	ld	s1,88(sp)
    80002fbc:	6946                	ld	s2,80(sp)
    80002fbe:	69a6                	ld	s3,72(sp)
    80002fc0:	6a06                	ld	s4,64(sp)
    80002fc2:	7ae2                	ld	s5,56(sp)
    80002fc4:	7b42                	ld	s6,48(sp)
    80002fc6:	7ba2                	ld	s7,40(sp)
    80002fc8:	7c02                	ld	s8,32(sp)
    80002fca:	6ce2                	ld	s9,24(sp)
    80002fcc:	6d42                	ld	s10,16(sp)
    80002fce:	6da2                	ld	s11,8(sp)
    80002fd0:	6165                	addi	sp,sp,112
    80002fd2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002fd4:	8a5e                	mv	s4,s7
    80002fd6:	bfc9                	j	80002fa8 <writei+0xe2>
    return -1;
    80002fd8:	557d                	li	a0,-1
}
    80002fda:	8082                	ret
    return -1;
    80002fdc:	557d                	li	a0,-1
    80002fde:	bfe1                	j	80002fb6 <writei+0xf0>
    return -1;
    80002fe0:	557d                	li	a0,-1
    80002fe2:	bfd1                	j	80002fb6 <writei+0xf0>

0000000080002fe4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002fe4:	1141                	addi	sp,sp,-16
    80002fe6:	e406                	sd	ra,8(sp)
    80002fe8:	e022                	sd	s0,0(sp)
    80002fea:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002fec:	4639                	li	a2,14
    80002fee:	ffffd097          	auipc	ra,0xffffd
    80002ff2:	262080e7          	jalr	610(ra) # 80000250 <strncmp>
}
    80002ff6:	60a2                	ld	ra,8(sp)
    80002ff8:	6402                	ld	s0,0(sp)
    80002ffa:	0141                	addi	sp,sp,16
    80002ffc:	8082                	ret

0000000080002ffe <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002ffe:	7139                	addi	sp,sp,-64
    80003000:	fc06                	sd	ra,56(sp)
    80003002:	f822                	sd	s0,48(sp)
    80003004:	f426                	sd	s1,40(sp)
    80003006:	f04a                	sd	s2,32(sp)
    80003008:	ec4e                	sd	s3,24(sp)
    8000300a:	e852                	sd	s4,16(sp)
    8000300c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000300e:	04451703          	lh	a4,68(a0)
    80003012:	4785                	li	a5,1
    80003014:	00f71a63          	bne	a4,a5,80003028 <dirlookup+0x2a>
    80003018:	892a                	mv	s2,a0
    8000301a:	89ae                	mv	s3,a1
    8000301c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000301e:	457c                	lw	a5,76(a0)
    80003020:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003022:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003024:	e79d                	bnez	a5,80003052 <dirlookup+0x54>
    80003026:	a8a5                	j	8000309e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003028:	00006517          	auipc	a0,0x6
    8000302c:	56850513          	addi	a0,a0,1384 # 80009590 <syscalls+0x1e0>
    80003030:	00004097          	auipc	ra,0x4
    80003034:	c04080e7          	jalr	-1020(ra) # 80006c34 <panic>
      panic("dirlookup read");
    80003038:	00006517          	auipc	a0,0x6
    8000303c:	57050513          	addi	a0,a0,1392 # 800095a8 <syscalls+0x1f8>
    80003040:	00004097          	auipc	ra,0x4
    80003044:	bf4080e7          	jalr	-1036(ra) # 80006c34 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003048:	24c1                	addiw	s1,s1,16
    8000304a:	04c92783          	lw	a5,76(s2)
    8000304e:	04f4f763          	bgeu	s1,a5,8000309c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003052:	4741                	li	a4,16
    80003054:	86a6                	mv	a3,s1
    80003056:	fc040613          	addi	a2,s0,-64
    8000305a:	4581                	li	a1,0
    8000305c:	854a                	mv	a0,s2
    8000305e:	00000097          	auipc	ra,0x0
    80003062:	d70080e7          	jalr	-656(ra) # 80002dce <readi>
    80003066:	47c1                	li	a5,16
    80003068:	fcf518e3          	bne	a0,a5,80003038 <dirlookup+0x3a>
    if(de.inum == 0)
    8000306c:	fc045783          	lhu	a5,-64(s0)
    80003070:	dfe1                	beqz	a5,80003048 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003072:	fc240593          	addi	a1,s0,-62
    80003076:	854e                	mv	a0,s3
    80003078:	00000097          	auipc	ra,0x0
    8000307c:	f6c080e7          	jalr	-148(ra) # 80002fe4 <namecmp>
    80003080:	f561                	bnez	a0,80003048 <dirlookup+0x4a>
      if(poff)
    80003082:	000a0463          	beqz	s4,8000308a <dirlookup+0x8c>
        *poff = off;
    80003086:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000308a:	fc045583          	lhu	a1,-64(s0)
    8000308e:	00092503          	lw	a0,0(s2)
    80003092:	fffff097          	auipc	ra,0xfffff
    80003096:	754080e7          	jalr	1876(ra) # 800027e6 <iget>
    8000309a:	a011                	j	8000309e <dirlookup+0xa0>
  return 0;
    8000309c:	4501                	li	a0,0
}
    8000309e:	70e2                	ld	ra,56(sp)
    800030a0:	7442                	ld	s0,48(sp)
    800030a2:	74a2                	ld	s1,40(sp)
    800030a4:	7902                	ld	s2,32(sp)
    800030a6:	69e2                	ld	s3,24(sp)
    800030a8:	6a42                	ld	s4,16(sp)
    800030aa:	6121                	addi	sp,sp,64
    800030ac:	8082                	ret

00000000800030ae <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800030ae:	711d                	addi	sp,sp,-96
    800030b0:	ec86                	sd	ra,88(sp)
    800030b2:	e8a2                	sd	s0,80(sp)
    800030b4:	e4a6                	sd	s1,72(sp)
    800030b6:	e0ca                	sd	s2,64(sp)
    800030b8:	fc4e                	sd	s3,56(sp)
    800030ba:	f852                	sd	s4,48(sp)
    800030bc:	f456                	sd	s5,40(sp)
    800030be:	f05a                	sd	s6,32(sp)
    800030c0:	ec5e                	sd	s7,24(sp)
    800030c2:	e862                	sd	s8,16(sp)
    800030c4:	e466                	sd	s9,8(sp)
    800030c6:	1080                	addi	s0,sp,96
    800030c8:	84aa                	mv	s1,a0
    800030ca:	8aae                	mv	s5,a1
    800030cc:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800030ce:	00054703          	lbu	a4,0(a0)
    800030d2:	02f00793          	li	a5,47
    800030d6:	02f70363          	beq	a4,a5,800030fc <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800030da:	ffffe097          	auipc	ra,0xffffe
    800030de:	de6080e7          	jalr	-538(ra) # 80000ec0 <myproc>
    800030e2:	15053503          	ld	a0,336(a0)
    800030e6:	00000097          	auipc	ra,0x0
    800030ea:	9f6080e7          	jalr	-1546(ra) # 80002adc <idup>
    800030ee:	89aa                	mv	s3,a0
  while(*path == '/')
    800030f0:	02f00913          	li	s2,47
  len = path - s;
    800030f4:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800030f6:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800030f8:	4b85                	li	s7,1
    800030fa:	a865                	j	800031b2 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800030fc:	4585                	li	a1,1
    800030fe:	4505                	li	a0,1
    80003100:	fffff097          	auipc	ra,0xfffff
    80003104:	6e6080e7          	jalr	1766(ra) # 800027e6 <iget>
    80003108:	89aa                	mv	s3,a0
    8000310a:	b7dd                	j	800030f0 <namex+0x42>
      iunlockput(ip);
    8000310c:	854e                	mv	a0,s3
    8000310e:	00000097          	auipc	ra,0x0
    80003112:	c6e080e7          	jalr	-914(ra) # 80002d7c <iunlockput>
      return 0;
    80003116:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003118:	854e                	mv	a0,s3
    8000311a:	60e6                	ld	ra,88(sp)
    8000311c:	6446                	ld	s0,80(sp)
    8000311e:	64a6                	ld	s1,72(sp)
    80003120:	6906                	ld	s2,64(sp)
    80003122:	79e2                	ld	s3,56(sp)
    80003124:	7a42                	ld	s4,48(sp)
    80003126:	7aa2                	ld	s5,40(sp)
    80003128:	7b02                	ld	s6,32(sp)
    8000312a:	6be2                	ld	s7,24(sp)
    8000312c:	6c42                	ld	s8,16(sp)
    8000312e:	6ca2                	ld	s9,8(sp)
    80003130:	6125                	addi	sp,sp,96
    80003132:	8082                	ret
      iunlock(ip);
    80003134:	854e                	mv	a0,s3
    80003136:	00000097          	auipc	ra,0x0
    8000313a:	aa6080e7          	jalr	-1370(ra) # 80002bdc <iunlock>
      return ip;
    8000313e:	bfe9                	j	80003118 <namex+0x6a>
      iunlockput(ip);
    80003140:	854e                	mv	a0,s3
    80003142:	00000097          	auipc	ra,0x0
    80003146:	c3a080e7          	jalr	-966(ra) # 80002d7c <iunlockput>
      return 0;
    8000314a:	89e6                	mv	s3,s9
    8000314c:	b7f1                	j	80003118 <namex+0x6a>
  len = path - s;
    8000314e:	40b48633          	sub	a2,s1,a1
    80003152:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003156:	099c5463          	bge	s8,s9,800031de <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000315a:	4639                	li	a2,14
    8000315c:	8552                	mv	a0,s4
    8000315e:	ffffd097          	auipc	ra,0xffffd
    80003162:	076080e7          	jalr	118(ra) # 800001d4 <memmove>
  while(*path == '/')
    80003166:	0004c783          	lbu	a5,0(s1)
    8000316a:	01279763          	bne	a5,s2,80003178 <namex+0xca>
    path++;
    8000316e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003170:	0004c783          	lbu	a5,0(s1)
    80003174:	ff278de3          	beq	a5,s2,8000316e <namex+0xc0>
    ilock(ip);
    80003178:	854e                	mv	a0,s3
    8000317a:	00000097          	auipc	ra,0x0
    8000317e:	9a0080e7          	jalr	-1632(ra) # 80002b1a <ilock>
    if(ip->type != T_DIR){
    80003182:	04499783          	lh	a5,68(s3)
    80003186:	f97793e3          	bne	a5,s7,8000310c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000318a:	000a8563          	beqz	s5,80003194 <namex+0xe6>
    8000318e:	0004c783          	lbu	a5,0(s1)
    80003192:	d3cd                	beqz	a5,80003134 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003194:	865a                	mv	a2,s6
    80003196:	85d2                	mv	a1,s4
    80003198:	854e                	mv	a0,s3
    8000319a:	00000097          	auipc	ra,0x0
    8000319e:	e64080e7          	jalr	-412(ra) # 80002ffe <dirlookup>
    800031a2:	8caa                	mv	s9,a0
    800031a4:	dd51                	beqz	a0,80003140 <namex+0x92>
    iunlockput(ip);
    800031a6:	854e                	mv	a0,s3
    800031a8:	00000097          	auipc	ra,0x0
    800031ac:	bd4080e7          	jalr	-1068(ra) # 80002d7c <iunlockput>
    ip = next;
    800031b0:	89e6                	mv	s3,s9
  while(*path == '/')
    800031b2:	0004c783          	lbu	a5,0(s1)
    800031b6:	05279763          	bne	a5,s2,80003204 <namex+0x156>
    path++;
    800031ba:	0485                	addi	s1,s1,1
  while(*path == '/')
    800031bc:	0004c783          	lbu	a5,0(s1)
    800031c0:	ff278de3          	beq	a5,s2,800031ba <namex+0x10c>
  if(*path == 0)
    800031c4:	c79d                	beqz	a5,800031f2 <namex+0x144>
    path++;
    800031c6:	85a6                	mv	a1,s1
  len = path - s;
    800031c8:	8cda                	mv	s9,s6
    800031ca:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800031cc:	01278963          	beq	a5,s2,800031de <namex+0x130>
    800031d0:	dfbd                	beqz	a5,8000314e <namex+0xa0>
    path++;
    800031d2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800031d4:	0004c783          	lbu	a5,0(s1)
    800031d8:	ff279ce3          	bne	a5,s2,800031d0 <namex+0x122>
    800031dc:	bf8d                	j	8000314e <namex+0xa0>
    memmove(name, s, len);
    800031de:	2601                	sext.w	a2,a2
    800031e0:	8552                	mv	a0,s4
    800031e2:	ffffd097          	auipc	ra,0xffffd
    800031e6:	ff2080e7          	jalr	-14(ra) # 800001d4 <memmove>
    name[len] = 0;
    800031ea:	9cd2                	add	s9,s9,s4
    800031ec:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800031f0:	bf9d                	j	80003166 <namex+0xb8>
  if(nameiparent){
    800031f2:	f20a83e3          	beqz	s5,80003118 <namex+0x6a>
    iput(ip);
    800031f6:	854e                	mv	a0,s3
    800031f8:	00000097          	auipc	ra,0x0
    800031fc:	adc080e7          	jalr	-1316(ra) # 80002cd4 <iput>
    return 0;
    80003200:	4981                	li	s3,0
    80003202:	bf19                	j	80003118 <namex+0x6a>
  if(*path == 0)
    80003204:	d7fd                	beqz	a5,800031f2 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003206:	0004c783          	lbu	a5,0(s1)
    8000320a:	85a6                	mv	a1,s1
    8000320c:	b7d1                	j	800031d0 <namex+0x122>

000000008000320e <dirlink>:
{
    8000320e:	7139                	addi	sp,sp,-64
    80003210:	fc06                	sd	ra,56(sp)
    80003212:	f822                	sd	s0,48(sp)
    80003214:	f426                	sd	s1,40(sp)
    80003216:	f04a                	sd	s2,32(sp)
    80003218:	ec4e                	sd	s3,24(sp)
    8000321a:	e852                	sd	s4,16(sp)
    8000321c:	0080                	addi	s0,sp,64
    8000321e:	892a                	mv	s2,a0
    80003220:	8a2e                	mv	s4,a1
    80003222:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003224:	4601                	li	a2,0
    80003226:	00000097          	auipc	ra,0x0
    8000322a:	dd8080e7          	jalr	-552(ra) # 80002ffe <dirlookup>
    8000322e:	e93d                	bnez	a0,800032a4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003230:	04c92483          	lw	s1,76(s2)
    80003234:	c49d                	beqz	s1,80003262 <dirlink+0x54>
    80003236:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003238:	4741                	li	a4,16
    8000323a:	86a6                	mv	a3,s1
    8000323c:	fc040613          	addi	a2,s0,-64
    80003240:	4581                	li	a1,0
    80003242:	854a                	mv	a0,s2
    80003244:	00000097          	auipc	ra,0x0
    80003248:	b8a080e7          	jalr	-1142(ra) # 80002dce <readi>
    8000324c:	47c1                	li	a5,16
    8000324e:	06f51163          	bne	a0,a5,800032b0 <dirlink+0xa2>
    if(de.inum == 0)
    80003252:	fc045783          	lhu	a5,-64(s0)
    80003256:	c791                	beqz	a5,80003262 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003258:	24c1                	addiw	s1,s1,16
    8000325a:	04c92783          	lw	a5,76(s2)
    8000325e:	fcf4ede3          	bltu	s1,a5,80003238 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003262:	4639                	li	a2,14
    80003264:	85d2                	mv	a1,s4
    80003266:	fc240513          	addi	a0,s0,-62
    8000326a:	ffffd097          	auipc	ra,0xffffd
    8000326e:	022080e7          	jalr	34(ra) # 8000028c <strncpy>
  de.inum = inum;
    80003272:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003276:	4741                	li	a4,16
    80003278:	86a6                	mv	a3,s1
    8000327a:	fc040613          	addi	a2,s0,-64
    8000327e:	4581                	li	a1,0
    80003280:	854a                	mv	a0,s2
    80003282:	00000097          	auipc	ra,0x0
    80003286:	c44080e7          	jalr	-956(ra) # 80002ec6 <writei>
    8000328a:	872a                	mv	a4,a0
    8000328c:	47c1                	li	a5,16
  return 0;
    8000328e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003290:	02f71863          	bne	a4,a5,800032c0 <dirlink+0xb2>
}
    80003294:	70e2                	ld	ra,56(sp)
    80003296:	7442                	ld	s0,48(sp)
    80003298:	74a2                	ld	s1,40(sp)
    8000329a:	7902                	ld	s2,32(sp)
    8000329c:	69e2                	ld	s3,24(sp)
    8000329e:	6a42                	ld	s4,16(sp)
    800032a0:	6121                	addi	sp,sp,64
    800032a2:	8082                	ret
    iput(ip);
    800032a4:	00000097          	auipc	ra,0x0
    800032a8:	a30080e7          	jalr	-1488(ra) # 80002cd4 <iput>
    return -1;
    800032ac:	557d                	li	a0,-1
    800032ae:	b7dd                	j	80003294 <dirlink+0x86>
      panic("dirlink read");
    800032b0:	00006517          	auipc	a0,0x6
    800032b4:	30850513          	addi	a0,a0,776 # 800095b8 <syscalls+0x208>
    800032b8:	00004097          	auipc	ra,0x4
    800032bc:	97c080e7          	jalr	-1668(ra) # 80006c34 <panic>
    panic("dirlink");
    800032c0:	00006517          	auipc	a0,0x6
    800032c4:	40850513          	addi	a0,a0,1032 # 800096c8 <syscalls+0x318>
    800032c8:	00004097          	auipc	ra,0x4
    800032cc:	96c080e7          	jalr	-1684(ra) # 80006c34 <panic>

00000000800032d0 <namei>:

struct inode*
namei(char *path)
{
    800032d0:	1101                	addi	sp,sp,-32
    800032d2:	ec06                	sd	ra,24(sp)
    800032d4:	e822                	sd	s0,16(sp)
    800032d6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800032d8:	fe040613          	addi	a2,s0,-32
    800032dc:	4581                	li	a1,0
    800032de:	00000097          	auipc	ra,0x0
    800032e2:	dd0080e7          	jalr	-560(ra) # 800030ae <namex>
}
    800032e6:	60e2                	ld	ra,24(sp)
    800032e8:	6442                	ld	s0,16(sp)
    800032ea:	6105                	addi	sp,sp,32
    800032ec:	8082                	ret

00000000800032ee <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800032ee:	1141                	addi	sp,sp,-16
    800032f0:	e406                	sd	ra,8(sp)
    800032f2:	e022                	sd	s0,0(sp)
    800032f4:	0800                	addi	s0,sp,16
    800032f6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800032f8:	4585                	li	a1,1
    800032fa:	00000097          	auipc	ra,0x0
    800032fe:	db4080e7          	jalr	-588(ra) # 800030ae <namex>
}
    80003302:	60a2                	ld	ra,8(sp)
    80003304:	6402                	ld	s0,0(sp)
    80003306:	0141                	addi	sp,sp,16
    80003308:	8082                	ret

000000008000330a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000330a:	1101                	addi	sp,sp,-32
    8000330c:	ec06                	sd	ra,24(sp)
    8000330e:	e822                	sd	s0,16(sp)
    80003310:	e426                	sd	s1,8(sp)
    80003312:	e04a                	sd	s2,0(sp)
    80003314:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003316:	00017917          	auipc	s2,0x17
    8000331a:	d1290913          	addi	s2,s2,-750 # 8001a028 <log>
    8000331e:	01892583          	lw	a1,24(s2)
    80003322:	02892503          	lw	a0,40(s2)
    80003326:	fffff097          	auipc	ra,0xfffff
    8000332a:	ff2080e7          	jalr	-14(ra) # 80002318 <bread>
    8000332e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003330:	02c92683          	lw	a3,44(s2)
    80003334:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003336:	02d05763          	blez	a3,80003364 <write_head+0x5a>
    8000333a:	00017797          	auipc	a5,0x17
    8000333e:	d1e78793          	addi	a5,a5,-738 # 8001a058 <log+0x30>
    80003342:	05c50713          	addi	a4,a0,92
    80003346:	36fd                	addiw	a3,a3,-1
    80003348:	1682                	slli	a3,a3,0x20
    8000334a:	9281                	srli	a3,a3,0x20
    8000334c:	068a                	slli	a3,a3,0x2
    8000334e:	00017617          	auipc	a2,0x17
    80003352:	d0e60613          	addi	a2,a2,-754 # 8001a05c <log+0x34>
    80003356:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003358:	4390                	lw	a2,0(a5)
    8000335a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000335c:	0791                	addi	a5,a5,4
    8000335e:	0711                	addi	a4,a4,4
    80003360:	fed79ce3          	bne	a5,a3,80003358 <write_head+0x4e>
  }
  bwrite(buf);
    80003364:	8526                	mv	a0,s1
    80003366:	fffff097          	auipc	ra,0xfffff
    8000336a:	0a4080e7          	jalr	164(ra) # 8000240a <bwrite>
  brelse(buf);
    8000336e:	8526                	mv	a0,s1
    80003370:	fffff097          	auipc	ra,0xfffff
    80003374:	0d8080e7          	jalr	216(ra) # 80002448 <brelse>
}
    80003378:	60e2                	ld	ra,24(sp)
    8000337a:	6442                	ld	s0,16(sp)
    8000337c:	64a2                	ld	s1,8(sp)
    8000337e:	6902                	ld	s2,0(sp)
    80003380:	6105                	addi	sp,sp,32
    80003382:	8082                	ret

0000000080003384 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003384:	00017797          	auipc	a5,0x17
    80003388:	cd07a783          	lw	a5,-816(a5) # 8001a054 <log+0x2c>
    8000338c:	0af05d63          	blez	a5,80003446 <install_trans+0xc2>
{
    80003390:	7139                	addi	sp,sp,-64
    80003392:	fc06                	sd	ra,56(sp)
    80003394:	f822                	sd	s0,48(sp)
    80003396:	f426                	sd	s1,40(sp)
    80003398:	f04a                	sd	s2,32(sp)
    8000339a:	ec4e                	sd	s3,24(sp)
    8000339c:	e852                	sd	s4,16(sp)
    8000339e:	e456                	sd	s5,8(sp)
    800033a0:	e05a                	sd	s6,0(sp)
    800033a2:	0080                	addi	s0,sp,64
    800033a4:	8b2a                	mv	s6,a0
    800033a6:	00017a97          	auipc	s5,0x17
    800033aa:	cb2a8a93          	addi	s5,s5,-846 # 8001a058 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800033ae:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800033b0:	00017997          	auipc	s3,0x17
    800033b4:	c7898993          	addi	s3,s3,-904 # 8001a028 <log>
    800033b8:	a00d                	j	800033da <install_trans+0x56>
    brelse(lbuf);
    800033ba:	854a                	mv	a0,s2
    800033bc:	fffff097          	auipc	ra,0xfffff
    800033c0:	08c080e7          	jalr	140(ra) # 80002448 <brelse>
    brelse(dbuf);
    800033c4:	8526                	mv	a0,s1
    800033c6:	fffff097          	auipc	ra,0xfffff
    800033ca:	082080e7          	jalr	130(ra) # 80002448 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800033ce:	2a05                	addiw	s4,s4,1
    800033d0:	0a91                	addi	s5,s5,4
    800033d2:	02c9a783          	lw	a5,44(s3)
    800033d6:	04fa5e63          	bge	s4,a5,80003432 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800033da:	0189a583          	lw	a1,24(s3)
    800033de:	014585bb          	addw	a1,a1,s4
    800033e2:	2585                	addiw	a1,a1,1
    800033e4:	0289a503          	lw	a0,40(s3)
    800033e8:	fffff097          	auipc	ra,0xfffff
    800033ec:	f30080e7          	jalr	-208(ra) # 80002318 <bread>
    800033f0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800033f2:	000aa583          	lw	a1,0(s5)
    800033f6:	0289a503          	lw	a0,40(s3)
    800033fa:	fffff097          	auipc	ra,0xfffff
    800033fe:	f1e080e7          	jalr	-226(ra) # 80002318 <bread>
    80003402:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003404:	40000613          	li	a2,1024
    80003408:	05890593          	addi	a1,s2,88
    8000340c:	05850513          	addi	a0,a0,88
    80003410:	ffffd097          	auipc	ra,0xffffd
    80003414:	dc4080e7          	jalr	-572(ra) # 800001d4 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003418:	8526                	mv	a0,s1
    8000341a:	fffff097          	auipc	ra,0xfffff
    8000341e:	ff0080e7          	jalr	-16(ra) # 8000240a <bwrite>
    if(recovering == 0)
    80003422:	f80b1ce3          	bnez	s6,800033ba <install_trans+0x36>
      bunpin(dbuf);
    80003426:	8526                	mv	a0,s1
    80003428:	fffff097          	auipc	ra,0xfffff
    8000342c:	0fa080e7          	jalr	250(ra) # 80002522 <bunpin>
    80003430:	b769                	j	800033ba <install_trans+0x36>
}
    80003432:	70e2                	ld	ra,56(sp)
    80003434:	7442                	ld	s0,48(sp)
    80003436:	74a2                	ld	s1,40(sp)
    80003438:	7902                	ld	s2,32(sp)
    8000343a:	69e2                	ld	s3,24(sp)
    8000343c:	6a42                	ld	s4,16(sp)
    8000343e:	6aa2                	ld	s5,8(sp)
    80003440:	6b02                	ld	s6,0(sp)
    80003442:	6121                	addi	sp,sp,64
    80003444:	8082                	ret
    80003446:	8082                	ret

0000000080003448 <initlog>:
{
    80003448:	7179                	addi	sp,sp,-48
    8000344a:	f406                	sd	ra,40(sp)
    8000344c:	f022                	sd	s0,32(sp)
    8000344e:	ec26                	sd	s1,24(sp)
    80003450:	e84a                	sd	s2,16(sp)
    80003452:	e44e                	sd	s3,8(sp)
    80003454:	1800                	addi	s0,sp,48
    80003456:	892a                	mv	s2,a0
    80003458:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000345a:	00017497          	auipc	s1,0x17
    8000345e:	bce48493          	addi	s1,s1,-1074 # 8001a028 <log>
    80003462:	00006597          	auipc	a1,0x6
    80003466:	16658593          	addi	a1,a1,358 # 800095c8 <syscalls+0x218>
    8000346a:	8526                	mv	a0,s1
    8000346c:	00004097          	auipc	ra,0x4
    80003470:	c74080e7          	jalr	-908(ra) # 800070e0 <initlock>
  log.start = sb->logstart;
    80003474:	0149a583          	lw	a1,20(s3)
    80003478:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000347a:	0109a783          	lw	a5,16(s3)
    8000347e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003480:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003484:	854a                	mv	a0,s2
    80003486:	fffff097          	auipc	ra,0xfffff
    8000348a:	e92080e7          	jalr	-366(ra) # 80002318 <bread>
  log.lh.n = lh->n;
    8000348e:	4d34                	lw	a3,88(a0)
    80003490:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003492:	02d05563          	blez	a3,800034bc <initlog+0x74>
    80003496:	05c50793          	addi	a5,a0,92
    8000349a:	00017717          	auipc	a4,0x17
    8000349e:	bbe70713          	addi	a4,a4,-1090 # 8001a058 <log+0x30>
    800034a2:	36fd                	addiw	a3,a3,-1
    800034a4:	1682                	slli	a3,a3,0x20
    800034a6:	9281                	srli	a3,a3,0x20
    800034a8:	068a                	slli	a3,a3,0x2
    800034aa:	06050613          	addi	a2,a0,96
    800034ae:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800034b0:	4390                	lw	a2,0(a5)
    800034b2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800034b4:	0791                	addi	a5,a5,4
    800034b6:	0711                	addi	a4,a4,4
    800034b8:	fed79ce3          	bne	a5,a3,800034b0 <initlog+0x68>
  brelse(buf);
    800034bc:	fffff097          	auipc	ra,0xfffff
    800034c0:	f8c080e7          	jalr	-116(ra) # 80002448 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800034c4:	4505                	li	a0,1
    800034c6:	00000097          	auipc	ra,0x0
    800034ca:	ebe080e7          	jalr	-322(ra) # 80003384 <install_trans>
  log.lh.n = 0;
    800034ce:	00017797          	auipc	a5,0x17
    800034d2:	b807a323          	sw	zero,-1146(a5) # 8001a054 <log+0x2c>
  write_head(); // clear the log
    800034d6:	00000097          	auipc	ra,0x0
    800034da:	e34080e7          	jalr	-460(ra) # 8000330a <write_head>
}
    800034de:	70a2                	ld	ra,40(sp)
    800034e0:	7402                	ld	s0,32(sp)
    800034e2:	64e2                	ld	s1,24(sp)
    800034e4:	6942                	ld	s2,16(sp)
    800034e6:	69a2                	ld	s3,8(sp)
    800034e8:	6145                	addi	sp,sp,48
    800034ea:	8082                	ret

00000000800034ec <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800034ec:	1101                	addi	sp,sp,-32
    800034ee:	ec06                	sd	ra,24(sp)
    800034f0:	e822                	sd	s0,16(sp)
    800034f2:	e426                	sd	s1,8(sp)
    800034f4:	e04a                	sd	s2,0(sp)
    800034f6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800034f8:	00017517          	auipc	a0,0x17
    800034fc:	b3050513          	addi	a0,a0,-1232 # 8001a028 <log>
    80003500:	00004097          	auipc	ra,0x4
    80003504:	c70080e7          	jalr	-912(ra) # 80007170 <acquire>
  while(1){
    if(log.committing){
    80003508:	00017497          	auipc	s1,0x17
    8000350c:	b2048493          	addi	s1,s1,-1248 # 8001a028 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003510:	4979                	li	s2,30
    80003512:	a039                	j	80003520 <begin_op+0x34>
      sleep(&log, &log.lock);
    80003514:	85a6                	mv	a1,s1
    80003516:	8526                	mv	a0,s1
    80003518:	ffffe097          	auipc	ra,0xffffe
    8000351c:	1bc080e7          	jalr	444(ra) # 800016d4 <sleep>
    if(log.committing){
    80003520:	50dc                	lw	a5,36(s1)
    80003522:	fbed                	bnez	a5,80003514 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003524:	509c                	lw	a5,32(s1)
    80003526:	0017871b          	addiw	a4,a5,1
    8000352a:	0007069b          	sext.w	a3,a4
    8000352e:	0027179b          	slliw	a5,a4,0x2
    80003532:	9fb9                	addw	a5,a5,a4
    80003534:	0017979b          	slliw	a5,a5,0x1
    80003538:	54d8                	lw	a4,44(s1)
    8000353a:	9fb9                	addw	a5,a5,a4
    8000353c:	00f95963          	bge	s2,a5,8000354e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003540:	85a6                	mv	a1,s1
    80003542:	8526                	mv	a0,s1
    80003544:	ffffe097          	auipc	ra,0xffffe
    80003548:	190080e7          	jalr	400(ra) # 800016d4 <sleep>
    8000354c:	bfd1                	j	80003520 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000354e:	00017517          	auipc	a0,0x17
    80003552:	ada50513          	addi	a0,a0,-1318 # 8001a028 <log>
    80003556:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80003558:	00004097          	auipc	ra,0x4
    8000355c:	ccc080e7          	jalr	-820(ra) # 80007224 <release>
      break;
    }
  }
}
    80003560:	60e2                	ld	ra,24(sp)
    80003562:	6442                	ld	s0,16(sp)
    80003564:	64a2                	ld	s1,8(sp)
    80003566:	6902                	ld	s2,0(sp)
    80003568:	6105                	addi	sp,sp,32
    8000356a:	8082                	ret

000000008000356c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000356c:	7139                	addi	sp,sp,-64
    8000356e:	fc06                	sd	ra,56(sp)
    80003570:	f822                	sd	s0,48(sp)
    80003572:	f426                	sd	s1,40(sp)
    80003574:	f04a                	sd	s2,32(sp)
    80003576:	ec4e                	sd	s3,24(sp)
    80003578:	e852                	sd	s4,16(sp)
    8000357a:	e456                	sd	s5,8(sp)
    8000357c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000357e:	00017497          	auipc	s1,0x17
    80003582:	aaa48493          	addi	s1,s1,-1366 # 8001a028 <log>
    80003586:	8526                	mv	a0,s1
    80003588:	00004097          	auipc	ra,0x4
    8000358c:	be8080e7          	jalr	-1048(ra) # 80007170 <acquire>
  log.outstanding -= 1;
    80003590:	509c                	lw	a5,32(s1)
    80003592:	37fd                	addiw	a5,a5,-1
    80003594:	0007891b          	sext.w	s2,a5
    80003598:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000359a:	50dc                	lw	a5,36(s1)
    8000359c:	e7b9                	bnez	a5,800035ea <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000359e:	04091e63          	bnez	s2,800035fa <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800035a2:	00017497          	auipc	s1,0x17
    800035a6:	a8648493          	addi	s1,s1,-1402 # 8001a028 <log>
    800035aa:	4785                	li	a5,1
    800035ac:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800035ae:	8526                	mv	a0,s1
    800035b0:	00004097          	auipc	ra,0x4
    800035b4:	c74080e7          	jalr	-908(ra) # 80007224 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800035b8:	54dc                	lw	a5,44(s1)
    800035ba:	06f04763          	bgtz	a5,80003628 <end_op+0xbc>
    acquire(&log.lock);
    800035be:	00017497          	auipc	s1,0x17
    800035c2:	a6a48493          	addi	s1,s1,-1430 # 8001a028 <log>
    800035c6:	8526                	mv	a0,s1
    800035c8:	00004097          	auipc	ra,0x4
    800035cc:	ba8080e7          	jalr	-1112(ra) # 80007170 <acquire>
    log.committing = 0;
    800035d0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800035d4:	8526                	mv	a0,s1
    800035d6:	ffffe097          	auipc	ra,0xffffe
    800035da:	27e080e7          	jalr	638(ra) # 80001854 <wakeup>
    release(&log.lock);
    800035de:	8526                	mv	a0,s1
    800035e0:	00004097          	auipc	ra,0x4
    800035e4:	c44080e7          	jalr	-956(ra) # 80007224 <release>
}
    800035e8:	a03d                	j	80003616 <end_op+0xaa>
    panic("log.committing");
    800035ea:	00006517          	auipc	a0,0x6
    800035ee:	fe650513          	addi	a0,a0,-26 # 800095d0 <syscalls+0x220>
    800035f2:	00003097          	auipc	ra,0x3
    800035f6:	642080e7          	jalr	1602(ra) # 80006c34 <panic>
    wakeup(&log);
    800035fa:	00017497          	auipc	s1,0x17
    800035fe:	a2e48493          	addi	s1,s1,-1490 # 8001a028 <log>
    80003602:	8526                	mv	a0,s1
    80003604:	ffffe097          	auipc	ra,0xffffe
    80003608:	250080e7          	jalr	592(ra) # 80001854 <wakeup>
  release(&log.lock);
    8000360c:	8526                	mv	a0,s1
    8000360e:	00004097          	auipc	ra,0x4
    80003612:	c16080e7          	jalr	-1002(ra) # 80007224 <release>
}
    80003616:	70e2                	ld	ra,56(sp)
    80003618:	7442                	ld	s0,48(sp)
    8000361a:	74a2                	ld	s1,40(sp)
    8000361c:	7902                	ld	s2,32(sp)
    8000361e:	69e2                	ld	s3,24(sp)
    80003620:	6a42                	ld	s4,16(sp)
    80003622:	6aa2                	ld	s5,8(sp)
    80003624:	6121                	addi	sp,sp,64
    80003626:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003628:	00017a97          	auipc	s5,0x17
    8000362c:	a30a8a93          	addi	s5,s5,-1488 # 8001a058 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003630:	00017a17          	auipc	s4,0x17
    80003634:	9f8a0a13          	addi	s4,s4,-1544 # 8001a028 <log>
    80003638:	018a2583          	lw	a1,24(s4)
    8000363c:	012585bb          	addw	a1,a1,s2
    80003640:	2585                	addiw	a1,a1,1
    80003642:	028a2503          	lw	a0,40(s4)
    80003646:	fffff097          	auipc	ra,0xfffff
    8000364a:	cd2080e7          	jalr	-814(ra) # 80002318 <bread>
    8000364e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003650:	000aa583          	lw	a1,0(s5)
    80003654:	028a2503          	lw	a0,40(s4)
    80003658:	fffff097          	auipc	ra,0xfffff
    8000365c:	cc0080e7          	jalr	-832(ra) # 80002318 <bread>
    80003660:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003662:	40000613          	li	a2,1024
    80003666:	05850593          	addi	a1,a0,88
    8000366a:	05848513          	addi	a0,s1,88
    8000366e:	ffffd097          	auipc	ra,0xffffd
    80003672:	b66080e7          	jalr	-1178(ra) # 800001d4 <memmove>
    bwrite(to);  // write the log
    80003676:	8526                	mv	a0,s1
    80003678:	fffff097          	auipc	ra,0xfffff
    8000367c:	d92080e7          	jalr	-622(ra) # 8000240a <bwrite>
    brelse(from);
    80003680:	854e                	mv	a0,s3
    80003682:	fffff097          	auipc	ra,0xfffff
    80003686:	dc6080e7          	jalr	-570(ra) # 80002448 <brelse>
    brelse(to);
    8000368a:	8526                	mv	a0,s1
    8000368c:	fffff097          	auipc	ra,0xfffff
    80003690:	dbc080e7          	jalr	-580(ra) # 80002448 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003694:	2905                	addiw	s2,s2,1
    80003696:	0a91                	addi	s5,s5,4
    80003698:	02ca2783          	lw	a5,44(s4)
    8000369c:	f8f94ee3          	blt	s2,a5,80003638 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800036a0:	00000097          	auipc	ra,0x0
    800036a4:	c6a080e7          	jalr	-918(ra) # 8000330a <write_head>
    install_trans(0); // Now install writes to home locations
    800036a8:	4501                	li	a0,0
    800036aa:	00000097          	auipc	ra,0x0
    800036ae:	cda080e7          	jalr	-806(ra) # 80003384 <install_trans>
    log.lh.n = 0;
    800036b2:	00017797          	auipc	a5,0x17
    800036b6:	9a07a123          	sw	zero,-1630(a5) # 8001a054 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800036ba:	00000097          	auipc	ra,0x0
    800036be:	c50080e7          	jalr	-944(ra) # 8000330a <write_head>
    800036c2:	bdf5                	j	800035be <end_op+0x52>

00000000800036c4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800036c4:	1101                	addi	sp,sp,-32
    800036c6:	ec06                	sd	ra,24(sp)
    800036c8:	e822                	sd	s0,16(sp)
    800036ca:	e426                	sd	s1,8(sp)
    800036cc:	e04a                	sd	s2,0(sp)
    800036ce:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800036d0:	00017717          	auipc	a4,0x17
    800036d4:	98472703          	lw	a4,-1660(a4) # 8001a054 <log+0x2c>
    800036d8:	47f5                	li	a5,29
    800036da:	08e7c063          	blt	a5,a4,8000375a <log_write+0x96>
    800036de:	84aa                	mv	s1,a0
    800036e0:	00017797          	auipc	a5,0x17
    800036e4:	9647a783          	lw	a5,-1692(a5) # 8001a044 <log+0x1c>
    800036e8:	37fd                	addiw	a5,a5,-1
    800036ea:	06f75863          	bge	a4,a5,8000375a <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800036ee:	00017797          	auipc	a5,0x17
    800036f2:	95a7a783          	lw	a5,-1702(a5) # 8001a048 <log+0x20>
    800036f6:	06f05a63          	blez	a5,8000376a <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800036fa:	00017917          	auipc	s2,0x17
    800036fe:	92e90913          	addi	s2,s2,-1746 # 8001a028 <log>
    80003702:	854a                	mv	a0,s2
    80003704:	00004097          	auipc	ra,0x4
    80003708:	a6c080e7          	jalr	-1428(ra) # 80007170 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    8000370c:	02c92603          	lw	a2,44(s2)
    80003710:	06c05563          	blez	a2,8000377a <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80003714:	44cc                	lw	a1,12(s1)
    80003716:	00017717          	auipc	a4,0x17
    8000371a:	94270713          	addi	a4,a4,-1726 # 8001a058 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000371e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80003720:	4314                	lw	a3,0(a4)
    80003722:	04b68d63          	beq	a3,a1,8000377c <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80003726:	2785                	addiw	a5,a5,1
    80003728:	0711                	addi	a4,a4,4
    8000372a:	fec79be3          	bne	a5,a2,80003720 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000372e:	0621                	addi	a2,a2,8
    80003730:	060a                	slli	a2,a2,0x2
    80003732:	00017797          	auipc	a5,0x17
    80003736:	8f678793          	addi	a5,a5,-1802 # 8001a028 <log>
    8000373a:	963e                	add	a2,a2,a5
    8000373c:	44dc                	lw	a5,12(s1)
    8000373e:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003740:	8526                	mv	a0,s1
    80003742:	fffff097          	auipc	ra,0xfffff
    80003746:	da4080e7          	jalr	-604(ra) # 800024e6 <bpin>
    log.lh.n++;
    8000374a:	00017717          	auipc	a4,0x17
    8000374e:	8de70713          	addi	a4,a4,-1826 # 8001a028 <log>
    80003752:	575c                	lw	a5,44(a4)
    80003754:	2785                	addiw	a5,a5,1
    80003756:	d75c                	sw	a5,44(a4)
    80003758:	a83d                	j	80003796 <log_write+0xd2>
    panic("too big a transaction");
    8000375a:	00006517          	auipc	a0,0x6
    8000375e:	e8650513          	addi	a0,a0,-378 # 800095e0 <syscalls+0x230>
    80003762:	00003097          	auipc	ra,0x3
    80003766:	4d2080e7          	jalr	1234(ra) # 80006c34 <panic>
    panic("log_write outside of trans");
    8000376a:	00006517          	auipc	a0,0x6
    8000376e:	e8e50513          	addi	a0,a0,-370 # 800095f8 <syscalls+0x248>
    80003772:	00003097          	auipc	ra,0x3
    80003776:	4c2080e7          	jalr	1218(ra) # 80006c34 <panic>
  for (i = 0; i < log.lh.n; i++) {
    8000377a:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    8000377c:	00878713          	addi	a4,a5,8
    80003780:	00271693          	slli	a3,a4,0x2
    80003784:	00017717          	auipc	a4,0x17
    80003788:	8a470713          	addi	a4,a4,-1884 # 8001a028 <log>
    8000378c:	9736                	add	a4,a4,a3
    8000378e:	44d4                	lw	a3,12(s1)
    80003790:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003792:	faf607e3          	beq	a2,a5,80003740 <log_write+0x7c>
  }
  release(&log.lock);
    80003796:	00017517          	auipc	a0,0x17
    8000379a:	89250513          	addi	a0,a0,-1902 # 8001a028 <log>
    8000379e:	00004097          	auipc	ra,0x4
    800037a2:	a86080e7          	jalr	-1402(ra) # 80007224 <release>
}
    800037a6:	60e2                	ld	ra,24(sp)
    800037a8:	6442                	ld	s0,16(sp)
    800037aa:	64a2                	ld	s1,8(sp)
    800037ac:	6902                	ld	s2,0(sp)
    800037ae:	6105                	addi	sp,sp,32
    800037b0:	8082                	ret

00000000800037b2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800037b2:	1101                	addi	sp,sp,-32
    800037b4:	ec06                	sd	ra,24(sp)
    800037b6:	e822                	sd	s0,16(sp)
    800037b8:	e426                	sd	s1,8(sp)
    800037ba:	e04a                	sd	s2,0(sp)
    800037bc:	1000                	addi	s0,sp,32
    800037be:	84aa                	mv	s1,a0
    800037c0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800037c2:	00006597          	auipc	a1,0x6
    800037c6:	e5658593          	addi	a1,a1,-426 # 80009618 <syscalls+0x268>
    800037ca:	0521                	addi	a0,a0,8
    800037cc:	00004097          	auipc	ra,0x4
    800037d0:	914080e7          	jalr	-1772(ra) # 800070e0 <initlock>
  lk->name = name;
    800037d4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800037d8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800037dc:	0204a423          	sw	zero,40(s1)
}
    800037e0:	60e2                	ld	ra,24(sp)
    800037e2:	6442                	ld	s0,16(sp)
    800037e4:	64a2                	ld	s1,8(sp)
    800037e6:	6902                	ld	s2,0(sp)
    800037e8:	6105                	addi	sp,sp,32
    800037ea:	8082                	ret

00000000800037ec <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800037ec:	1101                	addi	sp,sp,-32
    800037ee:	ec06                	sd	ra,24(sp)
    800037f0:	e822                	sd	s0,16(sp)
    800037f2:	e426                	sd	s1,8(sp)
    800037f4:	e04a                	sd	s2,0(sp)
    800037f6:	1000                	addi	s0,sp,32
    800037f8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800037fa:	00850913          	addi	s2,a0,8
    800037fe:	854a                	mv	a0,s2
    80003800:	00004097          	auipc	ra,0x4
    80003804:	970080e7          	jalr	-1680(ra) # 80007170 <acquire>
  while (lk->locked) {
    80003808:	409c                	lw	a5,0(s1)
    8000380a:	cb89                	beqz	a5,8000381c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000380c:	85ca                	mv	a1,s2
    8000380e:	8526                	mv	a0,s1
    80003810:	ffffe097          	auipc	ra,0xffffe
    80003814:	ec4080e7          	jalr	-316(ra) # 800016d4 <sleep>
  while (lk->locked) {
    80003818:	409c                	lw	a5,0(s1)
    8000381a:	fbed                	bnez	a5,8000380c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000381c:	4785                	li	a5,1
    8000381e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003820:	ffffd097          	auipc	ra,0xffffd
    80003824:	6a0080e7          	jalr	1696(ra) # 80000ec0 <myproc>
    80003828:	5d1c                	lw	a5,56(a0)
    8000382a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000382c:	854a                	mv	a0,s2
    8000382e:	00004097          	auipc	ra,0x4
    80003832:	9f6080e7          	jalr	-1546(ra) # 80007224 <release>
}
    80003836:	60e2                	ld	ra,24(sp)
    80003838:	6442                	ld	s0,16(sp)
    8000383a:	64a2                	ld	s1,8(sp)
    8000383c:	6902                	ld	s2,0(sp)
    8000383e:	6105                	addi	sp,sp,32
    80003840:	8082                	ret

0000000080003842 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003842:	1101                	addi	sp,sp,-32
    80003844:	ec06                	sd	ra,24(sp)
    80003846:	e822                	sd	s0,16(sp)
    80003848:	e426                	sd	s1,8(sp)
    8000384a:	e04a                	sd	s2,0(sp)
    8000384c:	1000                	addi	s0,sp,32
    8000384e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003850:	00850913          	addi	s2,a0,8
    80003854:	854a                	mv	a0,s2
    80003856:	00004097          	auipc	ra,0x4
    8000385a:	91a080e7          	jalr	-1766(ra) # 80007170 <acquire>
  lk->locked = 0;
    8000385e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003862:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003866:	8526                	mv	a0,s1
    80003868:	ffffe097          	auipc	ra,0xffffe
    8000386c:	fec080e7          	jalr	-20(ra) # 80001854 <wakeup>
  release(&lk->lk);
    80003870:	854a                	mv	a0,s2
    80003872:	00004097          	auipc	ra,0x4
    80003876:	9b2080e7          	jalr	-1614(ra) # 80007224 <release>
}
    8000387a:	60e2                	ld	ra,24(sp)
    8000387c:	6442                	ld	s0,16(sp)
    8000387e:	64a2                	ld	s1,8(sp)
    80003880:	6902                	ld	s2,0(sp)
    80003882:	6105                	addi	sp,sp,32
    80003884:	8082                	ret

0000000080003886 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003886:	7179                	addi	sp,sp,-48
    80003888:	f406                	sd	ra,40(sp)
    8000388a:	f022                	sd	s0,32(sp)
    8000388c:	ec26                	sd	s1,24(sp)
    8000388e:	e84a                	sd	s2,16(sp)
    80003890:	e44e                	sd	s3,8(sp)
    80003892:	1800                	addi	s0,sp,48
    80003894:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003896:	00850913          	addi	s2,a0,8
    8000389a:	854a                	mv	a0,s2
    8000389c:	00004097          	auipc	ra,0x4
    800038a0:	8d4080e7          	jalr	-1836(ra) # 80007170 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800038a4:	409c                	lw	a5,0(s1)
    800038a6:	ef99                	bnez	a5,800038c4 <holdingsleep+0x3e>
    800038a8:	4481                	li	s1,0
  release(&lk->lk);
    800038aa:	854a                	mv	a0,s2
    800038ac:	00004097          	auipc	ra,0x4
    800038b0:	978080e7          	jalr	-1672(ra) # 80007224 <release>
  return r;
}
    800038b4:	8526                	mv	a0,s1
    800038b6:	70a2                	ld	ra,40(sp)
    800038b8:	7402                	ld	s0,32(sp)
    800038ba:	64e2                	ld	s1,24(sp)
    800038bc:	6942                	ld	s2,16(sp)
    800038be:	69a2                	ld	s3,8(sp)
    800038c0:	6145                	addi	sp,sp,48
    800038c2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800038c4:	0284a983          	lw	s3,40(s1)
    800038c8:	ffffd097          	auipc	ra,0xffffd
    800038cc:	5f8080e7          	jalr	1528(ra) # 80000ec0 <myproc>
    800038d0:	5d04                	lw	s1,56(a0)
    800038d2:	413484b3          	sub	s1,s1,s3
    800038d6:	0014b493          	seqz	s1,s1
    800038da:	bfc1                	j	800038aa <holdingsleep+0x24>

00000000800038dc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800038dc:	1141                	addi	sp,sp,-16
    800038de:	e406                	sd	ra,8(sp)
    800038e0:	e022                	sd	s0,0(sp)
    800038e2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800038e4:	00006597          	auipc	a1,0x6
    800038e8:	d4458593          	addi	a1,a1,-700 # 80009628 <syscalls+0x278>
    800038ec:	00017517          	auipc	a0,0x17
    800038f0:	88450513          	addi	a0,a0,-1916 # 8001a170 <ftable>
    800038f4:	00003097          	auipc	ra,0x3
    800038f8:	7ec080e7          	jalr	2028(ra) # 800070e0 <initlock>
}
    800038fc:	60a2                	ld	ra,8(sp)
    800038fe:	6402                	ld	s0,0(sp)
    80003900:	0141                	addi	sp,sp,16
    80003902:	8082                	ret

0000000080003904 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003904:	1101                	addi	sp,sp,-32
    80003906:	ec06                	sd	ra,24(sp)
    80003908:	e822                	sd	s0,16(sp)
    8000390a:	e426                	sd	s1,8(sp)
    8000390c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000390e:	00017517          	auipc	a0,0x17
    80003912:	86250513          	addi	a0,a0,-1950 # 8001a170 <ftable>
    80003916:	00004097          	auipc	ra,0x4
    8000391a:	85a080e7          	jalr	-1958(ra) # 80007170 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000391e:	00017497          	auipc	s1,0x17
    80003922:	86a48493          	addi	s1,s1,-1942 # 8001a188 <ftable+0x18>
    80003926:	00018717          	auipc	a4,0x18
    8000392a:	b2270713          	addi	a4,a4,-1246 # 8001b448 <ftable+0x12d8>
    if(f->ref == 0){
    8000392e:	40dc                	lw	a5,4(s1)
    80003930:	cf99                	beqz	a5,8000394e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003932:	03048493          	addi	s1,s1,48
    80003936:	fee49ce3          	bne	s1,a4,8000392e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000393a:	00017517          	auipc	a0,0x17
    8000393e:	83650513          	addi	a0,a0,-1994 # 8001a170 <ftable>
    80003942:	00004097          	auipc	ra,0x4
    80003946:	8e2080e7          	jalr	-1822(ra) # 80007224 <release>
  return 0;
    8000394a:	4481                	li	s1,0
    8000394c:	a819                	j	80003962 <filealloc+0x5e>
      f->ref = 1;
    8000394e:	4785                	li	a5,1
    80003950:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003952:	00017517          	auipc	a0,0x17
    80003956:	81e50513          	addi	a0,a0,-2018 # 8001a170 <ftable>
    8000395a:	00004097          	auipc	ra,0x4
    8000395e:	8ca080e7          	jalr	-1846(ra) # 80007224 <release>
}
    80003962:	8526                	mv	a0,s1
    80003964:	60e2                	ld	ra,24(sp)
    80003966:	6442                	ld	s0,16(sp)
    80003968:	64a2                	ld	s1,8(sp)
    8000396a:	6105                	addi	sp,sp,32
    8000396c:	8082                	ret

000000008000396e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000396e:	1101                	addi	sp,sp,-32
    80003970:	ec06                	sd	ra,24(sp)
    80003972:	e822                	sd	s0,16(sp)
    80003974:	e426                	sd	s1,8(sp)
    80003976:	1000                	addi	s0,sp,32
    80003978:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000397a:	00016517          	auipc	a0,0x16
    8000397e:	7f650513          	addi	a0,a0,2038 # 8001a170 <ftable>
    80003982:	00003097          	auipc	ra,0x3
    80003986:	7ee080e7          	jalr	2030(ra) # 80007170 <acquire>
  if(f->ref < 1)
    8000398a:	40dc                	lw	a5,4(s1)
    8000398c:	02f05263          	blez	a5,800039b0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80003990:	2785                	addiw	a5,a5,1
    80003992:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003994:	00016517          	auipc	a0,0x16
    80003998:	7dc50513          	addi	a0,a0,2012 # 8001a170 <ftable>
    8000399c:	00004097          	auipc	ra,0x4
    800039a0:	888080e7          	jalr	-1912(ra) # 80007224 <release>
  return f;
}
    800039a4:	8526                	mv	a0,s1
    800039a6:	60e2                	ld	ra,24(sp)
    800039a8:	6442                	ld	s0,16(sp)
    800039aa:	64a2                	ld	s1,8(sp)
    800039ac:	6105                	addi	sp,sp,32
    800039ae:	8082                	ret
    panic("filedup");
    800039b0:	00006517          	auipc	a0,0x6
    800039b4:	c8050513          	addi	a0,a0,-896 # 80009630 <syscalls+0x280>
    800039b8:	00003097          	auipc	ra,0x3
    800039bc:	27c080e7          	jalr	636(ra) # 80006c34 <panic>

00000000800039c0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800039c0:	7139                	addi	sp,sp,-64
    800039c2:	fc06                	sd	ra,56(sp)
    800039c4:	f822                	sd	s0,48(sp)
    800039c6:	f426                	sd	s1,40(sp)
    800039c8:	f04a                	sd	s2,32(sp)
    800039ca:	ec4e                	sd	s3,24(sp)
    800039cc:	e852                	sd	s4,16(sp)
    800039ce:	e456                	sd	s5,8(sp)
    800039d0:	e05a                	sd	s6,0(sp)
    800039d2:	0080                	addi	s0,sp,64
    800039d4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800039d6:	00016517          	auipc	a0,0x16
    800039da:	79a50513          	addi	a0,a0,1946 # 8001a170 <ftable>
    800039de:	00003097          	auipc	ra,0x3
    800039e2:	792080e7          	jalr	1938(ra) # 80007170 <acquire>
  if(f->ref < 1)
    800039e6:	40dc                	lw	a5,4(s1)
    800039e8:	04f05f63          	blez	a5,80003a46 <fileclose+0x86>
    panic("fileclose");
  if(--f->ref > 0){
    800039ec:	37fd                	addiw	a5,a5,-1
    800039ee:	0007871b          	sext.w	a4,a5
    800039f2:	c0dc                	sw	a5,4(s1)
    800039f4:	06e04163          	bgtz	a4,80003a56 <fileclose+0x96>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800039f8:	0004a903          	lw	s2,0(s1)
    800039fc:	0094ca83          	lbu	s5,9(s1)
    80003a00:	0104ba03          	ld	s4,16(s1)
    80003a04:	0184b983          	ld	s3,24(s1)
    80003a08:	0204bb03          	ld	s6,32(s1)
  f->ref = 0;
    80003a0c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003a10:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003a14:	00016517          	auipc	a0,0x16
    80003a18:	75c50513          	addi	a0,a0,1884 # 8001a170 <ftable>
    80003a1c:	00004097          	auipc	ra,0x4
    80003a20:	808080e7          	jalr	-2040(ra) # 80007224 <release>

  if(ff.type == FD_PIPE){
    80003a24:	4785                	li	a5,1
    80003a26:	04f90a63          	beq	s2,a5,80003a7a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003a2a:	ffe9079b          	addiw	a5,s2,-2
    80003a2e:	4705                	li	a4,1
    80003a30:	04f77c63          	bgeu	a4,a5,80003a88 <fileclose+0xc8>
    begin_op();
    iput(ff.ip);
    end_op();
  }
#ifdef LAB_NET
  else if(ff.type == FD_SOCK){
    80003a34:	4791                	li	a5,4
    80003a36:	02f91863          	bne	s2,a5,80003a66 <fileclose+0xa6>
    sockclose(ff.sock);
    80003a3a:	855a                	mv	a0,s6
    80003a3c:	00003097          	auipc	ra,0x3
    80003a40:	9a2080e7          	jalr	-1630(ra) # 800063de <sockclose>
    80003a44:	a00d                	j	80003a66 <fileclose+0xa6>
    panic("fileclose");
    80003a46:	00006517          	auipc	a0,0x6
    80003a4a:	bf250513          	addi	a0,a0,-1038 # 80009638 <syscalls+0x288>
    80003a4e:	00003097          	auipc	ra,0x3
    80003a52:	1e6080e7          	jalr	486(ra) # 80006c34 <panic>
    release(&ftable.lock);
    80003a56:	00016517          	auipc	a0,0x16
    80003a5a:	71a50513          	addi	a0,a0,1818 # 8001a170 <ftable>
    80003a5e:	00003097          	auipc	ra,0x3
    80003a62:	7c6080e7          	jalr	1990(ra) # 80007224 <release>
  }
#endif
}
    80003a66:	70e2                	ld	ra,56(sp)
    80003a68:	7442                	ld	s0,48(sp)
    80003a6a:	74a2                	ld	s1,40(sp)
    80003a6c:	7902                	ld	s2,32(sp)
    80003a6e:	69e2                	ld	s3,24(sp)
    80003a70:	6a42                	ld	s4,16(sp)
    80003a72:	6aa2                	ld	s5,8(sp)
    80003a74:	6b02                	ld	s6,0(sp)
    80003a76:	6121                	addi	sp,sp,64
    80003a78:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003a7a:	85d6                	mv	a1,s5
    80003a7c:	8552                	mv	a0,s4
    80003a7e:	00000097          	auipc	ra,0x0
    80003a82:	37c080e7          	jalr	892(ra) # 80003dfa <pipeclose>
    80003a86:	b7c5                	j	80003a66 <fileclose+0xa6>
    begin_op();
    80003a88:	00000097          	auipc	ra,0x0
    80003a8c:	a64080e7          	jalr	-1436(ra) # 800034ec <begin_op>
    iput(ff.ip);
    80003a90:	854e                	mv	a0,s3
    80003a92:	fffff097          	auipc	ra,0xfffff
    80003a96:	242080e7          	jalr	578(ra) # 80002cd4 <iput>
    end_op();
    80003a9a:	00000097          	auipc	ra,0x0
    80003a9e:	ad2080e7          	jalr	-1326(ra) # 8000356c <end_op>
    80003aa2:	b7d1                	j	80003a66 <fileclose+0xa6>

0000000080003aa4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003aa4:	715d                	addi	sp,sp,-80
    80003aa6:	e486                	sd	ra,72(sp)
    80003aa8:	e0a2                	sd	s0,64(sp)
    80003aaa:	fc26                	sd	s1,56(sp)
    80003aac:	f84a                	sd	s2,48(sp)
    80003aae:	f44e                	sd	s3,40(sp)
    80003ab0:	0880                	addi	s0,sp,80
    80003ab2:	84aa                	mv	s1,a0
    80003ab4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003ab6:	ffffd097          	auipc	ra,0xffffd
    80003aba:	40a080e7          	jalr	1034(ra) # 80000ec0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003abe:	409c                	lw	a5,0(s1)
    80003ac0:	37f9                	addiw	a5,a5,-2
    80003ac2:	4705                	li	a4,1
    80003ac4:	04f76763          	bltu	a4,a5,80003b12 <filestat+0x6e>
    80003ac8:	892a                	mv	s2,a0
    ilock(f->ip);
    80003aca:	6c88                	ld	a0,24(s1)
    80003acc:	fffff097          	auipc	ra,0xfffff
    80003ad0:	04e080e7          	jalr	78(ra) # 80002b1a <ilock>
    stati(f->ip, &st);
    80003ad4:	fb840593          	addi	a1,s0,-72
    80003ad8:	6c88                	ld	a0,24(s1)
    80003ada:	fffff097          	auipc	ra,0xfffff
    80003ade:	2ca080e7          	jalr	714(ra) # 80002da4 <stati>
    iunlock(f->ip);
    80003ae2:	6c88                	ld	a0,24(s1)
    80003ae4:	fffff097          	auipc	ra,0xfffff
    80003ae8:	0f8080e7          	jalr	248(ra) # 80002bdc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003aec:	46e1                	li	a3,24
    80003aee:	fb840613          	addi	a2,s0,-72
    80003af2:	85ce                	mv	a1,s3
    80003af4:	05093503          	ld	a0,80(s2)
    80003af8:	ffffd097          	auipc	ra,0xffffd
    80003afc:	05c080e7          	jalr	92(ra) # 80000b54 <copyout>
    80003b00:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003b04:	60a6                	ld	ra,72(sp)
    80003b06:	6406                	ld	s0,64(sp)
    80003b08:	74e2                	ld	s1,56(sp)
    80003b0a:	7942                	ld	s2,48(sp)
    80003b0c:	79a2                	ld	s3,40(sp)
    80003b0e:	6161                	addi	sp,sp,80
    80003b10:	8082                	ret
  return -1;
    80003b12:	557d                	li	a0,-1
    80003b14:	bfc5                	j	80003b04 <filestat+0x60>

0000000080003b16 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003b16:	7179                	addi	sp,sp,-48
    80003b18:	f406                	sd	ra,40(sp)
    80003b1a:	f022                	sd	s0,32(sp)
    80003b1c:	ec26                	sd	s1,24(sp)
    80003b1e:	e84a                	sd	s2,16(sp)
    80003b20:	e44e                	sd	s3,8(sp)
    80003b22:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003b24:	00854783          	lbu	a5,8(a0)
    80003b28:	cfc5                	beqz	a5,80003be0 <fileread+0xca>
    80003b2a:	84aa                	mv	s1,a0
    80003b2c:	89ae                	mv	s3,a1
    80003b2e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003b30:	411c                	lw	a5,0(a0)
    80003b32:	4705                	li	a4,1
    80003b34:	02e78963          	beq	a5,a4,80003b66 <fileread+0x50>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003b38:	470d                	li	a4,3
    80003b3a:	02e78d63          	beq	a5,a4,80003b74 <fileread+0x5e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003b3e:	4709                	li	a4,2
    80003b40:	04e78e63          	beq	a5,a4,80003b9c <fileread+0x86>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
  }
#ifdef LAB_NET
  else if(f->type == FD_SOCK){
    80003b44:	4711                	li	a4,4
    80003b46:	08e79563          	bne	a5,a4,80003bd0 <fileread+0xba>
    r = sockread(f->sock, addr, n);
    80003b4a:	7108                	ld	a0,32(a0)
    80003b4c:	00003097          	auipc	ra,0x3
    80003b50:	922080e7          	jalr	-1758(ra) # 8000646e <sockread>
    80003b54:	892a                	mv	s2,a0
  else {
    panic("fileread");
  }

  return r;
}
    80003b56:	854a                	mv	a0,s2
    80003b58:	70a2                	ld	ra,40(sp)
    80003b5a:	7402                	ld	s0,32(sp)
    80003b5c:	64e2                	ld	s1,24(sp)
    80003b5e:	6942                	ld	s2,16(sp)
    80003b60:	69a2                	ld	s3,8(sp)
    80003b62:	6145                	addi	sp,sp,48
    80003b64:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003b66:	6908                	ld	a0,16(a0)
    80003b68:	00000097          	auipc	ra,0x0
    80003b6c:	3f4080e7          	jalr	1012(ra) # 80003f5c <piperead>
    80003b70:	892a                	mv	s2,a0
    80003b72:	b7d5                	j	80003b56 <fileread+0x40>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003b74:	02c51783          	lh	a5,44(a0)
    80003b78:	03079693          	slli	a3,a5,0x30
    80003b7c:	92c1                	srli	a3,a3,0x30
    80003b7e:	4725                	li	a4,9
    80003b80:	06d76263          	bltu	a4,a3,80003be4 <fileread+0xce>
    80003b84:	0792                	slli	a5,a5,0x4
    80003b86:	00016717          	auipc	a4,0x16
    80003b8a:	54a70713          	addi	a4,a4,1354 # 8001a0d0 <devsw>
    80003b8e:	97ba                	add	a5,a5,a4
    80003b90:	639c                	ld	a5,0(a5)
    80003b92:	cbb9                	beqz	a5,80003be8 <fileread+0xd2>
    r = devsw[f->major].read(1, addr, n);
    80003b94:	4505                	li	a0,1
    80003b96:	9782                	jalr	a5
    80003b98:	892a                	mv	s2,a0
    80003b9a:	bf75                	j	80003b56 <fileread+0x40>
    ilock(f->ip);
    80003b9c:	6d08                	ld	a0,24(a0)
    80003b9e:	fffff097          	auipc	ra,0xfffff
    80003ba2:	f7c080e7          	jalr	-132(ra) # 80002b1a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003ba6:	874a                	mv	a4,s2
    80003ba8:	5494                	lw	a3,40(s1)
    80003baa:	864e                	mv	a2,s3
    80003bac:	4585                	li	a1,1
    80003bae:	6c88                	ld	a0,24(s1)
    80003bb0:	fffff097          	auipc	ra,0xfffff
    80003bb4:	21e080e7          	jalr	542(ra) # 80002dce <readi>
    80003bb8:	892a                	mv	s2,a0
    80003bba:	00a05563          	blez	a0,80003bc4 <fileread+0xae>
      f->off += r;
    80003bbe:	549c                	lw	a5,40(s1)
    80003bc0:	9fa9                	addw	a5,a5,a0
    80003bc2:	d49c                	sw	a5,40(s1)
    iunlock(f->ip);
    80003bc4:	6c88                	ld	a0,24(s1)
    80003bc6:	fffff097          	auipc	ra,0xfffff
    80003bca:	016080e7          	jalr	22(ra) # 80002bdc <iunlock>
    80003bce:	b761                	j	80003b56 <fileread+0x40>
    panic("fileread");
    80003bd0:	00006517          	auipc	a0,0x6
    80003bd4:	a7850513          	addi	a0,a0,-1416 # 80009648 <syscalls+0x298>
    80003bd8:	00003097          	auipc	ra,0x3
    80003bdc:	05c080e7          	jalr	92(ra) # 80006c34 <panic>
    return -1;
    80003be0:	597d                	li	s2,-1
    80003be2:	bf95                	j	80003b56 <fileread+0x40>
      return -1;
    80003be4:	597d                	li	s2,-1
    80003be6:	bf85                	j	80003b56 <fileread+0x40>
    80003be8:	597d                	li	s2,-1
    80003bea:	b7b5                	j	80003b56 <fileread+0x40>

0000000080003bec <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80003bec:	00954783          	lbu	a5,9(a0)
    80003bf0:	12078263          	beqz	a5,80003d14 <filewrite+0x128>
{
    80003bf4:	715d                	addi	sp,sp,-80
    80003bf6:	e486                	sd	ra,72(sp)
    80003bf8:	e0a2                	sd	s0,64(sp)
    80003bfa:	fc26                	sd	s1,56(sp)
    80003bfc:	f84a                	sd	s2,48(sp)
    80003bfe:	f44e                	sd	s3,40(sp)
    80003c00:	f052                	sd	s4,32(sp)
    80003c02:	ec56                	sd	s5,24(sp)
    80003c04:	e85a                	sd	s6,16(sp)
    80003c06:	e45e                	sd	s7,8(sp)
    80003c08:	e062                	sd	s8,0(sp)
    80003c0a:	0880                	addi	s0,sp,80
    80003c0c:	84aa                	mv	s1,a0
    80003c0e:	8aae                	mv	s5,a1
    80003c10:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003c12:	411c                	lw	a5,0(a0)
    80003c14:	4705                	li	a4,1
    80003c16:	02e78c63          	beq	a5,a4,80003c4e <filewrite+0x62>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003c1a:	470d                	li	a4,3
    80003c1c:	02e78f63          	beq	a5,a4,80003c5a <filewrite+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003c20:	4709                	li	a4,2
    80003c22:	04e78f63          	beq	a5,a4,80003c80 <filewrite+0x94>
      i += r;
    }
    ret = (i == n ? n : -1);
  }
#ifdef LAB_NET
  else if(f->type == FD_SOCK){
    80003c26:	4711                	li	a4,4
    80003c28:	0ce79e63          	bne	a5,a4,80003d04 <filewrite+0x118>
    ret = sockwrite(f->sock, addr, n);
    80003c2c:	7108                	ld	a0,32(a0)
    80003c2e:	00003097          	auipc	ra,0x3
    80003c32:	910080e7          	jalr	-1776(ra) # 8000653e <sockwrite>
  else {
    panic("filewrite");
  }

  return ret;
}
    80003c36:	60a6                	ld	ra,72(sp)
    80003c38:	6406                	ld	s0,64(sp)
    80003c3a:	74e2                	ld	s1,56(sp)
    80003c3c:	7942                	ld	s2,48(sp)
    80003c3e:	79a2                	ld	s3,40(sp)
    80003c40:	7a02                	ld	s4,32(sp)
    80003c42:	6ae2                	ld	s5,24(sp)
    80003c44:	6b42                	ld	s6,16(sp)
    80003c46:	6ba2                	ld	s7,8(sp)
    80003c48:	6c02                	ld	s8,0(sp)
    80003c4a:	6161                	addi	sp,sp,80
    80003c4c:	8082                	ret
    ret = pipewrite(f->pipe, addr, n);
    80003c4e:	6908                	ld	a0,16(a0)
    80003c50:	00000097          	auipc	ra,0x0
    80003c54:	21a080e7          	jalr	538(ra) # 80003e6a <pipewrite>
    80003c58:	bff9                	j	80003c36 <filewrite+0x4a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003c5a:	02c51783          	lh	a5,44(a0)
    80003c5e:	03079693          	slli	a3,a5,0x30
    80003c62:	92c1                	srli	a3,a3,0x30
    80003c64:	4725                	li	a4,9
    80003c66:	0ad76963          	bltu	a4,a3,80003d18 <filewrite+0x12c>
    80003c6a:	0792                	slli	a5,a5,0x4
    80003c6c:	00016717          	auipc	a4,0x16
    80003c70:	46470713          	addi	a4,a4,1124 # 8001a0d0 <devsw>
    80003c74:	97ba                	add	a5,a5,a4
    80003c76:	679c                	ld	a5,8(a5)
    80003c78:	c3d5                	beqz	a5,80003d1c <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003c7a:	4505                	li	a0,1
    80003c7c:	9782                	jalr	a5
    80003c7e:	bf65                	j	80003c36 <filewrite+0x4a>
    while(i < n){
    80003c80:	06c05c63          	blez	a2,80003cf8 <filewrite+0x10c>
    int i = 0;
    80003c84:	4981                	li	s3,0
    80003c86:	6b05                	lui	s6,0x1
    80003c88:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80003c8c:	6b85                	lui	s7,0x1
    80003c8e:	c00b8b9b          	addiw	s7,s7,-1024
    80003c92:	a899                	j	80003ce8 <filewrite+0xfc>
    80003c94:	00090c1b          	sext.w	s8,s2
      begin_op();
    80003c98:	00000097          	auipc	ra,0x0
    80003c9c:	854080e7          	jalr	-1964(ra) # 800034ec <begin_op>
      ilock(f->ip);
    80003ca0:	6c88                	ld	a0,24(s1)
    80003ca2:	fffff097          	auipc	ra,0xfffff
    80003ca6:	e78080e7          	jalr	-392(ra) # 80002b1a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003caa:	8762                	mv	a4,s8
    80003cac:	5494                	lw	a3,40(s1)
    80003cae:	01598633          	add	a2,s3,s5
    80003cb2:	4585                	li	a1,1
    80003cb4:	6c88                	ld	a0,24(s1)
    80003cb6:	fffff097          	auipc	ra,0xfffff
    80003cba:	210080e7          	jalr	528(ra) # 80002ec6 <writei>
    80003cbe:	892a                	mv	s2,a0
    80003cc0:	00a05563          	blez	a0,80003cca <filewrite+0xde>
        f->off += r;
    80003cc4:	549c                	lw	a5,40(s1)
    80003cc6:	9fa9                	addw	a5,a5,a0
    80003cc8:	d49c                	sw	a5,40(s1)
      iunlock(f->ip);
    80003cca:	6c88                	ld	a0,24(s1)
    80003ccc:	fffff097          	auipc	ra,0xfffff
    80003cd0:	f10080e7          	jalr	-240(ra) # 80002bdc <iunlock>
      end_op();
    80003cd4:	00000097          	auipc	ra,0x0
    80003cd8:	898080e7          	jalr	-1896(ra) # 8000356c <end_op>
      if(r != n1){
    80003cdc:	012c1f63          	bne	s8,s2,80003cfa <filewrite+0x10e>
      i += r;
    80003ce0:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80003ce4:	0149db63          	bge	s3,s4,80003cfa <filewrite+0x10e>
      int n1 = n - i;
    80003ce8:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80003cec:	893e                	mv	s2,a5
    80003cee:	2781                	sext.w	a5,a5
    80003cf0:	fafb52e3          	bge	s6,a5,80003c94 <filewrite+0xa8>
    80003cf4:	895e                	mv	s2,s7
    80003cf6:	bf79                	j	80003c94 <filewrite+0xa8>
    int i = 0;
    80003cf8:	4981                	li	s3,0
    ret = (i == n ? n : -1);
    80003cfa:	8552                	mv	a0,s4
    80003cfc:	f33a0de3          	beq	s4,s3,80003c36 <filewrite+0x4a>
    80003d00:	557d                	li	a0,-1
    80003d02:	bf15                	j	80003c36 <filewrite+0x4a>
    panic("filewrite");
    80003d04:	00006517          	auipc	a0,0x6
    80003d08:	95450513          	addi	a0,a0,-1708 # 80009658 <syscalls+0x2a8>
    80003d0c:	00003097          	auipc	ra,0x3
    80003d10:	f28080e7          	jalr	-216(ra) # 80006c34 <panic>
    return -1;
    80003d14:	557d                	li	a0,-1
}
    80003d16:	8082                	ret
      return -1;
    80003d18:	557d                	li	a0,-1
    80003d1a:	bf31                	j	80003c36 <filewrite+0x4a>
    80003d1c:	557d                	li	a0,-1
    80003d1e:	bf21                	j	80003c36 <filewrite+0x4a>

0000000080003d20 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003d20:	7179                	addi	sp,sp,-48
    80003d22:	f406                	sd	ra,40(sp)
    80003d24:	f022                	sd	s0,32(sp)
    80003d26:	ec26                	sd	s1,24(sp)
    80003d28:	e84a                	sd	s2,16(sp)
    80003d2a:	e44e                	sd	s3,8(sp)
    80003d2c:	e052                	sd	s4,0(sp)
    80003d2e:	1800                	addi	s0,sp,48
    80003d30:	84aa                	mv	s1,a0
    80003d32:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003d34:	0005b023          	sd	zero,0(a1)
    80003d38:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003d3c:	00000097          	auipc	ra,0x0
    80003d40:	bc8080e7          	jalr	-1080(ra) # 80003904 <filealloc>
    80003d44:	e088                	sd	a0,0(s1)
    80003d46:	c551                	beqz	a0,80003dd2 <pipealloc+0xb2>
    80003d48:	00000097          	auipc	ra,0x0
    80003d4c:	bbc080e7          	jalr	-1092(ra) # 80003904 <filealloc>
    80003d50:	00aa3023          	sd	a0,0(s4)
    80003d54:	c92d                	beqz	a0,80003dc6 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003d56:	ffffc097          	auipc	ra,0xffffc
    80003d5a:	3c2080e7          	jalr	962(ra) # 80000118 <kalloc>
    80003d5e:	892a                	mv	s2,a0
    80003d60:	c125                	beqz	a0,80003dc0 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80003d62:	4985                	li	s3,1
    80003d64:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003d68:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003d6c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003d70:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003d74:	00006597          	auipc	a1,0x6
    80003d78:	8f458593          	addi	a1,a1,-1804 # 80009668 <syscalls+0x2b8>
    80003d7c:	00003097          	auipc	ra,0x3
    80003d80:	364080e7          	jalr	868(ra) # 800070e0 <initlock>
  (*f0)->type = FD_PIPE;
    80003d84:	609c                	ld	a5,0(s1)
    80003d86:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003d8a:	609c                	ld	a5,0(s1)
    80003d8c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003d90:	609c                	ld	a5,0(s1)
    80003d92:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003d96:	609c                	ld	a5,0(s1)
    80003d98:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003d9c:	000a3783          	ld	a5,0(s4)
    80003da0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003da4:	000a3783          	ld	a5,0(s4)
    80003da8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003dac:	000a3783          	ld	a5,0(s4)
    80003db0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003db4:	000a3783          	ld	a5,0(s4)
    80003db8:	0127b823          	sd	s2,16(a5)
  return 0;
    80003dbc:	4501                	li	a0,0
    80003dbe:	a025                	j	80003de6 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003dc0:	6088                	ld	a0,0(s1)
    80003dc2:	e501                	bnez	a0,80003dca <pipealloc+0xaa>
    80003dc4:	a039                	j	80003dd2 <pipealloc+0xb2>
    80003dc6:	6088                	ld	a0,0(s1)
    80003dc8:	c51d                	beqz	a0,80003df6 <pipealloc+0xd6>
    fileclose(*f0);
    80003dca:	00000097          	auipc	ra,0x0
    80003dce:	bf6080e7          	jalr	-1034(ra) # 800039c0 <fileclose>
  if(*f1)
    80003dd2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003dd6:	557d                	li	a0,-1
  if(*f1)
    80003dd8:	c799                	beqz	a5,80003de6 <pipealloc+0xc6>
    fileclose(*f1);
    80003dda:	853e                	mv	a0,a5
    80003ddc:	00000097          	auipc	ra,0x0
    80003de0:	be4080e7          	jalr	-1052(ra) # 800039c0 <fileclose>
  return -1;
    80003de4:	557d                	li	a0,-1
}
    80003de6:	70a2                	ld	ra,40(sp)
    80003de8:	7402                	ld	s0,32(sp)
    80003dea:	64e2                	ld	s1,24(sp)
    80003dec:	6942                	ld	s2,16(sp)
    80003dee:	69a2                	ld	s3,8(sp)
    80003df0:	6a02                	ld	s4,0(sp)
    80003df2:	6145                	addi	sp,sp,48
    80003df4:	8082                	ret
  return -1;
    80003df6:	557d                	li	a0,-1
    80003df8:	b7fd                	j	80003de6 <pipealloc+0xc6>

0000000080003dfa <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003dfa:	1101                	addi	sp,sp,-32
    80003dfc:	ec06                	sd	ra,24(sp)
    80003dfe:	e822                	sd	s0,16(sp)
    80003e00:	e426                	sd	s1,8(sp)
    80003e02:	e04a                	sd	s2,0(sp)
    80003e04:	1000                	addi	s0,sp,32
    80003e06:	84aa                	mv	s1,a0
    80003e08:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003e0a:	00003097          	auipc	ra,0x3
    80003e0e:	366080e7          	jalr	870(ra) # 80007170 <acquire>
  if(writable){
    80003e12:	02090d63          	beqz	s2,80003e4c <pipeclose+0x52>
    pi->writeopen = 0;
    80003e16:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003e1a:	21848513          	addi	a0,s1,536
    80003e1e:	ffffe097          	auipc	ra,0xffffe
    80003e22:	a36080e7          	jalr	-1482(ra) # 80001854 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003e26:	2204b783          	ld	a5,544(s1)
    80003e2a:	eb95                	bnez	a5,80003e5e <pipeclose+0x64>
    release(&pi->lock);
    80003e2c:	8526                	mv	a0,s1
    80003e2e:	00003097          	auipc	ra,0x3
    80003e32:	3f6080e7          	jalr	1014(ra) # 80007224 <release>
    kfree((char*)pi);
    80003e36:	8526                	mv	a0,s1
    80003e38:	ffffc097          	auipc	ra,0xffffc
    80003e3c:	1e4080e7          	jalr	484(ra) # 8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003e40:	60e2                	ld	ra,24(sp)
    80003e42:	6442                	ld	s0,16(sp)
    80003e44:	64a2                	ld	s1,8(sp)
    80003e46:	6902                	ld	s2,0(sp)
    80003e48:	6105                	addi	sp,sp,32
    80003e4a:	8082                	ret
    pi->readopen = 0;
    80003e4c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003e50:	21c48513          	addi	a0,s1,540
    80003e54:	ffffe097          	auipc	ra,0xffffe
    80003e58:	a00080e7          	jalr	-1536(ra) # 80001854 <wakeup>
    80003e5c:	b7e9                	j	80003e26 <pipeclose+0x2c>
    release(&pi->lock);
    80003e5e:	8526                	mv	a0,s1
    80003e60:	00003097          	auipc	ra,0x3
    80003e64:	3c4080e7          	jalr	964(ra) # 80007224 <release>
}
    80003e68:	bfe1                	j	80003e40 <pipeclose+0x46>

0000000080003e6a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003e6a:	711d                	addi	sp,sp,-96
    80003e6c:	ec86                	sd	ra,88(sp)
    80003e6e:	e8a2                	sd	s0,80(sp)
    80003e70:	e4a6                	sd	s1,72(sp)
    80003e72:	e0ca                	sd	s2,64(sp)
    80003e74:	fc4e                	sd	s3,56(sp)
    80003e76:	f852                	sd	s4,48(sp)
    80003e78:	f456                	sd	s5,40(sp)
    80003e7a:	f05a                	sd	s6,32(sp)
    80003e7c:	ec5e                	sd	s7,24(sp)
    80003e7e:	e862                	sd	s8,16(sp)
    80003e80:	1080                	addi	s0,sp,96
    80003e82:	84aa                	mv	s1,a0
    80003e84:	8aae                	mv	s5,a1
    80003e86:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003e88:	ffffd097          	auipc	ra,0xffffd
    80003e8c:	038080e7          	jalr	56(ra) # 80000ec0 <myproc>
    80003e90:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003e92:	8526                	mv	a0,s1
    80003e94:	00003097          	auipc	ra,0x3
    80003e98:	2dc080e7          	jalr	732(ra) # 80007170 <acquire>
  while(i < n){
    80003e9c:	0b405363          	blez	s4,80003f42 <pipewrite+0xd8>
  int i = 0;
    80003ea0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003ea2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003ea4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003ea8:	21c48b93          	addi	s7,s1,540
    80003eac:	a089                	j	80003eee <pipewrite+0x84>
      release(&pi->lock);
    80003eae:	8526                	mv	a0,s1
    80003eb0:	00003097          	auipc	ra,0x3
    80003eb4:	374080e7          	jalr	884(ra) # 80007224 <release>
      return -1;
    80003eb8:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003eba:	854a                	mv	a0,s2
    80003ebc:	60e6                	ld	ra,88(sp)
    80003ebe:	6446                	ld	s0,80(sp)
    80003ec0:	64a6                	ld	s1,72(sp)
    80003ec2:	6906                	ld	s2,64(sp)
    80003ec4:	79e2                	ld	s3,56(sp)
    80003ec6:	7a42                	ld	s4,48(sp)
    80003ec8:	7aa2                	ld	s5,40(sp)
    80003eca:	7b02                	ld	s6,32(sp)
    80003ecc:	6be2                	ld	s7,24(sp)
    80003ece:	6c42                	ld	s8,16(sp)
    80003ed0:	6125                	addi	sp,sp,96
    80003ed2:	8082                	ret
      wakeup(&pi->nread);
    80003ed4:	8562                	mv	a0,s8
    80003ed6:	ffffe097          	auipc	ra,0xffffe
    80003eda:	97e080e7          	jalr	-1666(ra) # 80001854 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003ede:	85a6                	mv	a1,s1
    80003ee0:	855e                	mv	a0,s7
    80003ee2:	ffffd097          	auipc	ra,0xffffd
    80003ee6:	7f2080e7          	jalr	2034(ra) # 800016d4 <sleep>
  while(i < n){
    80003eea:	05495d63          	bge	s2,s4,80003f44 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80003eee:	2204a783          	lw	a5,544(s1)
    80003ef2:	dfd5                	beqz	a5,80003eae <pipewrite+0x44>
    80003ef4:	0309a783          	lw	a5,48(s3)
    80003ef8:	fbdd                	bnez	a5,80003eae <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003efa:	2184a783          	lw	a5,536(s1)
    80003efe:	21c4a703          	lw	a4,540(s1)
    80003f02:	2007879b          	addiw	a5,a5,512
    80003f06:	fcf707e3          	beq	a4,a5,80003ed4 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003f0a:	4685                	li	a3,1
    80003f0c:	01590633          	add	a2,s2,s5
    80003f10:	faf40593          	addi	a1,s0,-81
    80003f14:	0509b503          	ld	a0,80(s3)
    80003f18:	ffffd097          	auipc	ra,0xffffd
    80003f1c:	cc8080e7          	jalr	-824(ra) # 80000be0 <copyin>
    80003f20:	03650263          	beq	a0,s6,80003f44 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003f24:	21c4a783          	lw	a5,540(s1)
    80003f28:	0017871b          	addiw	a4,a5,1
    80003f2c:	20e4ae23          	sw	a4,540(s1)
    80003f30:	1ff7f793          	andi	a5,a5,511
    80003f34:	97a6                	add	a5,a5,s1
    80003f36:	faf44703          	lbu	a4,-81(s0)
    80003f3a:	00e78c23          	sb	a4,24(a5)
      i++;
    80003f3e:	2905                	addiw	s2,s2,1
    80003f40:	b76d                	j	80003eea <pipewrite+0x80>
  int i = 0;
    80003f42:	4901                	li	s2,0
  wakeup(&pi->nread);
    80003f44:	21848513          	addi	a0,s1,536
    80003f48:	ffffe097          	auipc	ra,0xffffe
    80003f4c:	90c080e7          	jalr	-1780(ra) # 80001854 <wakeup>
  release(&pi->lock);
    80003f50:	8526                	mv	a0,s1
    80003f52:	00003097          	auipc	ra,0x3
    80003f56:	2d2080e7          	jalr	722(ra) # 80007224 <release>
  return i;
    80003f5a:	b785                	j	80003eba <pipewrite+0x50>

0000000080003f5c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003f5c:	715d                	addi	sp,sp,-80
    80003f5e:	e486                	sd	ra,72(sp)
    80003f60:	e0a2                	sd	s0,64(sp)
    80003f62:	fc26                	sd	s1,56(sp)
    80003f64:	f84a                	sd	s2,48(sp)
    80003f66:	f44e                	sd	s3,40(sp)
    80003f68:	f052                	sd	s4,32(sp)
    80003f6a:	ec56                	sd	s5,24(sp)
    80003f6c:	e85a                	sd	s6,16(sp)
    80003f6e:	0880                	addi	s0,sp,80
    80003f70:	84aa                	mv	s1,a0
    80003f72:	892e                	mv	s2,a1
    80003f74:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003f76:	ffffd097          	auipc	ra,0xffffd
    80003f7a:	f4a080e7          	jalr	-182(ra) # 80000ec0 <myproc>
    80003f7e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003f80:	8526                	mv	a0,s1
    80003f82:	00003097          	auipc	ra,0x3
    80003f86:	1ee080e7          	jalr	494(ra) # 80007170 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003f8a:	2184a703          	lw	a4,536(s1)
    80003f8e:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003f92:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003f96:	02f71463          	bne	a4,a5,80003fbe <piperead+0x62>
    80003f9a:	2244a783          	lw	a5,548(s1)
    80003f9e:	c385                	beqz	a5,80003fbe <piperead+0x62>
    if(pr->killed){
    80003fa0:	030a2783          	lw	a5,48(s4)
    80003fa4:	ebc1                	bnez	a5,80004034 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003fa6:	85a6                	mv	a1,s1
    80003fa8:	854e                	mv	a0,s3
    80003faa:	ffffd097          	auipc	ra,0xffffd
    80003fae:	72a080e7          	jalr	1834(ra) # 800016d4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003fb2:	2184a703          	lw	a4,536(s1)
    80003fb6:	21c4a783          	lw	a5,540(s1)
    80003fba:	fef700e3          	beq	a4,a5,80003f9a <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003fbe:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003fc0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003fc2:	05505363          	blez	s5,80004008 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80003fc6:	2184a783          	lw	a5,536(s1)
    80003fca:	21c4a703          	lw	a4,540(s1)
    80003fce:	02f70d63          	beq	a4,a5,80004008 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003fd2:	0017871b          	addiw	a4,a5,1
    80003fd6:	20e4ac23          	sw	a4,536(s1)
    80003fda:	1ff7f793          	andi	a5,a5,511
    80003fde:	97a6                	add	a5,a5,s1
    80003fe0:	0187c783          	lbu	a5,24(a5)
    80003fe4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003fe8:	4685                	li	a3,1
    80003fea:	fbf40613          	addi	a2,s0,-65
    80003fee:	85ca                	mv	a1,s2
    80003ff0:	050a3503          	ld	a0,80(s4)
    80003ff4:	ffffd097          	auipc	ra,0xffffd
    80003ff8:	b60080e7          	jalr	-1184(ra) # 80000b54 <copyout>
    80003ffc:	01650663          	beq	a0,s6,80004008 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004000:	2985                	addiw	s3,s3,1
    80004002:	0905                	addi	s2,s2,1
    80004004:	fd3a91e3          	bne	s5,s3,80003fc6 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004008:	21c48513          	addi	a0,s1,540
    8000400c:	ffffe097          	auipc	ra,0xffffe
    80004010:	848080e7          	jalr	-1976(ra) # 80001854 <wakeup>
  release(&pi->lock);
    80004014:	8526                	mv	a0,s1
    80004016:	00003097          	auipc	ra,0x3
    8000401a:	20e080e7          	jalr	526(ra) # 80007224 <release>
  return i;
}
    8000401e:	854e                	mv	a0,s3
    80004020:	60a6                	ld	ra,72(sp)
    80004022:	6406                	ld	s0,64(sp)
    80004024:	74e2                	ld	s1,56(sp)
    80004026:	7942                	ld	s2,48(sp)
    80004028:	79a2                	ld	s3,40(sp)
    8000402a:	7a02                	ld	s4,32(sp)
    8000402c:	6ae2                	ld	s5,24(sp)
    8000402e:	6b42                	ld	s6,16(sp)
    80004030:	6161                	addi	sp,sp,80
    80004032:	8082                	ret
      release(&pi->lock);
    80004034:	8526                	mv	a0,s1
    80004036:	00003097          	auipc	ra,0x3
    8000403a:	1ee080e7          	jalr	494(ra) # 80007224 <release>
      return -1;
    8000403e:	59fd                	li	s3,-1
    80004040:	bff9                	j	8000401e <piperead+0xc2>

0000000080004042 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004042:	de010113          	addi	sp,sp,-544
    80004046:	20113c23          	sd	ra,536(sp)
    8000404a:	20813823          	sd	s0,528(sp)
    8000404e:	20913423          	sd	s1,520(sp)
    80004052:	21213023          	sd	s2,512(sp)
    80004056:	ffce                	sd	s3,504(sp)
    80004058:	fbd2                	sd	s4,496(sp)
    8000405a:	f7d6                	sd	s5,488(sp)
    8000405c:	f3da                	sd	s6,480(sp)
    8000405e:	efde                	sd	s7,472(sp)
    80004060:	ebe2                	sd	s8,464(sp)
    80004062:	e7e6                	sd	s9,456(sp)
    80004064:	e3ea                	sd	s10,448(sp)
    80004066:	ff6e                	sd	s11,440(sp)
    80004068:	1400                	addi	s0,sp,544
    8000406a:	892a                	mv	s2,a0
    8000406c:	dea43423          	sd	a0,-536(s0)
    80004070:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004074:	ffffd097          	auipc	ra,0xffffd
    80004078:	e4c080e7          	jalr	-436(ra) # 80000ec0 <myproc>
    8000407c:	84aa                	mv	s1,a0

  begin_op();
    8000407e:	fffff097          	auipc	ra,0xfffff
    80004082:	46e080e7          	jalr	1134(ra) # 800034ec <begin_op>

  if((ip = namei(path)) == 0){
    80004086:	854a                	mv	a0,s2
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	248080e7          	jalr	584(ra) # 800032d0 <namei>
    80004090:	c93d                	beqz	a0,80004106 <exec+0xc4>
    80004092:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004094:	fffff097          	auipc	ra,0xfffff
    80004098:	a86080e7          	jalr	-1402(ra) # 80002b1a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000409c:	04000713          	li	a4,64
    800040a0:	4681                	li	a3,0
    800040a2:	e4840613          	addi	a2,s0,-440
    800040a6:	4581                	li	a1,0
    800040a8:	8556                	mv	a0,s5
    800040aa:	fffff097          	auipc	ra,0xfffff
    800040ae:	d24080e7          	jalr	-732(ra) # 80002dce <readi>
    800040b2:	04000793          	li	a5,64
    800040b6:	00f51a63          	bne	a0,a5,800040ca <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800040ba:	e4842703          	lw	a4,-440(s0)
    800040be:	464c47b7          	lui	a5,0x464c4
    800040c2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800040c6:	04f70663          	beq	a4,a5,80004112 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800040ca:	8556                	mv	a0,s5
    800040cc:	fffff097          	auipc	ra,0xfffff
    800040d0:	cb0080e7          	jalr	-848(ra) # 80002d7c <iunlockput>
    end_op();
    800040d4:	fffff097          	auipc	ra,0xfffff
    800040d8:	498080e7          	jalr	1176(ra) # 8000356c <end_op>
  }
  return -1;
    800040dc:	557d                	li	a0,-1
}
    800040de:	21813083          	ld	ra,536(sp)
    800040e2:	21013403          	ld	s0,528(sp)
    800040e6:	20813483          	ld	s1,520(sp)
    800040ea:	20013903          	ld	s2,512(sp)
    800040ee:	79fe                	ld	s3,504(sp)
    800040f0:	7a5e                	ld	s4,496(sp)
    800040f2:	7abe                	ld	s5,488(sp)
    800040f4:	7b1e                	ld	s6,480(sp)
    800040f6:	6bfe                	ld	s7,472(sp)
    800040f8:	6c5e                	ld	s8,464(sp)
    800040fa:	6cbe                	ld	s9,456(sp)
    800040fc:	6d1e                	ld	s10,448(sp)
    800040fe:	7dfa                	ld	s11,440(sp)
    80004100:	22010113          	addi	sp,sp,544
    80004104:	8082                	ret
    end_op();
    80004106:	fffff097          	auipc	ra,0xfffff
    8000410a:	466080e7          	jalr	1126(ra) # 8000356c <end_op>
    return -1;
    8000410e:	557d                	li	a0,-1
    80004110:	b7f9                	j	800040de <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004112:	8526                	mv	a0,s1
    80004114:	ffffd097          	auipc	ra,0xffffd
    80004118:	e70080e7          	jalr	-400(ra) # 80000f84 <proc_pagetable>
    8000411c:	8b2a                	mv	s6,a0
    8000411e:	d555                	beqz	a0,800040ca <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004120:	e6842783          	lw	a5,-408(s0)
    80004124:	e8045703          	lhu	a4,-384(s0)
    80004128:	c735                	beqz	a4,80004194 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000412a:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000412c:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004130:	6a05                	lui	s4,0x1
    80004132:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004136:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    8000413a:	6d85                	lui	s11,0x1
    8000413c:	7d7d                	lui	s10,0xfffff
    8000413e:	ac1d                	j	80004374 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004140:	00005517          	auipc	a0,0x5
    80004144:	53050513          	addi	a0,a0,1328 # 80009670 <syscalls+0x2c0>
    80004148:	00003097          	auipc	ra,0x3
    8000414c:	aec080e7          	jalr	-1300(ra) # 80006c34 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004150:	874a                	mv	a4,s2
    80004152:	009c86bb          	addw	a3,s9,s1
    80004156:	4581                	li	a1,0
    80004158:	8556                	mv	a0,s5
    8000415a:	fffff097          	auipc	ra,0xfffff
    8000415e:	c74080e7          	jalr	-908(ra) # 80002dce <readi>
    80004162:	2501                	sext.w	a0,a0
    80004164:	1aa91863          	bne	s2,a0,80004314 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004168:	009d84bb          	addw	s1,s11,s1
    8000416c:	013d09bb          	addw	s3,s10,s3
    80004170:	1f74f263          	bgeu	s1,s7,80004354 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004174:	02049593          	slli	a1,s1,0x20
    80004178:	9181                	srli	a1,a1,0x20
    8000417a:	95e2                	add	a1,a1,s8
    8000417c:	855a                	mv	a0,s6
    8000417e:	ffffc097          	auipc	ra,0xffffc
    80004182:	3a0080e7          	jalr	928(ra) # 8000051e <walkaddr>
    80004186:	862a                	mv	a2,a0
    if(pa == 0)
    80004188:	dd45                	beqz	a0,80004140 <exec+0xfe>
      n = PGSIZE;
    8000418a:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000418c:	fd49f2e3          	bgeu	s3,s4,80004150 <exec+0x10e>
      n = sz - i;
    80004190:	894e                	mv	s2,s3
    80004192:	bf7d                	j	80004150 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004194:	4481                	li	s1,0
  iunlockput(ip);
    80004196:	8556                	mv	a0,s5
    80004198:	fffff097          	auipc	ra,0xfffff
    8000419c:	be4080e7          	jalr	-1052(ra) # 80002d7c <iunlockput>
  end_op();
    800041a0:	fffff097          	auipc	ra,0xfffff
    800041a4:	3cc080e7          	jalr	972(ra) # 8000356c <end_op>
  p = myproc();
    800041a8:	ffffd097          	auipc	ra,0xffffd
    800041ac:	d18080e7          	jalr	-744(ra) # 80000ec0 <myproc>
    800041b0:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800041b2:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800041b6:	6785                	lui	a5,0x1
    800041b8:	17fd                	addi	a5,a5,-1
    800041ba:	94be                	add	s1,s1,a5
    800041bc:	77fd                	lui	a5,0xfffff
    800041be:	8fe5                	and	a5,a5,s1
    800041c0:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800041c4:	6609                	lui	a2,0x2
    800041c6:	963e                	add	a2,a2,a5
    800041c8:	85be                	mv	a1,a5
    800041ca:	855a                	mv	a0,s6
    800041cc:	ffffc097          	auipc	ra,0xffffc
    800041d0:	738080e7          	jalr	1848(ra) # 80000904 <uvmalloc>
    800041d4:	8c2a                	mv	s8,a0
  ip = 0;
    800041d6:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800041d8:	12050e63          	beqz	a0,80004314 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    800041dc:	75f9                	lui	a1,0xffffe
    800041de:	95aa                	add	a1,a1,a0
    800041e0:	855a                	mv	a0,s6
    800041e2:	ffffd097          	auipc	ra,0xffffd
    800041e6:	940080e7          	jalr	-1728(ra) # 80000b22 <uvmclear>
  stackbase = sp - PGSIZE;
    800041ea:	7afd                	lui	s5,0xfffff
    800041ec:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800041ee:	df043783          	ld	a5,-528(s0)
    800041f2:	6388                	ld	a0,0(a5)
    800041f4:	c925                	beqz	a0,80004264 <exec+0x222>
    800041f6:	e8840993          	addi	s3,s0,-376
    800041fa:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    800041fe:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004200:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004202:	ffffc097          	auipc	ra,0xffffc
    80004206:	0fa080e7          	jalr	250(ra) # 800002fc <strlen>
    8000420a:	0015079b          	addiw	a5,a0,1
    8000420e:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004212:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004216:	13596363          	bltu	s2,s5,8000433c <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000421a:	df043d83          	ld	s11,-528(s0)
    8000421e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004222:	8552                	mv	a0,s4
    80004224:	ffffc097          	auipc	ra,0xffffc
    80004228:	0d8080e7          	jalr	216(ra) # 800002fc <strlen>
    8000422c:	0015069b          	addiw	a3,a0,1
    80004230:	8652                	mv	a2,s4
    80004232:	85ca                	mv	a1,s2
    80004234:	855a                	mv	a0,s6
    80004236:	ffffd097          	auipc	ra,0xffffd
    8000423a:	91e080e7          	jalr	-1762(ra) # 80000b54 <copyout>
    8000423e:	10054363          	bltz	a0,80004344 <exec+0x302>
    ustack[argc] = sp;
    80004242:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004246:	0485                	addi	s1,s1,1
    80004248:	008d8793          	addi	a5,s11,8
    8000424c:	def43823          	sd	a5,-528(s0)
    80004250:	008db503          	ld	a0,8(s11)
    80004254:	c911                	beqz	a0,80004268 <exec+0x226>
    if(argc >= MAXARG)
    80004256:	09a1                	addi	s3,s3,8
    80004258:	fb3c95e3          	bne	s9,s3,80004202 <exec+0x1c0>
  sz = sz1;
    8000425c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004260:	4a81                	li	s5,0
    80004262:	a84d                	j	80004314 <exec+0x2d2>
  sp = sz;
    80004264:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004266:	4481                	li	s1,0
  ustack[argc] = 0;
    80004268:	00349793          	slli	a5,s1,0x3
    8000426c:	f9040713          	addi	a4,s0,-112
    80004270:	97ba                	add	a5,a5,a4
    80004272:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd7968>
  sp -= (argc+1) * sizeof(uint64);
    80004276:	00148693          	addi	a3,s1,1
    8000427a:	068e                	slli	a3,a3,0x3
    8000427c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004280:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004284:	01597663          	bgeu	s2,s5,80004290 <exec+0x24e>
  sz = sz1;
    80004288:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000428c:	4a81                	li	s5,0
    8000428e:	a059                	j	80004314 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004290:	e8840613          	addi	a2,s0,-376
    80004294:	85ca                	mv	a1,s2
    80004296:	855a                	mv	a0,s6
    80004298:	ffffd097          	auipc	ra,0xffffd
    8000429c:	8bc080e7          	jalr	-1860(ra) # 80000b54 <copyout>
    800042a0:	0a054663          	bltz	a0,8000434c <exec+0x30a>
  p->trapframe->a1 = sp;
    800042a4:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800042a8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800042ac:	de843783          	ld	a5,-536(s0)
    800042b0:	0007c703          	lbu	a4,0(a5)
    800042b4:	cf11                	beqz	a4,800042d0 <exec+0x28e>
    800042b6:	0785                	addi	a5,a5,1
    if(*s == '/')
    800042b8:	02f00693          	li	a3,47
    800042bc:	a039                	j	800042ca <exec+0x288>
      last = s+1;
    800042be:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800042c2:	0785                	addi	a5,a5,1
    800042c4:	fff7c703          	lbu	a4,-1(a5)
    800042c8:	c701                	beqz	a4,800042d0 <exec+0x28e>
    if(*s == '/')
    800042ca:	fed71ce3          	bne	a4,a3,800042c2 <exec+0x280>
    800042ce:	bfc5                	j	800042be <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    800042d0:	4641                	li	a2,16
    800042d2:	de843583          	ld	a1,-536(s0)
    800042d6:	158b8513          	addi	a0,s7,344
    800042da:	ffffc097          	auipc	ra,0xffffc
    800042de:	ff0080e7          	jalr	-16(ra) # 800002ca <safestrcpy>
  oldpagetable = p->pagetable;
    800042e2:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800042e6:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800042ea:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800042ee:	058bb783          	ld	a5,88(s7)
    800042f2:	e6043703          	ld	a4,-416(s0)
    800042f6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800042f8:	058bb783          	ld	a5,88(s7)
    800042fc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004300:	85ea                	mv	a1,s10
    80004302:	ffffd097          	auipc	ra,0xffffd
    80004306:	d1e080e7          	jalr	-738(ra) # 80001020 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000430a:	0004851b          	sext.w	a0,s1
    8000430e:	bbc1                	j	800040de <exec+0x9c>
    80004310:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004314:	df843583          	ld	a1,-520(s0)
    80004318:	855a                	mv	a0,s6
    8000431a:	ffffd097          	auipc	ra,0xffffd
    8000431e:	d06080e7          	jalr	-762(ra) # 80001020 <proc_freepagetable>
  if(ip){
    80004322:	da0a94e3          	bnez	s5,800040ca <exec+0x88>
  return -1;
    80004326:	557d                	li	a0,-1
    80004328:	bb5d                	j	800040de <exec+0x9c>
    8000432a:	de943c23          	sd	s1,-520(s0)
    8000432e:	b7dd                	j	80004314 <exec+0x2d2>
    80004330:	de943c23          	sd	s1,-520(s0)
    80004334:	b7c5                	j	80004314 <exec+0x2d2>
    80004336:	de943c23          	sd	s1,-520(s0)
    8000433a:	bfe9                	j	80004314 <exec+0x2d2>
  sz = sz1;
    8000433c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004340:	4a81                	li	s5,0
    80004342:	bfc9                	j	80004314 <exec+0x2d2>
  sz = sz1;
    80004344:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004348:	4a81                	li	s5,0
    8000434a:	b7e9                	j	80004314 <exec+0x2d2>
  sz = sz1;
    8000434c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004350:	4a81                	li	s5,0
    80004352:	b7c9                	j	80004314 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004354:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004358:	e0843783          	ld	a5,-504(s0)
    8000435c:	0017869b          	addiw	a3,a5,1
    80004360:	e0d43423          	sd	a3,-504(s0)
    80004364:	e0043783          	ld	a5,-512(s0)
    80004368:	0387879b          	addiw	a5,a5,56
    8000436c:	e8045703          	lhu	a4,-384(s0)
    80004370:	e2e6d3e3          	bge	a3,a4,80004196 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004374:	2781                	sext.w	a5,a5
    80004376:	e0f43023          	sd	a5,-512(s0)
    8000437a:	03800713          	li	a4,56
    8000437e:	86be                	mv	a3,a5
    80004380:	e1040613          	addi	a2,s0,-496
    80004384:	4581                	li	a1,0
    80004386:	8556                	mv	a0,s5
    80004388:	fffff097          	auipc	ra,0xfffff
    8000438c:	a46080e7          	jalr	-1466(ra) # 80002dce <readi>
    80004390:	03800793          	li	a5,56
    80004394:	f6f51ee3          	bne	a0,a5,80004310 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80004398:	e1042783          	lw	a5,-496(s0)
    8000439c:	4705                	li	a4,1
    8000439e:	fae79de3          	bne	a5,a4,80004358 <exec+0x316>
    if(ph.memsz < ph.filesz)
    800043a2:	e3843603          	ld	a2,-456(s0)
    800043a6:	e3043783          	ld	a5,-464(s0)
    800043aa:	f8f660e3          	bltu	a2,a5,8000432a <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800043ae:	e2043783          	ld	a5,-480(s0)
    800043b2:	963e                	add	a2,a2,a5
    800043b4:	f6f66ee3          	bltu	a2,a5,80004330 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800043b8:	85a6                	mv	a1,s1
    800043ba:	855a                	mv	a0,s6
    800043bc:	ffffc097          	auipc	ra,0xffffc
    800043c0:	548080e7          	jalr	1352(ra) # 80000904 <uvmalloc>
    800043c4:	dea43c23          	sd	a0,-520(s0)
    800043c8:	d53d                	beqz	a0,80004336 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    800043ca:	e2043c03          	ld	s8,-480(s0)
    800043ce:	de043783          	ld	a5,-544(s0)
    800043d2:	00fc77b3          	and	a5,s8,a5
    800043d6:	ff9d                	bnez	a5,80004314 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800043d8:	e1842c83          	lw	s9,-488(s0)
    800043dc:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800043e0:	f60b8ae3          	beqz	s7,80004354 <exec+0x312>
    800043e4:	89de                	mv	s3,s7
    800043e6:	4481                	li	s1,0
    800043e8:	b371                	j	80004174 <exec+0x132>

00000000800043ea <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800043ea:	7179                	addi	sp,sp,-48
    800043ec:	f406                	sd	ra,40(sp)
    800043ee:	f022                	sd	s0,32(sp)
    800043f0:	ec26                	sd	s1,24(sp)
    800043f2:	e84a                	sd	s2,16(sp)
    800043f4:	1800                	addi	s0,sp,48
    800043f6:	892e                	mv	s2,a1
    800043f8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800043fa:	fdc40593          	addi	a1,s0,-36
    800043fe:	ffffe097          	auipc	ra,0xffffe
    80004402:	bac080e7          	jalr	-1108(ra) # 80001faa <argint>
    80004406:	04054063          	bltz	a0,80004446 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000440a:	fdc42703          	lw	a4,-36(s0)
    8000440e:	47bd                	li	a5,15
    80004410:	02e7ed63          	bltu	a5,a4,8000444a <argfd+0x60>
    80004414:	ffffd097          	auipc	ra,0xffffd
    80004418:	aac080e7          	jalr	-1364(ra) # 80000ec0 <myproc>
    8000441c:	fdc42703          	lw	a4,-36(s0)
    80004420:	01a70793          	addi	a5,a4,26
    80004424:	078e                	slli	a5,a5,0x3
    80004426:	953e                	add	a0,a0,a5
    80004428:	611c                	ld	a5,0(a0)
    8000442a:	c395                	beqz	a5,8000444e <argfd+0x64>
    return -1;
  if(pfd)
    8000442c:	00090463          	beqz	s2,80004434 <argfd+0x4a>
    *pfd = fd;
    80004430:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004434:	4501                	li	a0,0
  if(pf)
    80004436:	c091                	beqz	s1,8000443a <argfd+0x50>
    *pf = f;
    80004438:	e09c                	sd	a5,0(s1)
}
    8000443a:	70a2                	ld	ra,40(sp)
    8000443c:	7402                	ld	s0,32(sp)
    8000443e:	64e2                	ld	s1,24(sp)
    80004440:	6942                	ld	s2,16(sp)
    80004442:	6145                	addi	sp,sp,48
    80004444:	8082                	ret
    return -1;
    80004446:	557d                	li	a0,-1
    80004448:	bfcd                	j	8000443a <argfd+0x50>
    return -1;
    8000444a:	557d                	li	a0,-1
    8000444c:	b7fd                	j	8000443a <argfd+0x50>
    8000444e:	557d                	li	a0,-1
    80004450:	b7ed                	j	8000443a <argfd+0x50>

0000000080004452 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004452:	1101                	addi	sp,sp,-32
    80004454:	ec06                	sd	ra,24(sp)
    80004456:	e822                	sd	s0,16(sp)
    80004458:	e426                	sd	s1,8(sp)
    8000445a:	1000                	addi	s0,sp,32
    8000445c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000445e:	ffffd097          	auipc	ra,0xffffd
    80004462:	a62080e7          	jalr	-1438(ra) # 80000ec0 <myproc>
    80004466:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004468:	0d050793          	addi	a5,a0,208
    8000446c:	4501                	li	a0,0
    8000446e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004470:	6398                	ld	a4,0(a5)
    80004472:	cb19                	beqz	a4,80004488 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004474:	2505                	addiw	a0,a0,1
    80004476:	07a1                	addi	a5,a5,8
    80004478:	fed51ce3          	bne	a0,a3,80004470 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000447c:	557d                	li	a0,-1
}
    8000447e:	60e2                	ld	ra,24(sp)
    80004480:	6442                	ld	s0,16(sp)
    80004482:	64a2                	ld	s1,8(sp)
    80004484:	6105                	addi	sp,sp,32
    80004486:	8082                	ret
      p->ofile[fd] = f;
    80004488:	01a50793          	addi	a5,a0,26
    8000448c:	078e                	slli	a5,a5,0x3
    8000448e:	963e                	add	a2,a2,a5
    80004490:	e204                	sd	s1,0(a2)
      return fd;
    80004492:	b7f5                	j	8000447e <fdalloc+0x2c>

0000000080004494 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004494:	715d                	addi	sp,sp,-80
    80004496:	e486                	sd	ra,72(sp)
    80004498:	e0a2                	sd	s0,64(sp)
    8000449a:	fc26                	sd	s1,56(sp)
    8000449c:	f84a                	sd	s2,48(sp)
    8000449e:	f44e                	sd	s3,40(sp)
    800044a0:	f052                	sd	s4,32(sp)
    800044a2:	ec56                	sd	s5,24(sp)
    800044a4:	0880                	addi	s0,sp,80
    800044a6:	89ae                	mv	s3,a1
    800044a8:	8ab2                	mv	s5,a2
    800044aa:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800044ac:	fb040593          	addi	a1,s0,-80
    800044b0:	fffff097          	auipc	ra,0xfffff
    800044b4:	e3e080e7          	jalr	-450(ra) # 800032ee <nameiparent>
    800044b8:	892a                	mv	s2,a0
    800044ba:	12050e63          	beqz	a0,800045f6 <create+0x162>
    return 0;

  ilock(dp);
    800044be:	ffffe097          	auipc	ra,0xffffe
    800044c2:	65c080e7          	jalr	1628(ra) # 80002b1a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800044c6:	4601                	li	a2,0
    800044c8:	fb040593          	addi	a1,s0,-80
    800044cc:	854a                	mv	a0,s2
    800044ce:	fffff097          	auipc	ra,0xfffff
    800044d2:	b30080e7          	jalr	-1232(ra) # 80002ffe <dirlookup>
    800044d6:	84aa                	mv	s1,a0
    800044d8:	c921                	beqz	a0,80004528 <create+0x94>
    iunlockput(dp);
    800044da:	854a                	mv	a0,s2
    800044dc:	fffff097          	auipc	ra,0xfffff
    800044e0:	8a0080e7          	jalr	-1888(ra) # 80002d7c <iunlockput>
    ilock(ip);
    800044e4:	8526                	mv	a0,s1
    800044e6:	ffffe097          	auipc	ra,0xffffe
    800044ea:	634080e7          	jalr	1588(ra) # 80002b1a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800044ee:	2981                	sext.w	s3,s3
    800044f0:	4789                	li	a5,2
    800044f2:	02f99463          	bne	s3,a5,8000451a <create+0x86>
    800044f6:	0444d783          	lhu	a5,68(s1)
    800044fa:	37f9                	addiw	a5,a5,-2
    800044fc:	17c2                	slli	a5,a5,0x30
    800044fe:	93c1                	srli	a5,a5,0x30
    80004500:	4705                	li	a4,1
    80004502:	00f76c63          	bltu	a4,a5,8000451a <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80004506:	8526                	mv	a0,s1
    80004508:	60a6                	ld	ra,72(sp)
    8000450a:	6406                	ld	s0,64(sp)
    8000450c:	74e2                	ld	s1,56(sp)
    8000450e:	7942                	ld	s2,48(sp)
    80004510:	79a2                	ld	s3,40(sp)
    80004512:	7a02                	ld	s4,32(sp)
    80004514:	6ae2                	ld	s5,24(sp)
    80004516:	6161                	addi	sp,sp,80
    80004518:	8082                	ret
    iunlockput(ip);
    8000451a:	8526                	mv	a0,s1
    8000451c:	fffff097          	auipc	ra,0xfffff
    80004520:	860080e7          	jalr	-1952(ra) # 80002d7c <iunlockput>
    return 0;
    80004524:	4481                	li	s1,0
    80004526:	b7c5                	j	80004506 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80004528:	85ce                	mv	a1,s3
    8000452a:	00092503          	lw	a0,0(s2)
    8000452e:	ffffe097          	auipc	ra,0xffffe
    80004532:	454080e7          	jalr	1108(ra) # 80002982 <ialloc>
    80004536:	84aa                	mv	s1,a0
    80004538:	c521                	beqz	a0,80004580 <create+0xec>
  ilock(ip);
    8000453a:	ffffe097          	auipc	ra,0xffffe
    8000453e:	5e0080e7          	jalr	1504(ra) # 80002b1a <ilock>
  ip->major = major;
    80004542:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80004546:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000454a:	4a05                	li	s4,1
    8000454c:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80004550:	8526                	mv	a0,s1
    80004552:	ffffe097          	auipc	ra,0xffffe
    80004556:	4fe080e7          	jalr	1278(ra) # 80002a50 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000455a:	2981                	sext.w	s3,s3
    8000455c:	03498a63          	beq	s3,s4,80004590 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80004560:	40d0                	lw	a2,4(s1)
    80004562:	fb040593          	addi	a1,s0,-80
    80004566:	854a                	mv	a0,s2
    80004568:	fffff097          	auipc	ra,0xfffff
    8000456c:	ca6080e7          	jalr	-858(ra) # 8000320e <dirlink>
    80004570:	06054b63          	bltz	a0,800045e6 <create+0x152>
  iunlockput(dp);
    80004574:	854a                	mv	a0,s2
    80004576:	fffff097          	auipc	ra,0xfffff
    8000457a:	806080e7          	jalr	-2042(ra) # 80002d7c <iunlockput>
  return ip;
    8000457e:	b761                	j	80004506 <create+0x72>
    panic("create: ialloc");
    80004580:	00005517          	auipc	a0,0x5
    80004584:	11050513          	addi	a0,a0,272 # 80009690 <syscalls+0x2e0>
    80004588:	00002097          	auipc	ra,0x2
    8000458c:	6ac080e7          	jalr	1708(ra) # 80006c34 <panic>
    dp->nlink++;  // for ".."
    80004590:	04a95783          	lhu	a5,74(s2)
    80004594:	2785                	addiw	a5,a5,1
    80004596:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000459a:	854a                	mv	a0,s2
    8000459c:	ffffe097          	auipc	ra,0xffffe
    800045a0:	4b4080e7          	jalr	1204(ra) # 80002a50 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800045a4:	40d0                	lw	a2,4(s1)
    800045a6:	00005597          	auipc	a1,0x5
    800045aa:	0fa58593          	addi	a1,a1,250 # 800096a0 <syscalls+0x2f0>
    800045ae:	8526                	mv	a0,s1
    800045b0:	fffff097          	auipc	ra,0xfffff
    800045b4:	c5e080e7          	jalr	-930(ra) # 8000320e <dirlink>
    800045b8:	00054f63          	bltz	a0,800045d6 <create+0x142>
    800045bc:	00492603          	lw	a2,4(s2)
    800045c0:	00005597          	auipc	a1,0x5
    800045c4:	0e858593          	addi	a1,a1,232 # 800096a8 <syscalls+0x2f8>
    800045c8:	8526                	mv	a0,s1
    800045ca:	fffff097          	auipc	ra,0xfffff
    800045ce:	c44080e7          	jalr	-956(ra) # 8000320e <dirlink>
    800045d2:	f80557e3          	bgez	a0,80004560 <create+0xcc>
      panic("create dots");
    800045d6:	00005517          	auipc	a0,0x5
    800045da:	0da50513          	addi	a0,a0,218 # 800096b0 <syscalls+0x300>
    800045de:	00002097          	auipc	ra,0x2
    800045e2:	656080e7          	jalr	1622(ra) # 80006c34 <panic>
    panic("create: dirlink");
    800045e6:	00005517          	auipc	a0,0x5
    800045ea:	0da50513          	addi	a0,a0,218 # 800096c0 <syscalls+0x310>
    800045ee:	00002097          	auipc	ra,0x2
    800045f2:	646080e7          	jalr	1606(ra) # 80006c34 <panic>
    return 0;
    800045f6:	84aa                	mv	s1,a0
    800045f8:	b739                	j	80004506 <create+0x72>

00000000800045fa <sys_dup>:
{
    800045fa:	7179                	addi	sp,sp,-48
    800045fc:	f406                	sd	ra,40(sp)
    800045fe:	f022                	sd	s0,32(sp)
    80004600:	ec26                	sd	s1,24(sp)
    80004602:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004604:	fd840613          	addi	a2,s0,-40
    80004608:	4581                	li	a1,0
    8000460a:	4501                	li	a0,0
    8000460c:	00000097          	auipc	ra,0x0
    80004610:	dde080e7          	jalr	-546(ra) # 800043ea <argfd>
    return -1;
    80004614:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004616:	02054363          	bltz	a0,8000463c <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000461a:	fd843503          	ld	a0,-40(s0)
    8000461e:	00000097          	auipc	ra,0x0
    80004622:	e34080e7          	jalr	-460(ra) # 80004452 <fdalloc>
    80004626:	84aa                	mv	s1,a0
    return -1;
    80004628:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000462a:	00054963          	bltz	a0,8000463c <sys_dup+0x42>
  filedup(f);
    8000462e:	fd843503          	ld	a0,-40(s0)
    80004632:	fffff097          	auipc	ra,0xfffff
    80004636:	33c080e7          	jalr	828(ra) # 8000396e <filedup>
  return fd;
    8000463a:	87a6                	mv	a5,s1
}
    8000463c:	853e                	mv	a0,a5
    8000463e:	70a2                	ld	ra,40(sp)
    80004640:	7402                	ld	s0,32(sp)
    80004642:	64e2                	ld	s1,24(sp)
    80004644:	6145                	addi	sp,sp,48
    80004646:	8082                	ret

0000000080004648 <sys_read>:
{
    80004648:	7179                	addi	sp,sp,-48
    8000464a:	f406                	sd	ra,40(sp)
    8000464c:	f022                	sd	s0,32(sp)
    8000464e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004650:	fe840613          	addi	a2,s0,-24
    80004654:	4581                	li	a1,0
    80004656:	4501                	li	a0,0
    80004658:	00000097          	auipc	ra,0x0
    8000465c:	d92080e7          	jalr	-622(ra) # 800043ea <argfd>
    return -1;
    80004660:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004662:	04054163          	bltz	a0,800046a4 <sys_read+0x5c>
    80004666:	fe440593          	addi	a1,s0,-28
    8000466a:	4509                	li	a0,2
    8000466c:	ffffe097          	auipc	ra,0xffffe
    80004670:	93e080e7          	jalr	-1730(ra) # 80001faa <argint>
    return -1;
    80004674:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004676:	02054763          	bltz	a0,800046a4 <sys_read+0x5c>
    8000467a:	fd840593          	addi	a1,s0,-40
    8000467e:	4505                	li	a0,1
    80004680:	ffffe097          	auipc	ra,0xffffe
    80004684:	94c080e7          	jalr	-1716(ra) # 80001fcc <argaddr>
    return -1;
    80004688:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000468a:	00054d63          	bltz	a0,800046a4 <sys_read+0x5c>
  return fileread(f, p, n);
    8000468e:	fe442603          	lw	a2,-28(s0)
    80004692:	fd843583          	ld	a1,-40(s0)
    80004696:	fe843503          	ld	a0,-24(s0)
    8000469a:	fffff097          	auipc	ra,0xfffff
    8000469e:	47c080e7          	jalr	1148(ra) # 80003b16 <fileread>
    800046a2:	87aa                	mv	a5,a0
}
    800046a4:	853e                	mv	a0,a5
    800046a6:	70a2                	ld	ra,40(sp)
    800046a8:	7402                	ld	s0,32(sp)
    800046aa:	6145                	addi	sp,sp,48
    800046ac:	8082                	ret

00000000800046ae <sys_write>:
{
    800046ae:	7179                	addi	sp,sp,-48
    800046b0:	f406                	sd	ra,40(sp)
    800046b2:	f022                	sd	s0,32(sp)
    800046b4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800046b6:	fe840613          	addi	a2,s0,-24
    800046ba:	4581                	li	a1,0
    800046bc:	4501                	li	a0,0
    800046be:	00000097          	auipc	ra,0x0
    800046c2:	d2c080e7          	jalr	-724(ra) # 800043ea <argfd>
    return -1;
    800046c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800046c8:	04054163          	bltz	a0,8000470a <sys_write+0x5c>
    800046cc:	fe440593          	addi	a1,s0,-28
    800046d0:	4509                	li	a0,2
    800046d2:	ffffe097          	auipc	ra,0xffffe
    800046d6:	8d8080e7          	jalr	-1832(ra) # 80001faa <argint>
    return -1;
    800046da:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800046dc:	02054763          	bltz	a0,8000470a <sys_write+0x5c>
    800046e0:	fd840593          	addi	a1,s0,-40
    800046e4:	4505                	li	a0,1
    800046e6:	ffffe097          	auipc	ra,0xffffe
    800046ea:	8e6080e7          	jalr	-1818(ra) # 80001fcc <argaddr>
    return -1;
    800046ee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800046f0:	00054d63          	bltz	a0,8000470a <sys_write+0x5c>
  return filewrite(f, p, n);
    800046f4:	fe442603          	lw	a2,-28(s0)
    800046f8:	fd843583          	ld	a1,-40(s0)
    800046fc:	fe843503          	ld	a0,-24(s0)
    80004700:	fffff097          	auipc	ra,0xfffff
    80004704:	4ec080e7          	jalr	1260(ra) # 80003bec <filewrite>
    80004708:	87aa                	mv	a5,a0
}
    8000470a:	853e                	mv	a0,a5
    8000470c:	70a2                	ld	ra,40(sp)
    8000470e:	7402                	ld	s0,32(sp)
    80004710:	6145                	addi	sp,sp,48
    80004712:	8082                	ret

0000000080004714 <sys_close>:
{
    80004714:	1101                	addi	sp,sp,-32
    80004716:	ec06                	sd	ra,24(sp)
    80004718:	e822                	sd	s0,16(sp)
    8000471a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000471c:	fe040613          	addi	a2,s0,-32
    80004720:	fec40593          	addi	a1,s0,-20
    80004724:	4501                	li	a0,0
    80004726:	00000097          	auipc	ra,0x0
    8000472a:	cc4080e7          	jalr	-828(ra) # 800043ea <argfd>
    return -1;
    8000472e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004730:	02054463          	bltz	a0,80004758 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80004734:	ffffc097          	auipc	ra,0xffffc
    80004738:	78c080e7          	jalr	1932(ra) # 80000ec0 <myproc>
    8000473c:	fec42783          	lw	a5,-20(s0)
    80004740:	07e9                	addi	a5,a5,26
    80004742:	078e                	slli	a5,a5,0x3
    80004744:	97aa                	add	a5,a5,a0
    80004746:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000474a:	fe043503          	ld	a0,-32(s0)
    8000474e:	fffff097          	auipc	ra,0xfffff
    80004752:	272080e7          	jalr	626(ra) # 800039c0 <fileclose>
  return 0;
    80004756:	4781                	li	a5,0
}
    80004758:	853e                	mv	a0,a5
    8000475a:	60e2                	ld	ra,24(sp)
    8000475c:	6442                	ld	s0,16(sp)
    8000475e:	6105                	addi	sp,sp,32
    80004760:	8082                	ret

0000000080004762 <sys_fstat>:
{
    80004762:	1101                	addi	sp,sp,-32
    80004764:	ec06                	sd	ra,24(sp)
    80004766:	e822                	sd	s0,16(sp)
    80004768:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000476a:	fe840613          	addi	a2,s0,-24
    8000476e:	4581                	li	a1,0
    80004770:	4501                	li	a0,0
    80004772:	00000097          	auipc	ra,0x0
    80004776:	c78080e7          	jalr	-904(ra) # 800043ea <argfd>
    return -1;
    8000477a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000477c:	02054563          	bltz	a0,800047a6 <sys_fstat+0x44>
    80004780:	fe040593          	addi	a1,s0,-32
    80004784:	4505                	li	a0,1
    80004786:	ffffe097          	auipc	ra,0xffffe
    8000478a:	846080e7          	jalr	-1978(ra) # 80001fcc <argaddr>
    return -1;
    8000478e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80004790:	00054b63          	bltz	a0,800047a6 <sys_fstat+0x44>
  return filestat(f, st);
    80004794:	fe043583          	ld	a1,-32(s0)
    80004798:	fe843503          	ld	a0,-24(s0)
    8000479c:	fffff097          	auipc	ra,0xfffff
    800047a0:	308080e7          	jalr	776(ra) # 80003aa4 <filestat>
    800047a4:	87aa                	mv	a5,a0
}
    800047a6:	853e                	mv	a0,a5
    800047a8:	60e2                	ld	ra,24(sp)
    800047aa:	6442                	ld	s0,16(sp)
    800047ac:	6105                	addi	sp,sp,32
    800047ae:	8082                	ret

00000000800047b0 <sys_link>:
{
    800047b0:	7169                	addi	sp,sp,-304
    800047b2:	f606                	sd	ra,296(sp)
    800047b4:	f222                	sd	s0,288(sp)
    800047b6:	ee26                	sd	s1,280(sp)
    800047b8:	ea4a                	sd	s2,272(sp)
    800047ba:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800047bc:	08000613          	li	a2,128
    800047c0:	ed040593          	addi	a1,s0,-304
    800047c4:	4501                	li	a0,0
    800047c6:	ffffe097          	auipc	ra,0xffffe
    800047ca:	828080e7          	jalr	-2008(ra) # 80001fee <argstr>
    return -1;
    800047ce:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800047d0:	10054e63          	bltz	a0,800048ec <sys_link+0x13c>
    800047d4:	08000613          	li	a2,128
    800047d8:	f5040593          	addi	a1,s0,-176
    800047dc:	4505                	li	a0,1
    800047de:	ffffe097          	auipc	ra,0xffffe
    800047e2:	810080e7          	jalr	-2032(ra) # 80001fee <argstr>
    return -1;
    800047e6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800047e8:	10054263          	bltz	a0,800048ec <sys_link+0x13c>
  begin_op();
    800047ec:	fffff097          	auipc	ra,0xfffff
    800047f0:	d00080e7          	jalr	-768(ra) # 800034ec <begin_op>
  if((ip = namei(old)) == 0){
    800047f4:	ed040513          	addi	a0,s0,-304
    800047f8:	fffff097          	auipc	ra,0xfffff
    800047fc:	ad8080e7          	jalr	-1320(ra) # 800032d0 <namei>
    80004800:	84aa                	mv	s1,a0
    80004802:	c551                	beqz	a0,8000488e <sys_link+0xde>
  ilock(ip);
    80004804:	ffffe097          	auipc	ra,0xffffe
    80004808:	316080e7          	jalr	790(ra) # 80002b1a <ilock>
  if(ip->type == T_DIR){
    8000480c:	04449703          	lh	a4,68(s1)
    80004810:	4785                	li	a5,1
    80004812:	08f70463          	beq	a4,a5,8000489a <sys_link+0xea>
  ip->nlink++;
    80004816:	04a4d783          	lhu	a5,74(s1)
    8000481a:	2785                	addiw	a5,a5,1
    8000481c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004820:	8526                	mv	a0,s1
    80004822:	ffffe097          	auipc	ra,0xffffe
    80004826:	22e080e7          	jalr	558(ra) # 80002a50 <iupdate>
  iunlock(ip);
    8000482a:	8526                	mv	a0,s1
    8000482c:	ffffe097          	auipc	ra,0xffffe
    80004830:	3b0080e7          	jalr	944(ra) # 80002bdc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004834:	fd040593          	addi	a1,s0,-48
    80004838:	f5040513          	addi	a0,s0,-176
    8000483c:	fffff097          	auipc	ra,0xfffff
    80004840:	ab2080e7          	jalr	-1358(ra) # 800032ee <nameiparent>
    80004844:	892a                	mv	s2,a0
    80004846:	c935                	beqz	a0,800048ba <sys_link+0x10a>
  ilock(dp);
    80004848:	ffffe097          	auipc	ra,0xffffe
    8000484c:	2d2080e7          	jalr	722(ra) # 80002b1a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004850:	00092703          	lw	a4,0(s2)
    80004854:	409c                	lw	a5,0(s1)
    80004856:	04f71d63          	bne	a4,a5,800048b0 <sys_link+0x100>
    8000485a:	40d0                	lw	a2,4(s1)
    8000485c:	fd040593          	addi	a1,s0,-48
    80004860:	854a                	mv	a0,s2
    80004862:	fffff097          	auipc	ra,0xfffff
    80004866:	9ac080e7          	jalr	-1620(ra) # 8000320e <dirlink>
    8000486a:	04054363          	bltz	a0,800048b0 <sys_link+0x100>
  iunlockput(dp);
    8000486e:	854a                	mv	a0,s2
    80004870:	ffffe097          	auipc	ra,0xffffe
    80004874:	50c080e7          	jalr	1292(ra) # 80002d7c <iunlockput>
  iput(ip);
    80004878:	8526                	mv	a0,s1
    8000487a:	ffffe097          	auipc	ra,0xffffe
    8000487e:	45a080e7          	jalr	1114(ra) # 80002cd4 <iput>
  end_op();
    80004882:	fffff097          	auipc	ra,0xfffff
    80004886:	cea080e7          	jalr	-790(ra) # 8000356c <end_op>
  return 0;
    8000488a:	4781                	li	a5,0
    8000488c:	a085                	j	800048ec <sys_link+0x13c>
    end_op();
    8000488e:	fffff097          	auipc	ra,0xfffff
    80004892:	cde080e7          	jalr	-802(ra) # 8000356c <end_op>
    return -1;
    80004896:	57fd                	li	a5,-1
    80004898:	a891                	j	800048ec <sys_link+0x13c>
    iunlockput(ip);
    8000489a:	8526                	mv	a0,s1
    8000489c:	ffffe097          	auipc	ra,0xffffe
    800048a0:	4e0080e7          	jalr	1248(ra) # 80002d7c <iunlockput>
    end_op();
    800048a4:	fffff097          	auipc	ra,0xfffff
    800048a8:	cc8080e7          	jalr	-824(ra) # 8000356c <end_op>
    return -1;
    800048ac:	57fd                	li	a5,-1
    800048ae:	a83d                	j	800048ec <sys_link+0x13c>
    iunlockput(dp);
    800048b0:	854a                	mv	a0,s2
    800048b2:	ffffe097          	auipc	ra,0xffffe
    800048b6:	4ca080e7          	jalr	1226(ra) # 80002d7c <iunlockput>
  ilock(ip);
    800048ba:	8526                	mv	a0,s1
    800048bc:	ffffe097          	auipc	ra,0xffffe
    800048c0:	25e080e7          	jalr	606(ra) # 80002b1a <ilock>
  ip->nlink--;
    800048c4:	04a4d783          	lhu	a5,74(s1)
    800048c8:	37fd                	addiw	a5,a5,-1
    800048ca:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800048ce:	8526                	mv	a0,s1
    800048d0:	ffffe097          	auipc	ra,0xffffe
    800048d4:	180080e7          	jalr	384(ra) # 80002a50 <iupdate>
  iunlockput(ip);
    800048d8:	8526                	mv	a0,s1
    800048da:	ffffe097          	auipc	ra,0xffffe
    800048de:	4a2080e7          	jalr	1186(ra) # 80002d7c <iunlockput>
  end_op();
    800048e2:	fffff097          	auipc	ra,0xfffff
    800048e6:	c8a080e7          	jalr	-886(ra) # 8000356c <end_op>
  return -1;
    800048ea:	57fd                	li	a5,-1
}
    800048ec:	853e                	mv	a0,a5
    800048ee:	70b2                	ld	ra,296(sp)
    800048f0:	7412                	ld	s0,288(sp)
    800048f2:	64f2                	ld	s1,280(sp)
    800048f4:	6952                	ld	s2,272(sp)
    800048f6:	6155                	addi	sp,sp,304
    800048f8:	8082                	ret

00000000800048fa <sys_unlink>:
{
    800048fa:	7151                	addi	sp,sp,-240
    800048fc:	f586                	sd	ra,232(sp)
    800048fe:	f1a2                	sd	s0,224(sp)
    80004900:	eda6                	sd	s1,216(sp)
    80004902:	e9ca                	sd	s2,208(sp)
    80004904:	e5ce                	sd	s3,200(sp)
    80004906:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004908:	08000613          	li	a2,128
    8000490c:	f3040593          	addi	a1,s0,-208
    80004910:	4501                	li	a0,0
    80004912:	ffffd097          	auipc	ra,0xffffd
    80004916:	6dc080e7          	jalr	1756(ra) # 80001fee <argstr>
    8000491a:	18054163          	bltz	a0,80004a9c <sys_unlink+0x1a2>
  begin_op();
    8000491e:	fffff097          	auipc	ra,0xfffff
    80004922:	bce080e7          	jalr	-1074(ra) # 800034ec <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004926:	fb040593          	addi	a1,s0,-80
    8000492a:	f3040513          	addi	a0,s0,-208
    8000492e:	fffff097          	auipc	ra,0xfffff
    80004932:	9c0080e7          	jalr	-1600(ra) # 800032ee <nameiparent>
    80004936:	84aa                	mv	s1,a0
    80004938:	c979                	beqz	a0,80004a0e <sys_unlink+0x114>
  ilock(dp);
    8000493a:	ffffe097          	auipc	ra,0xffffe
    8000493e:	1e0080e7          	jalr	480(ra) # 80002b1a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004942:	00005597          	auipc	a1,0x5
    80004946:	d5e58593          	addi	a1,a1,-674 # 800096a0 <syscalls+0x2f0>
    8000494a:	fb040513          	addi	a0,s0,-80
    8000494e:	ffffe097          	auipc	ra,0xffffe
    80004952:	696080e7          	jalr	1686(ra) # 80002fe4 <namecmp>
    80004956:	14050a63          	beqz	a0,80004aaa <sys_unlink+0x1b0>
    8000495a:	00005597          	auipc	a1,0x5
    8000495e:	d4e58593          	addi	a1,a1,-690 # 800096a8 <syscalls+0x2f8>
    80004962:	fb040513          	addi	a0,s0,-80
    80004966:	ffffe097          	auipc	ra,0xffffe
    8000496a:	67e080e7          	jalr	1662(ra) # 80002fe4 <namecmp>
    8000496e:	12050e63          	beqz	a0,80004aaa <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004972:	f2c40613          	addi	a2,s0,-212
    80004976:	fb040593          	addi	a1,s0,-80
    8000497a:	8526                	mv	a0,s1
    8000497c:	ffffe097          	auipc	ra,0xffffe
    80004980:	682080e7          	jalr	1666(ra) # 80002ffe <dirlookup>
    80004984:	892a                	mv	s2,a0
    80004986:	12050263          	beqz	a0,80004aaa <sys_unlink+0x1b0>
  ilock(ip);
    8000498a:	ffffe097          	auipc	ra,0xffffe
    8000498e:	190080e7          	jalr	400(ra) # 80002b1a <ilock>
  if(ip->nlink < 1)
    80004992:	04a91783          	lh	a5,74(s2)
    80004996:	08f05263          	blez	a5,80004a1a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000499a:	04491703          	lh	a4,68(s2)
    8000499e:	4785                	li	a5,1
    800049a0:	08f70563          	beq	a4,a5,80004a2a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800049a4:	4641                	li	a2,16
    800049a6:	4581                	li	a1,0
    800049a8:	fc040513          	addi	a0,s0,-64
    800049ac:	ffffb097          	auipc	ra,0xffffb
    800049b0:	7cc080e7          	jalr	1996(ra) # 80000178 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800049b4:	4741                	li	a4,16
    800049b6:	f2c42683          	lw	a3,-212(s0)
    800049ba:	fc040613          	addi	a2,s0,-64
    800049be:	4581                	li	a1,0
    800049c0:	8526                	mv	a0,s1
    800049c2:	ffffe097          	auipc	ra,0xffffe
    800049c6:	504080e7          	jalr	1284(ra) # 80002ec6 <writei>
    800049ca:	47c1                	li	a5,16
    800049cc:	0af51563          	bne	a0,a5,80004a76 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800049d0:	04491703          	lh	a4,68(s2)
    800049d4:	4785                	li	a5,1
    800049d6:	0af70863          	beq	a4,a5,80004a86 <sys_unlink+0x18c>
  iunlockput(dp);
    800049da:	8526                	mv	a0,s1
    800049dc:	ffffe097          	auipc	ra,0xffffe
    800049e0:	3a0080e7          	jalr	928(ra) # 80002d7c <iunlockput>
  ip->nlink--;
    800049e4:	04a95783          	lhu	a5,74(s2)
    800049e8:	37fd                	addiw	a5,a5,-1
    800049ea:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800049ee:	854a                	mv	a0,s2
    800049f0:	ffffe097          	auipc	ra,0xffffe
    800049f4:	060080e7          	jalr	96(ra) # 80002a50 <iupdate>
  iunlockput(ip);
    800049f8:	854a                	mv	a0,s2
    800049fa:	ffffe097          	auipc	ra,0xffffe
    800049fe:	382080e7          	jalr	898(ra) # 80002d7c <iunlockput>
  end_op();
    80004a02:	fffff097          	auipc	ra,0xfffff
    80004a06:	b6a080e7          	jalr	-1174(ra) # 8000356c <end_op>
  return 0;
    80004a0a:	4501                	li	a0,0
    80004a0c:	a84d                	j	80004abe <sys_unlink+0x1c4>
    end_op();
    80004a0e:	fffff097          	auipc	ra,0xfffff
    80004a12:	b5e080e7          	jalr	-1186(ra) # 8000356c <end_op>
    return -1;
    80004a16:	557d                	li	a0,-1
    80004a18:	a05d                	j	80004abe <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80004a1a:	00005517          	auipc	a0,0x5
    80004a1e:	cb650513          	addi	a0,a0,-842 # 800096d0 <syscalls+0x320>
    80004a22:	00002097          	auipc	ra,0x2
    80004a26:	212080e7          	jalr	530(ra) # 80006c34 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004a2a:	04c92703          	lw	a4,76(s2)
    80004a2e:	02000793          	li	a5,32
    80004a32:	f6e7f9e3          	bgeu	a5,a4,800049a4 <sys_unlink+0xaa>
    80004a36:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a3a:	4741                	li	a4,16
    80004a3c:	86ce                	mv	a3,s3
    80004a3e:	f1840613          	addi	a2,s0,-232
    80004a42:	4581                	li	a1,0
    80004a44:	854a                	mv	a0,s2
    80004a46:	ffffe097          	auipc	ra,0xffffe
    80004a4a:	388080e7          	jalr	904(ra) # 80002dce <readi>
    80004a4e:	47c1                	li	a5,16
    80004a50:	00f51b63          	bne	a0,a5,80004a66 <sys_unlink+0x16c>
    if(de.inum != 0)
    80004a54:	f1845783          	lhu	a5,-232(s0)
    80004a58:	e7a1                	bnez	a5,80004aa0 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004a5a:	29c1                	addiw	s3,s3,16
    80004a5c:	04c92783          	lw	a5,76(s2)
    80004a60:	fcf9ede3          	bltu	s3,a5,80004a3a <sys_unlink+0x140>
    80004a64:	b781                	j	800049a4 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004a66:	00005517          	auipc	a0,0x5
    80004a6a:	c8250513          	addi	a0,a0,-894 # 800096e8 <syscalls+0x338>
    80004a6e:	00002097          	auipc	ra,0x2
    80004a72:	1c6080e7          	jalr	454(ra) # 80006c34 <panic>
    panic("unlink: writei");
    80004a76:	00005517          	auipc	a0,0x5
    80004a7a:	c8a50513          	addi	a0,a0,-886 # 80009700 <syscalls+0x350>
    80004a7e:	00002097          	auipc	ra,0x2
    80004a82:	1b6080e7          	jalr	438(ra) # 80006c34 <panic>
    dp->nlink--;
    80004a86:	04a4d783          	lhu	a5,74(s1)
    80004a8a:	37fd                	addiw	a5,a5,-1
    80004a8c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004a90:	8526                	mv	a0,s1
    80004a92:	ffffe097          	auipc	ra,0xffffe
    80004a96:	fbe080e7          	jalr	-66(ra) # 80002a50 <iupdate>
    80004a9a:	b781                	j	800049da <sys_unlink+0xe0>
    return -1;
    80004a9c:	557d                	li	a0,-1
    80004a9e:	a005                	j	80004abe <sys_unlink+0x1c4>
    iunlockput(ip);
    80004aa0:	854a                	mv	a0,s2
    80004aa2:	ffffe097          	auipc	ra,0xffffe
    80004aa6:	2da080e7          	jalr	730(ra) # 80002d7c <iunlockput>
  iunlockput(dp);
    80004aaa:	8526                	mv	a0,s1
    80004aac:	ffffe097          	auipc	ra,0xffffe
    80004ab0:	2d0080e7          	jalr	720(ra) # 80002d7c <iunlockput>
  end_op();
    80004ab4:	fffff097          	auipc	ra,0xfffff
    80004ab8:	ab8080e7          	jalr	-1352(ra) # 8000356c <end_op>
  return -1;
    80004abc:	557d                	li	a0,-1
}
    80004abe:	70ae                	ld	ra,232(sp)
    80004ac0:	740e                	ld	s0,224(sp)
    80004ac2:	64ee                	ld	s1,216(sp)
    80004ac4:	694e                	ld	s2,208(sp)
    80004ac6:	69ae                	ld	s3,200(sp)
    80004ac8:	616d                	addi	sp,sp,240
    80004aca:	8082                	ret

0000000080004acc <sys_open>:

uint64
sys_open(void)
{
    80004acc:	7131                	addi	sp,sp,-192
    80004ace:	fd06                	sd	ra,184(sp)
    80004ad0:	f922                	sd	s0,176(sp)
    80004ad2:	f526                	sd	s1,168(sp)
    80004ad4:	f14a                	sd	s2,160(sp)
    80004ad6:	ed4e                	sd	s3,152(sp)
    80004ad8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80004ada:	08000613          	li	a2,128
    80004ade:	f5040593          	addi	a1,s0,-176
    80004ae2:	4501                	li	a0,0
    80004ae4:	ffffd097          	auipc	ra,0xffffd
    80004ae8:	50a080e7          	jalr	1290(ra) # 80001fee <argstr>
    return -1;
    80004aec:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80004aee:	0c054163          	bltz	a0,80004bb0 <sys_open+0xe4>
    80004af2:	f4c40593          	addi	a1,s0,-180
    80004af6:	4505                	li	a0,1
    80004af8:	ffffd097          	auipc	ra,0xffffd
    80004afc:	4b2080e7          	jalr	1202(ra) # 80001faa <argint>
    80004b00:	0a054863          	bltz	a0,80004bb0 <sys_open+0xe4>

  begin_op();
    80004b04:	fffff097          	auipc	ra,0xfffff
    80004b08:	9e8080e7          	jalr	-1560(ra) # 800034ec <begin_op>

  if(omode & O_CREATE){
    80004b0c:	f4c42783          	lw	a5,-180(s0)
    80004b10:	2007f793          	andi	a5,a5,512
    80004b14:	cbdd                	beqz	a5,80004bca <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004b16:	4681                	li	a3,0
    80004b18:	4601                	li	a2,0
    80004b1a:	4589                	li	a1,2
    80004b1c:	f5040513          	addi	a0,s0,-176
    80004b20:	00000097          	auipc	ra,0x0
    80004b24:	974080e7          	jalr	-1676(ra) # 80004494 <create>
    80004b28:	892a                	mv	s2,a0
    if(ip == 0){
    80004b2a:	c959                	beqz	a0,80004bc0 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004b2c:	04491703          	lh	a4,68(s2)
    80004b30:	478d                	li	a5,3
    80004b32:	00f71763          	bne	a4,a5,80004b40 <sys_open+0x74>
    80004b36:	04695703          	lhu	a4,70(s2)
    80004b3a:	47a5                	li	a5,9
    80004b3c:	0ce7ec63          	bltu	a5,a4,80004c14 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004b40:	fffff097          	auipc	ra,0xfffff
    80004b44:	dc4080e7          	jalr	-572(ra) # 80003904 <filealloc>
    80004b48:	89aa                	mv	s3,a0
    80004b4a:	10050263          	beqz	a0,80004c4e <sys_open+0x182>
    80004b4e:	00000097          	auipc	ra,0x0
    80004b52:	904080e7          	jalr	-1788(ra) # 80004452 <fdalloc>
    80004b56:	84aa                	mv	s1,a0
    80004b58:	0e054663          	bltz	a0,80004c44 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004b5c:	04491703          	lh	a4,68(s2)
    80004b60:	478d                	li	a5,3
    80004b62:	0cf70463          	beq	a4,a5,80004c2a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004b66:	4789                	li	a5,2
    80004b68:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004b6c:	0209a423          	sw	zero,40(s3)
  }
  f->ip = ip;
    80004b70:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004b74:	f4c42783          	lw	a5,-180(s0)
    80004b78:	0017c713          	xori	a4,a5,1
    80004b7c:	8b05                	andi	a4,a4,1
    80004b7e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004b82:	0037f713          	andi	a4,a5,3
    80004b86:	00e03733          	snez	a4,a4
    80004b8a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004b8e:	4007f793          	andi	a5,a5,1024
    80004b92:	c791                	beqz	a5,80004b9e <sys_open+0xd2>
    80004b94:	04491703          	lh	a4,68(s2)
    80004b98:	4789                	li	a5,2
    80004b9a:	08f70f63          	beq	a4,a5,80004c38 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004b9e:	854a                	mv	a0,s2
    80004ba0:	ffffe097          	auipc	ra,0xffffe
    80004ba4:	03c080e7          	jalr	60(ra) # 80002bdc <iunlock>
  end_op();
    80004ba8:	fffff097          	auipc	ra,0xfffff
    80004bac:	9c4080e7          	jalr	-1596(ra) # 8000356c <end_op>

  return fd;
}
    80004bb0:	8526                	mv	a0,s1
    80004bb2:	70ea                	ld	ra,184(sp)
    80004bb4:	744a                	ld	s0,176(sp)
    80004bb6:	74aa                	ld	s1,168(sp)
    80004bb8:	790a                	ld	s2,160(sp)
    80004bba:	69ea                	ld	s3,152(sp)
    80004bbc:	6129                	addi	sp,sp,192
    80004bbe:	8082                	ret
      end_op();
    80004bc0:	fffff097          	auipc	ra,0xfffff
    80004bc4:	9ac080e7          	jalr	-1620(ra) # 8000356c <end_op>
      return -1;
    80004bc8:	b7e5                	j	80004bb0 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004bca:	f5040513          	addi	a0,s0,-176
    80004bce:	ffffe097          	auipc	ra,0xffffe
    80004bd2:	702080e7          	jalr	1794(ra) # 800032d0 <namei>
    80004bd6:	892a                	mv	s2,a0
    80004bd8:	c905                	beqz	a0,80004c08 <sys_open+0x13c>
    ilock(ip);
    80004bda:	ffffe097          	auipc	ra,0xffffe
    80004bde:	f40080e7          	jalr	-192(ra) # 80002b1a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004be2:	04491703          	lh	a4,68(s2)
    80004be6:	4785                	li	a5,1
    80004be8:	f4f712e3          	bne	a4,a5,80004b2c <sys_open+0x60>
    80004bec:	f4c42783          	lw	a5,-180(s0)
    80004bf0:	dba1                	beqz	a5,80004b40 <sys_open+0x74>
      iunlockput(ip);
    80004bf2:	854a                	mv	a0,s2
    80004bf4:	ffffe097          	auipc	ra,0xffffe
    80004bf8:	188080e7          	jalr	392(ra) # 80002d7c <iunlockput>
      end_op();
    80004bfc:	fffff097          	auipc	ra,0xfffff
    80004c00:	970080e7          	jalr	-1680(ra) # 8000356c <end_op>
      return -1;
    80004c04:	54fd                	li	s1,-1
    80004c06:	b76d                	j	80004bb0 <sys_open+0xe4>
      end_op();
    80004c08:	fffff097          	auipc	ra,0xfffff
    80004c0c:	964080e7          	jalr	-1692(ra) # 8000356c <end_op>
      return -1;
    80004c10:	54fd                	li	s1,-1
    80004c12:	bf79                	j	80004bb0 <sys_open+0xe4>
    iunlockput(ip);
    80004c14:	854a                	mv	a0,s2
    80004c16:	ffffe097          	auipc	ra,0xffffe
    80004c1a:	166080e7          	jalr	358(ra) # 80002d7c <iunlockput>
    end_op();
    80004c1e:	fffff097          	auipc	ra,0xfffff
    80004c22:	94e080e7          	jalr	-1714(ra) # 8000356c <end_op>
    return -1;
    80004c26:	54fd                	li	s1,-1
    80004c28:	b761                	j	80004bb0 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004c2a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004c2e:	04691783          	lh	a5,70(s2)
    80004c32:	02f99623          	sh	a5,44(s3)
    80004c36:	bf2d                	j	80004b70 <sys_open+0xa4>
    itrunc(ip);
    80004c38:	854a                	mv	a0,s2
    80004c3a:	ffffe097          	auipc	ra,0xffffe
    80004c3e:	fee080e7          	jalr	-18(ra) # 80002c28 <itrunc>
    80004c42:	bfb1                	j	80004b9e <sys_open+0xd2>
      fileclose(f);
    80004c44:	854e                	mv	a0,s3
    80004c46:	fffff097          	auipc	ra,0xfffff
    80004c4a:	d7a080e7          	jalr	-646(ra) # 800039c0 <fileclose>
    iunlockput(ip);
    80004c4e:	854a                	mv	a0,s2
    80004c50:	ffffe097          	auipc	ra,0xffffe
    80004c54:	12c080e7          	jalr	300(ra) # 80002d7c <iunlockput>
    end_op();
    80004c58:	fffff097          	auipc	ra,0xfffff
    80004c5c:	914080e7          	jalr	-1772(ra) # 8000356c <end_op>
    return -1;
    80004c60:	54fd                	li	s1,-1
    80004c62:	b7b9                	j	80004bb0 <sys_open+0xe4>

0000000080004c64 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004c64:	7175                	addi	sp,sp,-144
    80004c66:	e506                	sd	ra,136(sp)
    80004c68:	e122                	sd	s0,128(sp)
    80004c6a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004c6c:	fffff097          	auipc	ra,0xfffff
    80004c70:	880080e7          	jalr	-1920(ra) # 800034ec <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004c74:	08000613          	li	a2,128
    80004c78:	f7040593          	addi	a1,s0,-144
    80004c7c:	4501                	li	a0,0
    80004c7e:	ffffd097          	auipc	ra,0xffffd
    80004c82:	370080e7          	jalr	880(ra) # 80001fee <argstr>
    80004c86:	02054963          	bltz	a0,80004cb8 <sys_mkdir+0x54>
    80004c8a:	4681                	li	a3,0
    80004c8c:	4601                	li	a2,0
    80004c8e:	4585                	li	a1,1
    80004c90:	f7040513          	addi	a0,s0,-144
    80004c94:	00000097          	auipc	ra,0x0
    80004c98:	800080e7          	jalr	-2048(ra) # 80004494 <create>
    80004c9c:	cd11                	beqz	a0,80004cb8 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004c9e:	ffffe097          	auipc	ra,0xffffe
    80004ca2:	0de080e7          	jalr	222(ra) # 80002d7c <iunlockput>
  end_op();
    80004ca6:	fffff097          	auipc	ra,0xfffff
    80004caa:	8c6080e7          	jalr	-1850(ra) # 8000356c <end_op>
  return 0;
    80004cae:	4501                	li	a0,0
}
    80004cb0:	60aa                	ld	ra,136(sp)
    80004cb2:	640a                	ld	s0,128(sp)
    80004cb4:	6149                	addi	sp,sp,144
    80004cb6:	8082                	ret
    end_op();
    80004cb8:	fffff097          	auipc	ra,0xfffff
    80004cbc:	8b4080e7          	jalr	-1868(ra) # 8000356c <end_op>
    return -1;
    80004cc0:	557d                	li	a0,-1
    80004cc2:	b7fd                	j	80004cb0 <sys_mkdir+0x4c>

0000000080004cc4 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004cc4:	7135                	addi	sp,sp,-160
    80004cc6:	ed06                	sd	ra,152(sp)
    80004cc8:	e922                	sd	s0,144(sp)
    80004cca:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004ccc:	fffff097          	auipc	ra,0xfffff
    80004cd0:	820080e7          	jalr	-2016(ra) # 800034ec <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004cd4:	08000613          	li	a2,128
    80004cd8:	f7040593          	addi	a1,s0,-144
    80004cdc:	4501                	li	a0,0
    80004cde:	ffffd097          	auipc	ra,0xffffd
    80004ce2:	310080e7          	jalr	784(ra) # 80001fee <argstr>
    80004ce6:	04054a63          	bltz	a0,80004d3a <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80004cea:	f6c40593          	addi	a1,s0,-148
    80004cee:	4505                	li	a0,1
    80004cf0:	ffffd097          	auipc	ra,0xffffd
    80004cf4:	2ba080e7          	jalr	698(ra) # 80001faa <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004cf8:	04054163          	bltz	a0,80004d3a <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80004cfc:	f6840593          	addi	a1,s0,-152
    80004d00:	4509                	li	a0,2
    80004d02:	ffffd097          	auipc	ra,0xffffd
    80004d06:	2a8080e7          	jalr	680(ra) # 80001faa <argint>
     argint(1, &major) < 0 ||
    80004d0a:	02054863          	bltz	a0,80004d3a <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004d0e:	f6841683          	lh	a3,-152(s0)
    80004d12:	f6c41603          	lh	a2,-148(s0)
    80004d16:	458d                	li	a1,3
    80004d18:	f7040513          	addi	a0,s0,-144
    80004d1c:	fffff097          	auipc	ra,0xfffff
    80004d20:	778080e7          	jalr	1912(ra) # 80004494 <create>
     argint(2, &minor) < 0 ||
    80004d24:	c919                	beqz	a0,80004d3a <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004d26:	ffffe097          	auipc	ra,0xffffe
    80004d2a:	056080e7          	jalr	86(ra) # 80002d7c <iunlockput>
  end_op();
    80004d2e:	fffff097          	auipc	ra,0xfffff
    80004d32:	83e080e7          	jalr	-1986(ra) # 8000356c <end_op>
  return 0;
    80004d36:	4501                	li	a0,0
    80004d38:	a031                	j	80004d44 <sys_mknod+0x80>
    end_op();
    80004d3a:	fffff097          	auipc	ra,0xfffff
    80004d3e:	832080e7          	jalr	-1998(ra) # 8000356c <end_op>
    return -1;
    80004d42:	557d                	li	a0,-1
}
    80004d44:	60ea                	ld	ra,152(sp)
    80004d46:	644a                	ld	s0,144(sp)
    80004d48:	610d                	addi	sp,sp,160
    80004d4a:	8082                	ret

0000000080004d4c <sys_chdir>:

uint64
sys_chdir(void)
{
    80004d4c:	7135                	addi	sp,sp,-160
    80004d4e:	ed06                	sd	ra,152(sp)
    80004d50:	e922                	sd	s0,144(sp)
    80004d52:	e526                	sd	s1,136(sp)
    80004d54:	e14a                	sd	s2,128(sp)
    80004d56:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004d58:	ffffc097          	auipc	ra,0xffffc
    80004d5c:	168080e7          	jalr	360(ra) # 80000ec0 <myproc>
    80004d60:	892a                	mv	s2,a0
  
  begin_op();
    80004d62:	ffffe097          	auipc	ra,0xffffe
    80004d66:	78a080e7          	jalr	1930(ra) # 800034ec <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004d6a:	08000613          	li	a2,128
    80004d6e:	f6040593          	addi	a1,s0,-160
    80004d72:	4501                	li	a0,0
    80004d74:	ffffd097          	auipc	ra,0xffffd
    80004d78:	27a080e7          	jalr	634(ra) # 80001fee <argstr>
    80004d7c:	04054b63          	bltz	a0,80004dd2 <sys_chdir+0x86>
    80004d80:	f6040513          	addi	a0,s0,-160
    80004d84:	ffffe097          	auipc	ra,0xffffe
    80004d88:	54c080e7          	jalr	1356(ra) # 800032d0 <namei>
    80004d8c:	84aa                	mv	s1,a0
    80004d8e:	c131                	beqz	a0,80004dd2 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80004d90:	ffffe097          	auipc	ra,0xffffe
    80004d94:	d8a080e7          	jalr	-630(ra) # 80002b1a <ilock>
  if(ip->type != T_DIR){
    80004d98:	04449703          	lh	a4,68(s1)
    80004d9c:	4785                	li	a5,1
    80004d9e:	04f71063          	bne	a4,a5,80004dde <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004da2:	8526                	mv	a0,s1
    80004da4:	ffffe097          	auipc	ra,0xffffe
    80004da8:	e38080e7          	jalr	-456(ra) # 80002bdc <iunlock>
  iput(p->cwd);
    80004dac:	15093503          	ld	a0,336(s2)
    80004db0:	ffffe097          	auipc	ra,0xffffe
    80004db4:	f24080e7          	jalr	-220(ra) # 80002cd4 <iput>
  end_op();
    80004db8:	ffffe097          	auipc	ra,0xffffe
    80004dbc:	7b4080e7          	jalr	1972(ra) # 8000356c <end_op>
  p->cwd = ip;
    80004dc0:	14993823          	sd	s1,336(s2)
  return 0;
    80004dc4:	4501                	li	a0,0
}
    80004dc6:	60ea                	ld	ra,152(sp)
    80004dc8:	644a                	ld	s0,144(sp)
    80004dca:	64aa                	ld	s1,136(sp)
    80004dcc:	690a                	ld	s2,128(sp)
    80004dce:	610d                	addi	sp,sp,160
    80004dd0:	8082                	ret
    end_op();
    80004dd2:	ffffe097          	auipc	ra,0xffffe
    80004dd6:	79a080e7          	jalr	1946(ra) # 8000356c <end_op>
    return -1;
    80004dda:	557d                	li	a0,-1
    80004ddc:	b7ed                	j	80004dc6 <sys_chdir+0x7a>
    iunlockput(ip);
    80004dde:	8526                	mv	a0,s1
    80004de0:	ffffe097          	auipc	ra,0xffffe
    80004de4:	f9c080e7          	jalr	-100(ra) # 80002d7c <iunlockput>
    end_op();
    80004de8:	ffffe097          	auipc	ra,0xffffe
    80004dec:	784080e7          	jalr	1924(ra) # 8000356c <end_op>
    return -1;
    80004df0:	557d                	li	a0,-1
    80004df2:	bfd1                	j	80004dc6 <sys_chdir+0x7a>

0000000080004df4 <sys_exec>:

uint64
sys_exec(void)
{
    80004df4:	7145                	addi	sp,sp,-464
    80004df6:	e786                	sd	ra,456(sp)
    80004df8:	e3a2                	sd	s0,448(sp)
    80004dfa:	ff26                	sd	s1,440(sp)
    80004dfc:	fb4a                	sd	s2,432(sp)
    80004dfe:	f74e                	sd	s3,424(sp)
    80004e00:	f352                	sd	s4,416(sp)
    80004e02:	ef56                	sd	s5,408(sp)
    80004e04:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80004e06:	08000613          	li	a2,128
    80004e0a:	f4040593          	addi	a1,s0,-192
    80004e0e:	4501                	li	a0,0
    80004e10:	ffffd097          	auipc	ra,0xffffd
    80004e14:	1de080e7          	jalr	478(ra) # 80001fee <argstr>
    return -1;
    80004e18:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80004e1a:	0c054a63          	bltz	a0,80004eee <sys_exec+0xfa>
    80004e1e:	e3840593          	addi	a1,s0,-456
    80004e22:	4505                	li	a0,1
    80004e24:	ffffd097          	auipc	ra,0xffffd
    80004e28:	1a8080e7          	jalr	424(ra) # 80001fcc <argaddr>
    80004e2c:	0c054163          	bltz	a0,80004eee <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80004e30:	10000613          	li	a2,256
    80004e34:	4581                	li	a1,0
    80004e36:	e4040513          	addi	a0,s0,-448
    80004e3a:	ffffb097          	auipc	ra,0xffffb
    80004e3e:	33e080e7          	jalr	830(ra) # 80000178 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004e42:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004e46:	89a6                	mv	s3,s1
    80004e48:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004e4a:	02000a13          	li	s4,32
    80004e4e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004e52:	00391793          	slli	a5,s2,0x3
    80004e56:	e3040593          	addi	a1,s0,-464
    80004e5a:	e3843503          	ld	a0,-456(s0)
    80004e5e:	953e                	add	a0,a0,a5
    80004e60:	ffffd097          	auipc	ra,0xffffd
    80004e64:	0b0080e7          	jalr	176(ra) # 80001f10 <fetchaddr>
    80004e68:	02054a63          	bltz	a0,80004e9c <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80004e6c:	e3043783          	ld	a5,-464(s0)
    80004e70:	c3b9                	beqz	a5,80004eb6 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004e72:	ffffb097          	auipc	ra,0xffffb
    80004e76:	2a6080e7          	jalr	678(ra) # 80000118 <kalloc>
    80004e7a:	85aa                	mv	a1,a0
    80004e7c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004e80:	cd11                	beqz	a0,80004e9c <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004e82:	6605                	lui	a2,0x1
    80004e84:	e3043503          	ld	a0,-464(s0)
    80004e88:	ffffd097          	auipc	ra,0xffffd
    80004e8c:	0da080e7          	jalr	218(ra) # 80001f62 <fetchstr>
    80004e90:	00054663          	bltz	a0,80004e9c <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80004e94:	0905                	addi	s2,s2,1
    80004e96:	09a1                	addi	s3,s3,8
    80004e98:	fb491be3          	bne	s2,s4,80004e4e <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004e9c:	10048913          	addi	s2,s1,256
    80004ea0:	6088                	ld	a0,0(s1)
    80004ea2:	c529                	beqz	a0,80004eec <sys_exec+0xf8>
    kfree(argv[i]);
    80004ea4:	ffffb097          	auipc	ra,0xffffb
    80004ea8:	178080e7          	jalr	376(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004eac:	04a1                	addi	s1,s1,8
    80004eae:	ff2499e3          	bne	s1,s2,80004ea0 <sys_exec+0xac>
  return -1;
    80004eb2:	597d                	li	s2,-1
    80004eb4:	a82d                	j	80004eee <sys_exec+0xfa>
      argv[i] = 0;
    80004eb6:	0a8e                	slli	s5,s5,0x3
    80004eb8:	fc040793          	addi	a5,s0,-64
    80004ebc:	9abe                	add	s5,s5,a5
    80004ebe:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd78f0>
  int ret = exec(path, argv);
    80004ec2:	e4040593          	addi	a1,s0,-448
    80004ec6:	f4040513          	addi	a0,s0,-192
    80004eca:	fffff097          	auipc	ra,0xfffff
    80004ece:	178080e7          	jalr	376(ra) # 80004042 <exec>
    80004ed2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004ed4:	10048993          	addi	s3,s1,256
    80004ed8:	6088                	ld	a0,0(s1)
    80004eda:	c911                	beqz	a0,80004eee <sys_exec+0xfa>
    kfree(argv[i]);
    80004edc:	ffffb097          	auipc	ra,0xffffb
    80004ee0:	140080e7          	jalr	320(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004ee4:	04a1                	addi	s1,s1,8
    80004ee6:	ff3499e3          	bne	s1,s3,80004ed8 <sys_exec+0xe4>
    80004eea:	a011                	j	80004eee <sys_exec+0xfa>
  return -1;
    80004eec:	597d                	li	s2,-1
}
    80004eee:	854a                	mv	a0,s2
    80004ef0:	60be                	ld	ra,456(sp)
    80004ef2:	641e                	ld	s0,448(sp)
    80004ef4:	74fa                	ld	s1,440(sp)
    80004ef6:	795a                	ld	s2,432(sp)
    80004ef8:	79ba                	ld	s3,424(sp)
    80004efa:	7a1a                	ld	s4,416(sp)
    80004efc:	6afa                	ld	s5,408(sp)
    80004efe:	6179                	addi	sp,sp,464
    80004f00:	8082                	ret

0000000080004f02 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004f02:	7139                	addi	sp,sp,-64
    80004f04:	fc06                	sd	ra,56(sp)
    80004f06:	f822                	sd	s0,48(sp)
    80004f08:	f426                	sd	s1,40(sp)
    80004f0a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004f0c:	ffffc097          	auipc	ra,0xffffc
    80004f10:	fb4080e7          	jalr	-76(ra) # 80000ec0 <myproc>
    80004f14:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80004f16:	fd840593          	addi	a1,s0,-40
    80004f1a:	4501                	li	a0,0
    80004f1c:	ffffd097          	auipc	ra,0xffffd
    80004f20:	0b0080e7          	jalr	176(ra) # 80001fcc <argaddr>
    return -1;
    80004f24:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80004f26:	0e054063          	bltz	a0,80005006 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80004f2a:	fc840593          	addi	a1,s0,-56
    80004f2e:	fd040513          	addi	a0,s0,-48
    80004f32:	fffff097          	auipc	ra,0xfffff
    80004f36:	dee080e7          	jalr	-530(ra) # 80003d20 <pipealloc>
    return -1;
    80004f3a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004f3c:	0c054563          	bltz	a0,80005006 <sys_pipe+0x104>
  fd0 = -1;
    80004f40:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004f44:	fd043503          	ld	a0,-48(s0)
    80004f48:	fffff097          	auipc	ra,0xfffff
    80004f4c:	50a080e7          	jalr	1290(ra) # 80004452 <fdalloc>
    80004f50:	fca42223          	sw	a0,-60(s0)
    80004f54:	08054c63          	bltz	a0,80004fec <sys_pipe+0xea>
    80004f58:	fc843503          	ld	a0,-56(s0)
    80004f5c:	fffff097          	auipc	ra,0xfffff
    80004f60:	4f6080e7          	jalr	1270(ra) # 80004452 <fdalloc>
    80004f64:	fca42023          	sw	a0,-64(s0)
    80004f68:	06054863          	bltz	a0,80004fd8 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004f6c:	4691                	li	a3,4
    80004f6e:	fc440613          	addi	a2,s0,-60
    80004f72:	fd843583          	ld	a1,-40(s0)
    80004f76:	68a8                	ld	a0,80(s1)
    80004f78:	ffffc097          	auipc	ra,0xffffc
    80004f7c:	bdc080e7          	jalr	-1060(ra) # 80000b54 <copyout>
    80004f80:	02054063          	bltz	a0,80004fa0 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004f84:	4691                	li	a3,4
    80004f86:	fc040613          	addi	a2,s0,-64
    80004f8a:	fd843583          	ld	a1,-40(s0)
    80004f8e:	0591                	addi	a1,a1,4
    80004f90:	68a8                	ld	a0,80(s1)
    80004f92:	ffffc097          	auipc	ra,0xffffc
    80004f96:	bc2080e7          	jalr	-1086(ra) # 80000b54 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004f9a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004f9c:	06055563          	bgez	a0,80005006 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80004fa0:	fc442783          	lw	a5,-60(s0)
    80004fa4:	07e9                	addi	a5,a5,26
    80004fa6:	078e                	slli	a5,a5,0x3
    80004fa8:	97a6                	add	a5,a5,s1
    80004faa:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004fae:	fc042503          	lw	a0,-64(s0)
    80004fb2:	0569                	addi	a0,a0,26
    80004fb4:	050e                	slli	a0,a0,0x3
    80004fb6:	9526                	add	a0,a0,s1
    80004fb8:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80004fbc:	fd043503          	ld	a0,-48(s0)
    80004fc0:	fffff097          	auipc	ra,0xfffff
    80004fc4:	a00080e7          	jalr	-1536(ra) # 800039c0 <fileclose>
    fileclose(wf);
    80004fc8:	fc843503          	ld	a0,-56(s0)
    80004fcc:	fffff097          	auipc	ra,0xfffff
    80004fd0:	9f4080e7          	jalr	-1548(ra) # 800039c0 <fileclose>
    return -1;
    80004fd4:	57fd                	li	a5,-1
    80004fd6:	a805                	j	80005006 <sys_pipe+0x104>
    if(fd0 >= 0)
    80004fd8:	fc442783          	lw	a5,-60(s0)
    80004fdc:	0007c863          	bltz	a5,80004fec <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80004fe0:	01a78513          	addi	a0,a5,26
    80004fe4:	050e                	slli	a0,a0,0x3
    80004fe6:	9526                	add	a0,a0,s1
    80004fe8:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80004fec:	fd043503          	ld	a0,-48(s0)
    80004ff0:	fffff097          	auipc	ra,0xfffff
    80004ff4:	9d0080e7          	jalr	-1584(ra) # 800039c0 <fileclose>
    fileclose(wf);
    80004ff8:	fc843503          	ld	a0,-56(s0)
    80004ffc:	fffff097          	auipc	ra,0xfffff
    80005000:	9c4080e7          	jalr	-1596(ra) # 800039c0 <fileclose>
    return -1;
    80005004:	57fd                	li	a5,-1
}
    80005006:	853e                	mv	a0,a5
    80005008:	70e2                	ld	ra,56(sp)
    8000500a:	7442                	ld	s0,48(sp)
    8000500c:	74a2                	ld	s1,40(sp)
    8000500e:	6121                	addi	sp,sp,64
    80005010:	8082                	ret

0000000080005012 <sys_connect>:


#ifdef LAB_NET
int
sys_connect(void)
{
    80005012:	7179                	addi	sp,sp,-48
    80005014:	f406                	sd	ra,40(sp)
    80005016:	f022                	sd	s0,32(sp)
    80005018:	1800                	addi	s0,sp,48
  int fd;
  uint32 raddr;
  uint32 rport;
  uint32 lport;

  if (argint(0, (int*)&raddr) < 0 ||
    8000501a:	fe440593          	addi	a1,s0,-28
    8000501e:	4501                	li	a0,0
    80005020:	ffffd097          	auipc	ra,0xffffd
    80005024:	f8a080e7          	jalr	-118(ra) # 80001faa <argint>
    80005028:	06054663          	bltz	a0,80005094 <sys_connect+0x82>
      argint(1, (int*)&lport) < 0 ||
    8000502c:	fdc40593          	addi	a1,s0,-36
    80005030:	4505                	li	a0,1
    80005032:	ffffd097          	auipc	ra,0xffffd
    80005036:	f78080e7          	jalr	-136(ra) # 80001faa <argint>
  if (argint(0, (int*)&raddr) < 0 ||
    8000503a:	04054f63          	bltz	a0,80005098 <sys_connect+0x86>
      argint(2, (int*)&rport) < 0) {
    8000503e:	fe040593          	addi	a1,s0,-32
    80005042:	4509                	li	a0,2
    80005044:	ffffd097          	auipc	ra,0xffffd
    80005048:	f66080e7          	jalr	-154(ra) # 80001faa <argint>
      argint(1, (int*)&lport) < 0 ||
    8000504c:	04054863          	bltz	a0,8000509c <sys_connect+0x8a>
    return -1;
  }

  if(sockalloc(&f, raddr, lport, rport) < 0)
    80005050:	fe045683          	lhu	a3,-32(s0)
    80005054:	fdc45603          	lhu	a2,-36(s0)
    80005058:	fe442583          	lw	a1,-28(s0)
    8000505c:	fe840513          	addi	a0,s0,-24
    80005060:	00001097          	auipc	ra,0x1
    80005064:	258080e7          	jalr	600(ra) # 800062b8 <sockalloc>
    80005068:	02054c63          	bltz	a0,800050a0 <sys_connect+0x8e>
    return -1;
  if((fd=fdalloc(f)) < 0){
    8000506c:	fe843503          	ld	a0,-24(s0)
    80005070:	fffff097          	auipc	ra,0xfffff
    80005074:	3e2080e7          	jalr	994(ra) # 80004452 <fdalloc>
    80005078:	00054663          	bltz	a0,80005084 <sys_connect+0x72>
    fileclose(f);
    return -1;
  }

  return fd;
}
    8000507c:	70a2                	ld	ra,40(sp)
    8000507e:	7402                	ld	s0,32(sp)
    80005080:	6145                	addi	sp,sp,48
    80005082:	8082                	ret
    fileclose(f);
    80005084:	fe843503          	ld	a0,-24(s0)
    80005088:	fffff097          	auipc	ra,0xfffff
    8000508c:	938080e7          	jalr	-1736(ra) # 800039c0 <fileclose>
    return -1;
    80005090:	557d                	li	a0,-1
    80005092:	b7ed                	j	8000507c <sys_connect+0x6a>
    return -1;
    80005094:	557d                	li	a0,-1
    80005096:	b7dd                	j	8000507c <sys_connect+0x6a>
    80005098:	557d                	li	a0,-1
    8000509a:	b7cd                	j	8000507c <sys_connect+0x6a>
    8000509c:	557d                	li	a0,-1
    8000509e:	bff9                	j	8000507c <sys_connect+0x6a>
    return -1;
    800050a0:	557d                	li	a0,-1
    800050a2:	bfe9                	j	8000507c <sys_connect+0x6a>
	...

00000000800050b0 <kernelvec>:
    800050b0:	7111                	addi	sp,sp,-256
    800050b2:	e006                	sd	ra,0(sp)
    800050b4:	e40a                	sd	sp,8(sp)
    800050b6:	e80e                	sd	gp,16(sp)
    800050b8:	ec12                	sd	tp,24(sp)
    800050ba:	f016                	sd	t0,32(sp)
    800050bc:	f41a                	sd	t1,40(sp)
    800050be:	f81e                	sd	t2,48(sp)
    800050c0:	fc22                	sd	s0,56(sp)
    800050c2:	e0a6                	sd	s1,64(sp)
    800050c4:	e4aa                	sd	a0,72(sp)
    800050c6:	e8ae                	sd	a1,80(sp)
    800050c8:	ecb2                	sd	a2,88(sp)
    800050ca:	f0b6                	sd	a3,96(sp)
    800050cc:	f4ba                	sd	a4,104(sp)
    800050ce:	f8be                	sd	a5,112(sp)
    800050d0:	fcc2                	sd	a6,120(sp)
    800050d2:	e146                	sd	a7,128(sp)
    800050d4:	e54a                	sd	s2,136(sp)
    800050d6:	e94e                	sd	s3,144(sp)
    800050d8:	ed52                	sd	s4,152(sp)
    800050da:	f156                	sd	s5,160(sp)
    800050dc:	f55a                	sd	s6,168(sp)
    800050de:	f95e                	sd	s7,176(sp)
    800050e0:	fd62                	sd	s8,184(sp)
    800050e2:	e1e6                	sd	s9,192(sp)
    800050e4:	e5ea                	sd	s10,200(sp)
    800050e6:	e9ee                	sd	s11,208(sp)
    800050e8:	edf2                	sd	t3,216(sp)
    800050ea:	f1f6                	sd	t4,224(sp)
    800050ec:	f5fa                	sd	t5,232(sp)
    800050ee:	f9fe                	sd	t6,240(sp)
    800050f0:	cedfc0ef          	jal	ra,80001ddc <kerneltrap>
    800050f4:	6082                	ld	ra,0(sp)
    800050f6:	6122                	ld	sp,8(sp)
    800050f8:	61c2                	ld	gp,16(sp)
    800050fa:	7282                	ld	t0,32(sp)
    800050fc:	7322                	ld	t1,40(sp)
    800050fe:	73c2                	ld	t2,48(sp)
    80005100:	7462                	ld	s0,56(sp)
    80005102:	6486                	ld	s1,64(sp)
    80005104:	6526                	ld	a0,72(sp)
    80005106:	65c6                	ld	a1,80(sp)
    80005108:	6666                	ld	a2,88(sp)
    8000510a:	7686                	ld	a3,96(sp)
    8000510c:	7726                	ld	a4,104(sp)
    8000510e:	77c6                	ld	a5,112(sp)
    80005110:	7866                	ld	a6,120(sp)
    80005112:	688a                	ld	a7,128(sp)
    80005114:	692a                	ld	s2,136(sp)
    80005116:	69ca                	ld	s3,144(sp)
    80005118:	6a6a                	ld	s4,152(sp)
    8000511a:	7a8a                	ld	s5,160(sp)
    8000511c:	7b2a                	ld	s6,168(sp)
    8000511e:	7bca                	ld	s7,176(sp)
    80005120:	7c6a                	ld	s8,184(sp)
    80005122:	6c8e                	ld	s9,192(sp)
    80005124:	6d2e                	ld	s10,200(sp)
    80005126:	6dce                	ld	s11,208(sp)
    80005128:	6e6e                	ld	t3,216(sp)
    8000512a:	7e8e                	ld	t4,224(sp)
    8000512c:	7f2e                	ld	t5,232(sp)
    8000512e:	7fce                	ld	t6,240(sp)
    80005130:	6111                	addi	sp,sp,256
    80005132:	10200073          	sret
    80005136:	00000013          	nop
    8000513a:	00000013          	nop
    8000513e:	0001                	nop

0000000080005140 <timervec>:
    80005140:	34051573          	csrrw	a0,mscratch,a0
    80005144:	e10c                	sd	a1,0(a0)
    80005146:	e510                	sd	a2,8(a0)
    80005148:	e914                	sd	a3,16(a0)
    8000514a:	6d0c                	ld	a1,24(a0)
    8000514c:	7110                	ld	a2,32(a0)
    8000514e:	6194                	ld	a3,0(a1)
    80005150:	96b2                	add	a3,a3,a2
    80005152:	e194                	sd	a3,0(a1)
    80005154:	4589                	li	a1,2
    80005156:	14459073          	csrw	sip,a1
    8000515a:	6914                	ld	a3,16(a0)
    8000515c:	6510                	ld	a2,8(a0)
    8000515e:	610c                	ld	a1,0(a0)
    80005160:	34051573          	csrrw	a0,mscratch,a0
    80005164:	30200073          	mret
	...

000000008000516a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000516a:	1141                	addi	sp,sp,-16
    8000516c:	e422                	sd	s0,8(sp)
    8000516e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005170:	0c0007b7          	lui	a5,0xc000
    80005174:	4705                	li	a4,1
    80005176:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005178:	c3d8                	sw	a4,4(a5)
    8000517a:	0791                	addi	a5,a5,4
  
#ifdef LAB_NET
  // PCIE IRQs are 32 to 35
  for(int irq = 1; irq < 0x35; irq++){
    *(uint32*)(PLIC + irq*4) = 1;
    8000517c:	4685                	li	a3,1
  for(int irq = 1; irq < 0x35; irq++){
    8000517e:	0c000737          	lui	a4,0xc000
    80005182:	0d470713          	addi	a4,a4,212 # c0000d4 <_entry-0x73ffff2c>
    *(uint32*)(PLIC + irq*4) = 1;
    80005186:	c394                	sw	a3,0(a5)
  for(int irq = 1; irq < 0x35; irq++){
    80005188:	0791                	addi	a5,a5,4
    8000518a:	fee79ee3          	bne	a5,a4,80005186 <plicinit+0x1c>
  }
#endif  
}
    8000518e:	6422                	ld	s0,8(sp)
    80005190:	0141                	addi	sp,sp,16
    80005192:	8082                	ret

0000000080005194 <plicinithart>:

void
plicinithart(void)
{
    80005194:	1141                	addi	sp,sp,-16
    80005196:	e406                	sd	ra,8(sp)
    80005198:	e022                	sd	s0,0(sp)
    8000519a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000519c:	ffffc097          	auipc	ra,0xffffc
    800051a0:	cf8080e7          	jalr	-776(ra) # 80000e94 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800051a4:	0085171b          	slliw	a4,a0,0x8
    800051a8:	0c0027b7          	lui	a5,0xc002
    800051ac:	97ba                	add	a5,a5,a4
    800051ae:	40200713          	li	a4,1026
    800051b2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

#ifdef LAB_NET
  // hack to get at next 32 IRQs for e1000
  *(uint32*)(PLIC_SENABLE(hart)+4) = 0xffffffff;
    800051b6:	577d                	li	a4,-1
    800051b8:	08e7a223          	sw	a4,132(a5)
#endif
  
  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800051bc:	00d5151b          	slliw	a0,a0,0xd
    800051c0:	0c2017b7          	lui	a5,0xc201
    800051c4:	953e                	add	a0,a0,a5
    800051c6:	00052023          	sw	zero,0(a0)
}
    800051ca:	60a2                	ld	ra,8(sp)
    800051cc:	6402                	ld	s0,0(sp)
    800051ce:	0141                	addi	sp,sp,16
    800051d0:	8082                	ret

00000000800051d2 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800051d2:	1141                	addi	sp,sp,-16
    800051d4:	e406                	sd	ra,8(sp)
    800051d6:	e022                	sd	s0,0(sp)
    800051d8:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800051da:	ffffc097          	auipc	ra,0xffffc
    800051de:	cba080e7          	jalr	-838(ra) # 80000e94 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800051e2:	00d5179b          	slliw	a5,a0,0xd
    800051e6:	0c201537          	lui	a0,0xc201
    800051ea:	953e                	add	a0,a0,a5
  return irq;
}
    800051ec:	4148                	lw	a0,4(a0)
    800051ee:	60a2                	ld	ra,8(sp)
    800051f0:	6402                	ld	s0,0(sp)
    800051f2:	0141                	addi	sp,sp,16
    800051f4:	8082                	ret

00000000800051f6 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800051f6:	1101                	addi	sp,sp,-32
    800051f8:	ec06                	sd	ra,24(sp)
    800051fa:	e822                	sd	s0,16(sp)
    800051fc:	e426                	sd	s1,8(sp)
    800051fe:	1000                	addi	s0,sp,32
    80005200:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005202:	ffffc097          	auipc	ra,0xffffc
    80005206:	c92080e7          	jalr	-878(ra) # 80000e94 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000520a:	00d5151b          	slliw	a0,a0,0xd
    8000520e:	0c2017b7          	lui	a5,0xc201
    80005212:	97aa                	add	a5,a5,a0
    80005214:	c3c4                	sw	s1,4(a5)
}
    80005216:	60e2                	ld	ra,24(sp)
    80005218:	6442                	ld	s0,16(sp)
    8000521a:	64a2                	ld	s1,8(sp)
    8000521c:	6105                	addi	sp,sp,32
    8000521e:	8082                	ret

0000000080005220 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005220:	1141                	addi	sp,sp,-16
    80005222:	e406                	sd	ra,8(sp)
    80005224:	e022                	sd	s0,0(sp)
    80005226:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005228:	479d                	li	a5,7
    8000522a:	06a7c963          	blt	a5,a0,8000529c <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    8000522e:	00017797          	auipc	a5,0x17
    80005232:	dd278793          	addi	a5,a5,-558 # 8001c000 <disk>
    80005236:	00a78733          	add	a4,a5,a0
    8000523a:	6789                	lui	a5,0x2
    8000523c:	97ba                	add	a5,a5,a4
    8000523e:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005242:	e7ad                	bnez	a5,800052ac <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005244:	00451793          	slli	a5,a0,0x4
    80005248:	00019717          	auipc	a4,0x19
    8000524c:	db870713          	addi	a4,a4,-584 # 8001e000 <disk+0x2000>
    80005250:	6314                	ld	a3,0(a4)
    80005252:	96be                	add	a3,a3,a5
    80005254:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005258:	6314                	ld	a3,0(a4)
    8000525a:	96be                	add	a3,a3,a5
    8000525c:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005260:	6314                	ld	a3,0(a4)
    80005262:	96be                	add	a3,a3,a5
    80005264:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005268:	6318                	ld	a4,0(a4)
    8000526a:	97ba                	add	a5,a5,a4
    8000526c:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005270:	00017797          	auipc	a5,0x17
    80005274:	d9078793          	addi	a5,a5,-624 # 8001c000 <disk>
    80005278:	97aa                	add	a5,a5,a0
    8000527a:	6509                	lui	a0,0x2
    8000527c:	953e                	add	a0,a0,a5
    8000527e:	4785                	li	a5,1
    80005280:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005284:	00019517          	auipc	a0,0x19
    80005288:	d9450513          	addi	a0,a0,-620 # 8001e018 <disk+0x2018>
    8000528c:	ffffc097          	auipc	ra,0xffffc
    80005290:	5c8080e7          	jalr	1480(ra) # 80001854 <wakeup>
}
    80005294:	60a2                	ld	ra,8(sp)
    80005296:	6402                	ld	s0,0(sp)
    80005298:	0141                	addi	sp,sp,16
    8000529a:	8082                	ret
    panic("free_desc 1");
    8000529c:	00004517          	auipc	a0,0x4
    800052a0:	47450513          	addi	a0,a0,1140 # 80009710 <syscalls+0x360>
    800052a4:	00002097          	auipc	ra,0x2
    800052a8:	990080e7          	jalr	-1648(ra) # 80006c34 <panic>
    panic("free_desc 2");
    800052ac:	00004517          	auipc	a0,0x4
    800052b0:	47450513          	addi	a0,a0,1140 # 80009720 <syscalls+0x370>
    800052b4:	00002097          	auipc	ra,0x2
    800052b8:	980080e7          	jalr	-1664(ra) # 80006c34 <panic>

00000000800052bc <virtio_disk_init>:
{
    800052bc:	1101                	addi	sp,sp,-32
    800052be:	ec06                	sd	ra,24(sp)
    800052c0:	e822                	sd	s0,16(sp)
    800052c2:	e426                	sd	s1,8(sp)
    800052c4:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800052c6:	00004597          	auipc	a1,0x4
    800052ca:	46a58593          	addi	a1,a1,1130 # 80009730 <syscalls+0x380>
    800052ce:	00019517          	auipc	a0,0x19
    800052d2:	e5a50513          	addi	a0,a0,-422 # 8001e128 <disk+0x2128>
    800052d6:	00002097          	auipc	ra,0x2
    800052da:	e0a080e7          	jalr	-502(ra) # 800070e0 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800052de:	100017b7          	lui	a5,0x10001
    800052e2:	4398                	lw	a4,0(a5)
    800052e4:	2701                	sext.w	a4,a4
    800052e6:	747277b7          	lui	a5,0x74727
    800052ea:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800052ee:	0ef71163          	bne	a4,a5,800053d0 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800052f2:	100017b7          	lui	a5,0x10001
    800052f6:	43dc                	lw	a5,4(a5)
    800052f8:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800052fa:	4705                	li	a4,1
    800052fc:	0ce79a63          	bne	a5,a4,800053d0 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005300:	100017b7          	lui	a5,0x10001
    80005304:	479c                	lw	a5,8(a5)
    80005306:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005308:	4709                	li	a4,2
    8000530a:	0ce79363          	bne	a5,a4,800053d0 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000530e:	100017b7          	lui	a5,0x10001
    80005312:	47d8                	lw	a4,12(a5)
    80005314:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005316:	554d47b7          	lui	a5,0x554d4
    8000531a:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000531e:	0af71963          	bne	a4,a5,800053d0 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005322:	100017b7          	lui	a5,0x10001
    80005326:	4705                	li	a4,1
    80005328:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000532a:	470d                	li	a4,3
    8000532c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000532e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005330:	c7ffe737          	lui	a4,0xc7ffe
    80005334:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd71cf>
    80005338:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000533a:	2701                	sext.w	a4,a4
    8000533c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000533e:	472d                	li	a4,11
    80005340:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005342:	473d                	li	a4,15
    80005344:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005346:	6705                	lui	a4,0x1
    80005348:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000534a:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000534e:	5bdc                	lw	a5,52(a5)
    80005350:	2781                	sext.w	a5,a5
  if(max == 0)
    80005352:	c7d9                	beqz	a5,800053e0 <virtio_disk_init+0x124>
  if(max < NUM)
    80005354:	471d                	li	a4,7
    80005356:	08f77d63          	bgeu	a4,a5,800053f0 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000535a:	100014b7          	lui	s1,0x10001
    8000535e:	47a1                	li	a5,8
    80005360:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005362:	6609                	lui	a2,0x2
    80005364:	4581                	li	a1,0
    80005366:	00017517          	auipc	a0,0x17
    8000536a:	c9a50513          	addi	a0,a0,-870 # 8001c000 <disk>
    8000536e:	ffffb097          	auipc	ra,0xffffb
    80005372:	e0a080e7          	jalr	-502(ra) # 80000178 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005376:	00017717          	auipc	a4,0x17
    8000537a:	c8a70713          	addi	a4,a4,-886 # 8001c000 <disk>
    8000537e:	00c75793          	srli	a5,a4,0xc
    80005382:	2781                	sext.w	a5,a5
    80005384:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005386:	00019797          	auipc	a5,0x19
    8000538a:	c7a78793          	addi	a5,a5,-902 # 8001e000 <disk+0x2000>
    8000538e:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005390:	00017717          	auipc	a4,0x17
    80005394:	cf070713          	addi	a4,a4,-784 # 8001c080 <disk+0x80>
    80005398:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    8000539a:	00018717          	auipc	a4,0x18
    8000539e:	c6670713          	addi	a4,a4,-922 # 8001d000 <disk+0x1000>
    800053a2:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800053a4:	4705                	li	a4,1
    800053a6:	00e78c23          	sb	a4,24(a5)
    800053aa:	00e78ca3          	sb	a4,25(a5)
    800053ae:	00e78d23          	sb	a4,26(a5)
    800053b2:	00e78da3          	sb	a4,27(a5)
    800053b6:	00e78e23          	sb	a4,28(a5)
    800053ba:	00e78ea3          	sb	a4,29(a5)
    800053be:	00e78f23          	sb	a4,30(a5)
    800053c2:	00e78fa3          	sb	a4,31(a5)
}
    800053c6:	60e2                	ld	ra,24(sp)
    800053c8:	6442                	ld	s0,16(sp)
    800053ca:	64a2                	ld	s1,8(sp)
    800053cc:	6105                	addi	sp,sp,32
    800053ce:	8082                	ret
    panic("could not find virtio disk");
    800053d0:	00004517          	auipc	a0,0x4
    800053d4:	37050513          	addi	a0,a0,880 # 80009740 <syscalls+0x390>
    800053d8:	00002097          	auipc	ra,0x2
    800053dc:	85c080e7          	jalr	-1956(ra) # 80006c34 <panic>
    panic("virtio disk has no queue 0");
    800053e0:	00004517          	auipc	a0,0x4
    800053e4:	38050513          	addi	a0,a0,896 # 80009760 <syscalls+0x3b0>
    800053e8:	00002097          	auipc	ra,0x2
    800053ec:	84c080e7          	jalr	-1972(ra) # 80006c34 <panic>
    panic("virtio disk max queue too short");
    800053f0:	00004517          	auipc	a0,0x4
    800053f4:	39050513          	addi	a0,a0,912 # 80009780 <syscalls+0x3d0>
    800053f8:	00002097          	auipc	ra,0x2
    800053fc:	83c080e7          	jalr	-1988(ra) # 80006c34 <panic>

0000000080005400 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005400:	7119                	addi	sp,sp,-128
    80005402:	fc86                	sd	ra,120(sp)
    80005404:	f8a2                	sd	s0,112(sp)
    80005406:	f4a6                	sd	s1,104(sp)
    80005408:	f0ca                	sd	s2,96(sp)
    8000540a:	ecce                	sd	s3,88(sp)
    8000540c:	e8d2                	sd	s4,80(sp)
    8000540e:	e4d6                	sd	s5,72(sp)
    80005410:	e0da                	sd	s6,64(sp)
    80005412:	fc5e                	sd	s7,56(sp)
    80005414:	f862                	sd	s8,48(sp)
    80005416:	f466                	sd	s9,40(sp)
    80005418:	f06a                	sd	s10,32(sp)
    8000541a:	ec6e                	sd	s11,24(sp)
    8000541c:	0100                	addi	s0,sp,128
    8000541e:	8aaa                	mv	s5,a0
    80005420:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005422:	00c52c83          	lw	s9,12(a0)
    80005426:	001c9c9b          	slliw	s9,s9,0x1
    8000542a:	1c82                	slli	s9,s9,0x20
    8000542c:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005430:	00019517          	auipc	a0,0x19
    80005434:	cf850513          	addi	a0,a0,-776 # 8001e128 <disk+0x2128>
    80005438:	00002097          	auipc	ra,0x2
    8000543c:	d38080e7          	jalr	-712(ra) # 80007170 <acquire>
  for(int i = 0; i < 3; i++){
    80005440:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005442:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005444:	00017c17          	auipc	s8,0x17
    80005448:	bbcc0c13          	addi	s8,s8,-1092 # 8001c000 <disk>
    8000544c:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    8000544e:	4b0d                	li	s6,3
    80005450:	a0ad                	j	800054ba <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80005452:	00fc0733          	add	a4,s8,a5
    80005456:	975e                	add	a4,a4,s7
    80005458:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000545c:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000545e:	0207c563          	bltz	a5,80005488 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005462:	2905                	addiw	s2,s2,1
    80005464:	0611                	addi	a2,a2,4
    80005466:	19690d63          	beq	s2,s6,80005600 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    8000546a:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000546c:	00019717          	auipc	a4,0x19
    80005470:	bac70713          	addi	a4,a4,-1108 # 8001e018 <disk+0x2018>
    80005474:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005476:	00074683          	lbu	a3,0(a4)
    8000547a:	fee1                	bnez	a3,80005452 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    8000547c:	2785                	addiw	a5,a5,1
    8000547e:	0705                	addi	a4,a4,1
    80005480:	fe979be3          	bne	a5,s1,80005476 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005484:	57fd                	li	a5,-1
    80005486:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005488:	01205d63          	blez	s2,800054a2 <virtio_disk_rw+0xa2>
    8000548c:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    8000548e:	000a2503          	lw	a0,0(s4)
    80005492:	00000097          	auipc	ra,0x0
    80005496:	d8e080e7          	jalr	-626(ra) # 80005220 <free_desc>
      for(int j = 0; j < i; j++)
    8000549a:	2d85                	addiw	s11,s11,1
    8000549c:	0a11                	addi	s4,s4,4
    8000549e:	ffb918e3          	bne	s2,s11,8000548e <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800054a2:	00019597          	auipc	a1,0x19
    800054a6:	c8658593          	addi	a1,a1,-890 # 8001e128 <disk+0x2128>
    800054aa:	00019517          	auipc	a0,0x19
    800054ae:	b6e50513          	addi	a0,a0,-1170 # 8001e018 <disk+0x2018>
    800054b2:	ffffc097          	auipc	ra,0xffffc
    800054b6:	222080e7          	jalr	546(ra) # 800016d4 <sleep>
  for(int i = 0; i < 3; i++){
    800054ba:	f8040a13          	addi	s4,s0,-128
{
    800054be:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800054c0:	894e                	mv	s2,s3
    800054c2:	b765                	j	8000546a <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800054c4:	00019697          	auipc	a3,0x19
    800054c8:	b3c6b683          	ld	a3,-1220(a3) # 8001e000 <disk+0x2000>
    800054cc:	96ba                	add	a3,a3,a4
    800054ce:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800054d2:	00017817          	auipc	a6,0x17
    800054d6:	b2e80813          	addi	a6,a6,-1234 # 8001c000 <disk>
    800054da:	00019697          	auipc	a3,0x19
    800054de:	b2668693          	addi	a3,a3,-1242 # 8001e000 <disk+0x2000>
    800054e2:	6290                	ld	a2,0(a3)
    800054e4:	963a                	add	a2,a2,a4
    800054e6:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800054ea:	0015e593          	ori	a1,a1,1
    800054ee:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800054f2:	f8842603          	lw	a2,-120(s0)
    800054f6:	628c                	ld	a1,0(a3)
    800054f8:	972e                	add	a4,a4,a1
    800054fa:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800054fe:	20050593          	addi	a1,a0,512
    80005502:	0592                	slli	a1,a1,0x4
    80005504:	95c2                	add	a1,a1,a6
    80005506:	577d                	li	a4,-1
    80005508:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000550c:	00461713          	slli	a4,a2,0x4
    80005510:	6290                	ld	a2,0(a3)
    80005512:	963a                	add	a2,a2,a4
    80005514:	03078793          	addi	a5,a5,48
    80005518:	97c2                	add	a5,a5,a6
    8000551a:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    8000551c:	629c                	ld	a5,0(a3)
    8000551e:	97ba                	add	a5,a5,a4
    80005520:	4605                	li	a2,1
    80005522:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005524:	629c                	ld	a5,0(a3)
    80005526:	97ba                	add	a5,a5,a4
    80005528:	4809                	li	a6,2
    8000552a:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    8000552e:	629c                	ld	a5,0(a3)
    80005530:	973e                	add	a4,a4,a5
    80005532:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005536:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000553a:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000553e:	6698                	ld	a4,8(a3)
    80005540:	00275783          	lhu	a5,2(a4)
    80005544:	8b9d                	andi	a5,a5,7
    80005546:	0786                	slli	a5,a5,0x1
    80005548:	97ba                	add	a5,a5,a4
    8000554a:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    8000554e:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005552:	6698                	ld	a4,8(a3)
    80005554:	00275783          	lhu	a5,2(a4)
    80005558:	2785                	addiw	a5,a5,1
    8000555a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000555e:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005562:	100017b7          	lui	a5,0x10001
    80005566:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000556a:	004aa783          	lw	a5,4(s5)
    8000556e:	02c79163          	bne	a5,a2,80005590 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80005572:	00019917          	auipc	s2,0x19
    80005576:	bb690913          	addi	s2,s2,-1098 # 8001e128 <disk+0x2128>
  while(b->disk == 1) {
    8000557a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000557c:	85ca                	mv	a1,s2
    8000557e:	8556                	mv	a0,s5
    80005580:	ffffc097          	auipc	ra,0xffffc
    80005584:	154080e7          	jalr	340(ra) # 800016d4 <sleep>
  while(b->disk == 1) {
    80005588:	004aa783          	lw	a5,4(s5)
    8000558c:	fe9788e3          	beq	a5,s1,8000557c <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80005590:	f8042903          	lw	s2,-128(s0)
    80005594:	20090793          	addi	a5,s2,512
    80005598:	00479713          	slli	a4,a5,0x4
    8000559c:	00017797          	auipc	a5,0x17
    800055a0:	a6478793          	addi	a5,a5,-1436 # 8001c000 <disk>
    800055a4:	97ba                	add	a5,a5,a4
    800055a6:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800055aa:	00019997          	auipc	s3,0x19
    800055ae:	a5698993          	addi	s3,s3,-1450 # 8001e000 <disk+0x2000>
    800055b2:	00491713          	slli	a4,s2,0x4
    800055b6:	0009b783          	ld	a5,0(s3)
    800055ba:	97ba                	add	a5,a5,a4
    800055bc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800055c0:	854a                	mv	a0,s2
    800055c2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800055c6:	00000097          	auipc	ra,0x0
    800055ca:	c5a080e7          	jalr	-934(ra) # 80005220 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800055ce:	8885                	andi	s1,s1,1
    800055d0:	f0ed                	bnez	s1,800055b2 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800055d2:	00019517          	auipc	a0,0x19
    800055d6:	b5650513          	addi	a0,a0,-1194 # 8001e128 <disk+0x2128>
    800055da:	00002097          	auipc	ra,0x2
    800055de:	c4a080e7          	jalr	-950(ra) # 80007224 <release>
}
    800055e2:	70e6                	ld	ra,120(sp)
    800055e4:	7446                	ld	s0,112(sp)
    800055e6:	74a6                	ld	s1,104(sp)
    800055e8:	7906                	ld	s2,96(sp)
    800055ea:	69e6                	ld	s3,88(sp)
    800055ec:	6a46                	ld	s4,80(sp)
    800055ee:	6aa6                	ld	s5,72(sp)
    800055f0:	6b06                	ld	s6,64(sp)
    800055f2:	7be2                	ld	s7,56(sp)
    800055f4:	7c42                	ld	s8,48(sp)
    800055f6:	7ca2                	ld	s9,40(sp)
    800055f8:	7d02                	ld	s10,32(sp)
    800055fa:	6de2                	ld	s11,24(sp)
    800055fc:	6109                	addi	sp,sp,128
    800055fe:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005600:	f8042503          	lw	a0,-128(s0)
    80005604:	20050793          	addi	a5,a0,512
    80005608:	0792                	slli	a5,a5,0x4
  if(write)
    8000560a:	00017817          	auipc	a6,0x17
    8000560e:	9f680813          	addi	a6,a6,-1546 # 8001c000 <disk>
    80005612:	00f80733          	add	a4,a6,a5
    80005616:	01a036b3          	snez	a3,s10
    8000561a:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    8000561e:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80005622:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005626:	7679                	lui	a2,0xffffe
    80005628:	963e                	add	a2,a2,a5
    8000562a:	00019697          	auipc	a3,0x19
    8000562e:	9d668693          	addi	a3,a3,-1578 # 8001e000 <disk+0x2000>
    80005632:	6298                	ld	a4,0(a3)
    80005634:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005636:	0a878593          	addi	a1,a5,168
    8000563a:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000563c:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000563e:	6298                	ld	a4,0(a3)
    80005640:	9732                	add	a4,a4,a2
    80005642:	45c1                	li	a1,16
    80005644:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005646:	6298                	ld	a4,0(a3)
    80005648:	9732                	add	a4,a4,a2
    8000564a:	4585                	li	a1,1
    8000564c:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80005650:	f8442703          	lw	a4,-124(s0)
    80005654:	628c                	ld	a1,0(a3)
    80005656:	962e                	add	a2,a2,a1
    80005658:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd6a7e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    8000565c:	0712                	slli	a4,a4,0x4
    8000565e:	6290                	ld	a2,0(a3)
    80005660:	963a                	add	a2,a2,a4
    80005662:	058a8593          	addi	a1,s5,88
    80005666:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005668:	6294                	ld	a3,0(a3)
    8000566a:	96ba                	add	a3,a3,a4
    8000566c:	40000613          	li	a2,1024
    80005670:	c690                	sw	a2,8(a3)
  if(write)
    80005672:	e40d19e3          	bnez	s10,800054c4 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80005676:	00019697          	auipc	a3,0x19
    8000567a:	98a6b683          	ld	a3,-1654(a3) # 8001e000 <disk+0x2000>
    8000567e:	96ba                	add	a3,a3,a4
    80005680:	4609                	li	a2,2
    80005682:	00c69623          	sh	a2,12(a3)
    80005686:	b5b1                	j	800054d2 <virtio_disk_rw+0xd2>

0000000080005688 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005688:	1101                	addi	sp,sp,-32
    8000568a:	ec06                	sd	ra,24(sp)
    8000568c:	e822                	sd	s0,16(sp)
    8000568e:	e426                	sd	s1,8(sp)
    80005690:	e04a                	sd	s2,0(sp)
    80005692:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005694:	00019517          	auipc	a0,0x19
    80005698:	a9450513          	addi	a0,a0,-1388 # 8001e128 <disk+0x2128>
    8000569c:	00002097          	auipc	ra,0x2
    800056a0:	ad4080e7          	jalr	-1324(ra) # 80007170 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800056a4:	10001737          	lui	a4,0x10001
    800056a8:	533c                	lw	a5,96(a4)
    800056aa:	8b8d                	andi	a5,a5,3
    800056ac:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800056ae:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800056b2:	00019797          	auipc	a5,0x19
    800056b6:	94e78793          	addi	a5,a5,-1714 # 8001e000 <disk+0x2000>
    800056ba:	6b94                	ld	a3,16(a5)
    800056bc:	0207d703          	lhu	a4,32(a5)
    800056c0:	0026d783          	lhu	a5,2(a3)
    800056c4:	06f70163          	beq	a4,a5,80005726 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800056c8:	00017917          	auipc	s2,0x17
    800056cc:	93890913          	addi	s2,s2,-1736 # 8001c000 <disk>
    800056d0:	00019497          	auipc	s1,0x19
    800056d4:	93048493          	addi	s1,s1,-1744 # 8001e000 <disk+0x2000>
    __sync_synchronize();
    800056d8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800056dc:	6898                	ld	a4,16(s1)
    800056de:	0204d783          	lhu	a5,32(s1)
    800056e2:	8b9d                	andi	a5,a5,7
    800056e4:	078e                	slli	a5,a5,0x3
    800056e6:	97ba                	add	a5,a5,a4
    800056e8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800056ea:	20078713          	addi	a4,a5,512
    800056ee:	0712                	slli	a4,a4,0x4
    800056f0:	974a                	add	a4,a4,s2
    800056f2:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800056f6:	e731                	bnez	a4,80005742 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800056f8:	20078793          	addi	a5,a5,512
    800056fc:	0792                	slli	a5,a5,0x4
    800056fe:	97ca                	add	a5,a5,s2
    80005700:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80005702:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005706:	ffffc097          	auipc	ra,0xffffc
    8000570a:	14e080e7          	jalr	334(ra) # 80001854 <wakeup>

    disk.used_idx += 1;
    8000570e:	0204d783          	lhu	a5,32(s1)
    80005712:	2785                	addiw	a5,a5,1
    80005714:	17c2                	slli	a5,a5,0x30
    80005716:	93c1                	srli	a5,a5,0x30
    80005718:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000571c:	6898                	ld	a4,16(s1)
    8000571e:	00275703          	lhu	a4,2(a4)
    80005722:	faf71be3          	bne	a4,a5,800056d8 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80005726:	00019517          	auipc	a0,0x19
    8000572a:	a0250513          	addi	a0,a0,-1534 # 8001e128 <disk+0x2128>
    8000572e:	00002097          	auipc	ra,0x2
    80005732:	af6080e7          	jalr	-1290(ra) # 80007224 <release>
}
    80005736:	60e2                	ld	ra,24(sp)
    80005738:	6442                	ld	s0,16(sp)
    8000573a:	64a2                	ld	s1,8(sp)
    8000573c:	6902                	ld	s2,0(sp)
    8000573e:	6105                	addi	sp,sp,32
    80005740:	8082                	ret
      panic("virtio_disk_intr status");
    80005742:	00004517          	auipc	a0,0x4
    80005746:	05e50513          	addi	a0,a0,94 # 800097a0 <syscalls+0x3f0>
    8000574a:	00001097          	auipc	ra,0x1
    8000574e:	4ea080e7          	jalr	1258(ra) # 80006c34 <panic>

0000000080005752 <e1000_init>:
// called by pci_init().
// xregs is the memory address at which the
// e1000's registers are mapped.
void
e1000_init(uint32 *xregs)
{
    80005752:	7179                	addi	sp,sp,-48
    80005754:	f406                	sd	ra,40(sp)
    80005756:	f022                	sd	s0,32(sp)
    80005758:	ec26                	sd	s1,24(sp)
    8000575a:	e84a                	sd	s2,16(sp)
    8000575c:	e44e                	sd	s3,8(sp)
    8000575e:	1800                	addi	s0,sp,48
    80005760:	84aa                	mv	s1,a0
  int i;

  initlock(&e1000_lock, "e1000");
    80005762:	00004597          	auipc	a1,0x4
    80005766:	05658593          	addi	a1,a1,86 # 800097b8 <syscalls+0x408>
    8000576a:	0001a517          	auipc	a0,0x1a
    8000576e:	89650513          	addi	a0,a0,-1898 # 8001f000 <e1000_lock>
    80005772:	00002097          	auipc	ra,0x2
    80005776:	96e080e7          	jalr	-1682(ra) # 800070e0 <initlock>
  initlock(&e1000_lockrx, "e1000_rx");
    8000577a:	00004597          	auipc	a1,0x4
    8000577e:	04658593          	addi	a1,a1,70 # 800097c0 <syscalls+0x410>
    80005782:	0001a517          	auipc	a0,0x1a
    80005786:	89650513          	addi	a0,a0,-1898 # 8001f018 <e1000_lockrx>
    8000578a:	00002097          	auipc	ra,0x2
    8000578e:	956080e7          	jalr	-1706(ra) # 800070e0 <initlock>

  regs = xregs;
    80005792:	00005797          	auipc	a5,0x5
    80005796:	8897b723          	sd	s1,-1906(a5) # 8000a020 <regs>

  // Reset the device
  regs[E1000_IMS] = 0; // disable interrupts
    8000579a:	0c04a823          	sw	zero,208(s1)
  regs[E1000_CTL] |= E1000_CTL_RST;
    8000579e:	409c                	lw	a5,0(s1)
    800057a0:	00400737          	lui	a4,0x400
    800057a4:	8fd9                	or	a5,a5,a4
    800057a6:	2781                	sext.w	a5,a5
    800057a8:	c09c                	sw	a5,0(s1)
  regs[E1000_IMS] = 0; // redisable interrupts
    800057aa:	0c04a823          	sw	zero,208(s1)
  __sync_synchronize();
    800057ae:	0ff0000f          	fence

  // [E1000 14.5] Transmit initialization
  memset(tx_ring, 0, sizeof(tx_ring));
    800057b2:	10000613          	li	a2,256
    800057b6:	4581                	li	a1,0
    800057b8:	0001a517          	auipc	a0,0x1a
    800057bc:	87850513          	addi	a0,a0,-1928 # 8001f030 <tx_ring>
    800057c0:	ffffb097          	auipc	ra,0xffffb
    800057c4:	9b8080e7          	jalr	-1608(ra) # 80000178 <memset>
  for (i = 0; i < TX_RING_SIZE; i++) {
    800057c8:	0001a717          	auipc	a4,0x1a
    800057cc:	87470713          	addi	a4,a4,-1932 # 8001f03c <tx_ring+0xc>
    800057d0:	0001a797          	auipc	a5,0x1a
    800057d4:	96078793          	addi	a5,a5,-1696 # 8001f130 <tx_mbufs>
    800057d8:	0001a617          	auipc	a2,0x1a
    800057dc:	9d860613          	addi	a2,a2,-1576 # 8001f1b0 <rx_ring>
    tx_ring[i].status = E1000_TXD_STAT_DD;
    800057e0:	4685                	li	a3,1
    800057e2:	00d70023          	sb	a3,0(a4)
    tx_mbufs[i] = 0;
    800057e6:	0007b023          	sd	zero,0(a5)
  for (i = 0; i < TX_RING_SIZE; i++) {
    800057ea:	0741                	addi	a4,a4,16
    800057ec:	07a1                	addi	a5,a5,8
    800057ee:	fec79ae3          	bne	a5,a2,800057e2 <e1000_init+0x90>
  }
  regs[E1000_TDBAL] = (uint64) tx_ring;
    800057f2:	0001a717          	auipc	a4,0x1a
    800057f6:	83e70713          	addi	a4,a4,-1986 # 8001f030 <tx_ring>
    800057fa:	00005797          	auipc	a5,0x5
    800057fe:	8267b783          	ld	a5,-2010(a5) # 8000a020 <regs>
    80005802:	6691                	lui	a3,0x4
    80005804:	97b6                	add	a5,a5,a3
    80005806:	80e7a023          	sw	a4,-2048(a5)
  if(sizeof(tx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_TDLEN] = sizeof(tx_ring);
    8000580a:	10000713          	li	a4,256
    8000580e:	80e7a423          	sw	a4,-2040(a5)
  regs[E1000_TDH] = regs[E1000_TDT] = 0;
    80005812:	8007ac23          	sw	zero,-2024(a5)
    80005816:	8007a823          	sw	zero,-2032(a5)
  
  // [E1000 14.4] Receive initialization
  memset(rx_ring, 0, sizeof(rx_ring));
    8000581a:	0001a917          	auipc	s2,0x1a
    8000581e:	99690913          	addi	s2,s2,-1642 # 8001f1b0 <rx_ring>
    80005822:	10000613          	li	a2,256
    80005826:	4581                	li	a1,0
    80005828:	854a                	mv	a0,s2
    8000582a:	ffffb097          	auipc	ra,0xffffb
    8000582e:	94e080e7          	jalr	-1714(ra) # 80000178 <memset>
  for (i = 0; i < RX_RING_SIZE; i++) {
    80005832:	0001a497          	auipc	s1,0x1a
    80005836:	a7e48493          	addi	s1,s1,-1410 # 8001f2b0 <rx_mbufs>
    8000583a:	0001a997          	auipc	s3,0x1a
    8000583e:	af698993          	addi	s3,s3,-1290 # 8001f330 <lock>
    rx_mbufs[i] = mbufalloc(0);
    80005842:	4501                	li	a0,0
    80005844:	00000097          	auipc	ra,0x0
    80005848:	46e080e7          	jalr	1134(ra) # 80005cb2 <mbufalloc>
    8000584c:	e088                	sd	a0,0(s1)
    if (!rx_mbufs[i])
    8000584e:	c945                	beqz	a0,800058fe <e1000_init+0x1ac>
      panic("e1000");
    rx_ring[i].addr = (uint64) rx_mbufs[i]->head;
    80005850:	651c                	ld	a5,8(a0)
    80005852:	00f93023          	sd	a5,0(s2)
  for (i = 0; i < RX_RING_SIZE; i++) {
    80005856:	04a1                	addi	s1,s1,8
    80005858:	0941                	addi	s2,s2,16
    8000585a:	ff3494e3          	bne	s1,s3,80005842 <e1000_init+0xf0>
  }
  regs[E1000_RDBAL] = (uint64) rx_ring;
    8000585e:	00004697          	auipc	a3,0x4
    80005862:	7c26b683          	ld	a3,1986(a3) # 8000a020 <regs>
    80005866:	0001a717          	auipc	a4,0x1a
    8000586a:	94a70713          	addi	a4,a4,-1718 # 8001f1b0 <rx_ring>
    8000586e:	678d                	lui	a5,0x3
    80005870:	97b6                	add	a5,a5,a3
    80005872:	80e7a023          	sw	a4,-2048(a5) # 2800 <_entry-0x7fffd800>
  if(sizeof(rx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_RDH] = 0;
    80005876:	8007a823          	sw	zero,-2032(a5)
  regs[E1000_RDT] = RX_RING_SIZE - 1;
    8000587a:	473d                	li	a4,15
    8000587c:	80e7ac23          	sw	a4,-2024(a5)
  regs[E1000_RDLEN] = sizeof(rx_ring);
    80005880:	10000713          	li	a4,256
    80005884:	80e7a423          	sw	a4,-2040(a5)

  // filter by qemu's MAC address, 52:54:00:12:34:56
  regs[E1000_RA] = 0x12005452;
    80005888:	6715                	lui	a4,0x5
    8000588a:	00e68633          	add	a2,a3,a4
    8000588e:	120057b7          	lui	a5,0x12005
    80005892:	45278793          	addi	a5,a5,1106 # 12005452 <_entry-0x6dffabae>
    80005896:	40f62023          	sw	a5,1024(a2)
  regs[E1000_RA+1] = 0x5634 | (1<<31);
    8000589a:	800057b7          	lui	a5,0x80005
    8000589e:	63478793          	addi	a5,a5,1588 # ffffffff80005634 <end+0xfffffffefffde0a4>
    800058a2:	40f62223          	sw	a5,1028(a2)
  // multicast table
  for (int i = 0; i < 4096/32; i++)
    800058a6:	20070793          	addi	a5,a4,512 # 5200 <_entry-0x7fffae00>
    800058aa:	97b6                	add	a5,a5,a3
    800058ac:	40070713          	addi	a4,a4,1024
    800058b0:	9736                	add	a4,a4,a3
    regs[E1000_MTA + i] = 0;
    800058b2:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < 4096/32; i++)
    800058b6:	0791                	addi	a5,a5,4
    800058b8:	fee79de3          	bne	a5,a4,800058b2 <e1000_init+0x160>

  // transmitter control bits.
  regs[E1000_TCTL] = E1000_TCTL_EN |  // enable
    800058bc:	000407b7          	lui	a5,0x40
    800058c0:	10a78793          	addi	a5,a5,266 # 4010a <_entry-0x7ffbfef6>
    800058c4:	40f6a023          	sw	a5,1024(a3)
    E1000_TCTL_PSP |                  // pad short packets
    (0x10 << E1000_TCTL_CT_SHIFT) |   // collision stuff
    (0x40 << E1000_TCTL_COLD_SHIFT);
  regs[E1000_TIPG] = 10 | (8<<10) | (6<<20); // inter-pkt gap
    800058c8:	006027b7          	lui	a5,0x602
    800058cc:	07a9                	addi	a5,a5,10
    800058ce:	40f6a823          	sw	a5,1040(a3)

  // receiver control bits.
  regs[E1000_RCTL] = E1000_RCTL_EN | // enable receiver
    800058d2:	040087b7          	lui	a5,0x4008
    800058d6:	0789                	addi	a5,a5,2
    800058d8:	10f6a023          	sw	a5,256(a3)
    E1000_RCTL_BAM |                 // enable broadcast
    E1000_RCTL_SZ_2048 |             // 2048-byte rx buffers
    E1000_RCTL_SECRC;                // strip CRC
  
  // ask e1000 for receive interrupts.
  regs[E1000_RDTR] = 0; // interrupt after every received packet (no timer)
    800058dc:	678d                	lui	a5,0x3
    800058de:	97b6                	add	a5,a5,a3
    800058e0:	8207a023          	sw	zero,-2016(a5) # 2820 <_entry-0x7fffd7e0>
  regs[E1000_RADV] = 0; // interrupt after every packet (no timer)
    800058e4:	8207a623          	sw	zero,-2004(a5)
  regs[E1000_IMS] = (1 << 7); // RXDW -- Receiver Descriptor Write Back
    800058e8:	08000793          	li	a5,128
    800058ec:	0cf6a823          	sw	a5,208(a3)
}
    800058f0:	70a2                	ld	ra,40(sp)
    800058f2:	7402                	ld	s0,32(sp)
    800058f4:	64e2                	ld	s1,24(sp)
    800058f6:	6942                	ld	s2,16(sp)
    800058f8:	69a2                	ld	s3,8(sp)
    800058fa:	6145                	addi	sp,sp,48
    800058fc:	8082                	ret
      panic("e1000");
    800058fe:	00004517          	auipc	a0,0x4
    80005902:	eba50513          	addi	a0,a0,-326 # 800097b8 <syscalls+0x408>
    80005906:	00001097          	auipc	ra,0x1
    8000590a:	32e080e7          	jalr	814(ra) # 80006c34 <panic>

000000008000590e <e1000_transmit>:

int
e1000_transmit(struct mbuf *m)
{
    8000590e:	7179                	addi	sp,sp,-48
    80005910:	f406                	sd	ra,40(sp)
    80005912:	f022                	sd	s0,32(sp)
    80005914:	ec26                	sd	s1,24(sp)
    80005916:	e84a                	sd	s2,16(sp)
    80005918:	e44e                	sd	s3,8(sp)
    8000591a:	e052                	sd	s4,0(sp)
    8000591c:	1800                	addi	s0,sp,48
    8000591e:	89aa                	mv	s3,a0
  // the mbuf contains an ethernet frame; program it into
  // the TX descriptor ring so that the e1000 sends it. Stash
  // a pointer so that it can be freed after sending.
  //
  acquire(&e1000_lock);
    80005920:	00019917          	auipc	s2,0x19
    80005924:	6e090913          	addi	s2,s2,1760 # 8001f000 <e1000_lock>
    80005928:	854a                	mv	a0,s2
    8000592a:	00002097          	auipc	ra,0x2
    8000592e:	846080e7          	jalr	-1978(ra) # 80007170 <acquire>

  int tail = regs[E1000_TDT];
    80005932:	00004797          	auipc	a5,0x4
    80005936:	6ee7b783          	ld	a5,1774(a5) # 8000a020 <regs>
    8000593a:	6711                	lui	a4,0x4
    8000593c:	97ba                	add	a5,a5,a4
    8000593e:	8187a483          	lw	s1,-2024(a5)
    80005942:	2481                	sext.w	s1,s1
  if(!(tx_ring[tail].status & E1000_TXD_STAT_DD)){
    80005944:	00449793          	slli	a5,s1,0x4
    80005948:	993e                	add	s2,s2,a5
    8000594a:	03c94783          	lbu	a5,60(s2)
    8000594e:	8b85                	andi	a5,a5,1
    80005950:	cfd9                	beqz	a5,800059ee <e1000_transmit+0xe0>
    release(&e1000_lock);
    return -1;
  }
  
  if(tx_mbufs[tail])
    80005952:	00349713          	slli	a4,s1,0x3
    80005956:	00019797          	auipc	a5,0x19
    8000595a:	6aa78793          	addi	a5,a5,1706 # 8001f000 <e1000_lock>
    8000595e:	97ba                	add	a5,a5,a4
    80005960:	1307b503          	ld	a0,304(a5)
    80005964:	c509                	beqz	a0,8000596e <e1000_transmit+0x60>
    mbuffree(tx_mbufs[tail]);
    80005966:	00000097          	auipc	ra,0x0
    8000596a:	3a4080e7          	jalr	932(ra) # 80005d0a <mbuffree>
  
  memset(&tx_ring[tail], 0, sizeof(struct tx_desc));
    8000596e:	00019a17          	auipc	s4,0x19
    80005972:	692a0a13          	addi	s4,s4,1682 # 8001f000 <e1000_lock>
    80005976:	00449913          	slli	s2,s1,0x4
    8000597a:	4641                	li	a2,16
    8000597c:	4581                	li	a1,0
    8000597e:	00019517          	auipc	a0,0x19
    80005982:	6b250513          	addi	a0,a0,1714 # 8001f030 <tx_ring>
    80005986:	954a                	add	a0,a0,s2
    80005988:	ffffa097          	auipc	ra,0xffffa
    8000598c:	7f0080e7          	jalr	2032(ra) # 80000178 <memset>
  tx_ring[tail].cmd = (E1000_TXD_CMD_EOP | E1000_TXD_CMD_RS);
    80005990:	012a07b3          	add	a5,s4,s2
    80005994:	4725                	li	a4,9
    80005996:	02e78da3          	sb	a4,59(a5)
  tx_ring[tail].addr = (uint64)m->head;
    8000599a:	0089b703          	ld	a4,8(s3)
    8000599e:	fb98                	sd	a4,48(a5)
  tx_ring[tail].length = m->len;
    800059a0:	0109a703          	lw	a4,16(s3)
    800059a4:	02e79c23          	sh	a4,56(a5)
  tx_mbufs[tail] = m;
    800059a8:	00349793          	slli	a5,s1,0x3
    800059ac:	97d2                	add	a5,a5,s4
    800059ae:	1337b823          	sd	s3,304(a5)

  regs[E1000_TDT] = (tail + 1) % TX_RING_SIZE;
    800059b2:	2485                	addiw	s1,s1,1
    800059b4:	41f4d79b          	sraiw	a5,s1,0x1f
    800059b8:	01c7d79b          	srliw	a5,a5,0x1c
    800059bc:	9cbd                	addw	s1,s1,a5
    800059be:	88bd                	andi	s1,s1,15
    800059c0:	9c9d                	subw	s1,s1,a5
    800059c2:	00004797          	auipc	a5,0x4
    800059c6:	65e7b783          	ld	a5,1630(a5) # 8000a020 <regs>
    800059ca:	6711                	lui	a4,0x4
    800059cc:	97ba                	add	a5,a5,a4
    800059ce:	8097ac23          	sw	s1,-2024(a5)
  
  release(&e1000_lock);
    800059d2:	8552                	mv	a0,s4
    800059d4:	00002097          	auipc	ra,0x2
    800059d8:	850080e7          	jalr	-1968(ra) # 80007224 <release>
 
  return 0;
    800059dc:	4501                	li	a0,0
}
    800059de:	70a2                	ld	ra,40(sp)
    800059e0:	7402                	ld	s0,32(sp)
    800059e2:	64e2                	ld	s1,24(sp)
    800059e4:	6942                	ld	s2,16(sp)
    800059e6:	69a2                	ld	s3,8(sp)
    800059e8:	6a02                	ld	s4,0(sp)
    800059ea:	6145                	addi	sp,sp,48
    800059ec:	8082                	ret
    release(&e1000_lock);
    800059ee:	00019517          	auipc	a0,0x19
    800059f2:	61250513          	addi	a0,a0,1554 # 8001f000 <e1000_lock>
    800059f6:	00002097          	auipc	ra,0x2
    800059fa:	82e080e7          	jalr	-2002(ra) # 80007224 <release>
    return -1;
    800059fe:	557d                	li	a0,-1
    80005a00:	bff9                	j	800059de <e1000_transmit+0xd0>

0000000080005a02 <e1000_intr>:
  release(&e1000_lockrx);
}

void
e1000_intr(void)
{
    80005a02:	7139                	addi	sp,sp,-64
    80005a04:	fc06                	sd	ra,56(sp)
    80005a06:	f822                	sd	s0,48(sp)
    80005a08:	f426                	sd	s1,40(sp)
    80005a0a:	f04a                	sd	s2,32(sp)
    80005a0c:	ec4e                	sd	s3,24(sp)
    80005a0e:	e852                	sd	s4,16(sp)
    80005a10:	e456                	sd	s5,8(sp)
    80005a12:	e05a                	sd	s6,0(sp)
    80005a14:	0080                	addi	s0,sp,64
  // tell the e1000 we've seen this interrupt;
  // without this the e1000 won't raise any
  // further interrupts.
  regs[E1000_ICR] = 0xffffffff;
    80005a16:	00004497          	auipc	s1,0x4
    80005a1a:	60a48493          	addi	s1,s1,1546 # 8000a020 <regs>
    80005a1e:	609c                	ld	a5,0(s1)
    80005a20:	577d                	li	a4,-1
    80005a22:	0ce7a023          	sw	a4,192(a5)
  acquire(&e1000_lockrx);
    80005a26:	00019517          	auipc	a0,0x19
    80005a2a:	5f250513          	addi	a0,a0,1522 # 8001f018 <e1000_lockrx>
    80005a2e:	00001097          	auipc	ra,0x1
    80005a32:	742080e7          	jalr	1858(ra) # 80007170 <acquire>
  int i = (regs[E1000_RDT] + 1) % RX_RING_SIZE;
    80005a36:	609c                	ld	a5,0(s1)
    80005a38:	670d                	lui	a4,0x3
    80005a3a:	97ba                	add	a5,a5,a4
    80005a3c:	8187a483          	lw	s1,-2024(a5)
    80005a40:	2485                	addiw	s1,s1,1
    80005a42:	88bd                	andi	s1,s1,15
  while(rx_ring[i].status & E1000_RXD_STAT_DD){
    80005a44:	00449713          	slli	a4,s1,0x4
    80005a48:	00019797          	auipc	a5,0x19
    80005a4c:	5b878793          	addi	a5,a5,1464 # 8001f000 <e1000_lock>
    80005a50:	97ba                	add	a5,a5,a4
    80005a52:	1bc7c783          	lbu	a5,444(a5)
    80005a56:	8b85                	andi	a5,a5,1
    80005a58:	c3c1                	beqz	a5,80005ad8 <e1000_intr+0xd6>
    rx_mbufs[i]->len = rx_ring[i].length;
    80005a5a:	00019997          	auipc	s3,0x19
    80005a5e:	5a698993          	addi	s3,s3,1446 # 8001f000 <e1000_lock>
    regs[E1000_RDT] = i;
    80005a62:	00004a97          	auipc	s5,0x4
    80005a66:	5bea8a93          	addi	s5,s5,1470 # 8000a020 <regs>
    80005a6a:	6a0d                	lui	s4,0x3
    rx_mbufs[i]->len = rx_ring[i].length;
    80005a6c:	00349913          	slli	s2,s1,0x3
    80005a70:	994e                	add	s2,s2,s3
    80005a72:	2b093703          	ld	a4,688(s2)
    80005a76:	00449793          	slli	a5,s1,0x4
    80005a7a:	97ce                	add	a5,a5,s3
    80005a7c:	1b87d783          	lhu	a5,440(a5)
    80005a80:	cb1c                	sw	a5,16(a4)
    struct mbuf *rb = rx_mbufs[i];
    80005a82:	2b093b03          	ld	s6,688(s2)
    rx_mbufs[i] = mbufalloc(0);
    80005a86:	4501                	li	a0,0
    80005a88:	00000097          	auipc	ra,0x0
    80005a8c:	22a080e7          	jalr	554(ra) # 80005cb2 <mbufalloc>
    80005a90:	2aa93823          	sd	a0,688(s2)
    if (!rx_mbufs[i])
    80005a94:	c525                	beqz	a0,80005afc <e1000_intr+0xfa>
    rx_ring[i].addr = (uint64) rx_mbufs[i]->head;
    80005a96:	00449793          	slli	a5,s1,0x4
    80005a9a:	97ce                	add	a5,a5,s3
    80005a9c:	6518                	ld	a4,8(a0)
    80005a9e:	1ae7b823          	sd	a4,432(a5)
    rx_ring[i].status = 0;
    80005aa2:	1a078e23          	sb	zero,444(a5)
    regs[E1000_RDT] = i;
    80005aa6:	000ab783          	ld	a5,0(s5)
    80005aaa:	2481                	sext.w	s1,s1
    80005aac:	97d2                	add	a5,a5,s4
    80005aae:	8097ac23          	sw	s1,-2024(a5)
    net_rx(rb);
    80005ab2:	855a                	mv	a0,s6
    80005ab4:	00000097          	auipc	ra,0x0
    80005ab8:	3d2080e7          	jalr	978(ra) # 80005e86 <net_rx>
    i = (regs[E1000_RDT] + 1) % RX_RING_SIZE;
    80005abc:	000ab783          	ld	a5,0(s5)
    80005ac0:	97d2                	add	a5,a5,s4
    80005ac2:	8187a483          	lw	s1,-2024(a5)
    80005ac6:	2485                	addiw	s1,s1,1
    80005ac8:	88bd                	andi	s1,s1,15
  while(rx_ring[i].status & E1000_RXD_STAT_DD){
    80005aca:	00449793          	slli	a5,s1,0x4
    80005ace:	97ce                	add	a5,a5,s3
    80005ad0:	1bc7c783          	lbu	a5,444(a5)
    80005ad4:	8b85                	andi	a5,a5,1
    80005ad6:	fbd9                	bnez	a5,80005a6c <e1000_intr+0x6a>
  release(&e1000_lockrx);
    80005ad8:	00019517          	auipc	a0,0x19
    80005adc:	54050513          	addi	a0,a0,1344 # 8001f018 <e1000_lockrx>
    80005ae0:	00001097          	auipc	ra,0x1
    80005ae4:	744080e7          	jalr	1860(ra) # 80007224 <release>

  e1000_recv();
}
    80005ae8:	70e2                	ld	ra,56(sp)
    80005aea:	7442                	ld	s0,48(sp)
    80005aec:	74a2                	ld	s1,40(sp)
    80005aee:	7902                	ld	s2,32(sp)
    80005af0:	69e2                	ld	s3,24(sp)
    80005af2:	6a42                	ld	s4,16(sp)
    80005af4:	6aa2                	ld	s5,8(sp)
    80005af6:	6b02                	ld	s6,0(sp)
    80005af8:	6121                	addi	sp,sp,64
    80005afa:	8082                	ret
      panic("e1000");
    80005afc:	00004517          	auipc	a0,0x4
    80005b00:	cbc50513          	addi	a0,a0,-836 # 800097b8 <syscalls+0x408>
    80005b04:	00001097          	auipc	ra,0x1
    80005b08:	130080e7          	jalr	304(ra) # 80006c34 <panic>

0000000080005b0c <in_cksum>:

// This code is lifted from FreeBSD's ping.c, and is copyright by the Regents
// of the University of California.
static unsigned short
in_cksum(const unsigned char *addr, int len)
{
    80005b0c:	1101                	addi	sp,sp,-32
    80005b0e:	ec22                	sd	s0,24(sp)
    80005b10:	1000                	addi	s0,sp,32
  int nleft = len;
  const unsigned short *w = (const unsigned short *)addr;
  unsigned int sum = 0;
  unsigned short answer = 0;
    80005b12:	fe041723          	sh	zero,-18(s0)
  /*
   * Our algorithm is simple, using a 32 bit accumulator (sum), we add
   * sequential 16 bit words to it, and at the end, fold back all the
   * carry bits from the top 16 bits into the lower 16 bits.
   */
  while (nleft > 1)  {
    80005b16:	4785                	li	a5,1
    80005b18:	04b7da63          	bge	a5,a1,80005b6c <in_cksum+0x60>
    80005b1c:	ffe5861b          	addiw	a2,a1,-2
    80005b20:	0016561b          	srliw	a2,a2,0x1
    80005b24:	0016069b          	addiw	a3,a2,1
    80005b28:	1682                	slli	a3,a3,0x20
    80005b2a:	9281                	srli	a3,a3,0x20
    80005b2c:	0686                	slli	a3,a3,0x1
    80005b2e:	96aa                	add	a3,a3,a0
  unsigned int sum = 0;
    80005b30:	4781                	li	a5,0
    sum += *w++;
    80005b32:	0509                	addi	a0,a0,2
    80005b34:	ffe55703          	lhu	a4,-2(a0)
    80005b38:	9fb9                	addw	a5,a5,a4
  while (nleft > 1)  {
    80005b3a:	fed51ce3          	bne	a0,a3,80005b32 <in_cksum+0x26>
    nleft -= 2;
    80005b3e:	35f9                	addiw	a1,a1,-2
    80005b40:	0016161b          	slliw	a2,a2,0x1
    80005b44:	9d91                	subw	a1,a1,a2
  }

  /* mop up an odd byte, if necessary */
  if (nleft == 1) {
    80005b46:	4705                	li	a4,1
    80005b48:	02e58563          	beq	a1,a4,80005b72 <in_cksum+0x66>
    *(unsigned char *)(&answer) = *(const unsigned char *)w;
    sum += answer;
  }

  /* add back carry outs from top 16 bits to low 16 bits */
  sum = (sum & 0xffff) + (sum >> 16);
    80005b4c:	03079513          	slli	a0,a5,0x30
    80005b50:	9141                	srli	a0,a0,0x30
    80005b52:	0107d79b          	srliw	a5,a5,0x10
    80005b56:	9fa9                	addw	a5,a5,a0
  sum += (sum >> 16);
    80005b58:	0107d51b          	srliw	a0,a5,0x10
    80005b5c:	9d3d                	addw	a0,a0,a5
  /* guaranteed now that the lower 16 bits of sum are correct */

  answer = ~sum; /* truncate to 16 bits */
    80005b5e:	fff54513          	not	a0,a0
  return answer;
}
    80005b62:	1542                	slli	a0,a0,0x30
    80005b64:	9141                	srli	a0,a0,0x30
    80005b66:	6462                	ld	s0,24(sp)
    80005b68:	6105                	addi	sp,sp,32
    80005b6a:	8082                	ret
  const unsigned short *w = (const unsigned short *)addr;
    80005b6c:	86aa                	mv	a3,a0
  unsigned int sum = 0;
    80005b6e:	4781                	li	a5,0
    80005b70:	bfd9                	j	80005b46 <in_cksum+0x3a>
    *(unsigned char *)(&answer) = *(const unsigned char *)w;
    80005b72:	0006c703          	lbu	a4,0(a3)
    80005b76:	fee40723          	sb	a4,-18(s0)
    sum += answer;
    80005b7a:	fee45703          	lhu	a4,-18(s0)
    80005b7e:	9fb9                	addw	a5,a5,a4
    80005b80:	b7f1                	j	80005b4c <in_cksum+0x40>

0000000080005b82 <mbufpull>:
{
    80005b82:	1141                	addi	sp,sp,-16
    80005b84:	e422                	sd	s0,8(sp)
    80005b86:	0800                	addi	s0,sp,16
    80005b88:	87aa                	mv	a5,a0
  char *tmp = m->head;
    80005b8a:	6508                	ld	a0,8(a0)
  if (m->len < len)
    80005b8c:	4b98                	lw	a4,16(a5)
    80005b8e:	00b76b63          	bltu	a4,a1,80005ba4 <mbufpull+0x22>
  m->len -= len;
    80005b92:	9f0d                	subw	a4,a4,a1
    80005b94:	cb98                	sw	a4,16(a5)
  m->head += len;
    80005b96:	1582                	slli	a1,a1,0x20
    80005b98:	9181                	srli	a1,a1,0x20
    80005b9a:	95aa                	add	a1,a1,a0
    80005b9c:	e78c                	sd	a1,8(a5)
}
    80005b9e:	6422                	ld	s0,8(sp)
    80005ba0:	0141                	addi	sp,sp,16
    80005ba2:	8082                	ret
    return 0;
    80005ba4:	4501                	li	a0,0
    80005ba6:	bfe5                	j	80005b9e <mbufpull+0x1c>

0000000080005ba8 <mbufpush>:
{
    80005ba8:	87aa                	mv	a5,a0
  m->head -= len;
    80005baa:	02059713          	slli	a4,a1,0x20
    80005bae:	9301                	srli	a4,a4,0x20
    80005bb0:	6508                	ld	a0,8(a0)
    80005bb2:	8d19                	sub	a0,a0,a4
    80005bb4:	e788                	sd	a0,8(a5)
  if (m->head < m->buf)
    80005bb6:	01478713          	addi	a4,a5,20
    80005bba:	00e56663          	bltu	a0,a4,80005bc6 <mbufpush+0x1e>
  m->len += len;
    80005bbe:	4b98                	lw	a4,16(a5)
    80005bc0:	9db9                	addw	a1,a1,a4
    80005bc2:	cb8c                	sw	a1,16(a5)
}
    80005bc4:	8082                	ret
{
    80005bc6:	1141                	addi	sp,sp,-16
    80005bc8:	e406                	sd	ra,8(sp)
    80005bca:	e022                	sd	s0,0(sp)
    80005bcc:	0800                	addi	s0,sp,16
    panic("mbufpush");
    80005bce:	00004517          	auipc	a0,0x4
    80005bd2:	c0250513          	addi	a0,a0,-1022 # 800097d0 <syscalls+0x420>
    80005bd6:	00001097          	auipc	ra,0x1
    80005bda:	05e080e7          	jalr	94(ra) # 80006c34 <panic>

0000000080005bde <net_tx_eth>:

// sends an ethernet packet
static void
net_tx_eth(struct mbuf *m, uint16 ethtype)
{
    80005bde:	7179                	addi	sp,sp,-48
    80005be0:	f406                	sd	ra,40(sp)
    80005be2:	f022                	sd	s0,32(sp)
    80005be4:	ec26                	sd	s1,24(sp)
    80005be6:	e84a                	sd	s2,16(sp)
    80005be8:	e44e                	sd	s3,8(sp)
    80005bea:	1800                	addi	s0,sp,48
    80005bec:	89aa                	mv	s3,a0
    80005bee:	892e                	mv	s2,a1
  struct eth *ethhdr;

  ethhdr = mbufpushhdr(m, *ethhdr);
    80005bf0:	45b9                	li	a1,14
    80005bf2:	00000097          	auipc	ra,0x0
    80005bf6:	fb6080e7          	jalr	-74(ra) # 80005ba8 <mbufpush>
    80005bfa:	84aa                	mv	s1,a0
  memmove(ethhdr->shost, local_mac, ETHADDR_LEN);
    80005bfc:	4619                	li	a2,6
    80005bfe:	00004597          	auipc	a1,0x4
    80005c02:	c9258593          	addi	a1,a1,-878 # 80009890 <local_mac>
    80005c06:	0519                	addi	a0,a0,6
    80005c08:	ffffa097          	auipc	ra,0xffffa
    80005c0c:	5cc080e7          	jalr	1484(ra) # 800001d4 <memmove>
  // In a real networking stack, dhost would be set to the address discovered
  // through ARP. Because we don't support enough of the ARP protocol, set it
  // to broadcast instead.
  memmove(ethhdr->dhost, broadcast_mac, ETHADDR_LEN);
    80005c10:	4619                	li	a2,6
    80005c12:	00004597          	auipc	a1,0x4
    80005c16:	c7658593          	addi	a1,a1,-906 # 80009888 <broadcast_mac>
    80005c1a:	8526                	mv	a0,s1
    80005c1c:	ffffa097          	auipc	ra,0xffffa
    80005c20:	5b8080e7          	jalr	1464(ra) # 800001d4 <memmove>
// endianness support
//

static inline uint16 bswaps(uint16 val)
{
  return (((val & 0x00ffU) << 8) |
    80005c24:	0089579b          	srliw	a5,s2,0x8
  ethhdr->type = htons(ethtype);
    80005c28:	00f48623          	sb	a5,12(s1)
    80005c2c:	012486a3          	sb	s2,13(s1)
  if (e1000_transmit(m)) {
    80005c30:	854e                	mv	a0,s3
    80005c32:	00000097          	auipc	ra,0x0
    80005c36:	cdc080e7          	jalr	-804(ra) # 8000590e <e1000_transmit>
    80005c3a:	e901                	bnez	a0,80005c4a <net_tx_eth+0x6c>
    mbuffree(m);
  }
}
    80005c3c:	70a2                	ld	ra,40(sp)
    80005c3e:	7402                	ld	s0,32(sp)
    80005c40:	64e2                	ld	s1,24(sp)
    80005c42:	6942                	ld	s2,16(sp)
    80005c44:	69a2                	ld	s3,8(sp)
    80005c46:	6145                	addi	sp,sp,48
    80005c48:	8082                	ret
  kfree(m);
    80005c4a:	854e                	mv	a0,s3
    80005c4c:	ffffa097          	auipc	ra,0xffffa
    80005c50:	3d0080e7          	jalr	976(ra) # 8000001c <kfree>
}
    80005c54:	b7e5                	j	80005c3c <net_tx_eth+0x5e>

0000000080005c56 <mbufput>:
{
    80005c56:	87aa                	mv	a5,a0
  char *tmp = m->head + m->len;
    80005c58:	4918                	lw	a4,16(a0)
    80005c5a:	02071693          	slli	a3,a4,0x20
    80005c5e:	9281                	srli	a3,a3,0x20
    80005c60:	6508                	ld	a0,8(a0)
    80005c62:	9536                	add	a0,a0,a3
  m->len += len;
    80005c64:	9f2d                	addw	a4,a4,a1
    80005c66:	0007069b          	sext.w	a3,a4
    80005c6a:	cb98                	sw	a4,16(a5)
  if (m->len > MBUF_SIZE)
    80005c6c:	6785                	lui	a5,0x1
    80005c6e:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    80005c72:	00d7e363          	bltu	a5,a3,80005c78 <mbufput+0x22>
}
    80005c76:	8082                	ret
{
    80005c78:	1141                	addi	sp,sp,-16
    80005c7a:	e406                	sd	ra,8(sp)
    80005c7c:	e022                	sd	s0,0(sp)
    80005c7e:	0800                	addi	s0,sp,16
    panic("mbufput");
    80005c80:	00004517          	auipc	a0,0x4
    80005c84:	b6050513          	addi	a0,a0,-1184 # 800097e0 <syscalls+0x430>
    80005c88:	00001097          	auipc	ra,0x1
    80005c8c:	fac080e7          	jalr	-84(ra) # 80006c34 <panic>

0000000080005c90 <mbuftrim>:
{
    80005c90:	1141                	addi	sp,sp,-16
    80005c92:	e422                	sd	s0,8(sp)
    80005c94:	0800                	addi	s0,sp,16
  if (len > m->len)
    80005c96:	491c                	lw	a5,16(a0)
    80005c98:	00b7eb63          	bltu	a5,a1,80005cae <mbuftrim+0x1e>
  m->len -= len;
    80005c9c:	9f8d                	subw	a5,a5,a1
    80005c9e:	c91c                	sw	a5,16(a0)
  return m->head + m->len;
    80005ca0:	1782                	slli	a5,a5,0x20
    80005ca2:	9381                	srli	a5,a5,0x20
    80005ca4:	6508                	ld	a0,8(a0)
    80005ca6:	953e                	add	a0,a0,a5
}
    80005ca8:	6422                	ld	s0,8(sp)
    80005caa:	0141                	addi	sp,sp,16
    80005cac:	8082                	ret
    return 0;
    80005cae:	4501                	li	a0,0
    80005cb0:	bfe5                	j	80005ca8 <mbuftrim+0x18>

0000000080005cb2 <mbufalloc>:
{
    80005cb2:	1101                	addi	sp,sp,-32
    80005cb4:	ec06                	sd	ra,24(sp)
    80005cb6:	e822                	sd	s0,16(sp)
    80005cb8:	e426                	sd	s1,8(sp)
    80005cba:	e04a                	sd	s2,0(sp)
    80005cbc:	1000                	addi	s0,sp,32
  if (headroom > MBUF_SIZE)
    80005cbe:	6785                	lui	a5,0x1
    80005cc0:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    return 0;
    80005cc4:	4901                	li	s2,0
  if (headroom > MBUF_SIZE)
    80005cc6:	02a7eb63          	bltu	a5,a0,80005cfc <mbufalloc+0x4a>
    80005cca:	84aa                	mv	s1,a0
  m = kalloc();
    80005ccc:	ffffa097          	auipc	ra,0xffffa
    80005cd0:	44c080e7          	jalr	1100(ra) # 80000118 <kalloc>
    80005cd4:	892a                	mv	s2,a0
  if (m == 0)
    80005cd6:	c11d                	beqz	a0,80005cfc <mbufalloc+0x4a>
  m->next = 0;
    80005cd8:	00053023          	sd	zero,0(a0)
  m->head = (char *)m->buf + headroom;
    80005cdc:	0551                	addi	a0,a0,20
    80005cde:	1482                	slli	s1,s1,0x20
    80005ce0:	9081                	srli	s1,s1,0x20
    80005ce2:	94aa                	add	s1,s1,a0
    80005ce4:	00993423          	sd	s1,8(s2)
  m->len = 0;
    80005ce8:	00092823          	sw	zero,16(s2)
  memset(m->buf, 0, sizeof(m->buf));
    80005cec:	6605                	lui	a2,0x1
    80005cee:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80005cf2:	4581                	li	a1,0
    80005cf4:	ffffa097          	auipc	ra,0xffffa
    80005cf8:	484080e7          	jalr	1156(ra) # 80000178 <memset>
}
    80005cfc:	854a                	mv	a0,s2
    80005cfe:	60e2                	ld	ra,24(sp)
    80005d00:	6442                	ld	s0,16(sp)
    80005d02:	64a2                	ld	s1,8(sp)
    80005d04:	6902                	ld	s2,0(sp)
    80005d06:	6105                	addi	sp,sp,32
    80005d08:	8082                	ret

0000000080005d0a <mbuffree>:
{
    80005d0a:	1141                	addi	sp,sp,-16
    80005d0c:	e406                	sd	ra,8(sp)
    80005d0e:	e022                	sd	s0,0(sp)
    80005d10:	0800                	addi	s0,sp,16
  kfree(m);
    80005d12:	ffffa097          	auipc	ra,0xffffa
    80005d16:	30a080e7          	jalr	778(ra) # 8000001c <kfree>
}
    80005d1a:	60a2                	ld	ra,8(sp)
    80005d1c:	6402                	ld	s0,0(sp)
    80005d1e:	0141                	addi	sp,sp,16
    80005d20:	8082                	ret

0000000080005d22 <mbufq_pushtail>:
{
    80005d22:	1141                	addi	sp,sp,-16
    80005d24:	e422                	sd	s0,8(sp)
    80005d26:	0800                	addi	s0,sp,16
  m->next = 0;
    80005d28:	0005b023          	sd	zero,0(a1)
  if (!q->head){
    80005d2c:	611c                	ld	a5,0(a0)
    80005d2e:	c799                	beqz	a5,80005d3c <mbufq_pushtail+0x1a>
  q->tail->next = m;
    80005d30:	651c                	ld	a5,8(a0)
    80005d32:	e38c                	sd	a1,0(a5)
  q->tail = m;
    80005d34:	e50c                	sd	a1,8(a0)
}
    80005d36:	6422                	ld	s0,8(sp)
    80005d38:	0141                	addi	sp,sp,16
    80005d3a:	8082                	ret
    q->head = q->tail = m;
    80005d3c:	e50c                	sd	a1,8(a0)
    80005d3e:	e10c                	sd	a1,0(a0)
    return;
    80005d40:	bfdd                	j	80005d36 <mbufq_pushtail+0x14>

0000000080005d42 <mbufq_pophead>:
{
    80005d42:	1141                	addi	sp,sp,-16
    80005d44:	e422                	sd	s0,8(sp)
    80005d46:	0800                	addi	s0,sp,16
    80005d48:	87aa                	mv	a5,a0
  struct mbuf *head = q->head;
    80005d4a:	6108                	ld	a0,0(a0)
  if (!head)
    80005d4c:	c119                	beqz	a0,80005d52 <mbufq_pophead+0x10>
  q->head = head->next;
    80005d4e:	6118                	ld	a4,0(a0)
    80005d50:	e398                	sd	a4,0(a5)
}
    80005d52:	6422                	ld	s0,8(sp)
    80005d54:	0141                	addi	sp,sp,16
    80005d56:	8082                	ret

0000000080005d58 <mbufq_empty>:
{
    80005d58:	1141                	addi	sp,sp,-16
    80005d5a:	e422                	sd	s0,8(sp)
    80005d5c:	0800                	addi	s0,sp,16
  return q->head == 0;
    80005d5e:	6108                	ld	a0,0(a0)
}
    80005d60:	00153513          	seqz	a0,a0
    80005d64:	6422                	ld	s0,8(sp)
    80005d66:	0141                	addi	sp,sp,16
    80005d68:	8082                	ret

0000000080005d6a <mbufq_init>:
{
    80005d6a:	1141                	addi	sp,sp,-16
    80005d6c:	e422                	sd	s0,8(sp)
    80005d6e:	0800                	addi	s0,sp,16
  q->head = 0;
    80005d70:	00053023          	sd	zero,0(a0)
}
    80005d74:	6422                	ld	s0,8(sp)
    80005d76:	0141                	addi	sp,sp,16
    80005d78:	8082                	ret

0000000080005d7a <net_tx_udp>:

// sends a UDP packet
void
net_tx_udp(struct mbuf *m, uint32 dip,
           uint16 sport, uint16 dport)
{
    80005d7a:	7179                	addi	sp,sp,-48
    80005d7c:	f406                	sd	ra,40(sp)
    80005d7e:	f022                	sd	s0,32(sp)
    80005d80:	ec26                	sd	s1,24(sp)
    80005d82:	e84a                	sd	s2,16(sp)
    80005d84:	e44e                	sd	s3,8(sp)
    80005d86:	e052                	sd	s4,0(sp)
    80005d88:	1800                	addi	s0,sp,48
    80005d8a:	89aa                	mv	s3,a0
    80005d8c:	892e                	mv	s2,a1
    80005d8e:	8a32                	mv	s4,a2
    80005d90:	84b6                	mv	s1,a3
  struct udp *udphdr;

  // put the UDP header
  udphdr = mbufpushhdr(m, *udphdr);
    80005d92:	45a1                	li	a1,8
    80005d94:	00000097          	auipc	ra,0x0
    80005d98:	e14080e7          	jalr	-492(ra) # 80005ba8 <mbufpush>
    80005d9c:	008a161b          	slliw	a2,s4,0x8
    80005da0:	008a5a1b          	srliw	s4,s4,0x8
    80005da4:	01466a33          	or	s4,a2,s4
  udphdr->sport = htons(sport);
    80005da8:	01451023          	sh	s4,0(a0)
    80005dac:	0084969b          	slliw	a3,s1,0x8
    80005db0:	0084d49b          	srliw	s1,s1,0x8
    80005db4:	8cd5                	or	s1,s1,a3
  udphdr->dport = htons(dport);
    80005db6:	00951123          	sh	s1,2(a0)
  udphdr->ulen = htons(m->len);
    80005dba:	0109a783          	lw	a5,16(s3)
    80005dbe:	0087971b          	slliw	a4,a5,0x8
    80005dc2:	0107979b          	slliw	a5,a5,0x10
    80005dc6:	0107d79b          	srliw	a5,a5,0x10
    80005dca:	0087d79b          	srliw	a5,a5,0x8
    80005dce:	8fd9                	or	a5,a5,a4
    80005dd0:	00f51223          	sh	a5,4(a0)
  udphdr->sum = 0; // zero means no checksum is provided
    80005dd4:	00051323          	sh	zero,6(a0)
  iphdr = mbufpushhdr(m, *iphdr);
    80005dd8:	45d1                	li	a1,20
    80005dda:	854e                	mv	a0,s3
    80005ddc:	00000097          	auipc	ra,0x0
    80005de0:	dcc080e7          	jalr	-564(ra) # 80005ba8 <mbufpush>
    80005de4:	84aa                	mv	s1,a0
  memset(iphdr, 0, sizeof(*iphdr));
    80005de6:	4651                	li	a2,20
    80005de8:	4581                	li	a1,0
    80005dea:	ffffa097          	auipc	ra,0xffffa
    80005dee:	38e080e7          	jalr	910(ra) # 80000178 <memset>
  iphdr->ip_vhl = (4 << 4) | (20 >> 2);
    80005df2:	04500793          	li	a5,69
    80005df6:	00f48023          	sb	a5,0(s1)
  iphdr->ip_p = proto;
    80005dfa:	47c5                	li	a5,17
    80005dfc:	00f484a3          	sb	a5,9(s1)
  iphdr->ip_src = htonl(local_ip);
    80005e00:	0f0207b7          	lui	a5,0xf020
    80005e04:	07a9                	addi	a5,a5,10
    80005e06:	c4dc                	sw	a5,12(s1)
          ((val & 0xff00U) >> 8));
}

static inline uint32 bswapl(uint32 val)
{
  return (((val & 0x000000ffUL) << 24) |
    80005e08:	0189179b          	slliw	a5,s2,0x18
          ((val & 0x0000ff00UL) << 8) |
          ((val & 0x00ff0000UL) >> 8) |
          ((val & 0xff000000UL) >> 24));
    80005e0c:	0189571b          	srliw	a4,s2,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80005e10:	8fd9                	or	a5,a5,a4
          ((val & 0x0000ff00UL) << 8) |
    80005e12:	0089171b          	slliw	a4,s2,0x8
    80005e16:	00ff06b7          	lui	a3,0xff0
    80005e1a:	8f75                	and	a4,a4,a3
          ((val & 0x00ff0000UL) >> 8) |
    80005e1c:	8fd9                	or	a5,a5,a4
    80005e1e:	0089591b          	srliw	s2,s2,0x8
    80005e22:	65c1                	lui	a1,0x10
    80005e24:	f0058593          	addi	a1,a1,-256 # ff00 <_entry-0x7fff0100>
    80005e28:	00b97933          	and	s2,s2,a1
    80005e2c:	0127e933          	or	s2,a5,s2
  iphdr->ip_dst = htonl(dip);
    80005e30:	0124a823          	sw	s2,16(s1)
  iphdr->ip_len = htons(m->len);
    80005e34:	0109a783          	lw	a5,16(s3)
  return (((val & 0x00ffU) << 8) |
    80005e38:	0087971b          	slliw	a4,a5,0x8
    80005e3c:	0107979b          	slliw	a5,a5,0x10
    80005e40:	0107d79b          	srliw	a5,a5,0x10
    80005e44:	0087d79b          	srliw	a5,a5,0x8
    80005e48:	8fd9                	or	a5,a5,a4
    80005e4a:	00f49123          	sh	a5,2(s1)
  iphdr->ip_ttl = 100;
    80005e4e:	06400793          	li	a5,100
    80005e52:	00f48423          	sb	a5,8(s1)
  iphdr->ip_sum = in_cksum((unsigned char *)iphdr, sizeof(*iphdr));
    80005e56:	45d1                	li	a1,20
    80005e58:	8526                	mv	a0,s1
    80005e5a:	00000097          	auipc	ra,0x0
    80005e5e:	cb2080e7          	jalr	-846(ra) # 80005b0c <in_cksum>
    80005e62:	00a49523          	sh	a0,10(s1)
  net_tx_eth(m, ETHTYPE_IP);
    80005e66:	6585                	lui	a1,0x1
    80005e68:	80058593          	addi	a1,a1,-2048 # 800 <_entry-0x7ffff800>
    80005e6c:	854e                	mv	a0,s3
    80005e6e:	00000097          	auipc	ra,0x0
    80005e72:	d70080e7          	jalr	-656(ra) # 80005bde <net_tx_eth>

  // now on to the IP layer
  net_tx_ip(m, IPPROTO_UDP, dip);
}
    80005e76:	70a2                	ld	ra,40(sp)
    80005e78:	7402                	ld	s0,32(sp)
    80005e7a:	64e2                	ld	s1,24(sp)
    80005e7c:	6942                	ld	s2,16(sp)
    80005e7e:	69a2                	ld	s3,8(sp)
    80005e80:	6a02                	ld	s4,0(sp)
    80005e82:	6145                	addi	sp,sp,48
    80005e84:	8082                	ret

0000000080005e86 <net_rx>:
}

// called by e1000 driver's interrupt handler to deliver a packet to the
// networking stack
void net_rx(struct mbuf *m)
{
    80005e86:	715d                	addi	sp,sp,-80
    80005e88:	e486                	sd	ra,72(sp)
    80005e8a:	e0a2                	sd	s0,64(sp)
    80005e8c:	fc26                	sd	s1,56(sp)
    80005e8e:	f84a                	sd	s2,48(sp)
    80005e90:	f44e                	sd	s3,40(sp)
    80005e92:	f052                	sd	s4,32(sp)
    80005e94:	ec56                	sd	s5,24(sp)
    80005e96:	0880                	addi	s0,sp,80
    80005e98:	84aa                	mv	s1,a0
  struct eth *ethhdr;
  uint16 type;

  ethhdr = mbufpullhdr(m, *ethhdr);
    80005e9a:	45b9                	li	a1,14
    80005e9c:	00000097          	auipc	ra,0x0
    80005ea0:	ce6080e7          	jalr	-794(ra) # 80005b82 <mbufpull>
  if (!ethhdr) {
    80005ea4:	c521                	beqz	a0,80005eec <net_rx+0x66>
    mbuffree(m);
    return;
  }

  type = ntohs(ethhdr->type);
    80005ea6:	00c54703          	lbu	a4,12(a0)
    80005eaa:	00d54783          	lbu	a5,13(a0)
    80005eae:	07a2                	slli	a5,a5,0x8
    80005eb0:	8fd9                	or	a5,a5,a4
    80005eb2:	0087971b          	slliw	a4,a5,0x8
    80005eb6:	83a1                	srli	a5,a5,0x8
    80005eb8:	8fd9                	or	a5,a5,a4
    80005eba:	17c2                	slli	a5,a5,0x30
    80005ebc:	93c1                	srli	a5,a5,0x30
  if (type == ETHTYPE_IP)
    80005ebe:	8007871b          	addiw	a4,a5,-2048
    80005ec2:	cb1d                	beqz	a4,80005ef8 <net_rx+0x72>
    net_rx_ip(m);
  else if (type == ETHTYPE_ARP)
    80005ec4:	2781                	sext.w	a5,a5
    80005ec6:	6705                	lui	a4,0x1
    80005ec8:	80670713          	addi	a4,a4,-2042 # 806 <_entry-0x7ffff7fa>
    80005ecc:	1ae78a63          	beq	a5,a4,80006080 <net_rx+0x1fa>
  kfree(m);
    80005ed0:	8526                	mv	a0,s1
    80005ed2:	ffffa097          	auipc	ra,0xffffa
    80005ed6:	14a080e7          	jalr	330(ra) # 8000001c <kfree>
    net_rx_arp(m);
  else
    mbuffree(m);
}
    80005eda:	60a6                	ld	ra,72(sp)
    80005edc:	6406                	ld	s0,64(sp)
    80005ede:	74e2                	ld	s1,56(sp)
    80005ee0:	7942                	ld	s2,48(sp)
    80005ee2:	79a2                	ld	s3,40(sp)
    80005ee4:	7a02                	ld	s4,32(sp)
    80005ee6:	6ae2                	ld	s5,24(sp)
    80005ee8:	6161                	addi	sp,sp,80
    80005eea:	8082                	ret
  kfree(m);
    80005eec:	8526                	mv	a0,s1
    80005eee:	ffffa097          	auipc	ra,0xffffa
    80005ef2:	12e080e7          	jalr	302(ra) # 8000001c <kfree>
}
    80005ef6:	b7d5                	j	80005eda <net_rx+0x54>
  iphdr = mbufpullhdr(m, *iphdr);
    80005ef8:	45d1                	li	a1,20
    80005efa:	8526                	mv	a0,s1
    80005efc:	00000097          	auipc	ra,0x0
    80005f00:	c86080e7          	jalr	-890(ra) # 80005b82 <mbufpull>
    80005f04:	892a                	mv	s2,a0
  if (!iphdr)
    80005f06:	c519                	beqz	a0,80005f14 <net_rx+0x8e>
  if (iphdr->ip_vhl != ((4 << 4) | (20 >> 2)))
    80005f08:	00054703          	lbu	a4,0(a0)
    80005f0c:	04500793          	li	a5,69
    80005f10:	00f70863          	beq	a4,a5,80005f20 <net_rx+0x9a>
  kfree(m);
    80005f14:	8526                	mv	a0,s1
    80005f16:	ffffa097          	auipc	ra,0xffffa
    80005f1a:	106080e7          	jalr	262(ra) # 8000001c <kfree>
}
    80005f1e:	bf75                	j	80005eda <net_rx+0x54>
  if (in_cksum((unsigned char *)iphdr, sizeof(*iphdr)))
    80005f20:	45d1                	li	a1,20
    80005f22:	00000097          	auipc	ra,0x0
    80005f26:	bea080e7          	jalr	-1046(ra) # 80005b0c <in_cksum>
    80005f2a:	f56d                	bnez	a0,80005f14 <net_rx+0x8e>
    80005f2c:	00695783          	lhu	a5,6(s2)
    80005f30:	0087971b          	slliw	a4,a5,0x8
    80005f34:	0107979b          	slliw	a5,a5,0x10
    80005f38:	0107d79b          	srliw	a5,a5,0x10
    80005f3c:	0087d79b          	srliw	a5,a5,0x8
    80005f40:	8fd9                	or	a5,a5,a4
  if (htons(iphdr->ip_off) != 0)
    80005f42:	17c2                	slli	a5,a5,0x30
    80005f44:	93c1                	srli	a5,a5,0x30
    80005f46:	f7f9                	bnez	a5,80005f14 <net_rx+0x8e>
  if (htonl(iphdr->ip_dst) != local_ip)
    80005f48:	01092703          	lw	a4,16(s2)
  return (((val & 0x000000ffUL) << 24) |
    80005f4c:	0187179b          	slliw	a5,a4,0x18
          ((val & 0xff000000UL) >> 24));
    80005f50:	0187569b          	srliw	a3,a4,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80005f54:	8fd5                	or	a5,a5,a3
          ((val & 0x0000ff00UL) << 8) |
    80005f56:	0087169b          	slliw	a3,a4,0x8
    80005f5a:	00ff0637          	lui	a2,0xff0
    80005f5e:	8ef1                	and	a3,a3,a2
          ((val & 0x00ff0000UL) >> 8) |
    80005f60:	8fd5                	or	a5,a5,a3
    80005f62:	0087571b          	srliw	a4,a4,0x8
    80005f66:	66c1                	lui	a3,0x10
    80005f68:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    80005f6c:	8f75                	and	a4,a4,a3
    80005f6e:	8fd9                	or	a5,a5,a4
    80005f70:	2781                	sext.w	a5,a5
    80005f72:	0a000737          	lui	a4,0xa000
    80005f76:	20f70713          	addi	a4,a4,527 # a00020f <_entry-0x75fffdf1>
    80005f7a:	f8e79de3          	bne	a5,a4,80005f14 <net_rx+0x8e>
  if (iphdr->ip_p != IPPROTO_UDP)
    80005f7e:	00994703          	lbu	a4,9(s2)
    80005f82:	47c5                	li	a5,17
    80005f84:	f8f718e3          	bne	a4,a5,80005f14 <net_rx+0x8e>
  return (((val & 0x00ffU) << 8) |
    80005f88:	00295783          	lhu	a5,2(s2)
    80005f8c:	0087999b          	slliw	s3,a5,0x8
    80005f90:	0107979b          	slliw	a5,a5,0x10
    80005f94:	0107d79b          	srliw	a5,a5,0x10
    80005f98:	0087d79b          	srliw	a5,a5,0x8
    80005f9c:	00f9e7b3          	or	a5,s3,a5
    80005fa0:	03079993          	slli	s3,a5,0x30
    80005fa4:	0309d993          	srli	s3,s3,0x30
  len = ntohs(iphdr->ip_len) - sizeof(*iphdr);
    80005fa8:	fec9879b          	addiw	a5,s3,-20
    80005fac:	03079a13          	slli	s4,a5,0x30
    80005fb0:	030a5a13          	srli	s4,s4,0x30
  udphdr = mbufpullhdr(m, *udphdr);
    80005fb4:	45a1                	li	a1,8
    80005fb6:	8526                	mv	a0,s1
    80005fb8:	00000097          	auipc	ra,0x0
    80005fbc:	bca080e7          	jalr	-1078(ra) # 80005b82 <mbufpull>
    80005fc0:	8aaa                	mv	s5,a0
  if (!udphdr)
    80005fc2:	cd0d                	beqz	a0,80005ffc <net_rx+0x176>
    80005fc4:	00455783          	lhu	a5,4(a0)
    80005fc8:	0087971b          	slliw	a4,a5,0x8
    80005fcc:	0107979b          	slliw	a5,a5,0x10
    80005fd0:	0107d79b          	srliw	a5,a5,0x10
    80005fd4:	0087d79b          	srliw	a5,a5,0x8
    80005fd8:	8f5d                	or	a4,a4,a5
  if (ntohs(udphdr->ulen) != len)
    80005fda:	000a079b          	sext.w	a5,s4
    80005fde:	1742                	slli	a4,a4,0x30
    80005fe0:	9341                	srli	a4,a4,0x30
    80005fe2:	00e79d63          	bne	a5,a4,80005ffc <net_rx+0x176>
  len -= sizeof(*udphdr);
    80005fe6:	fe49879b          	addiw	a5,s3,-28
  if (len > m->len)
    80005fea:	0107979b          	slliw	a5,a5,0x10
    80005fee:	0107d79b          	srliw	a5,a5,0x10
    80005ff2:	0007871b          	sext.w	a4,a5
    80005ff6:	488c                	lw	a1,16(s1)
    80005ff8:	00e5f863          	bgeu	a1,a4,80006008 <net_rx+0x182>
  kfree(m);
    80005ffc:	8526                	mv	a0,s1
    80005ffe:	ffffa097          	auipc	ra,0xffffa
    80006002:	01e080e7          	jalr	30(ra) # 8000001c <kfree>
}
    80006006:	bdd1                	j	80005eda <net_rx+0x54>
  mbuftrim(m, m->len - len);
    80006008:	9d9d                	subw	a1,a1,a5
    8000600a:	8526                	mv	a0,s1
    8000600c:	00000097          	auipc	ra,0x0
    80006010:	c84080e7          	jalr	-892(ra) # 80005c90 <mbuftrim>
  sip = ntohl(iphdr->ip_src);
    80006014:	00c92783          	lw	a5,12(s2)
    80006018:	000ad703          	lhu	a4,0(s5)
    8000601c:	0087169b          	slliw	a3,a4,0x8
    80006020:	0107171b          	slliw	a4,a4,0x10
    80006024:	0107571b          	srliw	a4,a4,0x10
    80006028:	0087571b          	srliw	a4,a4,0x8
    8000602c:	8ed9                	or	a3,a3,a4
    8000602e:	002ad703          	lhu	a4,2(s5)
    80006032:	0087161b          	slliw	a2,a4,0x8
    80006036:	0107171b          	slliw	a4,a4,0x10
    8000603a:	0107571b          	srliw	a4,a4,0x10
    8000603e:	0087571b          	srliw	a4,a4,0x8
    80006042:	8e59                	or	a2,a2,a4
  return (((val & 0x000000ffUL) << 24) |
    80006044:	0187971b          	slliw	a4,a5,0x18
          ((val & 0xff000000UL) >> 24));
    80006048:	0187d59b          	srliw	a1,a5,0x18
          ((val & 0x00ff0000UL) >> 8) |
    8000604c:	8f4d                	or	a4,a4,a1
          ((val & 0x0000ff00UL) << 8) |
    8000604e:	0087959b          	slliw	a1,a5,0x8
    80006052:	00ff0537          	lui	a0,0xff0
    80006056:	8de9                	and	a1,a1,a0
          ((val & 0x00ff0000UL) >> 8) |
    80006058:	8f4d                	or	a4,a4,a1
    8000605a:	0087d79b          	srliw	a5,a5,0x8
    8000605e:	65c1                	lui	a1,0x10
    80006060:	f0058593          	addi	a1,a1,-256 # ff00 <_entry-0x7fff0100>
    80006064:	8fed                	and	a5,a5,a1
    80006066:	8fd9                	or	a5,a5,a4
  sockrecvudp(m, sip, dport, sport);
    80006068:	16c2                	slli	a3,a3,0x30
    8000606a:	92c1                	srli	a3,a3,0x30
    8000606c:	1642                	slli	a2,a2,0x30
    8000606e:	9241                	srli	a2,a2,0x30
    80006070:	0007859b          	sext.w	a1,a5
    80006074:	8526                	mv	a0,s1
    80006076:	00000097          	auipc	ra,0x0
    8000607a:	55c080e7          	jalr	1372(ra) # 800065d2 <sockrecvudp>
  return;
    8000607e:	bdb1                	j	80005eda <net_rx+0x54>
  arphdr = mbufpullhdr(m, *arphdr);
    80006080:	45f1                	li	a1,28
    80006082:	8526                	mv	a0,s1
    80006084:	00000097          	auipc	ra,0x0
    80006088:	afe080e7          	jalr	-1282(ra) # 80005b82 <mbufpull>
    8000608c:	892a                	mv	s2,a0
  if (!arphdr)
    8000608e:	c179                	beqz	a0,80006154 <net_rx+0x2ce>
  if (ntohs(arphdr->hrd) != ARP_HRD_ETHER ||
    80006090:	00054703          	lbu	a4,0(a0) # ff0000 <_entry-0x7f010000>
    80006094:	00154783          	lbu	a5,1(a0)
    80006098:	07a2                	slli	a5,a5,0x8
    8000609a:	8fd9                	or	a5,a5,a4
  return (((val & 0x00ffU) << 8) |
    8000609c:	0087971b          	slliw	a4,a5,0x8
    800060a0:	83a1                	srli	a5,a5,0x8
    800060a2:	8fd9                	or	a5,a5,a4
    800060a4:	17c2                	slli	a5,a5,0x30
    800060a6:	93c1                	srli	a5,a5,0x30
    800060a8:	4705                	li	a4,1
    800060aa:	0ae79563          	bne	a5,a4,80006154 <net_rx+0x2ce>
      ntohs(arphdr->pro) != ETHTYPE_IP ||
    800060ae:	00254703          	lbu	a4,2(a0)
    800060b2:	00354783          	lbu	a5,3(a0)
    800060b6:	07a2                	slli	a5,a5,0x8
    800060b8:	8fd9                	or	a5,a5,a4
    800060ba:	0087971b          	slliw	a4,a5,0x8
    800060be:	83a1                	srli	a5,a5,0x8
    800060c0:	8fd9                	or	a5,a5,a4
  if (ntohs(arphdr->hrd) != ARP_HRD_ETHER ||
    800060c2:	0107979b          	slliw	a5,a5,0x10
    800060c6:	0107d79b          	srliw	a5,a5,0x10
    800060ca:	8007879b          	addiw	a5,a5,-2048
    800060ce:	e3d9                	bnez	a5,80006154 <net_rx+0x2ce>
      ntohs(arphdr->pro) != ETHTYPE_IP ||
    800060d0:	00454703          	lbu	a4,4(a0)
    800060d4:	4799                	li	a5,6
    800060d6:	06f71f63          	bne	a4,a5,80006154 <net_rx+0x2ce>
      arphdr->hln != ETHADDR_LEN ||
    800060da:	00554703          	lbu	a4,5(a0)
    800060de:	4791                	li	a5,4
    800060e0:	06f71a63          	bne	a4,a5,80006154 <net_rx+0x2ce>
  if (ntohs(arphdr->op) != ARP_OP_REQUEST || tip != local_ip)
    800060e4:	00654703          	lbu	a4,6(a0)
    800060e8:	00754783          	lbu	a5,7(a0)
    800060ec:	07a2                	slli	a5,a5,0x8
    800060ee:	8fd9                	or	a5,a5,a4
    800060f0:	0087971b          	slliw	a4,a5,0x8
    800060f4:	83a1                	srli	a5,a5,0x8
    800060f6:	8fd9                	or	a5,a5,a4
    800060f8:	17c2                	slli	a5,a5,0x30
    800060fa:	93c1                	srli	a5,a5,0x30
    800060fc:	4705                	li	a4,1
    800060fe:	04e79b63          	bne	a5,a4,80006154 <net_rx+0x2ce>
  tip = ntohl(arphdr->tip); // target IP address
    80006102:	01854783          	lbu	a5,24(a0)
    80006106:	01954703          	lbu	a4,25(a0)
    8000610a:	0722                	slli	a4,a4,0x8
    8000610c:	8f5d                	or	a4,a4,a5
    8000610e:	01a54783          	lbu	a5,26(a0)
    80006112:	07c2                	slli	a5,a5,0x10
    80006114:	8f5d                	or	a4,a4,a5
    80006116:	01b54783          	lbu	a5,27(a0)
    8000611a:	07e2                	slli	a5,a5,0x18
    8000611c:	8fd9                	or	a5,a5,a4
    8000611e:	0007871b          	sext.w	a4,a5
  return (((val & 0x000000ffUL) << 24) |
    80006122:	0187979b          	slliw	a5,a5,0x18
          ((val & 0xff000000UL) >> 24));
    80006126:	0187569b          	srliw	a3,a4,0x18
          ((val & 0x00ff0000UL) >> 8) |
    8000612a:	8fd5                	or	a5,a5,a3
          ((val & 0x0000ff00UL) << 8) |
    8000612c:	0087169b          	slliw	a3,a4,0x8
    80006130:	00ff0637          	lui	a2,0xff0
    80006134:	8ef1                	and	a3,a3,a2
          ((val & 0x00ff0000UL) >> 8) |
    80006136:	8fd5                	or	a5,a5,a3
    80006138:	0087571b          	srliw	a4,a4,0x8
    8000613c:	66c1                	lui	a3,0x10
    8000613e:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    80006142:	8f75                	and	a4,a4,a3
    80006144:	8fd9                	or	a5,a5,a4
  if (ntohs(arphdr->op) != ARP_OP_REQUEST || tip != local_ip)
    80006146:	2781                	sext.w	a5,a5
    80006148:	0a000737          	lui	a4,0xa000
    8000614c:	20f70713          	addi	a4,a4,527 # a00020f <_entry-0x75fffdf1>
    80006150:	00e78863          	beq	a5,a4,80006160 <net_rx+0x2da>
  kfree(m);
    80006154:	8526                	mv	a0,s1
    80006156:	ffffa097          	auipc	ra,0xffffa
    8000615a:	ec6080e7          	jalr	-314(ra) # 8000001c <kfree>
}
    8000615e:	bbb5                	j	80005eda <net_rx+0x54>
  memmove(smac, arphdr->sha, ETHADDR_LEN); // sender's ethernet address
    80006160:	4619                	li	a2,6
    80006162:	00850593          	addi	a1,a0,8
    80006166:	fb840513          	addi	a0,s0,-72
    8000616a:	ffffa097          	auipc	ra,0xffffa
    8000616e:	06a080e7          	jalr	106(ra) # 800001d4 <memmove>
  sip = ntohl(arphdr->sip); // sender's IP address (qemu's slirp)
    80006172:	00e94783          	lbu	a5,14(s2)
    80006176:	00f94703          	lbu	a4,15(s2)
    8000617a:	0722                	slli	a4,a4,0x8
    8000617c:	8f5d                	or	a4,a4,a5
    8000617e:	01094783          	lbu	a5,16(s2)
    80006182:	07c2                	slli	a5,a5,0x10
    80006184:	8f5d                	or	a4,a4,a5
    80006186:	01194783          	lbu	a5,17(s2)
    8000618a:	07e2                	slli	a5,a5,0x18
    8000618c:	8fd9                	or	a5,a5,a4
    8000618e:	0007871b          	sext.w	a4,a5
  return (((val & 0x000000ffUL) << 24) |
    80006192:	0187991b          	slliw	s2,a5,0x18
          ((val & 0xff000000UL) >> 24));
    80006196:	0187579b          	srliw	a5,a4,0x18
          ((val & 0x00ff0000UL) >> 8) |
    8000619a:	00f96933          	or	s2,s2,a5
          ((val & 0x0000ff00UL) << 8) |
    8000619e:	0087179b          	slliw	a5,a4,0x8
    800061a2:	00ff06b7          	lui	a3,0xff0
    800061a6:	8ff5                	and	a5,a5,a3
          ((val & 0x00ff0000UL) >> 8) |
    800061a8:	00f96933          	or	s2,s2,a5
    800061ac:	0087579b          	srliw	a5,a4,0x8
    800061b0:	6741                	lui	a4,0x10
    800061b2:	f0070713          	addi	a4,a4,-256 # ff00 <_entry-0x7fff0100>
    800061b6:	8ff9                	and	a5,a5,a4
    800061b8:	00f96933          	or	s2,s2,a5
    800061bc:	2901                	sext.w	s2,s2
  m = mbufalloc(MBUF_DEFAULT_HEADROOM);
    800061be:	08000513          	li	a0,128
    800061c2:	00000097          	auipc	ra,0x0
    800061c6:	af0080e7          	jalr	-1296(ra) # 80005cb2 <mbufalloc>
    800061ca:	8a2a                	mv	s4,a0
  if (!m)
    800061cc:	d541                	beqz	a0,80006154 <net_rx+0x2ce>
  arphdr = mbufputhdr(m, *arphdr);
    800061ce:	45f1                	li	a1,28
    800061d0:	00000097          	auipc	ra,0x0
    800061d4:	a86080e7          	jalr	-1402(ra) # 80005c56 <mbufput>
    800061d8:	89aa                	mv	s3,a0
  arphdr->hrd = htons(ARP_HRD_ETHER);
    800061da:	00050023          	sb	zero,0(a0)
    800061de:	4785                	li	a5,1
    800061e0:	00f500a3          	sb	a5,1(a0)
  arphdr->pro = htons(ETHTYPE_IP);
    800061e4:	47a1                	li	a5,8
    800061e6:	00f50123          	sb	a5,2(a0)
    800061ea:	000501a3          	sb	zero,3(a0)
  arphdr->hln = ETHADDR_LEN;
    800061ee:	4799                	li	a5,6
    800061f0:	00f50223          	sb	a5,4(a0)
  arphdr->pln = sizeof(uint32);
    800061f4:	4791                	li	a5,4
    800061f6:	00f502a3          	sb	a5,5(a0)
  arphdr->op = htons(op);
    800061fa:	00050323          	sb	zero,6(a0)
    800061fe:	4a89                	li	s5,2
    80006200:	015503a3          	sb	s5,7(a0)
  memmove(arphdr->sha, local_mac, ETHADDR_LEN);
    80006204:	4619                	li	a2,6
    80006206:	00003597          	auipc	a1,0x3
    8000620a:	68a58593          	addi	a1,a1,1674 # 80009890 <local_mac>
    8000620e:	0521                	addi	a0,a0,8
    80006210:	ffffa097          	auipc	ra,0xffffa
    80006214:	fc4080e7          	jalr	-60(ra) # 800001d4 <memmove>
  arphdr->sip = htonl(local_ip);
    80006218:	47a9                	li	a5,10
    8000621a:	00f98723          	sb	a5,14(s3)
    8000621e:	000987a3          	sb	zero,15(s3)
    80006222:	01598823          	sb	s5,16(s3)
    80006226:	47bd                	li	a5,15
    80006228:	00f988a3          	sb	a5,17(s3)
  memmove(arphdr->tha, dmac, ETHADDR_LEN);
    8000622c:	4619                	li	a2,6
    8000622e:	fb840593          	addi	a1,s0,-72
    80006232:	01298513          	addi	a0,s3,18
    80006236:	ffffa097          	auipc	ra,0xffffa
    8000623a:	f9e080e7          	jalr	-98(ra) # 800001d4 <memmove>
  return (((val & 0x000000ffUL) << 24) |
    8000623e:	0189171b          	slliw	a4,s2,0x18
          ((val & 0xff000000UL) >> 24));
    80006242:	0189579b          	srliw	a5,s2,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006246:	8f5d                	or	a4,a4,a5
          ((val & 0x0000ff00UL) << 8) |
    80006248:	0089179b          	slliw	a5,s2,0x8
    8000624c:	00ff06b7          	lui	a3,0xff0
    80006250:	8ff5                	and	a5,a5,a3
          ((val & 0x00ff0000UL) >> 8) |
    80006252:	8f5d                	or	a4,a4,a5
    80006254:	0089579b          	srliw	a5,s2,0x8
    80006258:	66c1                	lui	a3,0x10
    8000625a:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    8000625e:	8ff5                	and	a5,a5,a3
    80006260:	8fd9                	or	a5,a5,a4
  arphdr->tip = htonl(dip);
    80006262:	00e98c23          	sb	a4,24(s3)
    80006266:	0087d71b          	srliw	a4,a5,0x8
    8000626a:	00e98ca3          	sb	a4,25(s3)
    8000626e:	0107d71b          	srliw	a4,a5,0x10
    80006272:	00e98d23          	sb	a4,26(s3)
    80006276:	0187d79b          	srliw	a5,a5,0x18
    8000627a:	00f98da3          	sb	a5,27(s3)
  net_tx_eth(m, ETHTYPE_ARP);
    8000627e:	6585                	lui	a1,0x1
    80006280:	80658593          	addi	a1,a1,-2042 # 806 <_entry-0x7ffff7fa>
    80006284:	8552                	mv	a0,s4
    80006286:	00000097          	auipc	ra,0x0
    8000628a:	958080e7          	jalr	-1704(ra) # 80005bde <net_tx_eth>
  return 0;
    8000628e:	b5d9                	j	80006154 <net_rx+0x2ce>

0000000080006290 <sockinit>:
static struct spinlock lock;
static struct sock *sockets;

void
sockinit(void)
{
    80006290:	1141                	addi	sp,sp,-16
    80006292:	e406                	sd	ra,8(sp)
    80006294:	e022                	sd	s0,0(sp)
    80006296:	0800                	addi	s0,sp,16
  initlock(&lock, "socktbl");
    80006298:	00003597          	auipc	a1,0x3
    8000629c:	55058593          	addi	a1,a1,1360 # 800097e8 <syscalls+0x438>
    800062a0:	00019517          	auipc	a0,0x19
    800062a4:	09050513          	addi	a0,a0,144 # 8001f330 <lock>
    800062a8:	00001097          	auipc	ra,0x1
    800062ac:	e38080e7          	jalr	-456(ra) # 800070e0 <initlock>
}
    800062b0:	60a2                	ld	ra,8(sp)
    800062b2:	6402                	ld	s0,0(sp)
    800062b4:	0141                	addi	sp,sp,16
    800062b6:	8082                	ret

00000000800062b8 <sockalloc>:

int
sockalloc(struct file **f, uint32 raddr, uint16 lport, uint16 rport)
{
    800062b8:	7139                	addi	sp,sp,-64
    800062ba:	fc06                	sd	ra,56(sp)
    800062bc:	f822                	sd	s0,48(sp)
    800062be:	f426                	sd	s1,40(sp)
    800062c0:	f04a                	sd	s2,32(sp)
    800062c2:	ec4e                	sd	s3,24(sp)
    800062c4:	e852                	sd	s4,16(sp)
    800062c6:	e456                	sd	s5,8(sp)
    800062c8:	0080                	addi	s0,sp,64
    800062ca:	892a                	mv	s2,a0
    800062cc:	84ae                	mv	s1,a1
    800062ce:	8a32                	mv	s4,a2
    800062d0:	89b6                	mv	s3,a3
  struct sock *si, *pos;

  si = 0;
  *f = 0;
    800062d2:	00053023          	sd	zero,0(a0)
  if ((*f = filealloc()) == 0)
    800062d6:	ffffd097          	auipc	ra,0xffffd
    800062da:	62e080e7          	jalr	1582(ra) # 80003904 <filealloc>
    800062de:	00a93023          	sd	a0,0(s2)
    800062e2:	c975                	beqz	a0,800063d6 <sockalloc+0x11e>
    goto bad;
  if ((si = (struct sock*)kalloc()) == 0)
    800062e4:	ffffa097          	auipc	ra,0xffffa
    800062e8:	e34080e7          	jalr	-460(ra) # 80000118 <kalloc>
    800062ec:	8aaa                	mv	s5,a0
    800062ee:	c15d                	beqz	a0,80006394 <sockalloc+0xdc>
    goto bad;

  // initialize objects
  si->raddr = raddr;
    800062f0:	c504                	sw	s1,8(a0)
  si->lport = lport;
    800062f2:	01451623          	sh	s4,12(a0)
  si->rport = rport;
    800062f6:	01351723          	sh	s3,14(a0)
  initlock(&si->lock, "sock");
    800062fa:	00003597          	auipc	a1,0x3
    800062fe:	4f658593          	addi	a1,a1,1270 # 800097f0 <syscalls+0x440>
    80006302:	0541                	addi	a0,a0,16
    80006304:	00001097          	auipc	ra,0x1
    80006308:	ddc080e7          	jalr	-548(ra) # 800070e0 <initlock>
  mbufq_init(&si->rxq);
    8000630c:	028a8513          	addi	a0,s5,40
    80006310:	00000097          	auipc	ra,0x0
    80006314:	a5a080e7          	jalr	-1446(ra) # 80005d6a <mbufq_init>
  (*f)->type = FD_SOCK;
    80006318:	00093783          	ld	a5,0(s2)
    8000631c:	4711                	li	a4,4
    8000631e:	c398                	sw	a4,0(a5)
  (*f)->readable = 1;
    80006320:	00093703          	ld	a4,0(s2)
    80006324:	4785                	li	a5,1
    80006326:	00f70423          	sb	a5,8(a4)
  (*f)->writable = 1;
    8000632a:	00093703          	ld	a4,0(s2)
    8000632e:	00f704a3          	sb	a5,9(a4)
  (*f)->sock = si;
    80006332:	00093783          	ld	a5,0(s2)
    80006336:	0357b023          	sd	s5,32(a5) # f020020 <_entry-0x70fdffe0>

  // add to list of sockets
  acquire(&lock);
    8000633a:	00019517          	auipc	a0,0x19
    8000633e:	ff650513          	addi	a0,a0,-10 # 8001f330 <lock>
    80006342:	00001097          	auipc	ra,0x1
    80006346:	e2e080e7          	jalr	-466(ra) # 80007170 <acquire>
  pos = sockets;
    8000634a:	00004597          	auipc	a1,0x4
    8000634e:	cde5b583          	ld	a1,-802(a1) # 8000a028 <sockets>
  while (pos) {
    80006352:	c9b1                	beqz	a1,800063a6 <sockalloc+0xee>
  pos = sockets;
    80006354:	87ae                	mv	a5,a1
    if (pos->raddr == raddr &&
    80006356:	000a061b          	sext.w	a2,s4
        pos->lport == lport &&
    8000635a:	0009869b          	sext.w	a3,s3
    8000635e:	a019                	j	80006364 <sockalloc+0xac>
	pos->rport == rport) {
      release(&lock);
      goto bad;
    }
    pos = pos->next;
    80006360:	639c                	ld	a5,0(a5)
  while (pos) {
    80006362:	c3b1                	beqz	a5,800063a6 <sockalloc+0xee>
    if (pos->raddr == raddr &&
    80006364:	4798                	lw	a4,8(a5)
    80006366:	fe971de3          	bne	a4,s1,80006360 <sockalloc+0xa8>
    8000636a:	00c7d703          	lhu	a4,12(a5)
    8000636e:	fec719e3          	bne	a4,a2,80006360 <sockalloc+0xa8>
        pos->lport == lport &&
    80006372:	00e7d703          	lhu	a4,14(a5)
    80006376:	fed715e3          	bne	a4,a3,80006360 <sockalloc+0xa8>
      release(&lock);
    8000637a:	00019517          	auipc	a0,0x19
    8000637e:	fb650513          	addi	a0,a0,-74 # 8001f330 <lock>
    80006382:	00001097          	auipc	ra,0x1
    80006386:	ea2080e7          	jalr	-350(ra) # 80007224 <release>
  release(&lock);
  return 0;

bad:
  if (si)
    kfree((char*)si);
    8000638a:	8556                	mv	a0,s5
    8000638c:	ffffa097          	auipc	ra,0xffffa
    80006390:	c90080e7          	jalr	-880(ra) # 8000001c <kfree>
  if (*f)
    80006394:	00093503          	ld	a0,0(s2)
    80006398:	c129                	beqz	a0,800063da <sockalloc+0x122>
    fileclose(*f);
    8000639a:	ffffd097          	auipc	ra,0xffffd
    8000639e:	626080e7          	jalr	1574(ra) # 800039c0 <fileclose>
  return -1;
    800063a2:	557d                	li	a0,-1
    800063a4:	a005                	j	800063c4 <sockalloc+0x10c>
  si->next = sockets;
    800063a6:	00bab023          	sd	a1,0(s5)
  sockets = si;
    800063aa:	00004797          	auipc	a5,0x4
    800063ae:	c757bf23          	sd	s5,-898(a5) # 8000a028 <sockets>
  release(&lock);
    800063b2:	00019517          	auipc	a0,0x19
    800063b6:	f7e50513          	addi	a0,a0,-130 # 8001f330 <lock>
    800063ba:	00001097          	auipc	ra,0x1
    800063be:	e6a080e7          	jalr	-406(ra) # 80007224 <release>
  return 0;
    800063c2:	4501                	li	a0,0
}
    800063c4:	70e2                	ld	ra,56(sp)
    800063c6:	7442                	ld	s0,48(sp)
    800063c8:	74a2                	ld	s1,40(sp)
    800063ca:	7902                	ld	s2,32(sp)
    800063cc:	69e2                	ld	s3,24(sp)
    800063ce:	6a42                	ld	s4,16(sp)
    800063d0:	6aa2                	ld	s5,8(sp)
    800063d2:	6121                	addi	sp,sp,64
    800063d4:	8082                	ret
  return -1;
    800063d6:	557d                	li	a0,-1
    800063d8:	b7f5                	j	800063c4 <sockalloc+0x10c>
    800063da:	557d                	li	a0,-1
    800063dc:	b7e5                	j	800063c4 <sockalloc+0x10c>

00000000800063de <sockclose>:

void
sockclose(struct sock *si)
{
    800063de:	1101                	addi	sp,sp,-32
    800063e0:	ec06                	sd	ra,24(sp)
    800063e2:	e822                	sd	s0,16(sp)
    800063e4:	e426                	sd	s1,8(sp)
    800063e6:	e04a                	sd	s2,0(sp)
    800063e8:	1000                	addi	s0,sp,32
    800063ea:	892a                	mv	s2,a0
  struct sock **pos;
  struct mbuf *m;

  // remove from list of sockets
  acquire(&lock);
    800063ec:	00019517          	auipc	a0,0x19
    800063f0:	f4450513          	addi	a0,a0,-188 # 8001f330 <lock>
    800063f4:	00001097          	auipc	ra,0x1
    800063f8:	d7c080e7          	jalr	-644(ra) # 80007170 <acquire>
  pos = &sockets;
    800063fc:	00004797          	auipc	a5,0x4
    80006400:	c2c7b783          	ld	a5,-980(a5) # 8000a028 <sockets>
  while (*pos) {
    80006404:	cb99                	beqz	a5,8000641a <sockclose+0x3c>
    if (*pos == si){
    80006406:	04f90463          	beq	s2,a5,8000644e <sockclose+0x70>
      *pos = si->next;
      break;
    }
    pos = &(*pos)->next;
    8000640a:	873e                	mv	a4,a5
    8000640c:	639c                	ld	a5,0(a5)
  while (*pos) {
    8000640e:	c791                	beqz	a5,8000641a <sockclose+0x3c>
    if (*pos == si){
    80006410:	fef91de3          	bne	s2,a5,8000640a <sockclose+0x2c>
      *pos = si->next;
    80006414:	00093783          	ld	a5,0(s2)
    80006418:	e31c                	sd	a5,0(a4)
  }
  release(&lock);
    8000641a:	00019517          	auipc	a0,0x19
    8000641e:	f1650513          	addi	a0,a0,-234 # 8001f330 <lock>
    80006422:	00001097          	auipc	ra,0x1
    80006426:	e02080e7          	jalr	-510(ra) # 80007224 <release>

  // free any pending mbufs
  while (!mbufq_empty(&si->rxq)) {
    8000642a:	02890493          	addi	s1,s2,40
    8000642e:	8526                	mv	a0,s1
    80006430:	00000097          	auipc	ra,0x0
    80006434:	928080e7          	jalr	-1752(ra) # 80005d58 <mbufq_empty>
    80006438:	e105                	bnez	a0,80006458 <sockclose+0x7a>
    m = mbufq_pophead(&si->rxq);
    8000643a:	8526                	mv	a0,s1
    8000643c:	00000097          	auipc	ra,0x0
    80006440:	906080e7          	jalr	-1786(ra) # 80005d42 <mbufq_pophead>
    mbuffree(m);
    80006444:	00000097          	auipc	ra,0x0
    80006448:	8c6080e7          	jalr	-1850(ra) # 80005d0a <mbuffree>
    8000644c:	b7cd                	j	8000642e <sockclose+0x50>
  pos = &sockets;
    8000644e:	00004717          	auipc	a4,0x4
    80006452:	bda70713          	addi	a4,a4,-1062 # 8000a028 <sockets>
    80006456:	bf7d                	j	80006414 <sockclose+0x36>
  }

  kfree((char*)si);
    80006458:	854a                	mv	a0,s2
    8000645a:	ffffa097          	auipc	ra,0xffffa
    8000645e:	bc2080e7          	jalr	-1086(ra) # 8000001c <kfree>
}
    80006462:	60e2                	ld	ra,24(sp)
    80006464:	6442                	ld	s0,16(sp)
    80006466:	64a2                	ld	s1,8(sp)
    80006468:	6902                	ld	s2,0(sp)
    8000646a:	6105                	addi	sp,sp,32
    8000646c:	8082                	ret

000000008000646e <sockread>:

int
sockread(struct sock *si, uint64 addr, int n)
{
    8000646e:	7139                	addi	sp,sp,-64
    80006470:	fc06                	sd	ra,56(sp)
    80006472:	f822                	sd	s0,48(sp)
    80006474:	f426                	sd	s1,40(sp)
    80006476:	f04a                	sd	s2,32(sp)
    80006478:	ec4e                	sd	s3,24(sp)
    8000647a:	e852                	sd	s4,16(sp)
    8000647c:	e456                	sd	s5,8(sp)
    8000647e:	0080                	addi	s0,sp,64
    80006480:	84aa                	mv	s1,a0
    80006482:	8a2e                	mv	s4,a1
    80006484:	8ab2                	mv	s5,a2
  struct proc *pr = myproc();
    80006486:	ffffb097          	auipc	ra,0xffffb
    8000648a:	a3a080e7          	jalr	-1478(ra) # 80000ec0 <myproc>
    8000648e:	892a                	mv	s2,a0
  struct mbuf *m;
  int len;

  acquire(&si->lock);
    80006490:	01048993          	addi	s3,s1,16
    80006494:	854e                	mv	a0,s3
    80006496:	00001097          	auipc	ra,0x1
    8000649a:	cda080e7          	jalr	-806(ra) # 80007170 <acquire>
  while (mbufq_empty(&si->rxq) && !pr->killed) {
    8000649e:	02848493          	addi	s1,s1,40
    800064a2:	a039                	j	800064b0 <sockread+0x42>
    sleep(&si->rxq, &si->lock);
    800064a4:	85ce                	mv	a1,s3
    800064a6:	8526                	mv	a0,s1
    800064a8:	ffffb097          	auipc	ra,0xffffb
    800064ac:	22c080e7          	jalr	556(ra) # 800016d4 <sleep>
  while (mbufq_empty(&si->rxq) && !pr->killed) {
    800064b0:	8526                	mv	a0,s1
    800064b2:	00000097          	auipc	ra,0x0
    800064b6:	8a6080e7          	jalr	-1882(ra) # 80005d58 <mbufq_empty>
    800064ba:	c919                	beqz	a0,800064d0 <sockread+0x62>
    800064bc:	03092783          	lw	a5,48(s2)
    800064c0:	d3f5                	beqz	a5,800064a4 <sockread+0x36>
  }
  if (pr->killed) {
    release(&si->lock);
    800064c2:	854e                	mv	a0,s3
    800064c4:	00001097          	auipc	ra,0x1
    800064c8:	d60080e7          	jalr	-672(ra) # 80007224 <release>
    return -1;
    800064cc:	59fd                	li	s3,-1
    800064ce:	a0b9                	j	8000651c <sockread+0xae>
  if (pr->killed) {
    800064d0:	03092783          	lw	a5,48(s2)
    800064d4:	f7fd                	bnez	a5,800064c2 <sockread+0x54>
  }
  m = mbufq_pophead(&si->rxq);
    800064d6:	8526                	mv	a0,s1
    800064d8:	00000097          	auipc	ra,0x0
    800064dc:	86a080e7          	jalr	-1942(ra) # 80005d42 <mbufq_pophead>
    800064e0:	84aa                	mv	s1,a0
  release(&si->lock);
    800064e2:	854e                	mv	a0,s3
    800064e4:	00001097          	auipc	ra,0x1
    800064e8:	d40080e7          	jalr	-704(ra) # 80007224 <release>

  len = m->len;
    800064ec:	489c                	lw	a5,16(s1)
  if (len > n)
    800064ee:	89be                	mv	s3,a5
    800064f0:	00fad363          	bge	s5,a5,800064f6 <sockread+0x88>
    800064f4:	89d6                	mv	s3,s5
    800064f6:	2981                	sext.w	s3,s3
    len = n;
  if (copyout(pr->pagetable, addr, m->head, len) == -1) {
    800064f8:	86ce                	mv	a3,s3
    800064fa:	6490                	ld	a2,8(s1)
    800064fc:	85d2                	mv	a1,s4
    800064fe:	05093503          	ld	a0,80(s2)
    80006502:	ffffa097          	auipc	ra,0xffffa
    80006506:	652080e7          	jalr	1618(ra) # 80000b54 <copyout>
    8000650a:	892a                	mv	s2,a0
    8000650c:	57fd                	li	a5,-1
    8000650e:	02f50163          	beq	a0,a5,80006530 <sockread+0xc2>
    mbuffree(m);
    return -1;
  }
  mbuffree(m);
    80006512:	8526                	mv	a0,s1
    80006514:	fffff097          	auipc	ra,0xfffff
    80006518:	7f6080e7          	jalr	2038(ra) # 80005d0a <mbuffree>
  return len;
}
    8000651c:	854e                	mv	a0,s3
    8000651e:	70e2                	ld	ra,56(sp)
    80006520:	7442                	ld	s0,48(sp)
    80006522:	74a2                	ld	s1,40(sp)
    80006524:	7902                	ld	s2,32(sp)
    80006526:	69e2                	ld	s3,24(sp)
    80006528:	6a42                	ld	s4,16(sp)
    8000652a:	6aa2                	ld	s5,8(sp)
    8000652c:	6121                	addi	sp,sp,64
    8000652e:	8082                	ret
    mbuffree(m);
    80006530:	8526                	mv	a0,s1
    80006532:	fffff097          	auipc	ra,0xfffff
    80006536:	7d8080e7          	jalr	2008(ra) # 80005d0a <mbuffree>
    return -1;
    8000653a:	89ca                	mv	s3,s2
    8000653c:	b7c5                	j	8000651c <sockread+0xae>

000000008000653e <sockwrite>:

int
sockwrite(struct sock *si, uint64 addr, int n)
{
    8000653e:	7139                	addi	sp,sp,-64
    80006540:	fc06                	sd	ra,56(sp)
    80006542:	f822                	sd	s0,48(sp)
    80006544:	f426                	sd	s1,40(sp)
    80006546:	f04a                	sd	s2,32(sp)
    80006548:	ec4e                	sd	s3,24(sp)
    8000654a:	e852                	sd	s4,16(sp)
    8000654c:	e456                	sd	s5,8(sp)
    8000654e:	0080                	addi	s0,sp,64
    80006550:	8aaa                	mv	s5,a0
    80006552:	89ae                	mv	s3,a1
    80006554:	8932                	mv	s2,a2
  struct proc *pr = myproc();
    80006556:	ffffb097          	auipc	ra,0xffffb
    8000655a:	96a080e7          	jalr	-1686(ra) # 80000ec0 <myproc>
    8000655e:	8a2a                	mv	s4,a0
  struct mbuf *m;

  m = mbufalloc(MBUF_DEFAULT_HEADROOM);
    80006560:	08000513          	li	a0,128
    80006564:	fffff097          	auipc	ra,0xfffff
    80006568:	74e080e7          	jalr	1870(ra) # 80005cb2 <mbufalloc>
  if (!m)
    8000656c:	c12d                	beqz	a0,800065ce <sockwrite+0x90>
    8000656e:	84aa                	mv	s1,a0
    return -1;

  if (copyin(pr->pagetable, mbufput(m, n), addr, n) == -1) {
    80006570:	050a3a03          	ld	s4,80(s4) # 3050 <_entry-0x7fffcfb0>
    80006574:	85ca                	mv	a1,s2
    80006576:	fffff097          	auipc	ra,0xfffff
    8000657a:	6e0080e7          	jalr	1760(ra) # 80005c56 <mbufput>
    8000657e:	85aa                	mv	a1,a0
    80006580:	86ca                	mv	a3,s2
    80006582:	864e                	mv	a2,s3
    80006584:	8552                	mv	a0,s4
    80006586:	ffffa097          	auipc	ra,0xffffa
    8000658a:	65a080e7          	jalr	1626(ra) # 80000be0 <copyin>
    8000658e:	89aa                	mv	s3,a0
    80006590:	57fd                	li	a5,-1
    80006592:	02f50863          	beq	a0,a5,800065c2 <sockwrite+0x84>
    mbuffree(m);
    return -1;
  }
  net_tx_udp(m, si->raddr, si->lport, si->rport);
    80006596:	00ead683          	lhu	a3,14(s5)
    8000659a:	00cad603          	lhu	a2,12(s5)
    8000659e:	008aa583          	lw	a1,8(s5)
    800065a2:	8526                	mv	a0,s1
    800065a4:	fffff097          	auipc	ra,0xfffff
    800065a8:	7d6080e7          	jalr	2006(ra) # 80005d7a <net_tx_udp>
  return n;
    800065ac:	89ca                	mv	s3,s2
}
    800065ae:	854e                	mv	a0,s3
    800065b0:	70e2                	ld	ra,56(sp)
    800065b2:	7442                	ld	s0,48(sp)
    800065b4:	74a2                	ld	s1,40(sp)
    800065b6:	7902                	ld	s2,32(sp)
    800065b8:	69e2                	ld	s3,24(sp)
    800065ba:	6a42                	ld	s4,16(sp)
    800065bc:	6aa2                	ld	s5,8(sp)
    800065be:	6121                	addi	sp,sp,64
    800065c0:	8082                	ret
    mbuffree(m);
    800065c2:	8526                	mv	a0,s1
    800065c4:	fffff097          	auipc	ra,0xfffff
    800065c8:	746080e7          	jalr	1862(ra) # 80005d0a <mbuffree>
    return -1;
    800065cc:	b7cd                	j	800065ae <sockwrite+0x70>
    return -1;
    800065ce:	59fd                	li	s3,-1
    800065d0:	bff9                	j	800065ae <sockwrite+0x70>

00000000800065d2 <sockrecvudp>:

// called by protocol handler layer to deliver UDP packets
void
sockrecvudp(struct mbuf *m, uint32 raddr, uint16 lport, uint16 rport)
{
    800065d2:	7139                	addi	sp,sp,-64
    800065d4:	fc06                	sd	ra,56(sp)
    800065d6:	f822                	sd	s0,48(sp)
    800065d8:	f426                	sd	s1,40(sp)
    800065da:	f04a                	sd	s2,32(sp)
    800065dc:	ec4e                	sd	s3,24(sp)
    800065de:	e852                	sd	s4,16(sp)
    800065e0:	e456                	sd	s5,8(sp)
    800065e2:	0080                	addi	s0,sp,64
    800065e4:	8a2a                	mv	s4,a0
    800065e6:	892e                	mv	s2,a1
    800065e8:	89b2                	mv	s3,a2
    800065ea:	8ab6                	mv	s5,a3
  // any sleeping reader. Free the mbuf if there are no sockets
  // registered to handle it.
  //
  struct sock *si;

  acquire(&lock);
    800065ec:	00019517          	auipc	a0,0x19
    800065f0:	d4450513          	addi	a0,a0,-700 # 8001f330 <lock>
    800065f4:	00001097          	auipc	ra,0x1
    800065f8:	b7c080e7          	jalr	-1156(ra) # 80007170 <acquire>
  si = sockets;
    800065fc:	00004497          	auipc	s1,0x4
    80006600:	a2c4b483          	ld	s1,-1492(s1) # 8000a028 <sockets>
  while (si) {
    80006604:	c4ad                	beqz	s1,8000666e <sockrecvudp+0x9c>
    if (si->raddr == raddr && si->lport == lport && si->rport == rport)
    80006606:	0009871b          	sext.w	a4,s3
    8000660a:	000a869b          	sext.w	a3,s5
    8000660e:	a019                	j	80006614 <sockrecvudp+0x42>
      goto found;
    si = si->next;
    80006610:	6084                	ld	s1,0(s1)
  while (si) {
    80006612:	ccb1                	beqz	s1,8000666e <sockrecvudp+0x9c>
    if (si->raddr == raddr && si->lport == lport && si->rport == rport)
    80006614:	449c                	lw	a5,8(s1)
    80006616:	ff279de3          	bne	a5,s2,80006610 <sockrecvudp+0x3e>
    8000661a:	00c4d783          	lhu	a5,12(s1)
    8000661e:	fee799e3          	bne	a5,a4,80006610 <sockrecvudp+0x3e>
    80006622:	00e4d783          	lhu	a5,14(s1)
    80006626:	fed795e3          	bne	a5,a3,80006610 <sockrecvudp+0x3e>
  release(&lock);
  mbuffree(m);
  return;

found:
  acquire(&si->lock);
    8000662a:	01048913          	addi	s2,s1,16
    8000662e:	854a                	mv	a0,s2
    80006630:	00001097          	auipc	ra,0x1
    80006634:	b40080e7          	jalr	-1216(ra) # 80007170 <acquire>
  mbufq_pushtail(&si->rxq, m);
    80006638:	02848493          	addi	s1,s1,40
    8000663c:	85d2                	mv	a1,s4
    8000663e:	8526                	mv	a0,s1
    80006640:	fffff097          	auipc	ra,0xfffff
    80006644:	6e2080e7          	jalr	1762(ra) # 80005d22 <mbufq_pushtail>
  wakeup(&si->rxq);
    80006648:	8526                	mv	a0,s1
    8000664a:	ffffb097          	auipc	ra,0xffffb
    8000664e:	20a080e7          	jalr	522(ra) # 80001854 <wakeup>
  release(&si->lock);
    80006652:	854a                	mv	a0,s2
    80006654:	00001097          	auipc	ra,0x1
    80006658:	bd0080e7          	jalr	-1072(ra) # 80007224 <release>
  release(&lock);
    8000665c:	00019517          	auipc	a0,0x19
    80006660:	cd450513          	addi	a0,a0,-812 # 8001f330 <lock>
    80006664:	00001097          	auipc	ra,0x1
    80006668:	bc0080e7          	jalr	-1088(ra) # 80007224 <release>
    8000666c:	a831                	j	80006688 <sockrecvudp+0xb6>
  release(&lock);
    8000666e:	00019517          	auipc	a0,0x19
    80006672:	cc250513          	addi	a0,a0,-830 # 8001f330 <lock>
    80006676:	00001097          	auipc	ra,0x1
    8000667a:	bae080e7          	jalr	-1106(ra) # 80007224 <release>
  mbuffree(m);
    8000667e:	8552                	mv	a0,s4
    80006680:	fffff097          	auipc	ra,0xfffff
    80006684:	68a080e7          	jalr	1674(ra) # 80005d0a <mbuffree>
}
    80006688:	70e2                	ld	ra,56(sp)
    8000668a:	7442                	ld	s0,48(sp)
    8000668c:	74a2                	ld	s1,40(sp)
    8000668e:	7902                	ld	s2,32(sp)
    80006690:	69e2                	ld	s3,24(sp)
    80006692:	6a42                	ld	s4,16(sp)
    80006694:	6aa2                	ld	s5,8(sp)
    80006696:	6121                	addi	sp,sp,64
    80006698:	8082                	ret

000000008000669a <pci_init>:
#include "proc.h"
#include "defs.h"

void
pci_init()
{
    8000669a:	715d                	addi	sp,sp,-80
    8000669c:	e486                	sd	ra,72(sp)
    8000669e:	e0a2                	sd	s0,64(sp)
    800066a0:	fc26                	sd	s1,56(sp)
    800066a2:	f84a                	sd	s2,48(sp)
    800066a4:	f44e                	sd	s3,40(sp)
    800066a6:	f052                	sd	s4,32(sp)
    800066a8:	ec56                	sd	s5,24(sp)
    800066aa:	e85a                	sd	s6,16(sp)
    800066ac:	e45e                	sd	s7,8(sp)
    800066ae:	0880                	addi	s0,sp,80
    800066b0:	300004b7          	lui	s1,0x30000
    uint32 off = (bus << 16) | (dev << 11) | (func << 8) | (offset);
    volatile uint32 *base = ecam + off;
    uint32 id = base[0];
    
    // 100e:8086 is an e1000
    if(id == 0x100e8086){
    800066b4:	100e8937          	lui	s2,0x100e8
    800066b8:	08690913          	addi	s2,s2,134 # 100e8086 <_entry-0x6ff17f7a>
      // command and status register.
      // bit 0 : I/O access enable
      // bit 1 : memory access enable
      // bit 2 : enable mastering
      base[1] = 7;
    800066bc:	4b9d                	li	s7,7
      for(int i = 0; i < 6; i++){
        uint32 old = base[4+i];

        // writing all 1's to the BAR causes it to be
        // replaced with its size.
        base[4+i] = 0xffffffff;
    800066be:	5afd                	li	s5,-1
        base[4+i] = old;
      }

      // tell the e1000 to reveal its registers at
      // physical address 0x40000000.
      base[4+0] = e1000_regs;
    800066c0:	40000b37          	lui	s6,0x40000
  for(int dev = 0; dev < 32; dev++){
    800066c4:	6a09                	lui	s4,0x2
    800066c6:	300409b7          	lui	s3,0x30040
    800066ca:	a819                	j	800066e0 <pci_init+0x46>
      base[4+0] = e1000_regs;
    800066cc:	0166a823          	sw	s6,16(a3)

      e1000_init((uint32*)e1000_regs);
    800066d0:	855a                	mv	a0,s6
    800066d2:	fffff097          	auipc	ra,0xfffff
    800066d6:	080080e7          	jalr	128(ra) # 80005752 <e1000_init>
  for(int dev = 0; dev < 32; dev++){
    800066da:	94d2                	add	s1,s1,s4
    800066dc:	03348a63          	beq	s1,s3,80006710 <pci_init+0x76>
    volatile uint32 *base = ecam + off;
    800066e0:	86a6                	mv	a3,s1
    uint32 id = base[0];
    800066e2:	409c                	lw	a5,0(s1)
    800066e4:	2781                	sext.w	a5,a5
    if(id == 0x100e8086){
    800066e6:	ff279ae3          	bne	a5,s2,800066da <pci_init+0x40>
      base[1] = 7;
    800066ea:	0174a223          	sw	s7,4(s1) # 30000004 <_entry-0x4ffffffc>
      __sync_synchronize();
    800066ee:	0ff0000f          	fence
      for(int i = 0; i < 6; i++){
    800066f2:	01048793          	addi	a5,s1,16
    800066f6:	02848613          	addi	a2,s1,40
        uint32 old = base[4+i];
    800066fa:	4398                	lw	a4,0(a5)
    800066fc:	2701                	sext.w	a4,a4
        base[4+i] = 0xffffffff;
    800066fe:	0157a023          	sw	s5,0(a5)
        __sync_synchronize();
    80006702:	0ff0000f          	fence
        base[4+i] = old;
    80006706:	c398                	sw	a4,0(a5)
      for(int i = 0; i < 6; i++){
    80006708:	0791                	addi	a5,a5,4
    8000670a:	fec798e3          	bne	a5,a2,800066fa <pci_init+0x60>
    8000670e:	bf7d                	j	800066cc <pci_init+0x32>
    }
  }
}
    80006710:	60a6                	ld	ra,72(sp)
    80006712:	6406                	ld	s0,64(sp)
    80006714:	74e2                	ld	s1,56(sp)
    80006716:	7942                	ld	s2,48(sp)
    80006718:	79a2                	ld	s3,40(sp)
    8000671a:	7a02                	ld	s4,32(sp)
    8000671c:	6ae2                	ld	s5,24(sp)
    8000671e:	6b42                	ld	s6,16(sp)
    80006720:	6ba2                	ld	s7,8(sp)
    80006722:	6161                	addi	sp,sp,80
    80006724:	8082                	ret

0000000080006726 <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    80006726:	1141                	addi	sp,sp,-16
    80006728:	e422                	sd	s0,8(sp)
    8000672a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    8000672c:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80006730:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80006734:	0037979b          	slliw	a5,a5,0x3
    80006738:	02004737          	lui	a4,0x2004
    8000673c:	97ba                	add	a5,a5,a4
    8000673e:	0200c737          	lui	a4,0x200c
    80006742:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80006746:	000f4637          	lui	a2,0xf4
    8000674a:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    8000674e:	95b2                	add	a1,a1,a2
    80006750:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80006752:	00269713          	slli	a4,a3,0x2
    80006756:	9736                	add	a4,a4,a3
    80006758:	00371693          	slli	a3,a4,0x3
    8000675c:	00019717          	auipc	a4,0x19
    80006760:	bf470713          	addi	a4,a4,-1036 # 8001f350 <timer_scratch>
    80006764:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    80006766:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    80006768:	f310                	sd	a2,32(a4)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000676a:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000676e:	fffff797          	auipc	a5,0xfffff
    80006772:	9d278793          	addi	a5,a5,-1582 # 80005140 <timervec>
    80006776:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000677a:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000677e:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80006782:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80006786:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000678a:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000678e:	30479073          	csrw	mie,a5
}
    80006792:	6422                	ld	s0,8(sp)
    80006794:	0141                	addi	sp,sp,16
    80006796:	8082                	ret

0000000080006798 <start>:
{
    80006798:	1141                	addi	sp,sp,-16
    8000679a:	e406                	sd	ra,8(sp)
    8000679c:	e022                	sd	s0,0(sp)
    8000679e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    800067a0:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    800067a4:	7779                	lui	a4,0xffffe
    800067a6:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd726f>
    800067aa:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800067ac:	6705                	lui	a4,0x1
    800067ae:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800067b2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800067b4:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800067b8:	ffffa797          	auipc	a5,0xffffa
    800067bc:	b6e78793          	addi	a5,a5,-1170 # 80000326 <main>
    800067c0:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800067c4:	4781                	li	a5,0
    800067c6:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800067ca:	67c1                	lui	a5,0x10
    800067cc:	17fd                	addi	a5,a5,-1
    800067ce:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800067d2:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800067d6:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800067da:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800067de:	10479073          	csrw	sie,a5
  timerinit();
    800067e2:	00000097          	auipc	ra,0x0
    800067e6:	f44080e7          	jalr	-188(ra) # 80006726 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800067ea:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800067ee:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    800067f0:	823e                	mv	tp,a5
  asm volatile("mret");
    800067f2:	30200073          	mret
}
    800067f6:	60a2                	ld	ra,8(sp)
    800067f8:	6402                	ld	s0,0(sp)
    800067fa:	0141                	addi	sp,sp,16
    800067fc:	8082                	ret

00000000800067fe <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800067fe:	715d                	addi	sp,sp,-80
    80006800:	e486                	sd	ra,72(sp)
    80006802:	e0a2                	sd	s0,64(sp)
    80006804:	fc26                	sd	s1,56(sp)
    80006806:	f84a                	sd	s2,48(sp)
    80006808:	f44e                	sd	s3,40(sp)
    8000680a:	f052                	sd	s4,32(sp)
    8000680c:	ec56                	sd	s5,24(sp)
    8000680e:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80006810:	04c05663          	blez	a2,8000685c <consolewrite+0x5e>
    80006814:	8a2a                	mv	s4,a0
    80006816:	84ae                	mv	s1,a1
    80006818:	89b2                	mv	s3,a2
    8000681a:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000681c:	5afd                	li	s5,-1
    8000681e:	4685                	li	a3,1
    80006820:	8626                	mv	a2,s1
    80006822:	85d2                	mv	a1,s4
    80006824:	fbf40513          	addi	a0,s0,-65
    80006828:	ffffb097          	auipc	ra,0xffffb
    8000682c:	15c080e7          	jalr	348(ra) # 80001984 <either_copyin>
    80006830:	01550c63          	beq	a0,s5,80006848 <consolewrite+0x4a>
      break;
    uartputc(c);
    80006834:	fbf44503          	lbu	a0,-65(s0)
    80006838:	00000097          	auipc	ra,0x0
    8000683c:	77a080e7          	jalr	1914(ra) # 80006fb2 <uartputc>
  for(i = 0; i < n; i++){
    80006840:	2905                	addiw	s2,s2,1
    80006842:	0485                	addi	s1,s1,1
    80006844:	fd299de3          	bne	s3,s2,8000681e <consolewrite+0x20>
  }

  return i;
}
    80006848:	854a                	mv	a0,s2
    8000684a:	60a6                	ld	ra,72(sp)
    8000684c:	6406                	ld	s0,64(sp)
    8000684e:	74e2                	ld	s1,56(sp)
    80006850:	7942                	ld	s2,48(sp)
    80006852:	79a2                	ld	s3,40(sp)
    80006854:	7a02                	ld	s4,32(sp)
    80006856:	6ae2                	ld	s5,24(sp)
    80006858:	6161                	addi	sp,sp,80
    8000685a:	8082                	ret
  for(i = 0; i < n; i++){
    8000685c:	4901                	li	s2,0
    8000685e:	b7ed                	j	80006848 <consolewrite+0x4a>

0000000080006860 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80006860:	7159                	addi	sp,sp,-112
    80006862:	f486                	sd	ra,104(sp)
    80006864:	f0a2                	sd	s0,96(sp)
    80006866:	eca6                	sd	s1,88(sp)
    80006868:	e8ca                	sd	s2,80(sp)
    8000686a:	e4ce                	sd	s3,72(sp)
    8000686c:	e0d2                	sd	s4,64(sp)
    8000686e:	fc56                	sd	s5,56(sp)
    80006870:	f85a                	sd	s6,48(sp)
    80006872:	f45e                	sd	s7,40(sp)
    80006874:	f062                	sd	s8,32(sp)
    80006876:	ec66                	sd	s9,24(sp)
    80006878:	e86a                	sd	s10,16(sp)
    8000687a:	1880                	addi	s0,sp,112
    8000687c:	8aaa                	mv	s5,a0
    8000687e:	8a2e                	mv	s4,a1
    80006880:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80006882:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80006886:	00021517          	auipc	a0,0x21
    8000688a:	c0a50513          	addi	a0,a0,-1014 # 80027490 <cons>
    8000688e:	00001097          	auipc	ra,0x1
    80006892:	8e2080e7          	jalr	-1822(ra) # 80007170 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80006896:	00021497          	auipc	s1,0x21
    8000689a:	bfa48493          	addi	s1,s1,-1030 # 80027490 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000689e:	00021917          	auipc	s2,0x21
    800068a2:	c8a90913          	addi	s2,s2,-886 # 80027528 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800068a6:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800068a8:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800068aa:	4ca9                	li	s9,10
  while(n > 0){
    800068ac:	07305863          	blez	s3,8000691c <consoleread+0xbc>
    while(cons.r == cons.w){
    800068b0:	0984a783          	lw	a5,152(s1)
    800068b4:	09c4a703          	lw	a4,156(s1)
    800068b8:	02f71463          	bne	a4,a5,800068e0 <consoleread+0x80>
      if(myproc()->killed){
    800068bc:	ffffa097          	auipc	ra,0xffffa
    800068c0:	604080e7          	jalr	1540(ra) # 80000ec0 <myproc>
    800068c4:	591c                	lw	a5,48(a0)
    800068c6:	e7b5                	bnez	a5,80006932 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800068c8:	85a6                	mv	a1,s1
    800068ca:	854a                	mv	a0,s2
    800068cc:	ffffb097          	auipc	ra,0xffffb
    800068d0:	e08080e7          	jalr	-504(ra) # 800016d4 <sleep>
    while(cons.r == cons.w){
    800068d4:	0984a783          	lw	a5,152(s1)
    800068d8:	09c4a703          	lw	a4,156(s1)
    800068dc:	fef700e3          	beq	a4,a5,800068bc <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800068e0:	0017871b          	addiw	a4,a5,1
    800068e4:	08e4ac23          	sw	a4,152(s1)
    800068e8:	07f7f713          	andi	a4,a5,127
    800068ec:	9726                	add	a4,a4,s1
    800068ee:	01874703          	lbu	a4,24(a4)
    800068f2:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800068f6:	077d0563          	beq	s10,s7,80006960 <consoleread+0x100>
    cbuf = c;
    800068fa:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800068fe:	4685                	li	a3,1
    80006900:	f9f40613          	addi	a2,s0,-97
    80006904:	85d2                	mv	a1,s4
    80006906:	8556                	mv	a0,s5
    80006908:	ffffb097          	auipc	ra,0xffffb
    8000690c:	026080e7          	jalr	38(ra) # 8000192e <either_copyout>
    80006910:	01850663          	beq	a0,s8,8000691c <consoleread+0xbc>
    dst++;
    80006914:	0a05                	addi	s4,s4,1
    --n;
    80006916:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80006918:	f99d1ae3          	bne	s10,s9,800068ac <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000691c:	00021517          	auipc	a0,0x21
    80006920:	b7450513          	addi	a0,a0,-1164 # 80027490 <cons>
    80006924:	00001097          	auipc	ra,0x1
    80006928:	900080e7          	jalr	-1792(ra) # 80007224 <release>

  return target - n;
    8000692c:	413b053b          	subw	a0,s6,s3
    80006930:	a811                	j	80006944 <consoleread+0xe4>
        release(&cons.lock);
    80006932:	00021517          	auipc	a0,0x21
    80006936:	b5e50513          	addi	a0,a0,-1186 # 80027490 <cons>
    8000693a:	00001097          	auipc	ra,0x1
    8000693e:	8ea080e7          	jalr	-1814(ra) # 80007224 <release>
        return -1;
    80006942:	557d                	li	a0,-1
}
    80006944:	70a6                	ld	ra,104(sp)
    80006946:	7406                	ld	s0,96(sp)
    80006948:	64e6                	ld	s1,88(sp)
    8000694a:	6946                	ld	s2,80(sp)
    8000694c:	69a6                	ld	s3,72(sp)
    8000694e:	6a06                	ld	s4,64(sp)
    80006950:	7ae2                	ld	s5,56(sp)
    80006952:	7b42                	ld	s6,48(sp)
    80006954:	7ba2                	ld	s7,40(sp)
    80006956:	7c02                	ld	s8,32(sp)
    80006958:	6ce2                	ld	s9,24(sp)
    8000695a:	6d42                	ld	s10,16(sp)
    8000695c:	6165                	addi	sp,sp,112
    8000695e:	8082                	ret
      if(n < target){
    80006960:	0009871b          	sext.w	a4,s3
    80006964:	fb677ce3          	bgeu	a4,s6,8000691c <consoleread+0xbc>
        cons.r--;
    80006968:	00021717          	auipc	a4,0x21
    8000696c:	bcf72023          	sw	a5,-1088(a4) # 80027528 <cons+0x98>
    80006970:	b775                	j	8000691c <consoleread+0xbc>

0000000080006972 <consputc>:
{
    80006972:	1141                	addi	sp,sp,-16
    80006974:	e406                	sd	ra,8(sp)
    80006976:	e022                	sd	s0,0(sp)
    80006978:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000697a:	10000793          	li	a5,256
    8000697e:	00f50a63          	beq	a0,a5,80006992 <consputc+0x20>
    uartputc_sync(c);
    80006982:	00000097          	auipc	ra,0x0
    80006986:	55e080e7          	jalr	1374(ra) # 80006ee0 <uartputc_sync>
}
    8000698a:	60a2                	ld	ra,8(sp)
    8000698c:	6402                	ld	s0,0(sp)
    8000698e:	0141                	addi	sp,sp,16
    80006990:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80006992:	4521                	li	a0,8
    80006994:	00000097          	auipc	ra,0x0
    80006998:	54c080e7          	jalr	1356(ra) # 80006ee0 <uartputc_sync>
    8000699c:	02000513          	li	a0,32
    800069a0:	00000097          	auipc	ra,0x0
    800069a4:	540080e7          	jalr	1344(ra) # 80006ee0 <uartputc_sync>
    800069a8:	4521                	li	a0,8
    800069aa:	00000097          	auipc	ra,0x0
    800069ae:	536080e7          	jalr	1334(ra) # 80006ee0 <uartputc_sync>
    800069b2:	bfe1                	j	8000698a <consputc+0x18>

00000000800069b4 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800069b4:	1101                	addi	sp,sp,-32
    800069b6:	ec06                	sd	ra,24(sp)
    800069b8:	e822                	sd	s0,16(sp)
    800069ba:	e426                	sd	s1,8(sp)
    800069bc:	e04a                	sd	s2,0(sp)
    800069be:	1000                	addi	s0,sp,32
    800069c0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800069c2:	00021517          	auipc	a0,0x21
    800069c6:	ace50513          	addi	a0,a0,-1330 # 80027490 <cons>
    800069ca:	00000097          	auipc	ra,0x0
    800069ce:	7a6080e7          	jalr	1958(ra) # 80007170 <acquire>

  switch(c){
    800069d2:	47d5                	li	a5,21
    800069d4:	0af48663          	beq	s1,a5,80006a80 <consoleintr+0xcc>
    800069d8:	0297ca63          	blt	a5,s1,80006a0c <consoleintr+0x58>
    800069dc:	47a1                	li	a5,8
    800069de:	0ef48763          	beq	s1,a5,80006acc <consoleintr+0x118>
    800069e2:	47c1                	li	a5,16
    800069e4:	10f49a63          	bne	s1,a5,80006af8 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800069e8:	ffffb097          	auipc	ra,0xffffb
    800069ec:	ff2080e7          	jalr	-14(ra) # 800019da <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800069f0:	00021517          	auipc	a0,0x21
    800069f4:	aa050513          	addi	a0,a0,-1376 # 80027490 <cons>
    800069f8:	00001097          	auipc	ra,0x1
    800069fc:	82c080e7          	jalr	-2004(ra) # 80007224 <release>
}
    80006a00:	60e2                	ld	ra,24(sp)
    80006a02:	6442                	ld	s0,16(sp)
    80006a04:	64a2                	ld	s1,8(sp)
    80006a06:	6902                	ld	s2,0(sp)
    80006a08:	6105                	addi	sp,sp,32
    80006a0a:	8082                	ret
  switch(c){
    80006a0c:	07f00793          	li	a5,127
    80006a10:	0af48e63          	beq	s1,a5,80006acc <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80006a14:	00021717          	auipc	a4,0x21
    80006a18:	a7c70713          	addi	a4,a4,-1412 # 80027490 <cons>
    80006a1c:	0a072783          	lw	a5,160(a4)
    80006a20:	09872703          	lw	a4,152(a4)
    80006a24:	9f99                	subw	a5,a5,a4
    80006a26:	07f00713          	li	a4,127
    80006a2a:	fcf763e3          	bltu	a4,a5,800069f0 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80006a2e:	47b5                	li	a5,13
    80006a30:	0cf48763          	beq	s1,a5,80006afe <consoleintr+0x14a>
      consputc(c);
    80006a34:	8526                	mv	a0,s1
    80006a36:	00000097          	auipc	ra,0x0
    80006a3a:	f3c080e7          	jalr	-196(ra) # 80006972 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80006a3e:	00021797          	auipc	a5,0x21
    80006a42:	a5278793          	addi	a5,a5,-1454 # 80027490 <cons>
    80006a46:	0a07a703          	lw	a4,160(a5)
    80006a4a:	0017069b          	addiw	a3,a4,1
    80006a4e:	0006861b          	sext.w	a2,a3
    80006a52:	0ad7a023          	sw	a3,160(a5)
    80006a56:	07f77713          	andi	a4,a4,127
    80006a5a:	97ba                	add	a5,a5,a4
    80006a5c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80006a60:	47a9                	li	a5,10
    80006a62:	0cf48563          	beq	s1,a5,80006b2c <consoleintr+0x178>
    80006a66:	4791                	li	a5,4
    80006a68:	0cf48263          	beq	s1,a5,80006b2c <consoleintr+0x178>
    80006a6c:	00021797          	auipc	a5,0x21
    80006a70:	abc7a783          	lw	a5,-1348(a5) # 80027528 <cons+0x98>
    80006a74:	0807879b          	addiw	a5,a5,128
    80006a78:	f6f61ce3          	bne	a2,a5,800069f0 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80006a7c:	863e                	mv	a2,a5
    80006a7e:	a07d                	j	80006b2c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80006a80:	00021717          	auipc	a4,0x21
    80006a84:	a1070713          	addi	a4,a4,-1520 # 80027490 <cons>
    80006a88:	0a072783          	lw	a5,160(a4)
    80006a8c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80006a90:	00021497          	auipc	s1,0x21
    80006a94:	a0048493          	addi	s1,s1,-1536 # 80027490 <cons>
    while(cons.e != cons.w &&
    80006a98:	4929                	li	s2,10
    80006a9a:	f4f70be3          	beq	a4,a5,800069f0 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80006a9e:	37fd                	addiw	a5,a5,-1
    80006aa0:	07f7f713          	andi	a4,a5,127
    80006aa4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80006aa6:	01874703          	lbu	a4,24(a4)
    80006aaa:	f52703e3          	beq	a4,s2,800069f0 <consoleintr+0x3c>
      cons.e--;
    80006aae:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80006ab2:	10000513          	li	a0,256
    80006ab6:	00000097          	auipc	ra,0x0
    80006aba:	ebc080e7          	jalr	-324(ra) # 80006972 <consputc>
    while(cons.e != cons.w &&
    80006abe:	0a04a783          	lw	a5,160(s1)
    80006ac2:	09c4a703          	lw	a4,156(s1)
    80006ac6:	fcf71ce3          	bne	a4,a5,80006a9e <consoleintr+0xea>
    80006aca:	b71d                	j	800069f0 <consoleintr+0x3c>
    if(cons.e != cons.w){
    80006acc:	00021717          	auipc	a4,0x21
    80006ad0:	9c470713          	addi	a4,a4,-1596 # 80027490 <cons>
    80006ad4:	0a072783          	lw	a5,160(a4)
    80006ad8:	09c72703          	lw	a4,156(a4)
    80006adc:	f0f70ae3          	beq	a4,a5,800069f0 <consoleintr+0x3c>
      cons.e--;
    80006ae0:	37fd                	addiw	a5,a5,-1
    80006ae2:	00021717          	auipc	a4,0x21
    80006ae6:	a4f72723          	sw	a5,-1458(a4) # 80027530 <cons+0xa0>
      consputc(BACKSPACE);
    80006aea:	10000513          	li	a0,256
    80006aee:	00000097          	auipc	ra,0x0
    80006af2:	e84080e7          	jalr	-380(ra) # 80006972 <consputc>
    80006af6:	bded                	j	800069f0 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80006af8:	ee048ce3          	beqz	s1,800069f0 <consoleintr+0x3c>
    80006afc:	bf21                	j	80006a14 <consoleintr+0x60>
      consputc(c);
    80006afe:	4529                	li	a0,10
    80006b00:	00000097          	auipc	ra,0x0
    80006b04:	e72080e7          	jalr	-398(ra) # 80006972 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80006b08:	00021797          	auipc	a5,0x21
    80006b0c:	98878793          	addi	a5,a5,-1656 # 80027490 <cons>
    80006b10:	0a07a703          	lw	a4,160(a5)
    80006b14:	0017069b          	addiw	a3,a4,1
    80006b18:	0006861b          	sext.w	a2,a3
    80006b1c:	0ad7a023          	sw	a3,160(a5)
    80006b20:	07f77713          	andi	a4,a4,127
    80006b24:	97ba                	add	a5,a5,a4
    80006b26:	4729                	li	a4,10
    80006b28:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80006b2c:	00021797          	auipc	a5,0x21
    80006b30:	a0c7a023          	sw	a2,-1536(a5) # 8002752c <cons+0x9c>
        wakeup(&cons.r);
    80006b34:	00021517          	auipc	a0,0x21
    80006b38:	9f450513          	addi	a0,a0,-1548 # 80027528 <cons+0x98>
    80006b3c:	ffffb097          	auipc	ra,0xffffb
    80006b40:	d18080e7          	jalr	-744(ra) # 80001854 <wakeup>
    80006b44:	b575                	j	800069f0 <consoleintr+0x3c>

0000000080006b46 <consoleinit>:

void
consoleinit(void)
{
    80006b46:	1141                	addi	sp,sp,-16
    80006b48:	e406                	sd	ra,8(sp)
    80006b4a:	e022                	sd	s0,0(sp)
    80006b4c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80006b4e:	00003597          	auipc	a1,0x3
    80006b52:	caa58593          	addi	a1,a1,-854 # 800097f8 <syscalls+0x448>
    80006b56:	00021517          	auipc	a0,0x21
    80006b5a:	93a50513          	addi	a0,a0,-1734 # 80027490 <cons>
    80006b5e:	00000097          	auipc	ra,0x0
    80006b62:	582080e7          	jalr	1410(ra) # 800070e0 <initlock>

  uartinit();
    80006b66:	00000097          	auipc	ra,0x0
    80006b6a:	32a080e7          	jalr	810(ra) # 80006e90 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80006b6e:	00013797          	auipc	a5,0x13
    80006b72:	56278793          	addi	a5,a5,1378 # 8001a0d0 <devsw>
    80006b76:	00000717          	auipc	a4,0x0
    80006b7a:	cea70713          	addi	a4,a4,-790 # 80006860 <consoleread>
    80006b7e:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80006b80:	00000717          	auipc	a4,0x0
    80006b84:	c7e70713          	addi	a4,a4,-898 # 800067fe <consolewrite>
    80006b88:	ef98                	sd	a4,24(a5)
}
    80006b8a:	60a2                	ld	ra,8(sp)
    80006b8c:	6402                	ld	s0,0(sp)
    80006b8e:	0141                	addi	sp,sp,16
    80006b90:	8082                	ret

0000000080006b92 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80006b92:	7179                	addi	sp,sp,-48
    80006b94:	f406                	sd	ra,40(sp)
    80006b96:	f022                	sd	s0,32(sp)
    80006b98:	ec26                	sd	s1,24(sp)
    80006b9a:	e84a                	sd	s2,16(sp)
    80006b9c:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80006b9e:	c219                	beqz	a2,80006ba4 <printint+0x12>
    80006ba0:	08054663          	bltz	a0,80006c2c <printint+0x9a>
    x = -xx;
  else
    x = xx;
    80006ba4:	2501                	sext.w	a0,a0
    80006ba6:	4881                	li	a7,0
    80006ba8:	fd040693          	addi	a3,s0,-48

  i = 0;
    80006bac:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80006bae:	2581                	sext.w	a1,a1
    80006bb0:	00003617          	auipc	a2,0x3
    80006bb4:	c7860613          	addi	a2,a2,-904 # 80009828 <digits>
    80006bb8:	883a                	mv	a6,a4
    80006bba:	2705                	addiw	a4,a4,1
    80006bbc:	02b577bb          	remuw	a5,a0,a1
    80006bc0:	1782                	slli	a5,a5,0x20
    80006bc2:	9381                	srli	a5,a5,0x20
    80006bc4:	97b2                	add	a5,a5,a2
    80006bc6:	0007c783          	lbu	a5,0(a5)
    80006bca:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80006bce:	0005079b          	sext.w	a5,a0
    80006bd2:	02b5553b          	divuw	a0,a0,a1
    80006bd6:	0685                	addi	a3,a3,1
    80006bd8:	feb7f0e3          	bgeu	a5,a1,80006bb8 <printint+0x26>

  if(sign)
    80006bdc:	00088b63          	beqz	a7,80006bf2 <printint+0x60>
    buf[i++] = '-';
    80006be0:	fe040793          	addi	a5,s0,-32
    80006be4:	973e                	add	a4,a4,a5
    80006be6:	02d00793          	li	a5,45
    80006bea:	fef70823          	sb	a5,-16(a4)
    80006bee:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80006bf2:	02e05763          	blez	a4,80006c20 <printint+0x8e>
    80006bf6:	fd040793          	addi	a5,s0,-48
    80006bfa:	00e784b3          	add	s1,a5,a4
    80006bfe:	fff78913          	addi	s2,a5,-1
    80006c02:	993a                	add	s2,s2,a4
    80006c04:	377d                	addiw	a4,a4,-1
    80006c06:	1702                	slli	a4,a4,0x20
    80006c08:	9301                	srli	a4,a4,0x20
    80006c0a:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80006c0e:	fff4c503          	lbu	a0,-1(s1)
    80006c12:	00000097          	auipc	ra,0x0
    80006c16:	d60080e7          	jalr	-672(ra) # 80006972 <consputc>
  while(--i >= 0)
    80006c1a:	14fd                	addi	s1,s1,-1
    80006c1c:	ff2499e3          	bne	s1,s2,80006c0e <printint+0x7c>
}
    80006c20:	70a2                	ld	ra,40(sp)
    80006c22:	7402                	ld	s0,32(sp)
    80006c24:	64e2                	ld	s1,24(sp)
    80006c26:	6942                	ld	s2,16(sp)
    80006c28:	6145                	addi	sp,sp,48
    80006c2a:	8082                	ret
    x = -xx;
    80006c2c:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80006c30:	4885                	li	a7,1
    x = -xx;
    80006c32:	bf9d                	j	80006ba8 <printint+0x16>

0000000080006c34 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80006c34:	1101                	addi	sp,sp,-32
    80006c36:	ec06                	sd	ra,24(sp)
    80006c38:	e822                	sd	s0,16(sp)
    80006c3a:	e426                	sd	s1,8(sp)
    80006c3c:	1000                	addi	s0,sp,32
    80006c3e:	84aa                	mv	s1,a0
  pr.locking = 0;
    80006c40:	00021797          	auipc	a5,0x21
    80006c44:	9007a823          	sw	zero,-1776(a5) # 80027550 <pr+0x18>
  printf("panic: ");
    80006c48:	00003517          	auipc	a0,0x3
    80006c4c:	bb850513          	addi	a0,a0,-1096 # 80009800 <syscalls+0x450>
    80006c50:	00000097          	auipc	ra,0x0
    80006c54:	02e080e7          	jalr	46(ra) # 80006c7e <printf>
  printf(s);
    80006c58:	8526                	mv	a0,s1
    80006c5a:	00000097          	auipc	ra,0x0
    80006c5e:	024080e7          	jalr	36(ra) # 80006c7e <printf>
  printf("\n");
    80006c62:	00002517          	auipc	a0,0x2
    80006c66:	3e650513          	addi	a0,a0,998 # 80009048 <etext+0x48>
    80006c6a:	00000097          	auipc	ra,0x0
    80006c6e:	014080e7          	jalr	20(ra) # 80006c7e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80006c72:	4785                	li	a5,1
    80006c74:	00003717          	auipc	a4,0x3
    80006c78:	3af72e23          	sw	a5,956(a4) # 8000a030 <panicked>
  for(;;)
    80006c7c:	a001                	j	80006c7c <panic+0x48>

0000000080006c7e <printf>:
{
    80006c7e:	7131                	addi	sp,sp,-192
    80006c80:	fc86                	sd	ra,120(sp)
    80006c82:	f8a2                	sd	s0,112(sp)
    80006c84:	f4a6                	sd	s1,104(sp)
    80006c86:	f0ca                	sd	s2,96(sp)
    80006c88:	ecce                	sd	s3,88(sp)
    80006c8a:	e8d2                	sd	s4,80(sp)
    80006c8c:	e4d6                	sd	s5,72(sp)
    80006c8e:	e0da                	sd	s6,64(sp)
    80006c90:	fc5e                	sd	s7,56(sp)
    80006c92:	f862                	sd	s8,48(sp)
    80006c94:	f466                	sd	s9,40(sp)
    80006c96:	f06a                	sd	s10,32(sp)
    80006c98:	ec6e                	sd	s11,24(sp)
    80006c9a:	0100                	addi	s0,sp,128
    80006c9c:	8a2a                	mv	s4,a0
    80006c9e:	e40c                	sd	a1,8(s0)
    80006ca0:	e810                	sd	a2,16(s0)
    80006ca2:	ec14                	sd	a3,24(s0)
    80006ca4:	f018                	sd	a4,32(s0)
    80006ca6:	f41c                	sd	a5,40(s0)
    80006ca8:	03043823          	sd	a6,48(s0)
    80006cac:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80006cb0:	00021d97          	auipc	s11,0x21
    80006cb4:	8a0dad83          	lw	s11,-1888(s11) # 80027550 <pr+0x18>
  if(locking)
    80006cb8:	020d9b63          	bnez	s11,80006cee <printf+0x70>
  if (fmt == 0)
    80006cbc:	040a0263          	beqz	s4,80006d00 <printf+0x82>
  va_start(ap, fmt);
    80006cc0:	00840793          	addi	a5,s0,8
    80006cc4:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80006cc8:	000a4503          	lbu	a0,0(s4) # 2000 <_entry-0x7fffe000>
    80006ccc:	14050f63          	beqz	a0,80006e2a <printf+0x1ac>
    80006cd0:	4981                	li	s3,0
    if(c != '%'){
    80006cd2:	02500a93          	li	s5,37
    switch(c){
    80006cd6:	07000b93          	li	s7,112
  consputc('x');
    80006cda:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80006cdc:	00003b17          	auipc	s6,0x3
    80006ce0:	b4cb0b13          	addi	s6,s6,-1204 # 80009828 <digits>
    switch(c){
    80006ce4:	07300c93          	li	s9,115
    80006ce8:	06400c13          	li	s8,100
    80006cec:	a82d                	j	80006d26 <printf+0xa8>
    acquire(&pr.lock);
    80006cee:	00021517          	auipc	a0,0x21
    80006cf2:	84a50513          	addi	a0,a0,-1974 # 80027538 <pr>
    80006cf6:	00000097          	auipc	ra,0x0
    80006cfa:	47a080e7          	jalr	1146(ra) # 80007170 <acquire>
    80006cfe:	bf7d                	j	80006cbc <printf+0x3e>
    panic("null fmt");
    80006d00:	00003517          	auipc	a0,0x3
    80006d04:	b1050513          	addi	a0,a0,-1264 # 80009810 <syscalls+0x460>
    80006d08:	00000097          	auipc	ra,0x0
    80006d0c:	f2c080e7          	jalr	-212(ra) # 80006c34 <panic>
      consputc(c);
    80006d10:	00000097          	auipc	ra,0x0
    80006d14:	c62080e7          	jalr	-926(ra) # 80006972 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80006d18:	2985                	addiw	s3,s3,1
    80006d1a:	013a07b3          	add	a5,s4,s3
    80006d1e:	0007c503          	lbu	a0,0(a5)
    80006d22:	10050463          	beqz	a0,80006e2a <printf+0x1ac>
    if(c != '%'){
    80006d26:	ff5515e3          	bne	a0,s5,80006d10 <printf+0x92>
    c = fmt[++i] & 0xff;
    80006d2a:	2985                	addiw	s3,s3,1
    80006d2c:	013a07b3          	add	a5,s4,s3
    80006d30:	0007c783          	lbu	a5,0(a5)
    80006d34:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80006d38:	cbed                	beqz	a5,80006e2a <printf+0x1ac>
    switch(c){
    80006d3a:	05778a63          	beq	a5,s7,80006d8e <printf+0x110>
    80006d3e:	02fbf663          	bgeu	s7,a5,80006d6a <printf+0xec>
    80006d42:	09978863          	beq	a5,s9,80006dd2 <printf+0x154>
    80006d46:	07800713          	li	a4,120
    80006d4a:	0ce79563          	bne	a5,a4,80006e14 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80006d4e:	f8843783          	ld	a5,-120(s0)
    80006d52:	00878713          	addi	a4,a5,8
    80006d56:	f8e43423          	sd	a4,-120(s0)
    80006d5a:	4605                	li	a2,1
    80006d5c:	85ea                	mv	a1,s10
    80006d5e:	4388                	lw	a0,0(a5)
    80006d60:	00000097          	auipc	ra,0x0
    80006d64:	e32080e7          	jalr	-462(ra) # 80006b92 <printint>
      break;
    80006d68:	bf45                	j	80006d18 <printf+0x9a>
    switch(c){
    80006d6a:	09578f63          	beq	a5,s5,80006e08 <printf+0x18a>
    80006d6e:	0b879363          	bne	a5,s8,80006e14 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80006d72:	f8843783          	ld	a5,-120(s0)
    80006d76:	00878713          	addi	a4,a5,8
    80006d7a:	f8e43423          	sd	a4,-120(s0)
    80006d7e:	4605                	li	a2,1
    80006d80:	45a9                	li	a1,10
    80006d82:	4388                	lw	a0,0(a5)
    80006d84:	00000097          	auipc	ra,0x0
    80006d88:	e0e080e7          	jalr	-498(ra) # 80006b92 <printint>
      break;
    80006d8c:	b771                	j	80006d18 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80006d8e:	f8843783          	ld	a5,-120(s0)
    80006d92:	00878713          	addi	a4,a5,8
    80006d96:	f8e43423          	sd	a4,-120(s0)
    80006d9a:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80006d9e:	03000513          	li	a0,48
    80006da2:	00000097          	auipc	ra,0x0
    80006da6:	bd0080e7          	jalr	-1072(ra) # 80006972 <consputc>
  consputc('x');
    80006daa:	07800513          	li	a0,120
    80006dae:	00000097          	auipc	ra,0x0
    80006db2:	bc4080e7          	jalr	-1084(ra) # 80006972 <consputc>
    80006db6:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80006db8:	03c95793          	srli	a5,s2,0x3c
    80006dbc:	97da                	add	a5,a5,s6
    80006dbe:	0007c503          	lbu	a0,0(a5)
    80006dc2:	00000097          	auipc	ra,0x0
    80006dc6:	bb0080e7          	jalr	-1104(ra) # 80006972 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80006dca:	0912                	slli	s2,s2,0x4
    80006dcc:	34fd                	addiw	s1,s1,-1
    80006dce:	f4ed                	bnez	s1,80006db8 <printf+0x13a>
    80006dd0:	b7a1                	j	80006d18 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    80006dd2:	f8843783          	ld	a5,-120(s0)
    80006dd6:	00878713          	addi	a4,a5,8
    80006dda:	f8e43423          	sd	a4,-120(s0)
    80006dde:	6384                	ld	s1,0(a5)
    80006de0:	cc89                	beqz	s1,80006dfa <printf+0x17c>
      for(; *s; s++)
    80006de2:	0004c503          	lbu	a0,0(s1)
    80006de6:	d90d                	beqz	a0,80006d18 <printf+0x9a>
        consputc(*s);
    80006de8:	00000097          	auipc	ra,0x0
    80006dec:	b8a080e7          	jalr	-1142(ra) # 80006972 <consputc>
      for(; *s; s++)
    80006df0:	0485                	addi	s1,s1,1
    80006df2:	0004c503          	lbu	a0,0(s1)
    80006df6:	f96d                	bnez	a0,80006de8 <printf+0x16a>
    80006df8:	b705                	j	80006d18 <printf+0x9a>
        s = "(null)";
    80006dfa:	00003497          	auipc	s1,0x3
    80006dfe:	a0e48493          	addi	s1,s1,-1522 # 80009808 <syscalls+0x458>
      for(; *s; s++)
    80006e02:	02800513          	li	a0,40
    80006e06:	b7cd                	j	80006de8 <printf+0x16a>
      consputc('%');
    80006e08:	8556                	mv	a0,s5
    80006e0a:	00000097          	auipc	ra,0x0
    80006e0e:	b68080e7          	jalr	-1176(ra) # 80006972 <consputc>
      break;
    80006e12:	b719                	j	80006d18 <printf+0x9a>
      consputc('%');
    80006e14:	8556                	mv	a0,s5
    80006e16:	00000097          	auipc	ra,0x0
    80006e1a:	b5c080e7          	jalr	-1188(ra) # 80006972 <consputc>
      consputc(c);
    80006e1e:	8526                	mv	a0,s1
    80006e20:	00000097          	auipc	ra,0x0
    80006e24:	b52080e7          	jalr	-1198(ra) # 80006972 <consputc>
      break;
    80006e28:	bdc5                	j	80006d18 <printf+0x9a>
  if(locking)
    80006e2a:	020d9163          	bnez	s11,80006e4c <printf+0x1ce>
}
    80006e2e:	70e6                	ld	ra,120(sp)
    80006e30:	7446                	ld	s0,112(sp)
    80006e32:	74a6                	ld	s1,104(sp)
    80006e34:	7906                	ld	s2,96(sp)
    80006e36:	69e6                	ld	s3,88(sp)
    80006e38:	6a46                	ld	s4,80(sp)
    80006e3a:	6aa6                	ld	s5,72(sp)
    80006e3c:	6b06                	ld	s6,64(sp)
    80006e3e:	7be2                	ld	s7,56(sp)
    80006e40:	7c42                	ld	s8,48(sp)
    80006e42:	7ca2                	ld	s9,40(sp)
    80006e44:	7d02                	ld	s10,32(sp)
    80006e46:	6de2                	ld	s11,24(sp)
    80006e48:	6129                	addi	sp,sp,192
    80006e4a:	8082                	ret
    release(&pr.lock);
    80006e4c:	00020517          	auipc	a0,0x20
    80006e50:	6ec50513          	addi	a0,a0,1772 # 80027538 <pr>
    80006e54:	00000097          	auipc	ra,0x0
    80006e58:	3d0080e7          	jalr	976(ra) # 80007224 <release>
}
    80006e5c:	bfc9                	j	80006e2e <printf+0x1b0>

0000000080006e5e <printfinit>:
    ;
}

void
printfinit(void)
{
    80006e5e:	1101                	addi	sp,sp,-32
    80006e60:	ec06                	sd	ra,24(sp)
    80006e62:	e822                	sd	s0,16(sp)
    80006e64:	e426                	sd	s1,8(sp)
    80006e66:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80006e68:	00020497          	auipc	s1,0x20
    80006e6c:	6d048493          	addi	s1,s1,1744 # 80027538 <pr>
    80006e70:	00003597          	auipc	a1,0x3
    80006e74:	9b058593          	addi	a1,a1,-1616 # 80009820 <syscalls+0x470>
    80006e78:	8526                	mv	a0,s1
    80006e7a:	00000097          	auipc	ra,0x0
    80006e7e:	266080e7          	jalr	614(ra) # 800070e0 <initlock>
  pr.locking = 1;
    80006e82:	4785                	li	a5,1
    80006e84:	cc9c                	sw	a5,24(s1)
}
    80006e86:	60e2                	ld	ra,24(sp)
    80006e88:	6442                	ld	s0,16(sp)
    80006e8a:	64a2                	ld	s1,8(sp)
    80006e8c:	6105                	addi	sp,sp,32
    80006e8e:	8082                	ret

0000000080006e90 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80006e90:	1141                	addi	sp,sp,-16
    80006e92:	e406                	sd	ra,8(sp)
    80006e94:	e022                	sd	s0,0(sp)
    80006e96:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80006e98:	100007b7          	lui	a5,0x10000
    80006e9c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80006ea0:	f8000713          	li	a4,-128
    80006ea4:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80006ea8:	470d                	li	a4,3
    80006eaa:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80006eae:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80006eb2:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80006eb6:	469d                	li	a3,7
    80006eb8:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80006ebc:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80006ec0:	00003597          	auipc	a1,0x3
    80006ec4:	98058593          	addi	a1,a1,-1664 # 80009840 <digits+0x18>
    80006ec8:	00020517          	auipc	a0,0x20
    80006ecc:	69050513          	addi	a0,a0,1680 # 80027558 <uart_tx_lock>
    80006ed0:	00000097          	auipc	ra,0x0
    80006ed4:	210080e7          	jalr	528(ra) # 800070e0 <initlock>
}
    80006ed8:	60a2                	ld	ra,8(sp)
    80006eda:	6402                	ld	s0,0(sp)
    80006edc:	0141                	addi	sp,sp,16
    80006ede:	8082                	ret

0000000080006ee0 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80006ee0:	1101                	addi	sp,sp,-32
    80006ee2:	ec06                	sd	ra,24(sp)
    80006ee4:	e822                	sd	s0,16(sp)
    80006ee6:	e426                	sd	s1,8(sp)
    80006ee8:	1000                	addi	s0,sp,32
    80006eea:	84aa                	mv	s1,a0
  push_off();
    80006eec:	00000097          	auipc	ra,0x0
    80006ef0:	238080e7          	jalr	568(ra) # 80007124 <push_off>

  if(panicked){
    80006ef4:	00003797          	auipc	a5,0x3
    80006ef8:	13c7a783          	lw	a5,316(a5) # 8000a030 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80006efc:	10000737          	lui	a4,0x10000
  if(panicked){
    80006f00:	c391                	beqz	a5,80006f04 <uartputc_sync+0x24>
    for(;;)
    80006f02:	a001                	j	80006f02 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80006f04:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80006f08:	0207f793          	andi	a5,a5,32
    80006f0c:	dfe5                	beqz	a5,80006f04 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80006f0e:	0ff4f513          	andi	a0,s1,255
    80006f12:	100007b7          	lui	a5,0x10000
    80006f16:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80006f1a:	00000097          	auipc	ra,0x0
    80006f1e:	2aa080e7          	jalr	682(ra) # 800071c4 <pop_off>
}
    80006f22:	60e2                	ld	ra,24(sp)
    80006f24:	6442                	ld	s0,16(sp)
    80006f26:	64a2                	ld	s1,8(sp)
    80006f28:	6105                	addi	sp,sp,32
    80006f2a:	8082                	ret

0000000080006f2c <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80006f2c:	00003797          	auipc	a5,0x3
    80006f30:	10c7b783          	ld	a5,268(a5) # 8000a038 <uart_tx_r>
    80006f34:	00003717          	auipc	a4,0x3
    80006f38:	10c73703          	ld	a4,268(a4) # 8000a040 <uart_tx_w>
    80006f3c:	06f70a63          	beq	a4,a5,80006fb0 <uartstart+0x84>
{
    80006f40:	7139                	addi	sp,sp,-64
    80006f42:	fc06                	sd	ra,56(sp)
    80006f44:	f822                	sd	s0,48(sp)
    80006f46:	f426                	sd	s1,40(sp)
    80006f48:	f04a                	sd	s2,32(sp)
    80006f4a:	ec4e                	sd	s3,24(sp)
    80006f4c:	e852                	sd	s4,16(sp)
    80006f4e:	e456                	sd	s5,8(sp)
    80006f50:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80006f52:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80006f56:	00020a17          	auipc	s4,0x20
    80006f5a:	602a0a13          	addi	s4,s4,1538 # 80027558 <uart_tx_lock>
    uart_tx_r += 1;
    80006f5e:	00003497          	auipc	s1,0x3
    80006f62:	0da48493          	addi	s1,s1,218 # 8000a038 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80006f66:	00003997          	auipc	s3,0x3
    80006f6a:	0da98993          	addi	s3,s3,218 # 8000a040 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80006f6e:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80006f72:	02077713          	andi	a4,a4,32
    80006f76:	c705                	beqz	a4,80006f9e <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80006f78:	01f7f713          	andi	a4,a5,31
    80006f7c:	9752                	add	a4,a4,s4
    80006f7e:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80006f82:	0785                	addi	a5,a5,1
    80006f84:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80006f86:	8526                	mv	a0,s1
    80006f88:	ffffb097          	auipc	ra,0xffffb
    80006f8c:	8cc080e7          	jalr	-1844(ra) # 80001854 <wakeup>
    
    WriteReg(THR, c);
    80006f90:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80006f94:	609c                	ld	a5,0(s1)
    80006f96:	0009b703          	ld	a4,0(s3)
    80006f9a:	fcf71ae3          	bne	a4,a5,80006f6e <uartstart+0x42>
  }
}
    80006f9e:	70e2                	ld	ra,56(sp)
    80006fa0:	7442                	ld	s0,48(sp)
    80006fa2:	74a2                	ld	s1,40(sp)
    80006fa4:	7902                	ld	s2,32(sp)
    80006fa6:	69e2                	ld	s3,24(sp)
    80006fa8:	6a42                	ld	s4,16(sp)
    80006faa:	6aa2                	ld	s5,8(sp)
    80006fac:	6121                	addi	sp,sp,64
    80006fae:	8082                	ret
    80006fb0:	8082                	ret

0000000080006fb2 <uartputc>:
{
    80006fb2:	7179                	addi	sp,sp,-48
    80006fb4:	f406                	sd	ra,40(sp)
    80006fb6:	f022                	sd	s0,32(sp)
    80006fb8:	ec26                	sd	s1,24(sp)
    80006fba:	e84a                	sd	s2,16(sp)
    80006fbc:	e44e                	sd	s3,8(sp)
    80006fbe:	e052                	sd	s4,0(sp)
    80006fc0:	1800                	addi	s0,sp,48
    80006fc2:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80006fc4:	00020517          	auipc	a0,0x20
    80006fc8:	59450513          	addi	a0,a0,1428 # 80027558 <uart_tx_lock>
    80006fcc:	00000097          	auipc	ra,0x0
    80006fd0:	1a4080e7          	jalr	420(ra) # 80007170 <acquire>
  if(panicked){
    80006fd4:	00003797          	auipc	a5,0x3
    80006fd8:	05c7a783          	lw	a5,92(a5) # 8000a030 <panicked>
    80006fdc:	c391                	beqz	a5,80006fe0 <uartputc+0x2e>
    for(;;)
    80006fde:	a001                	j	80006fde <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80006fe0:	00003717          	auipc	a4,0x3
    80006fe4:	06073703          	ld	a4,96(a4) # 8000a040 <uart_tx_w>
    80006fe8:	00003797          	auipc	a5,0x3
    80006fec:	0507b783          	ld	a5,80(a5) # 8000a038 <uart_tx_r>
    80006ff0:	02078793          	addi	a5,a5,32
    80006ff4:	02e79b63          	bne	a5,a4,8000702a <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    80006ff8:	00020997          	auipc	s3,0x20
    80006ffc:	56098993          	addi	s3,s3,1376 # 80027558 <uart_tx_lock>
    80007000:	00003497          	auipc	s1,0x3
    80007004:	03848493          	addi	s1,s1,56 # 8000a038 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80007008:	00003917          	auipc	s2,0x3
    8000700c:	03890913          	addi	s2,s2,56 # 8000a040 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80007010:	85ce                	mv	a1,s3
    80007012:	8526                	mv	a0,s1
    80007014:	ffffa097          	auipc	ra,0xffffa
    80007018:	6c0080e7          	jalr	1728(ra) # 800016d4 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000701c:	00093703          	ld	a4,0(s2)
    80007020:	609c                	ld	a5,0(s1)
    80007022:	02078793          	addi	a5,a5,32
    80007026:	fee785e3          	beq	a5,a4,80007010 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000702a:	00020497          	auipc	s1,0x20
    8000702e:	52e48493          	addi	s1,s1,1326 # 80027558 <uart_tx_lock>
    80007032:	01f77793          	andi	a5,a4,31
    80007036:	97a6                	add	a5,a5,s1
    80007038:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    8000703c:	0705                	addi	a4,a4,1
    8000703e:	00003797          	auipc	a5,0x3
    80007042:	00e7b123          	sd	a4,2(a5) # 8000a040 <uart_tx_w>
      uartstart();
    80007046:	00000097          	auipc	ra,0x0
    8000704a:	ee6080e7          	jalr	-282(ra) # 80006f2c <uartstart>
      release(&uart_tx_lock);
    8000704e:	8526                	mv	a0,s1
    80007050:	00000097          	auipc	ra,0x0
    80007054:	1d4080e7          	jalr	468(ra) # 80007224 <release>
}
    80007058:	70a2                	ld	ra,40(sp)
    8000705a:	7402                	ld	s0,32(sp)
    8000705c:	64e2                	ld	s1,24(sp)
    8000705e:	6942                	ld	s2,16(sp)
    80007060:	69a2                	ld	s3,8(sp)
    80007062:	6a02                	ld	s4,0(sp)
    80007064:	6145                	addi	sp,sp,48
    80007066:	8082                	ret

0000000080007068 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80007068:	1141                	addi	sp,sp,-16
    8000706a:	e422                	sd	s0,8(sp)
    8000706c:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000706e:	100007b7          	lui	a5,0x10000
    80007072:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80007076:	8b85                	andi	a5,a5,1
    80007078:	cb91                	beqz	a5,8000708c <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    8000707a:	100007b7          	lui	a5,0x10000
    8000707e:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80007082:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80007086:	6422                	ld	s0,8(sp)
    80007088:	0141                	addi	sp,sp,16
    8000708a:	8082                	ret
    return -1;
    8000708c:	557d                	li	a0,-1
    8000708e:	bfe5                	j	80007086 <uartgetc+0x1e>

0000000080007090 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80007090:	1101                	addi	sp,sp,-32
    80007092:	ec06                	sd	ra,24(sp)
    80007094:	e822                	sd	s0,16(sp)
    80007096:	e426                	sd	s1,8(sp)
    80007098:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000709a:	54fd                	li	s1,-1
    8000709c:	a029                	j	800070a6 <uartintr+0x16>
      break;
    consoleintr(c);
    8000709e:	00000097          	auipc	ra,0x0
    800070a2:	916080e7          	jalr	-1770(ra) # 800069b4 <consoleintr>
    int c = uartgetc();
    800070a6:	00000097          	auipc	ra,0x0
    800070aa:	fc2080e7          	jalr	-62(ra) # 80007068 <uartgetc>
    if(c == -1)
    800070ae:	fe9518e3          	bne	a0,s1,8000709e <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800070b2:	00020497          	auipc	s1,0x20
    800070b6:	4a648493          	addi	s1,s1,1190 # 80027558 <uart_tx_lock>
    800070ba:	8526                	mv	a0,s1
    800070bc:	00000097          	auipc	ra,0x0
    800070c0:	0b4080e7          	jalr	180(ra) # 80007170 <acquire>
  uartstart();
    800070c4:	00000097          	auipc	ra,0x0
    800070c8:	e68080e7          	jalr	-408(ra) # 80006f2c <uartstart>
  release(&uart_tx_lock);
    800070cc:	8526                	mv	a0,s1
    800070ce:	00000097          	auipc	ra,0x0
    800070d2:	156080e7          	jalr	342(ra) # 80007224 <release>
}
    800070d6:	60e2                	ld	ra,24(sp)
    800070d8:	6442                	ld	s0,16(sp)
    800070da:	64a2                	ld	s1,8(sp)
    800070dc:	6105                	addi	sp,sp,32
    800070de:	8082                	ret

00000000800070e0 <initlock>:
}
#endif

void
initlock(struct spinlock *lk, char *name)
{
    800070e0:	1141                	addi	sp,sp,-16
    800070e2:	e422                	sd	s0,8(sp)
    800070e4:	0800                	addi	s0,sp,16
  lk->name = name;
    800070e6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800070e8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800070ec:	00053823          	sd	zero,16(a0)
#ifdef LAB_LOCK
  lk->nts = 0;
  lk->n = 0;
  findslot(lk);
#endif  
}
    800070f0:	6422                	ld	s0,8(sp)
    800070f2:	0141                	addi	sp,sp,16
    800070f4:	8082                	ret

00000000800070f6 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    800070f6:	411c                	lw	a5,0(a0)
    800070f8:	e399                	bnez	a5,800070fe <holding+0x8>
    800070fa:	4501                	li	a0,0
  return r;
}
    800070fc:	8082                	ret
{
    800070fe:	1101                	addi	sp,sp,-32
    80007100:	ec06                	sd	ra,24(sp)
    80007102:	e822                	sd	s0,16(sp)
    80007104:	e426                	sd	s1,8(sp)
    80007106:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80007108:	6904                	ld	s1,16(a0)
    8000710a:	ffffa097          	auipc	ra,0xffffa
    8000710e:	d9a080e7          	jalr	-614(ra) # 80000ea4 <mycpu>
    80007112:	40a48533          	sub	a0,s1,a0
    80007116:	00153513          	seqz	a0,a0
}
    8000711a:	60e2                	ld	ra,24(sp)
    8000711c:	6442                	ld	s0,16(sp)
    8000711e:	64a2                	ld	s1,8(sp)
    80007120:	6105                	addi	sp,sp,32
    80007122:	8082                	ret

0000000080007124 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80007124:	1101                	addi	sp,sp,-32
    80007126:	ec06                	sd	ra,24(sp)
    80007128:	e822                	sd	s0,16(sp)
    8000712a:	e426                	sd	s1,8(sp)
    8000712c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000712e:	100024f3          	csrr	s1,sstatus
    80007132:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80007136:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80007138:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    8000713c:	ffffa097          	auipc	ra,0xffffa
    80007140:	d68080e7          	jalr	-664(ra) # 80000ea4 <mycpu>
    80007144:	5d3c                	lw	a5,120(a0)
    80007146:	cf89                	beqz	a5,80007160 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80007148:	ffffa097          	auipc	ra,0xffffa
    8000714c:	d5c080e7          	jalr	-676(ra) # 80000ea4 <mycpu>
    80007150:	5d3c                	lw	a5,120(a0)
    80007152:	2785                	addiw	a5,a5,1
    80007154:	dd3c                	sw	a5,120(a0)
}
    80007156:	60e2                	ld	ra,24(sp)
    80007158:	6442                	ld	s0,16(sp)
    8000715a:	64a2                	ld	s1,8(sp)
    8000715c:	6105                	addi	sp,sp,32
    8000715e:	8082                	ret
    mycpu()->intena = old;
    80007160:	ffffa097          	auipc	ra,0xffffa
    80007164:	d44080e7          	jalr	-700(ra) # 80000ea4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80007168:	8085                	srli	s1,s1,0x1
    8000716a:	8885                	andi	s1,s1,1
    8000716c:	dd64                	sw	s1,124(a0)
    8000716e:	bfe9                	j	80007148 <push_off+0x24>

0000000080007170 <acquire>:
{
    80007170:	1101                	addi	sp,sp,-32
    80007172:	ec06                	sd	ra,24(sp)
    80007174:	e822                	sd	s0,16(sp)
    80007176:	e426                	sd	s1,8(sp)
    80007178:	1000                	addi	s0,sp,32
    8000717a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    8000717c:	00000097          	auipc	ra,0x0
    80007180:	fa8080e7          	jalr	-88(ra) # 80007124 <push_off>
  if(holding(lk))
    80007184:	8526                	mv	a0,s1
    80007186:	00000097          	auipc	ra,0x0
    8000718a:	f70080e7          	jalr	-144(ra) # 800070f6 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    8000718e:	4705                	li	a4,1
  if(holding(lk))
    80007190:	e115                	bnez	a0,800071b4 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80007192:	87ba                	mv	a5,a4
    80007194:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80007198:	2781                	sext.w	a5,a5
    8000719a:	ffe5                	bnez	a5,80007192 <acquire+0x22>
  __sync_synchronize();
    8000719c:	0ff0000f          	fence
  lk->cpu = mycpu();
    800071a0:	ffffa097          	auipc	ra,0xffffa
    800071a4:	d04080e7          	jalr	-764(ra) # 80000ea4 <mycpu>
    800071a8:	e888                	sd	a0,16(s1)
}
    800071aa:	60e2                	ld	ra,24(sp)
    800071ac:	6442                	ld	s0,16(sp)
    800071ae:	64a2                	ld	s1,8(sp)
    800071b0:	6105                	addi	sp,sp,32
    800071b2:	8082                	ret
    panic("acquire");
    800071b4:	00002517          	auipc	a0,0x2
    800071b8:	69450513          	addi	a0,a0,1684 # 80009848 <digits+0x20>
    800071bc:	00000097          	auipc	ra,0x0
    800071c0:	a78080e7          	jalr	-1416(ra) # 80006c34 <panic>

00000000800071c4 <pop_off>:

void
pop_off(void)
{
    800071c4:	1141                	addi	sp,sp,-16
    800071c6:	e406                	sd	ra,8(sp)
    800071c8:	e022                	sd	s0,0(sp)
    800071ca:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800071cc:	ffffa097          	auipc	ra,0xffffa
    800071d0:	cd8080e7          	jalr	-808(ra) # 80000ea4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800071d4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800071d8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800071da:	e78d                	bnez	a5,80007204 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    800071dc:	5d3c                	lw	a5,120(a0)
    800071de:	02f05b63          	blez	a5,80007214 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    800071e2:	37fd                	addiw	a5,a5,-1
    800071e4:	0007871b          	sext.w	a4,a5
    800071e8:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    800071ea:	eb09                	bnez	a4,800071fc <pop_off+0x38>
    800071ec:	5d7c                	lw	a5,124(a0)
    800071ee:	c799                	beqz	a5,800071fc <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800071f0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800071f4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800071f8:	10079073          	csrw	sstatus,a5
    intr_on();
}
    800071fc:	60a2                	ld	ra,8(sp)
    800071fe:	6402                	ld	s0,0(sp)
    80007200:	0141                	addi	sp,sp,16
    80007202:	8082                	ret
    panic("pop_off - interruptible");
    80007204:	00002517          	auipc	a0,0x2
    80007208:	64c50513          	addi	a0,a0,1612 # 80009850 <digits+0x28>
    8000720c:	00000097          	auipc	ra,0x0
    80007210:	a28080e7          	jalr	-1496(ra) # 80006c34 <panic>
    panic("pop_off");
    80007214:	00002517          	auipc	a0,0x2
    80007218:	65450513          	addi	a0,a0,1620 # 80009868 <digits+0x40>
    8000721c:	00000097          	auipc	ra,0x0
    80007220:	a18080e7          	jalr	-1512(ra) # 80006c34 <panic>

0000000080007224 <release>:
{
    80007224:	1101                	addi	sp,sp,-32
    80007226:	ec06                	sd	ra,24(sp)
    80007228:	e822                	sd	s0,16(sp)
    8000722a:	e426                	sd	s1,8(sp)
    8000722c:	1000                	addi	s0,sp,32
    8000722e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80007230:	00000097          	auipc	ra,0x0
    80007234:	ec6080e7          	jalr	-314(ra) # 800070f6 <holding>
    80007238:	c115                	beqz	a0,8000725c <release+0x38>
  lk->cpu = 0;
    8000723a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    8000723e:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80007242:	0f50000f          	fence	iorw,ow
    80007246:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    8000724a:	00000097          	auipc	ra,0x0
    8000724e:	f7a080e7          	jalr	-134(ra) # 800071c4 <pop_off>
}
    80007252:	60e2                	ld	ra,24(sp)
    80007254:	6442                	ld	s0,16(sp)
    80007256:	64a2                	ld	s1,8(sp)
    80007258:	6105                	addi	sp,sp,32
    8000725a:	8082                	ret
    panic("release");
    8000725c:	00002517          	auipc	a0,0x2
    80007260:	61450513          	addi	a0,a0,1556 # 80009870 <digits+0x48>
    80007264:	00000097          	auipc	ra,0x0
    80007268:	9d0080e7          	jalr	-1584(ra) # 80006c34 <panic>

000000008000726c <lockfree_read8>:

// Read a shared 64-bit value without holding a lock
uint64
lockfree_read8(uint64 *addr) {
    8000726c:	1141                	addi	sp,sp,-16
    8000726e:	e422                	sd	s0,8(sp)
    80007270:	0800                	addi	s0,sp,16
  uint64 val;
  __atomic_load(addr, &val, __ATOMIC_SEQ_CST);
    80007272:	0ff0000f          	fence
    80007276:	6108                	ld	a0,0(a0)
    80007278:	0ff0000f          	fence
  return val;
}
    8000727c:	6422                	ld	s0,8(sp)
    8000727e:	0141                	addi	sp,sp,16
    80007280:	8082                	ret

0000000080007282 <lockfree_read4>:

// Read a shared 32-bit value without holding a lock
int
lockfree_read4(int *addr) {
    80007282:	1141                	addi	sp,sp,-16
    80007284:	e422                	sd	s0,8(sp)
    80007286:	0800                	addi	s0,sp,16
  uint32 val;
  __atomic_load(addr, &val, __ATOMIC_SEQ_CST);
    80007288:	0ff0000f          	fence
    8000728c:	4108                	lw	a0,0(a0)
    8000728e:	0ff0000f          	fence
  return val;
}
    80007292:	2501                	sext.w	a0,a0
    80007294:	6422                	ld	s0,8(sp)
    80007296:	0141                	addi	sp,sp,16
    80007298:	8082                	ret
	...

0000000080008000 <_trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
	...
