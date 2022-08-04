
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
    80000060:	e9478793          	addi	a5,a5,-364 # 80005ef0 <timervec>
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
    800000aa:	e9478793          	addi	a5,a5,-364 # 80000f3a <main>
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
    80000110:	b84080e7          	jalr	-1148(ra) # 80000c90 <acquire>
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
    8000012a:	408080e7          	jalr	1032(ra) # 8000252e <either_copyin>
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
    80000152:	bf6080e7          	jalr	-1034(ra) # 80000d44 <release>

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
    800001a0:	af4080e7          	jalr	-1292(ra) # 80000c90 <acquire>
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
    800001ce:	892080e7          	jalr	-1902(ra) # 80001a5c <myproc>
    800001d2:	591c                	lw	a5,48(a0)
    800001d4:	e7b5                	bnez	a5,80000240 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001d6:	85a6                	mv	a1,s1
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	0a4080e7          	jalr	164(ra) # 8000227e <sleep>
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
    8000021a:	2c2080e7          	jalr	706(ra) # 800024d8 <either_copyout>
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
    80000236:	b12080e7          	jalr	-1262(ra) # 80000d44 <release>

  return target - n;
    8000023a:	413b053b          	subw	a0,s6,s3
    8000023e:	a811                	j	80000252 <consoleread+0xe4>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	5f050513          	addi	a0,a0,1520 # 80011830 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	afc080e7          	jalr	-1284(ra) # 80000d44 <release>
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
    800002dc:	9b8080e7          	jalr	-1608(ra) # 80000c90 <acquire>

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
    800002fa:	28e080e7          	jalr	654(ra) # 80002584 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fe:	00011517          	auipc	a0,0x11
    80000302:	53250513          	addi	a0,a0,1330 # 80011830 <cons>
    80000306:	00001097          	auipc	ra,0x1
    8000030a:	a3e080e7          	jalr	-1474(ra) # 80000d44 <release>
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
    8000044e:	fb4080e7          	jalr	-76(ra) # 800023fe <wakeup>
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
    80000470:	794080e7          	jalr	1940(ra) # 80000c00 <initlock>

  uartinit();
    80000474:	00000097          	auipc	ra,0x0
    80000478:	396080e7          	jalr	918(ra) # 8000080a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047c:	00022797          	auipc	a5,0x22
    80000480:	53478793          	addi	a5,a5,1332 # 800229b0 <devsw>
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
    80000608:	68c080e7          	jalr	1676(ra) # 80000c90 <acquire>
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
    80000766:	5e2080e7          	jalr	1506(ra) # 80000d44 <release>
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
    800007f8:	40c080e7          	jalr	1036(ra) # 80000c00 <initlock>
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
    8000084e:	3b6080e7          	jalr	950(ra) # 80000c00 <initlock>
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
    8000086a:	3de080e7          	jalr	990(ra) # 80000c44 <push_off>

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
    80000898:	450080e7          	jalr	1104(ra) # 80000ce4 <pop_off>
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
    80000912:	af0080e7          	jalr	-1296(ra) # 800023fe <wakeup>
    
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
    80000956:	33e080e7          	jalr	830(ra) # 80000c90 <acquire>
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
    800009ac:	8d6080e7          	jalr	-1834(ra) # 8000227e <sleep>
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
    800009f2:	356080e7          	jalr	854(ra) # 80000d44 <release>
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
    80000a5e:	236080e7          	jalr	566(ra) # 80000c90 <acquire>
  uartstart();
    80000a62:	00000097          	auipc	ra,0x0
    80000a66:	e44080e7          	jalr	-444(ra) # 800008a6 <uartstart>
  release(&uart_tx_lock);
    80000a6a:	8526                	mv	a0,s1
    80000a6c:	00000097          	auipc	ra,0x0
    80000a70:	2d8080e7          	jalr	728(ra) # 80000d44 <release>
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
    80000aae:	2e2080e7          	jalr	738(ra) # 80000d8c <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000ab2:	00011917          	auipc	s2,0x11
    80000ab6:	e7e90913          	addi	s2,s2,-386 # 80011930 <kmem>
    80000aba:	854a                	mv	a0,s2
    80000abc:	00000097          	auipc	ra,0x0
    80000ac0:	1d4080e7          	jalr	468(ra) # 80000c90 <acquire>
  r->next = kmem.freelist;
    80000ac4:	01893783          	ld	a5,24(s2)
    80000ac8:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aca:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ace:	854a                	mv	a0,s2
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	274080e7          	jalr	628(ra) # 80000d44 <release>
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
    80000b5a:	0aa080e7          	jalr	170(ra) # 80000c00 <initlock>
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
    80000b92:	102080e7          	jalr	258(ra) # 80000c90 <acquire>
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
    80000baa:	19e080e7          	jalr	414(ra) # 80000d44 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bae:	6605                	lui	a2,0x1
    80000bb0:	4595                	li	a1,5
    80000bb2:	8526                	mv	a0,s1
    80000bb4:	00000097          	auipc	ra,0x0
    80000bb8:	1d8080e7          	jalr	472(ra) # 80000d8c <memset>
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
    80000bd4:	174080e7          	jalr	372(ra) # 80000d44 <release>
  if(r)
    80000bd8:	b7d5                	j	80000bbc <kalloc+0x42>

0000000080000bda <freemem_size>:
int
freemem_size(void){
    80000bda:	1141                	addi	sp,sp,-16
    80000bdc:	e422                	sd	s0,8(sp)
    80000bde:	0800                	addi	s0,sp,16
  struct run*r;
  int num=0;
  for(r=kmem.freelist;r;r=r->next){
    80000be0:	00011797          	auipc	a5,0x11
    80000be4:	d687b783          	ld	a5,-664(a5) # 80011948 <kmem+0x18>
    80000be8:	cb91                	beqz	a5,80000bfc <freemem_size+0x22>
  int num=0;
    80000bea:	4501                	li	a0,0
    num++;
    80000bec:	2505                	addiw	a0,a0,1
  for(r=kmem.freelist;r;r=r->next){
    80000bee:	639c                	ld	a5,0(a5)
    80000bf0:	fff5                	bnez	a5,80000bec <freemem_size+0x12>
  }
  return num*PGSIZE;
    80000bf2:	00c5151b          	slliw	a0,a0,0xc
    80000bf6:	6422                	ld	s0,8(sp)
    80000bf8:	0141                	addi	sp,sp,16
    80000bfa:	8082                	ret
  int num=0;
    80000bfc:	4501                	li	a0,0
    80000bfe:	bfd5                	j	80000bf2 <freemem_size+0x18>

0000000080000c00 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c00:	1141                	addi	sp,sp,-16
    80000c02:	e422                	sd	s0,8(sp)
    80000c04:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c06:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c08:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c0c:	00053823          	sd	zero,16(a0)
}
    80000c10:	6422                	ld	s0,8(sp)
    80000c12:	0141                	addi	sp,sp,16
    80000c14:	8082                	ret

0000000080000c16 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c16:	411c                	lw	a5,0(a0)
    80000c18:	e399                	bnez	a5,80000c1e <holding+0x8>
    80000c1a:	4501                	li	a0,0
  return r;
}
    80000c1c:	8082                	ret
{
    80000c1e:	1101                	addi	sp,sp,-32
    80000c20:	ec06                	sd	ra,24(sp)
    80000c22:	e822                	sd	s0,16(sp)
    80000c24:	e426                	sd	s1,8(sp)
    80000c26:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c28:	6904                	ld	s1,16(a0)
    80000c2a:	00001097          	auipc	ra,0x1
    80000c2e:	e16080e7          	jalr	-490(ra) # 80001a40 <mycpu>
    80000c32:	40a48533          	sub	a0,s1,a0
    80000c36:	00153513          	seqz	a0,a0
}
    80000c3a:	60e2                	ld	ra,24(sp)
    80000c3c:	6442                	ld	s0,16(sp)
    80000c3e:	64a2                	ld	s1,8(sp)
    80000c40:	6105                	addi	sp,sp,32
    80000c42:	8082                	ret

0000000080000c44 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c44:	1101                	addi	sp,sp,-32
    80000c46:	ec06                	sd	ra,24(sp)
    80000c48:	e822                	sd	s0,16(sp)
    80000c4a:	e426                	sd	s1,8(sp)
    80000c4c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4e:	100024f3          	csrr	s1,sstatus
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c56:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c58:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c5c:	00001097          	auipc	ra,0x1
    80000c60:	de4080e7          	jalr	-540(ra) # 80001a40 <mycpu>
    80000c64:	5d3c                	lw	a5,120(a0)
    80000c66:	cf89                	beqz	a5,80000c80 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c68:	00001097          	auipc	ra,0x1
    80000c6c:	dd8080e7          	jalr	-552(ra) # 80001a40 <mycpu>
    80000c70:	5d3c                	lw	a5,120(a0)
    80000c72:	2785                	addiw	a5,a5,1
    80000c74:	dd3c                	sw	a5,120(a0)
}
    80000c76:	60e2                	ld	ra,24(sp)
    80000c78:	6442                	ld	s0,16(sp)
    80000c7a:	64a2                	ld	s1,8(sp)
    80000c7c:	6105                	addi	sp,sp,32
    80000c7e:	8082                	ret
    mycpu()->intena = old;
    80000c80:	00001097          	auipc	ra,0x1
    80000c84:	dc0080e7          	jalr	-576(ra) # 80001a40 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c88:	8085                	srli	s1,s1,0x1
    80000c8a:	8885                	andi	s1,s1,1
    80000c8c:	dd64                	sw	s1,124(a0)
    80000c8e:	bfe9                	j	80000c68 <push_off+0x24>

0000000080000c90 <acquire>:
{
    80000c90:	1101                	addi	sp,sp,-32
    80000c92:	ec06                	sd	ra,24(sp)
    80000c94:	e822                	sd	s0,16(sp)
    80000c96:	e426                	sd	s1,8(sp)
    80000c98:	1000                	addi	s0,sp,32
    80000c9a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	fa8080e7          	jalr	-88(ra) # 80000c44 <push_off>
  if(holding(lk))
    80000ca4:	8526                	mv	a0,s1
    80000ca6:	00000097          	auipc	ra,0x0
    80000caa:	f70080e7          	jalr	-144(ra) # 80000c16 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cae:	4705                	li	a4,1
  if(holding(lk))
    80000cb0:	e115                	bnez	a0,80000cd4 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cb2:	87ba                	mv	a5,a4
    80000cb4:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cb8:	2781                	sext.w	a5,a5
    80000cba:	ffe5                	bnez	a5,80000cb2 <acquire+0x22>
  __sync_synchronize();
    80000cbc:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000cc0:	00001097          	auipc	ra,0x1
    80000cc4:	d80080e7          	jalr	-640(ra) # 80001a40 <mycpu>
    80000cc8:	e888                	sd	a0,16(s1)
}
    80000cca:	60e2                	ld	ra,24(sp)
    80000ccc:	6442                	ld	s0,16(sp)
    80000cce:	64a2                	ld	s1,8(sp)
    80000cd0:	6105                	addi	sp,sp,32
    80000cd2:	8082                	ret
    panic("acquire");
    80000cd4:	00007517          	auipc	a0,0x7
    80000cd8:	3b450513          	addi	a0,a0,948 # 80008088 <digits+0x30>
    80000cdc:	00000097          	auipc	ra,0x0
    80000ce0:	866080e7          	jalr	-1946(ra) # 80000542 <panic>

0000000080000ce4 <pop_off>:

void
pop_off(void)
{
    80000ce4:	1141                	addi	sp,sp,-16
    80000ce6:	e406                	sd	ra,8(sp)
    80000ce8:	e022                	sd	s0,0(sp)
    80000cea:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cec:	00001097          	auipc	ra,0x1
    80000cf0:	d54080e7          	jalr	-684(ra) # 80001a40 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cf4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cf8:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cfa:	e78d                	bnez	a5,80000d24 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cfc:	5d3c                	lw	a5,120(a0)
    80000cfe:	02f05b63          	blez	a5,80000d34 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d02:	37fd                	addiw	a5,a5,-1
    80000d04:	0007871b          	sext.w	a4,a5
    80000d08:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d0a:	eb09                	bnez	a4,80000d1c <pop_off+0x38>
    80000d0c:	5d7c                	lw	a5,124(a0)
    80000d0e:	c799                	beqz	a5,80000d1c <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d10:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d14:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d18:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d1c:	60a2                	ld	ra,8(sp)
    80000d1e:	6402                	ld	s0,0(sp)
    80000d20:	0141                	addi	sp,sp,16
    80000d22:	8082                	ret
    panic("pop_off - interruptible");
    80000d24:	00007517          	auipc	a0,0x7
    80000d28:	36c50513          	addi	a0,a0,876 # 80008090 <digits+0x38>
    80000d2c:	00000097          	auipc	ra,0x0
    80000d30:	816080e7          	jalr	-2026(ra) # 80000542 <panic>
    panic("pop_off");
    80000d34:	00007517          	auipc	a0,0x7
    80000d38:	37450513          	addi	a0,a0,884 # 800080a8 <digits+0x50>
    80000d3c:	00000097          	auipc	ra,0x0
    80000d40:	806080e7          	jalr	-2042(ra) # 80000542 <panic>

0000000080000d44 <release>:
{
    80000d44:	1101                	addi	sp,sp,-32
    80000d46:	ec06                	sd	ra,24(sp)
    80000d48:	e822                	sd	s0,16(sp)
    80000d4a:	e426                	sd	s1,8(sp)
    80000d4c:	1000                	addi	s0,sp,32
    80000d4e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d50:	00000097          	auipc	ra,0x0
    80000d54:	ec6080e7          	jalr	-314(ra) # 80000c16 <holding>
    80000d58:	c115                	beqz	a0,80000d7c <release+0x38>
  lk->cpu = 0;
    80000d5a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d5e:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d62:	0f50000f          	fence	iorw,ow
    80000d66:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d6a:	00000097          	auipc	ra,0x0
    80000d6e:	f7a080e7          	jalr	-134(ra) # 80000ce4 <pop_off>
}
    80000d72:	60e2                	ld	ra,24(sp)
    80000d74:	6442                	ld	s0,16(sp)
    80000d76:	64a2                	ld	s1,8(sp)
    80000d78:	6105                	addi	sp,sp,32
    80000d7a:	8082                	ret
    panic("release");
    80000d7c:	00007517          	auipc	a0,0x7
    80000d80:	33450513          	addi	a0,a0,820 # 800080b0 <digits+0x58>
    80000d84:	fffff097          	auipc	ra,0xfffff
    80000d88:	7be080e7          	jalr	1982(ra) # 80000542 <panic>

0000000080000d8c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d8c:	1141                	addi	sp,sp,-16
    80000d8e:	e422                	sd	s0,8(sp)
    80000d90:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d92:	ca19                	beqz	a2,80000da8 <memset+0x1c>
    80000d94:	87aa                	mv	a5,a0
    80000d96:	1602                	slli	a2,a2,0x20
    80000d98:	9201                	srli	a2,a2,0x20
    80000d9a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d9e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000da2:	0785                	addi	a5,a5,1
    80000da4:	fee79de3          	bne	a5,a4,80000d9e <memset+0x12>
  }
  return dst;
}
    80000da8:	6422                	ld	s0,8(sp)
    80000daa:	0141                	addi	sp,sp,16
    80000dac:	8082                	ret

0000000080000dae <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000dae:	1141                	addi	sp,sp,-16
    80000db0:	e422                	sd	s0,8(sp)
    80000db2:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000db4:	ca05                	beqz	a2,80000de4 <memcmp+0x36>
    80000db6:	fff6069b          	addiw	a3,a2,-1
    80000dba:	1682                	slli	a3,a3,0x20
    80000dbc:	9281                	srli	a3,a3,0x20
    80000dbe:	0685                	addi	a3,a3,1
    80000dc0:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000dc2:	00054783          	lbu	a5,0(a0)
    80000dc6:	0005c703          	lbu	a4,0(a1)
    80000dca:	00e79863          	bne	a5,a4,80000dda <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000dce:	0505                	addi	a0,a0,1
    80000dd0:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000dd2:	fed518e3          	bne	a0,a3,80000dc2 <memcmp+0x14>
  }

  return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	a019                	j	80000dde <memcmp+0x30>
      return *s1 - *s2;
    80000dda:	40e7853b          	subw	a0,a5,a4
}
    80000dde:	6422                	ld	s0,8(sp)
    80000de0:	0141                	addi	sp,sp,16
    80000de2:	8082                	ret
  return 0;
    80000de4:	4501                	li	a0,0
    80000de6:	bfe5                	j	80000dde <memcmp+0x30>

0000000080000de8 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000de8:	1141                	addi	sp,sp,-16
    80000dea:	e422                	sd	s0,8(sp)
    80000dec:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dee:	02a5e563          	bltu	a1,a0,80000e18 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000df2:	fff6069b          	addiw	a3,a2,-1
    80000df6:	ce11                	beqz	a2,80000e12 <memmove+0x2a>
    80000df8:	1682                	slli	a3,a3,0x20
    80000dfa:	9281                	srli	a3,a3,0x20
    80000dfc:	0685                	addi	a3,a3,1
    80000dfe:	96ae                	add	a3,a3,a1
    80000e00:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000e02:	0585                	addi	a1,a1,1
    80000e04:	0785                	addi	a5,a5,1
    80000e06:	fff5c703          	lbu	a4,-1(a1)
    80000e0a:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000e0e:	fed59ae3          	bne	a1,a3,80000e02 <memmove+0x1a>

  return dst;
}
    80000e12:	6422                	ld	s0,8(sp)
    80000e14:	0141                	addi	sp,sp,16
    80000e16:	8082                	ret
  if(s < d && s + n > d){
    80000e18:	02061713          	slli	a4,a2,0x20
    80000e1c:	9301                	srli	a4,a4,0x20
    80000e1e:	00e587b3          	add	a5,a1,a4
    80000e22:	fcf578e3          	bgeu	a0,a5,80000df2 <memmove+0xa>
    d += n;
    80000e26:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e28:	fff6069b          	addiw	a3,a2,-1
    80000e2c:	d27d                	beqz	a2,80000e12 <memmove+0x2a>
    80000e2e:	02069613          	slli	a2,a3,0x20
    80000e32:	9201                	srli	a2,a2,0x20
    80000e34:	fff64613          	not	a2,a2
    80000e38:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e3a:	17fd                	addi	a5,a5,-1
    80000e3c:	177d                	addi	a4,a4,-1
    80000e3e:	0007c683          	lbu	a3,0(a5)
    80000e42:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e46:	fef61ae3          	bne	a2,a5,80000e3a <memmove+0x52>
    80000e4a:	b7e1                	j	80000e12 <memmove+0x2a>

0000000080000e4c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e406                	sd	ra,8(sp)
    80000e50:	e022                	sd	s0,0(sp)
    80000e52:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e54:	00000097          	auipc	ra,0x0
    80000e58:	f94080e7          	jalr	-108(ra) # 80000de8 <memmove>
}
    80000e5c:	60a2                	ld	ra,8(sp)
    80000e5e:	6402                	ld	s0,0(sp)
    80000e60:	0141                	addi	sp,sp,16
    80000e62:	8082                	ret

0000000080000e64 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e64:	1141                	addi	sp,sp,-16
    80000e66:	e422                	sd	s0,8(sp)
    80000e68:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e6a:	ce11                	beqz	a2,80000e86 <strncmp+0x22>
    80000e6c:	00054783          	lbu	a5,0(a0)
    80000e70:	cf89                	beqz	a5,80000e8a <strncmp+0x26>
    80000e72:	0005c703          	lbu	a4,0(a1)
    80000e76:	00f71a63          	bne	a4,a5,80000e8a <strncmp+0x26>
    n--, p++, q++;
    80000e7a:	367d                	addiw	a2,a2,-1
    80000e7c:	0505                	addi	a0,a0,1
    80000e7e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e80:	f675                	bnez	a2,80000e6c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e82:	4501                	li	a0,0
    80000e84:	a809                	j	80000e96 <strncmp+0x32>
    80000e86:	4501                	li	a0,0
    80000e88:	a039                	j	80000e96 <strncmp+0x32>
  if(n == 0)
    80000e8a:	ca09                	beqz	a2,80000e9c <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e8c:	00054503          	lbu	a0,0(a0)
    80000e90:	0005c783          	lbu	a5,0(a1)
    80000e94:	9d1d                	subw	a0,a0,a5
}
    80000e96:	6422                	ld	s0,8(sp)
    80000e98:	0141                	addi	sp,sp,16
    80000e9a:	8082                	ret
    return 0;
    80000e9c:	4501                	li	a0,0
    80000e9e:	bfe5                	j	80000e96 <strncmp+0x32>

0000000080000ea0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000ea0:	1141                	addi	sp,sp,-16
    80000ea2:	e422                	sd	s0,8(sp)
    80000ea4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000ea6:	872a                	mv	a4,a0
    80000ea8:	8832                	mv	a6,a2
    80000eaa:	367d                	addiw	a2,a2,-1
    80000eac:	01005963          	blez	a6,80000ebe <strncpy+0x1e>
    80000eb0:	0705                	addi	a4,a4,1
    80000eb2:	0005c783          	lbu	a5,0(a1)
    80000eb6:	fef70fa3          	sb	a5,-1(a4)
    80000eba:	0585                	addi	a1,a1,1
    80000ebc:	f7f5                	bnez	a5,80000ea8 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ebe:	86ba                	mv	a3,a4
    80000ec0:	00c05c63          	blez	a2,80000ed8 <strncpy+0x38>
    *s++ = 0;
    80000ec4:	0685                	addi	a3,a3,1
    80000ec6:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000eca:	fff6c793          	not	a5,a3
    80000ece:	9fb9                	addw	a5,a5,a4
    80000ed0:	010787bb          	addw	a5,a5,a6
    80000ed4:	fef048e3          	bgtz	a5,80000ec4 <strncpy+0x24>
  return os;
}
    80000ed8:	6422                	ld	s0,8(sp)
    80000eda:	0141                	addi	sp,sp,16
    80000edc:	8082                	ret

0000000080000ede <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ede:	1141                	addi	sp,sp,-16
    80000ee0:	e422                	sd	s0,8(sp)
    80000ee2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ee4:	02c05363          	blez	a2,80000f0a <safestrcpy+0x2c>
    80000ee8:	fff6069b          	addiw	a3,a2,-1
    80000eec:	1682                	slli	a3,a3,0x20
    80000eee:	9281                	srli	a3,a3,0x20
    80000ef0:	96ae                	add	a3,a3,a1
    80000ef2:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ef4:	00d58963          	beq	a1,a3,80000f06 <safestrcpy+0x28>
    80000ef8:	0585                	addi	a1,a1,1
    80000efa:	0785                	addi	a5,a5,1
    80000efc:	fff5c703          	lbu	a4,-1(a1)
    80000f00:	fee78fa3          	sb	a4,-1(a5)
    80000f04:	fb65                	bnez	a4,80000ef4 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f06:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f0a:	6422                	ld	s0,8(sp)
    80000f0c:	0141                	addi	sp,sp,16
    80000f0e:	8082                	ret

0000000080000f10 <strlen>:

int
strlen(const char *s)
{
    80000f10:	1141                	addi	sp,sp,-16
    80000f12:	e422                	sd	s0,8(sp)
    80000f14:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f16:	00054783          	lbu	a5,0(a0)
    80000f1a:	cf91                	beqz	a5,80000f36 <strlen+0x26>
    80000f1c:	0505                	addi	a0,a0,1
    80000f1e:	87aa                	mv	a5,a0
    80000f20:	4685                	li	a3,1
    80000f22:	9e89                	subw	a3,a3,a0
    80000f24:	00f6853b          	addw	a0,a3,a5
    80000f28:	0785                	addi	a5,a5,1
    80000f2a:	fff7c703          	lbu	a4,-1(a5)
    80000f2e:	fb7d                	bnez	a4,80000f24 <strlen+0x14>
    ;
  return n;
}
    80000f30:	6422                	ld	s0,8(sp)
    80000f32:	0141                	addi	sp,sp,16
    80000f34:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f36:	4501                	li	a0,0
    80000f38:	bfe5                	j	80000f30 <strlen+0x20>

0000000080000f3a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f3a:	1141                	addi	sp,sp,-16
    80000f3c:	e406                	sd	ra,8(sp)
    80000f3e:	e022                	sd	s0,0(sp)
    80000f40:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f42:	00001097          	auipc	ra,0x1
    80000f46:	aee080e7          	jalr	-1298(ra) # 80001a30 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f4a:	00008717          	auipc	a4,0x8
    80000f4e:	0c270713          	addi	a4,a4,194 # 8000900c <started>
  if(cpuid() == 0){
    80000f52:	c139                	beqz	a0,80000f98 <main+0x5e>
    while(started == 0)
    80000f54:	431c                	lw	a5,0(a4)
    80000f56:	2781                	sext.w	a5,a5
    80000f58:	dff5                	beqz	a5,80000f54 <main+0x1a>
      ;
    __sync_synchronize();
    80000f5a:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f5e:	00001097          	auipc	ra,0x1
    80000f62:	ad2080e7          	jalr	-1326(ra) # 80001a30 <cpuid>
    80000f66:	85aa                	mv	a1,a0
    80000f68:	00007517          	auipc	a0,0x7
    80000f6c:	16850513          	addi	a0,a0,360 # 800080d0 <digits+0x78>
    80000f70:	fffff097          	auipc	ra,0xfffff
    80000f74:	61c080e7          	jalr	1564(ra) # 8000058c <printf>
    kvminithart();    // turn on paging
    80000f78:	00000097          	auipc	ra,0x0
    80000f7c:	0d8080e7          	jalr	216(ra) # 80001050 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f80:	00001097          	auipc	ra,0x1
    80000f84:	774080e7          	jalr	1908(ra) # 800026f4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f88:	00005097          	auipc	ra,0x5
    80000f8c:	fa8080e7          	jalr	-88(ra) # 80005f30 <plicinithart>
  }

  scheduler();        
    80000f90:	00001097          	auipc	ra,0x1
    80000f94:	012080e7          	jalr	18(ra) # 80001fa2 <scheduler>
    consoleinit();
    80000f98:	fffff097          	auipc	ra,0xfffff
    80000f9c:	4bc080e7          	jalr	1212(ra) # 80000454 <consoleinit>
    printfinit();
    80000fa0:	00000097          	auipc	ra,0x0
    80000fa4:	838080e7          	jalr	-1992(ra) # 800007d8 <printfinit>
    printf("\n");
    80000fa8:	00007517          	auipc	a0,0x7
    80000fac:	13850513          	addi	a0,a0,312 # 800080e0 <digits+0x88>
    80000fb0:	fffff097          	auipc	ra,0xfffff
    80000fb4:	5dc080e7          	jalr	1500(ra) # 8000058c <printf>
    printf("xv6 kernel is booting\n");
    80000fb8:	00007517          	auipc	a0,0x7
    80000fbc:	10050513          	addi	a0,a0,256 # 800080b8 <digits+0x60>
    80000fc0:	fffff097          	auipc	ra,0xfffff
    80000fc4:	5cc080e7          	jalr	1484(ra) # 8000058c <printf>
    printf("\n");
    80000fc8:	00007517          	auipc	a0,0x7
    80000fcc:	11850513          	addi	a0,a0,280 # 800080e0 <digits+0x88>
    80000fd0:	fffff097          	auipc	ra,0xfffff
    80000fd4:	5bc080e7          	jalr	1468(ra) # 8000058c <printf>
    kinit();         // physical page allocator
    80000fd8:	00000097          	auipc	ra,0x0
    80000fdc:	b66080e7          	jalr	-1178(ra) # 80000b3e <kinit>
    kvminit();       // create kernel page table
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	2a0080e7          	jalr	672(ra) # 80001280 <kvminit>
    kvminithart();   // turn on paging
    80000fe8:	00000097          	auipc	ra,0x0
    80000fec:	068080e7          	jalr	104(ra) # 80001050 <kvminithart>
    procinit();      // process table
    80000ff0:	00001097          	auipc	ra,0x1
    80000ff4:	970080e7          	jalr	-1680(ra) # 80001960 <procinit>
    trapinit();      // trap vectors
    80000ff8:	00001097          	auipc	ra,0x1
    80000ffc:	6d4080e7          	jalr	1748(ra) # 800026cc <trapinit>
    trapinithart();  // install kernel trap vector
    80001000:	00001097          	auipc	ra,0x1
    80001004:	6f4080e7          	jalr	1780(ra) # 800026f4 <trapinithart>
    plicinit();      // set up interrupt controller
    80001008:	00005097          	auipc	ra,0x5
    8000100c:	f12080e7          	jalr	-238(ra) # 80005f1a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001010:	00005097          	auipc	ra,0x5
    80001014:	f20080e7          	jalr	-224(ra) # 80005f30 <plicinithart>
    binit();         // buffer cache
    80001018:	00002097          	auipc	ra,0x2
    8000101c:	0d0080e7          	jalr	208(ra) # 800030e8 <binit>
    iinit();         // inode cache
    80001020:	00002097          	auipc	ra,0x2
    80001024:	760080e7          	jalr	1888(ra) # 80003780 <iinit>
    fileinit();      // file table
    80001028:	00003097          	auipc	ra,0x3
    8000102c:	6fa080e7          	jalr	1786(ra) # 80004722 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001030:	00005097          	auipc	ra,0x5
    80001034:	008080e7          	jalr	8(ra) # 80006038 <virtio_disk_init>
    userinit();      // first user process
    80001038:	00001097          	auipc	ra,0x1
    8000103c:	cee080e7          	jalr	-786(ra) # 80001d26 <userinit>
    __sync_synchronize();
    80001040:	0ff0000f          	fence
    started = 1;
    80001044:	4785                	li	a5,1
    80001046:	00008717          	auipc	a4,0x8
    8000104a:	fcf72323          	sw	a5,-58(a4) # 8000900c <started>
    8000104e:	b789                	j	80000f90 <main+0x56>

0000000080001050 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001050:	1141                	addi	sp,sp,-16
    80001052:	e422                	sd	s0,8(sp)
    80001054:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001056:	00008797          	auipc	a5,0x8
    8000105a:	fba7b783          	ld	a5,-70(a5) # 80009010 <kernel_pagetable>
    8000105e:	83b1                	srli	a5,a5,0xc
    80001060:	577d                	li	a4,-1
    80001062:	177e                	slli	a4,a4,0x3f
    80001064:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001066:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000106a:	12000073          	sfence.vma
  sfence_vma();
}
    8000106e:	6422                	ld	s0,8(sp)
    80001070:	0141                	addi	sp,sp,16
    80001072:	8082                	ret

0000000080001074 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001074:	7139                	addi	sp,sp,-64
    80001076:	fc06                	sd	ra,56(sp)
    80001078:	f822                	sd	s0,48(sp)
    8000107a:	f426                	sd	s1,40(sp)
    8000107c:	f04a                	sd	s2,32(sp)
    8000107e:	ec4e                	sd	s3,24(sp)
    80001080:	e852                	sd	s4,16(sp)
    80001082:	e456                	sd	s5,8(sp)
    80001084:	e05a                	sd	s6,0(sp)
    80001086:	0080                	addi	s0,sp,64
    80001088:	84aa                	mv	s1,a0
    8000108a:	89ae                	mv	s3,a1
    8000108c:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000108e:	57fd                	li	a5,-1
    80001090:	83e9                	srli	a5,a5,0x1a
    80001092:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001094:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001096:	04b7f263          	bgeu	a5,a1,800010da <walk+0x66>
    panic("walk");
    8000109a:	00007517          	auipc	a0,0x7
    8000109e:	04e50513          	addi	a0,a0,78 # 800080e8 <digits+0x90>
    800010a2:	fffff097          	auipc	ra,0xfffff
    800010a6:	4a0080e7          	jalr	1184(ra) # 80000542 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010aa:	060a8663          	beqz	s5,80001116 <walk+0xa2>
    800010ae:	00000097          	auipc	ra,0x0
    800010b2:	acc080e7          	jalr	-1332(ra) # 80000b7a <kalloc>
    800010b6:	84aa                	mv	s1,a0
    800010b8:	c529                	beqz	a0,80001102 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800010ba:	6605                	lui	a2,0x1
    800010bc:	4581                	li	a1,0
    800010be:	00000097          	auipc	ra,0x0
    800010c2:	cce080e7          	jalr	-818(ra) # 80000d8c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010c6:	00c4d793          	srli	a5,s1,0xc
    800010ca:	07aa                	slli	a5,a5,0xa
    800010cc:	0017e793          	ori	a5,a5,1
    800010d0:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010d4:	3a5d                	addiw	s4,s4,-9
    800010d6:	036a0063          	beq	s4,s6,800010f6 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010da:	0149d933          	srl	s2,s3,s4
    800010de:	1ff97913          	andi	s2,s2,511
    800010e2:	090e                	slli	s2,s2,0x3
    800010e4:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010e6:	00093483          	ld	s1,0(s2)
    800010ea:	0014f793          	andi	a5,s1,1
    800010ee:	dfd5                	beqz	a5,800010aa <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010f0:	80a9                	srli	s1,s1,0xa
    800010f2:	04b2                	slli	s1,s1,0xc
    800010f4:	b7c5                	j	800010d4 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010f6:	00c9d513          	srli	a0,s3,0xc
    800010fa:	1ff57513          	andi	a0,a0,511
    800010fe:	050e                	slli	a0,a0,0x3
    80001100:	9526                	add	a0,a0,s1
}
    80001102:	70e2                	ld	ra,56(sp)
    80001104:	7442                	ld	s0,48(sp)
    80001106:	74a2                	ld	s1,40(sp)
    80001108:	7902                	ld	s2,32(sp)
    8000110a:	69e2                	ld	s3,24(sp)
    8000110c:	6a42                	ld	s4,16(sp)
    8000110e:	6aa2                	ld	s5,8(sp)
    80001110:	6b02                	ld	s6,0(sp)
    80001112:	6121                	addi	sp,sp,64
    80001114:	8082                	ret
        return 0;
    80001116:	4501                	li	a0,0
    80001118:	b7ed                	j	80001102 <walk+0x8e>

000000008000111a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000111a:	57fd                	li	a5,-1
    8000111c:	83e9                	srli	a5,a5,0x1a
    8000111e:	00b7f463          	bgeu	a5,a1,80001126 <walkaddr+0xc>
    return 0;
    80001122:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001124:	8082                	ret
{
    80001126:	1141                	addi	sp,sp,-16
    80001128:	e406                	sd	ra,8(sp)
    8000112a:	e022                	sd	s0,0(sp)
    8000112c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000112e:	4601                	li	a2,0
    80001130:	00000097          	auipc	ra,0x0
    80001134:	f44080e7          	jalr	-188(ra) # 80001074 <walk>
  if(pte == 0)
    80001138:	c105                	beqz	a0,80001158 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000113a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000113c:	0117f693          	andi	a3,a5,17
    80001140:	4745                	li	a4,17
    return 0;
    80001142:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001144:	00e68663          	beq	a3,a4,80001150 <walkaddr+0x36>
}
    80001148:	60a2                	ld	ra,8(sp)
    8000114a:	6402                	ld	s0,0(sp)
    8000114c:	0141                	addi	sp,sp,16
    8000114e:	8082                	ret
  pa = PTE2PA(*pte);
    80001150:	00a7d513          	srli	a0,a5,0xa
    80001154:	0532                	slli	a0,a0,0xc
  return pa;
    80001156:	bfcd                	j	80001148 <walkaddr+0x2e>
    return 0;
    80001158:	4501                	li	a0,0
    8000115a:	b7fd                	j	80001148 <walkaddr+0x2e>

000000008000115c <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    8000115c:	1101                	addi	sp,sp,-32
    8000115e:	ec06                	sd	ra,24(sp)
    80001160:	e822                	sd	s0,16(sp)
    80001162:	e426                	sd	s1,8(sp)
    80001164:	1000                	addi	s0,sp,32
    80001166:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001168:	1552                	slli	a0,a0,0x34
    8000116a:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    8000116e:	4601                	li	a2,0
    80001170:	00008517          	auipc	a0,0x8
    80001174:	ea053503          	ld	a0,-352(a0) # 80009010 <kernel_pagetable>
    80001178:	00000097          	auipc	ra,0x0
    8000117c:	efc080e7          	jalr	-260(ra) # 80001074 <walk>
  if(pte == 0)
    80001180:	cd09                	beqz	a0,8000119a <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    80001182:	6108                	ld	a0,0(a0)
    80001184:	00157793          	andi	a5,a0,1
    80001188:	c38d                	beqz	a5,800011aa <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    8000118a:	8129                	srli	a0,a0,0xa
    8000118c:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    8000118e:	9526                	add	a0,a0,s1
    80001190:	60e2                	ld	ra,24(sp)
    80001192:	6442                	ld	s0,16(sp)
    80001194:	64a2                	ld	s1,8(sp)
    80001196:	6105                	addi	sp,sp,32
    80001198:	8082                	ret
    panic("kvmpa");
    8000119a:	00007517          	auipc	a0,0x7
    8000119e:	f5650513          	addi	a0,a0,-170 # 800080f0 <digits+0x98>
    800011a2:	fffff097          	auipc	ra,0xfffff
    800011a6:	3a0080e7          	jalr	928(ra) # 80000542 <panic>
    panic("kvmpa");
    800011aa:	00007517          	auipc	a0,0x7
    800011ae:	f4650513          	addi	a0,a0,-186 # 800080f0 <digits+0x98>
    800011b2:	fffff097          	auipc	ra,0xfffff
    800011b6:	390080e7          	jalr	912(ra) # 80000542 <panic>

00000000800011ba <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	fc26                	sd	s1,56(sp)
    800011c2:	f84a                	sd	s2,48(sp)
    800011c4:	f44e                	sd	s3,40(sp)
    800011c6:	f052                	sd	s4,32(sp)
    800011c8:	ec56                	sd	s5,24(sp)
    800011ca:	e85a                	sd	s6,16(sp)
    800011cc:	e45e                	sd	s7,8(sp)
    800011ce:	0880                	addi	s0,sp,80
    800011d0:	8aaa                	mv	s5,a0
    800011d2:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800011d4:	777d                	lui	a4,0xfffff
    800011d6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800011da:	167d                	addi	a2,a2,-1
    800011dc:	00b609b3          	add	s3,a2,a1
    800011e0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800011e4:	893e                	mv	s2,a5
    800011e6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011ea:	6b85                	lui	s7,0x1
    800011ec:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011f0:	4605                	li	a2,1
    800011f2:	85ca                	mv	a1,s2
    800011f4:	8556                	mv	a0,s5
    800011f6:	00000097          	auipc	ra,0x0
    800011fa:	e7e080e7          	jalr	-386(ra) # 80001074 <walk>
    800011fe:	c51d                	beqz	a0,8000122c <mappages+0x72>
    if(*pte & PTE_V)
    80001200:	611c                	ld	a5,0(a0)
    80001202:	8b85                	andi	a5,a5,1
    80001204:	ef81                	bnez	a5,8000121c <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001206:	80b1                	srli	s1,s1,0xc
    80001208:	04aa                	slli	s1,s1,0xa
    8000120a:	0164e4b3          	or	s1,s1,s6
    8000120e:	0014e493          	ori	s1,s1,1
    80001212:	e104                	sd	s1,0(a0)
    if(a == last)
    80001214:	03390863          	beq	s2,s3,80001244 <mappages+0x8a>
    a += PGSIZE;
    80001218:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000121a:	bfc9                	j	800011ec <mappages+0x32>
      panic("remap");
    8000121c:	00007517          	auipc	a0,0x7
    80001220:	edc50513          	addi	a0,a0,-292 # 800080f8 <digits+0xa0>
    80001224:	fffff097          	auipc	ra,0xfffff
    80001228:	31e080e7          	jalr	798(ra) # 80000542 <panic>
      return -1;
    8000122c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000122e:	60a6                	ld	ra,72(sp)
    80001230:	6406                	ld	s0,64(sp)
    80001232:	74e2                	ld	s1,56(sp)
    80001234:	7942                	ld	s2,48(sp)
    80001236:	79a2                	ld	s3,40(sp)
    80001238:	7a02                	ld	s4,32(sp)
    8000123a:	6ae2                	ld	s5,24(sp)
    8000123c:	6b42                	ld	s6,16(sp)
    8000123e:	6ba2                	ld	s7,8(sp)
    80001240:	6161                	addi	sp,sp,80
    80001242:	8082                	ret
  return 0;
    80001244:	4501                	li	a0,0
    80001246:	b7e5                	j	8000122e <mappages+0x74>

0000000080001248 <kvmmap>:
{
    80001248:	1141                	addi	sp,sp,-16
    8000124a:	e406                	sd	ra,8(sp)
    8000124c:	e022                	sd	s0,0(sp)
    8000124e:	0800                	addi	s0,sp,16
    80001250:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001252:	86ae                	mv	a3,a1
    80001254:	85aa                	mv	a1,a0
    80001256:	00008517          	auipc	a0,0x8
    8000125a:	dba53503          	ld	a0,-582(a0) # 80009010 <kernel_pagetable>
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f5c080e7          	jalr	-164(ra) # 800011ba <mappages>
    80001266:	e509                	bnez	a0,80001270 <kvmmap+0x28>
}
    80001268:	60a2                	ld	ra,8(sp)
    8000126a:	6402                	ld	s0,0(sp)
    8000126c:	0141                	addi	sp,sp,16
    8000126e:	8082                	ret
    panic("kvmmap");
    80001270:	00007517          	auipc	a0,0x7
    80001274:	e9050513          	addi	a0,a0,-368 # 80008100 <digits+0xa8>
    80001278:	fffff097          	auipc	ra,0xfffff
    8000127c:	2ca080e7          	jalr	714(ra) # 80000542 <panic>

0000000080001280 <kvminit>:
{
    80001280:	1101                	addi	sp,sp,-32
    80001282:	ec06                	sd	ra,24(sp)
    80001284:	e822                	sd	s0,16(sp)
    80001286:	e426                	sd	s1,8(sp)
    80001288:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    8000128a:	00000097          	auipc	ra,0x0
    8000128e:	8f0080e7          	jalr	-1808(ra) # 80000b7a <kalloc>
    80001292:	00008797          	auipc	a5,0x8
    80001296:	d6a7bf23          	sd	a0,-642(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    8000129a:	6605                	lui	a2,0x1
    8000129c:	4581                	li	a1,0
    8000129e:	00000097          	auipc	ra,0x0
    800012a2:	aee080e7          	jalr	-1298(ra) # 80000d8c <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012a6:	4699                	li	a3,6
    800012a8:	6605                	lui	a2,0x1
    800012aa:	100005b7          	lui	a1,0x10000
    800012ae:	10000537          	lui	a0,0x10000
    800012b2:	00000097          	auipc	ra,0x0
    800012b6:	f96080e7          	jalr	-106(ra) # 80001248 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012ba:	4699                	li	a3,6
    800012bc:	6605                	lui	a2,0x1
    800012be:	100015b7          	lui	a1,0x10001
    800012c2:	10001537          	lui	a0,0x10001
    800012c6:	00000097          	auipc	ra,0x0
    800012ca:	f82080e7          	jalr	-126(ra) # 80001248 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    800012ce:	4699                	li	a3,6
    800012d0:	6641                	lui	a2,0x10
    800012d2:	020005b7          	lui	a1,0x2000
    800012d6:	02000537          	lui	a0,0x2000
    800012da:	00000097          	auipc	ra,0x0
    800012de:	f6e080e7          	jalr	-146(ra) # 80001248 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012e2:	4699                	li	a3,6
    800012e4:	00400637          	lui	a2,0x400
    800012e8:	0c0005b7          	lui	a1,0xc000
    800012ec:	0c000537          	lui	a0,0xc000
    800012f0:	00000097          	auipc	ra,0x0
    800012f4:	f58080e7          	jalr	-168(ra) # 80001248 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012f8:	00007497          	auipc	s1,0x7
    800012fc:	d0848493          	addi	s1,s1,-760 # 80008000 <etext>
    80001300:	46a9                	li	a3,10
    80001302:	80007617          	auipc	a2,0x80007
    80001306:	cfe60613          	addi	a2,a2,-770 # 8000 <_entry-0x7fff8000>
    8000130a:	4585                	li	a1,1
    8000130c:	05fe                	slli	a1,a1,0x1f
    8000130e:	852e                	mv	a0,a1
    80001310:	00000097          	auipc	ra,0x0
    80001314:	f38080e7          	jalr	-200(ra) # 80001248 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001318:	4699                	li	a3,6
    8000131a:	4645                	li	a2,17
    8000131c:	066e                	slli	a2,a2,0x1b
    8000131e:	8e05                	sub	a2,a2,s1
    80001320:	85a6                	mv	a1,s1
    80001322:	8526                	mv	a0,s1
    80001324:	00000097          	auipc	ra,0x0
    80001328:	f24080e7          	jalr	-220(ra) # 80001248 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000132c:	46a9                	li	a3,10
    8000132e:	6605                	lui	a2,0x1
    80001330:	00006597          	auipc	a1,0x6
    80001334:	cd058593          	addi	a1,a1,-816 # 80007000 <_trampoline>
    80001338:	04000537          	lui	a0,0x4000
    8000133c:	157d                	addi	a0,a0,-1
    8000133e:	0532                	slli	a0,a0,0xc
    80001340:	00000097          	auipc	ra,0x0
    80001344:	f08080e7          	jalr	-248(ra) # 80001248 <kvmmap>
}
    80001348:	60e2                	ld	ra,24(sp)
    8000134a:	6442                	ld	s0,16(sp)
    8000134c:	64a2                	ld	s1,8(sp)
    8000134e:	6105                	addi	sp,sp,32
    80001350:	8082                	ret

0000000080001352 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001352:	715d                	addi	sp,sp,-80
    80001354:	e486                	sd	ra,72(sp)
    80001356:	e0a2                	sd	s0,64(sp)
    80001358:	fc26                	sd	s1,56(sp)
    8000135a:	f84a                	sd	s2,48(sp)
    8000135c:	f44e                	sd	s3,40(sp)
    8000135e:	f052                	sd	s4,32(sp)
    80001360:	ec56                	sd	s5,24(sp)
    80001362:	e85a                	sd	s6,16(sp)
    80001364:	e45e                	sd	s7,8(sp)
    80001366:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001368:	03459793          	slli	a5,a1,0x34
    8000136c:	e795                	bnez	a5,80001398 <uvmunmap+0x46>
    8000136e:	8a2a                	mv	s4,a0
    80001370:	892e                	mv	s2,a1
    80001372:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001374:	0632                	slli	a2,a2,0xc
    80001376:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000137a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000137c:	6b05                	lui	s6,0x1
    8000137e:	0735e263          	bltu	a1,s3,800013e2 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001382:	60a6                	ld	ra,72(sp)
    80001384:	6406                	ld	s0,64(sp)
    80001386:	74e2                	ld	s1,56(sp)
    80001388:	7942                	ld	s2,48(sp)
    8000138a:	79a2                	ld	s3,40(sp)
    8000138c:	7a02                	ld	s4,32(sp)
    8000138e:	6ae2                	ld	s5,24(sp)
    80001390:	6b42                	ld	s6,16(sp)
    80001392:	6ba2                	ld	s7,8(sp)
    80001394:	6161                	addi	sp,sp,80
    80001396:	8082                	ret
    panic("uvmunmap: not aligned");
    80001398:	00007517          	auipc	a0,0x7
    8000139c:	d7050513          	addi	a0,a0,-656 # 80008108 <digits+0xb0>
    800013a0:	fffff097          	auipc	ra,0xfffff
    800013a4:	1a2080e7          	jalr	418(ra) # 80000542 <panic>
      panic("uvmunmap: walk");
    800013a8:	00007517          	auipc	a0,0x7
    800013ac:	d7850513          	addi	a0,a0,-648 # 80008120 <digits+0xc8>
    800013b0:	fffff097          	auipc	ra,0xfffff
    800013b4:	192080e7          	jalr	402(ra) # 80000542 <panic>
      panic("uvmunmap: not mapped");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	d7850513          	addi	a0,a0,-648 # 80008130 <digits+0xd8>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	182080e7          	jalr	386(ra) # 80000542 <panic>
      panic("uvmunmap: not a leaf");
    800013c8:	00007517          	auipc	a0,0x7
    800013cc:	d8050513          	addi	a0,a0,-640 # 80008148 <digits+0xf0>
    800013d0:	fffff097          	auipc	ra,0xfffff
    800013d4:	172080e7          	jalr	370(ra) # 80000542 <panic>
    *pte = 0;
    800013d8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013dc:	995a                	add	s2,s2,s6
    800013de:	fb3972e3          	bgeu	s2,s3,80001382 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013e2:	4601                	li	a2,0
    800013e4:	85ca                	mv	a1,s2
    800013e6:	8552                	mv	a0,s4
    800013e8:	00000097          	auipc	ra,0x0
    800013ec:	c8c080e7          	jalr	-884(ra) # 80001074 <walk>
    800013f0:	84aa                	mv	s1,a0
    800013f2:	d95d                	beqz	a0,800013a8 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013f4:	6108                	ld	a0,0(a0)
    800013f6:	00157793          	andi	a5,a0,1
    800013fa:	dfdd                	beqz	a5,800013b8 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013fc:	3ff57793          	andi	a5,a0,1023
    80001400:	fd7784e3          	beq	a5,s7,800013c8 <uvmunmap+0x76>
    if(do_free){
    80001404:	fc0a8ae3          	beqz	s5,800013d8 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001408:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000140a:	0532                	slli	a0,a0,0xc
    8000140c:	fffff097          	auipc	ra,0xfffff
    80001410:	672080e7          	jalr	1650(ra) # 80000a7e <kfree>
    80001414:	b7d1                	j	800013d8 <uvmunmap+0x86>

0000000080001416 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001416:	1101                	addi	sp,sp,-32
    80001418:	ec06                	sd	ra,24(sp)
    8000141a:	e822                	sd	s0,16(sp)
    8000141c:	e426                	sd	s1,8(sp)
    8000141e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001420:	fffff097          	auipc	ra,0xfffff
    80001424:	75a080e7          	jalr	1882(ra) # 80000b7a <kalloc>
    80001428:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000142a:	c519                	beqz	a0,80001438 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000142c:	6605                	lui	a2,0x1
    8000142e:	4581                	li	a1,0
    80001430:	00000097          	auipc	ra,0x0
    80001434:	95c080e7          	jalr	-1700(ra) # 80000d8c <memset>
  return pagetable;
}
    80001438:	8526                	mv	a0,s1
    8000143a:	60e2                	ld	ra,24(sp)
    8000143c:	6442                	ld	s0,16(sp)
    8000143e:	64a2                	ld	s1,8(sp)
    80001440:	6105                	addi	sp,sp,32
    80001442:	8082                	ret

0000000080001444 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001444:	7179                	addi	sp,sp,-48
    80001446:	f406                	sd	ra,40(sp)
    80001448:	f022                	sd	s0,32(sp)
    8000144a:	ec26                	sd	s1,24(sp)
    8000144c:	e84a                	sd	s2,16(sp)
    8000144e:	e44e                	sd	s3,8(sp)
    80001450:	e052                	sd	s4,0(sp)
    80001452:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001454:	6785                	lui	a5,0x1
    80001456:	04f67863          	bgeu	a2,a5,800014a6 <uvminit+0x62>
    8000145a:	8a2a                	mv	s4,a0
    8000145c:	89ae                	mv	s3,a1
    8000145e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001460:	fffff097          	auipc	ra,0xfffff
    80001464:	71a080e7          	jalr	1818(ra) # 80000b7a <kalloc>
    80001468:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000146a:	6605                	lui	a2,0x1
    8000146c:	4581                	li	a1,0
    8000146e:	00000097          	auipc	ra,0x0
    80001472:	91e080e7          	jalr	-1762(ra) # 80000d8c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001476:	4779                	li	a4,30
    80001478:	86ca                	mv	a3,s2
    8000147a:	6605                	lui	a2,0x1
    8000147c:	4581                	li	a1,0
    8000147e:	8552                	mv	a0,s4
    80001480:	00000097          	auipc	ra,0x0
    80001484:	d3a080e7          	jalr	-710(ra) # 800011ba <mappages>
  memmove(mem, src, sz);
    80001488:	8626                	mv	a2,s1
    8000148a:	85ce                	mv	a1,s3
    8000148c:	854a                	mv	a0,s2
    8000148e:	00000097          	auipc	ra,0x0
    80001492:	95a080e7          	jalr	-1702(ra) # 80000de8 <memmove>
}
    80001496:	70a2                	ld	ra,40(sp)
    80001498:	7402                	ld	s0,32(sp)
    8000149a:	64e2                	ld	s1,24(sp)
    8000149c:	6942                	ld	s2,16(sp)
    8000149e:	69a2                	ld	s3,8(sp)
    800014a0:	6a02                	ld	s4,0(sp)
    800014a2:	6145                	addi	sp,sp,48
    800014a4:	8082                	ret
    panic("inituvm: more than a page");
    800014a6:	00007517          	auipc	a0,0x7
    800014aa:	cba50513          	addi	a0,a0,-838 # 80008160 <digits+0x108>
    800014ae:	fffff097          	auipc	ra,0xfffff
    800014b2:	094080e7          	jalr	148(ra) # 80000542 <panic>

00000000800014b6 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800014b6:	1101                	addi	sp,sp,-32
    800014b8:	ec06                	sd	ra,24(sp)
    800014ba:	e822                	sd	s0,16(sp)
    800014bc:	e426                	sd	s1,8(sp)
    800014be:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800014c0:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800014c2:	00b67d63          	bgeu	a2,a1,800014dc <uvmdealloc+0x26>
    800014c6:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014c8:	6785                	lui	a5,0x1
    800014ca:	17fd                	addi	a5,a5,-1
    800014cc:	00f60733          	add	a4,a2,a5
    800014d0:	767d                	lui	a2,0xfffff
    800014d2:	8f71                	and	a4,a4,a2
    800014d4:	97ae                	add	a5,a5,a1
    800014d6:	8ff1                	and	a5,a5,a2
    800014d8:	00f76863          	bltu	a4,a5,800014e8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014dc:	8526                	mv	a0,s1
    800014de:	60e2                	ld	ra,24(sp)
    800014e0:	6442                	ld	s0,16(sp)
    800014e2:	64a2                	ld	s1,8(sp)
    800014e4:	6105                	addi	sp,sp,32
    800014e6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014e8:	8f99                	sub	a5,a5,a4
    800014ea:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014ec:	4685                	li	a3,1
    800014ee:	0007861b          	sext.w	a2,a5
    800014f2:	85ba                	mv	a1,a4
    800014f4:	00000097          	auipc	ra,0x0
    800014f8:	e5e080e7          	jalr	-418(ra) # 80001352 <uvmunmap>
    800014fc:	b7c5                	j	800014dc <uvmdealloc+0x26>

00000000800014fe <uvmalloc>:
  if(newsz < oldsz)
    800014fe:	0ab66163          	bltu	a2,a1,800015a0 <uvmalloc+0xa2>
{
    80001502:	7139                	addi	sp,sp,-64
    80001504:	fc06                	sd	ra,56(sp)
    80001506:	f822                	sd	s0,48(sp)
    80001508:	f426                	sd	s1,40(sp)
    8000150a:	f04a                	sd	s2,32(sp)
    8000150c:	ec4e                	sd	s3,24(sp)
    8000150e:	e852                	sd	s4,16(sp)
    80001510:	e456                	sd	s5,8(sp)
    80001512:	0080                	addi	s0,sp,64
    80001514:	8aaa                	mv	s5,a0
    80001516:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001518:	6985                	lui	s3,0x1
    8000151a:	19fd                	addi	s3,s3,-1
    8000151c:	95ce                	add	a1,a1,s3
    8000151e:	79fd                	lui	s3,0xfffff
    80001520:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001524:	08c9f063          	bgeu	s3,a2,800015a4 <uvmalloc+0xa6>
    80001528:	894e                	mv	s2,s3
    mem = kalloc();
    8000152a:	fffff097          	auipc	ra,0xfffff
    8000152e:	650080e7          	jalr	1616(ra) # 80000b7a <kalloc>
    80001532:	84aa                	mv	s1,a0
    if(mem == 0){
    80001534:	c51d                	beqz	a0,80001562 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001536:	6605                	lui	a2,0x1
    80001538:	4581                	li	a1,0
    8000153a:	00000097          	auipc	ra,0x0
    8000153e:	852080e7          	jalr	-1966(ra) # 80000d8c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001542:	4779                	li	a4,30
    80001544:	86a6                	mv	a3,s1
    80001546:	6605                	lui	a2,0x1
    80001548:	85ca                	mv	a1,s2
    8000154a:	8556                	mv	a0,s5
    8000154c:	00000097          	auipc	ra,0x0
    80001550:	c6e080e7          	jalr	-914(ra) # 800011ba <mappages>
    80001554:	e905                	bnez	a0,80001584 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001556:	6785                	lui	a5,0x1
    80001558:	993e                	add	s2,s2,a5
    8000155a:	fd4968e3          	bltu	s2,s4,8000152a <uvmalloc+0x2c>
  return newsz;
    8000155e:	8552                	mv	a0,s4
    80001560:	a809                	j	80001572 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001562:	864e                	mv	a2,s3
    80001564:	85ca                	mv	a1,s2
    80001566:	8556                	mv	a0,s5
    80001568:	00000097          	auipc	ra,0x0
    8000156c:	f4e080e7          	jalr	-178(ra) # 800014b6 <uvmdealloc>
      return 0;
    80001570:	4501                	li	a0,0
}
    80001572:	70e2                	ld	ra,56(sp)
    80001574:	7442                	ld	s0,48(sp)
    80001576:	74a2                	ld	s1,40(sp)
    80001578:	7902                	ld	s2,32(sp)
    8000157a:	69e2                	ld	s3,24(sp)
    8000157c:	6a42                	ld	s4,16(sp)
    8000157e:	6aa2                	ld	s5,8(sp)
    80001580:	6121                	addi	sp,sp,64
    80001582:	8082                	ret
      kfree(mem);
    80001584:	8526                	mv	a0,s1
    80001586:	fffff097          	auipc	ra,0xfffff
    8000158a:	4f8080e7          	jalr	1272(ra) # 80000a7e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000158e:	864e                	mv	a2,s3
    80001590:	85ca                	mv	a1,s2
    80001592:	8556                	mv	a0,s5
    80001594:	00000097          	auipc	ra,0x0
    80001598:	f22080e7          	jalr	-222(ra) # 800014b6 <uvmdealloc>
      return 0;
    8000159c:	4501                	li	a0,0
    8000159e:	bfd1                	j	80001572 <uvmalloc+0x74>
    return oldsz;
    800015a0:	852e                	mv	a0,a1
}
    800015a2:	8082                	ret
  return newsz;
    800015a4:	8532                	mv	a0,a2
    800015a6:	b7f1                	j	80001572 <uvmalloc+0x74>

00000000800015a8 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800015a8:	7179                	addi	sp,sp,-48
    800015aa:	f406                	sd	ra,40(sp)
    800015ac:	f022                	sd	s0,32(sp)
    800015ae:	ec26                	sd	s1,24(sp)
    800015b0:	e84a                	sd	s2,16(sp)
    800015b2:	e44e                	sd	s3,8(sp)
    800015b4:	e052                	sd	s4,0(sp)
    800015b6:	1800                	addi	s0,sp,48
    800015b8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800015ba:	84aa                	mv	s1,a0
    800015bc:	6905                	lui	s2,0x1
    800015be:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015c0:	4985                	li	s3,1
    800015c2:	a821                	j	800015da <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015c4:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800015c6:	0532                	slli	a0,a0,0xc
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	fe0080e7          	jalr	-32(ra) # 800015a8 <freewalk>
      pagetable[i] = 0;
    800015d0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015d4:	04a1                	addi	s1,s1,8
    800015d6:	03248163          	beq	s1,s2,800015f8 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800015da:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015dc:	00f57793          	andi	a5,a0,15
    800015e0:	ff3782e3          	beq	a5,s3,800015c4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015e4:	8905                	andi	a0,a0,1
    800015e6:	d57d                	beqz	a0,800015d4 <freewalk+0x2c>
      panic("freewalk: leaf");
    800015e8:	00007517          	auipc	a0,0x7
    800015ec:	b9850513          	addi	a0,a0,-1128 # 80008180 <digits+0x128>
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	f52080e7          	jalr	-174(ra) # 80000542 <panic>
    }
  }
  kfree((void*)pagetable);
    800015f8:	8552                	mv	a0,s4
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	484080e7          	jalr	1156(ra) # 80000a7e <kfree>
}
    80001602:	70a2                	ld	ra,40(sp)
    80001604:	7402                	ld	s0,32(sp)
    80001606:	64e2                	ld	s1,24(sp)
    80001608:	6942                	ld	s2,16(sp)
    8000160a:	69a2                	ld	s3,8(sp)
    8000160c:	6a02                	ld	s4,0(sp)
    8000160e:	6145                	addi	sp,sp,48
    80001610:	8082                	ret

0000000080001612 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001612:	1101                	addi	sp,sp,-32
    80001614:	ec06                	sd	ra,24(sp)
    80001616:	e822                	sd	s0,16(sp)
    80001618:	e426                	sd	s1,8(sp)
    8000161a:	1000                	addi	s0,sp,32
    8000161c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000161e:	e999                	bnez	a1,80001634 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001620:	8526                	mv	a0,s1
    80001622:	00000097          	auipc	ra,0x0
    80001626:	f86080e7          	jalr	-122(ra) # 800015a8 <freewalk>
}
    8000162a:	60e2                	ld	ra,24(sp)
    8000162c:	6442                	ld	s0,16(sp)
    8000162e:	64a2                	ld	s1,8(sp)
    80001630:	6105                	addi	sp,sp,32
    80001632:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001634:	6605                	lui	a2,0x1
    80001636:	167d                	addi	a2,a2,-1
    80001638:	962e                	add	a2,a2,a1
    8000163a:	4685                	li	a3,1
    8000163c:	8231                	srli	a2,a2,0xc
    8000163e:	4581                	li	a1,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	d12080e7          	jalr	-750(ra) # 80001352 <uvmunmap>
    80001648:	bfe1                	j	80001620 <uvmfree+0xe>

000000008000164a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000164a:	c679                	beqz	a2,80001718 <uvmcopy+0xce>
{
    8000164c:	715d                	addi	sp,sp,-80
    8000164e:	e486                	sd	ra,72(sp)
    80001650:	e0a2                	sd	s0,64(sp)
    80001652:	fc26                	sd	s1,56(sp)
    80001654:	f84a                	sd	s2,48(sp)
    80001656:	f44e                	sd	s3,40(sp)
    80001658:	f052                	sd	s4,32(sp)
    8000165a:	ec56                	sd	s5,24(sp)
    8000165c:	e85a                	sd	s6,16(sp)
    8000165e:	e45e                	sd	s7,8(sp)
    80001660:	0880                	addi	s0,sp,80
    80001662:	8b2a                	mv	s6,a0
    80001664:	8aae                	mv	s5,a1
    80001666:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001668:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000166a:	4601                	li	a2,0
    8000166c:	85ce                	mv	a1,s3
    8000166e:	855a                	mv	a0,s6
    80001670:	00000097          	auipc	ra,0x0
    80001674:	a04080e7          	jalr	-1532(ra) # 80001074 <walk>
    80001678:	c531                	beqz	a0,800016c4 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000167a:	6118                	ld	a4,0(a0)
    8000167c:	00177793          	andi	a5,a4,1
    80001680:	cbb1                	beqz	a5,800016d4 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001682:	00a75593          	srli	a1,a4,0xa
    80001686:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000168a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000168e:	fffff097          	auipc	ra,0xfffff
    80001692:	4ec080e7          	jalr	1260(ra) # 80000b7a <kalloc>
    80001696:	892a                	mv	s2,a0
    80001698:	c939                	beqz	a0,800016ee <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000169a:	6605                	lui	a2,0x1
    8000169c:	85de                	mv	a1,s7
    8000169e:	fffff097          	auipc	ra,0xfffff
    800016a2:	74a080e7          	jalr	1866(ra) # 80000de8 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800016a6:	8726                	mv	a4,s1
    800016a8:	86ca                	mv	a3,s2
    800016aa:	6605                	lui	a2,0x1
    800016ac:	85ce                	mv	a1,s3
    800016ae:	8556                	mv	a0,s5
    800016b0:	00000097          	auipc	ra,0x0
    800016b4:	b0a080e7          	jalr	-1270(ra) # 800011ba <mappages>
    800016b8:	e515                	bnez	a0,800016e4 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800016ba:	6785                	lui	a5,0x1
    800016bc:	99be                	add	s3,s3,a5
    800016be:	fb49e6e3          	bltu	s3,s4,8000166a <uvmcopy+0x20>
    800016c2:	a081                	j	80001702 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800016c4:	00007517          	auipc	a0,0x7
    800016c8:	acc50513          	addi	a0,a0,-1332 # 80008190 <digits+0x138>
    800016cc:	fffff097          	auipc	ra,0xfffff
    800016d0:	e76080e7          	jalr	-394(ra) # 80000542 <panic>
      panic("uvmcopy: page not present");
    800016d4:	00007517          	auipc	a0,0x7
    800016d8:	adc50513          	addi	a0,a0,-1316 # 800081b0 <digits+0x158>
    800016dc:	fffff097          	auipc	ra,0xfffff
    800016e0:	e66080e7          	jalr	-410(ra) # 80000542 <panic>
      kfree(mem);
    800016e4:	854a                	mv	a0,s2
    800016e6:	fffff097          	auipc	ra,0xfffff
    800016ea:	398080e7          	jalr	920(ra) # 80000a7e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016ee:	4685                	li	a3,1
    800016f0:	00c9d613          	srli	a2,s3,0xc
    800016f4:	4581                	li	a1,0
    800016f6:	8556                	mv	a0,s5
    800016f8:	00000097          	auipc	ra,0x0
    800016fc:	c5a080e7          	jalr	-934(ra) # 80001352 <uvmunmap>
  return -1;
    80001700:	557d                	li	a0,-1
}
    80001702:	60a6                	ld	ra,72(sp)
    80001704:	6406                	ld	s0,64(sp)
    80001706:	74e2                	ld	s1,56(sp)
    80001708:	7942                	ld	s2,48(sp)
    8000170a:	79a2                	ld	s3,40(sp)
    8000170c:	7a02                	ld	s4,32(sp)
    8000170e:	6ae2                	ld	s5,24(sp)
    80001710:	6b42                	ld	s6,16(sp)
    80001712:	6ba2                	ld	s7,8(sp)
    80001714:	6161                	addi	sp,sp,80
    80001716:	8082                	ret
  return 0;
    80001718:	4501                	li	a0,0
}
    8000171a:	8082                	ret

000000008000171c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000171c:	1141                	addi	sp,sp,-16
    8000171e:	e406                	sd	ra,8(sp)
    80001720:	e022                	sd	s0,0(sp)
    80001722:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001724:	4601                	li	a2,0
    80001726:	00000097          	auipc	ra,0x0
    8000172a:	94e080e7          	jalr	-1714(ra) # 80001074 <walk>
  if(pte == 0)
    8000172e:	c901                	beqz	a0,8000173e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001730:	611c                	ld	a5,0(a0)
    80001732:	9bbd                	andi	a5,a5,-17
    80001734:	e11c                	sd	a5,0(a0)
}
    80001736:	60a2                	ld	ra,8(sp)
    80001738:	6402                	ld	s0,0(sp)
    8000173a:	0141                	addi	sp,sp,16
    8000173c:	8082                	ret
    panic("uvmclear");
    8000173e:	00007517          	auipc	a0,0x7
    80001742:	a9250513          	addi	a0,a0,-1390 # 800081d0 <digits+0x178>
    80001746:	fffff097          	auipc	ra,0xfffff
    8000174a:	dfc080e7          	jalr	-516(ra) # 80000542 <panic>

000000008000174e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000174e:	c6bd                	beqz	a3,800017bc <copyout+0x6e>
{
    80001750:	715d                	addi	sp,sp,-80
    80001752:	e486                	sd	ra,72(sp)
    80001754:	e0a2                	sd	s0,64(sp)
    80001756:	fc26                	sd	s1,56(sp)
    80001758:	f84a                	sd	s2,48(sp)
    8000175a:	f44e                	sd	s3,40(sp)
    8000175c:	f052                	sd	s4,32(sp)
    8000175e:	ec56                	sd	s5,24(sp)
    80001760:	e85a                	sd	s6,16(sp)
    80001762:	e45e                	sd	s7,8(sp)
    80001764:	e062                	sd	s8,0(sp)
    80001766:	0880                	addi	s0,sp,80
    80001768:	8b2a                	mv	s6,a0
    8000176a:	8c2e                	mv	s8,a1
    8000176c:	8a32                	mv	s4,a2
    8000176e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001770:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001772:	6a85                	lui	s5,0x1
    80001774:	a015                	j	80001798 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001776:	9562                	add	a0,a0,s8
    80001778:	0004861b          	sext.w	a2,s1
    8000177c:	85d2                	mv	a1,s4
    8000177e:	41250533          	sub	a0,a0,s2
    80001782:	fffff097          	auipc	ra,0xfffff
    80001786:	666080e7          	jalr	1638(ra) # 80000de8 <memmove>

    len -= n;
    8000178a:	409989b3          	sub	s3,s3,s1
    src += n;
    8000178e:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001790:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001794:	02098263          	beqz	s3,800017b8 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001798:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000179c:	85ca                	mv	a1,s2
    8000179e:	855a                	mv	a0,s6
    800017a0:	00000097          	auipc	ra,0x0
    800017a4:	97a080e7          	jalr	-1670(ra) # 8000111a <walkaddr>
    if(pa0 == 0)
    800017a8:	cd01                	beqz	a0,800017c0 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800017aa:	418904b3          	sub	s1,s2,s8
    800017ae:	94d6                	add	s1,s1,s5
    if(n > len)
    800017b0:	fc99f3e3          	bgeu	s3,s1,80001776 <copyout+0x28>
    800017b4:	84ce                	mv	s1,s3
    800017b6:	b7c1                	j	80001776 <copyout+0x28>
  }
  return 0;
    800017b8:	4501                	li	a0,0
    800017ba:	a021                	j	800017c2 <copyout+0x74>
    800017bc:	4501                	li	a0,0
}
    800017be:	8082                	ret
      return -1;
    800017c0:	557d                	li	a0,-1
}
    800017c2:	60a6                	ld	ra,72(sp)
    800017c4:	6406                	ld	s0,64(sp)
    800017c6:	74e2                	ld	s1,56(sp)
    800017c8:	7942                	ld	s2,48(sp)
    800017ca:	79a2                	ld	s3,40(sp)
    800017cc:	7a02                	ld	s4,32(sp)
    800017ce:	6ae2                	ld	s5,24(sp)
    800017d0:	6b42                	ld	s6,16(sp)
    800017d2:	6ba2                	ld	s7,8(sp)
    800017d4:	6c02                	ld	s8,0(sp)
    800017d6:	6161                	addi	sp,sp,80
    800017d8:	8082                	ret

00000000800017da <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017da:	caa5                	beqz	a3,8000184a <copyin+0x70>
{
    800017dc:	715d                	addi	sp,sp,-80
    800017de:	e486                	sd	ra,72(sp)
    800017e0:	e0a2                	sd	s0,64(sp)
    800017e2:	fc26                	sd	s1,56(sp)
    800017e4:	f84a                	sd	s2,48(sp)
    800017e6:	f44e                	sd	s3,40(sp)
    800017e8:	f052                	sd	s4,32(sp)
    800017ea:	ec56                	sd	s5,24(sp)
    800017ec:	e85a                	sd	s6,16(sp)
    800017ee:	e45e                	sd	s7,8(sp)
    800017f0:	e062                	sd	s8,0(sp)
    800017f2:	0880                	addi	s0,sp,80
    800017f4:	8b2a                	mv	s6,a0
    800017f6:	8a2e                	mv	s4,a1
    800017f8:	8c32                	mv	s8,a2
    800017fa:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017fc:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017fe:	6a85                	lui	s5,0x1
    80001800:	a01d                	j	80001826 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001802:	018505b3          	add	a1,a0,s8
    80001806:	0004861b          	sext.w	a2,s1
    8000180a:	412585b3          	sub	a1,a1,s2
    8000180e:	8552                	mv	a0,s4
    80001810:	fffff097          	auipc	ra,0xfffff
    80001814:	5d8080e7          	jalr	1496(ra) # 80000de8 <memmove>

    len -= n;
    80001818:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000181c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000181e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001822:	02098263          	beqz	s3,80001846 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001826:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000182a:	85ca                	mv	a1,s2
    8000182c:	855a                	mv	a0,s6
    8000182e:	00000097          	auipc	ra,0x0
    80001832:	8ec080e7          	jalr	-1812(ra) # 8000111a <walkaddr>
    if(pa0 == 0)
    80001836:	cd01                	beqz	a0,8000184e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001838:	418904b3          	sub	s1,s2,s8
    8000183c:	94d6                	add	s1,s1,s5
    if(n > len)
    8000183e:	fc99f2e3          	bgeu	s3,s1,80001802 <copyin+0x28>
    80001842:	84ce                	mv	s1,s3
    80001844:	bf7d                	j	80001802 <copyin+0x28>
  }
  return 0;
    80001846:	4501                	li	a0,0
    80001848:	a021                	j	80001850 <copyin+0x76>
    8000184a:	4501                	li	a0,0
}
    8000184c:	8082                	ret
      return -1;
    8000184e:	557d                	li	a0,-1
}
    80001850:	60a6                	ld	ra,72(sp)
    80001852:	6406                	ld	s0,64(sp)
    80001854:	74e2                	ld	s1,56(sp)
    80001856:	7942                	ld	s2,48(sp)
    80001858:	79a2                	ld	s3,40(sp)
    8000185a:	7a02                	ld	s4,32(sp)
    8000185c:	6ae2                	ld	s5,24(sp)
    8000185e:	6b42                	ld	s6,16(sp)
    80001860:	6ba2                	ld	s7,8(sp)
    80001862:	6c02                	ld	s8,0(sp)
    80001864:	6161                	addi	sp,sp,80
    80001866:	8082                	ret

0000000080001868 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001868:	c6c5                	beqz	a3,80001910 <copyinstr+0xa8>
{
    8000186a:	715d                	addi	sp,sp,-80
    8000186c:	e486                	sd	ra,72(sp)
    8000186e:	e0a2                	sd	s0,64(sp)
    80001870:	fc26                	sd	s1,56(sp)
    80001872:	f84a                	sd	s2,48(sp)
    80001874:	f44e                	sd	s3,40(sp)
    80001876:	f052                	sd	s4,32(sp)
    80001878:	ec56                	sd	s5,24(sp)
    8000187a:	e85a                	sd	s6,16(sp)
    8000187c:	e45e                	sd	s7,8(sp)
    8000187e:	0880                	addi	s0,sp,80
    80001880:	8a2a                	mv	s4,a0
    80001882:	8b2e                	mv	s6,a1
    80001884:	8bb2                	mv	s7,a2
    80001886:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001888:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000188a:	6985                	lui	s3,0x1
    8000188c:	a035                	j	800018b8 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000188e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001892:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001894:	0017b793          	seqz	a5,a5
    80001898:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000189c:	60a6                	ld	ra,72(sp)
    8000189e:	6406                	ld	s0,64(sp)
    800018a0:	74e2                	ld	s1,56(sp)
    800018a2:	7942                	ld	s2,48(sp)
    800018a4:	79a2                	ld	s3,40(sp)
    800018a6:	7a02                	ld	s4,32(sp)
    800018a8:	6ae2                	ld	s5,24(sp)
    800018aa:	6b42                	ld	s6,16(sp)
    800018ac:	6ba2                	ld	s7,8(sp)
    800018ae:	6161                	addi	sp,sp,80
    800018b0:	8082                	ret
    srcva = va0 + PGSIZE;
    800018b2:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800018b6:	c8a9                	beqz	s1,80001908 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800018b8:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800018bc:	85ca                	mv	a1,s2
    800018be:	8552                	mv	a0,s4
    800018c0:	00000097          	auipc	ra,0x0
    800018c4:	85a080e7          	jalr	-1958(ra) # 8000111a <walkaddr>
    if(pa0 == 0)
    800018c8:	c131                	beqz	a0,8000190c <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800018ca:	41790833          	sub	a6,s2,s7
    800018ce:	984e                	add	a6,a6,s3
    if(n > max)
    800018d0:	0104f363          	bgeu	s1,a6,800018d6 <copyinstr+0x6e>
    800018d4:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018d6:	955e                	add	a0,a0,s7
    800018d8:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018dc:	fc080be3          	beqz	a6,800018b2 <copyinstr+0x4a>
    800018e0:	985a                	add	a6,a6,s6
    800018e2:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018e4:	41650633          	sub	a2,a0,s6
    800018e8:	14fd                	addi	s1,s1,-1
    800018ea:	9b26                	add	s6,s6,s1
    800018ec:	00f60733          	add	a4,a2,a5
    800018f0:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd8000>
    800018f4:	df49                	beqz	a4,8000188e <copyinstr+0x26>
        *dst = *p;
    800018f6:	00e78023          	sb	a4,0(a5)
      --max;
    800018fa:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800018fe:	0785                	addi	a5,a5,1
    while(n > 0){
    80001900:	ff0796e3          	bne	a5,a6,800018ec <copyinstr+0x84>
      dst++;
    80001904:	8b42                	mv	s6,a6
    80001906:	b775                	j	800018b2 <copyinstr+0x4a>
    80001908:	4781                	li	a5,0
    8000190a:	b769                	j	80001894 <copyinstr+0x2c>
      return -1;
    8000190c:	557d                	li	a0,-1
    8000190e:	b779                	j	8000189c <copyinstr+0x34>
  int got_null = 0;
    80001910:	4781                	li	a5,0
  if(got_null){
    80001912:	0017b793          	seqz	a5,a5
    80001916:	40f00533          	neg	a0,a5
}
    8000191a:	8082                	ret

000000008000191c <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    8000191c:	1101                	addi	sp,sp,-32
    8000191e:	ec06                	sd	ra,24(sp)
    80001920:	e822                	sd	s0,16(sp)
    80001922:	e426                	sd	s1,8(sp)
    80001924:	1000                	addi	s0,sp,32
    80001926:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001928:	fffff097          	auipc	ra,0xfffff
    8000192c:	2ee080e7          	jalr	750(ra) # 80000c16 <holding>
    80001930:	c909                	beqz	a0,80001942 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001932:	749c                	ld	a5,40(s1)
    80001934:	00978f63          	beq	a5,s1,80001952 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001938:	60e2                	ld	ra,24(sp)
    8000193a:	6442                	ld	s0,16(sp)
    8000193c:	64a2                	ld	s1,8(sp)
    8000193e:	6105                	addi	sp,sp,32
    80001940:	8082                	ret
    panic("wakeup1");
    80001942:	00007517          	auipc	a0,0x7
    80001946:	89e50513          	addi	a0,a0,-1890 # 800081e0 <digits+0x188>
    8000194a:	fffff097          	auipc	ra,0xfffff
    8000194e:	bf8080e7          	jalr	-1032(ra) # 80000542 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001952:	4c98                	lw	a4,24(s1)
    80001954:	4785                	li	a5,1
    80001956:	fef711e3          	bne	a4,a5,80001938 <wakeup1+0x1c>
    p->state = RUNNABLE;
    8000195a:	4789                	li	a5,2
    8000195c:	cc9c                	sw	a5,24(s1)
}
    8000195e:	bfe9                	j	80001938 <wakeup1+0x1c>

0000000080001960 <procinit>:
{
    80001960:	715d                	addi	sp,sp,-80
    80001962:	e486                	sd	ra,72(sp)
    80001964:	e0a2                	sd	s0,64(sp)
    80001966:	fc26                	sd	s1,56(sp)
    80001968:	f84a                	sd	s2,48(sp)
    8000196a:	f44e                	sd	s3,40(sp)
    8000196c:	f052                	sd	s4,32(sp)
    8000196e:	ec56                	sd	s5,24(sp)
    80001970:	e85a                	sd	s6,16(sp)
    80001972:	e45e                	sd	s7,8(sp)
    80001974:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001976:	00007597          	auipc	a1,0x7
    8000197a:	87258593          	addi	a1,a1,-1934 # 800081e8 <digits+0x190>
    8000197e:	00010517          	auipc	a0,0x10
    80001982:	fd250513          	addi	a0,a0,-46 # 80011950 <pid_lock>
    80001986:	fffff097          	auipc	ra,0xfffff
    8000198a:	27a080e7          	jalr	634(ra) # 80000c00 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000198e:	00010917          	auipc	s2,0x10
    80001992:	3da90913          	addi	s2,s2,986 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001996:	00007b97          	auipc	s7,0x7
    8000199a:	85ab8b93          	addi	s7,s7,-1958 # 800081f0 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    8000199e:	8b4a                	mv	s6,s2
    800019a0:	00006a97          	auipc	s5,0x6
    800019a4:	660a8a93          	addi	s5,s5,1632 # 80008000 <etext>
    800019a8:	040009b7          	lui	s3,0x4000
    800019ac:	19fd                	addi	s3,s3,-1
    800019ae:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b0:	00017a17          	auipc	s4,0x17
    800019b4:	db8a0a13          	addi	s4,s4,-584 # 80018768 <tickslock>
      initlock(&p->lock, "proc");
    800019b8:	85de                	mv	a1,s7
    800019ba:	854a                	mv	a0,s2
    800019bc:	fffff097          	auipc	ra,0xfffff
    800019c0:	244080e7          	jalr	580(ra) # 80000c00 <initlock>
      char *pa = kalloc();
    800019c4:	fffff097          	auipc	ra,0xfffff
    800019c8:	1b6080e7          	jalr	438(ra) # 80000b7a <kalloc>
    800019cc:	85aa                	mv	a1,a0
      if(pa == 0)
    800019ce:	c929                	beqz	a0,80001a20 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800019d0:	416904b3          	sub	s1,s2,s6
    800019d4:	848d                	srai	s1,s1,0x3
    800019d6:	000ab783          	ld	a5,0(s5)
    800019da:	02f484b3          	mul	s1,s1,a5
    800019de:	2485                	addiw	s1,s1,1
    800019e0:	00d4949b          	slliw	s1,s1,0xd
    800019e4:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019e8:	4699                	li	a3,6
    800019ea:	6605                	lui	a2,0x1
    800019ec:	8526                	mv	a0,s1
    800019ee:	00000097          	auipc	ra,0x0
    800019f2:	85a080e7          	jalr	-1958(ra) # 80001248 <kvmmap>
      p->kstack = va;
    800019f6:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019fa:	1a890913          	addi	s2,s2,424
    800019fe:	fb491de3          	bne	s2,s4,800019b8 <procinit+0x58>
  kvminithart();
    80001a02:	fffff097          	auipc	ra,0xfffff
    80001a06:	64e080e7          	jalr	1614(ra) # 80001050 <kvminithart>
}
    80001a0a:	60a6                	ld	ra,72(sp)
    80001a0c:	6406                	ld	s0,64(sp)
    80001a0e:	74e2                	ld	s1,56(sp)
    80001a10:	7942                	ld	s2,48(sp)
    80001a12:	79a2                	ld	s3,40(sp)
    80001a14:	7a02                	ld	s4,32(sp)
    80001a16:	6ae2                	ld	s5,24(sp)
    80001a18:	6b42                	ld	s6,16(sp)
    80001a1a:	6ba2                	ld	s7,8(sp)
    80001a1c:	6161                	addi	sp,sp,80
    80001a1e:	8082                	ret
        panic("kalloc");
    80001a20:	00006517          	auipc	a0,0x6
    80001a24:	7d850513          	addi	a0,a0,2008 # 800081f8 <digits+0x1a0>
    80001a28:	fffff097          	auipc	ra,0xfffff
    80001a2c:	b1a080e7          	jalr	-1254(ra) # 80000542 <panic>

0000000080001a30 <cpuid>:
{
    80001a30:	1141                	addi	sp,sp,-16
    80001a32:	e422                	sd	s0,8(sp)
    80001a34:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a36:	8512                	mv	a0,tp
}
    80001a38:	2501                	sext.w	a0,a0
    80001a3a:	6422                	ld	s0,8(sp)
    80001a3c:	0141                	addi	sp,sp,16
    80001a3e:	8082                	ret

0000000080001a40 <mycpu>:
mycpu(void) {
    80001a40:	1141                	addi	sp,sp,-16
    80001a42:	e422                	sd	s0,8(sp)
    80001a44:	0800                	addi	s0,sp,16
    80001a46:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a48:	2781                	sext.w	a5,a5
    80001a4a:	079e                	slli	a5,a5,0x7
}
    80001a4c:	00010517          	auipc	a0,0x10
    80001a50:	f1c50513          	addi	a0,a0,-228 # 80011968 <cpus>
    80001a54:	953e                	add	a0,a0,a5
    80001a56:	6422                	ld	s0,8(sp)
    80001a58:	0141                	addi	sp,sp,16
    80001a5a:	8082                	ret

0000000080001a5c <myproc>:
myproc(void) {
    80001a5c:	1101                	addi	sp,sp,-32
    80001a5e:	ec06                	sd	ra,24(sp)
    80001a60:	e822                	sd	s0,16(sp)
    80001a62:	e426                	sd	s1,8(sp)
    80001a64:	1000                	addi	s0,sp,32
  push_off();
    80001a66:	fffff097          	auipc	ra,0xfffff
    80001a6a:	1de080e7          	jalr	478(ra) # 80000c44 <push_off>
    80001a6e:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a70:	2781                	sext.w	a5,a5
    80001a72:	079e                	slli	a5,a5,0x7
    80001a74:	00010717          	auipc	a4,0x10
    80001a78:	edc70713          	addi	a4,a4,-292 # 80011950 <pid_lock>
    80001a7c:	97ba                	add	a5,a5,a4
    80001a7e:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a80:	fffff097          	auipc	ra,0xfffff
    80001a84:	264080e7          	jalr	612(ra) # 80000ce4 <pop_off>
}
    80001a88:	8526                	mv	a0,s1
    80001a8a:	60e2                	ld	ra,24(sp)
    80001a8c:	6442                	ld	s0,16(sp)
    80001a8e:	64a2                	ld	s1,8(sp)
    80001a90:	6105                	addi	sp,sp,32
    80001a92:	8082                	ret

0000000080001a94 <forkret>:
{
    80001a94:	1141                	addi	sp,sp,-16
    80001a96:	e406                	sd	ra,8(sp)
    80001a98:	e022                	sd	s0,0(sp)
    80001a9a:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a9c:	00000097          	auipc	ra,0x0
    80001aa0:	fc0080e7          	jalr	-64(ra) # 80001a5c <myproc>
    80001aa4:	fffff097          	auipc	ra,0xfffff
    80001aa8:	2a0080e7          	jalr	672(ra) # 80000d44 <release>
  if (first) {
    80001aac:	00007797          	auipc	a5,0x7
    80001ab0:	f247a783          	lw	a5,-220(a5) # 800089d0 <first.1>
    80001ab4:	eb89                	bnez	a5,80001ac6 <forkret+0x32>
  usertrapret();
    80001ab6:	00001097          	auipc	ra,0x1
    80001aba:	c56080e7          	jalr	-938(ra) # 8000270c <usertrapret>
}
    80001abe:	60a2                	ld	ra,8(sp)
    80001ac0:	6402                	ld	s0,0(sp)
    80001ac2:	0141                	addi	sp,sp,16
    80001ac4:	8082                	ret
    first = 0;
    80001ac6:	00007797          	auipc	a5,0x7
    80001aca:	f007a523          	sw	zero,-246(a5) # 800089d0 <first.1>
    fsinit(ROOTDEV);
    80001ace:	4505                	li	a0,1
    80001ad0:	00002097          	auipc	ra,0x2
    80001ad4:	c30080e7          	jalr	-976(ra) # 80003700 <fsinit>
    80001ad8:	bff9                	j	80001ab6 <forkret+0x22>

0000000080001ada <allocpid>:
allocpid() {
    80001ada:	1101                	addi	sp,sp,-32
    80001adc:	ec06                	sd	ra,24(sp)
    80001ade:	e822                	sd	s0,16(sp)
    80001ae0:	e426                	sd	s1,8(sp)
    80001ae2:	e04a                	sd	s2,0(sp)
    80001ae4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ae6:	00010917          	auipc	s2,0x10
    80001aea:	e6a90913          	addi	s2,s2,-406 # 80011950 <pid_lock>
    80001aee:	854a                	mv	a0,s2
    80001af0:	fffff097          	auipc	ra,0xfffff
    80001af4:	1a0080e7          	jalr	416(ra) # 80000c90 <acquire>
  pid = nextpid;
    80001af8:	00007797          	auipc	a5,0x7
    80001afc:	edc78793          	addi	a5,a5,-292 # 800089d4 <nextpid>
    80001b00:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b02:	0014871b          	addiw	a4,s1,1
    80001b06:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b08:	854a                	mv	a0,s2
    80001b0a:	fffff097          	auipc	ra,0xfffff
    80001b0e:	23a080e7          	jalr	570(ra) # 80000d44 <release>
}
    80001b12:	8526                	mv	a0,s1
    80001b14:	60e2                	ld	ra,24(sp)
    80001b16:	6442                	ld	s0,16(sp)
    80001b18:	64a2                	ld	s1,8(sp)
    80001b1a:	6902                	ld	s2,0(sp)
    80001b1c:	6105                	addi	sp,sp,32
    80001b1e:	8082                	ret

0000000080001b20 <proc_pagetable>:
{
    80001b20:	1101                	addi	sp,sp,-32
    80001b22:	ec06                	sd	ra,24(sp)
    80001b24:	e822                	sd	s0,16(sp)
    80001b26:	e426                	sd	s1,8(sp)
    80001b28:	e04a                	sd	s2,0(sp)
    80001b2a:	1000                	addi	s0,sp,32
    80001b2c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b2e:	00000097          	auipc	ra,0x0
    80001b32:	8e8080e7          	jalr	-1816(ra) # 80001416 <uvmcreate>
    80001b36:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b38:	c121                	beqz	a0,80001b78 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b3a:	4729                	li	a4,10
    80001b3c:	00005697          	auipc	a3,0x5
    80001b40:	4c468693          	addi	a3,a3,1220 # 80007000 <_trampoline>
    80001b44:	6605                	lui	a2,0x1
    80001b46:	040005b7          	lui	a1,0x4000
    80001b4a:	15fd                	addi	a1,a1,-1
    80001b4c:	05b2                	slli	a1,a1,0xc
    80001b4e:	fffff097          	auipc	ra,0xfffff
    80001b52:	66c080e7          	jalr	1644(ra) # 800011ba <mappages>
    80001b56:	02054863          	bltz	a0,80001b86 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b5a:	4719                	li	a4,6
    80001b5c:	05893683          	ld	a3,88(s2)
    80001b60:	6605                	lui	a2,0x1
    80001b62:	020005b7          	lui	a1,0x2000
    80001b66:	15fd                	addi	a1,a1,-1
    80001b68:	05b6                	slli	a1,a1,0xd
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	fffff097          	auipc	ra,0xfffff
    80001b70:	64e080e7          	jalr	1614(ra) # 800011ba <mappages>
    80001b74:	02054163          	bltz	a0,80001b96 <proc_pagetable+0x76>
}
    80001b78:	8526                	mv	a0,s1
    80001b7a:	60e2                	ld	ra,24(sp)
    80001b7c:	6442                	ld	s0,16(sp)
    80001b7e:	64a2                	ld	s1,8(sp)
    80001b80:	6902                	ld	s2,0(sp)
    80001b82:	6105                	addi	sp,sp,32
    80001b84:	8082                	ret
    uvmfree(pagetable, 0);
    80001b86:	4581                	li	a1,0
    80001b88:	8526                	mv	a0,s1
    80001b8a:	00000097          	auipc	ra,0x0
    80001b8e:	a88080e7          	jalr	-1400(ra) # 80001612 <uvmfree>
    return 0;
    80001b92:	4481                	li	s1,0
    80001b94:	b7d5                	j	80001b78 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b96:	4681                	li	a3,0
    80001b98:	4605                	li	a2,1
    80001b9a:	040005b7          	lui	a1,0x4000
    80001b9e:	15fd                	addi	a1,a1,-1
    80001ba0:	05b2                	slli	a1,a1,0xc
    80001ba2:	8526                	mv	a0,s1
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	7ae080e7          	jalr	1966(ra) # 80001352 <uvmunmap>
    uvmfree(pagetable, 0);
    80001bac:	4581                	li	a1,0
    80001bae:	8526                	mv	a0,s1
    80001bb0:	00000097          	auipc	ra,0x0
    80001bb4:	a62080e7          	jalr	-1438(ra) # 80001612 <uvmfree>
    return 0;
    80001bb8:	4481                	li	s1,0
    80001bba:	bf7d                	j	80001b78 <proc_pagetable+0x58>

0000000080001bbc <proc_freepagetable>:
{
    80001bbc:	1101                	addi	sp,sp,-32
    80001bbe:	ec06                	sd	ra,24(sp)
    80001bc0:	e822                	sd	s0,16(sp)
    80001bc2:	e426                	sd	s1,8(sp)
    80001bc4:	e04a                	sd	s2,0(sp)
    80001bc6:	1000                	addi	s0,sp,32
    80001bc8:	84aa                	mv	s1,a0
    80001bca:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bcc:	4681                	li	a3,0
    80001bce:	4605                	li	a2,1
    80001bd0:	040005b7          	lui	a1,0x4000
    80001bd4:	15fd                	addi	a1,a1,-1
    80001bd6:	05b2                	slli	a1,a1,0xc
    80001bd8:	fffff097          	auipc	ra,0xfffff
    80001bdc:	77a080e7          	jalr	1914(ra) # 80001352 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001be0:	4681                	li	a3,0
    80001be2:	4605                	li	a2,1
    80001be4:	020005b7          	lui	a1,0x2000
    80001be8:	15fd                	addi	a1,a1,-1
    80001bea:	05b6                	slli	a1,a1,0xd
    80001bec:	8526                	mv	a0,s1
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	764080e7          	jalr	1892(ra) # 80001352 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bf6:	85ca                	mv	a1,s2
    80001bf8:	8526                	mv	a0,s1
    80001bfa:	00000097          	auipc	ra,0x0
    80001bfe:	a18080e7          	jalr	-1512(ra) # 80001612 <uvmfree>
}
    80001c02:	60e2                	ld	ra,24(sp)
    80001c04:	6442                	ld	s0,16(sp)
    80001c06:	64a2                	ld	s1,8(sp)
    80001c08:	6902                	ld	s2,0(sp)
    80001c0a:	6105                	addi	sp,sp,32
    80001c0c:	8082                	ret

0000000080001c0e <freeproc>:
{
    80001c0e:	1101                	addi	sp,sp,-32
    80001c10:	ec06                	sd	ra,24(sp)
    80001c12:	e822                	sd	s0,16(sp)
    80001c14:	e426                	sd	s1,8(sp)
    80001c16:	1000                	addi	s0,sp,32
    80001c18:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c1a:	6d28                	ld	a0,88(a0)
    80001c1c:	c509                	beqz	a0,80001c26 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c1e:	fffff097          	auipc	ra,0xfffff
    80001c22:	e60080e7          	jalr	-416(ra) # 80000a7e <kfree>
  p->trapframe = 0;
    80001c26:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c2a:	68a8                	ld	a0,80(s1)
    80001c2c:	c511                	beqz	a0,80001c38 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c2e:	64ac                	ld	a1,72(s1)
    80001c30:	00000097          	auipc	ra,0x0
    80001c34:	f8c080e7          	jalr	-116(ra) # 80001bbc <proc_freepagetable>
  p->pagetable = 0;
    80001c38:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c3c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c40:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c44:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c48:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c4c:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c50:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c54:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c58:	0004ac23          	sw	zero,24(s1)
}
    80001c5c:	60e2                	ld	ra,24(sp)
    80001c5e:	6442                	ld	s0,16(sp)
    80001c60:	64a2                	ld	s1,8(sp)
    80001c62:	6105                	addi	sp,sp,32
    80001c64:	8082                	ret

0000000080001c66 <allocproc>:
{
    80001c66:	1101                	addi	sp,sp,-32
    80001c68:	ec06                	sd	ra,24(sp)
    80001c6a:	e822                	sd	s0,16(sp)
    80001c6c:	e426                	sd	s1,8(sp)
    80001c6e:	e04a                	sd	s2,0(sp)
    80001c70:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c72:	00010497          	auipc	s1,0x10
    80001c76:	0f648493          	addi	s1,s1,246 # 80011d68 <proc>
    80001c7a:	00017917          	auipc	s2,0x17
    80001c7e:	aee90913          	addi	s2,s2,-1298 # 80018768 <tickslock>
    acquire(&p->lock);
    80001c82:	8526                	mv	a0,s1
    80001c84:	fffff097          	auipc	ra,0xfffff
    80001c88:	00c080e7          	jalr	12(ra) # 80000c90 <acquire>
    if(p->state == UNUSED) {
    80001c8c:	4c9c                	lw	a5,24(s1)
    80001c8e:	cf81                	beqz	a5,80001ca6 <allocproc+0x40>
      release(&p->lock);
    80001c90:	8526                	mv	a0,s1
    80001c92:	fffff097          	auipc	ra,0xfffff
    80001c96:	0b2080e7          	jalr	178(ra) # 80000d44 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c9a:	1a848493          	addi	s1,s1,424
    80001c9e:	ff2492e3          	bne	s1,s2,80001c82 <allocproc+0x1c>
  return 0;
    80001ca2:	4481                	li	s1,0
    80001ca4:	a0b9                	j	80001cf2 <allocproc+0x8c>
  p->pid = allocpid();
    80001ca6:	00000097          	auipc	ra,0x0
    80001caa:	e34080e7          	jalr	-460(ra) # 80001ada <allocpid>
    80001cae:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cb0:	fffff097          	auipc	ra,0xfffff
    80001cb4:	eca080e7          	jalr	-310(ra) # 80000b7a <kalloc>
    80001cb8:	892a                	mv	s2,a0
    80001cba:	eca8                	sd	a0,88(s1)
    80001cbc:	c131                	beqz	a0,80001d00 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001cbe:	8526                	mv	a0,s1
    80001cc0:	00000097          	auipc	ra,0x0
    80001cc4:	e60080e7          	jalr	-416(ra) # 80001b20 <proc_pagetable>
    80001cc8:	892a                	mv	s2,a0
    80001cca:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001ccc:	c129                	beqz	a0,80001d0e <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001cce:	07000613          	li	a2,112
    80001cd2:	4581                	li	a1,0
    80001cd4:	06048513          	addi	a0,s1,96
    80001cd8:	fffff097          	auipc	ra,0xfffff
    80001cdc:	0b4080e7          	jalr	180(ra) # 80000d8c <memset>
  p->context.ra = (uint64)forkret;
    80001ce0:	00000797          	auipc	a5,0x0
    80001ce4:	db478793          	addi	a5,a5,-588 # 80001a94 <forkret>
    80001ce8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cea:	60bc                	ld	a5,64(s1)
    80001cec:	6705                	lui	a4,0x1
    80001cee:	97ba                	add	a5,a5,a4
    80001cf0:	f4bc                	sd	a5,104(s1)
}
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	60e2                	ld	ra,24(sp)
    80001cf6:	6442                	ld	s0,16(sp)
    80001cf8:	64a2                	ld	s1,8(sp)
    80001cfa:	6902                	ld	s2,0(sp)
    80001cfc:	6105                	addi	sp,sp,32
    80001cfe:	8082                	ret
    release(&p->lock);
    80001d00:	8526                	mv	a0,s1
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	042080e7          	jalr	66(ra) # 80000d44 <release>
    return 0;
    80001d0a:	84ca                	mv	s1,s2
    80001d0c:	b7dd                	j	80001cf2 <allocproc+0x8c>
    freeproc(p);
    80001d0e:	8526                	mv	a0,s1
    80001d10:	00000097          	auipc	ra,0x0
    80001d14:	efe080e7          	jalr	-258(ra) # 80001c0e <freeproc>
    release(&p->lock);
    80001d18:	8526                	mv	a0,s1
    80001d1a:	fffff097          	auipc	ra,0xfffff
    80001d1e:	02a080e7          	jalr	42(ra) # 80000d44 <release>
    return 0;
    80001d22:	84ca                	mv	s1,s2
    80001d24:	b7f9                	j	80001cf2 <allocproc+0x8c>

0000000080001d26 <userinit>:
{
    80001d26:	1101                	addi	sp,sp,-32
    80001d28:	ec06                	sd	ra,24(sp)
    80001d2a:	e822                	sd	s0,16(sp)
    80001d2c:	e426                	sd	s1,8(sp)
    80001d2e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d30:	00000097          	auipc	ra,0x0
    80001d34:	f36080e7          	jalr	-202(ra) # 80001c66 <allocproc>
    80001d38:	84aa                	mv	s1,a0
  initproc = p;
    80001d3a:	00007797          	auipc	a5,0x7
    80001d3e:	2ca7bf23          	sd	a0,734(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d42:	03400613          	li	a2,52
    80001d46:	00007597          	auipc	a1,0x7
    80001d4a:	c9a58593          	addi	a1,a1,-870 # 800089e0 <initcode>
    80001d4e:	6928                	ld	a0,80(a0)
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	6f4080e7          	jalr	1780(ra) # 80001444 <uvminit>
  p->sz = PGSIZE;
    80001d58:	6785                	lui	a5,0x1
    80001d5a:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d5c:	6cb8                	ld	a4,88(s1)
    80001d5e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d62:	6cb8                	ld	a4,88(s1)
    80001d64:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d66:	4641                	li	a2,16
    80001d68:	00006597          	auipc	a1,0x6
    80001d6c:	49858593          	addi	a1,a1,1176 # 80008200 <digits+0x1a8>
    80001d70:	15848513          	addi	a0,s1,344
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	16a080e7          	jalr	362(ra) # 80000ede <safestrcpy>
  p->cwd = namei("/");
    80001d7c:	00006517          	auipc	a0,0x6
    80001d80:	49450513          	addi	a0,a0,1172 # 80008210 <digits+0x1b8>
    80001d84:	00002097          	auipc	ra,0x2
    80001d88:	3a4080e7          	jalr	932(ra) # 80004128 <namei>
    80001d8c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d90:	4789                	li	a5,2
    80001d92:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d94:	8526                	mv	a0,s1
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	fae080e7          	jalr	-82(ra) # 80000d44 <release>
}
    80001d9e:	60e2                	ld	ra,24(sp)
    80001da0:	6442                	ld	s0,16(sp)
    80001da2:	64a2                	ld	s1,8(sp)
    80001da4:	6105                	addi	sp,sp,32
    80001da6:	8082                	ret

0000000080001da8 <growproc>:
{
    80001da8:	1101                	addi	sp,sp,-32
    80001daa:	ec06                	sd	ra,24(sp)
    80001dac:	e822                	sd	s0,16(sp)
    80001dae:	e426                	sd	s1,8(sp)
    80001db0:	e04a                	sd	s2,0(sp)
    80001db2:	1000                	addi	s0,sp,32
    80001db4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001db6:	00000097          	auipc	ra,0x0
    80001dba:	ca6080e7          	jalr	-858(ra) # 80001a5c <myproc>
    80001dbe:	892a                	mv	s2,a0
  sz = p->sz;
    80001dc0:	652c                	ld	a1,72(a0)
    80001dc2:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001dc6:	00904f63          	bgtz	s1,80001de4 <growproc+0x3c>
  } else if(n < 0){
    80001dca:	0204cc63          	bltz	s1,80001e02 <growproc+0x5a>
  p->sz = sz;
    80001dce:	1602                	slli	a2,a2,0x20
    80001dd0:	9201                	srli	a2,a2,0x20
    80001dd2:	04c93423          	sd	a2,72(s2)
  return 0;
    80001dd6:	4501                	li	a0,0
}
    80001dd8:	60e2                	ld	ra,24(sp)
    80001dda:	6442                	ld	s0,16(sp)
    80001ddc:	64a2                	ld	s1,8(sp)
    80001dde:	6902                	ld	s2,0(sp)
    80001de0:	6105                	addi	sp,sp,32
    80001de2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001de4:	9e25                	addw	a2,a2,s1
    80001de6:	1602                	slli	a2,a2,0x20
    80001de8:	9201                	srli	a2,a2,0x20
    80001dea:	1582                	slli	a1,a1,0x20
    80001dec:	9181                	srli	a1,a1,0x20
    80001dee:	6928                	ld	a0,80(a0)
    80001df0:	fffff097          	auipc	ra,0xfffff
    80001df4:	70e080e7          	jalr	1806(ra) # 800014fe <uvmalloc>
    80001df8:	0005061b          	sext.w	a2,a0
    80001dfc:	fa69                	bnez	a2,80001dce <growproc+0x26>
      return -1;
    80001dfe:	557d                	li	a0,-1
    80001e00:	bfe1                	j	80001dd8 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e02:	9e25                	addw	a2,a2,s1
    80001e04:	1602                	slli	a2,a2,0x20
    80001e06:	9201                	srli	a2,a2,0x20
    80001e08:	1582                	slli	a1,a1,0x20
    80001e0a:	9181                	srli	a1,a1,0x20
    80001e0c:	6928                	ld	a0,80(a0)
    80001e0e:	fffff097          	auipc	ra,0xfffff
    80001e12:	6a8080e7          	jalr	1704(ra) # 800014b6 <uvmdealloc>
    80001e16:	0005061b          	sext.w	a2,a0
    80001e1a:	bf55                	j	80001dce <growproc+0x26>

0000000080001e1c <fork>:
{
    80001e1c:	7139                	addi	sp,sp,-64
    80001e1e:	fc06                	sd	ra,56(sp)
    80001e20:	f822                	sd	s0,48(sp)
    80001e22:	f426                	sd	s1,40(sp)
    80001e24:	f04a                	sd	s2,32(sp)
    80001e26:	ec4e                	sd	s3,24(sp)
    80001e28:	e852                	sd	s4,16(sp)
    80001e2a:	e456                	sd	s5,8(sp)
    80001e2c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e2e:	00000097          	auipc	ra,0x0
    80001e32:	c2e080e7          	jalr	-978(ra) # 80001a5c <myproc>
    80001e36:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e38:	00000097          	auipc	ra,0x0
    80001e3c:	e2e080e7          	jalr	-466(ra) # 80001c66 <allocproc>
    80001e40:	cd65                	beqz	a0,80001f38 <fork+0x11c>
    80001e42:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e44:	048ab603          	ld	a2,72(s5)
    80001e48:	692c                	ld	a1,80(a0)
    80001e4a:	050ab503          	ld	a0,80(s5)
    80001e4e:	fffff097          	auipc	ra,0xfffff
    80001e52:	7fc080e7          	jalr	2044(ra) # 8000164a <uvmcopy>
    80001e56:	06054363          	bltz	a0,80001ebc <fork+0xa0>
  np->sz = p->sz;
    80001e5a:	048ab783          	ld	a5,72(s5)
    80001e5e:	04fa3423          	sd	a5,72(s4)
  safestrcpy(np->mask, p->mask, sizeof(p->mask));
    80001e62:	4661                	li	a2,24
    80001e64:	168a8593          	addi	a1,s5,360
    80001e68:	168a0513          	addi	a0,s4,360
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	072080e7          	jalr	114(ra) # 80000ede <safestrcpy>
  np->parent = p;
    80001e74:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e78:	058ab683          	ld	a3,88(s5)
    80001e7c:	87b6                	mv	a5,a3
    80001e7e:	058a3703          	ld	a4,88(s4)
    80001e82:	12068693          	addi	a3,a3,288
    80001e86:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e8a:	6788                	ld	a0,8(a5)
    80001e8c:	6b8c                	ld	a1,16(a5)
    80001e8e:	6f90                	ld	a2,24(a5)
    80001e90:	01073023          	sd	a6,0(a4)
    80001e94:	e708                	sd	a0,8(a4)
    80001e96:	eb0c                	sd	a1,16(a4)
    80001e98:	ef10                	sd	a2,24(a4)
    80001e9a:	02078793          	addi	a5,a5,32
    80001e9e:	02070713          	addi	a4,a4,32
    80001ea2:	fed792e3          	bne	a5,a3,80001e86 <fork+0x6a>
  np->trapframe->a0 = 0;
    80001ea6:	058a3783          	ld	a5,88(s4)
    80001eaa:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001eae:	0d0a8493          	addi	s1,s5,208
    80001eb2:	0d0a0913          	addi	s2,s4,208
    80001eb6:	150a8993          	addi	s3,s5,336
    80001eba:	a00d                	j	80001edc <fork+0xc0>
    freeproc(np);
    80001ebc:	8552                	mv	a0,s4
    80001ebe:	00000097          	auipc	ra,0x0
    80001ec2:	d50080e7          	jalr	-688(ra) # 80001c0e <freeproc>
    release(&np->lock);
    80001ec6:	8552                	mv	a0,s4
    80001ec8:	fffff097          	auipc	ra,0xfffff
    80001ecc:	e7c080e7          	jalr	-388(ra) # 80000d44 <release>
    return -1;
    80001ed0:	54fd                	li	s1,-1
    80001ed2:	a889                	j	80001f24 <fork+0x108>
  for(i = 0; i < NOFILE; i++)
    80001ed4:	04a1                	addi	s1,s1,8
    80001ed6:	0921                	addi	s2,s2,8
    80001ed8:	01348b63          	beq	s1,s3,80001eee <fork+0xd2>
    if(p->ofile[i])
    80001edc:	6088                	ld	a0,0(s1)
    80001ede:	d97d                	beqz	a0,80001ed4 <fork+0xb8>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ee0:	00003097          	auipc	ra,0x3
    80001ee4:	8d4080e7          	jalr	-1836(ra) # 800047b4 <filedup>
    80001ee8:	00a93023          	sd	a0,0(s2)
    80001eec:	b7e5                	j	80001ed4 <fork+0xb8>
  np->cwd = idup(p->cwd);
    80001eee:	150ab503          	ld	a0,336(s5)
    80001ef2:	00002097          	auipc	ra,0x2
    80001ef6:	a48080e7          	jalr	-1464(ra) # 8000393a <idup>
    80001efa:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001efe:	4641                	li	a2,16
    80001f00:	158a8593          	addi	a1,s5,344
    80001f04:	158a0513          	addi	a0,s4,344
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	fd6080e7          	jalr	-42(ra) # 80000ede <safestrcpy>
  pid = np->pid;
    80001f10:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001f14:	4789                	li	a5,2
    80001f16:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f1a:	8552                	mv	a0,s4
    80001f1c:	fffff097          	auipc	ra,0xfffff
    80001f20:	e28080e7          	jalr	-472(ra) # 80000d44 <release>
}
    80001f24:	8526                	mv	a0,s1
    80001f26:	70e2                	ld	ra,56(sp)
    80001f28:	7442                	ld	s0,48(sp)
    80001f2a:	74a2                	ld	s1,40(sp)
    80001f2c:	7902                	ld	s2,32(sp)
    80001f2e:	69e2                	ld	s3,24(sp)
    80001f30:	6a42                	ld	s4,16(sp)
    80001f32:	6aa2                	ld	s5,8(sp)
    80001f34:	6121                	addi	sp,sp,64
    80001f36:	8082                	ret
    return -1;
    80001f38:	54fd                	li	s1,-1
    80001f3a:	b7ed                	j	80001f24 <fork+0x108>

0000000080001f3c <reparent>:
{
    80001f3c:	7179                	addi	sp,sp,-48
    80001f3e:	f406                	sd	ra,40(sp)
    80001f40:	f022                	sd	s0,32(sp)
    80001f42:	ec26                	sd	s1,24(sp)
    80001f44:	e84a                	sd	s2,16(sp)
    80001f46:	e44e                	sd	s3,8(sp)
    80001f48:	e052                	sd	s4,0(sp)
    80001f4a:	1800                	addi	s0,sp,48
    80001f4c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f4e:	00010497          	auipc	s1,0x10
    80001f52:	e1a48493          	addi	s1,s1,-486 # 80011d68 <proc>
      pp->parent = initproc;
    80001f56:	00007a17          	auipc	s4,0x7
    80001f5a:	0c2a0a13          	addi	s4,s4,194 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f5e:	00017997          	auipc	s3,0x17
    80001f62:	80a98993          	addi	s3,s3,-2038 # 80018768 <tickslock>
    80001f66:	a029                	j	80001f70 <reparent+0x34>
    80001f68:	1a848493          	addi	s1,s1,424
    80001f6c:	03348363          	beq	s1,s3,80001f92 <reparent+0x56>
    if(pp->parent == p){
    80001f70:	709c                	ld	a5,32(s1)
    80001f72:	ff279be3          	bne	a5,s2,80001f68 <reparent+0x2c>
      acquire(&pp->lock);
    80001f76:	8526                	mv	a0,s1
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	d18080e7          	jalr	-744(ra) # 80000c90 <acquire>
      pp->parent = initproc;
    80001f80:	000a3783          	ld	a5,0(s4)
    80001f84:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f86:	8526                	mv	a0,s1
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	dbc080e7          	jalr	-580(ra) # 80000d44 <release>
    80001f90:	bfe1                	j	80001f68 <reparent+0x2c>
}
    80001f92:	70a2                	ld	ra,40(sp)
    80001f94:	7402                	ld	s0,32(sp)
    80001f96:	64e2                	ld	s1,24(sp)
    80001f98:	6942                	ld	s2,16(sp)
    80001f9a:	69a2                	ld	s3,8(sp)
    80001f9c:	6a02                	ld	s4,0(sp)
    80001f9e:	6145                	addi	sp,sp,48
    80001fa0:	8082                	ret

0000000080001fa2 <scheduler>:
{
    80001fa2:	715d                	addi	sp,sp,-80
    80001fa4:	e486                	sd	ra,72(sp)
    80001fa6:	e0a2                	sd	s0,64(sp)
    80001fa8:	fc26                	sd	s1,56(sp)
    80001faa:	f84a                	sd	s2,48(sp)
    80001fac:	f44e                	sd	s3,40(sp)
    80001fae:	f052                	sd	s4,32(sp)
    80001fb0:	ec56                	sd	s5,24(sp)
    80001fb2:	e85a                	sd	s6,16(sp)
    80001fb4:	e45e                	sd	s7,8(sp)
    80001fb6:	e062                	sd	s8,0(sp)
    80001fb8:	0880                	addi	s0,sp,80
    80001fba:	8792                	mv	a5,tp
  int id = r_tp();
    80001fbc:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fbe:	00779b13          	slli	s6,a5,0x7
    80001fc2:	00010717          	auipc	a4,0x10
    80001fc6:	98e70713          	addi	a4,a4,-1650 # 80011950 <pid_lock>
    80001fca:	975a                	add	a4,a4,s6
    80001fcc:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001fd0:	00010717          	auipc	a4,0x10
    80001fd4:	9a070713          	addi	a4,a4,-1632 # 80011970 <cpus+0x8>
    80001fd8:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001fda:	4c0d                	li	s8,3
        c->proc = p;
    80001fdc:	079e                	slli	a5,a5,0x7
    80001fde:	00010a17          	auipc	s4,0x10
    80001fe2:	972a0a13          	addi	s4,s4,-1678 # 80011950 <pid_lock>
    80001fe6:	9a3e                	add	s4,s4,a5
        found = 1;
    80001fe8:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fea:	00016997          	auipc	s3,0x16
    80001fee:	77e98993          	addi	s3,s3,1918 # 80018768 <tickslock>
    80001ff2:	a899                	j	80002048 <scheduler+0xa6>
      release(&p->lock);
    80001ff4:	8526                	mv	a0,s1
    80001ff6:	fffff097          	auipc	ra,0xfffff
    80001ffa:	d4e080e7          	jalr	-690(ra) # 80000d44 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ffe:	1a848493          	addi	s1,s1,424
    80002002:	03348963          	beq	s1,s3,80002034 <scheduler+0x92>
      acquire(&p->lock);
    80002006:	8526                	mv	a0,s1
    80002008:	fffff097          	auipc	ra,0xfffff
    8000200c:	c88080e7          	jalr	-888(ra) # 80000c90 <acquire>
      if(p->state == RUNNABLE) {
    80002010:	4c9c                	lw	a5,24(s1)
    80002012:	ff2791e3          	bne	a5,s2,80001ff4 <scheduler+0x52>
        p->state = RUNNING;
    80002016:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000201a:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    8000201e:	06048593          	addi	a1,s1,96
    80002022:	855a                	mv	a0,s6
    80002024:	00000097          	auipc	ra,0x0
    80002028:	63e080e7          	jalr	1598(ra) # 80002662 <swtch>
        c->proc = 0;
    8000202c:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80002030:	8ade                	mv	s5,s7
    80002032:	b7c9                	j	80001ff4 <scheduler+0x52>
    if(found == 0) {
    80002034:	000a9a63          	bnez	s5,80002048 <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002038:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000203c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002040:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002044:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002048:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000204c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002050:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002054:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002056:	00010497          	auipc	s1,0x10
    8000205a:	d1248493          	addi	s1,s1,-750 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    8000205e:	4909                	li	s2,2
    80002060:	b75d                	j	80002006 <scheduler+0x64>

0000000080002062 <sched>:
{
    80002062:	7179                	addi	sp,sp,-48
    80002064:	f406                	sd	ra,40(sp)
    80002066:	f022                	sd	s0,32(sp)
    80002068:	ec26                	sd	s1,24(sp)
    8000206a:	e84a                	sd	s2,16(sp)
    8000206c:	e44e                	sd	s3,8(sp)
    8000206e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002070:	00000097          	auipc	ra,0x0
    80002074:	9ec080e7          	jalr	-1556(ra) # 80001a5c <myproc>
    80002078:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000207a:	fffff097          	auipc	ra,0xfffff
    8000207e:	b9c080e7          	jalr	-1124(ra) # 80000c16 <holding>
    80002082:	c93d                	beqz	a0,800020f8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002084:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002086:	2781                	sext.w	a5,a5
    80002088:	079e                	slli	a5,a5,0x7
    8000208a:	00010717          	auipc	a4,0x10
    8000208e:	8c670713          	addi	a4,a4,-1850 # 80011950 <pid_lock>
    80002092:	97ba                	add	a5,a5,a4
    80002094:	0907a703          	lw	a4,144(a5)
    80002098:	4785                	li	a5,1
    8000209a:	06f71763          	bne	a4,a5,80002108 <sched+0xa6>
  if(p->state == RUNNING)
    8000209e:	4c98                	lw	a4,24(s1)
    800020a0:	478d                	li	a5,3
    800020a2:	06f70b63          	beq	a4,a5,80002118 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020a6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020aa:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020ac:	efb5                	bnez	a5,80002128 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020ae:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020b0:	00010917          	auipc	s2,0x10
    800020b4:	8a090913          	addi	s2,s2,-1888 # 80011950 <pid_lock>
    800020b8:	2781                	sext.w	a5,a5
    800020ba:	079e                	slli	a5,a5,0x7
    800020bc:	97ca                	add	a5,a5,s2
    800020be:	0947a983          	lw	s3,148(a5)
    800020c2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020c4:	2781                	sext.w	a5,a5
    800020c6:	079e                	slli	a5,a5,0x7
    800020c8:	00010597          	auipc	a1,0x10
    800020cc:	8a858593          	addi	a1,a1,-1880 # 80011970 <cpus+0x8>
    800020d0:	95be                	add	a1,a1,a5
    800020d2:	06048513          	addi	a0,s1,96
    800020d6:	00000097          	auipc	ra,0x0
    800020da:	58c080e7          	jalr	1420(ra) # 80002662 <swtch>
    800020de:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020e0:	2781                	sext.w	a5,a5
    800020e2:	079e                	slli	a5,a5,0x7
    800020e4:	97ca                	add	a5,a5,s2
    800020e6:	0937aa23          	sw	s3,148(a5)
}
    800020ea:	70a2                	ld	ra,40(sp)
    800020ec:	7402                	ld	s0,32(sp)
    800020ee:	64e2                	ld	s1,24(sp)
    800020f0:	6942                	ld	s2,16(sp)
    800020f2:	69a2                	ld	s3,8(sp)
    800020f4:	6145                	addi	sp,sp,48
    800020f6:	8082                	ret
    panic("sched p->lock");
    800020f8:	00006517          	auipc	a0,0x6
    800020fc:	12050513          	addi	a0,a0,288 # 80008218 <digits+0x1c0>
    80002100:	ffffe097          	auipc	ra,0xffffe
    80002104:	442080e7          	jalr	1090(ra) # 80000542 <panic>
    panic("sched locks");
    80002108:	00006517          	auipc	a0,0x6
    8000210c:	12050513          	addi	a0,a0,288 # 80008228 <digits+0x1d0>
    80002110:	ffffe097          	auipc	ra,0xffffe
    80002114:	432080e7          	jalr	1074(ra) # 80000542 <panic>
    panic("sched running");
    80002118:	00006517          	auipc	a0,0x6
    8000211c:	12050513          	addi	a0,a0,288 # 80008238 <digits+0x1e0>
    80002120:	ffffe097          	auipc	ra,0xffffe
    80002124:	422080e7          	jalr	1058(ra) # 80000542 <panic>
    panic("sched interruptible");
    80002128:	00006517          	auipc	a0,0x6
    8000212c:	12050513          	addi	a0,a0,288 # 80008248 <digits+0x1f0>
    80002130:	ffffe097          	auipc	ra,0xffffe
    80002134:	412080e7          	jalr	1042(ra) # 80000542 <panic>

0000000080002138 <exit>:
{
    80002138:	7179                	addi	sp,sp,-48
    8000213a:	f406                	sd	ra,40(sp)
    8000213c:	f022                	sd	s0,32(sp)
    8000213e:	ec26                	sd	s1,24(sp)
    80002140:	e84a                	sd	s2,16(sp)
    80002142:	e44e                	sd	s3,8(sp)
    80002144:	e052                	sd	s4,0(sp)
    80002146:	1800                	addi	s0,sp,48
    80002148:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000214a:	00000097          	auipc	ra,0x0
    8000214e:	912080e7          	jalr	-1774(ra) # 80001a5c <myproc>
    80002152:	89aa                	mv	s3,a0
  if(p == initproc)
    80002154:	00007797          	auipc	a5,0x7
    80002158:	ec47b783          	ld	a5,-316(a5) # 80009018 <initproc>
    8000215c:	0d050493          	addi	s1,a0,208
    80002160:	15050913          	addi	s2,a0,336
    80002164:	02a79363          	bne	a5,a0,8000218a <exit+0x52>
    panic("init exiting");
    80002168:	00006517          	auipc	a0,0x6
    8000216c:	0f850513          	addi	a0,a0,248 # 80008260 <digits+0x208>
    80002170:	ffffe097          	auipc	ra,0xffffe
    80002174:	3d2080e7          	jalr	978(ra) # 80000542 <panic>
      fileclose(f);
    80002178:	00002097          	auipc	ra,0x2
    8000217c:	68e080e7          	jalr	1678(ra) # 80004806 <fileclose>
      p->ofile[fd] = 0;
    80002180:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002184:	04a1                	addi	s1,s1,8
    80002186:	01248563          	beq	s1,s2,80002190 <exit+0x58>
    if(p->ofile[fd]){
    8000218a:	6088                	ld	a0,0(s1)
    8000218c:	f575                	bnez	a0,80002178 <exit+0x40>
    8000218e:	bfdd                	j	80002184 <exit+0x4c>
  begin_op();
    80002190:	00002097          	auipc	ra,0x2
    80002194:	1a4080e7          	jalr	420(ra) # 80004334 <begin_op>
  iput(p->cwd);
    80002198:	1509b503          	ld	a0,336(s3)
    8000219c:	00002097          	auipc	ra,0x2
    800021a0:	996080e7          	jalr	-1642(ra) # 80003b32 <iput>
  end_op();
    800021a4:	00002097          	auipc	ra,0x2
    800021a8:	210080e7          	jalr	528(ra) # 800043b4 <end_op>
  p->cwd = 0;
    800021ac:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    800021b0:	00007497          	auipc	s1,0x7
    800021b4:	e6848493          	addi	s1,s1,-408 # 80009018 <initproc>
    800021b8:	6088                	ld	a0,0(s1)
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	ad6080e7          	jalr	-1322(ra) # 80000c90 <acquire>
  wakeup1(initproc);
    800021c2:	6088                	ld	a0,0(s1)
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	758080e7          	jalr	1880(ra) # 8000191c <wakeup1>
  release(&initproc->lock);
    800021cc:	6088                	ld	a0,0(s1)
    800021ce:	fffff097          	auipc	ra,0xfffff
    800021d2:	b76080e7          	jalr	-1162(ra) # 80000d44 <release>
  acquire(&p->lock);
    800021d6:	854e                	mv	a0,s3
    800021d8:	fffff097          	auipc	ra,0xfffff
    800021dc:	ab8080e7          	jalr	-1352(ra) # 80000c90 <acquire>
  struct proc *original_parent = p->parent;
    800021e0:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800021e4:	854e                	mv	a0,s3
    800021e6:	fffff097          	auipc	ra,0xfffff
    800021ea:	b5e080e7          	jalr	-1186(ra) # 80000d44 <release>
  acquire(&original_parent->lock);
    800021ee:	8526                	mv	a0,s1
    800021f0:	fffff097          	auipc	ra,0xfffff
    800021f4:	aa0080e7          	jalr	-1376(ra) # 80000c90 <acquire>
  acquire(&p->lock);
    800021f8:	854e                	mv	a0,s3
    800021fa:	fffff097          	auipc	ra,0xfffff
    800021fe:	a96080e7          	jalr	-1386(ra) # 80000c90 <acquire>
  reparent(p);
    80002202:	854e                	mv	a0,s3
    80002204:	00000097          	auipc	ra,0x0
    80002208:	d38080e7          	jalr	-712(ra) # 80001f3c <reparent>
  wakeup1(original_parent);
    8000220c:	8526                	mv	a0,s1
    8000220e:	fffff097          	auipc	ra,0xfffff
    80002212:	70e080e7          	jalr	1806(ra) # 8000191c <wakeup1>
  p->xstate = status;
    80002216:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    8000221a:	4791                	li	a5,4
    8000221c:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80002220:	8526                	mv	a0,s1
    80002222:	fffff097          	auipc	ra,0xfffff
    80002226:	b22080e7          	jalr	-1246(ra) # 80000d44 <release>
  sched();
    8000222a:	00000097          	auipc	ra,0x0
    8000222e:	e38080e7          	jalr	-456(ra) # 80002062 <sched>
  panic("zombie exit");
    80002232:	00006517          	auipc	a0,0x6
    80002236:	03e50513          	addi	a0,a0,62 # 80008270 <digits+0x218>
    8000223a:	ffffe097          	auipc	ra,0xffffe
    8000223e:	308080e7          	jalr	776(ra) # 80000542 <panic>

0000000080002242 <yield>:
{
    80002242:	1101                	addi	sp,sp,-32
    80002244:	ec06                	sd	ra,24(sp)
    80002246:	e822                	sd	s0,16(sp)
    80002248:	e426                	sd	s1,8(sp)
    8000224a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000224c:	00000097          	auipc	ra,0x0
    80002250:	810080e7          	jalr	-2032(ra) # 80001a5c <myproc>
    80002254:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002256:	fffff097          	auipc	ra,0xfffff
    8000225a:	a3a080e7          	jalr	-1478(ra) # 80000c90 <acquire>
  p->state = RUNNABLE;
    8000225e:	4789                	li	a5,2
    80002260:	cc9c                	sw	a5,24(s1)
  sched();
    80002262:	00000097          	auipc	ra,0x0
    80002266:	e00080e7          	jalr	-512(ra) # 80002062 <sched>
  release(&p->lock);
    8000226a:	8526                	mv	a0,s1
    8000226c:	fffff097          	auipc	ra,0xfffff
    80002270:	ad8080e7          	jalr	-1320(ra) # 80000d44 <release>
}
    80002274:	60e2                	ld	ra,24(sp)
    80002276:	6442                	ld	s0,16(sp)
    80002278:	64a2                	ld	s1,8(sp)
    8000227a:	6105                	addi	sp,sp,32
    8000227c:	8082                	ret

000000008000227e <sleep>:
{
    8000227e:	7179                	addi	sp,sp,-48
    80002280:	f406                	sd	ra,40(sp)
    80002282:	f022                	sd	s0,32(sp)
    80002284:	ec26                	sd	s1,24(sp)
    80002286:	e84a                	sd	s2,16(sp)
    80002288:	e44e                	sd	s3,8(sp)
    8000228a:	1800                	addi	s0,sp,48
    8000228c:	89aa                	mv	s3,a0
    8000228e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002290:	fffff097          	auipc	ra,0xfffff
    80002294:	7cc080e7          	jalr	1996(ra) # 80001a5c <myproc>
    80002298:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000229a:	05250663          	beq	a0,s2,800022e6 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	9f2080e7          	jalr	-1550(ra) # 80000c90 <acquire>
    release(lk);
    800022a6:	854a                	mv	a0,s2
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	a9c080e7          	jalr	-1380(ra) # 80000d44 <release>
  p->chan = chan;
    800022b0:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    800022b4:	4785                	li	a5,1
    800022b6:	cc9c                	sw	a5,24(s1)
  sched();
    800022b8:	00000097          	auipc	ra,0x0
    800022bc:	daa080e7          	jalr	-598(ra) # 80002062 <sched>
  p->chan = 0;
    800022c0:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800022c4:	8526                	mv	a0,s1
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	a7e080e7          	jalr	-1410(ra) # 80000d44 <release>
    acquire(lk);
    800022ce:	854a                	mv	a0,s2
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	9c0080e7          	jalr	-1600(ra) # 80000c90 <acquire>
}
    800022d8:	70a2                	ld	ra,40(sp)
    800022da:	7402                	ld	s0,32(sp)
    800022dc:	64e2                	ld	s1,24(sp)
    800022de:	6942                	ld	s2,16(sp)
    800022e0:	69a2                	ld	s3,8(sp)
    800022e2:	6145                	addi	sp,sp,48
    800022e4:	8082                	ret
  p->chan = chan;
    800022e6:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800022ea:	4785                	li	a5,1
    800022ec:	cd1c                	sw	a5,24(a0)
  sched();
    800022ee:	00000097          	auipc	ra,0x0
    800022f2:	d74080e7          	jalr	-652(ra) # 80002062 <sched>
  p->chan = 0;
    800022f6:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800022fa:	bff9                	j	800022d8 <sleep+0x5a>

00000000800022fc <wait>:
{
    800022fc:	715d                	addi	sp,sp,-80
    800022fe:	e486                	sd	ra,72(sp)
    80002300:	e0a2                	sd	s0,64(sp)
    80002302:	fc26                	sd	s1,56(sp)
    80002304:	f84a                	sd	s2,48(sp)
    80002306:	f44e                	sd	s3,40(sp)
    80002308:	f052                	sd	s4,32(sp)
    8000230a:	ec56                	sd	s5,24(sp)
    8000230c:	e85a                	sd	s6,16(sp)
    8000230e:	e45e                	sd	s7,8(sp)
    80002310:	0880                	addi	s0,sp,80
    80002312:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	748080e7          	jalr	1864(ra) # 80001a5c <myproc>
    8000231c:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000231e:	fffff097          	auipc	ra,0xfffff
    80002322:	972080e7          	jalr	-1678(ra) # 80000c90 <acquire>
    havekids = 0;
    80002326:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002328:	4a11                	li	s4,4
        havekids = 1;
    8000232a:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000232c:	00016997          	auipc	s3,0x16
    80002330:	43c98993          	addi	s3,s3,1084 # 80018768 <tickslock>
    havekids = 0;
    80002334:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002336:	00010497          	auipc	s1,0x10
    8000233a:	a3248493          	addi	s1,s1,-1486 # 80011d68 <proc>
    8000233e:	a08d                	j	800023a0 <wait+0xa4>
          pid = np->pid;
    80002340:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002344:	000b0e63          	beqz	s6,80002360 <wait+0x64>
    80002348:	4691                	li	a3,4
    8000234a:	03448613          	addi	a2,s1,52
    8000234e:	85da                	mv	a1,s6
    80002350:	05093503          	ld	a0,80(s2)
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	3fa080e7          	jalr	1018(ra) # 8000174e <copyout>
    8000235c:	02054263          	bltz	a0,80002380 <wait+0x84>
          freeproc(np);
    80002360:	8526                	mv	a0,s1
    80002362:	00000097          	auipc	ra,0x0
    80002366:	8ac080e7          	jalr	-1876(ra) # 80001c0e <freeproc>
          release(&np->lock);
    8000236a:	8526                	mv	a0,s1
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	9d8080e7          	jalr	-1576(ra) # 80000d44 <release>
          release(&p->lock);
    80002374:	854a                	mv	a0,s2
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	9ce080e7          	jalr	-1586(ra) # 80000d44 <release>
          return pid;
    8000237e:	a8a9                	j	800023d8 <wait+0xdc>
            release(&np->lock);
    80002380:	8526                	mv	a0,s1
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	9c2080e7          	jalr	-1598(ra) # 80000d44 <release>
            release(&p->lock);
    8000238a:	854a                	mv	a0,s2
    8000238c:	fffff097          	auipc	ra,0xfffff
    80002390:	9b8080e7          	jalr	-1608(ra) # 80000d44 <release>
            return -1;
    80002394:	59fd                	li	s3,-1
    80002396:	a089                	j	800023d8 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002398:	1a848493          	addi	s1,s1,424
    8000239c:	03348463          	beq	s1,s3,800023c4 <wait+0xc8>
      if(np->parent == p){
    800023a0:	709c                	ld	a5,32(s1)
    800023a2:	ff279be3          	bne	a5,s2,80002398 <wait+0x9c>
        acquire(&np->lock);
    800023a6:	8526                	mv	a0,s1
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	8e8080e7          	jalr	-1816(ra) # 80000c90 <acquire>
        if(np->state == ZOMBIE){
    800023b0:	4c9c                	lw	a5,24(s1)
    800023b2:	f94787e3          	beq	a5,s4,80002340 <wait+0x44>
        release(&np->lock);
    800023b6:	8526                	mv	a0,s1
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	98c080e7          	jalr	-1652(ra) # 80000d44 <release>
        havekids = 1;
    800023c0:	8756                	mv	a4,s5
    800023c2:	bfd9                	j	80002398 <wait+0x9c>
    if(!havekids || p->killed){
    800023c4:	c701                	beqz	a4,800023cc <wait+0xd0>
    800023c6:	03092783          	lw	a5,48(s2)
    800023ca:	c39d                	beqz	a5,800023f0 <wait+0xf4>
      release(&p->lock);
    800023cc:	854a                	mv	a0,s2
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	976080e7          	jalr	-1674(ra) # 80000d44 <release>
      return -1;
    800023d6:	59fd                	li	s3,-1
}
    800023d8:	854e                	mv	a0,s3
    800023da:	60a6                	ld	ra,72(sp)
    800023dc:	6406                	ld	s0,64(sp)
    800023de:	74e2                	ld	s1,56(sp)
    800023e0:	7942                	ld	s2,48(sp)
    800023e2:	79a2                	ld	s3,40(sp)
    800023e4:	7a02                	ld	s4,32(sp)
    800023e6:	6ae2                	ld	s5,24(sp)
    800023e8:	6b42                	ld	s6,16(sp)
    800023ea:	6ba2                	ld	s7,8(sp)
    800023ec:	6161                	addi	sp,sp,80
    800023ee:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023f0:	85ca                	mv	a1,s2
    800023f2:	854a                	mv	a0,s2
    800023f4:	00000097          	auipc	ra,0x0
    800023f8:	e8a080e7          	jalr	-374(ra) # 8000227e <sleep>
    havekids = 0;
    800023fc:	bf25                	j	80002334 <wait+0x38>

00000000800023fe <wakeup>:
{
    800023fe:	7139                	addi	sp,sp,-64
    80002400:	fc06                	sd	ra,56(sp)
    80002402:	f822                	sd	s0,48(sp)
    80002404:	f426                	sd	s1,40(sp)
    80002406:	f04a                	sd	s2,32(sp)
    80002408:	ec4e                	sd	s3,24(sp)
    8000240a:	e852                	sd	s4,16(sp)
    8000240c:	e456                	sd	s5,8(sp)
    8000240e:	0080                	addi	s0,sp,64
    80002410:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002412:	00010497          	auipc	s1,0x10
    80002416:	95648493          	addi	s1,s1,-1706 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    8000241a:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000241c:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    8000241e:	00016917          	auipc	s2,0x16
    80002422:	34a90913          	addi	s2,s2,842 # 80018768 <tickslock>
    80002426:	a811                	j	8000243a <wakeup+0x3c>
    release(&p->lock);
    80002428:	8526                	mv	a0,s1
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	91a080e7          	jalr	-1766(ra) # 80000d44 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002432:	1a848493          	addi	s1,s1,424
    80002436:	03248063          	beq	s1,s2,80002456 <wakeup+0x58>
    acquire(&p->lock);
    8000243a:	8526                	mv	a0,s1
    8000243c:	fffff097          	auipc	ra,0xfffff
    80002440:	854080e7          	jalr	-1964(ra) # 80000c90 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002444:	4c9c                	lw	a5,24(s1)
    80002446:	ff3791e3          	bne	a5,s3,80002428 <wakeup+0x2a>
    8000244a:	749c                	ld	a5,40(s1)
    8000244c:	fd479ee3          	bne	a5,s4,80002428 <wakeup+0x2a>
      p->state = RUNNABLE;
    80002450:	0154ac23          	sw	s5,24(s1)
    80002454:	bfd1                	j	80002428 <wakeup+0x2a>
}
    80002456:	70e2                	ld	ra,56(sp)
    80002458:	7442                	ld	s0,48(sp)
    8000245a:	74a2                	ld	s1,40(sp)
    8000245c:	7902                	ld	s2,32(sp)
    8000245e:	69e2                	ld	s3,24(sp)
    80002460:	6a42                	ld	s4,16(sp)
    80002462:	6aa2                	ld	s5,8(sp)
    80002464:	6121                	addi	sp,sp,64
    80002466:	8082                	ret

0000000080002468 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002468:	7179                	addi	sp,sp,-48
    8000246a:	f406                	sd	ra,40(sp)
    8000246c:	f022                	sd	s0,32(sp)
    8000246e:	ec26                	sd	s1,24(sp)
    80002470:	e84a                	sd	s2,16(sp)
    80002472:	e44e                	sd	s3,8(sp)
    80002474:	1800                	addi	s0,sp,48
    80002476:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002478:	00010497          	auipc	s1,0x10
    8000247c:	8f048493          	addi	s1,s1,-1808 # 80011d68 <proc>
    80002480:	00016997          	auipc	s3,0x16
    80002484:	2e898993          	addi	s3,s3,744 # 80018768 <tickslock>
    acquire(&p->lock);
    80002488:	8526                	mv	a0,s1
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	806080e7          	jalr	-2042(ra) # 80000c90 <acquire>
    if(p->pid == pid){
    80002492:	5c9c                	lw	a5,56(s1)
    80002494:	01278d63          	beq	a5,s2,800024ae <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002498:	8526                	mv	a0,s1
    8000249a:	fffff097          	auipc	ra,0xfffff
    8000249e:	8aa080e7          	jalr	-1878(ra) # 80000d44 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024a2:	1a848493          	addi	s1,s1,424
    800024a6:	ff3491e3          	bne	s1,s3,80002488 <kill+0x20>
  }
  return -1;
    800024aa:	557d                	li	a0,-1
    800024ac:	a821                	j	800024c4 <kill+0x5c>
      p->killed = 1;
    800024ae:	4785                	li	a5,1
    800024b0:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800024b2:	4c98                	lw	a4,24(s1)
    800024b4:	00f70f63          	beq	a4,a5,800024d2 <kill+0x6a>
      release(&p->lock);
    800024b8:	8526                	mv	a0,s1
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	88a080e7          	jalr	-1910(ra) # 80000d44 <release>
      return 0;
    800024c2:	4501                	li	a0,0
}
    800024c4:	70a2                	ld	ra,40(sp)
    800024c6:	7402                	ld	s0,32(sp)
    800024c8:	64e2                	ld	s1,24(sp)
    800024ca:	6942                	ld	s2,16(sp)
    800024cc:	69a2                	ld	s3,8(sp)
    800024ce:	6145                	addi	sp,sp,48
    800024d0:	8082                	ret
        p->state = RUNNABLE;
    800024d2:	4789                	li	a5,2
    800024d4:	cc9c                	sw	a5,24(s1)
    800024d6:	b7cd                	j	800024b8 <kill+0x50>

00000000800024d8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024d8:	7179                	addi	sp,sp,-48
    800024da:	f406                	sd	ra,40(sp)
    800024dc:	f022                	sd	s0,32(sp)
    800024de:	ec26                	sd	s1,24(sp)
    800024e0:	e84a                	sd	s2,16(sp)
    800024e2:	e44e                	sd	s3,8(sp)
    800024e4:	e052                	sd	s4,0(sp)
    800024e6:	1800                	addi	s0,sp,48
    800024e8:	84aa                	mv	s1,a0
    800024ea:	892e                	mv	s2,a1
    800024ec:	89b2                	mv	s3,a2
    800024ee:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024f0:	fffff097          	auipc	ra,0xfffff
    800024f4:	56c080e7          	jalr	1388(ra) # 80001a5c <myproc>
  if(user_dst){
    800024f8:	c08d                	beqz	s1,8000251a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024fa:	86d2                	mv	a3,s4
    800024fc:	864e                	mv	a2,s3
    800024fe:	85ca                	mv	a1,s2
    80002500:	6928                	ld	a0,80(a0)
    80002502:	fffff097          	auipc	ra,0xfffff
    80002506:	24c080e7          	jalr	588(ra) # 8000174e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000250a:	70a2                	ld	ra,40(sp)
    8000250c:	7402                	ld	s0,32(sp)
    8000250e:	64e2                	ld	s1,24(sp)
    80002510:	6942                	ld	s2,16(sp)
    80002512:	69a2                	ld	s3,8(sp)
    80002514:	6a02                	ld	s4,0(sp)
    80002516:	6145                	addi	sp,sp,48
    80002518:	8082                	ret
    memmove((char *)dst, src, len);
    8000251a:	000a061b          	sext.w	a2,s4
    8000251e:	85ce                	mv	a1,s3
    80002520:	854a                	mv	a0,s2
    80002522:	fffff097          	auipc	ra,0xfffff
    80002526:	8c6080e7          	jalr	-1850(ra) # 80000de8 <memmove>
    return 0;
    8000252a:	8526                	mv	a0,s1
    8000252c:	bff9                	j	8000250a <either_copyout+0x32>

000000008000252e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000252e:	7179                	addi	sp,sp,-48
    80002530:	f406                	sd	ra,40(sp)
    80002532:	f022                	sd	s0,32(sp)
    80002534:	ec26                	sd	s1,24(sp)
    80002536:	e84a                	sd	s2,16(sp)
    80002538:	e44e                	sd	s3,8(sp)
    8000253a:	e052                	sd	s4,0(sp)
    8000253c:	1800                	addi	s0,sp,48
    8000253e:	892a                	mv	s2,a0
    80002540:	84ae                	mv	s1,a1
    80002542:	89b2                	mv	s3,a2
    80002544:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002546:	fffff097          	auipc	ra,0xfffff
    8000254a:	516080e7          	jalr	1302(ra) # 80001a5c <myproc>
  if(user_src){
    8000254e:	c08d                	beqz	s1,80002570 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002550:	86d2                	mv	a3,s4
    80002552:	864e                	mv	a2,s3
    80002554:	85ca                	mv	a1,s2
    80002556:	6928                	ld	a0,80(a0)
    80002558:	fffff097          	auipc	ra,0xfffff
    8000255c:	282080e7          	jalr	642(ra) # 800017da <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002560:	70a2                	ld	ra,40(sp)
    80002562:	7402                	ld	s0,32(sp)
    80002564:	64e2                	ld	s1,24(sp)
    80002566:	6942                	ld	s2,16(sp)
    80002568:	69a2                	ld	s3,8(sp)
    8000256a:	6a02                	ld	s4,0(sp)
    8000256c:	6145                	addi	sp,sp,48
    8000256e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002570:	000a061b          	sext.w	a2,s4
    80002574:	85ce                	mv	a1,s3
    80002576:	854a                	mv	a0,s2
    80002578:	fffff097          	auipc	ra,0xfffff
    8000257c:	870080e7          	jalr	-1936(ra) # 80000de8 <memmove>
    return 0;
    80002580:	8526                	mv	a0,s1
    80002582:	bff9                	j	80002560 <either_copyin+0x32>

0000000080002584 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002584:	715d                	addi	sp,sp,-80
    80002586:	e486                	sd	ra,72(sp)
    80002588:	e0a2                	sd	s0,64(sp)
    8000258a:	fc26                	sd	s1,56(sp)
    8000258c:	f84a                	sd	s2,48(sp)
    8000258e:	f44e                	sd	s3,40(sp)
    80002590:	f052                	sd	s4,32(sp)
    80002592:	ec56                	sd	s5,24(sp)
    80002594:	e85a                	sd	s6,16(sp)
    80002596:	e45e                	sd	s7,8(sp)
    80002598:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000259a:	00006517          	auipc	a0,0x6
    8000259e:	b4650513          	addi	a0,a0,-1210 # 800080e0 <digits+0x88>
    800025a2:	ffffe097          	auipc	ra,0xffffe
    800025a6:	fea080e7          	jalr	-22(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025aa:	00010497          	auipc	s1,0x10
    800025ae:	91648493          	addi	s1,s1,-1770 # 80011ec0 <proc+0x158>
    800025b2:	00016917          	auipc	s2,0x16
    800025b6:	30e90913          	addi	s2,s2,782 # 800188c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ba:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800025bc:	00006997          	auipc	s3,0x6
    800025c0:	cc498993          	addi	s3,s3,-828 # 80008280 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    800025c4:	00006a97          	auipc	s5,0x6
    800025c8:	cc4a8a93          	addi	s5,s5,-828 # 80008288 <digits+0x230>
    printf("\n");
    800025cc:	00006a17          	auipc	s4,0x6
    800025d0:	b14a0a13          	addi	s4,s4,-1260 # 800080e0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025d4:	00006b97          	auipc	s7,0x6
    800025d8:	cecb8b93          	addi	s7,s7,-788 # 800082c0 <states.0>
    800025dc:	a00d                	j	800025fe <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025de:	ee06a583          	lw	a1,-288(a3)
    800025e2:	8556                	mv	a0,s5
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	fa8080e7          	jalr	-88(ra) # 8000058c <printf>
    printf("\n");
    800025ec:	8552                	mv	a0,s4
    800025ee:	ffffe097          	auipc	ra,0xffffe
    800025f2:	f9e080e7          	jalr	-98(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025f6:	1a848493          	addi	s1,s1,424
    800025fa:	03248163          	beq	s1,s2,8000261c <procdump+0x98>
    if(p->state == UNUSED)
    800025fe:	86a6                	mv	a3,s1
    80002600:	ec04a783          	lw	a5,-320(s1)
    80002604:	dbed                	beqz	a5,800025f6 <procdump+0x72>
      state = "???";
    80002606:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002608:	fcfb6be3          	bltu	s6,a5,800025de <procdump+0x5a>
    8000260c:	1782                	slli	a5,a5,0x20
    8000260e:	9381                	srli	a5,a5,0x20
    80002610:	078e                	slli	a5,a5,0x3
    80002612:	97de                	add	a5,a5,s7
    80002614:	6390                	ld	a2,0(a5)
    80002616:	f661                	bnez	a2,800025de <procdump+0x5a>
      state = "???";
    80002618:	864e                	mv	a2,s3
    8000261a:	b7d1                	j	800025de <procdump+0x5a>
  }
}
    8000261c:	60a6                	ld	ra,72(sp)
    8000261e:	6406                	ld	s0,64(sp)
    80002620:	74e2                	ld	s1,56(sp)
    80002622:	7942                	ld	s2,48(sp)
    80002624:	79a2                	ld	s3,40(sp)
    80002626:	7a02                	ld	s4,32(sp)
    80002628:	6ae2                	ld	s5,24(sp)
    8000262a:	6b42                	ld	s6,16(sp)
    8000262c:	6ba2                	ld	s7,8(sp)
    8000262e:	6161                	addi	sp,sp,80
    80002630:	8082                	ret

0000000080002632 <proc_num>:
int 
proc_num(void){
    80002632:	1141                	addi	sp,sp,-16
    80002634:	e422                	sd	s0,8(sp)
    80002636:	0800                	addi	s0,sp,16
  struct proc*p;
  uint64 num=0;
    80002638:	4501                	li	a0,0
  for(p=proc;p<&proc[NPROC];p++){
    8000263a:	0000f797          	auipc	a5,0xf
    8000263e:	72e78793          	addi	a5,a5,1838 # 80011d68 <proc>
    80002642:	00016697          	auipc	a3,0x16
    80002646:	12668693          	addi	a3,a3,294 # 80018768 <tickslock>
    if(p->state!=UNUSED){
    8000264a:	4f98                	lw	a4,24(a5)
      num++;
    8000264c:	00e03733          	snez	a4,a4
    80002650:	953a                	add	a0,a0,a4
  for(p=proc;p<&proc[NPROC];p++){
    80002652:	1a878793          	addi	a5,a5,424
    80002656:	fed79ae3          	bne	a5,a3,8000264a <proc_num+0x18>
    }
  }
  return num;
}
    8000265a:	2501                	sext.w	a0,a0
    8000265c:	6422                	ld	s0,8(sp)
    8000265e:	0141                	addi	sp,sp,16
    80002660:	8082                	ret

0000000080002662 <swtch>:
    80002662:	00153023          	sd	ra,0(a0)
    80002666:	00253423          	sd	sp,8(a0)
    8000266a:	e900                	sd	s0,16(a0)
    8000266c:	ed04                	sd	s1,24(a0)
    8000266e:	03253023          	sd	s2,32(a0)
    80002672:	03353423          	sd	s3,40(a0)
    80002676:	03453823          	sd	s4,48(a0)
    8000267a:	03553c23          	sd	s5,56(a0)
    8000267e:	05653023          	sd	s6,64(a0)
    80002682:	05753423          	sd	s7,72(a0)
    80002686:	05853823          	sd	s8,80(a0)
    8000268a:	05953c23          	sd	s9,88(a0)
    8000268e:	07a53023          	sd	s10,96(a0)
    80002692:	07b53423          	sd	s11,104(a0)
    80002696:	0005b083          	ld	ra,0(a1)
    8000269a:	0085b103          	ld	sp,8(a1)
    8000269e:	6980                	ld	s0,16(a1)
    800026a0:	6d84                	ld	s1,24(a1)
    800026a2:	0205b903          	ld	s2,32(a1)
    800026a6:	0285b983          	ld	s3,40(a1)
    800026aa:	0305ba03          	ld	s4,48(a1)
    800026ae:	0385ba83          	ld	s5,56(a1)
    800026b2:	0405bb03          	ld	s6,64(a1)
    800026b6:	0485bb83          	ld	s7,72(a1)
    800026ba:	0505bc03          	ld	s8,80(a1)
    800026be:	0585bc83          	ld	s9,88(a1)
    800026c2:	0605bd03          	ld	s10,96(a1)
    800026c6:	0685bd83          	ld	s11,104(a1)
    800026ca:	8082                	ret

00000000800026cc <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026cc:	1141                	addi	sp,sp,-16
    800026ce:	e406                	sd	ra,8(sp)
    800026d0:	e022                	sd	s0,0(sp)
    800026d2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026d4:	00006597          	auipc	a1,0x6
    800026d8:	c1458593          	addi	a1,a1,-1004 # 800082e8 <states.0+0x28>
    800026dc:	00016517          	auipc	a0,0x16
    800026e0:	08c50513          	addi	a0,a0,140 # 80018768 <tickslock>
    800026e4:	ffffe097          	auipc	ra,0xffffe
    800026e8:	51c080e7          	jalr	1308(ra) # 80000c00 <initlock>
}
    800026ec:	60a2                	ld	ra,8(sp)
    800026ee:	6402                	ld	s0,0(sp)
    800026f0:	0141                	addi	sp,sp,16
    800026f2:	8082                	ret

00000000800026f4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026f4:	1141                	addi	sp,sp,-16
    800026f6:	e422                	sd	s0,8(sp)
    800026f8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026fa:	00003797          	auipc	a5,0x3
    800026fe:	76678793          	addi	a5,a5,1894 # 80005e60 <kernelvec>
    80002702:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002706:	6422                	ld	s0,8(sp)
    80002708:	0141                	addi	sp,sp,16
    8000270a:	8082                	ret

000000008000270c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000270c:	1141                	addi	sp,sp,-16
    8000270e:	e406                	sd	ra,8(sp)
    80002710:	e022                	sd	s0,0(sp)
    80002712:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002714:	fffff097          	auipc	ra,0xfffff
    80002718:	348080e7          	jalr	840(ra) # 80001a5c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000271c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002720:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002722:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002726:	00005617          	auipc	a2,0x5
    8000272a:	8da60613          	addi	a2,a2,-1830 # 80007000 <_trampoline>
    8000272e:	00005697          	auipc	a3,0x5
    80002732:	8d268693          	addi	a3,a3,-1838 # 80007000 <_trampoline>
    80002736:	8e91                	sub	a3,a3,a2
    80002738:	040007b7          	lui	a5,0x4000
    8000273c:	17fd                	addi	a5,a5,-1
    8000273e:	07b2                	slli	a5,a5,0xc
    80002740:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002742:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002746:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002748:	180026f3          	csrr	a3,satp
    8000274c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000274e:	6d38                	ld	a4,88(a0)
    80002750:	6134                	ld	a3,64(a0)
    80002752:	6585                	lui	a1,0x1
    80002754:	96ae                	add	a3,a3,a1
    80002756:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002758:	6d38                	ld	a4,88(a0)
    8000275a:	00000697          	auipc	a3,0x0
    8000275e:	2ac68693          	addi	a3,a3,684 # 80002a06 <usertrap>
    80002762:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002764:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002766:	8692                	mv	a3,tp
    80002768:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000276a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000276e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002772:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002776:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000277a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000277c:	6f18                	ld	a4,24(a4)
    8000277e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002782:	692c                	ld	a1,80(a0)
    80002784:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002786:	00005717          	auipc	a4,0x5
    8000278a:	90a70713          	addi	a4,a4,-1782 # 80007090 <userret>
    8000278e:	8f11                	sub	a4,a4,a2
    80002790:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002792:	577d                	li	a4,-1
    80002794:	177e                	slli	a4,a4,0x3f
    80002796:	8dd9                	or	a1,a1,a4
    80002798:	02000537          	lui	a0,0x2000
    8000279c:	157d                	addi	a0,a0,-1
    8000279e:	0536                	slli	a0,a0,0xd
    800027a0:	9782                	jalr	a5
}
    800027a2:	60a2                	ld	ra,8(sp)
    800027a4:	6402                	ld	s0,0(sp)
    800027a6:	0141                	addi	sp,sp,16
    800027a8:	8082                	ret

00000000800027aa <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027aa:	1101                	addi	sp,sp,-32
    800027ac:	ec06                	sd	ra,24(sp)
    800027ae:	e822                	sd	s0,16(sp)
    800027b0:	e426                	sd	s1,8(sp)
    800027b2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800027b4:	00016497          	auipc	s1,0x16
    800027b8:	fb448493          	addi	s1,s1,-76 # 80018768 <tickslock>
    800027bc:	8526                	mv	a0,s1
    800027be:	ffffe097          	auipc	ra,0xffffe
    800027c2:	4d2080e7          	jalr	1234(ra) # 80000c90 <acquire>
  ticks++;
    800027c6:	00007517          	auipc	a0,0x7
    800027ca:	85a50513          	addi	a0,a0,-1958 # 80009020 <ticks>
    800027ce:	411c                	lw	a5,0(a0)
    800027d0:	2785                	addiw	a5,a5,1
    800027d2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027d4:	00000097          	auipc	ra,0x0
    800027d8:	c2a080e7          	jalr	-982(ra) # 800023fe <wakeup>
  release(&tickslock);
    800027dc:	8526                	mv	a0,s1
    800027de:	ffffe097          	auipc	ra,0xffffe
    800027e2:	566080e7          	jalr	1382(ra) # 80000d44 <release>
}
    800027e6:	60e2                	ld	ra,24(sp)
    800027e8:	6442                	ld	s0,16(sp)
    800027ea:	64a2                	ld	s1,8(sp)
    800027ec:	6105                	addi	sp,sp,32
    800027ee:	8082                	ret

00000000800027f0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027f0:	1101                	addi	sp,sp,-32
    800027f2:	ec06                	sd	ra,24(sp)
    800027f4:	e822                	sd	s0,16(sp)
    800027f6:	e426                	sd	s1,8(sp)
    800027f8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027fa:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027fe:	00074d63          	bltz	a4,80002818 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002802:	57fd                	li	a5,-1
    80002804:	17fe                	slli	a5,a5,0x3f
    80002806:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002808:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000280a:	06f70363          	beq	a4,a5,80002870 <devintr+0x80>
  }
}
    8000280e:	60e2                	ld	ra,24(sp)
    80002810:	6442                	ld	s0,16(sp)
    80002812:	64a2                	ld	s1,8(sp)
    80002814:	6105                	addi	sp,sp,32
    80002816:	8082                	ret
     (scause & 0xff) == 9){
    80002818:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000281c:	46a5                	li	a3,9
    8000281e:	fed792e3          	bne	a5,a3,80002802 <devintr+0x12>
    int irq = plic_claim();
    80002822:	00003097          	auipc	ra,0x3
    80002826:	746080e7          	jalr	1862(ra) # 80005f68 <plic_claim>
    8000282a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000282c:	47a9                	li	a5,10
    8000282e:	02f50763          	beq	a0,a5,8000285c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002832:	4785                	li	a5,1
    80002834:	02f50963          	beq	a0,a5,80002866 <devintr+0x76>
    return 1;
    80002838:	4505                	li	a0,1
    } else if(irq){
    8000283a:	d8f1                	beqz	s1,8000280e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000283c:	85a6                	mv	a1,s1
    8000283e:	00006517          	auipc	a0,0x6
    80002842:	ab250513          	addi	a0,a0,-1358 # 800082f0 <states.0+0x30>
    80002846:	ffffe097          	auipc	ra,0xffffe
    8000284a:	d46080e7          	jalr	-698(ra) # 8000058c <printf>
      plic_complete(irq);
    8000284e:	8526                	mv	a0,s1
    80002850:	00003097          	auipc	ra,0x3
    80002854:	73c080e7          	jalr	1852(ra) # 80005f8c <plic_complete>
    return 1;
    80002858:	4505                	li	a0,1
    8000285a:	bf55                	j	8000280e <devintr+0x1e>
      uartintr();
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	1d2080e7          	jalr	466(ra) # 80000a2e <uartintr>
    80002864:	b7ed                	j	8000284e <devintr+0x5e>
      virtio_disk_intr();
    80002866:	00004097          	auipc	ra,0x4
    8000286a:	ba0080e7          	jalr	-1120(ra) # 80006406 <virtio_disk_intr>
    8000286e:	b7c5                	j	8000284e <devintr+0x5e>
    if(cpuid() == 0){
    80002870:	fffff097          	auipc	ra,0xfffff
    80002874:	1c0080e7          	jalr	448(ra) # 80001a30 <cpuid>
    80002878:	c901                	beqz	a0,80002888 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000287a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000287e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002880:	14479073          	csrw	sip,a5
    return 2;
    80002884:	4509                	li	a0,2
    80002886:	b761                	j	8000280e <devintr+0x1e>
      clockintr();
    80002888:	00000097          	auipc	ra,0x0
    8000288c:	f22080e7          	jalr	-222(ra) # 800027aa <clockintr>
    80002890:	b7ed                	j	8000287a <devintr+0x8a>

0000000080002892 <kerneltrap>:
{
    80002892:	7179                	addi	sp,sp,-48
    80002894:	f406                	sd	ra,40(sp)
    80002896:	f022                	sd	s0,32(sp)
    80002898:	ec26                	sd	s1,24(sp)
    8000289a:	e84a                	sd	s2,16(sp)
    8000289c:	e44e                	sd	s3,8(sp)
    8000289e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028a0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028a4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028a8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028ac:	1004f793          	andi	a5,s1,256
    800028b0:	cb85                	beqz	a5,800028e0 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028b2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028b6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028b8:	ef85                	bnez	a5,800028f0 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800028ba:	00000097          	auipc	ra,0x0
    800028be:	f36080e7          	jalr	-202(ra) # 800027f0 <devintr>
    800028c2:	cd1d                	beqz	a0,80002900 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800028c4:	4789                	li	a5,2
    800028c6:	06f50a63          	beq	a0,a5,8000293a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028ca:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028ce:	10049073          	csrw	sstatus,s1
}
    800028d2:	70a2                	ld	ra,40(sp)
    800028d4:	7402                	ld	s0,32(sp)
    800028d6:	64e2                	ld	s1,24(sp)
    800028d8:	6942                	ld	s2,16(sp)
    800028da:	69a2                	ld	s3,8(sp)
    800028dc:	6145                	addi	sp,sp,48
    800028de:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028e0:	00006517          	auipc	a0,0x6
    800028e4:	a3050513          	addi	a0,a0,-1488 # 80008310 <states.0+0x50>
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	c5a080e7          	jalr	-934(ra) # 80000542 <panic>
    panic("kerneltrap: interrupts enabled");
    800028f0:	00006517          	auipc	a0,0x6
    800028f4:	a4850513          	addi	a0,a0,-1464 # 80008338 <states.0+0x78>
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	c4a080e7          	jalr	-950(ra) # 80000542 <panic>
    printf("scause %p\n", scause);
    80002900:	85ce                	mv	a1,s3
    80002902:	00006517          	auipc	a0,0x6
    80002906:	a5650513          	addi	a0,a0,-1450 # 80008358 <states.0+0x98>
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	c82080e7          	jalr	-894(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002912:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002916:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000291a:	00006517          	auipc	a0,0x6
    8000291e:	a4e50513          	addi	a0,a0,-1458 # 80008368 <states.0+0xa8>
    80002922:	ffffe097          	auipc	ra,0xffffe
    80002926:	c6a080e7          	jalr	-918(ra) # 8000058c <printf>
    panic("kerneltrap");
    8000292a:	00006517          	auipc	a0,0x6
    8000292e:	a5650513          	addi	a0,a0,-1450 # 80008380 <states.0+0xc0>
    80002932:	ffffe097          	auipc	ra,0xffffe
    80002936:	c10080e7          	jalr	-1008(ra) # 80000542 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000293a:	fffff097          	auipc	ra,0xfffff
    8000293e:	122080e7          	jalr	290(ra) # 80001a5c <myproc>
    80002942:	d541                	beqz	a0,800028ca <kerneltrap+0x38>
    80002944:	fffff097          	auipc	ra,0xfffff
    80002948:	118080e7          	jalr	280(ra) # 80001a5c <myproc>
    8000294c:	4d18                	lw	a4,24(a0)
    8000294e:	478d                	li	a5,3
    80002950:	f6f71de3          	bne	a4,a5,800028ca <kerneltrap+0x38>
    yield();
    80002954:	00000097          	auipc	ra,0x0
    80002958:	8ee080e7          	jalr	-1810(ra) # 80002242 <yield>
    8000295c:	b7bd                	j	800028ca <kerneltrap+0x38>

000000008000295e <switchTrapframe>:
void switchTrapframe(struct trapframe* trapframe,struct trapframe* trapframeSave){
    8000295e:	1141                	addi	sp,sp,-16
    80002960:	e422                	sd	s0,8(sp)
    80002962:	0800                	addi	s0,sp,16
trapframe->kernel_satp = trapframeSave ->kernel_satp ;
    80002964:	619c                	ld	a5,0(a1)
    80002966:	e11c                	sd	a5,0(a0)
trapframe->kernel_sp = trapframeSave ->kernel_sp;
    80002968:	659c                	ld	a5,8(a1)
    8000296a:	e51c                	sd	a5,8(a0)
trapframe->epc = trapframeSave ->epc;
    8000296c:	6d9c                	ld	a5,24(a1)
    8000296e:	ed1c                	sd	a5,24(a0)
trapframe->kernel_hartid = trapframeSave->kernel_hartid;
    80002970:	719c                	ld	a5,32(a1)
    80002972:	f11c                	sd	a5,32(a0)
trapframe->ra = trapframeSave->ra;
    80002974:	759c                	ld	a5,40(a1)
    80002976:	f51c                	sd	a5,40(a0)
trapframe->sp = trapframeSave->sp;
    80002978:	799c                	ld	a5,48(a1)
    8000297a:	f91c                	sd	a5,48(a0)
trapframe->gp = trapframeSave->gp;
    8000297c:	7d9c                	ld	a5,56(a1)
    8000297e:	fd1c                	sd	a5,56(a0)
trapframe->tp = trapframeSave->tp;
    80002980:	61bc                	ld	a5,64(a1)
    80002982:	e13c                	sd	a5,64(a0)
trapframe->t0 = trapframeSave->t0;
    80002984:	65bc                	ld	a5,72(a1)
    80002986:	e53c                	sd	a5,72(a0)
trapframe->t1 = trapframeSave->t1;
    80002988:	69bc                	ld	a5,80(a1)
    8000298a:	e93c                	sd	a5,80(a0)
trapframe->t2 = trapframeSave->t2;
    8000298c:	6dbc                	ld	a5,88(a1)
    8000298e:	ed3c                	sd	a5,88(a0)
trapframe->s0 = trapframeSave->s0;
    80002990:	71bc                	ld	a5,96(a1)
    80002992:	f13c                	sd	a5,96(a0)
trapframe->s1 = trapframeSave->s1;
    80002994:	75bc                	ld	a5,104(a1)
    80002996:	f53c                	sd	a5,104(a0)
trapframe->a0 = trapframeSave->a0;
    80002998:	79bc                	ld	a5,112(a1)
    8000299a:	f93c                	sd	a5,112(a0)
trapframe->a1 = trapframeSave->a1;
    8000299c:	7dbc                	ld	a5,120(a1)
    8000299e:	fd3c                	sd	a5,120(a0)
trapframe->a2 = trapframeSave->a2;
    800029a0:	61dc                	ld	a5,128(a1)
    800029a2:	e15c                	sd	a5,128(a0)
trapframe->a3 = trapframeSave->a3;
    800029a4:	65dc                	ld	a5,136(a1)
    800029a6:	e55c                	sd	a5,136(a0)
trapframe->a4 = trapframeSave->a4;
    800029a8:	69dc                	ld	a5,144(a1)
    800029aa:	e95c                	sd	a5,144(a0)
trapframe->a5 = trapframeSave->a5;
    800029ac:	6ddc                	ld	a5,152(a1)
    800029ae:	ed5c                	sd	a5,152(a0)
trapframe->a6 = trapframeSave->a6;
    800029b0:	71dc                	ld	a5,160(a1)
    800029b2:	f15c                	sd	a5,160(a0)
trapframe->a7 = trapframeSave->a7;
    800029b4:	75dc                	ld	a5,168(a1)
    800029b6:	f55c                	sd	a5,168(a0)
trapframe->s2 = trapframeSave->s2;
    800029b8:	79dc                	ld	a5,176(a1)
    800029ba:	f95c                	sd	a5,176(a0)
trapframe->s3 = trapframeSave->s3;
    800029bc:	7ddc                	ld	a5,184(a1)
    800029be:	fd5c                	sd	a5,184(a0)
trapframe->s4 = trapframeSave->s4;
    800029c0:	61fc                	ld	a5,192(a1)
    800029c2:	e17c                	sd	a5,192(a0)
trapframe->s5 = trapframeSave->s5;
    800029c4:	65fc                	ld	a5,200(a1)
    800029c6:	e57c                	sd	a5,200(a0)
trapframe->s6 = trapframeSave->s6;
    800029c8:	69fc                	ld	a5,208(a1)
    800029ca:	e97c                	sd	a5,208(a0)
trapframe->s7 = trapframeSave->s7;
    800029cc:	6dfc                	ld	a5,216(a1)
    800029ce:	ed7c                	sd	a5,216(a0)
trapframe->s8 = trapframeSave->s8;
    800029d0:	71fc                	ld	a5,224(a1)
    800029d2:	f17c                	sd	a5,224(a0)
trapframe->s9 = trapframeSave->s9;
    800029d4:	75fc                	ld	a5,232(a1)
    800029d6:	f57c                	sd	a5,232(a0)
trapframe->s10 =trapframeSave->s10;
    800029d8:	79fc                	ld	a5,240(a1)
    800029da:	f97c                	sd	a5,240(a0)
trapframe->s11 =trapframeSave->s11;
    800029dc:	7dfc                	ld	a5,248(a1)
    800029de:	fd7c                	sd	a5,248(a0)
trapframe->t3 = trapframeSave->t3;
    800029e0:	1005b783          	ld	a5,256(a1) # 1100 <_entry-0x7fffef00>
    800029e4:	10f53023          	sd	a5,256(a0)
trapframe->t4 = trapframeSave->t4;
    800029e8:	1085b783          	ld	a5,264(a1)
    800029ec:	10f53423          	sd	a5,264(a0)
trapframe->t5 = trapframeSave->t5;
    800029f0:	1105b783          	ld	a5,272(a1)
    800029f4:	10f53823          	sd	a5,272(a0)
trapframe->t6 = trapframeSave->t6;
    800029f8:	1185b783          	ld	a5,280(a1)
    800029fc:	10f53c23          	sd	a5,280(a0)
}
    80002a00:	6422                	ld	s0,8(sp)
    80002a02:	0141                	addi	sp,sp,16
    80002a04:	8082                	ret

0000000080002a06 <usertrap>:
{
    80002a06:	1101                	addi	sp,sp,-32
    80002a08:	ec06                	sd	ra,24(sp)
    80002a0a:	e822                	sd	s0,16(sp)
    80002a0c:	e426                	sd	s1,8(sp)
    80002a0e:	e04a                	sd	s2,0(sp)
    80002a10:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a12:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a16:	1007f793          	andi	a5,a5,256
    80002a1a:	e3b5                	bnez	a5,80002a7e <usertrap+0x78>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a1c:	00003797          	auipc	a5,0x3
    80002a20:	44478793          	addi	a5,a5,1092 # 80005e60 <kernelvec>
    80002a24:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a28:	fffff097          	auipc	ra,0xfffff
    80002a2c:	034080e7          	jalr	52(ra) # 80001a5c <myproc>
    80002a30:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a32:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a34:	14102773          	csrr	a4,sepc
    80002a38:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a3a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a3e:	47a1                	li	a5,8
    80002a40:	04f71d63          	bne	a4,a5,80002a9a <usertrap+0x94>
    if(p->killed)
    80002a44:	591c                	lw	a5,48(a0)
    80002a46:	e7a1                	bnez	a5,80002a8e <usertrap+0x88>
    p->trapframe->epc += 4;
    80002a48:	6cb8                	ld	a4,88(s1)
    80002a4a:	6f1c                	ld	a5,24(a4)
    80002a4c:	0791                	addi	a5,a5,4
    80002a4e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a50:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a54:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a58:	10079073          	csrw	sstatus,a5
    syscall();
    80002a5c:	00000097          	auipc	ra,0x0
    80002a60:	26a080e7          	jalr	618(ra) # 80002cc6 <syscall>
  int which_dev = 0;
    80002a64:	4901                	li	s2,0
  if(p->killed)
    80002a66:	589c                	lw	a5,48(s1)
    80002a68:	e7f9                	bnez	a5,80002b36 <usertrap+0x130>
  usertrapret();
    80002a6a:	00000097          	auipc	ra,0x0
    80002a6e:	ca2080e7          	jalr	-862(ra) # 8000270c <usertrapret>
}
    80002a72:	60e2                	ld	ra,24(sp)
    80002a74:	6442                	ld	s0,16(sp)
    80002a76:	64a2                	ld	s1,8(sp)
    80002a78:	6902                	ld	s2,0(sp)
    80002a7a:	6105                	addi	sp,sp,32
    80002a7c:	8082                	ret
    panic("usertrap: not from user mode");
    80002a7e:	00006517          	auipc	a0,0x6
    80002a82:	91250513          	addi	a0,a0,-1774 # 80008390 <states.0+0xd0>
    80002a86:	ffffe097          	auipc	ra,0xffffe
    80002a8a:	abc080e7          	jalr	-1348(ra) # 80000542 <panic>
      exit(-1);
    80002a8e:	557d                	li	a0,-1
    80002a90:	fffff097          	auipc	ra,0xfffff
    80002a94:	6a8080e7          	jalr	1704(ra) # 80002138 <exit>
    80002a98:	bf45                	j	80002a48 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002a9a:	00000097          	auipc	ra,0x0
    80002a9e:	d56080e7          	jalr	-682(ra) # 800027f0 <devintr>
    80002aa2:	892a                	mv	s2,a0
    80002aa4:	c931                	beqz	a0,80002af8 <usertrap+0xf2>
      if(which_dev==2&& p->waitReturn==0){
    80002aa6:	4789                	li	a5,2
    80002aa8:	faf51fe3          	bne	a0,a5,80002a66 <usertrap+0x60>
    80002aac:	1a04a783          	lw	a5,416(s1)
    80002ab0:	eb99                	bnez	a5,80002ac6 <usertrap+0xc0>
        if(p->interval!=0){
    80002ab2:	1804b783          	ld	a5,384(s1)
    80002ab6:	cb81                	beqz	a5,80002ac6 <usertrap+0xc0>
         p->spend=p->spend+1;
    80002ab8:	1904b703          	ld	a4,400(s1)
    80002abc:	0705                	addi	a4,a4,1
    80002abe:	18e4b823          	sd	a4,400(s1)
         if(p->spend==p->interval){
    80002ac2:	00e78a63          	beq	a5,a4,80002ad6 <usertrap+0xd0>
  if(p->killed)
    80002ac6:	589c                	lw	a5,48(s1)
    80002ac8:	cfbd                	beqz	a5,80002b46 <usertrap+0x140>
    exit(-1);
    80002aca:	557d                	li	a0,-1
    80002acc:	fffff097          	auipc	ra,0xfffff
    80002ad0:	66c080e7          	jalr	1644(ra) # 80002138 <exit>
  if(which_dev == 2)
    80002ad4:	a88d                	j	80002b46 <usertrap+0x140>
          switchTrapframe(p->trapframeSave,p->trapframe);
    80002ad6:	6cac                	ld	a1,88(s1)
    80002ad8:	1984b503          	ld	a0,408(s1)
    80002adc:	00000097          	auipc	ra,0x0
    80002ae0:	e82080e7          	jalr	-382(ra) # 8000295e <switchTrapframe>
          p->spend=0;
    80002ae4:	1804b823          	sd	zero,400(s1)
          p->trapframe->epc=(uint64)p->handler;
    80002ae8:	6cbc                	ld	a5,88(s1)
    80002aea:	1884b703          	ld	a4,392(s1)
    80002aee:	ef98                	sd	a4,24(a5)
          p->waitReturn=1;
    80002af0:	4785                	li	a5,1
    80002af2:	1af4a023          	sw	a5,416(s1)
    80002af6:	bfc1                	j	80002ac6 <usertrap+0xc0>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002af8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002afc:	5c90                	lw	a2,56(s1)
    80002afe:	00006517          	auipc	a0,0x6
    80002b02:	8b250513          	addi	a0,a0,-1870 # 800083b0 <states.0+0xf0>
    80002b06:	ffffe097          	auipc	ra,0xffffe
    80002b0a:	a86080e7          	jalr	-1402(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b0e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b12:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b16:	00006517          	auipc	a0,0x6
    80002b1a:	8ca50513          	addi	a0,a0,-1846 # 800083e0 <states.0+0x120>
    80002b1e:	ffffe097          	auipc	ra,0xffffe
    80002b22:	a6e080e7          	jalr	-1426(ra) # 8000058c <printf>
    p->killed = 1;
    80002b26:	4785                	li	a5,1
    80002b28:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002b2a:	557d                	li	a0,-1
    80002b2c:	fffff097          	auipc	ra,0xfffff
    80002b30:	60c080e7          	jalr	1548(ra) # 80002138 <exit>
  if(which_dev == 2)
    80002b34:	bf1d                	j	80002a6a <usertrap+0x64>
    exit(-1);
    80002b36:	557d                	li	a0,-1
    80002b38:	fffff097          	auipc	ra,0xfffff
    80002b3c:	600080e7          	jalr	1536(ra) # 80002138 <exit>
  if(which_dev == 2)
    80002b40:	4789                	li	a5,2
    80002b42:	f2f914e3          	bne	s2,a5,80002a6a <usertrap+0x64>
    yield();
    80002b46:	fffff097          	auipc	ra,0xfffff
    80002b4a:	6fc080e7          	jalr	1788(ra) # 80002242 <yield>
    80002b4e:	bf31                	j	80002a6a <usertrap+0x64>

0000000080002b50 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b50:	1101                	addi	sp,sp,-32
    80002b52:	ec06                	sd	ra,24(sp)
    80002b54:	e822                	sd	s0,16(sp)
    80002b56:	e426                	sd	s1,8(sp)
    80002b58:	1000                	addi	s0,sp,32
    80002b5a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b5c:	fffff097          	auipc	ra,0xfffff
    80002b60:	f00080e7          	jalr	-256(ra) # 80001a5c <myproc>
  switch (n) {
    80002b64:	4795                	li	a5,5
    80002b66:	0497e163          	bltu	a5,s1,80002ba8 <argraw+0x58>
    80002b6a:	048a                	slli	s1,s1,0x2
    80002b6c:	00006717          	auipc	a4,0x6
    80002b70:	98470713          	addi	a4,a4,-1660 # 800084f0 <states.0+0x230>
    80002b74:	94ba                	add	s1,s1,a4
    80002b76:	409c                	lw	a5,0(s1)
    80002b78:	97ba                	add	a5,a5,a4
    80002b7a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b7c:	6d3c                	ld	a5,88(a0)
    80002b7e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b80:	60e2                	ld	ra,24(sp)
    80002b82:	6442                	ld	s0,16(sp)
    80002b84:	64a2                	ld	s1,8(sp)
    80002b86:	6105                	addi	sp,sp,32
    80002b88:	8082                	ret
    return p->trapframe->a1;
    80002b8a:	6d3c                	ld	a5,88(a0)
    80002b8c:	7fa8                	ld	a0,120(a5)
    80002b8e:	bfcd                	j	80002b80 <argraw+0x30>
    return p->trapframe->a2;
    80002b90:	6d3c                	ld	a5,88(a0)
    80002b92:	63c8                	ld	a0,128(a5)
    80002b94:	b7f5                	j	80002b80 <argraw+0x30>
    return p->trapframe->a3;
    80002b96:	6d3c                	ld	a5,88(a0)
    80002b98:	67c8                	ld	a0,136(a5)
    80002b9a:	b7dd                	j	80002b80 <argraw+0x30>
    return p->trapframe->a4;
    80002b9c:	6d3c                	ld	a5,88(a0)
    80002b9e:	6bc8                	ld	a0,144(a5)
    80002ba0:	b7c5                	j	80002b80 <argraw+0x30>
    return p->trapframe->a5;
    80002ba2:	6d3c                	ld	a5,88(a0)
    80002ba4:	6fc8                	ld	a0,152(a5)
    80002ba6:	bfe9                	j	80002b80 <argraw+0x30>
  panic("argraw");
    80002ba8:	00006517          	auipc	a0,0x6
    80002bac:	85850513          	addi	a0,a0,-1960 # 80008400 <states.0+0x140>
    80002bb0:	ffffe097          	auipc	ra,0xffffe
    80002bb4:	992080e7          	jalr	-1646(ra) # 80000542 <panic>

0000000080002bb8 <fetchaddr>:
{
    80002bb8:	1101                	addi	sp,sp,-32
    80002bba:	ec06                	sd	ra,24(sp)
    80002bbc:	e822                	sd	s0,16(sp)
    80002bbe:	e426                	sd	s1,8(sp)
    80002bc0:	e04a                	sd	s2,0(sp)
    80002bc2:	1000                	addi	s0,sp,32
    80002bc4:	84aa                	mv	s1,a0
    80002bc6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002bc8:	fffff097          	auipc	ra,0xfffff
    80002bcc:	e94080e7          	jalr	-364(ra) # 80001a5c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002bd0:	653c                	ld	a5,72(a0)
    80002bd2:	02f4f863          	bgeu	s1,a5,80002c02 <fetchaddr+0x4a>
    80002bd6:	00848713          	addi	a4,s1,8
    80002bda:	02e7e663          	bltu	a5,a4,80002c06 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002bde:	46a1                	li	a3,8
    80002be0:	8626                	mv	a2,s1
    80002be2:	85ca                	mv	a1,s2
    80002be4:	6928                	ld	a0,80(a0)
    80002be6:	fffff097          	auipc	ra,0xfffff
    80002bea:	bf4080e7          	jalr	-1036(ra) # 800017da <copyin>
    80002bee:	00a03533          	snez	a0,a0
    80002bf2:	40a00533          	neg	a0,a0
}
    80002bf6:	60e2                	ld	ra,24(sp)
    80002bf8:	6442                	ld	s0,16(sp)
    80002bfa:	64a2                	ld	s1,8(sp)
    80002bfc:	6902                	ld	s2,0(sp)
    80002bfe:	6105                	addi	sp,sp,32
    80002c00:	8082                	ret
    return -1;
    80002c02:	557d                	li	a0,-1
    80002c04:	bfcd                	j	80002bf6 <fetchaddr+0x3e>
    80002c06:	557d                	li	a0,-1
    80002c08:	b7fd                	j	80002bf6 <fetchaddr+0x3e>

0000000080002c0a <fetchstr>:
{
    80002c0a:	7179                	addi	sp,sp,-48
    80002c0c:	f406                	sd	ra,40(sp)
    80002c0e:	f022                	sd	s0,32(sp)
    80002c10:	ec26                	sd	s1,24(sp)
    80002c12:	e84a                	sd	s2,16(sp)
    80002c14:	e44e                	sd	s3,8(sp)
    80002c16:	1800                	addi	s0,sp,48
    80002c18:	892a                	mv	s2,a0
    80002c1a:	84ae                	mv	s1,a1
    80002c1c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c1e:	fffff097          	auipc	ra,0xfffff
    80002c22:	e3e080e7          	jalr	-450(ra) # 80001a5c <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002c26:	86ce                	mv	a3,s3
    80002c28:	864a                	mv	a2,s2
    80002c2a:	85a6                	mv	a1,s1
    80002c2c:	6928                	ld	a0,80(a0)
    80002c2e:	fffff097          	auipc	ra,0xfffff
    80002c32:	c3a080e7          	jalr	-966(ra) # 80001868 <copyinstr>
  if(err < 0)
    80002c36:	00054763          	bltz	a0,80002c44 <fetchstr+0x3a>
  return strlen(buf);
    80002c3a:	8526                	mv	a0,s1
    80002c3c:	ffffe097          	auipc	ra,0xffffe
    80002c40:	2d4080e7          	jalr	724(ra) # 80000f10 <strlen>
}
    80002c44:	70a2                	ld	ra,40(sp)
    80002c46:	7402                	ld	s0,32(sp)
    80002c48:	64e2                	ld	s1,24(sp)
    80002c4a:	6942                	ld	s2,16(sp)
    80002c4c:	69a2                	ld	s3,8(sp)
    80002c4e:	6145                	addi	sp,sp,48
    80002c50:	8082                	ret

0000000080002c52 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002c52:	1101                	addi	sp,sp,-32
    80002c54:	ec06                	sd	ra,24(sp)
    80002c56:	e822                	sd	s0,16(sp)
    80002c58:	e426                	sd	s1,8(sp)
    80002c5a:	1000                	addi	s0,sp,32
    80002c5c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c5e:	00000097          	auipc	ra,0x0
    80002c62:	ef2080e7          	jalr	-270(ra) # 80002b50 <argraw>
    80002c66:	c088                	sw	a0,0(s1)
  return 0;
}
    80002c68:	4501                	li	a0,0
    80002c6a:	60e2                	ld	ra,24(sp)
    80002c6c:	6442                	ld	s0,16(sp)
    80002c6e:	64a2                	ld	s1,8(sp)
    80002c70:	6105                	addi	sp,sp,32
    80002c72:	8082                	ret

0000000080002c74 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002c74:	1101                	addi	sp,sp,-32
    80002c76:	ec06                	sd	ra,24(sp)
    80002c78:	e822                	sd	s0,16(sp)
    80002c7a:	e426                	sd	s1,8(sp)
    80002c7c:	1000                	addi	s0,sp,32
    80002c7e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c80:	00000097          	auipc	ra,0x0
    80002c84:	ed0080e7          	jalr	-304(ra) # 80002b50 <argraw>
    80002c88:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c8a:	4501                	li	a0,0
    80002c8c:	60e2                	ld	ra,24(sp)
    80002c8e:	6442                	ld	s0,16(sp)
    80002c90:	64a2                	ld	s1,8(sp)
    80002c92:	6105                	addi	sp,sp,32
    80002c94:	8082                	ret

0000000080002c96 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c96:	1101                	addi	sp,sp,-32
    80002c98:	ec06                	sd	ra,24(sp)
    80002c9a:	e822                	sd	s0,16(sp)
    80002c9c:	e426                	sd	s1,8(sp)
    80002c9e:	e04a                	sd	s2,0(sp)
    80002ca0:	1000                	addi	s0,sp,32
    80002ca2:	84ae                	mv	s1,a1
    80002ca4:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002ca6:	00000097          	auipc	ra,0x0
    80002caa:	eaa080e7          	jalr	-342(ra) # 80002b50 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002cae:	864a                	mv	a2,s2
    80002cb0:	85a6                	mv	a1,s1
    80002cb2:	00000097          	auipc	ra,0x0
    80002cb6:	f58080e7          	jalr	-168(ra) # 80002c0a <fetchstr>
}
    80002cba:	60e2                	ld	ra,24(sp)
    80002cbc:	6442                	ld	s0,16(sp)
    80002cbe:	64a2                	ld	s1,8(sp)
    80002cc0:	6902                	ld	s2,0(sp)
    80002cc2:	6105                	addi	sp,sp,32
    80002cc4:	8082                	ret

0000000080002cc6 <syscall>:
[SYS_sigreturn] sys_sigreturn,
};

void
syscall(void)
{
    80002cc6:	7179                	addi	sp,sp,-48
    80002cc8:	f406                	sd	ra,40(sp)
    80002cca:	f022                	sd	s0,32(sp)
    80002ccc:	ec26                	sd	s1,24(sp)
    80002cce:	e84a                	sd	s2,16(sp)
    80002cd0:	e44e                	sd	s3,8(sp)
    80002cd2:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002cd4:	fffff097          	auipc	ra,0xfffff
    80002cd8:	d88080e7          	jalr	-632(ra) # 80001a5c <myproc>
    80002cdc:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002cde:	05853903          	ld	s2,88(a0)
    80002ce2:	0a893783          	ld	a5,168(s2)
    80002ce6:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002cea:	37fd                	addiw	a5,a5,-1
    80002cec:	4761                	li	a4,24
    80002cee:	06f76263          	bltu	a4,a5,80002d52 <syscall+0x8c>
    80002cf2:	00399713          	slli	a4,s3,0x3
    80002cf6:	00006797          	auipc	a5,0x6
    80002cfa:	81278793          	addi	a5,a5,-2030 # 80008508 <syscalls>
    80002cfe:	97ba                	add	a5,a5,a4
    80002d00:	639c                	ld	a5,0(a5)
    80002d02:	cba1                	beqz	a5,80002d52 <syscall+0x8c>
    p->trapframe->a0 = syscalls[num]();
    80002d04:	9782                	jalr	a5
    80002d06:	06a93823          	sd	a0,112(s2)
    if(strlen(p->mask)>0 && p->mask[num]=='1'){
    80002d0a:	16848513          	addi	a0,s1,360
    80002d0e:	ffffe097          	auipc	ra,0xffffe
    80002d12:	202080e7          	jalr	514(ra) # 80000f10 <strlen>
    80002d16:	04a05d63          	blez	a0,80002d70 <syscall+0xaa>
    80002d1a:	013487b3          	add	a5,s1,s3
    80002d1e:	1687c703          	lbu	a4,360(a5)
    80002d22:	03100793          	li	a5,49
    80002d26:	04f71563          	bne	a4,a5,80002d70 <syscall+0xaa>
      printf("%d: syscall %s -> %d\n",
    80002d2a:	6cb8                	ld	a4,88(s1)
    80002d2c:	098e                	slli	s3,s3,0x3
    80002d2e:	00005797          	auipc	a5,0x5
    80002d32:	7da78793          	addi	a5,a5,2010 # 80008508 <syscalls>
    80002d36:	99be                	add	s3,s3,a5
    80002d38:	7b34                	ld	a3,112(a4)
    80002d3a:	0d09b603          	ld	a2,208(s3)
    80002d3e:	5c8c                	lw	a1,56(s1)
    80002d40:	00005517          	auipc	a0,0x5
    80002d44:	6c850513          	addi	a0,a0,1736 # 80008408 <states.0+0x148>
    80002d48:	ffffe097          	auipc	ra,0xffffe
    80002d4c:	844080e7          	jalr	-1980(ra) # 8000058c <printf>
    80002d50:	a005                	j	80002d70 <syscall+0xaa>
      p->pid, syscall_names[num], p->trapframe->a0);
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d52:	86ce                	mv	a3,s3
    80002d54:	15848613          	addi	a2,s1,344
    80002d58:	5c8c                	lw	a1,56(s1)
    80002d5a:	00005517          	auipc	a0,0x5
    80002d5e:	6c650513          	addi	a0,a0,1734 # 80008420 <states.0+0x160>
    80002d62:	ffffe097          	auipc	ra,0xffffe
    80002d66:	82a080e7          	jalr	-2006(ra) # 8000058c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d6a:	6cbc                	ld	a5,88(s1)
    80002d6c:	577d                	li	a4,-1
    80002d6e:	fbb8                	sd	a4,112(a5)
  }
}
    80002d70:	70a2                	ld	ra,40(sp)
    80002d72:	7402                	ld	s0,32(sp)
    80002d74:	64e2                	ld	s1,24(sp)
    80002d76:	6942                	ld	s2,16(sp)
    80002d78:	69a2                	ld	s3,8(sp)
    80002d7a:	6145                	addi	sp,sp,48
    80002d7c:	8082                	ret

0000000080002d7e <sys_exit>:
#include "proc.h"
#include "sysinfo.h"

uint64
sys_exit(void)
{
    80002d7e:	1101                	addi	sp,sp,-32
    80002d80:	ec06                	sd	ra,24(sp)
    80002d82:	e822                	sd	s0,16(sp)
    80002d84:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002d86:	fec40593          	addi	a1,s0,-20
    80002d8a:	4501                	li	a0,0
    80002d8c:	00000097          	auipc	ra,0x0
    80002d90:	ec6080e7          	jalr	-314(ra) # 80002c52 <argint>
    return -1;
    80002d94:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d96:	00054963          	bltz	a0,80002da8 <sys_exit+0x2a>
  exit(n);
    80002d9a:	fec42503          	lw	a0,-20(s0)
    80002d9e:	fffff097          	auipc	ra,0xfffff
    80002da2:	39a080e7          	jalr	922(ra) # 80002138 <exit>
  return 0;  // not reached
    80002da6:	4781                	li	a5,0
}
    80002da8:	853e                	mv	a0,a5
    80002daa:	60e2                	ld	ra,24(sp)
    80002dac:	6442                	ld	s0,16(sp)
    80002dae:	6105                	addi	sp,sp,32
    80002db0:	8082                	ret

0000000080002db2 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002db2:	1141                	addi	sp,sp,-16
    80002db4:	e406                	sd	ra,8(sp)
    80002db6:	e022                	sd	s0,0(sp)
    80002db8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002dba:	fffff097          	auipc	ra,0xfffff
    80002dbe:	ca2080e7          	jalr	-862(ra) # 80001a5c <myproc>
}
    80002dc2:	5d08                	lw	a0,56(a0)
    80002dc4:	60a2                	ld	ra,8(sp)
    80002dc6:	6402                	ld	s0,0(sp)
    80002dc8:	0141                	addi	sp,sp,16
    80002dca:	8082                	ret

0000000080002dcc <sys_fork>:

uint64
sys_fork(void)
{
    80002dcc:	1141                	addi	sp,sp,-16
    80002dce:	e406                	sd	ra,8(sp)
    80002dd0:	e022                	sd	s0,0(sp)
    80002dd2:	0800                	addi	s0,sp,16
  return fork();
    80002dd4:	fffff097          	auipc	ra,0xfffff
    80002dd8:	048080e7          	jalr	72(ra) # 80001e1c <fork>
}
    80002ddc:	60a2                	ld	ra,8(sp)
    80002dde:	6402                	ld	s0,0(sp)
    80002de0:	0141                	addi	sp,sp,16
    80002de2:	8082                	ret

0000000080002de4 <sys_wait>:

uint64
sys_wait(void)
{
    80002de4:	1101                	addi	sp,sp,-32
    80002de6:	ec06                	sd	ra,24(sp)
    80002de8:	e822                	sd	s0,16(sp)
    80002dea:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002dec:	fe840593          	addi	a1,s0,-24
    80002df0:	4501                	li	a0,0
    80002df2:	00000097          	auipc	ra,0x0
    80002df6:	e82080e7          	jalr	-382(ra) # 80002c74 <argaddr>
    80002dfa:	87aa                	mv	a5,a0
    return -1;
    80002dfc:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002dfe:	0007c863          	bltz	a5,80002e0e <sys_wait+0x2a>
  return wait(p);
    80002e02:	fe843503          	ld	a0,-24(s0)
    80002e06:	fffff097          	auipc	ra,0xfffff
    80002e0a:	4f6080e7          	jalr	1270(ra) # 800022fc <wait>
}
    80002e0e:	60e2                	ld	ra,24(sp)
    80002e10:	6442                	ld	s0,16(sp)
    80002e12:	6105                	addi	sp,sp,32
    80002e14:	8082                	ret

0000000080002e16 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e16:	7179                	addi	sp,sp,-48
    80002e18:	f406                	sd	ra,40(sp)
    80002e1a:	f022                	sd	s0,32(sp)
    80002e1c:	ec26                	sd	s1,24(sp)
    80002e1e:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002e20:	fdc40593          	addi	a1,s0,-36
    80002e24:	4501                	li	a0,0
    80002e26:	00000097          	auipc	ra,0x0
    80002e2a:	e2c080e7          	jalr	-468(ra) # 80002c52 <argint>
    return -1;
    80002e2e:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002e30:	00054f63          	bltz	a0,80002e4e <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002e34:	fffff097          	auipc	ra,0xfffff
    80002e38:	c28080e7          	jalr	-984(ra) # 80001a5c <myproc>
    80002e3c:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002e3e:	fdc42503          	lw	a0,-36(s0)
    80002e42:	fffff097          	auipc	ra,0xfffff
    80002e46:	f66080e7          	jalr	-154(ra) # 80001da8 <growproc>
    80002e4a:	00054863          	bltz	a0,80002e5a <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002e4e:	8526                	mv	a0,s1
    80002e50:	70a2                	ld	ra,40(sp)
    80002e52:	7402                	ld	s0,32(sp)
    80002e54:	64e2                	ld	s1,24(sp)
    80002e56:	6145                	addi	sp,sp,48
    80002e58:	8082                	ret
    return -1;
    80002e5a:	54fd                	li	s1,-1
    80002e5c:	bfcd                	j	80002e4e <sys_sbrk+0x38>

0000000080002e5e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e5e:	7139                	addi	sp,sp,-64
    80002e60:	fc06                	sd	ra,56(sp)
    80002e62:	f822                	sd	s0,48(sp)
    80002e64:	f426                	sd	s1,40(sp)
    80002e66:	f04a                	sd	s2,32(sp)
    80002e68:	ec4e                	sd	s3,24(sp)
    80002e6a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002e6c:	fcc40593          	addi	a1,s0,-52
    80002e70:	4501                	li	a0,0
    80002e72:	00000097          	auipc	ra,0x0
    80002e76:	de0080e7          	jalr	-544(ra) # 80002c52 <argint>
    return -1;
    80002e7a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e7c:	06054963          	bltz	a0,80002eee <sys_sleep+0x90>
  acquire(&tickslock);
    80002e80:	00016517          	auipc	a0,0x16
    80002e84:	8e850513          	addi	a0,a0,-1816 # 80018768 <tickslock>
    80002e88:	ffffe097          	auipc	ra,0xffffe
    80002e8c:	e08080e7          	jalr	-504(ra) # 80000c90 <acquire>
  ticks0 = ticks;
    80002e90:	00006917          	auipc	s2,0x6
    80002e94:	19092903          	lw	s2,400(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002e98:	fcc42783          	lw	a5,-52(s0)
    80002e9c:	cf85                	beqz	a5,80002ed4 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e9e:	00016997          	auipc	s3,0x16
    80002ea2:	8ca98993          	addi	s3,s3,-1846 # 80018768 <tickslock>
    80002ea6:	00006497          	auipc	s1,0x6
    80002eaa:	17a48493          	addi	s1,s1,378 # 80009020 <ticks>
    if(myproc()->killed){
    80002eae:	fffff097          	auipc	ra,0xfffff
    80002eb2:	bae080e7          	jalr	-1106(ra) # 80001a5c <myproc>
    80002eb6:	591c                	lw	a5,48(a0)
    80002eb8:	e3b9                	bnez	a5,80002efe <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80002eba:	85ce                	mv	a1,s3
    80002ebc:	8526                	mv	a0,s1
    80002ebe:	fffff097          	auipc	ra,0xfffff
    80002ec2:	3c0080e7          	jalr	960(ra) # 8000227e <sleep>
  while(ticks - ticks0 < n){
    80002ec6:	409c                	lw	a5,0(s1)
    80002ec8:	412787bb          	subw	a5,a5,s2
    80002ecc:	fcc42703          	lw	a4,-52(s0)
    80002ed0:	fce7efe3          	bltu	a5,a4,80002eae <sys_sleep+0x50>
  }
  release(&tickslock);
    80002ed4:	00016517          	auipc	a0,0x16
    80002ed8:	89450513          	addi	a0,a0,-1900 # 80018768 <tickslock>
    80002edc:	ffffe097          	auipc	ra,0xffffe
    80002ee0:	e68080e7          	jalr	-408(ra) # 80000d44 <release>
  backtrace();
    80002ee4:	ffffe097          	auipc	ra,0xffffe
    80002ee8:	888080e7          	jalr	-1912(ra) # 8000076c <backtrace>
  return 0;
    80002eec:	4781                	li	a5,0
}
    80002eee:	853e                	mv	a0,a5
    80002ef0:	70e2                	ld	ra,56(sp)
    80002ef2:	7442                	ld	s0,48(sp)
    80002ef4:	74a2                	ld	s1,40(sp)
    80002ef6:	7902                	ld	s2,32(sp)
    80002ef8:	69e2                	ld	s3,24(sp)
    80002efa:	6121                	addi	sp,sp,64
    80002efc:	8082                	ret
      release(&tickslock);
    80002efe:	00016517          	auipc	a0,0x16
    80002f02:	86a50513          	addi	a0,a0,-1942 # 80018768 <tickslock>
    80002f06:	ffffe097          	auipc	ra,0xffffe
    80002f0a:	e3e080e7          	jalr	-450(ra) # 80000d44 <release>
      return -1;
    80002f0e:	57fd                	li	a5,-1
    80002f10:	bff9                	j	80002eee <sys_sleep+0x90>

0000000080002f12 <sys_kill>:

uint64
sys_kill(void)
{
    80002f12:	1101                	addi	sp,sp,-32
    80002f14:	ec06                	sd	ra,24(sp)
    80002f16:	e822                	sd	s0,16(sp)
    80002f18:	1000                	addi	s0,sp,32
  int pid;
  if(argint(0, &pid) < 0)
    80002f1a:	fec40593          	addi	a1,s0,-20
    80002f1e:	4501                	li	a0,0
    80002f20:	00000097          	auipc	ra,0x0
    80002f24:	d32080e7          	jalr	-718(ra) # 80002c52 <argint>
    80002f28:	87aa                	mv	a5,a0
    return -1;
    80002f2a:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002f2c:	0007c863          	bltz	a5,80002f3c <sys_kill+0x2a>
  return kill(pid);
    80002f30:	fec42503          	lw	a0,-20(s0)
    80002f34:	fffff097          	auipc	ra,0xfffff
    80002f38:	534080e7          	jalr	1332(ra) # 80002468 <kill>
}
    80002f3c:	60e2                	ld	ra,24(sp)
    80002f3e:	6442                	ld	s0,16(sp)
    80002f40:	6105                	addi	sp,sp,32
    80002f42:	8082                	ret

0000000080002f44 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f44:	1101                	addi	sp,sp,-32
    80002f46:	ec06                	sd	ra,24(sp)
    80002f48:	e822                	sd	s0,16(sp)
    80002f4a:	e426                	sd	s1,8(sp)
    80002f4c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f4e:	00016517          	auipc	a0,0x16
    80002f52:	81a50513          	addi	a0,a0,-2022 # 80018768 <tickslock>
    80002f56:	ffffe097          	auipc	ra,0xffffe
    80002f5a:	d3a080e7          	jalr	-710(ra) # 80000c90 <acquire>
  xticks = ticks;
    80002f5e:	00006497          	auipc	s1,0x6
    80002f62:	0c24a483          	lw	s1,194(s1) # 80009020 <ticks>
  release(&tickslock);
    80002f66:	00016517          	auipc	a0,0x16
    80002f6a:	80250513          	addi	a0,a0,-2046 # 80018768 <tickslock>
    80002f6e:	ffffe097          	auipc	ra,0xffffe
    80002f72:	dd6080e7          	jalr	-554(ra) # 80000d44 <release>
  return xticks;
}
    80002f76:	02049513          	slli	a0,s1,0x20
    80002f7a:	9101                	srli	a0,a0,0x20
    80002f7c:	60e2                	ld	ra,24(sp)
    80002f7e:	6442                	ld	s0,16(sp)
    80002f80:	64a2                	ld	s1,8(sp)
    80002f82:	6105                	addi	sp,sp,32
    80002f84:	8082                	ret

0000000080002f86 <sys_trace>:
uint64
sys_trace(void){
    80002f86:	1101                	addi	sp,sp,-32
    80002f88:	ec06                	sd	ra,24(sp)
    80002f8a:	e822                	sd	s0,16(sp)
    80002f8c:	1000                	addi	s0,sp,32
  int n;
  //argint()用于读取在a0-a5寄存器中传递的系统调用参数
  if(argint(0,&n)<0)
    80002f8e:	fec40593          	addi	a1,s0,-20
    80002f92:	4501                	li	a0,0
    80002f94:	00000097          	auipc	ra,0x0
    80002f98:	cbe080e7          	jalr	-834(ra) # 80002c52 <argint>
    return -1;
    80002f9c:	57fd                	li	a5,-1
  if(argint(0,&n)<0)
    80002f9e:	04054563          	bltz	a0,80002fe8 <sys_trace+0x62>
  struct proc *p =myproc();
    80002fa2:	fffff097          	auipc	ra,0xfffff
    80002fa6:	aba080e7          	jalr	-1350(ra) # 80001a5c <myproc>
  char *mask=p->mask;
  int i=0;
  while(i<24&&n>0)
    80002faa:	16850513          	addi	a0,a0,360
  struct proc *p =myproc();
    80002fae:	4705                	li	a4,1
    if(n%2)
    {
      mask[i++]='1';
    }else
    {
      mask[i++]='0';
    80002fb0:	03000593          	li	a1,48
      mask[i++]='1';
    80002fb4:	03100613          	li	a2,49
  while(i<24&&n>0)
    80002fb8:	46e5                	li	a3,25
    80002fba:	a829                	j	80002fd4 <sys_trace+0x4e>
      mask[i++]='0';
    80002fbc:	00b50023          	sb	a1,0(a0)
    }
    n>>=1;
    80002fc0:	fec42783          	lw	a5,-20(s0)
    80002fc4:	4017d79b          	sraiw	a5,a5,0x1
    80002fc8:	fef42623          	sw	a5,-20(s0)
  while(i<24&&n>0)
    80002fcc:	2705                	addiw	a4,a4,1
    80002fce:	0505                	addi	a0,a0,1
    80002fd0:	02d70163          	beq	a4,a3,80002ff2 <sys_trace+0x6c>
    80002fd4:	fec42783          	lw	a5,-20(s0)
    80002fd8:	00f05763          	blez	a5,80002fe6 <sys_trace+0x60>
    if(n%2)
    80002fdc:	8b85                	andi	a5,a5,1
    80002fde:	dff9                	beqz	a5,80002fbc <sys_trace+0x36>
      mask[i++]='1';
    80002fe0:	00c50023          	sb	a2,0(a0)
    80002fe4:	bff1                	j	80002fc0 <sys_trace+0x3a>
  }
  return 0;
    80002fe6:	4781                	li	a5,0
}
    80002fe8:	853e                	mv	a0,a5
    80002fea:	60e2                	ld	ra,24(sp)
    80002fec:	6442                	ld	s0,16(sp)
    80002fee:	6105                	addi	sp,sp,32
    80002ff0:	8082                	ret
  return 0;
    80002ff2:	4781                	li	a5,0
    80002ff4:	bfd5                	j	80002fe8 <sys_trace+0x62>

0000000080002ff6 <sys_sysinfo>:
uint64
sys_sysinfo(void)
{
    80002ff6:	7139                	addi	sp,sp,-64
    80002ff8:	fc06                	sd	ra,56(sp)
    80002ffa:	f822                	sd	s0,48(sp)
    80002ffc:	f426                	sd	s1,40(sp)
    80002ffe:	0080                	addi	s0,sp,64
  struct sysinfo info;
  uint64 addr;
  struct proc *p=myproc();
    80003000:	fffff097          	auipc	ra,0xfffff
    80003004:	a5c080e7          	jalr	-1444(ra) # 80001a5c <myproc>
    80003008:	84aa                	mv	s1,a0
  if(argaddr(0,&addr)<0){
    8000300a:	fc840593          	addi	a1,s0,-56
    8000300e:	4501                	li	a0,0
    80003010:	00000097          	auipc	ra,0x0
    80003014:	c64080e7          	jalr	-924(ra) # 80002c74 <argaddr>
    return -1;
    80003018:	57fd                	li	a5,-1
  if(argaddr(0,&addr)<0){
    8000301a:	02054a63          	bltz	a0,8000304e <sys_sysinfo+0x58>
  }
  info.freemem=freemem_size();
    8000301e:	ffffe097          	auipc	ra,0xffffe
    80003022:	bbc080e7          	jalr	-1092(ra) # 80000bda <freemem_size>
    80003026:	fca43823          	sd	a0,-48(s0)
  info.nproc=proc_num();
    8000302a:	fffff097          	auipc	ra,0xfffff
    8000302e:	608080e7          	jalr	1544(ra) # 80002632 <proc_num>
    80003032:	fca43c23          	sd	a0,-40(s0)
  if(copyout(p->pagetable,addr,(char *)&info,sizeof(info))<0){
    80003036:	46c1                	li	a3,16
    80003038:	fd040613          	addi	a2,s0,-48
    8000303c:	fc843583          	ld	a1,-56(s0)
    80003040:	68a8                	ld	a0,80(s1)
    80003042:	ffffe097          	auipc	ra,0xffffe
    80003046:	70c080e7          	jalr	1804(ra) # 8000174e <copyout>
    8000304a:	43f55793          	srai	a5,a0,0x3f
    return -1;
  }
  return 0;

}
    8000304e:	853e                	mv	a0,a5
    80003050:	70e2                	ld	ra,56(sp)
    80003052:	7442                	ld	s0,48(sp)
    80003054:	74a2                	ld	s1,40(sp)
    80003056:	6121                	addi	sp,sp,64
    80003058:	8082                	ret

000000008000305a <sys_sigalarm>:
uint64
sys_sigalarm(void)
{
    8000305a:	7179                	addi	sp,sp,-48
    8000305c:	f406                	sd	ra,40(sp)
    8000305e:	f022                	sd	s0,32(sp)
    80003060:	ec26                	sd	s1,24(sp)
    80003062:	1800                	addi	s0,sp,48
  struct proc*myProc=myproc();
    80003064:	fffff097          	auipc	ra,0xfffff
    80003068:	9f8080e7          	jalr	-1544(ra) # 80001a5c <myproc>
    8000306c:	84aa                	mv	s1,a0
  int n;
  uint64 handler;

  if(argint(0, &n) < 0)
    8000306e:	fdc40593          	addi	a1,s0,-36
    80003072:	4501                	li	a0,0
    80003074:	00000097          	auipc	ra,0x0
    80003078:	bde080e7          	jalr	-1058(ra) # 80002c52 <argint>
  return -1;
    8000307c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000307e:	02054463          	bltz	a0,800030a6 <sys_sigalarm+0x4c>
     myProc->interval=n;
    80003082:	fdc42783          	lw	a5,-36(s0)
    80003086:	18f4b023          	sd	a5,384(s1)
  if(argaddr(0, &handler) < 0)
    8000308a:	fd040593          	addi	a1,s0,-48
    8000308e:	4501                	li	a0,0
    80003090:	00000097          	auipc	ra,0x0
    80003094:	be4080e7          	jalr	-1052(ra) # 80002c74 <argaddr>
    80003098:	00054d63          	bltz	a0,800030b2 <sys_sigalarm+0x58>
  return -1;
    myProc->handler=(void(*)())handler;
    8000309c:	fd043783          	ld	a5,-48(s0)
    800030a0:	18f4b423          	sd	a5,392(s1)
    return 0;
    800030a4:	4781                	li	a5,0
}
    800030a6:	853e                	mv	a0,a5
    800030a8:	70a2                	ld	ra,40(sp)
    800030aa:	7402                	ld	s0,32(sp)
    800030ac:	64e2                	ld	s1,24(sp)
    800030ae:	6145                	addi	sp,sp,48
    800030b0:	8082                	ret
  return -1;
    800030b2:	57fd                	li	a5,-1
    800030b4:	bfcd                	j	800030a6 <sys_sigalarm+0x4c>

00000000800030b6 <sys_sigreturn>:
uint64
sys_sigreturn(void)
{
    800030b6:	1101                	addi	sp,sp,-32
    800030b8:	ec06                	sd	ra,24(sp)
    800030ba:	e822                	sd	s0,16(sp)
    800030bc:	e426                	sd	s1,8(sp)
    800030be:	1000                	addi	s0,sp,32
  struct proc*myProc=myproc();
    800030c0:	fffff097          	auipc	ra,0xfffff
    800030c4:	99c080e7          	jalr	-1636(ra) # 80001a5c <myproc>
    800030c8:	84aa                	mv	s1,a0
  switchTrapframe(myProc->trapframe,myProc->trapframeSave);
    800030ca:	19853583          	ld	a1,408(a0)
    800030ce:	6d28                	ld	a0,88(a0)
    800030d0:	00000097          	auipc	ra,0x0
    800030d4:	88e080e7          	jalr	-1906(ra) # 8000295e <switchTrapframe>
  myProc->waitReturn=0;
    800030d8:	1a04a023          	sw	zero,416(s1)
   return 0;
}
    800030dc:	4501                	li	a0,0
    800030de:	60e2                	ld	ra,24(sp)
    800030e0:	6442                	ld	s0,16(sp)
    800030e2:	64a2                	ld	s1,8(sp)
    800030e4:	6105                	addi	sp,sp,32
    800030e6:	8082                	ret

00000000800030e8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030e8:	7179                	addi	sp,sp,-48
    800030ea:	f406                	sd	ra,40(sp)
    800030ec:	f022                	sd	s0,32(sp)
    800030ee:	ec26                	sd	s1,24(sp)
    800030f0:	e84a                	sd	s2,16(sp)
    800030f2:	e44e                	sd	s3,8(sp)
    800030f4:	e052                	sd	s4,0(sp)
    800030f6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030f8:	00005597          	auipc	a1,0x5
    800030fc:	5a058593          	addi	a1,a1,1440 # 80008698 <syscall_names+0xc0>
    80003100:	00015517          	auipc	a0,0x15
    80003104:	68050513          	addi	a0,a0,1664 # 80018780 <bcache>
    80003108:	ffffe097          	auipc	ra,0xffffe
    8000310c:	af8080e7          	jalr	-1288(ra) # 80000c00 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003110:	0001d797          	auipc	a5,0x1d
    80003114:	67078793          	addi	a5,a5,1648 # 80020780 <bcache+0x8000>
    80003118:	0001e717          	auipc	a4,0x1e
    8000311c:	8d070713          	addi	a4,a4,-1840 # 800209e8 <bcache+0x8268>
    80003120:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003124:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003128:	00015497          	auipc	s1,0x15
    8000312c:	67048493          	addi	s1,s1,1648 # 80018798 <bcache+0x18>
    b->next = bcache.head.next;
    80003130:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003132:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003134:	00005a17          	auipc	s4,0x5
    80003138:	56ca0a13          	addi	s4,s4,1388 # 800086a0 <syscall_names+0xc8>
    b->next = bcache.head.next;
    8000313c:	2b893783          	ld	a5,696(s2)
    80003140:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003142:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003146:	85d2                	mv	a1,s4
    80003148:	01048513          	addi	a0,s1,16
    8000314c:	00001097          	auipc	ra,0x1
    80003150:	4ac080e7          	jalr	1196(ra) # 800045f8 <initsleeplock>
    bcache.head.next->prev = b;
    80003154:	2b893783          	ld	a5,696(s2)
    80003158:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000315a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000315e:	45848493          	addi	s1,s1,1112
    80003162:	fd349de3          	bne	s1,s3,8000313c <binit+0x54>
  }
}
    80003166:	70a2                	ld	ra,40(sp)
    80003168:	7402                	ld	s0,32(sp)
    8000316a:	64e2                	ld	s1,24(sp)
    8000316c:	6942                	ld	s2,16(sp)
    8000316e:	69a2                	ld	s3,8(sp)
    80003170:	6a02                	ld	s4,0(sp)
    80003172:	6145                	addi	sp,sp,48
    80003174:	8082                	ret

0000000080003176 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003176:	7179                	addi	sp,sp,-48
    80003178:	f406                	sd	ra,40(sp)
    8000317a:	f022                	sd	s0,32(sp)
    8000317c:	ec26                	sd	s1,24(sp)
    8000317e:	e84a                	sd	s2,16(sp)
    80003180:	e44e                	sd	s3,8(sp)
    80003182:	1800                	addi	s0,sp,48
    80003184:	892a                	mv	s2,a0
    80003186:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003188:	00015517          	auipc	a0,0x15
    8000318c:	5f850513          	addi	a0,a0,1528 # 80018780 <bcache>
    80003190:	ffffe097          	auipc	ra,0xffffe
    80003194:	b00080e7          	jalr	-1280(ra) # 80000c90 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003198:	0001e497          	auipc	s1,0x1e
    8000319c:	8a04b483          	ld	s1,-1888(s1) # 80020a38 <bcache+0x82b8>
    800031a0:	0001e797          	auipc	a5,0x1e
    800031a4:	84878793          	addi	a5,a5,-1976 # 800209e8 <bcache+0x8268>
    800031a8:	02f48f63          	beq	s1,a5,800031e6 <bread+0x70>
    800031ac:	873e                	mv	a4,a5
    800031ae:	a021                	j	800031b6 <bread+0x40>
    800031b0:	68a4                	ld	s1,80(s1)
    800031b2:	02e48a63          	beq	s1,a4,800031e6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031b6:	449c                	lw	a5,8(s1)
    800031b8:	ff279ce3          	bne	a5,s2,800031b0 <bread+0x3a>
    800031bc:	44dc                	lw	a5,12(s1)
    800031be:	ff3799e3          	bne	a5,s3,800031b0 <bread+0x3a>
      b->refcnt++;
    800031c2:	40bc                	lw	a5,64(s1)
    800031c4:	2785                	addiw	a5,a5,1
    800031c6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031c8:	00015517          	auipc	a0,0x15
    800031cc:	5b850513          	addi	a0,a0,1464 # 80018780 <bcache>
    800031d0:	ffffe097          	auipc	ra,0xffffe
    800031d4:	b74080e7          	jalr	-1164(ra) # 80000d44 <release>
      acquiresleep(&b->lock);
    800031d8:	01048513          	addi	a0,s1,16
    800031dc:	00001097          	auipc	ra,0x1
    800031e0:	456080e7          	jalr	1110(ra) # 80004632 <acquiresleep>
      return b;
    800031e4:	a8b9                	j	80003242 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031e6:	0001e497          	auipc	s1,0x1e
    800031ea:	84a4b483          	ld	s1,-1974(s1) # 80020a30 <bcache+0x82b0>
    800031ee:	0001d797          	auipc	a5,0x1d
    800031f2:	7fa78793          	addi	a5,a5,2042 # 800209e8 <bcache+0x8268>
    800031f6:	00f48863          	beq	s1,a5,80003206 <bread+0x90>
    800031fa:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031fc:	40bc                	lw	a5,64(s1)
    800031fe:	cf81                	beqz	a5,80003216 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003200:	64a4                	ld	s1,72(s1)
    80003202:	fee49de3          	bne	s1,a4,800031fc <bread+0x86>
  panic("bget: no buffers");
    80003206:	00005517          	auipc	a0,0x5
    8000320a:	4a250513          	addi	a0,a0,1186 # 800086a8 <syscall_names+0xd0>
    8000320e:	ffffd097          	auipc	ra,0xffffd
    80003212:	334080e7          	jalr	820(ra) # 80000542 <panic>
      b->dev = dev;
    80003216:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000321a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000321e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003222:	4785                	li	a5,1
    80003224:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003226:	00015517          	auipc	a0,0x15
    8000322a:	55a50513          	addi	a0,a0,1370 # 80018780 <bcache>
    8000322e:	ffffe097          	auipc	ra,0xffffe
    80003232:	b16080e7          	jalr	-1258(ra) # 80000d44 <release>
      acquiresleep(&b->lock);
    80003236:	01048513          	addi	a0,s1,16
    8000323a:	00001097          	auipc	ra,0x1
    8000323e:	3f8080e7          	jalr	1016(ra) # 80004632 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003242:	409c                	lw	a5,0(s1)
    80003244:	cb89                	beqz	a5,80003256 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003246:	8526                	mv	a0,s1
    80003248:	70a2                	ld	ra,40(sp)
    8000324a:	7402                	ld	s0,32(sp)
    8000324c:	64e2                	ld	s1,24(sp)
    8000324e:	6942                	ld	s2,16(sp)
    80003250:	69a2                	ld	s3,8(sp)
    80003252:	6145                	addi	sp,sp,48
    80003254:	8082                	ret
    virtio_disk_rw(b, 0);
    80003256:	4581                	li	a1,0
    80003258:	8526                	mv	a0,s1
    8000325a:	00003097          	auipc	ra,0x3
    8000325e:	f22080e7          	jalr	-222(ra) # 8000617c <virtio_disk_rw>
    b->valid = 1;
    80003262:	4785                	li	a5,1
    80003264:	c09c                	sw	a5,0(s1)
  return b;
    80003266:	b7c5                	j	80003246 <bread+0xd0>

0000000080003268 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003268:	1101                	addi	sp,sp,-32
    8000326a:	ec06                	sd	ra,24(sp)
    8000326c:	e822                	sd	s0,16(sp)
    8000326e:	e426                	sd	s1,8(sp)
    80003270:	1000                	addi	s0,sp,32
    80003272:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003274:	0541                	addi	a0,a0,16
    80003276:	00001097          	auipc	ra,0x1
    8000327a:	456080e7          	jalr	1110(ra) # 800046cc <holdingsleep>
    8000327e:	cd01                	beqz	a0,80003296 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003280:	4585                	li	a1,1
    80003282:	8526                	mv	a0,s1
    80003284:	00003097          	auipc	ra,0x3
    80003288:	ef8080e7          	jalr	-264(ra) # 8000617c <virtio_disk_rw>
}
    8000328c:	60e2                	ld	ra,24(sp)
    8000328e:	6442                	ld	s0,16(sp)
    80003290:	64a2                	ld	s1,8(sp)
    80003292:	6105                	addi	sp,sp,32
    80003294:	8082                	ret
    panic("bwrite");
    80003296:	00005517          	auipc	a0,0x5
    8000329a:	42a50513          	addi	a0,a0,1066 # 800086c0 <syscall_names+0xe8>
    8000329e:	ffffd097          	auipc	ra,0xffffd
    800032a2:	2a4080e7          	jalr	676(ra) # 80000542 <panic>

00000000800032a6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032a6:	1101                	addi	sp,sp,-32
    800032a8:	ec06                	sd	ra,24(sp)
    800032aa:	e822                	sd	s0,16(sp)
    800032ac:	e426                	sd	s1,8(sp)
    800032ae:	e04a                	sd	s2,0(sp)
    800032b0:	1000                	addi	s0,sp,32
    800032b2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032b4:	01050913          	addi	s2,a0,16
    800032b8:	854a                	mv	a0,s2
    800032ba:	00001097          	auipc	ra,0x1
    800032be:	412080e7          	jalr	1042(ra) # 800046cc <holdingsleep>
    800032c2:	c92d                	beqz	a0,80003334 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800032c4:	854a                	mv	a0,s2
    800032c6:	00001097          	auipc	ra,0x1
    800032ca:	3c2080e7          	jalr	962(ra) # 80004688 <releasesleep>

  acquire(&bcache.lock);
    800032ce:	00015517          	auipc	a0,0x15
    800032d2:	4b250513          	addi	a0,a0,1202 # 80018780 <bcache>
    800032d6:	ffffe097          	auipc	ra,0xffffe
    800032da:	9ba080e7          	jalr	-1606(ra) # 80000c90 <acquire>
  b->refcnt--;
    800032de:	40bc                	lw	a5,64(s1)
    800032e0:	37fd                	addiw	a5,a5,-1
    800032e2:	0007871b          	sext.w	a4,a5
    800032e6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800032e8:	eb05                	bnez	a4,80003318 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800032ea:	68bc                	ld	a5,80(s1)
    800032ec:	64b8                	ld	a4,72(s1)
    800032ee:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800032f0:	64bc                	ld	a5,72(s1)
    800032f2:	68b8                	ld	a4,80(s1)
    800032f4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800032f6:	0001d797          	auipc	a5,0x1d
    800032fa:	48a78793          	addi	a5,a5,1162 # 80020780 <bcache+0x8000>
    800032fe:	2b87b703          	ld	a4,696(a5)
    80003302:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003304:	0001d717          	auipc	a4,0x1d
    80003308:	6e470713          	addi	a4,a4,1764 # 800209e8 <bcache+0x8268>
    8000330c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000330e:	2b87b703          	ld	a4,696(a5)
    80003312:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003314:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003318:	00015517          	auipc	a0,0x15
    8000331c:	46850513          	addi	a0,a0,1128 # 80018780 <bcache>
    80003320:	ffffe097          	auipc	ra,0xffffe
    80003324:	a24080e7          	jalr	-1500(ra) # 80000d44 <release>
}
    80003328:	60e2                	ld	ra,24(sp)
    8000332a:	6442                	ld	s0,16(sp)
    8000332c:	64a2                	ld	s1,8(sp)
    8000332e:	6902                	ld	s2,0(sp)
    80003330:	6105                	addi	sp,sp,32
    80003332:	8082                	ret
    panic("brelse");
    80003334:	00005517          	auipc	a0,0x5
    80003338:	39450513          	addi	a0,a0,916 # 800086c8 <syscall_names+0xf0>
    8000333c:	ffffd097          	auipc	ra,0xffffd
    80003340:	206080e7          	jalr	518(ra) # 80000542 <panic>

0000000080003344 <bpin>:

void
bpin(struct buf *b) {
    80003344:	1101                	addi	sp,sp,-32
    80003346:	ec06                	sd	ra,24(sp)
    80003348:	e822                	sd	s0,16(sp)
    8000334a:	e426                	sd	s1,8(sp)
    8000334c:	1000                	addi	s0,sp,32
    8000334e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003350:	00015517          	auipc	a0,0x15
    80003354:	43050513          	addi	a0,a0,1072 # 80018780 <bcache>
    80003358:	ffffe097          	auipc	ra,0xffffe
    8000335c:	938080e7          	jalr	-1736(ra) # 80000c90 <acquire>
  b->refcnt++;
    80003360:	40bc                	lw	a5,64(s1)
    80003362:	2785                	addiw	a5,a5,1
    80003364:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003366:	00015517          	auipc	a0,0x15
    8000336a:	41a50513          	addi	a0,a0,1050 # 80018780 <bcache>
    8000336e:	ffffe097          	auipc	ra,0xffffe
    80003372:	9d6080e7          	jalr	-1578(ra) # 80000d44 <release>
}
    80003376:	60e2                	ld	ra,24(sp)
    80003378:	6442                	ld	s0,16(sp)
    8000337a:	64a2                	ld	s1,8(sp)
    8000337c:	6105                	addi	sp,sp,32
    8000337e:	8082                	ret

0000000080003380 <bunpin>:

void
bunpin(struct buf *b) {
    80003380:	1101                	addi	sp,sp,-32
    80003382:	ec06                	sd	ra,24(sp)
    80003384:	e822                	sd	s0,16(sp)
    80003386:	e426                	sd	s1,8(sp)
    80003388:	1000                	addi	s0,sp,32
    8000338a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000338c:	00015517          	auipc	a0,0x15
    80003390:	3f450513          	addi	a0,a0,1012 # 80018780 <bcache>
    80003394:	ffffe097          	auipc	ra,0xffffe
    80003398:	8fc080e7          	jalr	-1796(ra) # 80000c90 <acquire>
  b->refcnt--;
    8000339c:	40bc                	lw	a5,64(s1)
    8000339e:	37fd                	addiw	a5,a5,-1
    800033a0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033a2:	00015517          	auipc	a0,0x15
    800033a6:	3de50513          	addi	a0,a0,990 # 80018780 <bcache>
    800033aa:	ffffe097          	auipc	ra,0xffffe
    800033ae:	99a080e7          	jalr	-1638(ra) # 80000d44 <release>
}
    800033b2:	60e2                	ld	ra,24(sp)
    800033b4:	6442                	ld	s0,16(sp)
    800033b6:	64a2                	ld	s1,8(sp)
    800033b8:	6105                	addi	sp,sp,32
    800033ba:	8082                	ret

00000000800033bc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033bc:	1101                	addi	sp,sp,-32
    800033be:	ec06                	sd	ra,24(sp)
    800033c0:	e822                	sd	s0,16(sp)
    800033c2:	e426                	sd	s1,8(sp)
    800033c4:	e04a                	sd	s2,0(sp)
    800033c6:	1000                	addi	s0,sp,32
    800033c8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033ca:	00d5d59b          	srliw	a1,a1,0xd
    800033ce:	0001e797          	auipc	a5,0x1e
    800033d2:	a8e7a783          	lw	a5,-1394(a5) # 80020e5c <sb+0x1c>
    800033d6:	9dbd                	addw	a1,a1,a5
    800033d8:	00000097          	auipc	ra,0x0
    800033dc:	d9e080e7          	jalr	-610(ra) # 80003176 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033e0:	0074f713          	andi	a4,s1,7
    800033e4:	4785                	li	a5,1
    800033e6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800033ea:	14ce                	slli	s1,s1,0x33
    800033ec:	90d9                	srli	s1,s1,0x36
    800033ee:	00950733          	add	a4,a0,s1
    800033f2:	05874703          	lbu	a4,88(a4)
    800033f6:	00e7f6b3          	and	a3,a5,a4
    800033fa:	c69d                	beqz	a3,80003428 <bfree+0x6c>
    800033fc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033fe:	94aa                	add	s1,s1,a0
    80003400:	fff7c793          	not	a5,a5
    80003404:	8ff9                	and	a5,a5,a4
    80003406:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000340a:	00001097          	auipc	ra,0x1
    8000340e:	100080e7          	jalr	256(ra) # 8000450a <log_write>
  brelse(bp);
    80003412:	854a                	mv	a0,s2
    80003414:	00000097          	auipc	ra,0x0
    80003418:	e92080e7          	jalr	-366(ra) # 800032a6 <brelse>
}
    8000341c:	60e2                	ld	ra,24(sp)
    8000341e:	6442                	ld	s0,16(sp)
    80003420:	64a2                	ld	s1,8(sp)
    80003422:	6902                	ld	s2,0(sp)
    80003424:	6105                	addi	sp,sp,32
    80003426:	8082                	ret
    panic("freeing free block");
    80003428:	00005517          	auipc	a0,0x5
    8000342c:	2a850513          	addi	a0,a0,680 # 800086d0 <syscall_names+0xf8>
    80003430:	ffffd097          	auipc	ra,0xffffd
    80003434:	112080e7          	jalr	274(ra) # 80000542 <panic>

0000000080003438 <balloc>:
{
    80003438:	711d                	addi	sp,sp,-96
    8000343a:	ec86                	sd	ra,88(sp)
    8000343c:	e8a2                	sd	s0,80(sp)
    8000343e:	e4a6                	sd	s1,72(sp)
    80003440:	e0ca                	sd	s2,64(sp)
    80003442:	fc4e                	sd	s3,56(sp)
    80003444:	f852                	sd	s4,48(sp)
    80003446:	f456                	sd	s5,40(sp)
    80003448:	f05a                	sd	s6,32(sp)
    8000344a:	ec5e                	sd	s7,24(sp)
    8000344c:	e862                	sd	s8,16(sp)
    8000344e:	e466                	sd	s9,8(sp)
    80003450:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003452:	0001e797          	auipc	a5,0x1e
    80003456:	9f27a783          	lw	a5,-1550(a5) # 80020e44 <sb+0x4>
    8000345a:	cbd1                	beqz	a5,800034ee <balloc+0xb6>
    8000345c:	8baa                	mv	s7,a0
    8000345e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003460:	0001eb17          	auipc	s6,0x1e
    80003464:	9e0b0b13          	addi	s6,s6,-1568 # 80020e40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003468:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000346a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000346c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000346e:	6c89                	lui	s9,0x2
    80003470:	a831                	j	8000348c <balloc+0x54>
    brelse(bp);
    80003472:	854a                	mv	a0,s2
    80003474:	00000097          	auipc	ra,0x0
    80003478:	e32080e7          	jalr	-462(ra) # 800032a6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000347c:	015c87bb          	addw	a5,s9,s5
    80003480:	00078a9b          	sext.w	s5,a5
    80003484:	004b2703          	lw	a4,4(s6)
    80003488:	06eaf363          	bgeu	s5,a4,800034ee <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000348c:	41fad79b          	sraiw	a5,s5,0x1f
    80003490:	0137d79b          	srliw	a5,a5,0x13
    80003494:	015787bb          	addw	a5,a5,s5
    80003498:	40d7d79b          	sraiw	a5,a5,0xd
    8000349c:	01cb2583          	lw	a1,28(s6)
    800034a0:	9dbd                	addw	a1,a1,a5
    800034a2:	855e                	mv	a0,s7
    800034a4:	00000097          	auipc	ra,0x0
    800034a8:	cd2080e7          	jalr	-814(ra) # 80003176 <bread>
    800034ac:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ae:	004b2503          	lw	a0,4(s6)
    800034b2:	000a849b          	sext.w	s1,s5
    800034b6:	8662                	mv	a2,s8
    800034b8:	faa4fde3          	bgeu	s1,a0,80003472 <balloc+0x3a>
      m = 1 << (bi % 8);
    800034bc:	41f6579b          	sraiw	a5,a2,0x1f
    800034c0:	01d7d69b          	srliw	a3,a5,0x1d
    800034c4:	00c6873b          	addw	a4,a3,a2
    800034c8:	00777793          	andi	a5,a4,7
    800034cc:	9f95                	subw	a5,a5,a3
    800034ce:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034d2:	4037571b          	sraiw	a4,a4,0x3
    800034d6:	00e906b3          	add	a3,s2,a4
    800034da:	0586c683          	lbu	a3,88(a3)
    800034de:	00d7f5b3          	and	a1,a5,a3
    800034e2:	cd91                	beqz	a1,800034fe <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034e4:	2605                	addiw	a2,a2,1
    800034e6:	2485                	addiw	s1,s1,1
    800034e8:	fd4618e3          	bne	a2,s4,800034b8 <balloc+0x80>
    800034ec:	b759                	j	80003472 <balloc+0x3a>
  panic("balloc: out of blocks");
    800034ee:	00005517          	auipc	a0,0x5
    800034f2:	1fa50513          	addi	a0,a0,506 # 800086e8 <syscall_names+0x110>
    800034f6:	ffffd097          	auipc	ra,0xffffd
    800034fa:	04c080e7          	jalr	76(ra) # 80000542 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034fe:	974a                	add	a4,a4,s2
    80003500:	8fd5                	or	a5,a5,a3
    80003502:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003506:	854a                	mv	a0,s2
    80003508:	00001097          	auipc	ra,0x1
    8000350c:	002080e7          	jalr	2(ra) # 8000450a <log_write>
        brelse(bp);
    80003510:	854a                	mv	a0,s2
    80003512:	00000097          	auipc	ra,0x0
    80003516:	d94080e7          	jalr	-620(ra) # 800032a6 <brelse>
  bp = bread(dev, bno);
    8000351a:	85a6                	mv	a1,s1
    8000351c:	855e                	mv	a0,s7
    8000351e:	00000097          	auipc	ra,0x0
    80003522:	c58080e7          	jalr	-936(ra) # 80003176 <bread>
    80003526:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003528:	40000613          	li	a2,1024
    8000352c:	4581                	li	a1,0
    8000352e:	05850513          	addi	a0,a0,88
    80003532:	ffffe097          	auipc	ra,0xffffe
    80003536:	85a080e7          	jalr	-1958(ra) # 80000d8c <memset>
  log_write(bp);
    8000353a:	854a                	mv	a0,s2
    8000353c:	00001097          	auipc	ra,0x1
    80003540:	fce080e7          	jalr	-50(ra) # 8000450a <log_write>
  brelse(bp);
    80003544:	854a                	mv	a0,s2
    80003546:	00000097          	auipc	ra,0x0
    8000354a:	d60080e7          	jalr	-672(ra) # 800032a6 <brelse>
}
    8000354e:	8526                	mv	a0,s1
    80003550:	60e6                	ld	ra,88(sp)
    80003552:	6446                	ld	s0,80(sp)
    80003554:	64a6                	ld	s1,72(sp)
    80003556:	6906                	ld	s2,64(sp)
    80003558:	79e2                	ld	s3,56(sp)
    8000355a:	7a42                	ld	s4,48(sp)
    8000355c:	7aa2                	ld	s5,40(sp)
    8000355e:	7b02                	ld	s6,32(sp)
    80003560:	6be2                	ld	s7,24(sp)
    80003562:	6c42                	ld	s8,16(sp)
    80003564:	6ca2                	ld	s9,8(sp)
    80003566:	6125                	addi	sp,sp,96
    80003568:	8082                	ret

000000008000356a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000356a:	7179                	addi	sp,sp,-48
    8000356c:	f406                	sd	ra,40(sp)
    8000356e:	f022                	sd	s0,32(sp)
    80003570:	ec26                	sd	s1,24(sp)
    80003572:	e84a                	sd	s2,16(sp)
    80003574:	e44e                	sd	s3,8(sp)
    80003576:	e052                	sd	s4,0(sp)
    80003578:	1800                	addi	s0,sp,48
    8000357a:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000357c:	47ad                	li	a5,11
    8000357e:	04b7fe63          	bgeu	a5,a1,800035da <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003582:	ff45849b          	addiw	s1,a1,-12
    80003586:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000358a:	0ff00793          	li	a5,255
    8000358e:	0ae7e363          	bltu	a5,a4,80003634 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003592:	08052583          	lw	a1,128(a0)
    80003596:	c5ad                	beqz	a1,80003600 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003598:	00092503          	lw	a0,0(s2)
    8000359c:	00000097          	auipc	ra,0x0
    800035a0:	bda080e7          	jalr	-1062(ra) # 80003176 <bread>
    800035a4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035a6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800035aa:	02049593          	slli	a1,s1,0x20
    800035ae:	9181                	srli	a1,a1,0x20
    800035b0:	058a                	slli	a1,a1,0x2
    800035b2:	00b784b3          	add	s1,a5,a1
    800035b6:	0004a983          	lw	s3,0(s1)
    800035ba:	04098d63          	beqz	s3,80003614 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800035be:	8552                	mv	a0,s4
    800035c0:	00000097          	auipc	ra,0x0
    800035c4:	ce6080e7          	jalr	-794(ra) # 800032a6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800035c8:	854e                	mv	a0,s3
    800035ca:	70a2                	ld	ra,40(sp)
    800035cc:	7402                	ld	s0,32(sp)
    800035ce:	64e2                	ld	s1,24(sp)
    800035d0:	6942                	ld	s2,16(sp)
    800035d2:	69a2                	ld	s3,8(sp)
    800035d4:	6a02                	ld	s4,0(sp)
    800035d6:	6145                	addi	sp,sp,48
    800035d8:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800035da:	02059493          	slli	s1,a1,0x20
    800035de:	9081                	srli	s1,s1,0x20
    800035e0:	048a                	slli	s1,s1,0x2
    800035e2:	94aa                	add	s1,s1,a0
    800035e4:	0504a983          	lw	s3,80(s1)
    800035e8:	fe0990e3          	bnez	s3,800035c8 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800035ec:	4108                	lw	a0,0(a0)
    800035ee:	00000097          	auipc	ra,0x0
    800035f2:	e4a080e7          	jalr	-438(ra) # 80003438 <balloc>
    800035f6:	0005099b          	sext.w	s3,a0
    800035fa:	0534a823          	sw	s3,80(s1)
    800035fe:	b7e9                	j	800035c8 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003600:	4108                	lw	a0,0(a0)
    80003602:	00000097          	auipc	ra,0x0
    80003606:	e36080e7          	jalr	-458(ra) # 80003438 <balloc>
    8000360a:	0005059b          	sext.w	a1,a0
    8000360e:	08b92023          	sw	a1,128(s2)
    80003612:	b759                	j	80003598 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003614:	00092503          	lw	a0,0(s2)
    80003618:	00000097          	auipc	ra,0x0
    8000361c:	e20080e7          	jalr	-480(ra) # 80003438 <balloc>
    80003620:	0005099b          	sext.w	s3,a0
    80003624:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003628:	8552                	mv	a0,s4
    8000362a:	00001097          	auipc	ra,0x1
    8000362e:	ee0080e7          	jalr	-288(ra) # 8000450a <log_write>
    80003632:	b771                	j	800035be <bmap+0x54>
  panic("bmap: out of range");
    80003634:	00005517          	auipc	a0,0x5
    80003638:	0cc50513          	addi	a0,a0,204 # 80008700 <syscall_names+0x128>
    8000363c:	ffffd097          	auipc	ra,0xffffd
    80003640:	f06080e7          	jalr	-250(ra) # 80000542 <panic>

0000000080003644 <iget>:
{
    80003644:	7179                	addi	sp,sp,-48
    80003646:	f406                	sd	ra,40(sp)
    80003648:	f022                	sd	s0,32(sp)
    8000364a:	ec26                	sd	s1,24(sp)
    8000364c:	e84a                	sd	s2,16(sp)
    8000364e:	e44e                	sd	s3,8(sp)
    80003650:	e052                	sd	s4,0(sp)
    80003652:	1800                	addi	s0,sp,48
    80003654:	89aa                	mv	s3,a0
    80003656:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003658:	0001e517          	auipc	a0,0x1e
    8000365c:	80850513          	addi	a0,a0,-2040 # 80020e60 <icache>
    80003660:	ffffd097          	auipc	ra,0xffffd
    80003664:	630080e7          	jalr	1584(ra) # 80000c90 <acquire>
  empty = 0;
    80003668:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000366a:	0001e497          	auipc	s1,0x1e
    8000366e:	80e48493          	addi	s1,s1,-2034 # 80020e78 <icache+0x18>
    80003672:	0001f697          	auipc	a3,0x1f
    80003676:	29668693          	addi	a3,a3,662 # 80022908 <log>
    8000367a:	a039                	j	80003688 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000367c:	02090b63          	beqz	s2,800036b2 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003680:	08848493          	addi	s1,s1,136
    80003684:	02d48a63          	beq	s1,a3,800036b8 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003688:	449c                	lw	a5,8(s1)
    8000368a:	fef059e3          	blez	a5,8000367c <iget+0x38>
    8000368e:	4098                	lw	a4,0(s1)
    80003690:	ff3716e3          	bne	a4,s3,8000367c <iget+0x38>
    80003694:	40d8                	lw	a4,4(s1)
    80003696:	ff4713e3          	bne	a4,s4,8000367c <iget+0x38>
      ip->ref++;
    8000369a:	2785                	addiw	a5,a5,1
    8000369c:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000369e:	0001d517          	auipc	a0,0x1d
    800036a2:	7c250513          	addi	a0,a0,1986 # 80020e60 <icache>
    800036a6:	ffffd097          	auipc	ra,0xffffd
    800036aa:	69e080e7          	jalr	1694(ra) # 80000d44 <release>
      return ip;
    800036ae:	8926                	mv	s2,s1
    800036b0:	a03d                	j	800036de <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036b2:	f7f9                	bnez	a5,80003680 <iget+0x3c>
    800036b4:	8926                	mv	s2,s1
    800036b6:	b7e9                	j	80003680 <iget+0x3c>
  if(empty == 0)
    800036b8:	02090c63          	beqz	s2,800036f0 <iget+0xac>
  ip->dev = dev;
    800036bc:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800036c0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800036c4:	4785                	li	a5,1
    800036c6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800036ca:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800036ce:	0001d517          	auipc	a0,0x1d
    800036d2:	79250513          	addi	a0,a0,1938 # 80020e60 <icache>
    800036d6:	ffffd097          	auipc	ra,0xffffd
    800036da:	66e080e7          	jalr	1646(ra) # 80000d44 <release>
}
    800036de:	854a                	mv	a0,s2
    800036e0:	70a2                	ld	ra,40(sp)
    800036e2:	7402                	ld	s0,32(sp)
    800036e4:	64e2                	ld	s1,24(sp)
    800036e6:	6942                	ld	s2,16(sp)
    800036e8:	69a2                	ld	s3,8(sp)
    800036ea:	6a02                	ld	s4,0(sp)
    800036ec:	6145                	addi	sp,sp,48
    800036ee:	8082                	ret
    panic("iget: no inodes");
    800036f0:	00005517          	auipc	a0,0x5
    800036f4:	02850513          	addi	a0,a0,40 # 80008718 <syscall_names+0x140>
    800036f8:	ffffd097          	auipc	ra,0xffffd
    800036fc:	e4a080e7          	jalr	-438(ra) # 80000542 <panic>

0000000080003700 <fsinit>:
fsinit(int dev) {
    80003700:	7179                	addi	sp,sp,-48
    80003702:	f406                	sd	ra,40(sp)
    80003704:	f022                	sd	s0,32(sp)
    80003706:	ec26                	sd	s1,24(sp)
    80003708:	e84a                	sd	s2,16(sp)
    8000370a:	e44e                	sd	s3,8(sp)
    8000370c:	1800                	addi	s0,sp,48
    8000370e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003710:	4585                	li	a1,1
    80003712:	00000097          	auipc	ra,0x0
    80003716:	a64080e7          	jalr	-1436(ra) # 80003176 <bread>
    8000371a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000371c:	0001d997          	auipc	s3,0x1d
    80003720:	72498993          	addi	s3,s3,1828 # 80020e40 <sb>
    80003724:	02000613          	li	a2,32
    80003728:	05850593          	addi	a1,a0,88
    8000372c:	854e                	mv	a0,s3
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	6ba080e7          	jalr	1722(ra) # 80000de8 <memmove>
  brelse(bp);
    80003736:	8526                	mv	a0,s1
    80003738:	00000097          	auipc	ra,0x0
    8000373c:	b6e080e7          	jalr	-1170(ra) # 800032a6 <brelse>
  if(sb.magic != FSMAGIC)
    80003740:	0009a703          	lw	a4,0(s3)
    80003744:	102037b7          	lui	a5,0x10203
    80003748:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000374c:	02f71263          	bne	a4,a5,80003770 <fsinit+0x70>
  initlog(dev, &sb);
    80003750:	0001d597          	auipc	a1,0x1d
    80003754:	6f058593          	addi	a1,a1,1776 # 80020e40 <sb>
    80003758:	854a                	mv	a0,s2
    8000375a:	00001097          	auipc	ra,0x1
    8000375e:	b38080e7          	jalr	-1224(ra) # 80004292 <initlog>
}
    80003762:	70a2                	ld	ra,40(sp)
    80003764:	7402                	ld	s0,32(sp)
    80003766:	64e2                	ld	s1,24(sp)
    80003768:	6942                	ld	s2,16(sp)
    8000376a:	69a2                	ld	s3,8(sp)
    8000376c:	6145                	addi	sp,sp,48
    8000376e:	8082                	ret
    panic("invalid file system");
    80003770:	00005517          	auipc	a0,0x5
    80003774:	fb850513          	addi	a0,a0,-72 # 80008728 <syscall_names+0x150>
    80003778:	ffffd097          	auipc	ra,0xffffd
    8000377c:	dca080e7          	jalr	-566(ra) # 80000542 <panic>

0000000080003780 <iinit>:
{
    80003780:	7179                	addi	sp,sp,-48
    80003782:	f406                	sd	ra,40(sp)
    80003784:	f022                	sd	s0,32(sp)
    80003786:	ec26                	sd	s1,24(sp)
    80003788:	e84a                	sd	s2,16(sp)
    8000378a:	e44e                	sd	s3,8(sp)
    8000378c:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000378e:	00005597          	auipc	a1,0x5
    80003792:	fb258593          	addi	a1,a1,-78 # 80008740 <syscall_names+0x168>
    80003796:	0001d517          	auipc	a0,0x1d
    8000379a:	6ca50513          	addi	a0,a0,1738 # 80020e60 <icache>
    8000379e:	ffffd097          	auipc	ra,0xffffd
    800037a2:	462080e7          	jalr	1122(ra) # 80000c00 <initlock>
  for(i = 0; i < NINODE; i++) {
    800037a6:	0001d497          	auipc	s1,0x1d
    800037aa:	6e248493          	addi	s1,s1,1762 # 80020e88 <icache+0x28>
    800037ae:	0001f997          	auipc	s3,0x1f
    800037b2:	16a98993          	addi	s3,s3,362 # 80022918 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800037b6:	00005917          	auipc	s2,0x5
    800037ba:	f9290913          	addi	s2,s2,-110 # 80008748 <syscall_names+0x170>
    800037be:	85ca                	mv	a1,s2
    800037c0:	8526                	mv	a0,s1
    800037c2:	00001097          	auipc	ra,0x1
    800037c6:	e36080e7          	jalr	-458(ra) # 800045f8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800037ca:	08848493          	addi	s1,s1,136
    800037ce:	ff3498e3          	bne	s1,s3,800037be <iinit+0x3e>
}
    800037d2:	70a2                	ld	ra,40(sp)
    800037d4:	7402                	ld	s0,32(sp)
    800037d6:	64e2                	ld	s1,24(sp)
    800037d8:	6942                	ld	s2,16(sp)
    800037da:	69a2                	ld	s3,8(sp)
    800037dc:	6145                	addi	sp,sp,48
    800037de:	8082                	ret

00000000800037e0 <ialloc>:
{
    800037e0:	715d                	addi	sp,sp,-80
    800037e2:	e486                	sd	ra,72(sp)
    800037e4:	e0a2                	sd	s0,64(sp)
    800037e6:	fc26                	sd	s1,56(sp)
    800037e8:	f84a                	sd	s2,48(sp)
    800037ea:	f44e                	sd	s3,40(sp)
    800037ec:	f052                	sd	s4,32(sp)
    800037ee:	ec56                	sd	s5,24(sp)
    800037f0:	e85a                	sd	s6,16(sp)
    800037f2:	e45e                	sd	s7,8(sp)
    800037f4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800037f6:	0001d717          	auipc	a4,0x1d
    800037fa:	65672703          	lw	a4,1622(a4) # 80020e4c <sb+0xc>
    800037fe:	4785                	li	a5,1
    80003800:	04e7fa63          	bgeu	a5,a4,80003854 <ialloc+0x74>
    80003804:	8aaa                	mv	s5,a0
    80003806:	8bae                	mv	s7,a1
    80003808:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000380a:	0001da17          	auipc	s4,0x1d
    8000380e:	636a0a13          	addi	s4,s4,1590 # 80020e40 <sb>
    80003812:	00048b1b          	sext.w	s6,s1
    80003816:	0044d793          	srli	a5,s1,0x4
    8000381a:	018a2583          	lw	a1,24(s4)
    8000381e:	9dbd                	addw	a1,a1,a5
    80003820:	8556                	mv	a0,s5
    80003822:	00000097          	auipc	ra,0x0
    80003826:	954080e7          	jalr	-1708(ra) # 80003176 <bread>
    8000382a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000382c:	05850993          	addi	s3,a0,88
    80003830:	00f4f793          	andi	a5,s1,15
    80003834:	079a                	slli	a5,a5,0x6
    80003836:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003838:	00099783          	lh	a5,0(s3)
    8000383c:	c785                	beqz	a5,80003864 <ialloc+0x84>
    brelse(bp);
    8000383e:	00000097          	auipc	ra,0x0
    80003842:	a68080e7          	jalr	-1432(ra) # 800032a6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003846:	0485                	addi	s1,s1,1
    80003848:	00ca2703          	lw	a4,12(s4)
    8000384c:	0004879b          	sext.w	a5,s1
    80003850:	fce7e1e3          	bltu	a5,a4,80003812 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003854:	00005517          	auipc	a0,0x5
    80003858:	efc50513          	addi	a0,a0,-260 # 80008750 <syscall_names+0x178>
    8000385c:	ffffd097          	auipc	ra,0xffffd
    80003860:	ce6080e7          	jalr	-794(ra) # 80000542 <panic>
      memset(dip, 0, sizeof(*dip));
    80003864:	04000613          	li	a2,64
    80003868:	4581                	li	a1,0
    8000386a:	854e                	mv	a0,s3
    8000386c:	ffffd097          	auipc	ra,0xffffd
    80003870:	520080e7          	jalr	1312(ra) # 80000d8c <memset>
      dip->type = type;
    80003874:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003878:	854a                	mv	a0,s2
    8000387a:	00001097          	auipc	ra,0x1
    8000387e:	c90080e7          	jalr	-880(ra) # 8000450a <log_write>
      brelse(bp);
    80003882:	854a                	mv	a0,s2
    80003884:	00000097          	auipc	ra,0x0
    80003888:	a22080e7          	jalr	-1502(ra) # 800032a6 <brelse>
      return iget(dev, inum);
    8000388c:	85da                	mv	a1,s6
    8000388e:	8556                	mv	a0,s5
    80003890:	00000097          	auipc	ra,0x0
    80003894:	db4080e7          	jalr	-588(ra) # 80003644 <iget>
}
    80003898:	60a6                	ld	ra,72(sp)
    8000389a:	6406                	ld	s0,64(sp)
    8000389c:	74e2                	ld	s1,56(sp)
    8000389e:	7942                	ld	s2,48(sp)
    800038a0:	79a2                	ld	s3,40(sp)
    800038a2:	7a02                	ld	s4,32(sp)
    800038a4:	6ae2                	ld	s5,24(sp)
    800038a6:	6b42                	ld	s6,16(sp)
    800038a8:	6ba2                	ld	s7,8(sp)
    800038aa:	6161                	addi	sp,sp,80
    800038ac:	8082                	ret

00000000800038ae <iupdate>:
{
    800038ae:	1101                	addi	sp,sp,-32
    800038b0:	ec06                	sd	ra,24(sp)
    800038b2:	e822                	sd	s0,16(sp)
    800038b4:	e426                	sd	s1,8(sp)
    800038b6:	e04a                	sd	s2,0(sp)
    800038b8:	1000                	addi	s0,sp,32
    800038ba:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038bc:	415c                	lw	a5,4(a0)
    800038be:	0047d79b          	srliw	a5,a5,0x4
    800038c2:	0001d597          	auipc	a1,0x1d
    800038c6:	5965a583          	lw	a1,1430(a1) # 80020e58 <sb+0x18>
    800038ca:	9dbd                	addw	a1,a1,a5
    800038cc:	4108                	lw	a0,0(a0)
    800038ce:	00000097          	auipc	ra,0x0
    800038d2:	8a8080e7          	jalr	-1880(ra) # 80003176 <bread>
    800038d6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038d8:	05850793          	addi	a5,a0,88
    800038dc:	40c8                	lw	a0,4(s1)
    800038de:	893d                	andi	a0,a0,15
    800038e0:	051a                	slli	a0,a0,0x6
    800038e2:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800038e4:	04449703          	lh	a4,68(s1)
    800038e8:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800038ec:	04649703          	lh	a4,70(s1)
    800038f0:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800038f4:	04849703          	lh	a4,72(s1)
    800038f8:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800038fc:	04a49703          	lh	a4,74(s1)
    80003900:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003904:	44f8                	lw	a4,76(s1)
    80003906:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003908:	03400613          	li	a2,52
    8000390c:	05048593          	addi	a1,s1,80
    80003910:	0531                	addi	a0,a0,12
    80003912:	ffffd097          	auipc	ra,0xffffd
    80003916:	4d6080e7          	jalr	1238(ra) # 80000de8 <memmove>
  log_write(bp);
    8000391a:	854a                	mv	a0,s2
    8000391c:	00001097          	auipc	ra,0x1
    80003920:	bee080e7          	jalr	-1042(ra) # 8000450a <log_write>
  brelse(bp);
    80003924:	854a                	mv	a0,s2
    80003926:	00000097          	auipc	ra,0x0
    8000392a:	980080e7          	jalr	-1664(ra) # 800032a6 <brelse>
}
    8000392e:	60e2                	ld	ra,24(sp)
    80003930:	6442                	ld	s0,16(sp)
    80003932:	64a2                	ld	s1,8(sp)
    80003934:	6902                	ld	s2,0(sp)
    80003936:	6105                	addi	sp,sp,32
    80003938:	8082                	ret

000000008000393a <idup>:
{
    8000393a:	1101                	addi	sp,sp,-32
    8000393c:	ec06                	sd	ra,24(sp)
    8000393e:	e822                	sd	s0,16(sp)
    80003940:	e426                	sd	s1,8(sp)
    80003942:	1000                	addi	s0,sp,32
    80003944:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003946:	0001d517          	auipc	a0,0x1d
    8000394a:	51a50513          	addi	a0,a0,1306 # 80020e60 <icache>
    8000394e:	ffffd097          	auipc	ra,0xffffd
    80003952:	342080e7          	jalr	834(ra) # 80000c90 <acquire>
  ip->ref++;
    80003956:	449c                	lw	a5,8(s1)
    80003958:	2785                	addiw	a5,a5,1
    8000395a:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000395c:	0001d517          	auipc	a0,0x1d
    80003960:	50450513          	addi	a0,a0,1284 # 80020e60 <icache>
    80003964:	ffffd097          	auipc	ra,0xffffd
    80003968:	3e0080e7          	jalr	992(ra) # 80000d44 <release>
}
    8000396c:	8526                	mv	a0,s1
    8000396e:	60e2                	ld	ra,24(sp)
    80003970:	6442                	ld	s0,16(sp)
    80003972:	64a2                	ld	s1,8(sp)
    80003974:	6105                	addi	sp,sp,32
    80003976:	8082                	ret

0000000080003978 <ilock>:
{
    80003978:	1101                	addi	sp,sp,-32
    8000397a:	ec06                	sd	ra,24(sp)
    8000397c:	e822                	sd	s0,16(sp)
    8000397e:	e426                	sd	s1,8(sp)
    80003980:	e04a                	sd	s2,0(sp)
    80003982:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003984:	c115                	beqz	a0,800039a8 <ilock+0x30>
    80003986:	84aa                	mv	s1,a0
    80003988:	451c                	lw	a5,8(a0)
    8000398a:	00f05f63          	blez	a5,800039a8 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000398e:	0541                	addi	a0,a0,16
    80003990:	00001097          	auipc	ra,0x1
    80003994:	ca2080e7          	jalr	-862(ra) # 80004632 <acquiresleep>
  if(ip->valid == 0){
    80003998:	40bc                	lw	a5,64(s1)
    8000399a:	cf99                	beqz	a5,800039b8 <ilock+0x40>
}
    8000399c:	60e2                	ld	ra,24(sp)
    8000399e:	6442                	ld	s0,16(sp)
    800039a0:	64a2                	ld	s1,8(sp)
    800039a2:	6902                	ld	s2,0(sp)
    800039a4:	6105                	addi	sp,sp,32
    800039a6:	8082                	ret
    panic("ilock");
    800039a8:	00005517          	auipc	a0,0x5
    800039ac:	dc050513          	addi	a0,a0,-576 # 80008768 <syscall_names+0x190>
    800039b0:	ffffd097          	auipc	ra,0xffffd
    800039b4:	b92080e7          	jalr	-1134(ra) # 80000542 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039b8:	40dc                	lw	a5,4(s1)
    800039ba:	0047d79b          	srliw	a5,a5,0x4
    800039be:	0001d597          	auipc	a1,0x1d
    800039c2:	49a5a583          	lw	a1,1178(a1) # 80020e58 <sb+0x18>
    800039c6:	9dbd                	addw	a1,a1,a5
    800039c8:	4088                	lw	a0,0(s1)
    800039ca:	fffff097          	auipc	ra,0xfffff
    800039ce:	7ac080e7          	jalr	1964(ra) # 80003176 <bread>
    800039d2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039d4:	05850593          	addi	a1,a0,88
    800039d8:	40dc                	lw	a5,4(s1)
    800039da:	8bbd                	andi	a5,a5,15
    800039dc:	079a                	slli	a5,a5,0x6
    800039de:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039e0:	00059783          	lh	a5,0(a1)
    800039e4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039e8:	00259783          	lh	a5,2(a1)
    800039ec:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039f0:	00459783          	lh	a5,4(a1)
    800039f4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039f8:	00659783          	lh	a5,6(a1)
    800039fc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a00:	459c                	lw	a5,8(a1)
    80003a02:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a04:	03400613          	li	a2,52
    80003a08:	05b1                	addi	a1,a1,12
    80003a0a:	05048513          	addi	a0,s1,80
    80003a0e:	ffffd097          	auipc	ra,0xffffd
    80003a12:	3da080e7          	jalr	986(ra) # 80000de8 <memmove>
    brelse(bp);
    80003a16:	854a                	mv	a0,s2
    80003a18:	00000097          	auipc	ra,0x0
    80003a1c:	88e080e7          	jalr	-1906(ra) # 800032a6 <brelse>
    ip->valid = 1;
    80003a20:	4785                	li	a5,1
    80003a22:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a24:	04449783          	lh	a5,68(s1)
    80003a28:	fbb5                	bnez	a5,8000399c <ilock+0x24>
      panic("ilock: no type");
    80003a2a:	00005517          	auipc	a0,0x5
    80003a2e:	d4650513          	addi	a0,a0,-698 # 80008770 <syscall_names+0x198>
    80003a32:	ffffd097          	auipc	ra,0xffffd
    80003a36:	b10080e7          	jalr	-1264(ra) # 80000542 <panic>

0000000080003a3a <iunlock>:
{
    80003a3a:	1101                	addi	sp,sp,-32
    80003a3c:	ec06                	sd	ra,24(sp)
    80003a3e:	e822                	sd	s0,16(sp)
    80003a40:	e426                	sd	s1,8(sp)
    80003a42:	e04a                	sd	s2,0(sp)
    80003a44:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a46:	c905                	beqz	a0,80003a76 <iunlock+0x3c>
    80003a48:	84aa                	mv	s1,a0
    80003a4a:	01050913          	addi	s2,a0,16
    80003a4e:	854a                	mv	a0,s2
    80003a50:	00001097          	auipc	ra,0x1
    80003a54:	c7c080e7          	jalr	-900(ra) # 800046cc <holdingsleep>
    80003a58:	cd19                	beqz	a0,80003a76 <iunlock+0x3c>
    80003a5a:	449c                	lw	a5,8(s1)
    80003a5c:	00f05d63          	blez	a5,80003a76 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a60:	854a                	mv	a0,s2
    80003a62:	00001097          	auipc	ra,0x1
    80003a66:	c26080e7          	jalr	-986(ra) # 80004688 <releasesleep>
}
    80003a6a:	60e2                	ld	ra,24(sp)
    80003a6c:	6442                	ld	s0,16(sp)
    80003a6e:	64a2                	ld	s1,8(sp)
    80003a70:	6902                	ld	s2,0(sp)
    80003a72:	6105                	addi	sp,sp,32
    80003a74:	8082                	ret
    panic("iunlock");
    80003a76:	00005517          	auipc	a0,0x5
    80003a7a:	d0a50513          	addi	a0,a0,-758 # 80008780 <syscall_names+0x1a8>
    80003a7e:	ffffd097          	auipc	ra,0xffffd
    80003a82:	ac4080e7          	jalr	-1340(ra) # 80000542 <panic>

0000000080003a86 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a86:	7179                	addi	sp,sp,-48
    80003a88:	f406                	sd	ra,40(sp)
    80003a8a:	f022                	sd	s0,32(sp)
    80003a8c:	ec26                	sd	s1,24(sp)
    80003a8e:	e84a                	sd	s2,16(sp)
    80003a90:	e44e                	sd	s3,8(sp)
    80003a92:	e052                	sd	s4,0(sp)
    80003a94:	1800                	addi	s0,sp,48
    80003a96:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a98:	05050493          	addi	s1,a0,80
    80003a9c:	08050913          	addi	s2,a0,128
    80003aa0:	a021                	j	80003aa8 <itrunc+0x22>
    80003aa2:	0491                	addi	s1,s1,4
    80003aa4:	01248d63          	beq	s1,s2,80003abe <itrunc+0x38>
    if(ip->addrs[i]){
    80003aa8:	408c                	lw	a1,0(s1)
    80003aaa:	dde5                	beqz	a1,80003aa2 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003aac:	0009a503          	lw	a0,0(s3)
    80003ab0:	00000097          	auipc	ra,0x0
    80003ab4:	90c080e7          	jalr	-1780(ra) # 800033bc <bfree>
      ip->addrs[i] = 0;
    80003ab8:	0004a023          	sw	zero,0(s1)
    80003abc:	b7dd                	j	80003aa2 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003abe:	0809a583          	lw	a1,128(s3)
    80003ac2:	e185                	bnez	a1,80003ae2 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ac4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ac8:	854e                	mv	a0,s3
    80003aca:	00000097          	auipc	ra,0x0
    80003ace:	de4080e7          	jalr	-540(ra) # 800038ae <iupdate>
}
    80003ad2:	70a2                	ld	ra,40(sp)
    80003ad4:	7402                	ld	s0,32(sp)
    80003ad6:	64e2                	ld	s1,24(sp)
    80003ad8:	6942                	ld	s2,16(sp)
    80003ada:	69a2                	ld	s3,8(sp)
    80003adc:	6a02                	ld	s4,0(sp)
    80003ade:	6145                	addi	sp,sp,48
    80003ae0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003ae2:	0009a503          	lw	a0,0(s3)
    80003ae6:	fffff097          	auipc	ra,0xfffff
    80003aea:	690080e7          	jalr	1680(ra) # 80003176 <bread>
    80003aee:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003af0:	05850493          	addi	s1,a0,88
    80003af4:	45850913          	addi	s2,a0,1112
    80003af8:	a021                	j	80003b00 <itrunc+0x7a>
    80003afa:	0491                	addi	s1,s1,4
    80003afc:	01248b63          	beq	s1,s2,80003b12 <itrunc+0x8c>
      if(a[j])
    80003b00:	408c                	lw	a1,0(s1)
    80003b02:	dde5                	beqz	a1,80003afa <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b04:	0009a503          	lw	a0,0(s3)
    80003b08:	00000097          	auipc	ra,0x0
    80003b0c:	8b4080e7          	jalr	-1868(ra) # 800033bc <bfree>
    80003b10:	b7ed                	j	80003afa <itrunc+0x74>
    brelse(bp);
    80003b12:	8552                	mv	a0,s4
    80003b14:	fffff097          	auipc	ra,0xfffff
    80003b18:	792080e7          	jalr	1938(ra) # 800032a6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b1c:	0809a583          	lw	a1,128(s3)
    80003b20:	0009a503          	lw	a0,0(s3)
    80003b24:	00000097          	auipc	ra,0x0
    80003b28:	898080e7          	jalr	-1896(ra) # 800033bc <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b2c:	0809a023          	sw	zero,128(s3)
    80003b30:	bf51                	j	80003ac4 <itrunc+0x3e>

0000000080003b32 <iput>:
{
    80003b32:	1101                	addi	sp,sp,-32
    80003b34:	ec06                	sd	ra,24(sp)
    80003b36:	e822                	sd	s0,16(sp)
    80003b38:	e426                	sd	s1,8(sp)
    80003b3a:	e04a                	sd	s2,0(sp)
    80003b3c:	1000                	addi	s0,sp,32
    80003b3e:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003b40:	0001d517          	auipc	a0,0x1d
    80003b44:	32050513          	addi	a0,a0,800 # 80020e60 <icache>
    80003b48:	ffffd097          	auipc	ra,0xffffd
    80003b4c:	148080e7          	jalr	328(ra) # 80000c90 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b50:	4498                	lw	a4,8(s1)
    80003b52:	4785                	li	a5,1
    80003b54:	02f70363          	beq	a4,a5,80003b7a <iput+0x48>
  ip->ref--;
    80003b58:	449c                	lw	a5,8(s1)
    80003b5a:	37fd                	addiw	a5,a5,-1
    80003b5c:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003b5e:	0001d517          	auipc	a0,0x1d
    80003b62:	30250513          	addi	a0,a0,770 # 80020e60 <icache>
    80003b66:	ffffd097          	auipc	ra,0xffffd
    80003b6a:	1de080e7          	jalr	478(ra) # 80000d44 <release>
}
    80003b6e:	60e2                	ld	ra,24(sp)
    80003b70:	6442                	ld	s0,16(sp)
    80003b72:	64a2                	ld	s1,8(sp)
    80003b74:	6902                	ld	s2,0(sp)
    80003b76:	6105                	addi	sp,sp,32
    80003b78:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b7a:	40bc                	lw	a5,64(s1)
    80003b7c:	dff1                	beqz	a5,80003b58 <iput+0x26>
    80003b7e:	04a49783          	lh	a5,74(s1)
    80003b82:	fbf9                	bnez	a5,80003b58 <iput+0x26>
    acquiresleep(&ip->lock);
    80003b84:	01048913          	addi	s2,s1,16
    80003b88:	854a                	mv	a0,s2
    80003b8a:	00001097          	auipc	ra,0x1
    80003b8e:	aa8080e7          	jalr	-1368(ra) # 80004632 <acquiresleep>
    release(&icache.lock);
    80003b92:	0001d517          	auipc	a0,0x1d
    80003b96:	2ce50513          	addi	a0,a0,718 # 80020e60 <icache>
    80003b9a:	ffffd097          	auipc	ra,0xffffd
    80003b9e:	1aa080e7          	jalr	426(ra) # 80000d44 <release>
    itrunc(ip);
    80003ba2:	8526                	mv	a0,s1
    80003ba4:	00000097          	auipc	ra,0x0
    80003ba8:	ee2080e7          	jalr	-286(ra) # 80003a86 <itrunc>
    ip->type = 0;
    80003bac:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003bb0:	8526                	mv	a0,s1
    80003bb2:	00000097          	auipc	ra,0x0
    80003bb6:	cfc080e7          	jalr	-772(ra) # 800038ae <iupdate>
    ip->valid = 0;
    80003bba:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003bbe:	854a                	mv	a0,s2
    80003bc0:	00001097          	auipc	ra,0x1
    80003bc4:	ac8080e7          	jalr	-1336(ra) # 80004688 <releasesleep>
    acquire(&icache.lock);
    80003bc8:	0001d517          	auipc	a0,0x1d
    80003bcc:	29850513          	addi	a0,a0,664 # 80020e60 <icache>
    80003bd0:	ffffd097          	auipc	ra,0xffffd
    80003bd4:	0c0080e7          	jalr	192(ra) # 80000c90 <acquire>
    80003bd8:	b741                	j	80003b58 <iput+0x26>

0000000080003bda <iunlockput>:
{
    80003bda:	1101                	addi	sp,sp,-32
    80003bdc:	ec06                	sd	ra,24(sp)
    80003bde:	e822                	sd	s0,16(sp)
    80003be0:	e426                	sd	s1,8(sp)
    80003be2:	1000                	addi	s0,sp,32
    80003be4:	84aa                	mv	s1,a0
  iunlock(ip);
    80003be6:	00000097          	auipc	ra,0x0
    80003bea:	e54080e7          	jalr	-428(ra) # 80003a3a <iunlock>
  iput(ip);
    80003bee:	8526                	mv	a0,s1
    80003bf0:	00000097          	auipc	ra,0x0
    80003bf4:	f42080e7          	jalr	-190(ra) # 80003b32 <iput>
}
    80003bf8:	60e2                	ld	ra,24(sp)
    80003bfa:	6442                	ld	s0,16(sp)
    80003bfc:	64a2                	ld	s1,8(sp)
    80003bfe:	6105                	addi	sp,sp,32
    80003c00:	8082                	ret

0000000080003c02 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c02:	1141                	addi	sp,sp,-16
    80003c04:	e422                	sd	s0,8(sp)
    80003c06:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c08:	411c                	lw	a5,0(a0)
    80003c0a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c0c:	415c                	lw	a5,4(a0)
    80003c0e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c10:	04451783          	lh	a5,68(a0)
    80003c14:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c18:	04a51783          	lh	a5,74(a0)
    80003c1c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c20:	04c56783          	lwu	a5,76(a0)
    80003c24:	e99c                	sd	a5,16(a1)
}
    80003c26:	6422                	ld	s0,8(sp)
    80003c28:	0141                	addi	sp,sp,16
    80003c2a:	8082                	ret

0000000080003c2c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c2c:	457c                	lw	a5,76(a0)
    80003c2e:	0ed7e863          	bltu	a5,a3,80003d1e <readi+0xf2>
{
    80003c32:	7159                	addi	sp,sp,-112
    80003c34:	f486                	sd	ra,104(sp)
    80003c36:	f0a2                	sd	s0,96(sp)
    80003c38:	eca6                	sd	s1,88(sp)
    80003c3a:	e8ca                	sd	s2,80(sp)
    80003c3c:	e4ce                	sd	s3,72(sp)
    80003c3e:	e0d2                	sd	s4,64(sp)
    80003c40:	fc56                	sd	s5,56(sp)
    80003c42:	f85a                	sd	s6,48(sp)
    80003c44:	f45e                	sd	s7,40(sp)
    80003c46:	f062                	sd	s8,32(sp)
    80003c48:	ec66                	sd	s9,24(sp)
    80003c4a:	e86a                	sd	s10,16(sp)
    80003c4c:	e46e                	sd	s11,8(sp)
    80003c4e:	1880                	addi	s0,sp,112
    80003c50:	8baa                	mv	s7,a0
    80003c52:	8c2e                	mv	s8,a1
    80003c54:	8ab2                	mv	s5,a2
    80003c56:	84b6                	mv	s1,a3
    80003c58:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c5a:	9f35                	addw	a4,a4,a3
    return 0;
    80003c5c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c5e:	08d76f63          	bltu	a4,a3,80003cfc <readi+0xd0>
  if(off + n > ip->size)
    80003c62:	00e7f463          	bgeu	a5,a4,80003c6a <readi+0x3e>
    n = ip->size - off;
    80003c66:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c6a:	0a0b0863          	beqz	s6,80003d1a <readi+0xee>
    80003c6e:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c70:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c74:	5cfd                	li	s9,-1
    80003c76:	a82d                	j	80003cb0 <readi+0x84>
    80003c78:	020a1d93          	slli	s11,s4,0x20
    80003c7c:	020ddd93          	srli	s11,s11,0x20
    80003c80:	05890793          	addi	a5,s2,88
    80003c84:	86ee                	mv	a3,s11
    80003c86:	963e                	add	a2,a2,a5
    80003c88:	85d6                	mv	a1,s5
    80003c8a:	8562                	mv	a0,s8
    80003c8c:	fffff097          	auipc	ra,0xfffff
    80003c90:	84c080e7          	jalr	-1972(ra) # 800024d8 <either_copyout>
    80003c94:	05950d63          	beq	a0,s9,80003cee <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003c98:	854a                	mv	a0,s2
    80003c9a:	fffff097          	auipc	ra,0xfffff
    80003c9e:	60c080e7          	jalr	1548(ra) # 800032a6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ca2:	013a09bb          	addw	s3,s4,s3
    80003ca6:	009a04bb          	addw	s1,s4,s1
    80003caa:	9aee                	add	s5,s5,s11
    80003cac:	0569f663          	bgeu	s3,s6,80003cf8 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003cb0:	000ba903          	lw	s2,0(s7)
    80003cb4:	00a4d59b          	srliw	a1,s1,0xa
    80003cb8:	855e                	mv	a0,s7
    80003cba:	00000097          	auipc	ra,0x0
    80003cbe:	8b0080e7          	jalr	-1872(ra) # 8000356a <bmap>
    80003cc2:	0005059b          	sext.w	a1,a0
    80003cc6:	854a                	mv	a0,s2
    80003cc8:	fffff097          	auipc	ra,0xfffff
    80003ccc:	4ae080e7          	jalr	1198(ra) # 80003176 <bread>
    80003cd0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cd2:	3ff4f613          	andi	a2,s1,1023
    80003cd6:	40cd07bb          	subw	a5,s10,a2
    80003cda:	413b073b          	subw	a4,s6,s3
    80003cde:	8a3e                	mv	s4,a5
    80003ce0:	2781                	sext.w	a5,a5
    80003ce2:	0007069b          	sext.w	a3,a4
    80003ce6:	f8f6f9e3          	bgeu	a3,a5,80003c78 <readi+0x4c>
    80003cea:	8a3a                	mv	s4,a4
    80003cec:	b771                	j	80003c78 <readi+0x4c>
      brelse(bp);
    80003cee:	854a                	mv	a0,s2
    80003cf0:	fffff097          	auipc	ra,0xfffff
    80003cf4:	5b6080e7          	jalr	1462(ra) # 800032a6 <brelse>
  }
  return tot;
    80003cf8:	0009851b          	sext.w	a0,s3
}
    80003cfc:	70a6                	ld	ra,104(sp)
    80003cfe:	7406                	ld	s0,96(sp)
    80003d00:	64e6                	ld	s1,88(sp)
    80003d02:	6946                	ld	s2,80(sp)
    80003d04:	69a6                	ld	s3,72(sp)
    80003d06:	6a06                	ld	s4,64(sp)
    80003d08:	7ae2                	ld	s5,56(sp)
    80003d0a:	7b42                	ld	s6,48(sp)
    80003d0c:	7ba2                	ld	s7,40(sp)
    80003d0e:	7c02                	ld	s8,32(sp)
    80003d10:	6ce2                	ld	s9,24(sp)
    80003d12:	6d42                	ld	s10,16(sp)
    80003d14:	6da2                	ld	s11,8(sp)
    80003d16:	6165                	addi	sp,sp,112
    80003d18:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d1a:	89da                	mv	s3,s6
    80003d1c:	bff1                	j	80003cf8 <readi+0xcc>
    return 0;
    80003d1e:	4501                	li	a0,0
}
    80003d20:	8082                	ret

0000000080003d22 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d22:	457c                	lw	a5,76(a0)
    80003d24:	10d7e663          	bltu	a5,a3,80003e30 <writei+0x10e>
{
    80003d28:	7159                	addi	sp,sp,-112
    80003d2a:	f486                	sd	ra,104(sp)
    80003d2c:	f0a2                	sd	s0,96(sp)
    80003d2e:	eca6                	sd	s1,88(sp)
    80003d30:	e8ca                	sd	s2,80(sp)
    80003d32:	e4ce                	sd	s3,72(sp)
    80003d34:	e0d2                	sd	s4,64(sp)
    80003d36:	fc56                	sd	s5,56(sp)
    80003d38:	f85a                	sd	s6,48(sp)
    80003d3a:	f45e                	sd	s7,40(sp)
    80003d3c:	f062                	sd	s8,32(sp)
    80003d3e:	ec66                	sd	s9,24(sp)
    80003d40:	e86a                	sd	s10,16(sp)
    80003d42:	e46e                	sd	s11,8(sp)
    80003d44:	1880                	addi	s0,sp,112
    80003d46:	8baa                	mv	s7,a0
    80003d48:	8c2e                	mv	s8,a1
    80003d4a:	8ab2                	mv	s5,a2
    80003d4c:	8936                	mv	s2,a3
    80003d4e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d50:	00e687bb          	addw	a5,a3,a4
    80003d54:	0ed7e063          	bltu	a5,a3,80003e34 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d58:	00043737          	lui	a4,0x43
    80003d5c:	0cf76e63          	bltu	a4,a5,80003e38 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d60:	0a0b0763          	beqz	s6,80003e0e <writei+0xec>
    80003d64:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d66:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d6a:	5cfd                	li	s9,-1
    80003d6c:	a091                	j	80003db0 <writei+0x8e>
    80003d6e:	02099d93          	slli	s11,s3,0x20
    80003d72:	020ddd93          	srli	s11,s11,0x20
    80003d76:	05848793          	addi	a5,s1,88
    80003d7a:	86ee                	mv	a3,s11
    80003d7c:	8656                	mv	a2,s5
    80003d7e:	85e2                	mv	a1,s8
    80003d80:	953e                	add	a0,a0,a5
    80003d82:	ffffe097          	auipc	ra,0xffffe
    80003d86:	7ac080e7          	jalr	1964(ra) # 8000252e <either_copyin>
    80003d8a:	07950263          	beq	a0,s9,80003dee <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d8e:	8526                	mv	a0,s1
    80003d90:	00000097          	auipc	ra,0x0
    80003d94:	77a080e7          	jalr	1914(ra) # 8000450a <log_write>
    brelse(bp);
    80003d98:	8526                	mv	a0,s1
    80003d9a:	fffff097          	auipc	ra,0xfffff
    80003d9e:	50c080e7          	jalr	1292(ra) # 800032a6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003da2:	01498a3b          	addw	s4,s3,s4
    80003da6:	0129893b          	addw	s2,s3,s2
    80003daa:	9aee                	add	s5,s5,s11
    80003dac:	056a7663          	bgeu	s4,s6,80003df8 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003db0:	000ba483          	lw	s1,0(s7)
    80003db4:	00a9559b          	srliw	a1,s2,0xa
    80003db8:	855e                	mv	a0,s7
    80003dba:	fffff097          	auipc	ra,0xfffff
    80003dbe:	7b0080e7          	jalr	1968(ra) # 8000356a <bmap>
    80003dc2:	0005059b          	sext.w	a1,a0
    80003dc6:	8526                	mv	a0,s1
    80003dc8:	fffff097          	auipc	ra,0xfffff
    80003dcc:	3ae080e7          	jalr	942(ra) # 80003176 <bread>
    80003dd0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dd2:	3ff97513          	andi	a0,s2,1023
    80003dd6:	40ad07bb          	subw	a5,s10,a0
    80003dda:	414b073b          	subw	a4,s6,s4
    80003dde:	89be                	mv	s3,a5
    80003de0:	2781                	sext.w	a5,a5
    80003de2:	0007069b          	sext.w	a3,a4
    80003de6:	f8f6f4e3          	bgeu	a3,a5,80003d6e <writei+0x4c>
    80003dea:	89ba                	mv	s3,a4
    80003dec:	b749                	j	80003d6e <writei+0x4c>
      brelse(bp);
    80003dee:	8526                	mv	a0,s1
    80003df0:	fffff097          	auipc	ra,0xfffff
    80003df4:	4b6080e7          	jalr	1206(ra) # 800032a6 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003df8:	04cba783          	lw	a5,76(s7)
    80003dfc:	0127f463          	bgeu	a5,s2,80003e04 <writei+0xe2>
      ip->size = off;
    80003e00:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003e04:	855e                	mv	a0,s7
    80003e06:	00000097          	auipc	ra,0x0
    80003e0a:	aa8080e7          	jalr	-1368(ra) # 800038ae <iupdate>
  }

  return n;
    80003e0e:	000b051b          	sext.w	a0,s6
}
    80003e12:	70a6                	ld	ra,104(sp)
    80003e14:	7406                	ld	s0,96(sp)
    80003e16:	64e6                	ld	s1,88(sp)
    80003e18:	6946                	ld	s2,80(sp)
    80003e1a:	69a6                	ld	s3,72(sp)
    80003e1c:	6a06                	ld	s4,64(sp)
    80003e1e:	7ae2                	ld	s5,56(sp)
    80003e20:	7b42                	ld	s6,48(sp)
    80003e22:	7ba2                	ld	s7,40(sp)
    80003e24:	7c02                	ld	s8,32(sp)
    80003e26:	6ce2                	ld	s9,24(sp)
    80003e28:	6d42                	ld	s10,16(sp)
    80003e2a:	6da2                	ld	s11,8(sp)
    80003e2c:	6165                	addi	sp,sp,112
    80003e2e:	8082                	ret
    return -1;
    80003e30:	557d                	li	a0,-1
}
    80003e32:	8082                	ret
    return -1;
    80003e34:	557d                	li	a0,-1
    80003e36:	bff1                	j	80003e12 <writei+0xf0>
    return -1;
    80003e38:	557d                	li	a0,-1
    80003e3a:	bfe1                	j	80003e12 <writei+0xf0>

0000000080003e3c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e3c:	1141                	addi	sp,sp,-16
    80003e3e:	e406                	sd	ra,8(sp)
    80003e40:	e022                	sd	s0,0(sp)
    80003e42:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e44:	4639                	li	a2,14
    80003e46:	ffffd097          	auipc	ra,0xffffd
    80003e4a:	01e080e7          	jalr	30(ra) # 80000e64 <strncmp>
}
    80003e4e:	60a2                	ld	ra,8(sp)
    80003e50:	6402                	ld	s0,0(sp)
    80003e52:	0141                	addi	sp,sp,16
    80003e54:	8082                	ret

0000000080003e56 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e56:	7139                	addi	sp,sp,-64
    80003e58:	fc06                	sd	ra,56(sp)
    80003e5a:	f822                	sd	s0,48(sp)
    80003e5c:	f426                	sd	s1,40(sp)
    80003e5e:	f04a                	sd	s2,32(sp)
    80003e60:	ec4e                	sd	s3,24(sp)
    80003e62:	e852                	sd	s4,16(sp)
    80003e64:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e66:	04451703          	lh	a4,68(a0)
    80003e6a:	4785                	li	a5,1
    80003e6c:	00f71a63          	bne	a4,a5,80003e80 <dirlookup+0x2a>
    80003e70:	892a                	mv	s2,a0
    80003e72:	89ae                	mv	s3,a1
    80003e74:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e76:	457c                	lw	a5,76(a0)
    80003e78:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e7a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e7c:	e79d                	bnez	a5,80003eaa <dirlookup+0x54>
    80003e7e:	a8a5                	j	80003ef6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e80:	00005517          	auipc	a0,0x5
    80003e84:	90850513          	addi	a0,a0,-1784 # 80008788 <syscall_names+0x1b0>
    80003e88:	ffffc097          	auipc	ra,0xffffc
    80003e8c:	6ba080e7          	jalr	1722(ra) # 80000542 <panic>
      panic("dirlookup read");
    80003e90:	00005517          	auipc	a0,0x5
    80003e94:	91050513          	addi	a0,a0,-1776 # 800087a0 <syscall_names+0x1c8>
    80003e98:	ffffc097          	auipc	ra,0xffffc
    80003e9c:	6aa080e7          	jalr	1706(ra) # 80000542 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ea0:	24c1                	addiw	s1,s1,16
    80003ea2:	04c92783          	lw	a5,76(s2)
    80003ea6:	04f4f763          	bgeu	s1,a5,80003ef4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eaa:	4741                	li	a4,16
    80003eac:	86a6                	mv	a3,s1
    80003eae:	fc040613          	addi	a2,s0,-64
    80003eb2:	4581                	li	a1,0
    80003eb4:	854a                	mv	a0,s2
    80003eb6:	00000097          	auipc	ra,0x0
    80003eba:	d76080e7          	jalr	-650(ra) # 80003c2c <readi>
    80003ebe:	47c1                	li	a5,16
    80003ec0:	fcf518e3          	bne	a0,a5,80003e90 <dirlookup+0x3a>
    if(de.inum == 0)
    80003ec4:	fc045783          	lhu	a5,-64(s0)
    80003ec8:	dfe1                	beqz	a5,80003ea0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003eca:	fc240593          	addi	a1,s0,-62
    80003ece:	854e                	mv	a0,s3
    80003ed0:	00000097          	auipc	ra,0x0
    80003ed4:	f6c080e7          	jalr	-148(ra) # 80003e3c <namecmp>
    80003ed8:	f561                	bnez	a0,80003ea0 <dirlookup+0x4a>
      if(poff)
    80003eda:	000a0463          	beqz	s4,80003ee2 <dirlookup+0x8c>
        *poff = off;
    80003ede:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ee2:	fc045583          	lhu	a1,-64(s0)
    80003ee6:	00092503          	lw	a0,0(s2)
    80003eea:	fffff097          	auipc	ra,0xfffff
    80003eee:	75a080e7          	jalr	1882(ra) # 80003644 <iget>
    80003ef2:	a011                	j	80003ef6 <dirlookup+0xa0>
  return 0;
    80003ef4:	4501                	li	a0,0
}
    80003ef6:	70e2                	ld	ra,56(sp)
    80003ef8:	7442                	ld	s0,48(sp)
    80003efa:	74a2                	ld	s1,40(sp)
    80003efc:	7902                	ld	s2,32(sp)
    80003efe:	69e2                	ld	s3,24(sp)
    80003f00:	6a42                	ld	s4,16(sp)
    80003f02:	6121                	addi	sp,sp,64
    80003f04:	8082                	ret

0000000080003f06 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f06:	711d                	addi	sp,sp,-96
    80003f08:	ec86                	sd	ra,88(sp)
    80003f0a:	e8a2                	sd	s0,80(sp)
    80003f0c:	e4a6                	sd	s1,72(sp)
    80003f0e:	e0ca                	sd	s2,64(sp)
    80003f10:	fc4e                	sd	s3,56(sp)
    80003f12:	f852                	sd	s4,48(sp)
    80003f14:	f456                	sd	s5,40(sp)
    80003f16:	f05a                	sd	s6,32(sp)
    80003f18:	ec5e                	sd	s7,24(sp)
    80003f1a:	e862                	sd	s8,16(sp)
    80003f1c:	e466                	sd	s9,8(sp)
    80003f1e:	1080                	addi	s0,sp,96
    80003f20:	84aa                	mv	s1,a0
    80003f22:	8aae                	mv	s5,a1
    80003f24:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f26:	00054703          	lbu	a4,0(a0)
    80003f2a:	02f00793          	li	a5,47
    80003f2e:	02f70363          	beq	a4,a5,80003f54 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f32:	ffffe097          	auipc	ra,0xffffe
    80003f36:	b2a080e7          	jalr	-1238(ra) # 80001a5c <myproc>
    80003f3a:	15053503          	ld	a0,336(a0)
    80003f3e:	00000097          	auipc	ra,0x0
    80003f42:	9fc080e7          	jalr	-1540(ra) # 8000393a <idup>
    80003f46:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f48:	02f00913          	li	s2,47
  len = path - s;
    80003f4c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f4e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f50:	4b85                	li	s7,1
    80003f52:	a865                	j	8000400a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f54:	4585                	li	a1,1
    80003f56:	4505                	li	a0,1
    80003f58:	fffff097          	auipc	ra,0xfffff
    80003f5c:	6ec080e7          	jalr	1772(ra) # 80003644 <iget>
    80003f60:	89aa                	mv	s3,a0
    80003f62:	b7dd                	j	80003f48 <namex+0x42>
      iunlockput(ip);
    80003f64:	854e                	mv	a0,s3
    80003f66:	00000097          	auipc	ra,0x0
    80003f6a:	c74080e7          	jalr	-908(ra) # 80003bda <iunlockput>
      return 0;
    80003f6e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f70:	854e                	mv	a0,s3
    80003f72:	60e6                	ld	ra,88(sp)
    80003f74:	6446                	ld	s0,80(sp)
    80003f76:	64a6                	ld	s1,72(sp)
    80003f78:	6906                	ld	s2,64(sp)
    80003f7a:	79e2                	ld	s3,56(sp)
    80003f7c:	7a42                	ld	s4,48(sp)
    80003f7e:	7aa2                	ld	s5,40(sp)
    80003f80:	7b02                	ld	s6,32(sp)
    80003f82:	6be2                	ld	s7,24(sp)
    80003f84:	6c42                	ld	s8,16(sp)
    80003f86:	6ca2                	ld	s9,8(sp)
    80003f88:	6125                	addi	sp,sp,96
    80003f8a:	8082                	ret
      iunlock(ip);
    80003f8c:	854e                	mv	a0,s3
    80003f8e:	00000097          	auipc	ra,0x0
    80003f92:	aac080e7          	jalr	-1364(ra) # 80003a3a <iunlock>
      return ip;
    80003f96:	bfe9                	j	80003f70 <namex+0x6a>
      iunlockput(ip);
    80003f98:	854e                	mv	a0,s3
    80003f9a:	00000097          	auipc	ra,0x0
    80003f9e:	c40080e7          	jalr	-960(ra) # 80003bda <iunlockput>
      return 0;
    80003fa2:	89e6                	mv	s3,s9
    80003fa4:	b7f1                	j	80003f70 <namex+0x6a>
  len = path - s;
    80003fa6:	40b48633          	sub	a2,s1,a1
    80003faa:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003fae:	099c5463          	bge	s8,s9,80004036 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003fb2:	4639                	li	a2,14
    80003fb4:	8552                	mv	a0,s4
    80003fb6:	ffffd097          	auipc	ra,0xffffd
    80003fba:	e32080e7          	jalr	-462(ra) # 80000de8 <memmove>
  while(*path == '/')
    80003fbe:	0004c783          	lbu	a5,0(s1)
    80003fc2:	01279763          	bne	a5,s2,80003fd0 <namex+0xca>
    path++;
    80003fc6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fc8:	0004c783          	lbu	a5,0(s1)
    80003fcc:	ff278de3          	beq	a5,s2,80003fc6 <namex+0xc0>
    ilock(ip);
    80003fd0:	854e                	mv	a0,s3
    80003fd2:	00000097          	auipc	ra,0x0
    80003fd6:	9a6080e7          	jalr	-1626(ra) # 80003978 <ilock>
    if(ip->type != T_DIR){
    80003fda:	04499783          	lh	a5,68(s3)
    80003fde:	f97793e3          	bne	a5,s7,80003f64 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003fe2:	000a8563          	beqz	s5,80003fec <namex+0xe6>
    80003fe6:	0004c783          	lbu	a5,0(s1)
    80003fea:	d3cd                	beqz	a5,80003f8c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003fec:	865a                	mv	a2,s6
    80003fee:	85d2                	mv	a1,s4
    80003ff0:	854e                	mv	a0,s3
    80003ff2:	00000097          	auipc	ra,0x0
    80003ff6:	e64080e7          	jalr	-412(ra) # 80003e56 <dirlookup>
    80003ffa:	8caa                	mv	s9,a0
    80003ffc:	dd51                	beqz	a0,80003f98 <namex+0x92>
    iunlockput(ip);
    80003ffe:	854e                	mv	a0,s3
    80004000:	00000097          	auipc	ra,0x0
    80004004:	bda080e7          	jalr	-1062(ra) # 80003bda <iunlockput>
    ip = next;
    80004008:	89e6                	mv	s3,s9
  while(*path == '/')
    8000400a:	0004c783          	lbu	a5,0(s1)
    8000400e:	05279763          	bne	a5,s2,8000405c <namex+0x156>
    path++;
    80004012:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004014:	0004c783          	lbu	a5,0(s1)
    80004018:	ff278de3          	beq	a5,s2,80004012 <namex+0x10c>
  if(*path == 0)
    8000401c:	c79d                	beqz	a5,8000404a <namex+0x144>
    path++;
    8000401e:	85a6                	mv	a1,s1
  len = path - s;
    80004020:	8cda                	mv	s9,s6
    80004022:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004024:	01278963          	beq	a5,s2,80004036 <namex+0x130>
    80004028:	dfbd                	beqz	a5,80003fa6 <namex+0xa0>
    path++;
    8000402a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000402c:	0004c783          	lbu	a5,0(s1)
    80004030:	ff279ce3          	bne	a5,s2,80004028 <namex+0x122>
    80004034:	bf8d                	j	80003fa6 <namex+0xa0>
    memmove(name, s, len);
    80004036:	2601                	sext.w	a2,a2
    80004038:	8552                	mv	a0,s4
    8000403a:	ffffd097          	auipc	ra,0xffffd
    8000403e:	dae080e7          	jalr	-594(ra) # 80000de8 <memmove>
    name[len] = 0;
    80004042:	9cd2                	add	s9,s9,s4
    80004044:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004048:	bf9d                	j	80003fbe <namex+0xb8>
  if(nameiparent){
    8000404a:	f20a83e3          	beqz	s5,80003f70 <namex+0x6a>
    iput(ip);
    8000404e:	854e                	mv	a0,s3
    80004050:	00000097          	auipc	ra,0x0
    80004054:	ae2080e7          	jalr	-1310(ra) # 80003b32 <iput>
    return 0;
    80004058:	4981                	li	s3,0
    8000405a:	bf19                	j	80003f70 <namex+0x6a>
  if(*path == 0)
    8000405c:	d7fd                	beqz	a5,8000404a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000405e:	0004c783          	lbu	a5,0(s1)
    80004062:	85a6                	mv	a1,s1
    80004064:	b7d1                	j	80004028 <namex+0x122>

0000000080004066 <dirlink>:
{
    80004066:	7139                	addi	sp,sp,-64
    80004068:	fc06                	sd	ra,56(sp)
    8000406a:	f822                	sd	s0,48(sp)
    8000406c:	f426                	sd	s1,40(sp)
    8000406e:	f04a                	sd	s2,32(sp)
    80004070:	ec4e                	sd	s3,24(sp)
    80004072:	e852                	sd	s4,16(sp)
    80004074:	0080                	addi	s0,sp,64
    80004076:	892a                	mv	s2,a0
    80004078:	8a2e                	mv	s4,a1
    8000407a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000407c:	4601                	li	a2,0
    8000407e:	00000097          	auipc	ra,0x0
    80004082:	dd8080e7          	jalr	-552(ra) # 80003e56 <dirlookup>
    80004086:	e93d                	bnez	a0,800040fc <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004088:	04c92483          	lw	s1,76(s2)
    8000408c:	c49d                	beqz	s1,800040ba <dirlink+0x54>
    8000408e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004090:	4741                	li	a4,16
    80004092:	86a6                	mv	a3,s1
    80004094:	fc040613          	addi	a2,s0,-64
    80004098:	4581                	li	a1,0
    8000409a:	854a                	mv	a0,s2
    8000409c:	00000097          	auipc	ra,0x0
    800040a0:	b90080e7          	jalr	-1136(ra) # 80003c2c <readi>
    800040a4:	47c1                	li	a5,16
    800040a6:	06f51163          	bne	a0,a5,80004108 <dirlink+0xa2>
    if(de.inum == 0)
    800040aa:	fc045783          	lhu	a5,-64(s0)
    800040ae:	c791                	beqz	a5,800040ba <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040b0:	24c1                	addiw	s1,s1,16
    800040b2:	04c92783          	lw	a5,76(s2)
    800040b6:	fcf4ede3          	bltu	s1,a5,80004090 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800040ba:	4639                	li	a2,14
    800040bc:	85d2                	mv	a1,s4
    800040be:	fc240513          	addi	a0,s0,-62
    800040c2:	ffffd097          	auipc	ra,0xffffd
    800040c6:	dde080e7          	jalr	-546(ra) # 80000ea0 <strncpy>
  de.inum = inum;
    800040ca:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040ce:	4741                	li	a4,16
    800040d0:	86a6                	mv	a3,s1
    800040d2:	fc040613          	addi	a2,s0,-64
    800040d6:	4581                	li	a1,0
    800040d8:	854a                	mv	a0,s2
    800040da:	00000097          	auipc	ra,0x0
    800040de:	c48080e7          	jalr	-952(ra) # 80003d22 <writei>
    800040e2:	872a                	mv	a4,a0
    800040e4:	47c1                	li	a5,16
  return 0;
    800040e6:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040e8:	02f71863          	bne	a4,a5,80004118 <dirlink+0xb2>
}
    800040ec:	70e2                	ld	ra,56(sp)
    800040ee:	7442                	ld	s0,48(sp)
    800040f0:	74a2                	ld	s1,40(sp)
    800040f2:	7902                	ld	s2,32(sp)
    800040f4:	69e2                	ld	s3,24(sp)
    800040f6:	6a42                	ld	s4,16(sp)
    800040f8:	6121                	addi	sp,sp,64
    800040fa:	8082                	ret
    iput(ip);
    800040fc:	00000097          	auipc	ra,0x0
    80004100:	a36080e7          	jalr	-1482(ra) # 80003b32 <iput>
    return -1;
    80004104:	557d                	li	a0,-1
    80004106:	b7dd                	j	800040ec <dirlink+0x86>
      panic("dirlink read");
    80004108:	00004517          	auipc	a0,0x4
    8000410c:	6a850513          	addi	a0,a0,1704 # 800087b0 <syscall_names+0x1d8>
    80004110:	ffffc097          	auipc	ra,0xffffc
    80004114:	432080e7          	jalr	1074(ra) # 80000542 <panic>
    panic("dirlink");
    80004118:	00004517          	auipc	a0,0x4
    8000411c:	7b050513          	addi	a0,a0,1968 # 800088c8 <syscall_names+0x2f0>
    80004120:	ffffc097          	auipc	ra,0xffffc
    80004124:	422080e7          	jalr	1058(ra) # 80000542 <panic>

0000000080004128 <namei>:

struct inode*
namei(char *path)
{
    80004128:	1101                	addi	sp,sp,-32
    8000412a:	ec06                	sd	ra,24(sp)
    8000412c:	e822                	sd	s0,16(sp)
    8000412e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004130:	fe040613          	addi	a2,s0,-32
    80004134:	4581                	li	a1,0
    80004136:	00000097          	auipc	ra,0x0
    8000413a:	dd0080e7          	jalr	-560(ra) # 80003f06 <namex>
}
    8000413e:	60e2                	ld	ra,24(sp)
    80004140:	6442                	ld	s0,16(sp)
    80004142:	6105                	addi	sp,sp,32
    80004144:	8082                	ret

0000000080004146 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004146:	1141                	addi	sp,sp,-16
    80004148:	e406                	sd	ra,8(sp)
    8000414a:	e022                	sd	s0,0(sp)
    8000414c:	0800                	addi	s0,sp,16
    8000414e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004150:	4585                	li	a1,1
    80004152:	00000097          	auipc	ra,0x0
    80004156:	db4080e7          	jalr	-588(ra) # 80003f06 <namex>
}
    8000415a:	60a2                	ld	ra,8(sp)
    8000415c:	6402                	ld	s0,0(sp)
    8000415e:	0141                	addi	sp,sp,16
    80004160:	8082                	ret

0000000080004162 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004162:	1101                	addi	sp,sp,-32
    80004164:	ec06                	sd	ra,24(sp)
    80004166:	e822                	sd	s0,16(sp)
    80004168:	e426                	sd	s1,8(sp)
    8000416a:	e04a                	sd	s2,0(sp)
    8000416c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000416e:	0001e917          	auipc	s2,0x1e
    80004172:	79a90913          	addi	s2,s2,1946 # 80022908 <log>
    80004176:	01892583          	lw	a1,24(s2)
    8000417a:	02892503          	lw	a0,40(s2)
    8000417e:	fffff097          	auipc	ra,0xfffff
    80004182:	ff8080e7          	jalr	-8(ra) # 80003176 <bread>
    80004186:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004188:	02c92683          	lw	a3,44(s2)
    8000418c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000418e:	02d05763          	blez	a3,800041bc <write_head+0x5a>
    80004192:	0001e797          	auipc	a5,0x1e
    80004196:	7a678793          	addi	a5,a5,1958 # 80022938 <log+0x30>
    8000419a:	05c50713          	addi	a4,a0,92
    8000419e:	36fd                	addiw	a3,a3,-1
    800041a0:	1682                	slli	a3,a3,0x20
    800041a2:	9281                	srli	a3,a3,0x20
    800041a4:	068a                	slli	a3,a3,0x2
    800041a6:	0001e617          	auipc	a2,0x1e
    800041aa:	79660613          	addi	a2,a2,1942 # 8002293c <log+0x34>
    800041ae:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800041b0:	4390                	lw	a2,0(a5)
    800041b2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041b4:	0791                	addi	a5,a5,4
    800041b6:	0711                	addi	a4,a4,4
    800041b8:	fed79ce3          	bne	a5,a3,800041b0 <write_head+0x4e>
  }
  bwrite(buf);
    800041bc:	8526                	mv	a0,s1
    800041be:	fffff097          	auipc	ra,0xfffff
    800041c2:	0aa080e7          	jalr	170(ra) # 80003268 <bwrite>
  brelse(buf);
    800041c6:	8526                	mv	a0,s1
    800041c8:	fffff097          	auipc	ra,0xfffff
    800041cc:	0de080e7          	jalr	222(ra) # 800032a6 <brelse>
}
    800041d0:	60e2                	ld	ra,24(sp)
    800041d2:	6442                	ld	s0,16(sp)
    800041d4:	64a2                	ld	s1,8(sp)
    800041d6:	6902                	ld	s2,0(sp)
    800041d8:	6105                	addi	sp,sp,32
    800041da:	8082                	ret

00000000800041dc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041dc:	0001e797          	auipc	a5,0x1e
    800041e0:	7587a783          	lw	a5,1880(a5) # 80022934 <log+0x2c>
    800041e4:	0af05663          	blez	a5,80004290 <install_trans+0xb4>
{
    800041e8:	7139                	addi	sp,sp,-64
    800041ea:	fc06                	sd	ra,56(sp)
    800041ec:	f822                	sd	s0,48(sp)
    800041ee:	f426                	sd	s1,40(sp)
    800041f0:	f04a                	sd	s2,32(sp)
    800041f2:	ec4e                	sd	s3,24(sp)
    800041f4:	e852                	sd	s4,16(sp)
    800041f6:	e456                	sd	s5,8(sp)
    800041f8:	0080                	addi	s0,sp,64
    800041fa:	0001ea97          	auipc	s5,0x1e
    800041fe:	73ea8a93          	addi	s5,s5,1854 # 80022938 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004202:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004204:	0001e997          	auipc	s3,0x1e
    80004208:	70498993          	addi	s3,s3,1796 # 80022908 <log>
    8000420c:	0189a583          	lw	a1,24(s3)
    80004210:	014585bb          	addw	a1,a1,s4
    80004214:	2585                	addiw	a1,a1,1
    80004216:	0289a503          	lw	a0,40(s3)
    8000421a:	fffff097          	auipc	ra,0xfffff
    8000421e:	f5c080e7          	jalr	-164(ra) # 80003176 <bread>
    80004222:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004224:	000aa583          	lw	a1,0(s5)
    80004228:	0289a503          	lw	a0,40(s3)
    8000422c:	fffff097          	auipc	ra,0xfffff
    80004230:	f4a080e7          	jalr	-182(ra) # 80003176 <bread>
    80004234:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004236:	40000613          	li	a2,1024
    8000423a:	05890593          	addi	a1,s2,88
    8000423e:	05850513          	addi	a0,a0,88
    80004242:	ffffd097          	auipc	ra,0xffffd
    80004246:	ba6080e7          	jalr	-1114(ra) # 80000de8 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000424a:	8526                	mv	a0,s1
    8000424c:	fffff097          	auipc	ra,0xfffff
    80004250:	01c080e7          	jalr	28(ra) # 80003268 <bwrite>
    bunpin(dbuf);
    80004254:	8526                	mv	a0,s1
    80004256:	fffff097          	auipc	ra,0xfffff
    8000425a:	12a080e7          	jalr	298(ra) # 80003380 <bunpin>
    brelse(lbuf);
    8000425e:	854a                	mv	a0,s2
    80004260:	fffff097          	auipc	ra,0xfffff
    80004264:	046080e7          	jalr	70(ra) # 800032a6 <brelse>
    brelse(dbuf);
    80004268:	8526                	mv	a0,s1
    8000426a:	fffff097          	auipc	ra,0xfffff
    8000426e:	03c080e7          	jalr	60(ra) # 800032a6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004272:	2a05                	addiw	s4,s4,1
    80004274:	0a91                	addi	s5,s5,4
    80004276:	02c9a783          	lw	a5,44(s3)
    8000427a:	f8fa49e3          	blt	s4,a5,8000420c <install_trans+0x30>
}
    8000427e:	70e2                	ld	ra,56(sp)
    80004280:	7442                	ld	s0,48(sp)
    80004282:	74a2                	ld	s1,40(sp)
    80004284:	7902                	ld	s2,32(sp)
    80004286:	69e2                	ld	s3,24(sp)
    80004288:	6a42                	ld	s4,16(sp)
    8000428a:	6aa2                	ld	s5,8(sp)
    8000428c:	6121                	addi	sp,sp,64
    8000428e:	8082                	ret
    80004290:	8082                	ret

0000000080004292 <initlog>:
{
    80004292:	7179                	addi	sp,sp,-48
    80004294:	f406                	sd	ra,40(sp)
    80004296:	f022                	sd	s0,32(sp)
    80004298:	ec26                	sd	s1,24(sp)
    8000429a:	e84a                	sd	s2,16(sp)
    8000429c:	e44e                	sd	s3,8(sp)
    8000429e:	1800                	addi	s0,sp,48
    800042a0:	892a                	mv	s2,a0
    800042a2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800042a4:	0001e497          	auipc	s1,0x1e
    800042a8:	66448493          	addi	s1,s1,1636 # 80022908 <log>
    800042ac:	00004597          	auipc	a1,0x4
    800042b0:	51458593          	addi	a1,a1,1300 # 800087c0 <syscall_names+0x1e8>
    800042b4:	8526                	mv	a0,s1
    800042b6:	ffffd097          	auipc	ra,0xffffd
    800042ba:	94a080e7          	jalr	-1718(ra) # 80000c00 <initlock>
  log.start = sb->logstart;
    800042be:	0149a583          	lw	a1,20(s3)
    800042c2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800042c4:	0109a783          	lw	a5,16(s3)
    800042c8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800042ca:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042ce:	854a                	mv	a0,s2
    800042d0:	fffff097          	auipc	ra,0xfffff
    800042d4:	ea6080e7          	jalr	-346(ra) # 80003176 <bread>
  log.lh.n = lh->n;
    800042d8:	4d34                	lw	a3,88(a0)
    800042da:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042dc:	02d05563          	blez	a3,80004306 <initlog+0x74>
    800042e0:	05c50793          	addi	a5,a0,92
    800042e4:	0001e717          	auipc	a4,0x1e
    800042e8:	65470713          	addi	a4,a4,1620 # 80022938 <log+0x30>
    800042ec:	36fd                	addiw	a3,a3,-1
    800042ee:	1682                	slli	a3,a3,0x20
    800042f0:	9281                	srli	a3,a3,0x20
    800042f2:	068a                	slli	a3,a3,0x2
    800042f4:	06050613          	addi	a2,a0,96
    800042f8:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800042fa:	4390                	lw	a2,0(a5)
    800042fc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042fe:	0791                	addi	a5,a5,4
    80004300:	0711                	addi	a4,a4,4
    80004302:	fed79ce3          	bne	a5,a3,800042fa <initlog+0x68>
  brelse(buf);
    80004306:	fffff097          	auipc	ra,0xfffff
    8000430a:	fa0080e7          	jalr	-96(ra) # 800032a6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    8000430e:	00000097          	auipc	ra,0x0
    80004312:	ece080e7          	jalr	-306(ra) # 800041dc <install_trans>
  log.lh.n = 0;
    80004316:	0001e797          	auipc	a5,0x1e
    8000431a:	6007af23          	sw	zero,1566(a5) # 80022934 <log+0x2c>
  write_head(); // clear the log
    8000431e:	00000097          	auipc	ra,0x0
    80004322:	e44080e7          	jalr	-444(ra) # 80004162 <write_head>
}
    80004326:	70a2                	ld	ra,40(sp)
    80004328:	7402                	ld	s0,32(sp)
    8000432a:	64e2                	ld	s1,24(sp)
    8000432c:	6942                	ld	s2,16(sp)
    8000432e:	69a2                	ld	s3,8(sp)
    80004330:	6145                	addi	sp,sp,48
    80004332:	8082                	ret

0000000080004334 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004334:	1101                	addi	sp,sp,-32
    80004336:	ec06                	sd	ra,24(sp)
    80004338:	e822                	sd	s0,16(sp)
    8000433a:	e426                	sd	s1,8(sp)
    8000433c:	e04a                	sd	s2,0(sp)
    8000433e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004340:	0001e517          	auipc	a0,0x1e
    80004344:	5c850513          	addi	a0,a0,1480 # 80022908 <log>
    80004348:	ffffd097          	auipc	ra,0xffffd
    8000434c:	948080e7          	jalr	-1720(ra) # 80000c90 <acquire>
  while(1){
    if(log.committing){
    80004350:	0001e497          	auipc	s1,0x1e
    80004354:	5b848493          	addi	s1,s1,1464 # 80022908 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004358:	4979                	li	s2,30
    8000435a:	a039                	j	80004368 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000435c:	85a6                	mv	a1,s1
    8000435e:	8526                	mv	a0,s1
    80004360:	ffffe097          	auipc	ra,0xffffe
    80004364:	f1e080e7          	jalr	-226(ra) # 8000227e <sleep>
    if(log.committing){
    80004368:	50dc                	lw	a5,36(s1)
    8000436a:	fbed                	bnez	a5,8000435c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000436c:	509c                	lw	a5,32(s1)
    8000436e:	0017871b          	addiw	a4,a5,1
    80004372:	0007069b          	sext.w	a3,a4
    80004376:	0027179b          	slliw	a5,a4,0x2
    8000437a:	9fb9                	addw	a5,a5,a4
    8000437c:	0017979b          	slliw	a5,a5,0x1
    80004380:	54d8                	lw	a4,44(s1)
    80004382:	9fb9                	addw	a5,a5,a4
    80004384:	00f95963          	bge	s2,a5,80004396 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004388:	85a6                	mv	a1,s1
    8000438a:	8526                	mv	a0,s1
    8000438c:	ffffe097          	auipc	ra,0xffffe
    80004390:	ef2080e7          	jalr	-270(ra) # 8000227e <sleep>
    80004394:	bfd1                	j	80004368 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004396:	0001e517          	auipc	a0,0x1e
    8000439a:	57250513          	addi	a0,a0,1394 # 80022908 <log>
    8000439e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800043a0:	ffffd097          	auipc	ra,0xffffd
    800043a4:	9a4080e7          	jalr	-1628(ra) # 80000d44 <release>
      break;
    }
  }
}
    800043a8:	60e2                	ld	ra,24(sp)
    800043aa:	6442                	ld	s0,16(sp)
    800043ac:	64a2                	ld	s1,8(sp)
    800043ae:	6902                	ld	s2,0(sp)
    800043b0:	6105                	addi	sp,sp,32
    800043b2:	8082                	ret

00000000800043b4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800043b4:	7139                	addi	sp,sp,-64
    800043b6:	fc06                	sd	ra,56(sp)
    800043b8:	f822                	sd	s0,48(sp)
    800043ba:	f426                	sd	s1,40(sp)
    800043bc:	f04a                	sd	s2,32(sp)
    800043be:	ec4e                	sd	s3,24(sp)
    800043c0:	e852                	sd	s4,16(sp)
    800043c2:	e456                	sd	s5,8(sp)
    800043c4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800043c6:	0001e497          	auipc	s1,0x1e
    800043ca:	54248493          	addi	s1,s1,1346 # 80022908 <log>
    800043ce:	8526                	mv	a0,s1
    800043d0:	ffffd097          	auipc	ra,0xffffd
    800043d4:	8c0080e7          	jalr	-1856(ra) # 80000c90 <acquire>
  log.outstanding -= 1;
    800043d8:	509c                	lw	a5,32(s1)
    800043da:	37fd                	addiw	a5,a5,-1
    800043dc:	0007891b          	sext.w	s2,a5
    800043e0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800043e2:	50dc                	lw	a5,36(s1)
    800043e4:	e7b9                	bnez	a5,80004432 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800043e6:	04091e63          	bnez	s2,80004442 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800043ea:	0001e497          	auipc	s1,0x1e
    800043ee:	51e48493          	addi	s1,s1,1310 # 80022908 <log>
    800043f2:	4785                	li	a5,1
    800043f4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043f6:	8526                	mv	a0,s1
    800043f8:	ffffd097          	auipc	ra,0xffffd
    800043fc:	94c080e7          	jalr	-1716(ra) # 80000d44 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004400:	54dc                	lw	a5,44(s1)
    80004402:	06f04763          	bgtz	a5,80004470 <end_op+0xbc>
    acquire(&log.lock);
    80004406:	0001e497          	auipc	s1,0x1e
    8000440a:	50248493          	addi	s1,s1,1282 # 80022908 <log>
    8000440e:	8526                	mv	a0,s1
    80004410:	ffffd097          	auipc	ra,0xffffd
    80004414:	880080e7          	jalr	-1920(ra) # 80000c90 <acquire>
    log.committing = 0;
    80004418:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000441c:	8526                	mv	a0,s1
    8000441e:	ffffe097          	auipc	ra,0xffffe
    80004422:	fe0080e7          	jalr	-32(ra) # 800023fe <wakeup>
    release(&log.lock);
    80004426:	8526                	mv	a0,s1
    80004428:	ffffd097          	auipc	ra,0xffffd
    8000442c:	91c080e7          	jalr	-1764(ra) # 80000d44 <release>
}
    80004430:	a03d                	j	8000445e <end_op+0xaa>
    panic("log.committing");
    80004432:	00004517          	auipc	a0,0x4
    80004436:	39650513          	addi	a0,a0,918 # 800087c8 <syscall_names+0x1f0>
    8000443a:	ffffc097          	auipc	ra,0xffffc
    8000443e:	108080e7          	jalr	264(ra) # 80000542 <panic>
    wakeup(&log);
    80004442:	0001e497          	auipc	s1,0x1e
    80004446:	4c648493          	addi	s1,s1,1222 # 80022908 <log>
    8000444a:	8526                	mv	a0,s1
    8000444c:	ffffe097          	auipc	ra,0xffffe
    80004450:	fb2080e7          	jalr	-78(ra) # 800023fe <wakeup>
  release(&log.lock);
    80004454:	8526                	mv	a0,s1
    80004456:	ffffd097          	auipc	ra,0xffffd
    8000445a:	8ee080e7          	jalr	-1810(ra) # 80000d44 <release>
}
    8000445e:	70e2                	ld	ra,56(sp)
    80004460:	7442                	ld	s0,48(sp)
    80004462:	74a2                	ld	s1,40(sp)
    80004464:	7902                	ld	s2,32(sp)
    80004466:	69e2                	ld	s3,24(sp)
    80004468:	6a42                	ld	s4,16(sp)
    8000446a:	6aa2                	ld	s5,8(sp)
    8000446c:	6121                	addi	sp,sp,64
    8000446e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004470:	0001ea97          	auipc	s5,0x1e
    80004474:	4c8a8a93          	addi	s5,s5,1224 # 80022938 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004478:	0001ea17          	auipc	s4,0x1e
    8000447c:	490a0a13          	addi	s4,s4,1168 # 80022908 <log>
    80004480:	018a2583          	lw	a1,24(s4)
    80004484:	012585bb          	addw	a1,a1,s2
    80004488:	2585                	addiw	a1,a1,1
    8000448a:	028a2503          	lw	a0,40(s4)
    8000448e:	fffff097          	auipc	ra,0xfffff
    80004492:	ce8080e7          	jalr	-792(ra) # 80003176 <bread>
    80004496:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004498:	000aa583          	lw	a1,0(s5)
    8000449c:	028a2503          	lw	a0,40(s4)
    800044a0:	fffff097          	auipc	ra,0xfffff
    800044a4:	cd6080e7          	jalr	-810(ra) # 80003176 <bread>
    800044a8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800044aa:	40000613          	li	a2,1024
    800044ae:	05850593          	addi	a1,a0,88
    800044b2:	05848513          	addi	a0,s1,88
    800044b6:	ffffd097          	auipc	ra,0xffffd
    800044ba:	932080e7          	jalr	-1742(ra) # 80000de8 <memmove>
    bwrite(to);  // write the log
    800044be:	8526                	mv	a0,s1
    800044c0:	fffff097          	auipc	ra,0xfffff
    800044c4:	da8080e7          	jalr	-600(ra) # 80003268 <bwrite>
    brelse(from);
    800044c8:	854e                	mv	a0,s3
    800044ca:	fffff097          	auipc	ra,0xfffff
    800044ce:	ddc080e7          	jalr	-548(ra) # 800032a6 <brelse>
    brelse(to);
    800044d2:	8526                	mv	a0,s1
    800044d4:	fffff097          	auipc	ra,0xfffff
    800044d8:	dd2080e7          	jalr	-558(ra) # 800032a6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044dc:	2905                	addiw	s2,s2,1
    800044de:	0a91                	addi	s5,s5,4
    800044e0:	02ca2783          	lw	a5,44(s4)
    800044e4:	f8f94ee3          	blt	s2,a5,80004480 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044e8:	00000097          	auipc	ra,0x0
    800044ec:	c7a080e7          	jalr	-902(ra) # 80004162 <write_head>
    install_trans(); // Now install writes to home locations
    800044f0:	00000097          	auipc	ra,0x0
    800044f4:	cec080e7          	jalr	-788(ra) # 800041dc <install_trans>
    log.lh.n = 0;
    800044f8:	0001e797          	auipc	a5,0x1e
    800044fc:	4207ae23          	sw	zero,1084(a5) # 80022934 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004500:	00000097          	auipc	ra,0x0
    80004504:	c62080e7          	jalr	-926(ra) # 80004162 <write_head>
    80004508:	bdfd                	j	80004406 <end_op+0x52>

000000008000450a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000450a:	1101                	addi	sp,sp,-32
    8000450c:	ec06                	sd	ra,24(sp)
    8000450e:	e822                	sd	s0,16(sp)
    80004510:	e426                	sd	s1,8(sp)
    80004512:	e04a                	sd	s2,0(sp)
    80004514:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004516:	0001e717          	auipc	a4,0x1e
    8000451a:	41e72703          	lw	a4,1054(a4) # 80022934 <log+0x2c>
    8000451e:	47f5                	li	a5,29
    80004520:	08e7c063          	blt	a5,a4,800045a0 <log_write+0x96>
    80004524:	84aa                	mv	s1,a0
    80004526:	0001e797          	auipc	a5,0x1e
    8000452a:	3fe7a783          	lw	a5,1022(a5) # 80022924 <log+0x1c>
    8000452e:	37fd                	addiw	a5,a5,-1
    80004530:	06f75863          	bge	a4,a5,800045a0 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004534:	0001e797          	auipc	a5,0x1e
    80004538:	3f47a783          	lw	a5,1012(a5) # 80022928 <log+0x20>
    8000453c:	06f05a63          	blez	a5,800045b0 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004540:	0001e917          	auipc	s2,0x1e
    80004544:	3c890913          	addi	s2,s2,968 # 80022908 <log>
    80004548:	854a                	mv	a0,s2
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	746080e7          	jalr	1862(ra) # 80000c90 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004552:	02c92603          	lw	a2,44(s2)
    80004556:	06c05563          	blez	a2,800045c0 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000455a:	44cc                	lw	a1,12(s1)
    8000455c:	0001e717          	auipc	a4,0x1e
    80004560:	3dc70713          	addi	a4,a4,988 # 80022938 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004564:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004566:	4314                	lw	a3,0(a4)
    80004568:	04b68d63          	beq	a3,a1,800045c2 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    8000456c:	2785                	addiw	a5,a5,1
    8000456e:	0711                	addi	a4,a4,4
    80004570:	fec79be3          	bne	a5,a2,80004566 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004574:	0621                	addi	a2,a2,8
    80004576:	060a                	slli	a2,a2,0x2
    80004578:	0001e797          	auipc	a5,0x1e
    8000457c:	39078793          	addi	a5,a5,912 # 80022908 <log>
    80004580:	963e                	add	a2,a2,a5
    80004582:	44dc                	lw	a5,12(s1)
    80004584:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004586:	8526                	mv	a0,s1
    80004588:	fffff097          	auipc	ra,0xfffff
    8000458c:	dbc080e7          	jalr	-580(ra) # 80003344 <bpin>
    log.lh.n++;
    80004590:	0001e717          	auipc	a4,0x1e
    80004594:	37870713          	addi	a4,a4,888 # 80022908 <log>
    80004598:	575c                	lw	a5,44(a4)
    8000459a:	2785                	addiw	a5,a5,1
    8000459c:	d75c                	sw	a5,44(a4)
    8000459e:	a83d                	j	800045dc <log_write+0xd2>
    panic("too big a transaction");
    800045a0:	00004517          	auipc	a0,0x4
    800045a4:	23850513          	addi	a0,a0,568 # 800087d8 <syscall_names+0x200>
    800045a8:	ffffc097          	auipc	ra,0xffffc
    800045ac:	f9a080e7          	jalr	-102(ra) # 80000542 <panic>
    panic("log_write outside of trans");
    800045b0:	00004517          	auipc	a0,0x4
    800045b4:	24050513          	addi	a0,a0,576 # 800087f0 <syscall_names+0x218>
    800045b8:	ffffc097          	auipc	ra,0xffffc
    800045bc:	f8a080e7          	jalr	-118(ra) # 80000542 <panic>
  for (i = 0; i < log.lh.n; i++) {
    800045c0:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    800045c2:	00878713          	addi	a4,a5,8
    800045c6:	00271693          	slli	a3,a4,0x2
    800045ca:	0001e717          	auipc	a4,0x1e
    800045ce:	33e70713          	addi	a4,a4,830 # 80022908 <log>
    800045d2:	9736                	add	a4,a4,a3
    800045d4:	44d4                	lw	a3,12(s1)
    800045d6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045d8:	faf607e3          	beq	a2,a5,80004586 <log_write+0x7c>
  }
  release(&log.lock);
    800045dc:	0001e517          	auipc	a0,0x1e
    800045e0:	32c50513          	addi	a0,a0,812 # 80022908 <log>
    800045e4:	ffffc097          	auipc	ra,0xffffc
    800045e8:	760080e7          	jalr	1888(ra) # 80000d44 <release>
}
    800045ec:	60e2                	ld	ra,24(sp)
    800045ee:	6442                	ld	s0,16(sp)
    800045f0:	64a2                	ld	s1,8(sp)
    800045f2:	6902                	ld	s2,0(sp)
    800045f4:	6105                	addi	sp,sp,32
    800045f6:	8082                	ret

00000000800045f8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045f8:	1101                	addi	sp,sp,-32
    800045fa:	ec06                	sd	ra,24(sp)
    800045fc:	e822                	sd	s0,16(sp)
    800045fe:	e426                	sd	s1,8(sp)
    80004600:	e04a                	sd	s2,0(sp)
    80004602:	1000                	addi	s0,sp,32
    80004604:	84aa                	mv	s1,a0
    80004606:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004608:	00004597          	auipc	a1,0x4
    8000460c:	20858593          	addi	a1,a1,520 # 80008810 <syscall_names+0x238>
    80004610:	0521                	addi	a0,a0,8
    80004612:	ffffc097          	auipc	ra,0xffffc
    80004616:	5ee080e7          	jalr	1518(ra) # 80000c00 <initlock>
  lk->name = name;
    8000461a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000461e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004622:	0204a423          	sw	zero,40(s1)
}
    80004626:	60e2                	ld	ra,24(sp)
    80004628:	6442                	ld	s0,16(sp)
    8000462a:	64a2                	ld	s1,8(sp)
    8000462c:	6902                	ld	s2,0(sp)
    8000462e:	6105                	addi	sp,sp,32
    80004630:	8082                	ret

0000000080004632 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004632:	1101                	addi	sp,sp,-32
    80004634:	ec06                	sd	ra,24(sp)
    80004636:	e822                	sd	s0,16(sp)
    80004638:	e426                	sd	s1,8(sp)
    8000463a:	e04a                	sd	s2,0(sp)
    8000463c:	1000                	addi	s0,sp,32
    8000463e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004640:	00850913          	addi	s2,a0,8
    80004644:	854a                	mv	a0,s2
    80004646:	ffffc097          	auipc	ra,0xffffc
    8000464a:	64a080e7          	jalr	1610(ra) # 80000c90 <acquire>
  while (lk->locked) {
    8000464e:	409c                	lw	a5,0(s1)
    80004650:	cb89                	beqz	a5,80004662 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004652:	85ca                	mv	a1,s2
    80004654:	8526                	mv	a0,s1
    80004656:	ffffe097          	auipc	ra,0xffffe
    8000465a:	c28080e7          	jalr	-984(ra) # 8000227e <sleep>
  while (lk->locked) {
    8000465e:	409c                	lw	a5,0(s1)
    80004660:	fbed                	bnez	a5,80004652 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004662:	4785                	li	a5,1
    80004664:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004666:	ffffd097          	auipc	ra,0xffffd
    8000466a:	3f6080e7          	jalr	1014(ra) # 80001a5c <myproc>
    8000466e:	5d1c                	lw	a5,56(a0)
    80004670:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004672:	854a                	mv	a0,s2
    80004674:	ffffc097          	auipc	ra,0xffffc
    80004678:	6d0080e7          	jalr	1744(ra) # 80000d44 <release>
}
    8000467c:	60e2                	ld	ra,24(sp)
    8000467e:	6442                	ld	s0,16(sp)
    80004680:	64a2                	ld	s1,8(sp)
    80004682:	6902                	ld	s2,0(sp)
    80004684:	6105                	addi	sp,sp,32
    80004686:	8082                	ret

0000000080004688 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004688:	1101                	addi	sp,sp,-32
    8000468a:	ec06                	sd	ra,24(sp)
    8000468c:	e822                	sd	s0,16(sp)
    8000468e:	e426                	sd	s1,8(sp)
    80004690:	e04a                	sd	s2,0(sp)
    80004692:	1000                	addi	s0,sp,32
    80004694:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004696:	00850913          	addi	s2,a0,8
    8000469a:	854a                	mv	a0,s2
    8000469c:	ffffc097          	auipc	ra,0xffffc
    800046a0:	5f4080e7          	jalr	1524(ra) # 80000c90 <acquire>
  lk->locked = 0;
    800046a4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046a8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800046ac:	8526                	mv	a0,s1
    800046ae:	ffffe097          	auipc	ra,0xffffe
    800046b2:	d50080e7          	jalr	-688(ra) # 800023fe <wakeup>
  release(&lk->lk);
    800046b6:	854a                	mv	a0,s2
    800046b8:	ffffc097          	auipc	ra,0xffffc
    800046bc:	68c080e7          	jalr	1676(ra) # 80000d44 <release>
}
    800046c0:	60e2                	ld	ra,24(sp)
    800046c2:	6442                	ld	s0,16(sp)
    800046c4:	64a2                	ld	s1,8(sp)
    800046c6:	6902                	ld	s2,0(sp)
    800046c8:	6105                	addi	sp,sp,32
    800046ca:	8082                	ret

00000000800046cc <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800046cc:	7179                	addi	sp,sp,-48
    800046ce:	f406                	sd	ra,40(sp)
    800046d0:	f022                	sd	s0,32(sp)
    800046d2:	ec26                	sd	s1,24(sp)
    800046d4:	e84a                	sd	s2,16(sp)
    800046d6:	e44e                	sd	s3,8(sp)
    800046d8:	1800                	addi	s0,sp,48
    800046da:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046dc:	00850913          	addi	s2,a0,8
    800046e0:	854a                	mv	a0,s2
    800046e2:	ffffc097          	auipc	ra,0xffffc
    800046e6:	5ae080e7          	jalr	1454(ra) # 80000c90 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046ea:	409c                	lw	a5,0(s1)
    800046ec:	ef99                	bnez	a5,8000470a <holdingsleep+0x3e>
    800046ee:	4481                	li	s1,0
  release(&lk->lk);
    800046f0:	854a                	mv	a0,s2
    800046f2:	ffffc097          	auipc	ra,0xffffc
    800046f6:	652080e7          	jalr	1618(ra) # 80000d44 <release>
  return r;
}
    800046fa:	8526                	mv	a0,s1
    800046fc:	70a2                	ld	ra,40(sp)
    800046fe:	7402                	ld	s0,32(sp)
    80004700:	64e2                	ld	s1,24(sp)
    80004702:	6942                	ld	s2,16(sp)
    80004704:	69a2                	ld	s3,8(sp)
    80004706:	6145                	addi	sp,sp,48
    80004708:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000470a:	0284a983          	lw	s3,40(s1)
    8000470e:	ffffd097          	auipc	ra,0xffffd
    80004712:	34e080e7          	jalr	846(ra) # 80001a5c <myproc>
    80004716:	5d04                	lw	s1,56(a0)
    80004718:	413484b3          	sub	s1,s1,s3
    8000471c:	0014b493          	seqz	s1,s1
    80004720:	bfc1                	j	800046f0 <holdingsleep+0x24>

0000000080004722 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004722:	1141                	addi	sp,sp,-16
    80004724:	e406                	sd	ra,8(sp)
    80004726:	e022                	sd	s0,0(sp)
    80004728:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000472a:	00004597          	auipc	a1,0x4
    8000472e:	0f658593          	addi	a1,a1,246 # 80008820 <syscall_names+0x248>
    80004732:	0001e517          	auipc	a0,0x1e
    80004736:	31e50513          	addi	a0,a0,798 # 80022a50 <ftable>
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	4c6080e7          	jalr	1222(ra) # 80000c00 <initlock>
}
    80004742:	60a2                	ld	ra,8(sp)
    80004744:	6402                	ld	s0,0(sp)
    80004746:	0141                	addi	sp,sp,16
    80004748:	8082                	ret

000000008000474a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000474a:	1101                	addi	sp,sp,-32
    8000474c:	ec06                	sd	ra,24(sp)
    8000474e:	e822                	sd	s0,16(sp)
    80004750:	e426                	sd	s1,8(sp)
    80004752:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004754:	0001e517          	auipc	a0,0x1e
    80004758:	2fc50513          	addi	a0,a0,764 # 80022a50 <ftable>
    8000475c:	ffffc097          	auipc	ra,0xffffc
    80004760:	534080e7          	jalr	1332(ra) # 80000c90 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004764:	0001e497          	auipc	s1,0x1e
    80004768:	30448493          	addi	s1,s1,772 # 80022a68 <ftable+0x18>
    8000476c:	0001f717          	auipc	a4,0x1f
    80004770:	29c70713          	addi	a4,a4,668 # 80023a08 <ftable+0xfb8>
    if(f->ref == 0){
    80004774:	40dc                	lw	a5,4(s1)
    80004776:	cf99                	beqz	a5,80004794 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004778:	02848493          	addi	s1,s1,40
    8000477c:	fee49ce3          	bne	s1,a4,80004774 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004780:	0001e517          	auipc	a0,0x1e
    80004784:	2d050513          	addi	a0,a0,720 # 80022a50 <ftable>
    80004788:	ffffc097          	auipc	ra,0xffffc
    8000478c:	5bc080e7          	jalr	1468(ra) # 80000d44 <release>
  return 0;
    80004790:	4481                	li	s1,0
    80004792:	a819                	j	800047a8 <filealloc+0x5e>
      f->ref = 1;
    80004794:	4785                	li	a5,1
    80004796:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004798:	0001e517          	auipc	a0,0x1e
    8000479c:	2b850513          	addi	a0,a0,696 # 80022a50 <ftable>
    800047a0:	ffffc097          	auipc	ra,0xffffc
    800047a4:	5a4080e7          	jalr	1444(ra) # 80000d44 <release>
}
    800047a8:	8526                	mv	a0,s1
    800047aa:	60e2                	ld	ra,24(sp)
    800047ac:	6442                	ld	s0,16(sp)
    800047ae:	64a2                	ld	s1,8(sp)
    800047b0:	6105                	addi	sp,sp,32
    800047b2:	8082                	ret

00000000800047b4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047b4:	1101                	addi	sp,sp,-32
    800047b6:	ec06                	sd	ra,24(sp)
    800047b8:	e822                	sd	s0,16(sp)
    800047ba:	e426                	sd	s1,8(sp)
    800047bc:	1000                	addi	s0,sp,32
    800047be:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047c0:	0001e517          	auipc	a0,0x1e
    800047c4:	29050513          	addi	a0,a0,656 # 80022a50 <ftable>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	4c8080e7          	jalr	1224(ra) # 80000c90 <acquire>
  if(f->ref < 1)
    800047d0:	40dc                	lw	a5,4(s1)
    800047d2:	02f05263          	blez	a5,800047f6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047d6:	2785                	addiw	a5,a5,1
    800047d8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047da:	0001e517          	auipc	a0,0x1e
    800047de:	27650513          	addi	a0,a0,630 # 80022a50 <ftable>
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	562080e7          	jalr	1378(ra) # 80000d44 <release>
  return f;
}
    800047ea:	8526                	mv	a0,s1
    800047ec:	60e2                	ld	ra,24(sp)
    800047ee:	6442                	ld	s0,16(sp)
    800047f0:	64a2                	ld	s1,8(sp)
    800047f2:	6105                	addi	sp,sp,32
    800047f4:	8082                	ret
    panic("filedup");
    800047f6:	00004517          	auipc	a0,0x4
    800047fa:	03250513          	addi	a0,a0,50 # 80008828 <syscall_names+0x250>
    800047fe:	ffffc097          	auipc	ra,0xffffc
    80004802:	d44080e7          	jalr	-700(ra) # 80000542 <panic>

0000000080004806 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004806:	7139                	addi	sp,sp,-64
    80004808:	fc06                	sd	ra,56(sp)
    8000480a:	f822                	sd	s0,48(sp)
    8000480c:	f426                	sd	s1,40(sp)
    8000480e:	f04a                	sd	s2,32(sp)
    80004810:	ec4e                	sd	s3,24(sp)
    80004812:	e852                	sd	s4,16(sp)
    80004814:	e456                	sd	s5,8(sp)
    80004816:	0080                	addi	s0,sp,64
    80004818:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000481a:	0001e517          	auipc	a0,0x1e
    8000481e:	23650513          	addi	a0,a0,566 # 80022a50 <ftable>
    80004822:	ffffc097          	auipc	ra,0xffffc
    80004826:	46e080e7          	jalr	1134(ra) # 80000c90 <acquire>
  if(f->ref < 1)
    8000482a:	40dc                	lw	a5,4(s1)
    8000482c:	06f05163          	blez	a5,8000488e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004830:	37fd                	addiw	a5,a5,-1
    80004832:	0007871b          	sext.w	a4,a5
    80004836:	c0dc                	sw	a5,4(s1)
    80004838:	06e04363          	bgtz	a4,8000489e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000483c:	0004a903          	lw	s2,0(s1)
    80004840:	0094ca83          	lbu	s5,9(s1)
    80004844:	0104ba03          	ld	s4,16(s1)
    80004848:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000484c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004850:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004854:	0001e517          	auipc	a0,0x1e
    80004858:	1fc50513          	addi	a0,a0,508 # 80022a50 <ftable>
    8000485c:	ffffc097          	auipc	ra,0xffffc
    80004860:	4e8080e7          	jalr	1256(ra) # 80000d44 <release>

  if(ff.type == FD_PIPE){
    80004864:	4785                	li	a5,1
    80004866:	04f90d63          	beq	s2,a5,800048c0 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000486a:	3979                	addiw	s2,s2,-2
    8000486c:	4785                	li	a5,1
    8000486e:	0527e063          	bltu	a5,s2,800048ae <fileclose+0xa8>
    begin_op();
    80004872:	00000097          	auipc	ra,0x0
    80004876:	ac2080e7          	jalr	-1342(ra) # 80004334 <begin_op>
    iput(ff.ip);
    8000487a:	854e                	mv	a0,s3
    8000487c:	fffff097          	auipc	ra,0xfffff
    80004880:	2b6080e7          	jalr	694(ra) # 80003b32 <iput>
    end_op();
    80004884:	00000097          	auipc	ra,0x0
    80004888:	b30080e7          	jalr	-1232(ra) # 800043b4 <end_op>
    8000488c:	a00d                	j	800048ae <fileclose+0xa8>
    panic("fileclose");
    8000488e:	00004517          	auipc	a0,0x4
    80004892:	fa250513          	addi	a0,a0,-94 # 80008830 <syscall_names+0x258>
    80004896:	ffffc097          	auipc	ra,0xffffc
    8000489a:	cac080e7          	jalr	-852(ra) # 80000542 <panic>
    release(&ftable.lock);
    8000489e:	0001e517          	auipc	a0,0x1e
    800048a2:	1b250513          	addi	a0,a0,434 # 80022a50 <ftable>
    800048a6:	ffffc097          	auipc	ra,0xffffc
    800048aa:	49e080e7          	jalr	1182(ra) # 80000d44 <release>
  }
}
    800048ae:	70e2                	ld	ra,56(sp)
    800048b0:	7442                	ld	s0,48(sp)
    800048b2:	74a2                	ld	s1,40(sp)
    800048b4:	7902                	ld	s2,32(sp)
    800048b6:	69e2                	ld	s3,24(sp)
    800048b8:	6a42                	ld	s4,16(sp)
    800048ba:	6aa2                	ld	s5,8(sp)
    800048bc:	6121                	addi	sp,sp,64
    800048be:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048c0:	85d6                	mv	a1,s5
    800048c2:	8552                	mv	a0,s4
    800048c4:	00000097          	auipc	ra,0x0
    800048c8:	372080e7          	jalr	882(ra) # 80004c36 <pipeclose>
    800048cc:	b7cd                	j	800048ae <fileclose+0xa8>

00000000800048ce <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048ce:	715d                	addi	sp,sp,-80
    800048d0:	e486                	sd	ra,72(sp)
    800048d2:	e0a2                	sd	s0,64(sp)
    800048d4:	fc26                	sd	s1,56(sp)
    800048d6:	f84a                	sd	s2,48(sp)
    800048d8:	f44e                	sd	s3,40(sp)
    800048da:	0880                	addi	s0,sp,80
    800048dc:	84aa                	mv	s1,a0
    800048de:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048e0:	ffffd097          	auipc	ra,0xffffd
    800048e4:	17c080e7          	jalr	380(ra) # 80001a5c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048e8:	409c                	lw	a5,0(s1)
    800048ea:	37f9                	addiw	a5,a5,-2
    800048ec:	4705                	li	a4,1
    800048ee:	04f76763          	bltu	a4,a5,8000493c <filestat+0x6e>
    800048f2:	892a                	mv	s2,a0
    ilock(f->ip);
    800048f4:	6c88                	ld	a0,24(s1)
    800048f6:	fffff097          	auipc	ra,0xfffff
    800048fa:	082080e7          	jalr	130(ra) # 80003978 <ilock>
    stati(f->ip, &st);
    800048fe:	fb840593          	addi	a1,s0,-72
    80004902:	6c88                	ld	a0,24(s1)
    80004904:	fffff097          	auipc	ra,0xfffff
    80004908:	2fe080e7          	jalr	766(ra) # 80003c02 <stati>
    iunlock(f->ip);
    8000490c:	6c88                	ld	a0,24(s1)
    8000490e:	fffff097          	auipc	ra,0xfffff
    80004912:	12c080e7          	jalr	300(ra) # 80003a3a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004916:	46e1                	li	a3,24
    80004918:	fb840613          	addi	a2,s0,-72
    8000491c:	85ce                	mv	a1,s3
    8000491e:	05093503          	ld	a0,80(s2)
    80004922:	ffffd097          	auipc	ra,0xffffd
    80004926:	e2c080e7          	jalr	-468(ra) # 8000174e <copyout>
    8000492a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000492e:	60a6                	ld	ra,72(sp)
    80004930:	6406                	ld	s0,64(sp)
    80004932:	74e2                	ld	s1,56(sp)
    80004934:	7942                	ld	s2,48(sp)
    80004936:	79a2                	ld	s3,40(sp)
    80004938:	6161                	addi	sp,sp,80
    8000493a:	8082                	ret
  return -1;
    8000493c:	557d                	li	a0,-1
    8000493e:	bfc5                	j	8000492e <filestat+0x60>

0000000080004940 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004940:	7179                	addi	sp,sp,-48
    80004942:	f406                	sd	ra,40(sp)
    80004944:	f022                	sd	s0,32(sp)
    80004946:	ec26                	sd	s1,24(sp)
    80004948:	e84a                	sd	s2,16(sp)
    8000494a:	e44e                	sd	s3,8(sp)
    8000494c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000494e:	00854783          	lbu	a5,8(a0)
    80004952:	c3d5                	beqz	a5,800049f6 <fileread+0xb6>
    80004954:	84aa                	mv	s1,a0
    80004956:	89ae                	mv	s3,a1
    80004958:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000495a:	411c                	lw	a5,0(a0)
    8000495c:	4705                	li	a4,1
    8000495e:	04e78963          	beq	a5,a4,800049b0 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004962:	470d                	li	a4,3
    80004964:	04e78d63          	beq	a5,a4,800049be <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004968:	4709                	li	a4,2
    8000496a:	06e79e63          	bne	a5,a4,800049e6 <fileread+0xa6>
    ilock(f->ip);
    8000496e:	6d08                	ld	a0,24(a0)
    80004970:	fffff097          	auipc	ra,0xfffff
    80004974:	008080e7          	jalr	8(ra) # 80003978 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004978:	874a                	mv	a4,s2
    8000497a:	5094                	lw	a3,32(s1)
    8000497c:	864e                	mv	a2,s3
    8000497e:	4585                	li	a1,1
    80004980:	6c88                	ld	a0,24(s1)
    80004982:	fffff097          	auipc	ra,0xfffff
    80004986:	2aa080e7          	jalr	682(ra) # 80003c2c <readi>
    8000498a:	892a                	mv	s2,a0
    8000498c:	00a05563          	blez	a0,80004996 <fileread+0x56>
      f->off += r;
    80004990:	509c                	lw	a5,32(s1)
    80004992:	9fa9                	addw	a5,a5,a0
    80004994:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004996:	6c88                	ld	a0,24(s1)
    80004998:	fffff097          	auipc	ra,0xfffff
    8000499c:	0a2080e7          	jalr	162(ra) # 80003a3a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049a0:	854a                	mv	a0,s2
    800049a2:	70a2                	ld	ra,40(sp)
    800049a4:	7402                	ld	s0,32(sp)
    800049a6:	64e2                	ld	s1,24(sp)
    800049a8:	6942                	ld	s2,16(sp)
    800049aa:	69a2                	ld	s3,8(sp)
    800049ac:	6145                	addi	sp,sp,48
    800049ae:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049b0:	6908                	ld	a0,16(a0)
    800049b2:	00000097          	auipc	ra,0x0
    800049b6:	3f4080e7          	jalr	1012(ra) # 80004da6 <piperead>
    800049ba:	892a                	mv	s2,a0
    800049bc:	b7d5                	j	800049a0 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049be:	02451783          	lh	a5,36(a0)
    800049c2:	03079693          	slli	a3,a5,0x30
    800049c6:	92c1                	srli	a3,a3,0x30
    800049c8:	4725                	li	a4,9
    800049ca:	02d76863          	bltu	a4,a3,800049fa <fileread+0xba>
    800049ce:	0792                	slli	a5,a5,0x4
    800049d0:	0001e717          	auipc	a4,0x1e
    800049d4:	fe070713          	addi	a4,a4,-32 # 800229b0 <devsw>
    800049d8:	97ba                	add	a5,a5,a4
    800049da:	639c                	ld	a5,0(a5)
    800049dc:	c38d                	beqz	a5,800049fe <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800049de:	4505                	li	a0,1
    800049e0:	9782                	jalr	a5
    800049e2:	892a                	mv	s2,a0
    800049e4:	bf75                	j	800049a0 <fileread+0x60>
    panic("fileread");
    800049e6:	00004517          	auipc	a0,0x4
    800049ea:	e5a50513          	addi	a0,a0,-422 # 80008840 <syscall_names+0x268>
    800049ee:	ffffc097          	auipc	ra,0xffffc
    800049f2:	b54080e7          	jalr	-1196(ra) # 80000542 <panic>
    return -1;
    800049f6:	597d                	li	s2,-1
    800049f8:	b765                	j	800049a0 <fileread+0x60>
      return -1;
    800049fa:	597d                	li	s2,-1
    800049fc:	b755                	j	800049a0 <fileread+0x60>
    800049fe:	597d                	li	s2,-1
    80004a00:	b745                	j	800049a0 <fileread+0x60>

0000000080004a02 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004a02:	00954783          	lbu	a5,9(a0)
    80004a06:	14078563          	beqz	a5,80004b50 <filewrite+0x14e>
{
    80004a0a:	715d                	addi	sp,sp,-80
    80004a0c:	e486                	sd	ra,72(sp)
    80004a0e:	e0a2                	sd	s0,64(sp)
    80004a10:	fc26                	sd	s1,56(sp)
    80004a12:	f84a                	sd	s2,48(sp)
    80004a14:	f44e                	sd	s3,40(sp)
    80004a16:	f052                	sd	s4,32(sp)
    80004a18:	ec56                	sd	s5,24(sp)
    80004a1a:	e85a                	sd	s6,16(sp)
    80004a1c:	e45e                	sd	s7,8(sp)
    80004a1e:	e062                	sd	s8,0(sp)
    80004a20:	0880                	addi	s0,sp,80
    80004a22:	892a                	mv	s2,a0
    80004a24:	8aae                	mv	s5,a1
    80004a26:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a28:	411c                	lw	a5,0(a0)
    80004a2a:	4705                	li	a4,1
    80004a2c:	02e78263          	beq	a5,a4,80004a50 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a30:	470d                	li	a4,3
    80004a32:	02e78563          	beq	a5,a4,80004a5c <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a36:	4709                	li	a4,2
    80004a38:	10e79463          	bne	a5,a4,80004b40 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a3c:	0ec05e63          	blez	a2,80004b38 <filewrite+0x136>
    int i = 0;
    80004a40:	4981                	li	s3,0
    80004a42:	6b05                	lui	s6,0x1
    80004a44:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a48:	6b85                	lui	s7,0x1
    80004a4a:	c00b8b9b          	addiw	s7,s7,-1024
    80004a4e:	a851                	j	80004ae2 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004a50:	6908                	ld	a0,16(a0)
    80004a52:	00000097          	auipc	ra,0x0
    80004a56:	254080e7          	jalr	596(ra) # 80004ca6 <pipewrite>
    80004a5a:	a85d                	j	80004b10 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a5c:	02451783          	lh	a5,36(a0)
    80004a60:	03079693          	slli	a3,a5,0x30
    80004a64:	92c1                	srli	a3,a3,0x30
    80004a66:	4725                	li	a4,9
    80004a68:	0ed76663          	bltu	a4,a3,80004b54 <filewrite+0x152>
    80004a6c:	0792                	slli	a5,a5,0x4
    80004a6e:	0001e717          	auipc	a4,0x1e
    80004a72:	f4270713          	addi	a4,a4,-190 # 800229b0 <devsw>
    80004a76:	97ba                	add	a5,a5,a4
    80004a78:	679c                	ld	a5,8(a5)
    80004a7a:	cff9                	beqz	a5,80004b58 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004a7c:	4505                	li	a0,1
    80004a7e:	9782                	jalr	a5
    80004a80:	a841                	j	80004b10 <filewrite+0x10e>
    80004a82:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a86:	00000097          	auipc	ra,0x0
    80004a8a:	8ae080e7          	jalr	-1874(ra) # 80004334 <begin_op>
      ilock(f->ip);
    80004a8e:	01893503          	ld	a0,24(s2)
    80004a92:	fffff097          	auipc	ra,0xfffff
    80004a96:	ee6080e7          	jalr	-282(ra) # 80003978 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a9a:	8762                	mv	a4,s8
    80004a9c:	02092683          	lw	a3,32(s2)
    80004aa0:	01598633          	add	a2,s3,s5
    80004aa4:	4585                	li	a1,1
    80004aa6:	01893503          	ld	a0,24(s2)
    80004aaa:	fffff097          	auipc	ra,0xfffff
    80004aae:	278080e7          	jalr	632(ra) # 80003d22 <writei>
    80004ab2:	84aa                	mv	s1,a0
    80004ab4:	02a05f63          	blez	a0,80004af2 <filewrite+0xf0>
        f->off += r;
    80004ab8:	02092783          	lw	a5,32(s2)
    80004abc:	9fa9                	addw	a5,a5,a0
    80004abe:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ac2:	01893503          	ld	a0,24(s2)
    80004ac6:	fffff097          	auipc	ra,0xfffff
    80004aca:	f74080e7          	jalr	-140(ra) # 80003a3a <iunlock>
      end_op();
    80004ace:	00000097          	auipc	ra,0x0
    80004ad2:	8e6080e7          	jalr	-1818(ra) # 800043b4 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004ad6:	049c1963          	bne	s8,s1,80004b28 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004ada:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ade:	0349d663          	bge	s3,s4,80004b0a <filewrite+0x108>
      int n1 = n - i;
    80004ae2:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004ae6:	84be                	mv	s1,a5
    80004ae8:	2781                	sext.w	a5,a5
    80004aea:	f8fb5ce3          	bge	s6,a5,80004a82 <filewrite+0x80>
    80004aee:	84de                	mv	s1,s7
    80004af0:	bf49                	j	80004a82 <filewrite+0x80>
      iunlock(f->ip);
    80004af2:	01893503          	ld	a0,24(s2)
    80004af6:	fffff097          	auipc	ra,0xfffff
    80004afa:	f44080e7          	jalr	-188(ra) # 80003a3a <iunlock>
      end_op();
    80004afe:	00000097          	auipc	ra,0x0
    80004b02:	8b6080e7          	jalr	-1866(ra) # 800043b4 <end_op>
      if(r < 0)
    80004b06:	fc04d8e3          	bgez	s1,80004ad6 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004b0a:	8552                	mv	a0,s4
    80004b0c:	033a1863          	bne	s4,s3,80004b3c <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b10:	60a6                	ld	ra,72(sp)
    80004b12:	6406                	ld	s0,64(sp)
    80004b14:	74e2                	ld	s1,56(sp)
    80004b16:	7942                	ld	s2,48(sp)
    80004b18:	79a2                	ld	s3,40(sp)
    80004b1a:	7a02                	ld	s4,32(sp)
    80004b1c:	6ae2                	ld	s5,24(sp)
    80004b1e:	6b42                	ld	s6,16(sp)
    80004b20:	6ba2                	ld	s7,8(sp)
    80004b22:	6c02                	ld	s8,0(sp)
    80004b24:	6161                	addi	sp,sp,80
    80004b26:	8082                	ret
        panic("short filewrite");
    80004b28:	00004517          	auipc	a0,0x4
    80004b2c:	d2850513          	addi	a0,a0,-728 # 80008850 <syscall_names+0x278>
    80004b30:	ffffc097          	auipc	ra,0xffffc
    80004b34:	a12080e7          	jalr	-1518(ra) # 80000542 <panic>
    int i = 0;
    80004b38:	4981                	li	s3,0
    80004b3a:	bfc1                	j	80004b0a <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004b3c:	557d                	li	a0,-1
    80004b3e:	bfc9                	j	80004b10 <filewrite+0x10e>
    panic("filewrite");
    80004b40:	00004517          	auipc	a0,0x4
    80004b44:	d2050513          	addi	a0,a0,-736 # 80008860 <syscall_names+0x288>
    80004b48:	ffffc097          	auipc	ra,0xffffc
    80004b4c:	9fa080e7          	jalr	-1542(ra) # 80000542 <panic>
    return -1;
    80004b50:	557d                	li	a0,-1
}
    80004b52:	8082                	ret
      return -1;
    80004b54:	557d                	li	a0,-1
    80004b56:	bf6d                	j	80004b10 <filewrite+0x10e>
    80004b58:	557d                	li	a0,-1
    80004b5a:	bf5d                	j	80004b10 <filewrite+0x10e>

0000000080004b5c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b5c:	7179                	addi	sp,sp,-48
    80004b5e:	f406                	sd	ra,40(sp)
    80004b60:	f022                	sd	s0,32(sp)
    80004b62:	ec26                	sd	s1,24(sp)
    80004b64:	e84a                	sd	s2,16(sp)
    80004b66:	e44e                	sd	s3,8(sp)
    80004b68:	e052                	sd	s4,0(sp)
    80004b6a:	1800                	addi	s0,sp,48
    80004b6c:	84aa                	mv	s1,a0
    80004b6e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b70:	0005b023          	sd	zero,0(a1)
    80004b74:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b78:	00000097          	auipc	ra,0x0
    80004b7c:	bd2080e7          	jalr	-1070(ra) # 8000474a <filealloc>
    80004b80:	e088                	sd	a0,0(s1)
    80004b82:	c551                	beqz	a0,80004c0e <pipealloc+0xb2>
    80004b84:	00000097          	auipc	ra,0x0
    80004b88:	bc6080e7          	jalr	-1082(ra) # 8000474a <filealloc>
    80004b8c:	00aa3023          	sd	a0,0(s4)
    80004b90:	c92d                	beqz	a0,80004c02 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b92:	ffffc097          	auipc	ra,0xffffc
    80004b96:	fe8080e7          	jalr	-24(ra) # 80000b7a <kalloc>
    80004b9a:	892a                	mv	s2,a0
    80004b9c:	c125                	beqz	a0,80004bfc <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b9e:	4985                	li	s3,1
    80004ba0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004ba4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ba8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004bac:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004bb0:	00004597          	auipc	a1,0x4
    80004bb4:	8a858593          	addi	a1,a1,-1880 # 80008458 <states.0+0x198>
    80004bb8:	ffffc097          	auipc	ra,0xffffc
    80004bbc:	048080e7          	jalr	72(ra) # 80000c00 <initlock>
  (*f0)->type = FD_PIPE;
    80004bc0:	609c                	ld	a5,0(s1)
    80004bc2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004bc6:	609c                	ld	a5,0(s1)
    80004bc8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bcc:	609c                	ld	a5,0(s1)
    80004bce:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004bd2:	609c                	ld	a5,0(s1)
    80004bd4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004bd8:	000a3783          	ld	a5,0(s4)
    80004bdc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004be0:	000a3783          	ld	a5,0(s4)
    80004be4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004be8:	000a3783          	ld	a5,0(s4)
    80004bec:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004bf0:	000a3783          	ld	a5,0(s4)
    80004bf4:	0127b823          	sd	s2,16(a5)
  return 0;
    80004bf8:	4501                	li	a0,0
    80004bfa:	a025                	j	80004c22 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004bfc:	6088                	ld	a0,0(s1)
    80004bfe:	e501                	bnez	a0,80004c06 <pipealloc+0xaa>
    80004c00:	a039                	j	80004c0e <pipealloc+0xb2>
    80004c02:	6088                	ld	a0,0(s1)
    80004c04:	c51d                	beqz	a0,80004c32 <pipealloc+0xd6>
    fileclose(*f0);
    80004c06:	00000097          	auipc	ra,0x0
    80004c0a:	c00080e7          	jalr	-1024(ra) # 80004806 <fileclose>
  if(*f1)
    80004c0e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c12:	557d                	li	a0,-1
  if(*f1)
    80004c14:	c799                	beqz	a5,80004c22 <pipealloc+0xc6>
    fileclose(*f1);
    80004c16:	853e                	mv	a0,a5
    80004c18:	00000097          	auipc	ra,0x0
    80004c1c:	bee080e7          	jalr	-1042(ra) # 80004806 <fileclose>
  return -1;
    80004c20:	557d                	li	a0,-1
}
    80004c22:	70a2                	ld	ra,40(sp)
    80004c24:	7402                	ld	s0,32(sp)
    80004c26:	64e2                	ld	s1,24(sp)
    80004c28:	6942                	ld	s2,16(sp)
    80004c2a:	69a2                	ld	s3,8(sp)
    80004c2c:	6a02                	ld	s4,0(sp)
    80004c2e:	6145                	addi	sp,sp,48
    80004c30:	8082                	ret
  return -1;
    80004c32:	557d                	li	a0,-1
    80004c34:	b7fd                	j	80004c22 <pipealloc+0xc6>

0000000080004c36 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c36:	1101                	addi	sp,sp,-32
    80004c38:	ec06                	sd	ra,24(sp)
    80004c3a:	e822                	sd	s0,16(sp)
    80004c3c:	e426                	sd	s1,8(sp)
    80004c3e:	e04a                	sd	s2,0(sp)
    80004c40:	1000                	addi	s0,sp,32
    80004c42:	84aa                	mv	s1,a0
    80004c44:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c46:	ffffc097          	auipc	ra,0xffffc
    80004c4a:	04a080e7          	jalr	74(ra) # 80000c90 <acquire>
  if(writable){
    80004c4e:	02090d63          	beqz	s2,80004c88 <pipeclose+0x52>
    pi->writeopen = 0;
    80004c52:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c56:	21848513          	addi	a0,s1,536
    80004c5a:	ffffd097          	auipc	ra,0xffffd
    80004c5e:	7a4080e7          	jalr	1956(ra) # 800023fe <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c62:	2204b783          	ld	a5,544(s1)
    80004c66:	eb95                	bnez	a5,80004c9a <pipeclose+0x64>
    release(&pi->lock);
    80004c68:	8526                	mv	a0,s1
    80004c6a:	ffffc097          	auipc	ra,0xffffc
    80004c6e:	0da080e7          	jalr	218(ra) # 80000d44 <release>
    kfree((char*)pi);
    80004c72:	8526                	mv	a0,s1
    80004c74:	ffffc097          	auipc	ra,0xffffc
    80004c78:	e0a080e7          	jalr	-502(ra) # 80000a7e <kfree>
  } else
    release(&pi->lock);
}
    80004c7c:	60e2                	ld	ra,24(sp)
    80004c7e:	6442                	ld	s0,16(sp)
    80004c80:	64a2                	ld	s1,8(sp)
    80004c82:	6902                	ld	s2,0(sp)
    80004c84:	6105                	addi	sp,sp,32
    80004c86:	8082                	ret
    pi->readopen = 0;
    80004c88:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c8c:	21c48513          	addi	a0,s1,540
    80004c90:	ffffd097          	auipc	ra,0xffffd
    80004c94:	76e080e7          	jalr	1902(ra) # 800023fe <wakeup>
    80004c98:	b7e9                	j	80004c62 <pipeclose+0x2c>
    release(&pi->lock);
    80004c9a:	8526                	mv	a0,s1
    80004c9c:	ffffc097          	auipc	ra,0xffffc
    80004ca0:	0a8080e7          	jalr	168(ra) # 80000d44 <release>
}
    80004ca4:	bfe1                	j	80004c7c <pipeclose+0x46>

0000000080004ca6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ca6:	711d                	addi	sp,sp,-96
    80004ca8:	ec86                	sd	ra,88(sp)
    80004caa:	e8a2                	sd	s0,80(sp)
    80004cac:	e4a6                	sd	s1,72(sp)
    80004cae:	e0ca                	sd	s2,64(sp)
    80004cb0:	fc4e                	sd	s3,56(sp)
    80004cb2:	f852                	sd	s4,48(sp)
    80004cb4:	f456                	sd	s5,40(sp)
    80004cb6:	f05a                	sd	s6,32(sp)
    80004cb8:	ec5e                	sd	s7,24(sp)
    80004cba:	e862                	sd	s8,16(sp)
    80004cbc:	1080                	addi	s0,sp,96
    80004cbe:	84aa                	mv	s1,a0
    80004cc0:	8b2e                	mv	s6,a1
    80004cc2:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004cc4:	ffffd097          	auipc	ra,0xffffd
    80004cc8:	d98080e7          	jalr	-616(ra) # 80001a5c <myproc>
    80004ccc:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004cce:	8526                	mv	a0,s1
    80004cd0:	ffffc097          	auipc	ra,0xffffc
    80004cd4:	fc0080e7          	jalr	-64(ra) # 80000c90 <acquire>
  for(i = 0; i < n; i++){
    80004cd8:	09505763          	blez	s5,80004d66 <pipewrite+0xc0>
    80004cdc:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004cde:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ce2:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ce6:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004ce8:	2184a783          	lw	a5,536(s1)
    80004cec:	21c4a703          	lw	a4,540(s1)
    80004cf0:	2007879b          	addiw	a5,a5,512
    80004cf4:	02f71b63          	bne	a4,a5,80004d2a <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    80004cf8:	2204a783          	lw	a5,544(s1)
    80004cfc:	c3d1                	beqz	a5,80004d80 <pipewrite+0xda>
    80004cfe:	03092783          	lw	a5,48(s2)
    80004d02:	efbd                	bnez	a5,80004d80 <pipewrite+0xda>
      wakeup(&pi->nread);
    80004d04:	8552                	mv	a0,s4
    80004d06:	ffffd097          	auipc	ra,0xffffd
    80004d0a:	6f8080e7          	jalr	1784(ra) # 800023fe <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d0e:	85a6                	mv	a1,s1
    80004d10:	854e                	mv	a0,s3
    80004d12:	ffffd097          	auipc	ra,0xffffd
    80004d16:	56c080e7          	jalr	1388(ra) # 8000227e <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004d1a:	2184a783          	lw	a5,536(s1)
    80004d1e:	21c4a703          	lw	a4,540(s1)
    80004d22:	2007879b          	addiw	a5,a5,512
    80004d26:	fcf709e3          	beq	a4,a5,80004cf8 <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d2a:	4685                	li	a3,1
    80004d2c:	865a                	mv	a2,s6
    80004d2e:	faf40593          	addi	a1,s0,-81
    80004d32:	05093503          	ld	a0,80(s2)
    80004d36:	ffffd097          	auipc	ra,0xffffd
    80004d3a:	aa4080e7          	jalr	-1372(ra) # 800017da <copyin>
    80004d3e:	03850563          	beq	a0,s8,80004d68 <pipewrite+0xc2>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d42:	21c4a783          	lw	a5,540(s1)
    80004d46:	0017871b          	addiw	a4,a5,1
    80004d4a:	20e4ae23          	sw	a4,540(s1)
    80004d4e:	1ff7f793          	andi	a5,a5,511
    80004d52:	97a6                	add	a5,a5,s1
    80004d54:	faf44703          	lbu	a4,-81(s0)
    80004d58:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004d5c:	2b85                	addiw	s7,s7,1
    80004d5e:	0b05                	addi	s6,s6,1
    80004d60:	f97a94e3          	bne	s5,s7,80004ce8 <pipewrite+0x42>
    80004d64:	a011                	j	80004d68 <pipewrite+0xc2>
    80004d66:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    80004d68:	21848513          	addi	a0,s1,536
    80004d6c:	ffffd097          	auipc	ra,0xffffd
    80004d70:	692080e7          	jalr	1682(ra) # 800023fe <wakeup>
  release(&pi->lock);
    80004d74:	8526                	mv	a0,s1
    80004d76:	ffffc097          	auipc	ra,0xffffc
    80004d7a:	fce080e7          	jalr	-50(ra) # 80000d44 <release>
  return i;
    80004d7e:	a039                	j	80004d8c <pipewrite+0xe6>
        release(&pi->lock);
    80004d80:	8526                	mv	a0,s1
    80004d82:	ffffc097          	auipc	ra,0xffffc
    80004d86:	fc2080e7          	jalr	-62(ra) # 80000d44 <release>
        return -1;
    80004d8a:	5bfd                	li	s7,-1
}
    80004d8c:	855e                	mv	a0,s7
    80004d8e:	60e6                	ld	ra,88(sp)
    80004d90:	6446                	ld	s0,80(sp)
    80004d92:	64a6                	ld	s1,72(sp)
    80004d94:	6906                	ld	s2,64(sp)
    80004d96:	79e2                	ld	s3,56(sp)
    80004d98:	7a42                	ld	s4,48(sp)
    80004d9a:	7aa2                	ld	s5,40(sp)
    80004d9c:	7b02                	ld	s6,32(sp)
    80004d9e:	6be2                	ld	s7,24(sp)
    80004da0:	6c42                	ld	s8,16(sp)
    80004da2:	6125                	addi	sp,sp,96
    80004da4:	8082                	ret

0000000080004da6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004da6:	715d                	addi	sp,sp,-80
    80004da8:	e486                	sd	ra,72(sp)
    80004daa:	e0a2                	sd	s0,64(sp)
    80004dac:	fc26                	sd	s1,56(sp)
    80004dae:	f84a                	sd	s2,48(sp)
    80004db0:	f44e                	sd	s3,40(sp)
    80004db2:	f052                	sd	s4,32(sp)
    80004db4:	ec56                	sd	s5,24(sp)
    80004db6:	e85a                	sd	s6,16(sp)
    80004db8:	0880                	addi	s0,sp,80
    80004dba:	84aa                	mv	s1,a0
    80004dbc:	892e                	mv	s2,a1
    80004dbe:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004dc0:	ffffd097          	auipc	ra,0xffffd
    80004dc4:	c9c080e7          	jalr	-868(ra) # 80001a5c <myproc>
    80004dc8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004dca:	8526                	mv	a0,s1
    80004dcc:	ffffc097          	auipc	ra,0xffffc
    80004dd0:	ec4080e7          	jalr	-316(ra) # 80000c90 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dd4:	2184a703          	lw	a4,536(s1)
    80004dd8:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ddc:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004de0:	02f71463          	bne	a4,a5,80004e08 <piperead+0x62>
    80004de4:	2244a783          	lw	a5,548(s1)
    80004de8:	c385                	beqz	a5,80004e08 <piperead+0x62>
    if(pr->killed){
    80004dea:	030a2783          	lw	a5,48(s4)
    80004dee:	ebc1                	bnez	a5,80004e7e <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004df0:	85a6                	mv	a1,s1
    80004df2:	854e                	mv	a0,s3
    80004df4:	ffffd097          	auipc	ra,0xffffd
    80004df8:	48a080e7          	jalr	1162(ra) # 8000227e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dfc:	2184a703          	lw	a4,536(s1)
    80004e00:	21c4a783          	lw	a5,540(s1)
    80004e04:	fef700e3          	beq	a4,a5,80004de4 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e08:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e0a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e0c:	05505363          	blez	s5,80004e52 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004e10:	2184a783          	lw	a5,536(s1)
    80004e14:	21c4a703          	lw	a4,540(s1)
    80004e18:	02f70d63          	beq	a4,a5,80004e52 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e1c:	0017871b          	addiw	a4,a5,1
    80004e20:	20e4ac23          	sw	a4,536(s1)
    80004e24:	1ff7f793          	andi	a5,a5,511
    80004e28:	97a6                	add	a5,a5,s1
    80004e2a:	0187c783          	lbu	a5,24(a5)
    80004e2e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e32:	4685                	li	a3,1
    80004e34:	fbf40613          	addi	a2,s0,-65
    80004e38:	85ca                	mv	a1,s2
    80004e3a:	050a3503          	ld	a0,80(s4)
    80004e3e:	ffffd097          	auipc	ra,0xffffd
    80004e42:	910080e7          	jalr	-1776(ra) # 8000174e <copyout>
    80004e46:	01650663          	beq	a0,s6,80004e52 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e4a:	2985                	addiw	s3,s3,1
    80004e4c:	0905                	addi	s2,s2,1
    80004e4e:	fd3a91e3          	bne	s5,s3,80004e10 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e52:	21c48513          	addi	a0,s1,540
    80004e56:	ffffd097          	auipc	ra,0xffffd
    80004e5a:	5a8080e7          	jalr	1448(ra) # 800023fe <wakeup>
  release(&pi->lock);
    80004e5e:	8526                	mv	a0,s1
    80004e60:	ffffc097          	auipc	ra,0xffffc
    80004e64:	ee4080e7          	jalr	-284(ra) # 80000d44 <release>
  return i;
}
    80004e68:	854e                	mv	a0,s3
    80004e6a:	60a6                	ld	ra,72(sp)
    80004e6c:	6406                	ld	s0,64(sp)
    80004e6e:	74e2                	ld	s1,56(sp)
    80004e70:	7942                	ld	s2,48(sp)
    80004e72:	79a2                	ld	s3,40(sp)
    80004e74:	7a02                	ld	s4,32(sp)
    80004e76:	6ae2                	ld	s5,24(sp)
    80004e78:	6b42                	ld	s6,16(sp)
    80004e7a:	6161                	addi	sp,sp,80
    80004e7c:	8082                	ret
      release(&pi->lock);
    80004e7e:	8526                	mv	a0,s1
    80004e80:	ffffc097          	auipc	ra,0xffffc
    80004e84:	ec4080e7          	jalr	-316(ra) # 80000d44 <release>
      return -1;
    80004e88:	59fd                	li	s3,-1
    80004e8a:	bff9                	j	80004e68 <piperead+0xc2>

0000000080004e8c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e8c:	de010113          	addi	sp,sp,-544
    80004e90:	20113c23          	sd	ra,536(sp)
    80004e94:	20813823          	sd	s0,528(sp)
    80004e98:	20913423          	sd	s1,520(sp)
    80004e9c:	21213023          	sd	s2,512(sp)
    80004ea0:	ffce                	sd	s3,504(sp)
    80004ea2:	fbd2                	sd	s4,496(sp)
    80004ea4:	f7d6                	sd	s5,488(sp)
    80004ea6:	f3da                	sd	s6,480(sp)
    80004ea8:	efde                	sd	s7,472(sp)
    80004eaa:	ebe2                	sd	s8,464(sp)
    80004eac:	e7e6                	sd	s9,456(sp)
    80004eae:	e3ea                	sd	s10,448(sp)
    80004eb0:	ff6e                	sd	s11,440(sp)
    80004eb2:	1400                	addi	s0,sp,544
    80004eb4:	892a                	mv	s2,a0
    80004eb6:	dea43423          	sd	a0,-536(s0)
    80004eba:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ebe:	ffffd097          	auipc	ra,0xffffd
    80004ec2:	b9e080e7          	jalr	-1122(ra) # 80001a5c <myproc>
    80004ec6:	84aa                	mv	s1,a0

  begin_op();
    80004ec8:	fffff097          	auipc	ra,0xfffff
    80004ecc:	46c080e7          	jalr	1132(ra) # 80004334 <begin_op>

  if((ip = namei(path)) == 0){
    80004ed0:	854a                	mv	a0,s2
    80004ed2:	fffff097          	auipc	ra,0xfffff
    80004ed6:	256080e7          	jalr	598(ra) # 80004128 <namei>
    80004eda:	c93d                	beqz	a0,80004f50 <exec+0xc4>
    80004edc:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ede:	fffff097          	auipc	ra,0xfffff
    80004ee2:	a9a080e7          	jalr	-1382(ra) # 80003978 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ee6:	04000713          	li	a4,64
    80004eea:	4681                	li	a3,0
    80004eec:	e4840613          	addi	a2,s0,-440
    80004ef0:	4581                	li	a1,0
    80004ef2:	8556                	mv	a0,s5
    80004ef4:	fffff097          	auipc	ra,0xfffff
    80004ef8:	d38080e7          	jalr	-712(ra) # 80003c2c <readi>
    80004efc:	04000793          	li	a5,64
    80004f00:	00f51a63          	bne	a0,a5,80004f14 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004f04:	e4842703          	lw	a4,-440(s0)
    80004f08:	464c47b7          	lui	a5,0x464c4
    80004f0c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f10:	04f70663          	beq	a4,a5,80004f5c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f14:	8556                	mv	a0,s5
    80004f16:	fffff097          	auipc	ra,0xfffff
    80004f1a:	cc4080e7          	jalr	-828(ra) # 80003bda <iunlockput>
    end_op();
    80004f1e:	fffff097          	auipc	ra,0xfffff
    80004f22:	496080e7          	jalr	1174(ra) # 800043b4 <end_op>
  }
  return -1;
    80004f26:	557d                	li	a0,-1
}
    80004f28:	21813083          	ld	ra,536(sp)
    80004f2c:	21013403          	ld	s0,528(sp)
    80004f30:	20813483          	ld	s1,520(sp)
    80004f34:	20013903          	ld	s2,512(sp)
    80004f38:	79fe                	ld	s3,504(sp)
    80004f3a:	7a5e                	ld	s4,496(sp)
    80004f3c:	7abe                	ld	s5,488(sp)
    80004f3e:	7b1e                	ld	s6,480(sp)
    80004f40:	6bfe                	ld	s7,472(sp)
    80004f42:	6c5e                	ld	s8,464(sp)
    80004f44:	6cbe                	ld	s9,456(sp)
    80004f46:	6d1e                	ld	s10,448(sp)
    80004f48:	7dfa                	ld	s11,440(sp)
    80004f4a:	22010113          	addi	sp,sp,544
    80004f4e:	8082                	ret
    end_op();
    80004f50:	fffff097          	auipc	ra,0xfffff
    80004f54:	464080e7          	jalr	1124(ra) # 800043b4 <end_op>
    return -1;
    80004f58:	557d                	li	a0,-1
    80004f5a:	b7f9                	j	80004f28 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f5c:	8526                	mv	a0,s1
    80004f5e:	ffffd097          	auipc	ra,0xffffd
    80004f62:	bc2080e7          	jalr	-1086(ra) # 80001b20 <proc_pagetable>
    80004f66:	8b2a                	mv	s6,a0
    80004f68:	d555                	beqz	a0,80004f14 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f6a:	e6842783          	lw	a5,-408(s0)
    80004f6e:	e8045703          	lhu	a4,-384(s0)
    80004f72:	c735                	beqz	a4,80004fde <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f74:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f76:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f7a:	6a05                	lui	s4,0x1
    80004f7c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f80:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004f84:	6d85                	lui	s11,0x1
    80004f86:	7d7d                	lui	s10,0xfffff
    80004f88:	ac1d                	j	800051be <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f8a:	00004517          	auipc	a0,0x4
    80004f8e:	8e650513          	addi	a0,a0,-1818 # 80008870 <syscall_names+0x298>
    80004f92:	ffffb097          	auipc	ra,0xffffb
    80004f96:	5b0080e7          	jalr	1456(ra) # 80000542 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f9a:	874a                	mv	a4,s2
    80004f9c:	009c86bb          	addw	a3,s9,s1
    80004fa0:	4581                	li	a1,0
    80004fa2:	8556                	mv	a0,s5
    80004fa4:	fffff097          	auipc	ra,0xfffff
    80004fa8:	c88080e7          	jalr	-888(ra) # 80003c2c <readi>
    80004fac:	2501                	sext.w	a0,a0
    80004fae:	1aa91863          	bne	s2,a0,8000515e <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004fb2:	009d84bb          	addw	s1,s11,s1
    80004fb6:	013d09bb          	addw	s3,s10,s3
    80004fba:	1f74f263          	bgeu	s1,s7,8000519e <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004fbe:	02049593          	slli	a1,s1,0x20
    80004fc2:	9181                	srli	a1,a1,0x20
    80004fc4:	95e2                	add	a1,a1,s8
    80004fc6:	855a                	mv	a0,s6
    80004fc8:	ffffc097          	auipc	ra,0xffffc
    80004fcc:	152080e7          	jalr	338(ra) # 8000111a <walkaddr>
    80004fd0:	862a                	mv	a2,a0
    if(pa == 0)
    80004fd2:	dd45                	beqz	a0,80004f8a <exec+0xfe>
      n = PGSIZE;
    80004fd4:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004fd6:	fd49f2e3          	bgeu	s3,s4,80004f9a <exec+0x10e>
      n = sz - i;
    80004fda:	894e                	mv	s2,s3
    80004fdc:	bf7d                	j	80004f9a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004fde:	4481                	li	s1,0
  iunlockput(ip);
    80004fe0:	8556                	mv	a0,s5
    80004fe2:	fffff097          	auipc	ra,0xfffff
    80004fe6:	bf8080e7          	jalr	-1032(ra) # 80003bda <iunlockput>
  end_op();
    80004fea:	fffff097          	auipc	ra,0xfffff
    80004fee:	3ca080e7          	jalr	970(ra) # 800043b4 <end_op>
  p = myproc();
    80004ff2:	ffffd097          	auipc	ra,0xffffd
    80004ff6:	a6a080e7          	jalr	-1430(ra) # 80001a5c <myproc>
    80004ffa:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004ffc:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005000:	6785                	lui	a5,0x1
    80005002:	17fd                	addi	a5,a5,-1
    80005004:	94be                	add	s1,s1,a5
    80005006:	77fd                	lui	a5,0xfffff
    80005008:	8fe5                	and	a5,a5,s1
    8000500a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000500e:	6609                	lui	a2,0x2
    80005010:	963e                	add	a2,a2,a5
    80005012:	85be                	mv	a1,a5
    80005014:	855a                	mv	a0,s6
    80005016:	ffffc097          	auipc	ra,0xffffc
    8000501a:	4e8080e7          	jalr	1256(ra) # 800014fe <uvmalloc>
    8000501e:	8c2a                	mv	s8,a0
  ip = 0;
    80005020:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005022:	12050e63          	beqz	a0,8000515e <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005026:	75f9                	lui	a1,0xffffe
    80005028:	95aa                	add	a1,a1,a0
    8000502a:	855a                	mv	a0,s6
    8000502c:	ffffc097          	auipc	ra,0xffffc
    80005030:	6f0080e7          	jalr	1776(ra) # 8000171c <uvmclear>
  stackbase = sp - PGSIZE;
    80005034:	7afd                	lui	s5,0xfffff
    80005036:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005038:	df043783          	ld	a5,-528(s0)
    8000503c:	6388                	ld	a0,0(a5)
    8000503e:	c925                	beqz	a0,800050ae <exec+0x222>
    80005040:	e8840993          	addi	s3,s0,-376
    80005044:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005048:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000504a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000504c:	ffffc097          	auipc	ra,0xffffc
    80005050:	ec4080e7          	jalr	-316(ra) # 80000f10 <strlen>
    80005054:	0015079b          	addiw	a5,a0,1
    80005058:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000505c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005060:	13596363          	bltu	s2,s5,80005186 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005064:	df043d83          	ld	s11,-528(s0)
    80005068:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000506c:	8552                	mv	a0,s4
    8000506e:	ffffc097          	auipc	ra,0xffffc
    80005072:	ea2080e7          	jalr	-350(ra) # 80000f10 <strlen>
    80005076:	0015069b          	addiw	a3,a0,1
    8000507a:	8652                	mv	a2,s4
    8000507c:	85ca                	mv	a1,s2
    8000507e:	855a                	mv	a0,s6
    80005080:	ffffc097          	auipc	ra,0xffffc
    80005084:	6ce080e7          	jalr	1742(ra) # 8000174e <copyout>
    80005088:	10054363          	bltz	a0,8000518e <exec+0x302>
    ustack[argc] = sp;
    8000508c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005090:	0485                	addi	s1,s1,1
    80005092:	008d8793          	addi	a5,s11,8
    80005096:	def43823          	sd	a5,-528(s0)
    8000509a:	008db503          	ld	a0,8(s11)
    8000509e:	c911                	beqz	a0,800050b2 <exec+0x226>
    if(argc >= MAXARG)
    800050a0:	09a1                	addi	s3,s3,8
    800050a2:	fb3c95e3          	bne	s9,s3,8000504c <exec+0x1c0>
  sz = sz1;
    800050a6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050aa:	4a81                	li	s5,0
    800050ac:	a84d                	j	8000515e <exec+0x2d2>
  sp = sz;
    800050ae:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800050b0:	4481                	li	s1,0
  ustack[argc] = 0;
    800050b2:	00349793          	slli	a5,s1,0x3
    800050b6:	f9040713          	addi	a4,s0,-112
    800050ba:	97ba                	add	a5,a5,a4
    800050bc:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd7ef8>
  sp -= (argc+1) * sizeof(uint64);
    800050c0:	00148693          	addi	a3,s1,1
    800050c4:	068e                	slli	a3,a3,0x3
    800050c6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050ca:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800050ce:	01597663          	bgeu	s2,s5,800050da <exec+0x24e>
  sz = sz1;
    800050d2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050d6:	4a81                	li	s5,0
    800050d8:	a059                	j	8000515e <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050da:	e8840613          	addi	a2,s0,-376
    800050de:	85ca                	mv	a1,s2
    800050e0:	855a                	mv	a0,s6
    800050e2:	ffffc097          	auipc	ra,0xffffc
    800050e6:	66c080e7          	jalr	1644(ra) # 8000174e <copyout>
    800050ea:	0a054663          	bltz	a0,80005196 <exec+0x30a>
  p->trapframe->a1 = sp;
    800050ee:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800050f2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050f6:	de843783          	ld	a5,-536(s0)
    800050fa:	0007c703          	lbu	a4,0(a5)
    800050fe:	cf11                	beqz	a4,8000511a <exec+0x28e>
    80005100:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005102:	02f00693          	li	a3,47
    80005106:	a039                	j	80005114 <exec+0x288>
      last = s+1;
    80005108:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000510c:	0785                	addi	a5,a5,1
    8000510e:	fff7c703          	lbu	a4,-1(a5)
    80005112:	c701                	beqz	a4,8000511a <exec+0x28e>
    if(*s == '/')
    80005114:	fed71ce3          	bne	a4,a3,8000510c <exec+0x280>
    80005118:	bfc5                	j	80005108 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000511a:	4641                	li	a2,16
    8000511c:	de843583          	ld	a1,-536(s0)
    80005120:	158b8513          	addi	a0,s7,344
    80005124:	ffffc097          	auipc	ra,0xffffc
    80005128:	dba080e7          	jalr	-582(ra) # 80000ede <safestrcpy>
  oldpagetable = p->pagetable;
    8000512c:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005130:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005134:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005138:	058bb783          	ld	a5,88(s7)
    8000513c:	e6043703          	ld	a4,-416(s0)
    80005140:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005142:	058bb783          	ld	a5,88(s7)
    80005146:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000514a:	85ea                	mv	a1,s10
    8000514c:	ffffd097          	auipc	ra,0xffffd
    80005150:	a70080e7          	jalr	-1424(ra) # 80001bbc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005154:	0004851b          	sext.w	a0,s1
    80005158:	bbc1                	j	80004f28 <exec+0x9c>
    8000515a:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000515e:	df843583          	ld	a1,-520(s0)
    80005162:	855a                	mv	a0,s6
    80005164:	ffffd097          	auipc	ra,0xffffd
    80005168:	a58080e7          	jalr	-1448(ra) # 80001bbc <proc_freepagetable>
  if(ip){
    8000516c:	da0a94e3          	bnez	s5,80004f14 <exec+0x88>
  return -1;
    80005170:	557d                	li	a0,-1
    80005172:	bb5d                	j	80004f28 <exec+0x9c>
    80005174:	de943c23          	sd	s1,-520(s0)
    80005178:	b7dd                	j	8000515e <exec+0x2d2>
    8000517a:	de943c23          	sd	s1,-520(s0)
    8000517e:	b7c5                	j	8000515e <exec+0x2d2>
    80005180:	de943c23          	sd	s1,-520(s0)
    80005184:	bfe9                	j	8000515e <exec+0x2d2>
  sz = sz1;
    80005186:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000518a:	4a81                	li	s5,0
    8000518c:	bfc9                	j	8000515e <exec+0x2d2>
  sz = sz1;
    8000518e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005192:	4a81                	li	s5,0
    80005194:	b7e9                	j	8000515e <exec+0x2d2>
  sz = sz1;
    80005196:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000519a:	4a81                	li	s5,0
    8000519c:	b7c9                	j	8000515e <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000519e:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051a2:	e0843783          	ld	a5,-504(s0)
    800051a6:	0017869b          	addiw	a3,a5,1
    800051aa:	e0d43423          	sd	a3,-504(s0)
    800051ae:	e0043783          	ld	a5,-512(s0)
    800051b2:	0387879b          	addiw	a5,a5,56
    800051b6:	e8045703          	lhu	a4,-384(s0)
    800051ba:	e2e6d3e3          	bge	a3,a4,80004fe0 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051be:	2781                	sext.w	a5,a5
    800051c0:	e0f43023          	sd	a5,-512(s0)
    800051c4:	03800713          	li	a4,56
    800051c8:	86be                	mv	a3,a5
    800051ca:	e1040613          	addi	a2,s0,-496
    800051ce:	4581                	li	a1,0
    800051d0:	8556                	mv	a0,s5
    800051d2:	fffff097          	auipc	ra,0xfffff
    800051d6:	a5a080e7          	jalr	-1446(ra) # 80003c2c <readi>
    800051da:	03800793          	li	a5,56
    800051de:	f6f51ee3          	bne	a0,a5,8000515a <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    800051e2:	e1042783          	lw	a5,-496(s0)
    800051e6:	4705                	li	a4,1
    800051e8:	fae79de3          	bne	a5,a4,800051a2 <exec+0x316>
    if(ph.memsz < ph.filesz)
    800051ec:	e3843603          	ld	a2,-456(s0)
    800051f0:	e3043783          	ld	a5,-464(s0)
    800051f4:	f8f660e3          	bltu	a2,a5,80005174 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051f8:	e2043783          	ld	a5,-480(s0)
    800051fc:	963e                	add	a2,a2,a5
    800051fe:	f6f66ee3          	bltu	a2,a5,8000517a <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005202:	85a6                	mv	a1,s1
    80005204:	855a                	mv	a0,s6
    80005206:	ffffc097          	auipc	ra,0xffffc
    8000520a:	2f8080e7          	jalr	760(ra) # 800014fe <uvmalloc>
    8000520e:	dea43c23          	sd	a0,-520(s0)
    80005212:	d53d                	beqz	a0,80005180 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80005214:	e2043c03          	ld	s8,-480(s0)
    80005218:	de043783          	ld	a5,-544(s0)
    8000521c:	00fc77b3          	and	a5,s8,a5
    80005220:	ff9d                	bnez	a5,8000515e <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005222:	e1842c83          	lw	s9,-488(s0)
    80005226:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000522a:	f60b8ae3          	beqz	s7,8000519e <exec+0x312>
    8000522e:	89de                	mv	s3,s7
    80005230:	4481                	li	s1,0
    80005232:	b371                	j	80004fbe <exec+0x132>

0000000080005234 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005234:	7179                	addi	sp,sp,-48
    80005236:	f406                	sd	ra,40(sp)
    80005238:	f022                	sd	s0,32(sp)
    8000523a:	ec26                	sd	s1,24(sp)
    8000523c:	e84a                	sd	s2,16(sp)
    8000523e:	1800                	addi	s0,sp,48
    80005240:	892e                	mv	s2,a1
    80005242:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005244:	fdc40593          	addi	a1,s0,-36
    80005248:	ffffe097          	auipc	ra,0xffffe
    8000524c:	a0a080e7          	jalr	-1526(ra) # 80002c52 <argint>
    80005250:	04054063          	bltz	a0,80005290 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005254:	fdc42703          	lw	a4,-36(s0)
    80005258:	47bd                	li	a5,15
    8000525a:	02e7ed63          	bltu	a5,a4,80005294 <argfd+0x60>
    8000525e:	ffffc097          	auipc	ra,0xffffc
    80005262:	7fe080e7          	jalr	2046(ra) # 80001a5c <myproc>
    80005266:	fdc42703          	lw	a4,-36(s0)
    8000526a:	01a70793          	addi	a5,a4,26
    8000526e:	078e                	slli	a5,a5,0x3
    80005270:	953e                	add	a0,a0,a5
    80005272:	611c                	ld	a5,0(a0)
    80005274:	c395                	beqz	a5,80005298 <argfd+0x64>
    return -1;
  if(pfd)
    80005276:	00090463          	beqz	s2,8000527e <argfd+0x4a>
    *pfd = fd;
    8000527a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000527e:	4501                	li	a0,0
  if(pf)
    80005280:	c091                	beqz	s1,80005284 <argfd+0x50>
    *pf = f;
    80005282:	e09c                	sd	a5,0(s1)
}
    80005284:	70a2                	ld	ra,40(sp)
    80005286:	7402                	ld	s0,32(sp)
    80005288:	64e2                	ld	s1,24(sp)
    8000528a:	6942                	ld	s2,16(sp)
    8000528c:	6145                	addi	sp,sp,48
    8000528e:	8082                	ret
    return -1;
    80005290:	557d                	li	a0,-1
    80005292:	bfcd                	j	80005284 <argfd+0x50>
    return -1;
    80005294:	557d                	li	a0,-1
    80005296:	b7fd                	j	80005284 <argfd+0x50>
    80005298:	557d                	li	a0,-1
    8000529a:	b7ed                	j	80005284 <argfd+0x50>

000000008000529c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000529c:	1101                	addi	sp,sp,-32
    8000529e:	ec06                	sd	ra,24(sp)
    800052a0:	e822                	sd	s0,16(sp)
    800052a2:	e426                	sd	s1,8(sp)
    800052a4:	1000                	addi	s0,sp,32
    800052a6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052a8:	ffffc097          	auipc	ra,0xffffc
    800052ac:	7b4080e7          	jalr	1972(ra) # 80001a5c <myproc>
    800052b0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052b2:	0d050793          	addi	a5,a0,208
    800052b6:	4501                	li	a0,0
    800052b8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052ba:	6398                	ld	a4,0(a5)
    800052bc:	cb19                	beqz	a4,800052d2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052be:	2505                	addiw	a0,a0,1
    800052c0:	07a1                	addi	a5,a5,8
    800052c2:	fed51ce3          	bne	a0,a3,800052ba <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052c6:	557d                	li	a0,-1
}
    800052c8:	60e2                	ld	ra,24(sp)
    800052ca:	6442                	ld	s0,16(sp)
    800052cc:	64a2                	ld	s1,8(sp)
    800052ce:	6105                	addi	sp,sp,32
    800052d0:	8082                	ret
      p->ofile[fd] = f;
    800052d2:	01a50793          	addi	a5,a0,26
    800052d6:	078e                	slli	a5,a5,0x3
    800052d8:	963e                	add	a2,a2,a5
    800052da:	e204                	sd	s1,0(a2)
      return fd;
    800052dc:	b7f5                	j	800052c8 <fdalloc+0x2c>

00000000800052de <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052de:	715d                	addi	sp,sp,-80
    800052e0:	e486                	sd	ra,72(sp)
    800052e2:	e0a2                	sd	s0,64(sp)
    800052e4:	fc26                	sd	s1,56(sp)
    800052e6:	f84a                	sd	s2,48(sp)
    800052e8:	f44e                	sd	s3,40(sp)
    800052ea:	f052                	sd	s4,32(sp)
    800052ec:	ec56                	sd	s5,24(sp)
    800052ee:	0880                	addi	s0,sp,80
    800052f0:	89ae                	mv	s3,a1
    800052f2:	8ab2                	mv	s5,a2
    800052f4:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052f6:	fb040593          	addi	a1,s0,-80
    800052fa:	fffff097          	auipc	ra,0xfffff
    800052fe:	e4c080e7          	jalr	-436(ra) # 80004146 <nameiparent>
    80005302:	892a                	mv	s2,a0
    80005304:	12050e63          	beqz	a0,80005440 <create+0x162>
    return 0;

  ilock(dp);
    80005308:	ffffe097          	auipc	ra,0xffffe
    8000530c:	670080e7          	jalr	1648(ra) # 80003978 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005310:	4601                	li	a2,0
    80005312:	fb040593          	addi	a1,s0,-80
    80005316:	854a                	mv	a0,s2
    80005318:	fffff097          	auipc	ra,0xfffff
    8000531c:	b3e080e7          	jalr	-1218(ra) # 80003e56 <dirlookup>
    80005320:	84aa                	mv	s1,a0
    80005322:	c921                	beqz	a0,80005372 <create+0x94>
    iunlockput(dp);
    80005324:	854a                	mv	a0,s2
    80005326:	fffff097          	auipc	ra,0xfffff
    8000532a:	8b4080e7          	jalr	-1868(ra) # 80003bda <iunlockput>
    ilock(ip);
    8000532e:	8526                	mv	a0,s1
    80005330:	ffffe097          	auipc	ra,0xffffe
    80005334:	648080e7          	jalr	1608(ra) # 80003978 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005338:	2981                	sext.w	s3,s3
    8000533a:	4789                	li	a5,2
    8000533c:	02f99463          	bne	s3,a5,80005364 <create+0x86>
    80005340:	0444d783          	lhu	a5,68(s1)
    80005344:	37f9                	addiw	a5,a5,-2
    80005346:	17c2                	slli	a5,a5,0x30
    80005348:	93c1                	srli	a5,a5,0x30
    8000534a:	4705                	li	a4,1
    8000534c:	00f76c63          	bltu	a4,a5,80005364 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005350:	8526                	mv	a0,s1
    80005352:	60a6                	ld	ra,72(sp)
    80005354:	6406                	ld	s0,64(sp)
    80005356:	74e2                	ld	s1,56(sp)
    80005358:	7942                	ld	s2,48(sp)
    8000535a:	79a2                	ld	s3,40(sp)
    8000535c:	7a02                	ld	s4,32(sp)
    8000535e:	6ae2                	ld	s5,24(sp)
    80005360:	6161                	addi	sp,sp,80
    80005362:	8082                	ret
    iunlockput(ip);
    80005364:	8526                	mv	a0,s1
    80005366:	fffff097          	auipc	ra,0xfffff
    8000536a:	874080e7          	jalr	-1932(ra) # 80003bda <iunlockput>
    return 0;
    8000536e:	4481                	li	s1,0
    80005370:	b7c5                	j	80005350 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005372:	85ce                	mv	a1,s3
    80005374:	00092503          	lw	a0,0(s2)
    80005378:	ffffe097          	auipc	ra,0xffffe
    8000537c:	468080e7          	jalr	1128(ra) # 800037e0 <ialloc>
    80005380:	84aa                	mv	s1,a0
    80005382:	c521                	beqz	a0,800053ca <create+0xec>
  ilock(ip);
    80005384:	ffffe097          	auipc	ra,0xffffe
    80005388:	5f4080e7          	jalr	1524(ra) # 80003978 <ilock>
  ip->major = major;
    8000538c:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005390:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005394:	4a05                	li	s4,1
    80005396:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000539a:	8526                	mv	a0,s1
    8000539c:	ffffe097          	auipc	ra,0xffffe
    800053a0:	512080e7          	jalr	1298(ra) # 800038ae <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053a4:	2981                	sext.w	s3,s3
    800053a6:	03498a63          	beq	s3,s4,800053da <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800053aa:	40d0                	lw	a2,4(s1)
    800053ac:	fb040593          	addi	a1,s0,-80
    800053b0:	854a                	mv	a0,s2
    800053b2:	fffff097          	auipc	ra,0xfffff
    800053b6:	cb4080e7          	jalr	-844(ra) # 80004066 <dirlink>
    800053ba:	06054b63          	bltz	a0,80005430 <create+0x152>
  iunlockput(dp);
    800053be:	854a                	mv	a0,s2
    800053c0:	fffff097          	auipc	ra,0xfffff
    800053c4:	81a080e7          	jalr	-2022(ra) # 80003bda <iunlockput>
  return ip;
    800053c8:	b761                	j	80005350 <create+0x72>
    panic("create: ialloc");
    800053ca:	00003517          	auipc	a0,0x3
    800053ce:	4c650513          	addi	a0,a0,1222 # 80008890 <syscall_names+0x2b8>
    800053d2:	ffffb097          	auipc	ra,0xffffb
    800053d6:	170080e7          	jalr	368(ra) # 80000542 <panic>
    dp->nlink++;  // for ".."
    800053da:	04a95783          	lhu	a5,74(s2)
    800053de:	2785                	addiw	a5,a5,1
    800053e0:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800053e4:	854a                	mv	a0,s2
    800053e6:	ffffe097          	auipc	ra,0xffffe
    800053ea:	4c8080e7          	jalr	1224(ra) # 800038ae <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053ee:	40d0                	lw	a2,4(s1)
    800053f0:	00003597          	auipc	a1,0x3
    800053f4:	4b058593          	addi	a1,a1,1200 # 800088a0 <syscall_names+0x2c8>
    800053f8:	8526                	mv	a0,s1
    800053fa:	fffff097          	auipc	ra,0xfffff
    800053fe:	c6c080e7          	jalr	-916(ra) # 80004066 <dirlink>
    80005402:	00054f63          	bltz	a0,80005420 <create+0x142>
    80005406:	00492603          	lw	a2,4(s2)
    8000540a:	00003597          	auipc	a1,0x3
    8000540e:	49e58593          	addi	a1,a1,1182 # 800088a8 <syscall_names+0x2d0>
    80005412:	8526                	mv	a0,s1
    80005414:	fffff097          	auipc	ra,0xfffff
    80005418:	c52080e7          	jalr	-942(ra) # 80004066 <dirlink>
    8000541c:	f80557e3          	bgez	a0,800053aa <create+0xcc>
      panic("create dots");
    80005420:	00003517          	auipc	a0,0x3
    80005424:	49050513          	addi	a0,a0,1168 # 800088b0 <syscall_names+0x2d8>
    80005428:	ffffb097          	auipc	ra,0xffffb
    8000542c:	11a080e7          	jalr	282(ra) # 80000542 <panic>
    panic("create: dirlink");
    80005430:	00003517          	auipc	a0,0x3
    80005434:	49050513          	addi	a0,a0,1168 # 800088c0 <syscall_names+0x2e8>
    80005438:	ffffb097          	auipc	ra,0xffffb
    8000543c:	10a080e7          	jalr	266(ra) # 80000542 <panic>
    return 0;
    80005440:	84aa                	mv	s1,a0
    80005442:	b739                	j	80005350 <create+0x72>

0000000080005444 <sys_dup>:
{
    80005444:	7179                	addi	sp,sp,-48
    80005446:	f406                	sd	ra,40(sp)
    80005448:	f022                	sd	s0,32(sp)
    8000544a:	ec26                	sd	s1,24(sp)
    8000544c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000544e:	fd840613          	addi	a2,s0,-40
    80005452:	4581                	li	a1,0
    80005454:	4501                	li	a0,0
    80005456:	00000097          	auipc	ra,0x0
    8000545a:	dde080e7          	jalr	-546(ra) # 80005234 <argfd>
    return -1;
    8000545e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005460:	02054363          	bltz	a0,80005486 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005464:	fd843503          	ld	a0,-40(s0)
    80005468:	00000097          	auipc	ra,0x0
    8000546c:	e34080e7          	jalr	-460(ra) # 8000529c <fdalloc>
    80005470:	84aa                	mv	s1,a0
    return -1;
    80005472:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005474:	00054963          	bltz	a0,80005486 <sys_dup+0x42>
  filedup(f);
    80005478:	fd843503          	ld	a0,-40(s0)
    8000547c:	fffff097          	auipc	ra,0xfffff
    80005480:	338080e7          	jalr	824(ra) # 800047b4 <filedup>
  return fd;
    80005484:	87a6                	mv	a5,s1
}
    80005486:	853e                	mv	a0,a5
    80005488:	70a2                	ld	ra,40(sp)
    8000548a:	7402                	ld	s0,32(sp)
    8000548c:	64e2                	ld	s1,24(sp)
    8000548e:	6145                	addi	sp,sp,48
    80005490:	8082                	ret

0000000080005492 <sys_read>:
{
    80005492:	7179                	addi	sp,sp,-48
    80005494:	f406                	sd	ra,40(sp)
    80005496:	f022                	sd	s0,32(sp)
    80005498:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000549a:	fe840613          	addi	a2,s0,-24
    8000549e:	4581                	li	a1,0
    800054a0:	4501                	li	a0,0
    800054a2:	00000097          	auipc	ra,0x0
    800054a6:	d92080e7          	jalr	-622(ra) # 80005234 <argfd>
    return -1;
    800054aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ac:	04054163          	bltz	a0,800054ee <sys_read+0x5c>
    800054b0:	fe440593          	addi	a1,s0,-28
    800054b4:	4509                	li	a0,2
    800054b6:	ffffd097          	auipc	ra,0xffffd
    800054ba:	79c080e7          	jalr	1948(ra) # 80002c52 <argint>
    return -1;
    800054be:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054c0:	02054763          	bltz	a0,800054ee <sys_read+0x5c>
    800054c4:	fd840593          	addi	a1,s0,-40
    800054c8:	4505                	li	a0,1
    800054ca:	ffffd097          	auipc	ra,0xffffd
    800054ce:	7aa080e7          	jalr	1962(ra) # 80002c74 <argaddr>
    return -1;
    800054d2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054d4:	00054d63          	bltz	a0,800054ee <sys_read+0x5c>
  return fileread(f, p, n);
    800054d8:	fe442603          	lw	a2,-28(s0)
    800054dc:	fd843583          	ld	a1,-40(s0)
    800054e0:	fe843503          	ld	a0,-24(s0)
    800054e4:	fffff097          	auipc	ra,0xfffff
    800054e8:	45c080e7          	jalr	1116(ra) # 80004940 <fileread>
    800054ec:	87aa                	mv	a5,a0
}
    800054ee:	853e                	mv	a0,a5
    800054f0:	70a2                	ld	ra,40(sp)
    800054f2:	7402                	ld	s0,32(sp)
    800054f4:	6145                	addi	sp,sp,48
    800054f6:	8082                	ret

00000000800054f8 <sys_write>:
{
    800054f8:	7179                	addi	sp,sp,-48
    800054fa:	f406                	sd	ra,40(sp)
    800054fc:	f022                	sd	s0,32(sp)
    800054fe:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005500:	fe840613          	addi	a2,s0,-24
    80005504:	4581                	li	a1,0
    80005506:	4501                	li	a0,0
    80005508:	00000097          	auipc	ra,0x0
    8000550c:	d2c080e7          	jalr	-724(ra) # 80005234 <argfd>
    return -1;
    80005510:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005512:	04054163          	bltz	a0,80005554 <sys_write+0x5c>
    80005516:	fe440593          	addi	a1,s0,-28
    8000551a:	4509                	li	a0,2
    8000551c:	ffffd097          	auipc	ra,0xffffd
    80005520:	736080e7          	jalr	1846(ra) # 80002c52 <argint>
    return -1;
    80005524:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005526:	02054763          	bltz	a0,80005554 <sys_write+0x5c>
    8000552a:	fd840593          	addi	a1,s0,-40
    8000552e:	4505                	li	a0,1
    80005530:	ffffd097          	auipc	ra,0xffffd
    80005534:	744080e7          	jalr	1860(ra) # 80002c74 <argaddr>
    return -1;
    80005538:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000553a:	00054d63          	bltz	a0,80005554 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000553e:	fe442603          	lw	a2,-28(s0)
    80005542:	fd843583          	ld	a1,-40(s0)
    80005546:	fe843503          	ld	a0,-24(s0)
    8000554a:	fffff097          	auipc	ra,0xfffff
    8000554e:	4b8080e7          	jalr	1208(ra) # 80004a02 <filewrite>
    80005552:	87aa                	mv	a5,a0
}
    80005554:	853e                	mv	a0,a5
    80005556:	70a2                	ld	ra,40(sp)
    80005558:	7402                	ld	s0,32(sp)
    8000555a:	6145                	addi	sp,sp,48
    8000555c:	8082                	ret

000000008000555e <sys_close>:
{
    8000555e:	1101                	addi	sp,sp,-32
    80005560:	ec06                	sd	ra,24(sp)
    80005562:	e822                	sd	s0,16(sp)
    80005564:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005566:	fe040613          	addi	a2,s0,-32
    8000556a:	fec40593          	addi	a1,s0,-20
    8000556e:	4501                	li	a0,0
    80005570:	00000097          	auipc	ra,0x0
    80005574:	cc4080e7          	jalr	-828(ra) # 80005234 <argfd>
    return -1;
    80005578:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000557a:	02054463          	bltz	a0,800055a2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000557e:	ffffc097          	auipc	ra,0xffffc
    80005582:	4de080e7          	jalr	1246(ra) # 80001a5c <myproc>
    80005586:	fec42783          	lw	a5,-20(s0)
    8000558a:	07e9                	addi	a5,a5,26
    8000558c:	078e                	slli	a5,a5,0x3
    8000558e:	97aa                	add	a5,a5,a0
    80005590:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005594:	fe043503          	ld	a0,-32(s0)
    80005598:	fffff097          	auipc	ra,0xfffff
    8000559c:	26e080e7          	jalr	622(ra) # 80004806 <fileclose>
  return 0;
    800055a0:	4781                	li	a5,0
}
    800055a2:	853e                	mv	a0,a5
    800055a4:	60e2                	ld	ra,24(sp)
    800055a6:	6442                	ld	s0,16(sp)
    800055a8:	6105                	addi	sp,sp,32
    800055aa:	8082                	ret

00000000800055ac <sys_fstat>:
{
    800055ac:	1101                	addi	sp,sp,-32
    800055ae:	ec06                	sd	ra,24(sp)
    800055b0:	e822                	sd	s0,16(sp)
    800055b2:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055b4:	fe840613          	addi	a2,s0,-24
    800055b8:	4581                	li	a1,0
    800055ba:	4501                	li	a0,0
    800055bc:	00000097          	auipc	ra,0x0
    800055c0:	c78080e7          	jalr	-904(ra) # 80005234 <argfd>
    return -1;
    800055c4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055c6:	02054563          	bltz	a0,800055f0 <sys_fstat+0x44>
    800055ca:	fe040593          	addi	a1,s0,-32
    800055ce:	4505                	li	a0,1
    800055d0:	ffffd097          	auipc	ra,0xffffd
    800055d4:	6a4080e7          	jalr	1700(ra) # 80002c74 <argaddr>
    return -1;
    800055d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055da:	00054b63          	bltz	a0,800055f0 <sys_fstat+0x44>
  return filestat(f, st);
    800055de:	fe043583          	ld	a1,-32(s0)
    800055e2:	fe843503          	ld	a0,-24(s0)
    800055e6:	fffff097          	auipc	ra,0xfffff
    800055ea:	2e8080e7          	jalr	744(ra) # 800048ce <filestat>
    800055ee:	87aa                	mv	a5,a0
}
    800055f0:	853e                	mv	a0,a5
    800055f2:	60e2                	ld	ra,24(sp)
    800055f4:	6442                	ld	s0,16(sp)
    800055f6:	6105                	addi	sp,sp,32
    800055f8:	8082                	ret

00000000800055fa <sys_link>:
{
    800055fa:	7169                	addi	sp,sp,-304
    800055fc:	f606                	sd	ra,296(sp)
    800055fe:	f222                	sd	s0,288(sp)
    80005600:	ee26                	sd	s1,280(sp)
    80005602:	ea4a                	sd	s2,272(sp)
    80005604:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005606:	08000613          	li	a2,128
    8000560a:	ed040593          	addi	a1,s0,-304
    8000560e:	4501                	li	a0,0
    80005610:	ffffd097          	auipc	ra,0xffffd
    80005614:	686080e7          	jalr	1670(ra) # 80002c96 <argstr>
    return -1;
    80005618:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000561a:	10054e63          	bltz	a0,80005736 <sys_link+0x13c>
    8000561e:	08000613          	li	a2,128
    80005622:	f5040593          	addi	a1,s0,-176
    80005626:	4505                	li	a0,1
    80005628:	ffffd097          	auipc	ra,0xffffd
    8000562c:	66e080e7          	jalr	1646(ra) # 80002c96 <argstr>
    return -1;
    80005630:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005632:	10054263          	bltz	a0,80005736 <sys_link+0x13c>
  begin_op();
    80005636:	fffff097          	auipc	ra,0xfffff
    8000563a:	cfe080e7          	jalr	-770(ra) # 80004334 <begin_op>
  if((ip = namei(old)) == 0){
    8000563e:	ed040513          	addi	a0,s0,-304
    80005642:	fffff097          	auipc	ra,0xfffff
    80005646:	ae6080e7          	jalr	-1306(ra) # 80004128 <namei>
    8000564a:	84aa                	mv	s1,a0
    8000564c:	c551                	beqz	a0,800056d8 <sys_link+0xde>
  ilock(ip);
    8000564e:	ffffe097          	auipc	ra,0xffffe
    80005652:	32a080e7          	jalr	810(ra) # 80003978 <ilock>
  if(ip->type == T_DIR){
    80005656:	04449703          	lh	a4,68(s1)
    8000565a:	4785                	li	a5,1
    8000565c:	08f70463          	beq	a4,a5,800056e4 <sys_link+0xea>
  ip->nlink++;
    80005660:	04a4d783          	lhu	a5,74(s1)
    80005664:	2785                	addiw	a5,a5,1
    80005666:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000566a:	8526                	mv	a0,s1
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	242080e7          	jalr	578(ra) # 800038ae <iupdate>
  iunlock(ip);
    80005674:	8526                	mv	a0,s1
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	3c4080e7          	jalr	964(ra) # 80003a3a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000567e:	fd040593          	addi	a1,s0,-48
    80005682:	f5040513          	addi	a0,s0,-176
    80005686:	fffff097          	auipc	ra,0xfffff
    8000568a:	ac0080e7          	jalr	-1344(ra) # 80004146 <nameiparent>
    8000568e:	892a                	mv	s2,a0
    80005690:	c935                	beqz	a0,80005704 <sys_link+0x10a>
  ilock(dp);
    80005692:	ffffe097          	auipc	ra,0xffffe
    80005696:	2e6080e7          	jalr	742(ra) # 80003978 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000569a:	00092703          	lw	a4,0(s2)
    8000569e:	409c                	lw	a5,0(s1)
    800056a0:	04f71d63          	bne	a4,a5,800056fa <sys_link+0x100>
    800056a4:	40d0                	lw	a2,4(s1)
    800056a6:	fd040593          	addi	a1,s0,-48
    800056aa:	854a                	mv	a0,s2
    800056ac:	fffff097          	auipc	ra,0xfffff
    800056b0:	9ba080e7          	jalr	-1606(ra) # 80004066 <dirlink>
    800056b4:	04054363          	bltz	a0,800056fa <sys_link+0x100>
  iunlockput(dp);
    800056b8:	854a                	mv	a0,s2
    800056ba:	ffffe097          	auipc	ra,0xffffe
    800056be:	520080e7          	jalr	1312(ra) # 80003bda <iunlockput>
  iput(ip);
    800056c2:	8526                	mv	a0,s1
    800056c4:	ffffe097          	auipc	ra,0xffffe
    800056c8:	46e080e7          	jalr	1134(ra) # 80003b32 <iput>
  end_op();
    800056cc:	fffff097          	auipc	ra,0xfffff
    800056d0:	ce8080e7          	jalr	-792(ra) # 800043b4 <end_op>
  return 0;
    800056d4:	4781                	li	a5,0
    800056d6:	a085                	j	80005736 <sys_link+0x13c>
    end_op();
    800056d8:	fffff097          	auipc	ra,0xfffff
    800056dc:	cdc080e7          	jalr	-804(ra) # 800043b4 <end_op>
    return -1;
    800056e0:	57fd                	li	a5,-1
    800056e2:	a891                	j	80005736 <sys_link+0x13c>
    iunlockput(ip);
    800056e4:	8526                	mv	a0,s1
    800056e6:	ffffe097          	auipc	ra,0xffffe
    800056ea:	4f4080e7          	jalr	1268(ra) # 80003bda <iunlockput>
    end_op();
    800056ee:	fffff097          	auipc	ra,0xfffff
    800056f2:	cc6080e7          	jalr	-826(ra) # 800043b4 <end_op>
    return -1;
    800056f6:	57fd                	li	a5,-1
    800056f8:	a83d                	j	80005736 <sys_link+0x13c>
    iunlockput(dp);
    800056fa:	854a                	mv	a0,s2
    800056fc:	ffffe097          	auipc	ra,0xffffe
    80005700:	4de080e7          	jalr	1246(ra) # 80003bda <iunlockput>
  ilock(ip);
    80005704:	8526                	mv	a0,s1
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	272080e7          	jalr	626(ra) # 80003978 <ilock>
  ip->nlink--;
    8000570e:	04a4d783          	lhu	a5,74(s1)
    80005712:	37fd                	addiw	a5,a5,-1
    80005714:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005718:	8526                	mv	a0,s1
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	194080e7          	jalr	404(ra) # 800038ae <iupdate>
  iunlockput(ip);
    80005722:	8526                	mv	a0,s1
    80005724:	ffffe097          	auipc	ra,0xffffe
    80005728:	4b6080e7          	jalr	1206(ra) # 80003bda <iunlockput>
  end_op();
    8000572c:	fffff097          	auipc	ra,0xfffff
    80005730:	c88080e7          	jalr	-888(ra) # 800043b4 <end_op>
  return -1;
    80005734:	57fd                	li	a5,-1
}
    80005736:	853e                	mv	a0,a5
    80005738:	70b2                	ld	ra,296(sp)
    8000573a:	7412                	ld	s0,288(sp)
    8000573c:	64f2                	ld	s1,280(sp)
    8000573e:	6952                	ld	s2,272(sp)
    80005740:	6155                	addi	sp,sp,304
    80005742:	8082                	ret

0000000080005744 <sys_unlink>:
{
    80005744:	7151                	addi	sp,sp,-240
    80005746:	f586                	sd	ra,232(sp)
    80005748:	f1a2                	sd	s0,224(sp)
    8000574a:	eda6                	sd	s1,216(sp)
    8000574c:	e9ca                	sd	s2,208(sp)
    8000574e:	e5ce                	sd	s3,200(sp)
    80005750:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005752:	08000613          	li	a2,128
    80005756:	f3040593          	addi	a1,s0,-208
    8000575a:	4501                	li	a0,0
    8000575c:	ffffd097          	auipc	ra,0xffffd
    80005760:	53a080e7          	jalr	1338(ra) # 80002c96 <argstr>
    80005764:	18054163          	bltz	a0,800058e6 <sys_unlink+0x1a2>
  begin_op();
    80005768:	fffff097          	auipc	ra,0xfffff
    8000576c:	bcc080e7          	jalr	-1076(ra) # 80004334 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005770:	fb040593          	addi	a1,s0,-80
    80005774:	f3040513          	addi	a0,s0,-208
    80005778:	fffff097          	auipc	ra,0xfffff
    8000577c:	9ce080e7          	jalr	-1586(ra) # 80004146 <nameiparent>
    80005780:	84aa                	mv	s1,a0
    80005782:	c979                	beqz	a0,80005858 <sys_unlink+0x114>
  ilock(dp);
    80005784:	ffffe097          	auipc	ra,0xffffe
    80005788:	1f4080e7          	jalr	500(ra) # 80003978 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000578c:	00003597          	auipc	a1,0x3
    80005790:	11458593          	addi	a1,a1,276 # 800088a0 <syscall_names+0x2c8>
    80005794:	fb040513          	addi	a0,s0,-80
    80005798:	ffffe097          	auipc	ra,0xffffe
    8000579c:	6a4080e7          	jalr	1700(ra) # 80003e3c <namecmp>
    800057a0:	14050a63          	beqz	a0,800058f4 <sys_unlink+0x1b0>
    800057a4:	00003597          	auipc	a1,0x3
    800057a8:	10458593          	addi	a1,a1,260 # 800088a8 <syscall_names+0x2d0>
    800057ac:	fb040513          	addi	a0,s0,-80
    800057b0:	ffffe097          	auipc	ra,0xffffe
    800057b4:	68c080e7          	jalr	1676(ra) # 80003e3c <namecmp>
    800057b8:	12050e63          	beqz	a0,800058f4 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057bc:	f2c40613          	addi	a2,s0,-212
    800057c0:	fb040593          	addi	a1,s0,-80
    800057c4:	8526                	mv	a0,s1
    800057c6:	ffffe097          	auipc	ra,0xffffe
    800057ca:	690080e7          	jalr	1680(ra) # 80003e56 <dirlookup>
    800057ce:	892a                	mv	s2,a0
    800057d0:	12050263          	beqz	a0,800058f4 <sys_unlink+0x1b0>
  ilock(ip);
    800057d4:	ffffe097          	auipc	ra,0xffffe
    800057d8:	1a4080e7          	jalr	420(ra) # 80003978 <ilock>
  if(ip->nlink < 1)
    800057dc:	04a91783          	lh	a5,74(s2)
    800057e0:	08f05263          	blez	a5,80005864 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057e4:	04491703          	lh	a4,68(s2)
    800057e8:	4785                	li	a5,1
    800057ea:	08f70563          	beq	a4,a5,80005874 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057ee:	4641                	li	a2,16
    800057f0:	4581                	li	a1,0
    800057f2:	fc040513          	addi	a0,s0,-64
    800057f6:	ffffb097          	auipc	ra,0xffffb
    800057fa:	596080e7          	jalr	1430(ra) # 80000d8c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057fe:	4741                	li	a4,16
    80005800:	f2c42683          	lw	a3,-212(s0)
    80005804:	fc040613          	addi	a2,s0,-64
    80005808:	4581                	li	a1,0
    8000580a:	8526                	mv	a0,s1
    8000580c:	ffffe097          	auipc	ra,0xffffe
    80005810:	516080e7          	jalr	1302(ra) # 80003d22 <writei>
    80005814:	47c1                	li	a5,16
    80005816:	0af51563          	bne	a0,a5,800058c0 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000581a:	04491703          	lh	a4,68(s2)
    8000581e:	4785                	li	a5,1
    80005820:	0af70863          	beq	a4,a5,800058d0 <sys_unlink+0x18c>
  iunlockput(dp);
    80005824:	8526                	mv	a0,s1
    80005826:	ffffe097          	auipc	ra,0xffffe
    8000582a:	3b4080e7          	jalr	948(ra) # 80003bda <iunlockput>
  ip->nlink--;
    8000582e:	04a95783          	lhu	a5,74(s2)
    80005832:	37fd                	addiw	a5,a5,-1
    80005834:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005838:	854a                	mv	a0,s2
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	074080e7          	jalr	116(ra) # 800038ae <iupdate>
  iunlockput(ip);
    80005842:	854a                	mv	a0,s2
    80005844:	ffffe097          	auipc	ra,0xffffe
    80005848:	396080e7          	jalr	918(ra) # 80003bda <iunlockput>
  end_op();
    8000584c:	fffff097          	auipc	ra,0xfffff
    80005850:	b68080e7          	jalr	-1176(ra) # 800043b4 <end_op>
  return 0;
    80005854:	4501                	li	a0,0
    80005856:	a84d                	j	80005908 <sys_unlink+0x1c4>
    end_op();
    80005858:	fffff097          	auipc	ra,0xfffff
    8000585c:	b5c080e7          	jalr	-1188(ra) # 800043b4 <end_op>
    return -1;
    80005860:	557d                	li	a0,-1
    80005862:	a05d                	j	80005908 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005864:	00003517          	auipc	a0,0x3
    80005868:	06c50513          	addi	a0,a0,108 # 800088d0 <syscall_names+0x2f8>
    8000586c:	ffffb097          	auipc	ra,0xffffb
    80005870:	cd6080e7          	jalr	-810(ra) # 80000542 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005874:	04c92703          	lw	a4,76(s2)
    80005878:	02000793          	li	a5,32
    8000587c:	f6e7f9e3          	bgeu	a5,a4,800057ee <sys_unlink+0xaa>
    80005880:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005884:	4741                	li	a4,16
    80005886:	86ce                	mv	a3,s3
    80005888:	f1840613          	addi	a2,s0,-232
    8000588c:	4581                	li	a1,0
    8000588e:	854a                	mv	a0,s2
    80005890:	ffffe097          	auipc	ra,0xffffe
    80005894:	39c080e7          	jalr	924(ra) # 80003c2c <readi>
    80005898:	47c1                	li	a5,16
    8000589a:	00f51b63          	bne	a0,a5,800058b0 <sys_unlink+0x16c>
    if(de.inum != 0)
    8000589e:	f1845783          	lhu	a5,-232(s0)
    800058a2:	e7a1                	bnez	a5,800058ea <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058a4:	29c1                	addiw	s3,s3,16
    800058a6:	04c92783          	lw	a5,76(s2)
    800058aa:	fcf9ede3          	bltu	s3,a5,80005884 <sys_unlink+0x140>
    800058ae:	b781                	j	800057ee <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058b0:	00003517          	auipc	a0,0x3
    800058b4:	03850513          	addi	a0,a0,56 # 800088e8 <syscall_names+0x310>
    800058b8:	ffffb097          	auipc	ra,0xffffb
    800058bc:	c8a080e7          	jalr	-886(ra) # 80000542 <panic>
    panic("unlink: writei");
    800058c0:	00003517          	auipc	a0,0x3
    800058c4:	04050513          	addi	a0,a0,64 # 80008900 <syscall_names+0x328>
    800058c8:	ffffb097          	auipc	ra,0xffffb
    800058cc:	c7a080e7          	jalr	-902(ra) # 80000542 <panic>
    dp->nlink--;
    800058d0:	04a4d783          	lhu	a5,74(s1)
    800058d4:	37fd                	addiw	a5,a5,-1
    800058d6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058da:	8526                	mv	a0,s1
    800058dc:	ffffe097          	auipc	ra,0xffffe
    800058e0:	fd2080e7          	jalr	-46(ra) # 800038ae <iupdate>
    800058e4:	b781                	j	80005824 <sys_unlink+0xe0>
    return -1;
    800058e6:	557d                	li	a0,-1
    800058e8:	a005                	j	80005908 <sys_unlink+0x1c4>
    iunlockput(ip);
    800058ea:	854a                	mv	a0,s2
    800058ec:	ffffe097          	auipc	ra,0xffffe
    800058f0:	2ee080e7          	jalr	750(ra) # 80003bda <iunlockput>
  iunlockput(dp);
    800058f4:	8526                	mv	a0,s1
    800058f6:	ffffe097          	auipc	ra,0xffffe
    800058fa:	2e4080e7          	jalr	740(ra) # 80003bda <iunlockput>
  end_op();
    800058fe:	fffff097          	auipc	ra,0xfffff
    80005902:	ab6080e7          	jalr	-1354(ra) # 800043b4 <end_op>
  return -1;
    80005906:	557d                	li	a0,-1
}
    80005908:	70ae                	ld	ra,232(sp)
    8000590a:	740e                	ld	s0,224(sp)
    8000590c:	64ee                	ld	s1,216(sp)
    8000590e:	694e                	ld	s2,208(sp)
    80005910:	69ae                	ld	s3,200(sp)
    80005912:	616d                	addi	sp,sp,240
    80005914:	8082                	ret

0000000080005916 <sys_open>:

uint64
sys_open(void)
{
    80005916:	7131                	addi	sp,sp,-192
    80005918:	fd06                	sd	ra,184(sp)
    8000591a:	f922                	sd	s0,176(sp)
    8000591c:	f526                	sd	s1,168(sp)
    8000591e:	f14a                	sd	s2,160(sp)
    80005920:	ed4e                	sd	s3,152(sp)
    80005922:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005924:	08000613          	li	a2,128
    80005928:	f5040593          	addi	a1,s0,-176
    8000592c:	4501                	li	a0,0
    8000592e:	ffffd097          	auipc	ra,0xffffd
    80005932:	368080e7          	jalr	872(ra) # 80002c96 <argstr>
    return -1;
    80005936:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005938:	0c054163          	bltz	a0,800059fa <sys_open+0xe4>
    8000593c:	f4c40593          	addi	a1,s0,-180
    80005940:	4505                	li	a0,1
    80005942:	ffffd097          	auipc	ra,0xffffd
    80005946:	310080e7          	jalr	784(ra) # 80002c52 <argint>
    8000594a:	0a054863          	bltz	a0,800059fa <sys_open+0xe4>

  begin_op();
    8000594e:	fffff097          	auipc	ra,0xfffff
    80005952:	9e6080e7          	jalr	-1562(ra) # 80004334 <begin_op>

  if(omode & O_CREATE){
    80005956:	f4c42783          	lw	a5,-180(s0)
    8000595a:	2007f793          	andi	a5,a5,512
    8000595e:	cbdd                	beqz	a5,80005a14 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005960:	4681                	li	a3,0
    80005962:	4601                	li	a2,0
    80005964:	4589                	li	a1,2
    80005966:	f5040513          	addi	a0,s0,-176
    8000596a:	00000097          	auipc	ra,0x0
    8000596e:	974080e7          	jalr	-1676(ra) # 800052de <create>
    80005972:	892a                	mv	s2,a0
    if(ip == 0){
    80005974:	c959                	beqz	a0,80005a0a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005976:	04491703          	lh	a4,68(s2)
    8000597a:	478d                	li	a5,3
    8000597c:	00f71763          	bne	a4,a5,8000598a <sys_open+0x74>
    80005980:	04695703          	lhu	a4,70(s2)
    80005984:	47a5                	li	a5,9
    80005986:	0ce7ec63          	bltu	a5,a4,80005a5e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000598a:	fffff097          	auipc	ra,0xfffff
    8000598e:	dc0080e7          	jalr	-576(ra) # 8000474a <filealloc>
    80005992:	89aa                	mv	s3,a0
    80005994:	10050263          	beqz	a0,80005a98 <sys_open+0x182>
    80005998:	00000097          	auipc	ra,0x0
    8000599c:	904080e7          	jalr	-1788(ra) # 8000529c <fdalloc>
    800059a0:	84aa                	mv	s1,a0
    800059a2:	0e054663          	bltz	a0,80005a8e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059a6:	04491703          	lh	a4,68(s2)
    800059aa:	478d                	li	a5,3
    800059ac:	0cf70463          	beq	a4,a5,80005a74 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059b0:	4789                	li	a5,2
    800059b2:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800059b6:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800059ba:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800059be:	f4c42783          	lw	a5,-180(s0)
    800059c2:	0017c713          	xori	a4,a5,1
    800059c6:	8b05                	andi	a4,a4,1
    800059c8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059cc:	0037f713          	andi	a4,a5,3
    800059d0:	00e03733          	snez	a4,a4
    800059d4:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059d8:	4007f793          	andi	a5,a5,1024
    800059dc:	c791                	beqz	a5,800059e8 <sys_open+0xd2>
    800059de:	04491703          	lh	a4,68(s2)
    800059e2:	4789                	li	a5,2
    800059e4:	08f70f63          	beq	a4,a5,80005a82 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800059e8:	854a                	mv	a0,s2
    800059ea:	ffffe097          	auipc	ra,0xffffe
    800059ee:	050080e7          	jalr	80(ra) # 80003a3a <iunlock>
  end_op();
    800059f2:	fffff097          	auipc	ra,0xfffff
    800059f6:	9c2080e7          	jalr	-1598(ra) # 800043b4 <end_op>

  return fd;
}
    800059fa:	8526                	mv	a0,s1
    800059fc:	70ea                	ld	ra,184(sp)
    800059fe:	744a                	ld	s0,176(sp)
    80005a00:	74aa                	ld	s1,168(sp)
    80005a02:	790a                	ld	s2,160(sp)
    80005a04:	69ea                	ld	s3,152(sp)
    80005a06:	6129                	addi	sp,sp,192
    80005a08:	8082                	ret
      end_op();
    80005a0a:	fffff097          	auipc	ra,0xfffff
    80005a0e:	9aa080e7          	jalr	-1622(ra) # 800043b4 <end_op>
      return -1;
    80005a12:	b7e5                	j	800059fa <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a14:	f5040513          	addi	a0,s0,-176
    80005a18:	ffffe097          	auipc	ra,0xffffe
    80005a1c:	710080e7          	jalr	1808(ra) # 80004128 <namei>
    80005a20:	892a                	mv	s2,a0
    80005a22:	c905                	beqz	a0,80005a52 <sys_open+0x13c>
    ilock(ip);
    80005a24:	ffffe097          	auipc	ra,0xffffe
    80005a28:	f54080e7          	jalr	-172(ra) # 80003978 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a2c:	04491703          	lh	a4,68(s2)
    80005a30:	4785                	li	a5,1
    80005a32:	f4f712e3          	bne	a4,a5,80005976 <sys_open+0x60>
    80005a36:	f4c42783          	lw	a5,-180(s0)
    80005a3a:	dba1                	beqz	a5,8000598a <sys_open+0x74>
      iunlockput(ip);
    80005a3c:	854a                	mv	a0,s2
    80005a3e:	ffffe097          	auipc	ra,0xffffe
    80005a42:	19c080e7          	jalr	412(ra) # 80003bda <iunlockput>
      end_op();
    80005a46:	fffff097          	auipc	ra,0xfffff
    80005a4a:	96e080e7          	jalr	-1682(ra) # 800043b4 <end_op>
      return -1;
    80005a4e:	54fd                	li	s1,-1
    80005a50:	b76d                	j	800059fa <sys_open+0xe4>
      end_op();
    80005a52:	fffff097          	auipc	ra,0xfffff
    80005a56:	962080e7          	jalr	-1694(ra) # 800043b4 <end_op>
      return -1;
    80005a5a:	54fd                	li	s1,-1
    80005a5c:	bf79                	j	800059fa <sys_open+0xe4>
    iunlockput(ip);
    80005a5e:	854a                	mv	a0,s2
    80005a60:	ffffe097          	auipc	ra,0xffffe
    80005a64:	17a080e7          	jalr	378(ra) # 80003bda <iunlockput>
    end_op();
    80005a68:	fffff097          	auipc	ra,0xfffff
    80005a6c:	94c080e7          	jalr	-1716(ra) # 800043b4 <end_op>
    return -1;
    80005a70:	54fd                	li	s1,-1
    80005a72:	b761                	j	800059fa <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a74:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a78:	04691783          	lh	a5,70(s2)
    80005a7c:	02f99223          	sh	a5,36(s3)
    80005a80:	bf2d                	j	800059ba <sys_open+0xa4>
    itrunc(ip);
    80005a82:	854a                	mv	a0,s2
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	002080e7          	jalr	2(ra) # 80003a86 <itrunc>
    80005a8c:	bfb1                	j	800059e8 <sys_open+0xd2>
      fileclose(f);
    80005a8e:	854e                	mv	a0,s3
    80005a90:	fffff097          	auipc	ra,0xfffff
    80005a94:	d76080e7          	jalr	-650(ra) # 80004806 <fileclose>
    iunlockput(ip);
    80005a98:	854a                	mv	a0,s2
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	140080e7          	jalr	320(ra) # 80003bda <iunlockput>
    end_op();
    80005aa2:	fffff097          	auipc	ra,0xfffff
    80005aa6:	912080e7          	jalr	-1774(ra) # 800043b4 <end_op>
    return -1;
    80005aaa:	54fd                	li	s1,-1
    80005aac:	b7b9                	j	800059fa <sys_open+0xe4>

0000000080005aae <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005aae:	7175                	addi	sp,sp,-144
    80005ab0:	e506                	sd	ra,136(sp)
    80005ab2:	e122                	sd	s0,128(sp)
    80005ab4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	87e080e7          	jalr	-1922(ra) # 80004334 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005abe:	08000613          	li	a2,128
    80005ac2:	f7040593          	addi	a1,s0,-144
    80005ac6:	4501                	li	a0,0
    80005ac8:	ffffd097          	auipc	ra,0xffffd
    80005acc:	1ce080e7          	jalr	462(ra) # 80002c96 <argstr>
    80005ad0:	02054963          	bltz	a0,80005b02 <sys_mkdir+0x54>
    80005ad4:	4681                	li	a3,0
    80005ad6:	4601                	li	a2,0
    80005ad8:	4585                	li	a1,1
    80005ada:	f7040513          	addi	a0,s0,-144
    80005ade:	00000097          	auipc	ra,0x0
    80005ae2:	800080e7          	jalr	-2048(ra) # 800052de <create>
    80005ae6:	cd11                	beqz	a0,80005b02 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ae8:	ffffe097          	auipc	ra,0xffffe
    80005aec:	0f2080e7          	jalr	242(ra) # 80003bda <iunlockput>
  end_op();
    80005af0:	fffff097          	auipc	ra,0xfffff
    80005af4:	8c4080e7          	jalr	-1852(ra) # 800043b4 <end_op>
  return 0;
    80005af8:	4501                	li	a0,0
}
    80005afa:	60aa                	ld	ra,136(sp)
    80005afc:	640a                	ld	s0,128(sp)
    80005afe:	6149                	addi	sp,sp,144
    80005b00:	8082                	ret
    end_op();
    80005b02:	fffff097          	auipc	ra,0xfffff
    80005b06:	8b2080e7          	jalr	-1870(ra) # 800043b4 <end_op>
    return -1;
    80005b0a:	557d                	li	a0,-1
    80005b0c:	b7fd                	j	80005afa <sys_mkdir+0x4c>

0000000080005b0e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b0e:	7135                	addi	sp,sp,-160
    80005b10:	ed06                	sd	ra,152(sp)
    80005b12:	e922                	sd	s0,144(sp)
    80005b14:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b16:	fffff097          	auipc	ra,0xfffff
    80005b1a:	81e080e7          	jalr	-2018(ra) # 80004334 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b1e:	08000613          	li	a2,128
    80005b22:	f7040593          	addi	a1,s0,-144
    80005b26:	4501                	li	a0,0
    80005b28:	ffffd097          	auipc	ra,0xffffd
    80005b2c:	16e080e7          	jalr	366(ra) # 80002c96 <argstr>
    80005b30:	04054a63          	bltz	a0,80005b84 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005b34:	f6c40593          	addi	a1,s0,-148
    80005b38:	4505                	li	a0,1
    80005b3a:	ffffd097          	auipc	ra,0xffffd
    80005b3e:	118080e7          	jalr	280(ra) # 80002c52 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b42:	04054163          	bltz	a0,80005b84 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005b46:	f6840593          	addi	a1,s0,-152
    80005b4a:	4509                	li	a0,2
    80005b4c:	ffffd097          	auipc	ra,0xffffd
    80005b50:	106080e7          	jalr	262(ra) # 80002c52 <argint>
     argint(1, &major) < 0 ||
    80005b54:	02054863          	bltz	a0,80005b84 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b58:	f6841683          	lh	a3,-152(s0)
    80005b5c:	f6c41603          	lh	a2,-148(s0)
    80005b60:	458d                	li	a1,3
    80005b62:	f7040513          	addi	a0,s0,-144
    80005b66:	fffff097          	auipc	ra,0xfffff
    80005b6a:	778080e7          	jalr	1912(ra) # 800052de <create>
     argint(2, &minor) < 0 ||
    80005b6e:	c919                	beqz	a0,80005b84 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b70:	ffffe097          	auipc	ra,0xffffe
    80005b74:	06a080e7          	jalr	106(ra) # 80003bda <iunlockput>
  end_op();
    80005b78:	fffff097          	auipc	ra,0xfffff
    80005b7c:	83c080e7          	jalr	-1988(ra) # 800043b4 <end_op>
  return 0;
    80005b80:	4501                	li	a0,0
    80005b82:	a031                	j	80005b8e <sys_mknod+0x80>
    end_op();
    80005b84:	fffff097          	auipc	ra,0xfffff
    80005b88:	830080e7          	jalr	-2000(ra) # 800043b4 <end_op>
    return -1;
    80005b8c:	557d                	li	a0,-1
}
    80005b8e:	60ea                	ld	ra,152(sp)
    80005b90:	644a                	ld	s0,144(sp)
    80005b92:	610d                	addi	sp,sp,160
    80005b94:	8082                	ret

0000000080005b96 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b96:	7135                	addi	sp,sp,-160
    80005b98:	ed06                	sd	ra,152(sp)
    80005b9a:	e922                	sd	s0,144(sp)
    80005b9c:	e526                	sd	s1,136(sp)
    80005b9e:	e14a                	sd	s2,128(sp)
    80005ba0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ba2:	ffffc097          	auipc	ra,0xffffc
    80005ba6:	eba080e7          	jalr	-326(ra) # 80001a5c <myproc>
    80005baa:	892a                	mv	s2,a0
  
  begin_op();
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	788080e7          	jalr	1928(ra) # 80004334 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bb4:	08000613          	li	a2,128
    80005bb8:	f6040593          	addi	a1,s0,-160
    80005bbc:	4501                	li	a0,0
    80005bbe:	ffffd097          	auipc	ra,0xffffd
    80005bc2:	0d8080e7          	jalr	216(ra) # 80002c96 <argstr>
    80005bc6:	04054b63          	bltz	a0,80005c1c <sys_chdir+0x86>
    80005bca:	f6040513          	addi	a0,s0,-160
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	55a080e7          	jalr	1370(ra) # 80004128 <namei>
    80005bd6:	84aa                	mv	s1,a0
    80005bd8:	c131                	beqz	a0,80005c1c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bda:	ffffe097          	auipc	ra,0xffffe
    80005bde:	d9e080e7          	jalr	-610(ra) # 80003978 <ilock>
  if(ip->type != T_DIR){
    80005be2:	04449703          	lh	a4,68(s1)
    80005be6:	4785                	li	a5,1
    80005be8:	04f71063          	bne	a4,a5,80005c28 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005bec:	8526                	mv	a0,s1
    80005bee:	ffffe097          	auipc	ra,0xffffe
    80005bf2:	e4c080e7          	jalr	-436(ra) # 80003a3a <iunlock>
  iput(p->cwd);
    80005bf6:	15093503          	ld	a0,336(s2)
    80005bfa:	ffffe097          	auipc	ra,0xffffe
    80005bfe:	f38080e7          	jalr	-200(ra) # 80003b32 <iput>
  end_op();
    80005c02:	ffffe097          	auipc	ra,0xffffe
    80005c06:	7b2080e7          	jalr	1970(ra) # 800043b4 <end_op>
  p->cwd = ip;
    80005c0a:	14993823          	sd	s1,336(s2)
  return 0;
    80005c0e:	4501                	li	a0,0
}
    80005c10:	60ea                	ld	ra,152(sp)
    80005c12:	644a                	ld	s0,144(sp)
    80005c14:	64aa                	ld	s1,136(sp)
    80005c16:	690a                	ld	s2,128(sp)
    80005c18:	610d                	addi	sp,sp,160
    80005c1a:	8082                	ret
    end_op();
    80005c1c:	ffffe097          	auipc	ra,0xffffe
    80005c20:	798080e7          	jalr	1944(ra) # 800043b4 <end_op>
    return -1;
    80005c24:	557d                	li	a0,-1
    80005c26:	b7ed                	j	80005c10 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c28:	8526                	mv	a0,s1
    80005c2a:	ffffe097          	auipc	ra,0xffffe
    80005c2e:	fb0080e7          	jalr	-80(ra) # 80003bda <iunlockput>
    end_op();
    80005c32:	ffffe097          	auipc	ra,0xffffe
    80005c36:	782080e7          	jalr	1922(ra) # 800043b4 <end_op>
    return -1;
    80005c3a:	557d                	li	a0,-1
    80005c3c:	bfd1                	j	80005c10 <sys_chdir+0x7a>

0000000080005c3e <sys_exec>:

uint64
sys_exec(void)
{
    80005c3e:	7145                	addi	sp,sp,-464
    80005c40:	e786                	sd	ra,456(sp)
    80005c42:	e3a2                	sd	s0,448(sp)
    80005c44:	ff26                	sd	s1,440(sp)
    80005c46:	fb4a                	sd	s2,432(sp)
    80005c48:	f74e                	sd	s3,424(sp)
    80005c4a:	f352                	sd	s4,416(sp)
    80005c4c:	ef56                	sd	s5,408(sp)
    80005c4e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c50:	08000613          	li	a2,128
    80005c54:	f4040593          	addi	a1,s0,-192
    80005c58:	4501                	li	a0,0
    80005c5a:	ffffd097          	auipc	ra,0xffffd
    80005c5e:	03c080e7          	jalr	60(ra) # 80002c96 <argstr>
    return -1;
    80005c62:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c64:	0c054a63          	bltz	a0,80005d38 <sys_exec+0xfa>
    80005c68:	e3840593          	addi	a1,s0,-456
    80005c6c:	4505                	li	a0,1
    80005c6e:	ffffd097          	auipc	ra,0xffffd
    80005c72:	006080e7          	jalr	6(ra) # 80002c74 <argaddr>
    80005c76:	0c054163          	bltz	a0,80005d38 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c7a:	10000613          	li	a2,256
    80005c7e:	4581                	li	a1,0
    80005c80:	e4040513          	addi	a0,s0,-448
    80005c84:	ffffb097          	auipc	ra,0xffffb
    80005c88:	108080e7          	jalr	264(ra) # 80000d8c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c8c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c90:	89a6                	mv	s3,s1
    80005c92:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c94:	02000a13          	li	s4,32
    80005c98:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c9c:	00391793          	slli	a5,s2,0x3
    80005ca0:	e3040593          	addi	a1,s0,-464
    80005ca4:	e3843503          	ld	a0,-456(s0)
    80005ca8:	953e                	add	a0,a0,a5
    80005caa:	ffffd097          	auipc	ra,0xffffd
    80005cae:	f0e080e7          	jalr	-242(ra) # 80002bb8 <fetchaddr>
    80005cb2:	02054a63          	bltz	a0,80005ce6 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005cb6:	e3043783          	ld	a5,-464(s0)
    80005cba:	c3b9                	beqz	a5,80005d00 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005cbc:	ffffb097          	auipc	ra,0xffffb
    80005cc0:	ebe080e7          	jalr	-322(ra) # 80000b7a <kalloc>
    80005cc4:	85aa                	mv	a1,a0
    80005cc6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005cca:	cd11                	beqz	a0,80005ce6 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ccc:	6605                	lui	a2,0x1
    80005cce:	e3043503          	ld	a0,-464(s0)
    80005cd2:	ffffd097          	auipc	ra,0xffffd
    80005cd6:	f38080e7          	jalr	-200(ra) # 80002c0a <fetchstr>
    80005cda:	00054663          	bltz	a0,80005ce6 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005cde:	0905                	addi	s2,s2,1
    80005ce0:	09a1                	addi	s3,s3,8
    80005ce2:	fb491be3          	bne	s2,s4,80005c98 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ce6:	10048913          	addi	s2,s1,256
    80005cea:	6088                	ld	a0,0(s1)
    80005cec:	c529                	beqz	a0,80005d36 <sys_exec+0xf8>
    kfree(argv[i]);
    80005cee:	ffffb097          	auipc	ra,0xffffb
    80005cf2:	d90080e7          	jalr	-624(ra) # 80000a7e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cf6:	04a1                	addi	s1,s1,8
    80005cf8:	ff2499e3          	bne	s1,s2,80005cea <sys_exec+0xac>
  return -1;
    80005cfc:	597d                	li	s2,-1
    80005cfe:	a82d                	j	80005d38 <sys_exec+0xfa>
      argv[i] = 0;
    80005d00:	0a8e                	slli	s5,s5,0x3
    80005d02:	fc040793          	addi	a5,s0,-64
    80005d06:	9abe                	add	s5,s5,a5
    80005d08:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd7e80>
  int ret = exec(path, argv);
    80005d0c:	e4040593          	addi	a1,s0,-448
    80005d10:	f4040513          	addi	a0,s0,-192
    80005d14:	fffff097          	auipc	ra,0xfffff
    80005d18:	178080e7          	jalr	376(ra) # 80004e8c <exec>
    80005d1c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d1e:	10048993          	addi	s3,s1,256
    80005d22:	6088                	ld	a0,0(s1)
    80005d24:	c911                	beqz	a0,80005d38 <sys_exec+0xfa>
    kfree(argv[i]);
    80005d26:	ffffb097          	auipc	ra,0xffffb
    80005d2a:	d58080e7          	jalr	-680(ra) # 80000a7e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d2e:	04a1                	addi	s1,s1,8
    80005d30:	ff3499e3          	bne	s1,s3,80005d22 <sys_exec+0xe4>
    80005d34:	a011                	j	80005d38 <sys_exec+0xfa>
  return -1;
    80005d36:	597d                	li	s2,-1
}
    80005d38:	854a                	mv	a0,s2
    80005d3a:	60be                	ld	ra,456(sp)
    80005d3c:	641e                	ld	s0,448(sp)
    80005d3e:	74fa                	ld	s1,440(sp)
    80005d40:	795a                	ld	s2,432(sp)
    80005d42:	79ba                	ld	s3,424(sp)
    80005d44:	7a1a                	ld	s4,416(sp)
    80005d46:	6afa                	ld	s5,408(sp)
    80005d48:	6179                	addi	sp,sp,464
    80005d4a:	8082                	ret

0000000080005d4c <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d4c:	7139                	addi	sp,sp,-64
    80005d4e:	fc06                	sd	ra,56(sp)
    80005d50:	f822                	sd	s0,48(sp)
    80005d52:	f426                	sd	s1,40(sp)
    80005d54:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d56:	ffffc097          	auipc	ra,0xffffc
    80005d5a:	d06080e7          	jalr	-762(ra) # 80001a5c <myproc>
    80005d5e:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d60:	fd840593          	addi	a1,s0,-40
    80005d64:	4501                	li	a0,0
    80005d66:	ffffd097          	auipc	ra,0xffffd
    80005d6a:	f0e080e7          	jalr	-242(ra) # 80002c74 <argaddr>
    return -1;
    80005d6e:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d70:	0e054063          	bltz	a0,80005e50 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d74:	fc840593          	addi	a1,s0,-56
    80005d78:	fd040513          	addi	a0,s0,-48
    80005d7c:	fffff097          	auipc	ra,0xfffff
    80005d80:	de0080e7          	jalr	-544(ra) # 80004b5c <pipealloc>
    return -1;
    80005d84:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d86:	0c054563          	bltz	a0,80005e50 <sys_pipe+0x104>
  fd0 = -1;
    80005d8a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d8e:	fd043503          	ld	a0,-48(s0)
    80005d92:	fffff097          	auipc	ra,0xfffff
    80005d96:	50a080e7          	jalr	1290(ra) # 8000529c <fdalloc>
    80005d9a:	fca42223          	sw	a0,-60(s0)
    80005d9e:	08054c63          	bltz	a0,80005e36 <sys_pipe+0xea>
    80005da2:	fc843503          	ld	a0,-56(s0)
    80005da6:	fffff097          	auipc	ra,0xfffff
    80005daa:	4f6080e7          	jalr	1270(ra) # 8000529c <fdalloc>
    80005dae:	fca42023          	sw	a0,-64(s0)
    80005db2:	06054863          	bltz	a0,80005e22 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005db6:	4691                	li	a3,4
    80005db8:	fc440613          	addi	a2,s0,-60
    80005dbc:	fd843583          	ld	a1,-40(s0)
    80005dc0:	68a8                	ld	a0,80(s1)
    80005dc2:	ffffc097          	auipc	ra,0xffffc
    80005dc6:	98c080e7          	jalr	-1652(ra) # 8000174e <copyout>
    80005dca:	02054063          	bltz	a0,80005dea <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005dce:	4691                	li	a3,4
    80005dd0:	fc040613          	addi	a2,s0,-64
    80005dd4:	fd843583          	ld	a1,-40(s0)
    80005dd8:	0591                	addi	a1,a1,4
    80005dda:	68a8                	ld	a0,80(s1)
    80005ddc:	ffffc097          	auipc	ra,0xffffc
    80005de0:	972080e7          	jalr	-1678(ra) # 8000174e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005de4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005de6:	06055563          	bgez	a0,80005e50 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005dea:	fc442783          	lw	a5,-60(s0)
    80005dee:	07e9                	addi	a5,a5,26
    80005df0:	078e                	slli	a5,a5,0x3
    80005df2:	97a6                	add	a5,a5,s1
    80005df4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005df8:	fc042503          	lw	a0,-64(s0)
    80005dfc:	0569                	addi	a0,a0,26
    80005dfe:	050e                	slli	a0,a0,0x3
    80005e00:	9526                	add	a0,a0,s1
    80005e02:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005e06:	fd043503          	ld	a0,-48(s0)
    80005e0a:	fffff097          	auipc	ra,0xfffff
    80005e0e:	9fc080e7          	jalr	-1540(ra) # 80004806 <fileclose>
    fileclose(wf);
    80005e12:	fc843503          	ld	a0,-56(s0)
    80005e16:	fffff097          	auipc	ra,0xfffff
    80005e1a:	9f0080e7          	jalr	-1552(ra) # 80004806 <fileclose>
    return -1;
    80005e1e:	57fd                	li	a5,-1
    80005e20:	a805                	j	80005e50 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005e22:	fc442783          	lw	a5,-60(s0)
    80005e26:	0007c863          	bltz	a5,80005e36 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005e2a:	01a78513          	addi	a0,a5,26
    80005e2e:	050e                	slli	a0,a0,0x3
    80005e30:	9526                	add	a0,a0,s1
    80005e32:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005e36:	fd043503          	ld	a0,-48(s0)
    80005e3a:	fffff097          	auipc	ra,0xfffff
    80005e3e:	9cc080e7          	jalr	-1588(ra) # 80004806 <fileclose>
    fileclose(wf);
    80005e42:	fc843503          	ld	a0,-56(s0)
    80005e46:	fffff097          	auipc	ra,0xfffff
    80005e4a:	9c0080e7          	jalr	-1600(ra) # 80004806 <fileclose>
    return -1;
    80005e4e:	57fd                	li	a5,-1
}
    80005e50:	853e                	mv	a0,a5
    80005e52:	70e2                	ld	ra,56(sp)
    80005e54:	7442                	ld	s0,48(sp)
    80005e56:	74a2                	ld	s1,40(sp)
    80005e58:	6121                	addi	sp,sp,64
    80005e5a:	8082                	ret
    80005e5c:	0000                	unimp
	...

0000000080005e60 <kernelvec>:
    80005e60:	7111                	addi	sp,sp,-256
    80005e62:	e006                	sd	ra,0(sp)
    80005e64:	e40a                	sd	sp,8(sp)
    80005e66:	e80e                	sd	gp,16(sp)
    80005e68:	ec12                	sd	tp,24(sp)
    80005e6a:	f016                	sd	t0,32(sp)
    80005e6c:	f41a                	sd	t1,40(sp)
    80005e6e:	f81e                	sd	t2,48(sp)
    80005e70:	fc22                	sd	s0,56(sp)
    80005e72:	e0a6                	sd	s1,64(sp)
    80005e74:	e4aa                	sd	a0,72(sp)
    80005e76:	e8ae                	sd	a1,80(sp)
    80005e78:	ecb2                	sd	a2,88(sp)
    80005e7a:	f0b6                	sd	a3,96(sp)
    80005e7c:	f4ba                	sd	a4,104(sp)
    80005e7e:	f8be                	sd	a5,112(sp)
    80005e80:	fcc2                	sd	a6,120(sp)
    80005e82:	e146                	sd	a7,128(sp)
    80005e84:	e54a                	sd	s2,136(sp)
    80005e86:	e94e                	sd	s3,144(sp)
    80005e88:	ed52                	sd	s4,152(sp)
    80005e8a:	f156                	sd	s5,160(sp)
    80005e8c:	f55a                	sd	s6,168(sp)
    80005e8e:	f95e                	sd	s7,176(sp)
    80005e90:	fd62                	sd	s8,184(sp)
    80005e92:	e1e6                	sd	s9,192(sp)
    80005e94:	e5ea                	sd	s10,200(sp)
    80005e96:	e9ee                	sd	s11,208(sp)
    80005e98:	edf2                	sd	t3,216(sp)
    80005e9a:	f1f6                	sd	t4,224(sp)
    80005e9c:	f5fa                	sd	t5,232(sp)
    80005e9e:	f9fe                	sd	t6,240(sp)
    80005ea0:	9f3fc0ef          	jal	ra,80002892 <kerneltrap>
    80005ea4:	6082                	ld	ra,0(sp)
    80005ea6:	6122                	ld	sp,8(sp)
    80005ea8:	61c2                	ld	gp,16(sp)
    80005eaa:	7282                	ld	t0,32(sp)
    80005eac:	7322                	ld	t1,40(sp)
    80005eae:	73c2                	ld	t2,48(sp)
    80005eb0:	7462                	ld	s0,56(sp)
    80005eb2:	6486                	ld	s1,64(sp)
    80005eb4:	6526                	ld	a0,72(sp)
    80005eb6:	65c6                	ld	a1,80(sp)
    80005eb8:	6666                	ld	a2,88(sp)
    80005eba:	7686                	ld	a3,96(sp)
    80005ebc:	7726                	ld	a4,104(sp)
    80005ebe:	77c6                	ld	a5,112(sp)
    80005ec0:	7866                	ld	a6,120(sp)
    80005ec2:	688a                	ld	a7,128(sp)
    80005ec4:	692a                	ld	s2,136(sp)
    80005ec6:	69ca                	ld	s3,144(sp)
    80005ec8:	6a6a                	ld	s4,152(sp)
    80005eca:	7a8a                	ld	s5,160(sp)
    80005ecc:	7b2a                	ld	s6,168(sp)
    80005ece:	7bca                	ld	s7,176(sp)
    80005ed0:	7c6a                	ld	s8,184(sp)
    80005ed2:	6c8e                	ld	s9,192(sp)
    80005ed4:	6d2e                	ld	s10,200(sp)
    80005ed6:	6dce                	ld	s11,208(sp)
    80005ed8:	6e6e                	ld	t3,216(sp)
    80005eda:	7e8e                	ld	t4,224(sp)
    80005edc:	7f2e                	ld	t5,232(sp)
    80005ede:	7fce                	ld	t6,240(sp)
    80005ee0:	6111                	addi	sp,sp,256
    80005ee2:	10200073          	sret
    80005ee6:	00000013          	nop
    80005eea:	00000013          	nop
    80005eee:	0001                	nop

0000000080005ef0 <timervec>:
    80005ef0:	34051573          	csrrw	a0,mscratch,a0
    80005ef4:	e10c                	sd	a1,0(a0)
    80005ef6:	e510                	sd	a2,8(a0)
    80005ef8:	e914                	sd	a3,16(a0)
    80005efa:	710c                	ld	a1,32(a0)
    80005efc:	7510                	ld	a2,40(a0)
    80005efe:	6194                	ld	a3,0(a1)
    80005f00:	96b2                	add	a3,a3,a2
    80005f02:	e194                	sd	a3,0(a1)
    80005f04:	4589                	li	a1,2
    80005f06:	14459073          	csrw	sip,a1
    80005f0a:	6914                	ld	a3,16(a0)
    80005f0c:	6510                	ld	a2,8(a0)
    80005f0e:	610c                	ld	a1,0(a0)
    80005f10:	34051573          	csrrw	a0,mscratch,a0
    80005f14:	30200073          	mret
	...

0000000080005f1a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f1a:	1141                	addi	sp,sp,-16
    80005f1c:	e422                	sd	s0,8(sp)
    80005f1e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f20:	0c0007b7          	lui	a5,0xc000
    80005f24:	4705                	li	a4,1
    80005f26:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f28:	c3d8                	sw	a4,4(a5)
}
    80005f2a:	6422                	ld	s0,8(sp)
    80005f2c:	0141                	addi	sp,sp,16
    80005f2e:	8082                	ret

0000000080005f30 <plicinithart>:

void
plicinithart(void)
{
    80005f30:	1141                	addi	sp,sp,-16
    80005f32:	e406                	sd	ra,8(sp)
    80005f34:	e022                	sd	s0,0(sp)
    80005f36:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f38:	ffffc097          	auipc	ra,0xffffc
    80005f3c:	af8080e7          	jalr	-1288(ra) # 80001a30 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f40:	0085171b          	slliw	a4,a0,0x8
    80005f44:	0c0027b7          	lui	a5,0xc002
    80005f48:	97ba                	add	a5,a5,a4
    80005f4a:	40200713          	li	a4,1026
    80005f4e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f52:	00d5151b          	slliw	a0,a0,0xd
    80005f56:	0c2017b7          	lui	a5,0xc201
    80005f5a:	953e                	add	a0,a0,a5
    80005f5c:	00052023          	sw	zero,0(a0)
}
    80005f60:	60a2                	ld	ra,8(sp)
    80005f62:	6402                	ld	s0,0(sp)
    80005f64:	0141                	addi	sp,sp,16
    80005f66:	8082                	ret

0000000080005f68 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f68:	1141                	addi	sp,sp,-16
    80005f6a:	e406                	sd	ra,8(sp)
    80005f6c:	e022                	sd	s0,0(sp)
    80005f6e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f70:	ffffc097          	auipc	ra,0xffffc
    80005f74:	ac0080e7          	jalr	-1344(ra) # 80001a30 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f78:	00d5179b          	slliw	a5,a0,0xd
    80005f7c:	0c201537          	lui	a0,0xc201
    80005f80:	953e                	add	a0,a0,a5
  return irq;
}
    80005f82:	4148                	lw	a0,4(a0)
    80005f84:	60a2                	ld	ra,8(sp)
    80005f86:	6402                	ld	s0,0(sp)
    80005f88:	0141                	addi	sp,sp,16
    80005f8a:	8082                	ret

0000000080005f8c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f8c:	1101                	addi	sp,sp,-32
    80005f8e:	ec06                	sd	ra,24(sp)
    80005f90:	e822                	sd	s0,16(sp)
    80005f92:	e426                	sd	s1,8(sp)
    80005f94:	1000                	addi	s0,sp,32
    80005f96:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f98:	ffffc097          	auipc	ra,0xffffc
    80005f9c:	a98080e7          	jalr	-1384(ra) # 80001a30 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fa0:	00d5151b          	slliw	a0,a0,0xd
    80005fa4:	0c2017b7          	lui	a5,0xc201
    80005fa8:	97aa                	add	a5,a5,a0
    80005faa:	c3c4                	sw	s1,4(a5)
}
    80005fac:	60e2                	ld	ra,24(sp)
    80005fae:	6442                	ld	s0,16(sp)
    80005fb0:	64a2                	ld	s1,8(sp)
    80005fb2:	6105                	addi	sp,sp,32
    80005fb4:	8082                	ret

0000000080005fb6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005fb6:	1141                	addi	sp,sp,-16
    80005fb8:	e406                	sd	ra,8(sp)
    80005fba:	e022                	sd	s0,0(sp)
    80005fbc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005fbe:	479d                	li	a5,7
    80005fc0:	04a7cc63          	blt	a5,a0,80006018 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005fc4:	0001e797          	auipc	a5,0x1e
    80005fc8:	03c78793          	addi	a5,a5,60 # 80024000 <disk>
    80005fcc:	00a78733          	add	a4,a5,a0
    80005fd0:	6789                	lui	a5,0x2
    80005fd2:	97ba                	add	a5,a5,a4
    80005fd4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005fd8:	eba1                	bnez	a5,80006028 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005fda:	00451713          	slli	a4,a0,0x4
    80005fde:	00020797          	auipc	a5,0x20
    80005fe2:	0227b783          	ld	a5,34(a5) # 80026000 <disk+0x2000>
    80005fe6:	97ba                	add	a5,a5,a4
    80005fe8:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005fec:	0001e797          	auipc	a5,0x1e
    80005ff0:	01478793          	addi	a5,a5,20 # 80024000 <disk>
    80005ff4:	97aa                	add	a5,a5,a0
    80005ff6:	6509                	lui	a0,0x2
    80005ff8:	953e                	add	a0,a0,a5
    80005ffa:	4785                	li	a5,1
    80005ffc:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006000:	00020517          	auipc	a0,0x20
    80006004:	01850513          	addi	a0,a0,24 # 80026018 <disk+0x2018>
    80006008:	ffffc097          	auipc	ra,0xffffc
    8000600c:	3f6080e7          	jalr	1014(ra) # 800023fe <wakeup>
}
    80006010:	60a2                	ld	ra,8(sp)
    80006012:	6402                	ld	s0,0(sp)
    80006014:	0141                	addi	sp,sp,16
    80006016:	8082                	ret
    panic("virtio_disk_intr 1");
    80006018:	00003517          	auipc	a0,0x3
    8000601c:	8f850513          	addi	a0,a0,-1800 # 80008910 <syscall_names+0x338>
    80006020:	ffffa097          	auipc	ra,0xffffa
    80006024:	522080e7          	jalr	1314(ra) # 80000542 <panic>
    panic("virtio_disk_intr 2");
    80006028:	00003517          	auipc	a0,0x3
    8000602c:	90050513          	addi	a0,a0,-1792 # 80008928 <syscall_names+0x350>
    80006030:	ffffa097          	auipc	ra,0xffffa
    80006034:	512080e7          	jalr	1298(ra) # 80000542 <panic>

0000000080006038 <virtio_disk_init>:
{
    80006038:	1101                	addi	sp,sp,-32
    8000603a:	ec06                	sd	ra,24(sp)
    8000603c:	e822                	sd	s0,16(sp)
    8000603e:	e426                	sd	s1,8(sp)
    80006040:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006042:	00003597          	auipc	a1,0x3
    80006046:	8fe58593          	addi	a1,a1,-1794 # 80008940 <syscall_names+0x368>
    8000604a:	00020517          	auipc	a0,0x20
    8000604e:	05e50513          	addi	a0,a0,94 # 800260a8 <disk+0x20a8>
    80006052:	ffffb097          	auipc	ra,0xffffb
    80006056:	bae080e7          	jalr	-1106(ra) # 80000c00 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000605a:	100017b7          	lui	a5,0x10001
    8000605e:	4398                	lw	a4,0(a5)
    80006060:	2701                	sext.w	a4,a4
    80006062:	747277b7          	lui	a5,0x74727
    80006066:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000606a:	0ef71163          	bne	a4,a5,8000614c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000606e:	100017b7          	lui	a5,0x10001
    80006072:	43dc                	lw	a5,4(a5)
    80006074:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006076:	4705                	li	a4,1
    80006078:	0ce79a63          	bne	a5,a4,8000614c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000607c:	100017b7          	lui	a5,0x10001
    80006080:	479c                	lw	a5,8(a5)
    80006082:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006084:	4709                	li	a4,2
    80006086:	0ce79363          	bne	a5,a4,8000614c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000608a:	100017b7          	lui	a5,0x10001
    8000608e:	47d8                	lw	a4,12(a5)
    80006090:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006092:	554d47b7          	lui	a5,0x554d4
    80006096:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000609a:	0af71963          	bne	a4,a5,8000614c <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000609e:	100017b7          	lui	a5,0x10001
    800060a2:	4705                	li	a4,1
    800060a4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060a6:	470d                	li	a4,3
    800060a8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060aa:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800060ac:	c7ffe737          	lui	a4,0xc7ffe
    800060b0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd775f>
    800060b4:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060b6:	2701                	sext.w	a4,a4
    800060b8:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ba:	472d                	li	a4,11
    800060bc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060be:	473d                	li	a4,15
    800060c0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800060c2:	6705                	lui	a4,0x1
    800060c4:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060c6:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060ca:	5bdc                	lw	a5,52(a5)
    800060cc:	2781                	sext.w	a5,a5
  if(max == 0)
    800060ce:	c7d9                	beqz	a5,8000615c <virtio_disk_init+0x124>
  if(max < NUM)
    800060d0:	471d                	li	a4,7
    800060d2:	08f77d63          	bgeu	a4,a5,8000616c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800060d6:	100014b7          	lui	s1,0x10001
    800060da:	47a1                	li	a5,8
    800060dc:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800060de:	6609                	lui	a2,0x2
    800060e0:	4581                	li	a1,0
    800060e2:	0001e517          	auipc	a0,0x1e
    800060e6:	f1e50513          	addi	a0,a0,-226 # 80024000 <disk>
    800060ea:	ffffb097          	auipc	ra,0xffffb
    800060ee:	ca2080e7          	jalr	-862(ra) # 80000d8c <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800060f2:	0001e717          	auipc	a4,0x1e
    800060f6:	f0e70713          	addi	a4,a4,-242 # 80024000 <disk>
    800060fa:	00c75793          	srli	a5,a4,0xc
    800060fe:	2781                	sext.w	a5,a5
    80006100:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80006102:	00020797          	auipc	a5,0x20
    80006106:	efe78793          	addi	a5,a5,-258 # 80026000 <disk+0x2000>
    8000610a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    8000610c:	0001e717          	auipc	a4,0x1e
    80006110:	f7470713          	addi	a4,a4,-140 # 80024080 <disk+0x80>
    80006114:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80006116:	0001f717          	auipc	a4,0x1f
    8000611a:	eea70713          	addi	a4,a4,-278 # 80025000 <disk+0x1000>
    8000611e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006120:	4705                	li	a4,1
    80006122:	00e78c23          	sb	a4,24(a5)
    80006126:	00e78ca3          	sb	a4,25(a5)
    8000612a:	00e78d23          	sb	a4,26(a5)
    8000612e:	00e78da3          	sb	a4,27(a5)
    80006132:	00e78e23          	sb	a4,28(a5)
    80006136:	00e78ea3          	sb	a4,29(a5)
    8000613a:	00e78f23          	sb	a4,30(a5)
    8000613e:	00e78fa3          	sb	a4,31(a5)
}
    80006142:	60e2                	ld	ra,24(sp)
    80006144:	6442                	ld	s0,16(sp)
    80006146:	64a2                	ld	s1,8(sp)
    80006148:	6105                	addi	sp,sp,32
    8000614a:	8082                	ret
    panic("could not find virtio disk");
    8000614c:	00003517          	auipc	a0,0x3
    80006150:	80450513          	addi	a0,a0,-2044 # 80008950 <syscall_names+0x378>
    80006154:	ffffa097          	auipc	ra,0xffffa
    80006158:	3ee080e7          	jalr	1006(ra) # 80000542 <panic>
    panic("virtio disk has no queue 0");
    8000615c:	00003517          	auipc	a0,0x3
    80006160:	81450513          	addi	a0,a0,-2028 # 80008970 <syscall_names+0x398>
    80006164:	ffffa097          	auipc	ra,0xffffa
    80006168:	3de080e7          	jalr	990(ra) # 80000542 <panic>
    panic("virtio disk max queue too short");
    8000616c:	00003517          	auipc	a0,0x3
    80006170:	82450513          	addi	a0,a0,-2012 # 80008990 <syscall_names+0x3b8>
    80006174:	ffffa097          	auipc	ra,0xffffa
    80006178:	3ce080e7          	jalr	974(ra) # 80000542 <panic>

000000008000617c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000617c:	7175                	addi	sp,sp,-144
    8000617e:	e506                	sd	ra,136(sp)
    80006180:	e122                	sd	s0,128(sp)
    80006182:	fca6                	sd	s1,120(sp)
    80006184:	f8ca                	sd	s2,112(sp)
    80006186:	f4ce                	sd	s3,104(sp)
    80006188:	f0d2                	sd	s4,96(sp)
    8000618a:	ecd6                	sd	s5,88(sp)
    8000618c:	e8da                	sd	s6,80(sp)
    8000618e:	e4de                	sd	s7,72(sp)
    80006190:	e0e2                	sd	s8,64(sp)
    80006192:	fc66                	sd	s9,56(sp)
    80006194:	f86a                	sd	s10,48(sp)
    80006196:	f46e                	sd	s11,40(sp)
    80006198:	0900                	addi	s0,sp,144
    8000619a:	8aaa                	mv	s5,a0
    8000619c:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000619e:	00c52c83          	lw	s9,12(a0)
    800061a2:	001c9c9b          	slliw	s9,s9,0x1
    800061a6:	1c82                	slli	s9,s9,0x20
    800061a8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800061ac:	00020517          	auipc	a0,0x20
    800061b0:	efc50513          	addi	a0,a0,-260 # 800260a8 <disk+0x20a8>
    800061b4:	ffffb097          	auipc	ra,0xffffb
    800061b8:	adc080e7          	jalr	-1316(ra) # 80000c90 <acquire>
  for(int i = 0; i < 3; i++){
    800061bc:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800061be:	44a1                	li	s1,8
      disk.free[i] = 0;
    800061c0:	0001ec17          	auipc	s8,0x1e
    800061c4:	e40c0c13          	addi	s8,s8,-448 # 80024000 <disk>
    800061c8:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    800061ca:	4b0d                	li	s6,3
    800061cc:	a0ad                	j	80006236 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800061ce:	00fc0733          	add	a4,s8,a5
    800061d2:	975e                	add	a4,a4,s7
    800061d4:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800061d8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800061da:	0207c563          	bltz	a5,80006204 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800061de:	2905                	addiw	s2,s2,1
    800061e0:	0611                	addi	a2,a2,4
    800061e2:	19690d63          	beq	s2,s6,8000637c <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    800061e6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800061e8:	00020717          	auipc	a4,0x20
    800061ec:	e3070713          	addi	a4,a4,-464 # 80026018 <disk+0x2018>
    800061f0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800061f2:	00074683          	lbu	a3,0(a4)
    800061f6:	fee1                	bnez	a3,800061ce <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800061f8:	2785                	addiw	a5,a5,1
    800061fa:	0705                	addi	a4,a4,1
    800061fc:	fe979be3          	bne	a5,s1,800061f2 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006200:	57fd                	li	a5,-1
    80006202:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006204:	01205d63          	blez	s2,8000621e <virtio_disk_rw+0xa2>
    80006208:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    8000620a:	000a2503          	lw	a0,0(s4)
    8000620e:	00000097          	auipc	ra,0x0
    80006212:	da8080e7          	jalr	-600(ra) # 80005fb6 <free_desc>
      for(int j = 0; j < i; j++)
    80006216:	2d85                	addiw	s11,s11,1
    80006218:	0a11                	addi	s4,s4,4
    8000621a:	ffb918e3          	bne	s2,s11,8000620a <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000621e:	00020597          	auipc	a1,0x20
    80006222:	e8a58593          	addi	a1,a1,-374 # 800260a8 <disk+0x20a8>
    80006226:	00020517          	auipc	a0,0x20
    8000622a:	df250513          	addi	a0,a0,-526 # 80026018 <disk+0x2018>
    8000622e:	ffffc097          	auipc	ra,0xffffc
    80006232:	050080e7          	jalr	80(ra) # 8000227e <sleep>
  for(int i = 0; i < 3; i++){
    80006236:	f8040a13          	addi	s4,s0,-128
{
    8000623a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000623c:	894e                	mv	s2,s3
    8000623e:	b765                	j	800061e6 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006240:	00020717          	auipc	a4,0x20
    80006244:	dc073703          	ld	a4,-576(a4) # 80026000 <disk+0x2000>
    80006248:	973e                	add	a4,a4,a5
    8000624a:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000624e:	0001e517          	auipc	a0,0x1e
    80006252:	db250513          	addi	a0,a0,-590 # 80024000 <disk>
    80006256:	00020717          	auipc	a4,0x20
    8000625a:	daa70713          	addi	a4,a4,-598 # 80026000 <disk+0x2000>
    8000625e:	6314                	ld	a3,0(a4)
    80006260:	96be                	add	a3,a3,a5
    80006262:	00c6d603          	lhu	a2,12(a3)
    80006266:	00166613          	ori	a2,a2,1
    8000626a:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000626e:	f8842683          	lw	a3,-120(s0)
    80006272:	6310                	ld	a2,0(a4)
    80006274:	97b2                	add	a5,a5,a2
    80006276:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    8000627a:	20048613          	addi	a2,s1,512 # 10001200 <_entry-0x6fffee00>
    8000627e:	0612                	slli	a2,a2,0x4
    80006280:	962a                	add	a2,a2,a0
    80006282:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006286:	00469793          	slli	a5,a3,0x4
    8000628a:	630c                	ld	a1,0(a4)
    8000628c:	95be                	add	a1,a1,a5
    8000628e:	6689                	lui	a3,0x2
    80006290:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006294:	96ca                	add	a3,a3,s2
    80006296:	96aa                	add	a3,a3,a0
    80006298:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    8000629a:	6314                	ld	a3,0(a4)
    8000629c:	96be                	add	a3,a3,a5
    8000629e:	4585                	li	a1,1
    800062a0:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062a2:	6314                	ld	a3,0(a4)
    800062a4:	96be                	add	a3,a3,a5
    800062a6:	4509                	li	a0,2
    800062a8:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    800062ac:	6314                	ld	a3,0(a4)
    800062ae:	97b6                	add	a5,a5,a3
    800062b0:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062b4:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800062b8:	03563423          	sd	s5,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    800062bc:	6714                	ld	a3,8(a4)
    800062be:	0026d783          	lhu	a5,2(a3)
    800062c2:	8b9d                	andi	a5,a5,7
    800062c4:	0789                	addi	a5,a5,2
    800062c6:	0786                	slli	a5,a5,0x1
    800062c8:	97b6                	add	a5,a5,a3
    800062ca:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    800062ce:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800062d2:	6718                	ld	a4,8(a4)
    800062d4:	00275783          	lhu	a5,2(a4)
    800062d8:	2785                	addiw	a5,a5,1
    800062da:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800062de:	100017b7          	lui	a5,0x10001
    800062e2:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800062e6:	004aa783          	lw	a5,4(s5)
    800062ea:	02b79163          	bne	a5,a1,8000630c <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800062ee:	00020917          	auipc	s2,0x20
    800062f2:	dba90913          	addi	s2,s2,-582 # 800260a8 <disk+0x20a8>
  while(b->disk == 1) {
    800062f6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800062f8:	85ca                	mv	a1,s2
    800062fa:	8556                	mv	a0,s5
    800062fc:	ffffc097          	auipc	ra,0xffffc
    80006300:	f82080e7          	jalr	-126(ra) # 8000227e <sleep>
  while(b->disk == 1) {
    80006304:	004aa783          	lw	a5,4(s5)
    80006308:	fe9788e3          	beq	a5,s1,800062f8 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    8000630c:	f8042483          	lw	s1,-128(s0)
    80006310:	20048793          	addi	a5,s1,512
    80006314:	00479713          	slli	a4,a5,0x4
    80006318:	0001e797          	auipc	a5,0x1e
    8000631c:	ce878793          	addi	a5,a5,-792 # 80024000 <disk>
    80006320:	97ba                	add	a5,a5,a4
    80006322:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006326:	00020917          	auipc	s2,0x20
    8000632a:	cda90913          	addi	s2,s2,-806 # 80026000 <disk+0x2000>
    8000632e:	a019                	j	80006334 <virtio_disk_rw+0x1b8>
      i = disk.desc[i].next;
    80006330:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    80006334:	8526                	mv	a0,s1
    80006336:	00000097          	auipc	ra,0x0
    8000633a:	c80080e7          	jalr	-896(ra) # 80005fb6 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    8000633e:	0492                	slli	s1,s1,0x4
    80006340:	00093783          	ld	a5,0(s2)
    80006344:	94be                	add	s1,s1,a5
    80006346:	00c4d783          	lhu	a5,12(s1)
    8000634a:	8b85                	andi	a5,a5,1
    8000634c:	f3f5                	bnez	a5,80006330 <virtio_disk_rw+0x1b4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000634e:	00020517          	auipc	a0,0x20
    80006352:	d5a50513          	addi	a0,a0,-678 # 800260a8 <disk+0x20a8>
    80006356:	ffffb097          	auipc	ra,0xffffb
    8000635a:	9ee080e7          	jalr	-1554(ra) # 80000d44 <release>
}
    8000635e:	60aa                	ld	ra,136(sp)
    80006360:	640a                	ld	s0,128(sp)
    80006362:	74e6                	ld	s1,120(sp)
    80006364:	7946                	ld	s2,112(sp)
    80006366:	79a6                	ld	s3,104(sp)
    80006368:	7a06                	ld	s4,96(sp)
    8000636a:	6ae6                	ld	s5,88(sp)
    8000636c:	6b46                	ld	s6,80(sp)
    8000636e:	6ba6                	ld	s7,72(sp)
    80006370:	6c06                	ld	s8,64(sp)
    80006372:	7ce2                	ld	s9,56(sp)
    80006374:	7d42                	ld	s10,48(sp)
    80006376:	7da2                	ld	s11,40(sp)
    80006378:	6149                	addi	sp,sp,144
    8000637a:	8082                	ret
  if(write)
    8000637c:	01a037b3          	snez	a5,s10
    80006380:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006384:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006388:	f7943c23          	sd	s9,-136(s0)
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    8000638c:	f8042483          	lw	s1,-128(s0)
    80006390:	00449913          	slli	s2,s1,0x4
    80006394:	00020997          	auipc	s3,0x20
    80006398:	c6c98993          	addi	s3,s3,-916 # 80026000 <disk+0x2000>
    8000639c:	0009ba03          	ld	s4,0(s3)
    800063a0:	9a4a                	add	s4,s4,s2
    800063a2:	f7040513          	addi	a0,s0,-144
    800063a6:	ffffb097          	auipc	ra,0xffffb
    800063aa:	db6080e7          	jalr	-586(ra) # 8000115c <kvmpa>
    800063ae:	00aa3023          	sd	a0,0(s4)
  disk.desc[idx[0]].len = sizeof(buf0);
    800063b2:	0009b783          	ld	a5,0(s3)
    800063b6:	97ca                	add	a5,a5,s2
    800063b8:	4741                	li	a4,16
    800063ba:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063bc:	0009b783          	ld	a5,0(s3)
    800063c0:	97ca                	add	a5,a5,s2
    800063c2:	4705                	li	a4,1
    800063c4:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800063c8:	f8442783          	lw	a5,-124(s0)
    800063cc:	0009b703          	ld	a4,0(s3)
    800063d0:	974a                	add	a4,a4,s2
    800063d2:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    800063d6:	0792                	slli	a5,a5,0x4
    800063d8:	0009b703          	ld	a4,0(s3)
    800063dc:	973e                	add	a4,a4,a5
    800063de:	058a8693          	addi	a3,s5,88
    800063e2:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    800063e4:	0009b703          	ld	a4,0(s3)
    800063e8:	973e                	add	a4,a4,a5
    800063ea:	40000693          	li	a3,1024
    800063ee:	c714                	sw	a3,8(a4)
  if(write)
    800063f0:	e40d18e3          	bnez	s10,80006240 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800063f4:	00020717          	auipc	a4,0x20
    800063f8:	c0c73703          	ld	a4,-1012(a4) # 80026000 <disk+0x2000>
    800063fc:	973e                	add	a4,a4,a5
    800063fe:	4689                	li	a3,2
    80006400:	00d71623          	sh	a3,12(a4)
    80006404:	b5a9                	j	8000624e <virtio_disk_rw+0xd2>

0000000080006406 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006406:	1101                	addi	sp,sp,-32
    80006408:	ec06                	sd	ra,24(sp)
    8000640a:	e822                	sd	s0,16(sp)
    8000640c:	e426                	sd	s1,8(sp)
    8000640e:	e04a                	sd	s2,0(sp)
    80006410:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006412:	00020517          	auipc	a0,0x20
    80006416:	c9650513          	addi	a0,a0,-874 # 800260a8 <disk+0x20a8>
    8000641a:	ffffb097          	auipc	ra,0xffffb
    8000641e:	876080e7          	jalr	-1930(ra) # 80000c90 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006422:	00020717          	auipc	a4,0x20
    80006426:	bde70713          	addi	a4,a4,-1058 # 80026000 <disk+0x2000>
    8000642a:	02075783          	lhu	a5,32(a4)
    8000642e:	6b18                	ld	a4,16(a4)
    80006430:	00275683          	lhu	a3,2(a4)
    80006434:	8ebd                	xor	a3,a3,a5
    80006436:	8a9d                	andi	a3,a3,7
    80006438:	cab9                	beqz	a3,8000648e <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000643a:	0001e917          	auipc	s2,0x1e
    8000643e:	bc690913          	addi	s2,s2,-1082 # 80024000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006442:	00020497          	auipc	s1,0x20
    80006446:	bbe48493          	addi	s1,s1,-1090 # 80026000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    8000644a:	078e                	slli	a5,a5,0x3
    8000644c:	97ba                	add	a5,a5,a4
    8000644e:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006450:	20078713          	addi	a4,a5,512
    80006454:	0712                	slli	a4,a4,0x4
    80006456:	974a                	add	a4,a4,s2
    80006458:	03074703          	lbu	a4,48(a4)
    8000645c:	ef21                	bnez	a4,800064b4 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000645e:	20078793          	addi	a5,a5,512
    80006462:	0792                	slli	a5,a5,0x4
    80006464:	97ca                	add	a5,a5,s2
    80006466:	7798                	ld	a4,40(a5)
    80006468:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    8000646c:	7788                	ld	a0,40(a5)
    8000646e:	ffffc097          	auipc	ra,0xffffc
    80006472:	f90080e7          	jalr	-112(ra) # 800023fe <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006476:	0204d783          	lhu	a5,32(s1)
    8000647a:	2785                	addiw	a5,a5,1
    8000647c:	8b9d                	andi	a5,a5,7
    8000647e:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006482:	6898                	ld	a4,16(s1)
    80006484:	00275683          	lhu	a3,2(a4)
    80006488:	8a9d                	andi	a3,a3,7
    8000648a:	fcf690e3          	bne	a3,a5,8000644a <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000648e:	10001737          	lui	a4,0x10001
    80006492:	533c                	lw	a5,96(a4)
    80006494:	8b8d                	andi	a5,a5,3
    80006496:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006498:	00020517          	auipc	a0,0x20
    8000649c:	c1050513          	addi	a0,a0,-1008 # 800260a8 <disk+0x20a8>
    800064a0:	ffffb097          	auipc	ra,0xffffb
    800064a4:	8a4080e7          	jalr	-1884(ra) # 80000d44 <release>
}
    800064a8:	60e2                	ld	ra,24(sp)
    800064aa:	6442                	ld	s0,16(sp)
    800064ac:	64a2                	ld	s1,8(sp)
    800064ae:	6902                	ld	s2,0(sp)
    800064b0:	6105                	addi	sp,sp,32
    800064b2:	8082                	ret
      panic("virtio_disk_intr status");
    800064b4:	00002517          	auipc	a0,0x2
    800064b8:	4fc50513          	addi	a0,a0,1276 # 800089b0 <syscall_names+0x3d8>
    800064bc:	ffffa097          	auipc	ra,0xffffa
    800064c0:	086080e7          	jalr	134(ra) # 80000542 <panic>
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
