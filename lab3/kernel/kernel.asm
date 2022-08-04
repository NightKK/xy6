
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
    80000060:	ea478793          	addi	a5,a5,-348 # 80005f00 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd77df>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e0278793          	addi	a5,a5,-510 # 80000ea8 <main>
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
    80000110:	af2080e7          	jalr	-1294(ra) # 80000bfe <acquire>
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
    8000012a:	694080e7          	jalr	1684(ra) # 800027ba <either_copyin>
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
    80000152:	b64080e7          	jalr	-1180(ra) # 80000cb2 <release>

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
    800001a0:	a62080e7          	jalr	-1438(ra) # 80000bfe <acquire>
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
    800001ce:	986080e7          	jalr	-1658(ra) # 80001b50 <myproc>
    800001d2:	591c                	lw	a5,48(a0)
    800001d4:	e7b5                	bnez	a5,80000240 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001d6:	85a6                	mv	a1,s1
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	330080e7          	jalr	816(ra) # 8000250a <sleep>
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
    8000021a:	54e080e7          	jalr	1358(ra) # 80002764 <either_copyout>
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
    80000236:	a80080e7          	jalr	-1408(ra) # 80000cb2 <release>

  return target - n;
    8000023a:	413b053b          	subw	a0,s6,s3
    8000023e:	a811                	j	80000252 <consoleread+0xe4>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	5f050513          	addi	a0,a0,1520 # 80011830 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	a6a080e7          	jalr	-1430(ra) # 80000cb2 <release>
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
    800002dc:	926080e7          	jalr	-1754(ra) # 80000bfe <acquire>

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
    800002fa:	51a080e7          	jalr	1306(ra) # 80002810 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fe:	00011517          	auipc	a0,0x11
    80000302:	53250513          	addi	a0,a0,1330 # 80011830 <cons>
    80000306:	00001097          	auipc	ra,0x1
    8000030a:	9ac080e7          	jalr	-1620(ra) # 80000cb2 <release>
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
    8000044e:	240080e7          	jalr	576(ra) # 8000268a <wakeup>
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
    80000460:	ba458593          	addi	a1,a1,-1116 # 80008000 <etext>
    80000464:	00011517          	auipc	a0,0x11
    80000468:	3cc50513          	addi	a0,a0,972 # 80011830 <cons>
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	702080e7          	jalr	1794(ra) # 80000b6e <initlock>

  uartinit();
    80000474:	00000097          	auipc	ra,0x0
    80000478:	32a080e7          	jalr	810(ra) # 8000079e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047c:	00021797          	auipc	a5,0x21
    80000480:	73478793          	addi	a5,a5,1844 # 80021bb0 <devsw>
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
    800004c2:	b7260613          	addi	a2,a2,-1166 # 80008030 <digits>
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
    8000055a:	ab250513          	addi	a0,a0,-1358 # 80008008 <etext+0x8>
    8000055e:	00000097          	auipc	ra,0x0
    80000562:	02e080e7          	jalr	46(ra) # 8000058c <printf>
  printf(s);
    80000566:	8526                	mv	a0,s1
    80000568:	00000097          	auipc	ra,0x0
    8000056c:	024080e7          	jalr	36(ra) # 8000058c <printf>
  printf("\n");
    80000570:	00008517          	auipc	a0,0x8
    80000574:	b4850513          	addi	a0,a0,-1208 # 800080b8 <digits+0x88>
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
    800005ee:	a46b0b13          	addi	s6,s6,-1466 # 80008030 <digits>
    switch(c){
    800005f2:	07300c93          	li	s9,115
    800005f6:	06400c13          	li	s8,100
    800005fa:	a82d                	j	80000634 <printf+0xa8>
    acquire(&pr.lock);
    800005fc:	00011517          	auipc	a0,0x11
    80000600:	2dc50513          	addi	a0,a0,732 # 800118d8 <pr>
    80000604:	00000097          	auipc	ra,0x0
    80000608:	5fa080e7          	jalr	1530(ra) # 80000bfe <acquire>
    8000060c:	bf7d                	j	800005ca <printf+0x3e>
    panic("null fmt");
    8000060e:	00008517          	auipc	a0,0x8
    80000612:	a0a50513          	addi	a0,a0,-1526 # 80008018 <etext+0x18>
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
    8000070c:	90848493          	addi	s1,s1,-1784 # 80008010 <etext+0x10>
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
    80000766:	550080e7          	jalr	1360(ra) # 80000cb2 <release>
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
    80000782:	8aa58593          	addi	a1,a1,-1878 # 80008028 <etext+0x28>
    80000786:	8526                	mv	a0,s1
    80000788:	00000097          	auipc	ra,0x0
    8000078c:	3e6080e7          	jalr	998(ra) # 80000b6e <initlock>
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
    800007d2:	87a58593          	addi	a1,a1,-1926 # 80008048 <digits+0x18>
    800007d6:	00011517          	auipc	a0,0x11
    800007da:	12250513          	addi	a0,a0,290 # 800118f8 <uart_tx_lock>
    800007de:	00000097          	auipc	ra,0x0
    800007e2:	390080e7          	jalr	912(ra) # 80000b6e <initlock>
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
    800007fe:	3b8080e7          	jalr	952(ra) # 80000bb2 <push_off>

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
    8000082c:	42a080e7          	jalr	1066(ra) # 80000c52 <pop_off>
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
    800008a6:	de8080e7          	jalr	-536(ra) # 8000268a <wakeup>
    
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
    800008ea:	318080e7          	jalr	792(ra) # 80000bfe <acquire>
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
    80000940:	bce080e7          	jalr	-1074(ra) # 8000250a <sleep>
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
    80000986:	330080e7          	jalr	816(ra) # 80000cb2 <release>
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
    800009f2:	210080e7          	jalr	528(ra) # 80000bfe <acquire>
  uartstart();
    800009f6:	00000097          	auipc	ra,0x0
    800009fa:	e44080e7          	jalr	-444(ra) # 8000083a <uartstart>
  release(&uart_tx_lock);
    800009fe:	8526                	mv	a0,s1
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	2b2080e7          	jalr	690(ra) # 80000cb2 <release>
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
    80000a22:	ebb9                	bnez	a5,80000a78 <kfree+0x66>
    80000a24:	84aa                	mv	s1,a0
    80000a26:	00026797          	auipc	a5,0x26
    80000a2a:	5fa78793          	addi	a5,a5,1530 # 80027020 <end>
    80000a2e:	04f56563          	bltu	a0,a5,80000a78 <kfree+0x66>
    80000a32:	47c5                	li	a5,17
    80000a34:	07ee                	slli	a5,a5,0x1b
    80000a36:	04f57163          	bgeu	a0,a5,80000a78 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a3a:	6605                	lui	a2,0x1
    80000a3c:	4585                	li	a1,1
    80000a3e:	00000097          	auipc	ra,0x0
    80000a42:	2bc080e7          	jalr	700(ra) # 80000cfa <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a46:	00011917          	auipc	s2,0x11
    80000a4a:	eea90913          	addi	s2,s2,-278 # 80011930 <kmem>
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	1ae080e7          	jalr	430(ra) # 80000bfe <acquire>
  r->next = kmem.freelist;
    80000a58:	01893783          	ld	a5,24(s2)
    80000a5c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a5e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a62:	854a                	mv	a0,s2
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	24e080e7          	jalr	590(ra) # 80000cb2 <release>
}
    80000a6c:	60e2                	ld	ra,24(sp)
    80000a6e:	6442                	ld	s0,16(sp)
    80000a70:	64a2                	ld	s1,8(sp)
    80000a72:	6902                	ld	s2,0(sp)
    80000a74:	6105                	addi	sp,sp,32
    80000a76:	8082                	ret
    panic("kfree");
    80000a78:	00007517          	auipc	a0,0x7
    80000a7c:	5d850513          	addi	a0,a0,1496 # 80008050 <digits+0x20>
    80000a80:	00000097          	auipc	ra,0x0
    80000a84:	ac2080e7          	jalr	-1342(ra) # 80000542 <panic>

0000000080000a88 <freerange>:
{
    80000a88:	7179                	addi	sp,sp,-48
    80000a8a:	f406                	sd	ra,40(sp)
    80000a8c:	f022                	sd	s0,32(sp)
    80000a8e:	ec26                	sd	s1,24(sp)
    80000a90:	e84a                	sd	s2,16(sp)
    80000a92:	e44e                	sd	s3,8(sp)
    80000a94:	e052                	sd	s4,0(sp)
    80000a96:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a98:	6785                	lui	a5,0x1
    80000a9a:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a9e:	94aa                	add	s1,s1,a0
    80000aa0:	757d                	lui	a0,0xfffff
    80000aa2:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa4:	94be                	add	s1,s1,a5
    80000aa6:	0095ee63          	bltu	a1,s1,80000ac2 <freerange+0x3a>
    80000aaa:	892e                	mv	s2,a1
    kfree(p);
    80000aac:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aae:	6985                	lui	s3,0x1
    kfree(p);
    80000ab0:	01448533          	add	a0,s1,s4
    80000ab4:	00000097          	auipc	ra,0x0
    80000ab8:	f5e080e7          	jalr	-162(ra) # 80000a12 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000abc:	94ce                	add	s1,s1,s3
    80000abe:	fe9979e3          	bgeu	s2,s1,80000ab0 <freerange+0x28>
}
    80000ac2:	70a2                	ld	ra,40(sp)
    80000ac4:	7402                	ld	s0,32(sp)
    80000ac6:	64e2                	ld	s1,24(sp)
    80000ac8:	6942                	ld	s2,16(sp)
    80000aca:	69a2                	ld	s3,8(sp)
    80000acc:	6a02                	ld	s4,0(sp)
    80000ace:	6145                	addi	sp,sp,48
    80000ad0:	8082                	ret

0000000080000ad2 <kinit>:
{
    80000ad2:	1141                	addi	sp,sp,-16
    80000ad4:	e406                	sd	ra,8(sp)
    80000ad6:	e022                	sd	s0,0(sp)
    80000ad8:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ada:	00007597          	auipc	a1,0x7
    80000ade:	57e58593          	addi	a1,a1,1406 # 80008058 <digits+0x28>
    80000ae2:	00011517          	auipc	a0,0x11
    80000ae6:	e4e50513          	addi	a0,a0,-434 # 80011930 <kmem>
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	084080e7          	jalr	132(ra) # 80000b6e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000af2:	45c5                	li	a1,17
    80000af4:	05ee                	slli	a1,a1,0x1b
    80000af6:	00026517          	auipc	a0,0x26
    80000afa:	52a50513          	addi	a0,a0,1322 # 80027020 <end>
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	f8a080e7          	jalr	-118(ra) # 80000a88 <freerange>
}
    80000b06:	60a2                	ld	ra,8(sp)
    80000b08:	6402                	ld	s0,0(sp)
    80000b0a:	0141                	addi	sp,sp,16
    80000b0c:	8082                	ret

0000000080000b0e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b0e:	1101                	addi	sp,sp,-32
    80000b10:	ec06                	sd	ra,24(sp)
    80000b12:	e822                	sd	s0,16(sp)
    80000b14:	e426                	sd	s1,8(sp)
    80000b16:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b18:	00011497          	auipc	s1,0x11
    80000b1c:	e1848493          	addi	s1,s1,-488 # 80011930 <kmem>
    80000b20:	8526                	mv	a0,s1
    80000b22:	00000097          	auipc	ra,0x0
    80000b26:	0dc080e7          	jalr	220(ra) # 80000bfe <acquire>
  r = kmem.freelist;
    80000b2a:	6c84                	ld	s1,24(s1)
  if(r)
    80000b2c:	c885                	beqz	s1,80000b5c <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b2e:	609c                	ld	a5,0(s1)
    80000b30:	00011517          	auipc	a0,0x11
    80000b34:	e0050513          	addi	a0,a0,-512 # 80011930 <kmem>
    80000b38:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b3a:	00000097          	auipc	ra,0x0
    80000b3e:	178080e7          	jalr	376(ra) # 80000cb2 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b42:	6605                	lui	a2,0x1
    80000b44:	4595                	li	a1,5
    80000b46:	8526                	mv	a0,s1
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	1b2080e7          	jalr	434(ra) # 80000cfa <memset>
  return (void*)r;
}
    80000b50:	8526                	mv	a0,s1
    80000b52:	60e2                	ld	ra,24(sp)
    80000b54:	6442                	ld	s0,16(sp)
    80000b56:	64a2                	ld	s1,8(sp)
    80000b58:	6105                	addi	sp,sp,32
    80000b5a:	8082                	ret
  release(&kmem.lock);
    80000b5c:	00011517          	auipc	a0,0x11
    80000b60:	dd450513          	addi	a0,a0,-556 # 80011930 <kmem>
    80000b64:	00000097          	auipc	ra,0x0
    80000b68:	14e080e7          	jalr	334(ra) # 80000cb2 <release>
  if(r)
    80000b6c:	b7d5                	j	80000b50 <kalloc+0x42>

0000000080000b6e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b6e:	1141                	addi	sp,sp,-16
    80000b70:	e422                	sd	s0,8(sp)
    80000b72:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b74:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b76:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b7a:	00053823          	sd	zero,16(a0)
}
    80000b7e:	6422                	ld	s0,8(sp)
    80000b80:	0141                	addi	sp,sp,16
    80000b82:	8082                	ret

0000000080000b84 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b84:	411c                	lw	a5,0(a0)
    80000b86:	e399                	bnez	a5,80000b8c <holding+0x8>
    80000b88:	4501                	li	a0,0
  return r;
}
    80000b8a:	8082                	ret
{
    80000b8c:	1101                	addi	sp,sp,-32
    80000b8e:	ec06                	sd	ra,24(sp)
    80000b90:	e822                	sd	s0,16(sp)
    80000b92:	e426                	sd	s1,8(sp)
    80000b94:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b96:	6904                	ld	s1,16(a0)
    80000b98:	00001097          	auipc	ra,0x1
    80000b9c:	f9c080e7          	jalr	-100(ra) # 80001b34 <mycpu>
    80000ba0:	40a48533          	sub	a0,s1,a0
    80000ba4:	00153513          	seqz	a0,a0
}
    80000ba8:	60e2                	ld	ra,24(sp)
    80000baa:	6442                	ld	s0,16(sp)
    80000bac:	64a2                	ld	s1,8(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret

0000000080000bb2 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb2:	1101                	addi	sp,sp,-32
    80000bb4:	ec06                	sd	ra,24(sp)
    80000bb6:	e822                	sd	s0,16(sp)
    80000bb8:	e426                	sd	s1,8(sp)
    80000bba:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbc:	100024f3          	csrr	s1,sstatus
    80000bc0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc6:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bca:	00001097          	auipc	ra,0x1
    80000bce:	f6a080e7          	jalr	-150(ra) # 80001b34 <mycpu>
    80000bd2:	5d3c                	lw	a5,120(a0)
    80000bd4:	cf89                	beqz	a5,80000bee <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd6:	00001097          	auipc	ra,0x1
    80000bda:	f5e080e7          	jalr	-162(ra) # 80001b34 <mycpu>
    80000bde:	5d3c                	lw	a5,120(a0)
    80000be0:	2785                	addiw	a5,a5,1
    80000be2:	dd3c                	sw	a5,120(a0)
}
    80000be4:	60e2                	ld	ra,24(sp)
    80000be6:	6442                	ld	s0,16(sp)
    80000be8:	64a2                	ld	s1,8(sp)
    80000bea:	6105                	addi	sp,sp,32
    80000bec:	8082                	ret
    mycpu()->intena = old;
    80000bee:	00001097          	auipc	ra,0x1
    80000bf2:	f46080e7          	jalr	-186(ra) # 80001b34 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bf6:	8085                	srli	s1,s1,0x1
    80000bf8:	8885                	andi	s1,s1,1
    80000bfa:	dd64                	sw	s1,124(a0)
    80000bfc:	bfe9                	j	80000bd6 <push_off+0x24>

0000000080000bfe <acquire>:
{
    80000bfe:	1101                	addi	sp,sp,-32
    80000c00:	ec06                	sd	ra,24(sp)
    80000c02:	e822                	sd	s0,16(sp)
    80000c04:	e426                	sd	s1,8(sp)
    80000c06:	1000                	addi	s0,sp,32
    80000c08:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c0a:	00000097          	auipc	ra,0x0
    80000c0e:	fa8080e7          	jalr	-88(ra) # 80000bb2 <push_off>
  if(holding(lk))
    80000c12:	8526                	mv	a0,s1
    80000c14:	00000097          	auipc	ra,0x0
    80000c18:	f70080e7          	jalr	-144(ra) # 80000b84 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c1c:	4705                	li	a4,1
  if(holding(lk))
    80000c1e:	e115                	bnez	a0,80000c42 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c20:	87ba                	mv	a5,a4
    80000c22:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c26:	2781                	sext.w	a5,a5
    80000c28:	ffe5                	bnez	a5,80000c20 <acquire+0x22>
  __sync_synchronize();
    80000c2a:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	f06080e7          	jalr	-250(ra) # 80001b34 <mycpu>
    80000c36:	e888                	sd	a0,16(s1)
}
    80000c38:	60e2                	ld	ra,24(sp)
    80000c3a:	6442                	ld	s0,16(sp)
    80000c3c:	64a2                	ld	s1,8(sp)
    80000c3e:	6105                	addi	sp,sp,32
    80000c40:	8082                	ret
    panic("acquire");
    80000c42:	00007517          	auipc	a0,0x7
    80000c46:	41e50513          	addi	a0,a0,1054 # 80008060 <digits+0x30>
    80000c4a:	00000097          	auipc	ra,0x0
    80000c4e:	8f8080e7          	jalr	-1800(ra) # 80000542 <panic>

0000000080000c52 <pop_off>:

void
pop_off(void)
{
    80000c52:	1141                	addi	sp,sp,-16
    80000c54:	e406                	sd	ra,8(sp)
    80000c56:	e022                	sd	s0,0(sp)
    80000c58:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c5a:	00001097          	auipc	ra,0x1
    80000c5e:	eda080e7          	jalr	-294(ra) # 80001b34 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c62:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c66:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c68:	e78d                	bnez	a5,80000c92 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c6a:	5d3c                	lw	a5,120(a0)
    80000c6c:	02f05b63          	blez	a5,80000ca2 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c70:	37fd                	addiw	a5,a5,-1
    80000c72:	0007871b          	sext.w	a4,a5
    80000c76:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c78:	eb09                	bnez	a4,80000c8a <pop_off+0x38>
    80000c7a:	5d7c                	lw	a5,124(a0)
    80000c7c:	c799                	beqz	a5,80000c8a <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c7e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c82:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c86:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c8a:	60a2                	ld	ra,8(sp)
    80000c8c:	6402                	ld	s0,0(sp)
    80000c8e:	0141                	addi	sp,sp,16
    80000c90:	8082                	ret
    panic("pop_off - interruptible");
    80000c92:	00007517          	auipc	a0,0x7
    80000c96:	3d650513          	addi	a0,a0,982 # 80008068 <digits+0x38>
    80000c9a:	00000097          	auipc	ra,0x0
    80000c9e:	8a8080e7          	jalr	-1880(ra) # 80000542 <panic>
    panic("pop_off");
    80000ca2:	00007517          	auipc	a0,0x7
    80000ca6:	3de50513          	addi	a0,a0,990 # 80008080 <digits+0x50>
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	898080e7          	jalr	-1896(ra) # 80000542 <panic>

0000000080000cb2 <release>:
{
    80000cb2:	1101                	addi	sp,sp,-32
    80000cb4:	ec06                	sd	ra,24(sp)
    80000cb6:	e822                	sd	s0,16(sp)
    80000cb8:	e426                	sd	s1,8(sp)
    80000cba:	1000                	addi	s0,sp,32
    80000cbc:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cbe:	00000097          	auipc	ra,0x0
    80000cc2:	ec6080e7          	jalr	-314(ra) # 80000b84 <holding>
    80000cc6:	c115                	beqz	a0,80000cea <release+0x38>
  lk->cpu = 0;
    80000cc8:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ccc:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cd0:	0f50000f          	fence	iorw,ow
    80000cd4:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	f7a080e7          	jalr	-134(ra) # 80000c52 <pop_off>
}
    80000ce0:	60e2                	ld	ra,24(sp)
    80000ce2:	6442                	ld	s0,16(sp)
    80000ce4:	64a2                	ld	s1,8(sp)
    80000ce6:	6105                	addi	sp,sp,32
    80000ce8:	8082                	ret
    panic("release");
    80000cea:	00007517          	auipc	a0,0x7
    80000cee:	39e50513          	addi	a0,a0,926 # 80008088 <digits+0x58>
    80000cf2:	00000097          	auipc	ra,0x0
    80000cf6:	850080e7          	jalr	-1968(ra) # 80000542 <panic>

0000000080000cfa <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cfa:	1141                	addi	sp,sp,-16
    80000cfc:	e422                	sd	s0,8(sp)
    80000cfe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d00:	ca19                	beqz	a2,80000d16 <memset+0x1c>
    80000d02:	87aa                	mv	a5,a0
    80000d04:	1602                	slli	a2,a2,0x20
    80000d06:	9201                	srli	a2,a2,0x20
    80000d08:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d0c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d10:	0785                	addi	a5,a5,1
    80000d12:	fee79de3          	bne	a5,a4,80000d0c <memset+0x12>
  }
  return dst;
}
    80000d16:	6422                	ld	s0,8(sp)
    80000d18:	0141                	addi	sp,sp,16
    80000d1a:	8082                	ret

0000000080000d1c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d1c:	1141                	addi	sp,sp,-16
    80000d1e:	e422                	sd	s0,8(sp)
    80000d20:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d22:	ca05                	beqz	a2,80000d52 <memcmp+0x36>
    80000d24:	fff6069b          	addiw	a3,a2,-1
    80000d28:	1682                	slli	a3,a3,0x20
    80000d2a:	9281                	srli	a3,a3,0x20
    80000d2c:	0685                	addi	a3,a3,1
    80000d2e:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d30:	00054783          	lbu	a5,0(a0)
    80000d34:	0005c703          	lbu	a4,0(a1)
    80000d38:	00e79863          	bne	a5,a4,80000d48 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d3c:	0505                	addi	a0,a0,1
    80000d3e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d40:	fed518e3          	bne	a0,a3,80000d30 <memcmp+0x14>
  }

  return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	a019                	j	80000d4c <memcmp+0x30>
      return *s1 - *s2;
    80000d48:	40e7853b          	subw	a0,a5,a4
}
    80000d4c:	6422                	ld	s0,8(sp)
    80000d4e:	0141                	addi	sp,sp,16
    80000d50:	8082                	ret
  return 0;
    80000d52:	4501                	li	a0,0
    80000d54:	bfe5                	j	80000d4c <memcmp+0x30>

0000000080000d56 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d56:	1141                	addi	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d5c:	02a5e563          	bltu	a1,a0,80000d86 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d60:	fff6069b          	addiw	a3,a2,-1
    80000d64:	ce11                	beqz	a2,80000d80 <memmove+0x2a>
    80000d66:	1682                	slli	a3,a3,0x20
    80000d68:	9281                	srli	a3,a3,0x20
    80000d6a:	0685                	addi	a3,a3,1
    80000d6c:	96ae                	add	a3,a3,a1
    80000d6e:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d70:	0585                	addi	a1,a1,1
    80000d72:	0785                	addi	a5,a5,1
    80000d74:	fff5c703          	lbu	a4,-1(a1)
    80000d78:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d7c:	fed59ae3          	bne	a1,a3,80000d70 <memmove+0x1a>

  return dst;
}
    80000d80:	6422                	ld	s0,8(sp)
    80000d82:	0141                	addi	sp,sp,16
    80000d84:	8082                	ret
  if(s < d && s + n > d){
    80000d86:	02061713          	slli	a4,a2,0x20
    80000d8a:	9301                	srli	a4,a4,0x20
    80000d8c:	00e587b3          	add	a5,a1,a4
    80000d90:	fcf578e3          	bgeu	a0,a5,80000d60 <memmove+0xa>
    d += n;
    80000d94:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d96:	fff6069b          	addiw	a3,a2,-1
    80000d9a:	d27d                	beqz	a2,80000d80 <memmove+0x2a>
    80000d9c:	02069613          	slli	a2,a3,0x20
    80000da0:	9201                	srli	a2,a2,0x20
    80000da2:	fff64613          	not	a2,a2
    80000da6:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000da8:	17fd                	addi	a5,a5,-1
    80000daa:	177d                	addi	a4,a4,-1
    80000dac:	0007c683          	lbu	a3,0(a5)
    80000db0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000db4:	fef61ae3          	bne	a2,a5,80000da8 <memmove+0x52>
    80000db8:	b7e1                	j	80000d80 <memmove+0x2a>

0000000080000dba <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dba:	1141                	addi	sp,sp,-16
    80000dbc:	e406                	sd	ra,8(sp)
    80000dbe:	e022                	sd	s0,0(sp)
    80000dc0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dc2:	00000097          	auipc	ra,0x0
    80000dc6:	f94080e7          	jalr	-108(ra) # 80000d56 <memmove>
}
    80000dca:	60a2                	ld	ra,8(sp)
    80000dcc:	6402                	ld	s0,0(sp)
    80000dce:	0141                	addi	sp,sp,16
    80000dd0:	8082                	ret

0000000080000dd2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dd2:	1141                	addi	sp,sp,-16
    80000dd4:	e422                	sd	s0,8(sp)
    80000dd6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dd8:	ce11                	beqz	a2,80000df4 <strncmp+0x22>
    80000dda:	00054783          	lbu	a5,0(a0)
    80000dde:	cf89                	beqz	a5,80000df8 <strncmp+0x26>
    80000de0:	0005c703          	lbu	a4,0(a1)
    80000de4:	00f71a63          	bne	a4,a5,80000df8 <strncmp+0x26>
    n--, p++, q++;
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	0505                	addi	a0,a0,1
    80000dec:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dee:	f675                	bnez	a2,80000dda <strncmp+0x8>
  if(n == 0)
    return 0;
    80000df0:	4501                	li	a0,0
    80000df2:	a809                	j	80000e04 <strncmp+0x32>
    80000df4:	4501                	li	a0,0
    80000df6:	a039                	j	80000e04 <strncmp+0x32>
  if(n == 0)
    80000df8:	ca09                	beqz	a2,80000e0a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dfa:	00054503          	lbu	a0,0(a0)
    80000dfe:	0005c783          	lbu	a5,0(a1)
    80000e02:	9d1d                	subw	a0,a0,a5
}
    80000e04:	6422                	ld	s0,8(sp)
    80000e06:	0141                	addi	sp,sp,16
    80000e08:	8082                	ret
    return 0;
    80000e0a:	4501                	li	a0,0
    80000e0c:	bfe5                	j	80000e04 <strncmp+0x32>

0000000080000e0e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e0e:	1141                	addi	sp,sp,-16
    80000e10:	e422                	sd	s0,8(sp)
    80000e12:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e14:	872a                	mv	a4,a0
    80000e16:	8832                	mv	a6,a2
    80000e18:	367d                	addiw	a2,a2,-1
    80000e1a:	01005963          	blez	a6,80000e2c <strncpy+0x1e>
    80000e1e:	0705                	addi	a4,a4,1
    80000e20:	0005c783          	lbu	a5,0(a1)
    80000e24:	fef70fa3          	sb	a5,-1(a4)
    80000e28:	0585                	addi	a1,a1,1
    80000e2a:	f7f5                	bnez	a5,80000e16 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e2c:	86ba                	mv	a3,a4
    80000e2e:	00c05c63          	blez	a2,80000e46 <strncpy+0x38>
    *s++ = 0;
    80000e32:	0685                	addi	a3,a3,1
    80000e34:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e38:	fff6c793          	not	a5,a3
    80000e3c:	9fb9                	addw	a5,a5,a4
    80000e3e:	010787bb          	addw	a5,a5,a6
    80000e42:	fef048e3          	bgtz	a5,80000e32 <strncpy+0x24>
  return os;
}
    80000e46:	6422                	ld	s0,8(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e422                	sd	s0,8(sp)
    80000e50:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e52:	02c05363          	blez	a2,80000e78 <safestrcpy+0x2c>
    80000e56:	fff6069b          	addiw	a3,a2,-1
    80000e5a:	1682                	slli	a3,a3,0x20
    80000e5c:	9281                	srli	a3,a3,0x20
    80000e5e:	96ae                	add	a3,a3,a1
    80000e60:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e62:	00d58963          	beq	a1,a3,80000e74 <safestrcpy+0x28>
    80000e66:	0585                	addi	a1,a1,1
    80000e68:	0785                	addi	a5,a5,1
    80000e6a:	fff5c703          	lbu	a4,-1(a1)
    80000e6e:	fee78fa3          	sb	a4,-1(a5)
    80000e72:	fb65                	bnez	a4,80000e62 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e74:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e78:	6422                	ld	s0,8(sp)
    80000e7a:	0141                	addi	sp,sp,16
    80000e7c:	8082                	ret

0000000080000e7e <strlen>:

int
strlen(const char *s)
{
    80000e7e:	1141                	addi	sp,sp,-16
    80000e80:	e422                	sd	s0,8(sp)
    80000e82:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e84:	00054783          	lbu	a5,0(a0)
    80000e88:	cf91                	beqz	a5,80000ea4 <strlen+0x26>
    80000e8a:	0505                	addi	a0,a0,1
    80000e8c:	87aa                	mv	a5,a0
    80000e8e:	4685                	li	a3,1
    80000e90:	9e89                	subw	a3,a3,a0
    80000e92:	00f6853b          	addw	a0,a3,a5
    80000e96:	0785                	addi	a5,a5,1
    80000e98:	fff7c703          	lbu	a4,-1(a5)
    80000e9c:	fb7d                	bnez	a4,80000e92 <strlen+0x14>
    ;
  return n;
}
    80000e9e:	6422                	ld	s0,8(sp)
    80000ea0:	0141                	addi	sp,sp,16
    80000ea2:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ea4:	4501                	li	a0,0
    80000ea6:	bfe5                	j	80000e9e <strlen+0x20>

0000000080000ea8 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ea8:	1141                	addi	sp,sp,-16
    80000eaa:	e406                	sd	ra,8(sp)
    80000eac:	e022                	sd	s0,0(sp)
    80000eae:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eb0:	00001097          	auipc	ra,0x1
    80000eb4:	c74080e7          	jalr	-908(ra) # 80001b24 <cpuid>
#endif    
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eb8:	00008717          	auipc	a4,0x8
    80000ebc:	15470713          	addi	a4,a4,340 # 8000900c <started>
  if(cpuid() == 0){
    80000ec0:	c139                	beqz	a0,80000f06 <main+0x5e>
    while(started == 0)
    80000ec2:	431c                	lw	a5,0(a4)
    80000ec4:	2781                	sext.w	a5,a5
    80000ec6:	dff5                	beqz	a5,80000ec2 <main+0x1a>
      ;
    __sync_synchronize();
    80000ec8:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ecc:	00001097          	auipc	ra,0x1
    80000ed0:	c58080e7          	jalr	-936(ra) # 80001b24 <cpuid>
    80000ed4:	85aa                	mv	a1,a0
    80000ed6:	00007517          	auipc	a0,0x7
    80000eda:	1d250513          	addi	a0,a0,466 # 800080a8 <digits+0x78>
    80000ede:	fffff097          	auipc	ra,0xfffff
    80000ee2:	6ae080e7          	jalr	1710(ra) # 8000058c <printf>
    kvminithart();    // turn on paging
    80000ee6:	00000097          	auipc	ra,0x0
    80000eea:	0e0080e7          	jalr	224(ra) # 80000fc6 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eee:	00002097          	auipc	ra,0x2
    80000ef2:	a62080e7          	jalr	-1438(ra) # 80002950 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ef6:	00005097          	auipc	ra,0x5
    80000efa:	04a080e7          	jalr	74(ra) # 80005f40 <plicinithart>
  }

  scheduler();        
    80000efe:	00001097          	auipc	ra,0x1
    80000f02:	314080e7          	jalr	788(ra) # 80002212 <scheduler>
    consoleinit();
    80000f06:	fffff097          	auipc	ra,0xfffff
    80000f0a:	54e080e7          	jalr	1358(ra) # 80000454 <consoleinit>
    statsinit();
    80000f0e:	00005097          	auipc	ra,0x5
    80000f12:	7d4080e7          	jalr	2004(ra) # 800066e2 <statsinit>
    printfinit();
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	856080e7          	jalr	-1962(ra) # 8000076c <printfinit>
    printf("\n");
    80000f1e:	00007517          	auipc	a0,0x7
    80000f22:	19a50513          	addi	a0,a0,410 # 800080b8 <digits+0x88>
    80000f26:	fffff097          	auipc	ra,0xfffff
    80000f2a:	666080e7          	jalr	1638(ra) # 8000058c <printf>
    printf("xv6 kernel is booting\n");
    80000f2e:	00007517          	auipc	a0,0x7
    80000f32:	16250513          	addi	a0,a0,354 # 80008090 <digits+0x60>
    80000f36:	fffff097          	auipc	ra,0xfffff
    80000f3a:	656080e7          	jalr	1622(ra) # 8000058c <printf>
    printf("\n");
    80000f3e:	00007517          	auipc	a0,0x7
    80000f42:	17a50513          	addi	a0,a0,378 # 800080b8 <digits+0x88>
    80000f46:	fffff097          	auipc	ra,0xfffff
    80000f4a:	646080e7          	jalr	1606(ra) # 8000058c <printf>
    kinit();         // physical page allocator
    80000f4e:	00000097          	auipc	ra,0x0
    80000f52:	b84080e7          	jalr	-1148(ra) # 80000ad2 <kinit>
    kvminit();       // create kernel page table
    80000f56:	00000097          	auipc	ra,0x0
    80000f5a:	2aa080e7          	jalr	682(ra) # 80001200 <kvminit>
    kvminithart();   // turn on paging
    80000f5e:	00000097          	auipc	ra,0x0
    80000f62:	068080e7          	jalr	104(ra) # 80000fc6 <kvminithart>
    procinit();      // process table
    80000f66:	00001097          	auipc	ra,0x1
    80000f6a:	b56080e7          	jalr	-1194(ra) # 80001abc <procinit>
    trapinit();      // trap vectors
    80000f6e:	00002097          	auipc	ra,0x2
    80000f72:	9ba080e7          	jalr	-1606(ra) # 80002928 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f76:	00002097          	auipc	ra,0x2
    80000f7a:	9da080e7          	jalr	-1574(ra) # 80002950 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f7e:	00005097          	auipc	ra,0x5
    80000f82:	fac080e7          	jalr	-84(ra) # 80005f2a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f86:	00005097          	auipc	ra,0x5
    80000f8a:	fba080e7          	jalr	-70(ra) # 80005f40 <plicinithart>
    binit();         // buffer cache
    80000f8e:	00002097          	auipc	ra,0x2
    80000f92:	102080e7          	jalr	258(ra) # 80003090 <binit>
    iinit();         // inode cache
    80000f96:	00002097          	auipc	ra,0x2
    80000f9a:	792080e7          	jalr	1938(ra) # 80003728 <iinit>
    fileinit();      // file table
    80000f9e:	00003097          	auipc	ra,0x3
    80000fa2:	72c080e7          	jalr	1836(ra) # 800046ca <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fa6:	00005097          	auipc	ra,0x5
    80000faa:	0a2080e7          	jalr	162(ra) # 80006048 <virtio_disk_init>
    userinit();      // first user process
    80000fae:	00001097          	auipc	ra,0x1
    80000fb2:	f6c080e7          	jalr	-148(ra) # 80001f1a <userinit>
    __sync_synchronize();
    80000fb6:	0ff0000f          	fence
    started = 1;
    80000fba:	4785                	li	a5,1
    80000fbc:	00008717          	auipc	a4,0x8
    80000fc0:	04f72823          	sw	a5,80(a4) # 8000900c <started>
    80000fc4:	bf2d                	j	80000efe <main+0x56>

0000000080000fc6 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fc6:	1141                	addi	sp,sp,-16
    80000fc8:	e422                	sd	s0,8(sp)
    80000fca:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fcc:	00008797          	auipc	a5,0x8
    80000fd0:	0447b783          	ld	a5,68(a5) # 80009010 <kernel_pagetable>
    80000fd4:	83b1                	srli	a5,a5,0xc
    80000fd6:	577d                	li	a4,-1
    80000fd8:	177e                	slli	a4,a4,0x3f
    80000fda:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fdc:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fe0:	12000073          	sfence.vma
  sfence_vma();
}
    80000fe4:	6422                	ld	s0,8(sp)
    80000fe6:	0141                	addi	sp,sp,16
    80000fe8:	8082                	ret

0000000080000fea <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fea:	7139                	addi	sp,sp,-64
    80000fec:	fc06                	sd	ra,56(sp)
    80000fee:	f822                	sd	s0,48(sp)
    80000ff0:	f426                	sd	s1,40(sp)
    80000ff2:	f04a                	sd	s2,32(sp)
    80000ff4:	ec4e                	sd	s3,24(sp)
    80000ff6:	e852                	sd	s4,16(sp)
    80000ff8:	e456                	sd	s5,8(sp)
    80000ffa:	e05a                	sd	s6,0(sp)
    80000ffc:	0080                	addi	s0,sp,64
    80000ffe:	84aa                	mv	s1,a0
    80001000:	89ae                	mv	s3,a1
    80001002:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001004:	57fd                	li	a5,-1
    80001006:	83e9                	srli	a5,a5,0x1a
    80001008:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000100a:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000100c:	04b7f263          	bgeu	a5,a1,80001050 <walk+0x66>
    panic("walk");
    80001010:	00007517          	auipc	a0,0x7
    80001014:	0b050513          	addi	a0,a0,176 # 800080c0 <digits+0x90>
    80001018:	fffff097          	auipc	ra,0xfffff
    8000101c:	52a080e7          	jalr	1322(ra) # 80000542 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001020:	060a8663          	beqz	s5,8000108c <walk+0xa2>
    80001024:	00000097          	auipc	ra,0x0
    80001028:	aea080e7          	jalr	-1302(ra) # 80000b0e <kalloc>
    8000102c:	84aa                	mv	s1,a0
    8000102e:	c529                	beqz	a0,80001078 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001030:	6605                	lui	a2,0x1
    80001032:	4581                	li	a1,0
    80001034:	00000097          	auipc	ra,0x0
    80001038:	cc6080e7          	jalr	-826(ra) # 80000cfa <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000103c:	00c4d793          	srli	a5,s1,0xc
    80001040:	07aa                	slli	a5,a5,0xa
    80001042:	0017e793          	ori	a5,a5,1
    80001046:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000104a:	3a5d                	addiw	s4,s4,-9
    8000104c:	036a0063          	beq	s4,s6,8000106c <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001050:	0149d933          	srl	s2,s3,s4
    80001054:	1ff97913          	andi	s2,s2,511
    80001058:	090e                	slli	s2,s2,0x3
    8000105a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000105c:	00093483          	ld	s1,0(s2)
    80001060:	0014f793          	andi	a5,s1,1
    80001064:	dfd5                	beqz	a5,80001020 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001066:	80a9                	srli	s1,s1,0xa
    80001068:	04b2                	slli	s1,s1,0xc
    8000106a:	b7c5                	j	8000104a <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000106c:	00c9d513          	srli	a0,s3,0xc
    80001070:	1ff57513          	andi	a0,a0,511
    80001074:	050e                	slli	a0,a0,0x3
    80001076:	9526                	add	a0,a0,s1
}
    80001078:	70e2                	ld	ra,56(sp)
    8000107a:	7442                	ld	s0,48(sp)
    8000107c:	74a2                	ld	s1,40(sp)
    8000107e:	7902                	ld	s2,32(sp)
    80001080:	69e2                	ld	s3,24(sp)
    80001082:	6a42                	ld	s4,16(sp)
    80001084:	6aa2                	ld	s5,8(sp)
    80001086:	6b02                	ld	s6,0(sp)
    80001088:	6121                	addi	sp,sp,64
    8000108a:	8082                	ret
        return 0;
    8000108c:	4501                	li	a0,0
    8000108e:	b7ed                	j	80001078 <walk+0x8e>

0000000080001090 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001090:	57fd                	li	a5,-1
    80001092:	83e9                	srli	a5,a5,0x1a
    80001094:	00b7f463          	bgeu	a5,a1,8000109c <walkaddr+0xc>
    return 0;
    80001098:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000109a:	8082                	ret
{
    8000109c:	1141                	addi	sp,sp,-16
    8000109e:	e406                	sd	ra,8(sp)
    800010a0:	e022                	sd	s0,0(sp)
    800010a2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010a4:	4601                	li	a2,0
    800010a6:	00000097          	auipc	ra,0x0
    800010aa:	f44080e7          	jalr	-188(ra) # 80000fea <walk>
  if(pte == 0)
    800010ae:	c105                	beqz	a0,800010ce <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010b0:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010b2:	0117f693          	andi	a3,a5,17
    800010b6:	4745                	li	a4,17
    return 0;
    800010b8:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010ba:	00e68663          	beq	a3,a4,800010c6 <walkaddr+0x36>
}
    800010be:	60a2                	ld	ra,8(sp)
    800010c0:	6402                	ld	s0,0(sp)
    800010c2:	0141                	addi	sp,sp,16
    800010c4:	8082                	ret
  pa = PTE2PA(*pte);
    800010c6:	00a7d513          	srli	a0,a5,0xa
    800010ca:	0532                	slli	a0,a0,0xc
  return pa;
    800010cc:	bfcd                	j	800010be <walkaddr+0x2e>
    return 0;
    800010ce:	4501                	li	a0,0
    800010d0:	b7fd                	j	800010be <walkaddr+0x2e>

00000000800010d2 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    800010d2:	1101                	addi	sp,sp,-32
    800010d4:	ec06                	sd	ra,24(sp)
    800010d6:	e822                	sd	s0,16(sp)
    800010d8:	e426                	sd	s1,8(sp)
    800010da:	e04a                	sd	s2,0(sp)
    800010dc:	1000                	addi	s0,sp,32
    800010de:	84aa                	mv	s1,a0
  uint64 off = va % PGSIZE;
    800010e0:	1552                	slli	a0,a0,0x34
    800010e2:	03455913          	srli	s2,a0,0x34
  pte_t *pte;
  uint64 pa;

  // 使用用户进程自己的内核页表地址来翻译虚拟地址
  struct proc *p = myproc();
    800010e6:	00001097          	auipc	ra,0x1
    800010ea:	a6a080e7          	jalr	-1430(ra) # 80001b50 <myproc>
  pte = walk(p->kernel_pagetable, va, 0);
    800010ee:	4601                	li	a2,0
    800010f0:	85a6                	mv	a1,s1
    800010f2:	16853503          	ld	a0,360(a0)
    800010f6:	00000097          	auipc	ra,0x0
    800010fa:	ef4080e7          	jalr	-268(ra) # 80000fea <walk>
 
  if(pte == 0)
    800010fe:	cd11                	beqz	a0,8000111a <kvmpa+0x48>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    80001100:	6108                	ld	a0,0(a0)
    80001102:	00157793          	andi	a5,a0,1
    80001106:	c395                	beqz	a5,8000112a <kvmpa+0x58>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001108:	8129                	srli	a0,a0,0xa
    8000110a:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    8000110c:	954a                	add	a0,a0,s2
    8000110e:	60e2                	ld	ra,24(sp)
    80001110:	6442                	ld	s0,16(sp)
    80001112:	64a2                	ld	s1,8(sp)
    80001114:	6902                	ld	s2,0(sp)
    80001116:	6105                	addi	sp,sp,32
    80001118:	8082                	ret
    panic("kvmpa");
    8000111a:	00007517          	auipc	a0,0x7
    8000111e:	fae50513          	addi	a0,a0,-82 # 800080c8 <digits+0x98>
    80001122:	fffff097          	auipc	ra,0xfffff
    80001126:	420080e7          	jalr	1056(ra) # 80000542 <panic>
    panic("kvmpa");
    8000112a:	00007517          	auipc	a0,0x7
    8000112e:	f9e50513          	addi	a0,a0,-98 # 800080c8 <digits+0x98>
    80001132:	fffff097          	auipc	ra,0xfffff
    80001136:	410080e7          	jalr	1040(ra) # 80000542 <panic>

000000008000113a <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000113a:	715d                	addi	sp,sp,-80
    8000113c:	e486                	sd	ra,72(sp)
    8000113e:	e0a2                	sd	s0,64(sp)
    80001140:	fc26                	sd	s1,56(sp)
    80001142:	f84a                	sd	s2,48(sp)
    80001144:	f44e                	sd	s3,40(sp)
    80001146:	f052                	sd	s4,32(sp)
    80001148:	ec56                	sd	s5,24(sp)
    8000114a:	e85a                	sd	s6,16(sp)
    8000114c:	e45e                	sd	s7,8(sp)
    8000114e:	0880                	addi	s0,sp,80
    80001150:	8aaa                	mv	s5,a0
    80001152:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001154:	777d                	lui	a4,0xfffff
    80001156:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000115a:	167d                	addi	a2,a2,-1
    8000115c:	00b609b3          	add	s3,a2,a1
    80001160:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001164:	893e                	mv	s2,a5
    80001166:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000116a:	6b85                	lui	s7,0x1
    8000116c:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001170:	4605                	li	a2,1
    80001172:	85ca                	mv	a1,s2
    80001174:	8556                	mv	a0,s5
    80001176:	00000097          	auipc	ra,0x0
    8000117a:	e74080e7          	jalr	-396(ra) # 80000fea <walk>
    8000117e:	c51d                	beqz	a0,800011ac <mappages+0x72>
    if(*pte & PTE_V)
    80001180:	611c                	ld	a5,0(a0)
    80001182:	8b85                	andi	a5,a5,1
    80001184:	ef81                	bnez	a5,8000119c <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001186:	80b1                	srli	s1,s1,0xc
    80001188:	04aa                	slli	s1,s1,0xa
    8000118a:	0164e4b3          	or	s1,s1,s6
    8000118e:	0014e493          	ori	s1,s1,1
    80001192:	e104                	sd	s1,0(a0)
    if(a == last)
    80001194:	03390863          	beq	s2,s3,800011c4 <mappages+0x8a>
    a += PGSIZE;
    80001198:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000119a:	bfc9                	j	8000116c <mappages+0x32>
      panic("remap");
    8000119c:	00007517          	auipc	a0,0x7
    800011a0:	f3450513          	addi	a0,a0,-204 # 800080d0 <digits+0xa0>
    800011a4:	fffff097          	auipc	ra,0xfffff
    800011a8:	39e080e7          	jalr	926(ra) # 80000542 <panic>
      return -1;
    800011ac:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011ae:	60a6                	ld	ra,72(sp)
    800011b0:	6406                	ld	s0,64(sp)
    800011b2:	74e2                	ld	s1,56(sp)
    800011b4:	7942                	ld	s2,48(sp)
    800011b6:	79a2                	ld	s3,40(sp)
    800011b8:	7a02                	ld	s4,32(sp)
    800011ba:	6ae2                	ld	s5,24(sp)
    800011bc:	6b42                	ld	s6,16(sp)
    800011be:	6ba2                	ld	s7,8(sp)
    800011c0:	6161                	addi	sp,sp,80
    800011c2:	8082                	ret
  return 0;
    800011c4:	4501                	li	a0,0
    800011c6:	b7e5                	j	800011ae <mappages+0x74>

00000000800011c8 <kvmmap>:
{
    800011c8:	1141                	addi	sp,sp,-16
    800011ca:	e406                	sd	ra,8(sp)
    800011cc:	e022                	sd	s0,0(sp)
    800011ce:	0800                	addi	s0,sp,16
    800011d0:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800011d2:	86ae                	mv	a3,a1
    800011d4:	85aa                	mv	a1,a0
    800011d6:	00008517          	auipc	a0,0x8
    800011da:	e3a53503          	ld	a0,-454(a0) # 80009010 <kernel_pagetable>
    800011de:	00000097          	auipc	ra,0x0
    800011e2:	f5c080e7          	jalr	-164(ra) # 8000113a <mappages>
    800011e6:	e509                	bnez	a0,800011f0 <kvmmap+0x28>
}
    800011e8:	60a2                	ld	ra,8(sp)
    800011ea:	6402                	ld	s0,0(sp)
    800011ec:	0141                	addi	sp,sp,16
    800011ee:	8082                	ret
    panic("kvmmap");
    800011f0:	00007517          	auipc	a0,0x7
    800011f4:	ee850513          	addi	a0,a0,-280 # 800080d8 <digits+0xa8>
    800011f8:	fffff097          	auipc	ra,0xfffff
    800011fc:	34a080e7          	jalr	842(ra) # 80000542 <panic>

0000000080001200 <kvminit>:
{
    80001200:	1101                	addi	sp,sp,-32
    80001202:	ec06                	sd	ra,24(sp)
    80001204:	e822                	sd	s0,16(sp)
    80001206:	e426                	sd	s1,8(sp)
    80001208:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    8000120a:	00000097          	auipc	ra,0x0
    8000120e:	904080e7          	jalr	-1788(ra) # 80000b0e <kalloc>
    80001212:	00008797          	auipc	a5,0x8
    80001216:	dea7bf23          	sd	a0,-514(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    8000121a:	6605                	lui	a2,0x1
    8000121c:	4581                	li	a1,0
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	adc080e7          	jalr	-1316(ra) # 80000cfa <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001226:	4699                	li	a3,6
    80001228:	6605                	lui	a2,0x1
    8000122a:	100005b7          	lui	a1,0x10000
    8000122e:	10000537          	lui	a0,0x10000
    80001232:	00000097          	auipc	ra,0x0
    80001236:	f96080e7          	jalr	-106(ra) # 800011c8 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000123a:	4699                	li	a3,6
    8000123c:	6605                	lui	a2,0x1
    8000123e:	100015b7          	lui	a1,0x10001
    80001242:	10001537          	lui	a0,0x10001
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f82080e7          	jalr	-126(ra) # 800011c8 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000124e:	4699                	li	a3,6
    80001250:	6641                	lui	a2,0x10
    80001252:	020005b7          	lui	a1,0x2000
    80001256:	02000537          	lui	a0,0x2000
    8000125a:	00000097          	auipc	ra,0x0
    8000125e:	f6e080e7          	jalr	-146(ra) # 800011c8 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001262:	4699                	li	a3,6
    80001264:	00400637          	lui	a2,0x400
    80001268:	0c0005b7          	lui	a1,0xc000
    8000126c:	0c000537          	lui	a0,0xc000
    80001270:	00000097          	auipc	ra,0x0
    80001274:	f58080e7          	jalr	-168(ra) # 800011c8 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001278:	00007497          	auipc	s1,0x7
    8000127c:	d8848493          	addi	s1,s1,-632 # 80008000 <etext>
    80001280:	46a9                	li	a3,10
    80001282:	80007617          	auipc	a2,0x80007
    80001286:	d7e60613          	addi	a2,a2,-642 # 8000 <_entry-0x7fff8000>
    8000128a:	4585                	li	a1,1
    8000128c:	05fe                	slli	a1,a1,0x1f
    8000128e:	852e                	mv	a0,a1
    80001290:	00000097          	auipc	ra,0x0
    80001294:	f38080e7          	jalr	-200(ra) # 800011c8 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001298:	4699                	li	a3,6
    8000129a:	4645                	li	a2,17
    8000129c:	066e                	slli	a2,a2,0x1b
    8000129e:	8e05                	sub	a2,a2,s1
    800012a0:	85a6                	mv	a1,s1
    800012a2:	8526                	mv	a0,s1
    800012a4:	00000097          	auipc	ra,0x0
    800012a8:	f24080e7          	jalr	-220(ra) # 800011c8 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012ac:	46a9                	li	a3,10
    800012ae:	6605                	lui	a2,0x1
    800012b0:	00006597          	auipc	a1,0x6
    800012b4:	d5058593          	addi	a1,a1,-688 # 80007000 <_trampoline>
    800012b8:	04000537          	lui	a0,0x4000
    800012bc:	157d                	addi	a0,a0,-1
    800012be:	0532                	slli	a0,a0,0xc
    800012c0:	00000097          	auipc	ra,0x0
    800012c4:	f08080e7          	jalr	-248(ra) # 800011c8 <kvmmap>
}
    800012c8:	60e2                	ld	ra,24(sp)
    800012ca:	6442                	ld	s0,16(sp)
    800012cc:	64a2                	ld	s1,8(sp)
    800012ce:	6105                	addi	sp,sp,32
    800012d0:	8082                	ret

00000000800012d2 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012d2:	715d                	addi	sp,sp,-80
    800012d4:	e486                	sd	ra,72(sp)
    800012d6:	e0a2                	sd	s0,64(sp)
    800012d8:	fc26                	sd	s1,56(sp)
    800012da:	f84a                	sd	s2,48(sp)
    800012dc:	f44e                	sd	s3,40(sp)
    800012de:	f052                	sd	s4,32(sp)
    800012e0:	ec56                	sd	s5,24(sp)
    800012e2:	e85a                	sd	s6,16(sp)
    800012e4:	e45e                	sd	s7,8(sp)
    800012e6:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012e8:	03459793          	slli	a5,a1,0x34
    800012ec:	e795                	bnez	a5,80001318 <uvmunmap+0x46>
    800012ee:	8a2a                	mv	s4,a0
    800012f0:	892e                	mv	s2,a1
    800012f2:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f4:	0632                	slli	a2,a2,0xc
    800012f6:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012fa:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012fc:	6b05                	lui	s6,0x1
    800012fe:	0735e263          	bltu	a1,s3,80001362 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001302:	60a6                	ld	ra,72(sp)
    80001304:	6406                	ld	s0,64(sp)
    80001306:	74e2                	ld	s1,56(sp)
    80001308:	7942                	ld	s2,48(sp)
    8000130a:	79a2                	ld	s3,40(sp)
    8000130c:	7a02                	ld	s4,32(sp)
    8000130e:	6ae2                	ld	s5,24(sp)
    80001310:	6b42                	ld	s6,16(sp)
    80001312:	6ba2                	ld	s7,8(sp)
    80001314:	6161                	addi	sp,sp,80
    80001316:	8082                	ret
    panic("uvmunmap: not aligned");
    80001318:	00007517          	auipc	a0,0x7
    8000131c:	dc850513          	addi	a0,a0,-568 # 800080e0 <digits+0xb0>
    80001320:	fffff097          	auipc	ra,0xfffff
    80001324:	222080e7          	jalr	546(ra) # 80000542 <panic>
      panic("uvmunmap: walk");
    80001328:	00007517          	auipc	a0,0x7
    8000132c:	dd050513          	addi	a0,a0,-560 # 800080f8 <digits+0xc8>
    80001330:	fffff097          	auipc	ra,0xfffff
    80001334:	212080e7          	jalr	530(ra) # 80000542 <panic>
      panic("uvmunmap: not mapped");
    80001338:	00007517          	auipc	a0,0x7
    8000133c:	dd050513          	addi	a0,a0,-560 # 80008108 <digits+0xd8>
    80001340:	fffff097          	auipc	ra,0xfffff
    80001344:	202080e7          	jalr	514(ra) # 80000542 <panic>
      panic("uvmunmap: not a leaf");
    80001348:	00007517          	auipc	a0,0x7
    8000134c:	dd850513          	addi	a0,a0,-552 # 80008120 <digits+0xf0>
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	1f2080e7          	jalr	498(ra) # 80000542 <panic>
    *pte = 0;
    80001358:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000135c:	995a                	add	s2,s2,s6
    8000135e:	fb3972e3          	bgeu	s2,s3,80001302 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001362:	4601                	li	a2,0
    80001364:	85ca                	mv	a1,s2
    80001366:	8552                	mv	a0,s4
    80001368:	00000097          	auipc	ra,0x0
    8000136c:	c82080e7          	jalr	-894(ra) # 80000fea <walk>
    80001370:	84aa                	mv	s1,a0
    80001372:	d95d                	beqz	a0,80001328 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001374:	6108                	ld	a0,0(a0)
    80001376:	00157793          	andi	a5,a0,1
    8000137a:	dfdd                	beqz	a5,80001338 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000137c:	3ff57793          	andi	a5,a0,1023
    80001380:	fd7784e3          	beq	a5,s7,80001348 <uvmunmap+0x76>
    if(do_free){
    80001384:	fc0a8ae3          	beqz	s5,80001358 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001388:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000138a:	0532                	slli	a0,a0,0xc
    8000138c:	fffff097          	auipc	ra,0xfffff
    80001390:	686080e7          	jalr	1670(ra) # 80000a12 <kfree>
    80001394:	b7d1                	j	80001358 <uvmunmap+0x86>

0000000080001396 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001396:	1101                	addi	sp,sp,-32
    80001398:	ec06                	sd	ra,24(sp)
    8000139a:	e822                	sd	s0,16(sp)
    8000139c:	e426                	sd	s1,8(sp)
    8000139e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013a0:	fffff097          	auipc	ra,0xfffff
    800013a4:	76e080e7          	jalr	1902(ra) # 80000b0e <kalloc>
    800013a8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013aa:	c519                	beqz	a0,800013b8 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013ac:	6605                	lui	a2,0x1
    800013ae:	4581                	li	a1,0
    800013b0:	00000097          	auipc	ra,0x0
    800013b4:	94a080e7          	jalr	-1718(ra) # 80000cfa <memset>
  return pagetable;
}
    800013b8:	8526                	mv	a0,s1
    800013ba:	60e2                	ld	ra,24(sp)
    800013bc:	6442                	ld	s0,16(sp)
    800013be:	64a2                	ld	s1,8(sp)
    800013c0:	6105                	addi	sp,sp,32
    800013c2:	8082                	ret

00000000800013c4 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013c4:	7179                	addi	sp,sp,-48
    800013c6:	f406                	sd	ra,40(sp)
    800013c8:	f022                	sd	s0,32(sp)
    800013ca:	ec26                	sd	s1,24(sp)
    800013cc:	e84a                	sd	s2,16(sp)
    800013ce:	e44e                	sd	s3,8(sp)
    800013d0:	e052                	sd	s4,0(sp)
    800013d2:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013d4:	6785                	lui	a5,0x1
    800013d6:	04f67863          	bgeu	a2,a5,80001426 <uvminit+0x62>
    800013da:	8a2a                	mv	s4,a0
    800013dc:	89ae                	mv	s3,a1
    800013de:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013e0:	fffff097          	auipc	ra,0xfffff
    800013e4:	72e080e7          	jalr	1838(ra) # 80000b0e <kalloc>
    800013e8:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013ea:	6605                	lui	a2,0x1
    800013ec:	4581                	li	a1,0
    800013ee:	00000097          	auipc	ra,0x0
    800013f2:	90c080e7          	jalr	-1780(ra) # 80000cfa <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013f6:	4779                	li	a4,30
    800013f8:	86ca                	mv	a3,s2
    800013fa:	6605                	lui	a2,0x1
    800013fc:	4581                	li	a1,0
    800013fe:	8552                	mv	a0,s4
    80001400:	00000097          	auipc	ra,0x0
    80001404:	d3a080e7          	jalr	-710(ra) # 8000113a <mappages>
  memmove(mem, src, sz);
    80001408:	8626                	mv	a2,s1
    8000140a:	85ce                	mv	a1,s3
    8000140c:	854a                	mv	a0,s2
    8000140e:	00000097          	auipc	ra,0x0
    80001412:	948080e7          	jalr	-1720(ra) # 80000d56 <memmove>
}
    80001416:	70a2                	ld	ra,40(sp)
    80001418:	7402                	ld	s0,32(sp)
    8000141a:	64e2                	ld	s1,24(sp)
    8000141c:	6942                	ld	s2,16(sp)
    8000141e:	69a2                	ld	s3,8(sp)
    80001420:	6a02                	ld	s4,0(sp)
    80001422:	6145                	addi	sp,sp,48
    80001424:	8082                	ret
    panic("inituvm: more than a page");
    80001426:	00007517          	auipc	a0,0x7
    8000142a:	d1250513          	addi	a0,a0,-750 # 80008138 <digits+0x108>
    8000142e:	fffff097          	auipc	ra,0xfffff
    80001432:	114080e7          	jalr	276(ra) # 80000542 <panic>

0000000080001436 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001436:	1101                	addi	sp,sp,-32
    80001438:	ec06                	sd	ra,24(sp)
    8000143a:	e822                	sd	s0,16(sp)
    8000143c:	e426                	sd	s1,8(sp)
    8000143e:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001440:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001442:	00b67d63          	bgeu	a2,a1,8000145c <uvmdealloc+0x26>
    80001446:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001448:	6785                	lui	a5,0x1
    8000144a:	17fd                	addi	a5,a5,-1
    8000144c:	00f60733          	add	a4,a2,a5
    80001450:	767d                	lui	a2,0xfffff
    80001452:	8f71                	and	a4,a4,a2
    80001454:	97ae                	add	a5,a5,a1
    80001456:	8ff1                	and	a5,a5,a2
    80001458:	00f76863          	bltu	a4,a5,80001468 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000145c:	8526                	mv	a0,s1
    8000145e:	60e2                	ld	ra,24(sp)
    80001460:	6442                	ld	s0,16(sp)
    80001462:	64a2                	ld	s1,8(sp)
    80001464:	6105                	addi	sp,sp,32
    80001466:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001468:	8f99                	sub	a5,a5,a4
    8000146a:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000146c:	4685                	li	a3,1
    8000146e:	0007861b          	sext.w	a2,a5
    80001472:	85ba                	mv	a1,a4
    80001474:	00000097          	auipc	ra,0x0
    80001478:	e5e080e7          	jalr	-418(ra) # 800012d2 <uvmunmap>
    8000147c:	b7c5                	j	8000145c <uvmdealloc+0x26>

000000008000147e <uvmalloc>:
  if(newsz < oldsz)
    8000147e:	0ab66163          	bltu	a2,a1,80001520 <uvmalloc+0xa2>
{
    80001482:	7139                	addi	sp,sp,-64
    80001484:	fc06                	sd	ra,56(sp)
    80001486:	f822                	sd	s0,48(sp)
    80001488:	f426                	sd	s1,40(sp)
    8000148a:	f04a                	sd	s2,32(sp)
    8000148c:	ec4e                	sd	s3,24(sp)
    8000148e:	e852                	sd	s4,16(sp)
    80001490:	e456                	sd	s5,8(sp)
    80001492:	0080                	addi	s0,sp,64
    80001494:	8aaa                	mv	s5,a0
    80001496:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001498:	6985                	lui	s3,0x1
    8000149a:	19fd                	addi	s3,s3,-1
    8000149c:	95ce                	add	a1,a1,s3
    8000149e:	79fd                	lui	s3,0xfffff
    800014a0:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014a4:	08c9f063          	bgeu	s3,a2,80001524 <uvmalloc+0xa6>
    800014a8:	894e                	mv	s2,s3
    mem = kalloc();
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	664080e7          	jalr	1636(ra) # 80000b0e <kalloc>
    800014b2:	84aa                	mv	s1,a0
    if(mem == 0){
    800014b4:	c51d                	beqz	a0,800014e2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014b6:	6605                	lui	a2,0x1
    800014b8:	4581                	li	a1,0
    800014ba:	00000097          	auipc	ra,0x0
    800014be:	840080e7          	jalr	-1984(ra) # 80000cfa <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014c2:	4779                	li	a4,30
    800014c4:	86a6                	mv	a3,s1
    800014c6:	6605                	lui	a2,0x1
    800014c8:	85ca                	mv	a1,s2
    800014ca:	8556                	mv	a0,s5
    800014cc:	00000097          	auipc	ra,0x0
    800014d0:	c6e080e7          	jalr	-914(ra) # 8000113a <mappages>
    800014d4:	e905                	bnez	a0,80001504 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	993e                	add	s2,s2,a5
    800014da:	fd4968e3          	bltu	s2,s4,800014aa <uvmalloc+0x2c>
  return newsz;
    800014de:	8552                	mv	a0,s4
    800014e0:	a809                	j	800014f2 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014e2:	864e                	mv	a2,s3
    800014e4:	85ca                	mv	a1,s2
    800014e6:	8556                	mv	a0,s5
    800014e8:	00000097          	auipc	ra,0x0
    800014ec:	f4e080e7          	jalr	-178(ra) # 80001436 <uvmdealloc>
      return 0;
    800014f0:	4501                	li	a0,0
}
    800014f2:	70e2                	ld	ra,56(sp)
    800014f4:	7442                	ld	s0,48(sp)
    800014f6:	74a2                	ld	s1,40(sp)
    800014f8:	7902                	ld	s2,32(sp)
    800014fa:	69e2                	ld	s3,24(sp)
    800014fc:	6a42                	ld	s4,16(sp)
    800014fe:	6aa2                	ld	s5,8(sp)
    80001500:	6121                	addi	sp,sp,64
    80001502:	8082                	ret
      kfree(mem);
    80001504:	8526                	mv	a0,s1
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	50c080e7          	jalr	1292(ra) # 80000a12 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000150e:	864e                	mv	a2,s3
    80001510:	85ca                	mv	a1,s2
    80001512:	8556                	mv	a0,s5
    80001514:	00000097          	auipc	ra,0x0
    80001518:	f22080e7          	jalr	-222(ra) # 80001436 <uvmdealloc>
      return 0;
    8000151c:	4501                	li	a0,0
    8000151e:	bfd1                	j	800014f2 <uvmalloc+0x74>
    return oldsz;
    80001520:	852e                	mv	a0,a1
}
    80001522:	8082                	ret
  return newsz;
    80001524:	8532                	mv	a0,a2
    80001526:	b7f1                	j	800014f2 <uvmalloc+0x74>

0000000080001528 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001528:	7179                	addi	sp,sp,-48
    8000152a:	f406                	sd	ra,40(sp)
    8000152c:	f022                	sd	s0,32(sp)
    8000152e:	ec26                	sd	s1,24(sp)
    80001530:	e84a                	sd	s2,16(sp)
    80001532:	e44e                	sd	s3,8(sp)
    80001534:	e052                	sd	s4,0(sp)
    80001536:	1800                	addi	s0,sp,48
    80001538:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000153a:	84aa                	mv	s1,a0
    8000153c:	6905                	lui	s2,0x1
    8000153e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001540:	4985                	li	s3,1
    80001542:	a821                	j	8000155a <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001544:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001546:	0532                	slli	a0,a0,0xc
    80001548:	00000097          	auipc	ra,0x0
    8000154c:	fe0080e7          	jalr	-32(ra) # 80001528 <freewalk>
      pagetable[i] = 0;
    80001550:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001554:	04a1                	addi	s1,s1,8
    80001556:	03248163          	beq	s1,s2,80001578 <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000155a:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000155c:	00f57793          	andi	a5,a0,15
    80001560:	ff3782e3          	beq	a5,s3,80001544 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001564:	8905                	andi	a0,a0,1
    80001566:	d57d                	beqz	a0,80001554 <freewalk+0x2c>
      panic("freewalk: leaf");
    80001568:	00007517          	auipc	a0,0x7
    8000156c:	bf050513          	addi	a0,a0,-1040 # 80008158 <digits+0x128>
    80001570:	fffff097          	auipc	ra,0xfffff
    80001574:	fd2080e7          	jalr	-46(ra) # 80000542 <panic>
    }
  }
  kfree((void*)pagetable);
    80001578:	8552                	mv	a0,s4
    8000157a:	fffff097          	auipc	ra,0xfffff
    8000157e:	498080e7          	jalr	1176(ra) # 80000a12 <kfree>
}
    80001582:	70a2                	ld	ra,40(sp)
    80001584:	7402                	ld	s0,32(sp)
    80001586:	64e2                	ld	s1,24(sp)
    80001588:	6942                	ld	s2,16(sp)
    8000158a:	69a2                	ld	s3,8(sp)
    8000158c:	6a02                	ld	s4,0(sp)
    8000158e:	6145                	addi	sp,sp,48
    80001590:	8082                	ret

0000000080001592 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001592:	1101                	addi	sp,sp,-32
    80001594:	ec06                	sd	ra,24(sp)
    80001596:	e822                	sd	s0,16(sp)
    80001598:	e426                	sd	s1,8(sp)
    8000159a:	1000                	addi	s0,sp,32
    8000159c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000159e:	e999                	bnez	a1,800015b4 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015a0:	8526                	mv	a0,s1
    800015a2:	00000097          	auipc	ra,0x0
    800015a6:	f86080e7          	jalr	-122(ra) # 80001528 <freewalk>
}
    800015aa:	60e2                	ld	ra,24(sp)
    800015ac:	6442                	ld	s0,16(sp)
    800015ae:	64a2                	ld	s1,8(sp)
    800015b0:	6105                	addi	sp,sp,32
    800015b2:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	167d                	addi	a2,a2,-1
    800015b8:	962e                	add	a2,a2,a1
    800015ba:	4685                	li	a3,1
    800015bc:	8231                	srli	a2,a2,0xc
    800015be:	4581                	li	a1,0
    800015c0:	00000097          	auipc	ra,0x0
    800015c4:	d12080e7          	jalr	-750(ra) # 800012d2 <uvmunmap>
    800015c8:	bfe1                	j	800015a0 <uvmfree+0xe>

00000000800015ca <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015ca:	c679                	beqz	a2,80001698 <uvmcopy+0xce>
{
    800015cc:	715d                	addi	sp,sp,-80
    800015ce:	e486                	sd	ra,72(sp)
    800015d0:	e0a2                	sd	s0,64(sp)
    800015d2:	fc26                	sd	s1,56(sp)
    800015d4:	f84a                	sd	s2,48(sp)
    800015d6:	f44e                	sd	s3,40(sp)
    800015d8:	f052                	sd	s4,32(sp)
    800015da:	ec56                	sd	s5,24(sp)
    800015dc:	e85a                	sd	s6,16(sp)
    800015de:	e45e                	sd	s7,8(sp)
    800015e0:	0880                	addi	s0,sp,80
    800015e2:	8b2a                	mv	s6,a0
    800015e4:	8aae                	mv	s5,a1
    800015e6:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015e8:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015ea:	4601                	li	a2,0
    800015ec:	85ce                	mv	a1,s3
    800015ee:	855a                	mv	a0,s6
    800015f0:	00000097          	auipc	ra,0x0
    800015f4:	9fa080e7          	jalr	-1542(ra) # 80000fea <walk>
    800015f8:	c531                	beqz	a0,80001644 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015fa:	6118                	ld	a4,0(a0)
    800015fc:	00177793          	andi	a5,a4,1
    80001600:	cbb1                	beqz	a5,80001654 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001602:	00a75593          	srli	a1,a4,0xa
    80001606:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000160a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000160e:	fffff097          	auipc	ra,0xfffff
    80001612:	500080e7          	jalr	1280(ra) # 80000b0e <kalloc>
    80001616:	892a                	mv	s2,a0
    80001618:	c939                	beqz	a0,8000166e <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000161a:	6605                	lui	a2,0x1
    8000161c:	85de                	mv	a1,s7
    8000161e:	fffff097          	auipc	ra,0xfffff
    80001622:	738080e7          	jalr	1848(ra) # 80000d56 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001626:	8726                	mv	a4,s1
    80001628:	86ca                	mv	a3,s2
    8000162a:	6605                	lui	a2,0x1
    8000162c:	85ce                	mv	a1,s3
    8000162e:	8556                	mv	a0,s5
    80001630:	00000097          	auipc	ra,0x0
    80001634:	b0a080e7          	jalr	-1270(ra) # 8000113a <mappages>
    80001638:	e515                	bnez	a0,80001664 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000163a:	6785                	lui	a5,0x1
    8000163c:	99be                	add	s3,s3,a5
    8000163e:	fb49e6e3          	bltu	s3,s4,800015ea <uvmcopy+0x20>
    80001642:	a081                	j	80001682 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001644:	00007517          	auipc	a0,0x7
    80001648:	b2450513          	addi	a0,a0,-1244 # 80008168 <digits+0x138>
    8000164c:	fffff097          	auipc	ra,0xfffff
    80001650:	ef6080e7          	jalr	-266(ra) # 80000542 <panic>
      panic("uvmcopy: page not present");
    80001654:	00007517          	auipc	a0,0x7
    80001658:	b3450513          	addi	a0,a0,-1228 # 80008188 <digits+0x158>
    8000165c:	fffff097          	auipc	ra,0xfffff
    80001660:	ee6080e7          	jalr	-282(ra) # 80000542 <panic>
      kfree(mem);
    80001664:	854a                	mv	a0,s2
    80001666:	fffff097          	auipc	ra,0xfffff
    8000166a:	3ac080e7          	jalr	940(ra) # 80000a12 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000166e:	4685                	li	a3,1
    80001670:	00c9d613          	srli	a2,s3,0xc
    80001674:	4581                	li	a1,0
    80001676:	8556                	mv	a0,s5
    80001678:	00000097          	auipc	ra,0x0
    8000167c:	c5a080e7          	jalr	-934(ra) # 800012d2 <uvmunmap>
  return -1;
    80001680:	557d                	li	a0,-1
}
    80001682:	60a6                	ld	ra,72(sp)
    80001684:	6406                	ld	s0,64(sp)
    80001686:	74e2                	ld	s1,56(sp)
    80001688:	7942                	ld	s2,48(sp)
    8000168a:	79a2                	ld	s3,40(sp)
    8000168c:	7a02                	ld	s4,32(sp)
    8000168e:	6ae2                	ld	s5,24(sp)
    80001690:	6b42                	ld	s6,16(sp)
    80001692:	6ba2                	ld	s7,8(sp)
    80001694:	6161                	addi	sp,sp,80
    80001696:	8082                	ret
  return 0;
    80001698:	4501                	li	a0,0
}
    8000169a:	8082                	ret

000000008000169c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000169c:	1141                	addi	sp,sp,-16
    8000169e:	e406                	sd	ra,8(sp)
    800016a0:	e022                	sd	s0,0(sp)
    800016a2:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016a4:	4601                	li	a2,0
    800016a6:	00000097          	auipc	ra,0x0
    800016aa:	944080e7          	jalr	-1724(ra) # 80000fea <walk>
  if(pte == 0)
    800016ae:	c901                	beqz	a0,800016be <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016b0:	611c                	ld	a5,0(a0)
    800016b2:	9bbd                	andi	a5,a5,-17
    800016b4:	e11c                	sd	a5,0(a0)
}
    800016b6:	60a2                	ld	ra,8(sp)
    800016b8:	6402                	ld	s0,0(sp)
    800016ba:	0141                	addi	sp,sp,16
    800016bc:	8082                	ret
    panic("uvmclear");
    800016be:	00007517          	auipc	a0,0x7
    800016c2:	aea50513          	addi	a0,a0,-1302 # 800081a8 <digits+0x178>
    800016c6:	fffff097          	auipc	ra,0xfffff
    800016ca:	e7c080e7          	jalr	-388(ra) # 80000542 <panic>

00000000800016ce <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016ce:	c6bd                	beqz	a3,8000173c <copyout+0x6e>
{
    800016d0:	715d                	addi	sp,sp,-80
    800016d2:	e486                	sd	ra,72(sp)
    800016d4:	e0a2                	sd	s0,64(sp)
    800016d6:	fc26                	sd	s1,56(sp)
    800016d8:	f84a                	sd	s2,48(sp)
    800016da:	f44e                	sd	s3,40(sp)
    800016dc:	f052                	sd	s4,32(sp)
    800016de:	ec56                	sd	s5,24(sp)
    800016e0:	e85a                	sd	s6,16(sp)
    800016e2:	e45e                	sd	s7,8(sp)
    800016e4:	e062                	sd	s8,0(sp)
    800016e6:	0880                	addi	s0,sp,80
    800016e8:	8b2a                	mv	s6,a0
    800016ea:	8c2e                	mv	s8,a1
    800016ec:	8a32                	mv	s4,a2
    800016ee:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016f0:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016f2:	6a85                	lui	s5,0x1
    800016f4:	a015                	j	80001718 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016f6:	9562                	add	a0,a0,s8
    800016f8:	0004861b          	sext.w	a2,s1
    800016fc:	85d2                	mv	a1,s4
    800016fe:	41250533          	sub	a0,a0,s2
    80001702:	fffff097          	auipc	ra,0xfffff
    80001706:	654080e7          	jalr	1620(ra) # 80000d56 <memmove>

    len -= n;
    8000170a:	409989b3          	sub	s3,s3,s1
    src += n;
    8000170e:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001710:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001714:	02098263          	beqz	s3,80001738 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001718:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000171c:	85ca                	mv	a1,s2
    8000171e:	855a                	mv	a0,s6
    80001720:	00000097          	auipc	ra,0x0
    80001724:	970080e7          	jalr	-1680(ra) # 80001090 <walkaddr>
    if(pa0 == 0)
    80001728:	cd01                	beqz	a0,80001740 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000172a:	418904b3          	sub	s1,s2,s8
    8000172e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001730:	fc99f3e3          	bgeu	s3,s1,800016f6 <copyout+0x28>
    80001734:	84ce                	mv	s1,s3
    80001736:	b7c1                	j	800016f6 <copyout+0x28>
  }
  return 0;
    80001738:	4501                	li	a0,0
    8000173a:	a021                	j	80001742 <copyout+0x74>
    8000173c:	4501                	li	a0,0
}
    8000173e:	8082                	ret
      return -1;
    80001740:	557d                	li	a0,-1
}
    80001742:	60a6                	ld	ra,72(sp)
    80001744:	6406                	ld	s0,64(sp)
    80001746:	74e2                	ld	s1,56(sp)
    80001748:	7942                	ld	s2,48(sp)
    8000174a:	79a2                	ld	s3,40(sp)
    8000174c:	7a02                	ld	s4,32(sp)
    8000174e:	6ae2                	ld	s5,24(sp)
    80001750:	6b42                	ld	s6,16(sp)
    80001752:	6ba2                	ld	s7,8(sp)
    80001754:	6c02                	ld	s8,0(sp)
    80001756:	6161                	addi	sp,sp,80
    80001758:	8082                	ret

000000008000175a <copyin>:
// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
    8000175a:	1141                	addi	sp,sp,-16
    8000175c:	e406                	sd	ra,8(sp)
    8000175e:	e022                	sd	s0,0(sp)
    80001760:	0800                	addi	s0,sp,16
  return copyin_new(pagetable, dst, srcva, len);
    80001762:	00005097          	auipc	ra,0x5
    80001766:	dce080e7          	jalr	-562(ra) # 80006530 <copyin_new>
}
    8000176a:	60a2                	ld	ra,8(sp)
    8000176c:	6402                	ld	s0,0(sp)
    8000176e:	0141                	addi	sp,sp,16
    80001770:	8082                	ret

0000000080001772 <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    80001772:	1141                	addi	sp,sp,-16
    80001774:	e406                	sd	ra,8(sp)
    80001776:	e022                	sd	s0,0(sp)
    80001778:	0800                	addi	s0,sp,16
  return copyinstr_new(pagetable, dst, srcva, max);
    8000177a:	00005097          	auipc	ra,0x5
    8000177e:	e1e080e7          	jalr	-482(ra) # 80006598 <copyinstr_new>
}
    80001782:	60a2                	ld	ra,8(sp)
    80001784:	6402                	ld	s0,0(sp)
    80001786:	0141                	addi	sp,sp,16
    80001788:	8082                	ret

000000008000178a <_vmprint>:
void _vmprint(pagetable_t pagetable, int level) {
    8000178a:	7159                	addi	sp,sp,-112
    8000178c:	f486                	sd	ra,104(sp)
    8000178e:	f0a2                	sd	s0,96(sp)
    80001790:	eca6                	sd	s1,88(sp)
    80001792:	e8ca                	sd	s2,80(sp)
    80001794:	e4ce                	sd	s3,72(sp)
    80001796:	e0d2                	sd	s4,64(sp)
    80001798:	fc56                	sd	s5,56(sp)
    8000179a:	f85a                	sd	s6,48(sp)
    8000179c:	f45e                	sd	s7,40(sp)
    8000179e:	f062                	sd	s8,32(sp)
    800017a0:	ec66                	sd	s9,24(sp)
    800017a2:	e86a                	sd	s10,16(sp)
    800017a4:	e46e                	sd	s11,8(sp)
    800017a6:	1880                	addi	s0,sp,112
    800017a8:	8aae                	mv	s5,a1
  for (int i = 0; i < 512; ++i) {
    800017aa:	8a2a                	mv	s4,a0
    800017ac:	4981                	li	s3,0
      for (int j = 0; j < level; ++j) {
        if (j == 0) printf("..");
        else printf(" ..");
      }
      uint64 child = PTE2PA(pte); // 通过pte映射下一级页表的物理地址
      printf("%d: pte %p pa %p\n", i, pte, child);
    800017ae:	00007c97          	auipc	s9,0x7
    800017b2:	a1ac8c93          	addi	s9,s9,-1510 # 800081c8 <digits+0x198>
      // 查看flag是否被设置，若被设置，则为最低一层
      // 只有在页表的最后一级，才可进行读、写、执行
      if ((pte & (PTE_R | PTE_W | PTE_X)) == 0)
        _vmprint((pagetable_t)child, level + 1);
    800017b6:	00158d9b          	addiw	s11,a1,1
      for (int j = 0; j < level; ++j) {
    800017ba:	4d01                	li	s10,0
        else printf(" ..");
    800017bc:	00007b17          	auipc	s6,0x7
    800017c0:	a04b0b13          	addi	s6,s6,-1532 # 800081c0 <digits+0x190>
        if (j == 0) printf("..");
    800017c4:	00007c17          	auipc	s8,0x7
    800017c8:	9f4c0c13          	addi	s8,s8,-1548 # 800081b8 <digits+0x188>
  for (int i = 0; i < 512; ++i) {
    800017cc:	20000b93          	li	s7,512
    800017d0:	a099                	j	80001816 <_vmprint+0x8c>
        else printf(" ..");
    800017d2:	855a                	mv	a0,s6
    800017d4:	fffff097          	auipc	ra,0xfffff
    800017d8:	db8080e7          	jalr	-584(ra) # 8000058c <printf>
      for (int j = 0; j < level; ++j) {
    800017dc:	2485                	addiw	s1,s1,1
    800017de:	009a8963          	beq	s5,s1,800017f0 <_vmprint+0x66>
        if (j == 0) printf("..");
    800017e2:	f8e5                	bnez	s1,800017d2 <_vmprint+0x48>
    800017e4:	8562                	mv	a0,s8
    800017e6:	fffff097          	auipc	ra,0xfffff
    800017ea:	da6080e7          	jalr	-602(ra) # 8000058c <printf>
    800017ee:	b7fd                	j	800017dc <_vmprint+0x52>
      uint64 child = PTE2PA(pte); // 通过pte映射下一级页表的物理地址
    800017f0:	00a95493          	srli	s1,s2,0xa
    800017f4:	04b2                	slli	s1,s1,0xc
      printf("%d: pte %p pa %p\n", i, pte, child);
    800017f6:	86a6                	mv	a3,s1
    800017f8:	864a                	mv	a2,s2
    800017fa:	85ce                	mv	a1,s3
    800017fc:	8566                	mv	a0,s9
    800017fe:	fffff097          	auipc	ra,0xfffff
    80001802:	d8e080e7          	jalr	-626(ra) # 8000058c <printf>
      if ((pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80001806:	00e97913          	andi	s2,s2,14
    8000180a:	00090f63          	beqz	s2,80001828 <_vmprint+0x9e>
  for (int i = 0; i < 512; ++i) {
    8000180e:	2985                	addiw	s3,s3,1
    80001810:	0a21                	addi	s4,s4,8
    80001812:	03798263          	beq	s3,s7,80001836 <_vmprint+0xac>
    pte_t pte = pagetable[i];
    80001816:	000a3903          	ld	s2,0(s4) # fffffffffffff000 <end+0xffffffff7ffd7fe0>
    if ((pte & PTE_V)) {
    8000181a:	00197793          	andi	a5,s2,1
    8000181e:	dbe5                	beqz	a5,8000180e <_vmprint+0x84>
      for (int j = 0; j < level; ++j) {
    80001820:	fd5058e3          	blez	s5,800017f0 <_vmprint+0x66>
    80001824:	84ea                	mv	s1,s10
    80001826:	bf75                	j	800017e2 <_vmprint+0x58>
        _vmprint((pagetable_t)child, level + 1);
    80001828:	85ee                	mv	a1,s11
    8000182a:	8526                	mv	a0,s1
    8000182c:	00000097          	auipc	ra,0x0
    80001830:	f5e080e7          	jalr	-162(ra) # 8000178a <_vmprint>
    80001834:	bfe9                	j	8000180e <_vmprint+0x84>
    }
  }
}
    80001836:	70a6                	ld	ra,104(sp)
    80001838:	7406                	ld	s0,96(sp)
    8000183a:	64e6                	ld	s1,88(sp)
    8000183c:	6946                	ld	s2,80(sp)
    8000183e:	69a6                	ld	s3,72(sp)
    80001840:	6a06                	ld	s4,64(sp)
    80001842:	7ae2                	ld	s5,56(sp)
    80001844:	7b42                	ld	s6,48(sp)
    80001846:	7ba2                	ld	s7,40(sp)
    80001848:	7c02                	ld	s8,32(sp)
    8000184a:	6ce2                	ld	s9,24(sp)
    8000184c:	6d42                	ld	s10,16(sp)
    8000184e:	6da2                	ld	s11,8(sp)
    80001850:	6165                	addi	sp,sp,112
    80001852:	8082                	ret

0000000080001854 <vmprint>:

void vmprint(pagetable_t pagetable) {
    80001854:	1101                	addi	sp,sp,-32
    80001856:	ec06                	sd	ra,24(sp)
    80001858:	e822                	sd	s0,16(sp)
    8000185a:	e426                	sd	s1,8(sp)
    8000185c:	1000                	addi	s0,sp,32
    8000185e:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    80001860:	85aa                	mv	a1,a0
    80001862:	00007517          	auipc	a0,0x7
    80001866:	97e50513          	addi	a0,a0,-1666 # 800081e0 <digits+0x1b0>
    8000186a:	fffff097          	auipc	ra,0xfffff
    8000186e:	d22080e7          	jalr	-734(ra) # 8000058c <printf>
  _vmprint(pagetable, 1);
    80001872:	4585                	li	a1,1
    80001874:	8526                	mv	a0,s1
    80001876:	00000097          	auipc	ra,0x0
    8000187a:	f14080e7          	jalr	-236(ra) # 8000178a <_vmprint>
}
    8000187e:	60e2                	ld	ra,24(sp)
    80001880:	6442                	ld	s0,16(sp)
    80001882:	64a2                	ld	s1,8(sp)
    80001884:	6105                	addi	sp,sp,32
    80001886:	8082                	ret

0000000080001888 <ukvmmap>:
void
ukvmmap(pagetable_t pagetable, uint64 va, uint64 pa, uint64 sz, int perm)
{
    80001888:	1141                	addi	sp,sp,-16
    8000188a:	e406                	sd	ra,8(sp)
    8000188c:	e022                	sd	s0,0(sp)
    8000188e:	0800                	addi	s0,sp,16
    80001890:	87b6                	mv	a5,a3
  if(mappages(pagetable, va, sz, pa, perm) != 0)
    80001892:	86b2                	mv	a3,a2
    80001894:	863e                	mv	a2,a5
    80001896:	00000097          	auipc	ra,0x0
    8000189a:	8a4080e7          	jalr	-1884(ra) # 8000113a <mappages>
    8000189e:	e509                	bnez	a0,800018a8 <ukvmmap+0x20>
    panic("ukvmmap");
}
    800018a0:	60a2                	ld	ra,8(sp)
    800018a2:	6402                	ld	s0,0(sp)
    800018a4:	0141                	addi	sp,sp,16
    800018a6:	8082                	ret
    panic("ukvmmap");
    800018a8:	00007517          	auipc	a0,0x7
    800018ac:	94850513          	addi	a0,a0,-1720 # 800081f0 <digits+0x1c0>
    800018b0:	fffff097          	auipc	ra,0xfffff
    800018b4:	c92080e7          	jalr	-878(ra) # 80000542 <panic>

00000000800018b8 <proc_kvminit>:

pagetable_t
proc_kvminit() {
    800018b8:	1101                	addi	sp,sp,-32
    800018ba:	ec06                	sd	ra,24(sp)
    800018bc:	e822                	sd	s0,16(sp)
    800018be:	e426                	sd	s1,8(sp)
    800018c0:	e04a                	sd	s2,0(sp)
    800018c2:	1000                	addi	s0,sp,32
  // 申请一个页表空间
  pagetable_t proc_kernel_pagetable = (pagetable_t) kalloc();
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	24a080e7          	jalr	586(ra) # 80000b0e <kalloc>
    800018cc:	84aa                	mv	s1,a0
  if (proc_kernel_pagetable == 0)
    800018ce:	c54d                	beqz	a0,80001978 <proc_kvminit+0xc0>
    return 0;
  memset(proc_kernel_pagetable, 0, PGSIZE);
    800018d0:	6605                	lui	a2,0x1
    800018d2:	4581                	li	a1,0
    800018d4:	fffff097          	auipc	ra,0xfffff
    800018d8:	426080e7          	jalr	1062(ra) # 80000cfa <memset>
  // 与vminint内容上保持一致
  ukvmmap(proc_kernel_pagetable, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800018dc:	4719                	li	a4,6
    800018de:	6685                	lui	a3,0x1
    800018e0:	10000637          	lui	a2,0x10000
    800018e4:	100005b7          	lui	a1,0x10000
    800018e8:	8526                	mv	a0,s1
    800018ea:	00000097          	auipc	ra,0x0
    800018ee:	f9e080e7          	jalr	-98(ra) # 80001888 <ukvmmap>
  ukvmmap(proc_kernel_pagetable, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800018f2:	4719                	li	a4,6
    800018f4:	6685                	lui	a3,0x1
    800018f6:	10001637          	lui	a2,0x10001
    800018fa:	100015b7          	lui	a1,0x10001
    800018fe:	8526                	mv	a0,s1
    80001900:	00000097          	auipc	ra,0x0
    80001904:	f88080e7          	jalr	-120(ra) # 80001888 <ukvmmap>
  // 用户进程内核页表无需在映射CLINT，将空间留出映射用户页表
  // ukvmmap(proc_kernel_pagetable, CLINT, CLINT, 0x10000, PTE_R | PTE_W);
  ukvmmap(proc_kernel_pagetable, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001908:	4719                	li	a4,6
    8000190a:	004006b7          	lui	a3,0x400
    8000190e:	0c000637          	lui	a2,0xc000
    80001912:	0c0005b7          	lui	a1,0xc000
    80001916:	8526                	mv	a0,s1
    80001918:	00000097          	auipc	ra,0x0
    8000191c:	f70080e7          	jalr	-144(ra) # 80001888 <ukvmmap>
  ukvmmap(proc_kernel_pagetable, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001920:	00006917          	auipc	s2,0x6
    80001924:	6e090913          	addi	s2,s2,1760 # 80008000 <etext>
    80001928:	4729                	li	a4,10
    8000192a:	80006697          	auipc	a3,0x80006
    8000192e:	6d668693          	addi	a3,a3,1750 # 8000 <_entry-0x7fff8000>
    80001932:	4605                	li	a2,1
    80001934:	067e                	slli	a2,a2,0x1f
    80001936:	85b2                	mv	a1,a2
    80001938:	8526                	mv	a0,s1
    8000193a:	00000097          	auipc	ra,0x0
    8000193e:	f4e080e7          	jalr	-178(ra) # 80001888 <ukvmmap>
  ukvmmap(proc_kernel_pagetable, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001942:	4719                	li	a4,6
    80001944:	46c5                	li	a3,17
    80001946:	06ee                	slli	a3,a3,0x1b
    80001948:	412686b3          	sub	a3,a3,s2
    8000194c:	864a                	mv	a2,s2
    8000194e:	85ca                	mv	a1,s2
    80001950:	8526                	mv	a0,s1
    80001952:	00000097          	auipc	ra,0x0
    80001956:	f36080e7          	jalr	-202(ra) # 80001888 <ukvmmap>
  ukvmmap(proc_kernel_pagetable, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000195a:	4729                	li	a4,10
    8000195c:	6685                	lui	a3,0x1
    8000195e:	00005617          	auipc	a2,0x5
    80001962:	6a260613          	addi	a2,a2,1698 # 80007000 <_trampoline>
    80001966:	040005b7          	lui	a1,0x4000
    8000196a:	15fd                	addi	a1,a1,-1
    8000196c:	05b2                	slli	a1,a1,0xc
    8000196e:	8526                	mv	a0,s1
    80001970:	00000097          	auipc	ra,0x0
    80001974:	f18080e7          	jalr	-232(ra) # 80001888 <ukvmmap>
  return proc_kernel_pagetable;
}
    80001978:	8526                	mv	a0,s1
    8000197a:	60e2                	ld	ra,24(sp)
    8000197c:	6442                	ld	s0,16(sp)
    8000197e:	64a2                	ld	s1,8(sp)
    80001980:	6902                	ld	s2,0(sp)
    80001982:	6105                	addi	sp,sp,32
    80001984:	8082                	ret

0000000080001986 <kvmcopymappings>:
// 将 src 页表的一部分页映射关系拷贝到 dst 页表中。
// 只拷贝页表项，不拷贝实际的物理页内存。
// 成功返回0，失败返回 -1
int
kvmcopymappings(pagetable_t src, pagetable_t dst, uint64 start, uint64 sz)
{
    80001986:	7179                	addi	sp,sp,-48
    80001988:	f406                	sd	ra,40(sp)
    8000198a:	f022                	sd	s0,32(sp)
    8000198c:	ec26                	sd	s1,24(sp)
    8000198e:	e84a                	sd	s2,16(sp)
    80001990:	e44e                	sd	s3,8(sp)
    80001992:	e052                	sd	s4,0(sp)
    80001994:	1800                	addi	s0,sp,48
    80001996:	8a2a                	mv	s4,a0
    80001998:	89ae                	mv	s3,a1
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  // PGROUNDUP: 对齐页边界，防止 remap
  for(i = PGROUNDUP(start); i < start + sz; i += PGSIZE){
    8000199a:	6485                	lui	s1,0x1
    8000199c:	14fd                	addi	s1,s1,-1
    8000199e:	94b2                	add	s1,s1,a2
    800019a0:	77fd                	lui	a5,0xfffff
    800019a2:	8cfd                	and	s1,s1,a5
    800019a4:	00d60933          	add	s2,a2,a3
    800019a8:	0924f263          	bgeu	s1,s2,80001a2c <kvmcopymappings+0xa6>
    if((pte = walk(src, i, 0)) == 0) // 找到虚拟地址的最后一级页表项
    800019ac:	4601                	li	a2,0
    800019ae:	85a6                	mv	a1,s1
    800019b0:	8552                	mv	a0,s4
    800019b2:	fffff097          	auipc	ra,0xfffff
    800019b6:	638080e7          	jalr	1592(ra) # 80000fea <walk>
    800019ba:	c51d                	beqz	a0,800019e8 <kvmcopymappings+0x62>
      panic("kvmcopymappings: pte should exist");
    if((*pte & PTE_V) == 0)	// 判断页表项是否有效
    800019bc:	6118                	ld	a4,0(a0)
    800019be:	00177793          	andi	a5,a4,1
    800019c2:	cb9d                	beqz	a5,800019f8 <kvmcopymappings+0x72>
      panic("kvmcopymappings: page not present");
    pa = PTE2PA(*pte);	 // 将页表项转换为物理地址页起始位置
    800019c4:	00a75693          	srli	a3,a4,0xa
    // `& ~PTE_U` 表示将该页的权限设置为非用户页
    // 必须设置该权限，RISC-V 中内核是无法直接访问用户页的。
    flags = PTE_FLAGS(*pte) & ~PTE_U;
    // 将pa这一页的PTEs映射到dst上同样的虚拟地址
    if(mappages(dst, i, PGSIZE, pa, flags) != 0){
    800019c8:	3ef77713          	andi	a4,a4,1007
    800019cc:	06b2                	slli	a3,a3,0xc
    800019ce:	6605                	lui	a2,0x1
    800019d0:	85a6                	mv	a1,s1
    800019d2:	854e                	mv	a0,s3
    800019d4:	fffff097          	auipc	ra,0xfffff
    800019d8:	766080e7          	jalr	1894(ra) # 8000113a <mappages>
    800019dc:	e515                	bnez	a0,80001a08 <kvmcopymappings+0x82>
  for(i = PGROUNDUP(start); i < start + sz; i += PGSIZE){
    800019de:	6785                	lui	a5,0x1
    800019e0:	94be                	add	s1,s1,a5
    800019e2:	fd24e5e3          	bltu	s1,s2,800019ac <kvmcopymappings+0x26>
    800019e6:	a81d                	j	80001a1c <kvmcopymappings+0x96>
      panic("kvmcopymappings: pte should exist");
    800019e8:	00007517          	auipc	a0,0x7
    800019ec:	81050513          	addi	a0,a0,-2032 # 800081f8 <digits+0x1c8>
    800019f0:	fffff097          	auipc	ra,0xfffff
    800019f4:	b52080e7          	jalr	-1198(ra) # 80000542 <panic>
      panic("kvmcopymappings: page not present");
    800019f8:	00007517          	auipc	a0,0x7
    800019fc:	82850513          	addi	a0,a0,-2008 # 80008220 <digits+0x1f0>
    80001a00:	fffff097          	auipc	ra,0xfffff
    80001a04:	b42080e7          	jalr	-1214(ra) # 80000542 <panic>
      // 清除已经映射的部分，但不释放内存
      uvmunmap(dst, 0, i / PGSIZE, 0);
    80001a08:	4681                	li	a3,0
    80001a0a:	00c4d613          	srli	a2,s1,0xc
    80001a0e:	4581                	li	a1,0
    80001a10:	854e                	mv	a0,s3
    80001a12:	00000097          	auipc	ra,0x0
    80001a16:	8c0080e7          	jalr	-1856(ra) # 800012d2 <uvmunmap>
      return -1;
    80001a1a:	557d                	li	a0,-1
    }
  }
  return 0;
}
    80001a1c:	70a2                	ld	ra,40(sp)
    80001a1e:	7402                	ld	s0,32(sp)
    80001a20:	64e2                	ld	s1,24(sp)
    80001a22:	6942                	ld	s2,16(sp)
    80001a24:	69a2                	ld	s3,8(sp)
    80001a26:	6a02                	ld	s4,0(sp)
    80001a28:	6145                	addi	sp,sp,48
    80001a2a:	8082                	ret
  return 0;
    80001a2c:	4501                	li	a0,0
    80001a2e:	b7fd                	j	80001a1c <kvmcopymappings+0x96>

0000000080001a30 <kvmdealloc>:

// 与 uvmdealloc 功能类似，将程序内存从 oldsz 缩减到 newsz。但区别在于不释放实际内存
// 用于内核页表内程序内存映射与用户页表程序内存映射之间的同步
uint64
kvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001a30:	1101                	addi	sp,sp,-32
    80001a32:	ec06                	sd	ra,24(sp)
    80001a34:	e822                	sd	s0,16(sp)
    80001a36:	e426                	sd	s1,8(sp)
    80001a38:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001a3a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001a3c:	00b67d63          	bgeu	a2,a1,80001a56 <kvmdealloc+0x26>
    80001a40:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001a42:	6785                	lui	a5,0x1
    80001a44:	17fd                	addi	a5,a5,-1
    80001a46:	00f60733          	add	a4,a2,a5
    80001a4a:	767d                	lui	a2,0xfffff
    80001a4c:	8f71                	and	a4,a4,a2
    80001a4e:	97ae                	add	a5,a5,a1
    80001a50:	8ff1                	and	a5,a5,a2
    80001a52:	00f76863          	bltu	a4,a5,80001a62 <kvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 0);
  }

  return newsz;
}
    80001a56:	8526                	mv	a0,s1
    80001a58:	60e2                	ld	ra,24(sp)
    80001a5a:	6442                	ld	s0,16(sp)
    80001a5c:	64a2                	ld	s1,8(sp)
    80001a5e:	6105                	addi	sp,sp,32
    80001a60:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001a62:	8f99                	sub	a5,a5,a4
    80001a64:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 0);
    80001a66:	4681                	li	a3,0
    80001a68:	0007861b          	sext.w	a2,a5
    80001a6c:	85ba                	mv	a1,a4
    80001a6e:	00000097          	auipc	ra,0x0
    80001a72:	864080e7          	jalr	-1948(ra) # 800012d2 <uvmunmap>
    80001a76:	b7c5                	j	80001a56 <kvmdealloc+0x26>

0000000080001a78 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001a78:	1101                	addi	sp,sp,-32
    80001a7a:	ec06                	sd	ra,24(sp)
    80001a7c:	e822                	sd	s0,16(sp)
    80001a7e:	e426                	sd	s1,8(sp)
    80001a80:	1000                	addi	s0,sp,32
    80001a82:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	100080e7          	jalr	256(ra) # 80000b84 <holding>
    80001a8c:	c909                	beqz	a0,80001a9e <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001a8e:	749c                	ld	a5,40(s1)
    80001a90:	00978f63          	beq	a5,s1,80001aae <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001a94:	60e2                	ld	ra,24(sp)
    80001a96:	6442                	ld	s0,16(sp)
    80001a98:	64a2                	ld	s1,8(sp)
    80001a9a:	6105                	addi	sp,sp,32
    80001a9c:	8082                	ret
    panic("wakeup1");
    80001a9e:	00006517          	auipc	a0,0x6
    80001aa2:	7aa50513          	addi	a0,a0,1962 # 80008248 <digits+0x218>
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	a9c080e7          	jalr	-1380(ra) # 80000542 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001aae:	4c98                	lw	a4,24(s1)
    80001ab0:	4785                	li	a5,1
    80001ab2:	fef711e3          	bne	a4,a5,80001a94 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001ab6:	4789                	li	a5,2
    80001ab8:	cc9c                	sw	a5,24(s1)
}
    80001aba:	bfe9                	j	80001a94 <wakeup1+0x1c>

0000000080001abc <procinit>:
{
    80001abc:	7179                	addi	sp,sp,-48
    80001abe:	f406                	sd	ra,40(sp)
    80001ac0:	f022                	sd	s0,32(sp)
    80001ac2:	ec26                	sd	s1,24(sp)
    80001ac4:	e84a                	sd	s2,16(sp)
    80001ac6:	e44e                	sd	s3,8(sp)
    80001ac8:	1800                	addi	s0,sp,48
  initlock(&pid_lock, "nextpid");
    80001aca:	00006597          	auipc	a1,0x6
    80001ace:	78658593          	addi	a1,a1,1926 # 80008250 <digits+0x220>
    80001ad2:	00010517          	auipc	a0,0x10
    80001ad6:	e7e50513          	addi	a0,a0,-386 # 80011950 <pid_lock>
    80001ada:	fffff097          	auipc	ra,0xfffff
    80001ade:	094080e7          	jalr	148(ra) # 80000b6e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ae2:	00010497          	auipc	s1,0x10
    80001ae6:	28648493          	addi	s1,s1,646 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001aea:	00006997          	auipc	s3,0x6
    80001aee:	76e98993          	addi	s3,s3,1902 # 80008258 <digits+0x228>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001af2:	00016917          	auipc	s2,0x16
    80001af6:	e7690913          	addi	s2,s2,-394 # 80017968 <tickslock>
      initlock(&p->lock, "proc");
    80001afa:	85ce                	mv	a1,s3
    80001afc:	8526                	mv	a0,s1
    80001afe:	fffff097          	auipc	ra,0xfffff
    80001b02:	070080e7          	jalr	112(ra) # 80000b6e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b06:	17048493          	addi	s1,s1,368
    80001b0a:	ff2498e3          	bne	s1,s2,80001afa <procinit+0x3e>
  kvminithart();
    80001b0e:	fffff097          	auipc	ra,0xfffff
    80001b12:	4b8080e7          	jalr	1208(ra) # 80000fc6 <kvminithart>
}
    80001b16:	70a2                	ld	ra,40(sp)
    80001b18:	7402                	ld	s0,32(sp)
    80001b1a:	64e2                	ld	s1,24(sp)
    80001b1c:	6942                	ld	s2,16(sp)
    80001b1e:	69a2                	ld	s3,8(sp)
    80001b20:	6145                	addi	sp,sp,48
    80001b22:	8082                	ret

0000000080001b24 <cpuid>:
{
    80001b24:	1141                	addi	sp,sp,-16
    80001b26:	e422                	sd	s0,8(sp)
    80001b28:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b2a:	8512                	mv	a0,tp
}
    80001b2c:	2501                	sext.w	a0,a0
    80001b2e:	6422                	ld	s0,8(sp)
    80001b30:	0141                	addi	sp,sp,16
    80001b32:	8082                	ret

0000000080001b34 <mycpu>:
mycpu(void) {
    80001b34:	1141                	addi	sp,sp,-16
    80001b36:	e422                	sd	s0,8(sp)
    80001b38:	0800                	addi	s0,sp,16
    80001b3a:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001b3c:	2781                	sext.w	a5,a5
    80001b3e:	079e                	slli	a5,a5,0x7
}
    80001b40:	00010517          	auipc	a0,0x10
    80001b44:	e2850513          	addi	a0,a0,-472 # 80011968 <cpus>
    80001b48:	953e                	add	a0,a0,a5
    80001b4a:	6422                	ld	s0,8(sp)
    80001b4c:	0141                	addi	sp,sp,16
    80001b4e:	8082                	ret

0000000080001b50 <myproc>:
myproc(void) {
    80001b50:	1101                	addi	sp,sp,-32
    80001b52:	ec06                	sd	ra,24(sp)
    80001b54:	e822                	sd	s0,16(sp)
    80001b56:	e426                	sd	s1,8(sp)
    80001b58:	1000                	addi	s0,sp,32
  push_off();
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	058080e7          	jalr	88(ra) # 80000bb2 <push_off>
    80001b62:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001b64:	2781                	sext.w	a5,a5
    80001b66:	079e                	slli	a5,a5,0x7
    80001b68:	00010717          	auipc	a4,0x10
    80001b6c:	de870713          	addi	a4,a4,-536 # 80011950 <pid_lock>
    80001b70:	97ba                	add	a5,a5,a4
    80001b72:	6f84                	ld	s1,24(a5)
  pop_off();
    80001b74:	fffff097          	auipc	ra,0xfffff
    80001b78:	0de080e7          	jalr	222(ra) # 80000c52 <pop_off>
}
    80001b7c:	8526                	mv	a0,s1
    80001b7e:	60e2                	ld	ra,24(sp)
    80001b80:	6442                	ld	s0,16(sp)
    80001b82:	64a2                	ld	s1,8(sp)
    80001b84:	6105                	addi	sp,sp,32
    80001b86:	8082                	ret

0000000080001b88 <forkret>:
{
    80001b88:	1141                	addi	sp,sp,-16
    80001b8a:	e406                	sd	ra,8(sp)
    80001b8c:	e022                	sd	s0,0(sp)
    80001b8e:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001b90:	00000097          	auipc	ra,0x0
    80001b94:	fc0080e7          	jalr	-64(ra) # 80001b50 <myproc>
    80001b98:	fffff097          	auipc	ra,0xfffff
    80001b9c:	11a080e7          	jalr	282(ra) # 80000cb2 <release>
  if (first) {
    80001ba0:	00007797          	auipc	a5,0x7
    80001ba4:	d407a783          	lw	a5,-704(a5) # 800088e0 <first.1>
    80001ba8:	eb89                	bnez	a5,80001bba <forkret+0x32>
  usertrapret();
    80001baa:	00001097          	auipc	ra,0x1
    80001bae:	dbe080e7          	jalr	-578(ra) # 80002968 <usertrapret>
}
    80001bb2:	60a2                	ld	ra,8(sp)
    80001bb4:	6402                	ld	s0,0(sp)
    80001bb6:	0141                	addi	sp,sp,16
    80001bb8:	8082                	ret
    first = 0;
    80001bba:	00007797          	auipc	a5,0x7
    80001bbe:	d207a323          	sw	zero,-730(a5) # 800088e0 <first.1>
    fsinit(ROOTDEV);
    80001bc2:	4505                	li	a0,1
    80001bc4:	00002097          	auipc	ra,0x2
    80001bc8:	ae4080e7          	jalr	-1308(ra) # 800036a8 <fsinit>
    80001bcc:	bff9                	j	80001baa <forkret+0x22>

0000000080001bce <allocpid>:
allocpid() {
    80001bce:	1101                	addi	sp,sp,-32
    80001bd0:	ec06                	sd	ra,24(sp)
    80001bd2:	e822                	sd	s0,16(sp)
    80001bd4:	e426                	sd	s1,8(sp)
    80001bd6:	e04a                	sd	s2,0(sp)
    80001bd8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bda:	00010917          	auipc	s2,0x10
    80001bde:	d7690913          	addi	s2,s2,-650 # 80011950 <pid_lock>
    80001be2:	854a                	mv	a0,s2
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	01a080e7          	jalr	26(ra) # 80000bfe <acquire>
  pid = nextpid;
    80001bec:	00007797          	auipc	a5,0x7
    80001bf0:	cf878793          	addi	a5,a5,-776 # 800088e4 <nextpid>
    80001bf4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bf6:	0014871b          	addiw	a4,s1,1
    80001bfa:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bfc:	854a                	mv	a0,s2
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	0b4080e7          	jalr	180(ra) # 80000cb2 <release>
}
    80001c06:	8526                	mv	a0,s1
    80001c08:	60e2                	ld	ra,24(sp)
    80001c0a:	6442                	ld	s0,16(sp)
    80001c0c:	64a2                	ld	s1,8(sp)
    80001c0e:	6902                	ld	s2,0(sp)
    80001c10:	6105                	addi	sp,sp,32
    80001c12:	8082                	ret

0000000080001c14 <proc_freepagetable>:
{
    80001c14:	1101                	addi	sp,sp,-32
    80001c16:	ec06                	sd	ra,24(sp)
    80001c18:	e822                	sd	s0,16(sp)
    80001c1a:	e426                	sd	s1,8(sp)
    80001c1c:	e04a                	sd	s2,0(sp)
    80001c1e:	1000                	addi	s0,sp,32
    80001c20:	84aa                	mv	s1,a0
    80001c22:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c24:	4681                	li	a3,0
    80001c26:	4605                	li	a2,1
    80001c28:	040005b7          	lui	a1,0x4000
    80001c2c:	15fd                	addi	a1,a1,-1
    80001c2e:	05b2                	slli	a1,a1,0xc
    80001c30:	fffff097          	auipc	ra,0xfffff
    80001c34:	6a2080e7          	jalr	1698(ra) # 800012d2 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c38:	4681                	li	a3,0
    80001c3a:	4605                	li	a2,1
    80001c3c:	020005b7          	lui	a1,0x2000
    80001c40:	15fd                	addi	a1,a1,-1
    80001c42:	05b6                	slli	a1,a1,0xd
    80001c44:	8526                	mv	a0,s1
    80001c46:	fffff097          	auipc	ra,0xfffff
    80001c4a:	68c080e7          	jalr	1676(ra) # 800012d2 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c4e:	85ca                	mv	a1,s2
    80001c50:	8526                	mv	a0,s1
    80001c52:	00000097          	auipc	ra,0x0
    80001c56:	940080e7          	jalr	-1728(ra) # 80001592 <uvmfree>
}
    80001c5a:	60e2                	ld	ra,24(sp)
    80001c5c:	6442                	ld	s0,16(sp)
    80001c5e:	64a2                	ld	s1,8(sp)
    80001c60:	6902                	ld	s2,0(sp)
    80001c62:	6105                	addi	sp,sp,32
    80001c64:	8082                	ret

0000000080001c66 <proc_freekernelpagetable>:
proc_freekernelpagetable(pagetable_t pagetable){
    80001c66:	7179                	addi	sp,sp,-48
    80001c68:	f406                	sd	ra,40(sp)
    80001c6a:	f022                	sd	s0,32(sp)
    80001c6c:	ec26                	sd	s1,24(sp)
    80001c6e:	e84a                	sd	s2,16(sp)
    80001c70:	e44e                	sd	s3,8(sp)
    80001c72:	1800                	addi	s0,sp,48
    80001c74:	89aa                	mv	s3,a0
  for (int i = 0; i < 512; ++i) {
    80001c76:	84aa                	mv	s1,a0
    80001c78:	6905                	lui	s2,0x1
    80001c7a:	992a                	add	s2,s2,a0
    80001c7c:	a021                	j	80001c84 <proc_freekernelpagetable+0x1e>
    80001c7e:	04a1                	addi	s1,s1,8
    80001c80:	03248263          	beq	s1,s2,80001ca4 <proc_freekernelpagetable+0x3e>
    pte_t pte = pagetable[i];
    80001c84:	6088                	ld	a0,0(s1)
    if ((pte & PTE_V)) {
    80001c86:	00157793          	andi	a5,a0,1
    80001c8a:	dbf5                	beqz	a5,80001c7e <proc_freekernelpagetable+0x18>
      pagetable[i] = 0;
    80001c8c:	0004b023          	sd	zero,0(s1)
      if ((pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001c90:	00e57793          	andi	a5,a0,14
    80001c94:	f7ed                	bnez	a5,80001c7e <proc_freekernelpagetable+0x18>
        uint64 child = PTE2PA(pte);
    80001c96:	8129                	srli	a0,a0,0xa
        proc_freekernelpagetable((pagetable_t)child);
    80001c98:	0532                	slli	a0,a0,0xc
    80001c9a:	00000097          	auipc	ra,0x0
    80001c9e:	fcc080e7          	jalr	-52(ra) # 80001c66 <proc_freekernelpagetable>
    80001ca2:	bff1                	j	80001c7e <proc_freekernelpagetable+0x18>
  kfree((void*)pagetable);
    80001ca4:	854e                	mv	a0,s3
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	d6c080e7          	jalr	-660(ra) # 80000a12 <kfree>
}
    80001cae:	70a2                	ld	ra,40(sp)
    80001cb0:	7402                	ld	s0,32(sp)
    80001cb2:	64e2                	ld	s1,24(sp)
    80001cb4:	6942                	ld	s2,16(sp)
    80001cb6:	69a2                	ld	s3,8(sp)
    80001cb8:	6145                	addi	sp,sp,48
    80001cba:	8082                	ret

0000000080001cbc <freeproc>:
{
    80001cbc:	1101                	addi	sp,sp,-32
    80001cbe:	ec06                	sd	ra,24(sp)
    80001cc0:	e822                	sd	s0,16(sp)
    80001cc2:	e426                	sd	s1,8(sp)
    80001cc4:	1000                	addi	s0,sp,32
    80001cc6:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001cc8:	6d28                	ld	a0,88(a0)
    80001cca:	c509                	beqz	a0,80001cd4 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	d46080e7          	jalr	-698(ra) # 80000a12 <kfree>
  p->trapframe = 0;
    80001cd4:	0404bc23          	sd	zero,88(s1)
  if (p->kstack) {
    80001cd8:	60ac                	ld	a1,64(s1)
    80001cda:	e9a1                	bnez	a1,80001d2a <freeproc+0x6e>
  if(p->pagetable)
    80001cdc:	68a8                	ld	a0,80(s1)
    80001cde:	c511                	beqz	a0,80001cea <freeproc+0x2e>
    proc_freepagetable(p->pagetable, p->sz);
    80001ce0:	64ac                	ld	a1,72(s1)
    80001ce2:	00000097          	auipc	ra,0x0
    80001ce6:	f32080e7          	jalr	-206(ra) # 80001c14 <proc_freepagetable>
  if (p->kernel_pagetable) 
    80001cea:	1684b503          	ld	a0,360(s1)
    80001cee:	c509                	beqz	a0,80001cf8 <freeproc+0x3c>
    proc_freekernelpagetable(p->kernel_pagetable);
    80001cf0:	00000097          	auipc	ra,0x0
    80001cf4:	f76080e7          	jalr	-138(ra) # 80001c66 <proc_freekernelpagetable>
  p->kernel_pagetable = 0;
    80001cf8:	1604b423          	sd	zero,360(s1)
  p->pagetable = 0;
    80001cfc:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d00:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d04:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001d08:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001d0c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d10:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001d14:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001d18:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001d1c:	0004ac23          	sw	zero,24(s1)
}
    80001d20:	60e2                	ld	ra,24(sp)
    80001d22:	6442                	ld	s0,16(sp)
    80001d24:	64a2                	ld	s1,8(sp)
    80001d26:	6105                	addi	sp,sp,32
    80001d28:	8082                	ret
    pte_t* pte = walk(p->kernel_pagetable, p->kstack, 0);
    80001d2a:	4601                	li	a2,0
    80001d2c:	1684b503          	ld	a0,360(s1)
    80001d30:	fffff097          	auipc	ra,0xfffff
    80001d34:	2ba080e7          	jalr	698(ra) # 80000fea <walk>
    if (pte == 0)
    80001d38:	c909                	beqz	a0,80001d4a <freeproc+0x8e>
    kfree((void*)PTE2PA(*pte));
    80001d3a:	6108                	ld	a0,0(a0)
    80001d3c:	8129                	srli	a0,a0,0xa
    80001d3e:	0532                	slli	a0,a0,0xc
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	cd2080e7          	jalr	-814(ra) # 80000a12 <kfree>
    80001d48:	bf51                	j	80001cdc <freeproc+0x20>
      panic("freeproc : kstack");
    80001d4a:	00006517          	auipc	a0,0x6
    80001d4e:	51650513          	addi	a0,a0,1302 # 80008260 <digits+0x230>
    80001d52:	ffffe097          	auipc	ra,0xffffe
    80001d56:	7f0080e7          	jalr	2032(ra) # 80000542 <panic>

0000000080001d5a <proc_pagetable>:
{
    80001d5a:	1101                	addi	sp,sp,-32
    80001d5c:	ec06                	sd	ra,24(sp)
    80001d5e:	e822                	sd	s0,16(sp)
    80001d60:	e426                	sd	s1,8(sp)
    80001d62:	e04a                	sd	s2,0(sp)
    80001d64:	1000                	addi	s0,sp,32
    80001d66:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	62e080e7          	jalr	1582(ra) # 80001396 <uvmcreate>
    80001d70:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001d72:	c121                	beqz	a0,80001db2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d74:	4729                	li	a4,10
    80001d76:	00005697          	auipc	a3,0x5
    80001d7a:	28a68693          	addi	a3,a3,650 # 80007000 <_trampoline>
    80001d7e:	6605                	lui	a2,0x1
    80001d80:	040005b7          	lui	a1,0x4000
    80001d84:	15fd                	addi	a1,a1,-1
    80001d86:	05b2                	slli	a1,a1,0xc
    80001d88:	fffff097          	auipc	ra,0xfffff
    80001d8c:	3b2080e7          	jalr	946(ra) # 8000113a <mappages>
    80001d90:	02054863          	bltz	a0,80001dc0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d94:	4719                	li	a4,6
    80001d96:	05893683          	ld	a3,88(s2) # 1058 <_entry-0x7fffefa8>
    80001d9a:	6605                	lui	a2,0x1
    80001d9c:	020005b7          	lui	a1,0x2000
    80001da0:	15fd                	addi	a1,a1,-1
    80001da2:	05b6                	slli	a1,a1,0xd
    80001da4:	8526                	mv	a0,s1
    80001da6:	fffff097          	auipc	ra,0xfffff
    80001daa:	394080e7          	jalr	916(ra) # 8000113a <mappages>
    80001dae:	02054163          	bltz	a0,80001dd0 <proc_pagetable+0x76>
}
    80001db2:	8526                	mv	a0,s1
    80001db4:	60e2                	ld	ra,24(sp)
    80001db6:	6442                	ld	s0,16(sp)
    80001db8:	64a2                	ld	s1,8(sp)
    80001dba:	6902                	ld	s2,0(sp)
    80001dbc:	6105                	addi	sp,sp,32
    80001dbe:	8082                	ret
    uvmfree(pagetable, 0);
    80001dc0:	4581                	li	a1,0
    80001dc2:	8526                	mv	a0,s1
    80001dc4:	fffff097          	auipc	ra,0xfffff
    80001dc8:	7ce080e7          	jalr	1998(ra) # 80001592 <uvmfree>
    return 0;
    80001dcc:	4481                	li	s1,0
    80001dce:	b7d5                	j	80001db2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dd0:	4681                	li	a3,0
    80001dd2:	4605                	li	a2,1
    80001dd4:	040005b7          	lui	a1,0x4000
    80001dd8:	15fd                	addi	a1,a1,-1
    80001dda:	05b2                	slli	a1,a1,0xc
    80001ddc:	8526                	mv	a0,s1
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	4f4080e7          	jalr	1268(ra) # 800012d2 <uvmunmap>
    uvmfree(pagetable, 0);
    80001de6:	4581                	li	a1,0
    80001de8:	8526                	mv	a0,s1
    80001dea:	fffff097          	auipc	ra,0xfffff
    80001dee:	7a8080e7          	jalr	1960(ra) # 80001592 <uvmfree>
    return 0;
    80001df2:	4481                	li	s1,0
    80001df4:	bf7d                	j	80001db2 <proc_pagetable+0x58>

0000000080001df6 <allocproc>:
{
    80001df6:	1101                	addi	sp,sp,-32
    80001df8:	ec06                	sd	ra,24(sp)
    80001dfa:	e822                	sd	s0,16(sp)
    80001dfc:	e426                	sd	s1,8(sp)
    80001dfe:	e04a                	sd	s2,0(sp)
    80001e00:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e02:	00010497          	auipc	s1,0x10
    80001e06:	f6648493          	addi	s1,s1,-154 # 80011d68 <proc>
    80001e0a:	00016917          	auipc	s2,0x16
    80001e0e:	b5e90913          	addi	s2,s2,-1186 # 80017968 <tickslock>
    acquire(&p->lock);
    80001e12:	8526                	mv	a0,s1
    80001e14:	fffff097          	auipc	ra,0xfffff
    80001e18:	dea080e7          	jalr	-534(ra) # 80000bfe <acquire>
    if(p->state == UNUSED) {
    80001e1c:	4c9c                	lw	a5,24(s1)
    80001e1e:	cf81                	beqz	a5,80001e36 <allocproc+0x40>
      release(&p->lock);
    80001e20:	8526                	mv	a0,s1
    80001e22:	fffff097          	auipc	ra,0xfffff
    80001e26:	e90080e7          	jalr	-368(ra) # 80000cb2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e2a:	17048493          	addi	s1,s1,368
    80001e2e:	ff2492e3          	bne	s1,s2,80001e12 <allocproc+0x1c>
  return 0;
    80001e32:	4481                	li	s1,0
    80001e34:	a069                	j	80001ebe <allocproc+0xc8>
  p->pid = allocpid();
    80001e36:	00000097          	auipc	ra,0x0
    80001e3a:	d98080e7          	jalr	-616(ra) # 80001bce <allocpid>
    80001e3e:	dc88                	sw	a0,56(s1)
p->kernel_pagetable = proc_kvminit();
    80001e40:	00000097          	auipc	ra,0x0
    80001e44:	a78080e7          	jalr	-1416(ra) # 800018b8 <proc_kvminit>
    80001e48:	892a                	mv	s2,a0
    80001e4a:	16a4b423          	sd	a0,360(s1)
if (p->kernel_pagetable == 0) {
    80001e4e:	cd3d                	beqz	a0,80001ecc <allocproc+0xd6>
char *pa = kalloc();
    80001e50:	fffff097          	auipc	ra,0xfffff
    80001e54:	cbe080e7          	jalr	-834(ra) # 80000b0e <kalloc>
    80001e58:	862a                	mv	a2,a0
if (pa == 0)
    80001e5a:	c549                	beqz	a0,80001ee4 <allocproc+0xee>
ukvmmap(p->kernel_pagetable, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001e5c:	4719                	li	a4,6
    80001e5e:	6685                	lui	a3,0x1
    80001e60:	04000937          	lui	s2,0x4000
    80001e64:	1975                	addi	s2,s2,-3
    80001e66:	00c91593          	slli	a1,s2,0xc
    80001e6a:	1684b503          	ld	a0,360(s1)
    80001e6e:	00000097          	auipc	ra,0x0
    80001e72:	a1a080e7          	jalr	-1510(ra) # 80001888 <ukvmmap>
p->kstack = va;
    80001e76:	0932                	slli	s2,s2,0xc
    80001e78:	0524b023          	sd	s2,64(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	c92080e7          	jalr	-878(ra) # 80000b0e <kalloc>
    80001e84:	892a                	mv	s2,a0
    80001e86:	eca8                	sd	a0,88(s1)
    80001e88:	c535                	beqz	a0,80001ef4 <allocproc+0xfe>
  p->pagetable = proc_pagetable(p);
    80001e8a:	8526                	mv	a0,s1
    80001e8c:	00000097          	auipc	ra,0x0
    80001e90:	ece080e7          	jalr	-306(ra) # 80001d5a <proc_pagetable>
    80001e94:	892a                	mv	s2,a0
    80001e96:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001e98:	c52d                	beqz	a0,80001f02 <allocproc+0x10c>
  memset(&p->context, 0, sizeof(p->context));
    80001e9a:	07000613          	li	a2,112
    80001e9e:	4581                	li	a1,0
    80001ea0:	06048513          	addi	a0,s1,96
    80001ea4:	fffff097          	auipc	ra,0xfffff
    80001ea8:	e56080e7          	jalr	-426(ra) # 80000cfa <memset>
  p->context.ra = (uint64)forkret;
    80001eac:	00000797          	auipc	a5,0x0
    80001eb0:	cdc78793          	addi	a5,a5,-804 # 80001b88 <forkret>
    80001eb4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001eb6:	60bc                	ld	a5,64(s1)
    80001eb8:	6705                	lui	a4,0x1
    80001eba:	97ba                	add	a5,a5,a4
    80001ebc:	f4bc                	sd	a5,104(s1)
}
    80001ebe:	8526                	mv	a0,s1
    80001ec0:	60e2                	ld	ra,24(sp)
    80001ec2:	6442                	ld	s0,16(sp)
    80001ec4:	64a2                	ld	s1,8(sp)
    80001ec6:	6902                	ld	s2,0(sp)
    80001ec8:	6105                	addi	sp,sp,32
    80001eca:	8082                	ret
  freeproc(p);
    80001ecc:	8526                	mv	a0,s1
    80001ece:	00000097          	auipc	ra,0x0
    80001ed2:	dee080e7          	jalr	-530(ra) # 80001cbc <freeproc>
  release(&p->lock);
    80001ed6:	8526                	mv	a0,s1
    80001ed8:	fffff097          	auipc	ra,0xfffff
    80001edc:	dda080e7          	jalr	-550(ra) # 80000cb2 <release>
  return 0;
    80001ee0:	84ca                	mv	s1,s2
    80001ee2:	bff1                	j	80001ebe <allocproc+0xc8>
  panic("kalloc");
    80001ee4:	00006517          	auipc	a0,0x6
    80001ee8:	39450513          	addi	a0,a0,916 # 80008278 <digits+0x248>
    80001eec:	ffffe097          	auipc	ra,0xffffe
    80001ef0:	656080e7          	jalr	1622(ra) # 80000542 <panic>
    release(&p->lock);
    80001ef4:	8526                	mv	a0,s1
    80001ef6:	fffff097          	auipc	ra,0xfffff
    80001efa:	dbc080e7          	jalr	-580(ra) # 80000cb2 <release>
    return 0;
    80001efe:	84ca                	mv	s1,s2
    80001f00:	bf7d                	j	80001ebe <allocproc+0xc8>
    freeproc(p);
    80001f02:	8526                	mv	a0,s1
    80001f04:	00000097          	auipc	ra,0x0
    80001f08:	db8080e7          	jalr	-584(ra) # 80001cbc <freeproc>
    release(&p->lock);
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	da4080e7          	jalr	-604(ra) # 80000cb2 <release>
    return 0;
    80001f16:	84ca                	mv	s1,s2
    80001f18:	b75d                	j	80001ebe <allocproc+0xc8>

0000000080001f1a <userinit>:
{
    80001f1a:	1101                	addi	sp,sp,-32
    80001f1c:	ec06                	sd	ra,24(sp)
    80001f1e:	e822                	sd	s0,16(sp)
    80001f20:	e426                	sd	s1,8(sp)
    80001f22:	e04a                	sd	s2,0(sp)
    80001f24:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f26:	00000097          	auipc	ra,0x0
    80001f2a:	ed0080e7          	jalr	-304(ra) # 80001df6 <allocproc>
    80001f2e:	84aa                	mv	s1,a0
  initproc = p;
    80001f30:	00007797          	auipc	a5,0x7
    80001f34:	0ea7b423          	sd	a0,232(a5) # 80009018 <initproc>
   uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f38:	03400613          	li	a2,52
    80001f3c:	00007597          	auipc	a1,0x7
    80001f40:	9b458593          	addi	a1,a1,-1612 # 800088f0 <initcode>
    80001f44:	6928                	ld	a0,80(a0)
    80001f46:	fffff097          	auipc	ra,0xfffff
    80001f4a:	47e080e7          	jalr	1150(ra) # 800013c4 <uvminit>
  p->sz = PGSIZE;
    80001f4e:	6905                	lui	s2,0x1
    80001f50:	0524b423          	sd	s2,72(s1)
  kvmcopymappings(p->pagetable, p->kernel_pagetable, 0, p->sz); // 同步程序内存映射到进程内核页表中
    80001f54:	6685                	lui	a3,0x1
    80001f56:	4601                	li	a2,0
    80001f58:	1684b583          	ld	a1,360(s1)
    80001f5c:	68a8                	ld	a0,80(s1)
    80001f5e:	00000097          	auipc	ra,0x0
    80001f62:	a28080e7          	jalr	-1496(ra) # 80001986 <kvmcopymappings>
  p->trapframe->epc = 0;      // user program counter
    80001f66:	6cbc                	ld	a5,88(s1)
    80001f68:	0007bc23          	sd	zero,24(a5)
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001f6c:	6cbc                	ld	a5,88(s1)
    80001f6e:	0327b823          	sd	s2,48(a5)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f72:	4641                	li	a2,16
    80001f74:	00006597          	auipc	a1,0x6
    80001f78:	30c58593          	addi	a1,a1,780 # 80008280 <digits+0x250>
    80001f7c:	15848513          	addi	a0,s1,344
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	ecc080e7          	jalr	-308(ra) # 80000e4c <safestrcpy>
  p->cwd = namei("/");
    80001f88:	00006517          	auipc	a0,0x6
    80001f8c:	30850513          	addi	a0,a0,776 # 80008290 <digits+0x260>
    80001f90:	00002097          	auipc	ra,0x2
    80001f94:	140080e7          	jalr	320(ra) # 800040d0 <namei>
    80001f98:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f9c:	4789                	li	a5,2
    80001f9e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001fa0:	8526                	mv	a0,s1
    80001fa2:	fffff097          	auipc	ra,0xfffff
    80001fa6:	d10080e7          	jalr	-752(ra) # 80000cb2 <release>
}
    80001faa:	60e2                	ld	ra,24(sp)
    80001fac:	6442                	ld	s0,16(sp)
    80001fae:	64a2                	ld	s1,8(sp)
    80001fb0:	6902                	ld	s2,0(sp)
    80001fb2:	6105                	addi	sp,sp,32
    80001fb4:	8082                	ret

0000000080001fb6 <growproc>:
{
    80001fb6:	7179                	addi	sp,sp,-48
    80001fb8:	f406                	sd	ra,40(sp)
    80001fba:	f022                	sd	s0,32(sp)
    80001fbc:	ec26                	sd	s1,24(sp)
    80001fbe:	e84a                	sd	s2,16(sp)
    80001fc0:	e44e                	sd	s3,8(sp)
    80001fc2:	e052                	sd	s4,0(sp)
    80001fc4:	1800                	addi	s0,sp,48
    80001fc6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001fc8:	00000097          	auipc	ra,0x0
    80001fcc:	b88080e7          	jalr	-1144(ra) # 80001b50 <myproc>
    80001fd0:	84aa                	mv	s1,a0
  sz = p->sz;
    80001fd2:	652c                	ld	a1,72(a0)
    80001fd4:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001fd8:	03204363          	bgtz	s2,80001ffe <growproc+0x48>
  } else if(n < 0){
    80001fdc:	06094663          	bltz	s2,80002048 <growproc+0x92>
  p->sz = sz;
    80001fe0:	02061913          	slli	s2,a2,0x20
    80001fe4:	02095913          	srli	s2,s2,0x20
    80001fe8:	0524b423          	sd	s2,72(s1)
  return 0;
    80001fec:	4501                	li	a0,0
}
    80001fee:	70a2                	ld	ra,40(sp)
    80001ff0:	7402                	ld	s0,32(sp)
    80001ff2:	64e2                	ld	s1,24(sp)
    80001ff4:	6942                	ld	s2,16(sp)
    80001ff6:	69a2                	ld	s3,8(sp)
    80001ff8:	6a02                	ld	s4,0(sp)
    80001ffa:	6145                	addi	sp,sp,48
    80001ffc:	8082                	ret
    if((newsz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001ffe:	02059993          	slli	s3,a1,0x20
    80002002:	0209d993          	srli	s3,s3,0x20
    80002006:	00c9063b          	addw	a2,s2,a2
    8000200a:	1602                	slli	a2,a2,0x20
    8000200c:	9201                	srli	a2,a2,0x20
    8000200e:	85ce                	mv	a1,s3
    80002010:	6928                	ld	a0,80(a0)
    80002012:	fffff097          	auipc	ra,0xfffff
    80002016:	46c080e7          	jalr	1132(ra) # 8000147e <uvmalloc>
    8000201a:	8a2a                	mv	s4,a0
    8000201c:	c12d                	beqz	a0,8000207e <growproc+0xc8>
    if(kvmcopymappings(p->pagetable, p->kernel_pagetable, sz, n) != 0) {
    8000201e:	86ca                	mv	a3,s2
    80002020:	864e                	mv	a2,s3
    80002022:	1684b583          	ld	a1,360(s1)
    80002026:	68a8                	ld	a0,80(s1)
    80002028:	00000097          	auipc	ra,0x0
    8000202c:	95e080e7          	jalr	-1698(ra) # 80001986 <kvmcopymappings>
    sz = newsz;
    80002030:	000a061b          	sext.w	a2,s4
    if(kvmcopymappings(p->pagetable, p->kernel_pagetable, sz, n) != 0) {
    80002034:	d555                	beqz	a0,80001fe0 <growproc+0x2a>
      uvmdealloc(p->pagetable, newsz, sz);
    80002036:	864e                	mv	a2,s3
    80002038:	85d2                	mv	a1,s4
    8000203a:	68a8                	ld	a0,80(s1)
    8000203c:	fffff097          	auipc	ra,0xfffff
    80002040:	3fa080e7          	jalr	1018(ra) # 80001436 <uvmdealloc>
      return -1;
    80002044:	557d                	li	a0,-1
    80002046:	b765                	j	80001fee <growproc+0x38>
    uvmdealloc(p->pagetable, sz, sz + n);
    80002048:	02059993          	slli	s3,a1,0x20
    8000204c:	0209d993          	srli	s3,s3,0x20
    80002050:	00c9093b          	addw	s2,s2,a2
    80002054:	1902                	slli	s2,s2,0x20
    80002056:	02095913          	srli	s2,s2,0x20
    8000205a:	864a                	mv	a2,s2
    8000205c:	85ce                	mv	a1,s3
    8000205e:	6928                	ld	a0,80(a0)
    80002060:	fffff097          	auipc	ra,0xfffff
    80002064:	3d6080e7          	jalr	982(ra) # 80001436 <uvmdealloc>
    sz = kvmdealloc(p->kernel_pagetable, sz, sz + n);
    80002068:	864a                	mv	a2,s2
    8000206a:	85ce                	mv	a1,s3
    8000206c:	1684b503          	ld	a0,360(s1)
    80002070:	00000097          	auipc	ra,0x0
    80002074:	9c0080e7          	jalr	-1600(ra) # 80001a30 <kvmdealloc>
    80002078:	0005061b          	sext.w	a2,a0
    8000207c:	b795                	j	80001fe0 <growproc+0x2a>
      return -1;
    8000207e:	557d                	li	a0,-1
    80002080:	b7bd                	j	80001fee <growproc+0x38>

0000000080002082 <fork>:
{
    80002082:	7139                	addi	sp,sp,-64
    80002084:	fc06                	sd	ra,56(sp)
    80002086:	f822                	sd	s0,48(sp)
    80002088:	f426                	sd	s1,40(sp)
    8000208a:	f04a                	sd	s2,32(sp)
    8000208c:	ec4e                	sd	s3,24(sp)
    8000208e:	e852                	sd	s4,16(sp)
    80002090:	e456                	sd	s5,8(sp)
    80002092:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002094:	00000097          	auipc	ra,0x0
    80002098:	abc080e7          	jalr	-1348(ra) # 80001b50 <myproc>
    8000209c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000209e:	00000097          	auipc	ra,0x0
    800020a2:	d58080e7          	jalr	-680(ra) # 80001df6 <allocproc>
    800020a6:	10050163          	beqz	a0,800021a8 <fork+0x126>
    800020aa:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0 ||
    800020ac:	048ab603          	ld	a2,72(s5) # 1048 <_entry-0x7fffefb8>
    800020b0:	692c                	ld	a1,80(a0)
    800020b2:	050ab503          	ld	a0,80(s5)
    800020b6:	fffff097          	auipc	ra,0xfffff
    800020ba:	514080e7          	jalr	1300(ra) # 800015ca <uvmcopy>
    800020be:	06054763          	bltz	a0,8000212c <fork+0xaa>
     kvmcopymappings(np->pagetable, np->kernel_pagetable, 0, p->sz) < 0){
    800020c2:	048ab683          	ld	a3,72(s5)
    800020c6:	4601                	li	a2,0
    800020c8:	1689b583          	ld	a1,360(s3)
    800020cc:	0509b503          	ld	a0,80(s3)
    800020d0:	00000097          	auipc	ra,0x0
    800020d4:	8b6080e7          	jalr	-1866(ra) # 80001986 <kvmcopymappings>
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0 ||
    800020d8:	04054a63          	bltz	a0,8000212c <fork+0xaa>
  np->sz = p->sz;
    800020dc:	048ab783          	ld	a5,72(s5)
    800020e0:	04f9b423          	sd	a5,72(s3)
  np->parent = p;
    800020e4:	0359b023          	sd	s5,32(s3)
  *(np->trapframe) = *(p->trapframe);
    800020e8:	058ab683          	ld	a3,88(s5)
    800020ec:	87b6                	mv	a5,a3
    800020ee:	0589b703          	ld	a4,88(s3)
    800020f2:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    800020f6:	0007b803          	ld	a6,0(a5)
    800020fa:	6788                	ld	a0,8(a5)
    800020fc:	6b8c                	ld	a1,16(a5)
    800020fe:	6f90                	ld	a2,24(a5)
    80002100:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80002104:	e708                	sd	a0,8(a4)
    80002106:	eb0c                	sd	a1,16(a4)
    80002108:	ef10                	sd	a2,24(a4)
    8000210a:	02078793          	addi	a5,a5,32
    8000210e:	02070713          	addi	a4,a4,32
    80002112:	fed792e3          	bne	a5,a3,800020f6 <fork+0x74>
  np->trapframe->a0 = 0;
    80002116:	0589b783          	ld	a5,88(s3)
    8000211a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    8000211e:	0d0a8493          	addi	s1,s5,208
    80002122:	0d098913          	addi	s2,s3,208
    80002126:	150a8a13          	addi	s4,s5,336
    8000212a:	a00d                	j	8000214c <fork+0xca>
    freeproc(np);
    8000212c:	854e                	mv	a0,s3
    8000212e:	00000097          	auipc	ra,0x0
    80002132:	b8e080e7          	jalr	-1138(ra) # 80001cbc <freeproc>
    release(&np->lock);
    80002136:	854e                	mv	a0,s3
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	b7a080e7          	jalr	-1158(ra) # 80000cb2 <release>
    return -1;
    80002140:	54fd                	li	s1,-1
    80002142:	a889                	j	80002194 <fork+0x112>
  for(i = 0; i < NOFILE; i++)
    80002144:	04a1                	addi	s1,s1,8
    80002146:	0921                	addi	s2,s2,8
    80002148:	01448b63          	beq	s1,s4,8000215e <fork+0xdc>
    if(p->ofile[i])
    8000214c:	6088                	ld	a0,0(s1)
    8000214e:	d97d                	beqz	a0,80002144 <fork+0xc2>
      np->ofile[i] = filedup(p->ofile[i]);
    80002150:	00002097          	auipc	ra,0x2
    80002154:	60c080e7          	jalr	1548(ra) # 8000475c <filedup>
    80002158:	00a93023          	sd	a0,0(s2) # 1000 <_entry-0x7ffff000>
    8000215c:	b7e5                	j	80002144 <fork+0xc2>
  np->cwd = idup(p->cwd);
    8000215e:	150ab503          	ld	a0,336(s5)
    80002162:	00001097          	auipc	ra,0x1
    80002166:	780080e7          	jalr	1920(ra) # 800038e2 <idup>
    8000216a:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000216e:	4641                	li	a2,16
    80002170:	158a8593          	addi	a1,s5,344
    80002174:	15898513          	addi	a0,s3,344
    80002178:	fffff097          	auipc	ra,0xfffff
    8000217c:	cd4080e7          	jalr	-812(ra) # 80000e4c <safestrcpy>
  pid = np->pid;
    80002180:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80002184:	4789                	li	a5,2
    80002186:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000218a:	854e                	mv	a0,s3
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	b26080e7          	jalr	-1242(ra) # 80000cb2 <release>
}
    80002194:	8526                	mv	a0,s1
    80002196:	70e2                	ld	ra,56(sp)
    80002198:	7442                	ld	s0,48(sp)
    8000219a:	74a2                	ld	s1,40(sp)
    8000219c:	7902                	ld	s2,32(sp)
    8000219e:	69e2                	ld	s3,24(sp)
    800021a0:	6a42                	ld	s4,16(sp)
    800021a2:	6aa2                	ld	s5,8(sp)
    800021a4:	6121                	addi	sp,sp,64
    800021a6:	8082                	ret
    return -1;
    800021a8:	54fd                	li	s1,-1
    800021aa:	b7ed                	j	80002194 <fork+0x112>

00000000800021ac <reparent>:
{
    800021ac:	7179                	addi	sp,sp,-48
    800021ae:	f406                	sd	ra,40(sp)
    800021b0:	f022                	sd	s0,32(sp)
    800021b2:	ec26                	sd	s1,24(sp)
    800021b4:	e84a                	sd	s2,16(sp)
    800021b6:	e44e                	sd	s3,8(sp)
    800021b8:	e052                	sd	s4,0(sp)
    800021ba:	1800                	addi	s0,sp,48
    800021bc:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021be:	00010497          	auipc	s1,0x10
    800021c2:	baa48493          	addi	s1,s1,-1110 # 80011d68 <proc>
      pp->parent = initproc;
    800021c6:	00007a17          	auipc	s4,0x7
    800021ca:	e52a0a13          	addi	s4,s4,-430 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ce:	00015997          	auipc	s3,0x15
    800021d2:	79a98993          	addi	s3,s3,1946 # 80017968 <tickslock>
    800021d6:	a029                	j	800021e0 <reparent+0x34>
    800021d8:	17048493          	addi	s1,s1,368
    800021dc:	03348363          	beq	s1,s3,80002202 <reparent+0x56>
    if(pp->parent == p){
    800021e0:	709c                	ld	a5,32(s1)
    800021e2:	ff279be3          	bne	a5,s2,800021d8 <reparent+0x2c>
      acquire(&pp->lock);
    800021e6:	8526                	mv	a0,s1
    800021e8:	fffff097          	auipc	ra,0xfffff
    800021ec:	a16080e7          	jalr	-1514(ra) # 80000bfe <acquire>
      pp->parent = initproc;
    800021f0:	000a3783          	ld	a5,0(s4)
    800021f4:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    800021f6:	8526                	mv	a0,s1
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	aba080e7          	jalr	-1350(ra) # 80000cb2 <release>
    80002200:	bfe1                	j	800021d8 <reparent+0x2c>
}
    80002202:	70a2                	ld	ra,40(sp)
    80002204:	7402                	ld	s0,32(sp)
    80002206:	64e2                	ld	s1,24(sp)
    80002208:	6942                	ld	s2,16(sp)
    8000220a:	69a2                	ld	s3,8(sp)
    8000220c:	6a02                	ld	s4,0(sp)
    8000220e:	6145                	addi	sp,sp,48
    80002210:	8082                	ret

0000000080002212 <scheduler>:
{
    80002212:	715d                	addi	sp,sp,-80
    80002214:	e486                	sd	ra,72(sp)
    80002216:	e0a2                	sd	s0,64(sp)
    80002218:	fc26                	sd	s1,56(sp)
    8000221a:	f84a                	sd	s2,48(sp)
    8000221c:	f44e                	sd	s3,40(sp)
    8000221e:	f052                	sd	s4,32(sp)
    80002220:	ec56                	sd	s5,24(sp)
    80002222:	e85a                	sd	s6,16(sp)
    80002224:	e45e                	sd	s7,8(sp)
    80002226:	e062                	sd	s8,0(sp)
    80002228:	0880                	addi	s0,sp,80
    8000222a:	8792                	mv	a5,tp
  int id = r_tp();
    8000222c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000222e:	00779b13          	slli	s6,a5,0x7
    80002232:	0000f717          	auipc	a4,0xf
    80002236:	71e70713          	addi	a4,a4,1822 # 80011950 <pid_lock>
    8000223a:	975a                	add	a4,a4,s6
    8000223c:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80002240:	0000f717          	auipc	a4,0xf
    80002244:	73070713          	addi	a4,a4,1840 # 80011970 <cpus+0x8>
    80002248:	9b3a                	add	s6,s6,a4
        c->proc = p;
    8000224a:	079e                	slli	a5,a5,0x7
    8000224c:	0000fa17          	auipc	s4,0xf
    80002250:	704a0a13          	addi	s4,s4,1796 # 80011950 <pid_lock>
    80002254:	9a3e                	add	s4,s4,a5
        w_satp(MAKE_SATP(p->kernel_pagetable));
    80002256:	5bfd                	li	s7,-1
    80002258:	1bfe                	slli	s7,s7,0x3f
    for(p = proc; p < &proc[NPROC]; p++) {
    8000225a:	00015997          	auipc	s3,0x15
    8000225e:	70e98993          	addi	s3,s3,1806 # 80017968 <tickslock>
    80002262:	a885                	j	800022d2 <scheduler+0xc0>
      release(&p->lock);
    80002264:	8526                	mv	a0,s1
    80002266:	fffff097          	auipc	ra,0xfffff
    8000226a:	a4c080e7          	jalr	-1460(ra) # 80000cb2 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000226e:	17048493          	addi	s1,s1,368
    80002272:	05348663          	beq	s1,s3,800022be <scheduler+0xac>
      acquire(&p->lock);
    80002276:	8526                	mv	a0,s1
    80002278:	fffff097          	auipc	ra,0xfffff
    8000227c:	986080e7          	jalr	-1658(ra) # 80000bfe <acquire>
      if(p->state == RUNNABLE) {
    80002280:	4c9c                	lw	a5,24(s1)
    80002282:	ff2791e3          	bne	a5,s2,80002264 <scheduler+0x52>
        p->state = RUNNING;
    80002286:	0154ac23          	sw	s5,24(s1)
        c->proc = p;
    8000228a:	009a3c23          	sd	s1,24(s4)
        w_satp(MAKE_SATP(p->kernel_pagetable));
    8000228e:	1684b783          	ld	a5,360(s1)
    80002292:	83b1                	srli	a5,a5,0xc
    80002294:	0177e7b3          	or	a5,a5,s7
  asm volatile("csrw satp, %0" : : "r" (x));
    80002298:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000229c:	12000073          	sfence.vma
        swtch(&c->context, &p->context);
    800022a0:	06048593          	addi	a1,s1,96
    800022a4:	855a                	mv	a0,s6
    800022a6:	00000097          	auipc	ra,0x0
    800022aa:	618080e7          	jalr	1560(ra) # 800028be <swtch>
        kvminithart();
    800022ae:	fffff097          	auipc	ra,0xfffff
    800022b2:	d18080e7          	jalr	-744(ra) # 80000fc6 <kvminithart>
        c->proc = 0;
    800022b6:	000a3c23          	sd	zero,24(s4)
        found = 1;
    800022ba:	4c05                	li	s8,1
    800022bc:	b765                	j	80002264 <scheduler+0x52>
    if(found == 0) {
    800022be:	000c1a63          	bnez	s8,800022d2 <scheduler+0xc0>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022c2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022c6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022ca:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800022ce:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022d2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022d6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022da:	10079073          	csrw	sstatus,a5
    int found = 0;
    800022de:	4c01                	li	s8,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800022e0:	00010497          	auipc	s1,0x10
    800022e4:	a8848493          	addi	s1,s1,-1400 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    800022e8:	4909                	li	s2,2
        p->state = RUNNING;
    800022ea:	4a8d                	li	s5,3
    800022ec:	b769                	j	80002276 <scheduler+0x64>

00000000800022ee <sched>:
{
    800022ee:	7179                	addi	sp,sp,-48
    800022f0:	f406                	sd	ra,40(sp)
    800022f2:	f022                	sd	s0,32(sp)
    800022f4:	ec26                	sd	s1,24(sp)
    800022f6:	e84a                	sd	s2,16(sp)
    800022f8:	e44e                	sd	s3,8(sp)
    800022fa:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800022fc:	00000097          	auipc	ra,0x0
    80002300:	854080e7          	jalr	-1964(ra) # 80001b50 <myproc>
    80002304:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002306:	fffff097          	auipc	ra,0xfffff
    8000230a:	87e080e7          	jalr	-1922(ra) # 80000b84 <holding>
    8000230e:	c93d                	beqz	a0,80002384 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002310:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002312:	2781                	sext.w	a5,a5
    80002314:	079e                	slli	a5,a5,0x7
    80002316:	0000f717          	auipc	a4,0xf
    8000231a:	63a70713          	addi	a4,a4,1594 # 80011950 <pid_lock>
    8000231e:	97ba                	add	a5,a5,a4
    80002320:	0907a703          	lw	a4,144(a5)
    80002324:	4785                	li	a5,1
    80002326:	06f71763          	bne	a4,a5,80002394 <sched+0xa6>
  if(p->state == RUNNING)
    8000232a:	4c98                	lw	a4,24(s1)
    8000232c:	478d                	li	a5,3
    8000232e:	06f70b63          	beq	a4,a5,800023a4 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002332:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002336:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002338:	efb5                	bnez	a5,800023b4 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000233a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000233c:	0000f917          	auipc	s2,0xf
    80002340:	61490913          	addi	s2,s2,1556 # 80011950 <pid_lock>
    80002344:	2781                	sext.w	a5,a5
    80002346:	079e                	slli	a5,a5,0x7
    80002348:	97ca                	add	a5,a5,s2
    8000234a:	0947a983          	lw	s3,148(a5)
    8000234e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002350:	2781                	sext.w	a5,a5
    80002352:	079e                	slli	a5,a5,0x7
    80002354:	0000f597          	auipc	a1,0xf
    80002358:	61c58593          	addi	a1,a1,1564 # 80011970 <cpus+0x8>
    8000235c:	95be                	add	a1,a1,a5
    8000235e:	06048513          	addi	a0,s1,96
    80002362:	00000097          	auipc	ra,0x0
    80002366:	55c080e7          	jalr	1372(ra) # 800028be <swtch>
    8000236a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000236c:	2781                	sext.w	a5,a5
    8000236e:	079e                	slli	a5,a5,0x7
    80002370:	97ca                	add	a5,a5,s2
    80002372:	0937aa23          	sw	s3,148(a5)
}
    80002376:	70a2                	ld	ra,40(sp)
    80002378:	7402                	ld	s0,32(sp)
    8000237a:	64e2                	ld	s1,24(sp)
    8000237c:	6942                	ld	s2,16(sp)
    8000237e:	69a2                	ld	s3,8(sp)
    80002380:	6145                	addi	sp,sp,48
    80002382:	8082                	ret
    panic("sched p->lock");
    80002384:	00006517          	auipc	a0,0x6
    80002388:	f1450513          	addi	a0,a0,-236 # 80008298 <digits+0x268>
    8000238c:	ffffe097          	auipc	ra,0xffffe
    80002390:	1b6080e7          	jalr	438(ra) # 80000542 <panic>
    panic("sched locks");
    80002394:	00006517          	auipc	a0,0x6
    80002398:	f1450513          	addi	a0,a0,-236 # 800082a8 <digits+0x278>
    8000239c:	ffffe097          	auipc	ra,0xffffe
    800023a0:	1a6080e7          	jalr	422(ra) # 80000542 <panic>
    panic("sched running");
    800023a4:	00006517          	auipc	a0,0x6
    800023a8:	f1450513          	addi	a0,a0,-236 # 800082b8 <digits+0x288>
    800023ac:	ffffe097          	auipc	ra,0xffffe
    800023b0:	196080e7          	jalr	406(ra) # 80000542 <panic>
    panic("sched interruptible");
    800023b4:	00006517          	auipc	a0,0x6
    800023b8:	f1450513          	addi	a0,a0,-236 # 800082c8 <digits+0x298>
    800023bc:	ffffe097          	auipc	ra,0xffffe
    800023c0:	186080e7          	jalr	390(ra) # 80000542 <panic>

00000000800023c4 <exit>:
{
    800023c4:	7179                	addi	sp,sp,-48
    800023c6:	f406                	sd	ra,40(sp)
    800023c8:	f022                	sd	s0,32(sp)
    800023ca:	ec26                	sd	s1,24(sp)
    800023cc:	e84a                	sd	s2,16(sp)
    800023ce:	e44e                	sd	s3,8(sp)
    800023d0:	e052                	sd	s4,0(sp)
    800023d2:	1800                	addi	s0,sp,48
    800023d4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800023d6:	fffff097          	auipc	ra,0xfffff
    800023da:	77a080e7          	jalr	1914(ra) # 80001b50 <myproc>
    800023de:	89aa                	mv	s3,a0
  if(p == initproc)
    800023e0:	00007797          	auipc	a5,0x7
    800023e4:	c387b783          	ld	a5,-968(a5) # 80009018 <initproc>
    800023e8:	0d050493          	addi	s1,a0,208
    800023ec:	15050913          	addi	s2,a0,336
    800023f0:	02a79363          	bne	a5,a0,80002416 <exit+0x52>
    panic("init exiting");
    800023f4:	00006517          	auipc	a0,0x6
    800023f8:	eec50513          	addi	a0,a0,-276 # 800082e0 <digits+0x2b0>
    800023fc:	ffffe097          	auipc	ra,0xffffe
    80002400:	146080e7          	jalr	326(ra) # 80000542 <panic>
      fileclose(f);
    80002404:	00002097          	auipc	ra,0x2
    80002408:	3aa080e7          	jalr	938(ra) # 800047ae <fileclose>
      p->ofile[fd] = 0;
    8000240c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002410:	04a1                	addi	s1,s1,8
    80002412:	01248563          	beq	s1,s2,8000241c <exit+0x58>
    if(p->ofile[fd]){
    80002416:	6088                	ld	a0,0(s1)
    80002418:	f575                	bnez	a0,80002404 <exit+0x40>
    8000241a:	bfdd                	j	80002410 <exit+0x4c>
  begin_op();
    8000241c:	00002097          	auipc	ra,0x2
    80002420:	ec0080e7          	jalr	-320(ra) # 800042dc <begin_op>
  iput(p->cwd);
    80002424:	1509b503          	ld	a0,336(s3)
    80002428:	00001097          	auipc	ra,0x1
    8000242c:	6b2080e7          	jalr	1714(ra) # 80003ada <iput>
  end_op();
    80002430:	00002097          	auipc	ra,0x2
    80002434:	f2c080e7          	jalr	-212(ra) # 8000435c <end_op>
  p->cwd = 0;
    80002438:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000243c:	00007497          	auipc	s1,0x7
    80002440:	bdc48493          	addi	s1,s1,-1060 # 80009018 <initproc>
    80002444:	6088                	ld	a0,0(s1)
    80002446:	ffffe097          	auipc	ra,0xffffe
    8000244a:	7b8080e7          	jalr	1976(ra) # 80000bfe <acquire>
  wakeup1(initproc);
    8000244e:	6088                	ld	a0,0(s1)
    80002450:	fffff097          	auipc	ra,0xfffff
    80002454:	628080e7          	jalr	1576(ra) # 80001a78 <wakeup1>
  release(&initproc->lock);
    80002458:	6088                	ld	a0,0(s1)
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	858080e7          	jalr	-1960(ra) # 80000cb2 <release>
  acquire(&p->lock);
    80002462:	854e                	mv	a0,s3
    80002464:	ffffe097          	auipc	ra,0xffffe
    80002468:	79a080e7          	jalr	1946(ra) # 80000bfe <acquire>
  struct proc *original_parent = p->parent;
    8000246c:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002470:	854e                	mv	a0,s3
    80002472:	fffff097          	auipc	ra,0xfffff
    80002476:	840080e7          	jalr	-1984(ra) # 80000cb2 <release>
  acquire(&original_parent->lock);
    8000247a:	8526                	mv	a0,s1
    8000247c:	ffffe097          	auipc	ra,0xffffe
    80002480:	782080e7          	jalr	1922(ra) # 80000bfe <acquire>
  acquire(&p->lock);
    80002484:	854e                	mv	a0,s3
    80002486:	ffffe097          	auipc	ra,0xffffe
    8000248a:	778080e7          	jalr	1912(ra) # 80000bfe <acquire>
  reparent(p);
    8000248e:	854e                	mv	a0,s3
    80002490:	00000097          	auipc	ra,0x0
    80002494:	d1c080e7          	jalr	-740(ra) # 800021ac <reparent>
  wakeup1(original_parent);
    80002498:	8526                	mv	a0,s1
    8000249a:	fffff097          	auipc	ra,0xfffff
    8000249e:	5de080e7          	jalr	1502(ra) # 80001a78 <wakeup1>
  p->xstate = status;
    800024a2:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800024a6:	4791                	li	a5,4
    800024a8:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800024ac:	8526                	mv	a0,s1
    800024ae:	fffff097          	auipc	ra,0xfffff
    800024b2:	804080e7          	jalr	-2044(ra) # 80000cb2 <release>
  sched();
    800024b6:	00000097          	auipc	ra,0x0
    800024ba:	e38080e7          	jalr	-456(ra) # 800022ee <sched>
  panic("zombie exit");
    800024be:	00006517          	auipc	a0,0x6
    800024c2:	e3250513          	addi	a0,a0,-462 # 800082f0 <digits+0x2c0>
    800024c6:	ffffe097          	auipc	ra,0xffffe
    800024ca:	07c080e7          	jalr	124(ra) # 80000542 <panic>

00000000800024ce <yield>:
{
    800024ce:	1101                	addi	sp,sp,-32
    800024d0:	ec06                	sd	ra,24(sp)
    800024d2:	e822                	sd	s0,16(sp)
    800024d4:	e426                	sd	s1,8(sp)
    800024d6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	678080e7          	jalr	1656(ra) # 80001b50 <myproc>
    800024e0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024e2:	ffffe097          	auipc	ra,0xffffe
    800024e6:	71c080e7          	jalr	1820(ra) # 80000bfe <acquire>
  p->state = RUNNABLE;
    800024ea:	4789                	li	a5,2
    800024ec:	cc9c                	sw	a5,24(s1)
  sched();
    800024ee:	00000097          	auipc	ra,0x0
    800024f2:	e00080e7          	jalr	-512(ra) # 800022ee <sched>
  release(&p->lock);
    800024f6:	8526                	mv	a0,s1
    800024f8:	ffffe097          	auipc	ra,0xffffe
    800024fc:	7ba080e7          	jalr	1978(ra) # 80000cb2 <release>
}
    80002500:	60e2                	ld	ra,24(sp)
    80002502:	6442                	ld	s0,16(sp)
    80002504:	64a2                	ld	s1,8(sp)
    80002506:	6105                	addi	sp,sp,32
    80002508:	8082                	ret

000000008000250a <sleep>:
{
    8000250a:	7179                	addi	sp,sp,-48
    8000250c:	f406                	sd	ra,40(sp)
    8000250e:	f022                	sd	s0,32(sp)
    80002510:	ec26                	sd	s1,24(sp)
    80002512:	e84a                	sd	s2,16(sp)
    80002514:	e44e                	sd	s3,8(sp)
    80002516:	1800                	addi	s0,sp,48
    80002518:	89aa                	mv	s3,a0
    8000251a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	634080e7          	jalr	1588(ra) # 80001b50 <myproc>
    80002524:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002526:	05250663          	beq	a0,s2,80002572 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000252a:	ffffe097          	auipc	ra,0xffffe
    8000252e:	6d4080e7          	jalr	1748(ra) # 80000bfe <acquire>
    release(lk);
    80002532:	854a                	mv	a0,s2
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	77e080e7          	jalr	1918(ra) # 80000cb2 <release>
  p->chan = chan;
    8000253c:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002540:	4785                	li	a5,1
    80002542:	cc9c                	sw	a5,24(s1)
  sched();
    80002544:	00000097          	auipc	ra,0x0
    80002548:	daa080e7          	jalr	-598(ra) # 800022ee <sched>
  p->chan = 0;
    8000254c:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002550:	8526                	mv	a0,s1
    80002552:	ffffe097          	auipc	ra,0xffffe
    80002556:	760080e7          	jalr	1888(ra) # 80000cb2 <release>
    acquire(lk);
    8000255a:	854a                	mv	a0,s2
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	6a2080e7          	jalr	1698(ra) # 80000bfe <acquire>
}
    80002564:	70a2                	ld	ra,40(sp)
    80002566:	7402                	ld	s0,32(sp)
    80002568:	64e2                	ld	s1,24(sp)
    8000256a:	6942                	ld	s2,16(sp)
    8000256c:	69a2                	ld	s3,8(sp)
    8000256e:	6145                	addi	sp,sp,48
    80002570:	8082                	ret
  p->chan = chan;
    80002572:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002576:	4785                	li	a5,1
    80002578:	cd1c                	sw	a5,24(a0)
  sched();
    8000257a:	00000097          	auipc	ra,0x0
    8000257e:	d74080e7          	jalr	-652(ra) # 800022ee <sched>
  p->chan = 0;
    80002582:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002586:	bff9                	j	80002564 <sleep+0x5a>

0000000080002588 <wait>:
{
    80002588:	715d                	addi	sp,sp,-80
    8000258a:	e486                	sd	ra,72(sp)
    8000258c:	e0a2                	sd	s0,64(sp)
    8000258e:	fc26                	sd	s1,56(sp)
    80002590:	f84a                	sd	s2,48(sp)
    80002592:	f44e                	sd	s3,40(sp)
    80002594:	f052                	sd	s4,32(sp)
    80002596:	ec56                	sd	s5,24(sp)
    80002598:	e85a                	sd	s6,16(sp)
    8000259a:	e45e                	sd	s7,8(sp)
    8000259c:	0880                	addi	s0,sp,80
    8000259e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800025a0:	fffff097          	auipc	ra,0xfffff
    800025a4:	5b0080e7          	jalr	1456(ra) # 80001b50 <myproc>
    800025a8:	892a                	mv	s2,a0
  acquire(&p->lock);
    800025aa:	ffffe097          	auipc	ra,0xffffe
    800025ae:	654080e7          	jalr	1620(ra) # 80000bfe <acquire>
    havekids = 0;
    800025b2:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800025b4:	4a11                	li	s4,4
        havekids = 1;
    800025b6:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800025b8:	00015997          	auipc	s3,0x15
    800025bc:	3b098993          	addi	s3,s3,944 # 80017968 <tickslock>
    havekids = 0;
    800025c0:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800025c2:	0000f497          	auipc	s1,0xf
    800025c6:	7a648493          	addi	s1,s1,1958 # 80011d68 <proc>
    800025ca:	a08d                	j	8000262c <wait+0xa4>
          pid = np->pid;
    800025cc:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800025d0:	000b0e63          	beqz	s6,800025ec <wait+0x64>
    800025d4:	4691                	li	a3,4
    800025d6:	03448613          	addi	a2,s1,52
    800025da:	85da                	mv	a1,s6
    800025dc:	05093503          	ld	a0,80(s2)
    800025e0:	fffff097          	auipc	ra,0xfffff
    800025e4:	0ee080e7          	jalr	238(ra) # 800016ce <copyout>
    800025e8:	02054263          	bltz	a0,8000260c <wait+0x84>
          freeproc(np);
    800025ec:	8526                	mv	a0,s1
    800025ee:	fffff097          	auipc	ra,0xfffff
    800025f2:	6ce080e7          	jalr	1742(ra) # 80001cbc <freeproc>
          release(&np->lock);
    800025f6:	8526                	mv	a0,s1
    800025f8:	ffffe097          	auipc	ra,0xffffe
    800025fc:	6ba080e7          	jalr	1722(ra) # 80000cb2 <release>
          release(&p->lock);
    80002600:	854a                	mv	a0,s2
    80002602:	ffffe097          	auipc	ra,0xffffe
    80002606:	6b0080e7          	jalr	1712(ra) # 80000cb2 <release>
          return pid;
    8000260a:	a8a9                	j	80002664 <wait+0xdc>
            release(&np->lock);
    8000260c:	8526                	mv	a0,s1
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	6a4080e7          	jalr	1700(ra) # 80000cb2 <release>
            release(&p->lock);
    80002616:	854a                	mv	a0,s2
    80002618:	ffffe097          	auipc	ra,0xffffe
    8000261c:	69a080e7          	jalr	1690(ra) # 80000cb2 <release>
            return -1;
    80002620:	59fd                	li	s3,-1
    80002622:	a089                	j	80002664 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002624:	17048493          	addi	s1,s1,368
    80002628:	03348463          	beq	s1,s3,80002650 <wait+0xc8>
      if(np->parent == p){
    8000262c:	709c                	ld	a5,32(s1)
    8000262e:	ff279be3          	bne	a5,s2,80002624 <wait+0x9c>
        acquire(&np->lock);
    80002632:	8526                	mv	a0,s1
    80002634:	ffffe097          	auipc	ra,0xffffe
    80002638:	5ca080e7          	jalr	1482(ra) # 80000bfe <acquire>
        if(np->state == ZOMBIE){
    8000263c:	4c9c                	lw	a5,24(s1)
    8000263e:	f94787e3          	beq	a5,s4,800025cc <wait+0x44>
        release(&np->lock);
    80002642:	8526                	mv	a0,s1
    80002644:	ffffe097          	auipc	ra,0xffffe
    80002648:	66e080e7          	jalr	1646(ra) # 80000cb2 <release>
        havekids = 1;
    8000264c:	8756                	mv	a4,s5
    8000264e:	bfd9                	j	80002624 <wait+0x9c>
    if(!havekids || p->killed){
    80002650:	c701                	beqz	a4,80002658 <wait+0xd0>
    80002652:	03092783          	lw	a5,48(s2)
    80002656:	c39d                	beqz	a5,8000267c <wait+0xf4>
      release(&p->lock);
    80002658:	854a                	mv	a0,s2
    8000265a:	ffffe097          	auipc	ra,0xffffe
    8000265e:	658080e7          	jalr	1624(ra) # 80000cb2 <release>
      return -1;
    80002662:	59fd                	li	s3,-1
}
    80002664:	854e                	mv	a0,s3
    80002666:	60a6                	ld	ra,72(sp)
    80002668:	6406                	ld	s0,64(sp)
    8000266a:	74e2                	ld	s1,56(sp)
    8000266c:	7942                	ld	s2,48(sp)
    8000266e:	79a2                	ld	s3,40(sp)
    80002670:	7a02                	ld	s4,32(sp)
    80002672:	6ae2                	ld	s5,24(sp)
    80002674:	6b42                	ld	s6,16(sp)
    80002676:	6ba2                	ld	s7,8(sp)
    80002678:	6161                	addi	sp,sp,80
    8000267a:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000267c:	85ca                	mv	a1,s2
    8000267e:	854a                	mv	a0,s2
    80002680:	00000097          	auipc	ra,0x0
    80002684:	e8a080e7          	jalr	-374(ra) # 8000250a <sleep>
    havekids = 0;
    80002688:	bf25                	j	800025c0 <wait+0x38>

000000008000268a <wakeup>:
{
    8000268a:	7139                	addi	sp,sp,-64
    8000268c:	fc06                	sd	ra,56(sp)
    8000268e:	f822                	sd	s0,48(sp)
    80002690:	f426                	sd	s1,40(sp)
    80002692:	f04a                	sd	s2,32(sp)
    80002694:	ec4e                	sd	s3,24(sp)
    80002696:	e852                	sd	s4,16(sp)
    80002698:	e456                	sd	s5,8(sp)
    8000269a:	0080                	addi	s0,sp,64
    8000269c:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000269e:	0000f497          	auipc	s1,0xf
    800026a2:	6ca48493          	addi	s1,s1,1738 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800026a6:	4985                	li	s3,1
      p->state = RUNNABLE;
    800026a8:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800026aa:	00015917          	auipc	s2,0x15
    800026ae:	2be90913          	addi	s2,s2,702 # 80017968 <tickslock>
    800026b2:	a811                	j	800026c6 <wakeup+0x3c>
    release(&p->lock);
    800026b4:	8526                	mv	a0,s1
    800026b6:	ffffe097          	auipc	ra,0xffffe
    800026ba:	5fc080e7          	jalr	1532(ra) # 80000cb2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800026be:	17048493          	addi	s1,s1,368
    800026c2:	03248063          	beq	s1,s2,800026e2 <wakeup+0x58>
    acquire(&p->lock);
    800026c6:	8526                	mv	a0,s1
    800026c8:	ffffe097          	auipc	ra,0xffffe
    800026cc:	536080e7          	jalr	1334(ra) # 80000bfe <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800026d0:	4c9c                	lw	a5,24(s1)
    800026d2:	ff3791e3          	bne	a5,s3,800026b4 <wakeup+0x2a>
    800026d6:	749c                	ld	a5,40(s1)
    800026d8:	fd479ee3          	bne	a5,s4,800026b4 <wakeup+0x2a>
      p->state = RUNNABLE;
    800026dc:	0154ac23          	sw	s5,24(s1)
    800026e0:	bfd1                	j	800026b4 <wakeup+0x2a>
}
    800026e2:	70e2                	ld	ra,56(sp)
    800026e4:	7442                	ld	s0,48(sp)
    800026e6:	74a2                	ld	s1,40(sp)
    800026e8:	7902                	ld	s2,32(sp)
    800026ea:	69e2                	ld	s3,24(sp)
    800026ec:	6a42                	ld	s4,16(sp)
    800026ee:	6aa2                	ld	s5,8(sp)
    800026f0:	6121                	addi	sp,sp,64
    800026f2:	8082                	ret

00000000800026f4 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800026f4:	7179                	addi	sp,sp,-48
    800026f6:	f406                	sd	ra,40(sp)
    800026f8:	f022                	sd	s0,32(sp)
    800026fa:	ec26                	sd	s1,24(sp)
    800026fc:	e84a                	sd	s2,16(sp)
    800026fe:	e44e                	sd	s3,8(sp)
    80002700:	1800                	addi	s0,sp,48
    80002702:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002704:	0000f497          	auipc	s1,0xf
    80002708:	66448493          	addi	s1,s1,1636 # 80011d68 <proc>
    8000270c:	00015997          	auipc	s3,0x15
    80002710:	25c98993          	addi	s3,s3,604 # 80017968 <tickslock>
    acquire(&p->lock);
    80002714:	8526                	mv	a0,s1
    80002716:	ffffe097          	auipc	ra,0xffffe
    8000271a:	4e8080e7          	jalr	1256(ra) # 80000bfe <acquire>
    if(p->pid == pid){
    8000271e:	5c9c                	lw	a5,56(s1)
    80002720:	01278d63          	beq	a5,s2,8000273a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002724:	8526                	mv	a0,s1
    80002726:	ffffe097          	auipc	ra,0xffffe
    8000272a:	58c080e7          	jalr	1420(ra) # 80000cb2 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000272e:	17048493          	addi	s1,s1,368
    80002732:	ff3491e3          	bne	s1,s3,80002714 <kill+0x20>
  }
  return -1;
    80002736:	557d                	li	a0,-1
    80002738:	a821                	j	80002750 <kill+0x5c>
      p->killed = 1;
    8000273a:	4785                	li	a5,1
    8000273c:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    8000273e:	4c98                	lw	a4,24(s1)
    80002740:	00f70f63          	beq	a4,a5,8000275e <kill+0x6a>
      release(&p->lock);
    80002744:	8526                	mv	a0,s1
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	56c080e7          	jalr	1388(ra) # 80000cb2 <release>
      return 0;
    8000274e:	4501                	li	a0,0
}
    80002750:	70a2                	ld	ra,40(sp)
    80002752:	7402                	ld	s0,32(sp)
    80002754:	64e2                	ld	s1,24(sp)
    80002756:	6942                	ld	s2,16(sp)
    80002758:	69a2                	ld	s3,8(sp)
    8000275a:	6145                	addi	sp,sp,48
    8000275c:	8082                	ret
        p->state = RUNNABLE;
    8000275e:	4789                	li	a5,2
    80002760:	cc9c                	sw	a5,24(s1)
    80002762:	b7cd                	j	80002744 <kill+0x50>

0000000080002764 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002764:	7179                	addi	sp,sp,-48
    80002766:	f406                	sd	ra,40(sp)
    80002768:	f022                	sd	s0,32(sp)
    8000276a:	ec26                	sd	s1,24(sp)
    8000276c:	e84a                	sd	s2,16(sp)
    8000276e:	e44e                	sd	s3,8(sp)
    80002770:	e052                	sd	s4,0(sp)
    80002772:	1800                	addi	s0,sp,48
    80002774:	84aa                	mv	s1,a0
    80002776:	892e                	mv	s2,a1
    80002778:	89b2                	mv	s3,a2
    8000277a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000277c:	fffff097          	auipc	ra,0xfffff
    80002780:	3d4080e7          	jalr	980(ra) # 80001b50 <myproc>
  if(user_dst){
    80002784:	c08d                	beqz	s1,800027a6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002786:	86d2                	mv	a3,s4
    80002788:	864e                	mv	a2,s3
    8000278a:	85ca                	mv	a1,s2
    8000278c:	6928                	ld	a0,80(a0)
    8000278e:	fffff097          	auipc	ra,0xfffff
    80002792:	f40080e7          	jalr	-192(ra) # 800016ce <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002796:	70a2                	ld	ra,40(sp)
    80002798:	7402                	ld	s0,32(sp)
    8000279a:	64e2                	ld	s1,24(sp)
    8000279c:	6942                	ld	s2,16(sp)
    8000279e:	69a2                	ld	s3,8(sp)
    800027a0:	6a02                	ld	s4,0(sp)
    800027a2:	6145                	addi	sp,sp,48
    800027a4:	8082                	ret
    memmove((char *)dst, src, len);
    800027a6:	000a061b          	sext.w	a2,s4
    800027aa:	85ce                	mv	a1,s3
    800027ac:	854a                	mv	a0,s2
    800027ae:	ffffe097          	auipc	ra,0xffffe
    800027b2:	5a8080e7          	jalr	1448(ra) # 80000d56 <memmove>
    return 0;
    800027b6:	8526                	mv	a0,s1
    800027b8:	bff9                	j	80002796 <either_copyout+0x32>

00000000800027ba <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027ba:	7179                	addi	sp,sp,-48
    800027bc:	f406                	sd	ra,40(sp)
    800027be:	f022                	sd	s0,32(sp)
    800027c0:	ec26                	sd	s1,24(sp)
    800027c2:	e84a                	sd	s2,16(sp)
    800027c4:	e44e                	sd	s3,8(sp)
    800027c6:	e052                	sd	s4,0(sp)
    800027c8:	1800                	addi	s0,sp,48
    800027ca:	892a                	mv	s2,a0
    800027cc:	84ae                	mv	s1,a1
    800027ce:	89b2                	mv	s3,a2
    800027d0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027d2:	fffff097          	auipc	ra,0xfffff
    800027d6:	37e080e7          	jalr	894(ra) # 80001b50 <myproc>
  if(user_src){
    800027da:	c08d                	beqz	s1,800027fc <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800027dc:	86d2                	mv	a3,s4
    800027de:	864e                	mv	a2,s3
    800027e0:	85ca                	mv	a1,s2
    800027e2:	6928                	ld	a0,80(a0)
    800027e4:	fffff097          	auipc	ra,0xfffff
    800027e8:	f76080e7          	jalr	-138(ra) # 8000175a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800027ec:	70a2                	ld	ra,40(sp)
    800027ee:	7402                	ld	s0,32(sp)
    800027f0:	64e2                	ld	s1,24(sp)
    800027f2:	6942                	ld	s2,16(sp)
    800027f4:	69a2                	ld	s3,8(sp)
    800027f6:	6a02                	ld	s4,0(sp)
    800027f8:	6145                	addi	sp,sp,48
    800027fa:	8082                	ret
    memmove(dst, (char*)src, len);
    800027fc:	000a061b          	sext.w	a2,s4
    80002800:	85ce                	mv	a1,s3
    80002802:	854a                	mv	a0,s2
    80002804:	ffffe097          	auipc	ra,0xffffe
    80002808:	552080e7          	jalr	1362(ra) # 80000d56 <memmove>
    return 0;
    8000280c:	8526                	mv	a0,s1
    8000280e:	bff9                	j	800027ec <either_copyin+0x32>

0000000080002810 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002810:	715d                	addi	sp,sp,-80
    80002812:	e486                	sd	ra,72(sp)
    80002814:	e0a2                	sd	s0,64(sp)
    80002816:	fc26                	sd	s1,56(sp)
    80002818:	f84a                	sd	s2,48(sp)
    8000281a:	f44e                	sd	s3,40(sp)
    8000281c:	f052                	sd	s4,32(sp)
    8000281e:	ec56                	sd	s5,24(sp)
    80002820:	e85a                	sd	s6,16(sp)
    80002822:	e45e                	sd	s7,8(sp)
    80002824:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002826:	00006517          	auipc	a0,0x6
    8000282a:	89250513          	addi	a0,a0,-1902 # 800080b8 <digits+0x88>
    8000282e:	ffffe097          	auipc	ra,0xffffe
    80002832:	d5e080e7          	jalr	-674(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002836:	0000f497          	auipc	s1,0xf
    8000283a:	68a48493          	addi	s1,s1,1674 # 80011ec0 <proc+0x158>
    8000283e:	00015917          	auipc	s2,0x15
    80002842:	28290913          	addi	s2,s2,642 # 80017ac0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002846:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002848:	00006997          	auipc	s3,0x6
    8000284c:	ab898993          	addi	s3,s3,-1352 # 80008300 <digits+0x2d0>
    printf("%d %s %s", p->pid, state, p->name);
    80002850:	00006a97          	auipc	s5,0x6
    80002854:	ab8a8a93          	addi	s5,s5,-1352 # 80008308 <digits+0x2d8>
    printf("\n");
    80002858:	00006a17          	auipc	s4,0x6
    8000285c:	860a0a13          	addi	s4,s4,-1952 # 800080b8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002860:	00006b97          	auipc	s7,0x6
    80002864:	ae0b8b93          	addi	s7,s7,-1312 # 80008340 <states.0>
    80002868:	a00d                	j	8000288a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000286a:	ee06a583          	lw	a1,-288(a3)
    8000286e:	8556                	mv	a0,s5
    80002870:	ffffe097          	auipc	ra,0xffffe
    80002874:	d1c080e7          	jalr	-740(ra) # 8000058c <printf>
    printf("\n");
    80002878:	8552                	mv	a0,s4
    8000287a:	ffffe097          	auipc	ra,0xffffe
    8000287e:	d12080e7          	jalr	-750(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002882:	17048493          	addi	s1,s1,368
    80002886:	03248163          	beq	s1,s2,800028a8 <procdump+0x98>
    if(p->state == UNUSED)
    8000288a:	86a6                	mv	a3,s1
    8000288c:	ec04a783          	lw	a5,-320(s1)
    80002890:	dbed                	beqz	a5,80002882 <procdump+0x72>
      state = "???";
    80002892:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002894:	fcfb6be3          	bltu	s6,a5,8000286a <procdump+0x5a>
    80002898:	1782                	slli	a5,a5,0x20
    8000289a:	9381                	srli	a5,a5,0x20
    8000289c:	078e                	slli	a5,a5,0x3
    8000289e:	97de                	add	a5,a5,s7
    800028a0:	6390                	ld	a2,0(a5)
    800028a2:	f661                	bnez	a2,8000286a <procdump+0x5a>
      state = "???";
    800028a4:	864e                	mv	a2,s3
    800028a6:	b7d1                	j	8000286a <procdump+0x5a>
  }
}
    800028a8:	60a6                	ld	ra,72(sp)
    800028aa:	6406                	ld	s0,64(sp)
    800028ac:	74e2                	ld	s1,56(sp)
    800028ae:	7942                	ld	s2,48(sp)
    800028b0:	79a2                	ld	s3,40(sp)
    800028b2:	7a02                	ld	s4,32(sp)
    800028b4:	6ae2                	ld	s5,24(sp)
    800028b6:	6b42                	ld	s6,16(sp)
    800028b8:	6ba2                	ld	s7,8(sp)
    800028ba:	6161                	addi	sp,sp,80
    800028bc:	8082                	ret

00000000800028be <swtch>:
    800028be:	00153023          	sd	ra,0(a0)
    800028c2:	00253423          	sd	sp,8(a0)
    800028c6:	e900                	sd	s0,16(a0)
    800028c8:	ed04                	sd	s1,24(a0)
    800028ca:	03253023          	sd	s2,32(a0)
    800028ce:	03353423          	sd	s3,40(a0)
    800028d2:	03453823          	sd	s4,48(a0)
    800028d6:	03553c23          	sd	s5,56(a0)
    800028da:	05653023          	sd	s6,64(a0)
    800028de:	05753423          	sd	s7,72(a0)
    800028e2:	05853823          	sd	s8,80(a0)
    800028e6:	05953c23          	sd	s9,88(a0)
    800028ea:	07a53023          	sd	s10,96(a0)
    800028ee:	07b53423          	sd	s11,104(a0)
    800028f2:	0005b083          	ld	ra,0(a1)
    800028f6:	0085b103          	ld	sp,8(a1)
    800028fa:	6980                	ld	s0,16(a1)
    800028fc:	6d84                	ld	s1,24(a1)
    800028fe:	0205b903          	ld	s2,32(a1)
    80002902:	0285b983          	ld	s3,40(a1)
    80002906:	0305ba03          	ld	s4,48(a1)
    8000290a:	0385ba83          	ld	s5,56(a1)
    8000290e:	0405bb03          	ld	s6,64(a1)
    80002912:	0485bb83          	ld	s7,72(a1)
    80002916:	0505bc03          	ld	s8,80(a1)
    8000291a:	0585bc83          	ld	s9,88(a1)
    8000291e:	0605bd03          	ld	s10,96(a1)
    80002922:	0685bd83          	ld	s11,104(a1)
    80002926:	8082                	ret

0000000080002928 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002928:	1141                	addi	sp,sp,-16
    8000292a:	e406                	sd	ra,8(sp)
    8000292c:	e022                	sd	s0,0(sp)
    8000292e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002930:	00006597          	auipc	a1,0x6
    80002934:	a3858593          	addi	a1,a1,-1480 # 80008368 <states.0+0x28>
    80002938:	00015517          	auipc	a0,0x15
    8000293c:	03050513          	addi	a0,a0,48 # 80017968 <tickslock>
    80002940:	ffffe097          	auipc	ra,0xffffe
    80002944:	22e080e7          	jalr	558(ra) # 80000b6e <initlock>
}
    80002948:	60a2                	ld	ra,8(sp)
    8000294a:	6402                	ld	s0,0(sp)
    8000294c:	0141                	addi	sp,sp,16
    8000294e:	8082                	ret

0000000080002950 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002950:	1141                	addi	sp,sp,-16
    80002952:	e422                	sd	s0,8(sp)
    80002954:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002956:	00003797          	auipc	a5,0x3
    8000295a:	51a78793          	addi	a5,a5,1306 # 80005e70 <kernelvec>
    8000295e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002962:	6422                	ld	s0,8(sp)
    80002964:	0141                	addi	sp,sp,16
    80002966:	8082                	ret

0000000080002968 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002968:	1141                	addi	sp,sp,-16
    8000296a:	e406                	sd	ra,8(sp)
    8000296c:	e022                	sd	s0,0(sp)
    8000296e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002970:	fffff097          	auipc	ra,0xfffff
    80002974:	1e0080e7          	jalr	480(ra) # 80001b50 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002978:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000297c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000297e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002982:	00004617          	auipc	a2,0x4
    80002986:	67e60613          	addi	a2,a2,1662 # 80007000 <_trampoline>
    8000298a:	00004697          	auipc	a3,0x4
    8000298e:	67668693          	addi	a3,a3,1654 # 80007000 <_trampoline>
    80002992:	8e91                	sub	a3,a3,a2
    80002994:	040007b7          	lui	a5,0x4000
    80002998:	17fd                	addi	a5,a5,-1
    8000299a:	07b2                	slli	a5,a5,0xc
    8000299c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000299e:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029a2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029a4:	180026f3          	csrr	a3,satp
    800029a8:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029aa:	6d38                	ld	a4,88(a0)
    800029ac:	6134                	ld	a3,64(a0)
    800029ae:	6585                	lui	a1,0x1
    800029b0:	96ae                	add	a3,a3,a1
    800029b2:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029b4:	6d38                	ld	a4,88(a0)
    800029b6:	00000697          	auipc	a3,0x0
    800029ba:	13868693          	addi	a3,a3,312 # 80002aee <usertrap>
    800029be:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800029c0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029c2:	8692                	mv	a3,tp
    800029c4:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c6:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029ca:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029ce:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029d2:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029d6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029d8:	6f18                	ld	a4,24(a4)
    800029da:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800029de:	692c                	ld	a1,80(a0)
    800029e0:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800029e2:	00004717          	auipc	a4,0x4
    800029e6:	6ae70713          	addi	a4,a4,1710 # 80007090 <userret>
    800029ea:	8f11                	sub	a4,a4,a2
    800029ec:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800029ee:	577d                	li	a4,-1
    800029f0:	177e                	slli	a4,a4,0x3f
    800029f2:	8dd9                	or	a1,a1,a4
    800029f4:	02000537          	lui	a0,0x2000
    800029f8:	157d                	addi	a0,a0,-1
    800029fa:	0536                	slli	a0,a0,0xd
    800029fc:	9782                	jalr	a5
}
    800029fe:	60a2                	ld	ra,8(sp)
    80002a00:	6402                	ld	s0,0(sp)
    80002a02:	0141                	addi	sp,sp,16
    80002a04:	8082                	ret

0000000080002a06 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a06:	1101                	addi	sp,sp,-32
    80002a08:	ec06                	sd	ra,24(sp)
    80002a0a:	e822                	sd	s0,16(sp)
    80002a0c:	e426                	sd	s1,8(sp)
    80002a0e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a10:	00015497          	auipc	s1,0x15
    80002a14:	f5848493          	addi	s1,s1,-168 # 80017968 <tickslock>
    80002a18:	8526                	mv	a0,s1
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	1e4080e7          	jalr	484(ra) # 80000bfe <acquire>
  ticks++;
    80002a22:	00006517          	auipc	a0,0x6
    80002a26:	5fe50513          	addi	a0,a0,1534 # 80009020 <ticks>
    80002a2a:	411c                	lw	a5,0(a0)
    80002a2c:	2785                	addiw	a5,a5,1
    80002a2e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a30:	00000097          	auipc	ra,0x0
    80002a34:	c5a080e7          	jalr	-934(ra) # 8000268a <wakeup>
  release(&tickslock);
    80002a38:	8526                	mv	a0,s1
    80002a3a:	ffffe097          	auipc	ra,0xffffe
    80002a3e:	278080e7          	jalr	632(ra) # 80000cb2 <release>
}
    80002a42:	60e2                	ld	ra,24(sp)
    80002a44:	6442                	ld	s0,16(sp)
    80002a46:	64a2                	ld	s1,8(sp)
    80002a48:	6105                	addi	sp,sp,32
    80002a4a:	8082                	ret

0000000080002a4c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a4c:	1101                	addi	sp,sp,-32
    80002a4e:	ec06                	sd	ra,24(sp)
    80002a50:	e822                	sd	s0,16(sp)
    80002a52:	e426                	sd	s1,8(sp)
    80002a54:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a56:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002a5a:	00074d63          	bltz	a4,80002a74 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002a5e:	57fd                	li	a5,-1
    80002a60:	17fe                	slli	a5,a5,0x3f
    80002a62:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a64:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a66:	06f70363          	beq	a4,a5,80002acc <devintr+0x80>
  }
}
    80002a6a:	60e2                	ld	ra,24(sp)
    80002a6c:	6442                	ld	s0,16(sp)
    80002a6e:	64a2                	ld	s1,8(sp)
    80002a70:	6105                	addi	sp,sp,32
    80002a72:	8082                	ret
     (scause & 0xff) == 9){
    80002a74:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a78:	46a5                	li	a3,9
    80002a7a:	fed792e3          	bne	a5,a3,80002a5e <devintr+0x12>
    int irq = plic_claim();
    80002a7e:	00003097          	auipc	ra,0x3
    80002a82:	4fa080e7          	jalr	1274(ra) # 80005f78 <plic_claim>
    80002a86:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a88:	47a9                	li	a5,10
    80002a8a:	02f50763          	beq	a0,a5,80002ab8 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002a8e:	4785                	li	a5,1
    80002a90:	02f50963          	beq	a0,a5,80002ac2 <devintr+0x76>
    return 1;
    80002a94:	4505                	li	a0,1
    } else if(irq){
    80002a96:	d8f1                	beqz	s1,80002a6a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a98:	85a6                	mv	a1,s1
    80002a9a:	00006517          	auipc	a0,0x6
    80002a9e:	8d650513          	addi	a0,a0,-1834 # 80008370 <states.0+0x30>
    80002aa2:	ffffe097          	auipc	ra,0xffffe
    80002aa6:	aea080e7          	jalr	-1302(ra) # 8000058c <printf>
      plic_complete(irq);
    80002aaa:	8526                	mv	a0,s1
    80002aac:	00003097          	auipc	ra,0x3
    80002ab0:	4f0080e7          	jalr	1264(ra) # 80005f9c <plic_complete>
    return 1;
    80002ab4:	4505                	li	a0,1
    80002ab6:	bf55                	j	80002a6a <devintr+0x1e>
      uartintr();
    80002ab8:	ffffe097          	auipc	ra,0xffffe
    80002abc:	f0a080e7          	jalr	-246(ra) # 800009c2 <uartintr>
    80002ac0:	b7ed                	j	80002aaa <devintr+0x5e>
      virtio_disk_intr();
    80002ac2:	00004097          	auipc	ra,0x4
    80002ac6:	954080e7          	jalr	-1708(ra) # 80006416 <virtio_disk_intr>
    80002aca:	b7c5                	j	80002aaa <devintr+0x5e>
    if(cpuid() == 0){
    80002acc:	fffff097          	auipc	ra,0xfffff
    80002ad0:	058080e7          	jalr	88(ra) # 80001b24 <cpuid>
    80002ad4:	c901                	beqz	a0,80002ae4 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002ad6:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ada:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002adc:	14479073          	csrw	sip,a5
    return 2;
    80002ae0:	4509                	li	a0,2
    80002ae2:	b761                	j	80002a6a <devintr+0x1e>
      clockintr();
    80002ae4:	00000097          	auipc	ra,0x0
    80002ae8:	f22080e7          	jalr	-222(ra) # 80002a06 <clockintr>
    80002aec:	b7ed                	j	80002ad6 <devintr+0x8a>

0000000080002aee <usertrap>:
{
    80002aee:	1101                	addi	sp,sp,-32
    80002af0:	ec06                	sd	ra,24(sp)
    80002af2:	e822                	sd	s0,16(sp)
    80002af4:	e426                	sd	s1,8(sp)
    80002af6:	e04a                	sd	s2,0(sp)
    80002af8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002afa:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002afe:	1007f793          	andi	a5,a5,256
    80002b02:	e3ad                	bnez	a5,80002b64 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b04:	00003797          	auipc	a5,0x3
    80002b08:	36c78793          	addi	a5,a5,876 # 80005e70 <kernelvec>
    80002b0c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b10:	fffff097          	auipc	ra,0xfffff
    80002b14:	040080e7          	jalr	64(ra) # 80001b50 <myproc>
    80002b18:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b1a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b1c:	14102773          	csrr	a4,sepc
    80002b20:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b22:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b26:	47a1                	li	a5,8
    80002b28:	04f71c63          	bne	a4,a5,80002b80 <usertrap+0x92>
    if(p->killed)
    80002b2c:	591c                	lw	a5,48(a0)
    80002b2e:	e3b9                	bnez	a5,80002b74 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002b30:	6cb8                	ld	a4,88(s1)
    80002b32:	6f1c                	ld	a5,24(a4)
    80002b34:	0791                	addi	a5,a5,4
    80002b36:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b38:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b3c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b40:	10079073          	csrw	sstatus,a5
    syscall();
    80002b44:	00000097          	auipc	ra,0x0
    80002b48:	2e0080e7          	jalr	736(ra) # 80002e24 <syscall>
  if(p->killed)
    80002b4c:	589c                	lw	a5,48(s1)
    80002b4e:	ebc1                	bnez	a5,80002bde <usertrap+0xf0>
  usertrapret();
    80002b50:	00000097          	auipc	ra,0x0
    80002b54:	e18080e7          	jalr	-488(ra) # 80002968 <usertrapret>
}
    80002b58:	60e2                	ld	ra,24(sp)
    80002b5a:	6442                	ld	s0,16(sp)
    80002b5c:	64a2                	ld	s1,8(sp)
    80002b5e:	6902                	ld	s2,0(sp)
    80002b60:	6105                	addi	sp,sp,32
    80002b62:	8082                	ret
    panic("usertrap: not from user mode");
    80002b64:	00006517          	auipc	a0,0x6
    80002b68:	82c50513          	addi	a0,a0,-2004 # 80008390 <states.0+0x50>
    80002b6c:	ffffe097          	auipc	ra,0xffffe
    80002b70:	9d6080e7          	jalr	-1578(ra) # 80000542 <panic>
      exit(-1);
    80002b74:	557d                	li	a0,-1
    80002b76:	00000097          	auipc	ra,0x0
    80002b7a:	84e080e7          	jalr	-1970(ra) # 800023c4 <exit>
    80002b7e:	bf4d                	j	80002b30 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002b80:	00000097          	auipc	ra,0x0
    80002b84:	ecc080e7          	jalr	-308(ra) # 80002a4c <devintr>
    80002b88:	892a                	mv	s2,a0
    80002b8a:	c501                	beqz	a0,80002b92 <usertrap+0xa4>
  if(p->killed)
    80002b8c:	589c                	lw	a5,48(s1)
    80002b8e:	c3a1                	beqz	a5,80002bce <usertrap+0xe0>
    80002b90:	a815                	j	80002bc4 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b92:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b96:	5c90                	lw	a2,56(s1)
    80002b98:	00006517          	auipc	a0,0x6
    80002b9c:	81850513          	addi	a0,a0,-2024 # 800083b0 <states.0+0x70>
    80002ba0:	ffffe097          	auipc	ra,0xffffe
    80002ba4:	9ec080e7          	jalr	-1556(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ba8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bac:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bb0:	00006517          	auipc	a0,0x6
    80002bb4:	83050513          	addi	a0,a0,-2000 # 800083e0 <states.0+0xa0>
    80002bb8:	ffffe097          	auipc	ra,0xffffe
    80002bbc:	9d4080e7          	jalr	-1580(ra) # 8000058c <printf>
    p->killed = 1;
    80002bc0:	4785                	li	a5,1
    80002bc2:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002bc4:	557d                	li	a0,-1
    80002bc6:	fffff097          	auipc	ra,0xfffff
    80002bca:	7fe080e7          	jalr	2046(ra) # 800023c4 <exit>
  if(which_dev == 2)
    80002bce:	4789                	li	a5,2
    80002bd0:	f8f910e3          	bne	s2,a5,80002b50 <usertrap+0x62>
    yield();
    80002bd4:	00000097          	auipc	ra,0x0
    80002bd8:	8fa080e7          	jalr	-1798(ra) # 800024ce <yield>
    80002bdc:	bf95                	j	80002b50 <usertrap+0x62>
  int which_dev = 0;
    80002bde:	4901                	li	s2,0
    80002be0:	b7d5                	j	80002bc4 <usertrap+0xd6>

0000000080002be2 <kerneltrap>:
{
    80002be2:	7179                	addi	sp,sp,-48
    80002be4:	f406                	sd	ra,40(sp)
    80002be6:	f022                	sd	s0,32(sp)
    80002be8:	ec26                	sd	s1,24(sp)
    80002bea:	e84a                	sd	s2,16(sp)
    80002bec:	e44e                	sd	s3,8(sp)
    80002bee:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bf0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bf4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bf8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002bfc:	1004f793          	andi	a5,s1,256
    80002c00:	cb85                	beqz	a5,80002c30 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c02:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c06:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c08:	ef85                	bnez	a5,80002c40 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c0a:	00000097          	auipc	ra,0x0
    80002c0e:	e42080e7          	jalr	-446(ra) # 80002a4c <devintr>
    80002c12:	cd1d                	beqz	a0,80002c50 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c14:	4789                	li	a5,2
    80002c16:	06f50a63          	beq	a0,a5,80002c8a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c1a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c1e:	10049073          	csrw	sstatus,s1
}
    80002c22:	70a2                	ld	ra,40(sp)
    80002c24:	7402                	ld	s0,32(sp)
    80002c26:	64e2                	ld	s1,24(sp)
    80002c28:	6942                	ld	s2,16(sp)
    80002c2a:	69a2                	ld	s3,8(sp)
    80002c2c:	6145                	addi	sp,sp,48
    80002c2e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c30:	00005517          	auipc	a0,0x5
    80002c34:	7d050513          	addi	a0,a0,2000 # 80008400 <states.0+0xc0>
    80002c38:	ffffe097          	auipc	ra,0xffffe
    80002c3c:	90a080e7          	jalr	-1782(ra) # 80000542 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c40:	00005517          	auipc	a0,0x5
    80002c44:	7e850513          	addi	a0,a0,2024 # 80008428 <states.0+0xe8>
    80002c48:	ffffe097          	auipc	ra,0xffffe
    80002c4c:	8fa080e7          	jalr	-1798(ra) # 80000542 <panic>
    printf("scause %p\n", scause);
    80002c50:	85ce                	mv	a1,s3
    80002c52:	00005517          	auipc	a0,0x5
    80002c56:	7f650513          	addi	a0,a0,2038 # 80008448 <states.0+0x108>
    80002c5a:	ffffe097          	auipc	ra,0xffffe
    80002c5e:	932080e7          	jalr	-1742(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c62:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c66:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c6a:	00005517          	auipc	a0,0x5
    80002c6e:	7ee50513          	addi	a0,a0,2030 # 80008458 <states.0+0x118>
    80002c72:	ffffe097          	auipc	ra,0xffffe
    80002c76:	91a080e7          	jalr	-1766(ra) # 8000058c <printf>
    panic("kerneltrap");
    80002c7a:	00005517          	auipc	a0,0x5
    80002c7e:	7f650513          	addi	a0,a0,2038 # 80008470 <states.0+0x130>
    80002c82:	ffffe097          	auipc	ra,0xffffe
    80002c86:	8c0080e7          	jalr	-1856(ra) # 80000542 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c8a:	fffff097          	auipc	ra,0xfffff
    80002c8e:	ec6080e7          	jalr	-314(ra) # 80001b50 <myproc>
    80002c92:	d541                	beqz	a0,80002c1a <kerneltrap+0x38>
    80002c94:	fffff097          	auipc	ra,0xfffff
    80002c98:	ebc080e7          	jalr	-324(ra) # 80001b50 <myproc>
    80002c9c:	4d18                	lw	a4,24(a0)
    80002c9e:	478d                	li	a5,3
    80002ca0:	f6f71de3          	bne	a4,a5,80002c1a <kerneltrap+0x38>
    yield();
    80002ca4:	00000097          	auipc	ra,0x0
    80002ca8:	82a080e7          	jalr	-2006(ra) # 800024ce <yield>
    80002cac:	b7bd                	j	80002c1a <kerneltrap+0x38>

0000000080002cae <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cae:	1101                	addi	sp,sp,-32
    80002cb0:	ec06                	sd	ra,24(sp)
    80002cb2:	e822                	sd	s0,16(sp)
    80002cb4:	e426                	sd	s1,8(sp)
    80002cb6:	1000                	addi	s0,sp,32
    80002cb8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cba:	fffff097          	auipc	ra,0xfffff
    80002cbe:	e96080e7          	jalr	-362(ra) # 80001b50 <myproc>
  switch (n) {
    80002cc2:	4795                	li	a5,5
    80002cc4:	0497e163          	bltu	a5,s1,80002d06 <argraw+0x58>
    80002cc8:	048a                	slli	s1,s1,0x2
    80002cca:	00005717          	auipc	a4,0x5
    80002cce:	7de70713          	addi	a4,a4,2014 # 800084a8 <states.0+0x168>
    80002cd2:	94ba                	add	s1,s1,a4
    80002cd4:	409c                	lw	a5,0(s1)
    80002cd6:	97ba                	add	a5,a5,a4
    80002cd8:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002cda:	6d3c                	ld	a5,88(a0)
    80002cdc:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cde:	60e2                	ld	ra,24(sp)
    80002ce0:	6442                	ld	s0,16(sp)
    80002ce2:	64a2                	ld	s1,8(sp)
    80002ce4:	6105                	addi	sp,sp,32
    80002ce6:	8082                	ret
    return p->trapframe->a1;
    80002ce8:	6d3c                	ld	a5,88(a0)
    80002cea:	7fa8                	ld	a0,120(a5)
    80002cec:	bfcd                	j	80002cde <argraw+0x30>
    return p->trapframe->a2;
    80002cee:	6d3c                	ld	a5,88(a0)
    80002cf0:	63c8                	ld	a0,128(a5)
    80002cf2:	b7f5                	j	80002cde <argraw+0x30>
    return p->trapframe->a3;
    80002cf4:	6d3c                	ld	a5,88(a0)
    80002cf6:	67c8                	ld	a0,136(a5)
    80002cf8:	b7dd                	j	80002cde <argraw+0x30>
    return p->trapframe->a4;
    80002cfa:	6d3c                	ld	a5,88(a0)
    80002cfc:	6bc8                	ld	a0,144(a5)
    80002cfe:	b7c5                	j	80002cde <argraw+0x30>
    return p->trapframe->a5;
    80002d00:	6d3c                	ld	a5,88(a0)
    80002d02:	6fc8                	ld	a0,152(a5)
    80002d04:	bfe9                	j	80002cde <argraw+0x30>
  panic("argraw");
    80002d06:	00005517          	auipc	a0,0x5
    80002d0a:	77a50513          	addi	a0,a0,1914 # 80008480 <states.0+0x140>
    80002d0e:	ffffe097          	auipc	ra,0xffffe
    80002d12:	834080e7          	jalr	-1996(ra) # 80000542 <panic>

0000000080002d16 <fetchaddr>:
{
    80002d16:	1101                	addi	sp,sp,-32
    80002d18:	ec06                	sd	ra,24(sp)
    80002d1a:	e822                	sd	s0,16(sp)
    80002d1c:	e426                	sd	s1,8(sp)
    80002d1e:	e04a                	sd	s2,0(sp)
    80002d20:	1000                	addi	s0,sp,32
    80002d22:	84aa                	mv	s1,a0
    80002d24:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d26:	fffff097          	auipc	ra,0xfffff
    80002d2a:	e2a080e7          	jalr	-470(ra) # 80001b50 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d2e:	653c                	ld	a5,72(a0)
    80002d30:	02f4f863          	bgeu	s1,a5,80002d60 <fetchaddr+0x4a>
    80002d34:	00848713          	addi	a4,s1,8
    80002d38:	02e7e663          	bltu	a5,a4,80002d64 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d3c:	46a1                	li	a3,8
    80002d3e:	8626                	mv	a2,s1
    80002d40:	85ca                	mv	a1,s2
    80002d42:	6928                	ld	a0,80(a0)
    80002d44:	fffff097          	auipc	ra,0xfffff
    80002d48:	a16080e7          	jalr	-1514(ra) # 8000175a <copyin>
    80002d4c:	00a03533          	snez	a0,a0
    80002d50:	40a00533          	neg	a0,a0
}
    80002d54:	60e2                	ld	ra,24(sp)
    80002d56:	6442                	ld	s0,16(sp)
    80002d58:	64a2                	ld	s1,8(sp)
    80002d5a:	6902                	ld	s2,0(sp)
    80002d5c:	6105                	addi	sp,sp,32
    80002d5e:	8082                	ret
    return -1;
    80002d60:	557d                	li	a0,-1
    80002d62:	bfcd                	j	80002d54 <fetchaddr+0x3e>
    80002d64:	557d                	li	a0,-1
    80002d66:	b7fd                	j	80002d54 <fetchaddr+0x3e>

0000000080002d68 <fetchstr>:
{
    80002d68:	7179                	addi	sp,sp,-48
    80002d6a:	f406                	sd	ra,40(sp)
    80002d6c:	f022                	sd	s0,32(sp)
    80002d6e:	ec26                	sd	s1,24(sp)
    80002d70:	e84a                	sd	s2,16(sp)
    80002d72:	e44e                	sd	s3,8(sp)
    80002d74:	1800                	addi	s0,sp,48
    80002d76:	892a                	mv	s2,a0
    80002d78:	84ae                	mv	s1,a1
    80002d7a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d7c:	fffff097          	auipc	ra,0xfffff
    80002d80:	dd4080e7          	jalr	-556(ra) # 80001b50 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002d84:	86ce                	mv	a3,s3
    80002d86:	864a                	mv	a2,s2
    80002d88:	85a6                	mv	a1,s1
    80002d8a:	6928                	ld	a0,80(a0)
    80002d8c:	fffff097          	auipc	ra,0xfffff
    80002d90:	9e6080e7          	jalr	-1562(ra) # 80001772 <copyinstr>
  if(err < 0)
    80002d94:	00054763          	bltz	a0,80002da2 <fetchstr+0x3a>
  return strlen(buf);
    80002d98:	8526                	mv	a0,s1
    80002d9a:	ffffe097          	auipc	ra,0xffffe
    80002d9e:	0e4080e7          	jalr	228(ra) # 80000e7e <strlen>
}
    80002da2:	70a2                	ld	ra,40(sp)
    80002da4:	7402                	ld	s0,32(sp)
    80002da6:	64e2                	ld	s1,24(sp)
    80002da8:	6942                	ld	s2,16(sp)
    80002daa:	69a2                	ld	s3,8(sp)
    80002dac:	6145                	addi	sp,sp,48
    80002dae:	8082                	ret

0000000080002db0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002db0:	1101                	addi	sp,sp,-32
    80002db2:	ec06                	sd	ra,24(sp)
    80002db4:	e822                	sd	s0,16(sp)
    80002db6:	e426                	sd	s1,8(sp)
    80002db8:	1000                	addi	s0,sp,32
    80002dba:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dbc:	00000097          	auipc	ra,0x0
    80002dc0:	ef2080e7          	jalr	-270(ra) # 80002cae <argraw>
    80002dc4:	c088                	sw	a0,0(s1)
  return 0;
}
    80002dc6:	4501                	li	a0,0
    80002dc8:	60e2                	ld	ra,24(sp)
    80002dca:	6442                	ld	s0,16(sp)
    80002dcc:	64a2                	ld	s1,8(sp)
    80002dce:	6105                	addi	sp,sp,32
    80002dd0:	8082                	ret

0000000080002dd2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002dd2:	1101                	addi	sp,sp,-32
    80002dd4:	ec06                	sd	ra,24(sp)
    80002dd6:	e822                	sd	s0,16(sp)
    80002dd8:	e426                	sd	s1,8(sp)
    80002dda:	1000                	addi	s0,sp,32
    80002ddc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dde:	00000097          	auipc	ra,0x0
    80002de2:	ed0080e7          	jalr	-304(ra) # 80002cae <argraw>
    80002de6:	e088                	sd	a0,0(s1)
  return 0;
}
    80002de8:	4501                	li	a0,0
    80002dea:	60e2                	ld	ra,24(sp)
    80002dec:	6442                	ld	s0,16(sp)
    80002dee:	64a2                	ld	s1,8(sp)
    80002df0:	6105                	addi	sp,sp,32
    80002df2:	8082                	ret

0000000080002df4 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002df4:	1101                	addi	sp,sp,-32
    80002df6:	ec06                	sd	ra,24(sp)
    80002df8:	e822                	sd	s0,16(sp)
    80002dfa:	e426                	sd	s1,8(sp)
    80002dfc:	e04a                	sd	s2,0(sp)
    80002dfe:	1000                	addi	s0,sp,32
    80002e00:	84ae                	mv	s1,a1
    80002e02:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002e04:	00000097          	auipc	ra,0x0
    80002e08:	eaa080e7          	jalr	-342(ra) # 80002cae <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e0c:	864a                	mv	a2,s2
    80002e0e:	85a6                	mv	a1,s1
    80002e10:	00000097          	auipc	ra,0x0
    80002e14:	f58080e7          	jalr	-168(ra) # 80002d68 <fetchstr>
}
    80002e18:	60e2                	ld	ra,24(sp)
    80002e1a:	6442                	ld	s0,16(sp)
    80002e1c:	64a2                	ld	s1,8(sp)
    80002e1e:	6902                	ld	s2,0(sp)
    80002e20:	6105                	addi	sp,sp,32
    80002e22:	8082                	ret

0000000080002e24 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002e24:	1101                	addi	sp,sp,-32
    80002e26:	ec06                	sd	ra,24(sp)
    80002e28:	e822                	sd	s0,16(sp)
    80002e2a:	e426                	sd	s1,8(sp)
    80002e2c:	e04a                	sd	s2,0(sp)
    80002e2e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e30:	fffff097          	auipc	ra,0xfffff
    80002e34:	d20080e7          	jalr	-736(ra) # 80001b50 <myproc>
    80002e38:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e3a:	05853903          	ld	s2,88(a0)
    80002e3e:	0a893783          	ld	a5,168(s2)
    80002e42:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e46:	37fd                	addiw	a5,a5,-1
    80002e48:	4751                	li	a4,20
    80002e4a:	00f76f63          	bltu	a4,a5,80002e68 <syscall+0x44>
    80002e4e:	00369713          	slli	a4,a3,0x3
    80002e52:	00005797          	auipc	a5,0x5
    80002e56:	66e78793          	addi	a5,a5,1646 # 800084c0 <syscalls>
    80002e5a:	97ba                	add	a5,a5,a4
    80002e5c:	639c                	ld	a5,0(a5)
    80002e5e:	c789                	beqz	a5,80002e68 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002e60:	9782                	jalr	a5
    80002e62:	06a93823          	sd	a0,112(s2)
    80002e66:	a839                	j	80002e84 <syscall+0x60>
  }
  
   else {
    printf("%d %s: unknown sys call %d\n",
    80002e68:	15848613          	addi	a2,s1,344
    80002e6c:	5c8c                	lw	a1,56(s1)
    80002e6e:	00005517          	auipc	a0,0x5
    80002e72:	61a50513          	addi	a0,a0,1562 # 80008488 <states.0+0x148>
    80002e76:	ffffd097          	auipc	ra,0xffffd
    80002e7a:	716080e7          	jalr	1814(ra) # 8000058c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e7e:	6cbc                	ld	a5,88(s1)
    80002e80:	577d                	li	a4,-1
    80002e82:	fbb8                	sd	a4,112(a5)
  }
}
    80002e84:	60e2                	ld	ra,24(sp)
    80002e86:	6442                	ld	s0,16(sp)
    80002e88:	64a2                	ld	s1,8(sp)
    80002e8a:	6902                	ld	s2,0(sp)
    80002e8c:	6105                	addi	sp,sp,32
    80002e8e:	8082                	ret

0000000080002e90 <sys_exit>:
#include "proc.h"


uint64
sys_exit(void)
{
    80002e90:	1101                	addi	sp,sp,-32
    80002e92:	ec06                	sd	ra,24(sp)
    80002e94:	e822                	sd	s0,16(sp)
    80002e96:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002e98:	fec40593          	addi	a1,s0,-20
    80002e9c:	4501                	li	a0,0
    80002e9e:	00000097          	auipc	ra,0x0
    80002ea2:	f12080e7          	jalr	-238(ra) # 80002db0 <argint>
    return -1;
    80002ea6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ea8:	00054963          	bltz	a0,80002eba <sys_exit+0x2a>
  exit(n);
    80002eac:	fec42503          	lw	a0,-20(s0)
    80002eb0:	fffff097          	auipc	ra,0xfffff
    80002eb4:	514080e7          	jalr	1300(ra) # 800023c4 <exit>
  return 0;  // not reached
    80002eb8:	4781                	li	a5,0
}
    80002eba:	853e                	mv	a0,a5
    80002ebc:	60e2                	ld	ra,24(sp)
    80002ebe:	6442                	ld	s0,16(sp)
    80002ec0:	6105                	addi	sp,sp,32
    80002ec2:	8082                	ret

0000000080002ec4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ec4:	1141                	addi	sp,sp,-16
    80002ec6:	e406                	sd	ra,8(sp)
    80002ec8:	e022                	sd	s0,0(sp)
    80002eca:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ecc:	fffff097          	auipc	ra,0xfffff
    80002ed0:	c84080e7          	jalr	-892(ra) # 80001b50 <myproc>
}
    80002ed4:	5d08                	lw	a0,56(a0)
    80002ed6:	60a2                	ld	ra,8(sp)
    80002ed8:	6402                	ld	s0,0(sp)
    80002eda:	0141                	addi	sp,sp,16
    80002edc:	8082                	ret

0000000080002ede <sys_fork>:

uint64
sys_fork(void)
{
    80002ede:	1141                	addi	sp,sp,-16
    80002ee0:	e406                	sd	ra,8(sp)
    80002ee2:	e022                	sd	s0,0(sp)
    80002ee4:	0800                	addi	s0,sp,16
  return fork();
    80002ee6:	fffff097          	auipc	ra,0xfffff
    80002eea:	19c080e7          	jalr	412(ra) # 80002082 <fork>
}
    80002eee:	60a2                	ld	ra,8(sp)
    80002ef0:	6402                	ld	s0,0(sp)
    80002ef2:	0141                	addi	sp,sp,16
    80002ef4:	8082                	ret

0000000080002ef6 <sys_wait>:

uint64
sys_wait(void)
{
    80002ef6:	1101                	addi	sp,sp,-32
    80002ef8:	ec06                	sd	ra,24(sp)
    80002efa:	e822                	sd	s0,16(sp)
    80002efc:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002efe:	fe840593          	addi	a1,s0,-24
    80002f02:	4501                	li	a0,0
    80002f04:	00000097          	auipc	ra,0x0
    80002f08:	ece080e7          	jalr	-306(ra) # 80002dd2 <argaddr>
    80002f0c:	87aa                	mv	a5,a0
    return -1;
    80002f0e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002f10:	0007c863          	bltz	a5,80002f20 <sys_wait+0x2a>
  return wait(p);
    80002f14:	fe843503          	ld	a0,-24(s0)
    80002f18:	fffff097          	auipc	ra,0xfffff
    80002f1c:	670080e7          	jalr	1648(ra) # 80002588 <wait>
}
    80002f20:	60e2                	ld	ra,24(sp)
    80002f22:	6442                	ld	s0,16(sp)
    80002f24:	6105                	addi	sp,sp,32
    80002f26:	8082                	ret

0000000080002f28 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f28:	7179                	addi	sp,sp,-48
    80002f2a:	f406                	sd	ra,40(sp)
    80002f2c:	f022                	sd	s0,32(sp)
    80002f2e:	ec26                	sd	s1,24(sp)
    80002f30:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002f32:	fdc40593          	addi	a1,s0,-36
    80002f36:	4501                	li	a0,0
    80002f38:	00000097          	auipc	ra,0x0
    80002f3c:	e78080e7          	jalr	-392(ra) # 80002db0 <argint>
    return -1;
    80002f40:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002f42:	00054f63          	bltz	a0,80002f60 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002f46:	fffff097          	auipc	ra,0xfffff
    80002f4a:	c0a080e7          	jalr	-1014(ra) # 80001b50 <myproc>
    80002f4e:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002f50:	fdc42503          	lw	a0,-36(s0)
    80002f54:	fffff097          	auipc	ra,0xfffff
    80002f58:	062080e7          	jalr	98(ra) # 80001fb6 <growproc>
    80002f5c:	00054863          	bltz	a0,80002f6c <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002f60:	8526                	mv	a0,s1
    80002f62:	70a2                	ld	ra,40(sp)
    80002f64:	7402                	ld	s0,32(sp)
    80002f66:	64e2                	ld	s1,24(sp)
    80002f68:	6145                	addi	sp,sp,48
    80002f6a:	8082                	ret
    return -1;
    80002f6c:	54fd                	li	s1,-1
    80002f6e:	bfcd                	j	80002f60 <sys_sbrk+0x38>

0000000080002f70 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f70:	7139                	addi	sp,sp,-64
    80002f72:	fc06                	sd	ra,56(sp)
    80002f74:	f822                	sd	s0,48(sp)
    80002f76:	f426                	sd	s1,40(sp)
    80002f78:	f04a                	sd	s2,32(sp)
    80002f7a:	ec4e                	sd	s3,24(sp)
    80002f7c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002f7e:	fcc40593          	addi	a1,s0,-52
    80002f82:	4501                	li	a0,0
    80002f84:	00000097          	auipc	ra,0x0
    80002f88:	e2c080e7          	jalr	-468(ra) # 80002db0 <argint>
    return -1;
    80002f8c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f8e:	06054563          	bltz	a0,80002ff8 <sys_sleep+0x88>
  acquire(&tickslock);
    80002f92:	00015517          	auipc	a0,0x15
    80002f96:	9d650513          	addi	a0,a0,-1578 # 80017968 <tickslock>
    80002f9a:	ffffe097          	auipc	ra,0xffffe
    80002f9e:	c64080e7          	jalr	-924(ra) # 80000bfe <acquire>
  ticks0 = ticks;
    80002fa2:	00006917          	auipc	s2,0x6
    80002fa6:	07e92903          	lw	s2,126(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002faa:	fcc42783          	lw	a5,-52(s0)
    80002fae:	cf85                	beqz	a5,80002fe6 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fb0:	00015997          	auipc	s3,0x15
    80002fb4:	9b898993          	addi	s3,s3,-1608 # 80017968 <tickslock>
    80002fb8:	00006497          	auipc	s1,0x6
    80002fbc:	06848493          	addi	s1,s1,104 # 80009020 <ticks>
    if(myproc()->killed){
    80002fc0:	fffff097          	auipc	ra,0xfffff
    80002fc4:	b90080e7          	jalr	-1136(ra) # 80001b50 <myproc>
    80002fc8:	591c                	lw	a5,48(a0)
    80002fca:	ef9d                	bnez	a5,80003008 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002fcc:	85ce                	mv	a1,s3
    80002fce:	8526                	mv	a0,s1
    80002fd0:	fffff097          	auipc	ra,0xfffff
    80002fd4:	53a080e7          	jalr	1338(ra) # 8000250a <sleep>
  while(ticks - ticks0 < n){
    80002fd8:	409c                	lw	a5,0(s1)
    80002fda:	412787bb          	subw	a5,a5,s2
    80002fde:	fcc42703          	lw	a4,-52(s0)
    80002fe2:	fce7efe3          	bltu	a5,a4,80002fc0 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002fe6:	00015517          	auipc	a0,0x15
    80002fea:	98250513          	addi	a0,a0,-1662 # 80017968 <tickslock>
    80002fee:	ffffe097          	auipc	ra,0xffffe
    80002ff2:	cc4080e7          	jalr	-828(ra) # 80000cb2 <release>
  return 0;
    80002ff6:	4781                	li	a5,0
}
    80002ff8:	853e                	mv	a0,a5
    80002ffa:	70e2                	ld	ra,56(sp)
    80002ffc:	7442                	ld	s0,48(sp)
    80002ffe:	74a2                	ld	s1,40(sp)
    80003000:	7902                	ld	s2,32(sp)
    80003002:	69e2                	ld	s3,24(sp)
    80003004:	6121                	addi	sp,sp,64
    80003006:	8082                	ret
      release(&tickslock);
    80003008:	00015517          	auipc	a0,0x15
    8000300c:	96050513          	addi	a0,a0,-1696 # 80017968 <tickslock>
    80003010:	ffffe097          	auipc	ra,0xffffe
    80003014:	ca2080e7          	jalr	-862(ra) # 80000cb2 <release>
      return -1;
    80003018:	57fd                	li	a5,-1
    8000301a:	bff9                	j	80002ff8 <sys_sleep+0x88>

000000008000301c <sys_kill>:

uint64
sys_kill(void)
{
    8000301c:	1101                	addi	sp,sp,-32
    8000301e:	ec06                	sd	ra,24(sp)
    80003020:	e822                	sd	s0,16(sp)
    80003022:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003024:	fec40593          	addi	a1,s0,-20
    80003028:	4501                	li	a0,0
    8000302a:	00000097          	auipc	ra,0x0
    8000302e:	d86080e7          	jalr	-634(ra) # 80002db0 <argint>
    80003032:	87aa                	mv	a5,a0
    return -1;
    80003034:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003036:	0007c863          	bltz	a5,80003046 <sys_kill+0x2a>
  return kill(pid);
    8000303a:	fec42503          	lw	a0,-20(s0)
    8000303e:	fffff097          	auipc	ra,0xfffff
    80003042:	6b6080e7          	jalr	1718(ra) # 800026f4 <kill>
}
    80003046:	60e2                	ld	ra,24(sp)
    80003048:	6442                	ld	s0,16(sp)
    8000304a:	6105                	addi	sp,sp,32
    8000304c:	8082                	ret

000000008000304e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000304e:	1101                	addi	sp,sp,-32
    80003050:	ec06                	sd	ra,24(sp)
    80003052:	e822                	sd	s0,16(sp)
    80003054:	e426                	sd	s1,8(sp)
    80003056:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003058:	00015517          	auipc	a0,0x15
    8000305c:	91050513          	addi	a0,a0,-1776 # 80017968 <tickslock>
    80003060:	ffffe097          	auipc	ra,0xffffe
    80003064:	b9e080e7          	jalr	-1122(ra) # 80000bfe <acquire>
  xticks = ticks;
    80003068:	00006497          	auipc	s1,0x6
    8000306c:	fb84a483          	lw	s1,-72(s1) # 80009020 <ticks>
  release(&tickslock);
    80003070:	00015517          	auipc	a0,0x15
    80003074:	8f850513          	addi	a0,a0,-1800 # 80017968 <tickslock>
    80003078:	ffffe097          	auipc	ra,0xffffe
    8000307c:	c3a080e7          	jalr	-966(ra) # 80000cb2 <release>
  return xticks;
}
    80003080:	02049513          	slli	a0,s1,0x20
    80003084:	9101                	srli	a0,a0,0x20
    80003086:	60e2                	ld	ra,24(sp)
    80003088:	6442                	ld	s0,16(sp)
    8000308a:	64a2                	ld	s1,8(sp)
    8000308c:	6105                	addi	sp,sp,32
    8000308e:	8082                	ret

0000000080003090 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003090:	7179                	addi	sp,sp,-48
    80003092:	f406                	sd	ra,40(sp)
    80003094:	f022                	sd	s0,32(sp)
    80003096:	ec26                	sd	s1,24(sp)
    80003098:	e84a                	sd	s2,16(sp)
    8000309a:	e44e                	sd	s3,8(sp)
    8000309c:	e052                	sd	s4,0(sp)
    8000309e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030a0:	00005597          	auipc	a1,0x5
    800030a4:	4d058593          	addi	a1,a1,1232 # 80008570 <syscalls+0xb0>
    800030a8:	00015517          	auipc	a0,0x15
    800030ac:	8d850513          	addi	a0,a0,-1832 # 80017980 <bcache>
    800030b0:	ffffe097          	auipc	ra,0xffffe
    800030b4:	abe080e7          	jalr	-1346(ra) # 80000b6e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030b8:	0001d797          	auipc	a5,0x1d
    800030bc:	8c878793          	addi	a5,a5,-1848 # 8001f980 <bcache+0x8000>
    800030c0:	0001d717          	auipc	a4,0x1d
    800030c4:	b2870713          	addi	a4,a4,-1240 # 8001fbe8 <bcache+0x8268>
    800030c8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030cc:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030d0:	00015497          	auipc	s1,0x15
    800030d4:	8c848493          	addi	s1,s1,-1848 # 80017998 <bcache+0x18>
    b->next = bcache.head.next;
    800030d8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030da:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030dc:	00005a17          	auipc	s4,0x5
    800030e0:	49ca0a13          	addi	s4,s4,1180 # 80008578 <syscalls+0xb8>
    b->next = bcache.head.next;
    800030e4:	2b893783          	ld	a5,696(s2)
    800030e8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030ea:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030ee:	85d2                	mv	a1,s4
    800030f0:	01048513          	addi	a0,s1,16
    800030f4:	00001097          	auipc	ra,0x1
    800030f8:	4ac080e7          	jalr	1196(ra) # 800045a0 <initsleeplock>
    bcache.head.next->prev = b;
    800030fc:	2b893783          	ld	a5,696(s2)
    80003100:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003102:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003106:	45848493          	addi	s1,s1,1112
    8000310a:	fd349de3          	bne	s1,s3,800030e4 <binit+0x54>
  }
}
    8000310e:	70a2                	ld	ra,40(sp)
    80003110:	7402                	ld	s0,32(sp)
    80003112:	64e2                	ld	s1,24(sp)
    80003114:	6942                	ld	s2,16(sp)
    80003116:	69a2                	ld	s3,8(sp)
    80003118:	6a02                	ld	s4,0(sp)
    8000311a:	6145                	addi	sp,sp,48
    8000311c:	8082                	ret

000000008000311e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000311e:	7179                	addi	sp,sp,-48
    80003120:	f406                	sd	ra,40(sp)
    80003122:	f022                	sd	s0,32(sp)
    80003124:	ec26                	sd	s1,24(sp)
    80003126:	e84a                	sd	s2,16(sp)
    80003128:	e44e                	sd	s3,8(sp)
    8000312a:	1800                	addi	s0,sp,48
    8000312c:	892a                	mv	s2,a0
    8000312e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003130:	00015517          	auipc	a0,0x15
    80003134:	85050513          	addi	a0,a0,-1968 # 80017980 <bcache>
    80003138:	ffffe097          	auipc	ra,0xffffe
    8000313c:	ac6080e7          	jalr	-1338(ra) # 80000bfe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003140:	0001d497          	auipc	s1,0x1d
    80003144:	af84b483          	ld	s1,-1288(s1) # 8001fc38 <bcache+0x82b8>
    80003148:	0001d797          	auipc	a5,0x1d
    8000314c:	aa078793          	addi	a5,a5,-1376 # 8001fbe8 <bcache+0x8268>
    80003150:	02f48f63          	beq	s1,a5,8000318e <bread+0x70>
    80003154:	873e                	mv	a4,a5
    80003156:	a021                	j	8000315e <bread+0x40>
    80003158:	68a4                	ld	s1,80(s1)
    8000315a:	02e48a63          	beq	s1,a4,8000318e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000315e:	449c                	lw	a5,8(s1)
    80003160:	ff279ce3          	bne	a5,s2,80003158 <bread+0x3a>
    80003164:	44dc                	lw	a5,12(s1)
    80003166:	ff3799e3          	bne	a5,s3,80003158 <bread+0x3a>
      b->refcnt++;
    8000316a:	40bc                	lw	a5,64(s1)
    8000316c:	2785                	addiw	a5,a5,1
    8000316e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003170:	00015517          	auipc	a0,0x15
    80003174:	81050513          	addi	a0,a0,-2032 # 80017980 <bcache>
    80003178:	ffffe097          	auipc	ra,0xffffe
    8000317c:	b3a080e7          	jalr	-1222(ra) # 80000cb2 <release>
      acquiresleep(&b->lock);
    80003180:	01048513          	addi	a0,s1,16
    80003184:	00001097          	auipc	ra,0x1
    80003188:	456080e7          	jalr	1110(ra) # 800045da <acquiresleep>
      return b;
    8000318c:	a8b9                	j	800031ea <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000318e:	0001d497          	auipc	s1,0x1d
    80003192:	aa24b483          	ld	s1,-1374(s1) # 8001fc30 <bcache+0x82b0>
    80003196:	0001d797          	auipc	a5,0x1d
    8000319a:	a5278793          	addi	a5,a5,-1454 # 8001fbe8 <bcache+0x8268>
    8000319e:	00f48863          	beq	s1,a5,800031ae <bread+0x90>
    800031a2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031a4:	40bc                	lw	a5,64(s1)
    800031a6:	cf81                	beqz	a5,800031be <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031a8:	64a4                	ld	s1,72(s1)
    800031aa:	fee49de3          	bne	s1,a4,800031a4 <bread+0x86>
  panic("bget: no buffers");
    800031ae:	00005517          	auipc	a0,0x5
    800031b2:	3d250513          	addi	a0,a0,978 # 80008580 <syscalls+0xc0>
    800031b6:	ffffd097          	auipc	ra,0xffffd
    800031ba:	38c080e7          	jalr	908(ra) # 80000542 <panic>
      b->dev = dev;
    800031be:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031c2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031c6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031ca:	4785                	li	a5,1
    800031cc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031ce:	00014517          	auipc	a0,0x14
    800031d2:	7b250513          	addi	a0,a0,1970 # 80017980 <bcache>
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	adc080e7          	jalr	-1316(ra) # 80000cb2 <release>
      acquiresleep(&b->lock);
    800031de:	01048513          	addi	a0,s1,16
    800031e2:	00001097          	auipc	ra,0x1
    800031e6:	3f8080e7          	jalr	1016(ra) # 800045da <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031ea:	409c                	lw	a5,0(s1)
    800031ec:	cb89                	beqz	a5,800031fe <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031ee:	8526                	mv	a0,s1
    800031f0:	70a2                	ld	ra,40(sp)
    800031f2:	7402                	ld	s0,32(sp)
    800031f4:	64e2                	ld	s1,24(sp)
    800031f6:	6942                	ld	s2,16(sp)
    800031f8:	69a2                	ld	s3,8(sp)
    800031fa:	6145                	addi	sp,sp,48
    800031fc:	8082                	ret
    virtio_disk_rw(b, 0);
    800031fe:	4581                	li	a1,0
    80003200:	8526                	mv	a0,s1
    80003202:	00003097          	auipc	ra,0x3
    80003206:	f8a080e7          	jalr	-118(ra) # 8000618c <virtio_disk_rw>
    b->valid = 1;
    8000320a:	4785                	li	a5,1
    8000320c:	c09c                	sw	a5,0(s1)
  return b;
    8000320e:	b7c5                	j	800031ee <bread+0xd0>

0000000080003210 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003210:	1101                	addi	sp,sp,-32
    80003212:	ec06                	sd	ra,24(sp)
    80003214:	e822                	sd	s0,16(sp)
    80003216:	e426                	sd	s1,8(sp)
    80003218:	1000                	addi	s0,sp,32
    8000321a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000321c:	0541                	addi	a0,a0,16
    8000321e:	00001097          	auipc	ra,0x1
    80003222:	456080e7          	jalr	1110(ra) # 80004674 <holdingsleep>
    80003226:	cd01                	beqz	a0,8000323e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003228:	4585                	li	a1,1
    8000322a:	8526                	mv	a0,s1
    8000322c:	00003097          	auipc	ra,0x3
    80003230:	f60080e7          	jalr	-160(ra) # 8000618c <virtio_disk_rw>
}
    80003234:	60e2                	ld	ra,24(sp)
    80003236:	6442                	ld	s0,16(sp)
    80003238:	64a2                	ld	s1,8(sp)
    8000323a:	6105                	addi	sp,sp,32
    8000323c:	8082                	ret
    panic("bwrite");
    8000323e:	00005517          	auipc	a0,0x5
    80003242:	35a50513          	addi	a0,a0,858 # 80008598 <syscalls+0xd8>
    80003246:	ffffd097          	auipc	ra,0xffffd
    8000324a:	2fc080e7          	jalr	764(ra) # 80000542 <panic>

000000008000324e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000324e:	1101                	addi	sp,sp,-32
    80003250:	ec06                	sd	ra,24(sp)
    80003252:	e822                	sd	s0,16(sp)
    80003254:	e426                	sd	s1,8(sp)
    80003256:	e04a                	sd	s2,0(sp)
    80003258:	1000                	addi	s0,sp,32
    8000325a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000325c:	01050913          	addi	s2,a0,16
    80003260:	854a                	mv	a0,s2
    80003262:	00001097          	auipc	ra,0x1
    80003266:	412080e7          	jalr	1042(ra) # 80004674 <holdingsleep>
    8000326a:	c92d                	beqz	a0,800032dc <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000326c:	854a                	mv	a0,s2
    8000326e:	00001097          	auipc	ra,0x1
    80003272:	3c2080e7          	jalr	962(ra) # 80004630 <releasesleep>

  acquire(&bcache.lock);
    80003276:	00014517          	auipc	a0,0x14
    8000327a:	70a50513          	addi	a0,a0,1802 # 80017980 <bcache>
    8000327e:	ffffe097          	auipc	ra,0xffffe
    80003282:	980080e7          	jalr	-1664(ra) # 80000bfe <acquire>
  b->refcnt--;
    80003286:	40bc                	lw	a5,64(s1)
    80003288:	37fd                	addiw	a5,a5,-1
    8000328a:	0007871b          	sext.w	a4,a5
    8000328e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003290:	eb05                	bnez	a4,800032c0 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003292:	68bc                	ld	a5,80(s1)
    80003294:	64b8                	ld	a4,72(s1)
    80003296:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003298:	64bc                	ld	a5,72(s1)
    8000329a:	68b8                	ld	a4,80(s1)
    8000329c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000329e:	0001c797          	auipc	a5,0x1c
    800032a2:	6e278793          	addi	a5,a5,1762 # 8001f980 <bcache+0x8000>
    800032a6:	2b87b703          	ld	a4,696(a5)
    800032aa:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032ac:	0001d717          	auipc	a4,0x1d
    800032b0:	93c70713          	addi	a4,a4,-1732 # 8001fbe8 <bcache+0x8268>
    800032b4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800032b6:	2b87b703          	ld	a4,696(a5)
    800032ba:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032bc:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800032c0:	00014517          	auipc	a0,0x14
    800032c4:	6c050513          	addi	a0,a0,1728 # 80017980 <bcache>
    800032c8:	ffffe097          	auipc	ra,0xffffe
    800032cc:	9ea080e7          	jalr	-1558(ra) # 80000cb2 <release>
}
    800032d0:	60e2                	ld	ra,24(sp)
    800032d2:	6442                	ld	s0,16(sp)
    800032d4:	64a2                	ld	s1,8(sp)
    800032d6:	6902                	ld	s2,0(sp)
    800032d8:	6105                	addi	sp,sp,32
    800032da:	8082                	ret
    panic("brelse");
    800032dc:	00005517          	auipc	a0,0x5
    800032e0:	2c450513          	addi	a0,a0,708 # 800085a0 <syscalls+0xe0>
    800032e4:	ffffd097          	auipc	ra,0xffffd
    800032e8:	25e080e7          	jalr	606(ra) # 80000542 <panic>

00000000800032ec <bpin>:

void
bpin(struct buf *b) {
    800032ec:	1101                	addi	sp,sp,-32
    800032ee:	ec06                	sd	ra,24(sp)
    800032f0:	e822                	sd	s0,16(sp)
    800032f2:	e426                	sd	s1,8(sp)
    800032f4:	1000                	addi	s0,sp,32
    800032f6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032f8:	00014517          	auipc	a0,0x14
    800032fc:	68850513          	addi	a0,a0,1672 # 80017980 <bcache>
    80003300:	ffffe097          	auipc	ra,0xffffe
    80003304:	8fe080e7          	jalr	-1794(ra) # 80000bfe <acquire>
  b->refcnt++;
    80003308:	40bc                	lw	a5,64(s1)
    8000330a:	2785                	addiw	a5,a5,1
    8000330c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000330e:	00014517          	auipc	a0,0x14
    80003312:	67250513          	addi	a0,a0,1650 # 80017980 <bcache>
    80003316:	ffffe097          	auipc	ra,0xffffe
    8000331a:	99c080e7          	jalr	-1636(ra) # 80000cb2 <release>
}
    8000331e:	60e2                	ld	ra,24(sp)
    80003320:	6442                	ld	s0,16(sp)
    80003322:	64a2                	ld	s1,8(sp)
    80003324:	6105                	addi	sp,sp,32
    80003326:	8082                	ret

0000000080003328 <bunpin>:

void
bunpin(struct buf *b) {
    80003328:	1101                	addi	sp,sp,-32
    8000332a:	ec06                	sd	ra,24(sp)
    8000332c:	e822                	sd	s0,16(sp)
    8000332e:	e426                	sd	s1,8(sp)
    80003330:	1000                	addi	s0,sp,32
    80003332:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003334:	00014517          	auipc	a0,0x14
    80003338:	64c50513          	addi	a0,a0,1612 # 80017980 <bcache>
    8000333c:	ffffe097          	auipc	ra,0xffffe
    80003340:	8c2080e7          	jalr	-1854(ra) # 80000bfe <acquire>
  b->refcnt--;
    80003344:	40bc                	lw	a5,64(s1)
    80003346:	37fd                	addiw	a5,a5,-1
    80003348:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000334a:	00014517          	auipc	a0,0x14
    8000334e:	63650513          	addi	a0,a0,1590 # 80017980 <bcache>
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	960080e7          	jalr	-1696(ra) # 80000cb2 <release>
}
    8000335a:	60e2                	ld	ra,24(sp)
    8000335c:	6442                	ld	s0,16(sp)
    8000335e:	64a2                	ld	s1,8(sp)
    80003360:	6105                	addi	sp,sp,32
    80003362:	8082                	ret

0000000080003364 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003364:	1101                	addi	sp,sp,-32
    80003366:	ec06                	sd	ra,24(sp)
    80003368:	e822                	sd	s0,16(sp)
    8000336a:	e426                	sd	s1,8(sp)
    8000336c:	e04a                	sd	s2,0(sp)
    8000336e:	1000                	addi	s0,sp,32
    80003370:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003372:	00d5d59b          	srliw	a1,a1,0xd
    80003376:	0001d797          	auipc	a5,0x1d
    8000337a:	ce67a783          	lw	a5,-794(a5) # 8002005c <sb+0x1c>
    8000337e:	9dbd                	addw	a1,a1,a5
    80003380:	00000097          	auipc	ra,0x0
    80003384:	d9e080e7          	jalr	-610(ra) # 8000311e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003388:	0074f713          	andi	a4,s1,7
    8000338c:	4785                	li	a5,1
    8000338e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003392:	14ce                	slli	s1,s1,0x33
    80003394:	90d9                	srli	s1,s1,0x36
    80003396:	00950733          	add	a4,a0,s1
    8000339a:	05874703          	lbu	a4,88(a4)
    8000339e:	00e7f6b3          	and	a3,a5,a4
    800033a2:	c69d                	beqz	a3,800033d0 <bfree+0x6c>
    800033a4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033a6:	94aa                	add	s1,s1,a0
    800033a8:	fff7c793          	not	a5,a5
    800033ac:	8ff9                	and	a5,a5,a4
    800033ae:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800033b2:	00001097          	auipc	ra,0x1
    800033b6:	100080e7          	jalr	256(ra) # 800044b2 <log_write>
  brelse(bp);
    800033ba:	854a                	mv	a0,s2
    800033bc:	00000097          	auipc	ra,0x0
    800033c0:	e92080e7          	jalr	-366(ra) # 8000324e <brelse>
}
    800033c4:	60e2                	ld	ra,24(sp)
    800033c6:	6442                	ld	s0,16(sp)
    800033c8:	64a2                	ld	s1,8(sp)
    800033ca:	6902                	ld	s2,0(sp)
    800033cc:	6105                	addi	sp,sp,32
    800033ce:	8082                	ret
    panic("freeing free block");
    800033d0:	00005517          	auipc	a0,0x5
    800033d4:	1d850513          	addi	a0,a0,472 # 800085a8 <syscalls+0xe8>
    800033d8:	ffffd097          	auipc	ra,0xffffd
    800033dc:	16a080e7          	jalr	362(ra) # 80000542 <panic>

00000000800033e0 <balloc>:
{
    800033e0:	711d                	addi	sp,sp,-96
    800033e2:	ec86                	sd	ra,88(sp)
    800033e4:	e8a2                	sd	s0,80(sp)
    800033e6:	e4a6                	sd	s1,72(sp)
    800033e8:	e0ca                	sd	s2,64(sp)
    800033ea:	fc4e                	sd	s3,56(sp)
    800033ec:	f852                	sd	s4,48(sp)
    800033ee:	f456                	sd	s5,40(sp)
    800033f0:	f05a                	sd	s6,32(sp)
    800033f2:	ec5e                	sd	s7,24(sp)
    800033f4:	e862                	sd	s8,16(sp)
    800033f6:	e466                	sd	s9,8(sp)
    800033f8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033fa:	0001d797          	auipc	a5,0x1d
    800033fe:	c4a7a783          	lw	a5,-950(a5) # 80020044 <sb+0x4>
    80003402:	cbd1                	beqz	a5,80003496 <balloc+0xb6>
    80003404:	8baa                	mv	s7,a0
    80003406:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003408:	0001db17          	auipc	s6,0x1d
    8000340c:	c38b0b13          	addi	s6,s6,-968 # 80020040 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003410:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003412:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003414:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003416:	6c89                	lui	s9,0x2
    80003418:	a831                	j	80003434 <balloc+0x54>
    brelse(bp);
    8000341a:	854a                	mv	a0,s2
    8000341c:	00000097          	auipc	ra,0x0
    80003420:	e32080e7          	jalr	-462(ra) # 8000324e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003424:	015c87bb          	addw	a5,s9,s5
    80003428:	00078a9b          	sext.w	s5,a5
    8000342c:	004b2703          	lw	a4,4(s6)
    80003430:	06eaf363          	bgeu	s5,a4,80003496 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003434:	41fad79b          	sraiw	a5,s5,0x1f
    80003438:	0137d79b          	srliw	a5,a5,0x13
    8000343c:	015787bb          	addw	a5,a5,s5
    80003440:	40d7d79b          	sraiw	a5,a5,0xd
    80003444:	01cb2583          	lw	a1,28(s6)
    80003448:	9dbd                	addw	a1,a1,a5
    8000344a:	855e                	mv	a0,s7
    8000344c:	00000097          	auipc	ra,0x0
    80003450:	cd2080e7          	jalr	-814(ra) # 8000311e <bread>
    80003454:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003456:	004b2503          	lw	a0,4(s6)
    8000345a:	000a849b          	sext.w	s1,s5
    8000345e:	8662                	mv	a2,s8
    80003460:	faa4fde3          	bgeu	s1,a0,8000341a <balloc+0x3a>
      m = 1 << (bi % 8);
    80003464:	41f6579b          	sraiw	a5,a2,0x1f
    80003468:	01d7d69b          	srliw	a3,a5,0x1d
    8000346c:	00c6873b          	addw	a4,a3,a2
    80003470:	00777793          	andi	a5,a4,7
    80003474:	9f95                	subw	a5,a5,a3
    80003476:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000347a:	4037571b          	sraiw	a4,a4,0x3
    8000347e:	00e906b3          	add	a3,s2,a4
    80003482:	0586c683          	lbu	a3,88(a3)
    80003486:	00d7f5b3          	and	a1,a5,a3
    8000348a:	cd91                	beqz	a1,800034a6 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000348c:	2605                	addiw	a2,a2,1
    8000348e:	2485                	addiw	s1,s1,1
    80003490:	fd4618e3          	bne	a2,s4,80003460 <balloc+0x80>
    80003494:	b759                	j	8000341a <balloc+0x3a>
  panic("balloc: out of blocks");
    80003496:	00005517          	auipc	a0,0x5
    8000349a:	12a50513          	addi	a0,a0,298 # 800085c0 <syscalls+0x100>
    8000349e:	ffffd097          	auipc	ra,0xffffd
    800034a2:	0a4080e7          	jalr	164(ra) # 80000542 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034a6:	974a                	add	a4,a4,s2
    800034a8:	8fd5                	or	a5,a5,a3
    800034aa:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800034ae:	854a                	mv	a0,s2
    800034b0:	00001097          	auipc	ra,0x1
    800034b4:	002080e7          	jalr	2(ra) # 800044b2 <log_write>
        brelse(bp);
    800034b8:	854a                	mv	a0,s2
    800034ba:	00000097          	auipc	ra,0x0
    800034be:	d94080e7          	jalr	-620(ra) # 8000324e <brelse>
  bp = bread(dev, bno);
    800034c2:	85a6                	mv	a1,s1
    800034c4:	855e                	mv	a0,s7
    800034c6:	00000097          	auipc	ra,0x0
    800034ca:	c58080e7          	jalr	-936(ra) # 8000311e <bread>
    800034ce:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034d0:	40000613          	li	a2,1024
    800034d4:	4581                	li	a1,0
    800034d6:	05850513          	addi	a0,a0,88
    800034da:	ffffe097          	auipc	ra,0xffffe
    800034de:	820080e7          	jalr	-2016(ra) # 80000cfa <memset>
  log_write(bp);
    800034e2:	854a                	mv	a0,s2
    800034e4:	00001097          	auipc	ra,0x1
    800034e8:	fce080e7          	jalr	-50(ra) # 800044b2 <log_write>
  brelse(bp);
    800034ec:	854a                	mv	a0,s2
    800034ee:	00000097          	auipc	ra,0x0
    800034f2:	d60080e7          	jalr	-672(ra) # 8000324e <brelse>
}
    800034f6:	8526                	mv	a0,s1
    800034f8:	60e6                	ld	ra,88(sp)
    800034fa:	6446                	ld	s0,80(sp)
    800034fc:	64a6                	ld	s1,72(sp)
    800034fe:	6906                	ld	s2,64(sp)
    80003500:	79e2                	ld	s3,56(sp)
    80003502:	7a42                	ld	s4,48(sp)
    80003504:	7aa2                	ld	s5,40(sp)
    80003506:	7b02                	ld	s6,32(sp)
    80003508:	6be2                	ld	s7,24(sp)
    8000350a:	6c42                	ld	s8,16(sp)
    8000350c:	6ca2                	ld	s9,8(sp)
    8000350e:	6125                	addi	sp,sp,96
    80003510:	8082                	ret

0000000080003512 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003512:	7179                	addi	sp,sp,-48
    80003514:	f406                	sd	ra,40(sp)
    80003516:	f022                	sd	s0,32(sp)
    80003518:	ec26                	sd	s1,24(sp)
    8000351a:	e84a                	sd	s2,16(sp)
    8000351c:	e44e                	sd	s3,8(sp)
    8000351e:	e052                	sd	s4,0(sp)
    80003520:	1800                	addi	s0,sp,48
    80003522:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003524:	47ad                	li	a5,11
    80003526:	04b7fe63          	bgeu	a5,a1,80003582 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000352a:	ff45849b          	addiw	s1,a1,-12
    8000352e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003532:	0ff00793          	li	a5,255
    80003536:	0ae7e363          	bltu	a5,a4,800035dc <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000353a:	08052583          	lw	a1,128(a0)
    8000353e:	c5ad                	beqz	a1,800035a8 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003540:	00092503          	lw	a0,0(s2)
    80003544:	00000097          	auipc	ra,0x0
    80003548:	bda080e7          	jalr	-1062(ra) # 8000311e <bread>
    8000354c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000354e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003552:	02049593          	slli	a1,s1,0x20
    80003556:	9181                	srli	a1,a1,0x20
    80003558:	058a                	slli	a1,a1,0x2
    8000355a:	00b784b3          	add	s1,a5,a1
    8000355e:	0004a983          	lw	s3,0(s1)
    80003562:	04098d63          	beqz	s3,800035bc <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003566:	8552                	mv	a0,s4
    80003568:	00000097          	auipc	ra,0x0
    8000356c:	ce6080e7          	jalr	-794(ra) # 8000324e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003570:	854e                	mv	a0,s3
    80003572:	70a2                	ld	ra,40(sp)
    80003574:	7402                	ld	s0,32(sp)
    80003576:	64e2                	ld	s1,24(sp)
    80003578:	6942                	ld	s2,16(sp)
    8000357a:	69a2                	ld	s3,8(sp)
    8000357c:	6a02                	ld	s4,0(sp)
    8000357e:	6145                	addi	sp,sp,48
    80003580:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003582:	02059493          	slli	s1,a1,0x20
    80003586:	9081                	srli	s1,s1,0x20
    80003588:	048a                	slli	s1,s1,0x2
    8000358a:	94aa                	add	s1,s1,a0
    8000358c:	0504a983          	lw	s3,80(s1)
    80003590:	fe0990e3          	bnez	s3,80003570 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003594:	4108                	lw	a0,0(a0)
    80003596:	00000097          	auipc	ra,0x0
    8000359a:	e4a080e7          	jalr	-438(ra) # 800033e0 <balloc>
    8000359e:	0005099b          	sext.w	s3,a0
    800035a2:	0534a823          	sw	s3,80(s1)
    800035a6:	b7e9                	j	80003570 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800035a8:	4108                	lw	a0,0(a0)
    800035aa:	00000097          	auipc	ra,0x0
    800035ae:	e36080e7          	jalr	-458(ra) # 800033e0 <balloc>
    800035b2:	0005059b          	sext.w	a1,a0
    800035b6:	08b92023          	sw	a1,128(s2)
    800035ba:	b759                	j	80003540 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800035bc:	00092503          	lw	a0,0(s2)
    800035c0:	00000097          	auipc	ra,0x0
    800035c4:	e20080e7          	jalr	-480(ra) # 800033e0 <balloc>
    800035c8:	0005099b          	sext.w	s3,a0
    800035cc:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800035d0:	8552                	mv	a0,s4
    800035d2:	00001097          	auipc	ra,0x1
    800035d6:	ee0080e7          	jalr	-288(ra) # 800044b2 <log_write>
    800035da:	b771                	j	80003566 <bmap+0x54>
  panic("bmap: out of range");
    800035dc:	00005517          	auipc	a0,0x5
    800035e0:	ffc50513          	addi	a0,a0,-4 # 800085d8 <syscalls+0x118>
    800035e4:	ffffd097          	auipc	ra,0xffffd
    800035e8:	f5e080e7          	jalr	-162(ra) # 80000542 <panic>

00000000800035ec <iget>:
{
    800035ec:	7179                	addi	sp,sp,-48
    800035ee:	f406                	sd	ra,40(sp)
    800035f0:	f022                	sd	s0,32(sp)
    800035f2:	ec26                	sd	s1,24(sp)
    800035f4:	e84a                	sd	s2,16(sp)
    800035f6:	e44e                	sd	s3,8(sp)
    800035f8:	e052                	sd	s4,0(sp)
    800035fa:	1800                	addi	s0,sp,48
    800035fc:	89aa                	mv	s3,a0
    800035fe:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003600:	0001d517          	auipc	a0,0x1d
    80003604:	a6050513          	addi	a0,a0,-1440 # 80020060 <icache>
    80003608:	ffffd097          	auipc	ra,0xffffd
    8000360c:	5f6080e7          	jalr	1526(ra) # 80000bfe <acquire>
  empty = 0;
    80003610:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003612:	0001d497          	auipc	s1,0x1d
    80003616:	a6648493          	addi	s1,s1,-1434 # 80020078 <icache+0x18>
    8000361a:	0001e697          	auipc	a3,0x1e
    8000361e:	4ee68693          	addi	a3,a3,1262 # 80021b08 <log>
    80003622:	a039                	j	80003630 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003624:	02090b63          	beqz	s2,8000365a <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003628:	08848493          	addi	s1,s1,136
    8000362c:	02d48a63          	beq	s1,a3,80003660 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003630:	449c                	lw	a5,8(s1)
    80003632:	fef059e3          	blez	a5,80003624 <iget+0x38>
    80003636:	4098                	lw	a4,0(s1)
    80003638:	ff3716e3          	bne	a4,s3,80003624 <iget+0x38>
    8000363c:	40d8                	lw	a4,4(s1)
    8000363e:	ff4713e3          	bne	a4,s4,80003624 <iget+0x38>
      ip->ref++;
    80003642:	2785                	addiw	a5,a5,1
    80003644:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003646:	0001d517          	auipc	a0,0x1d
    8000364a:	a1a50513          	addi	a0,a0,-1510 # 80020060 <icache>
    8000364e:	ffffd097          	auipc	ra,0xffffd
    80003652:	664080e7          	jalr	1636(ra) # 80000cb2 <release>
      return ip;
    80003656:	8926                	mv	s2,s1
    80003658:	a03d                	j	80003686 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000365a:	f7f9                	bnez	a5,80003628 <iget+0x3c>
    8000365c:	8926                	mv	s2,s1
    8000365e:	b7e9                	j	80003628 <iget+0x3c>
  if(empty == 0)
    80003660:	02090c63          	beqz	s2,80003698 <iget+0xac>
  ip->dev = dev;
    80003664:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003668:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000366c:	4785                	li	a5,1
    8000366e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003672:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003676:	0001d517          	auipc	a0,0x1d
    8000367a:	9ea50513          	addi	a0,a0,-1558 # 80020060 <icache>
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	634080e7          	jalr	1588(ra) # 80000cb2 <release>
}
    80003686:	854a                	mv	a0,s2
    80003688:	70a2                	ld	ra,40(sp)
    8000368a:	7402                	ld	s0,32(sp)
    8000368c:	64e2                	ld	s1,24(sp)
    8000368e:	6942                	ld	s2,16(sp)
    80003690:	69a2                	ld	s3,8(sp)
    80003692:	6a02                	ld	s4,0(sp)
    80003694:	6145                	addi	sp,sp,48
    80003696:	8082                	ret
    panic("iget: no inodes");
    80003698:	00005517          	auipc	a0,0x5
    8000369c:	f5850513          	addi	a0,a0,-168 # 800085f0 <syscalls+0x130>
    800036a0:	ffffd097          	auipc	ra,0xffffd
    800036a4:	ea2080e7          	jalr	-350(ra) # 80000542 <panic>

00000000800036a8 <fsinit>:
fsinit(int dev) {
    800036a8:	7179                	addi	sp,sp,-48
    800036aa:	f406                	sd	ra,40(sp)
    800036ac:	f022                	sd	s0,32(sp)
    800036ae:	ec26                	sd	s1,24(sp)
    800036b0:	e84a                	sd	s2,16(sp)
    800036b2:	e44e                	sd	s3,8(sp)
    800036b4:	1800                	addi	s0,sp,48
    800036b6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036b8:	4585                	li	a1,1
    800036ba:	00000097          	auipc	ra,0x0
    800036be:	a64080e7          	jalr	-1436(ra) # 8000311e <bread>
    800036c2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036c4:	0001d997          	auipc	s3,0x1d
    800036c8:	97c98993          	addi	s3,s3,-1668 # 80020040 <sb>
    800036cc:	02000613          	li	a2,32
    800036d0:	05850593          	addi	a1,a0,88
    800036d4:	854e                	mv	a0,s3
    800036d6:	ffffd097          	auipc	ra,0xffffd
    800036da:	680080e7          	jalr	1664(ra) # 80000d56 <memmove>
  brelse(bp);
    800036de:	8526                	mv	a0,s1
    800036e0:	00000097          	auipc	ra,0x0
    800036e4:	b6e080e7          	jalr	-1170(ra) # 8000324e <brelse>
  if(sb.magic != FSMAGIC)
    800036e8:	0009a703          	lw	a4,0(s3)
    800036ec:	102037b7          	lui	a5,0x10203
    800036f0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036f4:	02f71263          	bne	a4,a5,80003718 <fsinit+0x70>
  initlog(dev, &sb);
    800036f8:	0001d597          	auipc	a1,0x1d
    800036fc:	94858593          	addi	a1,a1,-1720 # 80020040 <sb>
    80003700:	854a                	mv	a0,s2
    80003702:	00001097          	auipc	ra,0x1
    80003706:	b38080e7          	jalr	-1224(ra) # 8000423a <initlog>
}
    8000370a:	70a2                	ld	ra,40(sp)
    8000370c:	7402                	ld	s0,32(sp)
    8000370e:	64e2                	ld	s1,24(sp)
    80003710:	6942                	ld	s2,16(sp)
    80003712:	69a2                	ld	s3,8(sp)
    80003714:	6145                	addi	sp,sp,48
    80003716:	8082                	ret
    panic("invalid file system");
    80003718:	00005517          	auipc	a0,0x5
    8000371c:	ee850513          	addi	a0,a0,-280 # 80008600 <syscalls+0x140>
    80003720:	ffffd097          	auipc	ra,0xffffd
    80003724:	e22080e7          	jalr	-478(ra) # 80000542 <panic>

0000000080003728 <iinit>:
{
    80003728:	7179                	addi	sp,sp,-48
    8000372a:	f406                	sd	ra,40(sp)
    8000372c:	f022                	sd	s0,32(sp)
    8000372e:	ec26                	sd	s1,24(sp)
    80003730:	e84a                	sd	s2,16(sp)
    80003732:	e44e                	sd	s3,8(sp)
    80003734:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003736:	00005597          	auipc	a1,0x5
    8000373a:	ee258593          	addi	a1,a1,-286 # 80008618 <syscalls+0x158>
    8000373e:	0001d517          	auipc	a0,0x1d
    80003742:	92250513          	addi	a0,a0,-1758 # 80020060 <icache>
    80003746:	ffffd097          	auipc	ra,0xffffd
    8000374a:	428080e7          	jalr	1064(ra) # 80000b6e <initlock>
  for(i = 0; i < NINODE; i++) {
    8000374e:	0001d497          	auipc	s1,0x1d
    80003752:	93a48493          	addi	s1,s1,-1734 # 80020088 <icache+0x28>
    80003756:	0001e997          	auipc	s3,0x1e
    8000375a:	3c298993          	addi	s3,s3,962 # 80021b18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000375e:	00005917          	auipc	s2,0x5
    80003762:	ec290913          	addi	s2,s2,-318 # 80008620 <syscalls+0x160>
    80003766:	85ca                	mv	a1,s2
    80003768:	8526                	mv	a0,s1
    8000376a:	00001097          	auipc	ra,0x1
    8000376e:	e36080e7          	jalr	-458(ra) # 800045a0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003772:	08848493          	addi	s1,s1,136
    80003776:	ff3498e3          	bne	s1,s3,80003766 <iinit+0x3e>
}
    8000377a:	70a2                	ld	ra,40(sp)
    8000377c:	7402                	ld	s0,32(sp)
    8000377e:	64e2                	ld	s1,24(sp)
    80003780:	6942                	ld	s2,16(sp)
    80003782:	69a2                	ld	s3,8(sp)
    80003784:	6145                	addi	sp,sp,48
    80003786:	8082                	ret

0000000080003788 <ialloc>:
{
    80003788:	715d                	addi	sp,sp,-80
    8000378a:	e486                	sd	ra,72(sp)
    8000378c:	e0a2                	sd	s0,64(sp)
    8000378e:	fc26                	sd	s1,56(sp)
    80003790:	f84a                	sd	s2,48(sp)
    80003792:	f44e                	sd	s3,40(sp)
    80003794:	f052                	sd	s4,32(sp)
    80003796:	ec56                	sd	s5,24(sp)
    80003798:	e85a                	sd	s6,16(sp)
    8000379a:	e45e                	sd	s7,8(sp)
    8000379c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000379e:	0001d717          	auipc	a4,0x1d
    800037a2:	8ae72703          	lw	a4,-1874(a4) # 8002004c <sb+0xc>
    800037a6:	4785                	li	a5,1
    800037a8:	04e7fa63          	bgeu	a5,a4,800037fc <ialloc+0x74>
    800037ac:	8aaa                	mv	s5,a0
    800037ae:	8bae                	mv	s7,a1
    800037b0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037b2:	0001da17          	auipc	s4,0x1d
    800037b6:	88ea0a13          	addi	s4,s4,-1906 # 80020040 <sb>
    800037ba:	00048b1b          	sext.w	s6,s1
    800037be:	0044d793          	srli	a5,s1,0x4
    800037c2:	018a2583          	lw	a1,24(s4)
    800037c6:	9dbd                	addw	a1,a1,a5
    800037c8:	8556                	mv	a0,s5
    800037ca:	00000097          	auipc	ra,0x0
    800037ce:	954080e7          	jalr	-1708(ra) # 8000311e <bread>
    800037d2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037d4:	05850993          	addi	s3,a0,88
    800037d8:	00f4f793          	andi	a5,s1,15
    800037dc:	079a                	slli	a5,a5,0x6
    800037de:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037e0:	00099783          	lh	a5,0(s3)
    800037e4:	c785                	beqz	a5,8000380c <ialloc+0x84>
    brelse(bp);
    800037e6:	00000097          	auipc	ra,0x0
    800037ea:	a68080e7          	jalr	-1432(ra) # 8000324e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037ee:	0485                	addi	s1,s1,1
    800037f0:	00ca2703          	lw	a4,12(s4)
    800037f4:	0004879b          	sext.w	a5,s1
    800037f8:	fce7e1e3          	bltu	a5,a4,800037ba <ialloc+0x32>
  panic("ialloc: no inodes");
    800037fc:	00005517          	auipc	a0,0x5
    80003800:	e2c50513          	addi	a0,a0,-468 # 80008628 <syscalls+0x168>
    80003804:	ffffd097          	auipc	ra,0xffffd
    80003808:	d3e080e7          	jalr	-706(ra) # 80000542 <panic>
      memset(dip, 0, sizeof(*dip));
    8000380c:	04000613          	li	a2,64
    80003810:	4581                	li	a1,0
    80003812:	854e                	mv	a0,s3
    80003814:	ffffd097          	auipc	ra,0xffffd
    80003818:	4e6080e7          	jalr	1254(ra) # 80000cfa <memset>
      dip->type = type;
    8000381c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003820:	854a                	mv	a0,s2
    80003822:	00001097          	auipc	ra,0x1
    80003826:	c90080e7          	jalr	-880(ra) # 800044b2 <log_write>
      brelse(bp);
    8000382a:	854a                	mv	a0,s2
    8000382c:	00000097          	auipc	ra,0x0
    80003830:	a22080e7          	jalr	-1502(ra) # 8000324e <brelse>
      return iget(dev, inum);
    80003834:	85da                	mv	a1,s6
    80003836:	8556                	mv	a0,s5
    80003838:	00000097          	auipc	ra,0x0
    8000383c:	db4080e7          	jalr	-588(ra) # 800035ec <iget>
}
    80003840:	60a6                	ld	ra,72(sp)
    80003842:	6406                	ld	s0,64(sp)
    80003844:	74e2                	ld	s1,56(sp)
    80003846:	7942                	ld	s2,48(sp)
    80003848:	79a2                	ld	s3,40(sp)
    8000384a:	7a02                	ld	s4,32(sp)
    8000384c:	6ae2                	ld	s5,24(sp)
    8000384e:	6b42                	ld	s6,16(sp)
    80003850:	6ba2                	ld	s7,8(sp)
    80003852:	6161                	addi	sp,sp,80
    80003854:	8082                	ret

0000000080003856 <iupdate>:
{
    80003856:	1101                	addi	sp,sp,-32
    80003858:	ec06                	sd	ra,24(sp)
    8000385a:	e822                	sd	s0,16(sp)
    8000385c:	e426                	sd	s1,8(sp)
    8000385e:	e04a                	sd	s2,0(sp)
    80003860:	1000                	addi	s0,sp,32
    80003862:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003864:	415c                	lw	a5,4(a0)
    80003866:	0047d79b          	srliw	a5,a5,0x4
    8000386a:	0001c597          	auipc	a1,0x1c
    8000386e:	7ee5a583          	lw	a1,2030(a1) # 80020058 <sb+0x18>
    80003872:	9dbd                	addw	a1,a1,a5
    80003874:	4108                	lw	a0,0(a0)
    80003876:	00000097          	auipc	ra,0x0
    8000387a:	8a8080e7          	jalr	-1880(ra) # 8000311e <bread>
    8000387e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003880:	05850793          	addi	a5,a0,88
    80003884:	40c8                	lw	a0,4(s1)
    80003886:	893d                	andi	a0,a0,15
    80003888:	051a                	slli	a0,a0,0x6
    8000388a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000388c:	04449703          	lh	a4,68(s1)
    80003890:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003894:	04649703          	lh	a4,70(s1)
    80003898:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000389c:	04849703          	lh	a4,72(s1)
    800038a0:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800038a4:	04a49703          	lh	a4,74(s1)
    800038a8:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800038ac:	44f8                	lw	a4,76(s1)
    800038ae:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038b0:	03400613          	li	a2,52
    800038b4:	05048593          	addi	a1,s1,80
    800038b8:	0531                	addi	a0,a0,12
    800038ba:	ffffd097          	auipc	ra,0xffffd
    800038be:	49c080e7          	jalr	1180(ra) # 80000d56 <memmove>
  log_write(bp);
    800038c2:	854a                	mv	a0,s2
    800038c4:	00001097          	auipc	ra,0x1
    800038c8:	bee080e7          	jalr	-1042(ra) # 800044b2 <log_write>
  brelse(bp);
    800038cc:	854a                	mv	a0,s2
    800038ce:	00000097          	auipc	ra,0x0
    800038d2:	980080e7          	jalr	-1664(ra) # 8000324e <brelse>
}
    800038d6:	60e2                	ld	ra,24(sp)
    800038d8:	6442                	ld	s0,16(sp)
    800038da:	64a2                	ld	s1,8(sp)
    800038dc:	6902                	ld	s2,0(sp)
    800038de:	6105                	addi	sp,sp,32
    800038e0:	8082                	ret

00000000800038e2 <idup>:
{
    800038e2:	1101                	addi	sp,sp,-32
    800038e4:	ec06                	sd	ra,24(sp)
    800038e6:	e822                	sd	s0,16(sp)
    800038e8:	e426                	sd	s1,8(sp)
    800038ea:	1000                	addi	s0,sp,32
    800038ec:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800038ee:	0001c517          	auipc	a0,0x1c
    800038f2:	77250513          	addi	a0,a0,1906 # 80020060 <icache>
    800038f6:	ffffd097          	auipc	ra,0xffffd
    800038fa:	308080e7          	jalr	776(ra) # 80000bfe <acquire>
  ip->ref++;
    800038fe:	449c                	lw	a5,8(s1)
    80003900:	2785                	addiw	a5,a5,1
    80003902:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003904:	0001c517          	auipc	a0,0x1c
    80003908:	75c50513          	addi	a0,a0,1884 # 80020060 <icache>
    8000390c:	ffffd097          	auipc	ra,0xffffd
    80003910:	3a6080e7          	jalr	934(ra) # 80000cb2 <release>
}
    80003914:	8526                	mv	a0,s1
    80003916:	60e2                	ld	ra,24(sp)
    80003918:	6442                	ld	s0,16(sp)
    8000391a:	64a2                	ld	s1,8(sp)
    8000391c:	6105                	addi	sp,sp,32
    8000391e:	8082                	ret

0000000080003920 <ilock>:
{
    80003920:	1101                	addi	sp,sp,-32
    80003922:	ec06                	sd	ra,24(sp)
    80003924:	e822                	sd	s0,16(sp)
    80003926:	e426                	sd	s1,8(sp)
    80003928:	e04a                	sd	s2,0(sp)
    8000392a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000392c:	c115                	beqz	a0,80003950 <ilock+0x30>
    8000392e:	84aa                	mv	s1,a0
    80003930:	451c                	lw	a5,8(a0)
    80003932:	00f05f63          	blez	a5,80003950 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003936:	0541                	addi	a0,a0,16
    80003938:	00001097          	auipc	ra,0x1
    8000393c:	ca2080e7          	jalr	-862(ra) # 800045da <acquiresleep>
  if(ip->valid == 0){
    80003940:	40bc                	lw	a5,64(s1)
    80003942:	cf99                	beqz	a5,80003960 <ilock+0x40>
}
    80003944:	60e2                	ld	ra,24(sp)
    80003946:	6442                	ld	s0,16(sp)
    80003948:	64a2                	ld	s1,8(sp)
    8000394a:	6902                	ld	s2,0(sp)
    8000394c:	6105                	addi	sp,sp,32
    8000394e:	8082                	ret
    panic("ilock");
    80003950:	00005517          	auipc	a0,0x5
    80003954:	cf050513          	addi	a0,a0,-784 # 80008640 <syscalls+0x180>
    80003958:	ffffd097          	auipc	ra,0xffffd
    8000395c:	bea080e7          	jalr	-1046(ra) # 80000542 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003960:	40dc                	lw	a5,4(s1)
    80003962:	0047d79b          	srliw	a5,a5,0x4
    80003966:	0001c597          	auipc	a1,0x1c
    8000396a:	6f25a583          	lw	a1,1778(a1) # 80020058 <sb+0x18>
    8000396e:	9dbd                	addw	a1,a1,a5
    80003970:	4088                	lw	a0,0(s1)
    80003972:	fffff097          	auipc	ra,0xfffff
    80003976:	7ac080e7          	jalr	1964(ra) # 8000311e <bread>
    8000397a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000397c:	05850593          	addi	a1,a0,88
    80003980:	40dc                	lw	a5,4(s1)
    80003982:	8bbd                	andi	a5,a5,15
    80003984:	079a                	slli	a5,a5,0x6
    80003986:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003988:	00059783          	lh	a5,0(a1)
    8000398c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003990:	00259783          	lh	a5,2(a1)
    80003994:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003998:	00459783          	lh	a5,4(a1)
    8000399c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039a0:	00659783          	lh	a5,6(a1)
    800039a4:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039a8:	459c                	lw	a5,8(a1)
    800039aa:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039ac:	03400613          	li	a2,52
    800039b0:	05b1                	addi	a1,a1,12
    800039b2:	05048513          	addi	a0,s1,80
    800039b6:	ffffd097          	auipc	ra,0xffffd
    800039ba:	3a0080e7          	jalr	928(ra) # 80000d56 <memmove>
    brelse(bp);
    800039be:	854a                	mv	a0,s2
    800039c0:	00000097          	auipc	ra,0x0
    800039c4:	88e080e7          	jalr	-1906(ra) # 8000324e <brelse>
    ip->valid = 1;
    800039c8:	4785                	li	a5,1
    800039ca:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039cc:	04449783          	lh	a5,68(s1)
    800039d0:	fbb5                	bnez	a5,80003944 <ilock+0x24>
      panic("ilock: no type");
    800039d2:	00005517          	auipc	a0,0x5
    800039d6:	c7650513          	addi	a0,a0,-906 # 80008648 <syscalls+0x188>
    800039da:	ffffd097          	auipc	ra,0xffffd
    800039de:	b68080e7          	jalr	-1176(ra) # 80000542 <panic>

00000000800039e2 <iunlock>:
{
    800039e2:	1101                	addi	sp,sp,-32
    800039e4:	ec06                	sd	ra,24(sp)
    800039e6:	e822                	sd	s0,16(sp)
    800039e8:	e426                	sd	s1,8(sp)
    800039ea:	e04a                	sd	s2,0(sp)
    800039ec:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039ee:	c905                	beqz	a0,80003a1e <iunlock+0x3c>
    800039f0:	84aa                	mv	s1,a0
    800039f2:	01050913          	addi	s2,a0,16
    800039f6:	854a                	mv	a0,s2
    800039f8:	00001097          	auipc	ra,0x1
    800039fc:	c7c080e7          	jalr	-900(ra) # 80004674 <holdingsleep>
    80003a00:	cd19                	beqz	a0,80003a1e <iunlock+0x3c>
    80003a02:	449c                	lw	a5,8(s1)
    80003a04:	00f05d63          	blez	a5,80003a1e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a08:	854a                	mv	a0,s2
    80003a0a:	00001097          	auipc	ra,0x1
    80003a0e:	c26080e7          	jalr	-986(ra) # 80004630 <releasesleep>
}
    80003a12:	60e2                	ld	ra,24(sp)
    80003a14:	6442                	ld	s0,16(sp)
    80003a16:	64a2                	ld	s1,8(sp)
    80003a18:	6902                	ld	s2,0(sp)
    80003a1a:	6105                	addi	sp,sp,32
    80003a1c:	8082                	ret
    panic("iunlock");
    80003a1e:	00005517          	auipc	a0,0x5
    80003a22:	c3a50513          	addi	a0,a0,-966 # 80008658 <syscalls+0x198>
    80003a26:	ffffd097          	auipc	ra,0xffffd
    80003a2a:	b1c080e7          	jalr	-1252(ra) # 80000542 <panic>

0000000080003a2e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a2e:	7179                	addi	sp,sp,-48
    80003a30:	f406                	sd	ra,40(sp)
    80003a32:	f022                	sd	s0,32(sp)
    80003a34:	ec26                	sd	s1,24(sp)
    80003a36:	e84a                	sd	s2,16(sp)
    80003a38:	e44e                	sd	s3,8(sp)
    80003a3a:	e052                	sd	s4,0(sp)
    80003a3c:	1800                	addi	s0,sp,48
    80003a3e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a40:	05050493          	addi	s1,a0,80
    80003a44:	08050913          	addi	s2,a0,128
    80003a48:	a021                	j	80003a50 <itrunc+0x22>
    80003a4a:	0491                	addi	s1,s1,4
    80003a4c:	01248d63          	beq	s1,s2,80003a66 <itrunc+0x38>
    if(ip->addrs[i]){
    80003a50:	408c                	lw	a1,0(s1)
    80003a52:	dde5                	beqz	a1,80003a4a <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a54:	0009a503          	lw	a0,0(s3)
    80003a58:	00000097          	auipc	ra,0x0
    80003a5c:	90c080e7          	jalr	-1780(ra) # 80003364 <bfree>
      ip->addrs[i] = 0;
    80003a60:	0004a023          	sw	zero,0(s1)
    80003a64:	b7dd                	j	80003a4a <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a66:	0809a583          	lw	a1,128(s3)
    80003a6a:	e185                	bnez	a1,80003a8a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a6c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a70:	854e                	mv	a0,s3
    80003a72:	00000097          	auipc	ra,0x0
    80003a76:	de4080e7          	jalr	-540(ra) # 80003856 <iupdate>
}
    80003a7a:	70a2                	ld	ra,40(sp)
    80003a7c:	7402                	ld	s0,32(sp)
    80003a7e:	64e2                	ld	s1,24(sp)
    80003a80:	6942                	ld	s2,16(sp)
    80003a82:	69a2                	ld	s3,8(sp)
    80003a84:	6a02                	ld	s4,0(sp)
    80003a86:	6145                	addi	sp,sp,48
    80003a88:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a8a:	0009a503          	lw	a0,0(s3)
    80003a8e:	fffff097          	auipc	ra,0xfffff
    80003a92:	690080e7          	jalr	1680(ra) # 8000311e <bread>
    80003a96:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a98:	05850493          	addi	s1,a0,88
    80003a9c:	45850913          	addi	s2,a0,1112
    80003aa0:	a021                	j	80003aa8 <itrunc+0x7a>
    80003aa2:	0491                	addi	s1,s1,4
    80003aa4:	01248b63          	beq	s1,s2,80003aba <itrunc+0x8c>
      if(a[j])
    80003aa8:	408c                	lw	a1,0(s1)
    80003aaa:	dde5                	beqz	a1,80003aa2 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003aac:	0009a503          	lw	a0,0(s3)
    80003ab0:	00000097          	auipc	ra,0x0
    80003ab4:	8b4080e7          	jalr	-1868(ra) # 80003364 <bfree>
    80003ab8:	b7ed                	j	80003aa2 <itrunc+0x74>
    brelse(bp);
    80003aba:	8552                	mv	a0,s4
    80003abc:	fffff097          	auipc	ra,0xfffff
    80003ac0:	792080e7          	jalr	1938(ra) # 8000324e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ac4:	0809a583          	lw	a1,128(s3)
    80003ac8:	0009a503          	lw	a0,0(s3)
    80003acc:	00000097          	auipc	ra,0x0
    80003ad0:	898080e7          	jalr	-1896(ra) # 80003364 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ad4:	0809a023          	sw	zero,128(s3)
    80003ad8:	bf51                	j	80003a6c <itrunc+0x3e>

0000000080003ada <iput>:
{
    80003ada:	1101                	addi	sp,sp,-32
    80003adc:	ec06                	sd	ra,24(sp)
    80003ade:	e822                	sd	s0,16(sp)
    80003ae0:	e426                	sd	s1,8(sp)
    80003ae2:	e04a                	sd	s2,0(sp)
    80003ae4:	1000                	addi	s0,sp,32
    80003ae6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003ae8:	0001c517          	auipc	a0,0x1c
    80003aec:	57850513          	addi	a0,a0,1400 # 80020060 <icache>
    80003af0:	ffffd097          	auipc	ra,0xffffd
    80003af4:	10e080e7          	jalr	270(ra) # 80000bfe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003af8:	4498                	lw	a4,8(s1)
    80003afa:	4785                	li	a5,1
    80003afc:	02f70363          	beq	a4,a5,80003b22 <iput+0x48>
  ip->ref--;
    80003b00:	449c                	lw	a5,8(s1)
    80003b02:	37fd                	addiw	a5,a5,-1
    80003b04:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003b06:	0001c517          	auipc	a0,0x1c
    80003b0a:	55a50513          	addi	a0,a0,1370 # 80020060 <icache>
    80003b0e:	ffffd097          	auipc	ra,0xffffd
    80003b12:	1a4080e7          	jalr	420(ra) # 80000cb2 <release>
}
    80003b16:	60e2                	ld	ra,24(sp)
    80003b18:	6442                	ld	s0,16(sp)
    80003b1a:	64a2                	ld	s1,8(sp)
    80003b1c:	6902                	ld	s2,0(sp)
    80003b1e:	6105                	addi	sp,sp,32
    80003b20:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b22:	40bc                	lw	a5,64(s1)
    80003b24:	dff1                	beqz	a5,80003b00 <iput+0x26>
    80003b26:	04a49783          	lh	a5,74(s1)
    80003b2a:	fbf9                	bnez	a5,80003b00 <iput+0x26>
    acquiresleep(&ip->lock);
    80003b2c:	01048913          	addi	s2,s1,16
    80003b30:	854a                	mv	a0,s2
    80003b32:	00001097          	auipc	ra,0x1
    80003b36:	aa8080e7          	jalr	-1368(ra) # 800045da <acquiresleep>
    release(&icache.lock);
    80003b3a:	0001c517          	auipc	a0,0x1c
    80003b3e:	52650513          	addi	a0,a0,1318 # 80020060 <icache>
    80003b42:	ffffd097          	auipc	ra,0xffffd
    80003b46:	170080e7          	jalr	368(ra) # 80000cb2 <release>
    itrunc(ip);
    80003b4a:	8526                	mv	a0,s1
    80003b4c:	00000097          	auipc	ra,0x0
    80003b50:	ee2080e7          	jalr	-286(ra) # 80003a2e <itrunc>
    ip->type = 0;
    80003b54:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b58:	8526                	mv	a0,s1
    80003b5a:	00000097          	auipc	ra,0x0
    80003b5e:	cfc080e7          	jalr	-772(ra) # 80003856 <iupdate>
    ip->valid = 0;
    80003b62:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b66:	854a                	mv	a0,s2
    80003b68:	00001097          	auipc	ra,0x1
    80003b6c:	ac8080e7          	jalr	-1336(ra) # 80004630 <releasesleep>
    acquire(&icache.lock);
    80003b70:	0001c517          	auipc	a0,0x1c
    80003b74:	4f050513          	addi	a0,a0,1264 # 80020060 <icache>
    80003b78:	ffffd097          	auipc	ra,0xffffd
    80003b7c:	086080e7          	jalr	134(ra) # 80000bfe <acquire>
    80003b80:	b741                	j	80003b00 <iput+0x26>

0000000080003b82 <iunlockput>:
{
    80003b82:	1101                	addi	sp,sp,-32
    80003b84:	ec06                	sd	ra,24(sp)
    80003b86:	e822                	sd	s0,16(sp)
    80003b88:	e426                	sd	s1,8(sp)
    80003b8a:	1000                	addi	s0,sp,32
    80003b8c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b8e:	00000097          	auipc	ra,0x0
    80003b92:	e54080e7          	jalr	-428(ra) # 800039e2 <iunlock>
  iput(ip);
    80003b96:	8526                	mv	a0,s1
    80003b98:	00000097          	auipc	ra,0x0
    80003b9c:	f42080e7          	jalr	-190(ra) # 80003ada <iput>
}
    80003ba0:	60e2                	ld	ra,24(sp)
    80003ba2:	6442                	ld	s0,16(sp)
    80003ba4:	64a2                	ld	s1,8(sp)
    80003ba6:	6105                	addi	sp,sp,32
    80003ba8:	8082                	ret

0000000080003baa <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003baa:	1141                	addi	sp,sp,-16
    80003bac:	e422                	sd	s0,8(sp)
    80003bae:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003bb0:	411c                	lw	a5,0(a0)
    80003bb2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bb4:	415c                	lw	a5,4(a0)
    80003bb6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bb8:	04451783          	lh	a5,68(a0)
    80003bbc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bc0:	04a51783          	lh	a5,74(a0)
    80003bc4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bc8:	04c56783          	lwu	a5,76(a0)
    80003bcc:	e99c                	sd	a5,16(a1)
}
    80003bce:	6422                	ld	s0,8(sp)
    80003bd0:	0141                	addi	sp,sp,16
    80003bd2:	8082                	ret

0000000080003bd4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bd4:	457c                	lw	a5,76(a0)
    80003bd6:	0ed7e863          	bltu	a5,a3,80003cc6 <readi+0xf2>
{
    80003bda:	7159                	addi	sp,sp,-112
    80003bdc:	f486                	sd	ra,104(sp)
    80003bde:	f0a2                	sd	s0,96(sp)
    80003be0:	eca6                	sd	s1,88(sp)
    80003be2:	e8ca                	sd	s2,80(sp)
    80003be4:	e4ce                	sd	s3,72(sp)
    80003be6:	e0d2                	sd	s4,64(sp)
    80003be8:	fc56                	sd	s5,56(sp)
    80003bea:	f85a                	sd	s6,48(sp)
    80003bec:	f45e                	sd	s7,40(sp)
    80003bee:	f062                	sd	s8,32(sp)
    80003bf0:	ec66                	sd	s9,24(sp)
    80003bf2:	e86a                	sd	s10,16(sp)
    80003bf4:	e46e                	sd	s11,8(sp)
    80003bf6:	1880                	addi	s0,sp,112
    80003bf8:	8baa                	mv	s7,a0
    80003bfa:	8c2e                	mv	s8,a1
    80003bfc:	8ab2                	mv	s5,a2
    80003bfe:	84b6                	mv	s1,a3
    80003c00:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c02:	9f35                	addw	a4,a4,a3
    return 0;
    80003c04:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c06:	08d76f63          	bltu	a4,a3,80003ca4 <readi+0xd0>
  if(off + n > ip->size)
    80003c0a:	00e7f463          	bgeu	a5,a4,80003c12 <readi+0x3e>
    n = ip->size - off;
    80003c0e:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c12:	0a0b0863          	beqz	s6,80003cc2 <readi+0xee>
    80003c16:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c18:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c1c:	5cfd                	li	s9,-1
    80003c1e:	a82d                	j	80003c58 <readi+0x84>
    80003c20:	020a1d93          	slli	s11,s4,0x20
    80003c24:	020ddd93          	srli	s11,s11,0x20
    80003c28:	05890793          	addi	a5,s2,88
    80003c2c:	86ee                	mv	a3,s11
    80003c2e:	963e                	add	a2,a2,a5
    80003c30:	85d6                	mv	a1,s5
    80003c32:	8562                	mv	a0,s8
    80003c34:	fffff097          	auipc	ra,0xfffff
    80003c38:	b30080e7          	jalr	-1232(ra) # 80002764 <either_copyout>
    80003c3c:	05950d63          	beq	a0,s9,80003c96 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003c40:	854a                	mv	a0,s2
    80003c42:	fffff097          	auipc	ra,0xfffff
    80003c46:	60c080e7          	jalr	1548(ra) # 8000324e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c4a:	013a09bb          	addw	s3,s4,s3
    80003c4e:	009a04bb          	addw	s1,s4,s1
    80003c52:	9aee                	add	s5,s5,s11
    80003c54:	0569f663          	bgeu	s3,s6,80003ca0 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c58:	000ba903          	lw	s2,0(s7)
    80003c5c:	00a4d59b          	srliw	a1,s1,0xa
    80003c60:	855e                	mv	a0,s7
    80003c62:	00000097          	auipc	ra,0x0
    80003c66:	8b0080e7          	jalr	-1872(ra) # 80003512 <bmap>
    80003c6a:	0005059b          	sext.w	a1,a0
    80003c6e:	854a                	mv	a0,s2
    80003c70:	fffff097          	auipc	ra,0xfffff
    80003c74:	4ae080e7          	jalr	1198(ra) # 8000311e <bread>
    80003c78:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c7a:	3ff4f613          	andi	a2,s1,1023
    80003c7e:	40cd07bb          	subw	a5,s10,a2
    80003c82:	413b073b          	subw	a4,s6,s3
    80003c86:	8a3e                	mv	s4,a5
    80003c88:	2781                	sext.w	a5,a5
    80003c8a:	0007069b          	sext.w	a3,a4
    80003c8e:	f8f6f9e3          	bgeu	a3,a5,80003c20 <readi+0x4c>
    80003c92:	8a3a                	mv	s4,a4
    80003c94:	b771                	j	80003c20 <readi+0x4c>
      brelse(bp);
    80003c96:	854a                	mv	a0,s2
    80003c98:	fffff097          	auipc	ra,0xfffff
    80003c9c:	5b6080e7          	jalr	1462(ra) # 8000324e <brelse>
  }
  return tot;
    80003ca0:	0009851b          	sext.w	a0,s3
}
    80003ca4:	70a6                	ld	ra,104(sp)
    80003ca6:	7406                	ld	s0,96(sp)
    80003ca8:	64e6                	ld	s1,88(sp)
    80003caa:	6946                	ld	s2,80(sp)
    80003cac:	69a6                	ld	s3,72(sp)
    80003cae:	6a06                	ld	s4,64(sp)
    80003cb0:	7ae2                	ld	s5,56(sp)
    80003cb2:	7b42                	ld	s6,48(sp)
    80003cb4:	7ba2                	ld	s7,40(sp)
    80003cb6:	7c02                	ld	s8,32(sp)
    80003cb8:	6ce2                	ld	s9,24(sp)
    80003cba:	6d42                	ld	s10,16(sp)
    80003cbc:	6da2                	ld	s11,8(sp)
    80003cbe:	6165                	addi	sp,sp,112
    80003cc0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cc2:	89da                	mv	s3,s6
    80003cc4:	bff1                	j	80003ca0 <readi+0xcc>
    return 0;
    80003cc6:	4501                	li	a0,0
}
    80003cc8:	8082                	ret

0000000080003cca <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cca:	457c                	lw	a5,76(a0)
    80003ccc:	10d7e663          	bltu	a5,a3,80003dd8 <writei+0x10e>
{
    80003cd0:	7159                	addi	sp,sp,-112
    80003cd2:	f486                	sd	ra,104(sp)
    80003cd4:	f0a2                	sd	s0,96(sp)
    80003cd6:	eca6                	sd	s1,88(sp)
    80003cd8:	e8ca                	sd	s2,80(sp)
    80003cda:	e4ce                	sd	s3,72(sp)
    80003cdc:	e0d2                	sd	s4,64(sp)
    80003cde:	fc56                	sd	s5,56(sp)
    80003ce0:	f85a                	sd	s6,48(sp)
    80003ce2:	f45e                	sd	s7,40(sp)
    80003ce4:	f062                	sd	s8,32(sp)
    80003ce6:	ec66                	sd	s9,24(sp)
    80003ce8:	e86a                	sd	s10,16(sp)
    80003cea:	e46e                	sd	s11,8(sp)
    80003cec:	1880                	addi	s0,sp,112
    80003cee:	8baa                	mv	s7,a0
    80003cf0:	8c2e                	mv	s8,a1
    80003cf2:	8ab2                	mv	s5,a2
    80003cf4:	8936                	mv	s2,a3
    80003cf6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cf8:	00e687bb          	addw	a5,a3,a4
    80003cfc:	0ed7e063          	bltu	a5,a3,80003ddc <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d00:	00043737          	lui	a4,0x43
    80003d04:	0cf76e63          	bltu	a4,a5,80003de0 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d08:	0a0b0763          	beqz	s6,80003db6 <writei+0xec>
    80003d0c:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d0e:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d12:	5cfd                	li	s9,-1
    80003d14:	a091                	j	80003d58 <writei+0x8e>
    80003d16:	02099d93          	slli	s11,s3,0x20
    80003d1a:	020ddd93          	srli	s11,s11,0x20
    80003d1e:	05848793          	addi	a5,s1,88
    80003d22:	86ee                	mv	a3,s11
    80003d24:	8656                	mv	a2,s5
    80003d26:	85e2                	mv	a1,s8
    80003d28:	953e                	add	a0,a0,a5
    80003d2a:	fffff097          	auipc	ra,0xfffff
    80003d2e:	a90080e7          	jalr	-1392(ra) # 800027ba <either_copyin>
    80003d32:	07950263          	beq	a0,s9,80003d96 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d36:	8526                	mv	a0,s1
    80003d38:	00000097          	auipc	ra,0x0
    80003d3c:	77a080e7          	jalr	1914(ra) # 800044b2 <log_write>
    brelse(bp);
    80003d40:	8526                	mv	a0,s1
    80003d42:	fffff097          	auipc	ra,0xfffff
    80003d46:	50c080e7          	jalr	1292(ra) # 8000324e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d4a:	01498a3b          	addw	s4,s3,s4
    80003d4e:	0129893b          	addw	s2,s3,s2
    80003d52:	9aee                	add	s5,s5,s11
    80003d54:	056a7663          	bgeu	s4,s6,80003da0 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d58:	000ba483          	lw	s1,0(s7)
    80003d5c:	00a9559b          	srliw	a1,s2,0xa
    80003d60:	855e                	mv	a0,s7
    80003d62:	fffff097          	auipc	ra,0xfffff
    80003d66:	7b0080e7          	jalr	1968(ra) # 80003512 <bmap>
    80003d6a:	0005059b          	sext.w	a1,a0
    80003d6e:	8526                	mv	a0,s1
    80003d70:	fffff097          	auipc	ra,0xfffff
    80003d74:	3ae080e7          	jalr	942(ra) # 8000311e <bread>
    80003d78:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d7a:	3ff97513          	andi	a0,s2,1023
    80003d7e:	40ad07bb          	subw	a5,s10,a0
    80003d82:	414b073b          	subw	a4,s6,s4
    80003d86:	89be                	mv	s3,a5
    80003d88:	2781                	sext.w	a5,a5
    80003d8a:	0007069b          	sext.w	a3,a4
    80003d8e:	f8f6f4e3          	bgeu	a3,a5,80003d16 <writei+0x4c>
    80003d92:	89ba                	mv	s3,a4
    80003d94:	b749                	j	80003d16 <writei+0x4c>
      brelse(bp);
    80003d96:	8526                	mv	a0,s1
    80003d98:	fffff097          	auipc	ra,0xfffff
    80003d9c:	4b6080e7          	jalr	1206(ra) # 8000324e <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003da0:	04cba783          	lw	a5,76(s7)
    80003da4:	0127f463          	bgeu	a5,s2,80003dac <writei+0xe2>
      ip->size = off;
    80003da8:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003dac:	855e                	mv	a0,s7
    80003dae:	00000097          	auipc	ra,0x0
    80003db2:	aa8080e7          	jalr	-1368(ra) # 80003856 <iupdate>
  }

  return n;
    80003db6:	000b051b          	sext.w	a0,s6
}
    80003dba:	70a6                	ld	ra,104(sp)
    80003dbc:	7406                	ld	s0,96(sp)
    80003dbe:	64e6                	ld	s1,88(sp)
    80003dc0:	6946                	ld	s2,80(sp)
    80003dc2:	69a6                	ld	s3,72(sp)
    80003dc4:	6a06                	ld	s4,64(sp)
    80003dc6:	7ae2                	ld	s5,56(sp)
    80003dc8:	7b42                	ld	s6,48(sp)
    80003dca:	7ba2                	ld	s7,40(sp)
    80003dcc:	7c02                	ld	s8,32(sp)
    80003dce:	6ce2                	ld	s9,24(sp)
    80003dd0:	6d42                	ld	s10,16(sp)
    80003dd2:	6da2                	ld	s11,8(sp)
    80003dd4:	6165                	addi	sp,sp,112
    80003dd6:	8082                	ret
    return -1;
    80003dd8:	557d                	li	a0,-1
}
    80003dda:	8082                	ret
    return -1;
    80003ddc:	557d                	li	a0,-1
    80003dde:	bff1                	j	80003dba <writei+0xf0>
    return -1;
    80003de0:	557d                	li	a0,-1
    80003de2:	bfe1                	j	80003dba <writei+0xf0>

0000000080003de4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003de4:	1141                	addi	sp,sp,-16
    80003de6:	e406                	sd	ra,8(sp)
    80003de8:	e022                	sd	s0,0(sp)
    80003dea:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003dec:	4639                	li	a2,14
    80003dee:	ffffd097          	auipc	ra,0xffffd
    80003df2:	fe4080e7          	jalr	-28(ra) # 80000dd2 <strncmp>
}
    80003df6:	60a2                	ld	ra,8(sp)
    80003df8:	6402                	ld	s0,0(sp)
    80003dfa:	0141                	addi	sp,sp,16
    80003dfc:	8082                	ret

0000000080003dfe <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003dfe:	7139                	addi	sp,sp,-64
    80003e00:	fc06                	sd	ra,56(sp)
    80003e02:	f822                	sd	s0,48(sp)
    80003e04:	f426                	sd	s1,40(sp)
    80003e06:	f04a                	sd	s2,32(sp)
    80003e08:	ec4e                	sd	s3,24(sp)
    80003e0a:	e852                	sd	s4,16(sp)
    80003e0c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e0e:	04451703          	lh	a4,68(a0)
    80003e12:	4785                	li	a5,1
    80003e14:	00f71a63          	bne	a4,a5,80003e28 <dirlookup+0x2a>
    80003e18:	892a                	mv	s2,a0
    80003e1a:	89ae                	mv	s3,a1
    80003e1c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e1e:	457c                	lw	a5,76(a0)
    80003e20:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e22:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e24:	e79d                	bnez	a5,80003e52 <dirlookup+0x54>
    80003e26:	a8a5                	j	80003e9e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e28:	00005517          	auipc	a0,0x5
    80003e2c:	83850513          	addi	a0,a0,-1992 # 80008660 <syscalls+0x1a0>
    80003e30:	ffffc097          	auipc	ra,0xffffc
    80003e34:	712080e7          	jalr	1810(ra) # 80000542 <panic>
      panic("dirlookup read");
    80003e38:	00005517          	auipc	a0,0x5
    80003e3c:	84050513          	addi	a0,a0,-1984 # 80008678 <syscalls+0x1b8>
    80003e40:	ffffc097          	auipc	ra,0xffffc
    80003e44:	702080e7          	jalr	1794(ra) # 80000542 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e48:	24c1                	addiw	s1,s1,16
    80003e4a:	04c92783          	lw	a5,76(s2)
    80003e4e:	04f4f763          	bgeu	s1,a5,80003e9c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e52:	4741                	li	a4,16
    80003e54:	86a6                	mv	a3,s1
    80003e56:	fc040613          	addi	a2,s0,-64
    80003e5a:	4581                	li	a1,0
    80003e5c:	854a                	mv	a0,s2
    80003e5e:	00000097          	auipc	ra,0x0
    80003e62:	d76080e7          	jalr	-650(ra) # 80003bd4 <readi>
    80003e66:	47c1                	li	a5,16
    80003e68:	fcf518e3          	bne	a0,a5,80003e38 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e6c:	fc045783          	lhu	a5,-64(s0)
    80003e70:	dfe1                	beqz	a5,80003e48 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e72:	fc240593          	addi	a1,s0,-62
    80003e76:	854e                	mv	a0,s3
    80003e78:	00000097          	auipc	ra,0x0
    80003e7c:	f6c080e7          	jalr	-148(ra) # 80003de4 <namecmp>
    80003e80:	f561                	bnez	a0,80003e48 <dirlookup+0x4a>
      if(poff)
    80003e82:	000a0463          	beqz	s4,80003e8a <dirlookup+0x8c>
        *poff = off;
    80003e86:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e8a:	fc045583          	lhu	a1,-64(s0)
    80003e8e:	00092503          	lw	a0,0(s2)
    80003e92:	fffff097          	auipc	ra,0xfffff
    80003e96:	75a080e7          	jalr	1882(ra) # 800035ec <iget>
    80003e9a:	a011                	j	80003e9e <dirlookup+0xa0>
  return 0;
    80003e9c:	4501                	li	a0,0
}
    80003e9e:	70e2                	ld	ra,56(sp)
    80003ea0:	7442                	ld	s0,48(sp)
    80003ea2:	74a2                	ld	s1,40(sp)
    80003ea4:	7902                	ld	s2,32(sp)
    80003ea6:	69e2                	ld	s3,24(sp)
    80003ea8:	6a42                	ld	s4,16(sp)
    80003eaa:	6121                	addi	sp,sp,64
    80003eac:	8082                	ret

0000000080003eae <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003eae:	711d                	addi	sp,sp,-96
    80003eb0:	ec86                	sd	ra,88(sp)
    80003eb2:	e8a2                	sd	s0,80(sp)
    80003eb4:	e4a6                	sd	s1,72(sp)
    80003eb6:	e0ca                	sd	s2,64(sp)
    80003eb8:	fc4e                	sd	s3,56(sp)
    80003eba:	f852                	sd	s4,48(sp)
    80003ebc:	f456                	sd	s5,40(sp)
    80003ebe:	f05a                	sd	s6,32(sp)
    80003ec0:	ec5e                	sd	s7,24(sp)
    80003ec2:	e862                	sd	s8,16(sp)
    80003ec4:	e466                	sd	s9,8(sp)
    80003ec6:	1080                	addi	s0,sp,96
    80003ec8:	84aa                	mv	s1,a0
    80003eca:	8aae                	mv	s5,a1
    80003ecc:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ece:	00054703          	lbu	a4,0(a0)
    80003ed2:	02f00793          	li	a5,47
    80003ed6:	02f70363          	beq	a4,a5,80003efc <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003eda:	ffffe097          	auipc	ra,0xffffe
    80003ede:	c76080e7          	jalr	-906(ra) # 80001b50 <myproc>
    80003ee2:	15053503          	ld	a0,336(a0)
    80003ee6:	00000097          	auipc	ra,0x0
    80003eea:	9fc080e7          	jalr	-1540(ra) # 800038e2 <idup>
    80003eee:	89aa                	mv	s3,a0
  while(*path == '/')
    80003ef0:	02f00913          	li	s2,47
  len = path - s;
    80003ef4:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003ef6:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ef8:	4b85                	li	s7,1
    80003efa:	a865                	j	80003fb2 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003efc:	4585                	li	a1,1
    80003efe:	4505                	li	a0,1
    80003f00:	fffff097          	auipc	ra,0xfffff
    80003f04:	6ec080e7          	jalr	1772(ra) # 800035ec <iget>
    80003f08:	89aa                	mv	s3,a0
    80003f0a:	b7dd                	j	80003ef0 <namex+0x42>
      iunlockput(ip);
    80003f0c:	854e                	mv	a0,s3
    80003f0e:	00000097          	auipc	ra,0x0
    80003f12:	c74080e7          	jalr	-908(ra) # 80003b82 <iunlockput>
      return 0;
    80003f16:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f18:	854e                	mv	a0,s3
    80003f1a:	60e6                	ld	ra,88(sp)
    80003f1c:	6446                	ld	s0,80(sp)
    80003f1e:	64a6                	ld	s1,72(sp)
    80003f20:	6906                	ld	s2,64(sp)
    80003f22:	79e2                	ld	s3,56(sp)
    80003f24:	7a42                	ld	s4,48(sp)
    80003f26:	7aa2                	ld	s5,40(sp)
    80003f28:	7b02                	ld	s6,32(sp)
    80003f2a:	6be2                	ld	s7,24(sp)
    80003f2c:	6c42                	ld	s8,16(sp)
    80003f2e:	6ca2                	ld	s9,8(sp)
    80003f30:	6125                	addi	sp,sp,96
    80003f32:	8082                	ret
      iunlock(ip);
    80003f34:	854e                	mv	a0,s3
    80003f36:	00000097          	auipc	ra,0x0
    80003f3a:	aac080e7          	jalr	-1364(ra) # 800039e2 <iunlock>
      return ip;
    80003f3e:	bfe9                	j	80003f18 <namex+0x6a>
      iunlockput(ip);
    80003f40:	854e                	mv	a0,s3
    80003f42:	00000097          	auipc	ra,0x0
    80003f46:	c40080e7          	jalr	-960(ra) # 80003b82 <iunlockput>
      return 0;
    80003f4a:	89e6                	mv	s3,s9
    80003f4c:	b7f1                	j	80003f18 <namex+0x6a>
  len = path - s;
    80003f4e:	40b48633          	sub	a2,s1,a1
    80003f52:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003f56:	099c5463          	bge	s8,s9,80003fde <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f5a:	4639                	li	a2,14
    80003f5c:	8552                	mv	a0,s4
    80003f5e:	ffffd097          	auipc	ra,0xffffd
    80003f62:	df8080e7          	jalr	-520(ra) # 80000d56 <memmove>
  while(*path == '/')
    80003f66:	0004c783          	lbu	a5,0(s1)
    80003f6a:	01279763          	bne	a5,s2,80003f78 <namex+0xca>
    path++;
    80003f6e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f70:	0004c783          	lbu	a5,0(s1)
    80003f74:	ff278de3          	beq	a5,s2,80003f6e <namex+0xc0>
    ilock(ip);
    80003f78:	854e                	mv	a0,s3
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	9a6080e7          	jalr	-1626(ra) # 80003920 <ilock>
    if(ip->type != T_DIR){
    80003f82:	04499783          	lh	a5,68(s3)
    80003f86:	f97793e3          	bne	a5,s7,80003f0c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f8a:	000a8563          	beqz	s5,80003f94 <namex+0xe6>
    80003f8e:	0004c783          	lbu	a5,0(s1)
    80003f92:	d3cd                	beqz	a5,80003f34 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f94:	865a                	mv	a2,s6
    80003f96:	85d2                	mv	a1,s4
    80003f98:	854e                	mv	a0,s3
    80003f9a:	00000097          	auipc	ra,0x0
    80003f9e:	e64080e7          	jalr	-412(ra) # 80003dfe <dirlookup>
    80003fa2:	8caa                	mv	s9,a0
    80003fa4:	dd51                	beqz	a0,80003f40 <namex+0x92>
    iunlockput(ip);
    80003fa6:	854e                	mv	a0,s3
    80003fa8:	00000097          	auipc	ra,0x0
    80003fac:	bda080e7          	jalr	-1062(ra) # 80003b82 <iunlockput>
    ip = next;
    80003fb0:	89e6                	mv	s3,s9
  while(*path == '/')
    80003fb2:	0004c783          	lbu	a5,0(s1)
    80003fb6:	05279763          	bne	a5,s2,80004004 <namex+0x156>
    path++;
    80003fba:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fbc:	0004c783          	lbu	a5,0(s1)
    80003fc0:	ff278de3          	beq	a5,s2,80003fba <namex+0x10c>
  if(*path == 0)
    80003fc4:	c79d                	beqz	a5,80003ff2 <namex+0x144>
    path++;
    80003fc6:	85a6                	mv	a1,s1
  len = path - s;
    80003fc8:	8cda                	mv	s9,s6
    80003fca:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003fcc:	01278963          	beq	a5,s2,80003fde <namex+0x130>
    80003fd0:	dfbd                	beqz	a5,80003f4e <namex+0xa0>
    path++;
    80003fd2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003fd4:	0004c783          	lbu	a5,0(s1)
    80003fd8:	ff279ce3          	bne	a5,s2,80003fd0 <namex+0x122>
    80003fdc:	bf8d                	j	80003f4e <namex+0xa0>
    memmove(name, s, len);
    80003fde:	2601                	sext.w	a2,a2
    80003fe0:	8552                	mv	a0,s4
    80003fe2:	ffffd097          	auipc	ra,0xffffd
    80003fe6:	d74080e7          	jalr	-652(ra) # 80000d56 <memmove>
    name[len] = 0;
    80003fea:	9cd2                	add	s9,s9,s4
    80003fec:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003ff0:	bf9d                	j	80003f66 <namex+0xb8>
  if(nameiparent){
    80003ff2:	f20a83e3          	beqz	s5,80003f18 <namex+0x6a>
    iput(ip);
    80003ff6:	854e                	mv	a0,s3
    80003ff8:	00000097          	auipc	ra,0x0
    80003ffc:	ae2080e7          	jalr	-1310(ra) # 80003ada <iput>
    return 0;
    80004000:	4981                	li	s3,0
    80004002:	bf19                	j	80003f18 <namex+0x6a>
  if(*path == 0)
    80004004:	d7fd                	beqz	a5,80003ff2 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004006:	0004c783          	lbu	a5,0(s1)
    8000400a:	85a6                	mv	a1,s1
    8000400c:	b7d1                	j	80003fd0 <namex+0x122>

000000008000400e <dirlink>:
{
    8000400e:	7139                	addi	sp,sp,-64
    80004010:	fc06                	sd	ra,56(sp)
    80004012:	f822                	sd	s0,48(sp)
    80004014:	f426                	sd	s1,40(sp)
    80004016:	f04a                	sd	s2,32(sp)
    80004018:	ec4e                	sd	s3,24(sp)
    8000401a:	e852                	sd	s4,16(sp)
    8000401c:	0080                	addi	s0,sp,64
    8000401e:	892a                	mv	s2,a0
    80004020:	8a2e                	mv	s4,a1
    80004022:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004024:	4601                	li	a2,0
    80004026:	00000097          	auipc	ra,0x0
    8000402a:	dd8080e7          	jalr	-552(ra) # 80003dfe <dirlookup>
    8000402e:	e93d                	bnez	a0,800040a4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004030:	04c92483          	lw	s1,76(s2)
    80004034:	c49d                	beqz	s1,80004062 <dirlink+0x54>
    80004036:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004038:	4741                	li	a4,16
    8000403a:	86a6                	mv	a3,s1
    8000403c:	fc040613          	addi	a2,s0,-64
    80004040:	4581                	li	a1,0
    80004042:	854a                	mv	a0,s2
    80004044:	00000097          	auipc	ra,0x0
    80004048:	b90080e7          	jalr	-1136(ra) # 80003bd4 <readi>
    8000404c:	47c1                	li	a5,16
    8000404e:	06f51163          	bne	a0,a5,800040b0 <dirlink+0xa2>
    if(de.inum == 0)
    80004052:	fc045783          	lhu	a5,-64(s0)
    80004056:	c791                	beqz	a5,80004062 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004058:	24c1                	addiw	s1,s1,16
    8000405a:	04c92783          	lw	a5,76(s2)
    8000405e:	fcf4ede3          	bltu	s1,a5,80004038 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004062:	4639                	li	a2,14
    80004064:	85d2                	mv	a1,s4
    80004066:	fc240513          	addi	a0,s0,-62
    8000406a:	ffffd097          	auipc	ra,0xffffd
    8000406e:	da4080e7          	jalr	-604(ra) # 80000e0e <strncpy>
  de.inum = inum;
    80004072:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004076:	4741                	li	a4,16
    80004078:	86a6                	mv	a3,s1
    8000407a:	fc040613          	addi	a2,s0,-64
    8000407e:	4581                	li	a1,0
    80004080:	854a                	mv	a0,s2
    80004082:	00000097          	auipc	ra,0x0
    80004086:	c48080e7          	jalr	-952(ra) # 80003cca <writei>
    8000408a:	872a                	mv	a4,a0
    8000408c:	47c1                	li	a5,16
  return 0;
    8000408e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004090:	02f71863          	bne	a4,a5,800040c0 <dirlink+0xb2>
}
    80004094:	70e2                	ld	ra,56(sp)
    80004096:	7442                	ld	s0,48(sp)
    80004098:	74a2                	ld	s1,40(sp)
    8000409a:	7902                	ld	s2,32(sp)
    8000409c:	69e2                	ld	s3,24(sp)
    8000409e:	6a42                	ld	s4,16(sp)
    800040a0:	6121                	addi	sp,sp,64
    800040a2:	8082                	ret
    iput(ip);
    800040a4:	00000097          	auipc	ra,0x0
    800040a8:	a36080e7          	jalr	-1482(ra) # 80003ada <iput>
    return -1;
    800040ac:	557d                	li	a0,-1
    800040ae:	b7dd                	j	80004094 <dirlink+0x86>
      panic("dirlink read");
    800040b0:	00004517          	auipc	a0,0x4
    800040b4:	5d850513          	addi	a0,a0,1496 # 80008688 <syscalls+0x1c8>
    800040b8:	ffffc097          	auipc	ra,0xffffc
    800040bc:	48a080e7          	jalr	1162(ra) # 80000542 <panic>
    panic("dirlink");
    800040c0:	00004517          	auipc	a0,0x4
    800040c4:	6e050513          	addi	a0,a0,1760 # 800087a0 <syscalls+0x2e0>
    800040c8:	ffffc097          	auipc	ra,0xffffc
    800040cc:	47a080e7          	jalr	1146(ra) # 80000542 <panic>

00000000800040d0 <namei>:

struct inode*
namei(char *path)
{
    800040d0:	1101                	addi	sp,sp,-32
    800040d2:	ec06                	sd	ra,24(sp)
    800040d4:	e822                	sd	s0,16(sp)
    800040d6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040d8:	fe040613          	addi	a2,s0,-32
    800040dc:	4581                	li	a1,0
    800040de:	00000097          	auipc	ra,0x0
    800040e2:	dd0080e7          	jalr	-560(ra) # 80003eae <namex>
}
    800040e6:	60e2                	ld	ra,24(sp)
    800040e8:	6442                	ld	s0,16(sp)
    800040ea:	6105                	addi	sp,sp,32
    800040ec:	8082                	ret

00000000800040ee <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040ee:	1141                	addi	sp,sp,-16
    800040f0:	e406                	sd	ra,8(sp)
    800040f2:	e022                	sd	s0,0(sp)
    800040f4:	0800                	addi	s0,sp,16
    800040f6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040f8:	4585                	li	a1,1
    800040fa:	00000097          	auipc	ra,0x0
    800040fe:	db4080e7          	jalr	-588(ra) # 80003eae <namex>
}
    80004102:	60a2                	ld	ra,8(sp)
    80004104:	6402                	ld	s0,0(sp)
    80004106:	0141                	addi	sp,sp,16
    80004108:	8082                	ret

000000008000410a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000410a:	1101                	addi	sp,sp,-32
    8000410c:	ec06                	sd	ra,24(sp)
    8000410e:	e822                	sd	s0,16(sp)
    80004110:	e426                	sd	s1,8(sp)
    80004112:	e04a                	sd	s2,0(sp)
    80004114:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004116:	0001e917          	auipc	s2,0x1e
    8000411a:	9f290913          	addi	s2,s2,-1550 # 80021b08 <log>
    8000411e:	01892583          	lw	a1,24(s2)
    80004122:	02892503          	lw	a0,40(s2)
    80004126:	fffff097          	auipc	ra,0xfffff
    8000412a:	ff8080e7          	jalr	-8(ra) # 8000311e <bread>
    8000412e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004130:	02c92683          	lw	a3,44(s2)
    80004134:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004136:	02d05763          	blez	a3,80004164 <write_head+0x5a>
    8000413a:	0001e797          	auipc	a5,0x1e
    8000413e:	9fe78793          	addi	a5,a5,-1538 # 80021b38 <log+0x30>
    80004142:	05c50713          	addi	a4,a0,92
    80004146:	36fd                	addiw	a3,a3,-1
    80004148:	1682                	slli	a3,a3,0x20
    8000414a:	9281                	srli	a3,a3,0x20
    8000414c:	068a                	slli	a3,a3,0x2
    8000414e:	0001e617          	auipc	a2,0x1e
    80004152:	9ee60613          	addi	a2,a2,-1554 # 80021b3c <log+0x34>
    80004156:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004158:	4390                	lw	a2,0(a5)
    8000415a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000415c:	0791                	addi	a5,a5,4
    8000415e:	0711                	addi	a4,a4,4
    80004160:	fed79ce3          	bne	a5,a3,80004158 <write_head+0x4e>
  }
  bwrite(buf);
    80004164:	8526                	mv	a0,s1
    80004166:	fffff097          	auipc	ra,0xfffff
    8000416a:	0aa080e7          	jalr	170(ra) # 80003210 <bwrite>
  brelse(buf);
    8000416e:	8526                	mv	a0,s1
    80004170:	fffff097          	auipc	ra,0xfffff
    80004174:	0de080e7          	jalr	222(ra) # 8000324e <brelse>
}
    80004178:	60e2                	ld	ra,24(sp)
    8000417a:	6442                	ld	s0,16(sp)
    8000417c:	64a2                	ld	s1,8(sp)
    8000417e:	6902                	ld	s2,0(sp)
    80004180:	6105                	addi	sp,sp,32
    80004182:	8082                	ret

0000000080004184 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004184:	0001e797          	auipc	a5,0x1e
    80004188:	9b07a783          	lw	a5,-1616(a5) # 80021b34 <log+0x2c>
    8000418c:	0af05663          	blez	a5,80004238 <install_trans+0xb4>
{
    80004190:	7139                	addi	sp,sp,-64
    80004192:	fc06                	sd	ra,56(sp)
    80004194:	f822                	sd	s0,48(sp)
    80004196:	f426                	sd	s1,40(sp)
    80004198:	f04a                	sd	s2,32(sp)
    8000419a:	ec4e                	sd	s3,24(sp)
    8000419c:	e852                	sd	s4,16(sp)
    8000419e:	e456                	sd	s5,8(sp)
    800041a0:	0080                	addi	s0,sp,64
    800041a2:	0001ea97          	auipc	s5,0x1e
    800041a6:	996a8a93          	addi	s5,s5,-1642 # 80021b38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041aa:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041ac:	0001e997          	auipc	s3,0x1e
    800041b0:	95c98993          	addi	s3,s3,-1700 # 80021b08 <log>
    800041b4:	0189a583          	lw	a1,24(s3)
    800041b8:	014585bb          	addw	a1,a1,s4
    800041bc:	2585                	addiw	a1,a1,1
    800041be:	0289a503          	lw	a0,40(s3)
    800041c2:	fffff097          	auipc	ra,0xfffff
    800041c6:	f5c080e7          	jalr	-164(ra) # 8000311e <bread>
    800041ca:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041cc:	000aa583          	lw	a1,0(s5)
    800041d0:	0289a503          	lw	a0,40(s3)
    800041d4:	fffff097          	auipc	ra,0xfffff
    800041d8:	f4a080e7          	jalr	-182(ra) # 8000311e <bread>
    800041dc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041de:	40000613          	li	a2,1024
    800041e2:	05890593          	addi	a1,s2,88
    800041e6:	05850513          	addi	a0,a0,88
    800041ea:	ffffd097          	auipc	ra,0xffffd
    800041ee:	b6c080e7          	jalr	-1172(ra) # 80000d56 <memmove>
    bwrite(dbuf);  // write dst to disk
    800041f2:	8526                	mv	a0,s1
    800041f4:	fffff097          	auipc	ra,0xfffff
    800041f8:	01c080e7          	jalr	28(ra) # 80003210 <bwrite>
    bunpin(dbuf);
    800041fc:	8526                	mv	a0,s1
    800041fe:	fffff097          	auipc	ra,0xfffff
    80004202:	12a080e7          	jalr	298(ra) # 80003328 <bunpin>
    brelse(lbuf);
    80004206:	854a                	mv	a0,s2
    80004208:	fffff097          	auipc	ra,0xfffff
    8000420c:	046080e7          	jalr	70(ra) # 8000324e <brelse>
    brelse(dbuf);
    80004210:	8526                	mv	a0,s1
    80004212:	fffff097          	auipc	ra,0xfffff
    80004216:	03c080e7          	jalr	60(ra) # 8000324e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000421a:	2a05                	addiw	s4,s4,1
    8000421c:	0a91                	addi	s5,s5,4
    8000421e:	02c9a783          	lw	a5,44(s3)
    80004222:	f8fa49e3          	blt	s4,a5,800041b4 <install_trans+0x30>
}
    80004226:	70e2                	ld	ra,56(sp)
    80004228:	7442                	ld	s0,48(sp)
    8000422a:	74a2                	ld	s1,40(sp)
    8000422c:	7902                	ld	s2,32(sp)
    8000422e:	69e2                	ld	s3,24(sp)
    80004230:	6a42                	ld	s4,16(sp)
    80004232:	6aa2                	ld	s5,8(sp)
    80004234:	6121                	addi	sp,sp,64
    80004236:	8082                	ret
    80004238:	8082                	ret

000000008000423a <initlog>:
{
    8000423a:	7179                	addi	sp,sp,-48
    8000423c:	f406                	sd	ra,40(sp)
    8000423e:	f022                	sd	s0,32(sp)
    80004240:	ec26                	sd	s1,24(sp)
    80004242:	e84a                	sd	s2,16(sp)
    80004244:	e44e                	sd	s3,8(sp)
    80004246:	1800                	addi	s0,sp,48
    80004248:	892a                	mv	s2,a0
    8000424a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000424c:	0001e497          	auipc	s1,0x1e
    80004250:	8bc48493          	addi	s1,s1,-1860 # 80021b08 <log>
    80004254:	00004597          	auipc	a1,0x4
    80004258:	44458593          	addi	a1,a1,1092 # 80008698 <syscalls+0x1d8>
    8000425c:	8526                	mv	a0,s1
    8000425e:	ffffd097          	auipc	ra,0xffffd
    80004262:	910080e7          	jalr	-1776(ra) # 80000b6e <initlock>
  log.start = sb->logstart;
    80004266:	0149a583          	lw	a1,20(s3)
    8000426a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000426c:	0109a783          	lw	a5,16(s3)
    80004270:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004272:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004276:	854a                	mv	a0,s2
    80004278:	fffff097          	auipc	ra,0xfffff
    8000427c:	ea6080e7          	jalr	-346(ra) # 8000311e <bread>
  log.lh.n = lh->n;
    80004280:	4d34                	lw	a3,88(a0)
    80004282:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004284:	02d05563          	blez	a3,800042ae <initlog+0x74>
    80004288:	05c50793          	addi	a5,a0,92
    8000428c:	0001e717          	auipc	a4,0x1e
    80004290:	8ac70713          	addi	a4,a4,-1876 # 80021b38 <log+0x30>
    80004294:	36fd                	addiw	a3,a3,-1
    80004296:	1682                	slli	a3,a3,0x20
    80004298:	9281                	srli	a3,a3,0x20
    8000429a:	068a                	slli	a3,a3,0x2
    8000429c:	06050613          	addi	a2,a0,96
    800042a0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800042a2:	4390                	lw	a2,0(a5)
    800042a4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042a6:	0791                	addi	a5,a5,4
    800042a8:	0711                	addi	a4,a4,4
    800042aa:	fed79ce3          	bne	a5,a3,800042a2 <initlog+0x68>
  brelse(buf);
    800042ae:	fffff097          	auipc	ra,0xfffff
    800042b2:	fa0080e7          	jalr	-96(ra) # 8000324e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800042b6:	00000097          	auipc	ra,0x0
    800042ba:	ece080e7          	jalr	-306(ra) # 80004184 <install_trans>
  log.lh.n = 0;
    800042be:	0001e797          	auipc	a5,0x1e
    800042c2:	8607ab23          	sw	zero,-1930(a5) # 80021b34 <log+0x2c>
  write_head(); // clear the log
    800042c6:	00000097          	auipc	ra,0x0
    800042ca:	e44080e7          	jalr	-444(ra) # 8000410a <write_head>
}
    800042ce:	70a2                	ld	ra,40(sp)
    800042d0:	7402                	ld	s0,32(sp)
    800042d2:	64e2                	ld	s1,24(sp)
    800042d4:	6942                	ld	s2,16(sp)
    800042d6:	69a2                	ld	s3,8(sp)
    800042d8:	6145                	addi	sp,sp,48
    800042da:	8082                	ret

00000000800042dc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042dc:	1101                	addi	sp,sp,-32
    800042de:	ec06                	sd	ra,24(sp)
    800042e0:	e822                	sd	s0,16(sp)
    800042e2:	e426                	sd	s1,8(sp)
    800042e4:	e04a                	sd	s2,0(sp)
    800042e6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042e8:	0001e517          	auipc	a0,0x1e
    800042ec:	82050513          	addi	a0,a0,-2016 # 80021b08 <log>
    800042f0:	ffffd097          	auipc	ra,0xffffd
    800042f4:	90e080e7          	jalr	-1778(ra) # 80000bfe <acquire>
  while(1){
    if(log.committing){
    800042f8:	0001e497          	auipc	s1,0x1e
    800042fc:	81048493          	addi	s1,s1,-2032 # 80021b08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004300:	4979                	li	s2,30
    80004302:	a039                	j	80004310 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004304:	85a6                	mv	a1,s1
    80004306:	8526                	mv	a0,s1
    80004308:	ffffe097          	auipc	ra,0xffffe
    8000430c:	202080e7          	jalr	514(ra) # 8000250a <sleep>
    if(log.committing){
    80004310:	50dc                	lw	a5,36(s1)
    80004312:	fbed                	bnez	a5,80004304 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004314:	509c                	lw	a5,32(s1)
    80004316:	0017871b          	addiw	a4,a5,1
    8000431a:	0007069b          	sext.w	a3,a4
    8000431e:	0027179b          	slliw	a5,a4,0x2
    80004322:	9fb9                	addw	a5,a5,a4
    80004324:	0017979b          	slliw	a5,a5,0x1
    80004328:	54d8                	lw	a4,44(s1)
    8000432a:	9fb9                	addw	a5,a5,a4
    8000432c:	00f95963          	bge	s2,a5,8000433e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004330:	85a6                	mv	a1,s1
    80004332:	8526                	mv	a0,s1
    80004334:	ffffe097          	auipc	ra,0xffffe
    80004338:	1d6080e7          	jalr	470(ra) # 8000250a <sleep>
    8000433c:	bfd1                	j	80004310 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000433e:	0001d517          	auipc	a0,0x1d
    80004342:	7ca50513          	addi	a0,a0,1994 # 80021b08 <log>
    80004346:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004348:	ffffd097          	auipc	ra,0xffffd
    8000434c:	96a080e7          	jalr	-1686(ra) # 80000cb2 <release>
      break;
    }
  }
}
    80004350:	60e2                	ld	ra,24(sp)
    80004352:	6442                	ld	s0,16(sp)
    80004354:	64a2                	ld	s1,8(sp)
    80004356:	6902                	ld	s2,0(sp)
    80004358:	6105                	addi	sp,sp,32
    8000435a:	8082                	ret

000000008000435c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000435c:	7139                	addi	sp,sp,-64
    8000435e:	fc06                	sd	ra,56(sp)
    80004360:	f822                	sd	s0,48(sp)
    80004362:	f426                	sd	s1,40(sp)
    80004364:	f04a                	sd	s2,32(sp)
    80004366:	ec4e                	sd	s3,24(sp)
    80004368:	e852                	sd	s4,16(sp)
    8000436a:	e456                	sd	s5,8(sp)
    8000436c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000436e:	0001d497          	auipc	s1,0x1d
    80004372:	79a48493          	addi	s1,s1,1946 # 80021b08 <log>
    80004376:	8526                	mv	a0,s1
    80004378:	ffffd097          	auipc	ra,0xffffd
    8000437c:	886080e7          	jalr	-1914(ra) # 80000bfe <acquire>
  log.outstanding -= 1;
    80004380:	509c                	lw	a5,32(s1)
    80004382:	37fd                	addiw	a5,a5,-1
    80004384:	0007891b          	sext.w	s2,a5
    80004388:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000438a:	50dc                	lw	a5,36(s1)
    8000438c:	e7b9                	bnez	a5,800043da <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000438e:	04091e63          	bnez	s2,800043ea <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004392:	0001d497          	auipc	s1,0x1d
    80004396:	77648493          	addi	s1,s1,1910 # 80021b08 <log>
    8000439a:	4785                	li	a5,1
    8000439c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000439e:	8526                	mv	a0,s1
    800043a0:	ffffd097          	auipc	ra,0xffffd
    800043a4:	912080e7          	jalr	-1774(ra) # 80000cb2 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043a8:	54dc                	lw	a5,44(s1)
    800043aa:	06f04763          	bgtz	a5,80004418 <end_op+0xbc>
    acquire(&log.lock);
    800043ae:	0001d497          	auipc	s1,0x1d
    800043b2:	75a48493          	addi	s1,s1,1882 # 80021b08 <log>
    800043b6:	8526                	mv	a0,s1
    800043b8:	ffffd097          	auipc	ra,0xffffd
    800043bc:	846080e7          	jalr	-1978(ra) # 80000bfe <acquire>
    log.committing = 0;
    800043c0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043c4:	8526                	mv	a0,s1
    800043c6:	ffffe097          	auipc	ra,0xffffe
    800043ca:	2c4080e7          	jalr	708(ra) # 8000268a <wakeup>
    release(&log.lock);
    800043ce:	8526                	mv	a0,s1
    800043d0:	ffffd097          	auipc	ra,0xffffd
    800043d4:	8e2080e7          	jalr	-1822(ra) # 80000cb2 <release>
}
    800043d8:	a03d                	j	80004406 <end_op+0xaa>
    panic("log.committing");
    800043da:	00004517          	auipc	a0,0x4
    800043de:	2c650513          	addi	a0,a0,710 # 800086a0 <syscalls+0x1e0>
    800043e2:	ffffc097          	auipc	ra,0xffffc
    800043e6:	160080e7          	jalr	352(ra) # 80000542 <panic>
    wakeup(&log);
    800043ea:	0001d497          	auipc	s1,0x1d
    800043ee:	71e48493          	addi	s1,s1,1822 # 80021b08 <log>
    800043f2:	8526                	mv	a0,s1
    800043f4:	ffffe097          	auipc	ra,0xffffe
    800043f8:	296080e7          	jalr	662(ra) # 8000268a <wakeup>
  release(&log.lock);
    800043fc:	8526                	mv	a0,s1
    800043fe:	ffffd097          	auipc	ra,0xffffd
    80004402:	8b4080e7          	jalr	-1868(ra) # 80000cb2 <release>
}
    80004406:	70e2                	ld	ra,56(sp)
    80004408:	7442                	ld	s0,48(sp)
    8000440a:	74a2                	ld	s1,40(sp)
    8000440c:	7902                	ld	s2,32(sp)
    8000440e:	69e2                	ld	s3,24(sp)
    80004410:	6a42                	ld	s4,16(sp)
    80004412:	6aa2                	ld	s5,8(sp)
    80004414:	6121                	addi	sp,sp,64
    80004416:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004418:	0001da97          	auipc	s5,0x1d
    8000441c:	720a8a93          	addi	s5,s5,1824 # 80021b38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004420:	0001da17          	auipc	s4,0x1d
    80004424:	6e8a0a13          	addi	s4,s4,1768 # 80021b08 <log>
    80004428:	018a2583          	lw	a1,24(s4)
    8000442c:	012585bb          	addw	a1,a1,s2
    80004430:	2585                	addiw	a1,a1,1
    80004432:	028a2503          	lw	a0,40(s4)
    80004436:	fffff097          	auipc	ra,0xfffff
    8000443a:	ce8080e7          	jalr	-792(ra) # 8000311e <bread>
    8000443e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004440:	000aa583          	lw	a1,0(s5)
    80004444:	028a2503          	lw	a0,40(s4)
    80004448:	fffff097          	auipc	ra,0xfffff
    8000444c:	cd6080e7          	jalr	-810(ra) # 8000311e <bread>
    80004450:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004452:	40000613          	li	a2,1024
    80004456:	05850593          	addi	a1,a0,88
    8000445a:	05848513          	addi	a0,s1,88
    8000445e:	ffffd097          	auipc	ra,0xffffd
    80004462:	8f8080e7          	jalr	-1800(ra) # 80000d56 <memmove>
    bwrite(to);  // write the log
    80004466:	8526                	mv	a0,s1
    80004468:	fffff097          	auipc	ra,0xfffff
    8000446c:	da8080e7          	jalr	-600(ra) # 80003210 <bwrite>
    brelse(from);
    80004470:	854e                	mv	a0,s3
    80004472:	fffff097          	auipc	ra,0xfffff
    80004476:	ddc080e7          	jalr	-548(ra) # 8000324e <brelse>
    brelse(to);
    8000447a:	8526                	mv	a0,s1
    8000447c:	fffff097          	auipc	ra,0xfffff
    80004480:	dd2080e7          	jalr	-558(ra) # 8000324e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004484:	2905                	addiw	s2,s2,1
    80004486:	0a91                	addi	s5,s5,4
    80004488:	02ca2783          	lw	a5,44(s4)
    8000448c:	f8f94ee3          	blt	s2,a5,80004428 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004490:	00000097          	auipc	ra,0x0
    80004494:	c7a080e7          	jalr	-902(ra) # 8000410a <write_head>
    install_trans(); // Now install writes to home locations
    80004498:	00000097          	auipc	ra,0x0
    8000449c:	cec080e7          	jalr	-788(ra) # 80004184 <install_trans>
    log.lh.n = 0;
    800044a0:	0001d797          	auipc	a5,0x1d
    800044a4:	6807aa23          	sw	zero,1684(a5) # 80021b34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044a8:	00000097          	auipc	ra,0x0
    800044ac:	c62080e7          	jalr	-926(ra) # 8000410a <write_head>
    800044b0:	bdfd                	j	800043ae <end_op+0x52>

00000000800044b2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044b2:	1101                	addi	sp,sp,-32
    800044b4:	ec06                	sd	ra,24(sp)
    800044b6:	e822                	sd	s0,16(sp)
    800044b8:	e426                	sd	s1,8(sp)
    800044ba:	e04a                	sd	s2,0(sp)
    800044bc:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044be:	0001d717          	auipc	a4,0x1d
    800044c2:	67672703          	lw	a4,1654(a4) # 80021b34 <log+0x2c>
    800044c6:	47f5                	li	a5,29
    800044c8:	08e7c063          	blt	a5,a4,80004548 <log_write+0x96>
    800044cc:	84aa                	mv	s1,a0
    800044ce:	0001d797          	auipc	a5,0x1d
    800044d2:	6567a783          	lw	a5,1622(a5) # 80021b24 <log+0x1c>
    800044d6:	37fd                	addiw	a5,a5,-1
    800044d8:	06f75863          	bge	a4,a5,80004548 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044dc:	0001d797          	auipc	a5,0x1d
    800044e0:	64c7a783          	lw	a5,1612(a5) # 80021b28 <log+0x20>
    800044e4:	06f05a63          	blez	a5,80004558 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800044e8:	0001d917          	auipc	s2,0x1d
    800044ec:	62090913          	addi	s2,s2,1568 # 80021b08 <log>
    800044f0:	854a                	mv	a0,s2
    800044f2:	ffffc097          	auipc	ra,0xffffc
    800044f6:	70c080e7          	jalr	1804(ra) # 80000bfe <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800044fa:	02c92603          	lw	a2,44(s2)
    800044fe:	06c05563          	blez	a2,80004568 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004502:	44cc                	lw	a1,12(s1)
    80004504:	0001d717          	auipc	a4,0x1d
    80004508:	63470713          	addi	a4,a4,1588 # 80021b38 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000450c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000450e:	4314                	lw	a3,0(a4)
    80004510:	04b68d63          	beq	a3,a1,8000456a <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004514:	2785                	addiw	a5,a5,1
    80004516:	0711                	addi	a4,a4,4
    80004518:	fec79be3          	bne	a5,a2,8000450e <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000451c:	0621                	addi	a2,a2,8
    8000451e:	060a                	slli	a2,a2,0x2
    80004520:	0001d797          	auipc	a5,0x1d
    80004524:	5e878793          	addi	a5,a5,1512 # 80021b08 <log>
    80004528:	963e                	add	a2,a2,a5
    8000452a:	44dc                	lw	a5,12(s1)
    8000452c:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000452e:	8526                	mv	a0,s1
    80004530:	fffff097          	auipc	ra,0xfffff
    80004534:	dbc080e7          	jalr	-580(ra) # 800032ec <bpin>
    log.lh.n++;
    80004538:	0001d717          	auipc	a4,0x1d
    8000453c:	5d070713          	addi	a4,a4,1488 # 80021b08 <log>
    80004540:	575c                	lw	a5,44(a4)
    80004542:	2785                	addiw	a5,a5,1
    80004544:	d75c                	sw	a5,44(a4)
    80004546:	a83d                	j	80004584 <log_write+0xd2>
    panic("too big a transaction");
    80004548:	00004517          	auipc	a0,0x4
    8000454c:	16850513          	addi	a0,a0,360 # 800086b0 <syscalls+0x1f0>
    80004550:	ffffc097          	auipc	ra,0xffffc
    80004554:	ff2080e7          	jalr	-14(ra) # 80000542 <panic>
    panic("log_write outside of trans");
    80004558:	00004517          	auipc	a0,0x4
    8000455c:	17050513          	addi	a0,a0,368 # 800086c8 <syscalls+0x208>
    80004560:	ffffc097          	auipc	ra,0xffffc
    80004564:	fe2080e7          	jalr	-30(ra) # 80000542 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004568:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    8000456a:	00878713          	addi	a4,a5,8
    8000456e:	00271693          	slli	a3,a4,0x2
    80004572:	0001d717          	auipc	a4,0x1d
    80004576:	59670713          	addi	a4,a4,1430 # 80021b08 <log>
    8000457a:	9736                	add	a4,a4,a3
    8000457c:	44d4                	lw	a3,12(s1)
    8000457e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004580:	faf607e3          	beq	a2,a5,8000452e <log_write+0x7c>
  }
  release(&log.lock);
    80004584:	0001d517          	auipc	a0,0x1d
    80004588:	58450513          	addi	a0,a0,1412 # 80021b08 <log>
    8000458c:	ffffc097          	auipc	ra,0xffffc
    80004590:	726080e7          	jalr	1830(ra) # 80000cb2 <release>
}
    80004594:	60e2                	ld	ra,24(sp)
    80004596:	6442                	ld	s0,16(sp)
    80004598:	64a2                	ld	s1,8(sp)
    8000459a:	6902                	ld	s2,0(sp)
    8000459c:	6105                	addi	sp,sp,32
    8000459e:	8082                	ret

00000000800045a0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045a0:	1101                	addi	sp,sp,-32
    800045a2:	ec06                	sd	ra,24(sp)
    800045a4:	e822                	sd	s0,16(sp)
    800045a6:	e426                	sd	s1,8(sp)
    800045a8:	e04a                	sd	s2,0(sp)
    800045aa:	1000                	addi	s0,sp,32
    800045ac:	84aa                	mv	s1,a0
    800045ae:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045b0:	00004597          	auipc	a1,0x4
    800045b4:	13858593          	addi	a1,a1,312 # 800086e8 <syscalls+0x228>
    800045b8:	0521                	addi	a0,a0,8
    800045ba:	ffffc097          	auipc	ra,0xffffc
    800045be:	5b4080e7          	jalr	1460(ra) # 80000b6e <initlock>
  lk->name = name;
    800045c2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045c6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045ca:	0204a423          	sw	zero,40(s1)
}
    800045ce:	60e2                	ld	ra,24(sp)
    800045d0:	6442                	ld	s0,16(sp)
    800045d2:	64a2                	ld	s1,8(sp)
    800045d4:	6902                	ld	s2,0(sp)
    800045d6:	6105                	addi	sp,sp,32
    800045d8:	8082                	ret

00000000800045da <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045da:	1101                	addi	sp,sp,-32
    800045dc:	ec06                	sd	ra,24(sp)
    800045de:	e822                	sd	s0,16(sp)
    800045e0:	e426                	sd	s1,8(sp)
    800045e2:	e04a                	sd	s2,0(sp)
    800045e4:	1000                	addi	s0,sp,32
    800045e6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045e8:	00850913          	addi	s2,a0,8
    800045ec:	854a                	mv	a0,s2
    800045ee:	ffffc097          	auipc	ra,0xffffc
    800045f2:	610080e7          	jalr	1552(ra) # 80000bfe <acquire>
  while (lk->locked) {
    800045f6:	409c                	lw	a5,0(s1)
    800045f8:	cb89                	beqz	a5,8000460a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045fa:	85ca                	mv	a1,s2
    800045fc:	8526                	mv	a0,s1
    800045fe:	ffffe097          	auipc	ra,0xffffe
    80004602:	f0c080e7          	jalr	-244(ra) # 8000250a <sleep>
  while (lk->locked) {
    80004606:	409c                	lw	a5,0(s1)
    80004608:	fbed                	bnez	a5,800045fa <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000460a:	4785                	li	a5,1
    8000460c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000460e:	ffffd097          	auipc	ra,0xffffd
    80004612:	542080e7          	jalr	1346(ra) # 80001b50 <myproc>
    80004616:	5d1c                	lw	a5,56(a0)
    80004618:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000461a:	854a                	mv	a0,s2
    8000461c:	ffffc097          	auipc	ra,0xffffc
    80004620:	696080e7          	jalr	1686(ra) # 80000cb2 <release>
}
    80004624:	60e2                	ld	ra,24(sp)
    80004626:	6442                	ld	s0,16(sp)
    80004628:	64a2                	ld	s1,8(sp)
    8000462a:	6902                	ld	s2,0(sp)
    8000462c:	6105                	addi	sp,sp,32
    8000462e:	8082                	ret

0000000080004630 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004630:	1101                	addi	sp,sp,-32
    80004632:	ec06                	sd	ra,24(sp)
    80004634:	e822                	sd	s0,16(sp)
    80004636:	e426                	sd	s1,8(sp)
    80004638:	e04a                	sd	s2,0(sp)
    8000463a:	1000                	addi	s0,sp,32
    8000463c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000463e:	00850913          	addi	s2,a0,8
    80004642:	854a                	mv	a0,s2
    80004644:	ffffc097          	auipc	ra,0xffffc
    80004648:	5ba080e7          	jalr	1466(ra) # 80000bfe <acquire>
  lk->locked = 0;
    8000464c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004650:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004654:	8526                	mv	a0,s1
    80004656:	ffffe097          	auipc	ra,0xffffe
    8000465a:	034080e7          	jalr	52(ra) # 8000268a <wakeup>
  release(&lk->lk);
    8000465e:	854a                	mv	a0,s2
    80004660:	ffffc097          	auipc	ra,0xffffc
    80004664:	652080e7          	jalr	1618(ra) # 80000cb2 <release>
}
    80004668:	60e2                	ld	ra,24(sp)
    8000466a:	6442                	ld	s0,16(sp)
    8000466c:	64a2                	ld	s1,8(sp)
    8000466e:	6902                	ld	s2,0(sp)
    80004670:	6105                	addi	sp,sp,32
    80004672:	8082                	ret

0000000080004674 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004674:	7179                	addi	sp,sp,-48
    80004676:	f406                	sd	ra,40(sp)
    80004678:	f022                	sd	s0,32(sp)
    8000467a:	ec26                	sd	s1,24(sp)
    8000467c:	e84a                	sd	s2,16(sp)
    8000467e:	e44e                	sd	s3,8(sp)
    80004680:	1800                	addi	s0,sp,48
    80004682:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004684:	00850913          	addi	s2,a0,8
    80004688:	854a                	mv	a0,s2
    8000468a:	ffffc097          	auipc	ra,0xffffc
    8000468e:	574080e7          	jalr	1396(ra) # 80000bfe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004692:	409c                	lw	a5,0(s1)
    80004694:	ef99                	bnez	a5,800046b2 <holdingsleep+0x3e>
    80004696:	4481                	li	s1,0
  release(&lk->lk);
    80004698:	854a                	mv	a0,s2
    8000469a:	ffffc097          	auipc	ra,0xffffc
    8000469e:	618080e7          	jalr	1560(ra) # 80000cb2 <release>
  return r;
}
    800046a2:	8526                	mv	a0,s1
    800046a4:	70a2                	ld	ra,40(sp)
    800046a6:	7402                	ld	s0,32(sp)
    800046a8:	64e2                	ld	s1,24(sp)
    800046aa:	6942                	ld	s2,16(sp)
    800046ac:	69a2                	ld	s3,8(sp)
    800046ae:	6145                	addi	sp,sp,48
    800046b0:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046b2:	0284a983          	lw	s3,40(s1)
    800046b6:	ffffd097          	auipc	ra,0xffffd
    800046ba:	49a080e7          	jalr	1178(ra) # 80001b50 <myproc>
    800046be:	5d04                	lw	s1,56(a0)
    800046c0:	413484b3          	sub	s1,s1,s3
    800046c4:	0014b493          	seqz	s1,s1
    800046c8:	bfc1                	j	80004698 <holdingsleep+0x24>

00000000800046ca <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046ca:	1141                	addi	sp,sp,-16
    800046cc:	e406                	sd	ra,8(sp)
    800046ce:	e022                	sd	s0,0(sp)
    800046d0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046d2:	00004597          	auipc	a1,0x4
    800046d6:	02658593          	addi	a1,a1,38 # 800086f8 <syscalls+0x238>
    800046da:	0001d517          	auipc	a0,0x1d
    800046de:	57650513          	addi	a0,a0,1398 # 80021c50 <ftable>
    800046e2:	ffffc097          	auipc	ra,0xffffc
    800046e6:	48c080e7          	jalr	1164(ra) # 80000b6e <initlock>
}
    800046ea:	60a2                	ld	ra,8(sp)
    800046ec:	6402                	ld	s0,0(sp)
    800046ee:	0141                	addi	sp,sp,16
    800046f0:	8082                	ret

00000000800046f2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046f2:	1101                	addi	sp,sp,-32
    800046f4:	ec06                	sd	ra,24(sp)
    800046f6:	e822                	sd	s0,16(sp)
    800046f8:	e426                	sd	s1,8(sp)
    800046fa:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046fc:	0001d517          	auipc	a0,0x1d
    80004700:	55450513          	addi	a0,a0,1364 # 80021c50 <ftable>
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	4fa080e7          	jalr	1274(ra) # 80000bfe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000470c:	0001d497          	auipc	s1,0x1d
    80004710:	55c48493          	addi	s1,s1,1372 # 80021c68 <ftable+0x18>
    80004714:	0001e717          	auipc	a4,0x1e
    80004718:	4f470713          	addi	a4,a4,1268 # 80022c08 <ftable+0xfb8>
    if(f->ref == 0){
    8000471c:	40dc                	lw	a5,4(s1)
    8000471e:	cf99                	beqz	a5,8000473c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004720:	02848493          	addi	s1,s1,40
    80004724:	fee49ce3          	bne	s1,a4,8000471c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004728:	0001d517          	auipc	a0,0x1d
    8000472c:	52850513          	addi	a0,a0,1320 # 80021c50 <ftable>
    80004730:	ffffc097          	auipc	ra,0xffffc
    80004734:	582080e7          	jalr	1410(ra) # 80000cb2 <release>
  return 0;
    80004738:	4481                	li	s1,0
    8000473a:	a819                	j	80004750 <filealloc+0x5e>
      f->ref = 1;
    8000473c:	4785                	li	a5,1
    8000473e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004740:	0001d517          	auipc	a0,0x1d
    80004744:	51050513          	addi	a0,a0,1296 # 80021c50 <ftable>
    80004748:	ffffc097          	auipc	ra,0xffffc
    8000474c:	56a080e7          	jalr	1386(ra) # 80000cb2 <release>
}
    80004750:	8526                	mv	a0,s1
    80004752:	60e2                	ld	ra,24(sp)
    80004754:	6442                	ld	s0,16(sp)
    80004756:	64a2                	ld	s1,8(sp)
    80004758:	6105                	addi	sp,sp,32
    8000475a:	8082                	ret

000000008000475c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000475c:	1101                	addi	sp,sp,-32
    8000475e:	ec06                	sd	ra,24(sp)
    80004760:	e822                	sd	s0,16(sp)
    80004762:	e426                	sd	s1,8(sp)
    80004764:	1000                	addi	s0,sp,32
    80004766:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004768:	0001d517          	auipc	a0,0x1d
    8000476c:	4e850513          	addi	a0,a0,1256 # 80021c50 <ftable>
    80004770:	ffffc097          	auipc	ra,0xffffc
    80004774:	48e080e7          	jalr	1166(ra) # 80000bfe <acquire>
  if(f->ref < 1)
    80004778:	40dc                	lw	a5,4(s1)
    8000477a:	02f05263          	blez	a5,8000479e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000477e:	2785                	addiw	a5,a5,1
    80004780:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004782:	0001d517          	auipc	a0,0x1d
    80004786:	4ce50513          	addi	a0,a0,1230 # 80021c50 <ftable>
    8000478a:	ffffc097          	auipc	ra,0xffffc
    8000478e:	528080e7          	jalr	1320(ra) # 80000cb2 <release>
  return f;
}
    80004792:	8526                	mv	a0,s1
    80004794:	60e2                	ld	ra,24(sp)
    80004796:	6442                	ld	s0,16(sp)
    80004798:	64a2                	ld	s1,8(sp)
    8000479a:	6105                	addi	sp,sp,32
    8000479c:	8082                	ret
    panic("filedup");
    8000479e:	00004517          	auipc	a0,0x4
    800047a2:	f6250513          	addi	a0,a0,-158 # 80008700 <syscalls+0x240>
    800047a6:	ffffc097          	auipc	ra,0xffffc
    800047aa:	d9c080e7          	jalr	-612(ra) # 80000542 <panic>

00000000800047ae <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047ae:	7139                	addi	sp,sp,-64
    800047b0:	fc06                	sd	ra,56(sp)
    800047b2:	f822                	sd	s0,48(sp)
    800047b4:	f426                	sd	s1,40(sp)
    800047b6:	f04a                	sd	s2,32(sp)
    800047b8:	ec4e                	sd	s3,24(sp)
    800047ba:	e852                	sd	s4,16(sp)
    800047bc:	e456                	sd	s5,8(sp)
    800047be:	0080                	addi	s0,sp,64
    800047c0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047c2:	0001d517          	auipc	a0,0x1d
    800047c6:	48e50513          	addi	a0,a0,1166 # 80021c50 <ftable>
    800047ca:	ffffc097          	auipc	ra,0xffffc
    800047ce:	434080e7          	jalr	1076(ra) # 80000bfe <acquire>
  if(f->ref < 1)
    800047d2:	40dc                	lw	a5,4(s1)
    800047d4:	06f05163          	blez	a5,80004836 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047d8:	37fd                	addiw	a5,a5,-1
    800047da:	0007871b          	sext.w	a4,a5
    800047de:	c0dc                	sw	a5,4(s1)
    800047e0:	06e04363          	bgtz	a4,80004846 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047e4:	0004a903          	lw	s2,0(s1)
    800047e8:	0094ca83          	lbu	s5,9(s1)
    800047ec:	0104ba03          	ld	s4,16(s1)
    800047f0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047f4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047f8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047fc:	0001d517          	auipc	a0,0x1d
    80004800:	45450513          	addi	a0,a0,1108 # 80021c50 <ftable>
    80004804:	ffffc097          	auipc	ra,0xffffc
    80004808:	4ae080e7          	jalr	1198(ra) # 80000cb2 <release>

  if(ff.type == FD_PIPE){
    8000480c:	4785                	li	a5,1
    8000480e:	04f90d63          	beq	s2,a5,80004868 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004812:	3979                	addiw	s2,s2,-2
    80004814:	4785                	li	a5,1
    80004816:	0527e063          	bltu	a5,s2,80004856 <fileclose+0xa8>
    begin_op();
    8000481a:	00000097          	auipc	ra,0x0
    8000481e:	ac2080e7          	jalr	-1342(ra) # 800042dc <begin_op>
    iput(ff.ip);
    80004822:	854e                	mv	a0,s3
    80004824:	fffff097          	auipc	ra,0xfffff
    80004828:	2b6080e7          	jalr	694(ra) # 80003ada <iput>
    end_op();
    8000482c:	00000097          	auipc	ra,0x0
    80004830:	b30080e7          	jalr	-1232(ra) # 8000435c <end_op>
    80004834:	a00d                	j	80004856 <fileclose+0xa8>
    panic("fileclose");
    80004836:	00004517          	auipc	a0,0x4
    8000483a:	ed250513          	addi	a0,a0,-302 # 80008708 <syscalls+0x248>
    8000483e:	ffffc097          	auipc	ra,0xffffc
    80004842:	d04080e7          	jalr	-764(ra) # 80000542 <panic>
    release(&ftable.lock);
    80004846:	0001d517          	auipc	a0,0x1d
    8000484a:	40a50513          	addi	a0,a0,1034 # 80021c50 <ftable>
    8000484e:	ffffc097          	auipc	ra,0xffffc
    80004852:	464080e7          	jalr	1124(ra) # 80000cb2 <release>
  }
}
    80004856:	70e2                	ld	ra,56(sp)
    80004858:	7442                	ld	s0,48(sp)
    8000485a:	74a2                	ld	s1,40(sp)
    8000485c:	7902                	ld	s2,32(sp)
    8000485e:	69e2                	ld	s3,24(sp)
    80004860:	6a42                	ld	s4,16(sp)
    80004862:	6aa2                	ld	s5,8(sp)
    80004864:	6121                	addi	sp,sp,64
    80004866:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004868:	85d6                	mv	a1,s5
    8000486a:	8552                	mv	a0,s4
    8000486c:	00000097          	auipc	ra,0x0
    80004870:	372080e7          	jalr	882(ra) # 80004bde <pipeclose>
    80004874:	b7cd                	j	80004856 <fileclose+0xa8>

0000000080004876 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004876:	715d                	addi	sp,sp,-80
    80004878:	e486                	sd	ra,72(sp)
    8000487a:	e0a2                	sd	s0,64(sp)
    8000487c:	fc26                	sd	s1,56(sp)
    8000487e:	f84a                	sd	s2,48(sp)
    80004880:	f44e                	sd	s3,40(sp)
    80004882:	0880                	addi	s0,sp,80
    80004884:	84aa                	mv	s1,a0
    80004886:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004888:	ffffd097          	auipc	ra,0xffffd
    8000488c:	2c8080e7          	jalr	712(ra) # 80001b50 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004890:	409c                	lw	a5,0(s1)
    80004892:	37f9                	addiw	a5,a5,-2
    80004894:	4705                	li	a4,1
    80004896:	04f76763          	bltu	a4,a5,800048e4 <filestat+0x6e>
    8000489a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000489c:	6c88                	ld	a0,24(s1)
    8000489e:	fffff097          	auipc	ra,0xfffff
    800048a2:	082080e7          	jalr	130(ra) # 80003920 <ilock>
    stati(f->ip, &st);
    800048a6:	fb840593          	addi	a1,s0,-72
    800048aa:	6c88                	ld	a0,24(s1)
    800048ac:	fffff097          	auipc	ra,0xfffff
    800048b0:	2fe080e7          	jalr	766(ra) # 80003baa <stati>
    iunlock(f->ip);
    800048b4:	6c88                	ld	a0,24(s1)
    800048b6:	fffff097          	auipc	ra,0xfffff
    800048ba:	12c080e7          	jalr	300(ra) # 800039e2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048be:	46e1                	li	a3,24
    800048c0:	fb840613          	addi	a2,s0,-72
    800048c4:	85ce                	mv	a1,s3
    800048c6:	05093503          	ld	a0,80(s2)
    800048ca:	ffffd097          	auipc	ra,0xffffd
    800048ce:	e04080e7          	jalr	-508(ra) # 800016ce <copyout>
    800048d2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048d6:	60a6                	ld	ra,72(sp)
    800048d8:	6406                	ld	s0,64(sp)
    800048da:	74e2                	ld	s1,56(sp)
    800048dc:	7942                	ld	s2,48(sp)
    800048de:	79a2                	ld	s3,40(sp)
    800048e0:	6161                	addi	sp,sp,80
    800048e2:	8082                	ret
  return -1;
    800048e4:	557d                	li	a0,-1
    800048e6:	bfc5                	j	800048d6 <filestat+0x60>

00000000800048e8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048e8:	7179                	addi	sp,sp,-48
    800048ea:	f406                	sd	ra,40(sp)
    800048ec:	f022                	sd	s0,32(sp)
    800048ee:	ec26                	sd	s1,24(sp)
    800048f0:	e84a                	sd	s2,16(sp)
    800048f2:	e44e                	sd	s3,8(sp)
    800048f4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048f6:	00854783          	lbu	a5,8(a0)
    800048fa:	c3d5                	beqz	a5,8000499e <fileread+0xb6>
    800048fc:	84aa                	mv	s1,a0
    800048fe:	89ae                	mv	s3,a1
    80004900:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004902:	411c                	lw	a5,0(a0)
    80004904:	4705                	li	a4,1
    80004906:	04e78963          	beq	a5,a4,80004958 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000490a:	470d                	li	a4,3
    8000490c:	04e78d63          	beq	a5,a4,80004966 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004910:	4709                	li	a4,2
    80004912:	06e79e63          	bne	a5,a4,8000498e <fileread+0xa6>
    ilock(f->ip);
    80004916:	6d08                	ld	a0,24(a0)
    80004918:	fffff097          	auipc	ra,0xfffff
    8000491c:	008080e7          	jalr	8(ra) # 80003920 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004920:	874a                	mv	a4,s2
    80004922:	5094                	lw	a3,32(s1)
    80004924:	864e                	mv	a2,s3
    80004926:	4585                	li	a1,1
    80004928:	6c88                	ld	a0,24(s1)
    8000492a:	fffff097          	auipc	ra,0xfffff
    8000492e:	2aa080e7          	jalr	682(ra) # 80003bd4 <readi>
    80004932:	892a                	mv	s2,a0
    80004934:	00a05563          	blez	a0,8000493e <fileread+0x56>
      f->off += r;
    80004938:	509c                	lw	a5,32(s1)
    8000493a:	9fa9                	addw	a5,a5,a0
    8000493c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000493e:	6c88                	ld	a0,24(s1)
    80004940:	fffff097          	auipc	ra,0xfffff
    80004944:	0a2080e7          	jalr	162(ra) # 800039e2 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004948:	854a                	mv	a0,s2
    8000494a:	70a2                	ld	ra,40(sp)
    8000494c:	7402                	ld	s0,32(sp)
    8000494e:	64e2                	ld	s1,24(sp)
    80004950:	6942                	ld	s2,16(sp)
    80004952:	69a2                	ld	s3,8(sp)
    80004954:	6145                	addi	sp,sp,48
    80004956:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004958:	6908                	ld	a0,16(a0)
    8000495a:	00000097          	auipc	ra,0x0
    8000495e:	3f4080e7          	jalr	1012(ra) # 80004d4e <piperead>
    80004962:	892a                	mv	s2,a0
    80004964:	b7d5                	j	80004948 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004966:	02451783          	lh	a5,36(a0)
    8000496a:	03079693          	slli	a3,a5,0x30
    8000496e:	92c1                	srli	a3,a3,0x30
    80004970:	4725                	li	a4,9
    80004972:	02d76863          	bltu	a4,a3,800049a2 <fileread+0xba>
    80004976:	0792                	slli	a5,a5,0x4
    80004978:	0001d717          	auipc	a4,0x1d
    8000497c:	23870713          	addi	a4,a4,568 # 80021bb0 <devsw>
    80004980:	97ba                	add	a5,a5,a4
    80004982:	639c                	ld	a5,0(a5)
    80004984:	c38d                	beqz	a5,800049a6 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004986:	4505                	li	a0,1
    80004988:	9782                	jalr	a5
    8000498a:	892a                	mv	s2,a0
    8000498c:	bf75                	j	80004948 <fileread+0x60>
    panic("fileread");
    8000498e:	00004517          	auipc	a0,0x4
    80004992:	d8a50513          	addi	a0,a0,-630 # 80008718 <syscalls+0x258>
    80004996:	ffffc097          	auipc	ra,0xffffc
    8000499a:	bac080e7          	jalr	-1108(ra) # 80000542 <panic>
    return -1;
    8000499e:	597d                	li	s2,-1
    800049a0:	b765                	j	80004948 <fileread+0x60>
      return -1;
    800049a2:	597d                	li	s2,-1
    800049a4:	b755                	j	80004948 <fileread+0x60>
    800049a6:	597d                	li	s2,-1
    800049a8:	b745                	j	80004948 <fileread+0x60>

00000000800049aa <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800049aa:	00954783          	lbu	a5,9(a0)
    800049ae:	14078563          	beqz	a5,80004af8 <filewrite+0x14e>
{
    800049b2:	715d                	addi	sp,sp,-80
    800049b4:	e486                	sd	ra,72(sp)
    800049b6:	e0a2                	sd	s0,64(sp)
    800049b8:	fc26                	sd	s1,56(sp)
    800049ba:	f84a                	sd	s2,48(sp)
    800049bc:	f44e                	sd	s3,40(sp)
    800049be:	f052                	sd	s4,32(sp)
    800049c0:	ec56                	sd	s5,24(sp)
    800049c2:	e85a                	sd	s6,16(sp)
    800049c4:	e45e                	sd	s7,8(sp)
    800049c6:	e062                	sd	s8,0(sp)
    800049c8:	0880                	addi	s0,sp,80
    800049ca:	892a                	mv	s2,a0
    800049cc:	8aae                	mv	s5,a1
    800049ce:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049d0:	411c                	lw	a5,0(a0)
    800049d2:	4705                	li	a4,1
    800049d4:	02e78263          	beq	a5,a4,800049f8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049d8:	470d                	li	a4,3
    800049da:	02e78563          	beq	a5,a4,80004a04 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049de:	4709                	li	a4,2
    800049e0:	10e79463          	bne	a5,a4,80004ae8 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049e4:	0ec05e63          	blez	a2,80004ae0 <filewrite+0x136>
    int i = 0;
    800049e8:	4981                	li	s3,0
    800049ea:	6b05                	lui	s6,0x1
    800049ec:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800049f0:	6b85                	lui	s7,0x1
    800049f2:	c00b8b9b          	addiw	s7,s7,-1024
    800049f6:	a851                	j	80004a8a <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800049f8:	6908                	ld	a0,16(a0)
    800049fa:	00000097          	auipc	ra,0x0
    800049fe:	254080e7          	jalr	596(ra) # 80004c4e <pipewrite>
    80004a02:	a85d                	j	80004ab8 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a04:	02451783          	lh	a5,36(a0)
    80004a08:	03079693          	slli	a3,a5,0x30
    80004a0c:	92c1                	srli	a3,a3,0x30
    80004a0e:	4725                	li	a4,9
    80004a10:	0ed76663          	bltu	a4,a3,80004afc <filewrite+0x152>
    80004a14:	0792                	slli	a5,a5,0x4
    80004a16:	0001d717          	auipc	a4,0x1d
    80004a1a:	19a70713          	addi	a4,a4,410 # 80021bb0 <devsw>
    80004a1e:	97ba                	add	a5,a5,a4
    80004a20:	679c                	ld	a5,8(a5)
    80004a22:	cff9                	beqz	a5,80004b00 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004a24:	4505                	li	a0,1
    80004a26:	9782                	jalr	a5
    80004a28:	a841                	j	80004ab8 <filewrite+0x10e>
    80004a2a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a2e:	00000097          	auipc	ra,0x0
    80004a32:	8ae080e7          	jalr	-1874(ra) # 800042dc <begin_op>
      ilock(f->ip);
    80004a36:	01893503          	ld	a0,24(s2)
    80004a3a:	fffff097          	auipc	ra,0xfffff
    80004a3e:	ee6080e7          	jalr	-282(ra) # 80003920 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a42:	8762                	mv	a4,s8
    80004a44:	02092683          	lw	a3,32(s2)
    80004a48:	01598633          	add	a2,s3,s5
    80004a4c:	4585                	li	a1,1
    80004a4e:	01893503          	ld	a0,24(s2)
    80004a52:	fffff097          	auipc	ra,0xfffff
    80004a56:	278080e7          	jalr	632(ra) # 80003cca <writei>
    80004a5a:	84aa                	mv	s1,a0
    80004a5c:	02a05f63          	blez	a0,80004a9a <filewrite+0xf0>
        f->off += r;
    80004a60:	02092783          	lw	a5,32(s2)
    80004a64:	9fa9                	addw	a5,a5,a0
    80004a66:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a6a:	01893503          	ld	a0,24(s2)
    80004a6e:	fffff097          	auipc	ra,0xfffff
    80004a72:	f74080e7          	jalr	-140(ra) # 800039e2 <iunlock>
      end_op();
    80004a76:	00000097          	auipc	ra,0x0
    80004a7a:	8e6080e7          	jalr	-1818(ra) # 8000435c <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004a7e:	049c1963          	bne	s8,s1,80004ad0 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004a82:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a86:	0349d663          	bge	s3,s4,80004ab2 <filewrite+0x108>
      int n1 = n - i;
    80004a8a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a8e:	84be                	mv	s1,a5
    80004a90:	2781                	sext.w	a5,a5
    80004a92:	f8fb5ce3          	bge	s6,a5,80004a2a <filewrite+0x80>
    80004a96:	84de                	mv	s1,s7
    80004a98:	bf49                	j	80004a2a <filewrite+0x80>
      iunlock(f->ip);
    80004a9a:	01893503          	ld	a0,24(s2)
    80004a9e:	fffff097          	auipc	ra,0xfffff
    80004aa2:	f44080e7          	jalr	-188(ra) # 800039e2 <iunlock>
      end_op();
    80004aa6:	00000097          	auipc	ra,0x0
    80004aaa:	8b6080e7          	jalr	-1866(ra) # 8000435c <end_op>
      if(r < 0)
    80004aae:	fc04d8e3          	bgez	s1,80004a7e <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004ab2:	8552                	mv	a0,s4
    80004ab4:	033a1863          	bne	s4,s3,80004ae4 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ab8:	60a6                	ld	ra,72(sp)
    80004aba:	6406                	ld	s0,64(sp)
    80004abc:	74e2                	ld	s1,56(sp)
    80004abe:	7942                	ld	s2,48(sp)
    80004ac0:	79a2                	ld	s3,40(sp)
    80004ac2:	7a02                	ld	s4,32(sp)
    80004ac4:	6ae2                	ld	s5,24(sp)
    80004ac6:	6b42                	ld	s6,16(sp)
    80004ac8:	6ba2                	ld	s7,8(sp)
    80004aca:	6c02                	ld	s8,0(sp)
    80004acc:	6161                	addi	sp,sp,80
    80004ace:	8082                	ret
        panic("short filewrite");
    80004ad0:	00004517          	auipc	a0,0x4
    80004ad4:	c5850513          	addi	a0,a0,-936 # 80008728 <syscalls+0x268>
    80004ad8:	ffffc097          	auipc	ra,0xffffc
    80004adc:	a6a080e7          	jalr	-1430(ra) # 80000542 <panic>
    int i = 0;
    80004ae0:	4981                	li	s3,0
    80004ae2:	bfc1                	j	80004ab2 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004ae4:	557d                	li	a0,-1
    80004ae6:	bfc9                	j	80004ab8 <filewrite+0x10e>
    panic("filewrite");
    80004ae8:	00004517          	auipc	a0,0x4
    80004aec:	c5050513          	addi	a0,a0,-944 # 80008738 <syscalls+0x278>
    80004af0:	ffffc097          	auipc	ra,0xffffc
    80004af4:	a52080e7          	jalr	-1454(ra) # 80000542 <panic>
    return -1;
    80004af8:	557d                	li	a0,-1
}
    80004afa:	8082                	ret
      return -1;
    80004afc:	557d                	li	a0,-1
    80004afe:	bf6d                	j	80004ab8 <filewrite+0x10e>
    80004b00:	557d                	li	a0,-1
    80004b02:	bf5d                	j	80004ab8 <filewrite+0x10e>

0000000080004b04 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b04:	7179                	addi	sp,sp,-48
    80004b06:	f406                	sd	ra,40(sp)
    80004b08:	f022                	sd	s0,32(sp)
    80004b0a:	ec26                	sd	s1,24(sp)
    80004b0c:	e84a                	sd	s2,16(sp)
    80004b0e:	e44e                	sd	s3,8(sp)
    80004b10:	e052                	sd	s4,0(sp)
    80004b12:	1800                	addi	s0,sp,48
    80004b14:	84aa                	mv	s1,a0
    80004b16:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b18:	0005b023          	sd	zero,0(a1)
    80004b1c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b20:	00000097          	auipc	ra,0x0
    80004b24:	bd2080e7          	jalr	-1070(ra) # 800046f2 <filealloc>
    80004b28:	e088                	sd	a0,0(s1)
    80004b2a:	c551                	beqz	a0,80004bb6 <pipealloc+0xb2>
    80004b2c:	00000097          	auipc	ra,0x0
    80004b30:	bc6080e7          	jalr	-1082(ra) # 800046f2 <filealloc>
    80004b34:	00aa3023          	sd	a0,0(s4)
    80004b38:	c92d                	beqz	a0,80004baa <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b3a:	ffffc097          	auipc	ra,0xffffc
    80004b3e:	fd4080e7          	jalr	-44(ra) # 80000b0e <kalloc>
    80004b42:	892a                	mv	s2,a0
    80004b44:	c125                	beqz	a0,80004ba4 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b46:	4985                	li	s3,1
    80004b48:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b4c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b50:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b54:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b58:	00004597          	auipc	a1,0x4
    80004b5c:	bf058593          	addi	a1,a1,-1040 # 80008748 <syscalls+0x288>
    80004b60:	ffffc097          	auipc	ra,0xffffc
    80004b64:	00e080e7          	jalr	14(ra) # 80000b6e <initlock>
  (*f0)->type = FD_PIPE;
    80004b68:	609c                	ld	a5,0(s1)
    80004b6a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b6e:	609c                	ld	a5,0(s1)
    80004b70:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b74:	609c                	ld	a5,0(s1)
    80004b76:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b7a:	609c                	ld	a5,0(s1)
    80004b7c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b80:	000a3783          	ld	a5,0(s4)
    80004b84:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b88:	000a3783          	ld	a5,0(s4)
    80004b8c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b90:	000a3783          	ld	a5,0(s4)
    80004b94:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b98:	000a3783          	ld	a5,0(s4)
    80004b9c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ba0:	4501                	li	a0,0
    80004ba2:	a025                	j	80004bca <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ba4:	6088                	ld	a0,0(s1)
    80004ba6:	e501                	bnez	a0,80004bae <pipealloc+0xaa>
    80004ba8:	a039                	j	80004bb6 <pipealloc+0xb2>
    80004baa:	6088                	ld	a0,0(s1)
    80004bac:	c51d                	beqz	a0,80004bda <pipealloc+0xd6>
    fileclose(*f0);
    80004bae:	00000097          	auipc	ra,0x0
    80004bb2:	c00080e7          	jalr	-1024(ra) # 800047ae <fileclose>
  if(*f1)
    80004bb6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bba:	557d                	li	a0,-1
  if(*f1)
    80004bbc:	c799                	beqz	a5,80004bca <pipealloc+0xc6>
    fileclose(*f1);
    80004bbe:	853e                	mv	a0,a5
    80004bc0:	00000097          	auipc	ra,0x0
    80004bc4:	bee080e7          	jalr	-1042(ra) # 800047ae <fileclose>
  return -1;
    80004bc8:	557d                	li	a0,-1
}
    80004bca:	70a2                	ld	ra,40(sp)
    80004bcc:	7402                	ld	s0,32(sp)
    80004bce:	64e2                	ld	s1,24(sp)
    80004bd0:	6942                	ld	s2,16(sp)
    80004bd2:	69a2                	ld	s3,8(sp)
    80004bd4:	6a02                	ld	s4,0(sp)
    80004bd6:	6145                	addi	sp,sp,48
    80004bd8:	8082                	ret
  return -1;
    80004bda:	557d                	li	a0,-1
    80004bdc:	b7fd                	j	80004bca <pipealloc+0xc6>

0000000080004bde <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bde:	1101                	addi	sp,sp,-32
    80004be0:	ec06                	sd	ra,24(sp)
    80004be2:	e822                	sd	s0,16(sp)
    80004be4:	e426                	sd	s1,8(sp)
    80004be6:	e04a                	sd	s2,0(sp)
    80004be8:	1000                	addi	s0,sp,32
    80004bea:	84aa                	mv	s1,a0
    80004bec:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bee:	ffffc097          	auipc	ra,0xffffc
    80004bf2:	010080e7          	jalr	16(ra) # 80000bfe <acquire>
  if(writable){
    80004bf6:	02090d63          	beqz	s2,80004c30 <pipeclose+0x52>
    pi->writeopen = 0;
    80004bfa:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bfe:	21848513          	addi	a0,s1,536
    80004c02:	ffffe097          	auipc	ra,0xffffe
    80004c06:	a88080e7          	jalr	-1400(ra) # 8000268a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c0a:	2204b783          	ld	a5,544(s1)
    80004c0e:	eb95                	bnez	a5,80004c42 <pipeclose+0x64>
    release(&pi->lock);
    80004c10:	8526                	mv	a0,s1
    80004c12:	ffffc097          	auipc	ra,0xffffc
    80004c16:	0a0080e7          	jalr	160(ra) # 80000cb2 <release>
    kfree((char*)pi);
    80004c1a:	8526                	mv	a0,s1
    80004c1c:	ffffc097          	auipc	ra,0xffffc
    80004c20:	df6080e7          	jalr	-522(ra) # 80000a12 <kfree>
  } else
    release(&pi->lock);
}
    80004c24:	60e2                	ld	ra,24(sp)
    80004c26:	6442                	ld	s0,16(sp)
    80004c28:	64a2                	ld	s1,8(sp)
    80004c2a:	6902                	ld	s2,0(sp)
    80004c2c:	6105                	addi	sp,sp,32
    80004c2e:	8082                	ret
    pi->readopen = 0;
    80004c30:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c34:	21c48513          	addi	a0,s1,540
    80004c38:	ffffe097          	auipc	ra,0xffffe
    80004c3c:	a52080e7          	jalr	-1454(ra) # 8000268a <wakeup>
    80004c40:	b7e9                	j	80004c0a <pipeclose+0x2c>
    release(&pi->lock);
    80004c42:	8526                	mv	a0,s1
    80004c44:	ffffc097          	auipc	ra,0xffffc
    80004c48:	06e080e7          	jalr	110(ra) # 80000cb2 <release>
}
    80004c4c:	bfe1                	j	80004c24 <pipeclose+0x46>

0000000080004c4e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c4e:	711d                	addi	sp,sp,-96
    80004c50:	ec86                	sd	ra,88(sp)
    80004c52:	e8a2                	sd	s0,80(sp)
    80004c54:	e4a6                	sd	s1,72(sp)
    80004c56:	e0ca                	sd	s2,64(sp)
    80004c58:	fc4e                	sd	s3,56(sp)
    80004c5a:	f852                	sd	s4,48(sp)
    80004c5c:	f456                	sd	s5,40(sp)
    80004c5e:	f05a                	sd	s6,32(sp)
    80004c60:	ec5e                	sd	s7,24(sp)
    80004c62:	e862                	sd	s8,16(sp)
    80004c64:	1080                	addi	s0,sp,96
    80004c66:	84aa                	mv	s1,a0
    80004c68:	8b2e                	mv	s6,a1
    80004c6a:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004c6c:	ffffd097          	auipc	ra,0xffffd
    80004c70:	ee4080e7          	jalr	-284(ra) # 80001b50 <myproc>
    80004c74:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004c76:	8526                	mv	a0,s1
    80004c78:	ffffc097          	auipc	ra,0xffffc
    80004c7c:	f86080e7          	jalr	-122(ra) # 80000bfe <acquire>
  for(i = 0; i < n; i++){
    80004c80:	09505763          	blez	s5,80004d0e <pipewrite+0xc0>
    80004c84:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004c86:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c8a:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c8e:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c90:	2184a783          	lw	a5,536(s1)
    80004c94:	21c4a703          	lw	a4,540(s1)
    80004c98:	2007879b          	addiw	a5,a5,512
    80004c9c:	02f71b63          	bne	a4,a5,80004cd2 <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    80004ca0:	2204a783          	lw	a5,544(s1)
    80004ca4:	c3d1                	beqz	a5,80004d28 <pipewrite+0xda>
    80004ca6:	03092783          	lw	a5,48(s2)
    80004caa:	efbd                	bnez	a5,80004d28 <pipewrite+0xda>
      wakeup(&pi->nread);
    80004cac:	8552                	mv	a0,s4
    80004cae:	ffffe097          	auipc	ra,0xffffe
    80004cb2:	9dc080e7          	jalr	-1572(ra) # 8000268a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cb6:	85a6                	mv	a1,s1
    80004cb8:	854e                	mv	a0,s3
    80004cba:	ffffe097          	auipc	ra,0xffffe
    80004cbe:	850080e7          	jalr	-1968(ra) # 8000250a <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004cc2:	2184a783          	lw	a5,536(s1)
    80004cc6:	21c4a703          	lw	a4,540(s1)
    80004cca:	2007879b          	addiw	a5,a5,512
    80004cce:	fcf709e3          	beq	a4,a5,80004ca0 <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cd2:	4685                	li	a3,1
    80004cd4:	865a                	mv	a2,s6
    80004cd6:	faf40593          	addi	a1,s0,-81
    80004cda:	05093503          	ld	a0,80(s2)
    80004cde:	ffffd097          	auipc	ra,0xffffd
    80004ce2:	a7c080e7          	jalr	-1412(ra) # 8000175a <copyin>
    80004ce6:	03850563          	beq	a0,s8,80004d10 <pipewrite+0xc2>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cea:	21c4a783          	lw	a5,540(s1)
    80004cee:	0017871b          	addiw	a4,a5,1
    80004cf2:	20e4ae23          	sw	a4,540(s1)
    80004cf6:	1ff7f793          	andi	a5,a5,511
    80004cfa:	97a6                	add	a5,a5,s1
    80004cfc:	faf44703          	lbu	a4,-81(s0)
    80004d00:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004d04:	2b85                	addiw	s7,s7,1
    80004d06:	0b05                	addi	s6,s6,1
    80004d08:	f97a94e3          	bne	s5,s7,80004c90 <pipewrite+0x42>
    80004d0c:	a011                	j	80004d10 <pipewrite+0xc2>
    80004d0e:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    80004d10:	21848513          	addi	a0,s1,536
    80004d14:	ffffe097          	auipc	ra,0xffffe
    80004d18:	976080e7          	jalr	-1674(ra) # 8000268a <wakeup>
  release(&pi->lock);
    80004d1c:	8526                	mv	a0,s1
    80004d1e:	ffffc097          	auipc	ra,0xffffc
    80004d22:	f94080e7          	jalr	-108(ra) # 80000cb2 <release>
  return i;
    80004d26:	a039                	j	80004d34 <pipewrite+0xe6>
        release(&pi->lock);
    80004d28:	8526                	mv	a0,s1
    80004d2a:	ffffc097          	auipc	ra,0xffffc
    80004d2e:	f88080e7          	jalr	-120(ra) # 80000cb2 <release>
        return -1;
    80004d32:	5bfd                	li	s7,-1
}
    80004d34:	855e                	mv	a0,s7
    80004d36:	60e6                	ld	ra,88(sp)
    80004d38:	6446                	ld	s0,80(sp)
    80004d3a:	64a6                	ld	s1,72(sp)
    80004d3c:	6906                	ld	s2,64(sp)
    80004d3e:	79e2                	ld	s3,56(sp)
    80004d40:	7a42                	ld	s4,48(sp)
    80004d42:	7aa2                	ld	s5,40(sp)
    80004d44:	7b02                	ld	s6,32(sp)
    80004d46:	6be2                	ld	s7,24(sp)
    80004d48:	6c42                	ld	s8,16(sp)
    80004d4a:	6125                	addi	sp,sp,96
    80004d4c:	8082                	ret

0000000080004d4e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d4e:	715d                	addi	sp,sp,-80
    80004d50:	e486                	sd	ra,72(sp)
    80004d52:	e0a2                	sd	s0,64(sp)
    80004d54:	fc26                	sd	s1,56(sp)
    80004d56:	f84a                	sd	s2,48(sp)
    80004d58:	f44e                	sd	s3,40(sp)
    80004d5a:	f052                	sd	s4,32(sp)
    80004d5c:	ec56                	sd	s5,24(sp)
    80004d5e:	e85a                	sd	s6,16(sp)
    80004d60:	0880                	addi	s0,sp,80
    80004d62:	84aa                	mv	s1,a0
    80004d64:	892e                	mv	s2,a1
    80004d66:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d68:	ffffd097          	auipc	ra,0xffffd
    80004d6c:	de8080e7          	jalr	-536(ra) # 80001b50 <myproc>
    80004d70:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d72:	8526                	mv	a0,s1
    80004d74:	ffffc097          	auipc	ra,0xffffc
    80004d78:	e8a080e7          	jalr	-374(ra) # 80000bfe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d7c:	2184a703          	lw	a4,536(s1)
    80004d80:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d84:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d88:	02f71463          	bne	a4,a5,80004db0 <piperead+0x62>
    80004d8c:	2244a783          	lw	a5,548(s1)
    80004d90:	c385                	beqz	a5,80004db0 <piperead+0x62>
    if(pr->killed){
    80004d92:	030a2783          	lw	a5,48(s4)
    80004d96:	ebc1                	bnez	a5,80004e26 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d98:	85a6                	mv	a1,s1
    80004d9a:	854e                	mv	a0,s3
    80004d9c:	ffffd097          	auipc	ra,0xffffd
    80004da0:	76e080e7          	jalr	1902(ra) # 8000250a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004da4:	2184a703          	lw	a4,536(s1)
    80004da8:	21c4a783          	lw	a5,540(s1)
    80004dac:	fef700e3          	beq	a4,a5,80004d8c <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004db0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004db2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004db4:	05505363          	blez	s5,80004dfa <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004db8:	2184a783          	lw	a5,536(s1)
    80004dbc:	21c4a703          	lw	a4,540(s1)
    80004dc0:	02f70d63          	beq	a4,a5,80004dfa <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004dc4:	0017871b          	addiw	a4,a5,1
    80004dc8:	20e4ac23          	sw	a4,536(s1)
    80004dcc:	1ff7f793          	andi	a5,a5,511
    80004dd0:	97a6                	add	a5,a5,s1
    80004dd2:	0187c783          	lbu	a5,24(a5)
    80004dd6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dda:	4685                	li	a3,1
    80004ddc:	fbf40613          	addi	a2,s0,-65
    80004de0:	85ca                	mv	a1,s2
    80004de2:	050a3503          	ld	a0,80(s4)
    80004de6:	ffffd097          	auipc	ra,0xffffd
    80004dea:	8e8080e7          	jalr	-1816(ra) # 800016ce <copyout>
    80004dee:	01650663          	beq	a0,s6,80004dfa <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004df2:	2985                	addiw	s3,s3,1
    80004df4:	0905                	addi	s2,s2,1
    80004df6:	fd3a91e3          	bne	s5,s3,80004db8 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004dfa:	21c48513          	addi	a0,s1,540
    80004dfe:	ffffe097          	auipc	ra,0xffffe
    80004e02:	88c080e7          	jalr	-1908(ra) # 8000268a <wakeup>
  release(&pi->lock);
    80004e06:	8526                	mv	a0,s1
    80004e08:	ffffc097          	auipc	ra,0xffffc
    80004e0c:	eaa080e7          	jalr	-342(ra) # 80000cb2 <release>
  return i;
}
    80004e10:	854e                	mv	a0,s3
    80004e12:	60a6                	ld	ra,72(sp)
    80004e14:	6406                	ld	s0,64(sp)
    80004e16:	74e2                	ld	s1,56(sp)
    80004e18:	7942                	ld	s2,48(sp)
    80004e1a:	79a2                	ld	s3,40(sp)
    80004e1c:	7a02                	ld	s4,32(sp)
    80004e1e:	6ae2                	ld	s5,24(sp)
    80004e20:	6b42                	ld	s6,16(sp)
    80004e22:	6161                	addi	sp,sp,80
    80004e24:	8082                	ret
      release(&pi->lock);
    80004e26:	8526                	mv	a0,s1
    80004e28:	ffffc097          	auipc	ra,0xffffc
    80004e2c:	e8a080e7          	jalr	-374(ra) # 80000cb2 <release>
      return -1;
    80004e30:	59fd                	li	s3,-1
    80004e32:	bff9                	j	80004e10 <piperead+0xc2>

0000000080004e34 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e34:	dd010113          	addi	sp,sp,-560
    80004e38:	22113423          	sd	ra,552(sp)
    80004e3c:	22813023          	sd	s0,544(sp)
    80004e40:	20913c23          	sd	s1,536(sp)
    80004e44:	21213823          	sd	s2,528(sp)
    80004e48:	21313423          	sd	s3,520(sp)
    80004e4c:	21413023          	sd	s4,512(sp)
    80004e50:	ffd6                	sd	s5,504(sp)
    80004e52:	fbda                	sd	s6,496(sp)
    80004e54:	f7de                	sd	s7,488(sp)
    80004e56:	f3e2                	sd	s8,480(sp)
    80004e58:	efe6                	sd	s9,472(sp)
    80004e5a:	ebea                	sd	s10,464(sp)
    80004e5c:	e7ee                	sd	s11,456(sp)
    80004e5e:	1c00                	addi	s0,sp,560
    80004e60:	892a                	mv	s2,a0
    80004e62:	dea43423          	sd	a0,-536(s0)
    80004e66:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e6a:	ffffd097          	auipc	ra,0xffffd
    80004e6e:	ce6080e7          	jalr	-794(ra) # 80001b50 <myproc>
    80004e72:	84aa                	mv	s1,a0

  begin_op();
    80004e74:	fffff097          	auipc	ra,0xfffff
    80004e78:	468080e7          	jalr	1128(ra) # 800042dc <begin_op>

  if((ip = namei(path)) == 0){
    80004e7c:	854a                	mv	a0,s2
    80004e7e:	fffff097          	auipc	ra,0xfffff
    80004e82:	252080e7          	jalr	594(ra) # 800040d0 <namei>
    80004e86:	cd2d                	beqz	a0,80004f00 <exec+0xcc>
    80004e88:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e8a:	fffff097          	auipc	ra,0xfffff
    80004e8e:	a96080e7          	jalr	-1386(ra) # 80003920 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e92:	04000713          	li	a4,64
    80004e96:	4681                	li	a3,0
    80004e98:	e4840613          	addi	a2,s0,-440
    80004e9c:	4581                	li	a1,0
    80004e9e:	8552                	mv	a0,s4
    80004ea0:	fffff097          	auipc	ra,0xfffff
    80004ea4:	d34080e7          	jalr	-716(ra) # 80003bd4 <readi>
    80004ea8:	04000793          	li	a5,64
    80004eac:	00f51a63          	bne	a0,a5,80004ec0 <exec+0x8c>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004eb0:	e4842703          	lw	a4,-440(s0)
    80004eb4:	464c47b7          	lui	a5,0x464c4
    80004eb8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ebc:	04f70863          	beq	a4,a5,80004f0c <exec+0xd8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ec0:	8552                	mv	a0,s4
    80004ec2:	fffff097          	auipc	ra,0xfffff
    80004ec6:	cc0080e7          	jalr	-832(ra) # 80003b82 <iunlockput>
    end_op();
    80004eca:	fffff097          	auipc	ra,0xfffff
    80004ece:	492080e7          	jalr	1170(ra) # 8000435c <end_op>
  }
  return -1;
    80004ed2:	557d                	li	a0,-1
}
    80004ed4:	22813083          	ld	ra,552(sp)
    80004ed8:	22013403          	ld	s0,544(sp)
    80004edc:	21813483          	ld	s1,536(sp)
    80004ee0:	21013903          	ld	s2,528(sp)
    80004ee4:	20813983          	ld	s3,520(sp)
    80004ee8:	20013a03          	ld	s4,512(sp)
    80004eec:	7afe                	ld	s5,504(sp)
    80004eee:	7b5e                	ld	s6,496(sp)
    80004ef0:	7bbe                	ld	s7,488(sp)
    80004ef2:	7c1e                	ld	s8,480(sp)
    80004ef4:	6cfe                	ld	s9,472(sp)
    80004ef6:	6d5e                	ld	s10,464(sp)
    80004ef8:	6dbe                	ld	s11,456(sp)
    80004efa:	23010113          	addi	sp,sp,560
    80004efe:	8082                	ret
    end_op();
    80004f00:	fffff097          	auipc	ra,0xfffff
    80004f04:	45c080e7          	jalr	1116(ra) # 8000435c <end_op>
    return -1;
    80004f08:	557d                	li	a0,-1
    80004f0a:	b7e9                	j	80004ed4 <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f0c:	8526                	mv	a0,s1
    80004f0e:	ffffd097          	auipc	ra,0xffffd
    80004f12:	e4c080e7          	jalr	-436(ra) # 80001d5a <proc_pagetable>
    80004f16:	8b2a                	mv	s6,a0
    80004f18:	d545                	beqz	a0,80004ec0 <exec+0x8c>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f1a:	e6842783          	lw	a5,-408(s0)
    80004f1e:	e8045703          	lhu	a4,-384(s0)
    80004f22:	cb35                	beqz	a4,80004f96 <exec+0x162>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f24:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f26:	e0043423          	sd	zero,-504(s0)
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f2a:	0c000737          	lui	a4,0xc000
    80004f2e:	1779                	addi	a4,a4,-2
    80004f30:	dee43023          	sd	a4,-544(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f34:	6a85                	lui	s5,0x1
    80004f36:	fffa8713          	addi	a4,s5,-1 # fff <_entry-0x7ffff001>
    80004f3a:	dce43c23          	sd	a4,-552(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004f3e:	6d85                	lui	s11,0x1
    80004f40:	aca5                	j	800051b8 <exec+0x384>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f42:	00004517          	auipc	a0,0x4
    80004f46:	80e50513          	addi	a0,a0,-2034 # 80008750 <syscalls+0x290>
    80004f4a:	ffffb097          	auipc	ra,0xffffb
    80004f4e:	5f8080e7          	jalr	1528(ra) # 80000542 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f52:	874a                	mv	a4,s2
    80004f54:	009c86bb          	addw	a3,s9,s1
    80004f58:	4581                	li	a1,0
    80004f5a:	8552                	mv	a0,s4
    80004f5c:	fffff097          	auipc	ra,0xfffff
    80004f60:	c78080e7          	jalr	-904(ra) # 80003bd4 <readi>
    80004f64:	2501                	sext.w	a0,a0
    80004f66:	1ea91963          	bne	s2,a0,80005158 <exec+0x324>
  for(i = 0; i < sz; i += PGSIZE){
    80004f6a:	009d84bb          	addw	s1,s11,s1
    80004f6e:	013d09bb          	addw	s3,s10,s3
    80004f72:	2374f363          	bgeu	s1,s7,80005198 <exec+0x364>
    pa = walkaddr(pagetable, va + i);
    80004f76:	02049593          	slli	a1,s1,0x20
    80004f7a:	9181                	srli	a1,a1,0x20
    80004f7c:	95e2                	add	a1,a1,s8
    80004f7e:	855a                	mv	a0,s6
    80004f80:	ffffc097          	auipc	ra,0xffffc
    80004f84:	110080e7          	jalr	272(ra) # 80001090 <walkaddr>
    80004f88:	862a                	mv	a2,a0
    if(pa == 0)
    80004f8a:	dd45                	beqz	a0,80004f42 <exec+0x10e>
      n = PGSIZE;
    80004f8c:	8956                	mv	s2,s5
    if(sz - i < PGSIZE)
    80004f8e:	fd59f2e3          	bgeu	s3,s5,80004f52 <exec+0x11e>
      n = sz - i;
    80004f92:	894e                	mv	s2,s3
    80004f94:	bf7d                	j	80004f52 <exec+0x11e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f96:	4481                	li	s1,0
  iunlockput(ip);
    80004f98:	8552                	mv	a0,s4
    80004f9a:	fffff097          	auipc	ra,0xfffff
    80004f9e:	be8080e7          	jalr	-1048(ra) # 80003b82 <iunlockput>
  end_op();
    80004fa2:	fffff097          	auipc	ra,0xfffff
    80004fa6:	3ba080e7          	jalr	954(ra) # 8000435c <end_op>
  p = myproc();
    80004faa:	ffffd097          	auipc	ra,0xffffd
    80004fae:	ba6080e7          	jalr	-1114(ra) # 80001b50 <myproc>
    80004fb2:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004fb4:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004fb8:	6785                	lui	a5,0x1
    80004fba:	17fd                	addi	a5,a5,-1
    80004fbc:	94be                	add	s1,s1,a5
    80004fbe:	77fd                	lui	a5,0xfffff
    80004fc0:	8fe5                	and	a5,a5,s1
    80004fc2:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fc6:	6609                	lui	a2,0x2
    80004fc8:	963e                	add	a2,a2,a5
    80004fca:	85be                	mv	a1,a5
    80004fcc:	855a                	mv	a0,s6
    80004fce:	ffffc097          	auipc	ra,0xffffc
    80004fd2:	4b0080e7          	jalr	1200(ra) # 8000147e <uvmalloc>
    80004fd6:	8baa                	mv	s7,a0
  ip = 0;
    80004fd8:	4a01                	li	s4,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fda:	16050f63          	beqz	a0,80005158 <exec+0x324>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fde:	75f9                	lui	a1,0xffffe
    80004fe0:	95aa                	add	a1,a1,a0
    80004fe2:	855a                	mv	a0,s6
    80004fe4:	ffffc097          	auipc	ra,0xffffc
    80004fe8:	6b8080e7          	jalr	1720(ra) # 8000169c <uvmclear>
  stackbase = sp - PGSIZE;
    80004fec:	7c7d                	lui	s8,0xfffff
    80004fee:	9c5e                	add	s8,s8,s7
  for(argc = 0; argv[argc]; argc++) {
    80004ff0:	df043783          	ld	a5,-528(s0)
    80004ff4:	6388                	ld	a0,0(a5)
    80004ff6:	c925                	beqz	a0,80005066 <exec+0x232>
    80004ff8:	e8840993          	addi	s3,s0,-376
    80004ffc:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005000:	895e                	mv	s2,s7
  for(argc = 0; argv[argc]; argc++) {
    80005002:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005004:	ffffc097          	auipc	ra,0xffffc
    80005008:	e7a080e7          	jalr	-390(ra) # 80000e7e <strlen>
    8000500c:	0015079b          	addiw	a5,a0,1
    80005010:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005014:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005018:	17896463          	bltu	s2,s8,80005180 <exec+0x34c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000501c:	df043d83          	ld	s11,-528(s0)
    80005020:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005024:	8552                	mv	a0,s4
    80005026:	ffffc097          	auipc	ra,0xffffc
    8000502a:	e58080e7          	jalr	-424(ra) # 80000e7e <strlen>
    8000502e:	0015069b          	addiw	a3,a0,1
    80005032:	8652                	mv	a2,s4
    80005034:	85ca                	mv	a1,s2
    80005036:	855a                	mv	a0,s6
    80005038:	ffffc097          	auipc	ra,0xffffc
    8000503c:	696080e7          	jalr	1686(ra) # 800016ce <copyout>
    80005040:	14054463          	bltz	a0,80005188 <exec+0x354>
    ustack[argc] = sp;
    80005044:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005048:	0485                	addi	s1,s1,1
    8000504a:	008d8793          	addi	a5,s11,8
    8000504e:	def43823          	sd	a5,-528(s0)
    80005052:	008db503          	ld	a0,8(s11)
    80005056:	c911                	beqz	a0,8000506a <exec+0x236>
    if(argc >= MAXARG)
    80005058:	09a1                	addi	s3,s3,8
    8000505a:	fb3c95e3          	bne	s9,s3,80005004 <exec+0x1d0>
  sz = sz1;
    8000505e:	df743c23          	sd	s7,-520(s0)
  ip = 0;
    80005062:	4a01                	li	s4,0
    80005064:	a8d5                	j	80005158 <exec+0x324>
  sp = sz;
    80005066:	895e                	mv	s2,s7
  for(argc = 0; argv[argc]; argc++) {
    80005068:	4481                	li	s1,0
  ustack[argc] = 0;
    8000506a:	00349793          	slli	a5,s1,0x3
    8000506e:	f9040713          	addi	a4,s0,-112
    80005072:	97ba                	add	a5,a5,a4
    80005074:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd7ed8>
  sp -= (argc+1) * sizeof(uint64);
    80005078:	00148693          	addi	a3,s1,1
    8000507c:	068e                	slli	a3,a3,0x3
    8000507e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005082:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005086:	01897663          	bgeu	s2,s8,80005092 <exec+0x25e>
  sz = sz1;
    8000508a:	df743c23          	sd	s7,-520(s0)
  ip = 0;
    8000508e:	4a01                	li	s4,0
    80005090:	a0e1                	j	80005158 <exec+0x324>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005092:	e8840613          	addi	a2,s0,-376
    80005096:	85ca                	mv	a1,s2
    80005098:	855a                	mv	a0,s6
    8000509a:	ffffc097          	auipc	ra,0xffffc
    8000509e:	634080e7          	jalr	1588(ra) # 800016ce <copyout>
    800050a2:	0e054763          	bltz	a0,80005190 <exec+0x35c>
  p->trapframe->a1 = sp;
    800050a6:	058ab783          	ld	a5,88(s5)
    800050aa:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050ae:	de843783          	ld	a5,-536(s0)
    800050b2:	0007c703          	lbu	a4,0(a5)
    800050b6:	cf11                	beqz	a4,800050d2 <exec+0x29e>
    800050b8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050ba:	02f00693          	li	a3,47
    800050be:	a039                	j	800050cc <exec+0x298>
      last = s+1;
    800050c0:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800050c4:	0785                	addi	a5,a5,1
    800050c6:	fff7c703          	lbu	a4,-1(a5)
    800050ca:	c701                	beqz	a4,800050d2 <exec+0x29e>
    if(*s == '/')
    800050cc:	fed71ce3          	bne	a4,a3,800050c4 <exec+0x290>
    800050d0:	bfc5                	j	800050c0 <exec+0x28c>
  safestrcpy(p->name, last, sizeof(p->name));
    800050d2:	4641                	li	a2,16
    800050d4:	de843583          	ld	a1,-536(s0)
    800050d8:	158a8513          	addi	a0,s5,344
    800050dc:	ffffc097          	auipc	ra,0xffffc
    800050e0:	d70080e7          	jalr	-656(ra) # 80000e4c <safestrcpy>
  uvmunmap(p->kernel_pagetable, 0, PGROUNDUP(oldsz)/PGSIZE, 0);
    800050e4:	6605                	lui	a2,0x1
    800050e6:	167d                	addi	a2,a2,-1
    800050e8:	966a                	add	a2,a2,s10
    800050ea:	4681                	li	a3,0
    800050ec:	8231                	srli	a2,a2,0xc
    800050ee:	4581                	li	a1,0
    800050f0:	168ab503          	ld	a0,360(s5)
    800050f4:	ffffc097          	auipc	ra,0xffffc
    800050f8:	1de080e7          	jalr	478(ra) # 800012d2 <uvmunmap>
  kvmcopymappings(pagetable, p->kernel_pagetable, 0, sz);
    800050fc:	86de                	mv	a3,s7
    800050fe:	4601                	li	a2,0
    80005100:	168ab583          	ld	a1,360(s5)
    80005104:	855a                	mv	a0,s6
    80005106:	ffffd097          	auipc	ra,0xffffd
    8000510a:	880080e7          	jalr	-1920(ra) # 80001986 <kvmcopymappings>
  oldpagetable = p->pagetable;
    8000510e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005112:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005116:	057ab423          	sd	s7,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000511a:	058ab783          	ld	a5,88(s5)
    8000511e:	e6043703          	ld	a4,-416(s0)
    80005122:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005124:	058ab783          	ld	a5,88(s5)
    80005128:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000512c:	85ea                	mv	a1,s10
    8000512e:	ffffd097          	auipc	ra,0xffffd
    80005132:	ae6080e7          	jalr	-1306(ra) # 80001c14 <proc_freepagetable>
  if (p->pid == 1) {
    80005136:	038aa703          	lw	a4,56(s5)
    8000513a:	4785                	li	a5,1
    8000513c:	00f70563          	beq	a4,a5,80005146 <exec+0x312>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005140:	0004851b          	sext.w	a0,s1
    80005144:	bb41                	j	80004ed4 <exec+0xa0>
	vmprint(p->pagetable);
    80005146:	050ab503          	ld	a0,80(s5)
    8000514a:	ffffc097          	auipc	ra,0xffffc
    8000514e:	70a080e7          	jalr	1802(ra) # 80001854 <vmprint>
    80005152:	b7fd                	j	80005140 <exec+0x30c>
    80005154:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005158:	df843583          	ld	a1,-520(s0)
    8000515c:	855a                	mv	a0,s6
    8000515e:	ffffd097          	auipc	ra,0xffffd
    80005162:	ab6080e7          	jalr	-1354(ra) # 80001c14 <proc_freepagetable>
  if(ip){
    80005166:	d40a1de3          	bnez	s4,80004ec0 <exec+0x8c>
  return -1;
    8000516a:	557d                	li	a0,-1
    8000516c:	b3a5                	j	80004ed4 <exec+0xa0>
    8000516e:	de943c23          	sd	s1,-520(s0)
    80005172:	b7dd                	j	80005158 <exec+0x324>
    80005174:	de943c23          	sd	s1,-520(s0)
    80005178:	b7c5                	j	80005158 <exec+0x324>
    8000517a:	de943c23          	sd	s1,-520(s0)
    8000517e:	bfe9                	j	80005158 <exec+0x324>
  sz = sz1;
    80005180:	df743c23          	sd	s7,-520(s0)
  ip = 0;
    80005184:	4a01                	li	s4,0
    80005186:	bfc9                	j	80005158 <exec+0x324>
  sz = sz1;
    80005188:	df743c23          	sd	s7,-520(s0)
  ip = 0;
    8000518c:	4a01                	li	s4,0
    8000518e:	b7e9                	j	80005158 <exec+0x324>
  sz = sz1;
    80005190:	df743c23          	sd	s7,-520(s0)
  ip = 0;
    80005194:	4a01                	li	s4,0
    80005196:	b7c9                	j	80005158 <exec+0x324>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005198:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000519c:	e0843783          	ld	a5,-504(s0)
    800051a0:	0017869b          	addiw	a3,a5,1
    800051a4:	e0d43423          	sd	a3,-504(s0)
    800051a8:	e0043783          	ld	a5,-512(s0)
    800051ac:	0387879b          	addiw	a5,a5,56
    800051b0:	e8045703          	lhu	a4,-384(s0)
    800051b4:	dee6d2e3          	bge	a3,a4,80004f98 <exec+0x164>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051b8:	2781                	sext.w	a5,a5
    800051ba:	e0f43023          	sd	a5,-512(s0)
    800051be:	03800713          	li	a4,56
    800051c2:	86be                	mv	a3,a5
    800051c4:	e1040613          	addi	a2,s0,-496
    800051c8:	4581                	li	a1,0
    800051ca:	8552                	mv	a0,s4
    800051cc:	fffff097          	auipc	ra,0xfffff
    800051d0:	a08080e7          	jalr	-1528(ra) # 80003bd4 <readi>
    800051d4:	03800793          	li	a5,56
    800051d8:	f6f51ee3          	bne	a0,a5,80005154 <exec+0x320>
    if(ph.type != ELF_PROG_LOAD)
    800051dc:	e1042783          	lw	a5,-496(s0)
    800051e0:	4705                	li	a4,1
    800051e2:	fae79de3          	bne	a5,a4,8000519c <exec+0x368>
    if(ph.memsz < ph.filesz)
    800051e6:	e3843603          	ld	a2,-456(s0)
    800051ea:	e3043783          	ld	a5,-464(s0)
    800051ee:	f8f660e3          	bltu	a2,a5,8000516e <exec+0x33a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051f2:	e2043783          	ld	a5,-480(s0)
    800051f6:	963e                	add	a2,a2,a5
    800051f8:	f6f66ee3          	bltu	a2,a5,80005174 <exec+0x340>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800051fc:	85a6                	mv	a1,s1
    800051fe:	855a                	mv	a0,s6
    80005200:	ffffc097          	auipc	ra,0xffffc
    80005204:	27e080e7          	jalr	638(ra) # 8000147e <uvmalloc>
    80005208:	dea43c23          	sd	a0,-520(s0)
    8000520c:	fff50793          	addi	a5,a0,-1
    80005210:	de043703          	ld	a4,-544(s0)
    80005214:	f6f763e3          	bltu	a4,a5,8000517a <exec+0x346>
    if(ph.vaddr % PGSIZE != 0)
    80005218:	e2043c03          	ld	s8,-480(s0)
    8000521c:	dd843783          	ld	a5,-552(s0)
    80005220:	00fc77b3          	and	a5,s8,a5
    80005224:	fb95                	bnez	a5,80005158 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005226:	e1842c83          	lw	s9,-488(s0)
    8000522a:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000522e:	f60b85e3          	beqz	s7,80005198 <exec+0x364>
    80005232:	89de                	mv	s3,s7
    80005234:	4481                	li	s1,0
    80005236:	7d7d                	lui	s10,0xfffff
    80005238:	bb3d                	j	80004f76 <exec+0x142>

000000008000523a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000523a:	7179                	addi	sp,sp,-48
    8000523c:	f406                	sd	ra,40(sp)
    8000523e:	f022                	sd	s0,32(sp)
    80005240:	ec26                	sd	s1,24(sp)
    80005242:	e84a                	sd	s2,16(sp)
    80005244:	1800                	addi	s0,sp,48
    80005246:	892e                	mv	s2,a1
    80005248:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000524a:	fdc40593          	addi	a1,s0,-36
    8000524e:	ffffe097          	auipc	ra,0xffffe
    80005252:	b62080e7          	jalr	-1182(ra) # 80002db0 <argint>
    80005256:	04054063          	bltz	a0,80005296 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000525a:	fdc42703          	lw	a4,-36(s0)
    8000525e:	47bd                	li	a5,15
    80005260:	02e7ed63          	bltu	a5,a4,8000529a <argfd+0x60>
    80005264:	ffffd097          	auipc	ra,0xffffd
    80005268:	8ec080e7          	jalr	-1812(ra) # 80001b50 <myproc>
    8000526c:	fdc42703          	lw	a4,-36(s0)
    80005270:	01a70793          	addi	a5,a4,26 # c00001a <_entry-0x73ffffe6>
    80005274:	078e                	slli	a5,a5,0x3
    80005276:	953e                	add	a0,a0,a5
    80005278:	611c                	ld	a5,0(a0)
    8000527a:	c395                	beqz	a5,8000529e <argfd+0x64>
    return -1;
  if(pfd)
    8000527c:	00090463          	beqz	s2,80005284 <argfd+0x4a>
    *pfd = fd;
    80005280:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005284:	4501                	li	a0,0
  if(pf)
    80005286:	c091                	beqz	s1,8000528a <argfd+0x50>
    *pf = f;
    80005288:	e09c                	sd	a5,0(s1)
}
    8000528a:	70a2                	ld	ra,40(sp)
    8000528c:	7402                	ld	s0,32(sp)
    8000528e:	64e2                	ld	s1,24(sp)
    80005290:	6942                	ld	s2,16(sp)
    80005292:	6145                	addi	sp,sp,48
    80005294:	8082                	ret
    return -1;
    80005296:	557d                	li	a0,-1
    80005298:	bfcd                	j	8000528a <argfd+0x50>
    return -1;
    8000529a:	557d                	li	a0,-1
    8000529c:	b7fd                	j	8000528a <argfd+0x50>
    8000529e:	557d                	li	a0,-1
    800052a0:	b7ed                	j	8000528a <argfd+0x50>

00000000800052a2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052a2:	1101                	addi	sp,sp,-32
    800052a4:	ec06                	sd	ra,24(sp)
    800052a6:	e822                	sd	s0,16(sp)
    800052a8:	e426                	sd	s1,8(sp)
    800052aa:	1000                	addi	s0,sp,32
    800052ac:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052ae:	ffffd097          	auipc	ra,0xffffd
    800052b2:	8a2080e7          	jalr	-1886(ra) # 80001b50 <myproc>
    800052b6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052b8:	0d050793          	addi	a5,a0,208
    800052bc:	4501                	li	a0,0
    800052be:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052c0:	6398                	ld	a4,0(a5)
    800052c2:	cb19                	beqz	a4,800052d8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052c4:	2505                	addiw	a0,a0,1
    800052c6:	07a1                	addi	a5,a5,8
    800052c8:	fed51ce3          	bne	a0,a3,800052c0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052cc:	557d                	li	a0,-1
}
    800052ce:	60e2                	ld	ra,24(sp)
    800052d0:	6442                	ld	s0,16(sp)
    800052d2:	64a2                	ld	s1,8(sp)
    800052d4:	6105                	addi	sp,sp,32
    800052d6:	8082                	ret
      p->ofile[fd] = f;
    800052d8:	01a50793          	addi	a5,a0,26
    800052dc:	078e                	slli	a5,a5,0x3
    800052de:	963e                	add	a2,a2,a5
    800052e0:	e204                	sd	s1,0(a2)
      return fd;
    800052e2:	b7f5                	j	800052ce <fdalloc+0x2c>

00000000800052e4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052e4:	715d                	addi	sp,sp,-80
    800052e6:	e486                	sd	ra,72(sp)
    800052e8:	e0a2                	sd	s0,64(sp)
    800052ea:	fc26                	sd	s1,56(sp)
    800052ec:	f84a                	sd	s2,48(sp)
    800052ee:	f44e                	sd	s3,40(sp)
    800052f0:	f052                	sd	s4,32(sp)
    800052f2:	ec56                	sd	s5,24(sp)
    800052f4:	0880                	addi	s0,sp,80
    800052f6:	89ae                	mv	s3,a1
    800052f8:	8ab2                	mv	s5,a2
    800052fa:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052fc:	fb040593          	addi	a1,s0,-80
    80005300:	fffff097          	auipc	ra,0xfffff
    80005304:	dee080e7          	jalr	-530(ra) # 800040ee <nameiparent>
    80005308:	892a                	mv	s2,a0
    8000530a:	12050e63          	beqz	a0,80005446 <create+0x162>
    return 0;

  ilock(dp);
    8000530e:	ffffe097          	auipc	ra,0xffffe
    80005312:	612080e7          	jalr	1554(ra) # 80003920 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005316:	4601                	li	a2,0
    80005318:	fb040593          	addi	a1,s0,-80
    8000531c:	854a                	mv	a0,s2
    8000531e:	fffff097          	auipc	ra,0xfffff
    80005322:	ae0080e7          	jalr	-1312(ra) # 80003dfe <dirlookup>
    80005326:	84aa                	mv	s1,a0
    80005328:	c921                	beqz	a0,80005378 <create+0x94>
    iunlockput(dp);
    8000532a:	854a                	mv	a0,s2
    8000532c:	fffff097          	auipc	ra,0xfffff
    80005330:	856080e7          	jalr	-1962(ra) # 80003b82 <iunlockput>
    ilock(ip);
    80005334:	8526                	mv	a0,s1
    80005336:	ffffe097          	auipc	ra,0xffffe
    8000533a:	5ea080e7          	jalr	1514(ra) # 80003920 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000533e:	2981                	sext.w	s3,s3
    80005340:	4789                	li	a5,2
    80005342:	02f99463          	bne	s3,a5,8000536a <create+0x86>
    80005346:	0444d783          	lhu	a5,68(s1)
    8000534a:	37f9                	addiw	a5,a5,-2
    8000534c:	17c2                	slli	a5,a5,0x30
    8000534e:	93c1                	srli	a5,a5,0x30
    80005350:	4705                	li	a4,1
    80005352:	00f76c63          	bltu	a4,a5,8000536a <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005356:	8526                	mv	a0,s1
    80005358:	60a6                	ld	ra,72(sp)
    8000535a:	6406                	ld	s0,64(sp)
    8000535c:	74e2                	ld	s1,56(sp)
    8000535e:	7942                	ld	s2,48(sp)
    80005360:	79a2                	ld	s3,40(sp)
    80005362:	7a02                	ld	s4,32(sp)
    80005364:	6ae2                	ld	s5,24(sp)
    80005366:	6161                	addi	sp,sp,80
    80005368:	8082                	ret
    iunlockput(ip);
    8000536a:	8526                	mv	a0,s1
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	816080e7          	jalr	-2026(ra) # 80003b82 <iunlockput>
    return 0;
    80005374:	4481                	li	s1,0
    80005376:	b7c5                	j	80005356 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005378:	85ce                	mv	a1,s3
    8000537a:	00092503          	lw	a0,0(s2)
    8000537e:	ffffe097          	auipc	ra,0xffffe
    80005382:	40a080e7          	jalr	1034(ra) # 80003788 <ialloc>
    80005386:	84aa                	mv	s1,a0
    80005388:	c521                	beqz	a0,800053d0 <create+0xec>
  ilock(ip);
    8000538a:	ffffe097          	auipc	ra,0xffffe
    8000538e:	596080e7          	jalr	1430(ra) # 80003920 <ilock>
  ip->major = major;
    80005392:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005396:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000539a:	4a05                	li	s4,1
    8000539c:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800053a0:	8526                	mv	a0,s1
    800053a2:	ffffe097          	auipc	ra,0xffffe
    800053a6:	4b4080e7          	jalr	1204(ra) # 80003856 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053aa:	2981                	sext.w	s3,s3
    800053ac:	03498a63          	beq	s3,s4,800053e0 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800053b0:	40d0                	lw	a2,4(s1)
    800053b2:	fb040593          	addi	a1,s0,-80
    800053b6:	854a                	mv	a0,s2
    800053b8:	fffff097          	auipc	ra,0xfffff
    800053bc:	c56080e7          	jalr	-938(ra) # 8000400e <dirlink>
    800053c0:	06054b63          	bltz	a0,80005436 <create+0x152>
  iunlockput(dp);
    800053c4:	854a                	mv	a0,s2
    800053c6:	ffffe097          	auipc	ra,0xffffe
    800053ca:	7bc080e7          	jalr	1980(ra) # 80003b82 <iunlockput>
  return ip;
    800053ce:	b761                	j	80005356 <create+0x72>
    panic("create: ialloc");
    800053d0:	00003517          	auipc	a0,0x3
    800053d4:	3a050513          	addi	a0,a0,928 # 80008770 <syscalls+0x2b0>
    800053d8:	ffffb097          	auipc	ra,0xffffb
    800053dc:	16a080e7          	jalr	362(ra) # 80000542 <panic>
    dp->nlink++;  // for ".."
    800053e0:	04a95783          	lhu	a5,74(s2)
    800053e4:	2785                	addiw	a5,a5,1
    800053e6:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800053ea:	854a                	mv	a0,s2
    800053ec:	ffffe097          	auipc	ra,0xffffe
    800053f0:	46a080e7          	jalr	1130(ra) # 80003856 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053f4:	40d0                	lw	a2,4(s1)
    800053f6:	00003597          	auipc	a1,0x3
    800053fa:	38a58593          	addi	a1,a1,906 # 80008780 <syscalls+0x2c0>
    800053fe:	8526                	mv	a0,s1
    80005400:	fffff097          	auipc	ra,0xfffff
    80005404:	c0e080e7          	jalr	-1010(ra) # 8000400e <dirlink>
    80005408:	00054f63          	bltz	a0,80005426 <create+0x142>
    8000540c:	00492603          	lw	a2,4(s2)
    80005410:	00003597          	auipc	a1,0x3
    80005414:	da858593          	addi	a1,a1,-600 # 800081b8 <digits+0x188>
    80005418:	8526                	mv	a0,s1
    8000541a:	fffff097          	auipc	ra,0xfffff
    8000541e:	bf4080e7          	jalr	-1036(ra) # 8000400e <dirlink>
    80005422:	f80557e3          	bgez	a0,800053b0 <create+0xcc>
      panic("create dots");
    80005426:	00003517          	auipc	a0,0x3
    8000542a:	36250513          	addi	a0,a0,866 # 80008788 <syscalls+0x2c8>
    8000542e:	ffffb097          	auipc	ra,0xffffb
    80005432:	114080e7          	jalr	276(ra) # 80000542 <panic>
    panic("create: dirlink");
    80005436:	00003517          	auipc	a0,0x3
    8000543a:	36250513          	addi	a0,a0,866 # 80008798 <syscalls+0x2d8>
    8000543e:	ffffb097          	auipc	ra,0xffffb
    80005442:	104080e7          	jalr	260(ra) # 80000542 <panic>
    return 0;
    80005446:	84aa                	mv	s1,a0
    80005448:	b739                	j	80005356 <create+0x72>

000000008000544a <sys_dup>:
{
    8000544a:	7179                	addi	sp,sp,-48
    8000544c:	f406                	sd	ra,40(sp)
    8000544e:	f022                	sd	s0,32(sp)
    80005450:	ec26                	sd	s1,24(sp)
    80005452:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005454:	fd840613          	addi	a2,s0,-40
    80005458:	4581                	li	a1,0
    8000545a:	4501                	li	a0,0
    8000545c:	00000097          	auipc	ra,0x0
    80005460:	dde080e7          	jalr	-546(ra) # 8000523a <argfd>
    return -1;
    80005464:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005466:	02054363          	bltz	a0,8000548c <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000546a:	fd843503          	ld	a0,-40(s0)
    8000546e:	00000097          	auipc	ra,0x0
    80005472:	e34080e7          	jalr	-460(ra) # 800052a2 <fdalloc>
    80005476:	84aa                	mv	s1,a0
    return -1;
    80005478:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000547a:	00054963          	bltz	a0,8000548c <sys_dup+0x42>
  filedup(f);
    8000547e:	fd843503          	ld	a0,-40(s0)
    80005482:	fffff097          	auipc	ra,0xfffff
    80005486:	2da080e7          	jalr	730(ra) # 8000475c <filedup>
  return fd;
    8000548a:	87a6                	mv	a5,s1
}
    8000548c:	853e                	mv	a0,a5
    8000548e:	70a2                	ld	ra,40(sp)
    80005490:	7402                	ld	s0,32(sp)
    80005492:	64e2                	ld	s1,24(sp)
    80005494:	6145                	addi	sp,sp,48
    80005496:	8082                	ret

0000000080005498 <sys_read>:
{
    80005498:	7179                	addi	sp,sp,-48
    8000549a:	f406                	sd	ra,40(sp)
    8000549c:	f022                	sd	s0,32(sp)
    8000549e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054a0:	fe840613          	addi	a2,s0,-24
    800054a4:	4581                	li	a1,0
    800054a6:	4501                	li	a0,0
    800054a8:	00000097          	auipc	ra,0x0
    800054ac:	d92080e7          	jalr	-622(ra) # 8000523a <argfd>
    return -1;
    800054b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054b2:	04054163          	bltz	a0,800054f4 <sys_read+0x5c>
    800054b6:	fe440593          	addi	a1,s0,-28
    800054ba:	4509                	li	a0,2
    800054bc:	ffffe097          	auipc	ra,0xffffe
    800054c0:	8f4080e7          	jalr	-1804(ra) # 80002db0 <argint>
    return -1;
    800054c4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054c6:	02054763          	bltz	a0,800054f4 <sys_read+0x5c>
    800054ca:	fd840593          	addi	a1,s0,-40
    800054ce:	4505                	li	a0,1
    800054d0:	ffffe097          	auipc	ra,0xffffe
    800054d4:	902080e7          	jalr	-1790(ra) # 80002dd2 <argaddr>
    return -1;
    800054d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054da:	00054d63          	bltz	a0,800054f4 <sys_read+0x5c>
  return fileread(f, p, n);
    800054de:	fe442603          	lw	a2,-28(s0)
    800054e2:	fd843583          	ld	a1,-40(s0)
    800054e6:	fe843503          	ld	a0,-24(s0)
    800054ea:	fffff097          	auipc	ra,0xfffff
    800054ee:	3fe080e7          	jalr	1022(ra) # 800048e8 <fileread>
    800054f2:	87aa                	mv	a5,a0
}
    800054f4:	853e                	mv	a0,a5
    800054f6:	70a2                	ld	ra,40(sp)
    800054f8:	7402                	ld	s0,32(sp)
    800054fa:	6145                	addi	sp,sp,48
    800054fc:	8082                	ret

00000000800054fe <sys_write>:
{
    800054fe:	7179                	addi	sp,sp,-48
    80005500:	f406                	sd	ra,40(sp)
    80005502:	f022                	sd	s0,32(sp)
    80005504:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005506:	fe840613          	addi	a2,s0,-24
    8000550a:	4581                	li	a1,0
    8000550c:	4501                	li	a0,0
    8000550e:	00000097          	auipc	ra,0x0
    80005512:	d2c080e7          	jalr	-724(ra) # 8000523a <argfd>
    return -1;
    80005516:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005518:	04054163          	bltz	a0,8000555a <sys_write+0x5c>
    8000551c:	fe440593          	addi	a1,s0,-28
    80005520:	4509                	li	a0,2
    80005522:	ffffe097          	auipc	ra,0xffffe
    80005526:	88e080e7          	jalr	-1906(ra) # 80002db0 <argint>
    return -1;
    8000552a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000552c:	02054763          	bltz	a0,8000555a <sys_write+0x5c>
    80005530:	fd840593          	addi	a1,s0,-40
    80005534:	4505                	li	a0,1
    80005536:	ffffe097          	auipc	ra,0xffffe
    8000553a:	89c080e7          	jalr	-1892(ra) # 80002dd2 <argaddr>
    return -1;
    8000553e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005540:	00054d63          	bltz	a0,8000555a <sys_write+0x5c>
  return filewrite(f, p, n);
    80005544:	fe442603          	lw	a2,-28(s0)
    80005548:	fd843583          	ld	a1,-40(s0)
    8000554c:	fe843503          	ld	a0,-24(s0)
    80005550:	fffff097          	auipc	ra,0xfffff
    80005554:	45a080e7          	jalr	1114(ra) # 800049aa <filewrite>
    80005558:	87aa                	mv	a5,a0
}
    8000555a:	853e                	mv	a0,a5
    8000555c:	70a2                	ld	ra,40(sp)
    8000555e:	7402                	ld	s0,32(sp)
    80005560:	6145                	addi	sp,sp,48
    80005562:	8082                	ret

0000000080005564 <sys_close>:
{
    80005564:	1101                	addi	sp,sp,-32
    80005566:	ec06                	sd	ra,24(sp)
    80005568:	e822                	sd	s0,16(sp)
    8000556a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000556c:	fe040613          	addi	a2,s0,-32
    80005570:	fec40593          	addi	a1,s0,-20
    80005574:	4501                	li	a0,0
    80005576:	00000097          	auipc	ra,0x0
    8000557a:	cc4080e7          	jalr	-828(ra) # 8000523a <argfd>
    return -1;
    8000557e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005580:	02054463          	bltz	a0,800055a8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005584:	ffffc097          	auipc	ra,0xffffc
    80005588:	5cc080e7          	jalr	1484(ra) # 80001b50 <myproc>
    8000558c:	fec42783          	lw	a5,-20(s0)
    80005590:	07e9                	addi	a5,a5,26
    80005592:	078e                	slli	a5,a5,0x3
    80005594:	97aa                	add	a5,a5,a0
    80005596:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000559a:	fe043503          	ld	a0,-32(s0)
    8000559e:	fffff097          	auipc	ra,0xfffff
    800055a2:	210080e7          	jalr	528(ra) # 800047ae <fileclose>
  return 0;
    800055a6:	4781                	li	a5,0
}
    800055a8:	853e                	mv	a0,a5
    800055aa:	60e2                	ld	ra,24(sp)
    800055ac:	6442                	ld	s0,16(sp)
    800055ae:	6105                	addi	sp,sp,32
    800055b0:	8082                	ret

00000000800055b2 <sys_fstat>:
{
    800055b2:	1101                	addi	sp,sp,-32
    800055b4:	ec06                	sd	ra,24(sp)
    800055b6:	e822                	sd	s0,16(sp)
    800055b8:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055ba:	fe840613          	addi	a2,s0,-24
    800055be:	4581                	li	a1,0
    800055c0:	4501                	li	a0,0
    800055c2:	00000097          	auipc	ra,0x0
    800055c6:	c78080e7          	jalr	-904(ra) # 8000523a <argfd>
    return -1;
    800055ca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055cc:	02054563          	bltz	a0,800055f6 <sys_fstat+0x44>
    800055d0:	fe040593          	addi	a1,s0,-32
    800055d4:	4505                	li	a0,1
    800055d6:	ffffd097          	auipc	ra,0xffffd
    800055da:	7fc080e7          	jalr	2044(ra) # 80002dd2 <argaddr>
    return -1;
    800055de:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055e0:	00054b63          	bltz	a0,800055f6 <sys_fstat+0x44>
  return filestat(f, st);
    800055e4:	fe043583          	ld	a1,-32(s0)
    800055e8:	fe843503          	ld	a0,-24(s0)
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	28a080e7          	jalr	650(ra) # 80004876 <filestat>
    800055f4:	87aa                	mv	a5,a0
}
    800055f6:	853e                	mv	a0,a5
    800055f8:	60e2                	ld	ra,24(sp)
    800055fa:	6442                	ld	s0,16(sp)
    800055fc:	6105                	addi	sp,sp,32
    800055fe:	8082                	ret

0000000080005600 <sys_link>:
{
    80005600:	7169                	addi	sp,sp,-304
    80005602:	f606                	sd	ra,296(sp)
    80005604:	f222                	sd	s0,288(sp)
    80005606:	ee26                	sd	s1,280(sp)
    80005608:	ea4a                	sd	s2,272(sp)
    8000560a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000560c:	08000613          	li	a2,128
    80005610:	ed040593          	addi	a1,s0,-304
    80005614:	4501                	li	a0,0
    80005616:	ffffd097          	auipc	ra,0xffffd
    8000561a:	7de080e7          	jalr	2014(ra) # 80002df4 <argstr>
    return -1;
    8000561e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005620:	10054e63          	bltz	a0,8000573c <sys_link+0x13c>
    80005624:	08000613          	li	a2,128
    80005628:	f5040593          	addi	a1,s0,-176
    8000562c:	4505                	li	a0,1
    8000562e:	ffffd097          	auipc	ra,0xffffd
    80005632:	7c6080e7          	jalr	1990(ra) # 80002df4 <argstr>
    return -1;
    80005636:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005638:	10054263          	bltz	a0,8000573c <sys_link+0x13c>
  begin_op();
    8000563c:	fffff097          	auipc	ra,0xfffff
    80005640:	ca0080e7          	jalr	-864(ra) # 800042dc <begin_op>
  if((ip = namei(old)) == 0){
    80005644:	ed040513          	addi	a0,s0,-304
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	a88080e7          	jalr	-1400(ra) # 800040d0 <namei>
    80005650:	84aa                	mv	s1,a0
    80005652:	c551                	beqz	a0,800056de <sys_link+0xde>
  ilock(ip);
    80005654:	ffffe097          	auipc	ra,0xffffe
    80005658:	2cc080e7          	jalr	716(ra) # 80003920 <ilock>
  if(ip->type == T_DIR){
    8000565c:	04449703          	lh	a4,68(s1)
    80005660:	4785                	li	a5,1
    80005662:	08f70463          	beq	a4,a5,800056ea <sys_link+0xea>
  ip->nlink++;
    80005666:	04a4d783          	lhu	a5,74(s1)
    8000566a:	2785                	addiw	a5,a5,1
    8000566c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005670:	8526                	mv	a0,s1
    80005672:	ffffe097          	auipc	ra,0xffffe
    80005676:	1e4080e7          	jalr	484(ra) # 80003856 <iupdate>
  iunlock(ip);
    8000567a:	8526                	mv	a0,s1
    8000567c:	ffffe097          	auipc	ra,0xffffe
    80005680:	366080e7          	jalr	870(ra) # 800039e2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005684:	fd040593          	addi	a1,s0,-48
    80005688:	f5040513          	addi	a0,s0,-176
    8000568c:	fffff097          	auipc	ra,0xfffff
    80005690:	a62080e7          	jalr	-1438(ra) # 800040ee <nameiparent>
    80005694:	892a                	mv	s2,a0
    80005696:	c935                	beqz	a0,8000570a <sys_link+0x10a>
  ilock(dp);
    80005698:	ffffe097          	auipc	ra,0xffffe
    8000569c:	288080e7          	jalr	648(ra) # 80003920 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056a0:	00092703          	lw	a4,0(s2)
    800056a4:	409c                	lw	a5,0(s1)
    800056a6:	04f71d63          	bne	a4,a5,80005700 <sys_link+0x100>
    800056aa:	40d0                	lw	a2,4(s1)
    800056ac:	fd040593          	addi	a1,s0,-48
    800056b0:	854a                	mv	a0,s2
    800056b2:	fffff097          	auipc	ra,0xfffff
    800056b6:	95c080e7          	jalr	-1700(ra) # 8000400e <dirlink>
    800056ba:	04054363          	bltz	a0,80005700 <sys_link+0x100>
  iunlockput(dp);
    800056be:	854a                	mv	a0,s2
    800056c0:	ffffe097          	auipc	ra,0xffffe
    800056c4:	4c2080e7          	jalr	1218(ra) # 80003b82 <iunlockput>
  iput(ip);
    800056c8:	8526                	mv	a0,s1
    800056ca:	ffffe097          	auipc	ra,0xffffe
    800056ce:	410080e7          	jalr	1040(ra) # 80003ada <iput>
  end_op();
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	c8a080e7          	jalr	-886(ra) # 8000435c <end_op>
  return 0;
    800056da:	4781                	li	a5,0
    800056dc:	a085                	j	8000573c <sys_link+0x13c>
    end_op();
    800056de:	fffff097          	auipc	ra,0xfffff
    800056e2:	c7e080e7          	jalr	-898(ra) # 8000435c <end_op>
    return -1;
    800056e6:	57fd                	li	a5,-1
    800056e8:	a891                	j	8000573c <sys_link+0x13c>
    iunlockput(ip);
    800056ea:	8526                	mv	a0,s1
    800056ec:	ffffe097          	auipc	ra,0xffffe
    800056f0:	496080e7          	jalr	1174(ra) # 80003b82 <iunlockput>
    end_op();
    800056f4:	fffff097          	auipc	ra,0xfffff
    800056f8:	c68080e7          	jalr	-920(ra) # 8000435c <end_op>
    return -1;
    800056fc:	57fd                	li	a5,-1
    800056fe:	a83d                	j	8000573c <sys_link+0x13c>
    iunlockput(dp);
    80005700:	854a                	mv	a0,s2
    80005702:	ffffe097          	auipc	ra,0xffffe
    80005706:	480080e7          	jalr	1152(ra) # 80003b82 <iunlockput>
  ilock(ip);
    8000570a:	8526                	mv	a0,s1
    8000570c:	ffffe097          	auipc	ra,0xffffe
    80005710:	214080e7          	jalr	532(ra) # 80003920 <ilock>
  ip->nlink--;
    80005714:	04a4d783          	lhu	a5,74(s1)
    80005718:	37fd                	addiw	a5,a5,-1
    8000571a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000571e:	8526                	mv	a0,s1
    80005720:	ffffe097          	auipc	ra,0xffffe
    80005724:	136080e7          	jalr	310(ra) # 80003856 <iupdate>
  iunlockput(ip);
    80005728:	8526                	mv	a0,s1
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	458080e7          	jalr	1112(ra) # 80003b82 <iunlockput>
  end_op();
    80005732:	fffff097          	auipc	ra,0xfffff
    80005736:	c2a080e7          	jalr	-982(ra) # 8000435c <end_op>
  return -1;
    8000573a:	57fd                	li	a5,-1
}
    8000573c:	853e                	mv	a0,a5
    8000573e:	70b2                	ld	ra,296(sp)
    80005740:	7412                	ld	s0,288(sp)
    80005742:	64f2                	ld	s1,280(sp)
    80005744:	6952                	ld	s2,272(sp)
    80005746:	6155                	addi	sp,sp,304
    80005748:	8082                	ret

000000008000574a <sys_unlink>:
{
    8000574a:	7151                	addi	sp,sp,-240
    8000574c:	f586                	sd	ra,232(sp)
    8000574e:	f1a2                	sd	s0,224(sp)
    80005750:	eda6                	sd	s1,216(sp)
    80005752:	e9ca                	sd	s2,208(sp)
    80005754:	e5ce                	sd	s3,200(sp)
    80005756:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005758:	08000613          	li	a2,128
    8000575c:	f3040593          	addi	a1,s0,-208
    80005760:	4501                	li	a0,0
    80005762:	ffffd097          	auipc	ra,0xffffd
    80005766:	692080e7          	jalr	1682(ra) # 80002df4 <argstr>
    8000576a:	18054163          	bltz	a0,800058ec <sys_unlink+0x1a2>
  begin_op();
    8000576e:	fffff097          	auipc	ra,0xfffff
    80005772:	b6e080e7          	jalr	-1170(ra) # 800042dc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005776:	fb040593          	addi	a1,s0,-80
    8000577a:	f3040513          	addi	a0,s0,-208
    8000577e:	fffff097          	auipc	ra,0xfffff
    80005782:	970080e7          	jalr	-1680(ra) # 800040ee <nameiparent>
    80005786:	84aa                	mv	s1,a0
    80005788:	c979                	beqz	a0,8000585e <sys_unlink+0x114>
  ilock(dp);
    8000578a:	ffffe097          	auipc	ra,0xffffe
    8000578e:	196080e7          	jalr	406(ra) # 80003920 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005792:	00003597          	auipc	a1,0x3
    80005796:	fee58593          	addi	a1,a1,-18 # 80008780 <syscalls+0x2c0>
    8000579a:	fb040513          	addi	a0,s0,-80
    8000579e:	ffffe097          	auipc	ra,0xffffe
    800057a2:	646080e7          	jalr	1606(ra) # 80003de4 <namecmp>
    800057a6:	14050a63          	beqz	a0,800058fa <sys_unlink+0x1b0>
    800057aa:	00003597          	auipc	a1,0x3
    800057ae:	a0e58593          	addi	a1,a1,-1522 # 800081b8 <digits+0x188>
    800057b2:	fb040513          	addi	a0,s0,-80
    800057b6:	ffffe097          	auipc	ra,0xffffe
    800057ba:	62e080e7          	jalr	1582(ra) # 80003de4 <namecmp>
    800057be:	12050e63          	beqz	a0,800058fa <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057c2:	f2c40613          	addi	a2,s0,-212
    800057c6:	fb040593          	addi	a1,s0,-80
    800057ca:	8526                	mv	a0,s1
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	632080e7          	jalr	1586(ra) # 80003dfe <dirlookup>
    800057d4:	892a                	mv	s2,a0
    800057d6:	12050263          	beqz	a0,800058fa <sys_unlink+0x1b0>
  ilock(ip);
    800057da:	ffffe097          	auipc	ra,0xffffe
    800057de:	146080e7          	jalr	326(ra) # 80003920 <ilock>
  if(ip->nlink < 1)
    800057e2:	04a91783          	lh	a5,74(s2)
    800057e6:	08f05263          	blez	a5,8000586a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057ea:	04491703          	lh	a4,68(s2)
    800057ee:	4785                	li	a5,1
    800057f0:	08f70563          	beq	a4,a5,8000587a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057f4:	4641                	li	a2,16
    800057f6:	4581                	li	a1,0
    800057f8:	fc040513          	addi	a0,s0,-64
    800057fc:	ffffb097          	auipc	ra,0xffffb
    80005800:	4fe080e7          	jalr	1278(ra) # 80000cfa <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005804:	4741                	li	a4,16
    80005806:	f2c42683          	lw	a3,-212(s0)
    8000580a:	fc040613          	addi	a2,s0,-64
    8000580e:	4581                	li	a1,0
    80005810:	8526                	mv	a0,s1
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	4b8080e7          	jalr	1208(ra) # 80003cca <writei>
    8000581a:	47c1                	li	a5,16
    8000581c:	0af51563          	bne	a0,a5,800058c6 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005820:	04491703          	lh	a4,68(s2)
    80005824:	4785                	li	a5,1
    80005826:	0af70863          	beq	a4,a5,800058d6 <sys_unlink+0x18c>
  iunlockput(dp);
    8000582a:	8526                	mv	a0,s1
    8000582c:	ffffe097          	auipc	ra,0xffffe
    80005830:	356080e7          	jalr	854(ra) # 80003b82 <iunlockput>
  ip->nlink--;
    80005834:	04a95783          	lhu	a5,74(s2)
    80005838:	37fd                	addiw	a5,a5,-1
    8000583a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000583e:	854a                	mv	a0,s2
    80005840:	ffffe097          	auipc	ra,0xffffe
    80005844:	016080e7          	jalr	22(ra) # 80003856 <iupdate>
  iunlockput(ip);
    80005848:	854a                	mv	a0,s2
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	338080e7          	jalr	824(ra) # 80003b82 <iunlockput>
  end_op();
    80005852:	fffff097          	auipc	ra,0xfffff
    80005856:	b0a080e7          	jalr	-1270(ra) # 8000435c <end_op>
  return 0;
    8000585a:	4501                	li	a0,0
    8000585c:	a84d                	j	8000590e <sys_unlink+0x1c4>
    end_op();
    8000585e:	fffff097          	auipc	ra,0xfffff
    80005862:	afe080e7          	jalr	-1282(ra) # 8000435c <end_op>
    return -1;
    80005866:	557d                	li	a0,-1
    80005868:	a05d                	j	8000590e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000586a:	00003517          	auipc	a0,0x3
    8000586e:	f3e50513          	addi	a0,a0,-194 # 800087a8 <syscalls+0x2e8>
    80005872:	ffffb097          	auipc	ra,0xffffb
    80005876:	cd0080e7          	jalr	-816(ra) # 80000542 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000587a:	04c92703          	lw	a4,76(s2)
    8000587e:	02000793          	li	a5,32
    80005882:	f6e7f9e3          	bgeu	a5,a4,800057f4 <sys_unlink+0xaa>
    80005886:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000588a:	4741                	li	a4,16
    8000588c:	86ce                	mv	a3,s3
    8000588e:	f1840613          	addi	a2,s0,-232
    80005892:	4581                	li	a1,0
    80005894:	854a                	mv	a0,s2
    80005896:	ffffe097          	auipc	ra,0xffffe
    8000589a:	33e080e7          	jalr	830(ra) # 80003bd4 <readi>
    8000589e:	47c1                	li	a5,16
    800058a0:	00f51b63          	bne	a0,a5,800058b6 <sys_unlink+0x16c>
    if(de.inum != 0)
    800058a4:	f1845783          	lhu	a5,-232(s0)
    800058a8:	e7a1                	bnez	a5,800058f0 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058aa:	29c1                	addiw	s3,s3,16
    800058ac:	04c92783          	lw	a5,76(s2)
    800058b0:	fcf9ede3          	bltu	s3,a5,8000588a <sys_unlink+0x140>
    800058b4:	b781                	j	800057f4 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058b6:	00003517          	auipc	a0,0x3
    800058ba:	f0a50513          	addi	a0,a0,-246 # 800087c0 <syscalls+0x300>
    800058be:	ffffb097          	auipc	ra,0xffffb
    800058c2:	c84080e7          	jalr	-892(ra) # 80000542 <panic>
    panic("unlink: writei");
    800058c6:	00003517          	auipc	a0,0x3
    800058ca:	f1250513          	addi	a0,a0,-238 # 800087d8 <syscalls+0x318>
    800058ce:	ffffb097          	auipc	ra,0xffffb
    800058d2:	c74080e7          	jalr	-908(ra) # 80000542 <panic>
    dp->nlink--;
    800058d6:	04a4d783          	lhu	a5,74(s1)
    800058da:	37fd                	addiw	a5,a5,-1
    800058dc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058e0:	8526                	mv	a0,s1
    800058e2:	ffffe097          	auipc	ra,0xffffe
    800058e6:	f74080e7          	jalr	-140(ra) # 80003856 <iupdate>
    800058ea:	b781                	j	8000582a <sys_unlink+0xe0>
    return -1;
    800058ec:	557d                	li	a0,-1
    800058ee:	a005                	j	8000590e <sys_unlink+0x1c4>
    iunlockput(ip);
    800058f0:	854a                	mv	a0,s2
    800058f2:	ffffe097          	auipc	ra,0xffffe
    800058f6:	290080e7          	jalr	656(ra) # 80003b82 <iunlockput>
  iunlockput(dp);
    800058fa:	8526                	mv	a0,s1
    800058fc:	ffffe097          	auipc	ra,0xffffe
    80005900:	286080e7          	jalr	646(ra) # 80003b82 <iunlockput>
  end_op();
    80005904:	fffff097          	auipc	ra,0xfffff
    80005908:	a58080e7          	jalr	-1448(ra) # 8000435c <end_op>
  return -1;
    8000590c:	557d                	li	a0,-1
}
    8000590e:	70ae                	ld	ra,232(sp)
    80005910:	740e                	ld	s0,224(sp)
    80005912:	64ee                	ld	s1,216(sp)
    80005914:	694e                	ld	s2,208(sp)
    80005916:	69ae                	ld	s3,200(sp)
    80005918:	616d                	addi	sp,sp,240
    8000591a:	8082                	ret

000000008000591c <sys_open>:

uint64
sys_open(void)
{
    8000591c:	7131                	addi	sp,sp,-192
    8000591e:	fd06                	sd	ra,184(sp)
    80005920:	f922                	sd	s0,176(sp)
    80005922:	f526                	sd	s1,168(sp)
    80005924:	f14a                	sd	s2,160(sp)
    80005926:	ed4e                	sd	s3,152(sp)
    80005928:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000592a:	08000613          	li	a2,128
    8000592e:	f5040593          	addi	a1,s0,-176
    80005932:	4501                	li	a0,0
    80005934:	ffffd097          	auipc	ra,0xffffd
    80005938:	4c0080e7          	jalr	1216(ra) # 80002df4 <argstr>
    return -1;
    8000593c:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000593e:	0c054163          	bltz	a0,80005a00 <sys_open+0xe4>
    80005942:	f4c40593          	addi	a1,s0,-180
    80005946:	4505                	li	a0,1
    80005948:	ffffd097          	auipc	ra,0xffffd
    8000594c:	468080e7          	jalr	1128(ra) # 80002db0 <argint>
    80005950:	0a054863          	bltz	a0,80005a00 <sys_open+0xe4>

  begin_op();
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	988080e7          	jalr	-1656(ra) # 800042dc <begin_op>

  if(omode & O_CREATE){
    8000595c:	f4c42783          	lw	a5,-180(s0)
    80005960:	2007f793          	andi	a5,a5,512
    80005964:	cbdd                	beqz	a5,80005a1a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005966:	4681                	li	a3,0
    80005968:	4601                	li	a2,0
    8000596a:	4589                	li	a1,2
    8000596c:	f5040513          	addi	a0,s0,-176
    80005970:	00000097          	auipc	ra,0x0
    80005974:	974080e7          	jalr	-1676(ra) # 800052e4 <create>
    80005978:	892a                	mv	s2,a0
    if(ip == 0){
    8000597a:	c959                	beqz	a0,80005a10 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000597c:	04491703          	lh	a4,68(s2)
    80005980:	478d                	li	a5,3
    80005982:	00f71763          	bne	a4,a5,80005990 <sys_open+0x74>
    80005986:	04695703          	lhu	a4,70(s2)
    8000598a:	47a5                	li	a5,9
    8000598c:	0ce7ec63          	bltu	a5,a4,80005a64 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005990:	fffff097          	auipc	ra,0xfffff
    80005994:	d62080e7          	jalr	-670(ra) # 800046f2 <filealloc>
    80005998:	89aa                	mv	s3,a0
    8000599a:	10050263          	beqz	a0,80005a9e <sys_open+0x182>
    8000599e:	00000097          	auipc	ra,0x0
    800059a2:	904080e7          	jalr	-1788(ra) # 800052a2 <fdalloc>
    800059a6:	84aa                	mv	s1,a0
    800059a8:	0e054663          	bltz	a0,80005a94 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059ac:	04491703          	lh	a4,68(s2)
    800059b0:	478d                	li	a5,3
    800059b2:	0cf70463          	beq	a4,a5,80005a7a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059b6:	4789                	li	a5,2
    800059b8:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800059bc:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800059c0:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800059c4:	f4c42783          	lw	a5,-180(s0)
    800059c8:	0017c713          	xori	a4,a5,1
    800059cc:	8b05                	andi	a4,a4,1
    800059ce:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059d2:	0037f713          	andi	a4,a5,3
    800059d6:	00e03733          	snez	a4,a4
    800059da:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059de:	4007f793          	andi	a5,a5,1024
    800059e2:	c791                	beqz	a5,800059ee <sys_open+0xd2>
    800059e4:	04491703          	lh	a4,68(s2)
    800059e8:	4789                	li	a5,2
    800059ea:	08f70f63          	beq	a4,a5,80005a88 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800059ee:	854a                	mv	a0,s2
    800059f0:	ffffe097          	auipc	ra,0xffffe
    800059f4:	ff2080e7          	jalr	-14(ra) # 800039e2 <iunlock>
  end_op();
    800059f8:	fffff097          	auipc	ra,0xfffff
    800059fc:	964080e7          	jalr	-1692(ra) # 8000435c <end_op>

  return fd;
}
    80005a00:	8526                	mv	a0,s1
    80005a02:	70ea                	ld	ra,184(sp)
    80005a04:	744a                	ld	s0,176(sp)
    80005a06:	74aa                	ld	s1,168(sp)
    80005a08:	790a                	ld	s2,160(sp)
    80005a0a:	69ea                	ld	s3,152(sp)
    80005a0c:	6129                	addi	sp,sp,192
    80005a0e:	8082                	ret
      end_op();
    80005a10:	fffff097          	auipc	ra,0xfffff
    80005a14:	94c080e7          	jalr	-1716(ra) # 8000435c <end_op>
      return -1;
    80005a18:	b7e5                	j	80005a00 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a1a:	f5040513          	addi	a0,s0,-176
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	6b2080e7          	jalr	1714(ra) # 800040d0 <namei>
    80005a26:	892a                	mv	s2,a0
    80005a28:	c905                	beqz	a0,80005a58 <sys_open+0x13c>
    ilock(ip);
    80005a2a:	ffffe097          	auipc	ra,0xffffe
    80005a2e:	ef6080e7          	jalr	-266(ra) # 80003920 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a32:	04491703          	lh	a4,68(s2)
    80005a36:	4785                	li	a5,1
    80005a38:	f4f712e3          	bne	a4,a5,8000597c <sys_open+0x60>
    80005a3c:	f4c42783          	lw	a5,-180(s0)
    80005a40:	dba1                	beqz	a5,80005990 <sys_open+0x74>
      iunlockput(ip);
    80005a42:	854a                	mv	a0,s2
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	13e080e7          	jalr	318(ra) # 80003b82 <iunlockput>
      end_op();
    80005a4c:	fffff097          	auipc	ra,0xfffff
    80005a50:	910080e7          	jalr	-1776(ra) # 8000435c <end_op>
      return -1;
    80005a54:	54fd                	li	s1,-1
    80005a56:	b76d                	j	80005a00 <sys_open+0xe4>
      end_op();
    80005a58:	fffff097          	auipc	ra,0xfffff
    80005a5c:	904080e7          	jalr	-1788(ra) # 8000435c <end_op>
      return -1;
    80005a60:	54fd                	li	s1,-1
    80005a62:	bf79                	j	80005a00 <sys_open+0xe4>
    iunlockput(ip);
    80005a64:	854a                	mv	a0,s2
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	11c080e7          	jalr	284(ra) # 80003b82 <iunlockput>
    end_op();
    80005a6e:	fffff097          	auipc	ra,0xfffff
    80005a72:	8ee080e7          	jalr	-1810(ra) # 8000435c <end_op>
    return -1;
    80005a76:	54fd                	li	s1,-1
    80005a78:	b761                	j	80005a00 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a7a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a7e:	04691783          	lh	a5,70(s2)
    80005a82:	02f99223          	sh	a5,36(s3)
    80005a86:	bf2d                	j	800059c0 <sys_open+0xa4>
    itrunc(ip);
    80005a88:	854a                	mv	a0,s2
    80005a8a:	ffffe097          	auipc	ra,0xffffe
    80005a8e:	fa4080e7          	jalr	-92(ra) # 80003a2e <itrunc>
    80005a92:	bfb1                	j	800059ee <sys_open+0xd2>
      fileclose(f);
    80005a94:	854e                	mv	a0,s3
    80005a96:	fffff097          	auipc	ra,0xfffff
    80005a9a:	d18080e7          	jalr	-744(ra) # 800047ae <fileclose>
    iunlockput(ip);
    80005a9e:	854a                	mv	a0,s2
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	0e2080e7          	jalr	226(ra) # 80003b82 <iunlockput>
    end_op();
    80005aa8:	fffff097          	auipc	ra,0xfffff
    80005aac:	8b4080e7          	jalr	-1868(ra) # 8000435c <end_op>
    return -1;
    80005ab0:	54fd                	li	s1,-1
    80005ab2:	b7b9                	j	80005a00 <sys_open+0xe4>

0000000080005ab4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ab4:	7175                	addi	sp,sp,-144
    80005ab6:	e506                	sd	ra,136(sp)
    80005ab8:	e122                	sd	s0,128(sp)
    80005aba:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005abc:	fffff097          	auipc	ra,0xfffff
    80005ac0:	820080e7          	jalr	-2016(ra) # 800042dc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ac4:	08000613          	li	a2,128
    80005ac8:	f7040593          	addi	a1,s0,-144
    80005acc:	4501                	li	a0,0
    80005ace:	ffffd097          	auipc	ra,0xffffd
    80005ad2:	326080e7          	jalr	806(ra) # 80002df4 <argstr>
    80005ad6:	02054963          	bltz	a0,80005b08 <sys_mkdir+0x54>
    80005ada:	4681                	li	a3,0
    80005adc:	4601                	li	a2,0
    80005ade:	4585                	li	a1,1
    80005ae0:	f7040513          	addi	a0,s0,-144
    80005ae4:	00000097          	auipc	ra,0x0
    80005ae8:	800080e7          	jalr	-2048(ra) # 800052e4 <create>
    80005aec:	cd11                	beqz	a0,80005b08 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005aee:	ffffe097          	auipc	ra,0xffffe
    80005af2:	094080e7          	jalr	148(ra) # 80003b82 <iunlockput>
  end_op();
    80005af6:	fffff097          	auipc	ra,0xfffff
    80005afa:	866080e7          	jalr	-1946(ra) # 8000435c <end_op>
  return 0;
    80005afe:	4501                	li	a0,0
}
    80005b00:	60aa                	ld	ra,136(sp)
    80005b02:	640a                	ld	s0,128(sp)
    80005b04:	6149                	addi	sp,sp,144
    80005b06:	8082                	ret
    end_op();
    80005b08:	fffff097          	auipc	ra,0xfffff
    80005b0c:	854080e7          	jalr	-1964(ra) # 8000435c <end_op>
    return -1;
    80005b10:	557d                	li	a0,-1
    80005b12:	b7fd                	j	80005b00 <sys_mkdir+0x4c>

0000000080005b14 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b14:	7135                	addi	sp,sp,-160
    80005b16:	ed06                	sd	ra,152(sp)
    80005b18:	e922                	sd	s0,144(sp)
    80005b1a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b1c:	ffffe097          	auipc	ra,0xffffe
    80005b20:	7c0080e7          	jalr	1984(ra) # 800042dc <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b24:	08000613          	li	a2,128
    80005b28:	f7040593          	addi	a1,s0,-144
    80005b2c:	4501                	li	a0,0
    80005b2e:	ffffd097          	auipc	ra,0xffffd
    80005b32:	2c6080e7          	jalr	710(ra) # 80002df4 <argstr>
    80005b36:	04054a63          	bltz	a0,80005b8a <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005b3a:	f6c40593          	addi	a1,s0,-148
    80005b3e:	4505                	li	a0,1
    80005b40:	ffffd097          	auipc	ra,0xffffd
    80005b44:	270080e7          	jalr	624(ra) # 80002db0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b48:	04054163          	bltz	a0,80005b8a <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005b4c:	f6840593          	addi	a1,s0,-152
    80005b50:	4509                	li	a0,2
    80005b52:	ffffd097          	auipc	ra,0xffffd
    80005b56:	25e080e7          	jalr	606(ra) # 80002db0 <argint>
     argint(1, &major) < 0 ||
    80005b5a:	02054863          	bltz	a0,80005b8a <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b5e:	f6841683          	lh	a3,-152(s0)
    80005b62:	f6c41603          	lh	a2,-148(s0)
    80005b66:	458d                	li	a1,3
    80005b68:	f7040513          	addi	a0,s0,-144
    80005b6c:	fffff097          	auipc	ra,0xfffff
    80005b70:	778080e7          	jalr	1912(ra) # 800052e4 <create>
     argint(2, &minor) < 0 ||
    80005b74:	c919                	beqz	a0,80005b8a <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b76:	ffffe097          	auipc	ra,0xffffe
    80005b7a:	00c080e7          	jalr	12(ra) # 80003b82 <iunlockput>
  end_op();
    80005b7e:	ffffe097          	auipc	ra,0xffffe
    80005b82:	7de080e7          	jalr	2014(ra) # 8000435c <end_op>
  return 0;
    80005b86:	4501                	li	a0,0
    80005b88:	a031                	j	80005b94 <sys_mknod+0x80>
    end_op();
    80005b8a:	ffffe097          	auipc	ra,0xffffe
    80005b8e:	7d2080e7          	jalr	2002(ra) # 8000435c <end_op>
    return -1;
    80005b92:	557d                	li	a0,-1
}
    80005b94:	60ea                	ld	ra,152(sp)
    80005b96:	644a                	ld	s0,144(sp)
    80005b98:	610d                	addi	sp,sp,160
    80005b9a:	8082                	ret

0000000080005b9c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b9c:	7135                	addi	sp,sp,-160
    80005b9e:	ed06                	sd	ra,152(sp)
    80005ba0:	e922                	sd	s0,144(sp)
    80005ba2:	e526                	sd	s1,136(sp)
    80005ba4:	e14a                	sd	s2,128(sp)
    80005ba6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ba8:	ffffc097          	auipc	ra,0xffffc
    80005bac:	fa8080e7          	jalr	-88(ra) # 80001b50 <myproc>
    80005bb0:	892a                	mv	s2,a0
  
  begin_op();
    80005bb2:	ffffe097          	auipc	ra,0xffffe
    80005bb6:	72a080e7          	jalr	1834(ra) # 800042dc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bba:	08000613          	li	a2,128
    80005bbe:	f6040593          	addi	a1,s0,-160
    80005bc2:	4501                	li	a0,0
    80005bc4:	ffffd097          	auipc	ra,0xffffd
    80005bc8:	230080e7          	jalr	560(ra) # 80002df4 <argstr>
    80005bcc:	04054b63          	bltz	a0,80005c22 <sys_chdir+0x86>
    80005bd0:	f6040513          	addi	a0,s0,-160
    80005bd4:	ffffe097          	auipc	ra,0xffffe
    80005bd8:	4fc080e7          	jalr	1276(ra) # 800040d0 <namei>
    80005bdc:	84aa                	mv	s1,a0
    80005bde:	c131                	beqz	a0,80005c22 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005be0:	ffffe097          	auipc	ra,0xffffe
    80005be4:	d40080e7          	jalr	-704(ra) # 80003920 <ilock>
  if(ip->type != T_DIR){
    80005be8:	04449703          	lh	a4,68(s1)
    80005bec:	4785                	li	a5,1
    80005bee:	04f71063          	bne	a4,a5,80005c2e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005bf2:	8526                	mv	a0,s1
    80005bf4:	ffffe097          	auipc	ra,0xffffe
    80005bf8:	dee080e7          	jalr	-530(ra) # 800039e2 <iunlock>
  iput(p->cwd);
    80005bfc:	15093503          	ld	a0,336(s2)
    80005c00:	ffffe097          	auipc	ra,0xffffe
    80005c04:	eda080e7          	jalr	-294(ra) # 80003ada <iput>
  end_op();
    80005c08:	ffffe097          	auipc	ra,0xffffe
    80005c0c:	754080e7          	jalr	1876(ra) # 8000435c <end_op>
  p->cwd = ip;
    80005c10:	14993823          	sd	s1,336(s2)
  return 0;
    80005c14:	4501                	li	a0,0
}
    80005c16:	60ea                	ld	ra,152(sp)
    80005c18:	644a                	ld	s0,144(sp)
    80005c1a:	64aa                	ld	s1,136(sp)
    80005c1c:	690a                	ld	s2,128(sp)
    80005c1e:	610d                	addi	sp,sp,160
    80005c20:	8082                	ret
    end_op();
    80005c22:	ffffe097          	auipc	ra,0xffffe
    80005c26:	73a080e7          	jalr	1850(ra) # 8000435c <end_op>
    return -1;
    80005c2a:	557d                	li	a0,-1
    80005c2c:	b7ed                	j	80005c16 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c2e:	8526                	mv	a0,s1
    80005c30:	ffffe097          	auipc	ra,0xffffe
    80005c34:	f52080e7          	jalr	-174(ra) # 80003b82 <iunlockput>
    end_op();
    80005c38:	ffffe097          	auipc	ra,0xffffe
    80005c3c:	724080e7          	jalr	1828(ra) # 8000435c <end_op>
    return -1;
    80005c40:	557d                	li	a0,-1
    80005c42:	bfd1                	j	80005c16 <sys_chdir+0x7a>

0000000080005c44 <sys_exec>:

uint64
sys_exec(void)
{
    80005c44:	7145                	addi	sp,sp,-464
    80005c46:	e786                	sd	ra,456(sp)
    80005c48:	e3a2                	sd	s0,448(sp)
    80005c4a:	ff26                	sd	s1,440(sp)
    80005c4c:	fb4a                	sd	s2,432(sp)
    80005c4e:	f74e                	sd	s3,424(sp)
    80005c50:	f352                	sd	s4,416(sp)
    80005c52:	ef56                	sd	s5,408(sp)
    80005c54:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c56:	08000613          	li	a2,128
    80005c5a:	f4040593          	addi	a1,s0,-192
    80005c5e:	4501                	li	a0,0
    80005c60:	ffffd097          	auipc	ra,0xffffd
    80005c64:	194080e7          	jalr	404(ra) # 80002df4 <argstr>
    return -1;
    80005c68:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c6a:	0c054a63          	bltz	a0,80005d3e <sys_exec+0xfa>
    80005c6e:	e3840593          	addi	a1,s0,-456
    80005c72:	4505                	li	a0,1
    80005c74:	ffffd097          	auipc	ra,0xffffd
    80005c78:	15e080e7          	jalr	350(ra) # 80002dd2 <argaddr>
    80005c7c:	0c054163          	bltz	a0,80005d3e <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c80:	10000613          	li	a2,256
    80005c84:	4581                	li	a1,0
    80005c86:	e4040513          	addi	a0,s0,-448
    80005c8a:	ffffb097          	auipc	ra,0xffffb
    80005c8e:	070080e7          	jalr	112(ra) # 80000cfa <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c92:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c96:	89a6                	mv	s3,s1
    80005c98:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c9a:	02000a13          	li	s4,32
    80005c9e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ca2:	00391793          	slli	a5,s2,0x3
    80005ca6:	e3040593          	addi	a1,s0,-464
    80005caa:	e3843503          	ld	a0,-456(s0)
    80005cae:	953e                	add	a0,a0,a5
    80005cb0:	ffffd097          	auipc	ra,0xffffd
    80005cb4:	066080e7          	jalr	102(ra) # 80002d16 <fetchaddr>
    80005cb8:	02054a63          	bltz	a0,80005cec <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005cbc:	e3043783          	ld	a5,-464(s0)
    80005cc0:	c3b9                	beqz	a5,80005d06 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005cc2:	ffffb097          	auipc	ra,0xffffb
    80005cc6:	e4c080e7          	jalr	-436(ra) # 80000b0e <kalloc>
    80005cca:	85aa                	mv	a1,a0
    80005ccc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005cd0:	cd11                	beqz	a0,80005cec <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cd2:	6605                	lui	a2,0x1
    80005cd4:	e3043503          	ld	a0,-464(s0)
    80005cd8:	ffffd097          	auipc	ra,0xffffd
    80005cdc:	090080e7          	jalr	144(ra) # 80002d68 <fetchstr>
    80005ce0:	00054663          	bltz	a0,80005cec <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005ce4:	0905                	addi	s2,s2,1
    80005ce6:	09a1                	addi	s3,s3,8
    80005ce8:	fb491be3          	bne	s2,s4,80005c9e <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cec:	10048913          	addi	s2,s1,256
    80005cf0:	6088                	ld	a0,0(s1)
    80005cf2:	c529                	beqz	a0,80005d3c <sys_exec+0xf8>
    kfree(argv[i]);
    80005cf4:	ffffb097          	auipc	ra,0xffffb
    80005cf8:	d1e080e7          	jalr	-738(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cfc:	04a1                	addi	s1,s1,8
    80005cfe:	ff2499e3          	bne	s1,s2,80005cf0 <sys_exec+0xac>
  return -1;
    80005d02:	597d                	li	s2,-1
    80005d04:	a82d                	j	80005d3e <sys_exec+0xfa>
      argv[i] = 0;
    80005d06:	0a8e                	slli	s5,s5,0x3
    80005d08:	fc040793          	addi	a5,s0,-64
    80005d0c:	9abe                	add	s5,s5,a5
    80005d0e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d12:	e4040593          	addi	a1,s0,-448
    80005d16:	f4040513          	addi	a0,s0,-192
    80005d1a:	fffff097          	auipc	ra,0xfffff
    80005d1e:	11a080e7          	jalr	282(ra) # 80004e34 <exec>
    80005d22:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d24:	10048993          	addi	s3,s1,256
    80005d28:	6088                	ld	a0,0(s1)
    80005d2a:	c911                	beqz	a0,80005d3e <sys_exec+0xfa>
    kfree(argv[i]);
    80005d2c:	ffffb097          	auipc	ra,0xffffb
    80005d30:	ce6080e7          	jalr	-794(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d34:	04a1                	addi	s1,s1,8
    80005d36:	ff3499e3          	bne	s1,s3,80005d28 <sys_exec+0xe4>
    80005d3a:	a011                	j	80005d3e <sys_exec+0xfa>
  return -1;
    80005d3c:	597d                	li	s2,-1
}
    80005d3e:	854a                	mv	a0,s2
    80005d40:	60be                	ld	ra,456(sp)
    80005d42:	641e                	ld	s0,448(sp)
    80005d44:	74fa                	ld	s1,440(sp)
    80005d46:	795a                	ld	s2,432(sp)
    80005d48:	79ba                	ld	s3,424(sp)
    80005d4a:	7a1a                	ld	s4,416(sp)
    80005d4c:	6afa                	ld	s5,408(sp)
    80005d4e:	6179                	addi	sp,sp,464
    80005d50:	8082                	ret

0000000080005d52 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d52:	7139                	addi	sp,sp,-64
    80005d54:	fc06                	sd	ra,56(sp)
    80005d56:	f822                	sd	s0,48(sp)
    80005d58:	f426                	sd	s1,40(sp)
    80005d5a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d5c:	ffffc097          	auipc	ra,0xffffc
    80005d60:	df4080e7          	jalr	-524(ra) # 80001b50 <myproc>
    80005d64:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d66:	fd840593          	addi	a1,s0,-40
    80005d6a:	4501                	li	a0,0
    80005d6c:	ffffd097          	auipc	ra,0xffffd
    80005d70:	066080e7          	jalr	102(ra) # 80002dd2 <argaddr>
    return -1;
    80005d74:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d76:	0e054063          	bltz	a0,80005e56 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d7a:	fc840593          	addi	a1,s0,-56
    80005d7e:	fd040513          	addi	a0,s0,-48
    80005d82:	fffff097          	auipc	ra,0xfffff
    80005d86:	d82080e7          	jalr	-638(ra) # 80004b04 <pipealloc>
    return -1;
    80005d8a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d8c:	0c054563          	bltz	a0,80005e56 <sys_pipe+0x104>
  fd0 = -1;
    80005d90:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d94:	fd043503          	ld	a0,-48(s0)
    80005d98:	fffff097          	auipc	ra,0xfffff
    80005d9c:	50a080e7          	jalr	1290(ra) # 800052a2 <fdalloc>
    80005da0:	fca42223          	sw	a0,-60(s0)
    80005da4:	08054c63          	bltz	a0,80005e3c <sys_pipe+0xea>
    80005da8:	fc843503          	ld	a0,-56(s0)
    80005dac:	fffff097          	auipc	ra,0xfffff
    80005db0:	4f6080e7          	jalr	1270(ra) # 800052a2 <fdalloc>
    80005db4:	fca42023          	sw	a0,-64(s0)
    80005db8:	06054863          	bltz	a0,80005e28 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dbc:	4691                	li	a3,4
    80005dbe:	fc440613          	addi	a2,s0,-60
    80005dc2:	fd843583          	ld	a1,-40(s0)
    80005dc6:	68a8                	ld	a0,80(s1)
    80005dc8:	ffffc097          	auipc	ra,0xffffc
    80005dcc:	906080e7          	jalr	-1786(ra) # 800016ce <copyout>
    80005dd0:	02054063          	bltz	a0,80005df0 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005dd4:	4691                	li	a3,4
    80005dd6:	fc040613          	addi	a2,s0,-64
    80005dda:	fd843583          	ld	a1,-40(s0)
    80005dde:	0591                	addi	a1,a1,4
    80005de0:	68a8                	ld	a0,80(s1)
    80005de2:	ffffc097          	auipc	ra,0xffffc
    80005de6:	8ec080e7          	jalr	-1812(ra) # 800016ce <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005dea:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dec:	06055563          	bgez	a0,80005e56 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005df0:	fc442783          	lw	a5,-60(s0)
    80005df4:	07e9                	addi	a5,a5,26
    80005df6:	078e                	slli	a5,a5,0x3
    80005df8:	97a6                	add	a5,a5,s1
    80005dfa:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005dfe:	fc042503          	lw	a0,-64(s0)
    80005e02:	0569                	addi	a0,a0,26
    80005e04:	050e                	slli	a0,a0,0x3
    80005e06:	9526                	add	a0,a0,s1
    80005e08:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005e0c:	fd043503          	ld	a0,-48(s0)
    80005e10:	fffff097          	auipc	ra,0xfffff
    80005e14:	99e080e7          	jalr	-1634(ra) # 800047ae <fileclose>
    fileclose(wf);
    80005e18:	fc843503          	ld	a0,-56(s0)
    80005e1c:	fffff097          	auipc	ra,0xfffff
    80005e20:	992080e7          	jalr	-1646(ra) # 800047ae <fileclose>
    return -1;
    80005e24:	57fd                	li	a5,-1
    80005e26:	a805                	j	80005e56 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005e28:	fc442783          	lw	a5,-60(s0)
    80005e2c:	0007c863          	bltz	a5,80005e3c <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005e30:	01a78513          	addi	a0,a5,26
    80005e34:	050e                	slli	a0,a0,0x3
    80005e36:	9526                	add	a0,a0,s1
    80005e38:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005e3c:	fd043503          	ld	a0,-48(s0)
    80005e40:	fffff097          	auipc	ra,0xfffff
    80005e44:	96e080e7          	jalr	-1682(ra) # 800047ae <fileclose>
    fileclose(wf);
    80005e48:	fc843503          	ld	a0,-56(s0)
    80005e4c:	fffff097          	auipc	ra,0xfffff
    80005e50:	962080e7          	jalr	-1694(ra) # 800047ae <fileclose>
    return -1;
    80005e54:	57fd                	li	a5,-1
}
    80005e56:	853e                	mv	a0,a5
    80005e58:	70e2                	ld	ra,56(sp)
    80005e5a:	7442                	ld	s0,48(sp)
    80005e5c:	74a2                	ld	s1,40(sp)
    80005e5e:	6121                	addi	sp,sp,64
    80005e60:	8082                	ret
	...

0000000080005e70 <kernelvec>:
    80005e70:	7111                	addi	sp,sp,-256
    80005e72:	e006                	sd	ra,0(sp)
    80005e74:	e40a                	sd	sp,8(sp)
    80005e76:	e80e                	sd	gp,16(sp)
    80005e78:	ec12                	sd	tp,24(sp)
    80005e7a:	f016                	sd	t0,32(sp)
    80005e7c:	f41a                	sd	t1,40(sp)
    80005e7e:	f81e                	sd	t2,48(sp)
    80005e80:	fc22                	sd	s0,56(sp)
    80005e82:	e0a6                	sd	s1,64(sp)
    80005e84:	e4aa                	sd	a0,72(sp)
    80005e86:	e8ae                	sd	a1,80(sp)
    80005e88:	ecb2                	sd	a2,88(sp)
    80005e8a:	f0b6                	sd	a3,96(sp)
    80005e8c:	f4ba                	sd	a4,104(sp)
    80005e8e:	f8be                	sd	a5,112(sp)
    80005e90:	fcc2                	sd	a6,120(sp)
    80005e92:	e146                	sd	a7,128(sp)
    80005e94:	e54a                	sd	s2,136(sp)
    80005e96:	e94e                	sd	s3,144(sp)
    80005e98:	ed52                	sd	s4,152(sp)
    80005e9a:	f156                	sd	s5,160(sp)
    80005e9c:	f55a                	sd	s6,168(sp)
    80005e9e:	f95e                	sd	s7,176(sp)
    80005ea0:	fd62                	sd	s8,184(sp)
    80005ea2:	e1e6                	sd	s9,192(sp)
    80005ea4:	e5ea                	sd	s10,200(sp)
    80005ea6:	e9ee                	sd	s11,208(sp)
    80005ea8:	edf2                	sd	t3,216(sp)
    80005eaa:	f1f6                	sd	t4,224(sp)
    80005eac:	f5fa                	sd	t5,232(sp)
    80005eae:	f9fe                	sd	t6,240(sp)
    80005eb0:	d33fc0ef          	jal	ra,80002be2 <kerneltrap>
    80005eb4:	6082                	ld	ra,0(sp)
    80005eb6:	6122                	ld	sp,8(sp)
    80005eb8:	61c2                	ld	gp,16(sp)
    80005eba:	7282                	ld	t0,32(sp)
    80005ebc:	7322                	ld	t1,40(sp)
    80005ebe:	73c2                	ld	t2,48(sp)
    80005ec0:	7462                	ld	s0,56(sp)
    80005ec2:	6486                	ld	s1,64(sp)
    80005ec4:	6526                	ld	a0,72(sp)
    80005ec6:	65c6                	ld	a1,80(sp)
    80005ec8:	6666                	ld	a2,88(sp)
    80005eca:	7686                	ld	a3,96(sp)
    80005ecc:	7726                	ld	a4,104(sp)
    80005ece:	77c6                	ld	a5,112(sp)
    80005ed0:	7866                	ld	a6,120(sp)
    80005ed2:	688a                	ld	a7,128(sp)
    80005ed4:	692a                	ld	s2,136(sp)
    80005ed6:	69ca                	ld	s3,144(sp)
    80005ed8:	6a6a                	ld	s4,152(sp)
    80005eda:	7a8a                	ld	s5,160(sp)
    80005edc:	7b2a                	ld	s6,168(sp)
    80005ede:	7bca                	ld	s7,176(sp)
    80005ee0:	7c6a                	ld	s8,184(sp)
    80005ee2:	6c8e                	ld	s9,192(sp)
    80005ee4:	6d2e                	ld	s10,200(sp)
    80005ee6:	6dce                	ld	s11,208(sp)
    80005ee8:	6e6e                	ld	t3,216(sp)
    80005eea:	7e8e                	ld	t4,224(sp)
    80005eec:	7f2e                	ld	t5,232(sp)
    80005eee:	7fce                	ld	t6,240(sp)
    80005ef0:	6111                	addi	sp,sp,256
    80005ef2:	10200073          	sret
    80005ef6:	00000013          	nop
    80005efa:	00000013          	nop
    80005efe:	0001                	nop

0000000080005f00 <timervec>:
    80005f00:	34051573          	csrrw	a0,mscratch,a0
    80005f04:	e10c                	sd	a1,0(a0)
    80005f06:	e510                	sd	a2,8(a0)
    80005f08:	e914                	sd	a3,16(a0)
    80005f0a:	710c                	ld	a1,32(a0)
    80005f0c:	7510                	ld	a2,40(a0)
    80005f0e:	6194                	ld	a3,0(a1)
    80005f10:	96b2                	add	a3,a3,a2
    80005f12:	e194                	sd	a3,0(a1)
    80005f14:	4589                	li	a1,2
    80005f16:	14459073          	csrw	sip,a1
    80005f1a:	6914                	ld	a3,16(a0)
    80005f1c:	6510                	ld	a2,8(a0)
    80005f1e:	610c                	ld	a1,0(a0)
    80005f20:	34051573          	csrrw	a0,mscratch,a0
    80005f24:	30200073          	mret
	...

0000000080005f2a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f2a:	1141                	addi	sp,sp,-16
    80005f2c:	e422                	sd	s0,8(sp)
    80005f2e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f30:	0c0007b7          	lui	a5,0xc000
    80005f34:	4705                	li	a4,1
    80005f36:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f38:	c3d8                	sw	a4,4(a5)
}
    80005f3a:	6422                	ld	s0,8(sp)
    80005f3c:	0141                	addi	sp,sp,16
    80005f3e:	8082                	ret

0000000080005f40 <plicinithart>:

void
plicinithart(void)
{
    80005f40:	1141                	addi	sp,sp,-16
    80005f42:	e406                	sd	ra,8(sp)
    80005f44:	e022                	sd	s0,0(sp)
    80005f46:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f48:	ffffc097          	auipc	ra,0xffffc
    80005f4c:	bdc080e7          	jalr	-1060(ra) # 80001b24 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f50:	0085171b          	slliw	a4,a0,0x8
    80005f54:	0c0027b7          	lui	a5,0xc002
    80005f58:	97ba                	add	a5,a5,a4
    80005f5a:	40200713          	li	a4,1026
    80005f5e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f62:	00d5151b          	slliw	a0,a0,0xd
    80005f66:	0c2017b7          	lui	a5,0xc201
    80005f6a:	953e                	add	a0,a0,a5
    80005f6c:	00052023          	sw	zero,0(a0)
}
    80005f70:	60a2                	ld	ra,8(sp)
    80005f72:	6402                	ld	s0,0(sp)
    80005f74:	0141                	addi	sp,sp,16
    80005f76:	8082                	ret

0000000080005f78 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f78:	1141                	addi	sp,sp,-16
    80005f7a:	e406                	sd	ra,8(sp)
    80005f7c:	e022                	sd	s0,0(sp)
    80005f7e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f80:	ffffc097          	auipc	ra,0xffffc
    80005f84:	ba4080e7          	jalr	-1116(ra) # 80001b24 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f88:	00d5179b          	slliw	a5,a0,0xd
    80005f8c:	0c201537          	lui	a0,0xc201
    80005f90:	953e                	add	a0,a0,a5
  return irq;
}
    80005f92:	4148                	lw	a0,4(a0)
    80005f94:	60a2                	ld	ra,8(sp)
    80005f96:	6402                	ld	s0,0(sp)
    80005f98:	0141                	addi	sp,sp,16
    80005f9a:	8082                	ret

0000000080005f9c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f9c:	1101                	addi	sp,sp,-32
    80005f9e:	ec06                	sd	ra,24(sp)
    80005fa0:	e822                	sd	s0,16(sp)
    80005fa2:	e426                	sd	s1,8(sp)
    80005fa4:	1000                	addi	s0,sp,32
    80005fa6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fa8:	ffffc097          	auipc	ra,0xffffc
    80005fac:	b7c080e7          	jalr	-1156(ra) # 80001b24 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fb0:	00d5151b          	slliw	a0,a0,0xd
    80005fb4:	0c2017b7          	lui	a5,0xc201
    80005fb8:	97aa                	add	a5,a5,a0
    80005fba:	c3c4                	sw	s1,4(a5)
}
    80005fbc:	60e2                	ld	ra,24(sp)
    80005fbe:	6442                	ld	s0,16(sp)
    80005fc0:	64a2                	ld	s1,8(sp)
    80005fc2:	6105                	addi	sp,sp,32
    80005fc4:	8082                	ret

0000000080005fc6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005fc6:	1141                	addi	sp,sp,-16
    80005fc8:	e406                	sd	ra,8(sp)
    80005fca:	e022                	sd	s0,0(sp)
    80005fcc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005fce:	479d                	li	a5,7
    80005fd0:	04a7cc63          	blt	a5,a0,80006028 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005fd4:	0001d797          	auipc	a5,0x1d
    80005fd8:	02c78793          	addi	a5,a5,44 # 80023000 <disk>
    80005fdc:	00a78733          	add	a4,a5,a0
    80005fe0:	6789                	lui	a5,0x2
    80005fe2:	97ba                	add	a5,a5,a4
    80005fe4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005fe8:	eba1                	bnez	a5,80006038 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005fea:	00451713          	slli	a4,a0,0x4
    80005fee:	0001f797          	auipc	a5,0x1f
    80005ff2:	0127b783          	ld	a5,18(a5) # 80025000 <disk+0x2000>
    80005ff6:	97ba                	add	a5,a5,a4
    80005ff8:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005ffc:	0001d797          	auipc	a5,0x1d
    80006000:	00478793          	addi	a5,a5,4 # 80023000 <disk>
    80006004:	97aa                	add	a5,a5,a0
    80006006:	6509                	lui	a0,0x2
    80006008:	953e                	add	a0,a0,a5
    8000600a:	4785                	li	a5,1
    8000600c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006010:	0001f517          	auipc	a0,0x1f
    80006014:	00850513          	addi	a0,a0,8 # 80025018 <disk+0x2018>
    80006018:	ffffc097          	auipc	ra,0xffffc
    8000601c:	672080e7          	jalr	1650(ra) # 8000268a <wakeup>
}
    80006020:	60a2                	ld	ra,8(sp)
    80006022:	6402                	ld	s0,0(sp)
    80006024:	0141                	addi	sp,sp,16
    80006026:	8082                	ret
    panic("virtio_disk_intr 1");
    80006028:	00002517          	auipc	a0,0x2
    8000602c:	7c050513          	addi	a0,a0,1984 # 800087e8 <syscalls+0x328>
    80006030:	ffffa097          	auipc	ra,0xffffa
    80006034:	512080e7          	jalr	1298(ra) # 80000542 <panic>
    panic("virtio_disk_intr 2");
    80006038:	00002517          	auipc	a0,0x2
    8000603c:	7c850513          	addi	a0,a0,1992 # 80008800 <syscalls+0x340>
    80006040:	ffffa097          	auipc	ra,0xffffa
    80006044:	502080e7          	jalr	1282(ra) # 80000542 <panic>

0000000080006048 <virtio_disk_init>:
{
    80006048:	1101                	addi	sp,sp,-32
    8000604a:	ec06                	sd	ra,24(sp)
    8000604c:	e822                	sd	s0,16(sp)
    8000604e:	e426                	sd	s1,8(sp)
    80006050:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006052:	00002597          	auipc	a1,0x2
    80006056:	7c658593          	addi	a1,a1,1990 # 80008818 <syscalls+0x358>
    8000605a:	0001f517          	auipc	a0,0x1f
    8000605e:	04e50513          	addi	a0,a0,78 # 800250a8 <disk+0x20a8>
    80006062:	ffffb097          	auipc	ra,0xffffb
    80006066:	b0c080e7          	jalr	-1268(ra) # 80000b6e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000606a:	100017b7          	lui	a5,0x10001
    8000606e:	4398                	lw	a4,0(a5)
    80006070:	2701                	sext.w	a4,a4
    80006072:	747277b7          	lui	a5,0x74727
    80006076:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000607a:	0ef71163          	bne	a4,a5,8000615c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000607e:	100017b7          	lui	a5,0x10001
    80006082:	43dc                	lw	a5,4(a5)
    80006084:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006086:	4705                	li	a4,1
    80006088:	0ce79a63          	bne	a5,a4,8000615c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000608c:	100017b7          	lui	a5,0x10001
    80006090:	479c                	lw	a5,8(a5)
    80006092:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006094:	4709                	li	a4,2
    80006096:	0ce79363          	bne	a5,a4,8000615c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000609a:	100017b7          	lui	a5,0x10001
    8000609e:	47d8                	lw	a4,12(a5)
    800060a0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060a2:	554d47b7          	lui	a5,0x554d4
    800060a6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060aa:	0af71963          	bne	a4,a5,8000615c <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ae:	100017b7          	lui	a5,0x10001
    800060b2:	4705                	li	a4,1
    800060b4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060b6:	470d                	li	a4,3
    800060b8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060ba:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800060bc:	c7ffe737          	lui	a4,0xc7ffe
    800060c0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd773f>
    800060c4:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060c6:	2701                	sext.w	a4,a4
    800060c8:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ca:	472d                	li	a4,11
    800060cc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ce:	473d                	li	a4,15
    800060d0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800060d2:	6705                	lui	a4,0x1
    800060d4:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060d6:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060da:	5bdc                	lw	a5,52(a5)
    800060dc:	2781                	sext.w	a5,a5
  if(max == 0)
    800060de:	c7d9                	beqz	a5,8000616c <virtio_disk_init+0x124>
  if(max < NUM)
    800060e0:	471d                	li	a4,7
    800060e2:	08f77d63          	bgeu	a4,a5,8000617c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800060e6:	100014b7          	lui	s1,0x10001
    800060ea:	47a1                	li	a5,8
    800060ec:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800060ee:	6609                	lui	a2,0x2
    800060f0:	4581                	li	a1,0
    800060f2:	0001d517          	auipc	a0,0x1d
    800060f6:	f0e50513          	addi	a0,a0,-242 # 80023000 <disk>
    800060fa:	ffffb097          	auipc	ra,0xffffb
    800060fe:	c00080e7          	jalr	-1024(ra) # 80000cfa <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006102:	0001d717          	auipc	a4,0x1d
    80006106:	efe70713          	addi	a4,a4,-258 # 80023000 <disk>
    8000610a:	00c75793          	srli	a5,a4,0xc
    8000610e:	2781                	sext.w	a5,a5
    80006110:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80006112:	0001f797          	auipc	a5,0x1f
    80006116:	eee78793          	addi	a5,a5,-274 # 80025000 <disk+0x2000>
    8000611a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    8000611c:	0001d717          	auipc	a4,0x1d
    80006120:	f6470713          	addi	a4,a4,-156 # 80023080 <disk+0x80>
    80006124:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80006126:	0001e717          	auipc	a4,0x1e
    8000612a:	eda70713          	addi	a4,a4,-294 # 80024000 <disk+0x1000>
    8000612e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006130:	4705                	li	a4,1
    80006132:	00e78c23          	sb	a4,24(a5)
    80006136:	00e78ca3          	sb	a4,25(a5)
    8000613a:	00e78d23          	sb	a4,26(a5)
    8000613e:	00e78da3          	sb	a4,27(a5)
    80006142:	00e78e23          	sb	a4,28(a5)
    80006146:	00e78ea3          	sb	a4,29(a5)
    8000614a:	00e78f23          	sb	a4,30(a5)
    8000614e:	00e78fa3          	sb	a4,31(a5)
}
    80006152:	60e2                	ld	ra,24(sp)
    80006154:	6442                	ld	s0,16(sp)
    80006156:	64a2                	ld	s1,8(sp)
    80006158:	6105                	addi	sp,sp,32
    8000615a:	8082                	ret
    panic("could not find virtio disk");
    8000615c:	00002517          	auipc	a0,0x2
    80006160:	6cc50513          	addi	a0,a0,1740 # 80008828 <syscalls+0x368>
    80006164:	ffffa097          	auipc	ra,0xffffa
    80006168:	3de080e7          	jalr	990(ra) # 80000542 <panic>
    panic("virtio disk has no queue 0");
    8000616c:	00002517          	auipc	a0,0x2
    80006170:	6dc50513          	addi	a0,a0,1756 # 80008848 <syscalls+0x388>
    80006174:	ffffa097          	auipc	ra,0xffffa
    80006178:	3ce080e7          	jalr	974(ra) # 80000542 <panic>
    panic("virtio disk max queue too short");
    8000617c:	00002517          	auipc	a0,0x2
    80006180:	6ec50513          	addi	a0,a0,1772 # 80008868 <syscalls+0x3a8>
    80006184:	ffffa097          	auipc	ra,0xffffa
    80006188:	3be080e7          	jalr	958(ra) # 80000542 <panic>

000000008000618c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000618c:	7175                	addi	sp,sp,-144
    8000618e:	e506                	sd	ra,136(sp)
    80006190:	e122                	sd	s0,128(sp)
    80006192:	fca6                	sd	s1,120(sp)
    80006194:	f8ca                	sd	s2,112(sp)
    80006196:	f4ce                	sd	s3,104(sp)
    80006198:	f0d2                	sd	s4,96(sp)
    8000619a:	ecd6                	sd	s5,88(sp)
    8000619c:	e8da                	sd	s6,80(sp)
    8000619e:	e4de                	sd	s7,72(sp)
    800061a0:	e0e2                	sd	s8,64(sp)
    800061a2:	fc66                	sd	s9,56(sp)
    800061a4:	f86a                	sd	s10,48(sp)
    800061a6:	f46e                	sd	s11,40(sp)
    800061a8:	0900                	addi	s0,sp,144
    800061aa:	8aaa                	mv	s5,a0
    800061ac:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061ae:	00c52c83          	lw	s9,12(a0)
    800061b2:	001c9c9b          	slliw	s9,s9,0x1
    800061b6:	1c82                	slli	s9,s9,0x20
    800061b8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800061bc:	0001f517          	auipc	a0,0x1f
    800061c0:	eec50513          	addi	a0,a0,-276 # 800250a8 <disk+0x20a8>
    800061c4:	ffffb097          	auipc	ra,0xffffb
    800061c8:	a3a080e7          	jalr	-1478(ra) # 80000bfe <acquire>
  for(int i = 0; i < 3; i++){
    800061cc:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800061ce:	44a1                	li	s1,8
      disk.free[i] = 0;
    800061d0:	0001dc17          	auipc	s8,0x1d
    800061d4:	e30c0c13          	addi	s8,s8,-464 # 80023000 <disk>
    800061d8:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    800061da:	4b0d                	li	s6,3
    800061dc:	a0ad                	j	80006246 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800061de:	00fc0733          	add	a4,s8,a5
    800061e2:	975e                	add	a4,a4,s7
    800061e4:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800061e8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800061ea:	0207c563          	bltz	a5,80006214 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800061ee:	2905                	addiw	s2,s2,1
    800061f0:	0611                	addi	a2,a2,4
    800061f2:	19690d63          	beq	s2,s6,8000638c <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    800061f6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800061f8:	0001f717          	auipc	a4,0x1f
    800061fc:	e2070713          	addi	a4,a4,-480 # 80025018 <disk+0x2018>
    80006200:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006202:	00074683          	lbu	a3,0(a4)
    80006206:	fee1                	bnez	a3,800061de <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006208:	2785                	addiw	a5,a5,1
    8000620a:	0705                	addi	a4,a4,1
    8000620c:	fe979be3          	bne	a5,s1,80006202 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006210:	57fd                	li	a5,-1
    80006212:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006214:	01205d63          	blez	s2,8000622e <virtio_disk_rw+0xa2>
    80006218:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    8000621a:	000a2503          	lw	a0,0(s4)
    8000621e:	00000097          	auipc	ra,0x0
    80006222:	da8080e7          	jalr	-600(ra) # 80005fc6 <free_desc>
      for(int j = 0; j < i; j++)
    80006226:	2d85                	addiw	s11,s11,1
    80006228:	0a11                	addi	s4,s4,4
    8000622a:	ffb918e3          	bne	s2,s11,8000621a <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000622e:	0001f597          	auipc	a1,0x1f
    80006232:	e7a58593          	addi	a1,a1,-390 # 800250a8 <disk+0x20a8>
    80006236:	0001f517          	auipc	a0,0x1f
    8000623a:	de250513          	addi	a0,a0,-542 # 80025018 <disk+0x2018>
    8000623e:	ffffc097          	auipc	ra,0xffffc
    80006242:	2cc080e7          	jalr	716(ra) # 8000250a <sleep>
  for(int i = 0; i < 3; i++){
    80006246:	f8040a13          	addi	s4,s0,-128
{
    8000624a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000624c:	894e                	mv	s2,s3
    8000624e:	b765                	j	800061f6 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006250:	0001f717          	auipc	a4,0x1f
    80006254:	db073703          	ld	a4,-592(a4) # 80025000 <disk+0x2000>
    80006258:	973e                	add	a4,a4,a5
    8000625a:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000625e:	0001d517          	auipc	a0,0x1d
    80006262:	da250513          	addi	a0,a0,-606 # 80023000 <disk>
    80006266:	0001f717          	auipc	a4,0x1f
    8000626a:	d9a70713          	addi	a4,a4,-614 # 80025000 <disk+0x2000>
    8000626e:	6314                	ld	a3,0(a4)
    80006270:	96be                	add	a3,a3,a5
    80006272:	00c6d603          	lhu	a2,12(a3)
    80006276:	00166613          	ori	a2,a2,1
    8000627a:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000627e:	f8842683          	lw	a3,-120(s0)
    80006282:	6310                	ld	a2,0(a4)
    80006284:	97b2                	add	a5,a5,a2
    80006286:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    8000628a:	20048613          	addi	a2,s1,512 # 10001200 <_entry-0x6fffee00>
    8000628e:	0612                	slli	a2,a2,0x4
    80006290:	962a                	add	a2,a2,a0
    80006292:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006296:	00469793          	slli	a5,a3,0x4
    8000629a:	630c                	ld	a1,0(a4)
    8000629c:	95be                	add	a1,a1,a5
    8000629e:	6689                	lui	a3,0x2
    800062a0:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    800062a4:	96ca                	add	a3,a3,s2
    800062a6:	96aa                	add	a3,a3,a0
    800062a8:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    800062aa:	6314                	ld	a3,0(a4)
    800062ac:	96be                	add	a3,a3,a5
    800062ae:	4585                	li	a1,1
    800062b0:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062b2:	6314                	ld	a3,0(a4)
    800062b4:	96be                	add	a3,a3,a5
    800062b6:	4509                	li	a0,2
    800062b8:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    800062bc:	6314                	ld	a3,0(a4)
    800062be:	97b6                	add	a5,a5,a3
    800062c0:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062c4:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800062c8:	03563423          	sd	s5,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    800062cc:	6714                	ld	a3,8(a4)
    800062ce:	0026d783          	lhu	a5,2(a3)
    800062d2:	8b9d                	andi	a5,a5,7
    800062d4:	0789                	addi	a5,a5,2
    800062d6:	0786                	slli	a5,a5,0x1
    800062d8:	97b6                	add	a5,a5,a3
    800062da:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    800062de:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800062e2:	6718                	ld	a4,8(a4)
    800062e4:	00275783          	lhu	a5,2(a4)
    800062e8:	2785                	addiw	a5,a5,1
    800062ea:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800062ee:	100017b7          	lui	a5,0x10001
    800062f2:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800062f6:	004aa783          	lw	a5,4(s5)
    800062fa:	02b79163          	bne	a5,a1,8000631c <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800062fe:	0001f917          	auipc	s2,0x1f
    80006302:	daa90913          	addi	s2,s2,-598 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006306:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006308:	85ca                	mv	a1,s2
    8000630a:	8556                	mv	a0,s5
    8000630c:	ffffc097          	auipc	ra,0xffffc
    80006310:	1fe080e7          	jalr	510(ra) # 8000250a <sleep>
  while(b->disk == 1) {
    80006314:	004aa783          	lw	a5,4(s5)
    80006318:	fe9788e3          	beq	a5,s1,80006308 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    8000631c:	f8042483          	lw	s1,-128(s0)
    80006320:	20048793          	addi	a5,s1,512
    80006324:	00479713          	slli	a4,a5,0x4
    80006328:	0001d797          	auipc	a5,0x1d
    8000632c:	cd878793          	addi	a5,a5,-808 # 80023000 <disk>
    80006330:	97ba                	add	a5,a5,a4
    80006332:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006336:	0001f917          	auipc	s2,0x1f
    8000633a:	cca90913          	addi	s2,s2,-822 # 80025000 <disk+0x2000>
    8000633e:	a019                	j	80006344 <virtio_disk_rw+0x1b8>
      i = disk.desc[i].next;
    80006340:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    80006344:	8526                	mv	a0,s1
    80006346:	00000097          	auipc	ra,0x0
    8000634a:	c80080e7          	jalr	-896(ra) # 80005fc6 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    8000634e:	0492                	slli	s1,s1,0x4
    80006350:	00093783          	ld	a5,0(s2)
    80006354:	94be                	add	s1,s1,a5
    80006356:	00c4d783          	lhu	a5,12(s1)
    8000635a:	8b85                	andi	a5,a5,1
    8000635c:	f3f5                	bnez	a5,80006340 <virtio_disk_rw+0x1b4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000635e:	0001f517          	auipc	a0,0x1f
    80006362:	d4a50513          	addi	a0,a0,-694 # 800250a8 <disk+0x20a8>
    80006366:	ffffb097          	auipc	ra,0xffffb
    8000636a:	94c080e7          	jalr	-1716(ra) # 80000cb2 <release>
}
    8000636e:	60aa                	ld	ra,136(sp)
    80006370:	640a                	ld	s0,128(sp)
    80006372:	74e6                	ld	s1,120(sp)
    80006374:	7946                	ld	s2,112(sp)
    80006376:	79a6                	ld	s3,104(sp)
    80006378:	7a06                	ld	s4,96(sp)
    8000637a:	6ae6                	ld	s5,88(sp)
    8000637c:	6b46                	ld	s6,80(sp)
    8000637e:	6ba6                	ld	s7,72(sp)
    80006380:	6c06                	ld	s8,64(sp)
    80006382:	7ce2                	ld	s9,56(sp)
    80006384:	7d42                	ld	s10,48(sp)
    80006386:	7da2                	ld	s11,40(sp)
    80006388:	6149                	addi	sp,sp,144
    8000638a:	8082                	ret
  if(write)
    8000638c:	01a037b3          	snez	a5,s10
    80006390:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006394:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006398:	f7943c23          	sd	s9,-136(s0)
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    8000639c:	f8042483          	lw	s1,-128(s0)
    800063a0:	00449913          	slli	s2,s1,0x4
    800063a4:	0001f997          	auipc	s3,0x1f
    800063a8:	c5c98993          	addi	s3,s3,-932 # 80025000 <disk+0x2000>
    800063ac:	0009ba03          	ld	s4,0(s3)
    800063b0:	9a4a                	add	s4,s4,s2
    800063b2:	f7040513          	addi	a0,s0,-144
    800063b6:	ffffb097          	auipc	ra,0xffffb
    800063ba:	d1c080e7          	jalr	-740(ra) # 800010d2 <kvmpa>
    800063be:	00aa3023          	sd	a0,0(s4)
  disk.desc[idx[0]].len = sizeof(buf0);
    800063c2:	0009b783          	ld	a5,0(s3)
    800063c6:	97ca                	add	a5,a5,s2
    800063c8:	4741                	li	a4,16
    800063ca:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063cc:	0009b783          	ld	a5,0(s3)
    800063d0:	97ca                	add	a5,a5,s2
    800063d2:	4705                	li	a4,1
    800063d4:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800063d8:	f8442783          	lw	a5,-124(s0)
    800063dc:	0009b703          	ld	a4,0(s3)
    800063e0:	974a                	add	a4,a4,s2
    800063e2:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    800063e6:	0792                	slli	a5,a5,0x4
    800063e8:	0009b703          	ld	a4,0(s3)
    800063ec:	973e                	add	a4,a4,a5
    800063ee:	058a8693          	addi	a3,s5,88
    800063f2:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    800063f4:	0009b703          	ld	a4,0(s3)
    800063f8:	973e                	add	a4,a4,a5
    800063fa:	40000693          	li	a3,1024
    800063fe:	c714                	sw	a3,8(a4)
  if(write)
    80006400:	e40d18e3          	bnez	s10,80006250 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006404:	0001f717          	auipc	a4,0x1f
    80006408:	bfc73703          	ld	a4,-1028(a4) # 80025000 <disk+0x2000>
    8000640c:	973e                	add	a4,a4,a5
    8000640e:	4689                	li	a3,2
    80006410:	00d71623          	sh	a3,12(a4)
    80006414:	b5a9                	j	8000625e <virtio_disk_rw+0xd2>

0000000080006416 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006416:	1101                	addi	sp,sp,-32
    80006418:	ec06                	sd	ra,24(sp)
    8000641a:	e822                	sd	s0,16(sp)
    8000641c:	e426                	sd	s1,8(sp)
    8000641e:	e04a                	sd	s2,0(sp)
    80006420:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006422:	0001f517          	auipc	a0,0x1f
    80006426:	c8650513          	addi	a0,a0,-890 # 800250a8 <disk+0x20a8>
    8000642a:	ffffa097          	auipc	ra,0xffffa
    8000642e:	7d4080e7          	jalr	2004(ra) # 80000bfe <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006432:	0001f717          	auipc	a4,0x1f
    80006436:	bce70713          	addi	a4,a4,-1074 # 80025000 <disk+0x2000>
    8000643a:	02075783          	lhu	a5,32(a4)
    8000643e:	6b18                	ld	a4,16(a4)
    80006440:	00275683          	lhu	a3,2(a4)
    80006444:	8ebd                	xor	a3,a3,a5
    80006446:	8a9d                	andi	a3,a3,7
    80006448:	cab9                	beqz	a3,8000649e <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000644a:	0001d917          	auipc	s2,0x1d
    8000644e:	bb690913          	addi	s2,s2,-1098 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006452:	0001f497          	auipc	s1,0x1f
    80006456:	bae48493          	addi	s1,s1,-1106 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    8000645a:	078e                	slli	a5,a5,0x3
    8000645c:	97ba                	add	a5,a5,a4
    8000645e:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006460:	20078713          	addi	a4,a5,512
    80006464:	0712                	slli	a4,a4,0x4
    80006466:	974a                	add	a4,a4,s2
    80006468:	03074703          	lbu	a4,48(a4)
    8000646c:	ef21                	bnez	a4,800064c4 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000646e:	20078793          	addi	a5,a5,512
    80006472:	0792                	slli	a5,a5,0x4
    80006474:	97ca                	add	a5,a5,s2
    80006476:	7798                	ld	a4,40(a5)
    80006478:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    8000647c:	7788                	ld	a0,40(a5)
    8000647e:	ffffc097          	auipc	ra,0xffffc
    80006482:	20c080e7          	jalr	524(ra) # 8000268a <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006486:	0204d783          	lhu	a5,32(s1)
    8000648a:	2785                	addiw	a5,a5,1
    8000648c:	8b9d                	andi	a5,a5,7
    8000648e:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006492:	6898                	ld	a4,16(s1)
    80006494:	00275683          	lhu	a3,2(a4)
    80006498:	8a9d                	andi	a3,a3,7
    8000649a:	fcf690e3          	bne	a3,a5,8000645a <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000649e:	10001737          	lui	a4,0x10001
    800064a2:	533c                	lw	a5,96(a4)
    800064a4:	8b8d                	andi	a5,a5,3
    800064a6:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    800064a8:	0001f517          	auipc	a0,0x1f
    800064ac:	c0050513          	addi	a0,a0,-1024 # 800250a8 <disk+0x20a8>
    800064b0:	ffffb097          	auipc	ra,0xffffb
    800064b4:	802080e7          	jalr	-2046(ra) # 80000cb2 <release>
}
    800064b8:	60e2                	ld	ra,24(sp)
    800064ba:	6442                	ld	s0,16(sp)
    800064bc:	64a2                	ld	s1,8(sp)
    800064be:	6902                	ld	s2,0(sp)
    800064c0:	6105                	addi	sp,sp,32
    800064c2:	8082                	ret
      panic("virtio_disk_intr status");
    800064c4:	00002517          	auipc	a0,0x2
    800064c8:	3c450513          	addi	a0,a0,964 # 80008888 <syscalls+0x3c8>
    800064cc:	ffffa097          	auipc	ra,0xffffa
    800064d0:	076080e7          	jalr	118(ra) # 80000542 <panic>

00000000800064d4 <statscopyin>:
  int ncopyin;
  int ncopyinstr;
} stats;

int
statscopyin(char *buf, int sz) {
    800064d4:	7179                	addi	sp,sp,-48
    800064d6:	f406                	sd	ra,40(sp)
    800064d8:	f022                	sd	s0,32(sp)
    800064da:	ec26                	sd	s1,24(sp)
    800064dc:	e84a                	sd	s2,16(sp)
    800064de:	e44e                	sd	s3,8(sp)
    800064e0:	e052                	sd	s4,0(sp)
    800064e2:	1800                	addi	s0,sp,48
    800064e4:	892a                	mv	s2,a0
    800064e6:	89ae                	mv	s3,a1
  int n;
  n = snprintf(buf, sz, "copyin: %d\n", stats.ncopyin);
    800064e8:	00003a17          	auipc	s4,0x3
    800064ec:	b40a0a13          	addi	s4,s4,-1216 # 80009028 <stats>
    800064f0:	000a2683          	lw	a3,0(s4)
    800064f4:	00002617          	auipc	a2,0x2
    800064f8:	3ac60613          	addi	a2,a2,940 # 800088a0 <syscalls+0x3e0>
    800064fc:	00000097          	auipc	ra,0x0
    80006500:	2c2080e7          	jalr	706(ra) # 800067be <snprintf>
    80006504:	84aa                	mv	s1,a0
  n += snprintf(buf+n, sz, "copyinstr: %d\n", stats.ncopyinstr);
    80006506:	004a2683          	lw	a3,4(s4)
    8000650a:	00002617          	auipc	a2,0x2
    8000650e:	3a660613          	addi	a2,a2,934 # 800088b0 <syscalls+0x3f0>
    80006512:	85ce                	mv	a1,s3
    80006514:	954a                	add	a0,a0,s2
    80006516:	00000097          	auipc	ra,0x0
    8000651a:	2a8080e7          	jalr	680(ra) # 800067be <snprintf>
  return n;
}
    8000651e:	9d25                	addw	a0,a0,s1
    80006520:	70a2                	ld	ra,40(sp)
    80006522:	7402                	ld	s0,32(sp)
    80006524:	64e2                	ld	s1,24(sp)
    80006526:	6942                	ld	s2,16(sp)
    80006528:	69a2                	ld	s3,8(sp)
    8000652a:	6a02                	ld	s4,0(sp)
    8000652c:	6145                	addi	sp,sp,48
    8000652e:	8082                	ret

0000000080006530 <copyin_new>:
// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin_new(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
    80006530:	7179                	addi	sp,sp,-48
    80006532:	f406                	sd	ra,40(sp)
    80006534:	f022                	sd	s0,32(sp)
    80006536:	ec26                	sd	s1,24(sp)
    80006538:	e84a                	sd	s2,16(sp)
    8000653a:	e44e                	sd	s3,8(sp)
    8000653c:	1800                	addi	s0,sp,48
    8000653e:	89ae                	mv	s3,a1
    80006540:	84b2                	mv	s1,a2
    80006542:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80006544:	ffffb097          	auipc	ra,0xffffb
    80006548:	60c080e7          	jalr	1548(ra) # 80001b50 <myproc>

  if (srcva >= p->sz || srcva+len >= p->sz || srcva+len < srcva)
    8000654c:	653c                	ld	a5,72(a0)
    8000654e:	02f4ff63          	bgeu	s1,a5,8000658c <copyin_new+0x5c>
    80006552:	01248733          	add	a4,s1,s2
    80006556:	02f77d63          	bgeu	a4,a5,80006590 <copyin_new+0x60>
    8000655a:	02976d63          	bltu	a4,s1,80006594 <copyin_new+0x64>
    return -1;
  memmove((void *) dst, (void *)srcva, len);
    8000655e:	0009061b          	sext.w	a2,s2
    80006562:	85a6                	mv	a1,s1
    80006564:	854e                	mv	a0,s3
    80006566:	ffffa097          	auipc	ra,0xffffa
    8000656a:	7f0080e7          	jalr	2032(ra) # 80000d56 <memmove>
  stats.ncopyin++;   // XXX lock
    8000656e:	00003717          	auipc	a4,0x3
    80006572:	aba70713          	addi	a4,a4,-1350 # 80009028 <stats>
    80006576:	431c                	lw	a5,0(a4)
    80006578:	2785                	addiw	a5,a5,1
    8000657a:	c31c                	sw	a5,0(a4)
  return 0;
    8000657c:	4501                	li	a0,0
}
    8000657e:	70a2                	ld	ra,40(sp)
    80006580:	7402                	ld	s0,32(sp)
    80006582:	64e2                	ld	s1,24(sp)
    80006584:	6942                	ld	s2,16(sp)
    80006586:	69a2                	ld	s3,8(sp)
    80006588:	6145                	addi	sp,sp,48
    8000658a:	8082                	ret
    return -1;
    8000658c:	557d                	li	a0,-1
    8000658e:	bfc5                	j	8000657e <copyin_new+0x4e>
    80006590:	557d                	li	a0,-1
    80006592:	b7f5                	j	8000657e <copyin_new+0x4e>
    80006594:	557d                	li	a0,-1
    80006596:	b7e5                	j	8000657e <copyin_new+0x4e>

0000000080006598 <copyinstr_new>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr_new(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    80006598:	7179                	addi	sp,sp,-48
    8000659a:	f406                	sd	ra,40(sp)
    8000659c:	f022                	sd	s0,32(sp)
    8000659e:	ec26                	sd	s1,24(sp)
    800065a0:	e84a                	sd	s2,16(sp)
    800065a2:	e44e                	sd	s3,8(sp)
    800065a4:	1800                	addi	s0,sp,48
    800065a6:	89ae                	mv	s3,a1
    800065a8:	8932                	mv	s2,a2
    800065aa:	84b6                	mv	s1,a3
  struct proc *p = myproc();
    800065ac:	ffffb097          	auipc	ra,0xffffb
    800065b0:	5a4080e7          	jalr	1444(ra) # 80001b50 <myproc>
  char *s = (char *) srcva;
  
  stats.ncopyinstr++;   // XXX lock
    800065b4:	00003717          	auipc	a4,0x3
    800065b8:	a7470713          	addi	a4,a4,-1420 # 80009028 <stats>
    800065bc:	435c                	lw	a5,4(a4)
    800065be:	2785                	addiw	a5,a5,1
    800065c0:	c35c                	sw	a5,4(a4)
  for(int i = 0; i < max && srcva + i < p->sz; i++){
    800065c2:	cc85                	beqz	s1,800065fa <copyinstr_new+0x62>
    800065c4:	00990833          	add	a6,s2,s1
    800065c8:	87ca                	mv	a5,s2
    800065ca:	6538                	ld	a4,72(a0)
    800065cc:	00e7ff63          	bgeu	a5,a4,800065ea <copyinstr_new+0x52>
    dst[i] = s[i];
    800065d0:	0007c683          	lbu	a3,0(a5)
    800065d4:	41278733          	sub	a4,a5,s2
    800065d8:	974e                	add	a4,a4,s3
    800065da:	00d70023          	sb	a3,0(a4)
    if(s[i] == '\0')
    800065de:	c285                	beqz	a3,800065fe <copyinstr_new+0x66>
  for(int i = 0; i < max && srcva + i < p->sz; i++){
    800065e0:	0785                	addi	a5,a5,1
    800065e2:	ff0794e3          	bne	a5,a6,800065ca <copyinstr_new+0x32>
      return 0;
  }
  return -1;
    800065e6:	557d                	li	a0,-1
    800065e8:	a011                	j	800065ec <copyinstr_new+0x54>
    800065ea:	557d                	li	a0,-1
}
    800065ec:	70a2                	ld	ra,40(sp)
    800065ee:	7402                	ld	s0,32(sp)
    800065f0:	64e2                	ld	s1,24(sp)
    800065f2:	6942                	ld	s2,16(sp)
    800065f4:	69a2                	ld	s3,8(sp)
    800065f6:	6145                	addi	sp,sp,48
    800065f8:	8082                	ret
  return -1;
    800065fa:	557d                	li	a0,-1
    800065fc:	bfc5                	j	800065ec <copyinstr_new+0x54>
      return 0;
    800065fe:	4501                	li	a0,0
    80006600:	b7f5                	j	800065ec <copyinstr_new+0x54>

0000000080006602 <statswrite>:
int statscopyin(char*, int);
int statslock(char*, int);
  
int
statswrite(int user_src, uint64 src, int n)
{
    80006602:	1141                	addi	sp,sp,-16
    80006604:	e422                	sd	s0,8(sp)
    80006606:	0800                	addi	s0,sp,16
  return -1;
}
    80006608:	557d                	li	a0,-1
    8000660a:	6422                	ld	s0,8(sp)
    8000660c:	0141                	addi	sp,sp,16
    8000660e:	8082                	ret

0000000080006610 <statsread>:

int
statsread(int user_dst, uint64 dst, int n)
{
    80006610:	7179                	addi	sp,sp,-48
    80006612:	f406                	sd	ra,40(sp)
    80006614:	f022                	sd	s0,32(sp)
    80006616:	ec26                	sd	s1,24(sp)
    80006618:	e84a                	sd	s2,16(sp)
    8000661a:	e44e                	sd	s3,8(sp)
    8000661c:	e052                	sd	s4,0(sp)
    8000661e:	1800                	addi	s0,sp,48
    80006620:	892a                	mv	s2,a0
    80006622:	89ae                	mv	s3,a1
    80006624:	84b2                	mv	s1,a2
  int m;

  acquire(&stats.lock);
    80006626:	00020517          	auipc	a0,0x20
    8000662a:	9da50513          	addi	a0,a0,-1574 # 80026000 <stats>
    8000662e:	ffffa097          	auipc	ra,0xffffa
    80006632:	5d0080e7          	jalr	1488(ra) # 80000bfe <acquire>

  if(stats.sz == 0) {
    80006636:	00021797          	auipc	a5,0x21
    8000663a:	9e27a783          	lw	a5,-1566(a5) # 80027018 <stats+0x1018>
    8000663e:	cbb5                	beqz	a5,800066b2 <statsread+0xa2>
#endif
#ifdef LAB_LOCK
    stats.sz = statslock(stats.buf, BUFSZ);
#endif
  }
  m = stats.sz - stats.off;
    80006640:	00021797          	auipc	a5,0x21
    80006644:	9c078793          	addi	a5,a5,-1600 # 80027000 <stats+0x1000>
    80006648:	4fd8                	lw	a4,28(a5)
    8000664a:	4f9c                	lw	a5,24(a5)
    8000664c:	9f99                	subw	a5,a5,a4
    8000664e:	0007869b          	sext.w	a3,a5

  if (m > 0) {
    80006652:	06d05e63          	blez	a3,800066ce <statsread+0xbe>
    if(m > n)
    80006656:	8a3e                	mv	s4,a5
    80006658:	00d4d363          	bge	s1,a3,8000665e <statsread+0x4e>
    8000665c:	8a26                	mv	s4,s1
    8000665e:	000a049b          	sext.w	s1,s4
      m  = n;
    if(either_copyout(user_dst, dst, stats.buf+stats.off, m) != -1) {
    80006662:	86a6                	mv	a3,s1
    80006664:	00020617          	auipc	a2,0x20
    80006668:	9b460613          	addi	a2,a2,-1612 # 80026018 <stats+0x18>
    8000666c:	963a                	add	a2,a2,a4
    8000666e:	85ce                	mv	a1,s3
    80006670:	854a                	mv	a0,s2
    80006672:	ffffc097          	auipc	ra,0xffffc
    80006676:	0f2080e7          	jalr	242(ra) # 80002764 <either_copyout>
    8000667a:	57fd                	li	a5,-1
    8000667c:	00f50a63          	beq	a0,a5,80006690 <statsread+0x80>
      stats.off += m;
    80006680:	00021717          	auipc	a4,0x21
    80006684:	98070713          	addi	a4,a4,-1664 # 80027000 <stats+0x1000>
    80006688:	4f5c                	lw	a5,28(a4)
    8000668a:	014787bb          	addw	a5,a5,s4
    8000668e:	cf5c                	sw	a5,28(a4)
  } else {
    m = -1;
    stats.sz = 0;
    stats.off = 0;
  }
  release(&stats.lock);
    80006690:	00020517          	auipc	a0,0x20
    80006694:	97050513          	addi	a0,a0,-1680 # 80026000 <stats>
    80006698:	ffffa097          	auipc	ra,0xffffa
    8000669c:	61a080e7          	jalr	1562(ra) # 80000cb2 <release>
  return m;
}
    800066a0:	8526                	mv	a0,s1
    800066a2:	70a2                	ld	ra,40(sp)
    800066a4:	7402                	ld	s0,32(sp)
    800066a6:	64e2                	ld	s1,24(sp)
    800066a8:	6942                	ld	s2,16(sp)
    800066aa:	69a2                	ld	s3,8(sp)
    800066ac:	6a02                	ld	s4,0(sp)
    800066ae:	6145                	addi	sp,sp,48
    800066b0:	8082                	ret
    stats.sz = statscopyin(stats.buf, BUFSZ);
    800066b2:	6585                	lui	a1,0x1
    800066b4:	00020517          	auipc	a0,0x20
    800066b8:	96450513          	addi	a0,a0,-1692 # 80026018 <stats+0x18>
    800066bc:	00000097          	auipc	ra,0x0
    800066c0:	e18080e7          	jalr	-488(ra) # 800064d4 <statscopyin>
    800066c4:	00021797          	auipc	a5,0x21
    800066c8:	94a7aa23          	sw	a0,-1708(a5) # 80027018 <stats+0x1018>
    800066cc:	bf95                	j	80006640 <statsread+0x30>
    stats.sz = 0;
    800066ce:	00021797          	auipc	a5,0x21
    800066d2:	93278793          	addi	a5,a5,-1742 # 80027000 <stats+0x1000>
    800066d6:	0007ac23          	sw	zero,24(a5)
    stats.off = 0;
    800066da:	0007ae23          	sw	zero,28(a5)
    m = -1;
    800066de:	54fd                	li	s1,-1
    800066e0:	bf45                	j	80006690 <statsread+0x80>

00000000800066e2 <statsinit>:

void
statsinit(void)
{
    800066e2:	1141                	addi	sp,sp,-16
    800066e4:	e406                	sd	ra,8(sp)
    800066e6:	e022                	sd	s0,0(sp)
    800066e8:	0800                	addi	s0,sp,16
  initlock(&stats.lock, "stats");
    800066ea:	00002597          	auipc	a1,0x2
    800066ee:	1d658593          	addi	a1,a1,470 # 800088c0 <syscalls+0x400>
    800066f2:	00020517          	auipc	a0,0x20
    800066f6:	90e50513          	addi	a0,a0,-1778 # 80026000 <stats>
    800066fa:	ffffa097          	auipc	ra,0xffffa
    800066fe:	474080e7          	jalr	1140(ra) # 80000b6e <initlock>

  devsw[STATS].read = statsread;
    80006702:	0001b797          	auipc	a5,0x1b
    80006706:	4ae78793          	addi	a5,a5,1198 # 80021bb0 <devsw>
    8000670a:	00000717          	auipc	a4,0x0
    8000670e:	f0670713          	addi	a4,a4,-250 # 80006610 <statsread>
    80006712:	f398                	sd	a4,32(a5)
  devsw[STATS].write = statswrite;
    80006714:	00000717          	auipc	a4,0x0
    80006718:	eee70713          	addi	a4,a4,-274 # 80006602 <statswrite>
    8000671c:	f798                	sd	a4,40(a5)
}
    8000671e:	60a2                	ld	ra,8(sp)
    80006720:	6402                	ld	s0,0(sp)
    80006722:	0141                	addi	sp,sp,16
    80006724:	8082                	ret

0000000080006726 <sprintint>:
  return 1;
}

static int
sprintint(char *s, int xx, int base, int sign)
{
    80006726:	1101                	addi	sp,sp,-32
    80006728:	ec22                	sd	s0,24(sp)
    8000672a:	1000                	addi	s0,sp,32
    8000672c:	882a                	mv	a6,a0
  char buf[16];
  int i, n;
  uint x;

  if(sign && (sign = xx < 0))
    8000672e:	c299                	beqz	a3,80006734 <sprintint+0xe>
    80006730:	0805c163          	bltz	a1,800067b2 <sprintint+0x8c>
    x = -xx;
  else
    x = xx;
    80006734:	2581                	sext.w	a1,a1
    80006736:	4301                	li	t1,0

  i = 0;
    80006738:	fe040713          	addi	a4,s0,-32
    8000673c:	4501                	li	a0,0
  do {
    buf[i++] = digits[x % base];
    8000673e:	2601                	sext.w	a2,a2
    80006740:	00002697          	auipc	a3,0x2
    80006744:	18868693          	addi	a3,a3,392 # 800088c8 <digits>
    80006748:	88aa                	mv	a7,a0
    8000674a:	2505                	addiw	a0,a0,1
    8000674c:	02c5f7bb          	remuw	a5,a1,a2
    80006750:	1782                	slli	a5,a5,0x20
    80006752:	9381                	srli	a5,a5,0x20
    80006754:	97b6                	add	a5,a5,a3
    80006756:	0007c783          	lbu	a5,0(a5)
    8000675a:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    8000675e:	0005879b          	sext.w	a5,a1
    80006762:	02c5d5bb          	divuw	a1,a1,a2
    80006766:	0705                	addi	a4,a4,1
    80006768:	fec7f0e3          	bgeu	a5,a2,80006748 <sprintint+0x22>

  if(sign)
    8000676c:	00030b63          	beqz	t1,80006782 <sprintint+0x5c>
    buf[i++] = '-';
    80006770:	ff040793          	addi	a5,s0,-16
    80006774:	97aa                	add	a5,a5,a0
    80006776:	02d00713          	li	a4,45
    8000677a:	fee78823          	sb	a4,-16(a5)
    8000677e:	0028851b          	addiw	a0,a7,2

  n = 0;
  while(--i >= 0)
    80006782:	02a05c63          	blez	a0,800067ba <sprintint+0x94>
    80006786:	fe040793          	addi	a5,s0,-32
    8000678a:	00a78733          	add	a4,a5,a0
    8000678e:	87c2                	mv	a5,a6
    80006790:	0805                	addi	a6,a6,1
    80006792:	fff5061b          	addiw	a2,a0,-1
    80006796:	1602                	slli	a2,a2,0x20
    80006798:	9201                	srli	a2,a2,0x20
    8000679a:	9642                	add	a2,a2,a6
  *s = c;
    8000679c:	fff74683          	lbu	a3,-1(a4)
    800067a0:	00d78023          	sb	a3,0(a5)
  while(--i >= 0)
    800067a4:	177d                	addi	a4,a4,-1
    800067a6:	0785                	addi	a5,a5,1
    800067a8:	fec79ae3          	bne	a5,a2,8000679c <sprintint+0x76>
    n += sputc(s+n, buf[i]);
  return n;
}
    800067ac:	6462                	ld	s0,24(sp)
    800067ae:	6105                	addi	sp,sp,32
    800067b0:	8082                	ret
    x = -xx;
    800067b2:	40b005bb          	negw	a1,a1
  if(sign && (sign = xx < 0))
    800067b6:	4305                	li	t1,1
    x = -xx;
    800067b8:	b741                	j	80006738 <sprintint+0x12>
  while(--i >= 0)
    800067ba:	4501                	li	a0,0
    800067bc:	bfc5                	j	800067ac <sprintint+0x86>

00000000800067be <snprintf>:

int
snprintf(char *buf, int sz, char *fmt, ...)
{
    800067be:	7135                	addi	sp,sp,-160
    800067c0:	f486                	sd	ra,104(sp)
    800067c2:	f0a2                	sd	s0,96(sp)
    800067c4:	eca6                	sd	s1,88(sp)
    800067c6:	e8ca                	sd	s2,80(sp)
    800067c8:	e4ce                	sd	s3,72(sp)
    800067ca:	e0d2                	sd	s4,64(sp)
    800067cc:	fc56                	sd	s5,56(sp)
    800067ce:	f85a                	sd	s6,48(sp)
    800067d0:	f45e                	sd	s7,40(sp)
    800067d2:	f062                	sd	s8,32(sp)
    800067d4:	ec66                	sd	s9,24(sp)
    800067d6:	e86a                	sd	s10,16(sp)
    800067d8:	1880                	addi	s0,sp,112
    800067da:	e414                	sd	a3,8(s0)
    800067dc:	e818                	sd	a4,16(s0)
    800067de:	ec1c                	sd	a5,24(s0)
    800067e0:	03043023          	sd	a6,32(s0)
    800067e4:	03143423          	sd	a7,40(s0)
  va_list ap;
  int i, c;
  int off = 0;
  char *s;

  if (fmt == 0)
    800067e8:	c61d                	beqz	a2,80006816 <snprintf+0x58>
    800067ea:	8baa                	mv	s7,a0
    800067ec:	89ae                	mv	s3,a1
    800067ee:	8a32                	mv	s4,a2
    panic("null fmt");

  va_start(ap, fmt);
    800067f0:	00840793          	addi	a5,s0,8
    800067f4:	f8f43c23          	sd	a5,-104(s0)
  int off = 0;
    800067f8:	4481                	li	s1,0
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    800067fa:	4901                	li	s2,0
    800067fc:	02b05563          	blez	a1,80006826 <snprintf+0x68>
    if(c != '%'){
    80006800:	02500a93          	li	s5,37
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    80006804:	07300b13          	li	s6,115
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
      break;
    case 's':
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s && off < sz; s++)
    80006808:	02800d13          	li	s10,40
    switch(c){
    8000680c:	07800c93          	li	s9,120
    80006810:	06400c13          	li	s8,100
    80006814:	a01d                	j	8000683a <snprintf+0x7c>
    panic("null fmt");
    80006816:	00002517          	auipc	a0,0x2
    8000681a:	80250513          	addi	a0,a0,-2046 # 80008018 <etext+0x18>
    8000681e:	ffffa097          	auipc	ra,0xffffa
    80006822:	d24080e7          	jalr	-732(ra) # 80000542 <panic>
  int off = 0;
    80006826:	4481                	li	s1,0
    80006828:	a86d                	j	800068e2 <snprintf+0x124>
  *s = c;
    8000682a:	009b8733          	add	a4,s7,s1
    8000682e:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    80006832:	2485                	addiw	s1,s1,1
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    80006834:	2905                	addiw	s2,s2,1
    80006836:	0b34d663          	bge	s1,s3,800068e2 <snprintf+0x124>
    8000683a:	012a07b3          	add	a5,s4,s2
    8000683e:	0007c783          	lbu	a5,0(a5)
    80006842:	0007871b          	sext.w	a4,a5
    80006846:	cfd1                	beqz	a5,800068e2 <snprintf+0x124>
    if(c != '%'){
    80006848:	ff5711e3          	bne	a4,s5,8000682a <snprintf+0x6c>
    c = fmt[++i] & 0xff;
    8000684c:	2905                	addiw	s2,s2,1
    8000684e:	012a07b3          	add	a5,s4,s2
    80006852:	0007c783          	lbu	a5,0(a5)
    if(c == 0)
    80006856:	c7d1                	beqz	a5,800068e2 <snprintf+0x124>
    switch(c){
    80006858:	05678c63          	beq	a5,s6,800068b0 <snprintf+0xf2>
    8000685c:	02fb6763          	bltu	s6,a5,8000688a <snprintf+0xcc>
    80006860:	0b578663          	beq	a5,s5,8000690c <snprintf+0x14e>
    80006864:	0b879a63          	bne	a5,s8,80006918 <snprintf+0x15a>
      off += sprintint(buf+off, va_arg(ap, int), 10, 1);
    80006868:	f9843783          	ld	a5,-104(s0)
    8000686c:	00878713          	addi	a4,a5,8
    80006870:	f8e43c23          	sd	a4,-104(s0)
    80006874:	4685                	li	a3,1
    80006876:	4629                	li	a2,10
    80006878:	438c                	lw	a1,0(a5)
    8000687a:	009b8533          	add	a0,s7,s1
    8000687e:	00000097          	auipc	ra,0x0
    80006882:	ea8080e7          	jalr	-344(ra) # 80006726 <sprintint>
    80006886:	9ca9                	addw	s1,s1,a0
      break;
    80006888:	b775                	j	80006834 <snprintf+0x76>
    switch(c){
    8000688a:	09979763          	bne	a5,s9,80006918 <snprintf+0x15a>
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
    8000688e:	f9843783          	ld	a5,-104(s0)
    80006892:	00878713          	addi	a4,a5,8
    80006896:	f8e43c23          	sd	a4,-104(s0)
    8000689a:	4685                	li	a3,1
    8000689c:	4641                	li	a2,16
    8000689e:	438c                	lw	a1,0(a5)
    800068a0:	009b8533          	add	a0,s7,s1
    800068a4:	00000097          	auipc	ra,0x0
    800068a8:	e82080e7          	jalr	-382(ra) # 80006726 <sprintint>
    800068ac:	9ca9                	addw	s1,s1,a0
      break;
    800068ae:	b759                	j	80006834 <snprintf+0x76>
      if((s = va_arg(ap, char*)) == 0)
    800068b0:	f9843783          	ld	a5,-104(s0)
    800068b4:	00878713          	addi	a4,a5,8
    800068b8:	f8e43c23          	sd	a4,-104(s0)
    800068bc:	639c                	ld	a5,0(a5)
    800068be:	c3a9                	beqz	a5,80006900 <snprintf+0x142>
      for(; *s && off < sz; s++)
    800068c0:	0007c703          	lbu	a4,0(a5)
    800068c4:	db25                	beqz	a4,80006834 <snprintf+0x76>
    800068c6:	0134de63          	bge	s1,s3,800068e2 <snprintf+0x124>
    800068ca:	009b86b3          	add	a3,s7,s1
  *s = c;
    800068ce:	00e68023          	sb	a4,0(a3)
        off += sputc(buf+off, *s);
    800068d2:	2485                	addiw	s1,s1,1
      for(; *s && off < sz; s++)
    800068d4:	0785                	addi	a5,a5,1
    800068d6:	0007c703          	lbu	a4,0(a5)
    800068da:	df29                	beqz	a4,80006834 <snprintf+0x76>
    800068dc:	0685                	addi	a3,a3,1
    800068de:	fe9998e3          	bne	s3,s1,800068ce <snprintf+0x110>
      off += sputc(buf+off, c);
      break;
    }
  }
  return off;
}
    800068e2:	8526                	mv	a0,s1
    800068e4:	70a6                	ld	ra,104(sp)
    800068e6:	7406                	ld	s0,96(sp)
    800068e8:	64e6                	ld	s1,88(sp)
    800068ea:	6946                	ld	s2,80(sp)
    800068ec:	69a6                	ld	s3,72(sp)
    800068ee:	6a06                	ld	s4,64(sp)
    800068f0:	7ae2                	ld	s5,56(sp)
    800068f2:	7b42                	ld	s6,48(sp)
    800068f4:	7ba2                	ld	s7,40(sp)
    800068f6:	7c02                	ld	s8,32(sp)
    800068f8:	6ce2                	ld	s9,24(sp)
    800068fa:	6d42                	ld	s10,16(sp)
    800068fc:	610d                	addi	sp,sp,160
    800068fe:	8082                	ret
        s = "(null)";
    80006900:	00001797          	auipc	a5,0x1
    80006904:	71078793          	addi	a5,a5,1808 # 80008010 <etext+0x10>
      for(; *s && off < sz; s++)
    80006908:	876a                	mv	a4,s10
    8000690a:	bf75                	j	800068c6 <snprintf+0x108>
  *s = c;
    8000690c:	009b87b3          	add	a5,s7,s1
    80006910:	01578023          	sb	s5,0(a5)
      off += sputc(buf+off, '%');
    80006914:	2485                	addiw	s1,s1,1
      break;
    80006916:	bf39                	j	80006834 <snprintf+0x76>
  *s = c;
    80006918:	009b8733          	add	a4,s7,s1
    8000691c:	01570023          	sb	s5,0(a4)
      off += sputc(buf+off, c);
    80006920:	0014871b          	addiw	a4,s1,1
  *s = c;
    80006924:	975e                	add	a4,a4,s7
    80006926:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    8000692a:	2489                	addiw	s1,s1,2
      break;
    8000692c:	b721                	j	80006834 <snprintf+0x76>
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
