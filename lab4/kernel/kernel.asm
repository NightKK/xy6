
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd77ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e6e78793          	addi	a5,a5,-402 # 80000f14 <main>
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
    80000110:	b5e080e7          	jalr	-1186(ra) # 80000c6a <acquire>
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
    8000012a:	400080e7          	jalr	1024(ra) # 80002526 <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00001097          	auipc	ra,0x1
    8000013a:	802080e7          	jalr	-2046(ra) # 80000938 <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	bd0080e7          	jalr	-1072(ra) # 80000d1e <release>

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
    800001a0:	ace080e7          	jalr	-1330(ra) # 80000c6a <acquire>
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
    800001ce:	86c080e7          	jalr	-1940(ra) # 80001a36 <myproc>
    800001d2:	591c                	lw	a5,48(a0)
    800001d4:	e7b5                	bnez	a5,80000240 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001d6:	85a6                	mv	a1,s1
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	09c080e7          	jalr	156(ra) # 80002276 <sleep>
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
    8000021a:	2ba080e7          	jalr	698(ra) # 800024d0 <either_copyout>
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
    80000236:	aec080e7          	jalr	-1300(ra) # 80000d1e <release>

  return target - n;
    8000023a:	413b053b          	subw	a0,s6,s3
    8000023e:	a811                	j	80000252 <consoleread+0xe4>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	5f050513          	addi	a0,a0,1520 # 80011830 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	ad6080e7          	jalr	-1322(ra) # 80000d1e <release>
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
    80000294:	5ca080e7          	jalr	1482(ra) # 8000085a <uartputc_sync>
}
    80000298:	60a2                	ld	ra,8(sp)
    8000029a:	6402                	ld	s0,0(sp)
    8000029c:	0141                	addi	sp,sp,16
    8000029e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a0:	4521                	li	a0,8
    800002a2:	00000097          	auipc	ra,0x0
    800002a6:	5b8080e7          	jalr	1464(ra) # 8000085a <uartputc_sync>
    800002aa:	02000513          	li	a0,32
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	5ac080e7          	jalr	1452(ra) # 8000085a <uartputc_sync>
    800002b6:	4521                	li	a0,8
    800002b8:	00000097          	auipc	ra,0x0
    800002bc:	5a2080e7          	jalr	1442(ra) # 8000085a <uartputc_sync>
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
    800002dc:	992080e7          	jalr	-1646(ra) # 80000c6a <acquire>

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
    800002fa:	286080e7          	jalr	646(ra) # 8000257c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fe:	00011517          	auipc	a0,0x11
    80000302:	53250513          	addi	a0,a0,1330 # 80011830 <cons>
    80000306:	00001097          	auipc	ra,0x1
    8000030a:	a18080e7          	jalr	-1512(ra) # 80000d1e <release>
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
    8000044e:	fac080e7          	jalr	-84(ra) # 800023f6 <wakeup>
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
    80000470:	76e080e7          	jalr	1902(ra) # 80000bda <initlock>

  uartinit();
    80000474:	00000097          	auipc	ra,0x0
    80000478:	396080e7          	jalr	918(ra) # 8000080a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047c:	00022797          	auipc	a5,0x22
    80000480:	f3478793          	addi	a5,a5,-204 # 800223b0 <devsw>
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
    800004c2:	b9a60613          	addi	a2,a2,-1126 # 80008058 <digits>
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
    fp = *(uint64*)(fp - 16); // preivous fp
  }
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
    80000574:	b7050513          	addi	a0,a0,-1168 # 800080e0 <digits+0x88>
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
    800005ee:	a6eb0b13          	addi	s6,s6,-1426 # 80008058 <digits>
    switch(c){
    800005f2:	07300c93          	li	s9,115
    800005f6:	06400c13          	li	s8,100
    800005fa:	a82d                	j	80000634 <printf+0xa8>
    acquire(&pr.lock);
    800005fc:	00011517          	auipc	a0,0x11
    80000600:	2dc50513          	addi	a0,a0,732 # 800118d8 <pr>
    80000604:	00000097          	auipc	ra,0x0
    80000608:	666080e7          	jalr	1638(ra) # 80000c6a <acquire>
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
    80000766:	5bc080e7          	jalr	1468(ra) # 80000d1e <release>
}
    8000076a:	bfc9                	j	8000073c <printf+0x1b0>

000000008000076c <backtrace>:
backtrace(void) {
    8000076c:	7179                	addi	sp,sp,-48
    8000076e:	f406                	sd	ra,40(sp)
    80000770:	f022                	sd	s0,32(sp)
    80000772:	ec26                	sd	s1,24(sp)
    80000774:	e84a                	sd	s2,16(sp)
    80000776:	e44e                	sd	s3,8(sp)
    80000778:	e052                	sd	s4,0(sp)
    8000077a:	1800                	addi	s0,sp,48
  printf("backtrace:\n");
    8000077c:	00008517          	auipc	a0,0x8
    80000780:	8bc50513          	addi	a0,a0,-1860 # 80008038 <etext+0x38>
    80000784:	00000097          	auipc	ra,0x0
    80000788:	e08080e7          	jalr	-504(ra) # 8000058c <printf>
}
static inline uint64
r_fp()
{
  uint64 x;
  asm volatile("mv %0, s0" : "=r" (x) );
    8000078c:	84a2                	mv	s1,s0
  while (fp != PGROUNDUP(fp)) {
    8000078e:	6785                	lui	a5,0x1
    80000790:	17fd                	addi	a5,a5,-1
    80000792:	97a6                	add	a5,a5,s1
    80000794:	777d                	lui	a4,0xfffff
    80000796:	8ff9                	and	a5,a5,a4
    80000798:	02f48863          	beq	s1,a5,800007c8 <backtrace+0x5c>
    printf("%p\n", ra);
    8000079c:	00008a17          	auipc	s4,0x8
    800007a0:	8aca0a13          	addi	s4,s4,-1876 # 80008048 <etext+0x48>
  while (fp != PGROUNDUP(fp)) {
    800007a4:	6905                	lui	s2,0x1
    800007a6:	197d                	addi	s2,s2,-1
    800007a8:	79fd                	lui	s3,0xfffff
    printf("%p\n", ra);
    800007aa:	ff84b583          	ld	a1,-8(s1)
    800007ae:	8552                	mv	a0,s4
    800007b0:	00000097          	auipc	ra,0x0
    800007b4:	ddc080e7          	jalr	-548(ra) # 8000058c <printf>
    fp = *(uint64*)(fp - 16); // preivous fp
    800007b8:	ff04b483          	ld	s1,-16(s1)
  while (fp != PGROUNDUP(fp)) {
    800007bc:	012487b3          	add	a5,s1,s2
    800007c0:	0137f7b3          	and	a5,a5,s3
    800007c4:	fe9793e3          	bne	a5,s1,800007aa <backtrace+0x3e>
}
    800007c8:	70a2                	ld	ra,40(sp)
    800007ca:	7402                	ld	s0,32(sp)
    800007cc:	64e2                	ld	s1,24(sp)
    800007ce:	6942                	ld	s2,16(sp)
    800007d0:	69a2                	ld	s3,8(sp)
    800007d2:	6a02                	ld	s4,0(sp)
    800007d4:	6145                	addi	sp,sp,48
    800007d6:	8082                	ret

00000000800007d8 <printfinit>:
}


void
printfinit(void)
{
    800007d8:	1101                	addi	sp,sp,-32
    800007da:	ec06                	sd	ra,24(sp)
    800007dc:	e822                	sd	s0,16(sp)
    800007de:	e426                	sd	s1,8(sp)
    800007e0:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007e2:	00011497          	auipc	s1,0x11
    800007e6:	0f648493          	addi	s1,s1,246 # 800118d8 <pr>
    800007ea:	00008597          	auipc	a1,0x8
    800007ee:	86658593          	addi	a1,a1,-1946 # 80008050 <etext+0x50>
    800007f2:	8526                	mv	a0,s1
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	3e6080e7          	jalr	998(ra) # 80000bda <initlock>
  pr.locking = 1;
    800007fc:	4785                	li	a5,1
    800007fe:	cc9c                	sw	a5,24(s1)
}
    80000800:	60e2                	ld	ra,24(sp)
    80000802:	6442                	ld	s0,16(sp)
    80000804:	64a2                	ld	s1,8(sp)
    80000806:	6105                	addi	sp,sp,32
    80000808:	8082                	ret

000000008000080a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000080a:	1141                	addi	sp,sp,-16
    8000080c:	e406                	sd	ra,8(sp)
    8000080e:	e022                	sd	s0,0(sp)
    80000810:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000812:	100007b7          	lui	a5,0x10000
    80000816:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000081a:	f8000713          	li	a4,-128
    8000081e:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000822:	470d                	li	a4,3
    80000824:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000828:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000082c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000830:	469d                	li	a3,7
    80000832:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000836:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000083a:	00008597          	auipc	a1,0x8
    8000083e:	83658593          	addi	a1,a1,-1994 # 80008070 <digits+0x18>
    80000842:	00011517          	auipc	a0,0x11
    80000846:	0b650513          	addi	a0,a0,182 # 800118f8 <uart_tx_lock>
    8000084a:	00000097          	auipc	ra,0x0
    8000084e:	390080e7          	jalr	912(ra) # 80000bda <initlock>
}
    80000852:	60a2                	ld	ra,8(sp)
    80000854:	6402                	ld	s0,0(sp)
    80000856:	0141                	addi	sp,sp,16
    80000858:	8082                	ret

000000008000085a <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000085a:	1101                	addi	sp,sp,-32
    8000085c:	ec06                	sd	ra,24(sp)
    8000085e:	e822                	sd	s0,16(sp)
    80000860:	e426                	sd	s1,8(sp)
    80000862:	1000                	addi	s0,sp,32
    80000864:	84aa                	mv	s1,a0
  push_off();
    80000866:	00000097          	auipc	ra,0x0
    8000086a:	3b8080e7          	jalr	952(ra) # 80000c1e <push_off>

  if(panicked){
    8000086e:	00008797          	auipc	a5,0x8
    80000872:	7927a783          	lw	a5,1938(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000876:	10000737          	lui	a4,0x10000
  if(panicked){
    8000087a:	c391                	beqz	a5,8000087e <uartputc_sync+0x24>
    for(;;)
    8000087c:	a001                	j	8000087c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000087e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000882:	0207f793          	andi	a5,a5,32
    80000886:	dfe5                	beqz	a5,8000087e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000888:	0ff4f513          	andi	a0,s1,255
    8000088c:	100007b7          	lui	a5,0x10000
    80000890:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000894:	00000097          	auipc	ra,0x0
    80000898:	42a080e7          	jalr	1066(ra) # 80000cbe <pop_off>
}
    8000089c:	60e2                	ld	ra,24(sp)
    8000089e:	6442                	ld	s0,16(sp)
    800008a0:	64a2                	ld	s1,8(sp)
    800008a2:	6105                	addi	sp,sp,32
    800008a4:	8082                	ret

00000000800008a6 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008a6:	00008797          	auipc	a5,0x8
    800008aa:	75e7a783          	lw	a5,1886(a5) # 80009004 <uart_tx_r>
    800008ae:	00008717          	auipc	a4,0x8
    800008b2:	75a72703          	lw	a4,1882(a4) # 80009008 <uart_tx_w>
    800008b6:	08f70063          	beq	a4,a5,80000936 <uartstart+0x90>
{
    800008ba:	7139                	addi	sp,sp,-64
    800008bc:	fc06                	sd	ra,56(sp)
    800008be:	f822                	sd	s0,48(sp)
    800008c0:	f426                	sd	s1,40(sp)
    800008c2:	f04a                	sd	s2,32(sp)
    800008c4:	ec4e                	sd	s3,24(sp)
    800008c6:	e852                	sd	s4,16(sp)
    800008c8:	e456                	sd	s5,8(sp)
    800008ca:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008cc:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    800008d0:	00011a97          	auipc	s5,0x11
    800008d4:	028a8a93          	addi	s5,s5,40 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008d8:	00008497          	auipc	s1,0x8
    800008dc:	72c48493          	addi	s1,s1,1836 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800008e0:	00008a17          	auipc	s4,0x8
    800008e4:	728a0a13          	addi	s4,s4,1832 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e8:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    800008ec:	02077713          	andi	a4,a4,32
    800008f0:	cb15                	beqz	a4,80000924 <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r];
    800008f2:	00fa8733          	add	a4,s5,a5
    800008f6:	01874983          	lbu	s3,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008fa:	2785                	addiw	a5,a5,1
    800008fc:	41f7d71b          	sraiw	a4,a5,0x1f
    80000900:	01b7571b          	srliw	a4,a4,0x1b
    80000904:	9fb9                	addw	a5,a5,a4
    80000906:	8bfd                	andi	a5,a5,31
    80000908:	9f99                	subw	a5,a5,a4
    8000090a:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000090c:	8526                	mv	a0,s1
    8000090e:	00002097          	auipc	ra,0x2
    80000912:	ae8080e7          	jalr	-1304(ra) # 800023f6 <wakeup>
    
    WriteReg(THR, c);
    80000916:	01390023          	sb	s3,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000091a:	409c                	lw	a5,0(s1)
    8000091c:	000a2703          	lw	a4,0(s4)
    80000920:	fcf714e3          	bne	a4,a5,800008e8 <uartstart+0x42>
  }
}
    80000924:	70e2                	ld	ra,56(sp)
    80000926:	7442                	ld	s0,48(sp)
    80000928:	74a2                	ld	s1,40(sp)
    8000092a:	7902                	ld	s2,32(sp)
    8000092c:	69e2                	ld	s3,24(sp)
    8000092e:	6a42                	ld	s4,16(sp)
    80000930:	6aa2                	ld	s5,8(sp)
    80000932:	6121                	addi	sp,sp,64
    80000934:	8082                	ret
    80000936:	8082                	ret

0000000080000938 <uartputc>:
{
    80000938:	7179                	addi	sp,sp,-48
    8000093a:	f406                	sd	ra,40(sp)
    8000093c:	f022                	sd	s0,32(sp)
    8000093e:	ec26                	sd	s1,24(sp)
    80000940:	e84a                	sd	s2,16(sp)
    80000942:	e44e                	sd	s3,8(sp)
    80000944:	e052                	sd	s4,0(sp)
    80000946:	1800                	addi	s0,sp,48
    80000948:	84aa                	mv	s1,a0
  acquire(&uart_tx_lock);
    8000094a:	00011517          	auipc	a0,0x11
    8000094e:	fae50513          	addi	a0,a0,-82 # 800118f8 <uart_tx_lock>
    80000952:	00000097          	auipc	ra,0x0
    80000956:	318080e7          	jalr	792(ra) # 80000c6a <acquire>
  if(panicked){
    8000095a:	00008797          	auipc	a5,0x8
    8000095e:	6a67a783          	lw	a5,1702(a5) # 80009000 <panicked>
    80000962:	c391                	beqz	a5,80000966 <uartputc+0x2e>
    for(;;)
    80000964:	a001                	j	80000964 <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000966:	00008697          	auipc	a3,0x8
    8000096a:	6a26a683          	lw	a3,1698(a3) # 80009008 <uart_tx_w>
    8000096e:	0016879b          	addiw	a5,a3,1
    80000972:	41f7d71b          	sraiw	a4,a5,0x1f
    80000976:	01b7571b          	srliw	a4,a4,0x1b
    8000097a:	9fb9                	addw	a5,a5,a4
    8000097c:	8bfd                	andi	a5,a5,31
    8000097e:	9f99                	subw	a5,a5,a4
    80000980:	00008717          	auipc	a4,0x8
    80000984:	68472703          	lw	a4,1668(a4) # 80009004 <uart_tx_r>
    80000988:	04f71363          	bne	a4,a5,800009ce <uartputc+0x96>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000098c:	00011a17          	auipc	s4,0x11
    80000990:	f6ca0a13          	addi	s4,s4,-148 # 800118f8 <uart_tx_lock>
    80000994:	00008917          	auipc	s2,0x8
    80000998:	67090913          	addi	s2,s2,1648 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000099c:	00008997          	auipc	s3,0x8
    800009a0:	66c98993          	addi	s3,s3,1644 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    800009a4:	85d2                	mv	a1,s4
    800009a6:	854a                	mv	a0,s2
    800009a8:	00002097          	auipc	ra,0x2
    800009ac:	8ce080e7          	jalr	-1842(ra) # 80002276 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800009b0:	0009a683          	lw	a3,0(s3)
    800009b4:	0016879b          	addiw	a5,a3,1
    800009b8:	41f7d71b          	sraiw	a4,a5,0x1f
    800009bc:	01b7571b          	srliw	a4,a4,0x1b
    800009c0:	9fb9                	addw	a5,a5,a4
    800009c2:	8bfd                	andi	a5,a5,31
    800009c4:	9f99                	subw	a5,a5,a4
    800009c6:	00092703          	lw	a4,0(s2)
    800009ca:	fcf70de3          	beq	a4,a5,800009a4 <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    800009ce:	00011917          	auipc	s2,0x11
    800009d2:	f2a90913          	addi	s2,s2,-214 # 800118f8 <uart_tx_lock>
    800009d6:	96ca                	add	a3,a3,s2
    800009d8:	00968c23          	sb	s1,24(a3)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    800009dc:	00008717          	auipc	a4,0x8
    800009e0:	62f72623          	sw	a5,1580(a4) # 80009008 <uart_tx_w>
      uartstart();
    800009e4:	00000097          	auipc	ra,0x0
    800009e8:	ec2080e7          	jalr	-318(ra) # 800008a6 <uartstart>
      release(&uart_tx_lock);
    800009ec:	854a                	mv	a0,s2
    800009ee:	00000097          	auipc	ra,0x0
    800009f2:	330080e7          	jalr	816(ra) # 80000d1e <release>
}
    800009f6:	70a2                	ld	ra,40(sp)
    800009f8:	7402                	ld	s0,32(sp)
    800009fa:	64e2                	ld	s1,24(sp)
    800009fc:	6942                	ld	s2,16(sp)
    800009fe:	69a2                	ld	s3,8(sp)
    80000a00:	6a02                	ld	s4,0(sp)
    80000a02:	6145                	addi	sp,sp,48
    80000a04:	8082                	ret

0000000080000a06 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000a06:	1141                	addi	sp,sp,-16
    80000a08:	e422                	sd	s0,8(sp)
    80000a0a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000a0c:	100007b7          	lui	a5,0x10000
    80000a10:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a14:	8b85                	andi	a5,a5,1
    80000a16:	cb91                	beqz	a5,80000a2a <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000a18:	100007b7          	lui	a5,0x10000
    80000a1c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000a20:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000a24:	6422                	ld	s0,8(sp)
    80000a26:	0141                	addi	sp,sp,16
    80000a28:	8082                	ret
    return -1;
    80000a2a:	557d                	li	a0,-1
    80000a2c:	bfe5                	j	80000a24 <uartgetc+0x1e>

0000000080000a2e <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000a2e:	1101                	addi	sp,sp,-32
    80000a30:	ec06                	sd	ra,24(sp)
    80000a32:	e822                	sd	s0,16(sp)
    80000a34:	e426                	sd	s1,8(sp)
    80000a36:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a38:	54fd                	li	s1,-1
    80000a3a:	a029                	j	80000a44 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	886080e7          	jalr	-1914(ra) # 800002c2 <consoleintr>
    int c = uartgetc();
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	fc2080e7          	jalr	-62(ra) # 80000a06 <uartgetc>
    if(c == -1)
    80000a4c:	fe9518e3          	bne	a0,s1,80000a3c <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a50:	00011497          	auipc	s1,0x11
    80000a54:	ea848493          	addi	s1,s1,-344 # 800118f8 <uart_tx_lock>
    80000a58:	8526                	mv	a0,s1
    80000a5a:	00000097          	auipc	ra,0x0
    80000a5e:	210080e7          	jalr	528(ra) # 80000c6a <acquire>
  uartstart();
    80000a62:	00000097          	auipc	ra,0x0
    80000a66:	e44080e7          	jalr	-444(ra) # 800008a6 <uartstart>
  release(&uart_tx_lock);
    80000a6a:	8526                	mv	a0,s1
    80000a6c:	00000097          	auipc	ra,0x0
    80000a70:	2b2080e7          	jalr	690(ra) # 80000d1e <release>
}
    80000a74:	60e2                	ld	ra,24(sp)
    80000a76:	6442                	ld	s0,16(sp)
    80000a78:	64a2                	ld	s1,8(sp)
    80000a7a:	6105                	addi	sp,sp,32
    80000a7c:	8082                	ret

0000000080000a7e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a7e:	1101                	addi	sp,sp,-32
    80000a80:	ec06                	sd	ra,24(sp)
    80000a82:	e822                	sd	s0,16(sp)
    80000a84:	e426                	sd	s1,8(sp)
    80000a86:	e04a                	sd	s2,0(sp)
    80000a88:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a8a:	03451793          	slli	a5,a0,0x34
    80000a8e:	ebb9                	bnez	a5,80000ae4 <kfree+0x66>
    80000a90:	84aa                	mv	s1,a0
    80000a92:	00026797          	auipc	a5,0x26
    80000a96:	56e78793          	addi	a5,a5,1390 # 80027000 <end>
    80000a9a:	04f56563          	bltu	a0,a5,80000ae4 <kfree+0x66>
    80000a9e:	47c5                	li	a5,17
    80000aa0:	07ee                	slli	a5,a5,0x1b
    80000aa2:	04f57163          	bgeu	a0,a5,80000ae4 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000aa6:	6605                	lui	a2,0x1
    80000aa8:	4585                	li	a1,1
    80000aaa:	00000097          	auipc	ra,0x0
    80000aae:	2bc080e7          	jalr	700(ra) # 80000d66 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000ab2:	00011917          	auipc	s2,0x11
    80000ab6:	e7e90913          	addi	s2,s2,-386 # 80011930 <kmem>
    80000aba:	854a                	mv	a0,s2
    80000abc:	00000097          	auipc	ra,0x0
    80000ac0:	1ae080e7          	jalr	430(ra) # 80000c6a <acquire>
  r->next = kmem.freelist;
    80000ac4:	01893783          	ld	a5,24(s2)
    80000ac8:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aca:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ace:	854a                	mv	a0,s2
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	24e080e7          	jalr	590(ra) # 80000d1e <release>
}
    80000ad8:	60e2                	ld	ra,24(sp)
    80000ada:	6442                	ld	s0,16(sp)
    80000adc:	64a2                	ld	s1,8(sp)
    80000ade:	6902                	ld	s2,0(sp)
    80000ae0:	6105                	addi	sp,sp,32
    80000ae2:	8082                	ret
    panic("kfree");
    80000ae4:	00007517          	auipc	a0,0x7
    80000ae8:	59450513          	addi	a0,a0,1428 # 80008078 <digits+0x20>
    80000aec:	00000097          	auipc	ra,0x0
    80000af0:	a56080e7          	jalr	-1450(ra) # 80000542 <panic>

0000000080000af4 <freerange>:
{
    80000af4:	7179                	addi	sp,sp,-48
    80000af6:	f406                	sd	ra,40(sp)
    80000af8:	f022                	sd	s0,32(sp)
    80000afa:	ec26                	sd	s1,24(sp)
    80000afc:	e84a                	sd	s2,16(sp)
    80000afe:	e44e                	sd	s3,8(sp)
    80000b00:	e052                	sd	s4,0(sp)
    80000b02:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b04:	6785                	lui	a5,0x1
    80000b06:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000b0a:	94aa                	add	s1,s1,a0
    80000b0c:	757d                	lui	a0,0xfffff
    80000b0e:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b10:	94be                	add	s1,s1,a5
    80000b12:	0095ee63          	bltu	a1,s1,80000b2e <freerange+0x3a>
    80000b16:	892e                	mv	s2,a1
    kfree(p);
    80000b18:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b1a:	6985                	lui	s3,0x1
    kfree(p);
    80000b1c:	01448533          	add	a0,s1,s4
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	f5e080e7          	jalr	-162(ra) # 80000a7e <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b28:	94ce                	add	s1,s1,s3
    80000b2a:	fe9979e3          	bgeu	s2,s1,80000b1c <freerange+0x28>
}
    80000b2e:	70a2                	ld	ra,40(sp)
    80000b30:	7402                	ld	s0,32(sp)
    80000b32:	64e2                	ld	s1,24(sp)
    80000b34:	6942                	ld	s2,16(sp)
    80000b36:	69a2                	ld	s3,8(sp)
    80000b38:	6a02                	ld	s4,0(sp)
    80000b3a:	6145                	addi	sp,sp,48
    80000b3c:	8082                	ret

0000000080000b3e <kinit>:
{
    80000b3e:	1141                	addi	sp,sp,-16
    80000b40:	e406                	sd	ra,8(sp)
    80000b42:	e022                	sd	s0,0(sp)
    80000b44:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b46:	00007597          	auipc	a1,0x7
    80000b4a:	53a58593          	addi	a1,a1,1338 # 80008080 <digits+0x28>
    80000b4e:	00011517          	auipc	a0,0x11
    80000b52:	de250513          	addi	a0,a0,-542 # 80011930 <kmem>
    80000b56:	00000097          	auipc	ra,0x0
    80000b5a:	084080e7          	jalr	132(ra) # 80000bda <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b5e:	45c5                	li	a1,17
    80000b60:	05ee                	slli	a1,a1,0x1b
    80000b62:	00026517          	auipc	a0,0x26
    80000b66:	49e50513          	addi	a0,a0,1182 # 80027000 <end>
    80000b6a:	00000097          	auipc	ra,0x0
    80000b6e:	f8a080e7          	jalr	-118(ra) # 80000af4 <freerange>
}
    80000b72:	60a2                	ld	ra,8(sp)
    80000b74:	6402                	ld	s0,0(sp)
    80000b76:	0141                	addi	sp,sp,16
    80000b78:	8082                	ret

0000000080000b7a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b7a:	1101                	addi	sp,sp,-32
    80000b7c:	ec06                	sd	ra,24(sp)
    80000b7e:	e822                	sd	s0,16(sp)
    80000b80:	e426                	sd	s1,8(sp)
    80000b82:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b84:	00011497          	auipc	s1,0x11
    80000b88:	dac48493          	addi	s1,s1,-596 # 80011930 <kmem>
    80000b8c:	8526                	mv	a0,s1
    80000b8e:	00000097          	auipc	ra,0x0
    80000b92:	0dc080e7          	jalr	220(ra) # 80000c6a <acquire>
  r = kmem.freelist;
    80000b96:	6c84                	ld	s1,24(s1)
  if(r)
    80000b98:	c885                	beqz	s1,80000bc8 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b9a:	609c                	ld	a5,0(s1)
    80000b9c:	00011517          	auipc	a0,0x11
    80000ba0:	d9450513          	addi	a0,a0,-620 # 80011930 <kmem>
    80000ba4:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000ba6:	00000097          	auipc	ra,0x0
    80000baa:	178080e7          	jalr	376(ra) # 80000d1e <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bae:	6605                	lui	a2,0x1
    80000bb0:	4595                	li	a1,5
    80000bb2:	8526                	mv	a0,s1
    80000bb4:	00000097          	auipc	ra,0x0
    80000bb8:	1b2080e7          	jalr	434(ra) # 80000d66 <memset>
  return (void*)r;
}
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	60e2                	ld	ra,24(sp)
    80000bc0:	6442                	ld	s0,16(sp)
    80000bc2:	64a2                	ld	s1,8(sp)
    80000bc4:	6105                	addi	sp,sp,32
    80000bc6:	8082                	ret
  release(&kmem.lock);
    80000bc8:	00011517          	auipc	a0,0x11
    80000bcc:	d6850513          	addi	a0,a0,-664 # 80011930 <kmem>
    80000bd0:	00000097          	auipc	ra,0x0
    80000bd4:	14e080e7          	jalr	334(ra) # 80000d1e <release>
  if(r)
    80000bd8:	b7d5                	j	80000bbc <kalloc+0x42>

0000000080000bda <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bda:	1141                	addi	sp,sp,-16
    80000bdc:	e422                	sd	s0,8(sp)
    80000bde:	0800                	addi	s0,sp,16
  lk->name = name;
    80000be0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000be2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000be6:	00053823          	sd	zero,16(a0)
}
    80000bea:	6422                	ld	s0,8(sp)
    80000bec:	0141                	addi	sp,sp,16
    80000bee:	8082                	ret

0000000080000bf0 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bf0:	411c                	lw	a5,0(a0)
    80000bf2:	e399                	bnez	a5,80000bf8 <holding+0x8>
    80000bf4:	4501                	li	a0,0
  return r;
}
    80000bf6:	8082                	ret
{
    80000bf8:	1101                	addi	sp,sp,-32
    80000bfa:	ec06                	sd	ra,24(sp)
    80000bfc:	e822                	sd	s0,16(sp)
    80000bfe:	e426                	sd	s1,8(sp)
    80000c00:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c02:	6904                	ld	s1,16(a0)
    80000c04:	00001097          	auipc	ra,0x1
    80000c08:	e16080e7          	jalr	-490(ra) # 80001a1a <mycpu>
    80000c0c:	40a48533          	sub	a0,s1,a0
    80000c10:	00153513          	seqz	a0,a0
}
    80000c14:	60e2                	ld	ra,24(sp)
    80000c16:	6442                	ld	s0,16(sp)
    80000c18:	64a2                	ld	s1,8(sp)
    80000c1a:	6105                	addi	sp,sp,32
    80000c1c:	8082                	ret

0000000080000c1e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c1e:	1101                	addi	sp,sp,-32
    80000c20:	ec06                	sd	ra,24(sp)
    80000c22:	e822                	sd	s0,16(sp)
    80000c24:	e426                	sd	s1,8(sp)
    80000c26:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c28:	100024f3          	csrr	s1,sstatus
    80000c2c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c30:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c32:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c36:	00001097          	auipc	ra,0x1
    80000c3a:	de4080e7          	jalr	-540(ra) # 80001a1a <mycpu>
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	cf89                	beqz	a5,80000c5a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c42:	00001097          	auipc	ra,0x1
    80000c46:	dd8080e7          	jalr	-552(ra) # 80001a1a <mycpu>
    80000c4a:	5d3c                	lw	a5,120(a0)
    80000c4c:	2785                	addiw	a5,a5,1
    80000c4e:	dd3c                	sw	a5,120(a0)
}
    80000c50:	60e2                	ld	ra,24(sp)
    80000c52:	6442                	ld	s0,16(sp)
    80000c54:	64a2                	ld	s1,8(sp)
    80000c56:	6105                	addi	sp,sp,32
    80000c58:	8082                	ret
    mycpu()->intena = old;
    80000c5a:	00001097          	auipc	ra,0x1
    80000c5e:	dc0080e7          	jalr	-576(ra) # 80001a1a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c62:	8085                	srli	s1,s1,0x1
    80000c64:	8885                	andi	s1,s1,1
    80000c66:	dd64                	sw	s1,124(a0)
    80000c68:	bfe9                	j	80000c42 <push_off+0x24>

0000000080000c6a <acquire>:
{
    80000c6a:	1101                	addi	sp,sp,-32
    80000c6c:	ec06                	sd	ra,24(sp)
    80000c6e:	e822                	sd	s0,16(sp)
    80000c70:	e426                	sd	s1,8(sp)
    80000c72:	1000                	addi	s0,sp,32
    80000c74:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c76:	00000097          	auipc	ra,0x0
    80000c7a:	fa8080e7          	jalr	-88(ra) # 80000c1e <push_off>
  if(holding(lk))
    80000c7e:	8526                	mv	a0,s1
    80000c80:	00000097          	auipc	ra,0x0
    80000c84:	f70080e7          	jalr	-144(ra) # 80000bf0 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c88:	4705                	li	a4,1
  if(holding(lk))
    80000c8a:	e115                	bnez	a0,80000cae <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c8c:	87ba                	mv	a5,a4
    80000c8e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c92:	2781                	sext.w	a5,a5
    80000c94:	ffe5                	bnez	a5,80000c8c <acquire+0x22>
  __sync_synchronize();
    80000c96:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c9a:	00001097          	auipc	ra,0x1
    80000c9e:	d80080e7          	jalr	-640(ra) # 80001a1a <mycpu>
    80000ca2:	e888                	sd	a0,16(s1)
}
    80000ca4:	60e2                	ld	ra,24(sp)
    80000ca6:	6442                	ld	s0,16(sp)
    80000ca8:	64a2                	ld	s1,8(sp)
    80000caa:	6105                	addi	sp,sp,32
    80000cac:	8082                	ret
    panic("acquire");
    80000cae:	00007517          	auipc	a0,0x7
    80000cb2:	3da50513          	addi	a0,a0,986 # 80008088 <digits+0x30>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	88c080e7          	jalr	-1908(ra) # 80000542 <panic>

0000000080000cbe <pop_off>:

void
pop_off(void)
{
    80000cbe:	1141                	addi	sp,sp,-16
    80000cc0:	e406                	sd	ra,8(sp)
    80000cc2:	e022                	sd	s0,0(sp)
    80000cc4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cc6:	00001097          	auipc	ra,0x1
    80000cca:	d54080e7          	jalr	-684(ra) # 80001a1a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cce:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cd2:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cd4:	e78d                	bnez	a5,80000cfe <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cd6:	5d3c                	lw	a5,120(a0)
    80000cd8:	02f05b63          	blez	a5,80000d0e <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000cdc:	37fd                	addiw	a5,a5,-1
    80000cde:	0007871b          	sext.w	a4,a5
    80000ce2:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000ce4:	eb09                	bnez	a4,80000cf6 <pop_off+0x38>
    80000ce6:	5d7c                	lw	a5,124(a0)
    80000ce8:	c799                	beqz	a5,80000cf6 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cea:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cee:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cf2:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cf6:	60a2                	ld	ra,8(sp)
    80000cf8:	6402                	ld	s0,0(sp)
    80000cfa:	0141                	addi	sp,sp,16
    80000cfc:	8082                	ret
    panic("pop_off - interruptible");
    80000cfe:	00007517          	auipc	a0,0x7
    80000d02:	39250513          	addi	a0,a0,914 # 80008090 <digits+0x38>
    80000d06:	00000097          	auipc	ra,0x0
    80000d0a:	83c080e7          	jalr	-1988(ra) # 80000542 <panic>
    panic("pop_off");
    80000d0e:	00007517          	auipc	a0,0x7
    80000d12:	39a50513          	addi	a0,a0,922 # 800080a8 <digits+0x50>
    80000d16:	00000097          	auipc	ra,0x0
    80000d1a:	82c080e7          	jalr	-2004(ra) # 80000542 <panic>

0000000080000d1e <release>:
{
    80000d1e:	1101                	addi	sp,sp,-32
    80000d20:	ec06                	sd	ra,24(sp)
    80000d22:	e822                	sd	s0,16(sp)
    80000d24:	e426                	sd	s1,8(sp)
    80000d26:	1000                	addi	s0,sp,32
    80000d28:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d2a:	00000097          	auipc	ra,0x0
    80000d2e:	ec6080e7          	jalr	-314(ra) # 80000bf0 <holding>
    80000d32:	c115                	beqz	a0,80000d56 <release+0x38>
  lk->cpu = 0;
    80000d34:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d38:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d3c:	0f50000f          	fence	iorw,ow
    80000d40:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d44:	00000097          	auipc	ra,0x0
    80000d48:	f7a080e7          	jalr	-134(ra) # 80000cbe <pop_off>
}
    80000d4c:	60e2                	ld	ra,24(sp)
    80000d4e:	6442                	ld	s0,16(sp)
    80000d50:	64a2                	ld	s1,8(sp)
    80000d52:	6105                	addi	sp,sp,32
    80000d54:	8082                	ret
    panic("release");
    80000d56:	00007517          	auipc	a0,0x7
    80000d5a:	35a50513          	addi	a0,a0,858 # 800080b0 <digits+0x58>
    80000d5e:	fffff097          	auipc	ra,0xfffff
    80000d62:	7e4080e7          	jalr	2020(ra) # 80000542 <panic>

0000000080000d66 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d66:	1141                	addi	sp,sp,-16
    80000d68:	e422                	sd	s0,8(sp)
    80000d6a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d6c:	ca19                	beqz	a2,80000d82 <memset+0x1c>
    80000d6e:	87aa                	mv	a5,a0
    80000d70:	1602                	slli	a2,a2,0x20
    80000d72:	9201                	srli	a2,a2,0x20
    80000d74:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d78:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d7c:	0785                	addi	a5,a5,1
    80000d7e:	fee79de3          	bne	a5,a4,80000d78 <memset+0x12>
  }
  return dst;
}
    80000d82:	6422                	ld	s0,8(sp)
    80000d84:	0141                	addi	sp,sp,16
    80000d86:	8082                	ret

0000000080000d88 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d88:	1141                	addi	sp,sp,-16
    80000d8a:	e422                	sd	s0,8(sp)
    80000d8c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d8e:	ca05                	beqz	a2,80000dbe <memcmp+0x36>
    80000d90:	fff6069b          	addiw	a3,a2,-1
    80000d94:	1682                	slli	a3,a3,0x20
    80000d96:	9281                	srli	a3,a3,0x20
    80000d98:	0685                	addi	a3,a3,1
    80000d9a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	0005c703          	lbu	a4,0(a1)
    80000da4:	00e79863          	bne	a5,a4,80000db4 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000da8:	0505                	addi	a0,a0,1
    80000daa:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000dac:	fed518e3          	bne	a0,a3,80000d9c <memcmp+0x14>
  }

  return 0;
    80000db0:	4501                	li	a0,0
    80000db2:	a019                	j	80000db8 <memcmp+0x30>
      return *s1 - *s2;
    80000db4:	40e7853b          	subw	a0,a5,a4
}
    80000db8:	6422                	ld	s0,8(sp)
    80000dba:	0141                	addi	sp,sp,16
    80000dbc:	8082                	ret
  return 0;
    80000dbe:	4501                	li	a0,0
    80000dc0:	bfe5                	j	80000db8 <memcmp+0x30>

0000000080000dc2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dc2:	1141                	addi	sp,sp,-16
    80000dc4:	e422                	sd	s0,8(sp)
    80000dc6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dc8:	02a5e563          	bltu	a1,a0,80000df2 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dcc:	fff6069b          	addiw	a3,a2,-1
    80000dd0:	ce11                	beqz	a2,80000dec <memmove+0x2a>
    80000dd2:	1682                	slli	a3,a3,0x20
    80000dd4:	9281                	srli	a3,a3,0x20
    80000dd6:	0685                	addi	a3,a3,1
    80000dd8:	96ae                	add	a3,a3,a1
    80000dda:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000ddc:	0585                	addi	a1,a1,1
    80000dde:	0785                	addi	a5,a5,1
    80000de0:	fff5c703          	lbu	a4,-1(a1)
    80000de4:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000de8:	fed59ae3          	bne	a1,a3,80000ddc <memmove+0x1a>

  return dst;
}
    80000dec:	6422                	ld	s0,8(sp)
    80000dee:	0141                	addi	sp,sp,16
    80000df0:	8082                	ret
  if(s < d && s + n > d){
    80000df2:	02061713          	slli	a4,a2,0x20
    80000df6:	9301                	srli	a4,a4,0x20
    80000df8:	00e587b3          	add	a5,a1,a4
    80000dfc:	fcf578e3          	bgeu	a0,a5,80000dcc <memmove+0xa>
    d += n;
    80000e00:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e02:	fff6069b          	addiw	a3,a2,-1
    80000e06:	d27d                	beqz	a2,80000dec <memmove+0x2a>
    80000e08:	02069613          	slli	a2,a3,0x20
    80000e0c:	9201                	srli	a2,a2,0x20
    80000e0e:	fff64613          	not	a2,a2
    80000e12:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e14:	17fd                	addi	a5,a5,-1
    80000e16:	177d                	addi	a4,a4,-1
    80000e18:	0007c683          	lbu	a3,0(a5)
    80000e1c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e20:	fef61ae3          	bne	a2,a5,80000e14 <memmove+0x52>
    80000e24:	b7e1                	j	80000dec <memmove+0x2a>

0000000080000e26 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e26:	1141                	addi	sp,sp,-16
    80000e28:	e406                	sd	ra,8(sp)
    80000e2a:	e022                	sd	s0,0(sp)
    80000e2c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e2e:	00000097          	auipc	ra,0x0
    80000e32:	f94080e7          	jalr	-108(ra) # 80000dc2 <memmove>
}
    80000e36:	60a2                	ld	ra,8(sp)
    80000e38:	6402                	ld	s0,0(sp)
    80000e3a:	0141                	addi	sp,sp,16
    80000e3c:	8082                	ret

0000000080000e3e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e3e:	1141                	addi	sp,sp,-16
    80000e40:	e422                	sd	s0,8(sp)
    80000e42:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e44:	ce11                	beqz	a2,80000e60 <strncmp+0x22>
    80000e46:	00054783          	lbu	a5,0(a0)
    80000e4a:	cf89                	beqz	a5,80000e64 <strncmp+0x26>
    80000e4c:	0005c703          	lbu	a4,0(a1)
    80000e50:	00f71a63          	bne	a4,a5,80000e64 <strncmp+0x26>
    n--, p++, q++;
    80000e54:	367d                	addiw	a2,a2,-1
    80000e56:	0505                	addi	a0,a0,1
    80000e58:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e5a:	f675                	bnez	a2,80000e46 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e5c:	4501                	li	a0,0
    80000e5e:	a809                	j	80000e70 <strncmp+0x32>
    80000e60:	4501                	li	a0,0
    80000e62:	a039                	j	80000e70 <strncmp+0x32>
  if(n == 0)
    80000e64:	ca09                	beqz	a2,80000e76 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e66:	00054503          	lbu	a0,0(a0)
    80000e6a:	0005c783          	lbu	a5,0(a1)
    80000e6e:	9d1d                	subw	a0,a0,a5
}
    80000e70:	6422                	ld	s0,8(sp)
    80000e72:	0141                	addi	sp,sp,16
    80000e74:	8082                	ret
    return 0;
    80000e76:	4501                	li	a0,0
    80000e78:	bfe5                	j	80000e70 <strncmp+0x32>

0000000080000e7a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e7a:	1141                	addi	sp,sp,-16
    80000e7c:	e422                	sd	s0,8(sp)
    80000e7e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e80:	872a                	mv	a4,a0
    80000e82:	8832                	mv	a6,a2
    80000e84:	367d                	addiw	a2,a2,-1
    80000e86:	01005963          	blez	a6,80000e98 <strncpy+0x1e>
    80000e8a:	0705                	addi	a4,a4,1
    80000e8c:	0005c783          	lbu	a5,0(a1)
    80000e90:	fef70fa3          	sb	a5,-1(a4)
    80000e94:	0585                	addi	a1,a1,1
    80000e96:	f7f5                	bnez	a5,80000e82 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e98:	86ba                	mv	a3,a4
    80000e9a:	00c05c63          	blez	a2,80000eb2 <strncpy+0x38>
    *s++ = 0;
    80000e9e:	0685                	addi	a3,a3,1
    80000ea0:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000ea4:	fff6c793          	not	a5,a3
    80000ea8:	9fb9                	addw	a5,a5,a4
    80000eaa:	010787bb          	addw	a5,a5,a6
    80000eae:	fef048e3          	bgtz	a5,80000e9e <strncpy+0x24>
  return os;
}
    80000eb2:	6422                	ld	s0,8(sp)
    80000eb4:	0141                	addi	sp,sp,16
    80000eb6:	8082                	ret

0000000080000eb8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000eb8:	1141                	addi	sp,sp,-16
    80000eba:	e422                	sd	s0,8(sp)
    80000ebc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ebe:	02c05363          	blez	a2,80000ee4 <safestrcpy+0x2c>
    80000ec2:	fff6069b          	addiw	a3,a2,-1
    80000ec6:	1682                	slli	a3,a3,0x20
    80000ec8:	9281                	srli	a3,a3,0x20
    80000eca:	96ae                	add	a3,a3,a1
    80000ecc:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ece:	00d58963          	beq	a1,a3,80000ee0 <safestrcpy+0x28>
    80000ed2:	0585                	addi	a1,a1,1
    80000ed4:	0785                	addi	a5,a5,1
    80000ed6:	fff5c703          	lbu	a4,-1(a1)
    80000eda:	fee78fa3          	sb	a4,-1(a5)
    80000ede:	fb65                	bnez	a4,80000ece <safestrcpy+0x16>
    ;
  *s = 0;
    80000ee0:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ee4:	6422                	ld	s0,8(sp)
    80000ee6:	0141                	addi	sp,sp,16
    80000ee8:	8082                	ret

0000000080000eea <strlen>:

int
strlen(const char *s)
{
    80000eea:	1141                	addi	sp,sp,-16
    80000eec:	e422                	sd	s0,8(sp)
    80000eee:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ef0:	00054783          	lbu	a5,0(a0)
    80000ef4:	cf91                	beqz	a5,80000f10 <strlen+0x26>
    80000ef6:	0505                	addi	a0,a0,1
    80000ef8:	87aa                	mv	a5,a0
    80000efa:	4685                	li	a3,1
    80000efc:	9e89                	subw	a3,a3,a0
    80000efe:	00f6853b          	addw	a0,a3,a5
    80000f02:	0785                	addi	a5,a5,1
    80000f04:	fff7c703          	lbu	a4,-1(a5)
    80000f08:	fb7d                	bnez	a4,80000efe <strlen+0x14>
    ;
  return n;
}
    80000f0a:	6422                	ld	s0,8(sp)
    80000f0c:	0141                	addi	sp,sp,16
    80000f0e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f10:	4501                	li	a0,0
    80000f12:	bfe5                	j	80000f0a <strlen+0x20>

0000000080000f14 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e406                	sd	ra,8(sp)
    80000f18:	e022                	sd	s0,0(sp)
    80000f1a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f1c:	00001097          	auipc	ra,0x1
    80000f20:	aee080e7          	jalr	-1298(ra) # 80001a0a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f24:	00008717          	auipc	a4,0x8
    80000f28:	0e870713          	addi	a4,a4,232 # 8000900c <started>
  if(cpuid() == 0){
    80000f2c:	c139                	beqz	a0,80000f72 <main+0x5e>
    while(started == 0)
    80000f2e:	431c                	lw	a5,0(a4)
    80000f30:	2781                	sext.w	a5,a5
    80000f32:	dff5                	beqz	a5,80000f2e <main+0x1a>
      ;
    __sync_synchronize();
    80000f34:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	ad2080e7          	jalr	-1326(ra) # 80001a0a <cpuid>
    80000f40:	85aa                	mv	a1,a0
    80000f42:	00007517          	auipc	a0,0x7
    80000f46:	18e50513          	addi	a0,a0,398 # 800080d0 <digits+0x78>
    80000f4a:	fffff097          	auipc	ra,0xfffff
    80000f4e:	642080e7          	jalr	1602(ra) # 8000058c <printf>
    kvminithart();    // turn on paging
    80000f52:	00000097          	auipc	ra,0x0
    80000f56:	0d8080e7          	jalr	216(ra) # 8000102a <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f5a:	00001097          	auipc	ra,0x1
    80000f5e:	762080e7          	jalr	1890(ra) # 800026bc <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	e7e080e7          	jalr	-386(ra) # 80005de0 <plicinithart>
  }

  scheduler();        
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	030080e7          	jalr	48(ra) # 80001f9a <scheduler>
    consoleinit();
    80000f72:	fffff097          	auipc	ra,0xfffff
    80000f76:	4e2080e7          	jalr	1250(ra) # 80000454 <consoleinit>
    printfinit();
    80000f7a:	00000097          	auipc	ra,0x0
    80000f7e:	85e080e7          	jalr	-1954(ra) # 800007d8 <printfinit>
    printf("\n");
    80000f82:	00007517          	auipc	a0,0x7
    80000f86:	15e50513          	addi	a0,a0,350 # 800080e0 <digits+0x88>
    80000f8a:	fffff097          	auipc	ra,0xfffff
    80000f8e:	602080e7          	jalr	1538(ra) # 8000058c <printf>
    printf("xv6 kernel is booting\n");
    80000f92:	00007517          	auipc	a0,0x7
    80000f96:	12650513          	addi	a0,a0,294 # 800080b8 <digits+0x60>
    80000f9a:	fffff097          	auipc	ra,0xfffff
    80000f9e:	5f2080e7          	jalr	1522(ra) # 8000058c <printf>
    printf("\n");
    80000fa2:	00007517          	auipc	a0,0x7
    80000fa6:	13e50513          	addi	a0,a0,318 # 800080e0 <digits+0x88>
    80000faa:	fffff097          	auipc	ra,0xfffff
    80000fae:	5e2080e7          	jalr	1506(ra) # 8000058c <printf>
    kinit();         // physical page allocator
    80000fb2:	00000097          	auipc	ra,0x0
    80000fb6:	b8c080e7          	jalr	-1140(ra) # 80000b3e <kinit>
    kvminit();       // create kernel page table
    80000fba:	00000097          	auipc	ra,0x0
    80000fbe:	2a0080e7          	jalr	672(ra) # 8000125a <kvminit>
    kvminithart();   // turn on paging
    80000fc2:	00000097          	auipc	ra,0x0
    80000fc6:	068080e7          	jalr	104(ra) # 8000102a <kvminithart>
    procinit();      // process table
    80000fca:	00001097          	auipc	ra,0x1
    80000fce:	970080e7          	jalr	-1680(ra) # 8000193a <procinit>
    trapinit();      // trap vectors
    80000fd2:	00001097          	auipc	ra,0x1
    80000fd6:	6c2080e7          	jalr	1730(ra) # 80002694 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fda:	00001097          	auipc	ra,0x1
    80000fde:	6e2080e7          	jalr	1762(ra) # 800026bc <trapinithart>
    plicinit();      // set up interrupt controller
    80000fe2:	00005097          	auipc	ra,0x5
    80000fe6:	de8080e7          	jalr	-536(ra) # 80005dca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fea:	00005097          	auipc	ra,0x5
    80000fee:	df6080e7          	jalr	-522(ra) # 80005de0 <plicinithart>
    binit();         // buffer cache
    80000ff2:	00002097          	auipc	ra,0x2
    80000ff6:	f9e080e7          	jalr	-98(ra) # 80002f90 <binit>
    iinit();         // inode cache
    80000ffa:	00002097          	auipc	ra,0x2
    80000ffe:	62e080e7          	jalr	1582(ra) # 80003628 <iinit>
    fileinit();      // file table
    80001002:	00003097          	auipc	ra,0x3
    80001006:	5c8080e7          	jalr	1480(ra) # 800045ca <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000100a:	00005097          	auipc	ra,0x5
    8000100e:	ede080e7          	jalr	-290(ra) # 80005ee8 <virtio_disk_init>
    userinit();      // first user process
    80001012:	00001097          	auipc	ra,0x1
    80001016:	d1e080e7          	jalr	-738(ra) # 80001d30 <userinit>
    __sync_synchronize();
    8000101a:	0ff0000f          	fence
    started = 1;
    8000101e:	4785                	li	a5,1
    80001020:	00008717          	auipc	a4,0x8
    80001024:	fef72623          	sw	a5,-20(a4) # 8000900c <started>
    80001028:	b789                	j	80000f6a <main+0x56>

000000008000102a <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000102a:	1141                	addi	sp,sp,-16
    8000102c:	e422                	sd	s0,8(sp)
    8000102e:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001030:	00008797          	auipc	a5,0x8
    80001034:	fe07b783          	ld	a5,-32(a5) # 80009010 <kernel_pagetable>
    80001038:	83b1                	srli	a5,a5,0xc
    8000103a:	577d                	li	a4,-1
    8000103c:	177e                	slli	a4,a4,0x3f
    8000103e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001040:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001044:	12000073          	sfence.vma
  sfence_vma();
}
    80001048:	6422                	ld	s0,8(sp)
    8000104a:	0141                	addi	sp,sp,16
    8000104c:	8082                	ret

000000008000104e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000104e:	7139                	addi	sp,sp,-64
    80001050:	fc06                	sd	ra,56(sp)
    80001052:	f822                	sd	s0,48(sp)
    80001054:	f426                	sd	s1,40(sp)
    80001056:	f04a                	sd	s2,32(sp)
    80001058:	ec4e                	sd	s3,24(sp)
    8000105a:	e852                	sd	s4,16(sp)
    8000105c:	e456                	sd	s5,8(sp)
    8000105e:	e05a                	sd	s6,0(sp)
    80001060:	0080                	addi	s0,sp,64
    80001062:	84aa                	mv	s1,a0
    80001064:	89ae                	mv	s3,a1
    80001066:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001068:	57fd                	li	a5,-1
    8000106a:	83e9                	srli	a5,a5,0x1a
    8000106c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000106e:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001070:	04b7f263          	bgeu	a5,a1,800010b4 <walk+0x66>
    panic("walk");
    80001074:	00007517          	auipc	a0,0x7
    80001078:	07450513          	addi	a0,a0,116 # 800080e8 <digits+0x90>
    8000107c:	fffff097          	auipc	ra,0xfffff
    80001080:	4c6080e7          	jalr	1222(ra) # 80000542 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001084:	060a8663          	beqz	s5,800010f0 <walk+0xa2>
    80001088:	00000097          	auipc	ra,0x0
    8000108c:	af2080e7          	jalr	-1294(ra) # 80000b7a <kalloc>
    80001090:	84aa                	mv	s1,a0
    80001092:	c529                	beqz	a0,800010dc <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001094:	6605                	lui	a2,0x1
    80001096:	4581                	li	a1,0
    80001098:	00000097          	auipc	ra,0x0
    8000109c:	cce080e7          	jalr	-818(ra) # 80000d66 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010a0:	00c4d793          	srli	a5,s1,0xc
    800010a4:	07aa                	slli	a5,a5,0xa
    800010a6:	0017e793          	ori	a5,a5,1
    800010aa:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010ae:	3a5d                	addiw	s4,s4,-9
    800010b0:	036a0063          	beq	s4,s6,800010d0 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010b4:	0149d933          	srl	s2,s3,s4
    800010b8:	1ff97913          	andi	s2,s2,511
    800010bc:	090e                	slli	s2,s2,0x3
    800010be:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010c0:	00093483          	ld	s1,0(s2)
    800010c4:	0014f793          	andi	a5,s1,1
    800010c8:	dfd5                	beqz	a5,80001084 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010ca:	80a9                	srli	s1,s1,0xa
    800010cc:	04b2                	slli	s1,s1,0xc
    800010ce:	b7c5                	j	800010ae <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010d0:	00c9d513          	srli	a0,s3,0xc
    800010d4:	1ff57513          	andi	a0,a0,511
    800010d8:	050e                	slli	a0,a0,0x3
    800010da:	9526                	add	a0,a0,s1
}
    800010dc:	70e2                	ld	ra,56(sp)
    800010de:	7442                	ld	s0,48(sp)
    800010e0:	74a2                	ld	s1,40(sp)
    800010e2:	7902                	ld	s2,32(sp)
    800010e4:	69e2                	ld	s3,24(sp)
    800010e6:	6a42                	ld	s4,16(sp)
    800010e8:	6aa2                	ld	s5,8(sp)
    800010ea:	6b02                	ld	s6,0(sp)
    800010ec:	6121                	addi	sp,sp,64
    800010ee:	8082                	ret
        return 0;
    800010f0:	4501                	li	a0,0
    800010f2:	b7ed                	j	800010dc <walk+0x8e>

00000000800010f4 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010f4:	57fd                	li	a5,-1
    800010f6:	83e9                	srli	a5,a5,0x1a
    800010f8:	00b7f463          	bgeu	a5,a1,80001100 <walkaddr+0xc>
    return 0;
    800010fc:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010fe:	8082                	ret
{
    80001100:	1141                	addi	sp,sp,-16
    80001102:	e406                	sd	ra,8(sp)
    80001104:	e022                	sd	s0,0(sp)
    80001106:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001108:	4601                	li	a2,0
    8000110a:	00000097          	auipc	ra,0x0
    8000110e:	f44080e7          	jalr	-188(ra) # 8000104e <walk>
  if(pte == 0)
    80001112:	c105                	beqz	a0,80001132 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001114:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001116:	0117f693          	andi	a3,a5,17
    8000111a:	4745                	li	a4,17
    return 0;
    8000111c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000111e:	00e68663          	beq	a3,a4,8000112a <walkaddr+0x36>
}
    80001122:	60a2                	ld	ra,8(sp)
    80001124:	6402                	ld	s0,0(sp)
    80001126:	0141                	addi	sp,sp,16
    80001128:	8082                	ret
  pa = PTE2PA(*pte);
    8000112a:	00a7d513          	srli	a0,a5,0xa
    8000112e:	0532                	slli	a0,a0,0xc
  return pa;
    80001130:	bfcd                	j	80001122 <walkaddr+0x2e>
    return 0;
    80001132:	4501                	li	a0,0
    80001134:	b7fd                	j	80001122 <walkaddr+0x2e>

0000000080001136 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    80001136:	1101                	addi	sp,sp,-32
    80001138:	ec06                	sd	ra,24(sp)
    8000113a:	e822                	sd	s0,16(sp)
    8000113c:	e426                	sd	s1,8(sp)
    8000113e:	1000                	addi	s0,sp,32
    80001140:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001142:	1552                	slli	a0,a0,0x34
    80001144:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    80001148:	4601                	li	a2,0
    8000114a:	00008517          	auipc	a0,0x8
    8000114e:	ec653503          	ld	a0,-314(a0) # 80009010 <kernel_pagetable>
    80001152:	00000097          	auipc	ra,0x0
    80001156:	efc080e7          	jalr	-260(ra) # 8000104e <walk>
  if(pte == 0)
    8000115a:	cd09                	beqz	a0,80001174 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    8000115c:	6108                	ld	a0,0(a0)
    8000115e:	00157793          	andi	a5,a0,1
    80001162:	c38d                	beqz	a5,80001184 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001164:	8129                	srli	a0,a0,0xa
    80001166:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001168:	9526                	add	a0,a0,s1
    8000116a:	60e2                	ld	ra,24(sp)
    8000116c:	6442                	ld	s0,16(sp)
    8000116e:	64a2                	ld	s1,8(sp)
    80001170:	6105                	addi	sp,sp,32
    80001172:	8082                	ret
    panic("kvmpa");
    80001174:	00007517          	auipc	a0,0x7
    80001178:	f7c50513          	addi	a0,a0,-132 # 800080f0 <digits+0x98>
    8000117c:	fffff097          	auipc	ra,0xfffff
    80001180:	3c6080e7          	jalr	966(ra) # 80000542 <panic>
    panic("kvmpa");
    80001184:	00007517          	auipc	a0,0x7
    80001188:	f6c50513          	addi	a0,a0,-148 # 800080f0 <digits+0x98>
    8000118c:	fffff097          	auipc	ra,0xfffff
    80001190:	3b6080e7          	jalr	950(ra) # 80000542 <panic>

0000000080001194 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001194:	715d                	addi	sp,sp,-80
    80001196:	e486                	sd	ra,72(sp)
    80001198:	e0a2                	sd	s0,64(sp)
    8000119a:	fc26                	sd	s1,56(sp)
    8000119c:	f84a                	sd	s2,48(sp)
    8000119e:	f44e                	sd	s3,40(sp)
    800011a0:	f052                	sd	s4,32(sp)
    800011a2:	ec56                	sd	s5,24(sp)
    800011a4:	e85a                	sd	s6,16(sp)
    800011a6:	e45e                	sd	s7,8(sp)
    800011a8:	0880                	addi	s0,sp,80
    800011aa:	8aaa                	mv	s5,a0
    800011ac:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800011ae:	777d                	lui	a4,0xfffff
    800011b0:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800011b4:	167d                	addi	a2,a2,-1
    800011b6:	00b609b3          	add	s3,a2,a1
    800011ba:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800011be:	893e                	mv	s2,a5
    800011c0:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011c4:	6b85                	lui	s7,0x1
    800011c6:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011ca:	4605                	li	a2,1
    800011cc:	85ca                	mv	a1,s2
    800011ce:	8556                	mv	a0,s5
    800011d0:	00000097          	auipc	ra,0x0
    800011d4:	e7e080e7          	jalr	-386(ra) # 8000104e <walk>
    800011d8:	c51d                	beqz	a0,80001206 <mappages+0x72>
    if(*pte & PTE_V)
    800011da:	611c                	ld	a5,0(a0)
    800011dc:	8b85                	andi	a5,a5,1
    800011de:	ef81                	bnez	a5,800011f6 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011e0:	80b1                	srli	s1,s1,0xc
    800011e2:	04aa                	slli	s1,s1,0xa
    800011e4:	0164e4b3          	or	s1,s1,s6
    800011e8:	0014e493          	ori	s1,s1,1
    800011ec:	e104                	sd	s1,0(a0)
    if(a == last)
    800011ee:	03390863          	beq	s2,s3,8000121e <mappages+0x8a>
    a += PGSIZE;
    800011f2:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800011f4:	bfc9                	j	800011c6 <mappages+0x32>
      panic("remap");
    800011f6:	00007517          	auipc	a0,0x7
    800011fa:	f0250513          	addi	a0,a0,-254 # 800080f8 <digits+0xa0>
    800011fe:	fffff097          	auipc	ra,0xfffff
    80001202:	344080e7          	jalr	836(ra) # 80000542 <panic>
      return -1;
    80001206:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001208:	60a6                	ld	ra,72(sp)
    8000120a:	6406                	ld	s0,64(sp)
    8000120c:	74e2                	ld	s1,56(sp)
    8000120e:	7942                	ld	s2,48(sp)
    80001210:	79a2                	ld	s3,40(sp)
    80001212:	7a02                	ld	s4,32(sp)
    80001214:	6ae2                	ld	s5,24(sp)
    80001216:	6b42                	ld	s6,16(sp)
    80001218:	6ba2                	ld	s7,8(sp)
    8000121a:	6161                	addi	sp,sp,80
    8000121c:	8082                	ret
  return 0;
    8000121e:	4501                	li	a0,0
    80001220:	b7e5                	j	80001208 <mappages+0x74>

0000000080001222 <kvmmap>:
{
    80001222:	1141                	addi	sp,sp,-16
    80001224:	e406                	sd	ra,8(sp)
    80001226:	e022                	sd	s0,0(sp)
    80001228:	0800                	addi	s0,sp,16
    8000122a:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000122c:	86ae                	mv	a3,a1
    8000122e:	85aa                	mv	a1,a0
    80001230:	00008517          	auipc	a0,0x8
    80001234:	de053503          	ld	a0,-544(a0) # 80009010 <kernel_pagetable>
    80001238:	00000097          	auipc	ra,0x0
    8000123c:	f5c080e7          	jalr	-164(ra) # 80001194 <mappages>
    80001240:	e509                	bnez	a0,8000124a <kvmmap+0x28>
}
    80001242:	60a2                	ld	ra,8(sp)
    80001244:	6402                	ld	s0,0(sp)
    80001246:	0141                	addi	sp,sp,16
    80001248:	8082                	ret
    panic("kvmmap");
    8000124a:	00007517          	auipc	a0,0x7
    8000124e:	eb650513          	addi	a0,a0,-330 # 80008100 <digits+0xa8>
    80001252:	fffff097          	auipc	ra,0xfffff
    80001256:	2f0080e7          	jalr	752(ra) # 80000542 <panic>

000000008000125a <kvminit>:
{
    8000125a:	1101                	addi	sp,sp,-32
    8000125c:	ec06                	sd	ra,24(sp)
    8000125e:	e822                	sd	s0,16(sp)
    80001260:	e426                	sd	s1,8(sp)
    80001262:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001264:	00000097          	auipc	ra,0x0
    80001268:	916080e7          	jalr	-1770(ra) # 80000b7a <kalloc>
    8000126c:	00008797          	auipc	a5,0x8
    80001270:	daa7b223          	sd	a0,-604(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001274:	6605                	lui	a2,0x1
    80001276:	4581                	li	a1,0
    80001278:	00000097          	auipc	ra,0x0
    8000127c:	aee080e7          	jalr	-1298(ra) # 80000d66 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001280:	4699                	li	a3,6
    80001282:	6605                	lui	a2,0x1
    80001284:	100005b7          	lui	a1,0x10000
    80001288:	10000537          	lui	a0,0x10000
    8000128c:	00000097          	auipc	ra,0x0
    80001290:	f96080e7          	jalr	-106(ra) # 80001222 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001294:	4699                	li	a3,6
    80001296:	6605                	lui	a2,0x1
    80001298:	100015b7          	lui	a1,0x10001
    8000129c:	10001537          	lui	a0,0x10001
    800012a0:	00000097          	auipc	ra,0x0
    800012a4:	f82080e7          	jalr	-126(ra) # 80001222 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    800012a8:	4699                	li	a3,6
    800012aa:	6641                	lui	a2,0x10
    800012ac:	020005b7          	lui	a1,0x2000
    800012b0:	02000537          	lui	a0,0x2000
    800012b4:	00000097          	auipc	ra,0x0
    800012b8:	f6e080e7          	jalr	-146(ra) # 80001222 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012bc:	4699                	li	a3,6
    800012be:	00400637          	lui	a2,0x400
    800012c2:	0c0005b7          	lui	a1,0xc000
    800012c6:	0c000537          	lui	a0,0xc000
    800012ca:	00000097          	auipc	ra,0x0
    800012ce:	f58080e7          	jalr	-168(ra) # 80001222 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012d2:	00007497          	auipc	s1,0x7
    800012d6:	d2e48493          	addi	s1,s1,-722 # 80008000 <etext>
    800012da:	46a9                	li	a3,10
    800012dc:	80007617          	auipc	a2,0x80007
    800012e0:	d2460613          	addi	a2,a2,-732 # 8000 <_entry-0x7fff8000>
    800012e4:	4585                	li	a1,1
    800012e6:	05fe                	slli	a1,a1,0x1f
    800012e8:	852e                	mv	a0,a1
    800012ea:	00000097          	auipc	ra,0x0
    800012ee:	f38080e7          	jalr	-200(ra) # 80001222 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012f2:	4699                	li	a3,6
    800012f4:	4645                	li	a2,17
    800012f6:	066e                	slli	a2,a2,0x1b
    800012f8:	8e05                	sub	a2,a2,s1
    800012fa:	85a6                	mv	a1,s1
    800012fc:	8526                	mv	a0,s1
    800012fe:	00000097          	auipc	ra,0x0
    80001302:	f24080e7          	jalr	-220(ra) # 80001222 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001306:	46a9                	li	a3,10
    80001308:	6605                	lui	a2,0x1
    8000130a:	00006597          	auipc	a1,0x6
    8000130e:	cf658593          	addi	a1,a1,-778 # 80007000 <_trampoline>
    80001312:	04000537          	lui	a0,0x4000
    80001316:	157d                	addi	a0,a0,-1
    80001318:	0532                	slli	a0,a0,0xc
    8000131a:	00000097          	auipc	ra,0x0
    8000131e:	f08080e7          	jalr	-248(ra) # 80001222 <kvmmap>
}
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret

000000008000132c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000132c:	715d                	addi	sp,sp,-80
    8000132e:	e486                	sd	ra,72(sp)
    80001330:	e0a2                	sd	s0,64(sp)
    80001332:	fc26                	sd	s1,56(sp)
    80001334:	f84a                	sd	s2,48(sp)
    80001336:	f44e                	sd	s3,40(sp)
    80001338:	f052                	sd	s4,32(sp)
    8000133a:	ec56                	sd	s5,24(sp)
    8000133c:	e85a                	sd	s6,16(sp)
    8000133e:	e45e                	sd	s7,8(sp)
    80001340:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001342:	03459793          	slli	a5,a1,0x34
    80001346:	e795                	bnez	a5,80001372 <uvmunmap+0x46>
    80001348:	8a2a                	mv	s4,a0
    8000134a:	892e                	mv	s2,a1
    8000134c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000134e:	0632                	slli	a2,a2,0xc
    80001350:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001354:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001356:	6b05                	lui	s6,0x1
    80001358:	0735e263          	bltu	a1,s3,800013bc <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000135c:	60a6                	ld	ra,72(sp)
    8000135e:	6406                	ld	s0,64(sp)
    80001360:	74e2                	ld	s1,56(sp)
    80001362:	7942                	ld	s2,48(sp)
    80001364:	79a2                	ld	s3,40(sp)
    80001366:	7a02                	ld	s4,32(sp)
    80001368:	6ae2                	ld	s5,24(sp)
    8000136a:	6b42                	ld	s6,16(sp)
    8000136c:	6ba2                	ld	s7,8(sp)
    8000136e:	6161                	addi	sp,sp,80
    80001370:	8082                	ret
    panic("uvmunmap: not aligned");
    80001372:	00007517          	auipc	a0,0x7
    80001376:	d9650513          	addi	a0,a0,-618 # 80008108 <digits+0xb0>
    8000137a:	fffff097          	auipc	ra,0xfffff
    8000137e:	1c8080e7          	jalr	456(ra) # 80000542 <panic>
      panic("uvmunmap: walk");
    80001382:	00007517          	auipc	a0,0x7
    80001386:	d9e50513          	addi	a0,a0,-610 # 80008120 <digits+0xc8>
    8000138a:	fffff097          	auipc	ra,0xfffff
    8000138e:	1b8080e7          	jalr	440(ra) # 80000542 <panic>
      panic("uvmunmap: not mapped");
    80001392:	00007517          	auipc	a0,0x7
    80001396:	d9e50513          	addi	a0,a0,-610 # 80008130 <digits+0xd8>
    8000139a:	fffff097          	auipc	ra,0xfffff
    8000139e:	1a8080e7          	jalr	424(ra) # 80000542 <panic>
      panic("uvmunmap: not a leaf");
    800013a2:	00007517          	auipc	a0,0x7
    800013a6:	da650513          	addi	a0,a0,-602 # 80008148 <digits+0xf0>
    800013aa:	fffff097          	auipc	ra,0xfffff
    800013ae:	198080e7          	jalr	408(ra) # 80000542 <panic>
    *pte = 0;
    800013b2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013b6:	995a                	add	s2,s2,s6
    800013b8:	fb3972e3          	bgeu	s2,s3,8000135c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013bc:	4601                	li	a2,0
    800013be:	85ca                	mv	a1,s2
    800013c0:	8552                	mv	a0,s4
    800013c2:	00000097          	auipc	ra,0x0
    800013c6:	c8c080e7          	jalr	-884(ra) # 8000104e <walk>
    800013ca:	84aa                	mv	s1,a0
    800013cc:	d95d                	beqz	a0,80001382 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013ce:	6108                	ld	a0,0(a0)
    800013d0:	00157793          	andi	a5,a0,1
    800013d4:	dfdd                	beqz	a5,80001392 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013d6:	3ff57793          	andi	a5,a0,1023
    800013da:	fd7784e3          	beq	a5,s7,800013a2 <uvmunmap+0x76>
    if(do_free){
    800013de:	fc0a8ae3          	beqz	s5,800013b2 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800013e2:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013e4:	0532                	slli	a0,a0,0xc
    800013e6:	fffff097          	auipc	ra,0xfffff
    800013ea:	698080e7          	jalr	1688(ra) # 80000a7e <kfree>
    800013ee:	b7d1                	j	800013b2 <uvmunmap+0x86>

00000000800013f0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013f0:	1101                	addi	sp,sp,-32
    800013f2:	ec06                	sd	ra,24(sp)
    800013f4:	e822                	sd	s0,16(sp)
    800013f6:	e426                	sd	s1,8(sp)
    800013f8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013fa:	fffff097          	auipc	ra,0xfffff
    800013fe:	780080e7          	jalr	1920(ra) # 80000b7a <kalloc>
    80001402:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001404:	c519                	beqz	a0,80001412 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001406:	6605                	lui	a2,0x1
    80001408:	4581                	li	a1,0
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	95c080e7          	jalr	-1700(ra) # 80000d66 <memset>
  return pagetable;
}
    80001412:	8526                	mv	a0,s1
    80001414:	60e2                	ld	ra,24(sp)
    80001416:	6442                	ld	s0,16(sp)
    80001418:	64a2                	ld	s1,8(sp)
    8000141a:	6105                	addi	sp,sp,32
    8000141c:	8082                	ret

000000008000141e <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000141e:	7179                	addi	sp,sp,-48
    80001420:	f406                	sd	ra,40(sp)
    80001422:	f022                	sd	s0,32(sp)
    80001424:	ec26                	sd	s1,24(sp)
    80001426:	e84a                	sd	s2,16(sp)
    80001428:	e44e                	sd	s3,8(sp)
    8000142a:	e052                	sd	s4,0(sp)
    8000142c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000142e:	6785                	lui	a5,0x1
    80001430:	04f67863          	bgeu	a2,a5,80001480 <uvminit+0x62>
    80001434:	8a2a                	mv	s4,a0
    80001436:	89ae                	mv	s3,a1
    80001438:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000143a:	fffff097          	auipc	ra,0xfffff
    8000143e:	740080e7          	jalr	1856(ra) # 80000b7a <kalloc>
    80001442:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001444:	6605                	lui	a2,0x1
    80001446:	4581                	li	a1,0
    80001448:	00000097          	auipc	ra,0x0
    8000144c:	91e080e7          	jalr	-1762(ra) # 80000d66 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001450:	4779                	li	a4,30
    80001452:	86ca                	mv	a3,s2
    80001454:	6605                	lui	a2,0x1
    80001456:	4581                	li	a1,0
    80001458:	8552                	mv	a0,s4
    8000145a:	00000097          	auipc	ra,0x0
    8000145e:	d3a080e7          	jalr	-710(ra) # 80001194 <mappages>
  memmove(mem, src, sz);
    80001462:	8626                	mv	a2,s1
    80001464:	85ce                	mv	a1,s3
    80001466:	854a                	mv	a0,s2
    80001468:	00000097          	auipc	ra,0x0
    8000146c:	95a080e7          	jalr	-1702(ra) # 80000dc2 <memmove>
}
    80001470:	70a2                	ld	ra,40(sp)
    80001472:	7402                	ld	s0,32(sp)
    80001474:	64e2                	ld	s1,24(sp)
    80001476:	6942                	ld	s2,16(sp)
    80001478:	69a2                	ld	s3,8(sp)
    8000147a:	6a02                	ld	s4,0(sp)
    8000147c:	6145                	addi	sp,sp,48
    8000147e:	8082                	ret
    panic("inituvm: more than a page");
    80001480:	00007517          	auipc	a0,0x7
    80001484:	ce050513          	addi	a0,a0,-800 # 80008160 <digits+0x108>
    80001488:	fffff097          	auipc	ra,0xfffff
    8000148c:	0ba080e7          	jalr	186(ra) # 80000542 <panic>

0000000080001490 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001490:	1101                	addi	sp,sp,-32
    80001492:	ec06                	sd	ra,24(sp)
    80001494:	e822                	sd	s0,16(sp)
    80001496:	e426                	sd	s1,8(sp)
    80001498:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000149a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000149c:	00b67d63          	bgeu	a2,a1,800014b6 <uvmdealloc+0x26>
    800014a0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014a2:	6785                	lui	a5,0x1
    800014a4:	17fd                	addi	a5,a5,-1
    800014a6:	00f60733          	add	a4,a2,a5
    800014aa:	767d                	lui	a2,0xfffff
    800014ac:	8f71                	and	a4,a4,a2
    800014ae:	97ae                	add	a5,a5,a1
    800014b0:	8ff1                	and	a5,a5,a2
    800014b2:	00f76863          	bltu	a4,a5,800014c2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014b6:	8526                	mv	a0,s1
    800014b8:	60e2                	ld	ra,24(sp)
    800014ba:	6442                	ld	s0,16(sp)
    800014bc:	64a2                	ld	s1,8(sp)
    800014be:	6105                	addi	sp,sp,32
    800014c0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014c2:	8f99                	sub	a5,a5,a4
    800014c4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014c6:	4685                	li	a3,1
    800014c8:	0007861b          	sext.w	a2,a5
    800014cc:	85ba                	mv	a1,a4
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	e5e080e7          	jalr	-418(ra) # 8000132c <uvmunmap>
    800014d6:	b7c5                	j	800014b6 <uvmdealloc+0x26>

00000000800014d8 <uvmalloc>:
  if(newsz < oldsz)
    800014d8:	0ab66163          	bltu	a2,a1,8000157a <uvmalloc+0xa2>
{
    800014dc:	7139                	addi	sp,sp,-64
    800014de:	fc06                	sd	ra,56(sp)
    800014e0:	f822                	sd	s0,48(sp)
    800014e2:	f426                	sd	s1,40(sp)
    800014e4:	f04a                	sd	s2,32(sp)
    800014e6:	ec4e                	sd	s3,24(sp)
    800014e8:	e852                	sd	s4,16(sp)
    800014ea:	e456                	sd	s5,8(sp)
    800014ec:	0080                	addi	s0,sp,64
    800014ee:	8aaa                	mv	s5,a0
    800014f0:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014f2:	6985                	lui	s3,0x1
    800014f4:	19fd                	addi	s3,s3,-1
    800014f6:	95ce                	add	a1,a1,s3
    800014f8:	79fd                	lui	s3,0xfffff
    800014fa:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014fe:	08c9f063          	bgeu	s3,a2,8000157e <uvmalloc+0xa6>
    80001502:	894e                	mv	s2,s3
    mem = kalloc();
    80001504:	fffff097          	auipc	ra,0xfffff
    80001508:	676080e7          	jalr	1654(ra) # 80000b7a <kalloc>
    8000150c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000150e:	c51d                	beqz	a0,8000153c <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001510:	6605                	lui	a2,0x1
    80001512:	4581                	li	a1,0
    80001514:	00000097          	auipc	ra,0x0
    80001518:	852080e7          	jalr	-1966(ra) # 80000d66 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000151c:	4779                	li	a4,30
    8000151e:	86a6                	mv	a3,s1
    80001520:	6605                	lui	a2,0x1
    80001522:	85ca                	mv	a1,s2
    80001524:	8556                	mv	a0,s5
    80001526:	00000097          	auipc	ra,0x0
    8000152a:	c6e080e7          	jalr	-914(ra) # 80001194 <mappages>
    8000152e:	e905                	bnez	a0,8000155e <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001530:	6785                	lui	a5,0x1
    80001532:	993e                	add	s2,s2,a5
    80001534:	fd4968e3          	bltu	s2,s4,80001504 <uvmalloc+0x2c>
  return newsz;
    80001538:	8552                	mv	a0,s4
    8000153a:	a809                	j	8000154c <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000153c:	864e                	mv	a2,s3
    8000153e:	85ca                	mv	a1,s2
    80001540:	8556                	mv	a0,s5
    80001542:	00000097          	auipc	ra,0x0
    80001546:	f4e080e7          	jalr	-178(ra) # 80001490 <uvmdealloc>
      return 0;
    8000154a:	4501                	li	a0,0
}
    8000154c:	70e2                	ld	ra,56(sp)
    8000154e:	7442                	ld	s0,48(sp)
    80001550:	74a2                	ld	s1,40(sp)
    80001552:	7902                	ld	s2,32(sp)
    80001554:	69e2                	ld	s3,24(sp)
    80001556:	6a42                	ld	s4,16(sp)
    80001558:	6aa2                	ld	s5,8(sp)
    8000155a:	6121                	addi	sp,sp,64
    8000155c:	8082                	ret
      kfree(mem);
    8000155e:	8526                	mv	a0,s1
    80001560:	fffff097          	auipc	ra,0xfffff
    80001564:	51e080e7          	jalr	1310(ra) # 80000a7e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001568:	864e                	mv	a2,s3
    8000156a:	85ca                	mv	a1,s2
    8000156c:	8556                	mv	a0,s5
    8000156e:	00000097          	auipc	ra,0x0
    80001572:	f22080e7          	jalr	-222(ra) # 80001490 <uvmdealloc>
      return 0;
    80001576:	4501                	li	a0,0
    80001578:	bfd1                	j	8000154c <uvmalloc+0x74>
    return oldsz;
    8000157a:	852e                	mv	a0,a1
}
    8000157c:	8082                	ret
  return newsz;
    8000157e:	8532                	mv	a0,a2
    80001580:	b7f1                	j	8000154c <uvmalloc+0x74>

0000000080001582 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001582:	7179                	addi	sp,sp,-48
    80001584:	f406                	sd	ra,40(sp)
    80001586:	f022                	sd	s0,32(sp)
    80001588:	ec26                	sd	s1,24(sp)
    8000158a:	e84a                	sd	s2,16(sp)
    8000158c:	e44e                	sd	s3,8(sp)
    8000158e:	e052                	sd	s4,0(sp)
    80001590:	1800                	addi	s0,sp,48
    80001592:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001594:	84aa                	mv	s1,a0
    80001596:	6905                	lui	s2,0x1
    80001598:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000159a:	4985                	li	s3,1
    8000159c:	a821                	j	800015b4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000159e:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800015a0:	0532                	slli	a0,a0,0xc
    800015a2:	00000097          	auipc	ra,0x0
    800015a6:	fe0080e7          	jalr	-32(ra) # 80001582 <freewalk>
      pagetable[i] = 0;
    800015aa:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015ae:	04a1                	addi	s1,s1,8
    800015b0:	03248163          	beq	s1,s2,800015d2 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800015b4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015b6:	00f57793          	andi	a5,a0,15
    800015ba:	ff3782e3          	beq	a5,s3,8000159e <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015be:	8905                	andi	a0,a0,1
    800015c0:	d57d                	beqz	a0,800015ae <freewalk+0x2c>
      panic("freewalk: leaf");
    800015c2:	00007517          	auipc	a0,0x7
    800015c6:	bbe50513          	addi	a0,a0,-1090 # 80008180 <digits+0x128>
    800015ca:	fffff097          	auipc	ra,0xfffff
    800015ce:	f78080e7          	jalr	-136(ra) # 80000542 <panic>
    }
  }
  kfree((void*)pagetable);
    800015d2:	8552                	mv	a0,s4
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	4aa080e7          	jalr	1194(ra) # 80000a7e <kfree>
}
    800015dc:	70a2                	ld	ra,40(sp)
    800015de:	7402                	ld	s0,32(sp)
    800015e0:	64e2                	ld	s1,24(sp)
    800015e2:	6942                	ld	s2,16(sp)
    800015e4:	69a2                	ld	s3,8(sp)
    800015e6:	6a02                	ld	s4,0(sp)
    800015e8:	6145                	addi	sp,sp,48
    800015ea:	8082                	ret

00000000800015ec <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015ec:	1101                	addi	sp,sp,-32
    800015ee:	ec06                	sd	ra,24(sp)
    800015f0:	e822                	sd	s0,16(sp)
    800015f2:	e426                	sd	s1,8(sp)
    800015f4:	1000                	addi	s0,sp,32
    800015f6:	84aa                	mv	s1,a0
  if(sz > 0)
    800015f8:	e999                	bnez	a1,8000160e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015fa:	8526                	mv	a0,s1
    800015fc:	00000097          	auipc	ra,0x0
    80001600:	f86080e7          	jalr	-122(ra) # 80001582 <freewalk>
}
    80001604:	60e2                	ld	ra,24(sp)
    80001606:	6442                	ld	s0,16(sp)
    80001608:	64a2                	ld	s1,8(sp)
    8000160a:	6105                	addi	sp,sp,32
    8000160c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000160e:	6605                	lui	a2,0x1
    80001610:	167d                	addi	a2,a2,-1
    80001612:	962e                	add	a2,a2,a1
    80001614:	4685                	li	a3,1
    80001616:	8231                	srli	a2,a2,0xc
    80001618:	4581                	li	a1,0
    8000161a:	00000097          	auipc	ra,0x0
    8000161e:	d12080e7          	jalr	-750(ra) # 8000132c <uvmunmap>
    80001622:	bfe1                	j	800015fa <uvmfree+0xe>

0000000080001624 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001624:	c679                	beqz	a2,800016f2 <uvmcopy+0xce>
{
    80001626:	715d                	addi	sp,sp,-80
    80001628:	e486                	sd	ra,72(sp)
    8000162a:	e0a2                	sd	s0,64(sp)
    8000162c:	fc26                	sd	s1,56(sp)
    8000162e:	f84a                	sd	s2,48(sp)
    80001630:	f44e                	sd	s3,40(sp)
    80001632:	f052                	sd	s4,32(sp)
    80001634:	ec56                	sd	s5,24(sp)
    80001636:	e85a                	sd	s6,16(sp)
    80001638:	e45e                	sd	s7,8(sp)
    8000163a:	0880                	addi	s0,sp,80
    8000163c:	8b2a                	mv	s6,a0
    8000163e:	8aae                	mv	s5,a1
    80001640:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001642:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001644:	4601                	li	a2,0
    80001646:	85ce                	mv	a1,s3
    80001648:	855a                	mv	a0,s6
    8000164a:	00000097          	auipc	ra,0x0
    8000164e:	a04080e7          	jalr	-1532(ra) # 8000104e <walk>
    80001652:	c531                	beqz	a0,8000169e <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001654:	6118                	ld	a4,0(a0)
    80001656:	00177793          	andi	a5,a4,1
    8000165a:	cbb1                	beqz	a5,800016ae <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000165c:	00a75593          	srli	a1,a4,0xa
    80001660:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001664:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001668:	fffff097          	auipc	ra,0xfffff
    8000166c:	512080e7          	jalr	1298(ra) # 80000b7a <kalloc>
    80001670:	892a                	mv	s2,a0
    80001672:	c939                	beqz	a0,800016c8 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001674:	6605                	lui	a2,0x1
    80001676:	85de                	mv	a1,s7
    80001678:	fffff097          	auipc	ra,0xfffff
    8000167c:	74a080e7          	jalr	1866(ra) # 80000dc2 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001680:	8726                	mv	a4,s1
    80001682:	86ca                	mv	a3,s2
    80001684:	6605                	lui	a2,0x1
    80001686:	85ce                	mv	a1,s3
    80001688:	8556                	mv	a0,s5
    8000168a:	00000097          	auipc	ra,0x0
    8000168e:	b0a080e7          	jalr	-1270(ra) # 80001194 <mappages>
    80001692:	e515                	bnez	a0,800016be <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001694:	6785                	lui	a5,0x1
    80001696:	99be                	add	s3,s3,a5
    80001698:	fb49e6e3          	bltu	s3,s4,80001644 <uvmcopy+0x20>
    8000169c:	a081                	j	800016dc <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    8000169e:	00007517          	auipc	a0,0x7
    800016a2:	af250513          	addi	a0,a0,-1294 # 80008190 <digits+0x138>
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	e9c080e7          	jalr	-356(ra) # 80000542 <panic>
      panic("uvmcopy: page not present");
    800016ae:	00007517          	auipc	a0,0x7
    800016b2:	b0250513          	addi	a0,a0,-1278 # 800081b0 <digits+0x158>
    800016b6:	fffff097          	auipc	ra,0xfffff
    800016ba:	e8c080e7          	jalr	-372(ra) # 80000542 <panic>
      kfree(mem);
    800016be:	854a                	mv	a0,s2
    800016c0:	fffff097          	auipc	ra,0xfffff
    800016c4:	3be080e7          	jalr	958(ra) # 80000a7e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016c8:	4685                	li	a3,1
    800016ca:	00c9d613          	srli	a2,s3,0xc
    800016ce:	4581                	li	a1,0
    800016d0:	8556                	mv	a0,s5
    800016d2:	00000097          	auipc	ra,0x0
    800016d6:	c5a080e7          	jalr	-934(ra) # 8000132c <uvmunmap>
  return -1;
    800016da:	557d                	li	a0,-1
}
    800016dc:	60a6                	ld	ra,72(sp)
    800016de:	6406                	ld	s0,64(sp)
    800016e0:	74e2                	ld	s1,56(sp)
    800016e2:	7942                	ld	s2,48(sp)
    800016e4:	79a2                	ld	s3,40(sp)
    800016e6:	7a02                	ld	s4,32(sp)
    800016e8:	6ae2                	ld	s5,24(sp)
    800016ea:	6b42                	ld	s6,16(sp)
    800016ec:	6ba2                	ld	s7,8(sp)
    800016ee:	6161                	addi	sp,sp,80
    800016f0:	8082                	ret
  return 0;
    800016f2:	4501                	li	a0,0
}
    800016f4:	8082                	ret

00000000800016f6 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016f6:	1141                	addi	sp,sp,-16
    800016f8:	e406                	sd	ra,8(sp)
    800016fa:	e022                	sd	s0,0(sp)
    800016fc:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016fe:	4601                	li	a2,0
    80001700:	00000097          	auipc	ra,0x0
    80001704:	94e080e7          	jalr	-1714(ra) # 8000104e <walk>
  if(pte == 0)
    80001708:	c901                	beqz	a0,80001718 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000170a:	611c                	ld	a5,0(a0)
    8000170c:	9bbd                	andi	a5,a5,-17
    8000170e:	e11c                	sd	a5,0(a0)
}
    80001710:	60a2                	ld	ra,8(sp)
    80001712:	6402                	ld	s0,0(sp)
    80001714:	0141                	addi	sp,sp,16
    80001716:	8082                	ret
    panic("uvmclear");
    80001718:	00007517          	auipc	a0,0x7
    8000171c:	ab850513          	addi	a0,a0,-1352 # 800081d0 <digits+0x178>
    80001720:	fffff097          	auipc	ra,0xfffff
    80001724:	e22080e7          	jalr	-478(ra) # 80000542 <panic>

0000000080001728 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001728:	c6bd                	beqz	a3,80001796 <copyout+0x6e>
{
    8000172a:	715d                	addi	sp,sp,-80
    8000172c:	e486                	sd	ra,72(sp)
    8000172e:	e0a2                	sd	s0,64(sp)
    80001730:	fc26                	sd	s1,56(sp)
    80001732:	f84a                	sd	s2,48(sp)
    80001734:	f44e                	sd	s3,40(sp)
    80001736:	f052                	sd	s4,32(sp)
    80001738:	ec56                	sd	s5,24(sp)
    8000173a:	e85a                	sd	s6,16(sp)
    8000173c:	e45e                	sd	s7,8(sp)
    8000173e:	e062                	sd	s8,0(sp)
    80001740:	0880                	addi	s0,sp,80
    80001742:	8b2a                	mv	s6,a0
    80001744:	8c2e                	mv	s8,a1
    80001746:	8a32                	mv	s4,a2
    80001748:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000174a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000174c:	6a85                	lui	s5,0x1
    8000174e:	a015                	j	80001772 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001750:	9562                	add	a0,a0,s8
    80001752:	0004861b          	sext.w	a2,s1
    80001756:	85d2                	mv	a1,s4
    80001758:	41250533          	sub	a0,a0,s2
    8000175c:	fffff097          	auipc	ra,0xfffff
    80001760:	666080e7          	jalr	1638(ra) # 80000dc2 <memmove>

    len -= n;
    80001764:	409989b3          	sub	s3,s3,s1
    src += n;
    80001768:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000176a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000176e:	02098263          	beqz	s3,80001792 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001772:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001776:	85ca                	mv	a1,s2
    80001778:	855a                	mv	a0,s6
    8000177a:	00000097          	auipc	ra,0x0
    8000177e:	97a080e7          	jalr	-1670(ra) # 800010f4 <walkaddr>
    if(pa0 == 0)
    80001782:	cd01                	beqz	a0,8000179a <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001784:	418904b3          	sub	s1,s2,s8
    80001788:	94d6                	add	s1,s1,s5
    if(n > len)
    8000178a:	fc99f3e3          	bgeu	s3,s1,80001750 <copyout+0x28>
    8000178e:	84ce                	mv	s1,s3
    80001790:	b7c1                	j	80001750 <copyout+0x28>
  }
  return 0;
    80001792:	4501                	li	a0,0
    80001794:	a021                	j	8000179c <copyout+0x74>
    80001796:	4501                	li	a0,0
}
    80001798:	8082                	ret
      return -1;
    8000179a:	557d                	li	a0,-1
}
    8000179c:	60a6                	ld	ra,72(sp)
    8000179e:	6406                	ld	s0,64(sp)
    800017a0:	74e2                	ld	s1,56(sp)
    800017a2:	7942                	ld	s2,48(sp)
    800017a4:	79a2                	ld	s3,40(sp)
    800017a6:	7a02                	ld	s4,32(sp)
    800017a8:	6ae2                	ld	s5,24(sp)
    800017aa:	6b42                	ld	s6,16(sp)
    800017ac:	6ba2                	ld	s7,8(sp)
    800017ae:	6c02                	ld	s8,0(sp)
    800017b0:	6161                	addi	sp,sp,80
    800017b2:	8082                	ret

00000000800017b4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017b4:	caa5                	beqz	a3,80001824 <copyin+0x70>
{
    800017b6:	715d                	addi	sp,sp,-80
    800017b8:	e486                	sd	ra,72(sp)
    800017ba:	e0a2                	sd	s0,64(sp)
    800017bc:	fc26                	sd	s1,56(sp)
    800017be:	f84a                	sd	s2,48(sp)
    800017c0:	f44e                	sd	s3,40(sp)
    800017c2:	f052                	sd	s4,32(sp)
    800017c4:	ec56                	sd	s5,24(sp)
    800017c6:	e85a                	sd	s6,16(sp)
    800017c8:	e45e                	sd	s7,8(sp)
    800017ca:	e062                	sd	s8,0(sp)
    800017cc:	0880                	addi	s0,sp,80
    800017ce:	8b2a                	mv	s6,a0
    800017d0:	8a2e                	mv	s4,a1
    800017d2:	8c32                	mv	s8,a2
    800017d4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017d6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017d8:	6a85                	lui	s5,0x1
    800017da:	a01d                	j	80001800 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017dc:	018505b3          	add	a1,a0,s8
    800017e0:	0004861b          	sext.w	a2,s1
    800017e4:	412585b3          	sub	a1,a1,s2
    800017e8:	8552                	mv	a0,s4
    800017ea:	fffff097          	auipc	ra,0xfffff
    800017ee:	5d8080e7          	jalr	1496(ra) # 80000dc2 <memmove>

    len -= n;
    800017f2:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017f6:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017f8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017fc:	02098263          	beqz	s3,80001820 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001800:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001804:	85ca                	mv	a1,s2
    80001806:	855a                	mv	a0,s6
    80001808:	00000097          	auipc	ra,0x0
    8000180c:	8ec080e7          	jalr	-1812(ra) # 800010f4 <walkaddr>
    if(pa0 == 0)
    80001810:	cd01                	beqz	a0,80001828 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001812:	418904b3          	sub	s1,s2,s8
    80001816:	94d6                	add	s1,s1,s5
    if(n > len)
    80001818:	fc99f2e3          	bgeu	s3,s1,800017dc <copyin+0x28>
    8000181c:	84ce                	mv	s1,s3
    8000181e:	bf7d                	j	800017dc <copyin+0x28>
  }
  return 0;
    80001820:	4501                	li	a0,0
    80001822:	a021                	j	8000182a <copyin+0x76>
    80001824:	4501                	li	a0,0
}
    80001826:	8082                	ret
      return -1;
    80001828:	557d                	li	a0,-1
}
    8000182a:	60a6                	ld	ra,72(sp)
    8000182c:	6406                	ld	s0,64(sp)
    8000182e:	74e2                	ld	s1,56(sp)
    80001830:	7942                	ld	s2,48(sp)
    80001832:	79a2                	ld	s3,40(sp)
    80001834:	7a02                	ld	s4,32(sp)
    80001836:	6ae2                	ld	s5,24(sp)
    80001838:	6b42                	ld	s6,16(sp)
    8000183a:	6ba2                	ld	s7,8(sp)
    8000183c:	6c02                	ld	s8,0(sp)
    8000183e:	6161                	addi	sp,sp,80
    80001840:	8082                	ret

0000000080001842 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001842:	c6c5                	beqz	a3,800018ea <copyinstr+0xa8>
{
    80001844:	715d                	addi	sp,sp,-80
    80001846:	e486                	sd	ra,72(sp)
    80001848:	e0a2                	sd	s0,64(sp)
    8000184a:	fc26                	sd	s1,56(sp)
    8000184c:	f84a                	sd	s2,48(sp)
    8000184e:	f44e                	sd	s3,40(sp)
    80001850:	f052                	sd	s4,32(sp)
    80001852:	ec56                	sd	s5,24(sp)
    80001854:	e85a                	sd	s6,16(sp)
    80001856:	e45e                	sd	s7,8(sp)
    80001858:	0880                	addi	s0,sp,80
    8000185a:	8a2a                	mv	s4,a0
    8000185c:	8b2e                	mv	s6,a1
    8000185e:	8bb2                	mv	s7,a2
    80001860:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001862:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001864:	6985                	lui	s3,0x1
    80001866:	a035                	j	80001892 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001868:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000186c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000186e:	0017b793          	seqz	a5,a5
    80001872:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001876:	60a6                	ld	ra,72(sp)
    80001878:	6406                	ld	s0,64(sp)
    8000187a:	74e2                	ld	s1,56(sp)
    8000187c:	7942                	ld	s2,48(sp)
    8000187e:	79a2                	ld	s3,40(sp)
    80001880:	7a02                	ld	s4,32(sp)
    80001882:	6ae2                	ld	s5,24(sp)
    80001884:	6b42                	ld	s6,16(sp)
    80001886:	6ba2                	ld	s7,8(sp)
    80001888:	6161                	addi	sp,sp,80
    8000188a:	8082                	ret
    srcva = va0 + PGSIZE;
    8000188c:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001890:	c8a9                	beqz	s1,800018e2 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001892:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001896:	85ca                	mv	a1,s2
    80001898:	8552                	mv	a0,s4
    8000189a:	00000097          	auipc	ra,0x0
    8000189e:	85a080e7          	jalr	-1958(ra) # 800010f4 <walkaddr>
    if(pa0 == 0)
    800018a2:	c131                	beqz	a0,800018e6 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800018a4:	41790833          	sub	a6,s2,s7
    800018a8:	984e                	add	a6,a6,s3
    if(n > max)
    800018aa:	0104f363          	bgeu	s1,a6,800018b0 <copyinstr+0x6e>
    800018ae:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018b0:	955e                	add	a0,a0,s7
    800018b2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018b6:	fc080be3          	beqz	a6,8000188c <copyinstr+0x4a>
    800018ba:	985a                	add	a6,a6,s6
    800018bc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018be:	41650633          	sub	a2,a0,s6
    800018c2:	14fd                	addi	s1,s1,-1
    800018c4:	9b26                	add	s6,s6,s1
    800018c6:	00f60733          	add	a4,a2,a5
    800018ca:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd8000>
    800018ce:	df49                	beqz	a4,80001868 <copyinstr+0x26>
        *dst = *p;
    800018d0:	00e78023          	sb	a4,0(a5)
      --max;
    800018d4:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800018d8:	0785                	addi	a5,a5,1
    while(n > 0){
    800018da:	ff0796e3          	bne	a5,a6,800018c6 <copyinstr+0x84>
      dst++;
    800018de:	8b42                	mv	s6,a6
    800018e0:	b775                	j	8000188c <copyinstr+0x4a>
    800018e2:	4781                	li	a5,0
    800018e4:	b769                	j	8000186e <copyinstr+0x2c>
      return -1;
    800018e6:	557d                	li	a0,-1
    800018e8:	b779                	j	80001876 <copyinstr+0x34>
  int got_null = 0;
    800018ea:	4781                	li	a5,0
  if(got_null){
    800018ec:	0017b793          	seqz	a5,a5
    800018f0:	40f00533          	neg	a0,a5
}
    800018f4:	8082                	ret

00000000800018f6 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800018f6:	1101                	addi	sp,sp,-32
    800018f8:	ec06                	sd	ra,24(sp)
    800018fa:	e822                	sd	s0,16(sp)
    800018fc:	e426                	sd	s1,8(sp)
    800018fe:	1000                	addi	s0,sp,32
    80001900:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	2ee080e7          	jalr	750(ra) # 80000bf0 <holding>
    8000190a:	c909                	beqz	a0,8000191c <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    8000190c:	749c                	ld	a5,40(s1)
    8000190e:	00978f63          	beq	a5,s1,8000192c <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001912:	60e2                	ld	ra,24(sp)
    80001914:	6442                	ld	s0,16(sp)
    80001916:	64a2                	ld	s1,8(sp)
    80001918:	6105                	addi	sp,sp,32
    8000191a:	8082                	ret
    panic("wakeup1");
    8000191c:	00007517          	auipc	a0,0x7
    80001920:	8c450513          	addi	a0,a0,-1852 # 800081e0 <digits+0x188>
    80001924:	fffff097          	auipc	ra,0xfffff
    80001928:	c1e080e7          	jalr	-994(ra) # 80000542 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    8000192c:	4c98                	lw	a4,24(s1)
    8000192e:	4785                	li	a5,1
    80001930:	fef711e3          	bne	a4,a5,80001912 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001934:	4789                	li	a5,2
    80001936:	cc9c                	sw	a5,24(s1)
}
    80001938:	bfe9                	j	80001912 <wakeup1+0x1c>

000000008000193a <procinit>:
{
    8000193a:	715d                	addi	sp,sp,-80
    8000193c:	e486                	sd	ra,72(sp)
    8000193e:	e0a2                	sd	s0,64(sp)
    80001940:	fc26                	sd	s1,56(sp)
    80001942:	f84a                	sd	s2,48(sp)
    80001944:	f44e                	sd	s3,40(sp)
    80001946:	f052                	sd	s4,32(sp)
    80001948:	ec56                	sd	s5,24(sp)
    8000194a:	e85a                	sd	s6,16(sp)
    8000194c:	e45e                	sd	s7,8(sp)
    8000194e:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001950:	00007597          	auipc	a1,0x7
    80001954:	89858593          	addi	a1,a1,-1896 # 800081e8 <digits+0x190>
    80001958:	00010517          	auipc	a0,0x10
    8000195c:	ff850513          	addi	a0,a0,-8 # 80011950 <pid_lock>
    80001960:	fffff097          	auipc	ra,0xfffff
    80001964:	27a080e7          	jalr	634(ra) # 80000bda <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001968:	00010917          	auipc	s2,0x10
    8000196c:	40090913          	addi	s2,s2,1024 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001970:	00007b97          	auipc	s7,0x7
    80001974:	880b8b93          	addi	s7,s7,-1920 # 800081f0 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    80001978:	8b4a                	mv	s6,s2
    8000197a:	00006a97          	auipc	s5,0x6
    8000197e:	686a8a93          	addi	s5,s5,1670 # 80008000 <etext>
    80001982:	040009b7          	lui	s3,0x4000
    80001986:	19fd                	addi	s3,s3,-1
    80001988:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000198a:	00016a17          	auipc	s4,0x16
    8000198e:	7dea0a13          	addi	s4,s4,2014 # 80018168 <tickslock>
      initlock(&p->lock, "proc");
    80001992:	85de                	mv	a1,s7
    80001994:	854a                	mv	a0,s2
    80001996:	fffff097          	auipc	ra,0xfffff
    8000199a:	244080e7          	jalr	580(ra) # 80000bda <initlock>
      char *pa = kalloc();
    8000199e:	fffff097          	auipc	ra,0xfffff
    800019a2:	1dc080e7          	jalr	476(ra) # 80000b7a <kalloc>
    800019a6:	85aa                	mv	a1,a0
      if(pa == 0)
    800019a8:	c929                	beqz	a0,800019fa <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800019aa:	416904b3          	sub	s1,s2,s6
    800019ae:	8491                	srai	s1,s1,0x4
    800019b0:	000ab783          	ld	a5,0(s5)
    800019b4:	02f484b3          	mul	s1,s1,a5
    800019b8:	2485                	addiw	s1,s1,1
    800019ba:	00d4949b          	slliw	s1,s1,0xd
    800019be:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019c2:	4699                	li	a3,6
    800019c4:	6605                	lui	a2,0x1
    800019c6:	8526                	mv	a0,s1
    800019c8:	00000097          	auipc	ra,0x0
    800019cc:	85a080e7          	jalr	-1958(ra) # 80001222 <kvmmap>
      p->kstack = va;
    800019d0:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d4:	19090913          	addi	s2,s2,400
    800019d8:	fb491de3          	bne	s2,s4,80001992 <procinit+0x58>
  kvminithart();
    800019dc:	fffff097          	auipc	ra,0xfffff
    800019e0:	64e080e7          	jalr	1614(ra) # 8000102a <kvminithart>
}
    800019e4:	60a6                	ld	ra,72(sp)
    800019e6:	6406                	ld	s0,64(sp)
    800019e8:	74e2                	ld	s1,56(sp)
    800019ea:	7942                	ld	s2,48(sp)
    800019ec:	79a2                	ld	s3,40(sp)
    800019ee:	7a02                	ld	s4,32(sp)
    800019f0:	6ae2                	ld	s5,24(sp)
    800019f2:	6b42                	ld	s6,16(sp)
    800019f4:	6ba2                	ld	s7,8(sp)
    800019f6:	6161                	addi	sp,sp,80
    800019f8:	8082                	ret
        panic("kalloc");
    800019fa:	00006517          	auipc	a0,0x6
    800019fe:	7fe50513          	addi	a0,a0,2046 # 800081f8 <digits+0x1a0>
    80001a02:	fffff097          	auipc	ra,0xfffff
    80001a06:	b40080e7          	jalr	-1216(ra) # 80000542 <panic>

0000000080001a0a <cpuid>:
{
    80001a0a:	1141                	addi	sp,sp,-16
    80001a0c:	e422                	sd	s0,8(sp)
    80001a0e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a10:	8512                	mv	a0,tp
}
    80001a12:	2501                	sext.w	a0,a0
    80001a14:	6422                	ld	s0,8(sp)
    80001a16:	0141                	addi	sp,sp,16
    80001a18:	8082                	ret

0000000080001a1a <mycpu>:
mycpu(void) {
    80001a1a:	1141                	addi	sp,sp,-16
    80001a1c:	e422                	sd	s0,8(sp)
    80001a1e:	0800                	addi	s0,sp,16
    80001a20:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a22:	2781                	sext.w	a5,a5
    80001a24:	079e                	slli	a5,a5,0x7
}
    80001a26:	00010517          	auipc	a0,0x10
    80001a2a:	f4250513          	addi	a0,a0,-190 # 80011968 <cpus>
    80001a2e:	953e                	add	a0,a0,a5
    80001a30:	6422                	ld	s0,8(sp)
    80001a32:	0141                	addi	sp,sp,16
    80001a34:	8082                	ret

0000000080001a36 <myproc>:
myproc(void) {
    80001a36:	1101                	addi	sp,sp,-32
    80001a38:	ec06                	sd	ra,24(sp)
    80001a3a:	e822                	sd	s0,16(sp)
    80001a3c:	e426                	sd	s1,8(sp)
    80001a3e:	1000                	addi	s0,sp,32
  push_off();
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	1de080e7          	jalr	478(ra) # 80000c1e <push_off>
    80001a48:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a4a:	2781                	sext.w	a5,a5
    80001a4c:	079e                	slli	a5,a5,0x7
    80001a4e:	00010717          	auipc	a4,0x10
    80001a52:	f0270713          	addi	a4,a4,-254 # 80011950 <pid_lock>
    80001a56:	97ba                	add	a5,a5,a4
    80001a58:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	264080e7          	jalr	612(ra) # 80000cbe <pop_off>
}
    80001a62:	8526                	mv	a0,s1
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6105                	addi	sp,sp,32
    80001a6c:	8082                	ret

0000000080001a6e <forkret>:
{
    80001a6e:	1141                	addi	sp,sp,-16
    80001a70:	e406                	sd	ra,8(sp)
    80001a72:	e022                	sd	s0,0(sp)
    80001a74:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a76:	00000097          	auipc	ra,0x0
    80001a7a:	fc0080e7          	jalr	-64(ra) # 80001a36 <myproc>
    80001a7e:	fffff097          	auipc	ra,0xfffff
    80001a82:	2a0080e7          	jalr	672(ra) # 80000d1e <release>
  if (first) {
    80001a86:	00007797          	auipc	a5,0x7
    80001a8a:	dba7a783          	lw	a5,-582(a5) # 80008840 <first.1>
    80001a8e:	eb89                	bnez	a5,80001aa0 <forkret+0x32>
  usertrapret();
    80001a90:	00001097          	auipc	ra,0x1
    80001a94:	c44080e7          	jalr	-956(ra) # 800026d4 <usertrapret>
}
    80001a98:	60a2                	ld	ra,8(sp)
    80001a9a:	6402                	ld	s0,0(sp)
    80001a9c:	0141                	addi	sp,sp,16
    80001a9e:	8082                	ret
    first = 0;
    80001aa0:	00007797          	auipc	a5,0x7
    80001aa4:	da07a023          	sw	zero,-608(a5) # 80008840 <first.1>
    fsinit(ROOTDEV);
    80001aa8:	4505                	li	a0,1
    80001aaa:	00002097          	auipc	ra,0x2
    80001aae:	afe080e7          	jalr	-1282(ra) # 800035a8 <fsinit>
    80001ab2:	bff9                	j	80001a90 <forkret+0x22>

0000000080001ab4 <allocpid>:
allocpid() {
    80001ab4:	1101                	addi	sp,sp,-32
    80001ab6:	ec06                	sd	ra,24(sp)
    80001ab8:	e822                	sd	s0,16(sp)
    80001aba:	e426                	sd	s1,8(sp)
    80001abc:	e04a                	sd	s2,0(sp)
    80001abe:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ac0:	00010917          	auipc	s2,0x10
    80001ac4:	e9090913          	addi	s2,s2,-368 # 80011950 <pid_lock>
    80001ac8:	854a                	mv	a0,s2
    80001aca:	fffff097          	auipc	ra,0xfffff
    80001ace:	1a0080e7          	jalr	416(ra) # 80000c6a <acquire>
  pid = nextpid;
    80001ad2:	00007797          	auipc	a5,0x7
    80001ad6:	d7278793          	addi	a5,a5,-654 # 80008844 <nextpid>
    80001ada:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001adc:	0014871b          	addiw	a4,s1,1
    80001ae0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ae2:	854a                	mv	a0,s2
    80001ae4:	fffff097          	auipc	ra,0xfffff
    80001ae8:	23a080e7          	jalr	570(ra) # 80000d1e <release>
}
    80001aec:	8526                	mv	a0,s1
    80001aee:	60e2                	ld	ra,24(sp)
    80001af0:	6442                	ld	s0,16(sp)
    80001af2:	64a2                	ld	s1,8(sp)
    80001af4:	6902                	ld	s2,0(sp)
    80001af6:	6105                	addi	sp,sp,32
    80001af8:	8082                	ret

0000000080001afa <proc_pagetable>:
{
    80001afa:	1101                	addi	sp,sp,-32
    80001afc:	ec06                	sd	ra,24(sp)
    80001afe:	e822                	sd	s0,16(sp)
    80001b00:	e426                	sd	s1,8(sp)
    80001b02:	e04a                	sd	s2,0(sp)
    80001b04:	1000                	addi	s0,sp,32
    80001b06:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b08:	00000097          	auipc	ra,0x0
    80001b0c:	8e8080e7          	jalr	-1816(ra) # 800013f0 <uvmcreate>
    80001b10:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b12:	c121                	beqz	a0,80001b52 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b14:	4729                	li	a4,10
    80001b16:	00005697          	auipc	a3,0x5
    80001b1a:	4ea68693          	addi	a3,a3,1258 # 80007000 <_trampoline>
    80001b1e:	6605                	lui	a2,0x1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	66c080e7          	jalr	1644(ra) # 80001194 <mappages>
    80001b30:	02054863          	bltz	a0,80001b60 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b34:	4719                	li	a4,6
    80001b36:	05893683          	ld	a3,88(s2)
    80001b3a:	6605                	lui	a2,0x1
    80001b3c:	020005b7          	lui	a1,0x2000
    80001b40:	15fd                	addi	a1,a1,-1
    80001b42:	05b6                	slli	a1,a1,0xd
    80001b44:	8526                	mv	a0,s1
    80001b46:	fffff097          	auipc	ra,0xfffff
    80001b4a:	64e080e7          	jalr	1614(ra) # 80001194 <mappages>
    80001b4e:	02054163          	bltz	a0,80001b70 <proc_pagetable+0x76>
}
    80001b52:	8526                	mv	a0,s1
    80001b54:	60e2                	ld	ra,24(sp)
    80001b56:	6442                	ld	s0,16(sp)
    80001b58:	64a2                	ld	s1,8(sp)
    80001b5a:	6902                	ld	s2,0(sp)
    80001b5c:	6105                	addi	sp,sp,32
    80001b5e:	8082                	ret
    uvmfree(pagetable, 0);
    80001b60:	4581                	li	a1,0
    80001b62:	8526                	mv	a0,s1
    80001b64:	00000097          	auipc	ra,0x0
    80001b68:	a88080e7          	jalr	-1400(ra) # 800015ec <uvmfree>
    return 0;
    80001b6c:	4481                	li	s1,0
    80001b6e:	b7d5                	j	80001b52 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b70:	4681                	li	a3,0
    80001b72:	4605                	li	a2,1
    80001b74:	040005b7          	lui	a1,0x4000
    80001b78:	15fd                	addi	a1,a1,-1
    80001b7a:	05b2                	slli	a1,a1,0xc
    80001b7c:	8526                	mv	a0,s1
    80001b7e:	fffff097          	auipc	ra,0xfffff
    80001b82:	7ae080e7          	jalr	1966(ra) # 8000132c <uvmunmap>
    uvmfree(pagetable, 0);
    80001b86:	4581                	li	a1,0
    80001b88:	8526                	mv	a0,s1
    80001b8a:	00000097          	auipc	ra,0x0
    80001b8e:	a62080e7          	jalr	-1438(ra) # 800015ec <uvmfree>
    return 0;
    80001b92:	4481                	li	s1,0
    80001b94:	bf7d                	j	80001b52 <proc_pagetable+0x58>

0000000080001b96 <proc_freepagetable>:
{
    80001b96:	1101                	addi	sp,sp,-32
    80001b98:	ec06                	sd	ra,24(sp)
    80001b9a:	e822                	sd	s0,16(sp)
    80001b9c:	e426                	sd	s1,8(sp)
    80001b9e:	e04a                	sd	s2,0(sp)
    80001ba0:	1000                	addi	s0,sp,32
    80001ba2:	84aa                	mv	s1,a0
    80001ba4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ba6:	4681                	li	a3,0
    80001ba8:	4605                	li	a2,1
    80001baa:	040005b7          	lui	a1,0x4000
    80001bae:	15fd                	addi	a1,a1,-1
    80001bb0:	05b2                	slli	a1,a1,0xc
    80001bb2:	fffff097          	auipc	ra,0xfffff
    80001bb6:	77a080e7          	jalr	1914(ra) # 8000132c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bba:	4681                	li	a3,0
    80001bbc:	4605                	li	a2,1
    80001bbe:	020005b7          	lui	a1,0x2000
    80001bc2:	15fd                	addi	a1,a1,-1
    80001bc4:	05b6                	slli	a1,a1,0xd
    80001bc6:	8526                	mv	a0,s1
    80001bc8:	fffff097          	auipc	ra,0xfffff
    80001bcc:	764080e7          	jalr	1892(ra) # 8000132c <uvmunmap>
  uvmfree(pagetable, sz);
    80001bd0:	85ca                	mv	a1,s2
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	00000097          	auipc	ra,0x0
    80001bd8:	a18080e7          	jalr	-1512(ra) # 800015ec <uvmfree>
}
    80001bdc:	60e2                	ld	ra,24(sp)
    80001bde:	6442                	ld	s0,16(sp)
    80001be0:	64a2                	ld	s1,8(sp)
    80001be2:	6902                	ld	s2,0(sp)
    80001be4:	6105                	addi	sp,sp,32
    80001be6:	8082                	ret

0000000080001be8 <freeproc>:
{
    80001be8:	1101                	addi	sp,sp,-32
    80001bea:	ec06                	sd	ra,24(sp)
    80001bec:	e822                	sd	s0,16(sp)
    80001bee:	e426                	sd	s1,8(sp)
    80001bf0:	1000                	addi	s0,sp,32
    80001bf2:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bf4:	6d28                	ld	a0,88(a0)
    80001bf6:	c509                	beqz	a0,80001c00 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bf8:	fffff097          	auipc	ra,0xfffff
    80001bfc:	e86080e7          	jalr	-378(ra) # 80000a7e <kfree>
  if(p->trapframeSave)
    80001c00:	1804b503          	ld	a0,384(s1)
    80001c04:	c509                	beqz	a0,80001c0e <freeproc+0x26>
    kfree((void*)p->trapframeSave);
    80001c06:	fffff097          	auipc	ra,0xfffff
    80001c0a:	e78080e7          	jalr	-392(ra) # 80000a7e <kfree>
  p->trapframe = 0;
    80001c0e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c12:	68a8                	ld	a0,80(s1)
    80001c14:	c511                	beqz	a0,80001c20 <freeproc+0x38>
    proc_freepagetable(p->pagetable, p->sz);
    80001c16:	64ac                	ld	a1,72(s1)
    80001c18:	00000097          	auipc	ra,0x0
    80001c1c:	f7e080e7          	jalr	-130(ra) # 80001b96 <proc_freepagetable>
  p->pagetable = 0;
    80001c20:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c24:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c28:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c2c:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c30:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c34:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c38:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c3c:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c40:	0004ac23          	sw	zero,24(s1)
}
    80001c44:	60e2                	ld	ra,24(sp)
    80001c46:	6442                	ld	s0,16(sp)
    80001c48:	64a2                	ld	s1,8(sp)
    80001c4a:	6105                	addi	sp,sp,32
    80001c4c:	8082                	ret

0000000080001c4e <allocproc>:
{
    80001c4e:	1101                	addi	sp,sp,-32
    80001c50:	ec06                	sd	ra,24(sp)
    80001c52:	e822                	sd	s0,16(sp)
    80001c54:	e426                	sd	s1,8(sp)
    80001c56:	e04a                	sd	s2,0(sp)
    80001c58:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c5a:	00010497          	auipc	s1,0x10
    80001c5e:	10e48493          	addi	s1,s1,270 # 80011d68 <proc>
    80001c62:	00016917          	auipc	s2,0x16
    80001c66:	50690913          	addi	s2,s2,1286 # 80018168 <tickslock>
    acquire(&p->lock);
    80001c6a:	8526                	mv	a0,s1
    80001c6c:	fffff097          	auipc	ra,0xfffff
    80001c70:	ffe080e7          	jalr	-2(ra) # 80000c6a <acquire>
    if(p->state == UNUSED) {
    80001c74:	4c9c                	lw	a5,24(s1)
    80001c76:	cf81                	beqz	a5,80001c8e <allocproc+0x40>
      release(&p->lock);
    80001c78:	8526                	mv	a0,s1
    80001c7a:	fffff097          	auipc	ra,0xfffff
    80001c7e:	0a4080e7          	jalr	164(ra) # 80000d1e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c82:	19048493          	addi	s1,s1,400
    80001c86:	ff2492e3          	bne	s1,s2,80001c6a <allocproc+0x1c>
  return 0;
    80001c8a:	4481                	li	s1,0
    80001c8c:	a08d                	j	80001cee <allocproc+0xa0>
  p->pid = allocpid();
    80001c8e:	00000097          	auipc	ra,0x0
    80001c92:	e26080e7          	jalr	-474(ra) # 80001ab4 <allocpid>
    80001c96:	dc88                	sw	a0,56(s1)
  p->spend=0;
    80001c98:	1604bc23          	sd	zero,376(s1)
  if((p->trapframeSave = (struct trapframe *)kalloc()) == 0){
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	ede080e7          	jalr	-290(ra) # 80000b7a <kalloc>
    80001ca4:	892a                	mv	s2,a0
    80001ca6:	18a4b023          	sd	a0,384(s1)
    80001caa:	c929                	beqz	a0,80001cfc <allocproc+0xae>
if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	ece080e7          	jalr	-306(ra) # 80000b7a <kalloc>
    80001cb4:	892a                	mv	s2,a0
    80001cb6:	eca8                	sd	a0,88(s1)
    80001cb8:	c929                	beqz	a0,80001d0a <allocproc+0xbc>
  p->pagetable = proc_pagetable(p);
    80001cba:	8526                	mv	a0,s1
    80001cbc:	00000097          	auipc	ra,0x0
    80001cc0:	e3e080e7          	jalr	-450(ra) # 80001afa <proc_pagetable>
    80001cc4:	892a                	mv	s2,a0
    80001cc6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cc8:	c921                	beqz	a0,80001d18 <allocproc+0xca>
  memset(&p->context, 0, sizeof(p->context));
    80001cca:	07000613          	li	a2,112
    80001cce:	4581                	li	a1,0
    80001cd0:	06048513          	addi	a0,s1,96
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	092080e7          	jalr	146(ra) # 80000d66 <memset>
  p->context.ra = (uint64)forkret;
    80001cdc:	00000797          	auipc	a5,0x0
    80001ce0:	d9278793          	addi	a5,a5,-622 # 80001a6e <forkret>
    80001ce4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ce6:	60bc                	ld	a5,64(s1)
    80001ce8:	6705                	lui	a4,0x1
    80001cea:	97ba                	add	a5,a5,a4
    80001cec:	f4bc                	sd	a5,104(s1)
}
    80001cee:	8526                	mv	a0,s1
    80001cf0:	60e2                	ld	ra,24(sp)
    80001cf2:	6442                	ld	s0,16(sp)
    80001cf4:	64a2                	ld	s1,8(sp)
    80001cf6:	6902                	ld	s2,0(sp)
    80001cf8:	6105                	addi	sp,sp,32
    80001cfa:	8082                	ret
    release(&p->lock);
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	fffff097          	auipc	ra,0xfffff
    80001d02:	020080e7          	jalr	32(ra) # 80000d1e <release>
    return 0;
    80001d06:	84ca                	mv	s1,s2
    80001d08:	b7dd                	j	80001cee <allocproc+0xa0>
    release(&p->lock);
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	fffff097          	auipc	ra,0xfffff
    80001d10:	012080e7          	jalr	18(ra) # 80000d1e <release>
    return 0;
    80001d14:	84ca                	mv	s1,s2
    80001d16:	bfe1                	j	80001cee <allocproc+0xa0>
    freeproc(p);
    80001d18:	8526                	mv	a0,s1
    80001d1a:	00000097          	auipc	ra,0x0
    80001d1e:	ece080e7          	jalr	-306(ra) # 80001be8 <freeproc>
    release(&p->lock);
    80001d22:	8526                	mv	a0,s1
    80001d24:	fffff097          	auipc	ra,0xfffff
    80001d28:	ffa080e7          	jalr	-6(ra) # 80000d1e <release>
    return 0;
    80001d2c:	84ca                	mv	s1,s2
    80001d2e:	b7c1                	j	80001cee <allocproc+0xa0>

0000000080001d30 <userinit>:
{
    80001d30:	1101                	addi	sp,sp,-32
    80001d32:	ec06                	sd	ra,24(sp)
    80001d34:	e822                	sd	s0,16(sp)
    80001d36:	e426                	sd	s1,8(sp)
    80001d38:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d3a:	00000097          	auipc	ra,0x0
    80001d3e:	f14080e7          	jalr	-236(ra) # 80001c4e <allocproc>
    80001d42:	84aa                	mv	s1,a0
  initproc = p;
    80001d44:	00007797          	auipc	a5,0x7
    80001d48:	2ca7ba23          	sd	a0,724(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d4c:	03400613          	li	a2,52
    80001d50:	00007597          	auipc	a1,0x7
    80001d54:	b0058593          	addi	a1,a1,-1280 # 80008850 <initcode>
    80001d58:	6928                	ld	a0,80(a0)
    80001d5a:	fffff097          	auipc	ra,0xfffff
    80001d5e:	6c4080e7          	jalr	1732(ra) # 8000141e <uvminit>
  p->sz = PGSIZE;
    80001d62:	6785                	lui	a5,0x1
    80001d64:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d66:	6cb8                	ld	a4,88(s1)
    80001d68:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d6c:	6cb8                	ld	a4,88(s1)
    80001d6e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d70:	4641                	li	a2,16
    80001d72:	00006597          	auipc	a1,0x6
    80001d76:	48e58593          	addi	a1,a1,1166 # 80008200 <digits+0x1a8>
    80001d7a:	15848513          	addi	a0,s1,344
    80001d7e:	fffff097          	auipc	ra,0xfffff
    80001d82:	13a080e7          	jalr	314(ra) # 80000eb8 <safestrcpy>
  p->cwd = namei("/");
    80001d86:	00006517          	auipc	a0,0x6
    80001d8a:	48a50513          	addi	a0,a0,1162 # 80008210 <digits+0x1b8>
    80001d8e:	00002097          	auipc	ra,0x2
    80001d92:	242080e7          	jalr	578(ra) # 80003fd0 <namei>
    80001d96:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d9a:	4789                	li	a5,2
    80001d9c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d9e:	8526                	mv	a0,s1
    80001da0:	fffff097          	auipc	ra,0xfffff
    80001da4:	f7e080e7          	jalr	-130(ra) # 80000d1e <release>
}
    80001da8:	60e2                	ld	ra,24(sp)
    80001daa:	6442                	ld	s0,16(sp)
    80001dac:	64a2                	ld	s1,8(sp)
    80001dae:	6105                	addi	sp,sp,32
    80001db0:	8082                	ret

0000000080001db2 <growproc>:
{
    80001db2:	1101                	addi	sp,sp,-32
    80001db4:	ec06                	sd	ra,24(sp)
    80001db6:	e822                	sd	s0,16(sp)
    80001db8:	e426                	sd	s1,8(sp)
    80001dba:	e04a                	sd	s2,0(sp)
    80001dbc:	1000                	addi	s0,sp,32
    80001dbe:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dc0:	00000097          	auipc	ra,0x0
    80001dc4:	c76080e7          	jalr	-906(ra) # 80001a36 <myproc>
    80001dc8:	892a                	mv	s2,a0
  sz = p->sz;
    80001dca:	652c                	ld	a1,72(a0)
    80001dcc:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001dd0:	00904f63          	bgtz	s1,80001dee <growproc+0x3c>
  } else if(n < 0){
    80001dd4:	0204cc63          	bltz	s1,80001e0c <growproc+0x5a>
  p->sz = sz;
    80001dd8:	1602                	slli	a2,a2,0x20
    80001dda:	9201                	srli	a2,a2,0x20
    80001ddc:	04c93423          	sd	a2,72(s2)
  return 0;
    80001de0:	4501                	li	a0,0
}
    80001de2:	60e2                	ld	ra,24(sp)
    80001de4:	6442                	ld	s0,16(sp)
    80001de6:	64a2                	ld	s1,8(sp)
    80001de8:	6902                	ld	s2,0(sp)
    80001dea:	6105                	addi	sp,sp,32
    80001dec:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dee:	9e25                	addw	a2,a2,s1
    80001df0:	1602                	slli	a2,a2,0x20
    80001df2:	9201                	srli	a2,a2,0x20
    80001df4:	1582                	slli	a1,a1,0x20
    80001df6:	9181                	srli	a1,a1,0x20
    80001df8:	6928                	ld	a0,80(a0)
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	6de080e7          	jalr	1758(ra) # 800014d8 <uvmalloc>
    80001e02:	0005061b          	sext.w	a2,a0
    80001e06:	fa69                	bnez	a2,80001dd8 <growproc+0x26>
      return -1;
    80001e08:	557d                	li	a0,-1
    80001e0a:	bfe1                	j	80001de2 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e0c:	9e25                	addw	a2,a2,s1
    80001e0e:	1602                	slli	a2,a2,0x20
    80001e10:	9201                	srli	a2,a2,0x20
    80001e12:	1582                	slli	a1,a1,0x20
    80001e14:	9181                	srli	a1,a1,0x20
    80001e16:	6928                	ld	a0,80(a0)
    80001e18:	fffff097          	auipc	ra,0xfffff
    80001e1c:	678080e7          	jalr	1656(ra) # 80001490 <uvmdealloc>
    80001e20:	0005061b          	sext.w	a2,a0
    80001e24:	bf55                	j	80001dd8 <growproc+0x26>

0000000080001e26 <fork>:
{
    80001e26:	7139                	addi	sp,sp,-64
    80001e28:	fc06                	sd	ra,56(sp)
    80001e2a:	f822                	sd	s0,48(sp)
    80001e2c:	f426                	sd	s1,40(sp)
    80001e2e:	f04a                	sd	s2,32(sp)
    80001e30:	ec4e                	sd	s3,24(sp)
    80001e32:	e852                	sd	s4,16(sp)
    80001e34:	e456                	sd	s5,8(sp)
    80001e36:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e38:	00000097          	auipc	ra,0x0
    80001e3c:	bfe080e7          	jalr	-1026(ra) # 80001a36 <myproc>
    80001e40:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e42:	00000097          	auipc	ra,0x0
    80001e46:	e0c080e7          	jalr	-500(ra) # 80001c4e <allocproc>
    80001e4a:	c17d                	beqz	a0,80001f30 <fork+0x10a>
    80001e4c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e4e:	048ab603          	ld	a2,72(s5)
    80001e52:	692c                	ld	a1,80(a0)
    80001e54:	050ab503          	ld	a0,80(s5)
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	7cc080e7          	jalr	1996(ra) # 80001624 <uvmcopy>
    80001e60:	04054a63          	bltz	a0,80001eb4 <fork+0x8e>
  np->sz = p->sz;
    80001e64:	048ab783          	ld	a5,72(s5)
    80001e68:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001e6c:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e70:	058ab683          	ld	a3,88(s5)
    80001e74:	87b6                	mv	a5,a3
    80001e76:	058a3703          	ld	a4,88(s4)
    80001e7a:	12068693          	addi	a3,a3,288
    80001e7e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e82:	6788                	ld	a0,8(a5)
    80001e84:	6b8c                	ld	a1,16(a5)
    80001e86:	6f90                	ld	a2,24(a5)
    80001e88:	01073023          	sd	a6,0(a4)
    80001e8c:	e708                	sd	a0,8(a4)
    80001e8e:	eb0c                	sd	a1,16(a4)
    80001e90:	ef10                	sd	a2,24(a4)
    80001e92:	02078793          	addi	a5,a5,32
    80001e96:	02070713          	addi	a4,a4,32
    80001e9a:	fed792e3          	bne	a5,a3,80001e7e <fork+0x58>
  np->trapframe->a0 = 0;
    80001e9e:	058a3783          	ld	a5,88(s4)
    80001ea2:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ea6:	0d0a8493          	addi	s1,s5,208
    80001eaa:	0d0a0913          	addi	s2,s4,208
    80001eae:	150a8993          	addi	s3,s5,336
    80001eb2:	a00d                	j	80001ed4 <fork+0xae>
    freeproc(np);
    80001eb4:	8552                	mv	a0,s4
    80001eb6:	00000097          	auipc	ra,0x0
    80001eba:	d32080e7          	jalr	-718(ra) # 80001be8 <freeproc>
    release(&np->lock);
    80001ebe:	8552                	mv	a0,s4
    80001ec0:	fffff097          	auipc	ra,0xfffff
    80001ec4:	e5e080e7          	jalr	-418(ra) # 80000d1e <release>
    return -1;
    80001ec8:	54fd                	li	s1,-1
    80001eca:	a889                	j	80001f1c <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001ecc:	04a1                	addi	s1,s1,8
    80001ece:	0921                	addi	s2,s2,8
    80001ed0:	01348b63          	beq	s1,s3,80001ee6 <fork+0xc0>
    if(p->ofile[i])
    80001ed4:	6088                	ld	a0,0(s1)
    80001ed6:	d97d                	beqz	a0,80001ecc <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ed8:	00002097          	auipc	ra,0x2
    80001edc:	784080e7          	jalr	1924(ra) # 8000465c <filedup>
    80001ee0:	00a93023          	sd	a0,0(s2)
    80001ee4:	b7e5                	j	80001ecc <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ee6:	150ab503          	ld	a0,336(s5)
    80001eea:	00002097          	auipc	ra,0x2
    80001eee:	8f8080e7          	jalr	-1800(ra) # 800037e2 <idup>
    80001ef2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ef6:	4641                	li	a2,16
    80001ef8:	158a8593          	addi	a1,s5,344
    80001efc:	158a0513          	addi	a0,s4,344
    80001f00:	fffff097          	auipc	ra,0xfffff
    80001f04:	fb8080e7          	jalr	-72(ra) # 80000eb8 <safestrcpy>
  pid = np->pid;
    80001f08:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001f0c:	4789                	li	a5,2
    80001f0e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f12:	8552                	mv	a0,s4
    80001f14:	fffff097          	auipc	ra,0xfffff
    80001f18:	e0a080e7          	jalr	-502(ra) # 80000d1e <release>
}
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	70e2                	ld	ra,56(sp)
    80001f20:	7442                	ld	s0,48(sp)
    80001f22:	74a2                	ld	s1,40(sp)
    80001f24:	7902                	ld	s2,32(sp)
    80001f26:	69e2                	ld	s3,24(sp)
    80001f28:	6a42                	ld	s4,16(sp)
    80001f2a:	6aa2                	ld	s5,8(sp)
    80001f2c:	6121                	addi	sp,sp,64
    80001f2e:	8082                	ret
    return -1;
    80001f30:	54fd                	li	s1,-1
    80001f32:	b7ed                	j	80001f1c <fork+0xf6>

0000000080001f34 <reparent>:
{
    80001f34:	7179                	addi	sp,sp,-48
    80001f36:	f406                	sd	ra,40(sp)
    80001f38:	f022                	sd	s0,32(sp)
    80001f3a:	ec26                	sd	s1,24(sp)
    80001f3c:	e84a                	sd	s2,16(sp)
    80001f3e:	e44e                	sd	s3,8(sp)
    80001f40:	e052                	sd	s4,0(sp)
    80001f42:	1800                	addi	s0,sp,48
    80001f44:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f46:	00010497          	auipc	s1,0x10
    80001f4a:	e2248493          	addi	s1,s1,-478 # 80011d68 <proc>
      pp->parent = initproc;
    80001f4e:	00007a17          	auipc	s4,0x7
    80001f52:	0caa0a13          	addi	s4,s4,202 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f56:	00016997          	auipc	s3,0x16
    80001f5a:	21298993          	addi	s3,s3,530 # 80018168 <tickslock>
    80001f5e:	a029                	j	80001f68 <reparent+0x34>
    80001f60:	19048493          	addi	s1,s1,400
    80001f64:	03348363          	beq	s1,s3,80001f8a <reparent+0x56>
    if(pp->parent == p){
    80001f68:	709c                	ld	a5,32(s1)
    80001f6a:	ff279be3          	bne	a5,s2,80001f60 <reparent+0x2c>
      acquire(&pp->lock);
    80001f6e:	8526                	mv	a0,s1
    80001f70:	fffff097          	auipc	ra,0xfffff
    80001f74:	cfa080e7          	jalr	-774(ra) # 80000c6a <acquire>
      pp->parent = initproc;
    80001f78:	000a3783          	ld	a5,0(s4)
    80001f7c:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f7e:	8526                	mv	a0,s1
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	d9e080e7          	jalr	-610(ra) # 80000d1e <release>
    80001f88:	bfe1                	j	80001f60 <reparent+0x2c>
}
    80001f8a:	70a2                	ld	ra,40(sp)
    80001f8c:	7402                	ld	s0,32(sp)
    80001f8e:	64e2                	ld	s1,24(sp)
    80001f90:	6942                	ld	s2,16(sp)
    80001f92:	69a2                	ld	s3,8(sp)
    80001f94:	6a02                	ld	s4,0(sp)
    80001f96:	6145                	addi	sp,sp,48
    80001f98:	8082                	ret

0000000080001f9a <scheduler>:
{
    80001f9a:	715d                	addi	sp,sp,-80
    80001f9c:	e486                	sd	ra,72(sp)
    80001f9e:	e0a2                	sd	s0,64(sp)
    80001fa0:	fc26                	sd	s1,56(sp)
    80001fa2:	f84a                	sd	s2,48(sp)
    80001fa4:	f44e                	sd	s3,40(sp)
    80001fa6:	f052                	sd	s4,32(sp)
    80001fa8:	ec56                	sd	s5,24(sp)
    80001faa:	e85a                	sd	s6,16(sp)
    80001fac:	e45e                	sd	s7,8(sp)
    80001fae:	e062                	sd	s8,0(sp)
    80001fb0:	0880                	addi	s0,sp,80
    80001fb2:	8792                	mv	a5,tp
  int id = r_tp();
    80001fb4:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fb6:	00779b13          	slli	s6,a5,0x7
    80001fba:	00010717          	auipc	a4,0x10
    80001fbe:	99670713          	addi	a4,a4,-1642 # 80011950 <pid_lock>
    80001fc2:	975a                	add	a4,a4,s6
    80001fc4:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001fc8:	00010717          	auipc	a4,0x10
    80001fcc:	9a870713          	addi	a4,a4,-1624 # 80011970 <cpus+0x8>
    80001fd0:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001fd2:	4c0d                	li	s8,3
        c->proc = p;
    80001fd4:	079e                	slli	a5,a5,0x7
    80001fd6:	00010a17          	auipc	s4,0x10
    80001fda:	97aa0a13          	addi	s4,s4,-1670 # 80011950 <pid_lock>
    80001fde:	9a3e                	add	s4,s4,a5
        found = 1;
    80001fe0:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fe2:	00016997          	auipc	s3,0x16
    80001fe6:	18698993          	addi	s3,s3,390 # 80018168 <tickslock>
    80001fea:	a899                	j	80002040 <scheduler+0xa6>
      release(&p->lock);
    80001fec:	8526                	mv	a0,s1
    80001fee:	fffff097          	auipc	ra,0xfffff
    80001ff2:	d30080e7          	jalr	-720(ra) # 80000d1e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ff6:	19048493          	addi	s1,s1,400
    80001ffa:	03348963          	beq	s1,s3,8000202c <scheduler+0x92>
      acquire(&p->lock);
    80001ffe:	8526                	mv	a0,s1
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	c6a080e7          	jalr	-918(ra) # 80000c6a <acquire>
      if(p->state == RUNNABLE) {
    80002008:	4c9c                	lw	a5,24(s1)
    8000200a:	ff2791e3          	bne	a5,s2,80001fec <scheduler+0x52>
        p->state = RUNNING;
    8000200e:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80002012:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80002016:	06048593          	addi	a1,s1,96
    8000201a:	855a                	mv	a0,s6
    8000201c:	00000097          	auipc	ra,0x0
    80002020:	60e080e7          	jalr	1550(ra) # 8000262a <swtch>
        c->proc = 0;
    80002024:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80002028:	8ade                	mv	s5,s7
    8000202a:	b7c9                	j	80001fec <scheduler+0x52>
    if(found == 0) {
    8000202c:	000a9a63          	bnez	s5,80002040 <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002030:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002034:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002038:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000203c:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002040:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002044:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002048:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000204c:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000204e:	00010497          	auipc	s1,0x10
    80002052:	d1a48493          	addi	s1,s1,-742 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    80002056:	4909                	li	s2,2
    80002058:	b75d                	j	80001ffe <scheduler+0x64>

000000008000205a <sched>:
{
    8000205a:	7179                	addi	sp,sp,-48
    8000205c:	f406                	sd	ra,40(sp)
    8000205e:	f022                	sd	s0,32(sp)
    80002060:	ec26                	sd	s1,24(sp)
    80002062:	e84a                	sd	s2,16(sp)
    80002064:	e44e                	sd	s3,8(sp)
    80002066:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002068:	00000097          	auipc	ra,0x0
    8000206c:	9ce080e7          	jalr	-1586(ra) # 80001a36 <myproc>
    80002070:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002072:	fffff097          	auipc	ra,0xfffff
    80002076:	b7e080e7          	jalr	-1154(ra) # 80000bf0 <holding>
    8000207a:	c93d                	beqz	a0,800020f0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000207c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000207e:	2781                	sext.w	a5,a5
    80002080:	079e                	slli	a5,a5,0x7
    80002082:	00010717          	auipc	a4,0x10
    80002086:	8ce70713          	addi	a4,a4,-1842 # 80011950 <pid_lock>
    8000208a:	97ba                	add	a5,a5,a4
    8000208c:	0907a703          	lw	a4,144(a5)
    80002090:	4785                	li	a5,1
    80002092:	06f71763          	bne	a4,a5,80002100 <sched+0xa6>
  if(p->state == RUNNING)
    80002096:	4c98                	lw	a4,24(s1)
    80002098:	478d                	li	a5,3
    8000209a:	06f70b63          	beq	a4,a5,80002110 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000209e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020a2:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020a4:	efb5                	bnez	a5,80002120 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020a6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020a8:	00010917          	auipc	s2,0x10
    800020ac:	8a890913          	addi	s2,s2,-1880 # 80011950 <pid_lock>
    800020b0:	2781                	sext.w	a5,a5
    800020b2:	079e                	slli	a5,a5,0x7
    800020b4:	97ca                	add	a5,a5,s2
    800020b6:	0947a983          	lw	s3,148(a5)
    800020ba:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020bc:	2781                	sext.w	a5,a5
    800020be:	079e                	slli	a5,a5,0x7
    800020c0:	00010597          	auipc	a1,0x10
    800020c4:	8b058593          	addi	a1,a1,-1872 # 80011970 <cpus+0x8>
    800020c8:	95be                	add	a1,a1,a5
    800020ca:	06048513          	addi	a0,s1,96
    800020ce:	00000097          	auipc	ra,0x0
    800020d2:	55c080e7          	jalr	1372(ra) # 8000262a <swtch>
    800020d6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020d8:	2781                	sext.w	a5,a5
    800020da:	079e                	slli	a5,a5,0x7
    800020dc:	97ca                	add	a5,a5,s2
    800020de:	0937aa23          	sw	s3,148(a5)
}
    800020e2:	70a2                	ld	ra,40(sp)
    800020e4:	7402                	ld	s0,32(sp)
    800020e6:	64e2                	ld	s1,24(sp)
    800020e8:	6942                	ld	s2,16(sp)
    800020ea:	69a2                	ld	s3,8(sp)
    800020ec:	6145                	addi	sp,sp,48
    800020ee:	8082                	ret
    panic("sched p->lock");
    800020f0:	00006517          	auipc	a0,0x6
    800020f4:	12850513          	addi	a0,a0,296 # 80008218 <digits+0x1c0>
    800020f8:	ffffe097          	auipc	ra,0xffffe
    800020fc:	44a080e7          	jalr	1098(ra) # 80000542 <panic>
    panic("sched locks");
    80002100:	00006517          	auipc	a0,0x6
    80002104:	12850513          	addi	a0,a0,296 # 80008228 <digits+0x1d0>
    80002108:	ffffe097          	auipc	ra,0xffffe
    8000210c:	43a080e7          	jalr	1082(ra) # 80000542 <panic>
    panic("sched running");
    80002110:	00006517          	auipc	a0,0x6
    80002114:	12850513          	addi	a0,a0,296 # 80008238 <digits+0x1e0>
    80002118:	ffffe097          	auipc	ra,0xffffe
    8000211c:	42a080e7          	jalr	1066(ra) # 80000542 <panic>
    panic("sched interruptible");
    80002120:	00006517          	auipc	a0,0x6
    80002124:	12850513          	addi	a0,a0,296 # 80008248 <digits+0x1f0>
    80002128:	ffffe097          	auipc	ra,0xffffe
    8000212c:	41a080e7          	jalr	1050(ra) # 80000542 <panic>

0000000080002130 <exit>:
{
    80002130:	7179                	addi	sp,sp,-48
    80002132:	f406                	sd	ra,40(sp)
    80002134:	f022                	sd	s0,32(sp)
    80002136:	ec26                	sd	s1,24(sp)
    80002138:	e84a                	sd	s2,16(sp)
    8000213a:	e44e                	sd	s3,8(sp)
    8000213c:	e052                	sd	s4,0(sp)
    8000213e:	1800                	addi	s0,sp,48
    80002140:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002142:	00000097          	auipc	ra,0x0
    80002146:	8f4080e7          	jalr	-1804(ra) # 80001a36 <myproc>
    8000214a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000214c:	00007797          	auipc	a5,0x7
    80002150:	ecc7b783          	ld	a5,-308(a5) # 80009018 <initproc>
    80002154:	0d050493          	addi	s1,a0,208
    80002158:	15050913          	addi	s2,a0,336
    8000215c:	02a79363          	bne	a5,a0,80002182 <exit+0x52>
    panic("init exiting");
    80002160:	00006517          	auipc	a0,0x6
    80002164:	10050513          	addi	a0,a0,256 # 80008260 <digits+0x208>
    80002168:	ffffe097          	auipc	ra,0xffffe
    8000216c:	3da080e7          	jalr	986(ra) # 80000542 <panic>
      fileclose(f);
    80002170:	00002097          	auipc	ra,0x2
    80002174:	53e080e7          	jalr	1342(ra) # 800046ae <fileclose>
      p->ofile[fd] = 0;
    80002178:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000217c:	04a1                	addi	s1,s1,8
    8000217e:	01248563          	beq	s1,s2,80002188 <exit+0x58>
    if(p->ofile[fd]){
    80002182:	6088                	ld	a0,0(s1)
    80002184:	f575                	bnez	a0,80002170 <exit+0x40>
    80002186:	bfdd                	j	8000217c <exit+0x4c>
  begin_op();
    80002188:	00002097          	auipc	ra,0x2
    8000218c:	054080e7          	jalr	84(ra) # 800041dc <begin_op>
  iput(p->cwd);
    80002190:	1509b503          	ld	a0,336(s3)
    80002194:	00002097          	auipc	ra,0x2
    80002198:	846080e7          	jalr	-1978(ra) # 800039da <iput>
  end_op();
    8000219c:	00002097          	auipc	ra,0x2
    800021a0:	0c0080e7          	jalr	192(ra) # 8000425c <end_op>
  p->cwd = 0;
    800021a4:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    800021a8:	00007497          	auipc	s1,0x7
    800021ac:	e7048493          	addi	s1,s1,-400 # 80009018 <initproc>
    800021b0:	6088                	ld	a0,0(s1)
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	ab8080e7          	jalr	-1352(ra) # 80000c6a <acquire>
  wakeup1(initproc);
    800021ba:	6088                	ld	a0,0(s1)
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	73a080e7          	jalr	1850(ra) # 800018f6 <wakeup1>
  release(&initproc->lock);
    800021c4:	6088                	ld	a0,0(s1)
    800021c6:	fffff097          	auipc	ra,0xfffff
    800021ca:	b58080e7          	jalr	-1192(ra) # 80000d1e <release>
  acquire(&p->lock);
    800021ce:	854e                	mv	a0,s3
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	a9a080e7          	jalr	-1382(ra) # 80000c6a <acquire>
  struct proc *original_parent = p->parent;
    800021d8:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800021dc:	854e                	mv	a0,s3
    800021de:	fffff097          	auipc	ra,0xfffff
    800021e2:	b40080e7          	jalr	-1216(ra) # 80000d1e <release>
  acquire(&original_parent->lock);
    800021e6:	8526                	mv	a0,s1
    800021e8:	fffff097          	auipc	ra,0xfffff
    800021ec:	a82080e7          	jalr	-1406(ra) # 80000c6a <acquire>
  acquire(&p->lock);
    800021f0:	854e                	mv	a0,s3
    800021f2:	fffff097          	auipc	ra,0xfffff
    800021f6:	a78080e7          	jalr	-1416(ra) # 80000c6a <acquire>
  reparent(p);
    800021fa:	854e                	mv	a0,s3
    800021fc:	00000097          	auipc	ra,0x0
    80002200:	d38080e7          	jalr	-712(ra) # 80001f34 <reparent>
  wakeup1(original_parent);
    80002204:	8526                	mv	a0,s1
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	6f0080e7          	jalr	1776(ra) # 800018f6 <wakeup1>
  p->xstate = status;
    8000220e:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002212:	4791                	li	a5,4
    80002214:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80002218:	8526                	mv	a0,s1
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	b04080e7          	jalr	-1276(ra) # 80000d1e <release>
  sched();
    80002222:	00000097          	auipc	ra,0x0
    80002226:	e38080e7          	jalr	-456(ra) # 8000205a <sched>
  panic("zombie exit");
    8000222a:	00006517          	auipc	a0,0x6
    8000222e:	04650513          	addi	a0,a0,70 # 80008270 <digits+0x218>
    80002232:	ffffe097          	auipc	ra,0xffffe
    80002236:	310080e7          	jalr	784(ra) # 80000542 <panic>

000000008000223a <yield>:
{
    8000223a:	1101                	addi	sp,sp,-32
    8000223c:	ec06                	sd	ra,24(sp)
    8000223e:	e822                	sd	s0,16(sp)
    80002240:	e426                	sd	s1,8(sp)
    80002242:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	7f2080e7          	jalr	2034(ra) # 80001a36 <myproc>
    8000224c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000224e:	fffff097          	auipc	ra,0xfffff
    80002252:	a1c080e7          	jalr	-1508(ra) # 80000c6a <acquire>
  p->state = RUNNABLE;
    80002256:	4789                	li	a5,2
    80002258:	cc9c                	sw	a5,24(s1)
  sched();
    8000225a:	00000097          	auipc	ra,0x0
    8000225e:	e00080e7          	jalr	-512(ra) # 8000205a <sched>
  release(&p->lock);
    80002262:	8526                	mv	a0,s1
    80002264:	fffff097          	auipc	ra,0xfffff
    80002268:	aba080e7          	jalr	-1350(ra) # 80000d1e <release>
}
    8000226c:	60e2                	ld	ra,24(sp)
    8000226e:	6442                	ld	s0,16(sp)
    80002270:	64a2                	ld	s1,8(sp)
    80002272:	6105                	addi	sp,sp,32
    80002274:	8082                	ret

0000000080002276 <sleep>:
{
    80002276:	7179                	addi	sp,sp,-48
    80002278:	f406                	sd	ra,40(sp)
    8000227a:	f022                	sd	s0,32(sp)
    8000227c:	ec26                	sd	s1,24(sp)
    8000227e:	e84a                	sd	s2,16(sp)
    80002280:	e44e                	sd	s3,8(sp)
    80002282:	1800                	addi	s0,sp,48
    80002284:	89aa                	mv	s3,a0
    80002286:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	7ae080e7          	jalr	1966(ra) # 80001a36 <myproc>
    80002290:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002292:	05250663          	beq	a0,s2,800022de <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	9d4080e7          	jalr	-1580(ra) # 80000c6a <acquire>
    release(lk);
    8000229e:	854a                	mv	a0,s2
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	a7e080e7          	jalr	-1410(ra) # 80000d1e <release>
  p->chan = chan;
    800022a8:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    800022ac:	4785                	li	a5,1
    800022ae:	cc9c                	sw	a5,24(s1)
  sched();
    800022b0:	00000097          	auipc	ra,0x0
    800022b4:	daa080e7          	jalr	-598(ra) # 8000205a <sched>
  p->chan = 0;
    800022b8:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800022bc:	8526                	mv	a0,s1
    800022be:	fffff097          	auipc	ra,0xfffff
    800022c2:	a60080e7          	jalr	-1440(ra) # 80000d1e <release>
    acquire(lk);
    800022c6:	854a                	mv	a0,s2
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	9a2080e7          	jalr	-1630(ra) # 80000c6a <acquire>
}
    800022d0:	70a2                	ld	ra,40(sp)
    800022d2:	7402                	ld	s0,32(sp)
    800022d4:	64e2                	ld	s1,24(sp)
    800022d6:	6942                	ld	s2,16(sp)
    800022d8:	69a2                	ld	s3,8(sp)
    800022da:	6145                	addi	sp,sp,48
    800022dc:	8082                	ret
  p->chan = chan;
    800022de:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800022e2:	4785                	li	a5,1
    800022e4:	cd1c                	sw	a5,24(a0)
  sched();
    800022e6:	00000097          	auipc	ra,0x0
    800022ea:	d74080e7          	jalr	-652(ra) # 8000205a <sched>
  p->chan = 0;
    800022ee:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800022f2:	bff9                	j	800022d0 <sleep+0x5a>

00000000800022f4 <wait>:
{
    800022f4:	715d                	addi	sp,sp,-80
    800022f6:	e486                	sd	ra,72(sp)
    800022f8:	e0a2                	sd	s0,64(sp)
    800022fa:	fc26                	sd	s1,56(sp)
    800022fc:	f84a                	sd	s2,48(sp)
    800022fe:	f44e                	sd	s3,40(sp)
    80002300:	f052                	sd	s4,32(sp)
    80002302:	ec56                	sd	s5,24(sp)
    80002304:	e85a                	sd	s6,16(sp)
    80002306:	e45e                	sd	s7,8(sp)
    80002308:	0880                	addi	s0,sp,80
    8000230a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000230c:	fffff097          	auipc	ra,0xfffff
    80002310:	72a080e7          	jalr	1834(ra) # 80001a36 <myproc>
    80002314:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002316:	fffff097          	auipc	ra,0xfffff
    8000231a:	954080e7          	jalr	-1708(ra) # 80000c6a <acquire>
    havekids = 0;
    8000231e:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002320:	4a11                	li	s4,4
        havekids = 1;
    80002322:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002324:	00016997          	auipc	s3,0x16
    80002328:	e4498993          	addi	s3,s3,-444 # 80018168 <tickslock>
    havekids = 0;
    8000232c:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000232e:	00010497          	auipc	s1,0x10
    80002332:	a3a48493          	addi	s1,s1,-1478 # 80011d68 <proc>
    80002336:	a08d                	j	80002398 <wait+0xa4>
          pid = np->pid;
    80002338:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000233c:	000b0e63          	beqz	s6,80002358 <wait+0x64>
    80002340:	4691                	li	a3,4
    80002342:	03448613          	addi	a2,s1,52
    80002346:	85da                	mv	a1,s6
    80002348:	05093503          	ld	a0,80(s2)
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	3dc080e7          	jalr	988(ra) # 80001728 <copyout>
    80002354:	02054263          	bltz	a0,80002378 <wait+0x84>
          freeproc(np);
    80002358:	8526                	mv	a0,s1
    8000235a:	00000097          	auipc	ra,0x0
    8000235e:	88e080e7          	jalr	-1906(ra) # 80001be8 <freeproc>
          release(&np->lock);
    80002362:	8526                	mv	a0,s1
    80002364:	fffff097          	auipc	ra,0xfffff
    80002368:	9ba080e7          	jalr	-1606(ra) # 80000d1e <release>
          release(&p->lock);
    8000236c:	854a                	mv	a0,s2
    8000236e:	fffff097          	auipc	ra,0xfffff
    80002372:	9b0080e7          	jalr	-1616(ra) # 80000d1e <release>
          return pid;
    80002376:	a8a9                	j	800023d0 <wait+0xdc>
            release(&np->lock);
    80002378:	8526                	mv	a0,s1
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	9a4080e7          	jalr	-1628(ra) # 80000d1e <release>
            release(&p->lock);
    80002382:	854a                	mv	a0,s2
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	99a080e7          	jalr	-1638(ra) # 80000d1e <release>
            return -1;
    8000238c:	59fd                	li	s3,-1
    8000238e:	a089                	j	800023d0 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002390:	19048493          	addi	s1,s1,400
    80002394:	03348463          	beq	s1,s3,800023bc <wait+0xc8>
      if(np->parent == p){
    80002398:	709c                	ld	a5,32(s1)
    8000239a:	ff279be3          	bne	a5,s2,80002390 <wait+0x9c>
        acquire(&np->lock);
    8000239e:	8526                	mv	a0,s1
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	8ca080e7          	jalr	-1846(ra) # 80000c6a <acquire>
        if(np->state == ZOMBIE){
    800023a8:	4c9c                	lw	a5,24(s1)
    800023aa:	f94787e3          	beq	a5,s4,80002338 <wait+0x44>
        release(&np->lock);
    800023ae:	8526                	mv	a0,s1
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	96e080e7          	jalr	-1682(ra) # 80000d1e <release>
        havekids = 1;
    800023b8:	8756                	mv	a4,s5
    800023ba:	bfd9                	j	80002390 <wait+0x9c>
    if(!havekids || p->killed){
    800023bc:	c701                	beqz	a4,800023c4 <wait+0xd0>
    800023be:	03092783          	lw	a5,48(s2)
    800023c2:	c39d                	beqz	a5,800023e8 <wait+0xf4>
      release(&p->lock);
    800023c4:	854a                	mv	a0,s2
    800023c6:	fffff097          	auipc	ra,0xfffff
    800023ca:	958080e7          	jalr	-1704(ra) # 80000d1e <release>
      return -1;
    800023ce:	59fd                	li	s3,-1
}
    800023d0:	854e                	mv	a0,s3
    800023d2:	60a6                	ld	ra,72(sp)
    800023d4:	6406                	ld	s0,64(sp)
    800023d6:	74e2                	ld	s1,56(sp)
    800023d8:	7942                	ld	s2,48(sp)
    800023da:	79a2                	ld	s3,40(sp)
    800023dc:	7a02                	ld	s4,32(sp)
    800023de:	6ae2                	ld	s5,24(sp)
    800023e0:	6b42                	ld	s6,16(sp)
    800023e2:	6ba2                	ld	s7,8(sp)
    800023e4:	6161                	addi	sp,sp,80
    800023e6:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023e8:	85ca                	mv	a1,s2
    800023ea:	854a                	mv	a0,s2
    800023ec:	00000097          	auipc	ra,0x0
    800023f0:	e8a080e7          	jalr	-374(ra) # 80002276 <sleep>
    havekids = 0;
    800023f4:	bf25                	j	8000232c <wait+0x38>

00000000800023f6 <wakeup>:
{
    800023f6:	7139                	addi	sp,sp,-64
    800023f8:	fc06                	sd	ra,56(sp)
    800023fa:	f822                	sd	s0,48(sp)
    800023fc:	f426                	sd	s1,40(sp)
    800023fe:	f04a                	sd	s2,32(sp)
    80002400:	ec4e                	sd	s3,24(sp)
    80002402:	e852                	sd	s4,16(sp)
    80002404:	e456                	sd	s5,8(sp)
    80002406:	0080                	addi	s0,sp,64
    80002408:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000240a:	00010497          	auipc	s1,0x10
    8000240e:	95e48493          	addi	s1,s1,-1698 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002412:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002414:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002416:	00016917          	auipc	s2,0x16
    8000241a:	d5290913          	addi	s2,s2,-686 # 80018168 <tickslock>
    8000241e:	a811                	j	80002432 <wakeup+0x3c>
    release(&p->lock);
    80002420:	8526                	mv	a0,s1
    80002422:	fffff097          	auipc	ra,0xfffff
    80002426:	8fc080e7          	jalr	-1796(ra) # 80000d1e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000242a:	19048493          	addi	s1,s1,400
    8000242e:	03248063          	beq	s1,s2,8000244e <wakeup+0x58>
    acquire(&p->lock);
    80002432:	8526                	mv	a0,s1
    80002434:	fffff097          	auipc	ra,0xfffff
    80002438:	836080e7          	jalr	-1994(ra) # 80000c6a <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000243c:	4c9c                	lw	a5,24(s1)
    8000243e:	ff3791e3          	bne	a5,s3,80002420 <wakeup+0x2a>
    80002442:	749c                	ld	a5,40(s1)
    80002444:	fd479ee3          	bne	a5,s4,80002420 <wakeup+0x2a>
      p->state = RUNNABLE;
    80002448:	0154ac23          	sw	s5,24(s1)
    8000244c:	bfd1                	j	80002420 <wakeup+0x2a>
}
    8000244e:	70e2                	ld	ra,56(sp)
    80002450:	7442                	ld	s0,48(sp)
    80002452:	74a2                	ld	s1,40(sp)
    80002454:	7902                	ld	s2,32(sp)
    80002456:	69e2                	ld	s3,24(sp)
    80002458:	6a42                	ld	s4,16(sp)
    8000245a:	6aa2                	ld	s5,8(sp)
    8000245c:	6121                	addi	sp,sp,64
    8000245e:	8082                	ret

0000000080002460 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002460:	7179                	addi	sp,sp,-48
    80002462:	f406                	sd	ra,40(sp)
    80002464:	f022                	sd	s0,32(sp)
    80002466:	ec26                	sd	s1,24(sp)
    80002468:	e84a                	sd	s2,16(sp)
    8000246a:	e44e                	sd	s3,8(sp)
    8000246c:	1800                	addi	s0,sp,48
    8000246e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002470:	00010497          	auipc	s1,0x10
    80002474:	8f848493          	addi	s1,s1,-1800 # 80011d68 <proc>
    80002478:	00016997          	auipc	s3,0x16
    8000247c:	cf098993          	addi	s3,s3,-784 # 80018168 <tickslock>
    acquire(&p->lock);
    80002480:	8526                	mv	a0,s1
    80002482:	ffffe097          	auipc	ra,0xffffe
    80002486:	7e8080e7          	jalr	2024(ra) # 80000c6a <acquire>
    if(p->pid == pid){
    8000248a:	5c9c                	lw	a5,56(s1)
    8000248c:	01278d63          	beq	a5,s2,800024a6 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002490:	8526                	mv	a0,s1
    80002492:	fffff097          	auipc	ra,0xfffff
    80002496:	88c080e7          	jalr	-1908(ra) # 80000d1e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000249a:	19048493          	addi	s1,s1,400
    8000249e:	ff3491e3          	bne	s1,s3,80002480 <kill+0x20>
  }
  return -1;
    800024a2:	557d                	li	a0,-1
    800024a4:	a821                	j	800024bc <kill+0x5c>
      p->killed = 1;
    800024a6:	4785                	li	a5,1
    800024a8:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800024aa:	4c98                	lw	a4,24(s1)
    800024ac:	00f70f63          	beq	a4,a5,800024ca <kill+0x6a>
      release(&p->lock);
    800024b0:	8526                	mv	a0,s1
    800024b2:	fffff097          	auipc	ra,0xfffff
    800024b6:	86c080e7          	jalr	-1940(ra) # 80000d1e <release>
      return 0;
    800024ba:	4501                	li	a0,0
}
    800024bc:	70a2                	ld	ra,40(sp)
    800024be:	7402                	ld	s0,32(sp)
    800024c0:	64e2                	ld	s1,24(sp)
    800024c2:	6942                	ld	s2,16(sp)
    800024c4:	69a2                	ld	s3,8(sp)
    800024c6:	6145                	addi	sp,sp,48
    800024c8:	8082                	ret
        p->state = RUNNABLE;
    800024ca:	4789                	li	a5,2
    800024cc:	cc9c                	sw	a5,24(s1)
    800024ce:	b7cd                	j	800024b0 <kill+0x50>

00000000800024d0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024d0:	7179                	addi	sp,sp,-48
    800024d2:	f406                	sd	ra,40(sp)
    800024d4:	f022                	sd	s0,32(sp)
    800024d6:	ec26                	sd	s1,24(sp)
    800024d8:	e84a                	sd	s2,16(sp)
    800024da:	e44e                	sd	s3,8(sp)
    800024dc:	e052                	sd	s4,0(sp)
    800024de:	1800                	addi	s0,sp,48
    800024e0:	84aa                	mv	s1,a0
    800024e2:	892e                	mv	s2,a1
    800024e4:	89b2                	mv	s3,a2
    800024e6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024e8:	fffff097          	auipc	ra,0xfffff
    800024ec:	54e080e7          	jalr	1358(ra) # 80001a36 <myproc>
  if(user_dst){
    800024f0:	c08d                	beqz	s1,80002512 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024f2:	86d2                	mv	a3,s4
    800024f4:	864e                	mv	a2,s3
    800024f6:	85ca                	mv	a1,s2
    800024f8:	6928                	ld	a0,80(a0)
    800024fa:	fffff097          	auipc	ra,0xfffff
    800024fe:	22e080e7          	jalr	558(ra) # 80001728 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002502:	70a2                	ld	ra,40(sp)
    80002504:	7402                	ld	s0,32(sp)
    80002506:	64e2                	ld	s1,24(sp)
    80002508:	6942                	ld	s2,16(sp)
    8000250a:	69a2                	ld	s3,8(sp)
    8000250c:	6a02                	ld	s4,0(sp)
    8000250e:	6145                	addi	sp,sp,48
    80002510:	8082                	ret
    memmove((char *)dst, src, len);
    80002512:	000a061b          	sext.w	a2,s4
    80002516:	85ce                	mv	a1,s3
    80002518:	854a                	mv	a0,s2
    8000251a:	fffff097          	auipc	ra,0xfffff
    8000251e:	8a8080e7          	jalr	-1880(ra) # 80000dc2 <memmove>
    return 0;
    80002522:	8526                	mv	a0,s1
    80002524:	bff9                	j	80002502 <either_copyout+0x32>

0000000080002526 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002526:	7179                	addi	sp,sp,-48
    80002528:	f406                	sd	ra,40(sp)
    8000252a:	f022                	sd	s0,32(sp)
    8000252c:	ec26                	sd	s1,24(sp)
    8000252e:	e84a                	sd	s2,16(sp)
    80002530:	e44e                	sd	s3,8(sp)
    80002532:	e052                	sd	s4,0(sp)
    80002534:	1800                	addi	s0,sp,48
    80002536:	892a                	mv	s2,a0
    80002538:	84ae                	mv	s1,a1
    8000253a:	89b2                	mv	s3,a2
    8000253c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000253e:	fffff097          	auipc	ra,0xfffff
    80002542:	4f8080e7          	jalr	1272(ra) # 80001a36 <myproc>
  if(user_src){
    80002546:	c08d                	beqz	s1,80002568 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002548:	86d2                	mv	a3,s4
    8000254a:	864e                	mv	a2,s3
    8000254c:	85ca                	mv	a1,s2
    8000254e:	6928                	ld	a0,80(a0)
    80002550:	fffff097          	auipc	ra,0xfffff
    80002554:	264080e7          	jalr	612(ra) # 800017b4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002558:	70a2                	ld	ra,40(sp)
    8000255a:	7402                	ld	s0,32(sp)
    8000255c:	64e2                	ld	s1,24(sp)
    8000255e:	6942                	ld	s2,16(sp)
    80002560:	69a2                	ld	s3,8(sp)
    80002562:	6a02                	ld	s4,0(sp)
    80002564:	6145                	addi	sp,sp,48
    80002566:	8082                	ret
    memmove(dst, (char*)src, len);
    80002568:	000a061b          	sext.w	a2,s4
    8000256c:	85ce                	mv	a1,s3
    8000256e:	854a                	mv	a0,s2
    80002570:	fffff097          	auipc	ra,0xfffff
    80002574:	852080e7          	jalr	-1966(ra) # 80000dc2 <memmove>
    return 0;
    80002578:	8526                	mv	a0,s1
    8000257a:	bff9                	j	80002558 <either_copyin+0x32>

000000008000257c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000257c:	715d                	addi	sp,sp,-80
    8000257e:	e486                	sd	ra,72(sp)
    80002580:	e0a2                	sd	s0,64(sp)
    80002582:	fc26                	sd	s1,56(sp)
    80002584:	f84a                	sd	s2,48(sp)
    80002586:	f44e                	sd	s3,40(sp)
    80002588:	f052                	sd	s4,32(sp)
    8000258a:	ec56                	sd	s5,24(sp)
    8000258c:	e85a                	sd	s6,16(sp)
    8000258e:	e45e                	sd	s7,8(sp)
    80002590:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002592:	00006517          	auipc	a0,0x6
    80002596:	b4e50513          	addi	a0,a0,-1202 # 800080e0 <digits+0x88>
    8000259a:	ffffe097          	auipc	ra,0xffffe
    8000259e:	ff2080e7          	jalr	-14(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025a2:	00010497          	auipc	s1,0x10
    800025a6:	91e48493          	addi	s1,s1,-1762 # 80011ec0 <proc+0x158>
    800025aa:	00016917          	auipc	s2,0x16
    800025ae:	d1690913          	addi	s2,s2,-746 # 800182c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025b2:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800025b4:	00006997          	auipc	s3,0x6
    800025b8:	ccc98993          	addi	s3,s3,-820 # 80008280 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    800025bc:	00006a97          	auipc	s5,0x6
    800025c0:	ccca8a93          	addi	s5,s5,-820 # 80008288 <digits+0x230>
    printf("\n");
    800025c4:	00006a17          	auipc	s4,0x6
    800025c8:	b1ca0a13          	addi	s4,s4,-1252 # 800080e0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025cc:	00006b97          	auipc	s7,0x6
    800025d0:	cf4b8b93          	addi	s7,s7,-780 # 800082c0 <states.0>
    800025d4:	a00d                	j	800025f6 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025d6:	ee06a583          	lw	a1,-288(a3)
    800025da:	8556                	mv	a0,s5
    800025dc:	ffffe097          	auipc	ra,0xffffe
    800025e0:	fb0080e7          	jalr	-80(ra) # 8000058c <printf>
    printf("\n");
    800025e4:	8552                	mv	a0,s4
    800025e6:	ffffe097          	auipc	ra,0xffffe
    800025ea:	fa6080e7          	jalr	-90(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025ee:	19048493          	addi	s1,s1,400
    800025f2:	03248163          	beq	s1,s2,80002614 <procdump+0x98>
    if(p->state == UNUSED)
    800025f6:	86a6                	mv	a3,s1
    800025f8:	ec04a783          	lw	a5,-320(s1)
    800025fc:	dbed                	beqz	a5,800025ee <procdump+0x72>
      state = "???";
    800025fe:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002600:	fcfb6be3          	bltu	s6,a5,800025d6 <procdump+0x5a>
    80002604:	1782                	slli	a5,a5,0x20
    80002606:	9381                	srli	a5,a5,0x20
    80002608:	078e                	slli	a5,a5,0x3
    8000260a:	97de                	add	a5,a5,s7
    8000260c:	6390                	ld	a2,0(a5)
    8000260e:	f661                	bnez	a2,800025d6 <procdump+0x5a>
      state = "???";
    80002610:	864e                	mv	a2,s3
    80002612:	b7d1                	j	800025d6 <procdump+0x5a>
  }
}
    80002614:	60a6                	ld	ra,72(sp)
    80002616:	6406                	ld	s0,64(sp)
    80002618:	74e2                	ld	s1,56(sp)
    8000261a:	7942                	ld	s2,48(sp)
    8000261c:	79a2                	ld	s3,40(sp)
    8000261e:	7a02                	ld	s4,32(sp)
    80002620:	6ae2                	ld	s5,24(sp)
    80002622:	6b42                	ld	s6,16(sp)
    80002624:	6ba2                	ld	s7,8(sp)
    80002626:	6161                	addi	sp,sp,80
    80002628:	8082                	ret

000000008000262a <swtch>:
    8000262a:	00153023          	sd	ra,0(a0)
    8000262e:	00253423          	sd	sp,8(a0)
    80002632:	e900                	sd	s0,16(a0)
    80002634:	ed04                	sd	s1,24(a0)
    80002636:	03253023          	sd	s2,32(a0)
    8000263a:	03353423          	sd	s3,40(a0)
    8000263e:	03453823          	sd	s4,48(a0)
    80002642:	03553c23          	sd	s5,56(a0)
    80002646:	05653023          	sd	s6,64(a0)
    8000264a:	05753423          	sd	s7,72(a0)
    8000264e:	05853823          	sd	s8,80(a0)
    80002652:	05953c23          	sd	s9,88(a0)
    80002656:	07a53023          	sd	s10,96(a0)
    8000265a:	07b53423          	sd	s11,104(a0)
    8000265e:	0005b083          	ld	ra,0(a1)
    80002662:	0085b103          	ld	sp,8(a1)
    80002666:	6980                	ld	s0,16(a1)
    80002668:	6d84                	ld	s1,24(a1)
    8000266a:	0205b903          	ld	s2,32(a1)
    8000266e:	0285b983          	ld	s3,40(a1)
    80002672:	0305ba03          	ld	s4,48(a1)
    80002676:	0385ba83          	ld	s5,56(a1)
    8000267a:	0405bb03          	ld	s6,64(a1)
    8000267e:	0485bb83          	ld	s7,72(a1)
    80002682:	0505bc03          	ld	s8,80(a1)
    80002686:	0585bc83          	ld	s9,88(a1)
    8000268a:	0605bd03          	ld	s10,96(a1)
    8000268e:	0685bd83          	ld	s11,104(a1)
    80002692:	8082                	ret

0000000080002694 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002694:	1141                	addi	sp,sp,-16
    80002696:	e406                	sd	ra,8(sp)
    80002698:	e022                	sd	s0,0(sp)
    8000269a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000269c:	00006597          	auipc	a1,0x6
    800026a0:	c4c58593          	addi	a1,a1,-948 # 800082e8 <states.0+0x28>
    800026a4:	00016517          	auipc	a0,0x16
    800026a8:	ac450513          	addi	a0,a0,-1340 # 80018168 <tickslock>
    800026ac:	ffffe097          	auipc	ra,0xffffe
    800026b0:	52e080e7          	jalr	1326(ra) # 80000bda <initlock>
}
    800026b4:	60a2                	ld	ra,8(sp)
    800026b6:	6402                	ld	s0,0(sp)
    800026b8:	0141                	addi	sp,sp,16
    800026ba:	8082                	ret

00000000800026bc <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026bc:	1141                	addi	sp,sp,-16
    800026be:	e422                	sd	s0,8(sp)
    800026c0:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026c2:	00003797          	auipc	a5,0x3
    800026c6:	64e78793          	addi	a5,a5,1614 # 80005d10 <kernelvec>
    800026ca:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026ce:	6422                	ld	s0,8(sp)
    800026d0:	0141                	addi	sp,sp,16
    800026d2:	8082                	ret

00000000800026d4 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026d4:	1141                	addi	sp,sp,-16
    800026d6:	e406                	sd	ra,8(sp)
    800026d8:	e022                	sd	s0,0(sp)
    800026da:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026dc:	fffff097          	auipc	ra,0xfffff
    800026e0:	35a080e7          	jalr	858(ra) # 80001a36 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026e4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026e8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ea:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026ee:	00005617          	auipc	a2,0x5
    800026f2:	91260613          	addi	a2,a2,-1774 # 80007000 <_trampoline>
    800026f6:	00005697          	auipc	a3,0x5
    800026fa:	90a68693          	addi	a3,a3,-1782 # 80007000 <_trampoline>
    800026fe:	8e91                	sub	a3,a3,a2
    80002700:	040007b7          	lui	a5,0x4000
    80002704:	17fd                	addi	a5,a5,-1
    80002706:	07b2                	slli	a5,a5,0xc
    80002708:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000270a:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000270e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002710:	180026f3          	csrr	a3,satp
    80002714:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002716:	6d38                	ld	a4,88(a0)
    80002718:	6134                	ld	a3,64(a0)
    8000271a:	6585                	lui	a1,0x1
    8000271c:	96ae                	add	a3,a3,a1
    8000271e:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002720:	6d38                	ld	a4,88(a0)
    80002722:	00000697          	auipc	a3,0x0
    80002726:	2ac68693          	addi	a3,a3,684 # 800029ce <usertrap>
    8000272a:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000272c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000272e:	8692                	mv	a3,tp
    80002730:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002732:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002736:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000273a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000273e:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002742:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002744:	6f18                	ld	a4,24(a4)
    80002746:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000274a:	692c                	ld	a1,80(a0)
    8000274c:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000274e:	00005717          	auipc	a4,0x5
    80002752:	94270713          	addi	a4,a4,-1726 # 80007090 <userret>
    80002756:	8f11                	sub	a4,a4,a2
    80002758:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000275a:	577d                	li	a4,-1
    8000275c:	177e                	slli	a4,a4,0x3f
    8000275e:	8dd9                	or	a1,a1,a4
    80002760:	02000537          	lui	a0,0x2000
    80002764:	157d                	addi	a0,a0,-1
    80002766:	0536                	slli	a0,a0,0xd
    80002768:	9782                	jalr	a5
}
    8000276a:	60a2                	ld	ra,8(sp)
    8000276c:	6402                	ld	s0,0(sp)
    8000276e:	0141                	addi	sp,sp,16
    80002770:	8082                	ret

0000000080002772 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002772:	1101                	addi	sp,sp,-32
    80002774:	ec06                	sd	ra,24(sp)
    80002776:	e822                	sd	s0,16(sp)
    80002778:	e426                	sd	s1,8(sp)
    8000277a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000277c:	00016497          	auipc	s1,0x16
    80002780:	9ec48493          	addi	s1,s1,-1556 # 80018168 <tickslock>
    80002784:	8526                	mv	a0,s1
    80002786:	ffffe097          	auipc	ra,0xffffe
    8000278a:	4e4080e7          	jalr	1252(ra) # 80000c6a <acquire>
  ticks++;
    8000278e:	00007517          	auipc	a0,0x7
    80002792:	89250513          	addi	a0,a0,-1902 # 80009020 <ticks>
    80002796:	411c                	lw	a5,0(a0)
    80002798:	2785                	addiw	a5,a5,1
    8000279a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000279c:	00000097          	auipc	ra,0x0
    800027a0:	c5a080e7          	jalr	-934(ra) # 800023f6 <wakeup>
  release(&tickslock);
    800027a4:	8526                	mv	a0,s1
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	578080e7          	jalr	1400(ra) # 80000d1e <release>
}
    800027ae:	60e2                	ld	ra,24(sp)
    800027b0:	6442                	ld	s0,16(sp)
    800027b2:	64a2                	ld	s1,8(sp)
    800027b4:	6105                	addi	sp,sp,32
    800027b6:	8082                	ret

00000000800027b8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027b8:	1101                	addi	sp,sp,-32
    800027ba:	ec06                	sd	ra,24(sp)
    800027bc:	e822                	sd	s0,16(sp)
    800027be:	e426                	sd	s1,8(sp)
    800027c0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027c2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027c6:	00074d63          	bltz	a4,800027e0 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027ca:	57fd                	li	a5,-1
    800027cc:	17fe                	slli	a5,a5,0x3f
    800027ce:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027d0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027d2:	06f70363          	beq	a4,a5,80002838 <devintr+0x80>
  }
}
    800027d6:	60e2                	ld	ra,24(sp)
    800027d8:	6442                	ld	s0,16(sp)
    800027da:	64a2                	ld	s1,8(sp)
    800027dc:	6105                	addi	sp,sp,32
    800027de:	8082                	ret
     (scause & 0xff) == 9){
    800027e0:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800027e4:	46a5                	li	a3,9
    800027e6:	fed792e3          	bne	a5,a3,800027ca <devintr+0x12>
    int irq = plic_claim();
    800027ea:	00003097          	auipc	ra,0x3
    800027ee:	62e080e7          	jalr	1582(ra) # 80005e18 <plic_claim>
    800027f2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027f4:	47a9                	li	a5,10
    800027f6:	02f50763          	beq	a0,a5,80002824 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027fa:	4785                	li	a5,1
    800027fc:	02f50963          	beq	a0,a5,8000282e <devintr+0x76>
    return 1;
    80002800:	4505                	li	a0,1
    } else if(irq){
    80002802:	d8f1                	beqz	s1,800027d6 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002804:	85a6                	mv	a1,s1
    80002806:	00006517          	auipc	a0,0x6
    8000280a:	aea50513          	addi	a0,a0,-1302 # 800082f0 <states.0+0x30>
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	d7e080e7          	jalr	-642(ra) # 8000058c <printf>
      plic_complete(irq);
    80002816:	8526                	mv	a0,s1
    80002818:	00003097          	auipc	ra,0x3
    8000281c:	624080e7          	jalr	1572(ra) # 80005e3c <plic_complete>
    return 1;
    80002820:	4505                	li	a0,1
    80002822:	bf55                	j	800027d6 <devintr+0x1e>
      uartintr();
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	20a080e7          	jalr	522(ra) # 80000a2e <uartintr>
    8000282c:	b7ed                	j	80002816 <devintr+0x5e>
      virtio_disk_intr();
    8000282e:	00004097          	auipc	ra,0x4
    80002832:	a88080e7          	jalr	-1400(ra) # 800062b6 <virtio_disk_intr>
    80002836:	b7c5                	j	80002816 <devintr+0x5e>
    if(cpuid() == 0){
    80002838:	fffff097          	auipc	ra,0xfffff
    8000283c:	1d2080e7          	jalr	466(ra) # 80001a0a <cpuid>
    80002840:	c901                	beqz	a0,80002850 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002842:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002846:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002848:	14479073          	csrw	sip,a5
    return 2;
    8000284c:	4509                	li	a0,2
    8000284e:	b761                	j	800027d6 <devintr+0x1e>
      clockintr();
    80002850:	00000097          	auipc	ra,0x0
    80002854:	f22080e7          	jalr	-222(ra) # 80002772 <clockintr>
    80002858:	b7ed                	j	80002842 <devintr+0x8a>

000000008000285a <kerneltrap>:
{
    8000285a:	7179                	addi	sp,sp,-48
    8000285c:	f406                	sd	ra,40(sp)
    8000285e:	f022                	sd	s0,32(sp)
    80002860:	ec26                	sd	s1,24(sp)
    80002862:	e84a                	sd	s2,16(sp)
    80002864:	e44e                	sd	s3,8(sp)
    80002866:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002868:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000286c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002870:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002874:	1004f793          	andi	a5,s1,256
    80002878:	cb85                	beqz	a5,800028a8 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000287a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000287e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002880:	ef85                	bnez	a5,800028b8 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002882:	00000097          	auipc	ra,0x0
    80002886:	f36080e7          	jalr	-202(ra) # 800027b8 <devintr>
    8000288a:	cd1d                	beqz	a0,800028c8 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000288c:	4789                	li	a5,2
    8000288e:	06f50a63          	beq	a0,a5,80002902 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002892:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002896:	10049073          	csrw	sstatus,s1
}
    8000289a:	70a2                	ld	ra,40(sp)
    8000289c:	7402                	ld	s0,32(sp)
    8000289e:	64e2                	ld	s1,24(sp)
    800028a0:	6942                	ld	s2,16(sp)
    800028a2:	69a2                	ld	s3,8(sp)
    800028a4:	6145                	addi	sp,sp,48
    800028a6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028a8:	00006517          	auipc	a0,0x6
    800028ac:	a6850513          	addi	a0,a0,-1432 # 80008310 <states.0+0x50>
    800028b0:	ffffe097          	auipc	ra,0xffffe
    800028b4:	c92080e7          	jalr	-878(ra) # 80000542 <panic>
    panic("kerneltrap: interrupts enabled");
    800028b8:	00006517          	auipc	a0,0x6
    800028bc:	a8050513          	addi	a0,a0,-1408 # 80008338 <states.0+0x78>
    800028c0:	ffffe097          	auipc	ra,0xffffe
    800028c4:	c82080e7          	jalr	-894(ra) # 80000542 <panic>
    printf("scause %p\n", scause);
    800028c8:	85ce                	mv	a1,s3
    800028ca:	00006517          	auipc	a0,0x6
    800028ce:	a8e50513          	addi	a0,a0,-1394 # 80008358 <states.0+0x98>
    800028d2:	ffffe097          	auipc	ra,0xffffe
    800028d6:	cba080e7          	jalr	-838(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028da:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028de:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028e2:	00006517          	auipc	a0,0x6
    800028e6:	a8650513          	addi	a0,a0,-1402 # 80008368 <states.0+0xa8>
    800028ea:	ffffe097          	auipc	ra,0xffffe
    800028ee:	ca2080e7          	jalr	-862(ra) # 8000058c <printf>
    panic("kerneltrap");
    800028f2:	00006517          	auipc	a0,0x6
    800028f6:	a8e50513          	addi	a0,a0,-1394 # 80008380 <states.0+0xc0>
    800028fa:	ffffe097          	auipc	ra,0xffffe
    800028fe:	c48080e7          	jalr	-952(ra) # 80000542 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002902:	fffff097          	auipc	ra,0xfffff
    80002906:	134080e7          	jalr	308(ra) # 80001a36 <myproc>
    8000290a:	d541                	beqz	a0,80002892 <kerneltrap+0x38>
    8000290c:	fffff097          	auipc	ra,0xfffff
    80002910:	12a080e7          	jalr	298(ra) # 80001a36 <myproc>
    80002914:	4d18                	lw	a4,24(a0)
    80002916:	478d                	li	a5,3
    80002918:	f6f71de3          	bne	a4,a5,80002892 <kerneltrap+0x38>
    yield();
    8000291c:	00000097          	auipc	ra,0x0
    80002920:	91e080e7          	jalr	-1762(ra) # 8000223a <yield>
    80002924:	b7bd                	j	80002892 <kerneltrap+0x38>

0000000080002926 <switchTrapframe>:
void switchTrapframe(struct trapframe* trapframe,struct trapframe* trapframeSave){
    80002926:	1141                	addi	sp,sp,-16
    80002928:	e422                	sd	s0,8(sp)
    8000292a:	0800                	addi	s0,sp,16
trapframe->kernel_satp = trapframeSave ->kernel_satp ;
    8000292c:	619c                	ld	a5,0(a1)
    8000292e:	e11c                	sd	a5,0(a0)
trapframe->kernel_sp = trapframeSave ->kernel_sp;
    80002930:	659c                	ld	a5,8(a1)
    80002932:	e51c                	sd	a5,8(a0)
trapframe->epc = trapframeSave ->epc;
    80002934:	6d9c                	ld	a5,24(a1)
    80002936:	ed1c                	sd	a5,24(a0)
trapframe->kernel_hartid = trapframeSave->kernel_hartid;
    80002938:	719c                	ld	a5,32(a1)
    8000293a:	f11c                	sd	a5,32(a0)
trapframe->ra = trapframeSave->ra;
    8000293c:	759c                	ld	a5,40(a1)
    8000293e:	f51c                	sd	a5,40(a0)
trapframe->sp = trapframeSave->sp;
    80002940:	799c                	ld	a5,48(a1)
    80002942:	f91c                	sd	a5,48(a0)
trapframe->gp = trapframeSave->gp;
    80002944:	7d9c                	ld	a5,56(a1)
    80002946:	fd1c                	sd	a5,56(a0)
trapframe->tp = trapframeSave->tp;
    80002948:	61bc                	ld	a5,64(a1)
    8000294a:	e13c                	sd	a5,64(a0)
trapframe->t0 = trapframeSave->t0;
    8000294c:	65bc                	ld	a5,72(a1)
    8000294e:	e53c                	sd	a5,72(a0)
trapframe->t1 = trapframeSave->t1;
    80002950:	69bc                	ld	a5,80(a1)
    80002952:	e93c                	sd	a5,80(a0)
trapframe->t2 = trapframeSave->t2;
    80002954:	6dbc                	ld	a5,88(a1)
    80002956:	ed3c                	sd	a5,88(a0)
trapframe->s0 = trapframeSave->s0;
    80002958:	71bc                	ld	a5,96(a1)
    8000295a:	f13c                	sd	a5,96(a0)
trapframe->s1 = trapframeSave->s1;
    8000295c:	75bc                	ld	a5,104(a1)
    8000295e:	f53c                	sd	a5,104(a0)
trapframe->a0 = trapframeSave->a0;
    80002960:	79bc                	ld	a5,112(a1)
    80002962:	f93c                	sd	a5,112(a0)
trapframe->a1 = trapframeSave->a1;
    80002964:	7dbc                	ld	a5,120(a1)
    80002966:	fd3c                	sd	a5,120(a0)
trapframe->a2 = trapframeSave->a2;
    80002968:	61dc                	ld	a5,128(a1)
    8000296a:	e15c                	sd	a5,128(a0)
trapframe->a3 = trapframeSave->a3;
    8000296c:	65dc                	ld	a5,136(a1)
    8000296e:	e55c                	sd	a5,136(a0)
trapframe->a4 = trapframeSave->a4;
    80002970:	69dc                	ld	a5,144(a1)
    80002972:	e95c                	sd	a5,144(a0)
trapframe->a5 = trapframeSave->a5;
    80002974:	6ddc                	ld	a5,152(a1)
    80002976:	ed5c                	sd	a5,152(a0)
trapframe->a6 = trapframeSave->a6;
    80002978:	71dc                	ld	a5,160(a1)
    8000297a:	f15c                	sd	a5,160(a0)
trapframe->a7 = trapframeSave->a7;
    8000297c:	75dc                	ld	a5,168(a1)
    8000297e:	f55c                	sd	a5,168(a0)
trapframe->s2 = trapframeSave->s2;
    80002980:	79dc                	ld	a5,176(a1)
    80002982:	f95c                	sd	a5,176(a0)
trapframe->s3 = trapframeSave->s3;
    80002984:	7ddc                	ld	a5,184(a1)
    80002986:	fd5c                	sd	a5,184(a0)
trapframe->s4 = trapframeSave->s4;
    80002988:	61fc                	ld	a5,192(a1)
    8000298a:	e17c                	sd	a5,192(a0)
trapframe->s5 = trapframeSave->s5;
    8000298c:	65fc                	ld	a5,200(a1)
    8000298e:	e57c                	sd	a5,200(a0)
trapframe->s6 = trapframeSave->s6;
    80002990:	69fc                	ld	a5,208(a1)
    80002992:	e97c                	sd	a5,208(a0)
trapframe->s7 = trapframeSave->s7;
    80002994:	6dfc                	ld	a5,216(a1)
    80002996:	ed7c                	sd	a5,216(a0)
trapframe->s8 = trapframeSave->s8;
    80002998:	71fc                	ld	a5,224(a1)
    8000299a:	f17c                	sd	a5,224(a0)
trapframe->s9 = trapframeSave->s9;
    8000299c:	75fc                	ld	a5,232(a1)
    8000299e:	f57c                	sd	a5,232(a0)
trapframe->s10 =trapframeSave->s10;
    800029a0:	79fc                	ld	a5,240(a1)
    800029a2:	f97c                	sd	a5,240(a0)
trapframe->s11 =trapframeSave->s11;
    800029a4:	7dfc                	ld	a5,248(a1)
    800029a6:	fd7c                	sd	a5,248(a0)
trapframe->t3 = trapframeSave->t3;
    800029a8:	1005b783          	ld	a5,256(a1) # 1100 <_entry-0x7fffef00>
    800029ac:	10f53023          	sd	a5,256(a0)
trapframe->t4 = trapframeSave->t4;
    800029b0:	1085b783          	ld	a5,264(a1)
    800029b4:	10f53423          	sd	a5,264(a0)
trapframe->t5 = trapframeSave->t5;
    800029b8:	1105b783          	ld	a5,272(a1)
    800029bc:	10f53823          	sd	a5,272(a0)
trapframe->t6 = trapframeSave->t6;
    800029c0:	1185b783          	ld	a5,280(a1)
    800029c4:	10f53c23          	sd	a5,280(a0)
}
    800029c8:	6422                	ld	s0,8(sp)
    800029ca:	0141                	addi	sp,sp,16
    800029cc:	8082                	ret

00000000800029ce <usertrap>:
{
    800029ce:	1101                	addi	sp,sp,-32
    800029d0:	ec06                	sd	ra,24(sp)
    800029d2:	e822                	sd	s0,16(sp)
    800029d4:	e426                	sd	s1,8(sp)
    800029d6:	e04a                	sd	s2,0(sp)
    800029d8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029da:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800029de:	1007f793          	andi	a5,a5,256
    800029e2:	e3b5                	bnez	a5,80002a46 <usertrap+0x78>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029e4:	00003797          	auipc	a5,0x3
    800029e8:	32c78793          	addi	a5,a5,812 # 80005d10 <kernelvec>
    800029ec:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029f0:	fffff097          	auipc	ra,0xfffff
    800029f4:	046080e7          	jalr	70(ra) # 80001a36 <myproc>
    800029f8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800029fa:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029fc:	14102773          	csrr	a4,sepc
    80002a00:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a02:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a06:	47a1                	li	a5,8
    80002a08:	04f71d63          	bne	a4,a5,80002a62 <usertrap+0x94>
    if(p->killed)
    80002a0c:	591c                	lw	a5,48(a0)
    80002a0e:	e7a1                	bnez	a5,80002a56 <usertrap+0x88>
    p->trapframe->epc += 4;
    80002a10:	6cb8                	ld	a4,88(s1)
    80002a12:	6f1c                	ld	a5,24(a4)
    80002a14:	0791                	addi	a5,a5,4
    80002a16:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a18:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a1c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a20:	10079073          	csrw	sstatus,a5
    syscall();
    80002a24:	00000097          	auipc	ra,0x0
    80002a28:	26a080e7          	jalr	618(ra) # 80002c8e <syscall>
  int which_dev = 0;
    80002a2c:	4901                	li	s2,0
  if(p->killed)
    80002a2e:	589c                	lw	a5,48(s1)
    80002a30:	e7f9                	bnez	a5,80002afe <usertrap+0x130>
  usertrapret();
    80002a32:	00000097          	auipc	ra,0x0
    80002a36:	ca2080e7          	jalr	-862(ra) # 800026d4 <usertrapret>
}
    80002a3a:	60e2                	ld	ra,24(sp)
    80002a3c:	6442                	ld	s0,16(sp)
    80002a3e:	64a2                	ld	s1,8(sp)
    80002a40:	6902                	ld	s2,0(sp)
    80002a42:	6105                	addi	sp,sp,32
    80002a44:	8082                	ret
    panic("usertrap: not from user mode");
    80002a46:	00006517          	auipc	a0,0x6
    80002a4a:	94a50513          	addi	a0,a0,-1718 # 80008390 <states.0+0xd0>
    80002a4e:	ffffe097          	auipc	ra,0xffffe
    80002a52:	af4080e7          	jalr	-1292(ra) # 80000542 <panic>
      exit(-1);
    80002a56:	557d                	li	a0,-1
    80002a58:	fffff097          	auipc	ra,0xfffff
    80002a5c:	6d8080e7          	jalr	1752(ra) # 80002130 <exit>
    80002a60:	bf45                	j	80002a10 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002a62:	00000097          	auipc	ra,0x0
    80002a66:	d56080e7          	jalr	-682(ra) # 800027b8 <devintr>
    80002a6a:	892a                	mv	s2,a0
    80002a6c:	c931                	beqz	a0,80002ac0 <usertrap+0xf2>
      if(which_dev==2&& p->waitReturn==0){
    80002a6e:	4789                	li	a5,2
    80002a70:	faf51fe3          	bne	a0,a5,80002a2e <usertrap+0x60>
    80002a74:	1884a783          	lw	a5,392(s1)
    80002a78:	eb99                	bnez	a5,80002a8e <usertrap+0xc0>
        if(p->interval!=0){
    80002a7a:	1684b783          	ld	a5,360(s1)
    80002a7e:	cb81                	beqz	a5,80002a8e <usertrap+0xc0>
         p->spend=p->spend+1;
    80002a80:	1784b703          	ld	a4,376(s1)
    80002a84:	0705                	addi	a4,a4,1
    80002a86:	16e4bc23          	sd	a4,376(s1)
         if(p->spend==p->interval){
    80002a8a:	00e78a63          	beq	a5,a4,80002a9e <usertrap+0xd0>
  if(p->killed)
    80002a8e:	589c                	lw	a5,48(s1)
    80002a90:	cfbd                	beqz	a5,80002b0e <usertrap+0x140>
    exit(-1);
    80002a92:	557d                	li	a0,-1
    80002a94:	fffff097          	auipc	ra,0xfffff
    80002a98:	69c080e7          	jalr	1692(ra) # 80002130 <exit>
  if(which_dev == 2)
    80002a9c:	a88d                	j	80002b0e <usertrap+0x140>
          switchTrapframe(p->trapframeSave,p->trapframe);
    80002a9e:	6cac                	ld	a1,88(s1)
    80002aa0:	1804b503          	ld	a0,384(s1)
    80002aa4:	00000097          	auipc	ra,0x0
    80002aa8:	e82080e7          	jalr	-382(ra) # 80002926 <switchTrapframe>
          p->spend=0;
    80002aac:	1604bc23          	sd	zero,376(s1)
          p->trapframe->epc=(uint64)p->handler;
    80002ab0:	6cbc                	ld	a5,88(s1)
    80002ab2:	1704b703          	ld	a4,368(s1)
    80002ab6:	ef98                	sd	a4,24(a5)
          p->waitReturn=1;
    80002ab8:	4785                	li	a5,1
    80002aba:	18f4a423          	sw	a5,392(s1)
    80002abe:	bfc1                	j	80002a8e <usertrap+0xc0>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ac0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ac4:	5c90                	lw	a2,56(s1)
    80002ac6:	00006517          	auipc	a0,0x6
    80002aca:	8ea50513          	addi	a0,a0,-1814 # 800083b0 <states.0+0xf0>
    80002ace:	ffffe097          	auipc	ra,0xffffe
    80002ad2:	abe080e7          	jalr	-1346(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ad6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ada:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ade:	00006517          	auipc	a0,0x6
    80002ae2:	90250513          	addi	a0,a0,-1790 # 800083e0 <states.0+0x120>
    80002ae6:	ffffe097          	auipc	ra,0xffffe
    80002aea:	aa6080e7          	jalr	-1370(ra) # 8000058c <printf>
    p->killed = 1;
    80002aee:	4785                	li	a5,1
    80002af0:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002af2:	557d                	li	a0,-1
    80002af4:	fffff097          	auipc	ra,0xfffff
    80002af8:	63c080e7          	jalr	1596(ra) # 80002130 <exit>
  if(which_dev == 2)
    80002afc:	bf1d                	j	80002a32 <usertrap+0x64>
    exit(-1);
    80002afe:	557d                	li	a0,-1
    80002b00:	fffff097          	auipc	ra,0xfffff
    80002b04:	630080e7          	jalr	1584(ra) # 80002130 <exit>
  if(which_dev == 2)
    80002b08:	4789                	li	a5,2
    80002b0a:	f2f914e3          	bne	s2,a5,80002a32 <usertrap+0x64>
    yield();
    80002b0e:	fffff097          	auipc	ra,0xfffff
    80002b12:	72c080e7          	jalr	1836(ra) # 8000223a <yield>
    80002b16:	bf31                	j	80002a32 <usertrap+0x64>

0000000080002b18 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b18:	1101                	addi	sp,sp,-32
    80002b1a:	ec06                	sd	ra,24(sp)
    80002b1c:	e822                	sd	s0,16(sp)
    80002b1e:	e426                	sd	s1,8(sp)
    80002b20:	1000                	addi	s0,sp,32
    80002b22:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b24:	fffff097          	auipc	ra,0xfffff
    80002b28:	f12080e7          	jalr	-238(ra) # 80001a36 <myproc>
  switch (n) {
    80002b2c:	4795                	li	a5,5
    80002b2e:	0497e163          	bltu	a5,s1,80002b70 <argraw+0x58>
    80002b32:	048a                	slli	s1,s1,0x2
    80002b34:	00006717          	auipc	a4,0x6
    80002b38:	8f470713          	addi	a4,a4,-1804 # 80008428 <states.0+0x168>
    80002b3c:	94ba                	add	s1,s1,a4
    80002b3e:	409c                	lw	a5,0(s1)
    80002b40:	97ba                	add	a5,a5,a4
    80002b42:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b44:	6d3c                	ld	a5,88(a0)
    80002b46:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b48:	60e2                	ld	ra,24(sp)
    80002b4a:	6442                	ld	s0,16(sp)
    80002b4c:	64a2                	ld	s1,8(sp)
    80002b4e:	6105                	addi	sp,sp,32
    80002b50:	8082                	ret
    return p->trapframe->a1;
    80002b52:	6d3c                	ld	a5,88(a0)
    80002b54:	7fa8                	ld	a0,120(a5)
    80002b56:	bfcd                	j	80002b48 <argraw+0x30>
    return p->trapframe->a2;
    80002b58:	6d3c                	ld	a5,88(a0)
    80002b5a:	63c8                	ld	a0,128(a5)
    80002b5c:	b7f5                	j	80002b48 <argraw+0x30>
    return p->trapframe->a3;
    80002b5e:	6d3c                	ld	a5,88(a0)
    80002b60:	67c8                	ld	a0,136(a5)
    80002b62:	b7dd                	j	80002b48 <argraw+0x30>
    return p->trapframe->a4;
    80002b64:	6d3c                	ld	a5,88(a0)
    80002b66:	6bc8                	ld	a0,144(a5)
    80002b68:	b7c5                	j	80002b48 <argraw+0x30>
    return p->trapframe->a5;
    80002b6a:	6d3c                	ld	a5,88(a0)
    80002b6c:	6fc8                	ld	a0,152(a5)
    80002b6e:	bfe9                	j	80002b48 <argraw+0x30>
  panic("argraw");
    80002b70:	00006517          	auipc	a0,0x6
    80002b74:	89050513          	addi	a0,a0,-1904 # 80008400 <states.0+0x140>
    80002b78:	ffffe097          	auipc	ra,0xffffe
    80002b7c:	9ca080e7          	jalr	-1590(ra) # 80000542 <panic>

0000000080002b80 <fetchaddr>:
{
    80002b80:	1101                	addi	sp,sp,-32
    80002b82:	ec06                	sd	ra,24(sp)
    80002b84:	e822                	sd	s0,16(sp)
    80002b86:	e426                	sd	s1,8(sp)
    80002b88:	e04a                	sd	s2,0(sp)
    80002b8a:	1000                	addi	s0,sp,32
    80002b8c:	84aa                	mv	s1,a0
    80002b8e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b90:	fffff097          	auipc	ra,0xfffff
    80002b94:	ea6080e7          	jalr	-346(ra) # 80001a36 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002b98:	653c                	ld	a5,72(a0)
    80002b9a:	02f4f863          	bgeu	s1,a5,80002bca <fetchaddr+0x4a>
    80002b9e:	00848713          	addi	a4,s1,8
    80002ba2:	02e7e663          	bltu	a5,a4,80002bce <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ba6:	46a1                	li	a3,8
    80002ba8:	8626                	mv	a2,s1
    80002baa:	85ca                	mv	a1,s2
    80002bac:	6928                	ld	a0,80(a0)
    80002bae:	fffff097          	auipc	ra,0xfffff
    80002bb2:	c06080e7          	jalr	-1018(ra) # 800017b4 <copyin>
    80002bb6:	00a03533          	snez	a0,a0
    80002bba:	40a00533          	neg	a0,a0
}
    80002bbe:	60e2                	ld	ra,24(sp)
    80002bc0:	6442                	ld	s0,16(sp)
    80002bc2:	64a2                	ld	s1,8(sp)
    80002bc4:	6902                	ld	s2,0(sp)
    80002bc6:	6105                	addi	sp,sp,32
    80002bc8:	8082                	ret
    return -1;
    80002bca:	557d                	li	a0,-1
    80002bcc:	bfcd                	j	80002bbe <fetchaddr+0x3e>
    80002bce:	557d                	li	a0,-1
    80002bd0:	b7fd                	j	80002bbe <fetchaddr+0x3e>

0000000080002bd2 <fetchstr>:
{
    80002bd2:	7179                	addi	sp,sp,-48
    80002bd4:	f406                	sd	ra,40(sp)
    80002bd6:	f022                	sd	s0,32(sp)
    80002bd8:	ec26                	sd	s1,24(sp)
    80002bda:	e84a                	sd	s2,16(sp)
    80002bdc:	e44e                	sd	s3,8(sp)
    80002bde:	1800                	addi	s0,sp,48
    80002be0:	892a                	mv	s2,a0
    80002be2:	84ae                	mv	s1,a1
    80002be4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002be6:	fffff097          	auipc	ra,0xfffff
    80002bea:	e50080e7          	jalr	-432(ra) # 80001a36 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002bee:	86ce                	mv	a3,s3
    80002bf0:	864a                	mv	a2,s2
    80002bf2:	85a6                	mv	a1,s1
    80002bf4:	6928                	ld	a0,80(a0)
    80002bf6:	fffff097          	auipc	ra,0xfffff
    80002bfa:	c4c080e7          	jalr	-948(ra) # 80001842 <copyinstr>
  if(err < 0)
    80002bfe:	00054763          	bltz	a0,80002c0c <fetchstr+0x3a>
  return strlen(buf);
    80002c02:	8526                	mv	a0,s1
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	2e6080e7          	jalr	742(ra) # 80000eea <strlen>
}
    80002c0c:	70a2                	ld	ra,40(sp)
    80002c0e:	7402                	ld	s0,32(sp)
    80002c10:	64e2                	ld	s1,24(sp)
    80002c12:	6942                	ld	s2,16(sp)
    80002c14:	69a2                	ld	s3,8(sp)
    80002c16:	6145                	addi	sp,sp,48
    80002c18:	8082                	ret

0000000080002c1a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002c1a:	1101                	addi	sp,sp,-32
    80002c1c:	ec06                	sd	ra,24(sp)
    80002c1e:	e822                	sd	s0,16(sp)
    80002c20:	e426                	sd	s1,8(sp)
    80002c22:	1000                	addi	s0,sp,32
    80002c24:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c26:	00000097          	auipc	ra,0x0
    80002c2a:	ef2080e7          	jalr	-270(ra) # 80002b18 <argraw>
    80002c2e:	c088                	sw	a0,0(s1)
  return 0;
}
    80002c30:	4501                	li	a0,0
    80002c32:	60e2                	ld	ra,24(sp)
    80002c34:	6442                	ld	s0,16(sp)
    80002c36:	64a2                	ld	s1,8(sp)
    80002c38:	6105                	addi	sp,sp,32
    80002c3a:	8082                	ret

0000000080002c3c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002c3c:	1101                	addi	sp,sp,-32
    80002c3e:	ec06                	sd	ra,24(sp)
    80002c40:	e822                	sd	s0,16(sp)
    80002c42:	e426                	sd	s1,8(sp)
    80002c44:	1000                	addi	s0,sp,32
    80002c46:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c48:	00000097          	auipc	ra,0x0
    80002c4c:	ed0080e7          	jalr	-304(ra) # 80002b18 <argraw>
    80002c50:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c52:	4501                	li	a0,0
    80002c54:	60e2                	ld	ra,24(sp)
    80002c56:	6442                	ld	s0,16(sp)
    80002c58:	64a2                	ld	s1,8(sp)
    80002c5a:	6105                	addi	sp,sp,32
    80002c5c:	8082                	ret

0000000080002c5e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c5e:	1101                	addi	sp,sp,-32
    80002c60:	ec06                	sd	ra,24(sp)
    80002c62:	e822                	sd	s0,16(sp)
    80002c64:	e426                	sd	s1,8(sp)
    80002c66:	e04a                	sd	s2,0(sp)
    80002c68:	1000                	addi	s0,sp,32
    80002c6a:	84ae                	mv	s1,a1
    80002c6c:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c6e:	00000097          	auipc	ra,0x0
    80002c72:	eaa080e7          	jalr	-342(ra) # 80002b18 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c76:	864a                	mv	a2,s2
    80002c78:	85a6                	mv	a1,s1
    80002c7a:	00000097          	auipc	ra,0x0
    80002c7e:	f58080e7          	jalr	-168(ra) # 80002bd2 <fetchstr>
}
    80002c82:	60e2                	ld	ra,24(sp)
    80002c84:	6442                	ld	s0,16(sp)
    80002c86:	64a2                	ld	s1,8(sp)
    80002c88:	6902                	ld	s2,0(sp)
    80002c8a:	6105                	addi	sp,sp,32
    80002c8c:	8082                	ret

0000000080002c8e <syscall>:
[SYS_sigreturn] sys_sigreturn,
};

void
syscall(void)
{
    80002c8e:	1101                	addi	sp,sp,-32
    80002c90:	ec06                	sd	ra,24(sp)
    80002c92:	e822                	sd	s0,16(sp)
    80002c94:	e426                	sd	s1,8(sp)
    80002c96:	e04a                	sd	s2,0(sp)
    80002c98:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c9a:	fffff097          	auipc	ra,0xfffff
    80002c9e:	d9c080e7          	jalr	-612(ra) # 80001a36 <myproc>
    80002ca2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ca4:	05853903          	ld	s2,88(a0)
    80002ca8:	0a893783          	ld	a5,168(s2)
    80002cac:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002cb0:	37fd                	addiw	a5,a5,-1
    80002cb2:	4759                	li	a4,22
    80002cb4:	00f76f63          	bltu	a4,a5,80002cd2 <syscall+0x44>
    80002cb8:	00369713          	slli	a4,a3,0x3
    80002cbc:	00005797          	auipc	a5,0x5
    80002cc0:	78478793          	addi	a5,a5,1924 # 80008440 <syscalls>
    80002cc4:	97ba                	add	a5,a5,a4
    80002cc6:	639c                	ld	a5,0(a5)
    80002cc8:	c789                	beqz	a5,80002cd2 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002cca:	9782                	jalr	a5
    80002ccc:	06a93823          	sd	a0,112(s2)
    80002cd0:	a839                	j	80002cee <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002cd2:	15848613          	addi	a2,s1,344
    80002cd6:	5c8c                	lw	a1,56(s1)
    80002cd8:	00005517          	auipc	a0,0x5
    80002cdc:	73050513          	addi	a0,a0,1840 # 80008408 <states.0+0x148>
    80002ce0:	ffffe097          	auipc	ra,0xffffe
    80002ce4:	8ac080e7          	jalr	-1876(ra) # 8000058c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ce8:	6cbc                	ld	a5,88(s1)
    80002cea:	577d                	li	a4,-1
    80002cec:	fbb8                	sd	a4,112(a5)
  }
}
    80002cee:	60e2                	ld	ra,24(sp)
    80002cf0:	6442                	ld	s0,16(sp)
    80002cf2:	64a2                	ld	s1,8(sp)
    80002cf4:	6902                	ld	s2,0(sp)
    80002cf6:	6105                	addi	sp,sp,32
    80002cf8:	8082                	ret

0000000080002cfa <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cfa:	1101                	addi	sp,sp,-32
    80002cfc:	ec06                	sd	ra,24(sp)
    80002cfe:	e822                	sd	s0,16(sp)
    80002d00:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002d02:	fec40593          	addi	a1,s0,-20
    80002d06:	4501                	li	a0,0
    80002d08:	00000097          	auipc	ra,0x0
    80002d0c:	f12080e7          	jalr	-238(ra) # 80002c1a <argint>
    return -1;
    80002d10:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d12:	00054963          	bltz	a0,80002d24 <sys_exit+0x2a>
  exit(n);
    80002d16:	fec42503          	lw	a0,-20(s0)
    80002d1a:	fffff097          	auipc	ra,0xfffff
    80002d1e:	416080e7          	jalr	1046(ra) # 80002130 <exit>
  return 0;  // not reached
    80002d22:	4781                	li	a5,0
}
    80002d24:	853e                	mv	a0,a5
    80002d26:	60e2                	ld	ra,24(sp)
    80002d28:	6442                	ld	s0,16(sp)
    80002d2a:	6105                	addi	sp,sp,32
    80002d2c:	8082                	ret

0000000080002d2e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d2e:	1141                	addi	sp,sp,-16
    80002d30:	e406                	sd	ra,8(sp)
    80002d32:	e022                	sd	s0,0(sp)
    80002d34:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d36:	fffff097          	auipc	ra,0xfffff
    80002d3a:	d00080e7          	jalr	-768(ra) # 80001a36 <myproc>
}
    80002d3e:	5d08                	lw	a0,56(a0)
    80002d40:	60a2                	ld	ra,8(sp)
    80002d42:	6402                	ld	s0,0(sp)
    80002d44:	0141                	addi	sp,sp,16
    80002d46:	8082                	ret

0000000080002d48 <sys_fork>:

uint64
sys_fork(void)
{
    80002d48:	1141                	addi	sp,sp,-16
    80002d4a:	e406                	sd	ra,8(sp)
    80002d4c:	e022                	sd	s0,0(sp)
    80002d4e:	0800                	addi	s0,sp,16
  return fork();
    80002d50:	fffff097          	auipc	ra,0xfffff
    80002d54:	0d6080e7          	jalr	214(ra) # 80001e26 <fork>
}
    80002d58:	60a2                	ld	ra,8(sp)
    80002d5a:	6402                	ld	s0,0(sp)
    80002d5c:	0141                	addi	sp,sp,16
    80002d5e:	8082                	ret

0000000080002d60 <sys_wait>:

uint64
sys_wait(void)
{
    80002d60:	1101                	addi	sp,sp,-32
    80002d62:	ec06                	sd	ra,24(sp)
    80002d64:	e822                	sd	s0,16(sp)
    80002d66:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d68:	fe840593          	addi	a1,s0,-24
    80002d6c:	4501                	li	a0,0
    80002d6e:	00000097          	auipc	ra,0x0
    80002d72:	ece080e7          	jalr	-306(ra) # 80002c3c <argaddr>
    80002d76:	87aa                	mv	a5,a0
    return -1;
    80002d78:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002d7a:	0007c863          	bltz	a5,80002d8a <sys_wait+0x2a>
  return wait(p);
    80002d7e:	fe843503          	ld	a0,-24(s0)
    80002d82:	fffff097          	auipc	ra,0xfffff
    80002d86:	572080e7          	jalr	1394(ra) # 800022f4 <wait>
}
    80002d8a:	60e2                	ld	ra,24(sp)
    80002d8c:	6442                	ld	s0,16(sp)
    80002d8e:	6105                	addi	sp,sp,32
    80002d90:	8082                	ret

0000000080002d92 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d92:	7179                	addi	sp,sp,-48
    80002d94:	f406                	sd	ra,40(sp)
    80002d96:	f022                	sd	s0,32(sp)
    80002d98:	ec26                	sd	s1,24(sp)
    80002d9a:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002d9c:	fdc40593          	addi	a1,s0,-36
    80002da0:	4501                	li	a0,0
    80002da2:	00000097          	auipc	ra,0x0
    80002da6:	e78080e7          	jalr	-392(ra) # 80002c1a <argint>
    return -1;
    80002daa:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002dac:	00054f63          	bltz	a0,80002dca <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002db0:	fffff097          	auipc	ra,0xfffff
    80002db4:	c86080e7          	jalr	-890(ra) # 80001a36 <myproc>
    80002db8:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002dba:	fdc42503          	lw	a0,-36(s0)
    80002dbe:	fffff097          	auipc	ra,0xfffff
    80002dc2:	ff4080e7          	jalr	-12(ra) # 80001db2 <growproc>
    80002dc6:	00054863          	bltz	a0,80002dd6 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002dca:	8526                	mv	a0,s1
    80002dcc:	70a2                	ld	ra,40(sp)
    80002dce:	7402                	ld	s0,32(sp)
    80002dd0:	64e2                	ld	s1,24(sp)
    80002dd2:	6145                	addi	sp,sp,48
    80002dd4:	8082                	ret
    return -1;
    80002dd6:	54fd                	li	s1,-1
    80002dd8:	bfcd                	j	80002dca <sys_sbrk+0x38>

0000000080002dda <sys_sleep>:

uint64
sys_sleep(void)
{
    80002dda:	7139                	addi	sp,sp,-64
    80002ddc:	fc06                	sd	ra,56(sp)
    80002dde:	f822                	sd	s0,48(sp)
    80002de0:	f426                	sd	s1,40(sp)
    80002de2:	f04a                	sd	s2,32(sp)
    80002de4:	ec4e                	sd	s3,24(sp)
    80002de6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002de8:	fcc40593          	addi	a1,s0,-52
    80002dec:	4501                	li	a0,0
    80002dee:	00000097          	auipc	ra,0x0
    80002df2:	e2c080e7          	jalr	-468(ra) # 80002c1a <argint>
    return -1;
    80002df6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002df8:	06054963          	bltz	a0,80002e6a <sys_sleep+0x90>
  acquire(&tickslock);
    80002dfc:	00015517          	auipc	a0,0x15
    80002e00:	36c50513          	addi	a0,a0,876 # 80018168 <tickslock>
    80002e04:	ffffe097          	auipc	ra,0xffffe
    80002e08:	e66080e7          	jalr	-410(ra) # 80000c6a <acquire>
  ticks0 = ticks;
    80002e0c:	00006917          	auipc	s2,0x6
    80002e10:	21492903          	lw	s2,532(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002e14:	fcc42783          	lw	a5,-52(s0)
    80002e18:	cf85                	beqz	a5,80002e50 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e1a:	00015997          	auipc	s3,0x15
    80002e1e:	34e98993          	addi	s3,s3,846 # 80018168 <tickslock>
    80002e22:	00006497          	auipc	s1,0x6
    80002e26:	1fe48493          	addi	s1,s1,510 # 80009020 <ticks>
    if(myproc()->killed){
    80002e2a:	fffff097          	auipc	ra,0xfffff
    80002e2e:	c0c080e7          	jalr	-1012(ra) # 80001a36 <myproc>
    80002e32:	591c                	lw	a5,48(a0)
    80002e34:	e3b9                	bnez	a5,80002e7a <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80002e36:	85ce                	mv	a1,s3
    80002e38:	8526                	mv	a0,s1
    80002e3a:	fffff097          	auipc	ra,0xfffff
    80002e3e:	43c080e7          	jalr	1084(ra) # 80002276 <sleep>
  while(ticks - ticks0 < n){
    80002e42:	409c                	lw	a5,0(s1)
    80002e44:	412787bb          	subw	a5,a5,s2
    80002e48:	fcc42703          	lw	a4,-52(s0)
    80002e4c:	fce7efe3          	bltu	a5,a4,80002e2a <sys_sleep+0x50>
  }
  release(&tickslock);
    80002e50:	00015517          	auipc	a0,0x15
    80002e54:	31850513          	addi	a0,a0,792 # 80018168 <tickslock>
    80002e58:	ffffe097          	auipc	ra,0xffffe
    80002e5c:	ec6080e7          	jalr	-314(ra) # 80000d1e <release>
  backtrace();
    80002e60:	ffffe097          	auipc	ra,0xffffe
    80002e64:	90c080e7          	jalr	-1780(ra) # 8000076c <backtrace>
  return 0;
    80002e68:	4781                	li	a5,0
}
    80002e6a:	853e                	mv	a0,a5
    80002e6c:	70e2                	ld	ra,56(sp)
    80002e6e:	7442                	ld	s0,48(sp)
    80002e70:	74a2                	ld	s1,40(sp)
    80002e72:	7902                	ld	s2,32(sp)
    80002e74:	69e2                	ld	s3,24(sp)
    80002e76:	6121                	addi	sp,sp,64
    80002e78:	8082                	ret
      release(&tickslock);
    80002e7a:	00015517          	auipc	a0,0x15
    80002e7e:	2ee50513          	addi	a0,a0,750 # 80018168 <tickslock>
    80002e82:	ffffe097          	auipc	ra,0xffffe
    80002e86:	e9c080e7          	jalr	-356(ra) # 80000d1e <release>
      return -1;
    80002e8a:	57fd                	li	a5,-1
    80002e8c:	bff9                	j	80002e6a <sys_sleep+0x90>

0000000080002e8e <sys_kill>:

uint64
sys_kill(void)
{
    80002e8e:	1101                	addi	sp,sp,-32
    80002e90:	ec06                	sd	ra,24(sp)
    80002e92:	e822                	sd	s0,16(sp)
    80002e94:	1000                	addi	s0,sp,32
  int pid;
  if(argint(0, &pid) < 0)
    80002e96:	fec40593          	addi	a1,s0,-20
    80002e9a:	4501                	li	a0,0
    80002e9c:	00000097          	auipc	ra,0x0
    80002ea0:	d7e080e7          	jalr	-642(ra) # 80002c1a <argint>
    80002ea4:	87aa                	mv	a5,a0
    return -1;
    80002ea6:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002ea8:	0007c863          	bltz	a5,80002eb8 <sys_kill+0x2a>
  return kill(pid);
    80002eac:	fec42503          	lw	a0,-20(s0)
    80002eb0:	fffff097          	auipc	ra,0xfffff
    80002eb4:	5b0080e7          	jalr	1456(ra) # 80002460 <kill>
}
    80002eb8:	60e2                	ld	ra,24(sp)
    80002eba:	6442                	ld	s0,16(sp)
    80002ebc:	6105                	addi	sp,sp,32
    80002ebe:	8082                	ret

0000000080002ec0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ec0:	1101                	addi	sp,sp,-32
    80002ec2:	ec06                	sd	ra,24(sp)
    80002ec4:	e822                	sd	s0,16(sp)
    80002ec6:	e426                	sd	s1,8(sp)
    80002ec8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002eca:	00015517          	auipc	a0,0x15
    80002ece:	29e50513          	addi	a0,a0,670 # 80018168 <tickslock>
    80002ed2:	ffffe097          	auipc	ra,0xffffe
    80002ed6:	d98080e7          	jalr	-616(ra) # 80000c6a <acquire>
  xticks = ticks;
    80002eda:	00006497          	auipc	s1,0x6
    80002ede:	1464a483          	lw	s1,326(s1) # 80009020 <ticks>
  release(&tickslock);
    80002ee2:	00015517          	auipc	a0,0x15
    80002ee6:	28650513          	addi	a0,a0,646 # 80018168 <tickslock>
    80002eea:	ffffe097          	auipc	ra,0xffffe
    80002eee:	e34080e7          	jalr	-460(ra) # 80000d1e <release>
  return xticks;
}
    80002ef2:	02049513          	slli	a0,s1,0x20
    80002ef6:	9101                	srli	a0,a0,0x20
    80002ef8:	60e2                	ld	ra,24(sp)
    80002efa:	6442                	ld	s0,16(sp)
    80002efc:	64a2                	ld	s1,8(sp)
    80002efe:	6105                	addi	sp,sp,32
    80002f00:	8082                	ret

0000000080002f02 <sys_sigalarm>:
uint64
sys_sigalarm(void)
{
    80002f02:	7179                	addi	sp,sp,-48
    80002f04:	f406                	sd	ra,40(sp)
    80002f06:	f022                	sd	s0,32(sp)
    80002f08:	ec26                	sd	s1,24(sp)
    80002f0a:	1800                	addi	s0,sp,48
  struct proc*myProc=myproc();
    80002f0c:	fffff097          	auipc	ra,0xfffff
    80002f10:	b2a080e7          	jalr	-1238(ra) # 80001a36 <myproc>
    80002f14:	84aa                	mv	s1,a0
  int n;
  uint64 handler;

  if(argint(0, &n) < 0)
    80002f16:	fdc40593          	addi	a1,s0,-36
    80002f1a:	4501                	li	a0,0
    80002f1c:	00000097          	auipc	ra,0x0
    80002f20:	cfe080e7          	jalr	-770(ra) # 80002c1a <argint>
  return -1;
    80002f24:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f26:	02054463          	bltz	a0,80002f4e <sys_sigalarm+0x4c>
     myProc->interval=n;
    80002f2a:	fdc42783          	lw	a5,-36(s0)
    80002f2e:	16f4b423          	sd	a5,360(s1)
  if(argaddr(0, &handler) < 0)
    80002f32:	fd040593          	addi	a1,s0,-48
    80002f36:	4501                	li	a0,0
    80002f38:	00000097          	auipc	ra,0x0
    80002f3c:	d04080e7          	jalr	-764(ra) # 80002c3c <argaddr>
    80002f40:	00054d63          	bltz	a0,80002f5a <sys_sigalarm+0x58>
  return -1;
    myProc->handler=(void(*)())handler;
    80002f44:	fd043783          	ld	a5,-48(s0)
    80002f48:	16f4b823          	sd	a5,368(s1)
    return 0;
    80002f4c:	4781                	li	a5,0
}
    80002f4e:	853e                	mv	a0,a5
    80002f50:	70a2                	ld	ra,40(sp)
    80002f52:	7402                	ld	s0,32(sp)
    80002f54:	64e2                	ld	s1,24(sp)
    80002f56:	6145                	addi	sp,sp,48
    80002f58:	8082                	ret
  return -1;
    80002f5a:	57fd                	li	a5,-1
    80002f5c:	bfcd                	j	80002f4e <sys_sigalarm+0x4c>

0000000080002f5e <sys_sigreturn>:
uint64
sys_sigreturn(void)
{
    80002f5e:	1101                	addi	sp,sp,-32
    80002f60:	ec06                	sd	ra,24(sp)
    80002f62:	e822                	sd	s0,16(sp)
    80002f64:	e426                	sd	s1,8(sp)
    80002f66:	1000                	addi	s0,sp,32
  struct proc*myProc=myproc();
    80002f68:	fffff097          	auipc	ra,0xfffff
    80002f6c:	ace080e7          	jalr	-1330(ra) # 80001a36 <myproc>
    80002f70:	84aa                	mv	s1,a0
  switchTrapframe(myProc->trapframe,myProc->trapframeSave);
    80002f72:	18053583          	ld	a1,384(a0)
    80002f76:	6d28                	ld	a0,88(a0)
    80002f78:	00000097          	auipc	ra,0x0
    80002f7c:	9ae080e7          	jalr	-1618(ra) # 80002926 <switchTrapframe>
  myProc->waitReturn=0;
    80002f80:	1804a423          	sw	zero,392(s1)
   return 0;
}
    80002f84:	4501                	li	a0,0
    80002f86:	60e2                	ld	ra,24(sp)
    80002f88:	6442                	ld	s0,16(sp)
    80002f8a:	64a2                	ld	s1,8(sp)
    80002f8c:	6105                	addi	sp,sp,32
    80002f8e:	8082                	ret

0000000080002f90 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f90:	7179                	addi	sp,sp,-48
    80002f92:	f406                	sd	ra,40(sp)
    80002f94:	f022                	sd	s0,32(sp)
    80002f96:	ec26                	sd	s1,24(sp)
    80002f98:	e84a                	sd	s2,16(sp)
    80002f9a:	e44e                	sd	s3,8(sp)
    80002f9c:	e052                	sd	s4,0(sp)
    80002f9e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002fa0:	00005597          	auipc	a1,0x5
    80002fa4:	56058593          	addi	a1,a1,1376 # 80008500 <syscalls+0xc0>
    80002fa8:	00015517          	auipc	a0,0x15
    80002fac:	1d850513          	addi	a0,a0,472 # 80018180 <bcache>
    80002fb0:	ffffe097          	auipc	ra,0xffffe
    80002fb4:	c2a080e7          	jalr	-982(ra) # 80000bda <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002fb8:	0001d797          	auipc	a5,0x1d
    80002fbc:	1c878793          	addi	a5,a5,456 # 80020180 <bcache+0x8000>
    80002fc0:	0001d717          	auipc	a4,0x1d
    80002fc4:	42870713          	addi	a4,a4,1064 # 800203e8 <bcache+0x8268>
    80002fc8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002fcc:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fd0:	00015497          	auipc	s1,0x15
    80002fd4:	1c848493          	addi	s1,s1,456 # 80018198 <bcache+0x18>
    b->next = bcache.head.next;
    80002fd8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002fda:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002fdc:	00005a17          	auipc	s4,0x5
    80002fe0:	52ca0a13          	addi	s4,s4,1324 # 80008508 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002fe4:	2b893783          	ld	a5,696(s2)
    80002fe8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002fea:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002fee:	85d2                	mv	a1,s4
    80002ff0:	01048513          	addi	a0,s1,16
    80002ff4:	00001097          	auipc	ra,0x1
    80002ff8:	4ac080e7          	jalr	1196(ra) # 800044a0 <initsleeplock>
    bcache.head.next->prev = b;
    80002ffc:	2b893783          	ld	a5,696(s2)
    80003000:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003002:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003006:	45848493          	addi	s1,s1,1112
    8000300a:	fd349de3          	bne	s1,s3,80002fe4 <binit+0x54>
  }
}
    8000300e:	70a2                	ld	ra,40(sp)
    80003010:	7402                	ld	s0,32(sp)
    80003012:	64e2                	ld	s1,24(sp)
    80003014:	6942                	ld	s2,16(sp)
    80003016:	69a2                	ld	s3,8(sp)
    80003018:	6a02                	ld	s4,0(sp)
    8000301a:	6145                	addi	sp,sp,48
    8000301c:	8082                	ret

000000008000301e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000301e:	7179                	addi	sp,sp,-48
    80003020:	f406                	sd	ra,40(sp)
    80003022:	f022                	sd	s0,32(sp)
    80003024:	ec26                	sd	s1,24(sp)
    80003026:	e84a                	sd	s2,16(sp)
    80003028:	e44e                	sd	s3,8(sp)
    8000302a:	1800                	addi	s0,sp,48
    8000302c:	892a                	mv	s2,a0
    8000302e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003030:	00015517          	auipc	a0,0x15
    80003034:	15050513          	addi	a0,a0,336 # 80018180 <bcache>
    80003038:	ffffe097          	auipc	ra,0xffffe
    8000303c:	c32080e7          	jalr	-974(ra) # 80000c6a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003040:	0001d497          	auipc	s1,0x1d
    80003044:	3f84b483          	ld	s1,1016(s1) # 80020438 <bcache+0x82b8>
    80003048:	0001d797          	auipc	a5,0x1d
    8000304c:	3a078793          	addi	a5,a5,928 # 800203e8 <bcache+0x8268>
    80003050:	02f48f63          	beq	s1,a5,8000308e <bread+0x70>
    80003054:	873e                	mv	a4,a5
    80003056:	a021                	j	8000305e <bread+0x40>
    80003058:	68a4                	ld	s1,80(s1)
    8000305a:	02e48a63          	beq	s1,a4,8000308e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000305e:	449c                	lw	a5,8(s1)
    80003060:	ff279ce3          	bne	a5,s2,80003058 <bread+0x3a>
    80003064:	44dc                	lw	a5,12(s1)
    80003066:	ff3799e3          	bne	a5,s3,80003058 <bread+0x3a>
      b->refcnt++;
    8000306a:	40bc                	lw	a5,64(s1)
    8000306c:	2785                	addiw	a5,a5,1
    8000306e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003070:	00015517          	auipc	a0,0x15
    80003074:	11050513          	addi	a0,a0,272 # 80018180 <bcache>
    80003078:	ffffe097          	auipc	ra,0xffffe
    8000307c:	ca6080e7          	jalr	-858(ra) # 80000d1e <release>
      acquiresleep(&b->lock);
    80003080:	01048513          	addi	a0,s1,16
    80003084:	00001097          	auipc	ra,0x1
    80003088:	456080e7          	jalr	1110(ra) # 800044da <acquiresleep>
      return b;
    8000308c:	a8b9                	j	800030ea <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000308e:	0001d497          	auipc	s1,0x1d
    80003092:	3a24b483          	ld	s1,930(s1) # 80020430 <bcache+0x82b0>
    80003096:	0001d797          	auipc	a5,0x1d
    8000309a:	35278793          	addi	a5,a5,850 # 800203e8 <bcache+0x8268>
    8000309e:	00f48863          	beq	s1,a5,800030ae <bread+0x90>
    800030a2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800030a4:	40bc                	lw	a5,64(s1)
    800030a6:	cf81                	beqz	a5,800030be <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030a8:	64a4                	ld	s1,72(s1)
    800030aa:	fee49de3          	bne	s1,a4,800030a4 <bread+0x86>
  panic("bget: no buffers");
    800030ae:	00005517          	auipc	a0,0x5
    800030b2:	46250513          	addi	a0,a0,1122 # 80008510 <syscalls+0xd0>
    800030b6:	ffffd097          	auipc	ra,0xffffd
    800030ba:	48c080e7          	jalr	1164(ra) # 80000542 <panic>
      b->dev = dev;
    800030be:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800030c2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800030c6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800030ca:	4785                	li	a5,1
    800030cc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030ce:	00015517          	auipc	a0,0x15
    800030d2:	0b250513          	addi	a0,a0,178 # 80018180 <bcache>
    800030d6:	ffffe097          	auipc	ra,0xffffe
    800030da:	c48080e7          	jalr	-952(ra) # 80000d1e <release>
      acquiresleep(&b->lock);
    800030de:	01048513          	addi	a0,s1,16
    800030e2:	00001097          	auipc	ra,0x1
    800030e6:	3f8080e7          	jalr	1016(ra) # 800044da <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800030ea:	409c                	lw	a5,0(s1)
    800030ec:	cb89                	beqz	a5,800030fe <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800030ee:	8526                	mv	a0,s1
    800030f0:	70a2                	ld	ra,40(sp)
    800030f2:	7402                	ld	s0,32(sp)
    800030f4:	64e2                	ld	s1,24(sp)
    800030f6:	6942                	ld	s2,16(sp)
    800030f8:	69a2                	ld	s3,8(sp)
    800030fa:	6145                	addi	sp,sp,48
    800030fc:	8082                	ret
    virtio_disk_rw(b, 0);
    800030fe:	4581                	li	a1,0
    80003100:	8526                	mv	a0,s1
    80003102:	00003097          	auipc	ra,0x3
    80003106:	f2a080e7          	jalr	-214(ra) # 8000602c <virtio_disk_rw>
    b->valid = 1;
    8000310a:	4785                	li	a5,1
    8000310c:	c09c                	sw	a5,0(s1)
  return b;
    8000310e:	b7c5                	j	800030ee <bread+0xd0>

0000000080003110 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003110:	1101                	addi	sp,sp,-32
    80003112:	ec06                	sd	ra,24(sp)
    80003114:	e822                	sd	s0,16(sp)
    80003116:	e426                	sd	s1,8(sp)
    80003118:	1000                	addi	s0,sp,32
    8000311a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000311c:	0541                	addi	a0,a0,16
    8000311e:	00001097          	auipc	ra,0x1
    80003122:	456080e7          	jalr	1110(ra) # 80004574 <holdingsleep>
    80003126:	cd01                	beqz	a0,8000313e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003128:	4585                	li	a1,1
    8000312a:	8526                	mv	a0,s1
    8000312c:	00003097          	auipc	ra,0x3
    80003130:	f00080e7          	jalr	-256(ra) # 8000602c <virtio_disk_rw>
}
    80003134:	60e2                	ld	ra,24(sp)
    80003136:	6442                	ld	s0,16(sp)
    80003138:	64a2                	ld	s1,8(sp)
    8000313a:	6105                	addi	sp,sp,32
    8000313c:	8082                	ret
    panic("bwrite");
    8000313e:	00005517          	auipc	a0,0x5
    80003142:	3ea50513          	addi	a0,a0,1002 # 80008528 <syscalls+0xe8>
    80003146:	ffffd097          	auipc	ra,0xffffd
    8000314a:	3fc080e7          	jalr	1020(ra) # 80000542 <panic>

000000008000314e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000314e:	1101                	addi	sp,sp,-32
    80003150:	ec06                	sd	ra,24(sp)
    80003152:	e822                	sd	s0,16(sp)
    80003154:	e426                	sd	s1,8(sp)
    80003156:	e04a                	sd	s2,0(sp)
    80003158:	1000                	addi	s0,sp,32
    8000315a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000315c:	01050913          	addi	s2,a0,16
    80003160:	854a                	mv	a0,s2
    80003162:	00001097          	auipc	ra,0x1
    80003166:	412080e7          	jalr	1042(ra) # 80004574 <holdingsleep>
    8000316a:	c92d                	beqz	a0,800031dc <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000316c:	854a                	mv	a0,s2
    8000316e:	00001097          	auipc	ra,0x1
    80003172:	3c2080e7          	jalr	962(ra) # 80004530 <releasesleep>

  acquire(&bcache.lock);
    80003176:	00015517          	auipc	a0,0x15
    8000317a:	00a50513          	addi	a0,a0,10 # 80018180 <bcache>
    8000317e:	ffffe097          	auipc	ra,0xffffe
    80003182:	aec080e7          	jalr	-1300(ra) # 80000c6a <acquire>
  b->refcnt--;
    80003186:	40bc                	lw	a5,64(s1)
    80003188:	37fd                	addiw	a5,a5,-1
    8000318a:	0007871b          	sext.w	a4,a5
    8000318e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003190:	eb05                	bnez	a4,800031c0 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003192:	68bc                	ld	a5,80(s1)
    80003194:	64b8                	ld	a4,72(s1)
    80003196:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003198:	64bc                	ld	a5,72(s1)
    8000319a:	68b8                	ld	a4,80(s1)
    8000319c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000319e:	0001d797          	auipc	a5,0x1d
    800031a2:	fe278793          	addi	a5,a5,-30 # 80020180 <bcache+0x8000>
    800031a6:	2b87b703          	ld	a4,696(a5)
    800031aa:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800031ac:	0001d717          	auipc	a4,0x1d
    800031b0:	23c70713          	addi	a4,a4,572 # 800203e8 <bcache+0x8268>
    800031b4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800031b6:	2b87b703          	ld	a4,696(a5)
    800031ba:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800031bc:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800031c0:	00015517          	auipc	a0,0x15
    800031c4:	fc050513          	addi	a0,a0,-64 # 80018180 <bcache>
    800031c8:	ffffe097          	auipc	ra,0xffffe
    800031cc:	b56080e7          	jalr	-1194(ra) # 80000d1e <release>
}
    800031d0:	60e2                	ld	ra,24(sp)
    800031d2:	6442                	ld	s0,16(sp)
    800031d4:	64a2                	ld	s1,8(sp)
    800031d6:	6902                	ld	s2,0(sp)
    800031d8:	6105                	addi	sp,sp,32
    800031da:	8082                	ret
    panic("brelse");
    800031dc:	00005517          	auipc	a0,0x5
    800031e0:	35450513          	addi	a0,a0,852 # 80008530 <syscalls+0xf0>
    800031e4:	ffffd097          	auipc	ra,0xffffd
    800031e8:	35e080e7          	jalr	862(ra) # 80000542 <panic>

00000000800031ec <bpin>:

void
bpin(struct buf *b) {
    800031ec:	1101                	addi	sp,sp,-32
    800031ee:	ec06                	sd	ra,24(sp)
    800031f0:	e822                	sd	s0,16(sp)
    800031f2:	e426                	sd	s1,8(sp)
    800031f4:	1000                	addi	s0,sp,32
    800031f6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031f8:	00015517          	auipc	a0,0x15
    800031fc:	f8850513          	addi	a0,a0,-120 # 80018180 <bcache>
    80003200:	ffffe097          	auipc	ra,0xffffe
    80003204:	a6a080e7          	jalr	-1430(ra) # 80000c6a <acquire>
  b->refcnt++;
    80003208:	40bc                	lw	a5,64(s1)
    8000320a:	2785                	addiw	a5,a5,1
    8000320c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000320e:	00015517          	auipc	a0,0x15
    80003212:	f7250513          	addi	a0,a0,-142 # 80018180 <bcache>
    80003216:	ffffe097          	auipc	ra,0xffffe
    8000321a:	b08080e7          	jalr	-1272(ra) # 80000d1e <release>
}
    8000321e:	60e2                	ld	ra,24(sp)
    80003220:	6442                	ld	s0,16(sp)
    80003222:	64a2                	ld	s1,8(sp)
    80003224:	6105                	addi	sp,sp,32
    80003226:	8082                	ret

0000000080003228 <bunpin>:

void
bunpin(struct buf *b) {
    80003228:	1101                	addi	sp,sp,-32
    8000322a:	ec06                	sd	ra,24(sp)
    8000322c:	e822                	sd	s0,16(sp)
    8000322e:	e426                	sd	s1,8(sp)
    80003230:	1000                	addi	s0,sp,32
    80003232:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003234:	00015517          	auipc	a0,0x15
    80003238:	f4c50513          	addi	a0,a0,-180 # 80018180 <bcache>
    8000323c:	ffffe097          	auipc	ra,0xffffe
    80003240:	a2e080e7          	jalr	-1490(ra) # 80000c6a <acquire>
  b->refcnt--;
    80003244:	40bc                	lw	a5,64(s1)
    80003246:	37fd                	addiw	a5,a5,-1
    80003248:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000324a:	00015517          	auipc	a0,0x15
    8000324e:	f3650513          	addi	a0,a0,-202 # 80018180 <bcache>
    80003252:	ffffe097          	auipc	ra,0xffffe
    80003256:	acc080e7          	jalr	-1332(ra) # 80000d1e <release>
}
    8000325a:	60e2                	ld	ra,24(sp)
    8000325c:	6442                	ld	s0,16(sp)
    8000325e:	64a2                	ld	s1,8(sp)
    80003260:	6105                	addi	sp,sp,32
    80003262:	8082                	ret

0000000080003264 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003264:	1101                	addi	sp,sp,-32
    80003266:	ec06                	sd	ra,24(sp)
    80003268:	e822                	sd	s0,16(sp)
    8000326a:	e426                	sd	s1,8(sp)
    8000326c:	e04a                	sd	s2,0(sp)
    8000326e:	1000                	addi	s0,sp,32
    80003270:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003272:	00d5d59b          	srliw	a1,a1,0xd
    80003276:	0001d797          	auipc	a5,0x1d
    8000327a:	5e67a783          	lw	a5,1510(a5) # 8002085c <sb+0x1c>
    8000327e:	9dbd                	addw	a1,a1,a5
    80003280:	00000097          	auipc	ra,0x0
    80003284:	d9e080e7          	jalr	-610(ra) # 8000301e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003288:	0074f713          	andi	a4,s1,7
    8000328c:	4785                	li	a5,1
    8000328e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003292:	14ce                	slli	s1,s1,0x33
    80003294:	90d9                	srli	s1,s1,0x36
    80003296:	00950733          	add	a4,a0,s1
    8000329a:	05874703          	lbu	a4,88(a4)
    8000329e:	00e7f6b3          	and	a3,a5,a4
    800032a2:	c69d                	beqz	a3,800032d0 <bfree+0x6c>
    800032a4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032a6:	94aa                	add	s1,s1,a0
    800032a8:	fff7c793          	not	a5,a5
    800032ac:	8ff9                	and	a5,a5,a4
    800032ae:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800032b2:	00001097          	auipc	ra,0x1
    800032b6:	100080e7          	jalr	256(ra) # 800043b2 <log_write>
  brelse(bp);
    800032ba:	854a                	mv	a0,s2
    800032bc:	00000097          	auipc	ra,0x0
    800032c0:	e92080e7          	jalr	-366(ra) # 8000314e <brelse>
}
    800032c4:	60e2                	ld	ra,24(sp)
    800032c6:	6442                	ld	s0,16(sp)
    800032c8:	64a2                	ld	s1,8(sp)
    800032ca:	6902                	ld	s2,0(sp)
    800032cc:	6105                	addi	sp,sp,32
    800032ce:	8082                	ret
    panic("freeing free block");
    800032d0:	00005517          	auipc	a0,0x5
    800032d4:	26850513          	addi	a0,a0,616 # 80008538 <syscalls+0xf8>
    800032d8:	ffffd097          	auipc	ra,0xffffd
    800032dc:	26a080e7          	jalr	618(ra) # 80000542 <panic>

00000000800032e0 <balloc>:
{
    800032e0:	711d                	addi	sp,sp,-96
    800032e2:	ec86                	sd	ra,88(sp)
    800032e4:	e8a2                	sd	s0,80(sp)
    800032e6:	e4a6                	sd	s1,72(sp)
    800032e8:	e0ca                	sd	s2,64(sp)
    800032ea:	fc4e                	sd	s3,56(sp)
    800032ec:	f852                	sd	s4,48(sp)
    800032ee:	f456                	sd	s5,40(sp)
    800032f0:	f05a                	sd	s6,32(sp)
    800032f2:	ec5e                	sd	s7,24(sp)
    800032f4:	e862                	sd	s8,16(sp)
    800032f6:	e466                	sd	s9,8(sp)
    800032f8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800032fa:	0001d797          	auipc	a5,0x1d
    800032fe:	54a7a783          	lw	a5,1354(a5) # 80020844 <sb+0x4>
    80003302:	cbd1                	beqz	a5,80003396 <balloc+0xb6>
    80003304:	8baa                	mv	s7,a0
    80003306:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003308:	0001db17          	auipc	s6,0x1d
    8000330c:	538b0b13          	addi	s6,s6,1336 # 80020840 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003310:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003312:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003314:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003316:	6c89                	lui	s9,0x2
    80003318:	a831                	j	80003334 <balloc+0x54>
    brelse(bp);
    8000331a:	854a                	mv	a0,s2
    8000331c:	00000097          	auipc	ra,0x0
    80003320:	e32080e7          	jalr	-462(ra) # 8000314e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003324:	015c87bb          	addw	a5,s9,s5
    80003328:	00078a9b          	sext.w	s5,a5
    8000332c:	004b2703          	lw	a4,4(s6)
    80003330:	06eaf363          	bgeu	s5,a4,80003396 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003334:	41fad79b          	sraiw	a5,s5,0x1f
    80003338:	0137d79b          	srliw	a5,a5,0x13
    8000333c:	015787bb          	addw	a5,a5,s5
    80003340:	40d7d79b          	sraiw	a5,a5,0xd
    80003344:	01cb2583          	lw	a1,28(s6)
    80003348:	9dbd                	addw	a1,a1,a5
    8000334a:	855e                	mv	a0,s7
    8000334c:	00000097          	auipc	ra,0x0
    80003350:	cd2080e7          	jalr	-814(ra) # 8000301e <bread>
    80003354:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003356:	004b2503          	lw	a0,4(s6)
    8000335a:	000a849b          	sext.w	s1,s5
    8000335e:	8662                	mv	a2,s8
    80003360:	faa4fde3          	bgeu	s1,a0,8000331a <balloc+0x3a>
      m = 1 << (bi % 8);
    80003364:	41f6579b          	sraiw	a5,a2,0x1f
    80003368:	01d7d69b          	srliw	a3,a5,0x1d
    8000336c:	00c6873b          	addw	a4,a3,a2
    80003370:	00777793          	andi	a5,a4,7
    80003374:	9f95                	subw	a5,a5,a3
    80003376:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000337a:	4037571b          	sraiw	a4,a4,0x3
    8000337e:	00e906b3          	add	a3,s2,a4
    80003382:	0586c683          	lbu	a3,88(a3)
    80003386:	00d7f5b3          	and	a1,a5,a3
    8000338a:	cd91                	beqz	a1,800033a6 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000338c:	2605                	addiw	a2,a2,1
    8000338e:	2485                	addiw	s1,s1,1
    80003390:	fd4618e3          	bne	a2,s4,80003360 <balloc+0x80>
    80003394:	b759                	j	8000331a <balloc+0x3a>
  panic("balloc: out of blocks");
    80003396:	00005517          	auipc	a0,0x5
    8000339a:	1ba50513          	addi	a0,a0,442 # 80008550 <syscalls+0x110>
    8000339e:	ffffd097          	auipc	ra,0xffffd
    800033a2:	1a4080e7          	jalr	420(ra) # 80000542 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033a6:	974a                	add	a4,a4,s2
    800033a8:	8fd5                	or	a5,a5,a3
    800033aa:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800033ae:	854a                	mv	a0,s2
    800033b0:	00001097          	auipc	ra,0x1
    800033b4:	002080e7          	jalr	2(ra) # 800043b2 <log_write>
        brelse(bp);
    800033b8:	854a                	mv	a0,s2
    800033ba:	00000097          	auipc	ra,0x0
    800033be:	d94080e7          	jalr	-620(ra) # 8000314e <brelse>
  bp = bread(dev, bno);
    800033c2:	85a6                	mv	a1,s1
    800033c4:	855e                	mv	a0,s7
    800033c6:	00000097          	auipc	ra,0x0
    800033ca:	c58080e7          	jalr	-936(ra) # 8000301e <bread>
    800033ce:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800033d0:	40000613          	li	a2,1024
    800033d4:	4581                	li	a1,0
    800033d6:	05850513          	addi	a0,a0,88
    800033da:	ffffe097          	auipc	ra,0xffffe
    800033de:	98c080e7          	jalr	-1652(ra) # 80000d66 <memset>
  log_write(bp);
    800033e2:	854a                	mv	a0,s2
    800033e4:	00001097          	auipc	ra,0x1
    800033e8:	fce080e7          	jalr	-50(ra) # 800043b2 <log_write>
  brelse(bp);
    800033ec:	854a                	mv	a0,s2
    800033ee:	00000097          	auipc	ra,0x0
    800033f2:	d60080e7          	jalr	-672(ra) # 8000314e <brelse>
}
    800033f6:	8526                	mv	a0,s1
    800033f8:	60e6                	ld	ra,88(sp)
    800033fa:	6446                	ld	s0,80(sp)
    800033fc:	64a6                	ld	s1,72(sp)
    800033fe:	6906                	ld	s2,64(sp)
    80003400:	79e2                	ld	s3,56(sp)
    80003402:	7a42                	ld	s4,48(sp)
    80003404:	7aa2                	ld	s5,40(sp)
    80003406:	7b02                	ld	s6,32(sp)
    80003408:	6be2                	ld	s7,24(sp)
    8000340a:	6c42                	ld	s8,16(sp)
    8000340c:	6ca2                	ld	s9,8(sp)
    8000340e:	6125                	addi	sp,sp,96
    80003410:	8082                	ret

0000000080003412 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003412:	7179                	addi	sp,sp,-48
    80003414:	f406                	sd	ra,40(sp)
    80003416:	f022                	sd	s0,32(sp)
    80003418:	ec26                	sd	s1,24(sp)
    8000341a:	e84a                	sd	s2,16(sp)
    8000341c:	e44e                	sd	s3,8(sp)
    8000341e:	e052                	sd	s4,0(sp)
    80003420:	1800                	addi	s0,sp,48
    80003422:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003424:	47ad                	li	a5,11
    80003426:	04b7fe63          	bgeu	a5,a1,80003482 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000342a:	ff45849b          	addiw	s1,a1,-12
    8000342e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003432:	0ff00793          	li	a5,255
    80003436:	0ae7e363          	bltu	a5,a4,800034dc <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000343a:	08052583          	lw	a1,128(a0)
    8000343e:	c5ad                	beqz	a1,800034a8 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003440:	00092503          	lw	a0,0(s2)
    80003444:	00000097          	auipc	ra,0x0
    80003448:	bda080e7          	jalr	-1062(ra) # 8000301e <bread>
    8000344c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000344e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003452:	02049593          	slli	a1,s1,0x20
    80003456:	9181                	srli	a1,a1,0x20
    80003458:	058a                	slli	a1,a1,0x2
    8000345a:	00b784b3          	add	s1,a5,a1
    8000345e:	0004a983          	lw	s3,0(s1)
    80003462:	04098d63          	beqz	s3,800034bc <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003466:	8552                	mv	a0,s4
    80003468:	00000097          	auipc	ra,0x0
    8000346c:	ce6080e7          	jalr	-794(ra) # 8000314e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003470:	854e                	mv	a0,s3
    80003472:	70a2                	ld	ra,40(sp)
    80003474:	7402                	ld	s0,32(sp)
    80003476:	64e2                	ld	s1,24(sp)
    80003478:	6942                	ld	s2,16(sp)
    8000347a:	69a2                	ld	s3,8(sp)
    8000347c:	6a02                	ld	s4,0(sp)
    8000347e:	6145                	addi	sp,sp,48
    80003480:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003482:	02059493          	slli	s1,a1,0x20
    80003486:	9081                	srli	s1,s1,0x20
    80003488:	048a                	slli	s1,s1,0x2
    8000348a:	94aa                	add	s1,s1,a0
    8000348c:	0504a983          	lw	s3,80(s1)
    80003490:	fe0990e3          	bnez	s3,80003470 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003494:	4108                	lw	a0,0(a0)
    80003496:	00000097          	auipc	ra,0x0
    8000349a:	e4a080e7          	jalr	-438(ra) # 800032e0 <balloc>
    8000349e:	0005099b          	sext.w	s3,a0
    800034a2:	0534a823          	sw	s3,80(s1)
    800034a6:	b7e9                	j	80003470 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800034a8:	4108                	lw	a0,0(a0)
    800034aa:	00000097          	auipc	ra,0x0
    800034ae:	e36080e7          	jalr	-458(ra) # 800032e0 <balloc>
    800034b2:	0005059b          	sext.w	a1,a0
    800034b6:	08b92023          	sw	a1,128(s2)
    800034ba:	b759                	j	80003440 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800034bc:	00092503          	lw	a0,0(s2)
    800034c0:	00000097          	auipc	ra,0x0
    800034c4:	e20080e7          	jalr	-480(ra) # 800032e0 <balloc>
    800034c8:	0005099b          	sext.w	s3,a0
    800034cc:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800034d0:	8552                	mv	a0,s4
    800034d2:	00001097          	auipc	ra,0x1
    800034d6:	ee0080e7          	jalr	-288(ra) # 800043b2 <log_write>
    800034da:	b771                	j	80003466 <bmap+0x54>
  panic("bmap: out of range");
    800034dc:	00005517          	auipc	a0,0x5
    800034e0:	08c50513          	addi	a0,a0,140 # 80008568 <syscalls+0x128>
    800034e4:	ffffd097          	auipc	ra,0xffffd
    800034e8:	05e080e7          	jalr	94(ra) # 80000542 <panic>

00000000800034ec <iget>:
{
    800034ec:	7179                	addi	sp,sp,-48
    800034ee:	f406                	sd	ra,40(sp)
    800034f0:	f022                	sd	s0,32(sp)
    800034f2:	ec26                	sd	s1,24(sp)
    800034f4:	e84a                	sd	s2,16(sp)
    800034f6:	e44e                	sd	s3,8(sp)
    800034f8:	e052                	sd	s4,0(sp)
    800034fa:	1800                	addi	s0,sp,48
    800034fc:	89aa                	mv	s3,a0
    800034fe:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003500:	0001d517          	auipc	a0,0x1d
    80003504:	36050513          	addi	a0,a0,864 # 80020860 <icache>
    80003508:	ffffd097          	auipc	ra,0xffffd
    8000350c:	762080e7          	jalr	1890(ra) # 80000c6a <acquire>
  empty = 0;
    80003510:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003512:	0001d497          	auipc	s1,0x1d
    80003516:	36648493          	addi	s1,s1,870 # 80020878 <icache+0x18>
    8000351a:	0001f697          	auipc	a3,0x1f
    8000351e:	dee68693          	addi	a3,a3,-530 # 80022308 <log>
    80003522:	a039                	j	80003530 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003524:	02090b63          	beqz	s2,8000355a <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003528:	08848493          	addi	s1,s1,136
    8000352c:	02d48a63          	beq	s1,a3,80003560 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003530:	449c                	lw	a5,8(s1)
    80003532:	fef059e3          	blez	a5,80003524 <iget+0x38>
    80003536:	4098                	lw	a4,0(s1)
    80003538:	ff3716e3          	bne	a4,s3,80003524 <iget+0x38>
    8000353c:	40d8                	lw	a4,4(s1)
    8000353e:	ff4713e3          	bne	a4,s4,80003524 <iget+0x38>
      ip->ref++;
    80003542:	2785                	addiw	a5,a5,1
    80003544:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003546:	0001d517          	auipc	a0,0x1d
    8000354a:	31a50513          	addi	a0,a0,794 # 80020860 <icache>
    8000354e:	ffffd097          	auipc	ra,0xffffd
    80003552:	7d0080e7          	jalr	2000(ra) # 80000d1e <release>
      return ip;
    80003556:	8926                	mv	s2,s1
    80003558:	a03d                	j	80003586 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000355a:	f7f9                	bnez	a5,80003528 <iget+0x3c>
    8000355c:	8926                	mv	s2,s1
    8000355e:	b7e9                	j	80003528 <iget+0x3c>
  if(empty == 0)
    80003560:	02090c63          	beqz	s2,80003598 <iget+0xac>
  ip->dev = dev;
    80003564:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003568:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000356c:	4785                	li	a5,1
    8000356e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003572:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003576:	0001d517          	auipc	a0,0x1d
    8000357a:	2ea50513          	addi	a0,a0,746 # 80020860 <icache>
    8000357e:	ffffd097          	auipc	ra,0xffffd
    80003582:	7a0080e7          	jalr	1952(ra) # 80000d1e <release>
}
    80003586:	854a                	mv	a0,s2
    80003588:	70a2                	ld	ra,40(sp)
    8000358a:	7402                	ld	s0,32(sp)
    8000358c:	64e2                	ld	s1,24(sp)
    8000358e:	6942                	ld	s2,16(sp)
    80003590:	69a2                	ld	s3,8(sp)
    80003592:	6a02                	ld	s4,0(sp)
    80003594:	6145                	addi	sp,sp,48
    80003596:	8082                	ret
    panic("iget: no inodes");
    80003598:	00005517          	auipc	a0,0x5
    8000359c:	fe850513          	addi	a0,a0,-24 # 80008580 <syscalls+0x140>
    800035a0:	ffffd097          	auipc	ra,0xffffd
    800035a4:	fa2080e7          	jalr	-94(ra) # 80000542 <panic>

00000000800035a8 <fsinit>:
fsinit(int dev) {
    800035a8:	7179                	addi	sp,sp,-48
    800035aa:	f406                	sd	ra,40(sp)
    800035ac:	f022                	sd	s0,32(sp)
    800035ae:	ec26                	sd	s1,24(sp)
    800035b0:	e84a                	sd	s2,16(sp)
    800035b2:	e44e                	sd	s3,8(sp)
    800035b4:	1800                	addi	s0,sp,48
    800035b6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800035b8:	4585                	li	a1,1
    800035ba:	00000097          	auipc	ra,0x0
    800035be:	a64080e7          	jalr	-1436(ra) # 8000301e <bread>
    800035c2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035c4:	0001d997          	auipc	s3,0x1d
    800035c8:	27c98993          	addi	s3,s3,636 # 80020840 <sb>
    800035cc:	02000613          	li	a2,32
    800035d0:	05850593          	addi	a1,a0,88
    800035d4:	854e                	mv	a0,s3
    800035d6:	ffffd097          	auipc	ra,0xffffd
    800035da:	7ec080e7          	jalr	2028(ra) # 80000dc2 <memmove>
  brelse(bp);
    800035de:	8526                	mv	a0,s1
    800035e0:	00000097          	auipc	ra,0x0
    800035e4:	b6e080e7          	jalr	-1170(ra) # 8000314e <brelse>
  if(sb.magic != FSMAGIC)
    800035e8:	0009a703          	lw	a4,0(s3)
    800035ec:	102037b7          	lui	a5,0x10203
    800035f0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035f4:	02f71263          	bne	a4,a5,80003618 <fsinit+0x70>
  initlog(dev, &sb);
    800035f8:	0001d597          	auipc	a1,0x1d
    800035fc:	24858593          	addi	a1,a1,584 # 80020840 <sb>
    80003600:	854a                	mv	a0,s2
    80003602:	00001097          	auipc	ra,0x1
    80003606:	b38080e7          	jalr	-1224(ra) # 8000413a <initlog>
}
    8000360a:	70a2                	ld	ra,40(sp)
    8000360c:	7402                	ld	s0,32(sp)
    8000360e:	64e2                	ld	s1,24(sp)
    80003610:	6942                	ld	s2,16(sp)
    80003612:	69a2                	ld	s3,8(sp)
    80003614:	6145                	addi	sp,sp,48
    80003616:	8082                	ret
    panic("invalid file system");
    80003618:	00005517          	auipc	a0,0x5
    8000361c:	f7850513          	addi	a0,a0,-136 # 80008590 <syscalls+0x150>
    80003620:	ffffd097          	auipc	ra,0xffffd
    80003624:	f22080e7          	jalr	-222(ra) # 80000542 <panic>

0000000080003628 <iinit>:
{
    80003628:	7179                	addi	sp,sp,-48
    8000362a:	f406                	sd	ra,40(sp)
    8000362c:	f022                	sd	s0,32(sp)
    8000362e:	ec26                	sd	s1,24(sp)
    80003630:	e84a                	sd	s2,16(sp)
    80003632:	e44e                	sd	s3,8(sp)
    80003634:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003636:	00005597          	auipc	a1,0x5
    8000363a:	f7258593          	addi	a1,a1,-142 # 800085a8 <syscalls+0x168>
    8000363e:	0001d517          	auipc	a0,0x1d
    80003642:	22250513          	addi	a0,a0,546 # 80020860 <icache>
    80003646:	ffffd097          	auipc	ra,0xffffd
    8000364a:	594080e7          	jalr	1428(ra) # 80000bda <initlock>
  for(i = 0; i < NINODE; i++) {
    8000364e:	0001d497          	auipc	s1,0x1d
    80003652:	23a48493          	addi	s1,s1,570 # 80020888 <icache+0x28>
    80003656:	0001f997          	auipc	s3,0x1f
    8000365a:	cc298993          	addi	s3,s3,-830 # 80022318 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000365e:	00005917          	auipc	s2,0x5
    80003662:	f5290913          	addi	s2,s2,-174 # 800085b0 <syscalls+0x170>
    80003666:	85ca                	mv	a1,s2
    80003668:	8526                	mv	a0,s1
    8000366a:	00001097          	auipc	ra,0x1
    8000366e:	e36080e7          	jalr	-458(ra) # 800044a0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003672:	08848493          	addi	s1,s1,136
    80003676:	ff3498e3          	bne	s1,s3,80003666 <iinit+0x3e>
}
    8000367a:	70a2                	ld	ra,40(sp)
    8000367c:	7402                	ld	s0,32(sp)
    8000367e:	64e2                	ld	s1,24(sp)
    80003680:	6942                	ld	s2,16(sp)
    80003682:	69a2                	ld	s3,8(sp)
    80003684:	6145                	addi	sp,sp,48
    80003686:	8082                	ret

0000000080003688 <ialloc>:
{
    80003688:	715d                	addi	sp,sp,-80
    8000368a:	e486                	sd	ra,72(sp)
    8000368c:	e0a2                	sd	s0,64(sp)
    8000368e:	fc26                	sd	s1,56(sp)
    80003690:	f84a                	sd	s2,48(sp)
    80003692:	f44e                	sd	s3,40(sp)
    80003694:	f052                	sd	s4,32(sp)
    80003696:	ec56                	sd	s5,24(sp)
    80003698:	e85a                	sd	s6,16(sp)
    8000369a:	e45e                	sd	s7,8(sp)
    8000369c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000369e:	0001d717          	auipc	a4,0x1d
    800036a2:	1ae72703          	lw	a4,430(a4) # 8002084c <sb+0xc>
    800036a6:	4785                	li	a5,1
    800036a8:	04e7fa63          	bgeu	a5,a4,800036fc <ialloc+0x74>
    800036ac:	8aaa                	mv	s5,a0
    800036ae:	8bae                	mv	s7,a1
    800036b0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800036b2:	0001da17          	auipc	s4,0x1d
    800036b6:	18ea0a13          	addi	s4,s4,398 # 80020840 <sb>
    800036ba:	00048b1b          	sext.w	s6,s1
    800036be:	0044d793          	srli	a5,s1,0x4
    800036c2:	018a2583          	lw	a1,24(s4)
    800036c6:	9dbd                	addw	a1,a1,a5
    800036c8:	8556                	mv	a0,s5
    800036ca:	00000097          	auipc	ra,0x0
    800036ce:	954080e7          	jalr	-1708(ra) # 8000301e <bread>
    800036d2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800036d4:	05850993          	addi	s3,a0,88
    800036d8:	00f4f793          	andi	a5,s1,15
    800036dc:	079a                	slli	a5,a5,0x6
    800036de:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800036e0:	00099783          	lh	a5,0(s3)
    800036e4:	c785                	beqz	a5,8000370c <ialloc+0x84>
    brelse(bp);
    800036e6:	00000097          	auipc	ra,0x0
    800036ea:	a68080e7          	jalr	-1432(ra) # 8000314e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036ee:	0485                	addi	s1,s1,1
    800036f0:	00ca2703          	lw	a4,12(s4)
    800036f4:	0004879b          	sext.w	a5,s1
    800036f8:	fce7e1e3          	bltu	a5,a4,800036ba <ialloc+0x32>
  panic("ialloc: no inodes");
    800036fc:	00005517          	auipc	a0,0x5
    80003700:	ebc50513          	addi	a0,a0,-324 # 800085b8 <syscalls+0x178>
    80003704:	ffffd097          	auipc	ra,0xffffd
    80003708:	e3e080e7          	jalr	-450(ra) # 80000542 <panic>
      memset(dip, 0, sizeof(*dip));
    8000370c:	04000613          	li	a2,64
    80003710:	4581                	li	a1,0
    80003712:	854e                	mv	a0,s3
    80003714:	ffffd097          	auipc	ra,0xffffd
    80003718:	652080e7          	jalr	1618(ra) # 80000d66 <memset>
      dip->type = type;
    8000371c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003720:	854a                	mv	a0,s2
    80003722:	00001097          	auipc	ra,0x1
    80003726:	c90080e7          	jalr	-880(ra) # 800043b2 <log_write>
      brelse(bp);
    8000372a:	854a                	mv	a0,s2
    8000372c:	00000097          	auipc	ra,0x0
    80003730:	a22080e7          	jalr	-1502(ra) # 8000314e <brelse>
      return iget(dev, inum);
    80003734:	85da                	mv	a1,s6
    80003736:	8556                	mv	a0,s5
    80003738:	00000097          	auipc	ra,0x0
    8000373c:	db4080e7          	jalr	-588(ra) # 800034ec <iget>
}
    80003740:	60a6                	ld	ra,72(sp)
    80003742:	6406                	ld	s0,64(sp)
    80003744:	74e2                	ld	s1,56(sp)
    80003746:	7942                	ld	s2,48(sp)
    80003748:	79a2                	ld	s3,40(sp)
    8000374a:	7a02                	ld	s4,32(sp)
    8000374c:	6ae2                	ld	s5,24(sp)
    8000374e:	6b42                	ld	s6,16(sp)
    80003750:	6ba2                	ld	s7,8(sp)
    80003752:	6161                	addi	sp,sp,80
    80003754:	8082                	ret

0000000080003756 <iupdate>:
{
    80003756:	1101                	addi	sp,sp,-32
    80003758:	ec06                	sd	ra,24(sp)
    8000375a:	e822                	sd	s0,16(sp)
    8000375c:	e426                	sd	s1,8(sp)
    8000375e:	e04a                	sd	s2,0(sp)
    80003760:	1000                	addi	s0,sp,32
    80003762:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003764:	415c                	lw	a5,4(a0)
    80003766:	0047d79b          	srliw	a5,a5,0x4
    8000376a:	0001d597          	auipc	a1,0x1d
    8000376e:	0ee5a583          	lw	a1,238(a1) # 80020858 <sb+0x18>
    80003772:	9dbd                	addw	a1,a1,a5
    80003774:	4108                	lw	a0,0(a0)
    80003776:	00000097          	auipc	ra,0x0
    8000377a:	8a8080e7          	jalr	-1880(ra) # 8000301e <bread>
    8000377e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003780:	05850793          	addi	a5,a0,88
    80003784:	40c8                	lw	a0,4(s1)
    80003786:	893d                	andi	a0,a0,15
    80003788:	051a                	slli	a0,a0,0x6
    8000378a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000378c:	04449703          	lh	a4,68(s1)
    80003790:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003794:	04649703          	lh	a4,70(s1)
    80003798:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000379c:	04849703          	lh	a4,72(s1)
    800037a0:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800037a4:	04a49703          	lh	a4,74(s1)
    800037a8:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800037ac:	44f8                	lw	a4,76(s1)
    800037ae:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800037b0:	03400613          	li	a2,52
    800037b4:	05048593          	addi	a1,s1,80
    800037b8:	0531                	addi	a0,a0,12
    800037ba:	ffffd097          	auipc	ra,0xffffd
    800037be:	608080e7          	jalr	1544(ra) # 80000dc2 <memmove>
  log_write(bp);
    800037c2:	854a                	mv	a0,s2
    800037c4:	00001097          	auipc	ra,0x1
    800037c8:	bee080e7          	jalr	-1042(ra) # 800043b2 <log_write>
  brelse(bp);
    800037cc:	854a                	mv	a0,s2
    800037ce:	00000097          	auipc	ra,0x0
    800037d2:	980080e7          	jalr	-1664(ra) # 8000314e <brelse>
}
    800037d6:	60e2                	ld	ra,24(sp)
    800037d8:	6442                	ld	s0,16(sp)
    800037da:	64a2                	ld	s1,8(sp)
    800037dc:	6902                	ld	s2,0(sp)
    800037de:	6105                	addi	sp,sp,32
    800037e0:	8082                	ret

00000000800037e2 <idup>:
{
    800037e2:	1101                	addi	sp,sp,-32
    800037e4:	ec06                	sd	ra,24(sp)
    800037e6:	e822                	sd	s0,16(sp)
    800037e8:	e426                	sd	s1,8(sp)
    800037ea:	1000                	addi	s0,sp,32
    800037ec:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800037ee:	0001d517          	auipc	a0,0x1d
    800037f2:	07250513          	addi	a0,a0,114 # 80020860 <icache>
    800037f6:	ffffd097          	auipc	ra,0xffffd
    800037fa:	474080e7          	jalr	1140(ra) # 80000c6a <acquire>
  ip->ref++;
    800037fe:	449c                	lw	a5,8(s1)
    80003800:	2785                	addiw	a5,a5,1
    80003802:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003804:	0001d517          	auipc	a0,0x1d
    80003808:	05c50513          	addi	a0,a0,92 # 80020860 <icache>
    8000380c:	ffffd097          	auipc	ra,0xffffd
    80003810:	512080e7          	jalr	1298(ra) # 80000d1e <release>
}
    80003814:	8526                	mv	a0,s1
    80003816:	60e2                	ld	ra,24(sp)
    80003818:	6442                	ld	s0,16(sp)
    8000381a:	64a2                	ld	s1,8(sp)
    8000381c:	6105                	addi	sp,sp,32
    8000381e:	8082                	ret

0000000080003820 <ilock>:
{
    80003820:	1101                	addi	sp,sp,-32
    80003822:	ec06                	sd	ra,24(sp)
    80003824:	e822                	sd	s0,16(sp)
    80003826:	e426                	sd	s1,8(sp)
    80003828:	e04a                	sd	s2,0(sp)
    8000382a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000382c:	c115                	beqz	a0,80003850 <ilock+0x30>
    8000382e:	84aa                	mv	s1,a0
    80003830:	451c                	lw	a5,8(a0)
    80003832:	00f05f63          	blez	a5,80003850 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003836:	0541                	addi	a0,a0,16
    80003838:	00001097          	auipc	ra,0x1
    8000383c:	ca2080e7          	jalr	-862(ra) # 800044da <acquiresleep>
  if(ip->valid == 0){
    80003840:	40bc                	lw	a5,64(s1)
    80003842:	cf99                	beqz	a5,80003860 <ilock+0x40>
}
    80003844:	60e2                	ld	ra,24(sp)
    80003846:	6442                	ld	s0,16(sp)
    80003848:	64a2                	ld	s1,8(sp)
    8000384a:	6902                	ld	s2,0(sp)
    8000384c:	6105                	addi	sp,sp,32
    8000384e:	8082                	ret
    panic("ilock");
    80003850:	00005517          	auipc	a0,0x5
    80003854:	d8050513          	addi	a0,a0,-640 # 800085d0 <syscalls+0x190>
    80003858:	ffffd097          	auipc	ra,0xffffd
    8000385c:	cea080e7          	jalr	-790(ra) # 80000542 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003860:	40dc                	lw	a5,4(s1)
    80003862:	0047d79b          	srliw	a5,a5,0x4
    80003866:	0001d597          	auipc	a1,0x1d
    8000386a:	ff25a583          	lw	a1,-14(a1) # 80020858 <sb+0x18>
    8000386e:	9dbd                	addw	a1,a1,a5
    80003870:	4088                	lw	a0,0(s1)
    80003872:	fffff097          	auipc	ra,0xfffff
    80003876:	7ac080e7          	jalr	1964(ra) # 8000301e <bread>
    8000387a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000387c:	05850593          	addi	a1,a0,88
    80003880:	40dc                	lw	a5,4(s1)
    80003882:	8bbd                	andi	a5,a5,15
    80003884:	079a                	slli	a5,a5,0x6
    80003886:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003888:	00059783          	lh	a5,0(a1)
    8000388c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003890:	00259783          	lh	a5,2(a1)
    80003894:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003898:	00459783          	lh	a5,4(a1)
    8000389c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038a0:	00659783          	lh	a5,6(a1)
    800038a4:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800038a8:	459c                	lw	a5,8(a1)
    800038aa:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800038ac:	03400613          	li	a2,52
    800038b0:	05b1                	addi	a1,a1,12
    800038b2:	05048513          	addi	a0,s1,80
    800038b6:	ffffd097          	auipc	ra,0xffffd
    800038ba:	50c080e7          	jalr	1292(ra) # 80000dc2 <memmove>
    brelse(bp);
    800038be:	854a                	mv	a0,s2
    800038c0:	00000097          	auipc	ra,0x0
    800038c4:	88e080e7          	jalr	-1906(ra) # 8000314e <brelse>
    ip->valid = 1;
    800038c8:	4785                	li	a5,1
    800038ca:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800038cc:	04449783          	lh	a5,68(s1)
    800038d0:	fbb5                	bnez	a5,80003844 <ilock+0x24>
      panic("ilock: no type");
    800038d2:	00005517          	auipc	a0,0x5
    800038d6:	d0650513          	addi	a0,a0,-762 # 800085d8 <syscalls+0x198>
    800038da:	ffffd097          	auipc	ra,0xffffd
    800038de:	c68080e7          	jalr	-920(ra) # 80000542 <panic>

00000000800038e2 <iunlock>:
{
    800038e2:	1101                	addi	sp,sp,-32
    800038e4:	ec06                	sd	ra,24(sp)
    800038e6:	e822                	sd	s0,16(sp)
    800038e8:	e426                	sd	s1,8(sp)
    800038ea:	e04a                	sd	s2,0(sp)
    800038ec:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800038ee:	c905                	beqz	a0,8000391e <iunlock+0x3c>
    800038f0:	84aa                	mv	s1,a0
    800038f2:	01050913          	addi	s2,a0,16
    800038f6:	854a                	mv	a0,s2
    800038f8:	00001097          	auipc	ra,0x1
    800038fc:	c7c080e7          	jalr	-900(ra) # 80004574 <holdingsleep>
    80003900:	cd19                	beqz	a0,8000391e <iunlock+0x3c>
    80003902:	449c                	lw	a5,8(s1)
    80003904:	00f05d63          	blez	a5,8000391e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003908:	854a                	mv	a0,s2
    8000390a:	00001097          	auipc	ra,0x1
    8000390e:	c26080e7          	jalr	-986(ra) # 80004530 <releasesleep>
}
    80003912:	60e2                	ld	ra,24(sp)
    80003914:	6442                	ld	s0,16(sp)
    80003916:	64a2                	ld	s1,8(sp)
    80003918:	6902                	ld	s2,0(sp)
    8000391a:	6105                	addi	sp,sp,32
    8000391c:	8082                	ret
    panic("iunlock");
    8000391e:	00005517          	auipc	a0,0x5
    80003922:	cca50513          	addi	a0,a0,-822 # 800085e8 <syscalls+0x1a8>
    80003926:	ffffd097          	auipc	ra,0xffffd
    8000392a:	c1c080e7          	jalr	-996(ra) # 80000542 <panic>

000000008000392e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000392e:	7179                	addi	sp,sp,-48
    80003930:	f406                	sd	ra,40(sp)
    80003932:	f022                	sd	s0,32(sp)
    80003934:	ec26                	sd	s1,24(sp)
    80003936:	e84a                	sd	s2,16(sp)
    80003938:	e44e                	sd	s3,8(sp)
    8000393a:	e052                	sd	s4,0(sp)
    8000393c:	1800                	addi	s0,sp,48
    8000393e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003940:	05050493          	addi	s1,a0,80
    80003944:	08050913          	addi	s2,a0,128
    80003948:	a021                	j	80003950 <itrunc+0x22>
    8000394a:	0491                	addi	s1,s1,4
    8000394c:	01248d63          	beq	s1,s2,80003966 <itrunc+0x38>
    if(ip->addrs[i]){
    80003950:	408c                	lw	a1,0(s1)
    80003952:	dde5                	beqz	a1,8000394a <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003954:	0009a503          	lw	a0,0(s3)
    80003958:	00000097          	auipc	ra,0x0
    8000395c:	90c080e7          	jalr	-1780(ra) # 80003264 <bfree>
      ip->addrs[i] = 0;
    80003960:	0004a023          	sw	zero,0(s1)
    80003964:	b7dd                	j	8000394a <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003966:	0809a583          	lw	a1,128(s3)
    8000396a:	e185                	bnez	a1,8000398a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000396c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003970:	854e                	mv	a0,s3
    80003972:	00000097          	auipc	ra,0x0
    80003976:	de4080e7          	jalr	-540(ra) # 80003756 <iupdate>
}
    8000397a:	70a2                	ld	ra,40(sp)
    8000397c:	7402                	ld	s0,32(sp)
    8000397e:	64e2                	ld	s1,24(sp)
    80003980:	6942                	ld	s2,16(sp)
    80003982:	69a2                	ld	s3,8(sp)
    80003984:	6a02                	ld	s4,0(sp)
    80003986:	6145                	addi	sp,sp,48
    80003988:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000398a:	0009a503          	lw	a0,0(s3)
    8000398e:	fffff097          	auipc	ra,0xfffff
    80003992:	690080e7          	jalr	1680(ra) # 8000301e <bread>
    80003996:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003998:	05850493          	addi	s1,a0,88
    8000399c:	45850913          	addi	s2,a0,1112
    800039a0:	a021                	j	800039a8 <itrunc+0x7a>
    800039a2:	0491                	addi	s1,s1,4
    800039a4:	01248b63          	beq	s1,s2,800039ba <itrunc+0x8c>
      if(a[j])
    800039a8:	408c                	lw	a1,0(s1)
    800039aa:	dde5                	beqz	a1,800039a2 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800039ac:	0009a503          	lw	a0,0(s3)
    800039b0:	00000097          	auipc	ra,0x0
    800039b4:	8b4080e7          	jalr	-1868(ra) # 80003264 <bfree>
    800039b8:	b7ed                	j	800039a2 <itrunc+0x74>
    brelse(bp);
    800039ba:	8552                	mv	a0,s4
    800039bc:	fffff097          	auipc	ra,0xfffff
    800039c0:	792080e7          	jalr	1938(ra) # 8000314e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800039c4:	0809a583          	lw	a1,128(s3)
    800039c8:	0009a503          	lw	a0,0(s3)
    800039cc:	00000097          	auipc	ra,0x0
    800039d0:	898080e7          	jalr	-1896(ra) # 80003264 <bfree>
    ip->addrs[NDIRECT] = 0;
    800039d4:	0809a023          	sw	zero,128(s3)
    800039d8:	bf51                	j	8000396c <itrunc+0x3e>

00000000800039da <iput>:
{
    800039da:	1101                	addi	sp,sp,-32
    800039dc:	ec06                	sd	ra,24(sp)
    800039de:	e822                	sd	s0,16(sp)
    800039e0:	e426                	sd	s1,8(sp)
    800039e2:	e04a                	sd	s2,0(sp)
    800039e4:	1000                	addi	s0,sp,32
    800039e6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800039e8:	0001d517          	auipc	a0,0x1d
    800039ec:	e7850513          	addi	a0,a0,-392 # 80020860 <icache>
    800039f0:	ffffd097          	auipc	ra,0xffffd
    800039f4:	27a080e7          	jalr	634(ra) # 80000c6a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039f8:	4498                	lw	a4,8(s1)
    800039fa:	4785                	li	a5,1
    800039fc:	02f70363          	beq	a4,a5,80003a22 <iput+0x48>
  ip->ref--;
    80003a00:	449c                	lw	a5,8(s1)
    80003a02:	37fd                	addiw	a5,a5,-1
    80003a04:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003a06:	0001d517          	auipc	a0,0x1d
    80003a0a:	e5a50513          	addi	a0,a0,-422 # 80020860 <icache>
    80003a0e:	ffffd097          	auipc	ra,0xffffd
    80003a12:	310080e7          	jalr	784(ra) # 80000d1e <release>
}
    80003a16:	60e2                	ld	ra,24(sp)
    80003a18:	6442                	ld	s0,16(sp)
    80003a1a:	64a2                	ld	s1,8(sp)
    80003a1c:	6902                	ld	s2,0(sp)
    80003a1e:	6105                	addi	sp,sp,32
    80003a20:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a22:	40bc                	lw	a5,64(s1)
    80003a24:	dff1                	beqz	a5,80003a00 <iput+0x26>
    80003a26:	04a49783          	lh	a5,74(s1)
    80003a2a:	fbf9                	bnez	a5,80003a00 <iput+0x26>
    acquiresleep(&ip->lock);
    80003a2c:	01048913          	addi	s2,s1,16
    80003a30:	854a                	mv	a0,s2
    80003a32:	00001097          	auipc	ra,0x1
    80003a36:	aa8080e7          	jalr	-1368(ra) # 800044da <acquiresleep>
    release(&icache.lock);
    80003a3a:	0001d517          	auipc	a0,0x1d
    80003a3e:	e2650513          	addi	a0,a0,-474 # 80020860 <icache>
    80003a42:	ffffd097          	auipc	ra,0xffffd
    80003a46:	2dc080e7          	jalr	732(ra) # 80000d1e <release>
    itrunc(ip);
    80003a4a:	8526                	mv	a0,s1
    80003a4c:	00000097          	auipc	ra,0x0
    80003a50:	ee2080e7          	jalr	-286(ra) # 8000392e <itrunc>
    ip->type = 0;
    80003a54:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a58:	8526                	mv	a0,s1
    80003a5a:	00000097          	auipc	ra,0x0
    80003a5e:	cfc080e7          	jalr	-772(ra) # 80003756 <iupdate>
    ip->valid = 0;
    80003a62:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a66:	854a                	mv	a0,s2
    80003a68:	00001097          	auipc	ra,0x1
    80003a6c:	ac8080e7          	jalr	-1336(ra) # 80004530 <releasesleep>
    acquire(&icache.lock);
    80003a70:	0001d517          	auipc	a0,0x1d
    80003a74:	df050513          	addi	a0,a0,-528 # 80020860 <icache>
    80003a78:	ffffd097          	auipc	ra,0xffffd
    80003a7c:	1f2080e7          	jalr	498(ra) # 80000c6a <acquire>
    80003a80:	b741                	j	80003a00 <iput+0x26>

0000000080003a82 <iunlockput>:
{
    80003a82:	1101                	addi	sp,sp,-32
    80003a84:	ec06                	sd	ra,24(sp)
    80003a86:	e822                	sd	s0,16(sp)
    80003a88:	e426                	sd	s1,8(sp)
    80003a8a:	1000                	addi	s0,sp,32
    80003a8c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a8e:	00000097          	auipc	ra,0x0
    80003a92:	e54080e7          	jalr	-428(ra) # 800038e2 <iunlock>
  iput(ip);
    80003a96:	8526                	mv	a0,s1
    80003a98:	00000097          	auipc	ra,0x0
    80003a9c:	f42080e7          	jalr	-190(ra) # 800039da <iput>
}
    80003aa0:	60e2                	ld	ra,24(sp)
    80003aa2:	6442                	ld	s0,16(sp)
    80003aa4:	64a2                	ld	s1,8(sp)
    80003aa6:	6105                	addi	sp,sp,32
    80003aa8:	8082                	ret

0000000080003aaa <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003aaa:	1141                	addi	sp,sp,-16
    80003aac:	e422                	sd	s0,8(sp)
    80003aae:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ab0:	411c                	lw	a5,0(a0)
    80003ab2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ab4:	415c                	lw	a5,4(a0)
    80003ab6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ab8:	04451783          	lh	a5,68(a0)
    80003abc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ac0:	04a51783          	lh	a5,74(a0)
    80003ac4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ac8:	04c56783          	lwu	a5,76(a0)
    80003acc:	e99c                	sd	a5,16(a1)
}
    80003ace:	6422                	ld	s0,8(sp)
    80003ad0:	0141                	addi	sp,sp,16
    80003ad2:	8082                	ret

0000000080003ad4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ad4:	457c                	lw	a5,76(a0)
    80003ad6:	0ed7e863          	bltu	a5,a3,80003bc6 <readi+0xf2>
{
    80003ada:	7159                	addi	sp,sp,-112
    80003adc:	f486                	sd	ra,104(sp)
    80003ade:	f0a2                	sd	s0,96(sp)
    80003ae0:	eca6                	sd	s1,88(sp)
    80003ae2:	e8ca                	sd	s2,80(sp)
    80003ae4:	e4ce                	sd	s3,72(sp)
    80003ae6:	e0d2                	sd	s4,64(sp)
    80003ae8:	fc56                	sd	s5,56(sp)
    80003aea:	f85a                	sd	s6,48(sp)
    80003aec:	f45e                	sd	s7,40(sp)
    80003aee:	f062                	sd	s8,32(sp)
    80003af0:	ec66                	sd	s9,24(sp)
    80003af2:	e86a                	sd	s10,16(sp)
    80003af4:	e46e                	sd	s11,8(sp)
    80003af6:	1880                	addi	s0,sp,112
    80003af8:	8baa                	mv	s7,a0
    80003afa:	8c2e                	mv	s8,a1
    80003afc:	8ab2                	mv	s5,a2
    80003afe:	84b6                	mv	s1,a3
    80003b00:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b02:	9f35                	addw	a4,a4,a3
    return 0;
    80003b04:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b06:	08d76f63          	bltu	a4,a3,80003ba4 <readi+0xd0>
  if(off + n > ip->size)
    80003b0a:	00e7f463          	bgeu	a5,a4,80003b12 <readi+0x3e>
    n = ip->size - off;
    80003b0e:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b12:	0a0b0863          	beqz	s6,80003bc2 <readi+0xee>
    80003b16:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b18:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b1c:	5cfd                	li	s9,-1
    80003b1e:	a82d                	j	80003b58 <readi+0x84>
    80003b20:	020a1d93          	slli	s11,s4,0x20
    80003b24:	020ddd93          	srli	s11,s11,0x20
    80003b28:	05890793          	addi	a5,s2,88
    80003b2c:	86ee                	mv	a3,s11
    80003b2e:	963e                	add	a2,a2,a5
    80003b30:	85d6                	mv	a1,s5
    80003b32:	8562                	mv	a0,s8
    80003b34:	fffff097          	auipc	ra,0xfffff
    80003b38:	99c080e7          	jalr	-1636(ra) # 800024d0 <either_copyout>
    80003b3c:	05950d63          	beq	a0,s9,80003b96 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003b40:	854a                	mv	a0,s2
    80003b42:	fffff097          	auipc	ra,0xfffff
    80003b46:	60c080e7          	jalr	1548(ra) # 8000314e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b4a:	013a09bb          	addw	s3,s4,s3
    80003b4e:	009a04bb          	addw	s1,s4,s1
    80003b52:	9aee                	add	s5,s5,s11
    80003b54:	0569f663          	bgeu	s3,s6,80003ba0 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b58:	000ba903          	lw	s2,0(s7)
    80003b5c:	00a4d59b          	srliw	a1,s1,0xa
    80003b60:	855e                	mv	a0,s7
    80003b62:	00000097          	auipc	ra,0x0
    80003b66:	8b0080e7          	jalr	-1872(ra) # 80003412 <bmap>
    80003b6a:	0005059b          	sext.w	a1,a0
    80003b6e:	854a                	mv	a0,s2
    80003b70:	fffff097          	auipc	ra,0xfffff
    80003b74:	4ae080e7          	jalr	1198(ra) # 8000301e <bread>
    80003b78:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b7a:	3ff4f613          	andi	a2,s1,1023
    80003b7e:	40cd07bb          	subw	a5,s10,a2
    80003b82:	413b073b          	subw	a4,s6,s3
    80003b86:	8a3e                	mv	s4,a5
    80003b88:	2781                	sext.w	a5,a5
    80003b8a:	0007069b          	sext.w	a3,a4
    80003b8e:	f8f6f9e3          	bgeu	a3,a5,80003b20 <readi+0x4c>
    80003b92:	8a3a                	mv	s4,a4
    80003b94:	b771                	j	80003b20 <readi+0x4c>
      brelse(bp);
    80003b96:	854a                	mv	a0,s2
    80003b98:	fffff097          	auipc	ra,0xfffff
    80003b9c:	5b6080e7          	jalr	1462(ra) # 8000314e <brelse>
  }
  return tot;
    80003ba0:	0009851b          	sext.w	a0,s3
}
    80003ba4:	70a6                	ld	ra,104(sp)
    80003ba6:	7406                	ld	s0,96(sp)
    80003ba8:	64e6                	ld	s1,88(sp)
    80003baa:	6946                	ld	s2,80(sp)
    80003bac:	69a6                	ld	s3,72(sp)
    80003bae:	6a06                	ld	s4,64(sp)
    80003bb0:	7ae2                	ld	s5,56(sp)
    80003bb2:	7b42                	ld	s6,48(sp)
    80003bb4:	7ba2                	ld	s7,40(sp)
    80003bb6:	7c02                	ld	s8,32(sp)
    80003bb8:	6ce2                	ld	s9,24(sp)
    80003bba:	6d42                	ld	s10,16(sp)
    80003bbc:	6da2                	ld	s11,8(sp)
    80003bbe:	6165                	addi	sp,sp,112
    80003bc0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bc2:	89da                	mv	s3,s6
    80003bc4:	bff1                	j	80003ba0 <readi+0xcc>
    return 0;
    80003bc6:	4501                	li	a0,0
}
    80003bc8:	8082                	ret

0000000080003bca <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bca:	457c                	lw	a5,76(a0)
    80003bcc:	10d7e663          	bltu	a5,a3,80003cd8 <writei+0x10e>
{
    80003bd0:	7159                	addi	sp,sp,-112
    80003bd2:	f486                	sd	ra,104(sp)
    80003bd4:	f0a2                	sd	s0,96(sp)
    80003bd6:	eca6                	sd	s1,88(sp)
    80003bd8:	e8ca                	sd	s2,80(sp)
    80003bda:	e4ce                	sd	s3,72(sp)
    80003bdc:	e0d2                	sd	s4,64(sp)
    80003bde:	fc56                	sd	s5,56(sp)
    80003be0:	f85a                	sd	s6,48(sp)
    80003be2:	f45e                	sd	s7,40(sp)
    80003be4:	f062                	sd	s8,32(sp)
    80003be6:	ec66                	sd	s9,24(sp)
    80003be8:	e86a                	sd	s10,16(sp)
    80003bea:	e46e                	sd	s11,8(sp)
    80003bec:	1880                	addi	s0,sp,112
    80003bee:	8baa                	mv	s7,a0
    80003bf0:	8c2e                	mv	s8,a1
    80003bf2:	8ab2                	mv	s5,a2
    80003bf4:	8936                	mv	s2,a3
    80003bf6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bf8:	00e687bb          	addw	a5,a3,a4
    80003bfc:	0ed7e063          	bltu	a5,a3,80003cdc <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c00:	00043737          	lui	a4,0x43
    80003c04:	0cf76e63          	bltu	a4,a5,80003ce0 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c08:	0a0b0763          	beqz	s6,80003cb6 <writei+0xec>
    80003c0c:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c0e:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c12:	5cfd                	li	s9,-1
    80003c14:	a091                	j	80003c58 <writei+0x8e>
    80003c16:	02099d93          	slli	s11,s3,0x20
    80003c1a:	020ddd93          	srli	s11,s11,0x20
    80003c1e:	05848793          	addi	a5,s1,88
    80003c22:	86ee                	mv	a3,s11
    80003c24:	8656                	mv	a2,s5
    80003c26:	85e2                	mv	a1,s8
    80003c28:	953e                	add	a0,a0,a5
    80003c2a:	fffff097          	auipc	ra,0xfffff
    80003c2e:	8fc080e7          	jalr	-1796(ra) # 80002526 <either_copyin>
    80003c32:	07950263          	beq	a0,s9,80003c96 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c36:	8526                	mv	a0,s1
    80003c38:	00000097          	auipc	ra,0x0
    80003c3c:	77a080e7          	jalr	1914(ra) # 800043b2 <log_write>
    brelse(bp);
    80003c40:	8526                	mv	a0,s1
    80003c42:	fffff097          	auipc	ra,0xfffff
    80003c46:	50c080e7          	jalr	1292(ra) # 8000314e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c4a:	01498a3b          	addw	s4,s3,s4
    80003c4e:	0129893b          	addw	s2,s3,s2
    80003c52:	9aee                	add	s5,s5,s11
    80003c54:	056a7663          	bgeu	s4,s6,80003ca0 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c58:	000ba483          	lw	s1,0(s7)
    80003c5c:	00a9559b          	srliw	a1,s2,0xa
    80003c60:	855e                	mv	a0,s7
    80003c62:	fffff097          	auipc	ra,0xfffff
    80003c66:	7b0080e7          	jalr	1968(ra) # 80003412 <bmap>
    80003c6a:	0005059b          	sext.w	a1,a0
    80003c6e:	8526                	mv	a0,s1
    80003c70:	fffff097          	auipc	ra,0xfffff
    80003c74:	3ae080e7          	jalr	942(ra) # 8000301e <bread>
    80003c78:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c7a:	3ff97513          	andi	a0,s2,1023
    80003c7e:	40ad07bb          	subw	a5,s10,a0
    80003c82:	414b073b          	subw	a4,s6,s4
    80003c86:	89be                	mv	s3,a5
    80003c88:	2781                	sext.w	a5,a5
    80003c8a:	0007069b          	sext.w	a3,a4
    80003c8e:	f8f6f4e3          	bgeu	a3,a5,80003c16 <writei+0x4c>
    80003c92:	89ba                	mv	s3,a4
    80003c94:	b749                	j	80003c16 <writei+0x4c>
      brelse(bp);
    80003c96:	8526                	mv	a0,s1
    80003c98:	fffff097          	auipc	ra,0xfffff
    80003c9c:	4b6080e7          	jalr	1206(ra) # 8000314e <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003ca0:	04cba783          	lw	a5,76(s7)
    80003ca4:	0127f463          	bgeu	a5,s2,80003cac <writei+0xe2>
      ip->size = off;
    80003ca8:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003cac:	855e                	mv	a0,s7
    80003cae:	00000097          	auipc	ra,0x0
    80003cb2:	aa8080e7          	jalr	-1368(ra) # 80003756 <iupdate>
  }

  return n;
    80003cb6:	000b051b          	sext.w	a0,s6
}
    80003cba:	70a6                	ld	ra,104(sp)
    80003cbc:	7406                	ld	s0,96(sp)
    80003cbe:	64e6                	ld	s1,88(sp)
    80003cc0:	6946                	ld	s2,80(sp)
    80003cc2:	69a6                	ld	s3,72(sp)
    80003cc4:	6a06                	ld	s4,64(sp)
    80003cc6:	7ae2                	ld	s5,56(sp)
    80003cc8:	7b42                	ld	s6,48(sp)
    80003cca:	7ba2                	ld	s7,40(sp)
    80003ccc:	7c02                	ld	s8,32(sp)
    80003cce:	6ce2                	ld	s9,24(sp)
    80003cd0:	6d42                	ld	s10,16(sp)
    80003cd2:	6da2                	ld	s11,8(sp)
    80003cd4:	6165                	addi	sp,sp,112
    80003cd6:	8082                	ret
    return -1;
    80003cd8:	557d                	li	a0,-1
}
    80003cda:	8082                	ret
    return -1;
    80003cdc:	557d                	li	a0,-1
    80003cde:	bff1                	j	80003cba <writei+0xf0>
    return -1;
    80003ce0:	557d                	li	a0,-1
    80003ce2:	bfe1                	j	80003cba <writei+0xf0>

0000000080003ce4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ce4:	1141                	addi	sp,sp,-16
    80003ce6:	e406                	sd	ra,8(sp)
    80003ce8:	e022                	sd	s0,0(sp)
    80003cea:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003cec:	4639                	li	a2,14
    80003cee:	ffffd097          	auipc	ra,0xffffd
    80003cf2:	150080e7          	jalr	336(ra) # 80000e3e <strncmp>
}
    80003cf6:	60a2                	ld	ra,8(sp)
    80003cf8:	6402                	ld	s0,0(sp)
    80003cfa:	0141                	addi	sp,sp,16
    80003cfc:	8082                	ret

0000000080003cfe <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003cfe:	7139                	addi	sp,sp,-64
    80003d00:	fc06                	sd	ra,56(sp)
    80003d02:	f822                	sd	s0,48(sp)
    80003d04:	f426                	sd	s1,40(sp)
    80003d06:	f04a                	sd	s2,32(sp)
    80003d08:	ec4e                	sd	s3,24(sp)
    80003d0a:	e852                	sd	s4,16(sp)
    80003d0c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d0e:	04451703          	lh	a4,68(a0)
    80003d12:	4785                	li	a5,1
    80003d14:	00f71a63          	bne	a4,a5,80003d28 <dirlookup+0x2a>
    80003d18:	892a                	mv	s2,a0
    80003d1a:	89ae                	mv	s3,a1
    80003d1c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d1e:	457c                	lw	a5,76(a0)
    80003d20:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d22:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d24:	e79d                	bnez	a5,80003d52 <dirlookup+0x54>
    80003d26:	a8a5                	j	80003d9e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d28:	00005517          	auipc	a0,0x5
    80003d2c:	8c850513          	addi	a0,a0,-1848 # 800085f0 <syscalls+0x1b0>
    80003d30:	ffffd097          	auipc	ra,0xffffd
    80003d34:	812080e7          	jalr	-2030(ra) # 80000542 <panic>
      panic("dirlookup read");
    80003d38:	00005517          	auipc	a0,0x5
    80003d3c:	8d050513          	addi	a0,a0,-1840 # 80008608 <syscalls+0x1c8>
    80003d40:	ffffd097          	auipc	ra,0xffffd
    80003d44:	802080e7          	jalr	-2046(ra) # 80000542 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d48:	24c1                	addiw	s1,s1,16
    80003d4a:	04c92783          	lw	a5,76(s2)
    80003d4e:	04f4f763          	bgeu	s1,a5,80003d9c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d52:	4741                	li	a4,16
    80003d54:	86a6                	mv	a3,s1
    80003d56:	fc040613          	addi	a2,s0,-64
    80003d5a:	4581                	li	a1,0
    80003d5c:	854a                	mv	a0,s2
    80003d5e:	00000097          	auipc	ra,0x0
    80003d62:	d76080e7          	jalr	-650(ra) # 80003ad4 <readi>
    80003d66:	47c1                	li	a5,16
    80003d68:	fcf518e3          	bne	a0,a5,80003d38 <dirlookup+0x3a>
    if(de.inum == 0)
    80003d6c:	fc045783          	lhu	a5,-64(s0)
    80003d70:	dfe1                	beqz	a5,80003d48 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003d72:	fc240593          	addi	a1,s0,-62
    80003d76:	854e                	mv	a0,s3
    80003d78:	00000097          	auipc	ra,0x0
    80003d7c:	f6c080e7          	jalr	-148(ra) # 80003ce4 <namecmp>
    80003d80:	f561                	bnez	a0,80003d48 <dirlookup+0x4a>
      if(poff)
    80003d82:	000a0463          	beqz	s4,80003d8a <dirlookup+0x8c>
        *poff = off;
    80003d86:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d8a:	fc045583          	lhu	a1,-64(s0)
    80003d8e:	00092503          	lw	a0,0(s2)
    80003d92:	fffff097          	auipc	ra,0xfffff
    80003d96:	75a080e7          	jalr	1882(ra) # 800034ec <iget>
    80003d9a:	a011                	j	80003d9e <dirlookup+0xa0>
  return 0;
    80003d9c:	4501                	li	a0,0
}
    80003d9e:	70e2                	ld	ra,56(sp)
    80003da0:	7442                	ld	s0,48(sp)
    80003da2:	74a2                	ld	s1,40(sp)
    80003da4:	7902                	ld	s2,32(sp)
    80003da6:	69e2                	ld	s3,24(sp)
    80003da8:	6a42                	ld	s4,16(sp)
    80003daa:	6121                	addi	sp,sp,64
    80003dac:	8082                	ret

0000000080003dae <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003dae:	711d                	addi	sp,sp,-96
    80003db0:	ec86                	sd	ra,88(sp)
    80003db2:	e8a2                	sd	s0,80(sp)
    80003db4:	e4a6                	sd	s1,72(sp)
    80003db6:	e0ca                	sd	s2,64(sp)
    80003db8:	fc4e                	sd	s3,56(sp)
    80003dba:	f852                	sd	s4,48(sp)
    80003dbc:	f456                	sd	s5,40(sp)
    80003dbe:	f05a                	sd	s6,32(sp)
    80003dc0:	ec5e                	sd	s7,24(sp)
    80003dc2:	e862                	sd	s8,16(sp)
    80003dc4:	e466                	sd	s9,8(sp)
    80003dc6:	1080                	addi	s0,sp,96
    80003dc8:	84aa                	mv	s1,a0
    80003dca:	8aae                	mv	s5,a1
    80003dcc:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003dce:	00054703          	lbu	a4,0(a0)
    80003dd2:	02f00793          	li	a5,47
    80003dd6:	02f70363          	beq	a4,a5,80003dfc <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003dda:	ffffe097          	auipc	ra,0xffffe
    80003dde:	c5c080e7          	jalr	-932(ra) # 80001a36 <myproc>
    80003de2:	15053503          	ld	a0,336(a0)
    80003de6:	00000097          	auipc	ra,0x0
    80003dea:	9fc080e7          	jalr	-1540(ra) # 800037e2 <idup>
    80003dee:	89aa                	mv	s3,a0
  while(*path == '/')
    80003df0:	02f00913          	li	s2,47
  len = path - s;
    80003df4:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003df6:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003df8:	4b85                	li	s7,1
    80003dfa:	a865                	j	80003eb2 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003dfc:	4585                	li	a1,1
    80003dfe:	4505                	li	a0,1
    80003e00:	fffff097          	auipc	ra,0xfffff
    80003e04:	6ec080e7          	jalr	1772(ra) # 800034ec <iget>
    80003e08:	89aa                	mv	s3,a0
    80003e0a:	b7dd                	j	80003df0 <namex+0x42>
      iunlockput(ip);
    80003e0c:	854e                	mv	a0,s3
    80003e0e:	00000097          	auipc	ra,0x0
    80003e12:	c74080e7          	jalr	-908(ra) # 80003a82 <iunlockput>
      return 0;
    80003e16:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e18:	854e                	mv	a0,s3
    80003e1a:	60e6                	ld	ra,88(sp)
    80003e1c:	6446                	ld	s0,80(sp)
    80003e1e:	64a6                	ld	s1,72(sp)
    80003e20:	6906                	ld	s2,64(sp)
    80003e22:	79e2                	ld	s3,56(sp)
    80003e24:	7a42                	ld	s4,48(sp)
    80003e26:	7aa2                	ld	s5,40(sp)
    80003e28:	7b02                	ld	s6,32(sp)
    80003e2a:	6be2                	ld	s7,24(sp)
    80003e2c:	6c42                	ld	s8,16(sp)
    80003e2e:	6ca2                	ld	s9,8(sp)
    80003e30:	6125                	addi	sp,sp,96
    80003e32:	8082                	ret
      iunlock(ip);
    80003e34:	854e                	mv	a0,s3
    80003e36:	00000097          	auipc	ra,0x0
    80003e3a:	aac080e7          	jalr	-1364(ra) # 800038e2 <iunlock>
      return ip;
    80003e3e:	bfe9                	j	80003e18 <namex+0x6a>
      iunlockput(ip);
    80003e40:	854e                	mv	a0,s3
    80003e42:	00000097          	auipc	ra,0x0
    80003e46:	c40080e7          	jalr	-960(ra) # 80003a82 <iunlockput>
      return 0;
    80003e4a:	89e6                	mv	s3,s9
    80003e4c:	b7f1                	j	80003e18 <namex+0x6a>
  len = path - s;
    80003e4e:	40b48633          	sub	a2,s1,a1
    80003e52:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003e56:	099c5463          	bge	s8,s9,80003ede <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003e5a:	4639                	li	a2,14
    80003e5c:	8552                	mv	a0,s4
    80003e5e:	ffffd097          	auipc	ra,0xffffd
    80003e62:	f64080e7          	jalr	-156(ra) # 80000dc2 <memmove>
  while(*path == '/')
    80003e66:	0004c783          	lbu	a5,0(s1)
    80003e6a:	01279763          	bne	a5,s2,80003e78 <namex+0xca>
    path++;
    80003e6e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e70:	0004c783          	lbu	a5,0(s1)
    80003e74:	ff278de3          	beq	a5,s2,80003e6e <namex+0xc0>
    ilock(ip);
    80003e78:	854e                	mv	a0,s3
    80003e7a:	00000097          	auipc	ra,0x0
    80003e7e:	9a6080e7          	jalr	-1626(ra) # 80003820 <ilock>
    if(ip->type != T_DIR){
    80003e82:	04499783          	lh	a5,68(s3)
    80003e86:	f97793e3          	bne	a5,s7,80003e0c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003e8a:	000a8563          	beqz	s5,80003e94 <namex+0xe6>
    80003e8e:	0004c783          	lbu	a5,0(s1)
    80003e92:	d3cd                	beqz	a5,80003e34 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e94:	865a                	mv	a2,s6
    80003e96:	85d2                	mv	a1,s4
    80003e98:	854e                	mv	a0,s3
    80003e9a:	00000097          	auipc	ra,0x0
    80003e9e:	e64080e7          	jalr	-412(ra) # 80003cfe <dirlookup>
    80003ea2:	8caa                	mv	s9,a0
    80003ea4:	dd51                	beqz	a0,80003e40 <namex+0x92>
    iunlockput(ip);
    80003ea6:	854e                	mv	a0,s3
    80003ea8:	00000097          	auipc	ra,0x0
    80003eac:	bda080e7          	jalr	-1062(ra) # 80003a82 <iunlockput>
    ip = next;
    80003eb0:	89e6                	mv	s3,s9
  while(*path == '/')
    80003eb2:	0004c783          	lbu	a5,0(s1)
    80003eb6:	05279763          	bne	a5,s2,80003f04 <namex+0x156>
    path++;
    80003eba:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ebc:	0004c783          	lbu	a5,0(s1)
    80003ec0:	ff278de3          	beq	a5,s2,80003eba <namex+0x10c>
  if(*path == 0)
    80003ec4:	c79d                	beqz	a5,80003ef2 <namex+0x144>
    path++;
    80003ec6:	85a6                	mv	a1,s1
  len = path - s;
    80003ec8:	8cda                	mv	s9,s6
    80003eca:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003ecc:	01278963          	beq	a5,s2,80003ede <namex+0x130>
    80003ed0:	dfbd                	beqz	a5,80003e4e <namex+0xa0>
    path++;
    80003ed2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003ed4:	0004c783          	lbu	a5,0(s1)
    80003ed8:	ff279ce3          	bne	a5,s2,80003ed0 <namex+0x122>
    80003edc:	bf8d                	j	80003e4e <namex+0xa0>
    memmove(name, s, len);
    80003ede:	2601                	sext.w	a2,a2
    80003ee0:	8552                	mv	a0,s4
    80003ee2:	ffffd097          	auipc	ra,0xffffd
    80003ee6:	ee0080e7          	jalr	-288(ra) # 80000dc2 <memmove>
    name[len] = 0;
    80003eea:	9cd2                	add	s9,s9,s4
    80003eec:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003ef0:	bf9d                	j	80003e66 <namex+0xb8>
  if(nameiparent){
    80003ef2:	f20a83e3          	beqz	s5,80003e18 <namex+0x6a>
    iput(ip);
    80003ef6:	854e                	mv	a0,s3
    80003ef8:	00000097          	auipc	ra,0x0
    80003efc:	ae2080e7          	jalr	-1310(ra) # 800039da <iput>
    return 0;
    80003f00:	4981                	li	s3,0
    80003f02:	bf19                	j	80003e18 <namex+0x6a>
  if(*path == 0)
    80003f04:	d7fd                	beqz	a5,80003ef2 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003f06:	0004c783          	lbu	a5,0(s1)
    80003f0a:	85a6                	mv	a1,s1
    80003f0c:	b7d1                	j	80003ed0 <namex+0x122>

0000000080003f0e <dirlink>:
{
    80003f0e:	7139                	addi	sp,sp,-64
    80003f10:	fc06                	sd	ra,56(sp)
    80003f12:	f822                	sd	s0,48(sp)
    80003f14:	f426                	sd	s1,40(sp)
    80003f16:	f04a                	sd	s2,32(sp)
    80003f18:	ec4e                	sd	s3,24(sp)
    80003f1a:	e852                	sd	s4,16(sp)
    80003f1c:	0080                	addi	s0,sp,64
    80003f1e:	892a                	mv	s2,a0
    80003f20:	8a2e                	mv	s4,a1
    80003f22:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f24:	4601                	li	a2,0
    80003f26:	00000097          	auipc	ra,0x0
    80003f2a:	dd8080e7          	jalr	-552(ra) # 80003cfe <dirlookup>
    80003f2e:	e93d                	bnez	a0,80003fa4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f30:	04c92483          	lw	s1,76(s2)
    80003f34:	c49d                	beqz	s1,80003f62 <dirlink+0x54>
    80003f36:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f38:	4741                	li	a4,16
    80003f3a:	86a6                	mv	a3,s1
    80003f3c:	fc040613          	addi	a2,s0,-64
    80003f40:	4581                	li	a1,0
    80003f42:	854a                	mv	a0,s2
    80003f44:	00000097          	auipc	ra,0x0
    80003f48:	b90080e7          	jalr	-1136(ra) # 80003ad4 <readi>
    80003f4c:	47c1                	li	a5,16
    80003f4e:	06f51163          	bne	a0,a5,80003fb0 <dirlink+0xa2>
    if(de.inum == 0)
    80003f52:	fc045783          	lhu	a5,-64(s0)
    80003f56:	c791                	beqz	a5,80003f62 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f58:	24c1                	addiw	s1,s1,16
    80003f5a:	04c92783          	lw	a5,76(s2)
    80003f5e:	fcf4ede3          	bltu	s1,a5,80003f38 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003f62:	4639                	li	a2,14
    80003f64:	85d2                	mv	a1,s4
    80003f66:	fc240513          	addi	a0,s0,-62
    80003f6a:	ffffd097          	auipc	ra,0xffffd
    80003f6e:	f10080e7          	jalr	-240(ra) # 80000e7a <strncpy>
  de.inum = inum;
    80003f72:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f76:	4741                	li	a4,16
    80003f78:	86a6                	mv	a3,s1
    80003f7a:	fc040613          	addi	a2,s0,-64
    80003f7e:	4581                	li	a1,0
    80003f80:	854a                	mv	a0,s2
    80003f82:	00000097          	auipc	ra,0x0
    80003f86:	c48080e7          	jalr	-952(ra) # 80003bca <writei>
    80003f8a:	872a                	mv	a4,a0
    80003f8c:	47c1                	li	a5,16
  return 0;
    80003f8e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f90:	02f71863          	bne	a4,a5,80003fc0 <dirlink+0xb2>
}
    80003f94:	70e2                	ld	ra,56(sp)
    80003f96:	7442                	ld	s0,48(sp)
    80003f98:	74a2                	ld	s1,40(sp)
    80003f9a:	7902                	ld	s2,32(sp)
    80003f9c:	69e2                	ld	s3,24(sp)
    80003f9e:	6a42                	ld	s4,16(sp)
    80003fa0:	6121                	addi	sp,sp,64
    80003fa2:	8082                	ret
    iput(ip);
    80003fa4:	00000097          	auipc	ra,0x0
    80003fa8:	a36080e7          	jalr	-1482(ra) # 800039da <iput>
    return -1;
    80003fac:	557d                	li	a0,-1
    80003fae:	b7dd                	j	80003f94 <dirlink+0x86>
      panic("dirlink read");
    80003fb0:	00004517          	auipc	a0,0x4
    80003fb4:	66850513          	addi	a0,a0,1640 # 80008618 <syscalls+0x1d8>
    80003fb8:	ffffc097          	auipc	ra,0xffffc
    80003fbc:	58a080e7          	jalr	1418(ra) # 80000542 <panic>
    panic("dirlink");
    80003fc0:	00004517          	auipc	a0,0x4
    80003fc4:	77850513          	addi	a0,a0,1912 # 80008738 <syscalls+0x2f8>
    80003fc8:	ffffc097          	auipc	ra,0xffffc
    80003fcc:	57a080e7          	jalr	1402(ra) # 80000542 <panic>

0000000080003fd0 <namei>:

struct inode*
namei(char *path)
{
    80003fd0:	1101                	addi	sp,sp,-32
    80003fd2:	ec06                	sd	ra,24(sp)
    80003fd4:	e822                	sd	s0,16(sp)
    80003fd6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003fd8:	fe040613          	addi	a2,s0,-32
    80003fdc:	4581                	li	a1,0
    80003fde:	00000097          	auipc	ra,0x0
    80003fe2:	dd0080e7          	jalr	-560(ra) # 80003dae <namex>
}
    80003fe6:	60e2                	ld	ra,24(sp)
    80003fe8:	6442                	ld	s0,16(sp)
    80003fea:	6105                	addi	sp,sp,32
    80003fec:	8082                	ret

0000000080003fee <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003fee:	1141                	addi	sp,sp,-16
    80003ff0:	e406                	sd	ra,8(sp)
    80003ff2:	e022                	sd	s0,0(sp)
    80003ff4:	0800                	addi	s0,sp,16
    80003ff6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ff8:	4585                	li	a1,1
    80003ffa:	00000097          	auipc	ra,0x0
    80003ffe:	db4080e7          	jalr	-588(ra) # 80003dae <namex>
}
    80004002:	60a2                	ld	ra,8(sp)
    80004004:	6402                	ld	s0,0(sp)
    80004006:	0141                	addi	sp,sp,16
    80004008:	8082                	ret

000000008000400a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000400a:	1101                	addi	sp,sp,-32
    8000400c:	ec06                	sd	ra,24(sp)
    8000400e:	e822                	sd	s0,16(sp)
    80004010:	e426                	sd	s1,8(sp)
    80004012:	e04a                	sd	s2,0(sp)
    80004014:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004016:	0001e917          	auipc	s2,0x1e
    8000401a:	2f290913          	addi	s2,s2,754 # 80022308 <log>
    8000401e:	01892583          	lw	a1,24(s2)
    80004022:	02892503          	lw	a0,40(s2)
    80004026:	fffff097          	auipc	ra,0xfffff
    8000402a:	ff8080e7          	jalr	-8(ra) # 8000301e <bread>
    8000402e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004030:	02c92683          	lw	a3,44(s2)
    80004034:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004036:	02d05763          	blez	a3,80004064 <write_head+0x5a>
    8000403a:	0001e797          	auipc	a5,0x1e
    8000403e:	2fe78793          	addi	a5,a5,766 # 80022338 <log+0x30>
    80004042:	05c50713          	addi	a4,a0,92
    80004046:	36fd                	addiw	a3,a3,-1
    80004048:	1682                	slli	a3,a3,0x20
    8000404a:	9281                	srli	a3,a3,0x20
    8000404c:	068a                	slli	a3,a3,0x2
    8000404e:	0001e617          	auipc	a2,0x1e
    80004052:	2ee60613          	addi	a2,a2,750 # 8002233c <log+0x34>
    80004056:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004058:	4390                	lw	a2,0(a5)
    8000405a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000405c:	0791                	addi	a5,a5,4
    8000405e:	0711                	addi	a4,a4,4
    80004060:	fed79ce3          	bne	a5,a3,80004058 <write_head+0x4e>
  }
  bwrite(buf);
    80004064:	8526                	mv	a0,s1
    80004066:	fffff097          	auipc	ra,0xfffff
    8000406a:	0aa080e7          	jalr	170(ra) # 80003110 <bwrite>
  brelse(buf);
    8000406e:	8526                	mv	a0,s1
    80004070:	fffff097          	auipc	ra,0xfffff
    80004074:	0de080e7          	jalr	222(ra) # 8000314e <brelse>
}
    80004078:	60e2                	ld	ra,24(sp)
    8000407a:	6442                	ld	s0,16(sp)
    8000407c:	64a2                	ld	s1,8(sp)
    8000407e:	6902                	ld	s2,0(sp)
    80004080:	6105                	addi	sp,sp,32
    80004082:	8082                	ret

0000000080004084 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004084:	0001e797          	auipc	a5,0x1e
    80004088:	2b07a783          	lw	a5,688(a5) # 80022334 <log+0x2c>
    8000408c:	0af05663          	blez	a5,80004138 <install_trans+0xb4>
{
    80004090:	7139                	addi	sp,sp,-64
    80004092:	fc06                	sd	ra,56(sp)
    80004094:	f822                	sd	s0,48(sp)
    80004096:	f426                	sd	s1,40(sp)
    80004098:	f04a                	sd	s2,32(sp)
    8000409a:	ec4e                	sd	s3,24(sp)
    8000409c:	e852                	sd	s4,16(sp)
    8000409e:	e456                	sd	s5,8(sp)
    800040a0:	0080                	addi	s0,sp,64
    800040a2:	0001ea97          	auipc	s5,0x1e
    800040a6:	296a8a93          	addi	s5,s5,662 # 80022338 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040aa:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040ac:	0001e997          	auipc	s3,0x1e
    800040b0:	25c98993          	addi	s3,s3,604 # 80022308 <log>
    800040b4:	0189a583          	lw	a1,24(s3)
    800040b8:	014585bb          	addw	a1,a1,s4
    800040bc:	2585                	addiw	a1,a1,1
    800040be:	0289a503          	lw	a0,40(s3)
    800040c2:	fffff097          	auipc	ra,0xfffff
    800040c6:	f5c080e7          	jalr	-164(ra) # 8000301e <bread>
    800040ca:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800040cc:	000aa583          	lw	a1,0(s5)
    800040d0:	0289a503          	lw	a0,40(s3)
    800040d4:	fffff097          	auipc	ra,0xfffff
    800040d8:	f4a080e7          	jalr	-182(ra) # 8000301e <bread>
    800040dc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800040de:	40000613          	li	a2,1024
    800040e2:	05890593          	addi	a1,s2,88
    800040e6:	05850513          	addi	a0,a0,88
    800040ea:	ffffd097          	auipc	ra,0xffffd
    800040ee:	cd8080e7          	jalr	-808(ra) # 80000dc2 <memmove>
    bwrite(dbuf);  // write dst to disk
    800040f2:	8526                	mv	a0,s1
    800040f4:	fffff097          	auipc	ra,0xfffff
    800040f8:	01c080e7          	jalr	28(ra) # 80003110 <bwrite>
    bunpin(dbuf);
    800040fc:	8526                	mv	a0,s1
    800040fe:	fffff097          	auipc	ra,0xfffff
    80004102:	12a080e7          	jalr	298(ra) # 80003228 <bunpin>
    brelse(lbuf);
    80004106:	854a                	mv	a0,s2
    80004108:	fffff097          	auipc	ra,0xfffff
    8000410c:	046080e7          	jalr	70(ra) # 8000314e <brelse>
    brelse(dbuf);
    80004110:	8526                	mv	a0,s1
    80004112:	fffff097          	auipc	ra,0xfffff
    80004116:	03c080e7          	jalr	60(ra) # 8000314e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000411a:	2a05                	addiw	s4,s4,1
    8000411c:	0a91                	addi	s5,s5,4
    8000411e:	02c9a783          	lw	a5,44(s3)
    80004122:	f8fa49e3          	blt	s4,a5,800040b4 <install_trans+0x30>
}
    80004126:	70e2                	ld	ra,56(sp)
    80004128:	7442                	ld	s0,48(sp)
    8000412a:	74a2                	ld	s1,40(sp)
    8000412c:	7902                	ld	s2,32(sp)
    8000412e:	69e2                	ld	s3,24(sp)
    80004130:	6a42                	ld	s4,16(sp)
    80004132:	6aa2                	ld	s5,8(sp)
    80004134:	6121                	addi	sp,sp,64
    80004136:	8082                	ret
    80004138:	8082                	ret

000000008000413a <initlog>:
{
    8000413a:	7179                	addi	sp,sp,-48
    8000413c:	f406                	sd	ra,40(sp)
    8000413e:	f022                	sd	s0,32(sp)
    80004140:	ec26                	sd	s1,24(sp)
    80004142:	e84a                	sd	s2,16(sp)
    80004144:	e44e                	sd	s3,8(sp)
    80004146:	1800                	addi	s0,sp,48
    80004148:	892a                	mv	s2,a0
    8000414a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000414c:	0001e497          	auipc	s1,0x1e
    80004150:	1bc48493          	addi	s1,s1,444 # 80022308 <log>
    80004154:	00004597          	auipc	a1,0x4
    80004158:	4d458593          	addi	a1,a1,1236 # 80008628 <syscalls+0x1e8>
    8000415c:	8526                	mv	a0,s1
    8000415e:	ffffd097          	auipc	ra,0xffffd
    80004162:	a7c080e7          	jalr	-1412(ra) # 80000bda <initlock>
  log.start = sb->logstart;
    80004166:	0149a583          	lw	a1,20(s3)
    8000416a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000416c:	0109a783          	lw	a5,16(s3)
    80004170:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004172:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004176:	854a                	mv	a0,s2
    80004178:	fffff097          	auipc	ra,0xfffff
    8000417c:	ea6080e7          	jalr	-346(ra) # 8000301e <bread>
  log.lh.n = lh->n;
    80004180:	4d34                	lw	a3,88(a0)
    80004182:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004184:	02d05563          	blez	a3,800041ae <initlog+0x74>
    80004188:	05c50793          	addi	a5,a0,92
    8000418c:	0001e717          	auipc	a4,0x1e
    80004190:	1ac70713          	addi	a4,a4,428 # 80022338 <log+0x30>
    80004194:	36fd                	addiw	a3,a3,-1
    80004196:	1682                	slli	a3,a3,0x20
    80004198:	9281                	srli	a3,a3,0x20
    8000419a:	068a                	slli	a3,a3,0x2
    8000419c:	06050613          	addi	a2,a0,96
    800041a0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800041a2:	4390                	lw	a2,0(a5)
    800041a4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041a6:	0791                	addi	a5,a5,4
    800041a8:	0711                	addi	a4,a4,4
    800041aa:	fed79ce3          	bne	a5,a3,800041a2 <initlog+0x68>
  brelse(buf);
    800041ae:	fffff097          	auipc	ra,0xfffff
    800041b2:	fa0080e7          	jalr	-96(ra) # 8000314e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800041b6:	00000097          	auipc	ra,0x0
    800041ba:	ece080e7          	jalr	-306(ra) # 80004084 <install_trans>
  log.lh.n = 0;
    800041be:	0001e797          	auipc	a5,0x1e
    800041c2:	1607ab23          	sw	zero,374(a5) # 80022334 <log+0x2c>
  write_head(); // clear the log
    800041c6:	00000097          	auipc	ra,0x0
    800041ca:	e44080e7          	jalr	-444(ra) # 8000400a <write_head>
}
    800041ce:	70a2                	ld	ra,40(sp)
    800041d0:	7402                	ld	s0,32(sp)
    800041d2:	64e2                	ld	s1,24(sp)
    800041d4:	6942                	ld	s2,16(sp)
    800041d6:	69a2                	ld	s3,8(sp)
    800041d8:	6145                	addi	sp,sp,48
    800041da:	8082                	ret

00000000800041dc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800041dc:	1101                	addi	sp,sp,-32
    800041de:	ec06                	sd	ra,24(sp)
    800041e0:	e822                	sd	s0,16(sp)
    800041e2:	e426                	sd	s1,8(sp)
    800041e4:	e04a                	sd	s2,0(sp)
    800041e6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800041e8:	0001e517          	auipc	a0,0x1e
    800041ec:	12050513          	addi	a0,a0,288 # 80022308 <log>
    800041f0:	ffffd097          	auipc	ra,0xffffd
    800041f4:	a7a080e7          	jalr	-1414(ra) # 80000c6a <acquire>
  while(1){
    if(log.committing){
    800041f8:	0001e497          	auipc	s1,0x1e
    800041fc:	11048493          	addi	s1,s1,272 # 80022308 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004200:	4979                	li	s2,30
    80004202:	a039                	j	80004210 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004204:	85a6                	mv	a1,s1
    80004206:	8526                	mv	a0,s1
    80004208:	ffffe097          	auipc	ra,0xffffe
    8000420c:	06e080e7          	jalr	110(ra) # 80002276 <sleep>
    if(log.committing){
    80004210:	50dc                	lw	a5,36(s1)
    80004212:	fbed                	bnez	a5,80004204 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004214:	509c                	lw	a5,32(s1)
    80004216:	0017871b          	addiw	a4,a5,1
    8000421a:	0007069b          	sext.w	a3,a4
    8000421e:	0027179b          	slliw	a5,a4,0x2
    80004222:	9fb9                	addw	a5,a5,a4
    80004224:	0017979b          	slliw	a5,a5,0x1
    80004228:	54d8                	lw	a4,44(s1)
    8000422a:	9fb9                	addw	a5,a5,a4
    8000422c:	00f95963          	bge	s2,a5,8000423e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004230:	85a6                	mv	a1,s1
    80004232:	8526                	mv	a0,s1
    80004234:	ffffe097          	auipc	ra,0xffffe
    80004238:	042080e7          	jalr	66(ra) # 80002276 <sleep>
    8000423c:	bfd1                	j	80004210 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000423e:	0001e517          	auipc	a0,0x1e
    80004242:	0ca50513          	addi	a0,a0,202 # 80022308 <log>
    80004246:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004248:	ffffd097          	auipc	ra,0xffffd
    8000424c:	ad6080e7          	jalr	-1322(ra) # 80000d1e <release>
      break;
    }
  }
}
    80004250:	60e2                	ld	ra,24(sp)
    80004252:	6442                	ld	s0,16(sp)
    80004254:	64a2                	ld	s1,8(sp)
    80004256:	6902                	ld	s2,0(sp)
    80004258:	6105                	addi	sp,sp,32
    8000425a:	8082                	ret

000000008000425c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000425c:	7139                	addi	sp,sp,-64
    8000425e:	fc06                	sd	ra,56(sp)
    80004260:	f822                	sd	s0,48(sp)
    80004262:	f426                	sd	s1,40(sp)
    80004264:	f04a                	sd	s2,32(sp)
    80004266:	ec4e                	sd	s3,24(sp)
    80004268:	e852                	sd	s4,16(sp)
    8000426a:	e456                	sd	s5,8(sp)
    8000426c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000426e:	0001e497          	auipc	s1,0x1e
    80004272:	09a48493          	addi	s1,s1,154 # 80022308 <log>
    80004276:	8526                	mv	a0,s1
    80004278:	ffffd097          	auipc	ra,0xffffd
    8000427c:	9f2080e7          	jalr	-1550(ra) # 80000c6a <acquire>
  log.outstanding -= 1;
    80004280:	509c                	lw	a5,32(s1)
    80004282:	37fd                	addiw	a5,a5,-1
    80004284:	0007891b          	sext.w	s2,a5
    80004288:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000428a:	50dc                	lw	a5,36(s1)
    8000428c:	e7b9                	bnez	a5,800042da <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000428e:	04091e63          	bnez	s2,800042ea <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004292:	0001e497          	auipc	s1,0x1e
    80004296:	07648493          	addi	s1,s1,118 # 80022308 <log>
    8000429a:	4785                	li	a5,1
    8000429c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000429e:	8526                	mv	a0,s1
    800042a0:	ffffd097          	auipc	ra,0xffffd
    800042a4:	a7e080e7          	jalr	-1410(ra) # 80000d1e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800042a8:	54dc                	lw	a5,44(s1)
    800042aa:	06f04763          	bgtz	a5,80004318 <end_op+0xbc>
    acquire(&log.lock);
    800042ae:	0001e497          	auipc	s1,0x1e
    800042b2:	05a48493          	addi	s1,s1,90 # 80022308 <log>
    800042b6:	8526                	mv	a0,s1
    800042b8:	ffffd097          	auipc	ra,0xffffd
    800042bc:	9b2080e7          	jalr	-1614(ra) # 80000c6a <acquire>
    log.committing = 0;
    800042c0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800042c4:	8526                	mv	a0,s1
    800042c6:	ffffe097          	auipc	ra,0xffffe
    800042ca:	130080e7          	jalr	304(ra) # 800023f6 <wakeup>
    release(&log.lock);
    800042ce:	8526                	mv	a0,s1
    800042d0:	ffffd097          	auipc	ra,0xffffd
    800042d4:	a4e080e7          	jalr	-1458(ra) # 80000d1e <release>
}
    800042d8:	a03d                	j	80004306 <end_op+0xaa>
    panic("log.committing");
    800042da:	00004517          	auipc	a0,0x4
    800042de:	35650513          	addi	a0,a0,854 # 80008630 <syscalls+0x1f0>
    800042e2:	ffffc097          	auipc	ra,0xffffc
    800042e6:	260080e7          	jalr	608(ra) # 80000542 <panic>
    wakeup(&log);
    800042ea:	0001e497          	auipc	s1,0x1e
    800042ee:	01e48493          	addi	s1,s1,30 # 80022308 <log>
    800042f2:	8526                	mv	a0,s1
    800042f4:	ffffe097          	auipc	ra,0xffffe
    800042f8:	102080e7          	jalr	258(ra) # 800023f6 <wakeup>
  release(&log.lock);
    800042fc:	8526                	mv	a0,s1
    800042fe:	ffffd097          	auipc	ra,0xffffd
    80004302:	a20080e7          	jalr	-1504(ra) # 80000d1e <release>
}
    80004306:	70e2                	ld	ra,56(sp)
    80004308:	7442                	ld	s0,48(sp)
    8000430a:	74a2                	ld	s1,40(sp)
    8000430c:	7902                	ld	s2,32(sp)
    8000430e:	69e2                	ld	s3,24(sp)
    80004310:	6a42                	ld	s4,16(sp)
    80004312:	6aa2                	ld	s5,8(sp)
    80004314:	6121                	addi	sp,sp,64
    80004316:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004318:	0001ea97          	auipc	s5,0x1e
    8000431c:	020a8a93          	addi	s5,s5,32 # 80022338 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004320:	0001ea17          	auipc	s4,0x1e
    80004324:	fe8a0a13          	addi	s4,s4,-24 # 80022308 <log>
    80004328:	018a2583          	lw	a1,24(s4)
    8000432c:	012585bb          	addw	a1,a1,s2
    80004330:	2585                	addiw	a1,a1,1
    80004332:	028a2503          	lw	a0,40(s4)
    80004336:	fffff097          	auipc	ra,0xfffff
    8000433a:	ce8080e7          	jalr	-792(ra) # 8000301e <bread>
    8000433e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004340:	000aa583          	lw	a1,0(s5)
    80004344:	028a2503          	lw	a0,40(s4)
    80004348:	fffff097          	auipc	ra,0xfffff
    8000434c:	cd6080e7          	jalr	-810(ra) # 8000301e <bread>
    80004350:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004352:	40000613          	li	a2,1024
    80004356:	05850593          	addi	a1,a0,88
    8000435a:	05848513          	addi	a0,s1,88
    8000435e:	ffffd097          	auipc	ra,0xffffd
    80004362:	a64080e7          	jalr	-1436(ra) # 80000dc2 <memmove>
    bwrite(to);  // write the log
    80004366:	8526                	mv	a0,s1
    80004368:	fffff097          	auipc	ra,0xfffff
    8000436c:	da8080e7          	jalr	-600(ra) # 80003110 <bwrite>
    brelse(from);
    80004370:	854e                	mv	a0,s3
    80004372:	fffff097          	auipc	ra,0xfffff
    80004376:	ddc080e7          	jalr	-548(ra) # 8000314e <brelse>
    brelse(to);
    8000437a:	8526                	mv	a0,s1
    8000437c:	fffff097          	auipc	ra,0xfffff
    80004380:	dd2080e7          	jalr	-558(ra) # 8000314e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004384:	2905                	addiw	s2,s2,1
    80004386:	0a91                	addi	s5,s5,4
    80004388:	02ca2783          	lw	a5,44(s4)
    8000438c:	f8f94ee3          	blt	s2,a5,80004328 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004390:	00000097          	auipc	ra,0x0
    80004394:	c7a080e7          	jalr	-902(ra) # 8000400a <write_head>
    install_trans(); // Now install writes to home locations
    80004398:	00000097          	auipc	ra,0x0
    8000439c:	cec080e7          	jalr	-788(ra) # 80004084 <install_trans>
    log.lh.n = 0;
    800043a0:	0001e797          	auipc	a5,0x1e
    800043a4:	f807aa23          	sw	zero,-108(a5) # 80022334 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800043a8:	00000097          	auipc	ra,0x0
    800043ac:	c62080e7          	jalr	-926(ra) # 8000400a <write_head>
    800043b0:	bdfd                	j	800042ae <end_op+0x52>

00000000800043b2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800043b2:	1101                	addi	sp,sp,-32
    800043b4:	ec06                	sd	ra,24(sp)
    800043b6:	e822                	sd	s0,16(sp)
    800043b8:	e426                	sd	s1,8(sp)
    800043ba:	e04a                	sd	s2,0(sp)
    800043bc:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800043be:	0001e717          	auipc	a4,0x1e
    800043c2:	f7672703          	lw	a4,-138(a4) # 80022334 <log+0x2c>
    800043c6:	47f5                	li	a5,29
    800043c8:	08e7c063          	blt	a5,a4,80004448 <log_write+0x96>
    800043cc:	84aa                	mv	s1,a0
    800043ce:	0001e797          	auipc	a5,0x1e
    800043d2:	f567a783          	lw	a5,-170(a5) # 80022324 <log+0x1c>
    800043d6:	37fd                	addiw	a5,a5,-1
    800043d8:	06f75863          	bge	a4,a5,80004448 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800043dc:	0001e797          	auipc	a5,0x1e
    800043e0:	f4c7a783          	lw	a5,-180(a5) # 80022328 <log+0x20>
    800043e4:	06f05a63          	blez	a5,80004458 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800043e8:	0001e917          	auipc	s2,0x1e
    800043ec:	f2090913          	addi	s2,s2,-224 # 80022308 <log>
    800043f0:	854a                	mv	a0,s2
    800043f2:	ffffd097          	auipc	ra,0xffffd
    800043f6:	878080e7          	jalr	-1928(ra) # 80000c6a <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800043fa:	02c92603          	lw	a2,44(s2)
    800043fe:	06c05563          	blez	a2,80004468 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004402:	44cc                	lw	a1,12(s1)
    80004404:	0001e717          	auipc	a4,0x1e
    80004408:	f3470713          	addi	a4,a4,-204 # 80022338 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000440c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000440e:	4314                	lw	a3,0(a4)
    80004410:	04b68d63          	beq	a3,a1,8000446a <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004414:	2785                	addiw	a5,a5,1
    80004416:	0711                	addi	a4,a4,4
    80004418:	fec79be3          	bne	a5,a2,8000440e <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000441c:	0621                	addi	a2,a2,8
    8000441e:	060a                	slli	a2,a2,0x2
    80004420:	0001e797          	auipc	a5,0x1e
    80004424:	ee878793          	addi	a5,a5,-280 # 80022308 <log>
    80004428:	963e                	add	a2,a2,a5
    8000442a:	44dc                	lw	a5,12(s1)
    8000442c:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000442e:	8526                	mv	a0,s1
    80004430:	fffff097          	auipc	ra,0xfffff
    80004434:	dbc080e7          	jalr	-580(ra) # 800031ec <bpin>
    log.lh.n++;
    80004438:	0001e717          	auipc	a4,0x1e
    8000443c:	ed070713          	addi	a4,a4,-304 # 80022308 <log>
    80004440:	575c                	lw	a5,44(a4)
    80004442:	2785                	addiw	a5,a5,1
    80004444:	d75c                	sw	a5,44(a4)
    80004446:	a83d                	j	80004484 <log_write+0xd2>
    panic("too big a transaction");
    80004448:	00004517          	auipc	a0,0x4
    8000444c:	1f850513          	addi	a0,a0,504 # 80008640 <syscalls+0x200>
    80004450:	ffffc097          	auipc	ra,0xffffc
    80004454:	0f2080e7          	jalr	242(ra) # 80000542 <panic>
    panic("log_write outside of trans");
    80004458:	00004517          	auipc	a0,0x4
    8000445c:	20050513          	addi	a0,a0,512 # 80008658 <syscalls+0x218>
    80004460:	ffffc097          	auipc	ra,0xffffc
    80004464:	0e2080e7          	jalr	226(ra) # 80000542 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004468:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    8000446a:	00878713          	addi	a4,a5,8
    8000446e:	00271693          	slli	a3,a4,0x2
    80004472:	0001e717          	auipc	a4,0x1e
    80004476:	e9670713          	addi	a4,a4,-362 # 80022308 <log>
    8000447a:	9736                	add	a4,a4,a3
    8000447c:	44d4                	lw	a3,12(s1)
    8000447e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004480:	faf607e3          	beq	a2,a5,8000442e <log_write+0x7c>
  }
  release(&log.lock);
    80004484:	0001e517          	auipc	a0,0x1e
    80004488:	e8450513          	addi	a0,a0,-380 # 80022308 <log>
    8000448c:	ffffd097          	auipc	ra,0xffffd
    80004490:	892080e7          	jalr	-1902(ra) # 80000d1e <release>
}
    80004494:	60e2                	ld	ra,24(sp)
    80004496:	6442                	ld	s0,16(sp)
    80004498:	64a2                	ld	s1,8(sp)
    8000449a:	6902                	ld	s2,0(sp)
    8000449c:	6105                	addi	sp,sp,32
    8000449e:	8082                	ret

00000000800044a0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044a0:	1101                	addi	sp,sp,-32
    800044a2:	ec06                	sd	ra,24(sp)
    800044a4:	e822                	sd	s0,16(sp)
    800044a6:	e426                	sd	s1,8(sp)
    800044a8:	e04a                	sd	s2,0(sp)
    800044aa:	1000                	addi	s0,sp,32
    800044ac:	84aa                	mv	s1,a0
    800044ae:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800044b0:	00004597          	auipc	a1,0x4
    800044b4:	1c858593          	addi	a1,a1,456 # 80008678 <syscalls+0x238>
    800044b8:	0521                	addi	a0,a0,8
    800044ba:	ffffc097          	auipc	ra,0xffffc
    800044be:	720080e7          	jalr	1824(ra) # 80000bda <initlock>
  lk->name = name;
    800044c2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800044c6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044ca:	0204a423          	sw	zero,40(s1)
}
    800044ce:	60e2                	ld	ra,24(sp)
    800044d0:	6442                	ld	s0,16(sp)
    800044d2:	64a2                	ld	s1,8(sp)
    800044d4:	6902                	ld	s2,0(sp)
    800044d6:	6105                	addi	sp,sp,32
    800044d8:	8082                	ret

00000000800044da <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044da:	1101                	addi	sp,sp,-32
    800044dc:	ec06                	sd	ra,24(sp)
    800044de:	e822                	sd	s0,16(sp)
    800044e0:	e426                	sd	s1,8(sp)
    800044e2:	e04a                	sd	s2,0(sp)
    800044e4:	1000                	addi	s0,sp,32
    800044e6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044e8:	00850913          	addi	s2,a0,8
    800044ec:	854a                	mv	a0,s2
    800044ee:	ffffc097          	auipc	ra,0xffffc
    800044f2:	77c080e7          	jalr	1916(ra) # 80000c6a <acquire>
  while (lk->locked) {
    800044f6:	409c                	lw	a5,0(s1)
    800044f8:	cb89                	beqz	a5,8000450a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800044fa:	85ca                	mv	a1,s2
    800044fc:	8526                	mv	a0,s1
    800044fe:	ffffe097          	auipc	ra,0xffffe
    80004502:	d78080e7          	jalr	-648(ra) # 80002276 <sleep>
  while (lk->locked) {
    80004506:	409c                	lw	a5,0(s1)
    80004508:	fbed                	bnez	a5,800044fa <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000450a:	4785                	li	a5,1
    8000450c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000450e:	ffffd097          	auipc	ra,0xffffd
    80004512:	528080e7          	jalr	1320(ra) # 80001a36 <myproc>
    80004516:	5d1c                	lw	a5,56(a0)
    80004518:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000451a:	854a                	mv	a0,s2
    8000451c:	ffffd097          	auipc	ra,0xffffd
    80004520:	802080e7          	jalr	-2046(ra) # 80000d1e <release>
}
    80004524:	60e2                	ld	ra,24(sp)
    80004526:	6442                	ld	s0,16(sp)
    80004528:	64a2                	ld	s1,8(sp)
    8000452a:	6902                	ld	s2,0(sp)
    8000452c:	6105                	addi	sp,sp,32
    8000452e:	8082                	ret

0000000080004530 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004530:	1101                	addi	sp,sp,-32
    80004532:	ec06                	sd	ra,24(sp)
    80004534:	e822                	sd	s0,16(sp)
    80004536:	e426                	sd	s1,8(sp)
    80004538:	e04a                	sd	s2,0(sp)
    8000453a:	1000                	addi	s0,sp,32
    8000453c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000453e:	00850913          	addi	s2,a0,8
    80004542:	854a                	mv	a0,s2
    80004544:	ffffc097          	auipc	ra,0xffffc
    80004548:	726080e7          	jalr	1830(ra) # 80000c6a <acquire>
  lk->locked = 0;
    8000454c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004550:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004554:	8526                	mv	a0,s1
    80004556:	ffffe097          	auipc	ra,0xffffe
    8000455a:	ea0080e7          	jalr	-352(ra) # 800023f6 <wakeup>
  release(&lk->lk);
    8000455e:	854a                	mv	a0,s2
    80004560:	ffffc097          	auipc	ra,0xffffc
    80004564:	7be080e7          	jalr	1982(ra) # 80000d1e <release>
}
    80004568:	60e2                	ld	ra,24(sp)
    8000456a:	6442                	ld	s0,16(sp)
    8000456c:	64a2                	ld	s1,8(sp)
    8000456e:	6902                	ld	s2,0(sp)
    80004570:	6105                	addi	sp,sp,32
    80004572:	8082                	ret

0000000080004574 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004574:	7179                	addi	sp,sp,-48
    80004576:	f406                	sd	ra,40(sp)
    80004578:	f022                	sd	s0,32(sp)
    8000457a:	ec26                	sd	s1,24(sp)
    8000457c:	e84a                	sd	s2,16(sp)
    8000457e:	e44e                	sd	s3,8(sp)
    80004580:	1800                	addi	s0,sp,48
    80004582:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004584:	00850913          	addi	s2,a0,8
    80004588:	854a                	mv	a0,s2
    8000458a:	ffffc097          	auipc	ra,0xffffc
    8000458e:	6e0080e7          	jalr	1760(ra) # 80000c6a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004592:	409c                	lw	a5,0(s1)
    80004594:	ef99                	bnez	a5,800045b2 <holdingsleep+0x3e>
    80004596:	4481                	li	s1,0
  release(&lk->lk);
    80004598:	854a                	mv	a0,s2
    8000459a:	ffffc097          	auipc	ra,0xffffc
    8000459e:	784080e7          	jalr	1924(ra) # 80000d1e <release>
  return r;
}
    800045a2:	8526                	mv	a0,s1
    800045a4:	70a2                	ld	ra,40(sp)
    800045a6:	7402                	ld	s0,32(sp)
    800045a8:	64e2                	ld	s1,24(sp)
    800045aa:	6942                	ld	s2,16(sp)
    800045ac:	69a2                	ld	s3,8(sp)
    800045ae:	6145                	addi	sp,sp,48
    800045b0:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800045b2:	0284a983          	lw	s3,40(s1)
    800045b6:	ffffd097          	auipc	ra,0xffffd
    800045ba:	480080e7          	jalr	1152(ra) # 80001a36 <myproc>
    800045be:	5d04                	lw	s1,56(a0)
    800045c0:	413484b3          	sub	s1,s1,s3
    800045c4:	0014b493          	seqz	s1,s1
    800045c8:	bfc1                	j	80004598 <holdingsleep+0x24>

00000000800045ca <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800045ca:	1141                	addi	sp,sp,-16
    800045cc:	e406                	sd	ra,8(sp)
    800045ce:	e022                	sd	s0,0(sp)
    800045d0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800045d2:	00004597          	auipc	a1,0x4
    800045d6:	0b658593          	addi	a1,a1,182 # 80008688 <syscalls+0x248>
    800045da:	0001e517          	auipc	a0,0x1e
    800045de:	e7650513          	addi	a0,a0,-394 # 80022450 <ftable>
    800045e2:	ffffc097          	auipc	ra,0xffffc
    800045e6:	5f8080e7          	jalr	1528(ra) # 80000bda <initlock>
}
    800045ea:	60a2                	ld	ra,8(sp)
    800045ec:	6402                	ld	s0,0(sp)
    800045ee:	0141                	addi	sp,sp,16
    800045f0:	8082                	ret

00000000800045f2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045f2:	1101                	addi	sp,sp,-32
    800045f4:	ec06                	sd	ra,24(sp)
    800045f6:	e822                	sd	s0,16(sp)
    800045f8:	e426                	sd	s1,8(sp)
    800045fa:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045fc:	0001e517          	auipc	a0,0x1e
    80004600:	e5450513          	addi	a0,a0,-428 # 80022450 <ftable>
    80004604:	ffffc097          	auipc	ra,0xffffc
    80004608:	666080e7          	jalr	1638(ra) # 80000c6a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000460c:	0001e497          	auipc	s1,0x1e
    80004610:	e5c48493          	addi	s1,s1,-420 # 80022468 <ftable+0x18>
    80004614:	0001f717          	auipc	a4,0x1f
    80004618:	df470713          	addi	a4,a4,-524 # 80023408 <ftable+0xfb8>
    if(f->ref == 0){
    8000461c:	40dc                	lw	a5,4(s1)
    8000461e:	cf99                	beqz	a5,8000463c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004620:	02848493          	addi	s1,s1,40
    80004624:	fee49ce3          	bne	s1,a4,8000461c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004628:	0001e517          	auipc	a0,0x1e
    8000462c:	e2850513          	addi	a0,a0,-472 # 80022450 <ftable>
    80004630:	ffffc097          	auipc	ra,0xffffc
    80004634:	6ee080e7          	jalr	1774(ra) # 80000d1e <release>
  return 0;
    80004638:	4481                	li	s1,0
    8000463a:	a819                	j	80004650 <filealloc+0x5e>
      f->ref = 1;
    8000463c:	4785                	li	a5,1
    8000463e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004640:	0001e517          	auipc	a0,0x1e
    80004644:	e1050513          	addi	a0,a0,-496 # 80022450 <ftable>
    80004648:	ffffc097          	auipc	ra,0xffffc
    8000464c:	6d6080e7          	jalr	1750(ra) # 80000d1e <release>
}
    80004650:	8526                	mv	a0,s1
    80004652:	60e2                	ld	ra,24(sp)
    80004654:	6442                	ld	s0,16(sp)
    80004656:	64a2                	ld	s1,8(sp)
    80004658:	6105                	addi	sp,sp,32
    8000465a:	8082                	ret

000000008000465c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000465c:	1101                	addi	sp,sp,-32
    8000465e:	ec06                	sd	ra,24(sp)
    80004660:	e822                	sd	s0,16(sp)
    80004662:	e426                	sd	s1,8(sp)
    80004664:	1000                	addi	s0,sp,32
    80004666:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004668:	0001e517          	auipc	a0,0x1e
    8000466c:	de850513          	addi	a0,a0,-536 # 80022450 <ftable>
    80004670:	ffffc097          	auipc	ra,0xffffc
    80004674:	5fa080e7          	jalr	1530(ra) # 80000c6a <acquire>
  if(f->ref < 1)
    80004678:	40dc                	lw	a5,4(s1)
    8000467a:	02f05263          	blez	a5,8000469e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000467e:	2785                	addiw	a5,a5,1
    80004680:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004682:	0001e517          	auipc	a0,0x1e
    80004686:	dce50513          	addi	a0,a0,-562 # 80022450 <ftable>
    8000468a:	ffffc097          	auipc	ra,0xffffc
    8000468e:	694080e7          	jalr	1684(ra) # 80000d1e <release>
  return f;
}
    80004692:	8526                	mv	a0,s1
    80004694:	60e2                	ld	ra,24(sp)
    80004696:	6442                	ld	s0,16(sp)
    80004698:	64a2                	ld	s1,8(sp)
    8000469a:	6105                	addi	sp,sp,32
    8000469c:	8082                	ret
    panic("filedup");
    8000469e:	00004517          	auipc	a0,0x4
    800046a2:	ff250513          	addi	a0,a0,-14 # 80008690 <syscalls+0x250>
    800046a6:	ffffc097          	auipc	ra,0xffffc
    800046aa:	e9c080e7          	jalr	-356(ra) # 80000542 <panic>

00000000800046ae <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800046ae:	7139                	addi	sp,sp,-64
    800046b0:	fc06                	sd	ra,56(sp)
    800046b2:	f822                	sd	s0,48(sp)
    800046b4:	f426                	sd	s1,40(sp)
    800046b6:	f04a                	sd	s2,32(sp)
    800046b8:	ec4e                	sd	s3,24(sp)
    800046ba:	e852                	sd	s4,16(sp)
    800046bc:	e456                	sd	s5,8(sp)
    800046be:	0080                	addi	s0,sp,64
    800046c0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800046c2:	0001e517          	auipc	a0,0x1e
    800046c6:	d8e50513          	addi	a0,a0,-626 # 80022450 <ftable>
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	5a0080e7          	jalr	1440(ra) # 80000c6a <acquire>
  if(f->ref < 1)
    800046d2:	40dc                	lw	a5,4(s1)
    800046d4:	06f05163          	blez	a5,80004736 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800046d8:	37fd                	addiw	a5,a5,-1
    800046da:	0007871b          	sext.w	a4,a5
    800046de:	c0dc                	sw	a5,4(s1)
    800046e0:	06e04363          	bgtz	a4,80004746 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046e4:	0004a903          	lw	s2,0(s1)
    800046e8:	0094ca83          	lbu	s5,9(s1)
    800046ec:	0104ba03          	ld	s4,16(s1)
    800046f0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800046f4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800046f8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800046fc:	0001e517          	auipc	a0,0x1e
    80004700:	d5450513          	addi	a0,a0,-684 # 80022450 <ftable>
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	61a080e7          	jalr	1562(ra) # 80000d1e <release>

  if(ff.type == FD_PIPE){
    8000470c:	4785                	li	a5,1
    8000470e:	04f90d63          	beq	s2,a5,80004768 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004712:	3979                	addiw	s2,s2,-2
    80004714:	4785                	li	a5,1
    80004716:	0527e063          	bltu	a5,s2,80004756 <fileclose+0xa8>
    begin_op();
    8000471a:	00000097          	auipc	ra,0x0
    8000471e:	ac2080e7          	jalr	-1342(ra) # 800041dc <begin_op>
    iput(ff.ip);
    80004722:	854e                	mv	a0,s3
    80004724:	fffff097          	auipc	ra,0xfffff
    80004728:	2b6080e7          	jalr	694(ra) # 800039da <iput>
    end_op();
    8000472c:	00000097          	auipc	ra,0x0
    80004730:	b30080e7          	jalr	-1232(ra) # 8000425c <end_op>
    80004734:	a00d                	j	80004756 <fileclose+0xa8>
    panic("fileclose");
    80004736:	00004517          	auipc	a0,0x4
    8000473a:	f6250513          	addi	a0,a0,-158 # 80008698 <syscalls+0x258>
    8000473e:	ffffc097          	auipc	ra,0xffffc
    80004742:	e04080e7          	jalr	-508(ra) # 80000542 <panic>
    release(&ftable.lock);
    80004746:	0001e517          	auipc	a0,0x1e
    8000474a:	d0a50513          	addi	a0,a0,-758 # 80022450 <ftable>
    8000474e:	ffffc097          	auipc	ra,0xffffc
    80004752:	5d0080e7          	jalr	1488(ra) # 80000d1e <release>
  }
}
    80004756:	70e2                	ld	ra,56(sp)
    80004758:	7442                	ld	s0,48(sp)
    8000475a:	74a2                	ld	s1,40(sp)
    8000475c:	7902                	ld	s2,32(sp)
    8000475e:	69e2                	ld	s3,24(sp)
    80004760:	6a42                	ld	s4,16(sp)
    80004762:	6aa2                	ld	s5,8(sp)
    80004764:	6121                	addi	sp,sp,64
    80004766:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004768:	85d6                	mv	a1,s5
    8000476a:	8552                	mv	a0,s4
    8000476c:	00000097          	auipc	ra,0x0
    80004770:	372080e7          	jalr	882(ra) # 80004ade <pipeclose>
    80004774:	b7cd                	j	80004756 <fileclose+0xa8>

0000000080004776 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004776:	715d                	addi	sp,sp,-80
    80004778:	e486                	sd	ra,72(sp)
    8000477a:	e0a2                	sd	s0,64(sp)
    8000477c:	fc26                	sd	s1,56(sp)
    8000477e:	f84a                	sd	s2,48(sp)
    80004780:	f44e                	sd	s3,40(sp)
    80004782:	0880                	addi	s0,sp,80
    80004784:	84aa                	mv	s1,a0
    80004786:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004788:	ffffd097          	auipc	ra,0xffffd
    8000478c:	2ae080e7          	jalr	686(ra) # 80001a36 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004790:	409c                	lw	a5,0(s1)
    80004792:	37f9                	addiw	a5,a5,-2
    80004794:	4705                	li	a4,1
    80004796:	04f76763          	bltu	a4,a5,800047e4 <filestat+0x6e>
    8000479a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000479c:	6c88                	ld	a0,24(s1)
    8000479e:	fffff097          	auipc	ra,0xfffff
    800047a2:	082080e7          	jalr	130(ra) # 80003820 <ilock>
    stati(f->ip, &st);
    800047a6:	fb840593          	addi	a1,s0,-72
    800047aa:	6c88                	ld	a0,24(s1)
    800047ac:	fffff097          	auipc	ra,0xfffff
    800047b0:	2fe080e7          	jalr	766(ra) # 80003aaa <stati>
    iunlock(f->ip);
    800047b4:	6c88                	ld	a0,24(s1)
    800047b6:	fffff097          	auipc	ra,0xfffff
    800047ba:	12c080e7          	jalr	300(ra) # 800038e2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800047be:	46e1                	li	a3,24
    800047c0:	fb840613          	addi	a2,s0,-72
    800047c4:	85ce                	mv	a1,s3
    800047c6:	05093503          	ld	a0,80(s2)
    800047ca:	ffffd097          	auipc	ra,0xffffd
    800047ce:	f5e080e7          	jalr	-162(ra) # 80001728 <copyout>
    800047d2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800047d6:	60a6                	ld	ra,72(sp)
    800047d8:	6406                	ld	s0,64(sp)
    800047da:	74e2                	ld	s1,56(sp)
    800047dc:	7942                	ld	s2,48(sp)
    800047de:	79a2                	ld	s3,40(sp)
    800047e0:	6161                	addi	sp,sp,80
    800047e2:	8082                	ret
  return -1;
    800047e4:	557d                	li	a0,-1
    800047e6:	bfc5                	j	800047d6 <filestat+0x60>

00000000800047e8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800047e8:	7179                	addi	sp,sp,-48
    800047ea:	f406                	sd	ra,40(sp)
    800047ec:	f022                	sd	s0,32(sp)
    800047ee:	ec26                	sd	s1,24(sp)
    800047f0:	e84a                	sd	s2,16(sp)
    800047f2:	e44e                	sd	s3,8(sp)
    800047f4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800047f6:	00854783          	lbu	a5,8(a0)
    800047fa:	c3d5                	beqz	a5,8000489e <fileread+0xb6>
    800047fc:	84aa                	mv	s1,a0
    800047fe:	89ae                	mv	s3,a1
    80004800:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004802:	411c                	lw	a5,0(a0)
    80004804:	4705                	li	a4,1
    80004806:	04e78963          	beq	a5,a4,80004858 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000480a:	470d                	li	a4,3
    8000480c:	04e78d63          	beq	a5,a4,80004866 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004810:	4709                	li	a4,2
    80004812:	06e79e63          	bne	a5,a4,8000488e <fileread+0xa6>
    ilock(f->ip);
    80004816:	6d08                	ld	a0,24(a0)
    80004818:	fffff097          	auipc	ra,0xfffff
    8000481c:	008080e7          	jalr	8(ra) # 80003820 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004820:	874a                	mv	a4,s2
    80004822:	5094                	lw	a3,32(s1)
    80004824:	864e                	mv	a2,s3
    80004826:	4585                	li	a1,1
    80004828:	6c88                	ld	a0,24(s1)
    8000482a:	fffff097          	auipc	ra,0xfffff
    8000482e:	2aa080e7          	jalr	682(ra) # 80003ad4 <readi>
    80004832:	892a                	mv	s2,a0
    80004834:	00a05563          	blez	a0,8000483e <fileread+0x56>
      f->off += r;
    80004838:	509c                	lw	a5,32(s1)
    8000483a:	9fa9                	addw	a5,a5,a0
    8000483c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000483e:	6c88                	ld	a0,24(s1)
    80004840:	fffff097          	auipc	ra,0xfffff
    80004844:	0a2080e7          	jalr	162(ra) # 800038e2 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004848:	854a                	mv	a0,s2
    8000484a:	70a2                	ld	ra,40(sp)
    8000484c:	7402                	ld	s0,32(sp)
    8000484e:	64e2                	ld	s1,24(sp)
    80004850:	6942                	ld	s2,16(sp)
    80004852:	69a2                	ld	s3,8(sp)
    80004854:	6145                	addi	sp,sp,48
    80004856:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004858:	6908                	ld	a0,16(a0)
    8000485a:	00000097          	auipc	ra,0x0
    8000485e:	3f4080e7          	jalr	1012(ra) # 80004c4e <piperead>
    80004862:	892a                	mv	s2,a0
    80004864:	b7d5                	j	80004848 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004866:	02451783          	lh	a5,36(a0)
    8000486a:	03079693          	slli	a3,a5,0x30
    8000486e:	92c1                	srli	a3,a3,0x30
    80004870:	4725                	li	a4,9
    80004872:	02d76863          	bltu	a4,a3,800048a2 <fileread+0xba>
    80004876:	0792                	slli	a5,a5,0x4
    80004878:	0001e717          	auipc	a4,0x1e
    8000487c:	b3870713          	addi	a4,a4,-1224 # 800223b0 <devsw>
    80004880:	97ba                	add	a5,a5,a4
    80004882:	639c                	ld	a5,0(a5)
    80004884:	c38d                	beqz	a5,800048a6 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004886:	4505                	li	a0,1
    80004888:	9782                	jalr	a5
    8000488a:	892a                	mv	s2,a0
    8000488c:	bf75                	j	80004848 <fileread+0x60>
    panic("fileread");
    8000488e:	00004517          	auipc	a0,0x4
    80004892:	e1a50513          	addi	a0,a0,-486 # 800086a8 <syscalls+0x268>
    80004896:	ffffc097          	auipc	ra,0xffffc
    8000489a:	cac080e7          	jalr	-852(ra) # 80000542 <panic>
    return -1;
    8000489e:	597d                	li	s2,-1
    800048a0:	b765                	j	80004848 <fileread+0x60>
      return -1;
    800048a2:	597d                	li	s2,-1
    800048a4:	b755                	j	80004848 <fileread+0x60>
    800048a6:	597d                	li	s2,-1
    800048a8:	b745                	j	80004848 <fileread+0x60>

00000000800048aa <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800048aa:	00954783          	lbu	a5,9(a0)
    800048ae:	14078563          	beqz	a5,800049f8 <filewrite+0x14e>
{
    800048b2:	715d                	addi	sp,sp,-80
    800048b4:	e486                	sd	ra,72(sp)
    800048b6:	e0a2                	sd	s0,64(sp)
    800048b8:	fc26                	sd	s1,56(sp)
    800048ba:	f84a                	sd	s2,48(sp)
    800048bc:	f44e                	sd	s3,40(sp)
    800048be:	f052                	sd	s4,32(sp)
    800048c0:	ec56                	sd	s5,24(sp)
    800048c2:	e85a                	sd	s6,16(sp)
    800048c4:	e45e                	sd	s7,8(sp)
    800048c6:	e062                	sd	s8,0(sp)
    800048c8:	0880                	addi	s0,sp,80
    800048ca:	892a                	mv	s2,a0
    800048cc:	8aae                	mv	s5,a1
    800048ce:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800048d0:	411c                	lw	a5,0(a0)
    800048d2:	4705                	li	a4,1
    800048d4:	02e78263          	beq	a5,a4,800048f8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048d8:	470d                	li	a4,3
    800048da:	02e78563          	beq	a5,a4,80004904 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800048de:	4709                	li	a4,2
    800048e0:	10e79463          	bne	a5,a4,800049e8 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800048e4:	0ec05e63          	blez	a2,800049e0 <filewrite+0x136>
    int i = 0;
    800048e8:	4981                	li	s3,0
    800048ea:	6b05                	lui	s6,0x1
    800048ec:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800048f0:	6b85                	lui	s7,0x1
    800048f2:	c00b8b9b          	addiw	s7,s7,-1024
    800048f6:	a851                	j	8000498a <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800048f8:	6908                	ld	a0,16(a0)
    800048fa:	00000097          	auipc	ra,0x0
    800048fe:	254080e7          	jalr	596(ra) # 80004b4e <pipewrite>
    80004902:	a85d                	j	800049b8 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004904:	02451783          	lh	a5,36(a0)
    80004908:	03079693          	slli	a3,a5,0x30
    8000490c:	92c1                	srli	a3,a3,0x30
    8000490e:	4725                	li	a4,9
    80004910:	0ed76663          	bltu	a4,a3,800049fc <filewrite+0x152>
    80004914:	0792                	slli	a5,a5,0x4
    80004916:	0001e717          	auipc	a4,0x1e
    8000491a:	a9a70713          	addi	a4,a4,-1382 # 800223b0 <devsw>
    8000491e:	97ba                	add	a5,a5,a4
    80004920:	679c                	ld	a5,8(a5)
    80004922:	cff9                	beqz	a5,80004a00 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004924:	4505                	li	a0,1
    80004926:	9782                	jalr	a5
    80004928:	a841                	j	800049b8 <filewrite+0x10e>
    8000492a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000492e:	00000097          	auipc	ra,0x0
    80004932:	8ae080e7          	jalr	-1874(ra) # 800041dc <begin_op>
      ilock(f->ip);
    80004936:	01893503          	ld	a0,24(s2)
    8000493a:	fffff097          	auipc	ra,0xfffff
    8000493e:	ee6080e7          	jalr	-282(ra) # 80003820 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004942:	8762                	mv	a4,s8
    80004944:	02092683          	lw	a3,32(s2)
    80004948:	01598633          	add	a2,s3,s5
    8000494c:	4585                	li	a1,1
    8000494e:	01893503          	ld	a0,24(s2)
    80004952:	fffff097          	auipc	ra,0xfffff
    80004956:	278080e7          	jalr	632(ra) # 80003bca <writei>
    8000495a:	84aa                	mv	s1,a0
    8000495c:	02a05f63          	blez	a0,8000499a <filewrite+0xf0>
        f->off += r;
    80004960:	02092783          	lw	a5,32(s2)
    80004964:	9fa9                	addw	a5,a5,a0
    80004966:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000496a:	01893503          	ld	a0,24(s2)
    8000496e:	fffff097          	auipc	ra,0xfffff
    80004972:	f74080e7          	jalr	-140(ra) # 800038e2 <iunlock>
      end_op();
    80004976:	00000097          	auipc	ra,0x0
    8000497a:	8e6080e7          	jalr	-1818(ra) # 8000425c <end_op>

      if(r < 0)
        break;
      if(r != n1)
    8000497e:	049c1963          	bne	s8,s1,800049d0 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004982:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004986:	0349d663          	bge	s3,s4,800049b2 <filewrite+0x108>
      int n1 = n - i;
    8000498a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000498e:	84be                	mv	s1,a5
    80004990:	2781                	sext.w	a5,a5
    80004992:	f8fb5ce3          	bge	s6,a5,8000492a <filewrite+0x80>
    80004996:	84de                	mv	s1,s7
    80004998:	bf49                	j	8000492a <filewrite+0x80>
      iunlock(f->ip);
    8000499a:	01893503          	ld	a0,24(s2)
    8000499e:	fffff097          	auipc	ra,0xfffff
    800049a2:	f44080e7          	jalr	-188(ra) # 800038e2 <iunlock>
      end_op();
    800049a6:	00000097          	auipc	ra,0x0
    800049aa:	8b6080e7          	jalr	-1866(ra) # 8000425c <end_op>
      if(r < 0)
    800049ae:	fc04d8e3          	bgez	s1,8000497e <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    800049b2:	8552                	mv	a0,s4
    800049b4:	033a1863          	bne	s4,s3,800049e4 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800049b8:	60a6                	ld	ra,72(sp)
    800049ba:	6406                	ld	s0,64(sp)
    800049bc:	74e2                	ld	s1,56(sp)
    800049be:	7942                	ld	s2,48(sp)
    800049c0:	79a2                	ld	s3,40(sp)
    800049c2:	7a02                	ld	s4,32(sp)
    800049c4:	6ae2                	ld	s5,24(sp)
    800049c6:	6b42                	ld	s6,16(sp)
    800049c8:	6ba2                	ld	s7,8(sp)
    800049ca:	6c02                	ld	s8,0(sp)
    800049cc:	6161                	addi	sp,sp,80
    800049ce:	8082                	ret
        panic("short filewrite");
    800049d0:	00004517          	auipc	a0,0x4
    800049d4:	ce850513          	addi	a0,a0,-792 # 800086b8 <syscalls+0x278>
    800049d8:	ffffc097          	auipc	ra,0xffffc
    800049dc:	b6a080e7          	jalr	-1174(ra) # 80000542 <panic>
    int i = 0;
    800049e0:	4981                	li	s3,0
    800049e2:	bfc1                	j	800049b2 <filewrite+0x108>
    ret = (i == n ? n : -1);
    800049e4:	557d                	li	a0,-1
    800049e6:	bfc9                	j	800049b8 <filewrite+0x10e>
    panic("filewrite");
    800049e8:	00004517          	auipc	a0,0x4
    800049ec:	ce050513          	addi	a0,a0,-800 # 800086c8 <syscalls+0x288>
    800049f0:	ffffc097          	auipc	ra,0xffffc
    800049f4:	b52080e7          	jalr	-1198(ra) # 80000542 <panic>
    return -1;
    800049f8:	557d                	li	a0,-1
}
    800049fa:	8082                	ret
      return -1;
    800049fc:	557d                	li	a0,-1
    800049fe:	bf6d                	j	800049b8 <filewrite+0x10e>
    80004a00:	557d                	li	a0,-1
    80004a02:	bf5d                	j	800049b8 <filewrite+0x10e>

0000000080004a04 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a04:	7179                	addi	sp,sp,-48
    80004a06:	f406                	sd	ra,40(sp)
    80004a08:	f022                	sd	s0,32(sp)
    80004a0a:	ec26                	sd	s1,24(sp)
    80004a0c:	e84a                	sd	s2,16(sp)
    80004a0e:	e44e                	sd	s3,8(sp)
    80004a10:	e052                	sd	s4,0(sp)
    80004a12:	1800                	addi	s0,sp,48
    80004a14:	84aa                	mv	s1,a0
    80004a16:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a18:	0005b023          	sd	zero,0(a1)
    80004a1c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a20:	00000097          	auipc	ra,0x0
    80004a24:	bd2080e7          	jalr	-1070(ra) # 800045f2 <filealloc>
    80004a28:	e088                	sd	a0,0(s1)
    80004a2a:	c551                	beqz	a0,80004ab6 <pipealloc+0xb2>
    80004a2c:	00000097          	auipc	ra,0x0
    80004a30:	bc6080e7          	jalr	-1082(ra) # 800045f2 <filealloc>
    80004a34:	00aa3023          	sd	a0,0(s4)
    80004a38:	c92d                	beqz	a0,80004aaa <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a3a:	ffffc097          	auipc	ra,0xffffc
    80004a3e:	140080e7          	jalr	320(ra) # 80000b7a <kalloc>
    80004a42:	892a                	mv	s2,a0
    80004a44:	c125                	beqz	a0,80004aa4 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a46:	4985                	li	s3,1
    80004a48:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004a4c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004a50:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a54:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a58:	00004597          	auipc	a1,0x4
    80004a5c:	c8058593          	addi	a1,a1,-896 # 800086d8 <syscalls+0x298>
    80004a60:	ffffc097          	auipc	ra,0xffffc
    80004a64:	17a080e7          	jalr	378(ra) # 80000bda <initlock>
  (*f0)->type = FD_PIPE;
    80004a68:	609c                	ld	a5,0(s1)
    80004a6a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a6e:	609c                	ld	a5,0(s1)
    80004a70:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a74:	609c                	ld	a5,0(s1)
    80004a76:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a7a:	609c                	ld	a5,0(s1)
    80004a7c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a80:	000a3783          	ld	a5,0(s4)
    80004a84:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a88:	000a3783          	ld	a5,0(s4)
    80004a8c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a90:	000a3783          	ld	a5,0(s4)
    80004a94:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a98:	000a3783          	ld	a5,0(s4)
    80004a9c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004aa0:	4501                	li	a0,0
    80004aa2:	a025                	j	80004aca <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004aa4:	6088                	ld	a0,0(s1)
    80004aa6:	e501                	bnez	a0,80004aae <pipealloc+0xaa>
    80004aa8:	a039                	j	80004ab6 <pipealloc+0xb2>
    80004aaa:	6088                	ld	a0,0(s1)
    80004aac:	c51d                	beqz	a0,80004ada <pipealloc+0xd6>
    fileclose(*f0);
    80004aae:	00000097          	auipc	ra,0x0
    80004ab2:	c00080e7          	jalr	-1024(ra) # 800046ae <fileclose>
  if(*f1)
    80004ab6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004aba:	557d                	li	a0,-1
  if(*f1)
    80004abc:	c799                	beqz	a5,80004aca <pipealloc+0xc6>
    fileclose(*f1);
    80004abe:	853e                	mv	a0,a5
    80004ac0:	00000097          	auipc	ra,0x0
    80004ac4:	bee080e7          	jalr	-1042(ra) # 800046ae <fileclose>
  return -1;
    80004ac8:	557d                	li	a0,-1
}
    80004aca:	70a2                	ld	ra,40(sp)
    80004acc:	7402                	ld	s0,32(sp)
    80004ace:	64e2                	ld	s1,24(sp)
    80004ad0:	6942                	ld	s2,16(sp)
    80004ad2:	69a2                	ld	s3,8(sp)
    80004ad4:	6a02                	ld	s4,0(sp)
    80004ad6:	6145                	addi	sp,sp,48
    80004ad8:	8082                	ret
  return -1;
    80004ada:	557d                	li	a0,-1
    80004adc:	b7fd                	j	80004aca <pipealloc+0xc6>

0000000080004ade <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004ade:	1101                	addi	sp,sp,-32
    80004ae0:	ec06                	sd	ra,24(sp)
    80004ae2:	e822                	sd	s0,16(sp)
    80004ae4:	e426                	sd	s1,8(sp)
    80004ae6:	e04a                	sd	s2,0(sp)
    80004ae8:	1000                	addi	s0,sp,32
    80004aea:	84aa                	mv	s1,a0
    80004aec:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004aee:	ffffc097          	auipc	ra,0xffffc
    80004af2:	17c080e7          	jalr	380(ra) # 80000c6a <acquire>
  if(writable){
    80004af6:	02090d63          	beqz	s2,80004b30 <pipeclose+0x52>
    pi->writeopen = 0;
    80004afa:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004afe:	21848513          	addi	a0,s1,536
    80004b02:	ffffe097          	auipc	ra,0xffffe
    80004b06:	8f4080e7          	jalr	-1804(ra) # 800023f6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b0a:	2204b783          	ld	a5,544(s1)
    80004b0e:	eb95                	bnez	a5,80004b42 <pipeclose+0x64>
    release(&pi->lock);
    80004b10:	8526                	mv	a0,s1
    80004b12:	ffffc097          	auipc	ra,0xffffc
    80004b16:	20c080e7          	jalr	524(ra) # 80000d1e <release>
    kfree((char*)pi);
    80004b1a:	8526                	mv	a0,s1
    80004b1c:	ffffc097          	auipc	ra,0xffffc
    80004b20:	f62080e7          	jalr	-158(ra) # 80000a7e <kfree>
  } else
    release(&pi->lock);
}
    80004b24:	60e2                	ld	ra,24(sp)
    80004b26:	6442                	ld	s0,16(sp)
    80004b28:	64a2                	ld	s1,8(sp)
    80004b2a:	6902                	ld	s2,0(sp)
    80004b2c:	6105                	addi	sp,sp,32
    80004b2e:	8082                	ret
    pi->readopen = 0;
    80004b30:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b34:	21c48513          	addi	a0,s1,540
    80004b38:	ffffe097          	auipc	ra,0xffffe
    80004b3c:	8be080e7          	jalr	-1858(ra) # 800023f6 <wakeup>
    80004b40:	b7e9                	j	80004b0a <pipeclose+0x2c>
    release(&pi->lock);
    80004b42:	8526                	mv	a0,s1
    80004b44:	ffffc097          	auipc	ra,0xffffc
    80004b48:	1da080e7          	jalr	474(ra) # 80000d1e <release>
}
    80004b4c:	bfe1                	j	80004b24 <pipeclose+0x46>

0000000080004b4e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b4e:	711d                	addi	sp,sp,-96
    80004b50:	ec86                	sd	ra,88(sp)
    80004b52:	e8a2                	sd	s0,80(sp)
    80004b54:	e4a6                	sd	s1,72(sp)
    80004b56:	e0ca                	sd	s2,64(sp)
    80004b58:	fc4e                	sd	s3,56(sp)
    80004b5a:	f852                	sd	s4,48(sp)
    80004b5c:	f456                	sd	s5,40(sp)
    80004b5e:	f05a                	sd	s6,32(sp)
    80004b60:	ec5e                	sd	s7,24(sp)
    80004b62:	e862                	sd	s8,16(sp)
    80004b64:	1080                	addi	s0,sp,96
    80004b66:	84aa                	mv	s1,a0
    80004b68:	8b2e                	mv	s6,a1
    80004b6a:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004b6c:	ffffd097          	auipc	ra,0xffffd
    80004b70:	eca080e7          	jalr	-310(ra) # 80001a36 <myproc>
    80004b74:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004b76:	8526                	mv	a0,s1
    80004b78:	ffffc097          	auipc	ra,0xffffc
    80004b7c:	0f2080e7          	jalr	242(ra) # 80000c6a <acquire>
  for(i = 0; i < n; i++){
    80004b80:	09505763          	blez	s5,80004c0e <pipewrite+0xc0>
    80004b84:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004b86:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004b8a:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b8e:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b90:	2184a783          	lw	a5,536(s1)
    80004b94:	21c4a703          	lw	a4,540(s1)
    80004b98:	2007879b          	addiw	a5,a5,512
    80004b9c:	02f71b63          	bne	a4,a5,80004bd2 <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    80004ba0:	2204a783          	lw	a5,544(s1)
    80004ba4:	c3d1                	beqz	a5,80004c28 <pipewrite+0xda>
    80004ba6:	03092783          	lw	a5,48(s2)
    80004baa:	efbd                	bnez	a5,80004c28 <pipewrite+0xda>
      wakeup(&pi->nread);
    80004bac:	8552                	mv	a0,s4
    80004bae:	ffffe097          	auipc	ra,0xffffe
    80004bb2:	848080e7          	jalr	-1976(ra) # 800023f6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004bb6:	85a6                	mv	a1,s1
    80004bb8:	854e                	mv	a0,s3
    80004bba:	ffffd097          	auipc	ra,0xffffd
    80004bbe:	6bc080e7          	jalr	1724(ra) # 80002276 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004bc2:	2184a783          	lw	a5,536(s1)
    80004bc6:	21c4a703          	lw	a4,540(s1)
    80004bca:	2007879b          	addiw	a5,a5,512
    80004bce:	fcf709e3          	beq	a4,a5,80004ba0 <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bd2:	4685                	li	a3,1
    80004bd4:	865a                	mv	a2,s6
    80004bd6:	faf40593          	addi	a1,s0,-81
    80004bda:	05093503          	ld	a0,80(s2)
    80004bde:	ffffd097          	auipc	ra,0xffffd
    80004be2:	bd6080e7          	jalr	-1066(ra) # 800017b4 <copyin>
    80004be6:	03850563          	beq	a0,s8,80004c10 <pipewrite+0xc2>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004bea:	21c4a783          	lw	a5,540(s1)
    80004bee:	0017871b          	addiw	a4,a5,1
    80004bf2:	20e4ae23          	sw	a4,540(s1)
    80004bf6:	1ff7f793          	andi	a5,a5,511
    80004bfa:	97a6                	add	a5,a5,s1
    80004bfc:	faf44703          	lbu	a4,-81(s0)
    80004c00:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004c04:	2b85                	addiw	s7,s7,1
    80004c06:	0b05                	addi	s6,s6,1
    80004c08:	f97a94e3          	bne	s5,s7,80004b90 <pipewrite+0x42>
    80004c0c:	a011                	j	80004c10 <pipewrite+0xc2>
    80004c0e:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    80004c10:	21848513          	addi	a0,s1,536
    80004c14:	ffffd097          	auipc	ra,0xffffd
    80004c18:	7e2080e7          	jalr	2018(ra) # 800023f6 <wakeup>
  release(&pi->lock);
    80004c1c:	8526                	mv	a0,s1
    80004c1e:	ffffc097          	auipc	ra,0xffffc
    80004c22:	100080e7          	jalr	256(ra) # 80000d1e <release>
  return i;
    80004c26:	a039                	j	80004c34 <pipewrite+0xe6>
        release(&pi->lock);
    80004c28:	8526                	mv	a0,s1
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	0f4080e7          	jalr	244(ra) # 80000d1e <release>
        return -1;
    80004c32:	5bfd                	li	s7,-1
}
    80004c34:	855e                	mv	a0,s7
    80004c36:	60e6                	ld	ra,88(sp)
    80004c38:	6446                	ld	s0,80(sp)
    80004c3a:	64a6                	ld	s1,72(sp)
    80004c3c:	6906                	ld	s2,64(sp)
    80004c3e:	79e2                	ld	s3,56(sp)
    80004c40:	7a42                	ld	s4,48(sp)
    80004c42:	7aa2                	ld	s5,40(sp)
    80004c44:	7b02                	ld	s6,32(sp)
    80004c46:	6be2                	ld	s7,24(sp)
    80004c48:	6c42                	ld	s8,16(sp)
    80004c4a:	6125                	addi	sp,sp,96
    80004c4c:	8082                	ret

0000000080004c4e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c4e:	715d                	addi	sp,sp,-80
    80004c50:	e486                	sd	ra,72(sp)
    80004c52:	e0a2                	sd	s0,64(sp)
    80004c54:	fc26                	sd	s1,56(sp)
    80004c56:	f84a                	sd	s2,48(sp)
    80004c58:	f44e                	sd	s3,40(sp)
    80004c5a:	f052                	sd	s4,32(sp)
    80004c5c:	ec56                	sd	s5,24(sp)
    80004c5e:	e85a                	sd	s6,16(sp)
    80004c60:	0880                	addi	s0,sp,80
    80004c62:	84aa                	mv	s1,a0
    80004c64:	892e                	mv	s2,a1
    80004c66:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c68:	ffffd097          	auipc	ra,0xffffd
    80004c6c:	dce080e7          	jalr	-562(ra) # 80001a36 <myproc>
    80004c70:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c72:	8526                	mv	a0,s1
    80004c74:	ffffc097          	auipc	ra,0xffffc
    80004c78:	ff6080e7          	jalr	-10(ra) # 80000c6a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c7c:	2184a703          	lw	a4,536(s1)
    80004c80:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c84:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c88:	02f71463          	bne	a4,a5,80004cb0 <piperead+0x62>
    80004c8c:	2244a783          	lw	a5,548(s1)
    80004c90:	c385                	beqz	a5,80004cb0 <piperead+0x62>
    if(pr->killed){
    80004c92:	030a2783          	lw	a5,48(s4)
    80004c96:	ebc1                	bnez	a5,80004d26 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c98:	85a6                	mv	a1,s1
    80004c9a:	854e                	mv	a0,s3
    80004c9c:	ffffd097          	auipc	ra,0xffffd
    80004ca0:	5da080e7          	jalr	1498(ra) # 80002276 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ca4:	2184a703          	lw	a4,536(s1)
    80004ca8:	21c4a783          	lw	a5,540(s1)
    80004cac:	fef700e3          	beq	a4,a5,80004c8c <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cb0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cb2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cb4:	05505363          	blez	s5,80004cfa <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004cb8:	2184a783          	lw	a5,536(s1)
    80004cbc:	21c4a703          	lw	a4,540(s1)
    80004cc0:	02f70d63          	beq	a4,a5,80004cfa <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004cc4:	0017871b          	addiw	a4,a5,1
    80004cc8:	20e4ac23          	sw	a4,536(s1)
    80004ccc:	1ff7f793          	andi	a5,a5,511
    80004cd0:	97a6                	add	a5,a5,s1
    80004cd2:	0187c783          	lbu	a5,24(a5)
    80004cd6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cda:	4685                	li	a3,1
    80004cdc:	fbf40613          	addi	a2,s0,-65
    80004ce0:	85ca                	mv	a1,s2
    80004ce2:	050a3503          	ld	a0,80(s4)
    80004ce6:	ffffd097          	auipc	ra,0xffffd
    80004cea:	a42080e7          	jalr	-1470(ra) # 80001728 <copyout>
    80004cee:	01650663          	beq	a0,s6,80004cfa <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cf2:	2985                	addiw	s3,s3,1
    80004cf4:	0905                	addi	s2,s2,1
    80004cf6:	fd3a91e3          	bne	s5,s3,80004cb8 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004cfa:	21c48513          	addi	a0,s1,540
    80004cfe:	ffffd097          	auipc	ra,0xffffd
    80004d02:	6f8080e7          	jalr	1784(ra) # 800023f6 <wakeup>
  release(&pi->lock);
    80004d06:	8526                	mv	a0,s1
    80004d08:	ffffc097          	auipc	ra,0xffffc
    80004d0c:	016080e7          	jalr	22(ra) # 80000d1e <release>
  return i;
}
    80004d10:	854e                	mv	a0,s3
    80004d12:	60a6                	ld	ra,72(sp)
    80004d14:	6406                	ld	s0,64(sp)
    80004d16:	74e2                	ld	s1,56(sp)
    80004d18:	7942                	ld	s2,48(sp)
    80004d1a:	79a2                	ld	s3,40(sp)
    80004d1c:	7a02                	ld	s4,32(sp)
    80004d1e:	6ae2                	ld	s5,24(sp)
    80004d20:	6b42                	ld	s6,16(sp)
    80004d22:	6161                	addi	sp,sp,80
    80004d24:	8082                	ret
      release(&pi->lock);
    80004d26:	8526                	mv	a0,s1
    80004d28:	ffffc097          	auipc	ra,0xffffc
    80004d2c:	ff6080e7          	jalr	-10(ra) # 80000d1e <release>
      return -1;
    80004d30:	59fd                	li	s3,-1
    80004d32:	bff9                	j	80004d10 <piperead+0xc2>

0000000080004d34 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004d34:	de010113          	addi	sp,sp,-544
    80004d38:	20113c23          	sd	ra,536(sp)
    80004d3c:	20813823          	sd	s0,528(sp)
    80004d40:	20913423          	sd	s1,520(sp)
    80004d44:	21213023          	sd	s2,512(sp)
    80004d48:	ffce                	sd	s3,504(sp)
    80004d4a:	fbd2                	sd	s4,496(sp)
    80004d4c:	f7d6                	sd	s5,488(sp)
    80004d4e:	f3da                	sd	s6,480(sp)
    80004d50:	efde                	sd	s7,472(sp)
    80004d52:	ebe2                	sd	s8,464(sp)
    80004d54:	e7e6                	sd	s9,456(sp)
    80004d56:	e3ea                	sd	s10,448(sp)
    80004d58:	ff6e                	sd	s11,440(sp)
    80004d5a:	1400                	addi	s0,sp,544
    80004d5c:	892a                	mv	s2,a0
    80004d5e:	dea43423          	sd	a0,-536(s0)
    80004d62:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d66:	ffffd097          	auipc	ra,0xffffd
    80004d6a:	cd0080e7          	jalr	-816(ra) # 80001a36 <myproc>
    80004d6e:	84aa                	mv	s1,a0

  begin_op();
    80004d70:	fffff097          	auipc	ra,0xfffff
    80004d74:	46c080e7          	jalr	1132(ra) # 800041dc <begin_op>

  if((ip = namei(path)) == 0){
    80004d78:	854a                	mv	a0,s2
    80004d7a:	fffff097          	auipc	ra,0xfffff
    80004d7e:	256080e7          	jalr	598(ra) # 80003fd0 <namei>
    80004d82:	c93d                	beqz	a0,80004df8 <exec+0xc4>
    80004d84:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d86:	fffff097          	auipc	ra,0xfffff
    80004d8a:	a9a080e7          	jalr	-1382(ra) # 80003820 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d8e:	04000713          	li	a4,64
    80004d92:	4681                	li	a3,0
    80004d94:	e4840613          	addi	a2,s0,-440
    80004d98:	4581                	li	a1,0
    80004d9a:	8556                	mv	a0,s5
    80004d9c:	fffff097          	auipc	ra,0xfffff
    80004da0:	d38080e7          	jalr	-712(ra) # 80003ad4 <readi>
    80004da4:	04000793          	li	a5,64
    80004da8:	00f51a63          	bne	a0,a5,80004dbc <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004dac:	e4842703          	lw	a4,-440(s0)
    80004db0:	464c47b7          	lui	a5,0x464c4
    80004db4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004db8:	04f70663          	beq	a4,a5,80004e04 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004dbc:	8556                	mv	a0,s5
    80004dbe:	fffff097          	auipc	ra,0xfffff
    80004dc2:	cc4080e7          	jalr	-828(ra) # 80003a82 <iunlockput>
    end_op();
    80004dc6:	fffff097          	auipc	ra,0xfffff
    80004dca:	496080e7          	jalr	1174(ra) # 8000425c <end_op>
  }
  return -1;
    80004dce:	557d                	li	a0,-1
}
    80004dd0:	21813083          	ld	ra,536(sp)
    80004dd4:	21013403          	ld	s0,528(sp)
    80004dd8:	20813483          	ld	s1,520(sp)
    80004ddc:	20013903          	ld	s2,512(sp)
    80004de0:	79fe                	ld	s3,504(sp)
    80004de2:	7a5e                	ld	s4,496(sp)
    80004de4:	7abe                	ld	s5,488(sp)
    80004de6:	7b1e                	ld	s6,480(sp)
    80004de8:	6bfe                	ld	s7,472(sp)
    80004dea:	6c5e                	ld	s8,464(sp)
    80004dec:	6cbe                	ld	s9,456(sp)
    80004dee:	6d1e                	ld	s10,448(sp)
    80004df0:	7dfa                	ld	s11,440(sp)
    80004df2:	22010113          	addi	sp,sp,544
    80004df6:	8082                	ret
    end_op();
    80004df8:	fffff097          	auipc	ra,0xfffff
    80004dfc:	464080e7          	jalr	1124(ra) # 8000425c <end_op>
    return -1;
    80004e00:	557d                	li	a0,-1
    80004e02:	b7f9                	j	80004dd0 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e04:	8526                	mv	a0,s1
    80004e06:	ffffd097          	auipc	ra,0xffffd
    80004e0a:	cf4080e7          	jalr	-780(ra) # 80001afa <proc_pagetable>
    80004e0e:	8b2a                	mv	s6,a0
    80004e10:	d555                	beqz	a0,80004dbc <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e12:	e6842783          	lw	a5,-408(s0)
    80004e16:	e8045703          	lhu	a4,-384(s0)
    80004e1a:	c735                	beqz	a4,80004e86 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004e1c:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e1e:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004e22:	6a05                	lui	s4,0x1
    80004e24:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004e28:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004e2c:	6d85                	lui	s11,0x1
    80004e2e:	7d7d                	lui	s10,0xfffff
    80004e30:	ac1d                	j	80005066 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004e32:	00004517          	auipc	a0,0x4
    80004e36:	8ae50513          	addi	a0,a0,-1874 # 800086e0 <syscalls+0x2a0>
    80004e3a:	ffffb097          	auipc	ra,0xffffb
    80004e3e:	708080e7          	jalr	1800(ra) # 80000542 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e42:	874a                	mv	a4,s2
    80004e44:	009c86bb          	addw	a3,s9,s1
    80004e48:	4581                	li	a1,0
    80004e4a:	8556                	mv	a0,s5
    80004e4c:	fffff097          	auipc	ra,0xfffff
    80004e50:	c88080e7          	jalr	-888(ra) # 80003ad4 <readi>
    80004e54:	2501                	sext.w	a0,a0
    80004e56:	1aa91863          	bne	s2,a0,80005006 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004e5a:	009d84bb          	addw	s1,s11,s1
    80004e5e:	013d09bb          	addw	s3,s10,s3
    80004e62:	1f74f263          	bgeu	s1,s7,80005046 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004e66:	02049593          	slli	a1,s1,0x20
    80004e6a:	9181                	srli	a1,a1,0x20
    80004e6c:	95e2                	add	a1,a1,s8
    80004e6e:	855a                	mv	a0,s6
    80004e70:	ffffc097          	auipc	ra,0xffffc
    80004e74:	284080e7          	jalr	644(ra) # 800010f4 <walkaddr>
    80004e78:	862a                	mv	a2,a0
    if(pa == 0)
    80004e7a:	dd45                	beqz	a0,80004e32 <exec+0xfe>
      n = PGSIZE;
    80004e7c:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004e7e:	fd49f2e3          	bgeu	s3,s4,80004e42 <exec+0x10e>
      n = sz - i;
    80004e82:	894e                	mv	s2,s3
    80004e84:	bf7d                	j	80004e42 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004e86:	4481                	li	s1,0
  iunlockput(ip);
    80004e88:	8556                	mv	a0,s5
    80004e8a:	fffff097          	auipc	ra,0xfffff
    80004e8e:	bf8080e7          	jalr	-1032(ra) # 80003a82 <iunlockput>
  end_op();
    80004e92:	fffff097          	auipc	ra,0xfffff
    80004e96:	3ca080e7          	jalr	970(ra) # 8000425c <end_op>
  p = myproc();
    80004e9a:	ffffd097          	auipc	ra,0xffffd
    80004e9e:	b9c080e7          	jalr	-1124(ra) # 80001a36 <myproc>
    80004ea2:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004ea4:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004ea8:	6785                	lui	a5,0x1
    80004eaa:	17fd                	addi	a5,a5,-1
    80004eac:	94be                	add	s1,s1,a5
    80004eae:	77fd                	lui	a5,0xfffff
    80004eb0:	8fe5                	and	a5,a5,s1
    80004eb2:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004eb6:	6609                	lui	a2,0x2
    80004eb8:	963e                	add	a2,a2,a5
    80004eba:	85be                	mv	a1,a5
    80004ebc:	855a                	mv	a0,s6
    80004ebe:	ffffc097          	auipc	ra,0xffffc
    80004ec2:	61a080e7          	jalr	1562(ra) # 800014d8 <uvmalloc>
    80004ec6:	8c2a                	mv	s8,a0
  ip = 0;
    80004ec8:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004eca:	12050e63          	beqz	a0,80005006 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004ece:	75f9                	lui	a1,0xffffe
    80004ed0:	95aa                	add	a1,a1,a0
    80004ed2:	855a                	mv	a0,s6
    80004ed4:	ffffd097          	auipc	ra,0xffffd
    80004ed8:	822080e7          	jalr	-2014(ra) # 800016f6 <uvmclear>
  stackbase = sp - PGSIZE;
    80004edc:	7afd                	lui	s5,0xfffff
    80004ede:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004ee0:	df043783          	ld	a5,-528(s0)
    80004ee4:	6388                	ld	a0,0(a5)
    80004ee6:	c925                	beqz	a0,80004f56 <exec+0x222>
    80004ee8:	e8840993          	addi	s3,s0,-376
    80004eec:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004ef0:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004ef2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004ef4:	ffffc097          	auipc	ra,0xffffc
    80004ef8:	ff6080e7          	jalr	-10(ra) # 80000eea <strlen>
    80004efc:	0015079b          	addiw	a5,a0,1
    80004f00:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f04:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004f08:	13596363          	bltu	s2,s5,8000502e <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f0c:	df043d83          	ld	s11,-528(s0)
    80004f10:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004f14:	8552                	mv	a0,s4
    80004f16:	ffffc097          	auipc	ra,0xffffc
    80004f1a:	fd4080e7          	jalr	-44(ra) # 80000eea <strlen>
    80004f1e:	0015069b          	addiw	a3,a0,1
    80004f22:	8652                	mv	a2,s4
    80004f24:	85ca                	mv	a1,s2
    80004f26:	855a                	mv	a0,s6
    80004f28:	ffffd097          	auipc	ra,0xffffd
    80004f2c:	800080e7          	jalr	-2048(ra) # 80001728 <copyout>
    80004f30:	10054363          	bltz	a0,80005036 <exec+0x302>
    ustack[argc] = sp;
    80004f34:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004f38:	0485                	addi	s1,s1,1
    80004f3a:	008d8793          	addi	a5,s11,8
    80004f3e:	def43823          	sd	a5,-528(s0)
    80004f42:	008db503          	ld	a0,8(s11)
    80004f46:	c911                	beqz	a0,80004f5a <exec+0x226>
    if(argc >= MAXARG)
    80004f48:	09a1                	addi	s3,s3,8
    80004f4a:	fb3c95e3          	bne	s9,s3,80004ef4 <exec+0x1c0>
  sz = sz1;
    80004f4e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f52:	4a81                	li	s5,0
    80004f54:	a84d                	j	80005006 <exec+0x2d2>
  sp = sz;
    80004f56:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004f58:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f5a:	00349793          	slli	a5,s1,0x3
    80004f5e:	f9040713          	addi	a4,s0,-112
    80004f62:	97ba                	add	a5,a5,a4
    80004f64:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd7ef8>
  sp -= (argc+1) * sizeof(uint64);
    80004f68:	00148693          	addi	a3,s1,1
    80004f6c:	068e                	slli	a3,a3,0x3
    80004f6e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f72:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004f76:	01597663          	bgeu	s2,s5,80004f82 <exec+0x24e>
  sz = sz1;
    80004f7a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f7e:	4a81                	li	s5,0
    80004f80:	a059                	j	80005006 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f82:	e8840613          	addi	a2,s0,-376
    80004f86:	85ca                	mv	a1,s2
    80004f88:	855a                	mv	a0,s6
    80004f8a:	ffffc097          	auipc	ra,0xffffc
    80004f8e:	79e080e7          	jalr	1950(ra) # 80001728 <copyout>
    80004f92:	0a054663          	bltz	a0,8000503e <exec+0x30a>
  p->trapframe->a1 = sp;
    80004f96:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004f9a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f9e:	de843783          	ld	a5,-536(s0)
    80004fa2:	0007c703          	lbu	a4,0(a5)
    80004fa6:	cf11                	beqz	a4,80004fc2 <exec+0x28e>
    80004fa8:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004faa:	02f00693          	li	a3,47
    80004fae:	a039                	j	80004fbc <exec+0x288>
      last = s+1;
    80004fb0:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004fb4:	0785                	addi	a5,a5,1
    80004fb6:	fff7c703          	lbu	a4,-1(a5)
    80004fba:	c701                	beqz	a4,80004fc2 <exec+0x28e>
    if(*s == '/')
    80004fbc:	fed71ce3          	bne	a4,a3,80004fb4 <exec+0x280>
    80004fc0:	bfc5                	j	80004fb0 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004fc2:	4641                	li	a2,16
    80004fc4:	de843583          	ld	a1,-536(s0)
    80004fc8:	158b8513          	addi	a0,s7,344
    80004fcc:	ffffc097          	auipc	ra,0xffffc
    80004fd0:	eec080e7          	jalr	-276(ra) # 80000eb8 <safestrcpy>
  oldpagetable = p->pagetable;
    80004fd4:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004fd8:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004fdc:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004fe0:	058bb783          	ld	a5,88(s7)
    80004fe4:	e6043703          	ld	a4,-416(s0)
    80004fe8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004fea:	058bb783          	ld	a5,88(s7)
    80004fee:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ff2:	85ea                	mv	a1,s10
    80004ff4:	ffffd097          	auipc	ra,0xffffd
    80004ff8:	ba2080e7          	jalr	-1118(ra) # 80001b96 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ffc:	0004851b          	sext.w	a0,s1
    80005000:	bbc1                	j	80004dd0 <exec+0x9c>
    80005002:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005006:	df843583          	ld	a1,-520(s0)
    8000500a:	855a                	mv	a0,s6
    8000500c:	ffffd097          	auipc	ra,0xffffd
    80005010:	b8a080e7          	jalr	-1142(ra) # 80001b96 <proc_freepagetable>
  if(ip){
    80005014:	da0a94e3          	bnez	s5,80004dbc <exec+0x88>
  return -1;
    80005018:	557d                	li	a0,-1
    8000501a:	bb5d                	j	80004dd0 <exec+0x9c>
    8000501c:	de943c23          	sd	s1,-520(s0)
    80005020:	b7dd                	j	80005006 <exec+0x2d2>
    80005022:	de943c23          	sd	s1,-520(s0)
    80005026:	b7c5                	j	80005006 <exec+0x2d2>
    80005028:	de943c23          	sd	s1,-520(s0)
    8000502c:	bfe9                	j	80005006 <exec+0x2d2>
  sz = sz1;
    8000502e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005032:	4a81                	li	s5,0
    80005034:	bfc9                	j	80005006 <exec+0x2d2>
  sz = sz1;
    80005036:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000503a:	4a81                	li	s5,0
    8000503c:	b7e9                	j	80005006 <exec+0x2d2>
  sz = sz1;
    8000503e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005042:	4a81                	li	s5,0
    80005044:	b7c9                	j	80005006 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005046:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000504a:	e0843783          	ld	a5,-504(s0)
    8000504e:	0017869b          	addiw	a3,a5,1
    80005052:	e0d43423          	sd	a3,-504(s0)
    80005056:	e0043783          	ld	a5,-512(s0)
    8000505a:	0387879b          	addiw	a5,a5,56
    8000505e:	e8045703          	lhu	a4,-384(s0)
    80005062:	e2e6d3e3          	bge	a3,a4,80004e88 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005066:	2781                	sext.w	a5,a5
    80005068:	e0f43023          	sd	a5,-512(s0)
    8000506c:	03800713          	li	a4,56
    80005070:	86be                	mv	a3,a5
    80005072:	e1040613          	addi	a2,s0,-496
    80005076:	4581                	li	a1,0
    80005078:	8556                	mv	a0,s5
    8000507a:	fffff097          	auipc	ra,0xfffff
    8000507e:	a5a080e7          	jalr	-1446(ra) # 80003ad4 <readi>
    80005082:	03800793          	li	a5,56
    80005086:	f6f51ee3          	bne	a0,a5,80005002 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    8000508a:	e1042783          	lw	a5,-496(s0)
    8000508e:	4705                	li	a4,1
    80005090:	fae79de3          	bne	a5,a4,8000504a <exec+0x316>
    if(ph.memsz < ph.filesz)
    80005094:	e3843603          	ld	a2,-456(s0)
    80005098:	e3043783          	ld	a5,-464(s0)
    8000509c:	f8f660e3          	bltu	a2,a5,8000501c <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800050a0:	e2043783          	ld	a5,-480(s0)
    800050a4:	963e                	add	a2,a2,a5
    800050a6:	f6f66ee3          	bltu	a2,a5,80005022 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800050aa:	85a6                	mv	a1,s1
    800050ac:	855a                	mv	a0,s6
    800050ae:	ffffc097          	auipc	ra,0xffffc
    800050b2:	42a080e7          	jalr	1066(ra) # 800014d8 <uvmalloc>
    800050b6:	dea43c23          	sd	a0,-520(s0)
    800050ba:	d53d                	beqz	a0,80005028 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    800050bc:	e2043c03          	ld	s8,-480(s0)
    800050c0:	de043783          	ld	a5,-544(s0)
    800050c4:	00fc77b3          	and	a5,s8,a5
    800050c8:	ff9d                	bnez	a5,80005006 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800050ca:	e1842c83          	lw	s9,-488(s0)
    800050ce:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800050d2:	f60b8ae3          	beqz	s7,80005046 <exec+0x312>
    800050d6:	89de                	mv	s3,s7
    800050d8:	4481                	li	s1,0
    800050da:	b371                	j	80004e66 <exec+0x132>

00000000800050dc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800050dc:	7179                	addi	sp,sp,-48
    800050de:	f406                	sd	ra,40(sp)
    800050e0:	f022                	sd	s0,32(sp)
    800050e2:	ec26                	sd	s1,24(sp)
    800050e4:	e84a                	sd	s2,16(sp)
    800050e6:	1800                	addi	s0,sp,48
    800050e8:	892e                	mv	s2,a1
    800050ea:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800050ec:	fdc40593          	addi	a1,s0,-36
    800050f0:	ffffe097          	auipc	ra,0xffffe
    800050f4:	b2a080e7          	jalr	-1238(ra) # 80002c1a <argint>
    800050f8:	04054063          	bltz	a0,80005138 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800050fc:	fdc42703          	lw	a4,-36(s0)
    80005100:	47bd                	li	a5,15
    80005102:	02e7ed63          	bltu	a5,a4,8000513c <argfd+0x60>
    80005106:	ffffd097          	auipc	ra,0xffffd
    8000510a:	930080e7          	jalr	-1744(ra) # 80001a36 <myproc>
    8000510e:	fdc42703          	lw	a4,-36(s0)
    80005112:	01a70793          	addi	a5,a4,26
    80005116:	078e                	slli	a5,a5,0x3
    80005118:	953e                	add	a0,a0,a5
    8000511a:	611c                	ld	a5,0(a0)
    8000511c:	c395                	beqz	a5,80005140 <argfd+0x64>
    return -1;
  if(pfd)
    8000511e:	00090463          	beqz	s2,80005126 <argfd+0x4a>
    *pfd = fd;
    80005122:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005126:	4501                	li	a0,0
  if(pf)
    80005128:	c091                	beqz	s1,8000512c <argfd+0x50>
    *pf = f;
    8000512a:	e09c                	sd	a5,0(s1)
}
    8000512c:	70a2                	ld	ra,40(sp)
    8000512e:	7402                	ld	s0,32(sp)
    80005130:	64e2                	ld	s1,24(sp)
    80005132:	6942                	ld	s2,16(sp)
    80005134:	6145                	addi	sp,sp,48
    80005136:	8082                	ret
    return -1;
    80005138:	557d                	li	a0,-1
    8000513a:	bfcd                	j	8000512c <argfd+0x50>
    return -1;
    8000513c:	557d                	li	a0,-1
    8000513e:	b7fd                	j	8000512c <argfd+0x50>
    80005140:	557d                	li	a0,-1
    80005142:	b7ed                	j	8000512c <argfd+0x50>

0000000080005144 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005144:	1101                	addi	sp,sp,-32
    80005146:	ec06                	sd	ra,24(sp)
    80005148:	e822                	sd	s0,16(sp)
    8000514a:	e426                	sd	s1,8(sp)
    8000514c:	1000                	addi	s0,sp,32
    8000514e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005150:	ffffd097          	auipc	ra,0xffffd
    80005154:	8e6080e7          	jalr	-1818(ra) # 80001a36 <myproc>
    80005158:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000515a:	0d050793          	addi	a5,a0,208
    8000515e:	4501                	li	a0,0
    80005160:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005162:	6398                	ld	a4,0(a5)
    80005164:	cb19                	beqz	a4,8000517a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005166:	2505                	addiw	a0,a0,1
    80005168:	07a1                	addi	a5,a5,8
    8000516a:	fed51ce3          	bne	a0,a3,80005162 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000516e:	557d                	li	a0,-1
}
    80005170:	60e2                	ld	ra,24(sp)
    80005172:	6442                	ld	s0,16(sp)
    80005174:	64a2                	ld	s1,8(sp)
    80005176:	6105                	addi	sp,sp,32
    80005178:	8082                	ret
      p->ofile[fd] = f;
    8000517a:	01a50793          	addi	a5,a0,26
    8000517e:	078e                	slli	a5,a5,0x3
    80005180:	963e                	add	a2,a2,a5
    80005182:	e204                	sd	s1,0(a2)
      return fd;
    80005184:	b7f5                	j	80005170 <fdalloc+0x2c>

0000000080005186 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005186:	715d                	addi	sp,sp,-80
    80005188:	e486                	sd	ra,72(sp)
    8000518a:	e0a2                	sd	s0,64(sp)
    8000518c:	fc26                	sd	s1,56(sp)
    8000518e:	f84a                	sd	s2,48(sp)
    80005190:	f44e                	sd	s3,40(sp)
    80005192:	f052                	sd	s4,32(sp)
    80005194:	ec56                	sd	s5,24(sp)
    80005196:	0880                	addi	s0,sp,80
    80005198:	89ae                	mv	s3,a1
    8000519a:	8ab2                	mv	s5,a2
    8000519c:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000519e:	fb040593          	addi	a1,s0,-80
    800051a2:	fffff097          	auipc	ra,0xfffff
    800051a6:	e4c080e7          	jalr	-436(ra) # 80003fee <nameiparent>
    800051aa:	892a                	mv	s2,a0
    800051ac:	12050e63          	beqz	a0,800052e8 <create+0x162>
    return 0;

  ilock(dp);
    800051b0:	ffffe097          	auipc	ra,0xffffe
    800051b4:	670080e7          	jalr	1648(ra) # 80003820 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051b8:	4601                	li	a2,0
    800051ba:	fb040593          	addi	a1,s0,-80
    800051be:	854a                	mv	a0,s2
    800051c0:	fffff097          	auipc	ra,0xfffff
    800051c4:	b3e080e7          	jalr	-1218(ra) # 80003cfe <dirlookup>
    800051c8:	84aa                	mv	s1,a0
    800051ca:	c921                	beqz	a0,8000521a <create+0x94>
    iunlockput(dp);
    800051cc:	854a                	mv	a0,s2
    800051ce:	fffff097          	auipc	ra,0xfffff
    800051d2:	8b4080e7          	jalr	-1868(ra) # 80003a82 <iunlockput>
    ilock(ip);
    800051d6:	8526                	mv	a0,s1
    800051d8:	ffffe097          	auipc	ra,0xffffe
    800051dc:	648080e7          	jalr	1608(ra) # 80003820 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800051e0:	2981                	sext.w	s3,s3
    800051e2:	4789                	li	a5,2
    800051e4:	02f99463          	bne	s3,a5,8000520c <create+0x86>
    800051e8:	0444d783          	lhu	a5,68(s1)
    800051ec:	37f9                	addiw	a5,a5,-2
    800051ee:	17c2                	slli	a5,a5,0x30
    800051f0:	93c1                	srli	a5,a5,0x30
    800051f2:	4705                	li	a4,1
    800051f4:	00f76c63          	bltu	a4,a5,8000520c <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800051f8:	8526                	mv	a0,s1
    800051fa:	60a6                	ld	ra,72(sp)
    800051fc:	6406                	ld	s0,64(sp)
    800051fe:	74e2                	ld	s1,56(sp)
    80005200:	7942                	ld	s2,48(sp)
    80005202:	79a2                	ld	s3,40(sp)
    80005204:	7a02                	ld	s4,32(sp)
    80005206:	6ae2                	ld	s5,24(sp)
    80005208:	6161                	addi	sp,sp,80
    8000520a:	8082                	ret
    iunlockput(ip);
    8000520c:	8526                	mv	a0,s1
    8000520e:	fffff097          	auipc	ra,0xfffff
    80005212:	874080e7          	jalr	-1932(ra) # 80003a82 <iunlockput>
    return 0;
    80005216:	4481                	li	s1,0
    80005218:	b7c5                	j	800051f8 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000521a:	85ce                	mv	a1,s3
    8000521c:	00092503          	lw	a0,0(s2)
    80005220:	ffffe097          	auipc	ra,0xffffe
    80005224:	468080e7          	jalr	1128(ra) # 80003688 <ialloc>
    80005228:	84aa                	mv	s1,a0
    8000522a:	c521                	beqz	a0,80005272 <create+0xec>
  ilock(ip);
    8000522c:	ffffe097          	auipc	ra,0xffffe
    80005230:	5f4080e7          	jalr	1524(ra) # 80003820 <ilock>
  ip->major = major;
    80005234:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005238:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000523c:	4a05                	li	s4,1
    8000523e:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005242:	8526                	mv	a0,s1
    80005244:	ffffe097          	auipc	ra,0xffffe
    80005248:	512080e7          	jalr	1298(ra) # 80003756 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000524c:	2981                	sext.w	s3,s3
    8000524e:	03498a63          	beq	s3,s4,80005282 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005252:	40d0                	lw	a2,4(s1)
    80005254:	fb040593          	addi	a1,s0,-80
    80005258:	854a                	mv	a0,s2
    8000525a:	fffff097          	auipc	ra,0xfffff
    8000525e:	cb4080e7          	jalr	-844(ra) # 80003f0e <dirlink>
    80005262:	06054b63          	bltz	a0,800052d8 <create+0x152>
  iunlockput(dp);
    80005266:	854a                	mv	a0,s2
    80005268:	fffff097          	auipc	ra,0xfffff
    8000526c:	81a080e7          	jalr	-2022(ra) # 80003a82 <iunlockput>
  return ip;
    80005270:	b761                	j	800051f8 <create+0x72>
    panic("create: ialloc");
    80005272:	00003517          	auipc	a0,0x3
    80005276:	48e50513          	addi	a0,a0,1166 # 80008700 <syscalls+0x2c0>
    8000527a:	ffffb097          	auipc	ra,0xffffb
    8000527e:	2c8080e7          	jalr	712(ra) # 80000542 <panic>
    dp->nlink++;  // for ".."
    80005282:	04a95783          	lhu	a5,74(s2)
    80005286:	2785                	addiw	a5,a5,1
    80005288:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000528c:	854a                	mv	a0,s2
    8000528e:	ffffe097          	auipc	ra,0xffffe
    80005292:	4c8080e7          	jalr	1224(ra) # 80003756 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005296:	40d0                	lw	a2,4(s1)
    80005298:	00003597          	auipc	a1,0x3
    8000529c:	47858593          	addi	a1,a1,1144 # 80008710 <syscalls+0x2d0>
    800052a0:	8526                	mv	a0,s1
    800052a2:	fffff097          	auipc	ra,0xfffff
    800052a6:	c6c080e7          	jalr	-916(ra) # 80003f0e <dirlink>
    800052aa:	00054f63          	bltz	a0,800052c8 <create+0x142>
    800052ae:	00492603          	lw	a2,4(s2)
    800052b2:	00003597          	auipc	a1,0x3
    800052b6:	46658593          	addi	a1,a1,1126 # 80008718 <syscalls+0x2d8>
    800052ba:	8526                	mv	a0,s1
    800052bc:	fffff097          	auipc	ra,0xfffff
    800052c0:	c52080e7          	jalr	-942(ra) # 80003f0e <dirlink>
    800052c4:	f80557e3          	bgez	a0,80005252 <create+0xcc>
      panic("create dots");
    800052c8:	00003517          	auipc	a0,0x3
    800052cc:	45850513          	addi	a0,a0,1112 # 80008720 <syscalls+0x2e0>
    800052d0:	ffffb097          	auipc	ra,0xffffb
    800052d4:	272080e7          	jalr	626(ra) # 80000542 <panic>
    panic("create: dirlink");
    800052d8:	00003517          	auipc	a0,0x3
    800052dc:	45850513          	addi	a0,a0,1112 # 80008730 <syscalls+0x2f0>
    800052e0:	ffffb097          	auipc	ra,0xffffb
    800052e4:	262080e7          	jalr	610(ra) # 80000542 <panic>
    return 0;
    800052e8:	84aa                	mv	s1,a0
    800052ea:	b739                	j	800051f8 <create+0x72>

00000000800052ec <sys_dup>:
{
    800052ec:	7179                	addi	sp,sp,-48
    800052ee:	f406                	sd	ra,40(sp)
    800052f0:	f022                	sd	s0,32(sp)
    800052f2:	ec26                	sd	s1,24(sp)
    800052f4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800052f6:	fd840613          	addi	a2,s0,-40
    800052fa:	4581                	li	a1,0
    800052fc:	4501                	li	a0,0
    800052fe:	00000097          	auipc	ra,0x0
    80005302:	dde080e7          	jalr	-546(ra) # 800050dc <argfd>
    return -1;
    80005306:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005308:	02054363          	bltz	a0,8000532e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000530c:	fd843503          	ld	a0,-40(s0)
    80005310:	00000097          	auipc	ra,0x0
    80005314:	e34080e7          	jalr	-460(ra) # 80005144 <fdalloc>
    80005318:	84aa                	mv	s1,a0
    return -1;
    8000531a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000531c:	00054963          	bltz	a0,8000532e <sys_dup+0x42>
  filedup(f);
    80005320:	fd843503          	ld	a0,-40(s0)
    80005324:	fffff097          	auipc	ra,0xfffff
    80005328:	338080e7          	jalr	824(ra) # 8000465c <filedup>
  return fd;
    8000532c:	87a6                	mv	a5,s1
}
    8000532e:	853e                	mv	a0,a5
    80005330:	70a2                	ld	ra,40(sp)
    80005332:	7402                	ld	s0,32(sp)
    80005334:	64e2                	ld	s1,24(sp)
    80005336:	6145                	addi	sp,sp,48
    80005338:	8082                	ret

000000008000533a <sys_read>:
{
    8000533a:	7179                	addi	sp,sp,-48
    8000533c:	f406                	sd	ra,40(sp)
    8000533e:	f022                	sd	s0,32(sp)
    80005340:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005342:	fe840613          	addi	a2,s0,-24
    80005346:	4581                	li	a1,0
    80005348:	4501                	li	a0,0
    8000534a:	00000097          	auipc	ra,0x0
    8000534e:	d92080e7          	jalr	-622(ra) # 800050dc <argfd>
    return -1;
    80005352:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005354:	04054163          	bltz	a0,80005396 <sys_read+0x5c>
    80005358:	fe440593          	addi	a1,s0,-28
    8000535c:	4509                	li	a0,2
    8000535e:	ffffe097          	auipc	ra,0xffffe
    80005362:	8bc080e7          	jalr	-1860(ra) # 80002c1a <argint>
    return -1;
    80005366:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005368:	02054763          	bltz	a0,80005396 <sys_read+0x5c>
    8000536c:	fd840593          	addi	a1,s0,-40
    80005370:	4505                	li	a0,1
    80005372:	ffffe097          	auipc	ra,0xffffe
    80005376:	8ca080e7          	jalr	-1846(ra) # 80002c3c <argaddr>
    return -1;
    8000537a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000537c:	00054d63          	bltz	a0,80005396 <sys_read+0x5c>
  return fileread(f, p, n);
    80005380:	fe442603          	lw	a2,-28(s0)
    80005384:	fd843583          	ld	a1,-40(s0)
    80005388:	fe843503          	ld	a0,-24(s0)
    8000538c:	fffff097          	auipc	ra,0xfffff
    80005390:	45c080e7          	jalr	1116(ra) # 800047e8 <fileread>
    80005394:	87aa                	mv	a5,a0
}
    80005396:	853e                	mv	a0,a5
    80005398:	70a2                	ld	ra,40(sp)
    8000539a:	7402                	ld	s0,32(sp)
    8000539c:	6145                	addi	sp,sp,48
    8000539e:	8082                	ret

00000000800053a0 <sys_write>:
{
    800053a0:	7179                	addi	sp,sp,-48
    800053a2:	f406                	sd	ra,40(sp)
    800053a4:	f022                	sd	s0,32(sp)
    800053a6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053a8:	fe840613          	addi	a2,s0,-24
    800053ac:	4581                	li	a1,0
    800053ae:	4501                	li	a0,0
    800053b0:	00000097          	auipc	ra,0x0
    800053b4:	d2c080e7          	jalr	-724(ra) # 800050dc <argfd>
    return -1;
    800053b8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053ba:	04054163          	bltz	a0,800053fc <sys_write+0x5c>
    800053be:	fe440593          	addi	a1,s0,-28
    800053c2:	4509                	li	a0,2
    800053c4:	ffffe097          	auipc	ra,0xffffe
    800053c8:	856080e7          	jalr	-1962(ra) # 80002c1a <argint>
    return -1;
    800053cc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053ce:	02054763          	bltz	a0,800053fc <sys_write+0x5c>
    800053d2:	fd840593          	addi	a1,s0,-40
    800053d6:	4505                	li	a0,1
    800053d8:	ffffe097          	auipc	ra,0xffffe
    800053dc:	864080e7          	jalr	-1948(ra) # 80002c3c <argaddr>
    return -1;
    800053e0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053e2:	00054d63          	bltz	a0,800053fc <sys_write+0x5c>
  return filewrite(f, p, n);
    800053e6:	fe442603          	lw	a2,-28(s0)
    800053ea:	fd843583          	ld	a1,-40(s0)
    800053ee:	fe843503          	ld	a0,-24(s0)
    800053f2:	fffff097          	auipc	ra,0xfffff
    800053f6:	4b8080e7          	jalr	1208(ra) # 800048aa <filewrite>
    800053fa:	87aa                	mv	a5,a0
}
    800053fc:	853e                	mv	a0,a5
    800053fe:	70a2                	ld	ra,40(sp)
    80005400:	7402                	ld	s0,32(sp)
    80005402:	6145                	addi	sp,sp,48
    80005404:	8082                	ret

0000000080005406 <sys_close>:
{
    80005406:	1101                	addi	sp,sp,-32
    80005408:	ec06                	sd	ra,24(sp)
    8000540a:	e822                	sd	s0,16(sp)
    8000540c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000540e:	fe040613          	addi	a2,s0,-32
    80005412:	fec40593          	addi	a1,s0,-20
    80005416:	4501                	li	a0,0
    80005418:	00000097          	auipc	ra,0x0
    8000541c:	cc4080e7          	jalr	-828(ra) # 800050dc <argfd>
    return -1;
    80005420:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005422:	02054463          	bltz	a0,8000544a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005426:	ffffc097          	auipc	ra,0xffffc
    8000542a:	610080e7          	jalr	1552(ra) # 80001a36 <myproc>
    8000542e:	fec42783          	lw	a5,-20(s0)
    80005432:	07e9                	addi	a5,a5,26
    80005434:	078e                	slli	a5,a5,0x3
    80005436:	97aa                	add	a5,a5,a0
    80005438:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000543c:	fe043503          	ld	a0,-32(s0)
    80005440:	fffff097          	auipc	ra,0xfffff
    80005444:	26e080e7          	jalr	622(ra) # 800046ae <fileclose>
  return 0;
    80005448:	4781                	li	a5,0
}
    8000544a:	853e                	mv	a0,a5
    8000544c:	60e2                	ld	ra,24(sp)
    8000544e:	6442                	ld	s0,16(sp)
    80005450:	6105                	addi	sp,sp,32
    80005452:	8082                	ret

0000000080005454 <sys_fstat>:
{
    80005454:	1101                	addi	sp,sp,-32
    80005456:	ec06                	sd	ra,24(sp)
    80005458:	e822                	sd	s0,16(sp)
    8000545a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000545c:	fe840613          	addi	a2,s0,-24
    80005460:	4581                	li	a1,0
    80005462:	4501                	li	a0,0
    80005464:	00000097          	auipc	ra,0x0
    80005468:	c78080e7          	jalr	-904(ra) # 800050dc <argfd>
    return -1;
    8000546c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000546e:	02054563          	bltz	a0,80005498 <sys_fstat+0x44>
    80005472:	fe040593          	addi	a1,s0,-32
    80005476:	4505                	li	a0,1
    80005478:	ffffd097          	auipc	ra,0xffffd
    8000547c:	7c4080e7          	jalr	1988(ra) # 80002c3c <argaddr>
    return -1;
    80005480:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005482:	00054b63          	bltz	a0,80005498 <sys_fstat+0x44>
  return filestat(f, st);
    80005486:	fe043583          	ld	a1,-32(s0)
    8000548a:	fe843503          	ld	a0,-24(s0)
    8000548e:	fffff097          	auipc	ra,0xfffff
    80005492:	2e8080e7          	jalr	744(ra) # 80004776 <filestat>
    80005496:	87aa                	mv	a5,a0
}
    80005498:	853e                	mv	a0,a5
    8000549a:	60e2                	ld	ra,24(sp)
    8000549c:	6442                	ld	s0,16(sp)
    8000549e:	6105                	addi	sp,sp,32
    800054a0:	8082                	ret

00000000800054a2 <sys_link>:
{
    800054a2:	7169                	addi	sp,sp,-304
    800054a4:	f606                	sd	ra,296(sp)
    800054a6:	f222                	sd	s0,288(sp)
    800054a8:	ee26                	sd	s1,280(sp)
    800054aa:	ea4a                	sd	s2,272(sp)
    800054ac:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054ae:	08000613          	li	a2,128
    800054b2:	ed040593          	addi	a1,s0,-304
    800054b6:	4501                	li	a0,0
    800054b8:	ffffd097          	auipc	ra,0xffffd
    800054bc:	7a6080e7          	jalr	1958(ra) # 80002c5e <argstr>
    return -1;
    800054c0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054c2:	10054e63          	bltz	a0,800055de <sys_link+0x13c>
    800054c6:	08000613          	li	a2,128
    800054ca:	f5040593          	addi	a1,s0,-176
    800054ce:	4505                	li	a0,1
    800054d0:	ffffd097          	auipc	ra,0xffffd
    800054d4:	78e080e7          	jalr	1934(ra) # 80002c5e <argstr>
    return -1;
    800054d8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054da:	10054263          	bltz	a0,800055de <sys_link+0x13c>
  begin_op();
    800054de:	fffff097          	auipc	ra,0xfffff
    800054e2:	cfe080e7          	jalr	-770(ra) # 800041dc <begin_op>
  if((ip = namei(old)) == 0){
    800054e6:	ed040513          	addi	a0,s0,-304
    800054ea:	fffff097          	auipc	ra,0xfffff
    800054ee:	ae6080e7          	jalr	-1306(ra) # 80003fd0 <namei>
    800054f2:	84aa                	mv	s1,a0
    800054f4:	c551                	beqz	a0,80005580 <sys_link+0xde>
  ilock(ip);
    800054f6:	ffffe097          	auipc	ra,0xffffe
    800054fa:	32a080e7          	jalr	810(ra) # 80003820 <ilock>
  if(ip->type == T_DIR){
    800054fe:	04449703          	lh	a4,68(s1)
    80005502:	4785                	li	a5,1
    80005504:	08f70463          	beq	a4,a5,8000558c <sys_link+0xea>
  ip->nlink++;
    80005508:	04a4d783          	lhu	a5,74(s1)
    8000550c:	2785                	addiw	a5,a5,1
    8000550e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005512:	8526                	mv	a0,s1
    80005514:	ffffe097          	auipc	ra,0xffffe
    80005518:	242080e7          	jalr	578(ra) # 80003756 <iupdate>
  iunlock(ip);
    8000551c:	8526                	mv	a0,s1
    8000551e:	ffffe097          	auipc	ra,0xffffe
    80005522:	3c4080e7          	jalr	964(ra) # 800038e2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005526:	fd040593          	addi	a1,s0,-48
    8000552a:	f5040513          	addi	a0,s0,-176
    8000552e:	fffff097          	auipc	ra,0xfffff
    80005532:	ac0080e7          	jalr	-1344(ra) # 80003fee <nameiparent>
    80005536:	892a                	mv	s2,a0
    80005538:	c935                	beqz	a0,800055ac <sys_link+0x10a>
  ilock(dp);
    8000553a:	ffffe097          	auipc	ra,0xffffe
    8000553e:	2e6080e7          	jalr	742(ra) # 80003820 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005542:	00092703          	lw	a4,0(s2)
    80005546:	409c                	lw	a5,0(s1)
    80005548:	04f71d63          	bne	a4,a5,800055a2 <sys_link+0x100>
    8000554c:	40d0                	lw	a2,4(s1)
    8000554e:	fd040593          	addi	a1,s0,-48
    80005552:	854a                	mv	a0,s2
    80005554:	fffff097          	auipc	ra,0xfffff
    80005558:	9ba080e7          	jalr	-1606(ra) # 80003f0e <dirlink>
    8000555c:	04054363          	bltz	a0,800055a2 <sys_link+0x100>
  iunlockput(dp);
    80005560:	854a                	mv	a0,s2
    80005562:	ffffe097          	auipc	ra,0xffffe
    80005566:	520080e7          	jalr	1312(ra) # 80003a82 <iunlockput>
  iput(ip);
    8000556a:	8526                	mv	a0,s1
    8000556c:	ffffe097          	auipc	ra,0xffffe
    80005570:	46e080e7          	jalr	1134(ra) # 800039da <iput>
  end_op();
    80005574:	fffff097          	auipc	ra,0xfffff
    80005578:	ce8080e7          	jalr	-792(ra) # 8000425c <end_op>
  return 0;
    8000557c:	4781                	li	a5,0
    8000557e:	a085                	j	800055de <sys_link+0x13c>
    end_op();
    80005580:	fffff097          	auipc	ra,0xfffff
    80005584:	cdc080e7          	jalr	-804(ra) # 8000425c <end_op>
    return -1;
    80005588:	57fd                	li	a5,-1
    8000558a:	a891                	j	800055de <sys_link+0x13c>
    iunlockput(ip);
    8000558c:	8526                	mv	a0,s1
    8000558e:	ffffe097          	auipc	ra,0xffffe
    80005592:	4f4080e7          	jalr	1268(ra) # 80003a82 <iunlockput>
    end_op();
    80005596:	fffff097          	auipc	ra,0xfffff
    8000559a:	cc6080e7          	jalr	-826(ra) # 8000425c <end_op>
    return -1;
    8000559e:	57fd                	li	a5,-1
    800055a0:	a83d                	j	800055de <sys_link+0x13c>
    iunlockput(dp);
    800055a2:	854a                	mv	a0,s2
    800055a4:	ffffe097          	auipc	ra,0xffffe
    800055a8:	4de080e7          	jalr	1246(ra) # 80003a82 <iunlockput>
  ilock(ip);
    800055ac:	8526                	mv	a0,s1
    800055ae:	ffffe097          	auipc	ra,0xffffe
    800055b2:	272080e7          	jalr	626(ra) # 80003820 <ilock>
  ip->nlink--;
    800055b6:	04a4d783          	lhu	a5,74(s1)
    800055ba:	37fd                	addiw	a5,a5,-1
    800055bc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055c0:	8526                	mv	a0,s1
    800055c2:	ffffe097          	auipc	ra,0xffffe
    800055c6:	194080e7          	jalr	404(ra) # 80003756 <iupdate>
  iunlockput(ip);
    800055ca:	8526                	mv	a0,s1
    800055cc:	ffffe097          	auipc	ra,0xffffe
    800055d0:	4b6080e7          	jalr	1206(ra) # 80003a82 <iunlockput>
  end_op();
    800055d4:	fffff097          	auipc	ra,0xfffff
    800055d8:	c88080e7          	jalr	-888(ra) # 8000425c <end_op>
  return -1;
    800055dc:	57fd                	li	a5,-1
}
    800055de:	853e                	mv	a0,a5
    800055e0:	70b2                	ld	ra,296(sp)
    800055e2:	7412                	ld	s0,288(sp)
    800055e4:	64f2                	ld	s1,280(sp)
    800055e6:	6952                	ld	s2,272(sp)
    800055e8:	6155                	addi	sp,sp,304
    800055ea:	8082                	ret

00000000800055ec <sys_unlink>:
{
    800055ec:	7151                	addi	sp,sp,-240
    800055ee:	f586                	sd	ra,232(sp)
    800055f0:	f1a2                	sd	s0,224(sp)
    800055f2:	eda6                	sd	s1,216(sp)
    800055f4:	e9ca                	sd	s2,208(sp)
    800055f6:	e5ce                	sd	s3,200(sp)
    800055f8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800055fa:	08000613          	li	a2,128
    800055fe:	f3040593          	addi	a1,s0,-208
    80005602:	4501                	li	a0,0
    80005604:	ffffd097          	auipc	ra,0xffffd
    80005608:	65a080e7          	jalr	1626(ra) # 80002c5e <argstr>
    8000560c:	18054163          	bltz	a0,8000578e <sys_unlink+0x1a2>
  begin_op();
    80005610:	fffff097          	auipc	ra,0xfffff
    80005614:	bcc080e7          	jalr	-1076(ra) # 800041dc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005618:	fb040593          	addi	a1,s0,-80
    8000561c:	f3040513          	addi	a0,s0,-208
    80005620:	fffff097          	auipc	ra,0xfffff
    80005624:	9ce080e7          	jalr	-1586(ra) # 80003fee <nameiparent>
    80005628:	84aa                	mv	s1,a0
    8000562a:	c979                	beqz	a0,80005700 <sys_unlink+0x114>
  ilock(dp);
    8000562c:	ffffe097          	auipc	ra,0xffffe
    80005630:	1f4080e7          	jalr	500(ra) # 80003820 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005634:	00003597          	auipc	a1,0x3
    80005638:	0dc58593          	addi	a1,a1,220 # 80008710 <syscalls+0x2d0>
    8000563c:	fb040513          	addi	a0,s0,-80
    80005640:	ffffe097          	auipc	ra,0xffffe
    80005644:	6a4080e7          	jalr	1700(ra) # 80003ce4 <namecmp>
    80005648:	14050a63          	beqz	a0,8000579c <sys_unlink+0x1b0>
    8000564c:	00003597          	auipc	a1,0x3
    80005650:	0cc58593          	addi	a1,a1,204 # 80008718 <syscalls+0x2d8>
    80005654:	fb040513          	addi	a0,s0,-80
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	68c080e7          	jalr	1676(ra) # 80003ce4 <namecmp>
    80005660:	12050e63          	beqz	a0,8000579c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005664:	f2c40613          	addi	a2,s0,-212
    80005668:	fb040593          	addi	a1,s0,-80
    8000566c:	8526                	mv	a0,s1
    8000566e:	ffffe097          	auipc	ra,0xffffe
    80005672:	690080e7          	jalr	1680(ra) # 80003cfe <dirlookup>
    80005676:	892a                	mv	s2,a0
    80005678:	12050263          	beqz	a0,8000579c <sys_unlink+0x1b0>
  ilock(ip);
    8000567c:	ffffe097          	auipc	ra,0xffffe
    80005680:	1a4080e7          	jalr	420(ra) # 80003820 <ilock>
  if(ip->nlink < 1)
    80005684:	04a91783          	lh	a5,74(s2)
    80005688:	08f05263          	blez	a5,8000570c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000568c:	04491703          	lh	a4,68(s2)
    80005690:	4785                	li	a5,1
    80005692:	08f70563          	beq	a4,a5,8000571c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005696:	4641                	li	a2,16
    80005698:	4581                	li	a1,0
    8000569a:	fc040513          	addi	a0,s0,-64
    8000569e:	ffffb097          	auipc	ra,0xffffb
    800056a2:	6c8080e7          	jalr	1736(ra) # 80000d66 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056a6:	4741                	li	a4,16
    800056a8:	f2c42683          	lw	a3,-212(s0)
    800056ac:	fc040613          	addi	a2,s0,-64
    800056b0:	4581                	li	a1,0
    800056b2:	8526                	mv	a0,s1
    800056b4:	ffffe097          	auipc	ra,0xffffe
    800056b8:	516080e7          	jalr	1302(ra) # 80003bca <writei>
    800056bc:	47c1                	li	a5,16
    800056be:	0af51563          	bne	a0,a5,80005768 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800056c2:	04491703          	lh	a4,68(s2)
    800056c6:	4785                	li	a5,1
    800056c8:	0af70863          	beq	a4,a5,80005778 <sys_unlink+0x18c>
  iunlockput(dp);
    800056cc:	8526                	mv	a0,s1
    800056ce:	ffffe097          	auipc	ra,0xffffe
    800056d2:	3b4080e7          	jalr	948(ra) # 80003a82 <iunlockput>
  ip->nlink--;
    800056d6:	04a95783          	lhu	a5,74(s2)
    800056da:	37fd                	addiw	a5,a5,-1
    800056dc:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800056e0:	854a                	mv	a0,s2
    800056e2:	ffffe097          	auipc	ra,0xffffe
    800056e6:	074080e7          	jalr	116(ra) # 80003756 <iupdate>
  iunlockput(ip);
    800056ea:	854a                	mv	a0,s2
    800056ec:	ffffe097          	auipc	ra,0xffffe
    800056f0:	396080e7          	jalr	918(ra) # 80003a82 <iunlockput>
  end_op();
    800056f4:	fffff097          	auipc	ra,0xfffff
    800056f8:	b68080e7          	jalr	-1176(ra) # 8000425c <end_op>
  return 0;
    800056fc:	4501                	li	a0,0
    800056fe:	a84d                	j	800057b0 <sys_unlink+0x1c4>
    end_op();
    80005700:	fffff097          	auipc	ra,0xfffff
    80005704:	b5c080e7          	jalr	-1188(ra) # 8000425c <end_op>
    return -1;
    80005708:	557d                	li	a0,-1
    8000570a:	a05d                	j	800057b0 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000570c:	00003517          	auipc	a0,0x3
    80005710:	03450513          	addi	a0,a0,52 # 80008740 <syscalls+0x300>
    80005714:	ffffb097          	auipc	ra,0xffffb
    80005718:	e2e080e7          	jalr	-466(ra) # 80000542 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000571c:	04c92703          	lw	a4,76(s2)
    80005720:	02000793          	li	a5,32
    80005724:	f6e7f9e3          	bgeu	a5,a4,80005696 <sys_unlink+0xaa>
    80005728:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000572c:	4741                	li	a4,16
    8000572e:	86ce                	mv	a3,s3
    80005730:	f1840613          	addi	a2,s0,-232
    80005734:	4581                	li	a1,0
    80005736:	854a                	mv	a0,s2
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	39c080e7          	jalr	924(ra) # 80003ad4 <readi>
    80005740:	47c1                	li	a5,16
    80005742:	00f51b63          	bne	a0,a5,80005758 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005746:	f1845783          	lhu	a5,-232(s0)
    8000574a:	e7a1                	bnez	a5,80005792 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000574c:	29c1                	addiw	s3,s3,16
    8000574e:	04c92783          	lw	a5,76(s2)
    80005752:	fcf9ede3          	bltu	s3,a5,8000572c <sys_unlink+0x140>
    80005756:	b781                	j	80005696 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005758:	00003517          	auipc	a0,0x3
    8000575c:	00050513          	mv	a0,a0
    80005760:	ffffb097          	auipc	ra,0xffffb
    80005764:	de2080e7          	jalr	-542(ra) # 80000542 <panic>
    panic("unlink: writei");
    80005768:	00003517          	auipc	a0,0x3
    8000576c:	00850513          	addi	a0,a0,8 # 80008770 <syscalls+0x330>
    80005770:	ffffb097          	auipc	ra,0xffffb
    80005774:	dd2080e7          	jalr	-558(ra) # 80000542 <panic>
    dp->nlink--;
    80005778:	04a4d783          	lhu	a5,74(s1)
    8000577c:	37fd                	addiw	a5,a5,-1
    8000577e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005782:	8526                	mv	a0,s1
    80005784:	ffffe097          	auipc	ra,0xffffe
    80005788:	fd2080e7          	jalr	-46(ra) # 80003756 <iupdate>
    8000578c:	b781                	j	800056cc <sys_unlink+0xe0>
    return -1;
    8000578e:	557d                	li	a0,-1
    80005790:	a005                	j	800057b0 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005792:	854a                	mv	a0,s2
    80005794:	ffffe097          	auipc	ra,0xffffe
    80005798:	2ee080e7          	jalr	750(ra) # 80003a82 <iunlockput>
  iunlockput(dp);
    8000579c:	8526                	mv	a0,s1
    8000579e:	ffffe097          	auipc	ra,0xffffe
    800057a2:	2e4080e7          	jalr	740(ra) # 80003a82 <iunlockput>
  end_op();
    800057a6:	fffff097          	auipc	ra,0xfffff
    800057aa:	ab6080e7          	jalr	-1354(ra) # 8000425c <end_op>
  return -1;
    800057ae:	557d                	li	a0,-1
}
    800057b0:	70ae                	ld	ra,232(sp)
    800057b2:	740e                	ld	s0,224(sp)
    800057b4:	64ee                	ld	s1,216(sp)
    800057b6:	694e                	ld	s2,208(sp)
    800057b8:	69ae                	ld	s3,200(sp)
    800057ba:	616d                	addi	sp,sp,240
    800057bc:	8082                	ret

00000000800057be <sys_open>:

uint64
sys_open(void)
{
    800057be:	7131                	addi	sp,sp,-192
    800057c0:	fd06                	sd	ra,184(sp)
    800057c2:	f922                	sd	s0,176(sp)
    800057c4:	f526                	sd	s1,168(sp)
    800057c6:	f14a                	sd	s2,160(sp)
    800057c8:	ed4e                	sd	s3,152(sp)
    800057ca:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800057cc:	08000613          	li	a2,128
    800057d0:	f5040593          	addi	a1,s0,-176
    800057d4:	4501                	li	a0,0
    800057d6:	ffffd097          	auipc	ra,0xffffd
    800057da:	488080e7          	jalr	1160(ra) # 80002c5e <argstr>
    return -1;
    800057de:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800057e0:	0c054163          	bltz	a0,800058a2 <sys_open+0xe4>
    800057e4:	f4c40593          	addi	a1,s0,-180
    800057e8:	4505                	li	a0,1
    800057ea:	ffffd097          	auipc	ra,0xffffd
    800057ee:	430080e7          	jalr	1072(ra) # 80002c1a <argint>
    800057f2:	0a054863          	bltz	a0,800058a2 <sys_open+0xe4>

  begin_op();
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	9e6080e7          	jalr	-1562(ra) # 800041dc <begin_op>

  if(omode & O_CREATE){
    800057fe:	f4c42783          	lw	a5,-180(s0)
    80005802:	2007f793          	andi	a5,a5,512
    80005806:	cbdd                	beqz	a5,800058bc <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005808:	4681                	li	a3,0
    8000580a:	4601                	li	a2,0
    8000580c:	4589                	li	a1,2
    8000580e:	f5040513          	addi	a0,s0,-176
    80005812:	00000097          	auipc	ra,0x0
    80005816:	974080e7          	jalr	-1676(ra) # 80005186 <create>
    8000581a:	892a                	mv	s2,a0
    if(ip == 0){
    8000581c:	c959                	beqz	a0,800058b2 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000581e:	04491703          	lh	a4,68(s2)
    80005822:	478d                	li	a5,3
    80005824:	00f71763          	bne	a4,a5,80005832 <sys_open+0x74>
    80005828:	04695703          	lhu	a4,70(s2)
    8000582c:	47a5                	li	a5,9
    8000582e:	0ce7ec63          	bltu	a5,a4,80005906 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005832:	fffff097          	auipc	ra,0xfffff
    80005836:	dc0080e7          	jalr	-576(ra) # 800045f2 <filealloc>
    8000583a:	89aa                	mv	s3,a0
    8000583c:	10050263          	beqz	a0,80005940 <sys_open+0x182>
    80005840:	00000097          	auipc	ra,0x0
    80005844:	904080e7          	jalr	-1788(ra) # 80005144 <fdalloc>
    80005848:	84aa                	mv	s1,a0
    8000584a:	0e054663          	bltz	a0,80005936 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000584e:	04491703          	lh	a4,68(s2)
    80005852:	478d                	li	a5,3
    80005854:	0cf70463          	beq	a4,a5,8000591c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005858:	4789                	li	a5,2
    8000585a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000585e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005862:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005866:	f4c42783          	lw	a5,-180(s0)
    8000586a:	0017c713          	xori	a4,a5,1
    8000586e:	8b05                	andi	a4,a4,1
    80005870:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005874:	0037f713          	andi	a4,a5,3
    80005878:	00e03733          	snez	a4,a4
    8000587c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005880:	4007f793          	andi	a5,a5,1024
    80005884:	c791                	beqz	a5,80005890 <sys_open+0xd2>
    80005886:	04491703          	lh	a4,68(s2)
    8000588a:	4789                	li	a5,2
    8000588c:	08f70f63          	beq	a4,a5,8000592a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005890:	854a                	mv	a0,s2
    80005892:	ffffe097          	auipc	ra,0xffffe
    80005896:	050080e7          	jalr	80(ra) # 800038e2 <iunlock>
  end_op();
    8000589a:	fffff097          	auipc	ra,0xfffff
    8000589e:	9c2080e7          	jalr	-1598(ra) # 8000425c <end_op>

  return fd;
}
    800058a2:	8526                	mv	a0,s1
    800058a4:	70ea                	ld	ra,184(sp)
    800058a6:	744a                	ld	s0,176(sp)
    800058a8:	74aa                	ld	s1,168(sp)
    800058aa:	790a                	ld	s2,160(sp)
    800058ac:	69ea                	ld	s3,152(sp)
    800058ae:	6129                	addi	sp,sp,192
    800058b0:	8082                	ret
      end_op();
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	9aa080e7          	jalr	-1622(ra) # 8000425c <end_op>
      return -1;
    800058ba:	b7e5                	j	800058a2 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800058bc:	f5040513          	addi	a0,s0,-176
    800058c0:	ffffe097          	auipc	ra,0xffffe
    800058c4:	710080e7          	jalr	1808(ra) # 80003fd0 <namei>
    800058c8:	892a                	mv	s2,a0
    800058ca:	c905                	beqz	a0,800058fa <sys_open+0x13c>
    ilock(ip);
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	f54080e7          	jalr	-172(ra) # 80003820 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800058d4:	04491703          	lh	a4,68(s2)
    800058d8:	4785                	li	a5,1
    800058da:	f4f712e3          	bne	a4,a5,8000581e <sys_open+0x60>
    800058de:	f4c42783          	lw	a5,-180(s0)
    800058e2:	dba1                	beqz	a5,80005832 <sys_open+0x74>
      iunlockput(ip);
    800058e4:	854a                	mv	a0,s2
    800058e6:	ffffe097          	auipc	ra,0xffffe
    800058ea:	19c080e7          	jalr	412(ra) # 80003a82 <iunlockput>
      end_op();
    800058ee:	fffff097          	auipc	ra,0xfffff
    800058f2:	96e080e7          	jalr	-1682(ra) # 8000425c <end_op>
      return -1;
    800058f6:	54fd                	li	s1,-1
    800058f8:	b76d                	j	800058a2 <sys_open+0xe4>
      end_op();
    800058fa:	fffff097          	auipc	ra,0xfffff
    800058fe:	962080e7          	jalr	-1694(ra) # 8000425c <end_op>
      return -1;
    80005902:	54fd                	li	s1,-1
    80005904:	bf79                	j	800058a2 <sys_open+0xe4>
    iunlockput(ip);
    80005906:	854a                	mv	a0,s2
    80005908:	ffffe097          	auipc	ra,0xffffe
    8000590c:	17a080e7          	jalr	378(ra) # 80003a82 <iunlockput>
    end_op();
    80005910:	fffff097          	auipc	ra,0xfffff
    80005914:	94c080e7          	jalr	-1716(ra) # 8000425c <end_op>
    return -1;
    80005918:	54fd                	li	s1,-1
    8000591a:	b761                	j	800058a2 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000591c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005920:	04691783          	lh	a5,70(s2)
    80005924:	02f99223          	sh	a5,36(s3)
    80005928:	bf2d                	j	80005862 <sys_open+0xa4>
    itrunc(ip);
    8000592a:	854a                	mv	a0,s2
    8000592c:	ffffe097          	auipc	ra,0xffffe
    80005930:	002080e7          	jalr	2(ra) # 8000392e <itrunc>
    80005934:	bfb1                	j	80005890 <sys_open+0xd2>
      fileclose(f);
    80005936:	854e                	mv	a0,s3
    80005938:	fffff097          	auipc	ra,0xfffff
    8000593c:	d76080e7          	jalr	-650(ra) # 800046ae <fileclose>
    iunlockput(ip);
    80005940:	854a                	mv	a0,s2
    80005942:	ffffe097          	auipc	ra,0xffffe
    80005946:	140080e7          	jalr	320(ra) # 80003a82 <iunlockput>
    end_op();
    8000594a:	fffff097          	auipc	ra,0xfffff
    8000594e:	912080e7          	jalr	-1774(ra) # 8000425c <end_op>
    return -1;
    80005952:	54fd                	li	s1,-1
    80005954:	b7b9                	j	800058a2 <sys_open+0xe4>

0000000080005956 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005956:	7175                	addi	sp,sp,-144
    80005958:	e506                	sd	ra,136(sp)
    8000595a:	e122                	sd	s0,128(sp)
    8000595c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000595e:	fffff097          	auipc	ra,0xfffff
    80005962:	87e080e7          	jalr	-1922(ra) # 800041dc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005966:	08000613          	li	a2,128
    8000596a:	f7040593          	addi	a1,s0,-144
    8000596e:	4501                	li	a0,0
    80005970:	ffffd097          	auipc	ra,0xffffd
    80005974:	2ee080e7          	jalr	750(ra) # 80002c5e <argstr>
    80005978:	02054963          	bltz	a0,800059aa <sys_mkdir+0x54>
    8000597c:	4681                	li	a3,0
    8000597e:	4601                	li	a2,0
    80005980:	4585                	li	a1,1
    80005982:	f7040513          	addi	a0,s0,-144
    80005986:	00000097          	auipc	ra,0x0
    8000598a:	800080e7          	jalr	-2048(ra) # 80005186 <create>
    8000598e:	cd11                	beqz	a0,800059aa <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	0f2080e7          	jalr	242(ra) # 80003a82 <iunlockput>
  end_op();
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	8c4080e7          	jalr	-1852(ra) # 8000425c <end_op>
  return 0;
    800059a0:	4501                	li	a0,0
}
    800059a2:	60aa                	ld	ra,136(sp)
    800059a4:	640a                	ld	s0,128(sp)
    800059a6:	6149                	addi	sp,sp,144
    800059a8:	8082                	ret
    end_op();
    800059aa:	fffff097          	auipc	ra,0xfffff
    800059ae:	8b2080e7          	jalr	-1870(ra) # 8000425c <end_op>
    return -1;
    800059b2:	557d                	li	a0,-1
    800059b4:	b7fd                	j	800059a2 <sys_mkdir+0x4c>

00000000800059b6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800059b6:	7135                	addi	sp,sp,-160
    800059b8:	ed06                	sd	ra,152(sp)
    800059ba:	e922                	sd	s0,144(sp)
    800059bc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	81e080e7          	jalr	-2018(ra) # 800041dc <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059c6:	08000613          	li	a2,128
    800059ca:	f7040593          	addi	a1,s0,-144
    800059ce:	4501                	li	a0,0
    800059d0:	ffffd097          	auipc	ra,0xffffd
    800059d4:	28e080e7          	jalr	654(ra) # 80002c5e <argstr>
    800059d8:	04054a63          	bltz	a0,80005a2c <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800059dc:	f6c40593          	addi	a1,s0,-148
    800059e0:	4505                	li	a0,1
    800059e2:	ffffd097          	auipc	ra,0xffffd
    800059e6:	238080e7          	jalr	568(ra) # 80002c1a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059ea:	04054163          	bltz	a0,80005a2c <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800059ee:	f6840593          	addi	a1,s0,-152
    800059f2:	4509                	li	a0,2
    800059f4:	ffffd097          	auipc	ra,0xffffd
    800059f8:	226080e7          	jalr	550(ra) # 80002c1a <argint>
     argint(1, &major) < 0 ||
    800059fc:	02054863          	bltz	a0,80005a2c <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a00:	f6841683          	lh	a3,-152(s0)
    80005a04:	f6c41603          	lh	a2,-148(s0)
    80005a08:	458d                	li	a1,3
    80005a0a:	f7040513          	addi	a0,s0,-144
    80005a0e:	fffff097          	auipc	ra,0xfffff
    80005a12:	778080e7          	jalr	1912(ra) # 80005186 <create>
     argint(2, &minor) < 0 ||
    80005a16:	c919                	beqz	a0,80005a2c <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a18:	ffffe097          	auipc	ra,0xffffe
    80005a1c:	06a080e7          	jalr	106(ra) # 80003a82 <iunlockput>
  end_op();
    80005a20:	fffff097          	auipc	ra,0xfffff
    80005a24:	83c080e7          	jalr	-1988(ra) # 8000425c <end_op>
  return 0;
    80005a28:	4501                	li	a0,0
    80005a2a:	a031                	j	80005a36 <sys_mknod+0x80>
    end_op();
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	830080e7          	jalr	-2000(ra) # 8000425c <end_op>
    return -1;
    80005a34:	557d                	li	a0,-1
}
    80005a36:	60ea                	ld	ra,152(sp)
    80005a38:	644a                	ld	s0,144(sp)
    80005a3a:	610d                	addi	sp,sp,160
    80005a3c:	8082                	ret

0000000080005a3e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a3e:	7135                	addi	sp,sp,-160
    80005a40:	ed06                	sd	ra,152(sp)
    80005a42:	e922                	sd	s0,144(sp)
    80005a44:	e526                	sd	s1,136(sp)
    80005a46:	e14a                	sd	s2,128(sp)
    80005a48:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a4a:	ffffc097          	auipc	ra,0xffffc
    80005a4e:	fec080e7          	jalr	-20(ra) # 80001a36 <myproc>
    80005a52:	892a                	mv	s2,a0
  
  begin_op();
    80005a54:	ffffe097          	auipc	ra,0xffffe
    80005a58:	788080e7          	jalr	1928(ra) # 800041dc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a5c:	08000613          	li	a2,128
    80005a60:	f6040593          	addi	a1,s0,-160
    80005a64:	4501                	li	a0,0
    80005a66:	ffffd097          	auipc	ra,0xffffd
    80005a6a:	1f8080e7          	jalr	504(ra) # 80002c5e <argstr>
    80005a6e:	04054b63          	bltz	a0,80005ac4 <sys_chdir+0x86>
    80005a72:	f6040513          	addi	a0,s0,-160
    80005a76:	ffffe097          	auipc	ra,0xffffe
    80005a7a:	55a080e7          	jalr	1370(ra) # 80003fd0 <namei>
    80005a7e:	84aa                	mv	s1,a0
    80005a80:	c131                	beqz	a0,80005ac4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a82:	ffffe097          	auipc	ra,0xffffe
    80005a86:	d9e080e7          	jalr	-610(ra) # 80003820 <ilock>
  if(ip->type != T_DIR){
    80005a8a:	04449703          	lh	a4,68(s1)
    80005a8e:	4785                	li	a5,1
    80005a90:	04f71063          	bne	a4,a5,80005ad0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a94:	8526                	mv	a0,s1
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	e4c080e7          	jalr	-436(ra) # 800038e2 <iunlock>
  iput(p->cwd);
    80005a9e:	15093503          	ld	a0,336(s2)
    80005aa2:	ffffe097          	auipc	ra,0xffffe
    80005aa6:	f38080e7          	jalr	-200(ra) # 800039da <iput>
  end_op();
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	7b2080e7          	jalr	1970(ra) # 8000425c <end_op>
  p->cwd = ip;
    80005ab2:	14993823          	sd	s1,336(s2)
  return 0;
    80005ab6:	4501                	li	a0,0
}
    80005ab8:	60ea                	ld	ra,152(sp)
    80005aba:	644a                	ld	s0,144(sp)
    80005abc:	64aa                	ld	s1,136(sp)
    80005abe:	690a                	ld	s2,128(sp)
    80005ac0:	610d                	addi	sp,sp,160
    80005ac2:	8082                	ret
    end_op();
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	798080e7          	jalr	1944(ra) # 8000425c <end_op>
    return -1;
    80005acc:	557d                	li	a0,-1
    80005ace:	b7ed                	j	80005ab8 <sys_chdir+0x7a>
    iunlockput(ip);
    80005ad0:	8526                	mv	a0,s1
    80005ad2:	ffffe097          	auipc	ra,0xffffe
    80005ad6:	fb0080e7          	jalr	-80(ra) # 80003a82 <iunlockput>
    end_op();
    80005ada:	ffffe097          	auipc	ra,0xffffe
    80005ade:	782080e7          	jalr	1922(ra) # 8000425c <end_op>
    return -1;
    80005ae2:	557d                	li	a0,-1
    80005ae4:	bfd1                	j	80005ab8 <sys_chdir+0x7a>

0000000080005ae6 <sys_exec>:

uint64
sys_exec(void)
{
    80005ae6:	7145                	addi	sp,sp,-464
    80005ae8:	e786                	sd	ra,456(sp)
    80005aea:	e3a2                	sd	s0,448(sp)
    80005aec:	ff26                	sd	s1,440(sp)
    80005aee:	fb4a                	sd	s2,432(sp)
    80005af0:	f74e                	sd	s3,424(sp)
    80005af2:	f352                	sd	s4,416(sp)
    80005af4:	ef56                	sd	s5,408(sp)
    80005af6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005af8:	08000613          	li	a2,128
    80005afc:	f4040593          	addi	a1,s0,-192
    80005b00:	4501                	li	a0,0
    80005b02:	ffffd097          	auipc	ra,0xffffd
    80005b06:	15c080e7          	jalr	348(ra) # 80002c5e <argstr>
    return -1;
    80005b0a:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005b0c:	0c054a63          	bltz	a0,80005be0 <sys_exec+0xfa>
    80005b10:	e3840593          	addi	a1,s0,-456
    80005b14:	4505                	li	a0,1
    80005b16:	ffffd097          	auipc	ra,0xffffd
    80005b1a:	126080e7          	jalr	294(ra) # 80002c3c <argaddr>
    80005b1e:	0c054163          	bltz	a0,80005be0 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005b22:	10000613          	li	a2,256
    80005b26:	4581                	li	a1,0
    80005b28:	e4040513          	addi	a0,s0,-448
    80005b2c:	ffffb097          	auipc	ra,0xffffb
    80005b30:	23a080e7          	jalr	570(ra) # 80000d66 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b34:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005b38:	89a6                	mv	s3,s1
    80005b3a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b3c:	02000a13          	li	s4,32
    80005b40:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b44:	00391793          	slli	a5,s2,0x3
    80005b48:	e3040593          	addi	a1,s0,-464
    80005b4c:	e3843503          	ld	a0,-456(s0)
    80005b50:	953e                	add	a0,a0,a5
    80005b52:	ffffd097          	auipc	ra,0xffffd
    80005b56:	02e080e7          	jalr	46(ra) # 80002b80 <fetchaddr>
    80005b5a:	02054a63          	bltz	a0,80005b8e <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005b5e:	e3043783          	ld	a5,-464(s0)
    80005b62:	c3b9                	beqz	a5,80005ba8 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b64:	ffffb097          	auipc	ra,0xffffb
    80005b68:	016080e7          	jalr	22(ra) # 80000b7a <kalloc>
    80005b6c:	85aa                	mv	a1,a0
    80005b6e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b72:	cd11                	beqz	a0,80005b8e <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b74:	6605                	lui	a2,0x1
    80005b76:	e3043503          	ld	a0,-464(s0)
    80005b7a:	ffffd097          	auipc	ra,0xffffd
    80005b7e:	058080e7          	jalr	88(ra) # 80002bd2 <fetchstr>
    80005b82:	00054663          	bltz	a0,80005b8e <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005b86:	0905                	addi	s2,s2,1
    80005b88:	09a1                	addi	s3,s3,8
    80005b8a:	fb491be3          	bne	s2,s4,80005b40 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b8e:	10048913          	addi	s2,s1,256
    80005b92:	6088                	ld	a0,0(s1)
    80005b94:	c529                	beqz	a0,80005bde <sys_exec+0xf8>
    kfree(argv[i]);
    80005b96:	ffffb097          	auipc	ra,0xffffb
    80005b9a:	ee8080e7          	jalr	-280(ra) # 80000a7e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b9e:	04a1                	addi	s1,s1,8
    80005ba0:	ff2499e3          	bne	s1,s2,80005b92 <sys_exec+0xac>
  return -1;
    80005ba4:	597d                	li	s2,-1
    80005ba6:	a82d                	j	80005be0 <sys_exec+0xfa>
      argv[i] = 0;
    80005ba8:	0a8e                	slli	s5,s5,0x3
    80005baa:	fc040793          	addi	a5,s0,-64
    80005bae:	9abe                	add	s5,s5,a5
    80005bb0:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd7e80>
  int ret = exec(path, argv);
    80005bb4:	e4040593          	addi	a1,s0,-448
    80005bb8:	f4040513          	addi	a0,s0,-192
    80005bbc:	fffff097          	auipc	ra,0xfffff
    80005bc0:	178080e7          	jalr	376(ra) # 80004d34 <exec>
    80005bc4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bc6:	10048993          	addi	s3,s1,256
    80005bca:	6088                	ld	a0,0(s1)
    80005bcc:	c911                	beqz	a0,80005be0 <sys_exec+0xfa>
    kfree(argv[i]);
    80005bce:	ffffb097          	auipc	ra,0xffffb
    80005bd2:	eb0080e7          	jalr	-336(ra) # 80000a7e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bd6:	04a1                	addi	s1,s1,8
    80005bd8:	ff3499e3          	bne	s1,s3,80005bca <sys_exec+0xe4>
    80005bdc:	a011                	j	80005be0 <sys_exec+0xfa>
  return -1;
    80005bde:	597d                	li	s2,-1
}
    80005be0:	854a                	mv	a0,s2
    80005be2:	60be                	ld	ra,456(sp)
    80005be4:	641e                	ld	s0,448(sp)
    80005be6:	74fa                	ld	s1,440(sp)
    80005be8:	795a                	ld	s2,432(sp)
    80005bea:	79ba                	ld	s3,424(sp)
    80005bec:	7a1a                	ld	s4,416(sp)
    80005bee:	6afa                	ld	s5,408(sp)
    80005bf0:	6179                	addi	sp,sp,464
    80005bf2:	8082                	ret

0000000080005bf4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005bf4:	7139                	addi	sp,sp,-64
    80005bf6:	fc06                	sd	ra,56(sp)
    80005bf8:	f822                	sd	s0,48(sp)
    80005bfa:	f426                	sd	s1,40(sp)
    80005bfc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005bfe:	ffffc097          	auipc	ra,0xffffc
    80005c02:	e38080e7          	jalr	-456(ra) # 80001a36 <myproc>
    80005c06:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005c08:	fd840593          	addi	a1,s0,-40
    80005c0c:	4501                	li	a0,0
    80005c0e:	ffffd097          	auipc	ra,0xffffd
    80005c12:	02e080e7          	jalr	46(ra) # 80002c3c <argaddr>
    return -1;
    80005c16:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005c18:	0e054063          	bltz	a0,80005cf8 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005c1c:	fc840593          	addi	a1,s0,-56
    80005c20:	fd040513          	addi	a0,s0,-48
    80005c24:	fffff097          	auipc	ra,0xfffff
    80005c28:	de0080e7          	jalr	-544(ra) # 80004a04 <pipealloc>
    return -1;
    80005c2c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c2e:	0c054563          	bltz	a0,80005cf8 <sys_pipe+0x104>
  fd0 = -1;
    80005c32:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c36:	fd043503          	ld	a0,-48(s0)
    80005c3a:	fffff097          	auipc	ra,0xfffff
    80005c3e:	50a080e7          	jalr	1290(ra) # 80005144 <fdalloc>
    80005c42:	fca42223          	sw	a0,-60(s0)
    80005c46:	08054c63          	bltz	a0,80005cde <sys_pipe+0xea>
    80005c4a:	fc843503          	ld	a0,-56(s0)
    80005c4e:	fffff097          	auipc	ra,0xfffff
    80005c52:	4f6080e7          	jalr	1270(ra) # 80005144 <fdalloc>
    80005c56:	fca42023          	sw	a0,-64(s0)
    80005c5a:	06054863          	bltz	a0,80005cca <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c5e:	4691                	li	a3,4
    80005c60:	fc440613          	addi	a2,s0,-60
    80005c64:	fd843583          	ld	a1,-40(s0)
    80005c68:	68a8                	ld	a0,80(s1)
    80005c6a:	ffffc097          	auipc	ra,0xffffc
    80005c6e:	abe080e7          	jalr	-1346(ra) # 80001728 <copyout>
    80005c72:	02054063          	bltz	a0,80005c92 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c76:	4691                	li	a3,4
    80005c78:	fc040613          	addi	a2,s0,-64
    80005c7c:	fd843583          	ld	a1,-40(s0)
    80005c80:	0591                	addi	a1,a1,4
    80005c82:	68a8                	ld	a0,80(s1)
    80005c84:	ffffc097          	auipc	ra,0xffffc
    80005c88:	aa4080e7          	jalr	-1372(ra) # 80001728 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c8c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c8e:	06055563          	bgez	a0,80005cf8 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005c92:	fc442783          	lw	a5,-60(s0)
    80005c96:	07e9                	addi	a5,a5,26
    80005c98:	078e                	slli	a5,a5,0x3
    80005c9a:	97a6                	add	a5,a5,s1
    80005c9c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005ca0:	fc042503          	lw	a0,-64(s0)
    80005ca4:	0569                	addi	a0,a0,26
    80005ca6:	050e                	slli	a0,a0,0x3
    80005ca8:	9526                	add	a0,a0,s1
    80005caa:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005cae:	fd043503          	ld	a0,-48(s0)
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	9fc080e7          	jalr	-1540(ra) # 800046ae <fileclose>
    fileclose(wf);
    80005cba:	fc843503          	ld	a0,-56(s0)
    80005cbe:	fffff097          	auipc	ra,0xfffff
    80005cc2:	9f0080e7          	jalr	-1552(ra) # 800046ae <fileclose>
    return -1;
    80005cc6:	57fd                	li	a5,-1
    80005cc8:	a805                	j	80005cf8 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005cca:	fc442783          	lw	a5,-60(s0)
    80005cce:	0007c863          	bltz	a5,80005cde <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005cd2:	01a78513          	addi	a0,a5,26
    80005cd6:	050e                	slli	a0,a0,0x3
    80005cd8:	9526                	add	a0,a0,s1
    80005cda:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005cde:	fd043503          	ld	a0,-48(s0)
    80005ce2:	fffff097          	auipc	ra,0xfffff
    80005ce6:	9cc080e7          	jalr	-1588(ra) # 800046ae <fileclose>
    fileclose(wf);
    80005cea:	fc843503          	ld	a0,-56(s0)
    80005cee:	fffff097          	auipc	ra,0xfffff
    80005cf2:	9c0080e7          	jalr	-1600(ra) # 800046ae <fileclose>
    return -1;
    80005cf6:	57fd                	li	a5,-1
}
    80005cf8:	853e                	mv	a0,a5
    80005cfa:	70e2                	ld	ra,56(sp)
    80005cfc:	7442                	ld	s0,48(sp)
    80005cfe:	74a2                	ld	s1,40(sp)
    80005d00:	6121                	addi	sp,sp,64
    80005d02:	8082                	ret
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
    80005d50:	b0bfc0ef          	jal	ra,8000285a <kerneltrap>
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
    80005dec:	c22080e7          	jalr	-990(ra) # 80001a0a <cpuid>
  
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
    80005e24:	bea080e7          	jalr	-1046(ra) # 80001a0a <cpuid>
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
    80005e4c:	bc2080e7          	jalr	-1086(ra) # 80001a0a <cpuid>
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
    80005e74:	0001e797          	auipc	a5,0x1e
    80005e78:	18c78793          	addi	a5,a5,396 # 80024000 <disk>
    80005e7c:	00a78733          	add	a4,a5,a0
    80005e80:	6789                	lui	a5,0x2
    80005e82:	97ba                	add	a5,a5,a4
    80005e84:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005e88:	eba1                	bnez	a5,80005ed8 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005e8a:	00451713          	slli	a4,a0,0x4
    80005e8e:	00020797          	auipc	a5,0x20
    80005e92:	1727b783          	ld	a5,370(a5) # 80026000 <disk+0x2000>
    80005e96:	97ba                	add	a5,a5,a4
    80005e98:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005e9c:	0001e797          	auipc	a5,0x1e
    80005ea0:	16478793          	addi	a5,a5,356 # 80024000 <disk>
    80005ea4:	97aa                	add	a5,a5,a0
    80005ea6:	6509                	lui	a0,0x2
    80005ea8:	953e                	add	a0,a0,a5
    80005eaa:	4785                	li	a5,1
    80005eac:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005eb0:	00020517          	auipc	a0,0x20
    80005eb4:	16850513          	addi	a0,a0,360 # 80026018 <disk+0x2018>
    80005eb8:	ffffc097          	auipc	ra,0xffffc
    80005ebc:	53e080e7          	jalr	1342(ra) # 800023f6 <wakeup>
}
    80005ec0:	60a2                	ld	ra,8(sp)
    80005ec2:	6402                	ld	s0,0(sp)
    80005ec4:	0141                	addi	sp,sp,16
    80005ec6:	8082                	ret
    panic("virtio_disk_intr 1");
    80005ec8:	00003517          	auipc	a0,0x3
    80005ecc:	8b850513          	addi	a0,a0,-1864 # 80008780 <syscalls+0x340>
    80005ed0:	ffffa097          	auipc	ra,0xffffa
    80005ed4:	672080e7          	jalr	1650(ra) # 80000542 <panic>
    panic("virtio_disk_intr 2");
    80005ed8:	00003517          	auipc	a0,0x3
    80005edc:	8c050513          	addi	a0,a0,-1856 # 80008798 <syscalls+0x358>
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
    80005ef6:	8be58593          	addi	a1,a1,-1858 # 800087b0 <syscalls+0x370>
    80005efa:	00020517          	auipc	a0,0x20
    80005efe:	1ae50513          	addi	a0,a0,430 # 800260a8 <disk+0x20a8>
    80005f02:	ffffb097          	auipc	ra,0xffffb
    80005f06:	cd8080e7          	jalr	-808(ra) # 80000bda <initlock>
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
    80005f60:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd775f>
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
    80005f92:	0001e517          	auipc	a0,0x1e
    80005f96:	06e50513          	addi	a0,a0,110 # 80024000 <disk>
    80005f9a:	ffffb097          	auipc	ra,0xffffb
    80005f9e:	dcc080e7          	jalr	-564(ra) # 80000d66 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005fa2:	0001e717          	auipc	a4,0x1e
    80005fa6:	05e70713          	addi	a4,a4,94 # 80024000 <disk>
    80005faa:	00c75793          	srli	a5,a4,0xc
    80005fae:	2781                	sext.w	a5,a5
    80005fb0:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005fb2:	00020797          	auipc	a5,0x20
    80005fb6:	04e78793          	addi	a5,a5,78 # 80026000 <disk+0x2000>
    80005fba:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005fbc:	0001e717          	auipc	a4,0x1e
    80005fc0:	0c470713          	addi	a4,a4,196 # 80024080 <disk+0x80>
    80005fc4:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005fc6:	0001f717          	auipc	a4,0x1f
    80005fca:	03a70713          	addi	a4,a4,58 # 80025000 <disk+0x1000>
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
    80006000:	7c450513          	addi	a0,a0,1988 # 800087c0 <syscalls+0x380>
    80006004:	ffffa097          	auipc	ra,0xffffa
    80006008:	53e080e7          	jalr	1342(ra) # 80000542 <panic>
    panic("virtio disk has no queue 0");
    8000600c:	00002517          	auipc	a0,0x2
    80006010:	7d450513          	addi	a0,a0,2004 # 800087e0 <syscalls+0x3a0>
    80006014:	ffffa097          	auipc	ra,0xffffa
    80006018:	52e080e7          	jalr	1326(ra) # 80000542 <panic>
    panic("virtio disk max queue too short");
    8000601c:	00002517          	auipc	a0,0x2
    80006020:	7e450513          	addi	a0,a0,2020 # 80008800 <syscalls+0x3c0>
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
    8000605c:	00020517          	auipc	a0,0x20
    80006060:	04c50513          	addi	a0,a0,76 # 800260a8 <disk+0x20a8>
    80006064:	ffffb097          	auipc	ra,0xffffb
    80006068:	c06080e7          	jalr	-1018(ra) # 80000c6a <acquire>
  for(int i = 0; i < 3; i++){
    8000606c:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000606e:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006070:	0001ec17          	auipc	s8,0x1e
    80006074:	f90c0c13          	addi	s8,s8,-112 # 80024000 <disk>
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
    80006098:	00020717          	auipc	a4,0x20
    8000609c:	f8070713          	addi	a4,a4,-128 # 80026018 <disk+0x2018>
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
    800060ba:	000a2503          	lw	a0,0(s4)
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
    800060ce:	00020597          	auipc	a1,0x20
    800060d2:	fda58593          	addi	a1,a1,-38 # 800260a8 <disk+0x20a8>
    800060d6:	00020517          	auipc	a0,0x20
    800060da:	f4250513          	addi	a0,a0,-190 # 80026018 <disk+0x2018>
    800060de:	ffffc097          	auipc	ra,0xffffc
    800060e2:	198080e7          	jalr	408(ra) # 80002276 <sleep>
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
    800060f0:	00020717          	auipc	a4,0x20
    800060f4:	f1073703          	ld	a4,-240(a4) # 80026000 <disk+0x2000>
    800060f8:	973e                	add	a4,a4,a5
    800060fa:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060fe:	0001e517          	auipc	a0,0x1e
    80006102:	f0250513          	addi	a0,a0,-254 # 80024000 <disk>
    80006106:	00020717          	auipc	a4,0x20
    8000610a:	efa70713          	addi	a4,a4,-262 # 80026000 <disk+0x2000>
    8000610e:	6314                	ld	a3,0(a4)
    80006110:	96be                	add	a3,a3,a5
    80006112:	00c6d603          	lhu	a2,12(a3)
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
    8000619e:	00020917          	auipc	s2,0x20
    800061a2:	f0a90913          	addi	s2,s2,-246 # 800260a8 <disk+0x20a8>
  while(b->disk == 1) {
    800061a6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800061a8:	85ca                	mv	a1,s2
    800061aa:	8556                	mv	a0,s5
    800061ac:	ffffc097          	auipc	ra,0xffffc
    800061b0:	0ca080e7          	jalr	202(ra) # 80002276 <sleep>
  while(b->disk == 1) {
    800061b4:	004aa783          	lw	a5,4(s5)
    800061b8:	fe9788e3          	beq	a5,s1,800061a8 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800061bc:	f8042483          	lw	s1,-128(s0)
    800061c0:	20048793          	addi	a5,s1,512
    800061c4:	00479713          	slli	a4,a5,0x4
    800061c8:	0001e797          	auipc	a5,0x1e
    800061cc:	e3878793          	addi	a5,a5,-456 # 80024000 <disk>
    800061d0:	97ba                	add	a5,a5,a4
    800061d2:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800061d6:	00020917          	auipc	s2,0x20
    800061da:	e2a90913          	addi	s2,s2,-470 # 80026000 <disk+0x2000>
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
    800061fe:	00020517          	auipc	a0,0x20
    80006202:	eaa50513          	addi	a0,a0,-342 # 800260a8 <disk+0x20a8>
    80006206:	ffffb097          	auipc	ra,0xffffb
    8000620a:	b18080e7          	jalr	-1256(ra) # 80000d1e <release>
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
    80006244:	00020997          	auipc	s3,0x20
    80006248:	dbc98993          	addi	s3,s3,-580 # 80026000 <disk+0x2000>
    8000624c:	0009ba03          	ld	s4,0(s3)
    80006250:	9a4a                	add	s4,s4,s2
    80006252:	f7040513          	addi	a0,s0,-144
    80006256:	ffffb097          	auipc	ra,0xffffb
    8000625a:	ee0080e7          	jalr	-288(ra) # 80001136 <kvmpa>
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
    800062a4:	00020717          	auipc	a4,0x20
    800062a8:	d5c73703          	ld	a4,-676(a4) # 80026000 <disk+0x2000>
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
    800062c2:	00020517          	auipc	a0,0x20
    800062c6:	de650513          	addi	a0,a0,-538 # 800260a8 <disk+0x20a8>
    800062ca:	ffffb097          	auipc	ra,0xffffb
    800062ce:	9a0080e7          	jalr	-1632(ra) # 80000c6a <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800062d2:	00020717          	auipc	a4,0x20
    800062d6:	d2e70713          	addi	a4,a4,-722 # 80026000 <disk+0x2000>
    800062da:	02075783          	lhu	a5,32(a4)
    800062de:	6b18                	ld	a4,16(a4)
    800062e0:	00275683          	lhu	a3,2(a4)
    800062e4:	8ebd                	xor	a3,a3,a5
    800062e6:	8a9d                	andi	a3,a3,7
    800062e8:	cab9                	beqz	a3,8000633e <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    800062ea:	0001e917          	auipc	s2,0x1e
    800062ee:	d1690913          	addi	s2,s2,-746 # 80024000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800062f2:	00020497          	auipc	s1,0x20
    800062f6:	d0e48493          	addi	s1,s1,-754 # 80026000 <disk+0x2000>
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
    80006322:	0d8080e7          	jalr	216(ra) # 800023f6 <wakeup>
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
    80006348:	00020517          	auipc	a0,0x20
    8000634c:	d6050513          	addi	a0,a0,-672 # 800260a8 <disk+0x20a8>
    80006350:	ffffb097          	auipc	ra,0xffffb
    80006354:	9ce080e7          	jalr	-1586(ra) # 80000d1e <release>
}
    80006358:	60e2                	ld	ra,24(sp)
    8000635a:	6442                	ld	s0,16(sp)
    8000635c:	64a2                	ld	s1,8(sp)
    8000635e:	6902                	ld	s2,0(sp)
    80006360:	6105                	addi	sp,sp,32
    80006362:	8082                	ret
      panic("virtio_disk_intr status");
    80006364:	00002517          	auipc	a0,0x2
    80006368:	4bc50513          	addi	a0,a0,1212 # 80008820 <syscalls+0x3e0>
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
