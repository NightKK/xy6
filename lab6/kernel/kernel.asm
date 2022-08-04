
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	83010113          	addi	sp,sp,-2000 # 80009830 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	c8478793          	addi	a5,a5,-892 # 80005ce0 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffb87ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	f1278793          	addi	a5,a5,-238 # 80000fb8 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ec:	715d                	addi	sp,sp,-80
    800000ee:	e486                	sd	ra,72(sp)
    800000f0:	e0a2                	sd	s0,64(sp)
    800000f2:	fc26                	sd	s1,56(sp)
    800000f4:	f84a                	sd	s2,48(sp)
    800000f6:	f44e                	sd	s3,40(sp)
    800000f8:	f052                	sd	s4,32(sp)
    800000fa:	ec56                	sd	s5,24(sp)
    800000fc:	0880                	addi	s0,sp,80
    800000fe:	8a2a                	mv	s4,a0
    80000100:	84ae                	mv	s1,a1
    80000102:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000104:	00011517          	auipc	a0,0x11
    80000108:	72c50513          	addi	a0,a0,1836 # 80011830 <cons>
    8000010c:	00001097          	auipc	ra,0x1
    80000110:	c02080e7          	jalr	-1022(ra) # 80000d0e <acquire>
  for(i = 0; i < n; i++){
    80000114:	05305b63          	blez	s3,8000016a <consolewrite+0x7e>
    80000118:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011a:	5afd                	li	s5,-1
    8000011c:	4685                	li	a3,1
    8000011e:	8626                	mv	a2,s1
    80000120:	85d2                	mv	a1,s4
    80000122:	fbf40513          	addi	a0,s0,-65
    80000126:	00002097          	auipc	ra,0x2
    8000012a:	4a4080e7          	jalr	1188(ra) # 800025ca <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	796080e7          	jalr	1942(ra) # 800008cc <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	c74080e7          	jalr	-908(ra) # 80000dc2 <release>

  return i;
}
    80000156:	854a                	mv	a0,s2
    80000158:	60a6                	ld	ra,72(sp)
    8000015a:	6406                	ld	s0,64(sp)
    8000015c:	74e2                	ld	s1,56(sp)
    8000015e:	7942                	ld	s2,48(sp)
    80000160:	79a2                	ld	s3,40(sp)
    80000162:	7a02                	ld	s4,32(sp)
    80000164:	6ae2                	ld	s5,24(sp)
    80000166:	6161                	addi	sp,sp,80
    80000168:	8082                	ret
  for(i = 0; i < n; i++){
    8000016a:	4901                	li	s2,0
    8000016c:	bfe9                	j	80000146 <consolewrite+0x5a>

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	7159                	addi	sp,sp,-112
    80000170:	f486                	sd	ra,104(sp)
    80000172:	f0a2                	sd	s0,96(sp)
    80000174:	eca6                	sd	s1,88(sp)
    80000176:	e8ca                	sd	s2,80(sp)
    80000178:	e4ce                	sd	s3,72(sp)
    8000017a:	e0d2                	sd	s4,64(sp)
    8000017c:	fc56                	sd	s5,56(sp)
    8000017e:	f85a                	sd	s6,48(sp)
    80000180:	f45e                	sd	s7,40(sp)
    80000182:	f062                	sd	s8,32(sp)
    80000184:	ec66                	sd	s9,24(sp)
    80000186:	e86a                	sd	s10,16(sp)
    80000188:	1880                	addi	s0,sp,112
    8000018a:	8aaa                	mv	s5,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000194:	00011517          	auipc	a0,0x11
    80000198:	69c50513          	addi	a0,a0,1692 # 80011830 <cons>
    8000019c:	00001097          	auipc	ra,0x1
    800001a0:	b72080e7          	jalr	-1166(ra) # 80000d0e <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a4:	00011497          	auipc	s1,0x11
    800001a8:	68c48493          	addi	s1,s1,1676 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ac:	00011917          	auipc	s2,0x11
    800001b0:	71c90913          	addi	s2,s2,1820 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001b4:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b6:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b8:	4ca9                	li	s9,10
  while(n > 0){
    800001ba:	07305863          	blez	s3,8000022a <consoleread+0xbc>
    while(cons.r == cons.w){
    800001be:	0984a783          	lw	a5,152(s1)
    800001c2:	09c4a703          	lw	a4,156(s1)
    800001c6:	02f71463          	bne	a4,a5,800001ee <consoleread+0x80>
      if(myproc()->killed){
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	93c080e7          	jalr	-1732(ra) # 80001b06 <myproc>
    800001d2:	591c                	lw	a5,48(a0)
    800001d4:	e7b5                	bnez	a5,80000240 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001d6:	85a6                	mv	a1,s1
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	140080e7          	jalr	320(ra) # 8000231a <sleep>
    while(cons.r == cons.w){
    800001e2:	0984a783          	lw	a5,152(s1)
    800001e6:	09c4a703          	lw	a4,156(s1)
    800001ea:	fef700e3          	beq	a4,a5,800001ca <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001ee:	0017871b          	addiw	a4,a5,1
    800001f2:	08e4ac23          	sw	a4,152(s1)
    800001f6:	07f7f713          	andi	a4,a5,127
    800001fa:	9726                	add	a4,a4,s1
    800001fc:	01874703          	lbu	a4,24(a4)
    80000200:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000204:	077d0563          	beq	s10,s7,8000026e <consoleread+0x100>
    cbuf = c;
    80000208:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020c:	4685                	li	a3,1
    8000020e:	f9f40613          	addi	a2,s0,-97
    80000212:	85d2                	mv	a1,s4
    80000214:	8556                	mv	a0,s5
    80000216:	00002097          	auipc	ra,0x2
    8000021a:	35e080e7          	jalr	862(ra) # 80002574 <either_copyout>
    8000021e:	01850663          	beq	a0,s8,8000022a <consoleread+0xbc>
    dst++;
    80000222:	0a05                	addi	s4,s4,1
    --n;
    80000224:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000226:	f99d1ae3          	bne	s10,s9,800001ba <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022a:	00011517          	auipc	a0,0x11
    8000022e:	60650513          	addi	a0,a0,1542 # 80011830 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	b90080e7          	jalr	-1136(ra) # 80000dc2 <release>

  return target - n;
    8000023a:	413b053b          	subw	a0,s6,s3
    8000023e:	a811                	j	80000252 <consoleread+0xe4>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	5f050513          	addi	a0,a0,1520 # 80011830 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	b7a080e7          	jalr	-1158(ra) # 80000dc2 <release>
        return -1;
    80000250:	557d                	li	a0,-1
}
    80000252:	70a6                	ld	ra,104(sp)
    80000254:	7406                	ld	s0,96(sp)
    80000256:	64e6                	ld	s1,88(sp)
    80000258:	6946                	ld	s2,80(sp)
    8000025a:	69a6                	ld	s3,72(sp)
    8000025c:	6a06                	ld	s4,64(sp)
    8000025e:	7ae2                	ld	s5,56(sp)
    80000260:	7b42                	ld	s6,48(sp)
    80000262:	7ba2                	ld	s7,40(sp)
    80000264:	7c02                	ld	s8,32(sp)
    80000266:	6ce2                	ld	s9,24(sp)
    80000268:	6d42                	ld	s10,16(sp)
    8000026a:	6165                	addi	sp,sp,112
    8000026c:	8082                	ret
      if(n < target){
    8000026e:	0009871b          	sext.w	a4,s3
    80000272:	fb677ce3          	bgeu	a4,s6,8000022a <consoleread+0xbc>
        cons.r--;
    80000276:	00011717          	auipc	a4,0x11
    8000027a:	64f72923          	sw	a5,1618(a4) # 800118c8 <cons+0x98>
    8000027e:	b775                	j	8000022a <consoleread+0xbc>

0000000080000280 <consputc>:
{
    80000280:	1141                	addi	sp,sp,-16
    80000282:	e406                	sd	ra,8(sp)
    80000284:	e022                	sd	s0,0(sp)
    80000286:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000288:	10000793          	li	a5,256
    8000028c:	00f50a63          	beq	a0,a5,800002a0 <consputc+0x20>
    uartputc_sync(c);
    80000290:	00000097          	auipc	ra,0x0
    80000294:	55e080e7          	jalr	1374(ra) # 800007ee <uartputc_sync>
}
    80000298:	60a2                	ld	ra,8(sp)
    8000029a:	6402                	ld	s0,0(sp)
    8000029c:	0141                	addi	sp,sp,16
    8000029e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a0:	4521                	li	a0,8
    800002a2:	00000097          	auipc	ra,0x0
    800002a6:	54c080e7          	jalr	1356(ra) # 800007ee <uartputc_sync>
    800002aa:	02000513          	li	a0,32
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	540080e7          	jalr	1344(ra) # 800007ee <uartputc_sync>
    800002b6:	4521                	li	a0,8
    800002b8:	00000097          	auipc	ra,0x0
    800002bc:	536080e7          	jalr	1334(ra) # 800007ee <uartputc_sync>
    800002c0:	bfe1                	j	80000298 <consputc+0x18>

00000000800002c2 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c2:	1101                	addi	sp,sp,-32
    800002c4:	ec06                	sd	ra,24(sp)
    800002c6:	e822                	sd	s0,16(sp)
    800002c8:	e426                	sd	s1,8(sp)
    800002ca:	e04a                	sd	s2,0(sp)
    800002cc:	1000                	addi	s0,sp,32
    800002ce:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d0:	00011517          	auipc	a0,0x11
    800002d4:	56050513          	addi	a0,a0,1376 # 80011830 <cons>
    800002d8:	00001097          	auipc	ra,0x1
    800002dc:	a36080e7          	jalr	-1482(ra) # 80000d0e <acquire>

  switch(c){
    800002e0:	47d5                	li	a5,21
    800002e2:	0af48663          	beq	s1,a5,8000038e <consoleintr+0xcc>
    800002e6:	0297ca63          	blt	a5,s1,8000031a <consoleintr+0x58>
    800002ea:	47a1                	li	a5,8
    800002ec:	0ef48763          	beq	s1,a5,800003da <consoleintr+0x118>
    800002f0:	47c1                	li	a5,16
    800002f2:	10f49a63          	bne	s1,a5,80000406 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f6:	00002097          	auipc	ra,0x2
    800002fa:	32a080e7          	jalr	810(ra) # 80002620 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fe:	00011517          	auipc	a0,0x11
    80000302:	53250513          	addi	a0,a0,1330 # 80011830 <cons>
    80000306:	00001097          	auipc	ra,0x1
    8000030a:	abc080e7          	jalr	-1348(ra) # 80000dc2 <release>
}
    8000030e:	60e2                	ld	ra,24(sp)
    80000310:	6442                	ld	s0,16(sp)
    80000312:	64a2                	ld	s1,8(sp)
    80000314:	6902                	ld	s2,0(sp)
    80000316:	6105                	addi	sp,sp,32
    80000318:	8082                	ret
  switch(c){
    8000031a:	07f00793          	li	a5,127
    8000031e:	0af48e63          	beq	s1,a5,800003da <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000322:	00011717          	auipc	a4,0x11
    80000326:	50e70713          	addi	a4,a4,1294 # 80011830 <cons>
    8000032a:	0a072783          	lw	a5,160(a4)
    8000032e:	09872703          	lw	a4,152(a4)
    80000332:	9f99                	subw	a5,a5,a4
    80000334:	07f00713          	li	a4,127
    80000338:	fcf763e3          	bltu	a4,a5,800002fe <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000033c:	47b5                	li	a5,13
    8000033e:	0cf48763          	beq	s1,a5,8000040c <consoleintr+0x14a>
      consputc(c);
    80000342:	8526                	mv	a0,s1
    80000344:	00000097          	auipc	ra,0x0
    80000348:	f3c080e7          	jalr	-196(ra) # 80000280 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000034c:	00011797          	auipc	a5,0x11
    80000350:	4e478793          	addi	a5,a5,1252 # 80011830 <cons>
    80000354:	0a07a703          	lw	a4,160(a5)
    80000358:	0017069b          	addiw	a3,a4,1
    8000035c:	0006861b          	sext.w	a2,a3
    80000360:	0ad7a023          	sw	a3,160(a5)
    80000364:	07f77713          	andi	a4,a4,127
    80000368:	97ba                	add	a5,a5,a4
    8000036a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000036e:	47a9                	li	a5,10
    80000370:	0cf48563          	beq	s1,a5,8000043a <consoleintr+0x178>
    80000374:	4791                	li	a5,4
    80000376:	0cf48263          	beq	s1,a5,8000043a <consoleintr+0x178>
    8000037a:	00011797          	auipc	a5,0x11
    8000037e:	54e7a783          	lw	a5,1358(a5) # 800118c8 <cons+0x98>
    80000382:	0807879b          	addiw	a5,a5,128
    80000386:	f6f61ce3          	bne	a2,a5,800002fe <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000038a:	863e                	mv	a2,a5
    8000038c:	a07d                	j	8000043a <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038e:	00011717          	auipc	a4,0x11
    80000392:	4a270713          	addi	a4,a4,1186 # 80011830 <cons>
    80000396:	0a072783          	lw	a5,160(a4)
    8000039a:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000039e:	00011497          	auipc	s1,0x11
    800003a2:	49248493          	addi	s1,s1,1170 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003a6:	4929                	li	s2,10
    800003a8:	f4f70be3          	beq	a4,a5,800002fe <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ac:	37fd                	addiw	a5,a5,-1
    800003ae:	07f7f713          	andi	a4,a5,127
    800003b2:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b4:	01874703          	lbu	a4,24(a4)
    800003b8:	f52703e3          	beq	a4,s2,800002fe <consoleintr+0x3c>
      cons.e--;
    800003bc:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c0:	10000513          	li	a0,256
    800003c4:	00000097          	auipc	ra,0x0
    800003c8:	ebc080e7          	jalr	-324(ra) # 80000280 <consputc>
    while(cons.e != cons.w &&
    800003cc:	0a04a783          	lw	a5,160(s1)
    800003d0:	09c4a703          	lw	a4,156(s1)
    800003d4:	fcf71ce3          	bne	a4,a5,800003ac <consoleintr+0xea>
    800003d8:	b71d                	j	800002fe <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003da:	00011717          	auipc	a4,0x11
    800003de:	45670713          	addi	a4,a4,1110 # 80011830 <cons>
    800003e2:	0a072783          	lw	a5,160(a4)
    800003e6:	09c72703          	lw	a4,156(a4)
    800003ea:	f0f70ae3          	beq	a4,a5,800002fe <consoleintr+0x3c>
      cons.e--;
    800003ee:	37fd                	addiw	a5,a5,-1
    800003f0:	00011717          	auipc	a4,0x11
    800003f4:	4ef72023          	sw	a5,1248(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f8:	10000513          	li	a0,256
    800003fc:	00000097          	auipc	ra,0x0
    80000400:	e84080e7          	jalr	-380(ra) # 80000280 <consputc>
    80000404:	bded                	j	800002fe <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000406:	ee048ce3          	beqz	s1,800002fe <consoleintr+0x3c>
    8000040a:	bf21                	j	80000322 <consoleintr+0x60>
      consputc(c);
    8000040c:	4529                	li	a0,10
    8000040e:	00000097          	auipc	ra,0x0
    80000412:	e72080e7          	jalr	-398(ra) # 80000280 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000416:	00011797          	auipc	a5,0x11
    8000041a:	41a78793          	addi	a5,a5,1050 # 80011830 <cons>
    8000041e:	0a07a703          	lw	a4,160(a5)
    80000422:	0017069b          	addiw	a3,a4,1
    80000426:	0006861b          	sext.w	a2,a3
    8000042a:	0ad7a023          	sw	a3,160(a5)
    8000042e:	07f77713          	andi	a4,a4,127
    80000432:	97ba                	add	a5,a5,a4
    80000434:	4729                	li	a4,10
    80000436:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043a:	00011797          	auipc	a5,0x11
    8000043e:	48c7a923          	sw	a2,1170(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000442:	00011517          	auipc	a0,0x11
    80000446:	48650513          	addi	a0,a0,1158 # 800118c8 <cons+0x98>
    8000044a:	00002097          	auipc	ra,0x2
    8000044e:	050080e7          	jalr	80(ra) # 8000249a <wakeup>
    80000452:	b575                	j	800002fe <consoleintr+0x3c>

0000000080000454 <consoleinit>:

void
consoleinit(void)
{
    80000454:	1141                	addi	sp,sp,-16
    80000456:	e406                	sd	ra,8(sp)
    80000458:	e022                	sd	s0,0(sp)
    8000045a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000045c:	00008597          	auipc	a1,0x8
    80000460:	bb458593          	addi	a1,a1,-1100 # 80008010 <etext+0x10>
    80000464:	00011517          	auipc	a0,0x11
    80000468:	3cc50513          	addi	a0,a0,972 # 80011830 <cons>
    8000046c:	00001097          	auipc	ra,0x1
    80000470:	812080e7          	jalr	-2030(ra) # 80000c7e <initlock>

  uartinit();
    80000474:	00000097          	auipc	ra,0x0
    80000478:	32a080e7          	jalr	810(ra) # 8000079e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047c:	00041797          	auipc	a5,0x41
    80000480:	53478793          	addi	a5,a5,1332 # 800419b0 <devsw>
    80000484:	00000717          	auipc	a4,0x0
    80000488:	cea70713          	addi	a4,a4,-790 # 8000016e <consoleread>
    8000048c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048e:	00000717          	auipc	a4,0x0
    80000492:	c5e70713          	addi	a4,a4,-930 # 800000ec <consolewrite>
    80000496:	ef98                	sd	a4,24(a5)
}
    80000498:	60a2                	ld	ra,8(sp)
    8000049a:	6402                	ld	s0,0(sp)
    8000049c:	0141                	addi	sp,sp,16
    8000049e:	8082                	ret

00000000800004a0 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a0:	7179                	addi	sp,sp,-48
    800004a2:	f406                	sd	ra,40(sp)
    800004a4:	f022                	sd	s0,32(sp)
    800004a6:	ec26                	sd	s1,24(sp)
    800004a8:	e84a                	sd	s2,16(sp)
    800004aa:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ac:	c219                	beqz	a2,800004b2 <printint+0x12>
    800004ae:	08054663          	bltz	a0,8000053a <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b2:	2501                	sext.w	a0,a0
    800004b4:	4881                	li	a7,0
    800004b6:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004ba:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004bc:	2581                	sext.w	a1,a1
    800004be:	00008617          	auipc	a2,0x8
    800004c2:	b8260613          	addi	a2,a2,-1150 # 80008040 <digits>
    800004c6:	883a                	mv	a6,a4
    800004c8:	2705                	addiw	a4,a4,1
    800004ca:	02b577bb          	remuw	a5,a0,a1
    800004ce:	1782                	slli	a5,a5,0x20
    800004d0:	9381                	srli	a5,a5,0x20
    800004d2:	97b2                	add	a5,a5,a2
    800004d4:	0007c783          	lbu	a5,0(a5)
    800004d8:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004dc:	0005079b          	sext.w	a5,a0
    800004e0:	02b5553b          	divuw	a0,a0,a1
    800004e4:	0685                	addi	a3,a3,1
    800004e6:	feb7f0e3          	bgeu	a5,a1,800004c6 <printint+0x26>

  if(sign)
    800004ea:	00088b63          	beqz	a7,80000500 <printint+0x60>
    buf[i++] = '-';
    800004ee:	fe040793          	addi	a5,s0,-32
    800004f2:	973e                	add	a4,a4,a5
    800004f4:	02d00793          	li	a5,45
    800004f8:	fef70823          	sb	a5,-16(a4)
    800004fc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000500:	02e05763          	blez	a4,8000052e <printint+0x8e>
    80000504:	fd040793          	addi	a5,s0,-48
    80000508:	00e784b3          	add	s1,a5,a4
    8000050c:	fff78913          	addi	s2,a5,-1
    80000510:	993a                	add	s2,s2,a4
    80000512:	377d                	addiw	a4,a4,-1
    80000514:	1702                	slli	a4,a4,0x20
    80000516:	9301                	srli	a4,a4,0x20
    80000518:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051c:	fff4c503          	lbu	a0,-1(s1)
    80000520:	00000097          	auipc	ra,0x0
    80000524:	d60080e7          	jalr	-672(ra) # 80000280 <consputc>
  while(--i >= 0)
    80000528:	14fd                	addi	s1,s1,-1
    8000052a:	ff2499e3          	bne	s1,s2,8000051c <printint+0x7c>
}
    8000052e:	70a2                	ld	ra,40(sp)
    80000530:	7402                	ld	s0,32(sp)
    80000532:	64e2                	ld	s1,24(sp)
    80000534:	6942                	ld	s2,16(sp)
    80000536:	6145                	addi	sp,sp,48
    80000538:	8082                	ret
    x = -xx;
    8000053a:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053e:	4885                	li	a7,1
    x = -xx;
    80000540:	bf9d                	j	800004b6 <printint+0x16>

0000000080000542 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000542:	1101                	addi	sp,sp,-32
    80000544:	ec06                	sd	ra,24(sp)
    80000546:	e822                	sd	s0,16(sp)
    80000548:	e426                	sd	s1,8(sp)
    8000054a:	1000                	addi	s0,sp,32
    8000054c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054e:	00011797          	auipc	a5,0x11
    80000552:	3a07a123          	sw	zero,930(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    80000556:	00008517          	auipc	a0,0x8
    8000055a:	ac250513          	addi	a0,a0,-1342 # 80008018 <etext+0x18>
    8000055e:	00000097          	auipc	ra,0x0
    80000562:	02e080e7          	jalr	46(ra) # 8000058c <printf>
  printf(s);
    80000566:	8526                	mv	a0,s1
    80000568:	00000097          	auipc	ra,0x0
    8000056c:	024080e7          	jalr	36(ra) # 8000058c <printf>
  printf("\n");
    80000570:	00008517          	auipc	a0,0x8
    80000574:	b5850513          	addi	a0,a0,-1192 # 800080c8 <digits+0x88>
    80000578:	00000097          	auipc	ra,0x0
    8000057c:	014080e7          	jalr	20(ra) # 8000058c <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000580:	4785                	li	a5,1
    80000582:	00009717          	auipc	a4,0x9
    80000586:	a6f72f23          	sw	a5,-1410(a4) # 80009000 <panicked>
  for(;;)
    8000058a:	a001                	j	8000058a <panic+0x48>

000000008000058c <printf>:
{
    8000058c:	7131                	addi	sp,sp,-192
    8000058e:	fc86                	sd	ra,120(sp)
    80000590:	f8a2                	sd	s0,112(sp)
    80000592:	f4a6                	sd	s1,104(sp)
    80000594:	f0ca                	sd	s2,96(sp)
    80000596:	ecce                	sd	s3,88(sp)
    80000598:	e8d2                	sd	s4,80(sp)
    8000059a:	e4d6                	sd	s5,72(sp)
    8000059c:	e0da                	sd	s6,64(sp)
    8000059e:	fc5e                	sd	s7,56(sp)
    800005a0:	f862                	sd	s8,48(sp)
    800005a2:	f466                	sd	s9,40(sp)
    800005a4:	f06a                	sd	s10,32(sp)
    800005a6:	ec6e                	sd	s11,24(sp)
    800005a8:	0100                	addi	s0,sp,128
    800005aa:	8a2a                	mv	s4,a0
    800005ac:	e40c                	sd	a1,8(s0)
    800005ae:	e810                	sd	a2,16(s0)
    800005b0:	ec14                	sd	a3,24(s0)
    800005b2:	f018                	sd	a4,32(s0)
    800005b4:	f41c                	sd	a5,40(s0)
    800005b6:	03043823          	sd	a6,48(s0)
    800005ba:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005be:	00011d97          	auipc	s11,0x11
    800005c2:	332dad83          	lw	s11,818(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005c6:	020d9b63          	bnez	s11,800005fc <printf+0x70>
  if (fmt == 0)
    800005ca:	040a0263          	beqz	s4,8000060e <printf+0x82>
  va_start(ap, fmt);
    800005ce:	00840793          	addi	a5,s0,8
    800005d2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d6:	000a4503          	lbu	a0,0(s4)
    800005da:	14050f63          	beqz	a0,80000738 <printf+0x1ac>
    800005de:	4981                	li	s3,0
    if(c != '%'){
    800005e0:	02500a93          	li	s5,37
    switch(c){
    800005e4:	07000b93          	li	s7,112
  consputc('x');
    800005e8:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005ea:	00008b17          	auipc	s6,0x8
    800005ee:	a56b0b13          	addi	s6,s6,-1450 # 80008040 <digits>
    switch(c){
    800005f2:	07300c93          	li	s9,115
    800005f6:	06400c13          	li	s8,100
    800005fa:	a82d                	j	80000634 <printf+0xa8>
    acquire(&pr.lock);
    800005fc:	00011517          	auipc	a0,0x11
    80000600:	2dc50513          	addi	a0,a0,732 # 800118d8 <pr>
    80000604:	00000097          	auipc	ra,0x0
    80000608:	70a080e7          	jalr	1802(ra) # 80000d0e <acquire>
    8000060c:	bf7d                	j	800005ca <printf+0x3e>
    panic("null fmt");
    8000060e:	00008517          	auipc	a0,0x8
    80000612:	a1a50513          	addi	a0,a0,-1510 # 80008028 <etext+0x28>
    80000616:	00000097          	auipc	ra,0x0
    8000061a:	f2c080e7          	jalr	-212(ra) # 80000542 <panic>
      consputc(c);
    8000061e:	00000097          	auipc	ra,0x0
    80000622:	c62080e7          	jalr	-926(ra) # 80000280 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000626:	2985                	addiw	s3,s3,1
    80000628:	013a07b3          	add	a5,s4,s3
    8000062c:	0007c503          	lbu	a0,0(a5)
    80000630:	10050463          	beqz	a0,80000738 <printf+0x1ac>
    if(c != '%'){
    80000634:	ff5515e3          	bne	a0,s5,8000061e <printf+0x92>
    c = fmt[++i] & 0xff;
    80000638:	2985                	addiw	s3,s3,1
    8000063a:	013a07b3          	add	a5,s4,s3
    8000063e:	0007c783          	lbu	a5,0(a5)
    80000642:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000646:	cbed                	beqz	a5,80000738 <printf+0x1ac>
    switch(c){
    80000648:	05778a63          	beq	a5,s7,8000069c <printf+0x110>
    8000064c:	02fbf663          	bgeu	s7,a5,80000678 <printf+0xec>
    80000650:	09978863          	beq	a5,s9,800006e0 <printf+0x154>
    80000654:	07800713          	li	a4,120
    80000658:	0ce79563          	bne	a5,a4,80000722 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065c:	f8843783          	ld	a5,-120(s0)
    80000660:	00878713          	addi	a4,a5,8
    80000664:	f8e43423          	sd	a4,-120(s0)
    80000668:	4605                	li	a2,1
    8000066a:	85ea                	mv	a1,s10
    8000066c:	4388                	lw	a0,0(a5)
    8000066e:	00000097          	auipc	ra,0x0
    80000672:	e32080e7          	jalr	-462(ra) # 800004a0 <printint>
      break;
    80000676:	bf45                	j	80000626 <printf+0x9a>
    switch(c){
    80000678:	09578f63          	beq	a5,s5,80000716 <printf+0x18a>
    8000067c:	0b879363          	bne	a5,s8,80000722 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000680:	f8843783          	ld	a5,-120(s0)
    80000684:	00878713          	addi	a4,a5,8
    80000688:	f8e43423          	sd	a4,-120(s0)
    8000068c:	4605                	li	a2,1
    8000068e:	45a9                	li	a1,10
    80000690:	4388                	lw	a0,0(a5)
    80000692:	00000097          	auipc	ra,0x0
    80000696:	e0e080e7          	jalr	-498(ra) # 800004a0 <printint>
      break;
    8000069a:	b771                	j	80000626 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069c:	f8843783          	ld	a5,-120(s0)
    800006a0:	00878713          	addi	a4,a5,8
    800006a4:	f8e43423          	sd	a4,-120(s0)
    800006a8:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006ac:	03000513          	li	a0,48
    800006b0:	00000097          	auipc	ra,0x0
    800006b4:	bd0080e7          	jalr	-1072(ra) # 80000280 <consputc>
  consputc('x');
    800006b8:	07800513          	li	a0,120
    800006bc:	00000097          	auipc	ra,0x0
    800006c0:	bc4080e7          	jalr	-1084(ra) # 80000280 <consputc>
    800006c4:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c6:	03c95793          	srli	a5,s2,0x3c
    800006ca:	97da                	add	a5,a5,s6
    800006cc:	0007c503          	lbu	a0,0(a5)
    800006d0:	00000097          	auipc	ra,0x0
    800006d4:	bb0080e7          	jalr	-1104(ra) # 80000280 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d8:	0912                	slli	s2,s2,0x4
    800006da:	34fd                	addiw	s1,s1,-1
    800006dc:	f4ed                	bnez	s1,800006c6 <printf+0x13a>
    800006de:	b7a1                	j	80000626 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e0:	f8843783          	ld	a5,-120(s0)
    800006e4:	00878713          	addi	a4,a5,8
    800006e8:	f8e43423          	sd	a4,-120(s0)
    800006ec:	6384                	ld	s1,0(a5)
    800006ee:	cc89                	beqz	s1,80000708 <printf+0x17c>
      for(; *s; s++)
    800006f0:	0004c503          	lbu	a0,0(s1)
    800006f4:	d90d                	beqz	a0,80000626 <printf+0x9a>
        consputc(*s);
    800006f6:	00000097          	auipc	ra,0x0
    800006fa:	b8a080e7          	jalr	-1142(ra) # 80000280 <consputc>
      for(; *s; s++)
    800006fe:	0485                	addi	s1,s1,1
    80000700:	0004c503          	lbu	a0,0(s1)
    80000704:	f96d                	bnez	a0,800006f6 <printf+0x16a>
    80000706:	b705                	j	80000626 <printf+0x9a>
        s = "(null)";
    80000708:	00008497          	auipc	s1,0x8
    8000070c:	91848493          	addi	s1,s1,-1768 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000710:	02800513          	li	a0,40
    80000714:	b7cd                	j	800006f6 <printf+0x16a>
      consputc('%');
    80000716:	8556                	mv	a0,s5
    80000718:	00000097          	auipc	ra,0x0
    8000071c:	b68080e7          	jalr	-1176(ra) # 80000280 <consputc>
      break;
    80000720:	b719                	j	80000626 <printf+0x9a>
      consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b5c080e7          	jalr	-1188(ra) # 80000280 <consputc>
      consputc(c);
    8000072c:	8526                	mv	a0,s1
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	b52080e7          	jalr	-1198(ra) # 80000280 <consputc>
      break;
    80000736:	bdc5                	j	80000626 <printf+0x9a>
  if(locking)
    80000738:	020d9163          	bnez	s11,8000075a <printf+0x1ce>
}
    8000073c:	70e6                	ld	ra,120(sp)
    8000073e:	7446                	ld	s0,112(sp)
    80000740:	74a6                	ld	s1,104(sp)
    80000742:	7906                	ld	s2,96(sp)
    80000744:	69e6                	ld	s3,88(sp)
    80000746:	6a46                	ld	s4,80(sp)
    80000748:	6aa6                	ld	s5,72(sp)
    8000074a:	6b06                	ld	s6,64(sp)
    8000074c:	7be2                	ld	s7,56(sp)
    8000074e:	7c42                	ld	s8,48(sp)
    80000750:	7ca2                	ld	s9,40(sp)
    80000752:	7d02                	ld	s10,32(sp)
    80000754:	6de2                	ld	s11,24(sp)
    80000756:	6129                	addi	sp,sp,192
    80000758:	8082                	ret
    release(&pr.lock);
    8000075a:	00011517          	auipc	a0,0x11
    8000075e:	17e50513          	addi	a0,a0,382 # 800118d8 <pr>
    80000762:	00000097          	auipc	ra,0x0
    80000766:	660080e7          	jalr	1632(ra) # 80000dc2 <release>
}
    8000076a:	bfc9                	j	8000073c <printf+0x1b0>

000000008000076c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076c:	1101                	addi	sp,sp,-32
    8000076e:	ec06                	sd	ra,24(sp)
    80000770:	e822                	sd	s0,16(sp)
    80000772:	e426                	sd	s1,8(sp)
    80000774:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000776:	00011497          	auipc	s1,0x11
    8000077a:	16248493          	addi	s1,s1,354 # 800118d8 <pr>
    8000077e:	00008597          	auipc	a1,0x8
    80000782:	8ba58593          	addi	a1,a1,-1862 # 80008038 <etext+0x38>
    80000786:	8526                	mv	a0,s1
    80000788:	00000097          	auipc	ra,0x0
    8000078c:	4f6080e7          	jalr	1270(ra) # 80000c7e <initlock>
  pr.locking = 1;
    80000790:	4785                	li	a5,1
    80000792:	cc9c                	sw	a5,24(s1)
}
    80000794:	60e2                	ld	ra,24(sp)
    80000796:	6442                	ld	s0,16(sp)
    80000798:	64a2                	ld	s1,8(sp)
    8000079a:	6105                	addi	sp,sp,32
    8000079c:	8082                	ret

000000008000079e <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079e:	1141                	addi	sp,sp,-16
    800007a0:	e406                	sd	ra,8(sp)
    800007a2:	e022                	sd	s0,0(sp)
    800007a4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a6:	100007b7          	lui	a5,0x10000
    800007aa:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ae:	f8000713          	li	a4,-128
    800007b2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b6:	470d                	li	a4,3
    800007b8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007bc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c4:	469d                	li	a3,7
    800007c6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007ca:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ce:	00008597          	auipc	a1,0x8
    800007d2:	88a58593          	addi	a1,a1,-1910 # 80008058 <digits+0x18>
    800007d6:	00011517          	auipc	a0,0x11
    800007da:	12250513          	addi	a0,a0,290 # 800118f8 <uart_tx_lock>
    800007de:	00000097          	auipc	ra,0x0
    800007e2:	4a0080e7          	jalr	1184(ra) # 80000c7e <initlock>
}
    800007e6:	60a2                	ld	ra,8(sp)
    800007e8:	6402                	ld	s0,0(sp)
    800007ea:	0141                	addi	sp,sp,16
    800007ec:	8082                	ret

00000000800007ee <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ee:	1101                	addi	sp,sp,-32
    800007f0:	ec06                	sd	ra,24(sp)
    800007f2:	e822                	sd	s0,16(sp)
    800007f4:	e426                	sd	s1,8(sp)
    800007f6:	1000                	addi	s0,sp,32
    800007f8:	84aa                	mv	s1,a0
  push_off();
    800007fa:	00000097          	auipc	ra,0x0
    800007fe:	4c8080e7          	jalr	1224(ra) # 80000cc2 <push_off>

  if(panicked){
    80000802:	00008797          	auipc	a5,0x8
    80000806:	7fe7a783          	lw	a5,2046(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080e:	c391                	beqz	a5,80000812 <uartputc_sync+0x24>
    for(;;)
    80000810:	a001                	j	80000810 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000812:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000816:	0207f793          	andi	a5,a5,32
    8000081a:	dfe5                	beqz	a5,80000812 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081c:	0ff4f513          	andi	a0,s1,255
    80000820:	100007b7          	lui	a5,0x10000
    80000824:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000828:	00000097          	auipc	ra,0x0
    8000082c:	53a080e7          	jalr	1338(ra) # 80000d62 <pop_off>
}
    80000830:	60e2                	ld	ra,24(sp)
    80000832:	6442                	ld	s0,16(sp)
    80000834:	64a2                	ld	s1,8(sp)
    80000836:	6105                	addi	sp,sp,32
    80000838:	8082                	ret

000000008000083a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000083a:	00008797          	auipc	a5,0x8
    8000083e:	7ca7a783          	lw	a5,1994(a5) # 80009004 <uart_tx_r>
    80000842:	00008717          	auipc	a4,0x8
    80000846:	7c672703          	lw	a4,1990(a4) # 80009008 <uart_tx_w>
    8000084a:	08f70063          	beq	a4,a5,800008ca <uartstart+0x90>
{
    8000084e:	7139                	addi	sp,sp,-64
    80000850:	fc06                	sd	ra,56(sp)
    80000852:	f822                	sd	s0,48(sp)
    80000854:	f426                	sd	s1,40(sp)
    80000856:	f04a                	sd	s2,32(sp)
    80000858:	ec4e                	sd	s3,24(sp)
    8000085a:	e852                	sd	s4,16(sp)
    8000085c:	e456                	sd	s5,8(sp)
    8000085e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000860:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    80000864:	00011a97          	auipc	s5,0x11
    80000868:	094a8a93          	addi	s5,s5,148 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000086c:	00008497          	auipc	s1,0x8
    80000870:	79848493          	addi	s1,s1,1944 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000874:	00008a17          	auipc	s4,0x8
    80000878:	794a0a13          	addi	s4,s4,1940 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000880:	02077713          	andi	a4,a4,32
    80000884:	cb15                	beqz	a4,800008b8 <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r];
    80000886:	00fa8733          	add	a4,s5,a5
    8000088a:	01874983          	lbu	s3,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000088e:	2785                	addiw	a5,a5,1
    80000890:	41f7d71b          	sraiw	a4,a5,0x1f
    80000894:	01b7571b          	srliw	a4,a4,0x1b
    80000898:	9fb9                	addw	a5,a5,a4
    8000089a:	8bfd                	andi	a5,a5,31
    8000089c:	9f99                	subw	a5,a5,a4
    8000089e:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a0:	8526                	mv	a0,s1
    800008a2:	00002097          	auipc	ra,0x2
    800008a6:	bf8080e7          	jalr	-1032(ra) # 8000249a <wakeup>
    
    WriteReg(THR, c);
    800008aa:	01390023          	sb	s3,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ae:	409c                	lw	a5,0(s1)
    800008b0:	000a2703          	lw	a4,0(s4)
    800008b4:	fcf714e3          	bne	a4,a5,8000087c <uartstart+0x42>
  }
}
    800008b8:	70e2                	ld	ra,56(sp)
    800008ba:	7442                	ld	s0,48(sp)
    800008bc:	74a2                	ld	s1,40(sp)
    800008be:	7902                	ld	s2,32(sp)
    800008c0:	69e2                	ld	s3,24(sp)
    800008c2:	6a42                	ld	s4,16(sp)
    800008c4:	6aa2                	ld	s5,8(sp)
    800008c6:	6121                	addi	sp,sp,64
    800008c8:	8082                	ret
    800008ca:	8082                	ret

00000000800008cc <uartputc>:
{
    800008cc:	7179                	addi	sp,sp,-48
    800008ce:	f406                	sd	ra,40(sp)
    800008d0:	f022                	sd	s0,32(sp)
    800008d2:	ec26                	sd	s1,24(sp)
    800008d4:	e84a                	sd	s2,16(sp)
    800008d6:	e44e                	sd	s3,8(sp)
    800008d8:	e052                	sd	s4,0(sp)
    800008da:	1800                	addi	s0,sp,48
    800008dc:	84aa                	mv	s1,a0
  acquire(&uart_tx_lock);
    800008de:	00011517          	auipc	a0,0x11
    800008e2:	01a50513          	addi	a0,a0,26 # 800118f8 <uart_tx_lock>
    800008e6:	00000097          	auipc	ra,0x0
    800008ea:	428080e7          	jalr	1064(ra) # 80000d0e <acquire>
  if(panicked){
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	7127a783          	lw	a5,1810(a5) # 80009000 <panicked>
    800008f6:	c391                	beqz	a5,800008fa <uartputc+0x2e>
    for(;;)
    800008f8:	a001                	j	800008f8 <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800008fa:	00008697          	auipc	a3,0x8
    800008fe:	70e6a683          	lw	a3,1806(a3) # 80009008 <uart_tx_w>
    80000902:	0016879b          	addiw	a5,a3,1
    80000906:	41f7d71b          	sraiw	a4,a5,0x1f
    8000090a:	01b7571b          	srliw	a4,a4,0x1b
    8000090e:	9fb9                	addw	a5,a5,a4
    80000910:	8bfd                	andi	a5,a5,31
    80000912:	9f99                	subw	a5,a5,a4
    80000914:	00008717          	auipc	a4,0x8
    80000918:	6f072703          	lw	a4,1776(a4) # 80009004 <uart_tx_r>
    8000091c:	04f71363          	bne	a4,a5,80000962 <uartputc+0x96>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000920:	00011a17          	auipc	s4,0x11
    80000924:	fd8a0a13          	addi	s4,s4,-40 # 800118f8 <uart_tx_lock>
    80000928:	00008917          	auipc	s2,0x8
    8000092c:	6dc90913          	addi	s2,s2,1756 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000930:	00008997          	auipc	s3,0x8
    80000934:	6d898993          	addi	s3,s3,1752 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000938:	85d2                	mv	a1,s4
    8000093a:	854a                	mv	a0,s2
    8000093c:	00002097          	auipc	ra,0x2
    80000940:	9de080e7          	jalr	-1570(ra) # 8000231a <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000944:	0009a683          	lw	a3,0(s3)
    80000948:	0016879b          	addiw	a5,a3,1
    8000094c:	41f7d71b          	sraiw	a4,a5,0x1f
    80000950:	01b7571b          	srliw	a4,a4,0x1b
    80000954:	9fb9                	addw	a5,a5,a4
    80000956:	8bfd                	andi	a5,a5,31
    80000958:	9f99                	subw	a5,a5,a4
    8000095a:	00092703          	lw	a4,0(s2)
    8000095e:	fcf70de3          	beq	a4,a5,80000938 <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000962:	00011917          	auipc	s2,0x11
    80000966:	f9690913          	addi	s2,s2,-106 # 800118f8 <uart_tx_lock>
    8000096a:	96ca                	add	a3,a3,s2
    8000096c:	00968c23          	sb	s1,24(a3)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000970:	00008717          	auipc	a4,0x8
    80000974:	68f72c23          	sw	a5,1688(a4) # 80009008 <uart_tx_w>
      uartstart();
    80000978:	00000097          	auipc	ra,0x0
    8000097c:	ec2080e7          	jalr	-318(ra) # 8000083a <uartstart>
      release(&uart_tx_lock);
    80000980:	854a                	mv	a0,s2
    80000982:	00000097          	auipc	ra,0x0
    80000986:	440080e7          	jalr	1088(ra) # 80000dc2 <release>
}
    8000098a:	70a2                	ld	ra,40(sp)
    8000098c:	7402                	ld	s0,32(sp)
    8000098e:	64e2                	ld	s1,24(sp)
    80000990:	6942                	ld	s2,16(sp)
    80000992:	69a2                	ld	s3,8(sp)
    80000994:	6a02                	ld	s4,0(sp)
    80000996:	6145                	addi	sp,sp,48
    80000998:	8082                	ret

000000008000099a <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000099a:	1141                	addi	sp,sp,-16
    8000099c:	e422                	sd	s0,8(sp)
    8000099e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009a0:	100007b7          	lui	a5,0x10000
    800009a4:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009a8:	8b85                	andi	a5,a5,1
    800009aa:	cb91                	beqz	a5,800009be <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009ac:	100007b7          	lui	a5,0x10000
    800009b0:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009b4:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009b8:	6422                	ld	s0,8(sp)
    800009ba:	0141                	addi	sp,sp,16
    800009bc:	8082                	ret
    return -1;
    800009be:	557d                	li	a0,-1
    800009c0:	bfe5                	j	800009b8 <uartgetc+0x1e>

00000000800009c2 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009c2:	1101                	addi	sp,sp,-32
    800009c4:	ec06                	sd	ra,24(sp)
    800009c6:	e822                	sd	s0,16(sp)
    800009c8:	e426                	sd	s1,8(sp)
    800009ca:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009cc:	54fd                	li	s1,-1
    800009ce:	a029                	j	800009d8 <uartintr+0x16>
      break;
    consoleintr(c);
    800009d0:	00000097          	auipc	ra,0x0
    800009d4:	8f2080e7          	jalr	-1806(ra) # 800002c2 <consoleintr>
    int c = uartgetc();
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	fc2080e7          	jalr	-62(ra) # 8000099a <uartgetc>
    if(c == -1)
    800009e0:	fe9518e3          	bne	a0,s1,800009d0 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009e4:	00011497          	auipc	s1,0x11
    800009e8:	f1448493          	addi	s1,s1,-236 # 800118f8 <uart_tx_lock>
    800009ec:	8526                	mv	a0,s1
    800009ee:	00000097          	auipc	ra,0x0
    800009f2:	320080e7          	jalr	800(ra) # 80000d0e <acquire>
  uartstart();
    800009f6:	00000097          	auipc	ra,0x0
    800009fa:	e44080e7          	jalr	-444(ra) # 8000083a <uartstart>
  release(&uart_tx_lock);
    800009fe:	8526                	mv	a0,s1
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	3c2080e7          	jalr	962(ra) # 80000dc2 <release>
}
    80000a08:	60e2                	ld	ra,24(sp)
    80000a0a:	6442                	ld	s0,16(sp)
    80000a0c:	64a2                	ld	s1,8(sp)
    80000a0e:	6105                	addi	sp,sp,32
    80000a10:	8082                	ret

0000000080000a12 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a12:	1101                	addi	sp,sp,-32
    80000a14:	ec06                	sd	ra,24(sp)
    80000a16:	e822                	sd	s0,16(sp)
    80000a18:	e426                	sd	s1,8(sp)
    80000a1a:	e04a                	sd	s2,0(sp)
    80000a1c:	1000                	addi	s0,sp,32
  struct run *r;  

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a1e:	03451793          	slli	a5,a0,0x34
    80000a22:	eba9                	bnez	a5,80000a74 <kfree+0x62>
    80000a24:	84aa                	mv	s1,a0
    80000a26:	00045797          	auipc	a5,0x45
    80000a2a:	5da78793          	addi	a5,a5,1498 # 80046000 <end>
    80000a2e:	04f56363          	bltu	a0,a5,80000a74 <kfree+0x62>
    80000a32:	47c5                	li	a5,17
    80000a34:	07ee                	slli	a5,a5,0x1b
    80000a36:	02f57f63          	bgeu	a0,a5,80000a74 <kfree+0x62>
    panic("kfree");

  //acquire(&ref_lock);
  if(page_ref[COW_INDEX(pa)] > 1) {
    80000a3a:	800007b7          	lui	a5,0x80000
    80000a3e:	97aa                	add	a5,a5,a0
    80000a40:	83b1                	srli	a5,a5,0xc
    80000a42:	00279693          	slli	a3,a5,0x2
    80000a46:	00011717          	auipc	a4,0x11
    80000a4a:	f0a70713          	addi	a4,a4,-246 # 80011950 <page_ref>
    80000a4e:	9736                	add	a4,a4,a3
    80000a50:	4318                	lw	a4,0(a4)
    80000a52:	4685                	li	a3,1
    80000a54:	02e6f863          	bgeu	a3,a4,80000a84 <kfree+0x72>
    page_ref[COW_INDEX(pa)]--;
    80000a58:	078a                	slli	a5,a5,0x2
    80000a5a:	00011697          	auipc	a3,0x11
    80000a5e:	ef668693          	addi	a3,a3,-266 # 80011950 <page_ref>
    80000a62:	97b6                	add	a5,a5,a3
    80000a64:	377d                	addiw	a4,a4,-1
    80000a66:	c398                	sw	a4,0(a5)

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}
    80000a68:	60e2                	ld	ra,24(sp)
    80000a6a:	6442                	ld	s0,16(sp)
    80000a6c:	64a2                	ld	s1,8(sp)
    80000a6e:	6902                	ld	s2,0(sp)
    80000a70:	6105                	addi	sp,sp,32
    80000a72:	8082                	ret
    panic("kfree");
    80000a74:	00007517          	auipc	a0,0x7
    80000a78:	5ec50513          	addi	a0,a0,1516 # 80008060 <digits+0x20>
    80000a7c:	00000097          	auipc	ra,0x0
    80000a80:	ac6080e7          	jalr	-1338(ra) # 80000542 <panic>
  page_ref[COW_INDEX(pa)] = 0;
    80000a84:	078a                	slli	a5,a5,0x2
    80000a86:	00011717          	auipc	a4,0x11
    80000a8a:	eca70713          	addi	a4,a4,-310 # 80011950 <page_ref>
    80000a8e:	97ba                	add	a5,a5,a4
    80000a90:	0007a023          	sw	zero,0(a5) # ffffffff80000000 <end+0xfffffffefffba000>
  memset(pa, 1, PGSIZE);
    80000a94:	6605                	lui	a2,0x1
    80000a96:	4585                	li	a1,1
    80000a98:	00000097          	auipc	ra,0x0
    80000a9c:	372080e7          	jalr	882(ra) # 80000e0a <memset>
  acquire(&kmem.lock);
    80000aa0:	00011917          	auipc	s2,0x11
    80000aa4:	e9090913          	addi	s2,s2,-368 # 80011930 <kmem>
    80000aa8:	854a                	mv	a0,s2
    80000aaa:	00000097          	auipc	ra,0x0
    80000aae:	264080e7          	jalr	612(ra) # 80000d0e <acquire>
  r->next = kmem.freelist;
    80000ab2:	01893783          	ld	a5,24(s2)
    80000ab6:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ab8:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000abc:	854a                	mv	a0,s2
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	304080e7          	jalr	772(ra) # 80000dc2 <release>
    80000ac6:	b74d                	j	80000a68 <kfree+0x56>

0000000080000ac8 <freerange>:
{
    80000ac8:	7179                	addi	sp,sp,-48
    80000aca:	f406                	sd	ra,40(sp)
    80000acc:	f022                	sd	s0,32(sp)
    80000ace:	ec26                	sd	s1,24(sp)
    80000ad0:	e84a                	sd	s2,16(sp)
    80000ad2:	e44e                	sd	s3,8(sp)
    80000ad4:	e052                	sd	s4,0(sp)
    80000ad6:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ad8:	6785                	lui	a5,0x1
    80000ada:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000ade:	94aa                	add	s1,s1,a0
    80000ae0:	757d                	lui	a0,0xfffff
    80000ae2:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae4:	94be                	add	s1,s1,a5
    80000ae6:	0095ee63          	bltu	a1,s1,80000b02 <freerange+0x3a>
    80000aea:	892e                	mv	s2,a1
    kfree(p);
    80000aec:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aee:	6985                	lui	s3,0x1
    kfree(p);
    80000af0:	01448533          	add	a0,s1,s4
    80000af4:	00000097          	auipc	ra,0x0
    80000af8:	f1e080e7          	jalr	-226(ra) # 80000a12 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afc:	94ce                	add	s1,s1,s3
    80000afe:	fe9979e3          	bgeu	s2,s1,80000af0 <freerange+0x28>
}
    80000b02:	70a2                	ld	ra,40(sp)
    80000b04:	7402                	ld	s0,32(sp)
    80000b06:	64e2                	ld	s1,24(sp)
    80000b08:	6942                	ld	s2,16(sp)
    80000b0a:	69a2                	ld	s3,8(sp)
    80000b0c:	6a02                	ld	s4,0(sp)
    80000b0e:	6145                	addi	sp,sp,48
    80000b10:	8082                	ret

0000000080000b12 <kinit>:
{
    80000b12:	1141                	addi	sp,sp,-16
    80000b14:	e406                	sd	ra,8(sp)
    80000b16:	e022                	sd	s0,0(sp)
    80000b18:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b1a:	00007597          	auipc	a1,0x7
    80000b1e:	54e58593          	addi	a1,a1,1358 # 80008068 <digits+0x28>
    80000b22:	00011517          	auipc	a0,0x11
    80000b26:	e0e50513          	addi	a0,a0,-498 # 80011930 <kmem>
    80000b2a:	00000097          	auipc	ra,0x0
    80000b2e:	154080e7          	jalr	340(ra) # 80000c7e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b32:	45c5                	li	a1,17
    80000b34:	05ee                	slli	a1,a1,0x1b
    80000b36:	00045517          	auipc	a0,0x45
    80000b3a:	4ca50513          	addi	a0,a0,1226 # 80046000 <end>
    80000b3e:	00000097          	auipc	ra,0x0
    80000b42:	f8a080e7          	jalr	-118(ra) # 80000ac8 <freerange>
}
    80000b46:	60a2                	ld	ra,8(sp)
    80000b48:	6402                	ld	s0,0(sp)
    80000b4a:	0141                	addi	sp,sp,16
    80000b4c:	8082                	ret

0000000080000b4e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b4e:	1101                	addi	sp,sp,-32
    80000b50:	ec06                	sd	ra,24(sp)
    80000b52:	e822                	sd	s0,16(sp)
    80000b54:	e426                	sd	s1,8(sp)
    80000b56:	1000                	addi	s0,sp,32
   struct run *r;

  acquire(&kmem.lock);
    80000b58:	00011497          	auipc	s1,0x11
    80000b5c:	dd848493          	addi	s1,s1,-552 # 80011930 <kmem>
    80000b60:	8526                	mv	a0,s1
    80000b62:	00000097          	auipc	ra,0x0
    80000b66:	1ac080e7          	jalr	428(ra) # 80000d0e <acquire>
  r = kmem.freelist;
    80000b6a:	6c84                	ld	s1,24(s1)
  if(r)
    80000b6c:	c4a1                	beqz	s1,80000bb4 <kalloc+0x66>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00011517          	auipc	a0,0x11
    80000b74:	dc050513          	addi	a0,a0,-576 # 80011930 <kmem>
    80000b78:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b7a:	00000097          	auipc	ra,0x0
    80000b7e:	248080e7          	jalr	584(ra) # 80000dc2 <release>

  if(r) {
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b82:	6605                	lui	a2,0x1
    80000b84:	4595                	li	a1,5
    80000b86:	8526                	mv	a0,s1
    80000b88:	00000097          	auipc	ra,0x0
    80000b8c:	282080e7          	jalr	642(ra) # 80000e0a <memset>
    page_ref[COW_INDEX(r)] = 1;
    80000b90:	800007b7          	lui	a5,0x80000
    80000b94:	97a6                	add	a5,a5,s1
    80000b96:	83b1                	srli	a5,a5,0xc
    80000b98:	078a                	slli	a5,a5,0x2
    80000b9a:	00011717          	auipc	a4,0x11
    80000b9e:	db670713          	addi	a4,a4,-586 # 80011950 <page_ref>
    80000ba2:	97ba                	add	a5,a5,a4
    80000ba4:	4705                	li	a4,1
    80000ba6:	c398                	sw	a4,0(a5)
  }
  return (void*)r;
}
    80000ba8:	8526                	mv	a0,s1
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret
  release(&kmem.lock);
    80000bb4:	00011517          	auipc	a0,0x11
    80000bb8:	d7c50513          	addi	a0,a0,-644 # 80011930 <kmem>
    80000bbc:	00000097          	auipc	ra,0x0
    80000bc0:	206080e7          	jalr	518(ra) # 80000dc2 <release>
  if(r) {
    80000bc4:	b7d5                	j	80000ba8 <kalloc+0x5a>

0000000080000bc6 <cow_alloc>:
int
cow_alloc(pagetable_t pagetable, uint64 va) {
    80000bc6:	7139                	addi	sp,sp,-64
    80000bc8:	fc06                	sd	ra,56(sp)
    80000bca:	f822                	sd	s0,48(sp)
    80000bcc:	f426                	sd	s1,40(sp)
    80000bce:	f04a                	sd	s2,32(sp)
    80000bd0:	ec4e                	sd	s3,24(sp)
    80000bd2:	e852                	sd	s4,16(sp)
    80000bd4:	e456                	sd	s5,8(sp)
    80000bd6:	0080                	addi	s0,sp,64
  va = PGROUNDDOWN(va);
    80000bd8:	77fd                	lui	a5,0xfffff
    80000bda:	00f5f4b3          	and	s1,a1,a5
  if(va >= MAXVA) return -1;
    80000bde:	57fd                	li	a5,-1
    80000be0:	83e9                	srli	a5,a5,0x1a
    80000be2:	0897e663          	bltu	a5,s1,80000c6e <cow_alloc+0xa8>
    80000be6:	892a                	mv	s2,a0
  pte_t *pte = walk(pagetable, va, 0);
    80000be8:	4601                	li	a2,0
    80000bea:	85a6                	mv	a1,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	506080e7          	jalr	1286(ra) # 800010f2 <walk>
  if(pte == 0) return -1;
    80000bf4:	cd3d                	beqz	a0,80000c72 <cow_alloc+0xac>
  uint64 pa = PTE2PA(*pte);
    80000bf6:	00053a03          	ld	s4,0(a0)
    80000bfa:	00aa5993          	srli	s3,s4,0xa
    80000bfe:	09b2                	slli	s3,s3,0xc
  if(pa == 0) return -1;
    80000c00:	06098b63          	beqz	s3,80000c76 <cow_alloc+0xb0>
  uint64 flags = PTE_FLAGS(*pte);
  if(flags & PTE_COW) {
    80000c04:	100a7793          	andi	a5,s4,256
	if (mappages(pagetable, va, PGSIZE, mem, flags) != 0) {
      kfree((void*)mem);
      return -1;
    }
  }
  return 0;
    80000c08:	4501                	li	a0,0
  if(flags & PTE_COW) {
    80000c0a:	eb91                	bnez	a5,80000c1e <cow_alloc+0x58>
}
    80000c0c:	70e2                	ld	ra,56(sp)
    80000c0e:	7442                	ld	s0,48(sp)
    80000c10:	74a2                	ld	s1,40(sp)
    80000c12:	7902                	ld	s2,32(sp)
    80000c14:	69e2                	ld	s3,24(sp)
    80000c16:	6a42                	ld	s4,16(sp)
    80000c18:	6aa2                	ld	s5,8(sp)
    80000c1a:	6121                	addi	sp,sp,64
    80000c1c:	8082                	ret
    uint64 mem = (uint64)kalloc();
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	f30080e7          	jalr	-208(ra) # 80000b4e <kalloc>
    80000c26:	8aaa                	mv	s5,a0
    if (mem == 0) return -1;
    80000c28:	c929                	beqz	a0,80000c7a <cow_alloc+0xb4>
    memmove((char*)mem, (char*)pa, PGSIZE);
    80000c2a:	6605                	lui	a2,0x1
    80000c2c:	85ce                	mv	a1,s3
    80000c2e:	00000097          	auipc	ra,0x0
    80000c32:	238080e7          	jalr	568(ra) # 80000e66 <memmove>
    uvmunmap(pagetable, va, 1, 1);
    80000c36:	4685                	li	a3,1
    80000c38:	4605                	li	a2,1
    80000c3a:	85a6                	mv	a1,s1
    80000c3c:	854a                	mv	a0,s2
    80000c3e:	00000097          	auipc	ra,0x0
    80000c42:	792080e7          	jalr	1938(ra) # 800013d0 <uvmunmap>
    flags = (flags | PTE_W) & ~PTE_COW;
    80000c46:	2fba7713          	andi	a4,s4,763
	if (mappages(pagetable, va, PGSIZE, mem, flags) != 0) {
    80000c4a:	00476713          	ori	a4,a4,4
    80000c4e:	86d6                	mv	a3,s5
    80000c50:	6605                	lui	a2,0x1
    80000c52:	85a6                	mv	a1,s1
    80000c54:	854a                	mv	a0,s2
    80000c56:	00000097          	auipc	ra,0x0
    80000c5a:	5e2080e7          	jalr	1506(ra) # 80001238 <mappages>
    80000c5e:	d55d                	beqz	a0,80000c0c <cow_alloc+0x46>
      kfree((void*)mem);
    80000c60:	8556                	mv	a0,s5
    80000c62:	00000097          	auipc	ra,0x0
    80000c66:	db0080e7          	jalr	-592(ra) # 80000a12 <kfree>
      return -1;
    80000c6a:	557d                	li	a0,-1
    80000c6c:	b745                	j	80000c0c <cow_alloc+0x46>
  if(va >= MAXVA) return -1;
    80000c6e:	557d                	li	a0,-1
    80000c70:	bf71                	j	80000c0c <cow_alloc+0x46>
  if(pte == 0) return -1;
    80000c72:	557d                	li	a0,-1
    80000c74:	bf61                	j	80000c0c <cow_alloc+0x46>
  if(pa == 0) return -1;
    80000c76:	557d                	li	a0,-1
    80000c78:	bf51                	j	80000c0c <cow_alloc+0x46>
    if (mem == 0) return -1;
    80000c7a:	557d                	li	a0,-1
    80000c7c:	bf41                	j	80000c0c <cow_alloc+0x46>

0000000080000c7e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c7e:	1141                	addi	sp,sp,-16
    80000c80:	e422                	sd	s0,8(sp)
    80000c82:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c84:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c86:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c8a:	00053823          	sd	zero,16(a0)
}
    80000c8e:	6422                	ld	s0,8(sp)
    80000c90:	0141                	addi	sp,sp,16
    80000c92:	8082                	ret

0000000080000c94 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c94:	411c                	lw	a5,0(a0)
    80000c96:	e399                	bnez	a5,80000c9c <holding+0x8>
    80000c98:	4501                	li	a0,0
  return r;
}
    80000c9a:	8082                	ret
{
    80000c9c:	1101                	addi	sp,sp,-32
    80000c9e:	ec06                	sd	ra,24(sp)
    80000ca0:	e822                	sd	s0,16(sp)
    80000ca2:	e426                	sd	s1,8(sp)
    80000ca4:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ca6:	6904                	ld	s1,16(a0)
    80000ca8:	00001097          	auipc	ra,0x1
    80000cac:	e42080e7          	jalr	-446(ra) # 80001aea <mycpu>
    80000cb0:	40a48533          	sub	a0,s1,a0
    80000cb4:	00153513          	seqz	a0,a0
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret

0000000080000cc2 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000cc2:	1101                	addi	sp,sp,-32
    80000cc4:	ec06                	sd	ra,24(sp)
    80000cc6:	e822                	sd	s0,16(sp)
    80000cc8:	e426                	sd	s1,8(sp)
    80000cca:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ccc:	100024f3          	csrr	s1,sstatus
    80000cd0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000cd4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cd6:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000cda:	00001097          	auipc	ra,0x1
    80000cde:	e10080e7          	jalr	-496(ra) # 80001aea <mycpu>
    80000ce2:	5d3c                	lw	a5,120(a0)
    80000ce4:	cf89                	beqz	a5,80000cfe <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ce6:	00001097          	auipc	ra,0x1
    80000cea:	e04080e7          	jalr	-508(ra) # 80001aea <mycpu>
    80000cee:	5d3c                	lw	a5,120(a0)
    80000cf0:	2785                	addiw	a5,a5,1
    80000cf2:	dd3c                	sw	a5,120(a0)
}
    80000cf4:	60e2                	ld	ra,24(sp)
    80000cf6:	6442                	ld	s0,16(sp)
    80000cf8:	64a2                	ld	s1,8(sp)
    80000cfa:	6105                	addi	sp,sp,32
    80000cfc:	8082                	ret
    mycpu()->intena = old;
    80000cfe:	00001097          	auipc	ra,0x1
    80000d02:	dec080e7          	jalr	-532(ra) # 80001aea <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000d06:	8085                	srli	s1,s1,0x1
    80000d08:	8885                	andi	s1,s1,1
    80000d0a:	dd64                	sw	s1,124(a0)
    80000d0c:	bfe9                	j	80000ce6 <push_off+0x24>

0000000080000d0e <acquire>:
{
    80000d0e:	1101                	addi	sp,sp,-32
    80000d10:	ec06                	sd	ra,24(sp)
    80000d12:	e822                	sd	s0,16(sp)
    80000d14:	e426                	sd	s1,8(sp)
    80000d16:	1000                	addi	s0,sp,32
    80000d18:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d1a:	00000097          	auipc	ra,0x0
    80000d1e:	fa8080e7          	jalr	-88(ra) # 80000cc2 <push_off>
  if(holding(lk))
    80000d22:	8526                	mv	a0,s1
    80000d24:	00000097          	auipc	ra,0x0
    80000d28:	f70080e7          	jalr	-144(ra) # 80000c94 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d2c:	4705                	li	a4,1
  if(holding(lk))
    80000d2e:	e115                	bnez	a0,80000d52 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d30:	87ba                	mv	a5,a4
    80000d32:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d36:	2781                	sext.w	a5,a5
    80000d38:	ffe5                	bnez	a5,80000d30 <acquire+0x22>
  __sync_synchronize();
    80000d3a:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d3e:	00001097          	auipc	ra,0x1
    80000d42:	dac080e7          	jalr	-596(ra) # 80001aea <mycpu>
    80000d46:	e888                	sd	a0,16(s1)
}
    80000d48:	60e2                	ld	ra,24(sp)
    80000d4a:	6442                	ld	s0,16(sp)
    80000d4c:	64a2                	ld	s1,8(sp)
    80000d4e:	6105                	addi	sp,sp,32
    80000d50:	8082                	ret
    panic("acquire");
    80000d52:	00007517          	auipc	a0,0x7
    80000d56:	31e50513          	addi	a0,a0,798 # 80008070 <digits+0x30>
    80000d5a:	fffff097          	auipc	ra,0xfffff
    80000d5e:	7e8080e7          	jalr	2024(ra) # 80000542 <panic>

0000000080000d62 <pop_off>:

void
pop_off(void)
{
    80000d62:	1141                	addi	sp,sp,-16
    80000d64:	e406                	sd	ra,8(sp)
    80000d66:	e022                	sd	s0,0(sp)
    80000d68:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d6a:	00001097          	auipc	ra,0x1
    80000d6e:	d80080e7          	jalr	-640(ra) # 80001aea <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d72:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d76:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d78:	e78d                	bnez	a5,80000da2 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d7a:	5d3c                	lw	a5,120(a0)
    80000d7c:	02f05b63          	blez	a5,80000db2 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d80:	37fd                	addiw	a5,a5,-1
    80000d82:	0007871b          	sext.w	a4,a5
    80000d86:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d88:	eb09                	bnez	a4,80000d9a <pop_off+0x38>
    80000d8a:	5d7c                	lw	a5,124(a0)
    80000d8c:	c799                	beqz	a5,80000d9a <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d8e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d92:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d96:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret
    panic("pop_off - interruptible");
    80000da2:	00007517          	auipc	a0,0x7
    80000da6:	2d650513          	addi	a0,a0,726 # 80008078 <digits+0x38>
    80000daa:	fffff097          	auipc	ra,0xfffff
    80000dae:	798080e7          	jalr	1944(ra) # 80000542 <panic>
    panic("pop_off");
    80000db2:	00007517          	auipc	a0,0x7
    80000db6:	2de50513          	addi	a0,a0,734 # 80008090 <digits+0x50>
    80000dba:	fffff097          	auipc	ra,0xfffff
    80000dbe:	788080e7          	jalr	1928(ra) # 80000542 <panic>

0000000080000dc2 <release>:
{
    80000dc2:	1101                	addi	sp,sp,-32
    80000dc4:	ec06                	sd	ra,24(sp)
    80000dc6:	e822                	sd	s0,16(sp)
    80000dc8:	e426                	sd	s1,8(sp)
    80000dca:	1000                	addi	s0,sp,32
    80000dcc:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000dce:	00000097          	auipc	ra,0x0
    80000dd2:	ec6080e7          	jalr	-314(ra) # 80000c94 <holding>
    80000dd6:	c115                	beqz	a0,80000dfa <release+0x38>
  lk->cpu = 0;
    80000dd8:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ddc:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000de0:	0f50000f          	fence	iorw,ow
    80000de4:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000de8:	00000097          	auipc	ra,0x0
    80000dec:	f7a080e7          	jalr	-134(ra) # 80000d62 <pop_off>
}
    80000df0:	60e2                	ld	ra,24(sp)
    80000df2:	6442                	ld	s0,16(sp)
    80000df4:	64a2                	ld	s1,8(sp)
    80000df6:	6105                	addi	sp,sp,32
    80000df8:	8082                	ret
    panic("release");
    80000dfa:	00007517          	auipc	a0,0x7
    80000dfe:	29e50513          	addi	a0,a0,670 # 80008098 <digits+0x58>
    80000e02:	fffff097          	auipc	ra,0xfffff
    80000e06:	740080e7          	jalr	1856(ra) # 80000542 <panic>

0000000080000e0a <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000e0a:	1141                	addi	sp,sp,-16
    80000e0c:	e422                	sd	s0,8(sp)
    80000e0e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e10:	ca19                	beqz	a2,80000e26 <memset+0x1c>
    80000e12:	87aa                	mv	a5,a0
    80000e14:	1602                	slli	a2,a2,0x20
    80000e16:	9201                	srli	a2,a2,0x20
    80000e18:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000e1c:	00b78023          	sb	a1,0(a5) # fffffffffffff000 <end+0xffffffff7ffb9000>
  for(i = 0; i < n; i++){
    80000e20:	0785                	addi	a5,a5,1
    80000e22:	fee79de3          	bne	a5,a4,80000e1c <memset+0x12>
  }
  return dst;
}
    80000e26:	6422                	ld	s0,8(sp)
    80000e28:	0141                	addi	sp,sp,16
    80000e2a:	8082                	ret

0000000080000e2c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e2c:	1141                	addi	sp,sp,-16
    80000e2e:	e422                	sd	s0,8(sp)
    80000e30:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e32:	ca05                	beqz	a2,80000e62 <memcmp+0x36>
    80000e34:	fff6069b          	addiw	a3,a2,-1
    80000e38:	1682                	slli	a3,a3,0x20
    80000e3a:	9281                	srli	a3,a3,0x20
    80000e3c:	0685                	addi	a3,a3,1
    80000e3e:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000e40:	00054783          	lbu	a5,0(a0)
    80000e44:	0005c703          	lbu	a4,0(a1)
    80000e48:	00e79863          	bne	a5,a4,80000e58 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000e4c:	0505                	addi	a0,a0,1
    80000e4e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e50:	fed518e3          	bne	a0,a3,80000e40 <memcmp+0x14>
  }

  return 0;
    80000e54:	4501                	li	a0,0
    80000e56:	a019                	j	80000e5c <memcmp+0x30>
      return *s1 - *s2;
    80000e58:	40e7853b          	subw	a0,a5,a4
}
    80000e5c:	6422                	ld	s0,8(sp)
    80000e5e:	0141                	addi	sp,sp,16
    80000e60:	8082                	ret
  return 0;
    80000e62:	4501                	li	a0,0
    80000e64:	bfe5                	j	80000e5c <memcmp+0x30>

0000000080000e66 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e66:	1141                	addi	sp,sp,-16
    80000e68:	e422                	sd	s0,8(sp)
    80000e6a:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e6c:	02a5e563          	bltu	a1,a0,80000e96 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e70:	fff6069b          	addiw	a3,a2,-1
    80000e74:	ce11                	beqz	a2,80000e90 <memmove+0x2a>
    80000e76:	1682                	slli	a3,a3,0x20
    80000e78:	9281                	srli	a3,a3,0x20
    80000e7a:	0685                	addi	a3,a3,1
    80000e7c:	96ae                	add	a3,a3,a1
    80000e7e:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000e80:	0585                	addi	a1,a1,1
    80000e82:	0785                	addi	a5,a5,1
    80000e84:	fff5c703          	lbu	a4,-1(a1)
    80000e88:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000e8c:	fed59ae3          	bne	a1,a3,80000e80 <memmove+0x1a>

  return dst;
}
    80000e90:	6422                	ld	s0,8(sp)
    80000e92:	0141                	addi	sp,sp,16
    80000e94:	8082                	ret
  if(s < d && s + n > d){
    80000e96:	02061713          	slli	a4,a2,0x20
    80000e9a:	9301                	srli	a4,a4,0x20
    80000e9c:	00e587b3          	add	a5,a1,a4
    80000ea0:	fcf578e3          	bgeu	a0,a5,80000e70 <memmove+0xa>
    d += n;
    80000ea4:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000ea6:	fff6069b          	addiw	a3,a2,-1
    80000eaa:	d27d                	beqz	a2,80000e90 <memmove+0x2a>
    80000eac:	02069613          	slli	a2,a3,0x20
    80000eb0:	9201                	srli	a2,a2,0x20
    80000eb2:	fff64613          	not	a2,a2
    80000eb6:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000eb8:	17fd                	addi	a5,a5,-1
    80000eba:	177d                	addi	a4,a4,-1
    80000ebc:	0007c683          	lbu	a3,0(a5)
    80000ec0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000ec4:	fef61ae3          	bne	a2,a5,80000eb8 <memmove+0x52>
    80000ec8:	b7e1                	j	80000e90 <memmove+0x2a>

0000000080000eca <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000eca:	1141                	addi	sp,sp,-16
    80000ecc:	e406                	sd	ra,8(sp)
    80000ece:	e022                	sd	s0,0(sp)
    80000ed0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	f94080e7          	jalr	-108(ra) # 80000e66 <memmove>
}
    80000eda:	60a2                	ld	ra,8(sp)
    80000edc:	6402                	ld	s0,0(sp)
    80000ede:	0141                	addi	sp,sp,16
    80000ee0:	8082                	ret

0000000080000ee2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000ee2:	1141                	addi	sp,sp,-16
    80000ee4:	e422                	sd	s0,8(sp)
    80000ee6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ee8:	ce11                	beqz	a2,80000f04 <strncmp+0x22>
    80000eea:	00054783          	lbu	a5,0(a0)
    80000eee:	cf89                	beqz	a5,80000f08 <strncmp+0x26>
    80000ef0:	0005c703          	lbu	a4,0(a1)
    80000ef4:	00f71a63          	bne	a4,a5,80000f08 <strncmp+0x26>
    n--, p++, q++;
    80000ef8:	367d                	addiw	a2,a2,-1
    80000efa:	0505                	addi	a0,a0,1
    80000efc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000efe:	f675                	bnez	a2,80000eea <strncmp+0x8>
  if(n == 0)
    return 0;
    80000f00:	4501                	li	a0,0
    80000f02:	a809                	j	80000f14 <strncmp+0x32>
    80000f04:	4501                	li	a0,0
    80000f06:	a039                	j	80000f14 <strncmp+0x32>
  if(n == 0)
    80000f08:	ca09                	beqz	a2,80000f1a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000f0a:	00054503          	lbu	a0,0(a0)
    80000f0e:	0005c783          	lbu	a5,0(a1)
    80000f12:	9d1d                	subw	a0,a0,a5
}
    80000f14:	6422                	ld	s0,8(sp)
    80000f16:	0141                	addi	sp,sp,16
    80000f18:	8082                	ret
    return 0;
    80000f1a:	4501                	li	a0,0
    80000f1c:	bfe5                	j	80000f14 <strncmp+0x32>

0000000080000f1e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000f1e:	1141                	addi	sp,sp,-16
    80000f20:	e422                	sd	s0,8(sp)
    80000f22:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f24:	872a                	mv	a4,a0
    80000f26:	8832                	mv	a6,a2
    80000f28:	367d                	addiw	a2,a2,-1
    80000f2a:	01005963          	blez	a6,80000f3c <strncpy+0x1e>
    80000f2e:	0705                	addi	a4,a4,1
    80000f30:	0005c783          	lbu	a5,0(a1)
    80000f34:	fef70fa3          	sb	a5,-1(a4)
    80000f38:	0585                	addi	a1,a1,1
    80000f3a:	f7f5                	bnez	a5,80000f26 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000f3c:	86ba                	mv	a3,a4
    80000f3e:	00c05c63          	blez	a2,80000f56 <strncpy+0x38>
    *s++ = 0;
    80000f42:	0685                	addi	a3,a3,1
    80000f44:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000f48:	fff6c793          	not	a5,a3
    80000f4c:	9fb9                	addw	a5,a5,a4
    80000f4e:	010787bb          	addw	a5,a5,a6
    80000f52:	fef048e3          	bgtz	a5,80000f42 <strncpy+0x24>
  return os;
}
    80000f56:	6422                	ld	s0,8(sp)
    80000f58:	0141                	addi	sp,sp,16
    80000f5a:	8082                	ret

0000000080000f5c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f5c:	1141                	addi	sp,sp,-16
    80000f5e:	e422                	sd	s0,8(sp)
    80000f60:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f62:	02c05363          	blez	a2,80000f88 <safestrcpy+0x2c>
    80000f66:	fff6069b          	addiw	a3,a2,-1
    80000f6a:	1682                	slli	a3,a3,0x20
    80000f6c:	9281                	srli	a3,a3,0x20
    80000f6e:	96ae                	add	a3,a3,a1
    80000f70:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f72:	00d58963          	beq	a1,a3,80000f84 <safestrcpy+0x28>
    80000f76:	0585                	addi	a1,a1,1
    80000f78:	0785                	addi	a5,a5,1
    80000f7a:	fff5c703          	lbu	a4,-1(a1)
    80000f7e:	fee78fa3          	sb	a4,-1(a5)
    80000f82:	fb65                	bnez	a4,80000f72 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f84:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f88:	6422                	ld	s0,8(sp)
    80000f8a:	0141                	addi	sp,sp,16
    80000f8c:	8082                	ret

0000000080000f8e <strlen>:

int
strlen(const char *s)
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f94:	00054783          	lbu	a5,0(a0)
    80000f98:	cf91                	beqz	a5,80000fb4 <strlen+0x26>
    80000f9a:	0505                	addi	a0,a0,1
    80000f9c:	87aa                	mv	a5,a0
    80000f9e:	4685                	li	a3,1
    80000fa0:	9e89                	subw	a3,a3,a0
    80000fa2:	00f6853b          	addw	a0,a3,a5
    80000fa6:	0785                	addi	a5,a5,1
    80000fa8:	fff7c703          	lbu	a4,-1(a5)
    80000fac:	fb7d                	bnez	a4,80000fa2 <strlen+0x14>
    ;
  return n;
}
    80000fae:	6422                	ld	s0,8(sp)
    80000fb0:	0141                	addi	sp,sp,16
    80000fb2:	8082                	ret
  for(n = 0; s[n]; n++)
    80000fb4:	4501                	li	a0,0
    80000fb6:	bfe5                	j	80000fae <strlen+0x20>

0000000080000fb8 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000fb8:	1141                	addi	sp,sp,-16
    80000fba:	e406                	sd	ra,8(sp)
    80000fbc:	e022                	sd	s0,0(sp)
    80000fbe:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000fc0:	00001097          	auipc	ra,0x1
    80000fc4:	b1a080e7          	jalr	-1254(ra) # 80001ada <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000fc8:	00008717          	auipc	a4,0x8
    80000fcc:	04470713          	addi	a4,a4,68 # 8000900c <started>
  if(cpuid() == 0){
    80000fd0:	c139                	beqz	a0,80001016 <main+0x5e>
    while(started == 0)
    80000fd2:	431c                	lw	a5,0(a4)
    80000fd4:	2781                	sext.w	a5,a5
    80000fd6:	dff5                	beqz	a5,80000fd2 <main+0x1a>
      ;
    __sync_synchronize();
    80000fd8:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000fdc:	00001097          	auipc	ra,0x1
    80000fe0:	afe080e7          	jalr	-1282(ra) # 80001ada <cpuid>
    80000fe4:	85aa                	mv	a1,a0
    80000fe6:	00007517          	auipc	a0,0x7
    80000fea:	0d250513          	addi	a0,a0,210 # 800080b8 <digits+0x78>
    80000fee:	fffff097          	auipc	ra,0xfffff
    80000ff2:	59e080e7          	jalr	1438(ra) # 8000058c <printf>
    kvminithart();    // turn on paging
    80000ff6:	00000097          	auipc	ra,0x0
    80000ffa:	0d8080e7          	jalr	216(ra) # 800010ce <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ffe:	00001097          	auipc	ra,0x1
    80001002:	762080e7          	jalr	1890(ra) # 80002760 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001006:	00005097          	auipc	ra,0x5
    8000100a:	d1a080e7          	jalr	-742(ra) # 80005d20 <plicinithart>
  }

  scheduler();        
    8000100e:	00001097          	auipc	ra,0x1
    80001012:	02c080e7          	jalr	44(ra) # 8000203a <scheduler>
    consoleinit();
    80001016:	fffff097          	auipc	ra,0xfffff
    8000101a:	43e080e7          	jalr	1086(ra) # 80000454 <consoleinit>
    printfinit();
    8000101e:	fffff097          	auipc	ra,0xfffff
    80001022:	74e080e7          	jalr	1870(ra) # 8000076c <printfinit>
    printf("\n");
    80001026:	00007517          	auipc	a0,0x7
    8000102a:	0a250513          	addi	a0,a0,162 # 800080c8 <digits+0x88>
    8000102e:	fffff097          	auipc	ra,0xfffff
    80001032:	55e080e7          	jalr	1374(ra) # 8000058c <printf>
    printf("xv6 kernel is booting\n");
    80001036:	00007517          	auipc	a0,0x7
    8000103a:	06a50513          	addi	a0,a0,106 # 800080a0 <digits+0x60>
    8000103e:	fffff097          	auipc	ra,0xfffff
    80001042:	54e080e7          	jalr	1358(ra) # 8000058c <printf>
    printf("\n");
    80001046:	00007517          	auipc	a0,0x7
    8000104a:	08250513          	addi	a0,a0,130 # 800080c8 <digits+0x88>
    8000104e:	fffff097          	auipc	ra,0xfffff
    80001052:	53e080e7          	jalr	1342(ra) # 8000058c <printf>
    kinit();         // physical page allocator
    80001056:	00000097          	auipc	ra,0x0
    8000105a:	abc080e7          	jalr	-1348(ra) # 80000b12 <kinit>
    kvminit();       // create kernel page table
    8000105e:	00000097          	auipc	ra,0x0
    80001062:	2a0080e7          	jalr	672(ra) # 800012fe <kvminit>
    kvminithart();   // turn on paging
    80001066:	00000097          	auipc	ra,0x0
    8000106a:	068080e7          	jalr	104(ra) # 800010ce <kvminithart>
    procinit();      // process table
    8000106e:	00001097          	auipc	ra,0x1
    80001072:	99c080e7          	jalr	-1636(ra) # 80001a0a <procinit>
    trapinit();      // trap vectors
    80001076:	00001097          	auipc	ra,0x1
    8000107a:	6c2080e7          	jalr	1730(ra) # 80002738 <trapinit>
    trapinithart();  // install kernel trap vector
    8000107e:	00001097          	auipc	ra,0x1
    80001082:	6e2080e7          	jalr	1762(ra) # 80002760 <trapinithart>
    plicinit();      // set up interrupt controller
    80001086:	00005097          	auipc	ra,0x5
    8000108a:	c84080e7          	jalr	-892(ra) # 80005d0a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000108e:	00005097          	auipc	ra,0x5
    80001092:	c92080e7          	jalr	-878(ra) # 80005d20 <plicinithart>
    binit();         // buffer cache
    80001096:	00002097          	auipc	ra,0x2
    8000109a:	e36080e7          	jalr	-458(ra) # 80002ecc <binit>
    iinit();         // inode cache
    8000109e:	00002097          	auipc	ra,0x2
    800010a2:	4c6080e7          	jalr	1222(ra) # 80003564 <iinit>
    fileinit();      // file table
    800010a6:	00003097          	auipc	ra,0x3
    800010aa:	464080e7          	jalr	1124(ra) # 8000450a <fileinit>
    virtio_disk_init(); // emulated hard disk
    800010ae:	00005097          	auipc	ra,0x5
    800010b2:	d7a080e7          	jalr	-646(ra) # 80005e28 <virtio_disk_init>
    userinit();      // first user process
    800010b6:	00001097          	auipc	ra,0x1
    800010ba:	d1a080e7          	jalr	-742(ra) # 80001dd0 <userinit>
    __sync_synchronize();
    800010be:	0ff0000f          	fence
    started = 1;
    800010c2:	4785                	li	a5,1
    800010c4:	00008717          	auipc	a4,0x8
    800010c8:	f4f72423          	sw	a5,-184(a4) # 8000900c <started>
    800010cc:	b789                	j	8000100e <main+0x56>

00000000800010ce <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800010ce:	1141                	addi	sp,sp,-16
    800010d0:	e422                	sd	s0,8(sp)
    800010d2:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    800010d4:	00008797          	auipc	a5,0x8
    800010d8:	f3c7b783          	ld	a5,-196(a5) # 80009010 <kernel_pagetable>
    800010dc:	83b1                	srli	a5,a5,0xc
    800010de:	577d                	li	a4,-1
    800010e0:	177e                	slli	a4,a4,0x3f
    800010e2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800010e4:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800010e8:	12000073          	sfence.vma
  sfence_vma();
}
    800010ec:	6422                	ld	s0,8(sp)
    800010ee:	0141                	addi	sp,sp,16
    800010f0:	8082                	ret

00000000800010f2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010f2:	7139                	addi	sp,sp,-64
    800010f4:	fc06                	sd	ra,56(sp)
    800010f6:	f822                	sd	s0,48(sp)
    800010f8:	f426                	sd	s1,40(sp)
    800010fa:	f04a                	sd	s2,32(sp)
    800010fc:	ec4e                	sd	s3,24(sp)
    800010fe:	e852                	sd	s4,16(sp)
    80001100:	e456                	sd	s5,8(sp)
    80001102:	e05a                	sd	s6,0(sp)
    80001104:	0080                	addi	s0,sp,64
    80001106:	84aa                	mv	s1,a0
    80001108:	89ae                	mv	s3,a1
    8000110a:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000110c:	57fd                	li	a5,-1
    8000110e:	83e9                	srli	a5,a5,0x1a
    80001110:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001112:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001114:	04b7f263          	bgeu	a5,a1,80001158 <walk+0x66>
    panic("walk");
    80001118:	00007517          	auipc	a0,0x7
    8000111c:	fb850513          	addi	a0,a0,-72 # 800080d0 <digits+0x90>
    80001120:	fffff097          	auipc	ra,0xfffff
    80001124:	422080e7          	jalr	1058(ra) # 80000542 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001128:	060a8663          	beqz	s5,80001194 <walk+0xa2>
    8000112c:	00000097          	auipc	ra,0x0
    80001130:	a22080e7          	jalr	-1502(ra) # 80000b4e <kalloc>
    80001134:	84aa                	mv	s1,a0
    80001136:	c529                	beqz	a0,80001180 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001138:	6605                	lui	a2,0x1
    8000113a:	4581                	li	a1,0
    8000113c:	00000097          	auipc	ra,0x0
    80001140:	cce080e7          	jalr	-818(ra) # 80000e0a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001144:	00c4d793          	srli	a5,s1,0xc
    80001148:	07aa                	slli	a5,a5,0xa
    8000114a:	0017e793          	ori	a5,a5,1
    8000114e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001152:	3a5d                	addiw	s4,s4,-9
    80001154:	036a0063          	beq	s4,s6,80001174 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001158:	0149d933          	srl	s2,s3,s4
    8000115c:	1ff97913          	andi	s2,s2,511
    80001160:	090e                	slli	s2,s2,0x3
    80001162:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001164:	00093483          	ld	s1,0(s2)
    80001168:	0014f793          	andi	a5,s1,1
    8000116c:	dfd5                	beqz	a5,80001128 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000116e:	80a9                	srli	s1,s1,0xa
    80001170:	04b2                	slli	s1,s1,0xc
    80001172:	b7c5                	j	80001152 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001174:	00c9d513          	srli	a0,s3,0xc
    80001178:	1ff57513          	andi	a0,a0,511
    8000117c:	050e                	slli	a0,a0,0x3
    8000117e:	9526                	add	a0,a0,s1
}
    80001180:	70e2                	ld	ra,56(sp)
    80001182:	7442                	ld	s0,48(sp)
    80001184:	74a2                	ld	s1,40(sp)
    80001186:	7902                	ld	s2,32(sp)
    80001188:	69e2                	ld	s3,24(sp)
    8000118a:	6a42                	ld	s4,16(sp)
    8000118c:	6aa2                	ld	s5,8(sp)
    8000118e:	6b02                	ld	s6,0(sp)
    80001190:	6121                	addi	sp,sp,64
    80001192:	8082                	ret
        return 0;
    80001194:	4501                	li	a0,0
    80001196:	b7ed                	j	80001180 <walk+0x8e>

0000000080001198 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001198:	57fd                	li	a5,-1
    8000119a:	83e9                	srli	a5,a5,0x1a
    8000119c:	00b7f463          	bgeu	a5,a1,800011a4 <walkaddr+0xc>
    return 0;
    800011a0:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800011a2:	8082                	ret
{
    800011a4:	1141                	addi	sp,sp,-16
    800011a6:	e406                	sd	ra,8(sp)
    800011a8:	e022                	sd	s0,0(sp)
    800011aa:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800011ac:	4601                	li	a2,0
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f44080e7          	jalr	-188(ra) # 800010f2 <walk>
  if(pte == 0)
    800011b6:	c105                	beqz	a0,800011d6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800011b8:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800011ba:	0117f693          	andi	a3,a5,17
    800011be:	4745                	li	a4,17
    return 0;
    800011c0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011c2:	00e68663          	beq	a3,a4,800011ce <walkaddr+0x36>
}
    800011c6:	60a2                	ld	ra,8(sp)
    800011c8:	6402                	ld	s0,0(sp)
    800011ca:	0141                	addi	sp,sp,16
    800011cc:	8082                	ret
  pa = PTE2PA(*pte);
    800011ce:	00a7d513          	srli	a0,a5,0xa
    800011d2:	0532                	slli	a0,a0,0xc
  return pa;
    800011d4:	bfcd                	j	800011c6 <walkaddr+0x2e>
    return 0;
    800011d6:	4501                	li	a0,0
    800011d8:	b7fd                	j	800011c6 <walkaddr+0x2e>

00000000800011da <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    800011da:	1101                	addi	sp,sp,-32
    800011dc:	ec06                	sd	ra,24(sp)
    800011de:	e822                	sd	s0,16(sp)
    800011e0:	e426                	sd	s1,8(sp)
    800011e2:	1000                	addi	s0,sp,32
    800011e4:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800011e6:	1552                	slli	a0,a0,0x34
    800011e8:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    800011ec:	4601                	li	a2,0
    800011ee:	00008517          	auipc	a0,0x8
    800011f2:	e2253503          	ld	a0,-478(a0) # 80009010 <kernel_pagetable>
    800011f6:	00000097          	auipc	ra,0x0
    800011fa:	efc080e7          	jalr	-260(ra) # 800010f2 <walk>
  if(pte == 0)
    800011fe:	cd09                	beqz	a0,80001218 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    80001200:	6108                	ld	a0,0(a0)
    80001202:	00157793          	andi	a5,a0,1
    80001206:	c38d                	beqz	a5,80001228 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001208:	8129                	srli	a0,a0,0xa
    8000120a:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    8000120c:	9526                	add	a0,a0,s1
    8000120e:	60e2                	ld	ra,24(sp)
    80001210:	6442                	ld	s0,16(sp)
    80001212:	64a2                	ld	s1,8(sp)
    80001214:	6105                	addi	sp,sp,32
    80001216:	8082                	ret
    panic("kvmpa");
    80001218:	00007517          	auipc	a0,0x7
    8000121c:	ec050513          	addi	a0,a0,-320 # 800080d8 <digits+0x98>
    80001220:	fffff097          	auipc	ra,0xfffff
    80001224:	322080e7          	jalr	802(ra) # 80000542 <panic>
    panic("kvmpa");
    80001228:	00007517          	auipc	a0,0x7
    8000122c:	eb050513          	addi	a0,a0,-336 # 800080d8 <digits+0x98>
    80001230:	fffff097          	auipc	ra,0xfffff
    80001234:	312080e7          	jalr	786(ra) # 80000542 <panic>

0000000080001238 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001238:	715d                	addi	sp,sp,-80
    8000123a:	e486                	sd	ra,72(sp)
    8000123c:	e0a2                	sd	s0,64(sp)
    8000123e:	fc26                	sd	s1,56(sp)
    80001240:	f84a                	sd	s2,48(sp)
    80001242:	f44e                	sd	s3,40(sp)
    80001244:	f052                	sd	s4,32(sp)
    80001246:	ec56                	sd	s5,24(sp)
    80001248:	e85a                	sd	s6,16(sp)
    8000124a:	e45e                	sd	s7,8(sp)
    8000124c:	0880                	addi	s0,sp,80
    8000124e:	8aaa                	mv	s5,a0
    80001250:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001252:	777d                	lui	a4,0xfffff
    80001254:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001258:	167d                	addi	a2,a2,-1
    8000125a:	00b609b3          	add	s3,a2,a1
    8000125e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001262:	893e                	mv	s2,a5
    80001264:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001268:	6b85                	lui	s7,0x1
    8000126a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000126e:	4605                	li	a2,1
    80001270:	85ca                	mv	a1,s2
    80001272:	8556                	mv	a0,s5
    80001274:	00000097          	auipc	ra,0x0
    80001278:	e7e080e7          	jalr	-386(ra) # 800010f2 <walk>
    8000127c:	c51d                	beqz	a0,800012aa <mappages+0x72>
    if(*pte & PTE_V)
    8000127e:	611c                	ld	a5,0(a0)
    80001280:	8b85                	andi	a5,a5,1
    80001282:	ef81                	bnez	a5,8000129a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001284:	80b1                	srli	s1,s1,0xc
    80001286:	04aa                	slli	s1,s1,0xa
    80001288:	0164e4b3          	or	s1,s1,s6
    8000128c:	0014e493          	ori	s1,s1,1
    80001290:	e104                	sd	s1,0(a0)
    if(a == last)
    80001292:	03390863          	beq	s2,s3,800012c2 <mappages+0x8a>
    a += PGSIZE;
    80001296:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001298:	bfc9                	j	8000126a <mappages+0x32>
      panic("remap");
    8000129a:	00007517          	auipc	a0,0x7
    8000129e:	e4650513          	addi	a0,a0,-442 # 800080e0 <digits+0xa0>
    800012a2:	fffff097          	auipc	ra,0xfffff
    800012a6:	2a0080e7          	jalr	672(ra) # 80000542 <panic>
      return -1;
    800012aa:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800012ac:	60a6                	ld	ra,72(sp)
    800012ae:	6406                	ld	s0,64(sp)
    800012b0:	74e2                	ld	s1,56(sp)
    800012b2:	7942                	ld	s2,48(sp)
    800012b4:	79a2                	ld	s3,40(sp)
    800012b6:	7a02                	ld	s4,32(sp)
    800012b8:	6ae2                	ld	s5,24(sp)
    800012ba:	6b42                	ld	s6,16(sp)
    800012bc:	6ba2                	ld	s7,8(sp)
    800012be:	6161                	addi	sp,sp,80
    800012c0:	8082                	ret
  return 0;
    800012c2:	4501                	li	a0,0
    800012c4:	b7e5                	j	800012ac <mappages+0x74>

00000000800012c6 <kvmmap>:
{
    800012c6:	1141                	addi	sp,sp,-16
    800012c8:	e406                	sd	ra,8(sp)
    800012ca:	e022                	sd	s0,0(sp)
    800012cc:	0800                	addi	s0,sp,16
    800012ce:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800012d0:	86ae                	mv	a3,a1
    800012d2:	85aa                	mv	a1,a0
    800012d4:	00008517          	auipc	a0,0x8
    800012d8:	d3c53503          	ld	a0,-708(a0) # 80009010 <kernel_pagetable>
    800012dc:	00000097          	auipc	ra,0x0
    800012e0:	f5c080e7          	jalr	-164(ra) # 80001238 <mappages>
    800012e4:	e509                	bnez	a0,800012ee <kvmmap+0x28>
}
    800012e6:	60a2                	ld	ra,8(sp)
    800012e8:	6402                	ld	s0,0(sp)
    800012ea:	0141                	addi	sp,sp,16
    800012ec:	8082                	ret
    panic("kvmmap");
    800012ee:	00007517          	auipc	a0,0x7
    800012f2:	dfa50513          	addi	a0,a0,-518 # 800080e8 <digits+0xa8>
    800012f6:	fffff097          	auipc	ra,0xfffff
    800012fa:	24c080e7          	jalr	588(ra) # 80000542 <panic>

00000000800012fe <kvminit>:
{
    800012fe:	1101                	addi	sp,sp,-32
    80001300:	ec06                	sd	ra,24(sp)
    80001302:	e822                	sd	s0,16(sp)
    80001304:	e426                	sd	s1,8(sp)
    80001306:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001308:	00000097          	auipc	ra,0x0
    8000130c:	846080e7          	jalr	-1978(ra) # 80000b4e <kalloc>
    80001310:	00008797          	auipc	a5,0x8
    80001314:	d0a7b023          	sd	a0,-768(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001318:	6605                	lui	a2,0x1
    8000131a:	4581                	li	a1,0
    8000131c:	00000097          	auipc	ra,0x0
    80001320:	aee080e7          	jalr	-1298(ra) # 80000e0a <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001324:	4699                	li	a3,6
    80001326:	6605                	lui	a2,0x1
    80001328:	100005b7          	lui	a1,0x10000
    8000132c:	10000537          	lui	a0,0x10000
    80001330:	00000097          	auipc	ra,0x0
    80001334:	f96080e7          	jalr	-106(ra) # 800012c6 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001338:	4699                	li	a3,6
    8000133a:	6605                	lui	a2,0x1
    8000133c:	100015b7          	lui	a1,0x10001
    80001340:	10001537          	lui	a0,0x10001
    80001344:	00000097          	auipc	ra,0x0
    80001348:	f82080e7          	jalr	-126(ra) # 800012c6 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000134c:	4699                	li	a3,6
    8000134e:	6641                	lui	a2,0x10
    80001350:	020005b7          	lui	a1,0x2000
    80001354:	02000537          	lui	a0,0x2000
    80001358:	00000097          	auipc	ra,0x0
    8000135c:	f6e080e7          	jalr	-146(ra) # 800012c6 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001360:	4699                	li	a3,6
    80001362:	00400637          	lui	a2,0x400
    80001366:	0c0005b7          	lui	a1,0xc000
    8000136a:	0c000537          	lui	a0,0xc000
    8000136e:	00000097          	auipc	ra,0x0
    80001372:	f58080e7          	jalr	-168(ra) # 800012c6 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001376:	00007497          	auipc	s1,0x7
    8000137a:	c8a48493          	addi	s1,s1,-886 # 80008000 <etext>
    8000137e:	46a9                	li	a3,10
    80001380:	80007617          	auipc	a2,0x80007
    80001384:	c8060613          	addi	a2,a2,-896 # 8000 <_entry-0x7fff8000>
    80001388:	4585                	li	a1,1
    8000138a:	05fe                	slli	a1,a1,0x1f
    8000138c:	852e                	mv	a0,a1
    8000138e:	00000097          	auipc	ra,0x0
    80001392:	f38080e7          	jalr	-200(ra) # 800012c6 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001396:	4699                	li	a3,6
    80001398:	4645                	li	a2,17
    8000139a:	066e                	slli	a2,a2,0x1b
    8000139c:	8e05                	sub	a2,a2,s1
    8000139e:	85a6                	mv	a1,s1
    800013a0:	8526                	mv	a0,s1
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	f24080e7          	jalr	-220(ra) # 800012c6 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800013aa:	46a9                	li	a3,10
    800013ac:	6605                	lui	a2,0x1
    800013ae:	00006597          	auipc	a1,0x6
    800013b2:	c5258593          	addi	a1,a1,-942 # 80007000 <_trampoline>
    800013b6:	04000537          	lui	a0,0x4000
    800013ba:	157d                	addi	a0,a0,-1
    800013bc:	0532                	slli	a0,a0,0xc
    800013be:	00000097          	auipc	ra,0x0
    800013c2:	f08080e7          	jalr	-248(ra) # 800012c6 <kvmmap>
}
    800013c6:	60e2                	ld	ra,24(sp)
    800013c8:	6442                	ld	s0,16(sp)
    800013ca:	64a2                	ld	s1,8(sp)
    800013cc:	6105                	addi	sp,sp,32
    800013ce:	8082                	ret

00000000800013d0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800013d0:	715d                	addi	sp,sp,-80
    800013d2:	e486                	sd	ra,72(sp)
    800013d4:	e0a2                	sd	s0,64(sp)
    800013d6:	fc26                	sd	s1,56(sp)
    800013d8:	f84a                	sd	s2,48(sp)
    800013da:	f44e                	sd	s3,40(sp)
    800013dc:	f052                	sd	s4,32(sp)
    800013de:	ec56                	sd	s5,24(sp)
    800013e0:	e85a                	sd	s6,16(sp)
    800013e2:	e45e                	sd	s7,8(sp)
    800013e4:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800013e6:	03459793          	slli	a5,a1,0x34
    800013ea:	e795                	bnez	a5,80001416 <uvmunmap+0x46>
    800013ec:	8a2a                	mv	s4,a0
    800013ee:	892e                	mv	s2,a1
    800013f0:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013f2:	0632                	slli	a2,a2,0xc
    800013f4:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800013f8:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013fa:	6b05                	lui	s6,0x1
    800013fc:	0735e263          	bltu	a1,s3,80001460 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001400:	60a6                	ld	ra,72(sp)
    80001402:	6406                	ld	s0,64(sp)
    80001404:	74e2                	ld	s1,56(sp)
    80001406:	7942                	ld	s2,48(sp)
    80001408:	79a2                	ld	s3,40(sp)
    8000140a:	7a02                	ld	s4,32(sp)
    8000140c:	6ae2                	ld	s5,24(sp)
    8000140e:	6b42                	ld	s6,16(sp)
    80001410:	6ba2                	ld	s7,8(sp)
    80001412:	6161                	addi	sp,sp,80
    80001414:	8082                	ret
    panic("uvmunmap: not aligned");
    80001416:	00007517          	auipc	a0,0x7
    8000141a:	cda50513          	addi	a0,a0,-806 # 800080f0 <digits+0xb0>
    8000141e:	fffff097          	auipc	ra,0xfffff
    80001422:	124080e7          	jalr	292(ra) # 80000542 <panic>
      panic("uvmunmap: walk");
    80001426:	00007517          	auipc	a0,0x7
    8000142a:	ce250513          	addi	a0,a0,-798 # 80008108 <digits+0xc8>
    8000142e:	fffff097          	auipc	ra,0xfffff
    80001432:	114080e7          	jalr	276(ra) # 80000542 <panic>
      panic("uvmunmap: not mapped");
    80001436:	00007517          	auipc	a0,0x7
    8000143a:	ce250513          	addi	a0,a0,-798 # 80008118 <digits+0xd8>
    8000143e:	fffff097          	auipc	ra,0xfffff
    80001442:	104080e7          	jalr	260(ra) # 80000542 <panic>
      panic("uvmunmap: not a leaf");
    80001446:	00007517          	auipc	a0,0x7
    8000144a:	cea50513          	addi	a0,a0,-790 # 80008130 <digits+0xf0>
    8000144e:	fffff097          	auipc	ra,0xfffff
    80001452:	0f4080e7          	jalr	244(ra) # 80000542 <panic>
    *pte = 0;
    80001456:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000145a:	995a                	add	s2,s2,s6
    8000145c:	fb3972e3          	bgeu	s2,s3,80001400 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001460:	4601                	li	a2,0
    80001462:	85ca                	mv	a1,s2
    80001464:	8552                	mv	a0,s4
    80001466:	00000097          	auipc	ra,0x0
    8000146a:	c8c080e7          	jalr	-884(ra) # 800010f2 <walk>
    8000146e:	84aa                	mv	s1,a0
    80001470:	d95d                	beqz	a0,80001426 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001472:	6108                	ld	a0,0(a0)
    80001474:	00157793          	andi	a5,a0,1
    80001478:	dfdd                	beqz	a5,80001436 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000147a:	3ff57793          	andi	a5,a0,1023
    8000147e:	fd7784e3          	beq	a5,s7,80001446 <uvmunmap+0x76>
    if(do_free){
    80001482:	fc0a8ae3          	beqz	s5,80001456 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001486:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001488:	0532                	slli	a0,a0,0xc
    8000148a:	fffff097          	auipc	ra,0xfffff
    8000148e:	588080e7          	jalr	1416(ra) # 80000a12 <kfree>
    80001492:	b7d1                	j	80001456 <uvmunmap+0x86>

0000000080001494 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001494:	1101                	addi	sp,sp,-32
    80001496:	ec06                	sd	ra,24(sp)
    80001498:	e822                	sd	s0,16(sp)
    8000149a:	e426                	sd	s1,8(sp)
    8000149c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000149e:	fffff097          	auipc	ra,0xfffff
    800014a2:	6b0080e7          	jalr	1712(ra) # 80000b4e <kalloc>
    800014a6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800014a8:	c519                	beqz	a0,800014b6 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800014aa:	6605                	lui	a2,0x1
    800014ac:	4581                	li	a1,0
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	95c080e7          	jalr	-1700(ra) # 80000e0a <memset>
  return pagetable;
}
    800014b6:	8526                	mv	a0,s1
    800014b8:	60e2                	ld	ra,24(sp)
    800014ba:	6442                	ld	s0,16(sp)
    800014bc:	64a2                	ld	s1,8(sp)
    800014be:	6105                	addi	sp,sp,32
    800014c0:	8082                	ret

00000000800014c2 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800014d2:	6785                	lui	a5,0x1
    800014d4:	04f67863          	bgeu	a2,a5,80001524 <uvminit+0x62>
    800014d8:	8a2a                	mv	s4,a0
    800014da:	89ae                	mv	s3,a1
    800014dc:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800014de:	fffff097          	auipc	ra,0xfffff
    800014e2:	670080e7          	jalr	1648(ra) # 80000b4e <kalloc>
    800014e6:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014e8:	6605                	lui	a2,0x1
    800014ea:	4581                	li	a1,0
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	91e080e7          	jalr	-1762(ra) # 80000e0a <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014f4:	4779                	li	a4,30
    800014f6:	86ca                	mv	a3,s2
    800014f8:	6605                	lui	a2,0x1
    800014fa:	4581                	li	a1,0
    800014fc:	8552                	mv	a0,s4
    800014fe:	00000097          	auipc	ra,0x0
    80001502:	d3a080e7          	jalr	-710(ra) # 80001238 <mappages>
  memmove(mem, src, sz);
    80001506:	8626                	mv	a2,s1
    80001508:	85ce                	mv	a1,s3
    8000150a:	854a                	mv	a0,s2
    8000150c:	00000097          	auipc	ra,0x0
    80001510:	95a080e7          	jalr	-1702(ra) # 80000e66 <memmove>
}
    80001514:	70a2                	ld	ra,40(sp)
    80001516:	7402                	ld	s0,32(sp)
    80001518:	64e2                	ld	s1,24(sp)
    8000151a:	6942                	ld	s2,16(sp)
    8000151c:	69a2                	ld	s3,8(sp)
    8000151e:	6a02                	ld	s4,0(sp)
    80001520:	6145                	addi	sp,sp,48
    80001522:	8082                	ret
    panic("inituvm: more than a page");
    80001524:	00007517          	auipc	a0,0x7
    80001528:	c2450513          	addi	a0,a0,-988 # 80008148 <digits+0x108>
    8000152c:	fffff097          	auipc	ra,0xfffff
    80001530:	016080e7          	jalr	22(ra) # 80000542 <panic>

0000000080001534 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001534:	1101                	addi	sp,sp,-32
    80001536:	ec06                	sd	ra,24(sp)
    80001538:	e822                	sd	s0,16(sp)
    8000153a:	e426                	sd	s1,8(sp)
    8000153c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000153e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001540:	00b67d63          	bgeu	a2,a1,8000155a <uvmdealloc+0x26>
    80001544:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001546:	6785                	lui	a5,0x1
    80001548:	17fd                	addi	a5,a5,-1
    8000154a:	00f60733          	add	a4,a2,a5
    8000154e:	767d                	lui	a2,0xfffff
    80001550:	8f71                	and	a4,a4,a2
    80001552:	97ae                	add	a5,a5,a1
    80001554:	8ff1                	and	a5,a5,a2
    80001556:	00f76863          	bltu	a4,a5,80001566 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000155a:	8526                	mv	a0,s1
    8000155c:	60e2                	ld	ra,24(sp)
    8000155e:	6442                	ld	s0,16(sp)
    80001560:	64a2                	ld	s1,8(sp)
    80001562:	6105                	addi	sp,sp,32
    80001564:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001566:	8f99                	sub	a5,a5,a4
    80001568:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000156a:	4685                	li	a3,1
    8000156c:	0007861b          	sext.w	a2,a5
    80001570:	85ba                	mv	a1,a4
    80001572:	00000097          	auipc	ra,0x0
    80001576:	e5e080e7          	jalr	-418(ra) # 800013d0 <uvmunmap>
    8000157a:	b7c5                	j	8000155a <uvmdealloc+0x26>

000000008000157c <uvmalloc>:
  if(newsz < oldsz)
    8000157c:	0ab66163          	bltu	a2,a1,8000161e <uvmalloc+0xa2>
{
    80001580:	7139                	addi	sp,sp,-64
    80001582:	fc06                	sd	ra,56(sp)
    80001584:	f822                	sd	s0,48(sp)
    80001586:	f426                	sd	s1,40(sp)
    80001588:	f04a                	sd	s2,32(sp)
    8000158a:	ec4e                	sd	s3,24(sp)
    8000158c:	e852                	sd	s4,16(sp)
    8000158e:	e456                	sd	s5,8(sp)
    80001590:	0080                	addi	s0,sp,64
    80001592:	8aaa                	mv	s5,a0
    80001594:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001596:	6985                	lui	s3,0x1
    80001598:	19fd                	addi	s3,s3,-1
    8000159a:	95ce                	add	a1,a1,s3
    8000159c:	79fd                	lui	s3,0xfffff
    8000159e:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015a2:	08c9f063          	bgeu	s3,a2,80001622 <uvmalloc+0xa6>
    800015a6:	894e                	mv	s2,s3
    mem = kalloc();
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	5a6080e7          	jalr	1446(ra) # 80000b4e <kalloc>
    800015b0:	84aa                	mv	s1,a0
    if(mem == 0){
    800015b2:	c51d                	beqz	a0,800015e0 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	4581                	li	a1,0
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	852080e7          	jalr	-1966(ra) # 80000e0a <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800015c0:	4779                	li	a4,30
    800015c2:	86a6                	mv	a3,s1
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ca                	mv	a1,s2
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	c6e080e7          	jalr	-914(ra) # 80001238 <mappages>
    800015d2:	e905                	bnez	a0,80001602 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015d4:	6785                	lui	a5,0x1
    800015d6:	993e                	add	s2,s2,a5
    800015d8:	fd4968e3          	bltu	s2,s4,800015a8 <uvmalloc+0x2c>
  return newsz;
    800015dc:	8552                	mv	a0,s4
    800015de:	a809                	j	800015f0 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800015e0:	864e                	mv	a2,s3
    800015e2:	85ca                	mv	a1,s2
    800015e4:	8556                	mv	a0,s5
    800015e6:	00000097          	auipc	ra,0x0
    800015ea:	f4e080e7          	jalr	-178(ra) # 80001534 <uvmdealloc>
      return 0;
    800015ee:	4501                	li	a0,0
}
    800015f0:	70e2                	ld	ra,56(sp)
    800015f2:	7442                	ld	s0,48(sp)
    800015f4:	74a2                	ld	s1,40(sp)
    800015f6:	7902                	ld	s2,32(sp)
    800015f8:	69e2                	ld	s3,24(sp)
    800015fa:	6a42                	ld	s4,16(sp)
    800015fc:	6aa2                	ld	s5,8(sp)
    800015fe:	6121                	addi	sp,sp,64
    80001600:	8082                	ret
      kfree(mem);
    80001602:	8526                	mv	a0,s1
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	40e080e7          	jalr	1038(ra) # 80000a12 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000160c:	864e                	mv	a2,s3
    8000160e:	85ca                	mv	a1,s2
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	f22080e7          	jalr	-222(ra) # 80001534 <uvmdealloc>
      return 0;
    8000161a:	4501                	li	a0,0
    8000161c:	bfd1                	j	800015f0 <uvmalloc+0x74>
    return oldsz;
    8000161e:	852e                	mv	a0,a1
}
    80001620:	8082                	ret
  return newsz;
    80001622:	8532                	mv	a0,a2
    80001624:	b7f1                	j	800015f0 <uvmalloc+0x74>

0000000080001626 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001626:	7179                	addi	sp,sp,-48
    80001628:	f406                	sd	ra,40(sp)
    8000162a:	f022                	sd	s0,32(sp)
    8000162c:	ec26                	sd	s1,24(sp)
    8000162e:	e84a                	sd	s2,16(sp)
    80001630:	e44e                	sd	s3,8(sp)
    80001632:	e052                	sd	s4,0(sp)
    80001634:	1800                	addi	s0,sp,48
    80001636:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001638:	84aa                	mv	s1,a0
    8000163a:	6905                	lui	s2,0x1
    8000163c:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000163e:	4985                	li	s3,1
    80001640:	a821                	j	80001658 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001642:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001644:	0532                	slli	a0,a0,0xc
    80001646:	00000097          	auipc	ra,0x0
    8000164a:	fe0080e7          	jalr	-32(ra) # 80001626 <freewalk>
      pagetable[i] = 0;
    8000164e:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001652:	04a1                	addi	s1,s1,8
    80001654:	03248163          	beq	s1,s2,80001676 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001658:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000165a:	00f57793          	andi	a5,a0,15
    8000165e:	ff3782e3          	beq	a5,s3,80001642 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001662:	8905                	andi	a0,a0,1
    80001664:	d57d                	beqz	a0,80001652 <freewalk+0x2c>
      panic("freewalk: leaf");
    80001666:	00007517          	auipc	a0,0x7
    8000166a:	b0250513          	addi	a0,a0,-1278 # 80008168 <digits+0x128>
    8000166e:	fffff097          	auipc	ra,0xfffff
    80001672:	ed4080e7          	jalr	-300(ra) # 80000542 <panic>
    }
  }
  kfree((void*)pagetable);
    80001676:	8552                	mv	a0,s4
    80001678:	fffff097          	auipc	ra,0xfffff
    8000167c:	39a080e7          	jalr	922(ra) # 80000a12 <kfree>
}
    80001680:	70a2                	ld	ra,40(sp)
    80001682:	7402                	ld	s0,32(sp)
    80001684:	64e2                	ld	s1,24(sp)
    80001686:	6942                	ld	s2,16(sp)
    80001688:	69a2                	ld	s3,8(sp)
    8000168a:	6a02                	ld	s4,0(sp)
    8000168c:	6145                	addi	sp,sp,48
    8000168e:	8082                	ret

0000000080001690 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001690:	1101                	addi	sp,sp,-32
    80001692:	ec06                	sd	ra,24(sp)
    80001694:	e822                	sd	s0,16(sp)
    80001696:	e426                	sd	s1,8(sp)
    80001698:	1000                	addi	s0,sp,32
    8000169a:	84aa                	mv	s1,a0
  if(sz > 0)
    8000169c:	e999                	bnez	a1,800016b2 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000169e:	8526                	mv	a0,s1
    800016a0:	00000097          	auipc	ra,0x0
    800016a4:	f86080e7          	jalr	-122(ra) # 80001626 <freewalk>
}
    800016a8:	60e2                	ld	ra,24(sp)
    800016aa:	6442                	ld	s0,16(sp)
    800016ac:	64a2                	ld	s1,8(sp)
    800016ae:	6105                	addi	sp,sp,32
    800016b0:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800016b2:	6605                	lui	a2,0x1
    800016b4:	167d                	addi	a2,a2,-1
    800016b6:	962e                	add	a2,a2,a1
    800016b8:	4685                	li	a3,1
    800016ba:	8231                	srli	a2,a2,0xc
    800016bc:	4581                	li	a1,0
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	d12080e7          	jalr	-750(ra) # 800013d0 <uvmunmap>
    800016c6:	bfe1                	j	8000169e <uvmfree+0xe>

00000000800016c8 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  //char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800016c8:	c669                	beqz	a2,80001792 <uvmcopy+0xca>
{
    800016ca:	715d                	addi	sp,sp,-80
    800016cc:	e486                	sd	ra,72(sp)
    800016ce:	e0a2                	sd	s0,64(sp)
    800016d0:	fc26                	sd	s1,56(sp)
    800016d2:	f84a                	sd	s2,48(sp)
    800016d4:	f44e                	sd	s3,40(sp)
    800016d6:	f052                	sd	s4,32(sp)
    800016d8:	ec56                	sd	s5,24(sp)
    800016da:	e85a                	sd	s6,16(sp)
    800016dc:	e45e                	sd	s7,8(sp)
    800016de:	0880                	addi	s0,sp,80
    800016e0:	8aaa                	mv	s5,a0
    800016e2:	8a2e                	mv	s4,a1
    800016e4:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    800016e6:	4901                	li	s2,0
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
      //kfree(mem);
      goto err;
    }
    //acquire(&ref_lock);
    page_ref[COW_INDEX(pa)]++;
    800016e8:	80000bb7          	lui	s7,0x80000
    800016ec:	00010b17          	auipc	s6,0x10
    800016f0:	264b0b13          	addi	s6,s6,612 # 80011950 <page_ref>
    if((pte = walk(old, i, 0)) == 0)
    800016f4:	4601                	li	a2,0
    800016f6:	85ca                	mv	a1,s2
    800016f8:	8556                	mv	a0,s5
    800016fa:	00000097          	auipc	ra,0x0
    800016fe:	9f8080e7          	jalr	-1544(ra) # 800010f2 <walk>
    80001702:	c139                	beqz	a0,80001748 <uvmcopy+0x80>
    if((*pte & PTE_V) == 0)
    80001704:	6118                	ld	a4,0(a0)
    80001706:	00177793          	andi	a5,a4,1
    8000170a:	c7b9                	beqz	a5,80001758 <uvmcopy+0x90>
    pa = PTE2PA(*pte);
    8000170c:	00a75493          	srli	s1,a4,0xa
    80001710:	04b2                	slli	s1,s1,0xc
    *pte = (*pte & ~PTE_W) | PTE_COW;
    80001712:	efb77713          	andi	a4,a4,-261
    80001716:	10076713          	ori	a4,a4,256
    8000171a:	e118                	sd	a4,0(a0)
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    8000171c:	3fb77713          	andi	a4,a4,1019
    80001720:	86a6                	mv	a3,s1
    80001722:	6605                	lui	a2,0x1
    80001724:	85ca                	mv	a1,s2
    80001726:	8552                	mv	a0,s4
    80001728:	00000097          	auipc	ra,0x0
    8000172c:	b10080e7          	jalr	-1264(ra) # 80001238 <mappages>
    80001730:	ed05                	bnez	a0,80001768 <uvmcopy+0xa0>
    page_ref[COW_INDEX(pa)]++;
    80001732:	94de                	add	s1,s1,s7
    80001734:	80a9                	srli	s1,s1,0xa
    80001736:	94da                	add	s1,s1,s6
    80001738:	409c                	lw	a5,0(s1)
    8000173a:	2785                	addiw	a5,a5,1
    8000173c:	c09c                	sw	a5,0(s1)
  for(i = 0; i < sz; i += PGSIZE){
    8000173e:	6785                	lui	a5,0x1
    80001740:	993e                	add	s2,s2,a5
    80001742:	fb3969e3          	bltu	s2,s3,800016f4 <uvmcopy+0x2c>
    80001746:	a81d                	j	8000177c <uvmcopy+0xb4>
      panic("uvmcopy: pte should exist");
    80001748:	00007517          	auipc	a0,0x7
    8000174c:	a3050513          	addi	a0,a0,-1488 # 80008178 <digits+0x138>
    80001750:	fffff097          	auipc	ra,0xfffff
    80001754:	df2080e7          	jalr	-526(ra) # 80000542 <panic>
      panic("uvmcopy: page not present");
    80001758:	00007517          	auipc	a0,0x7
    8000175c:	a4050513          	addi	a0,a0,-1472 # 80008198 <digits+0x158>
    80001760:	fffff097          	auipc	ra,0xfffff
    80001764:	de2080e7          	jalr	-542(ra) # 80000542 <panic>
    //release(&ref_lock);
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001768:	4685                	li	a3,1
    8000176a:	00c95613          	srli	a2,s2,0xc
    8000176e:	4581                	li	a1,0
    80001770:	8552                	mv	a0,s4
    80001772:	00000097          	auipc	ra,0x0
    80001776:	c5e080e7          	jalr	-930(ra) # 800013d0 <uvmunmap>
  return -1;
    8000177a:	557d                	li	a0,-1
}
    8000177c:	60a6                	ld	ra,72(sp)
    8000177e:	6406                	ld	s0,64(sp)
    80001780:	74e2                	ld	s1,56(sp)
    80001782:	7942                	ld	s2,48(sp)
    80001784:	79a2                	ld	s3,40(sp)
    80001786:	7a02                	ld	s4,32(sp)
    80001788:	6ae2                	ld	s5,24(sp)
    8000178a:	6b42                	ld	s6,16(sp)
    8000178c:	6ba2                	ld	s7,8(sp)
    8000178e:	6161                	addi	sp,sp,80
    80001790:	8082                	ret
  return 0;
    80001792:	4501                	li	a0,0
}
    80001794:	8082                	ret

0000000080001796 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001796:	1141                	addi	sp,sp,-16
    80001798:	e406                	sd	ra,8(sp)
    8000179a:	e022                	sd	s0,0(sp)
    8000179c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000179e:	4601                	li	a2,0
    800017a0:	00000097          	auipc	ra,0x0
    800017a4:	952080e7          	jalr	-1710(ra) # 800010f2 <walk>
  if(pte == 0)
    800017a8:	c901                	beqz	a0,800017b8 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800017aa:	611c                	ld	a5,0(a0)
    800017ac:	9bbd                	andi	a5,a5,-17
    800017ae:	e11c                	sd	a5,0(a0)
}
    800017b0:	60a2                	ld	ra,8(sp)
    800017b2:	6402                	ld	s0,0(sp)
    800017b4:	0141                	addi	sp,sp,16
    800017b6:	8082                	ret
    panic("uvmclear");
    800017b8:	00007517          	auipc	a0,0x7
    800017bc:	a0050513          	addi	a0,a0,-1536 # 800081b8 <digits+0x178>
    800017c0:	fffff097          	auipc	ra,0xfffff
    800017c4:	d82080e7          	jalr	-638(ra) # 80000542 <panic>

00000000800017c8 <copyout>:
// Copy from kernel to user.
// Copy len bytes from src to virtual address dstva in a given page table.
// Return 0 on success, -1 on error.
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
    800017c8:	711d                	addi	sp,sp,-96
    800017ca:	ec86                	sd	ra,88(sp)
    800017cc:	e8a2                	sd	s0,80(sp)
    800017ce:	e4a6                	sd	s1,72(sp)
    800017d0:	e0ca                	sd	s2,64(sp)
    800017d2:	fc4e                	sd	s3,56(sp)
    800017d4:	f852                	sd	s4,48(sp)
    800017d6:	f456                	sd	s5,40(sp)
    800017d8:	f05a                	sd	s6,32(sp)
    800017da:	ec5e                	sd	s7,24(sp)
    800017dc:	e862                	sd	s8,16(sp)
    800017de:	e466                	sd	s9,8(sp)
    800017e0:	e06a                	sd	s10,0(sp)
    800017e2:	1080                	addi	s0,sp,96
   uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    800017e4:	cab5                	beqz	a3,80001858 <copyout+0x90>
    800017e6:	8b2a                	mv	s6,a0
    800017e8:	89ae                	mv	s3,a1
    800017ea:	8bb2                	mv	s7,a2
    800017ec:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    800017ee:	7cfd                	lui	s9,0xfffff
    if (cow_alloc(pagetable, va0) != 0)
      return -1;
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800017f0:	6c05                	lui	s8,0x1
    800017f2:	a815                	j	80001826 <copyout+0x5e>
    if(n > len)
      n = len;
    pte = walk(pagetable, va0, 0);
    800017f4:	4601                	li	a2,0
    800017f6:	85ca                	mv	a1,s2
    800017f8:	855a                	mv	a0,s6
    800017fa:	00000097          	auipc	ra,0x0
    800017fe:	8f8080e7          	jalr	-1800(ra) # 800010f2 <walk>
    if(pte == 0)
    80001802:	cd3d                	beqz	a0,80001880 <copyout+0xb8>
      return -1;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001804:	41298533          	sub	a0,s3,s2
    80001808:	0004861b          	sext.w	a2,s1
    8000180c:	85de                	mv	a1,s7
    8000180e:	9552                	add	a0,a0,s4
    80001810:	fffff097          	auipc	ra,0xfffff
    80001814:	656080e7          	jalr	1622(ra) # 80000e66 <memmove>

    len -= n;
    80001818:	409a8ab3          	sub	s5,s5,s1
    src += n;
    8000181c:	9ba6                	add	s7,s7,s1
    dstva = va0 + PGSIZE;
    8000181e:	018909b3          	add	s3,s2,s8
  while(len > 0){
    80001822:	020a8e63          	beqz	s5,8000185e <copyout+0x96>
    va0 = PGROUNDDOWN(dstva);
    80001826:	0199f933          	and	s2,s3,s9
    if (cow_alloc(pagetable, va0) != 0)
    8000182a:	85ca                	mv	a1,s2
    8000182c:	855a                	mv	a0,s6
    8000182e:	fffff097          	auipc	ra,0xfffff
    80001832:	398080e7          	jalr	920(ra) # 80000bc6 <cow_alloc>
    80001836:	8d2a                	mv	s10,a0
    80001838:	e115                	bnez	a0,8000185c <copyout+0x94>
    pa0 = walkaddr(pagetable, va0);
    8000183a:	85ca                	mv	a1,s2
    8000183c:	855a                	mv	a0,s6
    8000183e:	00000097          	auipc	ra,0x0
    80001842:	95a080e7          	jalr	-1702(ra) # 80001198 <walkaddr>
    80001846:	8a2a                	mv	s4,a0
    if(pa0 == 0)
    80001848:	c915                	beqz	a0,8000187c <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    8000184a:	413904b3          	sub	s1,s2,s3
    8000184e:	94e2                	add	s1,s1,s8
    if(n > len)
    80001850:	fa9af2e3          	bgeu	s5,s1,800017f4 <copyout+0x2c>
    80001854:	84d6                	mv	s1,s5
    80001856:	bf79                	j	800017f4 <copyout+0x2c>
  }
  return 0;
    80001858:	4d01                	li	s10,0
    8000185a:	a011                	j	8000185e <copyout+0x96>
      return -1;
    8000185c:	5d7d                	li	s10,-1
}
    8000185e:	856a                	mv	a0,s10
    80001860:	60e6                	ld	ra,88(sp)
    80001862:	6446                	ld	s0,80(sp)
    80001864:	64a6                	ld	s1,72(sp)
    80001866:	6906                	ld	s2,64(sp)
    80001868:	79e2                	ld	s3,56(sp)
    8000186a:	7a42                	ld	s4,48(sp)
    8000186c:	7aa2                	ld	s5,40(sp)
    8000186e:	7b02                	ld	s6,32(sp)
    80001870:	6be2                	ld	s7,24(sp)
    80001872:	6c42                	ld	s8,16(sp)
    80001874:	6ca2                	ld	s9,8(sp)
    80001876:	6d02                	ld	s10,0(sp)
    80001878:	6125                	addi	sp,sp,96
    8000187a:	8082                	ret
      return -1;
    8000187c:	5d7d                	li	s10,-1
    8000187e:	b7c5                	j	8000185e <copyout+0x96>
      return -1;
    80001880:	5d7d                	li	s10,-1
    80001882:	bff1                	j	8000185e <copyout+0x96>

0000000080001884 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001884:	caa5                	beqz	a3,800018f4 <copyin+0x70>
{
    80001886:	715d                	addi	sp,sp,-80
    80001888:	e486                	sd	ra,72(sp)
    8000188a:	e0a2                	sd	s0,64(sp)
    8000188c:	fc26                	sd	s1,56(sp)
    8000188e:	f84a                	sd	s2,48(sp)
    80001890:	f44e                	sd	s3,40(sp)
    80001892:	f052                	sd	s4,32(sp)
    80001894:	ec56                	sd	s5,24(sp)
    80001896:	e85a                	sd	s6,16(sp)
    80001898:	e45e                	sd	s7,8(sp)
    8000189a:	e062                	sd	s8,0(sp)
    8000189c:	0880                	addi	s0,sp,80
    8000189e:	8b2a                	mv	s6,a0
    800018a0:	8a2e                	mv	s4,a1
    800018a2:	8c32                	mv	s8,a2
    800018a4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800018a6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018a8:	6a85                	lui	s5,0x1
    800018aa:	a01d                	j	800018d0 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018ac:	018505b3          	add	a1,a0,s8
    800018b0:	0004861b          	sext.w	a2,s1
    800018b4:	412585b3          	sub	a1,a1,s2
    800018b8:	8552                	mv	a0,s4
    800018ba:	fffff097          	auipc	ra,0xfffff
    800018be:	5ac080e7          	jalr	1452(ra) # 80000e66 <memmove>

    len -= n;
    800018c2:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018c6:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018c8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018cc:	02098263          	beqz	s3,800018f0 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800018d0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018d4:	85ca                	mv	a1,s2
    800018d6:	855a                	mv	a0,s6
    800018d8:	00000097          	auipc	ra,0x0
    800018dc:	8c0080e7          	jalr	-1856(ra) # 80001198 <walkaddr>
    if(pa0 == 0)
    800018e0:	cd01                	beqz	a0,800018f8 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800018e2:	418904b3          	sub	s1,s2,s8
    800018e6:	94d6                	add	s1,s1,s5
    if(n > len)
    800018e8:	fc99f2e3          	bgeu	s3,s1,800018ac <copyin+0x28>
    800018ec:	84ce                	mv	s1,s3
    800018ee:	bf7d                	j	800018ac <copyin+0x28>
  }
  return 0;
    800018f0:	4501                	li	a0,0
    800018f2:	a021                	j	800018fa <copyin+0x76>
    800018f4:	4501                	li	a0,0
}
    800018f6:	8082                	ret
      return -1;
    800018f8:	557d                	li	a0,-1
}
    800018fa:	60a6                	ld	ra,72(sp)
    800018fc:	6406                	ld	s0,64(sp)
    800018fe:	74e2                	ld	s1,56(sp)
    80001900:	7942                	ld	s2,48(sp)
    80001902:	79a2                	ld	s3,40(sp)
    80001904:	7a02                	ld	s4,32(sp)
    80001906:	6ae2                	ld	s5,24(sp)
    80001908:	6b42                	ld	s6,16(sp)
    8000190a:	6ba2                	ld	s7,8(sp)
    8000190c:	6c02                	ld	s8,0(sp)
    8000190e:	6161                	addi	sp,sp,80
    80001910:	8082                	ret

0000000080001912 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001912:	c6c5                	beqz	a3,800019ba <copyinstr+0xa8>
{
    80001914:	715d                	addi	sp,sp,-80
    80001916:	e486                	sd	ra,72(sp)
    80001918:	e0a2                	sd	s0,64(sp)
    8000191a:	fc26                	sd	s1,56(sp)
    8000191c:	f84a                	sd	s2,48(sp)
    8000191e:	f44e                	sd	s3,40(sp)
    80001920:	f052                	sd	s4,32(sp)
    80001922:	ec56                	sd	s5,24(sp)
    80001924:	e85a                	sd	s6,16(sp)
    80001926:	e45e                	sd	s7,8(sp)
    80001928:	0880                	addi	s0,sp,80
    8000192a:	8a2a                	mv	s4,a0
    8000192c:	8b2e                	mv	s6,a1
    8000192e:	8bb2                	mv	s7,a2
    80001930:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001932:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001934:	6985                	lui	s3,0x1
    80001936:	a035                	j	80001962 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001938:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000193c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000193e:	0017b793          	seqz	a5,a5
    80001942:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001946:	60a6                	ld	ra,72(sp)
    80001948:	6406                	ld	s0,64(sp)
    8000194a:	74e2                	ld	s1,56(sp)
    8000194c:	7942                	ld	s2,48(sp)
    8000194e:	79a2                	ld	s3,40(sp)
    80001950:	7a02                	ld	s4,32(sp)
    80001952:	6ae2                	ld	s5,24(sp)
    80001954:	6b42                	ld	s6,16(sp)
    80001956:	6ba2                	ld	s7,8(sp)
    80001958:	6161                	addi	sp,sp,80
    8000195a:	8082                	ret
    srcva = va0 + PGSIZE;
    8000195c:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001960:	c8a9                	beqz	s1,800019b2 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001962:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001966:	85ca                	mv	a1,s2
    80001968:	8552                	mv	a0,s4
    8000196a:	00000097          	auipc	ra,0x0
    8000196e:	82e080e7          	jalr	-2002(ra) # 80001198 <walkaddr>
    if(pa0 == 0)
    80001972:	c131                	beqz	a0,800019b6 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001974:	41790833          	sub	a6,s2,s7
    80001978:	984e                	add	a6,a6,s3
    if(n > max)
    8000197a:	0104f363          	bgeu	s1,a6,80001980 <copyinstr+0x6e>
    8000197e:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001980:	955e                	add	a0,a0,s7
    80001982:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001986:	fc080be3          	beqz	a6,8000195c <copyinstr+0x4a>
    8000198a:	985a                	add	a6,a6,s6
    8000198c:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000198e:	41650633          	sub	a2,a0,s6
    80001992:	14fd                	addi	s1,s1,-1
    80001994:	9b26                	add	s6,s6,s1
    80001996:	00f60733          	add	a4,a2,a5
    8000199a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffb9000>
    8000199e:	df49                	beqz	a4,80001938 <copyinstr+0x26>
        *dst = *p;
    800019a0:	00e78023          	sb	a4,0(a5)
      --max;
    800019a4:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800019a8:	0785                	addi	a5,a5,1
    while(n > 0){
    800019aa:	ff0796e3          	bne	a5,a6,80001996 <copyinstr+0x84>
      dst++;
    800019ae:	8b42                	mv	s6,a6
    800019b0:	b775                	j	8000195c <copyinstr+0x4a>
    800019b2:	4781                	li	a5,0
    800019b4:	b769                	j	8000193e <copyinstr+0x2c>
      return -1;
    800019b6:	557d                	li	a0,-1
    800019b8:	b779                	j	80001946 <copyinstr+0x34>
  int got_null = 0;
    800019ba:	4781                	li	a5,0
  if(got_null){
    800019bc:	0017b793          	seqz	a5,a5
    800019c0:	40f00533          	neg	a0,a5
}
    800019c4:	8082                	ret

00000000800019c6 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800019c6:	1101                	addi	sp,sp,-32
    800019c8:	ec06                	sd	ra,24(sp)
    800019ca:	e822                	sd	s0,16(sp)
    800019cc:	e426                	sd	s1,8(sp)
    800019ce:	1000                	addi	s0,sp,32
    800019d0:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800019d2:	fffff097          	auipc	ra,0xfffff
    800019d6:	2c2080e7          	jalr	706(ra) # 80000c94 <holding>
    800019da:	c909                	beqz	a0,800019ec <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800019dc:	749c                	ld	a5,40(s1)
    800019de:	00978f63          	beq	a5,s1,800019fc <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800019e2:	60e2                	ld	ra,24(sp)
    800019e4:	6442                	ld	s0,16(sp)
    800019e6:	64a2                	ld	s1,8(sp)
    800019e8:	6105                	addi	sp,sp,32
    800019ea:	8082                	ret
    panic("wakeup1");
    800019ec:	00006517          	auipc	a0,0x6
    800019f0:	7dc50513          	addi	a0,a0,2012 # 800081c8 <digits+0x188>
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	b4e080e7          	jalr	-1202(ra) # 80000542 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    800019fc:	4c98                	lw	a4,24(s1)
    800019fe:	4785                	li	a5,1
    80001a00:	fef711e3          	bne	a4,a5,800019e2 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001a04:	4789                	li	a5,2
    80001a06:	cc9c                	sw	a5,24(s1)
}
    80001a08:	bfe9                	j	800019e2 <wakeup1+0x1c>

0000000080001a0a <procinit>:
{
    80001a0a:	715d                	addi	sp,sp,-80
    80001a0c:	e486                	sd	ra,72(sp)
    80001a0e:	e0a2                	sd	s0,64(sp)
    80001a10:	fc26                	sd	s1,56(sp)
    80001a12:	f84a                	sd	s2,48(sp)
    80001a14:	f44e                	sd	s3,40(sp)
    80001a16:	f052                	sd	s4,32(sp)
    80001a18:	ec56                	sd	s5,24(sp)
    80001a1a:	e85a                	sd	s6,16(sp)
    80001a1c:	e45e                	sd	s7,8(sp)
    80001a1e:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001a20:	00006597          	auipc	a1,0x6
    80001a24:	7b058593          	addi	a1,a1,1968 # 800081d0 <digits+0x190>
    80001a28:	00030517          	auipc	a0,0x30
    80001a2c:	f2850513          	addi	a0,a0,-216 # 80031950 <pid_lock>
    80001a30:	fffff097          	auipc	ra,0xfffff
    80001a34:	24e080e7          	jalr	590(ra) # 80000c7e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a38:	00030917          	auipc	s2,0x30
    80001a3c:	33090913          	addi	s2,s2,816 # 80031d68 <proc>
      initlock(&p->lock, "proc");
    80001a40:	00006b97          	auipc	s7,0x6
    80001a44:	798b8b93          	addi	s7,s7,1944 # 800081d8 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    80001a48:	8b4a                	mv	s6,s2
    80001a4a:	00006a97          	auipc	s5,0x6
    80001a4e:	5b6a8a93          	addi	s5,s5,1462 # 80008000 <etext>
    80001a52:	040009b7          	lui	s3,0x4000
    80001a56:	19fd                	addi	s3,s3,-1
    80001a58:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a5a:	00036a17          	auipc	s4,0x36
    80001a5e:	d0ea0a13          	addi	s4,s4,-754 # 80037768 <tickslock>
      initlock(&p->lock, "proc");
    80001a62:	85de                	mv	a1,s7
    80001a64:	854a                	mv	a0,s2
    80001a66:	fffff097          	auipc	ra,0xfffff
    80001a6a:	218080e7          	jalr	536(ra) # 80000c7e <initlock>
      char *pa = kalloc();
    80001a6e:	fffff097          	auipc	ra,0xfffff
    80001a72:	0e0080e7          	jalr	224(ra) # 80000b4e <kalloc>
    80001a76:	85aa                	mv	a1,a0
      if(pa == 0)
    80001a78:	c929                	beqz	a0,80001aca <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001a7a:	416904b3          	sub	s1,s2,s6
    80001a7e:	848d                	srai	s1,s1,0x3
    80001a80:	000ab783          	ld	a5,0(s5)
    80001a84:	02f484b3          	mul	s1,s1,a5
    80001a88:	2485                	addiw	s1,s1,1
    80001a8a:	00d4949b          	slliw	s1,s1,0xd
    80001a8e:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a92:	4699                	li	a3,6
    80001a94:	6605                	lui	a2,0x1
    80001a96:	8526                	mv	a0,s1
    80001a98:	00000097          	auipc	ra,0x0
    80001a9c:	82e080e7          	jalr	-2002(ra) # 800012c6 <kvmmap>
      p->kstack = va;
    80001aa0:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aa4:	16890913          	addi	s2,s2,360
    80001aa8:	fb491de3          	bne	s2,s4,80001a62 <procinit+0x58>
  kvminithart();
    80001aac:	fffff097          	auipc	ra,0xfffff
    80001ab0:	622080e7          	jalr	1570(ra) # 800010ce <kvminithart>
}
    80001ab4:	60a6                	ld	ra,72(sp)
    80001ab6:	6406                	ld	s0,64(sp)
    80001ab8:	74e2                	ld	s1,56(sp)
    80001aba:	7942                	ld	s2,48(sp)
    80001abc:	79a2                	ld	s3,40(sp)
    80001abe:	7a02                	ld	s4,32(sp)
    80001ac0:	6ae2                	ld	s5,24(sp)
    80001ac2:	6b42                	ld	s6,16(sp)
    80001ac4:	6ba2                	ld	s7,8(sp)
    80001ac6:	6161                	addi	sp,sp,80
    80001ac8:	8082                	ret
        panic("kalloc");
    80001aca:	00006517          	auipc	a0,0x6
    80001ace:	71650513          	addi	a0,a0,1814 # 800081e0 <digits+0x1a0>
    80001ad2:	fffff097          	auipc	ra,0xfffff
    80001ad6:	a70080e7          	jalr	-1424(ra) # 80000542 <panic>

0000000080001ada <cpuid>:
{
    80001ada:	1141                	addi	sp,sp,-16
    80001adc:	e422                	sd	s0,8(sp)
    80001ade:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ae0:	8512                	mv	a0,tp
}
    80001ae2:	2501                	sext.w	a0,a0
    80001ae4:	6422                	ld	s0,8(sp)
    80001ae6:	0141                	addi	sp,sp,16
    80001ae8:	8082                	ret

0000000080001aea <mycpu>:
mycpu(void) {
    80001aea:	1141                	addi	sp,sp,-16
    80001aec:	e422                	sd	s0,8(sp)
    80001aee:	0800                	addi	s0,sp,16
    80001af0:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001af2:	2781                	sext.w	a5,a5
    80001af4:	079e                	slli	a5,a5,0x7
}
    80001af6:	00030517          	auipc	a0,0x30
    80001afa:	e7250513          	addi	a0,a0,-398 # 80031968 <cpus>
    80001afe:	953e                	add	a0,a0,a5
    80001b00:	6422                	ld	s0,8(sp)
    80001b02:	0141                	addi	sp,sp,16
    80001b04:	8082                	ret

0000000080001b06 <myproc>:
myproc(void) {
    80001b06:	1101                	addi	sp,sp,-32
    80001b08:	ec06                	sd	ra,24(sp)
    80001b0a:	e822                	sd	s0,16(sp)
    80001b0c:	e426                	sd	s1,8(sp)
    80001b0e:	1000                	addi	s0,sp,32
  push_off();
    80001b10:	fffff097          	auipc	ra,0xfffff
    80001b14:	1b2080e7          	jalr	434(ra) # 80000cc2 <push_off>
    80001b18:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001b1a:	2781                	sext.w	a5,a5
    80001b1c:	079e                	slli	a5,a5,0x7
    80001b1e:	00030717          	auipc	a4,0x30
    80001b22:	e3270713          	addi	a4,a4,-462 # 80031950 <pid_lock>
    80001b26:	97ba                	add	a5,a5,a4
    80001b28:	6f84                	ld	s1,24(a5)
  pop_off();
    80001b2a:	fffff097          	auipc	ra,0xfffff
    80001b2e:	238080e7          	jalr	568(ra) # 80000d62 <pop_off>
}
    80001b32:	8526                	mv	a0,s1
    80001b34:	60e2                	ld	ra,24(sp)
    80001b36:	6442                	ld	s0,16(sp)
    80001b38:	64a2                	ld	s1,8(sp)
    80001b3a:	6105                	addi	sp,sp,32
    80001b3c:	8082                	ret

0000000080001b3e <forkret>:
{
    80001b3e:	1141                	addi	sp,sp,-16
    80001b40:	e406                	sd	ra,8(sp)
    80001b42:	e022                	sd	s0,0(sp)
    80001b44:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001b46:	00000097          	auipc	ra,0x0
    80001b4a:	fc0080e7          	jalr	-64(ra) # 80001b06 <myproc>
    80001b4e:	fffff097          	auipc	ra,0xfffff
    80001b52:	274080e7          	jalr	628(ra) # 80000dc2 <release>
  if (first) {
    80001b56:	00007797          	auipc	a5,0x7
    80001b5a:	cba7a783          	lw	a5,-838(a5) # 80008810 <first.1>
    80001b5e:	eb89                	bnez	a5,80001b70 <forkret+0x32>
  usertrapret();
    80001b60:	00001097          	auipc	ra,0x1
    80001b64:	c18080e7          	jalr	-1000(ra) # 80002778 <usertrapret>
}
    80001b68:	60a2                	ld	ra,8(sp)
    80001b6a:	6402                	ld	s0,0(sp)
    80001b6c:	0141                	addi	sp,sp,16
    80001b6e:	8082                	ret
    first = 0;
    80001b70:	00007797          	auipc	a5,0x7
    80001b74:	ca07a023          	sw	zero,-864(a5) # 80008810 <first.1>
    fsinit(ROOTDEV);
    80001b78:	4505                	li	a0,1
    80001b7a:	00002097          	auipc	ra,0x2
    80001b7e:	96a080e7          	jalr	-1686(ra) # 800034e4 <fsinit>
    80001b82:	bff9                	j	80001b60 <forkret+0x22>

0000000080001b84 <allocpid>:
allocpid() {
    80001b84:	1101                	addi	sp,sp,-32
    80001b86:	ec06                	sd	ra,24(sp)
    80001b88:	e822                	sd	s0,16(sp)
    80001b8a:	e426                	sd	s1,8(sp)
    80001b8c:	e04a                	sd	s2,0(sp)
    80001b8e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b90:	00030917          	auipc	s2,0x30
    80001b94:	dc090913          	addi	s2,s2,-576 # 80031950 <pid_lock>
    80001b98:	854a                	mv	a0,s2
    80001b9a:	fffff097          	auipc	ra,0xfffff
    80001b9e:	174080e7          	jalr	372(ra) # 80000d0e <acquire>
  pid = nextpid;
    80001ba2:	00007797          	auipc	a5,0x7
    80001ba6:	c7278793          	addi	a5,a5,-910 # 80008814 <nextpid>
    80001baa:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bac:	0014871b          	addiw	a4,s1,1
    80001bb0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bb2:	854a                	mv	a0,s2
    80001bb4:	fffff097          	auipc	ra,0xfffff
    80001bb8:	20e080e7          	jalr	526(ra) # 80000dc2 <release>
}
    80001bbc:	8526                	mv	a0,s1
    80001bbe:	60e2                	ld	ra,24(sp)
    80001bc0:	6442                	ld	s0,16(sp)
    80001bc2:	64a2                	ld	s1,8(sp)
    80001bc4:	6902                	ld	s2,0(sp)
    80001bc6:	6105                	addi	sp,sp,32
    80001bc8:	8082                	ret

0000000080001bca <proc_pagetable>:
{
    80001bca:	1101                	addi	sp,sp,-32
    80001bcc:	ec06                	sd	ra,24(sp)
    80001bce:	e822                	sd	s0,16(sp)
    80001bd0:	e426                	sd	s1,8(sp)
    80001bd2:	e04a                	sd	s2,0(sp)
    80001bd4:	1000                	addi	s0,sp,32
    80001bd6:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bd8:	00000097          	auipc	ra,0x0
    80001bdc:	8bc080e7          	jalr	-1860(ra) # 80001494 <uvmcreate>
    80001be0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001be2:	c121                	beqz	a0,80001c22 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001be4:	4729                	li	a4,10
    80001be6:	00005697          	auipc	a3,0x5
    80001bea:	41a68693          	addi	a3,a3,1050 # 80007000 <_trampoline>
    80001bee:	6605                	lui	a2,0x1
    80001bf0:	040005b7          	lui	a1,0x4000
    80001bf4:	15fd                	addi	a1,a1,-1
    80001bf6:	05b2                	slli	a1,a1,0xc
    80001bf8:	fffff097          	auipc	ra,0xfffff
    80001bfc:	640080e7          	jalr	1600(ra) # 80001238 <mappages>
    80001c00:	02054863          	bltz	a0,80001c30 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c04:	4719                	li	a4,6
    80001c06:	05893683          	ld	a3,88(s2)
    80001c0a:	6605                	lui	a2,0x1
    80001c0c:	020005b7          	lui	a1,0x2000
    80001c10:	15fd                	addi	a1,a1,-1
    80001c12:	05b6                	slli	a1,a1,0xd
    80001c14:	8526                	mv	a0,s1
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	622080e7          	jalr	1570(ra) # 80001238 <mappages>
    80001c1e:	02054163          	bltz	a0,80001c40 <proc_pagetable+0x76>
}
    80001c22:	8526                	mv	a0,s1
    80001c24:	60e2                	ld	ra,24(sp)
    80001c26:	6442                	ld	s0,16(sp)
    80001c28:	64a2                	ld	s1,8(sp)
    80001c2a:	6902                	ld	s2,0(sp)
    80001c2c:	6105                	addi	sp,sp,32
    80001c2e:	8082                	ret
    uvmfree(pagetable, 0);
    80001c30:	4581                	li	a1,0
    80001c32:	8526                	mv	a0,s1
    80001c34:	00000097          	auipc	ra,0x0
    80001c38:	a5c080e7          	jalr	-1444(ra) # 80001690 <uvmfree>
    return 0;
    80001c3c:	4481                	li	s1,0
    80001c3e:	b7d5                	j	80001c22 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c40:	4681                	li	a3,0
    80001c42:	4605                	li	a2,1
    80001c44:	040005b7          	lui	a1,0x4000
    80001c48:	15fd                	addi	a1,a1,-1
    80001c4a:	05b2                	slli	a1,a1,0xc
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	fffff097          	auipc	ra,0xfffff
    80001c52:	782080e7          	jalr	1922(ra) # 800013d0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c56:	4581                	li	a1,0
    80001c58:	8526                	mv	a0,s1
    80001c5a:	00000097          	auipc	ra,0x0
    80001c5e:	a36080e7          	jalr	-1482(ra) # 80001690 <uvmfree>
    return 0;
    80001c62:	4481                	li	s1,0
    80001c64:	bf7d                	j	80001c22 <proc_pagetable+0x58>

0000000080001c66 <proc_freepagetable>:
{
    80001c66:	1101                	addi	sp,sp,-32
    80001c68:	ec06                	sd	ra,24(sp)
    80001c6a:	e822                	sd	s0,16(sp)
    80001c6c:	e426                	sd	s1,8(sp)
    80001c6e:	e04a                	sd	s2,0(sp)
    80001c70:	1000                	addi	s0,sp,32
    80001c72:	84aa                	mv	s1,a0
    80001c74:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c76:	4681                	li	a3,0
    80001c78:	4605                	li	a2,1
    80001c7a:	040005b7          	lui	a1,0x4000
    80001c7e:	15fd                	addi	a1,a1,-1
    80001c80:	05b2                	slli	a1,a1,0xc
    80001c82:	fffff097          	auipc	ra,0xfffff
    80001c86:	74e080e7          	jalr	1870(ra) # 800013d0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c8a:	4681                	li	a3,0
    80001c8c:	4605                	li	a2,1
    80001c8e:	020005b7          	lui	a1,0x2000
    80001c92:	15fd                	addi	a1,a1,-1
    80001c94:	05b6                	slli	a1,a1,0xd
    80001c96:	8526                	mv	a0,s1
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	738080e7          	jalr	1848(ra) # 800013d0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ca0:	85ca                	mv	a1,s2
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	00000097          	auipc	ra,0x0
    80001ca8:	9ec080e7          	jalr	-1556(ra) # 80001690 <uvmfree>
}
    80001cac:	60e2                	ld	ra,24(sp)
    80001cae:	6442                	ld	s0,16(sp)
    80001cb0:	64a2                	ld	s1,8(sp)
    80001cb2:	6902                	ld	s2,0(sp)
    80001cb4:	6105                	addi	sp,sp,32
    80001cb6:	8082                	ret

0000000080001cb8 <freeproc>:
{
    80001cb8:	1101                	addi	sp,sp,-32
    80001cba:	ec06                	sd	ra,24(sp)
    80001cbc:	e822                	sd	s0,16(sp)
    80001cbe:	e426                	sd	s1,8(sp)
    80001cc0:	1000                	addi	s0,sp,32
    80001cc2:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001cc4:	6d28                	ld	a0,88(a0)
    80001cc6:	c509                	beqz	a0,80001cd0 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001cc8:	fffff097          	auipc	ra,0xfffff
    80001ccc:	d4a080e7          	jalr	-694(ra) # 80000a12 <kfree>
  p->trapframe = 0;
    80001cd0:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001cd4:	68a8                	ld	a0,80(s1)
    80001cd6:	c511                	beqz	a0,80001ce2 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001cd8:	64ac                	ld	a1,72(s1)
    80001cda:	00000097          	auipc	ra,0x0
    80001cde:	f8c080e7          	jalr	-116(ra) # 80001c66 <proc_freepagetable>
  p->pagetable = 0;
    80001ce2:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ce6:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001cea:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001cee:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001cf2:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001cf6:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001cfa:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001cfe:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001d02:	0004ac23          	sw	zero,24(s1)
}
    80001d06:	60e2                	ld	ra,24(sp)
    80001d08:	6442                	ld	s0,16(sp)
    80001d0a:	64a2                	ld	s1,8(sp)
    80001d0c:	6105                	addi	sp,sp,32
    80001d0e:	8082                	ret

0000000080001d10 <allocproc>:
{
    80001d10:	1101                	addi	sp,sp,-32
    80001d12:	ec06                	sd	ra,24(sp)
    80001d14:	e822                	sd	s0,16(sp)
    80001d16:	e426                	sd	s1,8(sp)
    80001d18:	e04a                	sd	s2,0(sp)
    80001d1a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d1c:	00030497          	auipc	s1,0x30
    80001d20:	04c48493          	addi	s1,s1,76 # 80031d68 <proc>
    80001d24:	00036917          	auipc	s2,0x36
    80001d28:	a4490913          	addi	s2,s2,-1468 # 80037768 <tickslock>
    acquire(&p->lock);
    80001d2c:	8526                	mv	a0,s1
    80001d2e:	fffff097          	auipc	ra,0xfffff
    80001d32:	fe0080e7          	jalr	-32(ra) # 80000d0e <acquire>
    if(p->state == UNUSED) {
    80001d36:	4c9c                	lw	a5,24(s1)
    80001d38:	cf81                	beqz	a5,80001d50 <allocproc+0x40>
      release(&p->lock);
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	086080e7          	jalr	134(ra) # 80000dc2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d44:	16848493          	addi	s1,s1,360
    80001d48:	ff2492e3          	bne	s1,s2,80001d2c <allocproc+0x1c>
  return 0;
    80001d4c:	4481                	li	s1,0
    80001d4e:	a0b9                	j	80001d9c <allocproc+0x8c>
  p->pid = allocpid();
    80001d50:	00000097          	auipc	ra,0x0
    80001d54:	e34080e7          	jalr	-460(ra) # 80001b84 <allocpid>
    80001d58:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d5a:	fffff097          	auipc	ra,0xfffff
    80001d5e:	df4080e7          	jalr	-524(ra) # 80000b4e <kalloc>
    80001d62:	892a                	mv	s2,a0
    80001d64:	eca8                	sd	a0,88(s1)
    80001d66:	c131                	beqz	a0,80001daa <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001d68:	8526                	mv	a0,s1
    80001d6a:	00000097          	auipc	ra,0x0
    80001d6e:	e60080e7          	jalr	-416(ra) # 80001bca <proc_pagetable>
    80001d72:	892a                	mv	s2,a0
    80001d74:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d76:	c129                	beqz	a0,80001db8 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001d78:	07000613          	li	a2,112
    80001d7c:	4581                	li	a1,0
    80001d7e:	06048513          	addi	a0,s1,96
    80001d82:	fffff097          	auipc	ra,0xfffff
    80001d86:	088080e7          	jalr	136(ra) # 80000e0a <memset>
  p->context.ra = (uint64)forkret;
    80001d8a:	00000797          	auipc	a5,0x0
    80001d8e:	db478793          	addi	a5,a5,-588 # 80001b3e <forkret>
    80001d92:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d94:	60bc                	ld	a5,64(s1)
    80001d96:	6705                	lui	a4,0x1
    80001d98:	97ba                	add	a5,a5,a4
    80001d9a:	f4bc                	sd	a5,104(s1)
}
    80001d9c:	8526                	mv	a0,s1
    80001d9e:	60e2                	ld	ra,24(sp)
    80001da0:	6442                	ld	s0,16(sp)
    80001da2:	64a2                	ld	s1,8(sp)
    80001da4:	6902                	ld	s2,0(sp)
    80001da6:	6105                	addi	sp,sp,32
    80001da8:	8082                	ret
    release(&p->lock);
    80001daa:	8526                	mv	a0,s1
    80001dac:	fffff097          	auipc	ra,0xfffff
    80001db0:	016080e7          	jalr	22(ra) # 80000dc2 <release>
    return 0;
    80001db4:	84ca                	mv	s1,s2
    80001db6:	b7dd                	j	80001d9c <allocproc+0x8c>
    freeproc(p);
    80001db8:	8526                	mv	a0,s1
    80001dba:	00000097          	auipc	ra,0x0
    80001dbe:	efe080e7          	jalr	-258(ra) # 80001cb8 <freeproc>
    release(&p->lock);
    80001dc2:	8526                	mv	a0,s1
    80001dc4:	fffff097          	auipc	ra,0xfffff
    80001dc8:	ffe080e7          	jalr	-2(ra) # 80000dc2 <release>
    return 0;
    80001dcc:	84ca                	mv	s1,s2
    80001dce:	b7f9                	j	80001d9c <allocproc+0x8c>

0000000080001dd0 <userinit>:
{
    80001dd0:	1101                	addi	sp,sp,-32
    80001dd2:	ec06                	sd	ra,24(sp)
    80001dd4:	e822                	sd	s0,16(sp)
    80001dd6:	e426                	sd	s1,8(sp)
    80001dd8:	1000                	addi	s0,sp,32
  p = allocproc();
    80001dda:	00000097          	auipc	ra,0x0
    80001dde:	f36080e7          	jalr	-202(ra) # 80001d10 <allocproc>
    80001de2:	84aa                	mv	s1,a0
  initproc = p;
    80001de4:	00007797          	auipc	a5,0x7
    80001de8:	22a7ba23          	sd	a0,564(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001dec:	03400613          	li	a2,52
    80001df0:	00007597          	auipc	a1,0x7
    80001df4:	a3058593          	addi	a1,a1,-1488 # 80008820 <initcode>
    80001df8:	6928                	ld	a0,80(a0)
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	6c8080e7          	jalr	1736(ra) # 800014c2 <uvminit>
  p->sz = PGSIZE;
    80001e02:	6785                	lui	a5,0x1
    80001e04:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001e06:	6cb8                	ld	a4,88(s1)
    80001e08:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001e0c:	6cb8                	ld	a4,88(s1)
    80001e0e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e10:	4641                	li	a2,16
    80001e12:	00006597          	auipc	a1,0x6
    80001e16:	3d658593          	addi	a1,a1,982 # 800081e8 <digits+0x1a8>
    80001e1a:	15848513          	addi	a0,s1,344
    80001e1e:	fffff097          	auipc	ra,0xfffff
    80001e22:	13e080e7          	jalr	318(ra) # 80000f5c <safestrcpy>
  p->cwd = namei("/");
    80001e26:	00006517          	auipc	a0,0x6
    80001e2a:	3d250513          	addi	a0,a0,978 # 800081f8 <digits+0x1b8>
    80001e2e:	00002097          	auipc	ra,0x2
    80001e32:	0e2080e7          	jalr	226(ra) # 80003f10 <namei>
    80001e36:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e3a:	4789                	li	a5,2
    80001e3c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e3e:	8526                	mv	a0,s1
    80001e40:	fffff097          	auipc	ra,0xfffff
    80001e44:	f82080e7          	jalr	-126(ra) # 80000dc2 <release>
}
    80001e48:	60e2                	ld	ra,24(sp)
    80001e4a:	6442                	ld	s0,16(sp)
    80001e4c:	64a2                	ld	s1,8(sp)
    80001e4e:	6105                	addi	sp,sp,32
    80001e50:	8082                	ret

0000000080001e52 <growproc>:
{
    80001e52:	1101                	addi	sp,sp,-32
    80001e54:	ec06                	sd	ra,24(sp)
    80001e56:	e822                	sd	s0,16(sp)
    80001e58:	e426                	sd	s1,8(sp)
    80001e5a:	e04a                	sd	s2,0(sp)
    80001e5c:	1000                	addi	s0,sp,32
    80001e5e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e60:	00000097          	auipc	ra,0x0
    80001e64:	ca6080e7          	jalr	-858(ra) # 80001b06 <myproc>
    80001e68:	892a                	mv	s2,a0
  sz = p->sz;
    80001e6a:	652c                	ld	a1,72(a0)
    80001e6c:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001e70:	00904f63          	bgtz	s1,80001e8e <growproc+0x3c>
  } else if(n < 0){
    80001e74:	0204cc63          	bltz	s1,80001eac <growproc+0x5a>
  p->sz = sz;
    80001e78:	1602                	slli	a2,a2,0x20
    80001e7a:	9201                	srli	a2,a2,0x20
    80001e7c:	04c93423          	sd	a2,72(s2)
  return 0;
    80001e80:	4501                	li	a0,0
}
    80001e82:	60e2                	ld	ra,24(sp)
    80001e84:	6442                	ld	s0,16(sp)
    80001e86:	64a2                	ld	s1,8(sp)
    80001e88:	6902                	ld	s2,0(sp)
    80001e8a:	6105                	addi	sp,sp,32
    80001e8c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e8e:	9e25                	addw	a2,a2,s1
    80001e90:	1602                	slli	a2,a2,0x20
    80001e92:	9201                	srli	a2,a2,0x20
    80001e94:	1582                	slli	a1,a1,0x20
    80001e96:	9181                	srli	a1,a1,0x20
    80001e98:	6928                	ld	a0,80(a0)
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	6e2080e7          	jalr	1762(ra) # 8000157c <uvmalloc>
    80001ea2:	0005061b          	sext.w	a2,a0
    80001ea6:	fa69                	bnez	a2,80001e78 <growproc+0x26>
      return -1;
    80001ea8:	557d                	li	a0,-1
    80001eaa:	bfe1                	j	80001e82 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001eac:	9e25                	addw	a2,a2,s1
    80001eae:	1602                	slli	a2,a2,0x20
    80001eb0:	9201                	srli	a2,a2,0x20
    80001eb2:	1582                	slli	a1,a1,0x20
    80001eb4:	9181                	srli	a1,a1,0x20
    80001eb6:	6928                	ld	a0,80(a0)
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	67c080e7          	jalr	1660(ra) # 80001534 <uvmdealloc>
    80001ec0:	0005061b          	sext.w	a2,a0
    80001ec4:	bf55                	j	80001e78 <growproc+0x26>

0000000080001ec6 <fork>:
{
    80001ec6:	7139                	addi	sp,sp,-64
    80001ec8:	fc06                	sd	ra,56(sp)
    80001eca:	f822                	sd	s0,48(sp)
    80001ecc:	f426                	sd	s1,40(sp)
    80001ece:	f04a                	sd	s2,32(sp)
    80001ed0:	ec4e                	sd	s3,24(sp)
    80001ed2:	e852                	sd	s4,16(sp)
    80001ed4:	e456                	sd	s5,8(sp)
    80001ed6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ed8:	00000097          	auipc	ra,0x0
    80001edc:	c2e080e7          	jalr	-978(ra) # 80001b06 <myproc>
    80001ee0:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001ee2:	00000097          	auipc	ra,0x0
    80001ee6:	e2e080e7          	jalr	-466(ra) # 80001d10 <allocproc>
    80001eea:	c17d                	beqz	a0,80001fd0 <fork+0x10a>
    80001eec:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001eee:	048ab603          	ld	a2,72(s5)
    80001ef2:	692c                	ld	a1,80(a0)
    80001ef4:	050ab503          	ld	a0,80(s5)
    80001ef8:	fffff097          	auipc	ra,0xfffff
    80001efc:	7d0080e7          	jalr	2000(ra) # 800016c8 <uvmcopy>
    80001f00:	04054a63          	bltz	a0,80001f54 <fork+0x8e>
  np->sz = p->sz;
    80001f04:	048ab783          	ld	a5,72(s5)
    80001f08:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001f0c:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80001f10:	058ab683          	ld	a3,88(s5)
    80001f14:	87b6                	mv	a5,a3
    80001f16:	058a3703          	ld	a4,88(s4)
    80001f1a:	12068693          	addi	a3,a3,288
    80001f1e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f22:	6788                	ld	a0,8(a5)
    80001f24:	6b8c                	ld	a1,16(a5)
    80001f26:	6f90                	ld	a2,24(a5)
    80001f28:	01073023          	sd	a6,0(a4)
    80001f2c:	e708                	sd	a0,8(a4)
    80001f2e:	eb0c                	sd	a1,16(a4)
    80001f30:	ef10                	sd	a2,24(a4)
    80001f32:	02078793          	addi	a5,a5,32
    80001f36:	02070713          	addi	a4,a4,32
    80001f3a:	fed792e3          	bne	a5,a3,80001f1e <fork+0x58>
  np->trapframe->a0 = 0;
    80001f3e:	058a3783          	ld	a5,88(s4)
    80001f42:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f46:	0d0a8493          	addi	s1,s5,208
    80001f4a:	0d0a0913          	addi	s2,s4,208
    80001f4e:	150a8993          	addi	s3,s5,336
    80001f52:	a00d                	j	80001f74 <fork+0xae>
    freeproc(np);
    80001f54:	8552                	mv	a0,s4
    80001f56:	00000097          	auipc	ra,0x0
    80001f5a:	d62080e7          	jalr	-670(ra) # 80001cb8 <freeproc>
    release(&np->lock);
    80001f5e:	8552                	mv	a0,s4
    80001f60:	fffff097          	auipc	ra,0xfffff
    80001f64:	e62080e7          	jalr	-414(ra) # 80000dc2 <release>
    return -1;
    80001f68:	54fd                	li	s1,-1
    80001f6a:	a889                	j	80001fbc <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001f6c:	04a1                	addi	s1,s1,8
    80001f6e:	0921                	addi	s2,s2,8
    80001f70:	01348b63          	beq	s1,s3,80001f86 <fork+0xc0>
    if(p->ofile[i])
    80001f74:	6088                	ld	a0,0(s1)
    80001f76:	d97d                	beqz	a0,80001f6c <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f78:	00002097          	auipc	ra,0x2
    80001f7c:	624080e7          	jalr	1572(ra) # 8000459c <filedup>
    80001f80:	00a93023          	sd	a0,0(s2)
    80001f84:	b7e5                	j	80001f6c <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001f86:	150ab503          	ld	a0,336(s5)
    80001f8a:	00001097          	auipc	ra,0x1
    80001f8e:	794080e7          	jalr	1940(ra) # 8000371e <idup>
    80001f92:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f96:	4641                	li	a2,16
    80001f98:	158a8593          	addi	a1,s5,344
    80001f9c:	158a0513          	addi	a0,s4,344
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	fbc080e7          	jalr	-68(ra) # 80000f5c <safestrcpy>
  pid = np->pid;
    80001fa8:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001fac:	4789                	li	a5,2
    80001fae:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001fb2:	8552                	mv	a0,s4
    80001fb4:	fffff097          	auipc	ra,0xfffff
    80001fb8:	e0e080e7          	jalr	-498(ra) # 80000dc2 <release>
}
    80001fbc:	8526                	mv	a0,s1
    80001fbe:	70e2                	ld	ra,56(sp)
    80001fc0:	7442                	ld	s0,48(sp)
    80001fc2:	74a2                	ld	s1,40(sp)
    80001fc4:	7902                	ld	s2,32(sp)
    80001fc6:	69e2                	ld	s3,24(sp)
    80001fc8:	6a42                	ld	s4,16(sp)
    80001fca:	6aa2                	ld	s5,8(sp)
    80001fcc:	6121                	addi	sp,sp,64
    80001fce:	8082                	ret
    return -1;
    80001fd0:	54fd                	li	s1,-1
    80001fd2:	b7ed                	j	80001fbc <fork+0xf6>

0000000080001fd4 <reparent>:
{
    80001fd4:	7179                	addi	sp,sp,-48
    80001fd6:	f406                	sd	ra,40(sp)
    80001fd8:	f022                	sd	s0,32(sp)
    80001fda:	ec26                	sd	s1,24(sp)
    80001fdc:	e84a                	sd	s2,16(sp)
    80001fde:	e44e                	sd	s3,8(sp)
    80001fe0:	e052                	sd	s4,0(sp)
    80001fe2:	1800                	addi	s0,sp,48
    80001fe4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fe6:	00030497          	auipc	s1,0x30
    80001fea:	d8248493          	addi	s1,s1,-638 # 80031d68 <proc>
      pp->parent = initproc;
    80001fee:	00007a17          	auipc	s4,0x7
    80001ff2:	02aa0a13          	addi	s4,s4,42 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ff6:	00035997          	auipc	s3,0x35
    80001ffa:	77298993          	addi	s3,s3,1906 # 80037768 <tickslock>
    80001ffe:	a029                	j	80002008 <reparent+0x34>
    80002000:	16848493          	addi	s1,s1,360
    80002004:	03348363          	beq	s1,s3,8000202a <reparent+0x56>
    if(pp->parent == p){
    80002008:	709c                	ld	a5,32(s1)
    8000200a:	ff279be3          	bne	a5,s2,80002000 <reparent+0x2c>
      acquire(&pp->lock);
    8000200e:	8526                	mv	a0,s1
    80002010:	fffff097          	auipc	ra,0xfffff
    80002014:	cfe080e7          	jalr	-770(ra) # 80000d0e <acquire>
      pp->parent = initproc;
    80002018:	000a3783          	ld	a5,0(s4)
    8000201c:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    8000201e:	8526                	mv	a0,s1
    80002020:	fffff097          	auipc	ra,0xfffff
    80002024:	da2080e7          	jalr	-606(ra) # 80000dc2 <release>
    80002028:	bfe1                	j	80002000 <reparent+0x2c>
}
    8000202a:	70a2                	ld	ra,40(sp)
    8000202c:	7402                	ld	s0,32(sp)
    8000202e:	64e2                	ld	s1,24(sp)
    80002030:	6942                	ld	s2,16(sp)
    80002032:	69a2                	ld	s3,8(sp)
    80002034:	6a02                	ld	s4,0(sp)
    80002036:	6145                	addi	sp,sp,48
    80002038:	8082                	ret

000000008000203a <scheduler>:
{
    8000203a:	711d                	addi	sp,sp,-96
    8000203c:	ec86                	sd	ra,88(sp)
    8000203e:	e8a2                	sd	s0,80(sp)
    80002040:	e4a6                	sd	s1,72(sp)
    80002042:	e0ca                	sd	s2,64(sp)
    80002044:	fc4e                	sd	s3,56(sp)
    80002046:	f852                	sd	s4,48(sp)
    80002048:	f456                	sd	s5,40(sp)
    8000204a:	f05a                	sd	s6,32(sp)
    8000204c:	ec5e                	sd	s7,24(sp)
    8000204e:	e862                	sd	s8,16(sp)
    80002050:	e466                	sd	s9,8(sp)
    80002052:	1080                	addi	s0,sp,96
    80002054:	8792                	mv	a5,tp
  int id = r_tp();
    80002056:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002058:	00779c13          	slli	s8,a5,0x7
    8000205c:	00030717          	auipc	a4,0x30
    80002060:	8f470713          	addi	a4,a4,-1804 # 80031950 <pid_lock>
    80002064:	9762                	add	a4,a4,s8
    80002066:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    8000206a:	00030717          	auipc	a4,0x30
    8000206e:	90670713          	addi	a4,a4,-1786 # 80031970 <cpus+0x8>
    80002072:	9c3a                	add	s8,s8,a4
    int nproc = 0;
    80002074:	4c81                	li	s9,0
      if(p->state == RUNNABLE) {
    80002076:	4a89                	li	s5,2
        c->proc = p;
    80002078:	079e                	slli	a5,a5,0x7
    8000207a:	00030b17          	auipc	s6,0x30
    8000207e:	8d6b0b13          	addi	s6,s6,-1834 # 80031950 <pid_lock>
    80002082:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002084:	00035a17          	auipc	s4,0x35
    80002088:	6e4a0a13          	addi	s4,s4,1764 # 80037768 <tickslock>
    8000208c:	a8a1                	j	800020e4 <scheduler+0xaa>
      release(&p->lock);
    8000208e:	8526                	mv	a0,s1
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	d32080e7          	jalr	-718(ra) # 80000dc2 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002098:	16848493          	addi	s1,s1,360
    8000209c:	03448a63          	beq	s1,s4,800020d0 <scheduler+0x96>
      acquire(&p->lock);
    800020a0:	8526                	mv	a0,s1
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	c6c080e7          	jalr	-916(ra) # 80000d0e <acquire>
      if(p->state != UNUSED) {
    800020aa:	4c9c                	lw	a5,24(s1)
    800020ac:	d3ed                	beqz	a5,8000208e <scheduler+0x54>
        nproc++;
    800020ae:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    800020b0:	fd579fe3          	bne	a5,s5,8000208e <scheduler+0x54>
        p->state = RUNNING;
    800020b4:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    800020b8:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    800020bc:	06048593          	addi	a1,s1,96
    800020c0:	8562                	mv	a0,s8
    800020c2:	00000097          	auipc	ra,0x0
    800020c6:	60c080e7          	jalr	1548(ra) # 800026ce <swtch>
        c->proc = 0;
    800020ca:	000b3c23          	sd	zero,24(s6)
    800020ce:	b7c1                	j	8000208e <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    800020d0:	013aca63          	blt	s5,s3,800020e4 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020d4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020d8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020dc:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800020e0:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020e4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020e8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020ec:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    800020f0:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    800020f2:	00030497          	auipc	s1,0x30
    800020f6:	c7648493          	addi	s1,s1,-906 # 80031d68 <proc>
        p->state = RUNNING;
    800020fa:	4b8d                	li	s7,3
    800020fc:	b755                	j	800020a0 <scheduler+0x66>

00000000800020fe <sched>:
{
    800020fe:	7179                	addi	sp,sp,-48
    80002100:	f406                	sd	ra,40(sp)
    80002102:	f022                	sd	s0,32(sp)
    80002104:	ec26                	sd	s1,24(sp)
    80002106:	e84a                	sd	s2,16(sp)
    80002108:	e44e                	sd	s3,8(sp)
    8000210a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000210c:	00000097          	auipc	ra,0x0
    80002110:	9fa080e7          	jalr	-1542(ra) # 80001b06 <myproc>
    80002114:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	b7e080e7          	jalr	-1154(ra) # 80000c94 <holding>
    8000211e:	c93d                	beqz	a0,80002194 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002120:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002122:	2781                	sext.w	a5,a5
    80002124:	079e                	slli	a5,a5,0x7
    80002126:	00030717          	auipc	a4,0x30
    8000212a:	82a70713          	addi	a4,a4,-2006 # 80031950 <pid_lock>
    8000212e:	97ba                	add	a5,a5,a4
    80002130:	0907a703          	lw	a4,144(a5)
    80002134:	4785                	li	a5,1
    80002136:	06f71763          	bne	a4,a5,800021a4 <sched+0xa6>
  if(p->state == RUNNING)
    8000213a:	4c98                	lw	a4,24(s1)
    8000213c:	478d                	li	a5,3
    8000213e:	06f70b63          	beq	a4,a5,800021b4 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002142:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002146:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002148:	efb5                	bnez	a5,800021c4 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000214a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000214c:	00030917          	auipc	s2,0x30
    80002150:	80490913          	addi	s2,s2,-2044 # 80031950 <pid_lock>
    80002154:	2781                	sext.w	a5,a5
    80002156:	079e                	slli	a5,a5,0x7
    80002158:	97ca                	add	a5,a5,s2
    8000215a:	0947a983          	lw	s3,148(a5)
    8000215e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002160:	2781                	sext.w	a5,a5
    80002162:	079e                	slli	a5,a5,0x7
    80002164:	00030597          	auipc	a1,0x30
    80002168:	80c58593          	addi	a1,a1,-2036 # 80031970 <cpus+0x8>
    8000216c:	95be                	add	a1,a1,a5
    8000216e:	06048513          	addi	a0,s1,96
    80002172:	00000097          	auipc	ra,0x0
    80002176:	55c080e7          	jalr	1372(ra) # 800026ce <swtch>
    8000217a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000217c:	2781                	sext.w	a5,a5
    8000217e:	079e                	slli	a5,a5,0x7
    80002180:	97ca                	add	a5,a5,s2
    80002182:	0937aa23          	sw	s3,148(a5)
}
    80002186:	70a2                	ld	ra,40(sp)
    80002188:	7402                	ld	s0,32(sp)
    8000218a:	64e2                	ld	s1,24(sp)
    8000218c:	6942                	ld	s2,16(sp)
    8000218e:	69a2                	ld	s3,8(sp)
    80002190:	6145                	addi	sp,sp,48
    80002192:	8082                	ret
    panic("sched p->lock");
    80002194:	00006517          	auipc	a0,0x6
    80002198:	06c50513          	addi	a0,a0,108 # 80008200 <digits+0x1c0>
    8000219c:	ffffe097          	auipc	ra,0xffffe
    800021a0:	3a6080e7          	jalr	934(ra) # 80000542 <panic>
    panic("sched locks");
    800021a4:	00006517          	auipc	a0,0x6
    800021a8:	06c50513          	addi	a0,a0,108 # 80008210 <digits+0x1d0>
    800021ac:	ffffe097          	auipc	ra,0xffffe
    800021b0:	396080e7          	jalr	918(ra) # 80000542 <panic>
    panic("sched running");
    800021b4:	00006517          	auipc	a0,0x6
    800021b8:	06c50513          	addi	a0,a0,108 # 80008220 <digits+0x1e0>
    800021bc:	ffffe097          	auipc	ra,0xffffe
    800021c0:	386080e7          	jalr	902(ra) # 80000542 <panic>
    panic("sched interruptible");
    800021c4:	00006517          	auipc	a0,0x6
    800021c8:	06c50513          	addi	a0,a0,108 # 80008230 <digits+0x1f0>
    800021cc:	ffffe097          	auipc	ra,0xffffe
    800021d0:	376080e7          	jalr	886(ra) # 80000542 <panic>

00000000800021d4 <exit>:
{
    800021d4:	7179                	addi	sp,sp,-48
    800021d6:	f406                	sd	ra,40(sp)
    800021d8:	f022                	sd	s0,32(sp)
    800021da:	ec26                	sd	s1,24(sp)
    800021dc:	e84a                	sd	s2,16(sp)
    800021de:	e44e                	sd	s3,8(sp)
    800021e0:	e052                	sd	s4,0(sp)
    800021e2:	1800                	addi	s0,sp,48
    800021e4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021e6:	00000097          	auipc	ra,0x0
    800021ea:	920080e7          	jalr	-1760(ra) # 80001b06 <myproc>
    800021ee:	89aa                	mv	s3,a0
  if(p == initproc)
    800021f0:	00007797          	auipc	a5,0x7
    800021f4:	e287b783          	ld	a5,-472(a5) # 80009018 <initproc>
    800021f8:	0d050493          	addi	s1,a0,208
    800021fc:	15050913          	addi	s2,a0,336
    80002200:	02a79363          	bne	a5,a0,80002226 <exit+0x52>
    panic("init exiting");
    80002204:	00006517          	auipc	a0,0x6
    80002208:	04450513          	addi	a0,a0,68 # 80008248 <digits+0x208>
    8000220c:	ffffe097          	auipc	ra,0xffffe
    80002210:	336080e7          	jalr	822(ra) # 80000542 <panic>
      fileclose(f);
    80002214:	00002097          	auipc	ra,0x2
    80002218:	3da080e7          	jalr	986(ra) # 800045ee <fileclose>
      p->ofile[fd] = 0;
    8000221c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002220:	04a1                	addi	s1,s1,8
    80002222:	01248563          	beq	s1,s2,8000222c <exit+0x58>
    if(p->ofile[fd]){
    80002226:	6088                	ld	a0,0(s1)
    80002228:	f575                	bnez	a0,80002214 <exit+0x40>
    8000222a:	bfdd                	j	80002220 <exit+0x4c>
  begin_op();
    8000222c:	00002097          	auipc	ra,0x2
    80002230:	ef0080e7          	jalr	-272(ra) # 8000411c <begin_op>
  iput(p->cwd);
    80002234:	1509b503          	ld	a0,336(s3)
    80002238:	00001097          	auipc	ra,0x1
    8000223c:	6de080e7          	jalr	1758(ra) # 80003916 <iput>
  end_op();
    80002240:	00002097          	auipc	ra,0x2
    80002244:	f5c080e7          	jalr	-164(ra) # 8000419c <end_op>
  p->cwd = 0;
    80002248:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000224c:	00007497          	auipc	s1,0x7
    80002250:	dcc48493          	addi	s1,s1,-564 # 80009018 <initproc>
    80002254:	6088                	ld	a0,0(s1)
    80002256:	fffff097          	auipc	ra,0xfffff
    8000225a:	ab8080e7          	jalr	-1352(ra) # 80000d0e <acquire>
  wakeup1(initproc);
    8000225e:	6088                	ld	a0,0(s1)
    80002260:	fffff097          	auipc	ra,0xfffff
    80002264:	766080e7          	jalr	1894(ra) # 800019c6 <wakeup1>
  release(&initproc->lock);
    80002268:	6088                	ld	a0,0(s1)
    8000226a:	fffff097          	auipc	ra,0xfffff
    8000226e:	b58080e7          	jalr	-1192(ra) # 80000dc2 <release>
  acquire(&p->lock);
    80002272:	854e                	mv	a0,s3
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	a9a080e7          	jalr	-1382(ra) # 80000d0e <acquire>
  struct proc *original_parent = p->parent;
    8000227c:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002280:	854e                	mv	a0,s3
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	b40080e7          	jalr	-1216(ra) # 80000dc2 <release>
  acquire(&original_parent->lock);
    8000228a:	8526                	mv	a0,s1
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	a82080e7          	jalr	-1406(ra) # 80000d0e <acquire>
  acquire(&p->lock);
    80002294:	854e                	mv	a0,s3
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	a78080e7          	jalr	-1416(ra) # 80000d0e <acquire>
  reparent(p);
    8000229e:	854e                	mv	a0,s3
    800022a0:	00000097          	auipc	ra,0x0
    800022a4:	d34080e7          	jalr	-716(ra) # 80001fd4 <reparent>
  wakeup1(original_parent);
    800022a8:	8526                	mv	a0,s1
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	71c080e7          	jalr	1820(ra) # 800019c6 <wakeup1>
  p->xstate = status;
    800022b2:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800022b6:	4791                	li	a5,4
    800022b8:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800022bc:	8526                	mv	a0,s1
    800022be:	fffff097          	auipc	ra,0xfffff
    800022c2:	b04080e7          	jalr	-1276(ra) # 80000dc2 <release>
  sched();
    800022c6:	00000097          	auipc	ra,0x0
    800022ca:	e38080e7          	jalr	-456(ra) # 800020fe <sched>
  panic("zombie exit");
    800022ce:	00006517          	auipc	a0,0x6
    800022d2:	f8a50513          	addi	a0,a0,-118 # 80008258 <digits+0x218>
    800022d6:	ffffe097          	auipc	ra,0xffffe
    800022da:	26c080e7          	jalr	620(ra) # 80000542 <panic>

00000000800022de <yield>:
{
    800022de:	1101                	addi	sp,sp,-32
    800022e0:	ec06                	sd	ra,24(sp)
    800022e2:	e822                	sd	s0,16(sp)
    800022e4:	e426                	sd	s1,8(sp)
    800022e6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022e8:	00000097          	auipc	ra,0x0
    800022ec:	81e080e7          	jalr	-2018(ra) # 80001b06 <myproc>
    800022f0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	a1c080e7          	jalr	-1508(ra) # 80000d0e <acquire>
  p->state = RUNNABLE;
    800022fa:	4789                	li	a5,2
    800022fc:	cc9c                	sw	a5,24(s1)
  sched();
    800022fe:	00000097          	auipc	ra,0x0
    80002302:	e00080e7          	jalr	-512(ra) # 800020fe <sched>
  release(&p->lock);
    80002306:	8526                	mv	a0,s1
    80002308:	fffff097          	auipc	ra,0xfffff
    8000230c:	aba080e7          	jalr	-1350(ra) # 80000dc2 <release>
}
    80002310:	60e2                	ld	ra,24(sp)
    80002312:	6442                	ld	s0,16(sp)
    80002314:	64a2                	ld	s1,8(sp)
    80002316:	6105                	addi	sp,sp,32
    80002318:	8082                	ret

000000008000231a <sleep>:
{
    8000231a:	7179                	addi	sp,sp,-48
    8000231c:	f406                	sd	ra,40(sp)
    8000231e:	f022                	sd	s0,32(sp)
    80002320:	ec26                	sd	s1,24(sp)
    80002322:	e84a                	sd	s2,16(sp)
    80002324:	e44e                	sd	s3,8(sp)
    80002326:	1800                	addi	s0,sp,48
    80002328:	89aa                	mv	s3,a0
    8000232a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	7da080e7          	jalr	2010(ra) # 80001b06 <myproc>
    80002334:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002336:	05250663          	beq	a0,s2,80002382 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	9d4080e7          	jalr	-1580(ra) # 80000d0e <acquire>
    release(lk);
    80002342:	854a                	mv	a0,s2
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	a7e080e7          	jalr	-1410(ra) # 80000dc2 <release>
  p->chan = chan;
    8000234c:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002350:	4785                	li	a5,1
    80002352:	cc9c                	sw	a5,24(s1)
  sched();
    80002354:	00000097          	auipc	ra,0x0
    80002358:	daa080e7          	jalr	-598(ra) # 800020fe <sched>
  p->chan = 0;
    8000235c:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002360:	8526                	mv	a0,s1
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	a60080e7          	jalr	-1440(ra) # 80000dc2 <release>
    acquire(lk);
    8000236a:	854a                	mv	a0,s2
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	9a2080e7          	jalr	-1630(ra) # 80000d0e <acquire>
}
    80002374:	70a2                	ld	ra,40(sp)
    80002376:	7402                	ld	s0,32(sp)
    80002378:	64e2                	ld	s1,24(sp)
    8000237a:	6942                	ld	s2,16(sp)
    8000237c:	69a2                	ld	s3,8(sp)
    8000237e:	6145                	addi	sp,sp,48
    80002380:	8082                	ret
  p->chan = chan;
    80002382:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002386:	4785                	li	a5,1
    80002388:	cd1c                	sw	a5,24(a0)
  sched();
    8000238a:	00000097          	auipc	ra,0x0
    8000238e:	d74080e7          	jalr	-652(ra) # 800020fe <sched>
  p->chan = 0;
    80002392:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002396:	bff9                	j	80002374 <sleep+0x5a>

0000000080002398 <wait>:
{
    80002398:	715d                	addi	sp,sp,-80
    8000239a:	e486                	sd	ra,72(sp)
    8000239c:	e0a2                	sd	s0,64(sp)
    8000239e:	fc26                	sd	s1,56(sp)
    800023a0:	f84a                	sd	s2,48(sp)
    800023a2:	f44e                	sd	s3,40(sp)
    800023a4:	f052                	sd	s4,32(sp)
    800023a6:	ec56                	sd	s5,24(sp)
    800023a8:	e85a                	sd	s6,16(sp)
    800023aa:	e45e                	sd	s7,8(sp)
    800023ac:	0880                	addi	s0,sp,80
    800023ae:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	756080e7          	jalr	1878(ra) # 80001b06 <myproc>
    800023b8:	892a                	mv	s2,a0
  acquire(&p->lock);
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	954080e7          	jalr	-1708(ra) # 80000d0e <acquire>
    havekids = 0;
    800023c2:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800023c4:	4a11                	li	s4,4
        havekids = 1;
    800023c6:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800023c8:	00035997          	auipc	s3,0x35
    800023cc:	3a098993          	addi	s3,s3,928 # 80037768 <tickslock>
    havekids = 0;
    800023d0:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800023d2:	00030497          	auipc	s1,0x30
    800023d6:	99648493          	addi	s1,s1,-1642 # 80031d68 <proc>
    800023da:	a08d                	j	8000243c <wait+0xa4>
          pid = np->pid;
    800023dc:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800023e0:	000b0e63          	beqz	s6,800023fc <wait+0x64>
    800023e4:	4691                	li	a3,4
    800023e6:	03448613          	addi	a2,s1,52
    800023ea:	85da                	mv	a1,s6
    800023ec:	05093503          	ld	a0,80(s2)
    800023f0:	fffff097          	auipc	ra,0xfffff
    800023f4:	3d8080e7          	jalr	984(ra) # 800017c8 <copyout>
    800023f8:	02054263          	bltz	a0,8000241c <wait+0x84>
          freeproc(np);
    800023fc:	8526                	mv	a0,s1
    800023fe:	00000097          	auipc	ra,0x0
    80002402:	8ba080e7          	jalr	-1862(ra) # 80001cb8 <freeproc>
          release(&np->lock);
    80002406:	8526                	mv	a0,s1
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	9ba080e7          	jalr	-1606(ra) # 80000dc2 <release>
          release(&p->lock);
    80002410:	854a                	mv	a0,s2
    80002412:	fffff097          	auipc	ra,0xfffff
    80002416:	9b0080e7          	jalr	-1616(ra) # 80000dc2 <release>
          return pid;
    8000241a:	a8a9                	j	80002474 <wait+0xdc>
            release(&np->lock);
    8000241c:	8526                	mv	a0,s1
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	9a4080e7          	jalr	-1628(ra) # 80000dc2 <release>
            release(&p->lock);
    80002426:	854a                	mv	a0,s2
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	99a080e7          	jalr	-1638(ra) # 80000dc2 <release>
            return -1;
    80002430:	59fd                	li	s3,-1
    80002432:	a089                	j	80002474 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002434:	16848493          	addi	s1,s1,360
    80002438:	03348463          	beq	s1,s3,80002460 <wait+0xc8>
      if(np->parent == p){
    8000243c:	709c                	ld	a5,32(s1)
    8000243e:	ff279be3          	bne	a5,s2,80002434 <wait+0x9c>
        acquire(&np->lock);
    80002442:	8526                	mv	a0,s1
    80002444:	fffff097          	auipc	ra,0xfffff
    80002448:	8ca080e7          	jalr	-1846(ra) # 80000d0e <acquire>
        if(np->state == ZOMBIE){
    8000244c:	4c9c                	lw	a5,24(s1)
    8000244e:	f94787e3          	beq	a5,s4,800023dc <wait+0x44>
        release(&np->lock);
    80002452:	8526                	mv	a0,s1
    80002454:	fffff097          	auipc	ra,0xfffff
    80002458:	96e080e7          	jalr	-1682(ra) # 80000dc2 <release>
        havekids = 1;
    8000245c:	8756                	mv	a4,s5
    8000245e:	bfd9                	j	80002434 <wait+0x9c>
    if(!havekids || p->killed){
    80002460:	c701                	beqz	a4,80002468 <wait+0xd0>
    80002462:	03092783          	lw	a5,48(s2)
    80002466:	c39d                	beqz	a5,8000248c <wait+0xf4>
      release(&p->lock);
    80002468:	854a                	mv	a0,s2
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	958080e7          	jalr	-1704(ra) # 80000dc2 <release>
      return -1;
    80002472:	59fd                	li	s3,-1
}
    80002474:	854e                	mv	a0,s3
    80002476:	60a6                	ld	ra,72(sp)
    80002478:	6406                	ld	s0,64(sp)
    8000247a:	74e2                	ld	s1,56(sp)
    8000247c:	7942                	ld	s2,48(sp)
    8000247e:	79a2                	ld	s3,40(sp)
    80002480:	7a02                	ld	s4,32(sp)
    80002482:	6ae2                	ld	s5,24(sp)
    80002484:	6b42                	ld	s6,16(sp)
    80002486:	6ba2                	ld	s7,8(sp)
    80002488:	6161                	addi	sp,sp,80
    8000248a:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000248c:	85ca                	mv	a1,s2
    8000248e:	854a                	mv	a0,s2
    80002490:	00000097          	auipc	ra,0x0
    80002494:	e8a080e7          	jalr	-374(ra) # 8000231a <sleep>
    havekids = 0;
    80002498:	bf25                	j	800023d0 <wait+0x38>

000000008000249a <wakeup>:
{
    8000249a:	7139                	addi	sp,sp,-64
    8000249c:	fc06                	sd	ra,56(sp)
    8000249e:	f822                	sd	s0,48(sp)
    800024a0:	f426                	sd	s1,40(sp)
    800024a2:	f04a                	sd	s2,32(sp)
    800024a4:	ec4e                	sd	s3,24(sp)
    800024a6:	e852                	sd	s4,16(sp)
    800024a8:	e456                	sd	s5,8(sp)
    800024aa:	0080                	addi	s0,sp,64
    800024ac:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800024ae:	00030497          	auipc	s1,0x30
    800024b2:	8ba48493          	addi	s1,s1,-1862 # 80031d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800024b6:	4985                	li	s3,1
      p->state = RUNNABLE;
    800024b8:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800024ba:	00035917          	auipc	s2,0x35
    800024be:	2ae90913          	addi	s2,s2,686 # 80037768 <tickslock>
    800024c2:	a811                	j	800024d6 <wakeup+0x3c>
    release(&p->lock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	fffff097          	auipc	ra,0xfffff
    800024ca:	8fc080e7          	jalr	-1796(ra) # 80000dc2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800024ce:	16848493          	addi	s1,s1,360
    800024d2:	03248063          	beq	s1,s2,800024f2 <wakeup+0x58>
    acquire(&p->lock);
    800024d6:	8526                	mv	a0,s1
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	836080e7          	jalr	-1994(ra) # 80000d0e <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800024e0:	4c9c                	lw	a5,24(s1)
    800024e2:	ff3791e3          	bne	a5,s3,800024c4 <wakeup+0x2a>
    800024e6:	749c                	ld	a5,40(s1)
    800024e8:	fd479ee3          	bne	a5,s4,800024c4 <wakeup+0x2a>
      p->state = RUNNABLE;
    800024ec:	0154ac23          	sw	s5,24(s1)
    800024f0:	bfd1                	j	800024c4 <wakeup+0x2a>
}
    800024f2:	70e2                	ld	ra,56(sp)
    800024f4:	7442                	ld	s0,48(sp)
    800024f6:	74a2                	ld	s1,40(sp)
    800024f8:	7902                	ld	s2,32(sp)
    800024fa:	69e2                	ld	s3,24(sp)
    800024fc:	6a42                	ld	s4,16(sp)
    800024fe:	6aa2                	ld	s5,8(sp)
    80002500:	6121                	addi	sp,sp,64
    80002502:	8082                	ret

0000000080002504 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002504:	7179                	addi	sp,sp,-48
    80002506:	f406                	sd	ra,40(sp)
    80002508:	f022                	sd	s0,32(sp)
    8000250a:	ec26                	sd	s1,24(sp)
    8000250c:	e84a                	sd	s2,16(sp)
    8000250e:	e44e                	sd	s3,8(sp)
    80002510:	1800                	addi	s0,sp,48
    80002512:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002514:	00030497          	auipc	s1,0x30
    80002518:	85448493          	addi	s1,s1,-1964 # 80031d68 <proc>
    8000251c:	00035997          	auipc	s3,0x35
    80002520:	24c98993          	addi	s3,s3,588 # 80037768 <tickslock>
    acquire(&p->lock);
    80002524:	8526                	mv	a0,s1
    80002526:	ffffe097          	auipc	ra,0xffffe
    8000252a:	7e8080e7          	jalr	2024(ra) # 80000d0e <acquire>
    if(p->pid == pid){
    8000252e:	5c9c                	lw	a5,56(s1)
    80002530:	01278d63          	beq	a5,s2,8000254a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002534:	8526                	mv	a0,s1
    80002536:	fffff097          	auipc	ra,0xfffff
    8000253a:	88c080e7          	jalr	-1908(ra) # 80000dc2 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000253e:	16848493          	addi	s1,s1,360
    80002542:	ff3491e3          	bne	s1,s3,80002524 <kill+0x20>
  }
  return -1;
    80002546:	557d                	li	a0,-1
    80002548:	a821                	j	80002560 <kill+0x5c>
      p->killed = 1;
    8000254a:	4785                	li	a5,1
    8000254c:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    8000254e:	4c98                	lw	a4,24(s1)
    80002550:	00f70f63          	beq	a4,a5,8000256e <kill+0x6a>
      release(&p->lock);
    80002554:	8526                	mv	a0,s1
    80002556:	fffff097          	auipc	ra,0xfffff
    8000255a:	86c080e7          	jalr	-1940(ra) # 80000dc2 <release>
      return 0;
    8000255e:	4501                	li	a0,0
}
    80002560:	70a2                	ld	ra,40(sp)
    80002562:	7402                	ld	s0,32(sp)
    80002564:	64e2                	ld	s1,24(sp)
    80002566:	6942                	ld	s2,16(sp)
    80002568:	69a2                	ld	s3,8(sp)
    8000256a:	6145                	addi	sp,sp,48
    8000256c:	8082                	ret
        p->state = RUNNABLE;
    8000256e:	4789                	li	a5,2
    80002570:	cc9c                	sw	a5,24(s1)
    80002572:	b7cd                	j	80002554 <kill+0x50>

0000000080002574 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002574:	7179                	addi	sp,sp,-48
    80002576:	f406                	sd	ra,40(sp)
    80002578:	f022                	sd	s0,32(sp)
    8000257a:	ec26                	sd	s1,24(sp)
    8000257c:	e84a                	sd	s2,16(sp)
    8000257e:	e44e                	sd	s3,8(sp)
    80002580:	e052                	sd	s4,0(sp)
    80002582:	1800                	addi	s0,sp,48
    80002584:	84aa                	mv	s1,a0
    80002586:	892e                	mv	s2,a1
    80002588:	89b2                	mv	s3,a2
    8000258a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000258c:	fffff097          	auipc	ra,0xfffff
    80002590:	57a080e7          	jalr	1402(ra) # 80001b06 <myproc>
  if(user_dst){
    80002594:	c08d                	beqz	s1,800025b6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002596:	86d2                	mv	a3,s4
    80002598:	864e                	mv	a2,s3
    8000259a:	85ca                	mv	a1,s2
    8000259c:	6928                	ld	a0,80(a0)
    8000259e:	fffff097          	auipc	ra,0xfffff
    800025a2:	22a080e7          	jalr	554(ra) # 800017c8 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025a6:	70a2                	ld	ra,40(sp)
    800025a8:	7402                	ld	s0,32(sp)
    800025aa:	64e2                	ld	s1,24(sp)
    800025ac:	6942                	ld	s2,16(sp)
    800025ae:	69a2                	ld	s3,8(sp)
    800025b0:	6a02                	ld	s4,0(sp)
    800025b2:	6145                	addi	sp,sp,48
    800025b4:	8082                	ret
    memmove((char *)dst, src, len);
    800025b6:	000a061b          	sext.w	a2,s4
    800025ba:	85ce                	mv	a1,s3
    800025bc:	854a                	mv	a0,s2
    800025be:	fffff097          	auipc	ra,0xfffff
    800025c2:	8a8080e7          	jalr	-1880(ra) # 80000e66 <memmove>
    return 0;
    800025c6:	8526                	mv	a0,s1
    800025c8:	bff9                	j	800025a6 <either_copyout+0x32>

00000000800025ca <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025ca:	7179                	addi	sp,sp,-48
    800025cc:	f406                	sd	ra,40(sp)
    800025ce:	f022                	sd	s0,32(sp)
    800025d0:	ec26                	sd	s1,24(sp)
    800025d2:	e84a                	sd	s2,16(sp)
    800025d4:	e44e                	sd	s3,8(sp)
    800025d6:	e052                	sd	s4,0(sp)
    800025d8:	1800                	addi	s0,sp,48
    800025da:	892a                	mv	s2,a0
    800025dc:	84ae                	mv	s1,a1
    800025de:	89b2                	mv	s3,a2
    800025e0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025e2:	fffff097          	auipc	ra,0xfffff
    800025e6:	524080e7          	jalr	1316(ra) # 80001b06 <myproc>
  if(user_src){
    800025ea:	c08d                	beqz	s1,8000260c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025ec:	86d2                	mv	a3,s4
    800025ee:	864e                	mv	a2,s3
    800025f0:	85ca                	mv	a1,s2
    800025f2:	6928                	ld	a0,80(a0)
    800025f4:	fffff097          	auipc	ra,0xfffff
    800025f8:	290080e7          	jalr	656(ra) # 80001884 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025fc:	70a2                	ld	ra,40(sp)
    800025fe:	7402                	ld	s0,32(sp)
    80002600:	64e2                	ld	s1,24(sp)
    80002602:	6942                	ld	s2,16(sp)
    80002604:	69a2                	ld	s3,8(sp)
    80002606:	6a02                	ld	s4,0(sp)
    80002608:	6145                	addi	sp,sp,48
    8000260a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000260c:	000a061b          	sext.w	a2,s4
    80002610:	85ce                	mv	a1,s3
    80002612:	854a                	mv	a0,s2
    80002614:	fffff097          	auipc	ra,0xfffff
    80002618:	852080e7          	jalr	-1966(ra) # 80000e66 <memmove>
    return 0;
    8000261c:	8526                	mv	a0,s1
    8000261e:	bff9                	j	800025fc <either_copyin+0x32>

0000000080002620 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002620:	715d                	addi	sp,sp,-80
    80002622:	e486                	sd	ra,72(sp)
    80002624:	e0a2                	sd	s0,64(sp)
    80002626:	fc26                	sd	s1,56(sp)
    80002628:	f84a                	sd	s2,48(sp)
    8000262a:	f44e                	sd	s3,40(sp)
    8000262c:	f052                	sd	s4,32(sp)
    8000262e:	ec56                	sd	s5,24(sp)
    80002630:	e85a                	sd	s6,16(sp)
    80002632:	e45e                	sd	s7,8(sp)
    80002634:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002636:	00006517          	auipc	a0,0x6
    8000263a:	a9250513          	addi	a0,a0,-1390 # 800080c8 <digits+0x88>
    8000263e:	ffffe097          	auipc	ra,0xffffe
    80002642:	f4e080e7          	jalr	-178(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002646:	00030497          	auipc	s1,0x30
    8000264a:	87a48493          	addi	s1,s1,-1926 # 80031ec0 <proc+0x158>
    8000264e:	00035917          	auipc	s2,0x35
    80002652:	27290913          	addi	s2,s2,626 # 800378c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002656:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002658:	00006997          	auipc	s3,0x6
    8000265c:	c1098993          	addi	s3,s3,-1008 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    80002660:	00006a97          	auipc	s5,0x6
    80002664:	c10a8a93          	addi	s5,s5,-1008 # 80008270 <digits+0x230>
    printf("\n");
    80002668:	00006a17          	auipc	s4,0x6
    8000266c:	a60a0a13          	addi	s4,s4,-1440 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002670:	00006b97          	auipc	s7,0x6
    80002674:	c38b8b93          	addi	s7,s7,-968 # 800082a8 <states.0>
    80002678:	a00d                	j	8000269a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000267a:	ee06a583          	lw	a1,-288(a3)
    8000267e:	8556                	mv	a0,s5
    80002680:	ffffe097          	auipc	ra,0xffffe
    80002684:	f0c080e7          	jalr	-244(ra) # 8000058c <printf>
    printf("\n");
    80002688:	8552                	mv	a0,s4
    8000268a:	ffffe097          	auipc	ra,0xffffe
    8000268e:	f02080e7          	jalr	-254(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002692:	16848493          	addi	s1,s1,360
    80002696:	03248163          	beq	s1,s2,800026b8 <procdump+0x98>
    if(p->state == UNUSED)
    8000269a:	86a6                	mv	a3,s1
    8000269c:	ec04a783          	lw	a5,-320(s1)
    800026a0:	dbed                	beqz	a5,80002692 <procdump+0x72>
      state = "???";
    800026a2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026a4:	fcfb6be3          	bltu	s6,a5,8000267a <procdump+0x5a>
    800026a8:	1782                	slli	a5,a5,0x20
    800026aa:	9381                	srli	a5,a5,0x20
    800026ac:	078e                	slli	a5,a5,0x3
    800026ae:	97de                	add	a5,a5,s7
    800026b0:	6390                	ld	a2,0(a5)
    800026b2:	f661                	bnez	a2,8000267a <procdump+0x5a>
      state = "???";
    800026b4:	864e                	mv	a2,s3
    800026b6:	b7d1                	j	8000267a <procdump+0x5a>
  }
}
    800026b8:	60a6                	ld	ra,72(sp)
    800026ba:	6406                	ld	s0,64(sp)
    800026bc:	74e2                	ld	s1,56(sp)
    800026be:	7942                	ld	s2,48(sp)
    800026c0:	79a2                	ld	s3,40(sp)
    800026c2:	7a02                	ld	s4,32(sp)
    800026c4:	6ae2                	ld	s5,24(sp)
    800026c6:	6b42                	ld	s6,16(sp)
    800026c8:	6ba2                	ld	s7,8(sp)
    800026ca:	6161                	addi	sp,sp,80
    800026cc:	8082                	ret

00000000800026ce <swtch>:
    800026ce:	00153023          	sd	ra,0(a0)
    800026d2:	00253423          	sd	sp,8(a0)
    800026d6:	e900                	sd	s0,16(a0)
    800026d8:	ed04                	sd	s1,24(a0)
    800026da:	03253023          	sd	s2,32(a0)
    800026de:	03353423          	sd	s3,40(a0)
    800026e2:	03453823          	sd	s4,48(a0)
    800026e6:	03553c23          	sd	s5,56(a0)
    800026ea:	05653023          	sd	s6,64(a0)
    800026ee:	05753423          	sd	s7,72(a0)
    800026f2:	05853823          	sd	s8,80(a0)
    800026f6:	05953c23          	sd	s9,88(a0)
    800026fa:	07a53023          	sd	s10,96(a0)
    800026fe:	07b53423          	sd	s11,104(a0)
    80002702:	0005b083          	ld	ra,0(a1)
    80002706:	0085b103          	ld	sp,8(a1)
    8000270a:	6980                	ld	s0,16(a1)
    8000270c:	6d84                	ld	s1,24(a1)
    8000270e:	0205b903          	ld	s2,32(a1)
    80002712:	0285b983          	ld	s3,40(a1)
    80002716:	0305ba03          	ld	s4,48(a1)
    8000271a:	0385ba83          	ld	s5,56(a1)
    8000271e:	0405bb03          	ld	s6,64(a1)
    80002722:	0485bb83          	ld	s7,72(a1)
    80002726:	0505bc03          	ld	s8,80(a1)
    8000272a:	0585bc83          	ld	s9,88(a1)
    8000272e:	0605bd03          	ld	s10,96(a1)
    80002732:	0685bd83          	ld	s11,104(a1)
    80002736:	8082                	ret

0000000080002738 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002738:	1141                	addi	sp,sp,-16
    8000273a:	e406                	sd	ra,8(sp)
    8000273c:	e022                	sd	s0,0(sp)
    8000273e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002740:	00006597          	auipc	a1,0x6
    80002744:	b9058593          	addi	a1,a1,-1136 # 800082d0 <states.0+0x28>
    80002748:	00035517          	auipc	a0,0x35
    8000274c:	02050513          	addi	a0,a0,32 # 80037768 <tickslock>
    80002750:	ffffe097          	auipc	ra,0xffffe
    80002754:	52e080e7          	jalr	1326(ra) # 80000c7e <initlock>
}
    80002758:	60a2                	ld	ra,8(sp)
    8000275a:	6402                	ld	s0,0(sp)
    8000275c:	0141                	addi	sp,sp,16
    8000275e:	8082                	ret

0000000080002760 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002760:	1141                	addi	sp,sp,-16
    80002762:	e422                	sd	s0,8(sp)
    80002764:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002766:	00003797          	auipc	a5,0x3
    8000276a:	4ea78793          	addi	a5,a5,1258 # 80005c50 <kernelvec>
    8000276e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002772:	6422                	ld	s0,8(sp)
    80002774:	0141                	addi	sp,sp,16
    80002776:	8082                	ret

0000000080002778 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002778:	1141                	addi	sp,sp,-16
    8000277a:	e406                	sd	ra,8(sp)
    8000277c:	e022                	sd	s0,0(sp)
    8000277e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002780:	fffff097          	auipc	ra,0xfffff
    80002784:	386080e7          	jalr	902(ra) # 80001b06 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002788:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000278c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000278e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002792:	00005617          	auipc	a2,0x5
    80002796:	86e60613          	addi	a2,a2,-1938 # 80007000 <_trampoline>
    8000279a:	00005697          	auipc	a3,0x5
    8000279e:	86668693          	addi	a3,a3,-1946 # 80007000 <_trampoline>
    800027a2:	8e91                	sub	a3,a3,a2
    800027a4:	040007b7          	lui	a5,0x4000
    800027a8:	17fd                	addi	a5,a5,-1
    800027aa:	07b2                	slli	a5,a5,0xc
    800027ac:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027ae:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027b2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027b4:	180026f3          	csrr	a3,satp
    800027b8:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027ba:	6d38                	ld	a4,88(a0)
    800027bc:	6134                	ld	a3,64(a0)
    800027be:	6585                	lui	a1,0x1
    800027c0:	96ae                	add	a3,a3,a1
    800027c2:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027c4:	6d38                	ld	a4,88(a0)
    800027c6:	00000697          	auipc	a3,0x0
    800027ca:	13868693          	addi	a3,a3,312 # 800028fe <usertrap>
    800027ce:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027d0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027d2:	8692                	mv	a3,tp
    800027d4:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027d6:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027da:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027de:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027e2:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027e6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027e8:	6f18                	ld	a4,24(a4)
    800027ea:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027ee:	692c                	ld	a1,80(a0)
    800027f0:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800027f2:	00005717          	auipc	a4,0x5
    800027f6:	89e70713          	addi	a4,a4,-1890 # 80007090 <userret>
    800027fa:	8f11                	sub	a4,a4,a2
    800027fc:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800027fe:	577d                	li	a4,-1
    80002800:	177e                	slli	a4,a4,0x3f
    80002802:	8dd9                	or	a1,a1,a4
    80002804:	02000537          	lui	a0,0x2000
    80002808:	157d                	addi	a0,a0,-1
    8000280a:	0536                	slli	a0,a0,0xd
    8000280c:	9782                	jalr	a5
}
    8000280e:	60a2                	ld	ra,8(sp)
    80002810:	6402                	ld	s0,0(sp)
    80002812:	0141                	addi	sp,sp,16
    80002814:	8082                	ret

0000000080002816 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002816:	1101                	addi	sp,sp,-32
    80002818:	ec06                	sd	ra,24(sp)
    8000281a:	e822                	sd	s0,16(sp)
    8000281c:	e426                	sd	s1,8(sp)
    8000281e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002820:	00035497          	auipc	s1,0x35
    80002824:	f4848493          	addi	s1,s1,-184 # 80037768 <tickslock>
    80002828:	8526                	mv	a0,s1
    8000282a:	ffffe097          	auipc	ra,0xffffe
    8000282e:	4e4080e7          	jalr	1252(ra) # 80000d0e <acquire>
  ticks++;
    80002832:	00006517          	auipc	a0,0x6
    80002836:	7ee50513          	addi	a0,a0,2030 # 80009020 <ticks>
    8000283a:	411c                	lw	a5,0(a0)
    8000283c:	2785                	addiw	a5,a5,1
    8000283e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002840:	00000097          	auipc	ra,0x0
    80002844:	c5a080e7          	jalr	-934(ra) # 8000249a <wakeup>
  release(&tickslock);
    80002848:	8526                	mv	a0,s1
    8000284a:	ffffe097          	auipc	ra,0xffffe
    8000284e:	578080e7          	jalr	1400(ra) # 80000dc2 <release>
}
    80002852:	60e2                	ld	ra,24(sp)
    80002854:	6442                	ld	s0,16(sp)
    80002856:	64a2                	ld	s1,8(sp)
    80002858:	6105                	addi	sp,sp,32
    8000285a:	8082                	ret

000000008000285c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000285c:	1101                	addi	sp,sp,-32
    8000285e:	ec06                	sd	ra,24(sp)
    80002860:	e822                	sd	s0,16(sp)
    80002862:	e426                	sd	s1,8(sp)
    80002864:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002866:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000286a:	00074d63          	bltz	a4,80002884 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000286e:	57fd                	li	a5,-1
    80002870:	17fe                	slli	a5,a5,0x3f
    80002872:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002874:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002876:	06f70363          	beq	a4,a5,800028dc <devintr+0x80>
  }
}
    8000287a:	60e2                	ld	ra,24(sp)
    8000287c:	6442                	ld	s0,16(sp)
    8000287e:	64a2                	ld	s1,8(sp)
    80002880:	6105                	addi	sp,sp,32
    80002882:	8082                	ret
     (scause & 0xff) == 9){
    80002884:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002888:	46a5                	li	a3,9
    8000288a:	fed792e3          	bne	a5,a3,8000286e <devintr+0x12>
    int irq = plic_claim();
    8000288e:	00003097          	auipc	ra,0x3
    80002892:	4ca080e7          	jalr	1226(ra) # 80005d58 <plic_claim>
    80002896:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002898:	47a9                	li	a5,10
    8000289a:	02f50763          	beq	a0,a5,800028c8 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000289e:	4785                	li	a5,1
    800028a0:	02f50963          	beq	a0,a5,800028d2 <devintr+0x76>
    return 1;
    800028a4:	4505                	li	a0,1
    } else if(irq){
    800028a6:	d8f1                	beqz	s1,8000287a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800028a8:	85a6                	mv	a1,s1
    800028aa:	00006517          	auipc	a0,0x6
    800028ae:	a2e50513          	addi	a0,a0,-1490 # 800082d8 <states.0+0x30>
    800028b2:	ffffe097          	auipc	ra,0xffffe
    800028b6:	cda080e7          	jalr	-806(ra) # 8000058c <printf>
      plic_complete(irq);
    800028ba:	8526                	mv	a0,s1
    800028bc:	00003097          	auipc	ra,0x3
    800028c0:	4c0080e7          	jalr	1216(ra) # 80005d7c <plic_complete>
    return 1;
    800028c4:	4505                	li	a0,1
    800028c6:	bf55                	j	8000287a <devintr+0x1e>
      uartintr();
    800028c8:	ffffe097          	auipc	ra,0xffffe
    800028cc:	0fa080e7          	jalr	250(ra) # 800009c2 <uartintr>
    800028d0:	b7ed                	j	800028ba <devintr+0x5e>
      virtio_disk_intr();
    800028d2:	00004097          	auipc	ra,0x4
    800028d6:	924080e7          	jalr	-1756(ra) # 800061f6 <virtio_disk_intr>
    800028da:	b7c5                	j	800028ba <devintr+0x5e>
    if(cpuid() == 0){
    800028dc:	fffff097          	auipc	ra,0xfffff
    800028e0:	1fe080e7          	jalr	510(ra) # 80001ada <cpuid>
    800028e4:	c901                	beqz	a0,800028f4 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800028e6:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028ea:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028ec:	14479073          	csrw	sip,a5
    return 2;
    800028f0:	4509                	li	a0,2
    800028f2:	b761                	j	8000287a <devintr+0x1e>
      clockintr();
    800028f4:	00000097          	auipc	ra,0x0
    800028f8:	f22080e7          	jalr	-222(ra) # 80002816 <clockintr>
    800028fc:	b7ed                	j	800028e6 <devintr+0x8a>

00000000800028fe <usertrap>:
{
    800028fe:	1101                	addi	sp,sp,-32
    80002900:	ec06                	sd	ra,24(sp)
    80002902:	e822                	sd	s0,16(sp)
    80002904:	e426                	sd	s1,8(sp)
    80002906:	e04a                	sd	s2,0(sp)
    80002908:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000290a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000290e:	1007f793          	andi	a5,a5,256
    80002912:	e3ad                	bnez	a5,80002974 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002914:	00003797          	auipc	a5,0x3
    80002918:	33c78793          	addi	a5,a5,828 # 80005c50 <kernelvec>
    8000291c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002920:	fffff097          	auipc	ra,0xfffff
    80002924:	1e6080e7          	jalr	486(ra) # 80001b06 <myproc>
    80002928:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000292a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000292c:	14102773          	csrr	a4,sepc
    80002930:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002932:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002936:	47a1                	li	a5,8
    80002938:	04f71c63          	bne	a4,a5,80002990 <usertrap+0x92>
    if(p->killed)
    8000293c:	591c                	lw	a5,48(a0)
    8000293e:	e3b9                	bnez	a5,80002984 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002940:	6cb8                	ld	a4,88(s1)
    80002942:	6f1c                	ld	a5,24(a4)
    80002944:	0791                	addi	a5,a5,4
    80002946:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002948:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000294c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002950:	10079073          	csrw	sstatus,a5
    syscall();
    80002954:	00000097          	auipc	ra,0x0
    80002958:	30c080e7          	jalr	780(ra) # 80002c60 <syscall>
  if(p->killed)
    8000295c:	589c                	lw	a5,48(s1)
    8000295e:	efd5                	bnez	a5,80002a1a <usertrap+0x11c>
  usertrapret();
    80002960:	00000097          	auipc	ra,0x0
    80002964:	e18080e7          	jalr	-488(ra) # 80002778 <usertrapret>
}
    80002968:	60e2                	ld	ra,24(sp)
    8000296a:	6442                	ld	s0,16(sp)
    8000296c:	64a2                	ld	s1,8(sp)
    8000296e:	6902                	ld	s2,0(sp)
    80002970:	6105                	addi	sp,sp,32
    80002972:	8082                	ret
    panic("usertrap: not from user mode");
    80002974:	00006517          	auipc	a0,0x6
    80002978:	98450513          	addi	a0,a0,-1660 # 800082f8 <states.0+0x50>
    8000297c:	ffffe097          	auipc	ra,0xffffe
    80002980:	bc6080e7          	jalr	-1082(ra) # 80000542 <panic>
      exit(-1);
    80002984:	557d                	li	a0,-1
    80002986:	00000097          	auipc	ra,0x0
    8000298a:	84e080e7          	jalr	-1970(ra) # 800021d4 <exit>
    8000298e:	bf4d                	j	80002940 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002990:	00000097          	auipc	ra,0x0
    80002994:	ecc080e7          	jalr	-308(ra) # 8000285c <devintr>
    80002998:	892a                	mv	s2,a0
    8000299a:	ed2d                	bnez	a0,80002a14 <usertrap+0x116>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000299c:	14202773          	csrr	a4,scause
  } else if(r_scause() == 15) {
    800029a0:	47bd                	li	a5,15
    800029a2:	02f71363          	bne	a4,a5,800029c8 <usertrap+0xca>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029a6:	143025f3          	csrr	a1,stval
    if(va >= p->sz)
    800029aa:	64bc                	ld	a5,72(s1)
    800029ac:	00f5e563          	bltu	a1,a5,800029b6 <usertrap+0xb8>
      p->killed = 1;
    800029b0:	4785                	li	a5,1
    800029b2:	d89c                	sw	a5,48(s1)
    800029b4:	a099                	j	800029fa <usertrap+0xfc>
    else if(cow_alloc(p->pagetable, va) != 0)
    800029b6:	68a8                	ld	a0,80(s1)
    800029b8:	ffffe097          	auipc	ra,0xffffe
    800029bc:	20e080e7          	jalr	526(ra) # 80000bc6 <cow_alloc>
    800029c0:	dd51                	beqz	a0,8000295c <usertrap+0x5e>
      p->killed = 1;
    800029c2:	4785                	li	a5,1
    800029c4:	d89c                	sw	a5,48(s1)
    800029c6:	a815                	j	800029fa <usertrap+0xfc>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029c8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029cc:	5c90                	lw	a2,56(s1)
    800029ce:	00006517          	auipc	a0,0x6
    800029d2:	94a50513          	addi	a0,a0,-1718 # 80008318 <states.0+0x70>
    800029d6:	ffffe097          	auipc	ra,0xffffe
    800029da:	bb6080e7          	jalr	-1098(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029de:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029e2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029e6:	00006517          	auipc	a0,0x6
    800029ea:	96250513          	addi	a0,a0,-1694 # 80008348 <states.0+0xa0>
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	b9e080e7          	jalr	-1122(ra) # 8000058c <printf>
    p->killed = 1;
    800029f6:	4785                	li	a5,1
    800029f8:	d89c                	sw	a5,48(s1)
    exit(-1);
    800029fa:	557d                	li	a0,-1
    800029fc:	fffff097          	auipc	ra,0xfffff
    80002a00:	7d8080e7          	jalr	2008(ra) # 800021d4 <exit>
  if(which_dev == 2)
    80002a04:	4789                	li	a5,2
    80002a06:	f4f91de3          	bne	s2,a5,80002960 <usertrap+0x62>
    yield();
    80002a0a:	00000097          	auipc	ra,0x0
    80002a0e:	8d4080e7          	jalr	-1836(ra) # 800022de <yield>
    80002a12:	b7b9                	j	80002960 <usertrap+0x62>
  if(p->killed)
    80002a14:	589c                	lw	a5,48(s1)
    80002a16:	d7fd                	beqz	a5,80002a04 <usertrap+0x106>
    80002a18:	b7cd                	j	800029fa <usertrap+0xfc>
    80002a1a:	4901                	li	s2,0
    80002a1c:	bff9                	j	800029fa <usertrap+0xfc>

0000000080002a1e <kerneltrap>:
{
    80002a1e:	7179                	addi	sp,sp,-48
    80002a20:	f406                	sd	ra,40(sp)
    80002a22:	f022                	sd	s0,32(sp)
    80002a24:	ec26                	sd	s1,24(sp)
    80002a26:	e84a                	sd	s2,16(sp)
    80002a28:	e44e                	sd	s3,8(sp)
    80002a2a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a2c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a30:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a34:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a38:	1004f793          	andi	a5,s1,256
    80002a3c:	cb85                	beqz	a5,80002a6c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a3e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a42:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a44:	ef85                	bnez	a5,80002a7c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a46:	00000097          	auipc	ra,0x0
    80002a4a:	e16080e7          	jalr	-490(ra) # 8000285c <devintr>
    80002a4e:	cd1d                	beqz	a0,80002a8c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a50:	4789                	li	a5,2
    80002a52:	06f50a63          	beq	a0,a5,80002ac6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a56:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a5a:	10049073          	csrw	sstatus,s1
}
    80002a5e:	70a2                	ld	ra,40(sp)
    80002a60:	7402                	ld	s0,32(sp)
    80002a62:	64e2                	ld	s1,24(sp)
    80002a64:	6942                	ld	s2,16(sp)
    80002a66:	69a2                	ld	s3,8(sp)
    80002a68:	6145                	addi	sp,sp,48
    80002a6a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a6c:	00006517          	auipc	a0,0x6
    80002a70:	8fc50513          	addi	a0,a0,-1796 # 80008368 <states.0+0xc0>
    80002a74:	ffffe097          	auipc	ra,0xffffe
    80002a78:	ace080e7          	jalr	-1330(ra) # 80000542 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a7c:	00006517          	auipc	a0,0x6
    80002a80:	91450513          	addi	a0,a0,-1772 # 80008390 <states.0+0xe8>
    80002a84:	ffffe097          	auipc	ra,0xffffe
    80002a88:	abe080e7          	jalr	-1346(ra) # 80000542 <panic>
    printf("scause %p\n", scause);
    80002a8c:	85ce                	mv	a1,s3
    80002a8e:	00006517          	auipc	a0,0x6
    80002a92:	92250513          	addi	a0,a0,-1758 # 800083b0 <states.0+0x108>
    80002a96:	ffffe097          	auipc	ra,0xffffe
    80002a9a:	af6080e7          	jalr	-1290(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a9e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002aa2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002aa6:	00006517          	auipc	a0,0x6
    80002aaa:	91a50513          	addi	a0,a0,-1766 # 800083c0 <states.0+0x118>
    80002aae:	ffffe097          	auipc	ra,0xffffe
    80002ab2:	ade080e7          	jalr	-1314(ra) # 8000058c <printf>
    panic("kerneltrap");
    80002ab6:	00006517          	auipc	a0,0x6
    80002aba:	92250513          	addi	a0,a0,-1758 # 800083d8 <states.0+0x130>
    80002abe:	ffffe097          	auipc	ra,0xffffe
    80002ac2:	a84080e7          	jalr	-1404(ra) # 80000542 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ac6:	fffff097          	auipc	ra,0xfffff
    80002aca:	040080e7          	jalr	64(ra) # 80001b06 <myproc>
    80002ace:	d541                	beqz	a0,80002a56 <kerneltrap+0x38>
    80002ad0:	fffff097          	auipc	ra,0xfffff
    80002ad4:	036080e7          	jalr	54(ra) # 80001b06 <myproc>
    80002ad8:	4d18                	lw	a4,24(a0)
    80002ada:	478d                	li	a5,3
    80002adc:	f6f71de3          	bne	a4,a5,80002a56 <kerneltrap+0x38>
    yield();
    80002ae0:	fffff097          	auipc	ra,0xfffff
    80002ae4:	7fe080e7          	jalr	2046(ra) # 800022de <yield>
    80002ae8:	b7bd                	j	80002a56 <kerneltrap+0x38>

0000000080002aea <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002aea:	1101                	addi	sp,sp,-32
    80002aec:	ec06                	sd	ra,24(sp)
    80002aee:	e822                	sd	s0,16(sp)
    80002af0:	e426                	sd	s1,8(sp)
    80002af2:	1000                	addi	s0,sp,32
    80002af4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	010080e7          	jalr	16(ra) # 80001b06 <myproc>
  switch (n) {
    80002afe:	4795                	li	a5,5
    80002b00:	0497e163          	bltu	a5,s1,80002b42 <argraw+0x58>
    80002b04:	048a                	slli	s1,s1,0x2
    80002b06:	00006717          	auipc	a4,0x6
    80002b0a:	90a70713          	addi	a4,a4,-1782 # 80008410 <states.0+0x168>
    80002b0e:	94ba                	add	s1,s1,a4
    80002b10:	409c                	lw	a5,0(s1)
    80002b12:	97ba                	add	a5,a5,a4
    80002b14:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b16:	6d3c                	ld	a5,88(a0)
    80002b18:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b1a:	60e2                	ld	ra,24(sp)
    80002b1c:	6442                	ld	s0,16(sp)
    80002b1e:	64a2                	ld	s1,8(sp)
    80002b20:	6105                	addi	sp,sp,32
    80002b22:	8082                	ret
    return p->trapframe->a1;
    80002b24:	6d3c                	ld	a5,88(a0)
    80002b26:	7fa8                	ld	a0,120(a5)
    80002b28:	bfcd                	j	80002b1a <argraw+0x30>
    return p->trapframe->a2;
    80002b2a:	6d3c                	ld	a5,88(a0)
    80002b2c:	63c8                	ld	a0,128(a5)
    80002b2e:	b7f5                	j	80002b1a <argraw+0x30>
    return p->trapframe->a3;
    80002b30:	6d3c                	ld	a5,88(a0)
    80002b32:	67c8                	ld	a0,136(a5)
    80002b34:	b7dd                	j	80002b1a <argraw+0x30>
    return p->trapframe->a4;
    80002b36:	6d3c                	ld	a5,88(a0)
    80002b38:	6bc8                	ld	a0,144(a5)
    80002b3a:	b7c5                	j	80002b1a <argraw+0x30>
    return p->trapframe->a5;
    80002b3c:	6d3c                	ld	a5,88(a0)
    80002b3e:	6fc8                	ld	a0,152(a5)
    80002b40:	bfe9                	j	80002b1a <argraw+0x30>
  panic("argraw");
    80002b42:	00006517          	auipc	a0,0x6
    80002b46:	8a650513          	addi	a0,a0,-1882 # 800083e8 <states.0+0x140>
    80002b4a:	ffffe097          	auipc	ra,0xffffe
    80002b4e:	9f8080e7          	jalr	-1544(ra) # 80000542 <panic>

0000000080002b52 <fetchaddr>:
{
    80002b52:	1101                	addi	sp,sp,-32
    80002b54:	ec06                	sd	ra,24(sp)
    80002b56:	e822                	sd	s0,16(sp)
    80002b58:	e426                	sd	s1,8(sp)
    80002b5a:	e04a                	sd	s2,0(sp)
    80002b5c:	1000                	addi	s0,sp,32
    80002b5e:	84aa                	mv	s1,a0
    80002b60:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b62:	fffff097          	auipc	ra,0xfffff
    80002b66:	fa4080e7          	jalr	-92(ra) # 80001b06 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002b6a:	653c                	ld	a5,72(a0)
    80002b6c:	02f4f863          	bgeu	s1,a5,80002b9c <fetchaddr+0x4a>
    80002b70:	00848713          	addi	a4,s1,8
    80002b74:	02e7e663          	bltu	a5,a4,80002ba0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b78:	46a1                	li	a3,8
    80002b7a:	8626                	mv	a2,s1
    80002b7c:	85ca                	mv	a1,s2
    80002b7e:	6928                	ld	a0,80(a0)
    80002b80:	fffff097          	auipc	ra,0xfffff
    80002b84:	d04080e7          	jalr	-764(ra) # 80001884 <copyin>
    80002b88:	00a03533          	snez	a0,a0
    80002b8c:	40a00533          	neg	a0,a0
}
    80002b90:	60e2                	ld	ra,24(sp)
    80002b92:	6442                	ld	s0,16(sp)
    80002b94:	64a2                	ld	s1,8(sp)
    80002b96:	6902                	ld	s2,0(sp)
    80002b98:	6105                	addi	sp,sp,32
    80002b9a:	8082                	ret
    return -1;
    80002b9c:	557d                	li	a0,-1
    80002b9e:	bfcd                	j	80002b90 <fetchaddr+0x3e>
    80002ba0:	557d                	li	a0,-1
    80002ba2:	b7fd                	j	80002b90 <fetchaddr+0x3e>

0000000080002ba4 <fetchstr>:
{
    80002ba4:	7179                	addi	sp,sp,-48
    80002ba6:	f406                	sd	ra,40(sp)
    80002ba8:	f022                	sd	s0,32(sp)
    80002baa:	ec26                	sd	s1,24(sp)
    80002bac:	e84a                	sd	s2,16(sp)
    80002bae:	e44e                	sd	s3,8(sp)
    80002bb0:	1800                	addi	s0,sp,48
    80002bb2:	892a                	mv	s2,a0
    80002bb4:	84ae                	mv	s1,a1
    80002bb6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bb8:	fffff097          	auipc	ra,0xfffff
    80002bbc:	f4e080e7          	jalr	-178(ra) # 80001b06 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002bc0:	86ce                	mv	a3,s3
    80002bc2:	864a                	mv	a2,s2
    80002bc4:	85a6                	mv	a1,s1
    80002bc6:	6928                	ld	a0,80(a0)
    80002bc8:	fffff097          	auipc	ra,0xfffff
    80002bcc:	d4a080e7          	jalr	-694(ra) # 80001912 <copyinstr>
  if(err < 0)
    80002bd0:	00054763          	bltz	a0,80002bde <fetchstr+0x3a>
  return strlen(buf);
    80002bd4:	8526                	mv	a0,s1
    80002bd6:	ffffe097          	auipc	ra,0xffffe
    80002bda:	3b8080e7          	jalr	952(ra) # 80000f8e <strlen>
}
    80002bde:	70a2                	ld	ra,40(sp)
    80002be0:	7402                	ld	s0,32(sp)
    80002be2:	64e2                	ld	s1,24(sp)
    80002be4:	6942                	ld	s2,16(sp)
    80002be6:	69a2                	ld	s3,8(sp)
    80002be8:	6145                	addi	sp,sp,48
    80002bea:	8082                	ret

0000000080002bec <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002bec:	1101                	addi	sp,sp,-32
    80002bee:	ec06                	sd	ra,24(sp)
    80002bf0:	e822                	sd	s0,16(sp)
    80002bf2:	e426                	sd	s1,8(sp)
    80002bf4:	1000                	addi	s0,sp,32
    80002bf6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bf8:	00000097          	auipc	ra,0x0
    80002bfc:	ef2080e7          	jalr	-270(ra) # 80002aea <argraw>
    80002c00:	c088                	sw	a0,0(s1)
  return 0;
}
    80002c02:	4501                	li	a0,0
    80002c04:	60e2                	ld	ra,24(sp)
    80002c06:	6442                	ld	s0,16(sp)
    80002c08:	64a2                	ld	s1,8(sp)
    80002c0a:	6105                	addi	sp,sp,32
    80002c0c:	8082                	ret

0000000080002c0e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002c0e:	1101                	addi	sp,sp,-32
    80002c10:	ec06                	sd	ra,24(sp)
    80002c12:	e822                	sd	s0,16(sp)
    80002c14:	e426                	sd	s1,8(sp)
    80002c16:	1000                	addi	s0,sp,32
    80002c18:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c1a:	00000097          	auipc	ra,0x0
    80002c1e:	ed0080e7          	jalr	-304(ra) # 80002aea <argraw>
    80002c22:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c24:	4501                	li	a0,0
    80002c26:	60e2                	ld	ra,24(sp)
    80002c28:	6442                	ld	s0,16(sp)
    80002c2a:	64a2                	ld	s1,8(sp)
    80002c2c:	6105                	addi	sp,sp,32
    80002c2e:	8082                	ret

0000000080002c30 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c30:	1101                	addi	sp,sp,-32
    80002c32:	ec06                	sd	ra,24(sp)
    80002c34:	e822                	sd	s0,16(sp)
    80002c36:	e426                	sd	s1,8(sp)
    80002c38:	e04a                	sd	s2,0(sp)
    80002c3a:	1000                	addi	s0,sp,32
    80002c3c:	84ae                	mv	s1,a1
    80002c3e:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c40:	00000097          	auipc	ra,0x0
    80002c44:	eaa080e7          	jalr	-342(ra) # 80002aea <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c48:	864a                	mv	a2,s2
    80002c4a:	85a6                	mv	a1,s1
    80002c4c:	00000097          	auipc	ra,0x0
    80002c50:	f58080e7          	jalr	-168(ra) # 80002ba4 <fetchstr>
}
    80002c54:	60e2                	ld	ra,24(sp)
    80002c56:	6442                	ld	s0,16(sp)
    80002c58:	64a2                	ld	s1,8(sp)
    80002c5a:	6902                	ld	s2,0(sp)
    80002c5c:	6105                	addi	sp,sp,32
    80002c5e:	8082                	ret

0000000080002c60 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002c60:	1101                	addi	sp,sp,-32
    80002c62:	ec06                	sd	ra,24(sp)
    80002c64:	e822                	sd	s0,16(sp)
    80002c66:	e426                	sd	s1,8(sp)
    80002c68:	e04a                	sd	s2,0(sp)
    80002c6a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c6c:	fffff097          	auipc	ra,0xfffff
    80002c70:	e9a080e7          	jalr	-358(ra) # 80001b06 <myproc>
    80002c74:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c76:	05853903          	ld	s2,88(a0)
    80002c7a:	0a893783          	ld	a5,168(s2)
    80002c7e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c82:	37fd                	addiw	a5,a5,-1
    80002c84:	4751                	li	a4,20
    80002c86:	00f76f63          	bltu	a4,a5,80002ca4 <syscall+0x44>
    80002c8a:	00369713          	slli	a4,a3,0x3
    80002c8e:	00005797          	auipc	a5,0x5
    80002c92:	79a78793          	addi	a5,a5,1946 # 80008428 <syscalls>
    80002c96:	97ba                	add	a5,a5,a4
    80002c98:	639c                	ld	a5,0(a5)
    80002c9a:	c789                	beqz	a5,80002ca4 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002c9c:	9782                	jalr	a5
    80002c9e:	06a93823          	sd	a0,112(s2)
    80002ca2:	a839                	j	80002cc0 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ca4:	15848613          	addi	a2,s1,344
    80002ca8:	5c8c                	lw	a1,56(s1)
    80002caa:	00005517          	auipc	a0,0x5
    80002cae:	74650513          	addi	a0,a0,1862 # 800083f0 <states.0+0x148>
    80002cb2:	ffffe097          	auipc	ra,0xffffe
    80002cb6:	8da080e7          	jalr	-1830(ra) # 8000058c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002cba:	6cbc                	ld	a5,88(s1)
    80002cbc:	577d                	li	a4,-1
    80002cbe:	fbb8                	sd	a4,112(a5)
  }
}
    80002cc0:	60e2                	ld	ra,24(sp)
    80002cc2:	6442                	ld	s0,16(sp)
    80002cc4:	64a2                	ld	s1,8(sp)
    80002cc6:	6902                	ld	s2,0(sp)
    80002cc8:	6105                	addi	sp,sp,32
    80002cca:	8082                	ret

0000000080002ccc <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ccc:	1101                	addi	sp,sp,-32
    80002cce:	ec06                	sd	ra,24(sp)
    80002cd0:	e822                	sd	s0,16(sp)
    80002cd2:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002cd4:	fec40593          	addi	a1,s0,-20
    80002cd8:	4501                	li	a0,0
    80002cda:	00000097          	auipc	ra,0x0
    80002cde:	f12080e7          	jalr	-238(ra) # 80002bec <argint>
    return -1;
    80002ce2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ce4:	00054963          	bltz	a0,80002cf6 <sys_exit+0x2a>
  exit(n);
    80002ce8:	fec42503          	lw	a0,-20(s0)
    80002cec:	fffff097          	auipc	ra,0xfffff
    80002cf0:	4e8080e7          	jalr	1256(ra) # 800021d4 <exit>
  return 0;  // not reached
    80002cf4:	4781                	li	a5,0
}
    80002cf6:	853e                	mv	a0,a5
    80002cf8:	60e2                	ld	ra,24(sp)
    80002cfa:	6442                	ld	s0,16(sp)
    80002cfc:	6105                	addi	sp,sp,32
    80002cfe:	8082                	ret

0000000080002d00 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d00:	1141                	addi	sp,sp,-16
    80002d02:	e406                	sd	ra,8(sp)
    80002d04:	e022                	sd	s0,0(sp)
    80002d06:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d08:	fffff097          	auipc	ra,0xfffff
    80002d0c:	dfe080e7          	jalr	-514(ra) # 80001b06 <myproc>
}
    80002d10:	5d08                	lw	a0,56(a0)
    80002d12:	60a2                	ld	ra,8(sp)
    80002d14:	6402                	ld	s0,0(sp)
    80002d16:	0141                	addi	sp,sp,16
    80002d18:	8082                	ret

0000000080002d1a <sys_fork>:

uint64
sys_fork(void)
{
    80002d1a:	1141                	addi	sp,sp,-16
    80002d1c:	e406                	sd	ra,8(sp)
    80002d1e:	e022                	sd	s0,0(sp)
    80002d20:	0800                	addi	s0,sp,16
  return fork();
    80002d22:	fffff097          	auipc	ra,0xfffff
    80002d26:	1a4080e7          	jalr	420(ra) # 80001ec6 <fork>
}
    80002d2a:	60a2                	ld	ra,8(sp)
    80002d2c:	6402                	ld	s0,0(sp)
    80002d2e:	0141                	addi	sp,sp,16
    80002d30:	8082                	ret

0000000080002d32 <sys_wait>:

uint64
sys_wait(void)
{
    80002d32:	1101                	addi	sp,sp,-32
    80002d34:	ec06                	sd	ra,24(sp)
    80002d36:	e822                	sd	s0,16(sp)
    80002d38:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d3a:	fe840593          	addi	a1,s0,-24
    80002d3e:	4501                	li	a0,0
    80002d40:	00000097          	auipc	ra,0x0
    80002d44:	ece080e7          	jalr	-306(ra) # 80002c0e <argaddr>
    80002d48:	87aa                	mv	a5,a0
    return -1;
    80002d4a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002d4c:	0007c863          	bltz	a5,80002d5c <sys_wait+0x2a>
  return wait(p);
    80002d50:	fe843503          	ld	a0,-24(s0)
    80002d54:	fffff097          	auipc	ra,0xfffff
    80002d58:	644080e7          	jalr	1604(ra) # 80002398 <wait>
}
    80002d5c:	60e2                	ld	ra,24(sp)
    80002d5e:	6442                	ld	s0,16(sp)
    80002d60:	6105                	addi	sp,sp,32
    80002d62:	8082                	ret

0000000080002d64 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d64:	7179                	addi	sp,sp,-48
    80002d66:	f406                	sd	ra,40(sp)
    80002d68:	f022                	sd	s0,32(sp)
    80002d6a:	ec26                	sd	s1,24(sp)
    80002d6c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002d6e:	fdc40593          	addi	a1,s0,-36
    80002d72:	4501                	li	a0,0
    80002d74:	00000097          	auipc	ra,0x0
    80002d78:	e78080e7          	jalr	-392(ra) # 80002bec <argint>
    return -1;
    80002d7c:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002d7e:	00054f63          	bltz	a0,80002d9c <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002d82:	fffff097          	auipc	ra,0xfffff
    80002d86:	d84080e7          	jalr	-636(ra) # 80001b06 <myproc>
    80002d8a:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002d8c:	fdc42503          	lw	a0,-36(s0)
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	0c2080e7          	jalr	194(ra) # 80001e52 <growproc>
    80002d98:	00054863          	bltz	a0,80002da8 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002d9c:	8526                	mv	a0,s1
    80002d9e:	70a2                	ld	ra,40(sp)
    80002da0:	7402                	ld	s0,32(sp)
    80002da2:	64e2                	ld	s1,24(sp)
    80002da4:	6145                	addi	sp,sp,48
    80002da6:	8082                	ret
    return -1;
    80002da8:	54fd                	li	s1,-1
    80002daa:	bfcd                	j	80002d9c <sys_sbrk+0x38>

0000000080002dac <sys_sleep>:

uint64
sys_sleep(void)
{
    80002dac:	7139                	addi	sp,sp,-64
    80002dae:	fc06                	sd	ra,56(sp)
    80002db0:	f822                	sd	s0,48(sp)
    80002db2:	f426                	sd	s1,40(sp)
    80002db4:	f04a                	sd	s2,32(sp)
    80002db6:	ec4e                	sd	s3,24(sp)
    80002db8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002dba:	fcc40593          	addi	a1,s0,-52
    80002dbe:	4501                	li	a0,0
    80002dc0:	00000097          	auipc	ra,0x0
    80002dc4:	e2c080e7          	jalr	-468(ra) # 80002bec <argint>
    return -1;
    80002dc8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002dca:	06054563          	bltz	a0,80002e34 <sys_sleep+0x88>
  acquire(&tickslock);
    80002dce:	00035517          	auipc	a0,0x35
    80002dd2:	99a50513          	addi	a0,a0,-1638 # 80037768 <tickslock>
    80002dd6:	ffffe097          	auipc	ra,0xffffe
    80002dda:	f38080e7          	jalr	-200(ra) # 80000d0e <acquire>
  ticks0 = ticks;
    80002dde:	00006917          	auipc	s2,0x6
    80002de2:	24292903          	lw	s2,578(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002de6:	fcc42783          	lw	a5,-52(s0)
    80002dea:	cf85                	beqz	a5,80002e22 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dec:	00035997          	auipc	s3,0x35
    80002df0:	97c98993          	addi	s3,s3,-1668 # 80037768 <tickslock>
    80002df4:	00006497          	auipc	s1,0x6
    80002df8:	22c48493          	addi	s1,s1,556 # 80009020 <ticks>
    if(myproc()->killed){
    80002dfc:	fffff097          	auipc	ra,0xfffff
    80002e00:	d0a080e7          	jalr	-758(ra) # 80001b06 <myproc>
    80002e04:	591c                	lw	a5,48(a0)
    80002e06:	ef9d                	bnez	a5,80002e44 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002e08:	85ce                	mv	a1,s3
    80002e0a:	8526                	mv	a0,s1
    80002e0c:	fffff097          	auipc	ra,0xfffff
    80002e10:	50e080e7          	jalr	1294(ra) # 8000231a <sleep>
  while(ticks - ticks0 < n){
    80002e14:	409c                	lw	a5,0(s1)
    80002e16:	412787bb          	subw	a5,a5,s2
    80002e1a:	fcc42703          	lw	a4,-52(s0)
    80002e1e:	fce7efe3          	bltu	a5,a4,80002dfc <sys_sleep+0x50>
  }
  release(&tickslock);
    80002e22:	00035517          	auipc	a0,0x35
    80002e26:	94650513          	addi	a0,a0,-1722 # 80037768 <tickslock>
    80002e2a:	ffffe097          	auipc	ra,0xffffe
    80002e2e:	f98080e7          	jalr	-104(ra) # 80000dc2 <release>
  return 0;
    80002e32:	4781                	li	a5,0
}
    80002e34:	853e                	mv	a0,a5
    80002e36:	70e2                	ld	ra,56(sp)
    80002e38:	7442                	ld	s0,48(sp)
    80002e3a:	74a2                	ld	s1,40(sp)
    80002e3c:	7902                	ld	s2,32(sp)
    80002e3e:	69e2                	ld	s3,24(sp)
    80002e40:	6121                	addi	sp,sp,64
    80002e42:	8082                	ret
      release(&tickslock);
    80002e44:	00035517          	auipc	a0,0x35
    80002e48:	92450513          	addi	a0,a0,-1756 # 80037768 <tickslock>
    80002e4c:	ffffe097          	auipc	ra,0xffffe
    80002e50:	f76080e7          	jalr	-138(ra) # 80000dc2 <release>
      return -1;
    80002e54:	57fd                	li	a5,-1
    80002e56:	bff9                	j	80002e34 <sys_sleep+0x88>

0000000080002e58 <sys_kill>:

uint64
sys_kill(void)
{
    80002e58:	1101                	addi	sp,sp,-32
    80002e5a:	ec06                	sd	ra,24(sp)
    80002e5c:	e822                	sd	s0,16(sp)
    80002e5e:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002e60:	fec40593          	addi	a1,s0,-20
    80002e64:	4501                	li	a0,0
    80002e66:	00000097          	auipc	ra,0x0
    80002e6a:	d86080e7          	jalr	-634(ra) # 80002bec <argint>
    80002e6e:	87aa                	mv	a5,a0
    return -1;
    80002e70:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002e72:	0007c863          	bltz	a5,80002e82 <sys_kill+0x2a>
  return kill(pid);
    80002e76:	fec42503          	lw	a0,-20(s0)
    80002e7a:	fffff097          	auipc	ra,0xfffff
    80002e7e:	68a080e7          	jalr	1674(ra) # 80002504 <kill>
}
    80002e82:	60e2                	ld	ra,24(sp)
    80002e84:	6442                	ld	s0,16(sp)
    80002e86:	6105                	addi	sp,sp,32
    80002e88:	8082                	ret

0000000080002e8a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e8a:	1101                	addi	sp,sp,-32
    80002e8c:	ec06                	sd	ra,24(sp)
    80002e8e:	e822                	sd	s0,16(sp)
    80002e90:	e426                	sd	s1,8(sp)
    80002e92:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e94:	00035517          	auipc	a0,0x35
    80002e98:	8d450513          	addi	a0,a0,-1836 # 80037768 <tickslock>
    80002e9c:	ffffe097          	auipc	ra,0xffffe
    80002ea0:	e72080e7          	jalr	-398(ra) # 80000d0e <acquire>
  xticks = ticks;
    80002ea4:	00006497          	auipc	s1,0x6
    80002ea8:	17c4a483          	lw	s1,380(s1) # 80009020 <ticks>
  release(&tickslock);
    80002eac:	00035517          	auipc	a0,0x35
    80002eb0:	8bc50513          	addi	a0,a0,-1860 # 80037768 <tickslock>
    80002eb4:	ffffe097          	auipc	ra,0xffffe
    80002eb8:	f0e080e7          	jalr	-242(ra) # 80000dc2 <release>
  return xticks;
}
    80002ebc:	02049513          	slli	a0,s1,0x20
    80002ec0:	9101                	srli	a0,a0,0x20
    80002ec2:	60e2                	ld	ra,24(sp)
    80002ec4:	6442                	ld	s0,16(sp)
    80002ec6:	64a2                	ld	s1,8(sp)
    80002ec8:	6105                	addi	sp,sp,32
    80002eca:	8082                	ret

0000000080002ecc <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ecc:	7179                	addi	sp,sp,-48
    80002ece:	f406                	sd	ra,40(sp)
    80002ed0:	f022                	sd	s0,32(sp)
    80002ed2:	ec26                	sd	s1,24(sp)
    80002ed4:	e84a                	sd	s2,16(sp)
    80002ed6:	e44e                	sd	s3,8(sp)
    80002ed8:	e052                	sd	s4,0(sp)
    80002eda:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002edc:	00005597          	auipc	a1,0x5
    80002ee0:	5fc58593          	addi	a1,a1,1532 # 800084d8 <syscalls+0xb0>
    80002ee4:	00035517          	auipc	a0,0x35
    80002ee8:	89c50513          	addi	a0,a0,-1892 # 80037780 <bcache>
    80002eec:	ffffe097          	auipc	ra,0xffffe
    80002ef0:	d92080e7          	jalr	-622(ra) # 80000c7e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ef4:	0003d797          	auipc	a5,0x3d
    80002ef8:	88c78793          	addi	a5,a5,-1908 # 8003f780 <bcache+0x8000>
    80002efc:	0003d717          	auipc	a4,0x3d
    80002f00:	aec70713          	addi	a4,a4,-1300 # 8003f9e8 <bcache+0x8268>
    80002f04:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f08:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f0c:	00035497          	auipc	s1,0x35
    80002f10:	88c48493          	addi	s1,s1,-1908 # 80037798 <bcache+0x18>
    b->next = bcache.head.next;
    80002f14:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f16:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f18:	00005a17          	auipc	s4,0x5
    80002f1c:	5c8a0a13          	addi	s4,s4,1480 # 800084e0 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002f20:	2b893783          	ld	a5,696(s2)
    80002f24:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f26:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f2a:	85d2                	mv	a1,s4
    80002f2c:	01048513          	addi	a0,s1,16
    80002f30:	00001097          	auipc	ra,0x1
    80002f34:	4b0080e7          	jalr	1200(ra) # 800043e0 <initsleeplock>
    bcache.head.next->prev = b;
    80002f38:	2b893783          	ld	a5,696(s2)
    80002f3c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f3e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f42:	45848493          	addi	s1,s1,1112
    80002f46:	fd349de3          	bne	s1,s3,80002f20 <binit+0x54>
  }
}
    80002f4a:	70a2                	ld	ra,40(sp)
    80002f4c:	7402                	ld	s0,32(sp)
    80002f4e:	64e2                	ld	s1,24(sp)
    80002f50:	6942                	ld	s2,16(sp)
    80002f52:	69a2                	ld	s3,8(sp)
    80002f54:	6a02                	ld	s4,0(sp)
    80002f56:	6145                	addi	sp,sp,48
    80002f58:	8082                	ret

0000000080002f5a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f5a:	7179                	addi	sp,sp,-48
    80002f5c:	f406                	sd	ra,40(sp)
    80002f5e:	f022                	sd	s0,32(sp)
    80002f60:	ec26                	sd	s1,24(sp)
    80002f62:	e84a                	sd	s2,16(sp)
    80002f64:	e44e                	sd	s3,8(sp)
    80002f66:	1800                	addi	s0,sp,48
    80002f68:	892a                	mv	s2,a0
    80002f6a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f6c:	00035517          	auipc	a0,0x35
    80002f70:	81450513          	addi	a0,a0,-2028 # 80037780 <bcache>
    80002f74:	ffffe097          	auipc	ra,0xffffe
    80002f78:	d9a080e7          	jalr	-614(ra) # 80000d0e <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f7c:	0003d497          	auipc	s1,0x3d
    80002f80:	abc4b483          	ld	s1,-1348(s1) # 8003fa38 <bcache+0x82b8>
    80002f84:	0003d797          	auipc	a5,0x3d
    80002f88:	a6478793          	addi	a5,a5,-1436 # 8003f9e8 <bcache+0x8268>
    80002f8c:	02f48f63          	beq	s1,a5,80002fca <bread+0x70>
    80002f90:	873e                	mv	a4,a5
    80002f92:	a021                	j	80002f9a <bread+0x40>
    80002f94:	68a4                	ld	s1,80(s1)
    80002f96:	02e48a63          	beq	s1,a4,80002fca <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f9a:	449c                	lw	a5,8(s1)
    80002f9c:	ff279ce3          	bne	a5,s2,80002f94 <bread+0x3a>
    80002fa0:	44dc                	lw	a5,12(s1)
    80002fa2:	ff3799e3          	bne	a5,s3,80002f94 <bread+0x3a>
      b->refcnt++;
    80002fa6:	40bc                	lw	a5,64(s1)
    80002fa8:	2785                	addiw	a5,a5,1
    80002faa:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fac:	00034517          	auipc	a0,0x34
    80002fb0:	7d450513          	addi	a0,a0,2004 # 80037780 <bcache>
    80002fb4:	ffffe097          	auipc	ra,0xffffe
    80002fb8:	e0e080e7          	jalr	-498(ra) # 80000dc2 <release>
      acquiresleep(&b->lock);
    80002fbc:	01048513          	addi	a0,s1,16
    80002fc0:	00001097          	auipc	ra,0x1
    80002fc4:	45a080e7          	jalr	1114(ra) # 8000441a <acquiresleep>
      return b;
    80002fc8:	a8b9                	j	80003026 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fca:	0003d497          	auipc	s1,0x3d
    80002fce:	a664b483          	ld	s1,-1434(s1) # 8003fa30 <bcache+0x82b0>
    80002fd2:	0003d797          	auipc	a5,0x3d
    80002fd6:	a1678793          	addi	a5,a5,-1514 # 8003f9e8 <bcache+0x8268>
    80002fda:	00f48863          	beq	s1,a5,80002fea <bread+0x90>
    80002fde:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fe0:	40bc                	lw	a5,64(s1)
    80002fe2:	cf81                	beqz	a5,80002ffa <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fe4:	64a4                	ld	s1,72(s1)
    80002fe6:	fee49de3          	bne	s1,a4,80002fe0 <bread+0x86>
  panic("bget: no buffers");
    80002fea:	00005517          	auipc	a0,0x5
    80002fee:	4fe50513          	addi	a0,a0,1278 # 800084e8 <syscalls+0xc0>
    80002ff2:	ffffd097          	auipc	ra,0xffffd
    80002ff6:	550080e7          	jalr	1360(ra) # 80000542 <panic>
      b->dev = dev;
    80002ffa:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ffe:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003002:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003006:	4785                	li	a5,1
    80003008:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000300a:	00034517          	auipc	a0,0x34
    8000300e:	77650513          	addi	a0,a0,1910 # 80037780 <bcache>
    80003012:	ffffe097          	auipc	ra,0xffffe
    80003016:	db0080e7          	jalr	-592(ra) # 80000dc2 <release>
      acquiresleep(&b->lock);
    8000301a:	01048513          	addi	a0,s1,16
    8000301e:	00001097          	auipc	ra,0x1
    80003022:	3fc080e7          	jalr	1020(ra) # 8000441a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003026:	409c                	lw	a5,0(s1)
    80003028:	cb89                	beqz	a5,8000303a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000302a:	8526                	mv	a0,s1
    8000302c:	70a2                	ld	ra,40(sp)
    8000302e:	7402                	ld	s0,32(sp)
    80003030:	64e2                	ld	s1,24(sp)
    80003032:	6942                	ld	s2,16(sp)
    80003034:	69a2                	ld	s3,8(sp)
    80003036:	6145                	addi	sp,sp,48
    80003038:	8082                	ret
    virtio_disk_rw(b, 0);
    8000303a:	4581                	li	a1,0
    8000303c:	8526                	mv	a0,s1
    8000303e:	00003097          	auipc	ra,0x3
    80003042:	f2e080e7          	jalr	-210(ra) # 80005f6c <virtio_disk_rw>
    b->valid = 1;
    80003046:	4785                	li	a5,1
    80003048:	c09c                	sw	a5,0(s1)
  return b;
    8000304a:	b7c5                	j	8000302a <bread+0xd0>

000000008000304c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000304c:	1101                	addi	sp,sp,-32
    8000304e:	ec06                	sd	ra,24(sp)
    80003050:	e822                	sd	s0,16(sp)
    80003052:	e426                	sd	s1,8(sp)
    80003054:	1000                	addi	s0,sp,32
    80003056:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003058:	0541                	addi	a0,a0,16
    8000305a:	00001097          	auipc	ra,0x1
    8000305e:	45a080e7          	jalr	1114(ra) # 800044b4 <holdingsleep>
    80003062:	cd01                	beqz	a0,8000307a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003064:	4585                	li	a1,1
    80003066:	8526                	mv	a0,s1
    80003068:	00003097          	auipc	ra,0x3
    8000306c:	f04080e7          	jalr	-252(ra) # 80005f6c <virtio_disk_rw>
}
    80003070:	60e2                	ld	ra,24(sp)
    80003072:	6442                	ld	s0,16(sp)
    80003074:	64a2                	ld	s1,8(sp)
    80003076:	6105                	addi	sp,sp,32
    80003078:	8082                	ret
    panic("bwrite");
    8000307a:	00005517          	auipc	a0,0x5
    8000307e:	48650513          	addi	a0,a0,1158 # 80008500 <syscalls+0xd8>
    80003082:	ffffd097          	auipc	ra,0xffffd
    80003086:	4c0080e7          	jalr	1216(ra) # 80000542 <panic>

000000008000308a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000308a:	1101                	addi	sp,sp,-32
    8000308c:	ec06                	sd	ra,24(sp)
    8000308e:	e822                	sd	s0,16(sp)
    80003090:	e426                	sd	s1,8(sp)
    80003092:	e04a                	sd	s2,0(sp)
    80003094:	1000                	addi	s0,sp,32
    80003096:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003098:	01050913          	addi	s2,a0,16
    8000309c:	854a                	mv	a0,s2
    8000309e:	00001097          	auipc	ra,0x1
    800030a2:	416080e7          	jalr	1046(ra) # 800044b4 <holdingsleep>
    800030a6:	c92d                	beqz	a0,80003118 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800030a8:	854a                	mv	a0,s2
    800030aa:	00001097          	auipc	ra,0x1
    800030ae:	3c6080e7          	jalr	966(ra) # 80004470 <releasesleep>

  acquire(&bcache.lock);
    800030b2:	00034517          	auipc	a0,0x34
    800030b6:	6ce50513          	addi	a0,a0,1742 # 80037780 <bcache>
    800030ba:	ffffe097          	auipc	ra,0xffffe
    800030be:	c54080e7          	jalr	-940(ra) # 80000d0e <acquire>
  b->refcnt--;
    800030c2:	40bc                	lw	a5,64(s1)
    800030c4:	37fd                	addiw	a5,a5,-1
    800030c6:	0007871b          	sext.w	a4,a5
    800030ca:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030cc:	eb05                	bnez	a4,800030fc <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030ce:	68bc                	ld	a5,80(s1)
    800030d0:	64b8                	ld	a4,72(s1)
    800030d2:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800030d4:	64bc                	ld	a5,72(s1)
    800030d6:	68b8                	ld	a4,80(s1)
    800030d8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030da:	0003c797          	auipc	a5,0x3c
    800030de:	6a678793          	addi	a5,a5,1702 # 8003f780 <bcache+0x8000>
    800030e2:	2b87b703          	ld	a4,696(a5)
    800030e6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030e8:	0003d717          	auipc	a4,0x3d
    800030ec:	90070713          	addi	a4,a4,-1792 # 8003f9e8 <bcache+0x8268>
    800030f0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030f2:	2b87b703          	ld	a4,696(a5)
    800030f6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030f8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030fc:	00034517          	auipc	a0,0x34
    80003100:	68450513          	addi	a0,a0,1668 # 80037780 <bcache>
    80003104:	ffffe097          	auipc	ra,0xffffe
    80003108:	cbe080e7          	jalr	-834(ra) # 80000dc2 <release>
}
    8000310c:	60e2                	ld	ra,24(sp)
    8000310e:	6442                	ld	s0,16(sp)
    80003110:	64a2                	ld	s1,8(sp)
    80003112:	6902                	ld	s2,0(sp)
    80003114:	6105                	addi	sp,sp,32
    80003116:	8082                	ret
    panic("brelse");
    80003118:	00005517          	auipc	a0,0x5
    8000311c:	3f050513          	addi	a0,a0,1008 # 80008508 <syscalls+0xe0>
    80003120:	ffffd097          	auipc	ra,0xffffd
    80003124:	422080e7          	jalr	1058(ra) # 80000542 <panic>

0000000080003128 <bpin>:

void
bpin(struct buf *b) {
    80003128:	1101                	addi	sp,sp,-32
    8000312a:	ec06                	sd	ra,24(sp)
    8000312c:	e822                	sd	s0,16(sp)
    8000312e:	e426                	sd	s1,8(sp)
    80003130:	1000                	addi	s0,sp,32
    80003132:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003134:	00034517          	auipc	a0,0x34
    80003138:	64c50513          	addi	a0,a0,1612 # 80037780 <bcache>
    8000313c:	ffffe097          	auipc	ra,0xffffe
    80003140:	bd2080e7          	jalr	-1070(ra) # 80000d0e <acquire>
  b->refcnt++;
    80003144:	40bc                	lw	a5,64(s1)
    80003146:	2785                	addiw	a5,a5,1
    80003148:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000314a:	00034517          	auipc	a0,0x34
    8000314e:	63650513          	addi	a0,a0,1590 # 80037780 <bcache>
    80003152:	ffffe097          	auipc	ra,0xffffe
    80003156:	c70080e7          	jalr	-912(ra) # 80000dc2 <release>
}
    8000315a:	60e2                	ld	ra,24(sp)
    8000315c:	6442                	ld	s0,16(sp)
    8000315e:	64a2                	ld	s1,8(sp)
    80003160:	6105                	addi	sp,sp,32
    80003162:	8082                	ret

0000000080003164 <bunpin>:

void
bunpin(struct buf *b) {
    80003164:	1101                	addi	sp,sp,-32
    80003166:	ec06                	sd	ra,24(sp)
    80003168:	e822                	sd	s0,16(sp)
    8000316a:	e426                	sd	s1,8(sp)
    8000316c:	1000                	addi	s0,sp,32
    8000316e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003170:	00034517          	auipc	a0,0x34
    80003174:	61050513          	addi	a0,a0,1552 # 80037780 <bcache>
    80003178:	ffffe097          	auipc	ra,0xffffe
    8000317c:	b96080e7          	jalr	-1130(ra) # 80000d0e <acquire>
  b->refcnt--;
    80003180:	40bc                	lw	a5,64(s1)
    80003182:	37fd                	addiw	a5,a5,-1
    80003184:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003186:	00034517          	auipc	a0,0x34
    8000318a:	5fa50513          	addi	a0,a0,1530 # 80037780 <bcache>
    8000318e:	ffffe097          	auipc	ra,0xffffe
    80003192:	c34080e7          	jalr	-972(ra) # 80000dc2 <release>
}
    80003196:	60e2                	ld	ra,24(sp)
    80003198:	6442                	ld	s0,16(sp)
    8000319a:	64a2                	ld	s1,8(sp)
    8000319c:	6105                	addi	sp,sp,32
    8000319e:	8082                	ret

00000000800031a0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031a0:	1101                	addi	sp,sp,-32
    800031a2:	ec06                	sd	ra,24(sp)
    800031a4:	e822                	sd	s0,16(sp)
    800031a6:	e426                	sd	s1,8(sp)
    800031a8:	e04a                	sd	s2,0(sp)
    800031aa:	1000                	addi	s0,sp,32
    800031ac:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031ae:	00d5d59b          	srliw	a1,a1,0xd
    800031b2:	0003d797          	auipc	a5,0x3d
    800031b6:	caa7a783          	lw	a5,-854(a5) # 8003fe5c <sb+0x1c>
    800031ba:	9dbd                	addw	a1,a1,a5
    800031bc:	00000097          	auipc	ra,0x0
    800031c0:	d9e080e7          	jalr	-610(ra) # 80002f5a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031c4:	0074f713          	andi	a4,s1,7
    800031c8:	4785                	li	a5,1
    800031ca:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031ce:	14ce                	slli	s1,s1,0x33
    800031d0:	90d9                	srli	s1,s1,0x36
    800031d2:	00950733          	add	a4,a0,s1
    800031d6:	05874703          	lbu	a4,88(a4)
    800031da:	00e7f6b3          	and	a3,a5,a4
    800031de:	c69d                	beqz	a3,8000320c <bfree+0x6c>
    800031e0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031e2:	94aa                	add	s1,s1,a0
    800031e4:	fff7c793          	not	a5,a5
    800031e8:	8ff9                	and	a5,a5,a4
    800031ea:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800031ee:	00001097          	auipc	ra,0x1
    800031f2:	104080e7          	jalr	260(ra) # 800042f2 <log_write>
  brelse(bp);
    800031f6:	854a                	mv	a0,s2
    800031f8:	00000097          	auipc	ra,0x0
    800031fc:	e92080e7          	jalr	-366(ra) # 8000308a <brelse>
}
    80003200:	60e2                	ld	ra,24(sp)
    80003202:	6442                	ld	s0,16(sp)
    80003204:	64a2                	ld	s1,8(sp)
    80003206:	6902                	ld	s2,0(sp)
    80003208:	6105                	addi	sp,sp,32
    8000320a:	8082                	ret
    panic("freeing free block");
    8000320c:	00005517          	auipc	a0,0x5
    80003210:	30450513          	addi	a0,a0,772 # 80008510 <syscalls+0xe8>
    80003214:	ffffd097          	auipc	ra,0xffffd
    80003218:	32e080e7          	jalr	814(ra) # 80000542 <panic>

000000008000321c <balloc>:
{
    8000321c:	711d                	addi	sp,sp,-96
    8000321e:	ec86                	sd	ra,88(sp)
    80003220:	e8a2                	sd	s0,80(sp)
    80003222:	e4a6                	sd	s1,72(sp)
    80003224:	e0ca                	sd	s2,64(sp)
    80003226:	fc4e                	sd	s3,56(sp)
    80003228:	f852                	sd	s4,48(sp)
    8000322a:	f456                	sd	s5,40(sp)
    8000322c:	f05a                	sd	s6,32(sp)
    8000322e:	ec5e                	sd	s7,24(sp)
    80003230:	e862                	sd	s8,16(sp)
    80003232:	e466                	sd	s9,8(sp)
    80003234:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003236:	0003d797          	auipc	a5,0x3d
    8000323a:	c0e7a783          	lw	a5,-1010(a5) # 8003fe44 <sb+0x4>
    8000323e:	cbd1                	beqz	a5,800032d2 <balloc+0xb6>
    80003240:	8baa                	mv	s7,a0
    80003242:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003244:	0003db17          	auipc	s6,0x3d
    80003248:	bfcb0b13          	addi	s6,s6,-1028 # 8003fe40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000324c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000324e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003250:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003252:	6c89                	lui	s9,0x2
    80003254:	a831                	j	80003270 <balloc+0x54>
    brelse(bp);
    80003256:	854a                	mv	a0,s2
    80003258:	00000097          	auipc	ra,0x0
    8000325c:	e32080e7          	jalr	-462(ra) # 8000308a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003260:	015c87bb          	addw	a5,s9,s5
    80003264:	00078a9b          	sext.w	s5,a5
    80003268:	004b2703          	lw	a4,4(s6)
    8000326c:	06eaf363          	bgeu	s5,a4,800032d2 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003270:	41fad79b          	sraiw	a5,s5,0x1f
    80003274:	0137d79b          	srliw	a5,a5,0x13
    80003278:	015787bb          	addw	a5,a5,s5
    8000327c:	40d7d79b          	sraiw	a5,a5,0xd
    80003280:	01cb2583          	lw	a1,28(s6)
    80003284:	9dbd                	addw	a1,a1,a5
    80003286:	855e                	mv	a0,s7
    80003288:	00000097          	auipc	ra,0x0
    8000328c:	cd2080e7          	jalr	-814(ra) # 80002f5a <bread>
    80003290:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003292:	004b2503          	lw	a0,4(s6)
    80003296:	000a849b          	sext.w	s1,s5
    8000329a:	8662                	mv	a2,s8
    8000329c:	faa4fde3          	bgeu	s1,a0,80003256 <balloc+0x3a>
      m = 1 << (bi % 8);
    800032a0:	41f6579b          	sraiw	a5,a2,0x1f
    800032a4:	01d7d69b          	srliw	a3,a5,0x1d
    800032a8:	00c6873b          	addw	a4,a3,a2
    800032ac:	00777793          	andi	a5,a4,7
    800032b0:	9f95                	subw	a5,a5,a3
    800032b2:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032b6:	4037571b          	sraiw	a4,a4,0x3
    800032ba:	00e906b3          	add	a3,s2,a4
    800032be:	0586c683          	lbu	a3,88(a3)
    800032c2:	00d7f5b3          	and	a1,a5,a3
    800032c6:	cd91                	beqz	a1,800032e2 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c8:	2605                	addiw	a2,a2,1
    800032ca:	2485                	addiw	s1,s1,1
    800032cc:	fd4618e3          	bne	a2,s4,8000329c <balloc+0x80>
    800032d0:	b759                	j	80003256 <balloc+0x3a>
  panic("balloc: out of blocks");
    800032d2:	00005517          	auipc	a0,0x5
    800032d6:	25650513          	addi	a0,a0,598 # 80008528 <syscalls+0x100>
    800032da:	ffffd097          	auipc	ra,0xffffd
    800032de:	268080e7          	jalr	616(ra) # 80000542 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032e2:	974a                	add	a4,a4,s2
    800032e4:	8fd5                	or	a5,a5,a3
    800032e6:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800032ea:	854a                	mv	a0,s2
    800032ec:	00001097          	auipc	ra,0x1
    800032f0:	006080e7          	jalr	6(ra) # 800042f2 <log_write>
        brelse(bp);
    800032f4:	854a                	mv	a0,s2
    800032f6:	00000097          	auipc	ra,0x0
    800032fa:	d94080e7          	jalr	-620(ra) # 8000308a <brelse>
  bp = bread(dev, bno);
    800032fe:	85a6                	mv	a1,s1
    80003300:	855e                	mv	a0,s7
    80003302:	00000097          	auipc	ra,0x0
    80003306:	c58080e7          	jalr	-936(ra) # 80002f5a <bread>
    8000330a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000330c:	40000613          	li	a2,1024
    80003310:	4581                	li	a1,0
    80003312:	05850513          	addi	a0,a0,88
    80003316:	ffffe097          	auipc	ra,0xffffe
    8000331a:	af4080e7          	jalr	-1292(ra) # 80000e0a <memset>
  log_write(bp);
    8000331e:	854a                	mv	a0,s2
    80003320:	00001097          	auipc	ra,0x1
    80003324:	fd2080e7          	jalr	-46(ra) # 800042f2 <log_write>
  brelse(bp);
    80003328:	854a                	mv	a0,s2
    8000332a:	00000097          	auipc	ra,0x0
    8000332e:	d60080e7          	jalr	-672(ra) # 8000308a <brelse>
}
    80003332:	8526                	mv	a0,s1
    80003334:	60e6                	ld	ra,88(sp)
    80003336:	6446                	ld	s0,80(sp)
    80003338:	64a6                	ld	s1,72(sp)
    8000333a:	6906                	ld	s2,64(sp)
    8000333c:	79e2                	ld	s3,56(sp)
    8000333e:	7a42                	ld	s4,48(sp)
    80003340:	7aa2                	ld	s5,40(sp)
    80003342:	7b02                	ld	s6,32(sp)
    80003344:	6be2                	ld	s7,24(sp)
    80003346:	6c42                	ld	s8,16(sp)
    80003348:	6ca2                	ld	s9,8(sp)
    8000334a:	6125                	addi	sp,sp,96
    8000334c:	8082                	ret

000000008000334e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000334e:	7179                	addi	sp,sp,-48
    80003350:	f406                	sd	ra,40(sp)
    80003352:	f022                	sd	s0,32(sp)
    80003354:	ec26                	sd	s1,24(sp)
    80003356:	e84a                	sd	s2,16(sp)
    80003358:	e44e                	sd	s3,8(sp)
    8000335a:	e052                	sd	s4,0(sp)
    8000335c:	1800                	addi	s0,sp,48
    8000335e:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003360:	47ad                	li	a5,11
    80003362:	04b7fe63          	bgeu	a5,a1,800033be <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003366:	ff45849b          	addiw	s1,a1,-12
    8000336a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000336e:	0ff00793          	li	a5,255
    80003372:	0ae7e363          	bltu	a5,a4,80003418 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003376:	08052583          	lw	a1,128(a0)
    8000337a:	c5ad                	beqz	a1,800033e4 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000337c:	00092503          	lw	a0,0(s2)
    80003380:	00000097          	auipc	ra,0x0
    80003384:	bda080e7          	jalr	-1062(ra) # 80002f5a <bread>
    80003388:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000338a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000338e:	02049593          	slli	a1,s1,0x20
    80003392:	9181                	srli	a1,a1,0x20
    80003394:	058a                	slli	a1,a1,0x2
    80003396:	00b784b3          	add	s1,a5,a1
    8000339a:	0004a983          	lw	s3,0(s1)
    8000339e:	04098d63          	beqz	s3,800033f8 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800033a2:	8552                	mv	a0,s4
    800033a4:	00000097          	auipc	ra,0x0
    800033a8:	ce6080e7          	jalr	-794(ra) # 8000308a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800033ac:	854e                	mv	a0,s3
    800033ae:	70a2                	ld	ra,40(sp)
    800033b0:	7402                	ld	s0,32(sp)
    800033b2:	64e2                	ld	s1,24(sp)
    800033b4:	6942                	ld	s2,16(sp)
    800033b6:	69a2                	ld	s3,8(sp)
    800033b8:	6a02                	ld	s4,0(sp)
    800033ba:	6145                	addi	sp,sp,48
    800033bc:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800033be:	02059493          	slli	s1,a1,0x20
    800033c2:	9081                	srli	s1,s1,0x20
    800033c4:	048a                	slli	s1,s1,0x2
    800033c6:	94aa                	add	s1,s1,a0
    800033c8:	0504a983          	lw	s3,80(s1)
    800033cc:	fe0990e3          	bnez	s3,800033ac <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800033d0:	4108                	lw	a0,0(a0)
    800033d2:	00000097          	auipc	ra,0x0
    800033d6:	e4a080e7          	jalr	-438(ra) # 8000321c <balloc>
    800033da:	0005099b          	sext.w	s3,a0
    800033de:	0534a823          	sw	s3,80(s1)
    800033e2:	b7e9                	j	800033ac <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800033e4:	4108                	lw	a0,0(a0)
    800033e6:	00000097          	auipc	ra,0x0
    800033ea:	e36080e7          	jalr	-458(ra) # 8000321c <balloc>
    800033ee:	0005059b          	sext.w	a1,a0
    800033f2:	08b92023          	sw	a1,128(s2)
    800033f6:	b759                	j	8000337c <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800033f8:	00092503          	lw	a0,0(s2)
    800033fc:	00000097          	auipc	ra,0x0
    80003400:	e20080e7          	jalr	-480(ra) # 8000321c <balloc>
    80003404:	0005099b          	sext.w	s3,a0
    80003408:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000340c:	8552                	mv	a0,s4
    8000340e:	00001097          	auipc	ra,0x1
    80003412:	ee4080e7          	jalr	-284(ra) # 800042f2 <log_write>
    80003416:	b771                	j	800033a2 <bmap+0x54>
  panic("bmap: out of range");
    80003418:	00005517          	auipc	a0,0x5
    8000341c:	12850513          	addi	a0,a0,296 # 80008540 <syscalls+0x118>
    80003420:	ffffd097          	auipc	ra,0xffffd
    80003424:	122080e7          	jalr	290(ra) # 80000542 <panic>

0000000080003428 <iget>:
{
    80003428:	7179                	addi	sp,sp,-48
    8000342a:	f406                	sd	ra,40(sp)
    8000342c:	f022                	sd	s0,32(sp)
    8000342e:	ec26                	sd	s1,24(sp)
    80003430:	e84a                	sd	s2,16(sp)
    80003432:	e44e                	sd	s3,8(sp)
    80003434:	e052                	sd	s4,0(sp)
    80003436:	1800                	addi	s0,sp,48
    80003438:	89aa                	mv	s3,a0
    8000343a:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000343c:	0003d517          	auipc	a0,0x3d
    80003440:	a2450513          	addi	a0,a0,-1500 # 8003fe60 <icache>
    80003444:	ffffe097          	auipc	ra,0xffffe
    80003448:	8ca080e7          	jalr	-1846(ra) # 80000d0e <acquire>
  empty = 0;
    8000344c:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000344e:	0003d497          	auipc	s1,0x3d
    80003452:	a2a48493          	addi	s1,s1,-1494 # 8003fe78 <icache+0x18>
    80003456:	0003e697          	auipc	a3,0x3e
    8000345a:	4b268693          	addi	a3,a3,1202 # 80041908 <log>
    8000345e:	a039                	j	8000346c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003460:	02090b63          	beqz	s2,80003496 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003464:	08848493          	addi	s1,s1,136
    80003468:	02d48a63          	beq	s1,a3,8000349c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000346c:	449c                	lw	a5,8(s1)
    8000346e:	fef059e3          	blez	a5,80003460 <iget+0x38>
    80003472:	4098                	lw	a4,0(s1)
    80003474:	ff3716e3          	bne	a4,s3,80003460 <iget+0x38>
    80003478:	40d8                	lw	a4,4(s1)
    8000347a:	ff4713e3          	bne	a4,s4,80003460 <iget+0x38>
      ip->ref++;
    8000347e:	2785                	addiw	a5,a5,1
    80003480:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003482:	0003d517          	auipc	a0,0x3d
    80003486:	9de50513          	addi	a0,a0,-1570 # 8003fe60 <icache>
    8000348a:	ffffe097          	auipc	ra,0xffffe
    8000348e:	938080e7          	jalr	-1736(ra) # 80000dc2 <release>
      return ip;
    80003492:	8926                	mv	s2,s1
    80003494:	a03d                	j	800034c2 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003496:	f7f9                	bnez	a5,80003464 <iget+0x3c>
    80003498:	8926                	mv	s2,s1
    8000349a:	b7e9                	j	80003464 <iget+0x3c>
  if(empty == 0)
    8000349c:	02090c63          	beqz	s2,800034d4 <iget+0xac>
  ip->dev = dev;
    800034a0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034a4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034a8:	4785                	li	a5,1
    800034aa:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034ae:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800034b2:	0003d517          	auipc	a0,0x3d
    800034b6:	9ae50513          	addi	a0,a0,-1618 # 8003fe60 <icache>
    800034ba:	ffffe097          	auipc	ra,0xffffe
    800034be:	908080e7          	jalr	-1784(ra) # 80000dc2 <release>
}
    800034c2:	854a                	mv	a0,s2
    800034c4:	70a2                	ld	ra,40(sp)
    800034c6:	7402                	ld	s0,32(sp)
    800034c8:	64e2                	ld	s1,24(sp)
    800034ca:	6942                	ld	s2,16(sp)
    800034cc:	69a2                	ld	s3,8(sp)
    800034ce:	6a02                	ld	s4,0(sp)
    800034d0:	6145                	addi	sp,sp,48
    800034d2:	8082                	ret
    panic("iget: no inodes");
    800034d4:	00005517          	auipc	a0,0x5
    800034d8:	08450513          	addi	a0,a0,132 # 80008558 <syscalls+0x130>
    800034dc:	ffffd097          	auipc	ra,0xffffd
    800034e0:	066080e7          	jalr	102(ra) # 80000542 <panic>

00000000800034e4 <fsinit>:
fsinit(int dev) {
    800034e4:	7179                	addi	sp,sp,-48
    800034e6:	f406                	sd	ra,40(sp)
    800034e8:	f022                	sd	s0,32(sp)
    800034ea:	ec26                	sd	s1,24(sp)
    800034ec:	e84a                	sd	s2,16(sp)
    800034ee:	e44e                	sd	s3,8(sp)
    800034f0:	1800                	addi	s0,sp,48
    800034f2:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034f4:	4585                	li	a1,1
    800034f6:	00000097          	auipc	ra,0x0
    800034fa:	a64080e7          	jalr	-1436(ra) # 80002f5a <bread>
    800034fe:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003500:	0003d997          	auipc	s3,0x3d
    80003504:	94098993          	addi	s3,s3,-1728 # 8003fe40 <sb>
    80003508:	02000613          	li	a2,32
    8000350c:	05850593          	addi	a1,a0,88
    80003510:	854e                	mv	a0,s3
    80003512:	ffffe097          	auipc	ra,0xffffe
    80003516:	954080e7          	jalr	-1708(ra) # 80000e66 <memmove>
  brelse(bp);
    8000351a:	8526                	mv	a0,s1
    8000351c:	00000097          	auipc	ra,0x0
    80003520:	b6e080e7          	jalr	-1170(ra) # 8000308a <brelse>
  if(sb.magic != FSMAGIC)
    80003524:	0009a703          	lw	a4,0(s3)
    80003528:	102037b7          	lui	a5,0x10203
    8000352c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003530:	02f71263          	bne	a4,a5,80003554 <fsinit+0x70>
  initlog(dev, &sb);
    80003534:	0003d597          	auipc	a1,0x3d
    80003538:	90c58593          	addi	a1,a1,-1780 # 8003fe40 <sb>
    8000353c:	854a                	mv	a0,s2
    8000353e:	00001097          	auipc	ra,0x1
    80003542:	b3c080e7          	jalr	-1220(ra) # 8000407a <initlog>
}
    80003546:	70a2                	ld	ra,40(sp)
    80003548:	7402                	ld	s0,32(sp)
    8000354a:	64e2                	ld	s1,24(sp)
    8000354c:	6942                	ld	s2,16(sp)
    8000354e:	69a2                	ld	s3,8(sp)
    80003550:	6145                	addi	sp,sp,48
    80003552:	8082                	ret
    panic("invalid file system");
    80003554:	00005517          	auipc	a0,0x5
    80003558:	01450513          	addi	a0,a0,20 # 80008568 <syscalls+0x140>
    8000355c:	ffffd097          	auipc	ra,0xffffd
    80003560:	fe6080e7          	jalr	-26(ra) # 80000542 <panic>

0000000080003564 <iinit>:
{
    80003564:	7179                	addi	sp,sp,-48
    80003566:	f406                	sd	ra,40(sp)
    80003568:	f022                	sd	s0,32(sp)
    8000356a:	ec26                	sd	s1,24(sp)
    8000356c:	e84a                	sd	s2,16(sp)
    8000356e:	e44e                	sd	s3,8(sp)
    80003570:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003572:	00005597          	auipc	a1,0x5
    80003576:	00e58593          	addi	a1,a1,14 # 80008580 <syscalls+0x158>
    8000357a:	0003d517          	auipc	a0,0x3d
    8000357e:	8e650513          	addi	a0,a0,-1818 # 8003fe60 <icache>
    80003582:	ffffd097          	auipc	ra,0xffffd
    80003586:	6fc080e7          	jalr	1788(ra) # 80000c7e <initlock>
  for(i = 0; i < NINODE; i++) {
    8000358a:	0003d497          	auipc	s1,0x3d
    8000358e:	8fe48493          	addi	s1,s1,-1794 # 8003fe88 <icache+0x28>
    80003592:	0003e997          	auipc	s3,0x3e
    80003596:	38698993          	addi	s3,s3,902 # 80041918 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000359a:	00005917          	auipc	s2,0x5
    8000359e:	fee90913          	addi	s2,s2,-18 # 80008588 <syscalls+0x160>
    800035a2:	85ca                	mv	a1,s2
    800035a4:	8526                	mv	a0,s1
    800035a6:	00001097          	auipc	ra,0x1
    800035aa:	e3a080e7          	jalr	-454(ra) # 800043e0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035ae:	08848493          	addi	s1,s1,136
    800035b2:	ff3498e3          	bne	s1,s3,800035a2 <iinit+0x3e>
}
    800035b6:	70a2                	ld	ra,40(sp)
    800035b8:	7402                	ld	s0,32(sp)
    800035ba:	64e2                	ld	s1,24(sp)
    800035bc:	6942                	ld	s2,16(sp)
    800035be:	69a2                	ld	s3,8(sp)
    800035c0:	6145                	addi	sp,sp,48
    800035c2:	8082                	ret

00000000800035c4 <ialloc>:
{
    800035c4:	715d                	addi	sp,sp,-80
    800035c6:	e486                	sd	ra,72(sp)
    800035c8:	e0a2                	sd	s0,64(sp)
    800035ca:	fc26                	sd	s1,56(sp)
    800035cc:	f84a                	sd	s2,48(sp)
    800035ce:	f44e                	sd	s3,40(sp)
    800035d0:	f052                	sd	s4,32(sp)
    800035d2:	ec56                	sd	s5,24(sp)
    800035d4:	e85a                	sd	s6,16(sp)
    800035d6:	e45e                	sd	s7,8(sp)
    800035d8:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800035da:	0003d717          	auipc	a4,0x3d
    800035de:	87272703          	lw	a4,-1934(a4) # 8003fe4c <sb+0xc>
    800035e2:	4785                	li	a5,1
    800035e4:	04e7fa63          	bgeu	a5,a4,80003638 <ialloc+0x74>
    800035e8:	8aaa                	mv	s5,a0
    800035ea:	8bae                	mv	s7,a1
    800035ec:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800035ee:	0003da17          	auipc	s4,0x3d
    800035f2:	852a0a13          	addi	s4,s4,-1966 # 8003fe40 <sb>
    800035f6:	00048b1b          	sext.w	s6,s1
    800035fa:	0044d793          	srli	a5,s1,0x4
    800035fe:	018a2583          	lw	a1,24(s4)
    80003602:	9dbd                	addw	a1,a1,a5
    80003604:	8556                	mv	a0,s5
    80003606:	00000097          	auipc	ra,0x0
    8000360a:	954080e7          	jalr	-1708(ra) # 80002f5a <bread>
    8000360e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003610:	05850993          	addi	s3,a0,88
    80003614:	00f4f793          	andi	a5,s1,15
    80003618:	079a                	slli	a5,a5,0x6
    8000361a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000361c:	00099783          	lh	a5,0(s3)
    80003620:	c785                	beqz	a5,80003648 <ialloc+0x84>
    brelse(bp);
    80003622:	00000097          	auipc	ra,0x0
    80003626:	a68080e7          	jalr	-1432(ra) # 8000308a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000362a:	0485                	addi	s1,s1,1
    8000362c:	00ca2703          	lw	a4,12(s4)
    80003630:	0004879b          	sext.w	a5,s1
    80003634:	fce7e1e3          	bltu	a5,a4,800035f6 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003638:	00005517          	auipc	a0,0x5
    8000363c:	f5850513          	addi	a0,a0,-168 # 80008590 <syscalls+0x168>
    80003640:	ffffd097          	auipc	ra,0xffffd
    80003644:	f02080e7          	jalr	-254(ra) # 80000542 <panic>
      memset(dip, 0, sizeof(*dip));
    80003648:	04000613          	li	a2,64
    8000364c:	4581                	li	a1,0
    8000364e:	854e                	mv	a0,s3
    80003650:	ffffd097          	auipc	ra,0xffffd
    80003654:	7ba080e7          	jalr	1978(ra) # 80000e0a <memset>
      dip->type = type;
    80003658:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000365c:	854a                	mv	a0,s2
    8000365e:	00001097          	auipc	ra,0x1
    80003662:	c94080e7          	jalr	-876(ra) # 800042f2 <log_write>
      brelse(bp);
    80003666:	854a                	mv	a0,s2
    80003668:	00000097          	auipc	ra,0x0
    8000366c:	a22080e7          	jalr	-1502(ra) # 8000308a <brelse>
      return iget(dev, inum);
    80003670:	85da                	mv	a1,s6
    80003672:	8556                	mv	a0,s5
    80003674:	00000097          	auipc	ra,0x0
    80003678:	db4080e7          	jalr	-588(ra) # 80003428 <iget>
}
    8000367c:	60a6                	ld	ra,72(sp)
    8000367e:	6406                	ld	s0,64(sp)
    80003680:	74e2                	ld	s1,56(sp)
    80003682:	7942                	ld	s2,48(sp)
    80003684:	79a2                	ld	s3,40(sp)
    80003686:	7a02                	ld	s4,32(sp)
    80003688:	6ae2                	ld	s5,24(sp)
    8000368a:	6b42                	ld	s6,16(sp)
    8000368c:	6ba2                	ld	s7,8(sp)
    8000368e:	6161                	addi	sp,sp,80
    80003690:	8082                	ret

0000000080003692 <iupdate>:
{
    80003692:	1101                	addi	sp,sp,-32
    80003694:	ec06                	sd	ra,24(sp)
    80003696:	e822                	sd	s0,16(sp)
    80003698:	e426                	sd	s1,8(sp)
    8000369a:	e04a                	sd	s2,0(sp)
    8000369c:	1000                	addi	s0,sp,32
    8000369e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036a0:	415c                	lw	a5,4(a0)
    800036a2:	0047d79b          	srliw	a5,a5,0x4
    800036a6:	0003c597          	auipc	a1,0x3c
    800036aa:	7b25a583          	lw	a1,1970(a1) # 8003fe58 <sb+0x18>
    800036ae:	9dbd                	addw	a1,a1,a5
    800036b0:	4108                	lw	a0,0(a0)
    800036b2:	00000097          	auipc	ra,0x0
    800036b6:	8a8080e7          	jalr	-1880(ra) # 80002f5a <bread>
    800036ba:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036bc:	05850793          	addi	a5,a0,88
    800036c0:	40c8                	lw	a0,4(s1)
    800036c2:	893d                	andi	a0,a0,15
    800036c4:	051a                	slli	a0,a0,0x6
    800036c6:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800036c8:	04449703          	lh	a4,68(s1)
    800036cc:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800036d0:	04649703          	lh	a4,70(s1)
    800036d4:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800036d8:	04849703          	lh	a4,72(s1)
    800036dc:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800036e0:	04a49703          	lh	a4,74(s1)
    800036e4:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800036e8:	44f8                	lw	a4,76(s1)
    800036ea:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036ec:	03400613          	li	a2,52
    800036f0:	05048593          	addi	a1,s1,80
    800036f4:	0531                	addi	a0,a0,12
    800036f6:	ffffd097          	auipc	ra,0xffffd
    800036fa:	770080e7          	jalr	1904(ra) # 80000e66 <memmove>
  log_write(bp);
    800036fe:	854a                	mv	a0,s2
    80003700:	00001097          	auipc	ra,0x1
    80003704:	bf2080e7          	jalr	-1038(ra) # 800042f2 <log_write>
  brelse(bp);
    80003708:	854a                	mv	a0,s2
    8000370a:	00000097          	auipc	ra,0x0
    8000370e:	980080e7          	jalr	-1664(ra) # 8000308a <brelse>
}
    80003712:	60e2                	ld	ra,24(sp)
    80003714:	6442                	ld	s0,16(sp)
    80003716:	64a2                	ld	s1,8(sp)
    80003718:	6902                	ld	s2,0(sp)
    8000371a:	6105                	addi	sp,sp,32
    8000371c:	8082                	ret

000000008000371e <idup>:
{
    8000371e:	1101                	addi	sp,sp,-32
    80003720:	ec06                	sd	ra,24(sp)
    80003722:	e822                	sd	s0,16(sp)
    80003724:	e426                	sd	s1,8(sp)
    80003726:	1000                	addi	s0,sp,32
    80003728:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000372a:	0003c517          	auipc	a0,0x3c
    8000372e:	73650513          	addi	a0,a0,1846 # 8003fe60 <icache>
    80003732:	ffffd097          	auipc	ra,0xffffd
    80003736:	5dc080e7          	jalr	1500(ra) # 80000d0e <acquire>
  ip->ref++;
    8000373a:	449c                	lw	a5,8(s1)
    8000373c:	2785                	addiw	a5,a5,1
    8000373e:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003740:	0003c517          	auipc	a0,0x3c
    80003744:	72050513          	addi	a0,a0,1824 # 8003fe60 <icache>
    80003748:	ffffd097          	auipc	ra,0xffffd
    8000374c:	67a080e7          	jalr	1658(ra) # 80000dc2 <release>
}
    80003750:	8526                	mv	a0,s1
    80003752:	60e2                	ld	ra,24(sp)
    80003754:	6442                	ld	s0,16(sp)
    80003756:	64a2                	ld	s1,8(sp)
    80003758:	6105                	addi	sp,sp,32
    8000375a:	8082                	ret

000000008000375c <ilock>:
{
    8000375c:	1101                	addi	sp,sp,-32
    8000375e:	ec06                	sd	ra,24(sp)
    80003760:	e822                	sd	s0,16(sp)
    80003762:	e426                	sd	s1,8(sp)
    80003764:	e04a                	sd	s2,0(sp)
    80003766:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003768:	c115                	beqz	a0,8000378c <ilock+0x30>
    8000376a:	84aa                	mv	s1,a0
    8000376c:	451c                	lw	a5,8(a0)
    8000376e:	00f05f63          	blez	a5,8000378c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003772:	0541                	addi	a0,a0,16
    80003774:	00001097          	auipc	ra,0x1
    80003778:	ca6080e7          	jalr	-858(ra) # 8000441a <acquiresleep>
  if(ip->valid == 0){
    8000377c:	40bc                	lw	a5,64(s1)
    8000377e:	cf99                	beqz	a5,8000379c <ilock+0x40>
}
    80003780:	60e2                	ld	ra,24(sp)
    80003782:	6442                	ld	s0,16(sp)
    80003784:	64a2                	ld	s1,8(sp)
    80003786:	6902                	ld	s2,0(sp)
    80003788:	6105                	addi	sp,sp,32
    8000378a:	8082                	ret
    panic("ilock");
    8000378c:	00005517          	auipc	a0,0x5
    80003790:	e1c50513          	addi	a0,a0,-484 # 800085a8 <syscalls+0x180>
    80003794:	ffffd097          	auipc	ra,0xffffd
    80003798:	dae080e7          	jalr	-594(ra) # 80000542 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000379c:	40dc                	lw	a5,4(s1)
    8000379e:	0047d79b          	srliw	a5,a5,0x4
    800037a2:	0003c597          	auipc	a1,0x3c
    800037a6:	6b65a583          	lw	a1,1718(a1) # 8003fe58 <sb+0x18>
    800037aa:	9dbd                	addw	a1,a1,a5
    800037ac:	4088                	lw	a0,0(s1)
    800037ae:	fffff097          	auipc	ra,0xfffff
    800037b2:	7ac080e7          	jalr	1964(ra) # 80002f5a <bread>
    800037b6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037b8:	05850593          	addi	a1,a0,88
    800037bc:	40dc                	lw	a5,4(s1)
    800037be:	8bbd                	andi	a5,a5,15
    800037c0:	079a                	slli	a5,a5,0x6
    800037c2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037c4:	00059783          	lh	a5,0(a1)
    800037c8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037cc:	00259783          	lh	a5,2(a1)
    800037d0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037d4:	00459783          	lh	a5,4(a1)
    800037d8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037dc:	00659783          	lh	a5,6(a1)
    800037e0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800037e4:	459c                	lw	a5,8(a1)
    800037e6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037e8:	03400613          	li	a2,52
    800037ec:	05b1                	addi	a1,a1,12
    800037ee:	05048513          	addi	a0,s1,80
    800037f2:	ffffd097          	auipc	ra,0xffffd
    800037f6:	674080e7          	jalr	1652(ra) # 80000e66 <memmove>
    brelse(bp);
    800037fa:	854a                	mv	a0,s2
    800037fc:	00000097          	auipc	ra,0x0
    80003800:	88e080e7          	jalr	-1906(ra) # 8000308a <brelse>
    ip->valid = 1;
    80003804:	4785                	li	a5,1
    80003806:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003808:	04449783          	lh	a5,68(s1)
    8000380c:	fbb5                	bnez	a5,80003780 <ilock+0x24>
      panic("ilock: no type");
    8000380e:	00005517          	auipc	a0,0x5
    80003812:	da250513          	addi	a0,a0,-606 # 800085b0 <syscalls+0x188>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	d2c080e7          	jalr	-724(ra) # 80000542 <panic>

000000008000381e <iunlock>:
{
    8000381e:	1101                	addi	sp,sp,-32
    80003820:	ec06                	sd	ra,24(sp)
    80003822:	e822                	sd	s0,16(sp)
    80003824:	e426                	sd	s1,8(sp)
    80003826:	e04a                	sd	s2,0(sp)
    80003828:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000382a:	c905                	beqz	a0,8000385a <iunlock+0x3c>
    8000382c:	84aa                	mv	s1,a0
    8000382e:	01050913          	addi	s2,a0,16
    80003832:	854a                	mv	a0,s2
    80003834:	00001097          	auipc	ra,0x1
    80003838:	c80080e7          	jalr	-896(ra) # 800044b4 <holdingsleep>
    8000383c:	cd19                	beqz	a0,8000385a <iunlock+0x3c>
    8000383e:	449c                	lw	a5,8(s1)
    80003840:	00f05d63          	blez	a5,8000385a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003844:	854a                	mv	a0,s2
    80003846:	00001097          	auipc	ra,0x1
    8000384a:	c2a080e7          	jalr	-982(ra) # 80004470 <releasesleep>
}
    8000384e:	60e2                	ld	ra,24(sp)
    80003850:	6442                	ld	s0,16(sp)
    80003852:	64a2                	ld	s1,8(sp)
    80003854:	6902                	ld	s2,0(sp)
    80003856:	6105                	addi	sp,sp,32
    80003858:	8082                	ret
    panic("iunlock");
    8000385a:	00005517          	auipc	a0,0x5
    8000385e:	d6650513          	addi	a0,a0,-666 # 800085c0 <syscalls+0x198>
    80003862:	ffffd097          	auipc	ra,0xffffd
    80003866:	ce0080e7          	jalr	-800(ra) # 80000542 <panic>

000000008000386a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000386a:	7179                	addi	sp,sp,-48
    8000386c:	f406                	sd	ra,40(sp)
    8000386e:	f022                	sd	s0,32(sp)
    80003870:	ec26                	sd	s1,24(sp)
    80003872:	e84a                	sd	s2,16(sp)
    80003874:	e44e                	sd	s3,8(sp)
    80003876:	e052                	sd	s4,0(sp)
    80003878:	1800                	addi	s0,sp,48
    8000387a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000387c:	05050493          	addi	s1,a0,80
    80003880:	08050913          	addi	s2,a0,128
    80003884:	a021                	j	8000388c <itrunc+0x22>
    80003886:	0491                	addi	s1,s1,4
    80003888:	01248d63          	beq	s1,s2,800038a2 <itrunc+0x38>
    if(ip->addrs[i]){
    8000388c:	408c                	lw	a1,0(s1)
    8000388e:	dde5                	beqz	a1,80003886 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003890:	0009a503          	lw	a0,0(s3)
    80003894:	00000097          	auipc	ra,0x0
    80003898:	90c080e7          	jalr	-1780(ra) # 800031a0 <bfree>
      ip->addrs[i] = 0;
    8000389c:	0004a023          	sw	zero,0(s1)
    800038a0:	b7dd                	j	80003886 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038a2:	0809a583          	lw	a1,128(s3)
    800038a6:	e185                	bnez	a1,800038c6 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038a8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038ac:	854e                	mv	a0,s3
    800038ae:	00000097          	auipc	ra,0x0
    800038b2:	de4080e7          	jalr	-540(ra) # 80003692 <iupdate>
}
    800038b6:	70a2                	ld	ra,40(sp)
    800038b8:	7402                	ld	s0,32(sp)
    800038ba:	64e2                	ld	s1,24(sp)
    800038bc:	6942                	ld	s2,16(sp)
    800038be:	69a2                	ld	s3,8(sp)
    800038c0:	6a02                	ld	s4,0(sp)
    800038c2:	6145                	addi	sp,sp,48
    800038c4:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038c6:	0009a503          	lw	a0,0(s3)
    800038ca:	fffff097          	auipc	ra,0xfffff
    800038ce:	690080e7          	jalr	1680(ra) # 80002f5a <bread>
    800038d2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038d4:	05850493          	addi	s1,a0,88
    800038d8:	45850913          	addi	s2,a0,1112
    800038dc:	a021                	j	800038e4 <itrunc+0x7a>
    800038de:	0491                	addi	s1,s1,4
    800038e0:	01248b63          	beq	s1,s2,800038f6 <itrunc+0x8c>
      if(a[j])
    800038e4:	408c                	lw	a1,0(s1)
    800038e6:	dde5                	beqz	a1,800038de <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800038e8:	0009a503          	lw	a0,0(s3)
    800038ec:	00000097          	auipc	ra,0x0
    800038f0:	8b4080e7          	jalr	-1868(ra) # 800031a0 <bfree>
    800038f4:	b7ed                	j	800038de <itrunc+0x74>
    brelse(bp);
    800038f6:	8552                	mv	a0,s4
    800038f8:	fffff097          	auipc	ra,0xfffff
    800038fc:	792080e7          	jalr	1938(ra) # 8000308a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003900:	0809a583          	lw	a1,128(s3)
    80003904:	0009a503          	lw	a0,0(s3)
    80003908:	00000097          	auipc	ra,0x0
    8000390c:	898080e7          	jalr	-1896(ra) # 800031a0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003910:	0809a023          	sw	zero,128(s3)
    80003914:	bf51                	j	800038a8 <itrunc+0x3e>

0000000080003916 <iput>:
{
    80003916:	1101                	addi	sp,sp,-32
    80003918:	ec06                	sd	ra,24(sp)
    8000391a:	e822                	sd	s0,16(sp)
    8000391c:	e426                	sd	s1,8(sp)
    8000391e:	e04a                	sd	s2,0(sp)
    80003920:	1000                	addi	s0,sp,32
    80003922:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003924:	0003c517          	auipc	a0,0x3c
    80003928:	53c50513          	addi	a0,a0,1340 # 8003fe60 <icache>
    8000392c:	ffffd097          	auipc	ra,0xffffd
    80003930:	3e2080e7          	jalr	994(ra) # 80000d0e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003934:	4498                	lw	a4,8(s1)
    80003936:	4785                	li	a5,1
    80003938:	02f70363          	beq	a4,a5,8000395e <iput+0x48>
  ip->ref--;
    8000393c:	449c                	lw	a5,8(s1)
    8000393e:	37fd                	addiw	a5,a5,-1
    80003940:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003942:	0003c517          	auipc	a0,0x3c
    80003946:	51e50513          	addi	a0,a0,1310 # 8003fe60 <icache>
    8000394a:	ffffd097          	auipc	ra,0xffffd
    8000394e:	478080e7          	jalr	1144(ra) # 80000dc2 <release>
}
    80003952:	60e2                	ld	ra,24(sp)
    80003954:	6442                	ld	s0,16(sp)
    80003956:	64a2                	ld	s1,8(sp)
    80003958:	6902                	ld	s2,0(sp)
    8000395a:	6105                	addi	sp,sp,32
    8000395c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000395e:	40bc                	lw	a5,64(s1)
    80003960:	dff1                	beqz	a5,8000393c <iput+0x26>
    80003962:	04a49783          	lh	a5,74(s1)
    80003966:	fbf9                	bnez	a5,8000393c <iput+0x26>
    acquiresleep(&ip->lock);
    80003968:	01048913          	addi	s2,s1,16
    8000396c:	854a                	mv	a0,s2
    8000396e:	00001097          	auipc	ra,0x1
    80003972:	aac080e7          	jalr	-1364(ra) # 8000441a <acquiresleep>
    release(&icache.lock);
    80003976:	0003c517          	auipc	a0,0x3c
    8000397a:	4ea50513          	addi	a0,a0,1258 # 8003fe60 <icache>
    8000397e:	ffffd097          	auipc	ra,0xffffd
    80003982:	444080e7          	jalr	1092(ra) # 80000dc2 <release>
    itrunc(ip);
    80003986:	8526                	mv	a0,s1
    80003988:	00000097          	auipc	ra,0x0
    8000398c:	ee2080e7          	jalr	-286(ra) # 8000386a <itrunc>
    ip->type = 0;
    80003990:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003994:	8526                	mv	a0,s1
    80003996:	00000097          	auipc	ra,0x0
    8000399a:	cfc080e7          	jalr	-772(ra) # 80003692 <iupdate>
    ip->valid = 0;
    8000399e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039a2:	854a                	mv	a0,s2
    800039a4:	00001097          	auipc	ra,0x1
    800039a8:	acc080e7          	jalr	-1332(ra) # 80004470 <releasesleep>
    acquire(&icache.lock);
    800039ac:	0003c517          	auipc	a0,0x3c
    800039b0:	4b450513          	addi	a0,a0,1204 # 8003fe60 <icache>
    800039b4:	ffffd097          	auipc	ra,0xffffd
    800039b8:	35a080e7          	jalr	858(ra) # 80000d0e <acquire>
    800039bc:	b741                	j	8000393c <iput+0x26>

00000000800039be <iunlockput>:
{
    800039be:	1101                	addi	sp,sp,-32
    800039c0:	ec06                	sd	ra,24(sp)
    800039c2:	e822                	sd	s0,16(sp)
    800039c4:	e426                	sd	s1,8(sp)
    800039c6:	1000                	addi	s0,sp,32
    800039c8:	84aa                	mv	s1,a0
  iunlock(ip);
    800039ca:	00000097          	auipc	ra,0x0
    800039ce:	e54080e7          	jalr	-428(ra) # 8000381e <iunlock>
  iput(ip);
    800039d2:	8526                	mv	a0,s1
    800039d4:	00000097          	auipc	ra,0x0
    800039d8:	f42080e7          	jalr	-190(ra) # 80003916 <iput>
}
    800039dc:	60e2                	ld	ra,24(sp)
    800039de:	6442                	ld	s0,16(sp)
    800039e0:	64a2                	ld	s1,8(sp)
    800039e2:	6105                	addi	sp,sp,32
    800039e4:	8082                	ret

00000000800039e6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039e6:	1141                	addi	sp,sp,-16
    800039e8:	e422                	sd	s0,8(sp)
    800039ea:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039ec:	411c                	lw	a5,0(a0)
    800039ee:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039f0:	415c                	lw	a5,4(a0)
    800039f2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039f4:	04451783          	lh	a5,68(a0)
    800039f8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039fc:	04a51783          	lh	a5,74(a0)
    80003a00:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a04:	04c56783          	lwu	a5,76(a0)
    80003a08:	e99c                	sd	a5,16(a1)
}
    80003a0a:	6422                	ld	s0,8(sp)
    80003a0c:	0141                	addi	sp,sp,16
    80003a0e:	8082                	ret

0000000080003a10 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a10:	457c                	lw	a5,76(a0)
    80003a12:	0ed7e963          	bltu	a5,a3,80003b04 <readi+0xf4>
{
    80003a16:	7159                	addi	sp,sp,-112
    80003a18:	f486                	sd	ra,104(sp)
    80003a1a:	f0a2                	sd	s0,96(sp)
    80003a1c:	eca6                	sd	s1,88(sp)
    80003a1e:	e8ca                	sd	s2,80(sp)
    80003a20:	e4ce                	sd	s3,72(sp)
    80003a22:	e0d2                	sd	s4,64(sp)
    80003a24:	fc56                	sd	s5,56(sp)
    80003a26:	f85a                	sd	s6,48(sp)
    80003a28:	f45e                	sd	s7,40(sp)
    80003a2a:	f062                	sd	s8,32(sp)
    80003a2c:	ec66                	sd	s9,24(sp)
    80003a2e:	e86a                	sd	s10,16(sp)
    80003a30:	e46e                	sd	s11,8(sp)
    80003a32:	1880                	addi	s0,sp,112
    80003a34:	8baa                	mv	s7,a0
    80003a36:	8c2e                	mv	s8,a1
    80003a38:	8ab2                	mv	s5,a2
    80003a3a:	84b6                	mv	s1,a3
    80003a3c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a3e:	9f35                	addw	a4,a4,a3
    return 0;
    80003a40:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a42:	0ad76063          	bltu	a4,a3,80003ae2 <readi+0xd2>
  if(off + n > ip->size)
    80003a46:	00e7f463          	bgeu	a5,a4,80003a4e <readi+0x3e>
    n = ip->size - off;
    80003a4a:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a4e:	0a0b0963          	beqz	s6,80003b00 <readi+0xf0>
    80003a52:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a54:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a58:	5cfd                	li	s9,-1
    80003a5a:	a82d                	j	80003a94 <readi+0x84>
    80003a5c:	020a1d93          	slli	s11,s4,0x20
    80003a60:	020ddd93          	srli	s11,s11,0x20
    80003a64:	05890793          	addi	a5,s2,88
    80003a68:	86ee                	mv	a3,s11
    80003a6a:	963e                	add	a2,a2,a5
    80003a6c:	85d6                	mv	a1,s5
    80003a6e:	8562                	mv	a0,s8
    80003a70:	fffff097          	auipc	ra,0xfffff
    80003a74:	b04080e7          	jalr	-1276(ra) # 80002574 <either_copyout>
    80003a78:	05950d63          	beq	a0,s9,80003ad2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a7c:	854a                	mv	a0,s2
    80003a7e:	fffff097          	auipc	ra,0xfffff
    80003a82:	60c080e7          	jalr	1548(ra) # 8000308a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a86:	013a09bb          	addw	s3,s4,s3
    80003a8a:	009a04bb          	addw	s1,s4,s1
    80003a8e:	9aee                	add	s5,s5,s11
    80003a90:	0569f763          	bgeu	s3,s6,80003ade <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a94:	000ba903          	lw	s2,0(s7)
    80003a98:	00a4d59b          	srliw	a1,s1,0xa
    80003a9c:	855e                	mv	a0,s7
    80003a9e:	00000097          	auipc	ra,0x0
    80003aa2:	8b0080e7          	jalr	-1872(ra) # 8000334e <bmap>
    80003aa6:	0005059b          	sext.w	a1,a0
    80003aaa:	854a                	mv	a0,s2
    80003aac:	fffff097          	auipc	ra,0xfffff
    80003ab0:	4ae080e7          	jalr	1198(ra) # 80002f5a <bread>
    80003ab4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ab6:	3ff4f613          	andi	a2,s1,1023
    80003aba:	40cd07bb          	subw	a5,s10,a2
    80003abe:	413b073b          	subw	a4,s6,s3
    80003ac2:	8a3e                	mv	s4,a5
    80003ac4:	2781                	sext.w	a5,a5
    80003ac6:	0007069b          	sext.w	a3,a4
    80003aca:	f8f6f9e3          	bgeu	a3,a5,80003a5c <readi+0x4c>
    80003ace:	8a3a                	mv	s4,a4
    80003ad0:	b771                	j	80003a5c <readi+0x4c>
      brelse(bp);
    80003ad2:	854a                	mv	a0,s2
    80003ad4:	fffff097          	auipc	ra,0xfffff
    80003ad8:	5b6080e7          	jalr	1462(ra) # 8000308a <brelse>
      tot = -1;
    80003adc:	59fd                	li	s3,-1
  }
  return tot;
    80003ade:	0009851b          	sext.w	a0,s3
}
    80003ae2:	70a6                	ld	ra,104(sp)
    80003ae4:	7406                	ld	s0,96(sp)
    80003ae6:	64e6                	ld	s1,88(sp)
    80003ae8:	6946                	ld	s2,80(sp)
    80003aea:	69a6                	ld	s3,72(sp)
    80003aec:	6a06                	ld	s4,64(sp)
    80003aee:	7ae2                	ld	s5,56(sp)
    80003af0:	7b42                	ld	s6,48(sp)
    80003af2:	7ba2                	ld	s7,40(sp)
    80003af4:	7c02                	ld	s8,32(sp)
    80003af6:	6ce2                	ld	s9,24(sp)
    80003af8:	6d42                	ld	s10,16(sp)
    80003afa:	6da2                	ld	s11,8(sp)
    80003afc:	6165                	addi	sp,sp,112
    80003afe:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b00:	89da                	mv	s3,s6
    80003b02:	bff1                	j	80003ade <readi+0xce>
    return 0;
    80003b04:	4501                	li	a0,0
}
    80003b06:	8082                	ret

0000000080003b08 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b08:	457c                	lw	a5,76(a0)
    80003b0a:	10d7e763          	bltu	a5,a3,80003c18 <writei+0x110>
{
    80003b0e:	7159                	addi	sp,sp,-112
    80003b10:	f486                	sd	ra,104(sp)
    80003b12:	f0a2                	sd	s0,96(sp)
    80003b14:	eca6                	sd	s1,88(sp)
    80003b16:	e8ca                	sd	s2,80(sp)
    80003b18:	e4ce                	sd	s3,72(sp)
    80003b1a:	e0d2                	sd	s4,64(sp)
    80003b1c:	fc56                	sd	s5,56(sp)
    80003b1e:	f85a                	sd	s6,48(sp)
    80003b20:	f45e                	sd	s7,40(sp)
    80003b22:	f062                	sd	s8,32(sp)
    80003b24:	ec66                	sd	s9,24(sp)
    80003b26:	e86a                	sd	s10,16(sp)
    80003b28:	e46e                	sd	s11,8(sp)
    80003b2a:	1880                	addi	s0,sp,112
    80003b2c:	8baa                	mv	s7,a0
    80003b2e:	8c2e                	mv	s8,a1
    80003b30:	8ab2                	mv	s5,a2
    80003b32:	8936                	mv	s2,a3
    80003b34:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b36:	00e687bb          	addw	a5,a3,a4
    80003b3a:	0ed7e163          	bltu	a5,a3,80003c1c <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b3e:	00043737          	lui	a4,0x43
    80003b42:	0cf76f63          	bltu	a4,a5,80003c20 <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b46:	0a0b0863          	beqz	s6,80003bf6 <writei+0xee>
    80003b4a:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b4c:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b50:	5cfd                	li	s9,-1
    80003b52:	a091                	j	80003b96 <writei+0x8e>
    80003b54:	02099d93          	slli	s11,s3,0x20
    80003b58:	020ddd93          	srli	s11,s11,0x20
    80003b5c:	05848793          	addi	a5,s1,88
    80003b60:	86ee                	mv	a3,s11
    80003b62:	8656                	mv	a2,s5
    80003b64:	85e2                	mv	a1,s8
    80003b66:	953e                	add	a0,a0,a5
    80003b68:	fffff097          	auipc	ra,0xfffff
    80003b6c:	a62080e7          	jalr	-1438(ra) # 800025ca <either_copyin>
    80003b70:	07950263          	beq	a0,s9,80003bd4 <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003b74:	8526                	mv	a0,s1
    80003b76:	00000097          	auipc	ra,0x0
    80003b7a:	77c080e7          	jalr	1916(ra) # 800042f2 <log_write>
    brelse(bp);
    80003b7e:	8526                	mv	a0,s1
    80003b80:	fffff097          	auipc	ra,0xfffff
    80003b84:	50a080e7          	jalr	1290(ra) # 8000308a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b88:	01498a3b          	addw	s4,s3,s4
    80003b8c:	0129893b          	addw	s2,s3,s2
    80003b90:	9aee                	add	s5,s5,s11
    80003b92:	056a7763          	bgeu	s4,s6,80003be0 <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b96:	000ba483          	lw	s1,0(s7)
    80003b9a:	00a9559b          	srliw	a1,s2,0xa
    80003b9e:	855e                	mv	a0,s7
    80003ba0:	fffff097          	auipc	ra,0xfffff
    80003ba4:	7ae080e7          	jalr	1966(ra) # 8000334e <bmap>
    80003ba8:	0005059b          	sext.w	a1,a0
    80003bac:	8526                	mv	a0,s1
    80003bae:	fffff097          	auipc	ra,0xfffff
    80003bb2:	3ac080e7          	jalr	940(ra) # 80002f5a <bread>
    80003bb6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bb8:	3ff97513          	andi	a0,s2,1023
    80003bbc:	40ad07bb          	subw	a5,s10,a0
    80003bc0:	414b073b          	subw	a4,s6,s4
    80003bc4:	89be                	mv	s3,a5
    80003bc6:	2781                	sext.w	a5,a5
    80003bc8:	0007069b          	sext.w	a3,a4
    80003bcc:	f8f6f4e3          	bgeu	a3,a5,80003b54 <writei+0x4c>
    80003bd0:	89ba                	mv	s3,a4
    80003bd2:	b749                	j	80003b54 <writei+0x4c>
      brelse(bp);
    80003bd4:	8526                	mv	a0,s1
    80003bd6:	fffff097          	auipc	ra,0xfffff
    80003bda:	4b4080e7          	jalr	1204(ra) # 8000308a <brelse>
      n = -1;
    80003bde:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003be0:	04cba783          	lw	a5,76(s7)
    80003be4:	0127f463          	bgeu	a5,s2,80003bec <writei+0xe4>
      ip->size = off;
    80003be8:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003bec:	855e                	mv	a0,s7
    80003bee:	00000097          	auipc	ra,0x0
    80003bf2:	aa4080e7          	jalr	-1372(ra) # 80003692 <iupdate>
  }

  return n;
    80003bf6:	000b051b          	sext.w	a0,s6
}
    80003bfa:	70a6                	ld	ra,104(sp)
    80003bfc:	7406                	ld	s0,96(sp)
    80003bfe:	64e6                	ld	s1,88(sp)
    80003c00:	6946                	ld	s2,80(sp)
    80003c02:	69a6                	ld	s3,72(sp)
    80003c04:	6a06                	ld	s4,64(sp)
    80003c06:	7ae2                	ld	s5,56(sp)
    80003c08:	7b42                	ld	s6,48(sp)
    80003c0a:	7ba2                	ld	s7,40(sp)
    80003c0c:	7c02                	ld	s8,32(sp)
    80003c0e:	6ce2                	ld	s9,24(sp)
    80003c10:	6d42                	ld	s10,16(sp)
    80003c12:	6da2                	ld	s11,8(sp)
    80003c14:	6165                	addi	sp,sp,112
    80003c16:	8082                	ret
    return -1;
    80003c18:	557d                	li	a0,-1
}
    80003c1a:	8082                	ret
    return -1;
    80003c1c:	557d                	li	a0,-1
    80003c1e:	bff1                	j	80003bfa <writei+0xf2>
    return -1;
    80003c20:	557d                	li	a0,-1
    80003c22:	bfe1                	j	80003bfa <writei+0xf2>

0000000080003c24 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c24:	1141                	addi	sp,sp,-16
    80003c26:	e406                	sd	ra,8(sp)
    80003c28:	e022                	sd	s0,0(sp)
    80003c2a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c2c:	4639                	li	a2,14
    80003c2e:	ffffd097          	auipc	ra,0xffffd
    80003c32:	2b4080e7          	jalr	692(ra) # 80000ee2 <strncmp>
}
    80003c36:	60a2                	ld	ra,8(sp)
    80003c38:	6402                	ld	s0,0(sp)
    80003c3a:	0141                	addi	sp,sp,16
    80003c3c:	8082                	ret

0000000080003c3e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c3e:	7139                	addi	sp,sp,-64
    80003c40:	fc06                	sd	ra,56(sp)
    80003c42:	f822                	sd	s0,48(sp)
    80003c44:	f426                	sd	s1,40(sp)
    80003c46:	f04a                	sd	s2,32(sp)
    80003c48:	ec4e                	sd	s3,24(sp)
    80003c4a:	e852                	sd	s4,16(sp)
    80003c4c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c4e:	04451703          	lh	a4,68(a0)
    80003c52:	4785                	li	a5,1
    80003c54:	00f71a63          	bne	a4,a5,80003c68 <dirlookup+0x2a>
    80003c58:	892a                	mv	s2,a0
    80003c5a:	89ae                	mv	s3,a1
    80003c5c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c5e:	457c                	lw	a5,76(a0)
    80003c60:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c62:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c64:	e79d                	bnez	a5,80003c92 <dirlookup+0x54>
    80003c66:	a8a5                	j	80003cde <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c68:	00005517          	auipc	a0,0x5
    80003c6c:	96050513          	addi	a0,a0,-1696 # 800085c8 <syscalls+0x1a0>
    80003c70:	ffffd097          	auipc	ra,0xffffd
    80003c74:	8d2080e7          	jalr	-1838(ra) # 80000542 <panic>
      panic("dirlookup read");
    80003c78:	00005517          	auipc	a0,0x5
    80003c7c:	96850513          	addi	a0,a0,-1688 # 800085e0 <syscalls+0x1b8>
    80003c80:	ffffd097          	auipc	ra,0xffffd
    80003c84:	8c2080e7          	jalr	-1854(ra) # 80000542 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c88:	24c1                	addiw	s1,s1,16
    80003c8a:	04c92783          	lw	a5,76(s2)
    80003c8e:	04f4f763          	bgeu	s1,a5,80003cdc <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c92:	4741                	li	a4,16
    80003c94:	86a6                	mv	a3,s1
    80003c96:	fc040613          	addi	a2,s0,-64
    80003c9a:	4581                	li	a1,0
    80003c9c:	854a                	mv	a0,s2
    80003c9e:	00000097          	auipc	ra,0x0
    80003ca2:	d72080e7          	jalr	-654(ra) # 80003a10 <readi>
    80003ca6:	47c1                	li	a5,16
    80003ca8:	fcf518e3          	bne	a0,a5,80003c78 <dirlookup+0x3a>
    if(de.inum == 0)
    80003cac:	fc045783          	lhu	a5,-64(s0)
    80003cb0:	dfe1                	beqz	a5,80003c88 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003cb2:	fc240593          	addi	a1,s0,-62
    80003cb6:	854e                	mv	a0,s3
    80003cb8:	00000097          	auipc	ra,0x0
    80003cbc:	f6c080e7          	jalr	-148(ra) # 80003c24 <namecmp>
    80003cc0:	f561                	bnez	a0,80003c88 <dirlookup+0x4a>
      if(poff)
    80003cc2:	000a0463          	beqz	s4,80003cca <dirlookup+0x8c>
        *poff = off;
    80003cc6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cca:	fc045583          	lhu	a1,-64(s0)
    80003cce:	00092503          	lw	a0,0(s2)
    80003cd2:	fffff097          	auipc	ra,0xfffff
    80003cd6:	756080e7          	jalr	1878(ra) # 80003428 <iget>
    80003cda:	a011                	j	80003cde <dirlookup+0xa0>
  return 0;
    80003cdc:	4501                	li	a0,0
}
    80003cde:	70e2                	ld	ra,56(sp)
    80003ce0:	7442                	ld	s0,48(sp)
    80003ce2:	74a2                	ld	s1,40(sp)
    80003ce4:	7902                	ld	s2,32(sp)
    80003ce6:	69e2                	ld	s3,24(sp)
    80003ce8:	6a42                	ld	s4,16(sp)
    80003cea:	6121                	addi	sp,sp,64
    80003cec:	8082                	ret

0000000080003cee <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003cee:	711d                	addi	sp,sp,-96
    80003cf0:	ec86                	sd	ra,88(sp)
    80003cf2:	e8a2                	sd	s0,80(sp)
    80003cf4:	e4a6                	sd	s1,72(sp)
    80003cf6:	e0ca                	sd	s2,64(sp)
    80003cf8:	fc4e                	sd	s3,56(sp)
    80003cfa:	f852                	sd	s4,48(sp)
    80003cfc:	f456                	sd	s5,40(sp)
    80003cfe:	f05a                	sd	s6,32(sp)
    80003d00:	ec5e                	sd	s7,24(sp)
    80003d02:	e862                	sd	s8,16(sp)
    80003d04:	e466                	sd	s9,8(sp)
    80003d06:	1080                	addi	s0,sp,96
    80003d08:	84aa                	mv	s1,a0
    80003d0a:	8aae                	mv	s5,a1
    80003d0c:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d0e:	00054703          	lbu	a4,0(a0)
    80003d12:	02f00793          	li	a5,47
    80003d16:	02f70363          	beq	a4,a5,80003d3c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d1a:	ffffe097          	auipc	ra,0xffffe
    80003d1e:	dec080e7          	jalr	-532(ra) # 80001b06 <myproc>
    80003d22:	15053503          	ld	a0,336(a0)
    80003d26:	00000097          	auipc	ra,0x0
    80003d2a:	9f8080e7          	jalr	-1544(ra) # 8000371e <idup>
    80003d2e:	89aa                	mv	s3,a0
  while(*path == '/')
    80003d30:	02f00913          	li	s2,47
  len = path - s;
    80003d34:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003d36:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d38:	4b85                	li	s7,1
    80003d3a:	a865                	j	80003df2 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003d3c:	4585                	li	a1,1
    80003d3e:	4505                	li	a0,1
    80003d40:	fffff097          	auipc	ra,0xfffff
    80003d44:	6e8080e7          	jalr	1768(ra) # 80003428 <iget>
    80003d48:	89aa                	mv	s3,a0
    80003d4a:	b7dd                	j	80003d30 <namex+0x42>
      iunlockput(ip);
    80003d4c:	854e                	mv	a0,s3
    80003d4e:	00000097          	auipc	ra,0x0
    80003d52:	c70080e7          	jalr	-912(ra) # 800039be <iunlockput>
      return 0;
    80003d56:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d58:	854e                	mv	a0,s3
    80003d5a:	60e6                	ld	ra,88(sp)
    80003d5c:	6446                	ld	s0,80(sp)
    80003d5e:	64a6                	ld	s1,72(sp)
    80003d60:	6906                	ld	s2,64(sp)
    80003d62:	79e2                	ld	s3,56(sp)
    80003d64:	7a42                	ld	s4,48(sp)
    80003d66:	7aa2                	ld	s5,40(sp)
    80003d68:	7b02                	ld	s6,32(sp)
    80003d6a:	6be2                	ld	s7,24(sp)
    80003d6c:	6c42                	ld	s8,16(sp)
    80003d6e:	6ca2                	ld	s9,8(sp)
    80003d70:	6125                	addi	sp,sp,96
    80003d72:	8082                	ret
      iunlock(ip);
    80003d74:	854e                	mv	a0,s3
    80003d76:	00000097          	auipc	ra,0x0
    80003d7a:	aa8080e7          	jalr	-1368(ra) # 8000381e <iunlock>
      return ip;
    80003d7e:	bfe9                	j	80003d58 <namex+0x6a>
      iunlockput(ip);
    80003d80:	854e                	mv	a0,s3
    80003d82:	00000097          	auipc	ra,0x0
    80003d86:	c3c080e7          	jalr	-964(ra) # 800039be <iunlockput>
      return 0;
    80003d8a:	89e6                	mv	s3,s9
    80003d8c:	b7f1                	j	80003d58 <namex+0x6a>
  len = path - s;
    80003d8e:	40b48633          	sub	a2,s1,a1
    80003d92:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d96:	099c5463          	bge	s8,s9,80003e1e <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003d9a:	4639                	li	a2,14
    80003d9c:	8552                	mv	a0,s4
    80003d9e:	ffffd097          	auipc	ra,0xffffd
    80003da2:	0c8080e7          	jalr	200(ra) # 80000e66 <memmove>
  while(*path == '/')
    80003da6:	0004c783          	lbu	a5,0(s1)
    80003daa:	01279763          	bne	a5,s2,80003db8 <namex+0xca>
    path++;
    80003dae:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003db0:	0004c783          	lbu	a5,0(s1)
    80003db4:	ff278de3          	beq	a5,s2,80003dae <namex+0xc0>
    ilock(ip);
    80003db8:	854e                	mv	a0,s3
    80003dba:	00000097          	auipc	ra,0x0
    80003dbe:	9a2080e7          	jalr	-1630(ra) # 8000375c <ilock>
    if(ip->type != T_DIR){
    80003dc2:	04499783          	lh	a5,68(s3)
    80003dc6:	f97793e3          	bne	a5,s7,80003d4c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003dca:	000a8563          	beqz	s5,80003dd4 <namex+0xe6>
    80003dce:	0004c783          	lbu	a5,0(s1)
    80003dd2:	d3cd                	beqz	a5,80003d74 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003dd4:	865a                	mv	a2,s6
    80003dd6:	85d2                	mv	a1,s4
    80003dd8:	854e                	mv	a0,s3
    80003dda:	00000097          	auipc	ra,0x0
    80003dde:	e64080e7          	jalr	-412(ra) # 80003c3e <dirlookup>
    80003de2:	8caa                	mv	s9,a0
    80003de4:	dd51                	beqz	a0,80003d80 <namex+0x92>
    iunlockput(ip);
    80003de6:	854e                	mv	a0,s3
    80003de8:	00000097          	auipc	ra,0x0
    80003dec:	bd6080e7          	jalr	-1066(ra) # 800039be <iunlockput>
    ip = next;
    80003df0:	89e6                	mv	s3,s9
  while(*path == '/')
    80003df2:	0004c783          	lbu	a5,0(s1)
    80003df6:	05279763          	bne	a5,s2,80003e44 <namex+0x156>
    path++;
    80003dfa:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dfc:	0004c783          	lbu	a5,0(s1)
    80003e00:	ff278de3          	beq	a5,s2,80003dfa <namex+0x10c>
  if(*path == 0)
    80003e04:	c79d                	beqz	a5,80003e32 <namex+0x144>
    path++;
    80003e06:	85a6                	mv	a1,s1
  len = path - s;
    80003e08:	8cda                	mv	s9,s6
    80003e0a:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003e0c:	01278963          	beq	a5,s2,80003e1e <namex+0x130>
    80003e10:	dfbd                	beqz	a5,80003d8e <namex+0xa0>
    path++;
    80003e12:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003e14:	0004c783          	lbu	a5,0(s1)
    80003e18:	ff279ce3          	bne	a5,s2,80003e10 <namex+0x122>
    80003e1c:	bf8d                	j	80003d8e <namex+0xa0>
    memmove(name, s, len);
    80003e1e:	2601                	sext.w	a2,a2
    80003e20:	8552                	mv	a0,s4
    80003e22:	ffffd097          	auipc	ra,0xffffd
    80003e26:	044080e7          	jalr	68(ra) # 80000e66 <memmove>
    name[len] = 0;
    80003e2a:	9cd2                	add	s9,s9,s4
    80003e2c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e30:	bf9d                	j	80003da6 <namex+0xb8>
  if(nameiparent){
    80003e32:	f20a83e3          	beqz	s5,80003d58 <namex+0x6a>
    iput(ip);
    80003e36:	854e                	mv	a0,s3
    80003e38:	00000097          	auipc	ra,0x0
    80003e3c:	ade080e7          	jalr	-1314(ra) # 80003916 <iput>
    return 0;
    80003e40:	4981                	li	s3,0
    80003e42:	bf19                	j	80003d58 <namex+0x6a>
  if(*path == 0)
    80003e44:	d7fd                	beqz	a5,80003e32 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003e46:	0004c783          	lbu	a5,0(s1)
    80003e4a:	85a6                	mv	a1,s1
    80003e4c:	b7d1                	j	80003e10 <namex+0x122>

0000000080003e4e <dirlink>:
{
    80003e4e:	7139                	addi	sp,sp,-64
    80003e50:	fc06                	sd	ra,56(sp)
    80003e52:	f822                	sd	s0,48(sp)
    80003e54:	f426                	sd	s1,40(sp)
    80003e56:	f04a                	sd	s2,32(sp)
    80003e58:	ec4e                	sd	s3,24(sp)
    80003e5a:	e852                	sd	s4,16(sp)
    80003e5c:	0080                	addi	s0,sp,64
    80003e5e:	892a                	mv	s2,a0
    80003e60:	8a2e                	mv	s4,a1
    80003e62:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e64:	4601                	li	a2,0
    80003e66:	00000097          	auipc	ra,0x0
    80003e6a:	dd8080e7          	jalr	-552(ra) # 80003c3e <dirlookup>
    80003e6e:	e93d                	bnez	a0,80003ee4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e70:	04c92483          	lw	s1,76(s2)
    80003e74:	c49d                	beqz	s1,80003ea2 <dirlink+0x54>
    80003e76:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e78:	4741                	li	a4,16
    80003e7a:	86a6                	mv	a3,s1
    80003e7c:	fc040613          	addi	a2,s0,-64
    80003e80:	4581                	li	a1,0
    80003e82:	854a                	mv	a0,s2
    80003e84:	00000097          	auipc	ra,0x0
    80003e88:	b8c080e7          	jalr	-1140(ra) # 80003a10 <readi>
    80003e8c:	47c1                	li	a5,16
    80003e8e:	06f51163          	bne	a0,a5,80003ef0 <dirlink+0xa2>
    if(de.inum == 0)
    80003e92:	fc045783          	lhu	a5,-64(s0)
    80003e96:	c791                	beqz	a5,80003ea2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e98:	24c1                	addiw	s1,s1,16
    80003e9a:	04c92783          	lw	a5,76(s2)
    80003e9e:	fcf4ede3          	bltu	s1,a5,80003e78 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003ea2:	4639                	li	a2,14
    80003ea4:	85d2                	mv	a1,s4
    80003ea6:	fc240513          	addi	a0,s0,-62
    80003eaa:	ffffd097          	auipc	ra,0xffffd
    80003eae:	074080e7          	jalr	116(ra) # 80000f1e <strncpy>
  de.inum = inum;
    80003eb2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eb6:	4741                	li	a4,16
    80003eb8:	86a6                	mv	a3,s1
    80003eba:	fc040613          	addi	a2,s0,-64
    80003ebe:	4581                	li	a1,0
    80003ec0:	854a                	mv	a0,s2
    80003ec2:	00000097          	auipc	ra,0x0
    80003ec6:	c46080e7          	jalr	-954(ra) # 80003b08 <writei>
    80003eca:	872a                	mv	a4,a0
    80003ecc:	47c1                	li	a5,16
  return 0;
    80003ece:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ed0:	02f71863          	bne	a4,a5,80003f00 <dirlink+0xb2>
}
    80003ed4:	70e2                	ld	ra,56(sp)
    80003ed6:	7442                	ld	s0,48(sp)
    80003ed8:	74a2                	ld	s1,40(sp)
    80003eda:	7902                	ld	s2,32(sp)
    80003edc:	69e2                	ld	s3,24(sp)
    80003ede:	6a42                	ld	s4,16(sp)
    80003ee0:	6121                	addi	sp,sp,64
    80003ee2:	8082                	ret
    iput(ip);
    80003ee4:	00000097          	auipc	ra,0x0
    80003ee8:	a32080e7          	jalr	-1486(ra) # 80003916 <iput>
    return -1;
    80003eec:	557d                	li	a0,-1
    80003eee:	b7dd                	j	80003ed4 <dirlink+0x86>
      panic("dirlink read");
    80003ef0:	00004517          	auipc	a0,0x4
    80003ef4:	70050513          	addi	a0,a0,1792 # 800085f0 <syscalls+0x1c8>
    80003ef8:	ffffc097          	auipc	ra,0xffffc
    80003efc:	64a080e7          	jalr	1610(ra) # 80000542 <panic>
    panic("dirlink");
    80003f00:	00005517          	auipc	a0,0x5
    80003f04:	81050513          	addi	a0,a0,-2032 # 80008710 <syscalls+0x2e8>
    80003f08:	ffffc097          	auipc	ra,0xffffc
    80003f0c:	63a080e7          	jalr	1594(ra) # 80000542 <panic>

0000000080003f10 <namei>:

struct inode*
namei(char *path)
{
    80003f10:	1101                	addi	sp,sp,-32
    80003f12:	ec06                	sd	ra,24(sp)
    80003f14:	e822                	sd	s0,16(sp)
    80003f16:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f18:	fe040613          	addi	a2,s0,-32
    80003f1c:	4581                	li	a1,0
    80003f1e:	00000097          	auipc	ra,0x0
    80003f22:	dd0080e7          	jalr	-560(ra) # 80003cee <namex>
}
    80003f26:	60e2                	ld	ra,24(sp)
    80003f28:	6442                	ld	s0,16(sp)
    80003f2a:	6105                	addi	sp,sp,32
    80003f2c:	8082                	ret

0000000080003f2e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f2e:	1141                	addi	sp,sp,-16
    80003f30:	e406                	sd	ra,8(sp)
    80003f32:	e022                	sd	s0,0(sp)
    80003f34:	0800                	addi	s0,sp,16
    80003f36:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f38:	4585                	li	a1,1
    80003f3a:	00000097          	auipc	ra,0x0
    80003f3e:	db4080e7          	jalr	-588(ra) # 80003cee <namex>
}
    80003f42:	60a2                	ld	ra,8(sp)
    80003f44:	6402                	ld	s0,0(sp)
    80003f46:	0141                	addi	sp,sp,16
    80003f48:	8082                	ret

0000000080003f4a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f4a:	1101                	addi	sp,sp,-32
    80003f4c:	ec06                	sd	ra,24(sp)
    80003f4e:	e822                	sd	s0,16(sp)
    80003f50:	e426                	sd	s1,8(sp)
    80003f52:	e04a                	sd	s2,0(sp)
    80003f54:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f56:	0003e917          	auipc	s2,0x3e
    80003f5a:	9b290913          	addi	s2,s2,-1614 # 80041908 <log>
    80003f5e:	01892583          	lw	a1,24(s2)
    80003f62:	02892503          	lw	a0,40(s2)
    80003f66:	fffff097          	auipc	ra,0xfffff
    80003f6a:	ff4080e7          	jalr	-12(ra) # 80002f5a <bread>
    80003f6e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f70:	02c92683          	lw	a3,44(s2)
    80003f74:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f76:	02d05763          	blez	a3,80003fa4 <write_head+0x5a>
    80003f7a:	0003e797          	auipc	a5,0x3e
    80003f7e:	9be78793          	addi	a5,a5,-1602 # 80041938 <log+0x30>
    80003f82:	05c50713          	addi	a4,a0,92
    80003f86:	36fd                	addiw	a3,a3,-1
    80003f88:	1682                	slli	a3,a3,0x20
    80003f8a:	9281                	srli	a3,a3,0x20
    80003f8c:	068a                	slli	a3,a3,0x2
    80003f8e:	0003e617          	auipc	a2,0x3e
    80003f92:	9ae60613          	addi	a2,a2,-1618 # 8004193c <log+0x34>
    80003f96:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f98:	4390                	lw	a2,0(a5)
    80003f9a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f9c:	0791                	addi	a5,a5,4
    80003f9e:	0711                	addi	a4,a4,4
    80003fa0:	fed79ce3          	bne	a5,a3,80003f98 <write_head+0x4e>
  }
  bwrite(buf);
    80003fa4:	8526                	mv	a0,s1
    80003fa6:	fffff097          	auipc	ra,0xfffff
    80003faa:	0a6080e7          	jalr	166(ra) # 8000304c <bwrite>
  brelse(buf);
    80003fae:	8526                	mv	a0,s1
    80003fb0:	fffff097          	auipc	ra,0xfffff
    80003fb4:	0da080e7          	jalr	218(ra) # 8000308a <brelse>
}
    80003fb8:	60e2                	ld	ra,24(sp)
    80003fba:	6442                	ld	s0,16(sp)
    80003fbc:	64a2                	ld	s1,8(sp)
    80003fbe:	6902                	ld	s2,0(sp)
    80003fc0:	6105                	addi	sp,sp,32
    80003fc2:	8082                	ret

0000000080003fc4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fc4:	0003e797          	auipc	a5,0x3e
    80003fc8:	9707a783          	lw	a5,-1680(a5) # 80041934 <log+0x2c>
    80003fcc:	0af05663          	blez	a5,80004078 <install_trans+0xb4>
{
    80003fd0:	7139                	addi	sp,sp,-64
    80003fd2:	fc06                	sd	ra,56(sp)
    80003fd4:	f822                	sd	s0,48(sp)
    80003fd6:	f426                	sd	s1,40(sp)
    80003fd8:	f04a                	sd	s2,32(sp)
    80003fda:	ec4e                	sd	s3,24(sp)
    80003fdc:	e852                	sd	s4,16(sp)
    80003fde:	e456                	sd	s5,8(sp)
    80003fe0:	0080                	addi	s0,sp,64
    80003fe2:	0003ea97          	auipc	s5,0x3e
    80003fe6:	956a8a93          	addi	s5,s5,-1706 # 80041938 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fea:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fec:	0003e997          	auipc	s3,0x3e
    80003ff0:	91c98993          	addi	s3,s3,-1764 # 80041908 <log>
    80003ff4:	0189a583          	lw	a1,24(s3)
    80003ff8:	014585bb          	addw	a1,a1,s4
    80003ffc:	2585                	addiw	a1,a1,1
    80003ffe:	0289a503          	lw	a0,40(s3)
    80004002:	fffff097          	auipc	ra,0xfffff
    80004006:	f58080e7          	jalr	-168(ra) # 80002f5a <bread>
    8000400a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000400c:	000aa583          	lw	a1,0(s5)
    80004010:	0289a503          	lw	a0,40(s3)
    80004014:	fffff097          	auipc	ra,0xfffff
    80004018:	f46080e7          	jalr	-186(ra) # 80002f5a <bread>
    8000401c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000401e:	40000613          	li	a2,1024
    80004022:	05890593          	addi	a1,s2,88
    80004026:	05850513          	addi	a0,a0,88
    8000402a:	ffffd097          	auipc	ra,0xffffd
    8000402e:	e3c080e7          	jalr	-452(ra) # 80000e66 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004032:	8526                	mv	a0,s1
    80004034:	fffff097          	auipc	ra,0xfffff
    80004038:	018080e7          	jalr	24(ra) # 8000304c <bwrite>
    bunpin(dbuf);
    8000403c:	8526                	mv	a0,s1
    8000403e:	fffff097          	auipc	ra,0xfffff
    80004042:	126080e7          	jalr	294(ra) # 80003164 <bunpin>
    brelse(lbuf);
    80004046:	854a                	mv	a0,s2
    80004048:	fffff097          	auipc	ra,0xfffff
    8000404c:	042080e7          	jalr	66(ra) # 8000308a <brelse>
    brelse(dbuf);
    80004050:	8526                	mv	a0,s1
    80004052:	fffff097          	auipc	ra,0xfffff
    80004056:	038080e7          	jalr	56(ra) # 8000308a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000405a:	2a05                	addiw	s4,s4,1
    8000405c:	0a91                	addi	s5,s5,4
    8000405e:	02c9a783          	lw	a5,44(s3)
    80004062:	f8fa49e3          	blt	s4,a5,80003ff4 <install_trans+0x30>
}
    80004066:	70e2                	ld	ra,56(sp)
    80004068:	7442                	ld	s0,48(sp)
    8000406a:	74a2                	ld	s1,40(sp)
    8000406c:	7902                	ld	s2,32(sp)
    8000406e:	69e2                	ld	s3,24(sp)
    80004070:	6a42                	ld	s4,16(sp)
    80004072:	6aa2                	ld	s5,8(sp)
    80004074:	6121                	addi	sp,sp,64
    80004076:	8082                	ret
    80004078:	8082                	ret

000000008000407a <initlog>:
{
    8000407a:	7179                	addi	sp,sp,-48
    8000407c:	f406                	sd	ra,40(sp)
    8000407e:	f022                	sd	s0,32(sp)
    80004080:	ec26                	sd	s1,24(sp)
    80004082:	e84a                	sd	s2,16(sp)
    80004084:	e44e                	sd	s3,8(sp)
    80004086:	1800                	addi	s0,sp,48
    80004088:	892a                	mv	s2,a0
    8000408a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000408c:	0003e497          	auipc	s1,0x3e
    80004090:	87c48493          	addi	s1,s1,-1924 # 80041908 <log>
    80004094:	00004597          	auipc	a1,0x4
    80004098:	56c58593          	addi	a1,a1,1388 # 80008600 <syscalls+0x1d8>
    8000409c:	8526                	mv	a0,s1
    8000409e:	ffffd097          	auipc	ra,0xffffd
    800040a2:	be0080e7          	jalr	-1056(ra) # 80000c7e <initlock>
  log.start = sb->logstart;
    800040a6:	0149a583          	lw	a1,20(s3)
    800040aa:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040ac:	0109a783          	lw	a5,16(s3)
    800040b0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040b2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040b6:	854a                	mv	a0,s2
    800040b8:	fffff097          	auipc	ra,0xfffff
    800040bc:	ea2080e7          	jalr	-350(ra) # 80002f5a <bread>
  log.lh.n = lh->n;
    800040c0:	4d34                	lw	a3,88(a0)
    800040c2:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040c4:	02d05563          	blez	a3,800040ee <initlog+0x74>
    800040c8:	05c50793          	addi	a5,a0,92
    800040cc:	0003e717          	auipc	a4,0x3e
    800040d0:	86c70713          	addi	a4,a4,-1940 # 80041938 <log+0x30>
    800040d4:	36fd                	addiw	a3,a3,-1
    800040d6:	1682                	slli	a3,a3,0x20
    800040d8:	9281                	srli	a3,a3,0x20
    800040da:	068a                	slli	a3,a3,0x2
    800040dc:	06050613          	addi	a2,a0,96
    800040e0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800040e2:	4390                	lw	a2,0(a5)
    800040e4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040e6:	0791                	addi	a5,a5,4
    800040e8:	0711                	addi	a4,a4,4
    800040ea:	fed79ce3          	bne	a5,a3,800040e2 <initlog+0x68>
  brelse(buf);
    800040ee:	fffff097          	auipc	ra,0xfffff
    800040f2:	f9c080e7          	jalr	-100(ra) # 8000308a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800040f6:	00000097          	auipc	ra,0x0
    800040fa:	ece080e7          	jalr	-306(ra) # 80003fc4 <install_trans>
  log.lh.n = 0;
    800040fe:	0003e797          	auipc	a5,0x3e
    80004102:	8207ab23          	sw	zero,-1994(a5) # 80041934 <log+0x2c>
  write_head(); // clear the log
    80004106:	00000097          	auipc	ra,0x0
    8000410a:	e44080e7          	jalr	-444(ra) # 80003f4a <write_head>
}
    8000410e:	70a2                	ld	ra,40(sp)
    80004110:	7402                	ld	s0,32(sp)
    80004112:	64e2                	ld	s1,24(sp)
    80004114:	6942                	ld	s2,16(sp)
    80004116:	69a2                	ld	s3,8(sp)
    80004118:	6145                	addi	sp,sp,48
    8000411a:	8082                	ret

000000008000411c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000411c:	1101                	addi	sp,sp,-32
    8000411e:	ec06                	sd	ra,24(sp)
    80004120:	e822                	sd	s0,16(sp)
    80004122:	e426                	sd	s1,8(sp)
    80004124:	e04a                	sd	s2,0(sp)
    80004126:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004128:	0003d517          	auipc	a0,0x3d
    8000412c:	7e050513          	addi	a0,a0,2016 # 80041908 <log>
    80004130:	ffffd097          	auipc	ra,0xffffd
    80004134:	bde080e7          	jalr	-1058(ra) # 80000d0e <acquire>
  while(1){
    if(log.committing){
    80004138:	0003d497          	auipc	s1,0x3d
    8000413c:	7d048493          	addi	s1,s1,2000 # 80041908 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004140:	4979                	li	s2,30
    80004142:	a039                	j	80004150 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004144:	85a6                	mv	a1,s1
    80004146:	8526                	mv	a0,s1
    80004148:	ffffe097          	auipc	ra,0xffffe
    8000414c:	1d2080e7          	jalr	466(ra) # 8000231a <sleep>
    if(log.committing){
    80004150:	50dc                	lw	a5,36(s1)
    80004152:	fbed                	bnez	a5,80004144 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004154:	509c                	lw	a5,32(s1)
    80004156:	0017871b          	addiw	a4,a5,1
    8000415a:	0007069b          	sext.w	a3,a4
    8000415e:	0027179b          	slliw	a5,a4,0x2
    80004162:	9fb9                	addw	a5,a5,a4
    80004164:	0017979b          	slliw	a5,a5,0x1
    80004168:	54d8                	lw	a4,44(s1)
    8000416a:	9fb9                	addw	a5,a5,a4
    8000416c:	00f95963          	bge	s2,a5,8000417e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004170:	85a6                	mv	a1,s1
    80004172:	8526                	mv	a0,s1
    80004174:	ffffe097          	auipc	ra,0xffffe
    80004178:	1a6080e7          	jalr	422(ra) # 8000231a <sleep>
    8000417c:	bfd1                	j	80004150 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000417e:	0003d517          	auipc	a0,0x3d
    80004182:	78a50513          	addi	a0,a0,1930 # 80041908 <log>
    80004186:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004188:	ffffd097          	auipc	ra,0xffffd
    8000418c:	c3a080e7          	jalr	-966(ra) # 80000dc2 <release>
      break;
    }
  }
}
    80004190:	60e2                	ld	ra,24(sp)
    80004192:	6442                	ld	s0,16(sp)
    80004194:	64a2                	ld	s1,8(sp)
    80004196:	6902                	ld	s2,0(sp)
    80004198:	6105                	addi	sp,sp,32
    8000419a:	8082                	ret

000000008000419c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000419c:	7139                	addi	sp,sp,-64
    8000419e:	fc06                	sd	ra,56(sp)
    800041a0:	f822                	sd	s0,48(sp)
    800041a2:	f426                	sd	s1,40(sp)
    800041a4:	f04a                	sd	s2,32(sp)
    800041a6:	ec4e                	sd	s3,24(sp)
    800041a8:	e852                	sd	s4,16(sp)
    800041aa:	e456                	sd	s5,8(sp)
    800041ac:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041ae:	0003d497          	auipc	s1,0x3d
    800041b2:	75a48493          	addi	s1,s1,1882 # 80041908 <log>
    800041b6:	8526                	mv	a0,s1
    800041b8:	ffffd097          	auipc	ra,0xffffd
    800041bc:	b56080e7          	jalr	-1194(ra) # 80000d0e <acquire>
  log.outstanding -= 1;
    800041c0:	509c                	lw	a5,32(s1)
    800041c2:	37fd                	addiw	a5,a5,-1
    800041c4:	0007891b          	sext.w	s2,a5
    800041c8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041ca:	50dc                	lw	a5,36(s1)
    800041cc:	e7b9                	bnez	a5,8000421a <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800041ce:	04091e63          	bnez	s2,8000422a <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800041d2:	0003d497          	auipc	s1,0x3d
    800041d6:	73648493          	addi	s1,s1,1846 # 80041908 <log>
    800041da:	4785                	li	a5,1
    800041dc:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041de:	8526                	mv	a0,s1
    800041e0:	ffffd097          	auipc	ra,0xffffd
    800041e4:	be2080e7          	jalr	-1054(ra) # 80000dc2 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041e8:	54dc                	lw	a5,44(s1)
    800041ea:	06f04763          	bgtz	a5,80004258 <end_op+0xbc>
    acquire(&log.lock);
    800041ee:	0003d497          	auipc	s1,0x3d
    800041f2:	71a48493          	addi	s1,s1,1818 # 80041908 <log>
    800041f6:	8526                	mv	a0,s1
    800041f8:	ffffd097          	auipc	ra,0xffffd
    800041fc:	b16080e7          	jalr	-1258(ra) # 80000d0e <acquire>
    log.committing = 0;
    80004200:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004204:	8526                	mv	a0,s1
    80004206:	ffffe097          	auipc	ra,0xffffe
    8000420a:	294080e7          	jalr	660(ra) # 8000249a <wakeup>
    release(&log.lock);
    8000420e:	8526                	mv	a0,s1
    80004210:	ffffd097          	auipc	ra,0xffffd
    80004214:	bb2080e7          	jalr	-1102(ra) # 80000dc2 <release>
}
    80004218:	a03d                	j	80004246 <end_op+0xaa>
    panic("log.committing");
    8000421a:	00004517          	auipc	a0,0x4
    8000421e:	3ee50513          	addi	a0,a0,1006 # 80008608 <syscalls+0x1e0>
    80004222:	ffffc097          	auipc	ra,0xffffc
    80004226:	320080e7          	jalr	800(ra) # 80000542 <panic>
    wakeup(&log);
    8000422a:	0003d497          	auipc	s1,0x3d
    8000422e:	6de48493          	addi	s1,s1,1758 # 80041908 <log>
    80004232:	8526                	mv	a0,s1
    80004234:	ffffe097          	auipc	ra,0xffffe
    80004238:	266080e7          	jalr	614(ra) # 8000249a <wakeup>
  release(&log.lock);
    8000423c:	8526                	mv	a0,s1
    8000423e:	ffffd097          	auipc	ra,0xffffd
    80004242:	b84080e7          	jalr	-1148(ra) # 80000dc2 <release>
}
    80004246:	70e2                	ld	ra,56(sp)
    80004248:	7442                	ld	s0,48(sp)
    8000424a:	74a2                	ld	s1,40(sp)
    8000424c:	7902                	ld	s2,32(sp)
    8000424e:	69e2                	ld	s3,24(sp)
    80004250:	6a42                	ld	s4,16(sp)
    80004252:	6aa2                	ld	s5,8(sp)
    80004254:	6121                	addi	sp,sp,64
    80004256:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004258:	0003da97          	auipc	s5,0x3d
    8000425c:	6e0a8a93          	addi	s5,s5,1760 # 80041938 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004260:	0003da17          	auipc	s4,0x3d
    80004264:	6a8a0a13          	addi	s4,s4,1704 # 80041908 <log>
    80004268:	018a2583          	lw	a1,24(s4)
    8000426c:	012585bb          	addw	a1,a1,s2
    80004270:	2585                	addiw	a1,a1,1
    80004272:	028a2503          	lw	a0,40(s4)
    80004276:	fffff097          	auipc	ra,0xfffff
    8000427a:	ce4080e7          	jalr	-796(ra) # 80002f5a <bread>
    8000427e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004280:	000aa583          	lw	a1,0(s5)
    80004284:	028a2503          	lw	a0,40(s4)
    80004288:	fffff097          	auipc	ra,0xfffff
    8000428c:	cd2080e7          	jalr	-814(ra) # 80002f5a <bread>
    80004290:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004292:	40000613          	li	a2,1024
    80004296:	05850593          	addi	a1,a0,88
    8000429a:	05848513          	addi	a0,s1,88
    8000429e:	ffffd097          	auipc	ra,0xffffd
    800042a2:	bc8080e7          	jalr	-1080(ra) # 80000e66 <memmove>
    bwrite(to);  // write the log
    800042a6:	8526                	mv	a0,s1
    800042a8:	fffff097          	auipc	ra,0xfffff
    800042ac:	da4080e7          	jalr	-604(ra) # 8000304c <bwrite>
    brelse(from);
    800042b0:	854e                	mv	a0,s3
    800042b2:	fffff097          	auipc	ra,0xfffff
    800042b6:	dd8080e7          	jalr	-552(ra) # 8000308a <brelse>
    brelse(to);
    800042ba:	8526                	mv	a0,s1
    800042bc:	fffff097          	auipc	ra,0xfffff
    800042c0:	dce080e7          	jalr	-562(ra) # 8000308a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042c4:	2905                	addiw	s2,s2,1
    800042c6:	0a91                	addi	s5,s5,4
    800042c8:	02ca2783          	lw	a5,44(s4)
    800042cc:	f8f94ee3          	blt	s2,a5,80004268 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042d0:	00000097          	auipc	ra,0x0
    800042d4:	c7a080e7          	jalr	-902(ra) # 80003f4a <write_head>
    install_trans(); // Now install writes to home locations
    800042d8:	00000097          	auipc	ra,0x0
    800042dc:	cec080e7          	jalr	-788(ra) # 80003fc4 <install_trans>
    log.lh.n = 0;
    800042e0:	0003d797          	auipc	a5,0x3d
    800042e4:	6407aa23          	sw	zero,1620(a5) # 80041934 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042e8:	00000097          	auipc	ra,0x0
    800042ec:	c62080e7          	jalr	-926(ra) # 80003f4a <write_head>
    800042f0:	bdfd                	j	800041ee <end_op+0x52>

00000000800042f2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042f2:	1101                	addi	sp,sp,-32
    800042f4:	ec06                	sd	ra,24(sp)
    800042f6:	e822                	sd	s0,16(sp)
    800042f8:	e426                	sd	s1,8(sp)
    800042fa:	e04a                	sd	s2,0(sp)
    800042fc:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042fe:	0003d717          	auipc	a4,0x3d
    80004302:	63672703          	lw	a4,1590(a4) # 80041934 <log+0x2c>
    80004306:	47f5                	li	a5,29
    80004308:	08e7c063          	blt	a5,a4,80004388 <log_write+0x96>
    8000430c:	84aa                	mv	s1,a0
    8000430e:	0003d797          	auipc	a5,0x3d
    80004312:	6167a783          	lw	a5,1558(a5) # 80041924 <log+0x1c>
    80004316:	37fd                	addiw	a5,a5,-1
    80004318:	06f75863          	bge	a4,a5,80004388 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000431c:	0003d797          	auipc	a5,0x3d
    80004320:	60c7a783          	lw	a5,1548(a5) # 80041928 <log+0x20>
    80004324:	06f05a63          	blez	a5,80004398 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004328:	0003d917          	auipc	s2,0x3d
    8000432c:	5e090913          	addi	s2,s2,1504 # 80041908 <log>
    80004330:	854a                	mv	a0,s2
    80004332:	ffffd097          	auipc	ra,0xffffd
    80004336:	9dc080e7          	jalr	-1572(ra) # 80000d0e <acquire>
  for (i = 0; i < log.lh.n; i++) {
    8000433a:	02c92603          	lw	a2,44(s2)
    8000433e:	06c05563          	blez	a2,800043a8 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004342:	44cc                	lw	a1,12(s1)
    80004344:	0003d717          	auipc	a4,0x3d
    80004348:	5f470713          	addi	a4,a4,1524 # 80041938 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000434c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000434e:	4314                	lw	a3,0(a4)
    80004350:	04b68d63          	beq	a3,a1,800043aa <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004354:	2785                	addiw	a5,a5,1
    80004356:	0711                	addi	a4,a4,4
    80004358:	fec79be3          	bne	a5,a2,8000434e <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000435c:	0621                	addi	a2,a2,8
    8000435e:	060a                	slli	a2,a2,0x2
    80004360:	0003d797          	auipc	a5,0x3d
    80004364:	5a878793          	addi	a5,a5,1448 # 80041908 <log>
    80004368:	963e                	add	a2,a2,a5
    8000436a:	44dc                	lw	a5,12(s1)
    8000436c:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000436e:	8526                	mv	a0,s1
    80004370:	fffff097          	auipc	ra,0xfffff
    80004374:	db8080e7          	jalr	-584(ra) # 80003128 <bpin>
    log.lh.n++;
    80004378:	0003d717          	auipc	a4,0x3d
    8000437c:	59070713          	addi	a4,a4,1424 # 80041908 <log>
    80004380:	575c                	lw	a5,44(a4)
    80004382:	2785                	addiw	a5,a5,1
    80004384:	d75c                	sw	a5,44(a4)
    80004386:	a83d                	j	800043c4 <log_write+0xd2>
    panic("too big a transaction");
    80004388:	00004517          	auipc	a0,0x4
    8000438c:	29050513          	addi	a0,a0,656 # 80008618 <syscalls+0x1f0>
    80004390:	ffffc097          	auipc	ra,0xffffc
    80004394:	1b2080e7          	jalr	434(ra) # 80000542 <panic>
    panic("log_write outside of trans");
    80004398:	00004517          	auipc	a0,0x4
    8000439c:	29850513          	addi	a0,a0,664 # 80008630 <syscalls+0x208>
    800043a0:	ffffc097          	auipc	ra,0xffffc
    800043a4:	1a2080e7          	jalr	418(ra) # 80000542 <panic>
  for (i = 0; i < log.lh.n; i++) {
    800043a8:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    800043aa:	00878713          	addi	a4,a5,8
    800043ae:	00271693          	slli	a3,a4,0x2
    800043b2:	0003d717          	auipc	a4,0x3d
    800043b6:	55670713          	addi	a4,a4,1366 # 80041908 <log>
    800043ba:	9736                	add	a4,a4,a3
    800043bc:	44d4                	lw	a3,12(s1)
    800043be:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043c0:	faf607e3          	beq	a2,a5,8000436e <log_write+0x7c>
  }
  release(&log.lock);
    800043c4:	0003d517          	auipc	a0,0x3d
    800043c8:	54450513          	addi	a0,a0,1348 # 80041908 <log>
    800043cc:	ffffd097          	auipc	ra,0xffffd
    800043d0:	9f6080e7          	jalr	-1546(ra) # 80000dc2 <release>
}
    800043d4:	60e2                	ld	ra,24(sp)
    800043d6:	6442                	ld	s0,16(sp)
    800043d8:	64a2                	ld	s1,8(sp)
    800043da:	6902                	ld	s2,0(sp)
    800043dc:	6105                	addi	sp,sp,32
    800043de:	8082                	ret

00000000800043e0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043e0:	1101                	addi	sp,sp,-32
    800043e2:	ec06                	sd	ra,24(sp)
    800043e4:	e822                	sd	s0,16(sp)
    800043e6:	e426                	sd	s1,8(sp)
    800043e8:	e04a                	sd	s2,0(sp)
    800043ea:	1000                	addi	s0,sp,32
    800043ec:	84aa                	mv	s1,a0
    800043ee:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043f0:	00004597          	auipc	a1,0x4
    800043f4:	26058593          	addi	a1,a1,608 # 80008650 <syscalls+0x228>
    800043f8:	0521                	addi	a0,a0,8
    800043fa:	ffffd097          	auipc	ra,0xffffd
    800043fe:	884080e7          	jalr	-1916(ra) # 80000c7e <initlock>
  lk->name = name;
    80004402:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004406:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000440a:	0204a423          	sw	zero,40(s1)
}
    8000440e:	60e2                	ld	ra,24(sp)
    80004410:	6442                	ld	s0,16(sp)
    80004412:	64a2                	ld	s1,8(sp)
    80004414:	6902                	ld	s2,0(sp)
    80004416:	6105                	addi	sp,sp,32
    80004418:	8082                	ret

000000008000441a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000441a:	1101                	addi	sp,sp,-32
    8000441c:	ec06                	sd	ra,24(sp)
    8000441e:	e822                	sd	s0,16(sp)
    80004420:	e426                	sd	s1,8(sp)
    80004422:	e04a                	sd	s2,0(sp)
    80004424:	1000                	addi	s0,sp,32
    80004426:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004428:	00850913          	addi	s2,a0,8
    8000442c:	854a                	mv	a0,s2
    8000442e:	ffffd097          	auipc	ra,0xffffd
    80004432:	8e0080e7          	jalr	-1824(ra) # 80000d0e <acquire>
  while (lk->locked) {
    80004436:	409c                	lw	a5,0(s1)
    80004438:	cb89                	beqz	a5,8000444a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000443a:	85ca                	mv	a1,s2
    8000443c:	8526                	mv	a0,s1
    8000443e:	ffffe097          	auipc	ra,0xffffe
    80004442:	edc080e7          	jalr	-292(ra) # 8000231a <sleep>
  while (lk->locked) {
    80004446:	409c                	lw	a5,0(s1)
    80004448:	fbed                	bnez	a5,8000443a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000444a:	4785                	li	a5,1
    8000444c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000444e:	ffffd097          	auipc	ra,0xffffd
    80004452:	6b8080e7          	jalr	1720(ra) # 80001b06 <myproc>
    80004456:	5d1c                	lw	a5,56(a0)
    80004458:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000445a:	854a                	mv	a0,s2
    8000445c:	ffffd097          	auipc	ra,0xffffd
    80004460:	966080e7          	jalr	-1690(ra) # 80000dc2 <release>
}
    80004464:	60e2                	ld	ra,24(sp)
    80004466:	6442                	ld	s0,16(sp)
    80004468:	64a2                	ld	s1,8(sp)
    8000446a:	6902                	ld	s2,0(sp)
    8000446c:	6105                	addi	sp,sp,32
    8000446e:	8082                	ret

0000000080004470 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004470:	1101                	addi	sp,sp,-32
    80004472:	ec06                	sd	ra,24(sp)
    80004474:	e822                	sd	s0,16(sp)
    80004476:	e426                	sd	s1,8(sp)
    80004478:	e04a                	sd	s2,0(sp)
    8000447a:	1000                	addi	s0,sp,32
    8000447c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000447e:	00850913          	addi	s2,a0,8
    80004482:	854a                	mv	a0,s2
    80004484:	ffffd097          	auipc	ra,0xffffd
    80004488:	88a080e7          	jalr	-1910(ra) # 80000d0e <acquire>
  lk->locked = 0;
    8000448c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004490:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004494:	8526                	mv	a0,s1
    80004496:	ffffe097          	auipc	ra,0xffffe
    8000449a:	004080e7          	jalr	4(ra) # 8000249a <wakeup>
  release(&lk->lk);
    8000449e:	854a                	mv	a0,s2
    800044a0:	ffffd097          	auipc	ra,0xffffd
    800044a4:	922080e7          	jalr	-1758(ra) # 80000dc2 <release>
}
    800044a8:	60e2                	ld	ra,24(sp)
    800044aa:	6442                	ld	s0,16(sp)
    800044ac:	64a2                	ld	s1,8(sp)
    800044ae:	6902                	ld	s2,0(sp)
    800044b0:	6105                	addi	sp,sp,32
    800044b2:	8082                	ret

00000000800044b4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044b4:	7179                	addi	sp,sp,-48
    800044b6:	f406                	sd	ra,40(sp)
    800044b8:	f022                	sd	s0,32(sp)
    800044ba:	ec26                	sd	s1,24(sp)
    800044bc:	e84a                	sd	s2,16(sp)
    800044be:	e44e                	sd	s3,8(sp)
    800044c0:	1800                	addi	s0,sp,48
    800044c2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044c4:	00850913          	addi	s2,a0,8
    800044c8:	854a                	mv	a0,s2
    800044ca:	ffffd097          	auipc	ra,0xffffd
    800044ce:	844080e7          	jalr	-1980(ra) # 80000d0e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044d2:	409c                	lw	a5,0(s1)
    800044d4:	ef99                	bnez	a5,800044f2 <holdingsleep+0x3e>
    800044d6:	4481                	li	s1,0
  release(&lk->lk);
    800044d8:	854a                	mv	a0,s2
    800044da:	ffffd097          	auipc	ra,0xffffd
    800044de:	8e8080e7          	jalr	-1816(ra) # 80000dc2 <release>
  return r;
}
    800044e2:	8526                	mv	a0,s1
    800044e4:	70a2                	ld	ra,40(sp)
    800044e6:	7402                	ld	s0,32(sp)
    800044e8:	64e2                	ld	s1,24(sp)
    800044ea:	6942                	ld	s2,16(sp)
    800044ec:	69a2                	ld	s3,8(sp)
    800044ee:	6145                	addi	sp,sp,48
    800044f0:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044f2:	0284a983          	lw	s3,40(s1)
    800044f6:	ffffd097          	auipc	ra,0xffffd
    800044fa:	610080e7          	jalr	1552(ra) # 80001b06 <myproc>
    800044fe:	5d04                	lw	s1,56(a0)
    80004500:	413484b3          	sub	s1,s1,s3
    80004504:	0014b493          	seqz	s1,s1
    80004508:	bfc1                	j	800044d8 <holdingsleep+0x24>

000000008000450a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000450a:	1141                	addi	sp,sp,-16
    8000450c:	e406                	sd	ra,8(sp)
    8000450e:	e022                	sd	s0,0(sp)
    80004510:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004512:	00004597          	auipc	a1,0x4
    80004516:	14e58593          	addi	a1,a1,334 # 80008660 <syscalls+0x238>
    8000451a:	0003d517          	auipc	a0,0x3d
    8000451e:	53650513          	addi	a0,a0,1334 # 80041a50 <ftable>
    80004522:	ffffc097          	auipc	ra,0xffffc
    80004526:	75c080e7          	jalr	1884(ra) # 80000c7e <initlock>
}
    8000452a:	60a2                	ld	ra,8(sp)
    8000452c:	6402                	ld	s0,0(sp)
    8000452e:	0141                	addi	sp,sp,16
    80004530:	8082                	ret

0000000080004532 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004532:	1101                	addi	sp,sp,-32
    80004534:	ec06                	sd	ra,24(sp)
    80004536:	e822                	sd	s0,16(sp)
    80004538:	e426                	sd	s1,8(sp)
    8000453a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000453c:	0003d517          	auipc	a0,0x3d
    80004540:	51450513          	addi	a0,a0,1300 # 80041a50 <ftable>
    80004544:	ffffc097          	auipc	ra,0xffffc
    80004548:	7ca080e7          	jalr	1994(ra) # 80000d0e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000454c:	0003d497          	auipc	s1,0x3d
    80004550:	51c48493          	addi	s1,s1,1308 # 80041a68 <ftable+0x18>
    80004554:	0003e717          	auipc	a4,0x3e
    80004558:	4b470713          	addi	a4,a4,1204 # 80042a08 <ftable+0xfb8>
    if(f->ref == 0){
    8000455c:	40dc                	lw	a5,4(s1)
    8000455e:	cf99                	beqz	a5,8000457c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004560:	02848493          	addi	s1,s1,40
    80004564:	fee49ce3          	bne	s1,a4,8000455c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004568:	0003d517          	auipc	a0,0x3d
    8000456c:	4e850513          	addi	a0,a0,1256 # 80041a50 <ftable>
    80004570:	ffffd097          	auipc	ra,0xffffd
    80004574:	852080e7          	jalr	-1966(ra) # 80000dc2 <release>
  return 0;
    80004578:	4481                	li	s1,0
    8000457a:	a819                	j	80004590 <filealloc+0x5e>
      f->ref = 1;
    8000457c:	4785                	li	a5,1
    8000457e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004580:	0003d517          	auipc	a0,0x3d
    80004584:	4d050513          	addi	a0,a0,1232 # 80041a50 <ftable>
    80004588:	ffffd097          	auipc	ra,0xffffd
    8000458c:	83a080e7          	jalr	-1990(ra) # 80000dc2 <release>
}
    80004590:	8526                	mv	a0,s1
    80004592:	60e2                	ld	ra,24(sp)
    80004594:	6442                	ld	s0,16(sp)
    80004596:	64a2                	ld	s1,8(sp)
    80004598:	6105                	addi	sp,sp,32
    8000459a:	8082                	ret

000000008000459c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000459c:	1101                	addi	sp,sp,-32
    8000459e:	ec06                	sd	ra,24(sp)
    800045a0:	e822                	sd	s0,16(sp)
    800045a2:	e426                	sd	s1,8(sp)
    800045a4:	1000                	addi	s0,sp,32
    800045a6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045a8:	0003d517          	auipc	a0,0x3d
    800045ac:	4a850513          	addi	a0,a0,1192 # 80041a50 <ftable>
    800045b0:	ffffc097          	auipc	ra,0xffffc
    800045b4:	75e080e7          	jalr	1886(ra) # 80000d0e <acquire>
  if(f->ref < 1)
    800045b8:	40dc                	lw	a5,4(s1)
    800045ba:	02f05263          	blez	a5,800045de <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045be:	2785                	addiw	a5,a5,1
    800045c0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045c2:	0003d517          	auipc	a0,0x3d
    800045c6:	48e50513          	addi	a0,a0,1166 # 80041a50 <ftable>
    800045ca:	ffffc097          	auipc	ra,0xffffc
    800045ce:	7f8080e7          	jalr	2040(ra) # 80000dc2 <release>
  return f;
}
    800045d2:	8526                	mv	a0,s1
    800045d4:	60e2                	ld	ra,24(sp)
    800045d6:	6442                	ld	s0,16(sp)
    800045d8:	64a2                	ld	s1,8(sp)
    800045da:	6105                	addi	sp,sp,32
    800045dc:	8082                	ret
    panic("filedup");
    800045de:	00004517          	auipc	a0,0x4
    800045e2:	08a50513          	addi	a0,a0,138 # 80008668 <syscalls+0x240>
    800045e6:	ffffc097          	auipc	ra,0xffffc
    800045ea:	f5c080e7          	jalr	-164(ra) # 80000542 <panic>

00000000800045ee <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045ee:	7139                	addi	sp,sp,-64
    800045f0:	fc06                	sd	ra,56(sp)
    800045f2:	f822                	sd	s0,48(sp)
    800045f4:	f426                	sd	s1,40(sp)
    800045f6:	f04a                	sd	s2,32(sp)
    800045f8:	ec4e                	sd	s3,24(sp)
    800045fa:	e852                	sd	s4,16(sp)
    800045fc:	e456                	sd	s5,8(sp)
    800045fe:	0080                	addi	s0,sp,64
    80004600:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004602:	0003d517          	auipc	a0,0x3d
    80004606:	44e50513          	addi	a0,a0,1102 # 80041a50 <ftable>
    8000460a:	ffffc097          	auipc	ra,0xffffc
    8000460e:	704080e7          	jalr	1796(ra) # 80000d0e <acquire>
  if(f->ref < 1)
    80004612:	40dc                	lw	a5,4(s1)
    80004614:	06f05163          	blez	a5,80004676 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004618:	37fd                	addiw	a5,a5,-1
    8000461a:	0007871b          	sext.w	a4,a5
    8000461e:	c0dc                	sw	a5,4(s1)
    80004620:	06e04363          	bgtz	a4,80004686 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004624:	0004a903          	lw	s2,0(s1)
    80004628:	0094ca83          	lbu	s5,9(s1)
    8000462c:	0104ba03          	ld	s4,16(s1)
    80004630:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004634:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004638:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000463c:	0003d517          	auipc	a0,0x3d
    80004640:	41450513          	addi	a0,a0,1044 # 80041a50 <ftable>
    80004644:	ffffc097          	auipc	ra,0xffffc
    80004648:	77e080e7          	jalr	1918(ra) # 80000dc2 <release>

  if(ff.type == FD_PIPE){
    8000464c:	4785                	li	a5,1
    8000464e:	04f90d63          	beq	s2,a5,800046a8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004652:	3979                	addiw	s2,s2,-2
    80004654:	4785                	li	a5,1
    80004656:	0527e063          	bltu	a5,s2,80004696 <fileclose+0xa8>
    begin_op();
    8000465a:	00000097          	auipc	ra,0x0
    8000465e:	ac2080e7          	jalr	-1342(ra) # 8000411c <begin_op>
    iput(ff.ip);
    80004662:	854e                	mv	a0,s3
    80004664:	fffff097          	auipc	ra,0xfffff
    80004668:	2b2080e7          	jalr	690(ra) # 80003916 <iput>
    end_op();
    8000466c:	00000097          	auipc	ra,0x0
    80004670:	b30080e7          	jalr	-1232(ra) # 8000419c <end_op>
    80004674:	a00d                	j	80004696 <fileclose+0xa8>
    panic("fileclose");
    80004676:	00004517          	auipc	a0,0x4
    8000467a:	ffa50513          	addi	a0,a0,-6 # 80008670 <syscalls+0x248>
    8000467e:	ffffc097          	auipc	ra,0xffffc
    80004682:	ec4080e7          	jalr	-316(ra) # 80000542 <panic>
    release(&ftable.lock);
    80004686:	0003d517          	auipc	a0,0x3d
    8000468a:	3ca50513          	addi	a0,a0,970 # 80041a50 <ftable>
    8000468e:	ffffc097          	auipc	ra,0xffffc
    80004692:	734080e7          	jalr	1844(ra) # 80000dc2 <release>
  }
}
    80004696:	70e2                	ld	ra,56(sp)
    80004698:	7442                	ld	s0,48(sp)
    8000469a:	74a2                	ld	s1,40(sp)
    8000469c:	7902                	ld	s2,32(sp)
    8000469e:	69e2                	ld	s3,24(sp)
    800046a0:	6a42                	ld	s4,16(sp)
    800046a2:	6aa2                	ld	s5,8(sp)
    800046a4:	6121                	addi	sp,sp,64
    800046a6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046a8:	85d6                	mv	a1,s5
    800046aa:	8552                	mv	a0,s4
    800046ac:	00000097          	auipc	ra,0x0
    800046b0:	372080e7          	jalr	882(ra) # 80004a1e <pipeclose>
    800046b4:	b7cd                	j	80004696 <fileclose+0xa8>

00000000800046b6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046b6:	715d                	addi	sp,sp,-80
    800046b8:	e486                	sd	ra,72(sp)
    800046ba:	e0a2                	sd	s0,64(sp)
    800046bc:	fc26                	sd	s1,56(sp)
    800046be:	f84a                	sd	s2,48(sp)
    800046c0:	f44e                	sd	s3,40(sp)
    800046c2:	0880                	addi	s0,sp,80
    800046c4:	84aa                	mv	s1,a0
    800046c6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046c8:	ffffd097          	auipc	ra,0xffffd
    800046cc:	43e080e7          	jalr	1086(ra) # 80001b06 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046d0:	409c                	lw	a5,0(s1)
    800046d2:	37f9                	addiw	a5,a5,-2
    800046d4:	4705                	li	a4,1
    800046d6:	04f76763          	bltu	a4,a5,80004724 <filestat+0x6e>
    800046da:	892a                	mv	s2,a0
    ilock(f->ip);
    800046dc:	6c88                	ld	a0,24(s1)
    800046de:	fffff097          	auipc	ra,0xfffff
    800046e2:	07e080e7          	jalr	126(ra) # 8000375c <ilock>
    stati(f->ip, &st);
    800046e6:	fb840593          	addi	a1,s0,-72
    800046ea:	6c88                	ld	a0,24(s1)
    800046ec:	fffff097          	auipc	ra,0xfffff
    800046f0:	2fa080e7          	jalr	762(ra) # 800039e6 <stati>
    iunlock(f->ip);
    800046f4:	6c88                	ld	a0,24(s1)
    800046f6:	fffff097          	auipc	ra,0xfffff
    800046fa:	128080e7          	jalr	296(ra) # 8000381e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046fe:	46e1                	li	a3,24
    80004700:	fb840613          	addi	a2,s0,-72
    80004704:	85ce                	mv	a1,s3
    80004706:	05093503          	ld	a0,80(s2)
    8000470a:	ffffd097          	auipc	ra,0xffffd
    8000470e:	0be080e7          	jalr	190(ra) # 800017c8 <copyout>
    80004712:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004716:	60a6                	ld	ra,72(sp)
    80004718:	6406                	ld	s0,64(sp)
    8000471a:	74e2                	ld	s1,56(sp)
    8000471c:	7942                	ld	s2,48(sp)
    8000471e:	79a2                	ld	s3,40(sp)
    80004720:	6161                	addi	sp,sp,80
    80004722:	8082                	ret
  return -1;
    80004724:	557d                	li	a0,-1
    80004726:	bfc5                	j	80004716 <filestat+0x60>

0000000080004728 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004728:	7179                	addi	sp,sp,-48
    8000472a:	f406                	sd	ra,40(sp)
    8000472c:	f022                	sd	s0,32(sp)
    8000472e:	ec26                	sd	s1,24(sp)
    80004730:	e84a                	sd	s2,16(sp)
    80004732:	e44e                	sd	s3,8(sp)
    80004734:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004736:	00854783          	lbu	a5,8(a0)
    8000473a:	c3d5                	beqz	a5,800047de <fileread+0xb6>
    8000473c:	84aa                	mv	s1,a0
    8000473e:	89ae                	mv	s3,a1
    80004740:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004742:	411c                	lw	a5,0(a0)
    80004744:	4705                	li	a4,1
    80004746:	04e78963          	beq	a5,a4,80004798 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000474a:	470d                	li	a4,3
    8000474c:	04e78d63          	beq	a5,a4,800047a6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004750:	4709                	li	a4,2
    80004752:	06e79e63          	bne	a5,a4,800047ce <fileread+0xa6>
    ilock(f->ip);
    80004756:	6d08                	ld	a0,24(a0)
    80004758:	fffff097          	auipc	ra,0xfffff
    8000475c:	004080e7          	jalr	4(ra) # 8000375c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004760:	874a                	mv	a4,s2
    80004762:	5094                	lw	a3,32(s1)
    80004764:	864e                	mv	a2,s3
    80004766:	4585                	li	a1,1
    80004768:	6c88                	ld	a0,24(s1)
    8000476a:	fffff097          	auipc	ra,0xfffff
    8000476e:	2a6080e7          	jalr	678(ra) # 80003a10 <readi>
    80004772:	892a                	mv	s2,a0
    80004774:	00a05563          	blez	a0,8000477e <fileread+0x56>
      f->off += r;
    80004778:	509c                	lw	a5,32(s1)
    8000477a:	9fa9                	addw	a5,a5,a0
    8000477c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000477e:	6c88                	ld	a0,24(s1)
    80004780:	fffff097          	auipc	ra,0xfffff
    80004784:	09e080e7          	jalr	158(ra) # 8000381e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004788:	854a                	mv	a0,s2
    8000478a:	70a2                	ld	ra,40(sp)
    8000478c:	7402                	ld	s0,32(sp)
    8000478e:	64e2                	ld	s1,24(sp)
    80004790:	6942                	ld	s2,16(sp)
    80004792:	69a2                	ld	s3,8(sp)
    80004794:	6145                	addi	sp,sp,48
    80004796:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004798:	6908                	ld	a0,16(a0)
    8000479a:	00000097          	auipc	ra,0x0
    8000479e:	3f4080e7          	jalr	1012(ra) # 80004b8e <piperead>
    800047a2:	892a                	mv	s2,a0
    800047a4:	b7d5                	j	80004788 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047a6:	02451783          	lh	a5,36(a0)
    800047aa:	03079693          	slli	a3,a5,0x30
    800047ae:	92c1                	srli	a3,a3,0x30
    800047b0:	4725                	li	a4,9
    800047b2:	02d76863          	bltu	a4,a3,800047e2 <fileread+0xba>
    800047b6:	0792                	slli	a5,a5,0x4
    800047b8:	0003d717          	auipc	a4,0x3d
    800047bc:	1f870713          	addi	a4,a4,504 # 800419b0 <devsw>
    800047c0:	97ba                	add	a5,a5,a4
    800047c2:	639c                	ld	a5,0(a5)
    800047c4:	c38d                	beqz	a5,800047e6 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047c6:	4505                	li	a0,1
    800047c8:	9782                	jalr	a5
    800047ca:	892a                	mv	s2,a0
    800047cc:	bf75                	j	80004788 <fileread+0x60>
    panic("fileread");
    800047ce:	00004517          	auipc	a0,0x4
    800047d2:	eb250513          	addi	a0,a0,-334 # 80008680 <syscalls+0x258>
    800047d6:	ffffc097          	auipc	ra,0xffffc
    800047da:	d6c080e7          	jalr	-660(ra) # 80000542 <panic>
    return -1;
    800047de:	597d                	li	s2,-1
    800047e0:	b765                	j	80004788 <fileread+0x60>
      return -1;
    800047e2:	597d                	li	s2,-1
    800047e4:	b755                	j	80004788 <fileread+0x60>
    800047e6:	597d                	li	s2,-1
    800047e8:	b745                	j	80004788 <fileread+0x60>

00000000800047ea <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047ea:	00954783          	lbu	a5,9(a0)
    800047ee:	14078563          	beqz	a5,80004938 <filewrite+0x14e>
{
    800047f2:	715d                	addi	sp,sp,-80
    800047f4:	e486                	sd	ra,72(sp)
    800047f6:	e0a2                	sd	s0,64(sp)
    800047f8:	fc26                	sd	s1,56(sp)
    800047fa:	f84a                	sd	s2,48(sp)
    800047fc:	f44e                	sd	s3,40(sp)
    800047fe:	f052                	sd	s4,32(sp)
    80004800:	ec56                	sd	s5,24(sp)
    80004802:	e85a                	sd	s6,16(sp)
    80004804:	e45e                	sd	s7,8(sp)
    80004806:	e062                	sd	s8,0(sp)
    80004808:	0880                	addi	s0,sp,80
    8000480a:	892a                	mv	s2,a0
    8000480c:	8aae                	mv	s5,a1
    8000480e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004810:	411c                	lw	a5,0(a0)
    80004812:	4705                	li	a4,1
    80004814:	02e78263          	beq	a5,a4,80004838 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004818:	470d                	li	a4,3
    8000481a:	02e78563          	beq	a5,a4,80004844 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000481e:	4709                	li	a4,2
    80004820:	10e79463          	bne	a5,a4,80004928 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004824:	0ec05e63          	blez	a2,80004920 <filewrite+0x136>
    int i = 0;
    80004828:	4981                	li	s3,0
    8000482a:	6b05                	lui	s6,0x1
    8000482c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004830:	6b85                	lui	s7,0x1
    80004832:	c00b8b9b          	addiw	s7,s7,-1024
    80004836:	a851                	j	800048ca <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004838:	6908                	ld	a0,16(a0)
    8000483a:	00000097          	auipc	ra,0x0
    8000483e:	254080e7          	jalr	596(ra) # 80004a8e <pipewrite>
    80004842:	a85d                	j	800048f8 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004844:	02451783          	lh	a5,36(a0)
    80004848:	03079693          	slli	a3,a5,0x30
    8000484c:	92c1                	srli	a3,a3,0x30
    8000484e:	4725                	li	a4,9
    80004850:	0ed76663          	bltu	a4,a3,8000493c <filewrite+0x152>
    80004854:	0792                	slli	a5,a5,0x4
    80004856:	0003d717          	auipc	a4,0x3d
    8000485a:	15a70713          	addi	a4,a4,346 # 800419b0 <devsw>
    8000485e:	97ba                	add	a5,a5,a4
    80004860:	679c                	ld	a5,8(a5)
    80004862:	cff9                	beqz	a5,80004940 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004864:	4505                	li	a0,1
    80004866:	9782                	jalr	a5
    80004868:	a841                	j	800048f8 <filewrite+0x10e>
    8000486a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000486e:	00000097          	auipc	ra,0x0
    80004872:	8ae080e7          	jalr	-1874(ra) # 8000411c <begin_op>
      ilock(f->ip);
    80004876:	01893503          	ld	a0,24(s2)
    8000487a:	fffff097          	auipc	ra,0xfffff
    8000487e:	ee2080e7          	jalr	-286(ra) # 8000375c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004882:	8762                	mv	a4,s8
    80004884:	02092683          	lw	a3,32(s2)
    80004888:	01598633          	add	a2,s3,s5
    8000488c:	4585                	li	a1,1
    8000488e:	01893503          	ld	a0,24(s2)
    80004892:	fffff097          	auipc	ra,0xfffff
    80004896:	276080e7          	jalr	630(ra) # 80003b08 <writei>
    8000489a:	84aa                	mv	s1,a0
    8000489c:	02a05f63          	blez	a0,800048da <filewrite+0xf0>
        f->off += r;
    800048a0:	02092783          	lw	a5,32(s2)
    800048a4:	9fa9                	addw	a5,a5,a0
    800048a6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048aa:	01893503          	ld	a0,24(s2)
    800048ae:	fffff097          	auipc	ra,0xfffff
    800048b2:	f70080e7          	jalr	-144(ra) # 8000381e <iunlock>
      end_op();
    800048b6:	00000097          	auipc	ra,0x0
    800048ba:	8e6080e7          	jalr	-1818(ra) # 8000419c <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800048be:	049c1963          	bne	s8,s1,80004910 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    800048c2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048c6:	0349d663          	bge	s3,s4,800048f2 <filewrite+0x108>
      int n1 = n - i;
    800048ca:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800048ce:	84be                	mv	s1,a5
    800048d0:	2781                	sext.w	a5,a5
    800048d2:	f8fb5ce3          	bge	s6,a5,8000486a <filewrite+0x80>
    800048d6:	84de                	mv	s1,s7
    800048d8:	bf49                	j	8000486a <filewrite+0x80>
      iunlock(f->ip);
    800048da:	01893503          	ld	a0,24(s2)
    800048de:	fffff097          	auipc	ra,0xfffff
    800048e2:	f40080e7          	jalr	-192(ra) # 8000381e <iunlock>
      end_op();
    800048e6:	00000097          	auipc	ra,0x0
    800048ea:	8b6080e7          	jalr	-1866(ra) # 8000419c <end_op>
      if(r < 0)
    800048ee:	fc04d8e3          	bgez	s1,800048be <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    800048f2:	8552                	mv	a0,s4
    800048f4:	033a1863          	bne	s4,s3,80004924 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048f8:	60a6                	ld	ra,72(sp)
    800048fa:	6406                	ld	s0,64(sp)
    800048fc:	74e2                	ld	s1,56(sp)
    800048fe:	7942                	ld	s2,48(sp)
    80004900:	79a2                	ld	s3,40(sp)
    80004902:	7a02                	ld	s4,32(sp)
    80004904:	6ae2                	ld	s5,24(sp)
    80004906:	6b42                	ld	s6,16(sp)
    80004908:	6ba2                	ld	s7,8(sp)
    8000490a:	6c02                	ld	s8,0(sp)
    8000490c:	6161                	addi	sp,sp,80
    8000490e:	8082                	ret
        panic("short filewrite");
    80004910:	00004517          	auipc	a0,0x4
    80004914:	d8050513          	addi	a0,a0,-640 # 80008690 <syscalls+0x268>
    80004918:	ffffc097          	auipc	ra,0xffffc
    8000491c:	c2a080e7          	jalr	-982(ra) # 80000542 <panic>
    int i = 0;
    80004920:	4981                	li	s3,0
    80004922:	bfc1                	j	800048f2 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004924:	557d                	li	a0,-1
    80004926:	bfc9                	j	800048f8 <filewrite+0x10e>
    panic("filewrite");
    80004928:	00004517          	auipc	a0,0x4
    8000492c:	d7850513          	addi	a0,a0,-648 # 800086a0 <syscalls+0x278>
    80004930:	ffffc097          	auipc	ra,0xffffc
    80004934:	c12080e7          	jalr	-1006(ra) # 80000542 <panic>
    return -1;
    80004938:	557d                	li	a0,-1
}
    8000493a:	8082                	ret
      return -1;
    8000493c:	557d                	li	a0,-1
    8000493e:	bf6d                	j	800048f8 <filewrite+0x10e>
    80004940:	557d                	li	a0,-1
    80004942:	bf5d                	j	800048f8 <filewrite+0x10e>

0000000080004944 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004944:	7179                	addi	sp,sp,-48
    80004946:	f406                	sd	ra,40(sp)
    80004948:	f022                	sd	s0,32(sp)
    8000494a:	ec26                	sd	s1,24(sp)
    8000494c:	e84a                	sd	s2,16(sp)
    8000494e:	e44e                	sd	s3,8(sp)
    80004950:	e052                	sd	s4,0(sp)
    80004952:	1800                	addi	s0,sp,48
    80004954:	84aa                	mv	s1,a0
    80004956:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004958:	0005b023          	sd	zero,0(a1)
    8000495c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004960:	00000097          	auipc	ra,0x0
    80004964:	bd2080e7          	jalr	-1070(ra) # 80004532 <filealloc>
    80004968:	e088                	sd	a0,0(s1)
    8000496a:	c551                	beqz	a0,800049f6 <pipealloc+0xb2>
    8000496c:	00000097          	auipc	ra,0x0
    80004970:	bc6080e7          	jalr	-1082(ra) # 80004532 <filealloc>
    80004974:	00aa3023          	sd	a0,0(s4)
    80004978:	c92d                	beqz	a0,800049ea <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000497a:	ffffc097          	auipc	ra,0xffffc
    8000497e:	1d4080e7          	jalr	468(ra) # 80000b4e <kalloc>
    80004982:	892a                	mv	s2,a0
    80004984:	c125                	beqz	a0,800049e4 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004986:	4985                	li	s3,1
    80004988:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000498c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004990:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004994:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004998:	00004597          	auipc	a1,0x4
    8000499c:	d1858593          	addi	a1,a1,-744 # 800086b0 <syscalls+0x288>
    800049a0:	ffffc097          	auipc	ra,0xffffc
    800049a4:	2de080e7          	jalr	734(ra) # 80000c7e <initlock>
  (*f0)->type = FD_PIPE;
    800049a8:	609c                	ld	a5,0(s1)
    800049aa:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049ae:	609c                	ld	a5,0(s1)
    800049b0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049b4:	609c                	ld	a5,0(s1)
    800049b6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049ba:	609c                	ld	a5,0(s1)
    800049bc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049c0:	000a3783          	ld	a5,0(s4)
    800049c4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049c8:	000a3783          	ld	a5,0(s4)
    800049cc:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049d0:	000a3783          	ld	a5,0(s4)
    800049d4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049d8:	000a3783          	ld	a5,0(s4)
    800049dc:	0127b823          	sd	s2,16(a5)
  return 0;
    800049e0:	4501                	li	a0,0
    800049e2:	a025                	j	80004a0a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049e4:	6088                	ld	a0,0(s1)
    800049e6:	e501                	bnez	a0,800049ee <pipealloc+0xaa>
    800049e8:	a039                	j	800049f6 <pipealloc+0xb2>
    800049ea:	6088                	ld	a0,0(s1)
    800049ec:	c51d                	beqz	a0,80004a1a <pipealloc+0xd6>
    fileclose(*f0);
    800049ee:	00000097          	auipc	ra,0x0
    800049f2:	c00080e7          	jalr	-1024(ra) # 800045ee <fileclose>
  if(*f1)
    800049f6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049fa:	557d                	li	a0,-1
  if(*f1)
    800049fc:	c799                	beqz	a5,80004a0a <pipealloc+0xc6>
    fileclose(*f1);
    800049fe:	853e                	mv	a0,a5
    80004a00:	00000097          	auipc	ra,0x0
    80004a04:	bee080e7          	jalr	-1042(ra) # 800045ee <fileclose>
  return -1;
    80004a08:	557d                	li	a0,-1
}
    80004a0a:	70a2                	ld	ra,40(sp)
    80004a0c:	7402                	ld	s0,32(sp)
    80004a0e:	64e2                	ld	s1,24(sp)
    80004a10:	6942                	ld	s2,16(sp)
    80004a12:	69a2                	ld	s3,8(sp)
    80004a14:	6a02                	ld	s4,0(sp)
    80004a16:	6145                	addi	sp,sp,48
    80004a18:	8082                	ret
  return -1;
    80004a1a:	557d                	li	a0,-1
    80004a1c:	b7fd                	j	80004a0a <pipealloc+0xc6>

0000000080004a1e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a1e:	1101                	addi	sp,sp,-32
    80004a20:	ec06                	sd	ra,24(sp)
    80004a22:	e822                	sd	s0,16(sp)
    80004a24:	e426                	sd	s1,8(sp)
    80004a26:	e04a                	sd	s2,0(sp)
    80004a28:	1000                	addi	s0,sp,32
    80004a2a:	84aa                	mv	s1,a0
    80004a2c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a2e:	ffffc097          	auipc	ra,0xffffc
    80004a32:	2e0080e7          	jalr	736(ra) # 80000d0e <acquire>
  if(writable){
    80004a36:	02090d63          	beqz	s2,80004a70 <pipeclose+0x52>
    pi->writeopen = 0;
    80004a3a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a3e:	21848513          	addi	a0,s1,536
    80004a42:	ffffe097          	auipc	ra,0xffffe
    80004a46:	a58080e7          	jalr	-1448(ra) # 8000249a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a4a:	2204b783          	ld	a5,544(s1)
    80004a4e:	eb95                	bnez	a5,80004a82 <pipeclose+0x64>
    release(&pi->lock);
    80004a50:	8526                	mv	a0,s1
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	370080e7          	jalr	880(ra) # 80000dc2 <release>
    kfree((char*)pi);
    80004a5a:	8526                	mv	a0,s1
    80004a5c:	ffffc097          	auipc	ra,0xffffc
    80004a60:	fb6080e7          	jalr	-74(ra) # 80000a12 <kfree>
  } else
    release(&pi->lock);
}
    80004a64:	60e2                	ld	ra,24(sp)
    80004a66:	6442                	ld	s0,16(sp)
    80004a68:	64a2                	ld	s1,8(sp)
    80004a6a:	6902                	ld	s2,0(sp)
    80004a6c:	6105                	addi	sp,sp,32
    80004a6e:	8082                	ret
    pi->readopen = 0;
    80004a70:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a74:	21c48513          	addi	a0,s1,540
    80004a78:	ffffe097          	auipc	ra,0xffffe
    80004a7c:	a22080e7          	jalr	-1502(ra) # 8000249a <wakeup>
    80004a80:	b7e9                	j	80004a4a <pipeclose+0x2c>
    release(&pi->lock);
    80004a82:	8526                	mv	a0,s1
    80004a84:	ffffc097          	auipc	ra,0xffffc
    80004a88:	33e080e7          	jalr	830(ra) # 80000dc2 <release>
}
    80004a8c:	bfe1                	j	80004a64 <pipeclose+0x46>

0000000080004a8e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a8e:	711d                	addi	sp,sp,-96
    80004a90:	ec86                	sd	ra,88(sp)
    80004a92:	e8a2                	sd	s0,80(sp)
    80004a94:	e4a6                	sd	s1,72(sp)
    80004a96:	e0ca                	sd	s2,64(sp)
    80004a98:	fc4e                	sd	s3,56(sp)
    80004a9a:	f852                	sd	s4,48(sp)
    80004a9c:	f456                	sd	s5,40(sp)
    80004a9e:	f05a                	sd	s6,32(sp)
    80004aa0:	ec5e                	sd	s7,24(sp)
    80004aa2:	e862                	sd	s8,16(sp)
    80004aa4:	1080                	addi	s0,sp,96
    80004aa6:	84aa                	mv	s1,a0
    80004aa8:	8b2e                	mv	s6,a1
    80004aaa:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004aac:	ffffd097          	auipc	ra,0xffffd
    80004ab0:	05a080e7          	jalr	90(ra) # 80001b06 <myproc>
    80004ab4:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004ab6:	8526                	mv	a0,s1
    80004ab8:	ffffc097          	auipc	ra,0xffffc
    80004abc:	256080e7          	jalr	598(ra) # 80000d0e <acquire>
  for(i = 0; i < n; i++){
    80004ac0:	09505763          	blez	s5,80004b4e <pipewrite+0xc0>
    80004ac4:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004ac6:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004aca:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ace:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004ad0:	2184a783          	lw	a5,536(s1)
    80004ad4:	21c4a703          	lw	a4,540(s1)
    80004ad8:	2007879b          	addiw	a5,a5,512
    80004adc:	02f71b63          	bne	a4,a5,80004b12 <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    80004ae0:	2204a783          	lw	a5,544(s1)
    80004ae4:	c3d1                	beqz	a5,80004b68 <pipewrite+0xda>
    80004ae6:	03092783          	lw	a5,48(s2)
    80004aea:	efbd                	bnez	a5,80004b68 <pipewrite+0xda>
      wakeup(&pi->nread);
    80004aec:	8552                	mv	a0,s4
    80004aee:	ffffe097          	auipc	ra,0xffffe
    80004af2:	9ac080e7          	jalr	-1620(ra) # 8000249a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004af6:	85a6                	mv	a1,s1
    80004af8:	854e                	mv	a0,s3
    80004afa:	ffffe097          	auipc	ra,0xffffe
    80004afe:	820080e7          	jalr	-2016(ra) # 8000231a <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b02:	2184a783          	lw	a5,536(s1)
    80004b06:	21c4a703          	lw	a4,540(s1)
    80004b0a:	2007879b          	addiw	a5,a5,512
    80004b0e:	fcf709e3          	beq	a4,a5,80004ae0 <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b12:	4685                	li	a3,1
    80004b14:	865a                	mv	a2,s6
    80004b16:	faf40593          	addi	a1,s0,-81
    80004b1a:	05093503          	ld	a0,80(s2)
    80004b1e:	ffffd097          	auipc	ra,0xffffd
    80004b22:	d66080e7          	jalr	-666(ra) # 80001884 <copyin>
    80004b26:	03850563          	beq	a0,s8,80004b50 <pipewrite+0xc2>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b2a:	21c4a783          	lw	a5,540(s1)
    80004b2e:	0017871b          	addiw	a4,a5,1
    80004b32:	20e4ae23          	sw	a4,540(s1)
    80004b36:	1ff7f793          	andi	a5,a5,511
    80004b3a:	97a6                	add	a5,a5,s1
    80004b3c:	faf44703          	lbu	a4,-81(s0)
    80004b40:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004b44:	2b85                	addiw	s7,s7,1
    80004b46:	0b05                	addi	s6,s6,1
    80004b48:	f97a94e3          	bne	s5,s7,80004ad0 <pipewrite+0x42>
    80004b4c:	a011                	j	80004b50 <pipewrite+0xc2>
    80004b4e:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    80004b50:	21848513          	addi	a0,s1,536
    80004b54:	ffffe097          	auipc	ra,0xffffe
    80004b58:	946080e7          	jalr	-1722(ra) # 8000249a <wakeup>
  release(&pi->lock);
    80004b5c:	8526                	mv	a0,s1
    80004b5e:	ffffc097          	auipc	ra,0xffffc
    80004b62:	264080e7          	jalr	612(ra) # 80000dc2 <release>
  return i;
    80004b66:	a039                	j	80004b74 <pipewrite+0xe6>
        release(&pi->lock);
    80004b68:	8526                	mv	a0,s1
    80004b6a:	ffffc097          	auipc	ra,0xffffc
    80004b6e:	258080e7          	jalr	600(ra) # 80000dc2 <release>
        return -1;
    80004b72:	5bfd                	li	s7,-1
}
    80004b74:	855e                	mv	a0,s7
    80004b76:	60e6                	ld	ra,88(sp)
    80004b78:	6446                	ld	s0,80(sp)
    80004b7a:	64a6                	ld	s1,72(sp)
    80004b7c:	6906                	ld	s2,64(sp)
    80004b7e:	79e2                	ld	s3,56(sp)
    80004b80:	7a42                	ld	s4,48(sp)
    80004b82:	7aa2                	ld	s5,40(sp)
    80004b84:	7b02                	ld	s6,32(sp)
    80004b86:	6be2                	ld	s7,24(sp)
    80004b88:	6c42                	ld	s8,16(sp)
    80004b8a:	6125                	addi	sp,sp,96
    80004b8c:	8082                	ret

0000000080004b8e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b8e:	715d                	addi	sp,sp,-80
    80004b90:	e486                	sd	ra,72(sp)
    80004b92:	e0a2                	sd	s0,64(sp)
    80004b94:	fc26                	sd	s1,56(sp)
    80004b96:	f84a                	sd	s2,48(sp)
    80004b98:	f44e                	sd	s3,40(sp)
    80004b9a:	f052                	sd	s4,32(sp)
    80004b9c:	ec56                	sd	s5,24(sp)
    80004b9e:	e85a                	sd	s6,16(sp)
    80004ba0:	0880                	addi	s0,sp,80
    80004ba2:	84aa                	mv	s1,a0
    80004ba4:	892e                	mv	s2,a1
    80004ba6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ba8:	ffffd097          	auipc	ra,0xffffd
    80004bac:	f5e080e7          	jalr	-162(ra) # 80001b06 <myproc>
    80004bb0:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004bb2:	8526                	mv	a0,s1
    80004bb4:	ffffc097          	auipc	ra,0xffffc
    80004bb8:	15a080e7          	jalr	346(ra) # 80000d0e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bbc:	2184a703          	lw	a4,536(s1)
    80004bc0:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bc4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bc8:	02f71463          	bne	a4,a5,80004bf0 <piperead+0x62>
    80004bcc:	2244a783          	lw	a5,548(s1)
    80004bd0:	c385                	beqz	a5,80004bf0 <piperead+0x62>
    if(pr->killed){
    80004bd2:	030a2783          	lw	a5,48(s4)
    80004bd6:	ebc1                	bnez	a5,80004c66 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bd8:	85a6                	mv	a1,s1
    80004bda:	854e                	mv	a0,s3
    80004bdc:	ffffd097          	auipc	ra,0xffffd
    80004be0:	73e080e7          	jalr	1854(ra) # 8000231a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004be4:	2184a703          	lw	a4,536(s1)
    80004be8:	21c4a783          	lw	a5,540(s1)
    80004bec:	fef700e3          	beq	a4,a5,80004bcc <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bf0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bf2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bf4:	05505363          	blez	s5,80004c3a <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004bf8:	2184a783          	lw	a5,536(s1)
    80004bfc:	21c4a703          	lw	a4,540(s1)
    80004c00:	02f70d63          	beq	a4,a5,80004c3a <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c04:	0017871b          	addiw	a4,a5,1
    80004c08:	20e4ac23          	sw	a4,536(s1)
    80004c0c:	1ff7f793          	andi	a5,a5,511
    80004c10:	97a6                	add	a5,a5,s1
    80004c12:	0187c783          	lbu	a5,24(a5)
    80004c16:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c1a:	4685                	li	a3,1
    80004c1c:	fbf40613          	addi	a2,s0,-65
    80004c20:	85ca                	mv	a1,s2
    80004c22:	050a3503          	ld	a0,80(s4)
    80004c26:	ffffd097          	auipc	ra,0xffffd
    80004c2a:	ba2080e7          	jalr	-1118(ra) # 800017c8 <copyout>
    80004c2e:	01650663          	beq	a0,s6,80004c3a <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c32:	2985                	addiw	s3,s3,1
    80004c34:	0905                	addi	s2,s2,1
    80004c36:	fd3a91e3          	bne	s5,s3,80004bf8 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c3a:	21c48513          	addi	a0,s1,540
    80004c3e:	ffffe097          	auipc	ra,0xffffe
    80004c42:	85c080e7          	jalr	-1956(ra) # 8000249a <wakeup>
  release(&pi->lock);
    80004c46:	8526                	mv	a0,s1
    80004c48:	ffffc097          	auipc	ra,0xffffc
    80004c4c:	17a080e7          	jalr	378(ra) # 80000dc2 <release>
  return i;
}
    80004c50:	854e                	mv	a0,s3
    80004c52:	60a6                	ld	ra,72(sp)
    80004c54:	6406                	ld	s0,64(sp)
    80004c56:	74e2                	ld	s1,56(sp)
    80004c58:	7942                	ld	s2,48(sp)
    80004c5a:	79a2                	ld	s3,40(sp)
    80004c5c:	7a02                	ld	s4,32(sp)
    80004c5e:	6ae2                	ld	s5,24(sp)
    80004c60:	6b42                	ld	s6,16(sp)
    80004c62:	6161                	addi	sp,sp,80
    80004c64:	8082                	ret
      release(&pi->lock);
    80004c66:	8526                	mv	a0,s1
    80004c68:	ffffc097          	auipc	ra,0xffffc
    80004c6c:	15a080e7          	jalr	346(ra) # 80000dc2 <release>
      return -1;
    80004c70:	59fd                	li	s3,-1
    80004c72:	bff9                	j	80004c50 <piperead+0xc2>

0000000080004c74 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004c74:	de010113          	addi	sp,sp,-544
    80004c78:	20113c23          	sd	ra,536(sp)
    80004c7c:	20813823          	sd	s0,528(sp)
    80004c80:	20913423          	sd	s1,520(sp)
    80004c84:	21213023          	sd	s2,512(sp)
    80004c88:	ffce                	sd	s3,504(sp)
    80004c8a:	fbd2                	sd	s4,496(sp)
    80004c8c:	f7d6                	sd	s5,488(sp)
    80004c8e:	f3da                	sd	s6,480(sp)
    80004c90:	efde                	sd	s7,472(sp)
    80004c92:	ebe2                	sd	s8,464(sp)
    80004c94:	e7e6                	sd	s9,456(sp)
    80004c96:	e3ea                	sd	s10,448(sp)
    80004c98:	ff6e                	sd	s11,440(sp)
    80004c9a:	1400                	addi	s0,sp,544
    80004c9c:	892a                	mv	s2,a0
    80004c9e:	dea43423          	sd	a0,-536(s0)
    80004ca2:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ca6:	ffffd097          	auipc	ra,0xffffd
    80004caa:	e60080e7          	jalr	-416(ra) # 80001b06 <myproc>
    80004cae:	84aa                	mv	s1,a0

  begin_op();
    80004cb0:	fffff097          	auipc	ra,0xfffff
    80004cb4:	46c080e7          	jalr	1132(ra) # 8000411c <begin_op>

  if((ip = namei(path)) == 0){
    80004cb8:	854a                	mv	a0,s2
    80004cba:	fffff097          	auipc	ra,0xfffff
    80004cbe:	256080e7          	jalr	598(ra) # 80003f10 <namei>
    80004cc2:	c93d                	beqz	a0,80004d38 <exec+0xc4>
    80004cc4:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004cc6:	fffff097          	auipc	ra,0xfffff
    80004cca:	a96080e7          	jalr	-1386(ra) # 8000375c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cce:	04000713          	li	a4,64
    80004cd2:	4681                	li	a3,0
    80004cd4:	e4840613          	addi	a2,s0,-440
    80004cd8:	4581                	li	a1,0
    80004cda:	8556                	mv	a0,s5
    80004cdc:	fffff097          	auipc	ra,0xfffff
    80004ce0:	d34080e7          	jalr	-716(ra) # 80003a10 <readi>
    80004ce4:	04000793          	li	a5,64
    80004ce8:	00f51a63          	bne	a0,a5,80004cfc <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004cec:	e4842703          	lw	a4,-440(s0)
    80004cf0:	464c47b7          	lui	a5,0x464c4
    80004cf4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cf8:	04f70663          	beq	a4,a5,80004d44 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004cfc:	8556                	mv	a0,s5
    80004cfe:	fffff097          	auipc	ra,0xfffff
    80004d02:	cc0080e7          	jalr	-832(ra) # 800039be <iunlockput>
    end_op();
    80004d06:	fffff097          	auipc	ra,0xfffff
    80004d0a:	496080e7          	jalr	1174(ra) # 8000419c <end_op>
  }
  return -1;
    80004d0e:	557d                	li	a0,-1
}
    80004d10:	21813083          	ld	ra,536(sp)
    80004d14:	21013403          	ld	s0,528(sp)
    80004d18:	20813483          	ld	s1,520(sp)
    80004d1c:	20013903          	ld	s2,512(sp)
    80004d20:	79fe                	ld	s3,504(sp)
    80004d22:	7a5e                	ld	s4,496(sp)
    80004d24:	7abe                	ld	s5,488(sp)
    80004d26:	7b1e                	ld	s6,480(sp)
    80004d28:	6bfe                	ld	s7,472(sp)
    80004d2a:	6c5e                	ld	s8,464(sp)
    80004d2c:	6cbe                	ld	s9,456(sp)
    80004d2e:	6d1e                	ld	s10,448(sp)
    80004d30:	7dfa                	ld	s11,440(sp)
    80004d32:	22010113          	addi	sp,sp,544
    80004d36:	8082                	ret
    end_op();
    80004d38:	fffff097          	auipc	ra,0xfffff
    80004d3c:	464080e7          	jalr	1124(ra) # 8000419c <end_op>
    return -1;
    80004d40:	557d                	li	a0,-1
    80004d42:	b7f9                	j	80004d10 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d44:	8526                	mv	a0,s1
    80004d46:	ffffd097          	auipc	ra,0xffffd
    80004d4a:	e84080e7          	jalr	-380(ra) # 80001bca <proc_pagetable>
    80004d4e:	8b2a                	mv	s6,a0
    80004d50:	d555                	beqz	a0,80004cfc <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d52:	e6842783          	lw	a5,-408(s0)
    80004d56:	e8045703          	lhu	a4,-384(s0)
    80004d5a:	c735                	beqz	a4,80004dc6 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d5c:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d5e:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004d62:	6a05                	lui	s4,0x1
    80004d64:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004d68:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004d6c:	6d85                	lui	s11,0x1
    80004d6e:	7d7d                	lui	s10,0xfffff
    80004d70:	ac1d                	j	80004fa6 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004d72:	00004517          	auipc	a0,0x4
    80004d76:	94650513          	addi	a0,a0,-1722 # 800086b8 <syscalls+0x290>
    80004d7a:	ffffb097          	auipc	ra,0xffffb
    80004d7e:	7c8080e7          	jalr	1992(ra) # 80000542 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d82:	874a                	mv	a4,s2
    80004d84:	009c86bb          	addw	a3,s9,s1
    80004d88:	4581                	li	a1,0
    80004d8a:	8556                	mv	a0,s5
    80004d8c:	fffff097          	auipc	ra,0xfffff
    80004d90:	c84080e7          	jalr	-892(ra) # 80003a10 <readi>
    80004d94:	2501                	sext.w	a0,a0
    80004d96:	1aa91863          	bne	s2,a0,80004f46 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004d9a:	009d84bb          	addw	s1,s11,s1
    80004d9e:	013d09bb          	addw	s3,s10,s3
    80004da2:	1f74f263          	bgeu	s1,s7,80004f86 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004da6:	02049593          	slli	a1,s1,0x20
    80004daa:	9181                	srli	a1,a1,0x20
    80004dac:	95e2                	add	a1,a1,s8
    80004dae:	855a                	mv	a0,s6
    80004db0:	ffffc097          	auipc	ra,0xffffc
    80004db4:	3e8080e7          	jalr	1000(ra) # 80001198 <walkaddr>
    80004db8:	862a                	mv	a2,a0
    if(pa == 0)
    80004dba:	dd45                	beqz	a0,80004d72 <exec+0xfe>
      n = PGSIZE;
    80004dbc:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004dbe:	fd49f2e3          	bgeu	s3,s4,80004d82 <exec+0x10e>
      n = sz - i;
    80004dc2:	894e                	mv	s2,s3
    80004dc4:	bf7d                	j	80004d82 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004dc6:	4481                	li	s1,0
  iunlockput(ip);
    80004dc8:	8556                	mv	a0,s5
    80004dca:	fffff097          	auipc	ra,0xfffff
    80004dce:	bf4080e7          	jalr	-1036(ra) # 800039be <iunlockput>
  end_op();
    80004dd2:	fffff097          	auipc	ra,0xfffff
    80004dd6:	3ca080e7          	jalr	970(ra) # 8000419c <end_op>
  p = myproc();
    80004dda:	ffffd097          	auipc	ra,0xffffd
    80004dde:	d2c080e7          	jalr	-724(ra) # 80001b06 <myproc>
    80004de2:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004de4:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004de8:	6785                	lui	a5,0x1
    80004dea:	17fd                	addi	a5,a5,-1
    80004dec:	94be                	add	s1,s1,a5
    80004dee:	77fd                	lui	a5,0xfffff
    80004df0:	8fe5                	and	a5,a5,s1
    80004df2:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004df6:	6609                	lui	a2,0x2
    80004df8:	963e                	add	a2,a2,a5
    80004dfa:	85be                	mv	a1,a5
    80004dfc:	855a                	mv	a0,s6
    80004dfe:	ffffc097          	auipc	ra,0xffffc
    80004e02:	77e080e7          	jalr	1918(ra) # 8000157c <uvmalloc>
    80004e06:	8c2a                	mv	s8,a0
  ip = 0;
    80004e08:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e0a:	12050e63          	beqz	a0,80004f46 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e0e:	75f9                	lui	a1,0xffffe
    80004e10:	95aa                	add	a1,a1,a0
    80004e12:	855a                	mv	a0,s6
    80004e14:	ffffd097          	auipc	ra,0xffffd
    80004e18:	982080e7          	jalr	-1662(ra) # 80001796 <uvmclear>
  stackbase = sp - PGSIZE;
    80004e1c:	7afd                	lui	s5,0xfffff
    80004e1e:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e20:	df043783          	ld	a5,-528(s0)
    80004e24:	6388                	ld	a0,0(a5)
    80004e26:	c925                	beqz	a0,80004e96 <exec+0x222>
    80004e28:	e8840993          	addi	s3,s0,-376
    80004e2c:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004e30:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e32:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004e34:	ffffc097          	auipc	ra,0xffffc
    80004e38:	15a080e7          	jalr	346(ra) # 80000f8e <strlen>
    80004e3c:	0015079b          	addiw	a5,a0,1
    80004e40:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e44:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004e48:	13596363          	bltu	s2,s5,80004f6e <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e4c:	df043d83          	ld	s11,-528(s0)
    80004e50:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004e54:	8552                	mv	a0,s4
    80004e56:	ffffc097          	auipc	ra,0xffffc
    80004e5a:	138080e7          	jalr	312(ra) # 80000f8e <strlen>
    80004e5e:	0015069b          	addiw	a3,a0,1
    80004e62:	8652                	mv	a2,s4
    80004e64:	85ca                	mv	a1,s2
    80004e66:	855a                	mv	a0,s6
    80004e68:	ffffd097          	auipc	ra,0xffffd
    80004e6c:	960080e7          	jalr	-1696(ra) # 800017c8 <copyout>
    80004e70:	10054363          	bltz	a0,80004f76 <exec+0x302>
    ustack[argc] = sp;
    80004e74:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e78:	0485                	addi	s1,s1,1
    80004e7a:	008d8793          	addi	a5,s11,8
    80004e7e:	def43823          	sd	a5,-528(s0)
    80004e82:	008db503          	ld	a0,8(s11)
    80004e86:	c911                	beqz	a0,80004e9a <exec+0x226>
    if(argc >= MAXARG)
    80004e88:	09a1                	addi	s3,s3,8
    80004e8a:	fb3c95e3          	bne	s9,s3,80004e34 <exec+0x1c0>
  sz = sz1;
    80004e8e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e92:	4a81                	li	s5,0
    80004e94:	a84d                	j	80004f46 <exec+0x2d2>
  sp = sz;
    80004e96:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e98:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e9a:	00349793          	slli	a5,s1,0x3
    80004e9e:	f9040713          	addi	a4,s0,-112
    80004ea2:	97ba                	add	a5,a5,a4
    80004ea4:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffb8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80004ea8:	00148693          	addi	a3,s1,1
    80004eac:	068e                	slli	a3,a3,0x3
    80004eae:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004eb2:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004eb6:	01597663          	bgeu	s2,s5,80004ec2 <exec+0x24e>
  sz = sz1;
    80004eba:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ebe:	4a81                	li	s5,0
    80004ec0:	a059                	j	80004f46 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004ec2:	e8840613          	addi	a2,s0,-376
    80004ec6:	85ca                	mv	a1,s2
    80004ec8:	855a                	mv	a0,s6
    80004eca:	ffffd097          	auipc	ra,0xffffd
    80004ece:	8fe080e7          	jalr	-1794(ra) # 800017c8 <copyout>
    80004ed2:	0a054663          	bltz	a0,80004f7e <exec+0x30a>
  p->trapframe->a1 = sp;
    80004ed6:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004eda:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004ede:	de843783          	ld	a5,-536(s0)
    80004ee2:	0007c703          	lbu	a4,0(a5)
    80004ee6:	cf11                	beqz	a4,80004f02 <exec+0x28e>
    80004ee8:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004eea:	02f00693          	li	a3,47
    80004eee:	a039                	j	80004efc <exec+0x288>
      last = s+1;
    80004ef0:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004ef4:	0785                	addi	a5,a5,1
    80004ef6:	fff7c703          	lbu	a4,-1(a5)
    80004efa:	c701                	beqz	a4,80004f02 <exec+0x28e>
    if(*s == '/')
    80004efc:	fed71ce3          	bne	a4,a3,80004ef4 <exec+0x280>
    80004f00:	bfc5                	j	80004ef0 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f02:	4641                	li	a2,16
    80004f04:	de843583          	ld	a1,-536(s0)
    80004f08:	158b8513          	addi	a0,s7,344
    80004f0c:	ffffc097          	auipc	ra,0xffffc
    80004f10:	050080e7          	jalr	80(ra) # 80000f5c <safestrcpy>
  oldpagetable = p->pagetable;
    80004f14:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004f18:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004f1c:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f20:	058bb783          	ld	a5,88(s7)
    80004f24:	e6043703          	ld	a4,-416(s0)
    80004f28:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f2a:	058bb783          	ld	a5,88(s7)
    80004f2e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f32:	85ea                	mv	a1,s10
    80004f34:	ffffd097          	auipc	ra,0xffffd
    80004f38:	d32080e7          	jalr	-718(ra) # 80001c66 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f3c:	0004851b          	sext.w	a0,s1
    80004f40:	bbc1                	j	80004d10 <exec+0x9c>
    80004f42:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004f46:	df843583          	ld	a1,-520(s0)
    80004f4a:	855a                	mv	a0,s6
    80004f4c:	ffffd097          	auipc	ra,0xffffd
    80004f50:	d1a080e7          	jalr	-742(ra) # 80001c66 <proc_freepagetable>
  if(ip){
    80004f54:	da0a94e3          	bnez	s5,80004cfc <exec+0x88>
  return -1;
    80004f58:	557d                	li	a0,-1
    80004f5a:	bb5d                	j	80004d10 <exec+0x9c>
    80004f5c:	de943c23          	sd	s1,-520(s0)
    80004f60:	b7dd                	j	80004f46 <exec+0x2d2>
    80004f62:	de943c23          	sd	s1,-520(s0)
    80004f66:	b7c5                	j	80004f46 <exec+0x2d2>
    80004f68:	de943c23          	sd	s1,-520(s0)
    80004f6c:	bfe9                	j	80004f46 <exec+0x2d2>
  sz = sz1;
    80004f6e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f72:	4a81                	li	s5,0
    80004f74:	bfc9                	j	80004f46 <exec+0x2d2>
  sz = sz1;
    80004f76:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f7a:	4a81                	li	s5,0
    80004f7c:	b7e9                	j	80004f46 <exec+0x2d2>
  sz = sz1;
    80004f7e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f82:	4a81                	li	s5,0
    80004f84:	b7c9                	j	80004f46 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f86:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f8a:	e0843783          	ld	a5,-504(s0)
    80004f8e:	0017869b          	addiw	a3,a5,1
    80004f92:	e0d43423          	sd	a3,-504(s0)
    80004f96:	e0043783          	ld	a5,-512(s0)
    80004f9a:	0387879b          	addiw	a5,a5,56
    80004f9e:	e8045703          	lhu	a4,-384(s0)
    80004fa2:	e2e6d3e3          	bge	a3,a4,80004dc8 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004fa6:	2781                	sext.w	a5,a5
    80004fa8:	e0f43023          	sd	a5,-512(s0)
    80004fac:	03800713          	li	a4,56
    80004fb0:	86be                	mv	a3,a5
    80004fb2:	e1040613          	addi	a2,s0,-496
    80004fb6:	4581                	li	a1,0
    80004fb8:	8556                	mv	a0,s5
    80004fba:	fffff097          	auipc	ra,0xfffff
    80004fbe:	a56080e7          	jalr	-1450(ra) # 80003a10 <readi>
    80004fc2:	03800793          	li	a5,56
    80004fc6:	f6f51ee3          	bne	a0,a5,80004f42 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80004fca:	e1042783          	lw	a5,-496(s0)
    80004fce:	4705                	li	a4,1
    80004fd0:	fae79de3          	bne	a5,a4,80004f8a <exec+0x316>
    if(ph.memsz < ph.filesz)
    80004fd4:	e3843603          	ld	a2,-456(s0)
    80004fd8:	e3043783          	ld	a5,-464(s0)
    80004fdc:	f8f660e3          	bltu	a2,a5,80004f5c <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004fe0:	e2043783          	ld	a5,-480(s0)
    80004fe4:	963e                	add	a2,a2,a5
    80004fe6:	f6f66ee3          	bltu	a2,a5,80004f62 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004fea:	85a6                	mv	a1,s1
    80004fec:	855a                	mv	a0,s6
    80004fee:	ffffc097          	auipc	ra,0xffffc
    80004ff2:	58e080e7          	jalr	1422(ra) # 8000157c <uvmalloc>
    80004ff6:	dea43c23          	sd	a0,-520(s0)
    80004ffa:	d53d                	beqz	a0,80004f68 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80004ffc:	e2043c03          	ld	s8,-480(s0)
    80005000:	de043783          	ld	a5,-544(s0)
    80005004:	00fc77b3          	and	a5,s8,a5
    80005008:	ff9d                	bnez	a5,80004f46 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000500a:	e1842c83          	lw	s9,-488(s0)
    8000500e:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005012:	f60b8ae3          	beqz	s7,80004f86 <exec+0x312>
    80005016:	89de                	mv	s3,s7
    80005018:	4481                	li	s1,0
    8000501a:	b371                	j	80004da6 <exec+0x132>

000000008000501c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000501c:	7179                	addi	sp,sp,-48
    8000501e:	f406                	sd	ra,40(sp)
    80005020:	f022                	sd	s0,32(sp)
    80005022:	ec26                	sd	s1,24(sp)
    80005024:	e84a                	sd	s2,16(sp)
    80005026:	1800                	addi	s0,sp,48
    80005028:	892e                	mv	s2,a1
    8000502a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000502c:	fdc40593          	addi	a1,s0,-36
    80005030:	ffffe097          	auipc	ra,0xffffe
    80005034:	bbc080e7          	jalr	-1092(ra) # 80002bec <argint>
    80005038:	04054063          	bltz	a0,80005078 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000503c:	fdc42703          	lw	a4,-36(s0)
    80005040:	47bd                	li	a5,15
    80005042:	02e7ed63          	bltu	a5,a4,8000507c <argfd+0x60>
    80005046:	ffffd097          	auipc	ra,0xffffd
    8000504a:	ac0080e7          	jalr	-1344(ra) # 80001b06 <myproc>
    8000504e:	fdc42703          	lw	a4,-36(s0)
    80005052:	01a70793          	addi	a5,a4,26
    80005056:	078e                	slli	a5,a5,0x3
    80005058:	953e                	add	a0,a0,a5
    8000505a:	611c                	ld	a5,0(a0)
    8000505c:	c395                	beqz	a5,80005080 <argfd+0x64>
    return -1;
  if(pfd)
    8000505e:	00090463          	beqz	s2,80005066 <argfd+0x4a>
    *pfd = fd;
    80005062:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005066:	4501                	li	a0,0
  if(pf)
    80005068:	c091                	beqz	s1,8000506c <argfd+0x50>
    *pf = f;
    8000506a:	e09c                	sd	a5,0(s1)
}
    8000506c:	70a2                	ld	ra,40(sp)
    8000506e:	7402                	ld	s0,32(sp)
    80005070:	64e2                	ld	s1,24(sp)
    80005072:	6942                	ld	s2,16(sp)
    80005074:	6145                	addi	sp,sp,48
    80005076:	8082                	ret
    return -1;
    80005078:	557d                	li	a0,-1
    8000507a:	bfcd                	j	8000506c <argfd+0x50>
    return -1;
    8000507c:	557d                	li	a0,-1
    8000507e:	b7fd                	j	8000506c <argfd+0x50>
    80005080:	557d                	li	a0,-1
    80005082:	b7ed                	j	8000506c <argfd+0x50>

0000000080005084 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005084:	1101                	addi	sp,sp,-32
    80005086:	ec06                	sd	ra,24(sp)
    80005088:	e822                	sd	s0,16(sp)
    8000508a:	e426                	sd	s1,8(sp)
    8000508c:	1000                	addi	s0,sp,32
    8000508e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005090:	ffffd097          	auipc	ra,0xffffd
    80005094:	a76080e7          	jalr	-1418(ra) # 80001b06 <myproc>
    80005098:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000509a:	0d050793          	addi	a5,a0,208
    8000509e:	4501                	li	a0,0
    800050a0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800050a2:	6398                	ld	a4,0(a5)
    800050a4:	cb19                	beqz	a4,800050ba <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800050a6:	2505                	addiw	a0,a0,1
    800050a8:	07a1                	addi	a5,a5,8
    800050aa:	fed51ce3          	bne	a0,a3,800050a2 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050ae:	557d                	li	a0,-1
}
    800050b0:	60e2                	ld	ra,24(sp)
    800050b2:	6442                	ld	s0,16(sp)
    800050b4:	64a2                	ld	s1,8(sp)
    800050b6:	6105                	addi	sp,sp,32
    800050b8:	8082                	ret
      p->ofile[fd] = f;
    800050ba:	01a50793          	addi	a5,a0,26
    800050be:	078e                	slli	a5,a5,0x3
    800050c0:	963e                	add	a2,a2,a5
    800050c2:	e204                	sd	s1,0(a2)
      return fd;
    800050c4:	b7f5                	j	800050b0 <fdalloc+0x2c>

00000000800050c6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050c6:	715d                	addi	sp,sp,-80
    800050c8:	e486                	sd	ra,72(sp)
    800050ca:	e0a2                	sd	s0,64(sp)
    800050cc:	fc26                	sd	s1,56(sp)
    800050ce:	f84a                	sd	s2,48(sp)
    800050d0:	f44e                	sd	s3,40(sp)
    800050d2:	f052                	sd	s4,32(sp)
    800050d4:	ec56                	sd	s5,24(sp)
    800050d6:	0880                	addi	s0,sp,80
    800050d8:	89ae                	mv	s3,a1
    800050da:	8ab2                	mv	s5,a2
    800050dc:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050de:	fb040593          	addi	a1,s0,-80
    800050e2:	fffff097          	auipc	ra,0xfffff
    800050e6:	e4c080e7          	jalr	-436(ra) # 80003f2e <nameiparent>
    800050ea:	892a                	mv	s2,a0
    800050ec:	12050e63          	beqz	a0,80005228 <create+0x162>
    return 0;

  ilock(dp);
    800050f0:	ffffe097          	auipc	ra,0xffffe
    800050f4:	66c080e7          	jalr	1644(ra) # 8000375c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050f8:	4601                	li	a2,0
    800050fa:	fb040593          	addi	a1,s0,-80
    800050fe:	854a                	mv	a0,s2
    80005100:	fffff097          	auipc	ra,0xfffff
    80005104:	b3e080e7          	jalr	-1218(ra) # 80003c3e <dirlookup>
    80005108:	84aa                	mv	s1,a0
    8000510a:	c921                	beqz	a0,8000515a <create+0x94>
    iunlockput(dp);
    8000510c:	854a                	mv	a0,s2
    8000510e:	fffff097          	auipc	ra,0xfffff
    80005112:	8b0080e7          	jalr	-1872(ra) # 800039be <iunlockput>
    ilock(ip);
    80005116:	8526                	mv	a0,s1
    80005118:	ffffe097          	auipc	ra,0xffffe
    8000511c:	644080e7          	jalr	1604(ra) # 8000375c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005120:	2981                	sext.w	s3,s3
    80005122:	4789                	li	a5,2
    80005124:	02f99463          	bne	s3,a5,8000514c <create+0x86>
    80005128:	0444d783          	lhu	a5,68(s1)
    8000512c:	37f9                	addiw	a5,a5,-2
    8000512e:	17c2                	slli	a5,a5,0x30
    80005130:	93c1                	srli	a5,a5,0x30
    80005132:	4705                	li	a4,1
    80005134:	00f76c63          	bltu	a4,a5,8000514c <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005138:	8526                	mv	a0,s1
    8000513a:	60a6                	ld	ra,72(sp)
    8000513c:	6406                	ld	s0,64(sp)
    8000513e:	74e2                	ld	s1,56(sp)
    80005140:	7942                	ld	s2,48(sp)
    80005142:	79a2                	ld	s3,40(sp)
    80005144:	7a02                	ld	s4,32(sp)
    80005146:	6ae2                	ld	s5,24(sp)
    80005148:	6161                	addi	sp,sp,80
    8000514a:	8082                	ret
    iunlockput(ip);
    8000514c:	8526                	mv	a0,s1
    8000514e:	fffff097          	auipc	ra,0xfffff
    80005152:	870080e7          	jalr	-1936(ra) # 800039be <iunlockput>
    return 0;
    80005156:	4481                	li	s1,0
    80005158:	b7c5                	j	80005138 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000515a:	85ce                	mv	a1,s3
    8000515c:	00092503          	lw	a0,0(s2)
    80005160:	ffffe097          	auipc	ra,0xffffe
    80005164:	464080e7          	jalr	1124(ra) # 800035c4 <ialloc>
    80005168:	84aa                	mv	s1,a0
    8000516a:	c521                	beqz	a0,800051b2 <create+0xec>
  ilock(ip);
    8000516c:	ffffe097          	auipc	ra,0xffffe
    80005170:	5f0080e7          	jalr	1520(ra) # 8000375c <ilock>
  ip->major = major;
    80005174:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005178:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000517c:	4a05                	li	s4,1
    8000517e:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005182:	8526                	mv	a0,s1
    80005184:	ffffe097          	auipc	ra,0xffffe
    80005188:	50e080e7          	jalr	1294(ra) # 80003692 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000518c:	2981                	sext.w	s3,s3
    8000518e:	03498a63          	beq	s3,s4,800051c2 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005192:	40d0                	lw	a2,4(s1)
    80005194:	fb040593          	addi	a1,s0,-80
    80005198:	854a                	mv	a0,s2
    8000519a:	fffff097          	auipc	ra,0xfffff
    8000519e:	cb4080e7          	jalr	-844(ra) # 80003e4e <dirlink>
    800051a2:	06054b63          	bltz	a0,80005218 <create+0x152>
  iunlockput(dp);
    800051a6:	854a                	mv	a0,s2
    800051a8:	fffff097          	auipc	ra,0xfffff
    800051ac:	816080e7          	jalr	-2026(ra) # 800039be <iunlockput>
  return ip;
    800051b0:	b761                	j	80005138 <create+0x72>
    panic("create: ialloc");
    800051b2:	00003517          	auipc	a0,0x3
    800051b6:	52650513          	addi	a0,a0,1318 # 800086d8 <syscalls+0x2b0>
    800051ba:	ffffb097          	auipc	ra,0xffffb
    800051be:	388080e7          	jalr	904(ra) # 80000542 <panic>
    dp->nlink++;  // for ".."
    800051c2:	04a95783          	lhu	a5,74(s2)
    800051c6:	2785                	addiw	a5,a5,1
    800051c8:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800051cc:	854a                	mv	a0,s2
    800051ce:	ffffe097          	auipc	ra,0xffffe
    800051d2:	4c4080e7          	jalr	1220(ra) # 80003692 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051d6:	40d0                	lw	a2,4(s1)
    800051d8:	00003597          	auipc	a1,0x3
    800051dc:	51058593          	addi	a1,a1,1296 # 800086e8 <syscalls+0x2c0>
    800051e0:	8526                	mv	a0,s1
    800051e2:	fffff097          	auipc	ra,0xfffff
    800051e6:	c6c080e7          	jalr	-916(ra) # 80003e4e <dirlink>
    800051ea:	00054f63          	bltz	a0,80005208 <create+0x142>
    800051ee:	00492603          	lw	a2,4(s2)
    800051f2:	00003597          	auipc	a1,0x3
    800051f6:	4fe58593          	addi	a1,a1,1278 # 800086f0 <syscalls+0x2c8>
    800051fa:	8526                	mv	a0,s1
    800051fc:	fffff097          	auipc	ra,0xfffff
    80005200:	c52080e7          	jalr	-942(ra) # 80003e4e <dirlink>
    80005204:	f80557e3          	bgez	a0,80005192 <create+0xcc>
      panic("create dots");
    80005208:	00003517          	auipc	a0,0x3
    8000520c:	4f050513          	addi	a0,a0,1264 # 800086f8 <syscalls+0x2d0>
    80005210:	ffffb097          	auipc	ra,0xffffb
    80005214:	332080e7          	jalr	818(ra) # 80000542 <panic>
    panic("create: dirlink");
    80005218:	00003517          	auipc	a0,0x3
    8000521c:	4f050513          	addi	a0,a0,1264 # 80008708 <syscalls+0x2e0>
    80005220:	ffffb097          	auipc	ra,0xffffb
    80005224:	322080e7          	jalr	802(ra) # 80000542 <panic>
    return 0;
    80005228:	84aa                	mv	s1,a0
    8000522a:	b739                	j	80005138 <create+0x72>

000000008000522c <sys_dup>:
{
    8000522c:	7179                	addi	sp,sp,-48
    8000522e:	f406                	sd	ra,40(sp)
    80005230:	f022                	sd	s0,32(sp)
    80005232:	ec26                	sd	s1,24(sp)
    80005234:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005236:	fd840613          	addi	a2,s0,-40
    8000523a:	4581                	li	a1,0
    8000523c:	4501                	li	a0,0
    8000523e:	00000097          	auipc	ra,0x0
    80005242:	dde080e7          	jalr	-546(ra) # 8000501c <argfd>
    return -1;
    80005246:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005248:	02054363          	bltz	a0,8000526e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000524c:	fd843503          	ld	a0,-40(s0)
    80005250:	00000097          	auipc	ra,0x0
    80005254:	e34080e7          	jalr	-460(ra) # 80005084 <fdalloc>
    80005258:	84aa                	mv	s1,a0
    return -1;
    8000525a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000525c:	00054963          	bltz	a0,8000526e <sys_dup+0x42>
  filedup(f);
    80005260:	fd843503          	ld	a0,-40(s0)
    80005264:	fffff097          	auipc	ra,0xfffff
    80005268:	338080e7          	jalr	824(ra) # 8000459c <filedup>
  return fd;
    8000526c:	87a6                	mv	a5,s1
}
    8000526e:	853e                	mv	a0,a5
    80005270:	70a2                	ld	ra,40(sp)
    80005272:	7402                	ld	s0,32(sp)
    80005274:	64e2                	ld	s1,24(sp)
    80005276:	6145                	addi	sp,sp,48
    80005278:	8082                	ret

000000008000527a <sys_read>:
{
    8000527a:	7179                	addi	sp,sp,-48
    8000527c:	f406                	sd	ra,40(sp)
    8000527e:	f022                	sd	s0,32(sp)
    80005280:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005282:	fe840613          	addi	a2,s0,-24
    80005286:	4581                	li	a1,0
    80005288:	4501                	li	a0,0
    8000528a:	00000097          	auipc	ra,0x0
    8000528e:	d92080e7          	jalr	-622(ra) # 8000501c <argfd>
    return -1;
    80005292:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005294:	04054163          	bltz	a0,800052d6 <sys_read+0x5c>
    80005298:	fe440593          	addi	a1,s0,-28
    8000529c:	4509                	li	a0,2
    8000529e:	ffffe097          	auipc	ra,0xffffe
    800052a2:	94e080e7          	jalr	-1714(ra) # 80002bec <argint>
    return -1;
    800052a6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052a8:	02054763          	bltz	a0,800052d6 <sys_read+0x5c>
    800052ac:	fd840593          	addi	a1,s0,-40
    800052b0:	4505                	li	a0,1
    800052b2:	ffffe097          	auipc	ra,0xffffe
    800052b6:	95c080e7          	jalr	-1700(ra) # 80002c0e <argaddr>
    return -1;
    800052ba:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052bc:	00054d63          	bltz	a0,800052d6 <sys_read+0x5c>
  return fileread(f, p, n);
    800052c0:	fe442603          	lw	a2,-28(s0)
    800052c4:	fd843583          	ld	a1,-40(s0)
    800052c8:	fe843503          	ld	a0,-24(s0)
    800052cc:	fffff097          	auipc	ra,0xfffff
    800052d0:	45c080e7          	jalr	1116(ra) # 80004728 <fileread>
    800052d4:	87aa                	mv	a5,a0
}
    800052d6:	853e                	mv	a0,a5
    800052d8:	70a2                	ld	ra,40(sp)
    800052da:	7402                	ld	s0,32(sp)
    800052dc:	6145                	addi	sp,sp,48
    800052de:	8082                	ret

00000000800052e0 <sys_write>:
{
    800052e0:	7179                	addi	sp,sp,-48
    800052e2:	f406                	sd	ra,40(sp)
    800052e4:	f022                	sd	s0,32(sp)
    800052e6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052e8:	fe840613          	addi	a2,s0,-24
    800052ec:	4581                	li	a1,0
    800052ee:	4501                	li	a0,0
    800052f0:	00000097          	auipc	ra,0x0
    800052f4:	d2c080e7          	jalr	-724(ra) # 8000501c <argfd>
    return -1;
    800052f8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052fa:	04054163          	bltz	a0,8000533c <sys_write+0x5c>
    800052fe:	fe440593          	addi	a1,s0,-28
    80005302:	4509                	li	a0,2
    80005304:	ffffe097          	auipc	ra,0xffffe
    80005308:	8e8080e7          	jalr	-1816(ra) # 80002bec <argint>
    return -1;
    8000530c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000530e:	02054763          	bltz	a0,8000533c <sys_write+0x5c>
    80005312:	fd840593          	addi	a1,s0,-40
    80005316:	4505                	li	a0,1
    80005318:	ffffe097          	auipc	ra,0xffffe
    8000531c:	8f6080e7          	jalr	-1802(ra) # 80002c0e <argaddr>
    return -1;
    80005320:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005322:	00054d63          	bltz	a0,8000533c <sys_write+0x5c>
  return filewrite(f, p, n);
    80005326:	fe442603          	lw	a2,-28(s0)
    8000532a:	fd843583          	ld	a1,-40(s0)
    8000532e:	fe843503          	ld	a0,-24(s0)
    80005332:	fffff097          	auipc	ra,0xfffff
    80005336:	4b8080e7          	jalr	1208(ra) # 800047ea <filewrite>
    8000533a:	87aa                	mv	a5,a0
}
    8000533c:	853e                	mv	a0,a5
    8000533e:	70a2                	ld	ra,40(sp)
    80005340:	7402                	ld	s0,32(sp)
    80005342:	6145                	addi	sp,sp,48
    80005344:	8082                	ret

0000000080005346 <sys_close>:
{
    80005346:	1101                	addi	sp,sp,-32
    80005348:	ec06                	sd	ra,24(sp)
    8000534a:	e822                	sd	s0,16(sp)
    8000534c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000534e:	fe040613          	addi	a2,s0,-32
    80005352:	fec40593          	addi	a1,s0,-20
    80005356:	4501                	li	a0,0
    80005358:	00000097          	auipc	ra,0x0
    8000535c:	cc4080e7          	jalr	-828(ra) # 8000501c <argfd>
    return -1;
    80005360:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005362:	02054463          	bltz	a0,8000538a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005366:	ffffc097          	auipc	ra,0xffffc
    8000536a:	7a0080e7          	jalr	1952(ra) # 80001b06 <myproc>
    8000536e:	fec42783          	lw	a5,-20(s0)
    80005372:	07e9                	addi	a5,a5,26
    80005374:	078e                	slli	a5,a5,0x3
    80005376:	97aa                	add	a5,a5,a0
    80005378:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000537c:	fe043503          	ld	a0,-32(s0)
    80005380:	fffff097          	auipc	ra,0xfffff
    80005384:	26e080e7          	jalr	622(ra) # 800045ee <fileclose>
  return 0;
    80005388:	4781                	li	a5,0
}
    8000538a:	853e                	mv	a0,a5
    8000538c:	60e2                	ld	ra,24(sp)
    8000538e:	6442                	ld	s0,16(sp)
    80005390:	6105                	addi	sp,sp,32
    80005392:	8082                	ret

0000000080005394 <sys_fstat>:
{
    80005394:	1101                	addi	sp,sp,-32
    80005396:	ec06                	sd	ra,24(sp)
    80005398:	e822                	sd	s0,16(sp)
    8000539a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000539c:	fe840613          	addi	a2,s0,-24
    800053a0:	4581                	li	a1,0
    800053a2:	4501                	li	a0,0
    800053a4:	00000097          	auipc	ra,0x0
    800053a8:	c78080e7          	jalr	-904(ra) # 8000501c <argfd>
    return -1;
    800053ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053ae:	02054563          	bltz	a0,800053d8 <sys_fstat+0x44>
    800053b2:	fe040593          	addi	a1,s0,-32
    800053b6:	4505                	li	a0,1
    800053b8:	ffffe097          	auipc	ra,0xffffe
    800053bc:	856080e7          	jalr	-1962(ra) # 80002c0e <argaddr>
    return -1;
    800053c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053c2:	00054b63          	bltz	a0,800053d8 <sys_fstat+0x44>
  return filestat(f, st);
    800053c6:	fe043583          	ld	a1,-32(s0)
    800053ca:	fe843503          	ld	a0,-24(s0)
    800053ce:	fffff097          	auipc	ra,0xfffff
    800053d2:	2e8080e7          	jalr	744(ra) # 800046b6 <filestat>
    800053d6:	87aa                	mv	a5,a0
}
    800053d8:	853e                	mv	a0,a5
    800053da:	60e2                	ld	ra,24(sp)
    800053dc:	6442                	ld	s0,16(sp)
    800053de:	6105                	addi	sp,sp,32
    800053e0:	8082                	ret

00000000800053e2 <sys_link>:
{
    800053e2:	7169                	addi	sp,sp,-304
    800053e4:	f606                	sd	ra,296(sp)
    800053e6:	f222                	sd	s0,288(sp)
    800053e8:	ee26                	sd	s1,280(sp)
    800053ea:	ea4a                	sd	s2,272(sp)
    800053ec:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053ee:	08000613          	li	a2,128
    800053f2:	ed040593          	addi	a1,s0,-304
    800053f6:	4501                	li	a0,0
    800053f8:	ffffe097          	auipc	ra,0xffffe
    800053fc:	838080e7          	jalr	-1992(ra) # 80002c30 <argstr>
    return -1;
    80005400:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005402:	10054e63          	bltz	a0,8000551e <sys_link+0x13c>
    80005406:	08000613          	li	a2,128
    8000540a:	f5040593          	addi	a1,s0,-176
    8000540e:	4505                	li	a0,1
    80005410:	ffffe097          	auipc	ra,0xffffe
    80005414:	820080e7          	jalr	-2016(ra) # 80002c30 <argstr>
    return -1;
    80005418:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000541a:	10054263          	bltz	a0,8000551e <sys_link+0x13c>
  begin_op();
    8000541e:	fffff097          	auipc	ra,0xfffff
    80005422:	cfe080e7          	jalr	-770(ra) # 8000411c <begin_op>
  if((ip = namei(old)) == 0){
    80005426:	ed040513          	addi	a0,s0,-304
    8000542a:	fffff097          	auipc	ra,0xfffff
    8000542e:	ae6080e7          	jalr	-1306(ra) # 80003f10 <namei>
    80005432:	84aa                	mv	s1,a0
    80005434:	c551                	beqz	a0,800054c0 <sys_link+0xde>
  ilock(ip);
    80005436:	ffffe097          	auipc	ra,0xffffe
    8000543a:	326080e7          	jalr	806(ra) # 8000375c <ilock>
  if(ip->type == T_DIR){
    8000543e:	04449703          	lh	a4,68(s1)
    80005442:	4785                	li	a5,1
    80005444:	08f70463          	beq	a4,a5,800054cc <sys_link+0xea>
  ip->nlink++;
    80005448:	04a4d783          	lhu	a5,74(s1)
    8000544c:	2785                	addiw	a5,a5,1
    8000544e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005452:	8526                	mv	a0,s1
    80005454:	ffffe097          	auipc	ra,0xffffe
    80005458:	23e080e7          	jalr	574(ra) # 80003692 <iupdate>
  iunlock(ip);
    8000545c:	8526                	mv	a0,s1
    8000545e:	ffffe097          	auipc	ra,0xffffe
    80005462:	3c0080e7          	jalr	960(ra) # 8000381e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005466:	fd040593          	addi	a1,s0,-48
    8000546a:	f5040513          	addi	a0,s0,-176
    8000546e:	fffff097          	auipc	ra,0xfffff
    80005472:	ac0080e7          	jalr	-1344(ra) # 80003f2e <nameiparent>
    80005476:	892a                	mv	s2,a0
    80005478:	c935                	beqz	a0,800054ec <sys_link+0x10a>
  ilock(dp);
    8000547a:	ffffe097          	auipc	ra,0xffffe
    8000547e:	2e2080e7          	jalr	738(ra) # 8000375c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005482:	00092703          	lw	a4,0(s2)
    80005486:	409c                	lw	a5,0(s1)
    80005488:	04f71d63          	bne	a4,a5,800054e2 <sys_link+0x100>
    8000548c:	40d0                	lw	a2,4(s1)
    8000548e:	fd040593          	addi	a1,s0,-48
    80005492:	854a                	mv	a0,s2
    80005494:	fffff097          	auipc	ra,0xfffff
    80005498:	9ba080e7          	jalr	-1606(ra) # 80003e4e <dirlink>
    8000549c:	04054363          	bltz	a0,800054e2 <sys_link+0x100>
  iunlockput(dp);
    800054a0:	854a                	mv	a0,s2
    800054a2:	ffffe097          	auipc	ra,0xffffe
    800054a6:	51c080e7          	jalr	1308(ra) # 800039be <iunlockput>
  iput(ip);
    800054aa:	8526                	mv	a0,s1
    800054ac:	ffffe097          	auipc	ra,0xffffe
    800054b0:	46a080e7          	jalr	1130(ra) # 80003916 <iput>
  end_op();
    800054b4:	fffff097          	auipc	ra,0xfffff
    800054b8:	ce8080e7          	jalr	-792(ra) # 8000419c <end_op>
  return 0;
    800054bc:	4781                	li	a5,0
    800054be:	a085                	j	8000551e <sys_link+0x13c>
    end_op();
    800054c0:	fffff097          	auipc	ra,0xfffff
    800054c4:	cdc080e7          	jalr	-804(ra) # 8000419c <end_op>
    return -1;
    800054c8:	57fd                	li	a5,-1
    800054ca:	a891                	j	8000551e <sys_link+0x13c>
    iunlockput(ip);
    800054cc:	8526                	mv	a0,s1
    800054ce:	ffffe097          	auipc	ra,0xffffe
    800054d2:	4f0080e7          	jalr	1264(ra) # 800039be <iunlockput>
    end_op();
    800054d6:	fffff097          	auipc	ra,0xfffff
    800054da:	cc6080e7          	jalr	-826(ra) # 8000419c <end_op>
    return -1;
    800054de:	57fd                	li	a5,-1
    800054e0:	a83d                	j	8000551e <sys_link+0x13c>
    iunlockput(dp);
    800054e2:	854a                	mv	a0,s2
    800054e4:	ffffe097          	auipc	ra,0xffffe
    800054e8:	4da080e7          	jalr	1242(ra) # 800039be <iunlockput>
  ilock(ip);
    800054ec:	8526                	mv	a0,s1
    800054ee:	ffffe097          	auipc	ra,0xffffe
    800054f2:	26e080e7          	jalr	622(ra) # 8000375c <ilock>
  ip->nlink--;
    800054f6:	04a4d783          	lhu	a5,74(s1)
    800054fa:	37fd                	addiw	a5,a5,-1
    800054fc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005500:	8526                	mv	a0,s1
    80005502:	ffffe097          	auipc	ra,0xffffe
    80005506:	190080e7          	jalr	400(ra) # 80003692 <iupdate>
  iunlockput(ip);
    8000550a:	8526                	mv	a0,s1
    8000550c:	ffffe097          	auipc	ra,0xffffe
    80005510:	4b2080e7          	jalr	1202(ra) # 800039be <iunlockput>
  end_op();
    80005514:	fffff097          	auipc	ra,0xfffff
    80005518:	c88080e7          	jalr	-888(ra) # 8000419c <end_op>
  return -1;
    8000551c:	57fd                	li	a5,-1
}
    8000551e:	853e                	mv	a0,a5
    80005520:	70b2                	ld	ra,296(sp)
    80005522:	7412                	ld	s0,288(sp)
    80005524:	64f2                	ld	s1,280(sp)
    80005526:	6952                	ld	s2,272(sp)
    80005528:	6155                	addi	sp,sp,304
    8000552a:	8082                	ret

000000008000552c <sys_unlink>:
{
    8000552c:	7151                	addi	sp,sp,-240
    8000552e:	f586                	sd	ra,232(sp)
    80005530:	f1a2                	sd	s0,224(sp)
    80005532:	eda6                	sd	s1,216(sp)
    80005534:	e9ca                	sd	s2,208(sp)
    80005536:	e5ce                	sd	s3,200(sp)
    80005538:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000553a:	08000613          	li	a2,128
    8000553e:	f3040593          	addi	a1,s0,-208
    80005542:	4501                	li	a0,0
    80005544:	ffffd097          	auipc	ra,0xffffd
    80005548:	6ec080e7          	jalr	1772(ra) # 80002c30 <argstr>
    8000554c:	18054163          	bltz	a0,800056ce <sys_unlink+0x1a2>
  begin_op();
    80005550:	fffff097          	auipc	ra,0xfffff
    80005554:	bcc080e7          	jalr	-1076(ra) # 8000411c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005558:	fb040593          	addi	a1,s0,-80
    8000555c:	f3040513          	addi	a0,s0,-208
    80005560:	fffff097          	auipc	ra,0xfffff
    80005564:	9ce080e7          	jalr	-1586(ra) # 80003f2e <nameiparent>
    80005568:	84aa                	mv	s1,a0
    8000556a:	c979                	beqz	a0,80005640 <sys_unlink+0x114>
  ilock(dp);
    8000556c:	ffffe097          	auipc	ra,0xffffe
    80005570:	1f0080e7          	jalr	496(ra) # 8000375c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005574:	00003597          	auipc	a1,0x3
    80005578:	17458593          	addi	a1,a1,372 # 800086e8 <syscalls+0x2c0>
    8000557c:	fb040513          	addi	a0,s0,-80
    80005580:	ffffe097          	auipc	ra,0xffffe
    80005584:	6a4080e7          	jalr	1700(ra) # 80003c24 <namecmp>
    80005588:	14050a63          	beqz	a0,800056dc <sys_unlink+0x1b0>
    8000558c:	00003597          	auipc	a1,0x3
    80005590:	16458593          	addi	a1,a1,356 # 800086f0 <syscalls+0x2c8>
    80005594:	fb040513          	addi	a0,s0,-80
    80005598:	ffffe097          	auipc	ra,0xffffe
    8000559c:	68c080e7          	jalr	1676(ra) # 80003c24 <namecmp>
    800055a0:	12050e63          	beqz	a0,800056dc <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800055a4:	f2c40613          	addi	a2,s0,-212
    800055a8:	fb040593          	addi	a1,s0,-80
    800055ac:	8526                	mv	a0,s1
    800055ae:	ffffe097          	auipc	ra,0xffffe
    800055b2:	690080e7          	jalr	1680(ra) # 80003c3e <dirlookup>
    800055b6:	892a                	mv	s2,a0
    800055b8:	12050263          	beqz	a0,800056dc <sys_unlink+0x1b0>
  ilock(ip);
    800055bc:	ffffe097          	auipc	ra,0xffffe
    800055c0:	1a0080e7          	jalr	416(ra) # 8000375c <ilock>
  if(ip->nlink < 1)
    800055c4:	04a91783          	lh	a5,74(s2)
    800055c8:	08f05263          	blez	a5,8000564c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800055cc:	04491703          	lh	a4,68(s2)
    800055d0:	4785                	li	a5,1
    800055d2:	08f70563          	beq	a4,a5,8000565c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800055d6:	4641                	li	a2,16
    800055d8:	4581                	li	a1,0
    800055da:	fc040513          	addi	a0,s0,-64
    800055de:	ffffc097          	auipc	ra,0xffffc
    800055e2:	82c080e7          	jalr	-2004(ra) # 80000e0a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055e6:	4741                	li	a4,16
    800055e8:	f2c42683          	lw	a3,-212(s0)
    800055ec:	fc040613          	addi	a2,s0,-64
    800055f0:	4581                	li	a1,0
    800055f2:	8526                	mv	a0,s1
    800055f4:	ffffe097          	auipc	ra,0xffffe
    800055f8:	514080e7          	jalr	1300(ra) # 80003b08 <writei>
    800055fc:	47c1                	li	a5,16
    800055fe:	0af51563          	bne	a0,a5,800056a8 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005602:	04491703          	lh	a4,68(s2)
    80005606:	4785                	li	a5,1
    80005608:	0af70863          	beq	a4,a5,800056b8 <sys_unlink+0x18c>
  iunlockput(dp);
    8000560c:	8526                	mv	a0,s1
    8000560e:	ffffe097          	auipc	ra,0xffffe
    80005612:	3b0080e7          	jalr	944(ra) # 800039be <iunlockput>
  ip->nlink--;
    80005616:	04a95783          	lhu	a5,74(s2)
    8000561a:	37fd                	addiw	a5,a5,-1
    8000561c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005620:	854a                	mv	a0,s2
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	070080e7          	jalr	112(ra) # 80003692 <iupdate>
  iunlockput(ip);
    8000562a:	854a                	mv	a0,s2
    8000562c:	ffffe097          	auipc	ra,0xffffe
    80005630:	392080e7          	jalr	914(ra) # 800039be <iunlockput>
  end_op();
    80005634:	fffff097          	auipc	ra,0xfffff
    80005638:	b68080e7          	jalr	-1176(ra) # 8000419c <end_op>
  return 0;
    8000563c:	4501                	li	a0,0
    8000563e:	a84d                	j	800056f0 <sys_unlink+0x1c4>
    end_op();
    80005640:	fffff097          	auipc	ra,0xfffff
    80005644:	b5c080e7          	jalr	-1188(ra) # 8000419c <end_op>
    return -1;
    80005648:	557d                	li	a0,-1
    8000564a:	a05d                	j	800056f0 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000564c:	00003517          	auipc	a0,0x3
    80005650:	0cc50513          	addi	a0,a0,204 # 80008718 <syscalls+0x2f0>
    80005654:	ffffb097          	auipc	ra,0xffffb
    80005658:	eee080e7          	jalr	-274(ra) # 80000542 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000565c:	04c92703          	lw	a4,76(s2)
    80005660:	02000793          	li	a5,32
    80005664:	f6e7f9e3          	bgeu	a5,a4,800055d6 <sys_unlink+0xaa>
    80005668:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000566c:	4741                	li	a4,16
    8000566e:	86ce                	mv	a3,s3
    80005670:	f1840613          	addi	a2,s0,-232
    80005674:	4581                	li	a1,0
    80005676:	854a                	mv	a0,s2
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	398080e7          	jalr	920(ra) # 80003a10 <readi>
    80005680:	47c1                	li	a5,16
    80005682:	00f51b63          	bne	a0,a5,80005698 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005686:	f1845783          	lhu	a5,-232(s0)
    8000568a:	e7a1                	bnez	a5,800056d2 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000568c:	29c1                	addiw	s3,s3,16
    8000568e:	04c92783          	lw	a5,76(s2)
    80005692:	fcf9ede3          	bltu	s3,a5,8000566c <sys_unlink+0x140>
    80005696:	b781                	j	800055d6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005698:	00003517          	auipc	a0,0x3
    8000569c:	09850513          	addi	a0,a0,152 # 80008730 <syscalls+0x308>
    800056a0:	ffffb097          	auipc	ra,0xffffb
    800056a4:	ea2080e7          	jalr	-350(ra) # 80000542 <panic>
    panic("unlink: writei");
    800056a8:	00003517          	auipc	a0,0x3
    800056ac:	0a050513          	addi	a0,a0,160 # 80008748 <syscalls+0x320>
    800056b0:	ffffb097          	auipc	ra,0xffffb
    800056b4:	e92080e7          	jalr	-366(ra) # 80000542 <panic>
    dp->nlink--;
    800056b8:	04a4d783          	lhu	a5,74(s1)
    800056bc:	37fd                	addiw	a5,a5,-1
    800056be:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056c2:	8526                	mv	a0,s1
    800056c4:	ffffe097          	auipc	ra,0xffffe
    800056c8:	fce080e7          	jalr	-50(ra) # 80003692 <iupdate>
    800056cc:	b781                	j	8000560c <sys_unlink+0xe0>
    return -1;
    800056ce:	557d                	li	a0,-1
    800056d0:	a005                	j	800056f0 <sys_unlink+0x1c4>
    iunlockput(ip);
    800056d2:	854a                	mv	a0,s2
    800056d4:	ffffe097          	auipc	ra,0xffffe
    800056d8:	2ea080e7          	jalr	746(ra) # 800039be <iunlockput>
  iunlockput(dp);
    800056dc:	8526                	mv	a0,s1
    800056de:	ffffe097          	auipc	ra,0xffffe
    800056e2:	2e0080e7          	jalr	736(ra) # 800039be <iunlockput>
  end_op();
    800056e6:	fffff097          	auipc	ra,0xfffff
    800056ea:	ab6080e7          	jalr	-1354(ra) # 8000419c <end_op>
  return -1;
    800056ee:	557d                	li	a0,-1
}
    800056f0:	70ae                	ld	ra,232(sp)
    800056f2:	740e                	ld	s0,224(sp)
    800056f4:	64ee                	ld	s1,216(sp)
    800056f6:	694e                	ld	s2,208(sp)
    800056f8:	69ae                	ld	s3,200(sp)
    800056fa:	616d                	addi	sp,sp,240
    800056fc:	8082                	ret

00000000800056fe <sys_open>:

uint64
sys_open(void)
{
    800056fe:	7131                	addi	sp,sp,-192
    80005700:	fd06                	sd	ra,184(sp)
    80005702:	f922                	sd	s0,176(sp)
    80005704:	f526                	sd	s1,168(sp)
    80005706:	f14a                	sd	s2,160(sp)
    80005708:	ed4e                	sd	s3,152(sp)
    8000570a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000570c:	08000613          	li	a2,128
    80005710:	f5040593          	addi	a1,s0,-176
    80005714:	4501                	li	a0,0
    80005716:	ffffd097          	auipc	ra,0xffffd
    8000571a:	51a080e7          	jalr	1306(ra) # 80002c30 <argstr>
    return -1;
    8000571e:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005720:	0c054163          	bltz	a0,800057e2 <sys_open+0xe4>
    80005724:	f4c40593          	addi	a1,s0,-180
    80005728:	4505                	li	a0,1
    8000572a:	ffffd097          	auipc	ra,0xffffd
    8000572e:	4c2080e7          	jalr	1218(ra) # 80002bec <argint>
    80005732:	0a054863          	bltz	a0,800057e2 <sys_open+0xe4>

  begin_op();
    80005736:	fffff097          	auipc	ra,0xfffff
    8000573a:	9e6080e7          	jalr	-1562(ra) # 8000411c <begin_op>

  if(omode & O_CREATE){
    8000573e:	f4c42783          	lw	a5,-180(s0)
    80005742:	2007f793          	andi	a5,a5,512
    80005746:	cbdd                	beqz	a5,800057fc <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005748:	4681                	li	a3,0
    8000574a:	4601                	li	a2,0
    8000574c:	4589                	li	a1,2
    8000574e:	f5040513          	addi	a0,s0,-176
    80005752:	00000097          	auipc	ra,0x0
    80005756:	974080e7          	jalr	-1676(ra) # 800050c6 <create>
    8000575a:	892a                	mv	s2,a0
    if(ip == 0){
    8000575c:	c959                	beqz	a0,800057f2 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000575e:	04491703          	lh	a4,68(s2)
    80005762:	478d                	li	a5,3
    80005764:	00f71763          	bne	a4,a5,80005772 <sys_open+0x74>
    80005768:	04695703          	lhu	a4,70(s2)
    8000576c:	47a5                	li	a5,9
    8000576e:	0ce7ec63          	bltu	a5,a4,80005846 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005772:	fffff097          	auipc	ra,0xfffff
    80005776:	dc0080e7          	jalr	-576(ra) # 80004532 <filealloc>
    8000577a:	89aa                	mv	s3,a0
    8000577c:	10050263          	beqz	a0,80005880 <sys_open+0x182>
    80005780:	00000097          	auipc	ra,0x0
    80005784:	904080e7          	jalr	-1788(ra) # 80005084 <fdalloc>
    80005788:	84aa                	mv	s1,a0
    8000578a:	0e054663          	bltz	a0,80005876 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000578e:	04491703          	lh	a4,68(s2)
    80005792:	478d                	li	a5,3
    80005794:	0cf70463          	beq	a4,a5,8000585c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005798:	4789                	li	a5,2
    8000579a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000579e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800057a2:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800057a6:	f4c42783          	lw	a5,-180(s0)
    800057aa:	0017c713          	xori	a4,a5,1
    800057ae:	8b05                	andi	a4,a4,1
    800057b0:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057b4:	0037f713          	andi	a4,a5,3
    800057b8:	00e03733          	snez	a4,a4
    800057bc:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800057c0:	4007f793          	andi	a5,a5,1024
    800057c4:	c791                	beqz	a5,800057d0 <sys_open+0xd2>
    800057c6:	04491703          	lh	a4,68(s2)
    800057ca:	4789                	li	a5,2
    800057cc:	08f70f63          	beq	a4,a5,8000586a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800057d0:	854a                	mv	a0,s2
    800057d2:	ffffe097          	auipc	ra,0xffffe
    800057d6:	04c080e7          	jalr	76(ra) # 8000381e <iunlock>
  end_op();
    800057da:	fffff097          	auipc	ra,0xfffff
    800057de:	9c2080e7          	jalr	-1598(ra) # 8000419c <end_op>

  return fd;
}
    800057e2:	8526                	mv	a0,s1
    800057e4:	70ea                	ld	ra,184(sp)
    800057e6:	744a                	ld	s0,176(sp)
    800057e8:	74aa                	ld	s1,168(sp)
    800057ea:	790a                	ld	s2,160(sp)
    800057ec:	69ea                	ld	s3,152(sp)
    800057ee:	6129                	addi	sp,sp,192
    800057f0:	8082                	ret
      end_op();
    800057f2:	fffff097          	auipc	ra,0xfffff
    800057f6:	9aa080e7          	jalr	-1622(ra) # 8000419c <end_op>
      return -1;
    800057fa:	b7e5                	j	800057e2 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800057fc:	f5040513          	addi	a0,s0,-176
    80005800:	ffffe097          	auipc	ra,0xffffe
    80005804:	710080e7          	jalr	1808(ra) # 80003f10 <namei>
    80005808:	892a                	mv	s2,a0
    8000580a:	c905                	beqz	a0,8000583a <sys_open+0x13c>
    ilock(ip);
    8000580c:	ffffe097          	auipc	ra,0xffffe
    80005810:	f50080e7          	jalr	-176(ra) # 8000375c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005814:	04491703          	lh	a4,68(s2)
    80005818:	4785                	li	a5,1
    8000581a:	f4f712e3          	bne	a4,a5,8000575e <sys_open+0x60>
    8000581e:	f4c42783          	lw	a5,-180(s0)
    80005822:	dba1                	beqz	a5,80005772 <sys_open+0x74>
      iunlockput(ip);
    80005824:	854a                	mv	a0,s2
    80005826:	ffffe097          	auipc	ra,0xffffe
    8000582a:	198080e7          	jalr	408(ra) # 800039be <iunlockput>
      end_op();
    8000582e:	fffff097          	auipc	ra,0xfffff
    80005832:	96e080e7          	jalr	-1682(ra) # 8000419c <end_op>
      return -1;
    80005836:	54fd                	li	s1,-1
    80005838:	b76d                	j	800057e2 <sys_open+0xe4>
      end_op();
    8000583a:	fffff097          	auipc	ra,0xfffff
    8000583e:	962080e7          	jalr	-1694(ra) # 8000419c <end_op>
      return -1;
    80005842:	54fd                	li	s1,-1
    80005844:	bf79                	j	800057e2 <sys_open+0xe4>
    iunlockput(ip);
    80005846:	854a                	mv	a0,s2
    80005848:	ffffe097          	auipc	ra,0xffffe
    8000584c:	176080e7          	jalr	374(ra) # 800039be <iunlockput>
    end_op();
    80005850:	fffff097          	auipc	ra,0xfffff
    80005854:	94c080e7          	jalr	-1716(ra) # 8000419c <end_op>
    return -1;
    80005858:	54fd                	li	s1,-1
    8000585a:	b761                	j	800057e2 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000585c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005860:	04691783          	lh	a5,70(s2)
    80005864:	02f99223          	sh	a5,36(s3)
    80005868:	bf2d                	j	800057a2 <sys_open+0xa4>
    itrunc(ip);
    8000586a:	854a                	mv	a0,s2
    8000586c:	ffffe097          	auipc	ra,0xffffe
    80005870:	ffe080e7          	jalr	-2(ra) # 8000386a <itrunc>
    80005874:	bfb1                	j	800057d0 <sys_open+0xd2>
      fileclose(f);
    80005876:	854e                	mv	a0,s3
    80005878:	fffff097          	auipc	ra,0xfffff
    8000587c:	d76080e7          	jalr	-650(ra) # 800045ee <fileclose>
    iunlockput(ip);
    80005880:	854a                	mv	a0,s2
    80005882:	ffffe097          	auipc	ra,0xffffe
    80005886:	13c080e7          	jalr	316(ra) # 800039be <iunlockput>
    end_op();
    8000588a:	fffff097          	auipc	ra,0xfffff
    8000588e:	912080e7          	jalr	-1774(ra) # 8000419c <end_op>
    return -1;
    80005892:	54fd                	li	s1,-1
    80005894:	b7b9                	j	800057e2 <sys_open+0xe4>

0000000080005896 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005896:	7175                	addi	sp,sp,-144
    80005898:	e506                	sd	ra,136(sp)
    8000589a:	e122                	sd	s0,128(sp)
    8000589c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000589e:	fffff097          	auipc	ra,0xfffff
    800058a2:	87e080e7          	jalr	-1922(ra) # 8000411c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058a6:	08000613          	li	a2,128
    800058aa:	f7040593          	addi	a1,s0,-144
    800058ae:	4501                	li	a0,0
    800058b0:	ffffd097          	auipc	ra,0xffffd
    800058b4:	380080e7          	jalr	896(ra) # 80002c30 <argstr>
    800058b8:	02054963          	bltz	a0,800058ea <sys_mkdir+0x54>
    800058bc:	4681                	li	a3,0
    800058be:	4601                	li	a2,0
    800058c0:	4585                	li	a1,1
    800058c2:	f7040513          	addi	a0,s0,-144
    800058c6:	00000097          	auipc	ra,0x0
    800058ca:	800080e7          	jalr	-2048(ra) # 800050c6 <create>
    800058ce:	cd11                	beqz	a0,800058ea <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058d0:	ffffe097          	auipc	ra,0xffffe
    800058d4:	0ee080e7          	jalr	238(ra) # 800039be <iunlockput>
  end_op();
    800058d8:	fffff097          	auipc	ra,0xfffff
    800058dc:	8c4080e7          	jalr	-1852(ra) # 8000419c <end_op>
  return 0;
    800058e0:	4501                	li	a0,0
}
    800058e2:	60aa                	ld	ra,136(sp)
    800058e4:	640a                	ld	s0,128(sp)
    800058e6:	6149                	addi	sp,sp,144
    800058e8:	8082                	ret
    end_op();
    800058ea:	fffff097          	auipc	ra,0xfffff
    800058ee:	8b2080e7          	jalr	-1870(ra) # 8000419c <end_op>
    return -1;
    800058f2:	557d                	li	a0,-1
    800058f4:	b7fd                	j	800058e2 <sys_mkdir+0x4c>

00000000800058f6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800058f6:	7135                	addi	sp,sp,-160
    800058f8:	ed06                	sd	ra,152(sp)
    800058fa:	e922                	sd	s0,144(sp)
    800058fc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058fe:	fffff097          	auipc	ra,0xfffff
    80005902:	81e080e7          	jalr	-2018(ra) # 8000411c <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005906:	08000613          	li	a2,128
    8000590a:	f7040593          	addi	a1,s0,-144
    8000590e:	4501                	li	a0,0
    80005910:	ffffd097          	auipc	ra,0xffffd
    80005914:	320080e7          	jalr	800(ra) # 80002c30 <argstr>
    80005918:	04054a63          	bltz	a0,8000596c <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000591c:	f6c40593          	addi	a1,s0,-148
    80005920:	4505                	li	a0,1
    80005922:	ffffd097          	auipc	ra,0xffffd
    80005926:	2ca080e7          	jalr	714(ra) # 80002bec <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000592a:	04054163          	bltz	a0,8000596c <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000592e:	f6840593          	addi	a1,s0,-152
    80005932:	4509                	li	a0,2
    80005934:	ffffd097          	auipc	ra,0xffffd
    80005938:	2b8080e7          	jalr	696(ra) # 80002bec <argint>
     argint(1, &major) < 0 ||
    8000593c:	02054863          	bltz	a0,8000596c <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005940:	f6841683          	lh	a3,-152(s0)
    80005944:	f6c41603          	lh	a2,-148(s0)
    80005948:	458d                	li	a1,3
    8000594a:	f7040513          	addi	a0,s0,-144
    8000594e:	fffff097          	auipc	ra,0xfffff
    80005952:	778080e7          	jalr	1912(ra) # 800050c6 <create>
     argint(2, &minor) < 0 ||
    80005956:	c919                	beqz	a0,8000596c <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005958:	ffffe097          	auipc	ra,0xffffe
    8000595c:	066080e7          	jalr	102(ra) # 800039be <iunlockput>
  end_op();
    80005960:	fffff097          	auipc	ra,0xfffff
    80005964:	83c080e7          	jalr	-1988(ra) # 8000419c <end_op>
  return 0;
    80005968:	4501                	li	a0,0
    8000596a:	a031                	j	80005976 <sys_mknod+0x80>
    end_op();
    8000596c:	fffff097          	auipc	ra,0xfffff
    80005970:	830080e7          	jalr	-2000(ra) # 8000419c <end_op>
    return -1;
    80005974:	557d                	li	a0,-1
}
    80005976:	60ea                	ld	ra,152(sp)
    80005978:	644a                	ld	s0,144(sp)
    8000597a:	610d                	addi	sp,sp,160
    8000597c:	8082                	ret

000000008000597e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000597e:	7135                	addi	sp,sp,-160
    80005980:	ed06                	sd	ra,152(sp)
    80005982:	e922                	sd	s0,144(sp)
    80005984:	e526                	sd	s1,136(sp)
    80005986:	e14a                	sd	s2,128(sp)
    80005988:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000598a:	ffffc097          	auipc	ra,0xffffc
    8000598e:	17c080e7          	jalr	380(ra) # 80001b06 <myproc>
    80005992:	892a                	mv	s2,a0
  
  begin_op();
    80005994:	ffffe097          	auipc	ra,0xffffe
    80005998:	788080e7          	jalr	1928(ra) # 8000411c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000599c:	08000613          	li	a2,128
    800059a0:	f6040593          	addi	a1,s0,-160
    800059a4:	4501                	li	a0,0
    800059a6:	ffffd097          	auipc	ra,0xffffd
    800059aa:	28a080e7          	jalr	650(ra) # 80002c30 <argstr>
    800059ae:	04054b63          	bltz	a0,80005a04 <sys_chdir+0x86>
    800059b2:	f6040513          	addi	a0,s0,-160
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	55a080e7          	jalr	1370(ra) # 80003f10 <namei>
    800059be:	84aa                	mv	s1,a0
    800059c0:	c131                	beqz	a0,80005a04 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800059c2:	ffffe097          	auipc	ra,0xffffe
    800059c6:	d9a080e7          	jalr	-614(ra) # 8000375c <ilock>
  if(ip->type != T_DIR){
    800059ca:	04449703          	lh	a4,68(s1)
    800059ce:	4785                	li	a5,1
    800059d0:	04f71063          	bne	a4,a5,80005a10 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059d4:	8526                	mv	a0,s1
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	e48080e7          	jalr	-440(ra) # 8000381e <iunlock>
  iput(p->cwd);
    800059de:	15093503          	ld	a0,336(s2)
    800059e2:	ffffe097          	auipc	ra,0xffffe
    800059e6:	f34080e7          	jalr	-204(ra) # 80003916 <iput>
  end_op();
    800059ea:	ffffe097          	auipc	ra,0xffffe
    800059ee:	7b2080e7          	jalr	1970(ra) # 8000419c <end_op>
  p->cwd = ip;
    800059f2:	14993823          	sd	s1,336(s2)
  return 0;
    800059f6:	4501                	li	a0,0
}
    800059f8:	60ea                	ld	ra,152(sp)
    800059fa:	644a                	ld	s0,144(sp)
    800059fc:	64aa                	ld	s1,136(sp)
    800059fe:	690a                	ld	s2,128(sp)
    80005a00:	610d                	addi	sp,sp,160
    80005a02:	8082                	ret
    end_op();
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	798080e7          	jalr	1944(ra) # 8000419c <end_op>
    return -1;
    80005a0c:	557d                	li	a0,-1
    80005a0e:	b7ed                	j	800059f8 <sys_chdir+0x7a>
    iunlockput(ip);
    80005a10:	8526                	mv	a0,s1
    80005a12:	ffffe097          	auipc	ra,0xffffe
    80005a16:	fac080e7          	jalr	-84(ra) # 800039be <iunlockput>
    end_op();
    80005a1a:	ffffe097          	auipc	ra,0xffffe
    80005a1e:	782080e7          	jalr	1922(ra) # 8000419c <end_op>
    return -1;
    80005a22:	557d                	li	a0,-1
    80005a24:	bfd1                	j	800059f8 <sys_chdir+0x7a>

0000000080005a26 <sys_exec>:

uint64
sys_exec(void)
{
    80005a26:	7145                	addi	sp,sp,-464
    80005a28:	e786                	sd	ra,456(sp)
    80005a2a:	e3a2                	sd	s0,448(sp)
    80005a2c:	ff26                	sd	s1,440(sp)
    80005a2e:	fb4a                	sd	s2,432(sp)
    80005a30:	f74e                	sd	s3,424(sp)
    80005a32:	f352                	sd	s4,416(sp)
    80005a34:	ef56                	sd	s5,408(sp)
    80005a36:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a38:	08000613          	li	a2,128
    80005a3c:	f4040593          	addi	a1,s0,-192
    80005a40:	4501                	li	a0,0
    80005a42:	ffffd097          	auipc	ra,0xffffd
    80005a46:	1ee080e7          	jalr	494(ra) # 80002c30 <argstr>
    return -1;
    80005a4a:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a4c:	0c054a63          	bltz	a0,80005b20 <sys_exec+0xfa>
    80005a50:	e3840593          	addi	a1,s0,-456
    80005a54:	4505                	li	a0,1
    80005a56:	ffffd097          	auipc	ra,0xffffd
    80005a5a:	1b8080e7          	jalr	440(ra) # 80002c0e <argaddr>
    80005a5e:	0c054163          	bltz	a0,80005b20 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005a62:	10000613          	li	a2,256
    80005a66:	4581                	li	a1,0
    80005a68:	e4040513          	addi	a0,s0,-448
    80005a6c:	ffffb097          	auipc	ra,0xffffb
    80005a70:	39e080e7          	jalr	926(ra) # 80000e0a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a74:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005a78:	89a6                	mv	s3,s1
    80005a7a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a7c:	02000a13          	li	s4,32
    80005a80:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a84:	00391793          	slli	a5,s2,0x3
    80005a88:	e3040593          	addi	a1,s0,-464
    80005a8c:	e3843503          	ld	a0,-456(s0)
    80005a90:	953e                	add	a0,a0,a5
    80005a92:	ffffd097          	auipc	ra,0xffffd
    80005a96:	0c0080e7          	jalr	192(ra) # 80002b52 <fetchaddr>
    80005a9a:	02054a63          	bltz	a0,80005ace <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005a9e:	e3043783          	ld	a5,-464(s0)
    80005aa2:	c3b9                	beqz	a5,80005ae8 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005aa4:	ffffb097          	auipc	ra,0xffffb
    80005aa8:	0aa080e7          	jalr	170(ra) # 80000b4e <kalloc>
    80005aac:	85aa                	mv	a1,a0
    80005aae:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ab2:	cd11                	beqz	a0,80005ace <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ab4:	6605                	lui	a2,0x1
    80005ab6:	e3043503          	ld	a0,-464(s0)
    80005aba:	ffffd097          	auipc	ra,0xffffd
    80005abe:	0ea080e7          	jalr	234(ra) # 80002ba4 <fetchstr>
    80005ac2:	00054663          	bltz	a0,80005ace <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005ac6:	0905                	addi	s2,s2,1
    80005ac8:	09a1                	addi	s3,s3,8
    80005aca:	fb491be3          	bne	s2,s4,80005a80 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ace:	10048913          	addi	s2,s1,256
    80005ad2:	6088                	ld	a0,0(s1)
    80005ad4:	c529                	beqz	a0,80005b1e <sys_exec+0xf8>
    kfree(argv[i]);
    80005ad6:	ffffb097          	auipc	ra,0xffffb
    80005ada:	f3c080e7          	jalr	-196(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ade:	04a1                	addi	s1,s1,8
    80005ae0:	ff2499e3          	bne	s1,s2,80005ad2 <sys_exec+0xac>
  return -1;
    80005ae4:	597d                	li	s2,-1
    80005ae6:	a82d                	j	80005b20 <sys_exec+0xfa>
      argv[i] = 0;
    80005ae8:	0a8e                	slli	s5,s5,0x3
    80005aea:	fc040793          	addi	a5,s0,-64
    80005aee:	9abe                	add	s5,s5,a5
    80005af0:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffb8e80>
  int ret = exec(path, argv);
    80005af4:	e4040593          	addi	a1,s0,-448
    80005af8:	f4040513          	addi	a0,s0,-192
    80005afc:	fffff097          	auipc	ra,0xfffff
    80005b00:	178080e7          	jalr	376(ra) # 80004c74 <exec>
    80005b04:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b06:	10048993          	addi	s3,s1,256
    80005b0a:	6088                	ld	a0,0(s1)
    80005b0c:	c911                	beqz	a0,80005b20 <sys_exec+0xfa>
    kfree(argv[i]);
    80005b0e:	ffffb097          	auipc	ra,0xffffb
    80005b12:	f04080e7          	jalr	-252(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b16:	04a1                	addi	s1,s1,8
    80005b18:	ff3499e3          	bne	s1,s3,80005b0a <sys_exec+0xe4>
    80005b1c:	a011                	j	80005b20 <sys_exec+0xfa>
  return -1;
    80005b1e:	597d                	li	s2,-1
}
    80005b20:	854a                	mv	a0,s2
    80005b22:	60be                	ld	ra,456(sp)
    80005b24:	641e                	ld	s0,448(sp)
    80005b26:	74fa                	ld	s1,440(sp)
    80005b28:	795a                	ld	s2,432(sp)
    80005b2a:	79ba                	ld	s3,424(sp)
    80005b2c:	7a1a                	ld	s4,416(sp)
    80005b2e:	6afa                	ld	s5,408(sp)
    80005b30:	6179                	addi	sp,sp,464
    80005b32:	8082                	ret

0000000080005b34 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b34:	7139                	addi	sp,sp,-64
    80005b36:	fc06                	sd	ra,56(sp)
    80005b38:	f822                	sd	s0,48(sp)
    80005b3a:	f426                	sd	s1,40(sp)
    80005b3c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b3e:	ffffc097          	auipc	ra,0xffffc
    80005b42:	fc8080e7          	jalr	-56(ra) # 80001b06 <myproc>
    80005b46:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005b48:	fd840593          	addi	a1,s0,-40
    80005b4c:	4501                	li	a0,0
    80005b4e:	ffffd097          	auipc	ra,0xffffd
    80005b52:	0c0080e7          	jalr	192(ra) # 80002c0e <argaddr>
    return -1;
    80005b56:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005b58:	0e054063          	bltz	a0,80005c38 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005b5c:	fc840593          	addi	a1,s0,-56
    80005b60:	fd040513          	addi	a0,s0,-48
    80005b64:	fffff097          	auipc	ra,0xfffff
    80005b68:	de0080e7          	jalr	-544(ra) # 80004944 <pipealloc>
    return -1;
    80005b6c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b6e:	0c054563          	bltz	a0,80005c38 <sys_pipe+0x104>
  fd0 = -1;
    80005b72:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b76:	fd043503          	ld	a0,-48(s0)
    80005b7a:	fffff097          	auipc	ra,0xfffff
    80005b7e:	50a080e7          	jalr	1290(ra) # 80005084 <fdalloc>
    80005b82:	fca42223          	sw	a0,-60(s0)
    80005b86:	08054c63          	bltz	a0,80005c1e <sys_pipe+0xea>
    80005b8a:	fc843503          	ld	a0,-56(s0)
    80005b8e:	fffff097          	auipc	ra,0xfffff
    80005b92:	4f6080e7          	jalr	1270(ra) # 80005084 <fdalloc>
    80005b96:	fca42023          	sw	a0,-64(s0)
    80005b9a:	06054863          	bltz	a0,80005c0a <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b9e:	4691                	li	a3,4
    80005ba0:	fc440613          	addi	a2,s0,-60
    80005ba4:	fd843583          	ld	a1,-40(s0)
    80005ba8:	68a8                	ld	a0,80(s1)
    80005baa:	ffffc097          	auipc	ra,0xffffc
    80005bae:	c1e080e7          	jalr	-994(ra) # 800017c8 <copyout>
    80005bb2:	02054063          	bltz	a0,80005bd2 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005bb6:	4691                	li	a3,4
    80005bb8:	fc040613          	addi	a2,s0,-64
    80005bbc:	fd843583          	ld	a1,-40(s0)
    80005bc0:	0591                	addi	a1,a1,4
    80005bc2:	68a8                	ld	a0,80(s1)
    80005bc4:	ffffc097          	auipc	ra,0xffffc
    80005bc8:	c04080e7          	jalr	-1020(ra) # 800017c8 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005bcc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bce:	06055563          	bgez	a0,80005c38 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005bd2:	fc442783          	lw	a5,-60(s0)
    80005bd6:	07e9                	addi	a5,a5,26
    80005bd8:	078e                	slli	a5,a5,0x3
    80005bda:	97a6                	add	a5,a5,s1
    80005bdc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005be0:	fc042503          	lw	a0,-64(s0)
    80005be4:	0569                	addi	a0,a0,26
    80005be6:	050e                	slli	a0,a0,0x3
    80005be8:	9526                	add	a0,a0,s1
    80005bea:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005bee:	fd043503          	ld	a0,-48(s0)
    80005bf2:	fffff097          	auipc	ra,0xfffff
    80005bf6:	9fc080e7          	jalr	-1540(ra) # 800045ee <fileclose>
    fileclose(wf);
    80005bfa:	fc843503          	ld	a0,-56(s0)
    80005bfe:	fffff097          	auipc	ra,0xfffff
    80005c02:	9f0080e7          	jalr	-1552(ra) # 800045ee <fileclose>
    return -1;
    80005c06:	57fd                	li	a5,-1
    80005c08:	a805                	j	80005c38 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005c0a:	fc442783          	lw	a5,-60(s0)
    80005c0e:	0007c863          	bltz	a5,80005c1e <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005c12:	01a78513          	addi	a0,a5,26
    80005c16:	050e                	slli	a0,a0,0x3
    80005c18:	9526                	add	a0,a0,s1
    80005c1a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c1e:	fd043503          	ld	a0,-48(s0)
    80005c22:	fffff097          	auipc	ra,0xfffff
    80005c26:	9cc080e7          	jalr	-1588(ra) # 800045ee <fileclose>
    fileclose(wf);
    80005c2a:	fc843503          	ld	a0,-56(s0)
    80005c2e:	fffff097          	auipc	ra,0xfffff
    80005c32:	9c0080e7          	jalr	-1600(ra) # 800045ee <fileclose>
    return -1;
    80005c36:	57fd                	li	a5,-1
}
    80005c38:	853e                	mv	a0,a5
    80005c3a:	70e2                	ld	ra,56(sp)
    80005c3c:	7442                	ld	s0,48(sp)
    80005c3e:	74a2                	ld	s1,40(sp)
    80005c40:	6121                	addi	sp,sp,64
    80005c42:	8082                	ret
	...

0000000080005c50 <kernelvec>:
    80005c50:	7111                	addi	sp,sp,-256
    80005c52:	e006                	sd	ra,0(sp)
    80005c54:	e40a                	sd	sp,8(sp)
    80005c56:	e80e                	sd	gp,16(sp)
    80005c58:	ec12                	sd	tp,24(sp)
    80005c5a:	f016                	sd	t0,32(sp)
    80005c5c:	f41a                	sd	t1,40(sp)
    80005c5e:	f81e                	sd	t2,48(sp)
    80005c60:	fc22                	sd	s0,56(sp)
    80005c62:	e0a6                	sd	s1,64(sp)
    80005c64:	e4aa                	sd	a0,72(sp)
    80005c66:	e8ae                	sd	a1,80(sp)
    80005c68:	ecb2                	sd	a2,88(sp)
    80005c6a:	f0b6                	sd	a3,96(sp)
    80005c6c:	f4ba                	sd	a4,104(sp)
    80005c6e:	f8be                	sd	a5,112(sp)
    80005c70:	fcc2                	sd	a6,120(sp)
    80005c72:	e146                	sd	a7,128(sp)
    80005c74:	e54a                	sd	s2,136(sp)
    80005c76:	e94e                	sd	s3,144(sp)
    80005c78:	ed52                	sd	s4,152(sp)
    80005c7a:	f156                	sd	s5,160(sp)
    80005c7c:	f55a                	sd	s6,168(sp)
    80005c7e:	f95e                	sd	s7,176(sp)
    80005c80:	fd62                	sd	s8,184(sp)
    80005c82:	e1e6                	sd	s9,192(sp)
    80005c84:	e5ea                	sd	s10,200(sp)
    80005c86:	e9ee                	sd	s11,208(sp)
    80005c88:	edf2                	sd	t3,216(sp)
    80005c8a:	f1f6                	sd	t4,224(sp)
    80005c8c:	f5fa                	sd	t5,232(sp)
    80005c8e:	f9fe                	sd	t6,240(sp)
    80005c90:	d8ffc0ef          	jal	ra,80002a1e <kerneltrap>
    80005c94:	6082                	ld	ra,0(sp)
    80005c96:	6122                	ld	sp,8(sp)
    80005c98:	61c2                	ld	gp,16(sp)
    80005c9a:	7282                	ld	t0,32(sp)
    80005c9c:	7322                	ld	t1,40(sp)
    80005c9e:	73c2                	ld	t2,48(sp)
    80005ca0:	7462                	ld	s0,56(sp)
    80005ca2:	6486                	ld	s1,64(sp)
    80005ca4:	6526                	ld	a0,72(sp)
    80005ca6:	65c6                	ld	a1,80(sp)
    80005ca8:	6666                	ld	a2,88(sp)
    80005caa:	7686                	ld	a3,96(sp)
    80005cac:	7726                	ld	a4,104(sp)
    80005cae:	77c6                	ld	a5,112(sp)
    80005cb0:	7866                	ld	a6,120(sp)
    80005cb2:	688a                	ld	a7,128(sp)
    80005cb4:	692a                	ld	s2,136(sp)
    80005cb6:	69ca                	ld	s3,144(sp)
    80005cb8:	6a6a                	ld	s4,152(sp)
    80005cba:	7a8a                	ld	s5,160(sp)
    80005cbc:	7b2a                	ld	s6,168(sp)
    80005cbe:	7bca                	ld	s7,176(sp)
    80005cc0:	7c6a                	ld	s8,184(sp)
    80005cc2:	6c8e                	ld	s9,192(sp)
    80005cc4:	6d2e                	ld	s10,200(sp)
    80005cc6:	6dce                	ld	s11,208(sp)
    80005cc8:	6e6e                	ld	t3,216(sp)
    80005cca:	7e8e                	ld	t4,224(sp)
    80005ccc:	7f2e                	ld	t5,232(sp)
    80005cce:	7fce                	ld	t6,240(sp)
    80005cd0:	6111                	addi	sp,sp,256
    80005cd2:	10200073          	sret
    80005cd6:	00000013          	nop
    80005cda:	00000013          	nop
    80005cde:	0001                	nop

0000000080005ce0 <timervec>:
    80005ce0:	34051573          	csrrw	a0,mscratch,a0
    80005ce4:	e10c                	sd	a1,0(a0)
    80005ce6:	e510                	sd	a2,8(a0)
    80005ce8:	e914                	sd	a3,16(a0)
    80005cea:	710c                	ld	a1,32(a0)
    80005cec:	7510                	ld	a2,40(a0)
    80005cee:	6194                	ld	a3,0(a1)
    80005cf0:	96b2                	add	a3,a3,a2
    80005cf2:	e194                	sd	a3,0(a1)
    80005cf4:	4589                	li	a1,2
    80005cf6:	14459073          	csrw	sip,a1
    80005cfa:	6914                	ld	a3,16(a0)
    80005cfc:	6510                	ld	a2,8(a0)
    80005cfe:	610c                	ld	a1,0(a0)
    80005d00:	34051573          	csrrw	a0,mscratch,a0
    80005d04:	30200073          	mret
	...

0000000080005d0a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d0a:	1141                	addi	sp,sp,-16
    80005d0c:	e422                	sd	s0,8(sp)
    80005d0e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d10:	0c0007b7          	lui	a5,0xc000
    80005d14:	4705                	li	a4,1
    80005d16:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d18:	c3d8                	sw	a4,4(a5)
}
    80005d1a:	6422                	ld	s0,8(sp)
    80005d1c:	0141                	addi	sp,sp,16
    80005d1e:	8082                	ret

0000000080005d20 <plicinithart>:

void
plicinithart(void)
{
    80005d20:	1141                	addi	sp,sp,-16
    80005d22:	e406                	sd	ra,8(sp)
    80005d24:	e022                	sd	s0,0(sp)
    80005d26:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d28:	ffffc097          	auipc	ra,0xffffc
    80005d2c:	db2080e7          	jalr	-590(ra) # 80001ada <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d30:	0085171b          	slliw	a4,a0,0x8
    80005d34:	0c0027b7          	lui	a5,0xc002
    80005d38:	97ba                	add	a5,a5,a4
    80005d3a:	40200713          	li	a4,1026
    80005d3e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d42:	00d5151b          	slliw	a0,a0,0xd
    80005d46:	0c2017b7          	lui	a5,0xc201
    80005d4a:	953e                	add	a0,a0,a5
    80005d4c:	00052023          	sw	zero,0(a0)
}
    80005d50:	60a2                	ld	ra,8(sp)
    80005d52:	6402                	ld	s0,0(sp)
    80005d54:	0141                	addi	sp,sp,16
    80005d56:	8082                	ret

0000000080005d58 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d58:	1141                	addi	sp,sp,-16
    80005d5a:	e406                	sd	ra,8(sp)
    80005d5c:	e022                	sd	s0,0(sp)
    80005d5e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d60:	ffffc097          	auipc	ra,0xffffc
    80005d64:	d7a080e7          	jalr	-646(ra) # 80001ada <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d68:	00d5179b          	slliw	a5,a0,0xd
    80005d6c:	0c201537          	lui	a0,0xc201
    80005d70:	953e                	add	a0,a0,a5
  return irq;
}
    80005d72:	4148                	lw	a0,4(a0)
    80005d74:	60a2                	ld	ra,8(sp)
    80005d76:	6402                	ld	s0,0(sp)
    80005d78:	0141                	addi	sp,sp,16
    80005d7a:	8082                	ret

0000000080005d7c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d7c:	1101                	addi	sp,sp,-32
    80005d7e:	ec06                	sd	ra,24(sp)
    80005d80:	e822                	sd	s0,16(sp)
    80005d82:	e426                	sd	s1,8(sp)
    80005d84:	1000                	addi	s0,sp,32
    80005d86:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d88:	ffffc097          	auipc	ra,0xffffc
    80005d8c:	d52080e7          	jalr	-686(ra) # 80001ada <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d90:	00d5151b          	slliw	a0,a0,0xd
    80005d94:	0c2017b7          	lui	a5,0xc201
    80005d98:	97aa                	add	a5,a5,a0
    80005d9a:	c3c4                	sw	s1,4(a5)
}
    80005d9c:	60e2                	ld	ra,24(sp)
    80005d9e:	6442                	ld	s0,16(sp)
    80005da0:	64a2                	ld	s1,8(sp)
    80005da2:	6105                	addi	sp,sp,32
    80005da4:	8082                	ret

0000000080005da6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005da6:	1141                	addi	sp,sp,-16
    80005da8:	e406                	sd	ra,8(sp)
    80005daa:	e022                	sd	s0,0(sp)
    80005dac:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005dae:	479d                	li	a5,7
    80005db0:	04a7cc63          	blt	a5,a0,80005e08 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005db4:	0003d797          	auipc	a5,0x3d
    80005db8:	24c78793          	addi	a5,a5,588 # 80043000 <disk>
    80005dbc:	00a78733          	add	a4,a5,a0
    80005dc0:	6789                	lui	a5,0x2
    80005dc2:	97ba                	add	a5,a5,a4
    80005dc4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005dc8:	eba1                	bnez	a5,80005e18 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005dca:	00451713          	slli	a4,a0,0x4
    80005dce:	0003f797          	auipc	a5,0x3f
    80005dd2:	2327b783          	ld	a5,562(a5) # 80045000 <disk+0x2000>
    80005dd6:	97ba                	add	a5,a5,a4
    80005dd8:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005ddc:	0003d797          	auipc	a5,0x3d
    80005de0:	22478793          	addi	a5,a5,548 # 80043000 <disk>
    80005de4:	97aa                	add	a5,a5,a0
    80005de6:	6509                	lui	a0,0x2
    80005de8:	953e                	add	a0,a0,a5
    80005dea:	4785                	li	a5,1
    80005dec:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005df0:	0003f517          	auipc	a0,0x3f
    80005df4:	22850513          	addi	a0,a0,552 # 80045018 <disk+0x2018>
    80005df8:	ffffc097          	auipc	ra,0xffffc
    80005dfc:	6a2080e7          	jalr	1698(ra) # 8000249a <wakeup>
}
    80005e00:	60a2                	ld	ra,8(sp)
    80005e02:	6402                	ld	s0,0(sp)
    80005e04:	0141                	addi	sp,sp,16
    80005e06:	8082                	ret
    panic("virtio_disk_intr 1");
    80005e08:	00003517          	auipc	a0,0x3
    80005e0c:	95050513          	addi	a0,a0,-1712 # 80008758 <syscalls+0x330>
    80005e10:	ffffa097          	auipc	ra,0xffffa
    80005e14:	732080e7          	jalr	1842(ra) # 80000542 <panic>
    panic("virtio_disk_intr 2");
    80005e18:	00003517          	auipc	a0,0x3
    80005e1c:	95850513          	addi	a0,a0,-1704 # 80008770 <syscalls+0x348>
    80005e20:	ffffa097          	auipc	ra,0xffffa
    80005e24:	722080e7          	jalr	1826(ra) # 80000542 <panic>

0000000080005e28 <virtio_disk_init>:
{
    80005e28:	1101                	addi	sp,sp,-32
    80005e2a:	ec06                	sd	ra,24(sp)
    80005e2c:	e822                	sd	s0,16(sp)
    80005e2e:	e426                	sd	s1,8(sp)
    80005e30:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e32:	00003597          	auipc	a1,0x3
    80005e36:	95658593          	addi	a1,a1,-1706 # 80008788 <syscalls+0x360>
    80005e3a:	0003f517          	auipc	a0,0x3f
    80005e3e:	26e50513          	addi	a0,a0,622 # 800450a8 <disk+0x20a8>
    80005e42:	ffffb097          	auipc	ra,0xffffb
    80005e46:	e3c080e7          	jalr	-452(ra) # 80000c7e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e4a:	100017b7          	lui	a5,0x10001
    80005e4e:	4398                	lw	a4,0(a5)
    80005e50:	2701                	sext.w	a4,a4
    80005e52:	747277b7          	lui	a5,0x74727
    80005e56:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e5a:	0ef71163          	bne	a4,a5,80005f3c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e5e:	100017b7          	lui	a5,0x10001
    80005e62:	43dc                	lw	a5,4(a5)
    80005e64:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e66:	4705                	li	a4,1
    80005e68:	0ce79a63          	bne	a5,a4,80005f3c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e6c:	100017b7          	lui	a5,0x10001
    80005e70:	479c                	lw	a5,8(a5)
    80005e72:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e74:	4709                	li	a4,2
    80005e76:	0ce79363          	bne	a5,a4,80005f3c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e7a:	100017b7          	lui	a5,0x10001
    80005e7e:	47d8                	lw	a4,12(a5)
    80005e80:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e82:	554d47b7          	lui	a5,0x554d4
    80005e86:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e8a:	0af71963          	bne	a4,a5,80005f3c <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e8e:	100017b7          	lui	a5,0x10001
    80005e92:	4705                	li	a4,1
    80005e94:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e96:	470d                	li	a4,3
    80005e98:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e9a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005e9c:	c7ffe737          	lui	a4,0xc7ffe
    80005ea0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fb875f>
    80005ea4:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005ea6:	2701                	sext.w	a4,a4
    80005ea8:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eaa:	472d                	li	a4,11
    80005eac:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eae:	473d                	li	a4,15
    80005eb0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005eb2:	6705                	lui	a4,0x1
    80005eb4:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005eb6:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005eba:	5bdc                	lw	a5,52(a5)
    80005ebc:	2781                	sext.w	a5,a5
  if(max == 0)
    80005ebe:	c7d9                	beqz	a5,80005f4c <virtio_disk_init+0x124>
  if(max < NUM)
    80005ec0:	471d                	li	a4,7
    80005ec2:	08f77d63          	bgeu	a4,a5,80005f5c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ec6:	100014b7          	lui	s1,0x10001
    80005eca:	47a1                	li	a5,8
    80005ecc:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005ece:	6609                	lui	a2,0x2
    80005ed0:	4581                	li	a1,0
    80005ed2:	0003d517          	auipc	a0,0x3d
    80005ed6:	12e50513          	addi	a0,a0,302 # 80043000 <disk>
    80005eda:	ffffb097          	auipc	ra,0xffffb
    80005ede:	f30080e7          	jalr	-208(ra) # 80000e0a <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005ee2:	0003d717          	auipc	a4,0x3d
    80005ee6:	11e70713          	addi	a4,a4,286 # 80043000 <disk>
    80005eea:	00c75793          	srli	a5,a4,0xc
    80005eee:	2781                	sext.w	a5,a5
    80005ef0:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005ef2:	0003f797          	auipc	a5,0x3f
    80005ef6:	10e78793          	addi	a5,a5,270 # 80045000 <disk+0x2000>
    80005efa:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005efc:	0003d717          	auipc	a4,0x3d
    80005f00:	18470713          	addi	a4,a4,388 # 80043080 <disk+0x80>
    80005f04:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005f06:	0003e717          	auipc	a4,0x3e
    80005f0a:	0fa70713          	addi	a4,a4,250 # 80044000 <disk+0x1000>
    80005f0e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005f10:	4705                	li	a4,1
    80005f12:	00e78c23          	sb	a4,24(a5)
    80005f16:	00e78ca3          	sb	a4,25(a5)
    80005f1a:	00e78d23          	sb	a4,26(a5)
    80005f1e:	00e78da3          	sb	a4,27(a5)
    80005f22:	00e78e23          	sb	a4,28(a5)
    80005f26:	00e78ea3          	sb	a4,29(a5)
    80005f2a:	00e78f23          	sb	a4,30(a5)
    80005f2e:	00e78fa3          	sb	a4,31(a5)
}
    80005f32:	60e2                	ld	ra,24(sp)
    80005f34:	6442                	ld	s0,16(sp)
    80005f36:	64a2                	ld	s1,8(sp)
    80005f38:	6105                	addi	sp,sp,32
    80005f3a:	8082                	ret
    panic("could not find virtio disk");
    80005f3c:	00003517          	auipc	a0,0x3
    80005f40:	85c50513          	addi	a0,a0,-1956 # 80008798 <syscalls+0x370>
    80005f44:	ffffa097          	auipc	ra,0xffffa
    80005f48:	5fe080e7          	jalr	1534(ra) # 80000542 <panic>
    panic("virtio disk has no queue 0");
    80005f4c:	00003517          	auipc	a0,0x3
    80005f50:	86c50513          	addi	a0,a0,-1940 # 800087b8 <syscalls+0x390>
    80005f54:	ffffa097          	auipc	ra,0xffffa
    80005f58:	5ee080e7          	jalr	1518(ra) # 80000542 <panic>
    panic("virtio disk max queue too short");
    80005f5c:	00003517          	auipc	a0,0x3
    80005f60:	87c50513          	addi	a0,a0,-1924 # 800087d8 <syscalls+0x3b0>
    80005f64:	ffffa097          	auipc	ra,0xffffa
    80005f68:	5de080e7          	jalr	1502(ra) # 80000542 <panic>

0000000080005f6c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f6c:	7175                	addi	sp,sp,-144
    80005f6e:	e506                	sd	ra,136(sp)
    80005f70:	e122                	sd	s0,128(sp)
    80005f72:	fca6                	sd	s1,120(sp)
    80005f74:	f8ca                	sd	s2,112(sp)
    80005f76:	f4ce                	sd	s3,104(sp)
    80005f78:	f0d2                	sd	s4,96(sp)
    80005f7a:	ecd6                	sd	s5,88(sp)
    80005f7c:	e8da                	sd	s6,80(sp)
    80005f7e:	e4de                	sd	s7,72(sp)
    80005f80:	e0e2                	sd	s8,64(sp)
    80005f82:	fc66                	sd	s9,56(sp)
    80005f84:	f86a                	sd	s10,48(sp)
    80005f86:	f46e                	sd	s11,40(sp)
    80005f88:	0900                	addi	s0,sp,144
    80005f8a:	8aaa                	mv	s5,a0
    80005f8c:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f8e:	00c52c83          	lw	s9,12(a0)
    80005f92:	001c9c9b          	slliw	s9,s9,0x1
    80005f96:	1c82                	slli	s9,s9,0x20
    80005f98:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005f9c:	0003f517          	auipc	a0,0x3f
    80005fa0:	10c50513          	addi	a0,a0,268 # 800450a8 <disk+0x20a8>
    80005fa4:	ffffb097          	auipc	ra,0xffffb
    80005fa8:	d6a080e7          	jalr	-662(ra) # 80000d0e <acquire>
  for(int i = 0; i < 3; i++){
    80005fac:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005fae:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005fb0:	0003dc17          	auipc	s8,0x3d
    80005fb4:	050c0c13          	addi	s8,s8,80 # 80043000 <disk>
    80005fb8:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80005fba:	4b0d                	li	s6,3
    80005fbc:	a0ad                	j	80006026 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80005fbe:	00fc0733          	add	a4,s8,a5
    80005fc2:	975e                	add	a4,a4,s7
    80005fc4:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005fc8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005fca:	0207c563          	bltz	a5,80005ff4 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005fce:	2905                	addiw	s2,s2,1
    80005fd0:	0611                	addi	a2,a2,4
    80005fd2:	19690d63          	beq	s2,s6,8000616c <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80005fd6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005fd8:	0003f717          	auipc	a4,0x3f
    80005fdc:	04070713          	addi	a4,a4,64 # 80045018 <disk+0x2018>
    80005fe0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005fe2:	00074683          	lbu	a3,0(a4)
    80005fe6:	fee1                	bnez	a3,80005fbe <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005fe8:	2785                	addiw	a5,a5,1
    80005fea:	0705                	addi	a4,a4,1
    80005fec:	fe979be3          	bne	a5,s1,80005fe2 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005ff0:	57fd                	li	a5,-1
    80005ff2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005ff4:	01205d63          	blez	s2,8000600e <virtio_disk_rw+0xa2>
    80005ff8:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005ffa:	000a2503          	lw	a0,0(s4)
    80005ffe:	00000097          	auipc	ra,0x0
    80006002:	da8080e7          	jalr	-600(ra) # 80005da6 <free_desc>
      for(int j = 0; j < i; j++)
    80006006:	2d85                	addiw	s11,s11,1
    80006008:	0a11                	addi	s4,s4,4
    8000600a:	ffb918e3          	bne	s2,s11,80005ffa <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000600e:	0003f597          	auipc	a1,0x3f
    80006012:	09a58593          	addi	a1,a1,154 # 800450a8 <disk+0x20a8>
    80006016:	0003f517          	auipc	a0,0x3f
    8000601a:	00250513          	addi	a0,a0,2 # 80045018 <disk+0x2018>
    8000601e:	ffffc097          	auipc	ra,0xffffc
    80006022:	2fc080e7          	jalr	764(ra) # 8000231a <sleep>
  for(int i = 0; i < 3; i++){
    80006026:	f8040a13          	addi	s4,s0,-128
{
    8000602a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000602c:	894e                	mv	s2,s3
    8000602e:	b765                	j	80005fd6 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006030:	0003f717          	auipc	a4,0x3f
    80006034:	fd073703          	ld	a4,-48(a4) # 80045000 <disk+0x2000>
    80006038:	973e                	add	a4,a4,a5
    8000603a:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000603e:	0003d517          	auipc	a0,0x3d
    80006042:	fc250513          	addi	a0,a0,-62 # 80043000 <disk>
    80006046:	0003f717          	auipc	a4,0x3f
    8000604a:	fba70713          	addi	a4,a4,-70 # 80045000 <disk+0x2000>
    8000604e:	6314                	ld	a3,0(a4)
    80006050:	96be                	add	a3,a3,a5
    80006052:	00c6d603          	lhu	a2,12(a3)
    80006056:	00166613          	ori	a2,a2,1
    8000605a:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000605e:	f8842683          	lw	a3,-120(s0)
    80006062:	6310                	ld	a2,0(a4)
    80006064:	97b2                	add	a5,a5,a2
    80006066:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    8000606a:	20048613          	addi	a2,s1,512 # 10001200 <_entry-0x6fffee00>
    8000606e:	0612                	slli	a2,a2,0x4
    80006070:	962a                	add	a2,a2,a0
    80006072:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006076:	00469793          	slli	a5,a3,0x4
    8000607a:	630c                	ld	a1,0(a4)
    8000607c:	95be                	add	a1,a1,a5
    8000607e:	6689                	lui	a3,0x2
    80006080:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006084:	96ca                	add	a3,a3,s2
    80006086:	96aa                	add	a3,a3,a0
    80006088:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    8000608a:	6314                	ld	a3,0(a4)
    8000608c:	96be                	add	a3,a3,a5
    8000608e:	4585                	li	a1,1
    80006090:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006092:	6314                	ld	a3,0(a4)
    80006094:	96be                	add	a3,a3,a5
    80006096:	4509                	li	a0,2
    80006098:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    8000609c:	6314                	ld	a3,0(a4)
    8000609e:	97b6                	add	a5,a5,a3
    800060a0:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800060a4:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800060a8:	03563423          	sd	s5,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    800060ac:	6714                	ld	a3,8(a4)
    800060ae:	0026d783          	lhu	a5,2(a3)
    800060b2:	8b9d                	andi	a5,a5,7
    800060b4:	0789                	addi	a5,a5,2
    800060b6:	0786                	slli	a5,a5,0x1
    800060b8:	97b6                	add	a5,a5,a3
    800060ba:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    800060be:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800060c2:	6718                	ld	a4,8(a4)
    800060c4:	00275783          	lhu	a5,2(a4)
    800060c8:	2785                	addiw	a5,a5,1
    800060ca:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800060ce:	100017b7          	lui	a5,0x10001
    800060d2:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800060d6:	004aa783          	lw	a5,4(s5)
    800060da:	02b79163          	bne	a5,a1,800060fc <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800060de:	0003f917          	auipc	s2,0x3f
    800060e2:	fca90913          	addi	s2,s2,-54 # 800450a8 <disk+0x20a8>
  while(b->disk == 1) {
    800060e6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800060e8:	85ca                	mv	a1,s2
    800060ea:	8556                	mv	a0,s5
    800060ec:	ffffc097          	auipc	ra,0xffffc
    800060f0:	22e080e7          	jalr	558(ra) # 8000231a <sleep>
  while(b->disk == 1) {
    800060f4:	004aa783          	lw	a5,4(s5)
    800060f8:	fe9788e3          	beq	a5,s1,800060e8 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800060fc:	f8042483          	lw	s1,-128(s0)
    80006100:	20048793          	addi	a5,s1,512
    80006104:	00479713          	slli	a4,a5,0x4
    80006108:	0003d797          	auipc	a5,0x3d
    8000610c:	ef878793          	addi	a5,a5,-264 # 80043000 <disk>
    80006110:	97ba                	add	a5,a5,a4
    80006112:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006116:	0003f917          	auipc	s2,0x3f
    8000611a:	eea90913          	addi	s2,s2,-278 # 80045000 <disk+0x2000>
    8000611e:	a019                	j	80006124 <virtio_disk_rw+0x1b8>
      i = disk.desc[i].next;
    80006120:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    80006124:	8526                	mv	a0,s1
    80006126:	00000097          	auipc	ra,0x0
    8000612a:	c80080e7          	jalr	-896(ra) # 80005da6 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    8000612e:	0492                	slli	s1,s1,0x4
    80006130:	00093783          	ld	a5,0(s2)
    80006134:	94be                	add	s1,s1,a5
    80006136:	00c4d783          	lhu	a5,12(s1)
    8000613a:	8b85                	andi	a5,a5,1
    8000613c:	f3f5                	bnez	a5,80006120 <virtio_disk_rw+0x1b4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000613e:	0003f517          	auipc	a0,0x3f
    80006142:	f6a50513          	addi	a0,a0,-150 # 800450a8 <disk+0x20a8>
    80006146:	ffffb097          	auipc	ra,0xffffb
    8000614a:	c7c080e7          	jalr	-900(ra) # 80000dc2 <release>
}
    8000614e:	60aa                	ld	ra,136(sp)
    80006150:	640a                	ld	s0,128(sp)
    80006152:	74e6                	ld	s1,120(sp)
    80006154:	7946                	ld	s2,112(sp)
    80006156:	79a6                	ld	s3,104(sp)
    80006158:	7a06                	ld	s4,96(sp)
    8000615a:	6ae6                	ld	s5,88(sp)
    8000615c:	6b46                	ld	s6,80(sp)
    8000615e:	6ba6                	ld	s7,72(sp)
    80006160:	6c06                	ld	s8,64(sp)
    80006162:	7ce2                	ld	s9,56(sp)
    80006164:	7d42                	ld	s10,48(sp)
    80006166:	7da2                	ld	s11,40(sp)
    80006168:	6149                	addi	sp,sp,144
    8000616a:	8082                	ret
  if(write)
    8000616c:	01a037b3          	snez	a5,s10
    80006170:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006174:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006178:	f7943c23          	sd	s9,-136(s0)
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    8000617c:	f8042483          	lw	s1,-128(s0)
    80006180:	00449913          	slli	s2,s1,0x4
    80006184:	0003f997          	auipc	s3,0x3f
    80006188:	e7c98993          	addi	s3,s3,-388 # 80045000 <disk+0x2000>
    8000618c:	0009ba03          	ld	s4,0(s3)
    80006190:	9a4a                	add	s4,s4,s2
    80006192:	f7040513          	addi	a0,s0,-144
    80006196:	ffffb097          	auipc	ra,0xffffb
    8000619a:	044080e7          	jalr	68(ra) # 800011da <kvmpa>
    8000619e:	00aa3023          	sd	a0,0(s4)
  disk.desc[idx[0]].len = sizeof(buf0);
    800061a2:	0009b783          	ld	a5,0(s3)
    800061a6:	97ca                	add	a5,a5,s2
    800061a8:	4741                	li	a4,16
    800061aa:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800061ac:	0009b783          	ld	a5,0(s3)
    800061b0:	97ca                	add	a5,a5,s2
    800061b2:	4705                	li	a4,1
    800061b4:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800061b8:	f8442783          	lw	a5,-124(s0)
    800061bc:	0009b703          	ld	a4,0(s3)
    800061c0:	974a                	add	a4,a4,s2
    800061c2:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    800061c6:	0792                	slli	a5,a5,0x4
    800061c8:	0009b703          	ld	a4,0(s3)
    800061cc:	973e                	add	a4,a4,a5
    800061ce:	058a8693          	addi	a3,s5,88
    800061d2:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    800061d4:	0009b703          	ld	a4,0(s3)
    800061d8:	973e                	add	a4,a4,a5
    800061da:	40000693          	li	a3,1024
    800061de:	c714                	sw	a3,8(a4)
  if(write)
    800061e0:	e40d18e3          	bnez	s10,80006030 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800061e4:	0003f717          	auipc	a4,0x3f
    800061e8:	e1c73703          	ld	a4,-484(a4) # 80045000 <disk+0x2000>
    800061ec:	973e                	add	a4,a4,a5
    800061ee:	4689                	li	a3,2
    800061f0:	00d71623          	sh	a3,12(a4)
    800061f4:	b5a9                	j	8000603e <virtio_disk_rw+0xd2>

00000000800061f6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800061f6:	1101                	addi	sp,sp,-32
    800061f8:	ec06                	sd	ra,24(sp)
    800061fa:	e822                	sd	s0,16(sp)
    800061fc:	e426                	sd	s1,8(sp)
    800061fe:	e04a                	sd	s2,0(sp)
    80006200:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006202:	0003f517          	auipc	a0,0x3f
    80006206:	ea650513          	addi	a0,a0,-346 # 800450a8 <disk+0x20a8>
    8000620a:	ffffb097          	auipc	ra,0xffffb
    8000620e:	b04080e7          	jalr	-1276(ra) # 80000d0e <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006212:	0003f717          	auipc	a4,0x3f
    80006216:	dee70713          	addi	a4,a4,-530 # 80045000 <disk+0x2000>
    8000621a:	02075783          	lhu	a5,32(a4)
    8000621e:	6b18                	ld	a4,16(a4)
    80006220:	00275683          	lhu	a3,2(a4)
    80006224:	8ebd                	xor	a3,a3,a5
    80006226:	8a9d                	andi	a3,a3,7
    80006228:	cab9                	beqz	a3,8000627e <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000622a:	0003d917          	auipc	s2,0x3d
    8000622e:	dd690913          	addi	s2,s2,-554 # 80043000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006232:	0003f497          	auipc	s1,0x3f
    80006236:	dce48493          	addi	s1,s1,-562 # 80045000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    8000623a:	078e                	slli	a5,a5,0x3
    8000623c:	97ba                	add	a5,a5,a4
    8000623e:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006240:	20078713          	addi	a4,a5,512
    80006244:	0712                	slli	a4,a4,0x4
    80006246:	974a                	add	a4,a4,s2
    80006248:	03074703          	lbu	a4,48(a4)
    8000624c:	ef21                	bnez	a4,800062a4 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000624e:	20078793          	addi	a5,a5,512
    80006252:	0792                	slli	a5,a5,0x4
    80006254:	97ca                	add	a5,a5,s2
    80006256:	7798                	ld	a4,40(a5)
    80006258:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    8000625c:	7788                	ld	a0,40(a5)
    8000625e:	ffffc097          	auipc	ra,0xffffc
    80006262:	23c080e7          	jalr	572(ra) # 8000249a <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006266:	0204d783          	lhu	a5,32(s1)
    8000626a:	2785                	addiw	a5,a5,1
    8000626c:	8b9d                	andi	a5,a5,7
    8000626e:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006272:	6898                	ld	a4,16(s1)
    80006274:	00275683          	lhu	a3,2(a4)
    80006278:	8a9d                	andi	a3,a3,7
    8000627a:	fcf690e3          	bne	a3,a5,8000623a <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000627e:	10001737          	lui	a4,0x10001
    80006282:	533c                	lw	a5,96(a4)
    80006284:	8b8d                	andi	a5,a5,3
    80006286:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006288:	0003f517          	auipc	a0,0x3f
    8000628c:	e2050513          	addi	a0,a0,-480 # 800450a8 <disk+0x20a8>
    80006290:	ffffb097          	auipc	ra,0xffffb
    80006294:	b32080e7          	jalr	-1230(ra) # 80000dc2 <release>
}
    80006298:	60e2                	ld	ra,24(sp)
    8000629a:	6442                	ld	s0,16(sp)
    8000629c:	64a2                	ld	s1,8(sp)
    8000629e:	6902                	ld	s2,0(sp)
    800062a0:	6105                	addi	sp,sp,32
    800062a2:	8082                	ret
      panic("virtio_disk_intr status");
    800062a4:	00002517          	auipc	a0,0x2
    800062a8:	55450513          	addi	a0,a0,1364 # 800087f8 <syscalls+0x3d0>
    800062ac:	ffffa097          	auipc	ra,0xffffa
    800062b0:	296080e7          	jalr	662(ra) # 80000542 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
