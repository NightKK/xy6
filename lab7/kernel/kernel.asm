
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
    80000060:	d4478793          	addi	a5,a5,-700 # 80005da0 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
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
    8000012a:	432080e7          	jalr	1074(ra) # 80002558 <either_copyin>
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
    800001ce:	8ca080e7          	jalr	-1846(ra) # 80001a94 <myproc>
    800001d2:	591c                	lw	a5,48(a0)
    800001d4:	e7b5                	bnez	a5,80000240 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001d6:	85a6                	mv	a1,s1
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	0ce080e7          	jalr	206(ra) # 800022a8 <sleep>
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
    8000021a:	2ec080e7          	jalr	748(ra) # 80002502 <either_copyout>
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
    800002fa:	2b8080e7          	jalr	696(ra) # 800025ae <procdump>
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
    8000044e:	fde080e7          	jalr	-34(ra) # 80002428 <wakeup>
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
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	702080e7          	jalr	1794(ra) # 80000b6e <initlock>

  uartinit();
    80000474:	00000097          	auipc	ra,0x0
    80000478:	32a080e7          	jalr	810(ra) # 8000079e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047c:	00021797          	auipc	a5,0x21
    80000480:	53478793          	addi	a5,a5,1332 # 800219b0 <devsw>
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
    80000608:	5fa080e7          	jalr	1530(ra) # 80000bfe <acquire>
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
    80000782:	8ba58593          	addi	a1,a1,-1862 # 80008038 <etext+0x38>
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
    800007d2:	88a58593          	addi	a1,a1,-1910 # 80008058 <digits+0x18>
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
    800008a6:	b86080e7          	jalr	-1146(ra) # 80002428 <wakeup>
    
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
    80000940:	96c080e7          	jalr	-1684(ra) # 800022a8 <sleep>
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
    80000a26:	00025797          	auipc	a5,0x25
    80000a2a:	5da78793          	addi	a5,a5,1498 # 80026000 <end>
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
    80000a7c:	5e850513          	addi	a0,a0,1512 # 80008060 <digits+0x20>
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
    80000ade:	58e58593          	addi	a1,a1,1422 # 80008068 <digits+0x28>
    80000ae2:	00011517          	auipc	a0,0x11
    80000ae6:	e4e50513          	addi	a0,a0,-434 # 80011930 <kmem>
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	084080e7          	jalr	132(ra) # 80000b6e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000af2:	45c5                	li	a1,17
    80000af4:	05ee                	slli	a1,a1,0x1b
    80000af6:	00025517          	auipc	a0,0x25
    80000afa:	50a50513          	addi	a0,a0,1290 # 80026000 <end>
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
    80000b9c:	ee0080e7          	jalr	-288(ra) # 80001a78 <mycpu>
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
    80000bce:	eae080e7          	jalr	-338(ra) # 80001a78 <mycpu>
    80000bd2:	5d3c                	lw	a5,120(a0)
    80000bd4:	cf89                	beqz	a5,80000bee <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd6:	00001097          	auipc	ra,0x1
    80000bda:	ea2080e7          	jalr	-350(ra) # 80001a78 <mycpu>
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
    80000bf2:	e8a080e7          	jalr	-374(ra) # 80001a78 <mycpu>
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
    80000c32:	e4a080e7          	jalr	-438(ra) # 80001a78 <mycpu>
    80000c36:	e888                	sd	a0,16(s1)
}
    80000c38:	60e2                	ld	ra,24(sp)
    80000c3a:	6442                	ld	s0,16(sp)
    80000c3c:	64a2                	ld	s1,8(sp)
    80000c3e:	6105                	addi	sp,sp,32
    80000c40:	8082                	ret
    panic("acquire");
    80000c42:	00007517          	auipc	a0,0x7
    80000c46:	42e50513          	addi	a0,a0,1070 # 80008070 <digits+0x30>
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
    80000c5e:	e1e080e7          	jalr	-482(ra) # 80001a78 <mycpu>
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
    80000c96:	3e650513          	addi	a0,a0,998 # 80008078 <digits+0x38>
    80000c9a:	00000097          	auipc	ra,0x0
    80000c9e:	8a8080e7          	jalr	-1880(ra) # 80000542 <panic>
    panic("pop_off");
    80000ca2:	00007517          	auipc	a0,0x7
    80000ca6:	3ee50513          	addi	a0,a0,1006 # 80008090 <digits+0x50>
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
    80000cee:	3ae50513          	addi	a0,a0,942 # 80008098 <digits+0x58>
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
    80000eb4:	bb8080e7          	jalr	-1096(ra) # 80001a68 <cpuid>
    virtio_disk_init(); // emulated hard disk
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
    80000ed0:	b9c080e7          	jalr	-1124(ra) # 80001a68 <cpuid>
    80000ed4:	85aa                	mv	a1,a0
    80000ed6:	00007517          	auipc	a0,0x7
    80000eda:	1e250513          	addi	a0,a0,482 # 800080b8 <digits+0x78>
    80000ede:	fffff097          	auipc	ra,0xfffff
    80000ee2:	6ae080e7          	jalr	1710(ra) # 8000058c <printf>
    kvminithart();    // turn on paging
    80000ee6:	00000097          	auipc	ra,0x0
    80000eea:	0d8080e7          	jalr	216(ra) # 80000fbe <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eee:	00002097          	auipc	ra,0x2
    80000ef2:	800080e7          	jalr	-2048(ra) # 800026ee <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ef6:	00005097          	auipc	ra,0x5
    80000efa:	eea080e7          	jalr	-278(ra) # 80005de0 <plicinithart>
  }

  scheduler();        
    80000efe:	00001097          	auipc	ra,0x1
    80000f02:	0ca080e7          	jalr	202(ra) # 80001fc8 <scheduler>
    consoleinit();
    80000f06:	fffff097          	auipc	ra,0xfffff
    80000f0a:	54e080e7          	jalr	1358(ra) # 80000454 <consoleinit>
    printfinit();
    80000f0e:	00000097          	auipc	ra,0x0
    80000f12:	85e080e7          	jalr	-1954(ra) # 8000076c <printfinit>
    printf("\n");
    80000f16:	00007517          	auipc	a0,0x7
    80000f1a:	1b250513          	addi	a0,a0,434 # 800080c8 <digits+0x88>
    80000f1e:	fffff097          	auipc	ra,0xfffff
    80000f22:	66e080e7          	jalr	1646(ra) # 8000058c <printf>
    printf("xv6 kernel is booting\n");
    80000f26:	00007517          	auipc	a0,0x7
    80000f2a:	17a50513          	addi	a0,a0,378 # 800080a0 <digits+0x60>
    80000f2e:	fffff097          	auipc	ra,0xfffff
    80000f32:	65e080e7          	jalr	1630(ra) # 8000058c <printf>
    printf("\n");
    80000f36:	00007517          	auipc	a0,0x7
    80000f3a:	19250513          	addi	a0,a0,402 # 800080c8 <digits+0x88>
    80000f3e:	fffff097          	auipc	ra,0xfffff
    80000f42:	64e080e7          	jalr	1614(ra) # 8000058c <printf>
    kinit();         // physical page allocator
    80000f46:	00000097          	auipc	ra,0x0
    80000f4a:	b8c080e7          	jalr	-1140(ra) # 80000ad2 <kinit>
    kvminit();       // create kernel page table
    80000f4e:	00000097          	auipc	ra,0x0
    80000f52:	2a0080e7          	jalr	672(ra) # 800011ee <kvminit>
    kvminithart();   // turn on paging
    80000f56:	00000097          	auipc	ra,0x0
    80000f5a:	068080e7          	jalr	104(ra) # 80000fbe <kvminithart>
    procinit();      // process table
    80000f5e:	00001097          	auipc	ra,0x1
    80000f62:	a3a080e7          	jalr	-1478(ra) # 80001998 <procinit>
    trapinit();      // trap vectors
    80000f66:	00001097          	auipc	ra,0x1
    80000f6a:	760080e7          	jalr	1888(ra) # 800026c6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f6e:	00001097          	auipc	ra,0x1
    80000f72:	780080e7          	jalr	1920(ra) # 800026ee <trapinithart>
    plicinit();      // set up interrupt controller
    80000f76:	00005097          	auipc	ra,0x5
    80000f7a:	e54080e7          	jalr	-428(ra) # 80005dca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f7e:	00005097          	auipc	ra,0x5
    80000f82:	e62080e7          	jalr	-414(ra) # 80005de0 <plicinithart>
    binit();         // buffer cache
    80000f86:	00002097          	auipc	ra,0x2
    80000f8a:	ee2080e7          	jalr	-286(ra) # 80002e68 <binit>
    iinit();         // inode cache
    80000f8e:	00002097          	auipc	ra,0x2
    80000f92:	572080e7          	jalr	1394(ra) # 80003500 <iinit>
    fileinit();      // file table
    80000f96:	00003097          	auipc	ra,0x3
    80000f9a:	510080e7          	jalr	1296(ra) # 800044a6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f9e:	00005097          	auipc	ra,0x5
    80000fa2:	f4a080e7          	jalr	-182(ra) # 80005ee8 <virtio_disk_init>
    userinit();      // first user process
    80000fa6:	00001097          	auipc	ra,0x1
    80000faa:	db8080e7          	jalr	-584(ra) # 80001d5e <userinit>
    __sync_synchronize();
    80000fae:	0ff0000f          	fence
    started = 1;
    80000fb2:	4785                	li	a5,1
    80000fb4:	00008717          	auipc	a4,0x8
    80000fb8:	04f72c23          	sw	a5,88(a4) # 8000900c <started>
    80000fbc:	b789                	j	80000efe <main+0x56>

0000000080000fbe <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fbe:	1141                	addi	sp,sp,-16
    80000fc0:	e422                	sd	s0,8(sp)
    80000fc2:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fc4:	00008797          	auipc	a5,0x8
    80000fc8:	04c7b783          	ld	a5,76(a5) # 80009010 <kernel_pagetable>
    80000fcc:	83b1                	srli	a5,a5,0xc
    80000fce:	577d                	li	a4,-1
    80000fd0:	177e                	slli	a4,a4,0x3f
    80000fd2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fd4:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fd8:	12000073          	sfence.vma
  sfence_vma();
}
    80000fdc:	6422                	ld	s0,8(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret

0000000080000fe2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fe2:	7139                	addi	sp,sp,-64
    80000fe4:	fc06                	sd	ra,56(sp)
    80000fe6:	f822                	sd	s0,48(sp)
    80000fe8:	f426                	sd	s1,40(sp)
    80000fea:	f04a                	sd	s2,32(sp)
    80000fec:	ec4e                	sd	s3,24(sp)
    80000fee:	e852                	sd	s4,16(sp)
    80000ff0:	e456                	sd	s5,8(sp)
    80000ff2:	e05a                	sd	s6,0(sp)
    80000ff4:	0080                	addi	s0,sp,64
    80000ff6:	84aa                	mv	s1,a0
    80000ff8:	89ae                	mv	s3,a1
    80000ffa:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000ffc:	57fd                	li	a5,-1
    80000ffe:	83e9                	srli	a5,a5,0x1a
    80001000:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001002:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001004:	04b7f263          	bgeu	a5,a1,80001048 <walk+0x66>
    panic("walk");
    80001008:	00007517          	auipc	a0,0x7
    8000100c:	0c850513          	addi	a0,a0,200 # 800080d0 <digits+0x90>
    80001010:	fffff097          	auipc	ra,0xfffff
    80001014:	532080e7          	jalr	1330(ra) # 80000542 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001018:	060a8663          	beqz	s5,80001084 <walk+0xa2>
    8000101c:	00000097          	auipc	ra,0x0
    80001020:	af2080e7          	jalr	-1294(ra) # 80000b0e <kalloc>
    80001024:	84aa                	mv	s1,a0
    80001026:	c529                	beqz	a0,80001070 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001028:	6605                	lui	a2,0x1
    8000102a:	4581                	li	a1,0
    8000102c:	00000097          	auipc	ra,0x0
    80001030:	cce080e7          	jalr	-818(ra) # 80000cfa <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001034:	00c4d793          	srli	a5,s1,0xc
    80001038:	07aa                	slli	a5,a5,0xa
    8000103a:	0017e793          	ori	a5,a5,1
    8000103e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001042:	3a5d                	addiw	s4,s4,-9
    80001044:	036a0063          	beq	s4,s6,80001064 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001048:	0149d933          	srl	s2,s3,s4
    8000104c:	1ff97913          	andi	s2,s2,511
    80001050:	090e                	slli	s2,s2,0x3
    80001052:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001054:	00093483          	ld	s1,0(s2)
    80001058:	0014f793          	andi	a5,s1,1
    8000105c:	dfd5                	beqz	a5,80001018 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000105e:	80a9                	srli	s1,s1,0xa
    80001060:	04b2                	slli	s1,s1,0xc
    80001062:	b7c5                	j	80001042 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001064:	00c9d513          	srli	a0,s3,0xc
    80001068:	1ff57513          	andi	a0,a0,511
    8000106c:	050e                	slli	a0,a0,0x3
    8000106e:	9526                	add	a0,a0,s1
}
    80001070:	70e2                	ld	ra,56(sp)
    80001072:	7442                	ld	s0,48(sp)
    80001074:	74a2                	ld	s1,40(sp)
    80001076:	7902                	ld	s2,32(sp)
    80001078:	69e2                	ld	s3,24(sp)
    8000107a:	6a42                	ld	s4,16(sp)
    8000107c:	6aa2                	ld	s5,8(sp)
    8000107e:	6b02                	ld	s6,0(sp)
    80001080:	6121                	addi	sp,sp,64
    80001082:	8082                	ret
        return 0;
    80001084:	4501                	li	a0,0
    80001086:	b7ed                	j	80001070 <walk+0x8e>

0000000080001088 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001088:	57fd                	li	a5,-1
    8000108a:	83e9                	srli	a5,a5,0x1a
    8000108c:	00b7f463          	bgeu	a5,a1,80001094 <walkaddr+0xc>
    return 0;
    80001090:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001092:	8082                	ret
{
    80001094:	1141                	addi	sp,sp,-16
    80001096:	e406                	sd	ra,8(sp)
    80001098:	e022                	sd	s0,0(sp)
    8000109a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000109c:	4601                	li	a2,0
    8000109e:	00000097          	auipc	ra,0x0
    800010a2:	f44080e7          	jalr	-188(ra) # 80000fe2 <walk>
  if(pte == 0)
    800010a6:	c105                	beqz	a0,800010c6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010a8:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010aa:	0117f693          	andi	a3,a5,17
    800010ae:	4745                	li	a4,17
    return 0;
    800010b0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010b2:	00e68663          	beq	a3,a4,800010be <walkaddr+0x36>
}
    800010b6:	60a2                	ld	ra,8(sp)
    800010b8:	6402                	ld	s0,0(sp)
    800010ba:	0141                	addi	sp,sp,16
    800010bc:	8082                	ret
  pa = PTE2PA(*pte);
    800010be:	00a7d513          	srli	a0,a5,0xa
    800010c2:	0532                	slli	a0,a0,0xc
  return pa;
    800010c4:	bfcd                	j	800010b6 <walkaddr+0x2e>
    return 0;
    800010c6:	4501                	li	a0,0
    800010c8:	b7fd                	j	800010b6 <walkaddr+0x2e>

00000000800010ca <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    800010ca:	1101                	addi	sp,sp,-32
    800010cc:	ec06                	sd	ra,24(sp)
    800010ce:	e822                	sd	s0,16(sp)
    800010d0:	e426                	sd	s1,8(sp)
    800010d2:	1000                	addi	s0,sp,32
    800010d4:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800010d6:	1552                	slli	a0,a0,0x34
    800010d8:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    800010dc:	4601                	li	a2,0
    800010de:	00008517          	auipc	a0,0x8
    800010e2:	f3253503          	ld	a0,-206(a0) # 80009010 <kernel_pagetable>
    800010e6:	00000097          	auipc	ra,0x0
    800010ea:	efc080e7          	jalr	-260(ra) # 80000fe2 <walk>
  if(pte == 0)
    800010ee:	cd09                	beqz	a0,80001108 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    800010f0:	6108                	ld	a0,0(a0)
    800010f2:	00157793          	andi	a5,a0,1
    800010f6:	c38d                	beqz	a5,80001118 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    800010f8:	8129                	srli	a0,a0,0xa
    800010fa:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    800010fc:	9526                	add	a0,a0,s1
    800010fe:	60e2                	ld	ra,24(sp)
    80001100:	6442                	ld	s0,16(sp)
    80001102:	64a2                	ld	s1,8(sp)
    80001104:	6105                	addi	sp,sp,32
    80001106:	8082                	ret
    panic("kvmpa");
    80001108:	00007517          	auipc	a0,0x7
    8000110c:	fd050513          	addi	a0,a0,-48 # 800080d8 <digits+0x98>
    80001110:	fffff097          	auipc	ra,0xfffff
    80001114:	432080e7          	jalr	1074(ra) # 80000542 <panic>
    panic("kvmpa");
    80001118:	00007517          	auipc	a0,0x7
    8000111c:	fc050513          	addi	a0,a0,-64 # 800080d8 <digits+0x98>
    80001120:	fffff097          	auipc	ra,0xfffff
    80001124:	422080e7          	jalr	1058(ra) # 80000542 <panic>

0000000080001128 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001128:	715d                	addi	sp,sp,-80
    8000112a:	e486                	sd	ra,72(sp)
    8000112c:	e0a2                	sd	s0,64(sp)
    8000112e:	fc26                	sd	s1,56(sp)
    80001130:	f84a                	sd	s2,48(sp)
    80001132:	f44e                	sd	s3,40(sp)
    80001134:	f052                	sd	s4,32(sp)
    80001136:	ec56                	sd	s5,24(sp)
    80001138:	e85a                	sd	s6,16(sp)
    8000113a:	e45e                	sd	s7,8(sp)
    8000113c:	0880                	addi	s0,sp,80
    8000113e:	8aaa                	mv	s5,a0
    80001140:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001142:	777d                	lui	a4,0xfffff
    80001144:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001148:	167d                	addi	a2,a2,-1
    8000114a:	00b609b3          	add	s3,a2,a1
    8000114e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001152:	893e                	mv	s2,a5
    80001154:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001158:	6b85                	lui	s7,0x1
    8000115a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115e:	4605                	li	a2,1
    80001160:	85ca                	mv	a1,s2
    80001162:	8556                	mv	a0,s5
    80001164:	00000097          	auipc	ra,0x0
    80001168:	e7e080e7          	jalr	-386(ra) # 80000fe2 <walk>
    8000116c:	c51d                	beqz	a0,8000119a <mappages+0x72>
    if(*pte & PTE_V)
    8000116e:	611c                	ld	a5,0(a0)
    80001170:	8b85                	andi	a5,a5,1
    80001172:	ef81                	bnez	a5,8000118a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001174:	80b1                	srli	s1,s1,0xc
    80001176:	04aa                	slli	s1,s1,0xa
    80001178:	0164e4b3          	or	s1,s1,s6
    8000117c:	0014e493          	ori	s1,s1,1
    80001180:	e104                	sd	s1,0(a0)
    if(a == last)
    80001182:	03390863          	beq	s2,s3,800011b2 <mappages+0x8a>
    a += PGSIZE;
    80001186:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001188:	bfc9                	j	8000115a <mappages+0x32>
      panic("remap");
    8000118a:	00007517          	auipc	a0,0x7
    8000118e:	f5650513          	addi	a0,a0,-170 # 800080e0 <digits+0xa0>
    80001192:	fffff097          	auipc	ra,0xfffff
    80001196:	3b0080e7          	jalr	944(ra) # 80000542 <panic>
      return -1;
    8000119a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000119c:	60a6                	ld	ra,72(sp)
    8000119e:	6406                	ld	s0,64(sp)
    800011a0:	74e2                	ld	s1,56(sp)
    800011a2:	7942                	ld	s2,48(sp)
    800011a4:	79a2                	ld	s3,40(sp)
    800011a6:	7a02                	ld	s4,32(sp)
    800011a8:	6ae2                	ld	s5,24(sp)
    800011aa:	6b42                	ld	s6,16(sp)
    800011ac:	6ba2                	ld	s7,8(sp)
    800011ae:	6161                	addi	sp,sp,80
    800011b0:	8082                	ret
  return 0;
    800011b2:	4501                	li	a0,0
    800011b4:	b7e5                	j	8000119c <mappages+0x74>

00000000800011b6 <kvmmap>:
{
    800011b6:	1141                	addi	sp,sp,-16
    800011b8:	e406                	sd	ra,8(sp)
    800011ba:	e022                	sd	s0,0(sp)
    800011bc:	0800                	addi	s0,sp,16
    800011be:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800011c0:	86ae                	mv	a3,a1
    800011c2:	85aa                	mv	a1,a0
    800011c4:	00008517          	auipc	a0,0x8
    800011c8:	e4c53503          	ld	a0,-436(a0) # 80009010 <kernel_pagetable>
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f5c080e7          	jalr	-164(ra) # 80001128 <mappages>
    800011d4:	e509                	bnez	a0,800011de <kvmmap+0x28>
}
    800011d6:	60a2                	ld	ra,8(sp)
    800011d8:	6402                	ld	s0,0(sp)
    800011da:	0141                	addi	sp,sp,16
    800011dc:	8082                	ret
    panic("kvmmap");
    800011de:	00007517          	auipc	a0,0x7
    800011e2:	f0a50513          	addi	a0,a0,-246 # 800080e8 <digits+0xa8>
    800011e6:	fffff097          	auipc	ra,0xfffff
    800011ea:	35c080e7          	jalr	860(ra) # 80000542 <panic>

00000000800011ee <kvminit>:
{
    800011ee:	1101                	addi	sp,sp,-32
    800011f0:	ec06                	sd	ra,24(sp)
    800011f2:	e822                	sd	s0,16(sp)
    800011f4:	e426                	sd	s1,8(sp)
    800011f6:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	916080e7          	jalr	-1770(ra) # 80000b0e <kalloc>
    80001200:	00008797          	auipc	a5,0x8
    80001204:	e0a7b823          	sd	a0,-496(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001208:	6605                	lui	a2,0x1
    8000120a:	4581                	li	a1,0
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	aee080e7          	jalr	-1298(ra) # 80000cfa <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001214:	4699                	li	a3,6
    80001216:	6605                	lui	a2,0x1
    80001218:	100005b7          	lui	a1,0x10000
    8000121c:	10000537          	lui	a0,0x10000
    80001220:	00000097          	auipc	ra,0x0
    80001224:	f96080e7          	jalr	-106(ra) # 800011b6 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001228:	4699                	li	a3,6
    8000122a:	6605                	lui	a2,0x1
    8000122c:	100015b7          	lui	a1,0x10001
    80001230:	10001537          	lui	a0,0x10001
    80001234:	00000097          	auipc	ra,0x0
    80001238:	f82080e7          	jalr	-126(ra) # 800011b6 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000123c:	4699                	li	a3,6
    8000123e:	6641                	lui	a2,0x10
    80001240:	020005b7          	lui	a1,0x2000
    80001244:	02000537          	lui	a0,0x2000
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	f6e080e7          	jalr	-146(ra) # 800011b6 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001250:	4699                	li	a3,6
    80001252:	00400637          	lui	a2,0x400
    80001256:	0c0005b7          	lui	a1,0xc000
    8000125a:	0c000537          	lui	a0,0xc000
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f58080e7          	jalr	-168(ra) # 800011b6 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001266:	00007497          	auipc	s1,0x7
    8000126a:	d9a48493          	addi	s1,s1,-614 # 80008000 <etext>
    8000126e:	46a9                	li	a3,10
    80001270:	80007617          	auipc	a2,0x80007
    80001274:	d9060613          	addi	a2,a2,-624 # 8000 <_entry-0x7fff8000>
    80001278:	4585                	li	a1,1
    8000127a:	05fe                	slli	a1,a1,0x1f
    8000127c:	852e                	mv	a0,a1
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	f38080e7          	jalr	-200(ra) # 800011b6 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001286:	4699                	li	a3,6
    80001288:	4645                	li	a2,17
    8000128a:	066e                	slli	a2,a2,0x1b
    8000128c:	8e05                	sub	a2,a2,s1
    8000128e:	85a6                	mv	a1,s1
    80001290:	8526                	mv	a0,s1
    80001292:	00000097          	auipc	ra,0x0
    80001296:	f24080e7          	jalr	-220(ra) # 800011b6 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000129a:	46a9                	li	a3,10
    8000129c:	6605                	lui	a2,0x1
    8000129e:	00006597          	auipc	a1,0x6
    800012a2:	d6258593          	addi	a1,a1,-670 # 80007000 <_trampoline>
    800012a6:	04000537          	lui	a0,0x4000
    800012aa:	157d                	addi	a0,a0,-1
    800012ac:	0532                	slli	a0,a0,0xc
    800012ae:	00000097          	auipc	ra,0x0
    800012b2:	f08080e7          	jalr	-248(ra) # 800011b6 <kvmmap>
}
    800012b6:	60e2                	ld	ra,24(sp)
    800012b8:	6442                	ld	s0,16(sp)
    800012ba:	64a2                	ld	s1,8(sp)
    800012bc:	6105                	addi	sp,sp,32
    800012be:	8082                	ret

00000000800012c0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012c0:	715d                	addi	sp,sp,-80
    800012c2:	e486                	sd	ra,72(sp)
    800012c4:	e0a2                	sd	s0,64(sp)
    800012c6:	fc26                	sd	s1,56(sp)
    800012c8:	f84a                	sd	s2,48(sp)
    800012ca:	f44e                	sd	s3,40(sp)
    800012cc:	f052                	sd	s4,32(sp)
    800012ce:	ec56                	sd	s5,24(sp)
    800012d0:	e85a                	sd	s6,16(sp)
    800012d2:	e45e                	sd	s7,8(sp)
    800012d4:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012d6:	03459793          	slli	a5,a1,0x34
    800012da:	e795                	bnez	a5,80001306 <uvmunmap+0x46>
    800012dc:	8a2a                	mv	s4,a0
    800012de:	892e                	mv	s2,a1
    800012e0:	8b36                	mv	s6,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e2:	0632                	slli	a2,a2,0xc
    800012e4:	00b609b3          	add	s3,a2,a1
      continue;
      //panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      //panic("uvmunmap: not mapped");
      continue;
    if(PTE_FLAGS(*pte) == PTE_V)
    800012e8:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ea:	6a85                	lui	s5,0x1
    800012ec:	0535e263          	bltu	a1,s3,80001330 <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012f0:	60a6                	ld	ra,72(sp)
    800012f2:	6406                	ld	s0,64(sp)
    800012f4:	74e2                	ld	s1,56(sp)
    800012f6:	7942                	ld	s2,48(sp)
    800012f8:	79a2                	ld	s3,40(sp)
    800012fa:	7a02                	ld	s4,32(sp)
    800012fc:	6ae2                	ld	s5,24(sp)
    800012fe:	6b42                	ld	s6,16(sp)
    80001300:	6ba2                	ld	s7,8(sp)
    80001302:	6161                	addi	sp,sp,80
    80001304:	8082                	ret
    panic("uvmunmap: not aligned");
    80001306:	00007517          	auipc	a0,0x7
    8000130a:	dea50513          	addi	a0,a0,-534 # 800080f0 <digits+0xb0>
    8000130e:	fffff097          	auipc	ra,0xfffff
    80001312:	234080e7          	jalr	564(ra) # 80000542 <panic>
      panic("uvmunmap: not a leaf");
    80001316:	00007517          	auipc	a0,0x7
    8000131a:	df250513          	addi	a0,a0,-526 # 80008108 <digits+0xc8>
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	224080e7          	jalr	548(ra) # 80000542 <panic>
    *pte = 0;
    80001326:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000132a:	9956                	add	s2,s2,s5
    8000132c:	fd3972e3          	bgeu	s2,s3,800012f0 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001330:	4601                	li	a2,0
    80001332:	85ca                	mv	a1,s2
    80001334:	8552                	mv	a0,s4
    80001336:	00000097          	auipc	ra,0x0
    8000133a:	cac080e7          	jalr	-852(ra) # 80000fe2 <walk>
    8000133e:	84aa                	mv	s1,a0
    80001340:	d56d                	beqz	a0,8000132a <uvmunmap+0x6a>
    if((*pte & PTE_V) == 0)
    80001342:	611c                	ld	a5,0(a0)
    80001344:	0017f713          	andi	a4,a5,1
    80001348:	d36d                	beqz	a4,8000132a <uvmunmap+0x6a>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000134a:	3ff7f713          	andi	a4,a5,1023
    8000134e:	fd7704e3          	beq	a4,s7,80001316 <uvmunmap+0x56>
    if(do_free){
    80001352:	fc0b0ae3          	beqz	s6,80001326 <uvmunmap+0x66>
      uint64 pa = PTE2PA(*pte);
    80001356:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001358:	00c79513          	slli	a0,a5,0xc
    8000135c:	fffff097          	auipc	ra,0xfffff
    80001360:	6b6080e7          	jalr	1718(ra) # 80000a12 <kfree>
    80001364:	b7c9                	j	80001326 <uvmunmap+0x66>

0000000080001366 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001366:	1101                	addi	sp,sp,-32
    80001368:	ec06                	sd	ra,24(sp)
    8000136a:	e822                	sd	s0,16(sp)
    8000136c:	e426                	sd	s1,8(sp)
    8000136e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001370:	fffff097          	auipc	ra,0xfffff
    80001374:	79e080e7          	jalr	1950(ra) # 80000b0e <kalloc>
    80001378:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000137a:	c519                	beqz	a0,80001388 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	97a080e7          	jalr	-1670(ra) # 80000cfa <memset>
  return pagetable;
}
    80001388:	8526                	mv	a0,s1
    8000138a:	60e2                	ld	ra,24(sp)
    8000138c:	6442                	ld	s0,16(sp)
    8000138e:	64a2                	ld	s1,8(sp)
    80001390:	6105                	addi	sp,sp,32
    80001392:	8082                	ret

0000000080001394 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001394:	7179                	addi	sp,sp,-48
    80001396:	f406                	sd	ra,40(sp)
    80001398:	f022                	sd	s0,32(sp)
    8000139a:	ec26                	sd	s1,24(sp)
    8000139c:	e84a                	sd	s2,16(sp)
    8000139e:	e44e                	sd	s3,8(sp)
    800013a0:	e052                	sd	s4,0(sp)
    800013a2:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013a4:	6785                	lui	a5,0x1
    800013a6:	04f67863          	bgeu	a2,a5,800013f6 <uvminit+0x62>
    800013aa:	8a2a                	mv	s4,a0
    800013ac:	89ae                	mv	s3,a1
    800013ae:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013b0:	fffff097          	auipc	ra,0xfffff
    800013b4:	75e080e7          	jalr	1886(ra) # 80000b0e <kalloc>
    800013b8:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013ba:	6605                	lui	a2,0x1
    800013bc:	4581                	li	a1,0
    800013be:	00000097          	auipc	ra,0x0
    800013c2:	93c080e7          	jalr	-1732(ra) # 80000cfa <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013c6:	4779                	li	a4,30
    800013c8:	86ca                	mv	a3,s2
    800013ca:	6605                	lui	a2,0x1
    800013cc:	4581                	li	a1,0
    800013ce:	8552                	mv	a0,s4
    800013d0:	00000097          	auipc	ra,0x0
    800013d4:	d58080e7          	jalr	-680(ra) # 80001128 <mappages>
  memmove(mem, src, sz);
    800013d8:	8626                	mv	a2,s1
    800013da:	85ce                	mv	a1,s3
    800013dc:	854a                	mv	a0,s2
    800013de:	00000097          	auipc	ra,0x0
    800013e2:	978080e7          	jalr	-1672(ra) # 80000d56 <memmove>
}
    800013e6:	70a2                	ld	ra,40(sp)
    800013e8:	7402                	ld	s0,32(sp)
    800013ea:	64e2                	ld	s1,24(sp)
    800013ec:	6942                	ld	s2,16(sp)
    800013ee:	69a2                	ld	s3,8(sp)
    800013f0:	6a02                	ld	s4,0(sp)
    800013f2:	6145                	addi	sp,sp,48
    800013f4:	8082                	ret
    panic("inituvm: more than a page");
    800013f6:	00007517          	auipc	a0,0x7
    800013fa:	d2a50513          	addi	a0,a0,-726 # 80008120 <digits+0xe0>
    800013fe:	fffff097          	auipc	ra,0xfffff
    80001402:	144080e7          	jalr	324(ra) # 80000542 <panic>

0000000080001406 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001406:	1101                	addi	sp,sp,-32
    80001408:	ec06                	sd	ra,24(sp)
    8000140a:	e822                	sd	s0,16(sp)
    8000140c:	e426                	sd	s1,8(sp)
    8000140e:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001410:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001412:	00b67d63          	bgeu	a2,a1,8000142c <uvmdealloc+0x26>
    80001416:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001418:	6785                	lui	a5,0x1
    8000141a:	17fd                	addi	a5,a5,-1
    8000141c:	00f60733          	add	a4,a2,a5
    80001420:	767d                	lui	a2,0xfffff
    80001422:	8f71                	and	a4,a4,a2
    80001424:	97ae                	add	a5,a5,a1
    80001426:	8ff1                	and	a5,a5,a2
    80001428:	00f76863          	bltu	a4,a5,80001438 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000142c:	8526                	mv	a0,s1
    8000142e:	60e2                	ld	ra,24(sp)
    80001430:	6442                	ld	s0,16(sp)
    80001432:	64a2                	ld	s1,8(sp)
    80001434:	6105                	addi	sp,sp,32
    80001436:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001438:	8f99                	sub	a5,a5,a4
    8000143a:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000143c:	4685                	li	a3,1
    8000143e:	0007861b          	sext.w	a2,a5
    80001442:	85ba                	mv	a1,a4
    80001444:	00000097          	auipc	ra,0x0
    80001448:	e7c080e7          	jalr	-388(ra) # 800012c0 <uvmunmap>
    8000144c:	b7c5                	j	8000142c <uvmdealloc+0x26>

000000008000144e <uvmalloc>:
  if(newsz < oldsz)
    8000144e:	0ab66163          	bltu	a2,a1,800014f0 <uvmalloc+0xa2>
{
    80001452:	7139                	addi	sp,sp,-64
    80001454:	fc06                	sd	ra,56(sp)
    80001456:	f822                	sd	s0,48(sp)
    80001458:	f426                	sd	s1,40(sp)
    8000145a:	f04a                	sd	s2,32(sp)
    8000145c:	ec4e                	sd	s3,24(sp)
    8000145e:	e852                	sd	s4,16(sp)
    80001460:	e456                	sd	s5,8(sp)
    80001462:	0080                	addi	s0,sp,64
    80001464:	8aaa                	mv	s5,a0
    80001466:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001468:	6985                	lui	s3,0x1
    8000146a:	19fd                	addi	s3,s3,-1
    8000146c:	95ce                	add	a1,a1,s3
    8000146e:	79fd                	lui	s3,0xfffff
    80001470:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001474:	08c9f063          	bgeu	s3,a2,800014f4 <uvmalloc+0xa6>
    80001478:	894e                	mv	s2,s3
    mem = kalloc();
    8000147a:	fffff097          	auipc	ra,0xfffff
    8000147e:	694080e7          	jalr	1684(ra) # 80000b0e <kalloc>
    80001482:	84aa                	mv	s1,a0
    if(mem == 0){
    80001484:	c51d                	beqz	a0,800014b2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001486:	6605                	lui	a2,0x1
    80001488:	4581                	li	a1,0
    8000148a:	00000097          	auipc	ra,0x0
    8000148e:	870080e7          	jalr	-1936(ra) # 80000cfa <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001492:	4779                	li	a4,30
    80001494:	86a6                	mv	a3,s1
    80001496:	6605                	lui	a2,0x1
    80001498:	85ca                	mv	a1,s2
    8000149a:	8556                	mv	a0,s5
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	c8c080e7          	jalr	-884(ra) # 80001128 <mappages>
    800014a4:	e905                	bnez	a0,800014d4 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014a6:	6785                	lui	a5,0x1
    800014a8:	993e                	add	s2,s2,a5
    800014aa:	fd4968e3          	bltu	s2,s4,8000147a <uvmalloc+0x2c>
  return newsz;
    800014ae:	8552                	mv	a0,s4
    800014b0:	a809                	j	800014c2 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014b2:	864e                	mv	a2,s3
    800014b4:	85ca                	mv	a1,s2
    800014b6:	8556                	mv	a0,s5
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	f4e080e7          	jalr	-178(ra) # 80001406 <uvmdealloc>
      return 0;
    800014c0:	4501                	li	a0,0
}
    800014c2:	70e2                	ld	ra,56(sp)
    800014c4:	7442                	ld	s0,48(sp)
    800014c6:	74a2                	ld	s1,40(sp)
    800014c8:	7902                	ld	s2,32(sp)
    800014ca:	69e2                	ld	s3,24(sp)
    800014cc:	6a42                	ld	s4,16(sp)
    800014ce:	6aa2                	ld	s5,8(sp)
    800014d0:	6121                	addi	sp,sp,64
    800014d2:	8082                	ret
      kfree(mem);
    800014d4:	8526                	mv	a0,s1
    800014d6:	fffff097          	auipc	ra,0xfffff
    800014da:	53c080e7          	jalr	1340(ra) # 80000a12 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014de:	864e                	mv	a2,s3
    800014e0:	85ca                	mv	a1,s2
    800014e2:	8556                	mv	a0,s5
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	f22080e7          	jalr	-222(ra) # 80001406 <uvmdealloc>
      return 0;
    800014ec:	4501                	li	a0,0
    800014ee:	bfd1                	j	800014c2 <uvmalloc+0x74>
    return oldsz;
    800014f0:	852e                	mv	a0,a1
}
    800014f2:	8082                	ret
  return newsz;
    800014f4:	8532                	mv	a0,a2
    800014f6:	b7f1                	j	800014c2 <uvmalloc+0x74>

00000000800014f8 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014f8:	7179                	addi	sp,sp,-48
    800014fa:	f406                	sd	ra,40(sp)
    800014fc:	f022                	sd	s0,32(sp)
    800014fe:	ec26                	sd	s1,24(sp)
    80001500:	e84a                	sd	s2,16(sp)
    80001502:	e44e                	sd	s3,8(sp)
    80001504:	e052                	sd	s4,0(sp)
    80001506:	1800                	addi	s0,sp,48
    80001508:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000150a:	84aa                	mv	s1,a0
    8000150c:	6905                	lui	s2,0x1
    8000150e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001510:	4985                	li	s3,1
    80001512:	a821                	j	8000152a <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001514:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001516:	0532                	slli	a0,a0,0xc
    80001518:	00000097          	auipc	ra,0x0
    8000151c:	fe0080e7          	jalr	-32(ra) # 800014f8 <freewalk>
      pagetable[i] = 0;
    80001520:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001524:	04a1                	addi	s1,s1,8
    80001526:	03248163          	beq	s1,s2,80001548 <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000152a:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000152c:	00f57793          	andi	a5,a0,15
    80001530:	ff3782e3          	beq	a5,s3,80001514 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001534:	8905                	andi	a0,a0,1
    80001536:	d57d                	beqz	a0,80001524 <freewalk+0x2c>
      panic("freewalk: leaf");
    80001538:	00007517          	auipc	a0,0x7
    8000153c:	c0850513          	addi	a0,a0,-1016 # 80008140 <digits+0x100>
    80001540:	fffff097          	auipc	ra,0xfffff
    80001544:	002080e7          	jalr	2(ra) # 80000542 <panic>
    }
  }
  kfree((void*)pagetable);
    80001548:	8552                	mv	a0,s4
    8000154a:	fffff097          	auipc	ra,0xfffff
    8000154e:	4c8080e7          	jalr	1224(ra) # 80000a12 <kfree>
}
    80001552:	70a2                	ld	ra,40(sp)
    80001554:	7402                	ld	s0,32(sp)
    80001556:	64e2                	ld	s1,24(sp)
    80001558:	6942                	ld	s2,16(sp)
    8000155a:	69a2                	ld	s3,8(sp)
    8000155c:	6a02                	ld	s4,0(sp)
    8000155e:	6145                	addi	sp,sp,48
    80001560:	8082                	ret

0000000080001562 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001562:	1101                	addi	sp,sp,-32
    80001564:	ec06                	sd	ra,24(sp)
    80001566:	e822                	sd	s0,16(sp)
    80001568:	e426                	sd	s1,8(sp)
    8000156a:	1000                	addi	s0,sp,32
    8000156c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000156e:	e999                	bnez	a1,80001584 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001570:	8526                	mv	a0,s1
    80001572:	00000097          	auipc	ra,0x0
    80001576:	f86080e7          	jalr	-122(ra) # 800014f8 <freewalk>
}
    8000157a:	60e2                	ld	ra,24(sp)
    8000157c:	6442                	ld	s0,16(sp)
    8000157e:	64a2                	ld	s1,8(sp)
    80001580:	6105                	addi	sp,sp,32
    80001582:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001584:	6605                	lui	a2,0x1
    80001586:	167d                	addi	a2,a2,-1
    80001588:	962e                	add	a2,a2,a1
    8000158a:	4685                	li	a3,1
    8000158c:	8231                	srli	a2,a2,0xc
    8000158e:	4581                	li	a1,0
    80001590:	00000097          	auipc	ra,0x0
    80001594:	d30080e7          	jalr	-720(ra) # 800012c0 <uvmunmap>
    80001598:	bfe1                	j	80001570 <uvmfree+0xe>

000000008000159a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000159a:	ca4d                	beqz	a2,8000164c <uvmcopy+0xb2>
{
    8000159c:	715d                	addi	sp,sp,-80
    8000159e:	e486                	sd	ra,72(sp)
    800015a0:	e0a2                	sd	s0,64(sp)
    800015a2:	fc26                	sd	s1,56(sp)
    800015a4:	f84a                	sd	s2,48(sp)
    800015a6:	f44e                	sd	s3,40(sp)
    800015a8:	f052                	sd	s4,32(sp)
    800015aa:	ec56                	sd	s5,24(sp)
    800015ac:	e85a                	sd	s6,16(sp)
    800015ae:	e45e                	sd	s7,8(sp)
    800015b0:	0880                	addi	s0,sp,80
    800015b2:	8aaa                	mv	s5,a0
    800015b4:	8b2e                	mv	s6,a1
    800015b6:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015b8:	4481                	li	s1,0
    800015ba:	a029                	j	800015c4 <uvmcopy+0x2a>
    800015bc:	6785                	lui	a5,0x1
    800015be:	94be                	add	s1,s1,a5
    800015c0:	0744fa63          	bgeu	s1,s4,80001634 <uvmcopy+0x9a>
    if((pte = walk(old, i, 0)) == 0)
    800015c4:	4601                	li	a2,0
    800015c6:	85a6                	mv	a1,s1
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	a18080e7          	jalr	-1512(ra) # 80000fe2 <walk>
    800015d2:	d56d                	beqz	a0,800015bc <uvmcopy+0x22>
      continue;
      //panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015d4:	6118                	ld	a4,0(a0)
    800015d6:	00177793          	andi	a5,a4,1
    800015da:	d3ed                	beqz	a5,800015bc <uvmcopy+0x22>
      continue;
      //panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015dc:	00a75593          	srli	a1,a4,0xa
    800015e0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015e4:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    800015e8:	fffff097          	auipc	ra,0xfffff
    800015ec:	526080e7          	jalr	1318(ra) # 80000b0e <kalloc>
    800015f0:	89aa                	mv	s3,a0
    800015f2:	c515                	beqz	a0,8000161e <uvmcopy+0x84>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015f4:	6605                	lui	a2,0x1
    800015f6:	85de                	mv	a1,s7
    800015f8:	fffff097          	auipc	ra,0xfffff
    800015fc:	75e080e7          	jalr	1886(ra) # 80000d56 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001600:	874a                	mv	a4,s2
    80001602:	86ce                	mv	a3,s3
    80001604:	6605                	lui	a2,0x1
    80001606:	85a6                	mv	a1,s1
    80001608:	855a                	mv	a0,s6
    8000160a:	00000097          	auipc	ra,0x0
    8000160e:	b1e080e7          	jalr	-1250(ra) # 80001128 <mappages>
    80001612:	d54d                	beqz	a0,800015bc <uvmcopy+0x22>
      kfree(mem);
    80001614:	854e                	mv	a0,s3
    80001616:	fffff097          	auipc	ra,0xfffff
    8000161a:	3fc080e7          	jalr	1020(ra) # 80000a12 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000161e:	4685                	li	a3,1
    80001620:	00c4d613          	srli	a2,s1,0xc
    80001624:	4581                	li	a1,0
    80001626:	855a                	mv	a0,s6
    80001628:	00000097          	auipc	ra,0x0
    8000162c:	c98080e7          	jalr	-872(ra) # 800012c0 <uvmunmap>
  return -1;
    80001630:	557d                	li	a0,-1
    80001632:	a011                	j	80001636 <uvmcopy+0x9c>
  return 0;
    80001634:	4501                	li	a0,0
}
    80001636:	60a6                	ld	ra,72(sp)
    80001638:	6406                	ld	s0,64(sp)
    8000163a:	74e2                	ld	s1,56(sp)
    8000163c:	7942                	ld	s2,48(sp)
    8000163e:	79a2                	ld	s3,40(sp)
    80001640:	7a02                	ld	s4,32(sp)
    80001642:	6ae2                	ld	s5,24(sp)
    80001644:	6b42                	ld	s6,16(sp)
    80001646:	6ba2                	ld	s7,8(sp)
    80001648:	6161                	addi	sp,sp,80
    8000164a:	8082                	ret
  return 0;
    8000164c:	4501                	li	a0,0
}
    8000164e:	8082                	ret

0000000080001650 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001650:	1141                	addi	sp,sp,-16
    80001652:	e406                	sd	ra,8(sp)
    80001654:	e022                	sd	s0,0(sp)
    80001656:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001658:	4601                	li	a2,0
    8000165a:	00000097          	auipc	ra,0x0
    8000165e:	988080e7          	jalr	-1656(ra) # 80000fe2 <walk>
  if(pte == 0)
    80001662:	c901                	beqz	a0,80001672 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001664:	611c                	ld	a5,0(a0)
    80001666:	9bbd                	andi	a5,a5,-17
    80001668:	e11c                	sd	a5,0(a0)
}
    8000166a:	60a2                	ld	ra,8(sp)
    8000166c:	6402                	ld	s0,0(sp)
    8000166e:	0141                	addi	sp,sp,16
    80001670:	8082                	ret
    panic("uvmclear");
    80001672:	00007517          	auipc	a0,0x7
    80001676:	ade50513          	addi	a0,a0,-1314 # 80008150 <digits+0x110>
    8000167a:	fffff097          	auipc	ra,0xfffff
    8000167e:	ec8080e7          	jalr	-312(ra) # 80000542 <panic>

0000000080001682 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001682:	c6bd                	beqz	a3,800016f0 <copyout+0x6e>
{
    80001684:	715d                	addi	sp,sp,-80
    80001686:	e486                	sd	ra,72(sp)
    80001688:	e0a2                	sd	s0,64(sp)
    8000168a:	fc26                	sd	s1,56(sp)
    8000168c:	f84a                	sd	s2,48(sp)
    8000168e:	f44e                	sd	s3,40(sp)
    80001690:	f052                	sd	s4,32(sp)
    80001692:	ec56                	sd	s5,24(sp)
    80001694:	e85a                	sd	s6,16(sp)
    80001696:	e45e                	sd	s7,8(sp)
    80001698:	e062                	sd	s8,0(sp)
    8000169a:	0880                	addi	s0,sp,80
    8000169c:	8b2a                	mv	s6,a0
    8000169e:	8c2e                	mv	s8,a1
    800016a0:	8a32                	mv	s4,a2
    800016a2:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016a4:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016a6:	6a85                	lui	s5,0x1
    800016a8:	a015                	j	800016cc <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016aa:	9562                	add	a0,a0,s8
    800016ac:	0004861b          	sext.w	a2,s1
    800016b0:	85d2                	mv	a1,s4
    800016b2:	41250533          	sub	a0,a0,s2
    800016b6:	fffff097          	auipc	ra,0xfffff
    800016ba:	6a0080e7          	jalr	1696(ra) # 80000d56 <memmove>

    len -= n;
    800016be:	409989b3          	sub	s3,s3,s1
    src += n;
    800016c2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016c4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016c8:	02098263          	beqz	s3,800016ec <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016cc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016d0:	85ca                	mv	a1,s2
    800016d2:	855a                	mv	a0,s6
    800016d4:	00000097          	auipc	ra,0x0
    800016d8:	9b4080e7          	jalr	-1612(ra) # 80001088 <walkaddr>
    if(pa0 == 0)
    800016dc:	cd01                	beqz	a0,800016f4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016de:	418904b3          	sub	s1,s2,s8
    800016e2:	94d6                	add	s1,s1,s5
    if(n > len)
    800016e4:	fc99f3e3          	bgeu	s3,s1,800016aa <copyout+0x28>
    800016e8:	84ce                	mv	s1,s3
    800016ea:	b7c1                	j	800016aa <copyout+0x28>
  }
  return 0;
    800016ec:	4501                	li	a0,0
    800016ee:	a021                	j	800016f6 <copyout+0x74>
    800016f0:	4501                	li	a0,0
}
    800016f2:	8082                	ret
      return -1;
    800016f4:	557d                	li	a0,-1
}
    800016f6:	60a6                	ld	ra,72(sp)
    800016f8:	6406                	ld	s0,64(sp)
    800016fa:	74e2                	ld	s1,56(sp)
    800016fc:	7942                	ld	s2,48(sp)
    800016fe:	79a2                	ld	s3,40(sp)
    80001700:	7a02                	ld	s4,32(sp)
    80001702:	6ae2                	ld	s5,24(sp)
    80001704:	6b42                	ld	s6,16(sp)
    80001706:	6ba2                	ld	s7,8(sp)
    80001708:	6c02                	ld	s8,0(sp)
    8000170a:	6161                	addi	sp,sp,80
    8000170c:	8082                	ret

000000008000170e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000170e:	caa5                	beqz	a3,8000177e <copyin+0x70>
{
    80001710:	715d                	addi	sp,sp,-80
    80001712:	e486                	sd	ra,72(sp)
    80001714:	e0a2                	sd	s0,64(sp)
    80001716:	fc26                	sd	s1,56(sp)
    80001718:	f84a                	sd	s2,48(sp)
    8000171a:	f44e                	sd	s3,40(sp)
    8000171c:	f052                	sd	s4,32(sp)
    8000171e:	ec56                	sd	s5,24(sp)
    80001720:	e85a                	sd	s6,16(sp)
    80001722:	e45e                	sd	s7,8(sp)
    80001724:	e062                	sd	s8,0(sp)
    80001726:	0880                	addi	s0,sp,80
    80001728:	8b2a                	mv	s6,a0
    8000172a:	8a2e                	mv	s4,a1
    8000172c:	8c32                	mv	s8,a2
    8000172e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001730:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001732:	6a85                	lui	s5,0x1
    80001734:	a01d                	j	8000175a <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001736:	018505b3          	add	a1,a0,s8
    8000173a:	0004861b          	sext.w	a2,s1
    8000173e:	412585b3          	sub	a1,a1,s2
    80001742:	8552                	mv	a0,s4
    80001744:	fffff097          	auipc	ra,0xfffff
    80001748:	612080e7          	jalr	1554(ra) # 80000d56 <memmove>

    len -= n;
    8000174c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001750:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001752:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001756:	02098263          	beqz	s3,8000177a <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000175a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000175e:	85ca                	mv	a1,s2
    80001760:	855a                	mv	a0,s6
    80001762:	00000097          	auipc	ra,0x0
    80001766:	926080e7          	jalr	-1754(ra) # 80001088 <walkaddr>
    if(pa0 == 0)
    8000176a:	cd01                	beqz	a0,80001782 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000176c:	418904b3          	sub	s1,s2,s8
    80001770:	94d6                	add	s1,s1,s5
    if(n > len)
    80001772:	fc99f2e3          	bgeu	s3,s1,80001736 <copyin+0x28>
    80001776:	84ce                	mv	s1,s3
    80001778:	bf7d                	j	80001736 <copyin+0x28>
  }
  return 0;
    8000177a:	4501                	li	a0,0
    8000177c:	a021                	j	80001784 <copyin+0x76>
    8000177e:	4501                	li	a0,0
}
    80001780:	8082                	ret
      return -1;
    80001782:	557d                	li	a0,-1
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret

000000008000179c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000179c:	c6c5                	beqz	a3,80001844 <copyinstr+0xa8>
{
    8000179e:	715d                	addi	sp,sp,-80
    800017a0:	e486                	sd	ra,72(sp)
    800017a2:	e0a2                	sd	s0,64(sp)
    800017a4:	fc26                	sd	s1,56(sp)
    800017a6:	f84a                	sd	s2,48(sp)
    800017a8:	f44e                	sd	s3,40(sp)
    800017aa:	f052                	sd	s4,32(sp)
    800017ac:	ec56                	sd	s5,24(sp)
    800017ae:	e85a                	sd	s6,16(sp)
    800017b0:	e45e                	sd	s7,8(sp)
    800017b2:	0880                	addi	s0,sp,80
    800017b4:	8a2a                	mv	s4,a0
    800017b6:	8b2e                	mv	s6,a1
    800017b8:	8bb2                	mv	s7,a2
    800017ba:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017bc:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017be:	6985                	lui	s3,0x1
    800017c0:	a035                	j	800017ec <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017c2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017c6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017c8:	0017b793          	seqz	a5,a5
    800017cc:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017d0:	60a6                	ld	ra,72(sp)
    800017d2:	6406                	ld	s0,64(sp)
    800017d4:	74e2                	ld	s1,56(sp)
    800017d6:	7942                	ld	s2,48(sp)
    800017d8:	79a2                	ld	s3,40(sp)
    800017da:	7a02                	ld	s4,32(sp)
    800017dc:	6ae2                	ld	s5,24(sp)
    800017de:	6b42                	ld	s6,16(sp)
    800017e0:	6ba2                	ld	s7,8(sp)
    800017e2:	6161                	addi	sp,sp,80
    800017e4:	8082                	ret
    srcva = va0 + PGSIZE;
    800017e6:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017ea:	c8a9                	beqz	s1,8000183c <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017ec:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017f0:	85ca                	mv	a1,s2
    800017f2:	8552                	mv	a0,s4
    800017f4:	00000097          	auipc	ra,0x0
    800017f8:	894080e7          	jalr	-1900(ra) # 80001088 <walkaddr>
    if(pa0 == 0)
    800017fc:	c131                	beqz	a0,80001840 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017fe:	41790833          	sub	a6,s2,s7
    80001802:	984e                	add	a6,a6,s3
    if(n > max)
    80001804:	0104f363          	bgeu	s1,a6,8000180a <copyinstr+0x6e>
    80001808:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000180a:	955e                	add	a0,a0,s7
    8000180c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001810:	fc080be3          	beqz	a6,800017e6 <copyinstr+0x4a>
    80001814:	985a                	add	a6,a6,s6
    80001816:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001818:	41650633          	sub	a2,a0,s6
    8000181c:	14fd                	addi	s1,s1,-1
    8000181e:	9b26                	add	s6,s6,s1
    80001820:	00f60733          	add	a4,a2,a5
    80001824:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    80001828:	df49                	beqz	a4,800017c2 <copyinstr+0x26>
        *dst = *p;
    8000182a:	00e78023          	sb	a4,0(a5)
      --max;
    8000182e:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001832:	0785                	addi	a5,a5,1
    while(n > 0){
    80001834:	ff0796e3          	bne	a5,a6,80001820 <copyinstr+0x84>
      dst++;
    80001838:	8b42                	mv	s6,a6
    8000183a:	b775                	j	800017e6 <copyinstr+0x4a>
    8000183c:	4781                	li	a5,0
    8000183e:	b769                	j	800017c8 <copyinstr+0x2c>
      return -1;
    80001840:	557d                	li	a0,-1
    80001842:	b779                	j	800017d0 <copyinstr+0x34>
  int got_null = 0;
    80001844:	4781                	li	a5,0
  if(got_null){
    80001846:	0017b793          	seqz	a5,a5
    8000184a:	40f00533          	neg	a0,a5
}
    8000184e:	8082                	ret

0000000080001850 <lazy_wr_alloc>:

// Lazy alloc for write read and pipe
int
lazy_wr_alloc(uint64 va, struct proc *p)
{
  if(va >= p->sz || va < PGROUNDDOWN(p->trapframe->sp)) {
    80001850:	65bc                	ld	a5,72(a1)
    80001852:	06f57b63          	bgeu	a0,a5,800018c8 <lazy_wr_alloc+0x78>
{
    80001856:	7179                	addi	sp,sp,-48
    80001858:	f406                	sd	ra,40(sp)
    8000185a:	f022                	sd	s0,32(sp)
    8000185c:	ec26                	sd	s1,24(sp)
    8000185e:	e84a                	sd	s2,16(sp)
    80001860:	e44e                	sd	s3,8(sp)
    80001862:	1800                	addi	s0,sp,48
    80001864:	892a                	mv	s2,a0
    80001866:	84ae                	mv	s1,a1
  if(va >= p->sz || va < PGROUNDDOWN(p->trapframe->sp)) {
    80001868:	6dbc                	ld	a5,88(a1)
    8000186a:	7b98                	ld	a4,48(a5)
    8000186c:	77fd                	lui	a5,0xfffff
    8000186e:	8ff9                	and	a5,a5,a4
    80001870:	04f56e63          	bltu	a0,a5,800018cc <lazy_wr_alloc+0x7c>
    //printf("lazy wr alloc error: va higher than sz\n");
    return -1;
  }

  char *mem = kalloc();
    80001874:	fffff097          	auipc	ra,0xfffff
    80001878:	29a080e7          	jalr	666(ra) # 80000b0e <kalloc>
    8000187c:	89aa                	mv	s3,a0
  if(mem == 0){
    8000187e:	c905                	beqz	a0,800018ae <lazy_wr_alloc+0x5e>
    //printf("lazy wr alloc error: no more memory\n");
    p->killed = 1;
    return -1;
  }

  memset(mem, 0, PGSIZE);
    80001880:	6605                	lui	a2,0x1
    80001882:	4581                	li	a1,0
    80001884:	fffff097          	auipc	ra,0xfffff
    80001888:	476080e7          	jalr	1142(ra) # 80000cfa <memset>
  if(mappages(p->pagetable, va, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_U) != 0){
    8000188c:	4759                	li	a4,22
    8000188e:	86ce                	mv	a3,s3
    80001890:	6605                	lui	a2,0x1
    80001892:	85ca                	mv	a1,s2
    80001894:	68a8                	ld	a0,80(s1)
    80001896:	00000097          	auipc	ra,0x0
    8000189a:	892080e7          	jalr	-1902(ra) # 80001128 <mappages>
    8000189e:	ed01                	bnez	a0,800018b6 <lazy_wr_alloc+0x66>
    p->killed = 1;
    return -1;
  }

  return 0;
}
    800018a0:	70a2                	ld	ra,40(sp)
    800018a2:	7402                	ld	s0,32(sp)
    800018a4:	64e2                	ld	s1,24(sp)
    800018a6:	6942                	ld	s2,16(sp)
    800018a8:	69a2                	ld	s3,8(sp)
    800018aa:	6145                	addi	sp,sp,48
    800018ac:	8082                	ret
    p->killed = 1;
    800018ae:	4785                	li	a5,1
    800018b0:	d89c                	sw	a5,48(s1)
    return -1;
    800018b2:	557d                	li	a0,-1
    800018b4:	b7f5                	j	800018a0 <lazy_wr_alloc+0x50>
    kfree(mem);
    800018b6:	854e                	mv	a0,s3
    800018b8:	fffff097          	auipc	ra,0xfffff
    800018bc:	15a080e7          	jalr	346(ra) # 80000a12 <kfree>
    p->killed = 1;
    800018c0:	4785                	li	a5,1
    800018c2:	d89c                	sw	a5,48(s1)
    return -1;
    800018c4:	557d                	li	a0,-1
    800018c6:	bfe9                	j	800018a0 <lazy_wr_alloc+0x50>
    return -1;
    800018c8:	557d                	li	a0,-1
}
    800018ca:	8082                	ret
    return -1;
    800018cc:	557d                	li	a0,-1
    800018ce:	bfc9                	j	800018a0 <lazy_wr_alloc+0x50>

00000000800018d0 <lazy_alloc>:

// Lazy alloc for sbrk
int
lazy_alloc(uint64 stval, struct proc *p)
{
    800018d0:	7179                	addi	sp,sp,-48
    800018d2:	f406                	sd	ra,40(sp)
    800018d4:	f022                	sd	s0,32(sp)
    800018d6:	ec26                	sd	s1,24(sp)
    800018d8:	e84a                	sd	s2,16(sp)
    800018da:	e44e                	sd	s3,8(sp)
    800018dc:	1800                	addi	s0,sp,48
    800018de:	84ae                	mv	s1,a1
  uint64 va = PGROUNDDOWN(stval);
    800018e0:	75fd                	lui	a1,0xfffff
    800018e2:	00b579b3          	and	s3,a0,a1
  if(stval >= p->sz || stval < PGROUNDDOWN(p->trapframe->sp)) {
    800018e6:	64bc                	ld	a5,72(s1)
    800018e8:	04f57563          	bgeu	a0,a5,80001932 <lazy_alloc+0x62>
    800018ec:	6cbc                	ld	a5,88(s1)
    800018ee:	7b98                	ld	a4,48(a5)
    800018f0:	77fd                	lui	a5,0xfffff
    800018f2:	8ff9                	and	a5,a5,a4
    800018f4:	02f56f63          	bltu	a0,a5,80001932 <lazy_alloc+0x62>
    //printf("lazy alloc error: va higher than sz or below user stack\n");
    p->killed = 1;
    return -1;
  }

  char *mem = kalloc();
    800018f8:	fffff097          	auipc	ra,0xfffff
    800018fc:	216080e7          	jalr	534(ra) # 80000b0e <kalloc>
    80001900:	892a                	mv	s2,a0
  if(mem == 0){
    80001902:	cd05                	beqz	a0,8000193a <lazy_alloc+0x6a>
    //printf("lazy alloc error: no more memory\n");
    p->killed = 1;
    return -1;
  }

  memset(mem, 0, PGSIZE);
    80001904:	6605                	lui	a2,0x1
    80001906:	4581                	li	a1,0
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	3f2080e7          	jalr	1010(ra) # 80000cfa <memset>
  if(mappages(p->pagetable, va, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_U) != 0){
    80001910:	4759                	li	a4,22
    80001912:	86ca                	mv	a3,s2
    80001914:	6605                	lui	a2,0x1
    80001916:	85ce                	mv	a1,s3
    80001918:	68a8                	ld	a0,80(s1)
    8000191a:	00000097          	auipc	ra,0x0
    8000191e:	80e080e7          	jalr	-2034(ra) # 80001128 <mappages>
    80001922:	e105                	bnez	a0,80001942 <lazy_alloc+0x72>
    p->killed = 1;
    return -1;
  }

  return 0;
    80001924:	70a2                	ld	ra,40(sp)
    80001926:	7402                	ld	s0,32(sp)
    80001928:	64e2                	ld	s1,24(sp)
    8000192a:	6942                	ld	s2,16(sp)
    8000192c:	69a2                	ld	s3,8(sp)
    8000192e:	6145                	addi	sp,sp,48
    80001930:	8082                	ret
    p->killed = 1;
    80001932:	4785                	li	a5,1
    80001934:	d89c                	sw	a5,48(s1)
    return -1;
    80001936:	557d                	li	a0,-1
    80001938:	b7f5                	j	80001924 <lazy_alloc+0x54>
    p->killed = 1;
    8000193a:	4785                	li	a5,1
    8000193c:	d89c                	sw	a5,48(s1)
    return -1;
    8000193e:	557d                	li	a0,-1
    80001940:	b7d5                	j	80001924 <lazy_alloc+0x54>
    kfree(mem);
    80001942:	854a                	mv	a0,s2
    80001944:	fffff097          	auipc	ra,0xfffff
    80001948:	0ce080e7          	jalr	206(ra) # 80000a12 <kfree>
    p->killed = 1;
    8000194c:	4785                	li	a5,1
    8000194e:	d89c                	sw	a5,48(s1)
    return -1;
    80001950:	557d                	li	a0,-1
    80001952:	bfc9                	j	80001924 <lazy_alloc+0x54>

0000000080001954 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001954:	1101                	addi	sp,sp,-32
    80001956:	ec06                	sd	ra,24(sp)
    80001958:	e822                	sd	s0,16(sp)
    8000195a:	e426                	sd	s1,8(sp)
    8000195c:	1000                	addi	s0,sp,32
    8000195e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001960:	fffff097          	auipc	ra,0xfffff
    80001964:	224080e7          	jalr	548(ra) # 80000b84 <holding>
    80001968:	c909                	beqz	a0,8000197a <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    8000196a:	749c                	ld	a5,40(s1)
    8000196c:	00978f63          	beq	a5,s1,8000198a <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001970:	60e2                	ld	ra,24(sp)
    80001972:	6442                	ld	s0,16(sp)
    80001974:	64a2                	ld	s1,8(sp)
    80001976:	6105                	addi	sp,sp,32
    80001978:	8082                	ret
    panic("wakeup1");
    8000197a:	00006517          	auipc	a0,0x6
    8000197e:	7e650513          	addi	a0,a0,2022 # 80008160 <digits+0x120>
    80001982:	fffff097          	auipc	ra,0xfffff
    80001986:	bc0080e7          	jalr	-1088(ra) # 80000542 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    8000198a:	4c98                	lw	a4,24(s1)
    8000198c:	4785                	li	a5,1
    8000198e:	fef711e3          	bne	a4,a5,80001970 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001992:	4789                	li	a5,2
    80001994:	cc9c                	sw	a5,24(s1)
}
    80001996:	bfe9                	j	80001970 <wakeup1+0x1c>

0000000080001998 <procinit>:
{
    80001998:	715d                	addi	sp,sp,-80
    8000199a:	e486                	sd	ra,72(sp)
    8000199c:	e0a2                	sd	s0,64(sp)
    8000199e:	fc26                	sd	s1,56(sp)
    800019a0:	f84a                	sd	s2,48(sp)
    800019a2:	f44e                	sd	s3,40(sp)
    800019a4:	f052                	sd	s4,32(sp)
    800019a6:	ec56                	sd	s5,24(sp)
    800019a8:	e85a                	sd	s6,16(sp)
    800019aa:	e45e                	sd	s7,8(sp)
    800019ac:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    800019ae:	00006597          	auipc	a1,0x6
    800019b2:	7ba58593          	addi	a1,a1,1978 # 80008168 <digits+0x128>
    800019b6:	00010517          	auipc	a0,0x10
    800019ba:	f9a50513          	addi	a0,a0,-102 # 80011950 <pid_lock>
    800019be:	fffff097          	auipc	ra,0xfffff
    800019c2:	1b0080e7          	jalr	432(ra) # 80000b6e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019c6:	00010917          	auipc	s2,0x10
    800019ca:	3a290913          	addi	s2,s2,930 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    800019ce:	00006b97          	auipc	s7,0x6
    800019d2:	7a2b8b93          	addi	s7,s7,1954 # 80008170 <digits+0x130>
      uint64 va = KSTACK((int) (p - proc));
    800019d6:	8b4a                	mv	s6,s2
    800019d8:	00006a97          	auipc	s5,0x6
    800019dc:	628a8a93          	addi	s5,s5,1576 # 80008000 <etext>
    800019e0:	040009b7          	lui	s3,0x4000
    800019e4:	19fd                	addi	s3,s3,-1
    800019e6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019e8:	00016a17          	auipc	s4,0x16
    800019ec:	d80a0a13          	addi	s4,s4,-640 # 80017768 <tickslock>
      initlock(&p->lock, "proc");
    800019f0:	85de                	mv	a1,s7
    800019f2:	854a                	mv	a0,s2
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	17a080e7          	jalr	378(ra) # 80000b6e <initlock>
      char *pa = kalloc();
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	112080e7          	jalr	274(ra) # 80000b0e <kalloc>
    80001a04:	85aa                	mv	a1,a0
      if(pa == 0)
    80001a06:	c929                	beqz	a0,80001a58 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001a08:	416904b3          	sub	s1,s2,s6
    80001a0c:	848d                	srai	s1,s1,0x3
    80001a0e:	000ab783          	ld	a5,0(s5)
    80001a12:	02f484b3          	mul	s1,s1,a5
    80001a16:	2485                	addiw	s1,s1,1
    80001a18:	00d4949b          	slliw	s1,s1,0xd
    80001a1c:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a20:	4699                	li	a3,6
    80001a22:	6605                	lui	a2,0x1
    80001a24:	8526                	mv	a0,s1
    80001a26:	fffff097          	auipc	ra,0xfffff
    80001a2a:	790080e7          	jalr	1936(ra) # 800011b6 <kvmmap>
      p->kstack = va;
    80001a2e:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a32:	16890913          	addi	s2,s2,360
    80001a36:	fb491de3          	bne	s2,s4,800019f0 <procinit+0x58>
  kvminithart();
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	584080e7          	jalr	1412(ra) # 80000fbe <kvminithart>
}
    80001a42:	60a6                	ld	ra,72(sp)
    80001a44:	6406                	ld	s0,64(sp)
    80001a46:	74e2                	ld	s1,56(sp)
    80001a48:	7942                	ld	s2,48(sp)
    80001a4a:	79a2                	ld	s3,40(sp)
    80001a4c:	7a02                	ld	s4,32(sp)
    80001a4e:	6ae2                	ld	s5,24(sp)
    80001a50:	6b42                	ld	s6,16(sp)
    80001a52:	6ba2                	ld	s7,8(sp)
    80001a54:	6161                	addi	sp,sp,80
    80001a56:	8082                	ret
        panic("kalloc");
    80001a58:	00006517          	auipc	a0,0x6
    80001a5c:	72050513          	addi	a0,a0,1824 # 80008178 <digits+0x138>
    80001a60:	fffff097          	auipc	ra,0xfffff
    80001a64:	ae2080e7          	jalr	-1310(ra) # 80000542 <panic>

0000000080001a68 <cpuid>:
{
    80001a68:	1141                	addi	sp,sp,-16
    80001a6a:	e422                	sd	s0,8(sp)
    80001a6c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a6e:	8512                	mv	a0,tp
}
    80001a70:	2501                	sext.w	a0,a0
    80001a72:	6422                	ld	s0,8(sp)
    80001a74:	0141                	addi	sp,sp,16
    80001a76:	8082                	ret

0000000080001a78 <mycpu>:
mycpu(void) {
    80001a78:	1141                	addi	sp,sp,-16
    80001a7a:	e422                	sd	s0,8(sp)
    80001a7c:	0800                	addi	s0,sp,16
    80001a7e:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a80:	2781                	sext.w	a5,a5
    80001a82:	079e                	slli	a5,a5,0x7
}
    80001a84:	00010517          	auipc	a0,0x10
    80001a88:	ee450513          	addi	a0,a0,-284 # 80011968 <cpus>
    80001a8c:	953e                	add	a0,a0,a5
    80001a8e:	6422                	ld	s0,8(sp)
    80001a90:	0141                	addi	sp,sp,16
    80001a92:	8082                	ret

0000000080001a94 <myproc>:
myproc(void) {
    80001a94:	1101                	addi	sp,sp,-32
    80001a96:	ec06                	sd	ra,24(sp)
    80001a98:	e822                	sd	s0,16(sp)
    80001a9a:	e426                	sd	s1,8(sp)
    80001a9c:	1000                	addi	s0,sp,32
  push_off();
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	114080e7          	jalr	276(ra) # 80000bb2 <push_off>
    80001aa6:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001aa8:	2781                	sext.w	a5,a5
    80001aaa:	079e                	slli	a5,a5,0x7
    80001aac:	00010717          	auipc	a4,0x10
    80001ab0:	ea470713          	addi	a4,a4,-348 # 80011950 <pid_lock>
    80001ab4:	97ba                	add	a5,a5,a4
    80001ab6:	6f84                	ld	s1,24(a5)
  pop_off();
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	19a080e7          	jalr	410(ra) # 80000c52 <pop_off>
}
    80001ac0:	8526                	mv	a0,s1
    80001ac2:	60e2                	ld	ra,24(sp)
    80001ac4:	6442                	ld	s0,16(sp)
    80001ac6:	64a2                	ld	s1,8(sp)
    80001ac8:	6105                	addi	sp,sp,32
    80001aca:	8082                	ret

0000000080001acc <forkret>:
{
    80001acc:	1141                	addi	sp,sp,-16
    80001ace:	e406                	sd	ra,8(sp)
    80001ad0:	e022                	sd	s0,0(sp)
    80001ad2:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001ad4:	00000097          	auipc	ra,0x0
    80001ad8:	fc0080e7          	jalr	-64(ra) # 80001a94 <myproc>
    80001adc:	fffff097          	auipc	ra,0xfffff
    80001ae0:	1d6080e7          	jalr	470(ra) # 80000cb2 <release>
  if (first) {
    80001ae4:	00007797          	auipc	a5,0x7
    80001ae8:	ccc7a783          	lw	a5,-820(a5) # 800087b0 <first.1>
    80001aec:	eb89                	bnez	a5,80001afe <forkret+0x32>
  usertrapret();
    80001aee:	00001097          	auipc	ra,0x1
    80001af2:	c18080e7          	jalr	-1000(ra) # 80002706 <usertrapret>
}
    80001af6:	60a2                	ld	ra,8(sp)
    80001af8:	6402                	ld	s0,0(sp)
    80001afa:	0141                	addi	sp,sp,16
    80001afc:	8082                	ret
    first = 0;
    80001afe:	00007797          	auipc	a5,0x7
    80001b02:	ca07a923          	sw	zero,-846(a5) # 800087b0 <first.1>
    fsinit(ROOTDEV);
    80001b06:	4505                	li	a0,1
    80001b08:	00002097          	auipc	ra,0x2
    80001b0c:	978080e7          	jalr	-1672(ra) # 80003480 <fsinit>
    80001b10:	bff9                	j	80001aee <forkret+0x22>

0000000080001b12 <allocpid>:
allocpid() {
    80001b12:	1101                	addi	sp,sp,-32
    80001b14:	ec06                	sd	ra,24(sp)
    80001b16:	e822                	sd	s0,16(sp)
    80001b18:	e426                	sd	s1,8(sp)
    80001b1a:	e04a                	sd	s2,0(sp)
    80001b1c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b1e:	00010917          	auipc	s2,0x10
    80001b22:	e3290913          	addi	s2,s2,-462 # 80011950 <pid_lock>
    80001b26:	854a                	mv	a0,s2
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	0d6080e7          	jalr	214(ra) # 80000bfe <acquire>
  pid = nextpid;
    80001b30:	00007797          	auipc	a5,0x7
    80001b34:	c8478793          	addi	a5,a5,-892 # 800087b4 <nextpid>
    80001b38:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b3a:	0014871b          	addiw	a4,s1,1
    80001b3e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b40:	854a                	mv	a0,s2
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	170080e7          	jalr	368(ra) # 80000cb2 <release>
}
    80001b4a:	8526                	mv	a0,s1
    80001b4c:	60e2                	ld	ra,24(sp)
    80001b4e:	6442                	ld	s0,16(sp)
    80001b50:	64a2                	ld	s1,8(sp)
    80001b52:	6902                	ld	s2,0(sp)
    80001b54:	6105                	addi	sp,sp,32
    80001b56:	8082                	ret

0000000080001b58 <proc_pagetable>:
{
    80001b58:	1101                	addi	sp,sp,-32
    80001b5a:	ec06                	sd	ra,24(sp)
    80001b5c:	e822                	sd	s0,16(sp)
    80001b5e:	e426                	sd	s1,8(sp)
    80001b60:	e04a                	sd	s2,0(sp)
    80001b62:	1000                	addi	s0,sp,32
    80001b64:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b66:	00000097          	auipc	ra,0x0
    80001b6a:	800080e7          	jalr	-2048(ra) # 80001366 <uvmcreate>
    80001b6e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b70:	c121                	beqz	a0,80001bb0 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b72:	4729                	li	a4,10
    80001b74:	00005697          	auipc	a3,0x5
    80001b78:	48c68693          	addi	a3,a3,1164 # 80007000 <_trampoline>
    80001b7c:	6605                	lui	a2,0x1
    80001b7e:	040005b7          	lui	a1,0x4000
    80001b82:	15fd                	addi	a1,a1,-1
    80001b84:	05b2                	slli	a1,a1,0xc
    80001b86:	fffff097          	auipc	ra,0xfffff
    80001b8a:	5a2080e7          	jalr	1442(ra) # 80001128 <mappages>
    80001b8e:	02054863          	bltz	a0,80001bbe <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b92:	4719                	li	a4,6
    80001b94:	05893683          	ld	a3,88(s2)
    80001b98:	6605                	lui	a2,0x1
    80001b9a:	020005b7          	lui	a1,0x2000
    80001b9e:	15fd                	addi	a1,a1,-1
    80001ba0:	05b6                	slli	a1,a1,0xd
    80001ba2:	8526                	mv	a0,s1
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	584080e7          	jalr	1412(ra) # 80001128 <mappages>
    80001bac:	02054163          	bltz	a0,80001bce <proc_pagetable+0x76>
}
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	60e2                	ld	ra,24(sp)
    80001bb4:	6442                	ld	s0,16(sp)
    80001bb6:	64a2                	ld	s1,8(sp)
    80001bb8:	6902                	ld	s2,0(sp)
    80001bba:	6105                	addi	sp,sp,32
    80001bbc:	8082                	ret
    uvmfree(pagetable, 0);
    80001bbe:	4581                	li	a1,0
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	00000097          	auipc	ra,0x0
    80001bc6:	9a0080e7          	jalr	-1632(ra) # 80001562 <uvmfree>
    return 0;
    80001bca:	4481                	li	s1,0
    80001bcc:	b7d5                	j	80001bb0 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bce:	4681                	li	a3,0
    80001bd0:	4605                	li	a2,1
    80001bd2:	040005b7          	lui	a1,0x4000
    80001bd6:	15fd                	addi	a1,a1,-1
    80001bd8:	05b2                	slli	a1,a1,0xc
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	6e4080e7          	jalr	1764(ra) # 800012c0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001be4:	4581                	li	a1,0
    80001be6:	8526                	mv	a0,s1
    80001be8:	00000097          	auipc	ra,0x0
    80001bec:	97a080e7          	jalr	-1670(ra) # 80001562 <uvmfree>
    return 0;
    80001bf0:	4481                	li	s1,0
    80001bf2:	bf7d                	j	80001bb0 <proc_pagetable+0x58>

0000000080001bf4 <proc_freepagetable>:
{
    80001bf4:	1101                	addi	sp,sp,-32
    80001bf6:	ec06                	sd	ra,24(sp)
    80001bf8:	e822                	sd	s0,16(sp)
    80001bfa:	e426                	sd	s1,8(sp)
    80001bfc:	e04a                	sd	s2,0(sp)
    80001bfe:	1000                	addi	s0,sp,32
    80001c00:	84aa                	mv	s1,a0
    80001c02:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c04:	4681                	li	a3,0
    80001c06:	4605                	li	a2,1
    80001c08:	040005b7          	lui	a1,0x4000
    80001c0c:	15fd                	addi	a1,a1,-1
    80001c0e:	05b2                	slli	a1,a1,0xc
    80001c10:	fffff097          	auipc	ra,0xfffff
    80001c14:	6b0080e7          	jalr	1712(ra) # 800012c0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c18:	4681                	li	a3,0
    80001c1a:	4605                	li	a2,1
    80001c1c:	020005b7          	lui	a1,0x2000
    80001c20:	15fd                	addi	a1,a1,-1
    80001c22:	05b6                	slli	a1,a1,0xd
    80001c24:	8526                	mv	a0,s1
    80001c26:	fffff097          	auipc	ra,0xfffff
    80001c2a:	69a080e7          	jalr	1690(ra) # 800012c0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c2e:	85ca                	mv	a1,s2
    80001c30:	8526                	mv	a0,s1
    80001c32:	00000097          	auipc	ra,0x0
    80001c36:	930080e7          	jalr	-1744(ra) # 80001562 <uvmfree>
}
    80001c3a:	60e2                	ld	ra,24(sp)
    80001c3c:	6442                	ld	s0,16(sp)
    80001c3e:	64a2                	ld	s1,8(sp)
    80001c40:	6902                	ld	s2,0(sp)
    80001c42:	6105                	addi	sp,sp,32
    80001c44:	8082                	ret

0000000080001c46 <freeproc>:
{
    80001c46:	1101                	addi	sp,sp,-32
    80001c48:	ec06                	sd	ra,24(sp)
    80001c4a:	e822                	sd	s0,16(sp)
    80001c4c:	e426                	sd	s1,8(sp)
    80001c4e:	1000                	addi	s0,sp,32
    80001c50:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c52:	6d28                	ld	a0,88(a0)
    80001c54:	c509                	beqz	a0,80001c5e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c56:	fffff097          	auipc	ra,0xfffff
    80001c5a:	dbc080e7          	jalr	-580(ra) # 80000a12 <kfree>
  p->trapframe = 0;
    80001c5e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c62:	68a8                	ld	a0,80(s1)
    80001c64:	c511                	beqz	a0,80001c70 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c66:	64ac                	ld	a1,72(s1)
    80001c68:	00000097          	auipc	ra,0x0
    80001c6c:	f8c080e7          	jalr	-116(ra) # 80001bf4 <proc_freepagetable>
  p->pagetable = 0;
    80001c70:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c74:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c78:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c7c:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c80:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c84:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c88:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c8c:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c90:	0004ac23          	sw	zero,24(s1)
}
    80001c94:	60e2                	ld	ra,24(sp)
    80001c96:	6442                	ld	s0,16(sp)
    80001c98:	64a2                	ld	s1,8(sp)
    80001c9a:	6105                	addi	sp,sp,32
    80001c9c:	8082                	ret

0000000080001c9e <allocproc>:
{
    80001c9e:	1101                	addi	sp,sp,-32
    80001ca0:	ec06                	sd	ra,24(sp)
    80001ca2:	e822                	sd	s0,16(sp)
    80001ca4:	e426                	sd	s1,8(sp)
    80001ca6:	e04a                	sd	s2,0(sp)
    80001ca8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001caa:	00010497          	auipc	s1,0x10
    80001cae:	0be48493          	addi	s1,s1,190 # 80011d68 <proc>
    80001cb2:	00016917          	auipc	s2,0x16
    80001cb6:	ab690913          	addi	s2,s2,-1354 # 80017768 <tickslock>
    acquire(&p->lock);
    80001cba:	8526                	mv	a0,s1
    80001cbc:	fffff097          	auipc	ra,0xfffff
    80001cc0:	f42080e7          	jalr	-190(ra) # 80000bfe <acquire>
    if(p->state == UNUSED) {
    80001cc4:	4c9c                	lw	a5,24(s1)
    80001cc6:	cf81                	beqz	a5,80001cde <allocproc+0x40>
      release(&p->lock);
    80001cc8:	8526                	mv	a0,s1
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	fe8080e7          	jalr	-24(ra) # 80000cb2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cd2:	16848493          	addi	s1,s1,360
    80001cd6:	ff2492e3          	bne	s1,s2,80001cba <allocproc+0x1c>
  return 0;
    80001cda:	4481                	li	s1,0
    80001cdc:	a0b9                	j	80001d2a <allocproc+0x8c>
  p->pid = allocpid();
    80001cde:	00000097          	auipc	ra,0x0
    80001ce2:	e34080e7          	jalr	-460(ra) # 80001b12 <allocpid>
    80001ce6:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ce8:	fffff097          	auipc	ra,0xfffff
    80001cec:	e26080e7          	jalr	-474(ra) # 80000b0e <kalloc>
    80001cf0:	892a                	mv	s2,a0
    80001cf2:	eca8                	sd	a0,88(s1)
    80001cf4:	c131                	beqz	a0,80001d38 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	00000097          	auipc	ra,0x0
    80001cfc:	e60080e7          	jalr	-416(ra) # 80001b58 <proc_pagetable>
    80001d00:	892a                	mv	s2,a0
    80001d02:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d04:	c129                	beqz	a0,80001d46 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001d06:	07000613          	li	a2,112
    80001d0a:	4581                	li	a1,0
    80001d0c:	06048513          	addi	a0,s1,96
    80001d10:	fffff097          	auipc	ra,0xfffff
    80001d14:	fea080e7          	jalr	-22(ra) # 80000cfa <memset>
  p->context.ra = (uint64)forkret;
    80001d18:	00000797          	auipc	a5,0x0
    80001d1c:	db478793          	addi	a5,a5,-588 # 80001acc <forkret>
    80001d20:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d22:	60bc                	ld	a5,64(s1)
    80001d24:	6705                	lui	a4,0x1
    80001d26:	97ba                	add	a5,a5,a4
    80001d28:	f4bc                	sd	a5,104(s1)
}
    80001d2a:	8526                	mv	a0,s1
    80001d2c:	60e2                	ld	ra,24(sp)
    80001d2e:	6442                	ld	s0,16(sp)
    80001d30:	64a2                	ld	s1,8(sp)
    80001d32:	6902                	ld	s2,0(sp)
    80001d34:	6105                	addi	sp,sp,32
    80001d36:	8082                	ret
    release(&p->lock);
    80001d38:	8526                	mv	a0,s1
    80001d3a:	fffff097          	auipc	ra,0xfffff
    80001d3e:	f78080e7          	jalr	-136(ra) # 80000cb2 <release>
    return 0;
    80001d42:	84ca                	mv	s1,s2
    80001d44:	b7dd                	j	80001d2a <allocproc+0x8c>
    freeproc(p);
    80001d46:	8526                	mv	a0,s1
    80001d48:	00000097          	auipc	ra,0x0
    80001d4c:	efe080e7          	jalr	-258(ra) # 80001c46 <freeproc>
    release(&p->lock);
    80001d50:	8526                	mv	a0,s1
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	f60080e7          	jalr	-160(ra) # 80000cb2 <release>
    return 0;
    80001d5a:	84ca                	mv	s1,s2
    80001d5c:	b7f9                	j	80001d2a <allocproc+0x8c>

0000000080001d5e <userinit>:
{
    80001d5e:	1101                	addi	sp,sp,-32
    80001d60:	ec06                	sd	ra,24(sp)
    80001d62:	e822                	sd	s0,16(sp)
    80001d64:	e426                	sd	s1,8(sp)
    80001d66:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d68:	00000097          	auipc	ra,0x0
    80001d6c:	f36080e7          	jalr	-202(ra) # 80001c9e <allocproc>
    80001d70:	84aa                	mv	s1,a0
  initproc = p;
    80001d72:	00007797          	auipc	a5,0x7
    80001d76:	2aa7b323          	sd	a0,678(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d7a:	03400613          	li	a2,52
    80001d7e:	00007597          	auipc	a1,0x7
    80001d82:	a4258593          	addi	a1,a1,-1470 # 800087c0 <initcode>
    80001d86:	6928                	ld	a0,80(a0)
    80001d88:	fffff097          	auipc	ra,0xfffff
    80001d8c:	60c080e7          	jalr	1548(ra) # 80001394 <uvminit>
  p->sz = PGSIZE;
    80001d90:	6785                	lui	a5,0x1
    80001d92:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d94:	6cb8                	ld	a4,88(s1)
    80001d96:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d9a:	6cb8                	ld	a4,88(s1)
    80001d9c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d9e:	4641                	li	a2,16
    80001da0:	00006597          	auipc	a1,0x6
    80001da4:	3e058593          	addi	a1,a1,992 # 80008180 <digits+0x140>
    80001da8:	15848513          	addi	a0,s1,344
    80001dac:	fffff097          	auipc	ra,0xfffff
    80001db0:	0a0080e7          	jalr	160(ra) # 80000e4c <safestrcpy>
  p->cwd = namei("/");
    80001db4:	00006517          	auipc	a0,0x6
    80001db8:	3dc50513          	addi	a0,a0,988 # 80008190 <digits+0x150>
    80001dbc:	00002097          	auipc	ra,0x2
    80001dc0:	0f0080e7          	jalr	240(ra) # 80003eac <namei>
    80001dc4:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001dc8:	4789                	li	a5,2
    80001dca:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dcc:	8526                	mv	a0,s1
    80001dce:	fffff097          	auipc	ra,0xfffff
    80001dd2:	ee4080e7          	jalr	-284(ra) # 80000cb2 <release>
}
    80001dd6:	60e2                	ld	ra,24(sp)
    80001dd8:	6442                	ld	s0,16(sp)
    80001dda:	64a2                	ld	s1,8(sp)
    80001ddc:	6105                	addi	sp,sp,32
    80001dde:	8082                	ret

0000000080001de0 <growproc>:
{
    80001de0:	1101                	addi	sp,sp,-32
    80001de2:	ec06                	sd	ra,24(sp)
    80001de4:	e822                	sd	s0,16(sp)
    80001de6:	e426                	sd	s1,8(sp)
    80001de8:	e04a                	sd	s2,0(sp)
    80001dea:	1000                	addi	s0,sp,32
    80001dec:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dee:	00000097          	auipc	ra,0x0
    80001df2:	ca6080e7          	jalr	-858(ra) # 80001a94 <myproc>
    80001df6:	892a                	mv	s2,a0
  sz = p->sz;
    80001df8:	652c                	ld	a1,72(a0)
    80001dfa:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001dfe:	00904f63          	bgtz	s1,80001e1c <growproc+0x3c>
  } else if(n < 0){
    80001e02:	0204cc63          	bltz	s1,80001e3a <growproc+0x5a>
  p->sz = sz;
    80001e06:	1602                	slli	a2,a2,0x20
    80001e08:	9201                	srli	a2,a2,0x20
    80001e0a:	04c93423          	sd	a2,72(s2)
  return 0;
    80001e0e:	4501                	li	a0,0
}
    80001e10:	60e2                	ld	ra,24(sp)
    80001e12:	6442                	ld	s0,16(sp)
    80001e14:	64a2                	ld	s1,8(sp)
    80001e16:	6902                	ld	s2,0(sp)
    80001e18:	6105                	addi	sp,sp,32
    80001e1a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e1c:	9e25                	addw	a2,a2,s1
    80001e1e:	1602                	slli	a2,a2,0x20
    80001e20:	9201                	srli	a2,a2,0x20
    80001e22:	1582                	slli	a1,a1,0x20
    80001e24:	9181                	srli	a1,a1,0x20
    80001e26:	6928                	ld	a0,80(a0)
    80001e28:	fffff097          	auipc	ra,0xfffff
    80001e2c:	626080e7          	jalr	1574(ra) # 8000144e <uvmalloc>
    80001e30:	0005061b          	sext.w	a2,a0
    80001e34:	fa69                	bnez	a2,80001e06 <growproc+0x26>
      return -1;
    80001e36:	557d                	li	a0,-1
    80001e38:	bfe1                	j	80001e10 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e3a:	9e25                	addw	a2,a2,s1
    80001e3c:	1602                	slli	a2,a2,0x20
    80001e3e:	9201                	srli	a2,a2,0x20
    80001e40:	1582                	slli	a1,a1,0x20
    80001e42:	9181                	srli	a1,a1,0x20
    80001e44:	6928                	ld	a0,80(a0)
    80001e46:	fffff097          	auipc	ra,0xfffff
    80001e4a:	5c0080e7          	jalr	1472(ra) # 80001406 <uvmdealloc>
    80001e4e:	0005061b          	sext.w	a2,a0
    80001e52:	bf55                	j	80001e06 <growproc+0x26>

0000000080001e54 <fork>:
{
    80001e54:	7139                	addi	sp,sp,-64
    80001e56:	fc06                	sd	ra,56(sp)
    80001e58:	f822                	sd	s0,48(sp)
    80001e5a:	f426                	sd	s1,40(sp)
    80001e5c:	f04a                	sd	s2,32(sp)
    80001e5e:	ec4e                	sd	s3,24(sp)
    80001e60:	e852                	sd	s4,16(sp)
    80001e62:	e456                	sd	s5,8(sp)
    80001e64:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e66:	00000097          	auipc	ra,0x0
    80001e6a:	c2e080e7          	jalr	-978(ra) # 80001a94 <myproc>
    80001e6e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e70:	00000097          	auipc	ra,0x0
    80001e74:	e2e080e7          	jalr	-466(ra) # 80001c9e <allocproc>
    80001e78:	c17d                	beqz	a0,80001f5e <fork+0x10a>
    80001e7a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e7c:	048ab603          	ld	a2,72(s5)
    80001e80:	692c                	ld	a1,80(a0)
    80001e82:	050ab503          	ld	a0,80(s5)
    80001e86:	fffff097          	auipc	ra,0xfffff
    80001e8a:	714080e7          	jalr	1812(ra) # 8000159a <uvmcopy>
    80001e8e:	04054a63          	bltz	a0,80001ee2 <fork+0x8e>
  np->sz = p->sz;
    80001e92:	048ab783          	ld	a5,72(s5)
    80001e96:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001e9a:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e9e:	058ab683          	ld	a3,88(s5)
    80001ea2:	87b6                	mv	a5,a3
    80001ea4:	058a3703          	ld	a4,88(s4)
    80001ea8:	12068693          	addi	a3,a3,288
    80001eac:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001eb0:	6788                	ld	a0,8(a5)
    80001eb2:	6b8c                	ld	a1,16(a5)
    80001eb4:	6f90                	ld	a2,24(a5)
    80001eb6:	01073023          	sd	a6,0(a4)
    80001eba:	e708                	sd	a0,8(a4)
    80001ebc:	eb0c                	sd	a1,16(a4)
    80001ebe:	ef10                	sd	a2,24(a4)
    80001ec0:	02078793          	addi	a5,a5,32
    80001ec4:	02070713          	addi	a4,a4,32
    80001ec8:	fed792e3          	bne	a5,a3,80001eac <fork+0x58>
  np->trapframe->a0 = 0;
    80001ecc:	058a3783          	ld	a5,88(s4)
    80001ed0:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ed4:	0d0a8493          	addi	s1,s5,208
    80001ed8:	0d0a0913          	addi	s2,s4,208
    80001edc:	150a8993          	addi	s3,s5,336
    80001ee0:	a00d                	j	80001f02 <fork+0xae>
    freeproc(np);
    80001ee2:	8552                	mv	a0,s4
    80001ee4:	00000097          	auipc	ra,0x0
    80001ee8:	d62080e7          	jalr	-670(ra) # 80001c46 <freeproc>
    release(&np->lock);
    80001eec:	8552                	mv	a0,s4
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	dc4080e7          	jalr	-572(ra) # 80000cb2 <release>
    return -1;
    80001ef6:	54fd                	li	s1,-1
    80001ef8:	a889                	j	80001f4a <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001efa:	04a1                	addi	s1,s1,8
    80001efc:	0921                	addi	s2,s2,8
    80001efe:	01348b63          	beq	s1,s3,80001f14 <fork+0xc0>
    if(p->ofile[i])
    80001f02:	6088                	ld	a0,0(s1)
    80001f04:	d97d                	beqz	a0,80001efa <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f06:	00002097          	auipc	ra,0x2
    80001f0a:	632080e7          	jalr	1586(ra) # 80004538 <filedup>
    80001f0e:	00a93023          	sd	a0,0(s2)
    80001f12:	b7e5                	j	80001efa <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001f14:	150ab503          	ld	a0,336(s5)
    80001f18:	00001097          	auipc	ra,0x1
    80001f1c:	7a2080e7          	jalr	1954(ra) # 800036ba <idup>
    80001f20:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f24:	4641                	li	a2,16
    80001f26:	158a8593          	addi	a1,s5,344
    80001f2a:	158a0513          	addi	a0,s4,344
    80001f2e:	fffff097          	auipc	ra,0xfffff
    80001f32:	f1e080e7          	jalr	-226(ra) # 80000e4c <safestrcpy>
  pid = np->pid;
    80001f36:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001f3a:	4789                	li	a5,2
    80001f3c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f40:	8552                	mv	a0,s4
    80001f42:	fffff097          	auipc	ra,0xfffff
    80001f46:	d70080e7          	jalr	-656(ra) # 80000cb2 <release>
}
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	70e2                	ld	ra,56(sp)
    80001f4e:	7442                	ld	s0,48(sp)
    80001f50:	74a2                	ld	s1,40(sp)
    80001f52:	7902                	ld	s2,32(sp)
    80001f54:	69e2                	ld	s3,24(sp)
    80001f56:	6a42                	ld	s4,16(sp)
    80001f58:	6aa2                	ld	s5,8(sp)
    80001f5a:	6121                	addi	sp,sp,64
    80001f5c:	8082                	ret
    return -1;
    80001f5e:	54fd                	li	s1,-1
    80001f60:	b7ed                	j	80001f4a <fork+0xf6>

0000000080001f62 <reparent>:
{
    80001f62:	7179                	addi	sp,sp,-48
    80001f64:	f406                	sd	ra,40(sp)
    80001f66:	f022                	sd	s0,32(sp)
    80001f68:	ec26                	sd	s1,24(sp)
    80001f6a:	e84a                	sd	s2,16(sp)
    80001f6c:	e44e                	sd	s3,8(sp)
    80001f6e:	e052                	sd	s4,0(sp)
    80001f70:	1800                	addi	s0,sp,48
    80001f72:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f74:	00010497          	auipc	s1,0x10
    80001f78:	df448493          	addi	s1,s1,-524 # 80011d68 <proc>
      pp->parent = initproc;
    80001f7c:	00007a17          	auipc	s4,0x7
    80001f80:	09ca0a13          	addi	s4,s4,156 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f84:	00015997          	auipc	s3,0x15
    80001f88:	7e498993          	addi	s3,s3,2020 # 80017768 <tickslock>
    80001f8c:	a029                	j	80001f96 <reparent+0x34>
    80001f8e:	16848493          	addi	s1,s1,360
    80001f92:	03348363          	beq	s1,s3,80001fb8 <reparent+0x56>
    if(pp->parent == p){
    80001f96:	709c                	ld	a5,32(s1)
    80001f98:	ff279be3          	bne	a5,s2,80001f8e <reparent+0x2c>
      acquire(&pp->lock);
    80001f9c:	8526                	mv	a0,s1
    80001f9e:	fffff097          	auipc	ra,0xfffff
    80001fa2:	c60080e7          	jalr	-928(ra) # 80000bfe <acquire>
      pp->parent = initproc;
    80001fa6:	000a3783          	ld	a5,0(s4)
    80001faa:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001fac:	8526                	mv	a0,s1
    80001fae:	fffff097          	auipc	ra,0xfffff
    80001fb2:	d04080e7          	jalr	-764(ra) # 80000cb2 <release>
    80001fb6:	bfe1                	j	80001f8e <reparent+0x2c>
}
    80001fb8:	70a2                	ld	ra,40(sp)
    80001fba:	7402                	ld	s0,32(sp)
    80001fbc:	64e2                	ld	s1,24(sp)
    80001fbe:	6942                	ld	s2,16(sp)
    80001fc0:	69a2                	ld	s3,8(sp)
    80001fc2:	6a02                	ld	s4,0(sp)
    80001fc4:	6145                	addi	sp,sp,48
    80001fc6:	8082                	ret

0000000080001fc8 <scheduler>:
{
    80001fc8:	711d                	addi	sp,sp,-96
    80001fca:	ec86                	sd	ra,88(sp)
    80001fcc:	e8a2                	sd	s0,80(sp)
    80001fce:	e4a6                	sd	s1,72(sp)
    80001fd0:	e0ca                	sd	s2,64(sp)
    80001fd2:	fc4e                	sd	s3,56(sp)
    80001fd4:	f852                	sd	s4,48(sp)
    80001fd6:	f456                	sd	s5,40(sp)
    80001fd8:	f05a                	sd	s6,32(sp)
    80001fda:	ec5e                	sd	s7,24(sp)
    80001fdc:	e862                	sd	s8,16(sp)
    80001fde:	e466                	sd	s9,8(sp)
    80001fe0:	1080                	addi	s0,sp,96
    80001fe2:	8792                	mv	a5,tp
  int id = r_tp();
    80001fe4:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fe6:	00779c13          	slli	s8,a5,0x7
    80001fea:	00010717          	auipc	a4,0x10
    80001fee:	96670713          	addi	a4,a4,-1690 # 80011950 <pid_lock>
    80001ff2:	9762                	add	a4,a4,s8
    80001ff4:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001ff8:	00010717          	auipc	a4,0x10
    80001ffc:	97870713          	addi	a4,a4,-1672 # 80011970 <cpus+0x8>
    80002000:	9c3a                	add	s8,s8,a4
    int nproc = 0;
    80002002:	4c81                	li	s9,0
      if(p->state == RUNNABLE) {
    80002004:	4a89                	li	s5,2
        c->proc = p;
    80002006:	079e                	slli	a5,a5,0x7
    80002008:	00010b17          	auipc	s6,0x10
    8000200c:	948b0b13          	addi	s6,s6,-1720 # 80011950 <pid_lock>
    80002010:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002012:	00015a17          	auipc	s4,0x15
    80002016:	756a0a13          	addi	s4,s4,1878 # 80017768 <tickslock>
    8000201a:	a8a1                	j	80002072 <scheduler+0xaa>
      release(&p->lock);
    8000201c:	8526                	mv	a0,s1
    8000201e:	fffff097          	auipc	ra,0xfffff
    80002022:	c94080e7          	jalr	-876(ra) # 80000cb2 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002026:	16848493          	addi	s1,s1,360
    8000202a:	03448a63          	beq	s1,s4,8000205e <scheduler+0x96>
      acquire(&p->lock);
    8000202e:	8526                	mv	a0,s1
    80002030:	fffff097          	auipc	ra,0xfffff
    80002034:	bce080e7          	jalr	-1074(ra) # 80000bfe <acquire>
      if(p->state != UNUSED) {
    80002038:	4c9c                	lw	a5,24(s1)
    8000203a:	d3ed                	beqz	a5,8000201c <scheduler+0x54>
        nproc++;
    8000203c:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    8000203e:	fd579fe3          	bne	a5,s5,8000201c <scheduler+0x54>
        p->state = RUNNING;
    80002042:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80002046:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    8000204a:	06048593          	addi	a1,s1,96
    8000204e:	8562                	mv	a0,s8
    80002050:	00000097          	auipc	ra,0x0
    80002054:	60c080e7          	jalr	1548(ra) # 8000265c <swtch>
        c->proc = 0;
    80002058:	000b3c23          	sd	zero,24(s6)
    8000205c:	b7c1                	j	8000201c <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    8000205e:	013aca63          	blt	s5,s3,80002072 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002062:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002066:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000206a:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000206e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002072:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002076:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000207a:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    8000207e:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    80002080:	00010497          	auipc	s1,0x10
    80002084:	ce848493          	addi	s1,s1,-792 # 80011d68 <proc>
        p->state = RUNNING;
    80002088:	4b8d                	li	s7,3
    8000208a:	b755                	j	8000202e <scheduler+0x66>

000000008000208c <sched>:
{
    8000208c:	7179                	addi	sp,sp,-48
    8000208e:	f406                	sd	ra,40(sp)
    80002090:	f022                	sd	s0,32(sp)
    80002092:	ec26                	sd	s1,24(sp)
    80002094:	e84a                	sd	s2,16(sp)
    80002096:	e44e                	sd	s3,8(sp)
    80002098:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000209a:	00000097          	auipc	ra,0x0
    8000209e:	9fa080e7          	jalr	-1542(ra) # 80001a94 <myproc>
    800020a2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	ae0080e7          	jalr	-1312(ra) # 80000b84 <holding>
    800020ac:	c93d                	beqz	a0,80002122 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020ae:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020b0:	2781                	sext.w	a5,a5
    800020b2:	079e                	slli	a5,a5,0x7
    800020b4:	00010717          	auipc	a4,0x10
    800020b8:	89c70713          	addi	a4,a4,-1892 # 80011950 <pid_lock>
    800020bc:	97ba                	add	a5,a5,a4
    800020be:	0907a703          	lw	a4,144(a5)
    800020c2:	4785                	li	a5,1
    800020c4:	06f71763          	bne	a4,a5,80002132 <sched+0xa6>
  if(p->state == RUNNING)
    800020c8:	4c98                	lw	a4,24(s1)
    800020ca:	478d                	li	a5,3
    800020cc:	06f70b63          	beq	a4,a5,80002142 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020d0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020d4:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020d6:	efb5                	bnez	a5,80002152 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020d8:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020da:	00010917          	auipc	s2,0x10
    800020de:	87690913          	addi	s2,s2,-1930 # 80011950 <pid_lock>
    800020e2:	2781                	sext.w	a5,a5
    800020e4:	079e                	slli	a5,a5,0x7
    800020e6:	97ca                	add	a5,a5,s2
    800020e8:	0947a983          	lw	s3,148(a5)
    800020ec:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020ee:	2781                	sext.w	a5,a5
    800020f0:	079e                	slli	a5,a5,0x7
    800020f2:	00010597          	auipc	a1,0x10
    800020f6:	87e58593          	addi	a1,a1,-1922 # 80011970 <cpus+0x8>
    800020fa:	95be                	add	a1,a1,a5
    800020fc:	06048513          	addi	a0,s1,96
    80002100:	00000097          	auipc	ra,0x0
    80002104:	55c080e7          	jalr	1372(ra) # 8000265c <swtch>
    80002108:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000210a:	2781                	sext.w	a5,a5
    8000210c:	079e                	slli	a5,a5,0x7
    8000210e:	97ca                	add	a5,a5,s2
    80002110:	0937aa23          	sw	s3,148(a5)
}
    80002114:	70a2                	ld	ra,40(sp)
    80002116:	7402                	ld	s0,32(sp)
    80002118:	64e2                	ld	s1,24(sp)
    8000211a:	6942                	ld	s2,16(sp)
    8000211c:	69a2                	ld	s3,8(sp)
    8000211e:	6145                	addi	sp,sp,48
    80002120:	8082                	ret
    panic("sched p->lock");
    80002122:	00006517          	auipc	a0,0x6
    80002126:	07650513          	addi	a0,a0,118 # 80008198 <digits+0x158>
    8000212a:	ffffe097          	auipc	ra,0xffffe
    8000212e:	418080e7          	jalr	1048(ra) # 80000542 <panic>
    panic("sched locks");
    80002132:	00006517          	auipc	a0,0x6
    80002136:	07650513          	addi	a0,a0,118 # 800081a8 <digits+0x168>
    8000213a:	ffffe097          	auipc	ra,0xffffe
    8000213e:	408080e7          	jalr	1032(ra) # 80000542 <panic>
    panic("sched running");
    80002142:	00006517          	auipc	a0,0x6
    80002146:	07650513          	addi	a0,a0,118 # 800081b8 <digits+0x178>
    8000214a:	ffffe097          	auipc	ra,0xffffe
    8000214e:	3f8080e7          	jalr	1016(ra) # 80000542 <panic>
    panic("sched interruptible");
    80002152:	00006517          	auipc	a0,0x6
    80002156:	07650513          	addi	a0,a0,118 # 800081c8 <digits+0x188>
    8000215a:	ffffe097          	auipc	ra,0xffffe
    8000215e:	3e8080e7          	jalr	1000(ra) # 80000542 <panic>

0000000080002162 <exit>:
{
    80002162:	7179                	addi	sp,sp,-48
    80002164:	f406                	sd	ra,40(sp)
    80002166:	f022                	sd	s0,32(sp)
    80002168:	ec26                	sd	s1,24(sp)
    8000216a:	e84a                	sd	s2,16(sp)
    8000216c:	e44e                	sd	s3,8(sp)
    8000216e:	e052                	sd	s4,0(sp)
    80002170:	1800                	addi	s0,sp,48
    80002172:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002174:	00000097          	auipc	ra,0x0
    80002178:	920080e7          	jalr	-1760(ra) # 80001a94 <myproc>
    8000217c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000217e:	00007797          	auipc	a5,0x7
    80002182:	e9a7b783          	ld	a5,-358(a5) # 80009018 <initproc>
    80002186:	0d050493          	addi	s1,a0,208
    8000218a:	15050913          	addi	s2,a0,336
    8000218e:	02a79363          	bne	a5,a0,800021b4 <exit+0x52>
    panic("init exiting");
    80002192:	00006517          	auipc	a0,0x6
    80002196:	04e50513          	addi	a0,a0,78 # 800081e0 <digits+0x1a0>
    8000219a:	ffffe097          	auipc	ra,0xffffe
    8000219e:	3a8080e7          	jalr	936(ra) # 80000542 <panic>
      fileclose(f);
    800021a2:	00002097          	auipc	ra,0x2
    800021a6:	3e8080e7          	jalr	1000(ra) # 8000458a <fileclose>
      p->ofile[fd] = 0;
    800021aa:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021ae:	04a1                	addi	s1,s1,8
    800021b0:	01248563          	beq	s1,s2,800021ba <exit+0x58>
    if(p->ofile[fd]){
    800021b4:	6088                	ld	a0,0(s1)
    800021b6:	f575                	bnez	a0,800021a2 <exit+0x40>
    800021b8:	bfdd                	j	800021ae <exit+0x4c>
  begin_op();
    800021ba:	00002097          	auipc	ra,0x2
    800021be:	efe080e7          	jalr	-258(ra) # 800040b8 <begin_op>
  iput(p->cwd);
    800021c2:	1509b503          	ld	a0,336(s3)
    800021c6:	00001097          	auipc	ra,0x1
    800021ca:	6ec080e7          	jalr	1772(ra) # 800038b2 <iput>
  end_op();
    800021ce:	00002097          	auipc	ra,0x2
    800021d2:	f6a080e7          	jalr	-150(ra) # 80004138 <end_op>
  p->cwd = 0;
    800021d6:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    800021da:	00007497          	auipc	s1,0x7
    800021de:	e3e48493          	addi	s1,s1,-450 # 80009018 <initproc>
    800021e2:	6088                	ld	a0,0(s1)
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	a1a080e7          	jalr	-1510(ra) # 80000bfe <acquire>
  wakeup1(initproc);
    800021ec:	6088                	ld	a0,0(s1)
    800021ee:	fffff097          	auipc	ra,0xfffff
    800021f2:	766080e7          	jalr	1894(ra) # 80001954 <wakeup1>
  release(&initproc->lock);
    800021f6:	6088                	ld	a0,0(s1)
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	aba080e7          	jalr	-1350(ra) # 80000cb2 <release>
  acquire(&p->lock);
    80002200:	854e                	mv	a0,s3
    80002202:	fffff097          	auipc	ra,0xfffff
    80002206:	9fc080e7          	jalr	-1540(ra) # 80000bfe <acquire>
  struct proc *original_parent = p->parent;
    8000220a:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    8000220e:	854e                	mv	a0,s3
    80002210:	fffff097          	auipc	ra,0xfffff
    80002214:	aa2080e7          	jalr	-1374(ra) # 80000cb2 <release>
  acquire(&original_parent->lock);
    80002218:	8526                	mv	a0,s1
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	9e4080e7          	jalr	-1564(ra) # 80000bfe <acquire>
  acquire(&p->lock);
    80002222:	854e                	mv	a0,s3
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	9da080e7          	jalr	-1574(ra) # 80000bfe <acquire>
  reparent(p);
    8000222c:	854e                	mv	a0,s3
    8000222e:	00000097          	auipc	ra,0x0
    80002232:	d34080e7          	jalr	-716(ra) # 80001f62 <reparent>
  wakeup1(original_parent);
    80002236:	8526                	mv	a0,s1
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	71c080e7          	jalr	1820(ra) # 80001954 <wakeup1>
  p->xstate = status;
    80002240:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002244:	4791                	li	a5,4
    80002246:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    8000224a:	8526                	mv	a0,s1
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	a66080e7          	jalr	-1434(ra) # 80000cb2 <release>
  sched();
    80002254:	00000097          	auipc	ra,0x0
    80002258:	e38080e7          	jalr	-456(ra) # 8000208c <sched>
  panic("zombie exit");
    8000225c:	00006517          	auipc	a0,0x6
    80002260:	f9450513          	addi	a0,a0,-108 # 800081f0 <digits+0x1b0>
    80002264:	ffffe097          	auipc	ra,0xffffe
    80002268:	2de080e7          	jalr	734(ra) # 80000542 <panic>

000000008000226c <yield>:
{
    8000226c:	1101                	addi	sp,sp,-32
    8000226e:	ec06                	sd	ra,24(sp)
    80002270:	e822                	sd	s0,16(sp)
    80002272:	e426                	sd	s1,8(sp)
    80002274:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002276:	00000097          	auipc	ra,0x0
    8000227a:	81e080e7          	jalr	-2018(ra) # 80001a94 <myproc>
    8000227e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	97e080e7          	jalr	-1666(ra) # 80000bfe <acquire>
  p->state = RUNNABLE;
    80002288:	4789                	li	a5,2
    8000228a:	cc9c                	sw	a5,24(s1)
  sched();
    8000228c:	00000097          	auipc	ra,0x0
    80002290:	e00080e7          	jalr	-512(ra) # 8000208c <sched>
  release(&p->lock);
    80002294:	8526                	mv	a0,s1
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	a1c080e7          	jalr	-1508(ra) # 80000cb2 <release>
}
    8000229e:	60e2                	ld	ra,24(sp)
    800022a0:	6442                	ld	s0,16(sp)
    800022a2:	64a2                	ld	s1,8(sp)
    800022a4:	6105                	addi	sp,sp,32
    800022a6:	8082                	ret

00000000800022a8 <sleep>:
{
    800022a8:	7179                	addi	sp,sp,-48
    800022aa:	f406                	sd	ra,40(sp)
    800022ac:	f022                	sd	s0,32(sp)
    800022ae:	ec26                	sd	s1,24(sp)
    800022b0:	e84a                	sd	s2,16(sp)
    800022b2:	e44e                	sd	s3,8(sp)
    800022b4:	1800                	addi	s0,sp,48
    800022b6:	89aa                	mv	s3,a0
    800022b8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	7da080e7          	jalr	2010(ra) # 80001a94 <myproc>
    800022c2:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800022c4:	05250663          	beq	a0,s2,80002310 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	936080e7          	jalr	-1738(ra) # 80000bfe <acquire>
    release(lk);
    800022d0:	854a                	mv	a0,s2
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	9e0080e7          	jalr	-1568(ra) # 80000cb2 <release>
  p->chan = chan;
    800022da:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    800022de:	4785                	li	a5,1
    800022e0:	cc9c                	sw	a5,24(s1)
  sched();
    800022e2:	00000097          	auipc	ra,0x0
    800022e6:	daa080e7          	jalr	-598(ra) # 8000208c <sched>
  p->chan = 0;
    800022ea:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800022ee:	8526                	mv	a0,s1
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	9c2080e7          	jalr	-1598(ra) # 80000cb2 <release>
    acquire(lk);
    800022f8:	854a                	mv	a0,s2
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	904080e7          	jalr	-1788(ra) # 80000bfe <acquire>
}
    80002302:	70a2                	ld	ra,40(sp)
    80002304:	7402                	ld	s0,32(sp)
    80002306:	64e2                	ld	s1,24(sp)
    80002308:	6942                	ld	s2,16(sp)
    8000230a:	69a2                	ld	s3,8(sp)
    8000230c:	6145                	addi	sp,sp,48
    8000230e:	8082                	ret
  p->chan = chan;
    80002310:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002314:	4785                	li	a5,1
    80002316:	cd1c                	sw	a5,24(a0)
  sched();
    80002318:	00000097          	auipc	ra,0x0
    8000231c:	d74080e7          	jalr	-652(ra) # 8000208c <sched>
  p->chan = 0;
    80002320:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002324:	bff9                	j	80002302 <sleep+0x5a>

0000000080002326 <wait>:
{
    80002326:	715d                	addi	sp,sp,-80
    80002328:	e486                	sd	ra,72(sp)
    8000232a:	e0a2                	sd	s0,64(sp)
    8000232c:	fc26                	sd	s1,56(sp)
    8000232e:	f84a                	sd	s2,48(sp)
    80002330:	f44e                	sd	s3,40(sp)
    80002332:	f052                	sd	s4,32(sp)
    80002334:	ec56                	sd	s5,24(sp)
    80002336:	e85a                	sd	s6,16(sp)
    80002338:	e45e                	sd	s7,8(sp)
    8000233a:	0880                	addi	s0,sp,80
    8000233c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	756080e7          	jalr	1878(ra) # 80001a94 <myproc>
    80002346:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002348:	fffff097          	auipc	ra,0xfffff
    8000234c:	8b6080e7          	jalr	-1866(ra) # 80000bfe <acquire>
    havekids = 0;
    80002350:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002352:	4a11                	li	s4,4
        havekids = 1;
    80002354:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002356:	00015997          	auipc	s3,0x15
    8000235a:	41298993          	addi	s3,s3,1042 # 80017768 <tickslock>
    havekids = 0;
    8000235e:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002360:	00010497          	auipc	s1,0x10
    80002364:	a0848493          	addi	s1,s1,-1528 # 80011d68 <proc>
    80002368:	a08d                	j	800023ca <wait+0xa4>
          pid = np->pid;
    8000236a:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000236e:	000b0e63          	beqz	s6,8000238a <wait+0x64>
    80002372:	4691                	li	a3,4
    80002374:	03448613          	addi	a2,s1,52
    80002378:	85da                	mv	a1,s6
    8000237a:	05093503          	ld	a0,80(s2)
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	304080e7          	jalr	772(ra) # 80001682 <copyout>
    80002386:	02054263          	bltz	a0,800023aa <wait+0x84>
          freeproc(np);
    8000238a:	8526                	mv	a0,s1
    8000238c:	00000097          	auipc	ra,0x0
    80002390:	8ba080e7          	jalr	-1862(ra) # 80001c46 <freeproc>
          release(&np->lock);
    80002394:	8526                	mv	a0,s1
    80002396:	fffff097          	auipc	ra,0xfffff
    8000239a:	91c080e7          	jalr	-1764(ra) # 80000cb2 <release>
          release(&p->lock);
    8000239e:	854a                	mv	a0,s2
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	912080e7          	jalr	-1774(ra) # 80000cb2 <release>
          return pid;
    800023a8:	a8a9                	j	80002402 <wait+0xdc>
            release(&np->lock);
    800023aa:	8526                	mv	a0,s1
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	906080e7          	jalr	-1786(ra) # 80000cb2 <release>
            release(&p->lock);
    800023b4:	854a                	mv	a0,s2
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	8fc080e7          	jalr	-1796(ra) # 80000cb2 <release>
            return -1;
    800023be:	59fd                	li	s3,-1
    800023c0:	a089                	j	80002402 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    800023c2:	16848493          	addi	s1,s1,360
    800023c6:	03348463          	beq	s1,s3,800023ee <wait+0xc8>
      if(np->parent == p){
    800023ca:	709c                	ld	a5,32(s1)
    800023cc:	ff279be3          	bne	a5,s2,800023c2 <wait+0x9c>
        acquire(&np->lock);
    800023d0:	8526                	mv	a0,s1
    800023d2:	fffff097          	auipc	ra,0xfffff
    800023d6:	82c080e7          	jalr	-2004(ra) # 80000bfe <acquire>
        if(np->state == ZOMBIE){
    800023da:	4c9c                	lw	a5,24(s1)
    800023dc:	f94787e3          	beq	a5,s4,8000236a <wait+0x44>
        release(&np->lock);
    800023e0:	8526                	mv	a0,s1
    800023e2:	fffff097          	auipc	ra,0xfffff
    800023e6:	8d0080e7          	jalr	-1840(ra) # 80000cb2 <release>
        havekids = 1;
    800023ea:	8756                	mv	a4,s5
    800023ec:	bfd9                	j	800023c2 <wait+0x9c>
    if(!havekids || p->killed){
    800023ee:	c701                	beqz	a4,800023f6 <wait+0xd0>
    800023f0:	03092783          	lw	a5,48(s2)
    800023f4:	c39d                	beqz	a5,8000241a <wait+0xf4>
      release(&p->lock);
    800023f6:	854a                	mv	a0,s2
    800023f8:	fffff097          	auipc	ra,0xfffff
    800023fc:	8ba080e7          	jalr	-1862(ra) # 80000cb2 <release>
      return -1;
    80002400:	59fd                	li	s3,-1
}
    80002402:	854e                	mv	a0,s3
    80002404:	60a6                	ld	ra,72(sp)
    80002406:	6406                	ld	s0,64(sp)
    80002408:	74e2                	ld	s1,56(sp)
    8000240a:	7942                	ld	s2,48(sp)
    8000240c:	79a2                	ld	s3,40(sp)
    8000240e:	7a02                	ld	s4,32(sp)
    80002410:	6ae2                	ld	s5,24(sp)
    80002412:	6b42                	ld	s6,16(sp)
    80002414:	6ba2                	ld	s7,8(sp)
    80002416:	6161                	addi	sp,sp,80
    80002418:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000241a:	85ca                	mv	a1,s2
    8000241c:	854a                	mv	a0,s2
    8000241e:	00000097          	auipc	ra,0x0
    80002422:	e8a080e7          	jalr	-374(ra) # 800022a8 <sleep>
    havekids = 0;
    80002426:	bf25                	j	8000235e <wait+0x38>

0000000080002428 <wakeup>:
{
    80002428:	7139                	addi	sp,sp,-64
    8000242a:	fc06                	sd	ra,56(sp)
    8000242c:	f822                	sd	s0,48(sp)
    8000242e:	f426                	sd	s1,40(sp)
    80002430:	f04a                	sd	s2,32(sp)
    80002432:	ec4e                	sd	s3,24(sp)
    80002434:	e852                	sd	s4,16(sp)
    80002436:	e456                	sd	s5,8(sp)
    80002438:	0080                	addi	s0,sp,64
    8000243a:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000243c:	00010497          	auipc	s1,0x10
    80002440:	92c48493          	addi	s1,s1,-1748 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002444:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002446:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002448:	00015917          	auipc	s2,0x15
    8000244c:	32090913          	addi	s2,s2,800 # 80017768 <tickslock>
    80002450:	a811                	j	80002464 <wakeup+0x3c>
    release(&p->lock);
    80002452:	8526                	mv	a0,s1
    80002454:	fffff097          	auipc	ra,0xfffff
    80002458:	85e080e7          	jalr	-1954(ra) # 80000cb2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000245c:	16848493          	addi	s1,s1,360
    80002460:	03248063          	beq	s1,s2,80002480 <wakeup+0x58>
    acquire(&p->lock);
    80002464:	8526                	mv	a0,s1
    80002466:	ffffe097          	auipc	ra,0xffffe
    8000246a:	798080e7          	jalr	1944(ra) # 80000bfe <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000246e:	4c9c                	lw	a5,24(s1)
    80002470:	ff3791e3          	bne	a5,s3,80002452 <wakeup+0x2a>
    80002474:	749c                	ld	a5,40(s1)
    80002476:	fd479ee3          	bne	a5,s4,80002452 <wakeup+0x2a>
      p->state = RUNNABLE;
    8000247a:	0154ac23          	sw	s5,24(s1)
    8000247e:	bfd1                	j	80002452 <wakeup+0x2a>
}
    80002480:	70e2                	ld	ra,56(sp)
    80002482:	7442                	ld	s0,48(sp)
    80002484:	74a2                	ld	s1,40(sp)
    80002486:	7902                	ld	s2,32(sp)
    80002488:	69e2                	ld	s3,24(sp)
    8000248a:	6a42                	ld	s4,16(sp)
    8000248c:	6aa2                	ld	s5,8(sp)
    8000248e:	6121                	addi	sp,sp,64
    80002490:	8082                	ret

0000000080002492 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002492:	7179                	addi	sp,sp,-48
    80002494:	f406                	sd	ra,40(sp)
    80002496:	f022                	sd	s0,32(sp)
    80002498:	ec26                	sd	s1,24(sp)
    8000249a:	e84a                	sd	s2,16(sp)
    8000249c:	e44e                	sd	s3,8(sp)
    8000249e:	1800                	addi	s0,sp,48
    800024a0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024a2:	00010497          	auipc	s1,0x10
    800024a6:	8c648493          	addi	s1,s1,-1850 # 80011d68 <proc>
    800024aa:	00015997          	auipc	s3,0x15
    800024ae:	2be98993          	addi	s3,s3,702 # 80017768 <tickslock>
    acquire(&p->lock);
    800024b2:	8526                	mv	a0,s1
    800024b4:	ffffe097          	auipc	ra,0xffffe
    800024b8:	74a080e7          	jalr	1866(ra) # 80000bfe <acquire>
    if(p->pid == pid){
    800024bc:	5c9c                	lw	a5,56(s1)
    800024be:	01278d63          	beq	a5,s2,800024d8 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024c2:	8526                	mv	a0,s1
    800024c4:	ffffe097          	auipc	ra,0xffffe
    800024c8:	7ee080e7          	jalr	2030(ra) # 80000cb2 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024cc:	16848493          	addi	s1,s1,360
    800024d0:	ff3491e3          	bne	s1,s3,800024b2 <kill+0x20>
  }
  return -1;
    800024d4:	557d                	li	a0,-1
    800024d6:	a821                	j	800024ee <kill+0x5c>
      p->killed = 1;
    800024d8:	4785                	li	a5,1
    800024da:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800024dc:	4c98                	lw	a4,24(s1)
    800024de:	00f70f63          	beq	a4,a5,800024fc <kill+0x6a>
      release(&p->lock);
    800024e2:	8526                	mv	a0,s1
    800024e4:	ffffe097          	auipc	ra,0xffffe
    800024e8:	7ce080e7          	jalr	1998(ra) # 80000cb2 <release>
      return 0;
    800024ec:	4501                	li	a0,0
}
    800024ee:	70a2                	ld	ra,40(sp)
    800024f0:	7402                	ld	s0,32(sp)
    800024f2:	64e2                	ld	s1,24(sp)
    800024f4:	6942                	ld	s2,16(sp)
    800024f6:	69a2                	ld	s3,8(sp)
    800024f8:	6145                	addi	sp,sp,48
    800024fa:	8082                	ret
        p->state = RUNNABLE;
    800024fc:	4789                	li	a5,2
    800024fe:	cc9c                	sw	a5,24(s1)
    80002500:	b7cd                	j	800024e2 <kill+0x50>

0000000080002502 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002502:	7179                	addi	sp,sp,-48
    80002504:	f406                	sd	ra,40(sp)
    80002506:	f022                	sd	s0,32(sp)
    80002508:	ec26                	sd	s1,24(sp)
    8000250a:	e84a                	sd	s2,16(sp)
    8000250c:	e44e                	sd	s3,8(sp)
    8000250e:	e052                	sd	s4,0(sp)
    80002510:	1800                	addi	s0,sp,48
    80002512:	84aa                	mv	s1,a0
    80002514:	892e                	mv	s2,a1
    80002516:	89b2                	mv	s3,a2
    80002518:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000251a:	fffff097          	auipc	ra,0xfffff
    8000251e:	57a080e7          	jalr	1402(ra) # 80001a94 <myproc>
  if(user_dst){
    80002522:	c08d                	beqz	s1,80002544 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002524:	86d2                	mv	a3,s4
    80002526:	864e                	mv	a2,s3
    80002528:	85ca                	mv	a1,s2
    8000252a:	6928                	ld	a0,80(a0)
    8000252c:	fffff097          	auipc	ra,0xfffff
    80002530:	156080e7          	jalr	342(ra) # 80001682 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002534:	70a2                	ld	ra,40(sp)
    80002536:	7402                	ld	s0,32(sp)
    80002538:	64e2                	ld	s1,24(sp)
    8000253a:	6942                	ld	s2,16(sp)
    8000253c:	69a2                	ld	s3,8(sp)
    8000253e:	6a02                	ld	s4,0(sp)
    80002540:	6145                	addi	sp,sp,48
    80002542:	8082                	ret
    memmove((char *)dst, src, len);
    80002544:	000a061b          	sext.w	a2,s4
    80002548:	85ce                	mv	a1,s3
    8000254a:	854a                	mv	a0,s2
    8000254c:	fffff097          	auipc	ra,0xfffff
    80002550:	80a080e7          	jalr	-2038(ra) # 80000d56 <memmove>
    return 0;
    80002554:	8526                	mv	a0,s1
    80002556:	bff9                	j	80002534 <either_copyout+0x32>

0000000080002558 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002558:	7179                	addi	sp,sp,-48
    8000255a:	f406                	sd	ra,40(sp)
    8000255c:	f022                	sd	s0,32(sp)
    8000255e:	ec26                	sd	s1,24(sp)
    80002560:	e84a                	sd	s2,16(sp)
    80002562:	e44e                	sd	s3,8(sp)
    80002564:	e052                	sd	s4,0(sp)
    80002566:	1800                	addi	s0,sp,48
    80002568:	892a                	mv	s2,a0
    8000256a:	84ae                	mv	s1,a1
    8000256c:	89b2                	mv	s3,a2
    8000256e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002570:	fffff097          	auipc	ra,0xfffff
    80002574:	524080e7          	jalr	1316(ra) # 80001a94 <myproc>
  if(user_src){
    80002578:	c08d                	beqz	s1,8000259a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000257a:	86d2                	mv	a3,s4
    8000257c:	864e                	mv	a2,s3
    8000257e:	85ca                	mv	a1,s2
    80002580:	6928                	ld	a0,80(a0)
    80002582:	fffff097          	auipc	ra,0xfffff
    80002586:	18c080e7          	jalr	396(ra) # 8000170e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000258a:	70a2                	ld	ra,40(sp)
    8000258c:	7402                	ld	s0,32(sp)
    8000258e:	64e2                	ld	s1,24(sp)
    80002590:	6942                	ld	s2,16(sp)
    80002592:	69a2                	ld	s3,8(sp)
    80002594:	6a02                	ld	s4,0(sp)
    80002596:	6145                	addi	sp,sp,48
    80002598:	8082                	ret
    memmove(dst, (char*)src, len);
    8000259a:	000a061b          	sext.w	a2,s4
    8000259e:	85ce                	mv	a1,s3
    800025a0:	854a                	mv	a0,s2
    800025a2:	ffffe097          	auipc	ra,0xffffe
    800025a6:	7b4080e7          	jalr	1972(ra) # 80000d56 <memmove>
    return 0;
    800025aa:	8526                	mv	a0,s1
    800025ac:	bff9                	j	8000258a <either_copyin+0x32>

00000000800025ae <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025ae:	715d                	addi	sp,sp,-80
    800025b0:	e486                	sd	ra,72(sp)
    800025b2:	e0a2                	sd	s0,64(sp)
    800025b4:	fc26                	sd	s1,56(sp)
    800025b6:	f84a                	sd	s2,48(sp)
    800025b8:	f44e                	sd	s3,40(sp)
    800025ba:	f052                	sd	s4,32(sp)
    800025bc:	ec56                	sd	s5,24(sp)
    800025be:	e85a                	sd	s6,16(sp)
    800025c0:	e45e                	sd	s7,8(sp)
    800025c2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025c4:	00006517          	auipc	a0,0x6
    800025c8:	b0450513          	addi	a0,a0,-1276 # 800080c8 <digits+0x88>
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	fc0080e7          	jalr	-64(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025d4:	00010497          	auipc	s1,0x10
    800025d8:	8ec48493          	addi	s1,s1,-1812 # 80011ec0 <proc+0x158>
    800025dc:	00015917          	auipc	s2,0x15
    800025e0:	2e490913          	addi	s2,s2,740 # 800178c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025e4:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800025e6:	00006997          	auipc	s3,0x6
    800025ea:	c1a98993          	addi	s3,s3,-998 # 80008200 <digits+0x1c0>
    printf("%d %s %s", p->pid, state, p->name);
    800025ee:	00006a97          	auipc	s5,0x6
    800025f2:	c1aa8a93          	addi	s5,s5,-998 # 80008208 <digits+0x1c8>
    printf("\n");
    800025f6:	00006a17          	auipc	s4,0x6
    800025fa:	ad2a0a13          	addi	s4,s4,-1326 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025fe:	00006b97          	auipc	s7,0x6
    80002602:	c42b8b93          	addi	s7,s7,-958 # 80008240 <states.0>
    80002606:	a00d                	j	80002628 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002608:	ee06a583          	lw	a1,-288(a3)
    8000260c:	8556                	mv	a0,s5
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	f7e080e7          	jalr	-130(ra) # 8000058c <printf>
    printf("\n");
    80002616:	8552                	mv	a0,s4
    80002618:	ffffe097          	auipc	ra,0xffffe
    8000261c:	f74080e7          	jalr	-140(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002620:	16848493          	addi	s1,s1,360
    80002624:	03248163          	beq	s1,s2,80002646 <procdump+0x98>
    if(p->state == UNUSED)
    80002628:	86a6                	mv	a3,s1
    8000262a:	ec04a783          	lw	a5,-320(s1)
    8000262e:	dbed                	beqz	a5,80002620 <procdump+0x72>
      state = "???";
    80002630:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002632:	fcfb6be3          	bltu	s6,a5,80002608 <procdump+0x5a>
    80002636:	1782                	slli	a5,a5,0x20
    80002638:	9381                	srli	a5,a5,0x20
    8000263a:	078e                	slli	a5,a5,0x3
    8000263c:	97de                	add	a5,a5,s7
    8000263e:	6390                	ld	a2,0(a5)
    80002640:	f661                	bnez	a2,80002608 <procdump+0x5a>
      state = "???";
    80002642:	864e                	mv	a2,s3
    80002644:	b7d1                	j	80002608 <procdump+0x5a>
  }
}
    80002646:	60a6                	ld	ra,72(sp)
    80002648:	6406                	ld	s0,64(sp)
    8000264a:	74e2                	ld	s1,56(sp)
    8000264c:	7942                	ld	s2,48(sp)
    8000264e:	79a2                	ld	s3,40(sp)
    80002650:	7a02                	ld	s4,32(sp)
    80002652:	6ae2                	ld	s5,24(sp)
    80002654:	6b42                	ld	s6,16(sp)
    80002656:	6ba2                	ld	s7,8(sp)
    80002658:	6161                	addi	sp,sp,80
    8000265a:	8082                	ret

000000008000265c <swtch>:
    8000265c:	00153023          	sd	ra,0(a0)
    80002660:	00253423          	sd	sp,8(a0)
    80002664:	e900                	sd	s0,16(a0)
    80002666:	ed04                	sd	s1,24(a0)
    80002668:	03253023          	sd	s2,32(a0)
    8000266c:	03353423          	sd	s3,40(a0)
    80002670:	03453823          	sd	s4,48(a0)
    80002674:	03553c23          	sd	s5,56(a0)
    80002678:	05653023          	sd	s6,64(a0)
    8000267c:	05753423          	sd	s7,72(a0)
    80002680:	05853823          	sd	s8,80(a0)
    80002684:	05953c23          	sd	s9,88(a0)
    80002688:	07a53023          	sd	s10,96(a0)
    8000268c:	07b53423          	sd	s11,104(a0)
    80002690:	0005b083          	ld	ra,0(a1)
    80002694:	0085b103          	ld	sp,8(a1)
    80002698:	6980                	ld	s0,16(a1)
    8000269a:	6d84                	ld	s1,24(a1)
    8000269c:	0205b903          	ld	s2,32(a1)
    800026a0:	0285b983          	ld	s3,40(a1)
    800026a4:	0305ba03          	ld	s4,48(a1)
    800026a8:	0385ba83          	ld	s5,56(a1)
    800026ac:	0405bb03          	ld	s6,64(a1)
    800026b0:	0485bb83          	ld	s7,72(a1)
    800026b4:	0505bc03          	ld	s8,80(a1)
    800026b8:	0585bc83          	ld	s9,88(a1)
    800026bc:	0605bd03          	ld	s10,96(a1)
    800026c0:	0685bd83          	ld	s11,104(a1)
    800026c4:	8082                	ret

00000000800026c6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026c6:	1141                	addi	sp,sp,-16
    800026c8:	e406                	sd	ra,8(sp)
    800026ca:	e022                	sd	s0,0(sp)
    800026cc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026ce:	00006597          	auipc	a1,0x6
    800026d2:	b9a58593          	addi	a1,a1,-1126 # 80008268 <states.0+0x28>
    800026d6:	00015517          	auipc	a0,0x15
    800026da:	09250513          	addi	a0,a0,146 # 80017768 <tickslock>
    800026de:	ffffe097          	auipc	ra,0xffffe
    800026e2:	490080e7          	jalr	1168(ra) # 80000b6e <initlock>
}
    800026e6:	60a2                	ld	ra,8(sp)
    800026e8:	6402                	ld	s0,0(sp)
    800026ea:	0141                	addi	sp,sp,16
    800026ec:	8082                	ret

00000000800026ee <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026ee:	1141                	addi	sp,sp,-16
    800026f0:	e422                	sd	s0,8(sp)
    800026f2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026f4:	00003797          	auipc	a5,0x3
    800026f8:	61c78793          	addi	a5,a5,1564 # 80005d10 <kernelvec>
    800026fc:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002700:	6422                	ld	s0,8(sp)
    80002702:	0141                	addi	sp,sp,16
    80002704:	8082                	ret

0000000080002706 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002706:	1141                	addi	sp,sp,-16
    80002708:	e406                	sd	ra,8(sp)
    8000270a:	e022                	sd	s0,0(sp)
    8000270c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000270e:	fffff097          	auipc	ra,0xfffff
    80002712:	386080e7          	jalr	902(ra) # 80001a94 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002716:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000271a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000271c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002720:	00005617          	auipc	a2,0x5
    80002724:	8e060613          	addi	a2,a2,-1824 # 80007000 <_trampoline>
    80002728:	00005697          	auipc	a3,0x5
    8000272c:	8d868693          	addi	a3,a3,-1832 # 80007000 <_trampoline>
    80002730:	8e91                	sub	a3,a3,a2
    80002732:	040007b7          	lui	a5,0x4000
    80002736:	17fd                	addi	a5,a5,-1
    80002738:	07b2                	slli	a5,a5,0xc
    8000273a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000273c:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002740:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002742:	180026f3          	csrr	a3,satp
    80002746:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002748:	6d38                	ld	a4,88(a0)
    8000274a:	6134                	ld	a3,64(a0)
    8000274c:	6585                	lui	a1,0x1
    8000274e:	96ae                	add	a3,a3,a1
    80002750:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002752:	6d38                	ld	a4,88(a0)
    80002754:	00000697          	auipc	a3,0x0
    80002758:	13868693          	addi	a3,a3,312 # 8000288c <usertrap>
    8000275c:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000275e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002760:	8692                	mv	a3,tp
    80002762:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002764:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002768:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000276c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002770:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002774:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002776:	6f18                	ld	a4,24(a4)
    80002778:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000277c:	692c                	ld	a1,80(a0)
    8000277e:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002780:	00005717          	auipc	a4,0x5
    80002784:	91070713          	addi	a4,a4,-1776 # 80007090 <userret>
    80002788:	8f11                	sub	a4,a4,a2
    8000278a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000278c:	577d                	li	a4,-1
    8000278e:	177e                	slli	a4,a4,0x3f
    80002790:	8dd9                	or	a1,a1,a4
    80002792:	02000537          	lui	a0,0x2000
    80002796:	157d                	addi	a0,a0,-1
    80002798:	0536                	slli	a0,a0,0xd
    8000279a:	9782                	jalr	a5
}
    8000279c:	60a2                	ld	ra,8(sp)
    8000279e:	6402                	ld	s0,0(sp)
    800027a0:	0141                	addi	sp,sp,16
    800027a2:	8082                	ret

00000000800027a4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027a4:	1101                	addi	sp,sp,-32
    800027a6:	ec06                	sd	ra,24(sp)
    800027a8:	e822                	sd	s0,16(sp)
    800027aa:	e426                	sd	s1,8(sp)
    800027ac:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800027ae:	00015497          	auipc	s1,0x15
    800027b2:	fba48493          	addi	s1,s1,-70 # 80017768 <tickslock>
    800027b6:	8526                	mv	a0,s1
    800027b8:	ffffe097          	auipc	ra,0xffffe
    800027bc:	446080e7          	jalr	1094(ra) # 80000bfe <acquire>
  ticks++;
    800027c0:	00007517          	auipc	a0,0x7
    800027c4:	86050513          	addi	a0,a0,-1952 # 80009020 <ticks>
    800027c8:	411c                	lw	a5,0(a0)
    800027ca:	2785                	addiw	a5,a5,1
    800027cc:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027ce:	00000097          	auipc	ra,0x0
    800027d2:	c5a080e7          	jalr	-934(ra) # 80002428 <wakeup>
  release(&tickslock);
    800027d6:	8526                	mv	a0,s1
    800027d8:	ffffe097          	auipc	ra,0xffffe
    800027dc:	4da080e7          	jalr	1242(ra) # 80000cb2 <release>
}
    800027e0:	60e2                	ld	ra,24(sp)
    800027e2:	6442                	ld	s0,16(sp)
    800027e4:	64a2                	ld	s1,8(sp)
    800027e6:	6105                	addi	sp,sp,32
    800027e8:	8082                	ret

00000000800027ea <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027ea:	1101                	addi	sp,sp,-32
    800027ec:	ec06                	sd	ra,24(sp)
    800027ee:	e822                	sd	s0,16(sp)
    800027f0:	e426                	sd	s1,8(sp)
    800027f2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027f4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027f8:	00074d63          	bltz	a4,80002812 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027fc:	57fd                	li	a5,-1
    800027fe:	17fe                	slli	a5,a5,0x3f
    80002800:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002802:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002804:	06f70363          	beq	a4,a5,8000286a <devintr+0x80>
  }
}
    80002808:	60e2                	ld	ra,24(sp)
    8000280a:	6442                	ld	s0,16(sp)
    8000280c:	64a2                	ld	s1,8(sp)
    8000280e:	6105                	addi	sp,sp,32
    80002810:	8082                	ret
     (scause & 0xff) == 9){
    80002812:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002816:	46a5                	li	a3,9
    80002818:	fed792e3          	bne	a5,a3,800027fc <devintr+0x12>
    int irq = plic_claim();
    8000281c:	00003097          	auipc	ra,0x3
    80002820:	5fc080e7          	jalr	1532(ra) # 80005e18 <plic_claim>
    80002824:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002826:	47a9                	li	a5,10
    80002828:	02f50763          	beq	a0,a5,80002856 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000282c:	4785                	li	a5,1
    8000282e:	02f50963          	beq	a0,a5,80002860 <devintr+0x76>
    return 1;
    80002832:	4505                	li	a0,1
    } else if(irq){
    80002834:	d8f1                	beqz	s1,80002808 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002836:	85a6                	mv	a1,s1
    80002838:	00006517          	auipc	a0,0x6
    8000283c:	a3850513          	addi	a0,a0,-1480 # 80008270 <states.0+0x30>
    80002840:	ffffe097          	auipc	ra,0xffffe
    80002844:	d4c080e7          	jalr	-692(ra) # 8000058c <printf>
      plic_complete(irq);
    80002848:	8526                	mv	a0,s1
    8000284a:	00003097          	auipc	ra,0x3
    8000284e:	5f2080e7          	jalr	1522(ra) # 80005e3c <plic_complete>
    return 1;
    80002852:	4505                	li	a0,1
    80002854:	bf55                	j	80002808 <devintr+0x1e>
      uartintr();
    80002856:	ffffe097          	auipc	ra,0xffffe
    8000285a:	16c080e7          	jalr	364(ra) # 800009c2 <uartintr>
    8000285e:	b7ed                	j	80002848 <devintr+0x5e>
      virtio_disk_intr();
    80002860:	00004097          	auipc	ra,0x4
    80002864:	a56080e7          	jalr	-1450(ra) # 800062b6 <virtio_disk_intr>
    80002868:	b7c5                	j	80002848 <devintr+0x5e>
    if(cpuid() == 0){
    8000286a:	fffff097          	auipc	ra,0xfffff
    8000286e:	1fe080e7          	jalr	510(ra) # 80001a68 <cpuid>
    80002872:	c901                	beqz	a0,80002882 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002874:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002878:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000287a:	14479073          	csrw	sip,a5
    return 2;
    8000287e:	4509                	li	a0,2
    80002880:	b761                	j	80002808 <devintr+0x1e>
      clockintr();
    80002882:	00000097          	auipc	ra,0x0
    80002886:	f22080e7          	jalr	-222(ra) # 800027a4 <clockintr>
    8000288a:	b7ed                	j	80002874 <devintr+0x8a>

000000008000288c <usertrap>:
{
    8000288c:	1101                	addi	sp,sp,-32
    8000288e:	ec06                	sd	ra,24(sp)
    80002890:	e822                	sd	s0,16(sp)
    80002892:	e426                	sd	s1,8(sp)
    80002894:	e04a                	sd	s2,0(sp)
    80002896:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002898:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000289c:	1007f793          	andi	a5,a5,256
    800028a0:	e3ad                	bnez	a5,80002902 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028a2:	00003797          	auipc	a5,0x3
    800028a6:	46e78793          	addi	a5,a5,1134 # 80005d10 <kernelvec>
    800028aa:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028ae:	fffff097          	auipc	ra,0xfffff
    800028b2:	1e6080e7          	jalr	486(ra) # 80001a94 <myproc>
    800028b6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800028b8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ba:	14102773          	csrr	a4,sepc
    800028be:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028c0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028c4:	47a1                	li	a5,8
    800028c6:	04f71c63          	bne	a4,a5,8000291e <usertrap+0x92>
    if(p->killed)
    800028ca:	591c                	lw	a5,48(a0)
    800028cc:	e3b9                	bnez	a5,80002912 <usertrap+0x86>
    p->trapframe->epc += 4;
    800028ce:	6cb8                	ld	a4,88(s1)
    800028d0:	6f1c                	ld	a5,24(a4)
    800028d2:	0791                	addi	a5,a5,4
    800028d4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028d6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028da:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028de:	10079073          	csrw	sstatus,a5
    syscall();
    800028e2:	00000097          	auipc	ra,0x0
    800028e6:	304080e7          	jalr	772(ra) # 80002be6 <syscall>
  if(p->killed)
    800028ea:	589c                	lw	a5,48(s1)
    800028ec:	efd1                	bnez	a5,80002988 <usertrap+0xfc>
  usertrapret();
    800028ee:	00000097          	auipc	ra,0x0
    800028f2:	e18080e7          	jalr	-488(ra) # 80002706 <usertrapret>
}
    800028f6:	60e2                	ld	ra,24(sp)
    800028f8:	6442                	ld	s0,16(sp)
    800028fa:	64a2                	ld	s1,8(sp)
    800028fc:	6902                	ld	s2,0(sp)
    800028fe:	6105                	addi	sp,sp,32
    80002900:	8082                	ret
    panic("usertrap: not from user mode");
    80002902:	00006517          	auipc	a0,0x6
    80002906:	98e50513          	addi	a0,a0,-1650 # 80008290 <states.0+0x50>
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	c38080e7          	jalr	-968(ra) # 80000542 <panic>
      exit(-1);
    80002912:	557d                	li	a0,-1
    80002914:	00000097          	auipc	ra,0x0
    80002918:	84e080e7          	jalr	-1970(ra) # 80002162 <exit>
    8000291c:	bf4d                	j	800028ce <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    8000291e:	00000097          	auipc	ra,0x0
    80002922:	ecc080e7          	jalr	-308(ra) # 800027ea <devintr>
    80002926:	892a                	mv	s2,a0
    80002928:	ed29                	bnez	a0,80002982 <usertrap+0xf6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000292a:	14202773          	csrr	a4,scause
  } else if (r_scause() == 13 || r_scause() == 15) {
    8000292e:	47b5                	li	a5,13
    80002930:	00f70763          	beq	a4,a5,8000293e <usertrap+0xb2>
    80002934:	14202773          	csrr	a4,scause
    80002938:	47bd                	li	a5,15
    8000293a:	00f71a63          	bne	a4,a5,8000294e <usertrap+0xc2>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000293e:	14302573          	csrr	a0,stval
    lazy_alloc(stval, p);
    80002942:	85a6                	mv	a1,s1
    80002944:	fffff097          	auipc	ra,0xfffff
    80002948:	f8c080e7          	jalr	-116(ra) # 800018d0 <lazy_alloc>
  } else if (r_scause() == 13 || r_scause() == 15) {
    8000294c:	bf79                	j	800028ea <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000294e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002952:	5c90                	lw	a2,56(s1)
    80002954:	00006517          	auipc	a0,0x6
    80002958:	95c50513          	addi	a0,a0,-1700 # 800082b0 <states.0+0x70>
    8000295c:	ffffe097          	auipc	ra,0xffffe
    80002960:	c30080e7          	jalr	-976(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002964:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002968:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000296c:	00006517          	auipc	a0,0x6
    80002970:	97450513          	addi	a0,a0,-1676 # 800082e0 <states.0+0xa0>
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	c18080e7          	jalr	-1000(ra) # 8000058c <printf>
    p->killed = 1;
    8000297c:	4785                	li	a5,1
    8000297e:	d89c                	sw	a5,48(s1)
  if(p->killed)
    80002980:	a029                	j	8000298a <usertrap+0xfe>
    80002982:	589c                	lw	a5,48(s1)
    80002984:	cb81                	beqz	a5,80002994 <usertrap+0x108>
    80002986:	a011                	j	8000298a <usertrap+0xfe>
    80002988:	4901                	li	s2,0
    exit(-1);
    8000298a:	557d                	li	a0,-1
    8000298c:	fffff097          	auipc	ra,0xfffff
    80002990:	7d6080e7          	jalr	2006(ra) # 80002162 <exit>
  if(which_dev == 2)
    80002994:	4789                	li	a5,2
    80002996:	f4f91ce3          	bne	s2,a5,800028ee <usertrap+0x62>
    yield();
    8000299a:	00000097          	auipc	ra,0x0
    8000299e:	8d2080e7          	jalr	-1838(ra) # 8000226c <yield>
    800029a2:	b7b1                	j	800028ee <usertrap+0x62>

00000000800029a4 <kerneltrap>:
{
    800029a4:	7179                	addi	sp,sp,-48
    800029a6:	f406                	sd	ra,40(sp)
    800029a8:	f022                	sd	s0,32(sp)
    800029aa:	ec26                	sd	s1,24(sp)
    800029ac:	e84a                	sd	s2,16(sp)
    800029ae:	e44e                	sd	s3,8(sp)
    800029b0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029b2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029b6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029ba:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029be:	1004f793          	andi	a5,s1,256
    800029c2:	cb85                	beqz	a5,800029f2 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029c8:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029ca:	ef85                	bnez	a5,80002a02 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029cc:	00000097          	auipc	ra,0x0
    800029d0:	e1e080e7          	jalr	-482(ra) # 800027ea <devintr>
    800029d4:	cd1d                	beqz	a0,80002a12 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029d6:	4789                	li	a5,2
    800029d8:	06f50a63          	beq	a0,a5,80002a4c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029dc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029e0:	10049073          	csrw	sstatus,s1
}
    800029e4:	70a2                	ld	ra,40(sp)
    800029e6:	7402                	ld	s0,32(sp)
    800029e8:	64e2                	ld	s1,24(sp)
    800029ea:	6942                	ld	s2,16(sp)
    800029ec:	69a2                	ld	s3,8(sp)
    800029ee:	6145                	addi	sp,sp,48
    800029f0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029f2:	00006517          	auipc	a0,0x6
    800029f6:	90e50513          	addi	a0,a0,-1778 # 80008300 <states.0+0xc0>
    800029fa:	ffffe097          	auipc	ra,0xffffe
    800029fe:	b48080e7          	jalr	-1208(ra) # 80000542 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a02:	00006517          	auipc	a0,0x6
    80002a06:	92650513          	addi	a0,a0,-1754 # 80008328 <states.0+0xe8>
    80002a0a:	ffffe097          	auipc	ra,0xffffe
    80002a0e:	b38080e7          	jalr	-1224(ra) # 80000542 <panic>
    printf("scause %p\n", scause);
    80002a12:	85ce                	mv	a1,s3
    80002a14:	00006517          	auipc	a0,0x6
    80002a18:	93450513          	addi	a0,a0,-1740 # 80008348 <states.0+0x108>
    80002a1c:	ffffe097          	auipc	ra,0xffffe
    80002a20:	b70080e7          	jalr	-1168(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a24:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a28:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a2c:	00006517          	auipc	a0,0x6
    80002a30:	92c50513          	addi	a0,a0,-1748 # 80008358 <states.0+0x118>
    80002a34:	ffffe097          	auipc	ra,0xffffe
    80002a38:	b58080e7          	jalr	-1192(ra) # 8000058c <printf>
    panic("kerneltrap");
    80002a3c:	00006517          	auipc	a0,0x6
    80002a40:	93450513          	addi	a0,a0,-1740 # 80008370 <states.0+0x130>
    80002a44:	ffffe097          	auipc	ra,0xffffe
    80002a48:	afe080e7          	jalr	-1282(ra) # 80000542 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a4c:	fffff097          	auipc	ra,0xfffff
    80002a50:	048080e7          	jalr	72(ra) # 80001a94 <myproc>
    80002a54:	d541                	beqz	a0,800029dc <kerneltrap+0x38>
    80002a56:	fffff097          	auipc	ra,0xfffff
    80002a5a:	03e080e7          	jalr	62(ra) # 80001a94 <myproc>
    80002a5e:	4d18                	lw	a4,24(a0)
    80002a60:	478d                	li	a5,3
    80002a62:	f6f71de3          	bne	a4,a5,800029dc <kerneltrap+0x38>
    yield();
    80002a66:	00000097          	auipc	ra,0x0
    80002a6a:	806080e7          	jalr	-2042(ra) # 8000226c <yield>
    80002a6e:	b7bd                	j	800029dc <kerneltrap+0x38>

0000000080002a70 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a70:	1101                	addi	sp,sp,-32
    80002a72:	ec06                	sd	ra,24(sp)
    80002a74:	e822                	sd	s0,16(sp)
    80002a76:	e426                	sd	s1,8(sp)
    80002a78:	1000                	addi	s0,sp,32
    80002a7a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a7c:	fffff097          	auipc	ra,0xfffff
    80002a80:	018080e7          	jalr	24(ra) # 80001a94 <myproc>
  switch (n) {
    80002a84:	4795                	li	a5,5
    80002a86:	0497e163          	bltu	a5,s1,80002ac8 <argraw+0x58>
    80002a8a:	048a                	slli	s1,s1,0x2
    80002a8c:	00006717          	auipc	a4,0x6
    80002a90:	91c70713          	addi	a4,a4,-1764 # 800083a8 <states.0+0x168>
    80002a94:	94ba                	add	s1,s1,a4
    80002a96:	409c                	lw	a5,0(s1)
    80002a98:	97ba                	add	a5,a5,a4
    80002a9a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a9c:	6d3c                	ld	a5,88(a0)
    80002a9e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002aa0:	60e2                	ld	ra,24(sp)
    80002aa2:	6442                	ld	s0,16(sp)
    80002aa4:	64a2                	ld	s1,8(sp)
    80002aa6:	6105                	addi	sp,sp,32
    80002aa8:	8082                	ret
    return p->trapframe->a1;
    80002aaa:	6d3c                	ld	a5,88(a0)
    80002aac:	7fa8                	ld	a0,120(a5)
    80002aae:	bfcd                	j	80002aa0 <argraw+0x30>
    return p->trapframe->a2;
    80002ab0:	6d3c                	ld	a5,88(a0)
    80002ab2:	63c8                	ld	a0,128(a5)
    80002ab4:	b7f5                	j	80002aa0 <argraw+0x30>
    return p->trapframe->a3;
    80002ab6:	6d3c                	ld	a5,88(a0)
    80002ab8:	67c8                	ld	a0,136(a5)
    80002aba:	b7dd                	j	80002aa0 <argraw+0x30>
    return p->trapframe->a4;
    80002abc:	6d3c                	ld	a5,88(a0)
    80002abe:	6bc8                	ld	a0,144(a5)
    80002ac0:	b7c5                	j	80002aa0 <argraw+0x30>
    return p->trapframe->a5;
    80002ac2:	6d3c                	ld	a5,88(a0)
    80002ac4:	6fc8                	ld	a0,152(a5)
    80002ac6:	bfe9                	j	80002aa0 <argraw+0x30>
  panic("argraw");
    80002ac8:	00006517          	auipc	a0,0x6
    80002acc:	8b850513          	addi	a0,a0,-1864 # 80008380 <states.0+0x140>
    80002ad0:	ffffe097          	auipc	ra,0xffffe
    80002ad4:	a72080e7          	jalr	-1422(ra) # 80000542 <panic>

0000000080002ad8 <fetchaddr>:
{
    80002ad8:	1101                	addi	sp,sp,-32
    80002ada:	ec06                	sd	ra,24(sp)
    80002adc:	e822                	sd	s0,16(sp)
    80002ade:	e426                	sd	s1,8(sp)
    80002ae0:	e04a                	sd	s2,0(sp)
    80002ae2:	1000                	addi	s0,sp,32
    80002ae4:	84aa                	mv	s1,a0
    80002ae6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ae8:	fffff097          	auipc	ra,0xfffff
    80002aec:	fac080e7          	jalr	-84(ra) # 80001a94 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002af0:	653c                	ld	a5,72(a0)
    80002af2:	02f4f863          	bgeu	s1,a5,80002b22 <fetchaddr+0x4a>
    80002af6:	00848713          	addi	a4,s1,8
    80002afa:	02e7e663          	bltu	a5,a4,80002b26 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002afe:	46a1                	li	a3,8
    80002b00:	8626                	mv	a2,s1
    80002b02:	85ca                	mv	a1,s2
    80002b04:	6928                	ld	a0,80(a0)
    80002b06:	fffff097          	auipc	ra,0xfffff
    80002b0a:	c08080e7          	jalr	-1016(ra) # 8000170e <copyin>
    80002b0e:	00a03533          	snez	a0,a0
    80002b12:	40a00533          	neg	a0,a0
}
    80002b16:	60e2                	ld	ra,24(sp)
    80002b18:	6442                	ld	s0,16(sp)
    80002b1a:	64a2                	ld	s1,8(sp)
    80002b1c:	6902                	ld	s2,0(sp)
    80002b1e:	6105                	addi	sp,sp,32
    80002b20:	8082                	ret
    return -1;
    80002b22:	557d                	li	a0,-1
    80002b24:	bfcd                	j	80002b16 <fetchaddr+0x3e>
    80002b26:	557d                	li	a0,-1
    80002b28:	b7fd                	j	80002b16 <fetchaddr+0x3e>

0000000080002b2a <fetchstr>:
{
    80002b2a:	7179                	addi	sp,sp,-48
    80002b2c:	f406                	sd	ra,40(sp)
    80002b2e:	f022                	sd	s0,32(sp)
    80002b30:	ec26                	sd	s1,24(sp)
    80002b32:	e84a                	sd	s2,16(sp)
    80002b34:	e44e                	sd	s3,8(sp)
    80002b36:	1800                	addi	s0,sp,48
    80002b38:	892a                	mv	s2,a0
    80002b3a:	84ae                	mv	s1,a1
    80002b3c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b3e:	fffff097          	auipc	ra,0xfffff
    80002b42:	f56080e7          	jalr	-170(ra) # 80001a94 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002b46:	86ce                	mv	a3,s3
    80002b48:	864a                	mv	a2,s2
    80002b4a:	85a6                	mv	a1,s1
    80002b4c:	6928                	ld	a0,80(a0)
    80002b4e:	fffff097          	auipc	ra,0xfffff
    80002b52:	c4e080e7          	jalr	-946(ra) # 8000179c <copyinstr>
  if(err < 0)
    80002b56:	00054763          	bltz	a0,80002b64 <fetchstr+0x3a>
  return strlen(buf);
    80002b5a:	8526                	mv	a0,s1
    80002b5c:	ffffe097          	auipc	ra,0xffffe
    80002b60:	322080e7          	jalr	802(ra) # 80000e7e <strlen>
}
    80002b64:	70a2                	ld	ra,40(sp)
    80002b66:	7402                	ld	s0,32(sp)
    80002b68:	64e2                	ld	s1,24(sp)
    80002b6a:	6942                	ld	s2,16(sp)
    80002b6c:	69a2                	ld	s3,8(sp)
    80002b6e:	6145                	addi	sp,sp,48
    80002b70:	8082                	ret

0000000080002b72 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b72:	1101                	addi	sp,sp,-32
    80002b74:	ec06                	sd	ra,24(sp)
    80002b76:	e822                	sd	s0,16(sp)
    80002b78:	e426                	sd	s1,8(sp)
    80002b7a:	1000                	addi	s0,sp,32
    80002b7c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b7e:	00000097          	auipc	ra,0x0
    80002b82:	ef2080e7          	jalr	-270(ra) # 80002a70 <argraw>
    80002b86:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b88:	4501                	li	a0,0
    80002b8a:	60e2                	ld	ra,24(sp)
    80002b8c:	6442                	ld	s0,16(sp)
    80002b8e:	64a2                	ld	s1,8(sp)
    80002b90:	6105                	addi	sp,sp,32
    80002b92:	8082                	ret

0000000080002b94 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b94:	1101                	addi	sp,sp,-32
    80002b96:	ec06                	sd	ra,24(sp)
    80002b98:	e822                	sd	s0,16(sp)
    80002b9a:	e426                	sd	s1,8(sp)
    80002b9c:	1000                	addi	s0,sp,32
    80002b9e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ba0:	00000097          	auipc	ra,0x0
    80002ba4:	ed0080e7          	jalr	-304(ra) # 80002a70 <argraw>
    80002ba8:	e088                	sd	a0,0(s1)
  return 0;
}
    80002baa:	4501                	li	a0,0
    80002bac:	60e2                	ld	ra,24(sp)
    80002bae:	6442                	ld	s0,16(sp)
    80002bb0:	64a2                	ld	s1,8(sp)
    80002bb2:	6105                	addi	sp,sp,32
    80002bb4:	8082                	ret

0000000080002bb6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002bb6:	1101                	addi	sp,sp,-32
    80002bb8:	ec06                	sd	ra,24(sp)
    80002bba:	e822                	sd	s0,16(sp)
    80002bbc:	e426                	sd	s1,8(sp)
    80002bbe:	e04a                	sd	s2,0(sp)
    80002bc0:	1000                	addi	s0,sp,32
    80002bc2:	84ae                	mv	s1,a1
    80002bc4:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002bc6:	00000097          	auipc	ra,0x0
    80002bca:	eaa080e7          	jalr	-342(ra) # 80002a70 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002bce:	864a                	mv	a2,s2
    80002bd0:	85a6                	mv	a1,s1
    80002bd2:	00000097          	auipc	ra,0x0
    80002bd6:	f58080e7          	jalr	-168(ra) # 80002b2a <fetchstr>
}
    80002bda:	60e2                	ld	ra,24(sp)
    80002bdc:	6442                	ld	s0,16(sp)
    80002bde:	64a2                	ld	s1,8(sp)
    80002be0:	6902                	ld	s2,0(sp)
    80002be2:	6105                	addi	sp,sp,32
    80002be4:	8082                	ret

0000000080002be6 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002be6:	1101                	addi	sp,sp,-32
    80002be8:	ec06                	sd	ra,24(sp)
    80002bea:	e822                	sd	s0,16(sp)
    80002bec:	e426                	sd	s1,8(sp)
    80002bee:	e04a                	sd	s2,0(sp)
    80002bf0:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bf2:	fffff097          	auipc	ra,0xfffff
    80002bf6:	ea2080e7          	jalr	-350(ra) # 80001a94 <myproc>
    80002bfa:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002bfc:	05853903          	ld	s2,88(a0)
    80002c00:	0a893783          	ld	a5,168(s2)
    80002c04:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c08:	37fd                	addiw	a5,a5,-1
    80002c0a:	4751                	li	a4,20
    80002c0c:	00f76f63          	bltu	a4,a5,80002c2a <syscall+0x44>
    80002c10:	00369713          	slli	a4,a3,0x3
    80002c14:	00005797          	auipc	a5,0x5
    80002c18:	7ac78793          	addi	a5,a5,1964 # 800083c0 <syscalls>
    80002c1c:	97ba                	add	a5,a5,a4
    80002c1e:	639c                	ld	a5,0(a5)
    80002c20:	c789                	beqz	a5,80002c2a <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002c22:	9782                	jalr	a5
    80002c24:	06a93823          	sd	a0,112(s2)
    80002c28:	a839                	j	80002c46 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c2a:	15848613          	addi	a2,s1,344
    80002c2e:	5c8c                	lw	a1,56(s1)
    80002c30:	00005517          	auipc	a0,0x5
    80002c34:	75850513          	addi	a0,a0,1880 # 80008388 <states.0+0x148>
    80002c38:	ffffe097          	auipc	ra,0xffffe
    80002c3c:	954080e7          	jalr	-1708(ra) # 8000058c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c40:	6cbc                	ld	a5,88(s1)
    80002c42:	577d                	li	a4,-1
    80002c44:	fbb8                	sd	a4,112(a5)
  }
}
    80002c46:	60e2                	ld	ra,24(sp)
    80002c48:	6442                	ld	s0,16(sp)
    80002c4a:	64a2                	ld	s1,8(sp)
    80002c4c:	6902                	ld	s2,0(sp)
    80002c4e:	6105                	addi	sp,sp,32
    80002c50:	8082                	ret

0000000080002c52 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c52:	1101                	addi	sp,sp,-32
    80002c54:	ec06                	sd	ra,24(sp)
    80002c56:	e822                	sd	s0,16(sp)
    80002c58:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c5a:	fec40593          	addi	a1,s0,-20
    80002c5e:	4501                	li	a0,0
    80002c60:	00000097          	auipc	ra,0x0
    80002c64:	f12080e7          	jalr	-238(ra) # 80002b72 <argint>
    return -1;
    80002c68:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c6a:	00054963          	bltz	a0,80002c7c <sys_exit+0x2a>
  exit(n);
    80002c6e:	fec42503          	lw	a0,-20(s0)
    80002c72:	fffff097          	auipc	ra,0xfffff
    80002c76:	4f0080e7          	jalr	1264(ra) # 80002162 <exit>
  return 0;  // not reached
    80002c7a:	4781                	li	a5,0
}
    80002c7c:	853e                	mv	a0,a5
    80002c7e:	60e2                	ld	ra,24(sp)
    80002c80:	6442                	ld	s0,16(sp)
    80002c82:	6105                	addi	sp,sp,32
    80002c84:	8082                	ret

0000000080002c86 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c86:	1141                	addi	sp,sp,-16
    80002c88:	e406                	sd	ra,8(sp)
    80002c8a:	e022                	sd	s0,0(sp)
    80002c8c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c8e:	fffff097          	auipc	ra,0xfffff
    80002c92:	e06080e7          	jalr	-506(ra) # 80001a94 <myproc>
}
    80002c96:	5d08                	lw	a0,56(a0)
    80002c98:	60a2                	ld	ra,8(sp)
    80002c9a:	6402                	ld	s0,0(sp)
    80002c9c:	0141                	addi	sp,sp,16
    80002c9e:	8082                	ret

0000000080002ca0 <sys_fork>:

uint64
sys_fork(void)
{
    80002ca0:	1141                	addi	sp,sp,-16
    80002ca2:	e406                	sd	ra,8(sp)
    80002ca4:	e022                	sd	s0,0(sp)
    80002ca6:	0800                	addi	s0,sp,16
  return fork();
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	1ac080e7          	jalr	428(ra) # 80001e54 <fork>
}
    80002cb0:	60a2                	ld	ra,8(sp)
    80002cb2:	6402                	ld	s0,0(sp)
    80002cb4:	0141                	addi	sp,sp,16
    80002cb6:	8082                	ret

0000000080002cb8 <sys_wait>:

uint64
sys_wait(void)
{
    80002cb8:	1101                	addi	sp,sp,-32
    80002cba:	ec06                	sd	ra,24(sp)
    80002cbc:	e822                	sd	s0,16(sp)
    80002cbe:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002cc0:	fe840593          	addi	a1,s0,-24
    80002cc4:	4501                	li	a0,0
    80002cc6:	00000097          	auipc	ra,0x0
    80002cca:	ece080e7          	jalr	-306(ra) # 80002b94 <argaddr>
    80002cce:	87aa                	mv	a5,a0
    return -1;
    80002cd0:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002cd2:	0007c863          	bltz	a5,80002ce2 <sys_wait+0x2a>
  return wait(p);
    80002cd6:	fe843503          	ld	a0,-24(s0)
    80002cda:	fffff097          	auipc	ra,0xfffff
    80002cde:	64c080e7          	jalr	1612(ra) # 80002326 <wait>
}
    80002ce2:	60e2                	ld	ra,24(sp)
    80002ce4:	6442                	ld	s0,16(sp)
    80002ce6:	6105                	addi	sp,sp,32
    80002ce8:	8082                	ret

0000000080002cea <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cea:	7179                	addi	sp,sp,-48
    80002cec:	f406                	sd	ra,40(sp)
    80002cee:	f022                	sd	s0,32(sp)
    80002cf0:	ec26                	sd	s1,24(sp)
    80002cf2:	e84a                	sd	s2,16(sp)
    80002cf4:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002cf6:	fdc40593          	addi	a1,s0,-36
    80002cfa:	4501                	li	a0,0
    80002cfc:	00000097          	auipc	ra,0x0
    80002d00:	e76080e7          	jalr	-394(ra) # 80002b72 <argint>
    return -1;
    80002d04:	597d                	li	s2,-1
  if(argint(0, &n) < 0)
    80002d06:	02054363          	bltz	a0,80002d2c <sys_sbrk+0x42>
  struct proc* p = myproc();
    80002d0a:	fffff097          	auipc	ra,0xfffff
    80002d0e:	d8a080e7          	jalr	-630(ra) # 80001a94 <myproc>
    80002d12:	84aa                	mv	s1,a0
  addr = p->sz;
    80002d14:	652c                	ld	a1,72(a0)
    80002d16:	0005891b          	sext.w	s2,a1
  
  if(n < 0) {
    80002d1a:	fdc42603          	lw	a2,-36(s0)
    80002d1e:	00064e63          	bltz	a2,80002d3a <sys_sbrk+0x50>
    uvmdealloc(p->pagetable, p->sz, p->sz + n);
  }
  p->sz += n;
    80002d22:	fdc42703          	lw	a4,-36(s0)
    80002d26:	64bc                	ld	a5,72(s1)
    80002d28:	97ba                	add	a5,a5,a4
    80002d2a:	e4bc                	sd	a5,72(s1)
  
  return addr;
}
    80002d2c:	854a                	mv	a0,s2
    80002d2e:	70a2                	ld	ra,40(sp)
    80002d30:	7402                	ld	s0,32(sp)
    80002d32:	64e2                	ld	s1,24(sp)
    80002d34:	6942                	ld	s2,16(sp)
    80002d36:	6145                	addi	sp,sp,48
    80002d38:	8082                	ret
    uvmdealloc(p->pagetable, p->sz, p->sz + n);
    80002d3a:	962e                	add	a2,a2,a1
    80002d3c:	6928                	ld	a0,80(a0)
    80002d3e:	ffffe097          	auipc	ra,0xffffe
    80002d42:	6c8080e7          	jalr	1736(ra) # 80001406 <uvmdealloc>
    80002d46:	bff1                	j	80002d22 <sys_sbrk+0x38>

0000000080002d48 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d48:	7139                	addi	sp,sp,-64
    80002d4a:	fc06                	sd	ra,56(sp)
    80002d4c:	f822                	sd	s0,48(sp)
    80002d4e:	f426                	sd	s1,40(sp)
    80002d50:	f04a                	sd	s2,32(sp)
    80002d52:	ec4e                	sd	s3,24(sp)
    80002d54:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d56:	fcc40593          	addi	a1,s0,-52
    80002d5a:	4501                	li	a0,0
    80002d5c:	00000097          	auipc	ra,0x0
    80002d60:	e16080e7          	jalr	-490(ra) # 80002b72 <argint>
    return -1;
    80002d64:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d66:	06054563          	bltz	a0,80002dd0 <sys_sleep+0x88>
  acquire(&tickslock);
    80002d6a:	00015517          	auipc	a0,0x15
    80002d6e:	9fe50513          	addi	a0,a0,-1538 # 80017768 <tickslock>
    80002d72:	ffffe097          	auipc	ra,0xffffe
    80002d76:	e8c080e7          	jalr	-372(ra) # 80000bfe <acquire>
  ticks0 = ticks;
    80002d7a:	00006917          	auipc	s2,0x6
    80002d7e:	2a692903          	lw	s2,678(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002d82:	fcc42783          	lw	a5,-52(s0)
    80002d86:	cf85                	beqz	a5,80002dbe <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d88:	00015997          	auipc	s3,0x15
    80002d8c:	9e098993          	addi	s3,s3,-1568 # 80017768 <tickslock>
    80002d90:	00006497          	auipc	s1,0x6
    80002d94:	29048493          	addi	s1,s1,656 # 80009020 <ticks>
    if(myproc()->killed){
    80002d98:	fffff097          	auipc	ra,0xfffff
    80002d9c:	cfc080e7          	jalr	-772(ra) # 80001a94 <myproc>
    80002da0:	591c                	lw	a5,48(a0)
    80002da2:	ef9d                	bnez	a5,80002de0 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002da4:	85ce                	mv	a1,s3
    80002da6:	8526                	mv	a0,s1
    80002da8:	fffff097          	auipc	ra,0xfffff
    80002dac:	500080e7          	jalr	1280(ra) # 800022a8 <sleep>
  while(ticks - ticks0 < n){
    80002db0:	409c                	lw	a5,0(s1)
    80002db2:	412787bb          	subw	a5,a5,s2
    80002db6:	fcc42703          	lw	a4,-52(s0)
    80002dba:	fce7efe3          	bltu	a5,a4,80002d98 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002dbe:	00015517          	auipc	a0,0x15
    80002dc2:	9aa50513          	addi	a0,a0,-1622 # 80017768 <tickslock>
    80002dc6:	ffffe097          	auipc	ra,0xffffe
    80002dca:	eec080e7          	jalr	-276(ra) # 80000cb2 <release>
  return 0;
    80002dce:	4781                	li	a5,0
}
    80002dd0:	853e                	mv	a0,a5
    80002dd2:	70e2                	ld	ra,56(sp)
    80002dd4:	7442                	ld	s0,48(sp)
    80002dd6:	74a2                	ld	s1,40(sp)
    80002dd8:	7902                	ld	s2,32(sp)
    80002dda:	69e2                	ld	s3,24(sp)
    80002ddc:	6121                	addi	sp,sp,64
    80002dde:	8082                	ret
      release(&tickslock);
    80002de0:	00015517          	auipc	a0,0x15
    80002de4:	98850513          	addi	a0,a0,-1656 # 80017768 <tickslock>
    80002de8:	ffffe097          	auipc	ra,0xffffe
    80002dec:	eca080e7          	jalr	-310(ra) # 80000cb2 <release>
      return -1;
    80002df0:	57fd                	li	a5,-1
    80002df2:	bff9                	j	80002dd0 <sys_sleep+0x88>

0000000080002df4 <sys_kill>:

uint64
sys_kill(void)
{
    80002df4:	1101                	addi	sp,sp,-32
    80002df6:	ec06                	sd	ra,24(sp)
    80002df8:	e822                	sd	s0,16(sp)
    80002dfa:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002dfc:	fec40593          	addi	a1,s0,-20
    80002e00:	4501                	li	a0,0
    80002e02:	00000097          	auipc	ra,0x0
    80002e06:	d70080e7          	jalr	-656(ra) # 80002b72 <argint>
    80002e0a:	87aa                	mv	a5,a0
    return -1;
    80002e0c:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002e0e:	0007c863          	bltz	a5,80002e1e <sys_kill+0x2a>
  return kill(pid);
    80002e12:	fec42503          	lw	a0,-20(s0)
    80002e16:	fffff097          	auipc	ra,0xfffff
    80002e1a:	67c080e7          	jalr	1660(ra) # 80002492 <kill>
}
    80002e1e:	60e2                	ld	ra,24(sp)
    80002e20:	6442                	ld	s0,16(sp)
    80002e22:	6105                	addi	sp,sp,32
    80002e24:	8082                	ret

0000000080002e26 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e26:	1101                	addi	sp,sp,-32
    80002e28:	ec06                	sd	ra,24(sp)
    80002e2a:	e822                	sd	s0,16(sp)
    80002e2c:	e426                	sd	s1,8(sp)
    80002e2e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e30:	00015517          	auipc	a0,0x15
    80002e34:	93850513          	addi	a0,a0,-1736 # 80017768 <tickslock>
    80002e38:	ffffe097          	auipc	ra,0xffffe
    80002e3c:	dc6080e7          	jalr	-570(ra) # 80000bfe <acquire>
  xticks = ticks;
    80002e40:	00006497          	auipc	s1,0x6
    80002e44:	1e04a483          	lw	s1,480(s1) # 80009020 <ticks>
  release(&tickslock);
    80002e48:	00015517          	auipc	a0,0x15
    80002e4c:	92050513          	addi	a0,a0,-1760 # 80017768 <tickslock>
    80002e50:	ffffe097          	auipc	ra,0xffffe
    80002e54:	e62080e7          	jalr	-414(ra) # 80000cb2 <release>
  return xticks;
}
    80002e58:	02049513          	slli	a0,s1,0x20
    80002e5c:	9101                	srli	a0,a0,0x20
    80002e5e:	60e2                	ld	ra,24(sp)
    80002e60:	6442                	ld	s0,16(sp)
    80002e62:	64a2                	ld	s1,8(sp)
    80002e64:	6105                	addi	sp,sp,32
    80002e66:	8082                	ret

0000000080002e68 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e68:	7179                	addi	sp,sp,-48
    80002e6a:	f406                	sd	ra,40(sp)
    80002e6c:	f022                	sd	s0,32(sp)
    80002e6e:	ec26                	sd	s1,24(sp)
    80002e70:	e84a                	sd	s2,16(sp)
    80002e72:	e44e                	sd	s3,8(sp)
    80002e74:	e052                	sd	s4,0(sp)
    80002e76:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e78:	00005597          	auipc	a1,0x5
    80002e7c:	5f858593          	addi	a1,a1,1528 # 80008470 <syscalls+0xb0>
    80002e80:	00015517          	auipc	a0,0x15
    80002e84:	90050513          	addi	a0,a0,-1792 # 80017780 <bcache>
    80002e88:	ffffe097          	auipc	ra,0xffffe
    80002e8c:	ce6080e7          	jalr	-794(ra) # 80000b6e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e90:	0001d797          	auipc	a5,0x1d
    80002e94:	8f078793          	addi	a5,a5,-1808 # 8001f780 <bcache+0x8000>
    80002e98:	0001d717          	auipc	a4,0x1d
    80002e9c:	b5070713          	addi	a4,a4,-1200 # 8001f9e8 <bcache+0x8268>
    80002ea0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ea4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ea8:	00015497          	auipc	s1,0x15
    80002eac:	8f048493          	addi	s1,s1,-1808 # 80017798 <bcache+0x18>
    b->next = bcache.head.next;
    80002eb0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002eb2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002eb4:	00005a17          	auipc	s4,0x5
    80002eb8:	5c4a0a13          	addi	s4,s4,1476 # 80008478 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002ebc:	2b893783          	ld	a5,696(s2)
    80002ec0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ec2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ec6:	85d2                	mv	a1,s4
    80002ec8:	01048513          	addi	a0,s1,16
    80002ecc:	00001097          	auipc	ra,0x1
    80002ed0:	4b0080e7          	jalr	1200(ra) # 8000437c <initsleeplock>
    bcache.head.next->prev = b;
    80002ed4:	2b893783          	ld	a5,696(s2)
    80002ed8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002eda:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ede:	45848493          	addi	s1,s1,1112
    80002ee2:	fd349de3          	bne	s1,s3,80002ebc <binit+0x54>
  }
}
    80002ee6:	70a2                	ld	ra,40(sp)
    80002ee8:	7402                	ld	s0,32(sp)
    80002eea:	64e2                	ld	s1,24(sp)
    80002eec:	6942                	ld	s2,16(sp)
    80002eee:	69a2                	ld	s3,8(sp)
    80002ef0:	6a02                	ld	s4,0(sp)
    80002ef2:	6145                	addi	sp,sp,48
    80002ef4:	8082                	ret

0000000080002ef6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ef6:	7179                	addi	sp,sp,-48
    80002ef8:	f406                	sd	ra,40(sp)
    80002efa:	f022                	sd	s0,32(sp)
    80002efc:	ec26                	sd	s1,24(sp)
    80002efe:	e84a                	sd	s2,16(sp)
    80002f00:	e44e                	sd	s3,8(sp)
    80002f02:	1800                	addi	s0,sp,48
    80002f04:	892a                	mv	s2,a0
    80002f06:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f08:	00015517          	auipc	a0,0x15
    80002f0c:	87850513          	addi	a0,a0,-1928 # 80017780 <bcache>
    80002f10:	ffffe097          	auipc	ra,0xffffe
    80002f14:	cee080e7          	jalr	-786(ra) # 80000bfe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f18:	0001d497          	auipc	s1,0x1d
    80002f1c:	b204b483          	ld	s1,-1248(s1) # 8001fa38 <bcache+0x82b8>
    80002f20:	0001d797          	auipc	a5,0x1d
    80002f24:	ac878793          	addi	a5,a5,-1336 # 8001f9e8 <bcache+0x8268>
    80002f28:	02f48f63          	beq	s1,a5,80002f66 <bread+0x70>
    80002f2c:	873e                	mv	a4,a5
    80002f2e:	a021                	j	80002f36 <bread+0x40>
    80002f30:	68a4                	ld	s1,80(s1)
    80002f32:	02e48a63          	beq	s1,a4,80002f66 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f36:	449c                	lw	a5,8(s1)
    80002f38:	ff279ce3          	bne	a5,s2,80002f30 <bread+0x3a>
    80002f3c:	44dc                	lw	a5,12(s1)
    80002f3e:	ff3799e3          	bne	a5,s3,80002f30 <bread+0x3a>
      b->refcnt++;
    80002f42:	40bc                	lw	a5,64(s1)
    80002f44:	2785                	addiw	a5,a5,1
    80002f46:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f48:	00015517          	auipc	a0,0x15
    80002f4c:	83850513          	addi	a0,a0,-1992 # 80017780 <bcache>
    80002f50:	ffffe097          	auipc	ra,0xffffe
    80002f54:	d62080e7          	jalr	-670(ra) # 80000cb2 <release>
      acquiresleep(&b->lock);
    80002f58:	01048513          	addi	a0,s1,16
    80002f5c:	00001097          	auipc	ra,0x1
    80002f60:	45a080e7          	jalr	1114(ra) # 800043b6 <acquiresleep>
      return b;
    80002f64:	a8b9                	j	80002fc2 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f66:	0001d497          	auipc	s1,0x1d
    80002f6a:	aca4b483          	ld	s1,-1334(s1) # 8001fa30 <bcache+0x82b0>
    80002f6e:	0001d797          	auipc	a5,0x1d
    80002f72:	a7a78793          	addi	a5,a5,-1414 # 8001f9e8 <bcache+0x8268>
    80002f76:	00f48863          	beq	s1,a5,80002f86 <bread+0x90>
    80002f7a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f7c:	40bc                	lw	a5,64(s1)
    80002f7e:	cf81                	beqz	a5,80002f96 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f80:	64a4                	ld	s1,72(s1)
    80002f82:	fee49de3          	bne	s1,a4,80002f7c <bread+0x86>
  panic("bget: no buffers");
    80002f86:	00005517          	auipc	a0,0x5
    80002f8a:	4fa50513          	addi	a0,a0,1274 # 80008480 <syscalls+0xc0>
    80002f8e:	ffffd097          	auipc	ra,0xffffd
    80002f92:	5b4080e7          	jalr	1460(ra) # 80000542 <panic>
      b->dev = dev;
    80002f96:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f9a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f9e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fa2:	4785                	li	a5,1
    80002fa4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fa6:	00014517          	auipc	a0,0x14
    80002faa:	7da50513          	addi	a0,a0,2010 # 80017780 <bcache>
    80002fae:	ffffe097          	auipc	ra,0xffffe
    80002fb2:	d04080e7          	jalr	-764(ra) # 80000cb2 <release>
      acquiresleep(&b->lock);
    80002fb6:	01048513          	addi	a0,s1,16
    80002fba:	00001097          	auipc	ra,0x1
    80002fbe:	3fc080e7          	jalr	1020(ra) # 800043b6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002fc2:	409c                	lw	a5,0(s1)
    80002fc4:	cb89                	beqz	a5,80002fd6 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002fc6:	8526                	mv	a0,s1
    80002fc8:	70a2                	ld	ra,40(sp)
    80002fca:	7402                	ld	s0,32(sp)
    80002fcc:	64e2                	ld	s1,24(sp)
    80002fce:	6942                	ld	s2,16(sp)
    80002fd0:	69a2                	ld	s3,8(sp)
    80002fd2:	6145                	addi	sp,sp,48
    80002fd4:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fd6:	4581                	li	a1,0
    80002fd8:	8526                	mv	a0,s1
    80002fda:	00003097          	auipc	ra,0x3
    80002fde:	052080e7          	jalr	82(ra) # 8000602c <virtio_disk_rw>
    b->valid = 1;
    80002fe2:	4785                	li	a5,1
    80002fe4:	c09c                	sw	a5,0(s1)
  return b;
    80002fe6:	b7c5                	j	80002fc6 <bread+0xd0>

0000000080002fe8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fe8:	1101                	addi	sp,sp,-32
    80002fea:	ec06                	sd	ra,24(sp)
    80002fec:	e822                	sd	s0,16(sp)
    80002fee:	e426                	sd	s1,8(sp)
    80002ff0:	1000                	addi	s0,sp,32
    80002ff2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ff4:	0541                	addi	a0,a0,16
    80002ff6:	00001097          	auipc	ra,0x1
    80002ffa:	45a080e7          	jalr	1114(ra) # 80004450 <holdingsleep>
    80002ffe:	cd01                	beqz	a0,80003016 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003000:	4585                	li	a1,1
    80003002:	8526                	mv	a0,s1
    80003004:	00003097          	auipc	ra,0x3
    80003008:	028080e7          	jalr	40(ra) # 8000602c <virtio_disk_rw>
}
    8000300c:	60e2                	ld	ra,24(sp)
    8000300e:	6442                	ld	s0,16(sp)
    80003010:	64a2                	ld	s1,8(sp)
    80003012:	6105                	addi	sp,sp,32
    80003014:	8082                	ret
    panic("bwrite");
    80003016:	00005517          	auipc	a0,0x5
    8000301a:	48250513          	addi	a0,a0,1154 # 80008498 <syscalls+0xd8>
    8000301e:	ffffd097          	auipc	ra,0xffffd
    80003022:	524080e7          	jalr	1316(ra) # 80000542 <panic>

0000000080003026 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003026:	1101                	addi	sp,sp,-32
    80003028:	ec06                	sd	ra,24(sp)
    8000302a:	e822                	sd	s0,16(sp)
    8000302c:	e426                	sd	s1,8(sp)
    8000302e:	e04a                	sd	s2,0(sp)
    80003030:	1000                	addi	s0,sp,32
    80003032:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003034:	01050913          	addi	s2,a0,16
    80003038:	854a                	mv	a0,s2
    8000303a:	00001097          	auipc	ra,0x1
    8000303e:	416080e7          	jalr	1046(ra) # 80004450 <holdingsleep>
    80003042:	c92d                	beqz	a0,800030b4 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003044:	854a                	mv	a0,s2
    80003046:	00001097          	auipc	ra,0x1
    8000304a:	3c6080e7          	jalr	966(ra) # 8000440c <releasesleep>

  acquire(&bcache.lock);
    8000304e:	00014517          	auipc	a0,0x14
    80003052:	73250513          	addi	a0,a0,1842 # 80017780 <bcache>
    80003056:	ffffe097          	auipc	ra,0xffffe
    8000305a:	ba8080e7          	jalr	-1112(ra) # 80000bfe <acquire>
  b->refcnt--;
    8000305e:	40bc                	lw	a5,64(s1)
    80003060:	37fd                	addiw	a5,a5,-1
    80003062:	0007871b          	sext.w	a4,a5
    80003066:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003068:	eb05                	bnez	a4,80003098 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000306a:	68bc                	ld	a5,80(s1)
    8000306c:	64b8                	ld	a4,72(s1)
    8000306e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003070:	64bc                	ld	a5,72(s1)
    80003072:	68b8                	ld	a4,80(s1)
    80003074:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003076:	0001c797          	auipc	a5,0x1c
    8000307a:	70a78793          	addi	a5,a5,1802 # 8001f780 <bcache+0x8000>
    8000307e:	2b87b703          	ld	a4,696(a5)
    80003082:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003084:	0001d717          	auipc	a4,0x1d
    80003088:	96470713          	addi	a4,a4,-1692 # 8001f9e8 <bcache+0x8268>
    8000308c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000308e:	2b87b703          	ld	a4,696(a5)
    80003092:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003094:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003098:	00014517          	auipc	a0,0x14
    8000309c:	6e850513          	addi	a0,a0,1768 # 80017780 <bcache>
    800030a0:	ffffe097          	auipc	ra,0xffffe
    800030a4:	c12080e7          	jalr	-1006(ra) # 80000cb2 <release>
}
    800030a8:	60e2                	ld	ra,24(sp)
    800030aa:	6442                	ld	s0,16(sp)
    800030ac:	64a2                	ld	s1,8(sp)
    800030ae:	6902                	ld	s2,0(sp)
    800030b0:	6105                	addi	sp,sp,32
    800030b2:	8082                	ret
    panic("brelse");
    800030b4:	00005517          	auipc	a0,0x5
    800030b8:	3ec50513          	addi	a0,a0,1004 # 800084a0 <syscalls+0xe0>
    800030bc:	ffffd097          	auipc	ra,0xffffd
    800030c0:	486080e7          	jalr	1158(ra) # 80000542 <panic>

00000000800030c4 <bpin>:

void
bpin(struct buf *b) {
    800030c4:	1101                	addi	sp,sp,-32
    800030c6:	ec06                	sd	ra,24(sp)
    800030c8:	e822                	sd	s0,16(sp)
    800030ca:	e426                	sd	s1,8(sp)
    800030cc:	1000                	addi	s0,sp,32
    800030ce:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030d0:	00014517          	auipc	a0,0x14
    800030d4:	6b050513          	addi	a0,a0,1712 # 80017780 <bcache>
    800030d8:	ffffe097          	auipc	ra,0xffffe
    800030dc:	b26080e7          	jalr	-1242(ra) # 80000bfe <acquire>
  b->refcnt++;
    800030e0:	40bc                	lw	a5,64(s1)
    800030e2:	2785                	addiw	a5,a5,1
    800030e4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030e6:	00014517          	auipc	a0,0x14
    800030ea:	69a50513          	addi	a0,a0,1690 # 80017780 <bcache>
    800030ee:	ffffe097          	auipc	ra,0xffffe
    800030f2:	bc4080e7          	jalr	-1084(ra) # 80000cb2 <release>
}
    800030f6:	60e2                	ld	ra,24(sp)
    800030f8:	6442                	ld	s0,16(sp)
    800030fa:	64a2                	ld	s1,8(sp)
    800030fc:	6105                	addi	sp,sp,32
    800030fe:	8082                	ret

0000000080003100 <bunpin>:

void
bunpin(struct buf *b) {
    80003100:	1101                	addi	sp,sp,-32
    80003102:	ec06                	sd	ra,24(sp)
    80003104:	e822                	sd	s0,16(sp)
    80003106:	e426                	sd	s1,8(sp)
    80003108:	1000                	addi	s0,sp,32
    8000310a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000310c:	00014517          	auipc	a0,0x14
    80003110:	67450513          	addi	a0,a0,1652 # 80017780 <bcache>
    80003114:	ffffe097          	auipc	ra,0xffffe
    80003118:	aea080e7          	jalr	-1302(ra) # 80000bfe <acquire>
  b->refcnt--;
    8000311c:	40bc                	lw	a5,64(s1)
    8000311e:	37fd                	addiw	a5,a5,-1
    80003120:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003122:	00014517          	auipc	a0,0x14
    80003126:	65e50513          	addi	a0,a0,1630 # 80017780 <bcache>
    8000312a:	ffffe097          	auipc	ra,0xffffe
    8000312e:	b88080e7          	jalr	-1144(ra) # 80000cb2 <release>
}
    80003132:	60e2                	ld	ra,24(sp)
    80003134:	6442                	ld	s0,16(sp)
    80003136:	64a2                	ld	s1,8(sp)
    80003138:	6105                	addi	sp,sp,32
    8000313a:	8082                	ret

000000008000313c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000313c:	1101                	addi	sp,sp,-32
    8000313e:	ec06                	sd	ra,24(sp)
    80003140:	e822                	sd	s0,16(sp)
    80003142:	e426                	sd	s1,8(sp)
    80003144:	e04a                	sd	s2,0(sp)
    80003146:	1000                	addi	s0,sp,32
    80003148:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000314a:	00d5d59b          	srliw	a1,a1,0xd
    8000314e:	0001d797          	auipc	a5,0x1d
    80003152:	d0e7a783          	lw	a5,-754(a5) # 8001fe5c <sb+0x1c>
    80003156:	9dbd                	addw	a1,a1,a5
    80003158:	00000097          	auipc	ra,0x0
    8000315c:	d9e080e7          	jalr	-610(ra) # 80002ef6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003160:	0074f713          	andi	a4,s1,7
    80003164:	4785                	li	a5,1
    80003166:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000316a:	14ce                	slli	s1,s1,0x33
    8000316c:	90d9                	srli	s1,s1,0x36
    8000316e:	00950733          	add	a4,a0,s1
    80003172:	05874703          	lbu	a4,88(a4)
    80003176:	00e7f6b3          	and	a3,a5,a4
    8000317a:	c69d                	beqz	a3,800031a8 <bfree+0x6c>
    8000317c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000317e:	94aa                	add	s1,s1,a0
    80003180:	fff7c793          	not	a5,a5
    80003184:	8ff9                	and	a5,a5,a4
    80003186:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000318a:	00001097          	auipc	ra,0x1
    8000318e:	104080e7          	jalr	260(ra) # 8000428e <log_write>
  brelse(bp);
    80003192:	854a                	mv	a0,s2
    80003194:	00000097          	auipc	ra,0x0
    80003198:	e92080e7          	jalr	-366(ra) # 80003026 <brelse>
}
    8000319c:	60e2                	ld	ra,24(sp)
    8000319e:	6442                	ld	s0,16(sp)
    800031a0:	64a2                	ld	s1,8(sp)
    800031a2:	6902                	ld	s2,0(sp)
    800031a4:	6105                	addi	sp,sp,32
    800031a6:	8082                	ret
    panic("freeing free block");
    800031a8:	00005517          	auipc	a0,0x5
    800031ac:	30050513          	addi	a0,a0,768 # 800084a8 <syscalls+0xe8>
    800031b0:	ffffd097          	auipc	ra,0xffffd
    800031b4:	392080e7          	jalr	914(ra) # 80000542 <panic>

00000000800031b8 <balloc>:
{
    800031b8:	711d                	addi	sp,sp,-96
    800031ba:	ec86                	sd	ra,88(sp)
    800031bc:	e8a2                	sd	s0,80(sp)
    800031be:	e4a6                	sd	s1,72(sp)
    800031c0:	e0ca                	sd	s2,64(sp)
    800031c2:	fc4e                	sd	s3,56(sp)
    800031c4:	f852                	sd	s4,48(sp)
    800031c6:	f456                	sd	s5,40(sp)
    800031c8:	f05a                	sd	s6,32(sp)
    800031ca:	ec5e                	sd	s7,24(sp)
    800031cc:	e862                	sd	s8,16(sp)
    800031ce:	e466                	sd	s9,8(sp)
    800031d0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031d2:	0001d797          	auipc	a5,0x1d
    800031d6:	c727a783          	lw	a5,-910(a5) # 8001fe44 <sb+0x4>
    800031da:	cbd1                	beqz	a5,8000326e <balloc+0xb6>
    800031dc:	8baa                	mv	s7,a0
    800031de:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031e0:	0001db17          	auipc	s6,0x1d
    800031e4:	c60b0b13          	addi	s6,s6,-928 # 8001fe40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031e8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031ea:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031ec:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031ee:	6c89                	lui	s9,0x2
    800031f0:	a831                	j	8000320c <balloc+0x54>
    brelse(bp);
    800031f2:	854a                	mv	a0,s2
    800031f4:	00000097          	auipc	ra,0x0
    800031f8:	e32080e7          	jalr	-462(ra) # 80003026 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031fc:	015c87bb          	addw	a5,s9,s5
    80003200:	00078a9b          	sext.w	s5,a5
    80003204:	004b2703          	lw	a4,4(s6)
    80003208:	06eaf363          	bgeu	s5,a4,8000326e <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000320c:	41fad79b          	sraiw	a5,s5,0x1f
    80003210:	0137d79b          	srliw	a5,a5,0x13
    80003214:	015787bb          	addw	a5,a5,s5
    80003218:	40d7d79b          	sraiw	a5,a5,0xd
    8000321c:	01cb2583          	lw	a1,28(s6)
    80003220:	9dbd                	addw	a1,a1,a5
    80003222:	855e                	mv	a0,s7
    80003224:	00000097          	auipc	ra,0x0
    80003228:	cd2080e7          	jalr	-814(ra) # 80002ef6 <bread>
    8000322c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000322e:	004b2503          	lw	a0,4(s6)
    80003232:	000a849b          	sext.w	s1,s5
    80003236:	8662                	mv	a2,s8
    80003238:	faa4fde3          	bgeu	s1,a0,800031f2 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000323c:	41f6579b          	sraiw	a5,a2,0x1f
    80003240:	01d7d69b          	srliw	a3,a5,0x1d
    80003244:	00c6873b          	addw	a4,a3,a2
    80003248:	00777793          	andi	a5,a4,7
    8000324c:	9f95                	subw	a5,a5,a3
    8000324e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003252:	4037571b          	sraiw	a4,a4,0x3
    80003256:	00e906b3          	add	a3,s2,a4
    8000325a:	0586c683          	lbu	a3,88(a3)
    8000325e:	00d7f5b3          	and	a1,a5,a3
    80003262:	cd91                	beqz	a1,8000327e <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003264:	2605                	addiw	a2,a2,1
    80003266:	2485                	addiw	s1,s1,1
    80003268:	fd4618e3          	bne	a2,s4,80003238 <balloc+0x80>
    8000326c:	b759                	j	800031f2 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000326e:	00005517          	auipc	a0,0x5
    80003272:	25250513          	addi	a0,a0,594 # 800084c0 <syscalls+0x100>
    80003276:	ffffd097          	auipc	ra,0xffffd
    8000327a:	2cc080e7          	jalr	716(ra) # 80000542 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000327e:	974a                	add	a4,a4,s2
    80003280:	8fd5                	or	a5,a5,a3
    80003282:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003286:	854a                	mv	a0,s2
    80003288:	00001097          	auipc	ra,0x1
    8000328c:	006080e7          	jalr	6(ra) # 8000428e <log_write>
        brelse(bp);
    80003290:	854a                	mv	a0,s2
    80003292:	00000097          	auipc	ra,0x0
    80003296:	d94080e7          	jalr	-620(ra) # 80003026 <brelse>
  bp = bread(dev, bno);
    8000329a:	85a6                	mv	a1,s1
    8000329c:	855e                	mv	a0,s7
    8000329e:	00000097          	auipc	ra,0x0
    800032a2:	c58080e7          	jalr	-936(ra) # 80002ef6 <bread>
    800032a6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032a8:	40000613          	li	a2,1024
    800032ac:	4581                	li	a1,0
    800032ae:	05850513          	addi	a0,a0,88
    800032b2:	ffffe097          	auipc	ra,0xffffe
    800032b6:	a48080e7          	jalr	-1464(ra) # 80000cfa <memset>
  log_write(bp);
    800032ba:	854a                	mv	a0,s2
    800032bc:	00001097          	auipc	ra,0x1
    800032c0:	fd2080e7          	jalr	-46(ra) # 8000428e <log_write>
  brelse(bp);
    800032c4:	854a                	mv	a0,s2
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	d60080e7          	jalr	-672(ra) # 80003026 <brelse>
}
    800032ce:	8526                	mv	a0,s1
    800032d0:	60e6                	ld	ra,88(sp)
    800032d2:	6446                	ld	s0,80(sp)
    800032d4:	64a6                	ld	s1,72(sp)
    800032d6:	6906                	ld	s2,64(sp)
    800032d8:	79e2                	ld	s3,56(sp)
    800032da:	7a42                	ld	s4,48(sp)
    800032dc:	7aa2                	ld	s5,40(sp)
    800032de:	7b02                	ld	s6,32(sp)
    800032e0:	6be2                	ld	s7,24(sp)
    800032e2:	6c42                	ld	s8,16(sp)
    800032e4:	6ca2                	ld	s9,8(sp)
    800032e6:	6125                	addi	sp,sp,96
    800032e8:	8082                	ret

00000000800032ea <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800032ea:	7179                	addi	sp,sp,-48
    800032ec:	f406                	sd	ra,40(sp)
    800032ee:	f022                	sd	s0,32(sp)
    800032f0:	ec26                	sd	s1,24(sp)
    800032f2:	e84a                	sd	s2,16(sp)
    800032f4:	e44e                	sd	s3,8(sp)
    800032f6:	e052                	sd	s4,0(sp)
    800032f8:	1800                	addi	s0,sp,48
    800032fa:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032fc:	47ad                	li	a5,11
    800032fe:	04b7fe63          	bgeu	a5,a1,8000335a <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003302:	ff45849b          	addiw	s1,a1,-12
    80003306:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000330a:	0ff00793          	li	a5,255
    8000330e:	0ae7e363          	bltu	a5,a4,800033b4 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003312:	08052583          	lw	a1,128(a0)
    80003316:	c5ad                	beqz	a1,80003380 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003318:	00092503          	lw	a0,0(s2)
    8000331c:	00000097          	auipc	ra,0x0
    80003320:	bda080e7          	jalr	-1062(ra) # 80002ef6 <bread>
    80003324:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003326:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000332a:	02049593          	slli	a1,s1,0x20
    8000332e:	9181                	srli	a1,a1,0x20
    80003330:	058a                	slli	a1,a1,0x2
    80003332:	00b784b3          	add	s1,a5,a1
    80003336:	0004a983          	lw	s3,0(s1)
    8000333a:	04098d63          	beqz	s3,80003394 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000333e:	8552                	mv	a0,s4
    80003340:	00000097          	auipc	ra,0x0
    80003344:	ce6080e7          	jalr	-794(ra) # 80003026 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003348:	854e                	mv	a0,s3
    8000334a:	70a2                	ld	ra,40(sp)
    8000334c:	7402                	ld	s0,32(sp)
    8000334e:	64e2                	ld	s1,24(sp)
    80003350:	6942                	ld	s2,16(sp)
    80003352:	69a2                	ld	s3,8(sp)
    80003354:	6a02                	ld	s4,0(sp)
    80003356:	6145                	addi	sp,sp,48
    80003358:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000335a:	02059493          	slli	s1,a1,0x20
    8000335e:	9081                	srli	s1,s1,0x20
    80003360:	048a                	slli	s1,s1,0x2
    80003362:	94aa                	add	s1,s1,a0
    80003364:	0504a983          	lw	s3,80(s1)
    80003368:	fe0990e3          	bnez	s3,80003348 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000336c:	4108                	lw	a0,0(a0)
    8000336e:	00000097          	auipc	ra,0x0
    80003372:	e4a080e7          	jalr	-438(ra) # 800031b8 <balloc>
    80003376:	0005099b          	sext.w	s3,a0
    8000337a:	0534a823          	sw	s3,80(s1)
    8000337e:	b7e9                	j	80003348 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003380:	4108                	lw	a0,0(a0)
    80003382:	00000097          	auipc	ra,0x0
    80003386:	e36080e7          	jalr	-458(ra) # 800031b8 <balloc>
    8000338a:	0005059b          	sext.w	a1,a0
    8000338e:	08b92023          	sw	a1,128(s2)
    80003392:	b759                	j	80003318 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003394:	00092503          	lw	a0,0(s2)
    80003398:	00000097          	auipc	ra,0x0
    8000339c:	e20080e7          	jalr	-480(ra) # 800031b8 <balloc>
    800033a0:	0005099b          	sext.w	s3,a0
    800033a4:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800033a8:	8552                	mv	a0,s4
    800033aa:	00001097          	auipc	ra,0x1
    800033ae:	ee4080e7          	jalr	-284(ra) # 8000428e <log_write>
    800033b2:	b771                	j	8000333e <bmap+0x54>
  panic("bmap: out of range");
    800033b4:	00005517          	auipc	a0,0x5
    800033b8:	12450513          	addi	a0,a0,292 # 800084d8 <syscalls+0x118>
    800033bc:	ffffd097          	auipc	ra,0xffffd
    800033c0:	186080e7          	jalr	390(ra) # 80000542 <panic>

00000000800033c4 <iget>:
{
    800033c4:	7179                	addi	sp,sp,-48
    800033c6:	f406                	sd	ra,40(sp)
    800033c8:	f022                	sd	s0,32(sp)
    800033ca:	ec26                	sd	s1,24(sp)
    800033cc:	e84a                	sd	s2,16(sp)
    800033ce:	e44e                	sd	s3,8(sp)
    800033d0:	e052                	sd	s4,0(sp)
    800033d2:	1800                	addi	s0,sp,48
    800033d4:	89aa                	mv	s3,a0
    800033d6:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800033d8:	0001d517          	auipc	a0,0x1d
    800033dc:	a8850513          	addi	a0,a0,-1400 # 8001fe60 <icache>
    800033e0:	ffffe097          	auipc	ra,0xffffe
    800033e4:	81e080e7          	jalr	-2018(ra) # 80000bfe <acquire>
  empty = 0;
    800033e8:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800033ea:	0001d497          	auipc	s1,0x1d
    800033ee:	a8e48493          	addi	s1,s1,-1394 # 8001fe78 <icache+0x18>
    800033f2:	0001e697          	auipc	a3,0x1e
    800033f6:	51668693          	addi	a3,a3,1302 # 80021908 <log>
    800033fa:	a039                	j	80003408 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033fc:	02090b63          	beqz	s2,80003432 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003400:	08848493          	addi	s1,s1,136
    80003404:	02d48a63          	beq	s1,a3,80003438 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003408:	449c                	lw	a5,8(s1)
    8000340a:	fef059e3          	blez	a5,800033fc <iget+0x38>
    8000340e:	4098                	lw	a4,0(s1)
    80003410:	ff3716e3          	bne	a4,s3,800033fc <iget+0x38>
    80003414:	40d8                	lw	a4,4(s1)
    80003416:	ff4713e3          	bne	a4,s4,800033fc <iget+0x38>
      ip->ref++;
    8000341a:	2785                	addiw	a5,a5,1
    8000341c:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000341e:	0001d517          	auipc	a0,0x1d
    80003422:	a4250513          	addi	a0,a0,-1470 # 8001fe60 <icache>
    80003426:	ffffe097          	auipc	ra,0xffffe
    8000342a:	88c080e7          	jalr	-1908(ra) # 80000cb2 <release>
      return ip;
    8000342e:	8926                	mv	s2,s1
    80003430:	a03d                	j	8000345e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003432:	f7f9                	bnez	a5,80003400 <iget+0x3c>
    80003434:	8926                	mv	s2,s1
    80003436:	b7e9                	j	80003400 <iget+0x3c>
  if(empty == 0)
    80003438:	02090c63          	beqz	s2,80003470 <iget+0xac>
  ip->dev = dev;
    8000343c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003440:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003444:	4785                	li	a5,1
    80003446:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000344a:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    8000344e:	0001d517          	auipc	a0,0x1d
    80003452:	a1250513          	addi	a0,a0,-1518 # 8001fe60 <icache>
    80003456:	ffffe097          	auipc	ra,0xffffe
    8000345a:	85c080e7          	jalr	-1956(ra) # 80000cb2 <release>
}
    8000345e:	854a                	mv	a0,s2
    80003460:	70a2                	ld	ra,40(sp)
    80003462:	7402                	ld	s0,32(sp)
    80003464:	64e2                	ld	s1,24(sp)
    80003466:	6942                	ld	s2,16(sp)
    80003468:	69a2                	ld	s3,8(sp)
    8000346a:	6a02                	ld	s4,0(sp)
    8000346c:	6145                	addi	sp,sp,48
    8000346e:	8082                	ret
    panic("iget: no inodes");
    80003470:	00005517          	auipc	a0,0x5
    80003474:	08050513          	addi	a0,a0,128 # 800084f0 <syscalls+0x130>
    80003478:	ffffd097          	auipc	ra,0xffffd
    8000347c:	0ca080e7          	jalr	202(ra) # 80000542 <panic>

0000000080003480 <fsinit>:
fsinit(int dev) {
    80003480:	7179                	addi	sp,sp,-48
    80003482:	f406                	sd	ra,40(sp)
    80003484:	f022                	sd	s0,32(sp)
    80003486:	ec26                	sd	s1,24(sp)
    80003488:	e84a                	sd	s2,16(sp)
    8000348a:	e44e                	sd	s3,8(sp)
    8000348c:	1800                	addi	s0,sp,48
    8000348e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003490:	4585                	li	a1,1
    80003492:	00000097          	auipc	ra,0x0
    80003496:	a64080e7          	jalr	-1436(ra) # 80002ef6 <bread>
    8000349a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000349c:	0001d997          	auipc	s3,0x1d
    800034a0:	9a498993          	addi	s3,s3,-1628 # 8001fe40 <sb>
    800034a4:	02000613          	li	a2,32
    800034a8:	05850593          	addi	a1,a0,88
    800034ac:	854e                	mv	a0,s3
    800034ae:	ffffe097          	auipc	ra,0xffffe
    800034b2:	8a8080e7          	jalr	-1880(ra) # 80000d56 <memmove>
  brelse(bp);
    800034b6:	8526                	mv	a0,s1
    800034b8:	00000097          	auipc	ra,0x0
    800034bc:	b6e080e7          	jalr	-1170(ra) # 80003026 <brelse>
  if(sb.magic != FSMAGIC)
    800034c0:	0009a703          	lw	a4,0(s3)
    800034c4:	102037b7          	lui	a5,0x10203
    800034c8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034cc:	02f71263          	bne	a4,a5,800034f0 <fsinit+0x70>
  initlog(dev, &sb);
    800034d0:	0001d597          	auipc	a1,0x1d
    800034d4:	97058593          	addi	a1,a1,-1680 # 8001fe40 <sb>
    800034d8:	854a                	mv	a0,s2
    800034da:	00001097          	auipc	ra,0x1
    800034de:	b3c080e7          	jalr	-1220(ra) # 80004016 <initlog>
}
    800034e2:	70a2                	ld	ra,40(sp)
    800034e4:	7402                	ld	s0,32(sp)
    800034e6:	64e2                	ld	s1,24(sp)
    800034e8:	6942                	ld	s2,16(sp)
    800034ea:	69a2                	ld	s3,8(sp)
    800034ec:	6145                	addi	sp,sp,48
    800034ee:	8082                	ret
    panic("invalid file system");
    800034f0:	00005517          	auipc	a0,0x5
    800034f4:	01050513          	addi	a0,a0,16 # 80008500 <syscalls+0x140>
    800034f8:	ffffd097          	auipc	ra,0xffffd
    800034fc:	04a080e7          	jalr	74(ra) # 80000542 <panic>

0000000080003500 <iinit>:
{
    80003500:	7179                	addi	sp,sp,-48
    80003502:	f406                	sd	ra,40(sp)
    80003504:	f022                	sd	s0,32(sp)
    80003506:	ec26                	sd	s1,24(sp)
    80003508:	e84a                	sd	s2,16(sp)
    8000350a:	e44e                	sd	s3,8(sp)
    8000350c:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000350e:	00005597          	auipc	a1,0x5
    80003512:	00a58593          	addi	a1,a1,10 # 80008518 <syscalls+0x158>
    80003516:	0001d517          	auipc	a0,0x1d
    8000351a:	94a50513          	addi	a0,a0,-1718 # 8001fe60 <icache>
    8000351e:	ffffd097          	auipc	ra,0xffffd
    80003522:	650080e7          	jalr	1616(ra) # 80000b6e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003526:	0001d497          	auipc	s1,0x1d
    8000352a:	96248493          	addi	s1,s1,-1694 # 8001fe88 <icache+0x28>
    8000352e:	0001e997          	auipc	s3,0x1e
    80003532:	3ea98993          	addi	s3,s3,1002 # 80021918 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003536:	00005917          	auipc	s2,0x5
    8000353a:	fea90913          	addi	s2,s2,-22 # 80008520 <syscalls+0x160>
    8000353e:	85ca                	mv	a1,s2
    80003540:	8526                	mv	a0,s1
    80003542:	00001097          	auipc	ra,0x1
    80003546:	e3a080e7          	jalr	-454(ra) # 8000437c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000354a:	08848493          	addi	s1,s1,136
    8000354e:	ff3498e3          	bne	s1,s3,8000353e <iinit+0x3e>
}
    80003552:	70a2                	ld	ra,40(sp)
    80003554:	7402                	ld	s0,32(sp)
    80003556:	64e2                	ld	s1,24(sp)
    80003558:	6942                	ld	s2,16(sp)
    8000355a:	69a2                	ld	s3,8(sp)
    8000355c:	6145                	addi	sp,sp,48
    8000355e:	8082                	ret

0000000080003560 <ialloc>:
{
    80003560:	715d                	addi	sp,sp,-80
    80003562:	e486                	sd	ra,72(sp)
    80003564:	e0a2                	sd	s0,64(sp)
    80003566:	fc26                	sd	s1,56(sp)
    80003568:	f84a                	sd	s2,48(sp)
    8000356a:	f44e                	sd	s3,40(sp)
    8000356c:	f052                	sd	s4,32(sp)
    8000356e:	ec56                	sd	s5,24(sp)
    80003570:	e85a                	sd	s6,16(sp)
    80003572:	e45e                	sd	s7,8(sp)
    80003574:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003576:	0001d717          	auipc	a4,0x1d
    8000357a:	8d672703          	lw	a4,-1834(a4) # 8001fe4c <sb+0xc>
    8000357e:	4785                	li	a5,1
    80003580:	04e7fa63          	bgeu	a5,a4,800035d4 <ialloc+0x74>
    80003584:	8aaa                	mv	s5,a0
    80003586:	8bae                	mv	s7,a1
    80003588:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000358a:	0001da17          	auipc	s4,0x1d
    8000358e:	8b6a0a13          	addi	s4,s4,-1866 # 8001fe40 <sb>
    80003592:	00048b1b          	sext.w	s6,s1
    80003596:	0044d793          	srli	a5,s1,0x4
    8000359a:	018a2583          	lw	a1,24(s4)
    8000359e:	9dbd                	addw	a1,a1,a5
    800035a0:	8556                	mv	a0,s5
    800035a2:	00000097          	auipc	ra,0x0
    800035a6:	954080e7          	jalr	-1708(ra) # 80002ef6 <bread>
    800035aa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035ac:	05850993          	addi	s3,a0,88
    800035b0:	00f4f793          	andi	a5,s1,15
    800035b4:	079a                	slli	a5,a5,0x6
    800035b6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035b8:	00099783          	lh	a5,0(s3)
    800035bc:	c785                	beqz	a5,800035e4 <ialloc+0x84>
    brelse(bp);
    800035be:	00000097          	auipc	ra,0x0
    800035c2:	a68080e7          	jalr	-1432(ra) # 80003026 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035c6:	0485                	addi	s1,s1,1
    800035c8:	00ca2703          	lw	a4,12(s4)
    800035cc:	0004879b          	sext.w	a5,s1
    800035d0:	fce7e1e3          	bltu	a5,a4,80003592 <ialloc+0x32>
  panic("ialloc: no inodes");
    800035d4:	00005517          	auipc	a0,0x5
    800035d8:	f5450513          	addi	a0,a0,-172 # 80008528 <syscalls+0x168>
    800035dc:	ffffd097          	auipc	ra,0xffffd
    800035e0:	f66080e7          	jalr	-154(ra) # 80000542 <panic>
      memset(dip, 0, sizeof(*dip));
    800035e4:	04000613          	li	a2,64
    800035e8:	4581                	li	a1,0
    800035ea:	854e                	mv	a0,s3
    800035ec:	ffffd097          	auipc	ra,0xffffd
    800035f0:	70e080e7          	jalr	1806(ra) # 80000cfa <memset>
      dip->type = type;
    800035f4:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035f8:	854a                	mv	a0,s2
    800035fa:	00001097          	auipc	ra,0x1
    800035fe:	c94080e7          	jalr	-876(ra) # 8000428e <log_write>
      brelse(bp);
    80003602:	854a                	mv	a0,s2
    80003604:	00000097          	auipc	ra,0x0
    80003608:	a22080e7          	jalr	-1502(ra) # 80003026 <brelse>
      return iget(dev, inum);
    8000360c:	85da                	mv	a1,s6
    8000360e:	8556                	mv	a0,s5
    80003610:	00000097          	auipc	ra,0x0
    80003614:	db4080e7          	jalr	-588(ra) # 800033c4 <iget>
}
    80003618:	60a6                	ld	ra,72(sp)
    8000361a:	6406                	ld	s0,64(sp)
    8000361c:	74e2                	ld	s1,56(sp)
    8000361e:	7942                	ld	s2,48(sp)
    80003620:	79a2                	ld	s3,40(sp)
    80003622:	7a02                	ld	s4,32(sp)
    80003624:	6ae2                	ld	s5,24(sp)
    80003626:	6b42                	ld	s6,16(sp)
    80003628:	6ba2                	ld	s7,8(sp)
    8000362a:	6161                	addi	sp,sp,80
    8000362c:	8082                	ret

000000008000362e <iupdate>:
{
    8000362e:	1101                	addi	sp,sp,-32
    80003630:	ec06                	sd	ra,24(sp)
    80003632:	e822                	sd	s0,16(sp)
    80003634:	e426                	sd	s1,8(sp)
    80003636:	e04a                	sd	s2,0(sp)
    80003638:	1000                	addi	s0,sp,32
    8000363a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000363c:	415c                	lw	a5,4(a0)
    8000363e:	0047d79b          	srliw	a5,a5,0x4
    80003642:	0001d597          	auipc	a1,0x1d
    80003646:	8165a583          	lw	a1,-2026(a1) # 8001fe58 <sb+0x18>
    8000364a:	9dbd                	addw	a1,a1,a5
    8000364c:	4108                	lw	a0,0(a0)
    8000364e:	00000097          	auipc	ra,0x0
    80003652:	8a8080e7          	jalr	-1880(ra) # 80002ef6 <bread>
    80003656:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003658:	05850793          	addi	a5,a0,88
    8000365c:	40c8                	lw	a0,4(s1)
    8000365e:	893d                	andi	a0,a0,15
    80003660:	051a                	slli	a0,a0,0x6
    80003662:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003664:	04449703          	lh	a4,68(s1)
    80003668:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000366c:	04649703          	lh	a4,70(s1)
    80003670:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003674:	04849703          	lh	a4,72(s1)
    80003678:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000367c:	04a49703          	lh	a4,74(s1)
    80003680:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003684:	44f8                	lw	a4,76(s1)
    80003686:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003688:	03400613          	li	a2,52
    8000368c:	05048593          	addi	a1,s1,80
    80003690:	0531                	addi	a0,a0,12
    80003692:	ffffd097          	auipc	ra,0xffffd
    80003696:	6c4080e7          	jalr	1732(ra) # 80000d56 <memmove>
  log_write(bp);
    8000369a:	854a                	mv	a0,s2
    8000369c:	00001097          	auipc	ra,0x1
    800036a0:	bf2080e7          	jalr	-1038(ra) # 8000428e <log_write>
  brelse(bp);
    800036a4:	854a                	mv	a0,s2
    800036a6:	00000097          	auipc	ra,0x0
    800036aa:	980080e7          	jalr	-1664(ra) # 80003026 <brelse>
}
    800036ae:	60e2                	ld	ra,24(sp)
    800036b0:	6442                	ld	s0,16(sp)
    800036b2:	64a2                	ld	s1,8(sp)
    800036b4:	6902                	ld	s2,0(sp)
    800036b6:	6105                	addi	sp,sp,32
    800036b8:	8082                	ret

00000000800036ba <idup>:
{
    800036ba:	1101                	addi	sp,sp,-32
    800036bc:	ec06                	sd	ra,24(sp)
    800036be:	e822                	sd	s0,16(sp)
    800036c0:	e426                	sd	s1,8(sp)
    800036c2:	1000                	addi	s0,sp,32
    800036c4:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800036c6:	0001c517          	auipc	a0,0x1c
    800036ca:	79a50513          	addi	a0,a0,1946 # 8001fe60 <icache>
    800036ce:	ffffd097          	auipc	ra,0xffffd
    800036d2:	530080e7          	jalr	1328(ra) # 80000bfe <acquire>
  ip->ref++;
    800036d6:	449c                	lw	a5,8(s1)
    800036d8:	2785                	addiw	a5,a5,1
    800036da:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800036dc:	0001c517          	auipc	a0,0x1c
    800036e0:	78450513          	addi	a0,a0,1924 # 8001fe60 <icache>
    800036e4:	ffffd097          	auipc	ra,0xffffd
    800036e8:	5ce080e7          	jalr	1486(ra) # 80000cb2 <release>
}
    800036ec:	8526                	mv	a0,s1
    800036ee:	60e2                	ld	ra,24(sp)
    800036f0:	6442                	ld	s0,16(sp)
    800036f2:	64a2                	ld	s1,8(sp)
    800036f4:	6105                	addi	sp,sp,32
    800036f6:	8082                	ret

00000000800036f8 <ilock>:
{
    800036f8:	1101                	addi	sp,sp,-32
    800036fa:	ec06                	sd	ra,24(sp)
    800036fc:	e822                	sd	s0,16(sp)
    800036fe:	e426                	sd	s1,8(sp)
    80003700:	e04a                	sd	s2,0(sp)
    80003702:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003704:	c115                	beqz	a0,80003728 <ilock+0x30>
    80003706:	84aa                	mv	s1,a0
    80003708:	451c                	lw	a5,8(a0)
    8000370a:	00f05f63          	blez	a5,80003728 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000370e:	0541                	addi	a0,a0,16
    80003710:	00001097          	auipc	ra,0x1
    80003714:	ca6080e7          	jalr	-858(ra) # 800043b6 <acquiresleep>
  if(ip->valid == 0){
    80003718:	40bc                	lw	a5,64(s1)
    8000371a:	cf99                	beqz	a5,80003738 <ilock+0x40>
}
    8000371c:	60e2                	ld	ra,24(sp)
    8000371e:	6442                	ld	s0,16(sp)
    80003720:	64a2                	ld	s1,8(sp)
    80003722:	6902                	ld	s2,0(sp)
    80003724:	6105                	addi	sp,sp,32
    80003726:	8082                	ret
    panic("ilock");
    80003728:	00005517          	auipc	a0,0x5
    8000372c:	e1850513          	addi	a0,a0,-488 # 80008540 <syscalls+0x180>
    80003730:	ffffd097          	auipc	ra,0xffffd
    80003734:	e12080e7          	jalr	-494(ra) # 80000542 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003738:	40dc                	lw	a5,4(s1)
    8000373a:	0047d79b          	srliw	a5,a5,0x4
    8000373e:	0001c597          	auipc	a1,0x1c
    80003742:	71a5a583          	lw	a1,1818(a1) # 8001fe58 <sb+0x18>
    80003746:	9dbd                	addw	a1,a1,a5
    80003748:	4088                	lw	a0,0(s1)
    8000374a:	fffff097          	auipc	ra,0xfffff
    8000374e:	7ac080e7          	jalr	1964(ra) # 80002ef6 <bread>
    80003752:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003754:	05850593          	addi	a1,a0,88
    80003758:	40dc                	lw	a5,4(s1)
    8000375a:	8bbd                	andi	a5,a5,15
    8000375c:	079a                	slli	a5,a5,0x6
    8000375e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003760:	00059783          	lh	a5,0(a1)
    80003764:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003768:	00259783          	lh	a5,2(a1)
    8000376c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003770:	00459783          	lh	a5,4(a1)
    80003774:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003778:	00659783          	lh	a5,6(a1)
    8000377c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003780:	459c                	lw	a5,8(a1)
    80003782:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003784:	03400613          	li	a2,52
    80003788:	05b1                	addi	a1,a1,12
    8000378a:	05048513          	addi	a0,s1,80
    8000378e:	ffffd097          	auipc	ra,0xffffd
    80003792:	5c8080e7          	jalr	1480(ra) # 80000d56 <memmove>
    brelse(bp);
    80003796:	854a                	mv	a0,s2
    80003798:	00000097          	auipc	ra,0x0
    8000379c:	88e080e7          	jalr	-1906(ra) # 80003026 <brelse>
    ip->valid = 1;
    800037a0:	4785                	li	a5,1
    800037a2:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037a4:	04449783          	lh	a5,68(s1)
    800037a8:	fbb5                	bnez	a5,8000371c <ilock+0x24>
      panic("ilock: no type");
    800037aa:	00005517          	auipc	a0,0x5
    800037ae:	d9e50513          	addi	a0,a0,-610 # 80008548 <syscalls+0x188>
    800037b2:	ffffd097          	auipc	ra,0xffffd
    800037b6:	d90080e7          	jalr	-624(ra) # 80000542 <panic>

00000000800037ba <iunlock>:
{
    800037ba:	1101                	addi	sp,sp,-32
    800037bc:	ec06                	sd	ra,24(sp)
    800037be:	e822                	sd	s0,16(sp)
    800037c0:	e426                	sd	s1,8(sp)
    800037c2:	e04a                	sd	s2,0(sp)
    800037c4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037c6:	c905                	beqz	a0,800037f6 <iunlock+0x3c>
    800037c8:	84aa                	mv	s1,a0
    800037ca:	01050913          	addi	s2,a0,16
    800037ce:	854a                	mv	a0,s2
    800037d0:	00001097          	auipc	ra,0x1
    800037d4:	c80080e7          	jalr	-896(ra) # 80004450 <holdingsleep>
    800037d8:	cd19                	beqz	a0,800037f6 <iunlock+0x3c>
    800037da:	449c                	lw	a5,8(s1)
    800037dc:	00f05d63          	blez	a5,800037f6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037e0:	854a                	mv	a0,s2
    800037e2:	00001097          	auipc	ra,0x1
    800037e6:	c2a080e7          	jalr	-982(ra) # 8000440c <releasesleep>
}
    800037ea:	60e2                	ld	ra,24(sp)
    800037ec:	6442                	ld	s0,16(sp)
    800037ee:	64a2                	ld	s1,8(sp)
    800037f0:	6902                	ld	s2,0(sp)
    800037f2:	6105                	addi	sp,sp,32
    800037f4:	8082                	ret
    panic("iunlock");
    800037f6:	00005517          	auipc	a0,0x5
    800037fa:	d6250513          	addi	a0,a0,-670 # 80008558 <syscalls+0x198>
    800037fe:	ffffd097          	auipc	ra,0xffffd
    80003802:	d44080e7          	jalr	-700(ra) # 80000542 <panic>

0000000080003806 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003806:	7179                	addi	sp,sp,-48
    80003808:	f406                	sd	ra,40(sp)
    8000380a:	f022                	sd	s0,32(sp)
    8000380c:	ec26                	sd	s1,24(sp)
    8000380e:	e84a                	sd	s2,16(sp)
    80003810:	e44e                	sd	s3,8(sp)
    80003812:	e052                	sd	s4,0(sp)
    80003814:	1800                	addi	s0,sp,48
    80003816:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003818:	05050493          	addi	s1,a0,80
    8000381c:	08050913          	addi	s2,a0,128
    80003820:	a021                	j	80003828 <itrunc+0x22>
    80003822:	0491                	addi	s1,s1,4
    80003824:	01248d63          	beq	s1,s2,8000383e <itrunc+0x38>
    if(ip->addrs[i]){
    80003828:	408c                	lw	a1,0(s1)
    8000382a:	dde5                	beqz	a1,80003822 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000382c:	0009a503          	lw	a0,0(s3)
    80003830:	00000097          	auipc	ra,0x0
    80003834:	90c080e7          	jalr	-1780(ra) # 8000313c <bfree>
      ip->addrs[i] = 0;
    80003838:	0004a023          	sw	zero,0(s1)
    8000383c:	b7dd                	j	80003822 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000383e:	0809a583          	lw	a1,128(s3)
    80003842:	e185                	bnez	a1,80003862 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003844:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003848:	854e                	mv	a0,s3
    8000384a:	00000097          	auipc	ra,0x0
    8000384e:	de4080e7          	jalr	-540(ra) # 8000362e <iupdate>
}
    80003852:	70a2                	ld	ra,40(sp)
    80003854:	7402                	ld	s0,32(sp)
    80003856:	64e2                	ld	s1,24(sp)
    80003858:	6942                	ld	s2,16(sp)
    8000385a:	69a2                	ld	s3,8(sp)
    8000385c:	6a02                	ld	s4,0(sp)
    8000385e:	6145                	addi	sp,sp,48
    80003860:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003862:	0009a503          	lw	a0,0(s3)
    80003866:	fffff097          	auipc	ra,0xfffff
    8000386a:	690080e7          	jalr	1680(ra) # 80002ef6 <bread>
    8000386e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003870:	05850493          	addi	s1,a0,88
    80003874:	45850913          	addi	s2,a0,1112
    80003878:	a021                	j	80003880 <itrunc+0x7a>
    8000387a:	0491                	addi	s1,s1,4
    8000387c:	01248b63          	beq	s1,s2,80003892 <itrunc+0x8c>
      if(a[j])
    80003880:	408c                	lw	a1,0(s1)
    80003882:	dde5                	beqz	a1,8000387a <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003884:	0009a503          	lw	a0,0(s3)
    80003888:	00000097          	auipc	ra,0x0
    8000388c:	8b4080e7          	jalr	-1868(ra) # 8000313c <bfree>
    80003890:	b7ed                	j	8000387a <itrunc+0x74>
    brelse(bp);
    80003892:	8552                	mv	a0,s4
    80003894:	fffff097          	auipc	ra,0xfffff
    80003898:	792080e7          	jalr	1938(ra) # 80003026 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000389c:	0809a583          	lw	a1,128(s3)
    800038a0:	0009a503          	lw	a0,0(s3)
    800038a4:	00000097          	auipc	ra,0x0
    800038a8:	898080e7          	jalr	-1896(ra) # 8000313c <bfree>
    ip->addrs[NDIRECT] = 0;
    800038ac:	0809a023          	sw	zero,128(s3)
    800038b0:	bf51                	j	80003844 <itrunc+0x3e>

00000000800038b2 <iput>:
{
    800038b2:	1101                	addi	sp,sp,-32
    800038b4:	ec06                	sd	ra,24(sp)
    800038b6:	e822                	sd	s0,16(sp)
    800038b8:	e426                	sd	s1,8(sp)
    800038ba:	e04a                	sd	s2,0(sp)
    800038bc:	1000                	addi	s0,sp,32
    800038be:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800038c0:	0001c517          	auipc	a0,0x1c
    800038c4:	5a050513          	addi	a0,a0,1440 # 8001fe60 <icache>
    800038c8:	ffffd097          	auipc	ra,0xffffd
    800038cc:	336080e7          	jalr	822(ra) # 80000bfe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038d0:	4498                	lw	a4,8(s1)
    800038d2:	4785                	li	a5,1
    800038d4:	02f70363          	beq	a4,a5,800038fa <iput+0x48>
  ip->ref--;
    800038d8:	449c                	lw	a5,8(s1)
    800038da:	37fd                	addiw	a5,a5,-1
    800038dc:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800038de:	0001c517          	auipc	a0,0x1c
    800038e2:	58250513          	addi	a0,a0,1410 # 8001fe60 <icache>
    800038e6:	ffffd097          	auipc	ra,0xffffd
    800038ea:	3cc080e7          	jalr	972(ra) # 80000cb2 <release>
}
    800038ee:	60e2                	ld	ra,24(sp)
    800038f0:	6442                	ld	s0,16(sp)
    800038f2:	64a2                	ld	s1,8(sp)
    800038f4:	6902                	ld	s2,0(sp)
    800038f6:	6105                	addi	sp,sp,32
    800038f8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038fa:	40bc                	lw	a5,64(s1)
    800038fc:	dff1                	beqz	a5,800038d8 <iput+0x26>
    800038fe:	04a49783          	lh	a5,74(s1)
    80003902:	fbf9                	bnez	a5,800038d8 <iput+0x26>
    acquiresleep(&ip->lock);
    80003904:	01048913          	addi	s2,s1,16
    80003908:	854a                	mv	a0,s2
    8000390a:	00001097          	auipc	ra,0x1
    8000390e:	aac080e7          	jalr	-1364(ra) # 800043b6 <acquiresleep>
    release(&icache.lock);
    80003912:	0001c517          	auipc	a0,0x1c
    80003916:	54e50513          	addi	a0,a0,1358 # 8001fe60 <icache>
    8000391a:	ffffd097          	auipc	ra,0xffffd
    8000391e:	398080e7          	jalr	920(ra) # 80000cb2 <release>
    itrunc(ip);
    80003922:	8526                	mv	a0,s1
    80003924:	00000097          	auipc	ra,0x0
    80003928:	ee2080e7          	jalr	-286(ra) # 80003806 <itrunc>
    ip->type = 0;
    8000392c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003930:	8526                	mv	a0,s1
    80003932:	00000097          	auipc	ra,0x0
    80003936:	cfc080e7          	jalr	-772(ra) # 8000362e <iupdate>
    ip->valid = 0;
    8000393a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000393e:	854a                	mv	a0,s2
    80003940:	00001097          	auipc	ra,0x1
    80003944:	acc080e7          	jalr	-1332(ra) # 8000440c <releasesleep>
    acquire(&icache.lock);
    80003948:	0001c517          	auipc	a0,0x1c
    8000394c:	51850513          	addi	a0,a0,1304 # 8001fe60 <icache>
    80003950:	ffffd097          	auipc	ra,0xffffd
    80003954:	2ae080e7          	jalr	686(ra) # 80000bfe <acquire>
    80003958:	b741                	j	800038d8 <iput+0x26>

000000008000395a <iunlockput>:
{
    8000395a:	1101                	addi	sp,sp,-32
    8000395c:	ec06                	sd	ra,24(sp)
    8000395e:	e822                	sd	s0,16(sp)
    80003960:	e426                	sd	s1,8(sp)
    80003962:	1000                	addi	s0,sp,32
    80003964:	84aa                	mv	s1,a0
  iunlock(ip);
    80003966:	00000097          	auipc	ra,0x0
    8000396a:	e54080e7          	jalr	-428(ra) # 800037ba <iunlock>
  iput(ip);
    8000396e:	8526                	mv	a0,s1
    80003970:	00000097          	auipc	ra,0x0
    80003974:	f42080e7          	jalr	-190(ra) # 800038b2 <iput>
}
    80003978:	60e2                	ld	ra,24(sp)
    8000397a:	6442                	ld	s0,16(sp)
    8000397c:	64a2                	ld	s1,8(sp)
    8000397e:	6105                	addi	sp,sp,32
    80003980:	8082                	ret

0000000080003982 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003982:	1141                	addi	sp,sp,-16
    80003984:	e422                	sd	s0,8(sp)
    80003986:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003988:	411c                	lw	a5,0(a0)
    8000398a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000398c:	415c                	lw	a5,4(a0)
    8000398e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003990:	04451783          	lh	a5,68(a0)
    80003994:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003998:	04a51783          	lh	a5,74(a0)
    8000399c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039a0:	04c56783          	lwu	a5,76(a0)
    800039a4:	e99c                	sd	a5,16(a1)
}
    800039a6:	6422                	ld	s0,8(sp)
    800039a8:	0141                	addi	sp,sp,16
    800039aa:	8082                	ret

00000000800039ac <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039ac:	457c                	lw	a5,76(a0)
    800039ae:	0ed7e963          	bltu	a5,a3,80003aa0 <readi+0xf4>
{
    800039b2:	7159                	addi	sp,sp,-112
    800039b4:	f486                	sd	ra,104(sp)
    800039b6:	f0a2                	sd	s0,96(sp)
    800039b8:	eca6                	sd	s1,88(sp)
    800039ba:	e8ca                	sd	s2,80(sp)
    800039bc:	e4ce                	sd	s3,72(sp)
    800039be:	e0d2                	sd	s4,64(sp)
    800039c0:	fc56                	sd	s5,56(sp)
    800039c2:	f85a                	sd	s6,48(sp)
    800039c4:	f45e                	sd	s7,40(sp)
    800039c6:	f062                	sd	s8,32(sp)
    800039c8:	ec66                	sd	s9,24(sp)
    800039ca:	e86a                	sd	s10,16(sp)
    800039cc:	e46e                	sd	s11,8(sp)
    800039ce:	1880                	addi	s0,sp,112
    800039d0:	8baa                	mv	s7,a0
    800039d2:	8c2e                	mv	s8,a1
    800039d4:	8ab2                	mv	s5,a2
    800039d6:	84b6                	mv	s1,a3
    800039d8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039da:	9f35                	addw	a4,a4,a3
    return 0;
    800039dc:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039de:	0ad76063          	bltu	a4,a3,80003a7e <readi+0xd2>
  if(off + n > ip->size)
    800039e2:	00e7f463          	bgeu	a5,a4,800039ea <readi+0x3e>
    n = ip->size - off;
    800039e6:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039ea:	0a0b0963          	beqz	s6,80003a9c <readi+0xf0>
    800039ee:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800039f0:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039f4:	5cfd                	li	s9,-1
    800039f6:	a82d                	j	80003a30 <readi+0x84>
    800039f8:	020a1d93          	slli	s11,s4,0x20
    800039fc:	020ddd93          	srli	s11,s11,0x20
    80003a00:	05890793          	addi	a5,s2,88
    80003a04:	86ee                	mv	a3,s11
    80003a06:	963e                	add	a2,a2,a5
    80003a08:	85d6                	mv	a1,s5
    80003a0a:	8562                	mv	a0,s8
    80003a0c:	fffff097          	auipc	ra,0xfffff
    80003a10:	af6080e7          	jalr	-1290(ra) # 80002502 <either_copyout>
    80003a14:	05950d63          	beq	a0,s9,80003a6e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a18:	854a                	mv	a0,s2
    80003a1a:	fffff097          	auipc	ra,0xfffff
    80003a1e:	60c080e7          	jalr	1548(ra) # 80003026 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a22:	013a09bb          	addw	s3,s4,s3
    80003a26:	009a04bb          	addw	s1,s4,s1
    80003a2a:	9aee                	add	s5,s5,s11
    80003a2c:	0569f763          	bgeu	s3,s6,80003a7a <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a30:	000ba903          	lw	s2,0(s7)
    80003a34:	00a4d59b          	srliw	a1,s1,0xa
    80003a38:	855e                	mv	a0,s7
    80003a3a:	00000097          	auipc	ra,0x0
    80003a3e:	8b0080e7          	jalr	-1872(ra) # 800032ea <bmap>
    80003a42:	0005059b          	sext.w	a1,a0
    80003a46:	854a                	mv	a0,s2
    80003a48:	fffff097          	auipc	ra,0xfffff
    80003a4c:	4ae080e7          	jalr	1198(ra) # 80002ef6 <bread>
    80003a50:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a52:	3ff4f613          	andi	a2,s1,1023
    80003a56:	40cd07bb          	subw	a5,s10,a2
    80003a5a:	413b073b          	subw	a4,s6,s3
    80003a5e:	8a3e                	mv	s4,a5
    80003a60:	2781                	sext.w	a5,a5
    80003a62:	0007069b          	sext.w	a3,a4
    80003a66:	f8f6f9e3          	bgeu	a3,a5,800039f8 <readi+0x4c>
    80003a6a:	8a3a                	mv	s4,a4
    80003a6c:	b771                	j	800039f8 <readi+0x4c>
      brelse(bp);
    80003a6e:	854a                	mv	a0,s2
    80003a70:	fffff097          	auipc	ra,0xfffff
    80003a74:	5b6080e7          	jalr	1462(ra) # 80003026 <brelse>
      tot = -1;
    80003a78:	59fd                	li	s3,-1
  }
  return tot;
    80003a7a:	0009851b          	sext.w	a0,s3
}
    80003a7e:	70a6                	ld	ra,104(sp)
    80003a80:	7406                	ld	s0,96(sp)
    80003a82:	64e6                	ld	s1,88(sp)
    80003a84:	6946                	ld	s2,80(sp)
    80003a86:	69a6                	ld	s3,72(sp)
    80003a88:	6a06                	ld	s4,64(sp)
    80003a8a:	7ae2                	ld	s5,56(sp)
    80003a8c:	7b42                	ld	s6,48(sp)
    80003a8e:	7ba2                	ld	s7,40(sp)
    80003a90:	7c02                	ld	s8,32(sp)
    80003a92:	6ce2                	ld	s9,24(sp)
    80003a94:	6d42                	ld	s10,16(sp)
    80003a96:	6da2                	ld	s11,8(sp)
    80003a98:	6165                	addi	sp,sp,112
    80003a9a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a9c:	89da                	mv	s3,s6
    80003a9e:	bff1                	j	80003a7a <readi+0xce>
    return 0;
    80003aa0:	4501                	li	a0,0
}
    80003aa2:	8082                	ret

0000000080003aa4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003aa4:	457c                	lw	a5,76(a0)
    80003aa6:	10d7e763          	bltu	a5,a3,80003bb4 <writei+0x110>
{
    80003aaa:	7159                	addi	sp,sp,-112
    80003aac:	f486                	sd	ra,104(sp)
    80003aae:	f0a2                	sd	s0,96(sp)
    80003ab0:	eca6                	sd	s1,88(sp)
    80003ab2:	e8ca                	sd	s2,80(sp)
    80003ab4:	e4ce                	sd	s3,72(sp)
    80003ab6:	e0d2                	sd	s4,64(sp)
    80003ab8:	fc56                	sd	s5,56(sp)
    80003aba:	f85a                	sd	s6,48(sp)
    80003abc:	f45e                	sd	s7,40(sp)
    80003abe:	f062                	sd	s8,32(sp)
    80003ac0:	ec66                	sd	s9,24(sp)
    80003ac2:	e86a                	sd	s10,16(sp)
    80003ac4:	e46e                	sd	s11,8(sp)
    80003ac6:	1880                	addi	s0,sp,112
    80003ac8:	8baa                	mv	s7,a0
    80003aca:	8c2e                	mv	s8,a1
    80003acc:	8ab2                	mv	s5,a2
    80003ace:	8936                	mv	s2,a3
    80003ad0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ad2:	00e687bb          	addw	a5,a3,a4
    80003ad6:	0ed7e163          	bltu	a5,a3,80003bb8 <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ada:	00043737          	lui	a4,0x43
    80003ade:	0cf76f63          	bltu	a4,a5,80003bbc <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ae2:	0a0b0863          	beqz	s6,80003b92 <writei+0xee>
    80003ae6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ae8:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003aec:	5cfd                	li	s9,-1
    80003aee:	a091                	j	80003b32 <writei+0x8e>
    80003af0:	02099d93          	slli	s11,s3,0x20
    80003af4:	020ddd93          	srli	s11,s11,0x20
    80003af8:	05848793          	addi	a5,s1,88
    80003afc:	86ee                	mv	a3,s11
    80003afe:	8656                	mv	a2,s5
    80003b00:	85e2                	mv	a1,s8
    80003b02:	953e                	add	a0,a0,a5
    80003b04:	fffff097          	auipc	ra,0xfffff
    80003b08:	a54080e7          	jalr	-1452(ra) # 80002558 <either_copyin>
    80003b0c:	07950263          	beq	a0,s9,80003b70 <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003b10:	8526                	mv	a0,s1
    80003b12:	00000097          	auipc	ra,0x0
    80003b16:	77c080e7          	jalr	1916(ra) # 8000428e <log_write>
    brelse(bp);
    80003b1a:	8526                	mv	a0,s1
    80003b1c:	fffff097          	auipc	ra,0xfffff
    80003b20:	50a080e7          	jalr	1290(ra) # 80003026 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b24:	01498a3b          	addw	s4,s3,s4
    80003b28:	0129893b          	addw	s2,s3,s2
    80003b2c:	9aee                	add	s5,s5,s11
    80003b2e:	056a7763          	bgeu	s4,s6,80003b7c <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b32:	000ba483          	lw	s1,0(s7)
    80003b36:	00a9559b          	srliw	a1,s2,0xa
    80003b3a:	855e                	mv	a0,s7
    80003b3c:	fffff097          	auipc	ra,0xfffff
    80003b40:	7ae080e7          	jalr	1966(ra) # 800032ea <bmap>
    80003b44:	0005059b          	sext.w	a1,a0
    80003b48:	8526                	mv	a0,s1
    80003b4a:	fffff097          	auipc	ra,0xfffff
    80003b4e:	3ac080e7          	jalr	940(ra) # 80002ef6 <bread>
    80003b52:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b54:	3ff97513          	andi	a0,s2,1023
    80003b58:	40ad07bb          	subw	a5,s10,a0
    80003b5c:	414b073b          	subw	a4,s6,s4
    80003b60:	89be                	mv	s3,a5
    80003b62:	2781                	sext.w	a5,a5
    80003b64:	0007069b          	sext.w	a3,a4
    80003b68:	f8f6f4e3          	bgeu	a3,a5,80003af0 <writei+0x4c>
    80003b6c:	89ba                	mv	s3,a4
    80003b6e:	b749                	j	80003af0 <writei+0x4c>
      brelse(bp);
    80003b70:	8526                	mv	a0,s1
    80003b72:	fffff097          	auipc	ra,0xfffff
    80003b76:	4b4080e7          	jalr	1204(ra) # 80003026 <brelse>
      n = -1;
    80003b7a:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003b7c:	04cba783          	lw	a5,76(s7)
    80003b80:	0127f463          	bgeu	a5,s2,80003b88 <writei+0xe4>
      ip->size = off;
    80003b84:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003b88:	855e                	mv	a0,s7
    80003b8a:	00000097          	auipc	ra,0x0
    80003b8e:	aa4080e7          	jalr	-1372(ra) # 8000362e <iupdate>
  }

  return n;
    80003b92:	000b051b          	sext.w	a0,s6
}
    80003b96:	70a6                	ld	ra,104(sp)
    80003b98:	7406                	ld	s0,96(sp)
    80003b9a:	64e6                	ld	s1,88(sp)
    80003b9c:	6946                	ld	s2,80(sp)
    80003b9e:	69a6                	ld	s3,72(sp)
    80003ba0:	6a06                	ld	s4,64(sp)
    80003ba2:	7ae2                	ld	s5,56(sp)
    80003ba4:	7b42                	ld	s6,48(sp)
    80003ba6:	7ba2                	ld	s7,40(sp)
    80003ba8:	7c02                	ld	s8,32(sp)
    80003baa:	6ce2                	ld	s9,24(sp)
    80003bac:	6d42                	ld	s10,16(sp)
    80003bae:	6da2                	ld	s11,8(sp)
    80003bb0:	6165                	addi	sp,sp,112
    80003bb2:	8082                	ret
    return -1;
    80003bb4:	557d                	li	a0,-1
}
    80003bb6:	8082                	ret
    return -1;
    80003bb8:	557d                	li	a0,-1
    80003bba:	bff1                	j	80003b96 <writei+0xf2>
    return -1;
    80003bbc:	557d                	li	a0,-1
    80003bbe:	bfe1                	j	80003b96 <writei+0xf2>

0000000080003bc0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003bc0:	1141                	addi	sp,sp,-16
    80003bc2:	e406                	sd	ra,8(sp)
    80003bc4:	e022                	sd	s0,0(sp)
    80003bc6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bc8:	4639                	li	a2,14
    80003bca:	ffffd097          	auipc	ra,0xffffd
    80003bce:	208080e7          	jalr	520(ra) # 80000dd2 <strncmp>
}
    80003bd2:	60a2                	ld	ra,8(sp)
    80003bd4:	6402                	ld	s0,0(sp)
    80003bd6:	0141                	addi	sp,sp,16
    80003bd8:	8082                	ret

0000000080003bda <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003bda:	7139                	addi	sp,sp,-64
    80003bdc:	fc06                	sd	ra,56(sp)
    80003bde:	f822                	sd	s0,48(sp)
    80003be0:	f426                	sd	s1,40(sp)
    80003be2:	f04a                	sd	s2,32(sp)
    80003be4:	ec4e                	sd	s3,24(sp)
    80003be6:	e852                	sd	s4,16(sp)
    80003be8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003bea:	04451703          	lh	a4,68(a0)
    80003bee:	4785                	li	a5,1
    80003bf0:	00f71a63          	bne	a4,a5,80003c04 <dirlookup+0x2a>
    80003bf4:	892a                	mv	s2,a0
    80003bf6:	89ae                	mv	s3,a1
    80003bf8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bfa:	457c                	lw	a5,76(a0)
    80003bfc:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bfe:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c00:	e79d                	bnez	a5,80003c2e <dirlookup+0x54>
    80003c02:	a8a5                	j	80003c7a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c04:	00005517          	auipc	a0,0x5
    80003c08:	95c50513          	addi	a0,a0,-1700 # 80008560 <syscalls+0x1a0>
    80003c0c:	ffffd097          	auipc	ra,0xffffd
    80003c10:	936080e7          	jalr	-1738(ra) # 80000542 <panic>
      panic("dirlookup read");
    80003c14:	00005517          	auipc	a0,0x5
    80003c18:	96450513          	addi	a0,a0,-1692 # 80008578 <syscalls+0x1b8>
    80003c1c:	ffffd097          	auipc	ra,0xffffd
    80003c20:	926080e7          	jalr	-1754(ra) # 80000542 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c24:	24c1                	addiw	s1,s1,16
    80003c26:	04c92783          	lw	a5,76(s2)
    80003c2a:	04f4f763          	bgeu	s1,a5,80003c78 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c2e:	4741                	li	a4,16
    80003c30:	86a6                	mv	a3,s1
    80003c32:	fc040613          	addi	a2,s0,-64
    80003c36:	4581                	li	a1,0
    80003c38:	854a                	mv	a0,s2
    80003c3a:	00000097          	auipc	ra,0x0
    80003c3e:	d72080e7          	jalr	-654(ra) # 800039ac <readi>
    80003c42:	47c1                	li	a5,16
    80003c44:	fcf518e3          	bne	a0,a5,80003c14 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c48:	fc045783          	lhu	a5,-64(s0)
    80003c4c:	dfe1                	beqz	a5,80003c24 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c4e:	fc240593          	addi	a1,s0,-62
    80003c52:	854e                	mv	a0,s3
    80003c54:	00000097          	auipc	ra,0x0
    80003c58:	f6c080e7          	jalr	-148(ra) # 80003bc0 <namecmp>
    80003c5c:	f561                	bnez	a0,80003c24 <dirlookup+0x4a>
      if(poff)
    80003c5e:	000a0463          	beqz	s4,80003c66 <dirlookup+0x8c>
        *poff = off;
    80003c62:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c66:	fc045583          	lhu	a1,-64(s0)
    80003c6a:	00092503          	lw	a0,0(s2)
    80003c6e:	fffff097          	auipc	ra,0xfffff
    80003c72:	756080e7          	jalr	1878(ra) # 800033c4 <iget>
    80003c76:	a011                	j	80003c7a <dirlookup+0xa0>
  return 0;
    80003c78:	4501                	li	a0,0
}
    80003c7a:	70e2                	ld	ra,56(sp)
    80003c7c:	7442                	ld	s0,48(sp)
    80003c7e:	74a2                	ld	s1,40(sp)
    80003c80:	7902                	ld	s2,32(sp)
    80003c82:	69e2                	ld	s3,24(sp)
    80003c84:	6a42                	ld	s4,16(sp)
    80003c86:	6121                	addi	sp,sp,64
    80003c88:	8082                	ret

0000000080003c8a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c8a:	711d                	addi	sp,sp,-96
    80003c8c:	ec86                	sd	ra,88(sp)
    80003c8e:	e8a2                	sd	s0,80(sp)
    80003c90:	e4a6                	sd	s1,72(sp)
    80003c92:	e0ca                	sd	s2,64(sp)
    80003c94:	fc4e                	sd	s3,56(sp)
    80003c96:	f852                	sd	s4,48(sp)
    80003c98:	f456                	sd	s5,40(sp)
    80003c9a:	f05a                	sd	s6,32(sp)
    80003c9c:	ec5e                	sd	s7,24(sp)
    80003c9e:	e862                	sd	s8,16(sp)
    80003ca0:	e466                	sd	s9,8(sp)
    80003ca2:	1080                	addi	s0,sp,96
    80003ca4:	84aa                	mv	s1,a0
    80003ca6:	8aae                	mv	s5,a1
    80003ca8:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003caa:	00054703          	lbu	a4,0(a0)
    80003cae:	02f00793          	li	a5,47
    80003cb2:	02f70363          	beq	a4,a5,80003cd8 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cb6:	ffffe097          	auipc	ra,0xffffe
    80003cba:	dde080e7          	jalr	-546(ra) # 80001a94 <myproc>
    80003cbe:	15053503          	ld	a0,336(a0)
    80003cc2:	00000097          	auipc	ra,0x0
    80003cc6:	9f8080e7          	jalr	-1544(ra) # 800036ba <idup>
    80003cca:	89aa                	mv	s3,a0
  while(*path == '/')
    80003ccc:	02f00913          	li	s2,47
  len = path - s;
    80003cd0:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003cd2:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cd4:	4b85                	li	s7,1
    80003cd6:	a865                	j	80003d8e <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003cd8:	4585                	li	a1,1
    80003cda:	4505                	li	a0,1
    80003cdc:	fffff097          	auipc	ra,0xfffff
    80003ce0:	6e8080e7          	jalr	1768(ra) # 800033c4 <iget>
    80003ce4:	89aa                	mv	s3,a0
    80003ce6:	b7dd                	j	80003ccc <namex+0x42>
      iunlockput(ip);
    80003ce8:	854e                	mv	a0,s3
    80003cea:	00000097          	auipc	ra,0x0
    80003cee:	c70080e7          	jalr	-912(ra) # 8000395a <iunlockput>
      return 0;
    80003cf2:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cf4:	854e                	mv	a0,s3
    80003cf6:	60e6                	ld	ra,88(sp)
    80003cf8:	6446                	ld	s0,80(sp)
    80003cfa:	64a6                	ld	s1,72(sp)
    80003cfc:	6906                	ld	s2,64(sp)
    80003cfe:	79e2                	ld	s3,56(sp)
    80003d00:	7a42                	ld	s4,48(sp)
    80003d02:	7aa2                	ld	s5,40(sp)
    80003d04:	7b02                	ld	s6,32(sp)
    80003d06:	6be2                	ld	s7,24(sp)
    80003d08:	6c42                	ld	s8,16(sp)
    80003d0a:	6ca2                	ld	s9,8(sp)
    80003d0c:	6125                	addi	sp,sp,96
    80003d0e:	8082                	ret
      iunlock(ip);
    80003d10:	854e                	mv	a0,s3
    80003d12:	00000097          	auipc	ra,0x0
    80003d16:	aa8080e7          	jalr	-1368(ra) # 800037ba <iunlock>
      return ip;
    80003d1a:	bfe9                	j	80003cf4 <namex+0x6a>
      iunlockput(ip);
    80003d1c:	854e                	mv	a0,s3
    80003d1e:	00000097          	auipc	ra,0x0
    80003d22:	c3c080e7          	jalr	-964(ra) # 8000395a <iunlockput>
      return 0;
    80003d26:	89e6                	mv	s3,s9
    80003d28:	b7f1                	j	80003cf4 <namex+0x6a>
  len = path - s;
    80003d2a:	40b48633          	sub	a2,s1,a1
    80003d2e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d32:	099c5463          	bge	s8,s9,80003dba <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003d36:	4639                	li	a2,14
    80003d38:	8552                	mv	a0,s4
    80003d3a:	ffffd097          	auipc	ra,0xffffd
    80003d3e:	01c080e7          	jalr	28(ra) # 80000d56 <memmove>
  while(*path == '/')
    80003d42:	0004c783          	lbu	a5,0(s1)
    80003d46:	01279763          	bne	a5,s2,80003d54 <namex+0xca>
    path++;
    80003d4a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d4c:	0004c783          	lbu	a5,0(s1)
    80003d50:	ff278de3          	beq	a5,s2,80003d4a <namex+0xc0>
    ilock(ip);
    80003d54:	854e                	mv	a0,s3
    80003d56:	00000097          	auipc	ra,0x0
    80003d5a:	9a2080e7          	jalr	-1630(ra) # 800036f8 <ilock>
    if(ip->type != T_DIR){
    80003d5e:	04499783          	lh	a5,68(s3)
    80003d62:	f97793e3          	bne	a5,s7,80003ce8 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003d66:	000a8563          	beqz	s5,80003d70 <namex+0xe6>
    80003d6a:	0004c783          	lbu	a5,0(s1)
    80003d6e:	d3cd                	beqz	a5,80003d10 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d70:	865a                	mv	a2,s6
    80003d72:	85d2                	mv	a1,s4
    80003d74:	854e                	mv	a0,s3
    80003d76:	00000097          	auipc	ra,0x0
    80003d7a:	e64080e7          	jalr	-412(ra) # 80003bda <dirlookup>
    80003d7e:	8caa                	mv	s9,a0
    80003d80:	dd51                	beqz	a0,80003d1c <namex+0x92>
    iunlockput(ip);
    80003d82:	854e                	mv	a0,s3
    80003d84:	00000097          	auipc	ra,0x0
    80003d88:	bd6080e7          	jalr	-1066(ra) # 8000395a <iunlockput>
    ip = next;
    80003d8c:	89e6                	mv	s3,s9
  while(*path == '/')
    80003d8e:	0004c783          	lbu	a5,0(s1)
    80003d92:	05279763          	bne	a5,s2,80003de0 <namex+0x156>
    path++;
    80003d96:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d98:	0004c783          	lbu	a5,0(s1)
    80003d9c:	ff278de3          	beq	a5,s2,80003d96 <namex+0x10c>
  if(*path == 0)
    80003da0:	c79d                	beqz	a5,80003dce <namex+0x144>
    path++;
    80003da2:	85a6                	mv	a1,s1
  len = path - s;
    80003da4:	8cda                	mv	s9,s6
    80003da6:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003da8:	01278963          	beq	a5,s2,80003dba <namex+0x130>
    80003dac:	dfbd                	beqz	a5,80003d2a <namex+0xa0>
    path++;
    80003dae:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003db0:	0004c783          	lbu	a5,0(s1)
    80003db4:	ff279ce3          	bne	a5,s2,80003dac <namex+0x122>
    80003db8:	bf8d                	j	80003d2a <namex+0xa0>
    memmove(name, s, len);
    80003dba:	2601                	sext.w	a2,a2
    80003dbc:	8552                	mv	a0,s4
    80003dbe:	ffffd097          	auipc	ra,0xffffd
    80003dc2:	f98080e7          	jalr	-104(ra) # 80000d56 <memmove>
    name[len] = 0;
    80003dc6:	9cd2                	add	s9,s9,s4
    80003dc8:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003dcc:	bf9d                	j	80003d42 <namex+0xb8>
  if(nameiparent){
    80003dce:	f20a83e3          	beqz	s5,80003cf4 <namex+0x6a>
    iput(ip);
    80003dd2:	854e                	mv	a0,s3
    80003dd4:	00000097          	auipc	ra,0x0
    80003dd8:	ade080e7          	jalr	-1314(ra) # 800038b2 <iput>
    return 0;
    80003ddc:	4981                	li	s3,0
    80003dde:	bf19                	j	80003cf4 <namex+0x6a>
  if(*path == 0)
    80003de0:	d7fd                	beqz	a5,80003dce <namex+0x144>
  while(*path != '/' && *path != 0)
    80003de2:	0004c783          	lbu	a5,0(s1)
    80003de6:	85a6                	mv	a1,s1
    80003de8:	b7d1                	j	80003dac <namex+0x122>

0000000080003dea <dirlink>:
{
    80003dea:	7139                	addi	sp,sp,-64
    80003dec:	fc06                	sd	ra,56(sp)
    80003dee:	f822                	sd	s0,48(sp)
    80003df0:	f426                	sd	s1,40(sp)
    80003df2:	f04a                	sd	s2,32(sp)
    80003df4:	ec4e                	sd	s3,24(sp)
    80003df6:	e852                	sd	s4,16(sp)
    80003df8:	0080                	addi	s0,sp,64
    80003dfa:	892a                	mv	s2,a0
    80003dfc:	8a2e                	mv	s4,a1
    80003dfe:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e00:	4601                	li	a2,0
    80003e02:	00000097          	auipc	ra,0x0
    80003e06:	dd8080e7          	jalr	-552(ra) # 80003bda <dirlookup>
    80003e0a:	e93d                	bnez	a0,80003e80 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e0c:	04c92483          	lw	s1,76(s2)
    80003e10:	c49d                	beqz	s1,80003e3e <dirlink+0x54>
    80003e12:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e14:	4741                	li	a4,16
    80003e16:	86a6                	mv	a3,s1
    80003e18:	fc040613          	addi	a2,s0,-64
    80003e1c:	4581                	li	a1,0
    80003e1e:	854a                	mv	a0,s2
    80003e20:	00000097          	auipc	ra,0x0
    80003e24:	b8c080e7          	jalr	-1140(ra) # 800039ac <readi>
    80003e28:	47c1                	li	a5,16
    80003e2a:	06f51163          	bne	a0,a5,80003e8c <dirlink+0xa2>
    if(de.inum == 0)
    80003e2e:	fc045783          	lhu	a5,-64(s0)
    80003e32:	c791                	beqz	a5,80003e3e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e34:	24c1                	addiw	s1,s1,16
    80003e36:	04c92783          	lw	a5,76(s2)
    80003e3a:	fcf4ede3          	bltu	s1,a5,80003e14 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e3e:	4639                	li	a2,14
    80003e40:	85d2                	mv	a1,s4
    80003e42:	fc240513          	addi	a0,s0,-62
    80003e46:	ffffd097          	auipc	ra,0xffffd
    80003e4a:	fc8080e7          	jalr	-56(ra) # 80000e0e <strncpy>
  de.inum = inum;
    80003e4e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e52:	4741                	li	a4,16
    80003e54:	86a6                	mv	a3,s1
    80003e56:	fc040613          	addi	a2,s0,-64
    80003e5a:	4581                	li	a1,0
    80003e5c:	854a                	mv	a0,s2
    80003e5e:	00000097          	auipc	ra,0x0
    80003e62:	c46080e7          	jalr	-954(ra) # 80003aa4 <writei>
    80003e66:	872a                	mv	a4,a0
    80003e68:	47c1                	li	a5,16
  return 0;
    80003e6a:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e6c:	02f71863          	bne	a4,a5,80003e9c <dirlink+0xb2>
}
    80003e70:	70e2                	ld	ra,56(sp)
    80003e72:	7442                	ld	s0,48(sp)
    80003e74:	74a2                	ld	s1,40(sp)
    80003e76:	7902                	ld	s2,32(sp)
    80003e78:	69e2                	ld	s3,24(sp)
    80003e7a:	6a42                	ld	s4,16(sp)
    80003e7c:	6121                	addi	sp,sp,64
    80003e7e:	8082                	ret
    iput(ip);
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	a32080e7          	jalr	-1486(ra) # 800038b2 <iput>
    return -1;
    80003e88:	557d                	li	a0,-1
    80003e8a:	b7dd                	j	80003e70 <dirlink+0x86>
      panic("dirlink read");
    80003e8c:	00004517          	auipc	a0,0x4
    80003e90:	6fc50513          	addi	a0,a0,1788 # 80008588 <syscalls+0x1c8>
    80003e94:	ffffc097          	auipc	ra,0xffffc
    80003e98:	6ae080e7          	jalr	1710(ra) # 80000542 <panic>
    panic("dirlink");
    80003e9c:	00005517          	auipc	a0,0x5
    80003ea0:	80c50513          	addi	a0,a0,-2036 # 800086a8 <syscalls+0x2e8>
    80003ea4:	ffffc097          	auipc	ra,0xffffc
    80003ea8:	69e080e7          	jalr	1694(ra) # 80000542 <panic>

0000000080003eac <namei>:

struct inode*
namei(char *path)
{
    80003eac:	1101                	addi	sp,sp,-32
    80003eae:	ec06                	sd	ra,24(sp)
    80003eb0:	e822                	sd	s0,16(sp)
    80003eb2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003eb4:	fe040613          	addi	a2,s0,-32
    80003eb8:	4581                	li	a1,0
    80003eba:	00000097          	auipc	ra,0x0
    80003ebe:	dd0080e7          	jalr	-560(ra) # 80003c8a <namex>
}
    80003ec2:	60e2                	ld	ra,24(sp)
    80003ec4:	6442                	ld	s0,16(sp)
    80003ec6:	6105                	addi	sp,sp,32
    80003ec8:	8082                	ret

0000000080003eca <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003eca:	1141                	addi	sp,sp,-16
    80003ecc:	e406                	sd	ra,8(sp)
    80003ece:	e022                	sd	s0,0(sp)
    80003ed0:	0800                	addi	s0,sp,16
    80003ed2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ed4:	4585                	li	a1,1
    80003ed6:	00000097          	auipc	ra,0x0
    80003eda:	db4080e7          	jalr	-588(ra) # 80003c8a <namex>
}
    80003ede:	60a2                	ld	ra,8(sp)
    80003ee0:	6402                	ld	s0,0(sp)
    80003ee2:	0141                	addi	sp,sp,16
    80003ee4:	8082                	ret

0000000080003ee6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ee6:	1101                	addi	sp,sp,-32
    80003ee8:	ec06                	sd	ra,24(sp)
    80003eea:	e822                	sd	s0,16(sp)
    80003eec:	e426                	sd	s1,8(sp)
    80003eee:	e04a                	sd	s2,0(sp)
    80003ef0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ef2:	0001e917          	auipc	s2,0x1e
    80003ef6:	a1690913          	addi	s2,s2,-1514 # 80021908 <log>
    80003efa:	01892583          	lw	a1,24(s2)
    80003efe:	02892503          	lw	a0,40(s2)
    80003f02:	fffff097          	auipc	ra,0xfffff
    80003f06:	ff4080e7          	jalr	-12(ra) # 80002ef6 <bread>
    80003f0a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f0c:	02c92683          	lw	a3,44(s2)
    80003f10:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f12:	02d05763          	blez	a3,80003f40 <write_head+0x5a>
    80003f16:	0001e797          	auipc	a5,0x1e
    80003f1a:	a2278793          	addi	a5,a5,-1502 # 80021938 <log+0x30>
    80003f1e:	05c50713          	addi	a4,a0,92
    80003f22:	36fd                	addiw	a3,a3,-1
    80003f24:	1682                	slli	a3,a3,0x20
    80003f26:	9281                	srli	a3,a3,0x20
    80003f28:	068a                	slli	a3,a3,0x2
    80003f2a:	0001e617          	auipc	a2,0x1e
    80003f2e:	a1260613          	addi	a2,a2,-1518 # 8002193c <log+0x34>
    80003f32:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f34:	4390                	lw	a2,0(a5)
    80003f36:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f38:	0791                	addi	a5,a5,4
    80003f3a:	0711                	addi	a4,a4,4
    80003f3c:	fed79ce3          	bne	a5,a3,80003f34 <write_head+0x4e>
  }
  bwrite(buf);
    80003f40:	8526                	mv	a0,s1
    80003f42:	fffff097          	auipc	ra,0xfffff
    80003f46:	0a6080e7          	jalr	166(ra) # 80002fe8 <bwrite>
  brelse(buf);
    80003f4a:	8526                	mv	a0,s1
    80003f4c:	fffff097          	auipc	ra,0xfffff
    80003f50:	0da080e7          	jalr	218(ra) # 80003026 <brelse>
}
    80003f54:	60e2                	ld	ra,24(sp)
    80003f56:	6442                	ld	s0,16(sp)
    80003f58:	64a2                	ld	s1,8(sp)
    80003f5a:	6902                	ld	s2,0(sp)
    80003f5c:	6105                	addi	sp,sp,32
    80003f5e:	8082                	ret

0000000080003f60 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f60:	0001e797          	auipc	a5,0x1e
    80003f64:	9d47a783          	lw	a5,-1580(a5) # 80021934 <log+0x2c>
    80003f68:	0af05663          	blez	a5,80004014 <install_trans+0xb4>
{
    80003f6c:	7139                	addi	sp,sp,-64
    80003f6e:	fc06                	sd	ra,56(sp)
    80003f70:	f822                	sd	s0,48(sp)
    80003f72:	f426                	sd	s1,40(sp)
    80003f74:	f04a                	sd	s2,32(sp)
    80003f76:	ec4e                	sd	s3,24(sp)
    80003f78:	e852                	sd	s4,16(sp)
    80003f7a:	e456                	sd	s5,8(sp)
    80003f7c:	0080                	addi	s0,sp,64
    80003f7e:	0001ea97          	auipc	s5,0x1e
    80003f82:	9baa8a93          	addi	s5,s5,-1606 # 80021938 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f86:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f88:	0001e997          	auipc	s3,0x1e
    80003f8c:	98098993          	addi	s3,s3,-1664 # 80021908 <log>
    80003f90:	0189a583          	lw	a1,24(s3)
    80003f94:	014585bb          	addw	a1,a1,s4
    80003f98:	2585                	addiw	a1,a1,1
    80003f9a:	0289a503          	lw	a0,40(s3)
    80003f9e:	fffff097          	auipc	ra,0xfffff
    80003fa2:	f58080e7          	jalr	-168(ra) # 80002ef6 <bread>
    80003fa6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fa8:	000aa583          	lw	a1,0(s5)
    80003fac:	0289a503          	lw	a0,40(s3)
    80003fb0:	fffff097          	auipc	ra,0xfffff
    80003fb4:	f46080e7          	jalr	-186(ra) # 80002ef6 <bread>
    80003fb8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003fba:	40000613          	li	a2,1024
    80003fbe:	05890593          	addi	a1,s2,88
    80003fc2:	05850513          	addi	a0,a0,88
    80003fc6:	ffffd097          	auipc	ra,0xffffd
    80003fca:	d90080e7          	jalr	-624(ra) # 80000d56 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fce:	8526                	mv	a0,s1
    80003fd0:	fffff097          	auipc	ra,0xfffff
    80003fd4:	018080e7          	jalr	24(ra) # 80002fe8 <bwrite>
    bunpin(dbuf);
    80003fd8:	8526                	mv	a0,s1
    80003fda:	fffff097          	auipc	ra,0xfffff
    80003fde:	126080e7          	jalr	294(ra) # 80003100 <bunpin>
    brelse(lbuf);
    80003fe2:	854a                	mv	a0,s2
    80003fe4:	fffff097          	auipc	ra,0xfffff
    80003fe8:	042080e7          	jalr	66(ra) # 80003026 <brelse>
    brelse(dbuf);
    80003fec:	8526                	mv	a0,s1
    80003fee:	fffff097          	auipc	ra,0xfffff
    80003ff2:	038080e7          	jalr	56(ra) # 80003026 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ff6:	2a05                	addiw	s4,s4,1
    80003ff8:	0a91                	addi	s5,s5,4
    80003ffa:	02c9a783          	lw	a5,44(s3)
    80003ffe:	f8fa49e3          	blt	s4,a5,80003f90 <install_trans+0x30>
}
    80004002:	70e2                	ld	ra,56(sp)
    80004004:	7442                	ld	s0,48(sp)
    80004006:	74a2                	ld	s1,40(sp)
    80004008:	7902                	ld	s2,32(sp)
    8000400a:	69e2                	ld	s3,24(sp)
    8000400c:	6a42                	ld	s4,16(sp)
    8000400e:	6aa2                	ld	s5,8(sp)
    80004010:	6121                	addi	sp,sp,64
    80004012:	8082                	ret
    80004014:	8082                	ret

0000000080004016 <initlog>:
{
    80004016:	7179                	addi	sp,sp,-48
    80004018:	f406                	sd	ra,40(sp)
    8000401a:	f022                	sd	s0,32(sp)
    8000401c:	ec26                	sd	s1,24(sp)
    8000401e:	e84a                	sd	s2,16(sp)
    80004020:	e44e                	sd	s3,8(sp)
    80004022:	1800                	addi	s0,sp,48
    80004024:	892a                	mv	s2,a0
    80004026:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004028:	0001e497          	auipc	s1,0x1e
    8000402c:	8e048493          	addi	s1,s1,-1824 # 80021908 <log>
    80004030:	00004597          	auipc	a1,0x4
    80004034:	56858593          	addi	a1,a1,1384 # 80008598 <syscalls+0x1d8>
    80004038:	8526                	mv	a0,s1
    8000403a:	ffffd097          	auipc	ra,0xffffd
    8000403e:	b34080e7          	jalr	-1228(ra) # 80000b6e <initlock>
  log.start = sb->logstart;
    80004042:	0149a583          	lw	a1,20(s3)
    80004046:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004048:	0109a783          	lw	a5,16(s3)
    8000404c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000404e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004052:	854a                	mv	a0,s2
    80004054:	fffff097          	auipc	ra,0xfffff
    80004058:	ea2080e7          	jalr	-350(ra) # 80002ef6 <bread>
  log.lh.n = lh->n;
    8000405c:	4d34                	lw	a3,88(a0)
    8000405e:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004060:	02d05563          	blez	a3,8000408a <initlog+0x74>
    80004064:	05c50793          	addi	a5,a0,92
    80004068:	0001e717          	auipc	a4,0x1e
    8000406c:	8d070713          	addi	a4,a4,-1840 # 80021938 <log+0x30>
    80004070:	36fd                	addiw	a3,a3,-1
    80004072:	1682                	slli	a3,a3,0x20
    80004074:	9281                	srli	a3,a3,0x20
    80004076:	068a                	slli	a3,a3,0x2
    80004078:	06050613          	addi	a2,a0,96
    8000407c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000407e:	4390                	lw	a2,0(a5)
    80004080:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004082:	0791                	addi	a5,a5,4
    80004084:	0711                	addi	a4,a4,4
    80004086:	fed79ce3          	bne	a5,a3,8000407e <initlog+0x68>
  brelse(buf);
    8000408a:	fffff097          	auipc	ra,0xfffff
    8000408e:	f9c080e7          	jalr	-100(ra) # 80003026 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004092:	00000097          	auipc	ra,0x0
    80004096:	ece080e7          	jalr	-306(ra) # 80003f60 <install_trans>
  log.lh.n = 0;
    8000409a:	0001e797          	auipc	a5,0x1e
    8000409e:	8807ad23          	sw	zero,-1894(a5) # 80021934 <log+0x2c>
  write_head(); // clear the log
    800040a2:	00000097          	auipc	ra,0x0
    800040a6:	e44080e7          	jalr	-444(ra) # 80003ee6 <write_head>
}
    800040aa:	70a2                	ld	ra,40(sp)
    800040ac:	7402                	ld	s0,32(sp)
    800040ae:	64e2                	ld	s1,24(sp)
    800040b0:	6942                	ld	s2,16(sp)
    800040b2:	69a2                	ld	s3,8(sp)
    800040b4:	6145                	addi	sp,sp,48
    800040b6:	8082                	ret

00000000800040b8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040b8:	1101                	addi	sp,sp,-32
    800040ba:	ec06                	sd	ra,24(sp)
    800040bc:	e822                	sd	s0,16(sp)
    800040be:	e426                	sd	s1,8(sp)
    800040c0:	e04a                	sd	s2,0(sp)
    800040c2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040c4:	0001e517          	auipc	a0,0x1e
    800040c8:	84450513          	addi	a0,a0,-1980 # 80021908 <log>
    800040cc:	ffffd097          	auipc	ra,0xffffd
    800040d0:	b32080e7          	jalr	-1230(ra) # 80000bfe <acquire>
  while(1){
    if(log.committing){
    800040d4:	0001e497          	auipc	s1,0x1e
    800040d8:	83448493          	addi	s1,s1,-1996 # 80021908 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040dc:	4979                	li	s2,30
    800040de:	a039                	j	800040ec <begin_op+0x34>
      sleep(&log, &log.lock);
    800040e0:	85a6                	mv	a1,s1
    800040e2:	8526                	mv	a0,s1
    800040e4:	ffffe097          	auipc	ra,0xffffe
    800040e8:	1c4080e7          	jalr	452(ra) # 800022a8 <sleep>
    if(log.committing){
    800040ec:	50dc                	lw	a5,36(s1)
    800040ee:	fbed                	bnez	a5,800040e0 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040f0:	509c                	lw	a5,32(s1)
    800040f2:	0017871b          	addiw	a4,a5,1
    800040f6:	0007069b          	sext.w	a3,a4
    800040fa:	0027179b          	slliw	a5,a4,0x2
    800040fe:	9fb9                	addw	a5,a5,a4
    80004100:	0017979b          	slliw	a5,a5,0x1
    80004104:	54d8                	lw	a4,44(s1)
    80004106:	9fb9                	addw	a5,a5,a4
    80004108:	00f95963          	bge	s2,a5,8000411a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000410c:	85a6                	mv	a1,s1
    8000410e:	8526                	mv	a0,s1
    80004110:	ffffe097          	auipc	ra,0xffffe
    80004114:	198080e7          	jalr	408(ra) # 800022a8 <sleep>
    80004118:	bfd1                	j	800040ec <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000411a:	0001d517          	auipc	a0,0x1d
    8000411e:	7ee50513          	addi	a0,a0,2030 # 80021908 <log>
    80004122:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004124:	ffffd097          	auipc	ra,0xffffd
    80004128:	b8e080e7          	jalr	-1138(ra) # 80000cb2 <release>
      break;
    }
  }
}
    8000412c:	60e2                	ld	ra,24(sp)
    8000412e:	6442                	ld	s0,16(sp)
    80004130:	64a2                	ld	s1,8(sp)
    80004132:	6902                	ld	s2,0(sp)
    80004134:	6105                	addi	sp,sp,32
    80004136:	8082                	ret

0000000080004138 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004138:	7139                	addi	sp,sp,-64
    8000413a:	fc06                	sd	ra,56(sp)
    8000413c:	f822                	sd	s0,48(sp)
    8000413e:	f426                	sd	s1,40(sp)
    80004140:	f04a                	sd	s2,32(sp)
    80004142:	ec4e                	sd	s3,24(sp)
    80004144:	e852                	sd	s4,16(sp)
    80004146:	e456                	sd	s5,8(sp)
    80004148:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000414a:	0001d497          	auipc	s1,0x1d
    8000414e:	7be48493          	addi	s1,s1,1982 # 80021908 <log>
    80004152:	8526                	mv	a0,s1
    80004154:	ffffd097          	auipc	ra,0xffffd
    80004158:	aaa080e7          	jalr	-1366(ra) # 80000bfe <acquire>
  log.outstanding -= 1;
    8000415c:	509c                	lw	a5,32(s1)
    8000415e:	37fd                	addiw	a5,a5,-1
    80004160:	0007891b          	sext.w	s2,a5
    80004164:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004166:	50dc                	lw	a5,36(s1)
    80004168:	e7b9                	bnez	a5,800041b6 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000416a:	04091e63          	bnez	s2,800041c6 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000416e:	0001d497          	auipc	s1,0x1d
    80004172:	79a48493          	addi	s1,s1,1946 # 80021908 <log>
    80004176:	4785                	li	a5,1
    80004178:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000417a:	8526                	mv	a0,s1
    8000417c:	ffffd097          	auipc	ra,0xffffd
    80004180:	b36080e7          	jalr	-1226(ra) # 80000cb2 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004184:	54dc                	lw	a5,44(s1)
    80004186:	06f04763          	bgtz	a5,800041f4 <end_op+0xbc>
    acquire(&log.lock);
    8000418a:	0001d497          	auipc	s1,0x1d
    8000418e:	77e48493          	addi	s1,s1,1918 # 80021908 <log>
    80004192:	8526                	mv	a0,s1
    80004194:	ffffd097          	auipc	ra,0xffffd
    80004198:	a6a080e7          	jalr	-1430(ra) # 80000bfe <acquire>
    log.committing = 0;
    8000419c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800041a0:	8526                	mv	a0,s1
    800041a2:	ffffe097          	auipc	ra,0xffffe
    800041a6:	286080e7          	jalr	646(ra) # 80002428 <wakeup>
    release(&log.lock);
    800041aa:	8526                	mv	a0,s1
    800041ac:	ffffd097          	auipc	ra,0xffffd
    800041b0:	b06080e7          	jalr	-1274(ra) # 80000cb2 <release>
}
    800041b4:	a03d                	j	800041e2 <end_op+0xaa>
    panic("log.committing");
    800041b6:	00004517          	auipc	a0,0x4
    800041ba:	3ea50513          	addi	a0,a0,1002 # 800085a0 <syscalls+0x1e0>
    800041be:	ffffc097          	auipc	ra,0xffffc
    800041c2:	384080e7          	jalr	900(ra) # 80000542 <panic>
    wakeup(&log);
    800041c6:	0001d497          	auipc	s1,0x1d
    800041ca:	74248493          	addi	s1,s1,1858 # 80021908 <log>
    800041ce:	8526                	mv	a0,s1
    800041d0:	ffffe097          	auipc	ra,0xffffe
    800041d4:	258080e7          	jalr	600(ra) # 80002428 <wakeup>
  release(&log.lock);
    800041d8:	8526                	mv	a0,s1
    800041da:	ffffd097          	auipc	ra,0xffffd
    800041de:	ad8080e7          	jalr	-1320(ra) # 80000cb2 <release>
}
    800041e2:	70e2                	ld	ra,56(sp)
    800041e4:	7442                	ld	s0,48(sp)
    800041e6:	74a2                	ld	s1,40(sp)
    800041e8:	7902                	ld	s2,32(sp)
    800041ea:	69e2                	ld	s3,24(sp)
    800041ec:	6a42                	ld	s4,16(sp)
    800041ee:	6aa2                	ld	s5,8(sp)
    800041f0:	6121                	addi	sp,sp,64
    800041f2:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041f4:	0001da97          	auipc	s5,0x1d
    800041f8:	744a8a93          	addi	s5,s5,1860 # 80021938 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041fc:	0001da17          	auipc	s4,0x1d
    80004200:	70ca0a13          	addi	s4,s4,1804 # 80021908 <log>
    80004204:	018a2583          	lw	a1,24(s4)
    80004208:	012585bb          	addw	a1,a1,s2
    8000420c:	2585                	addiw	a1,a1,1
    8000420e:	028a2503          	lw	a0,40(s4)
    80004212:	fffff097          	auipc	ra,0xfffff
    80004216:	ce4080e7          	jalr	-796(ra) # 80002ef6 <bread>
    8000421a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000421c:	000aa583          	lw	a1,0(s5)
    80004220:	028a2503          	lw	a0,40(s4)
    80004224:	fffff097          	auipc	ra,0xfffff
    80004228:	cd2080e7          	jalr	-814(ra) # 80002ef6 <bread>
    8000422c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000422e:	40000613          	li	a2,1024
    80004232:	05850593          	addi	a1,a0,88
    80004236:	05848513          	addi	a0,s1,88
    8000423a:	ffffd097          	auipc	ra,0xffffd
    8000423e:	b1c080e7          	jalr	-1252(ra) # 80000d56 <memmove>
    bwrite(to);  // write the log
    80004242:	8526                	mv	a0,s1
    80004244:	fffff097          	auipc	ra,0xfffff
    80004248:	da4080e7          	jalr	-604(ra) # 80002fe8 <bwrite>
    brelse(from);
    8000424c:	854e                	mv	a0,s3
    8000424e:	fffff097          	auipc	ra,0xfffff
    80004252:	dd8080e7          	jalr	-552(ra) # 80003026 <brelse>
    brelse(to);
    80004256:	8526                	mv	a0,s1
    80004258:	fffff097          	auipc	ra,0xfffff
    8000425c:	dce080e7          	jalr	-562(ra) # 80003026 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004260:	2905                	addiw	s2,s2,1
    80004262:	0a91                	addi	s5,s5,4
    80004264:	02ca2783          	lw	a5,44(s4)
    80004268:	f8f94ee3          	blt	s2,a5,80004204 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000426c:	00000097          	auipc	ra,0x0
    80004270:	c7a080e7          	jalr	-902(ra) # 80003ee6 <write_head>
    install_trans(); // Now install writes to home locations
    80004274:	00000097          	auipc	ra,0x0
    80004278:	cec080e7          	jalr	-788(ra) # 80003f60 <install_trans>
    log.lh.n = 0;
    8000427c:	0001d797          	auipc	a5,0x1d
    80004280:	6a07ac23          	sw	zero,1720(a5) # 80021934 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004284:	00000097          	auipc	ra,0x0
    80004288:	c62080e7          	jalr	-926(ra) # 80003ee6 <write_head>
    8000428c:	bdfd                	j	8000418a <end_op+0x52>

000000008000428e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000428e:	1101                	addi	sp,sp,-32
    80004290:	ec06                	sd	ra,24(sp)
    80004292:	e822                	sd	s0,16(sp)
    80004294:	e426                	sd	s1,8(sp)
    80004296:	e04a                	sd	s2,0(sp)
    80004298:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000429a:	0001d717          	auipc	a4,0x1d
    8000429e:	69a72703          	lw	a4,1690(a4) # 80021934 <log+0x2c>
    800042a2:	47f5                	li	a5,29
    800042a4:	08e7c063          	blt	a5,a4,80004324 <log_write+0x96>
    800042a8:	84aa                	mv	s1,a0
    800042aa:	0001d797          	auipc	a5,0x1d
    800042ae:	67a7a783          	lw	a5,1658(a5) # 80021924 <log+0x1c>
    800042b2:	37fd                	addiw	a5,a5,-1
    800042b4:	06f75863          	bge	a4,a5,80004324 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042b8:	0001d797          	auipc	a5,0x1d
    800042bc:	6707a783          	lw	a5,1648(a5) # 80021928 <log+0x20>
    800042c0:	06f05a63          	blez	a5,80004334 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800042c4:	0001d917          	auipc	s2,0x1d
    800042c8:	64490913          	addi	s2,s2,1604 # 80021908 <log>
    800042cc:	854a                	mv	a0,s2
    800042ce:	ffffd097          	auipc	ra,0xffffd
    800042d2:	930080e7          	jalr	-1744(ra) # 80000bfe <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800042d6:	02c92603          	lw	a2,44(s2)
    800042da:	06c05563          	blez	a2,80004344 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800042de:	44cc                	lw	a1,12(s1)
    800042e0:	0001d717          	auipc	a4,0x1d
    800042e4:	65870713          	addi	a4,a4,1624 # 80021938 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800042e8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800042ea:	4314                	lw	a3,0(a4)
    800042ec:	04b68d63          	beq	a3,a1,80004346 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    800042f0:	2785                	addiw	a5,a5,1
    800042f2:	0711                	addi	a4,a4,4
    800042f4:	fec79be3          	bne	a5,a2,800042ea <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042f8:	0621                	addi	a2,a2,8
    800042fa:	060a                	slli	a2,a2,0x2
    800042fc:	0001d797          	auipc	a5,0x1d
    80004300:	60c78793          	addi	a5,a5,1548 # 80021908 <log>
    80004304:	963e                	add	a2,a2,a5
    80004306:	44dc                	lw	a5,12(s1)
    80004308:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000430a:	8526                	mv	a0,s1
    8000430c:	fffff097          	auipc	ra,0xfffff
    80004310:	db8080e7          	jalr	-584(ra) # 800030c4 <bpin>
    log.lh.n++;
    80004314:	0001d717          	auipc	a4,0x1d
    80004318:	5f470713          	addi	a4,a4,1524 # 80021908 <log>
    8000431c:	575c                	lw	a5,44(a4)
    8000431e:	2785                	addiw	a5,a5,1
    80004320:	d75c                	sw	a5,44(a4)
    80004322:	a83d                	j	80004360 <log_write+0xd2>
    panic("too big a transaction");
    80004324:	00004517          	auipc	a0,0x4
    80004328:	28c50513          	addi	a0,a0,652 # 800085b0 <syscalls+0x1f0>
    8000432c:	ffffc097          	auipc	ra,0xffffc
    80004330:	216080e7          	jalr	534(ra) # 80000542 <panic>
    panic("log_write outside of trans");
    80004334:	00004517          	auipc	a0,0x4
    80004338:	29450513          	addi	a0,a0,660 # 800085c8 <syscalls+0x208>
    8000433c:	ffffc097          	auipc	ra,0xffffc
    80004340:	206080e7          	jalr	518(ra) # 80000542 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004344:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004346:	00878713          	addi	a4,a5,8
    8000434a:	00271693          	slli	a3,a4,0x2
    8000434e:	0001d717          	auipc	a4,0x1d
    80004352:	5ba70713          	addi	a4,a4,1466 # 80021908 <log>
    80004356:	9736                	add	a4,a4,a3
    80004358:	44d4                	lw	a3,12(s1)
    8000435a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000435c:	faf607e3          	beq	a2,a5,8000430a <log_write+0x7c>
  }
  release(&log.lock);
    80004360:	0001d517          	auipc	a0,0x1d
    80004364:	5a850513          	addi	a0,a0,1448 # 80021908 <log>
    80004368:	ffffd097          	auipc	ra,0xffffd
    8000436c:	94a080e7          	jalr	-1718(ra) # 80000cb2 <release>
}
    80004370:	60e2                	ld	ra,24(sp)
    80004372:	6442                	ld	s0,16(sp)
    80004374:	64a2                	ld	s1,8(sp)
    80004376:	6902                	ld	s2,0(sp)
    80004378:	6105                	addi	sp,sp,32
    8000437a:	8082                	ret

000000008000437c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000437c:	1101                	addi	sp,sp,-32
    8000437e:	ec06                	sd	ra,24(sp)
    80004380:	e822                	sd	s0,16(sp)
    80004382:	e426                	sd	s1,8(sp)
    80004384:	e04a                	sd	s2,0(sp)
    80004386:	1000                	addi	s0,sp,32
    80004388:	84aa                	mv	s1,a0
    8000438a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000438c:	00004597          	auipc	a1,0x4
    80004390:	25c58593          	addi	a1,a1,604 # 800085e8 <syscalls+0x228>
    80004394:	0521                	addi	a0,a0,8
    80004396:	ffffc097          	auipc	ra,0xffffc
    8000439a:	7d8080e7          	jalr	2008(ra) # 80000b6e <initlock>
  lk->name = name;
    8000439e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043a2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043a6:	0204a423          	sw	zero,40(s1)
}
    800043aa:	60e2                	ld	ra,24(sp)
    800043ac:	6442                	ld	s0,16(sp)
    800043ae:	64a2                	ld	s1,8(sp)
    800043b0:	6902                	ld	s2,0(sp)
    800043b2:	6105                	addi	sp,sp,32
    800043b4:	8082                	ret

00000000800043b6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043b6:	1101                	addi	sp,sp,-32
    800043b8:	ec06                	sd	ra,24(sp)
    800043ba:	e822                	sd	s0,16(sp)
    800043bc:	e426                	sd	s1,8(sp)
    800043be:	e04a                	sd	s2,0(sp)
    800043c0:	1000                	addi	s0,sp,32
    800043c2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043c4:	00850913          	addi	s2,a0,8
    800043c8:	854a                	mv	a0,s2
    800043ca:	ffffd097          	auipc	ra,0xffffd
    800043ce:	834080e7          	jalr	-1996(ra) # 80000bfe <acquire>
  while (lk->locked) {
    800043d2:	409c                	lw	a5,0(s1)
    800043d4:	cb89                	beqz	a5,800043e6 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043d6:	85ca                	mv	a1,s2
    800043d8:	8526                	mv	a0,s1
    800043da:	ffffe097          	auipc	ra,0xffffe
    800043de:	ece080e7          	jalr	-306(ra) # 800022a8 <sleep>
  while (lk->locked) {
    800043e2:	409c                	lw	a5,0(s1)
    800043e4:	fbed                	bnez	a5,800043d6 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043e6:	4785                	li	a5,1
    800043e8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043ea:	ffffd097          	auipc	ra,0xffffd
    800043ee:	6aa080e7          	jalr	1706(ra) # 80001a94 <myproc>
    800043f2:	5d1c                	lw	a5,56(a0)
    800043f4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043f6:	854a                	mv	a0,s2
    800043f8:	ffffd097          	auipc	ra,0xffffd
    800043fc:	8ba080e7          	jalr	-1862(ra) # 80000cb2 <release>
}
    80004400:	60e2                	ld	ra,24(sp)
    80004402:	6442                	ld	s0,16(sp)
    80004404:	64a2                	ld	s1,8(sp)
    80004406:	6902                	ld	s2,0(sp)
    80004408:	6105                	addi	sp,sp,32
    8000440a:	8082                	ret

000000008000440c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000440c:	1101                	addi	sp,sp,-32
    8000440e:	ec06                	sd	ra,24(sp)
    80004410:	e822                	sd	s0,16(sp)
    80004412:	e426                	sd	s1,8(sp)
    80004414:	e04a                	sd	s2,0(sp)
    80004416:	1000                	addi	s0,sp,32
    80004418:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000441a:	00850913          	addi	s2,a0,8
    8000441e:	854a                	mv	a0,s2
    80004420:	ffffc097          	auipc	ra,0xffffc
    80004424:	7de080e7          	jalr	2014(ra) # 80000bfe <acquire>
  lk->locked = 0;
    80004428:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000442c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004430:	8526                	mv	a0,s1
    80004432:	ffffe097          	auipc	ra,0xffffe
    80004436:	ff6080e7          	jalr	-10(ra) # 80002428 <wakeup>
  release(&lk->lk);
    8000443a:	854a                	mv	a0,s2
    8000443c:	ffffd097          	auipc	ra,0xffffd
    80004440:	876080e7          	jalr	-1930(ra) # 80000cb2 <release>
}
    80004444:	60e2                	ld	ra,24(sp)
    80004446:	6442                	ld	s0,16(sp)
    80004448:	64a2                	ld	s1,8(sp)
    8000444a:	6902                	ld	s2,0(sp)
    8000444c:	6105                	addi	sp,sp,32
    8000444e:	8082                	ret

0000000080004450 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004450:	7179                	addi	sp,sp,-48
    80004452:	f406                	sd	ra,40(sp)
    80004454:	f022                	sd	s0,32(sp)
    80004456:	ec26                	sd	s1,24(sp)
    80004458:	e84a                	sd	s2,16(sp)
    8000445a:	e44e                	sd	s3,8(sp)
    8000445c:	1800                	addi	s0,sp,48
    8000445e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004460:	00850913          	addi	s2,a0,8
    80004464:	854a                	mv	a0,s2
    80004466:	ffffc097          	auipc	ra,0xffffc
    8000446a:	798080e7          	jalr	1944(ra) # 80000bfe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000446e:	409c                	lw	a5,0(s1)
    80004470:	ef99                	bnez	a5,8000448e <holdingsleep+0x3e>
    80004472:	4481                	li	s1,0
  release(&lk->lk);
    80004474:	854a                	mv	a0,s2
    80004476:	ffffd097          	auipc	ra,0xffffd
    8000447a:	83c080e7          	jalr	-1988(ra) # 80000cb2 <release>
  return r;
}
    8000447e:	8526                	mv	a0,s1
    80004480:	70a2                	ld	ra,40(sp)
    80004482:	7402                	ld	s0,32(sp)
    80004484:	64e2                	ld	s1,24(sp)
    80004486:	6942                	ld	s2,16(sp)
    80004488:	69a2                	ld	s3,8(sp)
    8000448a:	6145                	addi	sp,sp,48
    8000448c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000448e:	0284a983          	lw	s3,40(s1)
    80004492:	ffffd097          	auipc	ra,0xffffd
    80004496:	602080e7          	jalr	1538(ra) # 80001a94 <myproc>
    8000449a:	5d04                	lw	s1,56(a0)
    8000449c:	413484b3          	sub	s1,s1,s3
    800044a0:	0014b493          	seqz	s1,s1
    800044a4:	bfc1                	j	80004474 <holdingsleep+0x24>

00000000800044a6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044a6:	1141                	addi	sp,sp,-16
    800044a8:	e406                	sd	ra,8(sp)
    800044aa:	e022                	sd	s0,0(sp)
    800044ac:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044ae:	00004597          	auipc	a1,0x4
    800044b2:	14a58593          	addi	a1,a1,330 # 800085f8 <syscalls+0x238>
    800044b6:	0001d517          	auipc	a0,0x1d
    800044ba:	59a50513          	addi	a0,a0,1434 # 80021a50 <ftable>
    800044be:	ffffc097          	auipc	ra,0xffffc
    800044c2:	6b0080e7          	jalr	1712(ra) # 80000b6e <initlock>
}
    800044c6:	60a2                	ld	ra,8(sp)
    800044c8:	6402                	ld	s0,0(sp)
    800044ca:	0141                	addi	sp,sp,16
    800044cc:	8082                	ret

00000000800044ce <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044ce:	1101                	addi	sp,sp,-32
    800044d0:	ec06                	sd	ra,24(sp)
    800044d2:	e822                	sd	s0,16(sp)
    800044d4:	e426                	sd	s1,8(sp)
    800044d6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044d8:	0001d517          	auipc	a0,0x1d
    800044dc:	57850513          	addi	a0,a0,1400 # 80021a50 <ftable>
    800044e0:	ffffc097          	auipc	ra,0xffffc
    800044e4:	71e080e7          	jalr	1822(ra) # 80000bfe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044e8:	0001d497          	auipc	s1,0x1d
    800044ec:	58048493          	addi	s1,s1,1408 # 80021a68 <ftable+0x18>
    800044f0:	0001e717          	auipc	a4,0x1e
    800044f4:	51870713          	addi	a4,a4,1304 # 80022a08 <ftable+0xfb8>
    if(f->ref == 0){
    800044f8:	40dc                	lw	a5,4(s1)
    800044fa:	cf99                	beqz	a5,80004518 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044fc:	02848493          	addi	s1,s1,40
    80004500:	fee49ce3          	bne	s1,a4,800044f8 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004504:	0001d517          	auipc	a0,0x1d
    80004508:	54c50513          	addi	a0,a0,1356 # 80021a50 <ftable>
    8000450c:	ffffc097          	auipc	ra,0xffffc
    80004510:	7a6080e7          	jalr	1958(ra) # 80000cb2 <release>
  return 0;
    80004514:	4481                	li	s1,0
    80004516:	a819                	j	8000452c <filealloc+0x5e>
      f->ref = 1;
    80004518:	4785                	li	a5,1
    8000451a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000451c:	0001d517          	auipc	a0,0x1d
    80004520:	53450513          	addi	a0,a0,1332 # 80021a50 <ftable>
    80004524:	ffffc097          	auipc	ra,0xffffc
    80004528:	78e080e7          	jalr	1934(ra) # 80000cb2 <release>
}
    8000452c:	8526                	mv	a0,s1
    8000452e:	60e2                	ld	ra,24(sp)
    80004530:	6442                	ld	s0,16(sp)
    80004532:	64a2                	ld	s1,8(sp)
    80004534:	6105                	addi	sp,sp,32
    80004536:	8082                	ret

0000000080004538 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004538:	1101                	addi	sp,sp,-32
    8000453a:	ec06                	sd	ra,24(sp)
    8000453c:	e822                	sd	s0,16(sp)
    8000453e:	e426                	sd	s1,8(sp)
    80004540:	1000                	addi	s0,sp,32
    80004542:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004544:	0001d517          	auipc	a0,0x1d
    80004548:	50c50513          	addi	a0,a0,1292 # 80021a50 <ftable>
    8000454c:	ffffc097          	auipc	ra,0xffffc
    80004550:	6b2080e7          	jalr	1714(ra) # 80000bfe <acquire>
  if(f->ref < 1)
    80004554:	40dc                	lw	a5,4(s1)
    80004556:	02f05263          	blez	a5,8000457a <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000455a:	2785                	addiw	a5,a5,1
    8000455c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000455e:	0001d517          	auipc	a0,0x1d
    80004562:	4f250513          	addi	a0,a0,1266 # 80021a50 <ftable>
    80004566:	ffffc097          	auipc	ra,0xffffc
    8000456a:	74c080e7          	jalr	1868(ra) # 80000cb2 <release>
  return f;
}
    8000456e:	8526                	mv	a0,s1
    80004570:	60e2                	ld	ra,24(sp)
    80004572:	6442                	ld	s0,16(sp)
    80004574:	64a2                	ld	s1,8(sp)
    80004576:	6105                	addi	sp,sp,32
    80004578:	8082                	ret
    panic("filedup");
    8000457a:	00004517          	auipc	a0,0x4
    8000457e:	08650513          	addi	a0,a0,134 # 80008600 <syscalls+0x240>
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	fc0080e7          	jalr	-64(ra) # 80000542 <panic>

000000008000458a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000458a:	7139                	addi	sp,sp,-64
    8000458c:	fc06                	sd	ra,56(sp)
    8000458e:	f822                	sd	s0,48(sp)
    80004590:	f426                	sd	s1,40(sp)
    80004592:	f04a                	sd	s2,32(sp)
    80004594:	ec4e                	sd	s3,24(sp)
    80004596:	e852                	sd	s4,16(sp)
    80004598:	e456                	sd	s5,8(sp)
    8000459a:	0080                	addi	s0,sp,64
    8000459c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000459e:	0001d517          	auipc	a0,0x1d
    800045a2:	4b250513          	addi	a0,a0,1202 # 80021a50 <ftable>
    800045a6:	ffffc097          	auipc	ra,0xffffc
    800045aa:	658080e7          	jalr	1624(ra) # 80000bfe <acquire>
  if(f->ref < 1)
    800045ae:	40dc                	lw	a5,4(s1)
    800045b0:	06f05163          	blez	a5,80004612 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800045b4:	37fd                	addiw	a5,a5,-1
    800045b6:	0007871b          	sext.w	a4,a5
    800045ba:	c0dc                	sw	a5,4(s1)
    800045bc:	06e04363          	bgtz	a4,80004622 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045c0:	0004a903          	lw	s2,0(s1)
    800045c4:	0094ca83          	lbu	s5,9(s1)
    800045c8:	0104ba03          	ld	s4,16(s1)
    800045cc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045d0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045d4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045d8:	0001d517          	auipc	a0,0x1d
    800045dc:	47850513          	addi	a0,a0,1144 # 80021a50 <ftable>
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	6d2080e7          	jalr	1746(ra) # 80000cb2 <release>

  if(ff.type == FD_PIPE){
    800045e8:	4785                	li	a5,1
    800045ea:	04f90d63          	beq	s2,a5,80004644 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045ee:	3979                	addiw	s2,s2,-2
    800045f0:	4785                	li	a5,1
    800045f2:	0527e063          	bltu	a5,s2,80004632 <fileclose+0xa8>
    begin_op();
    800045f6:	00000097          	auipc	ra,0x0
    800045fa:	ac2080e7          	jalr	-1342(ra) # 800040b8 <begin_op>
    iput(ff.ip);
    800045fe:	854e                	mv	a0,s3
    80004600:	fffff097          	auipc	ra,0xfffff
    80004604:	2b2080e7          	jalr	690(ra) # 800038b2 <iput>
    end_op();
    80004608:	00000097          	auipc	ra,0x0
    8000460c:	b30080e7          	jalr	-1232(ra) # 80004138 <end_op>
    80004610:	a00d                	j	80004632 <fileclose+0xa8>
    panic("fileclose");
    80004612:	00004517          	auipc	a0,0x4
    80004616:	ff650513          	addi	a0,a0,-10 # 80008608 <syscalls+0x248>
    8000461a:	ffffc097          	auipc	ra,0xffffc
    8000461e:	f28080e7          	jalr	-216(ra) # 80000542 <panic>
    release(&ftable.lock);
    80004622:	0001d517          	auipc	a0,0x1d
    80004626:	42e50513          	addi	a0,a0,1070 # 80021a50 <ftable>
    8000462a:	ffffc097          	auipc	ra,0xffffc
    8000462e:	688080e7          	jalr	1672(ra) # 80000cb2 <release>
  }
}
    80004632:	70e2                	ld	ra,56(sp)
    80004634:	7442                	ld	s0,48(sp)
    80004636:	74a2                	ld	s1,40(sp)
    80004638:	7902                	ld	s2,32(sp)
    8000463a:	69e2                	ld	s3,24(sp)
    8000463c:	6a42                	ld	s4,16(sp)
    8000463e:	6aa2                	ld	s5,8(sp)
    80004640:	6121                	addi	sp,sp,64
    80004642:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004644:	85d6                	mv	a1,s5
    80004646:	8552                	mv	a0,s4
    80004648:	00000097          	auipc	ra,0x0
    8000464c:	372080e7          	jalr	882(ra) # 800049ba <pipeclose>
    80004650:	b7cd                	j	80004632 <fileclose+0xa8>

0000000080004652 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004652:	715d                	addi	sp,sp,-80
    80004654:	e486                	sd	ra,72(sp)
    80004656:	e0a2                	sd	s0,64(sp)
    80004658:	fc26                	sd	s1,56(sp)
    8000465a:	f84a                	sd	s2,48(sp)
    8000465c:	f44e                	sd	s3,40(sp)
    8000465e:	0880                	addi	s0,sp,80
    80004660:	84aa                	mv	s1,a0
    80004662:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004664:	ffffd097          	auipc	ra,0xffffd
    80004668:	430080e7          	jalr	1072(ra) # 80001a94 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000466c:	409c                	lw	a5,0(s1)
    8000466e:	37f9                	addiw	a5,a5,-2
    80004670:	4705                	li	a4,1
    80004672:	04f76763          	bltu	a4,a5,800046c0 <filestat+0x6e>
    80004676:	892a                	mv	s2,a0
    ilock(f->ip);
    80004678:	6c88                	ld	a0,24(s1)
    8000467a:	fffff097          	auipc	ra,0xfffff
    8000467e:	07e080e7          	jalr	126(ra) # 800036f8 <ilock>
    stati(f->ip, &st);
    80004682:	fb840593          	addi	a1,s0,-72
    80004686:	6c88                	ld	a0,24(s1)
    80004688:	fffff097          	auipc	ra,0xfffff
    8000468c:	2fa080e7          	jalr	762(ra) # 80003982 <stati>
    iunlock(f->ip);
    80004690:	6c88                	ld	a0,24(s1)
    80004692:	fffff097          	auipc	ra,0xfffff
    80004696:	128080e7          	jalr	296(ra) # 800037ba <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000469a:	46e1                	li	a3,24
    8000469c:	fb840613          	addi	a2,s0,-72
    800046a0:	85ce                	mv	a1,s3
    800046a2:	05093503          	ld	a0,80(s2)
    800046a6:	ffffd097          	auipc	ra,0xffffd
    800046aa:	fdc080e7          	jalr	-36(ra) # 80001682 <copyout>
    800046ae:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800046b2:	60a6                	ld	ra,72(sp)
    800046b4:	6406                	ld	s0,64(sp)
    800046b6:	74e2                	ld	s1,56(sp)
    800046b8:	7942                	ld	s2,48(sp)
    800046ba:	79a2                	ld	s3,40(sp)
    800046bc:	6161                	addi	sp,sp,80
    800046be:	8082                	ret
  return -1;
    800046c0:	557d                	li	a0,-1
    800046c2:	bfc5                	j	800046b2 <filestat+0x60>

00000000800046c4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046c4:	7179                	addi	sp,sp,-48
    800046c6:	f406                	sd	ra,40(sp)
    800046c8:	f022                	sd	s0,32(sp)
    800046ca:	ec26                	sd	s1,24(sp)
    800046cc:	e84a                	sd	s2,16(sp)
    800046ce:	e44e                	sd	s3,8(sp)
    800046d0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046d2:	00854783          	lbu	a5,8(a0)
    800046d6:	c3d5                	beqz	a5,8000477a <fileread+0xb6>
    800046d8:	84aa                	mv	s1,a0
    800046da:	89ae                	mv	s3,a1
    800046dc:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046de:	411c                	lw	a5,0(a0)
    800046e0:	4705                	li	a4,1
    800046e2:	04e78963          	beq	a5,a4,80004734 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046e6:	470d                	li	a4,3
    800046e8:	04e78d63          	beq	a5,a4,80004742 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046ec:	4709                	li	a4,2
    800046ee:	06e79e63          	bne	a5,a4,8000476a <fileread+0xa6>
    ilock(f->ip);
    800046f2:	6d08                	ld	a0,24(a0)
    800046f4:	fffff097          	auipc	ra,0xfffff
    800046f8:	004080e7          	jalr	4(ra) # 800036f8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046fc:	874a                	mv	a4,s2
    800046fe:	5094                	lw	a3,32(s1)
    80004700:	864e                	mv	a2,s3
    80004702:	4585                	li	a1,1
    80004704:	6c88                	ld	a0,24(s1)
    80004706:	fffff097          	auipc	ra,0xfffff
    8000470a:	2a6080e7          	jalr	678(ra) # 800039ac <readi>
    8000470e:	892a                	mv	s2,a0
    80004710:	00a05563          	blez	a0,8000471a <fileread+0x56>
      f->off += r;
    80004714:	509c                	lw	a5,32(s1)
    80004716:	9fa9                	addw	a5,a5,a0
    80004718:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000471a:	6c88                	ld	a0,24(s1)
    8000471c:	fffff097          	auipc	ra,0xfffff
    80004720:	09e080e7          	jalr	158(ra) # 800037ba <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004724:	854a                	mv	a0,s2
    80004726:	70a2                	ld	ra,40(sp)
    80004728:	7402                	ld	s0,32(sp)
    8000472a:	64e2                	ld	s1,24(sp)
    8000472c:	6942                	ld	s2,16(sp)
    8000472e:	69a2                	ld	s3,8(sp)
    80004730:	6145                	addi	sp,sp,48
    80004732:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004734:	6908                	ld	a0,16(a0)
    80004736:	00000097          	auipc	ra,0x0
    8000473a:	3f4080e7          	jalr	1012(ra) # 80004b2a <piperead>
    8000473e:	892a                	mv	s2,a0
    80004740:	b7d5                	j	80004724 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004742:	02451783          	lh	a5,36(a0)
    80004746:	03079693          	slli	a3,a5,0x30
    8000474a:	92c1                	srli	a3,a3,0x30
    8000474c:	4725                	li	a4,9
    8000474e:	02d76863          	bltu	a4,a3,8000477e <fileread+0xba>
    80004752:	0792                	slli	a5,a5,0x4
    80004754:	0001d717          	auipc	a4,0x1d
    80004758:	25c70713          	addi	a4,a4,604 # 800219b0 <devsw>
    8000475c:	97ba                	add	a5,a5,a4
    8000475e:	639c                	ld	a5,0(a5)
    80004760:	c38d                	beqz	a5,80004782 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004762:	4505                	li	a0,1
    80004764:	9782                	jalr	a5
    80004766:	892a                	mv	s2,a0
    80004768:	bf75                	j	80004724 <fileread+0x60>
    panic("fileread");
    8000476a:	00004517          	auipc	a0,0x4
    8000476e:	eae50513          	addi	a0,a0,-338 # 80008618 <syscalls+0x258>
    80004772:	ffffc097          	auipc	ra,0xffffc
    80004776:	dd0080e7          	jalr	-560(ra) # 80000542 <panic>
    return -1;
    8000477a:	597d                	li	s2,-1
    8000477c:	b765                	j	80004724 <fileread+0x60>
      return -1;
    8000477e:	597d                	li	s2,-1
    80004780:	b755                	j	80004724 <fileread+0x60>
    80004782:	597d                	li	s2,-1
    80004784:	b745                	j	80004724 <fileread+0x60>

0000000080004786 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004786:	00954783          	lbu	a5,9(a0)
    8000478a:	14078563          	beqz	a5,800048d4 <filewrite+0x14e>
{
    8000478e:	715d                	addi	sp,sp,-80
    80004790:	e486                	sd	ra,72(sp)
    80004792:	e0a2                	sd	s0,64(sp)
    80004794:	fc26                	sd	s1,56(sp)
    80004796:	f84a                	sd	s2,48(sp)
    80004798:	f44e                	sd	s3,40(sp)
    8000479a:	f052                	sd	s4,32(sp)
    8000479c:	ec56                	sd	s5,24(sp)
    8000479e:	e85a                	sd	s6,16(sp)
    800047a0:	e45e                	sd	s7,8(sp)
    800047a2:	e062                	sd	s8,0(sp)
    800047a4:	0880                	addi	s0,sp,80
    800047a6:	892a                	mv	s2,a0
    800047a8:	8aae                	mv	s5,a1
    800047aa:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047ac:	411c                	lw	a5,0(a0)
    800047ae:	4705                	li	a4,1
    800047b0:	02e78263          	beq	a5,a4,800047d4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047b4:	470d                	li	a4,3
    800047b6:	02e78563          	beq	a5,a4,800047e0 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047ba:	4709                	li	a4,2
    800047bc:	10e79463          	bne	a5,a4,800048c4 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047c0:	0ec05e63          	blez	a2,800048bc <filewrite+0x136>
    int i = 0;
    800047c4:	4981                	li	s3,0
    800047c6:	6b05                	lui	s6,0x1
    800047c8:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800047cc:	6b85                	lui	s7,0x1
    800047ce:	c00b8b9b          	addiw	s7,s7,-1024
    800047d2:	a851                	j	80004866 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800047d4:	6908                	ld	a0,16(a0)
    800047d6:	00000097          	auipc	ra,0x0
    800047da:	254080e7          	jalr	596(ra) # 80004a2a <pipewrite>
    800047de:	a85d                	j	80004894 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047e0:	02451783          	lh	a5,36(a0)
    800047e4:	03079693          	slli	a3,a5,0x30
    800047e8:	92c1                	srli	a3,a3,0x30
    800047ea:	4725                	li	a4,9
    800047ec:	0ed76663          	bltu	a4,a3,800048d8 <filewrite+0x152>
    800047f0:	0792                	slli	a5,a5,0x4
    800047f2:	0001d717          	auipc	a4,0x1d
    800047f6:	1be70713          	addi	a4,a4,446 # 800219b0 <devsw>
    800047fa:	97ba                	add	a5,a5,a4
    800047fc:	679c                	ld	a5,8(a5)
    800047fe:	cff9                	beqz	a5,800048dc <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004800:	4505                	li	a0,1
    80004802:	9782                	jalr	a5
    80004804:	a841                	j	80004894 <filewrite+0x10e>
    80004806:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000480a:	00000097          	auipc	ra,0x0
    8000480e:	8ae080e7          	jalr	-1874(ra) # 800040b8 <begin_op>
      ilock(f->ip);
    80004812:	01893503          	ld	a0,24(s2)
    80004816:	fffff097          	auipc	ra,0xfffff
    8000481a:	ee2080e7          	jalr	-286(ra) # 800036f8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000481e:	8762                	mv	a4,s8
    80004820:	02092683          	lw	a3,32(s2)
    80004824:	01598633          	add	a2,s3,s5
    80004828:	4585                	li	a1,1
    8000482a:	01893503          	ld	a0,24(s2)
    8000482e:	fffff097          	auipc	ra,0xfffff
    80004832:	276080e7          	jalr	630(ra) # 80003aa4 <writei>
    80004836:	84aa                	mv	s1,a0
    80004838:	02a05f63          	blez	a0,80004876 <filewrite+0xf0>
        f->off += r;
    8000483c:	02092783          	lw	a5,32(s2)
    80004840:	9fa9                	addw	a5,a5,a0
    80004842:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004846:	01893503          	ld	a0,24(s2)
    8000484a:	fffff097          	auipc	ra,0xfffff
    8000484e:	f70080e7          	jalr	-144(ra) # 800037ba <iunlock>
      end_op();
    80004852:	00000097          	auipc	ra,0x0
    80004856:	8e6080e7          	jalr	-1818(ra) # 80004138 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    8000485a:	049c1963          	bne	s8,s1,800048ac <filewrite+0x126>
        panic("short filewrite");
      i += r;
    8000485e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004862:	0349d663          	bge	s3,s4,8000488e <filewrite+0x108>
      int n1 = n - i;
    80004866:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000486a:	84be                	mv	s1,a5
    8000486c:	2781                	sext.w	a5,a5
    8000486e:	f8fb5ce3          	bge	s6,a5,80004806 <filewrite+0x80>
    80004872:	84de                	mv	s1,s7
    80004874:	bf49                	j	80004806 <filewrite+0x80>
      iunlock(f->ip);
    80004876:	01893503          	ld	a0,24(s2)
    8000487a:	fffff097          	auipc	ra,0xfffff
    8000487e:	f40080e7          	jalr	-192(ra) # 800037ba <iunlock>
      end_op();
    80004882:	00000097          	auipc	ra,0x0
    80004886:	8b6080e7          	jalr	-1866(ra) # 80004138 <end_op>
      if(r < 0)
    8000488a:	fc04d8e3          	bgez	s1,8000485a <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    8000488e:	8552                	mv	a0,s4
    80004890:	033a1863          	bne	s4,s3,800048c0 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004894:	60a6                	ld	ra,72(sp)
    80004896:	6406                	ld	s0,64(sp)
    80004898:	74e2                	ld	s1,56(sp)
    8000489a:	7942                	ld	s2,48(sp)
    8000489c:	79a2                	ld	s3,40(sp)
    8000489e:	7a02                	ld	s4,32(sp)
    800048a0:	6ae2                	ld	s5,24(sp)
    800048a2:	6b42                	ld	s6,16(sp)
    800048a4:	6ba2                	ld	s7,8(sp)
    800048a6:	6c02                	ld	s8,0(sp)
    800048a8:	6161                	addi	sp,sp,80
    800048aa:	8082                	ret
        panic("short filewrite");
    800048ac:	00004517          	auipc	a0,0x4
    800048b0:	d7c50513          	addi	a0,a0,-644 # 80008628 <syscalls+0x268>
    800048b4:	ffffc097          	auipc	ra,0xffffc
    800048b8:	c8e080e7          	jalr	-882(ra) # 80000542 <panic>
    int i = 0;
    800048bc:	4981                	li	s3,0
    800048be:	bfc1                	j	8000488e <filewrite+0x108>
    ret = (i == n ? n : -1);
    800048c0:	557d                	li	a0,-1
    800048c2:	bfc9                	j	80004894 <filewrite+0x10e>
    panic("filewrite");
    800048c4:	00004517          	auipc	a0,0x4
    800048c8:	d7450513          	addi	a0,a0,-652 # 80008638 <syscalls+0x278>
    800048cc:	ffffc097          	auipc	ra,0xffffc
    800048d0:	c76080e7          	jalr	-906(ra) # 80000542 <panic>
    return -1;
    800048d4:	557d                	li	a0,-1
}
    800048d6:	8082                	ret
      return -1;
    800048d8:	557d                	li	a0,-1
    800048da:	bf6d                	j	80004894 <filewrite+0x10e>
    800048dc:	557d                	li	a0,-1
    800048de:	bf5d                	j	80004894 <filewrite+0x10e>

00000000800048e0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048e0:	7179                	addi	sp,sp,-48
    800048e2:	f406                	sd	ra,40(sp)
    800048e4:	f022                	sd	s0,32(sp)
    800048e6:	ec26                	sd	s1,24(sp)
    800048e8:	e84a                	sd	s2,16(sp)
    800048ea:	e44e                	sd	s3,8(sp)
    800048ec:	e052                	sd	s4,0(sp)
    800048ee:	1800                	addi	s0,sp,48
    800048f0:	84aa                	mv	s1,a0
    800048f2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048f4:	0005b023          	sd	zero,0(a1)
    800048f8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048fc:	00000097          	auipc	ra,0x0
    80004900:	bd2080e7          	jalr	-1070(ra) # 800044ce <filealloc>
    80004904:	e088                	sd	a0,0(s1)
    80004906:	c551                	beqz	a0,80004992 <pipealloc+0xb2>
    80004908:	00000097          	auipc	ra,0x0
    8000490c:	bc6080e7          	jalr	-1082(ra) # 800044ce <filealloc>
    80004910:	00aa3023          	sd	a0,0(s4)
    80004914:	c92d                	beqz	a0,80004986 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004916:	ffffc097          	auipc	ra,0xffffc
    8000491a:	1f8080e7          	jalr	504(ra) # 80000b0e <kalloc>
    8000491e:	892a                	mv	s2,a0
    80004920:	c125                	beqz	a0,80004980 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004922:	4985                	li	s3,1
    80004924:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004928:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000492c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004930:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004934:	00004597          	auipc	a1,0x4
    80004938:	d1458593          	addi	a1,a1,-748 # 80008648 <syscalls+0x288>
    8000493c:	ffffc097          	auipc	ra,0xffffc
    80004940:	232080e7          	jalr	562(ra) # 80000b6e <initlock>
  (*f0)->type = FD_PIPE;
    80004944:	609c                	ld	a5,0(s1)
    80004946:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000494a:	609c                	ld	a5,0(s1)
    8000494c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004950:	609c                	ld	a5,0(s1)
    80004952:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004956:	609c                	ld	a5,0(s1)
    80004958:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000495c:	000a3783          	ld	a5,0(s4)
    80004960:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004964:	000a3783          	ld	a5,0(s4)
    80004968:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000496c:	000a3783          	ld	a5,0(s4)
    80004970:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004974:	000a3783          	ld	a5,0(s4)
    80004978:	0127b823          	sd	s2,16(a5)
  return 0;
    8000497c:	4501                	li	a0,0
    8000497e:	a025                	j	800049a6 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004980:	6088                	ld	a0,0(s1)
    80004982:	e501                	bnez	a0,8000498a <pipealloc+0xaa>
    80004984:	a039                	j	80004992 <pipealloc+0xb2>
    80004986:	6088                	ld	a0,0(s1)
    80004988:	c51d                	beqz	a0,800049b6 <pipealloc+0xd6>
    fileclose(*f0);
    8000498a:	00000097          	auipc	ra,0x0
    8000498e:	c00080e7          	jalr	-1024(ra) # 8000458a <fileclose>
  if(*f1)
    80004992:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004996:	557d                	li	a0,-1
  if(*f1)
    80004998:	c799                	beqz	a5,800049a6 <pipealloc+0xc6>
    fileclose(*f1);
    8000499a:	853e                	mv	a0,a5
    8000499c:	00000097          	auipc	ra,0x0
    800049a0:	bee080e7          	jalr	-1042(ra) # 8000458a <fileclose>
  return -1;
    800049a4:	557d                	li	a0,-1
}
    800049a6:	70a2                	ld	ra,40(sp)
    800049a8:	7402                	ld	s0,32(sp)
    800049aa:	64e2                	ld	s1,24(sp)
    800049ac:	6942                	ld	s2,16(sp)
    800049ae:	69a2                	ld	s3,8(sp)
    800049b0:	6a02                	ld	s4,0(sp)
    800049b2:	6145                	addi	sp,sp,48
    800049b4:	8082                	ret
  return -1;
    800049b6:	557d                	li	a0,-1
    800049b8:	b7fd                	j	800049a6 <pipealloc+0xc6>

00000000800049ba <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049ba:	1101                	addi	sp,sp,-32
    800049bc:	ec06                	sd	ra,24(sp)
    800049be:	e822                	sd	s0,16(sp)
    800049c0:	e426                	sd	s1,8(sp)
    800049c2:	e04a                	sd	s2,0(sp)
    800049c4:	1000                	addi	s0,sp,32
    800049c6:	84aa                	mv	s1,a0
    800049c8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049ca:	ffffc097          	auipc	ra,0xffffc
    800049ce:	234080e7          	jalr	564(ra) # 80000bfe <acquire>
  if(writable){
    800049d2:	02090d63          	beqz	s2,80004a0c <pipeclose+0x52>
    pi->writeopen = 0;
    800049d6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049da:	21848513          	addi	a0,s1,536
    800049de:	ffffe097          	auipc	ra,0xffffe
    800049e2:	a4a080e7          	jalr	-1462(ra) # 80002428 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049e6:	2204b783          	ld	a5,544(s1)
    800049ea:	eb95                	bnez	a5,80004a1e <pipeclose+0x64>
    release(&pi->lock);
    800049ec:	8526                	mv	a0,s1
    800049ee:	ffffc097          	auipc	ra,0xffffc
    800049f2:	2c4080e7          	jalr	708(ra) # 80000cb2 <release>
    kfree((char*)pi);
    800049f6:	8526                	mv	a0,s1
    800049f8:	ffffc097          	auipc	ra,0xffffc
    800049fc:	01a080e7          	jalr	26(ra) # 80000a12 <kfree>
  } else
    release(&pi->lock);
}
    80004a00:	60e2                	ld	ra,24(sp)
    80004a02:	6442                	ld	s0,16(sp)
    80004a04:	64a2                	ld	s1,8(sp)
    80004a06:	6902                	ld	s2,0(sp)
    80004a08:	6105                	addi	sp,sp,32
    80004a0a:	8082                	ret
    pi->readopen = 0;
    80004a0c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a10:	21c48513          	addi	a0,s1,540
    80004a14:	ffffe097          	auipc	ra,0xffffe
    80004a18:	a14080e7          	jalr	-1516(ra) # 80002428 <wakeup>
    80004a1c:	b7e9                	j	800049e6 <pipeclose+0x2c>
    release(&pi->lock);
    80004a1e:	8526                	mv	a0,s1
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	292080e7          	jalr	658(ra) # 80000cb2 <release>
}
    80004a28:	bfe1                	j	80004a00 <pipeclose+0x46>

0000000080004a2a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a2a:	711d                	addi	sp,sp,-96
    80004a2c:	ec86                	sd	ra,88(sp)
    80004a2e:	e8a2                	sd	s0,80(sp)
    80004a30:	e4a6                	sd	s1,72(sp)
    80004a32:	e0ca                	sd	s2,64(sp)
    80004a34:	fc4e                	sd	s3,56(sp)
    80004a36:	f852                	sd	s4,48(sp)
    80004a38:	f456                	sd	s5,40(sp)
    80004a3a:	f05a                	sd	s6,32(sp)
    80004a3c:	ec5e                	sd	s7,24(sp)
    80004a3e:	e862                	sd	s8,16(sp)
    80004a40:	1080                	addi	s0,sp,96
    80004a42:	84aa                	mv	s1,a0
    80004a44:	8b2e                	mv	s6,a1
    80004a46:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004a48:	ffffd097          	auipc	ra,0xffffd
    80004a4c:	04c080e7          	jalr	76(ra) # 80001a94 <myproc>
    80004a50:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004a52:	8526                	mv	a0,s1
    80004a54:	ffffc097          	auipc	ra,0xffffc
    80004a58:	1aa080e7          	jalr	426(ra) # 80000bfe <acquire>
  for(i = 0; i < n; i++){
    80004a5c:	09505763          	blez	s5,80004aea <pipewrite+0xc0>
    80004a60:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004a62:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a66:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a6a:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004a6c:	2184a783          	lw	a5,536(s1)
    80004a70:	21c4a703          	lw	a4,540(s1)
    80004a74:	2007879b          	addiw	a5,a5,512
    80004a78:	02f71b63          	bne	a4,a5,80004aae <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    80004a7c:	2204a783          	lw	a5,544(s1)
    80004a80:	c3d1                	beqz	a5,80004b04 <pipewrite+0xda>
    80004a82:	03092783          	lw	a5,48(s2)
    80004a86:	efbd                	bnez	a5,80004b04 <pipewrite+0xda>
      wakeup(&pi->nread);
    80004a88:	8552                	mv	a0,s4
    80004a8a:	ffffe097          	auipc	ra,0xffffe
    80004a8e:	99e080e7          	jalr	-1634(ra) # 80002428 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a92:	85a6                	mv	a1,s1
    80004a94:	854e                	mv	a0,s3
    80004a96:	ffffe097          	auipc	ra,0xffffe
    80004a9a:	812080e7          	jalr	-2030(ra) # 800022a8 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004a9e:	2184a783          	lw	a5,536(s1)
    80004aa2:	21c4a703          	lw	a4,540(s1)
    80004aa6:	2007879b          	addiw	a5,a5,512
    80004aaa:	fcf709e3          	beq	a4,a5,80004a7c <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004aae:	4685                	li	a3,1
    80004ab0:	865a                	mv	a2,s6
    80004ab2:	faf40593          	addi	a1,s0,-81
    80004ab6:	05093503          	ld	a0,80(s2)
    80004aba:	ffffd097          	auipc	ra,0xffffd
    80004abe:	c54080e7          	jalr	-940(ra) # 8000170e <copyin>
    80004ac2:	03850563          	beq	a0,s8,80004aec <pipewrite+0xc2>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ac6:	21c4a783          	lw	a5,540(s1)
    80004aca:	0017871b          	addiw	a4,a5,1
    80004ace:	20e4ae23          	sw	a4,540(s1)
    80004ad2:	1ff7f793          	andi	a5,a5,511
    80004ad6:	97a6                	add	a5,a5,s1
    80004ad8:	faf44703          	lbu	a4,-81(s0)
    80004adc:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004ae0:	2b85                	addiw	s7,s7,1
    80004ae2:	0b05                	addi	s6,s6,1
    80004ae4:	f97a94e3          	bne	s5,s7,80004a6c <pipewrite+0x42>
    80004ae8:	a011                	j	80004aec <pipewrite+0xc2>
    80004aea:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    80004aec:	21848513          	addi	a0,s1,536
    80004af0:	ffffe097          	auipc	ra,0xffffe
    80004af4:	938080e7          	jalr	-1736(ra) # 80002428 <wakeup>
  release(&pi->lock);
    80004af8:	8526                	mv	a0,s1
    80004afa:	ffffc097          	auipc	ra,0xffffc
    80004afe:	1b8080e7          	jalr	440(ra) # 80000cb2 <release>
  return i;
    80004b02:	a039                	j	80004b10 <pipewrite+0xe6>
        release(&pi->lock);
    80004b04:	8526                	mv	a0,s1
    80004b06:	ffffc097          	auipc	ra,0xffffc
    80004b0a:	1ac080e7          	jalr	428(ra) # 80000cb2 <release>
        return -1;
    80004b0e:	5bfd                	li	s7,-1
}
    80004b10:	855e                	mv	a0,s7
    80004b12:	60e6                	ld	ra,88(sp)
    80004b14:	6446                	ld	s0,80(sp)
    80004b16:	64a6                	ld	s1,72(sp)
    80004b18:	6906                	ld	s2,64(sp)
    80004b1a:	79e2                	ld	s3,56(sp)
    80004b1c:	7a42                	ld	s4,48(sp)
    80004b1e:	7aa2                	ld	s5,40(sp)
    80004b20:	7b02                	ld	s6,32(sp)
    80004b22:	6be2                	ld	s7,24(sp)
    80004b24:	6c42                	ld	s8,16(sp)
    80004b26:	6125                	addi	sp,sp,96
    80004b28:	8082                	ret

0000000080004b2a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b2a:	715d                	addi	sp,sp,-80
    80004b2c:	e486                	sd	ra,72(sp)
    80004b2e:	e0a2                	sd	s0,64(sp)
    80004b30:	fc26                	sd	s1,56(sp)
    80004b32:	f84a                	sd	s2,48(sp)
    80004b34:	f44e                	sd	s3,40(sp)
    80004b36:	f052                	sd	s4,32(sp)
    80004b38:	ec56                	sd	s5,24(sp)
    80004b3a:	e85a                	sd	s6,16(sp)
    80004b3c:	0880                	addi	s0,sp,80
    80004b3e:	84aa                	mv	s1,a0
    80004b40:	892e                	mv	s2,a1
    80004b42:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b44:	ffffd097          	auipc	ra,0xffffd
    80004b48:	f50080e7          	jalr	-176(ra) # 80001a94 <myproc>
    80004b4c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b4e:	8526                	mv	a0,s1
    80004b50:	ffffc097          	auipc	ra,0xffffc
    80004b54:	0ae080e7          	jalr	174(ra) # 80000bfe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b58:	2184a703          	lw	a4,536(s1)
    80004b5c:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b60:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b64:	02f71463          	bne	a4,a5,80004b8c <piperead+0x62>
    80004b68:	2244a783          	lw	a5,548(s1)
    80004b6c:	c385                	beqz	a5,80004b8c <piperead+0x62>
    if(pr->killed){
    80004b6e:	030a2783          	lw	a5,48(s4)
    80004b72:	ebc1                	bnez	a5,80004c02 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b74:	85a6                	mv	a1,s1
    80004b76:	854e                	mv	a0,s3
    80004b78:	ffffd097          	auipc	ra,0xffffd
    80004b7c:	730080e7          	jalr	1840(ra) # 800022a8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b80:	2184a703          	lw	a4,536(s1)
    80004b84:	21c4a783          	lw	a5,540(s1)
    80004b88:	fef700e3          	beq	a4,a5,80004b68 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b8c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b8e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b90:	05505363          	blez	s5,80004bd6 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004b94:	2184a783          	lw	a5,536(s1)
    80004b98:	21c4a703          	lw	a4,540(s1)
    80004b9c:	02f70d63          	beq	a4,a5,80004bd6 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ba0:	0017871b          	addiw	a4,a5,1
    80004ba4:	20e4ac23          	sw	a4,536(s1)
    80004ba8:	1ff7f793          	andi	a5,a5,511
    80004bac:	97a6                	add	a5,a5,s1
    80004bae:	0187c783          	lbu	a5,24(a5)
    80004bb2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bb6:	4685                	li	a3,1
    80004bb8:	fbf40613          	addi	a2,s0,-65
    80004bbc:	85ca                	mv	a1,s2
    80004bbe:	050a3503          	ld	a0,80(s4)
    80004bc2:	ffffd097          	auipc	ra,0xffffd
    80004bc6:	ac0080e7          	jalr	-1344(ra) # 80001682 <copyout>
    80004bca:	01650663          	beq	a0,s6,80004bd6 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bce:	2985                	addiw	s3,s3,1
    80004bd0:	0905                	addi	s2,s2,1
    80004bd2:	fd3a91e3          	bne	s5,s3,80004b94 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004bd6:	21c48513          	addi	a0,s1,540
    80004bda:	ffffe097          	auipc	ra,0xffffe
    80004bde:	84e080e7          	jalr	-1970(ra) # 80002428 <wakeup>
  release(&pi->lock);
    80004be2:	8526                	mv	a0,s1
    80004be4:	ffffc097          	auipc	ra,0xffffc
    80004be8:	0ce080e7          	jalr	206(ra) # 80000cb2 <release>
  return i;
}
    80004bec:	854e                	mv	a0,s3
    80004bee:	60a6                	ld	ra,72(sp)
    80004bf0:	6406                	ld	s0,64(sp)
    80004bf2:	74e2                	ld	s1,56(sp)
    80004bf4:	7942                	ld	s2,48(sp)
    80004bf6:	79a2                	ld	s3,40(sp)
    80004bf8:	7a02                	ld	s4,32(sp)
    80004bfa:	6ae2                	ld	s5,24(sp)
    80004bfc:	6b42                	ld	s6,16(sp)
    80004bfe:	6161                	addi	sp,sp,80
    80004c00:	8082                	ret
      release(&pi->lock);
    80004c02:	8526                	mv	a0,s1
    80004c04:	ffffc097          	auipc	ra,0xffffc
    80004c08:	0ae080e7          	jalr	174(ra) # 80000cb2 <release>
      return -1;
    80004c0c:	59fd                	li	s3,-1
    80004c0e:	bff9                	j	80004bec <piperead+0xc2>

0000000080004c10 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004c10:	de010113          	addi	sp,sp,-544
    80004c14:	20113c23          	sd	ra,536(sp)
    80004c18:	20813823          	sd	s0,528(sp)
    80004c1c:	20913423          	sd	s1,520(sp)
    80004c20:	21213023          	sd	s2,512(sp)
    80004c24:	ffce                	sd	s3,504(sp)
    80004c26:	fbd2                	sd	s4,496(sp)
    80004c28:	f7d6                	sd	s5,488(sp)
    80004c2a:	f3da                	sd	s6,480(sp)
    80004c2c:	efde                	sd	s7,472(sp)
    80004c2e:	ebe2                	sd	s8,464(sp)
    80004c30:	e7e6                	sd	s9,456(sp)
    80004c32:	e3ea                	sd	s10,448(sp)
    80004c34:	ff6e                	sd	s11,440(sp)
    80004c36:	1400                	addi	s0,sp,544
    80004c38:	892a                	mv	s2,a0
    80004c3a:	dea43423          	sd	a0,-536(s0)
    80004c3e:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c42:	ffffd097          	auipc	ra,0xffffd
    80004c46:	e52080e7          	jalr	-430(ra) # 80001a94 <myproc>
    80004c4a:	84aa                	mv	s1,a0

  begin_op();
    80004c4c:	fffff097          	auipc	ra,0xfffff
    80004c50:	46c080e7          	jalr	1132(ra) # 800040b8 <begin_op>

  if((ip = namei(path)) == 0){
    80004c54:	854a                	mv	a0,s2
    80004c56:	fffff097          	auipc	ra,0xfffff
    80004c5a:	256080e7          	jalr	598(ra) # 80003eac <namei>
    80004c5e:	c93d                	beqz	a0,80004cd4 <exec+0xc4>
    80004c60:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c62:	fffff097          	auipc	ra,0xfffff
    80004c66:	a96080e7          	jalr	-1386(ra) # 800036f8 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c6a:	04000713          	li	a4,64
    80004c6e:	4681                	li	a3,0
    80004c70:	e4840613          	addi	a2,s0,-440
    80004c74:	4581                	li	a1,0
    80004c76:	8556                	mv	a0,s5
    80004c78:	fffff097          	auipc	ra,0xfffff
    80004c7c:	d34080e7          	jalr	-716(ra) # 800039ac <readi>
    80004c80:	04000793          	li	a5,64
    80004c84:	00f51a63          	bne	a0,a5,80004c98 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004c88:	e4842703          	lw	a4,-440(s0)
    80004c8c:	464c47b7          	lui	a5,0x464c4
    80004c90:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c94:	04f70663          	beq	a4,a5,80004ce0 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c98:	8556                	mv	a0,s5
    80004c9a:	fffff097          	auipc	ra,0xfffff
    80004c9e:	cc0080e7          	jalr	-832(ra) # 8000395a <iunlockput>
    end_op();
    80004ca2:	fffff097          	auipc	ra,0xfffff
    80004ca6:	496080e7          	jalr	1174(ra) # 80004138 <end_op>
  }
  return -1;
    80004caa:	557d                	li	a0,-1
}
    80004cac:	21813083          	ld	ra,536(sp)
    80004cb0:	21013403          	ld	s0,528(sp)
    80004cb4:	20813483          	ld	s1,520(sp)
    80004cb8:	20013903          	ld	s2,512(sp)
    80004cbc:	79fe                	ld	s3,504(sp)
    80004cbe:	7a5e                	ld	s4,496(sp)
    80004cc0:	7abe                	ld	s5,488(sp)
    80004cc2:	7b1e                	ld	s6,480(sp)
    80004cc4:	6bfe                	ld	s7,472(sp)
    80004cc6:	6c5e                	ld	s8,464(sp)
    80004cc8:	6cbe                	ld	s9,456(sp)
    80004cca:	6d1e                	ld	s10,448(sp)
    80004ccc:	7dfa                	ld	s11,440(sp)
    80004cce:	22010113          	addi	sp,sp,544
    80004cd2:	8082                	ret
    end_op();
    80004cd4:	fffff097          	auipc	ra,0xfffff
    80004cd8:	464080e7          	jalr	1124(ra) # 80004138 <end_op>
    return -1;
    80004cdc:	557d                	li	a0,-1
    80004cde:	b7f9                	j	80004cac <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ce0:	8526                	mv	a0,s1
    80004ce2:	ffffd097          	auipc	ra,0xffffd
    80004ce6:	e76080e7          	jalr	-394(ra) # 80001b58 <proc_pagetable>
    80004cea:	8b2a                	mv	s6,a0
    80004cec:	d555                	beqz	a0,80004c98 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cee:	e6842783          	lw	a5,-408(s0)
    80004cf2:	e8045703          	lhu	a4,-384(s0)
    80004cf6:	c735                	beqz	a4,80004d62 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004cf8:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cfa:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004cfe:	6a05                	lui	s4,0x1
    80004d00:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004d04:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004d08:	6d85                	lui	s11,0x1
    80004d0a:	7d7d                	lui	s10,0xfffff
    80004d0c:	ac1d                	j	80004f42 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004d0e:	00004517          	auipc	a0,0x4
    80004d12:	94250513          	addi	a0,a0,-1726 # 80008650 <syscalls+0x290>
    80004d16:	ffffc097          	auipc	ra,0xffffc
    80004d1a:	82c080e7          	jalr	-2004(ra) # 80000542 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d1e:	874a                	mv	a4,s2
    80004d20:	009c86bb          	addw	a3,s9,s1
    80004d24:	4581                	li	a1,0
    80004d26:	8556                	mv	a0,s5
    80004d28:	fffff097          	auipc	ra,0xfffff
    80004d2c:	c84080e7          	jalr	-892(ra) # 800039ac <readi>
    80004d30:	2501                	sext.w	a0,a0
    80004d32:	1aa91863          	bne	s2,a0,80004ee2 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004d36:	009d84bb          	addw	s1,s11,s1
    80004d3a:	013d09bb          	addw	s3,s10,s3
    80004d3e:	1f74f263          	bgeu	s1,s7,80004f22 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004d42:	02049593          	slli	a1,s1,0x20
    80004d46:	9181                	srli	a1,a1,0x20
    80004d48:	95e2                	add	a1,a1,s8
    80004d4a:	855a                	mv	a0,s6
    80004d4c:	ffffc097          	auipc	ra,0xffffc
    80004d50:	33c080e7          	jalr	828(ra) # 80001088 <walkaddr>
    80004d54:	862a                	mv	a2,a0
    if(pa == 0)
    80004d56:	dd45                	beqz	a0,80004d0e <exec+0xfe>
      n = PGSIZE;
    80004d58:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004d5a:	fd49f2e3          	bgeu	s3,s4,80004d1e <exec+0x10e>
      n = sz - i;
    80004d5e:	894e                	mv	s2,s3
    80004d60:	bf7d                	j	80004d1e <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d62:	4481                	li	s1,0
  iunlockput(ip);
    80004d64:	8556                	mv	a0,s5
    80004d66:	fffff097          	auipc	ra,0xfffff
    80004d6a:	bf4080e7          	jalr	-1036(ra) # 8000395a <iunlockput>
  end_op();
    80004d6e:	fffff097          	auipc	ra,0xfffff
    80004d72:	3ca080e7          	jalr	970(ra) # 80004138 <end_op>
  p = myproc();
    80004d76:	ffffd097          	auipc	ra,0xffffd
    80004d7a:	d1e080e7          	jalr	-738(ra) # 80001a94 <myproc>
    80004d7e:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004d80:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004d84:	6785                	lui	a5,0x1
    80004d86:	17fd                	addi	a5,a5,-1
    80004d88:	94be                	add	s1,s1,a5
    80004d8a:	77fd                	lui	a5,0xfffff
    80004d8c:	8fe5                	and	a5,a5,s1
    80004d8e:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d92:	6609                	lui	a2,0x2
    80004d94:	963e                	add	a2,a2,a5
    80004d96:	85be                	mv	a1,a5
    80004d98:	855a                	mv	a0,s6
    80004d9a:	ffffc097          	auipc	ra,0xffffc
    80004d9e:	6b4080e7          	jalr	1716(ra) # 8000144e <uvmalloc>
    80004da2:	8c2a                	mv	s8,a0
  ip = 0;
    80004da4:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004da6:	12050e63          	beqz	a0,80004ee2 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004daa:	75f9                	lui	a1,0xffffe
    80004dac:	95aa                	add	a1,a1,a0
    80004dae:	855a                	mv	a0,s6
    80004db0:	ffffd097          	auipc	ra,0xffffd
    80004db4:	8a0080e7          	jalr	-1888(ra) # 80001650 <uvmclear>
  stackbase = sp - PGSIZE;
    80004db8:	7afd                	lui	s5,0xfffff
    80004dba:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004dbc:	df043783          	ld	a5,-528(s0)
    80004dc0:	6388                	ld	a0,0(a5)
    80004dc2:	c925                	beqz	a0,80004e32 <exec+0x222>
    80004dc4:	e8840993          	addi	s3,s0,-376
    80004dc8:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004dcc:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004dce:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004dd0:	ffffc097          	auipc	ra,0xffffc
    80004dd4:	0ae080e7          	jalr	174(ra) # 80000e7e <strlen>
    80004dd8:	0015079b          	addiw	a5,a0,1
    80004ddc:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004de0:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004de4:	13596363          	bltu	s2,s5,80004f0a <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004de8:	df043d83          	ld	s11,-528(s0)
    80004dec:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004df0:	8552                	mv	a0,s4
    80004df2:	ffffc097          	auipc	ra,0xffffc
    80004df6:	08c080e7          	jalr	140(ra) # 80000e7e <strlen>
    80004dfa:	0015069b          	addiw	a3,a0,1
    80004dfe:	8652                	mv	a2,s4
    80004e00:	85ca                	mv	a1,s2
    80004e02:	855a                	mv	a0,s6
    80004e04:	ffffd097          	auipc	ra,0xffffd
    80004e08:	87e080e7          	jalr	-1922(ra) # 80001682 <copyout>
    80004e0c:	10054363          	bltz	a0,80004f12 <exec+0x302>
    ustack[argc] = sp;
    80004e10:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e14:	0485                	addi	s1,s1,1
    80004e16:	008d8793          	addi	a5,s11,8
    80004e1a:	def43823          	sd	a5,-528(s0)
    80004e1e:	008db503          	ld	a0,8(s11)
    80004e22:	c911                	beqz	a0,80004e36 <exec+0x226>
    if(argc >= MAXARG)
    80004e24:	09a1                	addi	s3,s3,8
    80004e26:	fb3c95e3          	bne	s9,s3,80004dd0 <exec+0x1c0>
  sz = sz1;
    80004e2a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e2e:	4a81                	li	s5,0
    80004e30:	a84d                	j	80004ee2 <exec+0x2d2>
  sp = sz;
    80004e32:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e34:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e36:	00349793          	slli	a5,s1,0x3
    80004e3a:	f9040713          	addi	a4,s0,-112
    80004e3e:	97ba                	add	a5,a5,a4
    80004e40:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80004e44:	00148693          	addi	a3,s1,1
    80004e48:	068e                	slli	a3,a3,0x3
    80004e4a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e4e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e52:	01597663          	bgeu	s2,s5,80004e5e <exec+0x24e>
  sz = sz1;
    80004e56:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e5a:	4a81                	li	s5,0
    80004e5c:	a059                	j	80004ee2 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e5e:	e8840613          	addi	a2,s0,-376
    80004e62:	85ca                	mv	a1,s2
    80004e64:	855a                	mv	a0,s6
    80004e66:	ffffd097          	auipc	ra,0xffffd
    80004e6a:	81c080e7          	jalr	-2020(ra) # 80001682 <copyout>
    80004e6e:	0a054663          	bltz	a0,80004f1a <exec+0x30a>
  p->trapframe->a1 = sp;
    80004e72:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004e76:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e7a:	de843783          	ld	a5,-536(s0)
    80004e7e:	0007c703          	lbu	a4,0(a5)
    80004e82:	cf11                	beqz	a4,80004e9e <exec+0x28e>
    80004e84:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e86:	02f00693          	li	a3,47
    80004e8a:	a039                	j	80004e98 <exec+0x288>
      last = s+1;
    80004e8c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004e90:	0785                	addi	a5,a5,1
    80004e92:	fff7c703          	lbu	a4,-1(a5)
    80004e96:	c701                	beqz	a4,80004e9e <exec+0x28e>
    if(*s == '/')
    80004e98:	fed71ce3          	bne	a4,a3,80004e90 <exec+0x280>
    80004e9c:	bfc5                	j	80004e8c <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e9e:	4641                	li	a2,16
    80004ea0:	de843583          	ld	a1,-536(s0)
    80004ea4:	158b8513          	addi	a0,s7,344
    80004ea8:	ffffc097          	auipc	ra,0xffffc
    80004eac:	fa4080e7          	jalr	-92(ra) # 80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80004eb0:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004eb4:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004eb8:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004ebc:	058bb783          	ld	a5,88(s7)
    80004ec0:	e6043703          	ld	a4,-416(s0)
    80004ec4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004ec6:	058bb783          	ld	a5,88(s7)
    80004eca:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ece:	85ea                	mv	a1,s10
    80004ed0:	ffffd097          	auipc	ra,0xffffd
    80004ed4:	d24080e7          	jalr	-732(ra) # 80001bf4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ed8:	0004851b          	sext.w	a0,s1
    80004edc:	bbc1                	j	80004cac <exec+0x9c>
    80004ede:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004ee2:	df843583          	ld	a1,-520(s0)
    80004ee6:	855a                	mv	a0,s6
    80004ee8:	ffffd097          	auipc	ra,0xffffd
    80004eec:	d0c080e7          	jalr	-756(ra) # 80001bf4 <proc_freepagetable>
  if(ip){
    80004ef0:	da0a94e3          	bnez	s5,80004c98 <exec+0x88>
  return -1;
    80004ef4:	557d                	li	a0,-1
    80004ef6:	bb5d                	j	80004cac <exec+0x9c>
    80004ef8:	de943c23          	sd	s1,-520(s0)
    80004efc:	b7dd                	j	80004ee2 <exec+0x2d2>
    80004efe:	de943c23          	sd	s1,-520(s0)
    80004f02:	b7c5                	j	80004ee2 <exec+0x2d2>
    80004f04:	de943c23          	sd	s1,-520(s0)
    80004f08:	bfe9                	j	80004ee2 <exec+0x2d2>
  sz = sz1;
    80004f0a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f0e:	4a81                	li	s5,0
    80004f10:	bfc9                	j	80004ee2 <exec+0x2d2>
  sz = sz1;
    80004f12:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f16:	4a81                	li	s5,0
    80004f18:	b7e9                	j	80004ee2 <exec+0x2d2>
  sz = sz1;
    80004f1a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f1e:	4a81                	li	s5,0
    80004f20:	b7c9                	j	80004ee2 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f22:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f26:	e0843783          	ld	a5,-504(s0)
    80004f2a:	0017869b          	addiw	a3,a5,1
    80004f2e:	e0d43423          	sd	a3,-504(s0)
    80004f32:	e0043783          	ld	a5,-512(s0)
    80004f36:	0387879b          	addiw	a5,a5,56
    80004f3a:	e8045703          	lhu	a4,-384(s0)
    80004f3e:	e2e6d3e3          	bge	a3,a4,80004d64 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f42:	2781                	sext.w	a5,a5
    80004f44:	e0f43023          	sd	a5,-512(s0)
    80004f48:	03800713          	li	a4,56
    80004f4c:	86be                	mv	a3,a5
    80004f4e:	e1040613          	addi	a2,s0,-496
    80004f52:	4581                	li	a1,0
    80004f54:	8556                	mv	a0,s5
    80004f56:	fffff097          	auipc	ra,0xfffff
    80004f5a:	a56080e7          	jalr	-1450(ra) # 800039ac <readi>
    80004f5e:	03800793          	li	a5,56
    80004f62:	f6f51ee3          	bne	a0,a5,80004ede <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80004f66:	e1042783          	lw	a5,-496(s0)
    80004f6a:	4705                	li	a4,1
    80004f6c:	fae79de3          	bne	a5,a4,80004f26 <exec+0x316>
    if(ph.memsz < ph.filesz)
    80004f70:	e3843603          	ld	a2,-456(s0)
    80004f74:	e3043783          	ld	a5,-464(s0)
    80004f78:	f8f660e3          	bltu	a2,a5,80004ef8 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f7c:	e2043783          	ld	a5,-480(s0)
    80004f80:	963e                	add	a2,a2,a5
    80004f82:	f6f66ee3          	bltu	a2,a5,80004efe <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f86:	85a6                	mv	a1,s1
    80004f88:	855a                	mv	a0,s6
    80004f8a:	ffffc097          	auipc	ra,0xffffc
    80004f8e:	4c4080e7          	jalr	1220(ra) # 8000144e <uvmalloc>
    80004f92:	dea43c23          	sd	a0,-520(s0)
    80004f96:	d53d                	beqz	a0,80004f04 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80004f98:	e2043c03          	ld	s8,-480(s0)
    80004f9c:	de043783          	ld	a5,-544(s0)
    80004fa0:	00fc77b3          	and	a5,s8,a5
    80004fa4:	ff9d                	bnez	a5,80004ee2 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fa6:	e1842c83          	lw	s9,-488(s0)
    80004faa:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004fae:	f60b8ae3          	beqz	s7,80004f22 <exec+0x312>
    80004fb2:	89de                	mv	s3,s7
    80004fb4:	4481                	li	s1,0
    80004fb6:	b371                	j	80004d42 <exec+0x132>

0000000080004fb8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004fb8:	7179                	addi	sp,sp,-48
    80004fba:	f406                	sd	ra,40(sp)
    80004fbc:	f022                	sd	s0,32(sp)
    80004fbe:	ec26                	sd	s1,24(sp)
    80004fc0:	e84a                	sd	s2,16(sp)
    80004fc2:	1800                	addi	s0,sp,48
    80004fc4:	892e                	mv	s2,a1
    80004fc6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004fc8:	fdc40593          	addi	a1,s0,-36
    80004fcc:	ffffe097          	auipc	ra,0xffffe
    80004fd0:	ba6080e7          	jalr	-1114(ra) # 80002b72 <argint>
    80004fd4:	04054063          	bltz	a0,80005014 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004fd8:	fdc42703          	lw	a4,-36(s0)
    80004fdc:	47bd                	li	a5,15
    80004fde:	02e7ed63          	bltu	a5,a4,80005018 <argfd+0x60>
    80004fe2:	ffffd097          	auipc	ra,0xffffd
    80004fe6:	ab2080e7          	jalr	-1358(ra) # 80001a94 <myproc>
    80004fea:	fdc42703          	lw	a4,-36(s0)
    80004fee:	01a70793          	addi	a5,a4,26
    80004ff2:	078e                	slli	a5,a5,0x3
    80004ff4:	953e                	add	a0,a0,a5
    80004ff6:	611c                	ld	a5,0(a0)
    80004ff8:	c395                	beqz	a5,8000501c <argfd+0x64>
    return -1;
  if(pfd)
    80004ffa:	00090463          	beqz	s2,80005002 <argfd+0x4a>
    *pfd = fd;
    80004ffe:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005002:	4501                	li	a0,0
  if(pf)
    80005004:	c091                	beqz	s1,80005008 <argfd+0x50>
    *pf = f;
    80005006:	e09c                	sd	a5,0(s1)
}
    80005008:	70a2                	ld	ra,40(sp)
    8000500a:	7402                	ld	s0,32(sp)
    8000500c:	64e2                	ld	s1,24(sp)
    8000500e:	6942                	ld	s2,16(sp)
    80005010:	6145                	addi	sp,sp,48
    80005012:	8082                	ret
    return -1;
    80005014:	557d                	li	a0,-1
    80005016:	bfcd                	j	80005008 <argfd+0x50>
    return -1;
    80005018:	557d                	li	a0,-1
    8000501a:	b7fd                	j	80005008 <argfd+0x50>
    8000501c:	557d                	li	a0,-1
    8000501e:	b7ed                	j	80005008 <argfd+0x50>

0000000080005020 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005020:	1101                	addi	sp,sp,-32
    80005022:	ec06                	sd	ra,24(sp)
    80005024:	e822                	sd	s0,16(sp)
    80005026:	e426                	sd	s1,8(sp)
    80005028:	1000                	addi	s0,sp,32
    8000502a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000502c:	ffffd097          	auipc	ra,0xffffd
    80005030:	a68080e7          	jalr	-1432(ra) # 80001a94 <myproc>
    80005034:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005036:	0d050793          	addi	a5,a0,208
    8000503a:	4501                	li	a0,0
    8000503c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000503e:	6398                	ld	a4,0(a5)
    80005040:	cb19                	beqz	a4,80005056 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005042:	2505                	addiw	a0,a0,1
    80005044:	07a1                	addi	a5,a5,8
    80005046:	fed51ce3          	bne	a0,a3,8000503e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000504a:	557d                	li	a0,-1
}
    8000504c:	60e2                	ld	ra,24(sp)
    8000504e:	6442                	ld	s0,16(sp)
    80005050:	64a2                	ld	s1,8(sp)
    80005052:	6105                	addi	sp,sp,32
    80005054:	8082                	ret
      p->ofile[fd] = f;
    80005056:	01a50793          	addi	a5,a0,26
    8000505a:	078e                	slli	a5,a5,0x3
    8000505c:	963e                	add	a2,a2,a5
    8000505e:	e204                	sd	s1,0(a2)
      return fd;
    80005060:	b7f5                	j	8000504c <fdalloc+0x2c>

0000000080005062 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005062:	715d                	addi	sp,sp,-80
    80005064:	e486                	sd	ra,72(sp)
    80005066:	e0a2                	sd	s0,64(sp)
    80005068:	fc26                	sd	s1,56(sp)
    8000506a:	f84a                	sd	s2,48(sp)
    8000506c:	f44e                	sd	s3,40(sp)
    8000506e:	f052                	sd	s4,32(sp)
    80005070:	ec56                	sd	s5,24(sp)
    80005072:	0880                	addi	s0,sp,80
    80005074:	89ae                	mv	s3,a1
    80005076:	8ab2                	mv	s5,a2
    80005078:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000507a:	fb040593          	addi	a1,s0,-80
    8000507e:	fffff097          	auipc	ra,0xfffff
    80005082:	e4c080e7          	jalr	-436(ra) # 80003eca <nameiparent>
    80005086:	892a                	mv	s2,a0
    80005088:	12050e63          	beqz	a0,800051c4 <create+0x162>
    return 0;

  ilock(dp);
    8000508c:	ffffe097          	auipc	ra,0xffffe
    80005090:	66c080e7          	jalr	1644(ra) # 800036f8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005094:	4601                	li	a2,0
    80005096:	fb040593          	addi	a1,s0,-80
    8000509a:	854a                	mv	a0,s2
    8000509c:	fffff097          	auipc	ra,0xfffff
    800050a0:	b3e080e7          	jalr	-1218(ra) # 80003bda <dirlookup>
    800050a4:	84aa                	mv	s1,a0
    800050a6:	c921                	beqz	a0,800050f6 <create+0x94>
    iunlockput(dp);
    800050a8:	854a                	mv	a0,s2
    800050aa:	fffff097          	auipc	ra,0xfffff
    800050ae:	8b0080e7          	jalr	-1872(ra) # 8000395a <iunlockput>
    ilock(ip);
    800050b2:	8526                	mv	a0,s1
    800050b4:	ffffe097          	auipc	ra,0xffffe
    800050b8:	644080e7          	jalr	1604(ra) # 800036f8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050bc:	2981                	sext.w	s3,s3
    800050be:	4789                	li	a5,2
    800050c0:	02f99463          	bne	s3,a5,800050e8 <create+0x86>
    800050c4:	0444d783          	lhu	a5,68(s1)
    800050c8:	37f9                	addiw	a5,a5,-2
    800050ca:	17c2                	slli	a5,a5,0x30
    800050cc:	93c1                	srli	a5,a5,0x30
    800050ce:	4705                	li	a4,1
    800050d0:	00f76c63          	bltu	a4,a5,800050e8 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800050d4:	8526                	mv	a0,s1
    800050d6:	60a6                	ld	ra,72(sp)
    800050d8:	6406                	ld	s0,64(sp)
    800050da:	74e2                	ld	s1,56(sp)
    800050dc:	7942                	ld	s2,48(sp)
    800050de:	79a2                	ld	s3,40(sp)
    800050e0:	7a02                	ld	s4,32(sp)
    800050e2:	6ae2                	ld	s5,24(sp)
    800050e4:	6161                	addi	sp,sp,80
    800050e6:	8082                	ret
    iunlockput(ip);
    800050e8:	8526                	mv	a0,s1
    800050ea:	fffff097          	auipc	ra,0xfffff
    800050ee:	870080e7          	jalr	-1936(ra) # 8000395a <iunlockput>
    return 0;
    800050f2:	4481                	li	s1,0
    800050f4:	b7c5                	j	800050d4 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800050f6:	85ce                	mv	a1,s3
    800050f8:	00092503          	lw	a0,0(s2)
    800050fc:	ffffe097          	auipc	ra,0xffffe
    80005100:	464080e7          	jalr	1124(ra) # 80003560 <ialloc>
    80005104:	84aa                	mv	s1,a0
    80005106:	c521                	beqz	a0,8000514e <create+0xec>
  ilock(ip);
    80005108:	ffffe097          	auipc	ra,0xffffe
    8000510c:	5f0080e7          	jalr	1520(ra) # 800036f8 <ilock>
  ip->major = major;
    80005110:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005114:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005118:	4a05                	li	s4,1
    8000511a:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000511e:	8526                	mv	a0,s1
    80005120:	ffffe097          	auipc	ra,0xffffe
    80005124:	50e080e7          	jalr	1294(ra) # 8000362e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005128:	2981                	sext.w	s3,s3
    8000512a:	03498a63          	beq	s3,s4,8000515e <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000512e:	40d0                	lw	a2,4(s1)
    80005130:	fb040593          	addi	a1,s0,-80
    80005134:	854a                	mv	a0,s2
    80005136:	fffff097          	auipc	ra,0xfffff
    8000513a:	cb4080e7          	jalr	-844(ra) # 80003dea <dirlink>
    8000513e:	06054b63          	bltz	a0,800051b4 <create+0x152>
  iunlockput(dp);
    80005142:	854a                	mv	a0,s2
    80005144:	fffff097          	auipc	ra,0xfffff
    80005148:	816080e7          	jalr	-2026(ra) # 8000395a <iunlockput>
  return ip;
    8000514c:	b761                	j	800050d4 <create+0x72>
    panic("create: ialloc");
    8000514e:	00003517          	auipc	a0,0x3
    80005152:	52250513          	addi	a0,a0,1314 # 80008670 <syscalls+0x2b0>
    80005156:	ffffb097          	auipc	ra,0xffffb
    8000515a:	3ec080e7          	jalr	1004(ra) # 80000542 <panic>
    dp->nlink++;  // for ".."
    8000515e:	04a95783          	lhu	a5,74(s2)
    80005162:	2785                	addiw	a5,a5,1
    80005164:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005168:	854a                	mv	a0,s2
    8000516a:	ffffe097          	auipc	ra,0xffffe
    8000516e:	4c4080e7          	jalr	1220(ra) # 8000362e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005172:	40d0                	lw	a2,4(s1)
    80005174:	00003597          	auipc	a1,0x3
    80005178:	50c58593          	addi	a1,a1,1292 # 80008680 <syscalls+0x2c0>
    8000517c:	8526                	mv	a0,s1
    8000517e:	fffff097          	auipc	ra,0xfffff
    80005182:	c6c080e7          	jalr	-916(ra) # 80003dea <dirlink>
    80005186:	00054f63          	bltz	a0,800051a4 <create+0x142>
    8000518a:	00492603          	lw	a2,4(s2)
    8000518e:	00003597          	auipc	a1,0x3
    80005192:	4fa58593          	addi	a1,a1,1274 # 80008688 <syscalls+0x2c8>
    80005196:	8526                	mv	a0,s1
    80005198:	fffff097          	auipc	ra,0xfffff
    8000519c:	c52080e7          	jalr	-942(ra) # 80003dea <dirlink>
    800051a0:	f80557e3          	bgez	a0,8000512e <create+0xcc>
      panic("create dots");
    800051a4:	00003517          	auipc	a0,0x3
    800051a8:	4ec50513          	addi	a0,a0,1260 # 80008690 <syscalls+0x2d0>
    800051ac:	ffffb097          	auipc	ra,0xffffb
    800051b0:	396080e7          	jalr	918(ra) # 80000542 <panic>
    panic("create: dirlink");
    800051b4:	00003517          	auipc	a0,0x3
    800051b8:	4ec50513          	addi	a0,a0,1260 # 800086a0 <syscalls+0x2e0>
    800051bc:	ffffb097          	auipc	ra,0xffffb
    800051c0:	386080e7          	jalr	902(ra) # 80000542 <panic>
    return 0;
    800051c4:	84aa                	mv	s1,a0
    800051c6:	b739                	j	800050d4 <create+0x72>

00000000800051c8 <sys_dup>:
{
    800051c8:	7179                	addi	sp,sp,-48
    800051ca:	f406                	sd	ra,40(sp)
    800051cc:	f022                	sd	s0,32(sp)
    800051ce:	ec26                	sd	s1,24(sp)
    800051d0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051d2:	fd840613          	addi	a2,s0,-40
    800051d6:	4581                	li	a1,0
    800051d8:	4501                	li	a0,0
    800051da:	00000097          	auipc	ra,0x0
    800051de:	dde080e7          	jalr	-546(ra) # 80004fb8 <argfd>
    return -1;
    800051e2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051e4:	02054363          	bltz	a0,8000520a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800051e8:	fd843503          	ld	a0,-40(s0)
    800051ec:	00000097          	auipc	ra,0x0
    800051f0:	e34080e7          	jalr	-460(ra) # 80005020 <fdalloc>
    800051f4:	84aa                	mv	s1,a0
    return -1;
    800051f6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051f8:	00054963          	bltz	a0,8000520a <sys_dup+0x42>
  filedup(f);
    800051fc:	fd843503          	ld	a0,-40(s0)
    80005200:	fffff097          	auipc	ra,0xfffff
    80005204:	338080e7          	jalr	824(ra) # 80004538 <filedup>
  return fd;
    80005208:	87a6                	mv	a5,s1
}
    8000520a:	853e                	mv	a0,a5
    8000520c:	70a2                	ld	ra,40(sp)
    8000520e:	7402                	ld	s0,32(sp)
    80005210:	64e2                	ld	s1,24(sp)
    80005212:	6145                	addi	sp,sp,48
    80005214:	8082                	ret

0000000080005216 <sys_read>:
{
    80005216:	715d                	addi	sp,sp,-80
    80005218:	e486                	sd	ra,72(sp)
    8000521a:	e0a2                	sd	s0,64(sp)
    8000521c:	fc26                	sd	s1,56(sp)
    8000521e:	f84a                	sd	s2,48(sp)
    80005220:	f44e                	sd	s3,40(sp)
    80005222:	0880                	addi	s0,sp,80
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005224:	fc840613          	addi	a2,s0,-56
    80005228:	4581                	li	a1,0
    8000522a:	4501                	li	a0,0
    8000522c:	00000097          	auipc	ra,0x0
    80005230:	d8c080e7          	jalr	-628(ra) # 80004fb8 <argfd>
    return -1;
    80005234:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005236:	08054963          	bltz	a0,800052c8 <sys_read+0xb2>
    8000523a:	fc440593          	addi	a1,s0,-60
    8000523e:	4509                	li	a0,2
    80005240:	ffffe097          	auipc	ra,0xffffe
    80005244:	932080e7          	jalr	-1742(ra) # 80002b72 <argint>
    return -1;
    80005248:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000524a:	06054f63          	bltz	a0,800052c8 <sys_read+0xb2>
    8000524e:	fb840593          	addi	a1,s0,-72
    80005252:	4505                	li	a0,1
    80005254:	ffffe097          	auipc	ra,0xffffe
    80005258:	940080e7          	jalr	-1728(ra) # 80002b94 <argaddr>
    return -1;
    8000525c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000525e:	06054563          	bltz	a0,800052c8 <sys_read+0xb2>
  struct proc *pro = myproc();
    80005262:	ffffd097          	auipc	ra,0xffffd
    80005266:	832080e7          	jalr	-1998(ra) # 80001a94 <myproc>
    8000526a:	892a                	mv	s2,a0
  for(uint64 va = PGROUNDDOWN(p); va < p + n; va += PGSIZE) {
    8000526c:	fb843583          	ld	a1,-72(s0)
    80005270:	74fd                	lui	s1,0xfffff
    80005272:	8ced                	and	s1,s1,a1
    80005274:	fc442603          	lw	a2,-60(s0)
    80005278:	00b607b3          	add	a5,a2,a1
    8000527c:	02f4ff63          	bgeu	s1,a5,800052ba <sys_read+0xa4>
    80005280:	6985                	lui	s3,0x1
    80005282:	a811                	j	80005296 <sys_read+0x80>
    80005284:	94ce                	add	s1,s1,s3
    80005286:	fc442603          	lw	a2,-60(s0)
    8000528a:	fb843583          	ld	a1,-72(s0)
    8000528e:	00b607b3          	add	a5,a2,a1
    80005292:	02f4f463          	bgeu	s1,a5,800052ba <sys_read+0xa4>
    if(walkaddr(pro->pagetable, va) == 0) {
    80005296:	85a6                	mv	a1,s1
    80005298:	05093503          	ld	a0,80(s2)
    8000529c:	ffffc097          	auipc	ra,0xffffc
    800052a0:	dec080e7          	jalr	-532(ra) # 80001088 <walkaddr>
    800052a4:	f165                	bnez	a0,80005284 <sys_read+0x6e>
      if(lazy_wr_alloc(va, pro) < 0)
    800052a6:	85ca                	mv	a1,s2
    800052a8:	8526                	mv	a0,s1
    800052aa:	ffffc097          	auipc	ra,0xffffc
    800052ae:	5a6080e7          	jalr	1446(ra) # 80001850 <lazy_wr_alloc>
    800052b2:	fc0559e3          	bgez	a0,80005284 <sys_read+0x6e>
        return -1;
    800052b6:	57fd                	li	a5,-1
    800052b8:	a801                	j	800052c8 <sys_read+0xb2>
  return fileread(f, p, n);
    800052ba:	fc843503          	ld	a0,-56(s0)
    800052be:	fffff097          	auipc	ra,0xfffff
    800052c2:	406080e7          	jalr	1030(ra) # 800046c4 <fileread>
    800052c6:	87aa                	mv	a5,a0
}
    800052c8:	853e                	mv	a0,a5
    800052ca:	60a6                	ld	ra,72(sp)
    800052cc:	6406                	ld	s0,64(sp)
    800052ce:	74e2                	ld	s1,56(sp)
    800052d0:	7942                	ld	s2,48(sp)
    800052d2:	79a2                	ld	s3,40(sp)
    800052d4:	6161                	addi	sp,sp,80
    800052d6:	8082                	ret

00000000800052d8 <sys_write>:
{
    800052d8:	715d                	addi	sp,sp,-80
    800052da:	e486                	sd	ra,72(sp)
    800052dc:	e0a2                	sd	s0,64(sp)
    800052de:	fc26                	sd	s1,56(sp)
    800052e0:	f84a                	sd	s2,48(sp)
    800052e2:	f44e                	sd	s3,40(sp)
    800052e4:	0880                	addi	s0,sp,80
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052e6:	fc840613          	addi	a2,s0,-56
    800052ea:	4581                	li	a1,0
    800052ec:	4501                	li	a0,0
    800052ee:	00000097          	auipc	ra,0x0
    800052f2:	cca080e7          	jalr	-822(ra) # 80004fb8 <argfd>
    return -1;
    800052f6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052f8:	08054963          	bltz	a0,8000538a <sys_write+0xb2>
    800052fc:	fc440593          	addi	a1,s0,-60
    80005300:	4509                	li	a0,2
    80005302:	ffffe097          	auipc	ra,0xffffe
    80005306:	870080e7          	jalr	-1936(ra) # 80002b72 <argint>
    return -1;
    8000530a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000530c:	06054f63          	bltz	a0,8000538a <sys_write+0xb2>
    80005310:	fb840593          	addi	a1,s0,-72
    80005314:	4505                	li	a0,1
    80005316:	ffffe097          	auipc	ra,0xffffe
    8000531a:	87e080e7          	jalr	-1922(ra) # 80002b94 <argaddr>
    return -1;
    8000531e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005320:	06054563          	bltz	a0,8000538a <sys_write+0xb2>
  struct proc *pro = myproc();
    80005324:	ffffc097          	auipc	ra,0xffffc
    80005328:	770080e7          	jalr	1904(ra) # 80001a94 <myproc>
    8000532c:	892a                	mv	s2,a0
  for(uint64 va = PGROUNDDOWN(p); va < p + n; va += PGSIZE) {
    8000532e:	fb843583          	ld	a1,-72(s0)
    80005332:	74fd                	lui	s1,0xfffff
    80005334:	8ced                	and	s1,s1,a1
    80005336:	fc442603          	lw	a2,-60(s0)
    8000533a:	00b607b3          	add	a5,a2,a1
    8000533e:	02f4ff63          	bgeu	s1,a5,8000537c <sys_write+0xa4>
    80005342:	6985                	lui	s3,0x1
    80005344:	a811                	j	80005358 <sys_write+0x80>
    80005346:	94ce                	add	s1,s1,s3
    80005348:	fc442603          	lw	a2,-60(s0)
    8000534c:	fb843583          	ld	a1,-72(s0)
    80005350:	00b607b3          	add	a5,a2,a1
    80005354:	02f4f463          	bgeu	s1,a5,8000537c <sys_write+0xa4>
    if(walkaddr(pro->pagetable, va) == 0) {
    80005358:	85a6                	mv	a1,s1
    8000535a:	05093503          	ld	a0,80(s2)
    8000535e:	ffffc097          	auipc	ra,0xffffc
    80005362:	d2a080e7          	jalr	-726(ra) # 80001088 <walkaddr>
    80005366:	f165                	bnez	a0,80005346 <sys_write+0x6e>
      if(lazy_wr_alloc(va, pro) < 0)
    80005368:	85ca                	mv	a1,s2
    8000536a:	8526                	mv	a0,s1
    8000536c:	ffffc097          	auipc	ra,0xffffc
    80005370:	4e4080e7          	jalr	1252(ra) # 80001850 <lazy_wr_alloc>
    80005374:	fc0559e3          	bgez	a0,80005346 <sys_write+0x6e>
        return -1;
    80005378:	57fd                	li	a5,-1
    8000537a:	a801                	j	8000538a <sys_write+0xb2>
  return filewrite(f, p, n);
    8000537c:	fc843503          	ld	a0,-56(s0)
    80005380:	fffff097          	auipc	ra,0xfffff
    80005384:	406080e7          	jalr	1030(ra) # 80004786 <filewrite>
    80005388:	87aa                	mv	a5,a0
}
    8000538a:	853e                	mv	a0,a5
    8000538c:	60a6                	ld	ra,72(sp)
    8000538e:	6406                	ld	s0,64(sp)
    80005390:	74e2                	ld	s1,56(sp)
    80005392:	7942                	ld	s2,48(sp)
    80005394:	79a2                	ld	s3,40(sp)
    80005396:	6161                	addi	sp,sp,80
    80005398:	8082                	ret

000000008000539a <sys_close>:
{
    8000539a:	1101                	addi	sp,sp,-32
    8000539c:	ec06                	sd	ra,24(sp)
    8000539e:	e822                	sd	s0,16(sp)
    800053a0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800053a2:	fe040613          	addi	a2,s0,-32
    800053a6:	fec40593          	addi	a1,s0,-20
    800053aa:	4501                	li	a0,0
    800053ac:	00000097          	auipc	ra,0x0
    800053b0:	c0c080e7          	jalr	-1012(ra) # 80004fb8 <argfd>
    return -1;
    800053b4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800053b6:	02054463          	bltz	a0,800053de <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800053ba:	ffffc097          	auipc	ra,0xffffc
    800053be:	6da080e7          	jalr	1754(ra) # 80001a94 <myproc>
    800053c2:	fec42783          	lw	a5,-20(s0)
    800053c6:	07e9                	addi	a5,a5,26
    800053c8:	078e                	slli	a5,a5,0x3
    800053ca:	97aa                	add	a5,a5,a0
    800053cc:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800053d0:	fe043503          	ld	a0,-32(s0)
    800053d4:	fffff097          	auipc	ra,0xfffff
    800053d8:	1b6080e7          	jalr	438(ra) # 8000458a <fileclose>
  return 0;
    800053dc:	4781                	li	a5,0
}
    800053de:	853e                	mv	a0,a5
    800053e0:	60e2                	ld	ra,24(sp)
    800053e2:	6442                	ld	s0,16(sp)
    800053e4:	6105                	addi	sp,sp,32
    800053e6:	8082                	ret

00000000800053e8 <sys_fstat>:
{
    800053e8:	1101                	addi	sp,sp,-32
    800053ea:	ec06                	sd	ra,24(sp)
    800053ec:	e822                	sd	s0,16(sp)
    800053ee:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053f0:	fe840613          	addi	a2,s0,-24
    800053f4:	4581                	li	a1,0
    800053f6:	4501                	li	a0,0
    800053f8:	00000097          	auipc	ra,0x0
    800053fc:	bc0080e7          	jalr	-1088(ra) # 80004fb8 <argfd>
    return -1;
    80005400:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005402:	02054563          	bltz	a0,8000542c <sys_fstat+0x44>
    80005406:	fe040593          	addi	a1,s0,-32
    8000540a:	4505                	li	a0,1
    8000540c:	ffffd097          	auipc	ra,0xffffd
    80005410:	788080e7          	jalr	1928(ra) # 80002b94 <argaddr>
    return -1;
    80005414:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005416:	00054b63          	bltz	a0,8000542c <sys_fstat+0x44>
  return filestat(f, st);
    8000541a:	fe043583          	ld	a1,-32(s0)
    8000541e:	fe843503          	ld	a0,-24(s0)
    80005422:	fffff097          	auipc	ra,0xfffff
    80005426:	230080e7          	jalr	560(ra) # 80004652 <filestat>
    8000542a:	87aa                	mv	a5,a0
}
    8000542c:	853e                	mv	a0,a5
    8000542e:	60e2                	ld	ra,24(sp)
    80005430:	6442                	ld	s0,16(sp)
    80005432:	6105                	addi	sp,sp,32
    80005434:	8082                	ret

0000000080005436 <sys_link>:
{
    80005436:	7169                	addi	sp,sp,-304
    80005438:	f606                	sd	ra,296(sp)
    8000543a:	f222                	sd	s0,288(sp)
    8000543c:	ee26                	sd	s1,280(sp)
    8000543e:	ea4a                	sd	s2,272(sp)
    80005440:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005442:	08000613          	li	a2,128
    80005446:	ed040593          	addi	a1,s0,-304
    8000544a:	4501                	li	a0,0
    8000544c:	ffffd097          	auipc	ra,0xffffd
    80005450:	76a080e7          	jalr	1898(ra) # 80002bb6 <argstr>
    return -1;
    80005454:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005456:	10054e63          	bltz	a0,80005572 <sys_link+0x13c>
    8000545a:	08000613          	li	a2,128
    8000545e:	f5040593          	addi	a1,s0,-176
    80005462:	4505                	li	a0,1
    80005464:	ffffd097          	auipc	ra,0xffffd
    80005468:	752080e7          	jalr	1874(ra) # 80002bb6 <argstr>
    return -1;
    8000546c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000546e:	10054263          	bltz	a0,80005572 <sys_link+0x13c>
  begin_op();
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	c46080e7          	jalr	-954(ra) # 800040b8 <begin_op>
  if((ip = namei(old)) == 0){
    8000547a:	ed040513          	addi	a0,s0,-304
    8000547e:	fffff097          	auipc	ra,0xfffff
    80005482:	a2e080e7          	jalr	-1490(ra) # 80003eac <namei>
    80005486:	84aa                	mv	s1,a0
    80005488:	c551                	beqz	a0,80005514 <sys_link+0xde>
  ilock(ip);
    8000548a:	ffffe097          	auipc	ra,0xffffe
    8000548e:	26e080e7          	jalr	622(ra) # 800036f8 <ilock>
  if(ip->type == T_DIR){
    80005492:	04449703          	lh	a4,68(s1) # fffffffffffff044 <end+0xffffffff7ffd9044>
    80005496:	4785                	li	a5,1
    80005498:	08f70463          	beq	a4,a5,80005520 <sys_link+0xea>
  ip->nlink++;
    8000549c:	04a4d783          	lhu	a5,74(s1)
    800054a0:	2785                	addiw	a5,a5,1
    800054a2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054a6:	8526                	mv	a0,s1
    800054a8:	ffffe097          	auipc	ra,0xffffe
    800054ac:	186080e7          	jalr	390(ra) # 8000362e <iupdate>
  iunlock(ip);
    800054b0:	8526                	mv	a0,s1
    800054b2:	ffffe097          	auipc	ra,0xffffe
    800054b6:	308080e7          	jalr	776(ra) # 800037ba <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800054ba:	fd040593          	addi	a1,s0,-48
    800054be:	f5040513          	addi	a0,s0,-176
    800054c2:	fffff097          	auipc	ra,0xfffff
    800054c6:	a08080e7          	jalr	-1528(ra) # 80003eca <nameiparent>
    800054ca:	892a                	mv	s2,a0
    800054cc:	c935                	beqz	a0,80005540 <sys_link+0x10a>
  ilock(dp);
    800054ce:	ffffe097          	auipc	ra,0xffffe
    800054d2:	22a080e7          	jalr	554(ra) # 800036f8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800054d6:	00092703          	lw	a4,0(s2)
    800054da:	409c                	lw	a5,0(s1)
    800054dc:	04f71d63          	bne	a4,a5,80005536 <sys_link+0x100>
    800054e0:	40d0                	lw	a2,4(s1)
    800054e2:	fd040593          	addi	a1,s0,-48
    800054e6:	854a                	mv	a0,s2
    800054e8:	fffff097          	auipc	ra,0xfffff
    800054ec:	902080e7          	jalr	-1790(ra) # 80003dea <dirlink>
    800054f0:	04054363          	bltz	a0,80005536 <sys_link+0x100>
  iunlockput(dp);
    800054f4:	854a                	mv	a0,s2
    800054f6:	ffffe097          	auipc	ra,0xffffe
    800054fa:	464080e7          	jalr	1124(ra) # 8000395a <iunlockput>
  iput(ip);
    800054fe:	8526                	mv	a0,s1
    80005500:	ffffe097          	auipc	ra,0xffffe
    80005504:	3b2080e7          	jalr	946(ra) # 800038b2 <iput>
  end_op();
    80005508:	fffff097          	auipc	ra,0xfffff
    8000550c:	c30080e7          	jalr	-976(ra) # 80004138 <end_op>
  return 0;
    80005510:	4781                	li	a5,0
    80005512:	a085                	j	80005572 <sys_link+0x13c>
    end_op();
    80005514:	fffff097          	auipc	ra,0xfffff
    80005518:	c24080e7          	jalr	-988(ra) # 80004138 <end_op>
    return -1;
    8000551c:	57fd                	li	a5,-1
    8000551e:	a891                	j	80005572 <sys_link+0x13c>
    iunlockput(ip);
    80005520:	8526                	mv	a0,s1
    80005522:	ffffe097          	auipc	ra,0xffffe
    80005526:	438080e7          	jalr	1080(ra) # 8000395a <iunlockput>
    end_op();
    8000552a:	fffff097          	auipc	ra,0xfffff
    8000552e:	c0e080e7          	jalr	-1010(ra) # 80004138 <end_op>
    return -1;
    80005532:	57fd                	li	a5,-1
    80005534:	a83d                	j	80005572 <sys_link+0x13c>
    iunlockput(dp);
    80005536:	854a                	mv	a0,s2
    80005538:	ffffe097          	auipc	ra,0xffffe
    8000553c:	422080e7          	jalr	1058(ra) # 8000395a <iunlockput>
  ilock(ip);
    80005540:	8526                	mv	a0,s1
    80005542:	ffffe097          	auipc	ra,0xffffe
    80005546:	1b6080e7          	jalr	438(ra) # 800036f8 <ilock>
  ip->nlink--;
    8000554a:	04a4d783          	lhu	a5,74(s1)
    8000554e:	37fd                	addiw	a5,a5,-1
    80005550:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005554:	8526                	mv	a0,s1
    80005556:	ffffe097          	auipc	ra,0xffffe
    8000555a:	0d8080e7          	jalr	216(ra) # 8000362e <iupdate>
  iunlockput(ip);
    8000555e:	8526                	mv	a0,s1
    80005560:	ffffe097          	auipc	ra,0xffffe
    80005564:	3fa080e7          	jalr	1018(ra) # 8000395a <iunlockput>
  end_op();
    80005568:	fffff097          	auipc	ra,0xfffff
    8000556c:	bd0080e7          	jalr	-1072(ra) # 80004138 <end_op>
  return -1;
    80005570:	57fd                	li	a5,-1
}
    80005572:	853e                	mv	a0,a5
    80005574:	70b2                	ld	ra,296(sp)
    80005576:	7412                	ld	s0,288(sp)
    80005578:	64f2                	ld	s1,280(sp)
    8000557a:	6952                	ld	s2,272(sp)
    8000557c:	6155                	addi	sp,sp,304
    8000557e:	8082                	ret

0000000080005580 <sys_unlink>:
{
    80005580:	7151                	addi	sp,sp,-240
    80005582:	f586                	sd	ra,232(sp)
    80005584:	f1a2                	sd	s0,224(sp)
    80005586:	eda6                	sd	s1,216(sp)
    80005588:	e9ca                	sd	s2,208(sp)
    8000558a:	e5ce                	sd	s3,200(sp)
    8000558c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000558e:	08000613          	li	a2,128
    80005592:	f3040593          	addi	a1,s0,-208
    80005596:	4501                	li	a0,0
    80005598:	ffffd097          	auipc	ra,0xffffd
    8000559c:	61e080e7          	jalr	1566(ra) # 80002bb6 <argstr>
    800055a0:	18054163          	bltz	a0,80005722 <sys_unlink+0x1a2>
  begin_op();
    800055a4:	fffff097          	auipc	ra,0xfffff
    800055a8:	b14080e7          	jalr	-1260(ra) # 800040b8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800055ac:	fb040593          	addi	a1,s0,-80
    800055b0:	f3040513          	addi	a0,s0,-208
    800055b4:	fffff097          	auipc	ra,0xfffff
    800055b8:	916080e7          	jalr	-1770(ra) # 80003eca <nameiparent>
    800055bc:	84aa                	mv	s1,a0
    800055be:	c979                	beqz	a0,80005694 <sys_unlink+0x114>
  ilock(dp);
    800055c0:	ffffe097          	auipc	ra,0xffffe
    800055c4:	138080e7          	jalr	312(ra) # 800036f8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800055c8:	00003597          	auipc	a1,0x3
    800055cc:	0b858593          	addi	a1,a1,184 # 80008680 <syscalls+0x2c0>
    800055d0:	fb040513          	addi	a0,s0,-80
    800055d4:	ffffe097          	auipc	ra,0xffffe
    800055d8:	5ec080e7          	jalr	1516(ra) # 80003bc0 <namecmp>
    800055dc:	14050a63          	beqz	a0,80005730 <sys_unlink+0x1b0>
    800055e0:	00003597          	auipc	a1,0x3
    800055e4:	0a858593          	addi	a1,a1,168 # 80008688 <syscalls+0x2c8>
    800055e8:	fb040513          	addi	a0,s0,-80
    800055ec:	ffffe097          	auipc	ra,0xffffe
    800055f0:	5d4080e7          	jalr	1492(ra) # 80003bc0 <namecmp>
    800055f4:	12050e63          	beqz	a0,80005730 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800055f8:	f2c40613          	addi	a2,s0,-212
    800055fc:	fb040593          	addi	a1,s0,-80
    80005600:	8526                	mv	a0,s1
    80005602:	ffffe097          	auipc	ra,0xffffe
    80005606:	5d8080e7          	jalr	1496(ra) # 80003bda <dirlookup>
    8000560a:	892a                	mv	s2,a0
    8000560c:	12050263          	beqz	a0,80005730 <sys_unlink+0x1b0>
  ilock(ip);
    80005610:	ffffe097          	auipc	ra,0xffffe
    80005614:	0e8080e7          	jalr	232(ra) # 800036f8 <ilock>
  if(ip->nlink < 1)
    80005618:	04a91783          	lh	a5,74(s2)
    8000561c:	08f05263          	blez	a5,800056a0 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005620:	04491703          	lh	a4,68(s2)
    80005624:	4785                	li	a5,1
    80005626:	08f70563          	beq	a4,a5,800056b0 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000562a:	4641                	li	a2,16
    8000562c:	4581                	li	a1,0
    8000562e:	fc040513          	addi	a0,s0,-64
    80005632:	ffffb097          	auipc	ra,0xffffb
    80005636:	6c8080e7          	jalr	1736(ra) # 80000cfa <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000563a:	4741                	li	a4,16
    8000563c:	f2c42683          	lw	a3,-212(s0)
    80005640:	fc040613          	addi	a2,s0,-64
    80005644:	4581                	li	a1,0
    80005646:	8526                	mv	a0,s1
    80005648:	ffffe097          	auipc	ra,0xffffe
    8000564c:	45c080e7          	jalr	1116(ra) # 80003aa4 <writei>
    80005650:	47c1                	li	a5,16
    80005652:	0af51563          	bne	a0,a5,800056fc <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005656:	04491703          	lh	a4,68(s2)
    8000565a:	4785                	li	a5,1
    8000565c:	0af70863          	beq	a4,a5,8000570c <sys_unlink+0x18c>
  iunlockput(dp);
    80005660:	8526                	mv	a0,s1
    80005662:	ffffe097          	auipc	ra,0xffffe
    80005666:	2f8080e7          	jalr	760(ra) # 8000395a <iunlockput>
  ip->nlink--;
    8000566a:	04a95783          	lhu	a5,74(s2)
    8000566e:	37fd                	addiw	a5,a5,-1
    80005670:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005674:	854a                	mv	a0,s2
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	fb8080e7          	jalr	-72(ra) # 8000362e <iupdate>
  iunlockput(ip);
    8000567e:	854a                	mv	a0,s2
    80005680:	ffffe097          	auipc	ra,0xffffe
    80005684:	2da080e7          	jalr	730(ra) # 8000395a <iunlockput>
  end_op();
    80005688:	fffff097          	auipc	ra,0xfffff
    8000568c:	ab0080e7          	jalr	-1360(ra) # 80004138 <end_op>
  return 0;
    80005690:	4501                	li	a0,0
    80005692:	a84d                	j	80005744 <sys_unlink+0x1c4>
    end_op();
    80005694:	fffff097          	auipc	ra,0xfffff
    80005698:	aa4080e7          	jalr	-1372(ra) # 80004138 <end_op>
    return -1;
    8000569c:	557d                	li	a0,-1
    8000569e:	a05d                	j	80005744 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800056a0:	00003517          	auipc	a0,0x3
    800056a4:	01050513          	addi	a0,a0,16 # 800086b0 <syscalls+0x2f0>
    800056a8:	ffffb097          	auipc	ra,0xffffb
    800056ac:	e9a080e7          	jalr	-358(ra) # 80000542 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056b0:	04c92703          	lw	a4,76(s2)
    800056b4:	02000793          	li	a5,32
    800056b8:	f6e7f9e3          	bgeu	a5,a4,8000562a <sys_unlink+0xaa>
    800056bc:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056c0:	4741                	li	a4,16
    800056c2:	86ce                	mv	a3,s3
    800056c4:	f1840613          	addi	a2,s0,-232
    800056c8:	4581                	li	a1,0
    800056ca:	854a                	mv	a0,s2
    800056cc:	ffffe097          	auipc	ra,0xffffe
    800056d0:	2e0080e7          	jalr	736(ra) # 800039ac <readi>
    800056d4:	47c1                	li	a5,16
    800056d6:	00f51b63          	bne	a0,a5,800056ec <sys_unlink+0x16c>
    if(de.inum != 0)
    800056da:	f1845783          	lhu	a5,-232(s0)
    800056de:	e7a1                	bnez	a5,80005726 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056e0:	29c1                	addiw	s3,s3,16
    800056e2:	04c92783          	lw	a5,76(s2)
    800056e6:	fcf9ede3          	bltu	s3,a5,800056c0 <sys_unlink+0x140>
    800056ea:	b781                	j	8000562a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800056ec:	00003517          	auipc	a0,0x3
    800056f0:	fdc50513          	addi	a0,a0,-36 # 800086c8 <syscalls+0x308>
    800056f4:	ffffb097          	auipc	ra,0xffffb
    800056f8:	e4e080e7          	jalr	-434(ra) # 80000542 <panic>
    panic("unlink: writei");
    800056fc:	00003517          	auipc	a0,0x3
    80005700:	fe450513          	addi	a0,a0,-28 # 800086e0 <syscalls+0x320>
    80005704:	ffffb097          	auipc	ra,0xffffb
    80005708:	e3e080e7          	jalr	-450(ra) # 80000542 <panic>
    dp->nlink--;
    8000570c:	04a4d783          	lhu	a5,74(s1)
    80005710:	37fd                	addiw	a5,a5,-1
    80005712:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005716:	8526                	mv	a0,s1
    80005718:	ffffe097          	auipc	ra,0xffffe
    8000571c:	f16080e7          	jalr	-234(ra) # 8000362e <iupdate>
    80005720:	b781                	j	80005660 <sys_unlink+0xe0>
    return -1;
    80005722:	557d                	li	a0,-1
    80005724:	a005                	j	80005744 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005726:	854a                	mv	a0,s2
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	232080e7          	jalr	562(ra) # 8000395a <iunlockput>
  iunlockput(dp);
    80005730:	8526                	mv	a0,s1
    80005732:	ffffe097          	auipc	ra,0xffffe
    80005736:	228080e7          	jalr	552(ra) # 8000395a <iunlockput>
  end_op();
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	9fe080e7          	jalr	-1538(ra) # 80004138 <end_op>
  return -1;
    80005742:	557d                	li	a0,-1
}
    80005744:	70ae                	ld	ra,232(sp)
    80005746:	740e                	ld	s0,224(sp)
    80005748:	64ee                	ld	s1,216(sp)
    8000574a:	694e                	ld	s2,208(sp)
    8000574c:	69ae                	ld	s3,200(sp)
    8000574e:	616d                	addi	sp,sp,240
    80005750:	8082                	ret

0000000080005752 <sys_open>:

uint64
sys_open(void)
{
    80005752:	7131                	addi	sp,sp,-192
    80005754:	fd06                	sd	ra,184(sp)
    80005756:	f922                	sd	s0,176(sp)
    80005758:	f526                	sd	s1,168(sp)
    8000575a:	f14a                	sd	s2,160(sp)
    8000575c:	ed4e                	sd	s3,152(sp)
    8000575e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005760:	08000613          	li	a2,128
    80005764:	f5040593          	addi	a1,s0,-176
    80005768:	4501                	li	a0,0
    8000576a:	ffffd097          	auipc	ra,0xffffd
    8000576e:	44c080e7          	jalr	1100(ra) # 80002bb6 <argstr>
    return -1;
    80005772:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005774:	0c054163          	bltz	a0,80005836 <sys_open+0xe4>
    80005778:	f4c40593          	addi	a1,s0,-180
    8000577c:	4505                	li	a0,1
    8000577e:	ffffd097          	auipc	ra,0xffffd
    80005782:	3f4080e7          	jalr	1012(ra) # 80002b72 <argint>
    80005786:	0a054863          	bltz	a0,80005836 <sys_open+0xe4>

  begin_op();
    8000578a:	fffff097          	auipc	ra,0xfffff
    8000578e:	92e080e7          	jalr	-1746(ra) # 800040b8 <begin_op>

  if(omode & O_CREATE){
    80005792:	f4c42783          	lw	a5,-180(s0)
    80005796:	2007f793          	andi	a5,a5,512
    8000579a:	cbdd                	beqz	a5,80005850 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000579c:	4681                	li	a3,0
    8000579e:	4601                	li	a2,0
    800057a0:	4589                	li	a1,2
    800057a2:	f5040513          	addi	a0,s0,-176
    800057a6:	00000097          	auipc	ra,0x0
    800057aa:	8bc080e7          	jalr	-1860(ra) # 80005062 <create>
    800057ae:	892a                	mv	s2,a0
    if(ip == 0){
    800057b0:	c959                	beqz	a0,80005846 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800057b2:	04491703          	lh	a4,68(s2)
    800057b6:	478d                	li	a5,3
    800057b8:	00f71763          	bne	a4,a5,800057c6 <sys_open+0x74>
    800057bc:	04695703          	lhu	a4,70(s2)
    800057c0:	47a5                	li	a5,9
    800057c2:	0ce7ec63          	bltu	a5,a4,8000589a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800057c6:	fffff097          	auipc	ra,0xfffff
    800057ca:	d08080e7          	jalr	-760(ra) # 800044ce <filealloc>
    800057ce:	89aa                	mv	s3,a0
    800057d0:	10050263          	beqz	a0,800058d4 <sys_open+0x182>
    800057d4:	00000097          	auipc	ra,0x0
    800057d8:	84c080e7          	jalr	-1972(ra) # 80005020 <fdalloc>
    800057dc:	84aa                	mv	s1,a0
    800057de:	0e054663          	bltz	a0,800058ca <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800057e2:	04491703          	lh	a4,68(s2)
    800057e6:	478d                	li	a5,3
    800057e8:	0cf70463          	beq	a4,a5,800058b0 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800057ec:	4789                	li	a5,2
    800057ee:	00f9a023          	sw	a5,0(s3) # 1000 <_entry-0x7ffff000>
    f->off = 0;
    800057f2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800057f6:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800057fa:	f4c42783          	lw	a5,-180(s0)
    800057fe:	0017c713          	xori	a4,a5,1
    80005802:	8b05                	andi	a4,a4,1
    80005804:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005808:	0037f713          	andi	a4,a5,3
    8000580c:	00e03733          	snez	a4,a4
    80005810:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005814:	4007f793          	andi	a5,a5,1024
    80005818:	c791                	beqz	a5,80005824 <sys_open+0xd2>
    8000581a:	04491703          	lh	a4,68(s2)
    8000581e:	4789                	li	a5,2
    80005820:	08f70f63          	beq	a4,a5,800058be <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005824:	854a                	mv	a0,s2
    80005826:	ffffe097          	auipc	ra,0xffffe
    8000582a:	f94080e7          	jalr	-108(ra) # 800037ba <iunlock>
  end_op();
    8000582e:	fffff097          	auipc	ra,0xfffff
    80005832:	90a080e7          	jalr	-1782(ra) # 80004138 <end_op>

  return fd;
}
    80005836:	8526                	mv	a0,s1
    80005838:	70ea                	ld	ra,184(sp)
    8000583a:	744a                	ld	s0,176(sp)
    8000583c:	74aa                	ld	s1,168(sp)
    8000583e:	790a                	ld	s2,160(sp)
    80005840:	69ea                	ld	s3,152(sp)
    80005842:	6129                	addi	sp,sp,192
    80005844:	8082                	ret
      end_op();
    80005846:	fffff097          	auipc	ra,0xfffff
    8000584a:	8f2080e7          	jalr	-1806(ra) # 80004138 <end_op>
      return -1;
    8000584e:	b7e5                	j	80005836 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005850:	f5040513          	addi	a0,s0,-176
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	658080e7          	jalr	1624(ra) # 80003eac <namei>
    8000585c:	892a                	mv	s2,a0
    8000585e:	c905                	beqz	a0,8000588e <sys_open+0x13c>
    ilock(ip);
    80005860:	ffffe097          	auipc	ra,0xffffe
    80005864:	e98080e7          	jalr	-360(ra) # 800036f8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005868:	04491703          	lh	a4,68(s2)
    8000586c:	4785                	li	a5,1
    8000586e:	f4f712e3          	bne	a4,a5,800057b2 <sys_open+0x60>
    80005872:	f4c42783          	lw	a5,-180(s0)
    80005876:	dba1                	beqz	a5,800057c6 <sys_open+0x74>
      iunlockput(ip);
    80005878:	854a                	mv	a0,s2
    8000587a:	ffffe097          	auipc	ra,0xffffe
    8000587e:	0e0080e7          	jalr	224(ra) # 8000395a <iunlockput>
      end_op();
    80005882:	fffff097          	auipc	ra,0xfffff
    80005886:	8b6080e7          	jalr	-1866(ra) # 80004138 <end_op>
      return -1;
    8000588a:	54fd                	li	s1,-1
    8000588c:	b76d                	j	80005836 <sys_open+0xe4>
      end_op();
    8000588e:	fffff097          	auipc	ra,0xfffff
    80005892:	8aa080e7          	jalr	-1878(ra) # 80004138 <end_op>
      return -1;
    80005896:	54fd                	li	s1,-1
    80005898:	bf79                	j	80005836 <sys_open+0xe4>
    iunlockput(ip);
    8000589a:	854a                	mv	a0,s2
    8000589c:	ffffe097          	auipc	ra,0xffffe
    800058a0:	0be080e7          	jalr	190(ra) # 8000395a <iunlockput>
    end_op();
    800058a4:	fffff097          	auipc	ra,0xfffff
    800058a8:	894080e7          	jalr	-1900(ra) # 80004138 <end_op>
    return -1;
    800058ac:	54fd                	li	s1,-1
    800058ae:	b761                	j	80005836 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800058b0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800058b4:	04691783          	lh	a5,70(s2)
    800058b8:	02f99223          	sh	a5,36(s3)
    800058bc:	bf2d                	j	800057f6 <sys_open+0xa4>
    itrunc(ip);
    800058be:	854a                	mv	a0,s2
    800058c0:	ffffe097          	auipc	ra,0xffffe
    800058c4:	f46080e7          	jalr	-186(ra) # 80003806 <itrunc>
    800058c8:	bfb1                	j	80005824 <sys_open+0xd2>
      fileclose(f);
    800058ca:	854e                	mv	a0,s3
    800058cc:	fffff097          	auipc	ra,0xfffff
    800058d0:	cbe080e7          	jalr	-834(ra) # 8000458a <fileclose>
    iunlockput(ip);
    800058d4:	854a                	mv	a0,s2
    800058d6:	ffffe097          	auipc	ra,0xffffe
    800058da:	084080e7          	jalr	132(ra) # 8000395a <iunlockput>
    end_op();
    800058de:	fffff097          	auipc	ra,0xfffff
    800058e2:	85a080e7          	jalr	-1958(ra) # 80004138 <end_op>
    return -1;
    800058e6:	54fd                	li	s1,-1
    800058e8:	b7b9                	j	80005836 <sys_open+0xe4>

00000000800058ea <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800058ea:	7175                	addi	sp,sp,-144
    800058ec:	e506                	sd	ra,136(sp)
    800058ee:	e122                	sd	s0,128(sp)
    800058f0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800058f2:	ffffe097          	auipc	ra,0xffffe
    800058f6:	7c6080e7          	jalr	1990(ra) # 800040b8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058fa:	08000613          	li	a2,128
    800058fe:	f7040593          	addi	a1,s0,-144
    80005902:	4501                	li	a0,0
    80005904:	ffffd097          	auipc	ra,0xffffd
    80005908:	2b2080e7          	jalr	690(ra) # 80002bb6 <argstr>
    8000590c:	02054963          	bltz	a0,8000593e <sys_mkdir+0x54>
    80005910:	4681                	li	a3,0
    80005912:	4601                	li	a2,0
    80005914:	4585                	li	a1,1
    80005916:	f7040513          	addi	a0,s0,-144
    8000591a:	fffff097          	auipc	ra,0xfffff
    8000591e:	748080e7          	jalr	1864(ra) # 80005062 <create>
    80005922:	cd11                	beqz	a0,8000593e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005924:	ffffe097          	auipc	ra,0xffffe
    80005928:	036080e7          	jalr	54(ra) # 8000395a <iunlockput>
  end_op();
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	80c080e7          	jalr	-2036(ra) # 80004138 <end_op>
  return 0;
    80005934:	4501                	li	a0,0
}
    80005936:	60aa                	ld	ra,136(sp)
    80005938:	640a                	ld	s0,128(sp)
    8000593a:	6149                	addi	sp,sp,144
    8000593c:	8082                	ret
    end_op();
    8000593e:	ffffe097          	auipc	ra,0xffffe
    80005942:	7fa080e7          	jalr	2042(ra) # 80004138 <end_op>
    return -1;
    80005946:	557d                	li	a0,-1
    80005948:	b7fd                	j	80005936 <sys_mkdir+0x4c>

000000008000594a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000594a:	7135                	addi	sp,sp,-160
    8000594c:	ed06                	sd	ra,152(sp)
    8000594e:	e922                	sd	s0,144(sp)
    80005950:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005952:	ffffe097          	auipc	ra,0xffffe
    80005956:	766080e7          	jalr	1894(ra) # 800040b8 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000595a:	08000613          	li	a2,128
    8000595e:	f7040593          	addi	a1,s0,-144
    80005962:	4501                	li	a0,0
    80005964:	ffffd097          	auipc	ra,0xffffd
    80005968:	252080e7          	jalr	594(ra) # 80002bb6 <argstr>
    8000596c:	04054a63          	bltz	a0,800059c0 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005970:	f6c40593          	addi	a1,s0,-148
    80005974:	4505                	li	a0,1
    80005976:	ffffd097          	auipc	ra,0xffffd
    8000597a:	1fc080e7          	jalr	508(ra) # 80002b72 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000597e:	04054163          	bltz	a0,800059c0 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005982:	f6840593          	addi	a1,s0,-152
    80005986:	4509                	li	a0,2
    80005988:	ffffd097          	auipc	ra,0xffffd
    8000598c:	1ea080e7          	jalr	490(ra) # 80002b72 <argint>
     argint(1, &major) < 0 ||
    80005990:	02054863          	bltz	a0,800059c0 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005994:	f6841683          	lh	a3,-152(s0)
    80005998:	f6c41603          	lh	a2,-148(s0)
    8000599c:	458d                	li	a1,3
    8000599e:	f7040513          	addi	a0,s0,-144
    800059a2:	fffff097          	auipc	ra,0xfffff
    800059a6:	6c0080e7          	jalr	1728(ra) # 80005062 <create>
     argint(2, &minor) < 0 ||
    800059aa:	c919                	beqz	a0,800059c0 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059ac:	ffffe097          	auipc	ra,0xffffe
    800059b0:	fae080e7          	jalr	-82(ra) # 8000395a <iunlockput>
  end_op();
    800059b4:	ffffe097          	auipc	ra,0xffffe
    800059b8:	784080e7          	jalr	1924(ra) # 80004138 <end_op>
  return 0;
    800059bc:	4501                	li	a0,0
    800059be:	a031                	j	800059ca <sys_mknod+0x80>
    end_op();
    800059c0:	ffffe097          	auipc	ra,0xffffe
    800059c4:	778080e7          	jalr	1912(ra) # 80004138 <end_op>
    return -1;
    800059c8:	557d                	li	a0,-1
}
    800059ca:	60ea                	ld	ra,152(sp)
    800059cc:	644a                	ld	s0,144(sp)
    800059ce:	610d                	addi	sp,sp,160
    800059d0:	8082                	ret

00000000800059d2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800059d2:	7135                	addi	sp,sp,-160
    800059d4:	ed06                	sd	ra,152(sp)
    800059d6:	e922                	sd	s0,144(sp)
    800059d8:	e526                	sd	s1,136(sp)
    800059da:	e14a                	sd	s2,128(sp)
    800059dc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800059de:	ffffc097          	auipc	ra,0xffffc
    800059e2:	0b6080e7          	jalr	182(ra) # 80001a94 <myproc>
    800059e6:	892a                	mv	s2,a0
  
  begin_op();
    800059e8:	ffffe097          	auipc	ra,0xffffe
    800059ec:	6d0080e7          	jalr	1744(ra) # 800040b8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800059f0:	08000613          	li	a2,128
    800059f4:	f6040593          	addi	a1,s0,-160
    800059f8:	4501                	li	a0,0
    800059fa:	ffffd097          	auipc	ra,0xffffd
    800059fe:	1bc080e7          	jalr	444(ra) # 80002bb6 <argstr>
    80005a02:	04054b63          	bltz	a0,80005a58 <sys_chdir+0x86>
    80005a06:	f6040513          	addi	a0,s0,-160
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	4a2080e7          	jalr	1186(ra) # 80003eac <namei>
    80005a12:	84aa                	mv	s1,a0
    80005a14:	c131                	beqz	a0,80005a58 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	ce2080e7          	jalr	-798(ra) # 800036f8 <ilock>
  if(ip->type != T_DIR){
    80005a1e:	04449703          	lh	a4,68(s1)
    80005a22:	4785                	li	a5,1
    80005a24:	04f71063          	bne	a4,a5,80005a64 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a28:	8526                	mv	a0,s1
    80005a2a:	ffffe097          	auipc	ra,0xffffe
    80005a2e:	d90080e7          	jalr	-624(ra) # 800037ba <iunlock>
  iput(p->cwd);
    80005a32:	15093503          	ld	a0,336(s2)
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	e7c080e7          	jalr	-388(ra) # 800038b2 <iput>
  end_op();
    80005a3e:	ffffe097          	auipc	ra,0xffffe
    80005a42:	6fa080e7          	jalr	1786(ra) # 80004138 <end_op>
  p->cwd = ip;
    80005a46:	14993823          	sd	s1,336(s2)
  return 0;
    80005a4a:	4501                	li	a0,0
}
    80005a4c:	60ea                	ld	ra,152(sp)
    80005a4e:	644a                	ld	s0,144(sp)
    80005a50:	64aa                	ld	s1,136(sp)
    80005a52:	690a                	ld	s2,128(sp)
    80005a54:	610d                	addi	sp,sp,160
    80005a56:	8082                	ret
    end_op();
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	6e0080e7          	jalr	1760(ra) # 80004138 <end_op>
    return -1;
    80005a60:	557d                	li	a0,-1
    80005a62:	b7ed                	j	80005a4c <sys_chdir+0x7a>
    iunlockput(ip);
    80005a64:	8526                	mv	a0,s1
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	ef4080e7          	jalr	-268(ra) # 8000395a <iunlockput>
    end_op();
    80005a6e:	ffffe097          	auipc	ra,0xffffe
    80005a72:	6ca080e7          	jalr	1738(ra) # 80004138 <end_op>
    return -1;
    80005a76:	557d                	li	a0,-1
    80005a78:	bfd1                	j	80005a4c <sys_chdir+0x7a>

0000000080005a7a <sys_exec>:

uint64
sys_exec(void)
{
    80005a7a:	7145                	addi	sp,sp,-464
    80005a7c:	e786                	sd	ra,456(sp)
    80005a7e:	e3a2                	sd	s0,448(sp)
    80005a80:	ff26                	sd	s1,440(sp)
    80005a82:	fb4a                	sd	s2,432(sp)
    80005a84:	f74e                	sd	s3,424(sp)
    80005a86:	f352                	sd	s4,416(sp)
    80005a88:	ef56                	sd	s5,408(sp)
    80005a8a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a8c:	08000613          	li	a2,128
    80005a90:	f4040593          	addi	a1,s0,-192
    80005a94:	4501                	li	a0,0
    80005a96:	ffffd097          	auipc	ra,0xffffd
    80005a9a:	120080e7          	jalr	288(ra) # 80002bb6 <argstr>
    return -1;
    80005a9e:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005aa0:	0c054a63          	bltz	a0,80005b74 <sys_exec+0xfa>
    80005aa4:	e3840593          	addi	a1,s0,-456
    80005aa8:	4505                	li	a0,1
    80005aaa:	ffffd097          	auipc	ra,0xffffd
    80005aae:	0ea080e7          	jalr	234(ra) # 80002b94 <argaddr>
    80005ab2:	0c054163          	bltz	a0,80005b74 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005ab6:	10000613          	li	a2,256
    80005aba:	4581                	li	a1,0
    80005abc:	e4040513          	addi	a0,s0,-448
    80005ac0:	ffffb097          	auipc	ra,0xffffb
    80005ac4:	23a080e7          	jalr	570(ra) # 80000cfa <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ac8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005acc:	89a6                	mv	s3,s1
    80005ace:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ad0:	02000a13          	li	s4,32
    80005ad4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ad8:	00391793          	slli	a5,s2,0x3
    80005adc:	e3040593          	addi	a1,s0,-464
    80005ae0:	e3843503          	ld	a0,-456(s0)
    80005ae4:	953e                	add	a0,a0,a5
    80005ae6:	ffffd097          	auipc	ra,0xffffd
    80005aea:	ff2080e7          	jalr	-14(ra) # 80002ad8 <fetchaddr>
    80005aee:	02054a63          	bltz	a0,80005b22 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005af2:	e3043783          	ld	a5,-464(s0)
    80005af6:	c3b9                	beqz	a5,80005b3c <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005af8:	ffffb097          	auipc	ra,0xffffb
    80005afc:	016080e7          	jalr	22(ra) # 80000b0e <kalloc>
    80005b00:	85aa                	mv	a1,a0
    80005b02:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b06:	cd11                	beqz	a0,80005b22 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b08:	6605                	lui	a2,0x1
    80005b0a:	e3043503          	ld	a0,-464(s0)
    80005b0e:	ffffd097          	auipc	ra,0xffffd
    80005b12:	01c080e7          	jalr	28(ra) # 80002b2a <fetchstr>
    80005b16:	00054663          	bltz	a0,80005b22 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005b1a:	0905                	addi	s2,s2,1
    80005b1c:	09a1                	addi	s3,s3,8
    80005b1e:	fb491be3          	bne	s2,s4,80005ad4 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b22:	10048913          	addi	s2,s1,256
    80005b26:	6088                	ld	a0,0(s1)
    80005b28:	c529                	beqz	a0,80005b72 <sys_exec+0xf8>
    kfree(argv[i]);
    80005b2a:	ffffb097          	auipc	ra,0xffffb
    80005b2e:	ee8080e7          	jalr	-280(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b32:	04a1                	addi	s1,s1,8
    80005b34:	ff2499e3          	bne	s1,s2,80005b26 <sys_exec+0xac>
  return -1;
    80005b38:	597d                	li	s2,-1
    80005b3a:	a82d                	j	80005b74 <sys_exec+0xfa>
      argv[i] = 0;
    80005b3c:	0a8e                	slli	s5,s5,0x3
    80005b3e:	fc040793          	addi	a5,s0,-64
    80005b42:	9abe                	add	s5,s5,a5
    80005b44:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    80005b48:	e4040593          	addi	a1,s0,-448
    80005b4c:	f4040513          	addi	a0,s0,-192
    80005b50:	fffff097          	auipc	ra,0xfffff
    80005b54:	0c0080e7          	jalr	192(ra) # 80004c10 <exec>
    80005b58:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b5a:	10048993          	addi	s3,s1,256
    80005b5e:	6088                	ld	a0,0(s1)
    80005b60:	c911                	beqz	a0,80005b74 <sys_exec+0xfa>
    kfree(argv[i]);
    80005b62:	ffffb097          	auipc	ra,0xffffb
    80005b66:	eb0080e7          	jalr	-336(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b6a:	04a1                	addi	s1,s1,8
    80005b6c:	ff3499e3          	bne	s1,s3,80005b5e <sys_exec+0xe4>
    80005b70:	a011                	j	80005b74 <sys_exec+0xfa>
  return -1;
    80005b72:	597d                	li	s2,-1
}
    80005b74:	854a                	mv	a0,s2
    80005b76:	60be                	ld	ra,456(sp)
    80005b78:	641e                	ld	s0,448(sp)
    80005b7a:	74fa                	ld	s1,440(sp)
    80005b7c:	795a                	ld	s2,432(sp)
    80005b7e:	79ba                	ld	s3,424(sp)
    80005b80:	7a1a                	ld	s4,416(sp)
    80005b82:	6afa                	ld	s5,408(sp)
    80005b84:	6179                	addi	sp,sp,464
    80005b86:	8082                	ret

0000000080005b88 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b88:	711d                	addi	sp,sp,-96
    80005b8a:	ec86                	sd	ra,88(sp)
    80005b8c:	e8a2                	sd	s0,80(sp)
    80005b8e:	e4a6                	sd	s1,72(sp)
    80005b90:	e0ca                	sd	s2,64(sp)
    80005b92:	fc4e                	sd	s3,56(sp)
    80005b94:	f852                	sd	s4,48(sp)
    80005b96:	f456                	sd	s5,40(sp)
    80005b98:	1080                	addi	s0,sp,96
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b9a:	ffffc097          	auipc	ra,0xffffc
    80005b9e:	efa080e7          	jalr	-262(ra) # 80001a94 <myproc>
    80005ba2:	892a                	mv	s2,a0

  if(argaddr(0, &fdarray) < 0)
    80005ba4:	fb840593          	addi	a1,s0,-72
    80005ba8:	4501                	li	a0,0
    80005baa:	ffffd097          	auipc	ra,0xffffd
    80005bae:	fea080e7          	jalr	-22(ra) # 80002b94 <argaddr>
    80005bb2:	14054663          	bltz	a0,80005cfe <sys_pipe+0x176>
    return -1;
  
  for(uint64 va = PGROUNDDOWN(fdarray); va < PGROUNDUP(fdarray + 2*sizeof(fd0)); va += PGSIZE) {
    80005bb6:	fb843783          	ld	a5,-72(s0)
    80005bba:	76fd                	lui	a3,0xfffff
    80005bbc:	00d7f4b3          	and	s1,a5,a3
    80005bc0:	6705                	lui	a4,0x1
    80005bc2:	071d                	addi	a4,a4,7
    80005bc4:	97ba                	add	a5,a5,a4
    80005bc6:	8ff5                	and	a5,a5,a3
    80005bc8:	04f4f063          	bgeu	s1,a5,80005c08 <sys_pipe+0x80>
    80005bcc:	6985                	lui	s3,0x1
    80005bce:	8aba                	mv	s5,a4
    80005bd0:	7a7d                	lui	s4,0xfffff
    80005bd2:	a809                	j	80005be4 <sys_pipe+0x5c>
    80005bd4:	94ce                	add	s1,s1,s3
    80005bd6:	fb843783          	ld	a5,-72(s0)
    80005bda:	97d6                	add	a5,a5,s5
    80005bdc:	0147f7b3          	and	a5,a5,s4
    80005be0:	02f4f463          	bgeu	s1,a5,80005c08 <sys_pipe+0x80>
    if(walkaddr(p->pagetable, va) == 0) {
    80005be4:	85a6                	mv	a1,s1
    80005be6:	05093503          	ld	a0,80(s2)
    80005bea:	ffffb097          	auipc	ra,0xffffb
    80005bee:	49e080e7          	jalr	1182(ra) # 80001088 <walkaddr>
    80005bf2:	f16d                	bnez	a0,80005bd4 <sys_pipe+0x4c>
      if(lazy_wr_alloc(va, p) < 0)
    80005bf4:	85ca                	mv	a1,s2
    80005bf6:	8526                	mv	a0,s1
    80005bf8:	ffffc097          	auipc	ra,0xffffc
    80005bfc:	c58080e7          	jalr	-936(ra) # 80001850 <lazy_wr_alloc>
    80005c00:	fc055ae3          	bgez	a0,80005bd4 <sys_pipe+0x4c>
        return -1;
    80005c04:	557d                	li	a0,-1
    80005c06:	a0dd                	j	80005cec <sys_pipe+0x164>
    }
  }

  if(pipealloc(&rf, &wf) < 0)
    80005c08:	fa840593          	addi	a1,s0,-88
    80005c0c:	fb040513          	addi	a0,s0,-80
    80005c10:	fffff097          	auipc	ra,0xfffff
    80005c14:	cd0080e7          	jalr	-816(ra) # 800048e0 <pipealloc>
    80005c18:	87aa                	mv	a5,a0
    return -1;
    80005c1a:	557d                	li	a0,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c1c:	0c07c863          	bltz	a5,80005cec <sys_pipe+0x164>
  fd0 = -1;
    80005c20:	57fd                	li	a5,-1
    80005c22:	faf42223          	sw	a5,-92(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c26:	fb043503          	ld	a0,-80(s0)
    80005c2a:	fffff097          	auipc	ra,0xfffff
    80005c2e:	3f6080e7          	jalr	1014(ra) # 80005020 <fdalloc>
    80005c32:	faa42223          	sw	a0,-92(s0)
    80005c36:	08054e63          	bltz	a0,80005cd2 <sys_pipe+0x14a>
    80005c3a:	fa843503          	ld	a0,-88(s0)
    80005c3e:	fffff097          	auipc	ra,0xfffff
    80005c42:	3e2080e7          	jalr	994(ra) # 80005020 <fdalloc>
    80005c46:	faa42023          	sw	a0,-96(s0)
    80005c4a:	06054b63          	bltz	a0,80005cc0 <sys_pipe+0x138>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c4e:	4691                	li	a3,4
    80005c50:	fa440613          	addi	a2,s0,-92
    80005c54:	fb843583          	ld	a1,-72(s0)
    80005c58:	05093503          	ld	a0,80(s2)
    80005c5c:	ffffc097          	auipc	ra,0xffffc
    80005c60:	a26080e7          	jalr	-1498(ra) # 80001682 <copyout>
    80005c64:	02054263          	bltz	a0,80005c88 <sys_pipe+0x100>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c68:	4691                	li	a3,4
    80005c6a:	fa040613          	addi	a2,s0,-96
    80005c6e:	fb843583          	ld	a1,-72(s0)
    80005c72:	0591                	addi	a1,a1,4
    80005c74:	05093503          	ld	a0,80(s2)
    80005c78:	ffffc097          	auipc	ra,0xffffc
    80005c7c:	a0a080e7          	jalr	-1526(ra) # 80001682 <copyout>
    80005c80:	87aa                	mv	a5,a0
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c82:	4501                	li	a0,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c84:	0607d463          	bgez	a5,80005cec <sys_pipe+0x164>
    p->ofile[fd0] = 0;
    80005c88:	fa442783          	lw	a5,-92(s0)
    80005c8c:	07e9                	addi	a5,a5,26
    80005c8e:	078e                	slli	a5,a5,0x3
    80005c90:	97ca                	add	a5,a5,s2
    80005c92:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c96:	fa042783          	lw	a5,-96(s0)
    80005c9a:	07e9                	addi	a5,a5,26
    80005c9c:	078e                	slli	a5,a5,0x3
    80005c9e:	993e                	add	s2,s2,a5
    80005ca0:	00093023          	sd	zero,0(s2)
    fileclose(rf);
    80005ca4:	fb043503          	ld	a0,-80(s0)
    80005ca8:	fffff097          	auipc	ra,0xfffff
    80005cac:	8e2080e7          	jalr	-1822(ra) # 8000458a <fileclose>
    fileclose(wf);
    80005cb0:	fa843503          	ld	a0,-88(s0)
    80005cb4:	fffff097          	auipc	ra,0xfffff
    80005cb8:	8d6080e7          	jalr	-1834(ra) # 8000458a <fileclose>
    return -1;
    80005cbc:	557d                	li	a0,-1
    80005cbe:	a03d                	j	80005cec <sys_pipe+0x164>
    if(fd0 >= 0)
    80005cc0:	fa442783          	lw	a5,-92(s0)
    80005cc4:	0007c763          	bltz	a5,80005cd2 <sys_pipe+0x14a>
      p->ofile[fd0] = 0;
    80005cc8:	07e9                	addi	a5,a5,26
    80005cca:	078e                	slli	a5,a5,0x3
    80005ccc:	993e                	add	s2,s2,a5
    80005cce:	00093023          	sd	zero,0(s2)
    fileclose(rf);
    80005cd2:	fb043503          	ld	a0,-80(s0)
    80005cd6:	fffff097          	auipc	ra,0xfffff
    80005cda:	8b4080e7          	jalr	-1868(ra) # 8000458a <fileclose>
    fileclose(wf);
    80005cde:	fa843503          	ld	a0,-88(s0)
    80005ce2:	fffff097          	auipc	ra,0xfffff
    80005ce6:	8a8080e7          	jalr	-1880(ra) # 8000458a <fileclose>
    return -1;
    80005cea:	557d                	li	a0,-1
}
    80005cec:	60e6                	ld	ra,88(sp)
    80005cee:	6446                	ld	s0,80(sp)
    80005cf0:	64a6                	ld	s1,72(sp)
    80005cf2:	6906                	ld	s2,64(sp)
    80005cf4:	79e2                	ld	s3,56(sp)
    80005cf6:	7a42                	ld	s4,48(sp)
    80005cf8:	7aa2                	ld	s5,40(sp)
    80005cfa:	6125                	addi	sp,sp,96
    80005cfc:	8082                	ret
    return -1;
    80005cfe:	557d                	li	a0,-1
    80005d00:	b7f5                	j	80005cec <sys_pipe+0x164>
	...

0000000080005d10 <kernelvec>:
    80005d10:	7111                	addi	sp,sp,-256
    80005d12:	e006                	sd	ra,0(sp)
    80005d14:	e40a                	sd	sp,8(sp)
    80005d16:	e80e                	sd	gp,16(sp)
    80005d18:	ec12                	sd	tp,24(sp)
    80005d1a:	f016                	sd	t0,32(sp)
    80005d1c:	f41a                	sd	t1,40(sp)
    80005d1e:	f81e                	sd	t2,48(sp)
    80005d20:	fc22                	sd	s0,56(sp)
    80005d22:	e0a6                	sd	s1,64(sp)
    80005d24:	e4aa                	sd	a0,72(sp)
    80005d26:	e8ae                	sd	a1,80(sp)
    80005d28:	ecb2                	sd	a2,88(sp)
    80005d2a:	f0b6                	sd	a3,96(sp)
    80005d2c:	f4ba                	sd	a4,104(sp)
    80005d2e:	f8be                	sd	a5,112(sp)
    80005d30:	fcc2                	sd	a6,120(sp)
    80005d32:	e146                	sd	a7,128(sp)
    80005d34:	e54a                	sd	s2,136(sp)
    80005d36:	e94e                	sd	s3,144(sp)
    80005d38:	ed52                	sd	s4,152(sp)
    80005d3a:	f156                	sd	s5,160(sp)
    80005d3c:	f55a                	sd	s6,168(sp)
    80005d3e:	f95e                	sd	s7,176(sp)
    80005d40:	fd62                	sd	s8,184(sp)
    80005d42:	e1e6                	sd	s9,192(sp)
    80005d44:	e5ea                	sd	s10,200(sp)
    80005d46:	e9ee                	sd	s11,208(sp)
    80005d48:	edf2                	sd	t3,216(sp)
    80005d4a:	f1f6                	sd	t4,224(sp)
    80005d4c:	f5fa                	sd	t5,232(sp)
    80005d4e:	f9fe                	sd	t6,240(sp)
    80005d50:	c55fc0ef          	jal	ra,800029a4 <kerneltrap>
    80005d54:	6082                	ld	ra,0(sp)
    80005d56:	6122                	ld	sp,8(sp)
    80005d58:	61c2                	ld	gp,16(sp)
    80005d5a:	7282                	ld	t0,32(sp)
    80005d5c:	7322                	ld	t1,40(sp)
    80005d5e:	73c2                	ld	t2,48(sp)
    80005d60:	7462                	ld	s0,56(sp)
    80005d62:	6486                	ld	s1,64(sp)
    80005d64:	6526                	ld	a0,72(sp)
    80005d66:	65c6                	ld	a1,80(sp)
    80005d68:	6666                	ld	a2,88(sp)
    80005d6a:	7686                	ld	a3,96(sp)
    80005d6c:	7726                	ld	a4,104(sp)
    80005d6e:	77c6                	ld	a5,112(sp)
    80005d70:	7866                	ld	a6,120(sp)
    80005d72:	688a                	ld	a7,128(sp)
    80005d74:	692a                	ld	s2,136(sp)
    80005d76:	69ca                	ld	s3,144(sp)
    80005d78:	6a6a                	ld	s4,152(sp)
    80005d7a:	7a8a                	ld	s5,160(sp)
    80005d7c:	7b2a                	ld	s6,168(sp)
    80005d7e:	7bca                	ld	s7,176(sp)
    80005d80:	7c6a                	ld	s8,184(sp)
    80005d82:	6c8e                	ld	s9,192(sp)
    80005d84:	6d2e                	ld	s10,200(sp)
    80005d86:	6dce                	ld	s11,208(sp)
    80005d88:	6e6e                	ld	t3,216(sp)
    80005d8a:	7e8e                	ld	t4,224(sp)
    80005d8c:	7f2e                	ld	t5,232(sp)
    80005d8e:	7fce                	ld	t6,240(sp)
    80005d90:	6111                	addi	sp,sp,256
    80005d92:	10200073          	sret
    80005d96:	00000013          	nop
    80005d9a:	00000013          	nop
    80005d9e:	0001                	nop

0000000080005da0 <timervec>:
    80005da0:	34051573          	csrrw	a0,mscratch,a0
    80005da4:	e10c                	sd	a1,0(a0)
    80005da6:	e510                	sd	a2,8(a0)
    80005da8:	e914                	sd	a3,16(a0)
    80005daa:	710c                	ld	a1,32(a0)
    80005dac:	7510                	ld	a2,40(a0)
    80005dae:	6194                	ld	a3,0(a1)
    80005db0:	96b2                	add	a3,a3,a2
    80005db2:	e194                	sd	a3,0(a1)
    80005db4:	4589                	li	a1,2
    80005db6:	14459073          	csrw	sip,a1
    80005dba:	6914                	ld	a3,16(a0)
    80005dbc:	6510                	ld	a2,8(a0)
    80005dbe:	610c                	ld	a1,0(a0)
    80005dc0:	34051573          	csrrw	a0,mscratch,a0
    80005dc4:	30200073          	mret
	...

0000000080005dca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005dca:	1141                	addi	sp,sp,-16
    80005dcc:	e422                	sd	s0,8(sp)
    80005dce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005dd0:	0c0007b7          	lui	a5,0xc000
    80005dd4:	4705                	li	a4,1
    80005dd6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005dd8:	c3d8                	sw	a4,4(a5)
}
    80005dda:	6422                	ld	s0,8(sp)
    80005ddc:	0141                	addi	sp,sp,16
    80005dde:	8082                	ret

0000000080005de0 <plicinithart>:

void
plicinithart(void)
{
    80005de0:	1141                	addi	sp,sp,-16
    80005de2:	e406                	sd	ra,8(sp)
    80005de4:	e022                	sd	s0,0(sp)
    80005de6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005de8:	ffffc097          	auipc	ra,0xffffc
    80005dec:	c80080e7          	jalr	-896(ra) # 80001a68 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005df0:	0085171b          	slliw	a4,a0,0x8
    80005df4:	0c0027b7          	lui	a5,0xc002
    80005df8:	97ba                	add	a5,a5,a4
    80005dfa:	40200713          	li	a4,1026
    80005dfe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e02:	00d5151b          	slliw	a0,a0,0xd
    80005e06:	0c2017b7          	lui	a5,0xc201
    80005e0a:	953e                	add	a0,a0,a5
    80005e0c:	00052023          	sw	zero,0(a0)
}
    80005e10:	60a2                	ld	ra,8(sp)
    80005e12:	6402                	ld	s0,0(sp)
    80005e14:	0141                	addi	sp,sp,16
    80005e16:	8082                	ret

0000000080005e18 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e18:	1141                	addi	sp,sp,-16
    80005e1a:	e406                	sd	ra,8(sp)
    80005e1c:	e022                	sd	s0,0(sp)
    80005e1e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e20:	ffffc097          	auipc	ra,0xffffc
    80005e24:	c48080e7          	jalr	-952(ra) # 80001a68 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e28:	00d5179b          	slliw	a5,a0,0xd
    80005e2c:	0c201537          	lui	a0,0xc201
    80005e30:	953e                	add	a0,a0,a5
  return irq;
}
    80005e32:	4148                	lw	a0,4(a0)
    80005e34:	60a2                	ld	ra,8(sp)
    80005e36:	6402                	ld	s0,0(sp)
    80005e38:	0141                	addi	sp,sp,16
    80005e3a:	8082                	ret

0000000080005e3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e3c:	1101                	addi	sp,sp,-32
    80005e3e:	ec06                	sd	ra,24(sp)
    80005e40:	e822                	sd	s0,16(sp)
    80005e42:	e426                	sd	s1,8(sp)
    80005e44:	1000                	addi	s0,sp,32
    80005e46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e48:	ffffc097          	auipc	ra,0xffffc
    80005e4c:	c20080e7          	jalr	-992(ra) # 80001a68 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e50:	00d5151b          	slliw	a0,a0,0xd
    80005e54:	0c2017b7          	lui	a5,0xc201
    80005e58:	97aa                	add	a5,a5,a0
    80005e5a:	c3c4                	sw	s1,4(a5)
}
    80005e5c:	60e2                	ld	ra,24(sp)
    80005e5e:	6442                	ld	s0,16(sp)
    80005e60:	64a2                	ld	s1,8(sp)
    80005e62:	6105                	addi	sp,sp,32
    80005e64:	8082                	ret

0000000080005e66 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e66:	1141                	addi	sp,sp,-16
    80005e68:	e406                	sd	ra,8(sp)
    80005e6a:	e022                	sd	s0,0(sp)
    80005e6c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e6e:	479d                	li	a5,7
    80005e70:	04a7cc63          	blt	a5,a0,80005ec8 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005e74:	0001d797          	auipc	a5,0x1d
    80005e78:	18c78793          	addi	a5,a5,396 # 80023000 <disk>
    80005e7c:	00a78733          	add	a4,a5,a0
    80005e80:	6789                	lui	a5,0x2
    80005e82:	97ba                	add	a5,a5,a4
    80005e84:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005e88:	eba1                	bnez	a5,80005ed8 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005e8a:	00451713          	slli	a4,a0,0x4
    80005e8e:	0001f797          	auipc	a5,0x1f
    80005e92:	1727b783          	ld	a5,370(a5) # 80025000 <disk+0x2000>
    80005e96:	97ba                	add	a5,a5,a4
    80005e98:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005e9c:	0001d797          	auipc	a5,0x1d
    80005ea0:	16478793          	addi	a5,a5,356 # 80023000 <disk>
    80005ea4:	97aa                	add	a5,a5,a0
    80005ea6:	6509                	lui	a0,0x2
    80005ea8:	953e                	add	a0,a0,a5
    80005eaa:	4785                	li	a5,1
    80005eac:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005eb0:	0001f517          	auipc	a0,0x1f
    80005eb4:	16850513          	addi	a0,a0,360 # 80025018 <disk+0x2018>
    80005eb8:	ffffc097          	auipc	ra,0xffffc
    80005ebc:	570080e7          	jalr	1392(ra) # 80002428 <wakeup>
}
    80005ec0:	60a2                	ld	ra,8(sp)
    80005ec2:	6402                	ld	s0,0(sp)
    80005ec4:	0141                	addi	sp,sp,16
    80005ec6:	8082                	ret
    panic("virtio_disk_intr 1");
    80005ec8:	00003517          	auipc	a0,0x3
    80005ecc:	82850513          	addi	a0,a0,-2008 # 800086f0 <syscalls+0x330>
    80005ed0:	ffffa097          	auipc	ra,0xffffa
    80005ed4:	672080e7          	jalr	1650(ra) # 80000542 <panic>
    panic("virtio_disk_intr 2");
    80005ed8:	00003517          	auipc	a0,0x3
    80005edc:	83050513          	addi	a0,a0,-2000 # 80008708 <syscalls+0x348>
    80005ee0:	ffffa097          	auipc	ra,0xffffa
    80005ee4:	662080e7          	jalr	1634(ra) # 80000542 <panic>

0000000080005ee8 <virtio_disk_init>:
{
    80005ee8:	1101                	addi	sp,sp,-32
    80005eea:	ec06                	sd	ra,24(sp)
    80005eec:	e822                	sd	s0,16(sp)
    80005eee:	e426                	sd	s1,8(sp)
    80005ef0:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ef2:	00003597          	auipc	a1,0x3
    80005ef6:	82e58593          	addi	a1,a1,-2002 # 80008720 <syscalls+0x360>
    80005efa:	0001f517          	auipc	a0,0x1f
    80005efe:	1ae50513          	addi	a0,a0,430 # 800250a8 <disk+0x20a8>
    80005f02:	ffffb097          	auipc	ra,0xffffb
    80005f06:	c6c080e7          	jalr	-916(ra) # 80000b6e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f0a:	100017b7          	lui	a5,0x10001
    80005f0e:	4398                	lw	a4,0(a5)
    80005f10:	2701                	sext.w	a4,a4
    80005f12:	747277b7          	lui	a5,0x74727
    80005f16:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f1a:	0ef71163          	bne	a4,a5,80005ffc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005f1e:	100017b7          	lui	a5,0x10001
    80005f22:	43dc                	lw	a5,4(a5)
    80005f24:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f26:	4705                	li	a4,1
    80005f28:	0ce79a63          	bne	a5,a4,80005ffc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f2c:	100017b7          	lui	a5,0x10001
    80005f30:	479c                	lw	a5,8(a5)
    80005f32:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005f34:	4709                	li	a4,2
    80005f36:	0ce79363          	bne	a5,a4,80005ffc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f3a:	100017b7          	lui	a5,0x10001
    80005f3e:	47d8                	lw	a4,12(a5)
    80005f40:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f42:	554d47b7          	lui	a5,0x554d4
    80005f46:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f4a:	0af71963          	bne	a4,a5,80005ffc <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f4e:	100017b7          	lui	a5,0x10001
    80005f52:	4705                	li	a4,1
    80005f54:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f56:	470d                	li	a4,3
    80005f58:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005f5a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005f5c:	c7ffe737          	lui	a4,0xc7ffe
    80005f60:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005f64:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f66:	2701                	sext.w	a4,a4
    80005f68:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f6a:	472d                	li	a4,11
    80005f6c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f6e:	473d                	li	a4,15
    80005f70:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005f72:	6705                	lui	a4,0x1
    80005f74:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f76:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005f7a:	5bdc                	lw	a5,52(a5)
    80005f7c:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f7e:	c7d9                	beqz	a5,8000600c <virtio_disk_init+0x124>
  if(max < NUM)
    80005f80:	471d                	li	a4,7
    80005f82:	08f77d63          	bgeu	a4,a5,8000601c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f86:	100014b7          	lui	s1,0x10001
    80005f8a:	47a1                	li	a5,8
    80005f8c:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005f8e:	6609                	lui	a2,0x2
    80005f90:	4581                	li	a1,0
    80005f92:	0001d517          	auipc	a0,0x1d
    80005f96:	06e50513          	addi	a0,a0,110 # 80023000 <disk>
    80005f9a:	ffffb097          	auipc	ra,0xffffb
    80005f9e:	d60080e7          	jalr	-672(ra) # 80000cfa <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005fa2:	0001d717          	auipc	a4,0x1d
    80005fa6:	05e70713          	addi	a4,a4,94 # 80023000 <disk>
    80005faa:	00c75793          	srli	a5,a4,0xc
    80005fae:	2781                	sext.w	a5,a5
    80005fb0:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005fb2:	0001f797          	auipc	a5,0x1f
    80005fb6:	04e78793          	addi	a5,a5,78 # 80025000 <disk+0x2000>
    80005fba:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005fbc:	0001d717          	auipc	a4,0x1d
    80005fc0:	0c470713          	addi	a4,a4,196 # 80023080 <disk+0x80>
    80005fc4:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005fc6:	0001e717          	auipc	a4,0x1e
    80005fca:	03a70713          	addi	a4,a4,58 # 80024000 <disk+0x1000>
    80005fce:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005fd0:	4705                	li	a4,1
    80005fd2:	00e78c23          	sb	a4,24(a5)
    80005fd6:	00e78ca3          	sb	a4,25(a5)
    80005fda:	00e78d23          	sb	a4,26(a5)
    80005fde:	00e78da3          	sb	a4,27(a5)
    80005fe2:	00e78e23          	sb	a4,28(a5)
    80005fe6:	00e78ea3          	sb	a4,29(a5)
    80005fea:	00e78f23          	sb	a4,30(a5)
    80005fee:	00e78fa3          	sb	a4,31(a5)
}
    80005ff2:	60e2                	ld	ra,24(sp)
    80005ff4:	6442                	ld	s0,16(sp)
    80005ff6:	64a2                	ld	s1,8(sp)
    80005ff8:	6105                	addi	sp,sp,32
    80005ffa:	8082                	ret
    panic("could not find virtio disk");
    80005ffc:	00002517          	auipc	a0,0x2
    80006000:	73450513          	addi	a0,a0,1844 # 80008730 <syscalls+0x370>
    80006004:	ffffa097          	auipc	ra,0xffffa
    80006008:	53e080e7          	jalr	1342(ra) # 80000542 <panic>
    panic("virtio disk has no queue 0");
    8000600c:	00002517          	auipc	a0,0x2
    80006010:	74450513          	addi	a0,a0,1860 # 80008750 <syscalls+0x390>
    80006014:	ffffa097          	auipc	ra,0xffffa
    80006018:	52e080e7          	jalr	1326(ra) # 80000542 <panic>
    panic("virtio disk max queue too short");
    8000601c:	00002517          	auipc	a0,0x2
    80006020:	75450513          	addi	a0,a0,1876 # 80008770 <syscalls+0x3b0>
    80006024:	ffffa097          	auipc	ra,0xffffa
    80006028:	51e080e7          	jalr	1310(ra) # 80000542 <panic>

000000008000602c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000602c:	7175                	addi	sp,sp,-144
    8000602e:	e506                	sd	ra,136(sp)
    80006030:	e122                	sd	s0,128(sp)
    80006032:	fca6                	sd	s1,120(sp)
    80006034:	f8ca                	sd	s2,112(sp)
    80006036:	f4ce                	sd	s3,104(sp)
    80006038:	f0d2                	sd	s4,96(sp)
    8000603a:	ecd6                	sd	s5,88(sp)
    8000603c:	e8da                	sd	s6,80(sp)
    8000603e:	e4de                	sd	s7,72(sp)
    80006040:	e0e2                	sd	s8,64(sp)
    80006042:	fc66                	sd	s9,56(sp)
    80006044:	f86a                	sd	s10,48(sp)
    80006046:	f46e                	sd	s11,40(sp)
    80006048:	0900                	addi	s0,sp,144
    8000604a:	8aaa                	mv	s5,a0
    8000604c:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000604e:	00c52c83          	lw	s9,12(a0)
    80006052:	001c9c9b          	slliw	s9,s9,0x1
    80006056:	1c82                	slli	s9,s9,0x20
    80006058:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000605c:	0001f517          	auipc	a0,0x1f
    80006060:	04c50513          	addi	a0,a0,76 # 800250a8 <disk+0x20a8>
    80006064:	ffffb097          	auipc	ra,0xffffb
    80006068:	b9a080e7          	jalr	-1126(ra) # 80000bfe <acquire>
  for(int i = 0; i < 3; i++){
    8000606c:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000606e:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006070:	0001dc17          	auipc	s8,0x1d
    80006074:	f90c0c13          	addi	s8,s8,-112 # 80023000 <disk>
    80006078:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    8000607a:	4b0d                	li	s6,3
    8000607c:	a0ad                	j	800060e6 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    8000607e:	00fc0733          	add	a4,s8,a5
    80006082:	975e                	add	a4,a4,s7
    80006084:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006088:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000608a:	0207c563          	bltz	a5,800060b4 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000608e:	2905                	addiw	s2,s2,1
    80006090:	0611                	addi	a2,a2,4
    80006092:	19690d63          	beq	s2,s6,8000622c <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006096:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006098:	0001f717          	auipc	a4,0x1f
    8000609c:	f8070713          	addi	a4,a4,-128 # 80025018 <disk+0x2018>
    800060a0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800060a2:	00074683          	lbu	a3,0(a4)
    800060a6:	fee1                	bnez	a3,8000607e <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800060a8:	2785                	addiw	a5,a5,1
    800060aa:	0705                	addi	a4,a4,1
    800060ac:	fe979be3          	bne	a5,s1,800060a2 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800060b0:	57fd                	li	a5,-1
    800060b2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800060b4:	01205d63          	blez	s2,800060ce <virtio_disk_rw+0xa2>
    800060b8:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800060ba:	000a2503          	lw	a0,0(s4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800060be:	00000097          	auipc	ra,0x0
    800060c2:	da8080e7          	jalr	-600(ra) # 80005e66 <free_desc>
      for(int j = 0; j < i; j++)
    800060c6:	2d85                	addiw	s11,s11,1
    800060c8:	0a11                	addi	s4,s4,4
    800060ca:	ffb918e3          	bne	s2,s11,800060ba <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800060ce:	0001f597          	auipc	a1,0x1f
    800060d2:	fda58593          	addi	a1,a1,-38 # 800250a8 <disk+0x20a8>
    800060d6:	0001f517          	auipc	a0,0x1f
    800060da:	f4250513          	addi	a0,a0,-190 # 80025018 <disk+0x2018>
    800060de:	ffffc097          	auipc	ra,0xffffc
    800060e2:	1ca080e7          	jalr	458(ra) # 800022a8 <sleep>
  for(int i = 0; i < 3; i++){
    800060e6:	f8040a13          	addi	s4,s0,-128
{
    800060ea:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800060ec:	894e                	mv	s2,s3
    800060ee:	b765                	j	80006096 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800060f0:	0001f717          	auipc	a4,0x1f
    800060f4:	f1073703          	ld	a4,-240(a4) # 80025000 <disk+0x2000>
    800060f8:	973e                	add	a4,a4,a5
    800060fa:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060fe:	0001d517          	auipc	a0,0x1d
    80006102:	f0250513          	addi	a0,a0,-254 # 80023000 <disk>
    80006106:	0001f717          	auipc	a4,0x1f
    8000610a:	efa70713          	addi	a4,a4,-262 # 80025000 <disk+0x2000>
    8000610e:	6314                	ld	a3,0(a4)
    80006110:	96be                	add	a3,a3,a5
    80006112:	00c6d603          	lhu	a2,12(a3) # fffffffffffff00c <end+0xffffffff7ffd900c>
    80006116:	00166613          	ori	a2,a2,1
    8000611a:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000611e:	f8842683          	lw	a3,-120(s0)
    80006122:	6310                	ld	a2,0(a4)
    80006124:	97b2                	add	a5,a5,a2
    80006126:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    8000612a:	20048613          	addi	a2,s1,512 # 10001200 <_entry-0x6fffee00>
    8000612e:	0612                	slli	a2,a2,0x4
    80006130:	962a                	add	a2,a2,a0
    80006132:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006136:	00469793          	slli	a5,a3,0x4
    8000613a:	630c                	ld	a1,0(a4)
    8000613c:	95be                	add	a1,a1,a5
    8000613e:	6689                	lui	a3,0x2
    80006140:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006144:	96ca                	add	a3,a3,s2
    80006146:	96aa                	add	a3,a3,a0
    80006148:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    8000614a:	6314                	ld	a3,0(a4)
    8000614c:	96be                	add	a3,a3,a5
    8000614e:	4585                	li	a1,1
    80006150:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006152:	6314                	ld	a3,0(a4)
    80006154:	96be                	add	a3,a3,a5
    80006156:	4509                	li	a0,2
    80006158:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    8000615c:	6314                	ld	a3,0(a4)
    8000615e:	97b6                	add	a5,a5,a3
    80006160:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006164:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006168:	03563423          	sd	s5,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    8000616c:	6714                	ld	a3,8(a4)
    8000616e:	0026d783          	lhu	a5,2(a3)
    80006172:	8b9d                	andi	a5,a5,7
    80006174:	0789                	addi	a5,a5,2
    80006176:	0786                	slli	a5,a5,0x1
    80006178:	97b6                	add	a5,a5,a3
    8000617a:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    8000617e:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    80006182:	6718                	ld	a4,8(a4)
    80006184:	00275783          	lhu	a5,2(a4)
    80006188:	2785                	addiw	a5,a5,1
    8000618a:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000618e:	100017b7          	lui	a5,0x10001
    80006192:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006196:	004aa783          	lw	a5,4(s5)
    8000619a:	02b79163          	bne	a5,a1,800061bc <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    8000619e:	0001f917          	auipc	s2,0x1f
    800061a2:	f0a90913          	addi	s2,s2,-246 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    800061a6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800061a8:	85ca                	mv	a1,s2
    800061aa:	8556                	mv	a0,s5
    800061ac:	ffffc097          	auipc	ra,0xffffc
    800061b0:	0fc080e7          	jalr	252(ra) # 800022a8 <sleep>
  while(b->disk == 1) {
    800061b4:	004aa783          	lw	a5,4(s5)
    800061b8:	fe9788e3          	beq	a5,s1,800061a8 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800061bc:	f8042483          	lw	s1,-128(s0)
    800061c0:	20048793          	addi	a5,s1,512
    800061c4:	00479713          	slli	a4,a5,0x4
    800061c8:	0001d797          	auipc	a5,0x1d
    800061cc:	e3878793          	addi	a5,a5,-456 # 80023000 <disk>
    800061d0:	97ba                	add	a5,a5,a4
    800061d2:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800061d6:	0001f917          	auipc	s2,0x1f
    800061da:	e2a90913          	addi	s2,s2,-470 # 80025000 <disk+0x2000>
    800061de:	a019                	j	800061e4 <virtio_disk_rw+0x1b8>
      i = disk.desc[i].next;
    800061e0:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    800061e4:	8526                	mv	a0,s1
    800061e6:	00000097          	auipc	ra,0x0
    800061ea:	c80080e7          	jalr	-896(ra) # 80005e66 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800061ee:	0492                	slli	s1,s1,0x4
    800061f0:	00093783          	ld	a5,0(s2)
    800061f4:	94be                	add	s1,s1,a5
    800061f6:	00c4d783          	lhu	a5,12(s1)
    800061fa:	8b85                	andi	a5,a5,1
    800061fc:	f3f5                	bnez	a5,800061e0 <virtio_disk_rw+0x1b4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061fe:	0001f517          	auipc	a0,0x1f
    80006202:	eaa50513          	addi	a0,a0,-342 # 800250a8 <disk+0x20a8>
    80006206:	ffffb097          	auipc	ra,0xffffb
    8000620a:	aac080e7          	jalr	-1364(ra) # 80000cb2 <release>
}
    8000620e:	60aa                	ld	ra,136(sp)
    80006210:	640a                	ld	s0,128(sp)
    80006212:	74e6                	ld	s1,120(sp)
    80006214:	7946                	ld	s2,112(sp)
    80006216:	79a6                	ld	s3,104(sp)
    80006218:	7a06                	ld	s4,96(sp)
    8000621a:	6ae6                	ld	s5,88(sp)
    8000621c:	6b46                	ld	s6,80(sp)
    8000621e:	6ba6                	ld	s7,72(sp)
    80006220:	6c06                	ld	s8,64(sp)
    80006222:	7ce2                	ld	s9,56(sp)
    80006224:	7d42                	ld	s10,48(sp)
    80006226:	7da2                	ld	s11,40(sp)
    80006228:	6149                	addi	sp,sp,144
    8000622a:	8082                	ret
  if(write)
    8000622c:	01a037b3          	snez	a5,s10
    80006230:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006234:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006238:	f7943c23          	sd	s9,-136(s0)
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    8000623c:	f8042483          	lw	s1,-128(s0)
    80006240:	00449913          	slli	s2,s1,0x4
    80006244:	0001f997          	auipc	s3,0x1f
    80006248:	dbc98993          	addi	s3,s3,-580 # 80025000 <disk+0x2000>
    8000624c:	0009ba03          	ld	s4,0(s3)
    80006250:	9a4a                	add	s4,s4,s2
    80006252:	f7040513          	addi	a0,s0,-144
    80006256:	ffffb097          	auipc	ra,0xffffb
    8000625a:	e74080e7          	jalr	-396(ra) # 800010ca <kvmpa>
    8000625e:	00aa3023          	sd	a0,0(s4)
  disk.desc[idx[0]].len = sizeof(buf0);
    80006262:	0009b783          	ld	a5,0(s3)
    80006266:	97ca                	add	a5,a5,s2
    80006268:	4741                	li	a4,16
    8000626a:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000626c:	0009b783          	ld	a5,0(s3)
    80006270:	97ca                	add	a5,a5,s2
    80006272:	4705                	li	a4,1
    80006274:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006278:	f8442783          	lw	a5,-124(s0)
    8000627c:	0009b703          	ld	a4,0(s3)
    80006280:	974a                	add	a4,a4,s2
    80006282:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006286:	0792                	slli	a5,a5,0x4
    80006288:	0009b703          	ld	a4,0(s3)
    8000628c:	973e                	add	a4,a4,a5
    8000628e:	058a8693          	addi	a3,s5,88
    80006292:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    80006294:	0009b703          	ld	a4,0(s3)
    80006298:	973e                	add	a4,a4,a5
    8000629a:	40000693          	li	a3,1024
    8000629e:	c714                	sw	a3,8(a4)
  if(write)
    800062a0:	e40d18e3          	bnez	s10,800060f0 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800062a4:	0001f717          	auipc	a4,0x1f
    800062a8:	d5c73703          	ld	a4,-676(a4) # 80025000 <disk+0x2000>
    800062ac:	973e                	add	a4,a4,a5
    800062ae:	4689                	li	a3,2
    800062b0:	00d71623          	sh	a3,12(a4)
    800062b4:	b5a9                	j	800060fe <virtio_disk_rw+0xd2>

00000000800062b6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800062b6:	1101                	addi	sp,sp,-32
    800062b8:	ec06                	sd	ra,24(sp)
    800062ba:	e822                	sd	s0,16(sp)
    800062bc:	e426                	sd	s1,8(sp)
    800062be:	e04a                	sd	s2,0(sp)
    800062c0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800062c2:	0001f517          	auipc	a0,0x1f
    800062c6:	de650513          	addi	a0,a0,-538 # 800250a8 <disk+0x20a8>
    800062ca:	ffffb097          	auipc	ra,0xffffb
    800062ce:	934080e7          	jalr	-1740(ra) # 80000bfe <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800062d2:	0001f717          	auipc	a4,0x1f
    800062d6:	d2e70713          	addi	a4,a4,-722 # 80025000 <disk+0x2000>
    800062da:	02075783          	lhu	a5,32(a4)
    800062de:	6b18                	ld	a4,16(a4)
    800062e0:	00275683          	lhu	a3,2(a4)
    800062e4:	8ebd                	xor	a3,a3,a5
    800062e6:	8a9d                	andi	a3,a3,7
    800062e8:	cab9                	beqz	a3,8000633e <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    800062ea:	0001d917          	auipc	s2,0x1d
    800062ee:	d1690913          	addi	s2,s2,-746 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800062f2:	0001f497          	auipc	s1,0x1f
    800062f6:	d0e48493          	addi	s1,s1,-754 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    800062fa:	078e                	slli	a5,a5,0x3
    800062fc:	97ba                	add	a5,a5,a4
    800062fe:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006300:	20078713          	addi	a4,a5,512
    80006304:	0712                	slli	a4,a4,0x4
    80006306:	974a                	add	a4,a4,s2
    80006308:	03074703          	lbu	a4,48(a4)
    8000630c:	ef21                	bnez	a4,80006364 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000630e:	20078793          	addi	a5,a5,512
    80006312:	0792                	slli	a5,a5,0x4
    80006314:	97ca                	add	a5,a5,s2
    80006316:	7798                	ld	a4,40(a5)
    80006318:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    8000631c:	7788                	ld	a0,40(a5)
    8000631e:	ffffc097          	auipc	ra,0xffffc
    80006322:	10a080e7          	jalr	266(ra) # 80002428 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006326:	0204d783          	lhu	a5,32(s1)
    8000632a:	2785                	addiw	a5,a5,1
    8000632c:	8b9d                	andi	a5,a5,7
    8000632e:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006332:	6898                	ld	a4,16(s1)
    80006334:	00275683          	lhu	a3,2(a4)
    80006338:	8a9d                	andi	a3,a3,7
    8000633a:	fcf690e3          	bne	a3,a5,800062fa <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000633e:	10001737          	lui	a4,0x10001
    80006342:	533c                	lw	a5,96(a4)
    80006344:	8b8d                	andi	a5,a5,3
    80006346:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006348:	0001f517          	auipc	a0,0x1f
    8000634c:	d6050513          	addi	a0,a0,-672 # 800250a8 <disk+0x20a8>
    80006350:	ffffb097          	auipc	ra,0xffffb
    80006354:	962080e7          	jalr	-1694(ra) # 80000cb2 <release>
}
    80006358:	60e2                	ld	ra,24(sp)
    8000635a:	6442                	ld	s0,16(sp)
    8000635c:	64a2                	ld	s1,8(sp)
    8000635e:	6902                	ld	s2,0(sp)
    80006360:	6105                	addi	sp,sp,32
    80006362:	8082                	ret
      panic("virtio_disk_intr status");
    80006364:	00002517          	auipc	a0,0x2
    80006368:	42c50513          	addi	a0,a0,1068 # 80008790 <syscalls+0x3d0>
    8000636c:	ffffa097          	auipc	ra,0xffffa
    80006370:	1d6080e7          	jalr	470(ra) # 80000542 <panic>
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
