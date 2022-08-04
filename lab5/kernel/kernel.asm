
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
    80000060:	e0478793          	addi	a5,a5,-508 # 80005e60 <timervec>
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
    8000012a:	42c080e7          	jalr	1068(ra) # 80002552 <either_copyin>
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
    800001ce:	898080e7          	jalr	-1896(ra) # 80001a62 <myproc>
    800001d2:	591c                	lw	a5,48(a0)
    800001d4:	e7b5                	bnez	a5,80000240 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001d6:	85a6                	mv	a1,s1
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	0c8080e7          	jalr	200(ra) # 800022a2 <sleep>
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
    8000021a:	2e6080e7          	jalr	742(ra) # 800024fc <either_copyout>
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
    800002fa:	2b2080e7          	jalr	690(ra) # 800025a8 <procdump>
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
    8000044e:	fd8080e7          	jalr	-40(ra) # 80002422 <wakeup>
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
    80000912:	b14080e7          	jalr	-1260(ra) # 80002422 <wakeup>
    
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
    800009ac:	8fa080e7          	jalr	-1798(ra) # 800022a2 <sleep>
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
    80000c08:	e42080e7          	jalr	-446(ra) # 80001a46 <mycpu>
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
    80000c3a:	e10080e7          	jalr	-496(ra) # 80001a46 <mycpu>
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	cf89                	beqz	a5,80000c5a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c42:	00001097          	auipc	ra,0x1
    80000c46:	e04080e7          	jalr	-508(ra) # 80001a46 <mycpu>
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
    80000c5e:	dec080e7          	jalr	-532(ra) # 80001a46 <mycpu>
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
    80000c9e:	dac080e7          	jalr	-596(ra) # 80001a46 <mycpu>
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
    80000cca:	d80080e7          	jalr	-640(ra) # 80001a46 <mycpu>
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
    80000f20:	b1a080e7          	jalr	-1254(ra) # 80001a36 <cpuid>
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
    80000f3c:	afe080e7          	jalr	-1282(ra) # 80001a36 <cpuid>
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
    80000f5e:	78e080e7          	jalr	1934(ra) # 800026e8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	f3e080e7          	jalr	-194(ra) # 80005ea0 <plicinithart>
  }

  scheduler();        
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	05c080e7          	jalr	92(ra) # 80001fc6 <scheduler>
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
    80000fbe:	306080e7          	jalr	774(ra) # 800012c0 <kvminit>
    kvminithart();   // turn on paging
    80000fc2:	00000097          	auipc	ra,0x0
    80000fc6:	068080e7          	jalr	104(ra) # 8000102a <kvminithart>
    procinit();      // process table
    80000fca:	00001097          	auipc	ra,0x1
    80000fce:	99c080e7          	jalr	-1636(ra) # 80001966 <procinit>
    trapinit();      // trap vectors
    80000fd2:	00001097          	auipc	ra,0x1
    80000fd6:	6ee080e7          	jalr	1774(ra) # 800026c0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fda:	00001097          	auipc	ra,0x1
    80000fde:	70e080e7          	jalr	1806(ra) # 800026e8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fe2:	00005097          	auipc	ra,0x5
    80000fe6:	ea8080e7          	jalr	-344(ra) # 80005e8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fea:	00005097          	auipc	ra,0x5
    80000fee:	eb6080e7          	jalr	-330(ra) # 80005ea0 <plicinithart>
    binit();         // buffer cache
    80000ff2:	00002097          	auipc	ra,0x2
    80000ff6:	068080e7          	jalr	104(ra) # 8000305a <binit>
    iinit();         // inode cache
    80000ffa:	00002097          	auipc	ra,0x2
    80000ffe:	6f8080e7          	jalr	1784(ra) # 800036f2 <iinit>
    fileinit();      // file table
    80001002:	00003097          	auipc	ra,0x3
    80001006:	692080e7          	jalr	1682(ra) # 80004694 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000100a:	00005097          	auipc	ra,0x5
    8000100e:	f9e080e7          	jalr	-98(ra) # 80005fa8 <virtio_disk_init>
    userinit();      // first user process
    80001012:	00001097          	auipc	ra,0x1
    80001016:	d4a080e7          	jalr	-694(ra) # 80001d5c <userinit>
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

00000000800010f4 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    800010f4:	1101                	addi	sp,sp,-32
    800010f6:	ec06                	sd	ra,24(sp)
    800010f8:	e822                	sd	s0,16(sp)
    800010fa:	e426                	sd	s1,8(sp)
    800010fc:	1000                	addi	s0,sp,32
    800010fe:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001100:	1552                	slli	a0,a0,0x34
    80001102:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    80001106:	4601                	li	a2,0
    80001108:	00008517          	auipc	a0,0x8
    8000110c:	f0853503          	ld	a0,-248(a0) # 80009010 <kernel_pagetable>
    80001110:	00000097          	auipc	ra,0x0
    80001114:	f3e080e7          	jalr	-194(ra) # 8000104e <walk>
  if(pte == 0)
    80001118:	cd09                	beqz	a0,80001132 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    8000111a:	6108                	ld	a0,0(a0)
    8000111c:	00157793          	andi	a5,a0,1
    80001120:	c38d                	beqz	a5,80001142 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001122:	8129                	srli	a0,a0,0xa
    80001124:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001126:	9526                	add	a0,a0,s1
    80001128:	60e2                	ld	ra,24(sp)
    8000112a:	6442                	ld	s0,16(sp)
    8000112c:	64a2                	ld	s1,8(sp)
    8000112e:	6105                	addi	sp,sp,32
    80001130:	8082                	ret
    panic("kvmpa");
    80001132:	00007517          	auipc	a0,0x7
    80001136:	fbe50513          	addi	a0,a0,-66 # 800080f0 <digits+0x98>
    8000113a:	fffff097          	auipc	ra,0xfffff
    8000113e:	408080e7          	jalr	1032(ra) # 80000542 <panic>
    panic("kvmpa");
    80001142:	00007517          	auipc	a0,0x7
    80001146:	fae50513          	addi	a0,a0,-82 # 800080f0 <digits+0x98>
    8000114a:	fffff097          	auipc	ra,0xfffff
    8000114e:	3f8080e7          	jalr	1016(ra) # 80000542 <panic>

0000000080001152 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001152:	715d                	addi	sp,sp,-80
    80001154:	e486                	sd	ra,72(sp)
    80001156:	e0a2                	sd	s0,64(sp)
    80001158:	fc26                	sd	s1,56(sp)
    8000115a:	f84a                	sd	s2,48(sp)
    8000115c:	f44e                	sd	s3,40(sp)
    8000115e:	f052                	sd	s4,32(sp)
    80001160:	ec56                	sd	s5,24(sp)
    80001162:	e85a                	sd	s6,16(sp)
    80001164:	e45e                	sd	s7,8(sp)
    80001166:	0880                	addi	s0,sp,80
    80001168:	8aaa                	mv	s5,a0
    8000116a:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    8000116c:	777d                	lui	a4,0xfffff
    8000116e:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001172:	167d                	addi	a2,a2,-1
    80001174:	00b609b3          	add	s3,a2,a1
    80001178:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000117c:	893e                	mv	s2,a5
    8000117e:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001182:	6b85                	lui	s7,0x1
    80001184:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001188:	4605                	li	a2,1
    8000118a:	85ca                	mv	a1,s2
    8000118c:	8556                	mv	a0,s5
    8000118e:	00000097          	auipc	ra,0x0
    80001192:	ec0080e7          	jalr	-320(ra) # 8000104e <walk>
    80001196:	c51d                	beqz	a0,800011c4 <mappages+0x72>
    if(*pte & PTE_V)
    80001198:	611c                	ld	a5,0(a0)
    8000119a:	8b85                	andi	a5,a5,1
    8000119c:	ef81                	bnez	a5,800011b4 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000119e:	80b1                	srli	s1,s1,0xc
    800011a0:	04aa                	slli	s1,s1,0xa
    800011a2:	0164e4b3          	or	s1,s1,s6
    800011a6:	0014e493          	ori	s1,s1,1
    800011aa:	e104                	sd	s1,0(a0)
    if(a == last)
    800011ac:	03390863          	beq	s2,s3,800011dc <mappages+0x8a>
    a += PGSIZE;
    800011b0:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800011b2:	bfc9                	j	80001184 <mappages+0x32>
      panic("remap");
    800011b4:	00007517          	auipc	a0,0x7
    800011b8:	f4450513          	addi	a0,a0,-188 # 800080f8 <digits+0xa0>
    800011bc:	fffff097          	auipc	ra,0xfffff
    800011c0:	386080e7          	jalr	902(ra) # 80000542 <panic>
      return -1;
    800011c4:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011c6:	60a6                	ld	ra,72(sp)
    800011c8:	6406                	ld	s0,64(sp)
    800011ca:	74e2                	ld	s1,56(sp)
    800011cc:	7942                	ld	s2,48(sp)
    800011ce:	79a2                	ld	s3,40(sp)
    800011d0:	7a02                	ld	s4,32(sp)
    800011d2:	6ae2                	ld	s5,24(sp)
    800011d4:	6b42                	ld	s6,16(sp)
    800011d6:	6ba2                	ld	s7,8(sp)
    800011d8:	6161                	addi	sp,sp,80
    800011da:	8082                	ret
  return 0;
    800011dc:	4501                	li	a0,0
    800011de:	b7e5                	j	800011c6 <mappages+0x74>

00000000800011e0 <walkaddr>:
{
    800011e0:	7179                	addi	sp,sp,-48
    800011e2:	f406                	sd	ra,40(sp)
    800011e4:	f022                	sd	s0,32(sp)
    800011e6:	ec26                	sd	s1,24(sp)
    800011e8:	e84a                	sd	s2,16(sp)
    800011ea:	e44e                	sd	s3,8(sp)
    800011ec:	e052                	sd	s4,0(sp)
    800011ee:	1800                	addi	s0,sp,48
  if(va >= MAXVA)
    800011f0:	57fd                	li	a5,-1
    800011f2:	83e9                	srli	a5,a5,0x1a
    return 0;
    800011f4:	4901                	li	s2,0
  if(va >= MAXVA)
    800011f6:	00b7fb63          	bgeu	a5,a1,8000120c <walkaddr+0x2c>
}
    800011fa:	854a                	mv	a0,s2
    800011fc:	70a2                	ld	ra,40(sp)
    800011fe:	7402                	ld	s0,32(sp)
    80001200:	64e2                	ld	s1,24(sp)
    80001202:	6942                	ld	s2,16(sp)
    80001204:	69a2                	ld	s3,8(sp)
    80001206:	6a02                	ld	s4,0(sp)
    80001208:	6145                	addi	sp,sp,48
    8000120a:	8082                	ret
    8000120c:	84ae                	mv	s1,a1
  pte = walk(pagetable, va, 0);
    8000120e:	4601                	li	a2,0
    80001210:	00000097          	auipc	ra,0x0
    80001214:	e3e080e7          	jalr	-450(ra) # 8000104e <walk>
  if (pte == 0 || (*pte & PTE_V) == 0) {
    80001218:	c509                	beqz	a0,80001222 <walkaddr+0x42>
    8000121a:	611c                	ld	a5,0(a0)
    8000121c:	0017f713          	andi	a4,a5,1
    80001220:	ef21                	bnez	a4,80001278 <walkaddr+0x98>
    struct proc *p = myproc();
    80001222:	00001097          	auipc	ra,0x1
    80001226:	840080e7          	jalr	-1984(ra) # 80001a62 <myproc>
    8000122a:	89aa                	mv	s3,a0
    if(va >= p->sz || va < PGROUNDUP(p->trapframe->sp)) return 0;
    8000122c:	653c                	ld	a5,72(a0)
    8000122e:	4901                	li	s2,0
    80001230:	fcf4f5e3          	bgeu	s1,a5,800011fa <walkaddr+0x1a>
    80001234:	6d3c                	ld	a5,88(a0)
    80001236:	7b9c                	ld	a5,48(a5)
    80001238:	6705                	lui	a4,0x1
    8000123a:	177d                	addi	a4,a4,-1
    8000123c:	97ba                	add	a5,a5,a4
    8000123e:	777d                	lui	a4,0xfffff
    80001240:	8ff9                	and	a5,a5,a4
    80001242:	faf4ece3          	bltu	s1,a5,800011fa <walkaddr+0x1a>
    pa = (uint64)kalloc();
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	934080e7          	jalr	-1740(ra) # 80000b7a <kalloc>
    8000124e:	8a2a                	mv	s4,a0
    if (pa == 0) return 0;
    80001250:	d54d                	beqz	a0,800011fa <walkaddr+0x1a>
    pa = (uint64)kalloc();
    80001252:	892a                	mv	s2,a0
    if (mappages(p->pagetable, va, PGSIZE, pa, PTE_W|PTE_R|PTE_U|PTE_X) != 0) {
    80001254:	4779                	li	a4,30
    80001256:	86aa                	mv	a3,a0
    80001258:	6605                	lui	a2,0x1
    8000125a:	85a6                	mv	a1,s1
    8000125c:	0509b503          	ld	a0,80(s3) # 1050 <_entry-0x7fffefb0>
    80001260:	00000097          	auipc	ra,0x0
    80001264:	ef2080e7          	jalr	-270(ra) # 80001152 <mappages>
    80001268:	d949                	beqz	a0,800011fa <walkaddr+0x1a>
      kfree((void*)pa);
    8000126a:	8552                	mv	a0,s4
    8000126c:	00000097          	auipc	ra,0x0
    80001270:	812080e7          	jalr	-2030(ra) # 80000a7e <kfree>
	  return 0;
    80001274:	4901                	li	s2,0
    80001276:	b751                	j	800011fa <walkaddr+0x1a>
  if((*pte & PTE_U) == 0)
    80001278:	0107f913          	andi	s2,a5,16
    8000127c:	f6090fe3          	beqz	s2,800011fa <walkaddr+0x1a>
  pa = PTE2PA(*pte);
    80001280:	83a9                	srli	a5,a5,0xa
    80001282:	00c79913          	slli	s2,a5,0xc
  return pa;
    80001286:	bf95                	j	800011fa <walkaddr+0x1a>

0000000080001288 <kvmmap>:
{
    80001288:	1141                	addi	sp,sp,-16
    8000128a:	e406                	sd	ra,8(sp)
    8000128c:	e022                	sd	s0,0(sp)
    8000128e:	0800                	addi	s0,sp,16
    80001290:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001292:	86ae                	mv	a3,a1
    80001294:	85aa                	mv	a1,a0
    80001296:	00008517          	auipc	a0,0x8
    8000129a:	d7a53503          	ld	a0,-646(a0) # 80009010 <kernel_pagetable>
    8000129e:	00000097          	auipc	ra,0x0
    800012a2:	eb4080e7          	jalr	-332(ra) # 80001152 <mappages>
    800012a6:	e509                	bnez	a0,800012b0 <kvmmap+0x28>
}
    800012a8:	60a2                	ld	ra,8(sp)
    800012aa:	6402                	ld	s0,0(sp)
    800012ac:	0141                	addi	sp,sp,16
    800012ae:	8082                	ret
    panic("kvmmap");
    800012b0:	00007517          	auipc	a0,0x7
    800012b4:	e5050513          	addi	a0,a0,-432 # 80008100 <digits+0xa8>
    800012b8:	fffff097          	auipc	ra,0xfffff
    800012bc:	28a080e7          	jalr	650(ra) # 80000542 <panic>

00000000800012c0 <kvminit>:
{
    800012c0:	1101                	addi	sp,sp,-32
    800012c2:	ec06                	sd	ra,24(sp)
    800012c4:	e822                	sd	s0,16(sp)
    800012c6:	e426                	sd	s1,8(sp)
    800012c8:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800012ca:	00000097          	auipc	ra,0x0
    800012ce:	8b0080e7          	jalr	-1872(ra) # 80000b7a <kalloc>
    800012d2:	00008797          	auipc	a5,0x8
    800012d6:	d2a7bf23          	sd	a0,-706(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800012da:	6605                	lui	a2,0x1
    800012dc:	4581                	li	a1,0
    800012de:	00000097          	auipc	ra,0x0
    800012e2:	a88080e7          	jalr	-1400(ra) # 80000d66 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012e6:	4699                	li	a3,6
    800012e8:	6605                	lui	a2,0x1
    800012ea:	100005b7          	lui	a1,0x10000
    800012ee:	10000537          	lui	a0,0x10000
    800012f2:	00000097          	auipc	ra,0x0
    800012f6:	f96080e7          	jalr	-106(ra) # 80001288 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012fa:	4699                	li	a3,6
    800012fc:	6605                	lui	a2,0x1
    800012fe:	100015b7          	lui	a1,0x10001
    80001302:	10001537          	lui	a0,0x10001
    80001306:	00000097          	auipc	ra,0x0
    8000130a:	f82080e7          	jalr	-126(ra) # 80001288 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000130e:	4699                	li	a3,6
    80001310:	6641                	lui	a2,0x10
    80001312:	020005b7          	lui	a1,0x2000
    80001316:	02000537          	lui	a0,0x2000
    8000131a:	00000097          	auipc	ra,0x0
    8000131e:	f6e080e7          	jalr	-146(ra) # 80001288 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001322:	4699                	li	a3,6
    80001324:	00400637          	lui	a2,0x400
    80001328:	0c0005b7          	lui	a1,0xc000
    8000132c:	0c000537          	lui	a0,0xc000
    80001330:	00000097          	auipc	ra,0x0
    80001334:	f58080e7          	jalr	-168(ra) # 80001288 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001338:	00007497          	auipc	s1,0x7
    8000133c:	cc848493          	addi	s1,s1,-824 # 80008000 <etext>
    80001340:	46a9                	li	a3,10
    80001342:	80007617          	auipc	a2,0x80007
    80001346:	cbe60613          	addi	a2,a2,-834 # 8000 <_entry-0x7fff8000>
    8000134a:	4585                	li	a1,1
    8000134c:	05fe                	slli	a1,a1,0x1f
    8000134e:	852e                	mv	a0,a1
    80001350:	00000097          	auipc	ra,0x0
    80001354:	f38080e7          	jalr	-200(ra) # 80001288 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001358:	4699                	li	a3,6
    8000135a:	4645                	li	a2,17
    8000135c:	066e                	slli	a2,a2,0x1b
    8000135e:	8e05                	sub	a2,a2,s1
    80001360:	85a6                	mv	a1,s1
    80001362:	8526                	mv	a0,s1
    80001364:	00000097          	auipc	ra,0x0
    80001368:	f24080e7          	jalr	-220(ra) # 80001288 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000136c:	46a9                	li	a3,10
    8000136e:	6605                	lui	a2,0x1
    80001370:	00006597          	auipc	a1,0x6
    80001374:	c9058593          	addi	a1,a1,-880 # 80007000 <_trampoline>
    80001378:	04000537          	lui	a0,0x4000
    8000137c:	157d                	addi	a0,a0,-1
    8000137e:	0532                	slli	a0,a0,0xc
    80001380:	00000097          	auipc	ra,0x0
    80001384:	f08080e7          	jalr	-248(ra) # 80001288 <kvmmap>
}
    80001388:	60e2                	ld	ra,24(sp)
    8000138a:	6442                	ld	s0,16(sp)
    8000138c:	64a2                	ld	s1,8(sp)
    8000138e:	6105                	addi	sp,sp,32
    80001390:	8082                	ret

0000000080001392 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001392:	715d                	addi	sp,sp,-80
    80001394:	e486                	sd	ra,72(sp)
    80001396:	e0a2                	sd	s0,64(sp)
    80001398:	fc26                	sd	s1,56(sp)
    8000139a:	f84a                	sd	s2,48(sp)
    8000139c:	f44e                	sd	s3,40(sp)
    8000139e:	f052                	sd	s4,32(sp)
    800013a0:	ec56                	sd	s5,24(sp)
    800013a2:	e85a                	sd	s6,16(sp)
    800013a4:	e45e                	sd	s7,8(sp)
    800013a6:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800013a8:	03459793          	slli	a5,a1,0x34
    800013ac:	e795                	bnez	a5,800013d8 <uvmunmap+0x46>
    800013ae:	8a2a                	mv	s4,a0
    800013b0:	892e                	mv	s2,a1
    800013b2:	8b36                	mv	s6,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013b4:	0632                	slli	a2,a2,0xc
    800013b6:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
     continue;
      //panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      continue;
    if(PTE_FLAGS(*pte) == PTE_V)
    800013ba:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013bc:	6a85                	lui	s5,0x1
    800013be:	0535e263          	bltu	a1,s3,80001402 <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800013c2:	60a6                	ld	ra,72(sp)
    800013c4:	6406                	ld	s0,64(sp)
    800013c6:	74e2                	ld	s1,56(sp)
    800013c8:	7942                	ld	s2,48(sp)
    800013ca:	79a2                	ld	s3,40(sp)
    800013cc:	7a02                	ld	s4,32(sp)
    800013ce:	6ae2                	ld	s5,24(sp)
    800013d0:	6b42                	ld	s6,16(sp)
    800013d2:	6ba2                	ld	s7,8(sp)
    800013d4:	6161                	addi	sp,sp,80
    800013d6:	8082                	ret
    panic("uvmunmap: not aligned");
    800013d8:	00007517          	auipc	a0,0x7
    800013dc:	d3050513          	addi	a0,a0,-720 # 80008108 <digits+0xb0>
    800013e0:	fffff097          	auipc	ra,0xfffff
    800013e4:	162080e7          	jalr	354(ra) # 80000542 <panic>
      panic("uvmunmap: not a leaf");
    800013e8:	00007517          	auipc	a0,0x7
    800013ec:	d3850513          	addi	a0,a0,-712 # 80008120 <digits+0xc8>
    800013f0:	fffff097          	auipc	ra,0xfffff
    800013f4:	152080e7          	jalr	338(ra) # 80000542 <panic>
    *pte = 0;
    800013f8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013fc:	9956                	add	s2,s2,s5
    800013fe:	fd3972e3          	bgeu	s2,s3,800013c2 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001402:	4601                	li	a2,0
    80001404:	85ca                	mv	a1,s2
    80001406:	8552                	mv	a0,s4
    80001408:	00000097          	auipc	ra,0x0
    8000140c:	c46080e7          	jalr	-954(ra) # 8000104e <walk>
    80001410:	84aa                	mv	s1,a0
    80001412:	d56d                	beqz	a0,800013fc <uvmunmap+0x6a>
    if((*pte & PTE_V) == 0)
    80001414:	611c                	ld	a5,0(a0)
    80001416:	0017f713          	andi	a4,a5,1
    8000141a:	d36d                	beqz	a4,800013fc <uvmunmap+0x6a>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000141c:	3ff7f713          	andi	a4,a5,1023
    80001420:	fd7704e3          	beq	a4,s7,800013e8 <uvmunmap+0x56>
    if(do_free){
    80001424:	fc0b0ae3          	beqz	s6,800013f8 <uvmunmap+0x66>
      uint64 pa = PTE2PA(*pte);
    80001428:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000142a:	00c79513          	slli	a0,a5,0xc
    8000142e:	fffff097          	auipc	ra,0xfffff
    80001432:	650080e7          	jalr	1616(ra) # 80000a7e <kfree>
    80001436:	b7c9                	j	800013f8 <uvmunmap+0x66>

0000000080001438 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001438:	1101                	addi	sp,sp,-32
    8000143a:	ec06                	sd	ra,24(sp)
    8000143c:	e822                	sd	s0,16(sp)
    8000143e:	e426                	sd	s1,8(sp)
    80001440:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	738080e7          	jalr	1848(ra) # 80000b7a <kalloc>
    8000144a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000144c:	c519                	beqz	a0,8000145a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	914080e7          	jalr	-1772(ra) # 80000d66 <memset>
  return pagetable;
}
    8000145a:	8526                	mv	a0,s1
    8000145c:	60e2                	ld	ra,24(sp)
    8000145e:	6442                	ld	s0,16(sp)
    80001460:	64a2                	ld	s1,8(sp)
    80001462:	6105                	addi	sp,sp,32
    80001464:	8082                	ret

0000000080001466 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001466:	7179                	addi	sp,sp,-48
    80001468:	f406                	sd	ra,40(sp)
    8000146a:	f022                	sd	s0,32(sp)
    8000146c:	ec26                	sd	s1,24(sp)
    8000146e:	e84a                	sd	s2,16(sp)
    80001470:	e44e                	sd	s3,8(sp)
    80001472:	e052                	sd	s4,0(sp)
    80001474:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001476:	6785                	lui	a5,0x1
    80001478:	04f67863          	bgeu	a2,a5,800014c8 <uvminit+0x62>
    8000147c:	8a2a                	mv	s4,a0
    8000147e:	89ae                	mv	s3,a1
    80001480:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001482:	fffff097          	auipc	ra,0xfffff
    80001486:	6f8080e7          	jalr	1784(ra) # 80000b7a <kalloc>
    8000148a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000148c:	6605                	lui	a2,0x1
    8000148e:	4581                	li	a1,0
    80001490:	00000097          	auipc	ra,0x0
    80001494:	8d6080e7          	jalr	-1834(ra) # 80000d66 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001498:	4779                	li	a4,30
    8000149a:	86ca                	mv	a3,s2
    8000149c:	6605                	lui	a2,0x1
    8000149e:	4581                	li	a1,0
    800014a0:	8552                	mv	a0,s4
    800014a2:	00000097          	auipc	ra,0x0
    800014a6:	cb0080e7          	jalr	-848(ra) # 80001152 <mappages>
  memmove(mem, src, sz);
    800014aa:	8626                	mv	a2,s1
    800014ac:	85ce                	mv	a1,s3
    800014ae:	854a                	mv	a0,s2
    800014b0:	00000097          	auipc	ra,0x0
    800014b4:	912080e7          	jalr	-1774(ra) # 80000dc2 <memmove>
}
    800014b8:	70a2                	ld	ra,40(sp)
    800014ba:	7402                	ld	s0,32(sp)
    800014bc:	64e2                	ld	s1,24(sp)
    800014be:	6942                	ld	s2,16(sp)
    800014c0:	69a2                	ld	s3,8(sp)
    800014c2:	6a02                	ld	s4,0(sp)
    800014c4:	6145                	addi	sp,sp,48
    800014c6:	8082                	ret
    panic("inituvm: more than a page");
    800014c8:	00007517          	auipc	a0,0x7
    800014cc:	c7050513          	addi	a0,a0,-912 # 80008138 <digits+0xe0>
    800014d0:	fffff097          	auipc	ra,0xfffff
    800014d4:	072080e7          	jalr	114(ra) # 80000542 <panic>

00000000800014d8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800014d8:	1101                	addi	sp,sp,-32
    800014da:	ec06                	sd	ra,24(sp)
    800014dc:	e822                	sd	s0,16(sp)
    800014de:	e426                	sd	s1,8(sp)
    800014e0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800014e2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800014e4:	00b67d63          	bgeu	a2,a1,800014fe <uvmdealloc+0x26>
    800014e8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014ea:	6785                	lui	a5,0x1
    800014ec:	17fd                	addi	a5,a5,-1
    800014ee:	00f60733          	add	a4,a2,a5
    800014f2:	767d                	lui	a2,0xfffff
    800014f4:	8f71                	and	a4,a4,a2
    800014f6:	97ae                	add	a5,a5,a1
    800014f8:	8ff1                	and	a5,a5,a2
    800014fa:	00f76863          	bltu	a4,a5,8000150a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014fe:	8526                	mv	a0,s1
    80001500:	60e2                	ld	ra,24(sp)
    80001502:	6442                	ld	s0,16(sp)
    80001504:	64a2                	ld	s1,8(sp)
    80001506:	6105                	addi	sp,sp,32
    80001508:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000150a:	8f99                	sub	a5,a5,a4
    8000150c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000150e:	4685                	li	a3,1
    80001510:	0007861b          	sext.w	a2,a5
    80001514:	85ba                	mv	a1,a4
    80001516:	00000097          	auipc	ra,0x0
    8000151a:	e7c080e7          	jalr	-388(ra) # 80001392 <uvmunmap>
    8000151e:	b7c5                	j	800014fe <uvmdealloc+0x26>

0000000080001520 <uvmalloc>:
  if(newsz < oldsz)
    80001520:	0ab66163          	bltu	a2,a1,800015c2 <uvmalloc+0xa2>
{
    80001524:	7139                	addi	sp,sp,-64
    80001526:	fc06                	sd	ra,56(sp)
    80001528:	f822                	sd	s0,48(sp)
    8000152a:	f426                	sd	s1,40(sp)
    8000152c:	f04a                	sd	s2,32(sp)
    8000152e:	ec4e                	sd	s3,24(sp)
    80001530:	e852                	sd	s4,16(sp)
    80001532:	e456                	sd	s5,8(sp)
    80001534:	0080                	addi	s0,sp,64
    80001536:	8aaa                	mv	s5,a0
    80001538:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000153a:	6985                	lui	s3,0x1
    8000153c:	19fd                	addi	s3,s3,-1
    8000153e:	95ce                	add	a1,a1,s3
    80001540:	79fd                	lui	s3,0xfffff
    80001542:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001546:	08c9f063          	bgeu	s3,a2,800015c6 <uvmalloc+0xa6>
    8000154a:	894e                	mv	s2,s3
    mem = kalloc();
    8000154c:	fffff097          	auipc	ra,0xfffff
    80001550:	62e080e7          	jalr	1582(ra) # 80000b7a <kalloc>
    80001554:	84aa                	mv	s1,a0
    if(mem == 0){
    80001556:	c51d                	beqz	a0,80001584 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001558:	6605                	lui	a2,0x1
    8000155a:	4581                	li	a1,0
    8000155c:	00000097          	auipc	ra,0x0
    80001560:	80a080e7          	jalr	-2038(ra) # 80000d66 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001564:	4779                	li	a4,30
    80001566:	86a6                	mv	a3,s1
    80001568:	6605                	lui	a2,0x1
    8000156a:	85ca                	mv	a1,s2
    8000156c:	8556                	mv	a0,s5
    8000156e:	00000097          	auipc	ra,0x0
    80001572:	be4080e7          	jalr	-1052(ra) # 80001152 <mappages>
    80001576:	e905                	bnez	a0,800015a6 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001578:	6785                	lui	a5,0x1
    8000157a:	993e                	add	s2,s2,a5
    8000157c:	fd4968e3          	bltu	s2,s4,8000154c <uvmalloc+0x2c>
  return newsz;
    80001580:	8552                	mv	a0,s4
    80001582:	a809                	j	80001594 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001584:	864e                	mv	a2,s3
    80001586:	85ca                	mv	a1,s2
    80001588:	8556                	mv	a0,s5
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	f4e080e7          	jalr	-178(ra) # 800014d8 <uvmdealloc>
      return 0;
    80001592:	4501                	li	a0,0
}
    80001594:	70e2                	ld	ra,56(sp)
    80001596:	7442                	ld	s0,48(sp)
    80001598:	74a2                	ld	s1,40(sp)
    8000159a:	7902                	ld	s2,32(sp)
    8000159c:	69e2                	ld	s3,24(sp)
    8000159e:	6a42                	ld	s4,16(sp)
    800015a0:	6aa2                	ld	s5,8(sp)
    800015a2:	6121                	addi	sp,sp,64
    800015a4:	8082                	ret
      kfree(mem);
    800015a6:	8526                	mv	a0,s1
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	4d6080e7          	jalr	1238(ra) # 80000a7e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800015b0:	864e                	mv	a2,s3
    800015b2:	85ca                	mv	a1,s2
    800015b4:	8556                	mv	a0,s5
    800015b6:	00000097          	auipc	ra,0x0
    800015ba:	f22080e7          	jalr	-222(ra) # 800014d8 <uvmdealloc>
      return 0;
    800015be:	4501                	li	a0,0
    800015c0:	bfd1                	j	80001594 <uvmalloc+0x74>
    return oldsz;
    800015c2:	852e                	mv	a0,a1
}
    800015c4:	8082                	ret
  return newsz;
    800015c6:	8532                	mv	a0,a2
    800015c8:	b7f1                	j	80001594 <uvmalloc+0x74>

00000000800015ca <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800015ca:	7179                	addi	sp,sp,-48
    800015cc:	f406                	sd	ra,40(sp)
    800015ce:	f022                	sd	s0,32(sp)
    800015d0:	ec26                	sd	s1,24(sp)
    800015d2:	e84a                	sd	s2,16(sp)
    800015d4:	e44e                	sd	s3,8(sp)
    800015d6:	e052                	sd	s4,0(sp)
    800015d8:	1800                	addi	s0,sp,48
    800015da:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800015dc:	84aa                	mv	s1,a0
    800015de:	6905                	lui	s2,0x1
    800015e0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015e2:	4985                	li	s3,1
    800015e4:	a821                	j	800015fc <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015e6:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800015e8:	0532                	slli	a0,a0,0xc
    800015ea:	00000097          	auipc	ra,0x0
    800015ee:	fe0080e7          	jalr	-32(ra) # 800015ca <freewalk>
      pagetable[i] = 0;
    800015f2:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015f6:	04a1                	addi	s1,s1,8
    800015f8:	03248163          	beq	s1,s2,8000161a <freewalk+0x50>
    pte_t pte = pagetable[i];
    800015fc:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015fe:	00f57793          	andi	a5,a0,15
    80001602:	ff3782e3          	beq	a5,s3,800015e6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001606:	8905                	andi	a0,a0,1
    80001608:	d57d                	beqz	a0,800015f6 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000160a:	00007517          	auipc	a0,0x7
    8000160e:	b4e50513          	addi	a0,a0,-1202 # 80008158 <digits+0x100>
    80001612:	fffff097          	auipc	ra,0xfffff
    80001616:	f30080e7          	jalr	-208(ra) # 80000542 <panic>
    }
  }
  kfree((void*)pagetable);
    8000161a:	8552                	mv	a0,s4
    8000161c:	fffff097          	auipc	ra,0xfffff
    80001620:	462080e7          	jalr	1122(ra) # 80000a7e <kfree>
}
    80001624:	70a2                	ld	ra,40(sp)
    80001626:	7402                	ld	s0,32(sp)
    80001628:	64e2                	ld	s1,24(sp)
    8000162a:	6942                	ld	s2,16(sp)
    8000162c:	69a2                	ld	s3,8(sp)
    8000162e:	6a02                	ld	s4,0(sp)
    80001630:	6145                	addi	sp,sp,48
    80001632:	8082                	ret

0000000080001634 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001634:	1101                	addi	sp,sp,-32
    80001636:	ec06                	sd	ra,24(sp)
    80001638:	e822                	sd	s0,16(sp)
    8000163a:	e426                	sd	s1,8(sp)
    8000163c:	1000                	addi	s0,sp,32
    8000163e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001640:	e999                	bnez	a1,80001656 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001642:	8526                	mv	a0,s1
    80001644:	00000097          	auipc	ra,0x0
    80001648:	f86080e7          	jalr	-122(ra) # 800015ca <freewalk>
}
    8000164c:	60e2                	ld	ra,24(sp)
    8000164e:	6442                	ld	s0,16(sp)
    80001650:	64a2                	ld	s1,8(sp)
    80001652:	6105                	addi	sp,sp,32
    80001654:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001656:	6605                	lui	a2,0x1
    80001658:	167d                	addi	a2,a2,-1
    8000165a:	962e                	add	a2,a2,a1
    8000165c:	4685                	li	a3,1
    8000165e:	8231                	srli	a2,a2,0xc
    80001660:	4581                	li	a1,0
    80001662:	00000097          	auipc	ra,0x0
    80001666:	d30080e7          	jalr	-720(ra) # 80001392 <uvmunmap>
    8000166a:	bfe1                	j	80001642 <uvmfree+0xe>

000000008000166c <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000166c:	ca4d                	beqz	a2,8000171e <uvmcopy+0xb2>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	0880                	addi	s0,sp,80
    80001684:	8aaa                	mv	s5,a0
    80001686:	8b2e                	mv	s6,a1
    80001688:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000168a:	4481                	li	s1,0
    8000168c:	a029                	j	80001696 <uvmcopy+0x2a>
    8000168e:	6785                	lui	a5,0x1
    80001690:	94be                	add	s1,s1,a5
    80001692:	0744fa63          	bgeu	s1,s4,80001706 <uvmcopy+0x9a>
    if((pte = walk(old, i, 0)) == 0)
    80001696:	4601                	li	a2,0
    80001698:	85a6                	mv	a1,s1
    8000169a:	8556                	mv	a0,s5
    8000169c:	00000097          	auipc	ra,0x0
    800016a0:	9b2080e7          	jalr	-1614(ra) # 8000104e <walk>
    800016a4:	d56d                	beqz	a0,8000168e <uvmcopy+0x22>
      continue;//panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016a6:	6118                	ld	a4,0(a0)
    800016a8:	00177793          	andi	a5,a4,1
    800016ac:	d3ed                	beqz	a5,8000168e <uvmcopy+0x22>
      continue;//panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800016ae:	00a75593          	srli	a1,a4,0xa
    800016b2:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800016b6:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    800016ba:	fffff097          	auipc	ra,0xfffff
    800016be:	4c0080e7          	jalr	1216(ra) # 80000b7a <kalloc>
    800016c2:	89aa                	mv	s3,a0
    800016c4:	c515                	beqz	a0,800016f0 <uvmcopy+0x84>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016c6:	6605                	lui	a2,0x1
    800016c8:	85de                	mv	a1,s7
    800016ca:	fffff097          	auipc	ra,0xfffff
    800016ce:	6f8080e7          	jalr	1784(ra) # 80000dc2 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800016d2:	874a                	mv	a4,s2
    800016d4:	86ce                	mv	a3,s3
    800016d6:	6605                	lui	a2,0x1
    800016d8:	85a6                	mv	a1,s1
    800016da:	855a                	mv	a0,s6
    800016dc:	00000097          	auipc	ra,0x0
    800016e0:	a76080e7          	jalr	-1418(ra) # 80001152 <mappages>
    800016e4:	d54d                	beqz	a0,8000168e <uvmcopy+0x22>
      kfree(mem);
    800016e6:	854e                	mv	a0,s3
    800016e8:	fffff097          	auipc	ra,0xfffff
    800016ec:	396080e7          	jalr	918(ra) # 80000a7e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016f0:	4685                	li	a3,1
    800016f2:	00c4d613          	srli	a2,s1,0xc
    800016f6:	4581                	li	a1,0
    800016f8:	855a                	mv	a0,s6
    800016fa:	00000097          	auipc	ra,0x0
    800016fe:	c98080e7          	jalr	-872(ra) # 80001392 <uvmunmap>
  return -1;
    80001702:	557d                	li	a0,-1
    80001704:	a011                	j	80001708 <uvmcopy+0x9c>
  return 0;
    80001706:	4501                	li	a0,0
}
    80001708:	60a6                	ld	ra,72(sp)
    8000170a:	6406                	ld	s0,64(sp)
    8000170c:	74e2                	ld	s1,56(sp)
    8000170e:	7942                	ld	s2,48(sp)
    80001710:	79a2                	ld	s3,40(sp)
    80001712:	7a02                	ld	s4,32(sp)
    80001714:	6ae2                	ld	s5,24(sp)
    80001716:	6b42                	ld	s6,16(sp)
    80001718:	6ba2                	ld	s7,8(sp)
    8000171a:	6161                	addi	sp,sp,80
    8000171c:	8082                	ret
  return 0;
    8000171e:	4501                	li	a0,0
}
    80001720:	8082                	ret

0000000080001722 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001722:	1141                	addi	sp,sp,-16
    80001724:	e406                	sd	ra,8(sp)
    80001726:	e022                	sd	s0,0(sp)
    80001728:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000172a:	4601                	li	a2,0
    8000172c:	00000097          	auipc	ra,0x0
    80001730:	922080e7          	jalr	-1758(ra) # 8000104e <walk>
  if(pte == 0)
    80001734:	c901                	beqz	a0,80001744 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001736:	611c                	ld	a5,0(a0)
    80001738:	9bbd                	andi	a5,a5,-17
    8000173a:	e11c                	sd	a5,0(a0)
}
    8000173c:	60a2                	ld	ra,8(sp)
    8000173e:	6402                	ld	s0,0(sp)
    80001740:	0141                	addi	sp,sp,16
    80001742:	8082                	ret
    panic("uvmclear");
    80001744:	00007517          	auipc	a0,0x7
    80001748:	a2450513          	addi	a0,a0,-1500 # 80008168 <digits+0x110>
    8000174c:	fffff097          	auipc	ra,0xfffff
    80001750:	df6080e7          	jalr	-522(ra) # 80000542 <panic>

0000000080001754 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001754:	c6bd                	beqz	a3,800017c2 <copyout+0x6e>
{
    80001756:	715d                	addi	sp,sp,-80
    80001758:	e486                	sd	ra,72(sp)
    8000175a:	e0a2                	sd	s0,64(sp)
    8000175c:	fc26                	sd	s1,56(sp)
    8000175e:	f84a                	sd	s2,48(sp)
    80001760:	f44e                	sd	s3,40(sp)
    80001762:	f052                	sd	s4,32(sp)
    80001764:	ec56                	sd	s5,24(sp)
    80001766:	e85a                	sd	s6,16(sp)
    80001768:	e45e                	sd	s7,8(sp)
    8000176a:	e062                	sd	s8,0(sp)
    8000176c:	0880                	addi	s0,sp,80
    8000176e:	8b2a                	mv	s6,a0
    80001770:	8c2e                	mv	s8,a1
    80001772:	8a32                	mv	s4,a2
    80001774:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001776:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001778:	6a85                	lui	s5,0x1
    8000177a:	a015                	j	8000179e <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000177c:	9562                	add	a0,a0,s8
    8000177e:	0004861b          	sext.w	a2,s1
    80001782:	85d2                	mv	a1,s4
    80001784:	41250533          	sub	a0,a0,s2
    80001788:	fffff097          	auipc	ra,0xfffff
    8000178c:	63a080e7          	jalr	1594(ra) # 80000dc2 <memmove>

    len -= n;
    80001790:	409989b3          	sub	s3,s3,s1
    src += n;
    80001794:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001796:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000179a:	02098263          	beqz	s3,800017be <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000179e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017a2:	85ca                	mv	a1,s2
    800017a4:	855a                	mv	a0,s6
    800017a6:	00000097          	auipc	ra,0x0
    800017aa:	a3a080e7          	jalr	-1478(ra) # 800011e0 <walkaddr>
    if(pa0 == 0)
    800017ae:	cd01                	beqz	a0,800017c6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800017b0:	418904b3          	sub	s1,s2,s8
    800017b4:	94d6                	add	s1,s1,s5
    if(n > len)
    800017b6:	fc99f3e3          	bgeu	s3,s1,8000177c <copyout+0x28>
    800017ba:	84ce                	mv	s1,s3
    800017bc:	b7c1                	j	8000177c <copyout+0x28>
  }
  return 0;
    800017be:	4501                	li	a0,0
    800017c0:	a021                	j	800017c8 <copyout+0x74>
    800017c2:	4501                	li	a0,0
}
    800017c4:	8082                	ret
      return -1;
    800017c6:	557d                	li	a0,-1
}
    800017c8:	60a6                	ld	ra,72(sp)
    800017ca:	6406                	ld	s0,64(sp)
    800017cc:	74e2                	ld	s1,56(sp)
    800017ce:	7942                	ld	s2,48(sp)
    800017d0:	79a2                	ld	s3,40(sp)
    800017d2:	7a02                	ld	s4,32(sp)
    800017d4:	6ae2                	ld	s5,24(sp)
    800017d6:	6b42                	ld	s6,16(sp)
    800017d8:	6ba2                	ld	s7,8(sp)
    800017da:	6c02                	ld	s8,0(sp)
    800017dc:	6161                	addi	sp,sp,80
    800017de:	8082                	ret

00000000800017e0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017e0:	caa5                	beqz	a3,80001850 <copyin+0x70>
{
    800017e2:	715d                	addi	sp,sp,-80
    800017e4:	e486                	sd	ra,72(sp)
    800017e6:	e0a2                	sd	s0,64(sp)
    800017e8:	fc26                	sd	s1,56(sp)
    800017ea:	f84a                	sd	s2,48(sp)
    800017ec:	f44e                	sd	s3,40(sp)
    800017ee:	f052                	sd	s4,32(sp)
    800017f0:	ec56                	sd	s5,24(sp)
    800017f2:	e85a                	sd	s6,16(sp)
    800017f4:	e45e                	sd	s7,8(sp)
    800017f6:	e062                	sd	s8,0(sp)
    800017f8:	0880                	addi	s0,sp,80
    800017fa:	8b2a                	mv	s6,a0
    800017fc:	8a2e                	mv	s4,a1
    800017fe:	8c32                	mv	s8,a2
    80001800:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001802:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001804:	6a85                	lui	s5,0x1
    80001806:	a01d                	j	8000182c <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001808:	018505b3          	add	a1,a0,s8
    8000180c:	0004861b          	sext.w	a2,s1
    80001810:	412585b3          	sub	a1,a1,s2
    80001814:	8552                	mv	a0,s4
    80001816:	fffff097          	auipc	ra,0xfffff
    8000181a:	5ac080e7          	jalr	1452(ra) # 80000dc2 <memmove>

    len -= n;
    8000181e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001822:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001824:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001828:	02098263          	beqz	s3,8000184c <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000182c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001830:	85ca                	mv	a1,s2
    80001832:	855a                	mv	a0,s6
    80001834:	00000097          	auipc	ra,0x0
    80001838:	9ac080e7          	jalr	-1620(ra) # 800011e0 <walkaddr>
    if(pa0 == 0)
    8000183c:	cd01                	beqz	a0,80001854 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000183e:	418904b3          	sub	s1,s2,s8
    80001842:	94d6                	add	s1,s1,s5
    if(n > len)
    80001844:	fc99f2e3          	bgeu	s3,s1,80001808 <copyin+0x28>
    80001848:	84ce                	mv	s1,s3
    8000184a:	bf7d                	j	80001808 <copyin+0x28>
  }
  return 0;
    8000184c:	4501                	li	a0,0
    8000184e:	a021                	j	80001856 <copyin+0x76>
    80001850:	4501                	li	a0,0
}
    80001852:	8082                	ret
      return -1;
    80001854:	557d                	li	a0,-1
}
    80001856:	60a6                	ld	ra,72(sp)
    80001858:	6406                	ld	s0,64(sp)
    8000185a:	74e2                	ld	s1,56(sp)
    8000185c:	7942                	ld	s2,48(sp)
    8000185e:	79a2                	ld	s3,40(sp)
    80001860:	7a02                	ld	s4,32(sp)
    80001862:	6ae2                	ld	s5,24(sp)
    80001864:	6b42                	ld	s6,16(sp)
    80001866:	6ba2                	ld	s7,8(sp)
    80001868:	6c02                	ld	s8,0(sp)
    8000186a:	6161                	addi	sp,sp,80
    8000186c:	8082                	ret

000000008000186e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000186e:	c6c5                	beqz	a3,80001916 <copyinstr+0xa8>
{
    80001870:	715d                	addi	sp,sp,-80
    80001872:	e486                	sd	ra,72(sp)
    80001874:	e0a2                	sd	s0,64(sp)
    80001876:	fc26                	sd	s1,56(sp)
    80001878:	f84a                	sd	s2,48(sp)
    8000187a:	f44e                	sd	s3,40(sp)
    8000187c:	f052                	sd	s4,32(sp)
    8000187e:	ec56                	sd	s5,24(sp)
    80001880:	e85a                	sd	s6,16(sp)
    80001882:	e45e                	sd	s7,8(sp)
    80001884:	0880                	addi	s0,sp,80
    80001886:	8a2a                	mv	s4,a0
    80001888:	8b2e                	mv	s6,a1
    8000188a:	8bb2                	mv	s7,a2
    8000188c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000188e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001890:	6985                	lui	s3,0x1
    80001892:	a035                	j	800018be <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001894:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001898:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000189a:	0017b793          	seqz	a5,a5
    8000189e:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800018a2:	60a6                	ld	ra,72(sp)
    800018a4:	6406                	ld	s0,64(sp)
    800018a6:	74e2                	ld	s1,56(sp)
    800018a8:	7942                	ld	s2,48(sp)
    800018aa:	79a2                	ld	s3,40(sp)
    800018ac:	7a02                	ld	s4,32(sp)
    800018ae:	6ae2                	ld	s5,24(sp)
    800018b0:	6b42                	ld	s6,16(sp)
    800018b2:	6ba2                	ld	s7,8(sp)
    800018b4:	6161                	addi	sp,sp,80
    800018b6:	8082                	ret
    srcva = va0 + PGSIZE;
    800018b8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800018bc:	c8a9                	beqz	s1,8000190e <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800018be:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800018c2:	85ca                	mv	a1,s2
    800018c4:	8552                	mv	a0,s4
    800018c6:	00000097          	auipc	ra,0x0
    800018ca:	91a080e7          	jalr	-1766(ra) # 800011e0 <walkaddr>
    if(pa0 == 0)
    800018ce:	c131                	beqz	a0,80001912 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800018d0:	41790833          	sub	a6,s2,s7
    800018d4:	984e                	add	a6,a6,s3
    if(n > max)
    800018d6:	0104f363          	bgeu	s1,a6,800018dc <copyinstr+0x6e>
    800018da:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018dc:	955e                	add	a0,a0,s7
    800018de:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018e2:	fc080be3          	beqz	a6,800018b8 <copyinstr+0x4a>
    800018e6:	985a                	add	a6,a6,s6
    800018e8:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018ea:	41650633          	sub	a2,a0,s6
    800018ee:	14fd                	addi	s1,s1,-1
    800018f0:	9b26                	add	s6,s6,s1
    800018f2:	00f60733          	add	a4,a2,a5
    800018f6:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd8000>
    800018fa:	df49                	beqz	a4,80001894 <copyinstr+0x26>
        *dst = *p;
    800018fc:	00e78023          	sb	a4,0(a5)
      --max;
    80001900:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001904:	0785                	addi	a5,a5,1
    while(n > 0){
    80001906:	ff0796e3          	bne	a5,a6,800018f2 <copyinstr+0x84>
      dst++;
    8000190a:	8b42                	mv	s6,a6
    8000190c:	b775                	j	800018b8 <copyinstr+0x4a>
    8000190e:	4781                	li	a5,0
    80001910:	b769                	j	8000189a <copyinstr+0x2c>
      return -1;
    80001912:	557d                	li	a0,-1
    80001914:	b779                	j	800018a2 <copyinstr+0x34>
  int got_null = 0;
    80001916:	4781                	li	a5,0
  if(got_null){
    80001918:	0017b793          	seqz	a5,a5
    8000191c:	40f00533          	neg	a0,a5
}
    80001920:	8082                	ret

0000000080001922 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001922:	1101                	addi	sp,sp,-32
    80001924:	ec06                	sd	ra,24(sp)
    80001926:	e822                	sd	s0,16(sp)
    80001928:	e426                	sd	s1,8(sp)
    8000192a:	1000                	addi	s0,sp,32
    8000192c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000192e:	fffff097          	auipc	ra,0xfffff
    80001932:	2c2080e7          	jalr	706(ra) # 80000bf0 <holding>
    80001936:	c909                	beqz	a0,80001948 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001938:	749c                	ld	a5,40(s1)
    8000193a:	00978f63          	beq	a5,s1,80001958 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    8000193e:	60e2                	ld	ra,24(sp)
    80001940:	6442                	ld	s0,16(sp)
    80001942:	64a2                	ld	s1,8(sp)
    80001944:	6105                	addi	sp,sp,32
    80001946:	8082                	ret
    panic("wakeup1");
    80001948:	00007517          	auipc	a0,0x7
    8000194c:	83050513          	addi	a0,a0,-2000 # 80008178 <digits+0x120>
    80001950:	fffff097          	auipc	ra,0xfffff
    80001954:	bf2080e7          	jalr	-1038(ra) # 80000542 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001958:	4c98                	lw	a4,24(s1)
    8000195a:	4785                	li	a5,1
    8000195c:	fef711e3          	bne	a4,a5,8000193e <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001960:	4789                	li	a5,2
    80001962:	cc9c                	sw	a5,24(s1)
}
    80001964:	bfe9                	j	8000193e <wakeup1+0x1c>

0000000080001966 <procinit>:
{
    80001966:	715d                	addi	sp,sp,-80
    80001968:	e486                	sd	ra,72(sp)
    8000196a:	e0a2                	sd	s0,64(sp)
    8000196c:	fc26                	sd	s1,56(sp)
    8000196e:	f84a                	sd	s2,48(sp)
    80001970:	f44e                	sd	s3,40(sp)
    80001972:	f052                	sd	s4,32(sp)
    80001974:	ec56                	sd	s5,24(sp)
    80001976:	e85a                	sd	s6,16(sp)
    80001978:	e45e                	sd	s7,8(sp)
    8000197a:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    8000197c:	00007597          	auipc	a1,0x7
    80001980:	80458593          	addi	a1,a1,-2044 # 80008180 <digits+0x128>
    80001984:	00010517          	auipc	a0,0x10
    80001988:	fcc50513          	addi	a0,a0,-52 # 80011950 <pid_lock>
    8000198c:	fffff097          	auipc	ra,0xfffff
    80001990:	24e080e7          	jalr	590(ra) # 80000bda <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001994:	00010917          	auipc	s2,0x10
    80001998:	3d490913          	addi	s2,s2,980 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    8000199c:	00006b97          	auipc	s7,0x6
    800019a0:	7ecb8b93          	addi	s7,s7,2028 # 80008188 <digits+0x130>
      uint64 va = KSTACK((int) (p - proc));
    800019a4:	8b4a                	mv	s6,s2
    800019a6:	00006a97          	auipc	s5,0x6
    800019aa:	65aa8a93          	addi	s5,s5,1626 # 80008000 <etext>
    800019ae:	040009b7          	lui	s3,0x4000
    800019b2:	19fd                	addi	s3,s3,-1
    800019b4:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b6:	00016a17          	auipc	s4,0x16
    800019ba:	7b2a0a13          	addi	s4,s4,1970 # 80018168 <tickslock>
      initlock(&p->lock, "proc");
    800019be:	85de                	mv	a1,s7
    800019c0:	854a                	mv	a0,s2
    800019c2:	fffff097          	auipc	ra,0xfffff
    800019c6:	218080e7          	jalr	536(ra) # 80000bda <initlock>
      char *pa = kalloc();
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	1b0080e7          	jalr	432(ra) # 80000b7a <kalloc>
    800019d2:	85aa                	mv	a1,a0
      if(pa == 0)
    800019d4:	c929                	beqz	a0,80001a26 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800019d6:	416904b3          	sub	s1,s2,s6
    800019da:	8491                	srai	s1,s1,0x4
    800019dc:	000ab783          	ld	a5,0(s5)
    800019e0:	02f484b3          	mul	s1,s1,a5
    800019e4:	2485                	addiw	s1,s1,1
    800019e6:	00d4949b          	slliw	s1,s1,0xd
    800019ea:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019ee:	4699                	li	a3,6
    800019f0:	6605                	lui	a2,0x1
    800019f2:	8526                	mv	a0,s1
    800019f4:	00000097          	auipc	ra,0x0
    800019f8:	894080e7          	jalr	-1900(ra) # 80001288 <kvmmap>
      p->kstack = va;
    800019fc:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a00:	19090913          	addi	s2,s2,400
    80001a04:	fb491de3          	bne	s2,s4,800019be <procinit+0x58>
  kvminithart();
    80001a08:	fffff097          	auipc	ra,0xfffff
    80001a0c:	622080e7          	jalr	1570(ra) # 8000102a <kvminithart>
}
    80001a10:	60a6                	ld	ra,72(sp)
    80001a12:	6406                	ld	s0,64(sp)
    80001a14:	74e2                	ld	s1,56(sp)
    80001a16:	7942                	ld	s2,48(sp)
    80001a18:	79a2                	ld	s3,40(sp)
    80001a1a:	7a02                	ld	s4,32(sp)
    80001a1c:	6ae2                	ld	s5,24(sp)
    80001a1e:	6b42                	ld	s6,16(sp)
    80001a20:	6ba2                	ld	s7,8(sp)
    80001a22:	6161                	addi	sp,sp,80
    80001a24:	8082                	ret
        panic("kalloc");
    80001a26:	00006517          	auipc	a0,0x6
    80001a2a:	76a50513          	addi	a0,a0,1898 # 80008190 <digits+0x138>
    80001a2e:	fffff097          	auipc	ra,0xfffff
    80001a32:	b14080e7          	jalr	-1260(ra) # 80000542 <panic>

0000000080001a36 <cpuid>:
{
    80001a36:	1141                	addi	sp,sp,-16
    80001a38:	e422                	sd	s0,8(sp)
    80001a3a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a3c:	8512                	mv	a0,tp
}
    80001a3e:	2501                	sext.w	a0,a0
    80001a40:	6422                	ld	s0,8(sp)
    80001a42:	0141                	addi	sp,sp,16
    80001a44:	8082                	ret

0000000080001a46 <mycpu>:
mycpu(void) {
    80001a46:	1141                	addi	sp,sp,-16
    80001a48:	e422                	sd	s0,8(sp)
    80001a4a:	0800                	addi	s0,sp,16
    80001a4c:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a4e:	2781                	sext.w	a5,a5
    80001a50:	079e                	slli	a5,a5,0x7
}
    80001a52:	00010517          	auipc	a0,0x10
    80001a56:	f1650513          	addi	a0,a0,-234 # 80011968 <cpus>
    80001a5a:	953e                	add	a0,a0,a5
    80001a5c:	6422                	ld	s0,8(sp)
    80001a5e:	0141                	addi	sp,sp,16
    80001a60:	8082                	ret

0000000080001a62 <myproc>:
myproc(void) {
    80001a62:	1101                	addi	sp,sp,-32
    80001a64:	ec06                	sd	ra,24(sp)
    80001a66:	e822                	sd	s0,16(sp)
    80001a68:	e426                	sd	s1,8(sp)
    80001a6a:	1000                	addi	s0,sp,32
  push_off();
    80001a6c:	fffff097          	auipc	ra,0xfffff
    80001a70:	1b2080e7          	jalr	434(ra) # 80000c1e <push_off>
    80001a74:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a76:	2781                	sext.w	a5,a5
    80001a78:	079e                	slli	a5,a5,0x7
    80001a7a:	00010717          	auipc	a4,0x10
    80001a7e:	ed670713          	addi	a4,a4,-298 # 80011950 <pid_lock>
    80001a82:	97ba                	add	a5,a5,a4
    80001a84:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	238080e7          	jalr	568(ra) # 80000cbe <pop_off>
}
    80001a8e:	8526                	mv	a0,s1
    80001a90:	60e2                	ld	ra,24(sp)
    80001a92:	6442                	ld	s0,16(sp)
    80001a94:	64a2                	ld	s1,8(sp)
    80001a96:	6105                	addi	sp,sp,32
    80001a98:	8082                	ret

0000000080001a9a <forkret>:
{
    80001a9a:	1141                	addi	sp,sp,-16
    80001a9c:	e406                	sd	ra,8(sp)
    80001a9e:	e022                	sd	s0,0(sp)
    80001aa0:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001aa2:	00000097          	auipc	ra,0x0
    80001aa6:	fc0080e7          	jalr	-64(ra) # 80001a62 <myproc>
    80001aaa:	fffff097          	auipc	ra,0xfffff
    80001aae:	274080e7          	jalr	628(ra) # 80000d1e <release>
  if (first) {
    80001ab2:	00007797          	auipc	a5,0x7
    80001ab6:	d1e7a783          	lw	a5,-738(a5) # 800087d0 <first.1>
    80001aba:	eb89                	bnez	a5,80001acc <forkret+0x32>
  usertrapret();
    80001abc:	00001097          	auipc	ra,0x1
    80001ac0:	c44080e7          	jalr	-956(ra) # 80002700 <usertrapret>
}
    80001ac4:	60a2                	ld	ra,8(sp)
    80001ac6:	6402                	ld	s0,0(sp)
    80001ac8:	0141                	addi	sp,sp,16
    80001aca:	8082                	ret
    first = 0;
    80001acc:	00007797          	auipc	a5,0x7
    80001ad0:	d007a223          	sw	zero,-764(a5) # 800087d0 <first.1>
    fsinit(ROOTDEV);
    80001ad4:	4505                	li	a0,1
    80001ad6:	00002097          	auipc	ra,0x2
    80001ada:	b9c080e7          	jalr	-1124(ra) # 80003672 <fsinit>
    80001ade:	bff9                	j	80001abc <forkret+0x22>

0000000080001ae0 <allocpid>:
allocpid() {
    80001ae0:	1101                	addi	sp,sp,-32
    80001ae2:	ec06                	sd	ra,24(sp)
    80001ae4:	e822                	sd	s0,16(sp)
    80001ae6:	e426                	sd	s1,8(sp)
    80001ae8:	e04a                	sd	s2,0(sp)
    80001aea:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001aec:	00010917          	auipc	s2,0x10
    80001af0:	e6490913          	addi	s2,s2,-412 # 80011950 <pid_lock>
    80001af4:	854a                	mv	a0,s2
    80001af6:	fffff097          	auipc	ra,0xfffff
    80001afa:	174080e7          	jalr	372(ra) # 80000c6a <acquire>
  pid = nextpid;
    80001afe:	00007797          	auipc	a5,0x7
    80001b02:	cd678793          	addi	a5,a5,-810 # 800087d4 <nextpid>
    80001b06:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b08:	0014871b          	addiw	a4,s1,1
    80001b0c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b0e:	854a                	mv	a0,s2
    80001b10:	fffff097          	auipc	ra,0xfffff
    80001b14:	20e080e7          	jalr	526(ra) # 80000d1e <release>
}
    80001b18:	8526                	mv	a0,s1
    80001b1a:	60e2                	ld	ra,24(sp)
    80001b1c:	6442                	ld	s0,16(sp)
    80001b1e:	64a2                	ld	s1,8(sp)
    80001b20:	6902                	ld	s2,0(sp)
    80001b22:	6105                	addi	sp,sp,32
    80001b24:	8082                	ret

0000000080001b26 <proc_pagetable>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	e04a                	sd	s2,0(sp)
    80001b30:	1000                	addi	s0,sp,32
    80001b32:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b34:	00000097          	auipc	ra,0x0
    80001b38:	904080e7          	jalr	-1788(ra) # 80001438 <uvmcreate>
    80001b3c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b3e:	c121                	beqz	a0,80001b7e <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b40:	4729                	li	a4,10
    80001b42:	00005697          	auipc	a3,0x5
    80001b46:	4be68693          	addi	a3,a3,1214 # 80007000 <_trampoline>
    80001b4a:	6605                	lui	a2,0x1
    80001b4c:	040005b7          	lui	a1,0x4000
    80001b50:	15fd                	addi	a1,a1,-1
    80001b52:	05b2                	slli	a1,a1,0xc
    80001b54:	fffff097          	auipc	ra,0xfffff
    80001b58:	5fe080e7          	jalr	1534(ra) # 80001152 <mappages>
    80001b5c:	02054863          	bltz	a0,80001b8c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b60:	4719                	li	a4,6
    80001b62:	05893683          	ld	a3,88(s2)
    80001b66:	6605                	lui	a2,0x1
    80001b68:	020005b7          	lui	a1,0x2000
    80001b6c:	15fd                	addi	a1,a1,-1
    80001b6e:	05b6                	slli	a1,a1,0xd
    80001b70:	8526                	mv	a0,s1
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	5e0080e7          	jalr	1504(ra) # 80001152 <mappages>
    80001b7a:	02054163          	bltz	a0,80001b9c <proc_pagetable+0x76>
}
    80001b7e:	8526                	mv	a0,s1
    80001b80:	60e2                	ld	ra,24(sp)
    80001b82:	6442                	ld	s0,16(sp)
    80001b84:	64a2                	ld	s1,8(sp)
    80001b86:	6902                	ld	s2,0(sp)
    80001b88:	6105                	addi	sp,sp,32
    80001b8a:	8082                	ret
    uvmfree(pagetable, 0);
    80001b8c:	4581                	li	a1,0
    80001b8e:	8526                	mv	a0,s1
    80001b90:	00000097          	auipc	ra,0x0
    80001b94:	aa4080e7          	jalr	-1372(ra) # 80001634 <uvmfree>
    return 0;
    80001b98:	4481                	li	s1,0
    80001b9a:	b7d5                	j	80001b7e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b9c:	4681                	li	a3,0
    80001b9e:	4605                	li	a2,1
    80001ba0:	040005b7          	lui	a1,0x4000
    80001ba4:	15fd                	addi	a1,a1,-1
    80001ba6:	05b2                	slli	a1,a1,0xc
    80001ba8:	8526                	mv	a0,s1
    80001baa:	fffff097          	auipc	ra,0xfffff
    80001bae:	7e8080e7          	jalr	2024(ra) # 80001392 <uvmunmap>
    uvmfree(pagetable, 0);
    80001bb2:	4581                	li	a1,0
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	00000097          	auipc	ra,0x0
    80001bba:	a7e080e7          	jalr	-1410(ra) # 80001634 <uvmfree>
    return 0;
    80001bbe:	4481                	li	s1,0
    80001bc0:	bf7d                	j	80001b7e <proc_pagetable+0x58>

0000000080001bc2 <proc_freepagetable>:
{
    80001bc2:	1101                	addi	sp,sp,-32
    80001bc4:	ec06                	sd	ra,24(sp)
    80001bc6:	e822                	sd	s0,16(sp)
    80001bc8:	e426                	sd	s1,8(sp)
    80001bca:	e04a                	sd	s2,0(sp)
    80001bcc:	1000                	addi	s0,sp,32
    80001bce:	84aa                	mv	s1,a0
    80001bd0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bd2:	4681                	li	a3,0
    80001bd4:	4605                	li	a2,1
    80001bd6:	040005b7          	lui	a1,0x4000
    80001bda:	15fd                	addi	a1,a1,-1
    80001bdc:	05b2                	slli	a1,a1,0xc
    80001bde:	fffff097          	auipc	ra,0xfffff
    80001be2:	7b4080e7          	jalr	1972(ra) # 80001392 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001be6:	4681                	li	a3,0
    80001be8:	4605                	li	a2,1
    80001bea:	020005b7          	lui	a1,0x2000
    80001bee:	15fd                	addi	a1,a1,-1
    80001bf0:	05b6                	slli	a1,a1,0xd
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	fffff097          	auipc	ra,0xfffff
    80001bf8:	79e080e7          	jalr	1950(ra) # 80001392 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bfc:	85ca                	mv	a1,s2
    80001bfe:	8526                	mv	a0,s1
    80001c00:	00000097          	auipc	ra,0x0
    80001c04:	a34080e7          	jalr	-1484(ra) # 80001634 <uvmfree>
}
    80001c08:	60e2                	ld	ra,24(sp)
    80001c0a:	6442                	ld	s0,16(sp)
    80001c0c:	64a2                	ld	s1,8(sp)
    80001c0e:	6902                	ld	s2,0(sp)
    80001c10:	6105                	addi	sp,sp,32
    80001c12:	8082                	ret

0000000080001c14 <freeproc>:
{
    80001c14:	1101                	addi	sp,sp,-32
    80001c16:	ec06                	sd	ra,24(sp)
    80001c18:	e822                	sd	s0,16(sp)
    80001c1a:	e426                	sd	s1,8(sp)
    80001c1c:	1000                	addi	s0,sp,32
    80001c1e:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c20:	6d28                	ld	a0,88(a0)
    80001c22:	c509                	beqz	a0,80001c2c <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c24:	fffff097          	auipc	ra,0xfffff
    80001c28:	e5a080e7          	jalr	-422(ra) # 80000a7e <kfree>
  if(p->trapframeSave)
    80001c2c:	1804b503          	ld	a0,384(s1)
    80001c30:	c509                	beqz	a0,80001c3a <freeproc+0x26>
    kfree((void*)p->trapframeSave);
    80001c32:	fffff097          	auipc	ra,0xfffff
    80001c36:	e4c080e7          	jalr	-436(ra) # 80000a7e <kfree>
  p->trapframe = 0;
    80001c3a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c3e:	68a8                	ld	a0,80(s1)
    80001c40:	c511                	beqz	a0,80001c4c <freeproc+0x38>
    proc_freepagetable(p->pagetable, p->sz);
    80001c42:	64ac                	ld	a1,72(s1)
    80001c44:	00000097          	auipc	ra,0x0
    80001c48:	f7e080e7          	jalr	-130(ra) # 80001bc2 <proc_freepagetable>
  p->pagetable = 0;
    80001c4c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c50:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c54:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c58:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c5c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c60:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c64:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c68:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c6c:	0004ac23          	sw	zero,24(s1)
}
    80001c70:	60e2                	ld	ra,24(sp)
    80001c72:	6442                	ld	s0,16(sp)
    80001c74:	64a2                	ld	s1,8(sp)
    80001c76:	6105                	addi	sp,sp,32
    80001c78:	8082                	ret

0000000080001c7a <allocproc>:
{
    80001c7a:	1101                	addi	sp,sp,-32
    80001c7c:	ec06                	sd	ra,24(sp)
    80001c7e:	e822                	sd	s0,16(sp)
    80001c80:	e426                	sd	s1,8(sp)
    80001c82:	e04a                	sd	s2,0(sp)
    80001c84:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c86:	00010497          	auipc	s1,0x10
    80001c8a:	0e248493          	addi	s1,s1,226 # 80011d68 <proc>
    80001c8e:	00016917          	auipc	s2,0x16
    80001c92:	4da90913          	addi	s2,s2,1242 # 80018168 <tickslock>
    acquire(&p->lock);
    80001c96:	8526                	mv	a0,s1
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	fd2080e7          	jalr	-46(ra) # 80000c6a <acquire>
    if(p->state == UNUSED) {
    80001ca0:	4c9c                	lw	a5,24(s1)
    80001ca2:	cf81                	beqz	a5,80001cba <allocproc+0x40>
      release(&p->lock);
    80001ca4:	8526                	mv	a0,s1
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	078080e7          	jalr	120(ra) # 80000d1e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cae:	19048493          	addi	s1,s1,400
    80001cb2:	ff2492e3          	bne	s1,s2,80001c96 <allocproc+0x1c>
  return 0;
    80001cb6:	4481                	li	s1,0
    80001cb8:	a08d                	j	80001d1a <allocproc+0xa0>
  p->pid = allocpid();
    80001cba:	00000097          	auipc	ra,0x0
    80001cbe:	e26080e7          	jalr	-474(ra) # 80001ae0 <allocpid>
    80001cc2:	dc88                	sw	a0,56(s1)
  p->spend=0;
    80001cc4:	1604bc23          	sd	zero,376(s1)
  if((p->trapframeSave = (struct trapframe *)kalloc()) == 0){
    80001cc8:	fffff097          	auipc	ra,0xfffff
    80001ccc:	eb2080e7          	jalr	-334(ra) # 80000b7a <kalloc>
    80001cd0:	892a                	mv	s2,a0
    80001cd2:	18a4b023          	sd	a0,384(s1)
    80001cd6:	c929                	beqz	a0,80001d28 <allocproc+0xae>
if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cd8:	fffff097          	auipc	ra,0xfffff
    80001cdc:	ea2080e7          	jalr	-350(ra) # 80000b7a <kalloc>
    80001ce0:	892a                	mv	s2,a0
    80001ce2:	eca8                	sd	a0,88(s1)
    80001ce4:	c929                	beqz	a0,80001d36 <allocproc+0xbc>
  p->pagetable = proc_pagetable(p);
    80001ce6:	8526                	mv	a0,s1
    80001ce8:	00000097          	auipc	ra,0x0
    80001cec:	e3e080e7          	jalr	-450(ra) # 80001b26 <proc_pagetable>
    80001cf0:	892a                	mv	s2,a0
    80001cf2:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cf4:	c921                	beqz	a0,80001d44 <allocproc+0xca>
  memset(&p->context, 0, sizeof(p->context));
    80001cf6:	07000613          	li	a2,112
    80001cfa:	4581                	li	a1,0
    80001cfc:	06048513          	addi	a0,s1,96
    80001d00:	fffff097          	auipc	ra,0xfffff
    80001d04:	066080e7          	jalr	102(ra) # 80000d66 <memset>
  p->context.ra = (uint64)forkret;
    80001d08:	00000797          	auipc	a5,0x0
    80001d0c:	d9278793          	addi	a5,a5,-622 # 80001a9a <forkret>
    80001d10:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d12:	60bc                	ld	a5,64(s1)
    80001d14:	6705                	lui	a4,0x1
    80001d16:	97ba                	add	a5,a5,a4
    80001d18:	f4bc                	sd	a5,104(s1)
}
    80001d1a:	8526                	mv	a0,s1
    80001d1c:	60e2                	ld	ra,24(sp)
    80001d1e:	6442                	ld	s0,16(sp)
    80001d20:	64a2                	ld	s1,8(sp)
    80001d22:	6902                	ld	s2,0(sp)
    80001d24:	6105                	addi	sp,sp,32
    80001d26:	8082                	ret
    release(&p->lock);
    80001d28:	8526                	mv	a0,s1
    80001d2a:	fffff097          	auipc	ra,0xfffff
    80001d2e:	ff4080e7          	jalr	-12(ra) # 80000d1e <release>
    return 0;
    80001d32:	84ca                	mv	s1,s2
    80001d34:	b7dd                	j	80001d1a <allocproc+0xa0>
    release(&p->lock);
    80001d36:	8526                	mv	a0,s1
    80001d38:	fffff097          	auipc	ra,0xfffff
    80001d3c:	fe6080e7          	jalr	-26(ra) # 80000d1e <release>
    return 0;
    80001d40:	84ca                	mv	s1,s2
    80001d42:	bfe1                	j	80001d1a <allocproc+0xa0>
    freeproc(p);
    80001d44:	8526                	mv	a0,s1
    80001d46:	00000097          	auipc	ra,0x0
    80001d4a:	ece080e7          	jalr	-306(ra) # 80001c14 <freeproc>
    release(&p->lock);
    80001d4e:	8526                	mv	a0,s1
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	fce080e7          	jalr	-50(ra) # 80000d1e <release>
    return 0;
    80001d58:	84ca                	mv	s1,s2
    80001d5a:	b7c1                	j	80001d1a <allocproc+0xa0>

0000000080001d5c <userinit>:
{
    80001d5c:	1101                	addi	sp,sp,-32
    80001d5e:	ec06                	sd	ra,24(sp)
    80001d60:	e822                	sd	s0,16(sp)
    80001d62:	e426                	sd	s1,8(sp)
    80001d64:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d66:	00000097          	auipc	ra,0x0
    80001d6a:	f14080e7          	jalr	-236(ra) # 80001c7a <allocproc>
    80001d6e:	84aa                	mv	s1,a0
  initproc = p;
    80001d70:	00007797          	auipc	a5,0x7
    80001d74:	2aa7b423          	sd	a0,680(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d78:	03400613          	li	a2,52
    80001d7c:	00007597          	auipc	a1,0x7
    80001d80:	a6458593          	addi	a1,a1,-1436 # 800087e0 <initcode>
    80001d84:	6928                	ld	a0,80(a0)
    80001d86:	fffff097          	auipc	ra,0xfffff
    80001d8a:	6e0080e7          	jalr	1760(ra) # 80001466 <uvminit>
  p->sz = PGSIZE;
    80001d8e:	6785                	lui	a5,0x1
    80001d90:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d92:	6cb8                	ld	a4,88(s1)
    80001d94:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d98:	6cb8                	ld	a4,88(s1)
    80001d9a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d9c:	4641                	li	a2,16
    80001d9e:	00006597          	auipc	a1,0x6
    80001da2:	3fa58593          	addi	a1,a1,1018 # 80008198 <digits+0x140>
    80001da6:	15848513          	addi	a0,s1,344
    80001daa:	fffff097          	auipc	ra,0xfffff
    80001dae:	10e080e7          	jalr	270(ra) # 80000eb8 <safestrcpy>
  p->cwd = namei("/");
    80001db2:	00006517          	auipc	a0,0x6
    80001db6:	3f650513          	addi	a0,a0,1014 # 800081a8 <digits+0x150>
    80001dba:	00002097          	auipc	ra,0x2
    80001dbe:	2e0080e7          	jalr	736(ra) # 8000409a <namei>
    80001dc2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001dc6:	4789                	li	a5,2
    80001dc8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dca:	8526                	mv	a0,s1
    80001dcc:	fffff097          	auipc	ra,0xfffff
    80001dd0:	f52080e7          	jalr	-174(ra) # 80000d1e <release>
}
    80001dd4:	60e2                	ld	ra,24(sp)
    80001dd6:	6442                	ld	s0,16(sp)
    80001dd8:	64a2                	ld	s1,8(sp)
    80001dda:	6105                	addi	sp,sp,32
    80001ddc:	8082                	ret

0000000080001dde <growproc>:
{
    80001dde:	1101                	addi	sp,sp,-32
    80001de0:	ec06                	sd	ra,24(sp)
    80001de2:	e822                	sd	s0,16(sp)
    80001de4:	e426                	sd	s1,8(sp)
    80001de6:	e04a                	sd	s2,0(sp)
    80001de8:	1000                	addi	s0,sp,32
    80001dea:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dec:	00000097          	auipc	ra,0x0
    80001df0:	c76080e7          	jalr	-906(ra) # 80001a62 <myproc>
    80001df4:	892a                	mv	s2,a0
  sz = p->sz;
    80001df6:	652c                	ld	a1,72(a0)
    80001df8:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001dfc:	00904f63          	bgtz	s1,80001e1a <growproc+0x3c>
  } else if(n < 0){
    80001e00:	0204cc63          	bltz	s1,80001e38 <growproc+0x5a>
  p->sz = sz;
    80001e04:	1602                	slli	a2,a2,0x20
    80001e06:	9201                	srli	a2,a2,0x20
    80001e08:	04c93423          	sd	a2,72(s2)
  return 0;
    80001e0c:	4501                	li	a0,0
}
    80001e0e:	60e2                	ld	ra,24(sp)
    80001e10:	6442                	ld	s0,16(sp)
    80001e12:	64a2                	ld	s1,8(sp)
    80001e14:	6902                	ld	s2,0(sp)
    80001e16:	6105                	addi	sp,sp,32
    80001e18:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e1a:	9e25                	addw	a2,a2,s1
    80001e1c:	1602                	slli	a2,a2,0x20
    80001e1e:	9201                	srli	a2,a2,0x20
    80001e20:	1582                	slli	a1,a1,0x20
    80001e22:	9181                	srli	a1,a1,0x20
    80001e24:	6928                	ld	a0,80(a0)
    80001e26:	fffff097          	auipc	ra,0xfffff
    80001e2a:	6fa080e7          	jalr	1786(ra) # 80001520 <uvmalloc>
    80001e2e:	0005061b          	sext.w	a2,a0
    80001e32:	fa69                	bnez	a2,80001e04 <growproc+0x26>
      return -1;
    80001e34:	557d                	li	a0,-1
    80001e36:	bfe1                	j	80001e0e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e38:	9e25                	addw	a2,a2,s1
    80001e3a:	1602                	slli	a2,a2,0x20
    80001e3c:	9201                	srli	a2,a2,0x20
    80001e3e:	1582                	slli	a1,a1,0x20
    80001e40:	9181                	srli	a1,a1,0x20
    80001e42:	6928                	ld	a0,80(a0)
    80001e44:	fffff097          	auipc	ra,0xfffff
    80001e48:	694080e7          	jalr	1684(ra) # 800014d8 <uvmdealloc>
    80001e4c:	0005061b          	sext.w	a2,a0
    80001e50:	bf55                	j	80001e04 <growproc+0x26>

0000000080001e52 <fork>:
{
    80001e52:	7139                	addi	sp,sp,-64
    80001e54:	fc06                	sd	ra,56(sp)
    80001e56:	f822                	sd	s0,48(sp)
    80001e58:	f426                	sd	s1,40(sp)
    80001e5a:	f04a                	sd	s2,32(sp)
    80001e5c:	ec4e                	sd	s3,24(sp)
    80001e5e:	e852                	sd	s4,16(sp)
    80001e60:	e456                	sd	s5,8(sp)
    80001e62:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e64:	00000097          	auipc	ra,0x0
    80001e68:	bfe080e7          	jalr	-1026(ra) # 80001a62 <myproc>
    80001e6c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e6e:	00000097          	auipc	ra,0x0
    80001e72:	e0c080e7          	jalr	-500(ra) # 80001c7a <allocproc>
    80001e76:	c17d                	beqz	a0,80001f5c <fork+0x10a>
    80001e78:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e7a:	048ab603          	ld	a2,72(s5)
    80001e7e:	692c                	ld	a1,80(a0)
    80001e80:	050ab503          	ld	a0,80(s5)
    80001e84:	fffff097          	auipc	ra,0xfffff
    80001e88:	7e8080e7          	jalr	2024(ra) # 8000166c <uvmcopy>
    80001e8c:	04054a63          	bltz	a0,80001ee0 <fork+0x8e>
  np->sz = p->sz;
    80001e90:	048ab783          	ld	a5,72(s5)
    80001e94:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001e98:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e9c:	058ab683          	ld	a3,88(s5)
    80001ea0:	87b6                	mv	a5,a3
    80001ea2:	058a3703          	ld	a4,88(s4)
    80001ea6:	12068693          	addi	a3,a3,288
    80001eaa:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001eae:	6788                	ld	a0,8(a5)
    80001eb0:	6b8c                	ld	a1,16(a5)
    80001eb2:	6f90                	ld	a2,24(a5)
    80001eb4:	01073023          	sd	a6,0(a4)
    80001eb8:	e708                	sd	a0,8(a4)
    80001eba:	eb0c                	sd	a1,16(a4)
    80001ebc:	ef10                	sd	a2,24(a4)
    80001ebe:	02078793          	addi	a5,a5,32
    80001ec2:	02070713          	addi	a4,a4,32
    80001ec6:	fed792e3          	bne	a5,a3,80001eaa <fork+0x58>
  np->trapframe->a0 = 0;
    80001eca:	058a3783          	ld	a5,88(s4)
    80001ece:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ed2:	0d0a8493          	addi	s1,s5,208
    80001ed6:	0d0a0913          	addi	s2,s4,208
    80001eda:	150a8993          	addi	s3,s5,336
    80001ede:	a00d                	j	80001f00 <fork+0xae>
    freeproc(np);
    80001ee0:	8552                	mv	a0,s4
    80001ee2:	00000097          	auipc	ra,0x0
    80001ee6:	d32080e7          	jalr	-718(ra) # 80001c14 <freeproc>
    release(&np->lock);
    80001eea:	8552                	mv	a0,s4
    80001eec:	fffff097          	auipc	ra,0xfffff
    80001ef0:	e32080e7          	jalr	-462(ra) # 80000d1e <release>
    return -1;
    80001ef4:	54fd                	li	s1,-1
    80001ef6:	a889                	j	80001f48 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001ef8:	04a1                	addi	s1,s1,8
    80001efa:	0921                	addi	s2,s2,8
    80001efc:	01348b63          	beq	s1,s3,80001f12 <fork+0xc0>
    if(p->ofile[i])
    80001f00:	6088                	ld	a0,0(s1)
    80001f02:	d97d                	beqz	a0,80001ef8 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f04:	00003097          	auipc	ra,0x3
    80001f08:	822080e7          	jalr	-2014(ra) # 80004726 <filedup>
    80001f0c:	00a93023          	sd	a0,0(s2)
    80001f10:	b7e5                	j	80001ef8 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001f12:	150ab503          	ld	a0,336(s5)
    80001f16:	00002097          	auipc	ra,0x2
    80001f1a:	996080e7          	jalr	-1642(ra) # 800038ac <idup>
    80001f1e:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f22:	4641                	li	a2,16
    80001f24:	158a8593          	addi	a1,s5,344
    80001f28:	158a0513          	addi	a0,s4,344
    80001f2c:	fffff097          	auipc	ra,0xfffff
    80001f30:	f8c080e7          	jalr	-116(ra) # 80000eb8 <safestrcpy>
  pid = np->pid;
    80001f34:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001f38:	4789                	li	a5,2
    80001f3a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f3e:	8552                	mv	a0,s4
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	dde080e7          	jalr	-546(ra) # 80000d1e <release>
}
    80001f48:	8526                	mv	a0,s1
    80001f4a:	70e2                	ld	ra,56(sp)
    80001f4c:	7442                	ld	s0,48(sp)
    80001f4e:	74a2                	ld	s1,40(sp)
    80001f50:	7902                	ld	s2,32(sp)
    80001f52:	69e2                	ld	s3,24(sp)
    80001f54:	6a42                	ld	s4,16(sp)
    80001f56:	6aa2                	ld	s5,8(sp)
    80001f58:	6121                	addi	sp,sp,64
    80001f5a:	8082                	ret
    return -1;
    80001f5c:	54fd                	li	s1,-1
    80001f5e:	b7ed                	j	80001f48 <fork+0xf6>

0000000080001f60 <reparent>:
{
    80001f60:	7179                	addi	sp,sp,-48
    80001f62:	f406                	sd	ra,40(sp)
    80001f64:	f022                	sd	s0,32(sp)
    80001f66:	ec26                	sd	s1,24(sp)
    80001f68:	e84a                	sd	s2,16(sp)
    80001f6a:	e44e                	sd	s3,8(sp)
    80001f6c:	e052                	sd	s4,0(sp)
    80001f6e:	1800                	addi	s0,sp,48
    80001f70:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f72:	00010497          	auipc	s1,0x10
    80001f76:	df648493          	addi	s1,s1,-522 # 80011d68 <proc>
      pp->parent = initproc;
    80001f7a:	00007a17          	auipc	s4,0x7
    80001f7e:	09ea0a13          	addi	s4,s4,158 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f82:	00016997          	auipc	s3,0x16
    80001f86:	1e698993          	addi	s3,s3,486 # 80018168 <tickslock>
    80001f8a:	a029                	j	80001f94 <reparent+0x34>
    80001f8c:	19048493          	addi	s1,s1,400
    80001f90:	03348363          	beq	s1,s3,80001fb6 <reparent+0x56>
    if(pp->parent == p){
    80001f94:	709c                	ld	a5,32(s1)
    80001f96:	ff279be3          	bne	a5,s2,80001f8c <reparent+0x2c>
      acquire(&pp->lock);
    80001f9a:	8526                	mv	a0,s1
    80001f9c:	fffff097          	auipc	ra,0xfffff
    80001fa0:	cce080e7          	jalr	-818(ra) # 80000c6a <acquire>
      pp->parent = initproc;
    80001fa4:	000a3783          	ld	a5,0(s4)
    80001fa8:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001faa:	8526                	mv	a0,s1
    80001fac:	fffff097          	auipc	ra,0xfffff
    80001fb0:	d72080e7          	jalr	-654(ra) # 80000d1e <release>
    80001fb4:	bfe1                	j	80001f8c <reparent+0x2c>
}
    80001fb6:	70a2                	ld	ra,40(sp)
    80001fb8:	7402                	ld	s0,32(sp)
    80001fba:	64e2                	ld	s1,24(sp)
    80001fbc:	6942                	ld	s2,16(sp)
    80001fbe:	69a2                	ld	s3,8(sp)
    80001fc0:	6a02                	ld	s4,0(sp)
    80001fc2:	6145                	addi	sp,sp,48
    80001fc4:	8082                	ret

0000000080001fc6 <scheduler>:
{
    80001fc6:	715d                	addi	sp,sp,-80
    80001fc8:	e486                	sd	ra,72(sp)
    80001fca:	e0a2                	sd	s0,64(sp)
    80001fcc:	fc26                	sd	s1,56(sp)
    80001fce:	f84a                	sd	s2,48(sp)
    80001fd0:	f44e                	sd	s3,40(sp)
    80001fd2:	f052                	sd	s4,32(sp)
    80001fd4:	ec56                	sd	s5,24(sp)
    80001fd6:	e85a                	sd	s6,16(sp)
    80001fd8:	e45e                	sd	s7,8(sp)
    80001fda:	e062                	sd	s8,0(sp)
    80001fdc:	0880                	addi	s0,sp,80
    80001fde:	8792                	mv	a5,tp
  int id = r_tp();
    80001fe0:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fe2:	00779b13          	slli	s6,a5,0x7
    80001fe6:	00010717          	auipc	a4,0x10
    80001fea:	96a70713          	addi	a4,a4,-1686 # 80011950 <pid_lock>
    80001fee:	975a                	add	a4,a4,s6
    80001ff0:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001ff4:	00010717          	auipc	a4,0x10
    80001ff8:	97c70713          	addi	a4,a4,-1668 # 80011970 <cpus+0x8>
    80001ffc:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001ffe:	4c0d                	li	s8,3
        c->proc = p;
    80002000:	079e                	slli	a5,a5,0x7
    80002002:	00010a17          	auipc	s4,0x10
    80002006:	94ea0a13          	addi	s4,s4,-1714 # 80011950 <pid_lock>
    8000200a:	9a3e                	add	s4,s4,a5
        found = 1;
    8000200c:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    8000200e:	00016997          	auipc	s3,0x16
    80002012:	15a98993          	addi	s3,s3,346 # 80018168 <tickslock>
    80002016:	a899                	j	8000206c <scheduler+0xa6>
      release(&p->lock);
    80002018:	8526                	mv	a0,s1
    8000201a:	fffff097          	auipc	ra,0xfffff
    8000201e:	d04080e7          	jalr	-764(ra) # 80000d1e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002022:	19048493          	addi	s1,s1,400
    80002026:	03348963          	beq	s1,s3,80002058 <scheduler+0x92>
      acquire(&p->lock);
    8000202a:	8526                	mv	a0,s1
    8000202c:	fffff097          	auipc	ra,0xfffff
    80002030:	c3e080e7          	jalr	-962(ra) # 80000c6a <acquire>
      if(p->state == RUNNABLE) {
    80002034:	4c9c                	lw	a5,24(s1)
    80002036:	ff2791e3          	bne	a5,s2,80002018 <scheduler+0x52>
        p->state = RUNNING;
    8000203a:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000203e:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80002042:	06048593          	addi	a1,s1,96
    80002046:	855a                	mv	a0,s6
    80002048:	00000097          	auipc	ra,0x0
    8000204c:	60e080e7          	jalr	1550(ra) # 80002656 <swtch>
        c->proc = 0;
    80002050:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80002054:	8ade                	mv	s5,s7
    80002056:	b7c9                	j	80002018 <scheduler+0x52>
    if(found == 0) {
    80002058:	000a9a63          	bnez	s5,8000206c <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000205c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002060:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002064:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002068:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000206c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002070:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002074:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002078:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000207a:	00010497          	auipc	s1,0x10
    8000207e:	cee48493          	addi	s1,s1,-786 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    80002082:	4909                	li	s2,2
    80002084:	b75d                	j	8000202a <scheduler+0x64>

0000000080002086 <sched>:
{
    80002086:	7179                	addi	sp,sp,-48
    80002088:	f406                	sd	ra,40(sp)
    8000208a:	f022                	sd	s0,32(sp)
    8000208c:	ec26                	sd	s1,24(sp)
    8000208e:	e84a                	sd	s2,16(sp)
    80002090:	e44e                	sd	s3,8(sp)
    80002092:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002094:	00000097          	auipc	ra,0x0
    80002098:	9ce080e7          	jalr	-1586(ra) # 80001a62 <myproc>
    8000209c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000209e:	fffff097          	auipc	ra,0xfffff
    800020a2:	b52080e7          	jalr	-1198(ra) # 80000bf0 <holding>
    800020a6:	c93d                	beqz	a0,8000211c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020a8:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020aa:	2781                	sext.w	a5,a5
    800020ac:	079e                	slli	a5,a5,0x7
    800020ae:	00010717          	auipc	a4,0x10
    800020b2:	8a270713          	addi	a4,a4,-1886 # 80011950 <pid_lock>
    800020b6:	97ba                	add	a5,a5,a4
    800020b8:	0907a703          	lw	a4,144(a5)
    800020bc:	4785                	li	a5,1
    800020be:	06f71763          	bne	a4,a5,8000212c <sched+0xa6>
  if(p->state == RUNNING)
    800020c2:	4c98                	lw	a4,24(s1)
    800020c4:	478d                	li	a5,3
    800020c6:	06f70b63          	beq	a4,a5,8000213c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020ca:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020ce:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020d0:	efb5                	bnez	a5,8000214c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020d2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020d4:	00010917          	auipc	s2,0x10
    800020d8:	87c90913          	addi	s2,s2,-1924 # 80011950 <pid_lock>
    800020dc:	2781                	sext.w	a5,a5
    800020de:	079e                	slli	a5,a5,0x7
    800020e0:	97ca                	add	a5,a5,s2
    800020e2:	0947a983          	lw	s3,148(a5)
    800020e6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020e8:	2781                	sext.w	a5,a5
    800020ea:	079e                	slli	a5,a5,0x7
    800020ec:	00010597          	auipc	a1,0x10
    800020f0:	88458593          	addi	a1,a1,-1916 # 80011970 <cpus+0x8>
    800020f4:	95be                	add	a1,a1,a5
    800020f6:	06048513          	addi	a0,s1,96
    800020fa:	00000097          	auipc	ra,0x0
    800020fe:	55c080e7          	jalr	1372(ra) # 80002656 <swtch>
    80002102:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002104:	2781                	sext.w	a5,a5
    80002106:	079e                	slli	a5,a5,0x7
    80002108:	97ca                	add	a5,a5,s2
    8000210a:	0937aa23          	sw	s3,148(a5)
}
    8000210e:	70a2                	ld	ra,40(sp)
    80002110:	7402                	ld	s0,32(sp)
    80002112:	64e2                	ld	s1,24(sp)
    80002114:	6942                	ld	s2,16(sp)
    80002116:	69a2                	ld	s3,8(sp)
    80002118:	6145                	addi	sp,sp,48
    8000211a:	8082                	ret
    panic("sched p->lock");
    8000211c:	00006517          	auipc	a0,0x6
    80002120:	09450513          	addi	a0,a0,148 # 800081b0 <digits+0x158>
    80002124:	ffffe097          	auipc	ra,0xffffe
    80002128:	41e080e7          	jalr	1054(ra) # 80000542 <panic>
    panic("sched locks");
    8000212c:	00006517          	auipc	a0,0x6
    80002130:	09450513          	addi	a0,a0,148 # 800081c0 <digits+0x168>
    80002134:	ffffe097          	auipc	ra,0xffffe
    80002138:	40e080e7          	jalr	1038(ra) # 80000542 <panic>
    panic("sched running");
    8000213c:	00006517          	auipc	a0,0x6
    80002140:	09450513          	addi	a0,a0,148 # 800081d0 <digits+0x178>
    80002144:	ffffe097          	auipc	ra,0xffffe
    80002148:	3fe080e7          	jalr	1022(ra) # 80000542 <panic>
    panic("sched interruptible");
    8000214c:	00006517          	auipc	a0,0x6
    80002150:	09450513          	addi	a0,a0,148 # 800081e0 <digits+0x188>
    80002154:	ffffe097          	auipc	ra,0xffffe
    80002158:	3ee080e7          	jalr	1006(ra) # 80000542 <panic>

000000008000215c <exit>:
{
    8000215c:	7179                	addi	sp,sp,-48
    8000215e:	f406                	sd	ra,40(sp)
    80002160:	f022                	sd	s0,32(sp)
    80002162:	ec26                	sd	s1,24(sp)
    80002164:	e84a                	sd	s2,16(sp)
    80002166:	e44e                	sd	s3,8(sp)
    80002168:	e052                	sd	s4,0(sp)
    8000216a:	1800                	addi	s0,sp,48
    8000216c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000216e:	00000097          	auipc	ra,0x0
    80002172:	8f4080e7          	jalr	-1804(ra) # 80001a62 <myproc>
    80002176:	89aa                	mv	s3,a0
  if(p == initproc)
    80002178:	00007797          	auipc	a5,0x7
    8000217c:	ea07b783          	ld	a5,-352(a5) # 80009018 <initproc>
    80002180:	0d050493          	addi	s1,a0,208
    80002184:	15050913          	addi	s2,a0,336
    80002188:	02a79363          	bne	a5,a0,800021ae <exit+0x52>
    panic("init exiting");
    8000218c:	00006517          	auipc	a0,0x6
    80002190:	06c50513          	addi	a0,a0,108 # 800081f8 <digits+0x1a0>
    80002194:	ffffe097          	auipc	ra,0xffffe
    80002198:	3ae080e7          	jalr	942(ra) # 80000542 <panic>
      fileclose(f);
    8000219c:	00002097          	auipc	ra,0x2
    800021a0:	5dc080e7          	jalr	1500(ra) # 80004778 <fileclose>
      p->ofile[fd] = 0;
    800021a4:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021a8:	04a1                	addi	s1,s1,8
    800021aa:	01248563          	beq	s1,s2,800021b4 <exit+0x58>
    if(p->ofile[fd]){
    800021ae:	6088                	ld	a0,0(s1)
    800021b0:	f575                	bnez	a0,8000219c <exit+0x40>
    800021b2:	bfdd                	j	800021a8 <exit+0x4c>
  begin_op();
    800021b4:	00002097          	auipc	ra,0x2
    800021b8:	0f2080e7          	jalr	242(ra) # 800042a6 <begin_op>
  iput(p->cwd);
    800021bc:	1509b503          	ld	a0,336(s3)
    800021c0:	00002097          	auipc	ra,0x2
    800021c4:	8e4080e7          	jalr	-1820(ra) # 80003aa4 <iput>
  end_op();
    800021c8:	00002097          	auipc	ra,0x2
    800021cc:	15e080e7          	jalr	350(ra) # 80004326 <end_op>
  p->cwd = 0;
    800021d0:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    800021d4:	00007497          	auipc	s1,0x7
    800021d8:	e4448493          	addi	s1,s1,-444 # 80009018 <initproc>
    800021dc:	6088                	ld	a0,0(s1)
    800021de:	fffff097          	auipc	ra,0xfffff
    800021e2:	a8c080e7          	jalr	-1396(ra) # 80000c6a <acquire>
  wakeup1(initproc);
    800021e6:	6088                	ld	a0,0(s1)
    800021e8:	fffff097          	auipc	ra,0xfffff
    800021ec:	73a080e7          	jalr	1850(ra) # 80001922 <wakeup1>
  release(&initproc->lock);
    800021f0:	6088                	ld	a0,0(s1)
    800021f2:	fffff097          	auipc	ra,0xfffff
    800021f6:	b2c080e7          	jalr	-1236(ra) # 80000d1e <release>
  acquire(&p->lock);
    800021fa:	854e                	mv	a0,s3
    800021fc:	fffff097          	auipc	ra,0xfffff
    80002200:	a6e080e7          	jalr	-1426(ra) # 80000c6a <acquire>
  struct proc *original_parent = p->parent;
    80002204:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002208:	854e                	mv	a0,s3
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	b14080e7          	jalr	-1260(ra) # 80000d1e <release>
  acquire(&original_parent->lock);
    80002212:	8526                	mv	a0,s1
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	a56080e7          	jalr	-1450(ra) # 80000c6a <acquire>
  acquire(&p->lock);
    8000221c:	854e                	mv	a0,s3
    8000221e:	fffff097          	auipc	ra,0xfffff
    80002222:	a4c080e7          	jalr	-1460(ra) # 80000c6a <acquire>
  reparent(p);
    80002226:	854e                	mv	a0,s3
    80002228:	00000097          	auipc	ra,0x0
    8000222c:	d38080e7          	jalr	-712(ra) # 80001f60 <reparent>
  wakeup1(original_parent);
    80002230:	8526                	mv	a0,s1
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	6f0080e7          	jalr	1776(ra) # 80001922 <wakeup1>
  p->xstate = status;
    8000223a:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    8000223e:	4791                	li	a5,4
    80002240:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80002244:	8526                	mv	a0,s1
    80002246:	fffff097          	auipc	ra,0xfffff
    8000224a:	ad8080e7          	jalr	-1320(ra) # 80000d1e <release>
  sched();
    8000224e:	00000097          	auipc	ra,0x0
    80002252:	e38080e7          	jalr	-456(ra) # 80002086 <sched>
  panic("zombie exit");
    80002256:	00006517          	auipc	a0,0x6
    8000225a:	fb250513          	addi	a0,a0,-78 # 80008208 <digits+0x1b0>
    8000225e:	ffffe097          	auipc	ra,0xffffe
    80002262:	2e4080e7          	jalr	740(ra) # 80000542 <panic>

0000000080002266 <yield>:
{
    80002266:	1101                	addi	sp,sp,-32
    80002268:	ec06                	sd	ra,24(sp)
    8000226a:	e822                	sd	s0,16(sp)
    8000226c:	e426                	sd	s1,8(sp)
    8000226e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002270:	fffff097          	auipc	ra,0xfffff
    80002274:	7f2080e7          	jalr	2034(ra) # 80001a62 <myproc>
    80002278:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000227a:	fffff097          	auipc	ra,0xfffff
    8000227e:	9f0080e7          	jalr	-1552(ra) # 80000c6a <acquire>
  p->state = RUNNABLE;
    80002282:	4789                	li	a5,2
    80002284:	cc9c                	sw	a5,24(s1)
  sched();
    80002286:	00000097          	auipc	ra,0x0
    8000228a:	e00080e7          	jalr	-512(ra) # 80002086 <sched>
  release(&p->lock);
    8000228e:	8526                	mv	a0,s1
    80002290:	fffff097          	auipc	ra,0xfffff
    80002294:	a8e080e7          	jalr	-1394(ra) # 80000d1e <release>
}
    80002298:	60e2                	ld	ra,24(sp)
    8000229a:	6442                	ld	s0,16(sp)
    8000229c:	64a2                	ld	s1,8(sp)
    8000229e:	6105                	addi	sp,sp,32
    800022a0:	8082                	ret

00000000800022a2 <sleep>:
{
    800022a2:	7179                	addi	sp,sp,-48
    800022a4:	f406                	sd	ra,40(sp)
    800022a6:	f022                	sd	s0,32(sp)
    800022a8:	ec26                	sd	s1,24(sp)
    800022aa:	e84a                	sd	s2,16(sp)
    800022ac:	e44e                	sd	s3,8(sp)
    800022ae:	1800                	addi	s0,sp,48
    800022b0:	89aa                	mv	s3,a0
    800022b2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800022b4:	fffff097          	auipc	ra,0xfffff
    800022b8:	7ae080e7          	jalr	1966(ra) # 80001a62 <myproc>
    800022bc:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800022be:	05250663          	beq	a0,s2,8000230a <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	9a8080e7          	jalr	-1624(ra) # 80000c6a <acquire>
    release(lk);
    800022ca:	854a                	mv	a0,s2
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	a52080e7          	jalr	-1454(ra) # 80000d1e <release>
  p->chan = chan;
    800022d4:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    800022d8:	4785                	li	a5,1
    800022da:	cc9c                	sw	a5,24(s1)
  sched();
    800022dc:	00000097          	auipc	ra,0x0
    800022e0:	daa080e7          	jalr	-598(ra) # 80002086 <sched>
  p->chan = 0;
    800022e4:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	a34080e7          	jalr	-1484(ra) # 80000d1e <release>
    acquire(lk);
    800022f2:	854a                	mv	a0,s2
    800022f4:	fffff097          	auipc	ra,0xfffff
    800022f8:	976080e7          	jalr	-1674(ra) # 80000c6a <acquire>
}
    800022fc:	70a2                	ld	ra,40(sp)
    800022fe:	7402                	ld	s0,32(sp)
    80002300:	64e2                	ld	s1,24(sp)
    80002302:	6942                	ld	s2,16(sp)
    80002304:	69a2                	ld	s3,8(sp)
    80002306:	6145                	addi	sp,sp,48
    80002308:	8082                	ret
  p->chan = chan;
    8000230a:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    8000230e:	4785                	li	a5,1
    80002310:	cd1c                	sw	a5,24(a0)
  sched();
    80002312:	00000097          	auipc	ra,0x0
    80002316:	d74080e7          	jalr	-652(ra) # 80002086 <sched>
  p->chan = 0;
    8000231a:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    8000231e:	bff9                	j	800022fc <sleep+0x5a>

0000000080002320 <wait>:
{
    80002320:	715d                	addi	sp,sp,-80
    80002322:	e486                	sd	ra,72(sp)
    80002324:	e0a2                	sd	s0,64(sp)
    80002326:	fc26                	sd	s1,56(sp)
    80002328:	f84a                	sd	s2,48(sp)
    8000232a:	f44e                	sd	s3,40(sp)
    8000232c:	f052                	sd	s4,32(sp)
    8000232e:	ec56                	sd	s5,24(sp)
    80002330:	e85a                	sd	s6,16(sp)
    80002332:	e45e                	sd	s7,8(sp)
    80002334:	0880                	addi	s0,sp,80
    80002336:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	72a080e7          	jalr	1834(ra) # 80001a62 <myproc>
    80002340:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	928080e7          	jalr	-1752(ra) # 80000c6a <acquire>
    havekids = 0;
    8000234a:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000234c:	4a11                	li	s4,4
        havekids = 1;
    8000234e:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002350:	00016997          	auipc	s3,0x16
    80002354:	e1898993          	addi	s3,s3,-488 # 80018168 <tickslock>
    havekids = 0;
    80002358:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000235a:	00010497          	auipc	s1,0x10
    8000235e:	a0e48493          	addi	s1,s1,-1522 # 80011d68 <proc>
    80002362:	a08d                	j	800023c4 <wait+0xa4>
          pid = np->pid;
    80002364:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002368:	000b0e63          	beqz	s6,80002384 <wait+0x64>
    8000236c:	4691                	li	a3,4
    8000236e:	03448613          	addi	a2,s1,52
    80002372:	85da                	mv	a1,s6
    80002374:	05093503          	ld	a0,80(s2)
    80002378:	fffff097          	auipc	ra,0xfffff
    8000237c:	3dc080e7          	jalr	988(ra) # 80001754 <copyout>
    80002380:	02054263          	bltz	a0,800023a4 <wait+0x84>
          freeproc(np);
    80002384:	8526                	mv	a0,s1
    80002386:	00000097          	auipc	ra,0x0
    8000238a:	88e080e7          	jalr	-1906(ra) # 80001c14 <freeproc>
          release(&np->lock);
    8000238e:	8526                	mv	a0,s1
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	98e080e7          	jalr	-1650(ra) # 80000d1e <release>
          release(&p->lock);
    80002398:	854a                	mv	a0,s2
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	984080e7          	jalr	-1660(ra) # 80000d1e <release>
          return pid;
    800023a2:	a8a9                	j	800023fc <wait+0xdc>
            release(&np->lock);
    800023a4:	8526                	mv	a0,s1
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	978080e7          	jalr	-1672(ra) # 80000d1e <release>
            release(&p->lock);
    800023ae:	854a                	mv	a0,s2
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	96e080e7          	jalr	-1682(ra) # 80000d1e <release>
            return -1;
    800023b8:	59fd                	li	s3,-1
    800023ba:	a089                	j	800023fc <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    800023bc:	19048493          	addi	s1,s1,400
    800023c0:	03348463          	beq	s1,s3,800023e8 <wait+0xc8>
      if(np->parent == p){
    800023c4:	709c                	ld	a5,32(s1)
    800023c6:	ff279be3          	bne	a5,s2,800023bc <wait+0x9c>
        acquire(&np->lock);
    800023ca:	8526                	mv	a0,s1
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	89e080e7          	jalr	-1890(ra) # 80000c6a <acquire>
        if(np->state == ZOMBIE){
    800023d4:	4c9c                	lw	a5,24(s1)
    800023d6:	f94787e3          	beq	a5,s4,80002364 <wait+0x44>
        release(&np->lock);
    800023da:	8526                	mv	a0,s1
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	942080e7          	jalr	-1726(ra) # 80000d1e <release>
        havekids = 1;
    800023e4:	8756                	mv	a4,s5
    800023e6:	bfd9                	j	800023bc <wait+0x9c>
    if(!havekids || p->killed){
    800023e8:	c701                	beqz	a4,800023f0 <wait+0xd0>
    800023ea:	03092783          	lw	a5,48(s2)
    800023ee:	c39d                	beqz	a5,80002414 <wait+0xf4>
      release(&p->lock);
    800023f0:	854a                	mv	a0,s2
    800023f2:	fffff097          	auipc	ra,0xfffff
    800023f6:	92c080e7          	jalr	-1748(ra) # 80000d1e <release>
      return -1;
    800023fa:	59fd                	li	s3,-1
}
    800023fc:	854e                	mv	a0,s3
    800023fe:	60a6                	ld	ra,72(sp)
    80002400:	6406                	ld	s0,64(sp)
    80002402:	74e2                	ld	s1,56(sp)
    80002404:	7942                	ld	s2,48(sp)
    80002406:	79a2                	ld	s3,40(sp)
    80002408:	7a02                	ld	s4,32(sp)
    8000240a:	6ae2                	ld	s5,24(sp)
    8000240c:	6b42                	ld	s6,16(sp)
    8000240e:	6ba2                	ld	s7,8(sp)
    80002410:	6161                	addi	sp,sp,80
    80002412:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002414:	85ca                	mv	a1,s2
    80002416:	854a                	mv	a0,s2
    80002418:	00000097          	auipc	ra,0x0
    8000241c:	e8a080e7          	jalr	-374(ra) # 800022a2 <sleep>
    havekids = 0;
    80002420:	bf25                	j	80002358 <wait+0x38>

0000000080002422 <wakeup>:
{
    80002422:	7139                	addi	sp,sp,-64
    80002424:	fc06                	sd	ra,56(sp)
    80002426:	f822                	sd	s0,48(sp)
    80002428:	f426                	sd	s1,40(sp)
    8000242a:	f04a                	sd	s2,32(sp)
    8000242c:	ec4e                	sd	s3,24(sp)
    8000242e:	e852                	sd	s4,16(sp)
    80002430:	e456                	sd	s5,8(sp)
    80002432:	0080                	addi	s0,sp,64
    80002434:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002436:	00010497          	auipc	s1,0x10
    8000243a:	93248493          	addi	s1,s1,-1742 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    8000243e:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002440:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002442:	00016917          	auipc	s2,0x16
    80002446:	d2690913          	addi	s2,s2,-730 # 80018168 <tickslock>
    8000244a:	a811                	j	8000245e <wakeup+0x3c>
    release(&p->lock);
    8000244c:	8526                	mv	a0,s1
    8000244e:	fffff097          	auipc	ra,0xfffff
    80002452:	8d0080e7          	jalr	-1840(ra) # 80000d1e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002456:	19048493          	addi	s1,s1,400
    8000245a:	03248063          	beq	s1,s2,8000247a <wakeup+0x58>
    acquire(&p->lock);
    8000245e:	8526                	mv	a0,s1
    80002460:	fffff097          	auipc	ra,0xfffff
    80002464:	80a080e7          	jalr	-2038(ra) # 80000c6a <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002468:	4c9c                	lw	a5,24(s1)
    8000246a:	ff3791e3          	bne	a5,s3,8000244c <wakeup+0x2a>
    8000246e:	749c                	ld	a5,40(s1)
    80002470:	fd479ee3          	bne	a5,s4,8000244c <wakeup+0x2a>
      p->state = RUNNABLE;
    80002474:	0154ac23          	sw	s5,24(s1)
    80002478:	bfd1                	j	8000244c <wakeup+0x2a>
}
    8000247a:	70e2                	ld	ra,56(sp)
    8000247c:	7442                	ld	s0,48(sp)
    8000247e:	74a2                	ld	s1,40(sp)
    80002480:	7902                	ld	s2,32(sp)
    80002482:	69e2                	ld	s3,24(sp)
    80002484:	6a42                	ld	s4,16(sp)
    80002486:	6aa2                	ld	s5,8(sp)
    80002488:	6121                	addi	sp,sp,64
    8000248a:	8082                	ret

000000008000248c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000248c:	7179                	addi	sp,sp,-48
    8000248e:	f406                	sd	ra,40(sp)
    80002490:	f022                	sd	s0,32(sp)
    80002492:	ec26                	sd	s1,24(sp)
    80002494:	e84a                	sd	s2,16(sp)
    80002496:	e44e                	sd	s3,8(sp)
    80002498:	1800                	addi	s0,sp,48
    8000249a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000249c:	00010497          	auipc	s1,0x10
    800024a0:	8cc48493          	addi	s1,s1,-1844 # 80011d68 <proc>
    800024a4:	00016997          	auipc	s3,0x16
    800024a8:	cc498993          	addi	s3,s3,-828 # 80018168 <tickslock>
    acquire(&p->lock);
    800024ac:	8526                	mv	a0,s1
    800024ae:	ffffe097          	auipc	ra,0xffffe
    800024b2:	7bc080e7          	jalr	1980(ra) # 80000c6a <acquire>
    if(p->pid == pid){
    800024b6:	5c9c                	lw	a5,56(s1)
    800024b8:	01278d63          	beq	a5,s2,800024d2 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024bc:	8526                	mv	a0,s1
    800024be:	fffff097          	auipc	ra,0xfffff
    800024c2:	860080e7          	jalr	-1952(ra) # 80000d1e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024c6:	19048493          	addi	s1,s1,400
    800024ca:	ff3491e3          	bne	s1,s3,800024ac <kill+0x20>
  }
  return -1;
    800024ce:	557d                	li	a0,-1
    800024d0:	a821                	j	800024e8 <kill+0x5c>
      p->killed = 1;
    800024d2:	4785                	li	a5,1
    800024d4:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800024d6:	4c98                	lw	a4,24(s1)
    800024d8:	00f70f63          	beq	a4,a5,800024f6 <kill+0x6a>
      release(&p->lock);
    800024dc:	8526                	mv	a0,s1
    800024de:	fffff097          	auipc	ra,0xfffff
    800024e2:	840080e7          	jalr	-1984(ra) # 80000d1e <release>
      return 0;
    800024e6:	4501                	li	a0,0
}
    800024e8:	70a2                	ld	ra,40(sp)
    800024ea:	7402                	ld	s0,32(sp)
    800024ec:	64e2                	ld	s1,24(sp)
    800024ee:	6942                	ld	s2,16(sp)
    800024f0:	69a2                	ld	s3,8(sp)
    800024f2:	6145                	addi	sp,sp,48
    800024f4:	8082                	ret
        p->state = RUNNABLE;
    800024f6:	4789                	li	a5,2
    800024f8:	cc9c                	sw	a5,24(s1)
    800024fa:	b7cd                	j	800024dc <kill+0x50>

00000000800024fc <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024fc:	7179                	addi	sp,sp,-48
    800024fe:	f406                	sd	ra,40(sp)
    80002500:	f022                	sd	s0,32(sp)
    80002502:	ec26                	sd	s1,24(sp)
    80002504:	e84a                	sd	s2,16(sp)
    80002506:	e44e                	sd	s3,8(sp)
    80002508:	e052                	sd	s4,0(sp)
    8000250a:	1800                	addi	s0,sp,48
    8000250c:	84aa                	mv	s1,a0
    8000250e:	892e                	mv	s2,a1
    80002510:	89b2                	mv	s3,a2
    80002512:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002514:	fffff097          	auipc	ra,0xfffff
    80002518:	54e080e7          	jalr	1358(ra) # 80001a62 <myproc>
  if(user_dst){
    8000251c:	c08d                	beqz	s1,8000253e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000251e:	86d2                	mv	a3,s4
    80002520:	864e                	mv	a2,s3
    80002522:	85ca                	mv	a1,s2
    80002524:	6928                	ld	a0,80(a0)
    80002526:	fffff097          	auipc	ra,0xfffff
    8000252a:	22e080e7          	jalr	558(ra) # 80001754 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000252e:	70a2                	ld	ra,40(sp)
    80002530:	7402                	ld	s0,32(sp)
    80002532:	64e2                	ld	s1,24(sp)
    80002534:	6942                	ld	s2,16(sp)
    80002536:	69a2                	ld	s3,8(sp)
    80002538:	6a02                	ld	s4,0(sp)
    8000253a:	6145                	addi	sp,sp,48
    8000253c:	8082                	ret
    memmove((char *)dst, src, len);
    8000253e:	000a061b          	sext.w	a2,s4
    80002542:	85ce                	mv	a1,s3
    80002544:	854a                	mv	a0,s2
    80002546:	fffff097          	auipc	ra,0xfffff
    8000254a:	87c080e7          	jalr	-1924(ra) # 80000dc2 <memmove>
    return 0;
    8000254e:	8526                	mv	a0,s1
    80002550:	bff9                	j	8000252e <either_copyout+0x32>

0000000080002552 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002552:	7179                	addi	sp,sp,-48
    80002554:	f406                	sd	ra,40(sp)
    80002556:	f022                	sd	s0,32(sp)
    80002558:	ec26                	sd	s1,24(sp)
    8000255a:	e84a                	sd	s2,16(sp)
    8000255c:	e44e                	sd	s3,8(sp)
    8000255e:	e052                	sd	s4,0(sp)
    80002560:	1800                	addi	s0,sp,48
    80002562:	892a                	mv	s2,a0
    80002564:	84ae                	mv	s1,a1
    80002566:	89b2                	mv	s3,a2
    80002568:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000256a:	fffff097          	auipc	ra,0xfffff
    8000256e:	4f8080e7          	jalr	1272(ra) # 80001a62 <myproc>
  if(user_src){
    80002572:	c08d                	beqz	s1,80002594 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002574:	86d2                	mv	a3,s4
    80002576:	864e                	mv	a2,s3
    80002578:	85ca                	mv	a1,s2
    8000257a:	6928                	ld	a0,80(a0)
    8000257c:	fffff097          	auipc	ra,0xfffff
    80002580:	264080e7          	jalr	612(ra) # 800017e0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002584:	70a2                	ld	ra,40(sp)
    80002586:	7402                	ld	s0,32(sp)
    80002588:	64e2                	ld	s1,24(sp)
    8000258a:	6942                	ld	s2,16(sp)
    8000258c:	69a2                	ld	s3,8(sp)
    8000258e:	6a02                	ld	s4,0(sp)
    80002590:	6145                	addi	sp,sp,48
    80002592:	8082                	ret
    memmove(dst, (char*)src, len);
    80002594:	000a061b          	sext.w	a2,s4
    80002598:	85ce                	mv	a1,s3
    8000259a:	854a                	mv	a0,s2
    8000259c:	fffff097          	auipc	ra,0xfffff
    800025a0:	826080e7          	jalr	-2010(ra) # 80000dc2 <memmove>
    return 0;
    800025a4:	8526                	mv	a0,s1
    800025a6:	bff9                	j	80002584 <either_copyin+0x32>

00000000800025a8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025a8:	715d                	addi	sp,sp,-80
    800025aa:	e486                	sd	ra,72(sp)
    800025ac:	e0a2                	sd	s0,64(sp)
    800025ae:	fc26                	sd	s1,56(sp)
    800025b0:	f84a                	sd	s2,48(sp)
    800025b2:	f44e                	sd	s3,40(sp)
    800025b4:	f052                	sd	s4,32(sp)
    800025b6:	ec56                	sd	s5,24(sp)
    800025b8:	e85a                	sd	s6,16(sp)
    800025ba:	e45e                	sd	s7,8(sp)
    800025bc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025be:	00006517          	auipc	a0,0x6
    800025c2:	b2250513          	addi	a0,a0,-1246 # 800080e0 <digits+0x88>
    800025c6:	ffffe097          	auipc	ra,0xffffe
    800025ca:	fc6080e7          	jalr	-58(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025ce:	00010497          	auipc	s1,0x10
    800025d2:	8f248493          	addi	s1,s1,-1806 # 80011ec0 <proc+0x158>
    800025d6:	00016917          	auipc	s2,0x16
    800025da:	cea90913          	addi	s2,s2,-790 # 800182c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025de:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800025e0:	00006997          	auipc	s3,0x6
    800025e4:	c3898993          	addi	s3,s3,-968 # 80008218 <digits+0x1c0>
    printf("%d %s %s", p->pid, state, p->name);
    800025e8:	00006a97          	auipc	s5,0x6
    800025ec:	c38a8a93          	addi	s5,s5,-968 # 80008220 <digits+0x1c8>
    printf("\n");
    800025f0:	00006a17          	auipc	s4,0x6
    800025f4:	af0a0a13          	addi	s4,s4,-1296 # 800080e0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025f8:	00006b97          	auipc	s7,0x6
    800025fc:	c60b8b93          	addi	s7,s7,-928 # 80008258 <states.0>
    80002600:	a00d                	j	80002622 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002602:	ee06a583          	lw	a1,-288(a3)
    80002606:	8556                	mv	a0,s5
    80002608:	ffffe097          	auipc	ra,0xffffe
    8000260c:	f84080e7          	jalr	-124(ra) # 8000058c <printf>
    printf("\n");
    80002610:	8552                	mv	a0,s4
    80002612:	ffffe097          	auipc	ra,0xffffe
    80002616:	f7a080e7          	jalr	-134(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000261a:	19048493          	addi	s1,s1,400
    8000261e:	03248163          	beq	s1,s2,80002640 <procdump+0x98>
    if(p->state == UNUSED)
    80002622:	86a6                	mv	a3,s1
    80002624:	ec04a783          	lw	a5,-320(s1)
    80002628:	dbed                	beqz	a5,8000261a <procdump+0x72>
      state = "???";
    8000262a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000262c:	fcfb6be3          	bltu	s6,a5,80002602 <procdump+0x5a>
    80002630:	1782                	slli	a5,a5,0x20
    80002632:	9381                	srli	a5,a5,0x20
    80002634:	078e                	slli	a5,a5,0x3
    80002636:	97de                	add	a5,a5,s7
    80002638:	6390                	ld	a2,0(a5)
    8000263a:	f661                	bnez	a2,80002602 <procdump+0x5a>
      state = "???";
    8000263c:	864e                	mv	a2,s3
    8000263e:	b7d1                	j	80002602 <procdump+0x5a>
  }
}
    80002640:	60a6                	ld	ra,72(sp)
    80002642:	6406                	ld	s0,64(sp)
    80002644:	74e2                	ld	s1,56(sp)
    80002646:	7942                	ld	s2,48(sp)
    80002648:	79a2                	ld	s3,40(sp)
    8000264a:	7a02                	ld	s4,32(sp)
    8000264c:	6ae2                	ld	s5,24(sp)
    8000264e:	6b42                	ld	s6,16(sp)
    80002650:	6ba2                	ld	s7,8(sp)
    80002652:	6161                	addi	sp,sp,80
    80002654:	8082                	ret

0000000080002656 <swtch>:
    80002656:	00153023          	sd	ra,0(a0)
    8000265a:	00253423          	sd	sp,8(a0)
    8000265e:	e900                	sd	s0,16(a0)
    80002660:	ed04                	sd	s1,24(a0)
    80002662:	03253023          	sd	s2,32(a0)
    80002666:	03353423          	sd	s3,40(a0)
    8000266a:	03453823          	sd	s4,48(a0)
    8000266e:	03553c23          	sd	s5,56(a0)
    80002672:	05653023          	sd	s6,64(a0)
    80002676:	05753423          	sd	s7,72(a0)
    8000267a:	05853823          	sd	s8,80(a0)
    8000267e:	05953c23          	sd	s9,88(a0)
    80002682:	07a53023          	sd	s10,96(a0)
    80002686:	07b53423          	sd	s11,104(a0)
    8000268a:	0005b083          	ld	ra,0(a1)
    8000268e:	0085b103          	ld	sp,8(a1)
    80002692:	6980                	ld	s0,16(a1)
    80002694:	6d84                	ld	s1,24(a1)
    80002696:	0205b903          	ld	s2,32(a1)
    8000269a:	0285b983          	ld	s3,40(a1)
    8000269e:	0305ba03          	ld	s4,48(a1)
    800026a2:	0385ba83          	ld	s5,56(a1)
    800026a6:	0405bb03          	ld	s6,64(a1)
    800026aa:	0485bb83          	ld	s7,72(a1)
    800026ae:	0505bc03          	ld	s8,80(a1)
    800026b2:	0585bc83          	ld	s9,88(a1)
    800026b6:	0605bd03          	ld	s10,96(a1)
    800026ba:	0685bd83          	ld	s11,104(a1)
    800026be:	8082                	ret

00000000800026c0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026c0:	1141                	addi	sp,sp,-16
    800026c2:	e406                	sd	ra,8(sp)
    800026c4:	e022                	sd	s0,0(sp)
    800026c6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026c8:	00006597          	auipc	a1,0x6
    800026cc:	bb858593          	addi	a1,a1,-1096 # 80008280 <states.0+0x28>
    800026d0:	00016517          	auipc	a0,0x16
    800026d4:	a9850513          	addi	a0,a0,-1384 # 80018168 <tickslock>
    800026d8:	ffffe097          	auipc	ra,0xffffe
    800026dc:	502080e7          	jalr	1282(ra) # 80000bda <initlock>
}
    800026e0:	60a2                	ld	ra,8(sp)
    800026e2:	6402                	ld	s0,0(sp)
    800026e4:	0141                	addi	sp,sp,16
    800026e6:	8082                	ret

00000000800026e8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026e8:	1141                	addi	sp,sp,-16
    800026ea:	e422                	sd	s0,8(sp)
    800026ec:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026ee:	00003797          	auipc	a5,0x3
    800026f2:	6e278793          	addi	a5,a5,1762 # 80005dd0 <kernelvec>
    800026f6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026fa:	6422                	ld	s0,8(sp)
    800026fc:	0141                	addi	sp,sp,16
    800026fe:	8082                	ret

0000000080002700 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002700:	1141                	addi	sp,sp,-16
    80002702:	e406                	sd	ra,8(sp)
    80002704:	e022                	sd	s0,0(sp)
    80002706:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002708:	fffff097          	auipc	ra,0xfffff
    8000270c:	35a080e7          	jalr	858(ra) # 80001a62 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002710:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002714:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002716:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000271a:	00005617          	auipc	a2,0x5
    8000271e:	8e660613          	addi	a2,a2,-1818 # 80007000 <_trampoline>
    80002722:	00005697          	auipc	a3,0x5
    80002726:	8de68693          	addi	a3,a3,-1826 # 80007000 <_trampoline>
    8000272a:	8e91                	sub	a3,a3,a2
    8000272c:	040007b7          	lui	a5,0x4000
    80002730:	17fd                	addi	a5,a5,-1
    80002732:	07b2                	slli	a5,a5,0xc
    80002734:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002736:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000273a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000273c:	180026f3          	csrr	a3,satp
    80002740:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002742:	6d38                	ld	a4,88(a0)
    80002744:	6134                	ld	a3,64(a0)
    80002746:	6585                	lui	a1,0x1
    80002748:	96ae                	add	a3,a3,a1
    8000274a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000274c:	6d38                	ld	a4,88(a0)
    8000274e:	00000697          	auipc	a3,0x0
    80002752:	2ac68693          	addi	a3,a3,684 # 800029fa <usertrap>
    80002756:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002758:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000275a:	8692                	mv	a3,tp
    8000275c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000275e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002762:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002766:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000276a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000276e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002770:	6f18                	ld	a4,24(a4)
    80002772:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002776:	692c                	ld	a1,80(a0)
    80002778:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000277a:	00005717          	auipc	a4,0x5
    8000277e:	91670713          	addi	a4,a4,-1770 # 80007090 <userret>
    80002782:	8f11                	sub	a4,a4,a2
    80002784:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002786:	577d                	li	a4,-1
    80002788:	177e                	slli	a4,a4,0x3f
    8000278a:	8dd9                	or	a1,a1,a4
    8000278c:	02000537          	lui	a0,0x2000
    80002790:	157d                	addi	a0,a0,-1
    80002792:	0536                	slli	a0,a0,0xd
    80002794:	9782                	jalr	a5
}
    80002796:	60a2                	ld	ra,8(sp)
    80002798:	6402                	ld	s0,0(sp)
    8000279a:	0141                	addi	sp,sp,16
    8000279c:	8082                	ret

000000008000279e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000279e:	1101                	addi	sp,sp,-32
    800027a0:	ec06                	sd	ra,24(sp)
    800027a2:	e822                	sd	s0,16(sp)
    800027a4:	e426                	sd	s1,8(sp)
    800027a6:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800027a8:	00016497          	auipc	s1,0x16
    800027ac:	9c048493          	addi	s1,s1,-1600 # 80018168 <tickslock>
    800027b0:	8526                	mv	a0,s1
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	4b8080e7          	jalr	1208(ra) # 80000c6a <acquire>
  ticks++;
    800027ba:	00007517          	auipc	a0,0x7
    800027be:	86650513          	addi	a0,a0,-1946 # 80009020 <ticks>
    800027c2:	411c                	lw	a5,0(a0)
    800027c4:	2785                	addiw	a5,a5,1
    800027c6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027c8:	00000097          	auipc	ra,0x0
    800027cc:	c5a080e7          	jalr	-934(ra) # 80002422 <wakeup>
  release(&tickslock);
    800027d0:	8526                	mv	a0,s1
    800027d2:	ffffe097          	auipc	ra,0xffffe
    800027d6:	54c080e7          	jalr	1356(ra) # 80000d1e <release>
}
    800027da:	60e2                	ld	ra,24(sp)
    800027dc:	6442                	ld	s0,16(sp)
    800027de:	64a2                	ld	s1,8(sp)
    800027e0:	6105                	addi	sp,sp,32
    800027e2:	8082                	ret

00000000800027e4 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027e4:	1101                	addi	sp,sp,-32
    800027e6:	ec06                	sd	ra,24(sp)
    800027e8:	e822                	sd	s0,16(sp)
    800027ea:	e426                	sd	s1,8(sp)
    800027ec:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027ee:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027f2:	00074d63          	bltz	a4,8000280c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027f6:	57fd                	li	a5,-1
    800027f8:	17fe                	slli	a5,a5,0x3f
    800027fa:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027fc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027fe:	06f70363          	beq	a4,a5,80002864 <devintr+0x80>
  }
}
    80002802:	60e2                	ld	ra,24(sp)
    80002804:	6442                	ld	s0,16(sp)
    80002806:	64a2                	ld	s1,8(sp)
    80002808:	6105                	addi	sp,sp,32
    8000280a:	8082                	ret
     (scause & 0xff) == 9){
    8000280c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002810:	46a5                	li	a3,9
    80002812:	fed792e3          	bne	a5,a3,800027f6 <devintr+0x12>
    int irq = plic_claim();
    80002816:	00003097          	auipc	ra,0x3
    8000281a:	6c2080e7          	jalr	1730(ra) # 80005ed8 <plic_claim>
    8000281e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002820:	47a9                	li	a5,10
    80002822:	02f50763          	beq	a0,a5,80002850 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002826:	4785                	li	a5,1
    80002828:	02f50963          	beq	a0,a5,8000285a <devintr+0x76>
    return 1;
    8000282c:	4505                	li	a0,1
    } else if(irq){
    8000282e:	d8f1                	beqz	s1,80002802 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002830:	85a6                	mv	a1,s1
    80002832:	00006517          	auipc	a0,0x6
    80002836:	a5650513          	addi	a0,a0,-1450 # 80008288 <states.0+0x30>
    8000283a:	ffffe097          	auipc	ra,0xffffe
    8000283e:	d52080e7          	jalr	-686(ra) # 8000058c <printf>
      plic_complete(irq);
    80002842:	8526                	mv	a0,s1
    80002844:	00003097          	auipc	ra,0x3
    80002848:	6b8080e7          	jalr	1720(ra) # 80005efc <plic_complete>
    return 1;
    8000284c:	4505                	li	a0,1
    8000284e:	bf55                	j	80002802 <devintr+0x1e>
      uartintr();
    80002850:	ffffe097          	auipc	ra,0xffffe
    80002854:	1de080e7          	jalr	478(ra) # 80000a2e <uartintr>
    80002858:	b7ed                	j	80002842 <devintr+0x5e>
      virtio_disk_intr();
    8000285a:	00004097          	auipc	ra,0x4
    8000285e:	b1c080e7          	jalr	-1252(ra) # 80006376 <virtio_disk_intr>
    80002862:	b7c5                	j	80002842 <devintr+0x5e>
    if(cpuid() == 0){
    80002864:	fffff097          	auipc	ra,0xfffff
    80002868:	1d2080e7          	jalr	466(ra) # 80001a36 <cpuid>
    8000286c:	c901                	beqz	a0,8000287c <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000286e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002872:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002874:	14479073          	csrw	sip,a5
    return 2;
    80002878:	4509                	li	a0,2
    8000287a:	b761                	j	80002802 <devintr+0x1e>
      clockintr();
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	f22080e7          	jalr	-222(ra) # 8000279e <clockintr>
    80002884:	b7ed                	j	8000286e <devintr+0x8a>

0000000080002886 <kerneltrap>:
{
    80002886:	7179                	addi	sp,sp,-48
    80002888:	f406                	sd	ra,40(sp)
    8000288a:	f022                	sd	s0,32(sp)
    8000288c:	ec26                	sd	s1,24(sp)
    8000288e:	e84a                	sd	s2,16(sp)
    80002890:	e44e                	sd	s3,8(sp)
    80002892:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002894:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002898:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000289c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028a0:	1004f793          	andi	a5,s1,256
    800028a4:	cb85                	beqz	a5,800028d4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028a6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028aa:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028ac:	ef85                	bnez	a5,800028e4 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800028ae:	00000097          	auipc	ra,0x0
    800028b2:	f36080e7          	jalr	-202(ra) # 800027e4 <devintr>
    800028b6:	cd1d                	beqz	a0,800028f4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800028b8:	4789                	li	a5,2
    800028ba:	06f50a63          	beq	a0,a5,8000292e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028be:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028c2:	10049073          	csrw	sstatus,s1
}
    800028c6:	70a2                	ld	ra,40(sp)
    800028c8:	7402                	ld	s0,32(sp)
    800028ca:	64e2                	ld	s1,24(sp)
    800028cc:	6942                	ld	s2,16(sp)
    800028ce:	69a2                	ld	s3,8(sp)
    800028d0:	6145                	addi	sp,sp,48
    800028d2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028d4:	00006517          	auipc	a0,0x6
    800028d8:	9d450513          	addi	a0,a0,-1580 # 800082a8 <states.0+0x50>
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	c66080e7          	jalr	-922(ra) # 80000542 <panic>
    panic("kerneltrap: interrupts enabled");
    800028e4:	00006517          	auipc	a0,0x6
    800028e8:	9ec50513          	addi	a0,a0,-1556 # 800082d0 <states.0+0x78>
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	c56080e7          	jalr	-938(ra) # 80000542 <panic>
    printf("scause %p\n", scause);
    800028f4:	85ce                	mv	a1,s3
    800028f6:	00006517          	auipc	a0,0x6
    800028fa:	9fa50513          	addi	a0,a0,-1542 # 800082f0 <states.0+0x98>
    800028fe:	ffffe097          	auipc	ra,0xffffe
    80002902:	c8e080e7          	jalr	-882(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002906:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000290a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000290e:	00006517          	auipc	a0,0x6
    80002912:	9f250513          	addi	a0,a0,-1550 # 80008300 <states.0+0xa8>
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	c76080e7          	jalr	-906(ra) # 8000058c <printf>
    panic("kerneltrap");
    8000291e:	00006517          	auipc	a0,0x6
    80002922:	9fa50513          	addi	a0,a0,-1542 # 80008318 <states.0+0xc0>
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	c1c080e7          	jalr	-996(ra) # 80000542 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000292e:	fffff097          	auipc	ra,0xfffff
    80002932:	134080e7          	jalr	308(ra) # 80001a62 <myproc>
    80002936:	d541                	beqz	a0,800028be <kerneltrap+0x38>
    80002938:	fffff097          	auipc	ra,0xfffff
    8000293c:	12a080e7          	jalr	298(ra) # 80001a62 <myproc>
    80002940:	4d18                	lw	a4,24(a0)
    80002942:	478d                	li	a5,3
    80002944:	f6f71de3          	bne	a4,a5,800028be <kerneltrap+0x38>
    yield();
    80002948:	00000097          	auipc	ra,0x0
    8000294c:	91e080e7          	jalr	-1762(ra) # 80002266 <yield>
    80002950:	b7bd                	j	800028be <kerneltrap+0x38>

0000000080002952 <switchTrapframe>:
void switchTrapframe(struct trapframe* trapframe,struct trapframe* trapframeSave){
    80002952:	1141                	addi	sp,sp,-16
    80002954:	e422                	sd	s0,8(sp)
    80002956:	0800                	addi	s0,sp,16
trapframe->kernel_satp = trapframeSave ->kernel_satp ;
    80002958:	619c                	ld	a5,0(a1)
    8000295a:	e11c                	sd	a5,0(a0)
trapframe->kernel_sp = trapframeSave ->kernel_sp;
    8000295c:	659c                	ld	a5,8(a1)
    8000295e:	e51c                	sd	a5,8(a0)
trapframe->epc = trapframeSave ->epc;
    80002960:	6d9c                	ld	a5,24(a1)
    80002962:	ed1c                	sd	a5,24(a0)
trapframe->kernel_hartid = trapframeSave->kernel_hartid;
    80002964:	719c                	ld	a5,32(a1)
    80002966:	f11c                	sd	a5,32(a0)
trapframe->ra = trapframeSave->ra;
    80002968:	759c                	ld	a5,40(a1)
    8000296a:	f51c                	sd	a5,40(a0)
trapframe->sp = trapframeSave->sp;
    8000296c:	799c                	ld	a5,48(a1)
    8000296e:	f91c                	sd	a5,48(a0)
trapframe->gp = trapframeSave->gp;
    80002970:	7d9c                	ld	a5,56(a1)
    80002972:	fd1c                	sd	a5,56(a0)
trapframe->tp = trapframeSave->tp;
    80002974:	61bc                	ld	a5,64(a1)
    80002976:	e13c                	sd	a5,64(a0)
trapframe->t0 = trapframeSave->t0;
    80002978:	65bc                	ld	a5,72(a1)
    8000297a:	e53c                	sd	a5,72(a0)
trapframe->t1 = trapframeSave->t1;
    8000297c:	69bc                	ld	a5,80(a1)
    8000297e:	e93c                	sd	a5,80(a0)
trapframe->t2 = trapframeSave->t2;
    80002980:	6dbc                	ld	a5,88(a1)
    80002982:	ed3c                	sd	a5,88(a0)
trapframe->s0 = trapframeSave->s0;
    80002984:	71bc                	ld	a5,96(a1)
    80002986:	f13c                	sd	a5,96(a0)
trapframe->s1 = trapframeSave->s1;
    80002988:	75bc                	ld	a5,104(a1)
    8000298a:	f53c                	sd	a5,104(a0)
trapframe->a0 = trapframeSave->a0;
    8000298c:	79bc                	ld	a5,112(a1)
    8000298e:	f93c                	sd	a5,112(a0)
trapframe->a1 = trapframeSave->a1;
    80002990:	7dbc                	ld	a5,120(a1)
    80002992:	fd3c                	sd	a5,120(a0)
trapframe->a2 = trapframeSave->a2;
    80002994:	61dc                	ld	a5,128(a1)
    80002996:	e15c                	sd	a5,128(a0)
trapframe->a3 = trapframeSave->a3;
    80002998:	65dc                	ld	a5,136(a1)
    8000299a:	e55c                	sd	a5,136(a0)
trapframe->a4 = trapframeSave->a4;
    8000299c:	69dc                	ld	a5,144(a1)
    8000299e:	e95c                	sd	a5,144(a0)
trapframe->a5 = trapframeSave->a5;
    800029a0:	6ddc                	ld	a5,152(a1)
    800029a2:	ed5c                	sd	a5,152(a0)
trapframe->a6 = trapframeSave->a6;
    800029a4:	71dc                	ld	a5,160(a1)
    800029a6:	f15c                	sd	a5,160(a0)
trapframe->a7 = trapframeSave->a7;
    800029a8:	75dc                	ld	a5,168(a1)
    800029aa:	f55c                	sd	a5,168(a0)
trapframe->s2 = trapframeSave->s2;
    800029ac:	79dc                	ld	a5,176(a1)
    800029ae:	f95c                	sd	a5,176(a0)
trapframe->s3 = trapframeSave->s3;
    800029b0:	7ddc                	ld	a5,184(a1)
    800029b2:	fd5c                	sd	a5,184(a0)
trapframe->s4 = trapframeSave->s4;
    800029b4:	61fc                	ld	a5,192(a1)
    800029b6:	e17c                	sd	a5,192(a0)
trapframe->s5 = trapframeSave->s5;
    800029b8:	65fc                	ld	a5,200(a1)
    800029ba:	e57c                	sd	a5,200(a0)
trapframe->s6 = trapframeSave->s6;
    800029bc:	69fc                	ld	a5,208(a1)
    800029be:	e97c                	sd	a5,208(a0)
trapframe->s7 = trapframeSave->s7;
    800029c0:	6dfc                	ld	a5,216(a1)
    800029c2:	ed7c                	sd	a5,216(a0)
trapframe->s8 = trapframeSave->s8;
    800029c4:	71fc                	ld	a5,224(a1)
    800029c6:	f17c                	sd	a5,224(a0)
trapframe->s9 = trapframeSave->s9;
    800029c8:	75fc                	ld	a5,232(a1)
    800029ca:	f57c                	sd	a5,232(a0)
trapframe->s10 =trapframeSave->s10;
    800029cc:	79fc                	ld	a5,240(a1)
    800029ce:	f97c                	sd	a5,240(a0)
trapframe->s11 =trapframeSave->s11;
    800029d0:	7dfc                	ld	a5,248(a1)
    800029d2:	fd7c                	sd	a5,248(a0)
trapframe->t3 = trapframeSave->t3;
    800029d4:	1005b783          	ld	a5,256(a1) # 1100 <_entry-0x7fffef00>
    800029d8:	10f53023          	sd	a5,256(a0)
trapframe->t4 = trapframeSave->t4;
    800029dc:	1085b783          	ld	a5,264(a1)
    800029e0:	10f53423          	sd	a5,264(a0)
trapframe->t5 = trapframeSave->t5;
    800029e4:	1105b783          	ld	a5,272(a1)
    800029e8:	10f53823          	sd	a5,272(a0)
trapframe->t6 = trapframeSave->t6;
    800029ec:	1185b783          	ld	a5,280(a1)
    800029f0:	10f53c23          	sd	a5,280(a0)
}
    800029f4:	6422                	ld	s0,8(sp)
    800029f6:	0141                	addi	sp,sp,16
    800029f8:	8082                	ret

00000000800029fa <usertrap>:
{
    800029fa:	7179                	addi	sp,sp,-48
    800029fc:	f406                	sd	ra,40(sp)
    800029fe:	f022                	sd	s0,32(sp)
    80002a00:	ec26                	sd	s1,24(sp)
    80002a02:	e84a                	sd	s2,16(sp)
    80002a04:	e44e                	sd	s3,8(sp)
    80002a06:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a08:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a0c:	1007f793          	andi	a5,a5,256
    80002a10:	e7a5                	bnez	a5,80002a78 <usertrap+0x7e>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a12:	00003797          	auipc	a5,0x3
    80002a16:	3be78793          	addi	a5,a5,958 # 80005dd0 <kernelvec>
    80002a1a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a1e:	fffff097          	auipc	ra,0xfffff
    80002a22:	044080e7          	jalr	68(ra) # 80001a62 <myproc>
    80002a26:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a28:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a2a:	14102773          	csrr	a4,sepc
    80002a2e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a30:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a34:	47a1                	li	a5,8
    80002a36:	04f71f63          	bne	a4,a5,80002a94 <usertrap+0x9a>
    if(p->killed)
    80002a3a:	591c                	lw	a5,48(a0)
    80002a3c:	e7b1                	bnez	a5,80002a88 <usertrap+0x8e>
    p->trapframe->epc += 4;
    80002a3e:	6cb8                	ld	a4,88(s1)
    80002a40:	6f1c                	ld	a5,24(a4)
    80002a42:	0791                	addi	a5,a5,4
    80002a44:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a46:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a4a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a4e:	10079073          	csrw	sstatus,a5
    syscall();
    80002a52:	00000097          	auipc	ra,0x0
    80002a56:	2f4080e7          	jalr	756(ra) # 80002d46 <syscall>
  int which_dev = 0;
    80002a5a:	4901                	li	s2,0
  if(p->killed)
    80002a5c:	589c                	lw	a5,48(s1)
    80002a5e:	14079c63          	bnez	a5,80002bb6 <usertrap+0x1bc>
  usertrapret();
    80002a62:	00000097          	auipc	ra,0x0
    80002a66:	c9e080e7          	jalr	-866(ra) # 80002700 <usertrapret>
}
    80002a6a:	70a2                	ld	ra,40(sp)
    80002a6c:	7402                	ld	s0,32(sp)
    80002a6e:	64e2                	ld	s1,24(sp)
    80002a70:	6942                	ld	s2,16(sp)
    80002a72:	69a2                	ld	s3,8(sp)
    80002a74:	6145                	addi	sp,sp,48
    80002a76:	8082                	ret
    panic("usertrap: not from user mode");
    80002a78:	00006517          	auipc	a0,0x6
    80002a7c:	8b050513          	addi	a0,a0,-1872 # 80008328 <states.0+0xd0>
    80002a80:	ffffe097          	auipc	ra,0xffffe
    80002a84:	ac2080e7          	jalr	-1342(ra) # 80000542 <panic>
      exit(-1);
    80002a88:	557d                	li	a0,-1
    80002a8a:	fffff097          	auipc	ra,0xfffff
    80002a8e:	6d2080e7          	jalr	1746(ra) # 8000215c <exit>
    80002a92:	b775                	j	80002a3e <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80002a94:	00000097          	auipc	ra,0x0
    80002a98:	d50080e7          	jalr	-688(ra) # 800027e4 <devintr>
    80002a9c:	892a                	mv	s2,a0
    80002a9e:	c939                	beqz	a0,80002af4 <usertrap+0xfa>
      if(which_dev==2&& p->waitReturn==0){
    80002aa0:	4789                	li	a5,2
    80002aa2:	faf51de3          	bne	a0,a5,80002a5c <usertrap+0x62>
    80002aa6:	1884a783          	lw	a5,392(s1)
    80002aaa:	eb99                	bnez	a5,80002ac0 <usertrap+0xc6>
        if(p->interval!=0){
    80002aac:	1684b783          	ld	a5,360(s1)
    80002ab0:	cb81                	beqz	a5,80002ac0 <usertrap+0xc6>
         p->spend=p->spend+1;
    80002ab2:	1784b703          	ld	a4,376(s1)
    80002ab6:	0705                	addi	a4,a4,1
    80002ab8:	16e4bc23          	sd	a4,376(s1)
         if(p->spend==p->interval){
    80002abc:	00e78b63          	beq	a5,a4,80002ad2 <usertrap+0xd8>
  if(p->killed)
    80002ac0:	589c                	lw	a5,48(s1)
    80002ac2:	10078263          	beqz	a5,80002bc6 <usertrap+0x1cc>
    exit(-1);
    80002ac6:	557d                	li	a0,-1
    80002ac8:	fffff097          	auipc	ra,0xfffff
    80002acc:	694080e7          	jalr	1684(ra) # 8000215c <exit>
  if(which_dev == 2)
    80002ad0:	a8dd                	j	80002bc6 <usertrap+0x1cc>
          switchTrapframe(p->trapframeSave,p->trapframe);
    80002ad2:	6cac                	ld	a1,88(s1)
    80002ad4:	1804b503          	ld	a0,384(s1)
    80002ad8:	00000097          	auipc	ra,0x0
    80002adc:	e7a080e7          	jalr	-390(ra) # 80002952 <switchTrapframe>
          p->spend=0;
    80002ae0:	1604bc23          	sd	zero,376(s1)
          p->trapframe->epc=(uint64)p->handler;
    80002ae4:	6cbc                	ld	a5,88(s1)
    80002ae6:	1704b703          	ld	a4,368(s1)
    80002aea:	ef98                	sd	a4,24(a5)
          p->waitReturn=1;
    80002aec:	4785                	li	a5,1
    80002aee:	18f4a423          	sw	a5,392(s1)
    80002af2:	b7f9                	j	80002ac0 <usertrap+0xc6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002af4:	14202773          	csrr	a4,scause
    else if(r_scause() == 13 || r_scause() == 15) {
    80002af8:	47b5                	li	a5,13
    80002afa:	00f70763          	beq	a4,a5,80002b08 <usertrap+0x10e>
    80002afe:	14202773          	csrr	a4,scause
    80002b02:	47bd                	li	a5,15
    80002b04:	06f71a63          	bne	a4,a5,80002b78 <usertrap+0x17e>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b08:	14302973          	csrr	s2,stval
    uint64 pa = (uint64)kalloc();
    80002b0c:	ffffe097          	auipc	ra,0xffffe
    80002b10:	06e080e7          	jalr	110(ra) # 80000b7a <kalloc>
    80002b14:	89aa                	mv	s3,a0
    if (pa == 0) {
    80002b16:	c115                	beqz	a0,80002b3a <usertrap+0x140>
    } else if (va >= p->sz || va <= PGROUNDDOWN(p->trapframe->sp)) {
    80002b18:	64bc                	ld	a5,72(s1)
    80002b1a:	00f97863          	bgeu	s2,a5,80002b2a <usertrap+0x130>
    80002b1e:	6cbc                	ld	a5,88(s1)
    80002b20:	7b98                	ld	a4,48(a5)
    80002b22:	77fd                	lui	a5,0xfffff
    80002b24:	8ff9                	and	a5,a5,a4
    80002b26:	0127ed63          	bltu	a5,s2,80002b40 <usertrap+0x146>
      kfree((void*)pa);
    80002b2a:	854e                	mv	a0,s3
    80002b2c:	ffffe097          	auipc	ra,0xffffe
    80002b30:	f52080e7          	jalr	-174(ra) # 80000a7e <kfree>
      p->killed = 1;
    80002b34:	4785                	li	a5,1
    80002b36:	d89c                	sw	a5,48(s1)
    80002b38:	a88d                	j	80002baa <usertrap+0x1b0>
      p->killed = 1;
    80002b3a:	4785                	li	a5,1
    80002b3c:	d89c                	sw	a5,48(s1)
    80002b3e:	a0b5                	j	80002baa <usertrap+0x1b0>
      memset((void*)pa, 0, PGSIZE);
    80002b40:	6605                	lui	a2,0x1
    80002b42:	4581                	li	a1,0
    80002b44:	ffffe097          	auipc	ra,0xffffe
    80002b48:	222080e7          	jalr	546(ra) # 80000d66 <memset>
      if (mappages(p->pagetable, va, PGSIZE, pa, PTE_W | PTE_U | PTE_R) != 0) {
    80002b4c:	4759                	li	a4,22
    80002b4e:	86ce                	mv	a3,s3
    80002b50:	6605                	lui	a2,0x1
    80002b52:	75fd                	lui	a1,0xfffff
    80002b54:	00b975b3          	and	a1,s2,a1
    80002b58:	68a8                	ld	a0,80(s1)
    80002b5a:	ffffe097          	auipc	ra,0xffffe
    80002b5e:	5f8080e7          	jalr	1528(ra) # 80001152 <mappages>
    80002b62:	892a                	mv	s2,a0
    80002b64:	ee050ce3          	beqz	a0,80002a5c <usertrap+0x62>
        kfree((void*)pa);
    80002b68:	854e                	mv	a0,s3
    80002b6a:	ffffe097          	auipc	ra,0xffffe
    80002b6e:	f14080e7          	jalr	-236(ra) # 80000a7e <kfree>
        p->killed = 1;
    80002b72:	4785                	li	a5,1
    80002b74:	d89c                	sw	a5,48(s1)
    80002b76:	a815                	j	80002baa <usertrap+0x1b0>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b78:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b7c:	5c90                	lw	a2,56(s1)
    80002b7e:	00005517          	auipc	a0,0x5
    80002b82:	7ca50513          	addi	a0,a0,1994 # 80008348 <states.0+0xf0>
    80002b86:	ffffe097          	auipc	ra,0xffffe
    80002b8a:	a06080e7          	jalr	-1530(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b8e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b92:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b96:	00005517          	auipc	a0,0x5
    80002b9a:	7e250513          	addi	a0,a0,2018 # 80008378 <states.0+0x120>
    80002b9e:	ffffe097          	auipc	ra,0xffffe
    80002ba2:	9ee080e7          	jalr	-1554(ra) # 8000058c <printf>
    p->killed = 1;
    80002ba6:	4785                	li	a5,1
    80002ba8:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002baa:	557d                	li	a0,-1
    80002bac:	fffff097          	auipc	ra,0xfffff
    80002bb0:	5b0080e7          	jalr	1456(ra) # 8000215c <exit>
  if(which_dev == 2)
    80002bb4:	b57d                	j	80002a62 <usertrap+0x68>
    exit(-1);
    80002bb6:	557d                	li	a0,-1
    80002bb8:	fffff097          	auipc	ra,0xfffff
    80002bbc:	5a4080e7          	jalr	1444(ra) # 8000215c <exit>
  if(which_dev == 2)
    80002bc0:	4789                	li	a5,2
    80002bc2:	eaf910e3          	bne	s2,a5,80002a62 <usertrap+0x68>
    yield();
    80002bc6:	fffff097          	auipc	ra,0xfffff
    80002bca:	6a0080e7          	jalr	1696(ra) # 80002266 <yield>
    80002bce:	bd51                	j	80002a62 <usertrap+0x68>

0000000080002bd0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002bd0:	1101                	addi	sp,sp,-32
    80002bd2:	ec06                	sd	ra,24(sp)
    80002bd4:	e822                	sd	s0,16(sp)
    80002bd6:	e426                	sd	s1,8(sp)
    80002bd8:	1000                	addi	s0,sp,32
    80002bda:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002bdc:	fffff097          	auipc	ra,0xfffff
    80002be0:	e86080e7          	jalr	-378(ra) # 80001a62 <myproc>
  switch (n) {
    80002be4:	4795                	li	a5,5
    80002be6:	0497e163          	bltu	a5,s1,80002c28 <argraw+0x58>
    80002bea:	048a                	slli	s1,s1,0x2
    80002bec:	00005717          	auipc	a4,0x5
    80002bf0:	7d470713          	addi	a4,a4,2004 # 800083c0 <states.0+0x168>
    80002bf4:	94ba                	add	s1,s1,a4
    80002bf6:	409c                	lw	a5,0(s1)
    80002bf8:	97ba                	add	a5,a5,a4
    80002bfa:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002bfc:	6d3c                	ld	a5,88(a0)
    80002bfe:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c00:	60e2                	ld	ra,24(sp)
    80002c02:	6442                	ld	s0,16(sp)
    80002c04:	64a2                	ld	s1,8(sp)
    80002c06:	6105                	addi	sp,sp,32
    80002c08:	8082                	ret
    return p->trapframe->a1;
    80002c0a:	6d3c                	ld	a5,88(a0)
    80002c0c:	7fa8                	ld	a0,120(a5)
    80002c0e:	bfcd                	j	80002c00 <argraw+0x30>
    return p->trapframe->a2;
    80002c10:	6d3c                	ld	a5,88(a0)
    80002c12:	63c8                	ld	a0,128(a5)
    80002c14:	b7f5                	j	80002c00 <argraw+0x30>
    return p->trapframe->a3;
    80002c16:	6d3c                	ld	a5,88(a0)
    80002c18:	67c8                	ld	a0,136(a5)
    80002c1a:	b7dd                	j	80002c00 <argraw+0x30>
    return p->trapframe->a4;
    80002c1c:	6d3c                	ld	a5,88(a0)
    80002c1e:	6bc8                	ld	a0,144(a5)
    80002c20:	b7c5                	j	80002c00 <argraw+0x30>
    return p->trapframe->a5;
    80002c22:	6d3c                	ld	a5,88(a0)
    80002c24:	6fc8                	ld	a0,152(a5)
    80002c26:	bfe9                	j	80002c00 <argraw+0x30>
  panic("argraw");
    80002c28:	00005517          	auipc	a0,0x5
    80002c2c:	77050513          	addi	a0,a0,1904 # 80008398 <states.0+0x140>
    80002c30:	ffffe097          	auipc	ra,0xffffe
    80002c34:	912080e7          	jalr	-1774(ra) # 80000542 <panic>

0000000080002c38 <fetchaddr>:
{
    80002c38:	1101                	addi	sp,sp,-32
    80002c3a:	ec06                	sd	ra,24(sp)
    80002c3c:	e822                	sd	s0,16(sp)
    80002c3e:	e426                	sd	s1,8(sp)
    80002c40:	e04a                	sd	s2,0(sp)
    80002c42:	1000                	addi	s0,sp,32
    80002c44:	84aa                	mv	s1,a0
    80002c46:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c48:	fffff097          	auipc	ra,0xfffff
    80002c4c:	e1a080e7          	jalr	-486(ra) # 80001a62 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002c50:	653c                	ld	a5,72(a0)
    80002c52:	02f4f863          	bgeu	s1,a5,80002c82 <fetchaddr+0x4a>
    80002c56:	00848713          	addi	a4,s1,8
    80002c5a:	02e7e663          	bltu	a5,a4,80002c86 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c5e:	46a1                	li	a3,8
    80002c60:	8626                	mv	a2,s1
    80002c62:	85ca                	mv	a1,s2
    80002c64:	6928                	ld	a0,80(a0)
    80002c66:	fffff097          	auipc	ra,0xfffff
    80002c6a:	b7a080e7          	jalr	-1158(ra) # 800017e0 <copyin>
    80002c6e:	00a03533          	snez	a0,a0
    80002c72:	40a00533          	neg	a0,a0
}
    80002c76:	60e2                	ld	ra,24(sp)
    80002c78:	6442                	ld	s0,16(sp)
    80002c7a:	64a2                	ld	s1,8(sp)
    80002c7c:	6902                	ld	s2,0(sp)
    80002c7e:	6105                	addi	sp,sp,32
    80002c80:	8082                	ret
    return -1;
    80002c82:	557d                	li	a0,-1
    80002c84:	bfcd                	j	80002c76 <fetchaddr+0x3e>
    80002c86:	557d                	li	a0,-1
    80002c88:	b7fd                	j	80002c76 <fetchaddr+0x3e>

0000000080002c8a <fetchstr>:
{
    80002c8a:	7179                	addi	sp,sp,-48
    80002c8c:	f406                	sd	ra,40(sp)
    80002c8e:	f022                	sd	s0,32(sp)
    80002c90:	ec26                	sd	s1,24(sp)
    80002c92:	e84a                	sd	s2,16(sp)
    80002c94:	e44e                	sd	s3,8(sp)
    80002c96:	1800                	addi	s0,sp,48
    80002c98:	892a                	mv	s2,a0
    80002c9a:	84ae                	mv	s1,a1
    80002c9c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	dc4080e7          	jalr	-572(ra) # 80001a62 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ca6:	86ce                	mv	a3,s3
    80002ca8:	864a                	mv	a2,s2
    80002caa:	85a6                	mv	a1,s1
    80002cac:	6928                	ld	a0,80(a0)
    80002cae:	fffff097          	auipc	ra,0xfffff
    80002cb2:	bc0080e7          	jalr	-1088(ra) # 8000186e <copyinstr>
  if(err < 0)
    80002cb6:	00054763          	bltz	a0,80002cc4 <fetchstr+0x3a>
  return strlen(buf);
    80002cba:	8526                	mv	a0,s1
    80002cbc:	ffffe097          	auipc	ra,0xffffe
    80002cc0:	22e080e7          	jalr	558(ra) # 80000eea <strlen>
}
    80002cc4:	70a2                	ld	ra,40(sp)
    80002cc6:	7402                	ld	s0,32(sp)
    80002cc8:	64e2                	ld	s1,24(sp)
    80002cca:	6942                	ld	s2,16(sp)
    80002ccc:	69a2                	ld	s3,8(sp)
    80002cce:	6145                	addi	sp,sp,48
    80002cd0:	8082                	ret

0000000080002cd2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002cd2:	1101                	addi	sp,sp,-32
    80002cd4:	ec06                	sd	ra,24(sp)
    80002cd6:	e822                	sd	s0,16(sp)
    80002cd8:	e426                	sd	s1,8(sp)
    80002cda:	1000                	addi	s0,sp,32
    80002cdc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cde:	00000097          	auipc	ra,0x0
    80002ce2:	ef2080e7          	jalr	-270(ra) # 80002bd0 <argraw>
    80002ce6:	c088                	sw	a0,0(s1)
  return 0;
}
    80002ce8:	4501                	li	a0,0
    80002cea:	60e2                	ld	ra,24(sp)
    80002cec:	6442                	ld	s0,16(sp)
    80002cee:	64a2                	ld	s1,8(sp)
    80002cf0:	6105                	addi	sp,sp,32
    80002cf2:	8082                	ret

0000000080002cf4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002cf4:	1101                	addi	sp,sp,-32
    80002cf6:	ec06                	sd	ra,24(sp)
    80002cf8:	e822                	sd	s0,16(sp)
    80002cfa:	e426                	sd	s1,8(sp)
    80002cfc:	1000                	addi	s0,sp,32
    80002cfe:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d00:	00000097          	auipc	ra,0x0
    80002d04:	ed0080e7          	jalr	-304(ra) # 80002bd0 <argraw>
    80002d08:	e088                	sd	a0,0(s1)
  return 0;
}
    80002d0a:	4501                	li	a0,0
    80002d0c:	60e2                	ld	ra,24(sp)
    80002d0e:	6442                	ld	s0,16(sp)
    80002d10:	64a2                	ld	s1,8(sp)
    80002d12:	6105                	addi	sp,sp,32
    80002d14:	8082                	ret

0000000080002d16 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d16:	1101                	addi	sp,sp,-32
    80002d18:	ec06                	sd	ra,24(sp)
    80002d1a:	e822                	sd	s0,16(sp)
    80002d1c:	e426                	sd	s1,8(sp)
    80002d1e:	e04a                	sd	s2,0(sp)
    80002d20:	1000                	addi	s0,sp,32
    80002d22:	84ae                	mv	s1,a1
    80002d24:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002d26:	00000097          	auipc	ra,0x0
    80002d2a:	eaa080e7          	jalr	-342(ra) # 80002bd0 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002d2e:	864a                	mv	a2,s2
    80002d30:	85a6                	mv	a1,s1
    80002d32:	00000097          	auipc	ra,0x0
    80002d36:	f58080e7          	jalr	-168(ra) # 80002c8a <fetchstr>
}
    80002d3a:	60e2                	ld	ra,24(sp)
    80002d3c:	6442                	ld	s0,16(sp)
    80002d3e:	64a2                	ld	s1,8(sp)
    80002d40:	6902                	ld	s2,0(sp)
    80002d42:	6105                	addi	sp,sp,32
    80002d44:	8082                	ret

0000000080002d46 <syscall>:
[SYS_sigreturn] sys_sigreturn,
};

void
syscall(void)
{
    80002d46:	1101                	addi	sp,sp,-32
    80002d48:	ec06                	sd	ra,24(sp)
    80002d4a:	e822                	sd	s0,16(sp)
    80002d4c:	e426                	sd	s1,8(sp)
    80002d4e:	e04a                	sd	s2,0(sp)
    80002d50:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d52:	fffff097          	auipc	ra,0xfffff
    80002d56:	d10080e7          	jalr	-752(ra) # 80001a62 <myproc>
    80002d5a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d5c:	05853903          	ld	s2,88(a0)
    80002d60:	0a893783          	ld	a5,168(s2)
    80002d64:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d68:	37fd                	addiw	a5,a5,-1
    80002d6a:	4759                	li	a4,22
    80002d6c:	00f76f63          	bltu	a4,a5,80002d8a <syscall+0x44>
    80002d70:	00369713          	slli	a4,a3,0x3
    80002d74:	00005797          	auipc	a5,0x5
    80002d78:	66478793          	addi	a5,a5,1636 # 800083d8 <syscalls>
    80002d7c:	97ba                	add	a5,a5,a4
    80002d7e:	639c                	ld	a5,0(a5)
    80002d80:	c789                	beqz	a5,80002d8a <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002d82:	9782                	jalr	a5
    80002d84:	06a93823          	sd	a0,112(s2)
    80002d88:	a839                	j	80002da6 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d8a:	15848613          	addi	a2,s1,344
    80002d8e:	5c8c                	lw	a1,56(s1)
    80002d90:	00005517          	auipc	a0,0x5
    80002d94:	61050513          	addi	a0,a0,1552 # 800083a0 <states.0+0x148>
    80002d98:	ffffd097          	auipc	ra,0xffffd
    80002d9c:	7f4080e7          	jalr	2036(ra) # 8000058c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002da0:	6cbc                	ld	a5,88(s1)
    80002da2:	577d                	li	a4,-1
    80002da4:	fbb8                	sd	a4,112(a5)
  }
}
    80002da6:	60e2                	ld	ra,24(sp)
    80002da8:	6442                	ld	s0,16(sp)
    80002daa:	64a2                	ld	s1,8(sp)
    80002dac:	6902                	ld	s2,0(sp)
    80002dae:	6105                	addi	sp,sp,32
    80002db0:	8082                	ret

0000000080002db2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002db2:	1101                	addi	sp,sp,-32
    80002db4:	ec06                	sd	ra,24(sp)
    80002db6:	e822                	sd	s0,16(sp)
    80002db8:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002dba:	fec40593          	addi	a1,s0,-20
    80002dbe:	4501                	li	a0,0
    80002dc0:	00000097          	auipc	ra,0x0
    80002dc4:	f12080e7          	jalr	-238(ra) # 80002cd2 <argint>
    return -1;
    80002dc8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002dca:	00054963          	bltz	a0,80002ddc <sys_exit+0x2a>
  exit(n);
    80002dce:	fec42503          	lw	a0,-20(s0)
    80002dd2:	fffff097          	auipc	ra,0xfffff
    80002dd6:	38a080e7          	jalr	906(ra) # 8000215c <exit>
  return 0;  // not reached
    80002dda:	4781                	li	a5,0
}
    80002ddc:	853e                	mv	a0,a5
    80002dde:	60e2                	ld	ra,24(sp)
    80002de0:	6442                	ld	s0,16(sp)
    80002de2:	6105                	addi	sp,sp,32
    80002de4:	8082                	ret

0000000080002de6 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002de6:	1141                	addi	sp,sp,-16
    80002de8:	e406                	sd	ra,8(sp)
    80002dea:	e022                	sd	s0,0(sp)
    80002dec:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002dee:	fffff097          	auipc	ra,0xfffff
    80002df2:	c74080e7          	jalr	-908(ra) # 80001a62 <myproc>
}
    80002df6:	5d08                	lw	a0,56(a0)
    80002df8:	60a2                	ld	ra,8(sp)
    80002dfa:	6402                	ld	s0,0(sp)
    80002dfc:	0141                	addi	sp,sp,16
    80002dfe:	8082                	ret

0000000080002e00 <sys_fork>:

uint64
sys_fork(void)
{
    80002e00:	1141                	addi	sp,sp,-16
    80002e02:	e406                	sd	ra,8(sp)
    80002e04:	e022                	sd	s0,0(sp)
    80002e06:	0800                	addi	s0,sp,16
  return fork();
    80002e08:	fffff097          	auipc	ra,0xfffff
    80002e0c:	04a080e7          	jalr	74(ra) # 80001e52 <fork>
}
    80002e10:	60a2                	ld	ra,8(sp)
    80002e12:	6402                	ld	s0,0(sp)
    80002e14:	0141                	addi	sp,sp,16
    80002e16:	8082                	ret

0000000080002e18 <sys_wait>:

uint64
sys_wait(void)
{
    80002e18:	1101                	addi	sp,sp,-32
    80002e1a:	ec06                	sd	ra,24(sp)
    80002e1c:	e822                	sd	s0,16(sp)
    80002e1e:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002e20:	fe840593          	addi	a1,s0,-24
    80002e24:	4501                	li	a0,0
    80002e26:	00000097          	auipc	ra,0x0
    80002e2a:	ece080e7          	jalr	-306(ra) # 80002cf4 <argaddr>
    80002e2e:	87aa                	mv	a5,a0
    return -1;
    80002e30:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002e32:	0007c863          	bltz	a5,80002e42 <sys_wait+0x2a>
  return wait(p);
    80002e36:	fe843503          	ld	a0,-24(s0)
    80002e3a:	fffff097          	auipc	ra,0xfffff
    80002e3e:	4e6080e7          	jalr	1254(ra) # 80002320 <wait>
}
    80002e42:	60e2                	ld	ra,24(sp)
    80002e44:	6442                	ld	s0,16(sp)
    80002e46:	6105                	addi	sp,sp,32
    80002e48:	8082                	ret

0000000080002e4a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e4a:	7179                	addi	sp,sp,-48
    80002e4c:	f406                	sd	ra,40(sp)
    80002e4e:	f022                	sd	s0,32(sp)
    80002e50:	ec26                	sd	s1,24(sp)
    80002e52:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002e54:	fdc40593          	addi	a1,s0,-36
    80002e58:	4501                	li	a0,0
    80002e5a:	00000097          	auipc	ra,0x0
    80002e5e:	e78080e7          	jalr	-392(ra) # 80002cd2 <argint>
    80002e62:	87aa                	mv	a5,a0
    return -1;
    80002e64:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002e66:	0207c163          	bltz	a5,80002e88 <sys_sbrk+0x3e>
  struct proc *p = myproc();
    80002e6a:	fffff097          	auipc	ra,0xfffff
    80002e6e:	bf8080e7          	jalr	-1032(ra) # 80001a62 <myproc>
  addr = p->sz;
    80002e72:	4524                	lw	s1,72(a0)
  //if (addr + n < 0) return -1;
  if (addr + n >= MAXVA || addr + n <= 0)
    80002e74:	fdc42783          	lw	a5,-36(s0)
    80002e78:	0097863b          	addw	a2,a5,s1
    80002e7c:	00c05b63          	blez	a2,80002e92 <sys_sbrk+0x48>
    return addr;
  p->sz = addr + n;
    80002e80:	e530                	sd	a2,72(a0)
  //if(growproc(n) < 0)
  //  return -1;
  if(n < 0)
    80002e82:	0007ca63          	bltz	a5,80002e96 <sys_sbrk+0x4c>
    uvmdealloc(p->pagetable, addr, p->sz);
  return addr;
    80002e86:	8526                	mv	a0,s1
}
    80002e88:	70a2                	ld	ra,40(sp)
    80002e8a:	7402                	ld	s0,32(sp)
    80002e8c:	64e2                	ld	s1,24(sp)
    80002e8e:	6145                	addi	sp,sp,48
    80002e90:	8082                	ret
    return addr;
    80002e92:	8526                	mv	a0,s1
    80002e94:	bfd5                	j	80002e88 <sys_sbrk+0x3e>
    uvmdealloc(p->pagetable, addr, p->sz);
    80002e96:	85a6                	mv	a1,s1
    80002e98:	6928                	ld	a0,80(a0)
    80002e9a:	ffffe097          	auipc	ra,0xffffe
    80002e9e:	63e080e7          	jalr	1598(ra) # 800014d8 <uvmdealloc>
    80002ea2:	b7d5                	j	80002e86 <sys_sbrk+0x3c>

0000000080002ea4 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002ea4:	7139                	addi	sp,sp,-64
    80002ea6:	fc06                	sd	ra,56(sp)
    80002ea8:	f822                	sd	s0,48(sp)
    80002eaa:	f426                	sd	s1,40(sp)
    80002eac:	f04a                	sd	s2,32(sp)
    80002eae:	ec4e                	sd	s3,24(sp)
    80002eb0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002eb2:	fcc40593          	addi	a1,s0,-52
    80002eb6:	4501                	li	a0,0
    80002eb8:	00000097          	auipc	ra,0x0
    80002ebc:	e1a080e7          	jalr	-486(ra) # 80002cd2 <argint>
    return -1;
    80002ec0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ec2:	06054963          	bltz	a0,80002f34 <sys_sleep+0x90>
  acquire(&tickslock);
    80002ec6:	00015517          	auipc	a0,0x15
    80002eca:	2a250513          	addi	a0,a0,674 # 80018168 <tickslock>
    80002ece:	ffffe097          	auipc	ra,0xffffe
    80002ed2:	d9c080e7          	jalr	-612(ra) # 80000c6a <acquire>
  ticks0 = ticks;
    80002ed6:	00006917          	auipc	s2,0x6
    80002eda:	14a92903          	lw	s2,330(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002ede:	fcc42783          	lw	a5,-52(s0)
    80002ee2:	cf85                	beqz	a5,80002f1a <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ee4:	00015997          	auipc	s3,0x15
    80002ee8:	28498993          	addi	s3,s3,644 # 80018168 <tickslock>
    80002eec:	00006497          	auipc	s1,0x6
    80002ef0:	13448493          	addi	s1,s1,308 # 80009020 <ticks>
    if(myproc()->killed){
    80002ef4:	fffff097          	auipc	ra,0xfffff
    80002ef8:	b6e080e7          	jalr	-1170(ra) # 80001a62 <myproc>
    80002efc:	591c                	lw	a5,48(a0)
    80002efe:	e3b9                	bnez	a5,80002f44 <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80002f00:	85ce                	mv	a1,s3
    80002f02:	8526                	mv	a0,s1
    80002f04:	fffff097          	auipc	ra,0xfffff
    80002f08:	39e080e7          	jalr	926(ra) # 800022a2 <sleep>
  while(ticks - ticks0 < n){
    80002f0c:	409c                	lw	a5,0(s1)
    80002f0e:	412787bb          	subw	a5,a5,s2
    80002f12:	fcc42703          	lw	a4,-52(s0)
    80002f16:	fce7efe3          	bltu	a5,a4,80002ef4 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002f1a:	00015517          	auipc	a0,0x15
    80002f1e:	24e50513          	addi	a0,a0,590 # 80018168 <tickslock>
    80002f22:	ffffe097          	auipc	ra,0xffffe
    80002f26:	dfc080e7          	jalr	-516(ra) # 80000d1e <release>
  backtrace();
    80002f2a:	ffffe097          	auipc	ra,0xffffe
    80002f2e:	842080e7          	jalr	-1982(ra) # 8000076c <backtrace>
  return 0;
    80002f32:	4781                	li	a5,0
}
    80002f34:	853e                	mv	a0,a5
    80002f36:	70e2                	ld	ra,56(sp)
    80002f38:	7442                	ld	s0,48(sp)
    80002f3a:	74a2                	ld	s1,40(sp)
    80002f3c:	7902                	ld	s2,32(sp)
    80002f3e:	69e2                	ld	s3,24(sp)
    80002f40:	6121                	addi	sp,sp,64
    80002f42:	8082                	ret
      release(&tickslock);
    80002f44:	00015517          	auipc	a0,0x15
    80002f48:	22450513          	addi	a0,a0,548 # 80018168 <tickslock>
    80002f4c:	ffffe097          	auipc	ra,0xffffe
    80002f50:	dd2080e7          	jalr	-558(ra) # 80000d1e <release>
      return -1;
    80002f54:	57fd                	li	a5,-1
    80002f56:	bff9                	j	80002f34 <sys_sleep+0x90>

0000000080002f58 <sys_kill>:

uint64
sys_kill(void)
{
    80002f58:	1101                	addi	sp,sp,-32
    80002f5a:	ec06                	sd	ra,24(sp)
    80002f5c:	e822                	sd	s0,16(sp)
    80002f5e:	1000                	addi	s0,sp,32
  int pid;
  if(argint(0, &pid) < 0)
    80002f60:	fec40593          	addi	a1,s0,-20
    80002f64:	4501                	li	a0,0
    80002f66:	00000097          	auipc	ra,0x0
    80002f6a:	d6c080e7          	jalr	-660(ra) # 80002cd2 <argint>
    80002f6e:	87aa                	mv	a5,a0
    return -1;
    80002f70:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002f72:	0007c863          	bltz	a5,80002f82 <sys_kill+0x2a>
  return kill(pid);
    80002f76:	fec42503          	lw	a0,-20(s0)
    80002f7a:	fffff097          	auipc	ra,0xfffff
    80002f7e:	512080e7          	jalr	1298(ra) # 8000248c <kill>
}
    80002f82:	60e2                	ld	ra,24(sp)
    80002f84:	6442                	ld	s0,16(sp)
    80002f86:	6105                	addi	sp,sp,32
    80002f88:	8082                	ret

0000000080002f8a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f8a:	1101                	addi	sp,sp,-32
    80002f8c:	ec06                	sd	ra,24(sp)
    80002f8e:	e822                	sd	s0,16(sp)
    80002f90:	e426                	sd	s1,8(sp)
    80002f92:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f94:	00015517          	auipc	a0,0x15
    80002f98:	1d450513          	addi	a0,a0,468 # 80018168 <tickslock>
    80002f9c:	ffffe097          	auipc	ra,0xffffe
    80002fa0:	cce080e7          	jalr	-818(ra) # 80000c6a <acquire>
  xticks = ticks;
    80002fa4:	00006497          	auipc	s1,0x6
    80002fa8:	07c4a483          	lw	s1,124(s1) # 80009020 <ticks>
  release(&tickslock);
    80002fac:	00015517          	auipc	a0,0x15
    80002fb0:	1bc50513          	addi	a0,a0,444 # 80018168 <tickslock>
    80002fb4:	ffffe097          	auipc	ra,0xffffe
    80002fb8:	d6a080e7          	jalr	-662(ra) # 80000d1e <release>
  return xticks;
}
    80002fbc:	02049513          	slli	a0,s1,0x20
    80002fc0:	9101                	srli	a0,a0,0x20
    80002fc2:	60e2                	ld	ra,24(sp)
    80002fc4:	6442                	ld	s0,16(sp)
    80002fc6:	64a2                	ld	s1,8(sp)
    80002fc8:	6105                	addi	sp,sp,32
    80002fca:	8082                	ret

0000000080002fcc <sys_sigalarm>:
uint64
sys_sigalarm(void)
{
    80002fcc:	7179                	addi	sp,sp,-48
    80002fce:	f406                	sd	ra,40(sp)
    80002fd0:	f022                	sd	s0,32(sp)
    80002fd2:	ec26                	sd	s1,24(sp)
    80002fd4:	1800                	addi	s0,sp,48
  struct proc*myProc=myproc();
    80002fd6:	fffff097          	auipc	ra,0xfffff
    80002fda:	a8c080e7          	jalr	-1396(ra) # 80001a62 <myproc>
    80002fde:	84aa                	mv	s1,a0
  int n;
  uint64 handler;

  if(argint(0, &n) < 0)
    80002fe0:	fdc40593          	addi	a1,s0,-36
    80002fe4:	4501                	li	a0,0
    80002fe6:	00000097          	auipc	ra,0x0
    80002fea:	cec080e7          	jalr	-788(ra) # 80002cd2 <argint>
  return -1;
    80002fee:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ff0:	02054463          	bltz	a0,80003018 <sys_sigalarm+0x4c>
     myProc->interval=n;
    80002ff4:	fdc42783          	lw	a5,-36(s0)
    80002ff8:	16f4b423          	sd	a5,360(s1)
  if(argaddr(0, &handler) < 0)
    80002ffc:	fd040593          	addi	a1,s0,-48
    80003000:	4501                	li	a0,0
    80003002:	00000097          	auipc	ra,0x0
    80003006:	cf2080e7          	jalr	-782(ra) # 80002cf4 <argaddr>
    8000300a:	00054d63          	bltz	a0,80003024 <sys_sigalarm+0x58>
  return -1;
    myProc->handler=(void(*)())handler;
    8000300e:	fd043783          	ld	a5,-48(s0)
    80003012:	16f4b823          	sd	a5,368(s1)
    return 0;
    80003016:	4781                	li	a5,0
}
    80003018:	853e                	mv	a0,a5
    8000301a:	70a2                	ld	ra,40(sp)
    8000301c:	7402                	ld	s0,32(sp)
    8000301e:	64e2                	ld	s1,24(sp)
    80003020:	6145                	addi	sp,sp,48
    80003022:	8082                	ret
  return -1;
    80003024:	57fd                	li	a5,-1
    80003026:	bfcd                	j	80003018 <sys_sigalarm+0x4c>

0000000080003028 <sys_sigreturn>:
uint64
sys_sigreturn(void)
{
    80003028:	1101                	addi	sp,sp,-32
    8000302a:	ec06                	sd	ra,24(sp)
    8000302c:	e822                	sd	s0,16(sp)
    8000302e:	e426                	sd	s1,8(sp)
    80003030:	1000                	addi	s0,sp,32
  struct proc*myProc=myproc();
    80003032:	fffff097          	auipc	ra,0xfffff
    80003036:	a30080e7          	jalr	-1488(ra) # 80001a62 <myproc>
    8000303a:	84aa                	mv	s1,a0
  switchTrapframe(myProc->trapframe,myProc->trapframeSave);
    8000303c:	18053583          	ld	a1,384(a0)
    80003040:	6d28                	ld	a0,88(a0)
    80003042:	00000097          	auipc	ra,0x0
    80003046:	910080e7          	jalr	-1776(ra) # 80002952 <switchTrapframe>
  myProc->waitReturn=0;
    8000304a:	1804a423          	sw	zero,392(s1)
   return 0;
}
    8000304e:	4501                	li	a0,0
    80003050:	60e2                	ld	ra,24(sp)
    80003052:	6442                	ld	s0,16(sp)
    80003054:	64a2                	ld	s1,8(sp)
    80003056:	6105                	addi	sp,sp,32
    80003058:	8082                	ret

000000008000305a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000305a:	7179                	addi	sp,sp,-48
    8000305c:	f406                	sd	ra,40(sp)
    8000305e:	f022                	sd	s0,32(sp)
    80003060:	ec26                	sd	s1,24(sp)
    80003062:	e84a                	sd	s2,16(sp)
    80003064:	e44e                	sd	s3,8(sp)
    80003066:	e052                	sd	s4,0(sp)
    80003068:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000306a:	00005597          	auipc	a1,0x5
    8000306e:	42e58593          	addi	a1,a1,1070 # 80008498 <syscalls+0xc0>
    80003072:	00015517          	auipc	a0,0x15
    80003076:	10e50513          	addi	a0,a0,270 # 80018180 <bcache>
    8000307a:	ffffe097          	auipc	ra,0xffffe
    8000307e:	b60080e7          	jalr	-1184(ra) # 80000bda <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003082:	0001d797          	auipc	a5,0x1d
    80003086:	0fe78793          	addi	a5,a5,254 # 80020180 <bcache+0x8000>
    8000308a:	0001d717          	auipc	a4,0x1d
    8000308e:	35e70713          	addi	a4,a4,862 # 800203e8 <bcache+0x8268>
    80003092:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003096:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000309a:	00015497          	auipc	s1,0x15
    8000309e:	0fe48493          	addi	s1,s1,254 # 80018198 <bcache+0x18>
    b->next = bcache.head.next;
    800030a2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030a4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030a6:	00005a17          	auipc	s4,0x5
    800030aa:	3faa0a13          	addi	s4,s4,1018 # 800084a0 <syscalls+0xc8>
    b->next = bcache.head.next;
    800030ae:	2b893783          	ld	a5,696(s2)
    800030b2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030b4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030b8:	85d2                	mv	a1,s4
    800030ba:	01048513          	addi	a0,s1,16
    800030be:	00001097          	auipc	ra,0x1
    800030c2:	4ac080e7          	jalr	1196(ra) # 8000456a <initsleeplock>
    bcache.head.next->prev = b;
    800030c6:	2b893783          	ld	a5,696(s2)
    800030ca:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030cc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030d0:	45848493          	addi	s1,s1,1112
    800030d4:	fd349de3          	bne	s1,s3,800030ae <binit+0x54>
  }
}
    800030d8:	70a2                	ld	ra,40(sp)
    800030da:	7402                	ld	s0,32(sp)
    800030dc:	64e2                	ld	s1,24(sp)
    800030de:	6942                	ld	s2,16(sp)
    800030e0:	69a2                	ld	s3,8(sp)
    800030e2:	6a02                	ld	s4,0(sp)
    800030e4:	6145                	addi	sp,sp,48
    800030e6:	8082                	ret

00000000800030e8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030e8:	7179                	addi	sp,sp,-48
    800030ea:	f406                	sd	ra,40(sp)
    800030ec:	f022                	sd	s0,32(sp)
    800030ee:	ec26                	sd	s1,24(sp)
    800030f0:	e84a                	sd	s2,16(sp)
    800030f2:	e44e                	sd	s3,8(sp)
    800030f4:	1800                	addi	s0,sp,48
    800030f6:	892a                	mv	s2,a0
    800030f8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800030fa:	00015517          	auipc	a0,0x15
    800030fe:	08650513          	addi	a0,a0,134 # 80018180 <bcache>
    80003102:	ffffe097          	auipc	ra,0xffffe
    80003106:	b68080e7          	jalr	-1176(ra) # 80000c6a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000310a:	0001d497          	auipc	s1,0x1d
    8000310e:	32e4b483          	ld	s1,814(s1) # 80020438 <bcache+0x82b8>
    80003112:	0001d797          	auipc	a5,0x1d
    80003116:	2d678793          	addi	a5,a5,726 # 800203e8 <bcache+0x8268>
    8000311a:	02f48f63          	beq	s1,a5,80003158 <bread+0x70>
    8000311e:	873e                	mv	a4,a5
    80003120:	a021                	j	80003128 <bread+0x40>
    80003122:	68a4                	ld	s1,80(s1)
    80003124:	02e48a63          	beq	s1,a4,80003158 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003128:	449c                	lw	a5,8(s1)
    8000312a:	ff279ce3          	bne	a5,s2,80003122 <bread+0x3a>
    8000312e:	44dc                	lw	a5,12(s1)
    80003130:	ff3799e3          	bne	a5,s3,80003122 <bread+0x3a>
      b->refcnt++;
    80003134:	40bc                	lw	a5,64(s1)
    80003136:	2785                	addiw	a5,a5,1
    80003138:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000313a:	00015517          	auipc	a0,0x15
    8000313e:	04650513          	addi	a0,a0,70 # 80018180 <bcache>
    80003142:	ffffe097          	auipc	ra,0xffffe
    80003146:	bdc080e7          	jalr	-1060(ra) # 80000d1e <release>
      acquiresleep(&b->lock);
    8000314a:	01048513          	addi	a0,s1,16
    8000314e:	00001097          	auipc	ra,0x1
    80003152:	456080e7          	jalr	1110(ra) # 800045a4 <acquiresleep>
      return b;
    80003156:	a8b9                	j	800031b4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003158:	0001d497          	auipc	s1,0x1d
    8000315c:	2d84b483          	ld	s1,728(s1) # 80020430 <bcache+0x82b0>
    80003160:	0001d797          	auipc	a5,0x1d
    80003164:	28878793          	addi	a5,a5,648 # 800203e8 <bcache+0x8268>
    80003168:	00f48863          	beq	s1,a5,80003178 <bread+0x90>
    8000316c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000316e:	40bc                	lw	a5,64(s1)
    80003170:	cf81                	beqz	a5,80003188 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003172:	64a4                	ld	s1,72(s1)
    80003174:	fee49de3          	bne	s1,a4,8000316e <bread+0x86>
  panic("bget: no buffers");
    80003178:	00005517          	auipc	a0,0x5
    8000317c:	33050513          	addi	a0,a0,816 # 800084a8 <syscalls+0xd0>
    80003180:	ffffd097          	auipc	ra,0xffffd
    80003184:	3c2080e7          	jalr	962(ra) # 80000542 <panic>
      b->dev = dev;
    80003188:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000318c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003190:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003194:	4785                	li	a5,1
    80003196:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003198:	00015517          	auipc	a0,0x15
    8000319c:	fe850513          	addi	a0,a0,-24 # 80018180 <bcache>
    800031a0:	ffffe097          	auipc	ra,0xffffe
    800031a4:	b7e080e7          	jalr	-1154(ra) # 80000d1e <release>
      acquiresleep(&b->lock);
    800031a8:	01048513          	addi	a0,s1,16
    800031ac:	00001097          	auipc	ra,0x1
    800031b0:	3f8080e7          	jalr	1016(ra) # 800045a4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031b4:	409c                	lw	a5,0(s1)
    800031b6:	cb89                	beqz	a5,800031c8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031b8:	8526                	mv	a0,s1
    800031ba:	70a2                	ld	ra,40(sp)
    800031bc:	7402                	ld	s0,32(sp)
    800031be:	64e2                	ld	s1,24(sp)
    800031c0:	6942                	ld	s2,16(sp)
    800031c2:	69a2                	ld	s3,8(sp)
    800031c4:	6145                	addi	sp,sp,48
    800031c6:	8082                	ret
    virtio_disk_rw(b, 0);
    800031c8:	4581                	li	a1,0
    800031ca:	8526                	mv	a0,s1
    800031cc:	00003097          	auipc	ra,0x3
    800031d0:	f20080e7          	jalr	-224(ra) # 800060ec <virtio_disk_rw>
    b->valid = 1;
    800031d4:	4785                	li	a5,1
    800031d6:	c09c                	sw	a5,0(s1)
  return b;
    800031d8:	b7c5                	j	800031b8 <bread+0xd0>

00000000800031da <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031da:	1101                	addi	sp,sp,-32
    800031dc:	ec06                	sd	ra,24(sp)
    800031de:	e822                	sd	s0,16(sp)
    800031e0:	e426                	sd	s1,8(sp)
    800031e2:	1000                	addi	s0,sp,32
    800031e4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031e6:	0541                	addi	a0,a0,16
    800031e8:	00001097          	auipc	ra,0x1
    800031ec:	456080e7          	jalr	1110(ra) # 8000463e <holdingsleep>
    800031f0:	cd01                	beqz	a0,80003208 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800031f2:	4585                	li	a1,1
    800031f4:	8526                	mv	a0,s1
    800031f6:	00003097          	auipc	ra,0x3
    800031fa:	ef6080e7          	jalr	-266(ra) # 800060ec <virtio_disk_rw>
}
    800031fe:	60e2                	ld	ra,24(sp)
    80003200:	6442                	ld	s0,16(sp)
    80003202:	64a2                	ld	s1,8(sp)
    80003204:	6105                	addi	sp,sp,32
    80003206:	8082                	ret
    panic("bwrite");
    80003208:	00005517          	auipc	a0,0x5
    8000320c:	2b850513          	addi	a0,a0,696 # 800084c0 <syscalls+0xe8>
    80003210:	ffffd097          	auipc	ra,0xffffd
    80003214:	332080e7          	jalr	818(ra) # 80000542 <panic>

0000000080003218 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003218:	1101                	addi	sp,sp,-32
    8000321a:	ec06                	sd	ra,24(sp)
    8000321c:	e822                	sd	s0,16(sp)
    8000321e:	e426                	sd	s1,8(sp)
    80003220:	e04a                	sd	s2,0(sp)
    80003222:	1000                	addi	s0,sp,32
    80003224:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003226:	01050913          	addi	s2,a0,16
    8000322a:	854a                	mv	a0,s2
    8000322c:	00001097          	auipc	ra,0x1
    80003230:	412080e7          	jalr	1042(ra) # 8000463e <holdingsleep>
    80003234:	c92d                	beqz	a0,800032a6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003236:	854a                	mv	a0,s2
    80003238:	00001097          	auipc	ra,0x1
    8000323c:	3c2080e7          	jalr	962(ra) # 800045fa <releasesleep>

  acquire(&bcache.lock);
    80003240:	00015517          	auipc	a0,0x15
    80003244:	f4050513          	addi	a0,a0,-192 # 80018180 <bcache>
    80003248:	ffffe097          	auipc	ra,0xffffe
    8000324c:	a22080e7          	jalr	-1502(ra) # 80000c6a <acquire>
  b->refcnt--;
    80003250:	40bc                	lw	a5,64(s1)
    80003252:	37fd                	addiw	a5,a5,-1
    80003254:	0007871b          	sext.w	a4,a5
    80003258:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000325a:	eb05                	bnez	a4,8000328a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000325c:	68bc                	ld	a5,80(s1)
    8000325e:	64b8                	ld	a4,72(s1)
    80003260:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003262:	64bc                	ld	a5,72(s1)
    80003264:	68b8                	ld	a4,80(s1)
    80003266:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003268:	0001d797          	auipc	a5,0x1d
    8000326c:	f1878793          	addi	a5,a5,-232 # 80020180 <bcache+0x8000>
    80003270:	2b87b703          	ld	a4,696(a5)
    80003274:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003276:	0001d717          	auipc	a4,0x1d
    8000327a:	17270713          	addi	a4,a4,370 # 800203e8 <bcache+0x8268>
    8000327e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003280:	2b87b703          	ld	a4,696(a5)
    80003284:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003286:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000328a:	00015517          	auipc	a0,0x15
    8000328e:	ef650513          	addi	a0,a0,-266 # 80018180 <bcache>
    80003292:	ffffe097          	auipc	ra,0xffffe
    80003296:	a8c080e7          	jalr	-1396(ra) # 80000d1e <release>
}
    8000329a:	60e2                	ld	ra,24(sp)
    8000329c:	6442                	ld	s0,16(sp)
    8000329e:	64a2                	ld	s1,8(sp)
    800032a0:	6902                	ld	s2,0(sp)
    800032a2:	6105                	addi	sp,sp,32
    800032a4:	8082                	ret
    panic("brelse");
    800032a6:	00005517          	auipc	a0,0x5
    800032aa:	22250513          	addi	a0,a0,546 # 800084c8 <syscalls+0xf0>
    800032ae:	ffffd097          	auipc	ra,0xffffd
    800032b2:	294080e7          	jalr	660(ra) # 80000542 <panic>

00000000800032b6 <bpin>:

void
bpin(struct buf *b) {
    800032b6:	1101                	addi	sp,sp,-32
    800032b8:	ec06                	sd	ra,24(sp)
    800032ba:	e822                	sd	s0,16(sp)
    800032bc:	e426                	sd	s1,8(sp)
    800032be:	1000                	addi	s0,sp,32
    800032c0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032c2:	00015517          	auipc	a0,0x15
    800032c6:	ebe50513          	addi	a0,a0,-322 # 80018180 <bcache>
    800032ca:	ffffe097          	auipc	ra,0xffffe
    800032ce:	9a0080e7          	jalr	-1632(ra) # 80000c6a <acquire>
  b->refcnt++;
    800032d2:	40bc                	lw	a5,64(s1)
    800032d4:	2785                	addiw	a5,a5,1
    800032d6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032d8:	00015517          	auipc	a0,0x15
    800032dc:	ea850513          	addi	a0,a0,-344 # 80018180 <bcache>
    800032e0:	ffffe097          	auipc	ra,0xffffe
    800032e4:	a3e080e7          	jalr	-1474(ra) # 80000d1e <release>
}
    800032e8:	60e2                	ld	ra,24(sp)
    800032ea:	6442                	ld	s0,16(sp)
    800032ec:	64a2                	ld	s1,8(sp)
    800032ee:	6105                	addi	sp,sp,32
    800032f0:	8082                	ret

00000000800032f2 <bunpin>:

void
bunpin(struct buf *b) {
    800032f2:	1101                	addi	sp,sp,-32
    800032f4:	ec06                	sd	ra,24(sp)
    800032f6:	e822                	sd	s0,16(sp)
    800032f8:	e426                	sd	s1,8(sp)
    800032fa:	1000                	addi	s0,sp,32
    800032fc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032fe:	00015517          	auipc	a0,0x15
    80003302:	e8250513          	addi	a0,a0,-382 # 80018180 <bcache>
    80003306:	ffffe097          	auipc	ra,0xffffe
    8000330a:	964080e7          	jalr	-1692(ra) # 80000c6a <acquire>
  b->refcnt--;
    8000330e:	40bc                	lw	a5,64(s1)
    80003310:	37fd                	addiw	a5,a5,-1
    80003312:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003314:	00015517          	auipc	a0,0x15
    80003318:	e6c50513          	addi	a0,a0,-404 # 80018180 <bcache>
    8000331c:	ffffe097          	auipc	ra,0xffffe
    80003320:	a02080e7          	jalr	-1534(ra) # 80000d1e <release>
}
    80003324:	60e2                	ld	ra,24(sp)
    80003326:	6442                	ld	s0,16(sp)
    80003328:	64a2                	ld	s1,8(sp)
    8000332a:	6105                	addi	sp,sp,32
    8000332c:	8082                	ret

000000008000332e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000332e:	1101                	addi	sp,sp,-32
    80003330:	ec06                	sd	ra,24(sp)
    80003332:	e822                	sd	s0,16(sp)
    80003334:	e426                	sd	s1,8(sp)
    80003336:	e04a                	sd	s2,0(sp)
    80003338:	1000                	addi	s0,sp,32
    8000333a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000333c:	00d5d59b          	srliw	a1,a1,0xd
    80003340:	0001d797          	auipc	a5,0x1d
    80003344:	51c7a783          	lw	a5,1308(a5) # 8002085c <sb+0x1c>
    80003348:	9dbd                	addw	a1,a1,a5
    8000334a:	00000097          	auipc	ra,0x0
    8000334e:	d9e080e7          	jalr	-610(ra) # 800030e8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003352:	0074f713          	andi	a4,s1,7
    80003356:	4785                	li	a5,1
    80003358:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000335c:	14ce                	slli	s1,s1,0x33
    8000335e:	90d9                	srli	s1,s1,0x36
    80003360:	00950733          	add	a4,a0,s1
    80003364:	05874703          	lbu	a4,88(a4)
    80003368:	00e7f6b3          	and	a3,a5,a4
    8000336c:	c69d                	beqz	a3,8000339a <bfree+0x6c>
    8000336e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003370:	94aa                	add	s1,s1,a0
    80003372:	fff7c793          	not	a5,a5
    80003376:	8ff9                	and	a5,a5,a4
    80003378:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000337c:	00001097          	auipc	ra,0x1
    80003380:	100080e7          	jalr	256(ra) # 8000447c <log_write>
  brelse(bp);
    80003384:	854a                	mv	a0,s2
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	e92080e7          	jalr	-366(ra) # 80003218 <brelse>
}
    8000338e:	60e2                	ld	ra,24(sp)
    80003390:	6442                	ld	s0,16(sp)
    80003392:	64a2                	ld	s1,8(sp)
    80003394:	6902                	ld	s2,0(sp)
    80003396:	6105                	addi	sp,sp,32
    80003398:	8082                	ret
    panic("freeing free block");
    8000339a:	00005517          	auipc	a0,0x5
    8000339e:	13650513          	addi	a0,a0,310 # 800084d0 <syscalls+0xf8>
    800033a2:	ffffd097          	auipc	ra,0xffffd
    800033a6:	1a0080e7          	jalr	416(ra) # 80000542 <panic>

00000000800033aa <balloc>:
{
    800033aa:	711d                	addi	sp,sp,-96
    800033ac:	ec86                	sd	ra,88(sp)
    800033ae:	e8a2                	sd	s0,80(sp)
    800033b0:	e4a6                	sd	s1,72(sp)
    800033b2:	e0ca                	sd	s2,64(sp)
    800033b4:	fc4e                	sd	s3,56(sp)
    800033b6:	f852                	sd	s4,48(sp)
    800033b8:	f456                	sd	s5,40(sp)
    800033ba:	f05a                	sd	s6,32(sp)
    800033bc:	ec5e                	sd	s7,24(sp)
    800033be:	e862                	sd	s8,16(sp)
    800033c0:	e466                	sd	s9,8(sp)
    800033c2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033c4:	0001d797          	auipc	a5,0x1d
    800033c8:	4807a783          	lw	a5,1152(a5) # 80020844 <sb+0x4>
    800033cc:	cbd1                	beqz	a5,80003460 <balloc+0xb6>
    800033ce:	8baa                	mv	s7,a0
    800033d0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033d2:	0001db17          	auipc	s6,0x1d
    800033d6:	46eb0b13          	addi	s6,s6,1134 # 80020840 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033da:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033dc:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033de:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033e0:	6c89                	lui	s9,0x2
    800033e2:	a831                	j	800033fe <balloc+0x54>
    brelse(bp);
    800033e4:	854a                	mv	a0,s2
    800033e6:	00000097          	auipc	ra,0x0
    800033ea:	e32080e7          	jalr	-462(ra) # 80003218 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033ee:	015c87bb          	addw	a5,s9,s5
    800033f2:	00078a9b          	sext.w	s5,a5
    800033f6:	004b2703          	lw	a4,4(s6)
    800033fa:	06eaf363          	bgeu	s5,a4,80003460 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800033fe:	41fad79b          	sraiw	a5,s5,0x1f
    80003402:	0137d79b          	srliw	a5,a5,0x13
    80003406:	015787bb          	addw	a5,a5,s5
    8000340a:	40d7d79b          	sraiw	a5,a5,0xd
    8000340e:	01cb2583          	lw	a1,28(s6)
    80003412:	9dbd                	addw	a1,a1,a5
    80003414:	855e                	mv	a0,s7
    80003416:	00000097          	auipc	ra,0x0
    8000341a:	cd2080e7          	jalr	-814(ra) # 800030e8 <bread>
    8000341e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003420:	004b2503          	lw	a0,4(s6)
    80003424:	000a849b          	sext.w	s1,s5
    80003428:	8662                	mv	a2,s8
    8000342a:	faa4fde3          	bgeu	s1,a0,800033e4 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000342e:	41f6579b          	sraiw	a5,a2,0x1f
    80003432:	01d7d69b          	srliw	a3,a5,0x1d
    80003436:	00c6873b          	addw	a4,a3,a2
    8000343a:	00777793          	andi	a5,a4,7
    8000343e:	9f95                	subw	a5,a5,a3
    80003440:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003444:	4037571b          	sraiw	a4,a4,0x3
    80003448:	00e906b3          	add	a3,s2,a4
    8000344c:	0586c683          	lbu	a3,88(a3)
    80003450:	00d7f5b3          	and	a1,a5,a3
    80003454:	cd91                	beqz	a1,80003470 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003456:	2605                	addiw	a2,a2,1
    80003458:	2485                	addiw	s1,s1,1
    8000345a:	fd4618e3          	bne	a2,s4,8000342a <balloc+0x80>
    8000345e:	b759                	j	800033e4 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003460:	00005517          	auipc	a0,0x5
    80003464:	08850513          	addi	a0,a0,136 # 800084e8 <syscalls+0x110>
    80003468:	ffffd097          	auipc	ra,0xffffd
    8000346c:	0da080e7          	jalr	218(ra) # 80000542 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003470:	974a                	add	a4,a4,s2
    80003472:	8fd5                	or	a5,a5,a3
    80003474:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003478:	854a                	mv	a0,s2
    8000347a:	00001097          	auipc	ra,0x1
    8000347e:	002080e7          	jalr	2(ra) # 8000447c <log_write>
        brelse(bp);
    80003482:	854a                	mv	a0,s2
    80003484:	00000097          	auipc	ra,0x0
    80003488:	d94080e7          	jalr	-620(ra) # 80003218 <brelse>
  bp = bread(dev, bno);
    8000348c:	85a6                	mv	a1,s1
    8000348e:	855e                	mv	a0,s7
    80003490:	00000097          	auipc	ra,0x0
    80003494:	c58080e7          	jalr	-936(ra) # 800030e8 <bread>
    80003498:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000349a:	40000613          	li	a2,1024
    8000349e:	4581                	li	a1,0
    800034a0:	05850513          	addi	a0,a0,88
    800034a4:	ffffe097          	auipc	ra,0xffffe
    800034a8:	8c2080e7          	jalr	-1854(ra) # 80000d66 <memset>
  log_write(bp);
    800034ac:	854a                	mv	a0,s2
    800034ae:	00001097          	auipc	ra,0x1
    800034b2:	fce080e7          	jalr	-50(ra) # 8000447c <log_write>
  brelse(bp);
    800034b6:	854a                	mv	a0,s2
    800034b8:	00000097          	auipc	ra,0x0
    800034bc:	d60080e7          	jalr	-672(ra) # 80003218 <brelse>
}
    800034c0:	8526                	mv	a0,s1
    800034c2:	60e6                	ld	ra,88(sp)
    800034c4:	6446                	ld	s0,80(sp)
    800034c6:	64a6                	ld	s1,72(sp)
    800034c8:	6906                	ld	s2,64(sp)
    800034ca:	79e2                	ld	s3,56(sp)
    800034cc:	7a42                	ld	s4,48(sp)
    800034ce:	7aa2                	ld	s5,40(sp)
    800034d0:	7b02                	ld	s6,32(sp)
    800034d2:	6be2                	ld	s7,24(sp)
    800034d4:	6c42                	ld	s8,16(sp)
    800034d6:	6ca2                	ld	s9,8(sp)
    800034d8:	6125                	addi	sp,sp,96
    800034da:	8082                	ret

00000000800034dc <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800034dc:	7179                	addi	sp,sp,-48
    800034de:	f406                	sd	ra,40(sp)
    800034e0:	f022                	sd	s0,32(sp)
    800034e2:	ec26                	sd	s1,24(sp)
    800034e4:	e84a                	sd	s2,16(sp)
    800034e6:	e44e                	sd	s3,8(sp)
    800034e8:	e052                	sd	s4,0(sp)
    800034ea:	1800                	addi	s0,sp,48
    800034ec:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034ee:	47ad                	li	a5,11
    800034f0:	04b7fe63          	bgeu	a5,a1,8000354c <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800034f4:	ff45849b          	addiw	s1,a1,-12
    800034f8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034fc:	0ff00793          	li	a5,255
    80003500:	0ae7e363          	bltu	a5,a4,800035a6 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003504:	08052583          	lw	a1,128(a0)
    80003508:	c5ad                	beqz	a1,80003572 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000350a:	00092503          	lw	a0,0(s2)
    8000350e:	00000097          	auipc	ra,0x0
    80003512:	bda080e7          	jalr	-1062(ra) # 800030e8 <bread>
    80003516:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003518:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000351c:	02049593          	slli	a1,s1,0x20
    80003520:	9181                	srli	a1,a1,0x20
    80003522:	058a                	slli	a1,a1,0x2
    80003524:	00b784b3          	add	s1,a5,a1
    80003528:	0004a983          	lw	s3,0(s1)
    8000352c:	04098d63          	beqz	s3,80003586 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003530:	8552                	mv	a0,s4
    80003532:	00000097          	auipc	ra,0x0
    80003536:	ce6080e7          	jalr	-794(ra) # 80003218 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000353a:	854e                	mv	a0,s3
    8000353c:	70a2                	ld	ra,40(sp)
    8000353e:	7402                	ld	s0,32(sp)
    80003540:	64e2                	ld	s1,24(sp)
    80003542:	6942                	ld	s2,16(sp)
    80003544:	69a2                	ld	s3,8(sp)
    80003546:	6a02                	ld	s4,0(sp)
    80003548:	6145                	addi	sp,sp,48
    8000354a:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000354c:	02059493          	slli	s1,a1,0x20
    80003550:	9081                	srli	s1,s1,0x20
    80003552:	048a                	slli	s1,s1,0x2
    80003554:	94aa                	add	s1,s1,a0
    80003556:	0504a983          	lw	s3,80(s1)
    8000355a:	fe0990e3          	bnez	s3,8000353a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000355e:	4108                	lw	a0,0(a0)
    80003560:	00000097          	auipc	ra,0x0
    80003564:	e4a080e7          	jalr	-438(ra) # 800033aa <balloc>
    80003568:	0005099b          	sext.w	s3,a0
    8000356c:	0534a823          	sw	s3,80(s1)
    80003570:	b7e9                	j	8000353a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003572:	4108                	lw	a0,0(a0)
    80003574:	00000097          	auipc	ra,0x0
    80003578:	e36080e7          	jalr	-458(ra) # 800033aa <balloc>
    8000357c:	0005059b          	sext.w	a1,a0
    80003580:	08b92023          	sw	a1,128(s2)
    80003584:	b759                	j	8000350a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003586:	00092503          	lw	a0,0(s2)
    8000358a:	00000097          	auipc	ra,0x0
    8000358e:	e20080e7          	jalr	-480(ra) # 800033aa <balloc>
    80003592:	0005099b          	sext.w	s3,a0
    80003596:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000359a:	8552                	mv	a0,s4
    8000359c:	00001097          	auipc	ra,0x1
    800035a0:	ee0080e7          	jalr	-288(ra) # 8000447c <log_write>
    800035a4:	b771                	j	80003530 <bmap+0x54>
  panic("bmap: out of range");
    800035a6:	00005517          	auipc	a0,0x5
    800035aa:	f5a50513          	addi	a0,a0,-166 # 80008500 <syscalls+0x128>
    800035ae:	ffffd097          	auipc	ra,0xffffd
    800035b2:	f94080e7          	jalr	-108(ra) # 80000542 <panic>

00000000800035b6 <iget>:
{
    800035b6:	7179                	addi	sp,sp,-48
    800035b8:	f406                	sd	ra,40(sp)
    800035ba:	f022                	sd	s0,32(sp)
    800035bc:	ec26                	sd	s1,24(sp)
    800035be:	e84a                	sd	s2,16(sp)
    800035c0:	e44e                	sd	s3,8(sp)
    800035c2:	e052                	sd	s4,0(sp)
    800035c4:	1800                	addi	s0,sp,48
    800035c6:	89aa                	mv	s3,a0
    800035c8:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800035ca:	0001d517          	auipc	a0,0x1d
    800035ce:	29650513          	addi	a0,a0,662 # 80020860 <icache>
    800035d2:	ffffd097          	auipc	ra,0xffffd
    800035d6:	698080e7          	jalr	1688(ra) # 80000c6a <acquire>
  empty = 0;
    800035da:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800035dc:	0001d497          	auipc	s1,0x1d
    800035e0:	29c48493          	addi	s1,s1,668 # 80020878 <icache+0x18>
    800035e4:	0001f697          	auipc	a3,0x1f
    800035e8:	d2468693          	addi	a3,a3,-732 # 80022308 <log>
    800035ec:	a039                	j	800035fa <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035ee:	02090b63          	beqz	s2,80003624 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800035f2:	08848493          	addi	s1,s1,136
    800035f6:	02d48a63          	beq	s1,a3,8000362a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035fa:	449c                	lw	a5,8(s1)
    800035fc:	fef059e3          	blez	a5,800035ee <iget+0x38>
    80003600:	4098                	lw	a4,0(s1)
    80003602:	ff3716e3          	bne	a4,s3,800035ee <iget+0x38>
    80003606:	40d8                	lw	a4,4(s1)
    80003608:	ff4713e3          	bne	a4,s4,800035ee <iget+0x38>
      ip->ref++;
    8000360c:	2785                	addiw	a5,a5,1
    8000360e:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003610:	0001d517          	auipc	a0,0x1d
    80003614:	25050513          	addi	a0,a0,592 # 80020860 <icache>
    80003618:	ffffd097          	auipc	ra,0xffffd
    8000361c:	706080e7          	jalr	1798(ra) # 80000d1e <release>
      return ip;
    80003620:	8926                	mv	s2,s1
    80003622:	a03d                	j	80003650 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003624:	f7f9                	bnez	a5,800035f2 <iget+0x3c>
    80003626:	8926                	mv	s2,s1
    80003628:	b7e9                	j	800035f2 <iget+0x3c>
  if(empty == 0)
    8000362a:	02090c63          	beqz	s2,80003662 <iget+0xac>
  ip->dev = dev;
    8000362e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003632:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003636:	4785                	li	a5,1
    80003638:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000363c:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003640:	0001d517          	auipc	a0,0x1d
    80003644:	22050513          	addi	a0,a0,544 # 80020860 <icache>
    80003648:	ffffd097          	auipc	ra,0xffffd
    8000364c:	6d6080e7          	jalr	1750(ra) # 80000d1e <release>
}
    80003650:	854a                	mv	a0,s2
    80003652:	70a2                	ld	ra,40(sp)
    80003654:	7402                	ld	s0,32(sp)
    80003656:	64e2                	ld	s1,24(sp)
    80003658:	6942                	ld	s2,16(sp)
    8000365a:	69a2                	ld	s3,8(sp)
    8000365c:	6a02                	ld	s4,0(sp)
    8000365e:	6145                	addi	sp,sp,48
    80003660:	8082                	ret
    panic("iget: no inodes");
    80003662:	00005517          	auipc	a0,0x5
    80003666:	eb650513          	addi	a0,a0,-330 # 80008518 <syscalls+0x140>
    8000366a:	ffffd097          	auipc	ra,0xffffd
    8000366e:	ed8080e7          	jalr	-296(ra) # 80000542 <panic>

0000000080003672 <fsinit>:
fsinit(int dev) {
    80003672:	7179                	addi	sp,sp,-48
    80003674:	f406                	sd	ra,40(sp)
    80003676:	f022                	sd	s0,32(sp)
    80003678:	ec26                	sd	s1,24(sp)
    8000367a:	e84a                	sd	s2,16(sp)
    8000367c:	e44e                	sd	s3,8(sp)
    8000367e:	1800                	addi	s0,sp,48
    80003680:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003682:	4585                	li	a1,1
    80003684:	00000097          	auipc	ra,0x0
    80003688:	a64080e7          	jalr	-1436(ra) # 800030e8 <bread>
    8000368c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000368e:	0001d997          	auipc	s3,0x1d
    80003692:	1b298993          	addi	s3,s3,434 # 80020840 <sb>
    80003696:	02000613          	li	a2,32
    8000369a:	05850593          	addi	a1,a0,88
    8000369e:	854e                	mv	a0,s3
    800036a0:	ffffd097          	auipc	ra,0xffffd
    800036a4:	722080e7          	jalr	1826(ra) # 80000dc2 <memmove>
  brelse(bp);
    800036a8:	8526                	mv	a0,s1
    800036aa:	00000097          	auipc	ra,0x0
    800036ae:	b6e080e7          	jalr	-1170(ra) # 80003218 <brelse>
  if(sb.magic != FSMAGIC)
    800036b2:	0009a703          	lw	a4,0(s3)
    800036b6:	102037b7          	lui	a5,0x10203
    800036ba:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036be:	02f71263          	bne	a4,a5,800036e2 <fsinit+0x70>
  initlog(dev, &sb);
    800036c2:	0001d597          	auipc	a1,0x1d
    800036c6:	17e58593          	addi	a1,a1,382 # 80020840 <sb>
    800036ca:	854a                	mv	a0,s2
    800036cc:	00001097          	auipc	ra,0x1
    800036d0:	b38080e7          	jalr	-1224(ra) # 80004204 <initlog>
}
    800036d4:	70a2                	ld	ra,40(sp)
    800036d6:	7402                	ld	s0,32(sp)
    800036d8:	64e2                	ld	s1,24(sp)
    800036da:	6942                	ld	s2,16(sp)
    800036dc:	69a2                	ld	s3,8(sp)
    800036de:	6145                	addi	sp,sp,48
    800036e0:	8082                	ret
    panic("invalid file system");
    800036e2:	00005517          	auipc	a0,0x5
    800036e6:	e4650513          	addi	a0,a0,-442 # 80008528 <syscalls+0x150>
    800036ea:	ffffd097          	auipc	ra,0xffffd
    800036ee:	e58080e7          	jalr	-424(ra) # 80000542 <panic>

00000000800036f2 <iinit>:
{
    800036f2:	7179                	addi	sp,sp,-48
    800036f4:	f406                	sd	ra,40(sp)
    800036f6:	f022                	sd	s0,32(sp)
    800036f8:	ec26                	sd	s1,24(sp)
    800036fa:	e84a                	sd	s2,16(sp)
    800036fc:	e44e                	sd	s3,8(sp)
    800036fe:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003700:	00005597          	auipc	a1,0x5
    80003704:	e4058593          	addi	a1,a1,-448 # 80008540 <syscalls+0x168>
    80003708:	0001d517          	auipc	a0,0x1d
    8000370c:	15850513          	addi	a0,a0,344 # 80020860 <icache>
    80003710:	ffffd097          	auipc	ra,0xffffd
    80003714:	4ca080e7          	jalr	1226(ra) # 80000bda <initlock>
  for(i = 0; i < NINODE; i++) {
    80003718:	0001d497          	auipc	s1,0x1d
    8000371c:	17048493          	addi	s1,s1,368 # 80020888 <icache+0x28>
    80003720:	0001f997          	auipc	s3,0x1f
    80003724:	bf898993          	addi	s3,s3,-1032 # 80022318 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003728:	00005917          	auipc	s2,0x5
    8000372c:	e2090913          	addi	s2,s2,-480 # 80008548 <syscalls+0x170>
    80003730:	85ca                	mv	a1,s2
    80003732:	8526                	mv	a0,s1
    80003734:	00001097          	auipc	ra,0x1
    80003738:	e36080e7          	jalr	-458(ra) # 8000456a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000373c:	08848493          	addi	s1,s1,136
    80003740:	ff3498e3          	bne	s1,s3,80003730 <iinit+0x3e>
}
    80003744:	70a2                	ld	ra,40(sp)
    80003746:	7402                	ld	s0,32(sp)
    80003748:	64e2                	ld	s1,24(sp)
    8000374a:	6942                	ld	s2,16(sp)
    8000374c:	69a2                	ld	s3,8(sp)
    8000374e:	6145                	addi	sp,sp,48
    80003750:	8082                	ret

0000000080003752 <ialloc>:
{
    80003752:	715d                	addi	sp,sp,-80
    80003754:	e486                	sd	ra,72(sp)
    80003756:	e0a2                	sd	s0,64(sp)
    80003758:	fc26                	sd	s1,56(sp)
    8000375a:	f84a                	sd	s2,48(sp)
    8000375c:	f44e                	sd	s3,40(sp)
    8000375e:	f052                	sd	s4,32(sp)
    80003760:	ec56                	sd	s5,24(sp)
    80003762:	e85a                	sd	s6,16(sp)
    80003764:	e45e                	sd	s7,8(sp)
    80003766:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003768:	0001d717          	auipc	a4,0x1d
    8000376c:	0e472703          	lw	a4,228(a4) # 8002084c <sb+0xc>
    80003770:	4785                	li	a5,1
    80003772:	04e7fa63          	bgeu	a5,a4,800037c6 <ialloc+0x74>
    80003776:	8aaa                	mv	s5,a0
    80003778:	8bae                	mv	s7,a1
    8000377a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000377c:	0001da17          	auipc	s4,0x1d
    80003780:	0c4a0a13          	addi	s4,s4,196 # 80020840 <sb>
    80003784:	00048b1b          	sext.w	s6,s1
    80003788:	0044d793          	srli	a5,s1,0x4
    8000378c:	018a2583          	lw	a1,24(s4)
    80003790:	9dbd                	addw	a1,a1,a5
    80003792:	8556                	mv	a0,s5
    80003794:	00000097          	auipc	ra,0x0
    80003798:	954080e7          	jalr	-1708(ra) # 800030e8 <bread>
    8000379c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000379e:	05850993          	addi	s3,a0,88
    800037a2:	00f4f793          	andi	a5,s1,15
    800037a6:	079a                	slli	a5,a5,0x6
    800037a8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037aa:	00099783          	lh	a5,0(s3)
    800037ae:	c785                	beqz	a5,800037d6 <ialloc+0x84>
    brelse(bp);
    800037b0:	00000097          	auipc	ra,0x0
    800037b4:	a68080e7          	jalr	-1432(ra) # 80003218 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037b8:	0485                	addi	s1,s1,1
    800037ba:	00ca2703          	lw	a4,12(s4)
    800037be:	0004879b          	sext.w	a5,s1
    800037c2:	fce7e1e3          	bltu	a5,a4,80003784 <ialloc+0x32>
  panic("ialloc: no inodes");
    800037c6:	00005517          	auipc	a0,0x5
    800037ca:	d8a50513          	addi	a0,a0,-630 # 80008550 <syscalls+0x178>
    800037ce:	ffffd097          	auipc	ra,0xffffd
    800037d2:	d74080e7          	jalr	-652(ra) # 80000542 <panic>
      memset(dip, 0, sizeof(*dip));
    800037d6:	04000613          	li	a2,64
    800037da:	4581                	li	a1,0
    800037dc:	854e                	mv	a0,s3
    800037de:	ffffd097          	auipc	ra,0xffffd
    800037e2:	588080e7          	jalr	1416(ra) # 80000d66 <memset>
      dip->type = type;
    800037e6:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800037ea:	854a                	mv	a0,s2
    800037ec:	00001097          	auipc	ra,0x1
    800037f0:	c90080e7          	jalr	-880(ra) # 8000447c <log_write>
      brelse(bp);
    800037f4:	854a                	mv	a0,s2
    800037f6:	00000097          	auipc	ra,0x0
    800037fa:	a22080e7          	jalr	-1502(ra) # 80003218 <brelse>
      return iget(dev, inum);
    800037fe:	85da                	mv	a1,s6
    80003800:	8556                	mv	a0,s5
    80003802:	00000097          	auipc	ra,0x0
    80003806:	db4080e7          	jalr	-588(ra) # 800035b6 <iget>
}
    8000380a:	60a6                	ld	ra,72(sp)
    8000380c:	6406                	ld	s0,64(sp)
    8000380e:	74e2                	ld	s1,56(sp)
    80003810:	7942                	ld	s2,48(sp)
    80003812:	79a2                	ld	s3,40(sp)
    80003814:	7a02                	ld	s4,32(sp)
    80003816:	6ae2                	ld	s5,24(sp)
    80003818:	6b42                	ld	s6,16(sp)
    8000381a:	6ba2                	ld	s7,8(sp)
    8000381c:	6161                	addi	sp,sp,80
    8000381e:	8082                	ret

0000000080003820 <iupdate>:
{
    80003820:	1101                	addi	sp,sp,-32
    80003822:	ec06                	sd	ra,24(sp)
    80003824:	e822                	sd	s0,16(sp)
    80003826:	e426                	sd	s1,8(sp)
    80003828:	e04a                	sd	s2,0(sp)
    8000382a:	1000                	addi	s0,sp,32
    8000382c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000382e:	415c                	lw	a5,4(a0)
    80003830:	0047d79b          	srliw	a5,a5,0x4
    80003834:	0001d597          	auipc	a1,0x1d
    80003838:	0245a583          	lw	a1,36(a1) # 80020858 <sb+0x18>
    8000383c:	9dbd                	addw	a1,a1,a5
    8000383e:	4108                	lw	a0,0(a0)
    80003840:	00000097          	auipc	ra,0x0
    80003844:	8a8080e7          	jalr	-1880(ra) # 800030e8 <bread>
    80003848:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000384a:	05850793          	addi	a5,a0,88
    8000384e:	40c8                	lw	a0,4(s1)
    80003850:	893d                	andi	a0,a0,15
    80003852:	051a                	slli	a0,a0,0x6
    80003854:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003856:	04449703          	lh	a4,68(s1)
    8000385a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000385e:	04649703          	lh	a4,70(s1)
    80003862:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003866:	04849703          	lh	a4,72(s1)
    8000386a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000386e:	04a49703          	lh	a4,74(s1)
    80003872:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003876:	44f8                	lw	a4,76(s1)
    80003878:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000387a:	03400613          	li	a2,52
    8000387e:	05048593          	addi	a1,s1,80
    80003882:	0531                	addi	a0,a0,12
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	53e080e7          	jalr	1342(ra) # 80000dc2 <memmove>
  log_write(bp);
    8000388c:	854a                	mv	a0,s2
    8000388e:	00001097          	auipc	ra,0x1
    80003892:	bee080e7          	jalr	-1042(ra) # 8000447c <log_write>
  brelse(bp);
    80003896:	854a                	mv	a0,s2
    80003898:	00000097          	auipc	ra,0x0
    8000389c:	980080e7          	jalr	-1664(ra) # 80003218 <brelse>
}
    800038a0:	60e2                	ld	ra,24(sp)
    800038a2:	6442                	ld	s0,16(sp)
    800038a4:	64a2                	ld	s1,8(sp)
    800038a6:	6902                	ld	s2,0(sp)
    800038a8:	6105                	addi	sp,sp,32
    800038aa:	8082                	ret

00000000800038ac <idup>:
{
    800038ac:	1101                	addi	sp,sp,-32
    800038ae:	ec06                	sd	ra,24(sp)
    800038b0:	e822                	sd	s0,16(sp)
    800038b2:	e426                	sd	s1,8(sp)
    800038b4:	1000                	addi	s0,sp,32
    800038b6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800038b8:	0001d517          	auipc	a0,0x1d
    800038bc:	fa850513          	addi	a0,a0,-88 # 80020860 <icache>
    800038c0:	ffffd097          	auipc	ra,0xffffd
    800038c4:	3aa080e7          	jalr	938(ra) # 80000c6a <acquire>
  ip->ref++;
    800038c8:	449c                	lw	a5,8(s1)
    800038ca:	2785                	addiw	a5,a5,1
    800038cc:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800038ce:	0001d517          	auipc	a0,0x1d
    800038d2:	f9250513          	addi	a0,a0,-110 # 80020860 <icache>
    800038d6:	ffffd097          	auipc	ra,0xffffd
    800038da:	448080e7          	jalr	1096(ra) # 80000d1e <release>
}
    800038de:	8526                	mv	a0,s1
    800038e0:	60e2                	ld	ra,24(sp)
    800038e2:	6442                	ld	s0,16(sp)
    800038e4:	64a2                	ld	s1,8(sp)
    800038e6:	6105                	addi	sp,sp,32
    800038e8:	8082                	ret

00000000800038ea <ilock>:
{
    800038ea:	1101                	addi	sp,sp,-32
    800038ec:	ec06                	sd	ra,24(sp)
    800038ee:	e822                	sd	s0,16(sp)
    800038f0:	e426                	sd	s1,8(sp)
    800038f2:	e04a                	sd	s2,0(sp)
    800038f4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800038f6:	c115                	beqz	a0,8000391a <ilock+0x30>
    800038f8:	84aa                	mv	s1,a0
    800038fa:	451c                	lw	a5,8(a0)
    800038fc:	00f05f63          	blez	a5,8000391a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003900:	0541                	addi	a0,a0,16
    80003902:	00001097          	auipc	ra,0x1
    80003906:	ca2080e7          	jalr	-862(ra) # 800045a4 <acquiresleep>
  if(ip->valid == 0){
    8000390a:	40bc                	lw	a5,64(s1)
    8000390c:	cf99                	beqz	a5,8000392a <ilock+0x40>
}
    8000390e:	60e2                	ld	ra,24(sp)
    80003910:	6442                	ld	s0,16(sp)
    80003912:	64a2                	ld	s1,8(sp)
    80003914:	6902                	ld	s2,0(sp)
    80003916:	6105                	addi	sp,sp,32
    80003918:	8082                	ret
    panic("ilock");
    8000391a:	00005517          	auipc	a0,0x5
    8000391e:	c4e50513          	addi	a0,a0,-946 # 80008568 <syscalls+0x190>
    80003922:	ffffd097          	auipc	ra,0xffffd
    80003926:	c20080e7          	jalr	-992(ra) # 80000542 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000392a:	40dc                	lw	a5,4(s1)
    8000392c:	0047d79b          	srliw	a5,a5,0x4
    80003930:	0001d597          	auipc	a1,0x1d
    80003934:	f285a583          	lw	a1,-216(a1) # 80020858 <sb+0x18>
    80003938:	9dbd                	addw	a1,a1,a5
    8000393a:	4088                	lw	a0,0(s1)
    8000393c:	fffff097          	auipc	ra,0xfffff
    80003940:	7ac080e7          	jalr	1964(ra) # 800030e8 <bread>
    80003944:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003946:	05850593          	addi	a1,a0,88
    8000394a:	40dc                	lw	a5,4(s1)
    8000394c:	8bbd                	andi	a5,a5,15
    8000394e:	079a                	slli	a5,a5,0x6
    80003950:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003952:	00059783          	lh	a5,0(a1)
    80003956:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000395a:	00259783          	lh	a5,2(a1)
    8000395e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003962:	00459783          	lh	a5,4(a1)
    80003966:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000396a:	00659783          	lh	a5,6(a1)
    8000396e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003972:	459c                	lw	a5,8(a1)
    80003974:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003976:	03400613          	li	a2,52
    8000397a:	05b1                	addi	a1,a1,12
    8000397c:	05048513          	addi	a0,s1,80
    80003980:	ffffd097          	auipc	ra,0xffffd
    80003984:	442080e7          	jalr	1090(ra) # 80000dc2 <memmove>
    brelse(bp);
    80003988:	854a                	mv	a0,s2
    8000398a:	00000097          	auipc	ra,0x0
    8000398e:	88e080e7          	jalr	-1906(ra) # 80003218 <brelse>
    ip->valid = 1;
    80003992:	4785                	li	a5,1
    80003994:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003996:	04449783          	lh	a5,68(s1)
    8000399a:	fbb5                	bnez	a5,8000390e <ilock+0x24>
      panic("ilock: no type");
    8000399c:	00005517          	auipc	a0,0x5
    800039a0:	bd450513          	addi	a0,a0,-1068 # 80008570 <syscalls+0x198>
    800039a4:	ffffd097          	auipc	ra,0xffffd
    800039a8:	b9e080e7          	jalr	-1122(ra) # 80000542 <panic>

00000000800039ac <iunlock>:
{
    800039ac:	1101                	addi	sp,sp,-32
    800039ae:	ec06                	sd	ra,24(sp)
    800039b0:	e822                	sd	s0,16(sp)
    800039b2:	e426                	sd	s1,8(sp)
    800039b4:	e04a                	sd	s2,0(sp)
    800039b6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039b8:	c905                	beqz	a0,800039e8 <iunlock+0x3c>
    800039ba:	84aa                	mv	s1,a0
    800039bc:	01050913          	addi	s2,a0,16
    800039c0:	854a                	mv	a0,s2
    800039c2:	00001097          	auipc	ra,0x1
    800039c6:	c7c080e7          	jalr	-900(ra) # 8000463e <holdingsleep>
    800039ca:	cd19                	beqz	a0,800039e8 <iunlock+0x3c>
    800039cc:	449c                	lw	a5,8(s1)
    800039ce:	00f05d63          	blez	a5,800039e8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800039d2:	854a                	mv	a0,s2
    800039d4:	00001097          	auipc	ra,0x1
    800039d8:	c26080e7          	jalr	-986(ra) # 800045fa <releasesleep>
}
    800039dc:	60e2                	ld	ra,24(sp)
    800039de:	6442                	ld	s0,16(sp)
    800039e0:	64a2                	ld	s1,8(sp)
    800039e2:	6902                	ld	s2,0(sp)
    800039e4:	6105                	addi	sp,sp,32
    800039e6:	8082                	ret
    panic("iunlock");
    800039e8:	00005517          	auipc	a0,0x5
    800039ec:	b9850513          	addi	a0,a0,-1128 # 80008580 <syscalls+0x1a8>
    800039f0:	ffffd097          	auipc	ra,0xffffd
    800039f4:	b52080e7          	jalr	-1198(ra) # 80000542 <panic>

00000000800039f8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800039f8:	7179                	addi	sp,sp,-48
    800039fa:	f406                	sd	ra,40(sp)
    800039fc:	f022                	sd	s0,32(sp)
    800039fe:	ec26                	sd	s1,24(sp)
    80003a00:	e84a                	sd	s2,16(sp)
    80003a02:	e44e                	sd	s3,8(sp)
    80003a04:	e052                	sd	s4,0(sp)
    80003a06:	1800                	addi	s0,sp,48
    80003a08:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a0a:	05050493          	addi	s1,a0,80
    80003a0e:	08050913          	addi	s2,a0,128
    80003a12:	a021                	j	80003a1a <itrunc+0x22>
    80003a14:	0491                	addi	s1,s1,4
    80003a16:	01248d63          	beq	s1,s2,80003a30 <itrunc+0x38>
    if(ip->addrs[i]){
    80003a1a:	408c                	lw	a1,0(s1)
    80003a1c:	dde5                	beqz	a1,80003a14 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a1e:	0009a503          	lw	a0,0(s3)
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	90c080e7          	jalr	-1780(ra) # 8000332e <bfree>
      ip->addrs[i] = 0;
    80003a2a:	0004a023          	sw	zero,0(s1)
    80003a2e:	b7dd                	j	80003a14 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a30:	0809a583          	lw	a1,128(s3)
    80003a34:	e185                	bnez	a1,80003a54 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a36:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a3a:	854e                	mv	a0,s3
    80003a3c:	00000097          	auipc	ra,0x0
    80003a40:	de4080e7          	jalr	-540(ra) # 80003820 <iupdate>
}
    80003a44:	70a2                	ld	ra,40(sp)
    80003a46:	7402                	ld	s0,32(sp)
    80003a48:	64e2                	ld	s1,24(sp)
    80003a4a:	6942                	ld	s2,16(sp)
    80003a4c:	69a2                	ld	s3,8(sp)
    80003a4e:	6a02                	ld	s4,0(sp)
    80003a50:	6145                	addi	sp,sp,48
    80003a52:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a54:	0009a503          	lw	a0,0(s3)
    80003a58:	fffff097          	auipc	ra,0xfffff
    80003a5c:	690080e7          	jalr	1680(ra) # 800030e8 <bread>
    80003a60:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a62:	05850493          	addi	s1,a0,88
    80003a66:	45850913          	addi	s2,a0,1112
    80003a6a:	a021                	j	80003a72 <itrunc+0x7a>
    80003a6c:	0491                	addi	s1,s1,4
    80003a6e:	01248b63          	beq	s1,s2,80003a84 <itrunc+0x8c>
      if(a[j])
    80003a72:	408c                	lw	a1,0(s1)
    80003a74:	dde5                	beqz	a1,80003a6c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003a76:	0009a503          	lw	a0,0(s3)
    80003a7a:	00000097          	auipc	ra,0x0
    80003a7e:	8b4080e7          	jalr	-1868(ra) # 8000332e <bfree>
    80003a82:	b7ed                	j	80003a6c <itrunc+0x74>
    brelse(bp);
    80003a84:	8552                	mv	a0,s4
    80003a86:	fffff097          	auipc	ra,0xfffff
    80003a8a:	792080e7          	jalr	1938(ra) # 80003218 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a8e:	0809a583          	lw	a1,128(s3)
    80003a92:	0009a503          	lw	a0,0(s3)
    80003a96:	00000097          	auipc	ra,0x0
    80003a9a:	898080e7          	jalr	-1896(ra) # 8000332e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a9e:	0809a023          	sw	zero,128(s3)
    80003aa2:	bf51                	j	80003a36 <itrunc+0x3e>

0000000080003aa4 <iput>:
{
    80003aa4:	1101                	addi	sp,sp,-32
    80003aa6:	ec06                	sd	ra,24(sp)
    80003aa8:	e822                	sd	s0,16(sp)
    80003aaa:	e426                	sd	s1,8(sp)
    80003aac:	e04a                	sd	s2,0(sp)
    80003aae:	1000                	addi	s0,sp,32
    80003ab0:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003ab2:	0001d517          	auipc	a0,0x1d
    80003ab6:	dae50513          	addi	a0,a0,-594 # 80020860 <icache>
    80003aba:	ffffd097          	auipc	ra,0xffffd
    80003abe:	1b0080e7          	jalr	432(ra) # 80000c6a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ac2:	4498                	lw	a4,8(s1)
    80003ac4:	4785                	li	a5,1
    80003ac6:	02f70363          	beq	a4,a5,80003aec <iput+0x48>
  ip->ref--;
    80003aca:	449c                	lw	a5,8(s1)
    80003acc:	37fd                	addiw	a5,a5,-1
    80003ace:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003ad0:	0001d517          	auipc	a0,0x1d
    80003ad4:	d9050513          	addi	a0,a0,-624 # 80020860 <icache>
    80003ad8:	ffffd097          	auipc	ra,0xffffd
    80003adc:	246080e7          	jalr	582(ra) # 80000d1e <release>
}
    80003ae0:	60e2                	ld	ra,24(sp)
    80003ae2:	6442                	ld	s0,16(sp)
    80003ae4:	64a2                	ld	s1,8(sp)
    80003ae6:	6902                	ld	s2,0(sp)
    80003ae8:	6105                	addi	sp,sp,32
    80003aea:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003aec:	40bc                	lw	a5,64(s1)
    80003aee:	dff1                	beqz	a5,80003aca <iput+0x26>
    80003af0:	04a49783          	lh	a5,74(s1)
    80003af4:	fbf9                	bnez	a5,80003aca <iput+0x26>
    acquiresleep(&ip->lock);
    80003af6:	01048913          	addi	s2,s1,16
    80003afa:	854a                	mv	a0,s2
    80003afc:	00001097          	auipc	ra,0x1
    80003b00:	aa8080e7          	jalr	-1368(ra) # 800045a4 <acquiresleep>
    release(&icache.lock);
    80003b04:	0001d517          	auipc	a0,0x1d
    80003b08:	d5c50513          	addi	a0,a0,-676 # 80020860 <icache>
    80003b0c:	ffffd097          	auipc	ra,0xffffd
    80003b10:	212080e7          	jalr	530(ra) # 80000d1e <release>
    itrunc(ip);
    80003b14:	8526                	mv	a0,s1
    80003b16:	00000097          	auipc	ra,0x0
    80003b1a:	ee2080e7          	jalr	-286(ra) # 800039f8 <itrunc>
    ip->type = 0;
    80003b1e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b22:	8526                	mv	a0,s1
    80003b24:	00000097          	auipc	ra,0x0
    80003b28:	cfc080e7          	jalr	-772(ra) # 80003820 <iupdate>
    ip->valid = 0;
    80003b2c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b30:	854a                	mv	a0,s2
    80003b32:	00001097          	auipc	ra,0x1
    80003b36:	ac8080e7          	jalr	-1336(ra) # 800045fa <releasesleep>
    acquire(&icache.lock);
    80003b3a:	0001d517          	auipc	a0,0x1d
    80003b3e:	d2650513          	addi	a0,a0,-730 # 80020860 <icache>
    80003b42:	ffffd097          	auipc	ra,0xffffd
    80003b46:	128080e7          	jalr	296(ra) # 80000c6a <acquire>
    80003b4a:	b741                	j	80003aca <iput+0x26>

0000000080003b4c <iunlockput>:
{
    80003b4c:	1101                	addi	sp,sp,-32
    80003b4e:	ec06                	sd	ra,24(sp)
    80003b50:	e822                	sd	s0,16(sp)
    80003b52:	e426                	sd	s1,8(sp)
    80003b54:	1000                	addi	s0,sp,32
    80003b56:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b58:	00000097          	auipc	ra,0x0
    80003b5c:	e54080e7          	jalr	-428(ra) # 800039ac <iunlock>
  iput(ip);
    80003b60:	8526                	mv	a0,s1
    80003b62:	00000097          	auipc	ra,0x0
    80003b66:	f42080e7          	jalr	-190(ra) # 80003aa4 <iput>
}
    80003b6a:	60e2                	ld	ra,24(sp)
    80003b6c:	6442                	ld	s0,16(sp)
    80003b6e:	64a2                	ld	s1,8(sp)
    80003b70:	6105                	addi	sp,sp,32
    80003b72:	8082                	ret

0000000080003b74 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b74:	1141                	addi	sp,sp,-16
    80003b76:	e422                	sd	s0,8(sp)
    80003b78:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b7a:	411c                	lw	a5,0(a0)
    80003b7c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b7e:	415c                	lw	a5,4(a0)
    80003b80:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b82:	04451783          	lh	a5,68(a0)
    80003b86:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b8a:	04a51783          	lh	a5,74(a0)
    80003b8e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b92:	04c56783          	lwu	a5,76(a0)
    80003b96:	e99c                	sd	a5,16(a1)
}
    80003b98:	6422                	ld	s0,8(sp)
    80003b9a:	0141                	addi	sp,sp,16
    80003b9c:	8082                	ret

0000000080003b9e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b9e:	457c                	lw	a5,76(a0)
    80003ba0:	0ed7e863          	bltu	a5,a3,80003c90 <readi+0xf2>
{
    80003ba4:	7159                	addi	sp,sp,-112
    80003ba6:	f486                	sd	ra,104(sp)
    80003ba8:	f0a2                	sd	s0,96(sp)
    80003baa:	eca6                	sd	s1,88(sp)
    80003bac:	e8ca                	sd	s2,80(sp)
    80003bae:	e4ce                	sd	s3,72(sp)
    80003bb0:	e0d2                	sd	s4,64(sp)
    80003bb2:	fc56                	sd	s5,56(sp)
    80003bb4:	f85a                	sd	s6,48(sp)
    80003bb6:	f45e                	sd	s7,40(sp)
    80003bb8:	f062                	sd	s8,32(sp)
    80003bba:	ec66                	sd	s9,24(sp)
    80003bbc:	e86a                	sd	s10,16(sp)
    80003bbe:	e46e                	sd	s11,8(sp)
    80003bc0:	1880                	addi	s0,sp,112
    80003bc2:	8baa                	mv	s7,a0
    80003bc4:	8c2e                	mv	s8,a1
    80003bc6:	8ab2                	mv	s5,a2
    80003bc8:	84b6                	mv	s1,a3
    80003bca:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bcc:	9f35                	addw	a4,a4,a3
    return 0;
    80003bce:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003bd0:	08d76f63          	bltu	a4,a3,80003c6e <readi+0xd0>
  if(off + n > ip->size)
    80003bd4:	00e7f463          	bgeu	a5,a4,80003bdc <readi+0x3e>
    n = ip->size - off;
    80003bd8:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bdc:	0a0b0863          	beqz	s6,80003c8c <readi+0xee>
    80003be0:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003be2:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003be6:	5cfd                	li	s9,-1
    80003be8:	a82d                	j	80003c22 <readi+0x84>
    80003bea:	020a1d93          	slli	s11,s4,0x20
    80003bee:	020ddd93          	srli	s11,s11,0x20
    80003bf2:	05890793          	addi	a5,s2,88
    80003bf6:	86ee                	mv	a3,s11
    80003bf8:	963e                	add	a2,a2,a5
    80003bfa:	85d6                	mv	a1,s5
    80003bfc:	8562                	mv	a0,s8
    80003bfe:	fffff097          	auipc	ra,0xfffff
    80003c02:	8fe080e7          	jalr	-1794(ra) # 800024fc <either_copyout>
    80003c06:	05950d63          	beq	a0,s9,80003c60 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003c0a:	854a                	mv	a0,s2
    80003c0c:	fffff097          	auipc	ra,0xfffff
    80003c10:	60c080e7          	jalr	1548(ra) # 80003218 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c14:	013a09bb          	addw	s3,s4,s3
    80003c18:	009a04bb          	addw	s1,s4,s1
    80003c1c:	9aee                	add	s5,s5,s11
    80003c1e:	0569f663          	bgeu	s3,s6,80003c6a <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c22:	000ba903          	lw	s2,0(s7)
    80003c26:	00a4d59b          	srliw	a1,s1,0xa
    80003c2a:	855e                	mv	a0,s7
    80003c2c:	00000097          	auipc	ra,0x0
    80003c30:	8b0080e7          	jalr	-1872(ra) # 800034dc <bmap>
    80003c34:	0005059b          	sext.w	a1,a0
    80003c38:	854a                	mv	a0,s2
    80003c3a:	fffff097          	auipc	ra,0xfffff
    80003c3e:	4ae080e7          	jalr	1198(ra) # 800030e8 <bread>
    80003c42:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c44:	3ff4f613          	andi	a2,s1,1023
    80003c48:	40cd07bb          	subw	a5,s10,a2
    80003c4c:	413b073b          	subw	a4,s6,s3
    80003c50:	8a3e                	mv	s4,a5
    80003c52:	2781                	sext.w	a5,a5
    80003c54:	0007069b          	sext.w	a3,a4
    80003c58:	f8f6f9e3          	bgeu	a3,a5,80003bea <readi+0x4c>
    80003c5c:	8a3a                	mv	s4,a4
    80003c5e:	b771                	j	80003bea <readi+0x4c>
      brelse(bp);
    80003c60:	854a                	mv	a0,s2
    80003c62:	fffff097          	auipc	ra,0xfffff
    80003c66:	5b6080e7          	jalr	1462(ra) # 80003218 <brelse>
  }
  return tot;
    80003c6a:	0009851b          	sext.w	a0,s3
}
    80003c6e:	70a6                	ld	ra,104(sp)
    80003c70:	7406                	ld	s0,96(sp)
    80003c72:	64e6                	ld	s1,88(sp)
    80003c74:	6946                	ld	s2,80(sp)
    80003c76:	69a6                	ld	s3,72(sp)
    80003c78:	6a06                	ld	s4,64(sp)
    80003c7a:	7ae2                	ld	s5,56(sp)
    80003c7c:	7b42                	ld	s6,48(sp)
    80003c7e:	7ba2                	ld	s7,40(sp)
    80003c80:	7c02                	ld	s8,32(sp)
    80003c82:	6ce2                	ld	s9,24(sp)
    80003c84:	6d42                	ld	s10,16(sp)
    80003c86:	6da2                	ld	s11,8(sp)
    80003c88:	6165                	addi	sp,sp,112
    80003c8a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c8c:	89da                	mv	s3,s6
    80003c8e:	bff1                	j	80003c6a <readi+0xcc>
    return 0;
    80003c90:	4501                	li	a0,0
}
    80003c92:	8082                	ret

0000000080003c94 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c94:	457c                	lw	a5,76(a0)
    80003c96:	10d7e663          	bltu	a5,a3,80003da2 <writei+0x10e>
{
    80003c9a:	7159                	addi	sp,sp,-112
    80003c9c:	f486                	sd	ra,104(sp)
    80003c9e:	f0a2                	sd	s0,96(sp)
    80003ca0:	eca6                	sd	s1,88(sp)
    80003ca2:	e8ca                	sd	s2,80(sp)
    80003ca4:	e4ce                	sd	s3,72(sp)
    80003ca6:	e0d2                	sd	s4,64(sp)
    80003ca8:	fc56                	sd	s5,56(sp)
    80003caa:	f85a                	sd	s6,48(sp)
    80003cac:	f45e                	sd	s7,40(sp)
    80003cae:	f062                	sd	s8,32(sp)
    80003cb0:	ec66                	sd	s9,24(sp)
    80003cb2:	e86a                	sd	s10,16(sp)
    80003cb4:	e46e                	sd	s11,8(sp)
    80003cb6:	1880                	addi	s0,sp,112
    80003cb8:	8baa                	mv	s7,a0
    80003cba:	8c2e                	mv	s8,a1
    80003cbc:	8ab2                	mv	s5,a2
    80003cbe:	8936                	mv	s2,a3
    80003cc0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cc2:	00e687bb          	addw	a5,a3,a4
    80003cc6:	0ed7e063          	bltu	a5,a3,80003da6 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cca:	00043737          	lui	a4,0x43
    80003cce:	0cf76e63          	bltu	a4,a5,80003daa <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cd2:	0a0b0763          	beqz	s6,80003d80 <writei+0xec>
    80003cd6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cd8:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003cdc:	5cfd                	li	s9,-1
    80003cde:	a091                	j	80003d22 <writei+0x8e>
    80003ce0:	02099d93          	slli	s11,s3,0x20
    80003ce4:	020ddd93          	srli	s11,s11,0x20
    80003ce8:	05848793          	addi	a5,s1,88
    80003cec:	86ee                	mv	a3,s11
    80003cee:	8656                	mv	a2,s5
    80003cf0:	85e2                	mv	a1,s8
    80003cf2:	953e                	add	a0,a0,a5
    80003cf4:	fffff097          	auipc	ra,0xfffff
    80003cf8:	85e080e7          	jalr	-1954(ra) # 80002552 <either_copyin>
    80003cfc:	07950263          	beq	a0,s9,80003d60 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d00:	8526                	mv	a0,s1
    80003d02:	00000097          	auipc	ra,0x0
    80003d06:	77a080e7          	jalr	1914(ra) # 8000447c <log_write>
    brelse(bp);
    80003d0a:	8526                	mv	a0,s1
    80003d0c:	fffff097          	auipc	ra,0xfffff
    80003d10:	50c080e7          	jalr	1292(ra) # 80003218 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d14:	01498a3b          	addw	s4,s3,s4
    80003d18:	0129893b          	addw	s2,s3,s2
    80003d1c:	9aee                	add	s5,s5,s11
    80003d1e:	056a7663          	bgeu	s4,s6,80003d6a <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d22:	000ba483          	lw	s1,0(s7)
    80003d26:	00a9559b          	srliw	a1,s2,0xa
    80003d2a:	855e                	mv	a0,s7
    80003d2c:	fffff097          	auipc	ra,0xfffff
    80003d30:	7b0080e7          	jalr	1968(ra) # 800034dc <bmap>
    80003d34:	0005059b          	sext.w	a1,a0
    80003d38:	8526                	mv	a0,s1
    80003d3a:	fffff097          	auipc	ra,0xfffff
    80003d3e:	3ae080e7          	jalr	942(ra) # 800030e8 <bread>
    80003d42:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d44:	3ff97513          	andi	a0,s2,1023
    80003d48:	40ad07bb          	subw	a5,s10,a0
    80003d4c:	414b073b          	subw	a4,s6,s4
    80003d50:	89be                	mv	s3,a5
    80003d52:	2781                	sext.w	a5,a5
    80003d54:	0007069b          	sext.w	a3,a4
    80003d58:	f8f6f4e3          	bgeu	a3,a5,80003ce0 <writei+0x4c>
    80003d5c:	89ba                	mv	s3,a4
    80003d5e:	b749                	j	80003ce0 <writei+0x4c>
      brelse(bp);
    80003d60:	8526                	mv	a0,s1
    80003d62:	fffff097          	auipc	ra,0xfffff
    80003d66:	4b6080e7          	jalr	1206(ra) # 80003218 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003d6a:	04cba783          	lw	a5,76(s7)
    80003d6e:	0127f463          	bgeu	a5,s2,80003d76 <writei+0xe2>
      ip->size = off;
    80003d72:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003d76:	855e                	mv	a0,s7
    80003d78:	00000097          	auipc	ra,0x0
    80003d7c:	aa8080e7          	jalr	-1368(ra) # 80003820 <iupdate>
  }

  return n;
    80003d80:	000b051b          	sext.w	a0,s6
}
    80003d84:	70a6                	ld	ra,104(sp)
    80003d86:	7406                	ld	s0,96(sp)
    80003d88:	64e6                	ld	s1,88(sp)
    80003d8a:	6946                	ld	s2,80(sp)
    80003d8c:	69a6                	ld	s3,72(sp)
    80003d8e:	6a06                	ld	s4,64(sp)
    80003d90:	7ae2                	ld	s5,56(sp)
    80003d92:	7b42                	ld	s6,48(sp)
    80003d94:	7ba2                	ld	s7,40(sp)
    80003d96:	7c02                	ld	s8,32(sp)
    80003d98:	6ce2                	ld	s9,24(sp)
    80003d9a:	6d42                	ld	s10,16(sp)
    80003d9c:	6da2                	ld	s11,8(sp)
    80003d9e:	6165                	addi	sp,sp,112
    80003da0:	8082                	ret
    return -1;
    80003da2:	557d                	li	a0,-1
}
    80003da4:	8082                	ret
    return -1;
    80003da6:	557d                	li	a0,-1
    80003da8:	bff1                	j	80003d84 <writei+0xf0>
    return -1;
    80003daa:	557d                	li	a0,-1
    80003dac:	bfe1                	j	80003d84 <writei+0xf0>

0000000080003dae <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003dae:	1141                	addi	sp,sp,-16
    80003db0:	e406                	sd	ra,8(sp)
    80003db2:	e022                	sd	s0,0(sp)
    80003db4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003db6:	4639                	li	a2,14
    80003db8:	ffffd097          	auipc	ra,0xffffd
    80003dbc:	086080e7          	jalr	134(ra) # 80000e3e <strncmp>
}
    80003dc0:	60a2                	ld	ra,8(sp)
    80003dc2:	6402                	ld	s0,0(sp)
    80003dc4:	0141                	addi	sp,sp,16
    80003dc6:	8082                	ret

0000000080003dc8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003dc8:	7139                	addi	sp,sp,-64
    80003dca:	fc06                	sd	ra,56(sp)
    80003dcc:	f822                	sd	s0,48(sp)
    80003dce:	f426                	sd	s1,40(sp)
    80003dd0:	f04a                	sd	s2,32(sp)
    80003dd2:	ec4e                	sd	s3,24(sp)
    80003dd4:	e852                	sd	s4,16(sp)
    80003dd6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003dd8:	04451703          	lh	a4,68(a0)
    80003ddc:	4785                	li	a5,1
    80003dde:	00f71a63          	bne	a4,a5,80003df2 <dirlookup+0x2a>
    80003de2:	892a                	mv	s2,a0
    80003de4:	89ae                	mv	s3,a1
    80003de6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003de8:	457c                	lw	a5,76(a0)
    80003dea:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003dec:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dee:	e79d                	bnez	a5,80003e1c <dirlookup+0x54>
    80003df0:	a8a5                	j	80003e68 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003df2:	00004517          	auipc	a0,0x4
    80003df6:	79650513          	addi	a0,a0,1942 # 80008588 <syscalls+0x1b0>
    80003dfa:	ffffc097          	auipc	ra,0xffffc
    80003dfe:	748080e7          	jalr	1864(ra) # 80000542 <panic>
      panic("dirlookup read");
    80003e02:	00004517          	auipc	a0,0x4
    80003e06:	79e50513          	addi	a0,a0,1950 # 800085a0 <syscalls+0x1c8>
    80003e0a:	ffffc097          	auipc	ra,0xffffc
    80003e0e:	738080e7          	jalr	1848(ra) # 80000542 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e12:	24c1                	addiw	s1,s1,16
    80003e14:	04c92783          	lw	a5,76(s2)
    80003e18:	04f4f763          	bgeu	s1,a5,80003e66 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e1c:	4741                	li	a4,16
    80003e1e:	86a6                	mv	a3,s1
    80003e20:	fc040613          	addi	a2,s0,-64
    80003e24:	4581                	li	a1,0
    80003e26:	854a                	mv	a0,s2
    80003e28:	00000097          	auipc	ra,0x0
    80003e2c:	d76080e7          	jalr	-650(ra) # 80003b9e <readi>
    80003e30:	47c1                	li	a5,16
    80003e32:	fcf518e3          	bne	a0,a5,80003e02 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e36:	fc045783          	lhu	a5,-64(s0)
    80003e3a:	dfe1                	beqz	a5,80003e12 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e3c:	fc240593          	addi	a1,s0,-62
    80003e40:	854e                	mv	a0,s3
    80003e42:	00000097          	auipc	ra,0x0
    80003e46:	f6c080e7          	jalr	-148(ra) # 80003dae <namecmp>
    80003e4a:	f561                	bnez	a0,80003e12 <dirlookup+0x4a>
      if(poff)
    80003e4c:	000a0463          	beqz	s4,80003e54 <dirlookup+0x8c>
        *poff = off;
    80003e50:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e54:	fc045583          	lhu	a1,-64(s0)
    80003e58:	00092503          	lw	a0,0(s2)
    80003e5c:	fffff097          	auipc	ra,0xfffff
    80003e60:	75a080e7          	jalr	1882(ra) # 800035b6 <iget>
    80003e64:	a011                	j	80003e68 <dirlookup+0xa0>
  return 0;
    80003e66:	4501                	li	a0,0
}
    80003e68:	70e2                	ld	ra,56(sp)
    80003e6a:	7442                	ld	s0,48(sp)
    80003e6c:	74a2                	ld	s1,40(sp)
    80003e6e:	7902                	ld	s2,32(sp)
    80003e70:	69e2                	ld	s3,24(sp)
    80003e72:	6a42                	ld	s4,16(sp)
    80003e74:	6121                	addi	sp,sp,64
    80003e76:	8082                	ret

0000000080003e78 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e78:	711d                	addi	sp,sp,-96
    80003e7a:	ec86                	sd	ra,88(sp)
    80003e7c:	e8a2                	sd	s0,80(sp)
    80003e7e:	e4a6                	sd	s1,72(sp)
    80003e80:	e0ca                	sd	s2,64(sp)
    80003e82:	fc4e                	sd	s3,56(sp)
    80003e84:	f852                	sd	s4,48(sp)
    80003e86:	f456                	sd	s5,40(sp)
    80003e88:	f05a                	sd	s6,32(sp)
    80003e8a:	ec5e                	sd	s7,24(sp)
    80003e8c:	e862                	sd	s8,16(sp)
    80003e8e:	e466                	sd	s9,8(sp)
    80003e90:	1080                	addi	s0,sp,96
    80003e92:	84aa                	mv	s1,a0
    80003e94:	8aae                	mv	s5,a1
    80003e96:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e98:	00054703          	lbu	a4,0(a0)
    80003e9c:	02f00793          	li	a5,47
    80003ea0:	02f70363          	beq	a4,a5,80003ec6 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ea4:	ffffe097          	auipc	ra,0xffffe
    80003ea8:	bbe080e7          	jalr	-1090(ra) # 80001a62 <myproc>
    80003eac:	15053503          	ld	a0,336(a0)
    80003eb0:	00000097          	auipc	ra,0x0
    80003eb4:	9fc080e7          	jalr	-1540(ra) # 800038ac <idup>
    80003eb8:	89aa                	mv	s3,a0
  while(*path == '/')
    80003eba:	02f00913          	li	s2,47
  len = path - s;
    80003ebe:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003ec0:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ec2:	4b85                	li	s7,1
    80003ec4:	a865                	j	80003f7c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003ec6:	4585                	li	a1,1
    80003ec8:	4505                	li	a0,1
    80003eca:	fffff097          	auipc	ra,0xfffff
    80003ece:	6ec080e7          	jalr	1772(ra) # 800035b6 <iget>
    80003ed2:	89aa                	mv	s3,a0
    80003ed4:	b7dd                	j	80003eba <namex+0x42>
      iunlockput(ip);
    80003ed6:	854e                	mv	a0,s3
    80003ed8:	00000097          	auipc	ra,0x0
    80003edc:	c74080e7          	jalr	-908(ra) # 80003b4c <iunlockput>
      return 0;
    80003ee0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ee2:	854e                	mv	a0,s3
    80003ee4:	60e6                	ld	ra,88(sp)
    80003ee6:	6446                	ld	s0,80(sp)
    80003ee8:	64a6                	ld	s1,72(sp)
    80003eea:	6906                	ld	s2,64(sp)
    80003eec:	79e2                	ld	s3,56(sp)
    80003eee:	7a42                	ld	s4,48(sp)
    80003ef0:	7aa2                	ld	s5,40(sp)
    80003ef2:	7b02                	ld	s6,32(sp)
    80003ef4:	6be2                	ld	s7,24(sp)
    80003ef6:	6c42                	ld	s8,16(sp)
    80003ef8:	6ca2                	ld	s9,8(sp)
    80003efa:	6125                	addi	sp,sp,96
    80003efc:	8082                	ret
      iunlock(ip);
    80003efe:	854e                	mv	a0,s3
    80003f00:	00000097          	auipc	ra,0x0
    80003f04:	aac080e7          	jalr	-1364(ra) # 800039ac <iunlock>
      return ip;
    80003f08:	bfe9                	j	80003ee2 <namex+0x6a>
      iunlockput(ip);
    80003f0a:	854e                	mv	a0,s3
    80003f0c:	00000097          	auipc	ra,0x0
    80003f10:	c40080e7          	jalr	-960(ra) # 80003b4c <iunlockput>
      return 0;
    80003f14:	89e6                	mv	s3,s9
    80003f16:	b7f1                	j	80003ee2 <namex+0x6a>
  len = path - s;
    80003f18:	40b48633          	sub	a2,s1,a1
    80003f1c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003f20:	099c5463          	bge	s8,s9,80003fa8 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f24:	4639                	li	a2,14
    80003f26:	8552                	mv	a0,s4
    80003f28:	ffffd097          	auipc	ra,0xffffd
    80003f2c:	e9a080e7          	jalr	-358(ra) # 80000dc2 <memmove>
  while(*path == '/')
    80003f30:	0004c783          	lbu	a5,0(s1)
    80003f34:	01279763          	bne	a5,s2,80003f42 <namex+0xca>
    path++;
    80003f38:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f3a:	0004c783          	lbu	a5,0(s1)
    80003f3e:	ff278de3          	beq	a5,s2,80003f38 <namex+0xc0>
    ilock(ip);
    80003f42:	854e                	mv	a0,s3
    80003f44:	00000097          	auipc	ra,0x0
    80003f48:	9a6080e7          	jalr	-1626(ra) # 800038ea <ilock>
    if(ip->type != T_DIR){
    80003f4c:	04499783          	lh	a5,68(s3)
    80003f50:	f97793e3          	bne	a5,s7,80003ed6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f54:	000a8563          	beqz	s5,80003f5e <namex+0xe6>
    80003f58:	0004c783          	lbu	a5,0(s1)
    80003f5c:	d3cd                	beqz	a5,80003efe <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f5e:	865a                	mv	a2,s6
    80003f60:	85d2                	mv	a1,s4
    80003f62:	854e                	mv	a0,s3
    80003f64:	00000097          	auipc	ra,0x0
    80003f68:	e64080e7          	jalr	-412(ra) # 80003dc8 <dirlookup>
    80003f6c:	8caa                	mv	s9,a0
    80003f6e:	dd51                	beqz	a0,80003f0a <namex+0x92>
    iunlockput(ip);
    80003f70:	854e                	mv	a0,s3
    80003f72:	00000097          	auipc	ra,0x0
    80003f76:	bda080e7          	jalr	-1062(ra) # 80003b4c <iunlockput>
    ip = next;
    80003f7a:	89e6                	mv	s3,s9
  while(*path == '/')
    80003f7c:	0004c783          	lbu	a5,0(s1)
    80003f80:	05279763          	bne	a5,s2,80003fce <namex+0x156>
    path++;
    80003f84:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f86:	0004c783          	lbu	a5,0(s1)
    80003f8a:	ff278de3          	beq	a5,s2,80003f84 <namex+0x10c>
  if(*path == 0)
    80003f8e:	c79d                	beqz	a5,80003fbc <namex+0x144>
    path++;
    80003f90:	85a6                	mv	a1,s1
  len = path - s;
    80003f92:	8cda                	mv	s9,s6
    80003f94:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003f96:	01278963          	beq	a5,s2,80003fa8 <namex+0x130>
    80003f9a:	dfbd                	beqz	a5,80003f18 <namex+0xa0>
    path++;
    80003f9c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f9e:	0004c783          	lbu	a5,0(s1)
    80003fa2:	ff279ce3          	bne	a5,s2,80003f9a <namex+0x122>
    80003fa6:	bf8d                	j	80003f18 <namex+0xa0>
    memmove(name, s, len);
    80003fa8:	2601                	sext.w	a2,a2
    80003faa:	8552                	mv	a0,s4
    80003fac:	ffffd097          	auipc	ra,0xffffd
    80003fb0:	e16080e7          	jalr	-490(ra) # 80000dc2 <memmove>
    name[len] = 0;
    80003fb4:	9cd2                	add	s9,s9,s4
    80003fb6:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003fba:	bf9d                	j	80003f30 <namex+0xb8>
  if(nameiparent){
    80003fbc:	f20a83e3          	beqz	s5,80003ee2 <namex+0x6a>
    iput(ip);
    80003fc0:	854e                	mv	a0,s3
    80003fc2:	00000097          	auipc	ra,0x0
    80003fc6:	ae2080e7          	jalr	-1310(ra) # 80003aa4 <iput>
    return 0;
    80003fca:	4981                	li	s3,0
    80003fcc:	bf19                	j	80003ee2 <namex+0x6a>
  if(*path == 0)
    80003fce:	d7fd                	beqz	a5,80003fbc <namex+0x144>
  while(*path != '/' && *path != 0)
    80003fd0:	0004c783          	lbu	a5,0(s1)
    80003fd4:	85a6                	mv	a1,s1
    80003fd6:	b7d1                	j	80003f9a <namex+0x122>

0000000080003fd8 <dirlink>:
{
    80003fd8:	7139                	addi	sp,sp,-64
    80003fda:	fc06                	sd	ra,56(sp)
    80003fdc:	f822                	sd	s0,48(sp)
    80003fde:	f426                	sd	s1,40(sp)
    80003fe0:	f04a                	sd	s2,32(sp)
    80003fe2:	ec4e                	sd	s3,24(sp)
    80003fe4:	e852                	sd	s4,16(sp)
    80003fe6:	0080                	addi	s0,sp,64
    80003fe8:	892a                	mv	s2,a0
    80003fea:	8a2e                	mv	s4,a1
    80003fec:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fee:	4601                	li	a2,0
    80003ff0:	00000097          	auipc	ra,0x0
    80003ff4:	dd8080e7          	jalr	-552(ra) # 80003dc8 <dirlookup>
    80003ff8:	e93d                	bnez	a0,8000406e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ffa:	04c92483          	lw	s1,76(s2)
    80003ffe:	c49d                	beqz	s1,8000402c <dirlink+0x54>
    80004000:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004002:	4741                	li	a4,16
    80004004:	86a6                	mv	a3,s1
    80004006:	fc040613          	addi	a2,s0,-64
    8000400a:	4581                	li	a1,0
    8000400c:	854a                	mv	a0,s2
    8000400e:	00000097          	auipc	ra,0x0
    80004012:	b90080e7          	jalr	-1136(ra) # 80003b9e <readi>
    80004016:	47c1                	li	a5,16
    80004018:	06f51163          	bne	a0,a5,8000407a <dirlink+0xa2>
    if(de.inum == 0)
    8000401c:	fc045783          	lhu	a5,-64(s0)
    80004020:	c791                	beqz	a5,8000402c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004022:	24c1                	addiw	s1,s1,16
    80004024:	04c92783          	lw	a5,76(s2)
    80004028:	fcf4ede3          	bltu	s1,a5,80004002 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000402c:	4639                	li	a2,14
    8000402e:	85d2                	mv	a1,s4
    80004030:	fc240513          	addi	a0,s0,-62
    80004034:	ffffd097          	auipc	ra,0xffffd
    80004038:	e46080e7          	jalr	-442(ra) # 80000e7a <strncpy>
  de.inum = inum;
    8000403c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004040:	4741                	li	a4,16
    80004042:	86a6                	mv	a3,s1
    80004044:	fc040613          	addi	a2,s0,-64
    80004048:	4581                	li	a1,0
    8000404a:	854a                	mv	a0,s2
    8000404c:	00000097          	auipc	ra,0x0
    80004050:	c48080e7          	jalr	-952(ra) # 80003c94 <writei>
    80004054:	872a                	mv	a4,a0
    80004056:	47c1                	li	a5,16
  return 0;
    80004058:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000405a:	02f71863          	bne	a4,a5,8000408a <dirlink+0xb2>
}
    8000405e:	70e2                	ld	ra,56(sp)
    80004060:	7442                	ld	s0,48(sp)
    80004062:	74a2                	ld	s1,40(sp)
    80004064:	7902                	ld	s2,32(sp)
    80004066:	69e2                	ld	s3,24(sp)
    80004068:	6a42                	ld	s4,16(sp)
    8000406a:	6121                	addi	sp,sp,64
    8000406c:	8082                	ret
    iput(ip);
    8000406e:	00000097          	auipc	ra,0x0
    80004072:	a36080e7          	jalr	-1482(ra) # 80003aa4 <iput>
    return -1;
    80004076:	557d                	li	a0,-1
    80004078:	b7dd                	j	8000405e <dirlink+0x86>
      panic("dirlink read");
    8000407a:	00004517          	auipc	a0,0x4
    8000407e:	53650513          	addi	a0,a0,1334 # 800085b0 <syscalls+0x1d8>
    80004082:	ffffc097          	auipc	ra,0xffffc
    80004086:	4c0080e7          	jalr	1216(ra) # 80000542 <panic>
    panic("dirlink");
    8000408a:	00004517          	auipc	a0,0x4
    8000408e:	64650513          	addi	a0,a0,1606 # 800086d0 <syscalls+0x2f8>
    80004092:	ffffc097          	auipc	ra,0xffffc
    80004096:	4b0080e7          	jalr	1200(ra) # 80000542 <panic>

000000008000409a <namei>:

struct inode*
namei(char *path)
{
    8000409a:	1101                	addi	sp,sp,-32
    8000409c:	ec06                	sd	ra,24(sp)
    8000409e:	e822                	sd	s0,16(sp)
    800040a0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040a2:	fe040613          	addi	a2,s0,-32
    800040a6:	4581                	li	a1,0
    800040a8:	00000097          	auipc	ra,0x0
    800040ac:	dd0080e7          	jalr	-560(ra) # 80003e78 <namex>
}
    800040b0:	60e2                	ld	ra,24(sp)
    800040b2:	6442                	ld	s0,16(sp)
    800040b4:	6105                	addi	sp,sp,32
    800040b6:	8082                	ret

00000000800040b8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040b8:	1141                	addi	sp,sp,-16
    800040ba:	e406                	sd	ra,8(sp)
    800040bc:	e022                	sd	s0,0(sp)
    800040be:	0800                	addi	s0,sp,16
    800040c0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040c2:	4585                	li	a1,1
    800040c4:	00000097          	auipc	ra,0x0
    800040c8:	db4080e7          	jalr	-588(ra) # 80003e78 <namex>
}
    800040cc:	60a2                	ld	ra,8(sp)
    800040ce:	6402                	ld	s0,0(sp)
    800040d0:	0141                	addi	sp,sp,16
    800040d2:	8082                	ret

00000000800040d4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040d4:	1101                	addi	sp,sp,-32
    800040d6:	ec06                	sd	ra,24(sp)
    800040d8:	e822                	sd	s0,16(sp)
    800040da:	e426                	sd	s1,8(sp)
    800040dc:	e04a                	sd	s2,0(sp)
    800040de:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040e0:	0001e917          	auipc	s2,0x1e
    800040e4:	22890913          	addi	s2,s2,552 # 80022308 <log>
    800040e8:	01892583          	lw	a1,24(s2)
    800040ec:	02892503          	lw	a0,40(s2)
    800040f0:	fffff097          	auipc	ra,0xfffff
    800040f4:	ff8080e7          	jalr	-8(ra) # 800030e8 <bread>
    800040f8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040fa:	02c92683          	lw	a3,44(s2)
    800040fe:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004100:	02d05763          	blez	a3,8000412e <write_head+0x5a>
    80004104:	0001e797          	auipc	a5,0x1e
    80004108:	23478793          	addi	a5,a5,564 # 80022338 <log+0x30>
    8000410c:	05c50713          	addi	a4,a0,92
    80004110:	36fd                	addiw	a3,a3,-1
    80004112:	1682                	slli	a3,a3,0x20
    80004114:	9281                	srli	a3,a3,0x20
    80004116:	068a                	slli	a3,a3,0x2
    80004118:	0001e617          	auipc	a2,0x1e
    8000411c:	22460613          	addi	a2,a2,548 # 8002233c <log+0x34>
    80004120:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004122:	4390                	lw	a2,0(a5)
    80004124:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004126:	0791                	addi	a5,a5,4
    80004128:	0711                	addi	a4,a4,4
    8000412a:	fed79ce3          	bne	a5,a3,80004122 <write_head+0x4e>
  }
  bwrite(buf);
    8000412e:	8526                	mv	a0,s1
    80004130:	fffff097          	auipc	ra,0xfffff
    80004134:	0aa080e7          	jalr	170(ra) # 800031da <bwrite>
  brelse(buf);
    80004138:	8526                	mv	a0,s1
    8000413a:	fffff097          	auipc	ra,0xfffff
    8000413e:	0de080e7          	jalr	222(ra) # 80003218 <brelse>
}
    80004142:	60e2                	ld	ra,24(sp)
    80004144:	6442                	ld	s0,16(sp)
    80004146:	64a2                	ld	s1,8(sp)
    80004148:	6902                	ld	s2,0(sp)
    8000414a:	6105                	addi	sp,sp,32
    8000414c:	8082                	ret

000000008000414e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000414e:	0001e797          	auipc	a5,0x1e
    80004152:	1e67a783          	lw	a5,486(a5) # 80022334 <log+0x2c>
    80004156:	0af05663          	blez	a5,80004202 <install_trans+0xb4>
{
    8000415a:	7139                	addi	sp,sp,-64
    8000415c:	fc06                	sd	ra,56(sp)
    8000415e:	f822                	sd	s0,48(sp)
    80004160:	f426                	sd	s1,40(sp)
    80004162:	f04a                	sd	s2,32(sp)
    80004164:	ec4e                	sd	s3,24(sp)
    80004166:	e852                	sd	s4,16(sp)
    80004168:	e456                	sd	s5,8(sp)
    8000416a:	0080                	addi	s0,sp,64
    8000416c:	0001ea97          	auipc	s5,0x1e
    80004170:	1cca8a93          	addi	s5,s5,460 # 80022338 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004174:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004176:	0001e997          	auipc	s3,0x1e
    8000417a:	19298993          	addi	s3,s3,402 # 80022308 <log>
    8000417e:	0189a583          	lw	a1,24(s3)
    80004182:	014585bb          	addw	a1,a1,s4
    80004186:	2585                	addiw	a1,a1,1
    80004188:	0289a503          	lw	a0,40(s3)
    8000418c:	fffff097          	auipc	ra,0xfffff
    80004190:	f5c080e7          	jalr	-164(ra) # 800030e8 <bread>
    80004194:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004196:	000aa583          	lw	a1,0(s5)
    8000419a:	0289a503          	lw	a0,40(s3)
    8000419e:	fffff097          	auipc	ra,0xfffff
    800041a2:	f4a080e7          	jalr	-182(ra) # 800030e8 <bread>
    800041a6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041a8:	40000613          	li	a2,1024
    800041ac:	05890593          	addi	a1,s2,88
    800041b0:	05850513          	addi	a0,a0,88
    800041b4:	ffffd097          	auipc	ra,0xffffd
    800041b8:	c0e080e7          	jalr	-1010(ra) # 80000dc2 <memmove>
    bwrite(dbuf);  // write dst to disk
    800041bc:	8526                	mv	a0,s1
    800041be:	fffff097          	auipc	ra,0xfffff
    800041c2:	01c080e7          	jalr	28(ra) # 800031da <bwrite>
    bunpin(dbuf);
    800041c6:	8526                	mv	a0,s1
    800041c8:	fffff097          	auipc	ra,0xfffff
    800041cc:	12a080e7          	jalr	298(ra) # 800032f2 <bunpin>
    brelse(lbuf);
    800041d0:	854a                	mv	a0,s2
    800041d2:	fffff097          	auipc	ra,0xfffff
    800041d6:	046080e7          	jalr	70(ra) # 80003218 <brelse>
    brelse(dbuf);
    800041da:	8526                	mv	a0,s1
    800041dc:	fffff097          	auipc	ra,0xfffff
    800041e0:	03c080e7          	jalr	60(ra) # 80003218 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041e4:	2a05                	addiw	s4,s4,1
    800041e6:	0a91                	addi	s5,s5,4
    800041e8:	02c9a783          	lw	a5,44(s3)
    800041ec:	f8fa49e3          	blt	s4,a5,8000417e <install_trans+0x30>
}
    800041f0:	70e2                	ld	ra,56(sp)
    800041f2:	7442                	ld	s0,48(sp)
    800041f4:	74a2                	ld	s1,40(sp)
    800041f6:	7902                	ld	s2,32(sp)
    800041f8:	69e2                	ld	s3,24(sp)
    800041fa:	6a42                	ld	s4,16(sp)
    800041fc:	6aa2                	ld	s5,8(sp)
    800041fe:	6121                	addi	sp,sp,64
    80004200:	8082                	ret
    80004202:	8082                	ret

0000000080004204 <initlog>:
{
    80004204:	7179                	addi	sp,sp,-48
    80004206:	f406                	sd	ra,40(sp)
    80004208:	f022                	sd	s0,32(sp)
    8000420a:	ec26                	sd	s1,24(sp)
    8000420c:	e84a                	sd	s2,16(sp)
    8000420e:	e44e                	sd	s3,8(sp)
    80004210:	1800                	addi	s0,sp,48
    80004212:	892a                	mv	s2,a0
    80004214:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004216:	0001e497          	auipc	s1,0x1e
    8000421a:	0f248493          	addi	s1,s1,242 # 80022308 <log>
    8000421e:	00004597          	auipc	a1,0x4
    80004222:	3a258593          	addi	a1,a1,930 # 800085c0 <syscalls+0x1e8>
    80004226:	8526                	mv	a0,s1
    80004228:	ffffd097          	auipc	ra,0xffffd
    8000422c:	9b2080e7          	jalr	-1614(ra) # 80000bda <initlock>
  log.start = sb->logstart;
    80004230:	0149a583          	lw	a1,20(s3)
    80004234:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004236:	0109a783          	lw	a5,16(s3)
    8000423a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000423c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004240:	854a                	mv	a0,s2
    80004242:	fffff097          	auipc	ra,0xfffff
    80004246:	ea6080e7          	jalr	-346(ra) # 800030e8 <bread>
  log.lh.n = lh->n;
    8000424a:	4d34                	lw	a3,88(a0)
    8000424c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000424e:	02d05563          	blez	a3,80004278 <initlog+0x74>
    80004252:	05c50793          	addi	a5,a0,92
    80004256:	0001e717          	auipc	a4,0x1e
    8000425a:	0e270713          	addi	a4,a4,226 # 80022338 <log+0x30>
    8000425e:	36fd                	addiw	a3,a3,-1
    80004260:	1682                	slli	a3,a3,0x20
    80004262:	9281                	srli	a3,a3,0x20
    80004264:	068a                	slli	a3,a3,0x2
    80004266:	06050613          	addi	a2,a0,96
    8000426a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000426c:	4390                	lw	a2,0(a5)
    8000426e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004270:	0791                	addi	a5,a5,4
    80004272:	0711                	addi	a4,a4,4
    80004274:	fed79ce3          	bne	a5,a3,8000426c <initlog+0x68>
  brelse(buf);
    80004278:	fffff097          	auipc	ra,0xfffff
    8000427c:	fa0080e7          	jalr	-96(ra) # 80003218 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004280:	00000097          	auipc	ra,0x0
    80004284:	ece080e7          	jalr	-306(ra) # 8000414e <install_trans>
  log.lh.n = 0;
    80004288:	0001e797          	auipc	a5,0x1e
    8000428c:	0a07a623          	sw	zero,172(a5) # 80022334 <log+0x2c>
  write_head(); // clear the log
    80004290:	00000097          	auipc	ra,0x0
    80004294:	e44080e7          	jalr	-444(ra) # 800040d4 <write_head>
}
    80004298:	70a2                	ld	ra,40(sp)
    8000429a:	7402                	ld	s0,32(sp)
    8000429c:	64e2                	ld	s1,24(sp)
    8000429e:	6942                	ld	s2,16(sp)
    800042a0:	69a2                	ld	s3,8(sp)
    800042a2:	6145                	addi	sp,sp,48
    800042a4:	8082                	ret

00000000800042a6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042a6:	1101                	addi	sp,sp,-32
    800042a8:	ec06                	sd	ra,24(sp)
    800042aa:	e822                	sd	s0,16(sp)
    800042ac:	e426                	sd	s1,8(sp)
    800042ae:	e04a                	sd	s2,0(sp)
    800042b0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042b2:	0001e517          	auipc	a0,0x1e
    800042b6:	05650513          	addi	a0,a0,86 # 80022308 <log>
    800042ba:	ffffd097          	auipc	ra,0xffffd
    800042be:	9b0080e7          	jalr	-1616(ra) # 80000c6a <acquire>
  while(1){
    if(log.committing){
    800042c2:	0001e497          	auipc	s1,0x1e
    800042c6:	04648493          	addi	s1,s1,70 # 80022308 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042ca:	4979                	li	s2,30
    800042cc:	a039                	j	800042da <begin_op+0x34>
      sleep(&log, &log.lock);
    800042ce:	85a6                	mv	a1,s1
    800042d0:	8526                	mv	a0,s1
    800042d2:	ffffe097          	auipc	ra,0xffffe
    800042d6:	fd0080e7          	jalr	-48(ra) # 800022a2 <sleep>
    if(log.committing){
    800042da:	50dc                	lw	a5,36(s1)
    800042dc:	fbed                	bnez	a5,800042ce <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042de:	509c                	lw	a5,32(s1)
    800042e0:	0017871b          	addiw	a4,a5,1
    800042e4:	0007069b          	sext.w	a3,a4
    800042e8:	0027179b          	slliw	a5,a4,0x2
    800042ec:	9fb9                	addw	a5,a5,a4
    800042ee:	0017979b          	slliw	a5,a5,0x1
    800042f2:	54d8                	lw	a4,44(s1)
    800042f4:	9fb9                	addw	a5,a5,a4
    800042f6:	00f95963          	bge	s2,a5,80004308 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800042fa:	85a6                	mv	a1,s1
    800042fc:	8526                	mv	a0,s1
    800042fe:	ffffe097          	auipc	ra,0xffffe
    80004302:	fa4080e7          	jalr	-92(ra) # 800022a2 <sleep>
    80004306:	bfd1                	j	800042da <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004308:	0001e517          	auipc	a0,0x1e
    8000430c:	00050513          	mv	a0,a0
    80004310:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004312:	ffffd097          	auipc	ra,0xffffd
    80004316:	a0c080e7          	jalr	-1524(ra) # 80000d1e <release>
      break;
    }
  }
}
    8000431a:	60e2                	ld	ra,24(sp)
    8000431c:	6442                	ld	s0,16(sp)
    8000431e:	64a2                	ld	s1,8(sp)
    80004320:	6902                	ld	s2,0(sp)
    80004322:	6105                	addi	sp,sp,32
    80004324:	8082                	ret

0000000080004326 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004326:	7139                	addi	sp,sp,-64
    80004328:	fc06                	sd	ra,56(sp)
    8000432a:	f822                	sd	s0,48(sp)
    8000432c:	f426                	sd	s1,40(sp)
    8000432e:	f04a                	sd	s2,32(sp)
    80004330:	ec4e                	sd	s3,24(sp)
    80004332:	e852                	sd	s4,16(sp)
    80004334:	e456                	sd	s5,8(sp)
    80004336:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004338:	0001e497          	auipc	s1,0x1e
    8000433c:	fd048493          	addi	s1,s1,-48 # 80022308 <log>
    80004340:	8526                	mv	a0,s1
    80004342:	ffffd097          	auipc	ra,0xffffd
    80004346:	928080e7          	jalr	-1752(ra) # 80000c6a <acquire>
  log.outstanding -= 1;
    8000434a:	509c                	lw	a5,32(s1)
    8000434c:	37fd                	addiw	a5,a5,-1
    8000434e:	0007891b          	sext.w	s2,a5
    80004352:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004354:	50dc                	lw	a5,36(s1)
    80004356:	e7b9                	bnez	a5,800043a4 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004358:	04091e63          	bnez	s2,800043b4 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000435c:	0001e497          	auipc	s1,0x1e
    80004360:	fac48493          	addi	s1,s1,-84 # 80022308 <log>
    80004364:	4785                	li	a5,1
    80004366:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004368:	8526                	mv	a0,s1
    8000436a:	ffffd097          	auipc	ra,0xffffd
    8000436e:	9b4080e7          	jalr	-1612(ra) # 80000d1e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004372:	54dc                	lw	a5,44(s1)
    80004374:	06f04763          	bgtz	a5,800043e2 <end_op+0xbc>
    acquire(&log.lock);
    80004378:	0001e497          	auipc	s1,0x1e
    8000437c:	f9048493          	addi	s1,s1,-112 # 80022308 <log>
    80004380:	8526                	mv	a0,s1
    80004382:	ffffd097          	auipc	ra,0xffffd
    80004386:	8e8080e7          	jalr	-1816(ra) # 80000c6a <acquire>
    log.committing = 0;
    8000438a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000438e:	8526                	mv	a0,s1
    80004390:	ffffe097          	auipc	ra,0xffffe
    80004394:	092080e7          	jalr	146(ra) # 80002422 <wakeup>
    release(&log.lock);
    80004398:	8526                	mv	a0,s1
    8000439a:	ffffd097          	auipc	ra,0xffffd
    8000439e:	984080e7          	jalr	-1660(ra) # 80000d1e <release>
}
    800043a2:	a03d                	j	800043d0 <end_op+0xaa>
    panic("log.committing");
    800043a4:	00004517          	auipc	a0,0x4
    800043a8:	22450513          	addi	a0,a0,548 # 800085c8 <syscalls+0x1f0>
    800043ac:	ffffc097          	auipc	ra,0xffffc
    800043b0:	196080e7          	jalr	406(ra) # 80000542 <panic>
    wakeup(&log);
    800043b4:	0001e497          	auipc	s1,0x1e
    800043b8:	f5448493          	addi	s1,s1,-172 # 80022308 <log>
    800043bc:	8526                	mv	a0,s1
    800043be:	ffffe097          	auipc	ra,0xffffe
    800043c2:	064080e7          	jalr	100(ra) # 80002422 <wakeup>
  release(&log.lock);
    800043c6:	8526                	mv	a0,s1
    800043c8:	ffffd097          	auipc	ra,0xffffd
    800043cc:	956080e7          	jalr	-1706(ra) # 80000d1e <release>
}
    800043d0:	70e2                	ld	ra,56(sp)
    800043d2:	7442                	ld	s0,48(sp)
    800043d4:	74a2                	ld	s1,40(sp)
    800043d6:	7902                	ld	s2,32(sp)
    800043d8:	69e2                	ld	s3,24(sp)
    800043da:	6a42                	ld	s4,16(sp)
    800043dc:	6aa2                	ld	s5,8(sp)
    800043de:	6121                	addi	sp,sp,64
    800043e0:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800043e2:	0001ea97          	auipc	s5,0x1e
    800043e6:	f56a8a93          	addi	s5,s5,-170 # 80022338 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800043ea:	0001ea17          	auipc	s4,0x1e
    800043ee:	f1ea0a13          	addi	s4,s4,-226 # 80022308 <log>
    800043f2:	018a2583          	lw	a1,24(s4)
    800043f6:	012585bb          	addw	a1,a1,s2
    800043fa:	2585                	addiw	a1,a1,1
    800043fc:	028a2503          	lw	a0,40(s4)
    80004400:	fffff097          	auipc	ra,0xfffff
    80004404:	ce8080e7          	jalr	-792(ra) # 800030e8 <bread>
    80004408:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000440a:	000aa583          	lw	a1,0(s5)
    8000440e:	028a2503          	lw	a0,40(s4)
    80004412:	fffff097          	auipc	ra,0xfffff
    80004416:	cd6080e7          	jalr	-810(ra) # 800030e8 <bread>
    8000441a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000441c:	40000613          	li	a2,1024
    80004420:	05850593          	addi	a1,a0,88
    80004424:	05848513          	addi	a0,s1,88
    80004428:	ffffd097          	auipc	ra,0xffffd
    8000442c:	99a080e7          	jalr	-1638(ra) # 80000dc2 <memmove>
    bwrite(to);  // write the log
    80004430:	8526                	mv	a0,s1
    80004432:	fffff097          	auipc	ra,0xfffff
    80004436:	da8080e7          	jalr	-600(ra) # 800031da <bwrite>
    brelse(from);
    8000443a:	854e                	mv	a0,s3
    8000443c:	fffff097          	auipc	ra,0xfffff
    80004440:	ddc080e7          	jalr	-548(ra) # 80003218 <brelse>
    brelse(to);
    80004444:	8526                	mv	a0,s1
    80004446:	fffff097          	auipc	ra,0xfffff
    8000444a:	dd2080e7          	jalr	-558(ra) # 80003218 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000444e:	2905                	addiw	s2,s2,1
    80004450:	0a91                	addi	s5,s5,4
    80004452:	02ca2783          	lw	a5,44(s4)
    80004456:	f8f94ee3          	blt	s2,a5,800043f2 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000445a:	00000097          	auipc	ra,0x0
    8000445e:	c7a080e7          	jalr	-902(ra) # 800040d4 <write_head>
    install_trans(); // Now install writes to home locations
    80004462:	00000097          	auipc	ra,0x0
    80004466:	cec080e7          	jalr	-788(ra) # 8000414e <install_trans>
    log.lh.n = 0;
    8000446a:	0001e797          	auipc	a5,0x1e
    8000446e:	ec07a523          	sw	zero,-310(a5) # 80022334 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004472:	00000097          	auipc	ra,0x0
    80004476:	c62080e7          	jalr	-926(ra) # 800040d4 <write_head>
    8000447a:	bdfd                	j	80004378 <end_op+0x52>

000000008000447c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000447c:	1101                	addi	sp,sp,-32
    8000447e:	ec06                	sd	ra,24(sp)
    80004480:	e822                	sd	s0,16(sp)
    80004482:	e426                	sd	s1,8(sp)
    80004484:	e04a                	sd	s2,0(sp)
    80004486:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004488:	0001e717          	auipc	a4,0x1e
    8000448c:	eac72703          	lw	a4,-340(a4) # 80022334 <log+0x2c>
    80004490:	47f5                	li	a5,29
    80004492:	08e7c063          	blt	a5,a4,80004512 <log_write+0x96>
    80004496:	84aa                	mv	s1,a0
    80004498:	0001e797          	auipc	a5,0x1e
    8000449c:	e8c7a783          	lw	a5,-372(a5) # 80022324 <log+0x1c>
    800044a0:	37fd                	addiw	a5,a5,-1
    800044a2:	06f75863          	bge	a4,a5,80004512 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044a6:	0001e797          	auipc	a5,0x1e
    800044aa:	e827a783          	lw	a5,-382(a5) # 80022328 <log+0x20>
    800044ae:	06f05a63          	blez	a5,80004522 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800044b2:	0001e917          	auipc	s2,0x1e
    800044b6:	e5690913          	addi	s2,s2,-426 # 80022308 <log>
    800044ba:	854a                	mv	a0,s2
    800044bc:	ffffc097          	auipc	ra,0xffffc
    800044c0:	7ae080e7          	jalr	1966(ra) # 80000c6a <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800044c4:	02c92603          	lw	a2,44(s2)
    800044c8:	06c05563          	blez	a2,80004532 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800044cc:	44cc                	lw	a1,12(s1)
    800044ce:	0001e717          	auipc	a4,0x1e
    800044d2:	e6a70713          	addi	a4,a4,-406 # 80022338 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800044d6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800044d8:	4314                	lw	a3,0(a4)
    800044da:	04b68d63          	beq	a3,a1,80004534 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    800044de:	2785                	addiw	a5,a5,1
    800044e0:	0711                	addi	a4,a4,4
    800044e2:	fec79be3          	bne	a5,a2,800044d8 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    800044e6:	0621                	addi	a2,a2,8
    800044e8:	060a                	slli	a2,a2,0x2
    800044ea:	0001e797          	auipc	a5,0x1e
    800044ee:	e1e78793          	addi	a5,a5,-482 # 80022308 <log>
    800044f2:	963e                	add	a2,a2,a5
    800044f4:	44dc                	lw	a5,12(s1)
    800044f6:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800044f8:	8526                	mv	a0,s1
    800044fa:	fffff097          	auipc	ra,0xfffff
    800044fe:	dbc080e7          	jalr	-580(ra) # 800032b6 <bpin>
    log.lh.n++;
    80004502:	0001e717          	auipc	a4,0x1e
    80004506:	e0670713          	addi	a4,a4,-506 # 80022308 <log>
    8000450a:	575c                	lw	a5,44(a4)
    8000450c:	2785                	addiw	a5,a5,1
    8000450e:	d75c                	sw	a5,44(a4)
    80004510:	a83d                	j	8000454e <log_write+0xd2>
    panic("too big a transaction");
    80004512:	00004517          	auipc	a0,0x4
    80004516:	0c650513          	addi	a0,a0,198 # 800085d8 <syscalls+0x200>
    8000451a:	ffffc097          	auipc	ra,0xffffc
    8000451e:	028080e7          	jalr	40(ra) # 80000542 <panic>
    panic("log_write outside of trans");
    80004522:	00004517          	auipc	a0,0x4
    80004526:	0ce50513          	addi	a0,a0,206 # 800085f0 <syscalls+0x218>
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	018080e7          	jalr	24(ra) # 80000542 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004532:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004534:	00878713          	addi	a4,a5,8
    80004538:	00271693          	slli	a3,a4,0x2
    8000453c:	0001e717          	auipc	a4,0x1e
    80004540:	dcc70713          	addi	a4,a4,-564 # 80022308 <log>
    80004544:	9736                	add	a4,a4,a3
    80004546:	44d4                	lw	a3,12(s1)
    80004548:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000454a:	faf607e3          	beq	a2,a5,800044f8 <log_write+0x7c>
  }
  release(&log.lock);
    8000454e:	0001e517          	auipc	a0,0x1e
    80004552:	dba50513          	addi	a0,a0,-582 # 80022308 <log>
    80004556:	ffffc097          	auipc	ra,0xffffc
    8000455a:	7c8080e7          	jalr	1992(ra) # 80000d1e <release>
}
    8000455e:	60e2                	ld	ra,24(sp)
    80004560:	6442                	ld	s0,16(sp)
    80004562:	64a2                	ld	s1,8(sp)
    80004564:	6902                	ld	s2,0(sp)
    80004566:	6105                	addi	sp,sp,32
    80004568:	8082                	ret

000000008000456a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000456a:	1101                	addi	sp,sp,-32
    8000456c:	ec06                	sd	ra,24(sp)
    8000456e:	e822                	sd	s0,16(sp)
    80004570:	e426                	sd	s1,8(sp)
    80004572:	e04a                	sd	s2,0(sp)
    80004574:	1000                	addi	s0,sp,32
    80004576:	84aa                	mv	s1,a0
    80004578:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000457a:	00004597          	auipc	a1,0x4
    8000457e:	09658593          	addi	a1,a1,150 # 80008610 <syscalls+0x238>
    80004582:	0521                	addi	a0,a0,8
    80004584:	ffffc097          	auipc	ra,0xffffc
    80004588:	656080e7          	jalr	1622(ra) # 80000bda <initlock>
  lk->name = name;
    8000458c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004590:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004594:	0204a423          	sw	zero,40(s1)
}
    80004598:	60e2                	ld	ra,24(sp)
    8000459a:	6442                	ld	s0,16(sp)
    8000459c:	64a2                	ld	s1,8(sp)
    8000459e:	6902                	ld	s2,0(sp)
    800045a0:	6105                	addi	sp,sp,32
    800045a2:	8082                	ret

00000000800045a4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045a4:	1101                	addi	sp,sp,-32
    800045a6:	ec06                	sd	ra,24(sp)
    800045a8:	e822                	sd	s0,16(sp)
    800045aa:	e426                	sd	s1,8(sp)
    800045ac:	e04a                	sd	s2,0(sp)
    800045ae:	1000                	addi	s0,sp,32
    800045b0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045b2:	00850913          	addi	s2,a0,8
    800045b6:	854a                	mv	a0,s2
    800045b8:	ffffc097          	auipc	ra,0xffffc
    800045bc:	6b2080e7          	jalr	1714(ra) # 80000c6a <acquire>
  while (lk->locked) {
    800045c0:	409c                	lw	a5,0(s1)
    800045c2:	cb89                	beqz	a5,800045d4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045c4:	85ca                	mv	a1,s2
    800045c6:	8526                	mv	a0,s1
    800045c8:	ffffe097          	auipc	ra,0xffffe
    800045cc:	cda080e7          	jalr	-806(ra) # 800022a2 <sleep>
  while (lk->locked) {
    800045d0:	409c                	lw	a5,0(s1)
    800045d2:	fbed                	bnez	a5,800045c4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045d4:	4785                	li	a5,1
    800045d6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045d8:	ffffd097          	auipc	ra,0xffffd
    800045dc:	48a080e7          	jalr	1162(ra) # 80001a62 <myproc>
    800045e0:	5d1c                	lw	a5,56(a0)
    800045e2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800045e4:	854a                	mv	a0,s2
    800045e6:	ffffc097          	auipc	ra,0xffffc
    800045ea:	738080e7          	jalr	1848(ra) # 80000d1e <release>
}
    800045ee:	60e2                	ld	ra,24(sp)
    800045f0:	6442                	ld	s0,16(sp)
    800045f2:	64a2                	ld	s1,8(sp)
    800045f4:	6902                	ld	s2,0(sp)
    800045f6:	6105                	addi	sp,sp,32
    800045f8:	8082                	ret

00000000800045fa <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045fa:	1101                	addi	sp,sp,-32
    800045fc:	ec06                	sd	ra,24(sp)
    800045fe:	e822                	sd	s0,16(sp)
    80004600:	e426                	sd	s1,8(sp)
    80004602:	e04a                	sd	s2,0(sp)
    80004604:	1000                	addi	s0,sp,32
    80004606:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004608:	00850913          	addi	s2,a0,8
    8000460c:	854a                	mv	a0,s2
    8000460e:	ffffc097          	auipc	ra,0xffffc
    80004612:	65c080e7          	jalr	1628(ra) # 80000c6a <acquire>
  lk->locked = 0;
    80004616:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000461a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000461e:	8526                	mv	a0,s1
    80004620:	ffffe097          	auipc	ra,0xffffe
    80004624:	e02080e7          	jalr	-510(ra) # 80002422 <wakeup>
  release(&lk->lk);
    80004628:	854a                	mv	a0,s2
    8000462a:	ffffc097          	auipc	ra,0xffffc
    8000462e:	6f4080e7          	jalr	1780(ra) # 80000d1e <release>
}
    80004632:	60e2                	ld	ra,24(sp)
    80004634:	6442                	ld	s0,16(sp)
    80004636:	64a2                	ld	s1,8(sp)
    80004638:	6902                	ld	s2,0(sp)
    8000463a:	6105                	addi	sp,sp,32
    8000463c:	8082                	ret

000000008000463e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000463e:	7179                	addi	sp,sp,-48
    80004640:	f406                	sd	ra,40(sp)
    80004642:	f022                	sd	s0,32(sp)
    80004644:	ec26                	sd	s1,24(sp)
    80004646:	e84a                	sd	s2,16(sp)
    80004648:	e44e                	sd	s3,8(sp)
    8000464a:	1800                	addi	s0,sp,48
    8000464c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000464e:	00850913          	addi	s2,a0,8
    80004652:	854a                	mv	a0,s2
    80004654:	ffffc097          	auipc	ra,0xffffc
    80004658:	616080e7          	jalr	1558(ra) # 80000c6a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000465c:	409c                	lw	a5,0(s1)
    8000465e:	ef99                	bnez	a5,8000467c <holdingsleep+0x3e>
    80004660:	4481                	li	s1,0
  release(&lk->lk);
    80004662:	854a                	mv	a0,s2
    80004664:	ffffc097          	auipc	ra,0xffffc
    80004668:	6ba080e7          	jalr	1722(ra) # 80000d1e <release>
  return r;
}
    8000466c:	8526                	mv	a0,s1
    8000466e:	70a2                	ld	ra,40(sp)
    80004670:	7402                	ld	s0,32(sp)
    80004672:	64e2                	ld	s1,24(sp)
    80004674:	6942                	ld	s2,16(sp)
    80004676:	69a2                	ld	s3,8(sp)
    80004678:	6145                	addi	sp,sp,48
    8000467a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000467c:	0284a983          	lw	s3,40(s1)
    80004680:	ffffd097          	auipc	ra,0xffffd
    80004684:	3e2080e7          	jalr	994(ra) # 80001a62 <myproc>
    80004688:	5d04                	lw	s1,56(a0)
    8000468a:	413484b3          	sub	s1,s1,s3
    8000468e:	0014b493          	seqz	s1,s1
    80004692:	bfc1                	j	80004662 <holdingsleep+0x24>

0000000080004694 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004694:	1141                	addi	sp,sp,-16
    80004696:	e406                	sd	ra,8(sp)
    80004698:	e022                	sd	s0,0(sp)
    8000469a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000469c:	00004597          	auipc	a1,0x4
    800046a0:	f8458593          	addi	a1,a1,-124 # 80008620 <syscalls+0x248>
    800046a4:	0001e517          	auipc	a0,0x1e
    800046a8:	dac50513          	addi	a0,a0,-596 # 80022450 <ftable>
    800046ac:	ffffc097          	auipc	ra,0xffffc
    800046b0:	52e080e7          	jalr	1326(ra) # 80000bda <initlock>
}
    800046b4:	60a2                	ld	ra,8(sp)
    800046b6:	6402                	ld	s0,0(sp)
    800046b8:	0141                	addi	sp,sp,16
    800046ba:	8082                	ret

00000000800046bc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046bc:	1101                	addi	sp,sp,-32
    800046be:	ec06                	sd	ra,24(sp)
    800046c0:	e822                	sd	s0,16(sp)
    800046c2:	e426                	sd	s1,8(sp)
    800046c4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046c6:	0001e517          	auipc	a0,0x1e
    800046ca:	d8a50513          	addi	a0,a0,-630 # 80022450 <ftable>
    800046ce:	ffffc097          	auipc	ra,0xffffc
    800046d2:	59c080e7          	jalr	1436(ra) # 80000c6a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046d6:	0001e497          	auipc	s1,0x1e
    800046da:	d9248493          	addi	s1,s1,-622 # 80022468 <ftable+0x18>
    800046de:	0001f717          	auipc	a4,0x1f
    800046e2:	d2a70713          	addi	a4,a4,-726 # 80023408 <ftable+0xfb8>
    if(f->ref == 0){
    800046e6:	40dc                	lw	a5,4(s1)
    800046e8:	cf99                	beqz	a5,80004706 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046ea:	02848493          	addi	s1,s1,40
    800046ee:	fee49ce3          	bne	s1,a4,800046e6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046f2:	0001e517          	auipc	a0,0x1e
    800046f6:	d5e50513          	addi	a0,a0,-674 # 80022450 <ftable>
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	624080e7          	jalr	1572(ra) # 80000d1e <release>
  return 0;
    80004702:	4481                	li	s1,0
    80004704:	a819                	j	8000471a <filealloc+0x5e>
      f->ref = 1;
    80004706:	4785                	li	a5,1
    80004708:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000470a:	0001e517          	auipc	a0,0x1e
    8000470e:	d4650513          	addi	a0,a0,-698 # 80022450 <ftable>
    80004712:	ffffc097          	auipc	ra,0xffffc
    80004716:	60c080e7          	jalr	1548(ra) # 80000d1e <release>
}
    8000471a:	8526                	mv	a0,s1
    8000471c:	60e2                	ld	ra,24(sp)
    8000471e:	6442                	ld	s0,16(sp)
    80004720:	64a2                	ld	s1,8(sp)
    80004722:	6105                	addi	sp,sp,32
    80004724:	8082                	ret

0000000080004726 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004726:	1101                	addi	sp,sp,-32
    80004728:	ec06                	sd	ra,24(sp)
    8000472a:	e822                	sd	s0,16(sp)
    8000472c:	e426                	sd	s1,8(sp)
    8000472e:	1000                	addi	s0,sp,32
    80004730:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004732:	0001e517          	auipc	a0,0x1e
    80004736:	d1e50513          	addi	a0,a0,-738 # 80022450 <ftable>
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	530080e7          	jalr	1328(ra) # 80000c6a <acquire>
  if(f->ref < 1)
    80004742:	40dc                	lw	a5,4(s1)
    80004744:	02f05263          	blez	a5,80004768 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004748:	2785                	addiw	a5,a5,1
    8000474a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000474c:	0001e517          	auipc	a0,0x1e
    80004750:	d0450513          	addi	a0,a0,-764 # 80022450 <ftable>
    80004754:	ffffc097          	auipc	ra,0xffffc
    80004758:	5ca080e7          	jalr	1482(ra) # 80000d1e <release>
  return f;
}
    8000475c:	8526                	mv	a0,s1
    8000475e:	60e2                	ld	ra,24(sp)
    80004760:	6442                	ld	s0,16(sp)
    80004762:	64a2                	ld	s1,8(sp)
    80004764:	6105                	addi	sp,sp,32
    80004766:	8082                	ret
    panic("filedup");
    80004768:	00004517          	auipc	a0,0x4
    8000476c:	ec050513          	addi	a0,a0,-320 # 80008628 <syscalls+0x250>
    80004770:	ffffc097          	auipc	ra,0xffffc
    80004774:	dd2080e7          	jalr	-558(ra) # 80000542 <panic>

0000000080004778 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004778:	7139                	addi	sp,sp,-64
    8000477a:	fc06                	sd	ra,56(sp)
    8000477c:	f822                	sd	s0,48(sp)
    8000477e:	f426                	sd	s1,40(sp)
    80004780:	f04a                	sd	s2,32(sp)
    80004782:	ec4e                	sd	s3,24(sp)
    80004784:	e852                	sd	s4,16(sp)
    80004786:	e456                	sd	s5,8(sp)
    80004788:	0080                	addi	s0,sp,64
    8000478a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000478c:	0001e517          	auipc	a0,0x1e
    80004790:	cc450513          	addi	a0,a0,-828 # 80022450 <ftable>
    80004794:	ffffc097          	auipc	ra,0xffffc
    80004798:	4d6080e7          	jalr	1238(ra) # 80000c6a <acquire>
  if(f->ref < 1)
    8000479c:	40dc                	lw	a5,4(s1)
    8000479e:	06f05163          	blez	a5,80004800 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047a2:	37fd                	addiw	a5,a5,-1
    800047a4:	0007871b          	sext.w	a4,a5
    800047a8:	c0dc                	sw	a5,4(s1)
    800047aa:	06e04363          	bgtz	a4,80004810 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047ae:	0004a903          	lw	s2,0(s1)
    800047b2:	0094ca83          	lbu	s5,9(s1)
    800047b6:	0104ba03          	ld	s4,16(s1)
    800047ba:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047be:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047c2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047c6:	0001e517          	auipc	a0,0x1e
    800047ca:	c8a50513          	addi	a0,a0,-886 # 80022450 <ftable>
    800047ce:	ffffc097          	auipc	ra,0xffffc
    800047d2:	550080e7          	jalr	1360(ra) # 80000d1e <release>

  if(ff.type == FD_PIPE){
    800047d6:	4785                	li	a5,1
    800047d8:	04f90d63          	beq	s2,a5,80004832 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047dc:	3979                	addiw	s2,s2,-2
    800047de:	4785                	li	a5,1
    800047e0:	0527e063          	bltu	a5,s2,80004820 <fileclose+0xa8>
    begin_op();
    800047e4:	00000097          	auipc	ra,0x0
    800047e8:	ac2080e7          	jalr	-1342(ra) # 800042a6 <begin_op>
    iput(ff.ip);
    800047ec:	854e                	mv	a0,s3
    800047ee:	fffff097          	auipc	ra,0xfffff
    800047f2:	2b6080e7          	jalr	694(ra) # 80003aa4 <iput>
    end_op();
    800047f6:	00000097          	auipc	ra,0x0
    800047fa:	b30080e7          	jalr	-1232(ra) # 80004326 <end_op>
    800047fe:	a00d                	j	80004820 <fileclose+0xa8>
    panic("fileclose");
    80004800:	00004517          	auipc	a0,0x4
    80004804:	e3050513          	addi	a0,a0,-464 # 80008630 <syscalls+0x258>
    80004808:	ffffc097          	auipc	ra,0xffffc
    8000480c:	d3a080e7          	jalr	-710(ra) # 80000542 <panic>
    release(&ftable.lock);
    80004810:	0001e517          	auipc	a0,0x1e
    80004814:	c4050513          	addi	a0,a0,-960 # 80022450 <ftable>
    80004818:	ffffc097          	auipc	ra,0xffffc
    8000481c:	506080e7          	jalr	1286(ra) # 80000d1e <release>
  }
}
    80004820:	70e2                	ld	ra,56(sp)
    80004822:	7442                	ld	s0,48(sp)
    80004824:	74a2                	ld	s1,40(sp)
    80004826:	7902                	ld	s2,32(sp)
    80004828:	69e2                	ld	s3,24(sp)
    8000482a:	6a42                	ld	s4,16(sp)
    8000482c:	6aa2                	ld	s5,8(sp)
    8000482e:	6121                	addi	sp,sp,64
    80004830:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004832:	85d6                	mv	a1,s5
    80004834:	8552                	mv	a0,s4
    80004836:	00000097          	auipc	ra,0x0
    8000483a:	372080e7          	jalr	882(ra) # 80004ba8 <pipeclose>
    8000483e:	b7cd                	j	80004820 <fileclose+0xa8>

0000000080004840 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004840:	715d                	addi	sp,sp,-80
    80004842:	e486                	sd	ra,72(sp)
    80004844:	e0a2                	sd	s0,64(sp)
    80004846:	fc26                	sd	s1,56(sp)
    80004848:	f84a                	sd	s2,48(sp)
    8000484a:	f44e                	sd	s3,40(sp)
    8000484c:	0880                	addi	s0,sp,80
    8000484e:	84aa                	mv	s1,a0
    80004850:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004852:	ffffd097          	auipc	ra,0xffffd
    80004856:	210080e7          	jalr	528(ra) # 80001a62 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000485a:	409c                	lw	a5,0(s1)
    8000485c:	37f9                	addiw	a5,a5,-2
    8000485e:	4705                	li	a4,1
    80004860:	04f76763          	bltu	a4,a5,800048ae <filestat+0x6e>
    80004864:	892a                	mv	s2,a0
    ilock(f->ip);
    80004866:	6c88                	ld	a0,24(s1)
    80004868:	fffff097          	auipc	ra,0xfffff
    8000486c:	082080e7          	jalr	130(ra) # 800038ea <ilock>
    stati(f->ip, &st);
    80004870:	fb840593          	addi	a1,s0,-72
    80004874:	6c88                	ld	a0,24(s1)
    80004876:	fffff097          	auipc	ra,0xfffff
    8000487a:	2fe080e7          	jalr	766(ra) # 80003b74 <stati>
    iunlock(f->ip);
    8000487e:	6c88                	ld	a0,24(s1)
    80004880:	fffff097          	auipc	ra,0xfffff
    80004884:	12c080e7          	jalr	300(ra) # 800039ac <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004888:	46e1                	li	a3,24
    8000488a:	fb840613          	addi	a2,s0,-72
    8000488e:	85ce                	mv	a1,s3
    80004890:	05093503          	ld	a0,80(s2)
    80004894:	ffffd097          	auipc	ra,0xffffd
    80004898:	ec0080e7          	jalr	-320(ra) # 80001754 <copyout>
    8000489c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048a0:	60a6                	ld	ra,72(sp)
    800048a2:	6406                	ld	s0,64(sp)
    800048a4:	74e2                	ld	s1,56(sp)
    800048a6:	7942                	ld	s2,48(sp)
    800048a8:	79a2                	ld	s3,40(sp)
    800048aa:	6161                	addi	sp,sp,80
    800048ac:	8082                	ret
  return -1;
    800048ae:	557d                	li	a0,-1
    800048b0:	bfc5                	j	800048a0 <filestat+0x60>

00000000800048b2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048b2:	7179                	addi	sp,sp,-48
    800048b4:	f406                	sd	ra,40(sp)
    800048b6:	f022                	sd	s0,32(sp)
    800048b8:	ec26                	sd	s1,24(sp)
    800048ba:	e84a                	sd	s2,16(sp)
    800048bc:	e44e                	sd	s3,8(sp)
    800048be:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048c0:	00854783          	lbu	a5,8(a0)
    800048c4:	c3d5                	beqz	a5,80004968 <fileread+0xb6>
    800048c6:	84aa                	mv	s1,a0
    800048c8:	89ae                	mv	s3,a1
    800048ca:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048cc:	411c                	lw	a5,0(a0)
    800048ce:	4705                	li	a4,1
    800048d0:	04e78963          	beq	a5,a4,80004922 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048d4:	470d                	li	a4,3
    800048d6:	04e78d63          	beq	a5,a4,80004930 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048da:	4709                	li	a4,2
    800048dc:	06e79e63          	bne	a5,a4,80004958 <fileread+0xa6>
    ilock(f->ip);
    800048e0:	6d08                	ld	a0,24(a0)
    800048e2:	fffff097          	auipc	ra,0xfffff
    800048e6:	008080e7          	jalr	8(ra) # 800038ea <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048ea:	874a                	mv	a4,s2
    800048ec:	5094                	lw	a3,32(s1)
    800048ee:	864e                	mv	a2,s3
    800048f0:	4585                	li	a1,1
    800048f2:	6c88                	ld	a0,24(s1)
    800048f4:	fffff097          	auipc	ra,0xfffff
    800048f8:	2aa080e7          	jalr	682(ra) # 80003b9e <readi>
    800048fc:	892a                	mv	s2,a0
    800048fe:	00a05563          	blez	a0,80004908 <fileread+0x56>
      f->off += r;
    80004902:	509c                	lw	a5,32(s1)
    80004904:	9fa9                	addw	a5,a5,a0
    80004906:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004908:	6c88                	ld	a0,24(s1)
    8000490a:	fffff097          	auipc	ra,0xfffff
    8000490e:	0a2080e7          	jalr	162(ra) # 800039ac <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004912:	854a                	mv	a0,s2
    80004914:	70a2                	ld	ra,40(sp)
    80004916:	7402                	ld	s0,32(sp)
    80004918:	64e2                	ld	s1,24(sp)
    8000491a:	6942                	ld	s2,16(sp)
    8000491c:	69a2                	ld	s3,8(sp)
    8000491e:	6145                	addi	sp,sp,48
    80004920:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004922:	6908                	ld	a0,16(a0)
    80004924:	00000097          	auipc	ra,0x0
    80004928:	3f4080e7          	jalr	1012(ra) # 80004d18 <piperead>
    8000492c:	892a                	mv	s2,a0
    8000492e:	b7d5                	j	80004912 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004930:	02451783          	lh	a5,36(a0)
    80004934:	03079693          	slli	a3,a5,0x30
    80004938:	92c1                	srli	a3,a3,0x30
    8000493a:	4725                	li	a4,9
    8000493c:	02d76863          	bltu	a4,a3,8000496c <fileread+0xba>
    80004940:	0792                	slli	a5,a5,0x4
    80004942:	0001e717          	auipc	a4,0x1e
    80004946:	a6e70713          	addi	a4,a4,-1426 # 800223b0 <devsw>
    8000494a:	97ba                	add	a5,a5,a4
    8000494c:	639c                	ld	a5,0(a5)
    8000494e:	c38d                	beqz	a5,80004970 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004950:	4505                	li	a0,1
    80004952:	9782                	jalr	a5
    80004954:	892a                	mv	s2,a0
    80004956:	bf75                	j	80004912 <fileread+0x60>
    panic("fileread");
    80004958:	00004517          	auipc	a0,0x4
    8000495c:	ce850513          	addi	a0,a0,-792 # 80008640 <syscalls+0x268>
    80004960:	ffffc097          	auipc	ra,0xffffc
    80004964:	be2080e7          	jalr	-1054(ra) # 80000542 <panic>
    return -1;
    80004968:	597d                	li	s2,-1
    8000496a:	b765                	j	80004912 <fileread+0x60>
      return -1;
    8000496c:	597d                	li	s2,-1
    8000496e:	b755                	j	80004912 <fileread+0x60>
    80004970:	597d                	li	s2,-1
    80004972:	b745                	j	80004912 <fileread+0x60>

0000000080004974 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004974:	00954783          	lbu	a5,9(a0)
    80004978:	14078563          	beqz	a5,80004ac2 <filewrite+0x14e>
{
    8000497c:	715d                	addi	sp,sp,-80
    8000497e:	e486                	sd	ra,72(sp)
    80004980:	e0a2                	sd	s0,64(sp)
    80004982:	fc26                	sd	s1,56(sp)
    80004984:	f84a                	sd	s2,48(sp)
    80004986:	f44e                	sd	s3,40(sp)
    80004988:	f052                	sd	s4,32(sp)
    8000498a:	ec56                	sd	s5,24(sp)
    8000498c:	e85a                	sd	s6,16(sp)
    8000498e:	e45e                	sd	s7,8(sp)
    80004990:	e062                	sd	s8,0(sp)
    80004992:	0880                	addi	s0,sp,80
    80004994:	892a                	mv	s2,a0
    80004996:	8aae                	mv	s5,a1
    80004998:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000499a:	411c                	lw	a5,0(a0)
    8000499c:	4705                	li	a4,1
    8000499e:	02e78263          	beq	a5,a4,800049c2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049a2:	470d                	li	a4,3
    800049a4:	02e78563          	beq	a5,a4,800049ce <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049a8:	4709                	li	a4,2
    800049aa:	10e79463          	bne	a5,a4,80004ab2 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049ae:	0ec05e63          	blez	a2,80004aaa <filewrite+0x136>
    int i = 0;
    800049b2:	4981                	li	s3,0
    800049b4:	6b05                	lui	s6,0x1
    800049b6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800049ba:	6b85                	lui	s7,0x1
    800049bc:	c00b8b9b          	addiw	s7,s7,-1024
    800049c0:	a851                	j	80004a54 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800049c2:	6908                	ld	a0,16(a0)
    800049c4:	00000097          	auipc	ra,0x0
    800049c8:	254080e7          	jalr	596(ra) # 80004c18 <pipewrite>
    800049cc:	a85d                	j	80004a82 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049ce:	02451783          	lh	a5,36(a0)
    800049d2:	03079693          	slli	a3,a5,0x30
    800049d6:	92c1                	srli	a3,a3,0x30
    800049d8:	4725                	li	a4,9
    800049da:	0ed76663          	bltu	a4,a3,80004ac6 <filewrite+0x152>
    800049de:	0792                	slli	a5,a5,0x4
    800049e0:	0001e717          	auipc	a4,0x1e
    800049e4:	9d070713          	addi	a4,a4,-1584 # 800223b0 <devsw>
    800049e8:	97ba                	add	a5,a5,a4
    800049ea:	679c                	ld	a5,8(a5)
    800049ec:	cff9                	beqz	a5,80004aca <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    800049ee:	4505                	li	a0,1
    800049f0:	9782                	jalr	a5
    800049f2:	a841                	j	80004a82 <filewrite+0x10e>
    800049f4:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800049f8:	00000097          	auipc	ra,0x0
    800049fc:	8ae080e7          	jalr	-1874(ra) # 800042a6 <begin_op>
      ilock(f->ip);
    80004a00:	01893503          	ld	a0,24(s2)
    80004a04:	fffff097          	auipc	ra,0xfffff
    80004a08:	ee6080e7          	jalr	-282(ra) # 800038ea <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a0c:	8762                	mv	a4,s8
    80004a0e:	02092683          	lw	a3,32(s2)
    80004a12:	01598633          	add	a2,s3,s5
    80004a16:	4585                	li	a1,1
    80004a18:	01893503          	ld	a0,24(s2)
    80004a1c:	fffff097          	auipc	ra,0xfffff
    80004a20:	278080e7          	jalr	632(ra) # 80003c94 <writei>
    80004a24:	84aa                	mv	s1,a0
    80004a26:	02a05f63          	blez	a0,80004a64 <filewrite+0xf0>
        f->off += r;
    80004a2a:	02092783          	lw	a5,32(s2)
    80004a2e:	9fa9                	addw	a5,a5,a0
    80004a30:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a34:	01893503          	ld	a0,24(s2)
    80004a38:	fffff097          	auipc	ra,0xfffff
    80004a3c:	f74080e7          	jalr	-140(ra) # 800039ac <iunlock>
      end_op();
    80004a40:	00000097          	auipc	ra,0x0
    80004a44:	8e6080e7          	jalr	-1818(ra) # 80004326 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004a48:	049c1963          	bne	s8,s1,80004a9a <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004a4c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a50:	0349d663          	bge	s3,s4,80004a7c <filewrite+0x108>
      int n1 = n - i;
    80004a54:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a58:	84be                	mv	s1,a5
    80004a5a:	2781                	sext.w	a5,a5
    80004a5c:	f8fb5ce3          	bge	s6,a5,800049f4 <filewrite+0x80>
    80004a60:	84de                	mv	s1,s7
    80004a62:	bf49                	j	800049f4 <filewrite+0x80>
      iunlock(f->ip);
    80004a64:	01893503          	ld	a0,24(s2)
    80004a68:	fffff097          	auipc	ra,0xfffff
    80004a6c:	f44080e7          	jalr	-188(ra) # 800039ac <iunlock>
      end_op();
    80004a70:	00000097          	auipc	ra,0x0
    80004a74:	8b6080e7          	jalr	-1866(ra) # 80004326 <end_op>
      if(r < 0)
    80004a78:	fc04d8e3          	bgez	s1,80004a48 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004a7c:	8552                	mv	a0,s4
    80004a7e:	033a1863          	bne	s4,s3,80004aae <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a82:	60a6                	ld	ra,72(sp)
    80004a84:	6406                	ld	s0,64(sp)
    80004a86:	74e2                	ld	s1,56(sp)
    80004a88:	7942                	ld	s2,48(sp)
    80004a8a:	79a2                	ld	s3,40(sp)
    80004a8c:	7a02                	ld	s4,32(sp)
    80004a8e:	6ae2                	ld	s5,24(sp)
    80004a90:	6b42                	ld	s6,16(sp)
    80004a92:	6ba2                	ld	s7,8(sp)
    80004a94:	6c02                	ld	s8,0(sp)
    80004a96:	6161                	addi	sp,sp,80
    80004a98:	8082                	ret
        panic("short filewrite");
    80004a9a:	00004517          	auipc	a0,0x4
    80004a9e:	bb650513          	addi	a0,a0,-1098 # 80008650 <syscalls+0x278>
    80004aa2:	ffffc097          	auipc	ra,0xffffc
    80004aa6:	aa0080e7          	jalr	-1376(ra) # 80000542 <panic>
    int i = 0;
    80004aaa:	4981                	li	s3,0
    80004aac:	bfc1                	j	80004a7c <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004aae:	557d                	li	a0,-1
    80004ab0:	bfc9                	j	80004a82 <filewrite+0x10e>
    panic("filewrite");
    80004ab2:	00004517          	auipc	a0,0x4
    80004ab6:	bae50513          	addi	a0,a0,-1106 # 80008660 <syscalls+0x288>
    80004aba:	ffffc097          	auipc	ra,0xffffc
    80004abe:	a88080e7          	jalr	-1400(ra) # 80000542 <panic>
    return -1;
    80004ac2:	557d                	li	a0,-1
}
    80004ac4:	8082                	ret
      return -1;
    80004ac6:	557d                	li	a0,-1
    80004ac8:	bf6d                	j	80004a82 <filewrite+0x10e>
    80004aca:	557d                	li	a0,-1
    80004acc:	bf5d                	j	80004a82 <filewrite+0x10e>

0000000080004ace <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ace:	7179                	addi	sp,sp,-48
    80004ad0:	f406                	sd	ra,40(sp)
    80004ad2:	f022                	sd	s0,32(sp)
    80004ad4:	ec26                	sd	s1,24(sp)
    80004ad6:	e84a                	sd	s2,16(sp)
    80004ad8:	e44e                	sd	s3,8(sp)
    80004ada:	e052                	sd	s4,0(sp)
    80004adc:	1800                	addi	s0,sp,48
    80004ade:	84aa                	mv	s1,a0
    80004ae0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ae2:	0005b023          	sd	zero,0(a1)
    80004ae6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004aea:	00000097          	auipc	ra,0x0
    80004aee:	bd2080e7          	jalr	-1070(ra) # 800046bc <filealloc>
    80004af2:	e088                	sd	a0,0(s1)
    80004af4:	c551                	beqz	a0,80004b80 <pipealloc+0xb2>
    80004af6:	00000097          	auipc	ra,0x0
    80004afa:	bc6080e7          	jalr	-1082(ra) # 800046bc <filealloc>
    80004afe:	00aa3023          	sd	a0,0(s4)
    80004b02:	c92d                	beqz	a0,80004b74 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b04:	ffffc097          	auipc	ra,0xffffc
    80004b08:	076080e7          	jalr	118(ra) # 80000b7a <kalloc>
    80004b0c:	892a                	mv	s2,a0
    80004b0e:	c125                	beqz	a0,80004b6e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b10:	4985                	li	s3,1
    80004b12:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b16:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b1a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b1e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b22:	00004597          	auipc	a1,0x4
    80004b26:	b4e58593          	addi	a1,a1,-1202 # 80008670 <syscalls+0x298>
    80004b2a:	ffffc097          	auipc	ra,0xffffc
    80004b2e:	0b0080e7          	jalr	176(ra) # 80000bda <initlock>
  (*f0)->type = FD_PIPE;
    80004b32:	609c                	ld	a5,0(s1)
    80004b34:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b38:	609c                	ld	a5,0(s1)
    80004b3a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b3e:	609c                	ld	a5,0(s1)
    80004b40:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b44:	609c                	ld	a5,0(s1)
    80004b46:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b4a:	000a3783          	ld	a5,0(s4)
    80004b4e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b52:	000a3783          	ld	a5,0(s4)
    80004b56:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b5a:	000a3783          	ld	a5,0(s4)
    80004b5e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b62:	000a3783          	ld	a5,0(s4)
    80004b66:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b6a:	4501                	li	a0,0
    80004b6c:	a025                	j	80004b94 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b6e:	6088                	ld	a0,0(s1)
    80004b70:	e501                	bnez	a0,80004b78 <pipealloc+0xaa>
    80004b72:	a039                	j	80004b80 <pipealloc+0xb2>
    80004b74:	6088                	ld	a0,0(s1)
    80004b76:	c51d                	beqz	a0,80004ba4 <pipealloc+0xd6>
    fileclose(*f0);
    80004b78:	00000097          	auipc	ra,0x0
    80004b7c:	c00080e7          	jalr	-1024(ra) # 80004778 <fileclose>
  if(*f1)
    80004b80:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b84:	557d                	li	a0,-1
  if(*f1)
    80004b86:	c799                	beqz	a5,80004b94 <pipealloc+0xc6>
    fileclose(*f1);
    80004b88:	853e                	mv	a0,a5
    80004b8a:	00000097          	auipc	ra,0x0
    80004b8e:	bee080e7          	jalr	-1042(ra) # 80004778 <fileclose>
  return -1;
    80004b92:	557d                	li	a0,-1
}
    80004b94:	70a2                	ld	ra,40(sp)
    80004b96:	7402                	ld	s0,32(sp)
    80004b98:	64e2                	ld	s1,24(sp)
    80004b9a:	6942                	ld	s2,16(sp)
    80004b9c:	69a2                	ld	s3,8(sp)
    80004b9e:	6a02                	ld	s4,0(sp)
    80004ba0:	6145                	addi	sp,sp,48
    80004ba2:	8082                	ret
  return -1;
    80004ba4:	557d                	li	a0,-1
    80004ba6:	b7fd                	j	80004b94 <pipealloc+0xc6>

0000000080004ba8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004ba8:	1101                	addi	sp,sp,-32
    80004baa:	ec06                	sd	ra,24(sp)
    80004bac:	e822                	sd	s0,16(sp)
    80004bae:	e426                	sd	s1,8(sp)
    80004bb0:	e04a                	sd	s2,0(sp)
    80004bb2:	1000                	addi	s0,sp,32
    80004bb4:	84aa                	mv	s1,a0
    80004bb6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bb8:	ffffc097          	auipc	ra,0xffffc
    80004bbc:	0b2080e7          	jalr	178(ra) # 80000c6a <acquire>
  if(writable){
    80004bc0:	02090d63          	beqz	s2,80004bfa <pipeclose+0x52>
    pi->writeopen = 0;
    80004bc4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bc8:	21848513          	addi	a0,s1,536
    80004bcc:	ffffe097          	auipc	ra,0xffffe
    80004bd0:	856080e7          	jalr	-1962(ra) # 80002422 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bd4:	2204b783          	ld	a5,544(s1)
    80004bd8:	eb95                	bnez	a5,80004c0c <pipeclose+0x64>
    release(&pi->lock);
    80004bda:	8526                	mv	a0,s1
    80004bdc:	ffffc097          	auipc	ra,0xffffc
    80004be0:	142080e7          	jalr	322(ra) # 80000d1e <release>
    kfree((char*)pi);
    80004be4:	8526                	mv	a0,s1
    80004be6:	ffffc097          	auipc	ra,0xffffc
    80004bea:	e98080e7          	jalr	-360(ra) # 80000a7e <kfree>
  } else
    release(&pi->lock);
}
    80004bee:	60e2                	ld	ra,24(sp)
    80004bf0:	6442                	ld	s0,16(sp)
    80004bf2:	64a2                	ld	s1,8(sp)
    80004bf4:	6902                	ld	s2,0(sp)
    80004bf6:	6105                	addi	sp,sp,32
    80004bf8:	8082                	ret
    pi->readopen = 0;
    80004bfa:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004bfe:	21c48513          	addi	a0,s1,540
    80004c02:	ffffe097          	auipc	ra,0xffffe
    80004c06:	820080e7          	jalr	-2016(ra) # 80002422 <wakeup>
    80004c0a:	b7e9                	j	80004bd4 <pipeclose+0x2c>
    release(&pi->lock);
    80004c0c:	8526                	mv	a0,s1
    80004c0e:	ffffc097          	auipc	ra,0xffffc
    80004c12:	110080e7          	jalr	272(ra) # 80000d1e <release>
}
    80004c16:	bfe1                	j	80004bee <pipeclose+0x46>

0000000080004c18 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c18:	711d                	addi	sp,sp,-96
    80004c1a:	ec86                	sd	ra,88(sp)
    80004c1c:	e8a2                	sd	s0,80(sp)
    80004c1e:	e4a6                	sd	s1,72(sp)
    80004c20:	e0ca                	sd	s2,64(sp)
    80004c22:	fc4e                	sd	s3,56(sp)
    80004c24:	f852                	sd	s4,48(sp)
    80004c26:	f456                	sd	s5,40(sp)
    80004c28:	f05a                	sd	s6,32(sp)
    80004c2a:	ec5e                	sd	s7,24(sp)
    80004c2c:	e862                	sd	s8,16(sp)
    80004c2e:	1080                	addi	s0,sp,96
    80004c30:	84aa                	mv	s1,a0
    80004c32:	8b2e                	mv	s6,a1
    80004c34:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004c36:	ffffd097          	auipc	ra,0xffffd
    80004c3a:	e2c080e7          	jalr	-468(ra) # 80001a62 <myproc>
    80004c3e:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004c40:	8526                	mv	a0,s1
    80004c42:	ffffc097          	auipc	ra,0xffffc
    80004c46:	028080e7          	jalr	40(ra) # 80000c6a <acquire>
  for(i = 0; i < n; i++){
    80004c4a:	09505763          	blez	s5,80004cd8 <pipewrite+0xc0>
    80004c4e:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004c50:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c54:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c58:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c5a:	2184a783          	lw	a5,536(s1)
    80004c5e:	21c4a703          	lw	a4,540(s1)
    80004c62:	2007879b          	addiw	a5,a5,512
    80004c66:	02f71b63          	bne	a4,a5,80004c9c <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    80004c6a:	2204a783          	lw	a5,544(s1)
    80004c6e:	c3d1                	beqz	a5,80004cf2 <pipewrite+0xda>
    80004c70:	03092783          	lw	a5,48(s2)
    80004c74:	efbd                	bnez	a5,80004cf2 <pipewrite+0xda>
      wakeup(&pi->nread);
    80004c76:	8552                	mv	a0,s4
    80004c78:	ffffd097          	auipc	ra,0xffffd
    80004c7c:	7aa080e7          	jalr	1962(ra) # 80002422 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c80:	85a6                	mv	a1,s1
    80004c82:	854e                	mv	a0,s3
    80004c84:	ffffd097          	auipc	ra,0xffffd
    80004c88:	61e080e7          	jalr	1566(ra) # 800022a2 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c8c:	2184a783          	lw	a5,536(s1)
    80004c90:	21c4a703          	lw	a4,540(s1)
    80004c94:	2007879b          	addiw	a5,a5,512
    80004c98:	fcf709e3          	beq	a4,a5,80004c6a <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c9c:	4685                	li	a3,1
    80004c9e:	865a                	mv	a2,s6
    80004ca0:	faf40593          	addi	a1,s0,-81
    80004ca4:	05093503          	ld	a0,80(s2)
    80004ca8:	ffffd097          	auipc	ra,0xffffd
    80004cac:	b38080e7          	jalr	-1224(ra) # 800017e0 <copyin>
    80004cb0:	03850563          	beq	a0,s8,80004cda <pipewrite+0xc2>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cb4:	21c4a783          	lw	a5,540(s1)
    80004cb8:	0017871b          	addiw	a4,a5,1
    80004cbc:	20e4ae23          	sw	a4,540(s1)
    80004cc0:	1ff7f793          	andi	a5,a5,511
    80004cc4:	97a6                	add	a5,a5,s1
    80004cc6:	faf44703          	lbu	a4,-81(s0)
    80004cca:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004cce:	2b85                	addiw	s7,s7,1
    80004cd0:	0b05                	addi	s6,s6,1
    80004cd2:	f97a94e3          	bne	s5,s7,80004c5a <pipewrite+0x42>
    80004cd6:	a011                	j	80004cda <pipewrite+0xc2>
    80004cd8:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    80004cda:	21848513          	addi	a0,s1,536
    80004cde:	ffffd097          	auipc	ra,0xffffd
    80004ce2:	744080e7          	jalr	1860(ra) # 80002422 <wakeup>
  release(&pi->lock);
    80004ce6:	8526                	mv	a0,s1
    80004ce8:	ffffc097          	auipc	ra,0xffffc
    80004cec:	036080e7          	jalr	54(ra) # 80000d1e <release>
  return i;
    80004cf0:	a039                	j	80004cfe <pipewrite+0xe6>
        release(&pi->lock);
    80004cf2:	8526                	mv	a0,s1
    80004cf4:	ffffc097          	auipc	ra,0xffffc
    80004cf8:	02a080e7          	jalr	42(ra) # 80000d1e <release>
        return -1;
    80004cfc:	5bfd                	li	s7,-1
}
    80004cfe:	855e                	mv	a0,s7
    80004d00:	60e6                	ld	ra,88(sp)
    80004d02:	6446                	ld	s0,80(sp)
    80004d04:	64a6                	ld	s1,72(sp)
    80004d06:	6906                	ld	s2,64(sp)
    80004d08:	79e2                	ld	s3,56(sp)
    80004d0a:	7a42                	ld	s4,48(sp)
    80004d0c:	7aa2                	ld	s5,40(sp)
    80004d0e:	7b02                	ld	s6,32(sp)
    80004d10:	6be2                	ld	s7,24(sp)
    80004d12:	6c42                	ld	s8,16(sp)
    80004d14:	6125                	addi	sp,sp,96
    80004d16:	8082                	ret

0000000080004d18 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d18:	715d                	addi	sp,sp,-80
    80004d1a:	e486                	sd	ra,72(sp)
    80004d1c:	e0a2                	sd	s0,64(sp)
    80004d1e:	fc26                	sd	s1,56(sp)
    80004d20:	f84a                	sd	s2,48(sp)
    80004d22:	f44e                	sd	s3,40(sp)
    80004d24:	f052                	sd	s4,32(sp)
    80004d26:	ec56                	sd	s5,24(sp)
    80004d28:	e85a                	sd	s6,16(sp)
    80004d2a:	0880                	addi	s0,sp,80
    80004d2c:	84aa                	mv	s1,a0
    80004d2e:	892e                	mv	s2,a1
    80004d30:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d32:	ffffd097          	auipc	ra,0xffffd
    80004d36:	d30080e7          	jalr	-720(ra) # 80001a62 <myproc>
    80004d3a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d3c:	8526                	mv	a0,s1
    80004d3e:	ffffc097          	auipc	ra,0xffffc
    80004d42:	f2c080e7          	jalr	-212(ra) # 80000c6a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d46:	2184a703          	lw	a4,536(s1)
    80004d4a:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d4e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d52:	02f71463          	bne	a4,a5,80004d7a <piperead+0x62>
    80004d56:	2244a783          	lw	a5,548(s1)
    80004d5a:	c385                	beqz	a5,80004d7a <piperead+0x62>
    if(pr->killed){
    80004d5c:	030a2783          	lw	a5,48(s4)
    80004d60:	ebc1                	bnez	a5,80004df0 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d62:	85a6                	mv	a1,s1
    80004d64:	854e                	mv	a0,s3
    80004d66:	ffffd097          	auipc	ra,0xffffd
    80004d6a:	53c080e7          	jalr	1340(ra) # 800022a2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d6e:	2184a703          	lw	a4,536(s1)
    80004d72:	21c4a783          	lw	a5,540(s1)
    80004d76:	fef700e3          	beq	a4,a5,80004d56 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d7a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d7c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d7e:	05505363          	blez	s5,80004dc4 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004d82:	2184a783          	lw	a5,536(s1)
    80004d86:	21c4a703          	lw	a4,540(s1)
    80004d8a:	02f70d63          	beq	a4,a5,80004dc4 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d8e:	0017871b          	addiw	a4,a5,1
    80004d92:	20e4ac23          	sw	a4,536(s1)
    80004d96:	1ff7f793          	andi	a5,a5,511
    80004d9a:	97a6                	add	a5,a5,s1
    80004d9c:	0187c783          	lbu	a5,24(a5)
    80004da0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004da4:	4685                	li	a3,1
    80004da6:	fbf40613          	addi	a2,s0,-65
    80004daa:	85ca                	mv	a1,s2
    80004dac:	050a3503          	ld	a0,80(s4)
    80004db0:	ffffd097          	auipc	ra,0xffffd
    80004db4:	9a4080e7          	jalr	-1628(ra) # 80001754 <copyout>
    80004db8:	01650663          	beq	a0,s6,80004dc4 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dbc:	2985                	addiw	s3,s3,1
    80004dbe:	0905                	addi	s2,s2,1
    80004dc0:	fd3a91e3          	bne	s5,s3,80004d82 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004dc4:	21c48513          	addi	a0,s1,540
    80004dc8:	ffffd097          	auipc	ra,0xffffd
    80004dcc:	65a080e7          	jalr	1626(ra) # 80002422 <wakeup>
  release(&pi->lock);
    80004dd0:	8526                	mv	a0,s1
    80004dd2:	ffffc097          	auipc	ra,0xffffc
    80004dd6:	f4c080e7          	jalr	-180(ra) # 80000d1e <release>
  return i;
}
    80004dda:	854e                	mv	a0,s3
    80004ddc:	60a6                	ld	ra,72(sp)
    80004dde:	6406                	ld	s0,64(sp)
    80004de0:	74e2                	ld	s1,56(sp)
    80004de2:	7942                	ld	s2,48(sp)
    80004de4:	79a2                	ld	s3,40(sp)
    80004de6:	7a02                	ld	s4,32(sp)
    80004de8:	6ae2                	ld	s5,24(sp)
    80004dea:	6b42                	ld	s6,16(sp)
    80004dec:	6161                	addi	sp,sp,80
    80004dee:	8082                	ret
      release(&pi->lock);
    80004df0:	8526                	mv	a0,s1
    80004df2:	ffffc097          	auipc	ra,0xffffc
    80004df6:	f2c080e7          	jalr	-212(ra) # 80000d1e <release>
      return -1;
    80004dfa:	59fd                	li	s3,-1
    80004dfc:	bff9                	j	80004dda <piperead+0xc2>

0000000080004dfe <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004dfe:	de010113          	addi	sp,sp,-544
    80004e02:	20113c23          	sd	ra,536(sp)
    80004e06:	20813823          	sd	s0,528(sp)
    80004e0a:	20913423          	sd	s1,520(sp)
    80004e0e:	21213023          	sd	s2,512(sp)
    80004e12:	ffce                	sd	s3,504(sp)
    80004e14:	fbd2                	sd	s4,496(sp)
    80004e16:	f7d6                	sd	s5,488(sp)
    80004e18:	f3da                	sd	s6,480(sp)
    80004e1a:	efde                	sd	s7,472(sp)
    80004e1c:	ebe2                	sd	s8,464(sp)
    80004e1e:	e7e6                	sd	s9,456(sp)
    80004e20:	e3ea                	sd	s10,448(sp)
    80004e22:	ff6e                	sd	s11,440(sp)
    80004e24:	1400                	addi	s0,sp,544
    80004e26:	892a                	mv	s2,a0
    80004e28:	dea43423          	sd	a0,-536(s0)
    80004e2c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e30:	ffffd097          	auipc	ra,0xffffd
    80004e34:	c32080e7          	jalr	-974(ra) # 80001a62 <myproc>
    80004e38:	84aa                	mv	s1,a0

  begin_op();
    80004e3a:	fffff097          	auipc	ra,0xfffff
    80004e3e:	46c080e7          	jalr	1132(ra) # 800042a6 <begin_op>

  if((ip = namei(path)) == 0){
    80004e42:	854a                	mv	a0,s2
    80004e44:	fffff097          	auipc	ra,0xfffff
    80004e48:	256080e7          	jalr	598(ra) # 8000409a <namei>
    80004e4c:	c93d                	beqz	a0,80004ec2 <exec+0xc4>
    80004e4e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e50:	fffff097          	auipc	ra,0xfffff
    80004e54:	a9a080e7          	jalr	-1382(ra) # 800038ea <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e58:	04000713          	li	a4,64
    80004e5c:	4681                	li	a3,0
    80004e5e:	e4840613          	addi	a2,s0,-440
    80004e62:	4581                	li	a1,0
    80004e64:	8556                	mv	a0,s5
    80004e66:	fffff097          	auipc	ra,0xfffff
    80004e6a:	d38080e7          	jalr	-712(ra) # 80003b9e <readi>
    80004e6e:	04000793          	li	a5,64
    80004e72:	00f51a63          	bne	a0,a5,80004e86 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e76:	e4842703          	lw	a4,-440(s0)
    80004e7a:	464c47b7          	lui	a5,0x464c4
    80004e7e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e82:	04f70663          	beq	a4,a5,80004ece <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e86:	8556                	mv	a0,s5
    80004e88:	fffff097          	auipc	ra,0xfffff
    80004e8c:	cc4080e7          	jalr	-828(ra) # 80003b4c <iunlockput>
    end_op();
    80004e90:	fffff097          	auipc	ra,0xfffff
    80004e94:	496080e7          	jalr	1174(ra) # 80004326 <end_op>
  }
  return -1;
    80004e98:	557d                	li	a0,-1
}
    80004e9a:	21813083          	ld	ra,536(sp)
    80004e9e:	21013403          	ld	s0,528(sp)
    80004ea2:	20813483          	ld	s1,520(sp)
    80004ea6:	20013903          	ld	s2,512(sp)
    80004eaa:	79fe                	ld	s3,504(sp)
    80004eac:	7a5e                	ld	s4,496(sp)
    80004eae:	7abe                	ld	s5,488(sp)
    80004eb0:	7b1e                	ld	s6,480(sp)
    80004eb2:	6bfe                	ld	s7,472(sp)
    80004eb4:	6c5e                	ld	s8,464(sp)
    80004eb6:	6cbe                	ld	s9,456(sp)
    80004eb8:	6d1e                	ld	s10,448(sp)
    80004eba:	7dfa                	ld	s11,440(sp)
    80004ebc:	22010113          	addi	sp,sp,544
    80004ec0:	8082                	ret
    end_op();
    80004ec2:	fffff097          	auipc	ra,0xfffff
    80004ec6:	464080e7          	jalr	1124(ra) # 80004326 <end_op>
    return -1;
    80004eca:	557d                	li	a0,-1
    80004ecc:	b7f9                	j	80004e9a <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ece:	8526                	mv	a0,s1
    80004ed0:	ffffd097          	auipc	ra,0xffffd
    80004ed4:	c56080e7          	jalr	-938(ra) # 80001b26 <proc_pagetable>
    80004ed8:	8b2a                	mv	s6,a0
    80004eda:	d555                	beqz	a0,80004e86 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004edc:	e6842783          	lw	a5,-408(s0)
    80004ee0:	e8045703          	lhu	a4,-384(s0)
    80004ee4:	c735                	beqz	a4,80004f50 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004ee6:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ee8:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004eec:	6a05                	lui	s4,0x1
    80004eee:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004ef2:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004ef6:	6d85                	lui	s11,0x1
    80004ef8:	7d7d                	lui	s10,0xfffff
    80004efa:	ac1d                	j	80005130 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004efc:	00003517          	auipc	a0,0x3
    80004f00:	77c50513          	addi	a0,a0,1916 # 80008678 <syscalls+0x2a0>
    80004f04:	ffffb097          	auipc	ra,0xffffb
    80004f08:	63e080e7          	jalr	1598(ra) # 80000542 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f0c:	874a                	mv	a4,s2
    80004f0e:	009c86bb          	addw	a3,s9,s1
    80004f12:	4581                	li	a1,0
    80004f14:	8556                	mv	a0,s5
    80004f16:	fffff097          	auipc	ra,0xfffff
    80004f1a:	c88080e7          	jalr	-888(ra) # 80003b9e <readi>
    80004f1e:	2501                	sext.w	a0,a0
    80004f20:	1aa91863          	bne	s2,a0,800050d0 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004f24:	009d84bb          	addw	s1,s11,s1
    80004f28:	013d09bb          	addw	s3,s10,s3
    80004f2c:	1f74f263          	bgeu	s1,s7,80005110 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004f30:	02049593          	slli	a1,s1,0x20
    80004f34:	9181                	srli	a1,a1,0x20
    80004f36:	95e2                	add	a1,a1,s8
    80004f38:	855a                	mv	a0,s6
    80004f3a:	ffffc097          	auipc	ra,0xffffc
    80004f3e:	2a6080e7          	jalr	678(ra) # 800011e0 <walkaddr>
    80004f42:	862a                	mv	a2,a0
    if(pa == 0)
    80004f44:	dd45                	beqz	a0,80004efc <exec+0xfe>
      n = PGSIZE;
    80004f46:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f48:	fd49f2e3          	bgeu	s3,s4,80004f0c <exec+0x10e>
      n = sz - i;
    80004f4c:	894e                	mv	s2,s3
    80004f4e:	bf7d                	j	80004f0c <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f50:	4481                	li	s1,0
  iunlockput(ip);
    80004f52:	8556                	mv	a0,s5
    80004f54:	fffff097          	auipc	ra,0xfffff
    80004f58:	bf8080e7          	jalr	-1032(ra) # 80003b4c <iunlockput>
  end_op();
    80004f5c:	fffff097          	auipc	ra,0xfffff
    80004f60:	3ca080e7          	jalr	970(ra) # 80004326 <end_op>
  p = myproc();
    80004f64:	ffffd097          	auipc	ra,0xffffd
    80004f68:	afe080e7          	jalr	-1282(ra) # 80001a62 <myproc>
    80004f6c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004f6e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f72:	6785                	lui	a5,0x1
    80004f74:	17fd                	addi	a5,a5,-1
    80004f76:	94be                	add	s1,s1,a5
    80004f78:	77fd                	lui	a5,0xfffff
    80004f7a:	8fe5                	and	a5,a5,s1
    80004f7c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f80:	6609                	lui	a2,0x2
    80004f82:	963e                	add	a2,a2,a5
    80004f84:	85be                	mv	a1,a5
    80004f86:	855a                	mv	a0,s6
    80004f88:	ffffc097          	auipc	ra,0xffffc
    80004f8c:	598080e7          	jalr	1432(ra) # 80001520 <uvmalloc>
    80004f90:	8c2a                	mv	s8,a0
  ip = 0;
    80004f92:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f94:	12050e63          	beqz	a0,800050d0 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f98:	75f9                	lui	a1,0xffffe
    80004f9a:	95aa                	add	a1,a1,a0
    80004f9c:	855a                	mv	a0,s6
    80004f9e:	ffffc097          	auipc	ra,0xffffc
    80004fa2:	784080e7          	jalr	1924(ra) # 80001722 <uvmclear>
  stackbase = sp - PGSIZE;
    80004fa6:	7afd                	lui	s5,0xfffff
    80004fa8:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004faa:	df043783          	ld	a5,-528(s0)
    80004fae:	6388                	ld	a0,0(a5)
    80004fb0:	c925                	beqz	a0,80005020 <exec+0x222>
    80004fb2:	e8840993          	addi	s3,s0,-376
    80004fb6:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004fba:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004fbc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	f2c080e7          	jalr	-212(ra) # 80000eea <strlen>
    80004fc6:	0015079b          	addiw	a5,a0,1
    80004fca:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fce:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004fd2:	13596363          	bltu	s2,s5,800050f8 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fd6:	df043d83          	ld	s11,-528(s0)
    80004fda:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004fde:	8552                	mv	a0,s4
    80004fe0:	ffffc097          	auipc	ra,0xffffc
    80004fe4:	f0a080e7          	jalr	-246(ra) # 80000eea <strlen>
    80004fe8:	0015069b          	addiw	a3,a0,1
    80004fec:	8652                	mv	a2,s4
    80004fee:	85ca                	mv	a1,s2
    80004ff0:	855a                	mv	a0,s6
    80004ff2:	ffffc097          	auipc	ra,0xffffc
    80004ff6:	762080e7          	jalr	1890(ra) # 80001754 <copyout>
    80004ffa:	10054363          	bltz	a0,80005100 <exec+0x302>
    ustack[argc] = sp;
    80004ffe:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005002:	0485                	addi	s1,s1,1
    80005004:	008d8793          	addi	a5,s11,8
    80005008:	def43823          	sd	a5,-528(s0)
    8000500c:	008db503          	ld	a0,8(s11)
    80005010:	c911                	beqz	a0,80005024 <exec+0x226>
    if(argc >= MAXARG)
    80005012:	09a1                	addi	s3,s3,8
    80005014:	fb3c95e3          	bne	s9,s3,80004fbe <exec+0x1c0>
  sz = sz1;
    80005018:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000501c:	4a81                	li	s5,0
    8000501e:	a84d                	j	800050d0 <exec+0x2d2>
  sp = sz;
    80005020:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005022:	4481                	li	s1,0
  ustack[argc] = 0;
    80005024:	00349793          	slli	a5,s1,0x3
    80005028:	f9040713          	addi	a4,s0,-112
    8000502c:	97ba                	add	a5,a5,a4
    8000502e:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd7ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005032:	00148693          	addi	a3,s1,1
    80005036:	068e                	slli	a3,a3,0x3
    80005038:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000503c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005040:	01597663          	bgeu	s2,s5,8000504c <exec+0x24e>
  sz = sz1;
    80005044:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005048:	4a81                	li	s5,0
    8000504a:	a059                	j	800050d0 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000504c:	e8840613          	addi	a2,s0,-376
    80005050:	85ca                	mv	a1,s2
    80005052:	855a                	mv	a0,s6
    80005054:	ffffc097          	auipc	ra,0xffffc
    80005058:	700080e7          	jalr	1792(ra) # 80001754 <copyout>
    8000505c:	0a054663          	bltz	a0,80005108 <exec+0x30a>
  p->trapframe->a1 = sp;
    80005060:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005064:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005068:	de843783          	ld	a5,-536(s0)
    8000506c:	0007c703          	lbu	a4,0(a5)
    80005070:	cf11                	beqz	a4,8000508c <exec+0x28e>
    80005072:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005074:	02f00693          	li	a3,47
    80005078:	a039                	j	80005086 <exec+0x288>
      last = s+1;
    8000507a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000507e:	0785                	addi	a5,a5,1
    80005080:	fff7c703          	lbu	a4,-1(a5)
    80005084:	c701                	beqz	a4,8000508c <exec+0x28e>
    if(*s == '/')
    80005086:	fed71ce3          	bne	a4,a3,8000507e <exec+0x280>
    8000508a:	bfc5                	j	8000507a <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000508c:	4641                	li	a2,16
    8000508e:	de843583          	ld	a1,-536(s0)
    80005092:	158b8513          	addi	a0,s7,344
    80005096:	ffffc097          	auipc	ra,0xffffc
    8000509a:	e22080e7          	jalr	-478(ra) # 80000eb8 <safestrcpy>
  oldpagetable = p->pagetable;
    8000509e:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800050a2:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800050a6:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050aa:	058bb783          	ld	a5,88(s7)
    800050ae:	e6043703          	ld	a4,-416(s0)
    800050b2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050b4:	058bb783          	ld	a5,88(s7)
    800050b8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050bc:	85ea                	mv	a1,s10
    800050be:	ffffd097          	auipc	ra,0xffffd
    800050c2:	b04080e7          	jalr	-1276(ra) # 80001bc2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050c6:	0004851b          	sext.w	a0,s1
    800050ca:	bbc1                	j	80004e9a <exec+0x9c>
    800050cc:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800050d0:	df843583          	ld	a1,-520(s0)
    800050d4:	855a                	mv	a0,s6
    800050d6:	ffffd097          	auipc	ra,0xffffd
    800050da:	aec080e7          	jalr	-1300(ra) # 80001bc2 <proc_freepagetable>
  if(ip){
    800050de:	da0a94e3          	bnez	s5,80004e86 <exec+0x88>
  return -1;
    800050e2:	557d                	li	a0,-1
    800050e4:	bb5d                	j	80004e9a <exec+0x9c>
    800050e6:	de943c23          	sd	s1,-520(s0)
    800050ea:	b7dd                	j	800050d0 <exec+0x2d2>
    800050ec:	de943c23          	sd	s1,-520(s0)
    800050f0:	b7c5                	j	800050d0 <exec+0x2d2>
    800050f2:	de943c23          	sd	s1,-520(s0)
    800050f6:	bfe9                	j	800050d0 <exec+0x2d2>
  sz = sz1;
    800050f8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050fc:	4a81                	li	s5,0
    800050fe:	bfc9                	j	800050d0 <exec+0x2d2>
  sz = sz1;
    80005100:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005104:	4a81                	li	s5,0
    80005106:	b7e9                	j	800050d0 <exec+0x2d2>
  sz = sz1;
    80005108:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000510c:	4a81                	li	s5,0
    8000510e:	b7c9                	j	800050d0 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005110:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005114:	e0843783          	ld	a5,-504(s0)
    80005118:	0017869b          	addiw	a3,a5,1
    8000511c:	e0d43423          	sd	a3,-504(s0)
    80005120:	e0043783          	ld	a5,-512(s0)
    80005124:	0387879b          	addiw	a5,a5,56
    80005128:	e8045703          	lhu	a4,-384(s0)
    8000512c:	e2e6d3e3          	bge	a3,a4,80004f52 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005130:	2781                	sext.w	a5,a5
    80005132:	e0f43023          	sd	a5,-512(s0)
    80005136:	03800713          	li	a4,56
    8000513a:	86be                	mv	a3,a5
    8000513c:	e1040613          	addi	a2,s0,-496
    80005140:	4581                	li	a1,0
    80005142:	8556                	mv	a0,s5
    80005144:	fffff097          	auipc	ra,0xfffff
    80005148:	a5a080e7          	jalr	-1446(ra) # 80003b9e <readi>
    8000514c:	03800793          	li	a5,56
    80005150:	f6f51ee3          	bne	a0,a5,800050cc <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80005154:	e1042783          	lw	a5,-496(s0)
    80005158:	4705                	li	a4,1
    8000515a:	fae79de3          	bne	a5,a4,80005114 <exec+0x316>
    if(ph.memsz < ph.filesz)
    8000515e:	e3843603          	ld	a2,-456(s0)
    80005162:	e3043783          	ld	a5,-464(s0)
    80005166:	f8f660e3          	bltu	a2,a5,800050e6 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000516a:	e2043783          	ld	a5,-480(s0)
    8000516e:	963e                	add	a2,a2,a5
    80005170:	f6f66ee3          	bltu	a2,a5,800050ec <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005174:	85a6                	mv	a1,s1
    80005176:	855a                	mv	a0,s6
    80005178:	ffffc097          	auipc	ra,0xffffc
    8000517c:	3a8080e7          	jalr	936(ra) # 80001520 <uvmalloc>
    80005180:	dea43c23          	sd	a0,-520(s0)
    80005184:	d53d                	beqz	a0,800050f2 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80005186:	e2043c03          	ld	s8,-480(s0)
    8000518a:	de043783          	ld	a5,-544(s0)
    8000518e:	00fc77b3          	and	a5,s8,a5
    80005192:	ff9d                	bnez	a5,800050d0 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005194:	e1842c83          	lw	s9,-488(s0)
    80005198:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000519c:	f60b8ae3          	beqz	s7,80005110 <exec+0x312>
    800051a0:	89de                	mv	s3,s7
    800051a2:	4481                	li	s1,0
    800051a4:	b371                	j	80004f30 <exec+0x132>

00000000800051a6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051a6:	7179                	addi	sp,sp,-48
    800051a8:	f406                	sd	ra,40(sp)
    800051aa:	f022                	sd	s0,32(sp)
    800051ac:	ec26                	sd	s1,24(sp)
    800051ae:	e84a                	sd	s2,16(sp)
    800051b0:	1800                	addi	s0,sp,48
    800051b2:	892e                	mv	s2,a1
    800051b4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800051b6:	fdc40593          	addi	a1,s0,-36
    800051ba:	ffffe097          	auipc	ra,0xffffe
    800051be:	b18080e7          	jalr	-1256(ra) # 80002cd2 <argint>
    800051c2:	04054063          	bltz	a0,80005202 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051c6:	fdc42703          	lw	a4,-36(s0)
    800051ca:	47bd                	li	a5,15
    800051cc:	02e7ed63          	bltu	a5,a4,80005206 <argfd+0x60>
    800051d0:	ffffd097          	auipc	ra,0xffffd
    800051d4:	892080e7          	jalr	-1902(ra) # 80001a62 <myproc>
    800051d8:	fdc42703          	lw	a4,-36(s0)
    800051dc:	01a70793          	addi	a5,a4,26
    800051e0:	078e                	slli	a5,a5,0x3
    800051e2:	953e                	add	a0,a0,a5
    800051e4:	611c                	ld	a5,0(a0)
    800051e6:	c395                	beqz	a5,8000520a <argfd+0x64>
    return -1;
  if(pfd)
    800051e8:	00090463          	beqz	s2,800051f0 <argfd+0x4a>
    *pfd = fd;
    800051ec:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051f0:	4501                	li	a0,0
  if(pf)
    800051f2:	c091                	beqz	s1,800051f6 <argfd+0x50>
    *pf = f;
    800051f4:	e09c                	sd	a5,0(s1)
}
    800051f6:	70a2                	ld	ra,40(sp)
    800051f8:	7402                	ld	s0,32(sp)
    800051fa:	64e2                	ld	s1,24(sp)
    800051fc:	6942                	ld	s2,16(sp)
    800051fe:	6145                	addi	sp,sp,48
    80005200:	8082                	ret
    return -1;
    80005202:	557d                	li	a0,-1
    80005204:	bfcd                	j	800051f6 <argfd+0x50>
    return -1;
    80005206:	557d                	li	a0,-1
    80005208:	b7fd                	j	800051f6 <argfd+0x50>
    8000520a:	557d                	li	a0,-1
    8000520c:	b7ed                	j	800051f6 <argfd+0x50>

000000008000520e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000520e:	1101                	addi	sp,sp,-32
    80005210:	ec06                	sd	ra,24(sp)
    80005212:	e822                	sd	s0,16(sp)
    80005214:	e426                	sd	s1,8(sp)
    80005216:	1000                	addi	s0,sp,32
    80005218:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000521a:	ffffd097          	auipc	ra,0xffffd
    8000521e:	848080e7          	jalr	-1976(ra) # 80001a62 <myproc>
    80005222:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005224:	0d050793          	addi	a5,a0,208
    80005228:	4501                	li	a0,0
    8000522a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000522c:	6398                	ld	a4,0(a5)
    8000522e:	cb19                	beqz	a4,80005244 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005230:	2505                	addiw	a0,a0,1
    80005232:	07a1                	addi	a5,a5,8
    80005234:	fed51ce3          	bne	a0,a3,8000522c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005238:	557d                	li	a0,-1
}
    8000523a:	60e2                	ld	ra,24(sp)
    8000523c:	6442                	ld	s0,16(sp)
    8000523e:	64a2                	ld	s1,8(sp)
    80005240:	6105                	addi	sp,sp,32
    80005242:	8082                	ret
      p->ofile[fd] = f;
    80005244:	01a50793          	addi	a5,a0,26
    80005248:	078e                	slli	a5,a5,0x3
    8000524a:	963e                	add	a2,a2,a5
    8000524c:	e204                	sd	s1,0(a2)
      return fd;
    8000524e:	b7f5                	j	8000523a <fdalloc+0x2c>

0000000080005250 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005250:	715d                	addi	sp,sp,-80
    80005252:	e486                	sd	ra,72(sp)
    80005254:	e0a2                	sd	s0,64(sp)
    80005256:	fc26                	sd	s1,56(sp)
    80005258:	f84a                	sd	s2,48(sp)
    8000525a:	f44e                	sd	s3,40(sp)
    8000525c:	f052                	sd	s4,32(sp)
    8000525e:	ec56                	sd	s5,24(sp)
    80005260:	0880                	addi	s0,sp,80
    80005262:	89ae                	mv	s3,a1
    80005264:	8ab2                	mv	s5,a2
    80005266:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005268:	fb040593          	addi	a1,s0,-80
    8000526c:	fffff097          	auipc	ra,0xfffff
    80005270:	e4c080e7          	jalr	-436(ra) # 800040b8 <nameiparent>
    80005274:	892a                	mv	s2,a0
    80005276:	12050e63          	beqz	a0,800053b2 <create+0x162>
    return 0;

  ilock(dp);
    8000527a:	ffffe097          	auipc	ra,0xffffe
    8000527e:	670080e7          	jalr	1648(ra) # 800038ea <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005282:	4601                	li	a2,0
    80005284:	fb040593          	addi	a1,s0,-80
    80005288:	854a                	mv	a0,s2
    8000528a:	fffff097          	auipc	ra,0xfffff
    8000528e:	b3e080e7          	jalr	-1218(ra) # 80003dc8 <dirlookup>
    80005292:	84aa                	mv	s1,a0
    80005294:	c921                	beqz	a0,800052e4 <create+0x94>
    iunlockput(dp);
    80005296:	854a                	mv	a0,s2
    80005298:	fffff097          	auipc	ra,0xfffff
    8000529c:	8b4080e7          	jalr	-1868(ra) # 80003b4c <iunlockput>
    ilock(ip);
    800052a0:	8526                	mv	a0,s1
    800052a2:	ffffe097          	auipc	ra,0xffffe
    800052a6:	648080e7          	jalr	1608(ra) # 800038ea <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052aa:	2981                	sext.w	s3,s3
    800052ac:	4789                	li	a5,2
    800052ae:	02f99463          	bne	s3,a5,800052d6 <create+0x86>
    800052b2:	0444d783          	lhu	a5,68(s1)
    800052b6:	37f9                	addiw	a5,a5,-2
    800052b8:	17c2                	slli	a5,a5,0x30
    800052ba:	93c1                	srli	a5,a5,0x30
    800052bc:	4705                	li	a4,1
    800052be:	00f76c63          	bltu	a4,a5,800052d6 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052c2:	8526                	mv	a0,s1
    800052c4:	60a6                	ld	ra,72(sp)
    800052c6:	6406                	ld	s0,64(sp)
    800052c8:	74e2                	ld	s1,56(sp)
    800052ca:	7942                	ld	s2,48(sp)
    800052cc:	79a2                	ld	s3,40(sp)
    800052ce:	7a02                	ld	s4,32(sp)
    800052d0:	6ae2                	ld	s5,24(sp)
    800052d2:	6161                	addi	sp,sp,80
    800052d4:	8082                	ret
    iunlockput(ip);
    800052d6:	8526                	mv	a0,s1
    800052d8:	fffff097          	auipc	ra,0xfffff
    800052dc:	874080e7          	jalr	-1932(ra) # 80003b4c <iunlockput>
    return 0;
    800052e0:	4481                	li	s1,0
    800052e2:	b7c5                	j	800052c2 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052e4:	85ce                	mv	a1,s3
    800052e6:	00092503          	lw	a0,0(s2)
    800052ea:	ffffe097          	auipc	ra,0xffffe
    800052ee:	468080e7          	jalr	1128(ra) # 80003752 <ialloc>
    800052f2:	84aa                	mv	s1,a0
    800052f4:	c521                	beqz	a0,8000533c <create+0xec>
  ilock(ip);
    800052f6:	ffffe097          	auipc	ra,0xffffe
    800052fa:	5f4080e7          	jalr	1524(ra) # 800038ea <ilock>
  ip->major = major;
    800052fe:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005302:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005306:	4a05                	li	s4,1
    80005308:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000530c:	8526                	mv	a0,s1
    8000530e:	ffffe097          	auipc	ra,0xffffe
    80005312:	512080e7          	jalr	1298(ra) # 80003820 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005316:	2981                	sext.w	s3,s3
    80005318:	03498a63          	beq	s3,s4,8000534c <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000531c:	40d0                	lw	a2,4(s1)
    8000531e:	fb040593          	addi	a1,s0,-80
    80005322:	854a                	mv	a0,s2
    80005324:	fffff097          	auipc	ra,0xfffff
    80005328:	cb4080e7          	jalr	-844(ra) # 80003fd8 <dirlink>
    8000532c:	06054b63          	bltz	a0,800053a2 <create+0x152>
  iunlockput(dp);
    80005330:	854a                	mv	a0,s2
    80005332:	fffff097          	auipc	ra,0xfffff
    80005336:	81a080e7          	jalr	-2022(ra) # 80003b4c <iunlockput>
  return ip;
    8000533a:	b761                	j	800052c2 <create+0x72>
    panic("create: ialloc");
    8000533c:	00003517          	auipc	a0,0x3
    80005340:	35c50513          	addi	a0,a0,860 # 80008698 <syscalls+0x2c0>
    80005344:	ffffb097          	auipc	ra,0xffffb
    80005348:	1fe080e7          	jalr	510(ra) # 80000542 <panic>
    dp->nlink++;  // for ".."
    8000534c:	04a95783          	lhu	a5,74(s2)
    80005350:	2785                	addiw	a5,a5,1
    80005352:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005356:	854a                	mv	a0,s2
    80005358:	ffffe097          	auipc	ra,0xffffe
    8000535c:	4c8080e7          	jalr	1224(ra) # 80003820 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005360:	40d0                	lw	a2,4(s1)
    80005362:	00003597          	auipc	a1,0x3
    80005366:	34658593          	addi	a1,a1,838 # 800086a8 <syscalls+0x2d0>
    8000536a:	8526                	mv	a0,s1
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	c6c080e7          	jalr	-916(ra) # 80003fd8 <dirlink>
    80005374:	00054f63          	bltz	a0,80005392 <create+0x142>
    80005378:	00492603          	lw	a2,4(s2)
    8000537c:	00003597          	auipc	a1,0x3
    80005380:	33458593          	addi	a1,a1,820 # 800086b0 <syscalls+0x2d8>
    80005384:	8526                	mv	a0,s1
    80005386:	fffff097          	auipc	ra,0xfffff
    8000538a:	c52080e7          	jalr	-942(ra) # 80003fd8 <dirlink>
    8000538e:	f80557e3          	bgez	a0,8000531c <create+0xcc>
      panic("create dots");
    80005392:	00003517          	auipc	a0,0x3
    80005396:	32650513          	addi	a0,a0,806 # 800086b8 <syscalls+0x2e0>
    8000539a:	ffffb097          	auipc	ra,0xffffb
    8000539e:	1a8080e7          	jalr	424(ra) # 80000542 <panic>
    panic("create: dirlink");
    800053a2:	00003517          	auipc	a0,0x3
    800053a6:	32650513          	addi	a0,a0,806 # 800086c8 <syscalls+0x2f0>
    800053aa:	ffffb097          	auipc	ra,0xffffb
    800053ae:	198080e7          	jalr	408(ra) # 80000542 <panic>
    return 0;
    800053b2:	84aa                	mv	s1,a0
    800053b4:	b739                	j	800052c2 <create+0x72>

00000000800053b6 <sys_dup>:
{
    800053b6:	7179                	addi	sp,sp,-48
    800053b8:	f406                	sd	ra,40(sp)
    800053ba:	f022                	sd	s0,32(sp)
    800053bc:	ec26                	sd	s1,24(sp)
    800053be:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053c0:	fd840613          	addi	a2,s0,-40
    800053c4:	4581                	li	a1,0
    800053c6:	4501                	li	a0,0
    800053c8:	00000097          	auipc	ra,0x0
    800053cc:	dde080e7          	jalr	-546(ra) # 800051a6 <argfd>
    return -1;
    800053d0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053d2:	02054363          	bltz	a0,800053f8 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053d6:	fd843503          	ld	a0,-40(s0)
    800053da:	00000097          	auipc	ra,0x0
    800053de:	e34080e7          	jalr	-460(ra) # 8000520e <fdalloc>
    800053e2:	84aa                	mv	s1,a0
    return -1;
    800053e4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053e6:	00054963          	bltz	a0,800053f8 <sys_dup+0x42>
  filedup(f);
    800053ea:	fd843503          	ld	a0,-40(s0)
    800053ee:	fffff097          	auipc	ra,0xfffff
    800053f2:	338080e7          	jalr	824(ra) # 80004726 <filedup>
  return fd;
    800053f6:	87a6                	mv	a5,s1
}
    800053f8:	853e                	mv	a0,a5
    800053fa:	70a2                	ld	ra,40(sp)
    800053fc:	7402                	ld	s0,32(sp)
    800053fe:	64e2                	ld	s1,24(sp)
    80005400:	6145                	addi	sp,sp,48
    80005402:	8082                	ret

0000000080005404 <sys_read>:
{
    80005404:	7179                	addi	sp,sp,-48
    80005406:	f406                	sd	ra,40(sp)
    80005408:	f022                	sd	s0,32(sp)
    8000540a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000540c:	fe840613          	addi	a2,s0,-24
    80005410:	4581                	li	a1,0
    80005412:	4501                	li	a0,0
    80005414:	00000097          	auipc	ra,0x0
    80005418:	d92080e7          	jalr	-622(ra) # 800051a6 <argfd>
    return -1;
    8000541c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000541e:	04054163          	bltz	a0,80005460 <sys_read+0x5c>
    80005422:	fe440593          	addi	a1,s0,-28
    80005426:	4509                	li	a0,2
    80005428:	ffffe097          	auipc	ra,0xffffe
    8000542c:	8aa080e7          	jalr	-1878(ra) # 80002cd2 <argint>
    return -1;
    80005430:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005432:	02054763          	bltz	a0,80005460 <sys_read+0x5c>
    80005436:	fd840593          	addi	a1,s0,-40
    8000543a:	4505                	li	a0,1
    8000543c:	ffffe097          	auipc	ra,0xffffe
    80005440:	8b8080e7          	jalr	-1864(ra) # 80002cf4 <argaddr>
    return -1;
    80005444:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005446:	00054d63          	bltz	a0,80005460 <sys_read+0x5c>
  return fileread(f, p, n);
    8000544a:	fe442603          	lw	a2,-28(s0)
    8000544e:	fd843583          	ld	a1,-40(s0)
    80005452:	fe843503          	ld	a0,-24(s0)
    80005456:	fffff097          	auipc	ra,0xfffff
    8000545a:	45c080e7          	jalr	1116(ra) # 800048b2 <fileread>
    8000545e:	87aa                	mv	a5,a0
}
    80005460:	853e                	mv	a0,a5
    80005462:	70a2                	ld	ra,40(sp)
    80005464:	7402                	ld	s0,32(sp)
    80005466:	6145                	addi	sp,sp,48
    80005468:	8082                	ret

000000008000546a <sys_write>:
{
    8000546a:	7179                	addi	sp,sp,-48
    8000546c:	f406                	sd	ra,40(sp)
    8000546e:	f022                	sd	s0,32(sp)
    80005470:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005472:	fe840613          	addi	a2,s0,-24
    80005476:	4581                	li	a1,0
    80005478:	4501                	li	a0,0
    8000547a:	00000097          	auipc	ra,0x0
    8000547e:	d2c080e7          	jalr	-724(ra) # 800051a6 <argfd>
    return -1;
    80005482:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005484:	04054163          	bltz	a0,800054c6 <sys_write+0x5c>
    80005488:	fe440593          	addi	a1,s0,-28
    8000548c:	4509                	li	a0,2
    8000548e:	ffffe097          	auipc	ra,0xffffe
    80005492:	844080e7          	jalr	-1980(ra) # 80002cd2 <argint>
    return -1;
    80005496:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005498:	02054763          	bltz	a0,800054c6 <sys_write+0x5c>
    8000549c:	fd840593          	addi	a1,s0,-40
    800054a0:	4505                	li	a0,1
    800054a2:	ffffe097          	auipc	ra,0xffffe
    800054a6:	852080e7          	jalr	-1966(ra) # 80002cf4 <argaddr>
    return -1;
    800054aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ac:	00054d63          	bltz	a0,800054c6 <sys_write+0x5c>
  return filewrite(f, p, n);
    800054b0:	fe442603          	lw	a2,-28(s0)
    800054b4:	fd843583          	ld	a1,-40(s0)
    800054b8:	fe843503          	ld	a0,-24(s0)
    800054bc:	fffff097          	auipc	ra,0xfffff
    800054c0:	4b8080e7          	jalr	1208(ra) # 80004974 <filewrite>
    800054c4:	87aa                	mv	a5,a0
}
    800054c6:	853e                	mv	a0,a5
    800054c8:	70a2                	ld	ra,40(sp)
    800054ca:	7402                	ld	s0,32(sp)
    800054cc:	6145                	addi	sp,sp,48
    800054ce:	8082                	ret

00000000800054d0 <sys_close>:
{
    800054d0:	1101                	addi	sp,sp,-32
    800054d2:	ec06                	sd	ra,24(sp)
    800054d4:	e822                	sd	s0,16(sp)
    800054d6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054d8:	fe040613          	addi	a2,s0,-32
    800054dc:	fec40593          	addi	a1,s0,-20
    800054e0:	4501                	li	a0,0
    800054e2:	00000097          	auipc	ra,0x0
    800054e6:	cc4080e7          	jalr	-828(ra) # 800051a6 <argfd>
    return -1;
    800054ea:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054ec:	02054463          	bltz	a0,80005514 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054f0:	ffffc097          	auipc	ra,0xffffc
    800054f4:	572080e7          	jalr	1394(ra) # 80001a62 <myproc>
    800054f8:	fec42783          	lw	a5,-20(s0)
    800054fc:	07e9                	addi	a5,a5,26
    800054fe:	078e                	slli	a5,a5,0x3
    80005500:	97aa                	add	a5,a5,a0
    80005502:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005506:	fe043503          	ld	a0,-32(s0)
    8000550a:	fffff097          	auipc	ra,0xfffff
    8000550e:	26e080e7          	jalr	622(ra) # 80004778 <fileclose>
  return 0;
    80005512:	4781                	li	a5,0
}
    80005514:	853e                	mv	a0,a5
    80005516:	60e2                	ld	ra,24(sp)
    80005518:	6442                	ld	s0,16(sp)
    8000551a:	6105                	addi	sp,sp,32
    8000551c:	8082                	ret

000000008000551e <sys_fstat>:
{
    8000551e:	1101                	addi	sp,sp,-32
    80005520:	ec06                	sd	ra,24(sp)
    80005522:	e822                	sd	s0,16(sp)
    80005524:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005526:	fe840613          	addi	a2,s0,-24
    8000552a:	4581                	li	a1,0
    8000552c:	4501                	li	a0,0
    8000552e:	00000097          	auipc	ra,0x0
    80005532:	c78080e7          	jalr	-904(ra) # 800051a6 <argfd>
    return -1;
    80005536:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005538:	02054563          	bltz	a0,80005562 <sys_fstat+0x44>
    8000553c:	fe040593          	addi	a1,s0,-32
    80005540:	4505                	li	a0,1
    80005542:	ffffd097          	auipc	ra,0xffffd
    80005546:	7b2080e7          	jalr	1970(ra) # 80002cf4 <argaddr>
    return -1;
    8000554a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000554c:	00054b63          	bltz	a0,80005562 <sys_fstat+0x44>
  return filestat(f, st);
    80005550:	fe043583          	ld	a1,-32(s0)
    80005554:	fe843503          	ld	a0,-24(s0)
    80005558:	fffff097          	auipc	ra,0xfffff
    8000555c:	2e8080e7          	jalr	744(ra) # 80004840 <filestat>
    80005560:	87aa                	mv	a5,a0
}
    80005562:	853e                	mv	a0,a5
    80005564:	60e2                	ld	ra,24(sp)
    80005566:	6442                	ld	s0,16(sp)
    80005568:	6105                	addi	sp,sp,32
    8000556a:	8082                	ret

000000008000556c <sys_link>:
{
    8000556c:	7169                	addi	sp,sp,-304
    8000556e:	f606                	sd	ra,296(sp)
    80005570:	f222                	sd	s0,288(sp)
    80005572:	ee26                	sd	s1,280(sp)
    80005574:	ea4a                	sd	s2,272(sp)
    80005576:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005578:	08000613          	li	a2,128
    8000557c:	ed040593          	addi	a1,s0,-304
    80005580:	4501                	li	a0,0
    80005582:	ffffd097          	auipc	ra,0xffffd
    80005586:	794080e7          	jalr	1940(ra) # 80002d16 <argstr>
    return -1;
    8000558a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000558c:	10054e63          	bltz	a0,800056a8 <sys_link+0x13c>
    80005590:	08000613          	li	a2,128
    80005594:	f5040593          	addi	a1,s0,-176
    80005598:	4505                	li	a0,1
    8000559a:	ffffd097          	auipc	ra,0xffffd
    8000559e:	77c080e7          	jalr	1916(ra) # 80002d16 <argstr>
    return -1;
    800055a2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055a4:	10054263          	bltz	a0,800056a8 <sys_link+0x13c>
  begin_op();
    800055a8:	fffff097          	auipc	ra,0xfffff
    800055ac:	cfe080e7          	jalr	-770(ra) # 800042a6 <begin_op>
  if((ip = namei(old)) == 0){
    800055b0:	ed040513          	addi	a0,s0,-304
    800055b4:	fffff097          	auipc	ra,0xfffff
    800055b8:	ae6080e7          	jalr	-1306(ra) # 8000409a <namei>
    800055bc:	84aa                	mv	s1,a0
    800055be:	c551                	beqz	a0,8000564a <sys_link+0xde>
  ilock(ip);
    800055c0:	ffffe097          	auipc	ra,0xffffe
    800055c4:	32a080e7          	jalr	810(ra) # 800038ea <ilock>
  if(ip->type == T_DIR){
    800055c8:	04449703          	lh	a4,68(s1)
    800055cc:	4785                	li	a5,1
    800055ce:	08f70463          	beq	a4,a5,80005656 <sys_link+0xea>
  ip->nlink++;
    800055d2:	04a4d783          	lhu	a5,74(s1)
    800055d6:	2785                	addiw	a5,a5,1
    800055d8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055dc:	8526                	mv	a0,s1
    800055de:	ffffe097          	auipc	ra,0xffffe
    800055e2:	242080e7          	jalr	578(ra) # 80003820 <iupdate>
  iunlock(ip);
    800055e6:	8526                	mv	a0,s1
    800055e8:	ffffe097          	auipc	ra,0xffffe
    800055ec:	3c4080e7          	jalr	964(ra) # 800039ac <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055f0:	fd040593          	addi	a1,s0,-48
    800055f4:	f5040513          	addi	a0,s0,-176
    800055f8:	fffff097          	auipc	ra,0xfffff
    800055fc:	ac0080e7          	jalr	-1344(ra) # 800040b8 <nameiparent>
    80005600:	892a                	mv	s2,a0
    80005602:	c935                	beqz	a0,80005676 <sys_link+0x10a>
  ilock(dp);
    80005604:	ffffe097          	auipc	ra,0xffffe
    80005608:	2e6080e7          	jalr	742(ra) # 800038ea <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000560c:	00092703          	lw	a4,0(s2)
    80005610:	409c                	lw	a5,0(s1)
    80005612:	04f71d63          	bne	a4,a5,8000566c <sys_link+0x100>
    80005616:	40d0                	lw	a2,4(s1)
    80005618:	fd040593          	addi	a1,s0,-48
    8000561c:	854a                	mv	a0,s2
    8000561e:	fffff097          	auipc	ra,0xfffff
    80005622:	9ba080e7          	jalr	-1606(ra) # 80003fd8 <dirlink>
    80005626:	04054363          	bltz	a0,8000566c <sys_link+0x100>
  iunlockput(dp);
    8000562a:	854a                	mv	a0,s2
    8000562c:	ffffe097          	auipc	ra,0xffffe
    80005630:	520080e7          	jalr	1312(ra) # 80003b4c <iunlockput>
  iput(ip);
    80005634:	8526                	mv	a0,s1
    80005636:	ffffe097          	auipc	ra,0xffffe
    8000563a:	46e080e7          	jalr	1134(ra) # 80003aa4 <iput>
  end_op();
    8000563e:	fffff097          	auipc	ra,0xfffff
    80005642:	ce8080e7          	jalr	-792(ra) # 80004326 <end_op>
  return 0;
    80005646:	4781                	li	a5,0
    80005648:	a085                	j	800056a8 <sys_link+0x13c>
    end_op();
    8000564a:	fffff097          	auipc	ra,0xfffff
    8000564e:	cdc080e7          	jalr	-804(ra) # 80004326 <end_op>
    return -1;
    80005652:	57fd                	li	a5,-1
    80005654:	a891                	j	800056a8 <sys_link+0x13c>
    iunlockput(ip);
    80005656:	8526                	mv	a0,s1
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	4f4080e7          	jalr	1268(ra) # 80003b4c <iunlockput>
    end_op();
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	cc6080e7          	jalr	-826(ra) # 80004326 <end_op>
    return -1;
    80005668:	57fd                	li	a5,-1
    8000566a:	a83d                	j	800056a8 <sys_link+0x13c>
    iunlockput(dp);
    8000566c:	854a                	mv	a0,s2
    8000566e:	ffffe097          	auipc	ra,0xffffe
    80005672:	4de080e7          	jalr	1246(ra) # 80003b4c <iunlockput>
  ilock(ip);
    80005676:	8526                	mv	a0,s1
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	272080e7          	jalr	626(ra) # 800038ea <ilock>
  ip->nlink--;
    80005680:	04a4d783          	lhu	a5,74(s1)
    80005684:	37fd                	addiw	a5,a5,-1
    80005686:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000568a:	8526                	mv	a0,s1
    8000568c:	ffffe097          	auipc	ra,0xffffe
    80005690:	194080e7          	jalr	404(ra) # 80003820 <iupdate>
  iunlockput(ip);
    80005694:	8526                	mv	a0,s1
    80005696:	ffffe097          	auipc	ra,0xffffe
    8000569a:	4b6080e7          	jalr	1206(ra) # 80003b4c <iunlockput>
  end_op();
    8000569e:	fffff097          	auipc	ra,0xfffff
    800056a2:	c88080e7          	jalr	-888(ra) # 80004326 <end_op>
  return -1;
    800056a6:	57fd                	li	a5,-1
}
    800056a8:	853e                	mv	a0,a5
    800056aa:	70b2                	ld	ra,296(sp)
    800056ac:	7412                	ld	s0,288(sp)
    800056ae:	64f2                	ld	s1,280(sp)
    800056b0:	6952                	ld	s2,272(sp)
    800056b2:	6155                	addi	sp,sp,304
    800056b4:	8082                	ret

00000000800056b6 <sys_unlink>:
{
    800056b6:	7151                	addi	sp,sp,-240
    800056b8:	f586                	sd	ra,232(sp)
    800056ba:	f1a2                	sd	s0,224(sp)
    800056bc:	eda6                	sd	s1,216(sp)
    800056be:	e9ca                	sd	s2,208(sp)
    800056c0:	e5ce                	sd	s3,200(sp)
    800056c2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056c4:	08000613          	li	a2,128
    800056c8:	f3040593          	addi	a1,s0,-208
    800056cc:	4501                	li	a0,0
    800056ce:	ffffd097          	auipc	ra,0xffffd
    800056d2:	648080e7          	jalr	1608(ra) # 80002d16 <argstr>
    800056d6:	18054163          	bltz	a0,80005858 <sys_unlink+0x1a2>
  begin_op();
    800056da:	fffff097          	auipc	ra,0xfffff
    800056de:	bcc080e7          	jalr	-1076(ra) # 800042a6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056e2:	fb040593          	addi	a1,s0,-80
    800056e6:	f3040513          	addi	a0,s0,-208
    800056ea:	fffff097          	auipc	ra,0xfffff
    800056ee:	9ce080e7          	jalr	-1586(ra) # 800040b8 <nameiparent>
    800056f2:	84aa                	mv	s1,a0
    800056f4:	c979                	beqz	a0,800057ca <sys_unlink+0x114>
  ilock(dp);
    800056f6:	ffffe097          	auipc	ra,0xffffe
    800056fa:	1f4080e7          	jalr	500(ra) # 800038ea <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056fe:	00003597          	auipc	a1,0x3
    80005702:	faa58593          	addi	a1,a1,-86 # 800086a8 <syscalls+0x2d0>
    80005706:	fb040513          	addi	a0,s0,-80
    8000570a:	ffffe097          	auipc	ra,0xffffe
    8000570e:	6a4080e7          	jalr	1700(ra) # 80003dae <namecmp>
    80005712:	14050a63          	beqz	a0,80005866 <sys_unlink+0x1b0>
    80005716:	00003597          	auipc	a1,0x3
    8000571a:	f9a58593          	addi	a1,a1,-102 # 800086b0 <syscalls+0x2d8>
    8000571e:	fb040513          	addi	a0,s0,-80
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	68c080e7          	jalr	1676(ra) # 80003dae <namecmp>
    8000572a:	12050e63          	beqz	a0,80005866 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000572e:	f2c40613          	addi	a2,s0,-212
    80005732:	fb040593          	addi	a1,s0,-80
    80005736:	8526                	mv	a0,s1
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	690080e7          	jalr	1680(ra) # 80003dc8 <dirlookup>
    80005740:	892a                	mv	s2,a0
    80005742:	12050263          	beqz	a0,80005866 <sys_unlink+0x1b0>
  ilock(ip);
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	1a4080e7          	jalr	420(ra) # 800038ea <ilock>
  if(ip->nlink < 1)
    8000574e:	04a91783          	lh	a5,74(s2)
    80005752:	08f05263          	blez	a5,800057d6 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005756:	04491703          	lh	a4,68(s2)
    8000575a:	4785                	li	a5,1
    8000575c:	08f70563          	beq	a4,a5,800057e6 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005760:	4641                	li	a2,16
    80005762:	4581                	li	a1,0
    80005764:	fc040513          	addi	a0,s0,-64
    80005768:	ffffb097          	auipc	ra,0xffffb
    8000576c:	5fe080e7          	jalr	1534(ra) # 80000d66 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005770:	4741                	li	a4,16
    80005772:	f2c42683          	lw	a3,-212(s0)
    80005776:	fc040613          	addi	a2,s0,-64
    8000577a:	4581                	li	a1,0
    8000577c:	8526                	mv	a0,s1
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	516080e7          	jalr	1302(ra) # 80003c94 <writei>
    80005786:	47c1                	li	a5,16
    80005788:	0af51563          	bne	a0,a5,80005832 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000578c:	04491703          	lh	a4,68(s2)
    80005790:	4785                	li	a5,1
    80005792:	0af70863          	beq	a4,a5,80005842 <sys_unlink+0x18c>
  iunlockput(dp);
    80005796:	8526                	mv	a0,s1
    80005798:	ffffe097          	auipc	ra,0xffffe
    8000579c:	3b4080e7          	jalr	948(ra) # 80003b4c <iunlockput>
  ip->nlink--;
    800057a0:	04a95783          	lhu	a5,74(s2)
    800057a4:	37fd                	addiw	a5,a5,-1
    800057a6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800057aa:	854a                	mv	a0,s2
    800057ac:	ffffe097          	auipc	ra,0xffffe
    800057b0:	074080e7          	jalr	116(ra) # 80003820 <iupdate>
  iunlockput(ip);
    800057b4:	854a                	mv	a0,s2
    800057b6:	ffffe097          	auipc	ra,0xffffe
    800057ba:	396080e7          	jalr	918(ra) # 80003b4c <iunlockput>
  end_op();
    800057be:	fffff097          	auipc	ra,0xfffff
    800057c2:	b68080e7          	jalr	-1176(ra) # 80004326 <end_op>
  return 0;
    800057c6:	4501                	li	a0,0
    800057c8:	a84d                	j	8000587a <sys_unlink+0x1c4>
    end_op();
    800057ca:	fffff097          	auipc	ra,0xfffff
    800057ce:	b5c080e7          	jalr	-1188(ra) # 80004326 <end_op>
    return -1;
    800057d2:	557d                	li	a0,-1
    800057d4:	a05d                	j	8000587a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800057d6:	00003517          	auipc	a0,0x3
    800057da:	f0250513          	addi	a0,a0,-254 # 800086d8 <syscalls+0x300>
    800057de:	ffffb097          	auipc	ra,0xffffb
    800057e2:	d64080e7          	jalr	-668(ra) # 80000542 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057e6:	04c92703          	lw	a4,76(s2)
    800057ea:	02000793          	li	a5,32
    800057ee:	f6e7f9e3          	bgeu	a5,a4,80005760 <sys_unlink+0xaa>
    800057f2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057f6:	4741                	li	a4,16
    800057f8:	86ce                	mv	a3,s3
    800057fa:	f1840613          	addi	a2,s0,-232
    800057fe:	4581                	li	a1,0
    80005800:	854a                	mv	a0,s2
    80005802:	ffffe097          	auipc	ra,0xffffe
    80005806:	39c080e7          	jalr	924(ra) # 80003b9e <readi>
    8000580a:	47c1                	li	a5,16
    8000580c:	00f51b63          	bne	a0,a5,80005822 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005810:	f1845783          	lhu	a5,-232(s0)
    80005814:	e7a1                	bnez	a5,8000585c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005816:	29c1                	addiw	s3,s3,16
    80005818:	04c92783          	lw	a5,76(s2)
    8000581c:	fcf9ede3          	bltu	s3,a5,800057f6 <sys_unlink+0x140>
    80005820:	b781                	j	80005760 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005822:	00003517          	auipc	a0,0x3
    80005826:	ece50513          	addi	a0,a0,-306 # 800086f0 <syscalls+0x318>
    8000582a:	ffffb097          	auipc	ra,0xffffb
    8000582e:	d18080e7          	jalr	-744(ra) # 80000542 <panic>
    panic("unlink: writei");
    80005832:	00003517          	auipc	a0,0x3
    80005836:	ed650513          	addi	a0,a0,-298 # 80008708 <syscalls+0x330>
    8000583a:	ffffb097          	auipc	ra,0xffffb
    8000583e:	d08080e7          	jalr	-760(ra) # 80000542 <panic>
    dp->nlink--;
    80005842:	04a4d783          	lhu	a5,74(s1)
    80005846:	37fd                	addiw	a5,a5,-1
    80005848:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000584c:	8526                	mv	a0,s1
    8000584e:	ffffe097          	auipc	ra,0xffffe
    80005852:	fd2080e7          	jalr	-46(ra) # 80003820 <iupdate>
    80005856:	b781                	j	80005796 <sys_unlink+0xe0>
    return -1;
    80005858:	557d                	li	a0,-1
    8000585a:	a005                	j	8000587a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000585c:	854a                	mv	a0,s2
    8000585e:	ffffe097          	auipc	ra,0xffffe
    80005862:	2ee080e7          	jalr	750(ra) # 80003b4c <iunlockput>
  iunlockput(dp);
    80005866:	8526                	mv	a0,s1
    80005868:	ffffe097          	auipc	ra,0xffffe
    8000586c:	2e4080e7          	jalr	740(ra) # 80003b4c <iunlockput>
  end_op();
    80005870:	fffff097          	auipc	ra,0xfffff
    80005874:	ab6080e7          	jalr	-1354(ra) # 80004326 <end_op>
  return -1;
    80005878:	557d                	li	a0,-1
}
    8000587a:	70ae                	ld	ra,232(sp)
    8000587c:	740e                	ld	s0,224(sp)
    8000587e:	64ee                	ld	s1,216(sp)
    80005880:	694e                	ld	s2,208(sp)
    80005882:	69ae                	ld	s3,200(sp)
    80005884:	616d                	addi	sp,sp,240
    80005886:	8082                	ret

0000000080005888 <sys_open>:

uint64
sys_open(void)
{
    80005888:	7131                	addi	sp,sp,-192
    8000588a:	fd06                	sd	ra,184(sp)
    8000588c:	f922                	sd	s0,176(sp)
    8000588e:	f526                	sd	s1,168(sp)
    80005890:	f14a                	sd	s2,160(sp)
    80005892:	ed4e                	sd	s3,152(sp)
    80005894:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005896:	08000613          	li	a2,128
    8000589a:	f5040593          	addi	a1,s0,-176
    8000589e:	4501                	li	a0,0
    800058a0:	ffffd097          	auipc	ra,0xffffd
    800058a4:	476080e7          	jalr	1142(ra) # 80002d16 <argstr>
    return -1;
    800058a8:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058aa:	0c054163          	bltz	a0,8000596c <sys_open+0xe4>
    800058ae:	f4c40593          	addi	a1,s0,-180
    800058b2:	4505                	li	a0,1
    800058b4:	ffffd097          	auipc	ra,0xffffd
    800058b8:	41e080e7          	jalr	1054(ra) # 80002cd2 <argint>
    800058bc:	0a054863          	bltz	a0,8000596c <sys_open+0xe4>

  begin_op();
    800058c0:	fffff097          	auipc	ra,0xfffff
    800058c4:	9e6080e7          	jalr	-1562(ra) # 800042a6 <begin_op>

  if(omode & O_CREATE){
    800058c8:	f4c42783          	lw	a5,-180(s0)
    800058cc:	2007f793          	andi	a5,a5,512
    800058d0:	cbdd                	beqz	a5,80005986 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058d2:	4681                	li	a3,0
    800058d4:	4601                	li	a2,0
    800058d6:	4589                	li	a1,2
    800058d8:	f5040513          	addi	a0,s0,-176
    800058dc:	00000097          	auipc	ra,0x0
    800058e0:	974080e7          	jalr	-1676(ra) # 80005250 <create>
    800058e4:	892a                	mv	s2,a0
    if(ip == 0){
    800058e6:	c959                	beqz	a0,8000597c <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058e8:	04491703          	lh	a4,68(s2)
    800058ec:	478d                	li	a5,3
    800058ee:	00f71763          	bne	a4,a5,800058fc <sys_open+0x74>
    800058f2:	04695703          	lhu	a4,70(s2)
    800058f6:	47a5                	li	a5,9
    800058f8:	0ce7ec63          	bltu	a5,a4,800059d0 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058fc:	fffff097          	auipc	ra,0xfffff
    80005900:	dc0080e7          	jalr	-576(ra) # 800046bc <filealloc>
    80005904:	89aa                	mv	s3,a0
    80005906:	10050263          	beqz	a0,80005a0a <sys_open+0x182>
    8000590a:	00000097          	auipc	ra,0x0
    8000590e:	904080e7          	jalr	-1788(ra) # 8000520e <fdalloc>
    80005912:	84aa                	mv	s1,a0
    80005914:	0e054663          	bltz	a0,80005a00 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005918:	04491703          	lh	a4,68(s2)
    8000591c:	478d                	li	a5,3
    8000591e:	0cf70463          	beq	a4,a5,800059e6 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005922:	4789                	li	a5,2
    80005924:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005928:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000592c:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005930:	f4c42783          	lw	a5,-180(s0)
    80005934:	0017c713          	xori	a4,a5,1
    80005938:	8b05                	andi	a4,a4,1
    8000593a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000593e:	0037f713          	andi	a4,a5,3
    80005942:	00e03733          	snez	a4,a4
    80005946:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000594a:	4007f793          	andi	a5,a5,1024
    8000594e:	c791                	beqz	a5,8000595a <sys_open+0xd2>
    80005950:	04491703          	lh	a4,68(s2)
    80005954:	4789                	li	a5,2
    80005956:	08f70f63          	beq	a4,a5,800059f4 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000595a:	854a                	mv	a0,s2
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	050080e7          	jalr	80(ra) # 800039ac <iunlock>
  end_op();
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	9c2080e7          	jalr	-1598(ra) # 80004326 <end_op>

  return fd;
}
    8000596c:	8526                	mv	a0,s1
    8000596e:	70ea                	ld	ra,184(sp)
    80005970:	744a                	ld	s0,176(sp)
    80005972:	74aa                	ld	s1,168(sp)
    80005974:	790a                	ld	s2,160(sp)
    80005976:	69ea                	ld	s3,152(sp)
    80005978:	6129                	addi	sp,sp,192
    8000597a:	8082                	ret
      end_op();
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	9aa080e7          	jalr	-1622(ra) # 80004326 <end_op>
      return -1;
    80005984:	b7e5                	j	8000596c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005986:	f5040513          	addi	a0,s0,-176
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	710080e7          	jalr	1808(ra) # 8000409a <namei>
    80005992:	892a                	mv	s2,a0
    80005994:	c905                	beqz	a0,800059c4 <sys_open+0x13c>
    ilock(ip);
    80005996:	ffffe097          	auipc	ra,0xffffe
    8000599a:	f54080e7          	jalr	-172(ra) # 800038ea <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000599e:	04491703          	lh	a4,68(s2)
    800059a2:	4785                	li	a5,1
    800059a4:	f4f712e3          	bne	a4,a5,800058e8 <sys_open+0x60>
    800059a8:	f4c42783          	lw	a5,-180(s0)
    800059ac:	dba1                	beqz	a5,800058fc <sys_open+0x74>
      iunlockput(ip);
    800059ae:	854a                	mv	a0,s2
    800059b0:	ffffe097          	auipc	ra,0xffffe
    800059b4:	19c080e7          	jalr	412(ra) # 80003b4c <iunlockput>
      end_op();
    800059b8:	fffff097          	auipc	ra,0xfffff
    800059bc:	96e080e7          	jalr	-1682(ra) # 80004326 <end_op>
      return -1;
    800059c0:	54fd                	li	s1,-1
    800059c2:	b76d                	j	8000596c <sys_open+0xe4>
      end_op();
    800059c4:	fffff097          	auipc	ra,0xfffff
    800059c8:	962080e7          	jalr	-1694(ra) # 80004326 <end_op>
      return -1;
    800059cc:	54fd                	li	s1,-1
    800059ce:	bf79                	j	8000596c <sys_open+0xe4>
    iunlockput(ip);
    800059d0:	854a                	mv	a0,s2
    800059d2:	ffffe097          	auipc	ra,0xffffe
    800059d6:	17a080e7          	jalr	378(ra) # 80003b4c <iunlockput>
    end_op();
    800059da:	fffff097          	auipc	ra,0xfffff
    800059de:	94c080e7          	jalr	-1716(ra) # 80004326 <end_op>
    return -1;
    800059e2:	54fd                	li	s1,-1
    800059e4:	b761                	j	8000596c <sys_open+0xe4>
    f->type = FD_DEVICE;
    800059e6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059ea:	04691783          	lh	a5,70(s2)
    800059ee:	02f99223          	sh	a5,36(s3)
    800059f2:	bf2d                	j	8000592c <sys_open+0xa4>
    itrunc(ip);
    800059f4:	854a                	mv	a0,s2
    800059f6:	ffffe097          	auipc	ra,0xffffe
    800059fa:	002080e7          	jalr	2(ra) # 800039f8 <itrunc>
    800059fe:	bfb1                	j	8000595a <sys_open+0xd2>
      fileclose(f);
    80005a00:	854e                	mv	a0,s3
    80005a02:	fffff097          	auipc	ra,0xfffff
    80005a06:	d76080e7          	jalr	-650(ra) # 80004778 <fileclose>
    iunlockput(ip);
    80005a0a:	854a                	mv	a0,s2
    80005a0c:	ffffe097          	auipc	ra,0xffffe
    80005a10:	140080e7          	jalr	320(ra) # 80003b4c <iunlockput>
    end_op();
    80005a14:	fffff097          	auipc	ra,0xfffff
    80005a18:	912080e7          	jalr	-1774(ra) # 80004326 <end_op>
    return -1;
    80005a1c:	54fd                	li	s1,-1
    80005a1e:	b7b9                	j	8000596c <sys_open+0xe4>

0000000080005a20 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a20:	7175                	addi	sp,sp,-144
    80005a22:	e506                	sd	ra,136(sp)
    80005a24:	e122                	sd	s0,128(sp)
    80005a26:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a28:	fffff097          	auipc	ra,0xfffff
    80005a2c:	87e080e7          	jalr	-1922(ra) # 800042a6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a30:	08000613          	li	a2,128
    80005a34:	f7040593          	addi	a1,s0,-144
    80005a38:	4501                	li	a0,0
    80005a3a:	ffffd097          	auipc	ra,0xffffd
    80005a3e:	2dc080e7          	jalr	732(ra) # 80002d16 <argstr>
    80005a42:	02054963          	bltz	a0,80005a74 <sys_mkdir+0x54>
    80005a46:	4681                	li	a3,0
    80005a48:	4601                	li	a2,0
    80005a4a:	4585                	li	a1,1
    80005a4c:	f7040513          	addi	a0,s0,-144
    80005a50:	00000097          	auipc	ra,0x0
    80005a54:	800080e7          	jalr	-2048(ra) # 80005250 <create>
    80005a58:	cd11                	beqz	a0,80005a74 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	0f2080e7          	jalr	242(ra) # 80003b4c <iunlockput>
  end_op();
    80005a62:	fffff097          	auipc	ra,0xfffff
    80005a66:	8c4080e7          	jalr	-1852(ra) # 80004326 <end_op>
  return 0;
    80005a6a:	4501                	li	a0,0
}
    80005a6c:	60aa                	ld	ra,136(sp)
    80005a6e:	640a                	ld	s0,128(sp)
    80005a70:	6149                	addi	sp,sp,144
    80005a72:	8082                	ret
    end_op();
    80005a74:	fffff097          	auipc	ra,0xfffff
    80005a78:	8b2080e7          	jalr	-1870(ra) # 80004326 <end_op>
    return -1;
    80005a7c:	557d                	li	a0,-1
    80005a7e:	b7fd                	j	80005a6c <sys_mkdir+0x4c>

0000000080005a80 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a80:	7135                	addi	sp,sp,-160
    80005a82:	ed06                	sd	ra,152(sp)
    80005a84:	e922                	sd	s0,144(sp)
    80005a86:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a88:	fffff097          	auipc	ra,0xfffff
    80005a8c:	81e080e7          	jalr	-2018(ra) # 800042a6 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a90:	08000613          	li	a2,128
    80005a94:	f7040593          	addi	a1,s0,-144
    80005a98:	4501                	li	a0,0
    80005a9a:	ffffd097          	auipc	ra,0xffffd
    80005a9e:	27c080e7          	jalr	636(ra) # 80002d16 <argstr>
    80005aa2:	04054a63          	bltz	a0,80005af6 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005aa6:	f6c40593          	addi	a1,s0,-148
    80005aaa:	4505                	li	a0,1
    80005aac:	ffffd097          	auipc	ra,0xffffd
    80005ab0:	226080e7          	jalr	550(ra) # 80002cd2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ab4:	04054163          	bltz	a0,80005af6 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005ab8:	f6840593          	addi	a1,s0,-152
    80005abc:	4509                	li	a0,2
    80005abe:	ffffd097          	auipc	ra,0xffffd
    80005ac2:	214080e7          	jalr	532(ra) # 80002cd2 <argint>
     argint(1, &major) < 0 ||
    80005ac6:	02054863          	bltz	a0,80005af6 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005aca:	f6841683          	lh	a3,-152(s0)
    80005ace:	f6c41603          	lh	a2,-148(s0)
    80005ad2:	458d                	li	a1,3
    80005ad4:	f7040513          	addi	a0,s0,-144
    80005ad8:	fffff097          	auipc	ra,0xfffff
    80005adc:	778080e7          	jalr	1912(ra) # 80005250 <create>
     argint(2, &minor) < 0 ||
    80005ae0:	c919                	beqz	a0,80005af6 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ae2:	ffffe097          	auipc	ra,0xffffe
    80005ae6:	06a080e7          	jalr	106(ra) # 80003b4c <iunlockput>
  end_op();
    80005aea:	fffff097          	auipc	ra,0xfffff
    80005aee:	83c080e7          	jalr	-1988(ra) # 80004326 <end_op>
  return 0;
    80005af2:	4501                	li	a0,0
    80005af4:	a031                	j	80005b00 <sys_mknod+0x80>
    end_op();
    80005af6:	fffff097          	auipc	ra,0xfffff
    80005afa:	830080e7          	jalr	-2000(ra) # 80004326 <end_op>
    return -1;
    80005afe:	557d                	li	a0,-1
}
    80005b00:	60ea                	ld	ra,152(sp)
    80005b02:	644a                	ld	s0,144(sp)
    80005b04:	610d                	addi	sp,sp,160
    80005b06:	8082                	ret

0000000080005b08 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b08:	7135                	addi	sp,sp,-160
    80005b0a:	ed06                	sd	ra,152(sp)
    80005b0c:	e922                	sd	s0,144(sp)
    80005b0e:	e526                	sd	s1,136(sp)
    80005b10:	e14a                	sd	s2,128(sp)
    80005b12:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b14:	ffffc097          	auipc	ra,0xffffc
    80005b18:	f4e080e7          	jalr	-178(ra) # 80001a62 <myproc>
    80005b1c:	892a                	mv	s2,a0
  
  begin_op();
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	788080e7          	jalr	1928(ra) # 800042a6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b26:	08000613          	li	a2,128
    80005b2a:	f6040593          	addi	a1,s0,-160
    80005b2e:	4501                	li	a0,0
    80005b30:	ffffd097          	auipc	ra,0xffffd
    80005b34:	1e6080e7          	jalr	486(ra) # 80002d16 <argstr>
    80005b38:	04054b63          	bltz	a0,80005b8e <sys_chdir+0x86>
    80005b3c:	f6040513          	addi	a0,s0,-160
    80005b40:	ffffe097          	auipc	ra,0xffffe
    80005b44:	55a080e7          	jalr	1370(ra) # 8000409a <namei>
    80005b48:	84aa                	mv	s1,a0
    80005b4a:	c131                	beqz	a0,80005b8e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b4c:	ffffe097          	auipc	ra,0xffffe
    80005b50:	d9e080e7          	jalr	-610(ra) # 800038ea <ilock>
  if(ip->type != T_DIR){
    80005b54:	04449703          	lh	a4,68(s1)
    80005b58:	4785                	li	a5,1
    80005b5a:	04f71063          	bne	a4,a5,80005b9a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b5e:	8526                	mv	a0,s1
    80005b60:	ffffe097          	auipc	ra,0xffffe
    80005b64:	e4c080e7          	jalr	-436(ra) # 800039ac <iunlock>
  iput(p->cwd);
    80005b68:	15093503          	ld	a0,336(s2)
    80005b6c:	ffffe097          	auipc	ra,0xffffe
    80005b70:	f38080e7          	jalr	-200(ra) # 80003aa4 <iput>
  end_op();
    80005b74:	ffffe097          	auipc	ra,0xffffe
    80005b78:	7b2080e7          	jalr	1970(ra) # 80004326 <end_op>
  p->cwd = ip;
    80005b7c:	14993823          	sd	s1,336(s2)
  return 0;
    80005b80:	4501                	li	a0,0
}
    80005b82:	60ea                	ld	ra,152(sp)
    80005b84:	644a                	ld	s0,144(sp)
    80005b86:	64aa                	ld	s1,136(sp)
    80005b88:	690a                	ld	s2,128(sp)
    80005b8a:	610d                	addi	sp,sp,160
    80005b8c:	8082                	ret
    end_op();
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	798080e7          	jalr	1944(ra) # 80004326 <end_op>
    return -1;
    80005b96:	557d                	li	a0,-1
    80005b98:	b7ed                	j	80005b82 <sys_chdir+0x7a>
    iunlockput(ip);
    80005b9a:	8526                	mv	a0,s1
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	fb0080e7          	jalr	-80(ra) # 80003b4c <iunlockput>
    end_op();
    80005ba4:	ffffe097          	auipc	ra,0xffffe
    80005ba8:	782080e7          	jalr	1922(ra) # 80004326 <end_op>
    return -1;
    80005bac:	557d                	li	a0,-1
    80005bae:	bfd1                	j	80005b82 <sys_chdir+0x7a>

0000000080005bb0 <sys_exec>:

uint64
sys_exec(void)
{
    80005bb0:	7145                	addi	sp,sp,-464
    80005bb2:	e786                	sd	ra,456(sp)
    80005bb4:	e3a2                	sd	s0,448(sp)
    80005bb6:	ff26                	sd	s1,440(sp)
    80005bb8:	fb4a                	sd	s2,432(sp)
    80005bba:	f74e                	sd	s3,424(sp)
    80005bbc:	f352                	sd	s4,416(sp)
    80005bbe:	ef56                	sd	s5,408(sp)
    80005bc0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bc2:	08000613          	li	a2,128
    80005bc6:	f4040593          	addi	a1,s0,-192
    80005bca:	4501                	li	a0,0
    80005bcc:	ffffd097          	auipc	ra,0xffffd
    80005bd0:	14a080e7          	jalr	330(ra) # 80002d16 <argstr>
    return -1;
    80005bd4:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bd6:	0c054a63          	bltz	a0,80005caa <sys_exec+0xfa>
    80005bda:	e3840593          	addi	a1,s0,-456
    80005bde:	4505                	li	a0,1
    80005be0:	ffffd097          	auipc	ra,0xffffd
    80005be4:	114080e7          	jalr	276(ra) # 80002cf4 <argaddr>
    80005be8:	0c054163          	bltz	a0,80005caa <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005bec:	10000613          	li	a2,256
    80005bf0:	4581                	li	a1,0
    80005bf2:	e4040513          	addi	a0,s0,-448
    80005bf6:	ffffb097          	auipc	ra,0xffffb
    80005bfa:	170080e7          	jalr	368(ra) # 80000d66 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005bfe:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c02:	89a6                	mv	s3,s1
    80005c04:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c06:	02000a13          	li	s4,32
    80005c0a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c0e:	00391793          	slli	a5,s2,0x3
    80005c12:	e3040593          	addi	a1,s0,-464
    80005c16:	e3843503          	ld	a0,-456(s0)
    80005c1a:	953e                	add	a0,a0,a5
    80005c1c:	ffffd097          	auipc	ra,0xffffd
    80005c20:	01c080e7          	jalr	28(ra) # 80002c38 <fetchaddr>
    80005c24:	02054a63          	bltz	a0,80005c58 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005c28:	e3043783          	ld	a5,-464(s0)
    80005c2c:	c3b9                	beqz	a5,80005c72 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c2e:	ffffb097          	auipc	ra,0xffffb
    80005c32:	f4c080e7          	jalr	-180(ra) # 80000b7a <kalloc>
    80005c36:	85aa                	mv	a1,a0
    80005c38:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c3c:	cd11                	beqz	a0,80005c58 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c3e:	6605                	lui	a2,0x1
    80005c40:	e3043503          	ld	a0,-464(s0)
    80005c44:	ffffd097          	auipc	ra,0xffffd
    80005c48:	046080e7          	jalr	70(ra) # 80002c8a <fetchstr>
    80005c4c:	00054663          	bltz	a0,80005c58 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005c50:	0905                	addi	s2,s2,1
    80005c52:	09a1                	addi	s3,s3,8
    80005c54:	fb491be3          	bne	s2,s4,80005c0a <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c58:	10048913          	addi	s2,s1,256
    80005c5c:	6088                	ld	a0,0(s1)
    80005c5e:	c529                	beqz	a0,80005ca8 <sys_exec+0xf8>
    kfree(argv[i]);
    80005c60:	ffffb097          	auipc	ra,0xffffb
    80005c64:	e1e080e7          	jalr	-482(ra) # 80000a7e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c68:	04a1                	addi	s1,s1,8
    80005c6a:	ff2499e3          	bne	s1,s2,80005c5c <sys_exec+0xac>
  return -1;
    80005c6e:	597d                	li	s2,-1
    80005c70:	a82d                	j	80005caa <sys_exec+0xfa>
      argv[i] = 0;
    80005c72:	0a8e                	slli	s5,s5,0x3
    80005c74:	fc040793          	addi	a5,s0,-64
    80005c78:	9abe                	add	s5,s5,a5
    80005c7a:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd7e80>
  int ret = exec(path, argv);
    80005c7e:	e4040593          	addi	a1,s0,-448
    80005c82:	f4040513          	addi	a0,s0,-192
    80005c86:	fffff097          	auipc	ra,0xfffff
    80005c8a:	178080e7          	jalr	376(ra) # 80004dfe <exec>
    80005c8e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c90:	10048993          	addi	s3,s1,256
    80005c94:	6088                	ld	a0,0(s1)
    80005c96:	c911                	beqz	a0,80005caa <sys_exec+0xfa>
    kfree(argv[i]);
    80005c98:	ffffb097          	auipc	ra,0xffffb
    80005c9c:	de6080e7          	jalr	-538(ra) # 80000a7e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ca0:	04a1                	addi	s1,s1,8
    80005ca2:	ff3499e3          	bne	s1,s3,80005c94 <sys_exec+0xe4>
    80005ca6:	a011                	j	80005caa <sys_exec+0xfa>
  return -1;
    80005ca8:	597d                	li	s2,-1
}
    80005caa:	854a                	mv	a0,s2
    80005cac:	60be                	ld	ra,456(sp)
    80005cae:	641e                	ld	s0,448(sp)
    80005cb0:	74fa                	ld	s1,440(sp)
    80005cb2:	795a                	ld	s2,432(sp)
    80005cb4:	79ba                	ld	s3,424(sp)
    80005cb6:	7a1a                	ld	s4,416(sp)
    80005cb8:	6afa                	ld	s5,408(sp)
    80005cba:	6179                	addi	sp,sp,464
    80005cbc:	8082                	ret

0000000080005cbe <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cbe:	7139                	addi	sp,sp,-64
    80005cc0:	fc06                	sd	ra,56(sp)
    80005cc2:	f822                	sd	s0,48(sp)
    80005cc4:	f426                	sd	s1,40(sp)
    80005cc6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cc8:	ffffc097          	auipc	ra,0xffffc
    80005ccc:	d9a080e7          	jalr	-614(ra) # 80001a62 <myproc>
    80005cd0:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005cd2:	fd840593          	addi	a1,s0,-40
    80005cd6:	4501                	li	a0,0
    80005cd8:	ffffd097          	auipc	ra,0xffffd
    80005cdc:	01c080e7          	jalr	28(ra) # 80002cf4 <argaddr>
    return -1;
    80005ce0:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005ce2:	0e054063          	bltz	a0,80005dc2 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005ce6:	fc840593          	addi	a1,s0,-56
    80005cea:	fd040513          	addi	a0,s0,-48
    80005cee:	fffff097          	auipc	ra,0xfffff
    80005cf2:	de0080e7          	jalr	-544(ra) # 80004ace <pipealloc>
    return -1;
    80005cf6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005cf8:	0c054563          	bltz	a0,80005dc2 <sys_pipe+0x104>
  fd0 = -1;
    80005cfc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d00:	fd043503          	ld	a0,-48(s0)
    80005d04:	fffff097          	auipc	ra,0xfffff
    80005d08:	50a080e7          	jalr	1290(ra) # 8000520e <fdalloc>
    80005d0c:	fca42223          	sw	a0,-60(s0)
    80005d10:	08054c63          	bltz	a0,80005da8 <sys_pipe+0xea>
    80005d14:	fc843503          	ld	a0,-56(s0)
    80005d18:	fffff097          	auipc	ra,0xfffff
    80005d1c:	4f6080e7          	jalr	1270(ra) # 8000520e <fdalloc>
    80005d20:	fca42023          	sw	a0,-64(s0)
    80005d24:	06054863          	bltz	a0,80005d94 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d28:	4691                	li	a3,4
    80005d2a:	fc440613          	addi	a2,s0,-60
    80005d2e:	fd843583          	ld	a1,-40(s0)
    80005d32:	68a8                	ld	a0,80(s1)
    80005d34:	ffffc097          	auipc	ra,0xffffc
    80005d38:	a20080e7          	jalr	-1504(ra) # 80001754 <copyout>
    80005d3c:	02054063          	bltz	a0,80005d5c <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d40:	4691                	li	a3,4
    80005d42:	fc040613          	addi	a2,s0,-64
    80005d46:	fd843583          	ld	a1,-40(s0)
    80005d4a:	0591                	addi	a1,a1,4
    80005d4c:	68a8                	ld	a0,80(s1)
    80005d4e:	ffffc097          	auipc	ra,0xffffc
    80005d52:	a06080e7          	jalr	-1530(ra) # 80001754 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d56:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d58:	06055563          	bgez	a0,80005dc2 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d5c:	fc442783          	lw	a5,-60(s0)
    80005d60:	07e9                	addi	a5,a5,26
    80005d62:	078e                	slli	a5,a5,0x3
    80005d64:	97a6                	add	a5,a5,s1
    80005d66:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d6a:	fc042503          	lw	a0,-64(s0)
    80005d6e:	0569                	addi	a0,a0,26
    80005d70:	050e                	slli	a0,a0,0x3
    80005d72:	9526                	add	a0,a0,s1
    80005d74:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005d78:	fd043503          	ld	a0,-48(s0)
    80005d7c:	fffff097          	auipc	ra,0xfffff
    80005d80:	9fc080e7          	jalr	-1540(ra) # 80004778 <fileclose>
    fileclose(wf);
    80005d84:	fc843503          	ld	a0,-56(s0)
    80005d88:	fffff097          	auipc	ra,0xfffff
    80005d8c:	9f0080e7          	jalr	-1552(ra) # 80004778 <fileclose>
    return -1;
    80005d90:	57fd                	li	a5,-1
    80005d92:	a805                	j	80005dc2 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005d94:	fc442783          	lw	a5,-60(s0)
    80005d98:	0007c863          	bltz	a5,80005da8 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005d9c:	01a78513          	addi	a0,a5,26
    80005da0:	050e                	slli	a0,a0,0x3
    80005da2:	9526                	add	a0,a0,s1
    80005da4:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005da8:	fd043503          	ld	a0,-48(s0)
    80005dac:	fffff097          	auipc	ra,0xfffff
    80005db0:	9cc080e7          	jalr	-1588(ra) # 80004778 <fileclose>
    fileclose(wf);
    80005db4:	fc843503          	ld	a0,-56(s0)
    80005db8:	fffff097          	auipc	ra,0xfffff
    80005dbc:	9c0080e7          	jalr	-1600(ra) # 80004778 <fileclose>
    return -1;
    80005dc0:	57fd                	li	a5,-1
}
    80005dc2:	853e                	mv	a0,a5
    80005dc4:	70e2                	ld	ra,56(sp)
    80005dc6:	7442                	ld	s0,48(sp)
    80005dc8:	74a2                	ld	s1,40(sp)
    80005dca:	6121                	addi	sp,sp,64
    80005dcc:	8082                	ret
	...

0000000080005dd0 <kernelvec>:
    80005dd0:	7111                	addi	sp,sp,-256
    80005dd2:	e006                	sd	ra,0(sp)
    80005dd4:	e40a                	sd	sp,8(sp)
    80005dd6:	e80e                	sd	gp,16(sp)
    80005dd8:	ec12                	sd	tp,24(sp)
    80005dda:	f016                	sd	t0,32(sp)
    80005ddc:	f41a                	sd	t1,40(sp)
    80005dde:	f81e                	sd	t2,48(sp)
    80005de0:	fc22                	sd	s0,56(sp)
    80005de2:	e0a6                	sd	s1,64(sp)
    80005de4:	e4aa                	sd	a0,72(sp)
    80005de6:	e8ae                	sd	a1,80(sp)
    80005de8:	ecb2                	sd	a2,88(sp)
    80005dea:	f0b6                	sd	a3,96(sp)
    80005dec:	f4ba                	sd	a4,104(sp)
    80005dee:	f8be                	sd	a5,112(sp)
    80005df0:	fcc2                	sd	a6,120(sp)
    80005df2:	e146                	sd	a7,128(sp)
    80005df4:	e54a                	sd	s2,136(sp)
    80005df6:	e94e                	sd	s3,144(sp)
    80005df8:	ed52                	sd	s4,152(sp)
    80005dfa:	f156                	sd	s5,160(sp)
    80005dfc:	f55a                	sd	s6,168(sp)
    80005dfe:	f95e                	sd	s7,176(sp)
    80005e00:	fd62                	sd	s8,184(sp)
    80005e02:	e1e6                	sd	s9,192(sp)
    80005e04:	e5ea                	sd	s10,200(sp)
    80005e06:	e9ee                	sd	s11,208(sp)
    80005e08:	edf2                	sd	t3,216(sp)
    80005e0a:	f1f6                	sd	t4,224(sp)
    80005e0c:	f5fa                	sd	t5,232(sp)
    80005e0e:	f9fe                	sd	t6,240(sp)
    80005e10:	a77fc0ef          	jal	ra,80002886 <kerneltrap>
    80005e14:	6082                	ld	ra,0(sp)
    80005e16:	6122                	ld	sp,8(sp)
    80005e18:	61c2                	ld	gp,16(sp)
    80005e1a:	7282                	ld	t0,32(sp)
    80005e1c:	7322                	ld	t1,40(sp)
    80005e1e:	73c2                	ld	t2,48(sp)
    80005e20:	7462                	ld	s0,56(sp)
    80005e22:	6486                	ld	s1,64(sp)
    80005e24:	6526                	ld	a0,72(sp)
    80005e26:	65c6                	ld	a1,80(sp)
    80005e28:	6666                	ld	a2,88(sp)
    80005e2a:	7686                	ld	a3,96(sp)
    80005e2c:	7726                	ld	a4,104(sp)
    80005e2e:	77c6                	ld	a5,112(sp)
    80005e30:	7866                	ld	a6,120(sp)
    80005e32:	688a                	ld	a7,128(sp)
    80005e34:	692a                	ld	s2,136(sp)
    80005e36:	69ca                	ld	s3,144(sp)
    80005e38:	6a6a                	ld	s4,152(sp)
    80005e3a:	7a8a                	ld	s5,160(sp)
    80005e3c:	7b2a                	ld	s6,168(sp)
    80005e3e:	7bca                	ld	s7,176(sp)
    80005e40:	7c6a                	ld	s8,184(sp)
    80005e42:	6c8e                	ld	s9,192(sp)
    80005e44:	6d2e                	ld	s10,200(sp)
    80005e46:	6dce                	ld	s11,208(sp)
    80005e48:	6e6e                	ld	t3,216(sp)
    80005e4a:	7e8e                	ld	t4,224(sp)
    80005e4c:	7f2e                	ld	t5,232(sp)
    80005e4e:	7fce                	ld	t6,240(sp)
    80005e50:	6111                	addi	sp,sp,256
    80005e52:	10200073          	sret
    80005e56:	00000013          	nop
    80005e5a:	00000013          	nop
    80005e5e:	0001                	nop

0000000080005e60 <timervec>:
    80005e60:	34051573          	csrrw	a0,mscratch,a0
    80005e64:	e10c                	sd	a1,0(a0)
    80005e66:	e510                	sd	a2,8(a0)
    80005e68:	e914                	sd	a3,16(a0)
    80005e6a:	710c                	ld	a1,32(a0)
    80005e6c:	7510                	ld	a2,40(a0)
    80005e6e:	6194                	ld	a3,0(a1)
    80005e70:	96b2                	add	a3,a3,a2
    80005e72:	e194                	sd	a3,0(a1)
    80005e74:	4589                	li	a1,2
    80005e76:	14459073          	csrw	sip,a1
    80005e7a:	6914                	ld	a3,16(a0)
    80005e7c:	6510                	ld	a2,8(a0)
    80005e7e:	610c                	ld	a1,0(a0)
    80005e80:	34051573          	csrrw	a0,mscratch,a0
    80005e84:	30200073          	mret
	...

0000000080005e8a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e8a:	1141                	addi	sp,sp,-16
    80005e8c:	e422                	sd	s0,8(sp)
    80005e8e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e90:	0c0007b7          	lui	a5,0xc000
    80005e94:	4705                	li	a4,1
    80005e96:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e98:	c3d8                	sw	a4,4(a5)
}
    80005e9a:	6422                	ld	s0,8(sp)
    80005e9c:	0141                	addi	sp,sp,16
    80005e9e:	8082                	ret

0000000080005ea0 <plicinithart>:

void
plicinithart(void)
{
    80005ea0:	1141                	addi	sp,sp,-16
    80005ea2:	e406                	sd	ra,8(sp)
    80005ea4:	e022                	sd	s0,0(sp)
    80005ea6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ea8:	ffffc097          	auipc	ra,0xffffc
    80005eac:	b8e080e7          	jalr	-1138(ra) # 80001a36 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005eb0:	0085171b          	slliw	a4,a0,0x8
    80005eb4:	0c0027b7          	lui	a5,0xc002
    80005eb8:	97ba                	add	a5,a5,a4
    80005eba:	40200713          	li	a4,1026
    80005ebe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ec2:	00d5151b          	slliw	a0,a0,0xd
    80005ec6:	0c2017b7          	lui	a5,0xc201
    80005eca:	953e                	add	a0,a0,a5
    80005ecc:	00052023          	sw	zero,0(a0)
}
    80005ed0:	60a2                	ld	ra,8(sp)
    80005ed2:	6402                	ld	s0,0(sp)
    80005ed4:	0141                	addi	sp,sp,16
    80005ed6:	8082                	ret

0000000080005ed8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ed8:	1141                	addi	sp,sp,-16
    80005eda:	e406                	sd	ra,8(sp)
    80005edc:	e022                	sd	s0,0(sp)
    80005ede:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ee0:	ffffc097          	auipc	ra,0xffffc
    80005ee4:	b56080e7          	jalr	-1194(ra) # 80001a36 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ee8:	00d5179b          	slliw	a5,a0,0xd
    80005eec:	0c201537          	lui	a0,0xc201
    80005ef0:	953e                	add	a0,a0,a5
  return irq;
}
    80005ef2:	4148                	lw	a0,4(a0)
    80005ef4:	60a2                	ld	ra,8(sp)
    80005ef6:	6402                	ld	s0,0(sp)
    80005ef8:	0141                	addi	sp,sp,16
    80005efa:	8082                	ret

0000000080005efc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005efc:	1101                	addi	sp,sp,-32
    80005efe:	ec06                	sd	ra,24(sp)
    80005f00:	e822                	sd	s0,16(sp)
    80005f02:	e426                	sd	s1,8(sp)
    80005f04:	1000                	addi	s0,sp,32
    80005f06:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f08:	ffffc097          	auipc	ra,0xffffc
    80005f0c:	b2e080e7          	jalr	-1234(ra) # 80001a36 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f10:	00d5151b          	slliw	a0,a0,0xd
    80005f14:	0c2017b7          	lui	a5,0xc201
    80005f18:	97aa                	add	a5,a5,a0
    80005f1a:	c3c4                	sw	s1,4(a5)
}
    80005f1c:	60e2                	ld	ra,24(sp)
    80005f1e:	6442                	ld	s0,16(sp)
    80005f20:	64a2                	ld	s1,8(sp)
    80005f22:	6105                	addi	sp,sp,32
    80005f24:	8082                	ret

0000000080005f26 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f26:	1141                	addi	sp,sp,-16
    80005f28:	e406                	sd	ra,8(sp)
    80005f2a:	e022                	sd	s0,0(sp)
    80005f2c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f2e:	479d                	li	a5,7
    80005f30:	04a7cc63          	blt	a5,a0,80005f88 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005f34:	0001e797          	auipc	a5,0x1e
    80005f38:	0cc78793          	addi	a5,a5,204 # 80024000 <disk>
    80005f3c:	00a78733          	add	a4,a5,a0
    80005f40:	6789                	lui	a5,0x2
    80005f42:	97ba                	add	a5,a5,a4
    80005f44:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005f48:	eba1                	bnez	a5,80005f98 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005f4a:	00451713          	slli	a4,a0,0x4
    80005f4e:	00020797          	auipc	a5,0x20
    80005f52:	0b27b783          	ld	a5,178(a5) # 80026000 <disk+0x2000>
    80005f56:	97ba                	add	a5,a5,a4
    80005f58:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005f5c:	0001e797          	auipc	a5,0x1e
    80005f60:	0a478793          	addi	a5,a5,164 # 80024000 <disk>
    80005f64:	97aa                	add	a5,a5,a0
    80005f66:	6509                	lui	a0,0x2
    80005f68:	953e                	add	a0,a0,a5
    80005f6a:	4785                	li	a5,1
    80005f6c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005f70:	00020517          	auipc	a0,0x20
    80005f74:	0a850513          	addi	a0,a0,168 # 80026018 <disk+0x2018>
    80005f78:	ffffc097          	auipc	ra,0xffffc
    80005f7c:	4aa080e7          	jalr	1194(ra) # 80002422 <wakeup>
}
    80005f80:	60a2                	ld	ra,8(sp)
    80005f82:	6402                	ld	s0,0(sp)
    80005f84:	0141                	addi	sp,sp,16
    80005f86:	8082                	ret
    panic("virtio_disk_intr 1");
    80005f88:	00002517          	auipc	a0,0x2
    80005f8c:	79050513          	addi	a0,a0,1936 # 80008718 <syscalls+0x340>
    80005f90:	ffffa097          	auipc	ra,0xffffa
    80005f94:	5b2080e7          	jalr	1458(ra) # 80000542 <panic>
    panic("virtio_disk_intr 2");
    80005f98:	00002517          	auipc	a0,0x2
    80005f9c:	79850513          	addi	a0,a0,1944 # 80008730 <syscalls+0x358>
    80005fa0:	ffffa097          	auipc	ra,0xffffa
    80005fa4:	5a2080e7          	jalr	1442(ra) # 80000542 <panic>

0000000080005fa8 <virtio_disk_init>:
{
    80005fa8:	1101                	addi	sp,sp,-32
    80005faa:	ec06                	sd	ra,24(sp)
    80005fac:	e822                	sd	s0,16(sp)
    80005fae:	e426                	sd	s1,8(sp)
    80005fb0:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fb2:	00002597          	auipc	a1,0x2
    80005fb6:	79658593          	addi	a1,a1,1942 # 80008748 <syscalls+0x370>
    80005fba:	00020517          	auipc	a0,0x20
    80005fbe:	0ee50513          	addi	a0,a0,238 # 800260a8 <disk+0x20a8>
    80005fc2:	ffffb097          	auipc	ra,0xffffb
    80005fc6:	c18080e7          	jalr	-1000(ra) # 80000bda <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fca:	100017b7          	lui	a5,0x10001
    80005fce:	4398                	lw	a4,0(a5)
    80005fd0:	2701                	sext.w	a4,a4
    80005fd2:	747277b7          	lui	a5,0x74727
    80005fd6:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005fda:	0ef71163          	bne	a4,a5,800060bc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005fde:	100017b7          	lui	a5,0x10001
    80005fe2:	43dc                	lw	a5,4(a5)
    80005fe4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fe6:	4705                	li	a4,1
    80005fe8:	0ce79a63          	bne	a5,a4,800060bc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fec:	100017b7          	lui	a5,0x10001
    80005ff0:	479c                	lw	a5,8(a5)
    80005ff2:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005ff4:	4709                	li	a4,2
    80005ff6:	0ce79363          	bne	a5,a4,800060bc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005ffa:	100017b7          	lui	a5,0x10001
    80005ffe:	47d8                	lw	a4,12(a5)
    80006000:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006002:	554d47b7          	lui	a5,0x554d4
    80006006:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000600a:	0af71963          	bne	a4,a5,800060bc <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000600e:	100017b7          	lui	a5,0x10001
    80006012:	4705                	li	a4,1
    80006014:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006016:	470d                	li	a4,3
    80006018:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000601a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000601c:	c7ffe737          	lui	a4,0xc7ffe
    80006020:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd775f>
    80006024:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006026:	2701                	sext.w	a4,a4
    80006028:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000602a:	472d                	li	a4,11
    8000602c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000602e:	473d                	li	a4,15
    80006030:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006032:	6705                	lui	a4,0x1
    80006034:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006036:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000603a:	5bdc                	lw	a5,52(a5)
    8000603c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000603e:	c7d9                	beqz	a5,800060cc <virtio_disk_init+0x124>
  if(max < NUM)
    80006040:	471d                	li	a4,7
    80006042:	08f77d63          	bgeu	a4,a5,800060dc <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006046:	100014b7          	lui	s1,0x10001
    8000604a:	47a1                	li	a5,8
    8000604c:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    8000604e:	6609                	lui	a2,0x2
    80006050:	4581                	li	a1,0
    80006052:	0001e517          	auipc	a0,0x1e
    80006056:	fae50513          	addi	a0,a0,-82 # 80024000 <disk>
    8000605a:	ffffb097          	auipc	ra,0xffffb
    8000605e:	d0c080e7          	jalr	-756(ra) # 80000d66 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006062:	0001e717          	auipc	a4,0x1e
    80006066:	f9e70713          	addi	a4,a4,-98 # 80024000 <disk>
    8000606a:	00c75793          	srli	a5,a4,0xc
    8000606e:	2781                	sext.w	a5,a5
    80006070:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80006072:	00020797          	auipc	a5,0x20
    80006076:	f8e78793          	addi	a5,a5,-114 # 80026000 <disk+0x2000>
    8000607a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    8000607c:	0001e717          	auipc	a4,0x1e
    80006080:	00470713          	addi	a4,a4,4 # 80024080 <disk+0x80>
    80006084:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80006086:	0001f717          	auipc	a4,0x1f
    8000608a:	f7a70713          	addi	a4,a4,-134 # 80025000 <disk+0x1000>
    8000608e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006090:	4705                	li	a4,1
    80006092:	00e78c23          	sb	a4,24(a5)
    80006096:	00e78ca3          	sb	a4,25(a5)
    8000609a:	00e78d23          	sb	a4,26(a5)
    8000609e:	00e78da3          	sb	a4,27(a5)
    800060a2:	00e78e23          	sb	a4,28(a5)
    800060a6:	00e78ea3          	sb	a4,29(a5)
    800060aa:	00e78f23          	sb	a4,30(a5)
    800060ae:	00e78fa3          	sb	a4,31(a5)
}
    800060b2:	60e2                	ld	ra,24(sp)
    800060b4:	6442                	ld	s0,16(sp)
    800060b6:	64a2                	ld	s1,8(sp)
    800060b8:	6105                	addi	sp,sp,32
    800060ba:	8082                	ret
    panic("could not find virtio disk");
    800060bc:	00002517          	auipc	a0,0x2
    800060c0:	69c50513          	addi	a0,a0,1692 # 80008758 <syscalls+0x380>
    800060c4:	ffffa097          	auipc	ra,0xffffa
    800060c8:	47e080e7          	jalr	1150(ra) # 80000542 <panic>
    panic("virtio disk has no queue 0");
    800060cc:	00002517          	auipc	a0,0x2
    800060d0:	6ac50513          	addi	a0,a0,1708 # 80008778 <syscalls+0x3a0>
    800060d4:	ffffa097          	auipc	ra,0xffffa
    800060d8:	46e080e7          	jalr	1134(ra) # 80000542 <panic>
    panic("virtio disk max queue too short");
    800060dc:	00002517          	auipc	a0,0x2
    800060e0:	6bc50513          	addi	a0,a0,1724 # 80008798 <syscalls+0x3c0>
    800060e4:	ffffa097          	auipc	ra,0xffffa
    800060e8:	45e080e7          	jalr	1118(ra) # 80000542 <panic>

00000000800060ec <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060ec:	7175                	addi	sp,sp,-144
    800060ee:	e506                	sd	ra,136(sp)
    800060f0:	e122                	sd	s0,128(sp)
    800060f2:	fca6                	sd	s1,120(sp)
    800060f4:	f8ca                	sd	s2,112(sp)
    800060f6:	f4ce                	sd	s3,104(sp)
    800060f8:	f0d2                	sd	s4,96(sp)
    800060fa:	ecd6                	sd	s5,88(sp)
    800060fc:	e8da                	sd	s6,80(sp)
    800060fe:	e4de                	sd	s7,72(sp)
    80006100:	e0e2                	sd	s8,64(sp)
    80006102:	fc66                	sd	s9,56(sp)
    80006104:	f86a                	sd	s10,48(sp)
    80006106:	f46e                	sd	s11,40(sp)
    80006108:	0900                	addi	s0,sp,144
    8000610a:	8aaa                	mv	s5,a0
    8000610c:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000610e:	00c52c83          	lw	s9,12(a0)
    80006112:	001c9c9b          	slliw	s9,s9,0x1
    80006116:	1c82                	slli	s9,s9,0x20
    80006118:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000611c:	00020517          	auipc	a0,0x20
    80006120:	f8c50513          	addi	a0,a0,-116 # 800260a8 <disk+0x20a8>
    80006124:	ffffb097          	auipc	ra,0xffffb
    80006128:	b46080e7          	jalr	-1210(ra) # 80000c6a <acquire>
  for(int i = 0; i < 3; i++){
    8000612c:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000612e:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006130:	0001ec17          	auipc	s8,0x1e
    80006134:	ed0c0c13          	addi	s8,s8,-304 # 80024000 <disk>
    80006138:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    8000613a:	4b0d                	li	s6,3
    8000613c:	a0ad                	j	800061a6 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    8000613e:	00fc0733          	add	a4,s8,a5
    80006142:	975e                	add	a4,a4,s7
    80006144:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006148:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000614a:	0207c563          	bltz	a5,80006174 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000614e:	2905                	addiw	s2,s2,1
    80006150:	0611                	addi	a2,a2,4
    80006152:	19690d63          	beq	s2,s6,800062ec <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006156:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006158:	00020717          	auipc	a4,0x20
    8000615c:	ec070713          	addi	a4,a4,-320 # 80026018 <disk+0x2018>
    80006160:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006162:	00074683          	lbu	a3,0(a4)
    80006166:	fee1                	bnez	a3,8000613e <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006168:	2785                	addiw	a5,a5,1
    8000616a:	0705                	addi	a4,a4,1
    8000616c:	fe979be3          	bne	a5,s1,80006162 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006170:	57fd                	li	a5,-1
    80006172:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006174:	01205d63          	blez	s2,8000618e <virtio_disk_rw+0xa2>
    80006178:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    8000617a:	000a2503          	lw	a0,0(s4)
    8000617e:	00000097          	auipc	ra,0x0
    80006182:	da8080e7          	jalr	-600(ra) # 80005f26 <free_desc>
      for(int j = 0; j < i; j++)
    80006186:	2d85                	addiw	s11,s11,1
    80006188:	0a11                	addi	s4,s4,4
    8000618a:	ffb918e3          	bne	s2,s11,8000617a <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000618e:	00020597          	auipc	a1,0x20
    80006192:	f1a58593          	addi	a1,a1,-230 # 800260a8 <disk+0x20a8>
    80006196:	00020517          	auipc	a0,0x20
    8000619a:	e8250513          	addi	a0,a0,-382 # 80026018 <disk+0x2018>
    8000619e:	ffffc097          	auipc	ra,0xffffc
    800061a2:	104080e7          	jalr	260(ra) # 800022a2 <sleep>
  for(int i = 0; i < 3; i++){
    800061a6:	f8040a13          	addi	s4,s0,-128
{
    800061aa:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800061ac:	894e                	mv	s2,s3
    800061ae:	b765                	j	80006156 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800061b0:	00020717          	auipc	a4,0x20
    800061b4:	e5073703          	ld	a4,-432(a4) # 80026000 <disk+0x2000>
    800061b8:	973e                	add	a4,a4,a5
    800061ba:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800061be:	0001e517          	auipc	a0,0x1e
    800061c2:	e4250513          	addi	a0,a0,-446 # 80024000 <disk>
    800061c6:	00020717          	auipc	a4,0x20
    800061ca:	e3a70713          	addi	a4,a4,-454 # 80026000 <disk+0x2000>
    800061ce:	6314                	ld	a3,0(a4)
    800061d0:	96be                	add	a3,a3,a5
    800061d2:	00c6d603          	lhu	a2,12(a3)
    800061d6:	00166613          	ori	a2,a2,1
    800061da:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800061de:	f8842683          	lw	a3,-120(s0)
    800061e2:	6310                	ld	a2,0(a4)
    800061e4:	97b2                	add	a5,a5,a2
    800061e6:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    800061ea:	20048613          	addi	a2,s1,512 # 10001200 <_entry-0x6fffee00>
    800061ee:	0612                	slli	a2,a2,0x4
    800061f0:	962a                	add	a2,a2,a0
    800061f2:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800061f6:	00469793          	slli	a5,a3,0x4
    800061fa:	630c                	ld	a1,0(a4)
    800061fc:	95be                	add	a1,a1,a5
    800061fe:	6689                	lui	a3,0x2
    80006200:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006204:	96ca                	add	a3,a3,s2
    80006206:	96aa                	add	a3,a3,a0
    80006208:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    8000620a:	6314                	ld	a3,0(a4)
    8000620c:	96be                	add	a3,a3,a5
    8000620e:	4585                	li	a1,1
    80006210:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006212:	6314                	ld	a3,0(a4)
    80006214:	96be                	add	a3,a3,a5
    80006216:	4509                	li	a0,2
    80006218:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    8000621c:	6314                	ld	a3,0(a4)
    8000621e:	97b6                	add	a5,a5,a3
    80006220:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006224:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006228:	03563423          	sd	s5,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    8000622c:	6714                	ld	a3,8(a4)
    8000622e:	0026d783          	lhu	a5,2(a3)
    80006232:	8b9d                	andi	a5,a5,7
    80006234:	0789                	addi	a5,a5,2
    80006236:	0786                	slli	a5,a5,0x1
    80006238:	97b6                	add	a5,a5,a3
    8000623a:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    8000623e:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    80006242:	6718                	ld	a4,8(a4)
    80006244:	00275783          	lhu	a5,2(a4)
    80006248:	2785                	addiw	a5,a5,1
    8000624a:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000624e:	100017b7          	lui	a5,0x10001
    80006252:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006256:	004aa783          	lw	a5,4(s5)
    8000625a:	02b79163          	bne	a5,a1,8000627c <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    8000625e:	00020917          	auipc	s2,0x20
    80006262:	e4a90913          	addi	s2,s2,-438 # 800260a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006266:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006268:	85ca                	mv	a1,s2
    8000626a:	8556                	mv	a0,s5
    8000626c:	ffffc097          	auipc	ra,0xffffc
    80006270:	036080e7          	jalr	54(ra) # 800022a2 <sleep>
  while(b->disk == 1) {
    80006274:	004aa783          	lw	a5,4(s5)
    80006278:	fe9788e3          	beq	a5,s1,80006268 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    8000627c:	f8042483          	lw	s1,-128(s0)
    80006280:	20048793          	addi	a5,s1,512
    80006284:	00479713          	slli	a4,a5,0x4
    80006288:	0001e797          	auipc	a5,0x1e
    8000628c:	d7878793          	addi	a5,a5,-648 # 80024000 <disk>
    80006290:	97ba                	add	a5,a5,a4
    80006292:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006296:	00020917          	auipc	s2,0x20
    8000629a:	d6a90913          	addi	s2,s2,-662 # 80026000 <disk+0x2000>
    8000629e:	a019                	j	800062a4 <virtio_disk_rw+0x1b8>
      i = disk.desc[i].next;
    800062a0:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    800062a4:	8526                	mv	a0,s1
    800062a6:	00000097          	auipc	ra,0x0
    800062aa:	c80080e7          	jalr	-896(ra) # 80005f26 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800062ae:	0492                	slli	s1,s1,0x4
    800062b0:	00093783          	ld	a5,0(s2)
    800062b4:	94be                	add	s1,s1,a5
    800062b6:	00c4d783          	lhu	a5,12(s1)
    800062ba:	8b85                	andi	a5,a5,1
    800062bc:	f3f5                	bnez	a5,800062a0 <virtio_disk_rw+0x1b4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062be:	00020517          	auipc	a0,0x20
    800062c2:	dea50513          	addi	a0,a0,-534 # 800260a8 <disk+0x20a8>
    800062c6:	ffffb097          	auipc	ra,0xffffb
    800062ca:	a58080e7          	jalr	-1448(ra) # 80000d1e <release>
}
    800062ce:	60aa                	ld	ra,136(sp)
    800062d0:	640a                	ld	s0,128(sp)
    800062d2:	74e6                	ld	s1,120(sp)
    800062d4:	7946                	ld	s2,112(sp)
    800062d6:	79a6                	ld	s3,104(sp)
    800062d8:	7a06                	ld	s4,96(sp)
    800062da:	6ae6                	ld	s5,88(sp)
    800062dc:	6b46                	ld	s6,80(sp)
    800062de:	6ba6                	ld	s7,72(sp)
    800062e0:	6c06                	ld	s8,64(sp)
    800062e2:	7ce2                	ld	s9,56(sp)
    800062e4:	7d42                	ld	s10,48(sp)
    800062e6:	7da2                	ld	s11,40(sp)
    800062e8:	6149                	addi	sp,sp,144
    800062ea:	8082                	ret
  if(write)
    800062ec:	01a037b3          	snez	a5,s10
    800062f0:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    800062f4:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    800062f8:	f7943c23          	sd	s9,-136(s0)
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    800062fc:	f8042483          	lw	s1,-128(s0)
    80006300:	00449913          	slli	s2,s1,0x4
    80006304:	00020997          	auipc	s3,0x20
    80006308:	cfc98993          	addi	s3,s3,-772 # 80026000 <disk+0x2000>
    8000630c:	0009ba03          	ld	s4,0(s3)
    80006310:	9a4a                	add	s4,s4,s2
    80006312:	f7040513          	addi	a0,s0,-144
    80006316:	ffffb097          	auipc	ra,0xffffb
    8000631a:	dde080e7          	jalr	-546(ra) # 800010f4 <kvmpa>
    8000631e:	00aa3023          	sd	a0,0(s4)
  disk.desc[idx[0]].len = sizeof(buf0);
    80006322:	0009b783          	ld	a5,0(s3)
    80006326:	97ca                	add	a5,a5,s2
    80006328:	4741                	li	a4,16
    8000632a:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000632c:	0009b783          	ld	a5,0(s3)
    80006330:	97ca                	add	a5,a5,s2
    80006332:	4705                	li	a4,1
    80006334:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006338:	f8442783          	lw	a5,-124(s0)
    8000633c:	0009b703          	ld	a4,0(s3)
    80006340:	974a                	add	a4,a4,s2
    80006342:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006346:	0792                	slli	a5,a5,0x4
    80006348:	0009b703          	ld	a4,0(s3)
    8000634c:	973e                	add	a4,a4,a5
    8000634e:	058a8693          	addi	a3,s5,88
    80006352:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    80006354:	0009b703          	ld	a4,0(s3)
    80006358:	973e                	add	a4,a4,a5
    8000635a:	40000693          	li	a3,1024
    8000635e:	c714                	sw	a3,8(a4)
  if(write)
    80006360:	e40d18e3          	bnez	s10,800061b0 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006364:	00020717          	auipc	a4,0x20
    80006368:	c9c73703          	ld	a4,-868(a4) # 80026000 <disk+0x2000>
    8000636c:	973e                	add	a4,a4,a5
    8000636e:	4689                	li	a3,2
    80006370:	00d71623          	sh	a3,12(a4)
    80006374:	b5a9                	j	800061be <virtio_disk_rw+0xd2>

0000000080006376 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006376:	1101                	addi	sp,sp,-32
    80006378:	ec06                	sd	ra,24(sp)
    8000637a:	e822                	sd	s0,16(sp)
    8000637c:	e426                	sd	s1,8(sp)
    8000637e:	e04a                	sd	s2,0(sp)
    80006380:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006382:	00020517          	auipc	a0,0x20
    80006386:	d2650513          	addi	a0,a0,-730 # 800260a8 <disk+0x20a8>
    8000638a:	ffffb097          	auipc	ra,0xffffb
    8000638e:	8e0080e7          	jalr	-1824(ra) # 80000c6a <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006392:	00020717          	auipc	a4,0x20
    80006396:	c6e70713          	addi	a4,a4,-914 # 80026000 <disk+0x2000>
    8000639a:	02075783          	lhu	a5,32(a4)
    8000639e:	6b18                	ld	a4,16(a4)
    800063a0:	00275683          	lhu	a3,2(a4)
    800063a4:	8ebd                	xor	a3,a3,a5
    800063a6:	8a9d                	andi	a3,a3,7
    800063a8:	cab9                	beqz	a3,800063fe <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    800063aa:	0001e917          	auipc	s2,0x1e
    800063ae:	c5690913          	addi	s2,s2,-938 # 80024000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800063b2:	00020497          	auipc	s1,0x20
    800063b6:	c4e48493          	addi	s1,s1,-946 # 80026000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    800063ba:	078e                	slli	a5,a5,0x3
    800063bc:	97ba                	add	a5,a5,a4
    800063be:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    800063c0:	20078713          	addi	a4,a5,512
    800063c4:	0712                	slli	a4,a4,0x4
    800063c6:	974a                	add	a4,a4,s2
    800063c8:	03074703          	lbu	a4,48(a4)
    800063cc:	ef21                	bnez	a4,80006424 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    800063ce:	20078793          	addi	a5,a5,512
    800063d2:	0792                	slli	a5,a5,0x4
    800063d4:	97ca                	add	a5,a5,s2
    800063d6:	7798                	ld	a4,40(a5)
    800063d8:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800063dc:	7788                	ld	a0,40(a5)
    800063de:	ffffc097          	auipc	ra,0xffffc
    800063e2:	044080e7          	jalr	68(ra) # 80002422 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    800063e6:	0204d783          	lhu	a5,32(s1)
    800063ea:	2785                	addiw	a5,a5,1
    800063ec:	8b9d                	andi	a5,a5,7
    800063ee:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800063f2:	6898                	ld	a4,16(s1)
    800063f4:	00275683          	lhu	a3,2(a4)
    800063f8:	8a9d                	andi	a3,a3,7
    800063fa:	fcf690e3          	bne	a3,a5,800063ba <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800063fe:	10001737          	lui	a4,0x10001
    80006402:	533c                	lw	a5,96(a4)
    80006404:	8b8d                	andi	a5,a5,3
    80006406:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006408:	00020517          	auipc	a0,0x20
    8000640c:	ca050513          	addi	a0,a0,-864 # 800260a8 <disk+0x20a8>
    80006410:	ffffb097          	auipc	ra,0xffffb
    80006414:	90e080e7          	jalr	-1778(ra) # 80000d1e <release>
}
    80006418:	60e2                	ld	ra,24(sp)
    8000641a:	6442                	ld	s0,16(sp)
    8000641c:	64a2                	ld	s1,8(sp)
    8000641e:	6902                	ld	s2,0(sp)
    80006420:	6105                	addi	sp,sp,32
    80006422:	8082                	ret
      panic("virtio_disk_intr status");
    80006424:	00002517          	auipc	a0,0x2
    80006428:	39450513          	addi	a0,a0,916 # 800087b8 <syscalls+0x3e0>
    8000642c:	ffffa097          	auipc	ra,0xffffa
    80006430:	116080e7          	jalr	278(ra) # 80000542 <panic>
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
